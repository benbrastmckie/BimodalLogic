#!/usr/bin/env bash
# check-paper-definitions.sh -- Detect drift between the JPL paper's semantic definitions and
# the pinned record at specs/paper-definitions-of-record.md.
#
# WHY THIS EXISTS: the paper at $PAPER_TEX is READ-ONLY input, edited in a separate repository
# this one cannot see, and it has moved through repeated definitional waves -- twice while a
# dispatch against it was in flight. Every wave silently invalidates task specs that quote the
# paper. This script re-reads the paper and reports drift against the pinned record instead of
# relying on an agent to notice mid-dispatch. See specs/paper-definitions-of-record.md for the
# full rationale, the anchor-extraction method this script implements, and the manifest this
# script parses.
#
# THREE OUTCOMES (distinguished because they carry different costs):
#   (a) paper unchanged (file checksum matches the pinned checksum)      -- silent pass, exit 0
#   (b) paper changed, but every recorded definition block still hashes
#       identical (prose moved elsewhere, no recorded definition did)   -- notice + pass, exit 0
#   (c) at least one recorded definition block changed                  -- FAIL, exit 1
#
# Anchors are resolved by \label{} / \aitem{} name, never by line number, per the manifest in
# the record file -- this is what lets the lint survive the paper's repeated reflowing.
#
# Usage:
#   check-paper-definitions.sh                          # check the live paper on disk
#   check-paper-definitions.sh --against COMMIT          # check the paper AS OF a git commit,
#                                                         #   instead of the live working tree
#                                                         #   (useful for testing this script
#                                                         #   itself against a known-drifted SHA)
#   check-paper-definitions.sh --paper PATH              # override the paper file path
#   check-paper-definitions.sh --record PATH             # override the record file path
#   check-paper-definitions.sh --resolve "ID|KIND|ENCLOSING|LOCATOR" [--against COMMIT]
#                                                         # resolve one ad hoc anchor spec and
#                                                         # print its current text + sha256, to
#                                                         # help add a new manifest row
#   check-paper-definitions.sh -h | --help
#
# Exit codes: 0 = case (a) or (b) [or --resolve succeeded]; 1 = case (c); 2 = usage/setup error.
set -uo pipefail

RECORD_DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/specs/paper-definitions-of-record.md"

PAPER=""
RECORD="$RECORD_DEFAULT"
AGAINST=""
RESOLVE_SPEC=""

while [ $# -gt 0 ]; do
  case "$1" in
    --paper) PAPER="$2"; shift 2 ;;
    --paper=*) PAPER="${1#--paper=}"; shift ;;
    --record) RECORD="$2"; shift 2 ;;
    --record=*) RECORD="${1#--record=}"; shift ;;
    --against) AGAINST="$2"; shift 2 ;;
    --against=*) AGAINST="${1#--against=}"; shift ;;
    --resolve) RESOLVE_SPEC="$2"; shift 2 ;;
    --resolve=*) RESOLVE_SPEC="${1#--resolve=}"; shift ;;
    -h|--help)
      sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "error: unrecognized argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ ! -f "$RECORD" ]; then
  echo "error: record file not found: $RECORD" >&2
  exit 2
fi

# sha256 helper -- prefer sha256sum (coreutils/Linux), fall back to `shasum -a 256` (macOS).
sha256_of_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | cut -d' ' -f1
  else
    echo "error: neither sha256sum nor shasum is available" >&2
    return 2
  fi
}

# --- Parse header fields out of the record (HTML-comment sentinels, see the record's own header) ---
record_field() {
  # $1 = sentinel name, e.g. PAPER_PATH
  grep -oP "<!-- ${1}: \K[^ ]+(?= -->)" "$RECORD" | head -1
}

RECORD_PAPER_PATH="$(record_field PAPER_PATH)"
RECORD_REPO_ROOT="$(record_field PAPER_REPO_ROOT)"
PINNED_COMMIT="$(record_field PINNED_COMMIT)"
PINNED_CHECKSUM="$(record_field FILE_CHECKSUM)"

if [ -z "$PAPER" ]; then
  PAPER="${PAPER_TEX:-$RECORD_PAPER_PATH}"
fi
if [ -z "$PAPER" ]; then
  echo "error: could not determine paper path (pass --paper, set PAPER_TEX, or fix the record's PAPER_PATH sentinel)" >&2
  exit 2
fi
if [ -z "$PINNED_CHECKSUM" ] || [ -z "$PINNED_COMMIT" ]; then
  echo "error: record file is missing required PINNED_COMMIT / FILE_CHECKSUM sentinels: $RECORD" >&2
  exit 2
fi

PAPER_DIR="$(dirname "$PAPER")"
if [ -z "$RECORD_REPO_ROOT" ]; then
  RECORD_REPO_ROOT="$(git -C "$PAPER_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
