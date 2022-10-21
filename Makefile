# Installs the pre-commit framework and 
# 	installs the specified pre-commit strategy (see .pre-commit-config.yaml)

# Usage: make

init:
	brew install pre-commit
	pre-commit install
