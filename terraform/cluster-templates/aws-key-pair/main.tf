provider "aws" {
  region = var.region

  default_tags {
    tags = merge({
      source  = "Terraform Managed"
      cluster = var.cluster_name
    }, var.tags)
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = var.key_pair_name
  public_key = var.public_key
}
