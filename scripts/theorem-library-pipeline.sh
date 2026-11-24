#!/usr/bin/env bash
# The one named entry point for the theorem library's tableau pipeline.
#
# Runs the five stages of records/theorem-library.md -- enumerate, decide, extract, certify,
# admit -- through the `theorem_library_pipeline` executable, and writes three outputs plus a
# sidecar per dataset:
#
#   data/theorem-library-pipeline.jsonl            the five stages' records
#   data/theorem-library-pipeline_metadata.json    its sidecar, with the `fields` array
#   data/theorem-library-countermodels.jsonl       certified refutations, NOT admitted
#   data/theorem-library-countermodels_metadata.json
#   <--out-module>                                 the generated theorem module, when asked for
#
# This script's shape follows scripts/proof-mode-cost-baseline.sh, which fixed the conventions
# this repository measures under:
#
#   THE STALENESS PIN IS READ BEFORE ANYTHING IS MEASURED.  The pipeline's measured surface is
#   the enumerator, the decision procedure, the gates, the emitters and the driver.  A figure
#   taken against a surface that has moved since the last recorded run is worse than no figure,
#   so a mismatch is reported and nothing is measured.  Unlike the cost baseline, the pin here is
#   ADVISORY: this pipeline's outputs are regenerated on demand rather than quoted as a fixed
#   baseline, so a moved surface prints a warning and proceeds instead of exiting 3.  Pass
#   --strict-pin to make it fatal.
#
#   THE RUN HOLDS .lake/build-guard.lock, taken once and held to exit, with a bounded announced
#   wait.  A pipeline run elaborates nothing but it does spend the machine, and the measured
#   figures are wall-clock; sharing the guard's lock is what keeps a concurrent `lake build` from
#   contaminating them.  The research probe for this work lost its only cost figure to exactly
#   that kind of contention.
#
#   --json IS THE DETERMINISM CONTRACT.  Two --json runs at the same bound AND THE SAME ATOM POOL
#   are byte-identical: --json zeroes `decision_time_ms`, the one field of the five reserved
#   payloads that is not a function of the commit and the toolchain, and zeroes the sidecar's
#   generation date.  The verdict counts were measured to reproduce exactly across two runs while
#   the timings did not, so zeroing the timing field is the whole of what determinism requires.
#
# THE ATOM POOL IS REQUIRED, with no default, and is echoed into every record and both sidecars.
# The measured yield is superexponential in pool size -- Boolean 14 and ModalBoolean 133 at a
# two-atom pool, against 902 and 751 in a dataset tabulation at a wider one -- so a yield figure
# without its pool is not reportable.
#
# Usage:
#   scripts/theorem-library-pipeline.sh --fragment F --max-complexity N --atoms K [options]
#   scripts/theorem-library-pipeline.sh --help
#
# Every flag not listed below is passed through to the executable unchanged; run --help for its
# own flag set.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

RECORDS="data/theorem-library-pipeline.jsonl"
RECORDS_SIDECAR="data/theorem-library-pipeline_metadata.json"
COUNTERMODELS="data/theorem-library-countermodels.jsonl"
COUNTERMODELS_SIDECAR="data/theorem-library-countermodels_metadata.json"
REF="docs/reference/diagnostics.md"
REGISTRY="data/registry-statements.jsonl"
REGISTRY_PROBE="specs/evidence/theorem-library-pipeline/registry-statements.lean"
LOCK=".lake/build-guard.lock"

# The measured surface: a change to any of these invalidates a recorded run's figures.
SURFACE=(
  "BimodalTools/FormulaEnumerator.lean"
  "BimodalTools/AtomCanonicalization.lean"
  "BimodalTools/TableauBridge.lean"
  "BimodalTools/LeanSourceEmit.lean"
  "BimodalTools/PipelineDiagnostics.lean"
  "BimodalTools/TheoremPipeline.lean"
  "BimodalTools/TheoremLibraryPipelineMain.lean"
  "BimodalLib/Subsumption.lean"
  "BimodalLib/Diagnostics"
  "FormalSystem/Metalogic/Decidability"
)

