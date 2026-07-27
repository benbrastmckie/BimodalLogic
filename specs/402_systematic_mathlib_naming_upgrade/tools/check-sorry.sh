#!/usr/bin/env bash
# Assert the repository's live `sorry` invariant across the BUILT tree:
# exactly one, inside `theorem countermodel_discrete` in
# Metalogic/WeakCanonical/Transfer.lean.  Located by CONTENT, never by line
# number (postmortem constraint 6).
#
# Boneyard/ is excluded: it is not imported by any active module and carries
# its own historical sorries, which are outside the invariant.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"
if [ -d FormalSystem ]; then ROOT=FormalSystem; else ROOT=Theories/Bimodal; fi

mapfile -t FILES < <(find "$ROOT" Tests -name '*.lean' -not -path '*/Boneyard/*' | sort)
OUT=$(bash .claude/scripts/lean-sorry-census.sh "${FILES[@]}")
N=$(printf '%s\n' "$OUT" | sed -n 's/^sorry_count: //p')
printf '%s\n' "$OUT"

FILE=$(grep -rl --include='*.lean' 'theorem countermodel_discrete' "$ROOT" | grep -v Boneyard | head -1)
[ -n "$FILE" ] || { echo "FAIL: theorem countermodel_discrete not found" >&2; exit 1; }
echo "countermodel_discrete located in: $FILE"
[ "$N" = "1" ] || { echo "FAIL: expected exactly 1 live sorry outside Boneyard, got $N" >&2; exit 1; }
printf '%s\n' "$OUT" | grep -q 'Transfer\.lean:' \
  || { echo "FAIL: sole live sorry is not in Transfer.lean" >&2; exit 1; }
echo "OK: sorry invariant holds (1 live sorry, in Transfer.lean)"
