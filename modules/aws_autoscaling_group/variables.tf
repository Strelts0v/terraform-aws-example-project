variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "user_data_path" {
  type    = string
  default = "user_data.sh"
}

variable "vpc_zone_identifier" {
  type    = list
  default = [""]
}

variable "security_groups" {
  type    = list
  default = [""]
}

variable "launch_configuration_name_prefix" {
  type    = string
  default = "LC-"
}

variable "autoscaling_group_min_size" {
  type    = number
  default = 2
}

variable "autoscaling_group_max_size" {
  type    = number
  default = 2
}

variable "autoscaling_group_min_elb_capacity" {
  type    = number
  default = 2
}

variable "autoscaling_group_health_check_type" {
  description = "ELB - by load balancer, EC2 - by server"
  type        = string
  default     = "ELB"
}

variable "autoscaling_group_wait_for_capacity_timeout" {
  description = "Maximum time required for autoscaling group full init"
  type        = string
  default     = "30m"
}

variable "elb_name" {
  type    = string
  default = "Elastic-Load-Balancer"
}

variable "vpc_subnets" {
  type    = list
  default = [""]
}

variable "listener_elb_port" {
  type    = number
  default = 80
}

variable "listener_instance_port" {
  type    = number
  default = 80
}

variable "listener_elb_protocol" {
  type    = string
  default = "http"
}

variable "listener_instance_protocol" {
  type    = string
  default = "http"
}

variable "elb_health_check_healthy_threshold" {
  type    = number
  default = 2
}

variable "elb_health_check_unhealthy_threshold" {
  type    = number
  default = 2
}

variable "elb_health_check_timeout" {
  type    = number
  default = 3
}

variable "elb_health_check_target" {
  type    = string
  default = "HTTP:80/"
}

variable "elb_health_check_interval" {
  type    = number
  default = 10
}

variable "tags" {
  type = map
  default = {
    Owner       = "Hleb Straltsou"
    Project     = "Example Project"
    Environment = "dev"
  }
}
