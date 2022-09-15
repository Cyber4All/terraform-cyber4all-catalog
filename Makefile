# Changes git config to look to .githooks for TF pre-commit hooks
# Also installs tflint, and terragrunt which is used in the pre-commit hook
# Install only supports MacOS brew command

# ** Note: You may need to uninstall terraform before installing terragrunt
# brew uninstall terraform

# Usage: make

init:
	git config core.hooksPath .githooks
	brew install tflint
	brew install terragrunt