variable "aws_region" {
  description = "AWS region deploy into"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the website"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}