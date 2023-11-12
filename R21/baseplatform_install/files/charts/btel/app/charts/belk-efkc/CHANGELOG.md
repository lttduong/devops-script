# Changelog
All notable changes to chart **belk-elkc** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
- CSF chart relocation rules enforced

## [6.3.2] - 2020-10-08
### Updated
- CSFOAM-6395: Updated templatename with chart.templatename

## [6.3.1] - 2020-09-30
### Updated
- Fixed trademark bugs for CSFLDA-2765, CSFLDA-2764
- Updated readme file for efkc chart
- CSFS-28353: Added TIMESTAMP_FIELD field as environmental value
- Added support for istio 1.4
- Addition of prefix to pod names, job and container names
- Added nameoverride and fullname override configuration changes
- Updated job and jobcontainer template names
- CSFS-28597: Added new headless svcs in elasticsearch & fluentd for cpro server to scrape metrics
- made repo user configurable to choose between centos7 and centos8 images
- Added dest rule for fluentd service for istio 1.4
- Sub-charts and docker images are moved to delivered

## [6.3.0] - 2020-08-31
### Updated
- CSFS-22644:Added support to accept precreated curator configmap.
- CSFS-24844: Updated kibana sg-configmap parameters to be evaluated as template
- CSFS-26654: Added server.rewritebasepath as kibana env property to remove the warning
- CSFS-23274: Added csp.strict in kibana_configmap_yml
- Added support for mounting additional certificates to kibana pod
- Helm hook-delete-policy of pre/post-upgrade jobs made user configurable
- CSFS-24844: Updated ES sg-configmap parameters to be evaluated as template
- Upgrade ES, Kibana to 7.8.0
- CSFS-26865: Updated the elasticsearch-graphana.json
- Updated cbura imageTag
- Added support for log exporter plugin
- fluentd docker image update for version upgrade 1.11.1, kubernetes_metadata_fliter updated to 2.5.2 and clog plugin fluent-plugin-prometheus updated to 1.8.01
- certificates for transport layer generated as part of docker entrypoint when istio is enabled 
- CSFS-27150: Added support for CKEY external to istio mesh
- Excluded .signals* indices from ES Backup restore
- Replaced CMS garbage collector with G1GC in elasticsearch
- Trademark changes for 7.8.0 kibana
- Incremental Trademark changes for 7.8.0 Kibana
- Kibana chart with latest csan, exporter plugin
- Added env variables for exporter plugin
- Moved docker images to delivered

## [6.2.0] - 2020-07-14
### Updated
- Added Pod affinity for ES chart
- Added fsGroup, supplementary groups, SELinux label
- Added liveness and readiness probes check
- Support for pre-created Service Account, role and rolebinding
- Added run as non-root condition check in fluentd daemonset
- Added customized security annotation which are user configurable
- Added provision for customized labels to pods
- Added support for istio
- Added istio-ingress gateway support
- Helmbestpractice changes for service account and rbac flag
- Added fluent-plugin-cvea-log by CLOG
- Fixed SG 6-7 upgrade issue when istio is enabled
- Added cleanup-job to delete remaining resources on purge
- Updated es-prometheus pod level annotations to work with istio enabled chart
- Integration with keycloak in mTLS
- Fixed elasticsearch helm3 issue with headless svc
- Moved docker images to delivered

## [6.1.1] - 2020-04-24
### Updated
- Helm3 changes
- Istio-Style Formatting for ports
- Creation of separate service for fluentd forward plugin

## [6.1.0] - 2020-03-19
### Updated
- Added service account to curator
- Upgraded curator to 5.8.1
- Updated job spec and job template parameters to be user configurable
- Modified service account for elasticsearch
- Modification of role in Post-delete job
- Handled sg migration failures on data node not detected(Delivered as BELK-19.12 patch with chart version 6.0.1810)
- Fix for files have insecure file permission in elasticsearch image
- Improved backup and restore scripts in elasticsearch docker
- Added permission in post-upgrade job to view logs of pod
- Added support for ES cipher suites
- Modified post-delete job with proper roles in fluentd 
- Added file buffer in belk.conf
- Added parameters reconnect_on_error,reload_on_failure,reload_connections in all .conf files
- Added service account for kibana
- Added kibana optimization for SG and CSAN in k_sg image
- Docker image file permissions are changed and restricted
- Updating values-model and values-template files for compaas
- Added autoUpdateCron in BrPolicy of all charts for automatically deleting/creating/updating cronjob based on other parameters
- Upgraded td-agent to 3.6.0, added request_timeout parameter in fluentd config files
- Increased fluentd default limits,requests values for memory and cpu
- CSFS-18987: Kibana UI changes done to correct trademark policy violations
- Modified default ingress path to /logviewer
- Moved docker images to delivered

