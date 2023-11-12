#!/usr/bin/env bash

readonly DEFAULT_BP_NAMESPACE='netguard-base'
readonly DEFAULT_CONFIG_NAMESPACE='netguard-configuration'
readonly INPUT_PARAM_ERROR=1

function get_secret() {
    namespace=$1
    k8s_secret_name=$2
    secret_key=$3

    kubectl get secret -n "${namespace}" "${k8s_secret_name}" -o jsonpath={.data.${secret_key}} | base64 -d
}

function get_mariadb_pod() {
    kubectl get pod -n ${BP_NAMESPACE} -l app=cmdb,csf-subcomponent=mariadb -o name | head -n 1
}

function list_secrets() {
    local mariadb_pod=$(get_mariadb_pod)

    local keycloak_db_password=$(helm get values ckey | grep keycloak_db_password | awk '{print $2}')
    local keycloak_admin_password=$(get_secret ${BP_NAMESPACE} ckey-ckey keycloak-admin-password)
    local mariadb_user_password=$(get_secret ${CONFIG_NAMESPACE} cmdb-configurator-config mariadb-password)
    local maxscale_user_password=$(helm get values cmdb | grep maxscale_user_password | awk '{print $2}' | base64 -d)
    local repl_user_password=$(helm get values cmdb | grep repl_user_password | awk '{print $2}' | base64 -d)
    local metrics_user_password=$(helm get values cmdb | grep metrics_password | awk '{print $2}' | base64 -d)
    local base_platform_sso_secret=$(get_secret ${CONFIG_NAMESPACE} ckey-netguard-config-base-platform-sso-secret base-platform-sso-secret)
    local grafana_db_password=$(helm get values btel-db-config | grep grafana_db_password | awk '{print $2}')
    local calm_db_password=$(helm get values btel-db-config | grep calm_db_password | awk '{print $2}')
    local cmdb_root_password=$(kubectl exec -n ${BP_NAMESPACE} ${mariadb_pod} -c mariadb -- mariadb_passwd --get --user=root)

    echo "Base Platform database secrets:"
    echo "KEYCLOAK_DB_PASSWORD: ${keycloak_db_password}"
    echo "KEYCLOAK_ADMIN_PASSWORD: ${keycloak_admin_password}"
    echo "MARIADB_USER_PASSWORD: ${mariadb_user_password}"
    echo "MAXSCALE_USER_PASSWORD: ${maxscale_user_password}"
    echo "REPL_USER_PASSWORD: ${repl_user_password}"
    echo "METRICS_USER_PASSWORD: ${metrics_user_password}"
    echo "BASE_PLATFORM_SSO_SECRET: ${base_platform_sso_secret}"
    echo "GRAFANA_DB_PASSWORD: ${grafana_db_password}"
    echo "CALM_DB_PASSWORD: ${calm_db_password}"
    echo "CMDB_ROOT_PASSWORD: ${cmdb_root_password}"
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        echo "--bp-namespace param not set - setting default ${DEFAULT_BP_NAMESPACE}"
        BP_NAMESPACE=${DEFAULT_BP_NAMESPACE}
    fi

    if [ -z "${CONFIG_NAMESPACE}" ]; then
        echo "--config-namespace param not set - setting default ${DEFAULT_CONFIG_NAMESPACE}"
        CONFIG_NAMESPACE=${DEFAULT_CONFIG_NAMESPACE}
    fi
}

function parse_input_parameters {
    for i in "${@}"
    do
    case $i in
        --bp-namespace=*)
        BP_NAMESPACE="${i#*=}"
        shift
        ;;
        --config-namespace=*)
        CONFIG_NAMESPACE="${i#*=}"
        shift
        ;;
        -h|--help)
        display_help
        exit 0
        ;;
        *)
        echo "Detected not supported option"
        display_help
        exit ${INPUT_PARAM_ERROR}
        ;;
    esac
    done
}

function display_help {
    echo "Usage: $0 [option...]" >&2
    echo "options:"
    echo "  --bp-namespace The same as provided in Base Platform installation (default: ${DEFAULT_BP_NAMESPACE})"
    echo "  --config-namespace The same as provided in Base Platform installation (default: ${DEFAULT_CONFIG_NAMESPACE})"
    echo "Example: $0 --bp-namespace=netguard-base --config-namespace=netguard-configuration"
}

function main {
    parse_input_parameters "${@}"
    validate_parameters
    list_secrets
}

main "${@}"