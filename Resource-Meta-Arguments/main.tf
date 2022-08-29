terraform {
  #   backend "local" {
  #     # hostname     = "app.terraform.io"
  #     # organization = "terraform-basics"

  #     # workspaces {
  #     #   name = "getting-started"
  #     # }
  #   }

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

# variable "instance_type" {
#   type        = string
#   description = "Instance type to launch"
#   sensitive   = true
#     validation {
#       condition = can(regex("^t2.", var.instance_type))
#       error_message = "The instance type must be a t2 type instance"
#     }
# }
locals {
  service_name = "EC2-instanceaby"
}
resource "aws_s3_bucket" "bucket" {
  bucket = "my-tf-test-bucket-depends-on"
  //depends_on -> Resource Meta-Arguments
  depends_on = [
    aws_instance.app_server
  ]

  #   tags = {
  #     Name        = "My bucket"
  #     Environment = "Dev"
  #   }
}

# resource "aws_s3_bucket_acl" "example" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "private"
# }

resource "aws_instance" "app_server" {
  //count -> Resource Meta-Arguments
  #   count         = 3
  //for_each -> Resource Meta-Arguments
  for_each = {

    micro  = "t2.micro",
    small  = "t2.small",
    medium = "t2.medium"

  }
  ami           = "ami-090fa75af13c156b4"
  instance_type = each.value
  tags = {
    Name = "Server ${each.key}"
  }
}
output "instance_ip_addr" {
  value = values(aws_instance.app_server)[*].public_ip
}
