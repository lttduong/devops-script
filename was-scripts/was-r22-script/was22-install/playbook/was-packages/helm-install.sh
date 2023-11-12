#!/bin/bash
# vim: filetype=sh shiftwidth=4 softtabstop=4
SCRIPTNAME=$(basename "$0")
readonly SCRIPTNAME
SCRIPTDIR=$(readlink -m "$(dirname "$0")")
readonly SCRIPTDIR

readonly INSTALLATION_TIMEOUT=${INSTALLATION_TIMEOUT:-900s}
readonly UNINSTALLATION_TIMEOUT=${UNINSTALLATION_TIMEOUT:-600s}

readonly DEFAULT_HELM_PATH=helm3
readonly INSTALL_ACTION=install
readonly UPGRADE_ACTION=upgrade
readonly UNINSTALL_ACTION=uninstall
readonly ACTION_POSSIBLE_VALUES="$INSTALL_ACTION|$UPGRADE_ACTION|$UNINSTALL_ACTION"
readonly DEFAULT_RELEASE_PREFIX=""

IGNORE_PREFIX_IN_RELEASE_NAME=
DRY_RUN=
NAMESPACE=

function display_help {
cat<<EOF
Usage: $SCRIPTNAME [option...]

Common options:
   --action=<action>         Install action. One of: $ACTION_POSSIBLE_VALUES [required]
   --helm-path               Path to the helm binary [default: ${DEFAULT_HELM_PATH}]
                             If not specified, helm binary available on the PATH will be used.

'install/upgrade' options:
   --appli-name=<name>              Application name [iam|acm|iam-acm|was|workbench]  [required]
   --config-values=<path>           Application <appli>_values.yml file     [required]
   --dry-run                        Use helm --dry-run option               [optional]
   --ignore-prefix-in-release-name  Ignores the release name prefix set in the APP_RELEASE_NAME_PREFIX configuration variable when
                                    composing the name of the Helm release to upgrade (applies to the upgrade option only)  [optional]

'uninstall' options:
   --appli-name=<name>       Application name [iam|acm|iam-acm|was|workbench]  [required]
   --namespace=<namespace>   Namespace                               [required]
   --release-prefix=<prefix> Release prefix (may be empty)           [required]

Examples:
  ./$SCRIPTNAME --action=install --appli-name=iam --config-values=templates/iam_values.yml --helm-path="ncs helm3"
  ./$SCRIPTNAME --action=upgrade --appli-name=iam --config-values=templates/iam_values.yml --helm-path="ncs helm3"
  ./$SCRIPTNAME --action=uninstall  --namespace=netguard-admin-ns --appli-name=iam --release-prefix=niam- --helm-path="ncs helm3"
  ./$SCRIPTNAME --action=uninstall  --namespace=netguard-admin-ns --appli-name=acm --release-prefix=nacm- --helm-path="ncs helm3"
  ./$SCRIPTNAME --action=uninstall  --namespace=netguard-admin-ns --appli-name=iam-acm --release-prefix=niam-nacm- --helm-path="ncs helm3"
EOF
}

function log_info {
    log "INFO" "$@"
}

function log_warning {
    log "WARNING" "$@" >&2
}

function log_error {
    log "ERROR" "$@" >&2
}

function log {
    local time_format="%Y-%m-%d %H:%M:%S.%3N"
    local log_severity=$1
    shift
    local log_msg="$*"
    echo "$(date +"${time_format}") | ${log_severity} | ${log_msg}"
}

function log_error_and_exit {
    log_error "$@"
    exit 1
}