## [6.0.18] - 2019-12-19
### Updated
- Added latest csan plugin in kibana chart
- Added es-prometheus annotations at pod level(es-master,es-data,es-client)
- Modified readiness probe for es-client to check searchguard health
- Configuration changes for IPv6 compatibility
- Fix for elasticsearch-client pod logs breaking terminal
- Added fluentd plugins: route, concat, grok-parser and clog provided plugins
- Updated docker images with latest centos base images
- Removed belk-elasticsearch-exporter chart from efkc
- Moved all sub-charts to stable

## [6.0.17] - 2019-10-30
### Updated
- Updated individual chart names in values-template file
- Added es-prometheus service to scrape elasticsearch metrics
- Added postscalein job in es and fluentd for deleting unused PVCs
- Updated es-prometheus service to add flag for SG enabled
- Improved SG migration code for ELK6 to ELK7 upgrade and removed sg_migrate flag.
- CSFLDA-2118: Added/updated BrPolicy in es, kibana and fluentd for configmap restore
- Creating optimize directory in kibana image
- Added autoEnableCron in Brpolicy of all charts
- Updated base images to centos-7.7, updated cbura image to 1.0.3-983
- Updated elasticsearch to latest java base image
- Moving all the individual charts to stable

## [6.0.16] - 2019-10-04
### Updated
- Moved belk-efkc individual charts to stable

## [6.0.15] - 2019-09-11
### Updated
- Modified readiness probe of es-master(CSFLDA-2113)
- Fixed indentation for nodeSelector in es-client & es-master
- Fluentd clog configuration updated to support for BCMT IPv6
- Added nodeSelector, toleration for fluentd daemonset
- Fluentd clog configuration updated for parsing non-container alarms for BCMT 19.09
- Added ignoreFileChanged in elasticsearch Brpolicy
- Upgraded kubectl image to v1.14.7-nano

## [6.0.14] - 2019-08-30
### Updated
- Moved belk-efkc individual charts to stable

## [6.0.13] - 2019-08-26
### Updated
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully 

## [6.0.12] - 2019-08-23
### Updated
- CSFS-15048: Updated cbura sidecar image to 1.0.3-871

## [6.0.11] - 2019-08-22
### Updated
- CSFLDA-1975: Moved all efkc chart images to buildah

## [6.0.10] - 2019-08-19
### Added
- CSFS-14508: Added secret, env and values for csan

## [6.0.9] - 2019-08-19
### Added
- Fixed kibana index re-index issue in postRestore
- Updated fluentd Clog configuration for C API
- Added /tmp for cbur sidecar for backup
- Moved all charts to stable

## [6.0.8] - 2019-08-12
### Added
- Fixed kibana index re-index issue in postRestore
- Updated fluentd Clog configuration for C API

## [6.0.7] - 2019-08-06
### Added
- Increased /tmp directory for cbur-sidecar

## [6.0.6] - 2019-08-05
### Added
- Fixed kibana restore issue.
- Added /tmp for cbur sidecar for backup

## [6.0.5] - 2019-07-26
### Added
- CSFS-14403: Added user configurable capture group for kibanabaseurl.
### Updated
- CSFS-14419: Made network_host user configurable.

## [6.0.4] - 2019-07-08
### Added
- Upgrade ELK to 7.0.1
- Upgraded td-agent to 3.4.1
- Moved all charts to stable

## [6.0.3] - 2019-07-06
### Added
- Added fix for upgrade(ES-6 to ES-7) issue by adding SG migrate script.
- Added pvc for master pods to persist cluster state
- Added security context to fluentd

## [6.0.2] - 2019-07-01
### Added
- Updated BrOption to 0
- Updated fluentd and elasticsearch chart

## [6.0.1] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1 

## [6.0.0] - 2019-06-28
### Added
- Upgraded ELK to 7.0.1
- Upgraded td-agent to 3.4.1

## [5.3.15] - 2019-06-27
### Added
- Moved kibana chart to stable


## [5.3.14] - 2019-06-27
### Added
- Moved kibana chart to stable
- Added server.ssl.supportedProtocols: ["TLSv1.2"] to kibana configmap

## [5.3.13] - 2019-06-26
### Added
- Added kibana-csan plugin to kibana docker image

## [5.3.12] - 2019-06-09
### Added
- CSFS-13747: Added fluentd prometheus metrics port
- Added enable_root_privilege flag to fluentd deployment

## [5.3.11] - 2019-05-31
### Add
- Updated brOption and added cbur resource limits
- Added security annotations to all charts
- Moved all charts to stable

## [5.3.10] - 2019-05-28
### Added
- Updated brOption and added cbur resource limits

## [5.3.9] - 2019-05-21
### Added
- Added security annotations to all charts

## [5.3.8] - 2019-05-21
### Added
- Added security annotations to charts

## [5.3.7] - 2019-05-15
### Added
- CSFID-2215:Add ElasticSearch dashboard for grafana

