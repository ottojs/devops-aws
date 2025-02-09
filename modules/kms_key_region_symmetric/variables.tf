
variable "name" {
  type    = string
  default = "main"
}

variable "description" {
  type    = string
  default = "main"
}

variable "iam_user" {
  type = string
}

variable "tags" {
  type = map(string)
}
