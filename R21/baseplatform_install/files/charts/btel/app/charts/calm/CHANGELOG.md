# Changelog
All notable changes to chart **calm** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [20.9.2] - 2020-10-12
### Added
- CSFS-29687: CALM not able to receive alarms from fluentd (CLOG)

## [20.9.1] - 2020-10-09
### Added
- CSFS-29667: CALM installation fails with SSL enabled and ISTIO disabled. RELEASE

## [20.9.0] - 2020-10-08
### Added
- CSFOAM-6367: CALM version 20.09 docker image update. CALM 20.09 RELEASE

## [20.8.0-35] - 2020-10-07
### Added
- CSFOAM-5806 jdbc session parameter suggestion, logLevel

## [20.8.0-34] - 2020-10-07
### Added
- CSFOAM-5806 log config, snmp logging, parameter changes

## [20.8.0-33] - 2020-10-06
### Added
- CSFOAM-6335: add namespace to diagnostic call

## [20.8.0-32] - 2020-09-30
### Added
- CSFOAM-6335: Get rid of CALM test image

## [20.8.0-31] - 2020-09-30
### Added
- CSFOAM-5806: CBUR Backup/Restore fix - refixing loggin and removing log volume from backup

## [20.8.0-30] - 2020-09-25
### Added
- CSFOAM-5806: CBUR Backup/Restore fix

## [20.8.0-29] - 2020-09-28
- CSFOAM-5806: CSFOAM-5806: cleanup property files - calm.properties changes - security.multiContextEnabled

## [20.8.0-28] - 2020-09-25
- CSFOAM-6203: Updated values-model.
- CSFOAM-5806: CSFOAM-5806: cleanup property files - cvea.properties changes

## [20.8.0-27] - 2020-09-25
- CSFOAM-5806: CSFOAM-5806: cleanup property files - rabbitmq.properties changes

## [20.8.0-26] - 2020-09-25
- CSFOAM-5806: *alma.storage* parameter has been renamed to *calm.persistence.type*
- CSFOAM-5806: *mq* parameter has been renamed to *calm.mq*

## [20.8.0-25] - 2020-09-24
### Added
- CSFS-27252: CALM: Add support to add prefix to pod names and container names

## [20.8.0-24] - 2020-09-24
### Added
- CSFOAM-6203: Added parameters to README.md 

## [20.8.0-23] - 2020-09-23
### Added
- CSFOAM-6203: Added comments to settings, removed some default values with secret

## [20.8.0-22] - 2020-09-22
### Added
- CBAMDEV-1438: CNOT config file and parameter name changes

## [20.8.0-21] - 2020-09-22
### Added
- CSFS-28622: Fix UDP expose according to Vz

## [20.8.0-20] - 2020-09-19
### Added
- CBAMDEV-1438: add NIDDs directory, missing keycloak params

## [20.8.0-19] - 2020-09-19
### Added
- CBAMDEV-1438: fix selfcheck liveness path

## [20.8.0-18] - 2020-09-18
### Added
- CBAMDEV-1438: CVEA adapter lib path added

## [20.8.0-17] - 2020-09-17
### Added
- CSFOAM-6268: Remove REST Config interface from CALM

## [20.8.0-16] - 2020-09-17
### Added
- CBAMDEV-1526 GAP:CALM: Add post-delete job to clean up PVCs created by CALM Helm Chart

## [20.8.0-15] - 2020-09-17
### Added
- CSFS-28491: Accessing CALM REST APIs and SNMP for CALM installation via helm chart

## [20.8.0-14] - 2020-09-17
### Added
- CSFS-26401: provision to pass an existing service account name at the CALM chart level

## [20.8.0-13] - 2020-09-16
### Added
- CBAMDEV-1438: Property file name changes, property changes

## [20.8.0-12] - 2020-09-15
### Added
- CSFS-28619: alma.maxThreads and alma.maxSnmp4jThreads to be made configurable

## [20.8.0-11] - 2020-09-08
### Added
- CSFS-28394: Specify delete policy for all CALM Helm tests

## [20.8.0-10] - 2020-09-02
### Added
- CSFS-27038: Add post-delete job to clean up PVCs created by CALM Helm Chart

## [20.8.0-9] - 2020-09-01
### Added
- CSFOAM-4624: verify if istio is enabled in test

## [20.8.0-8] - 2020-08-28
### Added
- CSFS-27034: Not able to store more then 1k alarm

## [20.8.0-7] - 2020-08-27
### Added
- CSFS-27257: If CNI is already available, don't create Istio PSP and Istio RBAC objects

## [20.8.0-6] - 2020-08-26
### Added
- CSFOAM-4624: istio enabled for CALM REST component

## [20.8.0-5] - 2020-08-26
### Added
- CSFOAM-4624: Fix role for helm test

## [20.8.0-4] - 2020-08-14
### Added
- CSFOAM-4624: CALM support BCMT with istio enabled
- CSFID-3264: CALM- Account for Policy in Istio 1.4 vs PeerAuthentication in later versions
- CSFS-22314: Istio support for CALM with MTLS
- CSFS-27252: CALM: Add support to add prefix to pod names and container names

## [20.8.0-3] - 2020-08-11
### Added
- CSFS-26143: Add fixAlarmCreateTimeIsUTC flag

## [20.8.0-2] - 2020-07-31
### Added
- CSFOAM-5926: Fix UDP expose