fi
PAPER_RELPATH=""
if [ -n "$RECORD_REPO_ROOT" ]; then
  PAPER_RELPATH="$(realpath --relative-to="$RECORD_REPO_ROOT" "$PAPER" 2>/dev/null || true)"
fi

# --- Materialize the "current" source: either the live file, or a git-extracted commit blob ---
CLEANUP_TMPS=()
cleanup() { for f in "${CLEANUP_TMPS[@]:-}"; do [ -n "$f" ] && rm -f "$f"; done; }
trap cleanup EXIT

CURRENT_FILE=""
CURRENT_LABEL=""
if [ -n "$AGAINST" ]; then
  if [ -z "$RECORD_REPO_ROOT" ] || [ -z "$PAPER_RELPATH" ]; then
    echo "error: --against requires the paper to live in a git repo with a resolvable relative path" >&2
    exit 2
  fi
  tmpf="$(mktemp)"
  CLEANUP_TMPS+=("$tmpf")
  if ! git -C "$RECORD_REPO_ROOT" show "${AGAINST}:${PAPER_RELPATH}" > "$tmpf" 2>/dev/null; then
    echo "error: could not extract ${PAPER_RELPATH} at commit ${AGAINST}" >&2
    exit 2
  fi
  CURRENT_FILE="$tmpf"
  CURRENT_LABEL="commit ${AGAINST}"
else
  if [ ! -f "$PAPER" ]; then
    echo "error: paper file not found: $PAPER" >&2
    exit 2
  fi
  CURRENT_FILE="$PAPER"
  CURRENT_LABEL="live working tree"
fi

# --- Anchor resolution (must match specs/paper-definitions-of-record.md's "Hashing method") ---
#
# All three resolvers must skip LaTeX comment lines (leading `%`, after optional whitespace) when
# searching for a match. The paper's own editorial convention leaves a `%% OLD: ...` comment
# holding the PREVIOUS text of a line directly above its live replacement, and that previous text
# routinely contains the same "\item[\it NAME:]" or "\aitem{...}" substring being searched for --
# an unfiltered grep -m1 can match the dead `%% OLD:` line instead of the live one below it.

# filter_noncomment_keep_ln -- reads "N:content" lines (grep -n output) on stdin, drops any whose
# content (after the "N:" prefix) starts with optional whitespace then `%`, prints survivors
# unchanged (prefix intact) so callers can still `cut -d: -f1` / `-f2-` afterwards.
filter_noncomment_keep_ln() {
  awk -F: '{ line=$0; sub(/^[0-9]+:/, "", line); if (line !~ /^[ \t]*%/) print $0 }'
}

# resolve_env FILE LABEL -> prints "START END" line range on stdout, or nothing (+ returns 1) if unresolvable.
resolve_env() {
  local file="$1" label="$2" ln begline env endrel endln
  ln=$(grep -nF "\\label{$label}" "$file" | filter_noncomment_keep_ln | head -1 | cut -d: -f1)
  [ -z "$ln" ] && return 1
  begline=$(sed -n "${ln}p" "$file")
  env=$(printf '%s' "$begline" | sed -n 's/.*\\begin{\([A-Za-z]*\)}.*/\1/p')
  [ -z "$env" ] && return 1
  endrel=$(tail -n +"$ln" "$file" | grep -nF "\\end{$env}" | filter_noncomment_keep_ln | head -1 | cut -d: -f1)
  [ -z "$endrel" ] && return 1
  endln=$((ln + endrel - 1))
  echo "$ln $endln"
}

# resolve_text FILE KIND ENCLOSING LOCATOR ANCHOR -> prints resolved verbatim text on stdout,
# or nothing (+ returns 1) if unresolvable.
resolve_text() {
  local file="$1" kind="$2" enclosing="$3" locator="$4" anchor="$5"
  case "$kind" in
    env)
      local range start end
      range=$(resolve_env "$file" "$anchor") || return 1
      start=${range% *}; end=${range#* }
      sed -n "${start},${end}p" "$file"
      ;;
    item)
      # The paper's item markup is NOT stable: the same item has appeared as `\item[\it NAME:]`
      # and, after a 2026-08 editing wave, as `\item[\bf NAME:]`. Keying the resolver on one
      # spelling made four `def:frame#*` sub-anchors go DANGLING on a purely cosmetic change.
      # Resolution is therefore markup-agnostic: try each known emphasis prefix (and the bare
      # form) in turn, first match wins. Matching stays literal (`grep -F`) so a locator
      # containing regex metacharacters cannot be misinterpreted.
      local range start end line body mk
      range=$(resolve_env "$file" "$enclosing") || return 1
      start=${range% *}; end=${range#* }
      body=$(sed -n "${start},${end}p" "$file" | grep -v -E '^[[:space:]]*%')
      line=""
      for mk in '\it ' '\bf ' '\em ' '\itshape ' '\bfseries ' ''; do
        line=$(printf '%s\n' "$body" | grep -F -m1 "\\item[${mk}${locator}:]") || line=""
        [ -n "$line" ] && break
      done
      [ -z "$line" ] && return 1
      printf '%s\n' "$line"
      ;;
    aitem)
      local line
      line=$(grep -nE '\\aitem(\[[A-Za-z0-9-]+\])?\{'"$anchor"'\}' "$file" | filter_noncomment_keep_ln | head -1 | cut -d: -f2-)
      [ -z "$line" ] && return 1
      printf '%s\n' "$line"
      ;;
    *)
      echo "error: unknown anchor kind '$kind'" >&2
      return 1
      ;;
  esac
}

