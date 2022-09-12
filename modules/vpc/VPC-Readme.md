## Creating a VPC using AWS VPC Module

[This](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) is a link to the docs on how to use their vpc module but an example is also included in this directory

[This](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=inputs) is a list of all possible inputs for a vpc module

[This](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.14.4?tab=outputs) is a list of outputs which can be defined in the outputs file
Example: 
```
output "vpc_id" {}
```


main file defines the module itself
[main.tf](./main-example.tf)


