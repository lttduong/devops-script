local utils = {}
local cjson = require "cjson"
local jwt = require "resty.jwt"
local oidc = require("resty.openidc")
local r_session = require("resty.session")

local authorization_header_name = "Authorization"
local json_content_type = "application/json; charset=utf-8"
local x_requested_with_header_name = "x-requested-with"
local xhr_header_value = "xmlhttprequest"
local forbidden_403_url = "/netguard-base/403"


function utils.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    else
        return "table" == type(v) and utils.tostring(v) or
                tostring(v)
    end
end

function utils.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. utils.val_to_str(k) .. "]"
    end
end

function utils.tostring(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, utils.val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
                utils.key_to_str(k) .. "=" .. utils.val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end

function utils.joinTables(t1, t2)
    for _, v in ipairs(t2) do
        table.insert(t1, v)
    end
    return t1
end

function utils.extractClientRoles(client, token)
    return token.payload and token.payload.resource_access and token.payload.resource_access[client] and
            token.payload.resource_access[client].roles or {}
end

function utils.extractAllClientRoles(token)
    local roles_per_client, all_roles = {}, {}
    if token.payload and token.payload.resource_access then
        for k, v in pairs(token.payload.resource_access) do
            table.insert(roles_per_client, { client_id = k, roles = v.roles })
            all_roles = utils.joinTables(all_roles, v.roles)
        end
    end
    return roles_per_client, all_roles
end

function utils.extractRealmRoles(token)
    return token.payload and token.payload.realm_access and token.payload.realm_access.roles or {}
end

function utils.extractFullName(token)
    return token.payload and token.payload.name or nil
end

function utils.extractUserLogin(token)
    return token.payload and token.payload.preferred_username or nil
end

function utils.hasRole(roles, neededRole)
    if not roles then
        return false
    end
    for _, role in pairs(roles) do
        if role == neededRole then
            return true
        end
    end
    return false
end

function utils.hasAtLeastOneOfRequiredRoles(userRoles, requiredRoles)
    for _, role in ipairs(requiredRoles)
    do
        if utils.hasRole(userRoles, role) then
            return true
        end
    end
    return false
end

function utils.setToken(token)
    local bearer_header = string.format("Bearer %s", token)
    ngx.req.set_header(authorization_header_name, bearer_header)
end

function utils.removeSessionCookie()
    local cookie_name = "cookie"
    local session_prefix = "session"
    local pattern = session_prefix .. "(.-)=(.*)(;-)"
    local headers = ngx.req.get_headers()

    for key, value in pairs(headers) do
        if string.lower(key) == cookie_name then
            value = string.gsub(value, pattern, "")
            ngx.req.set_header(cookie_name, value)
        end
    end
end

function utils.getRequestHeaderValue(headerName)
    local headers = ngx.req.get_headers()

    for key, value in pairs(headers) do
        if string.lower(key) == headerName then
            return value
        end
    end

    return nil
end

function utils.handleError(code)
    ngx.status = code
    ngx.say("General error occurred. Error code: " .. code)
    return ngx.exit(code)
end

function utils.executeExternalFlow(opts)
    local res, err, access_token = oidc.bearer_jwt_verify(opts)

    if err then
        return utils.handleError(ngx.HTTP_UNAUTHORIZED)
    end

    if res then
        res['access_token'] = access_token
    end

    return res
end

function utils.isSessionIdle(opts)
    local session = r_session.open()
    local access_token = jwt:load_jwt(session.data.access_token)
    local refresh_token = jwt:load_jwt(session.data.refresh_token)
    local now = ngx.now()
    local access_token_expired = access_token and access_token.payload and now > tonumber(access_token.payload.exp)
    local refresh_token_expired = refresh_token and refresh_token.payload and now > tonumber(refresh_token.payload.exp)

    if access_token_expired and refresh_token_expired then
        ngx.log(ngx.WARN, "ACCESS DENIED - Surpassed Session Idle timeout. Logging out...")
        opts.force_reauthorize = true
        opts.token_expired = true
        return true
    end
    return false
end

function utils.executeNormalFlow(opts)
    local res, err

    if utils.hasXHRHeader() then
        res, err, _, _ = oidc.authenticate(opts, nil, "pass")
    else
        res, err, _, _ = oidc.authenticate(opts)
    end

    if err then
        ngx.log(ngx.ERR, "Error occurred during authentication: " .. err)
        return utils.handleError(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if res == nil then
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    return res
end

function utils.hasNoAuthorizationHeader()
    local authorization_header_divider = " "
    local headers = ngx.req.get_headers()
    local header = headers[authorization_header_name]
    return header == nil or header:find(authorization_header_divider) == nil
end

function utils.hasXHRHeader()
    local x_requested_with = utils.getRequestHeaderValue(x_requested_with_header_name)
    return x_requested_with ~= nil and string.lower(x_requested_with) == xhr_header_value
end

function utils.isUserAccessingWhitelistedUrl(whitelist)
    whitelist = whitelist or {}
    for _, value in ipairs(whitelist)
    do
        if string.match(ngx.var.uri, value) then
            ngx.log(ngx.DEBUG, "Allowing access without authentication for: " .. ngx.var.uri .. " due to whitelist entry: " .. value)
            return true
        end
    end
    return false
end

function utils.authenticate()

    local auth = {}
    local res = {}
    local opts = {
        client_id = "{{ .Values.client_id }}",
        client_secret = "{{ .Values.client_secret }}",
        discovery = "https://" .. ngx.var.host .. "/auth/realms/{{ .Values.realmName | lower }}/.well-known/openid-configuration",
        ssl_verify = "no",
        redirect_uri = "/sso-redirect",
        redirect_uri_scheme = "https",
        logout_path = "/logout",
        redirect_after_logout_uri = "https://" .. ngx.var.host .. "/auth/realms/{{ .Values.realmName | lower }}/protocol/openid-connect/logout?redirect_uri=https%3A%2F%2F" .. ngx.var.host .. "%2Flogout-redirect%2F",
        redirect_after_logout_with_id_token_hint = false,
        session_contents = { access_token = true },
        http_request_decorator = function(req)
            local h = req.headers or {}
            h['Host'] = ngx.var.host
            req.headers = h
            return req
        end
    }

    if utils.isSessionIdle(opts) then
        res = oidc.authenticate(opts, opts.logout_path)
    end

    if utils.hasNoAuthorizationHeader() then
        res = utils.executeNormalFlow(opts)
    else
        res = utils.executeExternalFlow(opts)
    end

    local jwt_obj = jwt:load_jwt(res.access_token)
    if res.access_token ~= nil then
        utils.setToken(res.access_token)
    end

    utils.removeSessionCookie()

    function auth.andRequireAtLeastOneOfRealmRoles(requiredRoles)
        local userRoles = utils.extractRealmRoles(jwt_obj)
        if not utils.hasAtLeastOneOfRequiredRoles(userRoles, requiredRoles or {}) then
            ngx.log(ngx.ERR, "ACCESS DENIED - missing at least one of the realm roles: " .. table.concat(requiredRoles or {}, ","))
            ngx.redirect(forbidden_403_url)
        end
        return auth
    end

    function auth.andRequireAtLeastOneOfClientRoles(requiredRoles, clientName)
        local userRoles = utils.extractClientRoles(clientName, jwt_obj)
        if not utils.hasAtLeastOneOfRequiredRoles(userRoles, requiredRoles or {}) then
            ngx.log(ngx.ERR, "ACCESS DENIED - missing at least one of the roles: " .. table.concat(requiredRoles or {}, ",") .." for client " .. clientName)
            ngx.redirect(forbidden_403_url)
        end
        return auth
    end

    function auth.andRequireReamlRole(roleName)
        local roles = utils.extractRealmRoles(jwt_obj)

        if not utils.hasRole(roles, roleName) then
            ngx.log(ngx.ERR, "ACCESS DENIED - missing realm role: " .. roleName)
            ngx.redirect(forbidden_403_url)
        end
        return auth
    end

    function auth.andRequireClientRole(roleName, clientName)
        local roles = utils.extractClientRoles(clientName, jwt_obj)

        if not utils.hasRole(roles, roleName) then
            ngx.log(ngx.ERR, "ACCESS DENIED - missing role: " .. roleName .. " for client " .. clientName)
            ngx.redirect(forbidden_403_url)
        end
        return auth
    end

    function auth.andSetProxyAuthHeaders()
        local netguard_user_header = "netguard-proxy-user"
        local netguard_roles_header = "netguard-proxy-roles"
        local username_header = "username"

        local realm_roles = utils.extractRealmRoles(jwt_obj)
        local _, all_client_roles = utils.extractAllClientRoles(jwt_obj)
        local login = utils.extractUserLogin(jwt_obj) or cjson.null

        ngx.req.set_header(netguard_user_header, login)
        ngx.req.set_header(netguard_roles_header, table.concat(utils.joinTables(realm_roles, all_client_roles), ","))
        ngx.req.set_header(username_header, login)

        return auth
    end

    function auth.andSetEmptyProxyAuthHeaders()
        local netguard_user_header = "netguard-proxy-user"
        local netguard_roles_header = "netguard-proxy-roles"
        local username_header = "username"

        local login = utils.extractUserLogin(jwt_obj) or cjson.null

        ngx.req.set_header(netguard_user_header, login)
        ngx.req.set_header(netguard_roles_header, "")
        ngx.req.set_header(username_header, login)

        return auth
    end

    function auth.andClearAuthorizationHeader()
        ngx.req.clear_header("Authorization")

        return auth
    end

    return auth, res
end

function utils.isSessionValid()
    local session = r_session.start()
    local refresh_token = jwt:load_jwt(session.data.refresh_token)
    local now = ngx.now()
    if refresh_token and refresh_token.payload and now < tonumber(refresh_token.payload.exp) then
        local values = {
            expirationTimeStamp = refresh_token.payload.exp,
            timeToRefreshTokenExpiration = tonumber(refresh_token.payload.exp) - now
        }
        local user_info_json = string.gsub(cjson.encode(values), ":{}", ":[]")
        ngx.header.content_type = json_content_type
        ngx.say(user_info_json)
        return ngx.exit(ngx.HTTP_OK)
    end
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

function utils.getUserInfo(access_token)
    local jwt_obj = jwt:load_jwt(access_token)
    local user_info = {
        realm_roles = utils.extractRealmRoles(jwt_obj),
        client_roles = utils.extractAllClientRoles(jwt_obj),
        full_name = utils.extractFullName(jwt_obj) or cjson.null,
        login = utils.extractUserLogin(jwt_obj) or cjson.null
    }

    local user_info_json = string.gsub(cjson.encode(user_info), ":{}", ":[]")
    ngx.header.content_type = json_content_type
    ngx.say(user_info_json)
    return ngx.exit(ngx.HTTP_OK)
end

return utils
