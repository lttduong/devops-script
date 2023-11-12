#!/bin/bash

readonly APP_ERROR_CODE=2
readonly CMDB_APP=cmdb
readonly MARIADB_CONTAINER=mariadb
readonly MARIADB_LBL=mariadb
readonly MAX_SERVER_ID=4294967295
readonly MIN_CMDB_SLAVE_COUNT=1
readonly WAIT_TIMEOUT_SEC=600
RESTORE_BTEL_ES_CONFIG_MAPS="true"
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"
productConfigFiles=productconfig.tar.gz
dataBTEL=btel.tar.gz
dataCMDB=basecmdb.tar.gz
dataCKEY=baseckey.tar.gz
dataCMDBSecret=baseckeysec.tar.gz
dataCKEYSecret=basecmdbsec.tar.gz


echo "What is the absolute path of private key to access the cluster control nodes? i.e) /home/cloud-user/clcm.pem"
read key

echo "Was the backup stored local or sftp"
read tbackup

echo "What is the Base Platform namespace? i.e) netguard-base"
read bpNamespace

echo "What is the Netguard Configuration namespace? i.e) netguard-configuration"
read configurationNamespace


function log_info {
    local msg=$1
    logger -s -p user.info "${BASH_SOURCE[0]} | INFO | ${msg}"
}

function log_warning {
    local msg=$1
    logger -s -p user.warning "${BASH_SOURCE[0]} | WARNING | ${msg}"
}

function log_error_and_exit {
    local msg=$1
    logger -s -p user.err "${BASH_SOURCE[0]} | ERROR | ${msg}"
    exit "${APP_ERROR_CODE}"
}


function fluentdstop() {

    kubectl -n ${bpNamespace} patch daemonset btel-belk-fluentd-daemonset -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existing": "true"}}}}}'
    fdDown=$(kubectl get pods -n ${bpNamespace} | grep btel-belk-fluentd-daemonset | wc -l)
    while [ $fdDown -gt 0 ]
    do
        sleep 1
        fdDown=$(kubectl get pods -n ${bpNamespace} | grep btel-belk-fluentd-daemonset | wc -l)
    done
    log_info "Fluentd pods are down"

}

function fluentStart() {

   kubectl -n ${bpNamespace} patch daemonset btel-belk-fluentd-daemonset --type json -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/non-existing"}]'
   log_info "Fluentd restarted..."
   [ ! $? -eq 0 ] && log_error_and_exit "Fluentd restart did not work" || log_info "Fluentd pods are coming up!!!"

}



function RestoreNfsMounts() {

    mountcheck=`kubectl get pv btel-belk-elasticsearch-nfs-pv -o=jsonpath={'.spec.mountOptions'} | cut -d '' -f 2`
    log_info "The current mount option is ${mountcheck}"
    #[soft async timeo=7 retrans=4 vers=4.1]
    if [[ "$mountcheck" == "[soft async timeo=7 retrans=4 vers=4.1]" ]]; then
            log_info "NFS Mount Points are fine for elasticsearch"
    else
        kubectl get pv -n ${bpNamespace} btel-belk-elasticsearch-nfs-pv -o=yaml > ${SCRIPT_DIR}/btelNFS.yml
        log_info "${mountCheck} need to be updated as soft async timeo=7 retrans=4 vers=4.1"
        kubectl patch pv -n ${bpNamespace} btel-belk-elasticsearch-nfs-pv --type=json -p='[{"op": "add", "path": "/spec/mountOptions", "value" : ["soft","async","timeo=7","retrans=4","vers=4.1"] }]'
        esdatapod=$(kubectl get sts -n ${bpNamespace} btel-belk-elasticsearch-data -o jsonpath='{.status.replicas}')
        log_info "Elastic Search Data pod is ${esdatapod}"
        esmaster=$(kubectl get sts -n ${bpNamespace} btel-belk-elasticsearch-master -o jsonpath='{.status.replicas}')
        log_info "Elastic Search Master pod(s) ${esmaster}"
        esclient=$(kubectl get deployment -n ${bpNamespace} btel-belk-elasticsearch-client -o jsonpath='{.status.replicas}')
        log_info "Elastic Search client pod(s) ${esclient}"
        kubectl scale sts -n ${bpNamespace} btel-belk-elasticsearch-data --replicas=0
        kubectl scale sts -n ${bpNamespace} btel-belk-elasticsearch-master --replicas=0
        kubectl scale deployment -n ${bpNamespace} btel-belk-elasticsearch-client --replicas=0
        log_info "Stopping the Elastic Pods!"
        esdown=$(kubectl get pods -n ${bpNamespace} | grep btel-belk-elasticsearch | wc -l)
        while [ $esdown -gt 0 ]
        do
            sleep 1
            esdown=$(sudo kubectl get pods -n ${bpNamespace} | grep btel-belk-elasticsearch | wc -l)
        done
        log_info "Starting up the Elastic pods"
        kubectl scale sts -n ${bpNamespace} btel-belk-elasticsearch-data --replicas=$esdatapod 
        kubectl scale sts -n ${bpNamespace} btel-belk-elasticsearch-master --replicas=$esmaster
        kubectl scale deployment -n ${bpNamespace} btel-belk-elasticsearch-client --replicas=$esclient 
    fi
}


