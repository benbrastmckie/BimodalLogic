#!/usr/bin/env bash
# check-phantom-citations.sh -- Sweep backticked declaration-shaped names out of live task
# descriptions, docs/, and specs/ROADMAP.md, and report any with zero definition sites in
# FormalSystem/.
#
# WHY THIS EXISTS. A single revision round of this repository's task records found eleven
# phantom declaration citations -- names asserted as established fact, with file paths and
# sometimes line numbers attached, that do not exist anywhere in the tree -- spread across
# several task records. The defect is systemic: a name gets inherited from a predecessor's text
# rather than re-checked, so a citation that was wrong once stays wrong and propagates through
# every later revision that quotes it. A one-off hand repair leaves the mechanism that produced
# the defect intact. This script is that mechanism's repair: a re-runnable check, not a
# point-in-time correction. See the phantom-declaration-citation sweep's own research report
# (filed alongside this script) for the worked set of instances that motivated it.
#
# OWNERSHIP. This is the repository's ONE phantom-declaration-citation checker. The decidability-
# programme re-runnable-inventory effort considered building its own equivalent and explicitly
# deferred to this one instead -- see that record's own text, which names this exact mechanism as
# owned elsewhere and says not to duplicate it. Extend this script rather than writing a second
# one.
#
# WHAT IT CHECKS. Backtick-delimited spans that look like a Lean declaration name (a dotted
# qualified path, or a single identifier containing an underscore or internal capitalisation --
# see CANDIDATE SHAPE below) are extracted from:
#   - specs/state.json's active_projects[].description (every LIVE, i.e. non-archived, task
#     record -- archived tasks are historical and out of scope, same as reports/ and summaries/)
#   - docs/**/*.md
#   - specs/ROADMAP.md
# For each distinct candidate, the LAST dot-segment (the bare declaration name a Lean
# `theorem`/`def`/... line would actually carry, since namespaces are opened separately from the
# declaration keyword) is searched for as a definition site anywhere under FormalSystem/**/*.lean.
# A candidate with zero definition sites is reported as a phantom-citation FINDING, together with
# every (source file, line) it was cited from.
#
# CANDIDATE SHAPE (to cut noise -- plain prose words are backticked constantly in this repo's
# task descriptions and MUST NOT flood the report). A backticked span qualifies only if it:
#   - contains no whitespace, `/`, `(`, `)`, `:`, `,`, or `--` (rules out file paths, shell
#     invocations, flag lists, and prose fragments quoted verbatim), AND
#   - does not end in a known non-Lean file extension (.lean/.md/.json/.sh/.toml/.txt/.typ/.tex/
#     .yml/.yaml/.bib/.cff/.nix/.csv/.cfg/.ini), AND is not a bare version string (`v1.0.0`), AND
#   - either contains a `.` (a qualified path, e.g. `Foo.Bar.baz`), or contains `_` (snake_case,
#     the repo's lemma-naming convention), or has an internal uppercase letter not at position 0
#     that is preceded by a lowercase letter (camelCase, e.g. `verifyProof`), AND
#   - its SOURCE LINE also contains a Lean-proof-engineering signal (see LEAN_CONTEXT_RE below) --
#     this is what keeps a bash variable, a JSON field, or a CLI flag mentioned in `docs/`'s
#     installation/development/user-guide prose from being mistaken for a declaration citation,
#     since those shapes are genuinely indistinguishable from a snake_case Lean lemma name on
#     shape alone, AND
#   - its first dotted segment (or the whole span, if undotted) is not a known Lean-core/Mathlib/
#     metaprogramming namespace root (see ROOT_DENYLIST below) -- those are real declarations,
#     just not ones this repository defines, so "zero definition sites in FormalSystem/" is
#     trivially true of them and would otherwise be a wall of guaranteed false positives.
# This is a heuristic, not a parser, and is documented as such: it will both under- and
# over-approximate the true set of declaration citations. See LIMITATIONS below.
#
# MATHLIB / LEAN-CORE ALLOWLIST. Names this repository legitimately cites but does not itself
# define (`propext`, `Classical.choice`, `Quot.sound`, core type formers like `Prop`/`Nat`/`Bool`/
# `List`/`Set`/`Decidable`, and so on) would otherwise report as false positives, since "zero
# definition sites in FormalSystem/" is trivially true of them. These are skipped via the
# ALLOWLIST array below (extend it, rather than suppressing a specific finding, when a new one
# surfaces) and via an allowlist file at --allowlist (default: none beyond the built-in array).
#
# LIMITATIONS (read before trusting a clean run as proof of absence of the defect).
#   - Bare-name matching, not qualified-path matching: a candidate `Foo.Bar.baz` is cleared by
#     ANY declaration named `baz` anywhere in FormalSystem/, even in an unrelated namespace. This
#     means a same-named-but-wrong-namespace citation is a FALSE NEGATIVE this script will not
#     catch. It narrows the search space for a human, it does not replace one.
#   - This checks DEFINITION sites only, not whether a cited TYPE SIGNATURE or FILE/LINE anchor
#     attached to the name is itself accurate (the "misattributed anchor" class of defect, e.g. a
#     correct name cited to the wrong file or a stale line number). That class needs its own,
#     separate mechanism; this script's scope is existence, not attribution accuracy.
#   - Dead FILE/PATH anchors (a citation of a real artifact that has since moved, e.g. under
#     specs/archive/) are a related but DIFFERENT defect this script does not check -- it looks
#     only at backticked Lean-identifier-shaped spans, never at path-shaped ones.
#   - `definition_exists` recognizes `theorem`/`lemma`/`def`/.../`axiom` keyword lines (with or
#     without a dotted qualifier before the bare name), `inductive`/`structure` constructor or
#     field lines introduced with `|`, `namespace`/`end` lines, module directories/files, and
#     `macro`/`elab`/`syntax`/`notation` tactic declarations. It does NOT recognize a plain
#     `structure ... where` FIELD line (`  fieldName : Type`, no `|` and no keyword of its own) --
#     deliberately: that shape is indistinguishable from an ordinary local-variable type
#     ascription without actually parsing the enclosing `structure` block, and a general field
#     detector would trade this script's existing false positives for a worse flood of false
#     negatives. A bare field name confirmed live by hand belongs in ALLOWLIST with a comment
#     saying so, not in a structural fix here.
#
# Usage:
#   bash scripts/check-phantom-citations.sh                 # report (always exits 0: advisory)
#   bash scripts/check-phantom-citations.sh --strict         # exit 1 if any finding remains
#   bash scripts/check-phantom-citations.sh --allowlist PATH # extra allowlisted bare names, one
#                                                             #   per line, merged with the
#                                                             #   built-in ALLOWLIST array
#   bash scripts/check-phantom-citations.sh --verbose        # print every citation site per
#                                                             #   finding, not just the count
#
# Exit status: 0 normally (this is an advisory lead-generator, like the file_scope checks in
#   validate-state.sh); 1 under --strict if any finding remains; 2 on a usage/setup error.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="$ROOT/specs/state.json"
DOCS_DIR="$ROOT/docs"
ROADMAP="$ROOT/specs/ROADMAP.md"
SOURCE_DIR="$ROOT/FormalSystem"

