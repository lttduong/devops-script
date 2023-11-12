# Changelog

All notable changes to chart **cnot-configmap** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]

## [1.2.3] - 2020-09-11
### Changed
- Chart.yaml in accordance with HELM Best Practices (maintainer name added)

## [1.2.2] - 2020-09-11
### Added
- README.md added in accordance with HELM Best Practices (for now just a provisional version)
### Changed
- NOTES.txt updated in accordance with HELM Best Practices (service port forwarding)

## [1.2.1] - 2020-07-16
- CSFOAM-5907: CNOT 20.05.1 Release (update: release was not done)

### Security
- Update centos java base image to centos-nano:7.8-20200702

## [1.2.0] - 2020-05-28
- CSFS-24180: Security updates for java vulnerabilities

### Security
- Update centos java base image to centos-nano:7.8-20200506

## [1.1.0] - 2019-03-29

### Added
- first edition of cnot-configmap
- Add default value
- Add some parameters
- Add SMPP parts
- Add SMPP tls
- Add SMPP trigger
- Add Slack related config
- Add password encryption
- Slack TLS
- values-full.yaml
### Changed
- Correct some syntax errors
- Change JSON to YAML
- Add one parameter
- Use simple configuration file
### Fixed
- Fix one format error
- Fix Email template AlarmTask
- Wrong Profile ProfileForSMPP
- Clear alarm

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
