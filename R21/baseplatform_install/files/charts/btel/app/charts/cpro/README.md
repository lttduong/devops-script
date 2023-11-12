

# Prometheus

[Prometheus](https://prometheus.io/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

## TL;DR;

```console
$ helm install stable/prometheus
```

## Introduction

This chart bootstraps a [Prometheus](https://prometheus.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.13+ with Beta APIs enabled

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/prometheus
```

The command deploys Prometheus on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Prometheus 2.x

Prometheus version 2.x has made changes to alertmanager, storage and recording rules. Check out the migration guide [here](https://prometheus.io/docs/prometheus/2.0/migration/)

Users of this chart will need to update their alerting rules to the new format before they can upgrade.

## Upgrading from previous chart versions.

As of version 5.0, this chart uses Prometheus 2.1. This version of prometheus introduces a new data format and is not compatible with prometheus 1.x. It is recommended to install this as a new release, as updating existing releases will not work. See the [prometheus docs](https://prometheus.io/docs/prometheus/latest/migration/#storage) for instructions on retaining your old data.

### Example migration

Assuming you have an existing release of the prometheus chart, named `prometheus-old`. In order to update to prometheus 2.1 while keeping your old data do the following:

1. Update the `prometheus-old` release. Disable scraping on every component besides the prometheus server, similar to the configuration below:

	```
	alertmanager:
	  enabled: false
	alertmanagerFiles:
	  alertmanager.yml: ""
	kubeStateMetrics:
	  enabled: false
	nodeExporter:
	  enabled: false
	pushgateway:
	  enabled: false
	server:
	  extraArgs:
	    storage.local.retention: 720h
	serverFiles:
	  alerts: ""
	  prometheus.yml: ""
	  rules: ""
	```

1. Deploy a new release of the chart with version 5.0+ using prometheus 2.x. In the values.yaml set the scrape config as usual, and also add the `prometheus-old` instance as a remote-read target.

   ```
	  prometheus.yml:
	    ...
	    remote_read:
	    - url: http://prometheus-old/api/v1/read
	    ...
   ```

   Old data will be available when you query the new prometheus instance.

## Configuration

The following table lists the configurable parameters of the Prometheus chart and their default values.

Parameter | Description | Default
--------- | ----------- | -------
`global.registry` | Global Docker image registry | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`
`global.registry1` | Global Docker image registry | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`
`global.annotations` | Annotations to be added for CPRO resources | `{}`
`global.labels` | Labels to be added for CPRO resources | `{}`
`global.serviceAccountName` | Service Account to be used in CPRO components | 
`global.istioVersion` | Istio version of the cluster | `1.4`
`custom.psp.annotations` | PSP annotations that need to be added | `seccomp.security.alpha.kubernetes.io/allowedProfileNames: runtime/default,seccomp.security.alpha.kubernetes.io/defaultProfileName: runtime/default`
`custom.psp.apparmorAnnotations` | Apparmor annotations that need to be added to PSP | `apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default, apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default`
`custom.psp.labels` | Custom labels that need to be added to PSP | 
`rbac.enabled` | If true, create and use RBAC resources | `true`
`rbac.pspUseAppArmor` | If true, enable apparmor annotations on PSPS and pods | `false`
`deployOnComPaaS` | Set to true when need to deploy on ComPaaS, false when deploy on BCMT(or other K8S) | `false`
`certManager.used` | Generate certificates to scrape metrics from etcd in BCMT | `true`
`certManager.duration` | How long certificate will be valid | `8760h`
`certManager.renewBefore` | When to renew the certificate before it gets expired | `360h`
`certManager.keySize` | Size of KEY | `2048`
`certManager.api` | Api version of the cert-manager.io | `cert-manager.io/v1alpha2`
`certManager.servername` | CN of the certificate | 
`certManager.dnsNames` | DNS used in certificate | `localhost`
`certManager.domain` | Domain name used in certificate |
`certManager.ipAddress` | Alt Names used in certificate |
`certManager.issuerRef.name` | Issuer Name | `ncms-ca-issuer`
`certManager.issuerRef.kind` | CRD Name | `ClusterIssuer`
`restrictedToNamespace` | Prometheus needs to scrape only a particular Namespace | `false`
`seLinuxOptions.enabled` | Selinux options in PSP and Security context  of POD | `false`
`seLinuxOptions.level` | Selinux level in PSP and Security context of POD | `""`
`seLinuxOptions.role` | Selinux role in PSP and Security Context of POD | `""`
`seLinuxOptions.type` | Selinux type in PSP and Security context of POD | `""`
`seLinuxOptions.user` | Selinux user in PSP and Security context of POD | `""`
`serviceAccountName` |  ServiceAccount to be used for alertmanager, kubeStateMetrics, pushgateway, server, webhook4fluentd, restserver and migrate components | 
`exportersServiceAccountName` | ServiceAccount to be used for  nodeExporter and zombieExporter components |
`ha.enabled` | If true, high availability feature will be enabled, and alertmanager and server could create 2 instances. If false, alertmanager and server could create only 1 instance | `false`
`helmDeleteImage.image.imageRepo` | helmDeleteImage container image repository | `tools/kubectl`
`helmDeleteImage.image.imageTag` | helmDeleteImage container image tag | `v1.10.3-user`
`helmDeleteImage.image.imagePullPolicy` | helmDeleteImage container image pull policy | `IfNotPresent`
`helmDeleteImage.resources.limits.cpu` | helmDeleteImage pod resource limits of cpu | `100m`
`helmDeleteImage.resources.limits.memory` | helmDeleteImage pod resource limits of memory | `100Mi`
`helmDeleteImage.resources.requests.cpu` | helmDeleteImage pod resource requests of cpu | `50m`
`helmDeleteImage.resources.requests.memory` | helmDeleteImage pod resource requests of memory | `32Mi`
`persistence.reservePvc` | If true, pvc of alertmanager and server will be reserved. It's only useful when ha.enabled is true | `false`
`istio.enable` | Istio feature is enabled or not | `false`
`istio.mtls_enable` | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`
`istio.cni_enable` | CNI is enabled or not | `true`
`istio.test_timeout` | Ammount of time to wait before running the tests | `60`
`alertmanager.enabled` | If true, create alertmanager | `true`
`alertmanager.dnsConfig` | If true, config DNS for pod. Work only if ha.enabled is true | `true`
`alertmanager.antiAffinityMode` | soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`alertmanager.name` | alertmanager container name | `alertmanager`
`alertmanager.image.imageRepo` | alertmanager container image repository | `cpro/registry4/alertmanager`
`alertmanager.image.imageTag` | alertmanager container image tag | `v0.20.0-2`
`alertmanager.image.imagePullPolicy` | alertmanager container image pull policy | `IfNotPresent`
`alertmanager.extraArgs` | Additional alertmanager container arguments | `{}`
`alertmanager.prefixURL` | The prefix slug at which the server can be accessed | `""`
`alertmanager.baseURL` | The external url at which the server can be accessed | `""`
`alertmanager.extraEnv` | Additional alertmanager container environment variable | `{}`
`alertmanager.configMapOverrideName` | Prometheus alertmanager ConfigMap override where full-name is `{{.Release.Name}}-{{.Values.alertmanager.configMapOverrideName}}` and setting this value will prevent the default alertmanager ConfigMap from being generated | `""`
`alertmanager.outboundTLS.enabled` | If true, configure TLS to access the outbound server | `true`
`alertmanager.outboundTLS.cert` | CA Root cert of the outbound server | `cert content encoded in base64`
`alertmanager.ingress.enabled` | If true, alertmanager Ingress will be created | `false`
`alertmanager.ingress.annotations` | alertmanager Ingress annotations | `{}`
`alertmanager.ingress.extraLabels` | alertmanager Ingress additional labels | `{}`
`alertmanager.ingress.hosts` | alertmanager Ingress hostnames | `[]`
`alertmanager.ingress.tls` | alertmanager Ingress TLS configuration (YAML) | `[]`
`alertmanager.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`
`alertmanager.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with alertmanager.baseURL | `alertmanager`
`alertmanager.istioIngress.selector` |  selector for Gateway | `{istio: ingressgateway}`
`alertmanager.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`
`alertmanager.istioIngress.httpPort` | Istio ingress http port | `80`
`alertmanager.istioIngress.gateway` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `istio-system/single-gateway-in-istio-system`
`alertmanager.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`
`alertmanager.istioIngress.tls.httpsPort` | Istio ingress https port | `443`
`alertmanager.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`
`alertmanager.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`
`alertmanager.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`alertmanager.nodeSelector` | node labels for alertmanager pod assignment | `{}`
`alertmanager.schedulerName` | alertmanager alternate scheduler name | `nil`
`alertmanager.persistentVolume.enabled` | If true, alertmanager will create a Persistent Volume Claim | `true`
`alertmanager.persistentVolume.accessModes` | alertmanager data Persistent Volume access modes | `[ReadWriteOnce]`
`alertmanager.persistentVolume.annotations` | Annotations for alertmanager Persistent Volume Claim | `{}`
`alertmanager.persistentVolume.existingClaim` | alertmanager data Persistent Volume existing claim name | `""`
`alertmanager.persistentVolume.mountPath` | alertmanager data Persistent Volume mount root path | `/data`
`alertmanager.persistentVolume.size` | alertmanager data Persistent Volume size | `2Gi`
`alertmanager.persistentVolume.storageClass` | alertmanager data Persistent Volume Storage Class | `unset`
`alertmanager.persistentVolume.subPath` | Subdirectory of alertmanager data Persistent Volume to mount | `""`
`alertmanager.podAnnotations` | annotations to be added to alertmanager pods | `{prometheus.io/port: "9093" prometheus.io/scrape: "true"}`
`alertmanager.replicaCount` | it's only used when ha.enabled true. When ha.enabled is false, replicaCount will be hard coded to 1 | `2`
`alertmanager.resources.limits.cpu` | alertmanager pod resource limits of cpu | `500m`
`alertmanager.resources.limits.memory` | alertmanager pod resource limits of memory | `1Gi`
`alertmanager.resources.requests.cpu` | alertmanager pod resource requests of cpu | `10m`
`alertmanager.resources.requests.memory` | alertmanager pod resource requests of memory | `32Mi`
`alertmanager.securityContext.runAsUser` | run as user in Alert Manager containers | `65534`
`alertmanager.securityContext.fsGroup` | fsGroup id in Alert Manager containers | `65534`
`alertmanager.retention.time` | Alertmanager retention time | `120h`
`alertmanager.service.annotationsForAlertmanagerCluster` | annotations for alertmanager cluster | `{}`
`alertmanager.service.annotationsForScrape` | Service Annotations of alertmanager service | `{prometheus.io/scrape: "true"}`
`alertmanager.service.annotations` | annotation for alertmanager service | `{}`
`alertmanager.service.labels` | labels for alertmanager service | `{}`
`alertmanager.service.clusterIP` | internal alertmanager cluster service IP | `""`
`alertmanager.service.externalIPs` | alertmanager service external IP addresses | `[]`
`alertmanager.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`alertmanager.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`alertmanager.service.servicePort` | alertmanager service port | `80`
`alertmanager.service.clusterPort` | alertmanager container target port if alertmanager.service.type is ClusterIP | `8001`
`alertmanager.service.nodePort` | alertmanager container node port if alertmanager.service.type is NodePort | `unset`
`alertmanager.service.type` | type of alertmanager service to create | `ClusterIP`
`configmapReload.name` | configmap-reload container name | `configmap-reload`
`configmapReload.image.imageRepo` | configmap-reload container image repository | `cpro/registry4/configmap-reload`
`configmapReload.image.imageTag` | configmap-reload container image tag | `v0.1-2`
`configmapReload.image.imagePullPolicy` | configmap-reload container image pull policy | `IfNotPresent`
`configmapReload.extraArgs` | Additional configmap-reload container arguments | `{}`
`configmapReload.extraConfigmapMounts` | Additional configmap-reload configMap mounts | `[]`
`configmapReload.resources.limits.cpu` | configmapReload pod resource limits of cpu | `10m`
`configmapReload.resources.limits.memory` | configmapReload pod resource limits of memory | `32Mi`
`configmapReload.resources.requests.cpu` | configmapReload pod resource requests of cpu | `10m`
`configmapReload.resources.requests.memory` | configmapReload pod resource requests of memory | `32Mi`
`tools.image.imageRepo` | tools container image repository | `cpro/registry4/tools-image`
`tools.image.imageTag` | tools container image tag | `1.2`
`tools.image.imagePullPolicy` | tools container image pull policy | `IfNotPresent`
`helmtest.CPROconfigmapname` | CPRO configmap name used in helm test | 
`helmtest.resources.limits.cpu` | helmtest pod resource limits of CPU | `10m`
`helmtest.resources.limits.memory` | helmtest pod resource limits of memory | `32Mi`
`helmtest.resources.requests.cpu` | helm test pod resource requests of CPU | `10m`
`helmtest.resources.requests.memory` | helm test pod resource requests of memory | `32Mi`
`initChownData.enabled`  | If false, don't reset data ownership at startup | `false`
`initChownData.name` | init-chown-data container name | `init-chown-data`
`initChownData.image.imageRepo` | init-chown-data container image repository | `os_base/centos-nano`
`initChownData.image.imageTag` | init-chown-data container image tag | `7.8-20200506`
`initChownData.image.imagePullPolicy` | init-chown-data container image pull policy | `IfNotPresent`
`initChownData.resources.limits.cpu` | init-chown-data resource limits of cpu | `10m`
`initChownData.resources.limits.memory` | init-chown-data pod resource limits of memory | `32Mi`
`initChownData.resources.requests.cpu` | init-chown-data pod resource requests of cpu | `10m`
`initChownData.resources.requests.memory` | init-chown-data pod resource requests of memory | `32Mi`
`initChownData.securityContext.runAsUser` | run as user in init-chown-data containers | `0`
`initChownData.securityContext.fsGroup` | fsGroup applied in init-chown-data containers | `65534`
`kubeStateMetrics.enabled` | If true, create kube-state-metrics | `true`
`kubeStateMetrics.name` | kube-state-metrics container name | `kube-state-metrics`
`kubeStateMetrics.image.imageRepo` | kube-state-metrics container image repository| `cpro/registry4/kube-state-metrics`
`kubeStateMetrics.image.imageTag` | kube-state-metrics container image tag | `v1.5.0-4`
`kubeStateMetrics.image.imagePullPolicy` | kube-state-metrics container image pull policy | `IfNotPresent`
`kubeStateMetrics.args` | kube-state-metrics container arguments | `{}`
`kubeStateMetrics.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`kubeStateMetrics.nodeSelector` | node labels for kube-state-metrics pod assignment | `{}`
`kubeStateMetrics.podAnnotations` | annotations to be added to kube-state-metrics pods | `{}`
`kubeStateMetrics.pod.labels` | labels to be added to kube-state-metrics pods | `{}`
`kubeStateMetrics.replicaCount` | desired number of kube-state-metrics pods | `1`
`kubeStateMetrics.resources.limits.cpu` | kube-state-metrics pod resource limits of cpu | `100m`
`kubeStateMetrics.resources.limits.memory` | kube-state-metrics pod resource limits of memory | `200Mi`
`kubeStateMetrics.resources.requests.cpu` | kube-state-metrics pod resource requests of cpu | `10m`
`kubeStateMetrics.resources.requests.memory` | kube-state-metrics pod resource requests of memory | `32Mi`
`kubeStateMetrics.securityContext.runAsUser` | run as user in kube-state-metrics containers | `65534`
`kubeStateMetrics.service.annotations` | annotation for kube-state-metrics service | `{prometheus.io/scrape: "true"}`
`kubeStateMetrics.service.annotationsForScrape` | annotation for kube-state-metrics service | `{prometheus.io/scrape: "true"}`
`kubeStateMetrics.service.clusterIP` | internal kube-state-metrics cluster service IP | `None`
`kubeStateMetrics.service.externalIPs` | kube-state-metrics service external IP addresses | `[]`
`kubeStateMetrics.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`kubeStateMetrics.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`kubeStateMetrics.service.servicePort` | kube-state-metrics service port | `80`
`kubeStateMetrics.service.type` | type of kube-state-metrics service to create | `ClusterIP`
`nodeExporter.enabled` | If true, create node-exporter | `true`
`nodeExporter.name` | node-exporter container name | `node-exporter`
`nodeExporter.image.imageRepo` | node-exporter container image repository| `cpro/registry4/node_exporter`
`nodeExporter.image.imageTag` | node-exporter container image tag | `v1.0.0-1`
`nodeExporter.image.imagePullPolicy` | node-exporter container image pull policy | `RollingUpdate`
`nodeExporter.updateStrategy.type` | Custom Update Strategy | `RollingUpdate`
`nodeExporter.extraArgs` | Additional node-exporter container arguments | `{}`
`nodeExporter.extraArgs.web.listen-address` | Additional node-exporter container argument, required when node-exporter is brought-up on different port and value should be same as  podHostPort & podContainerPort | `":9100"`
`nodeExporter.extraHostPathMounts` | Additional node-exporter hostPath mounts | `[]`
`nodeExporter.extraConfigmapMounts` | Additional node-exporter configMap mounts | `[]`
`nodeExporter.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`nodeExporter.nodeSelector` | node labels for node-exporter pod assignment | `{}`
`nodeExporter.podAnnotations` | annotations to be added to node-exporter pods | `{}`
`nodeExporter.pod.labels` | labels to be added to node-exporter pods | `{}`
`nodeExporter.resources.limits.cpu` | node-exporter pod resource limits of cpu | `500m`
`nodeExporter.resources.limits.memory` | node-exporter pod resource limits of memory | `500Mi`
`nodeExporter.resources.requests.cpu` | node-exporter pod resource requests of cpu | `100m`
`nodeExporter.resources.requests.memory` | node-exporter pod resource requests of memory | `30Mi`
`nodeExporter.nodeExporterContainerSecurityContext` | securityContext for containers in pod | `{capabilities.add: - SYS_TIME}`
`nodeExporter.service.annotations` | annotations for node-exporter service | `{prometheus.io/probe: "node-exporter"}`
`nodeExporter.service.labels` | labels to be added to node-exporter service | `{}`
`nodeExporter.service.clusterIP` | internal node-exporter cluster service IP | `None`
`nodeExporter.service.externalIPs` | node-exporter service external IP addresses | `[]`
`nodeExporter.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`nodeExporter.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`nodeExporter.service.servicePort` | node-exporter service port | `9100`
`nodeExporter.service.type` | type of node-exporter service to create | `ClusterIP`
`nodeExporter.service.podContainerPort` | node-exporter container target port | `9100`
`nodeExporter.service.podHostPort` | node-exporter container host port | `9100`
`zombieExporter.enabled` | If true, create zombie-exporter | `false`
`zombieExporter.name` | zombie-exporter container name | `zombie-exporter`
`zombieExporter.image.imageRepo` | zombie-exporter container image repository| `cpro/registry4/zombie-process-exporter`
`zombieExporter.image.imageTag` | zombie-exporter container image tag | `1.2-1`
`zombieExporter.image.imagePullPolicy` | zombie-exporter container image pull policy | `IfNotPresent`
`zombieExporter.updateStrategy.type` | Custom Update Strategy | `RollingUpdate`
`zombieExporter.extraArgs` | Additional zombie-exporter container arguments | `{}`
`zombieExporter.extraHostPathMounts` | Additional zombie-exporter hostPath mounts | `[]`
`zombieExporter.extraConfigmapMounts` | Additional zombie-exporter configMap mounts | `[]`
`zombieExporter.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`zombieExporter.nodeSelector` | node labels for zombie-exporter pod assignment | `{}`
`zombieExporter.podAnnotations` | annotations to be added to zombie-exporter pods | `{}`
`zombieExporter.pod.labels` | labels to be added to zombie-exporter pods | `{}`
`zombieExporter.resources.limits.cpu` | zombie-exporter pod resource limits of cpu | `200m`
`zombieExporter.resources.limits.memory` | zombie-exporter pod resource limits of memory | `50Mi`
`zombieExporter.resources.requests.cpu` | zombie-exporter pod resource requests of cpu | `100m`
`zombieExporter.resources.requests.memory` | zombie-exporter pod resource requests of memory | `30Mi`
`zombieExporter.securityContext` | run as user in zombie-exporter containers | `{runAsUser: 65534, fsGroup: 65534}`
`zombieExporter.service.annotations` | annotation for zombie-exporter service | `{prometheus.io/scrape: "true"}`
`zombieExporter.service.labels` | labels for zombie-exporter service | `{}`
`zombieExporter.service.clusterIP` | internal zombie-exporter cluster service IP | `None`
`zombieExporter.service.externalIPs` | zombie-exporter service external IP addresses | `[]`
`zombieExporter.service.hostPort` | zombie-exporter service port | `8002`
`zombieExporter.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`zombieExporter.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`zombieExporter.service.servicePort` | zombie-exporter service port | `8002`
`zombieExporter.service.type` | type of zombie-exporter service to create | `ClusterIP`
`zombieExporter.service.scrapeInterval` | zombie-exporter service scrape interval | `15`
`zombieExporter.service.logForwardToConsole` | logForwardToConsole indicates the location where log printed. True: log printed to console. False: log printed to logFile | `"True"`
`zombieExporter.service.logFile` | log file when logForwardToConsole is False | `"/var/log/zombieprocessexporter.log"`
`zombieExporter.service.logLevel` | log_level : 0 – DEBUG, 1 - INFO, 2 – WARN, 3 - ERROR | `1`
`server.name` | Prometheus server container name | `server`
`server.etcdCertMountPath` | Path where etcd certificates generated by cert-manager will be mounted | `/etc/etcd/ssl`
`server.antiAffinityMode` | soft means preferredDuringSchedulingIgnoredDuringExecution. hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`server.image.imageRepo` | Prometheus server container image repository | `cpro/registry4/prometheus`
`server.image.imageTag` | Prometheus server container image tag | `v2.16.0-2`
`server.image.imagePullPolicy` | Prometheus server container image pull policy | `IfNotPresent`
`server.prefixURL` | The prefix slug at which the server can be accessed | `""`
`server.baseURL` | The external url at which the server can be accessed | `""`
`server.enableAdminApi` |  If true, Prometheus administrative HTTP API will be enabled. Please note, that you should take care of administrative API access protection (ingress or some frontend Nginx with auth) before enabling it. | `false`
`server.namespaceList` | List of namespaces that need to be scrapped. works only when restrictedToNamespace is true | `unset`
`server.extraArgs` | Additional Prometheus server container arguments | `{}`
`server.extraKeys` | Additional Prometheus server container only key arguments | `[]`
`server.extraHostPathMounts` | Additional Prometheus server hostPath mounts | `[]`
`server.extraConfigmapMounts` | Additional Prometheus server configMap mounts | `[]`
`server.extraSecretMounts` | Additional Prometheus server Secret mounts | `[]`
`server.configMapOverrideName` | Prometheus server ConfigMap override where full-name is `{{.Release.Name}}-{{.Values.server.configMapOverrideName}}` and setting this value will prevent the default server ConfigMap from being generated | `""`
`server.migrate.enabled` | Enable this if previously deployed in non-HA (K8S Deployment) and want to migrate to HA (K8S Statefulset). It will migrate scraped data to new created PersistentVolumes mounted to each Statefulset pod | `false`
`server.migrate.name` | migrate related container name | `migrate`
`server.migrate.fileName` | The file name you backup in non-HA. This file will be copied to CBUR STATEFULSET folder so it could be restored when cpro is in HA mode | `"20190603030217_e01_LOCAL_june-cpro-server.tar.gz"`
`server.migrate.cbur.path` | Pointing to the path of cbur glusterfs repo. By default it is mounted to BCMT control node | `"192.168.199.10:cbur-glusterfs-repo"`
`server.migrate.cbur.endpoint` | Pointing to the endpoint of cbur glusterfs repo. By default it is mounted to BCMT control node | `"glusterfs-cluster"`
`server.migrate.moveDuration` | Time(seconds) for migrating data from CBUR DEPLOYMENT to STATEFULSET | `30`
`server.cbur.enabled` | If true, CBUR feature will be enabled for Prometheus server | `true`
`server.cbur.image.imageRepo` | cbur side-car container image repository | `cbur/cbura`
`server.cbur.image.imageTag` | cbur side-car container image tag | `1.0.3-983`
`server.cbur.image.imagePullPolicy` | cbur side-car container image pull policy | `IfNotPresent`
`server.cbur.resources.limits.cpu` | cbur side-car resource limits of cpu | `200m`
`server.cbur.resources.limits.memory` | cbur side-car resource limits of memory | `200Mi`
`server.cbur.resources.requests.cpu` | cbur side-car resource requests of cpu | `100m`
`server.cbur.resources.requests.memory` | cbur side-car resource requests of memory | `64Mi`
`server.cbur.backendMode` | CBUR backend mode | `"local"`
`server.cbur.autoEnableCron` | indicates that the cron job is immediately scheduled when the BrPolicy is created or not | `false`
`server.cbur.autoUpdateCron` |  cronjob must be updated via brpolicy update or not | `false`
`server.cbur.cronJob` | It is used for scheduled backup task. Empty string is allowed for no scheduled backup | `"*/5 * * * *"`
`server.cbur.brOption` | This value only applies to statefulset, when ha.enabled is true. The value can be 0,1 or 2 | `2`
`server.cbur.maxCopy` | Limit the number of copies that can be saved. Once it is reached, the newer backup will overwritten the oldest one | `5`
`server.ingress.enabled` | If true, Prometheus server Ingress will be created | `false`
`server.ingress.annotations` | Prometheus server Ingress annotations | `[]`
`server.ingress.extraLabels` | Prometheus server Ingress additional labels | `{}`
`server.ingress.hosts` | Prometheus server Ingress hostnames | `[]`
`server.ingress.tls` | Prometheus server Ingress TLS configuration (YAML) | `[]`
`server.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`
`server.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with server.baseURL | `prometheus`
`server.istioIngress.selector` |  selector for Gateway | `{istio: ingressgateway}`
`server.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`
`server.istioIngress.httpPort` | Istio ingress http port | `80`
`server.istioIngress.gateway` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `istio-system/single-gateway-in-istio-system`
`server.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`
`server.istioIngress.tls.httpsPort` | Istio ingress https port | `443`
`server.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`
`server.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`
`server.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`server.nodeSelector` | node labels for Prometheus server pod assignment | `{}`
`server.schedulerName` | Prometheus server alternate scheduler name | `nil`
`server.persistentVolume.enabled` | If true, Prometheus server will create a Persistent Volume Claim | `true`
`server.persistentVolume.accessModes` | Prometheus server data Persistent Volume access modes | `[ReadWriteOnce]`
`server.persistentVolume.annotations` | Prometheus server data Persistent Volume annotations | `{}`
`server.persistentVolume.existingClaim` | Prometheus server data Persistent Volume existing claim name | `""`
`server.persistentVolume.mountPath` | Prometheus server data Persistent Volume mount root path | `/data`
`server.persistentVolume.mountPath2` | Prometheus server storage.tsdb.path  | `/data`
`server.persistentVolume.size` | Prometheus server data Persistent Volume size | 16Gi`
`server.persistentVolume.storageClass` | Prometheus server data Persistent Volume Storage Class |  `unset`
`server.persistentVolume.subPath` | Subdirectory of Prometheus server data Persistent Volume to mount | `""`
`server.podAnnotations` | annotations to be added to Prometheus server pods | `{}`
`server.replicaCount` | it's only used when ha.enabled true. when ha.enabled is false, replicaCount will be hard coded to 1 | `2`
`server.resources.limits.cpu` | Prometheus server pod resource limits of cpu | `2`
`server.resources.limits.memory` | Prometheus server pod resource limits of memory | `4Gi`
`server.resources.requests.cpu` | Prometheus server pod resource requests of cpu | `500m`
`server.resources.requests.memory` | Prometheus server pod resource requests of memory | `512Mi`
`server.securityContext` | Custom [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) for server containers | `{runAsUser: 65534, fsGroup: 65534}`
`server.service.annotations` | annotations for Prometheus server service | `{prometheus.io/probe: "prometheus"}`
`server.service.annotationsForScrape` | annotations for Prometheus server service | `{prometheus.io/probe: "prometheus"}`
`server.service.labels` | labels for Prometheus server service | `{}`
`server.service.clusterIP` | internal Prometheus server cluster service IP | `""`
`server.service.externalIPs` | Prometheus server service external IP addresses | `[]`
`server.service.loadBalancerIP` | IP address to assign to load balancer (if supported) | `""`
`server.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]`
`server.service.nodePort` | Port to be used as the service NodePort (ignored if `server.service.type` is not `NodePort`) | `0`
`server.service.servicePort` | Prometheus server service port | `80`
`server.service.type` | type of Prometheus server service to create | `ClusterIP`
`server.terminationGracePeriodSeconds` | Prometheus server pod termination grace period | `10`
`server.retention` | Prometheus data retention period | `""`
`server.terminationGracePeriodSeconds` | Prometheus server Pod termination grace period | `300`
`server.retention` | (optional) Prometheus data retention | `""`
`server.livenessProbe.initialDelaySeconds` | Prometheus livenessProbe intialDelaySeconds | `30`
`server.livenessProbe.timeoutSeconds` | Prometheus livenessProbe timeoutSeconds | `30`
`server.livenessProbe.failureThreshold` | Prometheus livenessProbe failureThreshold | `3`
`server.livenessProbe.periodSeconds` | Prometheus livenessProbe periodSeconds | `10`
`server.readinesProbe.initialDelaySeconds` | Prometheus readinessProbe intialDelaySeconds | `30`
`server.readinessProbe.timeoutSeconds` | Prometheus readinessProbe timeoutSeconds | `30`
`server.readinessProbe.failureThreshold` | Prometheus readinessProbe failureThreshold | `3`
`server.readinessProbe.periodSeconds` | Prometheus readinessProbe periodSeconds | `10`
`pushgateway.enabled` | If true, create pushgateway | `true`
`pushgateway.name` | pushgateway container name | `pushgateway`
`pushgateway.antiAffinityMode` | Affinity mode of push gateway pods. soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`pushgateway.image.imageRepo` | pushgateway container image repository | `cpro/registry4/pushgateway`
`pushgateway.image.imageTag` | pushgateway container image tag | `v1.2.0-2`
`pushgateway.image.imagePullPolicy` | pushgateway container image pull policy | `IfNotPresent`
`pushgateway.extraArgs` | Additional pushgateway container arguments | `{push.disable-consistency-check: ""}`
`pushgateway.baseURL` | External URL which can access pushgateway, when istio is enabled: baseURL path and Contextroot path should match | `""`
`pushgateway.prefixURL` | The URL prefix at which the container can be accessed. Useful in the case the '-web.external-url' includes a slug. so that the various internal URLs are still able to access as they are in the default case | `""`
`pushgateway.ingress.enabled` | If true, pushgateway Ingress will be created | `false`
`pushgateway.ingress.annotations` | pushgateway Ingress annotations | `{}`
`pushgateway.ingress.hosts` | pushgateway Ingress hostnames | `[]`
`pushgateway.ingress.tls` | pushgateway Ingress TLS configuration (YAML) | `[]`
`pushgateway.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`
`pushgateway.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with server.baseURL | `pushgateway`
`pushgateway.istioIngress.selector` |  selector for Gateway | `{istio: ingressgateway}`
`pushgateway.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`
`pushgateway.istioIngress.httpPort` | Istio ingress http port | `80`
`pushgateway.istioIngress.gateway` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `istio-system/single-gateway-in-istio-system`
`pushgateway.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`
`pushgateway.istioIngress.tls.httpsPort` | Istio ingress https port | `443`
`pushgateway.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`
`pushgateway.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `pushgateway-secret`
`pushgateway.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`pushgateway.nodeSelector` | node labels for Pushgateway server pod assignment | `{}`
`pushgateway.podAnnotations` | Pod annotations for pushgateway  | `{}`
`pushgateway.replicaCount` | Number of replicas of pushgateway | `1`
`pushgateway.resources.limits.cpu` | Pushgateway pod resource limits of cpu | `100m`
`pushgateway.resources.limits.memory` | Pushgateway pod resource limits of memory | `200Mi`
`pushgateway.resources.requests.cpu` | Pushgateway pod resource requests of cpu | `10m`
`pushgateway.resources.requests.memory` | Pushgateway  pod resource requests of memory | `32Mi`
`pushgateway.securityContext` | Security context of the Pushgateway pods | `{ runAsUser: 65534}`
`pushgateway.service.annotations` | Annotations for Pushgateway service | `{prometheus.io/probe: pushgateway}`
`pushgateway.service.labels` | Labels to be added to Pushgateway service | `{}`
`pushgateway.service.clusterIP` | Cluster ip in the service to be used |  `""`
`pushgateway.service.externalIPs` | List of IP addresses at which the pushgateway service is available | `[]`
`pushgateway.service.loadBalancerIP` | Load balancer ip in the pushgateway | `""`
`pushgateway.service.loadBalancerSourceRanges` | Load balancer source ranges in Service | `[]`
`pushgateway.service.servicePort` | Port at which service is available | `9091`
`pushgateway.service.type` | Type of the service | `ClusterIP`
`webhook4fluentd.enabled` | install webhook4fluentd as part of  this chart or not |  `false`
`webhook4fluentd.name` | webhook4fluentd container name | `wehbook4fluentd`
`webhook4fluentd.antiAffinityMode` | Affinity mode for the wehbook4fluentd pods soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution| `"soft"`
`webhook4fluentd.image.imageRepo`   | Image repo for webhook4fluentd | `cpro/registry4/webhook4fluentd`
`webhook4fluentd.image.imageTag` | Image Tag of webhook4fluentd | `2.3-4`
`webhook4fluentd.image.imagePullPolicy` | Image pull policy for wehbook4fluentd | `IfNotPresent`
`webhook4fluentd.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`
`webhook4fluentd.nodeSelector` | node labels for webhook4fluentd  pod assignment| `{}` 
`webhook4fluentd.podAnnotations` | Pod annotations of webhook4fluentd | `{}`
`webhook4fluentd.replicaCount` | Number of replica of wehbook4fluentd | `2`
`webhook4fluentd.resources.limits.cpu` | webhook4fluentd resource limits of cpu | `100m`
`webhook4fluentd.resources.limits.memory` | webhook4fluentd resource limits of memory|`200Mi` 
`webhook4fluentd.resources.requests.cpu` | webhook4fluentd resource request of cpu | `10m`
`webhook4fluentd.resources.requests.memory` |webhook4fluentd resource request of memory | `32Mi`
`webhook4fluentd.securityContext.runAsUser` | User with which webhook4fluentd container runs | `65534`
`webhook4fluentd.service.annotations` | Service Annotations of webhook4fluentd | `{prometheus.io/scrape: "true"}`
`webhook4fluentd.service.annotationsForScrape` | Service Annotations of webhook4fluentd | `{prometheus.io/scrape: "true"}`
`webhook4fluentd.service.labels` | Service labels to be added for webhook4fluentd | `{}`
`webhook4fluentd.service.servicePort` | Port at which webhook4fluentd service is available| `8005`
`webhook4fluentd.service.type` | Service type of webhook4fluentd | `ClusterIP`
`alertmanagerFiles.alertmanager.yml` | alertmanager ConfigMap entries, this is used when webhook4fluentd.enabled is false. alertmanagerFiles, alertmanagerWebhookFiles are mutually exclusive. only one of them will be used |
`alertmanagerWebhookFiles.alertmanager.yml` | this config is used when webhook4fluentd.enabled is true, the following is default value, it could be changed. 'release' in the url should be changed to the right value. port in url should be webhook4fluentd.service.servicePort if the value is not 8005 |
`serverFiles.alerts` | Prometheus server configmap entries |
`serverFiles.rules` | Rules to be added to Prometheus server configmap entries |
`serverFiles.prometheus.yml` | Prometheus server configuration |
`serverFilesForComPaaS.alerts` | Prometheus server alerts configuration (only used when deploy on ComPaaS) | `{}`
`serverFilesForComPaaS.rules` | Prometheus server rules configuration (only used when deploy on ComPaaS) | `{}`
`serverFilesForComPaaS.prometheus.yml` | Prometheus server scrape configuration (only used when deploy on ComPaaS) | example configuration
`customScrapeJobs` | Define custom scrape job here for Prometheus. These jobs will be appended to prometheus.yml | `[]`
`networkPolicy.enabled` | Enable NetworkPolicy | `false`
`restserver.enabled` | If true, create restserver| `false`
`restserver.name` | restserver container name | `restserver`
`restserver.podAnnotations` | Annotations to be added to restserver pod | `{}`
`restserver.BCMT.serverURL` | BCMT URL that is needed for accessing API server | `https://k8s-apiserver.bcmt.cluster.local:8443`
`restserver.antiAffinityMode` | Affinity Mode  for restserver pods. soft means preferredDuringSchedulingIgnoredDuringExecution. hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`
`restserver.image.imageRepo` | restserver container image repository | `cpro/registry4/prometheus-restapi`
`restserver.image.imageTag` | restserver container image tag | `3.0.0`
`restserver.image.imagePullPolicy` | restserver container image pull policy | `IfNotPresent`
`restserver.replicaCount` | restserver replica count | `1`
`restserver.service.type` | type of restserver service to create | `ClusterIP`
`restserver.service.servicePort` | restserver service port | `8888`
`restserver.service.nodePort` | restserver service node port | `32766`
`restserver.ingress.enabled` | If true, restserver Ingress will be created | `false`
`restserver.ingress.annotations` | restserver Ingress annotations | `{}`
`restserver.ingress.tls` | restserver Ingress TLS configuration (YAML) | `[]`
`restserver.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`
`restserver.istioIngress.Contextroot` | Context root that is used to distinguish services. | `restserver`
`restserver.istioIngress.selector` |  selector for Gateway | `{istio: ingressgateway}`
`restserver.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`
`restserver.istioIngress.httpPort` | Istio ingress http port | `80`
`restserver.istioIngress.gateway` | Keep gatewayName to empty to create kubenetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `istio-system/single-gateway-in-istio-system`
`restserver.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`
`restserver.istioIngress.tls.httpsPort` | Istio ingress https port | `443`
`restserver.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`
`restserver.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `restserver-secret`
`restserver.resources.limits.cpu` | restserver pod resource limits of cpu | `500m`
`restserver.resources.limits.memory` | restserver pod resource limits of memory | `500Mi`
`restserver.resources.requests.cpu` | restserver pod resource requests of cpu | `100m`
`restserver.resources.requests.memory` | restserver pod resource requests of memory | `128Mi`
`restserver.nodeSelector` | node labels for restserver pod assignment | `{}`
`restserver.tolerations` | Tolerations of RestAPI server | `[]`
`restserver.configs.ncmsUsername` | ncms user name | `user-input`
`restserver.configs.ncmsPassword` | ncms password | `user-input`
`restserver.configs.ncmsPassPhrase` | ncms passphrase | `user-input`
`restserver.configs.httpsEnabled` | if https access enabled | `false`
`restserver.configs.restCACert` | restserver CACert | `content of restCACert`
`restserver.configs.restServerKey` | restserver private key | `content of restServerKey`
`restserver.configs.restServerCert` | restserver cert | `content of restServerCert`
`restserver.loglevel` | Log Level: DEBUG < INFO < WARN < ERROR < FATAL < OFF | `INFO` 
`customResourceNames.resourceNameLimit` | custom name limit for pod and container name | `63`
`customResourceNames.alertManagerPod.alertManagerContainer` | custom name for alertmanager container | `""`
`customResourceNames.alertManagerPod.configMapReloadContainer` | custom name for alertmanager configmap reload container | `""`
`customResourceNames.restServerPod.restServerContainer` | custom name for restserver container | `""`
`customResourceNames.restServerPod.configMapReloadContainer` | custom name for restserver configreload container | `""`
`customResourceNames.restServerHelmTestPod.name` | custom name for restserver helm test pod | `""`
`customResourceNames.restServerHelmTestPod.testContainer` | custom name for restserver helm test container | `""`
`customResourceNames.serverPod.inCntInitChownData` | custom name for prometheus init-container | `""`
`customResourceNames.serverPod.configMapReloadContainer` | custom name for prometheus configreload container | `""`
`customResourceNames.serverPod.serverContainer` | custom name for prometheus container | `""`
`customResourceNames.pushGatewayPod.pushGatewayContainer` | custom name for pushgateway container | `""`
`customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer` | custom name for kubeStateMetricsPod container | `""`
`customResourceNames.hooks.postDeleteJobName` | custom name for postDeleteJob  | `""`
`customResourceNames.hooks.postDeleteContainer` | custom name for postDeleteContainer  | `""`
`customResourceNames.webhook4fluentd.webhookContainer` | custom name for webhook4fluentdContainer  | `""`
`customResourceNames.nodeExporter.nodeExporterContainer` | custom name for nodeExporterContainer | `""`
`customResourceNames.zombieExporter.zombieExporterContainer` | custom name for nodeExporterContainer | `""`
`customResourceNames.migrate.preUpgradePodName` | custom name for preUpgradePod | `""`
`customResourceNames.migrate.preUpgradeContainer` | custom name for preUpgradeContainer | `""`
`customResourceNames.migrate.postUpgradePodName` | custom name for postUpgradePod | `""`
`customResourceNames.migrate.postUpgradeContainer` | custom name for postUpgradeContainer | `""`
`customResourceNames.serverHelmTestPod.name` | custom name for server HelmTestPod  | `""`
`customResourceNames.serverHelmTestPod.testContainer` | custom name for server  testContainer | `""` |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install stable/prometheus --name my-release \
    --set server.terminationGracePeriodSeconds=360
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
`serverFilesForComPaaS.alerts` | Prometheus server alerts configuration (only used when deploy on ComPaaS) | `{}`
`serverFilesForComPaaS.rules` | Prometheus server rules configuration (only used when deploy on ComPaaS) | `{}`
`serverFilesForComPaaS.prometheus.yml` | Prometheus server scrape configuration (only used when deploy on ComPaaS) | example configuration
`customScrapeJobs` | Define custom scrape job here for Prometheus. These jobs will be appended to prometheus.yml | `[]`
`networkPolicy.enabled` | Enable NetworkPolicy | `false`
`restserver.enabled` | If true, create restserver| `false`
`restserver.name` | restserver container name | `restserver`
`restserver.image.imageRepo` | restserver container image repository | `cpro/registry4/prometheus-restapi`
`restserver.image.imageTag` | restserver container image tag | `1.1.3`
`restserver.image.imagePullPolicy` | restserver container image pull policy | `IfNotPresent`
`restserver.replicaCount` | restserver replica count | `1`
`restserver.service.type` | type of restserver service to create | `ClusterIP`
`restserver.service.servicePort` | restserver service port | `8888`
`restserver.service.nodePort` | restserver service node port | `32766`
`restserver.ingress.enabled` | If true, restserver Ingress will be created | `false`
`restserver.ingress.annotations` | restserver Ingress annotations | `{}`
`restserver.ingress.tls` | restserver Ingress TLS configuration (YAML) | `[]`
`restserver.resources.limits.cpu` | restserver pod resource limits of cpu | `500m`
`restserver.resources.limits.memory` | restserver pod resource limits of memory | `500Mi`
`restserver.resources.requests.cpu` | restserver pod resource requests of cpu | `100m`
`restserver.resources.requests.memory` | restserver pod resource requests of memory | `128Mi`
`restserver.nodeSelector` | node labels for restserver pod assignment | `{}`
`restserver.tolerations` | Tolerations of RestAPI server | `[]`
`restserver.configs.ncmsUsername` | ncms user name | `user-input`
`restserver.configs.ncmsPassword` | ncms password | `user-input`
`restserver.configs.ncmsPassPhrase` | ncms passphrase | `user-input`
`restserver.configs.httpsEnabled` | if https access enabled | `false`
`restserver.configs.restCACert` | restserver CACert | `content of restCACert`
`restserver.configs.restServerKey` | restserver private key | `content of restServerKey`
`restserver.configs.restServerCert` | restserver cert | `content of restServerCert`
`restserver.loglevel` | Log Level: DEBUG < INFO < WARN < ERROR < FATAL < OFF | `INFO` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install stable/prometheus --name my-release \
    --set server.terminationGracePeriodSeconds=360
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install stable/prometheus --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### RBAC Configuration
Roles and RoleBindings resources will be created automatically for all the required cpro components.

To manually setup RBAC you need to set the parameter `rbac.enabled=false` and specify the service account to be used for each service by setting the parameters: `global.serviceAccountName`and `serviceAccountName` to the name of a pre-existing 
service account for  alertmanager, kubeStateMetrics, pushgateway, server, webhook4fluentd, restserver and migrate components. 
And for exporters components ( nodeExporter and zombieExporter)  specify the service account to be used by setting the parameter `exportersServiceAccountName`

> **Tip**: You can refer to the default `*-*role.yaml` and `*-*rolebinding.yaml` files in [templates](templates/) to customize your own.

### ConfigMap Files
AlertManager is configured through [alertmanager.yml](https://prometheus.io/docs/alerting/configuration/). This file (and any others listed in `alertmanagerFiles`) will be mounted into the `alertmanager` pod.

Prometheus is configured through [prometheus.yml](https://prometheus.io/docs/operating/configuration/). This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

### Ingress TLS
If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [kube-lego](https://github.com/jetstack/kube-lego)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls prometheus-server-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the alertmanager/server Ingress TLS section of your custom `values.yaml` file:

```yaml
server:
  ingress:
    ## If true, Prometheus server Ingress will be created
    ##
    enabled: true

    ## Prometheus server Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - prometheus.domain.com

    ## Prometheus server Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: prometheus-server-tls
        hosts:
          - prometheus.domain.com
```

### NetworkPolicy

Enabling Network Policy for Prometheus will secure connections to Alert Manager
and Kube State Metrics by only accepting connections from Prometheus Server.
All inbound connections to Prometheus Server are still allowed.

To enable network policy for Prometheus, install a networking plugin that
implements the Kubernetes NetworkPolicy spec, and set `networkPolicy.enabled` to true.

If NetworkPolicy is enabled for Prometheus' scrape targets, you may also need
to manually create a networkpolicy which allows it.

