#!/usr/bin/env bash
# vim: set filetype=sh:
set -o nounset;  # Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o pipefail; # Catch the error in case a piped command fails
set -o errexit;  # Exit on error. Append "|| true" if you expect an error. Same as 'set -e'
set -o errtrace; # Exit on error inside any functions or subshells. Same as 'set -E'

# shellcheck disable=SC2155
readonly SCRIPTNAME=$(basename "$0")

readonly DEFAULT_KUBECTL_PATH=kubectl
readonly DEFAULT_NAMESPACE='netguard-admin-ns'
readonly DEFAULT_RELEASE_NAME_PREFIX=''
readonly DEFAULT_RELEASE_NAME_PREFIX_TXT="null"
readonly DEFAULT_PRODUCT=niam
readonly INPUT_PARAM_ERROR=1

DEBUG=
SECRETS_OUTPUT_FILE=
NAMESPACE=
PRODUCT=
RELEASE_NAME_PREFIX=
CONFIG_VARGS_FILE=
KUBECTL_PATH=
CLEANUP_REQUIRED=

display_help() {
cat<<EOF
This script is run on the deploy node or a node with access to the kubectl command.

Functions:
- get|get-secrets: Backup important application secrets to file.
- update-config-vars: Update config_vars template file with secrets from backup.

USAGE:
  $SCRIPTNAME [option...] [get(-secrets)|update-config-vars]

ARGUMENTS:
  get|get-secrets:    Retrieve secrets via kubectl
  update-config-vars: Update the secrets in given config_vars file

OPTIONS:
  General:
    --kubectl-path : Path to the kubectl binary (default: ${DEFAULT_KUBECTL_PATH})
            If not specified, kubectl binary available on the PATH will be used.
    --product [niam|nacm|niam-nacm|nwas|workbench|framework|codeploy|iam|acm|iam-acm|was|wb|fw] : Name of installed product. Used to determine the required secrets.
    -s|--secrets-file <file> : Specifies filename used to store secrets. This file will be created by get-secrets.
            (default: is created according to secrets-<product>-<namespace>.env)

  For get-secrets (used as input into kubectl):
    -n|--namespace : The same as provided in product installation (default: ${DEFAULT_NAMESPACE})
    --prefix : The release name prefix defined in the product configuration file (default: ${DEFAULT_RELEASE_NAME_PREFIX_TXT})

  For update-config-vars:
    -c|--config-vars <file> : The config vars file to update

  -h|--help: print this help

EXAMPLES:
  Get secrets to file:
    $SCRIPTNAME --product=niam --secrets-file niam-netguard-admin-ns.env --namespace=netguard-admin-ns --prefix=niam- --kubectl-path="ncs kubectl" get-secrets

  Update config_vars from secrets file:
    $SCRIPTNAME --product=niam --secrets-file secrets-niam-netguard-admin-ns.env --kubectl-path="ncs kubectl" --config-vars templates/iam_config_vars.tpl update-config-vars
EOF
}

