global:
  registry: {{ .IMAGE_REGISTRY }}
  BP_CONFIG_NAMESPACE: {{ .BP_CONFIG_NAMESPACE }}
  BP_NAMESPACE: {{ .BP_NAMESPACE }}
  BP_RELEASE_NAME_PREFIX: {{ .BP_RELEASE_NAME_PREFIX }}
  storageClass: {{ .BP_DEPLOYMENT_PROFILE_STORAGE }}
  APP_NAMESPACE: {{ .NAMESPACE }}
  APP_VERSION: 0.0.525
  ingressClass: {{ .INGRESS_CLASS }}
  release:
    name: workbench
  releaseNamePrefix: {{ .APP_RELEASE_NAME_PREFIX }}
  imageTags:
    certs-converter: "21.0.2"
    cmdb-config: "21.0.1"
    crmq-config: "21.0.1"
    epsec/products/framework/propertyencrypter/epsec-propertyencrypter: "0.0.275"
    epsec/products/framework/nos-dist/epsec-nos-dbschematool: "0.0.3276"
    epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench: "0.0.525"
    epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench-dbschematool: "0.0.525"
    epsec/products/businessprocessautomationservice/bpas-workbench-ui/epsec-bpas-workbench-ui: "REPLACE-VERSION-bpas-workbench-ui/epsec-bpas-workbench-ui-REPLACE"

  delete_cert_job:
    resources:
      requests:
        cpu: "10m"
        memory: "50Mi"
      limits:
        cpu: "200m"
        memory: "300Mi"

  # NSMA-3455: build a combined list of egde addresses/FQDNs. ckeyAdapterAddresses is used to populate the json realm-urls for SMC keycloak adapter
  {{- $addrs := (list (.ACCESS_FQDNS | join ",") (.ACCESS_IPS | join ",") | join ",") | splitList "," | compact | uniq }}
  ckeyAdapterAddresses: ['"https://{{ .BP_RELEASE_NAME_PREFIX }}ckey-ckey.{{ .BP_NAMESPACE }}.svc.{{ .DNS_DOMAIN }}:8443", {{- range $i, $addr := $addrs }}
      {{ printf "https://%s" $addr | quote }}
        {{- if (ne $i (sub (len $addrs) 1)) }},{{- end }}
    {{- end }}']

  cbur:
    enabled: {{ .CBUR.ENABLED }}
    backendMode: {{ .CBUR.BACKEND_MODE }}
    maxiCopy: {{ .CBUR.COPIES }}
    cronSpec: "{{ .CBUR.SCHEDULE.CRONJOB }}"
    autoEnableCron: {{ .CBUR.SCHEDULE.ENABLED }}
    dataEncryption: {{ .CBUR.DATA_ENCRYPTION }}
  certManager:
    api: "cert-manager.io/v1alpha2"
    duration: "8760h" # 365d
    renewBefore: "360h" # 15d
    keySize: "2048"
    issuerRef:
      name: ncms-ca-issuer
      kind: ClusterIssuer
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
  nosdbSecret: "{{ .APP_RELEASE_NAME_PREFIX }}nosdb-secret"
  workbenchdbSecret: "{{ .APP_RELEASE_NAME_PREFIX }}workbenchdb-secret"
  serverClusterServiceName: "{{ .APP_RELEASE_NAME_PREFIX }}na-server"
  serverClusterServiceHttpsPort: 8443
  sshConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}ssh-config"
  extendedPropertiesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}extended-properties"
  applicationPropertiesOverridesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}application-properties"
  adapterConfigOverridesConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}adapter-config-overrides"
  serverConfigOverrideConfigMapName: "{{ .APP_RELEASE_NAME_PREFIX }}server-config-override"
  caCertSecret: "netguard-ca"
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
      repo: tools/kubectl
      tag: v1.14.10-nano
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
          name: ckey-config
          tag: 21.0.1
        secretName: ckey-configurator-config
        configDir: /import/config
        dataDir: /import/data
        certificatesDir: /certificates
        caCertFile: ca.crt
      realm: netguard
      passwordPolicy: "forceExpiredPasswordChange(90) and passwordHistory(5) and upperCase(1) and lowerCase(1) and digits(1) and specialChars(1) and length(8) and regexPattern(^.{8,150}$)"
    cmdb:
      configurator:
        image:
          name: cmdb-config
          tag: 21.0.1
        secretName: cmdb-configurator-config
        configMapName: cmdb-configurator-config-configmap
        configDir: /import/config
    crmq:
      configurator:
        image:
          name: crmq-config
          tag: 21.0.1
        secretName: crmq-configurator-config
        configMapName: crmq-configurator-config-configmap

  #Extra SSL certs
  extraSslCerts:
    server: "{{ .SERVER_EXTRA_SSL_CERTS }}"

ckey-config:
  secrets:
    workflowAutomationWorkbenchSecret:
      enabled: "true"
      secretName: "{{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret"
      secretValue: "{{ .NETGUARD_WORKBENCH_SECRET }}"
  realm: {{ .CKEY_REALM_NAME }}
  enableNA: false
  image:
    nameAndTag: "{{ .IMAGE_REGISTRY }}/ckey-config:21.0.1"

