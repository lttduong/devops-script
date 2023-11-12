# Changelog
All notable changes to chart **ckaf-kafka** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- Do not add comments under Unreleased. Add comment only under release
## [3.0.2] - 2020-07-07
### Changed
- cbur image tag update to latest for clair scan fix.

## [3.0.1] - 2020-07-01
### Changed
- kafka scale feature via upgrade jobs support.
- update the jmx image to latest.

## [3.0.0] - 2020-06-30
### Changed
- Kafka Scale fix on docker side. 
- Version Upgrade of kafka (v5.4.1)
- Removed ClusterIP Service - CSFS-23682
- External RBAC Support 
- ServiceAccount Variable Name Change - NameOverride Fix
- Krb5.conf as configmap instead of base64 value
- enable zk acl authorizer configurations.
- MCS labels
- ckaf-kafka charts with istio mtls
- fix for pvc cleanup upon scale in.
- Docker image tag change to latest delivered, update the dependent chart to latest stable.

## [2.0.0] - 2020-03-31
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade
- Keytabs removal from chart.
- Helm3 Compliant
- Heal enhancement for Kafka component.
- Reverting back to centos7 . Docker Tag Change to Reflect the same.
- Istio Port Name Changes and annotation addition
- Deduplication of parameters in sts
- Istio changes in zk from listenonallips to ports exclusion
- Docker image tag change to latest delivered, update the dependent chart to latest stable.

## [1.6.7] - 2019-12-17
- configuration overrides flexibility added.
- add the generic service.
- configurable readiness and liveness probe timeouts.
- update the charts with the latest docker images and registry to candidates. 
-  update the charts with the latest docker images and registry to delivered.
## [1.6.6] - 2019-10-29
### Changed
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command (BUG-CSFANA-14847) 
- CBUR changes implemented
- Fullname override feature code is implemented.
- Revertig the cross-upgrade code from kafka.
- Compass code modifications.
- Values model file change for cbur 
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2
- Added Prometheus annotations in service-headless file
- corrected docker image tag
- Changes for supporting user provided keytabs in kafka pods.
- Configurable number of ZK in Compass
- CSFANA-18429 Replace mv command with cp 
- Ingress for kafka CSFID-1967, with configurable external service names.
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- SASL and SSL Parameters for Compass
- Base Image change for clair bug.
- Base Image change for clair bug.(re-do)
- docker image update with java base image update & requirements.yaml with zookeeper chart version
- docker delivered image and dependant stable chart updates for 19.10 release preparation 

## [1.6.5] - 2019-08-02
### Changed
- CSFS-12838 zkConnectUrl change to use zookeeper service and liveness readiness changes.
- Updated krb section of zookeeper in values.yaml for CSFS-12838.
- Java based nano image (CSFANA-13645 docker image tag change)
- Support for 3 Step Upgrade Procedure
- 19.07 delivery with Pre & post upgrade hooks disabled
- VAMS FIX (docker tag change CSFANA-14671)
- moving charts to stable 

## [1.6.4] - 2019-07-08
### Changed
- Kafka ERROR log level change

## [1.6.3] - 2019-06-21
### Changed
- Fullname override changes for Kafka.
- Exposed taint toleration parameter for zookeeper in values.yaml
- Node port support for kafka CSFID-1967 
- Added Per broker service creation yaml and configmap creation citm 
- Docker image tag change
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Made JmxExporter port generic in service files for kafka
- Fix for upgrade failure
- Fix for deploy failure
- reverting back fullname override changes
- For nodeSelector removed angaular brackets from example and provided example in comment
- Delivery 19.06

## [1.6.2] - 2019-06-02
### Changed
- readiness and liveness probe improvement
- changes in password-like fields in values-model.yaml format as password (CSFS-9850)
- change of attribute auto_remove_kf_secret to false (CSFS-9850)
- support for taints and tolerations
- Docker image tag change as per (CSFANA-13422)
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered

## [1.6.1] - 2019-04-09
### Changed
- clogEnable to true
- updated requirements.yaml
- Taking latest docker which has fix for clair vulnerability
- Docker image updation for 19.04 release
- Moving to delivered repo

