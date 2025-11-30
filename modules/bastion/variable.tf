variable "environment" { type = string }
variable "vpc_cidr" { type = string }

variable "vpc_id" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "key_name" {
  type = string
}

variable "bastion_sg_id" {
  type = string
}

variable "my_ip" {
  type = string
}
