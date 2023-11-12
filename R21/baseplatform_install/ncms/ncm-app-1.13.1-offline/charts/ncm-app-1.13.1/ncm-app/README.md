# NCM-APP

## Introduction

NCM-APP is an advanced Helm/Profile Operator with REST API.
It covers all the common lifecycle events(instantiate / upgrade / update / rollback / backup / restore / scale / terminate) of K8S applications packaged :
- using [Helm](https://helm.sh)
- using NOKIA profile (a spec defining bundles of charts with templatizable values)

Functionally, it can be considered as a [Kubernetes](http://kubernetes.io) Operator for NOKIA profile, controlling helm operations.

In addition to a REST API for helm, it provides :
- templating of values
- tagging (tags/skiptags)
- sequential or parallel of bundles of charts (group in profile)
- manage dependencies using waitFor crd,pods...
- harden helm with reinstall/retry in case of disconnections
- helm version agnostic (support of helm2/helm3 on demand or by affinity with cluster)
- helm repository agnostic (the service search the repository exporting the release, can deploy relocatable chart)

The REST interface is defined through a Swagger API. A dynamic cli is embedded with.
In addition to the REST interface, it will be able to react when changes are operated directly on the Profile CRD, that is through K8S API.
The API is helm2/3 transparent (but you can force a specific version for test purpose)

### Relation with hosted helm
From 1.12.x version, the server used is own binary versions. For compliancy, the default mode may still share the foled of the hosted helm, for repositories and plugins, and for its own data storage. In future releases, default mode will be autonomous. See above for more details.

## Prerequisites
- HELM 2.7+
- HELM Nokia plugins for lifecycle events
- RBAC to mount /root volumes

## Values

Values are defined and commented in the values.yaml. The present document describes more in details some of them.

### Deploy anywhere (Third party K8S)

Despite, the default values are sized for nokia container usage, the component
is also setup over various type of K8S. 

#### parameters
> standalone.enabled (false)
this is the recommended manner to setup the pod, since all the datas are then managed within a persistent volume storage
with no binary or folder dependencies with the "host".


> helmHostPath (/root/.helm)
When using the host env to store data, this value give the path to mount within the pod to read/write datas
This is a mandatory parameter to set.


#### install using kubectl

1. helm fetch csf-stable/ncm-app --version x.y.z
2. create values.yaml

        nodeSelector: []
         tolerations: []
        env:
         HELM_BIN: /casr/N+1/helm3
3. helm template ncm-app-x.y.z.tgz --name app-api -f values.yaml --output-dir .
4.
    1.if helm2 server or helm3 already setup on K8S
    >helm install app-api .
    2. if no helm on platform
 >kubectl apply -f ncm-app/templates/
### Audit

By default, the server will use the CSF CLOG audit service in order to track:
- any CUD http methods (success or failure)
- any READ http method related to release values (success or failure)
- any HELM command issues triggered during instantiating/upgrading a profile

The logger is defined by
env.AUDIT_LOGGER (default is ncm.audit)
The level is WARN by default but INFO can be set using
env.AUDIT_LEVEL_INFO to any value

### Logging

env.LOGGERS
>configure the very default java loggers.
however we recommend to turn on or off using the REST API (PUT /ncm/applications/logger/ncms allows to set to INFO and see helm commands)

### Helm
extended flags
>In addition to the support of profile, the server is able to react to specific extended flags. There are reflected in the "ncm app showAll" or OPTIONS /ncm/applications command. No parameters are required.

#### embedded with multiple versions
env.HELM_FAVORITE (2 is default)
>allows to start the service using the favorite helm version by default.
>Notice that this helm binary to be used can be decided  on the fly by pushing
>- either the Helm header ,i.e -H 'Helm:3.3.2'
>- or &helm=3.2.2
>
>The service comes with 3 embedded helm versions (named, N-1,N,N+1). N-1 referes to helm2 release.

env.HELM_BLACKLIST
> allows to blacklist a list of versions. For instance, to prevent helm2 from being used, define it with "2" 

#### Hosted
In addition to the embedded helm binaries, the service can be configured to use the binary served by the host
env.HELM_BIN
>allows to customize hosted helm binary path. By default, the /usr/local/bin/helm from the host.

helmHostPath ($HOME/.helm)
>this parameter can guide the hosted HELM_HOME. It is expected the folder to be defined as mounter point

env.STABLE_URL (http://tiller-repo:8879)
>allows to customize the default stable repo. This is only used for multitenant purpose with helm2.

env.XDG_DATA_HOME ($HOME/.helm/helm3/.local/share)
>allows to customize data directory for helm3

env.XDG_CONFIG_HOME ($HOME/.helm/helm3/.local/.config)
>allows to customize config directory for helm3 ($HOME/.config)

env.XDG_CACHE_HOME ($HOME/.helm/helm3/.local/.cache)
>allows to customize cache directory for helm3
### Security

env.SEMVER
>This parameter should never be used. It allows to customize the pattern to check the semver compatibility of the chart names. By default the server apply a semver2 pattern. Despite this is highly not recommended, you may loose this constraint setting the value to "(.*[a-z])-([0-9].*)". See values.yaml

env.SECURE (false)
> Only token from Keycloak (Out Authentication) and the current Kubernetes cluster (In Authentication) are accepted

env.LOG_LOCKED (false)
>prevent from changing or seing log from REST API

env.MAXFILESIZE (2000000)
>prevent from uploading huge file (the server uploads chart, or profile or templates). This is not the endpoint to onboard images. So keep this limit low

env.PARANOIAC_SECURITY (false)
>toggle this to limit information on 403, 401 error

env.MT (false)
> set to true to harden the control of NCM-xxx dedicated headers on multitenancy env. This parameter is legacy. See env.MT_MODE

env.MT_MODE ("O")
> set the type of control for multitenancy between 0 (none), 2 (helm2 model), 3 (helm3 model), 5 (hybrid). Setting MT to true on hybrid platform , should lead to 5.

keycloak.enabled (false)
> harden the token used by validating with the keycloack server. By default, the keycloak
> format is simply check.

env.PRIVILEGES_GROUP("system:authenticated,convert-additional-privileges-group,backup-additional-privileges-group")
> allows to define a list of groups of permissions requires for each request in a multitenancy env. by default convert and backup plugin requires additional privileges

env.AUTHORIZED_NS_PATTERN ()
> to be set too %s-ns to trigger and support ncs tenant namespace

env.K8S_TOKEN_VALIDATION (true)
> when env.SECURE is true, try to validate token with a request to api server (get nodes or get sa if namespace)

env.K8S_TOKEN_PATTERN (kubernetes/serviceaccount|k8s-aws-)
> when env.SECURE is true, service account token identification pattern.

env.K8S_CHECK_TYPE (RESOURCES)
> when env.SECURE and K8S_TOKEN_VALIDATION are true, this is the request used to challenge the key against the current cluster. Other choices are SERVICE_ACCOUNTS and NODES.

env.KEYCLOAK_TOKEN_PATTERN(.*(keycloak.*)|(.*/auth/realms/.*)
> when env.SECURE is true, check token is keycloak based

env.LOG_OBFUSCATOR ("(password|pwd) ([^ ,]*)")
> allows to obsfuscate password shown in helm commands

### Autonomous (or persistent mode)
autonomous.enabled (false default)
>when activating, the service will clain a persistent storage to store its data:
1) helm meta data (plugins, repositories)
2) profiles definition onboarded/deployed
3) projects meta data (when multitenancy is used)

Values.autonomous.tiller (helm2 only)
> allow to autodeploy a tiller instance in the same namespace/service account as the service itself

### Helm hardening
env.IGNORE_LINES
>Some version of HELM have troubles in the output whenever grpc issues occurs. Since the server inteprets the output, this may lead to misbehavior. In order to harden the server when it faces such issues, we provide the following parameter that provides a pattern to ignore silently such spurious lines whose default value is ".*portforward.go.*" that is the signature of the spurious line

#### Retry on issues
The ncm-app controller provides logic to harden and recover helm client whenever connection issue might occur during
a long install/upgrade or terminate activity. The logic also manages helm tiller pod failure or restart.
The logic can be customized according to the following properties.

env.RETRY_PATTERN
> When the helm client returns any output matching this given pattern, the controller detects a recoverable case in which a retry of the failed command can be attempted. The default value is ".*could not find a ready tiller pod|transport is closing|Error: forwarding ports|dial tcp|read: connection reset by peer.*". Resetting with an implausible value (like "ZZ") will deactivate the retry feature.

env.RETRY_MAX (default 4)
> This is the maximum number of retries the controller will attempt for a recoverable command. Multiply with the env.RETRY_TIMEOUT, you obtain the maximum period of time a command will be replayed.
> When the threshold is reached, the original error is returned to the caller.

env.RETRY_TIMEOUT (default 5)
> This is a period in seconds between each retry of a recoverable command.

env.RETRY_STRATEGY (default 1)
> This is the identifier of the strategy to apply when install needs to be recovered (from a profile). Indeed, replaying an install will often fail due to pre-existing resources.

> The default strategy (1) consists in :

>    A)if release is pending, purging any resources creating within helm hooks and deleting the release.

