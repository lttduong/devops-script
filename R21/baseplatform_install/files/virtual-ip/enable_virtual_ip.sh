#!/usr/bin/env bash

readonly SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
readonly DEFAULT_BP_CONFIG_VARS_PATH="/opt/bcmt/storage/bp_config_vars.yml"
readonly IPV4_ONLY="IPV4_ONLY"
readonly IPV4_DUALSTACK="IPV4_DUALSTACK"
readonly IPV6_ONLY="IPV6_ONLY"
readonly STACK_POSSIBLE_VALUES="${IPV4_ONLY}|${IPV4_DUALSTACK}|${IPV6_ONLY}"
readonly INPUT_PARAM_ERROR_CODE=1
readonly APP_ERROR_CODE=2
readonly HELM_TIMEOUT=600
readonly VIRTUAL_IP_RELEASE_NAME="netguard-virtual-ip"
readonly CITM_RELEASE_NAME="citm"
readonly CKEY_REALM_URLS_RELEASE_NAME="ckey-realm-urls"
readonly CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME="ckey-redirect-uris-config"
readonly CKEY_REDIRECT_URIS_CONFIG_ROLLBACK_RELEASE_NAME="ckey-redirect-uris-config-rollback"
readonly VIRTUAL_IP_CHARTS_DIR=${SCRIPT_DIR}/../charts/virtual-ip/app
readonly CITM_CHARTS_DIR=${SCRIPT_DIR}/../charts/citm/app
readonly CKEY_REALM_URLS_CHARTS_DIR=${SCRIPT_DIR}/../charts/ckey/realm-urls-config
readonly CKEY_REDIRECT_URIS_CONFIG_CHARTS_DIR=${SCRIPT_DIR}/../charts/ckey/redirect-uris-config
readonly GLOBAL_VALUES_PATH=${SCRIPT_DIR}/../charts/values/global-values.yaml
readonly BCMT_REGISTRY_ADDRESS="bcmt-registry:5000"
readonly FQDN_VALIDATION_REGEX='(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'
readonly REDIRECT_SUB_URIS=("logout/*" "auth/*" "sso-redirect/*" "logout-redirect/*")
readonly CKEY_REALM_URLS_DELIMITER=";"
readonly IP_ADDRESS_DELIMITER="/"
readonly HELM_PREVIOUS_VERSION=0
declare -a CKEY_REALM_URL_DUMP_LIST
declare -a UPGRADED_COMPONENTS_LIST

function log_info {
    local msg=$1
    logger -s -p user.info "${BASH_SOURCE[0]} | INFO  | ${msg}"
}

function log_error_and_exit {
    local msg=$1
    logger -s -p user.err "${BASH_SOURCE[0]} | ERROR | ${msg}"
    exit "${APP_ERROR_CODE}"
}

function display_help {
    echo "This script enables virtual IP functionality for Base Platform"
    echo "Usage: $0 [options...]" >&2
    echo "options:"
    echo "   --bp_config_vars_path The path to Base Platform config vars (default: ${DEFAULT_BP_CONFIG_VARS_PATH})"
    echo "Examples: $0 --bp_config_vars_path=/opt/bcmt/bp_config_vars.yml"
}

function parse_input_parameters {
    for i in "${@}"
    do
    case $i in
        --bp_config_vars_path=*)
        BP_CONFIG_VARS_PATH="${i#*=}"
        shift
        ;;
        -h|--help)
        display_help
        exit 0
        ;;
        *)
        echo "Detected not supported option"
        display_help
        exit ${INPUT_PARAM_ERROR_CODE}
        ;;
    esac
    done

    if [ -z "${BP_CONFIG_VARS_PATH}" ]; then
        log_info "--bp_config_vars_path param not set - setting default ${DEFAULT_BP_CONFIG_VARS_PATH}"
        BP_CONFIG_VARS_PATH=${DEFAULT_BP_CONFIG_VARS_PATH}
    fi

    if [ ! -f "${BP_CONFIG_VARS_PATH}" ]; then
        log_error_and_exit "${BP_CONFIG_VARS_PATH} doesn't exists"
    fi
}

