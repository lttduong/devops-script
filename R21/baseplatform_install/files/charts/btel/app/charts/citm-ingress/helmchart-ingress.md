# Install from charts

This chart bootstraps a citm-ingress controller deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```
$ helm install --name my-release citm-ingress
```

The command deploys nginx-ingress on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

This deploy also a default backend. The [default backend configuration](#default404) section lists the parameters that can be configured during installation for default backend.

**NOTE**: If you're installing a release upper than 1.16.5 (1.16.5 included), make sure configmap ingress-controller-leader-nginx does not exist. If it's present, remove it before installing the chart

```
$ kubectl delete cm ingress-controller-leader-nginx
```
## Updating the Chart

```
$ helm upgrade my-release citm-ingress
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

### Ingress controller

The following tables lists the configurable parameters of the nginx-ingress chart and their default values.

Parameter | Description | Default 
--------- | ----------- | ------- 
global.registry | default ingress controller container image repository | csf-docker-delivered.repo.lab.pl.alcatel-lucent.com
global.podNamePrefix | ability to prefix ALL pod names with prefixes | ""
global.containerNamePrefix |ability to prefix ALL container names with prefixes | ""
registry | controller container image repository| csf-docker-delivered.repo.lab.pl.alcatel-lucent.com 
controller.name | name of the controller component | controller 
controller.imageRepo | controller image repository name | citm/citm-nginx
controller.imageTag | controller container image tag | 1.18.0-1.6
controller.imagePullPolicy | controller container image pull policy | IfNotPresent
[controller.config](#configmap) | nginx ConfigMap entries | none
[controller.customTemplate.configMapName](#custom-template) | configMap containing a custom nginx template | none
[controller.customTemplate.configMapKey](#custom-template) | configMap key containing the nginx template | none
controller.bindAddress | Sets the addresses on which the server will accept requests instead of *.<br>See [bind-address](docker-ingress-configmap.md#bind-address)| none 
controller.workerProcessAsRoot | Required to start nginx worker process as root (default nginx).<br>See [worker-process-as-root](docker-ingress-configmap.md#worker-process-as-root) | false
controller.hostNetwork | If the nginx deployment / daemonset should run on the host's network namespace | true
[controller.dnsPolicy](#dnsconfig) | by ingress controller use hostnetwork, so default set to ClusterFirstWithHostNet | ClusterFirstWithHostNet
[controller.dnsConfig](#dnsconfig) | The dnsConfig field is optional and it can work with any dnsPolicy settings. However, when a Pod's dnsPolicy is set to "None", the dnsConfig field has to be specified. | 
controller.reusePort | enable "reuseport" option of the "listen" directive for nginx.<br>See [reuse-port](docker-ingress-configmap.md#reuse-port)| true
controller.disableIvp4 | disable Ipv4  for nginx.<br>See [disable-ipv4](docker-ingress-configmap.md#disable-ipv4)| false
controller.disableIvp6 | disable Ipv6  for nginx.<br>See [disable-ipv6](docker-ingress-configmap.md#disable-ipv6)| false
controller.enableHttp2OnHttp | Set it to true is you want http2 on http plain text | false
controller.securityContextPrivileged | set securityContext to Privileged | false
controller.workerProcessAsRoot | Required to start nginx worker process as root (default nginx) | false
controller.httpRedirectCode | set http-redirect-code.<br>See [http-redirect-code](docker-ingress-configmap.md#http-redirect-code) | 308
controller.defaultBackendService | default 404 backend service; required only if defaultBackend.enabled = false | ""
[controller.defaultSSLCertificate](#default-certificate) |  Optionally specify the secret name for default SSL certificate. Must be namespace/secret_name. See also (#cert-manager) | ""
controller.allowCertificateNotFound | If a ingress certificate is not found, use default certificate. Set this to false if you want to respond with HTTP 403 (access denied) instead of using default certificate | true
httpsForAllServers | If set to true, we force https on all ingress resources. If no certificate is provided for an ingress resource, default certificate will be used. You can overwrite it using [default certificate](#default-certificate) | false
controller.UdpServiceConfigMapNoNamespace | set to true to have all config map starting with this name udp-services-configmap, whatever the namespace will be added | false
controller.TcpServiceConfigMapNoNamespace | set to true to have all config map starting with this name tcp-services-configmap, whatever the namespace will be added | false
[controller.CalicoVersion](#calico) | if you want to activate ddiscovery of ipv6 endpoints. Endpoints are retrieved using calico CNI network subsystem.<br>Supported values are not-used, v1 or v3)  | not-used
[controller.splitIpv4Ipv6StreamBackend](#calico) | By default, create only one stream for all backends.<br>NOTE: In case of transparent proxy activated, this property is not taken into account (aka: we'll generate two different streams) | false
controller.healthzPort |  port for healthz endpoint. Default is to use httpPort. Overwrite this if you want another port for checking.<br>See [--healthz-port](docker-ingress-cli-arguments.md) ingress controller argument | none
controller.httpPort |  Indicates the port to use for HTTP traffic (default 80).<br>See [--http-port](docker-ingress-cli-arguments.md) ingress controller argument| none
controller.httpsPort |  Indicates the port to use for HTTPS traffic (default 443).<br>See [--https-port](docker-ingress-cli-arguments.md) ingress controller argument | none
controller.sslProtocols | Indicates ssl protocols to be used. Default TLS 1.2 and TLS 1.3 | TLSv1.3 TLSv1.2
controller.sslCiphers | Indicates ssl cipher list to be activated | TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
[controller.sslPasstroughProxyPort](tls.md#ssl-passthrough) |  Default port to use internally for SSL when SSL Passthgough is enabled (default 442).<br>See [--ssl-passthrough-proxy-port](docker-ingress-cli-arguments.md) ingress controller argument  | 442
[controller.sslPasstroughSplitPortListening](tls.md#ssl-passthrough) |  Split flow when ssl passthrough is activated. HTTPS with TLS termination is reachable on controller.httpsPort and SSL passthrough is reachable on controller.sslPasstroughProxyPort  | false
controller.statusPort |  Indicates the TCP port to use for exposing the nginx status page (default 18080).<br>See [--status-port](docker-ingress-cli-arguments.md) ingress controller argument  | none
controller.forcePort |  force http & https port to default (80 & 443) | none
controller.electionID | election ID to use for the status update. <br>See [--election-id](docker-ingress-cli-arguments.md) ingress controller argument | ingress-controller-leader
controller.ingressClass | name of the ingress class to route through this controller.<br>See [--ingress-class](docker-ingress-cli-arguments.md) ingress controller argument  | nginx
controller.podLabels | labels to add to the pod container metadata | none
controller.publishService.enabled | Allows customization of the external service | none
controller.publishService.pathOverride | Allows overriding of the publish service to bind to | false
[controller.scope.enabled](#scope) | limit the scope of the ingress controller | false (watch all namespaces)
[controller.scope.namespace](#scope) | namespace to watch for ingress | "" (use the release namespace)
[controller.etcd.enabled](#calico) | enable  Configuration of the location of your etcd cluster | false
[controller.etcd.etcd_endpoints](#calico) | etcd endpoints list | none
[controller.etcd.ETCD_CA_CERT](#calico) | etcd ca cert file path | /etc/etcd/ssl/ca.pem
[controller.etcd.ETCD_CLIENT_CERT](#calico) | etcd client cert file path | /etc/etcd/ssl/etcd-client.pem
[controller.etcd./etc/etcd/ssl/etcd-client-key.pem](#calico) | etcd client key file path | /etc/etcd/ssl/etcd-client-key.pem
[controller.blockCidrs](#block)|A comma-separated list of IP addresses (or subnets), requests from which have to be blocked globally|None
[controller.blockUserAgents](#block)|A comma-separated list of User-Agent, requests from which have to be blocked globally.<br>It's possible to use here full strings and regular expressions.
[controller.blockReferers](#block)|A comma-separated list of Referers, requests from which have to be blocked globally.<br>It's possible to use here full strings and regular expressions
controller.logToJsonFormat | to format log in json format | true
[controller.extraArgs](#extraargs) | Additional controller container [argument](docker-ingress-cli-arguments.md) | {}
controller.kind | install as Deployment or DaemonSet | DaemonSet
controller.tolerations | node taints to tolerate (requires Kubernetes >=1.6) | []
controller.runOnEdge | add a nodeSelector label in order to run only on edge node. Set this to false if you do not want only edge node | true
controller.nodeSelector | node labels for pod assignment. For is_edge label, considere setting runOnEdge | {}
controller.affinity | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ | {}
controller.podAnnotations | annotations to be added to pods | {}
controller.replicaCount | desired number of controller pods | 1
controller.resources | controller pod resource requests & limits | {}
controller.service.enabled | enable controller service | true
controller.service.annotations | annotations for controller service | {}
controller.service.clusterIP | internal controller cluster service IP | ""
controller.service.externalIPs | controller service external IP addresses | []
controller.service.loadBalancerIP | IP address to assign to load balancer (if supported) | ""
controller.service.loadBalancerSourceRanges | list of IP CIDRs allowed access to load balancer (if supported) | []
controller.service.targetPorts.http | Sets the targetPort that maps to the Ingress' port 80 | 80
controller.service.targetPorts.https | Sets the targetPort that maps to the Ingress' port 443 | 443
controller.service.type | type of controller service to create | ClusterIP
controller.service.nodePorts.http | If controller.service.type is NodePort and this is non-empty, it sets the nodePort that maps to the Ingress' port 80 | ""
controller.service.nodePorts.https | If controller.service.type is NodePort and this is non-empty, it sets the nodePort that maps to the Ingress' port 443 | ""
controller.serviceOnStream.enable | Defines if on UDP/TCP service, request are forwarded to k8s service instead of backends. Needed by Istio for stream. | false
[controller.dynamicUpdateServiceStream](#dynamicupdateservicestream) | Defines if on UDP/TCP service stream, services are dynamically updated. | false
[rbac.enabled](#rbac) | If true, create & use RBAC resources for ingress controller | true
[rbac.serviceAccountName](#rbac) | ServiceAccount to be used (ignored if rbac.enabled=true) | default
[controller.snippetNamespaceAllowed](#snippet-authorize) | Restrict usage of Lua code in Snippet annotation only for a subset of namespace. By default, all namespaces can use Lua code in snippet body | ""
[controller.deniedInSnippetCode](#snippet-authorize) | Set of pattern to check. If found in snippet body, annotation is ignored. Modify with care | "access_by_lua body_filter_by_lua content_by_lua header_filter_by_lua init_by_lua init_worker_by_lua log_by_lua rewrite_by_lua set_by_lua"
[controller.customLuaModules.enabled](#custom-lua) | enable possibility of providing ConfigMap with lua modules | false
[controller.customLuaModules.modules](#custom-lua) | list of custom lua modules. Each module consists of name (moduleName) and ConfigMap name with lua sources (sourcesConfigMapName) | none
[controller.modsecurity.enables](#mod-security) | Set this to true if you want to activate modsecurity globally | false
[controller.modsecurity.enableOwaspCrs](#mod-security) | Set this to true if you want to activate OWASP ModSecurity core rule set (CRS). See https://modsecurity.org/crs/ | false
[certManager.used](#cert-manager) | Use cert-manager service for generating default certificate | false
[certManager.duration](#cert-manager) | Duration of the generated certificate |   8760h # 365d
[certManager.renewBefore](#cert-manager) | Time before expiration for renewing the certificate | 360h # 15d
[certManager.keySize](#cert-manager) | certificate key size | 2048
[certManager.servername](#cert-manager) | your server name (FQDN) |
[certManager.dnsNames](#cert-manager) | List of dns names to be associated with this certificate | Empty by default. Will also use value provided in security.servername
[certManager.ipAddresses](#cert-manager) | List of server ipAddresses |
[certManager.issuerRef.name](#cert-manager)      | Issuer name to be used by cert-manager                     |   ncms-ca-issuer                                   |
[certManager.issuerRef.kind](#cert-manager)      | Issuer kind to be used by cert-manager                     | ClusterIssuer                                     |
istio.enabled | If true, create & use Istio Policy | false
istio.version | Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5. There is only specific setting for Istio 1.4 | 1.5
istio.permissive | Allow mutual TLS as well as clear text for deployment | true
[tcp](#stream-backend) | TCP service key:value pairs | {}
[udp](#stream-backend) | UDP service key:value pairs | {}
[grafanaSecret](#grafana) | Name of the secret that contains the grafana credentials | {}
[grafanaURL](#grafana) |  URL and port of the grafana server, without 'http:// | {}
[metrics](#enable-metrics) |  Set this to true if you want metrics witout Grafana rendering | false

### default404
You can also adapt following parameters for default backend

Parameter | Description | Default
--------- | ----------- | ------- 
defaultBackend.enable | If false, controller.defaultBackendService must be provided | true
[defaultBackend.serviceName](#nameOverride) | Provide name of the created default backend. Usefull when `nameOverride` or `fullnameOverride` is provided | Default is `Namespace`/`Name`-default404
[default404.rbac.enabled](#rbac) | If true, create & use RBAC resources for default backend | true
default404.nodeSelector | node labels for pod assignment. See default404.runOnEdge for edge node selection | {} 
default404.runOnEdge | If true, add a nodeSelector label in order to run default backend only on edge node | false
default404.tolerations | node taints to tolerate (requires Kubernetes >=1.6) | []
default404.affinity | Node affinity. See https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/ | {}
default404.replicaCount | desired number of default backend pods | 1 
default404.resources | default backend pod resource requests & limits | {}
default404.service.service.clusterIP | internal default backend cluster service IP | ""
default404.service.service.externalIPs | default backend service external IP addresses | []
default404.service.service.servicePort | default backend service port to create | 8080 
default404.service.service.type | type of default backend service to create | ClusterIP
default404.rbac.enabled | If true, create & use RBAC resources | true
default404.rbac.serviceAccountName | Use this service account when default404.rbac.enabled=false | default
default404.istio.enabled | If true, create & use Istio Policy and virtualservice | false
default404.istio.version | Istio version available in the cluster. For release upper or equal to 1.5, you can keep 1.5. There is only specific setting for Istio 1.4 | 1.5
default404.istio.permissive | Allow mutual TLS as well as clear text for deployment | true
default404.istio.cni.enabled | Whether istio cni is enabled in the environment | false
default404.backend.page.title | page title of default http backend | 404 - Not found
default404.backend.page.body | page body of default http backend | The requested page was not found
default404.backend.page.copyright | copyright of default http backend | Nokia. All rights reserved
default404.backend.page.productFamilyName | Product Family Name of default http backend| Nokia
default404.backend.page.productName | Product name of default http backend | 
default404.backend.page.productRelease | Product release of default http backend | 
default404.backend.page.toolbarTitle | toolbar title of default http backend | View more ...
default404.backend.page.imageBanner | Image logo of default http backend| Nokia_logo_white.svg
default404.backend.debug | activate debug log of default http backend | false

See default404 [rendering](docker-default404.md#rendering)

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```
$ helm install citm-ingress --name my-release -f values.yaml
```

## Run examples

### calico

If you want to retrieve ipv6 endpoints, using calico CNI release 3

```
$ helm install citm-ingress --set controller.etcd.enabled=true,controller.CalicoVersion=v3,controller.etcd.etcd_endpoints="https://192.168.1.2:2379"
```
### block
Hereafter, various ways to block incoming request, based on cidr, user-agent or referer.
#### blockCidrs

A comma-separated list of IP addresses (or subnets), requestst from which have to be blocked globally.

References: http://nginx.org/en/docs/http/ngx_http_access_module.html#deny

If you want to block 192.168.1.0/24 and 172.17.0.1 and 2001:0db8::/32

```
$ helm install citm-ingress --set controller.blockCidrs="192.168.1.0/24\,172.17.0.1\,2001:0db8::/32"
```
#### blockUserAgents
A comma-separated list of User-Agent, requestst from which have to be blocked globally. It's possible to use here full strings and regular expressions. 

More details about valid patterns can be found at map Nginx directive documentation.

References: http://nginx.org/en/docs/http/ngx_http_map_module.html#map

If you want to block curl/7.63.0 and Mozilla/5.0 user agent incoming request

```
$ helm install citm-ingress --set controller.blockUserAgents="curl/7.63.0\,~Mozilla/5.0"
```

#### blockReferers
A comma-separated list of Referers, requestst from which have to be blocked globally. It's possible to use here full strings and regular expressions. 

More details about valid patterns can be found at map Nginx directive documentation.

References: http://nginx.org/en/docs/http/ngx_http_map_module.html#map

If you want to block request having referrer security.com/ or www.example.org/galleries/ or something containing google
```
$ helm install citm-ingress --set controller.blockReferers="security.com/\,www.example.org/galleries/\,~\.google\."
```

### dnsconfig

See [https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)

If you want to specify your own dns configuration for ingress controller pod, set dnsPolicy to `None`

```
$ cat input.yaml 
controller:
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - 1.2.3.4
    searches:
      - ns1.svc.cluster-domain.example
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

```
$ helm install citm-ingress -f input.yaml
```
### Monitoring

#### enable-metrics
You can activate metrics on vhost and stream. 

```
$ helm install citm-ingress --set metrics=true
```

Rendering is available at

* http://edge_ip:18080/nginx-console/status.html (this one integrate streamStatus and vhostStatus in the same page)
* http://edge_ip:18080/vhostStatus
* http://edge_ip:18080/streamStatus
* http://edge_ip:18080/nginx_status

* Prometheus metrics are available at http://edge_ip:9913/metrics

18080 is the default port for status page. See controller.statusPort

#### grafana
grafana secret is built using grafana helm release and -cpro-grafana. 

grafanaURL is the url of grafana service, or IP of pod. Port 3000 is the port for importing dashboard

Refer to [CPRO user guide](https://confluence.app.alcatel-lucent.com/display/plateng/CPRO+-+Prometheus) for details

```
$ helm install citm-ingress --set grafanaSecret=grafana-cpro-grafana,grafanaURL=192.168.2.54:3000
```

#### FIXME Rendering to be put here

### configmap
You can add any of supported [configmap attribute](docker-ingress-configmap.md) using controller.config

Example, to disable ipv6 listening, use http2 for ssl connection and set http2-max-field-size to 12345

```
$ helm install citm-ingress --set controller.config.disable-ipv6=true --set controller.config.http2-max-field-size=12345 --set controller.config.use-http2=true
```

To set log level at debug in nginx
```
$ helm install citm-ingress --set controller.config.error-log-level=debug
```

### Security

#### cert-manager
citm-ingress supports cert-manager. You can use cert-manager for specifying default ssl certificate. This overwrite controller.defaultSSLCertificate
```
$ helm install citm-ingress --set certManager.used=true,certManager.servername=foo.bar.com
```
or using an input file
```
$ cat input.yaml 
certManager:
  used: true
  servername: foo.bar.com
  ipAddresses: 
  - 127.0.0.1
  - 127.0.0.2 
  dnsNames: 
  - "*.foo.bar.com"
```

```
$ helm install --name citm-ab --namespace ab citm-ingress -f input.yaml
```
Content of generated secret
```
# kubectl -n ab describe secrets tls-citm-ab-citm-ingress 
Name:         tls-citm-ab-citm-ingress
Namespace:    ab
Labels:       <none>
Annotations:  cert-manager.io/alt-names: foo.bar.com
              cert-manager.io/certificate-name: tls-citm-ab-citm-ingress
              cert-manager.io/common-name: foo.bar.com
              cert-manager.io/ip-sans: 127.0.0.1,127.0.0.2
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: ncms-ca-issuer
              cert-manager.io/uri-sans: 

Type:  kubernetes.io/tls

Data
====
ca.crt:   1257 bytes
tls.crt:  1277 bytes
tls.key:  1679 bytes
```

#### default-certificate

By default, CITM ingress controller provide a default Fake certificate, self signed. You can use [cert manager](#cert-manager) or create your own certificate.

Hereafter, how to use a created certificate named mysecret

```
$ CERT_NAME=mysecret
$ KEY_FILE=/tmp/${CERT_NAME}.key
$ CERT_FILE=/tmp/${CERT_NAME}.crt
$ HOST=$(hostname -s)
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=Nokia"
$ kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
$ rm -f $KEY_FILE $CERT_FILE
$ kubectl get secret mysecret
NAME       TYPE                DATA      AGE
mysecret   kubernetes.io/tls   2         15s

$ kubectl describe secret mysecret
Name:         mysecret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1135 bytes
tls.key:  1704 bytes
```
Now, you can use it when deploying CITM ingress chart
```
$ helm install citm-ingress --set controller.defaultSSLCertificate=default/mysecret
```
Note that templating is supported, so something like this will be correctly expanded (using a values.yaml)
```
controller:
  defaultSSLCertificate: "{{ .Release.Namespace }}/mysecret"
```
```
$ helm install citm-ingress -f values.yaml
```

#### modsecurity
You may want to activate ModSecurity (WAF) globally. CITM ingress comes with a minimum set of rules.
OWASP ModSecurity Core Rule Set (CRS) can aslo be activated, thanks to enableOwaspCrs

```
$ helm install citm-ingress --namespace ab --set controller.modsecurity.enabled=true,controller.modsecurity.enableOwaspCrs=true
```

#### snippet-authorize
You can restrict usage of Lua code in Snippet annotation only for a subset of namespace. By default, check is not activated

To allow Snippet code with Lua code only in foo and bar namespaces, set controller.snippetNamespaceAllowed to "foo bar"

```
$ helm install citm-ingress --set controller.snippetNamespaceAllowed="foo bar"
```
You can also overwritte checked pattern which are denied by providing (controller.deniedInSnippetCode). 

Setting this parameter to something else than the default provided, ONLY if you know what you're doing.

### rbac
By default, RBAC is enabled for citm-ingress and default404. If for any reason, you want to disable, set rbac.enabled to false and default404.rbac.enabled false
You can provide your own ServiceAccount (`rbac.serviceAccountName`, `default404.rbac.serviceAccountName`). In that case, check [which ressources](rbac.md) are needed. 

### nameOverride

* fullnameOverride

```
$ helm install --namespace ab --name citm-ab ./citm-ingress --set fullnameOverride=kiki34,default404.fullnameOverride=kikid404,defaultBackend.serviceName=ab/kikid404  
$ kubectl -n ab get pods,svc -o wide
NAME                            READY   STATUS    RESTARTS   AGE     IP               NODE             NOMINATED NODE   READINESS GATES
pod/kiki34-5zhlc                1/1     Running   0          2m57s   172.16.2.8       bcmt-edge-02     <none>           <none>
pod/kiki34-jtn8v                1/1     Running   0          2m57s   172.16.2.7       bcmt-edge-01     <none>           <none>
pod/kikid404-6c7f855ffc-54ksg   1/1     Running   0          2m57s   192.168.56.155   bcmt-worker-02   <none>           <none>

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE     SELECTOR
service/kiki34           ClusterIP   None             <none>        8089/TCP,8087/TCP   2m57s   app=citm-ingress,component=controller,release=citm-ab
service/kikid404         ClusterIP   10.254.55.188    <none>        8080/TCP            2m57s   app=default404,component=default404,release=citm-ab
With nameOverride
```

* nameOverride

```
$ helm install --namespace ab --name citm-ab ./citm-ingress --set nameOverride=kiki34,default404.nameOverride=kikid404,defaultBackend.serviceName=ab/citm-ab-kikid404 
$ kubectl -n ab get pods,svc -o wide
NAME                                    READY   STATUS    RESTARTS   AGE   IP                NODE             NOMINATED NODE   READINESS GATES
pod/citm-ab-kiki34-gvpfq                1/1     Running   0          82s   172.16.2.7        bcmt-edge-01     <none>           <none>
pod/citm-ab-kiki34-q68h5                1/1     Running   0          82s   172.16.2.8        bcmt-edge-02     <none>           <none>
pod/citm-ab-kikid404-77c9568fcf-7crcx   1/1     Running   0          82s   192.168.137.132   bcmt-worker-01   <none>           <none>

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE   SELECTOR
service/citm-ab-kiki34     ClusterIP   None             <none>        8089/TCP,8087/TCP   82s   app=kiki34,component=controller,release=citm-ab
service/citm-ab-kikid404   ClusterIP   10.254.78.226    <none>        8080/TCP            82s   app=kikid404,component=default404,release=citm-ab
```

#### scope
By default, CITM ingress controller track all namespaces (ClusterRole)

You can configure it to track only one namespace (Role). In that case, CITM ingress controller also needs to be deployed in this namespace. 

If controller.scope.namespace is not specified, the namespace associated with your release is used.

**NOTE**: If rbac is activated, Kubernetes roles and policies will be declared accordinglly.

```
$ helm install citm-ingress --namespace ab --set controller.scope.enabled=true,controller.scope.namespace=ab 
```

#### serviceAccount

If you provide your own service account, the famous kiki34

```
$ helm install citm-ingress --set rbac.enabled=false,rbac.serviceAccountName=kiki34,default404.rbac.enabled=false,default404.rbac.serviceAccountName=kiki34
```

### stream-backend
Use this to provide description of TCP/UDP services to be exposed by CITM ingress controller. 

The syntax should follow a key,value pair

The key indicates the external port to be used. The value is a reference to a Service in the form "namespace/name:port", where "port" can either be a port number or name. 

TCP ports 80 and 443 (or controller.service.nodePorts.http[s]) are reserved by the controller for servicing HTTP[S] traffic

Example, to declare a TCP service tcpServer on port 2019 and another one on port 2018. Also, an UDP service on port 2020. Namespace is set to default

```
$ helm install citm-ingress --set tcp.2019=default/tcpServer:2019 --set tcp.2018=default/tcpServer:2018 --set udp.2020=default/udpServer:2020
```
Same using a values.yaml
```
tcp: 
  2018: default/tcpServer:2018
  2019: default/tcpServer:2019
udp:
  2020: default/udpServer:2020
```

```
$ helm install citm-ingress -f values.yaml
```
Note that templating is supported, so something like this will be correctly expanded
```
tcp: 
  2015: "{{ .Release.Namespace }}/{{ .Release.Name }}-tcpserver2018:2018"
```
Check [TCP/UDP services](tcp-udp.md#dynamic-configuration) for dynamic declaration of udp/tcp services 

### dynamicUpdateServiceStream

When using dynamic declaration of TCP/UDP backends, ports associated with their services need to be linked with CITM ingress controller. See [how to](tcp-udp.md#ingress-controller-service) for linking ports to CITM ingress controller service.

### custom-template

The NGINX template is located in the file /etc/nginx/template/nginx.tmpl.

It is possible to use a custom template. This can be achieved by using a Configmap as source of the template

!!! Warning "Please note the template is tied to the Go code"

- Do not change names in the variable $cfg."

- For more information about the template syntax please check the [go template package](https://golang.org/pkg/text/template/)

This being said, just create a config map containing your template

??? "nginx.tmpl template"

    ```
    --8<-- "samples/nginx.tmpl"
    ```

And create the config map

```
$ kubectl create -n ab cm nginx-tmpl --from-file nginx.tmpl
```

And use it when deploying the chart

```
$ helm install  --name citm-ab --namespace ab citm-ingress --set controller.customTemplate.configMapName=nginx-tmpl,controller.customTemplate.configMapKey=nginx.tmpl
```

### custom-lua
This allow you to separate lua library from snippet code using it.

Complete example:

- a config map description (`helloworldlua.yaml`) containing code of your lua module library
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: helloworldlua
data:
  helloworldlua.lua: |+
    hw = {}
    function hw.sayHello()
      ngx.say('Hello, world kiki!')
    end
    return hw
```

- An ingress resource (`ingress.yaml`) making reference to this lua library and using it. In the example, a tomcat server
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: | 
      access_by_lua_block {
        local hw = require "helloworldlua"
        hw.sayHello()
      }
spec:
  rules:
  - http:
      paths:
      - path: /tomcat
        backend:
          serviceName: tomcat
          servicePort: 8080
...
```
- The `input.yaml` to be provided for loading this module in nginx
```
controller:
  customLuaModules:
    enabled: true
    modules:
      - moduleName: helloworldlua
        sourcesConfigMapName: helloworldlua
```
- Deploy the all things
```
$ kubectl -n ab create -f helloworldlua.yaml
$ kubectl -n ab create -f ingress.yaml
$ helm install --name citm-ab --namespace ab citm-ingress -f input.yaml
```
- Test it
```
$ kubectl -n ab get pods,svc,ing,cm -o wide
NAME                                            READY   STATUS      RESTARTS   AGE    IP                NODE                                     NOMINATED NODE   READINESS GATES
pod/citm-ab-citm-ingress-controller-74ndk       1/1     Running     0          16m    172.30.253.7      bcmt-sandbox1-3c7w2e-2003-s1-edge-01     <none>           <none>
pod/citm-ab-citm-ingress-controller-w9ms2       1/1     Running     0          16m    172.30.253.6      bcmt-sandbox1-3c7w2e-2003-s1-edge-02     <none>           <none>
pod/citm-ab-default404-5bc6dc7d99-94x28         1/1     Running     0          16m    192.168.133.93    bcmt-sandbox1-3c7w2e-2003-s1-worker-06   <none>           <none>
pod/tomcat-67ccb45b47-vrhfg                     1/1     Running     0          50m    192.168.133.120   bcmt-sandbox1-3c7w2e-2003-s1-worker-06   <none>           <none>

NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE    SELECTOR
service/citm-ab-citm-ingress-controller   ClusterIP   None             <none>        8089/TCP,8087/TCP   17m    app=citm-ingress,component=controller,release=citm-ab
service/citm-ab-default404                ClusterIP   10.254.63.95     <none>        8080/TCP            17m    app=default404,component=default404,release=citm-ab
service/tomcat                            ClusterIP   10.254.194.217   <none>        8080/TCP            50m    k8s-app=tomcat

NAME                                HOSTS   ADDRESS                      PORTS   AGE
ingress.extensions/webapp-ingress   *       10.76.184.122,10.76.184.73   80      50m

NAME                                        DATA   AGE
configmap/citm-ab-citm-ingress-controller   16     17m
configmap/citm-ab-citm-ingress-tcp          0      17m
configmap/citm-ab-citm-ingress-udp          0      17m
configmap/helloworldlua                     1      17m
configmap/ingress-controller-leader-nginx   0      17m
```

```
$ curl -k https://172.30.253.7:8087/tomcat
Hello, world kiki!
```

### extraargs
You can add any of supported [arguments](docker-ingress-cli-arguments.md) using controller.extraArgs

Example, to activate log debug in ingress controller (-v argument)

```
$ helm install citm-ingress --set controller.extraArgs.v=6
```

## Test
Steps to run a test suite on a release
```
$ helm test citm-ab --cleanup
RUNNING: citm-ab-controller-test-connection-d57mba
PASSED: citm-ab-controller-test-connection-d57mba
RUNNING: citm-ab-test-healthz-404-i7n6sa
PASSED: citm-ab-test-healthz-404-i7n6sa
```
## CITM ingress controller - kubernetes internal

See a [detailed description](ingress-controller-internal.md) of the internal workings of CITM ingress controller
