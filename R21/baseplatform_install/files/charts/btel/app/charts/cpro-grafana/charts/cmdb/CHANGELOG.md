# Changelog
All notable changes to chart **cmdb** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.
## [Unreleased]

## [7.12.2] - 2020-09-11
### Fixed
- Add tests/values-compat.yaml to ensure values-compat rendered before tests
- Fix values-compat for services.mysql.sessionAffinity
- Need to add values-compat for brhook values

## [7.12.1] - 2020-09-09
### Fixed
- CSFS-28232: keystore_server errors in simplex deployment once/sec
- containerNamePrefix cannot apply to cbura-sidecar container name
- CSFS-28277: CMDB install fails with error in BrPolicy in OpenShift with AspenMesh 1.4.6
- CSFS-28420: database access test failed if Values.global.podNamePrefix is set
- BrPolicy name must be same as mariadb statefulset with podNamePrefix
### Changed
- Implement pod/container name prefix in helm tests
- Implement full job/container name supprt in NCMS hooks heal/restore

## [7.12.0] - 2020-08-31
### Fixed
- CSFS-27891: Streamline pre_stop admin pod tasks to be as fast as possible
### Changed
- pre/post job timeouts moved from admin to hooks section
- pre/post backup/restore timeouts moved from admin to cbur section
- must default terminationGracePeriodSeconds for admin pre_stop to 120 (from 30)
### Added
- CSFOSDB-2541: Add support to add prefix to pod names and container names
- Addition control over hook job/container creation an naming
- CSFS-26575: Add DB name from original server audit log to data.object field
- CSFOSDB-2457: Support Customization of logrotate parameters
- Handle SIGTERM in admin container using terminationGracePeriodSeconds
- CSFS-28112: Support cbur.autoUpdateCron configuration

## [7.11.2] - 2020-08-14
### Fixed
- CSFS-27629: Internal replication needs to use repl_use_ssl vs use_tls
### Changed
- global.istioVersion must be supplied for installing into istio environment
### Added
- CSFOSDB-2541: CMDB policy objects to support istio 1.4 and 1.5

## [7.11.1] - 2020-08-12
### Fixed
- Additional arbitrary UID fixes
- helm upgrade broken from pre-7.5 chart versions
- CSFS-27438: Invalid spec configuration for PeerAuthentication

## [7.11.0] - 2020-07-31
### Fixed
- mariabackup SST method does not work in container environment
### Changed
- CSFS-26017: Specify delete policy for all CMDB Helm tests
- CSFOSDB-2505: Upgrade admin container to kubernetes 1.17.9
- CSFS-26157: enhance mdb_show_tables to ignore missing table entires
### Added
- CSFOSDB-2499: Support newer istio-1.6 security.istio.io API
- CSFOSDB-2411: Added Openshift arbitraty UID support
- CSFOSDB-2140: Support TLS/SSL for Galera IST/SST replication
- CSFOSDB-2389: Comprehensive support for Grafana dashboards for CMDB

## [7.10.3] - 2020-07-13
### Fixed
- CSFS-25673: Fix scenario where restoring an earlier backup (not the latest)
- CSFS-26157: enhance mdb_show_tables to ignore missing database entires
- CSFS-23497: provide default cert-manager DNS enrty
- CSFS-26188: CMDB Chart 7.10.2 installation fails for ISTIO enabled
- CSFS-25094: CMDB Metrics integration with Prometheus is not working

