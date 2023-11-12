# Changelog
All notable changes to chart **citm-ingress** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]

## [1.18.2] - 2020-07-02
### Changed
- new default404 chart 1.0.27

## [1.18.1] - 2020-06-29
### Changed
- new docker
- support of kubernetes 1.16, 1.17, 1.18
- new default404 chart 1.0.26
- rework ssl-passthrough. See https://csf.gitlabe2-pages.ext.net.nokia.com/mp/citm/guide/tls.html#ssl-passthrough
- Update kubectl image to v1.17.6-nano

### Added
- Support of custom template. https://csf.gitlabe2-pages.ext.net.nokia.com/mp/citm/guide/helmchart-ingress.html#custom-template
- Ability to split HTTPS and PASSTHROUGH listening port

## [1.16.17] - 2020-04-27
### Changed
- new docker 1.16.1-28.2
- increase timer on wget for helm test
- new default404 chart 1.0.21
- prefix leader config map wihh namespace

### Added
- export HTTP listening port as variable
- Clean configmap ingress-controller-leader-nginx in post-delete helm hook
- Clean cert manager generated secret in post-delete helm hook

## [1.16.14] - 2020-04-02
### Changed
- new docker 1.16.1-25.2

## [1.16.13] - 2020-03-05
### Added
- Provide probe thresholds and delay
- Allow patch on role/clusterrole
- Provide update on the fly of TCP/UDP stream services. See controller.dynamicUpdateServiceStream
- Support NodePort for TCP/UDP stream services. NODE-PORT=xxxx in the config map
- Can respond HTTP 403 when ingress certificate not found
- Support of helm3

### Changed
- new docker 1.16.1-25.1
- new default404 chart 1.0.18
- [liveness|ready]Probe are now done on httpPort (80)

## [1.16.12] - 2020-03-02
### Changed
- new default404 chart 1.0.17

## [1.16.11] - 2020-02-27
### Added
- Add controller.serviceOnStream.enable: Defines if on UDP/TCP service, request are forwarded to k8s service instead of backends. Needed by Istio for stream. false by default
- Add support of cert-manager

### Changed
- new docker 1.16.1-23.8

## [1.16.10] - 2020-02-04
### Added 
- Add support of modsecurity
- Add controller.enableHttp2OnHttp. Set it to true is you want http2 on http plain text
- Add controller.disableIvp4. Set it to true is you do not want listening on ipv4 interfaces

### Changed
- new docker 1.16.1-23.1 

## [1.16.9] - 2019-12-06
### Added 
- Add support of templating on defaultSSLCertificate

## [1.16.8] - 2019-12-04
### Added
- templating on tcp/udp services configmap

## [1.16.7] - 2019-12-03
### Added
- possibility of providing ConfigMap with lua modules

### Changed
- new docker 1.16.1-17.1 

## [1.16.6] - 2019-11-21
### Changed
- new docker 1.16.1-16.3 (CentOS 8 inside)
- new default404 chart
- new kubectl docker for helm test
- Enhance stream backend information on access log
- Activate TLS 1.3 and TLS 1.2 by default

### Added
- sslProtocols and sslCiphers in values.yaml

## [1.16.5] - 2019-10-31
### Added
- Add runOnEdge for setting is_edge: true in nodeSelector. Default is true
- Allow rendering of Monitoring console (set metrics to true for activation)
- Create leader config map only during helm install
### Fixed
- Lua OIDC login error handling

### Changed
- Enhance doc for udp/tcp services
- new docker 1.16.1-7.1
- new kubectl docker for helm test
- new default404 chart

## [1.16.4] - 2019-09-26
### Changed
- new docker 1.16.1-2.2

## [1.16.3] - 2019-09-18
### Added

### Changed
- set runAsUser:0 when worker process needs to run as root
- new chart for default404
- new docker 1.16.1-2.1

## [1.16.2] - 2019-09-03
### Added
- Access control for lua in Snippet code. See https://gitlabe1.ext.net.nokia.com/csf_bcmt/gerrit/CSF-CHARTS/raw/1.0/citm-ingress/README.md#snippet-authorize

### Changed
- New docker 1.16.1-1.2

## [1.16.1] - 2019-07-31
### Changed
- Do not request ClusterRole when scope on namespace is activated
- New docker 1.16.0-3.1

## [1.16.0] - 2019-06-25
### Fixed
- Compaas cookie cleanup problem

### Changed
- Update docker to 1.16.0-2.1

## [1.14.34] - 2019-05-24
### Changed
- Update docker to 1.14.2-11.2

