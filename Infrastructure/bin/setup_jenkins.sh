#!/bin/bash
# Setup Jenkins Project
if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
REPO=$2
CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student

oc new-app -f ../templates/template-jenkins.json -p MEMORY_LIMIT=2Gi --p VOLUME_CAPACITY=4Gi -n ${GUID}-jenkins

docker build ./Infrastructure/extraresources -t docker-registry-default.apps.${CLUSTER}/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.9
skopeo copy --dest-tls-verify=false --dest-creds=$(oc whoami):$(oc whoami -t) docker-daemon:docker-registry-default.apps.${CLUSTER}/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.9 docker://docker-registry-default.apps.${CLUSTER}/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.9

oc new-app -f ../templates/template-jenkinsmavenslave.json -p GUID=${GUID}


# Create build config pipelines
#oc process -f ../templates/template-mlbparks-pipeline.yaml --param REPO=${REPO} --param GUID=${GUID} --param CLUSTER=${CLUSTER} | oc create -f - -n ${GUID}-jenkins
#oc process -f ../templates/template-nationalparks-pipeline.yaml --param REPO=${REPO} --param GUID=${GUID} --param CLUSTER=${CLUSTER} | oc create -f - -n ${GUID}-jenkins
#oc process -f ../templates/template-parksmap-pipeline.yaml --param REPO=${REPO} --param GUID=${GUID} --param CLUSTER=${CLUSTER} | oc create -f - -n ${GUID}-jenkins


