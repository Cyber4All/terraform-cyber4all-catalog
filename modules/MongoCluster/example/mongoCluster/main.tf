provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

resource "mongodbatlas_cluster" "cluster-test" {
  project_id = var.project_id
  name       = "cluster-test-global"

  # Provider Settings "block"
  provider_name         = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name  = "US_EAST_1"
  #this will not spin up a free tier cluster via the public API
  # however you may add an entry to the ip access list to an 
  # existing cluster using only the resource below
  provider_instance_size_name = "M2"
}

resource "mongodbatlas_project_ip_access_list" "test" {
  project_id = var.project_id
  ip_address = var.nat_gateway_ip
  comment    = "ip address for tf test"

  depends_on = [
    mongodbatlas_cluster.cluster-test
  ]
}