die() { echo "theorem-library-pipeline.sh: $*" >&2; exit 1; }
note() { echo "theorem-library-pipeline.sh: $*" >&2; }

JSON_MODE=0
STRICT_PIN=0
HELP=0
OUT_MODULE=""
ATOMS=""
PASS_THROUGH=()

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_MODE=1; PASS_THROUGH+=("$1"); shift ;;
    --strict-pin) STRICT_PIN=1; shift ;;
    --help|-h) HELP=1; shift ;;
    --out-module) OUT_MODULE="${2:-}"; PASS_THROUGH+=("$1" "${2:-}"); shift 2 ;;
    --atoms) ATOMS="${2:-}"; PASS_THROUGH+=("$1" "${2:-}"); shift 2 ;;
    *) PASS_THROUGH+=("$1"); shift ;;
  esac
done

if [ "$HELP" -eq 1 ]; then
  sed -n '2,48p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
  echo
  echo "The executable's own flag set:"
  bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- exe theorem_library_pipeline \
    -- --help 2>/dev/null || lake exe theorem_library_pipeline --help
  exit 0
fi

[ -n "$ATOMS" ] || die "--atoms is required: a yield figure without its atom pool is not reportable"
[ -f "$REF" ] || die "reference page not found at $REF; the sidecars' fields are parsed from it"

# ---------------------------------------------------------------------------
# Stage 1 -- the staleness pin, read before anything is measured.
# ---------------------------------------------------------------------------

HEAD_SURFACE="$(git -C "$REPO_ROOT" log -1 --format=%H -- "${SURFACE[@]}" 2>/dev/null || true)"
[ -n "$HEAD_SURFACE" ] || die "could not determine the measured surface's head commit"

# The pin is the `measured_surface_commit` field of the records sidecar from the last run, not a
# file of its own: the sidecar is already the run's provenance record, and a second file would be
# one more thing to keep in step with it.
PIN=""
if [ -f "$RECORDS_SIDECAR" ]; then
  PIN="$(python3 -c 'import json,sys
try:
    print(json.load(open(sys.argv[1])).get("measured_surface_commit") or "")
except Exception:
    print("")' "$RECORDS_SIDECAR" 2>/dev/null || true)"
fi

if [ -n "$PIN" ]; then
  if [ "$PIN" != "$HEAD_SURFACE" ]; then
    if [ "$STRICT_PIN" -eq 1 ]; then
      cat >&2 <<EOF
theorem-library-pipeline.sh: STALE PIN

  pinned measured-surface commit : $PIN
  current measured-surface head  : $HEAD_SURFACE

The enumerator, the decision procedure, the gates, the emitters or the driver has changed since
the run $RECORDS_SIDECAR records. Nothing was measured. A figure taken against different code is
worse than no figure. Re-run without --strict-pin to re-measure and re-pin.
EOF
      exit 3
    fi
    note "measured-surface head $HEAD_SURFACE differs from pin $PIN; re-measuring and re-pinning"
  else
    note "measured-surface pin $PIN matches the current head"
  fi
else
  note "no recorded pin in $RECORDS_SIDECAR yet; this run establishes it"
fi

# ---------------------------------------------------------------------------
# Stage 2 -- build the executable through the guard, so no figure includes compilation.
# ---------------------------------------------------------------------------

# `build theorem_library_pipeline` and not `build BimodalTools.TheoremLibraryPipelineMain`: the
# module target produces the olean, while the EXE target also links the binary. Building only the
# module leaves `lake exe` to compile and link ~500 C objects inside the lock, which is exactly
# the compilation this stage exists to keep out of the measured window.
note "building theorem_library_pipeline through the build guard"
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 \
  -- build theorem_library_pipeline >&2 \
  || die "the executable did not build; nothing was measured"

# ---------------------------------------------------------------------------
# Stage 2b -- refresh the registry snapshot ADMIT compares candidates against.
#
# The ADMISSION rule is that a candidate is admitted unless it is a substitution instance of an
# entry ALREADY PRESENT, and the entries already present are the whole registry, hand-curated
# rows included. The driver is a compiled executable and cannot walk the environment, so the
# comparison set reaches it as data. Without this, the pipeline emits entries that duplicate
# hand-curated laws and `assert_no_subsumed_entries` fails the build on them -- measured, two of
# ten entries at the ruled bound.
#
# The probe imports the hand-curated registration modules only, never the enumerated ones, so it
# stays buildable while the invariant it feeds is red and a run never depends on its own previous
# output.
# ---------------------------------------------------------------------------