function read_config_vars {
    readonly BP_NAMESPACE=$(cat ${BP_CONFIG_VARS_PATH} | grep BP_NAMESPACE: | awk {'print $2'})
    readonly CONFIG_NAMESPACE=$(cat ${BP_CONFIG_VARS_PATH} | grep BP_CONFIG_NAMESPACE: | awk {'print $2'})
    readonly NETWORK_STACK=$(cat ${BP_CONFIG_VARS_PATH} | grep NETWORK_STACK: | awk {'print $2'})
    readonly VIP_ENABLED=$(cat ${BP_CONFIG_VARS_PATH} | grep VIRTUAL_IP: -A11 | grep ENABLED: | awk {'print $2'})
    readonly IPV4_ADDRESS=$(cat ${BP_CONFIG_VARS_PATH} | grep VIRTUAL_IP: -A11 | grep ADDRESS_IPV4: | awk {'print $2'} | tr -d '"')
    readonly IPV6_ADDRESS=$(cat ${BP_CONFIG_VARS_PATH} | grep VIRTUAL_IP: -A11 | grep ADDRESS_IPV6: | awk {'print $2'} | tr -d '"')
    readonly NETWORK_INTERFACE=$(cat ${BP_CONFIG_VARS_PATH} | grep VIRTUAL_IP: -A11 | grep INTERFACE: | awk {'print $2'})
    readonly FQDN=$(cat ${BP_CONFIG_VARS_PATH} | grep ACCESS_FQDNS -A1 | grep "-" | awk {'print $2'})
    readonly RESOURCES_PROFILE=$(cat ${BP_CONFIG_VARS_PATH} | grep RESOURCES: | awk {'print $2'})
    readonly CKEY_RESOURCES_PROFILE_PATH=${SCRIPT_DIR}/../charts/values/profiles/resources/${RESOURCES_PROFILE}/ckey.yaml
    local dns_name=$(cat ${BP_CONFIG_VARS_PATH} | grep DNS_DOMAIN: | awk {'print $2'} | tr -d '"')
    readonly CKEY_INTERNAL_URL="https://ckey-ckey.${BP_NAMESPACE}.svc.${dns_name}:8443"
}

function validate_ip_address() {
    local ip_address=$1
    local stack_option=${2:-""}

    validation_output=$(ipcalc -c ${stack_option} ${ip_address} 2>&1)
    is_valid_return_code=$?

    if [ ${is_valid_return_code} -ne 0 ]; then
        log_error_and_exit "IP address validation failed: ${validation_output}"
    fi
}

function validate_ipv4_address() {
    local ip_address=$1
    validate_ip_address "${ip_address}"
}

function validate_ipv6_address() {
    local ip_address=$1
    validate_ip_address "${ip_address}" -6
}

