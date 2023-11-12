# Changelog
All notable changes to chart **cpro** are documented in this file,
which is effectively a **Release Note** and readable by customers.

Do take a minute to read how to format this file properly.
It is based on [Keep a Changelog](http://keepachangelog.com)
- Newer entries _above_ older entries.
- At minimum, every released (stable) version must have an entry.
- Pre-release or incubating versions may reuse `Unreleased` section.

## [Unreleased]
### Added
### Changed

## [2.11.0] - 2020-10-01
#Added
- CSFS-28336: Option to disable consistency check in pushgateway (cpro v2.7.2)
- CSFS-28114: CPRO should provide support for cbur autoUpdateCron parameter in BrPolicy
- CSFS-22054: BCMT ETCD metrics cannot be scraped by Prometheus without root access
- CSFOAM-6233: CSFS-27347 prometheus changes to move it inside istio service mesh
- CSFOAM-6171: alertmanager and rest-server chart changes to fix CSFS-27259
- CSFOAM-6280: cpro-server , kubestatemetrics and pushgateway chart changes to fix CSFS-27259
- CSFOAM-6282: exporter,migrate and hooks chart changes to fix CSFS-27259
- CSFOAM-6217: Add web.listen-address: ":9100" to extraargs of nodeExporter
- CSFOAM-6247: helm test is failing when CPRO is deployed in HA mode 
- CSFS-26805: Handling WAL Corruptions
- CSFOAM-6287: Creating 20.08 version of readme.md for cpro
- CSFS-28997: Delete Policy for Helm Test for CPRO Server
- CSFOAM-6300: Update image tag and change registry to candidates
- CSFOAM-6310 - CPRO changes to scrape node exporter and zombie exporter with default configuration with istio feature enabled

- CSFOAM-6370: updating readme.md for cpro

## [2.10.0] - 2020-09-01
#Added
- CSFS-25109: CPRO chart has dependency on K8s version
- CSFS-25970: Specify resources for all containers
- CSFOAM-5936: HELM3 non-ha to ha upgrade , with same version of chart failed (cpro-2.7.3-14)
- CSFOAM-5971: Fix for Unable to change alert rules dynamically with istio and prefixURL usage
- CSFS-27188, CSFS-27192: istioVersion as integer and readiness probe fails in Istio 1.5 with Openshift
- CSFS-27378: scrape_config to gather metrics from https endpoints

## [2.9.0] - 2020-07-16
#Added
- CSFS-26495: Support to provide option for global.istioVersion

## [2.8.0] - 2020-07-14
### Added
- ISTIO certificate update to credentialName
- CSFS-21679: CPRO: Helm Port Istio-Style Formatting
- CSFOAM-5546: Added MCS label,seccomp and apparmor annotation
- CSFOAM-5675: Added Restricted to namespace flag for server and restserverv components
- CSFOAM-5534: Affinity/Anti affinity rules for cpro restserver and pushgateway components
- CSFOAM-5550: istio single gateway configuration, destination rule and policy 
- CSFOAM-5551: istio changes for peer authentication
- CSFOAM-5793: configuring role,rolebinding for istio
- CSFOAM-5855: docker image update and istio-mutual support
- CSFOAM-5857: Incorporated helm best practices
- CSFOAM-5863: pushgateway uri configuration & alertmanager statefulset.
- CSFOAM-5882: match label for peerauthentication
- CSFOAM-5884: Fixed helm backup issue
- CSFOAM-5886: Fixed Node-Exporter and Zombie-Exporter helm lint issue
- CSFOAM-5923: Fixed SecurityContext issue
- CSFOAM-5893: Reverted server serviceName back to server-headless
- CSFS-23095: Added Global serviceAccountName

### Changed
- - CSFOAM-5875: Helm Test Changes for CPRO and Restapi
- CSFOAM-5892,5894,5897,5921,5935: Istio bug fixes

## [2.7.2] - 2020-05-15
### Added
### Changed
- CSFS-24437: cpro-node-exporter container host volume mounts are not updating

## [2.7.1] - 2020-05-11
### Added
- CSFS-21679 - Reverting the tcp-cluster in alertmanager to retrieve the port from values.yaml

## [2.7.0] - 2020-05-11
### Added
- All future chart versions shall provide a change log summary
- CSFS-21679 - Helm Port Istio-Style Formatting
- CSFS-18070 - CPRO is only collecting node metrics on worker nodes.  Control and Edge nodes have no statistics.
- CSFS-21858: Configured wal compression flag
- CSFOAM-5321: Removed invalid baseUrl value
- CSFS-15670: SecurityContext updated for NodeExporter
- CSFOAM-5316: Updated cpro components docker image tags
- CSFOAM-5315 - Upgraded Prometheus, Alertmanager, Node Exporter and Pushgateway to the latest versions
### Changed
- Modify test script, add chart name
- Disable NodePort 31000
- Rebuild docker image with latest CentOS-mini:latest

## [2.5.0] - 2020-03-20
### Added

## [2.4.2] - 2020-03-14
### Added
- CSFS-21684 - CPRO Helm3 K8s 1.17 Changes

## [2.4.1] - 2020-03-05
### Added
- Updating the semverCompare condition for helm3 upgrade

## [2.4.0] - 2020-03-13
### Added
- Support for ipv6 for alert-manager
- Added environment variable to take k8s server url for ipv6
- Updated to remove the deprecate K8S APIs

## [2.2.15] - 2019-10-30
### Added
- Can specify storageClass name when Prometheus/Alertmanager is deployed in HA mode

## [2.2.14] - 2019-10-22
### Fixed
- ZombieProcessExporter should use non-root

## [2.2.13] - 2019-10-22
### Changed
- CSFOAM-4695: Non-root for all Prometheus components
- Use new version 2.0.3 for Prometheus RestAPI Server

## [2.2.12] - 2019-10-14
### Changed
- CSFS-9972: Update README.md
- CSFS-16413: Add param "ignoreFileChanged: true" in BrPolicy and change cbur image version from 637 to 983

## [2.2.11] - 2019-09-26
### Fixed
- CSFS-17048: CPRO uses latest tag for init-chown-data container

## [2.2.10] - 2019-09-26
### Fixed
- (sync with 2.3.0)CSFS-16574: Use Cinder Volume for Prometheus-backup folder
### Changed
- (sync with 2.3.1)CSFS-15040: CPRO alerts should have unique names

## [2.2.9] - 2019-09-23
### Added
- CSFS-16805: Add toleration for CPRO restserver

## [2.2.8] - 2019-09-11
### Changed
- CSFOAM-4183: New CPRO Backup/Restore method running on ComPaaS
- Alertmanager can set retention time now
- Use new kubectl image for post-delete job
### Fixed
- On ComPaaS environment, Prometheus HA post-delete job stucks

## [2.2.7] - 2019-09-03
### Changed
- CSFS-16095: Add service of CPRO server with cluster ip for external access
- CSFS-9906: cpro-server headless service incorrect port

## [2.2.6] - 2019-08-28
### Fixed
- Fix CSFS-14867
### Changed
- Use new restapi image 2.0.2

## [2.2.5] - 2019-08-28
### Fixed
- Fix CSFS-15670

## [2.2.4] - 2019-08-27
### Added
- CSFS-15521: Add NodePort in Pushgateway service
- CSFS-12715: Add livenessProbe and readinessProbe for Prometheus server
### Fixed
- CSFS-13963: Alertmanager Ingress in HA
### Changed
- CSFS-9972: Update README.md

## [2.2.3] - 2019-08-26
### Fixed
- Fix one typo which may lead to incorrect volume mount in server-statefulset.yaml

## [2.2.2] - 2019-08-26
### Fixed
- CSFS-15978: deploy the latest cpro-2.1.9, one container of cpro-restserver pod failed

## [2.2.1] - 2019-08-22
### Changed
- Use new docker image (prometheus:v2.11.1-3) built based on nano, with curl in it

## [2.2.0] - 2019-08-22
### Changed
- Use new docker image built based on nano
- Use new Prometheus version v2.11.1
- Use new Pushgateway version v0.9.1

## [2.1.9] - 2019-08-13
### Changed
- RestAPI server image version update to 2.0.1

## [2.1.8] - 2019-06-28
### Fixed
- RestAPI server in Chart 2.1.7 cannot rollback to 2.0.27

## [2.1.7] - 2019-06-27
### Fixed
- RestAPI server in Chart 2.1.7 cannot rollback to 2.0.27

## [2.1.6] - 2019-06-24
### Added
- (synced with 2.0.27)Now CPRO Helm chart can be deployed on ComPaaS > 18.11

## [2.1.5] - 2019-06-20
### Changed
- (synced with 2.0.24)Prometheus storage.tsdb.path now use different value with PersistentVolume
- (synced with 2.0.26)Add a pre-restore hook function to avoid time overlap during restore

## [2.1.4] - 2019-06-18
### Fixed
- One switch by default set to false

## [2.1.3] - 2019-06-11
### Added
- CSFOAM-3791 Integrate with new version of RESTAPI
### Changed
- File structure of CPRO Helm chart template folder

## [2.1.2] - 2019-06-10
### Changed
- CSFOAM-3983 Parameterized CBUR setting change variable name
- CSFOAM-3986 CPRO non-ha to ha upgrade

## [2.1.1] - 2019-05-27
### Changed
- CSFOAM-3983 Parameterized CBUR setting
- CSFS-13228 configure containerPort and targetPort of NodeExporter

## [2.1.0] - 2019-04-26
### Changed
- Use Prometheus new version v2.9.1
- Use new version of NodeExporter, Pushgateway, Alertmanager and Kube-state-metrics

## [2.0.27] - 2019-06-20
### Added
- Now CPRO Helm chart can be deployed on ComPaaS > 18.11

## [2.0.26] - 2019-06-16
### Fixed
- Wrong container name in pre-restore hook function

## [2.0.25] - 2019-06-15
### Changed
- Add a pre-restore hook function to avoid time overlap during restore

## [2.0.24] - 2019-06-12
### Changed
- Prometheus storage.tsdb.path now use different value with PersistentVolume
- Support data migration from non-HA to HA

## [2.0.23] - 2019-06-05
### Changed
- CSFOAM-3983 Parameterized CBUR setting change variable name
- Resources for restapi container doesnt effect

## [2.0.22] - 2019-05-27
### Changed
- CSFOAM-3983 Parameterized CBUR setting
- CSFS-13228 configure containerPort and targetPort of NodeExporter

## [2.0.21] - 2019-04-26
### Changed
- Add resource limits

## [2.0.20] - 2019-04-26
### Changed
- Rebuild docker image with latest CentOS-mini:latest

## [2.0.19] - 2019-03-20
### Changed
- Add alertmanagerWebhookFiles
CSFS-11436: CPRO: cannot customize my webhook4fluentd

## [2.0.18] - 2019-03-19
### Changed
- Add alertmanagerWebhookFiles
CSFS-11436: CPRO: cannot customize my webhook4fluentd

## [2.0.17] - 2019-03-18
### Added
- Alert rule now include one label "host"
- Providing a way to add custom Prometheus job, can do overwrite by Helm install
### Fixed
- Job "prometheus-nodeexporter" also need to do relabel for providing kubernetes_io_hostname

## [2.0.16] - 2019-03-14
### Changed
- Update restserver imageTag from 1.1.0 to 1.1.1

## [2.0.15] - 2019-03-13
### Changed
- Alertmanager service and ext-service use different annotation

## [2.0.14] - 2019-03-11
### Changed
- Change default ha value to false

## [2.0.13] - 2019-02-26
### Changed
- Update imageTag of configmap-reload from v0.1 to v0.1.1

## [2.0.12] - 2019-02-24
### Added
- Alertmanager webhook support TLS as output
### Fixed
- Kubernetes_sd_config wrongly remove endpoints

## [2.0.11] - 2019-02-19
### Added
- Label "source" in default alert definition

## [2.0.10] - 2019-01-31
### Fixed
- Fix Comments has Chinese characters 

## [2.0.9] - 2019-01-30
### Fixed
- Fix one issue in template/test/config.yaml to adapt ComPaaS change

## [2.0.8] - 2019-01-30
### Changed
- Change the livenessProbe and readinessProbe Request type of restserver

## [2.0.7] - 2019-01-29
### Fixed
- Move alert rules from serverRules to serverFiles

## [2.0.6] - 2019-01-29
### Fixed
- Fix for CSFS-9767: update webhook4fluentd image and job get hostname

## [2.0.5] - 2019-01-28
### Fixed
- Move alert rules from serverRules to serverFiles

## [2.0.4] - 2019-01-25
### Fixed
- Fix image.imagePullPolicy does not take effect [CSFS-9932]

## [2.0.3] - 2019-01-21
### Fixed
- Fix alter rules error

## [2.0.2] - 2019-01-21
### Added
- Add prometheus-restserver

## [2.0.1] - 2018-12-28
### Changed
- Changed sd_configs of server and node exporter to endpoints

## [2.0.0] - 2018-12-28
### Changed
- Add HA support for aletermanager and server
- Add zombieProcessExporter and webhook4fluentd
- Add Multi-tenancy support
### Fixed
- Removed lots of unexisting scrape targets

## [1.2.9] - 2018-11-29
### Changed
- Apply global relocation
### Fixed
- Change back to ClusterIP from NodePort

## [1.2.8] - 2018-11-21
### Changed
- Modify test script, add chart name

## [1.2.7] - 2018-11-13
### Added
- Insert namespace label for metrics.

## [1.2.6] - 2018-11-1
### Fixed
- Prometheus can find Alertmanager in same Helm release.

## [1.2.5] - 2018-10-21
### Changed
- Changed node_exporter and pushgateway docker image tag.

## [1.2.4] - 2018-09-29
### Added
- Add Backup/Restore

## [1.2.3] - 2018-08-29
### Added
- Delivered a new helm chart cpro-1.2.3
- Add ut tests into templates
- Set rbac.create=true in values.yaml

## [0.0.0] - YYYY-MM-DD
### Added | Changed | Deprecated | Removed | Fixed | Security
- your change summary, this is not a **git log**!
