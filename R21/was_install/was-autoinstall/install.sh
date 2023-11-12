#!/bin/bash

docker build . -t was-install:0.1

docker rm was-install || true

docker run -it --name was-install \
   --volume $PWD/was:/install/ansible \
   --volume $PWD/kubeconfig:/root/.kube/config \
   --volume $PWD/was_config_vars.yml:/install/ansible/was_config_vars.yml \
   was-install:0.1
