terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}
provider "aws" {
  # version = "~> 2.0"
  region = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "Instance type to launch"
  sensitive   = true
    validation {
      condition = can(regex("^t2.", var.instance_type))
      error_message = "The instance type must be a t2 type instance."
    }
}

locals {
  service_name = "EC2-instanceaby"
}

resource "aws_instance" "app_server" {
  ami           = "ami-090fa75af13c156b4"
  instance_type = var.instance_type
}