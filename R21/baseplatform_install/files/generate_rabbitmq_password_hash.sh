#!/usr/bin/env bash

readonly SCRIPT_FILE_NAME=$(basename $BASH_SOURCE)
VERBOSE=""

function print_help {
    echo ""
    echo "Generates RabbitMQ password hash according to https://www.rabbitmq.com/passwords.html#computing-password-hash"
    echo "Usage: "
    echo "  ./${SCRIPT_FILE_NAME} [options]"
    echo "  Required arguments:"
    echo "    -s, --salt 32-bit salt (e.g. 908DC60A)"
    echo "    -p, --passphrase Passphrase to be hashed"
    echo "  Optional arguments:"
    echo "    -v, --verbose Turn on verbose output"
    echo "    -h, --help Show help"
}

function log {
    local severity="$1"
    local message="$2"
    echo "${severity} | ${message}"
}

function log_debug {
    if [ ! -z "$VERBOSE" ]; then
        log "DEBUG" "$1" >&2
    fi
}

function log_error_and_exit {
    log "ERROR" "$1"
    exit 1
}

function convert_passphrase_to_utf_8 {
    PASSPHRASE_UTF_8=$(echo ${PASSPHRASE} | tr -d \\n | xxd -p)
    log_debug "UTF-8 passphrase: ${PASSPHRASE_UTF_8}"
}

function compute_hash {
    SHA256_HASH=$(echo "${SALT}${PASSPHRASE_UTF_8}" | xxd -r -p | sha256sum | sed "s/(stdin)=//")
    log_debug "SHA256 hash: ${SHA256_HASH}"
}

function convert_to_base64 {
    PASSWORD_HASH=$(echo "${SALT}${SHA256_HASH}" | xxd -r -p | base64)
    log_debug "Password hash: ${PASSWORD_HASH}"
}

function generate_password_hash {
    convert_passphrase_to_utf_8
    compute_hash
    convert_to_base64
    echo ${PASSWORD_HASH}
}

#####################################################

if [ $# -eq 0 ]; then
    log_error_and_exit "no parameters provided - check help for parameter descriptions `print_help`"
fi

while [[ $# -gt 0 ]]
do
    key="$1"
    case ${key} in
        -s|--salt)
            SALT=$2
            shift
            shift
            ;;
        -p|--passphrase)
            PASSPHRASE=$2
            shift
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            log_error_and_exit "parameter $1 not found. `print_help`"
            ;;
    esac
done

generate_password_hash
