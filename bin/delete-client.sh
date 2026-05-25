#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: env file not found: $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

required_vars=(ANSIBLE_HOST ANSIBLE_USER SSH_PORT)
for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "ERROR: required variable '$var_name' is empty in $ENV_FILE"
    exit 1
  fi
done

read -rp "Enter client name: " CLIENT

ssh -p $ANSIBLE_PORT $ANSIBLE_USER@$ANSIBLE_HOST "docker exec ipsec-vpn ikev2.sh --deleteclient $CLIENT -y"
