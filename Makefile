SHELL := /bin/bash
DEFAULT_GOAL := help

help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: bootstrap
bootstrap: ## Bootstrap server
	@set -a; . ./.env; set +a; ansible-playbook playbooks/bootstrap.yml

.PHONY: test
test: ## Run tests
	@bash bin/test.sh

.PHONY: add-client
add-client: ## Add new client
	@bash bin/add-client.sh

.PHONY: delete-client
delete-client: ## Delete client
	@bash bin/delete-client.sh

.PHONY: list-client
list-clients: ## Client list
	@bash bin/list-clients.sh
