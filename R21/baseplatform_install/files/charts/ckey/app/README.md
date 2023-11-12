# Keycloak
[Keycloak](https://www.keycloak.org) is an open source Identity and Access Management solution aimed at modern applications and services. It makes it easy to secure applications and services with little to no code.

## Introduction
This chart bootstraps a [Keycloak](https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=CSF-KEYCLOAK.git;a=shortlog;h=refs%2Fheads%2Fdocker) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. For more details about CKEY, please consult our confluence that is available at the following URL: https://confluence.app.alcatel-lucent.com/display/plateng/CKEY+-+Web+SSO+Guide?src=contextnavpagetreemode

## Prerequisites
- Kubernetes 1.6+ with Beta APIs enabled
- Helm (2.5.1+) installed
- The current cmdb dependency in requirements.yaml requires CSDC to be installed prior to installing CKEY (if cmdb.enabled is set to true).

## Installing the Chart
To install the chart with the release name `my-release`:

```bash
$ helm install ckey --name my-release
```

The command deploys Keycloak on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart
To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

Keycloak has multiple configurable parameters. For more details about these parameters, please take a look at the values-model.yaml file which contains a description for each item. On ComPaaS, the descriptions already appear for each configurable parameter. Keycloak parameters map to the env variables defined in [Dockerized Keycloak](https://confluence.app.alcatel-lucent.com/pages/viewpage.action?spaceKey=plateng&title=CKEY+-+Web+SSO+Guide#CKEY-WebSSOGuide-DockerizedKeycloak). For more information please refer to the [Dockerized Keycloak](https://confluence.app.alcatel-lucent.com/pages/viewpage.action?spaceKey=plateng&title=CKEY+-+Web+SSO+Guide#CKEY-WebSSOGuide-DockerizedKeycloak) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release --set dbIP=<db IP address goes here>,dbName=newdb stable/ckey
```

The above command sets up Keycloak using MariaDB instance 'newdb' on the specified  IP address (this would require a database to be installed and configured for Keycloak on the specified IP).

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ckey
```

> **Tip**: If '-f' is omitted, default values.yaml will be used.

## The default values may be seen in the helm chart's default values.yaml file.

NOTE: If the cmdb.enabled flag is set to true, we will deploy an instance of CMDB and connect Keycloak to it. If cmdb.enabled is set to false, you must provide the proper DB information and adjust the liveness prob timeout with respect to the time required for database schema initialization to complete. Keycloak expects the CMDB instance to have (1) a database, e.g. db4keycloak, and (2) a user, e.g. keycloak, which CKEY will use to connect to the database. You must ensure that the DB password that you provide to Keycloak is encoded with PicketBox, and you must also ensure that the keycloak user has the correct privileges over the applicable database. 
Granting the privilege can be achieved by running SQL queries, e.g.:
$ GRANT ALL PRIVILEGES ON db4keycloak.* to keycloak@'%' IDENTIFIED BY 'r00tr00t'; 
$ GRANT ALL PRIVILEGES ON db4keycloak.* to keycloak@'localhost' IDENTIFIED BY 'r00tr00t';
Encoding the DB password can be done by using the PicketBox jar and running the following command:
$ java -cp picketbox-4.9.6.Final.jar  org.picketbox.datasource.security.SecureIdentityLoginModule r00tr00t
This would return: # Encoded password: -444d243c54645015207a6df87216de44
For more information, please consult our documentation on Confluence.
