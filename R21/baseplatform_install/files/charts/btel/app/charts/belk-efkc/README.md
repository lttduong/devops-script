## belk-ekfc chart
BELK is a Blueprint for ELasticsearch, Fluentd , Kibana and Curator . It gives you the power of real-time data insights, with the ability to perform super-fast data extractions from virtually all structured or unstructured data sources.
EFKC chart consists of below components.
-   Elasticsearch : Elasticsearch allows to store, search, and analyze huge volumes of data quickly in real-time and give back answers in milliseconds.
-   Fluentd : Fluentd is a data collector for unified logging layer. It allows you to unify data collection and consumption for a better use and understanding of data.
-  Kibana : Kibana provides search and data visualization capabilities for data indexed in Elasticsearch.
-  Curator : helps you curate, or manage, your Elasticsearch indices and snapshots.

### Pre Requisites:

1. Kubernetes 1.12+
2. Helm 2.12+ or Helm 3.0-beta3+
3. PV provisioner support in the underlying infrastructure

### Installing the Chart

1. Add the stable repo
```
helm repo add csf-stable https://repo.lab.pl.alcatel-lucent.com/csf-helm-stable/
```
2. To install the chart with the release name `my-release` in `logging` namespace
```
helm install --name my-release csf-stable/belk-efkc --version <version> --namespace logging
```
The command deploys belk chart on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete --purge my-release

