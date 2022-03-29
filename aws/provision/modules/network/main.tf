resource "aws_network_interface" "nic" {
  subnet_id         = var.aws_subnet.id
  security_groups   = [var.aws_security_group.id]
  private_ips_count = var.private_ips_count
}