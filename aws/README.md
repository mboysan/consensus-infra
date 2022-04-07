# About

This folder shall be used to provision and orchestrate the performance tests for the consensus project in
Amazon Web Services (aws).

## Prerequisites

- Make sure you have an [AWS](https://aws.amazon.com/) account and configured according to amazon's best practices and 
recommendations. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- Install [aws cli](https://aws.amazon.com/cli/).

## IAM Policy Information

Although, in theory you can create an aws user with unbounded permissions, we highly suggest you assign a policy with 
the least number of privileges required to run the aws api calls for the user. We have created an 
[example IAM policy](./iam_example_policy.json) for which you can use to run packer and terraform commands configured 
for this project.

## Preparing AWS credentials

Almost all the tools used in this folder group needs to be configured properly with aws credentials to be able to
make the required api calls to amazon web services. There are many ways of configuring the credentials and adopting 
the configuration of the tools to the method you choose.

We prefer creating a profile called `consensus` in the `~/.aws/credentials` file as follows:
```
[consensus]
region=eu-west-1
aws_access_key_id=<your aws access key id>
aws_secret_access_key==<your aws secret access key>
```

After setting this file, review [env_setup.sh.example](env_setup.sh.example) and execute the following:
```
mv env_setup.sh.example env_setup.sh
chmod +x env_setup.sh
source env_setup.sh
```

## Guide
After preparing your aws credentials appropriately, you can check out the guides:
1. For provisioning the infrastructure, follow the guide at [provision](./provision) folder.
2. For orchestrating the ec2 instances and running the performance tests use the [orchestrate](./orchestrate) folder.