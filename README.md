# Terraform Module

## MacOS Setup

1. Install terraform on your machine locally

```console
brew tap hashicorp/tap

brew install hashicorp/tap/terraform
```

2. Run the Makefile

```console
make
```


## Other OS Setup

1. Follow the [Hashicorp Terraform Install CLI Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2. Install the pre-commit framework:

### Using pip:

```console
pip install pre-commit
```

### Using Conda (via conda-forge):
```console
conda install -c conda-forge pre-commit
```

3.  Install the git hook scripts:

```console
pre-commit install
```

<!-- BEGIN_TF_DOCS -->

## Sample Usage
```hcl
module "example" {


	 source  = "github.com/Cyber4All/terraform-cyber4all-catalog//modules/<REPLACE_WITH_MODULE>?ref=v<REPLACE_WITH_VERSION>"



}
```


<!-- END_TF_DOCS -->