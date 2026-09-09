output "s3_bucket_name" {
  value = module.log_bucket.bucket_name
}

output "s3_bucket_arn" {
  value = module.log_bucket.bucket_arn
}

output "aws_region" {
  value = var.aws_region
}

output "collector_policy_arn" {
  value = module.log_bucket.collector_policy_arn
}

output "collector_role_arn" {
  value = module.log_bucket.collector_role_arn
}
