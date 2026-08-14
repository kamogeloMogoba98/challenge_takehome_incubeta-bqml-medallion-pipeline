resource "google_bigquery_dataset" "bronze" {
  dataset_id = "retail_bronze"
  location   = var.region
}

resource "google_bigquery_dataset" "silver" {
  dataset_id = "retail_silver"
  location   = var.region
}

resource "google_bigquery_dataset" "gold" {
  dataset_id = "retail_gold"
  location   = var.region
}