## hvergelmir · 2026-11-19 — Hvergelmir leaves Ymir with its history

Hvergelmir lived at `apps/hvergelmir` in `zerwiz/ymir` from 2026-11-06. It now has its own repo, cut from Ymir with
`git filter-repo --subdirectory-filter apps/hvergelmir`, so every commit that touched it is here with its author and
date. Ymir keeps its own record of the app (`docs/fixes/apps/` in Ymir), never deleted.

This repo now carries the app contract Ymir installs from: `app.yaml`, `install.sh` (with `--check`), `start.sh`,
`stop.sh`, `uninstall.sh`. Installed by Ymir it lives in `~/.local/share/ymir-apps/hvergelmir/`; alone, `./install.sh`
then `./start.sh` from a clone. Its upstream is `zerwiz/pi-durable-news-agent` (MIT, see `UPSTREAM.md`).