## [7.10.2] - 2020-06-30 
### Fixed
- CSFS-24867: Cannot restore CMDB from 19.06 on a 20.03 BCMT env
- CSFS-25282: Istio sidecars injection works autoInject: false
- Heal event uses istio rbac when istio is enabled
- CSFS-25445: When using helm 2.16.8, cmdb install failed due to template issue
- CSFS-25545: admin job container exiting too quickly in istio may leave istio-proxy running
- CSFOSDB-2397: failed auto-heal can leave auto-heal delayed indefinitely
- CSFS-25621: Remove spaces in hooks.deletePolicy for BrHooks
- CSFS-25102: Enable maxscale with start slave does not start the slave process
### Added
- Support for configuration of the k8s cluster domain (cluster.local)
- CSFS-23077: Ability to pass a serviceAccount disabling creation of RBAC Resources
- securityContext added to all jobs
- admin-statefulset preStop script to SAVE database to disk
- CSFOSDB-2375: Support for auto-rebuild of failed master to slave if replication broken
### Changed
- CSFOSDB-2402: Use dedicated maxscale_exporter built product
- CSFOSDB-2410: Upgrade redis.io to 5.0.9
- CSFS-25741: Add checks for mariabackup errors
- CSFOSDB-2401: update mariadb_convert with nochas option
- CSFOSDB-2424: admin pod should persist to disk periodically

## [7.10.1] - 2020-05-31
### Fixed
- CSFS-24705: fail to run helm upgrade with cmdb in an umbrella chart when istio is enabled
- Need to wait_istio_proxy before running any kubectl commands in docker-entrypoint
### Added
- CSFOSDB-2346: Support cbur.ignoreFileChanged parameter in CMDB chart
- CSFOSDB-2163: CMDB Support for CBUR Backup and Restore Hooks
- CSFOSDB-2313: Support mysql service sessionAffinity
### Changed
- Upgrade MariaDB to MariaDB-10.3.23 (CVE fixes)
- Upgrade MaxScale to maxscale-2.3.19
- CSFOSDB-2348: Add X509v3 extensions: client+server auth

## [7.9.4] - 2020-05-12
### Added
- CSFOSDB-2348: Support for cert-manager version cert-manager.io/v1alpha2

## [7.9.3] - 2020-05-12
### Fixed
- CSFOSDB-2345: pre-install job failure with cmdb-7.9.2 chart

## [7.9.2] - 2020-05-08
### Fixed
- CSFOSDB-2330: Maxscale leader-elector container restarts twice during install in istio
### Added
- Istio support for helm tests
- Support for auto-heal on loss of galera quorum
### Changed
- CSFOSDB-2332: Enhance story CSFS-22503 to include the encrypt_binlog parameter

## [7.9.1] - 2020-05-04
### Fixed
- CSFOSDB-2328: Labeling of mariadb-master pod in istio environment not working
- CSFOSDB-2329: admin pod restarts when job completes in istio

## [7.9.0] - 2020-04-29
### Fixed
- Fixed maxscale docker-helper for broken scale
- Remove CLUSTER_SIZE environment variable from maxscaleinit-keystore
- CSFS-23273: mariadb tcp-socket liveness probe noisy
### Added
- CSFS-21678: CMDB: Helm Port Istio-Style Formatting
- CSFOSDB-1343: Istio support for CMDB
- CSFOSDB-2204: Manage MariaDB core files
- CSFS-22503: Data-At-Rest CMDB encryption support
- CSFOSDB-2236: Selective backup of CMDB tables
- Pass ISTIO_ENABLED to jobs to request istio-proxy sidecar stop after complete

## [7.8.2] - 2020-04-07
### Fixed
- CSFS-22791: Don't remove database_users.json until after processed

## [7.8.1] - 2020-04-03
### Fixed
- CSFS-22200: Fix for B/R of colocated datacenter config

## [7.8.0] - 2020-03-27
### Fixed
- CSFS-22079: helm restore with jobhookenable must force heal
- CSFS-22216: thread leak in mariadb_auditmon
### Changed
- Move admin-base docker iamge and tools to CSF-OSDB repo
- CSFOSDB-2184: Remove MariaDB from CMDB log messages
- upgrade flexlog and crypto-keyring to latest versions
- change MY_POD_NAMESPACE to K8S_NAMESPACE in maxscale statefulset

## [7.7.2] - 2020-03-09
### Fixed
- CSFS-22082: mariadb_lib failed to find server list

## [7.7.1] - 2020-03-04
### Fixed
- Install of simplex still requires that mariadb.count be set to 1
- CSFS-21813: mariadb_db_backup tool needs to capture firewall state from stderr

