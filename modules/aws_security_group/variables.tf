variable "name" {
  type    = string
  default = "Web Server Security Group"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "allowed_ports" {
  description = "List of ports to open on server"
  type        = list
  default     = ["80", "443", "22", "8080"]
}

variable "ports_protocol" {
  type    = string
  default = "tcp"
}

variable "ingress_cidr_blocks" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "egress_cidr_blocks" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "tags" {
  type    = map
  default = {}
}
