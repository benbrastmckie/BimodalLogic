#!/usr/bin/env bash
#
# Reproduce every figure in docs/development/proof-mode-cost-baseline.md, by one command.
#
# WHAT THIS RUNS.  One `lake env lean` elaboration of
# `specs/evidence/proof-mode-cost-baseline/cost-probe.lean`, which emits one diagnostics record
# per measured script: 48 acceptance-script mirrors, the `lintro` ladder at depth 1-16, the nested
# logical rewrite at 0-4 scopes, two simplifier rows and two views rows -- 73 records.  The
# records are collected into `data/proof-mode-diagnostics.jsonl` with a `*_metadata.json` sidecar,
# matching the dataset idiom the other members of `data/` already use.
#
# STALENESS IS THE FIRST THING CHECKED, NOT THE LAST.  A figure measured against different code is
# worse than no figure, because it looks like a measurement.  The baseline document pins the
# commit of the MEASURED SURFACE -- the proof mode's elaborators and rules, the diagnostics
# library, and the probe itself -- and this script's first action compares that pin against the
# surface's current head.  On a mismatch it reports a stale baseline and exits non-zero without
# measuring anything.  The surface deliberately excludes this script, the document, and the
# collected dataset: a change to how the figures are REPORTED does not invalidate them, while a
# change to what is MEASURED does.
#
# THE STAMP ROUTE IN USE.  Commit, date and command reach the records as registered string options
# read by the emitters, injected by `lake env lean -Ddiagnostics.commit=...`.  The tracked probe
# therefore carries no stamp of its own, which is what the `--json` zeroed-stamp determinism
# contract below wants anyway.  The fallback route the plan for this work allowed -- writing stamp
# lines into a scratch copy of the probe -- is NOT in use and is not implemented, because `-D`
# carries a string option without complaint.
#
# DETERMINISM CONTRACT.  Two `--json` runs from the same commit on the same UTC day produce
# byte-identical output.  `--json` zeroes the stamp fields and the two timing fields, which are the
# only parts of a record that are not a function of the commit and the toolchain, and sorts the
# records by their key.  `cmp` on two runs is the contract itself rather than a restatement of it.
#
# NEVER BARE `lake`.  The build goes through `.claude/scripts/lake-build-guard.sh` when it is
# present, and the probe run holds the same `.lake/build-guard.lock` the guard uses, taken once
# and held to exit, so no concurrent build competes for cores while a wall-clock figure is taken.
#
# Usage:
#   scripts/proof-mode-cost-baseline.sh                        # measure, write the dataset
#   scripts/proof-mode-cost-baseline.sh --json                 # build-free, zeroed, to stdout
#   scripts/proof-mode-cost-baseline.sh --pin <sha>            # set the pin (first run only)
#   scripts/proof-mode-cost-baseline.sh --stamp-commit <sha> --stamp-date <YYYY-MM-DD>
#   scripts/proof-mode-cost-baseline.sh --check-fields         # doc/sidecar field agreement only
#
# Exit status: 0 ok, 1 usage or internal error, 2 field-set divergence, 3 stale baseline.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PROBE="specs/evidence/proof-mode-cost-baseline/cost-probe.lean"
DOC="docs/development/proof-mode-cost-baseline.md"
REF="docs/reference/diagnostics.md"
DATASET="data/proof-mode-diagnostics.jsonl"
SIDECAR="data/proof-mode-diagnostics_metadata.json"
LOCK=".lake/build-guard.lock"

# The measured surface: everything whose change could move a figure.  Deliberately excludes this
# script, $DOC and $DATASET.
SURFACE=(
  "FormalSystem/Automation/ProofMode"
  "FormalSystem/Theorems/ProofMode"
  "BimodalLib/Diagnostics"
  "$PROBE"
)

JSON_MODE=0
CHECK_FIELDS_ONLY=0
PIN_OVERRIDE=""
STAMP_COMMIT=""
STAMP_DATE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_MODE=1; shift ;;
    --check-fields) CHECK_FIELDS_ONLY=1; shift ;;
    --pin) PIN_OVERRIDE="${2:-}"; shift 2 ;;
    --stamp-commit) STAMP_COMMIT="${2:-}"; shift 2 ;;
    --stamp-date) STAMP_DATE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '3,42p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "proof-mode-cost-baseline.sh: unknown argument '$1'" >&2; exit 1 ;;
  esac
done

die()   { echo "proof-mode-cost-baseline.sh: $*" >&2; exit 1; }
note()  { echo "proof-mode-cost-baseline.sh: $*" >&2; }

[ -f "$PROBE" ] || die "probe not found at $PROBE"
[ -f "$REF" ]   || die "reference page not found at $REF; the sidecar's fields are parsed from it"

# ---------------------------------------------------------------------------
# Field-set agreement: the sidecar's `fields` array is parsed out of the reference page's own
# tables, so the page is the single source and the two cannot drift.  The emitted records are then
# checked against that key set in BOTH directions.
# ---------------------------------------------------------------------------