## [1.6.0] - 2019-04-02
### Added
- Version Upgrade (CSFKAF-1510).
- Security gap fix for kafka  (CSFKAF-1526).
- Bug fix for CSFKAF-1757. Removed all hardcoded imagetag from values-template.yaml.j2
- updated zookeeper chart version
- Latest Docker Image Update for 19.03 release (CSFKAF-1804)

## [1.5.12] - 2019-02-28
### Added
- Added a new parameter zookeeperSetAcl in values.yaml to restrict unauthorized access to kafka from kafka manager
- Docker image 1.6.0-2.0.0-1151
### Changed 
- Bug fix for kafka scalein issue (CSFKAF-17).

## [1.5.11] - 2019-02-01
### Removed
- The imageTag of zookeeper in kafka values.yaml (CSFS-10148)

## [1.5.10] - 2019-02-01
### Changed
- Changed the imageTag of  zookeeper in values.yaml (CSFS-10148)

## [1.5.9] - 2019-01-31
### Added
- Added a new folder named dashboard which contains kafka metrics dashboard and node metrics dashboard which should be imported into grafana(CSFBANA-8274).
- Added ConfigMap for Jmx (CSFBANA-8277)
- Added autoPvEnabled to check if volumes are precreated then bind them to pods (CSFS-8360)
- Added selector in volumeClaimTemplates to bind pods to the specific labelled PVs (CSFS-8360)
### Changed
- Rbac updates for ComPaaS.(CSFS-9093)
- Changed the LogLevel (CSFS-9651)
- Changed nodeLabel , made it generic where the users have to give their own nodeType, which is a key value pair (CSFBANA-8472)

## [1.5.8] - 2018-12-27
### Changed
- sasl change
- Changed the kafka docker version to 1.4.0-2.0.0-880.
- Fixed deletion of kafka by deleting statefulset and pod(CSFS-8623)
- Fixed kafka scale in/ scale out issue if throttle value is large
- Change name of hooks,job,service-account,rolebindings to be unique (CSFS-9098).

## [1.5.7] - 2018-11-30
### Added
- Added nodeSelector in statefulset.yaml(CSFID-1747)
- Fix for CSFS-8292,lo4j.properties log volume mount utilization
### Changed
- Taking docker image from delivered(CSFBANA-7737)
- In values-template.yaml.j2 taking throttle value from values-model.yaml(CSFBANA-7737)

## [1.5.6] - 2018-11-20
### Added
- Pre rollback and pre delete hook(CSFS-7634)
- forceUpgrade, prepareRollback and enableRollback flag in values.yaml(CSFS-7634)
### Changed
- Changed pod management policy to OrderReady and deletion of kafka pods in pre-delete(CSFS-7634)
- Added statefulset deletion in pre-upgrade based on forceUpgrade flag in values.yaml(CSFS-7634)
- Fix for CSFBANA-7737
- Fix for CSFBANA-7930
- Fix for CSFS-8291

## [1.5.5] - 2018-10-31
### Changed
- Fix for CSFS-7683
- Fix for CSFS 7591
- Fix for CSFS 7732
- Fix for CSFS 7647
- Fix for CSFS-7634

## [1.5.4] - 2018-10-06
### Changed
- Fix for CSFS-7191: Creating seperate PVCs for data and log.
- Moved preheal and postheal under global in values.yaml as per latest heal plugin requirement(CSFS-7221)
- values-model realignment
### Added
- Put cpu and memory resources for cbur-agent and jobs(CSFS-7317)

## [1.5.3] - 2018-09-27
### Added
- Added storageClass variable in values.yaml to global scope.
### Removed
- Removed StorageClass and ckaf-zookeeper.storageClass from values.yaml

## [1.5.2] - 2018-09-12
### Changed
- Updated the memory requirement for charts(Gerrit 467349).

## [1.5.0] - 2018-09-11
### Changed
- CKAF 18.08 release: Supported CBUR 1.2.1, Fix terminate, Enhance scale and upgrade, Relocatable chart.

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

