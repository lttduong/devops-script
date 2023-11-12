BP_NAMESPACE: netguard-base
BP_CONFIG_NAMESPACE: netguard-base
BP_RELEASE_NAME_PREFIX: "nbp-"

IMAGE_REGISTRY: "wasr22containerregistry.azurecr.io"
VERSION: 22.2.0

DNS_DOMAIN: "cluster.local"

#On NCS20 and EKS when docker is used, keep as it is, on NCS22 change to containerd
CONTAINER_RUNTIME: docker

#Set FRONTEND_FQDN to the FQDN of the external IP address for accessing the system
FRONTEND_FQDN: "108.142.133.66"

VIRTUAL_IP_ENABLED: false
# must match FRONTEND_FQDN if IPv4 address provided or
# must match IPv4 address of FQDN from FRONTEND_FQDN
VIRTUAL_IP_ADDRESS_IPV4: "IPv4"
# must match IPv6 address of FQDN from FRONTEND_FQDN
VIRTUAL_IP_ADDRESS_IPV6: "IPv6"
VIRTUAL_IP_INTERFACE: "eth0"
VIRTUAL_IP_VRRP_IPV4: 46
VIRTUAL_IP_VRRP_IPV6: 32

BP_DEPLOYMENT_PROFILE_CONFIGURATION: prod
BP_DEPLOYMENT_PROFILE_RESOURCES: main
BP_DEPLOYMENT_PROFILE_STORAGE: nfs-client

BP_BR_ENABLED: false
CBUR_NFS_SERVER_ADDRESS: 172.17.3.4
CBUR_NFS_SERVER_BACKUPS_PATH: /var/netguard-data
CBUR_CMDB_ENABLED: false
# Possible values for COPIES parameter: [1 - 10]
CBUR_CMDB_COPIES: 3
CBUR_CMDB_SCHEDULE_ENABLED: false
CBUR_CMDB_SCHEDULE_CRONJOB: 0 0 * * *
CBUR_BTEL_ENABLED: false
CBUR_BTEL_ELASTIC_BACKUPS_SUBPATH: elasticsearch-backup
CBUR_BTEL_ELASTIC_SNAPSHOTS_CLEANUP_INTERVAL_DAYS: 7
# Possible values for COPIES parameter: [1 - 10]
CBUR_BTEL_COPIES: 3
CBUR_BTEL_SCHEDULE_ENABLED: false
CBUR_BTEL_SCHEDULE_CRONJOB: 0 0 * * *
CBUR_CONFIG_SECRETS_ENABLED: false
# Possible values for COPIES parameter: [1 - 10]
CBUR_CONFIG_SECRETS_COPIES: 1
CBUR_CONFIG_SECRETS_SCHEDULE_ENABLED: false
CBUR_CONFIG_SECRETS_SCHEDULE_CRONJOB: 0 0 * * *

# Supported values: local, AWSS3, sftp
CBUR_BACKEND_MODE: local

CMDB_STORAGE_SIZE_GB: 626
BELK_DATA_STORAGE_SIZE_GB: 50
BELK_DATA_RETENTION_DAYS: 7
BELK_DATA_ARCHIVE_DAYS: 6
CPRO_STORAGE_SIZE_GB: 80
CPRO_RETENTION_SIZE_GB: 60
CPRO_RETENTION_TIME_DAYS: 15

INSTALL_SHARED_BELK: false
SHARED_BELK_CURATOR_SCHEDULE_CRONJOB: 0 3 * * *
SHARED_BELK_CLIENT_REPLICAS: 1
SHARED_BELK_DATA_REPLICAS: 1
SHARED_BELK_MASTER_REPLICAS: 1
SHARED_BELK_DATA_STORAGE_SIZE_GB: 50
SHARED_BELK_DATA_RETENTION_DAYS: 7
SHARED_BELK_DATA_ARCHIVE_DAYS: 6
SHARED_BELK_CBUR_ENABLED: false
SHARED_BELK_SNAPSHOTS_CLEANUP_INTERVAL_DAYS: 7
SHARED_BELK_BACKUPS_SUBPATH: shared-elasticsearch-backup
SHARED_BELK_CBUR_SCHEDULE_ENABLED: false
SHARED_BELK_CBUR_SCHEDULE_CRONJOB: 0 0 * * *
KIBANA_SERVICE_SHARED_ES_USER_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
SHARED_ES_NODE_PORT_OFFSET: 31
SHARED_ES_MASTER_PORT_OFFSET: 32
SHARED_KIBANA_NODE_PORT_OFFSET: 33
SHARED_ES_GR_RESTORE_SCHEDULE: 0 * * * *


