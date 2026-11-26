locals {
  name = "ewg-${var.session_id}"
  common_tags = {
    Project   = "ephemeral-aws-wireguard"
    Owner     = "terraform"
    Purpose   = "ssh-only-mvp"
    SessionId = var.session_id
  }
}

# AWS-maintained public SSM parameter for the latest AL2023 ARM64 AMI.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

data "aws_ec2_instance_type_offerings" "bastion" {
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

resource "aws_vpc" "mvp" {
  cidr_block           = "10.252.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.mvp.id
  cidr_block = "10.252.1.0/24"
  # The subnet fixes the bastion's AZ, so choose a zone that offers its instance type.
  # Any eligible zone is acceptable for this disposable session; alphabetical order breaks the tie.
  availability_zone       = sort(data.aws_ec2_instance_type_offerings.bastion.locations)[0]
  map_public_ip_on_launch = false

  tags = { Name = "${local.name}-public-subnet" }
}

resource "aws_internet_gateway" "mvp" {
  vpc_id = aws_vpc.mvp.id
  tags   = { Name = "${local.name}-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mvp.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mvp.id
  }

  tags = { Name = "${local.name}-public-route" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ssh" {
  name_prefix = "${local.name}-ssh-"
  description = "MVP: operator SSH /32 only"
  vpc_id      = aws_vpc.mvp.id

  tags = { Name = "${local.name}-ssh" }
}

resource "aws_vpc_security_group_ingress_rule" "operator_ssh" {
  security_group_id = aws_security_group.ssh.id
  description       = "Single operator SSH source"
  cidr_ipv4         = var.operator_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Broad outbound access is intentional for initial OS updates. Reduce in a later hardening sprint.
resource "aws_vpc_security_group_egress_rule" "internet" {
  security_group_id = aws_security_group.ssh.id
  description       = "Outbound package repositories and future home WG endpoint"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_key_pair" "operator" {
  key_name_prefix = "${local.name}-operator-"
  public_key      = trimspace(var.operator_ssh_public_key)
  tags            = { Name = "${local.name}-operator-key" }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  key_name                    = aws_key_pair.operator.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  volume_tags = local.common_tags

  # Explicit route association avoids an instance briefly launching before
  # the public subnet's route exists.
  depends_on = [aws_route_table_association.public]

  tags = { Name = "${local.name}-bastion" }
}
