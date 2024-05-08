# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

provider "google" {
  project = "focus-empire-416205"
  region  = "us-west1"
  zone    = "us-west1-a"
}


resource "google_compute_instance" "gcp-instance1" {
  boot_disk {
    auto_delete = true
    device_name = "gcp-instance1"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240426"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"
  name         = "gcp-instance1"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/focus-empire-416205/regions/us-west1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "311163312383-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "us-west1-a"
}

resource "null_resource" "execute_commands" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = google_compute_instance.instance-20240507-194304.network_interface.0.access_config.0.nat_ip
      user        = "ubuntu" 
      private_key = file("${path.module}/key.pem")
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y sysbench",
      "sysbench --test=cpu run",
      "sysbench --test=memory run",
      "sysbench --test=fileio --file-test-mode=seqwr run"
    ]
  }
}
