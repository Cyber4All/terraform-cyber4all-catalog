<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>=1.2.9)

## Providers

The following providers are used by this module:

- <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider\_mongodbatlas)

## Resources

The following resources are used by this module:

- [mongodbatlas_cluster.cluster-test](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/cluster) (resource)
- [mongodbatlas_project_ip_access_list.test](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs/resources/project_ip_access_list) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_mongodbatlas_private_key"></a> [mongodbatlas\_private\_key](#input\_mongodbatlas\_private\_key)

Description: Private key for mongodb

Type: `string`

### <a name="input_mongodbatlas_public_key"></a> [mongodbatlas\_public\_key](#input\_mongodbatlas\_public\_key)

Description: Public key for mongodb

Type: `string`

### <a name="input_nat_gateway_ip"></a> [nat\_gateway\_ip](#input\_nat\_gateway\_ip)

Description: the ip address for the NAT gateway to connect to the DB

Type: `string`

### <a name="input_project_id"></a> [project\_id](#input\_project\_id)

Description: the id of the DB to connect to

Type: `string`

## Outputs

The following outputs are exported:

### <a name="output_srv"></a> [srv](#output\_srv)

Description: The SRV of the cluster
<!-- END_TF_DOCS -->