function btelRestore() {

    belkESCheck=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=jsonpath={'.spec.k8sobjects'} | grep btel-belk-elasticsearch)
    belkCMCheck=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=jsonpath={'.spec.k8sobjects'} | grep configmaps)
    belklabelKeyCheck=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=jsonpath={'.spec.k8sobjects'} | grep label-key)
    belkBackupKeyCheck=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=jsonpath={'.spec.k8sobjects'} | grep backup)
    belkNameCheck=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=jsonpath={'.spec.k8sobjects'} | grep name)


    if [[ ! -z "$belkCMCheck" && ! -z belkESCheck && ! -z belklabelKeyCheck && ! -z belklabelKeyCheck && ! -z belklabelKeyCheck ]]; then
        kubectl get brpolices.cbur.bcmt.local -n ${bpNamespace} btel-belk-elasticsearch-data -o=yaml > ${SCRIPT_DIR}/btelBrPolicy.yml
        log_info "Backed up BTEL Policy"
        if [[ ! -z "$belkCMCheck" && "${RESTORE_BTEL_ES_CONFIG_MAPS}" == "false" ]]; then
            CONFIGMAPS_INDEX=$(kubectl get br -n ${bpNamespace} btel-belk-elasticsearch-data -o=json | jq '.spec.k8sobjects | map(."object-type" == "configmaps") | index(true)')
            kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "remove", "path": "/spec/k8sobjects/'${CONFIGMAPS_INDEX}'"}]'
            [ ! $? -eq 0 ] && log_error_and_exit "The BTEL ES config maps removal from BrPolicy unsuccessful" || log_info "The BTEL ES config maps removal from BrPolicy successful"
        fi
        RestoreCheckCbur btel
        # using & so that pid can be retrieved in $! and use that to wait
        kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "remove", "path": "/spec/k8sobjects/0"}]'
        [ ! $? -eq 0 ] && log_error_and_exit "The Patch did not work for removal" || log_info "The Patch worked for removal and executing next step"
        if [ "${RESTORE_BTEL_ES_CONFIG_MAPS}" == "true" ]; then
            kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "remove", "path": "/spec/k8sobjects/0"}]'
            [ ! $? -eq 0 ] && log_error_and_exit "The Patch did not work for removal" || log_info "The Patch worked for removal and moving next step"
        fi
        RestoreCheckCbur btel
        kubectl delete brpolices.cbur.bcmt.local -n ${bpNamespace} btel-belk-elasticsearch-data
        kubectl apply -f ${SCRIPT_DIR}/btelBrPolicy.yml
    else
        log_info "BTEL K8Sobjects is empty!"
        if [ "${RESTORE_BTEL_ES_CONFIG_MAPS}" == "true" ]; then
            kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "add", "path": "/spec/k8sobjects/0", "value" :{"match-criteria": "name","match-string": "btel-belk-elasticsearch","object-type": "configmaps" }}]'
            [ ! $? -eq 0 ] && log_error_and_exit "The Patch Add operation did not work" || log_info "The Patch Add operation worked and moving to next step"
            log_info "BTEL K8Sobjects entries added for match-criteria!"
        else
            log_info "BTEL ES config maps will not be restored"
        fi
        kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "add", "path": "/spec/k8sobjects/0", "value" :{ "label-key": { "backup": "true" }, "match-criteria": "label", "object-type": "Secret" }}]'
        [ ! $? -eq 0 ] && log_error_and_exit "The Patch Add operation did not work" || log_info "The Patch Add operation worked and moving to next step"
        log_info "BTEL K8Sobjects entries added for label-key!"
        RestoreCheckCbur btel
        kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "remove", "path": "/spec/k8sobjects/0"}]'
        [ ! $? -eq 0 ] && log_error_and_exit "The Patch Remove operation did not work" || log_info "The Patch Remove operation worked and moving to next step"
        if [ "${RESTORE_BTEL_ES_CONFIG_MAPS}" == "true" ]; then
            kubectl patch br -n ${bpNamespace} btel-belk-elasticsearch-data --type=json -p='[{"op": "remove", "path": "/spec/k8sobjects/0"}]'
            [ ! $? -eq 0 ] && log_error_and_exit "The Patch Remove operation did not work" || log_info "The Patch Remove operation worked and moving to next step"
        fi
        RestoreCheckCbur btel
    fi
}

