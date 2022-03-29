variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "terraform"
}

variable "region" {
  description = "Region for AWS resources"
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "Default Availability Zone"
  type        = string
  default     = "eu-west-1c"
}
