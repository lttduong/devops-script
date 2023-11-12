# Changelog
All notable changes to chart **ckey** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.


## [8.11.0] - 2020-08-14
### Added
- Added support for custom ingress web-context paths.
- Added brPolicy config parameter ignoreFileChanged, cronSpec and brMaxiCopy
- Add PeerAuthentication/Policy mTLS mode configuration for Istio configuration
### Changed
- FOSS Keycloak upgraded to version 11.0.0
- Upgrade version of UMLite GUI
- Configurable certificate expiry alarm period
- Improved start time of post-install master realm configuration job
- Fix clustering issue in Istio enabled environment with REGISTRY_ONLY outboundTrafficPolicy
- Fix Helm restore hanging on PostRestore hook
- Force CKEY secret to be redeployed when Helm upgrade is triggered

## [8.10.28] - 2020-07-16
### Changed
- Feature to support SMP usecase for SaaS (DS RBAC - Customer contribution)
- Fix KEYCLOAK_IP not matching exactly with Keycloak service IP in configure-realm.sh
- Allow CKEY Helm Chart to customize DNS domain
- Upgrade CMDB dependency version to 7.10.3 to fix Helm upgrade/scale issue in Istio enabled environment
- Secure ingress sticky session cookie 'route'
- Remove fsGroup from securityContext
- Remove sensitive environment variables and mount them all into secret
- kubectl container used in jobs upgraded to v1.17.6-nano
- Add addtional RBAC rule to allow security hardening init container run as root
- Change certificates mounting procedure for security hardening
- Fix external database address with extra port in Helm chart
### Added
- Allow Istio to bind to existing Gateway/Hosts and configure TLS mode

## [8.10.12] - 2020-06-18
### Added
- Added support for external RBAC account
- Let users specify any number of labels for istio ingress gateway configuration.
### Changed
- Use a single service account for all the jobs
- Upgrade version of umlite image to address security vulnerabilities in serialize-javascript package
- nodeAffinity rule with BCMT label is_worker is disabled by default
- Remove metrics-exporter-registry.json config to allow Metrics Event Listener to listen to all event actions when enabled
- Eleminate init containers to allow ckey deploy when istio cni is enabled.
- Change cmdb chart version to 7.9.7 which contains a fix related to helm upgrade and helm backup/restore.

## [8.10.1] - 2020-05-14
### Added
- CBUR post-restore job to restart CKEY pods automatically
- Automatically backup restore CKEY secret by CBUR
- Supports istio - psp, sidecard injection, a sample istio ingress gateway configuration, destination rules
- Support for loading custom extensions: custom providers, themes
### Changed
- FOSS Keycloak upgraded to version 10.0.1
- Update Lite User Interface version

## [8.9.4] - 2020-04-16
### Changed
- RBAC fixes: Scope Mapping disassociation and not listing account-console client
- Version of depended CMDB changed to 7.7.0
### Added
- Basic Istio support

## [8.9.0] - 2020-03-15
### Changed
- FOSS Keycloak upgraded to version 9.0.0
- Changed port names to match Istio formatting
- Replaced 'Keycloak' trademark in Admin GUI
- Custom configuration script moved from config map to values.yaml. Removed parameter overrideEntryPoint from values.yaml.
- Updated old kubernetes API versions
- Version on depended CMDB changed to 7.6.0
### Added
- Tolerations configuration

## [8.8.11] - 2020-02-25
### Changed
- Fix master realm config job for ipv6

## [8.8.10] - 2020-02-20
### Added
- Added Prometheus annotations
- Added configuration for Health Check port
- Master realm configuration job fix for custom TLS certificate
- Added configuration for Generic Event Listener registry
- RBAC - Client role creation for authentication disabled client
### Removed
- Removed notification-interface sample file

## [8.8.0] - 2020-01-17
### Added
- FOSS Keycloak upgraded to version 8.0.1

## [8.7.6] - 2019-12-12
### Added
- Changed master realm job to https compatibility
- Fixed master realm job err handling
- Make chart compatible with IPv6 BCMT. Added new parameter ipType.
- CMDB dependency updated to latest version
- Default initial delay for liveness probe increased to 600 sec, for readiness probe descreased to 180 sec

## [8.7.0] - 2019-11-14
### Added
- New value added to values.yaml to set cors header
- New value added to values.yaml file to make binding ip configurable
- Fixed syntax error in rbac.yaml,post-heal and pre-heal to make heal working
- Fix helm upgrade by removing service accounts from hooks
- Allow special character in admin password
- Changing RBAC Light UI version