function UpdateDBUser() {

    graSec=$(kubectl get secrets -n ${configurationNamespace} btel-db-config-config-file -o jsonpath='{.data.btel\.sql}' | base64 -d | grep "ALTER USER" | cut -d " " -f 7 | head -n 1 | sed -e 's/^"//' -e 's/"$//' | cut -d ";" -f 1)
    #echo $c
    grapass=${graSec//\"/}
    #echo $grapass
    al=$(kubectl get secrets -n ${configurationNamespace} btel-db-config-config-file -o jsonpath='{.data.btel\.sql}' | base64 -d | grep "ALTER USER" | cut -d " " -f 7 | tail -n 1 | sed -e 's/^"//' -e 's/"$//' | cut -d ";" -f 1)
    almapas=${al//\"/}
    #echo $almapas
    grafuser=$(kubectl get secrets -n ${configurationNamespace} btel-db-config-config-file -o jsonpath='{.data.btel\.sql}' | base64 -d | grep "ALTER USER" | cut -d " " -f 3 | head -n 1)
    [ -z "$grafuser" ] && log_error_and_exit "The Grafana user is not available" || log_info "The Grafana user present"
    almauser=$(kubectl get secrets -n ${configurationNamespace} btel-db-config-config-file -o jsonpath='{.data.btel\.sql}' | base64 -d | grep "ALTER USER" | cut -d " " -f 3 | tail -n 1)
    [ -z "$almauser" ] && log_error_and_exit "The alma user is not available" || log_info "The alma user present"
    mariadbSecret=$(kubectl get secrets -n ${configurationNamespace} cmdb-configurator-config -o jsonpath='{.data.mariadb-password}' | cut -d "[" -f 1)
    #cmdbSh="show databases;"
    #echo $cmdbSh > ${SCRIPT_DIR}/update01.sql
    mariaPass=$(echo $mariadbSecret | base64 -d)
    AlmaUserData="ALTER USER $almauser IDENTIFIED BY \"$almapas\";"
    GrafanaUserData="ALTER USER $grafuser IDENTIFIED BY \"$grapass\";"
    #echo $createdataUser >> test.sql
    echo $AlmaUserData >> update01.sql
    echo $GrafanaUserData >> ${SCRIPT_DIR}/update01.sql
    echo "FLUSH PRIVILEGES;" >> ${SCRIPT_DIR}/update01.sql
    #awk and cut are not working so will need to find another way

    masterdb=$(kubectl get pod -n "${bpNamespace}" -l app=cmdb,type=mariadb,mariadb-master==yes -o jsonpath={.items[0].metadata.name})
    #echo $baseCurrentSec
    kubectl cp update01.sql ${bpNamespace}/${masterdb}:/mariadb/data/.
    #kubectl exec -it -n ${bpNamespace} cmdb-mariadb-0 --container=mariadb bash -- -c 'mysql --ssl --host=cmdb-mysql.${bpNamespace}.svc --user=mariadbuser -p'$mariaPass' < /mariadb/data/update01.sql'
    #above command is not working since build 19.0.3331 so updating to localhost then I found that even localhost game issue. This was due to having labels in backup. 
    #In NCS20 FP1 does not work: kubectl exec -it -n ${bpNamespace} cmdb-mariadb-0 --container=mariadb bash -- -c 'mysql --ssl --host 127.0.0.1 --user=mariadbuser -p'$mariaPass' < /mariadb/data/update01.sql'
    kubectl exec -it -n ${bpNamespace} ${masterdb} --container=mariadb -- /bin/sh -c 'mysql --ssl --host 127.0.0.1 --user=mariadbuser -p'$mariaPass' < /mariadb/data/update01.sql'
    [ ! $? -eq 0 ] && log_error_and_exit "The Database first update failed" || log_info "The Database first update applied"
    echo "use db4keycloak" > ${SCRIPT_DIR}/update02.sql
    baseCurrentSec=$(kubectl get secrets -n ${configurationNamespace} ckey-netguard-config-base-platform-sso-secret -o jsonpath='{.data.base-platform-sso-secret}' | base64 -d )
    [ -z "$baseCurrentSec" ] && log_error_and_exit "The Base Platform Secret is not available" || log_info "The Base Platform secret is present"
    updateBase01="update client set secret='"
    updateBase02=$baseCurrentSec
    updateBase03="' where client_id='base_platform_sso';"

    echo $updateBase01$updateBase02$updateBase03 >> ${SCRIPT_DIR}/update02.sql
    kubectl cp update02.sql ${bpNamespace}/$masterdb:/mariadb/data/.
    #kubectl exec -it -n ${bpNamespace} cmdb-mariadb-0 --container=mariadb bash -- -c 'mysql --ssl --host=cmdb-mysql.${bpNamespace}.svc --user=mariadbuser -p'$mariaPass' < /mariadb/data/update02.sql'
    #above command is not working since build 19.0.3331 so updating to localhost
    #In NCS20 FP1 does not work: kubectl exec -it -n ${bpNamespace} ${masterdb} --container=mariadb bash -- -c 'mysql --ssl --host 127.0.0.1 --user=mariadbuser -p'$mariaPass' < /mariadb/data/update02.sql'
    kubectl exec -it -n ${bpNamespace} ${masterdb} --container=mariadb -- /bin/sh -c 'mysql --ssl --host 127.0.0.1 --user=mariadbuser -p'$mariaPass' < /mariadb/data/update02.sql'
    [ ! $? -eq 0 ] && log_error_and_exit "The Database final update failed" || log_info "The Database final update applied"
    log_info "Cleaning up created files"
    rm ${SCRIPT_DIR}/update01.sql
    rm ${SCRIPT_DIR}/update02.sql

}


function RestoreCheckCbur() {

    capp=$1
    log_info "The ${capp} restore task status is initiated"
    sudo -i helm restore -t $capp | jq '.' > restoreProcess.json
    backid=$(cat restoreProcess.json | grep message | rev | cut -d " " -f 3 | rev)
    sudo -i helm restore -i $backid | jq '.' > celeryRstatus.json
    cstatus=$(cat celeryRstatus.json | jq '.status' | tr -d '"')
    while [[ "$cstatus" != "Success" ]] && [[ "$cstatus" != "Failure" ]]
    do
        sudo -i helm restore -i $backid | jq '.' > celeryRstatus.json
        cstatus=$(cat celeryRstatus.json | jq '.status' | tr -d '"')
        if [[ -z "$cstatus" ]]; then
           log_error_and_exit "The ${capp} restore task failed, Please investigate the failure!!!"
        fi
    done
    if [[ $cstatus == "Failure" ]]; then
        log_error_and_exit "The restore failed during ${capp}, Please investigate issue!!!"
    else
        log_info "The ${capp} restore task status is ${cstatus}"
    fi
    rm restoreProcess.json
    rm celeryRstatus.json
}


function restoreCburData() {

    set -e
    RestoreCheckCbur cmdb
    RestoreCheckCbur cmdb-configurator-config
    RestoreCheckCbur ckey-configurator-config
    RestoreCheckCbur ckey
    set +e
    log_info "Restore of CMDB CKEY CMDB Secret and CKEY Secrets"
}

function restartPods() {

    cmdbpod=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} cmdb-mariadb -o jsonpath='{.status.replicas}')
    cmdbadmin=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} cmdb-admin -o jsonpath='{.status.replicas}')
    maxscale=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} cmdb-maxscale -o jsonpath='{.status.replicas}')
    grafanapod=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} grafana -o jsonpath='{.status.replicas}')
    calmpod=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} btel-calm -o jsonpath='{.status.replicas}')
    ckeypod=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} ckey-ckey -o jsonpath='{.status.replicas}')
    crmqpod=$(sudo kubectl get statefulsets.apps -n ${bpNamespace} crmq-crmq -o jsonpath='{.status.replicas}')
    cingresspod=$(sudo kubectl get pod -n ${bpNamespace} | grep citm-citm-ingress-controller | cut -d" " -f 1)

    log_info "The CMDB Mariadb number of pod(s): ${cmdbpod}"
    log_info "The CMDB maxscale number of pod(s): ${maxscale}"
    log_info "The CMDB admin number of pod(s): ${cmdbadmin}"
    log_info "The grafana number of pod(s): ${grafanapod}"
    log_info "The CALM number pod(s): ${calmpod}"
    log_info "The CKEY number of pod(s): ${ckeypod}"
    log_info "The CRMQ number of pod(s): ${crmqpod}"

    log_info "Stopping the PODS"
    kubectl scale sts -n ${bpNamespace} cmdb-mariadb --replicas=0
    kubectl scale sts -n ${bpNamespace} cmdb-admin --replicas=0
    kubectl scale sts -n ${bpNamespace} grafana --replicas=0
    kubectl scale sts -n ${bpNamespace} btel-calm --replicas=0
    kubectl scale sts -n ${bpNamespace} ckey-ckey --replicas=0
    kubectl scale sts -n ${bpNamespace} crmq-crmq --replicas=0
    kubectl delete pod -n ${bpNamespace} $cingresspod 
    log_info "Starting up the PODS"
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} cmdb-mariadb --replicas=$cmdbpod
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} cmdb-admin --replicas=$cmdbadmin
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} grafana --replicas=$grafanapod
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} btel-calm  --replicas=$calmpod
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} ckey-ckey --replicas=$ckeypod
    kubectl scale sts -n ${bpNamespace} -n ${bpNamespace} crmq-crmq --replicas=$crmqpod

}

