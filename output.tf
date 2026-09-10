output "website_url" {
  description = "The full HTTP URL of the static website"
  value       = "http://${module.static_site.website_endpoint}"
}

output "bucket_name" {
  description = "The S3 bucket name"
  value       = module.static_site.bucket_id
}