# Format: This is a bash array, where each secret definition is a string of format:
# "<config_var> <secret_name (no prefix)> <secret_key>"
#
# Where <config_var> should match the config_var
#
# shellcheck disable=SC2034
NIAM_SECRET_DEFS=(\
"NOSDB_PASSWORD {prefix}nosdb-secret password" \
"NIAMDB_PASSWORD {prefix}niamdb-secret password" \
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_SECRET {prefix}ckey-netguard-network-access-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_AGENT_SECRET {prefix}ckey-netguard-network-access-agent-client-secret clientSecret" \
"NETGUARD_IAM_SECRET {prefix}ckey-netguard-iam-client-secret clientSecret" \
"NETGUARD_IAM_PROXY_SECRET {prefix}ckey-netguard-iam-proxy-client-secret clientSecret" \
"NETGUARD_IAM_KC_SECRET {prefix}ckey-netguard-iam-kc-cleanup-client-secret clientSecret" \
"NETGUARD_IAM_VIDEOLOGGING_SECRET {prefix}ckey-netguard-videologging-client-secret clientSecret" \
"CKEYLISTENERCRMQPASSWORD {prefix}ckey-listener-user-secret password" \
"NIAMUSERCRMQPASSWORD {prefix}iamuser-secret password" \
"PROXYUSERCRMQPASSWORD {prefix}proxy-crmq-user-secret password" \
"FLUENTDUSERCRMQPASSWORD {prefix}fluentd-crmq-user-secret password" \
"VIDEOLOGGINGUSERCRMQPASSWORD {prefix}videologginguser-secret password" \
"LASTLOGINUSERCRMQPASSWORD {prefix}iam-last-login-tracker-crmq-user-secret password" \
"LOGINBANNERDB_PASSWORD {prefix}loginbannerdb-secret password" \
"NETGUARD_IAM_LB_SECRET {prefix}ckey-netguard-iam-lb-client-secret clientSecret" \
)

# NOTE: there are duplicates in acm_config_vars.yml for NOSDB_PASSWORD/NOSDBPASSWORD, NACMDB_PASSWORD/NACMDBPASSWORD
# shellcheck disable=SC2034
NACM_SECRET_DEFS=(\
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_SECRET {prefix}ckey-netguard-network-access-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_AGENT_SECRET {prefix}ckey-netguard-network-access-agent-client-secret clientSecret" \
"NETGUARD_ACM_SECRET {prefix}ckey-netguard-acm-client-secret clientSecret" \
"NOSDBPASSWORD {prefix}nosdb-secret password" \
"NACMDBPASSWORD {prefix}nacmdb-secret password" \
"CKEYLISTENERCRMQPASSWORD {prefix}ckey-listener-user-secret password" \
"NACMUSERCRMQPASSWORD {prefix}acmuser-secret password" \
)

# shellcheck disable=SC2034
CODEPLOY_SECRET_DEFS=(\
"NOSDB_PASSWORD {prefix}nosdb-secret password" \
"NIAMDB_PASSWORD {prefix}niamdb-secret password" \
"NACMDB_PASSWORD {prefix}nacmdb-secret password" \
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_SECRET {prefix}ckey-netguard-network-access-client-secret clientSecret" \
"NETGUARD_NETWORKACCESS_AGENT_SECRET {prefix}ckey-netguard-network-access-agent-client-secret clientSecret" \
"NETGUARD_IAM_SECRET {prefix}ckey-netguard-iam-client-secret clientSecret" \
"NETGUARD_IAM_PROXY_SECRET {prefix}ckey-netguard-iam-proxy-client-secret clientSecret" \
"NETGUARD_IAM_KC_SECRET {prefix}ckey-netguard-iam-kc-cleanup-client-secret clientSecret" \
"NETGUARD_IAM_VIDEOLOGGING_SECRET {prefix}ckey-netguard-videologging-client-secret clientSecret" \
"NETGUARD_ACM_SECRET {prefix}ckey-netguard-acm-client-secret clientSecret" \
"CKEYLISTENERCRMQPASSWORD {prefix}ckey-listener-user-secret password" \
"NIAMUSERCRMQPASSWORD {prefix}iamuser-secret password" \
"PROXYUSERCRMQPASSWORD {prefix}proxy-crmq-user-secret password" \
"FLUENTDUSERCRMQPASSWORD {prefix}fluentd-crmq-user-secret password" \
"VIDEOLOGGINGUSERCRMQPASSWORD {prefix}videologginguser-secret password" \
"NACMUSERCRMQPASSWORD {prefix}acmuser-secret password" \
"LASTLOGINUSERCRMQPASSWORD {prefix}iam-acm-last-login-tracker-crmq-user-secret password" \
"NETGUARD_IAM_LB_SECRET {prefix}ckey-netguard-iam-lb-client-secret clientSecret" \
"LOGINBANNERDB_PASSWORD {prefix}loginbannerdb-secret password" \
)

# shellcheck disable=SC2034
WAS_SECRET_DEFS=(\
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
"NETGUARD_WAS_SECRET {prefix}ckey-netguard-was-client-secret clientSecret" \
)

# shellcheck disable=SC2034
WORKBENCH_SECRET_DEFS=(\
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
"NETGUARD_WORKBENCH_SECRET {prefix}ckey-was-workbench-client-secret clientSecret" \
)

# shellcheck disable=SC2034
FRAMEWORK_SECRET_DEFS=(\
"NETGUARD_FRAMEWORK_SECRET {prefix}ckey-netguard-framework-client-secret clientSecret" \
)

# Logging: these all log to stderr
die() { >&2 colorecho red "FATAL: $*"; exit 1; }
die_with_rc() { local rc=$1; shift; >&2 colorecho red "FATAL: $*, rc=$rc"; exit "$rc"; }
check_rc_die() { local rc=$1; shift; [ "$rc" != "0" ] && die_with_rc "$rc" "$@"; return 0; }
log_error() { >&2 colorecho red "ERROR: $*"; }
log_warn() { >&2 colorecho orange "WARN: $*"; }
log_info() { >&2 echo "$*"; }
log_debug() { if [ -n "$DEBUG" ]; then >&2 echo "DEBUG: $*"; fi; }
log_progress() { >&2 colorecho green "$*"; }

colorecho() {  # usage: colorecho <colour> <text> or colorecho -n <colour> <text>
  local echo_arg=
  if [ "$1" = "-n" ]; then echo_arg="-n"; shift; fi
  local colour="$1"; shift
  case "${colour}" in
    red) echo $echo_arg -e "$(tput setaf 1)$*$(tput sgr0)"; ;;
    green) echo $echo_arg -e "$(tput setaf 2)$*$(tput sgr0)"; ;;
    green-bold) echo $echo_arg -e "$(tput setaf 2; tput bold)$*$(tput sgr0)"; ;;
    yellow) echo $echo_arg -e "$(tput setaf 3; tput bold)$*$(tput sgr0)"; ;;
    orange) echo $echo_arg -e "$(tput setaf 3)$*$(tput sgr0)"; ;;
    blue) echo $echo_arg -e "$(tput setaf 4)$*$(tput sgr0)"; ;;
    purple) echo $echo_arg -e "$(tput setaf 5)$*$(tput sgr0)"; ;;
    cyan) echo $echo_arg -e "$(tput setaf 6)$*$(tput sgr0)"; ;;
    bold) echo $echo_arg -e "$(tput bold)$*$(tput sgr0)"; ;;
    normal|*) echo $echo_arg -e "$*"; ;;
  esac
}