function waitForReadyPod () {
    POD=$1
    NAME_COLUMN=1
    READY_COLUMN=2
    STATE_COLUMN=3
    log_info "Waiting for pod $POD to initialize"

    while true;
    do
        pod_information=$(kubectl get pods -n ${bpNamespace} | grep $POD | grep -v -e Completed -e Terminating -e ContainerCreating -e Init -e Pending)
        pod_state=$(echo ${pod_information} | awk '{print $'${STATE_COLUMN}'}')

        if [ "$pod_state" != "" ] ; then
            if [ "$pod_state" == "Running" ] ; then
                pod_status=$(echo ${pod_information} | awk '{print $'${READY_COLUMN}'}')
                ready_replicas=${pod_status%/*}
                all_replicas=${pod_status#*/}

                if [ ${ready_replicas} == ${all_replicas} ] ; then
                    return
                fi
            else
                pod_name=$(echo ${pod_information} | awk '{print $'${NAME_COLUMN}'}')
                log_error_and_exit "Error: Cannot start the pod. Pod ${pod_name} state: ${pod_state}"
                exit 1
            fi
        fi
        sleep 2
    done
}

function getStatefulSetExpectedReplicas () {
    COMPONENT_NAME=$1

    REPLICAS=$(kubectl get statefulsets ${COMPONENT_NAME} -n ${bpNamespace} -o jsonpath='{.spec.replicas}')
    echo ${REPLICAS}
}

