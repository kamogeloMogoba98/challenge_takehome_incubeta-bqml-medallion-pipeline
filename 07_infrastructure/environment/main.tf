terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "storage" {
  source      = "../modules/storage"
  bucket_name = "${var.project_id}-raw-data-lake"
  region      = var.region
}

module "bigquery" {
  source      = "../modules/bigquery"
  environment = var.environment
  region      = var.region
}

module "compute" {
  source       = "../modules/compute"
  environment  = var.environment
  zone         = var.zone
  machine_type = "e2-medium"
}