# --- --resolve helper mode: resolve one ad hoc spec against CURRENT_FILE and print text + hash ---
if [ -n "$RESOLVE_SPEC" ]; then
  IFS='|' read -r r_id r_kind r_enc r_loc <<<"$RESOLVE_SPEC"
  [ "$r_enc" = "-" ] && r_enc=""
  [ "$r_loc" = "-" ] && r_loc=""
  text=$(resolve_text "$CURRENT_FILE" "$r_kind" "$r_enc" "$r_loc" "$r_id")
  status=$?
  if [ $status -ne 0 ] || [ -z "$text" ]; then
    echo "could not resolve anchor '$r_id' (kind=$r_kind) against $CURRENT_LABEL" >&2
    exit 2
  fi
  hash=$(printf '%s\n' "$text" | sha256_of_stdin)
  echo "anchor:   $r_id"
  echo "kind:     $r_kind"
  echo "source:   $CURRENT_LABEL ($CURRENT_FILE)"
  echo "sha256:   $hash"
  echo "text:"
  printf '%s\n' "$text" | sed 's/^/  /'
  exit 0
fi

# --- Fast path: file checksum comparison (only meaningful for the live-file mode) ---
if [ -z "$AGAINST" ]; then
  CURRENT_CHECKSUM=$(sha256_of_stdin < "$CURRENT_FILE")
  if [ "$CURRENT_CHECKSUM" = "$PINNED_CHECKSUM" ]; then
    # Case (a): paper unchanged -- silent pass.
    exit 0
  fi
fi

# --- Parse the machine-readable manifest out of the record ---
MANIFEST_ROWS=$(sed -n '/<!-- MANIFEST:BEGIN -->/,/<!-- MANIFEST:END -->/p' "$RECORD" \
  | grep -v '<!--' | grep -v '^```' | grep -v '^#' | grep -v '^[[:space:]]*$')

if [ -z "$MANIFEST_ROWS" ]; then
  echo "error: no manifest rows found between MANIFEST:BEGIN/END sentinels in $RECORD" >&2
  exit 2
fi

