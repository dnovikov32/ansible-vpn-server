#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$ROOT_DIR/.env}"

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

if ! command -v ssh >/dev/null 2>&1; then
  echo "ERROR: ssh client is not installed"
  exit 1
fi

if ! command -v nc >/dev/null 2>&1; then
  echo "ERROR: netcat (nc) is not installed"
  exit 1
fi

HAS_SSHPASS=0
if command -v sshpass >/dev/null 2>&1; then
  HAS_SSHPASS=1
fi

REMOTE="${ANSIBLE_USER}@${ANSIBLE_HOST}"
SSH_COMMON_OPTS=(
  -p "$SSH_PORT"
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout=8
)

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1"; exit 1; }

remote_exec() {
  ssh "${SSH_COMMON_OPTS[@]}" "$REMOTE" "$@"
}

echo "Testing server security settings on $REMOTE:$SSH_PORT"

# 1) Server uses SSH_PORT for SSH connections
if nc -z -w 5 "$ANSIBLE_HOST" "$SSH_PORT"; then
  pass "TCP port $SSH_PORT is reachable"
else
  fail "TCP port $SSH_PORT is not reachable"
fi

if nc -z -w 5 "$ANSIBLE_HOST" 22; then
  fail "Default SSH port 22 is reachable"
else
  pass "Default SSH port 22 is not reachable"
fi

set +e
ssh22_attempt_output="$(
  ssh \
    -p 22 \
    -o StrictHostKeyChecking=accept-new \
    -o BatchMode=yes \
    -o ConnectTimeout=8 \
    "$REMOTE" "echo ssh22-open" 2>&1
)"
ssh22_attempt_rc=$?
set -e

if [[ $ssh22_attempt_rc -eq 0 ]]; then
  fail "SSH login unexpectedly succeeded on port 22"
else
  pass "SSH login on port 22 is blocked"
fi

if remote_exec -o BatchMode=yes "echo connected >/dev/null"; then
  pass "SSH key-based connection works on port $SSH_PORT"
else
  fail "Cannot connect with SSH key on port $SSH_PORT"
fi

# 2) Password auth is disabled.
# Preferred check: real password login attempt via sshpass.
# Fallback: check effective sshd config when sshpass/password are unavailable.
if [[ $HAS_SSHPASS -eq 1 && -n "${ANSIBLE_PASSWORD:-}" ]]; then
  set +e
  password_attempt_output="$(
    sshpass -p "$ANSIBLE_PASSWORD" ssh \
      "${SSH_COMMON_OPTS[@]}" \
      -o PubkeyAuthentication=no \
      -o PreferredAuthentications=password \
      -o NumberOfPasswordPrompts=1 \
      "$REMOTE" "echo password-login-ok" 2>&1
  )"
  password_attempt_rc=$?
  set -e

  if [[ $password_attempt_rc -eq 0 ]]; then
    fail "Password login succeeded; PasswordAuthentication is still enabled"
  else
    pass "Password login is denied"
  fi
else
  echo "[WARN] sshpass or ANSIBLE_PASSWORD missing, using sshd config fallback check"
  password_auth="$(remote_exec "if [ \"\$(id -u)\" -ne 0 ] && command -v sudo >/dev/null 2>&1; then sudo sshd -T; else sshd -T; fi" | awk '/^passwordauthentication / {print $2}')"
  if [[ "$password_auth" == "no" ]]; then
    pass "PasswordAuthentication is disabled (checked via sshd -T)"
  else
    fail "PasswordAuthentication is not disabled (current: ${password_auth:-unset})"
  fi
fi

# 3) Firewall rules
ufw_status="$(remote_exec "if [ \"\$(id -u)\" -ne 0 ] && command -v sudo >/dev/null 2>&1; then sudo ufw status verbose; else ufw status verbose; fi")"
if grep -q "Status: active" <<<"$ufw_status"; then
  pass "UFW is active"
else
  fail "UFW is not active"
fi

if grep -Eq "Default: deny \(incoming\), allow \(outgoing\)" <<<"$ufw_status"; then
  pass "UFW default policy is deny incoming / allow outgoing"
else
  fail "Unexpected UFW default policy"
fi

if grep -Eq "(^|[[:space:]])${SSH_PORT}(/tcp)?([[:space:]]|$).*ALLOW" <<<"$ufw_status"; then
  pass "UFW allows SSH port $SSH_PORT"
else
  fail "UFW rule for SSH port $SSH_PORT not found"
fi

# 4) Check that standard public ports are closed from outside.
closed_ports="80 443"
for port in $closed_ports; do
  if nc -z -w 5 "$ANSIBLE_HOST" "$port"; then
    fail "Port $port is reachable, but expected to be closed by firewall"
  else
    pass "Port $port is closed"
  fi
done

echo "All security checks passed."
