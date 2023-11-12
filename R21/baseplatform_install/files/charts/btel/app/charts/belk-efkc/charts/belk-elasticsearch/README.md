## Elasticsearch

Elasticsearch allows to store, search, and analyze huge volumes of data quickly in real-time and give back answers in milliseconds. It stores data in term of Elasticsearch index , index is a collection of documents. it comes with extensive REST APIs for storing and searching the data.

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
helm install --name my-release csf-stable/belk-elasticsearch --version <version> --namespace logging
```
The command deploys elasticsearch on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

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
|`global.registry`|Global Docker image registry for elasticsearch image|`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`|
|`global.registry1`|Global Docker image registry for kubectl images|`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`|
|`global.preheal`|To trigger preheal job hooks|`0`|
|`global.postheal`|To trigger postheal job hooks|`0`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. Ex. 1.4/1.5|`1.4`|
|`global.rbac.enabled`|Enable/disable rbac. When the flag is set to true, chart creates rbac objects if pre-created serviceaccount is not configured at global/chart level. When the flag is set to false, it is mandatory to configure a pre-created service-account at global/chart level|`true`|
|`global.serviceAccountName`|Pre-created ServiceAccountName defined at global level|`null`|
|`serviceAccountName`|Pre-created ServiceAccount specifically for elasticsearch chart. SA specified here takes precedence over the SA specified in global.|`null`|
|`customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`customResourceNames.masterPod.masterContainerName`         | Name for elasticsearch master pod's container                    | `null` |
|`customResourceNames.dataPod.dataContainerName`         | Name for elasticsearch data pod's container                    | `null` |
|`customResourceNames.clientPod.clientContainerName`         | Name for elasticsearch client pod's container                    | `null` |
|`customResourceNames.postScaleInJob.name`         | Name for es post-scalein job                    | `null` |
|`customResourceNames.postScaleInJob.postScaleInContainerName`         | Name for es post-scalein job's container                   | `null` |
|`customResourceNames.preUpgradeSgMigrateJob.name`         | Name for es pre-upgradeSgMigrate job                    | `null` |
|`customResourceNames.preUpgradeSgMigrateJob.preUpgradeSgMigrateContainerName`         | Name for es pre-upgradeSgMigrate job's container                   | `null` |
|`customResourceNames.postUpgradeSgMigrateJob.name`         | Name for es post-upgradeSgMigrate job                    | `null` |
|`customResourceNames.postUpgradeSgMigrateJob.postUpgradeSgMigrateContainerName`         | Name for es post-upgradeSgMigrate job's container                   | `null` |
|`customResourceNames.preHealJob.name`         | Name for es pre-heal job                    | `null` |
|`customResourceNames.preHealJob.preHealContainerName`         | Name for es pre-heal job's container                   | `null` |
|`customResourceNames.postDeletePrehealJob.name`         | Name for es post-deletePreheal job                    | `null` |
|`customResourceNames.postDeletePrehealJob.postDeletePrehealContainerName`         | Name for es post-deletePreheal job's container                   | `null` |
|`customResourceNames.postDeleteCleanupJob.name`         | Name for es post-deleteCleanup job                    | `null` |
|`customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName`         | Name for es post-deleteCleanup job's container                   | `null` |
|`customResourceNames.postDeletePvcJob.name`         | Name for es post-deletePvc job                    | `null` |
|`customResourceNames.postDeletePvcJob.postDeletePvcContainerName`         | Name for es post-deletePvc job's container                   | `null` |
|`nameOverride`         | Use this to override name for elasticsearch deployment/sts kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`fullnameOverride`         | Use this to configure custom-name for elasticsearch deployment/sts kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence. | `null` |
|`es_securityContext.fsGroup`|Group ID assigned for the volumemounts mounted to the pod|`1000`|
|`es_securityContext.supplementalGroups`|SupplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`es_securityContext.seLinuxOptions`|provision to configure selinuxoptions for elasticsearch container|`default value is commented out`|
|`custom.annotations`|Configure elasticsearch pod specific annotations|`null`|
|`istio.enabled`|Enable istio for Elasticsearch using the flag|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`istio.envoy_health_chk_port`|Health check port of istio envoy proxy|`15020`|
|`service.type`|Kubernetes service type|`ClusterIP`|
|`service.client_port`|Elasticsearch service port|`9200`|
|`service.client_nodeport`|Elasticsearch port when deployed with nodeport|`30932`|
|`service.master_port`|Elasticsearch service port for internal pod communication|`9300`|
|`service.name`|Kubernetes service name for elasticsearch|`elasticsearch`|
|`service.prometheus_metrics.enabled`|Scrape metrics from elasticsearch when set to true|`false`|
|`service.prometheus_metrics.pro_annotation_https_scrape`|Prometheus annotation to scrape metrics from elaticsearch https endpoints|`prometheus.io/scrape_es`|
|`network_host`|Configure based on network interface added to cluster nodes i.e ipv4 interface or ipv6 interface.For ipv4 interface value can be set to "\_site\_".For ipv6 interface values can be set to "\_global:ipv6\_" or "\_eth0:ipv6\_"|`"_site_"`|
|`postscalein`|To trigger postscale job hooks|`0`|
|`upgrade.hookDelPolicy`|Configure delete policy of pre/post-upgrade jobs to modify the job retention|`before-hook-creation, hook-succeeded`|
|`elasticsearch_master.name`|Elasticsearch master role name|`master`|
|`elasticsearch_master.replica`|Desired number of elasticsearch master node replicas|`3`|
|`elasticsearch_master.image.repo`|Elasticsearch image name. Accepted values are elk_e and elk_e_cos7 |`elk_e_cos7`|
|`elasticsearch_master.image.tag`|Elasticsearch image tag|`7.8.0-20.09.03`|
|`elasticsearch_master.ImagePullPolicy`|Elasticsearch image pull policy|`IfNotPresent`|
|`elasticsearch_master.resources`|CPU/Memory resource requests/limits for master pod|`limits:       cpu: "1"      memory: "2Gi"     requests:       cpu: "500m"       memory: "1Gi"`|
|`elasticsearch_master.es_java_opts`|Environment variable for setting up JVM options|` Xms1g  Xmx1g`|
|`elasticsearch_master.antiAffinity`|Master pod anti-affinity policy|`soft`|
|`elasticsearch_master.podAffinity`|Master pod affinity (in addition to master.antiAffinity when set)|`{}`|
|`elasticsearch_master.nodeAffinity`|Master node affinity (in addition to master.antiAffinity when set)|`{}`|
|`elasticsearch_master.nodeSelector`|master node labels for pod assignment|`{}`|
|`elasticsearch_master.tolerations`|List of node taints to tolerate for (master)|`[]`|
|`elasticsearch_master.podManagementPolicy`|Master statefulset parallel pod management policy |`Parallel`|
|`elasticsearch_master.updateStrategy.type`|Master statefulset update strategy policy|`RollingUpdate`|
|`elasticsearch_master.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (master)|`30`|
|`elasticsearch_master.livenessProbe.periodSeconds`|How often to perform the probe (master)|`10`|
|`elasticsearch_master.livenessProbe.timeoutSeconds`|When the probe times out (master)|`1`|
|`elasticsearch_master.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (master)|`1`|
|`elasticsearch_master.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (master)|`3`|
|`elasticsearch_master.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (master)|`30`|
|`elasticsearch_master.readinessProbe.periodSeconds`|How often to perform the probe (master)|`10`|
|`elasticsearch_master.readinessProbe.timeoutSeconds`|When the probe times out (master)|`1`|
|`elasticsearch_master.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (master)|`1`|
|`elasticsearch_master.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (master)|`3`|
|`elasticsearch_master.podLabels`|Customized labels to master pods|`null`|
|`esdata.name`|Elasticsearch data role name|`data`|
|`esdata.replicas`|Desired number of elasticsearch data node replicas|`2`|
|`esdata.podweight`|To decide the most preferred node for allocation|`100`|
|`esdata.resources`|CPU/Memory resource requests/limits for data pod|`limits:       cpu: "1"       memory: "4Gi"     requests:       cpu: "500m"       memory: "2Gi"`|
|`esdata.es_java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`esdata.podManagementPolicy`|Data statefulset parallel pod management policy |`Parallel`|
|`esdata.updateStrategy.type`|Data statefulset update strategy policy|`RollingUpdate`|
|`esdata.antiAffinity`|Data pod anti-affinity policy|`soft`|
|`esdata.podAffinity`|Data pod affinity (in addition to esdata.antiAffinity when set)|`{}`|
|`esdata.nodeAffinity`|Data node affinity (in addition to esdata.antiAffinity when set)|`{}`|
|`esdata.nodeSelector`|Data node labels for pod assignment|`{}`|
|`esdata.tolerations`|List of node taints to tolerate for (data)|`[]`|
|`esdata.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (data)|`30`|
|`esdata.livenessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`esdata.livenessProbe.timeoutSeconds`|When the probe times out (data)|`1`|
|`esdata.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (data)|`1`|
|`esdata.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (data)|`3`|
|`esdata.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (data)|`30`|
|`esdata.readinessProbe.periodSeconds`|How often to perform the probe (data)|`10`|
|`esdata.readinessProbe.timeoutSeconds`|When the probe times out (data)|`1`|
|`esdata.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (data)|`1`|
|`esdata.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (data)|`3`|
|`esdata.podLabels`|Customized labels to data pods|`null`|
|`elasticsearch_client.name`|Elasticsearch client role name|`client`|
|`elasticsearch_client.replicas`|Desired number of elasticsearch client node replicas|`3`|
|`elasticsearch_client.resources`|CPU/Memory resource requests/limits for client pod|`limits:       cpu: "1"       memory: "4Gi"     requests:       cpu: "500m"       memory: "2Gi"`|
|`elasticsearch_client.es_java_opts`|Environment variable for setting up JVM options|` Xms2g  Xmx2g`|
|`elasticsearch_client.antiAffinity`|Client pod anti-affinity policy|`soft`|
|`elasticsearch_client.podAffinity`|Client pod affinity (in addition to client.antiAffinity when set)|`{}`|
|`elasticsearch_client.nodeAffinity`|Client node affinity (in addition to client.antiAffinity when set)|`{}`|
|`elasticsearch_client.nodeSelector`|Client node labels for pod assignment|`{}`|
|`elasticsearch_client.tolerations`|List of node taints to tolerate for (client)|`[]`|
|`elasticsearch_client.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated (client)|`90`|
|`elasticsearch_client.livenessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`elasticsearch_client.livenessProbe.timeoutSeconds`|When the probe times out (client)|`1`|
|`elasticsearch_client.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (client)|`1`|
|`elasticsearch_client.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (client)|`3`|
|`elasticsearch_client.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (client)|`90`|
|`elasticsearch_client.readinessProbe.periodSeconds`|How often to perform the probe (client)|`20`|
|`elasticsearch_client.readinessProbe.timeoutSeconds`|When the probe times out (client)|`1`|
|`elasticsearch_client.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (client)|`1`|
|`elasticsearch_client.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (client)|`3`|
|`elasticsearch_client.podLabels`|Customized labels to client pods|`null`|
|`persistence.storageClassName`|Persistent Volume Storage Class name. Belk elasticsearch chart support "local-storage","cinder","hostpath". When configured as "" picks the default storage class configured in the BCMT cluster.|`null`|
|`persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`persistence.size`|Persistent Volume Size given to data pods for storage|`25Gi`|
|`persistence.masterStorage`|Persistent storage size for master pod to persist cluster state|`1Gi`|
|`persistence.auto_delete`|Persistent volumes auto deletion along with deletion of chart when set to true|`false`|
|`backup_restore.storageClassName`|Storage class used for backup restore not for elasticsearch data storage purpose. For this Only "glusterfs-storageclass" is supported. |`glusterfs-storageclass`|
|`backup_restore.size`|Size of the PersistentVolume used for backup restore|`40Gi`|
|`cbur.enabled`|Enable cbur for backup and restore operation|`false`|
|`cbur.brOption`|Backup is for a stateful set, CBUR will apply the rule specified by the brOption. Recommended value of brOption for BELK is 0.|`0`|
|`cbur.maxCopy`|Maxcopy of backup files to be stored|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|Cronjob frequency|`0 23 * * *`|
|`cbur.autoEnableCron`|AutoEnable Cron to take backup as per configured cronjob |`false`|
|`cbur.autoUpdateCron`|AutoUpdate cron to update cron job schedule|`false`|
|`cbura.imageRepo`|Cbura image used for backup and restore|`cbur/cbura`|
|`cbura.imageTag`|Cbura image tag|`1.0.3-1665`|
|`cbura.imagePullPolicy`|Cbura image pull policy|`IfNotPresent`|
|`cbura.userId`|Group id for cbura container|`1000`|
|`cbura.resources`|CPU/Memory resource requests/limits for cbura pod|`limits:       cpu: "1"       memory: "2Gi"     requests:       cpu: "500m"       memory: "1Gi"`|
|`cbura.tmp_size`|Volume mount size of /tmp directory for cbur-sidecar.The value should be around double the size of backup_restore.size|`80Gi`|
|`kubectl.image.repo`|Kubectl image name|`tools/kubectl`|
|`kubectl.image.tag`|Kubectl image tag|`v1.14.10-nano`|
|`kubectl.jobResources`|CPU/Memory resource requests/limits for kubectl resource|`limits:       cpu: "1"       memory: "1Gi"     requests:       cpu: "200m"       memory: "500Mi"`|
|`searchguard.image.repo`|Elasticsearch searchguard image name. Accepted values are elk_e_sg and elk_e_sg_cos7|`elk_e_sg_cos7`|
|`searchguard.image.tag`|Elasticsearch searchguard image tag|`7.8.0-20.09.04`|
|`searchguard.enable`|Enable searchguard using this flag|`false`|
|`searchguard.adminUsername`|Admin user credentials base64 format required for searchguard only when istio is enabled or searchguard.http_ssl is disabled.|`null`|
|`searchguard.adminPwd`|Admin user credentials base64 format required for searchguard only when istio is enabled or searchguard.http_ssl is disabled.|`null`|
|`searchguard.keycloak_auth`|Enable authentication required via keycloak|`false`|
|`searchguard.base64_keycloak_rootca_pem`|Base64 format of keycloak rootCA |`null`|
|`searchguard.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`searchguard.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh .Accepted values are MESH_INTERNAL, MESH_EXTERNAL|`MESH_INTERNAL`|
|`searchguard.istio.extCkeyIP`|IP to be used for DNS resolution of ckey hostname from the cluster.Required only when ckey is external to istio mesh and ckey hostname is not resolvable from the cluster|`null`|
|`searchguard.keystore_type`|Elasticsearch certificate keystore type|`JKS`|
|`searchguard.truststore_type`|Elasticsearch certificate truststore type|`JKS`|
|`searchguard.base64Keystore`|Base64 of elasticsearch server keystore|`null`|
|`searchguard.base64KeystorePasswd`|Base64 of KeystorePassword|`null`|
|`searchguard.base64Truststore`|Base64 of truststore containing the root ca that signed server & admin certificates.|`null`|
|`searchguard.base64TruststorePasswd`|Base64 of TruststorePassword|`null`|
|`searchguard.base64ClientKeystore`|Base64 of client keystore|`null`|
|`searchguard.base64_client_cert`|Base64 of client certificate|`null`|
|`searchguard.base64_client_key`|Base64 of client key|`null`|
|`searchguard.auth_admin_identity`|DN of the admin certificate|`<CN=admin,C=ELK>`|
|`searchguard.nodes_dn`|Configure DN of node certificate if the certificate does not contain an OID defined in its SAN|`null`|
|`searchguard.http_ssl`|Enable/disable SSL on REST layer for searchguard|`true`|
|`searchguard.ciphers`|Cipher suites are cryptographic algorithms used to provide security  for HTTPS traffic.Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256" "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"|`null`|
|`sg_configmap.sg_internal_users_yml`|Configure user for searchguard |`admin user`|
|`sg_configmap.sg_action_groups_yml`|Action groups are named collection of permissions.Using action groups is the preferred way of assigning permissions to a role.|`Refer values.yaml file or BELK user guide for more details`|
|`sg_configmap.sg_config_yml`|Configure Authentication and authorization settings for users|`Refer values.yaml file or BELK user guide for more details`|
|`sg_configmap.sg_roles_yml`|Configure searchguard roles defining access permissions to elasticsearch indices|`Refer values.yaml file or BELK user guide for more details`|
|`sg_configmap.sg_roles_mapping_yml`|Configure searchguard roles that are assigned to users|`Refer values.yaml file or BELK user guide for more details`|
|`sg_configmap.sg_blocks_yml`|Configure access control rules on a global level, for example blocking IPs or IP ranges|`Refer values.yaml file or BELK user guide for more details`|

Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install --name my-release --set istio.enabled=true csf-stable/belk-elasticsearch --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install --name my-release -f values.yaml csf-stable/belk-elasticsearch --version <version> --namespace logging

