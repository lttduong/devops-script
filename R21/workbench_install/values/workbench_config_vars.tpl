---
NAMESPACE: netguard-workbench
APP_RELEASE_NAME_PREFIX: "waswb-"
BP_RELEASE_NAME_PREFIX: ""
APP_RELEASE_NAME_PREFIX: ""
DNS_DOMAIN: "cluster.local"
BP_NAMESPACE: netguard-base
BP_CONFIG_NAMESPACE: netguard-configuration
IMAGE_REGISTRY: wasr21containerregistry.azurecr.io
INGRESS_CLASS: "netguard"
BP_DEPLOYMENT_PROFILE_STORAGE: "default"


# One of 'schema' or 'upgrade'
NOS_DBSCHEMATOOL_OPERATION: schema
WORKBENCH_DBSCHEMATOOL_OPERATION: schema

# EXTRA SSL CERTIFICATE(S)
# Make sure that file servercerts.pem exists in the current directory from where you execute ncmptl command (dictated by ncmptl fileExists requirement.
# In case of multiple extra cert files, please append all the certs in single servercerts.pem.
SERVER_EXTRA_SSL_CERTS: {{ if fileExists "servercerts.pem" }} {{ "servercerts.pem" | b64file }} {{ else }} "" {{ end }}

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

# Controls if the Keycloak configuration will be imported as part of the install process
IMPORT_KEYCLOAK_CONFIG: true

# NokiaMail session settings:
MAIL_HOST: mailrelay.int.nokia.com
MAIL_PORT: 25
MAIL_FROM: noreply@nokia.com

# Size of the diagnostic volume on each server
# A value of '0' disables this store (just '0', not '0Gi').
# If disabled then the internal storage is used, which will not survive restarts:
DIAGNOSTIC_VOLUME_SIZE: 32Gi

# Path to the directory containing the custom configuration files.
# The directory structure can be copied from the packages files/config_dir_template directory
CUSTOM_CONFIG_DIR_PATH:

# Path to the SSH private key used for public key authentication to NEs and file servers
SSH_PRIVATE_KEY_PATH:

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
ENCRYPTION_PASSWORD:

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
HELM_PATH: /exec/helm3
KUBECTL_PATH: kubectl

NETGUARD_FRAMEWORK_SECRET: {{ uuidv4 }}
NETGUARD_WORKBENCH_SECRET: {{ uuidv4 }}

NOSDBPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
WORKBENCHDBPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
CKEYLISTENERCRMQPASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}

ENCRYPTION_VERSION: '20200000-1'
ENCRYPTION_PASSWORD: ''
ENCRYPTION_VERSION_PREVIOUS: '20200000-1'
ENCRYPTION_PASSWORD_PREVIOUS: ''
