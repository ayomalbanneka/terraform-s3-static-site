variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "index_document" {
  description = "Index document for the static website"
  type = string
  default = "index.html"
}

variable "error_docuemt" {
  description = "Error document for the static website"
  type = string
  default = "error.html"
}

variable "site_content_dir" {
  description = "Local path to the directory containing the static website content"
  type = string
}