STRICT=0
VERBOSE=0
EXTRA_ALLOWLIST=""

while [ $# -gt 0 ]; do
  case "$1" in
    --strict) STRICT=1; shift ;;
    --verbose) VERBOSE=1; shift ;;
    --allowlist) EXTRA_ALLOWLIST="$2"; shift 2 ;;
    --allowlist=*) EXTRA_ALLOWLIST="${1#--allowlist=}"; shift ;;
    -h|--help)
      sed -n '2,70p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [ ! -f "$STATE_FILE" ]; then
  echo "FAIL (setup): state file not found at $STATE_FILE" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "FAIL (setup): jq is required" >&2
  exit 2
fi

# --- Built-in allowlist: Lean-core / Mathlib names legitimately cited but not defined here ------
ALLOWLIST=(
  propext Classical.choice Quot.sound sorryAx
  Prop Type Nat Int Bool List Set Option String Decidable DecidablePred Decidable.decide
  Nonempty Subtype Finset Finite Set.Finite WellFounded Classical BddAbove
  Iff.rfl Eq.refl Eq.mpr id_rfl
)

# --- Namespace roots that are real declarations, just never defined in FormalSystem/ ------------
# Matched against the span's FIRST dotted segment (or the whole span, if it has no dot).
# Includes Lake build-config keywords (`lean_exe`/`lean_lib`, lakefile.toml stanzas) and Lean
# compiler/linter option roots (`linter.*`, `synthInstance.*`, `weak.linter.*`) alongside the
# Lean-core/Mathlib/metaprogramming namespaces -- none of these are FormalSystem declarations,
# and all three classes showed up as false positives before this list was added.
ROOT_DENYLIST=(
  Lean Mathlib Tactic Elab Meta Expr Syntax MVarId Std Qq IO System Array
  Classical Nat Int List Option String Bool Prop Type Set Order
  linter synthInstance weak lean_exe lean_lib
)

