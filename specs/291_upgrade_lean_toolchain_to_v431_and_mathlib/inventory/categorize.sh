#!/usr/bin/env bash
# Classify lake build errors against the breakage taxonomy in
# reports/01_lean-toolchain-upgrade-431.md section 5.
#
#   Usage: bash categorize.sh <build.log>
#
# Emits one TSV row per error: file<TAB>line<TAB>category<TAB>error-text
# Category labels are exactly those fixed by the plan's Phase 3 task list.
set -u
LOG="${1:?usage: categorize.sh <build.log>}"

# Lean error lines look like:  error: path/File.lean:LINE:COL: message
# Some are emitted as a bare "path:line:col: error: message" instead.
grep -oE '^(error: )?[^ ]+\.lean:[0-9]+:[0-9]+: (error: )?.*' "$LOG" \
| sed 's/^error: //' \
| while IFS= read -r line; do
    loc="${line%%: *}"
    file="${loc%%:*}"
    rest="${loc#*:}"
    lineno="${rest%%:*}"
    msg="${line#*: }"
    msg="${msg#error: }"

    lower=$(printf '%s' "$msg" | tr '[:upper:]' '[:lower:]')
    case "$lower" in
      *"(deterministic) timeout"*|*"maximum recursion depth"*|*"maxheartbeats"*)
        cat=heartbeat-timeout ;;
      *"unknown tag"*|*"no goals with tag"*|*"invalid 'case'"*|*"tag not found"*)
        cat=subgoal-tags ;;
      *"noncomputable"*|*"compiler ipo"*|*"failed to compile definition"*)
        cat=noncomputable ;;
      *"dsimp made no progress"*|*"simp made no progress"*)
        cat=dsimp-no-progress ;;
      *"std.range"*|*"invalid field notation"*[\[]*|*"expected ']'"*|*"deprecated: use"*"..."*)
        cat=range-syntax ;;
      *"simp"*"instance"*|*"failed to synthesize"*"instance"*)
        cat=simp-instances ;;
      *"native_decide"*|*"ofreducebool"*|*"lean.trustcompiler"*)
        cat=native-decide-axioms ;;
      *"do"*"pure"*|*"unexpected 'return'"*|*"invalid 'do'"*|*"invalid 'return'"*)
        cat=do-elaborator ;;
      *"isstructurelike"*|*"compiledecl"*|*"addandcompile"*|*"unknown constant 'lean."*|*"unknown identifier 'lean."*)
        cat=meta-api-renames ;;
      *"type mismatch"*|*"is not definitionally equal"*|*"motive is not type correct"*|*"the rfl"*|*"failed to unify"*|*"definitional"*|*"inferinstanceas"*|*"simpa"*)
        cat=defeq-transparency ;;
      *)
        cat=unattributable ;;
    esac
    printf '%s\t%s\t%s\t%s\n' "$file" "$lineno" "$cat" "$msg"
  done
