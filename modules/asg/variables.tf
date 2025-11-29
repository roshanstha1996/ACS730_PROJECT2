variable "launch_template_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "desired_capacity" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "alb_target_group_arn" { type = string }
