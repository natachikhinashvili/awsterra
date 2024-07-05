provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
  backend "s3" {
    bucket = "natsbackend"
    key    = "backend.tfstate"
    region = "eu-central-1"
  }
}
