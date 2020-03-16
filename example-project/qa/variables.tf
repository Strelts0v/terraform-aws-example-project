variable "env" {
  type    = string
  default = "QA"
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
    Environment = "QA"
  }
}
