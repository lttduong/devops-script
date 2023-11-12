# Changelog
All notable changes to chart **belk-fluentd** will be documented in this file
which may be read by customers.

## [Unreleased]

## [4.7.2] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename

## [4.7.1] - 2020.09.30
### Added
- added prometheus source
- updated README.md file
- updated few fluentd parameters in README.md file
- added enable cvea to the configs
- added duplicate message handling in fluentd config in the elastich search
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- Updated job and job template name
- CSFS-28597: Added new headless service for prometheus
- Added dest rule for fluentd service for istio 1.4

## [4.7.0] - 2020.08.14
### Added
- fluentd docker image update for version upgrade 1.11.1, kubernetes_metadata_fliter updated to 2.5.2 and clog plugin fluent-plugin-prometheus updated to 1.8.01
- Moved docker image to delivered

## [4.6.2] - 2020.07.14
### Added
- Added fsGroup, supplementary groups, MCS label 
- Added liveness and readiness probe checks
- Added run as non-root condition check in fluentd daemonset.
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for customized labels to pods
- Helmbestpractice changes for service account and rbac flag
- Added fluent-plugin-cvea-log by CLOG
- Added cvea plugin dependecies in docker image
- Moved docker image to delivered

## [4.6.1] - 2020.04.21
### Added
- Helm3 changes
- Istio-Style Formatting for ports
- Creation of separate service for fluentd-forward plugin

## [4.6.0] - 2020.02.12
### Added
- Modified post-delete job with proper roles
- Added file buffer in belk.conf
- Added parameters reconnect_on_error,reload_on_failure,reload_connections in all .conf files
- Upgraded td-agent to 3.6.0
- Added request_timeout parameter in all .conf files
- Added autoUpdateCron in BrPolicy for automatically deleting/creating/updating cronjob based on other parameters
- Increased default limits,requests values for memory and cpu
- Moved docker image to delivered

## [4.5.17] - 2020.01.31
### Added
- CSFS-17741:Wrong way of getting current time

## [4.5.16] - 2019.12.18
### Added
- Added fluentd-http output plugin to docker image
- Updated belk.conf fluentd configuration to support for BCMT IPv6
- Added fluentd plugins: route, concat, grok-parser
- Added clog provided plugins from fluent-plugins-3.4.1-1.0.2.x86_64.rpm
- Removed nss,libd package from fluentd image
- Moved fluentd image to delivered

## [4.5.15] - 2019.11.12
### Added
- Added fluentd-http output plugin to docker image
- Updated belk.conf fluentd configuration to support for BCMT IPv6
- Added fluentd plugins: route, concat, grok-parser
- Added clog provided plugins from fluent-plugins-3.4.1-1.0.2.x86_64.rpm
- Removed nss,libd package from fluentd image

## [4.5.14] - 2019.10.30
### Added
- Added postscalein job to delete unused PVCs
- CSFLDA-2118: Added BrPolicy for configmap restore
- Added autoEnableCron in BrPolicy
- Upgraded base image to centos-7.7
- Updated registry parameter
- Moving fluentd image to docker-delivered

## [4.5.13] - 2019.10.04
### Added
- Added affinity to fluentd daemonset

## [4.5.12] - 2019.10.01
### Added
- Upgraded kubectl image to v1.14.7-nano 

## [4.5.11] - 2019.09.23
### Added
- support for parsing non-container alarms for BCMT 19.09

## [4.5.10] - 2019.09.23
### Added
- add toleration for daemonset

## [4.5.9] - 2019.09.20
### Added
- add nodeSelector for daemonset

## [4.5.8] - 2019.09.06
### Added
- modify prometheus configuration in clog fluentd configuration to support for BCMT IPv6

## [4.5.7] - 2019-09-03
### Added
- update clog fluentd configuration to support for BCMT IPv6

## [4.5.6] - 2019-08-30
### Updated
- Added registry1 parameter for kubectl image

## [4.5.5] - 2019-08-26
### Fixed
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully

## [4.5.4] - 2019-07-19
### Fixed
- update clog fluentd configuration for C API

## [4.5.3] - 2019-07-08
### Added
- Moved all images to delivered


## [4.5.2] - 2019-07-05
### Fixed
- Added required field ServiceName in StatefulSet to comply with K8S API spec
### Updated
- Removed unrequired field updateStrategy from Deployment to comply with K8S API spec

## [4.5.1] - 2019-07-03
### Fixed
- Fix a fluentd configuration issue for journal

## [4.5.0] - 2019-07-03
### Added
- Added securityContext privileged to support reading non-container logs when docker selinux is enabled on BCMT

## [4.4.29] - 2019-07-03
### Fixed
- Fix a fluentd configuration issue for non-container audit log

## [4.4.28] - 2019-07-01
### Updated
- removed pos_file parameter for systemd plugin in belk.conf

