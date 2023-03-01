terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  backend "s3" {
    bucket = "awsteam2s3bucket"
    key = "terraformstate/terraform.tfstate"
    region = "us-east-1"
    profile = "jeremyb"
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "jeremyb"
  default_tags {
    tags = var.tags
  }
}