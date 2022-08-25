terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "terraform-basics"

    workspaces {
      name = "getting-started"
    }
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}
provider "aws" {
  # version = "~> 2.0"
  region  = "us-east-1"
}

provider "aws" {
  # Configuration options
  profile = "default"
  region  = "us-east-1"
}

variable "instance_type" {
  type = string
}

locals {
  service_name = "EC2-instanceaby"
}

resource "aws_instance" "app_server" {
  ami           = "ami-090fa75af13c156b4"
  instance_type = var.instance_type

  tags = {
    Name = "arnab-${local.service_name}"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
output "instance_ip_addr" {
  value = aws_instance.app_server.public_ip
}

