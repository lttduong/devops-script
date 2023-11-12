# WAS installation

1. Update configuration file (was_config_vars.yml) according to the environment.
   Update the following parameters:
   - bcmt_registry
   - BP_DEPLOYMENT_PROFILE.STORAGE
   - ACCESS_FQDNS, ACCESS_IPS

2. Place kubeconfig file to the actual working directory (will be used by docker container)

3. Start installation
This will build the docker image and start local deployment

```
bash install.sh
```
