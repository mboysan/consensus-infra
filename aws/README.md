# About

This folder shall be used to provision and orchestrate the performance tests for the consensus project in
Amazon Web Services (aws).

## Prerequisites

- Make sure you have an [AWS](https://aws.amazon.com/) account and configured according to amazon's best practices and 
recommendations. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- Install [aws cli](https://aws.amazon.com/cli/).

## Preparing AWS credentials

Almost all the tools used in this folder group needs to be configured properly with aws credentials to be able to
make the required api calls to amazon web services. There are many ways of configuring the credentials and adopting 
the configuration of the tools to the method you choose. However, we prefer using the following method:
1. An environment configuration script is provided in [env_setup.sh.example](env_setup.sh.example).
2. Rename it and make it executable
```
mv env_setup.sh.example env_setup.sh
chmod +x env_setup.sh
```
3. Finally, source it
```
source env_setup.sh
```

## Guide
After preparing your aws credentials appropriately, you can check out the guides:
1. For provisioning the infrastructure, follow the guide at [provision](./provision) folder.
2. For orchestrating the ec2 instances and running the performance tests use the [orchestrate](./orchestrate) folder.