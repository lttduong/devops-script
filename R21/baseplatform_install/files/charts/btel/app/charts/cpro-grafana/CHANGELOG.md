# Changelog
All notable changes to chart **cpro-grafana** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Changed
### Security
### Fixed

## [3.16.1] - 2020-10-07
###Added
- CSFS-29417: Fixed dashboard rendering issue
- CSFS-20114: Grafana application title is user configurable
- CSFS-29475: Fixed grafana dashboard issue

## [3.16.0] - 2020-10-01
###Added
- CSFS-28115: Grafana should provide support for cbur autoUpdateCron parameter in BrPolicy
- CSFS-26510: Grafana allows password policy allows to set "@" character to grafana admin user password post this the subsequent upgrade fails
- CSFOAM-6172: Grafana chart changes to fix CSFS-27259
- CSFOAM-6234: CSFS-27347 grafana changes to expose metrics via service
- CSFOAM-6216: Updated grafana tenant docker image tag
- CSFS-18500: Updated file permissions for grafana volumes
- CSFS-17235: Fixed prometheus datasource error upon upgrade
- CSFOAM-6300: Update image tag and change registry to candidates
- CSFS-24504: Add Datasource button is added.
- CSFS-25869: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-24478: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-26961: SignIn redirection issue is solved wih grafana upgrade.
- CSFS-22926: Playlist can be saved after grafana upgrade.
- CSFS-27322: SignIn redirection issue is solved wih grafana upgrade.
- CSFOAM-6336: Updated hook deletion policy for update datasource job
- CSFOAM-6339: Auto Import dashboards and SetDatasource is failing for grafana in cpro-grafana-3.16.0-10.tgz
- CSFOAM-6371: updating readme.md for cpro-grafana

## [3.15.0] - 2020-09-01
###Added
CSFOAM-6154: Fix for grafana upgrade failure from cpro-grafana-3.14.0 to cpro-grafana-3.15.0-7
- CSFS-25109: CPRO chart has dependency on K8s version in EKS
- CSFS-25970: Specify resources for all containers
- Apply helm best practice for 'Relocatable Chart', global.registry2 is added for sidecar repository and global.registry5 is added for sane repository
- CSFS-27188, CSFS-27192, CSFS-27151: istioVersion as integer, support to integrate with external CKEY and readiness failure in istio 1.5 
- CSFS-24674: cpro-grafana support to evaluate _url config parameters as Template
- CSFOAM-5996 Grafana pods are going in crashloop backoff
- CSFS-24195: Added cookie_secure flag to grafana.ini

## [3.14.1] - 2020-07-23
###Added
- CSFS-26617: Grafana delete datasource job failing 

## [3.14.0] - 2020-07-16
#Added
- CSFS-26495: Support to provide option for global.istioVersion

## [3.13.0] - 2020-07-14
### Added
- ISTIO ingress certificate update to credentialName
- CSFOAM-5536: Grafana containers runs on single user id and runAsUser,fsGroup and supplementalGroups are configurable
- CSFOAM-5546: Added mcs label, seccomp and apparmor annoations
- CSFOAM-5849: Helm Best Practice changes for Grafana chart
- CSFOAM-5878: Added service entry and virtual service to support ckey.
- CSFS-23095: Added Golbal serviceAccountName
### Changed
- CSFS-25041: BTEL Grafana Helm chart backup using CBUR error - incorrect cmdb service name
- CSFS-22407: Grafanas "Kubernetes cluster monitoring (via Prometheus)" not showing the pods anymore
- CSFOAM-5550: istio single-gateway functionality , DestinationRule and Policy have been updated.
- CSFOAM-5551: istio changes for peer authentication
- CSFOAM-5793: Adding configuration for istio role,rolebinding
- CSFOAM-5855: docker image update and istio-mutual support
- CSFOAM-5882: match label for peer authentication
- CSFOAM-5921: PSP creation , when CNI is disabled doesnot have NET_RAW in allowedCapabilities
- CSFOAM-5943: fix for Grafana not coming up with internal cmdb when istio enabled

## [3.12.0] - 2020-05-11
### Added
- Helm Port Istio-Style Formatting
- CSFOAM-5316: Updated grafana docker image tag
- CSFOAM-5315: Upgraded Grafana component to the latest version

## [3.11.3] - 2020-03-14
### Added
- CPRO-Grafana Helm3 K8s 1.17 Compliance

## [3.11.2] - 2020-03-10
### Added
- Udating the tools/kubectl image version

## [3.11.1] - 2020-03-05
### Added
- Updating the semverCompare condition for helm3 upgrade

## [3.11.0] - 2020-03-03
### Added
- Updated to remove the deprecate K8S APIs
- docker image versions updated
- cmdb version changed from 6.3.1 to 7.6.0
## [3.10.0] - 2020-01-28
### Added
- Chart changes to support sane authentication using auth proxy
- By default sane is disabled
## [3.9.1] - 2019-12-20
### Added
- Remove Grafana logo, icon to overcome security trademark violations
- CSF chart relocation rules enforced
- Add istio feature
- Add a switch to retain cmdb data
### Changed
- Fix ticket CSFOAM-2687 in 1.0.3-2
- Change certification method. Avoiding manual steps in 1.0.3
### Security
- Integration with Grafana and Keycloak
### Fixed
CSFOAM-4490: image update for mysql deadlock issue

