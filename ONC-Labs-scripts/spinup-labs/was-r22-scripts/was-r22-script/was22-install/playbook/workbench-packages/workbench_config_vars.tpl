---
NAMESPACE: netguard-base
APP_RELEASE_NAME_PREFIX: "waswb-"

# One of 'schema' or 'upgrade'
NOS_DBSCHEMATOOL_OPERATION: schema
WORKBENCH_DBSCHEMATOOL_OPERATION: schema

# EXTRA SSL CERTIFICATE(S)
# This option is not useful in Workbench, leave the value to "false".
SERVER_EXTRA_SSL_CERTS: false

# NODE_AFFINITY is used to control which nodes pods are assigned to. The key/value must match a node label/value.
# if nodes with matching key/value label have taints, the TOLERATION_KEY must be value accordingly.
# to check taints on nodes in the cluster use the following command when connected to a control node:
# sudo kubectl get nodes -o jsonpath='{range.items[*]}{@.metadata.labels.kubernetes\.io/hostname}{" "}{@.spec.taints}{"\n"}{end}'
# example output:
# paris-1234-example-edge-01.domain [{"effect":"NoExecute","key":"is_edge","value":"true"}]
# in this case TOLERATION_KEY has to be set to is_edge
NODE_AFFINITY:
  # ENABLED: set to true to use these node affinity settings
  ENABLED: true
  SERVER:
    KEY: is_worker
    VALUE: true
    # TOLERATION_KEY is required if a taint is applied on the node where server executes.
    # Leave TOLERATION_KEY blank if the node for SERVER.KEY value does not have a taint
    TOLERATION_KEY:
  JOBS:
    KEY: is_worker
    VALUE: true
    # TOLERATION_KEY is required if a taint is applied on the node where pods from jobs execute.
    # Leave TOLERATION_KEY blank if the node for JOBS.KEY value does not have a taint
    TOLERATION_KEY:

# RBAC enablement flag
RBAC_ENABLED: true
# Specify SA names if RBAC_ENABLED is false
SERVICE_ACCOUNT_APP: ""
SERVICE_ACCOUNT_BP: ""

SERVER_REPLICAS: 1
UI_REPLICAS: 1

# 'prod' or 'lab'
RESOURCE_PROFILE: prod

# NokiaMail session settings:
MAIL_HOST: 20.231.83.47
MAIL_PORT: 25
MAIL_FROM: noreply@labs-open-ecosystem.org

# Size of the diagnostic volume on each server
# A value of '0' disables this store (just '0', not '0Gi').
# If disabled then the internal storage is used, which will not survive restarts:
DIAGNOSTIC_VOLUME_SIZE: 32Gi

# The wildfly server global transaction timeout, given in seconds:
TRANSACTION_TIMEOUT_SECONDS: 600

# Backup and Restore options
CBUR:
  ENABLED: false
  COPIES: 3
  SCHEDULE:
    ENABLED: false
    CRONJOB: 0 0 * * *
  BACKEND_MODE: local
  DATA_ENCRYPTION: true

# The following properties should not be modified
CKEY_REALM_NAME: netguard

# GEO redundancy properties
GEO_REDUNDANCY_ENABLED: false
# Possible values for MODE parameter: active|passive
GEO_REDUNDANCY_MODE: active

# Support codeployment (ex. WAS, Workbench): true|false
SUPPORT_CODEPLOYMENT: true

NETGUARD_FRAMEWORK_SECRET: {{ uuidv4 }}
NETGUARD_WORKBENCH_SECRET: {{ uuidv4 }}

NOSDBPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
WORKBENCHDBPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
CKEYLISTENERCRMQPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}

# Global flag to control encryption key generation.
# If set to 'true' then the ENCRYPTION_PASSWORD field is used, as defined below.
# If set to 'false' then the legacy encryption key is used.
ENCRYPTION_KEY_GENERATION_ENABLED: false

# Encryption key password, used to encrypt sensitive internal data (including data stored in the database).
# - If this field is empty: a new password is generated during installation. NOTE: in this case, configuration
#   backup/restore is required to preserve/restore the encryption keys from previous installations.
# - If this field is populated: the given password is used to calculate a deterministic encryption key.
# Notes for Customers:
# - Customers should not in general set this value, instead preferring a generated value
#   (thus ensuring the password is always kept secret).
# - If this value is set, then this file should itself be encrypted or moved to a secure area after installation
ENCRYPTION_PASSWORD: ''
ENCRYPTION_VERSION: '20200000-1'
ENCRYPTION_VERSION_PREVIOUS: '20200000-1'
ENCRYPTION_PASSWORD_PREVIOUS: ''
