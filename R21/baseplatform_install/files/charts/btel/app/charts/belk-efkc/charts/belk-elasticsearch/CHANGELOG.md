# Changelog
All notable changes to chart **belk-elasticsearch**  are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- CSF chart relocation rules enforced

## [6.1.2] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [6.1.1] - 2020-09-30
- Updated README.md file
- CSFS-24538: Saving list of indices in snapshot as a file in /elasticsearch_backup
- CSFS-28181: Removed jdk bundled with elasticsearch from the image
- Added support for istio 1.4
- Elasticsearch logging format modified for unified logging
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- updated job and job container template names
- CSFS-28597: Added new headless services for prometheus, removed cpro annotations from pods.
- updated docker image repo to choose between elasticsearch cos7 and cos8 images.
- Docker images moved to delivered

## [6.1.0] - 2020-08-31
### Updated
- Helm hook-delete-policy of pre/post-upgrade jobs made user configurable
- CSFS-24844: Updated ES sg-configmap parameters to be evaluated as template
- ELK upgrade to 7.8.0
- CSFS-26865: Updated the elasticsearch-graphana.json
- Updated cbura imageTag
- Added provision for self signed certificates for transport layer via docker entrypoint when istio is enabled 
- CSFS-27150: Added support for CKEY external to istio mesh
- Excluded .signals* indices from ES Backup restore in docker image
- Replaced CMS garbage collector with G1GC
- Moved ES docker image to delivered

## [6.0.21] - 2020-07-13
### Updated
- Added Pod affinity
- Added fsGroup, supplementary groups, MCS label
- Added readiness and liveness probe check
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for cutomized labels to pods
- helmbestpractice changes for service account and rbac flag
- Fixed SG 6-7 upgrade issue when istio is enabled
- CSFS-22260: Added cleanup-job to delete remaining resources on purge
- CSFLDA-2602: Updated es-prometheus pod level annotations to work with istio enabled chart
- Integration with keycloak in mTLS
- Fixing Helm3 issue with headless svc
- Removed unused parameter base64RootCA
- Moved docker images to delivered

## [6.0.20] - 2020-04-23
### Updated
- Helm3 changes
- Istio-Style Formatting for ports

## [6.0.19] - 2020-02-11
### Updated
- Modified service account for elasticsearch
- Modification of role in Post-delete job
- Handled sg migration failures on data node not detected(Delivered as BELK-19.12 patch with chart version 6.0.1810)
- Fix for files have insecure file permission in elasticsearch image
- Improved backup and restore scripts in elasticsearch docker
- Fix for files have insecure file permission in elasticsearch image for elasticsearch.yml and jvm.options
- Added permission in post-upgrade job to view logs of pod
- Added support for ES cipher suites
- Added autoUpdateCron in BrPolicy for automatically deleting/creating/updating cronjob based on other parameters
- Fixed restore script in elasticsearch docker
- Moved docker image to delivered

## [6.0.18] - 2019-12-18
### Updated
- Removed es-svcprometheus service that contained es-prometheus annotations 
- Added es-prometheus annotations at pod level(es-master,es-data,es-client)
- Modified readiness probe for es-client to check searchguard health.
- Updated java_opts & network host to support IPv6 Env
- Fix for client pod logs breaking terminal
- made prometheus scrape annotation for https endpoints user configurable
- updated elasticsearch image to point to latest java base image
- Moved elasticsearch image to delivered

## [6.0.17] - 2019-10-30
### Updated
- Added es-prometheus service to scrape elasticsearch metrics
- Added postscalein job for deleting unused PVCs
- Updated es-prometheus service to add flag for SG enabled
- Improved SG migration code for ELK6 to ELK7 upgrade and removed sg_migrate flag.
- CSFLDA-2118: Updated BrPolicy for configmap restore
- Added autoEnableCron in BrPolicy
- Upgraded base image to centos-7.7
- Updated cbura image to 1.0.3-983, updated registry parameter
- Updated to latest java base image
- Moving elasticsearch images to docker-delivered

## [6.0.16] - 2019-10-17
### Updated
- Added ignoreFileChanged option in Brpolicy
- Upgraded kubectl image to v1.14.7-nano

## [6.0.15] - 2019-09-11
### Updated
- Modified readiness probe of es-master(CSFLDA-2113)
- Fixed indentation for nodeSelector in es-client & es-master

## [6.0.14] - 2019-08-29
### Updated
-  Moved elasticsearch images to delivered

## [6.0.13] - 2019-08-23
### Updated
- CSFS-15048: Updated cbura sidecar image to 1.0.3-871

## [6.0.12] - 2019-08-22
### Updated
- CSFLDA-1975: Moved elasticsearch image to JAVA 11 and centos nano image 

## [6.0.11] - 2019-08-16
### Updated
- Fixed kibana restore issue for re-indexing kibana index
- Moved docker images to delivered

## [6.0.10] - 2019-08-12
### Updated
- Fixed kibana restore issue for re-indexing kibana index

## [6.0.9] - 2019-08-06
### Updated
- Increased /tmp directory volume for cbur-sidecar.

## [6.0.8] - 2019-08-05
### Updated
- Fixed kibana restore issue
- Provided /tmp directory volume for backup.

## [6.0.7] - 2019-07-11
### Updated
- CSFS-14419: Made network_host user configurable. 

## [6.0.6] - 2019-07-08
### Added
- Moved all images to delivered

## [6.0.5] - 2019-07-06
### Added
- Fixed upgrade(ES-6 to ES-7) issue by adding SG migrate script.

