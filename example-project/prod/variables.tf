variable "env" {
  type    = string
  default = "Prod"
}

variable "env_lower" {
  type    = string
  default = "prod"
}

variable "project" {
  type    = string
  default = "Example"
}

variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map

  default = {
    Owner       = "Hleb Straltsou"
    Project     = "Example"
    Environment = "Prod"
  }
}
