terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74"
    }
  }
  backend "s3" {
    bucket = "tf-state-lab-florent"
    key    = "tf-state"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-tf"
  }
}

resource "aws_s3_bucket" "tf-state" {
  bucket = "tf-state-lab-florent"

  tags = {
    Name        = "Terraform remote state"
    Environment = "Dev"
  }
}

