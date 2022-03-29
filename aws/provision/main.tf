provider "aws" {
  profile = module.defaults.profile
  region  = module.defaults.region
}

locals {
  node_names = toset([
    "consensus-node-0",
    "consensus-node-1",
  ])
  client_name = "consensus-client"
}

module "defaults" {
  source = "./modules/defaults"
}

module "ec2" {
  source   = "./modules/ec2"
  for_each = local.node_names

  ec2_name                = each.key
  vpc_id                  = module.defaults.vpc.id
  public_subnet_id        = module.defaults.public_subnet.id
  ec2_ssh_public_key_path = "./access/aws_instance_key.pub"
}
