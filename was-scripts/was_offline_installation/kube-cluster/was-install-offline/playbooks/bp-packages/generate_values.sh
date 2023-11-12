#!/bin/bash
set -e

readonly SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
readonly PROJECT_NAME="NetGuard_Base_Platform-Values"
readonly DEFAULT_WORK_DIR="/tmp"
readonly DEFAULT_NCMTPL_BIN="ncmtpl"
readonly CONFIG_VARS_FILE="bp_config_vars.yaml"
readonly COMMON_VALUES="common"
readonly VALIDATIONS="validation"
readonly YAML="yaml"
readonly TPL="tpl"
readonly EXT="tgz"
readonly RESOURCE_PROFILE_DIR="resource-profiles"

function log_info {
    log INFO "${*}"
}

function log_error {
    log ERROR "${*}"
}

function log {
    echo "$(date) ${*}"
}

function prepare_dirs {
    log_info "Untar values ${VALUES_PACKAGE} to ${tmp_values_in_dir}"
    tar -xf ${VALUES_PACKAGE} -C ${tmp_values_in_dir}

    mkdir -p ${tmp_values_out_dir}/values
    mkdir -p ${tmp_values_out_dir}/${RESOURCE_PROFILE_DIR}

    if [[ ! -e ${OUTPUT_DIR} ]]; then
        mkdir -p "${OUTPUT_DIR}"
    fi
}

function validate_config_vars {
    log_info "Validate config vars"
    local config_vars=${tmp_values_out_dir}/${CONFIG_VARS_FILE}
    local values_in_dir=${tmp_values_in_dir}/${PROJECT_NAME}

    ${NCMTPL_BIN} ${values_in_dir}/${VALIDATIONS}.${TPL} -d ${config_vars}
}


function generate_common_values {
    log_info "Template common values"
    local config_vars=${tmp_values_out_dir}/${CONFIG_VARS_FILE}
    local values_in_dir=${tmp_values_in_dir}/${PROJECT_NAME}

    ${NCMTPL_BIN} ${values_in_dir}/${COMMON_VALUES}.${TPL} -d ${config_vars} -d ${values_in_dir}/versions.yaml > ${tmp_values_out_dir}/${COMMON_VALUES}.${YAML}
}

function copy_upgrade_values {
    log_info "Copy upgrade values"
    local values_in_dir=${tmp_values_in_dir}/${PROJECT_NAME}
    cp -R ${values_in_dir}/upgrade ${tmp_values_out_dir}/upgrade
}


function generate_values_files {
    log_info "Template values"

    local config_vars=${tmp_values_out_dir}/${CONFIG_VARS_FILE}
    local values_in_dir=${tmp_values_in_dir}/${PROJECT_NAME}/values
    log_info "Generating values from ${values_in_dir} to ${tmp_values_out_dir}"

    for value_tpl_file in $(ls "${values_in_dir}"); do
        local app_name="${value_tpl_file%.*}"
        log_info "Generating value ${app_name}"
        ${NCMTPL_BIN} ${values_in_dir}/${value_tpl_file} -d ${config_vars} -d ${values_in_dir}/../versions.yaml > ${tmp_values_out_dir}/values/${app_name}.${YAML}
    done

}

function generate_resource_profiles {
    log_info "Template resource profiles"

    local config_vars=${tmp_values_out_dir}/${CONFIG_VARS_FILE}
    local values_in_dir=${tmp_values_in_dir}/${PROJECT_NAME}/resource-profiles
    log_info "Generating resource profiles from ${values_in_dir} to ${tmp_values_out_dir}/resource-profiles"

    for profile in $(ls "${values_in_dir}"); do
        mkdir -p ${tmp_values_out_dir}/resource-profiles/${profile}
        for value_tpl_file in $(ls "${values_in_dir}/${profile}"); do
            local app_name="${value_tpl_file%.*}"
            log_info "Generating resource profile in ${profile} profile for ${app_name}"
            ${NCMTPL_BIN} ${values_in_dir}/${profile}/${value_tpl_file} -d ${config_vars} -d ${values_in_dir}/../versions.yaml > ${tmp_values_out_dir}/resource-profiles/${profile}/${app_name}.${YAML}
        done
    done

}


