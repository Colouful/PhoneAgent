#!/usr/bin/env bash
set -euo pipefail
OWNER="${REPO_OWNER:-Colouful}"
NAME="${REPO_NAME:-PhoneAgent}"
REPO="${OWNER}/${NAME}"
VISIBILITY="${REPO_VISIBILITY:-private}"
DESCRIPTION="iPhone-first AI phone agent using ESP32-S3, AirPlay, BLE and USB HID"
command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v gh >/dev/null || { echo "GitHub CLI (gh) required; install it and run gh auth login" >&2; exit 1; }
[[ "$VISIBILITY" == private || "$VISIBILITY" == public ]] || { echo "REPO_VISIBILITY must be private or public" >&2; exit 1; }
gh auth status >/dev/null
gh auth setup-git
[[ -d .git ]] || git init
git branch -M main
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  if [[ -z "$(git config user.name || true)" || -z "$(git config user.email || true)" ]]; then
    echo "Set git config user.name and user.email before the initial commit." >&2; exit 1
  fi
  git add -A
  git commit -m "chore: initialize PhoneAgent engineering starter"
else
  if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo "Working tree has uncommitted changes; review and commit before publishing." >&2; exit 1
  fi
fi
if git remote get-url origin >/dev/null 2>&1; then
  origin="$(git remote get-url origin)"
  [[ "$origin" == *"${OWNER}/${NAME}"* ]] || { echo "origin points to $origin; refusing to overwrite" >&2; exit 1; }
else
  if ! gh repo view "$REPO" >/dev/null 2>&1; then
    gh repo create "$REPO" "--${VISIBILITY}" --description "$DESCRIPTION"
  fi
  git remote add origin "https://github.com/${REPO}.git"
fi
git push -u origin main
echo "Published: https://github.com/${REPO}"
echo "Visibility: ${VISIBILITY}"
