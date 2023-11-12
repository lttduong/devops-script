# Command line arguments

The following command line arguments are accepted by the CITM Ingress controller executable.

| Argument | Description |
|----------|-------------|
| --alsologtostderr <img width=1000/>  | log to standard error as well as files |
| --annotations-prefix string <img width=1000/>  | Prefix of the Ingress annotations specific to the NGINX controller. (default "nginx.ingress.kubernetes.io") |
| --apiserver-host string <img width=1000/>  | Address of the Kubernetes API server.                                   Takes the form "protocol://address:port". If not specified, it is assumed the                                   program runs inside a Kubernetes cluster and local discovery is attempted. |
| --citm-allow-certificate-not-found <img width=1000/>  | Defines if a ingress certificate is not found, default certificate is used. Setting this to false will respond with a HTTP 403 (access denied) (default true) |
| --citm-enable-https-all-server <img width=1000/>  | Defines if https is activated even when no TLS section is provided |
| --citm-use-service-on-stream <img width=1000/>  | Defines if on UDP/TCP service, request are forwarded to k8s service instead of backends |
| --configmap string <img width=1000/>  | Name of the ConfigMap containing custom global configurations for the controller. |
| --default-backend-service string <img width=1000/>  | Service used to serve HTTP requests not matching any known server name (catch-all).                                   Takes the form "namespace/name". The controller configures NGINX to forward                                   requests to the first port of this Service. |
| --default-server-port int <img width=1000/>  | Port to use for exposing the default server (catch-all). (default 8181) |
| --default-ssl-certificate string <img width=1000/>  | Secret containing a SSL certificate to be used by the default HTTPS server (catch-all).                                   Takes the form "namespace/name". |
| --election-id string <img width=1000/>  | Election id to use for Ingress status updates. (default "ingress-controller-leader") |
| --enable-dynamic-certificates <img width=1000/>  | Dynamically update SSL certificates instead of reloading NGINX.                                   Feature backed by OpenResty Lua libraries. Requires that OCSP stapling is not enabled |
| --enable-dynamic-configuration <img width=1000/>  | Dynamically refresh backends on topology changes instead of reloading NGINX.                                   Feature backed by OpenResty Lua libraries. |
| --enable-ssl-chain-completion <img width=1000/>  | Autocomplete SSL certificate chains with missing intermediate CA certificates.                                   A valid certificate chain is required to enable OCSP stapling. Certificates                                   uploaded to Kubernetes must have the "Authority Information Access" X.509 v3                                   extension for this to succeed. (default true) |
| --enable-ssl-passthrough <img width=1000/>  | Enable SSL Passthrough. |
| --force-namespace-isolation <img width=1000/>  | Force namespace isolation.                                   Prevents Ingress objects from referencing Secrets and ConfigMaps located in a                                   different namespace than their own. May be used together with watch-namespace. |
| --health-check-path string <img width=1000/>  | URL path of the health check endpoint.                                   Configured inside the NGINX status server. All requests received on the port                                   defined by the healthz-port parameter are forwarded internally to this path. (default "/healthz") |
| --healthz-port int <img width=1000/>  | Port to use for the healthz endpoint. (default 10254) |
| --http-port int <img width=1000/>  | Port to use for servicing HTTP traffic. (default 80) |
| --https-port int <img width=1000/>  | Port to use for servicing HTTPS traffic. (default 443) |
| --ingress-class string <img width=1000/>  | Name of the ingress class this controller satisfies.                                   The class of an Ingress object is set using the annotation "kubernetes.io/ingress.class".                                   All ingress classes are satisfied if this parameter is left empty. |
| --kubeconfig string <img width=1000/>  | Path to a kubeconfig file containing authorization and API server information. |
| --log_backtrace_at traceLocation <img width=1000/>  | when logging hits line file:N, emit a stack trace (default :0) |
| --log_dir string <img width=1000/>  | If non-empty, write log files in this directory |
| --logtostderr <img width=1000/>  | log to standard error instead of files (default true) |
| --profiling <img width=1000/>  | Enable profiling via web interface host:port/debug/pprof/ (default true) |
| --publish-service string <img width=1000/>  | Service fronting the Ingress controller.                                   Takes the form "namespace/name". When used together with update-status, the                                   controller mirrors the address of this service's endpoints to the load-balancer                                   status of all Ingress objects it satisfies. |
| --publish-status-address string <img width=1000/>  | Customized address to set as the load-balancer status of Ingress objects this controller satisfies.                                   Requires the update-status parameter. |
| --report-node-internal-ip-address <img width=1000/>  | Set the load-balancer status of Ingress objects to internal Node addresses instead of external.                                   Requires the update-status parameter. |
| --sort-backends <img width=1000/>  | Sort servers inside NGINX upstreams. |
| --ssl-passthrough-proxy-port int <img width=1000/>  | Port to use internally for SSL Passthrough. (default 442) |
| --status-port int <img width=1000/>  | Port to use for exposing NGINX status pages. (default 18080) |
| --stderrthreshold severity <img width=1000/>  | logs at or above this threshold go to stderr (default 2) |
| --sync-period duration <img width=1000/>  | Period at which the controller forces the repopulation of its local object stores. Disabled by default. |
| --sync-rate-limit float32 <img width=1000/>  | Define the sync frequency upper limit (default 0.3) |
| --tcp-services-configmap string <img width=1000/>  | Name of the ConfigMap containing the definition of the TCP services to expose.                                   The key in the map indicates the external port to be used. The value is a                                   reference to a Service in the form "namespace/name:port", where "port" can                                   either be a port number or name. TCP ports 80 and 443 are reserved by the                                   controller for servicing HTTP traffic. |
| --udp-services-configmap string <img width=1000/>  | Name of the ConfigMap containing the definition of the UDP services to expose.                                   The key in the map indicates the external port to be used. The value is a                                   reference to a Service in the form "namespace/name:port", where "port" can                                   either be a port name or number. |
| --update-status <img width=1000/>  | Update the load-balancer status of Ingress objects this controller satisfies.                                   Requires setting the publish-service parameter to a valid Service reference. (default true) |
| --update-status-on-shutdown <img width=1000/>  | Update the load-balancer status of Ingress objects when the controller shuts down.                                   Requires the update-status parameter. (default true) |
| --use-calico-cni-workload-endpoint string <img width=1000/>  | Defines which release of calico to use, when querying calico. Supported are: not-used, v1, v3. Default is not-used (default "not-used") |
| -v`, `--v Level <img width=1000/>  | log level for V logs |
| --version <img width=1000/>  | Show release information about the NGINX Ingress controller and exit. |
| --vmodule moduleSpec <img width=1000/>  | comma-separated list of pattern=N settings for file-filtered logging |
| --watch-namespace string <img width=1000/>  | Namespace the controller watches for updates to Kubernetes objects.                                   This includes Ingresses, Services and all configuration resources. All                                   namespaces are watched if this parameter is left empty. |