is_denylisted_root() {
  local span="$1" root a
  root="${span%%.*}"
  for a in "${ROOT_DENYLIST[@]}"; do
    [ "$a" = "$root" ] && return 0
  done
  return 1
}

# --- Line-level gate: a candidate only counts if its OWN source line reads as proof-engineering
# prose, not bash/JSON/CLI prose. Without this gate, a snake_case bash variable or JSON field
# (e.g. `active_projects`, `BIMODAL_LOGIC_PATH`) is indistinguishable by shape alone from a
# genuine Lean lemma name, and docs/ is heterogeneous enough (installation, development process,
# architecture, user guides) that shape-only filtering floods the report. This is still a
# heuristic, not a parser: a true citation on a context-free line is a FALSE NEGATIVE this gate
# will suppress, and conversely a false-positive-shaped word next to "theorem" elsewhere on the
# same line survives as a FALSE POSITIVE. See LIMITATIONS in the header.
LEAN_CONTEXT_RE='\.lean\b|\btheorem\b|\blemma\b|\baxiom\b|\bDerivable\b|\bsorry\b|\bFormalSystem\b|\bDecidable\b|#print|#check|\bdeclaration\b|\bFrameClass\b|\bvalid\b|\bValid'

if [ -n "$EXTRA_ALLOWLIST" ]; then
  if [ ! -f "$EXTRA_ALLOWLIST" ]; then
    echo "FAIL (setup): --allowlist file not found at $EXTRA_ALLOWLIST" >&2
    exit 2
  fi
  while IFS= read -r line; do
    [ -n "$line" ] && ALLOWLIST+=("$line")
  done < "$EXTRA_ALLOWLIST"
fi

is_allowlisted() {
  local name="$1" a
  for a in "${ALLOWLIST[@]}"; do
    [ "$a" = "$name" ] && return 0
  done
  return 1
}

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

CORPUS="$WORKDIR/corpus.txt"
: > "$CORPUS"

# --- Gather source text: live (non-archived) task descriptions, docs/, ROADMAP.md --------------
# Each line emitted as "SOURCE_LABEL<TAB>TEXT" so a later citation-site report can name its origin.
jq -r '
  .active_projects[] |
  "specs/state.json#project_" + (.project_number|tostring) + "\t" + (.description // "")
' "$STATE_FILE" >> "$CORPUS"

if [ -d "$DOCS_DIR" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$ROOT"/}"
    awk -v label="$rel" '{ print label "\t" $0 }' "$f" >> "$CORPUS"
  done < <(find "$DOCS_DIR" -type f -name '*.md' -print0 | sort -z)
fi

if [ -f "$ROADMAP" ]; then
  awk -v label="specs/ROADMAP.md" '{ print label "\t" $0 }' "$ROADMAP" >> "$CORPUS"
fi

# --- Extract candidates: backtick spans matching the CANDIDATE SHAPE rule ------------------------
# Step 1: every backtick span on a Lean-context line, tagged with its source line.
RAW_SPANS="$WORKDIR/raw_spans.tsv"
: > "$RAW_SPANS"
while IFS=$'\t' read -r label text; do
  [ -z "$text" ] && continue
  printf '%s' "$text" | grep -qP "$LEAN_CONTEXT_RE" || continue
  printf '%s\n' "$text" | grep -oP '`\K[\p{L}_][\p{L}\p{N}_'"'"'.]*(?=`)' 2>/dev/null \
    | while IFS= read -r span; do
        printf '%s\t%s\n' "$label" "$span"
      done
done < "$CORPUS" >> "$RAW_SPANS"

# Step 2: filter to the CANDIDATE SHAPE (dot, OR underscore, OR internal camelCase), minus the
# extension/version/namespace-root denylists. The whitespace/`/`/`(`/`)`/`:`/`,`/`--` exclusions
# are already enforced by the extraction regex (none of those characters are in the character
# class), so only the extension, version, shape, and root filters remain here.
CANDIDATES="$WORKDIR/candidates.tsv"
: > "$CANDIDATES"
while IFS=$'\t' read -r label span; do
  case "$span" in
    *.lean|*.md|*.json|*.sh|*.toml|*.txt|*.typ|*.tex|*.yml|*.yaml|*.bib|*.cff|*.nix|*.csv|*.cfg|*.ini) continue ;;
  esac
  if printf '%s' "$span" | grep -qP '^v?[0-9]+(\.[0-9]+)*$'; then
    continue
  fi
  is_denylisted_root "$span" && continue
  shape_ok=0
  case "$span" in
    *.*) shape_ok=1 ;;
    *_*) shape_ok=1 ;;
  esac
  if [ "$shape_ok" -eq 0 ]; then
    # camelCase test: an uppercase letter not at position 0, immediately preceded by a lowercase
    # letter (ASCII only -- sufficient for this repo's naming convention; a Greek-letter-only
    # span like a bare capital Phi has no underscore/dot and will correctly fail every shape
    # test here, which is fine -- that shape is never this repo's declaration-naming style).
    if printf '%s' "$span" | grep -qP '(?<=[a-z])[A-Z]'; then
      shape_ok=1
    fi
  fi
  [ "$shape_ok" -eq 1 ] || continue
  printf '%s\t%s\n' "$label" "$span" >> "$CANDIDATES"