function validate_fqdn() {
    local fqdn=$1

    validation_result=$(echo ${fqdn} | grep -P ${FQDN_VALIDATION_REGEX})

    if [ -z ${validation_result} ]; then
        log_error_and_exit "${fqdn} is not valid FQDN"
    fi
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        log_error_and_exit "BP_NAMESPACE key is empty"
    fi

    if [ -z "${CONFIG_NAMESPACE}" ]; then
        log_error_and_exit "BP_CONFIG_NAMESPACE key is empty"
    fi

    if [ -z "${VIP_ENABLED}" ]; then
        display_help
        log_error_and_exit "VIRTUAL_IP.ENABLED key is empty"
    fi

    if [[ "${VIP_ENABLED}" != "true" ]]; then
        display_help
        log_error_and_exit "VIRTUAL_IP.ENABLED key is not set to true"
    fi

    if [ -z "${NETWORK_INTERFACE}" ]; then
        display_help
        log_error_and_exit "VIRTUAL_IP.INTERFACE key is empty"
    fi

    if [ -z "${NETWORK_STACK}" ]; then
        log_error_and_exit "NETWORK_STACK key is empty"
    fi

    if ! [[ ${NETWORK_STACK} =~ ^(${STACK_POSSIBLE_VALUES})$ ]]; then
        display_help
        log_error_and_exit "Invalid value of NETWORK_STACK key. Possible values: ${STACK_POSSIBLE_VALUES}"
    fi

    if [ -z "${IPV4_ADDRESS}" ] && ([[ "${NETWORK_STACK}" == "${IPV4_ONLY}" ]] || [[ "${NETWORK_STACK}" == "${IPV4_DUALSTACK}" ]]); then
        display_help
        log_error_and_exit "VIRTUAL_IP.ADDRESS_IPV4 key is empty"
    fi

    if [ -z "${IPV6_ADDRESS}" ] && ([[ "${NETWORK_STACK}" == "${IPV6_ONLY}" ]] || [[ "${NETWORK_STACK}" == "${IPV4_DUALSTACK}" ]]); then
        display_help
        log_error_and_exit "VIRTUAL_IP.ADDRESS_IPV6 key is empty"
    fi

    [[ -n "${IPV4_ADDRESS}" ]] && validate_ipv4_address "${IPV4_ADDRESS}"
    [[ -n "${IPV6_ADDRESS}" ]] && validate_ipv6_address "${IPV6_ADDRESS}"

    if ! [ -z "${FQDN}" ]; then
        validate_fqdn ${FQDN}
    fi
}

