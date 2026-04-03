#!/bin/bash
set -euo pipefail

COMPOSE_DIR="/home/tim/paperless-ai"
LOG_FILE="$COMPOSE_DIR/update.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

cd "$COMPOSE_DIR"

# ── pull latest config from git ───────────────────────────────────────────────
log "Checking for config updates..."
git pull --ff-only origin main >> "$LOG_FILE" 2>&1 || log "WARN: git pull failed, continuing with local config"

# ── pull latest image and restart if changed ──────────────────────────────────
BEFORE=$(docker compose images -q 2>/dev/null | sort | md5sum)
docker compose pull >> "$LOG_FILE" 2>&1
AFTER=$(docker compose images -q 2>/dev/null | sort | md5sum)

if [ "$BEFORE" != "$AFTER" ]; then
  log "New image available — restarting..."
  docker compose up -d >> "$LOG_FILE" 2>&1
  log "Update complete."
else
  log "Already up to date."
fi
