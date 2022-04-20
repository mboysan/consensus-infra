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

variable "aws_ec2_ami_id" {
  description = "The Amazon Machine Image (AMI) ID"
  type        = string
}

variable "reserved_port_start" {
  description = "Start index of the reserved port (used for ec2 security group ingress rules)"
  type        = number
}

variable "reserved_port_end" {
  description = "End index of the reserved port (used for ec2 security group ingress rules)"
  type        = number
}

variable "aws_ec2_ssh_public_key_path" {
  description = "Public key file for ssh access to ec2 instances"
  type        = string
}

# --- Rest of the setup
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

locals {
  node_names = tomap({
    "0" = "node0",
    "1" = "node1",
    #    "2" = "node2",
    #    "3" = "node3",
    #    "4" = "node4",
  })
}

module "defaults" {
  source                = "./modules/defaults"
  aws_availability_zone = var.aws_availability_zone
}

module "security" {
  source = "./modules/security"

  aws_vpc                    = module.defaults.aws_vpc
  aws_security_group_ingress = {
    start_port = var.reserved_port_start
    end_port   = var.reserved_port_end
  }
  ec2_ssh_public_key_path = var.aws_ec2_ssh_public_key_path
}

module "ec2_nodes" {
  source   = "./modules/ec2"
  for_each = local.node_names

  aws_availability_zone = var.aws_availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair

  ec2_ami_id = var.aws_ec2_ami_id

  ec2_tags = {
    Index = each.key
    Name  = each.value
    Group = "nodes"
  }
}

module "ec2_client" {
  source = "./modules/ec2"

  aws_availability_zone = var.aws_availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair

  ec2_ami_id = var.aws_ec2_ami_id

  ec2_tags = {
    Index = "0"
    Name  = "client"
    Group = "clients"
  }
}

module "ec2_collector" {
  source = "./modules/ec2"

  aws_availability_zone = var.aws_availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair

  ec2_ami_id = var.aws_ec2_ami_id

  ec2_tags = {
    Index = "0"
    Name  = "collector"
    Group = "collectors"
  }
}

output "nodes" {
  depends_on = [module.ec2_nodes]
  value      = module.ec2_nodes
}

output "client" {
  depends_on = [module.ec2_client]
  value      = module.ec2_client
}

output "collector" {
  depends_on = [module.ec2_collector]
  value      = module.ec2_collector
}