function read_passphrase_for_fpm {
    readonly db_calm_passphrase=$(cat ${CONFIG_VARS} | grep BTEL_DB_CALM_PASSPHRASE: | awk {'print $2'})
    readonly calm_cnot_passphrase=$(cat ${CONFIG_VARS} | grep BTEL_CALM_CNOT_PASSPHRASE: | awk {'print $2'})
    readonly crmq_calm_passphrase=$(cat ${CONFIG_VARS} | grep BTEL_CALM_MQ_PASSPHRASE: | awk {'print $2'})
}

function read_passwords_for_fpm {
    readonly db_calm_password=$(cat ${CONFIG_VARS} | grep BTEL_DB_CALM_PASSWORD: | awk {'print $2'})
    readonly calm_cnot_truststore_password=$(cat ${CONFIG_VARS} | grep BTEL_CALM_CNOT_PASSWORD: | awk {'print $2'})
    readonly crmq_calm_password=$(cat ${CONFIG_VARS} | grep -w BTEL_CALM_MQ_PASSWORD: | awk {'print $2'})
}

function generate_fpm_password {
    read_passphrase_for_fpm
    read_passwords_for_fpm

    local db_calm_password_encrypted=$(${SCRIPT_DIR}/fpm-password en ${db_calm_password} ${db_calm_passphrase})
    local calm_cnot_truststore_password_encrypted=$(${SCRIPT_DIR}/fpm-password en ${calm_cnot_truststore_password} ${calm_cnot_passphrase})
    local crmq_calm_password_encrypted=$(${SCRIPT_DIR}/fpm-password en ${crmq_calm_password} ${crmq_calm_passphrase})

    local db_calm_password_encrypted_escaped=$(printf '%s' "${db_calm_password_encrypted}" | sed -e 's/[\/&]/\\&/g')
    local calm_cnot_truststore_password_encrypted_escaped=$(printf '%s' "${calm_cnot_truststore_password_encrypted}" | sed -e 's/[\/&]/\\&/g')
    local crmq_calm_password_encrypted_escaped=$(printf '%s' "${crmq_calm_password_encrypted}" | sed -e 's/[\/&]/\\&/g')

    local config_vars=${tmp_values_out_dir}/${CONFIG_VARS_FILE}
    sed -i "s/^BTEL_DB_CALM_PASSWORD_ENCRYPTED:.*/BTEL_DB_CALM_PASSWORD_ENCRYPTED: \"${db_calm_password_encrypted_escaped}\"/g" "${config_vars}"
    sed -i "s/^BTEL_CALM_CNOT_PASSWORD_ENCRYPTED:.*/BTEL_CALM_CNOT_PASSWORD_ENCRYPTED: \"${calm_cnot_truststore_password_encrypted_escaped}\"/g" "${config_vars}"
    sed -i "s/^BTEL_CALM_MQ_PASSWORD_ENCRYPTED:.*/BTEL_CALM_MQ_PASSWORD_ENCRYPTED: \"${crmq_calm_password_encrypted_escaped}\"/g" "${config_vars}"
}

function copy_config_vars {
    log_info "Copy ${CONFIG_VARS} to ${tmp_values_out_dir}/"
    cp ${CONFIG_VARS} ${tmp_values_out_dir}/${CONFIG_VARS_FILE}
}

function remove_dir {
    local dir=$1
    if [[ ! -z ${dir} && -d ${dir} ]]; then
        log_info "Cleanup ${dir}"
        rm -rf ${dir}
    fi
}

function cleanup {
    remove_dir ${tmp_values_in_dir}
    remove_dir ${tmp_values_out_dir}
}

function cleanup_on_fail {
    if [ $? -ne 0 ]; then
        cleanup
        trap '' EXIT
        exit 1
    fi
}

