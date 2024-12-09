
variable "name" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "tag_app" {
  type = string
}
