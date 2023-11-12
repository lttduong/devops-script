#!/usr/bin/env bash

readonly SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"

readonly VALUES_TMP_FILE_TPL="/tmp/values-XXXXXXXX.yaml"
readonly DEFAULT_BP_NAMESPACE="netguard-base"
readonly INPUT_PARAM_ERROR_CODE=1
readonly APP_ERROR_CODE=2
readonly ACTIVE_MODE="active"
readonly PASSIVE_MODE="passive"
readonly MODE_POSSIBLE_VALUES="${ACTIVE_MODE}|${PASSIVE_MODE}"
readonly CBUR_LOCAL_BACKEND="local"
readonly HELM_UPGRADE_TIMEOUT=900

readonly CKEY_RELEASE="ckey"
readonly BTEL_RELEASE="btel"
readonly CMDB_RELEASE="cmdb"
readonly CKEY_CONFIGURATOR_CONFIG_RELEASE="ckey-configurator-config"
readonly CMDB_CONFIGURATOR_CONFIG_RELEASE="cmdb-configurator-config"
readonly GEO_REDUNDANCY_BTEL_RELEASE="geo-redundancy-btel"
readonly GEO_REDUNDANCY_RELEASE="geo-redundancy-settings"
readonly GEO_REDUNDANCY_CONFIGMAP="geo-redundancy-site-settings"
readonly GRAFANA_CONFIG_RELEASE="btel-grafana-config"

readonly BTEL_CHARTS_DIR=${SCRIPT_DIR}/../charts/btel/app
readonly CKEY_CHARTS_DIR=${SCRIPT_DIR}/../charts/ckey/app
readonly GEO_REDUNDANCY_BTEL_CHARTS_DIR=${SCRIPT_DIR}/../charts/geo-redundancy-btel
readonly CMDB_CHARTS_DIR=${SCRIPT_DIR}/../charts/cmdb/app
readonly CKEY_CONFIGURATOR_CONFIG_CHARTS_DIR=${SCRIPT_DIR}/../charts/ckey/configurator-config
readonly CMDB_CONFIGURATOR_CONFIG_CHARTS_DIR=${SCRIPT_DIR}/../charts/cmdb/configurator-config
readonly GEO_REDUNDANCY_CHARTS_DIR=${SCRIPT_DIR}/../charts/geo-redundancy-settings
readonly GRAFANA_CONFIG_CHARTS_DIR=${SCRIPT_DIR}/../charts/btel/grafana-config

readonly CKEY_REPLICAS=2
readonly GRAFANA_REPLICAS=2
readonly CALM_REPLICAS=1

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

function switch_btel_mode() {
    local mode=$1

    local grafana_replicas=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "${GRAFANA_REPLICAS}" || echo "0")
    local calm_replicas=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "${CALM_REPLICAS}" || echo "0")
    local grafana_data_mgmt_enabled=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")
    local btel_backup_cronjob_enabled=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")
    local values_file=$(mktemp ${VALUES_TMP_FILE_TPL})

    trap "rm ${values_file}" RETURN EXIT

    # Values for umbrella charts need to be redefined and provided for upgrade as helm omits subcharts values
    # during upgrade operation and use defaults instead (https://github.com/helm/helm/issues/2948).
    # After switch to helm3 it should work properly.
    helm get values "${BTEL_RELEASE}" > "${values_file}" || \
        log_error_and_exit "Unable to get helm values for ${BTEL_RELEASE} release"

    log_info "Switching ${BTEL_RELEASE} release to ${mode} mode"

    helm upgrade "${BTEL_RELEASE}" "${BTEL_CHARTS_DIR}" \
        --no-hooks \
        --values "${values_file}" \
        --set grafana.replicas="${grafana_replicas}" \
        --set grafana.SetDashboard.enabled="${grafana_data_mgmt_enabled}" \
        --set grafana.SetDatasource.enabled="${grafana_data_mgmt_enabled}" \
        --set calm.servers="${calm_replicas}" \
        --set belk.belk-elasticsearch.cbur.autoEnableCron="${btel_backup_cronjob_enabled}" \
        --set belk.belk-elasticsearch.cbur.autoUpdateCron="true" \
        --force \
        --timeout ${HELM_UPGRADE_TIMEOUT} \
        --wait || \
        log_error_and_exit "helm upgrade of ${BTEL_RELEASE} release failed"

    trap - RETURN EXIT

    log_info "Release ${BTEL_RELEASE} switched successfully to ${mode} mode"
}

