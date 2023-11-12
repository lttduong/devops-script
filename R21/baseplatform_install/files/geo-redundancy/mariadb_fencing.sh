#!/usr/bin/env bash

readonly SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
readonly DEFAULT_BP_NAMESPACE="netguard-base"
readonly INPUT_PARAM_ERROR_CODE=1
readonly APP_ERROR_CODE=2

readonly ENDPOINT="cmdb-master-remote"
readonly CONFIGMAP="cmdb-master-remote-address-backup"
readonly CONFIGMAP_KEY="address"
readonly CMDB_RELEASE="cmdb"
readonly CHARTS_DIR=${SCRIPT_DIR}/../charts/cmdb/app
readonly MARIADB_PODS="cmdb-mariadb-0 cmdb-mariadb-1"
readonly MARIADB_CONTAINER="mariadb"
readonly FENCE_ACTION=fence
readonly UNFENCE_ACTION=unfence
readonly ACTION_POSSIBLE_VALUES="${FENCE_ACTION}|${UNFENCE_ACTION}"
REMOTE_ADDRESS=

function log_info {
    local msg=$1
    logger -s -p user.info "${BASH_SOURCE[0]} | INFO | ${msg}"
}

function log_warning {
    local msg=$1
    logger -s -p user.warning "${BASH_SOURCE[0]} | WARNING | ${msg}"
}

function log_error_and_exit {
    local msg=$1
    logger -s -p user.err "${BASH_SOURCE[0]} | ERROR | ${msg}"
    exit "${APP_ERROR_CODE}"
}

function backup_remote_address {
    local address
    if ! out=$(
          kubectl get endpoints -n "${BP_NAMESPACE}" "${ENDPOINT}" -o json | \
          jq '.subsets[].addresses[].ip +":"+ (.subsets[].ports[].port|tostring)' | tr -d '"'
        2>&1);
    then
        log_error_and_exit "Failed to read remote address from endpoint: ${address}"
    else
        address="${out}"
        log_info "Remote address: ${address}"
    fi

    if ! out=$(
        kubectl create cm -n "${BP_NAMESPACE}" "${CONFIGMAP}" \
        --from-literal="${CONFIGMAP_KEY}"="${address}" 2>&1);
    then
        log_error_and_exit "Failed to create configmap: ${out}"
    fi
    log_info "Saved remote master address in configmap ${CONFIGMAP}"
}

function ensure_fencing_is_not_applied {
    if out=$(kubectl get cm -n "${BP_NAMESPACE}" "${CONFIGMAP}" 2>&1); then
        log_error_and_exit "It seems that fencing is already applied - configMap already exists: ${CONFIGMAP}"
    fi;
    log_info "ConfigMap ${CONFIGMAP} does not exist (expected)"
}

function ensure_fencing_is_applied {
    local out
    if ! out=$(kubectl get cm -n "${BP_NAMESPACE}" "${CONFIGMAP}" 2>&1); then
        log_error_and_exit "It seems that fencing is not applied - could not find configmap ${CONFIGMAP}: ${out}"
    fi;
    log_info "ConfigMap ${CONFIGMAP} exists"
}

function read_address_from_configmap {
    if ! out=$(
          kubectl get cm -n "${BP_NAMESPACE}" "${CONFIGMAP}" -o jsonpath={.data."${CONFIGMAP_KEY}"}
        2>&1);
    then
        log_error_and_exit "Failed to read remote address from ConfigMap ${CONFIGMAP}: ${address}"
    elif [ -z "${out}" ]; then
        log_error_and_exit "Failed to read remote address from ConfigMap ${CONFIGMAP}: ${address}"
    else
        REMOTE_ADDRESS="${out}"
        log_info "Read remote address: ${REMOTE_ADDRESS}"
    fi
}

function perform_cmdb_upgrade {
    helm upgrade "${CMDB_RELEASE}" "${CHARTS_DIR}" \
        --reuse-values \
        --set geo_redundancy.remote.master="${REMOTE_ADDRESS}" \
        --wait || \
        log_error_and_exit "helm upgrade of ${CMDB_RELEASE} failed"

    log_info "helm upgrade of ${CMDB_RELEASE} completed successfully"

}

function restart_mariadb_slave_processes {
    for pod in ${MARIADB_PODS}; do
        if ! out=$(
            kubectl exec -it -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}" -- bash -c \
            '/usr/bin/mysql -u root --password=$(/usr/bin/mariadb_passwd --get --user root) -e "stop slave; start slave;"'
          2>&1); then
            log_warning "Failed to restart the slave process on ${pod}: ${out}"
        else
            log_info "Restarted the slave process on ${pod}"
        fi
    done;
}

function delete_configmap {
    if ! out=$(kubectl delete configmap -n "${BP_NAMESPACE}" "${CONFIGMAP}"); then
        log_warning "Failed to delete ConfigMap ${CONFIGMAP}: ${out}"
    fi
    log_info "Deleted ConfigMap ${CONFIGMAP}"
}

function configure_fence {
    ensure_fencing_is_not_applied
    backup_remote_address
    perform_cmdb_upgrade
    restart_mariadb_slave_processes
    log_info "Script complete.  MariaDB is no longer replicating from the remote data center."
}

function unconfigure_fence {
    ensure_fencing_is_applied
    read_address_from_configmap
    perform_cmdb_upgrade
    restart_mariadb_slave_processes
    delete_configmap
    echo "Script complete.  MariaDB remote data center replication should begin shortly."
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        log_info "--bp-namespace param not set - setting default ${DEFAULT_BP_NAMESPACE}"
        BP_NAMESPACE=${DEFAULT_BP_NAMESPACE}
    fi

    if [ -z "${ACTION}" ]; then
        display_help
        log_error_and_exit "--action parameter not set"
    fi

    if ! [[ ${ACTION} =~ ^(${ACTION_POSSIBLE_VALUES})$ ]]; then
        display_help
        log_error_and_exit "Invalid value of --mode parameter. Possible values: ${ACTION_POSSIBLE_VALUES}"
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
        --action=*)
        ACTION="${i#*=}"
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
}

function display_help {
    echo "Fences the local MariaDB cluster so that it will not replicate changes made in the remote data center."
    echo "This can be used in failover scenarios if the remote data center is unstable or undergoing maintenance."
    echo
    echo "Usage: $0" >&2
    echo "  --bp-namespace The same as provided in Base Platform installation (default: ${DEFAULT_BP_NAMESPACE})"
    echo "  --action Action to be performed - fence or unfence. Possible values: fence|unfence"
    echo "Example: $0 --bp-namespace=netguard-base --action=fence"
}

function main {
    parse_input_parameters "${@}"
    validate_parameters

    if [[ "${ACTION}" == "${FENCE_ACTION}" ]]; then
        configure_fence
    elif [[ "${ACTION}" == "${UNFENCE_ACTION}" ]]; then
        unconfigure_fence
    fi
}

main "${@}"
