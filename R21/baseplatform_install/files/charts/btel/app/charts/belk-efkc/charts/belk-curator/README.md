## Curator
Elasticsearch Curator helps you curate, or manage, your Elasticsearch indices and snapshots by:
1. Obtaining the full list of indices (or snapshots) from the cluster, as the actionable list
2. Iterate through a list of user-defined filters to progressively remove indices (or snapshots) from this actionable list as needed.
3. Perform various actions on the items which remain in the actionable list.

### Pre Requisites:
1. Kubernetes 1.12+
2. Helm 2.12+ or Helm 3.0-beta3+

### Installing the Chart
1. Add the stable repo
```
helm repo add csf-stable https://repo.lab.pl.alcatel-lucent.com/csf-helm-stable/
```
2. To install the chart with the release name `my-release` in `logging` namespace
```
helm install --name my-release csf-stable/belk-curator --version <version> --namespace logging
```

The command deploys Curator on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.
> **Tip**: List all releases using `helm list`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

### Parameters:
The following table lists the configurable parameters of the Curator chart and their default values.

| Parameter                           | Description                                   | Default                               |
| ----------------------------------- | ---------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `global.registry`                   | Global Docker image registry for elasticsearch-curator image                       | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com` |
| `global.registry1`                  | Global Docker image registry for kubectl image                                     | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com` |
| `global.seccompAllowedProfileNames` | Annotation that specifies which values are allowed for the pod seccomp annotations |`docker/default` |
| `global.seccompDefaultProfileName`  | Annotation that specifies the default seccomp profile to apply to containers       | `docker/default` |
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
| `global.rbac.enabled`               | Enable/disable rbac. When the flag is set to true, chart creates rbac objects if pre-created serviceaccount is not configured at global/chart level. When the flag is set to false, it is mandatory to configure a pre-created service-account at global/chart level.                                                                      | `true`  |
| `global.serviceAccountName`         | Pre-created SeriveAccountName when rbac.enabled is set to false                    | `null` |
|`customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`customResourceNames.curatorCronJobPod.curatorContainerName`         | Name for curator cronjob pod's container                    | `null` |
|`customResourceNames.deleteJob.name`         | Name for curator delete job                    | `null` |
|`customResourceNames.deleteJob.deleteJobContainerName`         | Name for curator delete job's container                   | `null` |
|`nameOverride`         | Use this to override name for curator cronjob kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`fullnameOverride`         | Use this to configure custom-name for curator cronjob kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
| `curator.image.repo`                | Curator image name. Accepted values are elk_c and elk_c_cos7                                                                 | `elk_c_cos7` |
| `curator.image.tag`                 | Curator image tag                                                                  | `5.8.1-20.09.0` |
| `curator.ImagePullPolicy`           | Curator  image pull policy                                                         | `IfNotPresent` |
| `curator.resources`                 | CPU/Memory resource requests/limits for Curator pod                                | `limits:       cpu: "120m"       memory: "120Mi"     requests:       cpu: "100m"       memory: "100Mi"` |
| `curator.serviceAccountName`        | Pre-created ServiceAccount specifically for curator chart when rbac.enabled is set to false. SA specified here takes precedence over the SA specified in global  | `null` |
| `curator.securityContext.fsGroup`   | Group ID that is assigned for the volumemounts mounted to the pod                  | `1000` |
| `curator.securityContext.supplementalGroups` | The supplementalGroups ID applies to shared storage volumes               | `commented out by default` |
| `curator.securityContext.seLinuxOptions`     | SELinux label to a container                                              | `commented out by default` |
| `curator.custom.annotations`        |  curator specific annotations                                                      | `default value is commented out` |
| `curator.podLabels.resourcetype`    | Additional pod labels                                                              | `default value is commented out` |
| `curator.schedule`                  | Curator cronjob schedule                                                           | `0 1 * * *` |
| `curator.jobSpec.successfulJobsHistoryLimit` | Number of successful CronJob executions that are saved                    | `Even though the value is commented, K8S default value is 3` |
| `curator.jobSpec.failedJobsHistoryLimit`     | Number of failed CronJob executions that are saved                        | `Even though the value is commented, K8S default value is 1` |
| `curator.jobSpec.concurrencyPolicy`          | Specifies how to treat concurrent executions of a Job created by the CronJob controller   | `Even though the value is commented, K8S default value is Allow` |
| `curator.jobTemplateSpec.activeDeadlineSeconds` | Duration of the job, no matter how many Pods are created. Once a Job reaches activeDeadlineSeconds, all of its running Pods are terminated                                                         | `default value is commented out` |
| `curator.jobTemplateSpec.backoffLimit`          | Specifies the number of retries before considering a Job as failed     | `default value is commented out` |
| `curator.configMaps.preCreatedConfigmap`        | Name of pre-created configmap. The configmap must contain the files actions.yml, curator.yml. When the value is set, BELK chart doesn't create curator configmap.                                  | `null` |
| `curator.configMaps.action_file_yml`            | It is a YAML configuration file. The root key must be actions, after which there can be any number of actions, nested underneath numbers    |  `delete indices older than 7 days using age filter` |
| `curator.configMaps.config_yml`                 | The configuration file contains client connection and settings for logging  | `connects to elasticsearch service on 9200 port via http`  |
| `jobResources.requests`                         | CPU/Memory resource requests for post-delete job to delete curator job if leftout after deleting the Release              | `requests:       cpu: "200m"       memory: "500Mi"` |
| `jobResources.limits`                           | CPU/Memory resource limits for post-delete job to delete curator job if leftout after deleting the Release                | `limits:       cpu: "1"       memory: "1Gi"` |
| `istio.enabled`                                 | enable istio using the flag                                            | `false` |
| `istio.envoy_health_chk_port`                   | Health check port of istio envoy proxy                                 | `15020` |
| `searchguard.enable`                            | enable searchguard using the flag                                      | `false` |
| `searchguard.base64_ca_certificate`             | Curator communicating to elasticsearch via SG certificates             | `null`  |


Specify parameters using `--set key=value[,key=value]` argument to `helm install`
```
helm install --name my-release --set istio.enabled=true csf-stable/belk-curator --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,
```
helm install --name my-release -f values.yaml csf-stable/belk-curator --version <version> --namespace logging
```

