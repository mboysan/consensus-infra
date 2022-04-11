# About

This module shall be used to provision the performance testing infrastructure (infra).

## Prerequisites
- Read the [readme](../README.md) at the parent dir.
- Install [terraform](https://www.terraform.io/).

This project configuration uses Amazon's default Ubuntu-20.04 Amazon Machine Image (AMI), i.e. `ami-08ca3fed11864d6bb`
as of today. 

For building your own AMI to use for the base of your ec2 instances, check out the [ami](./ami) folder. If you prefer
to do this, you need to update the `ami` parameter in [ec2/main.tf](./modules/ec2/main.tf) module.

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