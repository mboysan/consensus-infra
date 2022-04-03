output "aws_vpc" {
  value = data.aws_vpc.default
}

output "aws_subnet" {
  value = data.aws_subnet.default_az1
}
