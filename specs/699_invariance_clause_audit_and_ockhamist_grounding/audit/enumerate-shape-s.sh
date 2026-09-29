#!/usr/bin/env bash
# Re-runnable three-pass Shape-(S) enumeration for task 699's clause-shape audit.
#
# Shape (S): a predicate definition containing a subterm `forall x, R a x -> (P <-> Psi(x))` in
# which `R` is reflexive at the relevant argument and `P` does not mention `x`. This script does
# not itself decide Shape (S) membership -- that judgement is made by hand, per candidate, in
# the report's audit table. It reproduces the three enumeration passes the report's Appendix
# describes, against the current tree, so a future reader can re-run the count instead of
# trusting a dated snapshot.
#
# Read-only: performs no write, no `git` invocation and no `lake` invocation.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: enumerate-shape-s.sh [--help]

Three-pass Shape-(S) enumeration over FormalSystem/Metalogic/**/*.lean:

  Pass 1 (candidates): every def/abbrev/structure/class whose body contains `<->` (the Lean
    source character U+2194, written literally below).
  Pass 2 (share-guarded quantifiers): lines combining a universal quantifier and `share`.
  Pass 3 (reflexive relations): `_refl` lemma names, `@[refl]` attributes, and `Reflexive`.

Each pass prints its `path:line` hits, sorted, one per line, followed by a trailing
`# count: N` line. Run this script from the repository root.

Options:
  --help    Print this usage and exit 0.
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

root_dir="FormalSystem/Metalogic"
if [[ ! -d "$root_dir" ]]; then
  echo "error: expected to be run from the repository root (missing $root_dir)" >&2
  exit 1
fi

echo "=== Pass 1: candidate definitions (def/abbrev/structure/class whose body contains <->) ==="
pass1_hits="$(
  find "$root_dir" -name '*.lean' -print0 \
    | sort -z \
    | while IFS= read -r -d '' f; do
        awk -v F="$f" '
          /^def |^abbrev |^structure |^class |^  def / { indef=1; buf=$0"\n"; ln=NR; next }
          indef==1 {
            buf=buf $0"\n"
            if ($0 ~ /^$/) {
              if (buf ~ /↔/) printf "%s:%d\n", F, ln
              indef=0; buf=""
            }
          }
        ' "$f"
      done | sort -u
)"
if [[ -n "$pass1_hits" ]]; then
  printf '%s\n' "$pass1_hits"
fi
pass1_count=$(printf '%s\n' "$pass1_hits" | grep -c . || true)
pass1_files=$(printf '%s\n' "$pass1_hits" | sed 's/:[0-9]*$//' | sort -u | grep -c . || true)
echo "# count: ${pass1_count} candidate definitions across ${pass1_files} files"

echo
echo "=== Pass 2: share-guarded quantifiers ==="
pass2_hits="$(grep -rn "share" "$root_dir" --include='*.lean' 2>/dev/null \
  | grep -E "∀.*share|share.*→" | sort -u || true)"
if [[ -n "$pass2_hits" ]]; then
  printf '%s\n' "$pass2_hits"
fi
pass2_count=$(printf '%s\n' "$pass2_hits" | grep -c . || true)
echo "# count: ${pass2_count} share-guarded quantifier hits"

echo
echo "=== Pass 3: reflexive relations (_refl lemma names, @[refl], Reflexive) ==="
pass3_hits="$(grep -rnE '^theorem .*_refl\b|^@\[refl\]|Reflexive' "$root_dir" --include='*.lean' 2>/dev/null \
  | sort -u || true)"
if [[ -n "$pass3_hits" ]]; then
  printf '%s\n' "$pass3_hits"
fi
pass3_count=$(printf '%s\n' "$pass3_hits" | grep -c . || true)
echo "# count: ${pass3_count} reflexive-relation hits"

exit 0
