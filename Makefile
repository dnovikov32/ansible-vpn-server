.PHONY: bootstrap test add-client delete-client list-clients

ANSIBLE_PLAYBOOK = ansible-playbook

bootstrap:
	@set -a; . ./.env; set +a; $(ANSIBLE_PLAYBOOK) playbooks/bootstrap.yml

test:
	@bash bin/test.sh

add-client:
	@bash bin/add-client.sh

delete-client:
	@bash bin/delete-client.sh

list-clients:
	@bash bin/list-clients.sh