done < "$RAW_SPANS"

if [ ! -s "$CANDIDATES" ]; then
  echo "Phantom declaration citation check"
  echo "==================================="
  echo "PASS: no candidate declaration-shaped citations found."
  exit 0
fi

# --- Group by bare (last-dot-segment) name, collecting distinct source labels -------------------
BARE_MAP="$WORKDIR/bare_map.tsv"
awk -F'\t' '{
  span=$2; bare=span;
  n = split(span, parts, ".");
  if (n > 1) bare = parts[n];
  print bare "\t" span "\t" $1;
}' "$CANDIDATES" | sort -u > "$BARE_MAP"

DEFINED_CACHE="$WORKDIR/defined_cache.tsv"
: > "$DEFINED_CACHE"

definition_exists() {
  local bare="$1"
  local hit
  # Exact-match lookup (awk field 1), NOT `grep "$bare" file` -- a substring grep here would
  # false-hit on any OTHER cached bare name that merely contains this one as a substring (e.g.
  # a cached `not_plusValidZTime_neg_Phi -> no` line also matches a later lookup for the
  # substring `ValidZTime`), corrupting the cache with unrelated results.
  hit=$(awk -F'\t' -v b="$bare" '$1 == b { print $2; exit }' "$DEFINED_CACHE" 2>/dev/null)
  if [ -n "$hit" ]; then
    [ "$hit" = "yes" ] && return 0 || return 1
  fi
  # Primary: a standard declaration keyword line. Fallback 1: an `inductive`/`structure`
  # constructor or field line (`  | Name`), which carries no keyword of its own -- FrameClass's
  # own constructors (Base/Dense/ZTime/RTime) are exactly this shape. Fallback 2: a namespace or
  # a module/aggregator file or directory of this name (`FormalSystem.Metalogic.BXCanonical` is
  # cited constantly as a MODULE, not a theorem, and has no declaration line to match at all).
  #
  # Two deliberate departures from a plain `\b`-delimited bare-name match, both found by hand
  # during a manual triage of this checker's own findings against confirmed-live declarations it
  # was misreporting as phantom:
  #   - `(\S+\.)?` before the bare name in the keyword branch, mirroring the namespace/end
  #     branch below. This codebase writes many declarations as `def Prefix.bare ... :=` with no
  #     surrounding `namespace Prefix ... end` block (e.g. `def TaskFrame.ValidOn`, `def
  #     Axiom.minFrameClass`, `theorem HasAttainedSUP.toHasFaithfulDedekindSUP`) -- the namespace
  #     branch already anticipated this citation shape; the keyword branch, which is the common
  #     case, had not.
  #   - `(?![A-Za-z0-9_'])` in place of a trailing `\b` after the bare name. PCRE `\b` only fires
  #     at a transition between a word character and a non-word character; a Lean identifier
  #     ending in a prime (`'`, a non-word character, e.g. `no_finite_carrier_sat'`) followed by
  #     whitespace (also non-word) crosses no such transition, so `\b` never matches and a
  #     genuinely live primed declaration is reported as absent. The negative lookahead says
  #     directly what is actually meant: the next character must not continue the identifier.
  #     This cuts the other way too: a trailing `\b` after an UNPRIMED bare name (e.g.
  #     `trans_refl`) also matches a PRIMED declaration of a different name (`trans_refl'`),
  #     since "word char" -> "prime" is itself a `\b` transition -- the old pattern silently
  #     treated two distinct Lean identifiers as the same name. The lookahead fixes this too.
  #
  # Fallback 3: a `macro`/`elab`/`syntax`/`notation` tactic or term-syntax declaration (e.g.
  # `macro "apply_axiom" : tactic =>`, `elab "assumption_search" : tactic => do`, `syntax
  # "modal_search" (num)? : tactic`). This repository's Automation/Tactics layer declares several
  # user-facing tactics this way rather than as a `def`/`theorem`, so without this fallback a
  # genuinely live, implemented tactic name is reported as absent.
  if grep -rqP "^\s*(@\[[^]]*\]\s*)?(private\s+|protected\s+|noncomputable\s+)*(theorem|lemma|def|abbrev|instance|structure|inductive|class|axiom)\s+(\S+\.)?${bare}(?![A-Za-z0-9_'])" \
       --include='*.lean' "$SOURCE_DIR" 2>/dev/null \
     || grep -rqP "^\s*\|\s*${bare}(?![A-Za-z0-9_'])" --include='*.lean' "$SOURCE_DIR" 2>/dev/null \
     || grep -rqP "^\s*(namespace|end)\s+(\S+\.)?${bare}(?![A-Za-z0-9_'])" --include='*.lean' "$SOURCE_DIR" 2>/dev/null \
     || grep -rqP "^\s*(macro|elab|syntax|notation)(_rules)?\s+(\(\s*[^)]*\)\s*)?\"${bare}\"" \
          --include='*.lean' "$SOURCE_DIR" 2>/dev/null \
     || [ -d "$SOURCE_DIR/$bare" ] || find "$SOURCE_DIR" -type d -name "$bare" 2>/dev/null | grep -q . \
     || find "$SOURCE_DIR" -type f -name "${bare}.lean" 2>/dev/null | grep -q .; then
    printf '%s\tyes\n' "$bare" >> "$DEFINED_CACHE"
    return 0
  else
    printf '%s\tno\n' "$bare" >> "$DEFINED_CACHE"
    return 1
  fi
}

