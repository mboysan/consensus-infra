# About

This module shall be used to provision the performance testing infrastructure (infra).

## Prerequisites
- Read the [readme](../README.md) at the parent dir.
- Install [terraform](https://www.terraform.io/).

This project configuration uses a pre-built Amazon Machine Image (AMI). For building your own AMI to use for the base 
for your ec2 instances, check out the [ami](./ami) folder.

Note: all the commands listed in the following sections shall be executed in this directory (working directory).

## Provisioning the Infrastructure

Note that the terraform configuration ([main.tf](main.tf)) used here relies on the default VPC created in `eu-west-1` 
region with its default settings.

To plan the infra setup:
```
terraform plan
```

To apply changes:
```
terraform apply
```

To destroy the infra:
```
terraform destroy
```

### Verifying
To verify, navigate to your aws account and see all the resources created during the `terraform apply` command 
execution.