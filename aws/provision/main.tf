provider "aws" {
  profile = module.defaults.profile
  region  = module.defaults.region
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
}

module "security" {
  source = "./modules/security"

  aws_vpc                 = module.defaults.aws_vpc
  ec2_ssh_public_key_path = "./access/aws_instance_key.pub"
}

#module "network" {
#  source             = "./modules/network"
#  aws_security_group = module.security.aws_security_group
#  aws_subnet         = module.defaults.aws_subnet
#  private_ips_count  = sum([length(local.node_names), 2])
#}

module "ec2_nodes" {
  source   = "./modules/ec2"
  for_each = local.node_names

  ec2_name = each.key

  ec2_availability_zone = module.defaults.availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair
  #  aws_network_interface = module.network.aws_network_interface

}

module "ec2_client" {
  source = "./modules/ec2"

  ec2_name = local.client_name

  ec2_availability_zone = module.defaults.availability_zone

  aws_subnet         = module.defaults.aws_subnet
  aws_security_group = module.security.aws_security_group
  aws_key_pair       = module.security.aws_key_pair
  #  aws_network_interface = module.network.aws_network_interface
}

output "nodes" {
  depends_on = [module.ec2_nodes]
  value      = module.ec2_nodes
}

output "client" {
  depends_on = [module.ec2_client]
  value      = module.ec2_client
}
