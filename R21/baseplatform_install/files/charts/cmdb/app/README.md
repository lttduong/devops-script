# Helm Configuration Parameters

The CMDB helm chart provides the packaging to deploy a [MariaDB](https://mariadb.org) database instance in one of the supported deployment configurations (simplex, galera, master-slave).  MariaDB is developed as open source software and as a relational database it provides an SQL interface for accessing data.

There is a large set of configuration parameters that can be specified as input values when deploying or upgrading the CMDB Helm chart. Default and input values are passed in a YAML file, or can be passed via command-line \--set argument using the YAML object reference equivalent. The following values can be provided to override the defaults specified in the chart.

*Note: There are additional values defined in the chart values.yaml file, most of these are necessary for compliance to helm best practices. Do not change or re-set any values not specifically listed in the tables below.*

## ***Common, Cluster-level Parameters***

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#common_fn) |
|:----------|:------------|:----------------|:------------------------------------|
| global.registry | [csf-docker-delivered.repo.lab.pl.alcatel-lucent.com](http://csf-docker-delivered.repo.lab.pl.alcatel-lucent.com) | The registry URL used to pull CSF CMDB delivered container images | [Yes^1^](#"common_fn1") |
| global.registry1 | [registry1-docker-io.repo.lab.pl.alcatel-lucent.com](http://csf-docker-delivered.repo.lab.pl.alcatel-lucent.com) | The registry URL used to pull docker-io mirrored container images | [Yes^1^](#"common_fn1") |
| global.registry2 | [csf-docker-delivered.repo.lab.pl.alcatel-lucent.com](http://csf-docker-delivered.repo.lab.pl.alcatel-lucent.com/) | The registry URL used to pull CSF non-CMDB delivered container images (eg, CBUR, OSDB) | [Yes^1^](#"common_fn1") |
| global.istioVersion | 1.4 | ==NEW 7.11.2== The istio version installed on the platform being used to install CMDB in the istio environment. Only used if istio.enabled is true. | No |
| global.podNamePrefix | *(omitted)* | ==NEW 7.12.0== Prefix name to be prepended to every pod for both statefulsets pods and job pods. The prefix name will prepend the normal pod name which is made up of the release name and the pod name.  The pod prefix is *not* part of the relesae name and thus does not affect other created resources (eg, configmaps, services, etc.).  If it is desired to have a dash between the prefix and the release name which make up the normal pod name, then make sure you end the podNamePrefix with a dash. | No |
| global.containerNamePrefix | *(omitted)* | ==NEW 7.12.0== Container name to be prepended to every created container for both statefulset pod containers and job pod containers. If it is desired to have a dash between the prefix and the conatiner name, then make sure you end the containerNamePrefix with a dash. | No |
| rbac\_enabled | true | Specifies whether Role-Based Access Control (RBAC) is enabled in the underlying kubernetes enironment. | No |
| serviceAccountName | *(omitted)* | ==NEW 7.10.2== Service Account to use instead of a generated one (Also disables generation of Roles/Rolebindings). See [RBAC Rules](./oam_rbac_rules.md) | No |
| istio.enabled | false | ==NEW 7.9.1== Indicates if the deployment is being peformed in an istio-enabled namespace.  Also make sure that global.istioVersion is set appropriately for the base kubernetes platform.  | No |
| clusterDomain | cluster.local | ==NEW 7.10.2== Cluster domain used in raw k8s installs | No |
| cluster\_name | <Chart Release\> | Passed into the CMDB containers as CLUSTER\_NAME (See [Docker Configuration](./oam_configure_docker.md)) | No |
| cluster\_type | galera | Passed into the CMDB containers as CLUSTER\_TYPE (See [Docker Configuration](./oam_configure_docker.md)).  ==NEW IN 7.13.0== This value can now be changed during helm upgrade to perform a topology morph (see [Update Allowed^2^](#"common_fn2")). | [Yes^2^](#"common_fn2") |
| max\_node\_wait | 15 | Time (in minutes) maximum to wait for all pods to come up. Passed into the CMDB containers as MAX\_NODE\_WAIT (See [Docker Configuration](./oam_configure_docker.md)). | Yes |
| quorum\_node\_wait | 120 | ==NEW 7.6.0== Time (in seconds) maximum to wait for additional pods to come up after a quorum (50% + 1) is reached before continuing. Passed into the CMDB containers as QUORUM\_NODE\_WAIT (See [Docker Configuration](./oam_configure_docker.md)). | Yes |
| nodeAntiAffinity | hard | Specifies the type of anti-affinity for scheduling pods to nodes *(hard\|soft)* | No |
| displayPasswords | if-generated | Specifies if passwords shoudl be displayed by the helm NOTES, which are displayed when helm install completes.  Options are never, if-generated, always | No |

<a name="common_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  
<a name="common_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**  
<a name="common_fn2"></a>^2^ - Updating this value triggers a topology morph action.  See [Helm Topology Upgrade](./oam_management_lcm_events_helm.md#helm_topology_upgrade) section for discussion on changing this value.  

## **CMDB Services Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#cmdb_fn) |
|:----------|:------------|:----------------|:----------------------------------|
| services.mysql.name | <Chart Release\>-mysql | The name of the Kubernetes Service where Mysql clients can access the database | No |
| services.mysql.type | ClusterIP | Either ClusterIP or NodePort - depending on if the DB should be accessible only within the cluster or exposed externally, respectively | No |
| services.mysql.nodePort<br>services.mysql.nodePort\_readonly<br>services.mysql.nodePort\_mstronly | *(omitted)<br>(omitted)<br>(omitted)* | If service.mysql.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. The following nodePort can be assigned:<br>nodePort - nodePort for base mysql service (or maxscale rwSplit service)<br>nodePort\_readonly - nodePort for maxscale readOnly service<br>nodePort\_mstronly - nodePort for maxscale masterOnly service | No |
| services.mysql.sessionAffinity.enabled<br>services.mysql.sessionAffinity.timeout | false<br>*(omitted)* | ==NEW 7.10.1== Enable mysql service session affinity to ClientIP to ensure that connections from a particular client are passed to the same Pod each time.  A session affinity timeout value (in seconds) can also be provided (defaults to 10800 by kubernetes).| Yes |
| services.mysql.exporter\_port | 9104 | If mariadb.metrics.enabled is set to true, this port can be configured to define the port which mysqld\_exporter will listen to for metrics collection. | Yes |
| services.mariadb\_master.name | <Chart Release\>-mariadb-master | The name of the Kubernetes Service pointing to the Master Pod. *(Only relevant in Master-Slave clusters with MaxScale)* | No |
| services.mariadb\_master.type | NodePort | NodePort - should not be changed. *(Only relevant in Master-Slave clusters with MaxScale)* | No |
| services.mariadb\_master.nodePort | *(omitted)* | Can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. | No |
| services.maxscale.name | <Chart Release\>-maxscale | The name of the Kubernetes Service pointing to the leader MaxScale Pod. *(Only relevant in Master-Slave clusters with MaxScale)* | No |
| services.maxscale.type | ClusterIP | Either ClusterIP or NodePort - depending on if the maxctrl interface should be accessible only within the cluster or exposed externally, respectively. *(Only relevant in Master-Slave clusters with MaxScale)*<br>**NOTE: Will be automatically set to NodePort when geo\_redundancy.enabled is true.** | No |
| services.maxscale.port | 8989 | The port for the Kubernetes maxctrl Service. *(Only relevant in clusters with MaxScale and if services.maxscale.enabled is true)* | No |
| services.maxscale.nodePort | *(omitted)* | If service.maxscale.type is set to NodePort, you can optionally set a specific nodePort to use instead of having on assigned by kubernetes. If not specified, then kubernetes will assign a random port from the nodePort range. | No |
| services.maxscale.exporter\_port | 9195 | If maxscale.metrics.enabled is set to true, this port can be configured to define the port which maxscale\_exporter will listen to for metrics collection. | Yes |
| services.admin.name | <Chart Release\>-admin | The name of the Kubernetes Service pointing to the Admin Pod. *(Not relevent in simplex deployments).* | No |
| services.admin.type | ClusterIP | Either ClusterIP or NodePort - depending on if the Admin container should be accessible only within the cluster or exposed externally, respectively. Should not need to change this from ClusterIP. *(Not relevant in simplex deployments).* | No |

<a name="cmdb_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  

## **MariaDB Database Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#mariadb_fn) |
|:----------|:------------|:----------------|:-------------------------------------|
| mariadb.image.registry | <global.registry\> | The registry (global.registry override) to use for pulling the MariaDB container image. | [Yes^1^](#mariadb_fn1) |
| mariadb.image.name | cmdb/mariadb | The docker image to use for the MariaDB containers | [Yes^1^](#mariadb_fn1) |
| mariadb.image.tag | <Version\> | The docker image tag to use for the MariaDB containers | [Yes^1^](#mariadb_fn1) |
| mariadb.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#mariadb_fn1) |
| mariadb.count | 3 | The number of MariaDB pods to create, depends on cluster\_type (See [Docker Configuration](./oam_configure_docker.md)) | [Yes^1,2^](#mariadb_fn1) |
| mariadb.heuristic\_recover | rollback (non-simplex)<br>none (simplex) | Indicates the type of tc-heurisic-recover that should take place automatically on pod restarts. Valid values are rollback (default), commit, and none (disable automatic heuristic recovery).<br>Defaults to rollback for non-simplex deployments, defaults to none for simplex deployments. | Yes |
| mariadb.clean\_log\_interval | 3600 | Defines the interval (in seconds) that the Master of a replication cluster will clean-up old binlog files. | Yes |
| mariadb.audit\_logging.enabled | true | Boolean. Indicates if server audit logging should be enabled by default. | Yes |
| mariadb.audit\_logging.events | CONNECT,QUERY\_DCL,QUERY\_DDL | Indicates the server events that will be logged if audit\_logging is enabled. See [MariaDB Audit Plugin - Log Settings](https://mariadb.com/kb/en/library/mariadb-audit-plugin-log-settings/) for details on logging events that can be set. | Yes |
| mariadb.use\_tls | false | Boolean. Indicates if TLS/SSL is to be configured to encrypt data in flight to clients. Setting this to true will automatically add the ssl\_cipher TLSv1.2 to mariadb configuration and will automatically add REQUIRE SSL to all user grants.  The *mariadb.repl\_use\_ssl* is used to enable/disable SSL for replicatoin traffic. | No |
| mariadb.repl\_use\_ssl | false | Set to true to require that all internal replication traffic be encrypted.  Use of this parameter requires that mariadb.use\_tls also be set.  For Replication configuration, all mysql replication traffic between servers will be encrypted.  ==NEW 7.11.0== For Galera configuration, all SST/IST replication traffic will be encrypted. | No |
| mariadb.certificates.secret | *(omitted)* | ==CHANGED 7.7.0== Three interfaces are supportted as specified by the certificates.secret value, which must be one of these values:<br>1. none (or empty) = No certificates<br>2. cmgr = Automatically generated certificates<br>3. <secret\> = Manually supplied certificates. This is the name of the kubernetes <secret\> which contains the six CA certificate files provided in the mariadb.certificates section | [Procedure^4^(mariadb_fn4) |
| mariadb.certificates.client_ca_cert<br>mariadb.certificates.server_ca_cert<br>mariadb.certificates.client_cert<br>mariadb.certificates.client_key<br>mariadb.certificates.server_cert<br>mariadb.certificates.server_key | client-ca-cert.pem<br>server-ca-cert.pem<br>client-cert.pem<br>client-key.pem<br>server-cert.pem<br>server-key.pem | The specific client/server certificate files to create, either from the secret given in mariadb.certificates.secret, or via CMGR. | [Procedure^4^(mariadb_fn4) |
| mariadb.encryption.enabled | false | Boolean. Indicates whether data-at-rest encryption should be configured in the database nodes. | Yes |
| mariadb.encryption.secret | *(omitted)* | Specifies the name of the secret that holds the keyfile and the keyfile key. See [Data-At-Rest Encryption](./oam_data_at_rest_encrypt.md) for details. | No |
| mariadb.encryption.KeyFile | *(omitted)* | Specifies the name of the Key File stored in the kube secret. This value is used to encrypt/decrypt the database. | No |
| mariadb.encryption.KeyFileKey | *(omitted)* | Specifies the name of the file that holds the key to decrypt the keyfile. This is required only if the keyfile is encrypted. This value is not required if the keyFile is plain-text. | No |
| mariadb.encryption.keyFileId | 1 | Specifies a particular key in the Key File. If not present, then assume keyid "1". | No |
| mariadb.persistence.size | 20Gi | The size of the volume to attach to the MariaDB pods (database storage size) | No |
| mariadb.persistence.storageClass | *(omitted)* | The Kubernetes Storage Class for the database persistent volume. Default is to use the kubernetes default storage class. | No |
| mariadb.persistence.preserve\_pvc | false | Boolean. Indicates if the Persistent Volumes for database should be preserved when the chart is deleted. | Yes |
| mariadb.persistence.backup.enabled | true | Boolean. Indicates whether separate \"backup\" volume should be attached to the MariaDB pods. This should be enabled when CBUR is enabled to perform backup/restore operations. All other variables in the mariadb.persistence.backup section will be ignored unless this is set to true.| No |
| mariadb.persistence.backup.size | 20Gi | The size of the backup volume to attach to the MariaDB pods. As a general rule, backup volume size should be the same as the mariadb data volume size (mariabackup copies files from data dir into backup dir). | No |
| mariadb.persistence.backup.storageClass | *(omitted)* | The Kubernetes Storage Class for the backup persistent volume. Default is to use the kubernetes default storage class. | No |
| mariadb.persistence.backup.dir | /mariadb/backup | The direcotry to use for backup/restore local to the pod. | No |
| mariadb.persistence.temp.enabled | false | ==NEW IN 7.13.0== Boolean. Indicates whether separate \"temp\" volume should be attached to the MariaDB pods. This is used for mariadb temp file system space and will automatically configure the [tmpdir](https://mariadb.com/kb/en/server-system-variables/#tmpdir) config variable to point to this mount. This is needed when applications perform certain actions (eg. complicated ALTER table) which require large amount of temp file system space. All other variables in the mariadb.persistence.temp section will be ignored unless this is set to true. | No |
| mariadb.persistence.temp.size | 5Gi | ==NEW IN 7.13.0== The size of the temp volume to attach to the MariaDB pods.  Size requirements are application dependent. | No |
| mariadb.persistence.temp.storageClass | *(omitted)* | ==NEW IN 7.13.0== The Kubernetes Storage Class for the temp persistent volume. Default is to use the kubernetes default storage class. | No |
| mariadb.persistence.temp.dir | /mariadb/tmp | ==NEW IN 7.13.0== The mount direcotry for the temp persistent volume. The [tmpdir](https://mariadb.com/kb/en/server-system-variables/#tmpdir) config variable will be set to this value. | No |
| mariadb.persistence.shared.enabled | false | ==NEW IN 7.13.0== Boolean. **Use at your own risk.** Indicates whether a user supplied shared storage PVC should be mounted on *all* mariadb pod(s). It is the applications responsibility to ensure that the storage type being used is capable of being attached to multiple pods.  If not, then only one pod will successfully start.  All other variables in the mariadb.persistence.shared section will be ignored unless this is set to true. | No |
| mariadb.persistence.shared.name | *(omitted)* | ==NEW IN 7.13.0== The kubernetes Persistent Volume Claim (PVC) name for the resource to be mounted as shared storage. The PVC should be in the same namespace as the pods it will be mounted on. | No |
| mariadb.persistence.shared.dir | /mariadb/shared | ==NEW IN 7.13.0== The mount direcotry for the shared PVC. | No |
| mariadb.root\_password | <Generated\> | The MySQL root user database password to configure (base64 encoded) | No |
| mariadb.allow\_root\_all | false | Boolean. Indicates if root user should be allowed to connect from all hosts (e.g., \'%\') | No |
| mariadb.databases<br>mariadb.databases\[\*\].name<br>mariadb.databases\[\*\].character\_set<br>mariadb.databases\[\*\].collate | <None\> | A list of databases to create. .name is required; .character\_set and .collate are optional. Example:<br>mariadb:<br>  databases:<br>    -name: mydb<br>    -name: anotherdb<br>    character\_set: keybcs2 | No |
| mariadb.users<br>mariadb.users\[\*\].name<br>mariadb.users\[\*\].password<br>mariadb.users\[\*\].host<br>mariadb.users\[\*\].privilege<br>mariadb.users\[\*\].object<br>mariadb.users\[\*\].requires<br>mariadb.users\[\*\].with | <None\> | A list of users to create. All fields are required. Note .password must be base64 encoded. (See [MariaDB GRANT Syntax](https://mariadb.com/kb/en/library/grant/)) | No |
| mariadb.mysqld\_site\_conf | \[myslqd\]<br>userstat = on | Additional configuration contents to place in a mysql site configuration file on the MariaDB containers.  See [Server System Variables](https://mariadb.com/kb/en/server-system-variables/) for full list of MariaDB system variables that can be configured.  | Yes |
| mariadb.repl\_user | repl\@b.c | The MySQL replication user to configure. | No |
| mariadb.repl\_user\_password | <Generated\> | The MySQL replication user database password to configure (base64 encoded)<br>*Note: The same password must be used at both sites, if geo-redundant* | No/[Yes^3^](#mariadb_fn3) |
| mariadb.resources.requests.memory<br>mariadb.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the MariaDB pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.resources.limits.memory<br>mariadb.resources.limits.cpu | <Equal to Requests\> | The Kubernetes Memory and CPU resource limits for the MariaDB pods (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.terminationGracePeriodSeconds | 60 | Defines the grace period for termination of mariadb pods. | Yes |
| mariadb.tolerations | *(empty)* | Node tolerations for mariadb scheduling to nodes with taints. Ref: <https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/.> Use with caution. | No |
| mariadb.nodeSelector | *(empty)* | Node labels for mariadb pod assignment. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/\#nodeselector.](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/) Use with caution.<br>***Note***: This option is mutually exclusive with mariadb.nodeAffinity. | No |
| mariadb.nodeAffinity.enabled<br>mariadb.nodeAffinity.key<br>mariadb.nodeAffinity.value | true<br>is\_worker<br>true | Node affinity key in BCMT for the mariadb pods. This should not be changed and will bind the mariadb databases pods to the worker nodes.<br>mariadb.nodeAffinity.enable was added to allow the user to disable this feature.<br>***Note***: This option is mutually exclusive with mariadb.nodeSelector. | No |
| mariadb.metrics.enabled | false | Boolean. Indicates if the mariadb metrics sidecar container should be enabled. | No |
| mariadb.metrics.user | exporter | The MySQL metrics user to configure. | No |
| mariadb.metrics.metrics\_password | <Generated\> | The MySQL metrics user password to configure (base64 encoded). | No |
| mariadb.metrics.image.registry | <global.registry1\> | The registry (global.registry1 override) to use for pulling the MariaDB metrics container image. | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.image.name | prom/mysqld-exporter | The docker image to use for the mariadb metrics containers | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.image.tag | v0.11.0 | The docker image tag to use for the mariadb metrics containers | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.resources.requests.memory<br>mariadb.metrics.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.metrics.resources.limits.memory<br>mariadb.metrics.resources.limits.cpu | <Equal to Requests\> | The Kubernetes Memory and CPU resource limits for the mariadb pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#mariadb_fn1) |
| mariadb.dashboard.enabled | false | Boolean. Indicates if the mariadb Grafana dashboard should be enabled. This will create a configmap containing the MySQL dashboard(s) to be added to Grafana. | [Yes^1^](#mariadb_fn1) |

<a name="mariadb_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  
<a name="mariadb_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**  
<a name="mariadb_fn2"></a>^2^ - Updating this value on an existing chart will result in a Scale lifecycle event being performed.  
<a name="mariadb_fn3"></a>^3^ - Required for geo-redundant deployment of CMDB
<a name="mariadb_fn4"></a>^4^ - Updating this value requires a [special certificate renewal procedure](./att/Configure_HELM_mariadb_certificates_secret_procedure.md)

## **MaxScale Proxy Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#maxscale_fn) |
|:----------|:------------|:----------------|:--------------------------------------|
| maxscale.image.registry | <global.registry\> | The registry (global.registry override) to use for pulling the MaxScale container image. | [Yes^1^](#maxscale_fn1) |
| maxscale.image.name | cmdb/maxscale | The docker image to use for the MaxScale container | [Yes^1^](#maxscale_fn1) |
| maxscale.image.tag | <Version\> | The docker image tag to use for the MaxScale container | [Yes^1^](#maxscale_fn1) |
| maxscale.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#maxscale_fn1) |
| maxscale.count | 0 | The number of MaxScale pods to create. Set to 0 for no MaxScale. Set to 1 for simplex MaxScale. Set to 2 or 3 for HA MaxScale. | No |
| maxscale.masterSwitchoverTimeout | 30 | The time (in seconds) to allow the master switchover to attempt to switch master when the master pod is deleted. | No |
| maxscale.keystorePullTimeout | 300 | The time (in seconds) to allow the maxscale pod to pull the keystore from one of the mariadb pods. | [Yes^1^](#maxscale_fn1) |
| maxscale.maxscale\_ssl | false | ==NEW IN 7.13.0== Set to true to require that all traffic on the maxscale admin interface use SSL encryption.  All calls to the maxctrl API must use secure option and the maxscale REST API will require HTTPS.  This parameter will be ignored unless the mariadb.use\_tls is also set. | No |
| maxscale.maxscale\_user | maxscale | The MySQL maxscale user to configure. | No |
| maxscale.maxscale\_user\_password | <Generated\> | The MySQL maxscale user database password to configure (base64 encoded)<br>*Note: The same password must be used at both sites, if geo-redundant* | No/[Yes^2^](#maxscale_fn2) |
| maxscale.maxscale\_site\_conf | \[maxscale\]<br>threads = auto<br>query\_retries = 2<br>query\_retry\_timeout = 10 | Additional configuration contents to place in a maxscale site configuration file on the MaxScale containers. See [MariaDB MaxScale 2.4](https://mariadb.com/kb/en/mariadb-maxscale-24/) for details on various configuration options for MaxScale. | Yes |
| maxscale.logrotate\_site\_conf | \[maxscale\]<br>maxsize = 2097152<br>rotate = 5<br>compress = no | ==NEW 7.12.0== Customized maxscale logrotate configuration parameters. | Yes |
| maxscale.listeners.rwSplit | 3306 | Define the RWSplit-Service with the given port (typically 3306). | Yes |
| maxscale.listeners.readOnly | *(omitted)* | Enable the RO-Service in maxscale with the given port (typically 3307). Using this port will load-balance all read access to available slave servers. | Yes |
| maxscale.listeners.masterOnly | *(omitted)* | Enable the Master-Only service in maxscale with the given port (typically 3308). Using this port will direct all read/write access to the current Master server. | Yes |
| maxscale.listeners.maxInfo | *(omitted)* | Enable the MaxInfo service in maxscale with the given port (typically 8003). Using this port will allow scraping of metrics from teh maxscale service. | Yes |
| maxscale.sql.promotion | <None\> | List of SQL to inject on the Master MariaDB node after promotion | Yes |
| maxscale.sql.demotion | <None\> | List of SQL to inject on the Slave MariaDB node after demotion | Yes |
| maxscale.resources.requests.memory<br>maxscale.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the MaxScale pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.resources.limits.memory<br>maxscale.resources.limits.cpu | <Equal to Requests\> | The Kubernetes Memory and CPU resource limits for the MaxScale pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.enabled | false | Boolean. Indicates if the maxscale metrics sidecar container should be enabled. | No |
| maxscale.metrics.image.registry | <global.registry\> | The registry (global.registry override) to use for pulling the maxscale metrics container image. | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.image.name | cmdb/maxscale-exporter | The docker image to use for the maxscale metrics containers | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.image.tag | 0.1.1-1.<build\> | The docker image tag to use for the maxscale metrics containers | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.resources.requests.memory<br>maxscale.metrics.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the maxscale pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |
| maxscale.metrics.resources.limits.memory<br>maxscale.metrics.resources.limits.cpu | <Equal to Requests\> | The Kubernetes Memory and CPU resource limits for the maxscale pod metrics container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#maxscale_fn1) |

<a name="maxscale_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  
<a name="maxscale_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**  
<a name="maxscale_fn2"></a>^2^ - Required for geo-redundant deployment of CMDB

## **Administrative Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#admin_fn) |
|:----------|:------------|:----------------|:-----------------------------------|
| admin.image.registry | <global.registry\> | The registry (global.registry override) to use for pulling the Admin container image. | [Yes^1^](#admin_fn1) |
| admin.image.name | cmdb/admin | The docker image to use for the Admin container(s) (Jobs) | [Yes^1^](#admin_fn1) |
| admin.image.tag | <Version\> | The docker image tag to use for the Admin container | [Yes^1^](#admin_fn1) |
| admin.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#admin_fn1) |
| admin.recovery | <None\> | A database recovery indicator used for Healing. When this value is changed in the chart release, a Heal will be performed on the database nodes. If this value includes a colon-index (e.g., xxx:1), the Heal will be limited to that node (node 1); otherwise the entire cluster will perform a Heal. | [Yes^2^](#admin_fn2) |
| admin.configAnnotation | false | ==NEW 7.6.0== If set to \"true\", an annotation will be added to the mariadb and maxscale statefulsets to restart pods on a configuration change (normal k8s behavior). If set to \"false\" (default), pods will not be restarted on configuration changes, however the new configuration will be injected into the running pods and the services will be restarted. | [Yes^1^](#admin_fn1) |
| admin.autoHeal.enabled | true | ==NEW 7.6.0== Set to \"true\" to enable Galera cluster auto-heal capability. | Yes |
| admin.autoHeal.pauseDelay | 900 | ==NEW 7.6.0== Time (in seconds) after deploy or heal operation to wait before re-enabling auto-heal (if auto-heal is enabled). Be careful setting to too small a value, if no pods are ready yet after deploy/heal and the audit triggers, an auto-heal may be initiated. | Yes |
| admin.rebuildSlave.enabled | true | ==NEW 7.10.2== Set to \"true\" to enable MaxScale cluster auto-rebuild of failed Master server. | Yes |
| admin.rebuildSlave.preferredDonor | slave | ==NEW 7.10.2== Preferred donor (master or slave) to use for auto-rebuild of failed Master server. | Yes |
| admin.rebuildSlave.allowMasterDonor | true | ==NEW 7.10.2== Allow Master server to be used as Donor server? | Yes |
| admin.rebuildSlave.timeout | 300 | ==NEW 7.10.2== Time (in seconds) to allow for rebuild of slave to complete before aborting. | Yes |
| admin.rebuildSlave.parallel | 2 | ==NEW 7.10.2== Number of donor threads to use for rebuild. | Yes |
| admin.rebuildSlave.useMemory | 256M | ==NEW 7.10.2== Amount of memory to use for joining server. *(Do not set to more than half of resources.limits.memory)* | Yes |
| admin.quickInstall | \"\" | Set to \"yes\" to perform quick install of CMDB chart. A quick install will bypass waiting for all database pods to come up. Using quick install may result in pod failures not being detected during the installation process. | No |
| admin.debug | false | If true, the Admin container(s) will include more verbose output on stdout | Yes |
| admin.activeDeadlineSeconds | 120 | activeDeadlineSeconds for pre-upgrade-job | No |
| admin.pwChangeSecret | <None\> | The name of a Kubernetes secret which defines a set of password change data items. Used to change passwords for users via helm. | No |
| admin.persistence.enabled | true | Boolean. Indicates whether separate \"admin\" volume should be attached to the Admin pod.  This should not be changed. | No |
| admin.persistence.size | 20Gi | The size of the volume to attach to the Admin pod. This should typically be the same as mariadb.persistence.size since the admin container may need to perform backups of pods to perform heal and scale-out operations. | No |
| admin.persistence.storageClass | *(omitted)* | The Kubernetes Storage Class for the admin persistent volume. Default is to use the kubernetes default storage class. | No |
| admin.resources.requests.memory<br>admin.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the Admin pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| admin.resources.limits.memory<br>admin.resources.limits.cpu | 512Mi<br>500m | The Kubernetes Memory and CPU resource limits for the Admin pod (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| admin.terminationGracePeriodSeconds | 120 | ==NEW 7.11.3== Defines the grace period for termination of admin pod. Must provide enough time to add configMap with temporary pod advertisements. | Yes |
| admin.tolerations | *(empty)* | Node tolerations for admin scheduling to nodes with taints. Ref: [https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/.](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/) Use with caution. | No |
| admin.nodeSelector | *(empty)* | Node labels for admin pod assignment. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/\#nodeselector.](https://kubernetes.io/docs/concepts/configuration/taint-and-tolerations/) Use with caution.<br>***Note***: This option is mutually exclusive with admin.nodeAffinity. | No |
| admin.nodeAffinity.enabled<br>admin.nodeAffinity.key<br>admin.nodeAffinity.value | true<br>is\_worker<br>true | Node affinity key in BCMT for the admin pod. This should not be changed and will bind the admin pod to the worker nodes.<br>***Note***: This option is mutually exclusive with admin.nodeSelector. | No |

<a name="admin_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  
<a name="admin_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**  
<a name="admin_fn2"></a>^2^ - Updating this value on an existing chart will result in a Heal lifecycle event being performed.

## **Geo-Redundancy Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#geored_fn) |
|:----------|:------------|:----------------|:------------------------------------|
| geo\_redundancy.enabled | false | Boolean. Indicates if Geo-Redundancy should be configured between 2 clusters (Datacenters)<br>When set to true, the following will automatically be set independent of the user setting:<br>services.maxscale.enabled = true<br>service.maxscale.type = NodePort | No |
| geo\_redundancy.site\_index | 1 | The (1-based) index for this site used for determining conflict-avoiding autoincrement settings. Each site must have a different index (1 or 2) | No |
| geo\_redundancy.lag\_threshold | 30 | Passed into the MaxScale container as DATACENTER\_LAG\_THRESHOLD (See [Docker Configuration](./oam_configure_docker.md)) | No |
| geo\_redundancy.slave\_purge\_interval | 60 | Passed into the MaxScale container as DATACENTER\_SLAVE\_PURGE\_INTERVAL (See [Docker Configuration](./oam_configure_docker.md)) | No |
| geo\_redundancy.remote.name | remote | Name associated with remote datacenter. | No |
| geo\_redundancy.remote.maxscale | <None\> | IP:Port of the remote cluster (Datacenter) MaxScale service. Typically the IP/VIP of the Edge Node(s) and NodePort of the maxscale Kubernetes Service | Yes |
| geo\_redundancy.remote.master | <None\> | IP:Port of the remote cluster (Datacenter) MariaDB-Master service. Typically the IP/VIP of the Edge Node(s) and NodePort of the mariadb-master Kubernetes Service | Yes |
| geo\_redundance.remote.master\_remote\_service\_ip | <None\> | mariadb-master-remote ClusterIP for replicating to remote DC. You must set this to the original service IP assigned by kubernetes to the mariadb-master-remote service if re-deploying charts using preserve PVC. If unset, the service IP will be auto-generated by kubernetes. | No |

<a name="geored_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  

## **Hooks Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#hooks_fn) |
|:----------|:------------|:----------------|:-----------------------------------|
| hooks.deletePolicy | hook-succeeded | The deletion policy to use for kubernetes Jobs. By default, the jobs will be deleted upon success. *If using Helm v2.9+, this can be set to before-hook-creation to retain hook history until the next lifecycle event.* | Yes |
| hooks.preInstallJob.enabled<br>hooks.preInstallJob.name<br>hooks.preInstallJob.containerName<br>hooks.preInstallJob.timeout | true<br>pre-install<br>pre-install-admin<br>120 | ==NEW 7.12.0== Set **enabled** to false to disable running of the pre-install-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postInstallJob.enabled<br>hooks.postInstallJob.name<br>hooks.postInstallJob.containerName<br>hooks.postInstallJob.timeout | true<br>post-install<br>post-install-admin<br>900 | ==NEW 7.12.0== Set **enabled** to false to disable running of the post-install-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preUpgradeJob.enabled<br>hooks.preUpgradeJob.name<br>hooks.preUpgradeJob.containerName<br>hooks.preUpgradeJob.timeout | true<br>pre-upgrade<br>pre-upgrade-admin<br>180 | ==NEW 7.12.0== Set **enabled** to false to disable running of the pre-upgrade-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postUpgradeJob.enabled<br>hooks.postUpgradeJob.name<br>hooks.postUpgradeJob.containerName<br>hooks.postUpgradeJob.timeout | true<br>post-upgrade<br>post-upgrade-admin<br>1800 | ==NEW 7.12.0== Set **enabled** to false to disable running of the post-upgrade-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preRollbackJob.enabled<br>hooks.preRollbackJob.name<br>hooks.preRollbackJob.containerName<br>hooks.preRollbackJob.timeout | true<br>pre-rollback<br>pre-rollback-admin<br>180 | ==NEW 7.12.0== Set **enabled** to false to disable running of the pre-rollback-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postRollbackJob.enabled<br>hooks.postRollbackJob.name<br>hooks.postRollbackJob.containerName<br>hooks.postRollbackJob.timeout | true<br>post-rollback<br>post-rollback-admin<br>300 | ==NEW 7.12.0== Set **enabled** to false to disable running of the post-rollback-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preDeleteJob.enabled<br>hooks.preDeleteJob.name<br>hooks.preDeleteJob.containerName<br>hooks.preDeleteJob.timeout | true<br>pre-delete<br>pre-delete-admin<br>120 | ==NEW 7.12.0== Set **enabled** to false to disable running of the pre-delete-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postDeleteJob.enabled<br>hooks.postDeleteJob.name<br>hooks.postDeleteJob.containerName<br>hooks.postDeleteJob.timeout | true<br>post-delete<br>post-delete-admin<br>180 | ==NEW 7.12.0== Set **enabled** to false to disable running of the post-delete-job. Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postHealJob.name<br>hooks.postHealJob.containerName<br>hooks.postHealJob.timeout | true<br>post-heal<br>post-heal-admin<br>180 | ==NEW 7.12.1== Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.preRestoreJob.name<br>hooks.preRestoreJob.containerName<br>hooks.preRestoreJob.timeout | true<br>pre-restore<br>pre-restore-admin<br>180 | ==NEW 7.12.1== Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |
| hooks.postRestoreJob.name<br>hooks.postRestoreJob.containerName<br>hooks.postRestoreJob.timeout | true<br>post-restore<br>post-restore-admin<br>180 | ==NEW 7.12.1== Set **name** to change the job pod name.  Set **containerName** to change the default job pod container name. Set **timeout** to change the job timeout (in seconds).| Yes |

<a name="hooks_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  

## **Backup/Restore Policy (CBUR) Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed**[^†^](#cbur_fn) |
|:----------|:------------|:----------------|:----------------------------------|
| cbur.enabled | true | Enables the deployment to use backup/restore policy (BrPolicy). Requires cbur-master deployment. Set to false if cbur-master is not deployed in kubernetes cluster. | No |
| cbur.image.registry | <global.registry2\> | The registry (global.registry2 override) to use for pulling the CBUR container image. | [Yes^1^](#cbur_fn1) |
| cbur.image.name | cmdb/admin | The docker image to use for the CBUR container(s) (Jobs) | [Yes^1^](#cbur_fn1) |
| cbur.image.tag | <Version\> | The docker image tag to use for the CBUR container | [Yes^1^](#cbur_fn1) |
| cbur.image.pullPolicy | IfNotPresent | The policy used to determine when to pull a new image from the docker registry | [Yes^1^](#cbur_fn1) |
| cbur.jobhookenable | true | Exposes jobhookenable to control BrPolicy behavior for galera. When enabled, no action in postRestoreCmd and postrestore job hook for helm restore should run. When disabled, postRestoreCmd is executed and subsequent out-of-band helm heal is required. | Yes |
| cbur.legacyHooks | false | ==NEW 7.12.0== Exposes legacy NCMS Helm plugin hooks to override the CBUR BrHook API. | Yes |
| cbur.backendMode | local | Defines the backup storage options (ie. local, NetBackup, S3, Avamar) | Yes |
| cbur.autoEnableCron | false | Specifies if the backup scheduling cron job should be automatically enabled. | Yes |
| cbur.autoUpdateCron | false | ==NEW 7.12.0== Specifies cron update will be triggered automatically by BrPolicy update. | Yes |
| cbur.cronSpec | 0 0 \* \* \* | Allows user to schedule backups. | Yes |
| cbur.maxiCopy | 5 | Defines how many backup copies should be saved. | Yes |
| cbur.dataEncryption | true | When cbur.enabled is true, this dictates whether cbur will encrypt the backup in the CBUR repo. Disabling encryption will remove the encryption key dependency on the release name and allow CMDB to be restored from a backup taken at a geo-redundant site. | Yes |
| cbur.brhookType | brpolicy | ==NEW 7.10.1== Specifies the targetType (brpolicy\|release) of a specific BrHook API. | Yes |
| cbur.brhookWeight | 0 | ==NEW 7.10.1== Specifies the weight (integer) to control sequencing of multiple BrHook APIs. | Yes |
| cbur.brhookEnable | true | ==NEW 7.10.1== Specifies the boolean enable (true\|false) to enable/disable a specific BrHook API. | Yes |
| cbur.brhookTimeout | 600 | ==NEW 7.10.1== Specifies the timeout (seconds) for maximum wait time of a specific BrHook API. | Yes |
| cbur.prebackup_mariabackup_args | *(omitted)* | Specifies additional arguments for the mariabackup backup operation. | na[^2^](#cbur_fn2) |
| cbur.postrestore_mariabackup_args | *(omitted)* | Specifies additional arguments for the mariabackup restore operation. | na[^2^](#cbur_fn2) |
| cbur.preBackupHook.name<br>cbur.preBackupHook.containerName<br>cbur.preBackupHook.timeout | brhook-prebackup<br>brhook-prebackup-admin<br>180 | ==NEW 7.13.0== Set **name** to change the brhook job pod name.  Set **containerName** to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.postBackupHook.name<br>cbur.postBackupHook.containerName<br>cbur.postBackupHook.timeout | brhook-postbackup<br>brhook-postbackup-admin<br>120 | ==NEW 7.13.0== Set **name** to change the brhook job pod name.  Set **containerName** to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.preRestoreHook.name<br>cbur.preRestoreHook.containerName<br>cbur.preRestoreHook.timeout | brhook-prerestore<br>brhook-prerestore-admin<br>120 | ==NEW 7.13.0== Set **name** to change the brhook job pod name.  Set **containerName** to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.postRestoreHook.name<br>cbur.postRestoreHook.containerName<br>cbur.postRestoreHook.timeout | brhook-postrestore<br>brhook-postrestore-admin<br>900 | ==NEW 7.13.0== Set **name** to change the brhook job pod name.  Set **containerName** to change the default brhook job pod container name. Set **timeout** to change the brhook job timeout (in seconds).| Yes |
| cbur.resources.requests.memory<br>admin.resources.requests.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource requests for the CBUR container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |
| cbur.resources.limits.memory<br>admin.resources.limits.cpu | 256Mi<br>250m | The Kubernetes Memory and CPU resource limits for the CBUR container (See [K8s documentation](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#how-pods-with-resource-requests-are-scheduled)) | [Yes^1^](#admin_fn1) |

<a name="cbur_fn"></a>^†^ - There is no mechanism to prevent updating any values listed on an existing chart release. Therefore, an attempt to change any marked with an Update Allowed of No will not be prevented, but it will most likely result in the existing release of the chart being rendered unusable.  
<a name="cbur_fn1"></a>^1^ - Updating this value on an existing chart will cause a rolling update of the pods. These values should be updated carefully and with the expectation that service will be impacted. **For values that impact the MaxScale pod, updating this value will cause a service outage while the MaxScale pod is restarted.**  
<a name="cbur_fn2"></a>^2^ - Beware: "helm backup" will NOT automatically pick up changes to the "*_mariabackup_args" parameters when changed after installation. In this case, use "kubectl edit BrPolicy <cmdb-fullname>-mariadb" to manually reflect any changes.  

## **Cert-Manager Certificate Parameters**

| **Parameter** | **Default** | **Description** | **Update Allowed** |
|:----------|:------------|:----------------|:----------------------------------|
| certManager.apiVersion | certmanager.k8s.io/v1alpha1 | ==NEW 7.9.1== Defines the versioned schema of this representation of an object. | No |
| certManager.duration | 8760h | Certificate default Duration. | No |
| certManager.renewBefore | 360h | Certificate renew before expiration duration. | No |
| certManager.commonName | ((cmdb.fullname))-mariadb | A common name to be used on the Certificate. | No |
| certManager.caIssuer.name | ncms-ca-issuer | The cluster issuer. | No |
| certManager.dnsName1 | <Namespace\>.svc.<clusterDomain\> | ==CHANGED in 20.05.2== First of subject alt names to be used on the Certificate. | No |
| certManager.dnsName2 | *(omitted)* | ==NEW 7.9.1== Second of subject alt names to be used on the Certificate. | No |
