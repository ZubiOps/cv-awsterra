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

resource "aws_security_group" "cv_public" {
  name        = "cv-public"
  description = "Security group for CV public access"

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

resource "aws_network_interface_sg_attachment" "cv_public" {
  security_group_id    = aws_security_group.cv_public.id
  network_interface_id = "eni-0e4934146a3572030"
}
