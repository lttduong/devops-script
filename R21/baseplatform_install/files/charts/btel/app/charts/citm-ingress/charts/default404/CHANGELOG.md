# Changelog
All notable changes to chart **citm-default-backend** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [1.0.34] - 2020-10-05
### Changed
- prefix helper functions with chart name

## [1.0.33] - 2020-09-07
### Added
- affinity (.Values.affinity)
- hook-delete-policy on helm test (.Values.test.hookDeletePolicy)

## [1.0.32] - 2020-08-31
### Changed
- rename default404.rbac.create to default404.rbac.enabled to be compliant with [CSF Helm Best Practices](https://confluence-app.ext.net.nokia.com)

## [1.0.30] - 2020-08-12
### Added
- Support of Support of global.podNamePrefix and global.containerNamePrefix

## [1.0.29] - 2020-07-31
### Added
- Support of fullnameOverride

## [1.0.28] - 2020-07-15
### Changed
- Fixed rbac & Istio

## [1.0.27] - 2020-07-02
### Changed
- Fixed serviceAccount

## [1.0.26] - 2020-06-29
### Changed
- Support of kubernetes 1.16 and upper
- Clean up rbac. Only activated on Istio (rbac.create=true and istio.enable=true)
- Support predefined service account thanks to .Values.rbac.serviceAccountName (rbac.create=false)
- Update kubectl image to v1.17.6-nano

## [1.0.21] - 2020-05-26
### Changed
- increase curl timeout for helm test. DNS resolution is slow on ipv6
- Remove set on ClusterIP

### Added
- Istio port naming convention

## [1.0.18] - 2020-03-16
### Added
- Add NET_RAW, needed by istio sidecar

## [1.0.17] - 2020-03-02
### Fixed
- Fixed ServiceAccount

## [1.0.16] - 2020-01-06
### Changed
- Use own ServiceAccount and do not rely on default one

## [1.0.15] - 2019-11-20
### Changed
- new kubectl docker for chart test

## [1.0.14] - 2019-10-31
### Added 
- runOnEdge flag
- new kubectl docker for chart test

## [1.0.13] - 2019-09-23
### Added 
- kubernetes tolerations

## [1.0.12] - 2019-09-18
### Fixed 
- Fixed istio support

## [1.0.11] - 2019-07-12
### Added
- Add readiness probe

## [1.0.10] - 2019-03-13
### Added
- helm test on release

### Changed
- Provide resources limits for CPU & Memory

## [1.0.9] - 2019-02-13
### New
- Listening port is now configurable

## [1.0.7] - 2019-01-16
### New
- support of rbac & Istio

## [1.0.5] - 2018-11-29
### Fixed
- new docker image: citm/citm-default-backend:4.0.4-3

## [1.0.4] - 2018-11-26
### Fixed
- ComPass rendering

## [1.0.3] - 2018-11-06
### Fixed
- Rename Chart

## [1.0.2] - 2018-10-16
### Fixed
- First version

