#!/bin/bash

readonly SNAPSHOT_NAME_PATH=/elasticsearch-backup/snapshot_name.txt
readonly SNAPSHOT_INDICES_PATH=/elasticsearch-backup/snapshot_indices.json
readonly SNAPSHOT_NAME=$(cat $SNAPSHOT_NAME_PATH 2>/dev/null)
readonly SNAPSHOT_INDICES=$(cat $SNAPSHOT_INDICES_PATH 2>/dev/null | jq -r '.[]')
readonly ADMIN_CERTIFICATE=/etc/elasticsearch/certs/admin.crt.pem
readonly ADMIN_KEY=/etc/elasticsearch/certs/admin.key.pem
readonly INDEX_SUFFIX='-2*.*.*'
readonly CURL_TEMPLATE="curl --insecure --silent --cert ${ADMIN_CERTIFICATE} --key ${ADMIN_KEY} -X %s https://$ELASTICSEARCH_SERVICE:$CLIENT_PORT/%s"

function log() {
    echo "$(date) ${*}"
}

function log_ne {
    echo -ne "$(date) ${*}"
}

function log_info_ne {
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
    log_info "Post restore of Elasticsearch finished with failure (script return code ${script_return_code})"
    exit ${script_return_code}
}

function display_config() (
    log_info "Elasticsearch client service name is  $ELASTICSEARCH_SERVICE"
    log_info "Elasticsearch client port is  $CLIENT_PORT"
    log_info "Elasticsearch snapshot name is  $SNAPSHOT_NAME"
    log_info "Snapshot indices: ${SNAPSHOT_INDICES[*]}"
)

function create_repo_if_not_exists() (
    log_info "Checking if repo already exists"
    printf -v get_repo_request "${CURL_TEMPLATE}" GET _cat/repositories
    get_repos_response=$(${get_repo_request})

    if [ -z "$get_repos_response" ]; then
        log_info "Repo doesn't exist - creating the new one"
        printf -v create_repo_request "${CURL_TEMPLATE}" PUT _snapshot/es_backup
        repo_dir_response=$(${create_repo_request} \
            -H 'Content-Type: application/json' -d'{ "type": "fs",  "settings": {"location": "backup" }}')
        log_info "Repo creation curl response $repo_dir_response"
        if [[ $(echo "$repo_dir_response" | jq -r | jq .error ) != null ]]; then
            log_error_and_exit "Repo creation failed"
        fi
    else
        log_info "Repo already exists"
    fi
)

function should_be_deleted_if_index_has_suffix() (
    index_from_snapshot=$1
    index=$2
    index_prefix=$3
    [[ ${index_from_snapshot} == ${index_prefix}${INDEX_SUFFIX} && ${index} == ${index_prefix}${INDEX_SUFFIX} ]] && return 0 || return 1
)

function should_be_deleted_if_index_has_not_suffix() (
    index_from_snapshot=$1
    index=$2
    index_prefix=$3
    [[ ${index_from_snapshot} != ${index_prefix}${INDEX_SUFFIX} && ${index} == "${index_prefix}" ]] && return 0 || return 1
)

function delete_index() (
    index_to_delete=$1
    log_info "Index to be deleted: $index_to_delete"
    printf -v delete_index_request "${CURL_TEMPLATE}" DELETE "${index_to_delete}"
    delete_response=$(${delete_index_request})
    log_info "Delete index result is $delete_response"
    if [[ $(echo "$delete_response" | jq -r | jq .error ) != null ]]; then
        log_error_and_exit "Delete index $index_to_delete failed"
    fi
)

function remove_snapshot_indices() (
    printf -v get_indices_request "${CURL_TEMPLATE}" GET _cat/indices?h=index
    readarray -t current_indices < <(${get_indices_request})
    indices_to_delete=()
    for index_from_snapshot in ${SNAPSHOT_INDICES[*]}; do
        index_prefix=${index_from_snapshot%$INDEX_SUFFIX}
        for index in ${current_indices[*]}; do
            if should_be_deleted_if_index_has_suffix "${index_from_snapshot}" "${index}" "${index_prefix}" ||
               should_be_deleted_if_index_has_not_suffix "${index_from_snapshot}" "${index}" "${index_prefix}"; then
                if [[ ! " ${indices_to_delete[*]} " =~ " ${index} " ]]; then
                    indices_to_delete+=("${index}")
                    delete_index "${index}"
                fi
            fi
        done
    done
)

function restore_snapshot() {
    log_info "Restore of Elasticsearch data has started"
    restore_output=$(mktemp)
    printf -v restore_snapshot_request "${CURL_TEMPLATE}" POST _snapshot/es_backup/"${SNAPSHOT_NAME}"/_restore?wait_for_completion=true
    log_info_ne "Snapshot restore in progress"
    ${restore_snapshot_request} \
        -H 'Content-Type: application/json' \
        -d' { "indices": "*,-searchguard,-.signals*", "ignore_unavailable": true,"include_global_state": true }' > ${restore_output} &
    pid=$(echo $!)
    ps $pid > /dev/null
    while [[ $? == 0 ]]; do
      echo -ne "."
      sleep 30
      ps $pid > /dev/null
    done
    echo ""
    snapshot_restore_response=$(cat ${restore_output})
    log_info "Restore of Elasticsearch data finished. Snapshot restore result is $snapshot_restore_response"
    if [[ $(echo "$snapshot_restore_response" | jq -r | jq .error ) != null ]]; then
        log_error_and_exit "Snapshot restore failed"
    fi
}

if [[ $NODE_NAME == *"data-0"* ]]; then

    if ! [[ -f ${SNAPSHOT_NAME_PATH} && -f ${SNAPSHOT_INDICES_PATH} ]]; then
        log_error_and_exit "Files snapshot_name.txt or snapshot_indices.json not found. Restore can't be started"
    fi

    log_info "Post restore of Elasticsearch data started"

    display_config
    create_repo_if_not_exists
    remove_snapshot_indices
    restore_snapshot

    log_info "Post restore of Elasticsearch data completed"
fi
