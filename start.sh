#!/usr/bin/env bash
# start.sh — raise the API alone, on loopback (DNA_PORT, default 4850). Its config is .env (see .env.example).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${YMIR_APP_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hvergelmir}"
[ -f "$CONFIG/.env" ] && { set -a; . "$CONFIG/.env"; set +a; }
cd "$HERE/apps/dna-server-api"
exec env NODE_NO_WARNINGS=1 HOST="${HOST:-127.0.0.1}" npx tsx src/main.ts "$@"
