
variable "name" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "log_retention_days" {
  type = number
}

variable "tag_app" {
  type = string
}
