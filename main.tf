terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "cv_public" {
  name        = "cv-public"
  description = "Security group for CV public access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Public CV access"
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cv-public"
  }
}

resource "aws_instance" "cv_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.small"

  subnet_id = data.aws_subnets.default.ids[0]

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.cv_public.id
  ]

  user_data = <<-EOF
    #!/bin/bash

    dnf update -y
    dnf install -y docker git

    systemctl enable --now docker

    usermod -aG docker ec2-user

    mkdir -p /usr/libexec/docker/cli-plugins

    curl -SL https://github.com/docker/compose/releases/download/v2.39.4/docker-compose-linux-x86_64 \
      -o /usr/libexec/docker/cli-plugins/docker-compose

    chmod +x /usr/libexec/docker/cli-plugins/docker-compose

    mkdir -p /opt/cv-platform
    cd /opt

    git clone https://github.com/ZubiOps/cv-platform.git

    cd /opt/cv-platform

    docker compose up -d
  EOF

  tags = {
    Name = "cv-server"
  }
}

output "cv_public_ip" {
  value = aws_instance.cv_server.public_ip
}

output "cv_url" {
  value = "http://${aws_instance.cv_server.public_ip}:8090"
}