>    B)if release is unknown (i.e occurs before installation, during pre-install hooks) the release cannot be deleted through helm. The strategy attempts to purge any planified resources.

>    C)if release is failed (i.e occurs before installation, during pre-install hooks), purging any hook-based resources then deleting with nohooks. This strategy is retried with RETRY_MAX, as a workaround
>to "object is being deleted" issue.

>Setting the value to 0 will deactivate any attempt to recover installation issue.

env.RETRY_PENDING_WAIT (default 180)
> this is the period in seconds before applying the env.RETRY_STRATEGY on a pending release.

#### Retry on timeout
The ncm-app controller provides logic to harden and recover case where helm client get stuck for HELM_READ cases. When issues
occur in tiller/k8s, the socket used by the helm client may get stuck during the HELM_TIMEOUT period (300s). Since this is not
expected that a helm "read" command takes a long time (long more than HELM_QUICK_TIMEOUT (30s), the controller detects such a case and will perform the retry mechanism.

env.HELM_READ
> this is pattern that detects helm command that should answer quickly (HELM_QUICK_TIMEOUT). When such method timeouts,
>the system will retry following the same principle described int the chapter "retry feature". Setting the HELM_READ to implausible value,
>will deactivate this feature. By default , read command are "helm get|helm status| helm list| helm version"

env.HELM_TIMEOUT (300s)
> this is the period in seconds during the time the controller waits for a result of helm client command. Default is the HELM default timeout value

env.HELM_QUICK_TIMEOUT (30s)
> this is the period in seconds during the time the controller waits for a result of a helm read client command.

### Cli friendly output
env.User-Agent
>In addition to reflect the output of helm command, the server is able to convert in json when meaningful or adapt the output to the ncm cli. To help identifying the client, the following parameter is used. By default "ncm|go" is the matching pattern

### Operator Mode
> controller (false)

This will trigger the operator mode, starting multiple controllers for Profile CRD and Helm Secrets.Do not use yet in production.

### Misc

env.RELEASE
env.NAMESPACE
> are automatically injected by helm

env.CBUR_RELEASE (cbur-master)
env.CBUR_NAMESPACE (ncms)
>allow to relocate cbur chart reference. this is mainly to query information on cbur configuration (not critical)

env.TIMEOUT (300s)
>allows to customize timeout used when scheduling client in the server. 40s is the default value. Notice that helm
>is following the default HELM_TIMEOUT (300s) or HELM_QUICK_TIMEOUT (30s) according to helm command type.

env.JOBCLEANER_TIMEOUT (60mn)
>configure the backup/restore job cleaner

env.AUTODELETE (internal purpose only)
> allows ncm app|profile terminate to destroy itself

env.SMARTUPGRADE (true)
> profile upgrade is a smart diff algorithm before trigering helm upgrade (automatic version of --skipudpdate function)

env.TILLER_NAMESPACE (kube-system)
>this is the namespace for the default tiller. 

env.HELM_SEARCH_FLAGS
>these are optional flags to use by the server to find charts. By default for helm 2.15+, --devel is the default.
>you can reset these flags to hide such chart visiblity for instance

env.K8S_API_TIMEOUT (20s)
> this configure the connection timeout when requesting the K8S Api Server

env.SHOWTRACE (false)
>  this enable to show stack traces to know the cause of an exception.

env.REPO_SYNC (true)
>  on hybrid platform, helm2 and helm3 repositories are keep synchronized. It also lead to provide helm2+helm3 results 
in ncm app command list.

env.2TO3_CONVERT_FLAGS (--delete-v2-releases)
> when conversion is detected, they are the flags to the convert plugin

env.IGNORED_ENV ("HARBOR|BCMT|GLUSTER|KUBERN|PATH|SHL|INSTANCE_|CBUR|TILLER|CLCM|CERT|HEKETI|APP_API|LOCAL|PWD|/conf|/env|HOSTNAME")
> hide env in showAll

env.CBUR_ENDPOINT (default if CBUR_MASTER_CBUR_PORT)
> backup restore command will be enriched with explicit endpoint -x value 

env.USE_CACHE (true)
> chart finding strategy relying on cache instead of costly helm search. the strategy build optimizes indexes whenever
a profile is onboarded/installed/upgraded from a cache. From the index, the concrete url is retrieved very fast.

env.REPO_CACHE_TTL (86400)
> ttl of cache repositories in seconds (default is 24h). Can be set to 0 to prevent cache cleaning. This parameter allows
to free memory or to cleanup when repositories are no more used in a long life system.

env.REPO_RANKING (stable:)
> policy rules to priorize chart repository when multi matching (syntax is [regexp:]*) 

env.REPO_CACHE_INTEGRITY (false)
> reject when multiple chart are matching with different digest (only digest field in repository index is considered)

env.PROJECT_ADD_PLUGINS (true)
> link or copy plugins on each project (required in MT env)

env.PROJECT_SET_FILEPERMISSIONS (true)
> modify permissions of kubeconfig created by user (required in MT env)

env.ERROR_TO_FAILED_PATTERN ("Error|Exception")
> when helm command fails without changing the chart status, this pattern captures the error and turn into FAILED
	
env.AUTHORIZED_NS_PATTERN ("") 	
> advanced usaged. set it "%s-admin-ns" to trigger NCS multi-tenancy support

env.PLUGINS_REINSTALL(true)
> when pod restarts, systematically reinstall helm plugins that are packaged with the pod

env.PLUGINS_CLEANUP(true)
> when pod restarts, cleanup any helm duplications after reinstalling. trigger only if PLUGINS_REINSTALL is true

env.HELM_INIT_EMULATION(true)
> emulate helm init when creating new tenant/project. By disabling, helm init will be invoked (it requires link priviledge 
on host volume)

env.PLUGINS_COPY(false)
> when creating tenant projects, plugins are linked to the project/tenants. By enabling, copying is done instead of linking
(automatically set when link priviledge is not possible on host volume)

env.TAGS2LABELS(true)
> perform automatic labelling of existing profiles

env.DOLABELLING(true)
> activate the labelling mode that allows to drastically improve performance of profile status and terminate

env.DOTAGGING(true)
> activate the tagging of profile into the value of releases. When DOLABELLING is on, this policy is just informative.
Will be deprecated later.

env.PROFILE_CHECK_CONSISTENCY(true)
> only when DOLABELLING is on. Check that  a control before instantiating/upgrading a profile, consisti to check any selected releases are not used by
any other profile. If found, 409 is returned.

env.REJECT_ORPHAN_RELEASES(true)
>only when PROFILE_CHECK_CONSISTENCY is on. Prevent a profile from adopting any orphan existing release. Saying differently, no sharing service is accepted by default.

env.HELM_AFFINITY(true)
> for helm2, select helm client compliant with the hosted tiller.


## Experimental

profileEndpoint
>toggle implementation (Legacy/CRD). Experimental. Only Dev purpose

env.SMART_PROFILE (false)
> this enable the smart profile validation. It will compare the resource claimed and the resources available on the namespaces used by the profile. There are two corner cases once activated.
> Either targeted namespace doesn't have any quota defined, any chart will be rejected
> or if chart has no claiming resource and namespace doesn't have limitRange, the chart will be accepted.

## Embedded dynamic cli (dev)

The server embeds a smart cli that allows to replace curl REST command using the same user experience than the ncm command.
This cli dynamically load the commands according to the swagger served by the server.
from your cluster, you can setup using

        curl -ksO https://app-api-ncms-app.ncms.svc.cluster.local:8443/ncm/bin/cli.gz
        gzip -fd cli.gz && mv cli palm && chmod +x palm
        palm version
        palm help
        palm --completion > palm.completion
        source palm.completion
        palm app showAll
        
You can replace locally on the cluster with palm 
        alias ncm="$PWD/palm"
