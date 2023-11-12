#!/bin/bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly PROJECT_NAME="NetGuard_Base_Platform"
readonly CHARTS_PROJECT_NAME="${PROJECT_NAME}-Charts"
readonly DEFAULT_WORK_DIR="/tmp"
readonly DEFAULT_RELEASE_PREFIX="nbp-"
readonly DEFAULT_RELEASE_VERSION='21.2.0'
readonly DEFAULT_HELM_PATH=helm3
readonly DEFAULT_KUBECTL_PATH=kubectl
readonly INSTALL_ACTION=install
readonly UNINSTALL_ACTION=uninstall
readonly AUDIT_UNINSTALL_ACTION=audit
readonly UPGRADE_ACTION=upgrade
readonly ROLLBACK_ACTION=rollback
readonly ACTION_POSSIBLE_VALUES="${INSTALL_ACTION}|${UNINSTALL_ACTION}|${AUDIT_UNINSTALL_ACTION}|${UPGRADE_ACTION}|${ROLLBACK_ACTION}"
readonly COMMON_VALUES="common"
readonly YAML="yaml"
readonly DEFAULT_INSTALLATION_TIMEOUT=1800
readonly DEFAULT_UNINSTALLATION_TIMEOUT=900
readonly DEFAULT_UPGRADE_TIMEOUT=1800
readonly DEFAULT_ROLLBACK_TIMEOUT=1800
readonly DEFAULT_AUDIT_TIMEOUT=200
readonly HELM_FAILED_RELEASE_STATUS="failed"
readonly HELM_SUPERSEDED_RELEASE_STATUS="superseded"
readonly HELM_DEPLOYED_RELEASE_STATUS="deployed"
readonly RESOURCE_PROFILES_DIR="resource-profiles"
readonly UPGRADE_DIR="upgrade"
readonly DEFAULT_TIMEOUT=1800

RELEASE_FAILED=false
ERRORS=false
cbur_enabled=true
shared_belk=true

function log_info {
    log "INFO" "${1}"
}

function log_warning {
    log "WARNING" "${1}" >&2
}

function log_error {
    log "ERROR" "${1}" >&2
    ERRORS=true
}

function log_debug {
    log "DEBUG" "${1}" >&2
}

function log {
    local time_format="%Y-%m-%d %H:%M:%S.%3N"
    local log_severity="${1}"
    local log_msg="${2}"
    if [ "${log_severity}" = ERROR ]; then
        echo -e "\e[31m`date +"${time_format}"` | ${log_severity} | ${2}\e[0m"
    elif [ "${log_severity}" = WARNING ]; then
        echo -e "\e[33m`date +"${time_format}"` | ${log_severity} | ${2}\e[0m"
    elif [ "${log_severity}" = INFO ]; then
        echo -e "\e[36m`date +"${time_format}"` | ${log_severity} | ${2}\e[0m"
    elif [ "${log_severity}" = DEBUG ]; then
        echo -e "\e[35m`date +"${time_format}"` | ${log_severity} | ${2}\e[0m"
    else
        echo -e "`date +"${time_format}"` | ${log_severity} | ${2}"
    fi
}

function log_error_and_exit {
    log_error "${1}"
    ERRORS=true
    exit 1
}

function helm_cmd {
    ${HELM_PATH} "$@"
}

function kubectl_cmd {
    ${KUBECTL_PATH} "$@"
}

function prepare_tmp_charts_dir {
    tmp_charts_package_dir=$(mktemp -d ${WORK_DIR}/install-charts.XXXXXXX)

    log_info "Untar charts ${CHARTS_PACKAGE} to ${tmp_charts_package_dir}"
    tar -xf ${CHARTS_PACKAGE} -C ${tmp_charts_package_dir} || log_error_and_exit "Failed to untar charts package"
}

function prepare_tmp_values_dir {
    tmp_values_package_dir=$(mktemp -d ${WORK_DIR}/install-values.XXXXXXX)

    log_info "Untar values ${VALUES_PACKAGE} to ${tmp_values_package_dir}"
    tar -xf ${VALUES_PACKAGE} -C ${tmp_values_package_dir} || log_error_and_exit "Failed to untar values package"
}

function read_config_vars {
    local config_vars_path=${tmp_values_package_dir}/bp_config_vars.yaml

    readonly bp_namespace=$(cat ${config_vars_path} | grep BP_NAMESPACE: | awk {'print $2'})
    readonly config_namespace=$(cat ${config_vars_path} | grep BP_CONFIG_NAMESPACE: | awk {'print $2'})
    readonly version=$(cat ${config_vars_path} | grep -w VERSION: | awk {'print $2'})
    readonly bp_release_name_prefix=$(cat ${config_vars_path} | grep BP_RELEASE_NAME_PREFIX: | awk {'print $2'})
    cbur_enabled=$(cat ${config_vars_path} | grep BP_BR_ENABLED: | awk {'print $2'})
    cbur_install=$(cat ${config_vars_path} | grep CBUR_INSTALL: | awk {'print $2'})
    readonly shared_belk=$(cat ${config_vars_path} | grep INSTALL_SHARED_BELK: | awk {'print $2'})
    readonly resource_profile=$(cat ${config_vars_path} | grep BP_DEPLOYMENT_PROFILE_RESOURCES: | awk {'print $2'})
}

function get_current_release_version {
    local prefixed_helm_release_name=$1
    local namespace=$2

    helm_cmd history -n ${namespace} ${prefixed_helm_release_name} | awk -F'\t' 'BEGIN { OFS = FS } END { print $5 }' | xargs
}