## [7.7.0] - 2020-02-28
### Fixed
- CSFS-20729: pre-delete will attempt to use admin contain but bypass if necessary
- CSFS-21510: Galera pods may not come up after heal, auto-heal or restore
- Galera restore needs to force heal operation
- Simplex deployment will not updatecfg on every helm upgrade
### Added
- CSFS-20748: Cluster heal will do minimum necessary (or nothing) to fix cluster
- CSFOSDB-2030: Automatically generated cert-manager certificates
- CSFOSD-2162: Support for Chart migrations and upgrade rollback (helm rollback)
### Changed
- CSFS-20774: Default mariadb nodeAffinity to disabled (not is_worker)
- leader-elector sidecar upgraded to 4.6-1.15
- upgrade MaxScale to maxscale-2.3.17

## [7.6.1] - 2020-02-05
### Fixed
- CSFOSDB-2116: maxscale cmdbadmin user must be created as admin user

## [7.6.0] - 2020-01-30
### Added
- CSFS-19923: Add option to annotate statefulsets on configuration update
- quorum_wait_time added to specify additional time to wait after quorum reached
- CSFS-12486: Support auto-heal for galera cluster
- Audit MARIADB-MASTER labels for mariadb pods
### Fixed
- CSFS-16110: Add base64 password requirement to deployment form
- Fixed maxscale exporter scrape address to localhost:8003
- Upgrade maxscale_exporter to work with maxscale-2.3
- CSFS-19483: Perf-test: metrics container of cmdb crashed and does not come up
### Changed
- Change mariadb liveness probe to attempt socket connection to localhost:3306
- Change mariadb liveness probe to succeed until bootstrap complete

## [7.5.3] - 2020-01-02 
### Changed
- updated admin-base base image to v1.14.10-nano for vulnerabilities
- updated other base images to 7.7-20191216 for vulnerabilities

## [7.5.2] - 2019-12-31
### Fixed
- maxscale pod can pull passwords from mariadb before build-in password import
### Added
- add apiVersion to Chart.yaml
### Changed
- Changed deprecated StatefulSet API apps/v1beta1 to apps/v1

## [7.5.1] - 2019-12-04
### Fixed
- Admin container needs permission to get statefulset status
- Do not run update-config helper in pods if statefulset is in rolling update
- Do not run update-config helper in galera if would result in loss of quarum

## [7.5.0] - 2019-11-27
### Changed
- Add authentication to admin container for redis.io password authentication
- Add ability to have a job request pre-emption of job in progress (pre-delete)
- CSFOSDB-1903: Support a 2nd CA for cert-manager objects
- CSFOSDB-1875: Support for galera in pure IPv6 environment

## [7.4.5] - 2019-11-06
### Changed
- CSFS-17953: Add before-hook-creation to default hooks deletePolicy

## [7.4.4] - 2019-11-04
### Changed
- update for mariadb-tools-4.9-5

## [7.4.3] - 2019-11-01
### Changed
- updated for centos-nano:7.7 and kubectl:v1.14.7 docker base images

## [7.4.2] - 2019-10-31
### Changed
- updated for CMDB 4.12-1 19.10 final release (BVNF 19.08)

## [7.4.1] - 2019-10-30
### Fixed
- CSFS-17703: New variable to mysql_site_conf (values.yaml) --> helm upgrade --> cmdb pod is not updated

## [7.4.0] - 2019-10-24
### Added
- CSFOSDB-1658: CMDB support for common audit logging framework

## [7.3.3] - 2019-10-23
### Changed
- updated for CMDB 4.11-3 19.09.2 release 

## [7.3.2] - 2019-10-18
### Changed
- leader-elector container moved to CSF-OSDB repo
- updated for CMDB 4.11-2 19.09.1 release  

## [7.3.1] - 2019-09-30
### Fixed
- values-compat.yaml merging boolean true values must check for value exists
### Changed
- mariadb_recover to handle SSH failures

