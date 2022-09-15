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
2. Change the git config to look at the new git hook directory

```console
git config core.hooksPath .githooks
```

3. Install TFlint following their [installation guide](https://github.com/terraform-linters/tflint#installation)