parse_fields() {
  python3 - "$REF" <<'PY'
import json, re, sys
ref = open(sys.argv[1]).read()
# Each documented stage payload sits under a level-4 heading naming the stage key, or
# `#### shared head`, followed by one `| field | type | description |` table.
sections = re.split(r'^#### +', ref, flags=re.M)[1:]
want = ["shared head", "reprove", "compare"]
fields, seen = [], set()
for sec in sections:
    name = sec.split('\n', 1)[0].strip()
    if name not in want:
        continue
    # Read exactly the FIRST `| field | type | description |` table of the section and stop at
    # its end. A `#### ` section runs to the next `#### `, which can be several `##` sections
    # later, so an unbounded scan would also swallow the nullability-rules table further down.
    started = False
    for line in sec.split('\n'):
        if re.match(r'^\|\s*field\s*\|', line):
            started = True
            continue
        if not started:
            continue
        if re.match(r'^\|-+', line):
            continue
        m = re.match(r'^\|\s*`([a-z_]+)`\s*\|\s*([^|]+?)\s*\|\s*(.+?)\s*\|\s*$', line)
        if not m:
            if not line.strip().startswith('|'):
                break
            continue
        f, t, desc = m.group(1), m.group(2), m.group(3)
        if f in seen:
            continue
        seen.add(f)
        fields.append({"field": f, "type": t, "description": desc})
if not fields:
    print("NO_FIELDS_PARSED", file=sys.stderr)
    sys.exit(1)
json.dump(fields, sys.stdout)
PY
}

if [ "$CHECK_FIELDS_ONLY" -eq 1 ]; then
  parse_fields > /dev/null && note "field tables parse cleanly ($(parse_fields | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))') fields)"
  exit 0
fi

# ---------------------------------------------------------------------------
# Stage 1 -- the staleness re-probe, before anything is measured.
# ---------------------------------------------------------------------------

surface_head() {
  git -C "$REPO_ROOT" log -1 --format=%H -- "${SURFACE[@]}" 2>/dev/null || true
}

read_pin_from_doc() {
  [ -f "$DOC" ] || return 0
  sed -n 's/^- \*\*Measured surface commit\*\*: `\([0-9a-f]\{7,40\}\)`.*/\1/p' "$DOC" | head -1
}

HEAD_SURFACE="$(surface_head)"
[ -n "$HEAD_SURFACE" ] || die "could not determine the measured surface's head commit"

PIN="$PIN_OVERRIDE"
if [ -z "$PIN" ]; then
  PIN="$(read_pin_from_doc)"
fi

if [ -z "$PIN" ]; then
  if [ -f "$DOC" ]; then
    die "no 'Measured surface commit' pin found in $DOC; pass --pin <sha> to set one"
  fi
  note "no $DOC yet and no --pin given; taking the surface head as the pin for this first run"
  PIN="$HEAD_SURFACE"
fi

if [ "${PIN:0:${#PIN}}" != "${HEAD_SURFACE:0:${#PIN}}" ]; then
  cat >&2 <<EOF
proof-mode-cost-baseline.sh: STALE BASELINE

  pinned measured-surface commit : $PIN
  current measured-surface head  : $HEAD_SURFACE

The proof mode, the diagnostics library, or the probe has changed since the figures in $DOC
were taken. Re-run with --pin $HEAD_SURFACE to re-measure and then update the document's
provenance line, or check out the pinned commit to reproduce the recorded figures.

Nothing was measured. A figure taken against different code is worse than no figure.
EOF
  exit 3
fi

note "measured-surface pin $PIN matches the current head"

# ---------------------------------------------------------------------------
# Stage 2 -- build the library to completion, so no timing figure includes compilation.
# `--json` is build-free by contract and assumes an already-built tree.
# ---------------------------------------------------------------------------

if [ "$JSON_MODE" -eq 0 ]; then
  if [ -x ".claude/scripts/lake-build-guard.sh" ]; then
    note "building BimodalLib through the build guard"
    bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib >&2
  else
    note "build guard not present in this checkout; skipping the pre-build"
    note "the probe will fail below if the tree is not already built, which is the honest outcome"
  fi
fi

# ---------------------------------------------------------------------------
# Stage 3 -- run the probe under the shared lock, taken once and held to exit.
# ---------------------------------------------------------------------------

mkdir -p "$(dirname "$LOCK")"
exec 9>"$LOCK"
if ! flock -w 1800 9; then
  die "timed out waiting for $LOCK; another build or probe is holding it"
fi

if [ "$JSON_MODE" -eq 1 ]; then
  OPT_COMMIT=""
  OPT_DATE=""
  OPT_CMD=""
  OPT_ZERO="-Ddiagnostics.zeroTimings=true"