function getStatefulsetReadyReplicas () {
    COMPONENT_NAME=$1

    READY_REPLICAS=$(kubectl get statefulsets ${COMPONENT_NAME} -n ${bpNamespace} -o jsonpath='{.status.readyReplicas}')
    [ -z ${READY_REPLICAS} ] && READY_REPLICAS=0
    echo "${READY_REPLICAS}"
}

function waitForStatefulSetReplicas () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    log_info "Waiting for ${COMPONENT_NAME} statefulset replicas count: ${REPLICAS}"
    local counter=0
    while [ $(getStatefulsetReadyReplicas ${COMPONENT_NAME}) -ne "${REPLICAS}" ]
    do
        if [ ${counter} -lt ${WAIT_TIMEOUT_SEC} ]; then
            sleep 1
            ((counter++))
        else
            log_error_and_exit "Timeout waiting for ${COMPONENT_NAME} statefulset replicas count ${REPLICAS}"
        fi
    done
}

function restartStatefulSet () {
    STATEFULSET=$1
    ORIGINAL_REPLICA_COUNT=$(getStatefulSetExpectedReplicas ${STATEFULSET})
    log_info "Restarting ${STATEFULSET}"
    kubectl get pods -n "${bpNamespace}" -o=custom-columns=":metadata.name" | grep ${STATEFULSET} | xargs kubectl delete pod -n netguard-base
    waitForStatefulSetReplicas ${STATEFULSET} ${ORIGINAL_REPLICA_COUNT}
}

function restartMaxScale () {
    restartStatefulSet cmdb-maxscale
}

function getMariaDbMasterPod () {
    kubectl get pod -n "${bpNamespace}" -l app=${CMDB_APP},type=${MARIADB_LBL},mariadb-master==yes -o jsonpath={.items[0].metadata.name}
}

function getMariaDbSlavePod () {
    kubectl get pod -n "${bpNamespace}" -l app=${CMDB_APP},type=${MARIADB_LBL},mariadb-master!=yes -o jsonpath={.items[0].metadata.name}
}

function getServerId () {
    local pod_name=$1

    kubectl exec -n "${bpNamespace}" "${pod_name}" -c "${MARIADB_CONTAINER}" -- bash -c \
        'mysql -u root --password=$(/usr/bin/mariadb_passwd --get --user root) -e "select @@server_id"' | tail -n 1
}

function getMasterServerId () {
    getServerId "$(getMariaDbMasterPod)"
}