## [8.6.0] - 2019-10-17
### Changed
- Changed master realm job running condition to only INSTALL and added pre upgrade hook
- In keycloak chart missing configmap metrics-exporter-registry.yaml
- Handling empty scope mapping and adding resource for UMLite
- Added fullnameOverride and nameOverride parameter for fixed service name since it required for profile deployment in swordfish envrionment
- RBAC adding custom claims to access, userinfo, openid token
- Delete all pvc by default on helm delete

## [8.5.7] - 2019-09-26
### Changed
- CSFS-15099, CSFID-2449: Added Custom Role Based Access Control and User Light GUI
- CSFSEC-2990: Updated Ingress annotations

## [8.5.5] - 2019-09-13
### Changed
- Added error handling for master realm config job

## [8.5.2] - 2019-08-16
### Changed
- The messages in the CKEY login banner (if enabled) are now customizable. For more information on how to enable the CKEY login banner, please consult our user guide. The customizable messages will be applied to the login banner in the new 6.0.1-1 CKEY docker image.
- Error handling for helm master realm config

## [8.5.0] - 2019-07-18
### Changed
- Upgraded the CKEY version to 6.0.1-0
- Added a new log configuration for a periodic size logger.

## [8.4.1] - 2019-07-05
### Changed
- Upgraded the kubectl image to v1.14.3-nano
- Upgraded the cbur/cbura image to version 1.0.3-983

## [8.4.0] - 2019-07-04
### Changed
- Upgraded the CMDB helm chart dependency to version 7.0.3
- Removed fsgroup entry from the CBUR container inside the statefulset resource.

## [8.3.3] - 2019-06-24
### Changed
- Upgraded the CKEY version to 6.0.0-1

## [8.3.2] - 2019-06-06
### Changed
- Modified pre-delete script to fix syntax error.

## [8.3.1] - 2019-05-24
### Changed
### Added
- Upgraded the CKEY version to 6.0.0-0
- Changed the default allowed TLS Cipher Suite to TLSv1.2 If you want to enable other cipher suites, please configure the tlsVersionList environment variable as per your requirements.

## [8.3.0] - 2019-05-01
### Changed
### Added
- Added custom attributes configuration through values.yaml

## [8.2.0] - 2019-04-12
### Added
- Added push event notification configuration through values.yaml.
### Changed
- Upgraded the CKEY version to 5.0.0-0
- Changed name of realm-configuration-job to master-realm-configuration-job.
- Added the notUsername password policy to the existing list of password policies that are set in the realm configuration job.

## [8.1.7] - 2019-03-25
### Added
- Added configurable timeout and period seconds for the liveness and readiness probes. The default timeout for the liveness probe is not set to 5 seconds.

## [8.1.6] - 2019-03-15
### Changed
- Upgraded the CKEY version to 4.8.3-1.

## [8.1.5] - 2019-03-15
### Fixed
- Re-introduced SHARED label for compatiblity of ComPaaS 19.01 versions

## [8.1.4] - 2019-03-07
### Fixed
- Removed dash from  host in ingress files

## [8.1.3] - 2019-03-01
### Fixed
- SVC_SCOPE has been fixed

## [8.1.2] - 2019-02-26
### Added
- Added a new ingress-management.yaml file for JBoss management console. This will allow HTTPS connections to keycloak service on port 8443 and HTTP connections to JBoss mananement console on port 9990.
- Added dbAddress variable to values.yaml which needs to be set while deploying with external CMDB. This has replaced the old dbIP variable.
- Added dbPort variable to values.yaml which needs to be set while deploying with external CMDB.
### Removed
- Removed SHARED label from ckey chart.
- Removed dbFQDN variable from ckey chart.

