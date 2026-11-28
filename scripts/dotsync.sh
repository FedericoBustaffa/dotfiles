#!/usr/bin/env bash
set -euo pipefail

cd "${DOTFILES_DIR:-$HOME/dotfiles}"
mode=${1:-sync}
case "$mode" in login|logout|sync) ;; *) echo 'Usage: dotsync.sh [login|logout|sync]' >&2; exit 2 ;; esac

# Serialize session hooks and manual runs. Never publish from another branch.
exec 9>"$(git rev-parse --git-path dotsync.lock)"
flock -w 5 9
if [[ $(git branch --show-current) != master ]]; then
    echo 'Skipping dotfiles sync: expected the master branch.' >&2
    exit 0
fi

export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND=${GIT_SSH_COMMAND:-'ssh -o BatchMode=yes -o ConnectTimeout=8 -o ServerAliveInterval=5 -o ServerAliveCountMax=2'}

if [[ $mode != login ]]; then
    # Include tracked modifications and deletions, but never auto-add new files.
    git add -u
    if ! git diff --cached --quiet; then
        git commit -m "Sync dotfiles from ${HOSTNAME:-desktop}"
    fi
fi

if [[ $mode != logout ]]; then
    git fetch origin
    if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
        echo 'Fetched dotfiles; skipping fast-forward because tracked files have local edits.'
        exit 0
    fi
    git merge --ff-only origin/master
fi

if [[ $mode != login ]]; then
    git push origin HEAD:refs/heads/master
fi