function getSlaveServerId () {
    getServerId "$(getMariaDbSlavePod)"
}

function getNewServerId () {
    local slave_server_id=$(getSlaveServerId)
    local master_server_id=$(getMasterServerId)
    local new_server_id=$(( (${RANDOM} % ${MAX_SERVER_ID}) + 1 ))

    while [[ "${new_server_id}" == "${slave_server_id}" ]] || [[ "${new_server_id}" == "${master_server_id}" ]]; do
        new_server_id=$(( (${RANDOM} % ${MAX_SERVER_ID}) + 1 ))
    done

    echo ${new_server_id}
}

function fixServerId () {
    local mariadb_pod=$(getMariaDbSlavePod)
    local new_server_id=$(getNewServerId)

    kubectl exec -it -n "${bpNamespace}" "${mariadb_pod}" -c mariadb -- \
        sed -i "s/^MY_SERVER_ID.*/MY_SERVER_ID=${new_server_id}/g" /mariadb/data/cmdb-recovery.info ||
        log_error_and_exit "Changing server id in pod ${mariadb_pod} failed."

    log_info "Server id successfully changed to ${new_server_id} in pod ${mariadb_pod}"

    kubectl delete pod -n "${bpNamespace}" "${mariadb_pod}"
    log_info "Pod ${mariadb_pod} restarted after server id change"
    waitForReadyPod ${mariadb_pod}
}

function areServerIdsTheSame () {
    [[ "$(getSlaveServerId)" == "$(getMasterServerId)" ]] && return 0 || return 1
}

function getRunningSlaveNodeCount () {
    kubectl exec -n "${bpNamespace}" cmdb-maxscale-0 -c maxscale -- /usr/lib/mariadb/maxscale_rest_api.py --list-servers | grep -v Master | grep -i Slave | grep -i -c Running
}

function waitForRunningCmdbSlaveNode () {
    log_info "Waiting for running CMDB slave node"
    local counter=0
    while [ $(getRunningSlaveNodeCount) -lt ${MIN_CMDB_SLAVE_COUNT} ]; do
        if [ ${counter} -lt ${WAIT_TIMEOUT_SEC} ]; then
            sleep 1
            ((counter++))
        else
            log_error_and_exit "Timeout waiting for ready CMDB slave node"
        fi
    done
    log_info "CMDB slave node up and running"
}

function BaseConfigRestore(){

    find . -maxdepth 1 -name $productConfigFiles | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${productConfigFiles} does not exists so Script is terminating" || log_info "The file ${productConfigFiles} present"
    sudo tar -zxvf $productConfigFiles -P
    log_info "The ${productConfigFiles} is extracted, Install Base Platform as will terminate"
     exit "${APP_ERROR_CODE}"

}

