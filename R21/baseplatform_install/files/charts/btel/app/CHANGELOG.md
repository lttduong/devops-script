# Changelog
All notable changes to chart **btel** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [2.0.0] - 2020-10-30
## Changed
- README.md addition
- ISTIO adaptation
- BTEL common gateway creation
- Pod and container name prefix

## [1.3.0] - 2020-05-30
## Changed
- fluentd configuration updated to match the BELK-EFKC clog-json.conf
- helm3 btel deployment support
- CNOT mail server changed


## [1.2.2] - 2020-03-24
## Changed
- Server Audit logging set to false in cmdb

## [1.2.1] - 2020-03-20
## Changed
- Mariadb thread memory leak resolved

## [1.2.0] - 2020-03-19
## Changed
- BTEL IPv6 compatible
- Upgraded all the sub-charts to latest

## [1.1.8] - 2020-01-14
## Changed
- update cpro-grafana version to 3.9.1
- update CALM-CRMQ ssl certificate

## [1.1.8-6] - 2020-03-06
## Changed
- Certificates Changes for CNOT changes 

## [1.1.8-5] - 2020-03-06
## Changed
- CPRO ipv6 changes 

## [1.1.8-4] - 2020-03-03
## Changed
- CNOT ipv6 changes 

## [1.1.8-3] - 2020-03-03
## Changed
- All BTEL components are compliant with ipv6 network

## [1.1.8-2] - 2020-01-30
## Changed
- update belk-efkc version to 6.0.18

## [1.1.6] - 2019-11-07
## Changed
- update cpro-gen3gppxml version to 1.0.16

## [1.1.5] - 2019-11-04
## Changed
- update cpro version to 2.2.5

## [1.1.4] - 2019-10-08
## Changed
- update cpro, citm-ingress, cmdb, belk-fluntd and belk-efkc version and config


## [1.1.3] - 2019-09-24
## Changed
- update cpro version and config

## [1.1.2] - 2019-09-17
## Changed
- change maxscale count to 0

## [1.1.1] - 2019-09-12
## Changed
- change maxscale count to 2

## [1.1.0] - 2019-09-12
## Changed
- add nodeSelector and tolerations
- update sub component version

## [1.0.20] - 2019-08-06
## Changed
- add registry

## [1.0.19] - 2019-07-30
## Changed
- change cnot resources indent

## [1.0.18] - 2019-07-25
## Changed
- change cnot version

## [1.0.17] - 2019-07-23
## Changed
- change belk tags

## [1.0.16] - 2019-07-23
## Changed
- change grafana version back

## [1.0.15] - 2019-07-22
## Changed
- change components version
- delete cpro alert rules
- add belk tags

## [1.0.14] - 2019-06-26
## Changed
- change grafana version

## [1.0.13] - 2019-06-24
## Changed
- change cpro/calm/grafana/3gpp version

## [1.0.12] - 2019-06-18
## Changed
- change cpro version
- change java_esdata indent

## [1.0.11] - 2019-06-17
## Changed
- change NOTE.txt
- change cmdb version
- add fluentd config
- change fluentd url

## [1.0.10] - 2019-06-03
## Changed
- add resources
- change components version

## [1.0.9] - 2019-05-17
## Changed
- add resources
- add cnot SMTP tls

## [1.0.8] - 2019-05-08
## Changed
- delete 1 cpro job

## [1.0.7] - 2019-05-07
## Changed
- Change grafana ingress

## [1.0.6] - 2019-05-07
## Changed
- Change belk and citm version

## [1.0.5] - 2019-05-07
## Changed
- Change calm version

## [1.0.4] - 2019-04-29
## Changed
- Add ssl config

## [1.0.3] - 2019-04-28
## Changed
- BUG fix: No grafana/kibana GUI 

## [1.0.2] - 2019-04-25
## Changed
- Add ha 

## [1.0.1] - 2019-04-23
## Changed
- Add ssl support 

## [1.0.0] - 2019-04-10
## Changed
- With CMDB/CRMQ inside BTEL, it is OK
- Please replace btel-releasename with the real releasename firstly

## [0.0.1] - 2019-04-01
### Added
- With CMDB/CRMQ/CKAF outside BTEL, it is OK
