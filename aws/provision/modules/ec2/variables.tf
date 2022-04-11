variable "ec2_count" {
  description = "Should the EC2 be created?"
  type        = number
  default     = 1
}

variable "ec2_tags" {
  type = object({
    # The Name of the EC2 instance
    Name  = string

    # The Group that the EC2 instance belongs to
    Group = string

    # The Index of the ec2 instance in the group
    Index = string
  })
}

variable "ec2_ami_id" {
  description = "The Amazon Machine Image ID"
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