echo "Phantom declaration citation check"
echo "==================================="
echo "Scanned: specs/state.json (live task descriptions), docs/**/*.md, specs/ROADMAP.md"
echo "Definition search root: FormalSystem/**/*.lean"
echo ""

findings=0
total_candidates=0
declare -A SEEN_BARE

while IFS=$'\t' read -r bare span label; do
  [ -z "$bare" ] && continue
  total_candidates=$((total_candidates + 1))
  if is_allowlisted "$bare" || is_allowlisted "$span"; then
    continue
  fi
  if definition_exists "$bare"; then
    continue
  fi
  key="$span"
  if [ -z "${SEEN_BARE[$key]+x}" ]; then
    SEEN_BARE[$key]=1
    findings=$((findings + 1))
    sites=$(awk -F'\t' -v s="$span" '$2 == s { print $3 }' "$BARE_MAP" | sort -u)
    site_count=$(printf '%s\n' "$sites" | grep -c .)
    printf 'FINDING: `%s` -- zero definition sites for bare name `%s` in FormalSystem/ (%s site%s)\n' \
      "$span" "$bare" "$site_count" "$([ "$site_count" = 1 ] && echo "" || echo "s")"
    if [ "$VERBOSE" -eq 1 ]; then
      printf '%s\n' "$sites" | sed 's/^/    - /'
    fi
  fi
done < "$BARE_MAP"

echo ""
echo "Candidates examined: $total_candidates distinct (source-label, span) pairs"
echo "Findings: $findings distinct phantom-citation candidate(s)"

if [ "$findings" -gt 0 ]; then
  echo ""
  echo "Each finding needs human triage (see LIMITATIONS in this script's header): confirm the"
  echo "name is genuinely absent (not just differently namespaced), then repair at the citing"
  echo "source -- strike it, restate it as absent, or correct it to the live declaration it was"
  echo "reaching for. Do not edit specs/*/reports/ or specs/*/summaries/ (historical artifacts)."
  if [ "$STRICT" -eq 1 ]; then
    exit 1
  fi
fi

exit 0
