# Grafana Helm Chart

* Installs the web dashboarding system [Grafana](http://grafana.org/)

## TL;DR;

```console
$ helm install stable/grafana
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/cpro-grafana
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration


| Parameter                  | Description                         | Default                                                 |
|----------------------------|-------------------------------------|---------------------------------------------------------|
| `rbac.enabled`             | If true, create and use RBAC resources | `true` |
| `rbac.pspUseAppArmor`      | If true, enable apparmor annotations on PSPS and pods | `false`
| `serviceAccountName`       | ServiceAccount to be used for Grafana component |
| `deployOnCompass`          | Set to true when need to deploy on ComPaaS, false when deploy on BCMT(or other K8S) | `false`
| `deploymentStrategy`       | Strategy to create the pods by terminating old version and releasing new one | `Recreate`
| `global.registry`          | Global Docker image registry | `"csf-docker-delivered.repo.lab.pl.alcatel-lucent.com"`
| `global.registry2`         | Global Docker image registry to pull cmdb image | `"csf-docker-delivered.repo.lab.pl.alcatel-lucent.com"`
| `global.registry3`         | Global Docker image registry to pull grafana-tenant image | `"csf-docker-delivered.repo.lab.pl.alcatel-lucent.com"`
| `global.registry4`         | Global Docker image registry to pull download dashboards image | `"registry1-docker-io.repo.lab.pl.alcatel-lucent.com"`
| `global.registry5`         | Global Docker image registry to pull sane image | `"repo.lab.pl.alcatel-lucent.com"`
| `global.annotations`       | Annotations to be added for Grafana resources | `{}`
| `global.labels`            | Labels to be added for Grafana resources | `{}`
| `global.serviceAccountName`| Service Account to be used in Grafana components |
| `global.istioVersion`      | Istio version of the cluster | `1.4`
| `global.podNamePrefix`     | Custom prefix for pod Name  | `""`
| `global.containerNamePrefix` | Custom prefix for container Name | `""`
| `custom.psp.annotations`   | PSP annotations that need to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
| `custom.psp.apparmorAnnotations` | Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
| `custom.psp.labels`        | Custom labels that need to be added to PSP |
| `custom.pod.annotations`   | Pod Annotations to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
| `custom.pod.apparmorAnnotations` | Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
| `custom.pod.labels`        | Custom labels that need to be added to Pod |
| `name`                     | Grafana Container name | `grafana`
| `helm3`                    | Enable this flag to install/upgrade with helm version 3 | `false`
| `appTitle`                 | Title to be used for Grafana Application | `"Performance Monitoring"`
| `HA.enabled`               | Enable this flag to enable HA for Grafana pods | `false`
| `istio.enable`             | Istio feature is enabled or not | `false`
| `istio.mtls_enable`        | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`
| `istio.cni_enable`         | CNI is enabled or not | `true`
| `istio.createKeycloakServiceEntry.enabled` | Enable this flag to create a Service Entry for KeyCloak | `false`
| `istio.createKeycloakServiceEntry.extCkeyHostname` | Hostname with which CKEY is accessible from outside Ex. extCkeyHostname: "ckey.io" | `""`
| `istio.createKeycloakServiceEntry.extCkeyPort` | Port on which ckey is externally accessible. Ex. extCkeyPort: 31390 | `""`
| `istio.createKeycloakServiceEntry.extCkeyProtocol` | Protocol on which ckey is externally accessible. accepted values: HTTP, HTTPS | `""`
| `istio.createKeycloakServiceEntry.ckeyK8sSvcName` | FQDN of ckey k8s service name internally accessible within k8s cluster. Ex. keycloak-ckey.default.svc.cluster.local | `""`
| `istio.createKeycloakServiceEntry.ckeyK8sSvcPort` | Port on which ckey k8s service is accessible. Ex. ckeyK8sSvcPort: 8443 | `""`
| `istio.createKeycloakServiceEntry.hostAlias` | If the host name of ckey is not resolvable then edge node ip has to be given here | `""`
| `istio.createKeycloakServiceEntry.location` | Location specifies whether the service is part of Istio mesh or outside the mesh Ex. MESH_EXTERNAL/MESH_INTERNAL | `"MESH_INTERNAL"`
| `image.imageRepo`          | Image repository | `cpro/grafana-registry1/grafana-tenant` 
| `image.imageTag`           | Image tag. (`Must be >= 5.0.0`) Possible values listed [here](https://hub.docker.com/r/grafana/grafana/tags/).| `7.1.3-1.0.3`
| `image.imagePullPolicy`    | Image pull policy | `IfNotPresent` 
| `runAsUser`                | Grafana containers will be run as the specified user | `65534`
| `fsGroup`                  | fsGroup of Grafana container | `65534`
| `supplementalGroups`       | Supplemental security groups of Grafana Container | `65534`
| `seLinuxOptions.enabled`   | Selinux options in PSP and Security context  of POD | `false`
| `seLinuxOptions.level`     | Selinux level in PSP and Security context of POD | `""`
| `seLinuxOptions.role`      | Selinux role in PSP and Security Context of POD | `""`
| `seLinuxOptions.type`      | Selinux type in PSP and Security context of POD | `""`
| `seLinuxOptions.user`      | Selinux user in PSP and Security context of POD | `""`
| `helmDeleteImage.imageRepo` | Image repo of kubectl | `tools/kubectl`
| `helmDeleteImage.imageTag` | Image tag of kubectl | `v1.17.8-nano`
| `helmDeleteImage.imagePullPolicy` | Image pull policy | `IfNotPresent`
| `helmDeleteImage.resources.limits.cpu` | Kubectl pod resource limits for cpu | `100m`
| `helmDeleteImage.resources.limits.memory` | Kubectl pod resource limits for memory | `100Mi`
| `helmDeleteImage.resources.requests.cpu` | Kubectl pod resource requests for cpu | `50m`
| `helmDeleteImage.resources.requests.memory` | Kubectl pod resource requests for memory | `32Mi`
| `need_dbupdate`           | Enable if DB structure has changed between the from version and to version of the upgrade| `false`
| `sqlitetomdb`             | Enable to do data migrateion from SQLite DB to MariaDB | `false`
| `hookImage.imageRepo`     | Image repo of Grafana LCM Hook | `cpro/grafana-registry1/grafana-lcm-hook`
| `hookImage.imageTag`      | Image tag of Grafana LCM Hook | `1.8.0`
| `hookImage.imagePullPolicy` | Image pull policy | `IfNotPresent`
| `hookImage.resources.limits.cpu` | Grafana LCM Hook pod resource limits for cpu | `500m`
| `hookImage.resources.limits.memory` | Grafana LCM Hook pod resource limits for memory | `1Gi`
| `hookImage.resources.requests.cpu` | Grafana LCM Hook pod resource requests for cpu | `100m`
| `hookImage.resources.requests.memory` | Grafana LCM Hook pod resource requests for memory | `128Mi`
| `mdbToolImage.imageRepo`  | Image repo of Grafana MDB tool | `cpro/grafana-registry1/grafana-mdb-tool`
| `mdbToolImag.imageTag`    | Image tag of Grafana MDB tool | `3.9.0`
| `mdbToolImage.imagePullPolicy` | Image pull policy | `IfNotPresent`
| `mdbToolImage.resources.limits.cpu` | Grafana MDB Tool pod resource limits for cpu | `500m`
| `mdbToolImage.resources.limits.memory` | Grafana MDB Tool pod resource limits for memory | `1Gi`
| `mdbToolImage.resources.requests.cpu` | Grafana MDB tool pod resource requests for cpu | `100m`
| `mdbToolImage.resources.requests.memory` | Grafana MDB Tool pod resource requests for memory | `128Mi`
| `pluginsSideCar.enabled`  | If true, will install Pie chart and Bar chart and Alertmanager datasource plugins | `true`
| `pluginsSideCar.imageRepo` | Image repo of Grafana Plugins | `cpro/grafana-registry1/grafana-plugins`
| `pluginsSideCar.imageTag` | Image tag of Grafana PLugins | `2.0.1`
| `pluginsSideCar.imagePullPolicy` | Image pull policy | `IfNotPresent`
| `pluginsSideCar.resources.limits.cpu` | Grafana plugins pod resource limits for cpu | `500m`
| `pluginsSideCar.resources.limits.memory` | Grafana plugins pod resource limits for memory | `1Gi`
| `pluginsSideCar.resources.requests.cpu` | Grafana plugins pod resource requests for cpu | `100m`
| `pluginsSideCar.resources.requests.memory` | Grafana plugins pod resource requests for memory | `128Mi`
| `sane.enabled`  | If true, sane will be enabled |  `false`
| `sane.port`  | Port to be used  | ``
| `sane.servicePort`  | Specifies the service port |  ``
| `sane.env`  |  Environment key:value pair passed|  ``
| `sane.imageRepo`  |  Image repo for sane  |  `neo-docker-release/grafana-sane`
| `sane.imageTag`  |  Image tag for sane  |  `0.0.11`
| `sane.imagePullPolicy`  |  Specifies image pull policy | `IfNotPresent`
| `sane.ingress.annotations.kubernetes.io/ingress.class`  | annotation Ingress class |  `nginx`
| `sane.ingress.annotations.nginx.ingress.kubernetes.io/ssl-redirect`  | annotation ssl-redirect  |  `true`
| `sane.ingress.labels` | | `{}`
| `sane.ingress.path`  | |  `/`
| `sane.ingress.hosts`  | | ``
| `sane.ingress.tls`  | Specify secretName Eg: grafana-sane-server-tls. Specify hosts Eg: chart-example.local | ``
| `sane.ingress.resources.limits.cpu`  | Specify CPU resource limits for SANE container | `300m`
| `sane.ingress.resources.limits.memory` | Specify Memory resource limits for SANE container | `512Mi`
| `sane.ingress.resources.requests.cpu` | Specify CPU resource requests for SANE container | `100m`
| `sane.ingress.resources.requests.memory` | Specify Memory resource requests for SANE container | `64Mi`
| `keycloak.url`  |  Update ckeyUrl with the deployed keyclock baseurl, ex: 10.76.84.192:32443, ckey.example.com, ckeyistio.example.com:31390i(istio ingress), 10.76.84.192/ckey (ingress)  |  `10.76.84.192:32443`
| `keycloak.protocol`  | Protocol used  |  `https`
| `keycloak.realm`  ||  `cpro`
| `keycloak.secret`  |  Secret used in keycloak  |  ``
| `keycloak.cert`  |  if secret is null, then keycloak use cert. If secret is not null and it is a existing secret name, then use secret Certificate |  ``
| `cbur.enabled`  | If true, will install cbur  | `true`
| `cbur.image.imageRepo`  |  Image repo for cbur  | `cbur/cbura`
| `cbur.image.imageTag`  |  Image tag for cbur  |  `1.0.3-1665`
| `cbur.image.imagePullPolicy`  | Image pull policy for cbur  |  `IfNotPresent`
| `cbur.resource.limit.cpu`  | cbur pod resource limits for cpu  |  `500m`
| `cbur.resource.limit.memory`  | cbur pod resource limits for memory  |  `500Mi`
| `cbur.resources.requests.cpu`  | cbur pod resource requests for cpu  |  `100m`
| `cbur.resources.requests.memory`  |  cbur pod resource requests for memory  |  `128Mi`
| `cbur.backendMode`  | For "local" backend, CBUR will sync with the data in /CBUR_REPO |  `local`
| `cbur.autoEnableCron`  |  If BrPolicy contains spec.cronspec that is not empty, autoEnableCron = true indicates that the cron job is immediately scheduled when the BrPolicy is created, while autoEnableCron = false indicates that scheduling of the cron job should be done on a subsequent backup request. This option only works when k8swatcher.enabled is true  |  `false`
| `cbur.autoUpdateCron`  |  Idicate if subsequent update of cronjob will be done via brpoilicy update. true means cronjob must be updated via brpolicy update, false means cronjob must be updated via manual "helm backup -t app -a enable/disable" command.  |  `false`
| `cbur.cronJob`  |  cronjob frequency, here means very 5 minutes of every day  |  `*/5 * * * *`
| `cbur.maxCopy`  | the maximum copy you want to saved  | `5`
| `customResourceNames.resourceNameLimit` |  providing limit to the custom name created | `63` 
| `customResourceNames.grafanaPod` | section to provide grafana pod specific configuration names | `{}` 
| `customResourceNames.grafanaPod.inCntChangeDbSchema` | field to customize changedbschema init-container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.inCntChangeMariadbSchema` | field to customize changeMariadbSchema init-container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.inCntWaitforMariadb` | field to customize waitforMariadb init-container name in grafana pod  | `""` 
| `customResourceNames.grafanaPod.inCntDownloadDashboard` | field to customize downloaddashboard init-container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.pluginsidecar` | field to customize pluginsidecar container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.grafanaSidecarDashboard` | field to customize grafanaSidecarDashboard container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.grafanaSaneAuthproxy` | field to customize grafanaSaneAuthproxy container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.grafanaMdbtool` | field to customize grafanaMdbtool container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.grafanaDatasource` | field to customize grafanaDatasource container name in grafana pod | `""` 
| `customResourceNames.grafanaPod.grafanaContainer` | field to customize grafanaContainer container name in grafana pod | `""` 
| `customResourceNames.deleteDatasourceJobPod` | section to provide deleteDatasourcejobPod  customized  pod and container  names | `{}` 
| `customResourceNames.deleteDatasourceJobPod.name` | the name field which is under the section deleteDatasourcejobPod used for customizing pod name | `""` 
| `customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer` | the deleteDatasourceContainer field which is under the section deleteDatasourcejobPod used for customizing container name in deleteDatasourcejobPod | `""` 
| `customResourceNames.setDatasourceJobPod` | section to provide setDatasourcejobPod  customized  pod and container  names | `{}` 
| `customResourceNames.setDatasourceJobPod.name` |  the name field which is under the section setDatasourcejobPod used for customizing pod name | `""` 
| `customResourceNames.setDatasourceJobPod.setDatasourceContainer` | the setDatasourceContainer field which is under the section setDatasourcejobPod used for customizing container name in setDatasourcejobPod| `""` 
| `customResourceNames.postUpgradeJobPod` | section to provide postUpgradejobPod  customized  pod and container  names | `{}` 
| `customResourceNames.postUpgradeJobPod.name` |  the name field which is under the section postUpgradejobPod used for customizing pod name | `""` 
| `customResourceNames.postUpgradeJobPod.postUpgradeJobContainer` | the postUpgradejobContainer field which is under the section postUpgradejobPod used for customizing container name in postUpgradejobPod| `""` 
| `customResourceNames.postDeleteJobPod` | section to provide postDeletejobPod  customized  pod and container names | `{}` 
| `customResourceNames.postDeleteJobPod.name` |  the name field which is under the section postDeletejobPod used for customizing pod name | `""` 
| `customResourceNames.postDeleteJobPod.deletedbContainer` | the deletedbContainer field which is under the section postDeletejobPod used for customizing container name in postDeletejobPod | `""` 
| `customResourceNames.postDeleteJobPod.deletesecretsContainer` | the deletesecretsContainer field which is under the section postDeletejobPod used for customizing container name in postDeletejobPod | `""` 
| `customResourceNames.importDashboardjobPod` | section to provide importDashboardjobPod  customized  pod and container names | `{}` 
| `customResourceNames.importDashboardjobPod.name` |  the name field which is under the section postDeletejobPod used for customizing pod name | `""` 
| `customResourceNames.importDashboardJobPod.importDashboardjobContainer` | the importDashboardjobContainer field which is under the section importDashboardjobPod used for customizing container name in importDashboardjobPod | `""` 
| `downloadDashboardsImage.enabled` | Image for Downloading dashboards | `false`
| `downloadDashboardsImage.imageRepo` | Image repo for DownloadDashboards | `appropriate/curl`
| `downloadDashboardsImage.tag` | Image Tag for DownloadDashboards | `latest`
| `downloadDashboardsImage.pullPolicy` | Image pull policy | `IfNotPresent`
| `podAnnotations.prometheus.io/port` | Pod Annotations for Port | `3000`
| `podAnnotations.prometheus.io/scrape` | Pod Annotation for Scrape | `true`
| `dbIP` | Database IP address (the IP address should be filed, if need_deployed: false; it should be ignored, if need_deployed: true) | `grafanadb-cmdb-mysql`
| `dbName` | Name of the grafana database in CMDB | `grafana`
| `dbUser` | Username of the grafana DB in CMDB | `grafana`
| `dbPassword` | Password to Grafana DB | `grafana`	
| `cmdb.enabled`  | If true, Mariadb will be installed |  `false`
| `cmdb.need_deployed`  |  If true, mariadb will be deployed with grafana deployment  | `false`
| `cmdb.retain_data`  |   If retain_data is true, will retain grafana data in mariadb when deleting grafana instance  | `false`
| `cmdb.rbac_enabled`  |  If true, role based access is enabled  | `true`
| `cmdb.cluster_type`  |  If simplex, CLUSTER_SIZE should be 1. If galera, CLUSTER_SIZE should be odd (minimum 3). If master-master, Deploy Master-Master Replication cluster. CLUSTER_SIZE should be 2. If master-slave, Deploy Master-Slave Replication cluster. CLUSTER_SIZE can be any integer, first node will be Master, rest will be Slaves.  |  `simplex`
| `cmdb.cluster_name`  |  Name of the cluster  |  `my-cluster`
| `cmdb.istio.enabled`  |  Whether to enable istio or not  | `false`
| `cmdb.cacert`  | certificate authority value to placed  |  
| `cmdb.clientcert` |  client certificate value to be placed  |  
| `cmdb.mariadb.root_password`  |  Root password for mariabd  |  ``
| `cmdb.mariadb.allow_root_all` |If root user should be allowed from all hosts |  `false`
| `cmdb.mariadb.count`  |  The number of MariaDB pods to create  |  `1`
| `cmdb.mariadb.auto_rollback`  |  If automatic rollback of the database should be performed on pod restarts  |  `true`| `cmdb.mariadb.use_tls`  |  Use TLS for data in flight to/from client  |  `false`
| `cmdb.mariadb.certificates.ca_cert`  |  CA cert file|  `ca-cert.pem`
| `cmdb.mariadb.certificates.ca_key`  |  CA key file  |  `ca-key.pem`
| `cmdb.mariadb.certificates.client_cert`  |  client cert file  |  `client-cert.pem`
| `cmdb.mariadb.certificates.client_key`  |  client key file  |  `client_key.pem`
| `cmdb.mariadb.certificates.client_req`  |  client request file  |  `client-req.pem`
| `cmdb.mariadb.certificates.server_cert`  |  server certificate file  |  `server-cert.pem`
| `cmdb.mariadb.certificates.server_key`  |  server key file  |  `server-key.pem`
| `cmdb.mariadb.certificates.server_req`  | server request file  |  `server-req.pem`
| `cmdb.mariadb.certificates.secret`  ||
| `cmdb.mariadb.databases.name`  |  Namw of the database  |  `grafana`
| `cmdb.mariadb.databases.character_set`  |  Character set encoding that to be used  |  `utf8`
| `cmdb.mariadb.databases.collate`  ||  `utf8_general_ci`
| `cmdb.mariadb.users.name`  |  Name of the user  |  `grafana`
| `cmdb.mariadb.users.password`  |  Password for that user(base64 encoded:grafana)  | `Z3JhZmFuYQ==`
| `cmdb.mariadb.users.host`  || `%`
| `cmdb.mariadb.users.privilege`  |  Privilege given to the user  |  `ALL`
| `cmdb.mariadb.users.object`  ||  `grafana.*`
| `cmdb.mariadb.users.requires`  |  if use_tls set, require SSL/X509 or not  |  ``
| `cmdb.mariadb.persistence.enabled`  |  To enable persistence  |  `true`
| `cmdb.mariadb.persistence.accessMode`  |  Specifies what is the access mode for persistence  |  `ReadWriteOnce`
| `cmdb.mariadb.persistence.size`  |  Size of the persistence  |  `20Gi`
| `cmdb.mariadb.persistence.storageClass` | Storage class of Persistence | `""`
| `cmdb.mariadb.persistence.resourcePolicy` | Resource policy of Persistebce | `delete`
| `cmdb.mariadb.persistence.preserve_pvc` | Preserve PVC policy of persistence | `false`
| `cmdb.mariadb.persistence.backup.enabled` | Enable backup for persistence | `true`
| `cmdb.mariadb.persistence.backup.storageClass` | Storage class of Persistence backup | `""`
| `cmdb.mariadb.persistence.backup.accessMode` | Access mode of Persistence backup | `ReadWriteOnce`
| `cmdb.mariadb.persistence.backup.size` | Size of the persistence backup  |  `20Gi`
| `cmdb.mariadb.persistence.backup.resourcePolicy` | Resource policy of Persistence backup | `delete`
| `cmdb.mariadb.persistence.backup.preserve_pvc` | Preserve PVC policy of persistence backup | `false`
| `cmdb.mariadb.persistence.backup.dir` | Backup Directory | `/mariadb/backup`
| `cmdb.mariadb.mysqld_site_conf` | A customized mysqld.conf to import | `[mysqld] userstat = on`
| `cmdb.mariadb.resources.requests.cpu` | Resource requests for CPU for MariaDB | `250m`
| `cmdb.mariadb.resources.requests.memory` | Resource requests for Memory for MariaDB | `256Mi`
| `image.imagePullPolicy`    | Image pull policy | `IfNotPresent` 
| `service.type`             | Kubernetes service type | `ClusterIP` 
| `service.port`             | Kubernetes port where service is exposed| `80` 
| `service.annotations`      | Service annotations | `{}` 
| `service.annotationsForScrape` | Service annotations | `prometheus.io/scrape: "true"` 
| `service.labels`           | Custom labels                       | `{}`
| `ingress.enabled`          | Enables Ingress | `false` 
| `ingress.annotations`      | Ingress annotations | `{}` 
| `ingress.labels`           | Custom labels                       | `{}`
| `ingress.hosts`            | Ingress accepted hostnames | `[]` 
| `ingress.path`             | Ingress path | `/grafana/?(.*)`
| `ingress.tls`              | Ingress TLS configuration | `[]` 
| `istioIngress.enabled`     | Enable to use istio ingress gateway(Envoy) | `true`
| `istioIngress.Contextroot` | when istio is enabled: root_url path and Contextroot path should match | `grafana`
| `istioIngress.selector`    | Istio ingress gateway selector | `{istio: ingressgateway}`
| `istioIngress.host`        | the host used to access the management GUI from istio ingress gateway | `"*"`
| `istioIngress.httpPort`    | HTTP port to access GUI from ISTIO Ingress gatway | `80`
| `istioIngress.gatewayName` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `"istio-system/single-gateway-in-istio-system"`
| `istioIngress.tls.enabled` | tls section will be used if gatewayName is empty | `true`
| `istioIngress.tls.httpsPort` | HTTPS port for TLS section | `443`
| `istioIngress.tls.mode` | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`
| `istioIngress.tls.credentialName` | Secret name for Istio Ingress | `"am-gateway"`
| `resources.limits.cpu`    | CPU Resource limit for Grafana Pod | `500m`
| `resources.limits.memory` | Memory Resource limit for Grafana Pod | `1Gi`
| `resources.requests.cpu`  | CPU Resource REquests for Grafana Pod | `100m`
| `resources.requests.memory` | Memory Resource REquests for Grafana Pod | `128Mi`
| `nodeSelector`             | Node labels for pod assignment | `{}`
| `tolerations`              | Toleration labels for pod assignment | `[]` 
| `affinity`                 | Affinity settings for pod assignment | `{}` 
| `nodeAntiAffinity`         | Antiaffinity for Pod Assignments | `hard`
| `persistence.enabled`      | Use persistent volume to store data | `false` 
| `persistence.size`         | Size of persistent volume claim | `10Gi` 
| `persistence.existingClaim`| Use an existing PVC to persist data | `nil` 
| `persistence.storageClassName` | Type of persistent volume claim | `nil` 
| `persistence.accessModes`  | Persistence access modes | `[]` 
| `persistence.subPath`      | Mount a sub directory of the persistent volume if set | `""` 
| `persistence.annotations` | Persistence Annotations | `{}`
| `adminUser`                | Admin User name of Grafana UI | `admin`
| `schedulerName`            | Alternate scheduler name | `nil` 
| `env`                      | Extra environment variables passed to pods | `{}` 
| `envFromSecret`            | The name of a Kubenretes secret (must be manually created in the same namespace) containing values to be added to the environment | `""` 
| `extraSecretMounts`        | Additional grafana server secret mounts | `[]` 
| `plugins`                  | Pass the plugins you want installed as a comma separated list. | `""`
| `SetDatasource.enabled`    | If true, an initial Grafana Datasource will be set | `true`
| `SetDatasource.imageRepo`  | Image Repository for SetDatasource Container | `cpro/grafana-registry1/grafana-curl`
| `SetDatasource.imageTag`   | Image tag | `"1.16.0"`
| `SetDatasource.imagePullPolicy` | Image Pull policy | `IfNotPresent`
| `SetDatasource.resources.requests.cpu` | Resource requests for CPU
| `SetDatasource.resources.requests.memory` | Resource requests for memory
| `SetDatasource.resources.limits.cpu` | Resource limits for CPU
| `SetDatasource.resources.limits.memory` |  Resource limits for memory | 
| `SetDatasource.datasource.name` | The datasource name. | `prometheus`
| `SetDatasource.datasource.type` | Datasource type | `prometheus`
| `SetDatasource.datasource.url` | The url of the datasource. To set correctly you need to know the right datasource name and its port ahead. Check kubernetes dashboard or describe the service should fulfill the requirements. Synatx like `http://<release name>-<server name>:<port number> | `"http://prometheus-cpro-server"`
| `SetDatasource.datasource.proxy` | Specify if Grafana has to go thru proxy to reach datasource | `proxy` 
| `SetDatasource.datasource.isDefault` | Specify should Grafana use this datasource as default | `true`
| `SetDatasource.restartPolicy` | Specify the job restart policy | `OnFailure`
| `SetDashboard.enabled` | enable to import the initial set of dashboards  | `true`
| `SetDashboard.backoffLimit` | Dashboard limit | `10`
| `SetDashboard.overwrite` | When upgrade if overwrite = true, dashboards in old release will be overwrited by dashboards in new chart | `true`
| `SetDashboard.tinytools.imageRepo` | Image repository | `cpro/grafana-registry1/grafana-tiny-tools`
| `SetDashboard.tinytools.imageTag` | Image Tag | `"1.8.0"`
| `SetDashboard.tinytools.imagePullPolicy` | Image Pull policy  | `IfNotPresent`
| `SetDashboard.resourcesTinytools.limits.cpu` |  CPU Resource limits | `200m`
| `SetDashboard.resourcesTinytools.limits.memory` | Memory Resource limits | `128Mi`
| `SetDashboard.resourcesTinytools.requests.cpu` | Resource requests CPU | `100m`
| `SetDashboard.resourcesTinytools.requests.memory` | Resource requests for memory | `64Mi`
| `dashboardProviders` | Configure grafana dashboard providers. ref: http://docs.grafana.org/administration/provisioning/#dashboards | `{}`
| `dashboards` | Configure grafana dashboard to import. NOTE: To use dashboards you must also enable/configure dashboardProviders ref: https://grafana.com/dashboards | `{}`
| `livenessProbe.scheme` | Liveness Probe scheme | `HTTPS`
| `livenessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `60`
| `livenessProbe.timeoutSeconds` | Time out seconds | `1`
| `livenessProbe.failureThreshold` | Failure threshold | `10`
| `livenessProbe.periodSeconds` | Period in seconds | `3`
| `readinessProbe.scheme` | Readiness Probe scheme | `HTTPS
| `readinessProbe.initialDelaySeconds` | Liveness Probe initial delay seconds | `60`
| `readinessProbe.timeoutSeconds` | Time out seconds | `30`
| `readinessProbe.failureThreshold` | Failure threshold | `10`
| `readinessProbe.periodSeconds` | Period in seconds | `10`
| `scheme` | Grafana Scheme | `https` 
| `grafana.server_cert` | mounted to file /etc/grafana/ssl/server.crt | 
| `grafana.server_key` | mounted to file /etc/grafana/ssl/server.key | 
| `grafana_ini.paths.data` | Grafana primary configuration. NOTE: values in map will be converted to ini format. ref: http://docs.grafana.org/installation/configuration/ | `/var/lib/grafana/data`
| `grafana_ini.paths.logs` | Path where grafana logs get stored | `/var/log/grafana` 
| `grafana_ini.paths.plugins`| Plugins | `/var/lib/grafana/plugins`
| `grafana_ini.paths.provisioning`| Provisioning  | `/etc/grafana/provisioning`
| `grafana_ini.analytics.check_for_updates` |  | `false`
| `grafana_ini.analytics.reporting_enabled` |  | `false`
| `grafana_ini.log.mode`    |   | `console`	
| `grafana_ini.grafana_net.url` |  | `https://grafana.net`
| `grafana_ini.server.protocol` |  | `https`
| `grafana_ini.server.root_url` | when istio is enabled: root_url path and Contextroot path should match  | `""`
| `grafana_ini.server.cert_file` |  | `/etc/grafana/ssl/server.crt`
| `grafana_ini.cert_key` |  | `/etc/grafana/ssl/server.key`
| `grafana_ini.serve_from_sub_path` | set to true when istio is enabled | `true`
| `grafana_ini.security.cookie_secure` | Set to true if you host Grafana behind HTTPS. Default is false | `false`
| `grafana_ini.users.allow_sign_up` |   | `true`
| `grafana_ini.users.allow_org_create` |   | `true`
| `grafana_ini.users.auto_assign_org` |   | `true`
| `grafana_ini.users.auto_assign_org_role` |  | `Viewer`
| `grafana_ini.auth.disable_login_form` |  | `false`
| `grafana_ini.auth.disable_signout_menu` |  | `false`
| `grafana_ini.auth.signout_redirect_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/logout?redirect_uri=https://10.76.62.42"`
| `grafana_ini.auth.generic_oauth.enabled` |  | `false`
| `grafana_ini.auth.generic_oauth.name`    |  | `"{{ .Values.keycloak.realm }}"`
| `grafana_ini.auth.generic_oauth.client_id` |  | `grafana`
| `grafana_ini.auth.generic_oauth.client_secret` |  | `1a1a7188-b5b7-4c19-8459-c45c32a64437`
| `grafana_ini.auth.generic_oauth.scopes` |  | `openid`
| `grafana_ini.auth.generic_oauth.auth_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/auth"`
| `grafana_ini.auth.generic_oauth.token_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/token"` 
| `grafana_ini.auth.generic_oauth.api_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/userinfo"` 
| `grafana_ini.auth.generic_oauth.introspect_url` |  | `"{{ .Values.keycloak.protocol }}://{{ .Values.keycloak.url }}/auth/realms/{{ .Values.keycloak.realm }}/protocol/openid-connect/token/introspect"`
| `grafana_ini.allow_sign_up` |  | `true`
| `grafana_ini.tls_client_ca` |  | `/etc/grafana/keycloak/keycloak.crt`
| `grafana_ini.tls_skip_verify_insecure` |  | `false`
| `grafana_ini.role_attribute_path` | role_attribute_path is only available from Grafana v6.5+. | ``
| `grafana_ini.database.type` |  | `sqlite3`
| `grafana_ini.database.host` |  | `grafanadb-cmdb-mysql:3306`
| `grafana_ini.database.name` |  | `grafana`
| `grafana_ini.database.user` |  | `grafana`
| `grafana_ini.database.password` |  | `grafana`
| `grafana_ini.ssl_mode` |  | `true`
| `grafana_ini.ca_cert_path` |  | `/etc/grafana/cmdbtls/ca.crt`
| `grafana_ini.client_key_path` |  | `/etc/grafana/cmdbtls/client.key`
| `grafana_ini.server_cert_name` |  | `grafanadb-cmdb-mysql.default.svc.cluster.local`
| `ldap.existingSecret` | Grafana LDAP configuration. NOTE: To enable the grafana.ini must be configured with auth.ldap.enabled. `existingSecret` is a reference to an existing secret containing the ldap configuration | `""`
| `ldap.config` | `config` is the content of `ldap.toml` that will be stored in the created secret | `""`
| `smtp.existingSecret` | Grafana SMTP configuration. `existingSecret` is a reference to an existing secret containing the smtp configuration | `""`
| `sidecar.imageRepo` | Sidecars that collect the configmaps with specified label and stores the included files them into the respective folders. Requires at least Grafana 5 to work and cannot be used together with parameters dashboardProviders, datasources and dashboards | `kiwigrid/k8s-sidecar`
| `sidecar.imageTag` | Image tag | `0.1.209`
| `sidecar.imagePullPolicy` | Image Pull policy | `IfnotPresent`
| `sidecar.resources.limits.cpu` | Resource limits for CPU | `100m`
| `sidecar.resources.limits.memory` | Resource limits for Memory | `100Mi`
| `sidecar.resources.requests.cpu` | Resource requests for CPU | `50m`
| `sidecar.resources.requests.memory` | Resource requests for Memory | `50Mi`
| `sidecar.dashboards.folder` | folder in the pod that should hold the collected dashboards | `/tmp/dashboards`
| `sidecar.dashboards.enabled`            | Enabled the cluster wide search for dashboards and adds/updates/deletes them in grafana | `false` 
| `sidecar.dashboards.label`            | Label that config maps with dashboards should have to be added | `false` 
| `sidecar.datasources.enabled`            | Enabled the cluster wide search for datasources and adds/updates/deletes them in grafana | `false` 
| `sidecar.datasources.label`            | Label that config maps with datasources should have to be added | `false` 
| `datasources`              | Configure grafana datasources | `{}` 
| `dashboardProviders`       | Configure grafana dashboard providers | `{}` 
| `dashboards`               | Dashboards to import | `{}` 
| `grafana.ini`              | Grafana's primary configuration | `{}` 
| `ldap.existingSecret`      | The name of an existing secret containing the `ldap.toml` file, this must have the key `ldap-toml`. | `""` 
| `ldap.config  `            | Grafana's LDAP configuration    | `""` 
| `annotations`              | Deployment annotations | `{}` 
| `podAnnotations`           | Pod annotations | `{}` 
| `sidecar.dashboards.enabled`            | Enabled the cluster wide search for dashboards and adds/updates/deletes them in grafana | `false` 
| `sidecar.dashboards.label`            | Label that config maps with dashboards should have to be added | `false` 
| `sidecar.datasources.enabled`            | Enabled the cluster wide search for datasources and adds/updates/deletes them in grafana | `false` 
| `sidecar.datasources.label`            | Label that config maps with datasources should have to be added | `false` 
| `smtp.existingSecret`      | The name of an existing secret containing the SMTP credentials, this must have the keys `user` and `password`. | `""` |

## Sidecar for dashboards

If the parameter `sidecar.dashboards.enabled` is set, a sidecar container is deployed in the grafana pod. This container watches all config maps in the cluster and filters out the ones with a label as defined in `sidecar.dashboards.label`. The files defined in those configmaps are written to a folder and accessed by grafana. Changes to the configmaps are monitored and the imported dashboards are deleted/updated. A recommendation is to use one configmap per dashboard, as an reduction of multiple dashboards inside one configmap is currently not properly mirrored in grafana.
Example dashboard config:
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-grafana-dashboard
  labels:
     grafana_dashboard: 1
data:
  k8s-dashboard.json: |-
  [...]
```

## Sidecar for datasources

If the parameter `sidecar.datasource.enabled` is set, a sidecar container is deployed in the grafana pod. This container watches all config maps in the cluster and filters out the ones with a label as defined in `sidecar.datasources.label`. The files defined in those configmaps are written to a folder and accessed by grafana on startup. Using these yaml files, the data sources in grafana can be modified.

Example datasource config adapted from [Grafana](http://docs.grafana.org/administration/provisioning/#example-datasource-config-file):
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-grafana-datasource
  labels:
     grafana_datasource: 1
data:
	datasource.yaml: |-
		# config file version
		apiVersion: 1

		# list of datasources that should be deleted from the database
		deleteDatasources:
		  - name: Graphite
		    orgId: 1

		# list of datasources to insert/update depending
		# whats available in the database
		datasources:
		  # <string, required> name of the datasource. Required
		- name: Graphite
		  # <string, required> datasource type. Required
		  type: graphite
		  # <string, required> access mode. proxy or direct (Server or Browser in the UI). Required
		  access: proxy
		  # <int> org id. will default to orgId 1 if not specified
		  orgId: 1
		  # <string> url
		  url: http://localhost:8080
		  # <string> database password, if used
		  password:
		  # <string> database user, if used
		  user:
		  # <string> database name, if used
		  database:
		  # <bool> enable/disable basic auth
		  basicAuth:
		  # <string> basic auth username
		  basicAuthUser:
		  # <string> basic auth password
		  basicAuthPassword:
		  # <bool> enable/disable with credentials headers
		  withCredentials:
		  # <bool> mark as default datasource. Max one per org
		  isDefault:
		  # <map> fields that will be converted to json and stored in json_data
		  jsonData:
		     graphiteVersion: "1.1"
		     tlsAuth: true
		     tlsAuthWithCACert: true
		  # <string> json object of data that will be encrypted.
		  secureJsonData:
		    tlsCACert: "..."
		    tlsClientCert: "..."
		    tlsClientKey: "..."
		  version: 1
		  # <bool> allow users to edit datasources from the UI.
		  editable: false

```
# Grafana Helm Chart

* Installs the web dashboarding system [Grafana](http://grafana.org/)

| `sidecar.dashboards.label`            | Label that config maps with dashboards should have to be added | false |
| `sidecar.datasources.enabled`            | Enabled the cluster wide search for datasources and adds/updates/deletes them in grafana | false |
| `sidecar.datasources.label`            | Label that config maps with datasources should have to be added | false |
| `smtp.existingSecret`      | The name of an existing secret containing the SMTP credentials, this must have the keys `user` and `password`. | `""` |

## Sidecar for dashboards

If the parameter `sidecar.dashboards.enabled` is set, a sidecar container is deployed in the grafana pod. This container watches all config maps in the cluster and filters out the ones with a label as defined in `sidecar.dashboards.label`. The files defined in those configmaps are written to a folder and accessed by grafana. Changes to the configmaps are monitored and the imported dashboards are deleted/updated. A recommendation is to use one configmap per dashboard, as an reduction of multiple dashboards inside one configmap is currently not properly mirrored in grafana.
Example dashboard config:
```
apiVersion: v1
kind: ConfigMap
# Grafana Helm Chart

* Installs the web dashboarding system [Grafana](http://grafana.org/)

## TL;DR;

```console
$ helm install stable/grafana
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/grafana
```

## RBAC Configuration
Roles and RoleBindings resources will be created automatically for `grafana` service.

To manually setup RBAC you need to set the parameter `rbac.enabled=false` and specify the service account to be used for each service by setting the parameters: `global.serviceAccountName`and `serviceAccountName` to the name of a pre-existing service account

