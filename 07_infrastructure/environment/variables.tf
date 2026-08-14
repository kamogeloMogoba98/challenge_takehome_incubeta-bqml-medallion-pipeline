variable "project_id" {
  type        = string
  description = "Your GCP Project ID"
}

variable "region" {
  type        = string
  default     = "us-central1"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  type        = string
  default     = "prod"
}