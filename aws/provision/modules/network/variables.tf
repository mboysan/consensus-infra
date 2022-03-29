variable "aws_subnet" {
  description = "The object reference of the aws_subnet resource"
}

variable "aws_security_group" {
  description = "The object reference of the aws_security_group resource"
}

variable "private_ips_count" {
  description = "Count of the private ips in nic, total private ips = 1 + (private_ips_count)"
  type        = number
}