## [4.4.27] - 2019-07-01
### Update
- Update fluentd docker image tag

## [4.4.26] - 2019-06-28
### Added
- Updated fluentd-clog plugin to 0.1.2
- Added job resources and security annotations in post-delete

## [4.4.25] - 2019-06-25
### Fixed
- Upgraded to td-agent 3.4.1 (fluentd-1.4.2)
- Add double quotation marks for SYSTEM and SYSTEMID in daemonset/deployment/statefulset
- update clog-json file for time issue
- Update docker image tag

## [4.4.24]
### Added
- CSF chart relocation rules enforced
- Support non-container log message

## [4.4.23] - 2019-06-07
### Added
- CSFS-13747: Added metrics port to fluentd service and pod
- Added enable_root_privilege flag to fluentd deployment

## [4.4.22] - 2019-05-13
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [4.4.21] - 2019-05-10
### Added
- CSFS-12268:Add fullnameOverride tag to BELK helm charts

## [4.4.20] - 2019-05-08
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [4.4.19] - 2019-05-03
### Added
- Added latest clog-journa.conf and clog-json.conf

## [4.4.18] - 2019-04-30
### Added
- Added ssl properties to fluentd configuration
- Added searchguard configuration for clog-json.conf, clog-journal.conf files
- Moved images to delivered.
- CSFS-11586: Journal log event fields are not searchable

## [4.4.17] - 2019-04-25
### Added
- Upgraded base image

## [4.4.16] - 2019-04-25
### Added
- Added ssl properties to fluentd configuration
- Added searchguard configuration for clog-json.conf, clog-journal.conf files

## [4.4.15] - 2019-04-23
### Added
-Corrected clog-journal.conf and clog-josn.conf files

## [4.4.14] - 2019-04-17
### Added
-Corrected clog-journal.conf file

## [4.4.13] - 2019-04-17
### Added
-Updated clog-json.conf and clog-journal.conf for brevity and clog plugins.

## [4.4.12] - 2019-04-16
### Added
-CSFS:12219-Invalid Time format

## [4.4.11] - 2019-04-09
### Added
-CSFS:11586-Journal log event fields are not searchable

## [4.4.10] - 2019-03-29
### Added
-Added clog configuration
-Removed extra configuration of prometheus

## [4.4.9] - 2019-03-29
### Added
-Added clog configuration 


## [4.4.8] - 2019-03-26
### Added
- Upgraded base image to Centos 7.6
- Moved images to stable

## [4.4.7] - 2019-03-22
### Added
- Upgraded base image to Centos 7.6

## [4.4.6] - 2019-03-07
### Added
- Included CLOG related plugins(fluent-plugin-remote_syslog, remote_syslog_sender, syslog_protocol, fluent-plugin-brevity-control )


## [4.4.5] - 2019-03-05
### Added
- Included CLOG related plugins(fluent-plugin-remote_syslog, remote_syslog_sender, syslog_protocol, fluent-plugin-brevity-control )

## [4.4.4] - 2019-02-28
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- Test move charts to stable


## [4.4.3] - 2019-02-27
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [4.4.2] - 2019-02-21
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [4.4.1] - 2019-02-14
### Added
- CSFLDA-1543: Implemented Fluentd POD anti-affinity rules

## [4.4.0] - 2019-02-13
### Added
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [4.3.3] - 2019-01-15
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus(annotations added)

## [4.3.2] - 2019-01-10
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus(annotations added)


## [4.3.1] - 2019-01-10
### Added
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2(So downgraded fluent-plugin-kubernetes_metadata_filter to 1.0.1)
- CSFS-9183:fluentd metrics are not visible in prometheus

## [4.3.0] - 2018-12-20
### Added
- Upgarde of td-agent to 3.2.1

## [4.2.5] - 2018-11-27
### Added
- secret creation is added for prometheus

## [4.2.4] - 2018-11-22
### Added
- Prometheus plugin added

## [4.2.3] - 2018-10-29
### Changed
- Added mulitline parser plugin

## [4.2.2] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.2.1] - 2018-09-19
### Changed
- Added space for image name

## [4.2.0] - 2018-08-31
### Added
- Install and delete LCM events are added for fluentd.

## [4.1.1] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry 

## [4.1.0] - 2018-08-28
### Changed
- Updated to the chart to use fluentd version 1.2.2
- Changed fluent to run as root user and created respective rolebinding to fix permission issue

## [4.0.2] - 2018-08-23
### Changed
- Changelog updated

## [4.0.1] - 2018-08-17
### Changed
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Changed
- Charts to follow semver2 semantic


## [1.0.2-18.07.02] - 2018-08-06
### Added
-  PSP/RBAC support

### Changed
-  Chart to follow semantic naming. belk-<component>-<opensource version>-<csf release year>.<csf release month>.<patch> 
   eg: belk-fluentd-1.0.2-18.07.02
-  docker image on Centos 7.5