function restoreLocation(){

    celerypod=$(kubectl get pod -n ncms | grep cbur-master-cbur-mycelery | cut -d " " -f 1 2>&1)
    celerynode=$(kubectl describe pod -n ncms $celerypod | grep Node: | cut -d / -f 2 2>&1)
    vcontrol=$(ifconfig -a | grep $celerynode 2>&1)
    ssh-keyscan -4 $celerynode >> ~/.ssh/known_hosts
    cburrepopv=$(ssh -q -i $key cloud-user@$celerynode 'sudo kubectl get pv | grep cbur-repo | cut -d " " -f 1' 2>&1)
    log_info "The ${cburrepopv} is the CBUR PV"
    psvolpath=$(ssh -q -i $key cloud-user@$celerynode "sudo df -h | grep $cburrepopv | cut -d % -f 2" 2>&1)
    log_info "The ${psvolpath} is the CBUR volume location"
    basereposl=/
    baserep=repo/data/${bpNamespace}/
    baseconfrepo=repo/data/${configurationNamespace}/
    basebtelrepo=STATEFULSET_btel-belk-elasticsearch-data/
    baseckeyrepo=STATEFULSET_ckey-ckey/
    basecmdbrepo=STATEFULSET_cmdb-mariadb/
    baseconfk8cmdb=K8SOBJECTS_cmdb-configurator-config/
    baseconfk8ckey=K8SOBJECTS_ckey-configurator-config/

    vcontrol=$(sudo ifconfig -a | grep $celerynode 2>&1)
    log_info "The ${productConfigFiles} is extracted to the configuration directory"

    if [[ -z "$vcontrol" ]]; then
        sudo ssh-keyscan -4 $celerynode >> ~/.ssh/known_hosts
        cburrepopv=$(ssh -q -i $key cloud-user@$celerynode 'sudo kubectl get pv | grep cbur-repo | cut -d " " -f 1' 2>&1)
        log_info "The ${cburrepopv} is the CBUR PV"
        psvolpath=$(ssh -q -i $key cloud-user@$celerynode "sudo df -h | grep $cburrepopv | cut -d % -f 2" 2>&1)
        log_info "The ${psvolpath} is the CBUR volume location"

        log_info "Copying BTEL backup files to celery home directory location"
        scp -q -i $key $dataBTEL cloud-user@$celerynode:/home/cloud-user/. 
        log_info "Copying CKEY backup file to celery home directory location"
        scp -q -i $key $dataCKEY cloud-user@$celerynode:/home/cloud-user/.
        log_info "Copying CMDB backup file to celery home directory location"
        scp -q -i $key $dataCMDB cloud-user@$celerynode:/home/cloud-user/.
        log_info "Copying CKEY Secret file to celery home directory location"
        scp -q -i $key $dataCKEYSecret cloud-user@$celerynode:/home/cloud-user/.
        log_info "Copying CMDB Secret backup file to celery home directory location"
        scp -q -i $key $dataCMDBSecret cloud-user@$celerynode:/home/cloud-user/.
        log_info "Copying backup files to cloud-user home directory location complete"
        log_info "Copying backup files to glusterfs mount location"
        ssh -q -i $key cloud-user@$celerynode "sudo cp /home/cloud-user/btel.tar.gz $psvolpath$basereposl."
        ssh -q -i $key cloud-user@$celerynode "sudo cp /home/cloud-user/baseckey.tar.gz $psvolpath$basereposl."
        ssh -q -i $key cloud-user@$celerynode "sudo cp /home/cloud-user/basecmdb.tar.gz $psvolpath$basereposl."
        ssh -q -i $key cloud-user@$celerynode "sudo cp /home/cloud-user/baseckeysec.tar.gz $psvolpath$basereposl."
        ssh -q -i $key cloud-user@$celerynode "sudo cp /home/cloud-user/basecmdbsec.tar.gz $psvolpath$basereposl."
        log_info "Copying backup files to glusterfs location complete"
        ssh -q -i $key cloud-user@$celerynode "sudo rm /home/cloud-user/btel.tar.gz"
        ssh -q -i $key cloud-user@$celerynode "sudo rm /home/cloud-user/baseckey.tar.gz"
        ssh -q -i $key cloud-user@$celerynode "sudo rm /home/cloud-user/basecmdb.tar.gz"
        ssh -q -i $key cloud-user@$celerynode "sudo rm /home/cloud-user/baseckeysec.tar.gz"
        ssh -q -i $key cloud-user@$celerynode "sudo rm /home/cloud-user/basecmdbsec.tar.gz"

        basebtel=/btel.tar.gz
        baseckey=/baseckey.tar.gz
        basecmdb=/basecmdb.tar.gz
        baseckeysec=/baseckeysec.tar.gz
        basecmdbsec=/basecmdbsec.tar.gz
        log_info "Initiated Extraction of datafiles in glusterfs repo "
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zxvf $psvolpath$basebtel -C $psvolpath$basereposl"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zxvf $psvolpath$baseckey -C $psvolpath$basereposl"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zxvf $psvolpath$basecmdb -C $psvolpath$basereposl"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zxvf $psvolpath$baseckeysec -C $psvolpath$basereposl"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zxvf $psvolpath$basecmdbsec -C $psvolpath$basereposl"
        log_info "Extraction of datafiles in glusterfs repo completed!"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $psvolpath$basebtel"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $psvolpath$baseckey"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $psvolpath$basecmdb"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $psvolpath$baseckeysec"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $psvolpath$basecmdbsec"
    else
        cburrepopv=$(sudo kubectl get pv | grep cbur-repo | cut -d " " -f 1 2>&1)
        log_info "The ${cburrepopv} is the CBUR PV"
        psvolpath=$(sudo df -h | grep $cburrepopv | cut -d % -f 2 2>&1)
        log_info "The ${psvolpath} is the CBUR volume location"
        log_info "Copying backup files to glusterfs mount location"
        cp /home/cloud-user/$dataBTEL $psvolpath$basereposl.
        cp /home/cloud-user/$dataCKEY $psvolpath$basereposl.
        cp /home/cloud-user/$dataCMDB $psvolpath$basereposl.
        cp /home/cloud-user/$dataCKEYSecret $psvolpath$basereposl.
        cp /home/cloud-user/$dataCMDBSecret $psvolpath$basereposl.
        log_info "Copying backup files to glusterfs location complete"
        basebtel=/btel.tar.gz
        baseckey=/baseckey.tar.gz
        basecmdb=/basecmdb.tar.gz
        baseckeysec=/baseckeysec.tar.gz
        basecmdbsec=/basecmdbsec.tar.gz
        log_info "Initiated Extraction of datafiles in glusterfs repo "
        tar -zxvf $psvolpath$basebtel -C $psvolpath$basereposl
        tar -zxvf $psvolpath$baseckey -C $psvolpath$basereposl
        tar -zxvf $psvolpath$basecmdb -C $psvolpath$basereposl
        tar -zxvf $psvolpath$baseckeysec -C $psvolpath$basereposl
        tar -zxvf $psvolpath$basecmdbsec -C $psvolpath$basereposl
        log_info "Extraction of datafiles in glusterfs repo completed!"
        rm $psvolpath$basebtel
        rm $psvolpath$baseckey
        rm $psvolpath$basecmdb
        rm $psvolpath$baseckeysec
        rm $psvolpath$basecmdbsec
    fi
    restoreCburData
    fluentdstop
    btelRestore
    fluentStart
    RestoreNfsMounts
    restartPods
    restartMaxScale
    if $(areServerIdsTheSame); then # WA for https://jiradc2.ext.net.nokia.com/browse/CSFS-32472
        log_info "CMDB master server id equals slave server id - fixing server ids"
        fixServerId
    fi
    waitForRunningCmdbSlaveNode
    UpdateDBUser
    log_info "Restore of Base Platform is complete!!! Please wait until PODS are running state before launching UI"
}