## [7.3.0] - 2019-09-26
### Fixed
- Problem with scale-out of mariadb pods in maxscale environment
### Added
- Support nodeSelector and tolerations (default empty) in all statefulsets
- Perform pre-install checks of topology and node counts (eg. galera < 3 nodes)
- CSFOSDB-1708: Verify CBUR restore of a DC with backup from the remote DC
### Changed
- Auto-generate helm chart files for easier deployment/management
- Added configurable registry and image tags to ComPaaS values-model.yaml
- CSFS-15382: Maxscale readiness probe won't return ready unless Master exists
- Upgrade redis.io to version 5.0.5

## [7.2.0] - 2019-08-28
### Fixed
- CSFS-15830: post-upgrade of simplex deploy fails on chart upgrade
- CSFS-15349: Restore backup prior to mysqld_exporter user password change breaks metrics
### Changed
- Upgrade MariaDB to 10.3.17-1
- Upgrade maxscale to maxscale-2.3
- CSFS-15049: heuristic_recover defaults to rollback for non-simplex, none for simplex
### Added
- Add INSTALLED_CLUSTER_TYPE to mariadb-cluster-configmap for test container
- CSFOSDB-1311: Support replication SSL via repl_use_ssl value

## [7.1.0] - 2019-07-31
### Fixed
- maxscale leader-elector and exporter compatibility with BCMT 19.06
- support static mariadb-master-remote service IP assignment
- maxscale leader-elector registry incorrect for new leader-elector
- allow standalone in pre-migrate job and delete existing admin-deploy cm first
### Added
- CSFOSDB-1511: ncms pre/post restore hooks for maxscale
- Support for configuration of CLEAN_LOG_INTERVAL in chart
### Changed
- Upgrade MariaDB to MariaDB-10.3.16 and include MariaDB-cracklib-password-check

## [7.0.3] - 2019-06-26
### Fixed
- Fixed remote services to support IPv6 addresses
- CBUR backups fail due to security context on cbur sidecar container
### Added
- CSFOSDB-1620: Support for IPv6 and dual stack for external CMDB interfaces
- Support dual-stack installation, preferring IPv6 over IPv4

## [7.0.1] - 2019-06-14
### Fixed
- CSFS-13714: BCMT 19.06 compatibility removed optional on volumeMounts
- CSFS-14010: maxscale_exporter registry incorrect in default case
- CSFS-14072: CMDB upgrade from 7.0.0 to 7.0.0 fails (simplex)

## [7.0.0] - 2019-05-28
### Added
- CSFOSDB-1538: Parameterize CBUR configurations for MariaDB (NNEO-621)
- added admin pod to run small redis.io DB and run jobs
- CSFS-13159: Support nodePort assignments for mysql, mariadb-master, maxscale services
- CSFS-13072: Can't Turn off Node Affinity with values.yaml override
- CSFOSDB-1445: Support for maxscale-exporter sidecar for maxscale pod
- allow the mysqld_exporter port to be configured
### Changed
- Eliminate dependence on CSDC by running admin container as daemon
- cluster_type=simplex will force mariadb replica count to 1
- Upgrade to MariaDB-10.3.15 and maxscale-2.2.21
- changed maxscale readiness probe back to check-sanity

## [6.7.0] - 2019-04-30
### Fixed
- Force simplex to not use SDC even if etcd.client exists
### Added
- terminationGracePeriodSeconds can be configured for mariadb/maxscale pods
- add maxscale.listener.rwSplit to all configuration of default rwSplit service

## [6.6.4] - 2019-04-12
### Changed
- Updated to include CMDB 4.6-3 changes

## [6.6.3] - 2019-04-10
### Fixed
- CSFS-11850: Part 2 - helm restore for cluster-type galera (CSFOSDB-1143)

## [6.6.2] - 2019-04-10
### Fixed
- CSFS-11850: helm restore for cluster-type galera (CSFOSDB-1143)

