output "bucket_id" {
  description = "Bucket id of the S3 bucket created for the static website"
  value = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket created for the static website"
  value = aws_s3_bucket.site.arn
}

output "website_endpoint" {
  description = "The website endpoint URL (HTTP only)"
  value = aws_s3_bucket_website_configuration.site_config.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = aws_s3_bucket_website_configuration.site_config.website_domain
}