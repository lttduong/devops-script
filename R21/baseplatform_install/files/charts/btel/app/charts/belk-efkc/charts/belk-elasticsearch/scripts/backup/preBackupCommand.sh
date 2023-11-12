#!/bin/bash
set -e

readonly INDEX='es-snapshot'
readonly SNAPSHOT_DATE_AND_TIME=$(date +'%Y.%m.%d-%H:%M:%S')
readonly REPOSITORY_DATE_FORMAT='%Y/%m/%d'
readonly ADMIN_CERTIFICATE=/etc/elasticsearch/certs/admin.crt.pem
readonly ADMIN_KEY=/etc/elasticsearch/certs/admin.key.pem
readonly CURL_TEMPLATE="curl --insecure --silent --cert ${ADMIN_CERTIFICATE} --key ${ADMIN_KEY} -X %s https://$ELASTICSEARCH_SERVICE:$CLIENT_PORT/%s"
readonly ELASTICSEARCH_BACKUP_DIR=/elasticsearch-backup
readonly TEMP_ELASTICSEARCH_BACKUP_DIR=${ELASTICSEARCH_BACKUP_DIR}/tmp
readonly REPOSITORY_CREATION_DATE_PATH=${ELASTICSEARCH_BACKUP_DIR}/repository_creation_date.txt
readonly SNAPSHOTS_INDICES_PATH=${ELASTICSEARCH_BACKUP_DIR}/snapshot_indices.json
readonly SNAPSHOT_NAME_PATH=${ELASTICSEARCH_BACKUP_DIR}/snapshot_name.txt
readonly REPOSITORY_NAME=es_backup
readonly REPOSITORY_LOCATION_NAME=backup
readonly NOT_FOUND_HTTP_CODE=404

function log() {
    echo "$(date) ${*}"
}

function log_ne() {
    echo -ne "$(date) ${*}"
}

function log_info_ne() {
    log_ne INFO "${*}"
}

function log_info() {
    log INFO "${*}"
}

function log_error() {
    log ERROR "${*}"
}

function log_error_and_exit() {
    local script_return_code=1
    log_error "${*}"
    log_info "Pre backup of Elasticsearch finished with failure (script return code ${script_return_code})"
    exit ${script_return_code}
}

function display_config() {
    log_info "Snapshot name's ${INDEX}-${SNAPSHOT_DATE_AND_TIME}"
    log_info "Elasticsearch client service name is  ${ELASTICSEARCH_SERVICE}"
    log_info "Elasticsearch client port is  ${CLIENT_PORT}"
}

function does_repository_age_exceeds_cleanup_interval() {
    creation_date=$(cat ${REPOSITORY_CREATION_DATE_PATH})
    creation_timestamp=$(date -d ${creation_date} +%s)
    today_date_timestamp=$(date -d $(date +${REPOSITORY_DATE_FORMAT}) +%s)
    age_in_days=$(((${today_date_timestamp} - ${creation_timestamp}) / (60 * 60 * 24)))
    [ "${age_in_days}" -ge "${SNAPSHOTS_CLEANUP_INTERVAL}" ]
    return
}

function delete_repo() {
    log_info "Delete a repository"
    printf -v delete_repo_request "${CURL_TEMPLATE}" DELETE _snapshot/${REPOSITORY_NAME}
    response=$(${delete_repo_request})
    log_info "Repo deletion curl response ${response}"
    if [[ $(echo "${response}" | jq -r | jq .error) != null ]]; then
        log_error_and_exit "Repo deletion failed"
    fi
}

function get_repo() {
    log_info "Get a repository"
    printf -v get_repo_request "${CURL_TEMPLATE}" GET _snapshot/${REPOSITORY_NAME}
    response=$(${get_repo_request})
    log_info "Repo get curl response ${response}"
    [[ $(echo "${response}" | jq -r | jq .error) == null ]]
    return
}

function create_repo() {
    log_info "Create a directory to create snapshot"
    printf -v create_repo_request "${CURL_TEMPLATE}" PUT _snapshot/${REPOSITORY_NAME}
    repo_dir_response=$(${create_repo_request} \
        -H 'Content-Type: application/json' \
        -d'{ "type": "fs",  "settings": {"location": "'${REPOSITORY_LOCATION_NAME}'" }}')
    log_info "Repo creation curl response ${repo_dir_response}"
    if [[ $(echo "${repo_dir_response}" | jq -r | jq .error) != null ]]; then
        log_error_and_exit "Repo creation failed"
    fi
    today_date=$(date +${REPOSITORY_DATE_FORMAT})
    echo ${today_date} >${REPOSITORY_CREATION_DATE_PATH}
}

