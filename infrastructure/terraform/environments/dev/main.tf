terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # PoCはlocal state。ProductionではS3 backend + lockingを有効にする。
}

provider "aws" {
  region = var.aws_region
}

module "log_bucket" {
  source = "../../modules/log_bucket"

  bucket_name                   = var.bucket_name
  project_name                  = var.project_name
  environment                   = var.environment
  log_retention_days            = var.log_retention_days
  collector_role_principal_arns = var.collector_role_principal_arns
}
