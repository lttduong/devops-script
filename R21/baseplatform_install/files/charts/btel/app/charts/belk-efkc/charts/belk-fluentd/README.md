## Fluentd

Fluentd is an open-source data collector for unified logging layer. It allows you to unify data collection and consumption for a better use and understanding of data.

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
helm install --name my-release csf-stable/belk-fluentd --version <version> --namespace logging
```
The command deploys fluentd on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete --purge my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

### Parameters:
The following table lists the configurable parameters of the FluentD chart and their default values.

|   Parameter             |Description                                   |Default                               |
|----------------|-------------------------------|-----------------------------|
|`global.registry`|Global docker image registry for fluentd image           |`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com` |
|`global.registry1`       |Global docker image registry for kubectl image           |`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com` |
|`global.seccompAllowedProfileNames` | Annotation that specifies which values are allowed for the pod seccomp annotations |`docker/default` |
|`global.seccompDefaultProfileName`  | Annotation that specifies the default seccomp profile to apply to containers       | `docker/default` |
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. Ex. 1.4/1.5|`1.4`|
|`global.rbac.enabled`        |Enable/disable rbac. When the flag is set to true, chart creates rbac objects if pre-created serviceaccount is not configured at global/chart level. When the flag is set to false, it is mandatory to configure a pre-created service-account at global/chart level. |`true`|
|`global.serviceAccountName`         | Pre-created ServiceAccountName defined at global level.                    | `null` |
|`customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`customResourceNames.fluentdPod.fluentdContainerName`         | Name for fluentd pod's container                    | `null` |
|`customResourceNames.scaleinJob.name`         | Name for fluentd scalein job                    | `null` |
|`customResourceNames.scaleinJob.postscaleinContainerName`         | Name for fluentd scalein job's container                   | `null` |
|`customResourceNames.deletePvcJob.name`         | Name for fluentd delete PVC job                    | `null` |
|`customResourceNames.deletePvcJob.deletePvcContainerName`         | Name for fluentd delete pvc job's container                   | `null` |
|`nameOverride`         | Use this to override name for fluentd deployment/sts/deamonset kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`fullnameOverride`         | Use this to configure custom-name for fluentd deployment/sts/deamonset kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`global.postscalein`       |To trigger postscale job hooks           |`0`|
|`fluentd.kind`       |Configure fluentd kind like Deployment,DaemonSet,Statefulset          |`DaemonSet`|
|`fluentd.image.repo`       |Fluentd image name |`elk_f`|
|`fluentd.image.tag`       |Fluentd image tag        |`1.11.1-20.08.0`|
|`fluentd.ImagePullPolicy`       |Fluentd image pull policy         |`IfNotPresent`|
|`fluentd.replicas`       |Desired number of fluentd replicas when the kind is Deployment or Statefulset         |`1`|
|`fluentd.podManagementPolicy`       |Fluentd pod management policy           |`Parallel`|
|`fluentd.updateStrategy.type`       |Fluentd pod update strategy policy          |`RollingUpdate`|
|`fluentd.statefulsetSuffix`       |Suffix for fluentd statefulset object name         |`statefulset`|
|`fluentd.daemonsetSuffix`       |Suffix for fluentd daemonset object name    |`daemonset`|
|`fluentd.serviceAccountName`       |Pre-created ServiceAccount specifically for fluentd chart. SA specified here takes precedence over the SA specified in global.           |`null`|
|`fluentd.securityContext.fsGroup` |Group ID for the container|`998`|
|`fluentd.securityContext.supplementalGroups`       |SupplementalGroups ID applies to shared storage volumes          |`998`|
|`fluentd.securityContext.seLinuxOptions.level`       |Configure SELinux for fluentd container          |`s0:c23,c123`|
|`fluentd.securityContext.privileged`       |When docker_selinux is enabled on BCMT, to read /var/log/messages, set privileged as True in securityContext          |`false`|
|`fluentd.custom.annotations`       |Fluentd pod annotations          |`{}`|
|`fluentd.resources`|CPU/Memory resource requests/limits for fluentd pod|`resources:  limits:  cpu: "1"  memory: "1Gi"  requests:  cpu: "600m" memory: "500Mi"`|
|`fluentd.EnvVars.system`|Configure system name for non-container log messages|`BCMT`|
|`fluentd.EnvVars.systemId`|Configure system id for non-container log messages|`BCMT ID`|
|`fluentd.enable_root_privilege`|Enable root privilege to read container, journal logs|`true`|
|`fluentd.fluentd_certificates.enabled`|Enable certificates for ssl communication |`false`|
|`fluentd.fluentd_certificates.data.prometheus-crt.pem`|Configure prometheus crt in base 64 format for ssl communication|`null`|
|`fluentd.fluentd_certificates.data.prometheus-key.pem`|Configure prometheus key in base 64 format for ssl communication|`null`|
|`fluentd.fluentd_certificates.data.prometheus-root-ca.pem`|Configure prometheus root ca in base 64 format for ssl communication|`null`|
|`fluentd.fluentd_certificates.data.es-root-ca.pem`|Configure elasticsearch root ca in base 64 format for ssl communication|`null`|
|`fluentd.fluentd_config`|Fluentd configuration to read data. Configurable values are belk, clog-json,clog-journal,custom-value|`belk`|
|`fluentd.configFile`|`If own configuration for fluentd other than provided by belk/clog then set fluentd_config: custom-value and provide the configuration here'| `null`|
|`fluentd.service.enabled`|Enable fluentd service|`false`|
|`fluentd.service.custom_name`|Configure fluentd custom service name |`null`|
|`fluentd.service.type`|Kubernetes service type|`ClusterIP`|
|`fluentd.service.metricsPort`|fluentd-prometheus-plugin port|`24231`|
|`fluentd.service.annotations`|fluentd service annotations|`{}`|
|`fluentd.forward_service.enabled`|Enable fluentd forward service|`false`|
|`fluentd.forward_service.custom_name`|Configure fluentd custom forwarder service name|`null`|
|`fluentd.forward_service.port`|Fluentd forward service port|`24224`|
|`fluentd.forward_service.type`|Kubernetes service type|`ClusterIP`|
|`fluentd.forward_service.annotations`|fluentd forward service annotations|`{}`|
|`fluentd.volume_mount_enable`|Enable volume mount for fluentd pod|`true`|
|`fluentd.volumes`|Mount volume  for fluentd pods|`/var/log and /data0/docker volumes of hostpath are mounted`|
|`fluentd.volumeMounts`|Location to mount the above volumes inside the container| `Above volumes are mounted to /var/log and /data0/docker locations inside the container`|
|`fluentd.nodeSelector`|Node labels for fluentd pod assignment|`{}`|
|`fluentd.tolerations`|List of node taints to tolerate (fluentd pods)|`[]`|
|`fluentd.livenessProbe.initialDelaySeconds`|Delay before liveness probe is initiated|`30`|
|`fluentd.livenessProbe.periodSeconds`|How often to perform the probe|`20`|
|`fluentd.livenessProbe.timeoutSeconds`|When the probe times out|`1`|
|`fluentd.livenessProbe.successThreshold`|Minimum consecutive successes for the probe|`1`|
|`fluentd.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe|`3`|
|`fluentd.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated|`30`|
|`fluentd.readinessProbe.periodSeconds`|How often to perform the probe|`10`|
|`fluentd.readinessProbe.timeoutSeconds`|When the probe times out|`1`|
|`fluentd.readinessProbe.successThreshold`|Minimum consecutive successes for the probe|`1`|
|`fluentd.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe|`3`|
|`fluentd.affinity`|Fluentd pod anti-affinity policy|`{}`|
|`fluentd.podLabels`|To configure cutomized labels to pods|`commented out by default`|
|`fluentd.persistence.storageClassName`|Persistent Volume Storage Class|`null`|
|`fluentd.persistence.accessMode`|Persistent Volume Access Modes|`ReadWriteOnce`|
|`fluentd.persistence.size`|Persistent Volume Size|`10Gi`|
|`fluentd.persistence.pvc_auto_delete`|Persistent Volume auto delete when chart is deleted |`false`|
|`cbur.enabled`|Enable cbur for backup and restore operation|`true`|
|`cbur.maxcopy`|Maxcopy of backup files to be stored|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|Configure cronjob timings to take backup|`0 23 * * *`|
|`cbur.autoEnableCron`|AutoEnable Cron property to take backup as per configured cronjob|`true`|
|`cbur.autoUpdateCron`|AutoUpdate cron to update cron job timings|`false`|
|`istio.enabled`|Enable istio using this flag|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`kubectl.image.repo`|kubectl image name|`tools/kubectl`|
|`kubectl.image.tag`|kubectl image tag|`v1.14.10-nano`|
|`kubectl.jobResources`|CPU/Memory resource requests/limits for kubectl pod|`limits: cpu: "1" memory: "1Gi" requests: cpu: "200m" memory: "500Mi"`|


Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install --name my-release --set istio.enabled=true csf-stable/belk-fluentd --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install --name my-release -f values.yaml csf-stable/belk-fluentd --version <version> --namespace logging
```


