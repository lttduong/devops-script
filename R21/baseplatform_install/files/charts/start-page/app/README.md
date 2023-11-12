# Install from charts

This chart bootstraps a citm-server deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release citm-server
```

The command deploys nginx-server on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the citm-server chart and their default values.

Parameter | Description | Default
--- | --- | ---
registry | controller container image repository| csf-docker-delivered.repo.lab.pl.alcatel-lucent.com 
httpServer.name | name of the httpServer component | citm-server
httpServer.imageRepo | server image repository name | citm/citm-nginx-server
httpServer.imageTag | server container image tag | 1.18.0-2.1
httpServer.imagePullPolicy | server container image pull policy | IfNotPresent
[httpServer.webapp.url](#webapp)| Your html in tar.gz (the tar.gz will be directly untar inside the container) | None
[httpServer.webapp.proxy](#webapp)|if you need a proxy| ""
[httpServer.filesPath.webapp](#webapp)|you can also specify where the html had to be mount in the container|/usr/share/nginx/html/
[httpServer.conf.url](#conf-url)|You can specify an url to download it from an external server.| ""
[httpServer.conf.url](#webapp)| You can specify an url to download your nginx.conf | ""
[httpServer.configurationConfigMap](#webapp)|config map to be used for your server block. Format is namespace/config map name| ""
|[httpServer.watch.config](#watchconfig)|boolean|false|Set this to true if you want to watch nginx.conf file change and reload dynamicaly 	 |
|[httpServer.watch.timer](#watchconfig)|int|2|Time in second between to check |
[httpServer.expose](#ingress)|ingress paths and ports to be exposed by an ingress controller | ""
[httpServer.overrideIngress](#ingress)|specify this if you want to overwrite ingress rules assocaited with your webserver | ""
[httpServer.filesPath.conf](#webapp)|you can specify where the html had to be mount in the container | /usr/share/nginx/conf
[httpServer.defaultSecret](#secret)|you can specify a secret to be used as certificate for https connection. If not provided, a default self signed certificate will be used | ""
[httpServer.modsecurity.enabled](#modsecurity)|Set this to true if you want to enable modsecurity (WAF) | false
[httpServer.modsecurity.owaspCrs](#modsecurity)|Set this to true if you want to enable OWASP modsecurity Core Rule Set | false
httpServer.livenessProbePath| liveness path to be checked | /
httpServer.readinessProbePath| readyness path to be checked | /
httpServer.livenessScheme | schema to be used for liveness request | HTTP
httpServer.readinessScheme | schema to be used for readyness request | HTTP
httpServer.livenessInitialDelaySeconds | Initial delay (in second) to be used for liveness request | 10
httpServer.readinessInitialDelaySeconds | Initial delay (in second) to be used for readyness request | 10
httpServer.livenessTimeoutSeconds | timeout for liveness request | 1
httpServer.readinessTimeoutSeconds | timeout for readyness request | 1
[certManager.used](#cert-manager) | Use cert-manager service for generating default certificate | false
[certManager.duration](#cert-manager) | Duration of the generated certificate |   8760h # 365d
[certManager.renewBefore](#cert-manager) | Time before expiration for renewing the certificate | 360h # 15d
[certManager.keySize](#cert-manager) | certificate key size | 2048
[certManager.servername](#cert-manager) | your server name (FQDN) |
[certManager.dnsNames](#cert-manager) | List of dns names to be associated with this certificate | Empty by default. Will also use value provided in security.servername
[certManager.ipAddresses](#cert-manager) | List of server ipAddresses |
[certManager.issuerRef.name](#cert-manager)      | Issuer name to be used by cert-manager                     |   ncms-ca-issuer                                   |
[certManager.issuerRef.kind](#cert-manager)      | Issuer kind to be used by cert-manager                     | ClusterIssuer                                     |
[rbac.enabled](#rbac) | If true, create & use RBAC resources for http server | true
[rbac.serviceAccountName](#rbac) | ServiceAccount to be used (ignored if rbac.enabled=true) | default
json_log | to format log in json format. Set this to false of you do not want json formatting | true
metrics|set this to true if you do not want internal monitoring console. See https://confluence.app.alcatel-lucent.com/display/plateng/CITM+-+NGINX+Guide#CITM-NGINXGuide-Monitoringdisplay | false
docker_debug | Set this to true of you want debug log level for nginx | false
[grafanaSecret](#grafana) | Name of the secret that contains the grafana credentials | {}
[grafanaURL](#grafana) |  URL and port of the grafana server, without 'http:// | {}

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install citm-server --name my-release -f my-values.yaml
```

## Run examples

### webapp
You need to add your webapp, and your own nginx.conf