if [ -f "$REGISTRY_PROBE" ]; then
  note "refreshing the registry snapshot from $REGISTRY_PROBE"
  lake env lean "$REGISTRY_PROBE" >&2 \
    || die "the registry snapshot probe failed; nothing was measured"
  [ -s "$REGISTRY" ] || die "the probe wrote no $REGISTRY"
else
  die "registry snapshot probe not found at $REGISTRY_PROBE"
fi

# ---------------------------------------------------------------------------
# Stage 3 -- run under the shared lock, taken once and held to exit.
# ---------------------------------------------------------------------------

mkdir -p "$(dirname "$LOCK")" data
exec 9>"$LOCK"
note "waiting on the shared build lock ($LOCK, up to 1800s)"
if ! flock -w 1800 9; then
  die "timed out waiting on $LOCK; another build or probe is holding it"
fi

COMMIT="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
if [ "$JSON_MODE" -eq 1 ]; then
  STAMP_COMMIT="unstamped"
  GEN_DATE="1970-01-01"
else
  STAMP_COMMIT="$COMMIT"
  GEN_DATE="$(date -u +%Y-%m-%d)"
fi

SUMMARY_FILE="$(mktemp)"
trap 'rm -f "$SUMMARY_FILE"' EXIT

note "running the pipeline"
lake exe theorem_library_pipeline \
  --out-records "$RECORDS" \
  --out-countermodels "$COUNTERMODELS" \
  --registry-statements "$REGISTRY" \
  --commit "$STAMP_COMMIT" \
  "${PASS_THROUGH[@]}" > "$SUMMARY_FILE"
RUN_STATUS=$?

if [ "$RUN_STATUS" -ne 0 ]; then
  die "the pipeline exited $RUN_STATUS; the outputs written so far stand but no sidecar was written"
fi

# The exact command that reproduces this run, recorded in both sidecars.
REPRO="bash scripts/theorem-library-pipeline.sh"
for a in "${PASS_THROUGH[@]}"; do
  REPRO="$REPRO $a"
done

# ---------------------------------------------------------------------------
# Stage 4 -- the sidecars. The `fields` array is parsed out of the reference page, so a
# sidecar cannot paper over a field the page does not document.
# ---------------------------------------------------------------------------

python3 - "$RECORDS" "$RECORDS_SIDECAR" "$COUNTERMODELS" "$COUNTERMODELS_SIDECAR" \
         "$SUMMARY_FILE" "$GEN_DATE" "$REPRO" "$REF" "$HEAD_SURFACE" <<'PY'
import json, re, sys, collections

records_p, records_s, cms_p, cms_s, summary_p, gen_date, repro, ref, surface = sys.argv[1:10]

def read_jsonl(path):
    out = []
    try:
        with open(path) as fh:
            for line in fh:
                line = line.strip()
                if line:
                    out.append(json.loads(line))
    except FileNotFoundError:
        pass
    return out

records = read_jsonl(records_p)
cms = read_jsonl(cms_p)
summary = json.load(open(summary_p)) if summary_p else {}

# Parse the documented field tables out of the reference page: `| \`name\` | type | description |`
row = re.compile(r"^\|\s*`([A-Za-z0-9_]+)`\s*\|\s*([^|]+?)\s*\|\s*(.*?)\s*\|\s*$")
fields, seen = [], set()
for line in open(ref, encoding="utf-8"):
    m = row.match(line.rstrip("\n"))
    if not m:
        continue
    name, typ, desc = m.group(1), m.group(2), m.group(3)
    if name in seen:
        continue
    seen.add(name)
    fields.append({"field": name, "type": typ, "description": desc})

by_stage = collections.Counter(r.get("stage", "?") for r in records)
by_grade = collections.Counter(
    (r.get("grade") or "ungraded") for r in cms)
by_fc = collections.Counter(r.get("frame_class", "?") for r in cms)

