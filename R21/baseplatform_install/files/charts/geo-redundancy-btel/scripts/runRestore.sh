#!/bin/bash

readonly ELASTICSEARCH_BACKUP_PATH=${BACKUPS_PATH}
readonly METADATA_PATH=${RESTORE_METADATA_PATH}
readonly NIAM_RESTORE_SCRIPT_PATH=${RESTORE_SCRIPT_PATH}
readonly BACKUP_FILENAME="snapshot_name.txt"
readonly SUCCESS=0

function log() {
    echo "$(date) ${*}"
}

function log_info() {
    log INFO "${*}"
}

function log_error() {
    log ERROR "${*}"
}

function log_error_and_exit() {
    local error_exit_code=1
    log_error "${*}"
    log_info "Post restore of Elasticsearch finished with failure (script return code ${error_exit_code})"
    exit ${error_exit_code}
}

function run_restore() {
    ."${NIAM_RESTORE_SCRIPT_PATH}"
}

function change_snapshot_name_file_in_metadata_directory() {
    rm -f "${METADATA_PATH}/${BACKUP_FILENAME}"
    cp "${ELASTICSEARCH_BACKUP_PATH}/${BACKUP_FILENAME}" "${METADATA_PATH}/${BACKUP_FILENAME}"
    if [ $? -eq $SUCCESS ]; then
        log_info "Correctly changed metadata data for restore."
    else
        log_error "Could not properly copy metadata file to ${METADATA_PATH} path."
    fi
}

function run_restore_if_there_is_new_backup() {
    if [[ -f "${ELASTICSEARCH_BACKUP_PATH}/${BACKUP_FILENAME}" ]]; then
        if cmp -s "${ELASTICSEARCH_BACKUP_PATH}/${BACKUP_FILENAME}" "${METADATA_PATH}/${BACKUP_FILENAME}"; then
            log_info "Backup was already restored. Waiting for a newer one. Exiting."
        else
            log_info "Found newer backup on server. Starting restore procedure."
            if run_restore; then
                change_snapshot_name_file_in_metadata_directory
            else
                log_error_and_exit "Restore failed. Metadata has not been changed, will try to restore on next schedule."
            fi
        fi
    else
        log_info "snapshot_name.txt file is missing in backup directory. Restore can't be executed. Waiting for a first backup."
    fi
}

run_restore_if_there_is_new_backup
