
# TODO: Replication
# variable "region" {
#   type    = string
#   default = "us-east-2"
# }

variable "name" {
  type        = string
  description = "Bucket name that must be globally unique"
}

variable "random_id" {
  type = string
}

variable "kms_key" {
  type = object({
    id = string
  })
  description = "KMS Key Object"
}

variable "log_bucket_id" {
  type        = string
  description = "S3 Log Bucket ID"
}

variable "log_bucket_disabled" {
  type    = bool
  default = false
}

variable "tag_app" {
  type = string
}