## [6.6.1] - 2019-04-04
### Fixed
- CSFS-12061: maxscale_master_listener error in ComPaaS
- CSFS-11853: install in compaas fails due to missing resource requests/limits
- CSFS-11736: CMDB chart values-template renders empty strings into nulls instead of omitting them
### Changed
- Always create maxscale service if maxscale nodes exist (mariadb preStop)
- Make mariadb preStop master-switchover timeout tunable

## [6.6.0] - 2019-03-29
### Added
- Support for BCMT heal plugin
- IPv4 and IPv6 localhost addresses for exporter user
- Support for configuration of maxscale Master-Only service
- Support for configuration of RO-Service and Master-Service ports
- Support preStop hook in mariadb-statefulset to switchover master
- Helm tests for basic Maxscale verification
- Helm test for multi-DC replication verification
- Helm test for metrics verification
- Helm test for cmdbadmin database
- Pre-Upgrade Job to move metrics credentials from secret to keystore
- Added wait based on container status when SDC not used
### Changed
- Default csdc.enabled to true (from false) in ComPaaS
- Upgrade CSDC requirement to 2.0.29
- Upgrade to maxscale-2.2.20
- MaxScale readiness probe changed to attempt to connect to DB via 3306 port
- Upgrade CMDB images to 4.6-0
- Change exporter container to allow time for env file to be available and restart
- Update metrics-shared emptyDir to be memory-based
### Fixed
- Helm upgrade of galera cluster sometimes terminates all pods
- Post-install on simplex waits for pod to be ready

## [6.5.1] - 2019-03-03
### Fixed
- Fixed scaled-out nodes from using default passwords

## [6.5.0] - 2019-03-01
### Added
- values-compat template to support settings default values on upgrades
- values-image-version-check template to support minimum image version requirements
- maxscale init container to copy keystore from mariadb pod
- password change support
- initial set of basic helm test cases
### Changed
- upgrade to mariadb-10.3.13
- upgrade to maxscale-2.2.19
- upgrade admin-base image to support kubectl:v1.12.3
- upgrade to mysqld-exporter:v0.11.0
- provide a method to disable individual jobs from running
- Moved database_users to a hook-generated temporary configmap
- Removed persistence.enabled values since always required
### Fixed
- Fixed typo in maxscale-secrets which ignores maxscale user password in values

## [6.4.3] - 2019-02-07
### Fixed
- pre-install hook more selective on checking for existing PVCs

## [6.4.2] - 2019-02-05
### Changed
- Moved build of cmdb Helm chart to CSF-MARIADB repo/pipeline

## [6.4.1] - 2019-02-04
### Fixed
- Simplex post-install fails with exception

## [6.4.0] - 2019-01-31
### Fixed
- Fixed attribute mis-spelling in mariadb-statefulset
- Fixed RBAC hook weights so resources created in order

## [6.3.2] - 2019-01-24
### Changed
- Modified RBAC definition to be more selective for enhanced ComPaaS security
- Upgraded CSDC requirement to 2.0.3

## [6.3.1] - 2018-12-21
### Fixed
- Simplify metrics service management so works in MaxScale environment also

## [6.3.0] - 2018-12-19
### Added
- Allow nodeAffinity rules to be set for both mariadb and maxscale statefulsets
- Default set maxscale query_retries and query_retry_timeout
- Allow maxctrl to be configured for external access on port 8989
- Add optional maxctrl service that will follow leader maxscale pod
### Changed
- MaxScale upgraded to maxscale-2.2.18
- MaxScale pods will by default run on edge nodes to enhance HA
- Added limits to both mariadb and maxscale pods in BCMT environment
- Run mysql_upgrade on all upgrades/downgrades

## [6.2.1] - 2018-12-07
### Added
- Allow metrics and dashboard to be enabled via ComPaaS
### Changed
- Remove delete of CSDC PVC on terminate since CSDC-1.0.48 chart fixed issue
### Fixed
- audit_logging options not working in ComPaaS

