
MINIKUBE_CONTEXT="minikube"
APPS_NS=${1:-'netguard-base'}
JOB_SUCCEEDED=0
JOB_FAILED=2

function debug () {
  if [ ! -z "$DEBUG_ENABLED" ]; then
    log "$*"
  fi
}

function log () {
  >&2 echo -e "$*"
}

function waitForReady () {
    COMPONENT_NAME=$1
    IMAGE_OR_TAG=$2


    GREP_CMD="grep ${COMPONENT_NAME}"

    kind=$(getK8sComponentKind ${COMPONENT_NAME})
    names=$(kubectl get ${kind} -n ${APPS_NS} | eval ${GREP_CMD} | awk '{print $1}')

    for name in $names
    do
        case $kind in
            'Deployment') waitForReadyDeployment $name;;
            'DaemonSet') waitForReadyDaemonSet $name;;
            'StatefulSet') waitForReadyStatefulSet $name $IMAGE_OR_TAG;;
        esac
    done
}

function isPodReady () {
    POD=$1
    READY_COLUMN=2
    pod_status=$(kubectl get pods -n ${APPS_NS} | grep $POD | awk '{print $'$READY_COLUMN'}')
    ready_replicas=${pod_status%/*}
    all_replicas=${pod_status#*/}
    [ $ready_replicas = $all_replicas ]
    echo $?
}

function isJobFinished () {
    JOB=$1
    job_status=$(kubectl get job ${JOB} -n ${APPS_NS} -o jsonpath='{.status.conditions[?(@.type=="Complete")]}')
    [[ $job_status ]]
}

function isJobError () {
    JOB=$1
    JOB_ERROR=`kubectl get pods -n ${APPS_NS} | grep ${JOB} |  awk '{ print $3}' | grep Error`
    if [ -n "${JOB_ERROR}" ]; then
        return 0
    else
        return 1
    fi
}

function waitForReadyPod () {
    POD=$1
    NAME_COLUMN=1
    READY_COLUMN=2
    STATE_COLUMN=3
    echo -ne "\nWaiting for pod ${APPS_NS}:$POD to initialize"

    while true;
    do
        pod_information=$(kubectl get pods -n ${APPS_NS} | grep $POD | grep -v -e Completed -e Terminating -e ContainerCreating -e Init -e Pending)
        pod_state=$(echo $pod_information | awk '{print $'$STATE_COLUMN'}')

        if [ "$pod_state" != "" ] ; then
            if [ "$pod_state" == "Running" ] ; then
                pod_status=$(echo $pod_information | awk '{print $'$READY_COLUMN'}')
                ready_replicas=${pod_status%/*}
                all_replicas=${pod_status#*/}

                if [ $ready_replicas == $all_replicas ] ; then
                    return
                fi
            else
                pod_name=$(echo $pod_information | awk '{print $'$NAME_COLUMN'}')
                echo -e "\nError: Cannot start the pod. Pod $pod_name state: $pod_state\n"
                exit 1
            fi
        fi

        sleep 2
        echo -n "."
    done
}

function waitForFinishedJob () {
    JOB=$1
    WAITING_TIME=300
    SLEEPING_TIME=2
    echo -ne "\nWaiting for job ${APPS_NS}:$JOB to initialize...\n"

    while (( "$WAITING_TIME" > 0 ))
    do
        if isJobFinished $JOB; then
            return
        else
            WAITING_TIME=$(( $WAITING_TIME - $SLEEPING_TIME ))
            sleep $SLEEPING_TIME
            echo -n "."
        fi
    done

    echo -e "\nError: Cannot finish job\n"
    exit 1
}

function waitForFinishedJobOrError () {

    JOB=$1
    WAITING_TIME=${2:-300}
    SLEEPING_TIME=2
    echo -ne "\nWaiting for job ${APPS_NS}:$JOB to initialize...\n"

    while (( "$WAITING_TIME" > 0 ))
    do
        if isJobFinished $JOB; then
            return $JOB_SUCCEEDED
        elif isJobError $JOB; then
            return $JOB_FAILED
        else
            WAITING_TIME=$(( $WAITING_TIME - $SLEEPING_TIME ))
            sleep $SLEEPING_TIME
            echo -n "."
        fi
    done

    echo -e "\nError: Cannot finish job\n"
    exit 1
}

