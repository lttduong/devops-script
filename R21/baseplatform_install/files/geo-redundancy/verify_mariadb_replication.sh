#!/usr/bin/env bash

readonly DEFAULT_BP_NAMESPACE='netguard-base'
readonly INPUT_PARAM_ERROR=1
readonly REPLICATION_OK_STATUS_CODE=0
readonly REPLICATION_FAILURE_STATUS_CODE=4
readonly CMDB_APP=cmdb
readonly MAXSCALE_LBL=maxscale
readonly MARIADB_LBL=mariadb
readonly MARIADB_CONTAINER=mariadb
readonly MAXSCALE_CONTAINER=maxscale

function get_mariadb_master_pod {
    kubectl get pod -n "${BP_NAMESPACE}" -l app=${CMDB_APP},type=${MARIADB_LBL},mariadb-master==yes -o jsonpath={.items[0].metadata.name}
}

function get_maxscale_pod {
    kubectl get pod -n "${BP_NAMESPACE}" -l app=${CMDB_APP},type=${MAXSCALE_LBL} -o jsonpath='{.items[0].metadata.name}'
}

function verify_replication {
    if out=$(kubectl exec -n "${BP_NAMESPACE}" "$(get_mariadb_master_pod)" -c "${MARIADB_CONTAINER}" -- \
        /usr/bin/mariadb_db --verify-replication --verbose); then
        printf "\nReplication OK\n"
        return ${REPLICATION_OK_STATUS_CODE}
    else
        printf "\nReplication FAILURE\n"
        return ${REPLICATION_FAILURE_STATUS_CODE}
    fi
}

function list_mariadb_servers {
    printf "\nMariaDB servers:\n"
    kubectl exec -n "${BP_NAMESPACE}" "$(get_maxscale_pod)" -c "${MAXSCALE_CONTAINER}" -- \
        /usr/lib/mariadb/maxscale_rest_api.py --list-servers
}

function show_replication_status {
    local mariadb_master_pod="$(get_mariadb_master_pod)"

    printf "\nSlave status of ${mariadb_master_pod} server:\n"
    kubectl exec -n "${BP_NAMESPACE}" "${mariadb_master_pod}" -c "${MARIADB_CONTAINER}" -- \
        bash -c 'mysql -u root --password=$(/usr/bin/mariadb_passwd --get --user root) -e "show slave status\\G"'
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        echo "--bp-namespace param not set - setting default ${DEFAULT_BP_NAMESPACE}"
        BP_NAMESPACE=${DEFAULT_BP_NAMESPACE}
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
    echo "Example: $0 --bp-namespace=netguard-base"
}

function main {
    parse_input_parameters "${@}"
    validate_parameters
    list_mariadb_servers
    show_replication_status
    verify_replication
}

main "${@}"