LDAPS_CERT:

# SMTP server for alarm notification
EMAIL_SERVER_ID:
EMAIL_SERVER_HOST: 20.231.83.47
EMAIL_SERVER_PORT: 25
EMAIL_SERVER_AUTH:
EMAIL_SERVER_USERNAME:
EMAIL_SERVER_PASSWORD:
EMAIL_SERVER_FROM: noreply@labs-open-ecosystem.org
EMAIL_SERVER_TO:
EMAIL_SERVER_SEND_AS_HTML:
EMAIL_SERVER_TLS: false
EMAIL_SERVER_STARTTLS: false
EMAIL_SERVER_TRUSTCERT: false
EMAIL_SERVER_DESCRIPTION:

NETGUARD_ADMIN_PASSWORD: Admin123456!!!
# password for netguard realm admin user (at least one uppercase letter, one lowercase letter, one digit, one special character, minimum length: 8 characters, maximum length: 150 characters)

CKEY_EVENT_LISTENER_ENABLED: yes

# Comma separated list of Custom User Attributes (e.g. attribute1,atttribute2,attribute3)
CKEY_CUSTOM_USER_ATTRIBUTES: ""

# To be enabled only on the direction of Nokia Services
FINE_GRAINED_PERMISSIONS_ENABLED: false

# IPV4_ONLY (default), IPV4_DUALSTACK, IPV6_ONLY
NETWORK_STACK: IPV4_ONLY

INGRESS_CLASS: "netguard"
#INGRESS_CONTROLLER_KIND: Deployment
#INGRESS_CONTROLLER_REPLICAS: 2
#INGRESS_CONTROLLER_SERVICE_TYPE: ClusterIP
#INGRESS_CONTROLLER_SERVICE_ANNOTATIONS:
#- "service.beta.kubernetes.io/aws-load-balancer-internal: \"true\""
#- "service.beta.kubernetes.io/aws-load-balancer-type: nlb"

# Comma separated IP addresses on which ingress controller will accept requests
# If not specified, then ingress controller will listen on 0.0.0.0 for IPv4 and :: for IPv6
# VIP adresses can be specified as INGRESS_CONTROLLER_BIND_ADDRESSES if VIRTUAL_IP.ENABLED is set to 'true'
INGRESS_CONTROLLER_BIND_ADDRESSES: 172.17.3.4,172.17.3.5,108.142.133.66

GEO_REDUNDANCY_ENABLED: false
# Possible values for MODE parameter: active|passive
GEO_REDUNDANCY_MODE: active
# Possible values for SITE_INDEX parameter: 1|2
GEO_REDUNDANCY_SITE_INDEX: 1
GEO_REDUNDANCY_CMDB_REMOTE_DC_ADDRESS:
GEO_REDUNDANCY_BTEL_RESTORE_SCHEDULE: 0 * * * *

BP_INITIAL_NODE_PORT: 30000

#RABBITMQ_TLS_NODE_PORT: 30672
#RABBITMQ_MANAGEMENT_NODE_PORT: 30156
#RABBITMQ_PROMETHEUS_NODE_PORT: 30157
RABBITMQ_ADMIN_USERNAME: admin
RABBITMQ_ADMIN_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
RABBITMQ_ERLANG_COOKIE: {{ randAlphaNum 32 }}
RABBITMQ_SERVICE_TYPE: ClusterIP
RABBITMQ_SERVICE_ANNOTATIONS: []

#MARIADB_MASTER_NODE_PORT: 32426
#MAXSCALE_NODE_PORT: 30342
#NODE_EXPORTER_HOST_PORT: 9100

CMDB_MARIADB_MASTER_SERVICE_TYPE: ClusterIP
CMDB_MARIADB_MASTER_SERVICE_ANNOTATIONS: []
CMDB_MAXSCALE_SERVICE_TYPE: ClusterIP
CMDB_MAXSCALE_SERVICE_ANNOTATIONS: []

