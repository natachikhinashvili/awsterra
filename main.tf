terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 2.7.0"
        }
    }
}

resource "aws_s3_bucket" "nats_backend" {
    bucket = var.bucket_name
    acl    = "private"
}