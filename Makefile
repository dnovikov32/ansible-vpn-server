.PHONY: bootstrap test add-client remove-client list-client

ANSIBLE_PLAYBOOK = ansible-playbook

bootstrap:
	@set -a; . ./.env; set +a; $(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml

test:
	@bash bin/test.sh

add-client:
	@bash bin/add-client.sh

remove-client:
	@bash bin/remove-client.sh

list-client:
	@bash bin/list-client.sh
