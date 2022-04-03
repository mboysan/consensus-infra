# --- Input variables
variable "aws_profile" {
  description = "AWS Profile"
  type        = string
}

variable "aws_region" {
  description = "Region for AWS resources"
  type        = string
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "aws_ec2_ami_name" {
  description = "The Amazon Machine Image (AMI)"
  type        = string
}

# --- Rest of the setup
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

locals {
  node_names = toset([
    "consensus-node-0",
    #    "consensus-node-1",
    #    "consensus-node-2",
    #    "consensus-node-3",
    #    "consensus-node-4",
  ])
  client_name = "consensus-client"
}

module "defaults" {
  source = "./modules/defaults"
  aws_availability_zone = var.aws_availability_zone
}

module "security" {
  source = "./modules/security"

  aws_vpc                 = module.defaults.aws_vpc
  ec2_ssh_public_key_path = "./access/aws_instance_key.pub"
}

module "ec2_nodes" {
  source   = "./modules/ec2"
  for_each = local.node_names

  aws_availability_zone = var.aws_availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair

  ec2_ami_name = var.aws_ec2_ami_name
  ec2_name  = each.key
  ec2_group = "nodes"
}

module "ec2_client" {
  source = "./modules/ec2"

  aws_availability_zone = var.aws_availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair

  ec2_ami_name = var.aws_ec2_ami_name
  ec2_name  = "consensus-client"
  ec2_group = "clients"
}

#output "nodes" {
#  depends_on = [module.ec2_nodes]
#  value      = module.ec2_nodes
#}
#
#output "client" {
#  depends_on = [module.ec2_client]
#  value      = module.ec2_client
#}
