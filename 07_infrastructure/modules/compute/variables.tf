# variables.tf
variable "environment" { type = string }
variable "zone" { type = string }
variable "machine_type" {
  type        = string
  default     = "e2-medium"
}