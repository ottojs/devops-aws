
variable "vpc" {
  type = object({
    id = string
  })
}

variable "root_domain" {
  type = string
}

variable "tags" {
  type = map(string)
}