```
The command removes all the kubernetes components associated with the chart and deletes the release.

### Parameters:
The following table lists the configurable parameters of the Elasticsearch chart and their default values.

| Parameter                           | Description                                   | Default                            |
| ----------------------------------- | ----------------------------------------------| ---------------------------------------------------------- |
|`global.registry`|Global Docker image registry for belk image|`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`|
|`global.registry1`|Global Docker image registry for kubectl and cbura images|`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. Ex. 1.4/1.5|`1.4`|
|`global.rbac.enabled`|Enable/disable rbac. When the flag is set to true, chart creates rbac objects if pre-created serviceaccount is not configured at global/chart level. When the flag is set to false, it is mandatory to configure a pre-created service-account at global/chart level|`true`|
|`global.serviceAccountName`|Pre-created ServiceAccountName defined at global level|`null`|
|`tags.belk-fluentd`|Enable/disable fluentd components of umbrella chart |`true`|
|`tags.belk-elasticsearch`|Enable/disable elasticsearch components of umbrella chart |`true`|
|`tags.belk-kibana`|Enable/disable kibana components of umbrella chart |`true`|
|`tags.belk-curator`|Enable/disable curator components of umbrella chart |`true`|
|`belk-fluentd.fluentd.resources`|CPU/Memory resource requests/limits for fluentd pod|`resources:  limits:  cpu: "1"  memory: "1Gi"  requests:  cpu: "600m" memory: "500Mi"`|
|`belk-fluentd.fluentd.EnvVars.system`|Configure system name for non-container log messages|`BCMT`|
|`belk-fluentd.fluentd.EnvVars.systemId`|Configure system id for non-container log messages|`BCMT ID`|
|`belk-fluentd.fluentd.enable_root_privilege`|Enable root privilege to read container, journal logs|`true`|
|`belk-fluentd.fluentd.kind`       |Configure fluentd kind like Deployment,DaemonSet,Statefulset          |`DaemonSet`|
|`belk-fluentd.fluentd.replicas`       |Desired number of fluentd replicas when the kind is Deployment or Statefulset         |`1`|
|`belk-fluentd.fluentd.serviceAccountName`       |Pre-created ServiceAccount specifically for fluentd chart. SA specified here takes precedence over the SA specified in global.           |`null`|
|`belk-fluentd.fluentd.securityContext.privileged`       |set privileged as true when docker_selinux is enabled on BCMT to read /var/log/messages|`false`|
|`belk-fluentd.fluentd.securityContext.fsGroup` |Group ID for the container|`998`|
|`belk-fluentd.fluentd.securityContext.supplementalGroups`       |SupplementalGroups ID applies to shared storage volumes          |`998`|
|`belk-fluentd.fluentd.securityContext.seLinuxOptions`       |provision to configure selinuxoptions for fluentd container |`default value is commented`|
|`belk-fluentd.fluentd.custom.annotations`       |Fluentd pod annotations          |`{}`|
|`belk-fluentd.fluentd.fluentd_certificates.enabled`|Enable certificates for ssl communication |`false`|
|`belk-fluentd.fluentd.fluentd_certificates.data.prometheus-crt.pem`|Configure prometheus crt in base 64 format for ssl communication|`null`|
|`belk-fluentd.fluentd.fluentd_certificates.data.prometheus-key.pem`|Configure prometheus key in base 64 format for ssl communication|`null`|
|`belk-fluentd.fluentd.fluentd_certificates.data.prometheus-root-ca.pem`|Configure prometheus root ca in base 64 format for ssl communication|`null`|
|`belk-fluentd.fluentd.fluentd_certificates.data.es-root-ca.pem`|Configure elasticsearch root ca in base 64 format for ssl communication|`null`|
|`belk-fluentd.fluentd.service.enabled`|Enable fluentd service|`false`|
|`belk-fluentd.fluentd.service.custom_name`|Configure fluentd custom service name |`null`|
|`belk-fluentd.fluentd.service.type`|Kubernetes service type|`ClusterIP`|
|`belk-fluentd.fluentd.service.metricsPort`|fluentd-prometheus-plugin port|`24231`|
|`belk-fluentd.fluentd.service.annotations`|fluentd service annotations|`{}`|
|`belk-fluentd.fluentd.forward_service.enabled`|Enable fluentd forward service|`false`|
|`belk-fluentd.fluentd.forward_service.custom_name`|Configure fluentd custom forwarder service name|`null`|
|`belk-fluentd.fluentd.forward_service.port`|Fluentd forward service port|`24224`|
|`belk-fluentd.fluentd.forward_service.type`|Kubernetes service type|`ClusterIP`|
|`belk-fluentd.fluentd.forward_service.annotations`|fluentd forward service annotations|`{}`|
|`belk-fluentd.fluentd.volume_mount_enable`|Enable volume mount for fluentd pod|`true`|
|`belk-fluentd.fluentd.volumes`|Mount volume  for fluentd pods|`/var/log and /data0/docker volumes of hostpath are mounted`|
|`belk-fluentd.fluentd.volumeMounts`|Location to mount the above volumes inside the container| `Above volumes are mounted to /var/log and /data0/docker locations inside the container`|
|`belk-fluentd.fluentd.nodeSelector`|Node labels for fluentd pod assignment|`{}`|
|`belk-fluentd.fluentd.tolerations`|List of node taints to tolerate (fluentd pods)|`[]`|
|`belk-fluentd.fluentd.affinity`|Fluentd pod anti-affinity policy|`{}`|
|`belk-fluentd.fluentd.podLabels`|Set the podLabels parameter as key-value pair |`null`|
|`belk-fluentd.fluentd.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated|`30`|
|`belk-fluentd.fluentd.livenessProbe.periodSeconds`|How often to perform the probe|`10`|
|`belk-fluentd.fluentd.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated|`30`|
|`belk-fluentd.fluentd.readinessProbe.periodSeconds`|How often to perform the probe|`10`|
|`belk-fluentd.fluentd.persistence.storageClassName`|Persistent Volume Storage Class for fluentd persistence. Applicable only when kind is StatefulSet. When configured as "" , it picks the default storage class configured in the BCMT cluster.|`null`|
|`belk-fluentd.fluentd.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`belk-fluentd.fluentd.persistence.size`|Persistent Volume Size|`10Gi`|
|`belk-fluentd.fluentd.persistence.pvc_auto_delete`|Persistent Volume auto delete when chart is deleted |`false`|
|`belk-fluentd.fluentd.fluentd_config`|Fluentd configuration to read data. Configurable values are belk, clog-json,clog-journal,custom-value|`belk`|
|`belk-fluentd.fluentd.configFile`|`If own configuration for fluentd other than provided by belk/clog then set fluentd_config: custom-value and provide the configuration here'| `null`|
|`belk-fluentd.cbur.enabled`|Enable cbur for backup and restore operation|`true`|
|`belk-fluentd.cbur.maxcopy`|Maxcopy of backup files to be stored|`5`|
|`belk-fluentd.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`belk-fluentd.cbur.cronJob`|Configure cronjob timings to take backup|`0 23 * * *`|
|`belk-fluentd.cbur.autoEnableCron`|AutoEnable Cron property to take backup as per configured cronjob|`true`|
|`belk-fluentd.cbur.autoUpdateCron`|AutoUpdate cron to update cron job timings|`false`|
|`belk-fluentd.istio.enabled`|Enable istio using this flag|`false`|
|`belk-fluentd.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`belk-fluentd.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`belk-fluentd.customResourceNames.fluentdPod.fluentdContainerName`         | Name for fluentd pod's container                    | `null` |
|`belk-fluentd.customResourceNames.scaleinJob.name`         | Name for fluentd scalein job                    | `null` |
|`belk-fluentd.customResourceNames.scaleinJob.postscaleinContainerName`         | Name for fluentd scalein job's container                   | `null` |
|`belk-fluentd.customResourceNames.deletePvcJob.name`         | Name for fluentd delete PVC job                    | `null` |
|`belk-fluentd.customResourceNames.deletePvcJob.deletePvcContainerName`         | Name for fluentd delete pvc job's container                   | `null` |
|`belk-fluentd.nameOverride`         | Use this to override name for fluentd deployment/sts/deamonset kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`belk-fluentd.fullnameOverride`         | Use this to configure custom-name for fluentd deployment/sts/deamonset kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`belk-elasticsearch.elasticsearch_master.image.repo`|Elasticsearch image name. Accepted values are elk_e and elk_e_cos7 |`elk_e_cos7`|
|`belk-elasticsearch.elasticsearch_master.replica`|Desired number of elasticsearch master node replicas|`3`|
|`belk-elasticsearch.elasticsearch_master.resources`|CPU/Memory resource requests/limits for master pod|`limits:       cpu: "1"      memory: "2Gi"     requests:       cpu: "500m"       memory: "1Gi"`|
|`belk-elasticsearch.elasticsearch_master.es_java_opts`|Environment variable for setting up JVM options|` Xms1g  Xmx1g`|
|`belk-elasticsearch.elasticsearch_master.discovery_service`|Helps to form the elasticsearch cluster by discovering nodes|`elasticsearch-discovery`|
|`belk-elasticsearch.elasticsearch_master.antiAffinity`|Master pod anti-affinity policy|`soft`|
|`belk-elasticsearch.elasticsearch_master.podAffinity`|Master pod affinity (in addition to master.antiAffinity when set)|`{}`|
|`belk-elasticsearch.elasticsearch_master.nodeAffinity`|Master node affinity (in addition to master.antiAffinity when set)|`{}`|
|`belk-elasticsearch.elasticsearch_master.nodeSelector`|master node labels for pod assignment|`{}`|
|`belk-elasticsearch.elasticsearch_master.tolerations`|List of node taints to tolerate for (master)|`[]`|
|`belk-elasticsearch.elasticsearch_master.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (master)|`30`|
|`belk-elasticsearch.elasticsearch_master.livenessProbe.periodSeconds`|How often to perform the probe (master)|`10`|
|`belk-elasticsearch.elasticsearch_master.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (master)|`30`|
|`belk-elasticsearch.elasticsearch_master.readinessProbe.periodSeconds`|How often to perform the probe (master)|`10`|
|`belk-elasticsearch.elasticsearch_master.podManagementPolicy`|Master statefulset parallel pod management policy |`Parallel`|
|`belk-elasticsearch.elasticsearch_master.updateStrategy.type`|Master statefulset update strategy policy|`RollingUpdate`|
|`belk-elasticsearch.elasticsearch_master.podLabels`|Customized labels to master pods|`null`|
|`belk-elasticsearch.elasticsearch_client.replicas`|Desired number of elasticsearch client node replicas|`3`|
|`belk-elasticsearch.elasticsearch_client.resources`|CPU/Memory resource requests/limits for client pod|`limits:       cpu: "1"       memory: "4Gi"     requests:       cpu: "500m"       memory: "2Gi"`|
|`belk-elasticsearch.elasticsearch_client.es_java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`belk-elasticsearch.elasticsearch_client.antiAffinity`|Client pod anti-affinity policy|`soft`|
|`belk-elasticsearch.elasticsearch_client.podAffinity`|Client pod affinity (in addition to client.antiAffinity when set)|`{}`|
|`belk-elasticsearch.elasticsearch_client.nodeAffinity`|Client node affinity (in addition to client.antiAffinity when set)|`{}`|
|`belk-elasticsearch.elasticsearch_client.nodeSelector`|Client node labels for pod assignment|`{}`|
|`belk-elasticsearch.elasticsearch_client.tolerations`|List of node taints to tolerate for (client)|`[]`|
|`belk-elasticsearch.elasticsearch_client.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (client)|`90`|
|`belk-elasticsearch.elasticsearch_client.livenessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`belk-elasticsearch.elasticsearch_client.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (client)|`90`|
|`belk-elasticsearch.elasticsearch_client.readinessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`belk-elasticsearch.elasticsearch_client.podLabels`|Customized labels to client pods|`null`|
|`belk-elasticsearch.esdata.replicas`|Desired number of elasticsearch data node replicas|`2`|
|`belk-elasticsearch.esdata.resources`|CPU/Memory resource requests/limits for data pod|`limits:       cpu: "1"       memory: "4Gi"     requests:       cpu: "500m"       memory: "2Gi"`|
|`belk-elasticsearch.esdata.es_java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`belk-elasticsearch.esdata.podManagementPolicy`|Data statefulset parallel pod management policy |`Parallel`|
|`belk-elasticsearch.esdata.updateStrategy.type`|Data statefulset update strategy policy|`RollingUpdate`|
|`belk-elasticsearch.esdata.antiAffinity`|Data pod anti-affinity policy|`soft`|
|`belk-elasticsearch.esdata.podAffinity`|Data pod affinity (in addition to esdata.antiAffinity when set)|`{}`|
|`belk-elasticsearch.esdata.nodeAffinity`|Data node affinity (in addition to esdata.antiAffinity when set)|`{}`|
|`belk-elasticsearch.esdata.nodeSelector`|Data node labels for pod assignment|`{}`|
|`belk-elasticsearch.esdata.tolerations`|List of node taints to tolerate for (data)|`[]`|
|`belk-elasticsearch.esdata.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (data)|`30`|
|`belk-elasticsearch.esdata.livenessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`belk-elasticsearch.esdata.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (data)|`30`|
|`belk-elasticsearch.esdata.readinessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`belk-elasticsearch.esdata.podLabels`|Customized labels to data pods|`null`|
|`belk-elasticsearch.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`belk-elasticsearch.customResourceNames.masterPod.masterContainerName`         | Name for elasticsearch master pod's container                    | `null` |
|`belk-elasticsearch.customResourceNames.dataPod.dataContainerName`         | Name for elasticsearch data pod's container                    | `null` |
|`belk-elasticsearch.customResourceNames.clientPod.clientContainerName`         | Name for elasticsearch client pod's container                    | `null` |
|`belk-elasticsearch.customResourceNames.postScaleInJob.name`         | Name for es post-scalein job                    | `null` |
|`belk-elasticsearch.customResourceNames.postScaleInJob.postScaleInContainerName`         | Name for es post-scalein job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.preUpgradeSgMigrateJob.name`         | Name for es pre-upgradeSgMigrate job                    | `null` |
|`belk-elasticsearch.customResourceNames.preUpgradeSgMigrateJob.preUpgradeSgMigrateContainerName`         | Name for es pre-upgradeSgMigrate job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.postUpgradeSgMigrateJob.name`         | Name for es post-upgradeSgMigrate job                    | `null` |
|`belk-elasticsearch.customResourceNames.postUpgradeSgMigrateJob.postUpgradeSgMigrateContainerName`         | Name for es post-upgradeSgMigrate job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.preHealJob.name`         | Name for es pre-heal job                    | `null` |
|`belk-elasticsearch.customResourceNames.preHealJob.preHealContainerName`         | Name for es pre-heal job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.postDeletePrehealJob.name`         | Name for es post-deletePreheal job                    | `null` |
|`belk-elasticsearch.customResourceNames.postDeletePrehealJob.postDeletePrehealContainerName`         | Name for es post-deletePreheal job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.postDeleteCleanupJob.name`         | Name for es post-deleteCleanup job                    | `null` |
|`belk-elasticsearch.customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName`         | Name for es post-deleteCleanup job's container                   | `null` |
|`belk-elasticsearch.customResourceNames.postDeletePvcJob.name`         | Name for es post-deletePvc job                    | `null` |
|`belk-elasticsearch.customResourceNames.postDeletePvcJob.postDeletePvcContainerName`         | Name for es post-deletePvc job's container                   | `null` |
|`belk-elasticsearch.nameOverride`         | Use this to override name for elasticsearch deployment/sts kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`belk-elasticsearch.fullnameOverride`         | Use this to configure custom-name for elasticsearch deployment/sts kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence. | `null` |
|`belk-elasticsearch.es_securityContext.fsGroup`|Group ID assigned for the volumemounts mounted to the pod|`1000`|
|`belk-elasticsearch.es_securityContext.supplementalGroups`|SupplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`belk-elasticsearch.es_securityContext.seLinuxOptions`|provision to configure selinuxoptions for elasticsearch container|`default value is commented out`|
|`belk-elasticsearch.custom.annotations`|Configure elasticsearch pod specific annotations|`null`|
|`belk-elasticsearch.serviceAccountName`|Pre-created ServiceAccount specifically for elasticsearch chart. SA specified here takes precedence over the SA specified in global.|`null`|
|`belk-elasticsearch.upgrade.hookDelPolicy`|Configure delete policy of pre/post-upgrade jobs to modify the job retention|`before-hook-creation, hook-succeeded`|
|`belk-elasticsearch.persistence.enabled`|Enable persistent storage class for belk elasticsearch chart|`true`|
|`belk-elasticsearch.persistence.storageClassName`|Persistent Volume Storage Class name. Belk elasticsearch chart support "local-storage","cinder","hostpath". When configured as "" picks the default storage class configured in the BCMT cluster.|`null`|
|`belk-elasticsearch.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`belk-elasticsearch.persistence.size`|Persistent Volume Size given to data pods for storage|`50Gi`|
|`belk-elasticsearch.persistence.masterStorage`|Persistent storage size for master pod to persist cluster state|`1Gi`|
|`belk-elasticsearch.persistence.auto_delete`|Persistent volumes auto deletion along with deletion of chart when set to true|`false`|
|`belk-elasticsearch.network_host`|Configure based on network interface added to cluster nodes i.e ipv4 interface or ipv6 interface.For ipv4 interface value can be set to "\_site\_".For ipv6 interface values can be set to "\_global:ipv6\_" or "\_eth0:ipv6\_"|`"_site_"`|
|`belk-elasticsearch.backup_restore.size`|Size of the PersistentVolume used for backup restore|`25Gi`|
|`belk-elasticsearch.cbur.enabled`|Enable cbur for backup and restore operation|`false`|
|`belk-elasticsearch.cbur.brOption`|Backup is for a stateful set, CBUR will apply the rule specified by the brOption. Recommended value of brOption for BELK is 0.|`0`|
|`belk-elasticsearch.cbur.maxCopy`|Maxcopy of backup files to be stored|`5`|
|`belk-elasticsearch.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`belk-elasticsearch.cbur.cronJob`|Cronjob frequency|`0 23 * * *`|
|`belk-elasticsearch.cbur.autoEnableCron`|AutoEnable Cron to take backup as per configured cronjob |`false`|
|`belk-elasticsearch.cbur.autoUpdateCron`|AutoUpdate cron to update cron job schedule|`false`|
|`belk-elasticsearch.cbur.cbura.imageRepo`|Cbura image used for backup and restore|`cbur/cbura`|
|`belk-elasticsearch.cbur.cbura.imageTag`|Cbura image tag|`1.0.3-1665`|
|`belk-elasticsearch.cbur.cbura.imagePullPolicy`|Cbura image pull policy|`IfNotPresent`|
|`belk-elasticsearch.cbur.cbura.userId`|Group id for cbura container|`1000`|
|`belk-elasticsearch.cbur.cbura.resources`|CPU/Memory resource requests/limits for cbura pod|`limits:       cpu: "1"       memory: "2Gi"     requests:       cpu: "500m"       memory: "1Gi"`|
|`belk-elasticsearch.cbur.cbura.tmp_size`|Volume mount size of /tmp directory for cbur-sidecar.The value should be around double the size of backup_restore.size|`50Gi`|
|`belk-elasticsearch.service.name`|Kubernetes service name for elasticsearch|`elasticsearch`|
|`belk-elasticsearch.service.prometheus_metrics.enabled`|Scrape metrics from elasticsearch when set to true|`false`|
|`belk-elasticsearch.service.prometheus_metrics.pro_annotation_https_scrape`|Prometheus annotation to scrape metrics from elaticsearch https endpoints|`prometheus.io/scrape_es`|
|`belk-elasticsearch.istio.enabled`|Enable istio for Elasticsearch using the flag|`false`|
|`belk-elasticsearch.istio.envoy_health_chk_port`|Health check port of istio envoy proxy|`15020`|
|`belk-elasticsearch.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`belk-elasticsearch.searchguard.enable`|Enable searchguard using this flag|`false`|
|`belk-elasticsearch.searchguard.image.repo`|Elasticsearch searchguard image name. Accepted values are elk_e_sg and elk_e_sg_cos7|`elk_e_sg_cos7`|
|`belk-elasticsearch.searchguard.adminUsername`|Admin user credentials base64 format required for searchguard only when istio is enabled or searchguard.http_ssl is disabled.|`null`|
|`belk-elasticsearch.searchguard.adminPwd`|Admin user credentials base64 format required for searchguard only when istio is enabled or searchguard.http_ssl is disabled.|`null`|
|`belk-elasticsearch.searchguard.keycloak_auth`|Enable authentication via keycloak|`false`|
|`belk-elasticsearch.searchguard.base64_keycloak_rootca_pem`|Base64 format of keycloak rootCA |`null`|
|`belk-elasticsearch.searchguard.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`belk-elasticsearch.searchguard.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values are MESH_INTERNAL, MESH_EXTERNAL|`MESH_INTERNAL`|
|`belk-elasticsearch.searchguard.keystore_type`|Elasticsearch certificate keystore type|`JKS`|
|`belk-elasticsearch.searchguard.truststore_type`|Elasticsearch certificate truststore type|`JKS`|
|`belk-elasticsearch.searchguard.base64Keystore`|Base64 of elasticsearch server keystore|`null`|
|`belk-elasticsearch.searchguard.base64KeystorePasswd`|Base64 of KeystorePassword|`null`|
|`belk-elasticsearch.searchguard.base64Truststore`|Base64 of truststore containing the root ca that signed server & admin certificates.|`null`|
|`belk-elasticsearch.searchguard.base64TruststorePasswd`|Base64 of TruststorePassword|`null`|
|`belk-elasticsearch.searchguard.base64ClientKeystore`|Base64 of client keystore|`null`|
|`belk-elasticsearch.searchguard.base64_client_cert`|Base64 of client certificate|`null`|
|`belk-elasticsearch.searchguard.base64_client_key`|Base64 of client key|`null`|
|`belk-elasticsearch.searchguard.auth_admin_identity`|DN of the admin certificate|`<CN=admin,C=ELK>`|
|`belk-elasticsearch.searchguard.nodes_dn`|Configure DN of node certificate if the certificate does not contain an OID defined in its SAN|`null`|
|`belk-elasticsearch.searchguard.http_ssl`|Enable/disable SSL on REST layer for searchguard|`true`|
|`belk-elasticsearch.searchguard.ciphers`|Cipher suites are cryptographic algorithms used to provide security  for HTTPS traffic.Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"|`null`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_internal_users_yml`|Configure user for searchguard |`admin user`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_action_groups_yml`|Action groups are named collection of permissions.Using action groups is the preferred way of assigning permissions to a role.|`Refer values.yaml file or BELK user guide for more details`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_config_yml`|Configure Authentication and authorization settings for users|`Refer values.yaml file or BELK user guide for more details`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_roles_yml`|Configure searchguard roles defining access permissions to elasticsearch indices|`Refer values.yaml file or BELK user guide for more details`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_roles_mapping_yml`|Configure searchguard roles that are assigned to users|`Refer values.yaml file or BELK user guide for more details`|
|`belk-elasticsearch.searchguard.sg_configmap.sg_blocks_yml`|Configure access control rules on a global level, for example blocking IPs or IP ranges|`Refer values.yaml file or BELK user guide for more details`|
|`belk-kibana.searchguard.enable `|Enable tag for Searchguard|`false `|
|`belk-kibana.searchguard.image.repo `|Kibana SearchGuard Repo Tag. Accepted values are elk_k_sg and elk_k_sg_cos7|`elk_k_sg_cos7`|
|`belk-kibana.searchguard.base64_kib_es_username`|Base64 of kibana username |`null`|
|`belk-kibana.searchguard.base64_kib_es_password`|Base64 of kibana password|`null`|
|`belk-kibana.searchguard.keycloak_auth`|enable authentication required via keycloak|`false`|
|`belk-kibana.searchguard.base64_keycloak_rootca_pem`|Kibana communicating to keycloak using keycloak root-ca certificate|`null`|
|`belk-kibana.searchguard.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`belk-kibana.searchguard.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values: MESH_INTERNAL, MESH_EXTERNAL |`MESH_INTERNAL`|
|`belk-kibana.searchguard.istio.extCkeyPort`|Port on which ckey is externally accessible|`null`|
|`belk-kibana.searchguard.istio.extCkeyProtocol`|Protocol on which ckey is externally accessible|`null`|
|`belk-kibana.searchguard.istio.ckeyK8sSvcName`|FQDN of ckey k8s service name internally accessible within k8s cluster|`null`|
|`belk-kibana.searchguard.istio.ckeyK8sSvcPort`|Port on which ckey k8s service is accessible|`null`|
|`belk-kibana.searchguard.base64_ES_RootCA`|CA certificate used by Kibana to establish trust when contacting Elasticsearch|`null`|
|`belk-kibana.searchguard.base64ServerCrt`|base64 of kibana server certificate|`null`|
|`belk-kibana.searchguard.base64ServerKey`|base64 of kibana server key|`null`|
|`belk-kibana.searchguard.kibana.es_ssl_verification_mode`|Controls verification of the Elasticsearch server certificate that Kibana receives when contacting Elasticsearch|`certificate`|
|`belk-kibana.sane.keycloak_admin_user_name`|Base64 of keycloak admin username|`default value is commented out`|
|`belk-kibana.sane.keycloak_admin_password`|Base64 of keycloak admin password|`default value is commented out`|
|`belk-kibana.sane.keycloak_sane_user_password`|Base64 for default password for sane user|`default value is commented out`|
|`belk-kibana.kibana.image.repo`|Kibana image name. Accepted values are elk_k and elk_k_cos7|`elk_k_cos7`|
|`belk-kibana.kibana.replicas`|Desired number of kibana replicas|`1`|
|`belk-kibana.kibana.resources`|CPU/Memory resource requests/limits for kibana pod|`limits: CPU/Mem 1000m/2Gi , requests: CPU/Mem 500m/1Gi`|
|`belk-kibana.kibana.port`|Kibana is served by a back end server. This setting specifies the port to use.|`5601`|
|`belk-kibana.kibana.node_port`|This setting specifies the node_port to use when service type is NodePort|`30601`|
|`belk-kibana.kibana.livenessProbe.initialDelaySeconds `|Delay before liveness probe is initiated (kibana)|`150`|
|`belk-kibana.kibana.livenessProbe.periodSeconds`|How often to perform the probe (kibana)|`10`|
|`belk-kibana.kibana.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (kibana)|`150`|
|`belk-kibana.kibana.readinessProbe.periodSeconds`|How often to perform the probe (kibana)|`10`|
|`belk-kibana.kibana.podLabels`|Set the podLabels parameter as key-value pair |`null`|
|`belk-kibana.kibana.serviceAccountName`|Pre-created ServiceAccount specifically for kibana chart. SA specified here takes precedence over the SA specified in global.|`null`|
|`belk-kibana.kibana.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`belk-kibana.kibana.securityContext.supplementalGroups`|The supplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`belk-kibana.kibana.securityContext.seLinuxOptions`|provision to configure selinuxoptions for kibana container|`default value is commented`|
|`belk-kibana.kibana.custom.annotations`|Kibana pod annotations|`{}`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.server.name`|A human-readable display name that identifies this Kibana instance|`kibana`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.server.customResponseHeaders`|Header names and values to send on all responses to the client from the Kibana server|`{ "X-Frame-Options": "DENY" }  `|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.server.ssl.supportedProtocols`|Supported protocols with versions. Valid protocols: TLSv1, TLSv1.1, TLSv1.2. Enable server.ssl.supportedProtocols when sg is enabled.|`Even though the value is commented, default values are TLSv1.1, TLSv1.2`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.cookie.secure`| Searchguard cookie can be secured by setting the below parameter to true. Uncomment it when SG is enabled.|`true`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.elasticsearch.requestHeadersWhitelist `|Kibana client-side headers to send to Elasticsearch|`Even though the value is commented, default value is autorization`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.auth.type`|If openid/ckey authentication is required, then uncomment and set this parameter to openid, Also uncomment and configure the other openid.* parameters accordingly. |`default value is basicauth when searchguard is enabled.`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.connect_url `|The URL where the IdP publishes the OpenID metadata.|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.client_id`|The ID of the OpenID client configured in your IdP|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.client_secret`|The client secret of the OpenID client configured in your IdP|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.header`|HTTP header name of the JWT token|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.base_redirect_url`|The URL where the IdP redirects to after successful authentication|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.openid.root_ca`|Path to the root CA of your IdP|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csp.strict `|Kibana uses a Content Security Policy to help prevent the browser from allowing unsafe scripting|`true`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.enabled `|To enable/disable CSAN-Kibna integration. If csan is enabled, then uncomment and set other searchguard.auth.unauthenticated_routes,csan.* parameters accordingly|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.ssoproxy.url`|This is CSAN SSOProxy service URL|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.searchguard.auth.unauthenticated_routes`|CSAN plugin routes need to be excluded from search guard authentication model|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.sco.url`|This is system credential orchestrator service URL|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.sco.keycloak_entity`|This is keycloak entity name name|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.sco.keycloak_classifier`|This is Keyclock realm-admin and this is required to connect with keycloak|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.sco.sane_entity `|SANE entity name|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.sco.sane_plugin_name `|Name of CSAN-Kibna credential plugin|`null`|
|`belk-kibana.kibana.configMaps.kibana_configmap_yml.csan.auth_type `|Authentication type for dynamic password for CSAN users|`null`|
|`belk-kibana.kibana.env.ELASTICSEARCH_HOSTS`| The URLs of the Elasticsearch instances to use for all your queries. When sg is enabled use protocol as https                                                   |`http://elasticsearch:9200`|
|`belk-kibana.kibana.env.LOG_INDICES`| A ES based simple query to control the index-pattern to list (log-exporter).For more info about log-exporter parameter please refer[https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=992198356]                                        |`["log-*", journal]`|
|`belk-kibana.kibana.env.DEFAULT_FIELDS`|Default search fields for log exporter to search upon when field key is not provided in search query. Accepts comma Separated values.|`log,message`|
|`belk-kibana.kibana.env.EXPORT_CHUNK_SIZE`|Tune stream chunk size for exporting(No of record in one stream). Higher number can also clog slow down. (log-exporter)     |`500 `|
|`belk-kibana.kibana.env.SCROLL_TIME`|ES search api scroll value.This query is used for creating stream chunk. (log-exporter)                                                                        |`10m`|
|`belk-kibana.kibana.env.EXPORT_TIMEOUT`|Timeout for above scroll based query.(log-exporter)|`40s`|
|`belk-kibana.kibana.env.TIMESTAMP_FIELD`|Default time field for log exporter. Applicable to all indices|`@timestamp`|
|`belk-kibana.kibana.env.SERVER_SSL_ENABLED`|When istio is enabled then uncomment SERVER_SSL_ENABLED and set it to false and If searchguard is enabled uncomment SERVER_SSL_ENABLED|               `"default value is commented out"`|
|`belk-kibana.kibana.env.SERVER_SSL_CERTIFICATE`|When searchguard is enabled uncomment SERVER_SSL_CERTIFICATE.|                                         `"default value is commented out"`|
|`belk-kibana.kibana.env.SERVER_SSL_KEY`|When searchguard is enabled uncomment SERVER_SSL_KEY.|                                                            `"default value is commented out"`|
|`belk-kibana.kibana.sslsecretvolume.tls.crt.pem`|Base64 of tls crt|`default value is commented out`|
|`belk-kibana.kibana.sslsecretvolume.tls.key.pem`|Base64 of tls key|`default value is commented out`|
|`belk-kibana.kibana.nodeSelector`|kibana node labels for pod assignment|`{}`|
|`belk-kibana.kibana.tolerations`|List of node taints to tolerate (kibana)|`[]`|
|`belk-kibana.kibana.affinity`|kibana affinity (in addition to kibana.antiAffinity when set)|`{}`|
|`belk-kibana.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`belk-kibana.customResourceNames.kibanaPod.kibanaContainerName`         | Name for kibana pod's container                  | `null` |
|`belk-kibana.nameOverride`         | Use this to override name for kibana deployment kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`belk-kibana.fullnameOverride`         | Use this to configure custom-name for kibana deployment kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`belk-kibana.ingress.enabled`|Enable to access kibana svc via citm-ingress|`true`|
|`belk-kibana.ingress.annotations`|Ingress annotations (evaluated as a template)|`{}`|
|`belk-kibana.ingress.host`|Hosts configured for ingress|`*`|
|`belk-kibana.ingress.tls`|TLS configured for ingress |`[]`|
|`belk-kibana.service.name`|Kubernetes service name of kibana.|`kibana`|
|`belk-kibana.service.type`|Kubernetes service type|`ClusterIP`|
|`belk-kibana.kibanabaseurl.url`|Baseurl configured for kibana when kibana service is with ClusterIP|`/logviewer`|
|`belk-kibana.kibanabaseurl.cg`|Do not change cg(capture group) parameter below unless you want to change/modify nginx rewrite-target for kibana ingress|`/?(.*)`|
|`belk-kibana.istio.enabled`|Enabled istio for kibana when running in istio enabled namespace|`false`|
|`belk-kibana.istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`belk-kibana.istio.virtual_svc.hosts`|VirtualService defines a set of traffic routing rules to apply when a host is addressed|`*`|
|`belk-kibana.istio.gateway.existing_gw_name `|Istio ingressgateway name if existing gateway should be used|`null`|
|`belk-kibana.istio.gateway.selector.istio`|Selector for istio|`ingressgateway`|
|`belk-kibana.istio.gateway.port.number`|Port number used for istio gateway|`80`|
|`belk-kibana.istio.gateway.port.protocol`|Protocol used for istio gateway|`HTTP  `|
|`belk-kibana.istio.gateway.port.name`|Port name used for istio gateway|`http`|
|`belk-kibana.istio.gateway.hosts`|Hosts configured for istio gateway|`*`|
|`belk-kibana.istio.gateway.tls`|TLS configured for istio gateway|`[]`|
|`belk-kibana.cbur.enabled`|Enable cbur to take backup & restore the data|`false`|
|`belk-kibana.cbur.maxCopy`|max copy of backupdata stored in cbur|`5`|
|`belk-kibana.cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`belk-kibana.cbur.cronJob`|cronjob frequency|`0 23 * * *`|
|`belk-kibana.cbur.autoEnableCron`|To auto enable cron job |`false`|
|`belk-kibana.cbur.autoUpdateCron`|To delete/update cronjob automatically based on autoEnableCron|`false`|
|`belk-curator.searchguard.enable`|Enable searchguard for curator using this flag|`false`|
|`belk-curator.searchguard.base64_ca_certificate`|Curator communicating to elasticsearch via SG certificates|`null`|
|`belk-curator.istio.enabled`|Enable istio for curator using the flag |`false`|
|`belk-curator.istio.envoy_health_chk_port`|Health check port of istio envoy proxy |`15020`|
|`belk-curator.customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`belk-curator.customResourceNames.curatorCronJobPod.curatorContainerName`         | Name for curator cronjob pod's container                    | `null` |
|`belk-curator.customResourceNames.deleteJob.name`         | Name for curator delete job                    | `null` |
|`belk-curator.customResourceNames.deleteJob.deleteJobContainerName`         | Name for curator delete job's container                   | `null` |
|`belk-curator.nameOverride`         | Use this to override name for curator cronjob kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`belk-curator.fullnameOverride`         | Use this to configure custom-name for curator cronjob kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`belk-curator.curator.image.repo`| Curator image name. Accepted values are elk_c and elk_c_cos7| `elk_c_cos7` |
|`belk-curator.curator.resources`|CPU/Memory resource requests/limits for Curator pod|`limits:       cpu: "120m"       memory: "120Mi"     requests:       cpu: "100m"       memory: "100Mi"`|
|`belk-curator.curator.schedule`|Curator cronjob schedule|`0 1 * * *`|
|`belk-curator.curator.serviceAccountName`|Pre-created ServiceAccount specifically for curator chart when rbac.enabled is set to  false. SA specified here takes precedence over the SA specified in global|`null`|
|`belk-curator.curator.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`belk-curator.curator.securityContext.supplementalGroups`|     The supplementalGroups ID applies to shared storage volumes|`commented out by default`|
|`belk-curator.curator.securityContext.seLinuxOptions`|SELinux label to a curator container|`commented out by default`|
|`belk-curator.curator.custom.annotations`|Curator specific annotations|`default value is commented out`|
|`belk-curator.curator.podLabels`|Cutomized labels to curator pods|`commented out by default`|
|`belk-curator.curator.jobSpec.successfulJobsHistoryLimit`|Number of successful CronJob executions that are saved|`Even though the value is commented, K8S default value is 5`|
|`belk-curator.curator.jobSpec.failedJobsHistoryLimit`|Number of failed CronJob executions that are saved|`Even though the value is commented, K8S default value is 3`|
|`belk-curator.curator.jobSpec.concurrencyPolicy`|Specifies how to treat concurrent executions of a Job created by the CronJob controller|`Even though the value is commented, K8S default value is Allow`|
|`belk-curator.curator.jobTemplateSpec.backoffLimit`|Specifies the number of retries before considering a Job as failed|`default value is commented out`|
|`belk-curator.curator.jobTemplateSpec.activeDeadlineSeconds`|Duration of the job, no matter how many Pods are created. Once a Job reaches  activeDeadlineSeconds, all of its running Pods are terminated|`default value is commented out`|
|`belk-curator.curator.configMaps.preCreatedConfigmap`|Name of pre-created configmap. The configmap must contain the files actions.yml,  curator.yml. When the value is set, BELK chart doesn’t create curator configmap.|`null`|
|`belk-curator.curator.configMaps.action_file_yml`|It is a YAML configuration file. The root key must be actions, after which there can be  any number of actions, nested underneath numbers|`delete indices older than 7 days using age filter`|
|`belk-curator.curator.configMaps.config_yml`|The configuration file contains client connection and settings for logging|`connects to elasticsearch service on 9200 port via http`|


Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install --name my-release --set belk-elasticsearch.istio.enabled=true csf-stable/belk-efkc --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install --name my-release -f values.yaml csf-stable/belk-efkc --version <version> --namespace logging
