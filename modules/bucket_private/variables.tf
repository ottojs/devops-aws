
# TODO: Replication
# variable "region" {
#   type    = string
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

variable "delete_days_files" {
  type    = number
  default = 0 # Disabled
}

variable "delete_days_old_versions" {
  type    = number
  default = 90
}

variable "delete_days_multipart" {
  type    = number
  default = 3
}

variable "tags" {
  type = map(string)
}