function create_archive {
    log_info "Creating archive ${PACKAGE_NAME} in ${OUTPUT_DIR}"
    (
        cd "${tmp_values_out_dir}" && tar -zcf "${PACKAGE_NAME}" * && cd - > /dev/null
        cp ${tmp_values_out_dir}/${PACKAGE_NAME} ${OUTPUT_DIR}/
    )
    log_info "Package created ${PACKAGE_NAME}"
}

function generate_values {
    PACKAGE_NAME="${PROJECT_NAME}-gen.${EXT}"
    log_info "Generate values ${PACKAGE_NAME}"

    if [ "${NO_CLEANUP}" = false ]; then
        trap cleanup_on_fail EXIT SIGINT
    fi

    tmp_values_in_dir=$(mktemp -d ${WORK_DIR}/generate-values-in.XXXXXXX)
    tmp_values_out_dir=$(mktemp -d ${WORK_DIR}/generate-values-out.XXXXXXX)

    prepare_dirs

    copy_config_vars
    validate_config_vars
    generate_fpm_password
    generate_common_values
    generate_values_files
    generate_resource_profiles
    copy_upgrade_values
    create_archive

    if [ "${NO_CLEANUP}" = false ]; then
        cleanup
    fi
}

function validate_parameters {
    if [ -z "${VALUES_PACKAGE}" ]; then
        display_help
        log_error "--values-package parameter not set"
        exit 1
    fi

    if [ ! -f "${VALUES_PACKAGE}" ]; then
        display_help
        log_error "${VALUES_PACKAGE} file does not exist"
        exit 1
    fi

    if [ -z "${CONFIG_VARS}" ]; then
        display_help
        log_error "--config-vars parameter not set"
        exit 1
    fi

    if [ ! -f "${CONFIG_VARS}" ]; then
        display_help
        log_error "${CONFIG_VARS} file does not exist"
        exit 1
    fi

    if [ -z "${OUTPUT_DIR}" ]; then
        display_help
        log_error "--output-dir parameter not set"
        exit 1
    fi

    if [ -z "${NCMTPL_BIN}" ]; then
        log_info "--ncmtpl-bin param not set - setting default ${DEFAULT_NCMTPL_BIN}"
        NCMTPL_BIN=${DEFAULT_NCMTPL_BIN}
    fi

    if [ -z "${WORK_DIR}" ]; then
        log_info "--work-dir param not set - setting default ${DEFAULT_WORK_DIR}"
        WORK_DIR=${DEFAULT_WORK_DIR}
    fi

    if [ -z "${NO_CLEANUP}" ]; then
        NO_CLEANUP=false
    fi
    log_info ""
}

function parse_input_parameters {
    for i in "${@}"
    do
    case $i in
        --values-package=*)
        VALUES_PACKAGE="${i#*=}"
        shift
        ;;
        --config-vars=*)
        CONFIG_VARS="${i#*=}"
        shift
        ;;
        --output-dir=*)
        OUTPUT_DIR="${i#*=}"
        shift
        ;;
        --ncmtpl-bin=*)
        NCMTPL_BIN="${i#*=}"
        shift
        ;;
        --work-dir=*)
        WORK_DIR="${i#*=}"
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
        display_help
        log_error "Param not supported: ${i#*=}"
        exit 1
        ;;
    esac
    done
}

function display_help {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   --values-package                 path to input values package"
    echo "   --config-vars                    path to config vars yaml"
    echo "   --output-dir                     output dir"
    echo "   --ncmtpl-bin                     ncmtpl bin (default: ${DEFAULT_NCMTPL_BIN})"
    echo "   --work-dir                       path to working directory (default: ${DEFAULT_WORK_DIR})"
    echo "   --no-cleanup                     do not clean after installation; optional"
    echo
    echo "Example: $0 --values-package=./NetGuard_Base_Platform-Values-22.2.0.tgz --config-vars=bp_config_vars.yaml --output-dir=./values --ncmtpl-bin=./ncmtpl"
    echo
}

function main {
    parse_input_parameters "${@}"
    validate_parameters
    time generate_values
}

main "${@}"
