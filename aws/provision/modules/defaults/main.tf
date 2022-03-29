data "aws_vpc" "default" {}

data "aws_subnet" "default_az1" {
  availability_zone = var.az
}
