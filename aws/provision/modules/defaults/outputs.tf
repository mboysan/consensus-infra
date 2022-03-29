output "profile" {
  value = var.profile
}

output "region" {
  value = var.region
}

output "availability_zone" {
  value = var.availability_zone
}

output "aws_vpc" {
  value = data.aws_vpc.default
}

output "aws_subnet" {
  value = data.aws_subnet.default_az1
}