function switch_grafana_config_mode() {
    local mode=$1

    local set_dashboard_enabled=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")
    local post_delete_job=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "enable" || echo "disable")

    log_info "Switching ${GRAFANA_CONFIG_RELEASE} release to ${mode} mode"

    helm upgrade "${GRAFANA_CONFIG_RELEASE}" "${GRAFANA_CONFIG_CHARTS_DIR}" \
        --no-hooks \
        --reuse-values \
        --set SetDashboard.enabled=${set_dashboard_enabled} \
        --set hooks.postDeleteJob=${post_delete_job} \
        --timeout ${HELM_UPGRADE_TIMEOUT} \
        --wait || \
        log_error_and_exit "helm upgrade of ${GRAFANA_CONFIG_RELEASE} release failed"

    log_info "Release ${GRAFANA_CONFIG_RELEASE} switched successfully to ${mode} mode"
}

function switch_ckey_mode() {
    local mode=$1

    local ckey_replicas=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "${CKEY_REPLICAS}" || echo "0")
    local values_file=$(mktemp ${VALUES_TMP_FILE_TPL})
    local backup_cronjob_enabled=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")

    trap "rm ${values_file}" RETURN EXIT

    # Values for umbrella charts need to be redefined and provided for upgrade as helm omits subcharts values
    # during upgrade operation and use defaults instead (https://github.com/helm/helm/issues/2948).
    # After switch to helm3 it should work properly.
    helm get values "${CKEY_RELEASE}" > "${values_file}" || \
        log_error_and_exit "Unable to get helm values for ${CKEY_RELEASE} release"

    log_info "Switching ${CKEY_RELEASE} release to ${mode} mode"
    helm upgrade "${CKEY_RELEASE}" "${CKEY_CHARTS_DIR}" \
        --no-hooks \
        --values "${values_file}" \
        --set replicaCount="${ckey_replicas}" \
        --set cbur.autoEnableCron="${backup_cronjob_enabled}" \
        --set cbur.autoUpdateCron="true" \
        --timeout ${HELM_UPGRADE_TIMEOUT} \
        --wait || \
        log_error_and_exit "helm upgrade of ${CKEY_RELEASE} release failed"

    trap - RETURN EXIT

    log_info "Release ${CKEY_RELEASE} switched successfully to ${mode} mode"
}

function switch_cbur_cronjob() {
    local mode=$1
    local release=$2
    local charts_path=$3

    local backup_cronjob_enabled=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")

    log_info "Switching ${release} cbur cronjob to ${backup_cronjob_enabled} for ${mode} mode"

    helm upgrade "${release}" "${charts_path}" \
        --reuse-values \
        --set cbur.autoEnableCron="${backup_cronjob_enabled}" \
        --set cbur.autoUpdateCron="true" \
        --timeout ${HELM_UPGRADE_TIMEOUT} \
        --wait || \
        log_error_and_exit "helm upgrade of ${release} cbur cronjob failed"

    log_info "${release} cbur cronjob successfully switch to ${backup_cronjob_enabled} for ${mode} mode"
}

function switch_cmdb_cbur_cronjob() {
    local mode=$1
    switch_cbur_cronjob "${mode}" ${CMDB_RELEASE} ${CMDB_CHARTS_DIR}
}

