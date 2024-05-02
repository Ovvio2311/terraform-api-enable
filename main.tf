
data "google_client_config" "default" {  
}

data "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = "us-central1-c"
  
}

provider "google" {
  # credentials = file("/mnt/c/Users/jackyli/Downloads/able-scope-413414-d1f3a6012760.json")
  project = var.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}


provider "helm" {
  kubernetes {
    # config_path = "~/.kube/config"
    # host                   = "https://${module.gke.endpoint}"
    host  = "https://${data.google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    # cluster_ca_certificate   = base64decode(module.gke.ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["container", "clusters", "get-credentials", var.cluster_name, "--zone", "us-central1", "--project", var.project_id]
      # args=[]
      # command="gke-gloud-auth-plugin"
      command     = "gcloud"
    }
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    client_key             = base64decode(data.google_container_cluster.primary.master_auth.0.client_key)
    client_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.client_certificate)
  }
}
# ----------------------------------------------------------------------------------------

resource "google_project_service" "project" {
  project = "proven-fort-421209"
  service = "sqladmin.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
