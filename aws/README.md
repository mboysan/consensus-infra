# About

This folder shall be used to provision and orchestrate the performance tests for the consensus project in
Amazon Web Services (aws).

## Prerequisites

- Make sure you have an [AWS](https://aws.amazon.com/) account and configured according to amazon's best practices and 
recommendations. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- Install [aws cli](https://aws.amazon.com/cli/).

## Preparing AWS credentials

Almost all the tools used in this folder group needs to be configured properly with aws credentials to be able to
make the required api calls to amazon. There are many ways of configuring the credentials and adopting the configuration
of the tools to the method you choose. However, we prefer using the following method:
1. Create a file called `credentials` under home dir `~/.aws/`.
2. Edit the file using the following template:
```
[default]
region=eu-west-1
aws_access_key_id=<your_aws_access_key>
aws_secret_access_key=<your_aws_secret_key>
```

## Guide

1. For provisioning the infrastructure, follow the guide at [provision](./provision) folder.
2. For orchestrating the ec2 instances and running the performance tests use the [orchestrate](./orchestrate) folder.