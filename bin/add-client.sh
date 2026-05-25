#!/usr/bin/env bash
set -euo pipefail

ENV_FILE=".env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: env file not found: $ENV_FILE"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

required_vars=(ANSIBLE_HOST ANSIBLE_USER SSH_PORT)
for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "ERROR: required variable '$var_name' is empty in $ENV_FILE"
    exit 1
  fi
done

read -rp "Enter client name: " CLIENT

ssh -p $ANSIBLE_PORT $ANSIBLE_USER@$ANSIBLE_HOST "docker exec ipsec-vpn ikev2.sh --addclient $CLIENT"

# TODO: fix error, copy files from container to host
# /clients/: No such file or directory
# make: *** [Makefile:12: add-client] Error 1

scp -p $ANSIBLE_PORT $ANSIBLE_USER@$ANSIBLE_HOST:/etc/ipsec.d/"$CLIENT.mobileconfig $CLIENT.p12 $CLIENT.sswan" /clients/

echo "Client configs was copied to ./clients/$CLIENT (mobileconfig, p12, sswan)"




