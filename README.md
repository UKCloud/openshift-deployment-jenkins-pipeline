To execute, run the following:
```
./setup-ci.sh
```

Within the jenkins file, the stage 'validate openshift deployment'  The environment variables set by the pipeline need to be overwritten. The kubernetes of the pipeline automatically override the target host, so therefore need to unset them so you can deploy pods within the correct environment.
