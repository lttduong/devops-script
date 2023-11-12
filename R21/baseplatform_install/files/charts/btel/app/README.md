

# BTEL Helm Chart

## Introduction

BTEL umbrella chart is part of CSF Telemetry Blueprint (BTEL) to deploy all the sub-charts for BTEL related to fault and performance monitoring as well as logging

### Sub charts :

**belk-efkc** : Log collection, analysis and display

**calm** : Alarm service. It is a generic agent to support network elements integrated with different network management systems for fault management.

**cpro** : Prometheus service which provides system monitoring and alerting toolkit.

**cpro-grafana** : Grafana provides rich metrics dashboard and graph editor for Prometheus

**cpro-gen3gppxml** : Query metric data from Prometheus server and generate 3GPPXML files . It is used to integrate with NetAct on PM data

**cnot** : Notification service. It receives alerts and notifications from source applications and transmits them to the desired destination stream,such as E-mail, SMS, Slack or SNMP.

**crmq** : It is a message broker, which is an implementation of the protocol AMQP 0-9-1 (Advanced Message Queuing Protocol) along with some extensions.In BTEL, it is used by calm as one southern interface with application

**cmdb** : Database service. It is used by calm and cpro-grafana for storing their persistent data.

**citm-ingress** : Ingress controller which exposes HTTP and HTTPS routes from outside the cluster to services within the cluster

## Prerequisites

- For container installation Kubernetes 1.13+ with Beta APIs enabled needed.
- Modify values.yaml to install the chart with releasename as btel and  the namespace as btel
1. Replace "btel-releasename" with releasename "btel".
2. Replace the svc ".btel." with the  namespace ".<your-namespace>." If your namespace is btel, you don't need to change namespace.
3. Replace the cnot EMAIL servers details with the real server/email address to receive notification.
4. To enable ISTIO refer the ISTIO section below.


## Installing the Chart

To install the chart with the release name `btel`:

```console
$ helm install . --name=btel --timeout 1000 --namespce btel
For HELM3, use the below
$ helm3 install btel . --timeout 1000s --namespce btel
```

The command deploys BTEL on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


## Uninstalling the Chart

To uninstall/delete the `btel` deployment:

```console
# helm delete --purge btel --timeout 1000
 
For HELM3, use the below
# helm3 delete btel -n btel --timeout 1000s
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## ISTIO Section 

```console
tags:
  btel_citm: false
belk:
  belk-fluentd:
    istio:
      enabled: true

  belk-elasticsearch:
    istio:
      enabled: true
  belk-curator:
    istio:
      enabled: true
  belk-kibana:
    istio:
      enabled: true
      gateway:
      # if the virtual svc should bind to existing gateway, configure gateway name below
        existing_gw_name: "btel-common-istio-gateway"
calm:
  istio:
    enabled: true
    inject: true
    rbac: true
    permissive: false
  cnot:
    serverURL: http://cnot.btel.svc.cluster.local:80
    enabledSSL: false
  mq:
    hostname: crmq-ext.btel.svc.cluster.local:5672
    enabledSSL: false
cnot:
  istio:
    enabled: true
    gateway: false
    legacyCapabilities: true
    destinationRule: true
    permissive: false
  wildfly:
    https:
      enabled: false
cpro:
  istio:
    enable: true
    mtls_enable: true
    cni_enable: true
    test_timeout: 60
  alertmanager:
    baseURL: "http://localhost:31380/alertmanager"
    outboundTLS:
      enabled: false
    istioIngress:
      enabled: true
      Contextroot: alertmanager
      selector: {istio: ingressgateway}
      host: "*"
      httpPort: 80
      gatewayName: "btel-common-istio-gateway"
      tls:
        enabled: true
        httpsPort: 443
        mode: SIMPLE
        credentialName: "am-gateway"
  server:
    baseURL: "http://localhost:31380/prometheus"
    istioIngress:
      enabled: true
      Contextroot: prometheus
      selector: {istio: ingressgateway}
      host: "*"
      httpPort: 80
      gatewayName: "btel-common-istio-gateway"
      tls:
        enabled: true
        httpsPort: 443
        mode: SIMPLE
        credentialName: "am-gateway"
  pushgateway:
    baseURL: "http://localhost:31380/pushgateway"
    istioIngress:
      enabled: true
      selector: {istio: ingressgateway}
      Contextroot: pushgateway
      host: "*"
      httpPort: 80
      gatewayName: "btel-common-istio-gateway"
      tls:
        enabled: false
        httpsPort: 443
        mode: SIMPLE
        credentialName: "pushgateway-secret"
  restserver:
    istioIngress:
      enabled: true
      selector: {istio: ingressgateway}
      Contextroot: restserver
      host: "*"
      httpPort: 80
      gatewayName: "btel-common-istio-gateway"
      tls:
        enabled: false
        httpsPort: 443
        mode: SIMPLE
        credentialName: "restserver-gateway"
  alertmanagerFiles:
    alertmanager.yml:
      receivers:
        - name: default-receiver
          webhook_configs:
            - url: 'http://cnot.btel.svc.cluster.local/api/cnot/v1/notif'
              http_config:

grafana:
  istio:
    enable: true
    mtls_enable: true
    cni_enable: true
  cmdb:
    istio:
      enabled: true
  grafana_ini:
    server:
      protocol: http
      root_url: "%(protocol)s://%(domain)s:%(http_port)s/grafana"
      #set to true when istio is enabled
      serve_from_sub_path: true
  scheme: http
  livenessProbe:
    scheme: HTTP
  readinessProbe:
    scheme: HTTP
  istioIngress:
    enabled: true
    Contextroot: grafana
    selector: {istio: ingressgateway}
    host: "*"
    httpPort: 80
    gatewayName: "btel-common-istio-gateway"
    tls:
      enabled: true
      httpsPort: 443
      mode: SIMPLE
      credentialName: "am-gateway"

gen3gppxml:
  istio:
    enable: true
    mtls_enable: true
    cni_enable: true
  service:
    serviceType: ClusterIP
  configOverride: |+
    OVERRIDE_prometheus_url = http://cpro-server-ext.btel.svc.cluster.local:80/prometheus/api/v1
  istioIngress:
    enabled: true
    selector: {istio: ingressgateway}
    Contextroot: gen3gppxml
    host: "*"
    httpPort: 80
    gatewayName: "btel-common-istio-gateway"
    tls:
      enabled: false
      httpsPort: 443
      mode: PASSTHROUGH
      credentialName: "am-gateway"
    tcpGatewayName: ""
    sftpPort: 31400
    tcpHost: "*"
crmq:
  istio:
    enabled: true
    version: 1.5
    cni:
      enabled: true
    mtls:
      enabled: true
    permissive: false

  rabbitmq:
    tls:
      cacert: ""

cmdb:
  istio:
    enabled: true

citm-ingress:
  istio:
    enabled: true
    version: 1.5
    cni:
      enabled: true
    mtls:
      #Is strict MTLS enabled in the environment.
      enabled: true
    #Should allow mutual TLS as well as clear text for your deployment.
    permissive: true
  default404:
    istio:
      enabled: true
      version: 1.5
      cni:
        enabled: true
      mtls:
        enabled: true
      permissive: true
btel_istio_gateway:
  create  : true
```
## Pod and Container Name prefix
For pod and container name prefix set the below configuartion in global section.

```console
global:
  podNamePrefix: ""
  containerNamePrefix: ""
```
Set the below fullnameoverride to empty in the cpro section.

```console
cpro:
  fullnameOverride:
  alertmanager:
    fullnameOverride:
  kubeStateMetrics:
    fullnameOverride: 
  nodeExporter:
    fullnameOverride:
  server:
    fullnameOverride:
  pushgateway:
    fullnameOverride:
