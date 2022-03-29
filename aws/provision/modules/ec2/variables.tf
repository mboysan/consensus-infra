variable "ec2_availability_zone" {
  description = "Availability zone of the ec2 instance"
  type        = string
  default     = "eu-west-1c"
}

variable "ec2_count" {
  description = "Should the EC2 be created?"
  type        = number
  default     = 1
}

variable "ec2_name" {
  description = "The Name of the EC2"
  type        = string
  default     = "my-ec2-instance"
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

variable "aws_key_pair" {
  description = "The object reference of the aws_key_pair resource"
}

variable "aws_security_group" {
  description = "The object reference of the aws_security_group resource"
}

variable "aws_subnet" {
  description = "The object reference of the aws_subnet resource"
}

#variable "aws_network_interface" {
#  description = "The object reference of the aws_network_interface resource"
#}