# --- Pinned-text recovery from the record itself (authoritative) --------------
# On drift we want to show the operator what the RECORD pinned, not merely what some
# commit happens to contain. These can differ: the record is pinned by file checksum
# and may have been recorded from a dirty working tree, in which case the base commit's
# blob is a third, unrelated version. Printing the base-commit text under an "OLD
# (pinned @ ...)" label made a correct drift report look like a false positive whenever
# the base commit and the compared commit agreed with each other but not with the pin.
#
# The record stores pinned text in two shapes: a fenced ```latex block followed by a
# `sha256: <hash>` line (byte-exact), and a markdown table cell (whitespace-normalized
# for display, so NOT byte-exact and deliberately not recovered here). Rather than
# trusting layout, the candidate is re-hashed and returned only if it reproduces the
# recorded hash -- so this can never print text that merely looks like the pinned text.
#
# pinned_text_from_record EXPECTED_HASH -> prints verified pinned text, or returns 1.
pinned_text_from_record() {
  local expected="$1" cand
  [ -n "$expected" ] || return 1
  [ -f "$RECORD" ] || return 1

  cand=$(awk -v want="$expected" '
    /^```/ { if (infence) { infence = 0; blk = buf } else { infence = 1; buf = "" } ; next }
    infence { buf = buf $0 "\n" ; next }
    index($0, want) && /sha256/ { printf "%s", blk; exit }
  ' "$RECORD")

  [ -n "$cand" ] || return 1
  [ "$(printf '%s\n' "$cand" | sha256_of_stdin)" = "$expected" ] || return 1
  printf '%s' "$cand"
}

DRIFTED=()
MISSING=()
DRIFT_DETAIL=""

while IFS='|' read -r anchor kind enclosing locator expected_hash; do
  [ -z "$anchor" ] && continue
  [ "$enclosing" = "-" ] && enclosing=""
  [ "$locator" = "-" ] && locator=""

  new_text=$(resolve_text "$CURRENT_FILE" "$kind" "$enclosing" "$locator" "$anchor")
  if [ -z "$new_text" ]; then
    MISSING+=("$anchor")
    continue
  fi
  new_hash=$(printf '%s\n' "$new_text" | sha256_of_stdin)

  if [ "$new_hash" != "$expected_hash" ]; then
    DRIFTED+=("$anchor")

    # Recover the OLD text for a human-readable diff. Preference order matters:
    #   1. the record's own pinned text, verified by re-hash (authoritative);
    #   2. the base commit's text, which is NOT the pin and is labelled as such.
    old_text=""
    old_label=""
    old_text=$(pinned_text_from_record "$expected_hash" || true)
    if [ -n "$old_text" ]; then
      old_label="OLD (pinned text from ${RECORD}, sha256 ${expected_hash} -- verified):"
    else
      if [ -n "$RECORD_REPO_ROOT" ] && [ -n "$PAPER_RELPATH" ]; then
        old_tmp="$(mktemp)"
        CLEANUP_TMPS+=("$old_tmp")
        if git -C "$RECORD_REPO_ROOT" show "${PINNED_COMMIT}:${PAPER_RELPATH}" > "$old_tmp" 2>/dev/null; then
          old_text=$(resolve_text "$old_tmp" "$kind" "$enclosing" "$locator" "$anchor" || true)
        fi
      fi
      if [ -n "$old_text" ]; then
        old_base_hash=$(printf '%s\n' "$old_text" | sha256_of_stdin)
        if [ "$old_base_hash" = "$expected_hash" ]; then
          old_label="OLD (base commit ${PINNED_COMMIT}, sha256 ${expected_hash} -- matches the record's pin):"
        else
          old_label="OLD (re-extracted from base commit ${PINNED_COMMIT}, sha256 ${old_base_hash}):
  WARNING: this is NOT the record's pinned text (pinned sha256 ${expected_hash}). The record
  is pinned by file checksum and may have been recorded from a working tree differing from
  this commit, so the block below can be identical to NEW even though the anchor really did
  drift from the pin. The hashes above, not this text, are the authoritative comparison."
        fi
      fi
    fi

    DRIFT_DETAIL+="--- anchor: ${anchor} ---
"
    if [ -n "$old_text" ]; then
      DRIFT_DETAIL+="${old_label}
$(printf '%s\n' "$old_text" | sed 's/^/  /')
"
    else
      DRIFT_DETAIL+="OLD: (could not retrieve pinned text -- see recorded sha256 ${expected_hash} in $RECORD)
"
    fi
    DRIFT_DETAIL+="NEW (${CURRENT_LABEL}, sha256 ${new_hash}):
$(printf '%s\n' "$new_text" | sed 's/^/  /')
"
  fi
done <<<"$MANIFEST_ROWS"

if [ ${#DRIFTED[@]} -eq 0 ] && [ ${#MISSING[@]} -eq 0 ]; then
  # Case (b): paper changed, but every recorded definition still hashes identical.
  new_sha=""
  if [ -z "$AGAINST" ]; then
    new_sha=$(git -C "${RECORD_REPO_ROOT:-$PAPER_DIR}" log -1 --format=%H -- "${PAPER_RELPATH:-$PAPER}" 2>/dev/null || echo "unknown")
  else
    new_sha="$AGAINST"
  fi
  new_checksum=$(sha256_of_stdin < "$CURRENT_FILE")
  echo "[paper-definitions] notice: $(basename "$PAPER") changed (source: ${CURRENT_LABEL}, new checksum ${new_checksum}, last-touching commit ${new_sha}) but all $(printf '%s\n' "$MANIFEST_ROWS" | grep -c .) recorded definitions are unchanged -- pass."
  exit 0
fi

# Case (c) and/or dangling anchors: FAIL.
{
  echo "[paper-definitions] FAIL: drift detected against $RECORD"
  echo "  source checked: ${CURRENT_LABEL} (${PAPER})"
  if [ ${#DRIFTED[@]} -gt 0 ]; then
    echo ""
    echo "  ${#DRIFTED[@]} recorded definition(s) drifted:"
    printf '%s\n' "$DRIFT_DETAIL"
  fi
  if [ ${#MISSING[@]} -gt 0 ]; then
    echo "  ${#MISSING[@]} recorded anchor(s) could not be resolved (dangling \\label/\\aitem, or the environment/item structure changed):"
    for m in "${MISSING[@]}"; do
      echo "    - $m"
    done
  fi
} >&2

exit 1
