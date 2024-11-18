
variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "file_key" {
  type = string
}

variable "file_crt" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
  description = "KMS Key Object"
}

variable "subnet" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "tag_app" {
  type = string
}

variable "remote_cidr" {
  type = string
}
