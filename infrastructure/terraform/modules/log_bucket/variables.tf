variable "bucket_name" {
  description = "Globally unique private log bucket name."
  type        = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 365
  validation {
    condition     = var.log_retention_days > 90
    error_message = "log_retention_days must be greater than 90 because Glacier transition occurs on day 90."
  }
}

variable "standard_ia_transition_days" {
  type    = number
  default = 30
}

variable "glacier_transition_days" {
  type    = number
  default = 90
}

variable "collector_role_principal_arns" {
  description = "AWS principal ARNs allowed to assume the optional collector role. Empty disables role creation."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for arn in var.collector_role_principal_arns : arn != "*" && can(regex("^arn:[^:]+:iam::[0-9]{12}:(root|user/.+|role/.+)$", arn))])
    error_message = "collector_role_principal_arns must contain explicit IAM principal ARNs and must not include wildcards."
  }
}