For nginx.conf, there is two ways to provide it. 
* from an url [httpServer.conf.url](#from-url)
* or from a [config map](#from-configmap)

#### from-configmap
The configmap can by generated 
* by referencing the "servers" block in your values.yaml 
* or by providing your own config map, thanks to httpServer.configurationConfigMap

Here after a complete exemple with 2 servers, listening on 8080 and 8082 with multiple paths. 

Add a servers properties in your values.yaml
You can't use /opt/www anymore since the user change from root to nginx

```console
  servers:
   - server: server1
     port: 8080
     root: "/usr/share/nginx/html/"
     locations:
       - location: /
         index: index.html
         alias: /usr/share/nginx/html/
       - location: /50x.html
         index: 50x.html
         alias: /usr/share/nginx/html/
    - server: server2
      port: 8082
      root: "/usr/share/nginx/html"
      locations:
        - location: /
          index: index.html
          alias: /usr/share/nginx/html/
```

Or, create a configmap using following procedure. You may need to adapt the namespace (here, we've taken default)

```console
$ cat ws.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ws
  namespace: default
data:
  nginx.conf: |+
  # => here your nginx.conf ( you can take exemple of you configmap for the hardening part)
```
Declare it in kubernetes
```console
$ kubectl create -f ws.yaml
```

and use it 

```console
$ helm install csf-stable/citm-server --set httpServer.webapp.url="https://<url>/wabapp.tar.gz" --set httpServer.configurationConfigMap=default/ws
```

#### from-url

```console
$ helm install csf-stable/citm-server --set httpServer.webapp.url="http://<url>/wabapp.tar.gz" --set httpServer.conf.url="http://<url>/nginx.conf"
```

### watchconfig
If you provide your own nginx.conf (using a volume), you may want to reload it each time you make a modification. In this case, activate watchconfig. You can also provide a watch timer for delay between two checks (default is 2s)

```console
$ helm install csf-stable/citm-server --set httpServer.watch.config=true
```
with a check delay of 5s
```console
$ helm install csf-stable/citm-server --set httpServer.watch.config=true --set httpServer.watch.timer=5
```

### ingress
If you want to expose your servers thru the ingress controller, you can provide the expose properties.

It must be consistent with what is provided for generating nginx.conf, in term of path and port

Since the user in no more root you can't use ports under 1000

```console
expose:
  - port: 8080
    ingressPath: "server1"
  - port: 8082
    ingressPath: "server2"
```

You can also overwrite the default ingress description, by providing overrideIngress property

```console
overrideIngress: |
  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    name: basic-ingress
    annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  spec:
    rules:
    - host: server1
      http:
        paths:
        - backend:
            serviceName: ing-server1
            servicePort: 8080
          path: /(.*)
```

### secret
First you need to create a secret of type tls. Here-after a sample way to achieve this (using a self signed certificate). Refer to https://confluence.app.alcatel-lucent.com/display/plateng/CASF+-+HTTP+Server+Guide#CASF-HTTPServerGuide-DealingWithSSLDealingwithSSLandcertificate for official certificate.
```console
$ CERT_NAME=mysecret
$ KEY_FILE=/tmp/${CERT_NAME}.key
$ CERT_FILE=/tmp/${CERT_NAME}.crt
$ HOST=$(hostname -s)
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=Nokia"
$ kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
$ rm -f $KEY_FILE $CERT_FILE
```
Check
```console
$ kubectl get secret 
NAME                  TYPE                                  DATA   AGE
default-token-fgbjt   kubernetes.io/service-account-token   3      47h
mysecret              kubernetes.io/tls                     2      46h

$ kubectl describe secret mysecret 
Name:         mysecret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1139 bytes
tls.key:  1704 bytes
```
And tell citm-server to use it for https connection.
```console
$ helm install citm-server --set httpServer.defaultSecret=mysecret
```
NOTE: the tls secret and pod MUST be in the same namespace

### tls-paths
If you are using httpServer.defaultSecret to generated tls keys, they will be stored in /certificate. Don't forget to change your nginx.conf ssl_certificate to :
      | ssl_certificate /cerificate/tls.crt;
      | ssl_certificate_key /cerificate/tls.key;
If your not using httpServer.defaultSecret default keys are generated under /usr/share/nginx/ssl/tls.crt;
      | ssl_certificate /usr/share/nginx/ssl/tls.crt;
      | ssl_certificate_key /usr/share/nginx/html/tls.key;
filesPath.tls: "/usr/share/nginx/ssl" is the path where the default .key are generated

### cert-manager
citm-server supports cert-manager for certificate generation. 
```console
$ helm install citm-server --set certManager.used=true,certManager.servername=foo.bar.com
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
$ helm install --name citm-ab --namespace ab citm-server -f input.yaml
```
Content of generated secret
```
$ kubectl -n ab describe secrets tls-citm-ab-citm-server 
Name:         tls-citm-ab-citm-server
Namespace:    ab
Labels:       <none>
Annotations:  cert-manager.io/alt-names: *.foo.bar.com,foo.bar.com
              cert-manager.io/certificate-name: tls-citm-ab-citm-server
              cert-manager.io/common-name: foo.bar.com
              cert-manager.io/ip-sans: 127.0.0.1,127.0.0.2
              cert-manager.io/issuer-kind: ClusterIssuer
              cert-manager.io/issuer-name: ncms-ca-issuer
              cert-manager.io/uri-sans: 

Type:  kubernetes.io/tls

Data
====
ca.crt:   1257 bytes
tls.crt:  1302 bytes
tls.key:  1679 bytes
```

### rbac
By default, RBAC is enabled. If for any reason, you want to disable, set rbac.enabled to false
You can provide your own ServiceAccount (`rbac.serviceAccountName`, `). In that case, check [which ressources](rbac.md) are needed. 

### modsecurity
For activating modsecurity (WAF) and alsu sue OWASP Core rule set

```console
$ helm install citm-server --set httpServer.modsecurity.enabled=true,httpServer.modsecurity.owaspCrs=true
```

### extend-env
To set variables in the container environment
```console
$ helm install citm-server --set httpServer.extend.env.FOO="bar",httpServer.extend.env.BOB="42"
```

### grafana
grafana secret is built using grafana helm release and -cpro-grafana. 

grafanaURL is the url of grafana service, or IP of pod. Port 3000 is the port for importing dashboard

Refer to [CPRO user guide](https://confluence.app.alcatel-lucent.com/display/plateng/CPRO+-+Prometheus) for details

```console
$ helm install citm-server --set grafanaSecret=grafana-cpro-grafana,grafanaURL=192.168.2.54:3000
```
