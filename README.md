## Setup steps

1. Setup this pipelines slave using the instructions from the [jenkins-openstack-slave-pipeline](https://github.com/UKCloud/jenkins-openstack-slave-pipeline) repo

2. Run `./setup-ci.sh` found in this repo

3. Setup the [`openshift-test-pipeline`](github.com/ukcloud/openshift-test-pipeline) using the command `python run.py setup_pipeline --project=build-openshift`
