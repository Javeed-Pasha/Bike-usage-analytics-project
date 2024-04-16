terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.23.0"
    }
  }
}
##
provider "google" {
  # Configuration options
  credentials = file(var.secrets_key_path)
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "instance-2" {
  boot_disk {
    auto_delete = true
    device_name = "instance-2"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240110"
      size  = 30
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-standard-4"
  name         = "instance-2"

  network_interface {
      network = "default"
      access_config {
        
      }
  }


  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = var.region
  


 
  metadata = {
    ssh-keys = "gcp:${file("~/.ssh/gcp_key.pub")}"
	startup-script = <<-EOF
    sudo apt-get update
    sudo apt-get install -y docker.io
    git clone https://github.com/Javeed-Pasha/mage_dataengineeringzoomcamp.git ${var.VM_USER_HOME}/mage
    sudo groupadd docker
    sudo gpasswd -a $USER docker
    sudo usermod -a -G docker $USER
    sudo service docker restart
    newgrp docker
    mkdir -p ${var.VM_USER_HOME}/bin
    wget https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -O ${var.VM_USER_HOME}/bin/docker-compose
    chmod +x ${var.VM_USER_HOME}/bin/docker-compose
    sudo chown -R $USER:$USER ${var.VM_USER_HOME}/mage
    cd ${var.VM_USER_HOME}/mage
    ${var.VM_USER_HOME}/bin/docker-compose up -d --build
  EOF
     
   }


}
 
resource "google_storage_bucket" "GCP_BUCKET" {
  name          = var.gcs_bucketname
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "dtc_zoomcamp_ds" {
  dataset_id = var.bq_dataset
  location   = var.location
  delete_contents_on_destroy = true
}