function display_help {
    echo "This script restores Base Platform"
    echo "Usage: $0 [options...]" >&2
    echo "Optional arguments:"
    echo "   --skip-btel-es-cm If set script will not restore BTEL ES config maps"
    echo "Examples: $0 --skip-btel-es-cm"
}

function parse_input_parameters {
    for i in "${@}"
    do
    case $i in
        --skip-btel-es-cm*)
        RESTORE_BTEL_ES_CONFIG_MAPS="false"
        shift
        ;;
        -h|--help)
        display_help
        exit 0
        ;;
    esac
    done
}

parse_input_parameters "${@}"

if [[ "$tbackup" == "local" ]]; then
    log_info "Checking Base Platform status"
    kubectl get namespace | grep ${bpNamespace} 2>&1
    [ ! $? -eq 0 ] && BaseConfigRestore || log_info "The Base Platform installed present"
    find . -maxdepth 1 -name $dataBTEL | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${dataBTEL} does not exist so Script is terminating" || log_info "The file ${dataBTEL} present"
    find . -maxdepth 1 -name $dataCMDB | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${dataCMDB} does not exist so Script is terminating" || log_info "The file ${dataCMDB} present"
    find . -maxdepth 1 -name $dataCKEY | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${dataCKEY} does not exist so Script is terminating" || log_info "The file ${dataCKEY} present"
    find . -maxdepth 1 -name $dataCMDBSecret | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${dataCMDBSecret} does not exist so Script is terminating" || log_info "The file ${dataCMDBSecret} present"
    find . -maxdepth 1 -name $dataCKEYSecret | grep .
    [ ! $? -eq 0 ] && log_error_and_exit "The File  ${dataCKEYSecret} does not exist so Script is terminating" || log_info "The file ${dataCKEYSecret} present"
    helm list | grep netguard-base | grep geo-redundancy-btel | grep DEPLOYED 2>&1
    [ ! $? -eq 0 ] && log_error_and_exit "The Base Platform installation is not complete" || restoreLocation
elif [[ "$tbackup" == "sftp" ]] ; then
    log_info "Checking Base Platform status"
    kubectl get namespace | grep ${bpNamespace} 2>&1
    [ ! $? -eq 0 ] && BaseConfigRestore || log_info "The Base Platform installation is present"
    helm list | grep netguard-base | grep geo-redundancy-btel | grep DEPLOYED 2>&1
    [ ! $? -eq 0 ] && log_error_and_exit "The Base Platform is not fully installed" || restoreCburData
    fluentdstop
    btelRestore
    fluentStart
    RestoreNfsMounts
    restartPods
    restartMaxScale
    if $(areServerIdsTheSame); then  # WA for https://jiradc2.ext.net.nokia.com/browse/CSFS-32472
        log_info "CMDB master server id equals slave server id - fixing server ids"
        fixServerId
    fi
    waitForRunningCmdbSlaveNode
    UpdateDBUser
    log_info "Restore of Base Platform is complete!!! Please wait until PODS are running state before launching UI"
else
    log_error_and_exit "The File  ${tbackup} option is not valid so the script is terminating!!!"
fi