function executeCommandInPod () {
    DEPLOYMENT_NAME=$1
    COMMAND=$2
    POD_NAME=$(kubectl get pods -n ${APPS_NS} | grep $DEPLOYMENT_NAME | awk '{print $1}')
    echo $(kubectl exec -n ${APPS_NS} -it $POD_NAME -- bash -c "$COMMAND")
}

function delete_charts () {
    charts=${@}
    for chart in $charts; do
        echo "Removing $chart"
        helm delete $chart --purge
    done
}

function cluster_ips () {
    context=`kubectl config current-context`
    if [ ${context} == ${MINIKUBE_CONTEXT} ] ; then
        minikube ip
    else
        local res=($(kubectl config view -o jsonpath='{range .clusters[*]}{.cluster.server}{"\n"}{end}' | grep -o -P '(?<=://).*(?=:)'))
        local ips="${res[@]}"
        echo "${ips// /,}"
    fi
}

function first_ready_node () {
    kubectl get nodes -o jsonpath='{range.items[*]}{@.metadata.name}:Ready={@.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep 'Ready=True' | sed -n '1s/:.*//p'
}

function get_node_names () {
    LABEL=${1}
    kubectl get nodes -l "${LABEL}" -o jsonpath='{.items[*].metadata.name}'
}

function get_ips () {
    LABEL=${1}
    context=`kubectl config current-context`
    if [ ${context} == ${MINIKUBE_CONTEXT} ] ; then
        minikube ip
    else
        kubectl get nodes -l "${LABEL}" -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'
    fi
}

function list_namespaces () {
    kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'
}

function waitForCmd () {
    RETRY=100
    if [ ${1} == "--max-retries" ]; then RETRY=${2}; shift 2; fi
    $@
    while [ $? -ne 0 ] && [ ${RETRY} -gt 0 ]
    do
        ((RETRY--))
        sleep 2
        $@
    done
}

function getK8sComponentKind () {
    COMPONENT_NAME=$1

    kind=$(kubectl get $(kubectl get deployments,statefulset,daemonset -n ${APPS_NS} 2>/dev/null | grep ${COMPONENT_NAME} \
            | awk 'NR==1{print $1}') -n ${APPS_NS} -o jsonpath='{.kind}')
    echo ${kind}
}

function isDaemonSetReady () {
    DAEMONSET=$1
    DESIRED_NUMBER_SCHEDULED=$(kubectl get daemonset $DAEMONSET -n ${APPS_NS} -o jsonpath='{.status.desiredNumberScheduled}')
    NUMBER_READY=$(kubectl get daemonset $DAEMONSET -n ${APPS_NS} -o jsonpath='{.status.numberReady}')
    [ $DESIRED_NUMBER_SCHEDULED -eq $NUMBER_READY ]
    echo $?
}

function isStatefulSetReady () {
    STATEFULSET=$1
    replicas=$(kubectl get statefulset $STATEFULSET -n ${APPS_NS} -o jsonpath='{.status.replicas}')
    [ -z $replicas ] && replicas=0
    ready_replicas=$(kubectl get statefulset $STATEFULSET -n ${APPS_NS} -o jsonpath='{.status.readyReplicas}')
    [ -z $ready_replicas ] && ready_replicas=0
    [ $ready_replicas -eq $replicas ]
    echo $?
}

