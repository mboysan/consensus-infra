output "profile" {
  value = var.profile
}

output "region" {
  value = var.region
}

output "az" {
  value = var.az
}

output "vpc" {
  value = data.aws_vpc.default
}

output "public_subnet" {
  value = data.aws_subnet.default_az1
}