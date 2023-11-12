# Changelog
All notable changes to chart **ckaf-zookeeper** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- Do not add comments under Unreleased. Add comment only under release

## [3.0.1] - 2020-07-01
###Added
- Zookeeper support scale via upgrade.
- Update the jmx image to latest. 

## [3.0.0] - 2020-06-30
### Changed
- Zookeeper 3.5.7  Scale Fix.
- Version Upgrade to 3.5.7 and zookeeper upgrade fix.
- External RBAC Support
- ServiceAccount Variable Name Change - NameOverride Fix
- Krb5.conf as configmap instead of base64 value
- ckaf-zookeeper charts with istio mtls.
- fix for pvc cleanup upon scale in.
- log directory set for zk-gc log file
- Docker image tag update to delivered.

## [2.0.0] - 2020-03-30
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade
- Helm3 Compliant
- Istio Support
- Reverting back to centos7.Docker Tag Change to Reflect the same.
- Istio changes from listenonallips to ports exclusion
- docker image tag change to latest delivered.

## [1.4.15] - 2019-12-17
- provide feasibility to override any zookeeper config property
- Update charts with latest image tag and registry
- Zookeeper client default port set to 2181
- Update charts with latest image tag and delivered registry

## [1.4.14] - 2019-10-29
### Added
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command in CKAF components hooks
- Nodeport support for zookeeper CSFID-1967
- Fix/Added SASL  parameters for Zookeeper CSFANA-13634
- CBUR changes implemented
- Fullname override feature code is implemented.
- Reverted cbur-configmap name
- Reverting cross-upgrade code.
- Heal timeout paramter included
- compaas values-model file changes for cbur
- Replaced cbur prerestore cmd  from mv to cp 
- Included comment in prerestore hook job
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2
- added support for configuring SASL in compaas
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- Base Image change for clair bug.
- Base Image change for clair bug.(re-do)
- docker image update with java base image update
- delivered docker image update for 19.10 release preparation

## [1.4.13] - 2019-08-02
### Added
- CSFS-12838 Changes in chart to use zk service as zkConnectUrl.
- Java based nano image ( CSFANA-13645 docker image tag change)
- Disabling sts deletion for every upgrade
- 19.07 delivery
- VAMS FIX (docker tag change CSFANA-14671)
- moving to delivered 

## [1.4.12] - 2019-06-20
### Added
- Fullname override changes for zookeeper.
- Support for ingress (CSFID-1967)
- Docker image tag change 
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Made JmxExporter port generic in service files for zookeeper
- Fix for upgrade
- Fix for deploy
- Reverting name and fullname override changes
- Delete pvc lable condition corrected
- Delete pvc lable condition corrected in postscalein.yaml
- For nodeSelector removed angaular brackets from example and provided example in comment
- Delivery 19.06

## [1.4.11] - 2019-06-02
### Added
- Format password for all password like fields in values-model.yaml for (CSFS-9850)
- Support for taint and tolerations
- Image tag change as a fix for  CSFS-13400.
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered.

## [1.4.10] - 2019-04-30
### Changed
- clogEnable to true
- Taking latest docker which has fix for clair vulnerability
- Taking 1.8.0.212.centos7.6-20190411 docker which has fix for clair vulnerability

## [1.4.9] - 2019-04-02
### Added
- Version Upgrade (CSFKAF-1510).
- Security gap fix (CSFKAF-782).
- Bug fix for CSFKAF-1757. Removed all hardcoded imagetag from values-template.yaml.j2
- Latest Docker Image Update for 19.03 release (CSFKAF-1802)
### Changed
- Fix the issues while upgrading from ckaf-zookeeper 1.4.6(CSFS-11514)

## [1.4.8] - 2019-02-28
### Added
- Docker change 1.6.0-3.4.12-1151 
### Changed 
- Bug fix for zookeeper scale issue (CSFKAF-17).


## [1.4.7] - 2019-01-31
### Added
- Added preAllocationSize for zookeeper snapcount files
- Added a new folder named dashboard which contains zookeeper metrics dashboard which should be imported into grafana (CSFBANA-8272).
- Added ConfigMap for Jmx(CSFBANA-8443).
- Added autoPvEnabled to check if volumes are precreated then bind them to pods (CSFS-8360)
- Added selector in volumeClaimTemplates to bind pods to the specific labelled PVs (CSFS-8360)
### Changed
- Rbac updates for ComPaaS.(CSFS-9093)
- Changed nodeLabel , made it generic where the users have to give their own nodeType, which is a key value pair (CSFBANA-8471).


## [1.4.6] - 2018-12-11
### Added
- sasl refactor
- Added clog changes
- Added dynamic creation of zookeeper ensemble (CSFS-8362).
### Changed
- Docker image tag for zookeeper 1.4.0-3.4.12-880.
- Change name of hooks,job,service-account,rolebindings to be unique (CSFS-9098).

## [1.4.5] - 2018-11-29
### Added
- Added nodeSelector in statefulset.yaml.
- Added log rotation in log4j.properties and redirected the logs of zookeeper into specified log volume mount (CSFS 8289).

## [1.4.4] - 2018-11-19
### Added
- Pre-upgrade, post-upgrade and pre-rollback hooks(CSFS 7634).

## [1.4.3] - 2018-10-31
### Changed
- Updated the storageClass and namespace for zookeeper(CSFS 7591).

## [1.4.2] - 2018-10-06
### Changed
- Moved preheal and postheal under global in values.yaml as per latest heal plugin requirement(CSFS-7221)
- values-model realignment
- meta data support CSFS-7191
### Added
- Put cpu and memory resources for cbur-agent and jobs(CSFS-7317)

## [1.4.1] - 2018-09-27
### Changed
- Moved storageClass variable in values.yaml to global scope(CSFS-7253)

## [1.4.0] - 2018-09-10
### Changed
- CKAF-Zookeeper 18.08 release: CBUR 1.2.1 support, Fix terminate, Fix scale, Relocatable chart.

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
