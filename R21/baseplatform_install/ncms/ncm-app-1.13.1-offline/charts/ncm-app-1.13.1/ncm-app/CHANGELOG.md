# Changelog
All notable changes to chart **ncms-app** are documented in this file,
which is effectively a **Release Note** and readable by customers.


## [1.13.1] 2021-01-07

### Fixed
- false positive issues when interpreting inprogress backup/restore (CSFS-32548)
- autonomous mode: change PVC creation in pre-hook to avoid PVC deletion and support PVC deletion by deletePVC

### Added
- support of helm 2.17 and helm affinity with helm tiller (CSFP4-2264)
- security fix new image (centos VNE)

### Changed
- don't apply multitenancy filter for anonymous / unsecure 

## [1.13.0] 2020-12-18

### Fixed
- fix helm3 pending state in profile status (CSFP4-2376)
- configurable alogrithm to validate k8s tokens. fix feature interaction when secure with multitenancy modes (CSFP4-2360)
- support of selinux on hosted volumes (fix plugins copying and emulating helm init for project) (CSFP4-2307)
- turn profile status to FAILED whenever error is detected (CSFP4-2263)
- ncmtpl fix for smart upgrade (CSFP4-2305)
- support of app migrateServer to the hybrid helm and multitenant env (CSFP4-2074)
- fixes profile revision when rollback helm3 to helm2 (CSFP4-2254)
- API: missing project support to p values and p manifest (CSFP4-2200)
- helm repo certificates files were  not persistent in autonomous mode (CSFP4-2202)
- allow support of helm repo certificates file from multiple secure repositories (CSFP4-2203)
- fix regression since --monitoredBy 1.12.4, ncm -o json p status leads to NPE on asynchronous activity
- security VNEs for java libraries

