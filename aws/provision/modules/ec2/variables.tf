variable "ec2_count" {
  description = "Should the EC2 be created?"
  type        = number
  default     = 1
}

variable "ec2_name" {
  description = "The Name of the EC2"
  type        = string
  default     = "consensus-node"
}

variable "ec2_security_group_name" {
  description = "The Name of the EC2 Security Group"
  type        = string
  default     = "consensus-security-group"
}

variable "ec2_security_group_description" {
  description = "The Description of the EC2 Security Group"
  type        = string
  default     = "consensus security group"
}

variable "ec2_ami" {
  description = "The Amazon Machine Image"
  type        = string
  default     = "ami-0d0b1b94413024658" # Ubuntu based full dependencies ami created by packer (see ./aws/ami).
}

variable "ec2_instance_type" {
  description = "The EC2 Instance type"
  type        = string
  default     = "t2.micro" # Free Tier eligible
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the Public Subnet"
  type        = string
}

variable "ec2_ssh_key_name" {
  description = "The SSH Key Name"
  type        = string
  default     = "ec2_instance_key"
}

variable "ec2_ssh_public_key_path" {
  description = "The local path to the SSH Public Key"
  type        = string
}