else
  OPT_COMMIT="-Ddiagnostics.commit=${STAMP_COMMIT:-$(git rev-parse --short HEAD)}"
  OPT_DATE="-Ddiagnostics.date=${STAMP_DATE:-$(date -u +%Y-%m-%d)}"
  OPT_CMD="-Ddiagnostics.command=bash scripts/proof-mode-cost-baseline.sh"
  OPT_ZERO=""
fi

RAW="$(mktemp)"
trap 'rm -f "$RAW"' EXIT

note "elaborating $PROBE"
# shellcheck disable=SC2086
lake env lean $OPT_COMMIT $OPT_DATE ${OPT_CMD:+"$OPT_CMD"} $OPT_ZERO "$PROBE" > "$RAW" 2>&1 || {
  grep -n 'error' "$RAW" >&2 || true
  die "the probe did not elaborate cleanly; no dataset written"
}

RECORDS="$(mktemp)"
trap 'rm -f "$RAW" "$RECORDS"' EXIT

# The emitter prints one compressed JSON object per record, as a Lean `info:` message. Pull out
# exactly those lines, in source order, and sort by key so the output is order-stable.
grep -o '{"[a-z_]*":.*}$' "$RAW" \
  | python3 -c '
import json, sys
rows = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    rows.append(json.loads(line))
rows.sort(key=lambda r: (r.get("stage",""), r.get("statement","")))
for r in rows:
    print(json.dumps(r, sort_keys=True, separators=(",", ":")))
' > "$RECORDS"

COUNT="$(wc -l < "$RECORDS" | tr -d ' ')"
[ "$COUNT" -gt 0 ] || die "the probe emitted no records; refusing to write an empty dataset"
note "collected $COUNT record(s)"

# ---------------------------------------------------------------------------
# Stage 4 -- field-set agreement, in both directions, between the reference page and the records.
# ---------------------------------------------------------------------------

FIELDS_JSON="$(mktemp)"
trap 'rm -f "$RAW" "$RECORDS" "$FIELDS_JSON"' EXIT
parse_fields > "$FIELDS_JSON" || die "could not parse the field tables out of $REF"

if ! python3 - "$FIELDS_JSON" "$RECORDS" <<'PY'
import json, sys
fields = json.load(open(sys.argv[1]))
documented = {f["field"] for f in fields}
present = set()
for line in open(sys.argv[2]):
    present |= set(json.loads(line).keys())
missing = sorted(present - documented)
extra   = sorted(documented - present)
ok = True
if missing:
    print("FIELD DIVERGENCE: emitted but not documented in the reference page: %s"
          % ", ".join(missing), file=sys.stderr)
    ok = False
if extra:
    print("FIELD DIVERGENCE: documented for an implemented stage but never emitted: %s"
          % ", ".join(extra), file=sys.stderr)
    ok = False
sys.exit(0 if ok else 1)
PY
then
  echo "proof-mode-cost-baseline.sh: the reference page and the emitted records disagree." >&2
  echo "  Fix $REF or the emitters; the sidecar is parsed from the page, so it cannot paper over this." >&2
  exit 2
fi
note "field sets agree between $REF and the emitted records"

# ---------------------------------------------------------------------------
# Stage 5 -- emit, or write the dataset and its sidecar.
# ---------------------------------------------------------------------------

if [ "$JSON_MODE" -eq 1 ]; then
  cat "$RECORDS"
  exit 0
fi

cp "$RECORDS" "$DATASET"

python3 - "$FIELDS_JSON" "$DATASET" "$SIDECAR" "${STAMP_DATE:-$(date -u +%Y-%m-%d)}" <<'PY'
import json, sys
fields = json.load(open(sys.argv[1]))
rows = [json.loads(l) for l in open(sys.argv[2])]
by_stage = {}
for r in rows:
    by_stage[r["stage"]] = by_stage.get(r["stage"], 0) + 1
meta = {
  "dataset_name": "proof-mode-diagnostics",
  "version": "1.0.0",
  "schema_version": "1.0",
  "description": (
    "Diagnostics records for the derivation proof mode, in the one record schema that covers "
    "every stage of the library pipeline (BimodalLib/Diagnostics/Record.lean). Each record is "
    "keyed by a statement identifier and a stage, and carries the fragment, the frame class, the "
    "commit and the command that produced it. Only the reprove and compare stages are present: "
    "the other five are reserved in the schema and emitted by the tableau pipeline. Generated by "
    "scripts/proof-mode-cost-baseline.sh; every field is documented at "
    "docs/reference/diagnostics.md, from which this fields array is parsed."
  ),
  "generation_date": sys.argv[4],
  "total_records": len(rows),
  "records_by_stage": dict(sorted(by_stage.items())),
  "fields": fields,
}
with open(sys.argv[3], "w") as fh:
    json.dump(meta, fh, indent=2)
    fh.write("\n")
PY

note "wrote $DATASET ($COUNT records) and $SIDECAR"
note "measured-surface commit: $HEAD_SURFACE"