## [20.8.0-1] - 2020-07-20
### Added
- CSFOAM-5926: chart tests

## [20.6.2] - 2020-06-30
### Added
- CSFOAM-5806: Rename created enum

## [20.6.1] - 2020-06-26
### Added
- CSFOAM-5455: CALM support BCMT with istio enabled phase1 for SPS / VZ
- CSFS-23081: CALM: External RBAC Security Configuration
- CSFS-21121: (CALM) Introduce default entry for CVEA MOC_Name field

## [20.4.0] - 2020-04-24
### Added
- CSFS-22145: CALM: Helm Port Istio-Style Formatting

## [20.2.3] - 2020-04-01
### Added
- CSFS-22184: CALM version 20.02.1 docker image update.

## [20.2.2] - 2020-03-12
### Added
- CSFS-22184: CALM version 20.02.001 is not semantic versioning compliant.

## [20.02.001] - 2020-03-04
### Added
- CSFOAM-4669: IPv6,cbur version update

## [19.7.1] - 2019-10-29
### Added
- CSFOAM-4844: Add helm test cases
- CSFOAM-4531: Alarm de-duplication feature
- CSFS-15795: Print log to stdout

## [19.6.0] - 2019-09-03
### Added
- CSFOAM-4104: CALM must be configurable to communicate with CVEA following VES 5.x or VES 7.x
- CSFS-14835: CALM can not start while BTEL helm upgrade with option --recreate-pods
- CSFOAM-4471: CALM support alarm autoretire
- CSFS-15748: cannot change log level of calm-config-rest service via values.yaml
- CSFOAM-4572: alma-config image fails to listen on ::
- CSFOAM-3409: Comply with ComPaaS HELM Dev Guide

## [19.5.10] - 2019-07-31
### Added
- CSFS-14783: Log compression is not handled for all the calm related logs
- CSFS-14783: Revert the changes of Log compression
- CSFOAM-3995: fix bug of backup and restore

## [19.5.9] - 2019-06-30
### Added
- CSFOAM-4017: Upload final version for CALM 19.06.1

## [19.5.8] - 2019-06-24
### Added
- CSFOAM-3505: Rest-config no longer supports the NCM API

## [19.5.7] - 2019-06-21
### Added
- CSFS-14245: Upload test chart for BTEL
- CSFOAM-3503: values.yaml supports port compatibiliy
- CSFOAM-4027: Set default value of predefined sidecar as true
- CSFOAM-3858: Support severity configurable

## [19.5.6] - 2019-06-14
### Added
- CSFOAM-3858: Upload final version for CALM 19.06

## [19.5.5] - 2019-06-04
### Added
- CSFS-13834: Add multi-realm parameters for alma-config

## [19.5.4] - 2019-06-04
### Added
- CSFS-13497: Support backup and restore use pre defined sidecar on Compass

## [19.5.3] - 2019-06-03
### Added
- CSFOAM-3503: Support restful api for config based on pure k8s api

## [19.5.2] - 2019-05-30
### Added
- CSFOAM-3858: Upload final version for CALM 19.04.1

## [19.5.1] - 2019-05-08
### Added
- CSFS-12906: Update calm/alma-config image to newest version

## [19.5.0] - 2019-04-30
### Added
- CSFS-12645: Support backup and restore use pre defined sidecar

## [19.4.0] - 2019-04-15
### Added
- Support configmap reloader for CALM and readnessprobe

## [19.3.1] - 2019-03-08
### Added
- Modify imageTag

## [19.3.0] - 2019-02-28
### Added
- Make semver compliant
- Support Https for CNOT Adapter
- CSFS-9962: Make default.host in alma-warpath.properties configurable

## [19.2.2] - 2019-02-18
### Added
- Add description about how to configure cnot adaptor in values.yaml

## [19.02.1] - 2019-01-31
### Added
- Support CNOT Adapter

## [19.01.1] - 2019-01-31
### Added
- Modify imageTag

## [18.12.6] - 2019-01-25
### Added
- Modify imageTag, storageclass and nodeport default values

## [18.12.5] - 2019-01-23
### Added
- Support config br and heal

## [18.12.4] - 2019-01-17
### Added
- Fix bug on compaas

## [18.12.3] - 2019-01-10
### Added
- Support compaas

## [18.12.2] - 2019-01-04
### Added
- Support to configure snmp mib

## [18.12.1] - 2018-12-29
### Added
- Bug fix for multi-tenancy support

## [18.10.9] - 2018-12-27
### Added
- Support multi-tenancy related configurations

## [18.10.8] - 2018-12-18
### Added
- Fix endpoints error

## [18.10.7] - 2018-12-17
### Added
- Support to configure context for snmp4j

## [18.10.6] - 2018-12-14
### Added
- Support calm config rest modify

## [18.10.5] - 2018-11-27
### Added
- Create calm config rest pod

## [18.10.4] - 2018-11-8
### Added
- Fix to support Kafka MQ in BCMT 18.06

## [18.10.3] - 2018-10-30
### Added
- Support to disable persistence

## [18.10.2] - 2018-10-23
### Added
- CALM supports to create kafka topic and partition

## [18.10.1] - 2018-10-22
### Added
- Support Kafka MQ

## [18.09.1] - 2018-09-27
### Added
- modify chart version, promote to stable

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

