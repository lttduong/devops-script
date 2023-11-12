FROM wasr21containerregistry.azurecr.io/was-install:1.2

WORKDIR /install/ansible

COPY was ./

COPY was_config_vars.yml ./

ENTRYPOINT ["ansible-playbook","--extra-vars=@/install/ansible/was_config_vars.yml","-e","helm=/exec/helm3","-e","HELM_PATH=/exec/helm3","/install/ansible/install-local.yml"]
