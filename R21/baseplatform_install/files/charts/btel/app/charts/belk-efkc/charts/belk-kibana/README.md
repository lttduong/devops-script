## Kibana

_Kibana_ is an open source frontend application, providing search and data visualization capabilities for data indexed in Elasticsearch.

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
helm install --name my-release csf-stable/belk-kibana --version <version> --namespace logging
```
The command deploys kibana on the Kubernetes cluster in the default configuration. The Parameters section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart:
To uninstall/delete the `my-release` deployment:
```
helm delete --purge my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

### Parameters:
The following table lists the configurable parameters of the Kibana chart and their default values.

|   Parameter             |Description                                   |Default                               |
|----------------|-------------------------------|-----------------------------|
|`global.registry`|Global Docker image registry for kibana image|`csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`|
|`global.seccompAllowedProfileNames`|Annotation that specifies which values are allowed for the pod seccomp annotations|`docker/default`|
|`global.seccompDefaultProfileName`|Annotation that specifies the default seccomp profile to apply to containers|`docker/default`|
|`global.podNamePrefix`  | Prefix to be added for pods and jobs names       | `null` |
|`global.containerNamePrefix`  | Prefix to be added for pod containers and job container names        | `null` |
|`global.istio.version`|Istio version defined at global level. Accepts version in numeric X.Y format. Ex. 1.4/1.5|`1.4`|
|`global.rbac.enabled`|Enable/disable rbac. When the flag is set to true, chart creates rbac objects if pre-created serviceaccount is not configured at global/chart level. When the flag is set to false, it is mandatory to configure a pre-created service-account at global/chart level|`true`|
|`global.serviceAccountName`|Pre-created ServiceAccountName defined at global level|`null`|
|`customResourceNames.resourceNameLimit`         | Character limit for resource names to be truncated                    | `63` |
|`customResourceNames.kibanaPod.kibanaContainerName`         | Name for kibana pod's container                  | `null` |
|`nameOverride`         | Use this to override name for kibana deployment kubernetes object. When it is set, the name would be ReleaseName-nameOverride                 | `null` |
|`fullnameOverride`         | Use this to configure custom-name for kibana deployment kubernetes object.  If both nameOverride and fullnameOverride are specified, fullnameOverride would take the precedence.                  | `null` |
|`service.type`|Kubernetes service type|`ClusterIP`|
|`service.name`|Kubernetes service name of kibana|`default value is commented out`|
|`kibana.replicas`|Desired number of kibana replicas|`1`|
|`kibana.image.repo`|Kibana image name. Accepted values are elk_k and elk_k_cos7|`elk_k_cos7`|
|`kibana.image.tag`|Kibana image tag|`7.8.0-20.09.02`|
|`kibana.ImagePullPolicy`|Kibana image pull policy|`IfNotPresent`|
|`kibana.resources`|CPU/Memory resource requests/limits for kibana pod|`limits: CPU/Mem 1000m/2Gi , requests: CPU/Mem 500m/1Gi`|
|`kibana.port`|Kibana is served by a back end server. This setting specifies the port to use.|`5601`|
|`kibana.securityContext.fsGroup`|Group ID that is assigned for the volumemounts mounted to the pod|`1000`|
|`kibana.securityContext.supplementalGroups`|The supplementalGroups ID applies to shared storage volumes|`default value is commented out`|
|`kibana.securityContext.seLinuxOptions`|Provision to configure selinuxoptions for kibana container |`default value is commented`|
|`kibana.custom.annotations`|Kibana pod annotations|`{}`|
|`kibana.node_port`|This setting specifies the node_port to use when service type is NodePort|`30601`|
|`kibana.ImagePullPolicy`|Kibana image pull policy|`IfNotPresent`|
|`kibana.livenessProbe.initialDelaySeconds `|Delay before liveness probe is initiated (kibana)|`120`|
|`kibana.livenessProbe.periodSeconds`|How often to perform the probe (kibana)|`30`|
|`kibana.livenessProbe.timeoutSeconds`|When the probe times out (kibana)|`1`|
|`kibana.livenessProbe.successThreshold`|Minimum consecutive successes for the probe (kibana)|`1`|
|`kibana.livenessProbe.failureThreshold`|Minimum consecutive failures for the probe (kibana)|`3`|
|`kibana.readinessProbe.initialDelaySeconds`|Delay before readiness probe is initiated (kibana)|`120`|
|`kibana.readinessProbe.periodSeconds`|How often to perform the probe (kibana)|`15`|
|`kibana.readinessProbe.timeoutSeconds`|When the probe times out (kibana)               |`1`|
|`kibana.readinessProbe.successThreshold`|Minimum consecutive successes for the probe (kibana)|`1`|
|`kibana.podLabels`|Set the podLabels parameter as key-value pair |`null`|
|`kibana.readinessProbe.failureThreshold`|Minimum consecutive failures for the probe (kibana)|`3`|
|`kibana.serviceAccountName`|Pre-created ServiceAccount specifically for kibana chart. SA specified here takes precedence over the SA specified in global.|`null`|
|`kibana.configMaps.kibana_configmap_yml.server.name`|A human-readable display name that identifies this Kibana instance|`kibana`|
|`kibana.configMaps.kibana_configmap_yml.server.customResponseHeaders`|Header names and values to send on all responses to the client from the Kibana server|`{ "X-Frame-Options": "DENY" }  `|
|`kibana.configMaps.kibana_configmap_yml.server.ssl.supportedProtocols`|Supported protocols with versions. Valid protocols: TLSv1, TLSv1.1, TLSv1.2. Enable server.ssl.supportedProtocols when sg is enabled.|`Even though the value is commented, default values are TLSv1.1, TLSv1.2`|
|`kibana.configMaps.kibana_configmap_yml.elasticsearch.requestHeadersWhitelist `|Kibana client-side headers to send to Elasticsearch|`Even though the value is commented, default value is autorization`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.auth.type`|If openid/ckey authentication is required, then uncomment and set this parameter to openid, Also uncomment and configure the other openid.* parameters accordingly. |`default value is basicauth when searchguard is enabled.`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.connect_url `|The URL where the IdP publishes the OpenID metadata.|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.client_id`|The ID of the OpenID client configured in your IdP|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.client_secret`|The client secret of the OpenID client configured in your IdP|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.header`|HTTP header name of the JWT token|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.base_redirect_url`|The URL where the IdP redirects to after successful authentication|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.openid.root_ca`|Path to the root CA of your IdP|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.enabled `|To enable/disable CSAN-Kibna integration. If csan is enabled, then uncomment and set other searchguard.auth.unauthenticated_routes,csan.* parameters accordingly|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.ssoproxy.url`|This is CSAN SSOProxy service URL|`null`|
|`kibana.configMaps.kibana_configmap_yml.searchguard.auth.unauthenticated_routes`|CSAN plugin routes need to be excluded from search guard authentication model|`null`|
|`kibana.configMaps.kibana_configmap_yml.csp.strict `|Kibana uses a Content Security Policy to help prevent the browser from allowing unsafe scripting|`true`|
|`kibana.configMaps.kibana_configmap_yml.csan.sco.url`|This is system credential orchestrator service URL|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.sco.keycloak_entity`|This is keycloak entity name name|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.sco.keycloak_classifier`|This is Keyclock realm-admin and this is required to connect with keycloak|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.sco.sane_entity `|SANE entity name|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.sco.sane_plugin_name `|Name of CSAN-Kibna credential plugin|`null`|
|`kibana.configMaps.kibana_configmap_yml.csan.auth_type `|Authentication type for dynamic password for CSAN users|`null`|
|`kibana.env.ELASTICSEARCH_HOSTS`| The URLs of the Elasticsearch instances to use for all your queries. When sg is enabled use protocol as https                                                   |`http://elasticsearch:9200`|
|`kibana.env.LOG_INDICES`| A ES based simple query to control the index-pattern to list (log-exporter).For more info about log-exporter parameter please refer[https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=992198356]                                        |`["log-*", journal]`|
|`kibana.env.DEFAULT_FIELDS`|Default search fields for log exporter to search upon when field key is not provided in search query. Accepts comma Separated values.|`log,message`|
|`kibana.env.EXPORT_CHUNK_SIZE`|Tune stream chunk size for exporting(No of record in one stream). Higher number can also clog slow down. (log-exporter)     |`500 `|
|`kibana.env.SCROLL_TIME`|ES search api scroll value.This query is used for creating stream chunk. (log-exporter)                                                                        |`10m`|
|`kibana.env.EXPORT_TIMEOUT`|Timeout for above scroll based query.(log-exporter)|`40s`|
|`kibana.env.TIMESTAMP_FIELD`|Default time field for log exporter. Applicable to all indices|`@timestamp`|
|`kibana.env.SERVER_SSL_ENABLED`|When istio is enabled then uncomment SERVER_SSL_ENABLED and set it to false and If searchguard is enabled uncomment SERVER_SSL_ENABLED|               `"default value is commented out"`|
|`kibana.env.SERVER_SSL_CERTIFICATE`|When searchguard is enabled uncomment SERVER_SSL_CERTIFICATE.|                                            `"default value is commented out"`|
|`kibana.env.SERVER_SSL_KEY`|When searchguard is enabled uncomment SERVER_SSL_KEY.|                                                            `"default value is commented out"`|
|`kibana.sslsecretvolume.tls.crt.pem`|Base64 of tls crt|`default value is commented out`|
|`kibana.sslsecretvolume.tls.key.pem`|Base64 of tls key|`default value is commented out`|
|`kibana.affinity`|kibana affinity (in addition to kibana.antiAffinity when set)|`{}`|
|`kibana.nodeSelector`|kibana node labels for pod assignment|`{}`|
|`kibana.tolerations`|List of node taints to tolerate (kibana)|`[]`|
|`kibanabaseurl.url`|Baseurl configured for kibana when kibana service is with ClusterIP|`/logviewer`|
|`kibanabaseurl.cg`|Do not change cg(capture group) parameter below unless you want to change/modify nginx rewrite-target for kibana ingress|`/?(.*)`|
|`cbur.enabled`|Enable cbur to take backup & restore the data|`false`|
|`cbur.maxCopy`|max copy of backupdata stored in cbur|`5`|
|`cbur.backendMode`|Configure the mode of backup. Available options are local","NETBKUP","AVAMAR","CEPHS3","AWSS3"|`local`|
|`cbur.cronJob`|cronjob frequency|`0 23 * * *`|
|`cbur.autoEnableCron`|To auto enable cron job |`false`|
|`cbur.autoUpdateCron`|To delete/update cronjob automatically based on autoEnableCron|`false`|
|`ingress.enabled`|Enable to access kibana svc via citm-ingress|`true`|
|`ingress.annotations`|Ingress annotations (evaluated as a template)|`{}`|
|`ingress.host`|Hosts configured for ingress|`*`|
|`ingress.tls`|TLS configured for ingress |`[]`|
|`istio.enabled`|Enabled istio for kibana when running in istio enabled namespace|`false`|
|`istio.version`|Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5|`null`|
|`istio.virtual_svc.hosts`|VirtualService defines a set of traffic routing rules to apply when a host is addressed|`*`|
|`istio.gateway.existing_gw_name `|Istio ingressgateway name if existing gateway should be used|`null`|
|`istio.gateway.selector.istio`|Selector for istio|`ingressgateway`|
|`istio.gateway.port.number`|Port number used for istio gateway|`80`|
|`istio.gateway.port.protocol`|Protocol used for istio gateway|`HTTP  `|
|`istio.gateway.port.name`|Port name used for istio gateway|`http`|
|`istio.gateway.host`|Hosts configured for istio gateway|`*`|
|`istio.gateway.tls`|TLS configured for istio gateway|`[]`|
|`searchguard.image.repo `|Kibana SearchGuard Repo Tag. Accepted values are elk_k_sg and elk_k_sg_cos7|`elk_k_sg_cos7`|
|`searchguard.image.tag`|Kibana SearchGuard Image Tag|`7.8.0-20.09.03`|
|`searchguard.enable `|Enable tag for Searchguard|`false `|
|`searchguard.base64_kib_es_username`|Base64 of kibana username |`null`|
|`searchguard.base64_kib_es_password`|Base64 of kibana password|`null`|
|`searchguard.keycloak_auth`|enable authentication required via keycloak|`false`|
|`searchguard.base64_keycloak_rootca_pem`|Kibana communicating to keycloak using keycloak root-ca certificate|`null`|
|`searchguard.istio.extCkeyHostname`|FQDN of ckey hostname that is externally accessible from browser|`"ckey.io"`|
|`searchguard.istio.extCkeyLocation`|Location of ckey internal/external to the istio mesh. Accepted values: MESH_INTERNAL, MESH_EXTERNAL |`MESH_INTERNAL`|
|`searchguard.istio.extCkeyIP`|IP to be used for DNS resolution of ckey hostname, Required only when ckey is external to istio mesh and ckey hostname is not resolvable from the cluster. |`null`|
|`searchguard.istio.extCkeyPort`|Port on which ckey is externally accessible|`null`|
|`searchguard.istio.extCkeyProtocol`|Protocol on which ckey is externally accessible|`null`|
|`searchguard.istio.ckeyK8sSvcName`|FQDN of ckey k8s service name internally accessible within k8s cluster|`null`|
|`searchguard.istio.ckeyK8sSvcPort`|Port on which ckey k8s service is accessible|`null`|
|`searchguard.base64_ES_RootCA`|CA certificate used by Kibana to establish trust when contacting Elasticsearch|`null`|
|`searchguard.base64ServerCrt`|base64 of kibana server certificate|`null`|
|`searchguard.base64ServerKey`|base64 of kibana server key|`null`|
|`searchguard.kibana.es_ssl_verification_mode`|Controls verification of the Elasticsearch server certificate that Kibana receives when contacting Elasticsearch|`certificate`|
|`sane.keycloak_admin_user_name`|Base64 of keycloak admin username|`default value is commented out`|
|`sane.keycloak_admin_password`|Base64 of keycloak admin password|`default value is commented out`|
|`sane.keycloak_sane_user_password`|Base64 for default password for sane user|`default value is commented out`|


Specify parameters using `--set key=value[,key=value]` argument to `helm install`

```
helm install --name my-release --set istio.enabled=true csf-stable/belk-kibana --namespace logging
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
helm install --name my-release -f values.yaml csf-stable/belk-kibana --version <version> --namespace logging