undocumented = sorted({k for r in records for k in r} - seen)

json.dump({
    "dataset_name": "theorem-library-pipeline",
    "version": "1.0.0",
    "schema_version": "1.0",
    "description": (
        "Stage records for the theorem library's tableau pipeline, in the one record schema that "
        "covers every stage of the library pipeline (BimodalLib/Diagnostics/Record.lean). Each "
        "record is keyed by a statement identifier and a stage, and carries the fragment, the "
        "frame class, the commit and the command that produced it. The five reserved stages -- "
        "enumerate, decide, extract, certify, admit -- are emitted here by "
        "BimodalTools/PipelineDiagnostics.lean; reprove and compare are emitted by the "
        "proof-mode cost baseline instead. Generated by scripts/theorem-library-pipeline.sh; "
        "every field is documented at docs/reference/diagnostics.md, from which this fields "
        "array is parsed."),
    "generation_date": gen_date,
    "command": repro,
    "measured_surface_commit": surface,
    "run": summary,
    "total_records": len(records),
    "records_by_stage": dict(sorted(by_stage.items())),
    "undocumented_fields": undocumented,
    "fields": fields,
}, open(records_s, "w"), indent=2)
open(records_s, "a").write("\n")

json.dump({
    "dataset_name": "theorem-library-countermodels",
    "version": "1.0.0",
    "schema_version": "1.0",
    "description": (
        "Certified refutations produced by the theorem library's tableau pipeline, written in the "
        "form the countermodels record will read and NOT registered in BimodalLib. One record "
        "per refuted inference, carrying the inference, the frame class, the grade "
        "(gated_tableau when all eight hypotheses of not_valid_of_hasOpen_int hold on the open "
        "branch, certificate when a witness-family certificate was accepted by "
        "decidableCertifies), the eight gate booleans and the countermodel's valuation. At ZTime "
        "the gates are null by construction: regionLabel and temporalWitness are false there on "
        "every formula, so the gated grade is structurally unavailable and the certificate route "
        "is the only one. Generated by scripts/theorem-library-pipeline.sh."),
    "generation_date": gen_date,
    "command": repro,
    "total_records": len(cms),
    "records_by_grade": dict(sorted(by_grade.items())),
    "records_by_frame_class": dict(sorted(by_fc.items())),
    "fields": [
        {"field": "statement", "type": "string",
         "description": "The dataset identifier of the refuted formula"},
        {"field": "inference", "type": "string",
         "description": "The refuted formula, pretty-printed"},
        {"field": "frame_class", "type": "string enum",
         "description": "One of `Base`, `Dense`, `ZTime`, `RTime`"},
        {"field": "grade", "type": "string enum or null",
         "description": "`gated_tableau`, `certificate`, or null when neither route backed it"},
        {"field": "gates", "type": "object or null",
         "description": "BranchGates.toJson's nine booleans; null at ZTime by construction"},
        {"field": "true_atoms", "type": "array of string",
         "description": "Atoms the countermodel makes true"},
        {"field": "false_atoms", "type": "array of string",
         "description": "Atoms the countermodel makes false"},
    ],
}, open(cms_s, "w"), indent=2)
open(cms_s, "a").write("\n")

print("theorem-library-pipeline.sh: %d records (%s), %d refutations (%s)" % (
    len(records), ", ".join("%s=%d" % kv for kv in sorted(by_stage.items())),
    len(cms), ", ".join("%s=%d" % kv for kv in sorted(by_grade.items())) or "none"),
    file=sys.stderr)
if undocumented:
    print("theorem-library-pipeline.sh: fields not documented in %s: %s"
          % (ref, ", ".join(undocumented)), file=sys.stderr)
PY
SIDECAR_STATUS=$?
[ "$SIDECAR_STATUS" -eq 0 ] || die "the sidecars could not be written (exit $SIDECAR_STATUS)"

cat "$SUMMARY_FILE"
note "wrote $RECORDS, $RECORDS_SIDECAR, $COUNTERMODELS, $COUNTERMODELS_SIDECAR"
[ -n "$OUT_MODULE" ] && note "wrote $OUT_MODULE"
exit 0
