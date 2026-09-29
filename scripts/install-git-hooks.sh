#!/usr/bin/env bash
# ============================================================================
# install-git-hooks.sh
#
# One-time (idempotent) setup step that points this clone's `core.hooksPath`
# at the repository's versioned `.githooks/` directory, so the pre-commit
# count-freshness gate (`.githooks/pre-commit`) actually fires. Committing
# `.githooks/pre-commit` alone does nothing: `core.hooksPath` is per-clone
# LOCAL git config, never tracked, so every clone (including this one) needs
# this script run once.
#
# Usage:
#   scripts/install-git-hooks.sh            # set core.hooksPath = .githooks
#   scripts/install-git-hooks.sh --check     # report status only, change nothing
#   scripts/install-git-hooks.sh --print     # alias for --check
# ============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR_REL=".githooks"
HOOKS_DIR_ABS="${REPO_ROOT}/${HOOKS_DIR_REL}"

MODE="install"
case "${1:-}" in
  "")
    MODE="install"
    ;;
  --check|--print)
    MODE="check"
    ;;
  --help|-h)
    cat << 'USAGE'
Usage: scripts/install-git-hooks.sh [--check|--print]

  (no arguments)   Set this clone's local core.hooksPath to .githooks, so
                   .githooks/pre-commit (the count-freshness gate) fires.
                   Idempotent: a second run reports "already installed"
                   and exits 0 without changing anything.

  --check, --print
                   Read-only: report whether the hooks are installed
                   without changing any git config. Exit 0 whether
                   installed or not; useful in CONTRIBUTING.md and for a
                   contributor verifying their own setup.
USAGE
    exit 0
    ;;
  *)
    echo "install-git-hooks.sh: unrecognized argument: $1" >&2
    echo "Usage: scripts/install-git-hooks.sh [--check|--print]" >&2
    exit 2
    ;;
esac

CURRENT_VALUE="$(git -C "${REPO_ROOT}" config --local --get core.hooksPath 2>/dev/null || true)"

report_hooks_dir_state() {
  # Warn -- without failing -- if .git/hooks/ still holds a real (non-sample)
  # hook. Once core.hooksPath moves to .githooks/, anything left in
  # .git/hooks/ stops firing silently, which is worth a contributor knowing
  # about rather than discovering later.
  local git_hooks_dir="${REPO_ROOT}/.git/hooks"
  if [[ -d "${git_hooks_dir}" ]]; then
    local stray
    stray="$(find "${git_hooks_dir}" -maxdepth 1 -type f ! -name '*.sample' 2>/dev/null || true)"
    if [[ -n "${stray}" ]]; then
      echo "install-git-hooks.sh: WARNING -- .git/hooks/ contains non-sample file(s) that will" >&2
      echo "  stop firing once core.hooksPath points at ${HOOKS_DIR_REL}/:" >&2
      echo "${stray}" | sed 's/^/    /' >&2
    fi
  fi
}

if [[ "${MODE}" == "check" ]]; then
  if [[ "${CURRENT_VALUE}" == "${HOOKS_DIR_REL}" ]]; then
    echo "install-git-hooks.sh --check: installed (core.hooksPath = ${HOOKS_DIR_REL})"
    exit 0
  else
    echo "install-git-hooks.sh --check: NOT installed (core.hooksPath = ${CURRENT_VALUE:-unset})"
    echo "  Run 'bash scripts/install-git-hooks.sh' to install."
    exit 0
  fi
fi

# --- install mode ---
if [[ "${CURRENT_VALUE}" == "${HOOKS_DIR_REL}" ]]; then
  echo "install-git-hooks.sh: already installed (core.hooksPath = ${HOOKS_DIR_REL}); nothing to do."
  exit 0
fi

if [[ ! -d "${HOOKS_DIR_ABS}" ]]; then
  echo "install-git-hooks.sh: ${HOOKS_DIR_ABS} does not exist -- nothing to install." >&2
  exit 1
fi

report_hooks_dir_state

echo "install-git-hooks.sh: prior core.hooksPath = ${CURRENT_VALUE:-unset (default: .git/hooks)}"
git -C "${REPO_ROOT}" config --local core.hooksPath "${HOOKS_DIR_REL}"
echo "install-git-hooks.sh: new core.hooksPath = ${HOOKS_DIR_REL}"
echo "install-git-hooks.sh: installed. The pre-commit count-freshness gate is now active in this clone."
