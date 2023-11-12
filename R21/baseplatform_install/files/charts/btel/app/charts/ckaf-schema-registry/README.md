# Schema-Registry Helm Chart
This helm chart creates a [Confluent Schema-Registry server](https://github.com/confluentinc/schema-registry).

## Prerequisites
* Dependent on Kafka and Zookeeper

## Chart Components
This chart will do the following:

* Create a Schema-Registry deployment
* Create a Service configured to connect to the available Schema-Registry pods on the configured
  client port.

Note: Distributed Schema Registry Master Election is done via Kafka and Zookeeper Coordinator Master Election
https://docs.confluent.io/current/schema-registry/docs/design.html#kafka-coordinator-master-election

## Installing the Chart
You can install the chart with the release name `mysr` as below.

```console
$ helm install --name my-schema ckaf-schema-registry
```

If you do not specify a name, helm will select a name for you.

### Installed Components
You can use `kubectl get` to view all of the installed components.

```console{%raw}
$ kubectl get all -l app=ckaf-schema-registry

NAME                                          DESIRED   CURRENT   AGE
statefulsets/my-schema-ckaf-schema-registry   1         1         8h

NAME                                  READY     STATUS    RESTARTS   AGE
po/my-schema-ckaf-schema-registry-0   2/2       Running   5          8h

NAME                                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)              AGE
svc/my-schema-ckaf-schema-registry            ClusterIP   10.254.85.17   <none>        8081/TCP,32000/TCP   8h
svc/my-schema-ckaf-schema-registry-headless   ClusterIP   None           <none>        8081/TCP,32000/TCP   8h


```

## Configuration
You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install --name my-release -f values.yaml ckaf-schema-registry
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Parameters

The following table lists the configurable parameters of the SchemaRegistry chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
## Number of Schema Registry Pods to Deploy
|replicaCount| Number of Schema Registry Pods to Deploy | 3 |

|preheal| To trigger pre-heal hook | 0 |
|postheal| To trigger post-heal hook | 0 |

|jobtimeout| Job time out for Scale Event | 60 |

## Image details
|SchemaRegistry.image.name| The `SchemaRegistry` image name in the repository | ckaf/schema-registry |
|SchemaRegistry.image.tag| The `SchemaRegistry` image tag  |
|SchemaRegistry.image.pullPolicy| Image Pull Policy | `IfNotPresent` |

|JmxExporter.image.name|  The `Cpro` image name in the repository | cpro/jmx-exporter |
|JmxExporter.image.tag| The `Cpro` image tag  |
|JmxExporter.image.pullPolicy| Image Pull Policy | `IfNotPresent` |

|KubectlTool.image.name|  The `Tools` image name in the repository | tools/kubectl |
|KubectlTool.image.tag| The `Tools` image tag  |
|KubectlTool.image.pullPolicy| Image Pull Policy | `IfNotPresent` |

|SchemaRegistryTest.image.name| The `schema-registrytest` image name in the repository |
|SchemaRegistryTest.image.tag| The `schema-registrytest` image tag  |
|SchemaRegistryTest.image.pullPolicy| Image Pull Policy | `IfNotPresent` |

|configurationOverrides| `SchemaRegistry` [configuration setting](https://github.com/confluentinc/schema-registry/blob/master/docs/config.rst#configuration-options) overrides in the dictionary format `setting.name: value` | `{}` |

|resources| CPU/Memory resource requests/limits | `{}` |

|servicePort| The port on which the SchemaRegistry server will be exposed. | `8081` |


##BootStrapServers or ZookeeperUrl must be provided for Master Election.
|kafka.BootStrapServers| Kafka Bootstrap servers connection url with all brokers(comma seperated)  | SECURITY_PROTOCOL://broker1:9092,SECURITY_PROTOCOL://broker2:9092
|kafka.ZookeeperUrl| Zookeeper server connection url | <zookeeper service>:2181

##Security
#krbConf value: cat ./krb5.conf | base64 | tr -d '\n'
#sudo kubectl create secret generic <secret-name> --from-literal=krbPrincipalKey=<krbPrincipalKey> --from-literal=krbPasswordKey=<krbPasswordKey>
|sasl.krb.enabled|  whether krb is enabled | `false` |
|sasl.krb.krbSecretName| user to put according to configured Kubernetes secret name |
|sasl.krb.krbPrincipalKey| user to fill krbPrincipalKey |
|sasl.krb.krbPasswordKey| user to fill krbPasswordKey |
|sasl.krb.krbRealm| user to fill krbRealm | 

##K8s Secret doc: https://kubernetes.io/docs/concepts/configuration/secret/
###K8s Secret name defined by user. A single secret object has to be created which conatins 5 secret keys
###out of which 2 keys are created for certificate files (Keystore and Trustore) and 3 keys are created
###for SSL certificates peasswords (Keystore, Keystore key and Truststore password).
###Example K8s secret command:
###kubectl create secret generic <secret-name> --from-literal=keypass=<passwd>--from-literal=kstpass=<passwd> --from-literal=storepass=<passwd>--from-file=<certificatepath>/ca.truststore --from-file=<certificatepath>/kube1.keystore
|sr_ssl.enabled| whether schema registry SSL is enabled | `false` |
|sr_ssl.secret_name| user to put according to configured Kubernetes secret name |
|sr_ssl.keystore_key| user to fill for schema registry | 
|sr_ssl.truststore_key| user to fill for schema registry |
|sr_ssl.truststore_passwd_key| user to fill for schema registry |
|sr_ssl.keystore_passwd_key| user to fill for schema registry |
|sr_ssl.keystore_key_passwd_key| user to fill for schema registry

|kafkastore_ssl.enabled| whether Kafkastore SSL is enabled | `false` |
|kafkastore_ssl.secret_name|  user to put according to configured Kubernetes secret name |
|kafkastore_ssl.keystore_key| user to fill for schema registry |
|kafkastore_ssl.truststore_key| user to fill for schema registry |
|kafkastore_ssl.truststore_passwd_key| user to fill for schema registry |
|kafkastore_ssl.keystore_passwd_key| user to fill for schema registry |
|kafkastore_ssl.keystore_key_passwd_key | user to fill for schema registry |


|Security.runAsUser| User ID with which the process will run within the pod | 999 |
|Security.fsGroup| User group for schema registry | 998 |

|ingress.enabled| whether schema registry ingress is enabled | `false` |
|ingress.annotations| Ingress annotations key: values |
|ingress.hostname|
|ingress.path| Ingress path | /sr/ |

###Liveness and readiness Probe
ss -lntu | grep 8081 | grep -q  LISTEN
Configured liveness and readiness probe with listening socket connection information with respect to port
