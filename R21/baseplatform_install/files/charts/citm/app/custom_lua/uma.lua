local log = ngx.log
local ERROR = ngx.ERR
local WARN = ngx.WARN
local INFO = ngx.INFO

local jwt = require "resty.jwt"
local http = require "resty.http"
local cjson = require "cjson"
local base64 = ngx.encode_base64
local uma = {}

local AUTHORIZATION_HEADER_NAME = "Authorization"
local CACHE_ID = "uma_rpt"

local default_opts = {
    token_expiry_claim = "exp",
    token_username_claim = "preferred_username",
    ticket_grant_type = "urn:ietf:params:oauth:grant-type:uma-ticket",
    token_endpoint = "https://ckey-ckey.{{ .Release.Namespace }}.{{ .Values.serviceDomain }}:8443/auth/realms/netguard/protocol/openid-connect/token",
    rpt_exp_leeway_seconds = 5,
    ssl_verify = false
}

local function handleError(code)
    ngx.status = code
    ngx.say("General error occurred. Error code: " .. code)
    return ngx.exit(code)
end

local function extractRPT(http_response)
    return http_response.body and cjson.decode(http_response.body).access_token or nil
end

local function extractUsername(opts, token)
    local jwt_obj = jwt:load_jwt(token)
    return jwt_obj.payload and jwt_obj.payload[opts.token_username_claim] or nil
end

local function setInCache(type, key, value, ttl)
    local cache = ngx.shared[type]

    if cache and (ttl > 0) then
        local success, err, forcible = cache:set(key, value, ttl)

        if not success then
            log(WARN, "Unable to set RPT token in cache. Reason: ", err)
        end

        if forcible then
            log(WARN, "RPT cache is full - removed valid item to make space for new token.")
        end
    end
end

local function getFromCache(type, key)
    local cache = ngx.shared[type]
    return cache and cache:get(key) or nil
end

local function getTokenExpTime(opts, token)
    local jwt_obj = jwt:load_jwt(token)
    return tonumber(jwt_obj.payload[opts.token_expiry_claim]) - opts.rpt_exp_leeway_seconds
end

local function isTokenExpired(opts, token)
    return ngx.time() > getTokenExpTime(opts, token)
end

local function requestNewRPT(opts, authn_token, resource_server_id)
    local http_client = http.new()
    local res, err = http_client:request_uri(opts.token_endpoint, {
        method = "POST",
        body = string.format("grant_type=%s&audience=%s", opts.ticket_grant_type, resource_server_id),
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["Authorization"] = "Bearer " .. ngx.escape_uri(authn_token),
            ["Host"] = ngx.var.host
        },
        ssl_verify = opts.ssl_verify
    })

    if not res then
        log(ERROR, "RPT request to the authorization server failed. Reason: ", err)
        return handleError(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if res.status == ngx.HTTP_OK then
        return extractRPT(res)
    end

    if res.status == ngx.HTTP_FORBIDDEN or res.status == ngx.HTTP_UNAUTHORIZED then
        log(INFO, "RPT request to the authorization server forbidden for user: ", extractUsername(opts, authn_token),
            " status code: ", res.status, " message: ", res.body)
        ngx.exit(res.status)
    end

    log(ERROR, "RPT request to the authorization server failed with status code: ", res.status, " message: ", res.body)
    return handleError(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local function fetchRPT(opts, authn_token, resource_server_id)
    local rpt_storage_key = string.format("%s.%s", resource_server_id, authn_token)
    local rpt = getFromCache(CACHE_ID, rpt_storage_key)

    if rpt and not isTokenExpired(opts, rpt) then
        return rpt
    end

    log(INFO, "RPT not found in cache or expired - requesting new RPT from authorization server")

    rpt = requestNewRPT(opts, authn_token, resource_server_id, opts.ticket_grant_type)

    local ttl = getTokenExpTime(opts, rpt) - ngx.time()
    setInCache(CACHE_ID, rpt_storage_key, rpt, ttl)

    return rpt
end

function uma.getOptsBuilder()
    local opts = default_opts
    local builder = {}

    function builder.withTokenEndpoint(token_endpoint)
        opts.token_endpoint = token_endpoint
        return builder
    end

    function builder.withTicketGrantType(ticket_grant_type)
        opts.ticket_grant_type = ticket_grant_type
        return builder
    end

    function builder.withTokenUsernameClaim(token_username_claim)
        opts.token_username_claim = token_username_claim
        return builder
    end

    function builder.withTokenExpiryClaim(token_expiry_claim)
        opts.token_expiry_claim = token_expiry_claim
        return builder
    end

    function builder.withSSLVerify(ssl_verify)
        opts.ssl_verify = ssl_verify
        return builder
    end

    function builder.withRPTExpLeewaySeconds(rpt_exp_leeway_seconds)
        opts.rpt_exp_leeway_seconds = rpt_exp_leeway_seconds
        return builder
    end

    function builder.build()
        return opts
    end

    return builder
end

function uma.requestRPT(opts, authn_token, resource_server_id)
    local authz = {}
    local opts = opts or default_opts
    local rpt = fetchRPT(opts, authn_token, resource_server_id)

    function authz.andAttachAsBearerAuthHeader()
        ngx.req.set_header(AUTHORIZATION_HEADER_NAME, "Bearer " .. ngx.escape_uri(rpt))
    end

    function authz.andAttachAsBasicAuthHeader()
        local username = extractUsername(opts, authn_token)
        local auth_header = "Basic " .. base64(ngx.escape_uri(username) .. ":" .. ngx.escape_uri(rpt))
        ngx.req.set_header(AUTHORIZATION_HEADER_NAME, auth_header)
    end

    function authz.andAttachAsCustomAuthHeader(user_header_name, password_header_name)
        if user_header_name then
            local username = extractUsername(opts, authn_token)
            ngx.req.set_header(user_header_name, ngx.escape_uri(username))
        end
        ngx.req.set_header(password_header_name, ngx.escape_uri(rpt))
    end

    return authz, rpt
end

return uma
