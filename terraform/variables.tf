variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Short name used to label resources."
  type        = string
  default     = "marketplace-arbitrage"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,22}$", var.project_name))
    error_message = "project_name must be 1-22 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,8}$", var.environment))
    error_message = "environment must be 1-8 lowercase letters, numbers, or hyphens."
  }
}

variable "container_image" {
  description = "Full container image URI. Defaults to the ECR repository's latest tag."
  type        = string
  default     = null
  nullable    = true
}

variable "container_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate task memory in MiB."
  type        = number
  default     = 512
}

variable "app_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8011
}

variable "desired_count" {
  description = "Number of web application tasks. Keep at one while using SQLite."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count == 1
    error_message = "The SQLite deployment supports exactly one web task."
  }
}

variable "scan_schedule" {
  description = "EventBridge schedule expression for the scanner."
  type        = string
  default     = "rate(30 minutes)"
}

variable "schedule_enabled" {
  description = "Enable scheduled scanner tasks after credentials and categories are configured."
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 14
}

variable "vpc_cidr" {
  description = "CIDR range for the small public VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "allowed_ingress_cidr" {
  description = "CIDR allowed to reach the public load balancer. Narrow this when possible."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ebay_environment" {
  description = "eBay API environment: production or sandbox."
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "sandbox"], var.ebay_environment)
    error_message = "ebay_environment must be production or sandbox."
  }
}

variable "ebay_credentials_secret_arn" {
  description = "Optional Secrets Manager ARN containing EBAY_CLIENT_ID, EBAY_CLIENT_SECRET, and EBAY_REDIRECT_URI JSON keys."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}
