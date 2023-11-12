# Configure tcp-udp streams

## Overview

Allowing to proxy and load balance traffic for pure tcp/udp backends

Nginx [reference  guide](https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/)

## nginx.conf

Herafter a simple configuration for udp stream

```
stream {
	upstream test123.com {
		server 192.168.1.1:5060;
		server 192.168.1.2:5060;
    }
	
    server {
        listen 5060 udp;
        proxy_pass test123.com;
        proxy_timeout 1s;
        proxy_responses 1;
    }
}
```

The same for tcp

```
stream {
	upstream test123.com {
		server 192.168.1.1:5060;
		server 192.168.1.2:5060;
    }
	
    server {
        listen 5060 tcp;
        proxy_pass test123.com;
        proxy_timeout 1s;
    }
}
```

## Ingress controller

### Static configuration

By default, nginx ingress controller support one config map for udp service and another one for tcp service. They're specified using [udp-services-configmap and tcp-services-configmap](docker-ingress-cli-arguments.md) argument when starting CITM ingress controller pod. 

They can also be set by specifing a [tcp/udp](helmchart-ingress.md#stream-backend) set value to ingress controller helm chart.

### Dynamic configuration

You may also need to declare dynamic tcp/udp services. In that case, CITM nginx ingress controller has enhanced the mechanism to support a set of config map, instead of only one per protocol.

All config map starting with the pattern given in `udp-services-configmap` or `tcp-services-configmap` will be associated with respectively udp and tcp services.

If you do not provide a `namespace` in `udp-services-configmap` or `tcp-services-configmap`, then check will not be done on namespace, and all config map starting with this name, whatever the namespace will be added.

```
- --tcp-services-configmap=nginx-tcp-server-conf
- --udp-services-configmap=nginx-udp-server-conf
```

See `UdpServiceConfigMapNoNamespace` and `TcpServiceConfigMapNoNamespace` in ingress controller [helm chart](helmchart-ingress.md)

### Sample udp service

Herafter a complete chart of such udp service

??? "upd service sample chart"
     ```
     --8<-- "samples/udp-service.yaml"
     ```
### Ingress controller service

If you're using dynamic configuration, you also need to associate your UDP and TCP ports to CITM ingress controller service. 

This can be achieved thanks to `controller.dynamicUpdateServiceStream`. 

Setting it to true will ensure that all TCP/UDP ports are linked with CITM ingress controller service in kubernetes

```
$ helm install --name nginx citm-ingress --set controller.dynamicUpdateServiceStream=true
```
Now, port `UDP/2018` from previous example, is associated to CITM ingress controller service, and can be reached from edge nodes.
```
$ kubectl get pods,svc -o wide | grep citm
pod/nginx-citm-ingress-controller-tjnff    1/1     Running   0          6m42s   172.16.1.10      ab-cwe-01   <none>
service/nginx-citm-ingress-controller   ClusterIP   None             <none>        80/TCP,443/TCP,2018/UDP   6m42s   app=citm-ingress,component=controller,release=nginx
```
## NodePort

If you need to declare your UDP/TCP services as `NodePort` (needed for [Istio](istio.md)), by default, kubernetes peek-up a port in the range (30000-32767). CITM ingress controller allow you to specify this port for UDP/TCP service.

For this, you need to provide it in the config map, using keyword `NODE-PORT`

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2018
data:
  2018: "default/udpserver2018:2018,NODE-PORT=32042"
```

Keep in mind, that CITM ingress controller needs also to be configured for using NodePort

```
$ helm install --name nginx citm-ingress --set controller.dynamicUpdateServiceStream=true --set controller.service.type=NodePort
```
Now, service `UDP/2018` is associated with NodePort 32042
```
$ kubectl get pods,svc -o wide | grep citm
pod/nginx-citm-ingress-controller-qq5cr    1/1     Running       0          2m5s   172.16.1.10      ab-cwe-01   <none>
service/nginx-citm-ingress-controller   NodePort    10.254.227.10    <none>        80:31372/TCP,443:32115/TCP,2018:32042/UDP   2m5s   app=citm-ingress,component=controller,release=nginx
```

## Transparent proxy 

Transparent proxy allow to send client ip instead of CITM ingress controller one to backend. 

For achieving this, CITM ingress controller provides a new keyword for activating transparent proxying on udp/tcp services. Add `TRANSPARENT` after the port mapping.

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:TRANSPARENT"
```

If ypu need also to use this service as proxy, keyword becomes `TRANSPARENT-PROXY`

```
  2020: "default/udpserver2020:2020:TRANSPARENT-PROXY"
```

Since CITM ingress controller will modify source ip, You need to activate privilege on citm ingress controller pod. For this, set securityContextPrivileged and workerProcessAsRoot to true at helm install

```
$ helm install citm-ingress --set controller.securityContextPrivileged=true,controller.workerProcessAsRoot=true
```

!!! Warning "Network note.<br>Since we're changing ip source of the packet, this is IP spoofing, and this is normally not accepted by your network infrastructure and linux kernel."

You need to tweak some kernel and openstack parameters in order to let the packet reach the destination:

- At the linux level, this is controlled by `net.ipv4.conf.all.rp_filter`

	IP spoofing is disabled by doing `sysctl -w "net.ipv4.conf.all.rp_filter=0"`

	BCMT offer [Sysctl operator](https://confluence.app.alcatel-lucent.com/display/plateng/BCMT+-+OAM+Guide+19.09#BCMT-OAMGuide19.09-SysctlOperator) to apply these settings in a persistence way
	
- Openstack neutron also does not like IP spoofing so we have to tell Openstack to let go through the IP src that it does not know. This is done through neutron [port update](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/10/html/networking_guide/sec-allowed-address-pairs) command

- Also, read this [how-to](https://www.nginx.com/blog/ip-transparency-direct-server-return-nginx-plus-transparent-proxy/) if you need to receive packet in response. 

- [Troubleshooting](https://www.nginx.com/blog/ip-transparency-direct-server-return-nginx-plus-transparent-proxy/#troubleshooting)

Example of [setup](https://jiradc2.ext.net.nokia.com/browse/CSFS-28405) on a vmware cluster.

## Number of expected response for udp service

Set number of expected response for udp service. You can specify the number of expected response for an udp incoming request. 0 mean no response expected from the backend.

CITM ingress controller as added a specific keyword, `STREAM-RESPONSE` in the service ConfigMap. Set the value to the number of expected response. This will configure [proxy_responses](http://nginx.org/en/docs/stream/ngx_stream_proxy_module.html#proxy_responses) in nginx.conf. If not specified, the number of datagrams is not limited.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-udp-server-conf-2020
data:
  2020: "default/udpserver2020:2020:STREAM-RESPONSE=0"
```

If you also need `TRANSPARENT`

```
  2020: "default/udpserver2020:2020:TRANSPARENT,STREAM-RESPONSE=0"
```

## session affinity

Session affinity can be retrived from kubernetes service description, or set using the config map, with extra argument SESSION-AFFINITY
```
  2020: "default/udpserver2020:2020:SESSION-AFFINITY=least_conn;"
```

```
  2020: "default/udpserver2020:2020:SESSION-AFFINITY=hash $remote_addr"
```

Supported values are provided in [nginx documentation]( https://docs.nginx.com/nginx/admin-guide/load-balancer/tcp-udp-load-balancer/#configuring-tcp-or-udp-load-balancing)


