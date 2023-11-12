#!/bin/bash

#Define the product
defbase="netguard_base_platform"

#define variables for each product configuration path
bpconf=/opt/bcmt/storage/bp_config_vars.yml

#define the backup file names
baseDBSec=basecmdbsec.tar.gz
baseKeySec=baseckeysec.tar.gz 
baseDB=basecmdb.tar.gz 
baseKey=baseckey.tar.gz
baseBELK=btel.tar.gz

readonly APP_ERROR_CODE=2
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )"


echo "What is the absolute path of private key to access the cluster? i.e) /home/cloud-user/clcm.pem"
read key

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


function Postbackup() {

    bmode=$(kubectl get br -n ${bpNamespace} cmdb-mariadb -o jsonpath={.spec.backend.mode})
    log_info "Initiating the compression of latest backups followed by transfering to the script directory"
    celerypod=$(kubectl get pod -n ncms | grep cbur-master-cbur-mycelery | cut -d " " -f 1 )
    log_info "The celery pod is ${celerypod}"
    celerynode=$(kubectl get pod -n ncms $celerypod -o=jsonpath={.status.hostIP})
    log_info "The celery node is ${celerynode}"
    vcontrol=$(ifconfig -a | grep $celerynode)
 
    if [[ "$bmode" == "local" &&  -z "$vcontrol" ]]; then
        log_info " The backup mode is local and the celery on other control node"
        ssh-keyscan -4 $celerynode >> ~/.ssh/known_hosts
        cburrepopv=$(ssh -q -i $key cloud-user@$celerynode 'sudo kubectl get pv | grep cbur-repo | cut -d " " -f 1' 2>&1)
	[ -z "$cburrepopv" ] && log_error_and_exit "The CBUR Repo Persisted Volume is not found" || log_info "The CBUR repo Persisted Volume ${cburrepopv}"
        psvolpath=$(ssh -q -i $key cloud-user@$celerynode "sudo df -h | grep $cburrepopv | cut -d % -f 2" 2>&1)
        [ -z "$psvolpath" ] && log_error_and_exit "The CBUR Repo Persisted Volume Path is not found" || log_info "The CBUR Repo Persisted Volume is ${psvolpath}"
	basereposl=/
        baserep=repo/data/${bpNamespace}/
        baseconfrepo=repo/data/${configurationNamespace}/
        basebtelrepo=STATEFULSET_btel-belk-elasticsearch-data/
        baseckeyrepo=STATEFULSET_ckey-ckey/
        basecmdbrepo=STATEFULSET_cmdb-mariadb/

        eslatest=$(ssh -q -i $key cloud-user@$celerynode "sudo ls -ltr $psvolpath$basereposl$baserep$basebtelrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev" 2>&1)
        [ -z "$eslatest" ] && log_error_and_exit "The Elastic Search Latest Backup is not found" || log_info "The Elastic Search Latest Backup is ${eslatest}"
        log_info "Compressing BTEL Backup"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zcvf /home/cloud-user/$baseBELK -C $psvolpath $baserep$basebtelrepo$eslatest" 2>&1
        baseckey=$(ssh -q -i $key cloud-user@$celerynode "sudo ls -ltr $psvolpath$basereposl$baserep$baseckeyrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev" 2>&1)
        [ -z "$baseckey" ] && log_error_and_exit "The CKEY Latest Backup is not found" || log_info "Compressing the Latest CKEY Backup ${baseckey}"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zcvf /home/cloud-user/$baseKey -C $psvolpath $baserep$baseckeyrepo$baseckey" 2>&1
        basecmdb=$(ssh -q -i $key cloud-user@$celerynode "sudo ls -ltr $psvolpath$basereposl$baserep$basecmdbrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev" 2>&1)
        [ -z "$basecmdb" ] && log_error_and_exit "The CMDB Latest Backup is not found" || log_info "Compressing the Latest CMDB Backup ${basecmdb}"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zcvf /home/cloud-user/$baseDB -C $psvolpath $baserep$basecmdbrepo$basecmdb" 2>&1
        log_info "Updating the permission on the compressed CMDB, CKEY and BTEL Backup"
        ssh -q -i $key cloud-user@$celerynode "sudo chown cloud-user:cloud-user /home/cloud-user/$baseBELK /home/cloud-user/$baseKey /home/cloud-user/$baseDB"
        baseconfk8cmdb=K8SOBJECTS_cmdb-configurator-config/
        baseconfk8ckey=K8SOBJECTS_ckey-configurator-config/
        baseconfcmdbsec=$(ssh -q -i $key cloud-user@$celerynode "sudo ls -ltr $psvolpath$basereposl$baseconfrepo$baseconfk8cmdb | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev" 2>&1)
        [ -z "$baseconfcmdbsec" ] && log_error_and_exit "The CMDB Secret Latest Backup is not found" || log_info "Compressing the Latest CMDB Secret Backup ${baseconfcmdbsec}"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zcvf /home/cloud-user/$baseDBSec -C $psvolpath $baseconfrepo$baseconfk8cmdb$baseconfcmdbsec" 2>&1
        baseconfckeysec=$(ssh -q -i $key cloud-user@$celerynode "sudo ls -ltr $psvolpath$basereposl$baseconfrepo$baseconfk8ckey | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev" 2>&1)
        [ -z "$baseconfckeysec" ] && log_error_and_exit "The CKEY Secret Latest Backup is not found" || log_info "Compressing the Latest CKEY Secret Backup ${baseconfckeysec}"
        ssh -q -i $key cloud-user@$celerynode "sudo tar -zcvf /home/cloud-user/$baseKeySec -C $psvolpath $baseconfrepo$baseconfk8ckey$baseconfckeysec" 2>&1
        ssh -q -i $key cloud-user@$celerynode "sudo chown cloud-user:cloud-user /home/cloud-user/$baseDBSec /home/cloud-user/$baseKeySec"
        ssh -q -i $key cloud-user@$celerynode "sudo chmod 664 /home/cloud-user/$baseBELK /home/cloud-user/$baseKey /home/cloud-user/$baseDB /home/cloud-user/$baseDBSec /home/cloud-user/$baseKeySec"
        scp -q -i $key cloud-user@$celerynode:/home/cloud-user/$baseDBSec ${SCRIPT_DIR} 2>&1
	find . -maxdepth 1 -name $baseDBSec | grep .
	[ ! $? -eq 0 ] && log_error_and_exit "The File  ${baseDBSec} download failed" || log_info "The file ${baseDBSec} downloaded"
        scp -q -i $key cloud-user@$celerynode:/home/cloud-user/$baseKeySec ${SCRIPT_DIR} 2>&1
	find . -maxdepth 1 -name $baseKeySec | grep .
	[ ! $? -eq 0 ] && log_error_and_exit "The File  ${baseKeySec} download failed" || log_info "The file ${baseKeySec} downloaded"
        scp -q -i $key cloud-user@$celerynode:/home/cloud-user/$baseKey ${SCRIPT_DIR} 2>&1
        find . -maxdepth 1 -name $baseKey | grep .
	[ ! $? -eq 0 ] && log_error_and_exit "The File  ${baseKey} download failed" || log_info "The file ${baseKey} downloaded"
	scp -q -i $key cloud-user@$celerynode:/home/cloud-user/$baseDB ${SCRIPT_DIR} 2>&1
        find . -maxdepth 1 -name $baseDB | grep .
	[ ! $? -eq 0 ] && log_error_and_exit "The File  ${baseDB} download failed" || log_info "The file ${baseDB} downloaded"
	scp -q -i $key cloud-user@$celerynode:/home/cloud-user/$baseBELK ${SCRIPT_DIR} 2>&1
	find . -maxdepth 1 -name $baseBELK | grep .
	[ ! $? -eq 0 ] && log_error_and_exit "The File  ${baseBELK} download failed" || log_info "The file ${baseBELK} downloaded"
        ssh -q -i $key cloud-user@$celerynode "sudo rm $baseBELK $baseDB $baseKeySec $baseDBSec $baseKey"
        log_info "Files are removed from Control node that has the Persisted Volume Mount"
        log_info "The compressed backup files are now in the script launched directory!"
    elif [[ "$bmode" == "local" &&  ! -z "$vcontrol" ]]; then
        log_info "${vcontrol} on the current node and the back up mode is local"
        cburrepopv=$(kubectl get pv | grep cbur-repo | cut -d " " -f 1)
        [ -z "$cburrepopv" ] && log_error_and_exit "The CBUR Repo Persisted Volume is not found" || log_info "The CBUR repo Persisted Volume ${cburrepopv}"
        psvolpath=$(df -h | grep $cburrepopv | cut -d % -f 2)
        [ -z "$psvolpath" ] && log_error_and_exit "The CBUR Repo Persisted Volume Path is not found" || log_info "The CBUR Repo Persisted Volume is ${psvolpath}"
        basereposl=/
        baserep=repo/data/${bpNamespace}/
        baseconfrepo=repo/data/${configurationNamespace}/
        basebtelrepo=STATEFULSET_btel-belk-elasticsearch-data/
        baseckeyrepo=STATEFULSET_ckey-ckey/
        basecmdbrepo=STATEFULSET_cmdb-mariadb/
        eslatest=$(sudo ls -ltr $psvolpath$basereposl$baserep$basebtelrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev)
        [ -z "$eslatest" ] && log_error_and_exit "The Elastic Search Latest Backup is not found" || log_info "The Elastic Search Latest Backup is ${eslatest}"
        tar -zcvf ${SCRIPT_DIR}/$baseBELK -C $psvolpath $baserep$basebtelrepo$eslatest 2>&1
        baseckey=$(sudo ls -ltr $psvolpath$basereposl$baserep$baseckeyrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev)
        [ -z "$baseckey" ] && log_error_and_exit "The CKEY Latest Backup is not found" || log_info "Compressing the Latest CKEY Backup ${baseckey}"
        tar -zcvf ${SCRIPT_DIR}/$baseKey -C $psvolpath $baserep$baseckeyrepo$baseckey 2>&1
        basecmdb=$(sudo ls -ltr $psvolpath$basereposl$baserep$basecmdbrepo | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev)
        [ -z "$basecmdb" ] && log_error_and_exit "The CMDB Latest Backup is not found" || log_info "Compressing the Latest CMDB Backup ${basecmdb}"
        tar -zcvf ${SCRIPT_DIR}/$baseDB -C $psvolpath $baserep$basecmdbrepo$basecmdb 2>&1
        log_info "Updating the permission on the compressed CMDB CKEY and BTEL Backup"
        baseconfk8cmdb=K8SOBJECTS_cmdb-configurator-config/
        baseconfk8ckey=K8SOBJECTS_ckey-configurator-config/
        baseconfcmdbsec=$(sudo ls -ltr $psvolpath$basereposl$baseconfrepo$baseconfk8cmdb | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev)
        [ -z "$baseconfcmdbsec" ] && log_error_and_exit "The CMDB Secret Latest Backup is not found" || log_info "Compressing the Latest CMDB Secret Backup ${baseconfcmdbsec}"
        tar -zcvf ${SCRIPT_DIR}/$baseDBSec -C $psvolpath $baseconfrepo$baseconfk8cmdb$baseconfcmdbsec 2>&1
        baseconfckeysec=$(sudo ls -ltr $psvolpath$basereposl$baseconfrepo$baseconfk8ckey | grep '^d' | tail -1 | rev | cut -d ' ' -f 1 | rev)
        [ -z "$baseconfckeysec" ] && log_error_and_exit "The CKEY Secret Latest Backup is not found" || log_info "Compressing the Latest CKEY Secret Backup ${baseconfckeysec}"
        tar -zcvf ${SCRIPT_DIR}/$baseKeySec -C $psvolpath $baseconfrepo$baseconfk8ckey$baseconfckeysec 2>&1
        chmod 664 $baseDBSec $baseKeySec $baseDB $baseKey $baseBELK
        log_info "The compressed backup files are now in the script launched directory!"
    else
        log_info "Remote Files are not moved to central location!!!"
    fi
}

