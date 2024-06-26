

variable "VM_USER_HOME" {

  description = "VM user, same as sshkey generated"
  default     = "/home/gcp"
}

variable "secrets_key_path" {
  description = "my google credentials"
  default     = "~/.gc/my-creds.json"

}

variable "project" {
  description = "Project"
  default     = "forward-ace-411913"

}
variable "region" {
  description = "Project"
  default     = "us-west1-b"

}

variable "location" {
  description = "Project location"
  default     = "US"

}

variable "bq_dataset" {
  description = "my Biq query dataset name "
  default     = "zoomcamp_bigquery2"

}

variable "gcs_storage_class" {

  description = "Bucket storage class"
  default     = "STANDARD"
}

variable "gcs_bucketname" {

  description = "Bucket name"
  default     = "zoomcamp_b2"
}