### Added
- helm 3.4.2
- plugins update (1.0.7 allimages, 0.7.0 for 2to3)
- support for ncs multitenancy model (NCS-235, CSFS-31577)
- support of chart finding huge optimization, ranking, and consistency when multiple chart matching (CSFP4-2292)
- obfuscate helm command when password (CSFP4-2374)
- failureThreshold parameter to extend the probes (3 attempts by default, that leads to around 30s for liveness)
- allow secure on for eks (CSFP4-2335) 
- support of waitFor for terminate event (Profile 1.3, CSFP4-2145)
- support of priority class (NCS-37, CSFS-31510)
- support of profile rollback from helm3 to 2 (CSFP4-2156)
- allow support of ingress class for testing (CSFP4-2296
- API 1.10.1
- * ncm onboard --helmDryrun --failsOnError (CSFP4-2031)
- * ncm p terminate --parallel (CSFP4-2266)
- * ncm app get --topic notes
- * add getPlugins for csfp internal usage (CSFP4-2257,CSFS-31582)
- * ncm app imagesFromArchives (turn to GET to POST to avoid proxy issues) (CSFS-29823)
- * ncm instantiate/upgrade --dry-run (CSFP4-2031)
- * ncm profile rollback --nowait , requires when rollback restart citm (CSFP4-2215)

### Changed
- consider Exception as FAILED by default in profile status (CSFP4-2376)
- allow compliancy helm2 backup with last plugin and old cbur (CSFP4-2369)
- cleanup when multiple plugins version and add env.PLUGINS_REINSTALL parameters (CSFP4-2348)
- template deploment.yaml : remove helm 2 init from init container
- remove docker client in ncm-app image
- ingress rules are scoped with a new parameter ingress.class (test is default to avoid unmanaged interactions)
- repo were not copied from local to autonomous
- repo certificates files are copied to XDG_DATA_HOME (CSFP4-2202)
- certManager.enabled no more required, automatic discovery of cert-manager for certificate management (order still the same : user provided>certmanager>selfsigned)
- new advanced configurable parameters (consult README for exhaustive list)

### Limitations
- ncs multitenancy model requires repositories to be added in the tenant space using "ncm repo add"

## [1.12.6] 2020-10-26
### Added
- revert back the condition check for project migration

### Limitations
- When upgrade ncm-app with the version, projects would be moved to XDG_DATA_HOME, rollback would not undo this change

## [1.12.5] 2020-10-23

### Fixed
- project migration for second upgrade
- ncm repo add error(mkdir plugins failed as file exists, CSFP4-2180)

## [1.12.4] 2020-10-21

### Added
- API 1.9.3
- helm 3.3.4 
- update plugins (heal,scale, 2to3)
- support of multi helm coresidency (CSFP4-1982)
- 3 helm binaries integrated within (CSFP4-1982)
- support of multitenancy model with helm3 (CSFP4-1723)
- support of Profile 1.2 (helm version defined by profile)
- new profile status --monitoredBy,--audit , progress events/logs( CSFP4-1525)
- add activity time on profile status (CSFP4-1525)
- new profile manifest display profile metadata (CSFP4-2124)
- new profile / app convert 
- app API transparently applies on helm2/helm3 
- new HELM header (version) in app list
- support of extended permissions for helm3 plugins (convert/backup) (env.PRIVILEGES_GROUP)
- support of helm binary black listing env.HELM_BLACKLIST to remove binary usage (i.e use 2 to prevent helm2 invocation)
- support of declarative lcm.convert.flags in profile (expert or advanced usage)
- helm3 multitenancy kubeconfig can be refreshed with env.CONFIG_REFRESH
- ncm repo update --resync (allow to resync helm2/helm3 profile repositories
- includes tiller for autonomous helm2 mode
- introduces 3 modes for MT access control (helm2 only , helm3 only, hybrid) (see env.MT_MODE)
- new app terminate --purgeHistoryOnly (advanced)

### Fixed
- fixes for 1.18.x hosted env compliancy (helmHostPath)
- fixes regression with k8s token control when env.SECURE is true (CSFS-29058)
- fix profile rollback with helm2 (CSFP4-2172)
- repo init with autonomous helm2 (CSFP4-2053)
- plugins visible with autonomous helm2 (CSFP4-2051)
- allows smart upgrade to work with profile archive (remove Profile/Chart.yaml from values) (CSFP4-2043)
- remove omnipresent "waitFor message" in profile status
- remove default stable from profile repository (to avoid listing chart from profile repository)
- helm3 support of backup/restore plugin with 20PP1 version of cbur (CSFP4-2165)
- helm3 support of profile upgrade with autoremove (CSFP4-1723)
- helm3 profile backup/restore status 
- helm3 list with json (wrong mapping and harden when appversion is empty)
- regression when flags is used with app history
- migration of projects during upgrade from 1.11.x
- clean logs when wrong ncs token is used over csfp


### Changed
- app showall : display relevant env, show new mtMode (for access control helm2,helm3 or helm2+helm3)
- harden the manner when async errors are captured
- cbur/app-api release are automatically converted to helm3 and keep sync until helm3 is favorite
- profile values returns empty when profile not yet instantiated (instead of 500) (CSFP4-2124)
- internal data are moved to XDG_DATA_HOME (profiles/projects) , use profile p manifest to read metadata
- deprecates app migrate, p migrate (replace by convert)
- deprecated profile values --revision with --previous (CSFP4-2124)
- plugins are synchronized on those delivered by ncm-app (can be mitigated on next RC)
- helm3 plugins directory is removed during self migration (avoid plugin reinstalling issue with helm3)
- helm3 repository listing for empty profile repository returns empty (and not 400 as helm3 behaves)

### Limitations
- rollback doesn't delete helm3 release (use app terminate --purgeHistoryOnly)
- new repo update --resync only applies on unsecure repositories
- app migrateServer is not operational in this version (next release), instead use declarative helm in profile or explicit p convert API

## [1.11.11] 2020-09-09
### Added
- Profile 1.1 (support for waitFor) (CSFID-2745)
- fix bug from migrateServer (CSFP4-2009)

### Fixed
- very last VNE (CSFPIE4-2021)
- migrate data for MT true (API 1.8.1)
- cert mount point
- allows smooth upgrade with new certManager structure change

### Changed
- change paths when ingress mode (mainly external REST usage) is enabled to support colocation with bcmt-api in 20.06 (CSFS-27365)
- notice that : the very old /ncms path is no more supported from that version, we disable useless redirect
- deprecates rootPath usage
- add post-delete hook for pvc in autonomous or persistence mode
- fix error of service account name in deployment when rbac enable
- fix error of dnsName value does not exist in certificate
- fix helmHostPath implementation (for native EKS) (CSFP4-2013)
- add /ncm/token in path for suite test
- migrate (autonomous is default)
- allows local-bin mounting in persistence mode

## [1.11.10] 2020-08-21
### Fixed
- add support of long chart name when guessing repo from search request (helm2 and helm3) (CSFS-27535)
- ncmHost template

### Added
- protect internal use of history request from abnormal message
- support external serviceAccountName
- support external secret for server certificate
- support embedded helm2 and tiller

### Changed
- change verbosity of the 403 namespace authorized
- introduce PARANOAIC_SECURE mode to keep opaque 403 message
- add generate certificate through secret with sprig

## [1.11.9] 2020-08-20
### Added
- allow processingPoolSize customization (CSFS-27709)
- add support of --devel in helm3 search (CSFS-27535)
- optimization against request flooding on long activity methods (CSFS-27709)

### Fixed
- fix typo when settting idleTimeout (CSFS-27709)
- exclude N-1 folders from JSON profile listing (CSFS-27709)

### Changed
- change default value for processingPoolSize to 10 (CSFP usage)
- set default http connection idleTimeout to 15mn

## [1.11.8] 2020-08-10
### Changed
- increase default memory request limits to 1Gi (to avoid OOM during full suite of test)

## [1.11.7] 2020-08-07
### Added
- update change certificate to pass helm test (CSFP4-1942)
- fix fixable high CVEs (CSFP4-1945)

### Changed
keystore is enabled to true. the certificate in the chart is used by default (when no cert manager) instead of old expired one.
this certificate is for domain localhost + endpoint.svc.cluster.local

## [1.11.6] 2020-08-06
### Fixed
- allow correct access control when MT=true for profiles ncm command (CSFP4-1910)
- correct the deprecated ingress path to be consistent "https://kubernetes.github.io/ingress-nginx/examples/rewrite/"
### Added
- protect against no closed TLS connection (issue with client using go/restly) (CSFS-25925)
- enhancements for 3rd party compliancy - imagePullSecrets can be set into values.yaml (CSFP4-1886)
- enhancements for 3rd party compliancy - hostNetwork can be set into values.yaml (CSFP4-1885)
### Changed
- this release fixes the access control in CSFP when using project with a NCS context instead of CSFP context for the endpoint "profiles".
403 will be returned in such context also for profiles command. Consequently this is expected from this version, everyone SHOULD use profiles endpoint instead of deprecated app "profiles" commands.

## [1.11.5] 2020-07-12
### Fixed
- provide profile repository automigration (CSFP4-1843)
- keep compatibility with old cli (<1.6.5) using location flag empty in profile onboard


## [1.11.4] 2020-07-03
### Fixed
- fix purging hooks resources algorithm (java.lang.ArrayIndexOutOfBoundsException: 0) (CSFP4-1827)
- fix unexpected stack trace in showAll when some values are set to true (CSFS-25765)

### Added
- complete helm best practices compliancy (add kubernetes. annotations)

### Changed
- purgeHooks algorithm is fixed and may lead to complete resource deletion when retry is detected during install

## [1.11.3] 2020-06-30
### Fixed
- mandatory fix for 20.06 (profile support when relocated helm home) (CSFP4-1732)
- harden liveness probe with timeout (CSFS-25925)

### Added
- support of ~version in app_list (CSFS-25991)
- migrateServer all or nothing helm3 migration strategy
- integrate kubectl for plugins in autonomous mode (CSFP4-1778)

### Changed
- api 1.7.8 (migrate apis only for dry-run migration) (CSFP4-1812)

## [1.11.2] 2020-06-25

### Fixed
- security recommendation (remove useless .py) (CSFP4-1810)
- fix repo add with files options in a multitenant env (required for harbor 1.0.38) (CSFS-25708)

### Added
- profile smart upgrade (CSFP4-1704)
- add helm test for cert manager

### Changed
- change ingress apiVersion for 1.8.x

## [1.11.1] 2020-06-18

### Fixed
- fix regresssion with multitenant operation due to defaul t HELM_HOME introduced in 1.11.0 (CSFP4-1799)
- fix onboard during upgrade with operator

### Changed
- allow operator mode with legacy endpoint
- remove source in Profile CRD

## [1.11.0] 2020-06-17

### Added
- add compliancy with k8s 1.18.x v1beta API removal (kubeval tests)
- add server certificate generation from cert-manager and values.yaml
- changes to be compliant with helm best practice
- add helmHostPath for helm home relocation for compliancy with NCM 20.06 (default is deduced from 1.18.x) (CSFP4-1732)
- support name/namespace relocation for ncm-app and cbur, fix helm test to support test on relocated release
- controller mode (beta, demo scope)
- persistence mode (for autonomous mode with cbur and migration)

### Fixed
- anchore vulnerabilities
- adapt crd spec to controller mode
- profile upgrade with autoremove/terminate don't analyze first release listed in helm list -a -q (CSFP4-1707)

### Changed
- powered with jdk11
- use of k8s api 8.0.0 and implemenent fix for merge PATCH (CSFP4-1702, https://github.com/kubernetes-client/java/issues/866)
- helm-dir mounted is removed from configurable mounted volume. This is mounted by default using the helmHostPath
or /root/.helm (bcmt <20.06>) or /opt/bcmt/storage/helm_home (bcmt > 20.06). For helm3 and native k8S setup, autonomous mode is the recommended configuration (no helm-dir). Autonomous mode is deduced when persistence is enabled.

## [1.10.4] - 2020-05-19

### Fixed
- exclude N-1 folders from profile listing (CSFS-24595)

## [1.10.3] - 2020-05-13
### Fixed
- support of profile repository for helm3 (CSFP4-1687)
### Changed
- ignore XDG values when starting autonomous mode

## [1.10.2] - 2020-05-12
### Added
- added support of profile repository with credentials, and name based onboard (CSFP4-1506)
- harden profile upgrade by supporting upgrade of profile setup with unreachable chart (like expired candidates) (CSFS-23973)

### Changed
- remove the trailing helm to the default XDG variables (autononous mode)
- delete helm_plugin_update option
- data migration from init container

## [1.10.1] - 2020-04-29

### Added
- support of multicontext (aka multicluster) in extra cluster mode (CSFP4-1622)
- semver2 enhancement, support for build+ (CSFP4-1623)
- add json format for app status and app history  (CCSP4-1530)
- change tolerations (CSFS-17074)

### Fixed
- fix precedency when data.tpl is released within profile archive (CSFP4-1621, CSFS-23744)
- fix semver2 control, support for chartname ending with number (CSFP4-1623)
- security fixes, protection against absolute related path, injection through id,profile flags (CSFS-21701,CSFS-21748,CSFS-23532,CSFS-21849)

### Changed
- add semantic check on id used for application/profile/repositories : [a-zA-Z0-9_-]+
- API 1.7.6
- ncmtpl 155
- helm test fix

## [1.10.0] - 2020-04-09

### Added
- extra cluster mode support (CSFP4-1538)
- support of autoremove with tags/skiptags (CCSP4-1477)
- add ncm app/profile migrate methods to helm3 (CSFP4-1360)
- support dry-run in ncm app instantiate (CSFS-21865)
- allows deletion of ncm-app instances on test namespace (testing purpose)(CSFP4-1582)
- integrate v3 plugins  (+ helm2to3) in helm3 standalone mode , N+1 aligned with 3.1.2 (CSFP4-1496)
- support of profile values (CSFID-2367) (API 1.7.3)
- dynamic cli download from server (ENDPOINT/ncm/bin/cli.gz)

### Fixed
- enhance support of customize.tpl  (CSFP4-1501)
- fix terminate with reverse order (CSFS-22386)
- regression with upgrade --reuse-values to 1.9.9 (CSFP4-1486)
- minor regression on deprecated APIs (application profile)
- reinstall issue in crd mode
- support of timeout with ncm app test
- fix space issue when instantiateWithArchive with flags and file
 
## Changed
- app-api is self migrated to helm3, so that showAll displays right information (CSFP4-1478)
- improve performance and scale and showAll
- improved uncaught exception to 400 with explicit reason
- tillers logs no more printed on profile status (must use pretty=true, N/A for helm3)
- helm3 migrate profiles/projects data into $XDG_DATA_HOME
- API 1.7.5

## [1.9.9] - 2020-03-13

### Fixed
- latency issue when parsing values with huge entry (CSFS-22127)
- wrong computed profile status in JSON when all deployed (CSFP4-1482)

### Added
- support of persistency in vanilla (CSFP4-1372) 

### Changed
- when json, profile status on unknown profile return 404 + json entity  

## [1.9.8] - 2020-03-06

### Fixed
- regression introduced by 1.9.6 with helm3 list (CSFP4-1467)

## [1.9.6] - 2020-03-04

### Fixed
- security vulnerabilities (CSFS-21849,CSFS-21846,CSFS-21748,CSFS-21701,CSFS-21563)
- fix helm plugin backup/restore in multitenant env (use of hidden  --tiller-namespace) (CSFS-22006)
- fix security vulneratibility with ncmtpl (CSFS-21506)
- fix error with ncm app podList (CSFS-21856)
- fix 500 error when listing profile setup from location that doesn't exist any more
- support timeout for rollback

### Added
- profile rollback (CSFP4-1409)
- support of tags and skiptags together (CSFS-21296)
- portability of --timeout with new helm3 format
- automatic cleanup of ad-hoc added --tiller-namespace from commandline in helm3

### Changed
- fasten profile status
- profile status doesn't print tiller log when failed (use pretty=true)
- add new ncmtpl (137)
- change default timeout value for history and search command
- extends default RETRY_MAX to 4
- API 1.7.1

### Limitations
- lcm.rollback.flags not yet supported 

## [1.9.4] - 2020-02-18

### Added
- support of --devel to search among x.y.z-patch charts (fix incompatiblity with helm 2.15+) (CSFP4-14236)
- enhance algorithm loop retry even if status returns correctly (CSFS-19926)
- add two retry cases in default RETRY_PATTERN (pods is forbidden|Could not get apiVersions from Kubernetes)

### Fixed
- helm3 support of list with flags=--namespace or -n
## [1.9.3] - 2020-01-30
### Fixed
- regression with multi-tenancy (CSFP4-1417)

## [1.9.2] - 2020-01-24

### Added
- support of exponential annotation for --set env.MAXFILESIZE (CSFP4-1408)
- support of onboard with dry-run (CSFP4-1289)

### Changed
- default algorithm for application/images is switched to "extract" (to align with exporter) (CSFP4-1407)
- add API deprecated officially ncm with --resources bwith -o resources
- extend default env.MAXFILESIZE to 2Mb (CSFP4-1406)
- API 1.6.8

## [1.9.1] - 2020-01-21

### Fixed
- support of overriden timeout in guard of helm executor (CSFS-20270)

### Added
- enhance retry_pattern for "pods is forbidden" (CSFP4-1299)
- smart profile validation feature (CSFP4-14)

### Changed
- showAll return correct json format with crd state and diagnostic
- explicit message when crd not ready
- add support of cleanup in CRD implementation
- cleanup duplicated logs introduced in 1.9.0

## [1.9.0] - 2020-01-09

### Added
- returns failure cause on profile status even asynchronously (CSFP4-1312)
- retry_pattern hardening (allow to retry when pending fails according to failure cause, recovering command install --dry-run is now retried) 
- support of helm3 (phase1, single tenant only,disable by default, see README to toggle) (CSFP4-1207)
- support of XDG default values (CSFS-19814)
- support of https cbur (cbur-certs mount point) (CSFS-19767)
- provide alpha for CRD implementation (for dev purpose only)

### Fixed
- mt-true was seen as true while false in showAll
- typo in repo search output using ncms command format (CSFID-2426)

### Changed
- harden when command with reset by peer (CSFP4-1325)
- return 401 when Authorization header is wrongly formatted (instead of 500 + NPE)
- when onboarding profile with unauthorized namespace, 403 is sent instead of 401
- showAll json format, asyncBR: true is use to notify cbur asynchronous

## [1.8.8] - 2019-12-05

### Fixed
- protect search/list rendering against corrupted HELM repo. Corruption is still tracked within audit log (CSFS-18182)
- support direct-redis as asynchronous detection criteria (cbur 1.3.1) (CSFP4-1277)

### Changed
- decrease the resource.request value from 1 to 100m

## [1.8.7] - 2019-11-20

### Added
- add ncm app registry list/prune (CSFP4-124)
- support for deleting unused charts/images from a project (CSFP4-124)
- support for listing charts/images available from a project (CSFP4-124)
- add ncm p terminate --prune from a project will delete all images/charts setup with a profile (CSFP4-124)
- change values for internal test coverage (CSFP4-93)

### Changed
- API 1.6.6

## [1.8.6] - 2019-11-13

### Added
- add retry mechanism when helm status/get/list/version command timeout
- add support --reinstall from failed state (CSFPS-352)

### Fixed
- harden --reinstall, support of reinstall from failed (cbur case) CSFPS-352)
- security fix for jackson library (CSFP4-1190)
- fix tpl files order when onboard more than 10 files (CSFP4-1242)
- fix terminateProfileThread 

### Changed
- helm status(/get/list/version) commands are now timeboxed within a configurable HELM_QUICK_TIMEOUT (30s).
- add new ncmtpl (113) (CSFP4-1191)
- provide produces in all swagger methods (CSFP4-26)
- extend the log REST API buffer from 100 to 1000 lines
- lcm delete flags defined on release are interpreted when using upgrade --reinstall flag on that same release
- add new recovery install strategy from failed state (enrich RETRY_PATTERN with "is being deleted")  (CSFPS-352)
- API 1.6.5

## [1.8.5] - 2019-11-10

### Added
- improve resiliency with helm/tiller connection issues (retry feature) (CSFP4-196)
- add json format to list application(CSFP4-1179)
- add purgeHooks flags to application terminate. this allows purging resources created during helm hooks : Job,Secrete,ConfigMap,ServiceAccount,Role,RoleBinding,ClusterRole,ClusterRoleBinding

### Fixed
- prevent any install/upgrade if onboard fails on values parsing (CSFP4-1233)
- fix regression with default app list return due to previous delivery(plain/text is default media)
- fix profile terminate with common flags (CSFPS-241)

### Changed
- termination with tags wil not be possible after upgrade onboard that fails( CSFP4-1233)
- API 1.6.2

## [1.8.4] - 2019-10-18

### Added
- ncm terminate --abort to terminate and abort installing/upgrading activity (CSFPS-263)
- ncm app images (collect all possible images/release or chart) (CSFPIE-1210)
- support of json in responses (profile status, list) (CSFPS-260,CSFPS-261)

### Fixed
- fix 500 when listing profile repo the very first time (before adding) (CSFPIE-1207)

### Changed
- ncm p terminate return 409 during installing/upgrading activity (CSFPS-263)
- define explicit media-types ordering policy when no Accept or \*/* : test/urilist,text/plain 
then application/json
- API 1.6.0

## [1.8.3] - 2019-10-02

### Added
- new API to support profile repository (--type profile) (CSFPIE-1153)
- new API to support app upgrade with json (only REST) (CSFPIE-1184)

### Fixed
- add parameters description for backupJob (CSFS-16551)

### Changed
- remove experimental PodLogs API (being redesigned)
- harden profile onboarding with 400 whenever a default value is not evaluated (<no value> must not present after templating)

## [1.8.2] - 2019-09-27
### Fixed
- harden profile name matching (CSFPS-157)

## [1.8.1] - 2019-09-25

### Fixed
- fix minor inconsistencies output (CSFPIE-1181,CSFPIE-1182)
- support of host time zone (CSFS-16443)

## [1.8.0] - 2019-09-20

### Added
- add api with profile resource and deprecated (CSFPIE-1083)
- integrated tiller logs with profile status (CSFPIE-1073)
- harden control with cbur and backup/restore plugin not compliant (CSFPIE-1081)

### Changed
- API 1.5.0

## [1.7.15] - 2019-09-20

### Changed
- cleanup naming inconsistency in API (CSFPIE-1102)

## [1.7.14] - 2019-09-19

### Added
- support of audit log (CLOG) (CSFPIE-968,CSFID-2180)

### Fixed
- harden semver2 chart naming (i.e 19.09.01 is not semver2) (see README.md) (CSFPS-161)
- hardern helm search for compouding chart name (CSFPS-161)
- erratic order when using multiple data template files

### Changed
- decrease memory resources default requirement (512mi max). For large cluster, this can be extended (see values.yaml)
- new parameters detailed in README.md
- render helm command error as ERROR by default
- PATCH/POST/PUT without Content-Type are considered as application/x-www-form-urlencoded (415 may be emitted instead of 400 in case of wrong usage)

## [1.7.11] - 2019-09-09
### Added
- add terminate autoprotection (CSFPIE-1121)
- add support rollback ncm flag (CSFS-15821)
- add support timeout for rollback (CSFPIE-1093)
- add support of event based templates (CSFS-15018)
- json friendly api (app instantiate with json)
- ncm cli (User-Agent sensitive) friendly output (repo search, profile list)
- flags support on app terminate

### Fixed
- harden liveness : when glusterfs is no more writable (when remounted), liveness will trigger a restart (CSFS-15938)

### Changed
- API 1.4.13

## [1.7.10] - 2019-08-23
### Fixed
- harden templates to support serverupgrade with --reuse-values

## [1.7.9] - 2019-08-16

### Added
- add support for updating helm plugins (CSFS-15558)
- add component service name in label (CSFPIE-1049)
- add helm test for helm plugin version

## [1.7.8] - 2019-08-13

### Added
- add --tags, --skiptags in terminateProfile (CSFS-15090)
- add restore profile (CSFPIE-951)

### Fixed
- fix support of pending releases (list and terminate)
- fix serverupgrade no --reuse-values by default (CSFPIE-1056)
- fix swagger annotations and bcmt-registry when offline mode (CSFPIE-1042)

## [1.7.7] - 2019-07-10

### Added
- modified image tag in values.yaml to 1.5.38 

## [1.7.6] - 2019-07-09

### Added
- integrate ncmtpl version 1.0.0-93
- delivered new image 1.5.38

## [1.7.5] - 2019-07-02

### Added
- add sanity tests to the chart
- new restore plugin support

### Changed
- API 1.4.2
## [1.7.3] - 2019-06-26

### Added
- backup profile support (CSFPIE-950)
- uptime in showall
- add get log level

### Fixed
- add mandatory release parameter in backup/restore job
- regression with profile instanciation when recent cli using tags/skiptags empty (CSFPIE-975,CSFS-14436)
- improve swagger documentation

### Changed
- API 1.4.0

## [1.7.2] - 2019-06-23

### Fixed
- cleanup, useless parameter in backujob, remove 10s latency in instantiate/upgrade profile (CSFPIE-965)

### Changed
- API 1.3.16

## [1.7.1] - 2019-06-21

### Added
- upgrade version of ncmtpl supporting getFile function (CSFPIE-962)
- enhance showAll / OPTIONS to render ncmtpl version and extensions (CSFPIE-963)
- provide dynamic logging PUT /application/logger
### Changed
- API 1.3.15

## [1.7.0] - 2019-06-20

### Added
- support project for profileThreads (synchronous profile activity are shown also)
- support of extended lcm flag --skipupdate in profile (CSFS-13453)
- support of extended lcm flag --reinstall in profile (CSFPIE-920)
- support of tags and skiptags in profile (CSFPIE-870)
- request printed with http.access=DEBUG

### Fixed
- add security on chart command with unautorized namespaces (CSFS-13267)
### Changed
- API 1.3.14

## [1.6.9] - 2019-06-06

### Added
- harden onboard returns 400 if no app_list yaml file defined or computed CSFPIE-940)
- add support of superadmin operation when MT is true
- add support of /application/id/get/[manifest|hooks|values|all]

### Fixed
- reactivate the support MT=true (CSFPIE-938)
- fix repos/add whenever NCM-Project header is empty header (CSFPIE-939)
- harden MT=true, 422 when NCM-Project header (CSFPIE-939)
### Changed
- API 1.3.12

## [1.6.8] - 2019-06-05

### Fixed
- support of chunked encoding (compaas proxy) (CSFS-13275)
- regression with restore command (CSFS-13630)
- upgradeProfile with failure anormaly deletes all releases, upgradeProfile return 424 if helm command fails (CSFS-13709)

## [1.6.7] - 2019-05-29

### Added
- onboarding with wrong syntax lead to 400 (instead of 409) with reason (CSFPIE-924)
- add loose parameter to unleash control during onboarding (dev only)

## [1.6.6] - 2019-05-28

### Fixed
- regression with keycloak authentication, support of anonymous when MT is true (CSFPIE-916)
- trigger a repo update before onboarding (CSFPIE-921)
- listProfile should return 200OK when no profile yet created (CSFS-13372)

## [1.6.5] - 2019-05-14

### Added
- add support of asynchronous backup/restore (CSFS-10502)
- improve error message (404) when repository or chart unknown (CSFPIE-672)

### Fixed
- unleashed user/password constraints on repos adding

## [1.6.4] - 2019-05-03

### Added
- add HELM_IGNORE property env to ignore unacceptable lines in helm lines 
- use HELM_IGNORE=.*portforward.go.* to remove interference with helm output (https://github.com/helm/helm/issues/3480) (CSFS-12409)
- create plugins symbolic link with home (project multitenancy) (CSF-11378)

## [1.6.3] - 2019-05-02

### Fixed
- fix duplicate properties in values.yaml when onboarding multiple yaml
- fix yaml directives removal (don't remove when used in custom property) (CSFS-12759)

## [1.6.2] - 2019-04-30
### Added
- add MAXFILESIZE (default 1M bytes) configuration parameter (tgz should only contains yaml like files, no big data)

### Fixed
- regression wrong home building when ncm with MT=true (CSFPIE-887)

## [1.6.1] - 2019-04-29

### Added
- support of location url and profile.tgz support in onboard and instantiate (CSFPIE-875)

### Fixed
- fix regression : HELM output format for cli usage (ncm app list) was disappeared

### Changed
- API 1.3.8
## [1.6.0] - 2019-04-25

### Added
- add templater support, .tpl supported during profile onboarding (CSFID-1828)
- remove first last updated releases when terminating profile

### Fixed
- minor format in WWW-Authenticate header when namespace unauthorized

## [1.5.9] - 2019-04-18
### Fixed
- regression with LOGGERS, and don't print helm version in INFO (CSFS-11602)

## [1.5.8] - 2019-04-18

### Added
- support of api 1.3.6 (minor change, use Bearer in security swagger information) (CSFS-12469)

## [1.5.7] - 2019-04-17

## Fixed
- security fix aligned with latest casr component for jdk vulnerabilities

## [1.5.6] - 2019-04-15

### Added
- improve support of local chart for heal,upgrade,scale (CSFS-11378)
- add semver strict control on version (--nostrict to deactivate)
- add instantiate with descriptor (harmonization with compaas api)

### Fixed
- regression when printing command result in debug mode

## [1.5.5] - 2019-04-11
### Fixed
- add helm home to instantiateProfile API with MT

## [1.5.4] - 2019-04-09
### Fixed
- values with profile dictionary was overriden by ncm app server

## [1.5.3] - 2019-03-28
### Added
- add parallel flag (on-demand for profile instantiation)
- add env.MT to enforce MT headers presence in MT context (default to false)
- add support of multiple files in instantiation/upgrade
- support of NCM-Project in swagger (CSFS-11710)

### Changed
- env.PARALLEL set to false by default
- API 1.3.3

### Fixed
- type in NCM-Authorized-NS

## [1.5.2] - 2019-03-20
### Changed
- change lower logging level to WARN

## [1.5.1] - 2019-03-15
### Changed
- correct the bug for keycloak parameters

## [1.5.0] - 2019-03-15
### Added
- support of multi-home and multi tiller
- add repository with json descriptor
- add parallelism in profile instantiation/upgrade
- add cause in profile status
- add bean validations
- add picketbox functions
- add /ncms resources list
- add dual K8S/keycloak authentication 
- add secure mode, add keycloak mode
- add Authorization control mode

### Changed
- store profile files on .helm volume (high available)
- image 1.4.4
### Changed
- API 1.3.2

## [1.4.5] - 2019-03-14
### Changed
- add keycloack configuration

## [1.4.2] - 2019-03-01
### Added
- add tolerations/node selectors in values
- tolerate everything by default
- add resources cpu/memory

### Changed
- env as map instead of list 

## [1.3.4] - 2019-01-24

### Added
- add support of multiple release rollback function (CSFID-1736)
- fix regression with instantiate/upgrade offline (CSFS-9915)

## Changed
- align output format of instantiateProfile/upgradeProfile with status output
- profile instantiation/upgrade optimisation
- log rendering enhancement
- API 1.2.5

## [1.3.3] - 2019-01-21

### Added
- add support of autoremove in profile upgrade, improve asynchronous behavior, and profile definition resiliency (CSFS-8332)
- add --cleanup option on terminateProfile
- add serverVersion in OPTIONS

### Fixed
- remove duplicate parameters when using global options with multi charts in profile (CSFS-9610)
- fix support of repository having uppercases (CSFS-29418)
- fix regression with applications/values
- fix version comparison

### Changed
- output of profile status display
- API 1.2.3

## [1.3.2] - 2019-01-10

### Fixed
- support for new backup/restore plugins (CSFS-9449)

## [1.3.1] - 2019-01-08

### Added
- support of lcm.scale.timeout, support of timeout for helm plugins (CSFS-9400)

## [1.3.0] - 2018-12-20

### Changed
- switch to /ncm root path by default
- API 1.2.0

### Limitation
- autoremove feature not included

## [1.2.9] - 2018-12-17

### Added
- support for docker with ncm smooth migration

## [1.2.8] - 2018-12-17

### Changed
- critical fix trailing slash
- add ncm for smooth migration

## [1.2.7] - 2018-12-17

### Added
- support of --reuse-values in all the scenarios (CSFS-8853)
- fix ncms default namespace when no specified in profile (CSFPIE-741)
- add asynchronous mode for profile terminate (CSFPIE-736)
- add Threads API(GET/DELETE) add support body for instantiate (CSFS-7757)
- compatibility ingress rules for ncms
- prepare for path migration
### Changed
- API 1.1.8

## [1.2.6] - 2018-12-06

### Added
- support of long transactions for instantiateProfile/upgradeProfile (CSFS-6451)
- support of asynchronous mode (--nowait) (CSFS-6451)
- add support of values.yaml in instantiate
- local chart deployment (not included in swagger api)

### Changed
- terminateProfile continue if release missing (424 returned) (CSFS-8562)
- rollback robustness
- API 1.1.7

## [1.2.5] - 2018-11-27

### Added
- introduce support of lcm.<event>.flags in profile values.yaml (and --set) (CSFS-8294,CSFS-7634)
- support of common: in profile values.yaml for setting common parts on all the charts (CSFID-1827)

### Changed
- enforce 404 when unknown release
- rest command follow timeout defined through helm command.
- API 1.1.5

### Limitations
- lcm.<event> is not interpreted when used in chart values.yaml, just in command line or within profile values (CSFS-8294)

## [1.2.4] - 2018-11-9

### Added
- implement heal for this chart
- add none defaul value for backup

### Fixed
- app deployment/upgrade is idempotent and continue over failed apps with using --nofailfast mode (CSFS-6550)
- return 400 when rollback a single revision release
- fix restore API (CSFS-8274)
### Changed
- API 1.1.4

## [1.2.3] - 2018-11-5
### Fixed
- allow --factor with --set lcm (CSFS-8110)

## [1.2.2] - 2018-10-29
### Added
- allow easy log level configuration (default no log) (CSFS-7423)

## [1.2.1] - 2018-10-28
### Added
- support of scale factor (CSFS-7567)
- enhance server upgrade : version support and protect against --reuse-values

### Fixed
- support of revision with empty value in rollback

## [1.2.0] - 2018-10-23
### Added
- support plain/text with multifields list, add release history (CSFS-6857)
- check profile format during onboarding
- add support of update with empty set
### Changed
- API 1.1.0

## [1.1.9] - 2018-10-18
### Added
- add idempotency hardening during profile instantiate/upgrade : already deployed are ignored during instantiate, failed are reinstalled upgraded (CSFS-7802)

## [1.1.8] - 2018-10-15
### Fixed
- fix typo on tolerations to accept deployment on node mixing control/edge node" (CSFS-7714)

## [1.1.7] - 2018-10-12
### Added
- profile support any .yaml files (unleash app_list.yaml/values.yaml constraints) (CSFS-7680)

## [1.1.6] - 2018-10-11
### Fixed
- add nameOverride to ncms-app (to keep compliancy with bcmt-api nginx)
## [1.1.5] - 2018-10-10
### Added
- rollback without revision
### Fixed
- harden upgrade/update + doc

## [1.1.4] - 2018-10-08
### Fixed
- change readiness for helm (CSFS-7423)
- fix autoupgrade

## [1.1.3] - 2018-10-08
### Fixed
- fix templates for env

## [1.1.2] - 2018-10-01
### Added
- provide cpu optimization
### Fixed
- fix wrong docker image

## [1.1.1] - 2018-10-01
### Fixed
- applications/serverupgrade follow new ncm name
### Added
## [1.1.0] - 2018-09-30
### Added
- flags,body on applications/instantiate
- flags upgrade, update
- applications/values
- applications/logs
- log,helm_check configurability
### Changed
- user docker image 1.1.0
- repos/upload renaming repos/add
- liveness/readiness method 
- stack tuning
- API 1.0.0
### Fixed
- erratic output displaying  (CSFS-5857)
- applications/update
### Limitations
- case may fail with applications/update due to HELM 2.9.1 (https://github.com/helm/helm/issues/4336)

## [1.0.3] - 2018-08-28
### Added
- global relocability
### Changed
- use docker image 1.0.3
- reduce liveness period

## [1.0.2] - 2018-08-06
### Changed
- use docker image 1.0.2
