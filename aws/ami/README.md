# About

This module shall be used to create an Amazon Machine Image (AMI) to be used as the base for the ec2 instances.

## Prerequisites
- Read the [readme](../README.md) at the parent dir.
- Install [packer](https://www.packer.io/).

Note: all the commands listed in the following sections shall be executed in this directory (working directory).

## Creating your AMI on AWS

View and configure the [packer configuration file](./packer.pkr.hcl) for your needs.

Creating and publishing the ami is as simple as running:
```
packer build packer.pkr.hcl
```
This will create an ami with all the dependencies installed with the [`ami-bootstrap.sh`](ami-bootstrap.sh) script.

### Verifying
To verify:
1. Navigate to your aws account -> EC2.
2. Create a new instance and inspect the ami created with name: **ami-full-deps**