## [5.3.6] - 2019-05-14
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default

## [5.3.5] - 2019-05-10
### Added
- CSFS-11977:Fluentd app mounting /var/log and /data0/docker by default
- CSFS-12268:Add fullnameOverride tag to BELK helm charts 

## [5.3.4] - 2019-05-03
### Added
- Updated audit logging configuration for clog.conf files

## [5.3.3] - 2019-04-30
### Added
- Upgraded ELK to 6.6.1
- Removed sentinl plugin
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf
- Moved charts to stable

## [5.3.2] - 2019-04-26
### Added
- Upgraded base image


## [5.3.1] - 2019-04-25
### Added
- Added ssl parameter to fluentd chart

## [5.3.0] - 2019-04-25
### Added
- Upgraded ELK to 6.6.1
- Removed sentinl plugin
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf

## [5.2.9] - 2019-04-24
### Added
- Added fluentd chart to umbrella chart with updated clog fluentd configurations i.e clog-json.conf and clog-journal.conf

## [5.2.8] - 2019-04-22
### Added
- Added fluentd chart to umbrella chart with different fluentd configurations i.e belk.conf,clog-json.conf and clog-journal.conf

## [5.2.7] - 2019-04-02
### Added
- Added CLOG configuration to umbrella chart

## [5.2.6] - 2019-04-01
### Added
- Added CLOG configuration to umbrella chart


## [5.2.5] - 2019-03-27
### Added
- Upgraded docker base image to Centos 7.6
- Installed gems in fluentd  image to support CLOG
- Moved all images to delivered

## [5.2.4] - 2019-03-22
### Added
- Upgraded docker base image to Centos 7.6
- Installed gems in fluentd  image to support CLOG 

## [5.2.3] - 2019-03-18
### Added
- Installed sentil plugin for kibana 

## [5.2.2] - 2019-03-12
### Added
- CSFLDA-1590: Updated sg_roles and sg_roles_mapping with latest searchguard configurations

## [5.2.1] - 2019-03-11
### Changed
- CSFID-1611: Keycloak integration -added searchguard.openid.root_ca parameter to kibana configmap

## [5.2.0] - 2019-03-05
### Added
- CSFID-1611: Keycloak integration
- Liveness and Readiness probe modified for kibana

## [5.1.5] - 2019-02-28
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets
- CSFS-10055:Kibana readiness probe is added
- moved all charts to stable

## [5.1.4] - 2019-02-27
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart

## [5.1.3] - 2019-02-19
### Added
- CSFLDA-1521:TLS for belk-fluentd helm chart
- upgraded kubectl image in curator chart

## [5.1.2] - 2019-02-19
### Added
- CSFS-10055:Kibana readiness probe is added

## [5.1.1] - 2019-02-18
### Added
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [5.1.0] - 2019-02-15
### Added
- CSFLDA-1540:Implement ElasticSearch POD anti-affinity rules
- CSFLDA-1541:Implement Logstash POD anti-affinity rules
- CSFLDA-1542:Implement  Kibana POD anti-affinity rules
- CSFLDA-1543:Implement Fluentd POD anti-affinity rules
- Upgraded td-agent rpm to 3.3.0
- CSFID-1932:Installed fluentd postgres, genhashvalue, splunk plugins
- CSFID-1976:Fluentd supporting as statefulsets

## [5.0.3] - 2019-02-01
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana
- removed xpack env variable from docker image
- moved docker images to stable

## [5.0.2] - 2019-01-31
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana
- removed xpack env variable from docker image

## [5.0.1] - 2019-01-29
### Added
- Upgraded chart to 6.5.4-oss
- Reduced memory limit to kibana

## [5.0.0] - 2019-01-28
### Added
- Upgraded chart to 6.5.4-oss

## [4.4.8] - 2019-01-24
### Changed
- CSFLDA-1436:fixed snapshot name for postRestoreCommand and added removeGlusterfs.sh in the BrPolicy.yaml

## [4.4.7] - 2019-01-24
### Changed
- CSFLDA-1436:Removed snapshot name from values.yaml.

## [4.4.6] - 2019-01-15
### Changed
- CSFS-9322:Harmonized logging changed timezone
- CSFS-9181:elasticsearch metrics are missing from prometheus
- CSFS-9183:fluentd metrics are not visible in prometheus
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2
- CSFS-9384:efkc-belk-elasticsearch-client pods do not recover after error (OoM)
- CSFS-9385:ES-client threw OoM

## [4.4.5] - 2019-01-15
### Changed
- CSFS-9322:Harmonized logging changed timezone

## [4.4.4] - 2019-01-10
### Changed
- CSFS-9181:elasticsearch metrics are missing from prometheus
- CSFS-9183:fluentd metrics are not visible in prometheus
- CSFS-9192:JSON formatted log messages not properly parsed by fluentd 1.2.2
- CSFS-9384:efkc-belk-elasticsearch-client pods do not recover after error (OoM)
- CSFS-9385:ES-client threw OoM

