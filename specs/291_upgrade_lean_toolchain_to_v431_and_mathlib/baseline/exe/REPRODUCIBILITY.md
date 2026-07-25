# Executable Baseline: Coverage and Reproducibility

Pre-upgrade capture at HEAD `e0158da5e974e7526ea6e7c1db436618fa170e81`, Lean `v4.27.0-rc1`.

All 12 `lean_exe` entry points are covered. **No target is silently missing.** The exact
strength of each target's gate is stated below, because a baseline that cannot reproduce
against itself cannot detect a post-upgrade change, and pretending otherwise would make the
gate decorative.

## Method: interpreter, not native binary

Captured with `lake env lean --run <root>.lean`, not `lake exe`.

`lake exe` links a ~264 MB native binary per target, which first requires recompiling every
module in the import closure as `.c.o.export` at `-O3`. Two of those C files are 29 MB
(`Syntax/Formula.c`) and 52 MB (`Automation/FormulaEnumerator.c`); the 29 MB one alone consumed
**30 minutes of CPU and 3.9 GB RSS without finishing**, and the entire set would have to be
rebuilt after the pin flip.

That cost buys nothing for the property this gate exists to test. The dangerous change in this
upgrade — Lean 4.32 (#13912), `return` inside a nested action re-scoping to the enclosing `do` —
is a change to **elaboration**, not code generation. It alters the Lean core term the frontend
produces. The interpreter and the native backend consume that same elaborated term, so
`lake env lean --run` exercises the change identically while reusing oleans that already exist.

**What this method does not cover**: native-backend codegen and linking. If a target fails to
*link* after the upgrade, this gate will not see it. `lake build` of the 12 exe targets is the
check for that and is tracked separately, not folded in here.

## Reproducibility, measured (not assumed)

Each target was run **twice, back to back, pre-upgrade, on identical input**, and the two
outputs compared. Source reading establishes what *could* vary; only running it twice
establishes what *does*.

### Tier 1 — exactly reproducible (7 targets)

Byte-identical across two runs after masking only elapsed-time and output-path text.
A post-upgrade diff here is a strong signal: any difference is a real behavior change.

| Target | Compared |
|---|---|
| `benchmark_anchors` | full output |
| `benchmark_oracle` | full output |
| `dataset_validator` | pre-`Progress:` prefix — see note below |
| `machine_appendix` | full output (git stamps deliberately not passed) |
| `proof_extractor` | full output |
| `tableau_bridge` | full output |
| `trace_exporter` | full output |

### Tier 2 — RNG-dependent, structural comparison only (5 targets)

These call **unseeded `IO.rand`** (`FormulaEnumerator.lean:811,831,836,843,863,871,880,...`),
so they do not reproduce against themselves even with the toolchain held fixed. Two identical
pre-upgrade runs of `enum_benchmark` produced pool sizes of 108 vs 98, and valid-formula counts
of 43 vs 45.

**Consequence: a byte-exact output diff is impossible for these targets regardless of the
upgrade.** `proof_first_generator` is included despite taking `--seed 1000`; that flag does not
control `IO.rand`.

For these, the comparison masks RNG-derived cardinalities (pool sizes, sample histograms,
throughput, valid/invalid ratios) and requires **everything else to match exactly** — section
structure, PASS/FAIL verdicts, deterministic enumeration counts, and all non-sampled values.
Verified: after masking, both runs agree line-for-line.

| Target | Lines compared after masking |
|---|---|
| `contrastive_generator` | 58 |
| `dataset_generator` | 67 |
| `enum_benchmark` | 199 |
| `proof_first_generator` | 27 |
| `tableau_proof_steps` | 42 |

This is a genuinely weaker gate than Tier 1, and it is weaker for reasons that predate this
upgrade. It is recorded rather than hidden behind wider normalization.

## Per-target notes

- **`dataset_validator`** takes no workload flag. It always runs the full conformance suite and
  then a feasibility gate over **63,067,610** formulas — a multi-hour job that reached only
  81,100 formulas in 600 s. It is capped at 180 s deliberately. Everything semantically
  meaningful precedes the progress loop: all 30 conformance assertions (10 valid + 20 invalid,
  all PASS) and the enumeration cardinality. Those **are** compared; the truncated progress loop
  is not, because its cut-off point is a function of machine speed rather than program behavior.
- **`tableau_proof_steps`** does not finish under any sane cap at the plan's suggested
  `--max-complexity 3`. Shrunk to `--max-complexity 2 --valid-seed-count 5 --max-wrap-depth 1
  --wrap-batch-size 5`, which completes in seconds. Comparability across runs is what this gate
  needs, not workload size.
- **`machine_appendix`** is run without `--stamp-commit`/`--stamp-date` so no git metadata enters
  the output (it reports `stamp unstamped unstamped`).

## Corrections to the plan's suggested invocations

Two suggested REPL invocations were wrong, and both would have produced a baseline that looked
fine while testing nothing. The corrected forms are baked into `run-exes.sh` and must be used
for the post-upgrade run.

| Target | Plan suggested | Actual protocol | Evidence |
|---|---|---|---|
| `trace_exporter` | `{"command":"trace_decide","formula":{...}}` (JSON) | **S-expression**, one per line: `(imp (atom p) (atom q))` | `TraceExporter.lean:222` dispatches to `parseSExprFormula`; docstring at `:257` shows the S-expression form. Feeding JSON returns `{"status": "error", "message": "failed to parse formula: ..."}` — a parse-error baseline that would compare equal before and after the upgrade while exercising none of the decision procedure. |
| `tableau_bridge` | same JSON line | JSON is correct here, but the plan reused the `trace_exporter` line; minimal valid envelope is `{"command": "ping"}` | `TableauBridge.lean:26-31` protocol block |

The plan gave both targets the same JSON line, which cannot be correct for both — they use
different protocols.

## Reproducing

```bash
bash baseline/run-exes.sh <output-dir>     # capture
bash baseline/compare-exes.sh <dir-a> <dir-b>   # compare, applying the tiers above
```
