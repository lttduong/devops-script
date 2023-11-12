# CPRO-Gen3GPPXML tool

[CPRO-Gen3GPPXML](https://confluence.app.alcatel-lucent.com/display/plateng/CPRO+-+Gen3GPPXML+tool+Guide) is a tool to retrieve measurement data from Prometheus server and generate the corresponding 3GPP XML file. End user can configure the file generation period and the output metric set.

## TL;DR;

```bash
$ helm install stable/cpro-gen3gppxml
```

## Introduction

This chart bootstraps an gen3gppxml Service deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ 
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

- ```$  helm fetch stable/cpro-gen3gppxml```
- ```$  tar xzvf cpro-gen3gppxml-XX.YY.ZZ.tgz --warning=no-timestamp```
- ```$  helm install cpro-gen3gppxml ––name my-release```

The command deploys Gen3GPPXML Service on the Kubernetes cluster in the default configuration. The [configuration](https://confluence.app.alcatel-lucent.com/display/plateng/CPRO+-+Gen3GPPXML+tool+Guide#CPRO-Gen3GPPXMLtoolGuide-ConfigurationConfiguration) section lists the parameters that can be configured during installation.


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration
Please refer to the [Gen3GPPXML Configuration](https://confluence.app.alcatel-lucent.com/display/plateng/CPRO+-+Gen3GPPXML+tool+Guide#CPRO-Gen3GPPXMLtoolGuide-ConfigurationConfiguration) documentation.

A YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml cpro-gen3gppxml
```

## Persistence

The Gen3GPPXML service stores the generated XML files at the `/var/3gppxml` path of the container.

The chart mounts a Persistent Volume volume at this location. The volume is created using dynamic volume provisioning.

## Configuration


Parameter | Description | Default
--------- | ----------- | -------
`replicaCount` | No of replicas of Gen3gppxml pod | `1`
`global.registry` | Global Docker image registry | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`
`global.registry2` | Global Docker image registry | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`
`global.annotations` | Annotations to be added for Gen3gppxml resources | `{}`
`global.labels` | Labels to be added for Gen3gppxml resources | `{}`
`global.serviceAccountName` | Service Account to be used in CPRO components |
`global.istioVersion` | Istio version of the cluster | `1.4`
`global.podNamePrefix` | field to provide custom prefix for pod name in gen3gppxml chart | `""` 
`global.containerNamePrefix` | field to provide custom prefix for container name in gen3gppxml chart | `""` 
`persistence.pvc_auto_delete` | If set to true, the pvc created during chart deployment will be deleted during uninstalll | `true`
`custom.psp.annotations` | PSP annotations that need to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
`custom.psp.apparmorAnnotations` | Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
`custom.psp.labels` | Custom labels that need to be added to PSP |
`custom.pod.annotations` | Pod Annotations to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
`custom.pod.apparmorAnnotations` |  Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
`custom.pod.labels` | Custom labels that need to be added to Pod |
`customResourceNames.resourceNameLimit` | customized string length limit to the pod name and container name | `63` 
`customResourceNames.gen3gppxmlPod.gen3gppxmlContainer` | custom container name to gen3gppxml container in gen3gppxml pod | `""` 
`customResourceNames.gen3gppxmlPod.sftpContainer` | custom container name to sftpContainer container in gen3gppxml pod | `""` 
`customResourceNames.gen3gppxmlPod.configMapReloadContainer` | custom container name to configMapReloadContainer container in gen3gppxml pod | `""` 
`customResourceNames.postDeletejobPod.name` | custom pod name for  postDeletejob pod in gen3gppxml | `""` 
`customResourceNames.postDeletejobPod.postDeletePvcContainer` | custom container name for delete pvc container in postDeletejob pod | `""` 
`name` | Gen3gppxml Container name | `gen3gppxml`
`antiAffinityMode` |  soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`helm3` | Enable this flag to install/upgrade with helm version 3 | `false`
`rbac.enabled` | If true, create and use RBAC resources | `true`
`rbac.pspUseAppArmor` | If true, enable apparmor annotations on PSPS and pods | `false`
`serviceAccountName` | ServiceAccount to be used for Gen3gppxml component | 
`lcm.scale.timeout` | Timeout before scaling | `180`
`image.imageRepo` | Gen3gppxml container image repository | `"cpro-gen3gppxml"`
`image.imageTag` | Gen3gppxml container image tag | `3.0.0-2.0.1`
`image.pullPolicy` | Gen3gppxml container image Pull policy | `IfNotPresent`
`resources.requests.memory` | Gen3gppxml pod resource requests of memory | `256Mi`
`resources.requests.cpu` | Gen3gppxml pod resource requests of cpu | `250m`
`resources.limits.memory` | Gen3gppxml pod resource limits of memory | `1024Mi`
`resources.limits.cpu` | Gen3gppxml pod resource limits of cpu | `500m`
`seLinuxOptions.enabled` | Selinux options in PSP and Security context  of POD | `false`
`seLinuxOptions.level` | Selinux level in PSP and Security context of POD | `""`
`seLinuxOptions.role` | Selinux role in PSP and Security Context of POD | `""`
`seLinuxOptions.type` | Selinux type in PSP and Security context of POD | `""`
`seLinuxOptions.user` | Selinux user in PSP and Security context of POD | `""`
`service.name` | Name of Gen3gppxml service | `gen3gppxml`
`service.serviceType` | Type of Gen3gppxml service | `ClusterIP`
`service.sftpPort` | Port number of SFTP service | `2309`
`service.sftpNodePort` | Node port number of SFTP service | `30022`
`service.restHttpPort` | Port number of REST HTTP service | `8080`
`service.restHttpsPort` | Port number of REST HTTPS service | `8081`
`kubectl.image.repo` | kubectl container repository | `tools/kubectl` 
`kubectl.image.tag` | kubectl container image tag | `v1.14.3-nano`
`kubectl.jobResources.requests.cpu` | Kubectl container resource requests of cpu | `200m`
`kubectl.jobResources.requests.memory` | Kubectl container resource requests of memory | `500Mi`
`kubectl.jobResources.limits.cpu` | Kubectl container resource limits of cpu | `1`
`kubectl.jobResources.limits.memory` | Kubectl container resource limits of memory | `1Gi`
`cbur.enabled` | If true, CBUR feature will be enabled for Gen3gppxml | `true`
`cbur.image.repository` | cbur side-car container image repository | `cbur/cbura`
`cbur.image.tag` | cbur side-car container image tag | `1.0.3-983`
`cbur.image.pullPolicy` | cbur side-car container image pull policy | `IfNotPresent`
`cbur.resources.requests.memory` | cbur side-car resource requests of memory | `256Mi` 
`cbur.resources.requests.cpu` | cbur side-car resource requests of cpu | `250m`
`cbur.resources.limits.memory` | cbur side-car resource limits of memory | `1024Mi`
`cbur.resources.limits.cpu` | cbur side-car resource limits of cpu | `500m`
`cbur.backendMode` | CBUR backend mode | `"local"`
`cbur.autoEnableCron` | indicates that the cron job is immediately scheduled when the BrPolicy is created or not | `false`
`cbur.autoUpdateCron` | cronjob must be updated via brpolicy update or not | `false`
`cbur.cronJob` | It is used for scheduled backup task. Empty string is allowed for no scheduled backup | `"*/10 * * * *"`
`cbur.maxCopy` | Limit the number of copies that can be saved. Once it is reached, the newer backup will overwritten the oldest one | `5`
`istio.enable` | Istio feature is enabled or not | `false`
`istio.mtls_enable` | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`
`istio.cni_enable` | CNI is enabled or not | `true`
`istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`
`istioIngress.selector` | selector for Gateway | `{istio: ingressgateway}`
`istioIngress.Contextroot` | Context root that is used to distinguish services | `gen3gppxml`
`istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `"*"`
`istioIngress.httpPort` | Istio ingress http port | `80`
`istioIngress.gatewayName` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here gatewayName is used for http/https | `"istio-system/single-gateway-in-istio-system"`
`istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `false`
`istioIngress.tls.httpsPort` | Istio ingress https port | `443`
`istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, PASSTHROUGH | `PASSTHROUGH`
`istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`
`istioIngress.tcpGatewayName` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here. tcpGatewayName is used for sftp | 
`istioIngress.sftpPort` | ISTIO Ingress SFTP Port | `31400`
`istioIngress.tcpHost` | the host used to access the management GUI from istio ingress gateway(for tcp) | `"*"`
`configmapReload.image.repository` | ConfigmapReload container image repository | `cpro/registry4/configmap-reload`
`configmapReload.image.tag` | ConfigmapReload container image tag | `v0.2.1-3`
`configmapReload.image.pullPolicy` | ConfigmapReload container image pull policy | `IfNotPresent`
`configmapReload.resources.requests.memory` | ConfigmapReload container resources request for memory | `256Mi`
`configmapReload.resources.requests.cpu` |  ConfigmapReload container resources request for cpu | `250m`
`configmapReload.resources.limits.memory` | ConfigmapReload container resources limit for memory | `1024Mi`
`configmapReload.resources.limits.cpu` | ConfigmapReload container resources limit for cpu | `500m`
`containerSecurityContext.runAsUser` | Security context of Gen3gppxml pods. Containers will be run as the mentioned user | `1001`
`sftp.image.repository` | SFTP container image repository | `cpro-gen3gppxml-proftpd`
`sftp.image.tag` | SFTP container image tag | `3.0.0-2.0.1`
`sftp.image.pullPolicy` | SFTP container image pull policy | `IfNotPresent`
`sftp.resources.requests.memory` | SFTP container resources request for memory | `256Mi`
`sftp.resources.requests.cpu` | SFTP container resources request for cpu | `250m`
`sftp.resources.limits.memory` | SFTP container resources limit for memory | `1024Mi`
`sftp.resources.limits.cpu` | SFTP container resources limit for cpu | `500m`
`sftp.user` | SFTP user | `sftp`
`sftp.logLevel` | Log level | `3`
`sftp.authentication.passwd.enabled` | Enable SFTP login using password | `true`
`sftp.authentication.passwd.rsaKey` | Encrypted SFTP RSA Key | Default RSA Key
`sftp.authentication.passwd.passwd` | Encrypted SFTP Password | Default SFTP password
`sftp.authentication.key.enabled` | Enable SFTP login using key | `true`
`sftp.authentication.key.key` | Public key | Default SFTP public key
`configOverride` | User can use the configOverride to override the configuration in configs/Gen3GPPXML | ` OVERRIDE_prometheus_url = http://cpro-server.default.svc.cluster.local:80/api/v1`
`configs.Gen3GPPXML` | Overrirde Gen3gppxml configuration | `Gen3gppxml.json`
`secrets.prometheusCa` | Prometheus Root Certificate | 
`secrets.prometheusCert` | Prometheus Certificate | 
`secrets.prometheusKey` | Prometheus Private Key | 
`secrets.prometheusAuthKey` | Prometheus Authentication Key | 
`secrets.restCa` | Rest Server Root Certificate | 
`secrets.restCert` | Rest Server Certificate | 
`secrets.restKey` | Rest Server Private Key | 
`secrets.ssoCa` | Single Sign on Root Certificate | 
`secrets.ssoCert` | Single Sign on Certificate |
`secrets.ssoKey` | Single Sign on Private Key | 
`persistentVolume.size` | Gen3gppxml data Persistent Volume size | `1Gi`
`tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`nodeSelector` | | node labels for kube-state-metrics pod assignment | `{}`|

A YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml cpro-gen3gppxml
```

## Persistence

The Gen3GPPXML service stores the generated XML files at the `/var/3gppxml` path of the container.

The chart mounts a Persistent Volume volume at this location. The volume is created using dynamic volume provisioning.

## RBAC Configuration
Roles and RoleBindings resources will be created automatically for `gen3gppxml` service.

To manually setup RBAC you need to set the parameter `rbac.enabled=false` and specify the service account to be used for each service by setting the parameters: `global.serviceAccountName`and `serviceAccountName` to the name of a pre-existing service account
