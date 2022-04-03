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

variable "ec2_group" {
  description = "The Group that the EC2 instance belongs to"
  type        = string
  default     = "my-ec2-group"
}

variable "ec2_ami_name" {
  description = "The Amazon Machine Image"
  type        = string
}

variable "ec2_instance_type" {
  description = "The EC2 Instance type"
  type        = string
  default     = "t2.micro" # Free Tier eligible
}

variable "aws_availability_zone" {
  description = "AWS Availability Zone"
  type        = string
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
