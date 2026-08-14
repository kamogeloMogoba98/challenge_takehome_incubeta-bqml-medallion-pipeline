resource "google_compute_instance" "processing_vm" {
  name         = "${var.environment}-processing-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP for dev purposes; remove for strict private architecture
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}