function switch_cmdb_configurator_config_cbur_cronjob() {
    local mode=$1
    switch_cbur_cronjob "${mode}" ${CMDB_CONFIGURATOR_CONFIG_RELEASE} ${CMDB_CONFIGURATOR_CONFIG_CHARTS_DIR}
}

function switch_ckey_configurator_config_cbur_cronjob() {
    local mode=$1
    switch_cbur_cronjob "${mode}" ${CKEY_CONFIGURATOR_CONFIG_RELEASE} ${CKEY_CONFIGURATOR_CONFIG_CHARTS_DIR}
}

function switch_cbur_cronjobs() {
    local mode=$1
    switch_cmdb_cbur_cronjob "${mode}"
    switch_cmdb_configurator_config_cbur_cronjob "${mode}"
    switch_ckey_configurator_config_cbur_cronjob "${mode}"
}

function switch_geo_redundancy_btel() {
  local mode=$1
  local is_geo_redundancy_btel_suspended=$([[ "${mode}" == "${ACTIVE_MODE}" ]] && echo "true" || echo "false")

  log_info "Switching ${GEO_REDUNDANCY_BTEL_RELEASE} release to ${mode} mode"

  helm upgrade "${GEO_REDUNDANCY_BTEL_RELEASE}" "${GEO_REDUNDANCY_BTEL_CHARTS_DIR}" \
      --reuse-values \
      --set cronjob.suspended="${is_geo_redundancy_btel_suspended}" \
      --force \
      --timeout ${HELM_UPGRADE_TIMEOUT} \
      --wait || \
      log_error_and_exit "helm upgrade of ${GEO_REDUNDANCY_BTEL_RELEASE} release failed"

    trap - RETURN EXIT

    log_info "Release ${GEO_REDUNDANCY_BTEL_RELEASE} switched successfully to ${mode} mode"
}

function update_geo_redundancy_settings() {
    local mode=$1

    log_info "Updating geo-redundancy settings"

    helm upgrade "${GEO_REDUNDANCY_RELEASE}" "${GEO_REDUNDANCY_CHARTS_DIR}" \
        --reuse-values \
        --set geo_redundancy.mode="${mode}" \
        --timeout ${HELM_UPGRADE_TIMEOUT} \
        --wait || \
        log_error_and_exit "helm upgrade of ${GEO_REDUNDANCY_RELEASE} release failed"

    log_info "Gro-redundancy settings updated successfully"
}

function switch_mode() {
    local mode=$1

    log_info "Switching Base Platform to ${mode} mode"

    switch_btel_mode "${mode}"
    switch_grafana_config_mode "${mode}"
    switch_ckey_mode "${mode}"
    switch_geo_redundancy_btel "${mode}"
    switch_cbur_cronjobs "${mode}"
    update_geo_redundancy_settings "${mode}"

    log_info "Base Platform switched successfully to ${mode} mode"
}

function validate_parameters {
    if [ -z "${BP_NAMESPACE}" ]; then
        log_info "--bp-namespace param not set - setting default ${DEFAULT_BP_NAMESPACE}"
        BP_NAMESPACE=${DEFAULT_BP_NAMESPACE}
    fi

    if [ -z "${MODE}" ]; then
        display_help
        log_error_and_exit "--mode option not set."
    fi

    if ! [[ ${MODE} =~ ^(${MODE_POSSIBLE_VALUES})$ ]]; then
        display_help
        log_error_and_exit "Invalid value of --mode option. Possible values: ${MODE_POSSIBLE_VALUES}"
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
        --mode=*)
        MODE="${i#*=}"
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
    echo "  --mode Geo redundancy mode the site should be switched to. Possible values: active|passive"
    echo "  --bp-namespace The same as provided in Base Platform installation (default: ${DEFAULT_BP_NAMESPACE})"
    echo "Example: $0 --bp-namespace=netguard-base --mode=active"
}

function main {
    parse_input_parameters "${@}"
    validate_parameters
    switch_mode "${MODE}"
}

main "${@}"
