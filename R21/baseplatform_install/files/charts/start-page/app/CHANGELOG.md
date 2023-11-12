# Changelog
All notable changes to chart **citm-server** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
## [1.18.8] - 2020-11-02
### Changed
- new docker 1.18.0-2.1

## [1.18.7] - 2020-09-28
### Changed
- new docker 1.18.0-1.4

## [1.18.6] - 2020-09-10
### Added
- Sync .md from citm doc

## [1.18.5] - 2020-09-02
### Changed
- new docker 1.18.0-1.3

## [1.18.4] - 2020-08-31
### Added
- runAsUser

## [1.18.3] - 2020-06-19
### Changed
- Clean up cert-manager certificate if activated
- New docker: 1.18.0-1.2

## [1.18.2] - 2020-06-08
### Changed
- Support of kubernetes 1.16, 1.17
- Support of Istio

## [1.18.1] - 2020-06-09
### Changed
- New docker 1.18.0-1.1

## [1.16.12] - 2020-03-30
### Added
- Add support watch config

### Changed
- Update docker to 1.16.1-25.1

## [1.16.11] - 2020-02-25
### Added
- Add support of cert-manager

## [1.16.9] - 2020-02-05
### Changed
- Update docker to 1.16.1-23.1
- Provide modsecurity (WAF)

## [1.16.8] - 2019-12-03
### Changed
- Update docker to 1.16.1-17.1

## [1.16.7] - 2019-11-21
### Changed
- Update docker to 1.16.1-16.1

## [1.16.6] - 2019-09-27
### Changed
- Update docker to 1.16.1-2.2
- new centos image 7.7

## [1.16.5] - 2019-09-03
### Changed
- Update docker to 1.16.1-1.1

## [1.16.4] - 2019-08-09
### Changed
- Update docker to 1.16.0-3.4
- Correct issues on server block, json typo in configmap

## [1.16.3] - 2019-07-31
### Changed
- Update docker to 1.16.0-3.2

## [1.16.1] - 2019-07-01
### Changed
- Update docker to 1.16.0-2.2

## [1.16.0] - 2019-06-25
### Changed
- Update docker to 1.16.0-2.1

## [1.1.8] - 2019-06-06
### Added
- Support of secret
### Changed
- Update docker to 1.14.2-11.3

## [1.1.7] - 2019-05-24
- remove startPage section. Probe & Liveness are now directly under httpServer

## [1.1.6] - 2019-04-19
- remove serviceAccount. No more needed
- activate harmonized logging
- Enhance charts documentation

## [1.1.5] - 2019-03-12
### Added
- Support of runAsUser and capabilities

## [1.1.4] - 2019-02-28
### Security
- update docker

## [1.1.3] - 2019-01-30
- Anable nginx.conf via auto/configmap

## [1.1.2] - 2019-01-25
- Correct missing values in values.yaml

## [1.1.1] - 2019-01-25
- Workable citm-server after split from citm-ingress

## [1.1.0] - 2018-12-10
- First release

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

