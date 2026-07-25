#!/usr/bin/env bash
# Capture the output of all 12 lean_exe entry points with fixed, deterministic invocations.
#
#   Usage: bash run-exes.sh <output-dir>
#
# Run once before the toolchain upgrade and once after, then diff. Both runs must use this
# same script so the invocations are byte-identical and the outputs directly comparable.
#
# ---------------------------------------------------------------------------------------
# Why the interpreter (`lake env lean --run`) and not `lake exe`
# ---------------------------------------------------------------------------------------
# `lake exe` links a ~264 MB native binary per target, which requires compiling every module
# in the import closure a second time as `.c.o.export` at -O3. Two of those C files are 29 MB
# and 52 MB; one of them alone consumed 30 minutes of CPU and ~3.9 GB RSS without finishing,
# and the whole set has to be redone after the pin flip.
#
# That cost buys nothing for the property this gate exists to test. The dangerous change in
# this upgrade (Lean 4.32 #13912, `return` inside a nested action re-scoping to the enclosing
# `do`) is a change to **elaboration**, not to code generation: it alters the Lean core term
# the frontend produces. The interpreter and the native backend consume that same elaborated
# term, so `lake env lean --run` exercises the change identically while reusing the oleans
# that already exist.
#
# What the interpreter does NOT cover: native-backend-specific codegen and linking. If a
# target fails to *link* after the upgrade, this gate will not see it. `lake build` of the
# exe targets is the check for that, and is tracked separately.
# ---------------------------------------------------------------------------------------
set -u
OUT="${1:?usage: run-exes.sh <output-dir>}"
REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
mkdir -p "$OUT"
cd "$REPO" || exit 1

SRC="Theories/Bimodal/Automation"
CAP="${EXE_CAP:-600}"

# target -> root source file (matches the `root :=` fields in lakefile.lean)
run() {
  local name="$1" file="$2"; shift 2
  local cap="${CAP_OVERRIDE:-$CAP}"
  echo "### $name cap=${cap}s ($(date -Is))"
  timeout "$cap" lake env lean --run "$SRC/$file" "$@" \
    > "$OUT/$name.out" 2> "$OUT/$name.err" < /dev/null
  echo "exit=$?" > "$OUT/$name.exit"
}

run_stdin() {
  local name="$1" file="$2" input="$3"
  echo "### $name ($(date -Is))"
  printf '%s\n' "$input" \
    | timeout "$CAP" lake env lean --run "$SRC/$file" \
      > "$OUT/$name.out" 2> "$OUT/$name.err"
  echo "exit=$?" > "$OUT/$name.exit"
}

# dataset_validator takes no workload flag: it always runs the full conformance suite and then
# a feasibility gate over 63,067,610 formulas, which is a multi-hour job natively and cannot be
# run to completion here. It is capped deliberately. Everything semantically meaningful (all 30
# conformance assertions + the enumeration cardinality) is emitted before the progress loop
# starts, so the comparison uses the pre-`Progress:` prefix — see normalize.sh.
CAP_OVERRIDE=180 run dataset_validator DatasetValidator.lean
run enum_benchmark        EnumBenchmark.lean
run dataset_generator     DatasetExport.lean            --max-complexity 3 --output "$OUT/dataset.jsonl"
run proof_extractor       ProofStepExport.lean          --output "$OUT/proof_steps.jsonl"
run benchmark_anchors     BenchmarkAnchors.lean         --output "$OUT/axiom-instances.jsonl"
run contrastive_generator FormulaMutator.lean           --max-complexity 3 --output "$OUT/contrastive.jsonl"
# tableau_proof_steps: the plan's --max-complexity 3 does not finish inside any sane cap.
# Shrunk to a workload that completes; comparability across runs is what this gate needs,
# not workload size.
run tableau_proof_steps   TableauProofStepPipeline.lean --max-complexity 2 --valid-seed-count 5 \
                                                        --max-wrap-depth 1 --wrap-batch-size 5 \
                                                        --output "$OUT/tableau_steps.jsonl"
run proof_first_generator ProofFirstExporter.lean       --max-depth 2 --seed 1000 --output "$OUT/proof_first.jsonl"
# machine_appendix: --stamp-commit/--stamp-date deliberately omitted so output is reproducible.
run machine_appendix      MachineAppendixExport.lean    --output "$OUT/machine-appendix.jsonl"

# trace_exporter reads S-EXPRESSIONS, one per line (TraceExporter.lean:222 parseSExprFormula).
run_stdin trace_exporter  TraceExporter.lean '(imp (atom p) (atom q))'

# tableau_bridge reads JSON envelopes, one per line (TableauBridge.lean:26 protocol block).
run_stdin tableau_bridge  TableauBridge.lean '{"command": "ping"}'

# benchmark_oracle needs an input file: feed it the anchors produced above.
run benchmark_oracle      BenchmarkOracle.lean --input "$OUT/axiom-instances.jsonl" --output "$OUT/oracle-validated.jsonl"

echo "DONE ($(date -Is))"

# Data-product digests. The .jsonl outputs are up to 68 MB, far too large to keep in git, but
# they are real outputs and must still be gated. Record sha256 + line count instead; for
# deterministic targets the digest is an exact gate, and for RNG-dependent targets the line
# count is still a meaningful invariant.
{
  for j in "$OUT"/*.jsonl "$OUT"/*.json; do
    [ -e "$j" ] || continue
    case "$(basename "$j")" in repl-input.jsonl) continue;; esac
    printf '%s\t%s\t%s\n' "$(basename "$j")" "$(sha256sum < "$j" | cut -d' ' -f1)" "$(wc -l < "$j")"
  done
} | sort > "$OUT/data-products.tsv"
echo "wrote data-products.tsv"