function kubectl_cmd {
    ${KUBECTL_PATH} "$@"
}

get_secret() {
  local namespace=$1
  local k8s_secret_name=$2
  local secret_key=$3
  log_debug "Getting secret: $k8s_secret_name:$secret_key from $namespace"
  local extracted_secret=$(kubectl_cmd get secret -n "$namespace" "$k8s_secret_name" -o jsonpath=\{.data."${secret_key}"\})
  if [ -z "$extracted_secret" ]; then
      log_warn "Secret: $k8s_secret_name:$secret_key not found."
  else
      echo $extracted_secret | base64 -d
  fi
}

get_secret_from_def() {
  local config_var=$1
  local secret_name=$2
  local secret_key=$3
  local secret_val

  # Replace '{prefix}' with $RELEASE_NAME_PREFIX in the secret-name:
  local prefixed_secret_name=${secret_name/'{prefix}'/$RELEASE_NAME_PREFIX}
  log_debug "prefixed_secret_name=$prefixed_secret_name"

  secret_val=$(get_secret "$NAMESPACE" "$prefixed_secret_name" "$secret_key")
  if [ -z "$secret_val" ]; then
      log_warn "During upgrade,if applicable, ensure that above secret value is retrieved and updated in product config variable template file post restoring the current script retrieved-secrets."
  else
      # echo value in environment variable format:
      echo "${config_var}=\"${secret_val}\""
  fi
}

get_secrets_to_file() {
  local output_file=${1:-$SECRETS_OUTPUT_FILE}
  log_progress "Retrieving secrets to '${output_file}'"
  echo "# Secrets for: namespace=$NAMESPACE product=$PRODUCT prefix=$RELEASE_NAME_PREFIX" > "$output_file"
  echo "# Generated on ${HOSTNAME:-$(hostname)} at: $(date)" >> "$output_file"
  for secret_def in "${SECRET_DEFS[@]}"; do
    # shellcheck disable=SC2086
    get_secret_from_def $secret_def >> "$output_file"
  done
  log_progress "Retrieved secrets successfully to file: $output_file"
}

_replace_config_var() {
  local config_var_file=$1
  local config_var_name=$2
  local config_var_value=$3
  log_info "Replacing $config_var_name with value: $config_var_value"

  # Note: bash variables are pulled outside of the ' ' quotes, and are themselves double-quoted as per shellcheck:
  sed -i 's/^'"${config_var_name}"': .*/'"${config_var_name}: ${config_var_value}"'/' "$config_var_file"
}

