################
## providers.tf
################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

################
## main.tf
################

resource "aws_security_group" "openssh" {
  name        = "${var.developer}-openssh-sg"
  description = "Security group for ${var.developer} server"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # run: curl ifconfig.me
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # public — needed since you're installing nginx
  }

  ingress {
    description = "SonarQube access"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # public — needed since you're installing nginx
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # needed for apt update/install to reach internet
  }

  tags = {
    Name = "${var.developer}-sonarqube-sg"
  }
}

resource "aws_instance" "servers" {
  for_each               = var.server_names
  ami                    = var.ami_id
  vpc_security_group_ids = [aws_security_group.openssh.id]
  key_name               = var.key_pair_name
  instance_type          = var.machine_size
  #user_data              = file("../scripts/ec2-userdata.sh")
  tags = {
    Name = "${var.developer}-${each.key}"
  }
}


################
## variable.tf
################
variable "aws_region" { default = "us-east-1" }
variable "ami_id" { default = "ami-091138d0f0d41ff90" } # Amazone Linux 2023 us-east-1
variable "machine_size" { default = "t3.medium" }
variable "key_pair_name" { default = "multi-env-key" }
variable "developer" { default = "myName" }
variable "server_names" {
  type    = set(string)
  default = ["ec2-sonarQube"]
}