## [8.1.0] - 2019-02-14
### Added
- Added an initContainer to wait for external CMDB to become ready before ckey deployment gets started.
- Added dbFQDN variable to values.yml file which need to be set while deploying with external CMDB.
- Added Node Affinity ruled for ckey so that pods are deployed only on the worker node.
### Changed
- Upgraded the CKEY version to 4.8.3-0.
- Upgraded the Kubectl version to v1.12.3.
- Upgraded the CMDB version to 6.4.3.
- Replaced ClusterRole and ClusterRoleBinding with Role and RoleBinding where applicable.
- Attributes that are related to the backup persistance in CMDB are now configurable on ComPaaS.
- Added an additional check to the backup volume mount in the statefulset.yaml file.
- The CMDB dependency no longer requires CSDC (for simplex deployments).
- Replaced the 'default' storage class with the empty String where applicable.
- This new version introduces changes to the CKEY statefulset and as a result, the 'helm upgrade' command will not be compatible if upgrading from an older version.
### Fixed
- Fixed an issue in the ingress specification that was causing the template not to render properly when a range of ingress hosts is specified.

## [7.0.2] - 2019-01-30
### Added
- Added a new if-end check to volumeClaimTemplates in statefulset.yaml so that it will not create volume claim if cbur is disabled.

## [7.0.1] - 2019-01-22
### Added
- Added a new variable that allows users to enable ingress for jboss management console on port 9990. This will allow JConsole to remotely connect to keycloak for remote monitoritng.

## [7.0.0] - 2018-12-17
### Added
- A new realm configuration job has been added. The job creates a kubectl client, waits for CKEY to be ready, and configures certain security settings in the CKEY master realm if the job is enabled. The script that runs in the new realm configuration job is available in the new custom realm configuration configmap.
- Added the ability to configure additional custom arguments that get passed on to the CKEY statefulset.
- Added service accounts that are specific to the pre-delete job and to the new realm configuration job.
- Added new variables that allow the user to mount a custom Java keystore and a custom Java client truststore. Users can now provide the passwords for the keystores that they want to import.
- Added new volume mount for custom CKEY scripts.
### Changed
- Made small adjustments to the waiting times in the CKEY init containers.
- Modified default admin password from 'admin' to 'Admin123!' to comply with the new password policies.
- Upgraded the CKEY docker image to 4.5.0-3

## [6.1.0] - 2018-11-23
### Added
- Added support for backup and restore for CKEY.
### Changed
- Upgraded CKEY docker image to 4.5.0-2.

## [6.0.5] - 2018-11-16
### Changed
- The Keycloak default user credentials are now stored in a secret that has a pre-install hook annotation.
- Added a Keycloak pre-delete job to delete the secret that contains default user credentials.

## [6.0.4] - 2018-11-15
### Changed
- Added new boolean flag to determine whether the initial user should be created or not.

## [6.0.3] - 2018-10-25
### Changed
- Update CKEY docker image to 4.5.0-1.

## [6.0.2] - 2018-10-15
### Changed
- Heal events implemented for ckey

## [6.0.1] - 2018-10-11
### Changed
- CKEY now uses CMDB 6.0.3.
- The 'requires' field (for SSL and X509) is now configurable for DB users.

## [6.0.0] - 2018-10-05
### Changed
- The CKEY docker image now uses keycloak 4.4.0 and supports MariaDB versions that are larger 10.3.
- Updated the CMDB chart in requirements.yaml to 6.0.0.
### Added
- Users can now add SSL certificates for CMDB into CKEY.

## [5.0.4] - 2018-09-27
### Changed
- Made the initial delays for the readiness and liveness probes configurable.

## [5.0.3] - 2018-09-25
### Added
- Users can now add a trusted LDAPS certificate into CKEY.

## [5.0.2] - 2018-09-18
### Fixed
- Fixed the CKEY image reference in the values-template.j2.yaml file.

## [5.0.1] - 2018-08-31
### Changed
- Minor fix the the CHANGELOG.

## [5.0.0] - 2018-08-31
### Changed
- CKEY now uses a "Statefulset", as opposed to a "Deployment".
- Added an additional headless service for the CKEY statefulset.
- Added an initContainer to have CKEY wait for the CMDB container to be ready, the initContainer takes place if cmdb.enabled is set to true.
- CKEY now uses the new docker image from the 18.8 release. The current version is based on Keycloak 4.2.1.
### Security
- Added securityContext configurations to the helm chart. The helm chart can now be deployed as non-root user.
- The utilized CKEY docker image now runs as a "keycloak" user, with user ID 1000.

## [4.0.3] - 2018-08-28
### Changed
- Made the servicePort configurable in the ingress.yaml file. Users can now choose which Keycloak service port they would like to configure with ingress.

## [4.0.2] - 2018-08-16
### Fixed
- Made a small change to the ingress.yaml file. The ingress configuration now points to httpProxy.

## [4.0.1] - 2018-08-07
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