## [6.2.0] - 2018-11-30
### Added
- Added admin.quickInstall flag to allow for faster deployment if needed
- Create dashboards configmap with MySQL_Overview.json dashboard if enabled
### Changed
- Upgraded MariaDB to MariaDB-10.2.11
- Upgraded CSDC requirement to 1.0.48
### Fixed
- Fix ComPaaS Rendered Template Check issue
- Produce chart render error if database name contains hyphen character

## [6.1.3] - 2018-11-12
### Fixed
- Adding metrics user causes password assignment failure

## [6.1.2] - 2018-10-31
### Fixed
- Updated CMDB to 4.1-3 which resolves logging in BVNF environments

## [6.1.1] - 2018-10-30
### Fixed
- MaxScale will not come up in ComPaaS
- CSDC chart embedded enable flag not set correctly in ComPaaS
- pre-install job must not require SDC if being deployed as sub-chart

## [6.1.0] - 2018-10-29
### Added
- CSFS-7099: Support WITH GRANT OPTION via deploy.yaml for non-root users
- CSFOSDB-1107: Enable non-performance impacting audits by default
- Enhance galera to do auto-heal when deploying with existing PVCs
### Changed
- auto_rollback changed to heuristic_recover={rollback|commit|none}
- Default storageClass size for ComPaaS change to 5Gi (from 20Gi)
- max_node_wait changed from default 15 to 5 minutes
- mariadb readiness and livliness probe configurations changed
- updated CSDC chart to csdc-1.0.40
### Fixed
- Fixed statefulset storageClass definitions
- Add RBAC rule for MaxScale leader-elector container to manage endpoints
- pre-delete job should not require SDC

## [6.0.3] - 2018-10-10
### Fixed
- missing users.requires allowing user to specify REQUIRES SSL/X509 for user
- CSFS-7465: Please clean up older backup files first before 'helm backup'

## [6.0.2] - 2018-10-04
### Added
- Add CSDC chart requirement to optionally deploy CSDC chart with CMDB
### Changed
- Remove CSDC/etcd dependency for simplex deployments (does not require CSDC)
- CBUR can use either datadir/backup directory or additional backup volume
- Default to auto-generated password for repl_user and maxscale_user if not set (not hardcoded)
### Fixed
- INFO broken about how to deploy mariadb client pod
- don't generate repl@b.c in database_users.json unless mariadb.count > 1
- remove pre-install hook-delete-policy hook-succeeded
- ComPaaS environment change all passwords to 'password' type on GUI

## [6.0.0] - 2018-09-28
### Added
- Added support for HA (multiple) maxscale pods
- Integration of CBUR for helm driven backup/restore support
- Support second PVC for MariaDB backups
- Support MariaDB 10.3.9 and MaxScale 2.2.13
- Support TLS with MaxScale northbound and southbound
- Support import of CA certificates for SSL
### Changed
- image information (name/tag/pullPolicy) consistency
- default storageClass is not not set to use kubernetes default
- support CSDC with TLS enabled
### Fixed
- All containers must have request/limts defined for ComPaaS 18.08

## [5.0.4] - 2018-09-25
### Fixed
- CSFS-7236: parameter values were not updated after helm upgrade

## [5.0.3] - 2018-09-17
### Fixed
- added CSDC dependency requirement to README.md
- post-delete job will not fail if SDC access fails
- install with PSP/RBAC disabled fails
### Changed
- user must specify "requires: SSL" (or not) when users created

## [5.0.2] - 2018-09-07
### Fixed
- Remove chart version from labels
- add selector label to statefulsets

## [5.0.1] - 2018-09-07
### Added
- CSFS-5141: Follow standardized template naming rules
### Fixed
- Fix issue with roles, rolebindings not being deleted on terminate
- Fixed metrics registry relocation issue
### Changed
- Delete jobs back to post-delete hook
- Support 3.6-2 release MariaDB 10.2.17

## [5.0.0] - 2018-08-28
### Added
- PSP/RBAC support
- Delete jobs in pre-delete hook
- Add TLS support for MariaDB
- CSF chart relocation rules enforced

## [4.3.2] - 2018-08-06
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

