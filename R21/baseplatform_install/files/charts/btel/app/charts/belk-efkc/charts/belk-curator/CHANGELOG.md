All notable changes to chart **belk-curator** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]

## [4.5.5] - 2020-10-06
- CSFOAM-6395: Updated templatename with chart.templatename


## [4.5.4] - 2020-09-30
- Updated README.md file
- addition of prefix to pod names, job and container names
- added nameoverride and fullname override configuration changes
- updated job and job container template names
- updated docker image repo to choose between curator cos7 and cos8 images.
- Docker image moved to delivered

## [4.5.3] - 2020-07-20
- CSFS-22644: Added support to accept precreated curator configmap.

## [4.5.2] - 2020-07-13
### Updated
- Added fsGroup, supplementary groups, MCS label
- Support for pre-created Service Account, role and rolebinding
- Added customized security annotation which are user configurable
- Added support for istio
- Fixed annotations warning on upgrade
- Added provision for cutomized labels to pods
- helmbestpractice changes for service account and rbac flag
- Moved docker image to delivered

## [4.5.1] - 2020-04-23
### Updated
- Helm3 changes
- Istio-Style Formatting for ports


## [4.5.0] - 2020-02-11
### Updated
- Added service account to curator
- Upgraded curator to 5.8.1
- Updated job spec and job template parameters to be user configurable
- Updated curator-post-delete role permissions
- Moved docker image to delivered

## [4.4.7] - 2019-12-18
### Updated
- Updated curator configuration for deletion of snapshots
- Updated curator image to point to latest centos image
- Moved curator image to delivered

## [4.4.6] - 2019-10-30
### Updated
- Upgraded base image to centos-7.7
- Updated registry parameter
- Moving curator image to docker-delivered

## [4.4.5] - 2019-10-01
### Updated
- Upgraded kubectl image to v1.14.7-nano 

## [4.4.4] - 2019-08-29
### Updated
- Moved curator image to delivered

## [4.4.3] - 2019-08-26
### Updated
- CSFS-15916: Some resource of belk-efkc can not be deleted after helm delete successfully

## [4.4.2] - 2019-08-22
### Updated
- CSFLDA-1975: Moved curator image to centos nano image

## [4.4.1] - 2019-07-08
### Added
- Moved all images to delivered

## [4.4.0] - 2019-06-27
### Added
- Upgraded curator to 5.7.6

## [4.3.6] - 2019-05-21
### Added
- Added security annotation for curator

## [4.3.5] - 2019-05-20
### Added
- Added security annotation


## [4.3.4] - 2019-04-30
### Added
- Moved base image to delivered

## [4.3.3] - 2019-04-25
### Added
- Upgraded base image

## [4.3.2] - 2019-03-22
### Changed
- Upgraded base image to Centos 7.6

## [4.3.1] - 2019-02-19
### Changed
- Changed the version of kubectl image

## [4.3.0] - 2018-12-20
### Changed
- Upgraded curator to 5.6.0

## [4.2.1] - 2018-10-30
### Changed
- Changed certificates


## [4.2.0] - 2018-10-29
### Changed
- Elasticsearch curator upgraded to 5.5.4

## [4.1.4] - 2018-09-26
### Changed
- Resource properties removed from templates and added in the values.yaml

## [4.1.3] - 2018-09-19
### Changed
- Modified secret creation

## [4.1.2] - 2018-09-05
### Added
- Update config LCM event is added

## [4.1.1] - 2018-09-04
### Added
- CSFLDA-897: Fix for bug while installing chart with wrong base64 password

## [4.1.0] - 2018-08-31
### Added
- Install and delete LCM events are added for curator.

## [4.0.1] - 2018-08-30
### Changed
- CSF chart relocation rules enforced
- Updated image registry name from registry to global registry

## [4.0.0] - 2018-08-13
### Added
- All future chart versions shall provide a change log summary
- CSF chart relocation rules enforced
- PSP/RBAC support
### Changed
- Chart to follow semantic naming. belk-`component`-`opensource version`-`csf release year`.`csf release month`.`patch`
  e.g. `belk-curator-5.5.4-18.07.02`
- docker image on Centos 7.5

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