```


## Configuration

The following table lists the configurable parameters of the BTEL chart and their default values.
Refer the subchart README.md 


 Parameter | Description | Default
--------- | ----------- | -------
  |  `tags.belk-curator`  |  Enable/Disable component  |  `true`  |    |  `
  |  `tags.belk-elasticsearch`  |  Enable/Disable component   |  `true`  |  
  |  `tags.belk-fluentd`  |  Enable/Disable component    |  `true`  |  
  |  `tags.belk-kibana`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_belk`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_calm`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_citm`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_ckaf`  |  Enable/Disable component    |  `false`  |  
  |  `tags.btel_ckaf_schema`  |  Enable/Disable component    |  `false`  |  
  |  `tags.btel_cmdb`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_cnot`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_cpro`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_crmq`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_gen3gppxml`  |  Enable/Disable component    |  `true`  |  
  |  `tags.btel_grafana`  |  Enable/Disable component    |  `true`  |  
  |  `global.registry`  |  Global registry    |  `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`  |
  |  `global.registry1`  |  Global registry    |  `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`  |
  |  `global.registry2`  |  Global registry    |  `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`  |
  |  `global.registry3`  |  Global registry    |  `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`  |
  |  `global.registry4`  |  Global registry    |  `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`  |
  |  `global.istioVersion`  |  Istio version value    |  `1.5`  |
  |  `global.podNamePrefix`  |  Pod name prefix value    |  ``  |
  |  `global.containerNamePrefix`  |  Container name prefix value    |  ``  |
  |  __`belk:`__  |  __Configure paramaters for belk-efkc component__ |  *`Please refer belk-efkc chart README for more details `*  |
  |  `belk.belk-elasticsearch.istio.enabled`  |  Enable istio for Elasticsearch using the flag  |  `false`  |
  |  `belk.belk-elasticsearch.istio.enabled.envoy_health_chk_port`  |  Health check port of istio envoy proxy  |  `15020`  |
  |  `belk.belk-elasticsearch.istio.version`  |   Istio version specified at chart level. If defined here,it takes precedence over global level. Accepts istio version in numeric X.Y format. Ex. 1.4/1.5 |  `1.5`  |
  |  `belk.belk-elasticsearch.network_host`  |   Configure based on network interface added to cluster nodes i.e ipv4 interface or ipv6 interface.For ipv4 interface value can be set to "\_site\_".For ipv6 interface values can be set to "\_global:ipv6\_" or "\_eth0:ipv6\_"  |  `"_site_"`  |
  |  `belk.belk-elasticsearch.persistence.auto_delete`  |   Persistent volumes auto deletion along with deletion of chart when set to true |  `false`  |
  |  `belk.belk-elasticsearch.serviceAccountName`  |  Pre-created ServiceAccount specifically for elasticsearch chart. SA specified here takes precedence over the SA specified in global  |  `''`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.replicas`  |  Desired number of elasticsearch master node replicas  |  `3`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.es_java_opts`  |  Environment variable for setting up JVM options  |  `-Xms1g`  |    |  `-Xmx1g`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.nodeSelector`  |  master node labels for pod assignment  |  `{}`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.tolertions`  |  List of node taints to tolerate (elasticsearch master pods)  |  `{}`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.resources.limits.cpu`  |  CPU resource limits for master pod  | `'1'` |
  |  `belk.belk-elasticsearch.elasticsearch_master.resources.limits.memory`  |   Memory resource limits for master pod  |  `2Gi`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.resources.requests.cpu`  |   CPU resource requests for master pod  |  `500m`  |
  |  `belk.belk-elasticsearch.elasticsearch_master.resources.requests.memory`  |   Memory resource requests for master pod |  `1Gi`  |
  |  `belk.belk-elasticsearch.esdata.replicas`  |   Desired number of elasticsearch data node replicas   |  `2`  |
  |  `belk.belk-elasticsearch.esdata.es_java_opts`  |   Environment variable for setting up JVM options |  `-Xms1g-Xmx1g`  |
  |  `belk.belk-elasticsearch.esdata.nodeSelector`  |  Data node labels for pod assignment |  ``  |
  |  `belk.belk-elasticsearch.esdata.tolerations`  |  List of node taints to tolerate (elasticsearch data pods) |  ``  |
  |  `belk.belk-elasticsearch.esdata.resources.limits.cpu`  |   CPU resource limits for data pod  |  `'1'`  |
  |  `belk.belk-elasticsearch.esdata.resources.limits.memory`  |   Memory resource limits for data pod  | |  `2Gi`  |
  |  `belk.belk-elasticsearch.esdata.resources.requests.cpu`  |   CPU resource requests for data pod |  `500m`  |
  |  `belk.belk-elasticsearch.esdata.resources.requests.memory`  |   Memory resource requests for data pod |  `1Gi`  |
  |  `belk.belk-elasticsearch.elasticsearch_client.replicas`  |  Desired number of elasticsearch client node replicas  |  `3`  |
  |  `belk.belk-elasticsearch.elasticsearch_client.nodeSelector`  |  Data node labels for pod assignment |  ``  |
  |  `belk.belk-elasticsearch.elasticsearch_client.tolerations`  |  List of node taints to tolerate (elasticsearch client pods) |  ``  |
  |  `belk.belk-elasticsearch.elasticsearch_client.es_java_opts`  |   Environment variable for setting up JVM options |  `-Xms1g`  |    |  `-Xmx1g`  |  
  |  `belk.belk-elasticsearch.elasticsearch_client.resources.limits.cpu`  |   CPU resource limits for client pod |  `'1'`  |  
  |  `belk.belk-elasticsearch.elasticsearch_client.resources.limits.memory`  |   Memory resource limits for client pod |  `2Gi`  |  
  |  `belk.belk-elasticsearch.elasticsearch_client.resources.requests.cpu`  |   CPU resource requests for client pod |  `500m`  |  
  |  `belk.belk-elasticsearch.elasticsearch_client.resources.requests.memory`  |   Memory resource requests for client pod |  `1Gi`  |  
  |  `belk.belk-fluentd.istio.enabled`  |   Enable istio using this flag |  `false`  |
  |  `belk.belk-fluentd.istio.version`  |   Istion version value |  `1.5`  |
  |  `belk.belk-fluentd.fluentd.serviceAccountName`  |   Pre-created ServiceAccount specifically for fluentd chart. SA specified here takes precedence over the SA specified in global.  |  `''`  |
  |  `belk.belk-fluentd.fluentd.kind`  |  Configure fluentd kind like Deployment,DaemonSet,Statefulset |   `DaemonSet`  |
  |  `belk.belk-fluentd.fluentd.replicas`  |  When fluentd is deployed as Deployment or StatefulSet, below flag is used to scale the replicas |   `1`  |
  |  `belk.belk-fluentd.fluentd.nodeSelector`  |   Node labels for fluentd pod assignment  |  `{}`  |
  |  `belk.belk-fluentd.fluentd.persistence.pvc_auto_delete`  |   Persistent Volume auto delete when chart is deleted  |  `false`  |
  |  `belk.belk-fluentd.fluentd.resources.limits.cpu`  |   CPU resource limits for fluentd pod |   `500m`  |
  |  `belk.belk-fluentd.fluentd.resources.limits.memory`  |   Memory resource limits for fluentd pod |  `500Mi`  |
  |  `belk.belk-fluentd.fluentd.resources.requests.cpu`  |   CPU resource requests for fluentd pod |   `400m`  |
  |  `belk.belk-fluentd.fluentd.resources.requests.memory`  |   Memory resource requests for fluentd pod | `300Mi`  |
  |  `belk.belk-fluentd.fluentd.tolerations`  |   List of node taints to tolerate (fluentd pods) |  `[]`  |
  |  `belk.belk-fluentd.fluentd.service.custom_name`  |   Configure fluentd custom service name  |  `fluentd-metrics`  |
  |  `belk.belk-fluentd.fluentd.service.enabled`  |   Enable fluentd service  |  `true`  |
  |  `belk.belk-fluentd.fluentd.service.metricsPort`  |   fluentd-prometheus-plugin port  |  `24231`  |
  |  `belk.belk-fluentd.fluentd.forward_service.custom_name`  |   Configure fluentd custom forwarder service name  |  `fluentd`  |
  |  `belk.belk-fluentd.fluentd.forward_service.enabled`  |   Enable fluentd forward service |  `true`  |
  |  `belk.belk-fluentd.fluentd.forward_service.port`  |   Fluentd forward service port |  `24224`  |
  |  `belk.belk-fluentd.fluentd.fluentd_config.custom-value`  |  Configure fluentd custom forwarder service name  |  |
  |  `belk.belk-fluentd.fluentd.configFile`  |  If own configuration for fluentd other than provided by belk/clog then set fluentd_config: custom-value and provide the configuration here  |  `''`  |
  |  `belk.belk-kibana.kibana.replicas`  |   Desired number of kibana replicas  |  `1`  |
  |  `belk.belk-kibana.istio.enabled`  |   Enabled istio for kibana when running in istio enabled namespace  |  `false`  |
  |  `belk.belk-kibana.istio.version`  |   Istio version value  |  `1.5`  |
  |  `belk.belk-kibana.istio.gateway.existing_gw_name`  |   Istio ingressgateway name if existing gateway should be used  |  `'btel-common-istio-gateway'`  |
  |  `belk.belk-kibana.istio.gateway.hosts`  |   Hosts configured for istio gateway  |  `['*']`  |
  |  `belk.belk-kibana.istio.gateway.port.name`  |   Port name used for istio gateway |  `http`  |
  |  `belk.belk-kibana.istio.gateway.port.number`  |   Port number used for istio gateway |  `80`  |
  |  `belk.belk-kibana.istio.gateway.port.protocol`  |   Protocol used for istio gateway |  `HTTP`  |
  |  `belk.belk-kibana.istio.gateway.selector.istio`  |   Selector for istio |  `ingressgateway`  |
  |  `belk.belk-kibana.istio.gateway.tls`  |   TLS configured for istio gateway |  `[]`  |
  |  `belk.belk-kibana.istio.virtual_svc.hosts`  |   VirtualService defines a set of traffic routing rules to apply when a host is addressed  |  `['*']`  |
  |  `belk.belk-kibana.ingress.annotations.ingress.citm.nokia.com/sticky-route-services` |  Ingress annotations (evaluated as a template) |  `$cookie_JSESSIONID\|JSESSIONID ip_cookie`   |
  |  `belk.belk-kibana.ingress.annotations.nginx.ingress.kubernetes.io/rewrite-target` |  Ingress annotations (evaluated as a template) | `/$1` |
  |  `belk.belk-kibana.ingress.annotations.nginx.ingress.kubernetes.io/ssl-redirect`  |  Ingress annotations (evaluated as a template) | `"true"` |
  |  `belk.belk-kibana.kibana.nodeSelector`  |   kibana node labels for pod assignment  |  `{}`  |  
  |  `belk.belk-kibana.kibana.resources.limits.cpu`  |   CPU resource limits for kibana pod |  `1000m`  |
  |  `belk.belk-kibana.kibana.resources.limits.memory`  |   Memory resource limits for kibana pod |  `1Gi`  |    
  |  `belk.belk-kibana.kibana.resources.requests.cpu`  |   CPU resource requests for kibana pod |  `500m`  |  
  |  `belk.belk-kibana.kibana.resources.requests.memory`  |   Memory resource requests for kibana pod |  `500Mi`  |  
  |  `belk.belk-kibana.kibana.serviceAccountName`  |   Pre-created ServiceAccount specifically for kibana chart. SA specified here takes precedence over the SA specified in global. |  `''`  |  
  |  `belk.belk-kibana.kibana.tolerations`  |   List of node taints to tolerate (kibana) |  `[]`  |  
  |  `belk.belk-kibana.kibanabaseurl.cg`  |  Do not change cg(capture group) parameter below unless you want to change/modify nginx rewrite-target for kibana ingress  |  `'/?(.*)'`  |  
  |  `belk.belk-kibana.kibanabaseurl.url`  |  Baseurl configured for kibana when kibana service is with ClusterIP  |  `/logviewer`  |  
  |  `belk.belk-curator.curator.serviceAccountName`  |  Pre-created ServiceAccount specifically for curator chart when rbac.enabled is set to  false. SA specified here takes precedence over the SA specified in global  |  |
  |  `belk.belk-curator.istio.enabled`  |  Enable istio for curator using the flag    |  `false`  |
  |  `belk.belk-curator.istio.envoy_health_chk_port`  |  Health check port of istio envoy proxy  |  `15020`  |
  |  __`calm:`__  |  __Configure paramaters for calm component__    |  *`Please refer calm chart README for more details`*  |
  |  `calm.maxActiveAlarmCount`  |  The maximum number of active alarms in CALM database. If limit reached, CALM will drop new alarm instances.  |  `1024`  |  
  |  `calm.driver`  |   MariaDB driver |  `org.mariadb.jdbc.Driver`  |
  |  `calm.ha`  |   Configures high-availability mode of the CALM service. This feature is experimental, should not be used in production: the value should be false and CALM pods should not be scaled   |  `true`  |
  |  `calm.affinity`  |    [Node affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) settings for pod assignment. |  `{}`  |  
  |  `calm.logLevel`  |   Log level setting, this parameter accepts "TRACE","DEBUG","INFO","WARN" or "ERROR", its value is "ERROR" by default. |  `INFO`  |
  |  `calm.alarmAdapterClasses`  |   Enable NBI and SBI interfaces of CALM service. Mandatory prefix: `com.nokia.csf.calm.adapter.`, separator: `;`.<br> NBI - any of: `CveaAdapter`, `CnotAdapter`, `SnmpNorthboundAdapter` (NetAct adapter), `NetActAlarmAdapter` (legacy NetAct adapter).<br>SBI - one of: `QueueBasedAlarmAdapter`, `SnmpSouthboundAdapter` |  `com.nokia.csf.calm.adapter.QueueBasedAlarmAdapter;com.nokia.csf.calm.adapter.SnmpNorthboundAdapter`  |  
  |  `calm.rbac.enabled`  | If true, create and use RBAC resources    |  `true`  |
  |  `calm.istio.enabled`  | Enable feature. When disabled, other istio settings are ignored.    |  `false`  |
  |  `calm.istio.inject`  |    Controls auto inject of sidecar container.|  `false`  |
  |  `calm.istio.permissive`  |   In permissive mode istio gateway will not configure mTLS, services can be reached through NodePort or ClusterIP. |  `false`  |
  |  `calm.istio.ingress.enabled`  |  Indicates that Istio Gateway and VirtualService objects will be created by Helm. [More information] (https://istio.io/v1.5/docs/reference/config/networking/gateway/#Server)    |  `true`  |
  |  `calm.istio.ingress.enabled.host`  |   Host exposed by the gateway. A host is specified as a DNS name. It must have DNS binding to this host in order to resolve it and access CALM service.  |  `*`  |
  |  `calm.istio.ingress.enabled.port`  |    Port on which the gateway proxy should listen for incoming connections. |  `80`  |
  |  `calm.istio.ingress.enabled.uriRoot`  |     Root of the URI on which CALM service will be accessible. |  `calm`  |
  |  `calm.istio.ingress.enabled.gatewayName`  |   Leave it empty to create the Gateway object. Otherwise specify an existing Gateway object; `host`, `port`, `selector`, `tls.*` will be ignored.   |  `btel-common-istio-gateway`  |
  |  `calm.istio.ingress.enabled.tls.enabled`  |   Indicates secure gateway interface creation for inbound traffic.   |  `true`  |
  |  `calm.istio.ingress.enabled.tls.port`  |    Port on which the gateway proxy should listen for incoming secure connections |  `443`  |
  |  `calm.istio.ingress.enabled.tls.tlsOptions.mode`  |    See [TLSOptions](https://istio.io/v1.5/docs/reference/config/networking/gateway/#Server-TLSOptions) |  `SIMPLE`  |
  |  `calm.istio.ingress.enabled.tls.tlsOptions.credentialName`  |   See [TLSOptions](https://istio.io/v1.5/docs/reference/config/networking/gateway/#Server-TLSOptions)  |  `calm-credential`  |
  |  `calm.cnot.passphrase`  |   Passphrase for the truststorePassword.  |  `Input passphrase`  |
  |  `calm.cnot.truststorePassword`  |   Truststore password encrypted with passphrase using fpm-password tool  |  `Input truststore password`  |
  |  `calm.cnot.base64Truststore`  |   Base64 encoded truststore  |  `''`  |  
  |  `calm.cnot.enabledSSL`  |   Enable one way SSL connection to the CNOT server. |  `true`  |  
  |  `calm.cnot.serverURL`  |   URL, format: `<FQDN:Port>or <IP:Port>`. _site_specific_ |  `cnot.btel.svc.cluster.local:443'`  |  
  |  `calm.mariadbClientCert`  |  MariaDB client certificate.  |  `''`  |  
  |  `calm.mariadbClientKey`  |   MariaDB client private key. |  `''`  |  
  |  `calm.mariadbServerCert`  |   MariaDB server certificate. |  `''`  |  
  |  `calm.messageQueueType`  |   The message queue type used by CALM: `rabbitmq` or `kafka`. |  `rabbitmq`  |  
  |  `calm.mq.clientCert`  |   The client certificate.  |  `''`  |  
  |  `calm.mq.clientKey`  |   The private key of the client. |  `''`  |  
  |  `calm.mq.enabledSSL`  |   Enable SSL.   |  `true`  |  
  |  `calm.mq.encryptProtocol`  |   Encryption protocol. |  `TLSv1.2`  |  
  |  `calm.mq.hostname`  |   The address of the RabbitMQ service. Use the following format: `<FQDN:Port>or <IP:Port>`.  |  `'crmq-ext.btel.svc.cluster.local:5671'`  |  
  |  `calm.mq.passphrase`  |   The passphrase for the encrypted password |  `Input Passphrase`  |  
  |  `calm.mq.password`  |   The encrypted password using fpm-password tool |  `Input the password`  |  
  |  `calm.mq.serverCert`  |  The server certificate  |  `''`  |  
  |  `calm.mq.username`  |   Username.  |  `alma_mquser`  |  
  |  `calm.mq.vhost`  |  Virtual host.  | `/`  |  
  |  `calm.mq.exchangeName`  |  Exchange Name.  | `cfw`  |
  |  `calm.mq.routingKey`  |  Routing key.  | `event`  |
  |  `calm.mq.queueName`  |  Queue name  | `alma`  |
  |  `calm.servers`  |   CALM pods replicas. Should be set to 1, scaling is not supported, see also ha configuration parameter. | `2` |  
  |  `calm.tolerations`  |    [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) for pod assignment. |  `[]`  |  
  |  `calm.nodeSelector`  |  [Node labels](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector) for pod assignment.   | `{}`  |
  |  `calm.url`  |   MariaDB jdbc connection string. Example (replace IP):<br> 1.jdbc:mariadb:failover//127.0.0.1:3306/calm_alma?socketTimeout=10000<br>2. jdbc:mariadb:failover//127.0.0.1:3306/calm_alma?socketTimeout=10000&useSSL=true&enabledSslProtocolSuites=TLSv1,TLSv1.1,TLSv1.2&trustServerCertificate=true  |  `jdbc:mariadb:failover//cmdb-mysql.btel.svc.cluster.local:3306/calm_alma?socketTimeout=10000`  |
  |  `calm.user`  |   MariaDB user |  `alma_dbuser`  |  
  |  `calm.password`  |   MariaDB encrypted password. Encrypted with passphrase using fpm-password tool |  `Input password`  |
  |  `calm.passphrase`  |   MariaDB passphrase for the encrypted password. |  `Input passphrase`  |
  |  __`cnot:`__  |  __Configure paramaters for cnot component__    |  *`Please refer cnot chart README for more details`*  |
  |  `cnot.fullnameOverride`  |   Full name override value |  `cnot`  |
  |  `cnot.cnot.replicaCount`  |   desired number of cnot pods |  `1`  |  
  |  `cnot.istio.enabled`  |   Enable istio feature. When disabled, other istio settings are ignored. |  `false`  |
  |  `cnot.istio.gateway`  |   Enable istio gateway and virtual service |  `true`  |
  |  `cnot.istio.legacyCapabilities`  |   Add NET_ADMIN and NET_RAW to container capabilities (required if no Istio CNI is present; only applies if PSP is being generated by the chart.) |  `true`  |
  |  `cnot.istio.permissive`  |   In permissive mode istio gateway will not configure mTLS, services can be reached through NodePort or ClusterIP. |  `false`  |
  |  `cnot.rbac.enabled`  |   If true, create and use RBAC resources |  `true`  |
  |  `cnot.serviceAccountName`  |   Pre-created ServiceAccount specifically for cnot chart |  `null`  |
  |  `cnot.cnot.nodeSelector`  |   Node labels for pod assignment |  `{}`  |
  |  `cnot.cnot.resources.limits.cpu`  |   CPU resource limits for cnot pod  |  `'1'`  |     
  |  `cnot.cnot.resources.limits.memory`  |   Memory resource limits for cnot pod  |  `1Gi}`  | 
  |  `cnot.cnot.resources.requests.cpu`  |   CPU resource requests for cnot pod |  `500m`  |  
  |  `cnot.cnot.resources.requests.memory`  |   Memory resource requests for cnot pod |  `512Mi`  | 
  |  `cnot.cnot.service.annotations.prometheus.io/path`  |    |  `/api/cnot/v1/metrics`  |  
  |  `cnot.cnot.service.annotations.prometheus.io/scrape`  |    |  `'true'`  |  
  |  `cnot.cnot.service.servicePort`  |   cnot http service port |  `80`  |  
  |  `cnot.cnot.service.servicePortHTTPS`  |   cnot https service port |  `443`  |  
  |  `cnot.cnot.tolerations`  |    [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) for pod assignment. |  `[]`  |  
  |  `cnot.cnot-configmap.cnotFiles.app_conf.yaml`  |  cnot configuartion yaml  |  `null`  |  
  |  `cnot.cnot-configmap.cnotOutboundTrustCerts.EMAIL_SMTPServer1.crt`  |   cnot outbound certificate  |  `Input the certificate`  |  
  |  `cnot.wildfly.ipv6Enabled`  |  IPV6 enable flag |  `false`  |
  |  `cnot.wildfly.https.applikeystorepass`  |   wildfly application keystore pass |  `Input the password`  |  
  |  `cnot.wildfly.https.cert`  |   wildfly https cert |  `Input the certificate`  |  
  |  `cnot.wildfly.https.enabled`  |   wildfly enable https flag |  `true`  |  
  |  `cnot.wildfly.https.key`  |   wildfly https key  |  `Input the key`  |  
  |  `cnot.wildfly.https.vaultpass`  |   wildfly https vaultpass |  `Input the password`  |  
  |  __`crmq:`__  |  __Configure paramaters for crmq component__   |  *`Please refer crmq chart README`*  |
  |  `crmq.fullnameOverride`  | Full name override  |  `crmq`  |  
  |  `crmq.istio.enabled`  |   Specify if deploy on istio |  `false`  |  
  |  `crmq.istio.version`  |   Specify Istio version |  `1.5`  |
  |  `crmq.istio.cni.enabled`  |   Specify Istio cni enabled |  `true`  |
  |  `crmq.istio.mtls.enabled`  |   Specify Istio mtls enabled |  `true`  |
  |  `crmq.istio.permissive`  |   Allow mutual TLS as well as clear text for deployment |  `false`  |
  |  `crmq.rbac.enabled`  |   Specify if rbac is enabled in your cluster  |  `true`  |
  |  `crmq.rbac.serviceAccountName`  |   Specify default SA if rbac.enable false |  `null`  |
  |  `crmq.rbac.serviceAccountNameAdminForgetnode`  |   Specify admin SA if rbac.enable false & pvc disable  |  `null`  |
  |  `crmq.rbac.serviceAccountNamePostDel`  |   Specify post delete SA if rbac.enable false |  `null`  |
  |  `crmq.rbac.serviceAccountNameScale`  |   Specify scaling SA if rbac.enable false & pvc enable  |  `null`  |
  |  `crmq.rbac.test.enabled`  |   Enable or disable helm test when rbac.enabled is false |  `true`  |
  |  `crmq.rbac.test.helmTestSecret`  |   Specify tls secret if rbac.enable false & want to use helm test  |  `null`  |
  |  `crmq.rbac.test.serviceAccountNameHelmTest`  |   Specify default SA if rbac.enable false & want to use helm test |  `null`  |
  |  `crmq.replicas`  |    Replica count |  `3`  |
  |  `crmq.resources.limits.cpu`  |   resource needs and limits to apply to the pod  |  `1`  |
  |  `crmq.resources.limits.memory`  |   resource needs and limits to apply to the pod  |  `760Mi`  |
  |  `crmq.resources.requests.cpu`  |   resource needs and limits to apply to the pod  |  `100m`  |
  |  `crmq.resources.requests.memory`  |   resource needs and limits to apply to the pod  |  `256Mi`  |
  |  `crmq.tmpForceRecreateResources`  |   Force to recreate the resource created when install |  `false`  |
  |  `crmq.tolerations`  |   Toleration labels for pod assignment  |  `[]`  |
  |  `crmq.nodeSelector`  |   Node labels for pod assignment |  `{}`  |  
  |  `crmq.affinity`  |   Affinity settings for pod assignment |  `{}`  |
  |  `crmq.persistence.reservePvc`  |   reserve persistence storage after pod deleted |  `false`  |  
  |  `crmq.persistence.reservePvcForScalein`  |   reserve persistence storage after pod scale-in  |  `false`  |   
  |  `crmq.rabbitmq.password`  |   RabbitMQ application password |  `Input the password`  |  
  |  `crmq.rabbitmq.tls.cacert`  |   broker tls cacert file content |  `''`  |  
  |  `crmq.rabbitmq.tls.cert`  |   broker tls cert file content |  `''`  |  
  |  `crmq.rabbitmq.tls.fail_if_no_peer_cert`  |   whether to accept clients which have no certificate |  `'true'`  |  
  |  `crmq.rabbitmq.tls.key`  |   broker tls key file content |  `''`  |  
  |  `crmq.rabbitmq.tls.ssl_port`  |   RabbitMQ broker tls port |  `5671`  |  
  |  `crmq.rabbitmq.tls.verify_option`  |   whether peer verification is enabled |  `verify_peer`  |  
  |  `crmq.rabbitmq.tls.username`  |   RabbitMQ application username |  `alma_mquser`  |  
  |  `crmq.tmpForceRecreateResources`  |   Force to recreate the resource created when install |  `false`  |  
  |  `crmq.tolerations`  |   Toleration labels for pod assignment |  `[]`  |  
  |  __`cmdb:`__  |  __Configure paramaters for cmdb component__  |  *`Please refer cmdb chart README for more details`*  |
  |  `cmdb.fullnameOverride`  |   Full name override  |  `cmdb`  |
  |  `cmdb.cluster_type`  |   Passed into the CMDB containers as CLUSTER_TYPE (See Docker Configuration). ==NEW IN 7.13.0== This value can now be changed during helm upgrade to perform a topology morph  |  `simplex`  |
  |  `cmdb.istio.enabled`  |   Indicates if the deployment is being performed in an istio-enabled namespace.  Also make sure that global.istioVersion is set appropriately for the base kubernetes platform.  |  `false`  |
  |  `cmdb.rbac_enabled`  |   Specifies whether Role-Based Access Control (RBAC) is enabled in the underlying kubernetes environment |  `true`  |
  |  `cmdb.serviceAccountName`  |    Service Account to use instead of a generated one (Also disables generation of Roles/Rolebindings). See [RBAC Rules](./oam_rbac_rules.md)  |  `null`  |
  |  `cmdb.services.mysql.name`  |  <Chart Release\>-mysql  The name of the Kubernetes Service where Mysql clients can access the database |  ``  |
  |  `cmdb.services.mysql.type`  |  Either ClusterIP or NodePort - depending on if the DB should be accessible only within the cluster or exposed externally, respectively  |  `ClusterIP`  |
  |  `cmdb.services.mariadb.name`  |   <Chart Release\>-mariadb-<N>  ==NEW IN 7.13.4== If Istio is enabled, the name of the Kubernetes Service for the Istio per-pod service  |  ``  |
  |  `cmdb.services.mariadb.exporter.name`  |   <Chart Release\>-mariadb-metrics  ==NEW IN 7.13.4== If mariadb.metrics.enabled is set to true, this overrides the Kubernetes Service name be used for metrics collection. |  ``  |
  |  `cmdb.services.mariadb.exporter.port`  |   ==CHANGED IN 7.13.4== If mariadb.metrics.enabled is set to true, this port can be configured to define the port which mysqld\_exporter will listen to for metrics collection.<br>**NOTE: Renamed from services.mariadb.exporter\_port**  |  `9104`  |
  |  `cmdb.services.mariadb_master.name`  |  <Chart Release\>-mariadb-master  The name of the Kubernetes Service pointing to the Master Pod. *(Only relevant in Master-Slave clusters with MaxScale)*  |  ``  |
  |  `cmdb.services.mariadb_master.type`  |  NodePort - should not be changed. *(Only relevant in Master-Slave clusters with MaxScale)*  |  `NodePort`  |
  |  `cmdb.services.mariadb_master.nodePort`  |   If set to NodePort, optionally set a specific nodePort port to use instead of having one assigned by the infrastructure.  Ignored if not using NodePort, random assigned if commented out. NOTE:  If assigning nodePort here, you must ensure that the port is not currently assigned in the assignment range |  ``  |
  |  `cmdb.services.maxscale.name`  |    <Chart Release\>-maxscale  The name of the Kubernetes Service pointing to the leader MaxScale Pod. *(Only relevant in Master-Slave clusters with MaxScale)* |  ``  |
  |  `cmdb.services.maxscale.type`  |   Either ClusterIP or NodePort - depending on if the maxctrl interface should be accessible only within the cluster or exposed externally, respectively. *(Only relevant in Master-Slave clusters with MaxScale)*<br>**NOTE: Will be automatically set to NodePort when geo\_redundancy.enabled is true.** |  `ClusterIP`  |
  |  `cmdb.services.maxscale.port`  |   The port for the Kubernetes maxctrl Service. *(Only relevant in clusters with MaxScale and if services.maxscale.enabled is true)* |  `8989`  |
  |  `cmdb.services.maxscale.nodePort`  |   If set to NodePort, optionally set a specific nodePort port to use instead of having one assigned by the infrastructure.  Ignored if not using NodePort, random assigned if commented out. NOTE:  If assigning nodePort here, you must ensure that the port is not currently assigned in the assignment range |  ``  |
  |  `cmdb.services.maxscale.exporter.name`  |  <Chart Release\>-maxscale-metrics ==NEW IN 7.13.4== If maxscale.metrics.enabled is set to true, this overrides the Kubernetes Service name be used for metrics collection. |  ``  |
  |  `cmdb.services.maxscale.exporter.port`  |   ==CHANGED IN 7.13.4== If maxscale.metrics.enabled is set to true, this port can be configured to define the port which maxscale\_exporter will listen to for metrics collection.<br>**NOTE: Renamed from services.maxscale.exporter\_port** |  `9195`  |
  |  `cmdb.services.admin.name`  |   <Chart Release\>-admin  The name of the Kubernetes Service pointing to the Admin Pod. *(Not relevent in simplex deployments).*  |  ``  |
  |  `cmdb.services.admin.type`  |  Either ClusterIP or NodePort - depending on if the Admin container should be accessible only within the cluster or exposed externally, respectively. Should not need to change this from ClusterIP. *(Not relevant in simplex deployments).*  |  `ClusterIP`  |
  |  `cmdb.services.endpoints.master.name` | <Chart Release\>-master-<geo_redundancy.remote.name\>  ==NEW IN 7.13.4== The name of the Kubernetes Service providing a service endpoint for the remote data center connection to local Master service. *(Only relevant in Master-Slave clusters with MaxScale)* | `` |
  |  `cmdb.services.endpoints.maxscale.name` | <Chart Release\>-maxscale-<geo_redundancy.remote.name\> ==NEW IN 7.13.4== The name of the Kubernetes Service providing a service endpoint for the remote data center connection to local Maxscale service. *(Only relevant in Master-Slave clusters with MaxScale)* | `` |
  |  `cmdb.databases`  |  A list of databases to create. .name is required; .character_set and .collate are optional | `  - name: grafana character_set: utf8  collate: utf8_general_ci, - name: calm_alma character_set: keybcs2 collate: keybcs2_bin` |
  |  `cmdb.nodeAffinity:enabled`  |    Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector.  |  `true`  |
  |  `cmdb.nodeAffinity.key`  |   Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. |  `is_worker`  |
  |  `cmdb.nodeAffinity.value`  |   Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. |  `true`  |
  |  `cmdb.mariadb.resources.limits.cpu`  |   The Kubernetes CPU resource limits for the MariaDB pods (See K8s documentation) |  `500m`  |
  |  `cmdb.mariadb.resources.limits.memory`  |   The Kubernetes Memory resource limits for the MariaDB pods (See K8s documentation) |  `512Mi`  |
  |  `cmdb.mariadb.resources.requests.cpu`  |   The Kubernetes CPU resource requests for the MariaDB pods (See K8s documentation) |  `250m`  |
  |  `cmdb.mariadb.resources.requests.memory`  |   The Kubernetes Memory resource requests for the MariaDB pods (See K8s documentation) |  `256Mi`  |
  |  `cmdb.mariadb.root_password`  |  The MySQL root user database password to configure (base64 encoded)   |  `Input the password`  |
  |  `cmdb.mariadb.use_tls`  |   Boolean. Indicates if TLS/SSL is to be configured to encrypt data in flight to clients. Setting this to true will automatically add the ssl_cipher TLSv1.2 to mariadb configuration and will automatically add REQUIRE SSL to all user grants. The mariadb.repl_use_ssl is used to enable/disable SSL for replicatoin traffic. |  `false`  |
  |  `cmdb.users`  |   A list of users to create. All fields are required. Note .password must be base64 encoded. (See MariaDB GRANT Syntax) | `- name: grafana   password: Z3JhZmFuYQ==   host: "%"   privilege: ALL   object: "grafana.*"  requires: ""      - name: alma_dbuser   password: YWxtYV9kYnBhc3N3ZAo=   host: "%"   privilege: ALL  object: "calm_alma.*"  requires: ""        with: "GRANT OPTION"` |
  |  `cmdb.admin.nodeAffinity.enabled`  |   Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. |  `true`  |  
  |  `cmdb.admin.nodeAffinity.key`  |   Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. |  `is_worker`  |  
  |  `cmdb.admin.nodeAffinity.value`  |   Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. |  `true`  |    
  |  `cmdb.admin.resources.limits.cpu`  |   The Kubernetes CPU resource limits for the Admin pod (See K8s documentation) |  `500m`  |  
  |  `cmdb.admin.resources.limits.memory`  |  The Kubernetes Memory  resource limits for the Admin pod (See K8s documentation) | `512Mi`  |   
  |  `cmdb.admin.resources.requests.cpu`  |   The Kubernetes CPU resource requests for the Admin pod (See K8s documentation) | `250m`  | 
  |  `cmdb.admin.resources.requests.memory`  |   The Kubernetes Memory  resource requests for the Admin pod (See K8s documentation) |  `256Mi`  |  
  |  `cmdb.mariadb.count`  |   The number of MariaDB pods to create, depends on cluster_type (See Docker Configuration) |  `1`  |
  |  `cmdb.mariadb.allow_root_all`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `true`  |  
  |  `cmdb.mariadb.audit_logging.enabled`  |   Boolean. Indicates if server audit logging should be enabled by default. |  `false`  |  
  |  `cmdb.mariadb.certificates.client_ca_cert`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `client_ca-cert.pem`  |  
  |  `cmdb.mariadb.certificates.client_cert`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `client-cert.pem`  |  
  |  `cmdb.mariadb.certificates.client_key`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `client-key.pem`  |  
  |  `cmdb.mariadb.certificates.secret`  |   Three interfaces are supportted as specified by the certificates.secret value, which must be one of these values:1. none (or empty) = No certificates 2. cmgr = Automatically generated certificates 3. <secret> = Manually supplied certificates. This is the name of the kubernetes <secret> which contains the six CA certificate files provided in the mariadb.certificates section |  `null`  |  
  |  `cmdb.mariadb.certificates.server_ca_certserver_ca-cert.pem`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR.|    |  
  |  `cmdb.mariadb.certificates.server_cert`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `server-cert.pem`  |  
  |  `cmdb.mariadb.certificates.server_key`  |   The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. |  `server-key.pem`  |  
  |  `cmdb.maxscale.count`  |   The number of MaxScale pods to create. Set to 0 for no MaxScale. Set to 1 for simplex MaxScale. Set to 2 or 3 for HA MaxScale. |  `0`  |  
  |  `cmdb.maxscale.nodeAffinity.enabled`  |  Node affinity key in BCMT for the maxscale pod. This should not be changed and will bind the admin pod to the worker nodes.<br>***Note***: This option is mutually exclusive with admin.nodeSelector. | `true`  |
  |  `cmdb.maxscale.nodeAffinity.key`  |  Node affinity key in BCMT for the maxscale pod. This should not be changed and will bind the admin pod to the worker nodes.<br>***Note***: This option is mutually exclusive with admin.nodeSelector. | `is_edge`  |
  |  `cmdb.maxscale.nodeAffinity.value`  |  Node affinity key in BCMT for the maxscale pod. This should not be changed and will bind the admin pod to the worker nodes.<br>***Note***: This option is mutually exclusive with admin.nodeSelector. | `true`  |  
  |  `cmdb.maxscale.resources.limits.cpu`  |   The Kubernetes CPU resource limits for the MaxScale pod (See K8s documentation) |  `500m`  |     
  |  `cmdb.maxscale.resources.limits.memory`  |   The Kubernetes Memory resource limits for the MaxScale pod (See K8s documentation) |  `512Mi`  |  
  |  `cmdb.maxscale.resources.requests.cpu`  |   The Kubernetes CPU resource requests for the MaxScale pod (See K8s documentation) |  `250m`  |
  |  `cmdb.maxscale.resources.requests.memory`  |   The Kubernetes Memory resource requests for the MaxScale pod (See K8s documentation) |  `256Mi`  |
  |  __`cpro:`__  |  __Configure paramaters for cpro-server component__   | *`Please refer cpro-server chart README for more details`*  |
  |  `cpro.fullnameOverride  ` |  Fullname Override value | `cpro`  |
  |  `cpro.serviceAccountName  ` |  ServiceAccount to be used for alertmanager, kubeStateMetrics, pushgateway, server, webhook4fluentd, restserver and migrate components |  `` |
  |  `cpro.exportersServiceAccountName  ` | ServiceAccount to be used for  nodeExporter and zombieExporter components |  `` |
  |  `cpro.ha.enabled  ` | If true, high availability feature will be enabled, and alertmanager and server could create 2 instances. If false, alertmanager and server could create only 1 instance | `true`  |
  |  `cpro.rbac.enabled  ` | If true, create and use RBAC resources | `true`  |
  |  `cpro.rbac.pspUseAppArmor  ` | If true, enable apparmor annotations on PSPS and pods | `false`  |
  |  `cpro.istio.enable  ` | Istio feature is enabled or not | `false`  |
  |  `cpro.istio.mtls_enable  ` | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`  |
  |  `cpro.istio.cni_enable  ` | CNI is enabled or not | `true`  |
  |  `cpro.istio.test_timeout  ` | Ammount of time to wait before running the tests | `60`  |
  |  `cpro.persistence.reservePvc  ` | If true, pvc of alertmanager and server will be reserved. It's only useful when ha.enabled is true | `false`  |
  |  `cpro.alertmanager  ` |  Fullname Override value | `cpro-alertmanager`  |
  |  `cpro.alertmanager.enabled` | If true, create alertmanager | `true`  |
  |  `cpro.alertmanager.name` | alertmanager container name | `alertmanager`  |
  |  `cpro.alertmanager.baseURL` | The external url at which the server can be accessed | `""`  |
  |  `cpro.alertmanager.outboundTLS.enabled` | If true, configure TLS to access the outbound server | `true`  |
  |  `cpro.alertmanager.outboundTLS.cert` | CA Root cert of the outbound server | `cert content encoded in base64`  |
  |  `cpro.alertmanager.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`  |
  |  `cpro.alertmanager.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with alertmanager.baseURL | `alertmanager`  |
  |  `cpro.alertmanager.istioIngress.selector` |  selector for Gateway | `{istio. ingressgateway}`  |
  |  `cpro.alertmanager.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`  |
  |  `cpro.alertmanager.istioIngress.httpPort` | Istio ingress http port | `80`  |
  |  `cpro.alertmanager.istioIngress.gateway` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `btel-common-istio-gateway`  |
  |  `cpro.alertmanager.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`  |
  |  `cpro.alertmanager.istioIngress.tls.httpsPort` | Istio ingress https port | `443`  |
  |  `cpro.alertmanager.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`  |
  |  `cpro.alertmanager.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`  |
  |  `cpro.alertmanager.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `cpro.alertmanager.replicaCount` | it's only used when ha.enabled true. When ha.enabled is false, replicaCount will be hard coded to 1 | `2`  |
  |  `cpro.alertmanager.resources.limits.cpu` | alertmanager pod resource limits of cpu | `500m`  |
  |  `cpro.alertmanager.resources.limits.memory` | alertmanager pod resource limits of memory | `1Gi`  |
  |  `cpro.alertmanager.resources.requests.cpu` | alertmanager pod resource requests of cpu | `10m`  |
  |  `cpro.alertmanager.resources.requests.memory` | alertmanager pod resource requests of memory | `32Mi`  |
  |  `cpro.kubeStateMetrics.enabled` | If true, create kube-state-metrics | `true`  |
  |  `cpro.kubeStateMetrics.fullnameOverride  ` |  Fullname Override value | `cpro-kube-state-metrics`  |
  |  `cpro.kubeStateMetrics.name` | kube-state-metrics container name | `kube-state-metrics`  |
  |  `cpro.kubeStateMetrics.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `cpro.kubeStateMetrics.replicaCount` | desired number of kube-state-metrics pods | `1`  |
  |  `cpro.kubeStateMetrics.resources.limits.cpu` | kube-state-metrics pod resource limits of cpu | `100m`  |
  |  `cpro.kubeStateMetrics.resources.limits.memory` | kube-state-metrics pod resource limits of memory | `200Mi`  |
  |  `cpro.kubeStateMetrics.resources.requests.cpu` | kube-state-metrics pod resource requests of cpu | `10m`  |
  |  `cpro.kubeStateMetrics.resources.requests.memory` | kube-state-metrics pod resource requests of memory | `32Mi`  |
  |  `cpro.nodeExporter.enabled` | If true, create node-exporter | `true`  |
  |  `cpro.nodeExporter.fullnameOverride` | Fullname Override value | `cpro-node-exporter`  |
  |  `cpro.nodeExporter.name` | node-exporter container name | `node-exporter`  |
  |  `cpro.nodeExporter.extraArgs.web.listen-address` | Additional node-exporter container argument, required when node-exporter is brought-up on different port and value should be same as  podHostPort & podContainerPort | `":9100"`  |
  |  `cpro.nodeExporter.extraHostPathMounts` | Additional node-exporter hostPath mounts | `[]`  |
  |  `cpro.nodeExporter.extraConfigmapMounts` | Additional node-exporter configMap mounts | `[]`  |
  |  `cpro.nodeExporter.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `cpro.nodeExporter.resources.limits.cpu` | node-exporter pod resource limits of cpu | `500m`  |
  |  `cpro.nodeExporter.resources.limits.memory` | node-exporter pod resource limits of memory | `500Mi`  |
  |  `cpro.nodeExporter.resources.requests.cpu` | node-exporter pod resource requests of cpu | `100m`  |
  |  `cpro.nodeExporter.resources.requests.memory` | node-exporter pod resource requests of memory | `30Mi`  |
  |  `cpro.server.name` | Prometheus server container name | `server`  |
  |  `cpro.server.fullnameOverride` | Fullname Override value  | `cpro-server`  |
  |  `cpro.server.baseURL` | The external url at which the server can be accessed | `""`  |
  |  `cpro.server.extraHostPathMounts` | Additional Prometheus server hostPath mounts | `[]`  |
  |  `cpro.server.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`  |
  |  `cpro.server.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with server.baseURL | `prometheus`  |
  |  `cpro.server.istioIngress.selector` |  selector for Gateway | `{istio. ingressgateway}`  |
  |  `cpro.server.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`  |
  |  `cpro.server.istioIngress.httpPort` | Istio ingress http port | `80`  |
  |  `cpro.server.istioIngress.gateway` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `btel-common-istio-gateway`  |
  |  `cpro.server.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`  |
  |  `cpro.server.istioIngress.tls.httpsPort` | Istio ingress https port | `443`  |
  |  `cpro.server.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`  |
  |  `cpro.server.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`  |
  |  `cpro.server.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `cpro.server.nodeSelector` | node labels for Prometheus server pod assignment | `{}`  |
  |  `cpro.server.replicaCount` | it's only used when ha.enabled true. when ha.enabled is false, replicaCount will be hard coded to 1 | `2`  |
  |  `cpro.server.resources.limits.cpu` | Prometheus server pod resource limits of cpu | `2`  |
  |  `cpro.server.resources.limits.memory` | Prometheus server pod resource limits of memory | `4Gi`  |
  |  `cpro.server.resources.requests.cpu` | Prometheus server pod resource requests of cpu | `500m`  |
  |  `cpro.server.resources.requests.memory` | Prometheus server pod resource requests of memory | `512Mi`  |
  |  `cpro.pushgateway.enabled` | If true, create pushgateway | `true`  |
  |  `cpro.pushgateway.fullnameOverride` | Fullname Override value | `cpro-pushgateway`  |
  |  `cpro.pushgateway.name` | pushgateway container name | `pushgateway`  |
  |  `cpro.pushgateway.antiAffinityMode` | Affinity mode of push gateway pods. soft means preferredDuringSchedulingIgnoredDuringExecution, hard means requiredDuringSchedulingIgnoredDuringExecution | `"soft"`  |
  |  `cpro.pushgateway.extraArgs` | Additional pushgateway container arguments | `{push.disable-consistency-check: ""}`  |
  |  `cpro.pushgateway.baseURL` | External URL which can access pushgateway, when istio is enabled: baseURL path and Contextroot path should match | `""`  |
  |  `cpro.pushgateway.prefixURL` | The URL prefix at which the container can be accessed. Useful in the case the '-web.external-url' includes a slug. so that the various internal URLs are still able to access as they are in the default case | `""`  |
  |  `cpro.pushgateway.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`  |
  |  `cpro.pushgateway.istioIngress.Contextroot` | Context root that is used to distinguish services. this should align with server.baseURL | `pushgateway`  |
  |  `cpro.pushgateway.istioIngress.selector` |  selector for Gateway | `{istio. ingressgateway}`  |
  |  `cpro.pushgateway.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`  |
  |  `cpro.pushgateway.istioIngress.httpPort` | Istio ingress http port | `80`  |
  |  `cpro.pushgateway.istioIngress.gateway` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `btel-common-istio-gateway`  |
  |  `cpro.pushgateway.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`  |
  |  `cpro.pushgateway.istioIngress.tls.httpsPort` | Istio ingress https port | `443`  |
  |  `cpro.pushgateway.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`  |
  |  `cpro.pushgateway.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `pushgateway-secret`  |
  |  `cpro.pushgateway.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `cpro.pushgateway.nodeSelector` | node labels for Pushgateway server pod assignment | `{}`  |
  |  `cpro.pushgateway.replicaCount` | Number of replicas of pushgateway | `1`  |
  |  `cpro.pushgateway.resources.limits.cpu` | Pushgateway pod resource limits of cpu | `100m`  |
  |  `cpro.pushgateway.resources.limits.memory` | Pushgateway pod resource limits of memory | `200Mi`  |
  |  `cpro.pushgateway.resources.requests.cpu` | Pushgateway pod resource requests of cpu | `10m`  |
  |  `cpro.pushgateway.resources.requests.memory` | Pushgateway  pod resource requests of memory | `32Mi`  |
  |  `cpro.pushgateway.securityContext` | Security context of the Pushgateway pods | `{ runAsUser: 65534}`  |
  |  `cpro.pushgateway.service.type` | Type of the service | `ClusterIP`  |
  |  `cpro.alertmanagerFiles.alertmanager.yml` | alertmanager ConfigMap entries, this is used when webhook4fluentd.enabled is false. alertmanagerFiles, alertmanagerWebhookFiles are mutually exclusive. only one of them will be used |  |
  |  `cpro.serverFiles.prometheus.yml` | Prometheus server configuration |  |
  |  `cpro.restserver.enabled` | If true, create restserver| `false`  |
  |  `cpro.restserver.fullnameOverride` | Fullname override value| `cpro-restserver`  |
  |  `cpro.restserver.name` | restserver container name | `restserver`  |
  |  `cpro.restserver.BCMT.serverURL` | BCMT URL that is needed for accessing API server | `https://k8s-apiserver.bcmt.cluster.local:8443`  |
  |  `cpro.restserver.replicaCount` | restserver replica count | `1`  |
  |  `cpro.restserver.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`  |
  |  `cpro.restserver.istioIngress.Contextroot` | Context root that is used to distinguish services. | `restserver`  |
  |  `cpro.restserver.istioIngress.selector` |  selector for Gateway | `{istio. ingressgateway}`  |
  |  `cpro.restserver.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `*`  |
  |  `cpro.restserver.istioIngress.httpPort` | Istio ingress http port | `80`  |
  |  `cpro.restserver.istioIngress.gateway` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `btel-common-istio-gateway`  |
  |  `cpro.restserver.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `true`  |
  |  `cpro.restserver.istioIngress.tls.httpsPort` | Istio ingress https port | `443`  |
  |  `cpro.restserver.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, ISTIO_MUTUAL | `SIMPLE`  |
  |  `cpro.restserver.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `restserver-secret`  |
  |  `cpro.restserver.resources.limits.cpu` | restserver pod resource limits of cpu | `500m`  |
  |  `cpro.restserver.resources.limits.memory` | restserver pod resource limits of memory | `500Mi`  |
  |  `cpro.restserver.resources.requests.cpu` | restserver pod resource requests of cpu | `100m`  |
  |  `cpro.restserver.resources.requests.memory` | restserver pod resource requests of memory | `128Mi`  |
  |  `cpro.restserver.nodeSelector` | node labels for restserver pod assignment | `{}`  |
  |  `cpro.restserver.tolerations` | Tolerations of RestAPI server | `[]`  |
  |  `cpro.restserver.configs.ncmsUsername` | ncms user name | `user-input`  |
  |  `cpro.restserver.configs.ncmsPassword` | ncms password | `user-input`  |
  |  `cpro.restserver.configs.ncmsPassPhrase` | ncms passphrase | `user-input`  |
  |  `cpro.restserver.configs.httpsEnabled` | if https access enabled | `false`  |
  |  `cpro.restserver.configs.restCACert` | restserver CACert | `content of restCACert`  |
  |  `cpro.restserver.configs.restServerKey` | restserver private key | `content of restServerKey`  |
  |  `cpro.restserver.configs.restServerCert` | restserver cert | `content of restServerCert`  |
  |  __`gen3gppxml:`__  |  __Configure paramaters for cpro-gen3gppxml component__   |  __**`Please refer cpro-gen3gppxml chart README for more details`**__  |
  |  `gen3gppxml.replicaCount` | No of replicas of Gen3gppxml pod | `1`  |
  |  `gen3gppxml.persistence.pvc_auto_delete` | If set to true, the pvc created during chart deployment will be deleted during uninstalll | `true`  |
  |  `gen3gppxml.name` | Gen3gppxml Container name | `gen3gppxml`  |
  |  `gen3gppxml.helm3` | Enable this flag to install/upgrade with helm version 3 | `false`  |
  |  `gen3gppxml.rbac.enabled` | If true, create and use RBAC resources | `true`  |
  |  `gen3gppxml.rbac.pspUseAppArmor` | If true, enable apparmor annotations on PSPS and pods | `false`  |
  |  `gen3gppxml.serviceAccountName` | ServiceAccount to be used for Gen3gppxml component |  |
  |  `gen3gppxml.resources.requests.memory` | Gen3gppxml pod resource requests of memory | `256Mi`  |
  |  `gen3gppxml.resources.requests.cpu` | Gen3gppxml pod resource requests of cpu | `250m`  |
  |  `gen3gppxml.resources.limits.memory` | Gen3gppxml pod resource limits of memory | `1024Mi`  |
  |  `gen3gppxml.resources.limits.cpu` | Gen3gppxml pod resource limits of cpu | `500m`  |
  |  `gen3gppxml.service.name` | Name of Gen3gppxml service | `gen3gppxml`  |
  |  `gen3gppxml.service.serviceType` | Type of Gen3gppxml service | `ClusterIP`  |
  |  `gen3gppxml.service.sftpPort` | Port number of SFTP service | `2309`  |
  |  `gen3gppxml.service.sftpNodePort` | Node port number of SFTP service | `30022`  |
  |  `gen3gppxml.istio.enable` | Istio feature is enabled or not | `false`  |
  |  `gen3gppxml.istio.mtls_enable` | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`  |
  |  `gen3gppxml.istio.cni_enable` | CNI is enabled or not | `true`  |
  |  `gen3gppxml.istioIngress.enabled` | Istio Ingress is enabled or not. Works only istio.enabled is true | `true`  |
  |  `gen3gppxml.istioIngress.selector` | selector for Gateway | `{istio. ingressgateway}`  |
  |  `gen3gppxml.istioIngress.Contextroot` | Context root that is used to distinguish services | `gen3gppxml`  |
  |  `gen3gppxml.istioIngress.host` | Hosts used to access the management GUI from istio ingress gateway  | `"*"`  |
  |  `gen3gppxml.istioIngress.httpPort` | Istio ingress http port | `80`  |
  |  `gen3gppxml.istioIngress.gatewayName` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here gatewayName is used for http/https | `"btel-common-istio-gateway"`  |
  |  `gen3gppxml.istioIngress.tls.enabled` | TLS is enabled or not in Istio Ingress | `false`  |
  |  `gen3gppxml.istioIngress.tls.httpsPort` | Istio ingress https port | `443`  |
  |  `gen3gppxml.istioIngress.tls.mode` | Istio tls mode. Allowed values are SIMPLE, MUTUAL, PASSTHROUGH | `PASSTHROUGH`  |
  |  `gen3gppxml.istioIngress.tls.credentialName` | Secret name of certificates that need to be used in Istio gateway. ISTIO SDS feature needs to be enabled. This needs to be created before installing the chart | `am-gateway`  |
  |  `gen3gppxml.istioIngress.tcpGatewayName` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here. tcpGatewayName is used for sftp |  |
  |  `gen3gppxml.istioIngress.sftpPort` | ISTIO Ingress SFTP Port | `31400`  |
  |  `gen3gppxml.istioIngress.tcpHost` | the host used to access the management GUI from istio ingress gateway(for tcp) | `"*"`  |
  |  `gen3gppxml.tolerations` | node taints to tolerate (requires Kubernetes >=1.6) | `[]`  |
  |  `gen3gppxml.nodeSelector` | node labels for gen3gppxml pod assignment | `{}` |  
  |  __`grafana:`__  |  __Configure paramaters for grafana component__   |  __**`Please refer grafana chart README for more details`**__ |
  |  `grafana.rbac.enabled`             | If true, create and use RBAC resources | `true` |  
  |  `grafana.rbac.pspUseAppArmor`      | If true, enable apparmor annotations on PSPS and pods | `false`  |
  |  `grafana.serviceAccountName`       | ServiceAccount to be used for Grafana component |  |
  |  `grafana.name`                     | Grafana Container name | `grafana`  |
  |  `grafana.fullnameOverride`         | Fullname Override value | `grafana`  |
  |  `grafana.helm3`                    | Enable this flag to install/upgrade with helm version 3 | `false`  |
  |  `grafana.HA.enabled`               | Enable this flag to enable HA for Grafana pods | `true`  |
  |  `grafana.istio.enable`             | Istio feature is enabled or not | `false`  |
  |  `grafana.istio.mtls_enable`        | Istio Mutual TLS is enabled or not. These will be taken into account based on istio.enabled | `true`  |
  |  `grafana.istio.cni_enable`         | CNI is enabled or not | `true`  |
  |  `grafana.cmdb.enabled`  | If true, Mariadb will be installed |  `false`  |
  |  `grafana.cmdb.rbac_enabled`  |  If true, role based access is enabled  | `true`  |
  |  `grafana.cmdb.istio.enabled`  |  Whether to enable istio or not  | `false`  |
  |  `grafana.cmdb.mariadb.persistence.enabled`  |  To enable persistence  |  `true`  |
  |  `grafana.cmdb.mariadb.persistence.backup.preserve_pvc` | Preserve PVC policy of persistence backup | `false`  |
  |  `grafana.ingress.annotations`      | Ingress annotations | `{}`  |
  |  `grafana.ingress.path`             | Ingress path | `/grafana/?(.*)`  |
  |  `grafana.istioIngress.enabled`     | Enable to use istio ingress gateway(Envoy) | `true`  |
  |  `grafana.istioIngress.Contextroot` | when istio is enabled: root_url path and Contextroot path should match | `grafana`  |
  |  `grafana.istioIngress.selector`    | Istio ingress gateway selector | `{istio. ingressgateway}`  |
  |  `grafana.istioIngress.host`        | the host used to access the management GUI from istio ingress gateway | `"*"`  |
  |  `grafana.istioIngress.httpPort`    | HTTP port to access GUI from ISTIO Ingress gatway | `80`  |
  |  `grafana.istioIngress.gatewayName` | Keep gatewayName to empty to create kubernetes gateway resource. If new virtualservice needs to refer to existing gateway then mention that name here | `"btel-common-istio-gateway"`  |
  |  `grafana.istioIngress.tls.enabled` | tls section will be used if gatewayName is empty | `true`  |
  |  `grafana.istioIngress.tls.httpsPort` | HTTPS port for TLS section | `443`  |
  |  `grafana.istioIngress.tls.mode` | mode could be SIMPLE, MUTUAL, PASSTHROUGH, ISTIO_MUTUAL | `SIMPLE`  |
  |  `grafana.istioIngress.tls.credentialName` | Secret name for Istio Ingress | `"am-gateway"`  |
  |  `grafana.resources.limits.cpu`    | CPU Resource limit for Grafana Pod | `500m`  |
  |  `grafana.resources.limits.memory` | Memory Resource limit for Grafana Pod | `1Gi`  |
  |  `grafana.resources.requests.cpu`  | CPU Resource REquests for Grafana Pod | `100m`  |
  |  `grafana.resources.requests.memory` | Memory Resource REquests for Grafana Pod | `128Mi`  |
  |  `grafana.nodeSelector`             | Node labels for pod assignment | `{}`  |
  |  `grafana.tolerations`              | Toleration labels for pod assignment | `[]`  |
  |  `grafana.affinity`                 | Affinity settings for pod assignment | `{}`  |
  |  `grafana.nodeAntiAffinity`         | Antiaffinity for Pod Assignments | `hard`  |
  |  `grafana.persistence.enabled`      | Use persistent volume to store data | `false`  |
  |  `grafana.adminUser`                | Admin User name of Grafana UI | `admin`  |
  |  `grafana.schedulerName`            | Alternate scheduler name | `nil`  |
  |  `grafana.SetDatasource.enabled`    | If true, an initial Grafana Datasource will be set | `true`  |
  |  `grafana.SetDatasource.datasource.url` | The url of the datasource. To set correctly you need to know the right datasource name and its port ahead. Check kubernetes dashboard or describe the service should fulfill the requirements. Synatx like `http://<release name>-<server name>:<port number> | `"http://prometheus-cpro-server"`  |
  |  `grafana.livenessProbe.scheme` | Liveness Probe scheme | `HTTPS`  |
  |  `grafana.readinessProbe.scheme` | Readiness Probe scheme | `HTTPS  |
  |  `grafana.scheme` | Grafana Scheme | `https`  |
  |  `grafana.grafana_ini.paths.data` | Grafana primary configuration. NOTE: values in map will be converted to ini format. ref: http://docs.grafana.org/installation/configuration/ | `/var/lib/grafana/data`  |
  |  `grafana.grafana_ini.server.protocol` | Grafana server protocol | `https`  |
  |  `grafana.grafana_ini.server.root_url` | when istio is enabled: root_url path and Contextroot path should match  | `""`  |
  |  `grafana.grafana_ini.server.cert_file` | Grafana server cerificate | `/etc/grafana/ssl/server.crt`  |
  |  `grafana.grafana_ini.cert_key` | Certificate key | `/etc/grafana/ssl/server.key`  |
  |  `grafana.grafana_ini.serve_from_sub_path` | set to true when istio is enabled | `true`  |
  |  `grafana.grafana_ini.auth.disable_login_form` |Flag for disable login form | `false`  |
  |  `grafana.grafana_ini.auth.disable_signout_menu` |  Flag for disable signout menu| `false`  |
  |  `grafana.grafana_ini.database.type` | Database type | `sqlite3`  |
  |  `grafana.grafana_ini.database.host` | Database host | `grafanadb-cmdb-mysql:3306`  |
  |  `grafana.grafana_ini.database.name` | Database name | `grafana`  |
  |  `grafana.grafana_ini.database.user` | Database user | `grafana`  |
  |  `grafana.grafana_ini.database.password` |  Database password| `grafana`  |
  |  `grafana.grafana.ini`              | Grafana's primary configuration | `{}`  |
  |  `grafana.annotations`              | Deployment annotations | `{}`  |
  |  `grafana.podAnnotations`           | Pod annotations | `{}`  |
  |  __`citm:`__  |  __Configure paramaters for citm-ingress component__   |  *`Please refer citm-ingress chart README for more details`*  |
  |  `citm-ingress.istio.cni.enabled`  |   Whether istio cni is enabled in the environment |  `true`  |
  |  `citm-ingress.istio.enabled`  |   If true, create & use Istio Policy |  `false`  |
  |  `citm-ingress.istio.mtls.enabled`  |   Allow mutual TLS as well as clear text for deployment |  `true`  |
  |  `citm-ingress.istio.permissive`  |   Allow mutual TLS as well as clear text for deployment |  `true`  |
  |  `citm-ingress.istio.version`  |   Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5. There is only specific setting for Istio 1.4  |  `1.5`  |
  |  `citm-ingress.rbac.enabled`  |   Rbac flag |  `true`  |
  |  `citm-ingress.rbac.serviceAccountName`  |   Use this service account when default404.rbac.enabled=false |  `default`  |
  |  `citm-ingress.controller.healthzPort`  |   port for healthz endpoint. Default is to use httpPort. Overwrite this if you want another port for checking.<br>See [--healthz-port](docker-ingress-cli-arguments.md) ingress controller argument |  `null`  |  
  |  `citm-ingress.controller.httpPort`  |   Indicates the port to use for HTTP traffic (default 80).<br>See [--http-port](docker-ingress-cli-arguments.md) ingress controller argument |  `80`  |  
  |  `citm-ingress.controller.httpsPort`  |   Indicates the port to use for HTTPS traffic (default 443).<br>See [--https-port](docker-ingress-cli-arguments.md) ingress controller argument |  `443`  |  
  |  `citm-ingress.controller.ingressClass`  |   name of the ingress class to route through this controller.<br>See [--ingress-class](docker-ingress-cli-arguments.md) ingress controller argument |  `nginx`  |  
  |  `citm-ingress.controller.nodeSelector`  |   node labels for pod assignment. For is_edge label, consider setting runOnEdge | {}
  |  `controller.affinity` | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/  |  `{}`  |  
  |  `citm-ingress.controller.replicaCount`  |   desired number of controller pods |  `1`  |  
  |  `citm-ingress.controller.resources.limits.cpu`  |    The Kubernetes CPU resource limits for the MariaDB pods (See K8s documentation) |  `500m`  |  
  |  `citm-ingress.controller.resources.limits.memory`  |    The Kubernetes Memory resource limits for the MariaDB pods (See K8s documentation) |  `512Mi`  |  
  |  `citm-ingress.controller.resources.requests.cpu`  |   The Kubernetes CPU resource requests for the MariaDB pods (See K8s documentation) |  `250m`  |    
  |  `citm-ingress.controller.resources.requests.memory`  |   The Kubernetes Memory resource requests for the MariaDB pods (See K8s documentation)  |  `256Mi`  |   
  |  `citm-ingress.controller.service.targetPorts.http`  |   Sets the targetPort that maps to the Ingress' port 80 |  `80`  |  
  |  `citm-ingress.controller.service.targetPorts.https`  |   Sets the targetPort that maps to the Ingress' port 443 |  `443`  |  
  |  `citm-ingress.default404.istio.cni`  |   Whether istio cni is enabled in the environment     |  `{enabled`  |    |  `true}`  |  
  |  `citm-ingress.default404.istio.enabled`  |   If true, create & use Istio Policy and virtualservice |  `false`  |  
  |  `citm-ingress.default404.istio.mtls.enabled`  |  Allow mutual TLS as well as clear text for deployment  |  `true`  |  
  |  `citm-ingress.default404.istio.permissive`  |   Allow mutual TLS as well as clear text for deployment  |  `true`  |  
  |  `citm-ingress.default404.istio.version`  |   Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5. There is only specific setting for Istio 1.4 |  `1.5`  |  
  |  `citm-ingress.default404.nodeSelector`  |   node labels for pod assignment. See default404.runOnEdge for edge node selection |  `{}`  |  
  |  `citm-ingress.default404.rbac.enabled`  |   If true, create & use RBAC resources |  `true`  |  
  |  `citm-ingress.default404.rbac.serviceAccountName`  |   ServiceAccount to be used (ignored if rbac.enabled=true)  |  `default`  |  
  |  `citm-ingress.default404.tolerations`  |   node taints to tolerate (requires Kubernetes >=1.6)  |  `[]`  |   
  |  `btel_istio_gateway.create`  |     Create btel common istio gateway  |  `true`  |  
  |  `btel_istio_gateway.gatewayName`  |   Name of btel common istio gateway |  `btel-common-istio-gateway`  |  
  |  `btel_istio_gateway.customgateway_spec`  |   Specification for btel common istio gateway |  `Enter Specification for btel common istio gateway`  | 

 --This section is in progress --

