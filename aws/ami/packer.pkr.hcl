source "amazon-ebs" "ami" {
  region            = "eu-west-1"
  availability_zone = "eu-west-1c"
  instance_type     = "t2.micro"
  source_ami        = "ami-08ca3fed11864d6bb" # Ubuntu-20.04
  ami_name          = "ami-full-deps"
  ssh_username      = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ami"]

  provisioner "shell" {
    script = "ami-bootstrap.sh"
  }

}
