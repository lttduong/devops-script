# Changelog
All notable changes to chart **ckaf-schema-registry** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- Add comment only under release

## [6.0.1] - 2020-07-07
### Changed
- update jmx image with the latest.
## [6.0.0] - 2020-06-30
### Changed
- Vesrion Upgrade of schmea-registry(v5.4.1)
### Added
- Krb5.conf as configmap instead of base64 value.
- Docker image tag change to latest delivered.

## [5.0.0] - 2020-03-30
### Changed
- Docker Tag Change to Reflect Centos8,python3,Java11 upgrade
- 2 way ssl implementation and liveness readiness probes change
- Helm3 Compliant
- schema registry with basic authentication.
- provision to configure http listener when SSL is enabled.
- Reverting back to centos7. Docker Tag Change to Reflect the same.
- Mounting client keytab using secret instead of creating inside the pod.
- Docker image tag change to latest delivered.

## [4.8.14] - 2019-12-17
- ingress back end port configurable fix.
- Fix for CSFS-18512, wherein user can provide either of bootstrapserver or zookeeper; or both for master election
- removed requirements.yaml which removes depenedent charts.
- update with charts with latest image tag and registry to candidates
- Update charts with latest image name and registry to delivered.

## [4.8.13] - 2019-08-29
### Added
- Fix for deletion of other application resource/pods due to incorrect kubectl delete command in CKAF components hooks CSFANA-14847
- Fullname and Name override feature code implemented.
- Taking latest nano base image 1.8.0.222.centos7.6-20190801-2 and fix for CSFANA-14639
- Ingress support for ckaf-schema-registry CSFANA-15273
- Ingress host name made user configurable.
- update base docker image to 1.8.0.222.centos7.7-20190927 and VAMS fix
- fix for VAMS bug CSFANA-18533(related to sudo)
- Base Image change for clair bug.
- docker image update with java base image update & requirements.yaml with kafka chart version
- docker delivered image and stable dependant charts update for 19.10 release preparation.

## [4.8.12] - 2019-08-02
### Added
- Java based nano image (CSFANA-13645 docker image tag change)
- 19.07 delivery
- VAMS FIX (docker tag change CSFANA-14671)
- Moving charts to stable

## [4.8.11] - 2019-07-03
### Changed
- Fullname override changes implemented for schema-registry.
- Removed Kafka and Zookeeper dependencies from schema-registry.
- Renamed external_kafka to kafka_settings
- Removed parameters are number_of_brokers, port, security_protocol, kafka_service_name, release_name, name_space at kafka_settings BootStrapServers section and serviceName, port, release_name, name_space at ZookeeperUrl. Since we are not preparing BootStrapServers & ZookeeperUrl at _helper.tpl file.
- Docker image tag change
- For Taint toleration and nodeLabel feature removed curly braces and gave reference example
- Made JmxExporter port generic in service files
- Fix for upgrade
- Fix for deploy
- Fix Changes at sr-test-configmap.yaml and rbac-rolebinding.yaml
- Removed Fullname override changes
- For nodeSelector removed angaular brackets from example and provided example in comment
- Statefulset added with a update startegy (rolling update)
- upgrade changes for pre/post/prerollback with rbac changes (cluster-roles)
- Delivery 19.06

## [4.8.10] - 2019-06-02
### Changed
- Change of kafka version in requirements.yaml as part of kafka chart changes (CSFS-9850)
- Support for taints and tolerations
- Docker image tag change as per (CSFANA-13423)
- Docker image tag change as per rhel licensing issue.
- Moving artifacts to delivered.

## [4.8.9] - 2019-04-26
### Changed
- clogEnable to true
- updated requirements.yaml
- Added cub timeout as configurable value
- Taking latest docker which has fix for clair vulnerability
- Docker image change for 19.04 release
- Moving to delivered repo

## [4.8.8] - 2019-04-02
### Added
- Update the Kafka dependent chart version to latest.
- Fix for security gap in schema-registry (CSFKAF-1527).
- Latest Docker Image Update for 19.03 release (CSFKAF-1803)
### Removed
- Removed Role for schema and service account is bound with Cluster role admin.
- CBUR support for Schema registry as _schemas is back-up as part of kafka(CSFKAF-1758)

## [4.8.7] - 2019-02-01
### Added
- Update the Kafka dependent chart version to 1.5.11.

## [4.8.6] - 2019-01-31
### Added
- Added a new folder named dashboard which contains schema registry metrics dashboard which should be imported into grafana (CSFBANA-8273).
- Added nodeLabel , made it generic where the users have to give their own nodeType, which is a key value pair (CSFBANA-8514)

## [4.8.5] - 2018-12-27
### Added
- sasl refactor
- CLOG integration
- Fix for CSFBANA-8313 Log rotation for schema-registry logs
### Changed
- Change the schema registry docker version to 1.4.0-5.0.0-880.
- Change name of hooks,job,service-account,rolebindings to be unique (CSFS-9098).

## [4.8.4] - 2018-11-30
### Changed
- Release with Kafka 1.5.7 (release 18.11)

## [4.8.3] - 2018-10-31
### Added
- Added resource requests and limits for cbur-agent and jobs(CSFS 7317)

## [4.8.2] - 2018-10-06
### Changed
- Release with Kafka 1.5.4(with CSFS 7191 fix)

## [4.8.1] - 2018-09-27
### Added
- Added storageClass in global scope in values.yaml
- Added external_kafka.BootStrapServers.release_name in values.yaml
- Added external_kafka.ZookeeperUrl.release_name in values.yaml

## [4.8.0] - 2018-09-12
### Changed
- Schema Registry 18.08 release: Supported CBUR 1.2.1, Enhance scale, Relocatable chart.
