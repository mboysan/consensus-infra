variable "aws_region" {}
variable "aws_availability_zone" {}
variable "aws_ec2_ami_name" {}

source "amazon-ebs" "ami" {
  region            = var.aws_region
  availability_zone = var.aws_availability_zone
  instance_type     = "t2.micro"
  source_ami        = "ami-08ca3fed11864d6bb" # Ubuntu-20.04
  ami_name          = var.aws_ec2_ami_name
  ssh_username      = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ami"]
  provisioner "shell" {
    script = "ami-bootstrap.sh"
  }
}
