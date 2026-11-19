#!/usr/bin/env bash
# install.sh — build this release in place (the app contract; Ymir's bin/apps/apps.sh runs it).
#   install.sh          node 24+, the workspaces from the lock file
#   install.sh --check  change nothing; exit 1 naming what is not right
# Works alone too: from a plain clone, `./install.sh` then `./start.sh`.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
case "$HERE" in */ymir-runtime/apps/*|*/ymir/apps/*)
  printf 'error: refusing to build inside a Ymir tree (%s) — an installed app has its own home\n' "$HERE" >&2; exit 1 ;;
esac

node_ok() {
  command -v node >/dev/null 2>&1 || { printf 'error: node is not installed (Hvergelmir needs Node 24+)\n' >&2; return 1; }
  local major; major="$(node -p 'process.versions.node.split(".")[0]')"
  [ "$major" -ge 24 ] || { printf 'error: node %s is too old (Hvergelmir needs 24+)\n' "$(node --version)" >&2; return 1; }
}

if [ "${1-}" = --check ]; then
  node_ok
  [ -d node_modules ] || { printf 'error: the workspaces are not installed (node_modules missing) — run ./install.sh\n' >&2; exit 1; }
  npm ls --workspaces --depth=0 >/dev/null 2>&1 || { printf 'error: the installed packages do not match package-lock.json — run ./install.sh\n' >&2; exit 1; }
  [ -f apps/dna-server-api/src/main.ts ] || { printf 'error: the API source is missing\n' >&2; exit 1; }
  CONFIG="${YMIR_APP_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hvergelmir}"
  for var in DNA_CLIENT_TOKEN DNA_CRON_TOKEN; do
    grep -Eq "^${var}=.{32,}" "$CONFIG/.env" 2>/dev/null \
      || { printf 'error: %s is not set in %s — run ./install.sh\n' "$var" "$CONFIG/.env" >&2; exit 1; }
  done
  printf 'hvergelmir: ready (node %s, workspaces installed)\n' "$(node --version)"
  exit 0
fi

node_ok
npm ci --no-audit --no-fund
CONFIG="${YMIR_APP_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hvergelmir}"
mkdir -p "${YMIR_APP_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/hvergelmir}" "$CONFIG"
# The config lives OUTSIDE the release, so no update or rollback touches it. A first install
# writes it from .env.example and fills the two bearer tokens (what upstream's `just api tokens`
# does); a token already set is never replaced, and no token is ever printed.
if [ ! -f "$CONFIG/.env" ]; then
  umask 077
  cp .env.example "$CONFIG/.env"
fi
for var in DNA_CLIENT_TOKEN DNA_CRON_TOKEN; do
  if ! grep -Eq "^${var}=.{32,}" "$CONFIG/.env"; then
    tok="$(python3 -c 'import secrets; print(secrets.token_hex(24))')"
    if grep -q "^${var}=" "$CONFIG/.env"; then sed -i "s|^${var}=.*|${var}=${tok}|" "$CONFIG/.env"
    else printf '%s=%s\n' "$var" "$tok" >> "$CONFIG/.env"; fi
    printf 'hvergelmir: %s generated in %s\n' "$var" "$CONFIG/.env"
  fi
done
unset tok
printf 'hvergelmir: installed — ./start.sh raises the API on :%s\n' "${DNA_PORT:-4850}"
