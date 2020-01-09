#!/bin/bash

echo 'Please enter the username for the openstack CI user'
read username

echo 'Please enter the password for the openstack CI user'
read password

echo 'Please enter the s3accesskey'
read s3accesskey

echo 'Please enter the s3secretkey'
read s3secretkey

echo 'Please enter the s3regionendpoint'
read s3regionendpoint

echo 'Please enter the s3bucketname'
read s3bucketname

openshiftadminuser="admin"
openshiftdemouser="demo"

echo "Please enter the 'admin' user's password"
read openshiftadminpass

echo "Please enter the 'demo' user's password"
read openshiftdemopass

echo "Please enter the Openshift domain suffix"
read domainsuffix

echo "Please enter the UUID of the Data Plane Floating IP Address"
read dataplane_floating_ip

echo "Please enter the UUID of the Control Plane Floating IP Address"
read controlplane_floating_ip

echo 'Please enter the Red Hat Registration Org'
read rhorg

echo 'Please enter the Red Hat Registration activation key'
read rhactivationkey

echo 'Please enter the address of the satellite server to install from'
read satelliteaddress

echo 'Deploy from Satellite? True/False'
read usesatellite

echo 'Version of OpenShift to deploy'
read ocp_version

echo 'Deploy with multiple networks? True/False'
read multinetwork

echo 'Deploy extra gateway? (VRF for example) True/False'
read deploy_extra_gateway

echo 'Please enter the local domain suffix'
read localdomainsuffix

echo 'Please enter the quantity of small workers required'
read worker_small_scale

echo 'Please enter the quantity of medium workers required'
read worker_medium_scale

echo 'Please enter the quantity of large workers required'
read worker_large_scale

echo 'Please enter the quantity of infrastructure workers required'
read infra_scale

echo 'Please enter the quantity of net2 small workers required'
read net2_small_scale

echo 'Please enter the quantity of net2 medium workers required'
read net2_medium_scale

echo 'Please enter the quantity of net2 large workers required'
read net2_large_scale

echo 'Please enter net2 DNS server IPs in array format'
read net2_dns_server

echo 'Please enter external network for net2'
read net2_external_network

echo 'Please enter net2 internal gateway IP'
read net2_gateway_internal_ip

echo 'Please enter net2 NTP server IP addresses in array format'
read net2_ntp_servers

echo 'Please enter neustar password'
read neustar_ultradns_password

echo 'Please enter slack webhook for acme script'
read slack_webhook_url_acme_sh

echo 'Please provide the Red Hat registry URL'
read registry_url

echo 'Please provide the Red Hat registry user'
read registry_user

echo 'Please provide the Red Hat registry users password'
read registry_password

echo 'Please provide the openshift-deployment-ansible branch you would like to pull (e.g. v3.11)'
read ansible_branch

echo 'Please provide the ansible vault password to decrypt deploy key'
read ansible_vault_password

echo 'Please provide the auth URL for the openstack environment (v3)'
read OPENSTACK_AUTH_URL

echo 'Please provide the project ID for the openstack environment'
read OPENSTACK_PROJECT_ID

echo 'Please provide the name of the project for the openstack environment'
read OPENSTACK_PROJECT_NAME

NAME='openshift-build-pipeline'
SOURCE_REPOSITORY_URL='https://github.com/UKCloud/openshift-deployment-jenkins-pipeline.git'
SOURCE_REPOSITORY_REF='master'
CONTEXT_DIR='jenkins-pipelines/openshift'

function setup_openshift_deployment_jenkins_pipeline() {

    oc new-app -f openshift-yaml/template-openshift-build.yaml \
        -p NAME=$NAME \
        -p SOURCE_REPOSITORY_URL=$SOURCE_REPOSITORY_URL \
        -p SOURCE_REPOSITORY_REF=$SOURCE_REPOSITORY_REF \
        -p CONTEXT_DIR=$CONTEXT_DIR \
        -p OPENSTACK_AUTH_URL=$OPENSTACK_AUTH_URL \
        -p OPENSTACK_PROJECT_ID=$OPENSTACK_PROJECT_ID \
        -p OPENSTACK_PROJECT_NAME=$OPENSTACK_PROJECT_NAME
}

function setup_openstack_variables() {
    oc create secret generic openstack \
        --from-literal=username=$username \
        --from-literal=password=$password

    oc create secret generic rhelsubscriptions \
        --from-literal=rhel_org=$rhorg \
        --from-literal=rhel_activation_key=$rhactivationkey \
        --from-literal=satellite_fqdn=$satelliteaddress \
        --from-literal=satellite_deploy=$usesatellite

    oc create secret generic s3parameters \
        --from-literal=s3accesskey=$s3accesskey \
        --from-literal=s3secretkey=$s3secretkey \
        --from-literal=s3regionendpoint=$s3regionendpoint \
        --from-literal=s3bucketname=$s3bucketname

    # Admin is adminuser/adminpass. 'demo' is username/userpass
    oc create secret generic openshift \
        --from-literal=adminuser=$openshiftadminuser \
        --from-literal=username=$openshiftdemouser \
        --from-literal=adminpass=$openshiftadminpass \
        --from-literal=userpass=$openshiftdemopass \
        --from-literal=domainsuffix=$domainsuffix \
        --from-literal=localdomainsuffix=$localdomainsuffix \
        --from-literal=data_plane_ip=$dataplane_floating_ip \
        --from-literal=control_plane_ip=$controlplane_floating_ip \
        --from-literal=openshift_version=$ocp_version \
        --from-literal=multinetwork=$multinetwork \
        --from-literal=deploy_extra_gateway=$deploy_extra_gateway \
        --from-literal=worker_small_scale=$worker_small_scale \
        --from-literal=worker_medium_scale=$worker_medium_scale \
        --from-literal=worker_large_scale=$worker_large_scale \
        --from-literal=infra_scale=$infra_scale \
        --from-literal=net2_worker_small_scale=$net2_small_scale \
        --from-literal=net2_worker_medium_scale=$net2_medium_scale \
        --from-literal=net2_worker_large_scale=$net2_large_scale \
        --from-literal=net2_dns_server=$net2_dns_server \
        --from-literal=net2_external_network=$net2_external_network \
        --from-literal=net2_gateway_internal_ip=$net2_gateway_internal_ip \
        --from-literal=net2_ntp_servers=$net2_ntp_servers \
        --from-literal=neustar_ultradns_password=$neustar_ultradns_password \
        --from-literal=slack_webhook_url_acme_sh=$slack_webhook_url_acme_sh \
        --from-literal=registry_url=$registry_url \
        --from-literal=registry_user=$registry_user \
        --from-literal=registry_password=$registry_password \
        --from-literal=ansible_branch=$ansible_branch \
        --from-literal=ansible_vault_password=$ansible_vault_password

}

function configure_openshift_githooks() {
    # TODO: Automate webhook creation and updates via the github API
    gitHook=$(oc describe bc ${NAME} | grep -A1 'Webhook GitHub' | grep URL | awk '{print $NF}')
    echo "Add a github webhook for the following URL to trigger automated builds of the Jenkins pipeline, $gitHook"
}

setup_openshift_deployment_jenkins_pipeline
setup_openstack_variables
configure_openshift_githooks
