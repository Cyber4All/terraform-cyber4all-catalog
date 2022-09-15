# Changes git config to look to .githooks for TF pre-commit hooks
# Also installs tflint which is used in the pre-commit hook
# Install only supports MacOS brew command

# Usage: make

init:
	git config core.hooksPath .githooks
	brew install tflint