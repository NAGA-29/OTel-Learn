variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "otel-demo"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "log_retention_days" {
  type    = number
  default = 365
}

variable "collector_role_principal_arns" {
  type    = list(string)
  default = []
}

