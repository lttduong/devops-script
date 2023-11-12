# Changelog
All notable changes to chart **cpro-gen3gppxml** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
###Added
### Changed

## [2.3.0] - 2020-10-01
#Added
- CSFS-28116: CPRO-gen3gppxml should provide support for cbur autoUpdateCron parameter in BrPolicy
- CSFOAM-6173: gen3gpp chart changes to fix CSFS-27259
- CSFOAM-6307: fullnameoverride for gen3gppxml chart
- CSFOAM-6300: Update image tag and change registry to candidates
- CSFOAM-6376: updating readme.md for cpro-gen3gppxml

## [2.2.0] - 2020-09-01
#Added
- CSFS-25109: CPRO chart has dependency on K8s version in eks
- CSFS-27188, CSFOAM-6042: istioVersion as integer and differnt gateway for tcp
- CSFOAM-5997 adding context root for gen3gppxml for istio virtual service
- CSFS-27037: Add post-delete job to clean up PVCs created by cpro-gen3gppxml Helm Chart

## [2.1.0] - 2020-07-16
#Added
- CSFS-26495: Support to provide option for global.istioVersion

## [2.0.0] - 2020-07-14
#Added
- CSFOAM-5530: Gen3gppxml RBAC configurable code
- CSFOAM-5685: Gen3gppxml chart changes for non-root container
- CSFOAM-5551: Configurability of external istio gateway, removing PSP, role, rolebinding creaton in non cni istio config
- CSFOAM-5690: Added MCS label configuration,seccomp and apparmor annotation
- CSFOAM-5532: Affinity/Anti affinity rules for gen3gppxml
- CSFOAM-5551: istio changes for peer authentication
- CSFOAM-5791: Disable NodePort service for Gen3gppxml
- CSFOAM-5855: docker image update and istio-mutual support
- CSFOAM-5856: Helm Best Practice changes for Gen3gppxml chart
- CSFOAM-5878: upgradation changes for nodeport to clusterIP
- CSFOAM-5882: match label for peer authentication
- CSFOAM-5921: PSP creation , when CNI is disabled doesnot have NET_RAW in allowedCapabilities
- CSFS-23095: Added Global serviceAccountName

## [1.3.0] - 2020-04-13
### Added
- Helm Port Istio-Style Formatting
- CSFS-22743 Pods/Containers should not run or require privileged mode.
- CSFS-21838 Some gen3gppxml files gone missing on a large setup
- CSFS-22743 run sftp container as user configured UID
- CSFOAM-5047: workaround for VAMS high sev bug on PyYAML
- CSFOAM-5389: fix for backup failure of gen3gpp
- CSFOAM-5315: Upgraded Gen3ppxml component to the latest version

## [1.2.0] - 2020-03-20
### Added

## [1.1.2] - 2020-03-14
### Added
- CSFS-22103 - CPRO-GEN3GPPXML Helm3 K8s 1.17 Compliance


## [1.1.1] - 2020-03-05
### Added
- Updating the semverCompare condition for helm3 upgrade

## [1.1.0] - 2020-03-13
### Added
- Added metric node_memory_MemAvailable_bytes
### Changed
- Updated to remove the deprecate K8S APIs

## [1.0.16] - 2019-11-07
### Added
- Add NodePort for sftp service

## [1.0.15] - 2019-11-07
### Fixed
- Fixed storageClassName indent issue.

## [1.0.14] - 2019-09-23
### Added
- Add istio feature

## [1.0.13] - 2019-09-12
- CSFOAM-4213: cpro-gen3gppxml helm chart shall update to run sftp and gen3gppxml service in separate container
## [1.0.12] - 2019-06-20
### Changed
- CSFOAM-4279: Cpro gen3gppxml tool helm chart supports 2 registries.
- CSFOAM-4241: CPRO-gen3gppxml make the default helm chart work with prometheus
- CSFS-13617: Make storageClass as optional for cvea and cpro-gen3gppxml
## [1.0.11] - 2019-05-21
### Changed
- Parameterize CBUR configurations

## [1.0.10] - 2019-01-31
### Added
- Rewrite helm chart
## [1.0.9] - 2018-10-29
### Fixed
- Input configuration could be multiple files or directories
### Added
- Support FastPass related feature
- Support Python3.4

## [1.0.8] - 2018-08-27
### Fixed
- Wrong SSL/TLS crt/key format
- Relocatable
- Can not run in BCMT 16.6
### Added
- Support HTTPS

## [1.0.4] - 2018-06-21
### Added
- Initial

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