function get_current_release_status {
    local prefixed_helm_release_name=$1
    local namespace=$2

    helm_cmd history -n ${namespace} ${prefixed_helm_release_name} | awk -F'\t' 'BEGIN { OFS = FS } END { print $3 }' | xargs
}

function get_highest_non_failed_helm_revision_for_release_version {
    local prefixed_helm_release_name=$1
    local namespace=$2

    helm_cmd history \
    -n ${namespace} \
    ${prefixed_helm_release_name} | \
    awk -F'\t' 'BEGIN { OFS = FS } { print $1 "\t" $3 "\t" $5}' | \
    grep "${RELEASE_VERSION}" | \
    grep "${HELM_SUPERSEDED_RELEASE_STATUS}\|${HELM_DEPLOYED_RELEASE_STATUS}" | \
    awk -F'\t' 'BEGIN { OFS = FS; max_number = 0 } { number = $1; if (number > max_number) max_number = number; } END { print max_number }' | \
    xargs
}

function install_application {
    local chart_name=$1
    local helm_release_name=$2
    local namespace=$3
    local prefixed_helm_release_name=${bp_release_name_prefix}${helm_release_name}
    local charts_path=${tmp_charts_package_dir}/NetGuard_Base_Platform-Charts/charts

    local release_values_file=${tmp_values_package_dir}/values/${helm_release_name}.${YAML}
    local resource_profile_file=${tmp_values_package_dir}/${RESOURCE_PROFILES_DIR}/${resource_profile}/${helm_release_name}.${YAML}

    local release_values_param=""
    [[ -f "${release_values_file}" ]] && release_values_param+=" --values ${release_values_file}"
    release_values_param+=" --values ${tmp_values_package_dir}/${COMMON_VALUES}.${YAML}"
    [[ -f "${resource_profile_file}" ]] && release_values_param+=" --values ${resource_profile_file}"

    log_info "Install application ${prefixed_helm_release_name} in ${namespace}"
    ls ${tmp_values_package_dir}/values/${helm_release_name}.${YAML}

    log_debug "Command=> helm install \
                ${prefixed_helm_release_name} ${tmp_charts_package_dir}/NetGuard_Base_Platform-Charts/charts/${chart_name} \
                ${release_values_param} \
                --namespace ${namespace} \
                --wait --timeout ${TIMEOUT}s"

    tar -xf ${charts_path}/${chart_name}-${version}.tgz --directory ${charts_path}/

    helm_cmd install ${prefixed_helm_release_name} \
                ${charts_path}/${chart_name} \
                ${release_values_param} \
                --namespace ${namespace} \
                --wait --timeout "${TIMEOUT}s" || log_error_and_exit "Failed to install ${prefixed_helm_release_name}"
}

function install_application_in_background {
    local chart_name=$1
    local helm_release_name=$2
    local namespace=$3
    local pid=0

    install_application ${chart_name} ${helm_release_name} ${namespace} &
    pid="$!"
    if [[ ( ${pid} != 0 ) && ( ${pid} != "" ) ]]; then pids+=(${pid}); else exit 1; fi
}

function upgrade_application {
    local chart_name=$1
    local release_name=${2:-${chart_name}}
    local namespace=$3
    local disable_hooks=${4:-"false"}

    local prefixed_helm_release_name=${bp_release_name_prefix}${release_name}
    local prefixed_chart_package_name=${chart_name}
    local chart_path=${tmp_charts_package_dir}/NetGuard_Base_Platform-Charts/charts/${prefixed_chart_package_name}-${version}.tgz

    local release_values_file=${tmp_values_package_dir}/values/${release_name}.${YAML}
    local resource_profile_file=${tmp_values_package_dir}/${RESOURCE_PROFILES_DIR}/${resource_profile}/${release_name}.${YAML}
    local upgrade_file=${tmp_values_package_dir}/${UPGRADE_DIR}/${release_name}.${YAML}

    local current_release_version=$(get_current_release_version ${prefixed_helm_release_name} ${namespace})

    local release_values_param=""
    [[ -f "${release_values_file}" ]] && release_values_param+=" --values ${release_values_file}"
    release_values_param+=" --values ${tmp_values_package_dir}/${COMMON_VALUES}.${YAML}"
    [[ -f "${resource_profile_file}" ]] && release_values_param+=" --values ${resource_profile_file}"
    [[ -f "${upgrade_file}" ]] && release_values_param+=" --values ${upgrade_file}"
    local disable_hooks_param=""
    [[ "${disable_hooks}" == "true" ]] && disable_hooks_param+=" --no-hooks"

    log_info "Upgrade application ${prefixed_helm_release_name} version ${current_release_version} in ${namespace}"

    helm_cmd upgrade ${prefixed_helm_release_name} ${chart_path} \
        --namespace ${namespace} \
        --wait --install\
        --wait-for-jobs \
        --timeout "${TIMEOUT}s" \
        ${release_values_param} \
        --description "Upgrade to version $(echo ${version} | awk -F "." {'print $1'}) complete" \
        ${disable_hooks_param} \
        && log_info "Application ${prefixed_helm_release_name} has been successfully upgraded to version $(get_current_release_version ${prefixed_helm_release_name} ${namespace})" \
        || log_error_and_exit "Failed to upgrade ${prefixed_helm_release_name}"
}

function upgrade_application_in_background {
    local chart_name=$1
    local release_name=${2:-${chart_name}}
    local namespace=$3
    local disable_hooks=${4:-"false"}
    local pid=0

    upgrade_application ${chart_name} ${release_name} ${namespace} "${disable_hooks}" &
    pid="$!"
    if [[ ( ${pid} != 0 ) && ( ${pid} != "" ) ]]; then pids+=(${pid}); else exit 1; fi
}

