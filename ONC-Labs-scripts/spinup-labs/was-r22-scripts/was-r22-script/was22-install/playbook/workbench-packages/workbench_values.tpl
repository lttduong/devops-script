global:
  registry: {{ .IMAGE_REGISTRY }}
  BP_CONFIG_NAMESPACE: {{ .BP_CONFIG_NAMESPACE }}
  BP_NAMESPACE: {{ .BP_NAMESPACE }}
  BP_RELEASE_NAME_PREFIX: {{ .BP_RELEASE_NAME_PREFIX }}
  storageClass: {{ .BP_DEPLOYMENT_PROFILE_STORAGE }}
  APP_NAMESPACE: {{ .NAMESPACE }}
  ingressClass: {{ .INGRESS_CLASS }}
  app:
    name: workbench
    version: 22.2.28
  releaseNamePrefix: {{ .APP_RELEASE_NAME_PREFIX }}
  retainCkeyFrameworkClient: {{ .SUPPORT_CODEPLOYMENT }}
  imageTags:
    epsec/products/businessprocessautomationservice/bpas-workbench/certs-converter: "22.2.11"
    epsec/products/businessprocessautomationservice/bpas-workbench/ckey-config: "22.2.13"
    epsec/products/businessprocessautomationservice/bpas-workbench/cmdb-config: "22.2.7"
    epsec/products/businessprocessautomationservice/bpas-workbench/crmq-config: "22.2.6"
    epsec/products/businessprocessautomationservice/bpas-workbench/kubectl: "v1.24.2-rocky-nano-20220627"
    epsec/products/framework/propertyencrypter/epsec-propertyencrypter: "latest.22.3"
    epsec/products/framework/nos-dist/epsec-nos-dbschematool: "latest.22.3"
    epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench: "22.2.28"
    epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench-dbschematool: "22.2.28"
    epsec/products/businessprocessautomationservice/bpas-workbench-ui/epsec-bpas-workbench-ui: "22.2.8"

  delete_cert_job:
    resources:
      requests:
        cpu: "10m"
        memory: "50Mi"
      limits:
        cpu: "200m"
        memory: "300Mi"

  cbur:
    enabled: {{ .CBUR.ENABLED }}
    backendMode: {{ .CBUR.BACKEND_MODE }}
    maxiCopy: {{ .CBUR.COPIES }}
    cronSpec: "{{ .CBUR.SCHEDULE.CRONJOB }}"
  {{- if .GEO_REDUNDANCY_ENABLED }}
    autoEnableCron: {{ and .CBUR.SCHEDULE.ENABLED (eq .GEO_REDUNDANCY_MODE "active") }}
  {{- else }}
    autoEnableCron: {{ .CBUR.SCHEDULE.ENABLED }}
  {{- end }}
    dataEncryption: {{ .CBUR.DATA_ENCRYPTION }}
  certManager:
    api: "cert-manager.io/v1alpha2"
    duration: "8760h" # 365d
    renewBefore: "360h" # 15d
    keySize: "2048"
    issuerRef:
      # from bp_config_vars
    {{- if .CM_ISSUER_GROUP }}
      group: {{ .CM_ISSUER_GROUP}}
    {{- else}}
      group: "cert-manager.io"
    {{- end }}
    {{- if .CM_ISSUER_NAME }}
      name: {{ .CM_ISSUER_NAME }}
    {{- else}}
      name: "ncms-ca-issuer"
    {{- end }}
    {{- if .CM_ISSUER_KIND }}
      kind: {{ .CM_ISSUER_KIND }}
    {{- else}}
      kind: "ClusterIssuer"
    {{- end }}
  svcDnsDomain: svc.{{ .DNS_DOMAIN }}
  mariadbExternalName: "{{ .BP_RELEASE_NAME_PREFIX }}cmdb-mysql.{{ .BP_NAMESPACE }}.svc.{{ .DNS_DOMAIN }}"
  mariadbPort: 3306
  crmq:
    serviceName: "{{ .BP_RELEASE_NAME_PREFIX }}crmq-crmq.{{ .BP_NAMESPACE }}.svc.{{ .DNS_DOMAIN }}"
    port: "5671"    # 5672 for unencrypted, 5671 for ssl/tls
    useSsl: "true"
  elasticsearch:
    serviceName: "{{ .BP_RELEASE_NAME_PREFIX }}elasticsearch.{{ .BP_NAMESPACE }}.svc.{{ .DNS_DOMAIN }}"
    port: "9200"
  ckey:
    eventsTopicName: "ckey.topic"
    virtualHostName: "/"
  nosdbSecret: "nosdb-secret"
  workbenchdbSecret: "{{ .APP_RELEASE_NAME_PREFIX }}workbenchdb-secret"
  serverClusterServiceName: "{{ .APP_RELEASE_NAME_PREFIX }}na-server"
  serverClusterServiceHttpsPort: 8443
  sshConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}ssh-config"
  extendedPropertiesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}extended-properties"
  applicationPropertiesOverridesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}application-properties"
  adapterConfigOverridesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}adapter-config-overrides"
  serverConfigOverrideConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}server-config-override"
  helmHooks:
    secret:
      hook: "pre-install"
      weight: "-100"
    configmap:
      hook: "pre-install"
      weight: "-90"
    nosdbconfig:
      hook: "pre-install"
      weight: "-80"
    appdbconfig:
      hook: "pre-install"
      weight: "-70"
    nosdbschema:
      hook: "pre-install"
      weight: "-60"
    nrsdbschema:
      hook: "pre-install"
      weight: "-50"
    appdbschema:
      hook: "pre-install"
      weight: "-40"
    crmqconfig:
      hook: "pre-install"
      weight: "-30"
{{- if .NODE_AFFINITY.ENABLED }}
  jobNodeAffinityRuleTemplate: |
    affinity:
      # node-level affinity
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: {{ .NODE_AFFINITY.JOBS.KEY }}
              operator: In
              values:
              - {{ quote .NODE_AFFINITY.JOBS.VALUE }}
  {{- if .NODE_AFFINITY.JOBS.TOLERATION_KEY }}
    # Edge node has a taint setting that we must tolerate. We may not want this in all cases:
    tolerations:
    - key: "{{ .NODE_AFFINITY.JOBS.TOLERATION_KEY }}"
      operator: "Exists"
{{- end }}
{{- end }}
  # RBAC enablement flag
  rbac:
    enabled: {{ .RBAC_ENABLED }}
  # If set rbac.enabled to false, user can specify the pre-configured SA
  serviceAccountName: {{ .SERVICE_ACCOUNT_APP }}
  serviceAccountNameBP: {{ .SERVICE_ACCOUNT_BP }}

  kubectl:
    image:
      repo: epsec/products/businessprocessautomationservice/bpas-workbench/kubectl
      tag: v1.24.2-rocky-nano-20220627
  apiVersion: v1

  dns:
    domain: .svc.{{ .DNS_DOMAIN }}
    policy: ClusterFirst
  config:
    ckey:
      client:
        secret:
          netguardFrameworkSecret: {{ .NETGUARD_FRAMEWORK_SECRET }}
          workflowAutomationWorkbenchSecret: {{ .NETGUARD_WORKBENCH_SECRET }}
      configurator:
        resources:
          requests:
            cpu: "10m"
            memory: "50Mi"
          limits:
            cpu: "200m"
            memory: "300Mi"
        image:
          name: epsec/products/businessprocessautomationservice/bpas-workbench/ckey-config
          tag: 22.2.13
        secretName: {{ .BP_RELEASE_NAME_PREFIX }}ckey-configurator-config
        configDir: /import/config
        dataDir: /import/data
        certificatesDir: /certificates
        caCertFile: ca.crt
      realm: {{ .CKEY_REALM_NAME }}
      passwordPolicy: "forceExpiredPasswordChange(90) and passwordHistory(5) and upperCase(1) and lowerCase(1) and digits(1) and specialChars(1) and length(8) and regexPattern(^.{8,150}$)"
    cmdb:
      configurator:
        image:
          name: epsec/products/businessprocessautomationservice/bpas-workbench/cmdb-config
          tag: 22.2.7
        secretName: {{ .BP_RELEASE_NAME_PREFIX }}cmdb-configurator-config
        configMapName: {{ .BP_RELEASE_NAME_PREFIX }}cmdb-configurator-config-configmap
        configDir: /import/config
    crmq:
      configurator:
        image:
          name: epsec/products/businessprocessautomationservice/bpas-workbench/crmq-config
          tag: 22.2.6
        secretName: {{ .BP_RELEASE_NAME_PREFIX }}crmq-configurator-config
        configMapName: {{ .BP_RELEASE_NAME_PREFIX }}crmq-configurator-config-configmap

  #Extra SSL certs
  extraSslCerts:
    server: {{ .SERVER_EXTRA_SSL_CERTS }}