update_config_vars() {
  local secret_output_file=$1
  local config_var_file=$2
  if [ ! -f "$config_var_file" ]; then
    echo "ERROR: file does not exist: $config_var_file"
    exit ${INPUT_PARAM_ERROR}
  fi

  local config_var_file_bak="${config_var_file}.bak"
  if [ ! -f "$config_var_file_bak" ]; then
    log_info "Replacing config vars in $config_var_file (backup to $config_var_file_bak)"
    cp "$config_var_file" "${config_var_file}.bak"
  else
    log_info "Replacing config vars in $config_var_file (backup already exists)"
  fi

  while IFS= read -r line; do
# The longest matching TRAILING portion of "parameter" with "word" having pattern =* will be deleted. Reference : ${parameter%%word}
    local config_var=${line%%=*}
    local secret_val=${line#*=}
    local secret_val=${secret_val//&/\\&} # Escape & to avoid issue in sed command string replacement
    local secret_val=${secret_val//\"/}  # remove quotes
    _replace_config_var "$config_var_file" "$config_var" "$secret_val"
  done < <(grep -v '^ *#' < "$secret_output_file")   # uses process substitution (the first '<' redirects to stdin)
  log_progress "Updated config_vars successfully"
}

validate_parameters() {
  if [ -z "${KUBECTL_PATH}" ]; then
    log_debug "Using default kubectl path: ${KUBECTL_PATH}"
    KUBECTL_PATH=${DEFAULT_KUBECTL_PATH}
  fi
  if [ -z "${NAMESPACE}" ]; then
    log_debug "Using default namespace: ${DEFAULT_NAMESPACE}"
    NAMESPACE=${DEFAULT_NAMESPACE}
  fi
  if [ -z "${RELEASE_NAME_PREFIX}" ]; then
    log_debug "Using default release name prefix: ${DEFAULT_RELEASE_NAME_PREFIX_TXT}"
    RELEASE_NAME_PREFIX=${DEFAULT_RELEASE_NAME_PREFIX}
  else
    RELEASE_NAME_PREFIX="${RELEASE_NAME_PREFIX}"
  fi
  SECRETS_OUTPUT_FILE=${SECRETS_OUTPUT_FILE:-secrets-${PRODUCT}-${NAMESPACE}.env}

  PRODUCT=${PRODUCT:-$DEFAULT_PRODUCT}
  case "${PRODUCT,,}" in  # convert to lower-case for compare
    iam|niam)
      SECRET_DEFS=( "${NIAM_SECRET_DEFS[@]}" )
      ;;
    acm|nacm)
      SECRET_DEFS=( "${NACM_SECRET_DEFS[@]}" )
      ;;
    codeploy|niam-nacm|iam-acm)
      SECRET_DEFS=( "${CODEPLOY_SECRET_DEFS[@]}" )
      ;;
    was|nwas)
      SECRET_DEFS=( "${WAS_SECRET_DEFS[@]}" )
      ;;
    workbench|wb)
      SECRET_DEFS=( "${WORKBENCH_SECRET_DEFS[@]}" )
      ;;
    framework|fw)
      SECRET_DEFS=( "${FRAMEWORK_SECRET_DEFS[@]}" )
      ;;
    *)
      die "Unsupported product: $PRODUCT"
      ;;
  esac
}

################################################################################
# Main

CLEANUP_REQUIRED=
do_cleanup() {
  if [ -n "$CLEANUP_REQUIRED" ]; then
    log_error "Command failed. Cleaning up on failure"
    [ -f "$SECRETS_OUTPUT_FILE" ] && rm "$SECRETS_OUTPUT_FILE"
  fi
}

main() {
  local arg_cmd=
  while [ $# -gt 0 ] ; do
    case "${1:-""}" in
      -h|--help)
        display_help
        exit 0
        ;;
      -D|--debug)
        DEBUG=1
        ;;
      -n|--namespace)
        shift
        NAMESPACE=$1
        ;;
      -n=*|--namespace=*)
        NAMESPACE="${1#*=}"
        ;;
      --prefix)
        shift
        RELEASE_NAME_PREFIX=$1
        ;;
      --prefix=*)
        RELEASE_NAME_PREFIX="${1#*=}"
        ;;
      --product)
        shift
        PRODUCT=$1
        ;;
      --product=*)
        PRODUCT="${1#*=}"
        ;;
      -s|--secrets-file)
        shift
        SECRETS_OUTPUT_FILE=$1
        ;;
      -s=*|--secrets-file=*)
        SECRETS_OUTPUT_FILE="${1#*=}"
        ;;
      -c|--config-vars)
        shift
        CONFIG_VARGS_FILE=$1
        ;;
      -c=*|--config-vars=*)
        CONFIG_VARGS_FILE="${1#*=}"
        ;;
      --kubectl-path)
        shift
        KUBECTL_PATH=$1
        ;;
      --kubectl-path=*)
        KUBECTL_PATH="${1#*=}"
        ;;
      get|get-secrets|update-config-vars)
        arg_cmd=$1
        ;;
      *)
        die "Invalid argument '$1' [use -h/--help for help]"
        ;;
    esac
    shift
  done

  validate_parameters

  trap do_cleanup INT QUIT TERM EXIT

  case "$arg_cmd" in
    get|get-secrets)
      CLEANUP_REQUIRED=1
      get_secrets_to_file "$SECRETS_OUTPUT_FILE"
      ;;
    update-config-vars)
      [ -z "$CONFIG_VARGS_FILE" ] && die "no config_vars file given [use -h/--help for help]"
      update_config_vars "$SECRETS_OUTPUT_FILE" "$CONFIG_VARGS_FILE"
      ;;
    '')
      display_help
      ;;
  esac
  CLEANUP_REQUIRED=
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  main "$@"
fi