function BackupCompletion(){
    capp=$1
    sudo -i helm backup -t $capp | jq '.' > backupProcess.json
    backid=$(cat backupProcess.json | grep message | rev | cut -d " " -f 3 | rev)
    sudo -i helm backup -i $backid | jq '.' > celeryBstatus.json
    cstatus=$(cat celeryBstatus.json | jq '.status' | tr -d '"')
    while [[ "$cstatus" != "Success" ]] && [[ "$cstatus" != "Failure" ]]
    do
        sudo -i helm backup -i $backid | jq '.' > celeryBstatus.json
        cstatus=$(cat celeryBstatus.json | jq '.status' | tr -d '"')
        if [[ -z "$cstatus" ]]; then
           log_error_and_exit "The backup task returned empty so failure occured!"
        fi
    done
    if [[ $cstatus == "Failure" ]]; then
        log_error_and_exit "${capp} backup failed, Please investigate!!!"
    else
        log_info "The ${capp} backup status is ${cstatus}"
    fi
    rm backupProcess.json
    rm celeryBstatus.json
}


function backup() {
    log_info "Initiating the Backup of CMDB"
    set -e
    BackupCompletion cmdb
    log_info "Initiated Backup of BTEL"
    BackupCompletion btel
    log_info "Initiated Backup of CMDB CONFIGURATOR"
    BackupCompletion cmdb-configurator-config
    log_info "Initiated Backup of CKEY CONFIGURATOR"
    BackupCompletion ckey-configurator-config
    log_info "Initiated Backup of CKEY"
    BackupCompletion ckey
    log_info "Backup Completed!!!"
    set +e
    Postbackup
}


kubectl get namespace | grep ${bpNamespace} 2>&1
[ ! $? -eq 0 ] && log_error_and_exit "The Base Platform is not present" || log_info "The Base Platform is present"
tar -zcvf ${SCRIPT_DIR}/productconfig.tar.gz -P $bpconf
chmod 664 ${SCRIPT_DIR}/productconfig.tar.gz
helm list | grep netguard-base | grep geo-redundancy-btel | grep DEPLOYED 2>&1
[ ! $? -eq 0 ] && log_error_and_exit "The Base Platform is partially installed" || log_info "Confirmed Base Platform Installation completion"
backup