function rollback_application {
    local chart_name=$1
    local release_name=${2:-${chart_name}}
    local namespace=$3
    local uninstall=${4:-false}
    local prefixed_helm_release_name=${RELEASE_PREFIX}${release_name}
    local current_release_version=$(get_current_release_version ${prefixed_helm_release_name} ${namespace})
    local current_release_status=$(get_current_release_status ${prefixed_helm_release_name} ${namespace})

    if [[ ${current_release_version} != ${RELEASE_VERSION} || ${current_release_status} == ${HELM_FAILED_RELEASE_STATUS} ]]; then
        helm_revision=$(get_highest_non_failed_helm_revision_for_release_version ${prefixed_helm_release_name} ${namespace})
        if [[ ! -z ${helm_revision} ]] && (( ${helm_revision} > 0 )); then
            log_info "Rollback application ${prefixed_helm_release_name} to version ${RELEASE_VERSION} (number of helm revision: ${helm_revision})"
            helm_cmd rollback -n ${namespace} ${prefixed_helm_release_name} ${helm_revision} \
            --recreate-pods \
            --timeout "${TIMEOUT}s" \
            --wait \
            --wait-for-jobs \
            && log_info "Application ${prefixed_helm_release_name} has been successfully roll-backed to version ${RELEASE_VERSION}" \
            || log_error_and_exit "Failed to rollback ${prefixed_helm_release_name}"

        else
            log_error "Cannot rollback application ${prefixed_helm_release_name}. Cannot find helm revision for release version ${RELEASE_VERSION}"
            if [[ "${uninstall}" == true ]]; then
                uninstall_application ${release_name} ${namespace}
            fi
        fi
    else
        log_info "Skipping rollback application ${prefixed_helm_release_name}. Current release version is requested non-failed version."
    fi
}

function rollback_application_in_background {
    local chart_name=$1
    local release_name=${2:-${chart_name}}
    local namespace=$3
    local pid=0

    rollback_application ${chart_name} ${release_name} ${namespace} &
    pid="$!"
    if [[ ( ${pid} != 0 ) && ( ${pid} != "" ) ]]; then pids+=(${pid}); else exit 1; fi
}

function rollback_cmdb {
    prepare_tmp_charts_dir

    local chart_name=$1
    local release_name=${2:-${chart_name}}
    local namespace=$3
    local prefixed_helm_release_name=${RELEASE_PREFIX}${release_name}
    local current_release_version=$(get_current_release_version ${prefixed_helm_release_name} ${namespace})
    local current_release_status=$(get_current_release_status ${prefixed_helm_release_name} ${namespace})
    local charts_path=${tmp_charts_package_dir}/NetGuard_Base_Platform-Charts/charts

    if [[ ${current_release_version} != ${RELEASE_VERSION} || ${current_release_status} == ${HELM_FAILED_RELEASE_STATUS} ]]; then
        helm_revision=$(get_highest_non_failed_helm_revision_for_release_version ${prefixed_helm_release_name} ${namespace})
        log_info "Reinstallation ${prefixed_helm_release_name} version ${RELEASE_VERSION}"
        bash -c -- "${HELM_PATH} get values -n ${namespace} ${prefixed_helm_release_name} --revision ${helm_revision} -o yaml" > cmdb-rollback-values-${RELEASE_VERSION}.yaml
        helm_cmd delete -n ${namespace} ${prefixed_helm_release_name}

        helm_cmd install -n ${namespace} ${prefixed_helm_release_name} ${charts_path}/${chart_name}-${RELEASE_VERSION}*.tgz \
        -f cmdb-rollback-values-${RELEASE_VERSION}.yaml \
        --timeout "${TIMEOUT}s" \
        --wait \
        --wait-for-jobs \
        && log_info "Application ${prefixed_helm_release_name} has been successfully roll-backed to version ${RELEASE_VERSION}" \
        || log_error_and_exit "Failed to rollback ${prefixed_helm_release_name}"
    else
        log_info "Skipping rollback application ${prefixed_helm_release_name}. Current release version is requested non-failed version."
    fi
}

