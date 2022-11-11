# this defines the provider for the following resources
# go to mongodbatlas to create a project then follow the 
# documentation to create an API key for that project
provider "mongodbatlas" {
  public_key  = var.mongodbatlas_public_key
  private_key = var.mongodbatlas_private_key
}

#https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster
# This resource will create an entirely new cluster for a specific project id.
# You will most likely want to use the mongodbatlas_project_ip_access_list
# with it. 
# NOTE: mongodbatlas does not allow you to provision a free tier cluster from
# the public API which is why this example uses the "M2" provider instance size
resource "mongodbatlas_cluster" "cluster-test" {
  project_id = var.project_id
  name       = "cluster-test-global"

  # Provider Settings "block"
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M2"
}

#https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list
# this resource will create an entry in the cluster IP access list for 
# the given IP address. This can be used seperately from the
# mongodbatlas_cluster resource if you need to add an ip address to an 
# existing cluster. This will work for a free tier cluster as well.
resource "mongodbatlas_project_ip_access_list" "test" {
  project_id = var.project_id
  ip_address = var.nat_gateway_ip
  comment    = "ip address for tf test"

  depends_on = [
    mongodbatlas_cluster.cluster-test
  ]
}