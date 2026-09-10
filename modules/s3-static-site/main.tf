resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_website_configuration" "site_config" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_docuemt
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  # Must come after the public access block is set, or AWS rejects the policy
  depends_on = [aws_s3_bucket_public_access_block.bucket_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "site_files" {
  for_each = fileset(var.site_content_dir,"**/*")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${var.site_content_dir}/${each.value}"

  # Forces re-upload only when file content actually changes
  etag = filemd5("${var.site_content_dir}/${each.value}")

  # Set the content type based on the file extension, defaulting to application/octet-stream if unknown
  content_type = lookup(
    local.mime_types,
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
  )
}

locals {
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".json" = "application/json"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".txt"  = "text/plain"
  }
}