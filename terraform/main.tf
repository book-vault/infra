terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # backend "s3" {
  #   bucket         = "main-bookvault-terraform-s3"
  #   key            = "infra/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "main-bookvault-terraform-dynamodbTable"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.REGION

  default_tags {
    tags = local.common_aws_tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  region      = "us-east-2"
  environment = lower(terraform.workspace)
  project     = "bookvault"
  namespace   = "main"

  common_aws_tags = {
    Environment    = terraform.workspace
    Owner          = "manish"
    Organization   = "book-vault"
    RepositoryName = "infra"
    Description    = "book vault app"
    Iac            = "terraform"
  }
}