function isPodHasMatchingImageOrTag () {
    KIND=$1
    COMPONENT=$2
    POD=$3
    EXPECTED_IMAGE_OR_TAG=$4

    pod_images=$(kubectl get pod $POD -n ${APPS_NS} -o jsonpath='{.spec.containers[*].image}')

    [ "${EXPECTED_IMAGE_OR_TAG}" = "${EXPECTED_IMAGE_OR_TAG##*:}" ]
    tag_only=$?

    for image in ${pod_images}; do
      image=${image#*/}
      [ $tag_only = 0 ] && image=${image##*:}
      if [ ${EXPECTED_IMAGE_OR_TAG} = ${image} ] ; then
        echo 0
        return
      fi
      debug "${EXPECTED_IMAGE_OR_TAG} != ${image}"
    done
    log "Could not find container for: ${EXPECTED_IMAGE_OR_TAG}"

    echo 1
}

function isDeploymentReady () {
    COMPONENT_NAME=$1
    ready_replicas=$(kubectl get deployments $COMPONENT_NAME -n ${APPS_NS} -o jsonpath='{.status.readyReplicas}')
    [ -z $ready_replicas ] && ready_replicas=0
    replicas=$(kubectl get deployments $COMPONENT_NAME -n ${APPS_NS} -o jsonpath='{.status.replicas}')
    [ -z $replicas ] && replicas=0
    [ $ready_replicas -eq $replicas ]
    echo $?
}

function waitForReadyDeployment () {
    COMPONENT_NAME=$1
    echo -ne "\nWaiting for $COMPONENT_NAME to initialize"
    while [ $(isDeploymentReady $COMPONENT_NAME) != 0 ]
    do
        sleep 2
        echo -n "."
    done
}

function waitForReadyDaemonSet () {
    DAEMONSET=$1
    echo -ne "\nWaiting for $DAEMONSET to initialize"
    while [ $(isDaemonSetReady $DAEMONSET) != 0 ]
    do
        sleep 2
        echo -n "."
    done
}

function isPodTerminating() {
    POD_NAME=$1
    POD_STATUS=$(kubectl describe pod ${POD_NAME} -n ${APPS_NS} | grep 'Status:' | awk '{print $2}')
    [ $POD_STATUS == "Terminating" ]
    echo $?
}

function waitForReadyStatefulSet () {
    STATEFULSET=$1
    IMAGE_OR_TAG=$2
    KIND='StatefulSet'
    PODS=$(kubectl get pods -l statefulset.kubernetes.io/pod-name -n ${APPS_NS} | grep ${STATEFULSET} | awk '{print $1}')
    echo -ne "\nWaiting for $STATEFULSET to initialize"
    for POD in $PODS
    do
      while [ $(isStatefulSetReady $STATEFULSET) != 0 ] \
            || [ $(isPodHasMatchingImageOrTag $KIND $STATEFULSET $POD $IMAGE_OR_TAG) != 0 ] \
            || [ $(isPodTerminating $POD) == 0 ]
      do
          sleep 2
          echo -n "."
      done
    done
}

function restartStatefulSet () {
    STATEFULSET=$1
    ORIGINAL_REPLICA_COUNT=$(getStatefulSetExpectedReplicas ${STATEFULSET})

    echo "Scaling ${STATEFULSET} statefulset to 0 replicas"
    scaleComponent ${STATEFULSET} 0
    waitForStatefulSetCurrentReplicas ${STATEFULSET} 0
    echo "Scaling ${STATEFULSET} statefulset to ${ORIGINAL_REPLICA_COUNT} replicas"
    scaleComponent ${STATEFULSET} ${ORIGINAL_REPLICA_COUNT}
    waitForStatefulSetReplicas ${STATEFULSET} ${ORIGINAL_REPLICA_COUNT}
}

function scaleComponent () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    KIND=$(getK8sComponentKind ${COMPONENT_NAME})
    REAL_NAME=$(kubectl get ${KIND} -n ${APPS_NS} | grep ${COMPONENT_NAME} | awk '{print $1}')

    kubectl -n ${APPS_NS} scale --replicas=${REPLICAS} ${KIND}/${REAL_NAME}
}

function getDeploymentReadyReplicas () {
    COMPONENT_NAME=$1

    READY_REPLICAS=$(kubectl get deployments ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.status.readyReplicas}')
    [ -z $READY_REPLICAS ] && READY_REPLICAS=0
    echo "$READY_REPLICAS"
}

function getDaemonSetReadyReplicas () {
    COMPONENT_NAME=$1

    READY_REPLICAS=$(kubectl get daemonsets ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.status.numberReady}')
    [ -z $READY_REPLICAS ] && READY_REPLICAS=0
    echo "$READY_REPLICAS"
}

function getStatefulsetReadyReplicas () {
    COMPONENT_NAME=$1

    READY_REPLICAS=$(kubectl get statefulsets ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.status.readyReplicas}')
    [ -z $READY_REPLICAS ] && READY_REPLICAS=0
    echo "$READY_REPLICAS"
}

function getDeploymentExpectedReplicas () {
    COMPONENT_NAME=$1

    REPLICAS=$(kubectl get deployments ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.spec.replicas}')
    echo ${REPLICAS}
}

function getDaemonSetExpectedReplicas () {
    COMPONENT_NAME=$1

    REPLICAS=$(kubectl get daemonsets ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.status.desiredNumberScheduled}')
    echo ${REPLICAS}
}

function getStatefulSetExpectedReplicas () {
    COMPONENT_NAME=$1

    REPLICAS=$(kubectl get statefulsets ${COMPONENT_NAME} -n ${APPS_NS} -o jsonpath='{.spec.replicas}')
    echo ${REPLICAS}
}

function getStatefulSetCurrentReplicas () {
    COMPONENT_NAME=$1

    # Using the StatefulSet's '.status.currentReplicas' is unreliable, so this counts the number of pods instead
    CURRENT_POD_COUNT=$(kubectl get pod -n ${APPS_NS} -o name | grep -c -P "pod/${COMPONENT_NAME}-\d+")
    echo ${CURRENT_POD_COUNT}
}

function waitForDeploymentReplicas () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    echo "Waiting for ${COMPONENT_NAME} deployment replicas count: ${REPLICAS}"
    while [ $(getDeploymentReadyReplicas ${COMPONENT_NAME} ) -ne "${REPLICAS}" ]
    do
        sleep 2
        echo -n "."
    done
}

