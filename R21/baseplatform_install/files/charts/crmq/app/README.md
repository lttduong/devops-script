|          Parameter                    |                       Description                       |                         Default                          |
|---------------------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `global.registry`                     | Registry includes both rabbitmq image and kubectl image | `csf-docker-delivered.repo.lab.pl.alcatel-lucent.com`    |
| `image.repository`                    | Rabbitmq Image name                                     | see values.yaml                                          |
| `image.tag`                           | Rabbitmq Image tag                                      | `{VERSION}`                                              |
| `image.pullPolicy`                    | Image pull policy                                       | `Always` if `imageTag` is `latest`, else `IfNotPresent`  |
| `image.pullSecrets`                   | Specify docker-ragistry secret names as an array        | `nil`                                                    |
| `image.debug`                         | Specify if debug values should be set                   | `false`                                                  |
| `rbac.enabled`                        | Specify if rbac is enabled in your cluster              | `true`                                                   |
| `rbac.serviceAccountName`             | Specify default SA if rbac.enable false                 | `default`                                                |
| `rbac.serviceAccountNamePostDel`      | Specify post delete SA if rbac.enable false             | `default`                                                |
| `rbac.serviceAccountNameScale`        | Specify scaling SA if rbac.enable false & pvc enable    | `default`                                                |
| `rbac.serviceAccountNameAdminForgetnode`| Specify admin SA if rbac.enable false & pvc disable   | `default`                                                |
| `rbac.test.enabled`                   | Enable or disable helm test when rbac.enabled is false  | `true`                                                   |
| `rbac.test.serviceAccountNameHelmTest`  | Specify default SA if rbac.enable false & want to use helm test | `default`                                      |
| `rbac.test.helmTestSecret`            | Specify tls secret if rbac.enable false & want to use helm test | `default`                                        |
| `istio.enabled`                        | Specify if deploy on istio                              | `false`                                                  |
| `istioIngress.enabled`                | Whether enable istio ingress gateway                    | `false`                                                  |
| `istioIngress.host`                   | The host used to access istio ingress                   | ``                                                       |
| `istioIngress.selector`               | The selector of istio ingress gateway                   | `{istio: ingressgateway}`                                |
| `tmpForceRecreateResources`           | Force to recreate the resource created when install     | `false`                                                  |
| `rabbitmq.dynamicConfig.enable`       | Enable to run command after deploy                      | `false`                                                  |
| `rabbitmq.dynamicConfig.timeout`      | Seconds to wait for pod ready in post-install job       | `300`                                                    |
| `rabbitmq.dynamicConfig.maxCommandRetries`| Number of times to retry a command before failing the job | `10`                                               |
| `rabbitmq.dynamicConfig.parameters`   | Rabbitmq commands to run after chart deployed           |  see values.yaml                                         |
| `rabbitmq.username`                   | RabbitMQ application username                           | `user`                                                   |
| `rabbitmq.password`                   | RabbitMQ application password                           | _random 10 character long alphanumeric string_           |
| `rabbitmq.erlangCookie`               | Erlang cookie                                           | _random 32 character long alphanumeric string_           |
| `rabbitmq.amqpSvc`                    | To expose the amqp port                                 | `true`                                                   |
| `rabbitmq.amqpPort`                   | amqp port                                               | `5672`                                                   |
| `rabbitmq.nodePort`                   | amqp node port                                          | `30010`                                                  |
| `rabbitmq.rabbitmqClusterNodeName`    | Specify rabbitmq cluster name                           | none                                                     |
| `rabbitmq.diskFreeLimit`              | Specify rabbitmq disk free limit                        | `6GiB`                                                   |
| `rabbitmq.plugins`                    | configuration file for plugins to enable                | `[rabbitmq_management,rabbitmq_peer_discovery_k8s].`     |
| `rabbitmq.configuration`              | rabbitmq.conf content                                   | see values.yaml                                          |
| `rabbitmq.advancedConfig`             | advanced.config content                                 | none                                                     |
| `rabbitmq.environment`                | rabbitmq-env.conf content                               | see values.yaml                                          |
| `rabbitmq.mqtt.enabled`               | whether to enable mqtt plugin                           | `false`                                                  |
| `rabbitmq.mqtt.vhost`                 | vhost for mqtt plugin                                   | `\`                                                      |
| `rabbitmq.mqtt.exchange`              | exchagne of vhost for mqtt plugin                       | `amq.topic`                                              |
| `rabbitmq.mqtt.DefaultTcpPort`        | default tcp port for mqtt plugin                        | `1883`                                                   |
| `rabbitmq.mqtt.tcpNodePort`           | tcp nodePort for mqtt plugin                            | ``                                                       |
| `rabbitmq.mqtt.enabledSsl`            | whether to enable SSL port for mqtt                     | `false`                                                  |
| `rabbitmq.mqtt.DefaultSslPort`        | default SSL port for mqtt                               | `8883`                                                   |
| `rabbitmq.mqtt.sslNodePort`           | ssl nodePort for mqtt plugin                            | ``                                                       |
| `rabbitmq.clustering.address_type`    | the node address type of RabbitMQ                       | `default`                                                |
| `rabbitmq.clustering.k8s_domain`      | the k8s_domain                                          | `cluster.local`                                          |
| `rabbitmq.tls.cacert`                 | broker tls cacert file content                          | none                                                     |
| `rabbitmq.tls.cert`                   | broker tls cert file content                            | none                                                     |
| `rabbitmq.tls.key`                    | broker tls key file content                             | none                                                     |
| `rabbitmq.tls.verify_option`          | whether peer verification is enabled                    | `verify_peer`                                            |
| `rabbitmq.tls.fail_if_no_peer_cert`   | whether to accept clients which have no certificate     | `false`                                                  |
| `rabbitmq.tls.ssl_port`               | RabbitMQ broker tls port                                | `5671`                                                   |
| `rabbitmq.tls.nodePort`               | RabbitMQ broker tls nodePort                            | ``                                                       |
| `rabbitmq.tls.certmanager.used`       | generate cacert cert key with cert-manager              | `false`                                                  |
| `rabbitmq.tls.certmanager.dnsNames`   | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `rabbitmq.tls.certmanager.duration`   | cert_m Certificate default Duration                     | `8760h`                                                  |  
| `rabbitmq.tls.certmanager.renewBefore`| cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `rabbitmq.tls.certmanager.issuerName` | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `rabbitmq.tls.certmanager.issuerType` | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `rabbitmq.management.enabled`         | Enable management plugin                                | `true`                                                   |
| `rabbitmq.management.cacert`          | management plugin tls cacert file content               | none                                                     |
| `rabbitmq.management.cert`            | management plugin tls cert file content                 | none                                                     |
| `rabbitmq.management.key`             | management plugin tls key file content                  | none                                                     |
| `rabbitmq.management.port`            | RabbitMQ Manager port                                   | `15672`                                                  |
| `rabbitmq.management.nodePort`        | RabbitMQ Manager node port                              | `30110`                                                  |
| `rabbitmq.management.certmanager.used`| generate cacert cert key with cert-manager              | `false`                                                  |
| `rabbitmq.management.certmanager.dnsNames`    | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `rabbitmq.management.certmanager.duration`    |  cert_m Certificate default Duration                    | `8760h`                                                  |  
| `rabbitmq.management.certmanager.renewBefore` | cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `rabbitmq.management.certmanager.issuerName`  | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `rabbitmq.management.certmanager.issuerType`  | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `rabbitmq.backuprestore.enabled`      | whether enable backup/restore                           | `false`                                                  |
| `rabbitmq.backuprestore.backendMode`  | The backendMode field of BrPolicy                       | `local`                                                  |
| `rabbitmq.backuprestore.cronJob`      | The cronJob field of BrPolicy                           | `*/10 * * * *`                                           |
| `rabbitmq.backuprestore.brOption`     | The brOption field of BrPolicy                          | `0`                                                      |
| `rabbitmq.backuprestore.maxCopy`      | The maxCopy field of BrPolicy                           | `5`                                                      |
| `rabbitmq.backuprestore.agent.imageRepo`| the image repo of cbur sidecar                        | `cbur/cbura`                                             |
| `rabbitmq.backuprestore.agent.imageTag`| the image tag of cbur sidecar                          | `1.0.3-983`                                              |
| `rabbitmq.backuprestore.agent.imagePullPolicy`| cbur sidecar image pull policy                  | `IfNotPresent`                                           |
| `rabbitmq.rsyslog.enabled`            | whether to enable rsyslog (deprecated, use clog instead)| `false`                                                  |
| `rabbitmq.rsyslog.repository`         | rsyslog docker image repository                         | see values.yaml                                          |
| `rabbitmq.rsyslog.tag`                | rsyslog docker image tag                                | `latest`                                                 |
| `rabbitmq.rsyslog.imagePullPolicy`    | rsyslog docker image pullPolicy                         | `IfNotPresent`                                           |
| `rabbitmq.rsyslog.level`              | rsyslog level                                           | `debug`                                                  |
| `rabbitmq.rsyslog.transport`          | rsyslog transport                                       | `udp`                                                    |
| `rabbitmq.thirdPartyPlugin`           | third party plugin list                                 | none                                                     |
| `rabbitmq.clog.bcmt.enabled`          | whether to enable CLOG sidecar                          | `false`                                                  |
| `rabbitmq.clog.syslog.port`           | CLOG rsyslog port                                       | `2514`                                                   |
| `rabbitmq.clog.syslog.format`         | CLOG rsyslog format: rfc3164|rfc5424                    | `5424`                                                   |
| `rabbitmq.clog.syslog.level`          | CLOG rsyslog level                                      | `debug`                                                  |
| `rabbitmq.clog.syslog.transport`      | CLOG rsyslog transport                                  | `udp`                                                    |
| `rabbitmq.console.enabled`            | Log into console                                        | `true`                                                   |
| `rabbitmq.console.level`              | Log level                                               | `info`                                                   |
| `rabbitmq.prometheus.enabled`         | To enable prometheus plugib                             | `false`                                                  |
| `rabbitmq.prometheus.port`            | TCP port prometheus plugin is listening to              | `15692`                                                  |
| `tlsClient`                           | tls file list need to be mounted                        | none                                                     |
| `serviceType`                         | Kubernetes Service type                                 | `ClusterIP`                                              |
| `persistence.reservePvc`              | reserve persistence storage after pod deleted           | `false`                                                  |
| `persistence.reservePvcForScalein`    | reserve persistence storage after pod scale-in          | `false`                                                  |
| `persistence.data.enabled`            | enable persistence storage for data                     | `true`                                                   |
| `persistence.data.storageClass`       | storage class for pvc                                   | none                                                     |
| `persistence.data.accessMode`         | Persistent Volume Access Mode for data                  | `ReadWriteOnce`                                          |
| `persistence.data.size`               | Persistent Volume Size for data                         | `8GiB`                                                   |
| `persistence.log.enabled`             | enable persistence storage for log                      | `false`                                                  |
| `persistence.log.storageClass`        | storage class for pvc                                   | none                                                     |
| `persistence.log.accessMode`          | Persistent Volume Access Mode for log                   | `ReadWriteOnce`                                          |
| `persistence.log.size`                | Persistent Volume Size for log                          | `8GiB`                                                   |
| `resources`                           | resource needs and limits to apply to the pod           | {}                                                       |
| `replicas`                            | Replica count                                           | `3`                                                      |
| `nodeSelector`                        | Node labels for pod assignment                          | {}                                                       |
| `affinity`                            | Affinity settings for pod assignment                    | {}                                                       |
| `tolerations`                         | Toleration labels for pod assignment                    | []                                                       |
| `podAnnotations`                      | pod annotation                                          | {}                                                       |
| `svcAnnotations`                      | svc annotation                                          | {}                                                       |
| `ingress.enabled`                     | enable ingress for management console                   | `false`                                                  |
| `ingress.hostName`                    | host name of ingress                                    | `crmq-gui.paas2.compaas.vlab.pl.alcatel-lucent.com`      |
| `ingress.use_cert_manager`            | generated cacert cert key for ingress tls               | `false`                                                  |
| `ingress.dnsNames`                    | specify dnsNames for cert-manager generation keys       | `- ""`                                                   |  
| `ingress.duration`                    |  cert_m Certificate default Duration                    | `8760h`                                                  |  
| `ingress.renewBefore`                 | cert_m Certificate renew before expiration duration     | `360h`                                                   |  
| `ingress.issuerName`                  | to change the issuerRef for cert manager                | `ncms-ca-issuer`                                         |  
| `ingress.issuerType`                  | to change the issuerType (Kind) for cert manager        | `ClusterIssuer`                                          |  
| `livenessProbe.enabled`               | would you like a livessProbed to be enabled             | `true`                                                   |
| `livenessProbe.initialDelaySeconds`   | number of seconds                                       | 120                                                      |
| `livenessProbe.timeoutSeconds`        | number of seconds                                       | 5                                                        |
| `livenessProbe.failureThreshold`      | number of failures                                      | 6                                                        |
| `readinessProbe.enabled`              | would you like a readinessProbe to be enabled           | `true`                                                   |
| `readinessProbe.initialDelaySeconds`  | number of seconds                                       | 10                                                       |
| `readinessProbe.timeoutSeconds`       | number of seconds                                       | 3                                                        |
| `readinessProbe.periodSeconds`        | number of seconds                                       | 5                                                        |
| `lcm.scale_hooks`                     | lcm scale hook                                          | `noupgradehooks`                                         |
| `lcm.scale_timeout`                   | lcm scale timeout                                       | `120`                                                    |
| `postDeleteForceClean.enabled`        | True to force disabling ressources during post-delete   | `false`                                                  | 


## rsyslog / CLOG

According to CSF policy, CLOG sidecar should be used to send the CRMQ log on a BCMT cluster.

rabbitmq.rsyslog.enabled is so deprecated.

To be able to use CLOG sidecar, you must deploy CLOG as explained in the CLOG User Guide https://confluence.app.alcatel-lucent.com/display/plateng/CLOG+Sidecar+Auto+Injection+k8s-sidecar-injector

At a glance:
    - Create the TLS certificate as mentioned (default values can be used for testing)
    - Deploy the CLOG pod (helm install --name clogsidecar csf-stable/clog-sidecar --version=2.0.7 -f ./values.yaml)

Then, you can deploy CRMQ using --set rabbitmq.clog.bcmt.enabled=true

## Rbac enable false
If you chose to use you own resource you need to know that if you want to specify only one serviceAccount you can set only serviceAccountName and all other normaly needed serviceaccount will be set with the same service account.
You can check the documentation for more information : https://csf.gitlabe2-pages.ext.net.nokia.com/mp/crmq/guide/external_rbac.html 

rbac:
  enabled: false
  serviceAccountName: mysa
  serviceAccountNamePostDel :
  serviceAccountNameScale :
  serviceAccountNameAdminForgetnode :
  test:
    enabled: true
    serviceAccountNameHelmTest:

## Prefix & Suffix
If you want to change prefix and suffix you can fill theses values.
podNamePrefix & containerNamePrefix need to be under global.

global:

  podNamePrefix: prefixpod-
  containerNamePrefix: prefixcontainer-

postDeleteJobName: deljob
postDeleteContainerName: delcont
postInstallJobName: instjob
postInstallContainerName: instalcont
postUpgradeJobName: upgjob
postUpgradeContainerName: upgcon
postScaleinJobName: scajob
postScaleinContainerName: scajob



