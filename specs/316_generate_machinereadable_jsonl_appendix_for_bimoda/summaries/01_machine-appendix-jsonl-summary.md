# Implementation Summary: Task #316 — Machine-Readable JSONL Appendix for BimodalReference

- **Task**: 316 - Generate machine-readable JSONL appendix for BimodalReference
- **Status**: implemented (all 4 phases completed; both acceptance gates green)
- **Plan**: specs/316_generate_machinereadable_jsonl_appendix_for_bimoda/plans/01_machine-appendix-jsonl.md
- **Session**: sess_1783410218_f83296_316
- **Date**: 2026-07-07

## What Was Built

The 42-constructor axiom table, 7 inference rules, and 21 derived-operator definitions are now
exported from Lean as a committed, commit-stamped JSONL artifact
(`Theories/Bimodal/typst/generated/machine-appendix.jsonl`, 71 lines: 1 metadata + 42 + 7 + 21),
with schema formulas extracted from the `Axiom` type index (never transcribed), plus a derived
typst rendering (`machine-appendix.typ`) and an appendix chapter wired into
`BimodalReference.typ`. Freshness is enforced by `typst-sync-check.sh` Check 3 (count agreement
against live `Axioms.lean`/`Derivation.lean` scans + rendering agreement via re-render diff),
using jq/python/awk only — no `lake` invocation.

## Phases

1. **Lean exporter module and lake exe** [COMPLETED] — `MachineAppendixExport.lean` +
   shared `AxiomNames.lean` (extracted from BenchmarkAnchors) + `lean_exe machine_appendix`
   stanza. (Committed in a25f7d4e3, prior session.)
2. **Commit-stamped generation script** [COMPLETED] — `scripts/typst-machine-appendix.sh`
   (default regenerate mode + `--json` + `--render-only`); both generated artifacts committed;
   determinism verified by double-run byte-identity. (00161d0f3)
3. **Appendix chapter and book wiring** [COMPLETED] — `chapters/ax-machine-appendix.typ`,
   `#include` in `BimodalReference.typ` back matter, pointer subsection in
   `chapters/p4-dataset-pipeline.typ`, whitelist entries. (559f677b2)
4. **Sync-check Check 3 and full verification sweep** [COMPLETED] — Check 3 (two sub-checks),
   negative test confirmed (doctored JSONL → exit 1 with actionable regenerate message), full
   sweep green. (b430e16bb)

## Verification Results

- `lake build` (full default target): green (1709 jobs).
- Exporter run (interpreter): exits 0; coverage assertions pass (42/42 axioms matching
  `allAxiomNames`, 7 rules, 21 derived operators).
- Every JSONL line parses under `jq`; metadata line carries correct counts/stamps.
- Spot-checks: `modal_t` = `(□φ → φ)` / `Base`; `density` → `Dense`; `z1`/`prior_UZ` →
  `Discrete`; `linear_until` params `[φ, ψ, χ, θ]`; `neg` unfolds to
  `{"tag":"imp",...,"right":{"tag":"bot"}}`.
- `typst compile BimodalReference.typ` exits 0 (acceptance gate 1). Pre-existing font/deprecation
  warnings only.
- `bash scripts/typst-sync-check.sh` PASS, all 3 checks green (acceptance gate 2); negative test
  exits 1 with "regenerate via bash scripts/typst-machine-appendix.sh".
- Determinism: two consecutive script runs from the same commit/day produce byte-identical
  JSONL and .typ; `--render-only` of the committed JSONL reproduces the committed .typ exactly.
- Both generated artifacts are git-tracked (gitignore verified not to exclude them).
- No sorries, no vacuous definitions, no new axioms in any file touched by this task
  (repo-wide sorry census of 163 is pre-existing Boneyard/Metalogic baseline, untouched).

## Plan Deviations

- **Phase 1** *(altered, prior session)*: `allAxiomNames` extracted into new shared module
  `Theories/Bimodal/Automation/AxiomNames.lean` (BenchmarkAnchors declares a root-level `main`,
  so importing it from another exe module is a redeclaration error); also fixed a pre-existing
  latent break in `BenchmarkAnchors.lean` (LabeledFormula record literals missing 6 fields).
- **Phase 2** *(altered)*: The script's default generation path invokes the exporter through the
  Lean INTERPRETER (`lake build Bimodal.Automation.MachineAppendixExport` then
  `lake env lean --run Theories/Bimodal/Automation/MachineAppendixExport.lean -- ...`) instead of
  `lake exe machine_appendix`. Reason: the native link with `supportInterpreter := true`
  recompiles `Formula.c.o.export` under LEAN_EXPORTING at -O3, which OOM-kills clang
  (exit 137) on this machine — a hard environmental limit. The interpreter consumes ordinary
  .oleans and produces byte-identical JSONL in seconds. The `lean_exe machine_appendix` stanza
  remains in `lakefile.lean` for capable machines; the script header documents the rationale.
- **Testing & Validation** *(altered)*: exporter exit-0/coverage verification performed via the
  interpreter rather than the native exe, per the Phase 2 deviation.

## Artifacts

- `Theories/Bimodal/Automation/MachineAppendixExport.lean` — exporter module (Phase 1)
- `Theories/Bimodal/Automation/AxiomNames.lean` — shared 42-name list (Phase 1 deviation)
- `lakefile.lean` — `lean_exe machine_appendix` stanza (Phase 1; retained for capable machines)
- `scripts/typst-machine-appendix.sh` — interpreter-based generation wrapper
- `Theories/Bimodal/typst/generated/machine-appendix.jsonl` — shipped raw artifact (committed)
- `Theories/Bimodal/typst/generated/machine-appendix.typ` — derived rendering (committed)
- `Theories/Bimodal/typst/chapters/ax-machine-appendix.typ` — appendix chapter
- `Theories/Bimodal/typst/BimodalReference.typ` — back-matter include
- `Theories/Bimodal/typst/chapters/p4-dataset-pipeline.typ` — pointer subsection
- `Theories/Bimodal/typst/sync-check-whitelist.txt` — whitelist entries
- `scripts/typst-sync-check.sh` — Check 3 (count agreement + rendering agreement)

## Commits (this session)

- 00161d0f3 — task 316 phase 2: commit-stamped generation script (interpreter path)
- 559f677b2 — task 316 phase 3: appendix chapter and book wiring
- b430e16bb — task 316 phase 4: sync-check Check 3 and full verification sweep