function waitForDaemonSetReplicas () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    echo "Waiting for ${COMPONENT_NAME} daemonset replicas count: ${REPLICAS}"
    while [ $(getDaemonSetReadyReplicas ${COMPONENT_NAME} ) -ne "${REPLICAS}" ]
    do
        sleep 2
        echo -n "."
    done
}

function waitForStatefulSetReplicas () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    echo "Waiting for ${COMPONENT_NAME} statefulset replicas count: ${REPLICAS}"
    while [ $(getStatefulsetReadyReplicas ${COMPONENT_NAME}) -ne "${REPLICAS}" ]
    do
        sleep 2
        echo -n "."
    done
}

function waitForReplicas () {
  COMPONENT_NAME=$1
  REPLICAS=$2

  KIND=$(getK8sComponentKind ${COMPONENT_NAME})
  REAL_NAME=$(kubectl get ${KIND} -n ${APPS_NS} | grep ${COMPONENT_NAME} | awk '{print $1}')

  case $KIND in
    'Deployment') waitForDeploymentReplicas $REAL_NAME $REPLICAS ;;
    'DaemonSet') waitForDaemonSetReplicas $REAL_NAME $REPLICAS ;;
    'StatefulSet') waitForStatefulSetReplicas $REAL_NAME $REPLICAS ;;
  esac
}

function waitForStatefulSetCurrentReplicas () {
    COMPONENT_NAME=$1
    REPLICAS=$2

    echo "Waiting for ${COMPONENT_NAME} statefulset current pod count: ${REPLICAS}"
    while [ $(getStatefulSetCurrentReplicas ${COMPONENT_NAME}) -ne "${REPLICAS}" ]
    do
        sleep 2
        echo -n "."
    done
}

function getComponentExpectedReplicas () {
  COMPONENT_NAME=$1
  REPLICAS=0

  KIND=$(getK8sComponentKind ${COMPONENT_NAME})
  REAL_NAME=$(kubectl get ${KIND} -n ${APPS_NS} | grep ${COMPONENT_NAME} | awk '{print $1}')
  case $KIND in
    'Deployment') REPLICAS=$(getDeploymentExpectedReplicas $REAL_NAME) ;;
    'DaemonSet') REPLICAS=$(getDaemonSetExpectedReplicas $REAL_NAME) ;;
    'StatefulSet') REPLICAS=$(getStatefulSetExpectedReplicas $REAL_NAME ) ;;
  esac

  echo ${REPLICAS}
}

function label_node() {
    NODE_NAME=$1
    LABELS=${@:2}

    echo "Setting labels: \"${LABELS}\" on \"${NODE_NAME}\" node."
    kubectl label nodes ${NODE_NAME} ${LABELS} --overwrite
}

function wait_for_node_with_name() {
    NODE_NAME=$1

    echo "Waiting for node \"${NODE_NAME}\" available."
    while [ "$(find_node_by_name ${NODE_NAME})" != "${NODE_NAME}" ];
    do
        sleep 2
    done
    echo "Node \"${NODE_NAME}\" is available."
}

function find_node_by_name() {
    NODE_NAME=$1

    kubectl get nodes | grep ${NODE_NAME} | awk '{print $1}'
}

function waitForCrds() {
    CRDS_NAMES=${@}

    for CRDS in ${CRDS_NAMES}; do
        echo "Waiting for crds \"${CRDS}\"."
        while [ "$(findCrds ${CRDS})" != "${CRDS}" ];
        do
            sleep 2
        done
        echo "Crds \"${CRDS}\" is available."
    done
}

function findCrds() {
    CRDS_NAME=$1

    kubectl get customresourcedefinition | grep -w ${CRDS_NAME} | awk '{print $1}'
}
