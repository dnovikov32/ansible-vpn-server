.PHONY: run install-collections

run:
	@set -a; . ./.env; set +a; ansible-playbook playbooks/vpn-fin.yml

install-collections:
	ansible-galaxy collection install -r collections/requirements.yml