## [4.4.3] - 2019-01-04
### Changed
- Upgarded charts to 6.5.1
- Backup and restore issues are fixed i.e CSFLDA-1414, CSFLDA-1420 and CSFLDA-1421
- Kibana issue fixed i.e CSFLDA-1407


## [4.4.2] - 2019-01-02
### Changed
- backup and restore issue fixed

## [4.4.1] - 2018-12-21
### Changed
- In backup if condition is added

## [4.4.0] - 2018-12-21
### Changed
- Upgarded charts to 6.5.1
- Backup and restore is added


## [4.3.6] - 2018-11-30
### Changed
- CSFS-7762:SG improvement.
- Fluentd chart with prometheus ssl
- Harmonized logging
- Local Storage added
- Fluent image with prometheus plugin
- Fix for data pod restart

## [4.3.5] - 2018-11-29
### Changed
- CSFS-7762:SG improvement.

## [4.3.4] - 2018-11-27
### Changed
- Fluentd chart with prometheus ssl

## [4.3.3] - 2018-11-26
### Changed
- ES chart with SG image changed

## [4.3.2] - 2018-11-22
### Added
- Local Storage added for efkc

## [4.3.1] - 2018-11-22
### Changed
- Fluentd prometheus plugin added
- Fix for restart of ES pod while upgrading

## [4.3.0] - 2018-11-22
### Changed
- Harmonized logging for ES
- Docker base image changes to latest with security fixes

## [4.2.6] - 2018-11-15
### Changed
- CSFS-7753: Moving kibana chart to stable

## [4.2.5] - 2018-11-13
### Changed
- CSFS-8273: Unable to install EFKC in ComPaaS and removed fluentd from umbrella chart in Compaas environment

## [4.2.4] - 2018-11-08
### Changed
- CSFS-7753: Adding host field for Kibana Ingress in efkc

## [4.2.3] - 2018-11-05
### Changed
- CSFS-7753:TLS support for ingress for efkc

## [4.2.2] - 2018-10-31
### Changed
- Moving all charts to stable

## [4.2.1] - 2018-10-30
### Changed
- Added all BELK upgraded charts(version 6.4.1) in the Umbrella and curator certificate change

## [4.2.0] - 2018-10-30
### Changed
- Added all BELK upgraded charts(version 6.4.1) in the Umbrella

## [4.1.11] - 2018-10-29
### Changed
- Changed the elasticsearch and kibana charts repo to stable
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value
- CSFS-7753: Ingress TLS support


## [4.1.10] - 2018-10-26
### Changed
- CSFS-7750:Ingress not configurable in kibana


## [4.1.9] - 2018-10-25
### Changed
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value
- CSFS-7753: Ingress TLS support
## [4.1.8] - 2018-10-24
### Changed
- CSFS-7748: BELK add proxy authentication support
- CSFS-7852: elasticsearch test* configmaps are still having http in use when searchguard is enabled
- CSFS-7699: Kibana ingress cannot be disabled by value

## [4.1.7] - 2018-09-27
### Added
- Heal LCM event for efkc is added.

## [4.1.6] - 2018-09-26
### Changed
- Refactored resource parameters of efkc

## [4.1.5] - 2018-09-20
### Changed
- Modified secret creation 

## [4.1.4] - 2018-09-10
### Changed
- Added update config for ES to take searchguard configmap from values file

## [4.1.3] - 2018-09-05
### Added
- Added update config and upgrade , rollback 

## [4.1.2] - 2018-09-04
### Changed
- CSFLDA-897:Fix for bug when deploying chart with wrong base64 password

## [4.1.1] - 2018-09-03
### Changed
- Modified elasticsearch to take upgrade strategy from values file

## [4.1.0] - 2018-08-30
### Added
- Added install and delete LCM events for efkc

## [4.0.4] - 2018-08-30
### Changed
- Updated image registry name from registry to global registry


## [4.0.3] - 2018-08-28
### Added
- CSFLDA-816 : Elasticsearch service endpoints issue
- Updated fluentd version to 1.2.2
### Changed
- Update fluentd to run as root user only to fix container logs permission issue

## [4.0.2] - 2018-08-24
### Added
- CSFS-4771:- Cannot deploy more than one ElasticSearch in a namespace

## [4.0.0] - 2018-08-13
### Added
- All future chart versions shall provide a change log summary
- PSP/RBAC support
### Changed
- Updated curator schedule in values.yaml
- Chart to follow semantic naming. belk-`component`-`opensource version`-`csf release year`.`csf release month`.`patch` 
  e.g.: belk-efkc-6.2.4-18.07.03
- docker image on Centos 7.5

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