function check_for_installed_apps {
    BP_RELEASES=( ${RELEASE_PREFIX}"geo-redundancy-validation-mariadb" ${RELEASE_PREFIX}"geo-redundancy-validation-maxscale" ${RELEASE_PREFIX}"geo-redundancy-validation-repl" ${RELEASE_PREFIX}"geo-redundancy-validation-keycloak" ${RELEASE_PREFIX}"geo-redundancy-settings" ${RELEASE_PREFIX}"start-page" ${RELEASE_PREFIX}"crmq-configurator-config" ${RELEASE_PREFIX}"crmq" ${RELEASE_PREFIX}"cmdb-configurator-config" ${RELEASE_PREFIX}"cmdb" ${RELEASE_PREFIX}"cmdb-db-config" ${RELEASE_PREFIX}"ckey-db-config" ${RELEASE_PREFIX}"ckey" ${RELEASE_PREFIX}"ckey-configurator-config" ${RELEASE_PREFIX}"ckey-crmq-config" ${RELEASE_PREFIX}"ckey-master-config" ${RELEASE_PREFIX}"ckey-netguard-config" ${RELEASE_PREFIX}"citm" ${RELEASE_PREFIX}"virtual-ip" ${RELEASE_PREFIX}"cbur" ${RELEASE_PREFIX}"cbur-crds" ${RELEASE_PREFIX}"shared-elasticsearch" ${RELEASE_PREFIX}"shared-kibana" ${RELEASE_PREFIX}"shared-curator" ${RELEASE_PREFIX}"ckey-shared-belk-config" ${RELEASE_PREFIX}"geo-redundancy-shared-elastic" ${RELEASE_PREFIX}"shared-elastic-config")
	APPLICATION_DETECTED=false

    log_info "Checking for BTEL and product applications..."

	if [[ ${BP_NAMESPACE} = ${CONFIG_NAMESPACE} ]]; then
		DEPLOYED_RELEASES=($( helm_cmd list -aq -n ${BP_NAMESPACE} ))
	else
		BP_NAMESPACE_RELEASES=($( helm_cmd list -aq -n ${BP_NAMESPACE} ))
		CONFIG_NAMESPACE_RELEASES=($( helm_cmd list -aq -n ${CONFIG_NAMESPACE} ))
		DEPLOYED_RELEASES=(${BP_NAMESPACE_RELEASES[@]} ${CONFIG_NAMESPACE_RELEASES[@]})
	fi

	for release in ${DEPLOYED_RELEASES[@]}
	do
        if [[ ! " ${BP_RELEASES[@]} " =~ " ${release} " ]]; then
            echo -e "\e[31mnon-core BP release ${release} detected...\e[0m"
			APPLICATION_DETECTED=true
        fi
	done

    if [ ${APPLICATION_DETECTED} = true ]; then
        log_error_and_exit "BTEL or one or more product applications were detected. Please uninstall BTEL/product applications before uninstalling BP"
    else
        echo -e "\e[32mNo applications detected\e[0m"
    fi
}

function uninstall_application {
    local helm_release_name=$1
    local namespace=$2
    local prefixed_helm_release_name=${RELEASE_PREFIX}${helm_release_name}

    log_info "Checking application ${prefixed_helm_release_name} in ${namespace}"
    status=$(helm_cmd status ${prefixed_helm_release_name} --namespace ${namespace} -o json  | jq ".info.status")

    if [[ ! -z ${status} ]]; then
      log_info "Uninstall application ${prefixed_helm_release_name} in ${namespace}"
      helm_cmd uninstall ${prefixed_helm_release_name} --namespace ${namespace} --timeout "${TIMEOUT}s" ||
          log_error "Failed to uninstall ${prefixed_helm_release_name}"
    else
      log_info "Application ${prefixed_helm_release_name} is missing from ${namespace}, skipped"
    fi
}