# modified from http://stackoverflow.com/a/23002317/355492
function abspath {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    [ -e "$1" ] || log_error "path does not exist: $1"
    if [ -d "$1" ]; then
        # shellcheck disable=SC2164
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        if [[ $1 == */* ]]; then
          # shellcheck disable=SC2164
          echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
          echo "$(pwd)/$1"
        fi
    fi
}

function helm_cmd {
    ${HELM_PATH} "$@"
}

function is_application_installed {
    local namespace=$1
    local app_name=$2
    # shellcheck disable=SC2143
    if [ -z "$(helm_cmd ls --namespace="$namespace" | awk '{ print $1; }' | grep -w "^$app_name")" ]; then
        return 1  # not installed
    fi
    return 0  # is installed
}

function install_application {
    local action namespace version release_name_prefix helm_release_name
    action=$1
    namespace=$(grep -w "APP_NAMESPACE:" "${CONFIG_VALUES}" | awk '{ print $2; }')
    version=$(awk '/app:/{flag=1} flag && /version:/{print $NF;flag=""}' "${CONFIG_VALUES}")
    release_name_prefix=$(grep -w "releaseNamePrefix:" "${CONFIG_VALUES}" | awk '{ print $2; }')
    helm_release_name=${release_name_prefix}${APPLI_NAME}

    if [ -n "$NAMESPACE" ] && [ "$NAMESPACE" != "$namespace" ]; then
        log_error_and_exit "namespace does not match with APP_NAMESPACE in $CONFIG_VALUES"
    fi

    if [ "$INSTALL_ACTION" == "$action" ]; then
      if is_application_installed "$namespace" "$helm_release_name"; then
          log_error_and_exit "application is already installed in namespace=$namespace"
      fi
      log_info "Installing application ${helm_release_name} in namespace ${namespace}, timeout=$INSTALLATION_TIMEOUT"
    elif [ "$UPGRADE_ACTION" == "$action" ]; then
      if [ "$IGNORE_PREFIX_IN_RELEASE_NAME" = true ]; then
          helm_release_name=${APPLI_NAME}
      fi
      if ! is_application_installed "$namespace" "$helm_release_name"; then
          log_error_and_exit "application $helm_release_name is not installed in namespace=$namespace"
      fi
      log_info "Upgrading application ${helm_release_name} in namespace ${namespace}, timeout=$INSTALLATION_TIMEOUT"
    fi

    # TODO check the config vars secrets vs the values secrets and abort if not the same
    # if not generated yet in the config vars file then update the config vars file

    # Charts package: defaults to the proper place in our packaging directory,
    # but can be overridden via command line
    CHARTS_PACKAGE=${CHARTS_PACKAGE:-"$SCRIPTDIR/${APPLI_NAME}.tgz"}

    # Extract the charts tarball into a directory. Check for the directory; if not there, then extract the tarball.
    # Then, we supply the charts directory into helm here.
    local chart_extract_dir
    chart_extract_dir=$(basename "$CHARTS_PACKAGE" .tgz)
    if [ ! -d "$chart_extract_dir" ]; then
        log_info "Extracting $CHARTS_PACKAGE"
        tar zxf "$CHARTS_PACKAGE" || log_error_and_exit "Failed to extract $CHARTS_PACKAGE"
    fi
    if [ ! -d "$chart_extract_dir" ]; then
        log_error_and_exit "After extracting $CHARTS_PACKAGE, missing expected directory: $chart_extract_dir"
    fi

    ## handle extra ssl certs, copy certs to charts 
    local extra_certs_dir truststore_extra_configmap_dir
    extra_certs_dir="$SCRIPTDIR/server-extra-ssl-certs"
    truststore_extra_configmap_dir="$SCRIPTDIR/$chart_extract_dir/charts/server/truststore-extra-configmap"
    if [ -d "$extra_certs_dir" ] && [ -n "$(find $extra_certs_dir -name '*.pem' | head -1)" ]; then
        #log_info "Coping $extra_certs_dir pem files to $truststore_extra_configmap_dir"
        cp $extra_certs_dir/*.pem $truststore_extra_configmap_dir/. || log_error_and_exit "Failed to copy extra certs"
    fi

    # WAS process variable configuration
    local process_variable_config_dir process_variable_config_configmap_dir
    if [ "$APPLI_NAME" == "was" ]; then
        process_variable_config_dir="$SCRIPTDIR/config_dir_template/was-process-variable-config"
        process_variable_config_configmap_dir="$SCRIPTDIR/$chart_extract_dir/process-variable-config-configmap"
        if [ -d "$process_variable_config_dir" ] && [ -n "$(ls -A "$process_variable_config_dir")" ]; then
            cp $process_variable_config_dir/* $process_variable_config_configmap_dir/. || log_warning "Failed to copy WAS process variable configuration files"
        fi
    fi

    if [ "$INSTALL_ACTION" == "$action" ]; then
        # shellcheck disable=SC2086
        helm_cmd ${action} "${helm_release_name}" ./"$chart_extract_dir" \
            $DRY_RUN \
            --version "${version}" \
            --namespace "${namespace}" \
            --wait --timeout "${INSTALLATION_TIMEOUT}" \
            --values "${CONFIG_VALUES}" || log_error_and_exit "Failed to install ${helm_release_name}"
    elif [ "$UPGRADE_ACTION" == "$action" ]; then
        # shellcheck disable=SC2086
        helm_cmd ${action} "${helm_release_name}" ./"$chart_extract_dir" \
            $DRY_RUN \
            --version "${version}" \
            --reuse-values \
            --atomic \
            --namespace "${namespace}" \
            --wait --timeout "${INSTALLATION_TIMEOUT}" \
            --values "${CONFIG_VALUES}" || log_error_and_exit "Failed to upgrade ${helm_release_name}"
    fi

}

function uninstall_application {
    local helm_release_name=${RELEASE_PREFIX}${APPLI_NAME}
    log_info "Uninstall application ${helm_release_name} in namespace ${NAMESPACE}, timeout=$UNINSTALLATION_TIMEOUT"
    helm_cmd uninstall "${helm_release_name}" --namespace "$NAMESPACE" --timeout "${UNINSTALLATION_TIMEOUT}" || log_error_and_exit "Failed to uninstall ${helm_release_name}"
 }

function manage_application {
    case "$ACTION" in
        "$INSTALL_ACTION")
            install_application "$INSTALL_ACTION"
            ;;
        "$UPGRADE_ACTION")
            install_application "$UPGRADE_ACTION"
            ;;
        "$UNINSTALL_ACTION")
            uninstall_application
            ;;
        *)
            log_error_and_exit "Unexpected action: $ACTION"
            ;;
    esac
}

function validate_parameters {
    if [ -z "${ACTION}" ]; then
        log_error_and_exit "--action parameter not set. Possible values: ${ACTION_POSSIBLE_VALUES}"
    fi
    case "$ACTION" in
        "$INSTALL_ACTION")
            if [ -z "${APPLI_NAME}" ]; then
                log_error_and_exit "--appli-name parameter is required for install"
            fi
            if [ -z "${CONFIG_VALUES}" ]; then
                log_error_and_exit "--config-values parameter is required for install"
            fi
            if [ ! -f "${CONFIG_VALUES}" ]; then
                log_error_and_exit "--config-values: $CONFIG_VALUES file does not exist"
            fi
            CONFIG_VALUES=$(abspath "$CONFIG_VALUES")
            ;;
        "$UPGRADE_ACTION")
            if [ -z "${APPLI_NAME}" ]; then
                log_error_and_exit "--appli-name parameter is required for install"
            fi
            if [ -z "${CONFIG_VALUES}" ]; then
                log_error_and_exit "--config-values parameter is required for install"
            fi
            if [ ! -f "${CONFIG_VALUES}" ]; then
                log_error_and_exit "--config-values: $CONFIG_VALUES file does not exist"
            fi
            CONFIG_VALUES=$(abspath "$CONFIG_VALUES")
            ;;
        "$UNINSTALL_ACTION")
            if [ -z "${APPLI_NAME}" ]; then
                log_error_and_exit "--appli-name parameter is required for uninstall"
            fi
            if [ -z "${NAMESPACE}" ]; then
                log_error_and_exit "--namespace parameter is required for uninstall"
            fi
            if [ -z "${RELEASE_PREFIX+x}" ]; then
                log_error_and_exit "--release-prefix parameter is required for uninstall"
            fi
            ;;
        *)
            log_error_and_exit "Invalid value of --action parameter. Possible values: ${ACTION_POSSIBLE_VALUES}"
            ;;
    esac
    if [ -z "${HELM_PATH}" ]; then
        HELM_PATH=${DEFAULT_HELM_PATH}
    fi
    log_info ""
}

function parse_input_parameters {
    if [[ $# -eq 0 ]]; then
        display_help
        exit 1
    fi
    for i in "${@}"; do
        case $i in
            --action=*)
                ACTION="${i#*=}"
                shift
                ;;
            --appli-name=*)
                APPLI_NAME="${i#*=}"
                shift
                ;;
            --charts-package=*)
                CHARTS_PACKAGE="${i#*=}"
                shift
                ;;
            --config-values=*)
                CONFIG_VALUES="${i#*=}"
                shift
                ;;
            --dry-run)
                DRY_RUN=--dry-run
                shift
                ;;
            --helm-path=*)
                HELM_PATH="${i#*=}"
                shift
                ;;
            --namespace=*)
                NAMESPACE="${i#*=}"
                shift
                ;;
            --release-prefix=*)
                RELEASE_PREFIX="${i#*=}"
                shift
                ;;
            --ignore-prefix-in-release-name)
                IGNORE_PREFIX_IN_RELEASE_NAME=true
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

function main {
    parse_input_parameters "${@}"
    validate_parameters
    time manage_application
}

main "${@}"

