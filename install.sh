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
  printf 'hvergelmir: ready (node %s, workspaces installed)\n' "$(node --version)"
  exit 0
fi

node_ok
npm ci --no-audit --no-fund
mkdir -p "${YMIR_APP_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/hvergelmir}" \
         "${YMIR_APP_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hvergelmir}"
printf 'hvergelmir: installed — ./start.sh raises the API on :%s\n' "${DNA_PORT:-4850}"
