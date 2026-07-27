#!/usr/bin/env bash
# retriage.sh - category x document x base_char breakdown of any residual ledger
# produced by literature-repair-combining.sh --ledger-json (or a concatenation of
# several such runs, as residual-ledger-baseline.json is).
#
# Usage:
#   retriage.sh LEDGER.json [--reason REASON] [--dir DIRNAME]
#
# Reused verbatim (per plan Phase 1 Task 2) by Phases 2-7 and 10 of task 404's
# implementation plan to measure yield after each fix lands: run this before and
# after a phase's --write to see exactly which (reason, dir, base_char) buckets
# shrank and by how much.
#
# Output: TSV, one row per (reason, dir, base_char) triple, sorted by count
# descending, plus a grand total line.

set -euo pipefail

LEDGER="${1:-}"
if [ -z "$LEDGER" ] || [ ! -f "$LEDGER" ]; then
  echo "Usage: $0 LEDGER.json [--reason REASON] [--dir DIRNAME]" >&2
  exit 1
fi
shift || true

REASON_FILTER=""
DIR_FILTER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --reason) REASON_FILTER="${2:-}"; shift 2 ;;
    --dir) DIR_FILTER="${2:-}"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

jq -r --arg reason "$REASON_FILTER" --arg dir "$DIR_FILTER" '
  [ .[]
    | select($reason == "" or .reason == $reason)
    | select($dir == "" or .dir == $dir)
  ]
  | group_by([.reason, .dir, (.base_char // "null")])
  | map({
      reason: .[0].reason,
      dir: .[0].dir,
      base_char: (.[0].base_char // "null"),
      count: length
    })
  | sort_by(-.count)
  | (["reason","dir","base_char","count"] | @tsv),
    (.[] | [.reason, .dir, .base_char, (.count|tostring)] | @tsv)
' "$LEDGER"

echo "---"
jq -r --arg reason "$REASON_FILTER" --arg dir "$DIR_FILTER" '
  [ .[] | select($reason == "" or .reason == $reason) | select($dir == "" or .dir == $dir) ] | length
' "$LEDGER" | xargs -I{} echo "TOTAL: {}"