function cut_pattern_from_string() {
    local pattern=$1
    local string=$2
    echo ${string#${pattern}}
}

function dump_ckey_realm_urls() {
    log_info "Dumping ckey realm urls"
    local ckey_realm_url_dump=$(cut_pattern_from_string ${CKEY_INTERNAL_URL} $(helm get values ${CKEY_REALM_URLS_RELEASE_NAME} | grep realmUrls | awk {'print $2'}))
    CKEY_REALM_URL_DUMP_LIST=(${ckey_realm_url_dump//$CKEY_REALM_URLS_DELIMITER/ })
    log_info "ckey realm urls successfully dumped"
}

function prepare_redirect_uris() {
    local addresses=("$@")

    local redirect_uris=""
    for address in "${addresses[@]}"
    do
      for redirect_sub_uri in "${REDIRECT_SUB_URIS[@]}"
      do
          redirect_uris="${redirect_uris:+$redirect_uris\\,}\\\"${address}/${redirect_sub_uri}\\\""
      done
    done
    echo ${redirect_uris}
}

function update_ckey_redirect_uris() {
    local ip_address=$1
    local fqdn=$2

    declare -a address=("https://$([[ "${fqdn}" != "" ]] && echo "${fqdn}" || echo "${ip_address}")")
    declare -a addresses=("${CKEY_REALM_URL_DUMP_LIST[@]}" "${address[@]}")

    log_info "Updating CKEY redirect uris"

    UPGRADED_COMPONENTS_LIST+=(${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME})
    helm install ${CKEY_REDIRECT_URIS_CONFIG_CHARTS_DIR} \
        --name ${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME} \
        --namespace ${CONFIG_NAMESPACE} \
        --values ${GLOBAL_VALUES_PATH} \
        --values ${CKEY_RESOURCES_PROFILE_PATH} \
        --set image.registry=${BCMT_REGISTRY_ADDRESS} \
        --set redirectUris=$(prepare_redirect_uris ${addresses[@]}) \
        --timeout ${HELM_TIMEOUT} \
        --wait || \
        rollback_components ${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME} "${UPGRADED_COMPONENTS_LIST[@]}"

    log_info "CKEY redirect uris update has successfully finished"
}

function install_virtual_ip_chart() {

    log_info "Installing ${VIRTUAL_IP_RELEASE_NAME} chart"

    UPGRADED_COMPONENTS_LIST+=(${VIRTUAL_IP_RELEASE_NAME})
    helm install "${VIRTUAL_IP_CHARTS_DIR}" \
        --name ${VIRTUAL_IP_RELEASE_NAME} \
        --namespace ${BP_NAMESPACE} \
        --set virtualIp.enabled=true \
        --set instanceGroup.ipv4Address=${IPV4_ADDRESS} \
        --set instanceGroup.ipv6Address=${IPV6_ADDRESS} \
        --set instanceGroup.interface=${NETWORK_INTERFACE} \
        --timeout ${HELM_TIMEOUT} \
        --wait || \
        rollback_components ${VIRTUAL_IP_RELEASE_NAME} "${UPGRADED_COMPONENTS_LIST[@]}"

    log_info "Release ${VIRTUAL_IP_RELEASE_NAME} successfully installed"
}

function upgrade_citm() {
    local address=$1
    local fqdn=$2

    local dns_names_count=$(helm get values ${CITM_RELEASE_NAME} --output json | jq '.certManager.dnsNames | length')
    local ip_addresses_count=$(helm get values ${CITM_RELEASE_NAME} --output json | jq '.certManager.ipAddresses | length')
    local cert_manager_values=""
    if [[ "${fqdn}" != "" ]]; then
        cert_manager_values="certManager.dnsNames[${dns_names_count}]=${fqdn}"
    else
        cert_manager_values="certManager.ipAddresses[${ip_addresses_count}]=${address}"
    fi

    log_info "Upgrading ${CITM_RELEASE_NAME} component"

    UPGRADED_COMPONENTS_LIST+=(${CITM_RELEASE_NAME})
    helm upgrade "${CITM_RELEASE_NAME}" "${CITM_CHARTS_DIR}" \
        --reuse-values \
        --recreate-pods \
        --set ${cert_manager_values} \
        --timeout ${HELM_TIMEOUT} \
        --wait || \
        rollback_components ${CITM_RELEASE_NAME} "${UPGRADED_COMPONENTS_LIST[@]}"

     log_info "Release ${CITM_RELEASE_NAME} successfully upgraded"
}

function upgrade_ckey_realm_urls() {
    local ip_address=$1
    local fqdn=$2

    local address=$([[ "${fqdn}" != "" ]] && echo "${fqdn}" || echo "${ip_address}")

    log_info "Upgrading ${CKEY_REALM_URLS_RELEASE_NAME} component"

    UPGRADED_COMPONENTS_LIST+=(${CKEY_REALM_URLS_RELEASE_NAME})
    helm upgrade "${CKEY_REALM_URLS_RELEASE_NAME}" "${CKEY_REALM_URLS_CHARTS_DIR}" \
        --reuse-values \
        --force \
        --set config.ckey.realmUrls="${CKEY_INTERNAL_URL};${CKEY_REALM_URL_DUMP_LIST};https://${address}" \
        --timeout ${HELM_TIMEOUT} \
        --wait || \
        rollback_components ${CKEY_REALM_URLS_RELEASE_NAME} "${UPGRADED_COMPONENTS_LIST[@]}"

     log_info "Release ${CKEY_REALM_URLS_RELEASE_NAME} successfully upgraded"
}

function enable_virtual_ip() {
    log_info "Enabling vIP functionality for BP has started"
    declare -a ip_address_array=(${IPV4_ADDRESS//$IP_ADDRESS_DELIMITER/ })
    local address=${ip_address_array[0]}
    local mask=${ip_address_array[1]}

    update_ckey_redirect_uris ${address} ${FQDN}
    install_virtual_ip_chart
    upgrade_citm ${address} ${FQDN}
    upgrade_ckey_realm_urls ${address} ${FQDN}
    cleanup_on_success
    log_info "Enabling vIP functionality for BP has successfully completed"
}

function rollback_ckey_realm_urls() {
    log_info "Rollback-ing ${CKEY_REALM_URLS_RELEASE_NAME} to previous version"

    helm rollback ${CKEY_REALM_URLS_RELEASE_NAME} ${HELM_PREVIOUS_VERSION} \
        --force \
        --wait \
        --timeout ${HELM_TIMEOUT} || \
        log_error_and_exit "Rollback of ${CKEY_REALM_URLS_RELEASE_NAME} has failed"

    log_info "${CKEY_REALM_URLS_RELEASE_NAME} successfully rollback-ed"
}

function rollback_citm() {
    log_info "Rollback-ing ${CITM_RELEASE_NAME} to previous version"

    helm rollback ${CITM_RELEASE_NAME} ${HELM_PREVIOUS_VERSION} \
        --recreate-pods \
        --wait \
        --timeout ${HELM_TIMEOUT} || \
        log_error_and_exit "Rollback of ${CITM_RELEASE_NAME} has failed"

    log_info "${CITM_RELEASE_NAME} successfully rollback-ed"
}

function delete_virtual_ip() {
    delete_component ${VIRTUAL_IP_RELEASE_NAME}
}

function rollback_ckey_redirect_uris() {
    log_info "Rollback-ing CKEY redirect uris"

    helm install ${CKEY_REDIRECT_URIS_CONFIG_CHARTS_DIR} \
        --name ${CKEY_REDIRECT_URIS_CONFIG_ROLLBACK_RELEASE_NAME} \
        --namespace ${CONFIG_NAMESPACE} \
        --values ${GLOBAL_VALUES_PATH} \
        --values ${CKEY_RESOURCES_PROFILE_PATH} \
        --set image.registry=${BCMT_REGISTRY_ADDRESS} \
        --set redirectUris=$(prepare_redirect_uris ${CKEY_REALM_URL_DUMP_LIST[@]}) \
        --timeout ${HELM_TIMEOUT} \
        --wait || \
        log_error_and_exit "CKEY redirect uris rollback has failed"

    log_info "CKEY redirect uris rollback has successfully finished"
}

function is_item_on_list() {
    local item=$1
    shift
    local list=("$@")
    [[ ${list[@]} =~ (^|[[:space:]])${item}($|[[:space:]]) ]] && return 0 || return 1
}

function rollback_components() {
    local failed_component_name=$1
    shift
    local components_list=("$@")

    log_info "Installation/Upgrade of ${failed_component_name} has failed. Rollback in progress"
    $(is_item_on_list ${CKEY_REALM_URLS_RELEASE_NAME} ${components_list[@]}) && rollback_ckey_realm_urls
    $(is_item_on_list ${CITM_RELEASE_NAME} ${components_list[@]}) && rollback_citm
    $(is_item_on_list ${VIRTUAL_IP_RELEASE_NAME} ${components_list[@]}) && delete_virtual_ip
    $(is_item_on_list ${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME} ${components_list[@]}) && rollback_ckey_redirect_uris

    cleanup_on_failure
    log_error_and_exit "Enabling vIP functionality for BP has failed. The application has been rollback-ed to previous state"
}

function cleanup_on_success() {
    log_info "Performing cleanup"
    delete_component ${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME}
    log_info "Cleanup successfully performed"
}

function cleanup_on_failure() {
    log_info "Performing cleanup"
    delete_component ${CKEY_REDIRECT_URIS_CONFIG_RELEASE_NAME}
    delete_component ${CKEY_REDIRECT_URIS_CONFIG_ROLLBACK_RELEASE_NAME}
    log_info "Cleanup successfully performed"
}

function delete_component() {
    local component_name=$1

    log_info "Deleting ${component_name}"
    helm delete --purge ${component_name} || \
        log_error_and_exit "Deletion of ${component_name} release has failed"

    log_info "Release ${component_name} successfully deleted"
}

function main {
    parse_input_parameters "${@}"
    read_config_vars
    validate_parameters
    dump_ckey_realm_urls
    enable_virtual_ip
}

main "${@}"
