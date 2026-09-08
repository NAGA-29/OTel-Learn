output "bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.logs.arn
}

output "collector_policy_arn" {
  value = aws_iam_policy.collector.arn
}

output "collector_role_arn" {
  value = try(aws_iam_role.collector[0].arn, null)
}