# Values for chart /nos-dist/bcmt-common-pure-helm/common/charts/ckey-config/
ckey-config:
  importConfig:
  {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
    enabled: false
  {{- else }}
    enabled: true
  {{- end }}
  secrets:
    workflowAutomationWorkbenchSecret:
      enabled: "true"
      secretName: "{{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret"
      secretValue: "{{ .NETGUARD_WORKBENCH_SECRET }}"
  realm: {{ .CKEY_REALM_NAME }}
  enableNA: false
  image:
    name: epsec/products/businessprocessautomationservice/bpas-workbench/ckey-config
    tag: 22.2.13

# Values for chart /nos-dist/bcmt-common-pure-helm/common/charts/db-configurator/
db-configurator:
  createDB:
  {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
    enabled: false
  {{- else }}
    enabled: true
  {{- end }}
  jobs:
    nosdb:
      enabled: "true"
      username: "workbenchnosdb"
      password: {{ .NOSDBPASSWORD }}
      secretName: "nosdb-secret"
      sqlFile: "config_files/nosdb.sql"
    workbenchdb:
      enabled: "true"
      username: "workbenchdb"
      password: {{ .WORKBENCHDBPASSWORD }}
      nosUsername: "workbenchnosdb"
      secretName: "workbenchdb-secret"
      sqlFile: "config_files/workbenchdb.sql"

# Values for chart /nos-dist/bcmt-common-pure-helm/common/charts/crmq-configurator/
crmq-configurator:
  virtualHostName: "/"
  users:
    ckeyListener:
      password: "{{ .CKEYLISTENERCRMQPASSWORD }}"

# Values for chart /nos-dist/bcmt-common-pure-helm/common/charts/server/
server:
{{- if (eq .RESOURCE_PROFILE "prod") }}
  resources:
    requests:
      memory: 12Gi
      cpu: 2000m
    limits:
      memory: 12Gi
      cpu: 8000m
    jvm:
      Xms: 4G
      Xmx: 8G
      MetaspaceSize: 96M
      MaxMetaspaceSize: 512M
      debugPort: 0
    config:
      enableconsole: "false"
{{- else if (eq .RESOURCE_PROFILE "lab") }}
  resources:
    requests:
      memory: 8Gi
      cpu: 500m
    limits:
      memory: 8Gi
      cpu: 2000m
    jvm:
      Xms: 512M
      Xmx: 4G
      MetaspaceSize: 96M
      MaxMetaspaceSize: 512M
      debugPort: 0
    config:
      enableconsole: "false"
{{- else if (eq .RESOURCE_PROFILE "devel") }}
  resources:
    requests:
      memory: 4Gi
      cpu: 500m
    limits:
      memory: 4Gi
      cpu: 1500m
    jvm:
      Xms: 512M
      Xmx: 2G
      MetaspaceSize: 96M
      MaxMetaspaceSize: 512M
      debugPort: 8787
    config:
      enableconsole: "true"
{{- end }}
{{- if .NODE_AFFINITY.ENABLED }}
  nodeAffinityRuleTemplate: |
    affinity:
      # node-level affinity
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: {{ .NODE_AFFINITY.SERVER.KEY }}
              operator: In
              values:
              - {{ quote .NODE_AFFINITY.SERVER.VALUE }}
      # pod-level anti-affinity
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          podAffinityTerm:
            labelSelector:
               matchExpressions:
                - key: app
                  operator: In
                  values:
                  - {{ .APP_RELEASE_NAME_PREFIX }}server
            topologyKey: kubernetes.io/hostname
{{- if .NODE_AFFINITY.SERVER.TOLERATION_KEY }}
    # Edge node has a taint setting that we must tolerate. We may not want this in all cases:
    tolerations:
    - key: "{{ .NODE_AFFINITY.SERVER.TOLERATION_KEY }}"
      operator: "Exists"
{{- end }}
{{- end }}
  certsConverter:
    # From the CSF site: If the Truststore password is "changeit", a random password is then generated
    # by the CJEE installation script, and used. No clear password can be found in the log files.
    jkspass: "changeit"
    inputdir: "/opt/nokia/config/certs-input"
    outputdir: "/opt/nokia/config/certs-generated"
    truststoreExtraCerts: "/opt/nokia/config/certs-extra"
    keystorefile: "/opt/nokia/config/certs-generated/keystore.jks"
    truststorefile: "/opt/nokia/config/certs-generated/truststore.jks"
    initContainersTemplate: |
      - name: certs-converter-init
        image: {{ .IMAGE_REGISTRY }}/epsec/products/businessprocessautomationservice/bpas-workbench/certs-converter:22.2.11
        imagePullPolicy: "IfNotPresent"
        securityContext:
          runAsUser: 1000
        command: ["certs_converter"]
        args: ["--certs-dir=/opt/nokia/config/certs-input",
               "--output=/opt/nokia/config/certs-generated",
               {{- if .SERVER_EXTRA_SSL_CERTS }}
               "--truststore-certs-dir=/opt/nokia/config/certs-extra",
               {{- end }}
               "--format=JKS",
               "--ks-pass=changeit",
               "--ts-pass=changeit"]
        volumeMounts:
          # Mount the certificates generated via templates/certificate.yaml as input to certs_converter:
          - name: "tls-secret"
            mountPath: "/opt/nokia/config/certs-input"
            readOnly: true
          # Mount the outputdir where the converted certs will be placed.
          # We will then mount the converted certs (JKS files) in the main container
          - name: "server-generated-certs"
            mountPath: "/opt/nokia/config/certs-generated"
          {{- if .SERVER_EXTRA_SSL_CERTS }}
          # Mount the directory containing extra certs, to be included in the final truststore file
          - name: "server-truststore-extra"
            mountPath: "/opt/nokia/config/certs-extra"
          {{- end }}
    volumesTemplate: |
      - name: "tls-secret"
        secret:
          secretName: "{{ .APP_RELEASE_NAME_PREFIX }}server-tls-secret"
      - name: "server-generated-certs"
        emptyDir: {}
      {{- if .SERVER_EXTRA_SSL_CERTS }}
      - name: "server-truststore-extra"
        configMap:
          name: {{ .APP_RELEASE_NAME_PREFIX }}server-truststore-extra
      {{- end }}
    volumeMountsTemplate: |
      - name: "server-generated-certs"
        mountPath: "/opt/nokia/config/certs-generated"

  propertyEncrypter:
    initContainersTemplate: |-
      - name: property-encrypter
        image: {{ .IMAGE_REGISTRY }}/epsec/products/framework/propertyencrypter/epsec-propertyencrypter:latest.22.3
        imagePullPolicy: "IfNotPresent"
        env:
          - name: SOURCE_SECRETS_DIR
            value: "/opt/nokia/config/plaintext"
          - name: ENCRYPTED_PROPS_FILE
            value: /opt/nokia/config/encrypted/encrypted.properties
          - name: ENCRYPTION_CONFIG_FILE
            value: /opt/nokia/config/encrypted/encrypter-config.properties
        volumeMounts:
          - name: encrypted-properties
            mountPath: "/opt/nokia/config/encrypted"
          - mountPath: /opt/nokia/config/plaintext/ckey-netguard-framework-client-secret/ckey.client.secret.framework
            name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret-volume
          - mountPath: /opt/nokia/config/plaintext/ckey-was-workbench-client-secret/ckey.client.secret.workflowAutomationWorkbench
            name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret-volume
          - mountPath: /opt/nokia/config/plaintext/ckey-listener-user-secret/messagebroker
            name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-listener-user-secret-volume
    volumesTemplate: |-
      - name: encrypted-properties
        emptyDir: {}
      - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret-volume
        secret:
          secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret
      - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret-volume
        secret:
          secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret
      - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-listener-user-secret-volume
        secret:
          secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-listener-user-secret
    volumeMountsTemplate: |-
      - mountPath: /opt/nokia/config/encryptedProperties
        name: encrypted-properties

  {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
  replicaCount: 0
  {{- else }}
  replicaCount: {{ .SERVER_REPLICAS }}
  {{- end }}
  diagnosticVolume:
    size: {{ .DIAGNOSTIC_VOLUME_SIZE }}
  dbConfig:
    transactionTimeoutSeconds: "{{ .TRANSACTION_TIMEOUT_SECONDS }}"
  dbschematool:
    image: "epsec/products/framework/nos-dist/epsec-nos-dbschematool"
    imageTag: latest.22.3
    {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
    operation: "skip"
    {{- else }}
    operation: {{ .NOS_DBSCHEMATOOL_OPERATION }}
    {{- end }}
    imagePullPolicy: "IfNotPresent"
    restartPolicy: "Never"
    requests:
      memory: 4Gi
      cpu: 1000m
    limits:
      memory: 4Gi
      cpu: 1500m
  encryptionKey:
    enabled: {{ .ENCRYPTION_KEY_GENERATION_ENABLED }}
    secretName: "encryptkey-secret"
    version: "{{ .ENCRYPTION_VERSION }}"
    password: "{{ .ENCRYPTION_PASSWORD }}"
    previous:
      version: "{{ .ENCRYPTION_VERSION_PREVIOUS }}"
      password: "{{ .ENCRYPTION_PASSWORD_PREVIOUS }}"
  mail:
    host: {{ .MAIL_HOST }}
    port: {{ .MAIL_PORT }}
    from: {{ .MAIL_FROM }}
  useDbConfigurator: true
  dbAccounts:
    - name: "nosdb"
      secretName: "nosdb-secret"
    - name: "workbenchdb"
      secretName: "workbenchdb-secret"
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench"
  imageTag: 22.2.28
  ingress:
    networkAccess:
      ui:
        enabled: false
      rest:
        enabled: false
      legacyrest:
        enabled: false
    workbench:
      rest:
        enabled: true
        maxBodySize: 100m
        limitConnections: 35
        limitRps: 35
        proxyReadTimeout: 600
        externalPath: "/was-workbench-rest/"
        internalPath: "/was-workbench-rest/"

  extraVolumeMounts: |-
    - name: workbench-keycloak
      mountPath: /opt/nokia/config/workbench-keycloak.json
      subPath: workbench-keycloak.json
  extraVolumes: |-
    - name: workbench-keycloak
      configMap:
        name: {{ .APP_RELEASE_NAME_PREFIX }}workbench-keycloak

# Workbench UI: see /bpas-workbench-dist/bcmt-pure-helm/workbench/charts/workbench/templates/ui-*.yaml
ui:
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-ui/epsec-bpas-workbench-ui"
  imageTag: 22.2.8
  imagePullPolicy: "IfNotPresent"
  {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
  replicaCount: 0
  {{- else }}
  replicaCount: {{ .UI_REPLICAS }}
  {{- end }}
  httpsPort: 8443
  httpPort: 8080
  ingress:
    path: "/was-workbench(/|$)"
    useRegex: true
    maxBodySize: 100m
    limitConnections: 35
    proxyReadTimeout: 600
    limitRps: 35
    useHttps: true
# UI resource profiles
{{- if (eq .RESOURCE_PROFILE "prod") }}
  resources:
    requests:
      memory: 8Gi
      cpu: 1000m
    limits:
      memory: 8Gi
      cpu: 4000m
{{- else if (eq .RESOURCE_PROFILE "lab") }}
  resources:
    requests:
      memory: 2Gi
      cpu: 500m
    limits:
      memory: 2Gi
      cpu: 1000m
{{- else if (eq .RESOURCE_PROFILE "devel") }}
  resources:
    requests:
      memory: 1Gi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 500m
{{- end }}

# Workbench dbschematool: see /bpas-workbench-dist/bcmt-pure-helm/workbench/charts/workbench/templates/workbench-dbschematool-job.yaml
dbschematool:
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench-dbschematool"
  imageTag: 22.2.28
  hookWeight: 20
  {{- if and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
  operation: "skip"
  {{- else }}
  operation: {{ .WORKBENCH_DBSCHEMATOOL_OPERATION }}
  {{- end }}
  restartPolicy: "Never"
  imagePullPolicy: "IfNotPresent"
  requests:
    memory: 4Gi
    cpu: 1000m
  limits:
    memory: 4Gi
    cpu: 1500m

# Used in bcmt-pure-helm/workbench/charts/workbench/templates/workbench-dbschematool-job.yaml
certsConverter:
  # From the CSF site: If the Truststore password is "changeit", a random password is then generated
  # by the CJEE installation script, and used. No clear password can be found in the log files.
  jkspass: "changeit"
  inputdir: "/opt/nokia/config/certs-input"
  outputdir: "/opt/nokia/config/certs-generated"
  truststoreExtraCerts: "/opt/nokia/config/certs-extra"
  keystorefile: "/opt/nokia/config/certs-generated/keystore.jks"
  truststorefile: "/opt/nokia/config/certs-generated/truststore.jks"
  initContainersTemplate: |
    - name: certs-converter-init
      image: {{ .IMAGE_REGISTRY }}/epsec/products/businessprocessautomationservice/bpas-workbench/certs-converter:22.2.11
      imagePullPolicy: "IfNotPresent"
      securityContext:
        runAsUser: 1000
      command: ["certs_converter"]
      args: ["--certs-dir=/opt/nokia/config/certs-input",
             "--output=/opt/nokia/config/certs-generated",
             "--format=JKS",
             "--ks-pass=changeit",
             "--ts-pass=changeit"]
      volumeMounts:
        # Mount the certificates generated via templates/certificate.yaml as input to certs_converter:
        - name: "tls-secret"
          mountPath: "/opt/nokia/config/certs-input"
          readOnly: true
        # Mount the outputdir where the converted certs will be placed.
        # We will then mount the converted certs (JKS files) in the main container
        - name: "server-generated-certs"
          mountPath: "/opt/nokia/config/certs-generated"
  volumesTemplate: |
    - name: "tls-secret"
      secret:
        secretName: "{{ .APP_RELEASE_NAME_PREFIX }}server-tls-secret"
    - name: "server-generated-certs"
      emptyDir: {}
  volumeMountsTemplate: |
    - name: "server-generated-certs"
      mountPath: "/opt/nokia/config/certs-generated"

# GEO redundancy: see /bpas-workbench-dist/bcmt-pure-helm/workbench/charts/workbench/templates/geo-redundancy-configmap.yaml
geoRedundancyEnabled: {{ .GEO_REDUNDANCY_ENABLED }}
geoRedundancyMode: {{ .GEO_REDUNDANCY_MODE }}
geoRedundancyEnabledPassive: {{ and .GEO_REDUNDANCY_ENABLED (eq .GEO_REDUNDANCY_MODE "passive") }}