function create_snapshot() {
    log_info "Take snapshot of all elasticsearch indices"
    snapshot_name=${INDEX}-"${SNAPSHOT_DATE_AND_TIME}"
    printf -v create_snapshot_request "${CURL_TEMPLATE}" PUT _snapshot/${REPOSITORY_NAME}/${snapshot_name}?wait_for_completion=false
    snapshot_creation_state=$(${create_snapshot_request} \
                            -H 'Content-Type: application/json' \
                            -d' {"indices": "*,-searchguard,-.signals*","ignore_unavailable": true,"include_global_state": true},"partial": false}')
    log_info "Snapshot creation state is ${snapshot_creation_state}"
    error=$(echo "${snapshot_creation_state}" | jq -r | jq .error)
    if [[ ${error} != null ]]; then
        log_error_and_exit "Snapshot ${snapshot_name} creation failed ${error}"
    fi

    printf -v get_snapshot_request "${CURL_TEMPLATE}" GET _snapshot/${REPOSITORY_NAME}/${snapshot_name}
    snapshot=$(${get_snapshot_request})
    error=$(echo "${snapshot}" | jq -r | jq .error)
    if [[ ${error} != null ]]; then
        if [[ $(echo ${snapshot} | jq .status) == ${NOT_FOUND_HTTP_CODE} ]]; then
            log_error "Check if there is enough disk space on NFS server"
        fi
        log_error_and_exit "Snapshot ${snapshot_name} creation failed ${error}"
    fi
    log_info_ne "Snapshot creation in progress"
    while [[ $(echo "${snapshot}" | jq -r | jq .snapshots[].state) == '"IN_PROGRESS"' ]]; do
        printf -v get_snapshot_request "${CURL_TEMPLATE}" GET _snapshot/${REPOSITORY_NAME}/${snapshot_name}
        snapshot=$(${get_snapshot_request})
        error=$(echo "${snapshot}" | jq -r | jq .error)
        if [[ ${error} != null ]]; then
            if [[ $(echo ${snapshot} | jq .status) == ${NOT_FOUND_HTTP_CODE} ]]; then
                log_error "Check if there is enough disk space on NFS server"
            fi
            log_error_and_exit "Snapshot ${snapshot_name} creation failed ${error}"
        fi
        echo -ne "."
        sleep 30
    done
    echo ""

    if [[ $(echo "${snapshot}" | jq -r | jq .snapshots[].state) != '"SUCCESS"' ]]; then
        log_error_and_exit "Snapshot creation failed $(echo ${snapshot} | jq .snapshots[].failures)"
    fi
    echo "${snapshot}" | jq -r | jq .snapshots[].indices >${SNAPSHOTS_INDICES_PATH}
    echo "${INDEX}-${SNAPSHOT_DATE_AND_TIME}" >${SNAPSHOT_NAME_PATH}
    log_info "Snapshot of Elasticsearch data completed"
}

function revert_backup_from_tmp() {
    log_info "Reverting backup files from temporary dir"
    rm -rf ${ELASTICSEARCH_BACKUP_DIR}/${REPOSITORY_LOCATION_NAME}
    rm -rf ${SNAPSHOTS_INDICES_PATH}
    rm -rf ${SNAPSHOT_NAME_PATH}
    rm -rf ${REPOSITORY_CREATION_DATE_PATH}
    mv ${TEMP_ELASTICSEARCH_BACKUP_DIR}/* ${ELASTICSEARCH_BACKUP_DIR}
    rm -rf ${TEMP_ELASTICSEARCH_BACKUP_DIR}
    if ! get_repo; then
        repository_creation_date_backup_path=${REPOSITORY_CREATION_DATE_PATH}.bac
        mv ${REPOSITORY_CREATION_DATE_PATH} ${repository_creation_date_backup_path}
        create_repo
        mv ${repository_creation_date_backup_path} ${REPOSITORY_CREATION_DATE_PATH}
    fi
}

function cleanup() {
    if [ $? -ne 0 ]; then
        revert_backup_from_tmp
    fi
}

function create_full_backup() {
    log_info "Repository age exceeds snapshots cleanup interval days: ${SNAPSHOTS_CLEANUP_INTERVAL}"
    mkdir ${TEMP_ELASTICSEARCH_BACKUP_DIR}
    trap cleanup EXIT
    log_info "Moving actual backup repository files to temporary dir: ${TEMP_ELASTICSEARCH_BACKUP_DIR}"
    ls -d ${ELASTICSEARCH_BACKUP_DIR}/* | grep -vw ${TEMP_ELASTICSEARCH_BACKUP_DIR} | xargs mv -t ${TEMP_ELASTICSEARCH_BACKUP_DIR}
    if get_repo; then
        delete_repo
    fi
    create_repo
    create_snapshot
    rm -rf ${TEMP_ELASTICSEARCH_BACKUP_DIR}
}

function backup() {
    if [ -f ${REPOSITORY_CREATION_DATE_PATH} ]; then
        if does_repository_age_exceeds_cleanup_interval; then
            create_full_backup
        else
            if ! get_repo; then
                create_repo
            fi
            create_snapshot
        fi
    else
        create_repo
        create_snapshot
    fi
}

if [[ ${NODE_NAME} == *"data-0"* ]]; then
    log_info "Pre backup of Elasticsearch data started"
    display_config
    backup
    log_info "Pre backup of Elasticsearch data completed"
else
    if ${IS_FULL_BACKUP}; then
        log_info "Full backup of Elasticsearch data started"
        display_config
        create_full_backup
        log_info "Full backup of Elasticsearch data completed"
    else
        log_info "Backup of Elasticsearch was not scheduled for this site. Exiting."
    fi
fi
