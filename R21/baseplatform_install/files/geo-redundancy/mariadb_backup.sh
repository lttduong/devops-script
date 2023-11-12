#!/usr/bin/env bash

readonly DEFAULT_BP_NAMESPACE='netguard-base'
readonly INPUT_PARAM_ERROR_CODE=1
readonly APP_ERROR_CODE=2
readonly BACKUP_ACTION=backup
readonly RESTORE_ACTION=restore
readonly ACTION_POSSIBLE_VALUES="${BACKUP_ACTION}|${RESTORE_ACTION}"
readonly CMDB_APP=cmdb
readonly MAXSCALE_LBL=maxscale
readonly MARIADB_LBL=mariadb
readonly MARIADB_CONTAINER=mariadb
readonly MAXSCALE_CONTAINER=maxscale
readonly BACKUP_FILE_NAME=full_backup.xb.gz.enc

function log_info {
    local msg=$1
    logger -s -p user.info "${BASH_SOURCE[0]} | INFO | ${msg}"
}

function log_error_and_exit {
    local msg=$1
    logger -s -p user.err "${BASH_SOURCE[0]} | ERROR | ${msg}"
    exit "${APP_ERROR_CODE}"
}

function get_all_maxscale_pods {
    kubectl get pod -n "${BP_NAMESPACE}" -l app=${CMDB_APP},type=${MAXSCALE_LBL} -o jsonpath='{.items[*].metadata.name}'
}

function get_all_mariadb_pods {
    kubectl get pod -n "${BP_NAMESPACE}" -l app=${CMDB_APP},type=${MARIADB_LBL} -o jsonpath='{.items[*].metadata.name}'
}

function get_mariadb_slave_pod {
    kubectl get pod -n "${BP_NAMESPACE}" -l app=${CMDB_APP},type=${MARIADB_LBL},mariadb-master!=yes -o jsonpath={.items[0].metadata.name}
}

function disable_maxscale {
    local maxscale_pods=$(get_all_maxscale_pods)
    for pod in ${maxscale_pods}; do
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MAXSCALE_CONTAINER}" -- /usr/bin/maxscale_adm --disable --stop-slave && \
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MAXSCALE_CONTAINER}" -- /usr/lib/maxscale/maxscale_lib.py --maxscale-service=stop || \
            log_error_and_exit "Disabling maxscale '${pod}' failed."
    done
}

function enable_maxscale {
    local maxscale_pods=$(get_all_maxscale_pods)
    for pod in ${maxscale_pods}; do
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MAXSCALE_CONTAINER}" -- /usr/lib/maxscale/maxscale_lib.py --maxscale-service=start && \
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MAXSCALE_CONTAINER}" -- /usr/bin/maxscale_adm --enable || \
            log_error_and_exit "Enabling maxscale '${pod}' failed."
    done
}

function cleanup_pod_backup_file {
    local pod=$1
    local backup_file=$2

    kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c ${MARIADB_CONTAINER} -- rm ${backup_file}
}

function get_db_passwd {
    local pod=$1

    kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}" -- mariadb_passwd --get --user=root
}

function get_persistance_backup_dir {
    pod=$1

    kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}" -- \
        awk '$1 == "PERSISTENCE_BACKUP_DIR" {print $2}' /etc/sysconfig/mariadb
}

function create_mariadb_backup {
    local mariadb_slave_pod=$(get_mariadb_slave_pod)
    local db_passwd=$(get_db_passwd ${mariadb_slave_pod})

    kubectl exec -n "${BP_NAMESPACE}" "${mariadb_slave_pod}" -c ${MARIADB_CONTAINER} -- \
        bash -c "mariabackup --backup --user=root '--password=${db_passwd}' --stream=xbstream | gzip | \
        openssl enc -aes-256-cbc -k '${db_passwd}'" > "${BACKUP_FILE}" ||
        log_error_and_exit "Creating database backup for ${mariadb_slave_pod} failed."

    log_info "Backup file successfully created: ${BACKUP_FILE}"
}

function restore_mariadb_backup {
    local mariadb_pods=$(get_all_mariadb_pods)

    disable_maxscale

    for pod in ${mariadb_pods}; do
        log_info "Restoring backup for ${pod}"
        local persistance_backup_dir=$(get_persistance_backup_dir ${pod})
        local dst_backup_dir=${persistance_backup_dir:-/mariadb/backup}
        local dst_backup_file=${dst_backup_dir}/${BACKUP_FILE_NAME}

        trap "cleanup_pod_backup_file ${pod} ${dst_backup_file}; enable_maxscale" EXIT

        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}" -- mkdir -p "${dst_backup_dir}"
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}" -- rm -rf "${dst_backup_dir}/*"
        kubectl cp -n "${BP_NAMESPACE}" "${BACKUP_FILE}" "${pod}":"${dst_backup_file}" -c "${MARIADB_CONTAINER}"
        kubectl exec -n "${BP_NAMESPACE}" "${pod}" -c "${MARIADB_CONTAINER}"  -- \
            /usr/bin/mariadb_db_backup --restore --all --dir "${dst_backup_dir}" ||
            log_error_and_exit "Restoring database backup for ${pod} failed."

        log_info "Backup for ${pod} successfully restored"

        trap - EXIT

        cleanup_pod_backup_file ${pod} ${dst_backup_file}
    done

    enable_maxscale

    log_info "Backup successfully restored"
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        log_info "--bp-namespace parameter not set - setting default ${DEFAULT_BP_NAMESPACE}"
        BP_NAMESPACE=${DEFAULT_BP_NAMESPACE}
    fi

    if [ -z "${ACTION}" ]; then
        display_help
        log_error_and_exit "--action parameter not set"
    fi

    if [ -z "${BACKUP_FILE}" ]; then
        display_help
        log_error_and_exit "--backup-file parameter not set."
    fi

    if [[ ! -f "${BACKUP_FILE}" ]] && [[ "${ACTION}" == "${RESTORE_ACTION}" ]]; then
        display_help
        log_error_and_exit "Specified backup-file does not exist."
    fi

    if [[ -f "${BACKUP_FILE}" ]] && [[ "${ACTION}" == "${BACKUP_ACTION}" ]]; then
        display_help
        log_error_and_exit "Specified backup-file already exists."
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
        --backup-file=*)
        BACKUP_FILE="${i#*=}"
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
    echo "Usage: $0 [options...]" >&2
    echo "options:"
    echo "  --bp-namespace The same as provided in Base Platform installation (default: ${DEFAULT_BP_NAMESPACE})"
    echo "  --backup-file Path to the backup-file"
    echo "  --action Action to be performed - backup or restore. Possible values: backup|restore"
    echo "Example: $0 --bp-namespace=netguard-base --backup-file=/tmp/mariadb-backup --action=backup"
    echo "         $0 --bp-namespace=netguard-base --backup-file=/tmp/mariadb-backup --action=restore"
}

function main {
    parse_input_parameters "${@}"
    validate_parameters

    if [[ "${ACTION}" == "${BACKUP_ACTION}" ]]; then
        create_mariadb_backup
    elif [[ "${ACTION}" == "${RESTORE_ACTION}" ]]; then
        restore_mariadb_backup
    fi
}

main "${@}"
