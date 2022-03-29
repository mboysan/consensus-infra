resource "aws_instance" "ec2" {
  availability_zone = var.ec2_availability_zone
  count             = var.ec2_count

  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type

  subnet_id                   = var.aws_subnet.id
  vpc_security_group_ids      = [var.aws_security_group.id]
  associate_public_ip_address = true

  key_name = var.aws_key_pair.key_name

  tags = {
    Name  = var.ec2_name
    Group = var.ec2_group
  }
}
