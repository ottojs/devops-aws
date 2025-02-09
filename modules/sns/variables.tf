
variable "name" {
  type = string
}

variable "email" {
  type = string
}

variable "kms_key" {
  type = object({
    id  = string
    arn = string
  })
}

variable "tags" {
  type    = map(string)
  default = {}
}
