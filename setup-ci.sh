#!/bin/bash

echo 'Please enter the password for the openstack CI user (openshift@ukcloud.com)'
read password

NAME='openshift-build-pipeline'
SOURCE_REPOSITORY_URL='https://github.com/UKCloud/openshift-deployment-jenkins-pipeline.git'
SOURCE_REPOSITORY_REF='master'
CONTEXT_DIR='jenkins-pipelines/openshift'


function setup_openshift_deployment_jenkins_pipeline() {

    oc new-app -f openshift-yaml/template-openshift-build.yaml \
        -p NAME=$NAME \
        -p SOURCE_REPOSITORY_URL=$SOURCE_REPOSITORY_URL \
        -p SOURCE_REPOSITORY_REF=$SOURCE_REPOSITORY_REF \
        -p CONTEXT_DIR=$CONTEXT_DIR
}

function setup_openstack_variables() {
    oc create -f openshift-yaml/openstack_params.yaml
    oc create secret generic openstack --from-literal=username=openshift@ukcloud.com --from-literal=password=$password
    oc create secret generic rhelsubscriptions --from-literal=rhel_org=6468465 --from-literal=rhel_activation_key=openshift
}

function configure_openshift_githooks() {
    # TODO: Automate webhook creation and updates via the github API
    gitHook=$(oc describe bc ${NAME} | grep -A1 'Webhook GitHub' | grep URL | awk '{print $NF}')
    echo "Add a github webhook for the following URL to trigger automated builds of the Jenkins pipeline, $gitHook"
}

setup_openshift_deployment_jenkins_pipeline
setup_openstack_variables
configure_openshift_githooks