## [3.0.9] - 2019-09-24
### Fixed
- CSFS-16527:Grafana oauth session is forcely invalidated after "Access Token Lifespan" is exceeded

## [3.0.8] - 2019-09-10
### Added
- Added alertmanager datasources plugin
- Added bar chart and pie chart plugins
- Added before-hook-creation for import dashboard and datasource job.
- Added node-exporter-full dashboard.
- Supports to set existing keycloak secret in values.yaml
### Changed
- Change image to nano.
- Changed defaut ssl key and cert.
- helmDeleteImage updated to v1.14.3-nano
- Default pv size changed back to 1G.
- Removed session part in values.yaml
### Fixed
- Dashboard and datasource can be overwrited during upgrade.

## [3.0.7] - 2019-07-31
### Fix
- Fixed keycloak session issue

## [3.0.5] - 2019-07-4
### Changed
- Change Deployment to StatefulSet
- Change DS_PROMETHEUS to prometheus in dashboard
- Add backoffLimit parameter

## [3.0.4] - 2019-07-2
### Changed
- Add registry2 in deployment.yaml and values.yaml

## [3.0.3] - 2019-06-26
### Changed
- Change Values.schema to Values.scheme
- Fixed set datasource issue
- Add key pspUseAppArmor

## [3.0.2] - 2019-06-24
### Changed
- Fix initContainers bug in template

## [3.0.1] - 2019-06-19
### Changed
- Add a key deployOnCompass to 3.0.0

## [3.0.0] - 2019-06-19
### Changed
- Upgrade grafana version to 6.2.2

## [2.0.22] - 2019-06-26
### Changed
- Change Values.schema to Values.scheme
- Fixed set datasource issue

## [2.0.21] - 2019-06-25
### Changed
- Add key pspUseAppArmor

## [2.0.20] - 2019-06-24
### Changed
- Fix initContainers bug in template

## [2.0.19] - 2019-06-20
### Changed
- Add a key deployOnCompass to 2.0.18

## [2.0.18] - 2019-06-19
### Changed
- Change image tag

## [2.0.17] - 2019-06-13
### Changed
- Fixed post-delete secret issue
- support cpro-grafana to deploy on ComPaaS
- Parameterize CBUR configurations for cpro-grafana chart

## [2.0.15] - 2019-06-5
### Changed
- TLS can support between MariaDB and Grafana
- Fixed upgrade defects

## [2.0.13] - 2019-05-31
### Changed
- Made br policy configurable and fixed upgrade from 1.0.9.

## [2.0.10] - 2019-05-17
### Changed 
- Fixed backup/restore and upgrade issue.

## [2.0.5] - 2019-03-11
### Changed
- Change default database and session

## [2.0.4] - 2019-03-11
### Changed
- Change default ha value to false

## [2.0.3] - 2019-02-20
### Fixed
- Delete import-dashboard and set-datasource jobs when hook-succeeded
- Change post-delete job name

## [2.0.2] - 2019-01-31
### Fixed
- Fixed security policy for upgrade event

## [2.0.1] - 2019-01-30
### Changed
- Grafana HA support initial version
- Using cmdb 6.3.1
- Fix issue with NodeExporter 0.15.2 -> 0.16.0 (A lot of metrics were given different names)
- Support upgrading from version 1.0.9 using mariadb to this version

## [1.0.15] - 2019-1-21
### Changed
- Changed image tag to 1.5 so can be deployed in BCMT 18.12

## [1.0.14] - 2019-1-8
### Changed
- Add flag for BrPolicy

## [1.0.13] - 2018-12-28
### Changed
- Add Tenantlabel and Tenantvalue in Grafana for Prometheus Multi-tenancy support
- Limited to install under BCMT environment for adding BrPolicy

## [1.0.12] - 2018-12-28
### Changed
- Update grafana docker image

## [1.0.11] - 2018-12-19
### Changed
- Add brpolicy and upgrade for db schema change

## [1.0.10] - 2018-11-29
### Changed
- Adopt global relocation

## [1.0.9] - 2018-10-24
### Fixed
- Avoid updating password after Helm upgrade

## [1.0.8] - 2018-10-24
### Fixed
- Avoid updating password after Helm upgrade

## [1.0.7] - 2018-09-11
### Fixed
- Use CSF-built Grafana docker image

## [1.0.6] - 2018-09-10
### Fixed
- CSFS-6627: cpro-grafana upgrade issue. Change UpgradeStrategy

## [1.0.5] - 2018-09-09
### Fixed
- Avoiding 3rd party images. Use csf-built ones

## [1.0.4] - 2018-09-03
### Fixed
- Avoiding manual steps in 1.0.3

## [1.0.3] - 2018-08-29
### Added
- CSF chart relocation rules enforced
- Enable HTTPS for Grafana
- Integration with Grafana and Keycloak
### Security
- Enable HTTPS for Grafana
- Integration with Grafana and Keycloak
### Deprecated
- Deprecated because of manual steps

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