#The following parameter configures fluentd log filtering for multi-tenant environments, the filter must match the custom namespace name, if configured.  Change *netguard-admin-ns* to *your_custom_namespace*.  The default value is "/var/log/containers/*netguard-admin-ns*.log,/var/log/messages,/var/log/bcmt/apiserver/audit.log"
BTEL_LOG_FILTER: "/var/log/containers/*netguard-base*.log,/var/log/bcmt/apiserver/audit.log"

# The following parameter configures fluentd dockercontainers hostpath to access container logs.
# In AWS EKS use /var/lib/docker/containers
BTEL_DOCKER_LOG_HOSTPATH: "/data0/docker"


# The following parameters are auto-generated if not specified
KEYCLOAK_DB_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
KEYCLOAK_ADMIN_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
MARIADB_USER_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
MAXSCALE_USER_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
REPL_USER_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
METRICS_USER_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BASE_PLATFORM_SSO_SECRET: {{ uuidv4 }}
CMDB_ROOT_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}

# Enable usage of Keycloak customization. (This may brake some Keycloak functionalities)
ENABLE_KEYCLOAK_CUSTOMIZATION: false
KEYCLOAK_MASTER_ADMIN_SECRET: {{ uuidv4 }}
KEYCLOAK_NETGUARD_ADMIN_SECRET: {{ uuidv4 }}
KEYCLOAK_REALM_NAME: netguard
KEYCLOAK_EVENTS_EXPIRATION_SECONDS: 2592000
KEYCLOAK_ADMIN_EVENT_CLEANER_EXECUTION_PERIOD: 0
KEYCLOAK_ADMIN_EVENT_CLEANER_HISTORY: 10080
KEYCLOAK_CRMQ_PORT: 5671
KEYCLOAK_CRMQ_EXCHANGE_NAME: "ckey.topic"
KEYCLOAK_CRMQ_ROUTING_KEY: "user.security.events"
KEYCLOAK_CRMQ_USERNAME: ckey-user
KEYCLOAK_CRMQ_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}

LOGIN_SECURITY_BANNER: "You are about to access a private system. This system is for the use of authorized users only. All connections are logged. Any unauthorized access or access attempts may be punished to the fullest extent possible under the applicable local legislation."

# In AWS EKS use: https://kubernetes.default.svc
K8S_MASTER_API_SERVER_URL: "https://172.17.3.4:6443"

BTEL_CALM_REST_SERVICE_TYPE: NodePort
BTEL_CALM_REST_SERVICE_ANNOTATIONS: []
BTEL_CALM_SNMP_SERVICE_TYPE: NodePort
BTEL_CALM_SNMP_SERVICE_ANNOTATIONS: []

BTEL_BELK_ELASTICSEARCH_KEYSTORE_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_BELK_ELASTICSEARCH_TRUSTSTORE_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_CALM_MQ_PASSPHRASE: {{ randAlphaNum 16 }}
BTEL_CALM_MQ_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_CALM_MQ_PASSWORD_ENCRYPTED: "this value will be generated"
BTEL_GRAFANA_DB_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_DB_CALM_PASSPHRASE: {{ randAlphaNum 16 }}
BTEL_DB_CALM_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_DB_CALM_PASSWORD_ENCRYPTED: "this value will be generated"
BTEL_CALM_CNOT_PASSPHRASE: {{ randAlphaNum 16 }}
BTEL_CALM_CNOT_PASSWORD: {{ genPwd 14 20 0 0 0 0 "@%^" }}
BTEL_CALM_CNOT_PASSWORD_ENCRYPTED: "this value will be generated"
BTEL_CPRO_NODE_EXPORTER_ENABLED: false

# Configure SNMP version, This parameter can be SNMPv2 or SNMPv3, default is SNMPv3
SNMP_VERSION: SNMPv3

SNMPV3_USER_CONFIGURATION:
- userName: test1
  authPasswordEncrypted: "use fpm-password to encrypt authPassword with passPhrase"
  privPasswordEncrypted: "use fpm-password to encrypt privPassword with passPhrase"
  passPhrase: passphrase1
  context:

SNMPV2_USER_CONFIGURATION:
- securityName: sec1
  communityName: test11
  context: contexta

SNMP_NOTIFICATION_TARGETS_CONFIGURATION:
- notifyName: notify1
  notifyAddress: udp:127.0.0.1/162
  notifyIP: 127.0.0.1
  notifyPort: 162
  notifyParams: v3Params1
  notifyType: trap
  context:

SNMP_NOTIFICATION_PARAMETERS_CONFIGURATION:
- notifyParamsName: v3Params1
  notifyUser: test1
  notifySecurityModel: USM
  notifySecurityLevel: authPriv
  context:

SNMP_GROUP_CONFIGURATION:
- groupName: v3group1
  securityModel: USM
  userName: test1
  context:

SNMP_ACCESS_CONFIGURATION:
- groupName: v2cgroup1
  securityModel: SNMPv2c
  securityLevel: noAuthNoPriv
  readView: fullReadView
  writeView: fullWriteView
  notifyView: fullNotifyView
  context: contexta
- groupName: v3group1
  securityModel: USM
  securityLevel: authPriv
  readView: fullReadView
  writeView: fullWriteView
  notifyView: fullNotifyView

SNMP_VIEW_CONFIGURATION:
- viewName: fullReadView
  oid: 1.3
  context:
- viewName: fullWriteView
  oid: 1.3
  context:
- viewName: fullNotifyView
  oid: 1.3
  context:

# Configure node labels required for pods to use them
# https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set
# Labels for nodes accessible from outside the cluster
EDGE_NODE_LABEL_KEY: is_edge
EDGE_NODE_LABEL_VALUE: true

# Labels for nodes containing the components of the application workload
WORKER_NODE_LABEL_KEY: is_worker
WORKER_NODE_LABEL_VALUE: true

# Labels for nodes containing the components of the Kubernetes management processes
CONTROL_NODE_LABEL_KEY: is_control
CONTROL_NODE_LABEL_VALUE: true

# k8s tolerations for BTEL logs collection (fluentd) pods
BTEL_FLUENTD_TOLERATIONS:
- key: is_edge
  operator: "Equal"
  value: "true"
  effect: NoExecute

# k8s tolerations for BTEL metrics (node exporter) pods
BTEL_NODE_EXPORTER_TOLERATIONS:
- key: is_edge
  operator: "Equal"
  value: "true"
  effect: NoExecute
- key: is_control
  operator: "Equal"
  value: "true"
  effect: NoExecute

CM_ISSUER_NAME: ncms-ca-issuer
CM_ISSUER_KIND: ClusterIssuer
CM_ISSUER_GROUP: cert-manager.io

# Enable CBUR installation while deploying BP Core components
# Disable this on NCS environment if you want to use the global CBUR
CBUR_INSTALL: false

# Configure node labels required for CBUR to use them
# This parameter will be used for nodeSelector and affinity configuration
CBUR_NODE_LABEL_KEY: "is_worker"
CBUR_NODE_LABEL_VALUE: "true"

# Storage class used for CBUR temporary data. This can be different from the
# BP_DEPLOYMENT_PROFILE_STORAGE. 
CBUR_STORAGE_CLASS: nfs-client

# Set CBUR_S3_REGION to a sepcific region if you want to use different
# (from where the environment is running) region
CBUR_S3_REGION: ""

# Set to a predefined S3 bucket. Mandatory when CBUR_BACKEND_MODE is set to AWSS3 
CBUR_S3_BUCKET: ""

# Set to a predefined S3 bucket for Elastic backup.
# When it is set to the same as CBUR_S3_BUCKET, set CBUR_ELASTIC_S3_FOLDER as well
# Mandatory when CBUR_BACKEND_MODE is set to AWSS3 
CBUR_ELASTIC_S3_BUCKET: ""

# Folder to save Elasticsearch backup in CBUR_ELASTIC_S3_BUCKET bucket
CBUR_ELASTIC_S3_FOLDER: ""

# CBUR will mount it as "/BACKUP" volume.
# The "/BACKUP" volume is used as a temporary storage when backup/restore application
# data to/from third-party storage server.
CBUR_STORAGE_BACKUP: "2Gi"

# CBUR will mount it as "/CBUR_REPO" volume.
# The "/CBUR_REPO" volume is used as the local storage.
# When BACKEND MODE is "local", the data is saved here.
CBUR_STORAGE_REPO: "8Gi"

# Change tolerations if you have different nodes in the environment
CBUR_TOLERATIONS:
- effect: NoExecute
  key: is_control
  operator: Equal
  value: "true"
- effect: NoExecute
  key: is_edge
  operator: Equal
  value: "true"
- effect: NoExecute
  key: is_storage
  operator: Equal
  value: "true"

