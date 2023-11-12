# Changelog
All notable changes to chart **cnot** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [1.5.15] - 2020-09-11
### Changed
- With CNOT 20.08 release the configmap-reload chart version updated to 1.2.3 in requirements.yaml, the docker images updated to 1.5.4-1821 in case of cnot and 1.2.2-151 in case of configmap-reload in values.yaml and values-full.yaml

## [1.5.14] - 2020-09-11
### Changed
- CSFS-27249: revert using full name in case of configmap-reload container's naming for the sake of "relative" consistency (i.e. containers use name despite that pod uses fullname)

## [1.5.13] - 2020-09-11
### Added
- README.md added in accordance with HELM Best Practices (for now just a provisional version)
### Changed
- NOTES.txt updated in accordance with HELM Best Practices (service port forwarding, API endpoins summary)

## [1.5.12] - 2020-09-09
### Changed
CSFOAM-6023: Change DestinationRule name from short name to fully qualified

## [1.5.11] - 2020-09-08
### Fixed
- CNOT healthcheck probe changes in order to work when istio is enabled
- RBAC - default serviceAccountName isn't overwritten when using external saName
### Added
- Add mTLS strict/permissive mode switch
- Add istio-peerauthentication to keep compatibility with istio versions >1.4

## [1.5.10] - 2020-08-29
### Fixed
- Add TLS passthrough mode to istio-gateway to fix TLS connection

## [1.5.9] - 2020-08-29
### Changed
- A modification according to HELM best practices

## [1.5.8] - 2020-08-26
### Added
- Add support for Istio configuration (virtual service, gateway, destination rule)
- Add support for toggleable Istio CNI
- Add Istio permissive mTLS support

## [1.5.7] - 2020-08-26
### Changed
- External RBAC security can be used instead of default CSF RBAC if serviceAccountName is set

## [1.5.6] - 2020-08-25
### Changed
- Added support for pod name and container name prefixes

## [1.5.5] - 2020-08-17
### Added
- Added Istio automatic sidecar injection on/off

## [1.5.4] - 2020-08-10
### Added
- Added support for custom Role Based Access Control
- Added support for custom Pod Security Policy

## [1.5.3] - 2020-07-16
### Security
- CSFAR-3003: Fixing WildFly 19 vulnerability by updating to version 20 (cjee-wildfly:20.0.1-1.1.j8os7)
- CSFOAM-5940: Fixing log4j vulnerability by updating CLOG dependency
- CSFOAM-5944: Fixing slf4j vulnerability by updating Swagger dependency
- CSFOAM-5505: Fixing multiple RestEasy vulnerabilities

## [1.5.2] - 2020-05-19
- CSFS-24180: Security updates for java vulnerabilities
### Security
- Update CJEE/WildFly image to 19.1.0-1.1.java8

## [1.5.1] - 2020-04-22
- CNOT: Helm Port Istio-Style Formatting
### Added
- add names to ports in deployment.yaml
### Changed
- change port names in service.yaml

## [1.5.0] - 2020-04-21
- CNOT Helm3 K8s 1.17 changes
### Added
- matchLabels selector in deployment.yaml
### Changed
- apiVersion in deployment.yaml

## [1.4.1] - 2020-11-02
- CSFOAM-5031: SVM-53314 update Jackson Databind dependency to 2.10.2

## [1.4.0] - 2020-11-02
- CSFS-18954: wildfly server log rotation
- IPv6 support
- Disable http port to wildfly server when SSL is enabled for same interface

## [1.3.0] - 2019-11-06
### Changed
- change cnot image version

## [1.2.1] - 2019-08-12
### Added
- add nodeSelector and tolerations

## [1.2.0] - 2019-07-24
### Added
- add cnot tool jar in csf mvn repo of artifactory
### Changed
- based on centos nano image
- email can be sent to multiple addresses
- change from cluster role to role, cluster role binding to role binding
- add resources for containers
- change to non-root users for containers
- add httpconnector to cnot.extraEnv

## [1.1.0] - 2019-03-29
### Added
- first edition of cnot
- configmap-reload
- metrics
- tls related
- Add SMPP parts
- Configmap-reload monitoring multiple directories
- Add Slack related configurations
- Add Slack TLS
- Password encrypt
- Liveness and Readiness probe
- Keycloak integration
- values-full.yaml
### Changed
- override umbrella chart
- add default values
- header format
- configmap-reload upgrade to 0.2.1
- K8s Secret carry wildfly password
### Fixed
- Overriding
- Email template
- Move truststore to configmap-reload
- Wrong Profile ProfileForSMPP
- Clear Alarm
- One duplicate GLOBAL
- SMPP fixes
- add keycloakserver env in deployment.yaml
- add check wildfly https enabled

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
