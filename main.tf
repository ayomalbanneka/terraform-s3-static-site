module "static_site" {
  source = "./modules/s3-static-site"

  bucket_name      = var.bucket_name
  environment      = var.environment
  index_document   = "index.html"
  error_docuemt    = "error.html"
  site_content_dir = "${path.root}/site"
}
