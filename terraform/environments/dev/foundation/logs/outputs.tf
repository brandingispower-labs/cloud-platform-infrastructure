output "log_bucket_name" {
  value = aws_s3_bucket.logs.id
}

output "log_bucket_arn" {
  value = aws_s3_bucket.logs.arn
}