#!/bin/bash
## Using a service principal to login AZURE
USERNAMEID=1209541e-2e64-4f61-939d-fe54e3bb36dc
SECRET=sGb8Q~jkGk~~VEyBDWSSmL5WnVRTjdQ~Mg.3UaA7
TENANTID=5d471751-9675-428d-917b-70f44f9630b0

## Using az cli to login Azure
az login --service-principal -u ${USERNAMEID} -p ${SECRET} --tenant ${TENANTID}