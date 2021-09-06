variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "vivien-SG-instance"
}

output "alb_dns_name" {
  value       = aws_lb.lb-example.dns_name
  description = "The domain name of the load balancer"
}