## [1.14.33] - 2019-04-19
### Changed
- Disabled CORS support for NCM API in compaas SSO
- Update docker to 1.14.2-10.2

## [1.14.32] - 2019-04-02

### Changed
- Update docker to 1.14.2-9.3

## [1.14.31] - 2019-03-29
### Fixed
- Compaas SSS interation with NCM API problem

### Added
- docker: no more need of root user. Add runAsUser (nginx/1000) and securityContext / capabilities 
- more helm test

### Changed
- Update docker to 1.14.2-9.2

## [1.14.30] - 2019-02-26
### Added
- Support of block[Cidrs | UserAgents | Referers]
### Changed
- Update docker to 1.14.2-4.1. CITM Ingress Controller 0.20 inside (dynamicConfiguration disabled)
- Update docker to 1.14.2-4.3. Compaas SSO support for Keycloak login page.

## [1.14.29] - 2019-02-14
### Added
- Support for incoming Bearer tokens in Compaas SSO

## [1.14.28] - 2019-01-30
### Changed
- uppdate docker 1.14.2-3.2
- update default404 requirements version
- Compaas SSO - modified operational log
- split flow for stream backend when transparent proxying is required. Can be also forced for all stream with splitIpv4Ipv6StreamBackend set to true
### Fixed
- SSO login issue
- when service.type = NodePort, clusterIP should not be provided
- Harmonized logging 
### Added
- Add chart test
### Removed
- controller.UseOnlyIpv6Endpoint (this is now automaticaly detected. See also splitIpv4Ipv6StreamBackend)

## [1.14.27] - 2018-12-20
### Added
- Harmonized logging support. (Can be disabled by setting logToJsonFormat to false)
### Changed
- Don't start pods before default TLS certificate secret is ready
- Refresh token a few seconds before expiration

## [1.14.26] - 2018-12-06
### Changed
- improve citm as server
- Compaas SSO improvements
- Grafana dashboard

## [1.14.25] - 2018-11-14
### Changed
- Update docker citm-nginx:1.14.0-11.5

## [1.14.23] - 2018-11-06
### Changed
- Do not use alias in requirements on default backend

## [1.14.22] - 2018-10-26
### Changed
- update to docker citm-nginx:1.14.0-11.4

## [1.14.21] - 2018-10-25
### Fixed
- SSO logout problems
### Changed
- update to docker citm-nginx:1.14.0-11.3

## [1.14.20] - 2018-10-24
### Added
- add forcePort value to force http & https port to default (80 & 443)
### Changed
- update to docker citm-nginx:1.14.0-11.2

## [1.14.19] - 2018-10-23
### Added
- add values for nginx conf to allow 2 nginx releases to run on the same host

## [1.14.18] - 2018-10-17
- Remove default ingress resource

## [1.14.17] - 2018-10-16
### Fixed
- Default-backend is now a requirement

## [1.14.16] - 2018-10-10
### Fixed
- SSO session cookie problems

## [1.14.15] - 2018-10-10
### Fixed
- resolved typo on httpServer-deployment to load correctly external nginx configMap

## [1.14.14] - 2018-10-05
### Added
- added first version of citm as simple server

## [1.14.13] - 2018-10-03
### Fixed
- set rbac.create to true by default
- add podsecuritypolicies:privileded in clusterrole

## [1.14.12] - 2018-09-21
### Changed
- Add values to Configure the location of your etcd cluster
- Add value to use-calico-cni-workload-endpoint
- Add value to use only ipV6 endpoint

## [1.14.11] - 2018-09-21
### Changed
- Update to new citm nginx binary for IPV6 support

## [1.14.10] - 2018-09-13
### Fixed
- Using pre-defined resty session secret

## [1.14.9] - 2018-09-07
### Fixed
- adding template fullname in tcp and udp configMap

## [1.14.8] - 2018-09-07
### Added
- SSO support in sites federation
### Fixed
- Problem with SSO session cookie name

## [1.14.7] - 2018-09-04
### Added
- Configure UDP/TCP services 
- Configuring transparent proxy for udp/tcp service
- Optionally specify the secret name for default SSL certificate
- Ingress Controller suppoort for listening external IPs (local or nonlocal binding)
- Using global scope for relocation
### Removed
- Deprecated proxyStreamBindTransparent
### Fixed
- Issue with LUA includes

## [1.14.6] - 2018-09-03
### Added
- CSF chart relocation rules enforced
- SSO logging in CLF 

## [1.14.5] - 2018-08-28
### Removed
- stats-exporter removed
### Fixed
- issue in image relocation

## [1.14.4] - 2018-08-03
### Added
- All future chart versions shall provide a change log summary

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!

