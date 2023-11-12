FROM wasr21containerregistry.azurecr.io/base_platform_install:0.4

WORKDIR /install/ansible

COPY workbench ./
COPY kube_config /root/.kube/config
COPY workbench_config_vars.yml ./

ENTRYPOINT ["/exec/helm3", 'install "workbench" ./workbench --version "0.0.525" --namespace "netguard-workbench" --wait --timeout "900s" --values "workbench_config_vars.yml"']