## [6.0.4] - 2019-07-06
### Added
- Fixed upgrade(ES-6 to ES-7) issue by adding SG migrate script.

## [6.0.3] - 2019-07-05
### Added
- Added pvc for master pods as cluster state is persisted in path.data directory between node restarts

## [6.0.2] - 2019-07-01
### Modified
- Modified brOption to 0
- Modified pvc deletion to check for component=elasticsearch also

## [6.0.1] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Pointed the images to candidates

## [6.0.0] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Added job resources to jobs
- Added security annotations

## [5.2.6] - 2019-05-28
### Added
- Updated brOption and added cbur resource limits

## [5.2.5] - 2019-05-21
### Added
- Updated BRPolicy

## [5.2.4] - 2019-05-20
### Added
- Added security annotation

## [5.2.3] - 2019-05-14
### Added
- CSFID-2215:Add ElasticSearch dashboard for grafana

## [5.2.2] - 2019-04-30
### Added
- Upgraded ELK to 6.6.1
- moved images to delivered 

## [5.2.1] - 2019-04-25
### Added
- Upgraded base image

## [5.2.0] - 2019-04-25
### Added
- Upgraded ELK to 6.6.1

## [5.1.3] - 2019-03-26
### Added
- Upgraded base image to centos 7.6
- Moved images to delivered

## [5.1.2] - 2019-03-22
### Added
- Upgraded base image to centos 7.6 

## [5.1.1] - 2019-03-12
### Added
- CSFLDA-1590: Updated sg_roles and sg_roles_mapping with latest searchguard configurations

## [5.1.0] - 2019-03-04
### Added
- CSFID-1611: Keycloak integration

## [5.0.3] - 2019-02-28
### Added
- CSFLDA-1540: Implemented ElasticSearch POD anti-affinity rules
- Test move chart to stable

## [5.0.2] - 2019-02-14
### Added
- CSFLDA-1540: Implemented ElasticSearch POD anti-affinity rules

## [5.0.1] - 2019-02-01
### Added
- Upgraded chart to 6.5.4-oss
- Moved all docker images to delivered

## [5.0.0] - 2019-01-25
### Added
- Upgraded chart to 6.5.4-oss


## [4.4.8] - 2019-01-24
### Added
- CSFLDA-1436: fixed snapshot_name issue for postRestoreCommand.sh

## [4.4.7] - 2019-01-24
### Added
- CSFLDA-1436: Backup and restore enhancements. User no need to specify snapshot name in the values.yaml

## [4.4.6] - 2019-01-15
### Added
- CSFS-9322:Harmonized logging modified timezone field

## [4.4.5] - 2019-01-10
### Added
- CSFS-9384: Client doesnot recover after OoM
- CSFS-9385: ES-client threw OoM

## [4.4.4] - 2019-01-04
### Added
- Backup and restore below issues are fixed
- CSFLDA-1414: Backup is failing due to path_repo issue when we deploy EFKC chart with SearchGuard .
- CSFLDA-1420: Number of Snapshots were getting increased as the number of Datapods were getting increased.
- CSFLDA-1421: Backup of indices was failing when we deploy chart with SearchGuard.

## [4.4.3] - 2019-01-02
### Added
- Backup and restore issue fixed

## [4.4.2] - 2018-12-21
### Added
- Backup event if condition is added

## [4.4.1] - 2018-12-20
### Added
- Upgraded ES to 6.5.1

## [4.4.0] - 2018-12-19
### Added
- ES Implementation of backup LCM event for elasticsearch

## [4.3.3] - 2018-11-29
### Added
- ES chart with SG improvement

## [4.3.2] - 2018-11-26
### Added
- ES with SG image with Harmonized logging

## [4.3.1] - 2018-11-22
### Added
- Local Storage fo ES

## [4.3.0] - 2018-11-21
### Added
- Harmonized logging for ES
- Docker base image change which contains security fix
- Fix for deleting statefulsets while upgarding


## [4.2.0] - 2018-10-29
### Added
- Elasticsearch version Upgraded from 6.2.4 to 6.4.1

## [4.1.10] - 2018-10-24
### Added
- CSFS-7852:remove test folder

## [4.1.8] - 2018-09-27
### Added
- Heal LCM event is added.

## [4.1.7] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.1.6] - 2018-09-19
### Changed
- Modified secret creation

## [4.1.5] - 2018-09-10
### Changed
- Searchguard configmap is passed from values file

## [4.1.4] - 2018-09-05
### Added
- Update configuration LCM event is added

## [4.1.3] - 2018-09-05
### Added
- CSFLDA-802: Upgrade and rollback LCM events are added for ES

## [4.1.2] - 2018-09-04
### Changed
- CSFLDA-897: Fix for bug while installing chart with wrong base64 password

## [4.1.1] - 2018-09-03
### Changed
- Modified update strategy and podmanegement policy to take from values file

## [4.1.0] - 2018-08-31
### Added
- Install and delete LCM events are added for ES

## [4.0.4] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry

## [4.0.3] - 2018-08-28
### Changed
- CSFLDA-816: Fixed ES services endpoints
### Added
- CSF chart relocation rules enforced

## [4.0.1] - 2018-08-17
### Changed
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Changed
- Chart to follow semantic naming. belk-<component>-<opensource version>-<csf release year>.<csf release month>.<patch> 
  e.g. belk-elasticsearch-6.2.4-18.07.03
- docker image on Centos 7.5
### Added
-  PSP/RBAC support