function audit_uninstall {
    if [ "${RELEASE_PREFIX}" == "" ]; then
        log_info "Audit skipped because --release-prefix is set to empty"
    else
        echo -e "\e[32m===================== Performing a post delete audit ======================\e[0m"
        echo -e "\e[32mServiceAccounts:\e[0m"
        kubectl_cmd get serviceaccounts -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mRoleBindings:\e[0m"
        kubectl_cmd get rolebindings -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mRoles:\e[0m"
        kubectl_cmd get roles -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mCronJobs:\e[0m"
        kubectl_cmd get cronjobs -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mJobs:\e[0m"
        kubectl_cmd get jobs -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX}| awk '{print $1}'
        echo -e "\e[32mDeployments:\e[0m"
        kubectl_cmd get deployments -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mStatefulSets:\e[0m"
        kubectl_cmd get statefulsets -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mDaemonSets:\e[0m"
        kubectl_cmd get daemonsets -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mPvcs:\e[0m"
        kubectl_cmd get pvc -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mServices:\e[0m"
        kubectl_cmd get services -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mIngress:\e[0m"
        kubectl_cmd get ingresses -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mCertificates:\e[0m"
        kubectl_cmd get certificates -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mConfigMaps:\e[0m"
        kubectl_cmd get configmaps -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mSecrets:\e[0m"
        kubectl_cmd get secrets -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mPods:\e[0m"
        kubectl_cmd get pods -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32mPvs:\e[0m"
        kubectl_cmd get pv -n ${BP_NAMESPACE} | egrep ${RELEASE_PREFIX} | awk '{print $1}'
        echo -e "\e[32m==================== Post delete audit complete =====================\e[0m"
     fi
}

function wait_for_finish {
    for pid in ${@}; do
        if ! wait $pid; then
            RELEASE_FAILED=true
        fi
    done
    if [ ${RELEASE_FAILED} == "true" ]; then
        log_error_and_exit "${ACTION} failed"
    fi
}

function install_bp {
    prepare_tmp_charts_dir
    prepare_tmp_values_dir
    read_config_vars

    log_info "Install BP ${version} "
    if [ "${cbur_install}" = true ]; then
    install_application "cbur" "cbur" ${bp_namespace}
    fi

    if [ "${cbur_enabled}" = true ]; then
    install_application "geo-redundancy-validation" "geo-redundancy-validation-mariadb" ${config_namespace}
    install_application "geo-redundancy-validation" "geo-redundancy-validation-maxscale" ${config_namespace}
    install_application "geo-redundancy-validation" "geo-redundancy-validation-repl" ${config_namespace}
    install_application "geo-redundancy-validation" "geo-redundancy-validation-keycloak" ${config_namespace}
    fi

    install_application_in_background "citm-server" "start-page" ${bp_namespace}
    install_application_in_background "crmq-configurator-config" "crmq-configurator-config" ${config_namespace}
    install_application_in_background "crmq" "crmq" ${bp_namespace}
    wait_for_finish ${pids[@]}
    pids=()

    install_application "cmdb-configurator-config" "cmdb-configurator-config" ${config_namespace}
    install_application "cmdb" "cmdb" ${bp_namespace}
    install_application "cmdb-db-config" "cmdb-db-config" ${config_namespace}
    install_application "ckey-db-config" "ckey-db-config" ${config_namespace}
    install_application "ckey" "ckey" ${bp_namespace}
    install_application "ckey-configurator-config" "ckey-configurator-config" ${config_namespace}
    install_application "ckey-crmq-config" "ckey-crmq-config" ${config_namespace}
    install_application "ckey-master-config" "ckey-master-config" ${config_namespace}
    install_application "ckey-netguard-config" "ckey-netguard-config" ${config_namespace}
    install_application "citm-ingress" "citm" ${bp_namespace}
    install_application "virtual-ip" "virtual-ip" ${bp_namespace}
    if [ "${cbur_enabled}" = true ]; then
       install_application "geo-redundancy-settings" "geo-redundancy-settings" ${bp_namespace}
    fi

    if [ "${shared_belk}" = true ]; then
       install_application "ckey-shared-belk-config" "ckey-shared-belk-config" ${bp_namespace} true
       install_application "belk-elasticsearch" "shared-elasticsearch" ${bp_namespace} true
       install_application "elastic-config" "shared-elastic-config" ${bp_namespace} true
       install_application "belk-curator" "shared-curator" ${bp_namespace} true
       install_application "belk-kibana" "shared-kibana" ${bp_namespace} true
       if [ "${cbur_enabled}" = true ]; then
          install_application "geo-redundancy-shared-elastic" "geo-redundancy-shared-elastic" ${bp_namespace} true
       fi
    fi

    echo -e "\e[32m"Install BP ${version} has been successful"\e[0m"
}

function uninstall_bp {
    log_info "Uninstall BP application"
    check_for_installed_apps

    uninstall_application "geo-redundancy-shared-elastic" ${BP_NAMESPACE}
    uninstall_application "shared-kibana" ${BP_NAMESPACE}
    uninstall_application "shared-curator" ${BP_NAMESPACE}
    uninstall_application "shared-elastic-config" ${BP_NAMESPACE}
    uninstall_application "shared-elasticsearch" ${BP_NAMESPACE}
    uninstall_application "ckey-shared-belk-config" ${BP_NAMESPACE}

    uninstall_application "geo-redundancy-settings" ${BP_NAMESPACE}
    uninstall_application "virtual-ip" ${BP_NAMESPACE}
    uninstall_application "citm" ${BP_NAMESPACE}
    uninstall_application "ckey-netguard-config" ${CONFIG_NAMESPACE}
    uninstall_application "ckey-master-config" ${CONFIG_NAMESPACE}
    uninstall_application "ckey-crmq-config" ${CONFIG_NAMESPACE}
    uninstall_application "ckey-configurator-config" ${CONFIG_NAMESPACE}
    uninstall_application "ckey" ${BP_NAMESPACE}
    uninstall_application "ckey-db-config" ${CONFIG_NAMESPACE}
    uninstall_application "cmdb-db-config" ${CONFIG_NAMESPACE}
    uninstall_application "cmdb" ${BP_NAMESPACE}
    uninstall_application "cmdb-configurator-config" ${CONFIG_NAMESPACE}
    uninstall_application "crmq" ${BP_NAMESPACE}
    uninstall_application "crmq-configurator-config" ${CONFIG_NAMESPACE}
    uninstall_application "start-page" ${BP_NAMESPACE}
    uninstall_application "geo-redundancy-validation-keycloak" ${CONFIG_NAMESPACE}
    uninstall_application "geo-redundancy-validation-repl" ${CONFIG_NAMESPACE}
    uninstall_application "geo-redundancy-validation-maxscale" ${CONFIG_NAMESPACE}
    uninstall_application "geo-redundancy-validation-mariadb" ${CONFIG_NAMESPACE}
    uninstall_application "cbur" ${BP_NAMESPACE}

    if (${ERRORS}); then
        echo -e "\e[31m"Errors were detected. Perform an audit and clean if necessary"\e[0m"
        exit 1
    fi

    log_info "Uninstall BP application has been successful"
}

function upgrade_bp {
    prepare_tmp_charts_dir
    prepare_tmp_values_dir
    read_config_vars

    log_info "Upgrade BP application to ${version}"

    if [ "${cbur_enabled}" = true ]; then
        upgrade_application "geo-redundancy-validation" "geo-redundancy-validation-mariadb" ${config_namespace}
        upgrade_application "geo-redundancy-validation" "geo-redundancy-validation-maxscale" ${config_namespace}
        upgrade_application "geo-redundancy-validation" "geo-redundancy-validation-repl" ${config_namespace}
        upgrade_application "geo-redundancy-validation" "geo-redundancy-validation-keycloak" ${config_namespace}
    fi

    upgrade_application_in_background "citm-server" "start-page" ${bp_namespace}
    upgrade_application_in_background "crmq-configurator-config" "crmq-configurator-config" ${config_namespace}
    upgrade_application_in_background "crmq" "crmq" ${bp_namespace}
    wait_for_finish ${pids[@]}
    pids=()

    upgrade_application "cmdb-configurator-config" "cmdb-configurator-config" ${config_namespace}
    upgrade_application "cmdb" "cmdb" ${bp_namespace}
    upgrade_application "cmdb-db-config" "cmdb-db-config" ${config_namespace}
    upgrade_application "ckey-db-config" "ckey-db-config" ${config_namespace}
    upgrade_application "ckey" "ckey" ${bp_namespace}
    upgrade_application "ckey-configurator-config" "ckey-configurator-config" ${config_namespace}
    upgrade_application "ckey-crmq-config" "ckey-crmq-config" ${config_namespace}
    upgrade_application "ckey-master-config" "ckey-master-config" ${config_namespace}
    upgrade_application "ckey-netguard-config" "ckey-netguard-config" ${config_namespace}
    upgrade_application "citm-ingress" "citm" ${bp_namespace}
    upgrade_application "virtual-ip" "virtual-ip" ${bp_namespace}
    if [ "${cbur_enabled}" = true ]; then
        upgrade_application "geo-redundancy-settings" "geo-redundancy-settings" ${bp_namespace}
    fi

    if [ "${shared_belk}" = true ]; then
       upgrade_application "ckey-shared-belk-config" "ckey-shared-belk-config" ${bp_namespace}
       upgrade_application "belk-elasticsearch" "shared-elasticsearch" ${bp_namespace}
       upgrade_application "elastic-config" "shared-elastic-config" ${bp_namespace}
       upgrade_application "belk-curator" "shared-curator" ${bp_namespace}
       upgrade_application "belk-kibana" "shared-kibana" ${bp_namespace}
       if [ "${cbur_enabled}" = true ]; then
          upgrade_application "geo-redundancy-shared-elastic" "geo-redundancy-shared-elastic" ${bp_namespace}
       fi
    fi

    log_info "Upgrade BP application has been successful"
}

function restore_cmdb {
    log_info "CMDB restore has started"
    ${SCRIPT_DIR}/geo-redundancy/mariadb_backup.sh --release-prefix=${RELEASE_PREFIX} --bp-namespace=${BP_NAMESPACE} --backup-file=${PREVIOUS_CMDB_BACKUP} --action=restore
    log_info "CMDB restore has successfully finished"
}

function scale_ckey_statefulset {

    sts=`kubectl_cmd get statefulset --namespace ${BP_NAMESPACE} ${RELEASE_PREFIX}ckey-ckey --ignore-not-found=true`

    if [[ ! -z ${sts} ]]; then
        log_info "Scaling statefulset for rollback"
        kubectl_cmd scale statefulset --namespace ${BP_NAMESPACE} ${RELEASE_PREFIX}ckey-ckey --replicas=1 --timeout=${DEFAULT_TIMEOUT}s
        log_info "Waiting for one replica to be ready"
        kubectl_cmd wait pod --for=condition=ready -l statefulset.kubernetes.io/pod-name=${RELEASE_PREFIX}ckey-ckey-0 --timeout=${DEFAULT_TIMEOUT}s
    fi
}

function remove_ckey_statefulset {
    log_info "Removing CKEY statefulset"
    kubectl_cmd delete statefulset --namespace ${BP_NAMESPACE} ${RELEASE_PREFIX}ckey-ckey --cascade=orphan --ignore-not-found=true
    log_info "Removing CKEY statefulset has finished"
}

function rollback_bp {
    log_info "Rollback BP application"

    rollback_application "geo-redundancy-settings" "geo-redundancy-settings" ${BP_NAMESPACE}

    if [ "${shared_belk}" = true ]; then
       if [ "${cbur_enabled}" = true ]; then
          rollback_application "geo-redundancy-shared-elastic" "geo-redundancy-shared-elastic" ${BP_NAMESPACE}
       fi
       rollback_application "belk-kibana" "shared-kibana" ${BP_NAMESPACE}
       rollback_application "belk-curator" "shared-curator" ${BP_NAMESPACE}
       rollback_application "elastic-config" "shared-elastic-config" ${BP_NAMESPACE}
       rollback_application "belk-elasticsearch" "shared-elasticsearch" ${BP_NAMESPACE}
       rollback_application "ckey-shared-belk-config" "ckey-shared-belk-config" ${BP_NAMESPACE}
    fi

    rollback_application "virtual-ip" "virtual-ip" ${BP_NAMESPACE}
    rollback_application "citm-ingress" "citm" ${BP_NAMESPACE}
    rollback_application "ckey-netguard-config" "ckey-netguard-config" ${CONFIG_NAMESPACE}
    rollback_application "ckey-master-config" "ckey-master-config" ${CONFIG_NAMESPACE}
    rollback_application "ckey-crmq-config" "ckey-crmq-config" ${CONFIG_NAMESPACE}
    rollback_application "ckey-configurator-config" "ckey-configurator-config" ${CONFIG_NAMESPACE}

    rollback_application "cmdb-db-config" "cmdb-db-config" ${CONFIG_NAMESPACE}
    rollback_cmdb "cmdb" "cmdb" ${BP_NAMESPACE}
    restore_cmdb

    rollback_application "cmdb-configurator-config" "cmdb-configurator-config" ${CONFIG_NAMESPACE}

    scale_ckey_statefulset
    remove_ckey_statefulset

    rollback_application "ckey" "ckey" ${BP_NAMESPACE}
    rollback_application "ckey-db-config" "ckey-db-config" ${CONFIG_NAMESPACE}

    rollback_application_in_background "crmq" "crmq" ${BP_NAMESPACE}
    rollback_application_in_background "crmq-configurator-config" "crmq-configurator-config" ${CONFIG_NAMESPACE}
    rollback_application_in_background "citm-server" "start-page" ${BP_NAMESPACE}
    wait_for_finish ${pids[@]}
    pids=()

    rollback_application "geo-redundancy-validation" "geo-redundancy-validation-keycloak" ${CONFIG_NAMESPACE}
    rollback_application "geo-redundancy-validation" "geo-redundancy-validation-repl" ${CONFIG_NAMESPACE}
    rollback_application "geo-redundancy-validation" "geo-redundancy-validation-maxscale" ${CONFIG_NAMESPACE}
    rollback_application "geo-redundancy-validation" "geo-redundancy-validation-mariadb" ${CONFIG_NAMESPACE}

    log_info "Rollback BP application has been finished"
}

function remove_dir {
    local dir=$1
    if [[ ! -z ${dir} && -d ${dir} ]]; then
        log_info "Cleanup ${dir}"
        rm -rf ${dir}
    fi
}

function cleanup {
    remove_dir ${tmp_charts_package_dir}
    remove_dir ${tmp_values_package_dir}
}

function cleanup_on_fail {
    if [ $? -ne 0 ]; then
        cleanup
        trap '' EXIT
        exit 1
    fi
}

function manage_application {
    if [ "${NO_CLEANUP}" == false ]; then
        trap cleanup_on_fail EXIT SIGINT
    fi
    if [[ "${ACTION}" == "${INSTALL_ACTION}" ]]; then
        install_bp
    elif [[ "${ACTION}" == "${UNINSTALL_ACTION}" ]]; then
        uninstall_bp
    elif [[ "${ACTION}" == "${AUDIT_UNINSTALL_ACTION}" ]]; then
        audit_uninstall
    elif [[ "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        upgrade_bp
    elif [[ "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        rollback_bp
    fi

    if [ "${NO_CLEANUP}" == false ]; then
        cleanup
    fi
}

function validate_parameters {
    if [ -z "${ACTION}" ]; then
        display_help
        log_error "--action parameter not set. Possible values: ${ACTION_POSSIBLE_VALUES}"
        exit 1
    fi

    if ! [[ ${ACTION} =~ ^(${ACTION_POSSIBLE_VALUES})$ ]]; then
        display_help
        log_error "Invalid value of --action parameter. Possible values: ${ACTION_POSSIBLE_VALUES}"
        exit 1
    fi

    if [[ -z "${CHARTS_PACKAGE}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        display_help
        log_error "--charts-package parameter not set"
        exit 1
    fi

    if  [[ ! -f "${CHARTS_PACKAGE}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        display_help
        log_error "${CHARTS_PACKAGE} file does not exist"
        exit 1
    fi

    if [[ -z "${VALUES_PACKAGE}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        display_help
        log_error "--values-package parameter not set"
        exit 1
    fi

    if [[ ! -f "${VALUES_PACKAGE}" ]]  && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        display_help
        log_error "${VALUES_PACKAGE} file does not exist"
        exit 1
    fi

    if [[ "${VALUES_PACKAGE}" ]] && [[ "${ACTION}" == "${UNINSTALL_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        display_help
        log_error "--values-package parameter is not valid for ${ACTION} action"
        exit 1
    fi

    if [ -z "${WORK_DIR}" ]; then
        log_info "--work-dir param not set - setting default ${DEFAULT_WORK_DIR}"
        WORK_DIR=${DEFAULT_WORK_DIR}
    fi

    if [ -z "${TIMEOUT}" ]; then
        if [[ "${ACTION}" == "${INSTALL_ACTION}" ]]; then
            TIMEOUT=${DEFAULT_INSTALLATION_TIMEOUT}
        elif [[ "${ACTION}" == "${UNINSTALL_ACTION}" ]]; then
            TIMEOUT=${DEFAULT_UNINSTALLATION_TIMEOUT}
        elif [[ "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
            TIMEOUT=${DEFAULT_UPGRADE_TIMEOUT}
        elif [[ "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
            TIMEOUT=${DEFAULT_ROLLBACK_TIMEOUT}
        elif [[ "${ACTION}" == "${AUDIT_UNINSTALL_ACTION}" ]]; then
            TIMEOUT=${DEFAULT_AUDIT_TIMEOUT}
        fi
        log_info "--timeout param not set - setting default ${TIMEOUT}"
    fi

    if ! [[ "${TIMEOUT}" =~ ^[0-9]+$ ]]; then
        log_error "--timeout must be integer"
        exit 1
    fi

    if [ -z "${NO_CLEANUP}" ]; then
        NO_CLEANUP=false
    fi

    if [[ -z "${RELEASE_PREFIX}" ]] && [[ "${ACTION}" == "${UNINSTALL_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        log_info "--release-prefix param not set, setting to default: ${DEFAULT_RELEASE_PREFIX}"
        RELEASE_PREFIX=${DEFAULT_RELEASE_PREFIX}
    fi

    if [[ "${RELEASE_PREFIX}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        display_help
        log_error "--release-prefix param is not valid for ${ACTION} action"
        exit 1
    fi

    if [[ "${ACTION}" == "${ROLLBACK_ACTION}" ]] && [[ -z "${RELEASE_VERSION}" ]]; then
        RELEASE_VERSION=${DEFAULT_RELEASE_VERSION}
    fi

    if [[ "${ACTION}" == "${ROLLBACK_ACTION}" ]] && [[ -z "${PREVIOUS_CMDB_BACKUP}" ]]; then
        display_help
        log_error "--backup param not set. This param is required for rollback."
        exit 1
    fi

    if [[ "${ACTION}" == "${ROLLBACK_ACTION}" ]] && [[ ! -f "${PREVIOUS_CMDB_BACKUP}" ]]; then
        display_help
        log_error "${PREVIOUS_CMDB_BACKUP} file is not found."
        exit 1
    fi

    if [[ -z "${BP_NAMESPACE}" ]] && [[ "${ACTION}" == "${UNINSTALL_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        display_help
        log_error "--bp-namespace param not set"
        exit 1
    fi

    if [[ "${BP_NAMESPACE}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        display_help
        log_error "--bp-namespace param is not valid for ${ACTION} action"
        exit 1
    fi

    if [[ -z "${CONFIG_NAMESPACE}" ]] && [[ "${ACTION}" == "${UNINSTALL_ACTION}" || "${ACTION}" == "${ROLLBACK_ACTION}" ]]; then
        display_help
        log_error "--config-namespace param not set"
        exit 1
    fi

    if [[ "${CONFIG_NAMESPACE}" ]] && [[ "${ACTION}" == "${INSTALL_ACTION}" || "${ACTION}" == "${UPGRADE_ACTION}" ]]; then
        display_help
        log_error "--config-namespace param is not valid for ${ACTION} action"
        exit 1
    fi

    if [ -z "${HELM_PATH}" ]; then
        log_info "--helm-path param not set - setting default '${DEFAULT_HELM_PATH}'"
        HELM_PATH=${DEFAULT_HELM_PATH}
    fi

    if [ -z "${KUBECTL_PATH}" ]; then
        log_info "--kubectl-path param not set - setting default '${DEFAULT_KUBECTL_PATH}'"
        KUBECTL_PATH=${DEFAULT_KUBECTL_PATH}
    fi

    log_info ""
}

function parse_input_parameters {
    for i in "${@}"
    do
    case $i in
        --action=*)
            ACTION="${i#*=}"
            shift
            ;;
        --charts-package=*)
            CHARTS_PACKAGE="${i#*=}"
            shift
            ;;
        --values-package=*)
            VALUES_PACKAGE="${i#*=}"
            shift
            ;;
        --work-dir=*)
            WORK_DIR="${i#*=}"
            shift
            ;;
        --timeout=*)
            TIMEOUT="${i#*=}"
            shift
            ;;
        --release-prefix=*)
            RELEASE_PREFIX="${i#*=}"
            shift
            ;;
        --bp-namespace=*)
            BP_NAMESPACE="${i#*=}"
            shift
            ;;
        --config-namespace=*)
            CONFIG_NAMESPACE="${i#*=}"
            shift
            ;;
        --backup=*)
            PREVIOUS_CMDB_BACKUP="${i#*=}"
            shift
            ;;
        --release_version=*)
            RELEASE_VERSION="${i#*=}"
            shift
            ;;
        --helm-path=*)
            HELM_PATH="${i#*=}"
            shift
            ;;
        --kubectl-path=*)
            KUBECTL_PATH="${i#*=}"
            shift
            ;;
        --no-cleanup)
            NO_CLEANUP=true
            shift
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        *)
            log_error "Param not supported"
            display_help
            exit 1
            ;;
    esac
    done
}

function display_help {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   --action                         action; Possible values: ${ACTION_POSSIBLE_VALUES}"
    echo "   --charts-package                 path to charts package; required during install, upgrade and rollback; in case of rollback the previous (${DEFAULT_RELEASE_VERSION}) charts package must be specified!"
    echo "   --values-package                 path to generated values package in yaml format; required during install and upgrade"
    echo "   --work-dir                       path to working directory with at least 20GB free space (default: ${DEFAULT_WORK_DIR})"
    echo "   --timeout                        component timeout in seconds, integer value, default:
                                                  installation=${DEFAULT_INSTALLATION_TIMEOUT},
                                                  uninstallation=${DEFAULT_UNINSTALLATION_TIMEOUT},
                                                  upgrade=${DEFAULT_UPGRADE_TIMEOUT},
                                                  rollback=${DEFAULT_ROLLBACK_TIMEOUT}"
    echo "   --backup                         MariaDB backup ID; mandatory for rollback action"
    echo "   --no-cleanup                     do not clean after installation; optional"
    echo "   --release-prefix                 prefix of release names, including trailing dash if present (default: ${DEFAULT_RELEASE_PREFIX}); optional during rollback and uninstall"
    echo "   --bp-namespace                   namespace of BP releases; required during rollback and uninstall"
    echo "   --config-namespace               namespace of configurators releases; required during rollback and uninstall"
    echo "   --release_version                number of release version to which the application is roll-backed (default: ${DEFAULT_RELEASE_VERSION});"
    echo "                                    optional during rollback"
    echo "   --helm-path                      path to the helm binary. If not specified, helm binary available on the PATH will be used"
    echo "   --kubectl-path                   path to the kubectl binary. If not specified, kubectl binary available on the PATH will be used"
    echo "Example: ./install.sh --action=install --charts-package=./NetGuard_Base_Platform-Charts-22.2.0.tgz --values-package=./values/NetGuard_Base_Platform-Values-gen.tgz"
    echo "Example: ./install.sh --action=uninstall --release-prefix=nbp- --bp-namespace=netguard-admin-ns --config-namespace=netguard-admin-ns"
    echo "Example: ./install.sh --action=upgrade --charts-package=./NetGuard_Base_Platform-Charts-22.2.0.tgz --values-package=./values/NetGuard_Base_Platform-Values-gen.tgz "
    echo "Example: ./install.sh --action=rollback --release-prefix=nbp- --bp-namespace=netguard-admin-ns --config-namespace=netguard-admin-ns --backup=mariadb.tgz --charts-package=<path to a previous version chart file, eg. ../bp_20/NetGuard_Base_Platform-Charts-2.0.0.tgz>"
    echo "Example: ./install.sh --action=audit --release-prefix=nbp- --bp-namespace=netguard-admin-ns"
    echo
}

function main {
    parse_input_parameters "${@}"
    validate_parameters
    time manage_application
}

main "${@}"