db-configurator:
  jobs:
    nosdb:
      enabled: "true"
      username: "workbenchnosdb"
      password: {{ .NOSDBPASSWORD }}
      secretName: "{{ .APP_RELEASE_NAME_PREFIX }}nosdb-secret"
      sqlFile: "config_files/nosdb.sql"
    workbenchdb:
      enabled: "true"
      username: "workbenchdb"
      password: {{ .WORKBENCHDBPASSWORD }}
      nosUsername: "workbenchnosdb"
      secretName: "{{ .APP_RELEASE_NAME_PREFIX }}workbenchdb-secret"
      sqlFile: "config_files/workbenchdb.sql"

crmq-configurator:
  virtualHostName: "/"
  users:
    ckeyListener:
      password: "{{ .CKEYLISTENERCRMQPASSWORD }}"

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
{{- end }}
{{- if (eq .RESOURCE_PROFILE "lab") }}
  resources:
    requests:
      memory: 8Gi
      cpu: 500m
    limits:
      memory: 12Gi
      cpu: 2000m
    jvm:
      Xms: 512M
      Xmx: 4G
      MetaspaceSize: 96M
      MaxMetaspaceSize: 512M
      debugPort: 0
    config:
      enableconsole: "false"
{{- end }}
{{- if (eq .RESOURCE_PROFILE "devel") }}
  resources:
    requests:
      memory: "1024Mi"
      cpu: "500m"
    limits:
      memory: "4096Mi"
      cpu: "1500m"
    jvm:
      Xms: 512M
      Xmx: 2G
      MetaspaceSize: 96M
      MaxMetaspaceSize: 512M
      debugPort: 8787
    config:
      enableconsole: "false"
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
        image: {{ .IMAGE_REGISTRY }}/certs-converter:21.0.2
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
        image: {{ .IMAGE_REGISTRY }}/epsec/products/framework/propertyencrypter/epsec-propertyencrypter:0.0.275
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
    volumesTemplate: |-
      - name: encrypted-properties
        emptyDir: {}
      - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret-volume
        secret:
          secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret
      - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret-volume
        secret:
          secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret
    volumeMountsTemplate: |-
      - mountPath: /opt/nokia/config/encryptedProperties
        name: encrypted-properties

  replicaCount: {{ .SERVER_REPLICAS }}
  diagnosticVolume:
    size: {{ .DIAGNOSTIC_VOLUME_SIZE }}
  dbConfig:
    transactionTimeoutSeconds: "{{ .TRANSACTION_TIMEOUT_SECONDS }}"
  dbschematool:
    image: "epsec/products/framework/nos-dist/epsec-nos-dbschematool"
    imageTag: 0.0.3276
    operation: {{ .NOS_DBSCHEMATOOL_OPERATION }}
    imagePullPolicy: "IfNotPresent"
    restartPolicy: "Never"
    requests:
      memory: "1024Mi"
      cpu: "1000m"
    limits:
      memory: "4096Mi"
      cpu: "1500m"
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

  # workbench server values
  useDbConfigurator: true
  dbAccounts:
    - name: "nosdb"
      secretName: "nosdb-secret"
    - name: "workbenchdb"
      secretName: "workbenchdb-secret"
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench"
  imageTag: 0.0.525
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

propertyEncrypter:
  initContainersTemplate: |-
    - name: property-encrypter
      image: {{ .IMAGE_REGISTRY }}/epsec/products/framework/propertyencrypter/epsec-propertyencrypter:0.0.275
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
  volumesTemplate: |-
    - name: encrypted-properties
      emptyDir: {}
    - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret-volume
      secret:
        secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-netguard-framework-client-secret
    - name: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret-volume
      secret:
        secretName: {{ .APP_RELEASE_NAME_PREFIX }}ckey-was-workbench-client-secret
  volumeMountsTemplate: |-
    - mountPath: /opt/nokia/config/encryptedProperties
      name: encrypted-properties

# workbench ui
ui:
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-ui/epsec-bpas-workbench-ui"
  imageTag: 0.0.195
  imagePullPolicy: "IfNotPresent"
  replicaCount: {{ .UI_REPLICAS }}
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

# workbench dbschematool
dbschematool:
  image: "epsec/products/businessprocessautomationservice/bpas-workbench-dist/epsec-bpas-workbench-dbschematool"
  imageTag: 0.0.525
  hookWeight: 20
  operation: {{ .WORKBENCH_DBSCHEMATOOL_OPERATION }}
  restartPolicy: "Never"
  imagePullPolicy: "IfNotPresent"
  requests:
    memory: 1024Mi
    cpu: 1000m
  limits:
    memory: 4096Mi
    cpu: 1500m

# see bcmt-pure-helm/workbench/charts/workbench/templates/workbench-dbschematool-job.yaml
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
      image: {{ .IMAGE_REGISTRY }}/certs-converter:21.0.2
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
