variable "aws_vpc" {
  description = "The object reference of the aws_vpc resource"
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

variable "ec2_ssh_key_name" {
  description = "The SSH Key Name"
  type        = string
  default     = "ec2_instance_key"
}

variable "ec2_ssh_public_key_path" {
  description = "The local path to the SSH Public Key"
  type        = string
}

variable "aws_security_group_ingress" {
  type = object({
    start_port = number
    end_port = number
  })
}
