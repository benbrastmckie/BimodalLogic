# Research Report: Task #582

**Task**: 582 - Break or re-baseline the Conservativity <-> Deterministic directory cycle in `Metalogic/`
**Started**: 2026-09-16T00:00:00Z
**Completed**: 2026-09-16T00:00:00Z
**Effort**: Small (Option A1: one 5-line theorem relocated, one import line deleted, 3 doc rows updated, then CI wiring)
**Dependencies**: Task 583 (records the CI wiring pattern the final phase must follow; still `researching`)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Conservativity/Plus/*.lean`, `FormalSystem/Metalogic/Deterministic/*.lean`), `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh` (C15), `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`, `docs/theorem-index.md`, `.github/workflows/ci.yml`, `lake env lean` scratch compiles against the current build, prior report `01_conservativity-deterministic-cycle.md`
**Artifacts**: - specs/582_break_or_rebaseline_metalogic_cycle/reports/02_cycle-break-costing.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Option A is cheap and verified.** The `Conservativity -> Deterministic` edge exists for exactly
  one declaration: `Conservativity.detDerivable_ofFormula_iff` (Corollaries.lean:210-213, a 3-line
  proof). Nothing else in `Corollaries.lean` uses anything from `Deterministic`, and every other
  name it needs (`completeness_base`, `TemporalDerived`, `PlusNonValidities`, ...) is already in the
  import closure of `Conservativity.Plus.Forward`.
- **Relocating that one theorem into `Deterministic/Completeness.lean` and deleting the import line
  breaks the cycle.** Verified three ways: (1) a scratch copy of `Corollaries.lean` without the
  import and theorem compiles with exit 0 and no diagnostics; (2) the theorem, restated in
  namespace `FormalSystem.Metalogic.Deterministic` importing only `Deterministic.Completeness`,
  compiles and depends only on `propext`, `Classical.choice`, `Quot.sound`; (3)
  `check-metalogic-cycles.sh` run against a simulated tree with that change prints
  `PASS exactly 1 directory-level import cycle` (exit 0).
- **The removed edge is the layering inversion; the kept edge is the natural one.**
  `Deterministic -> Conservativity` is the extension (TM+ + *Determined*) reusing TM+'s axiom
  validity lemmas (`plusAxiom_validIn`, `plusAxiom_swap_validIn`); that direction is correct. The
  base system's corollaries module depending on the extension's completeness theorem was the
  inversion, and the theorem is itself a statement about `DetDerivable`, so it belongs in
  `Deterministic/`.
- **Option B is not justified** by the cost comparison: ADR-006 accepted `BXCanonical <->
  WeakCanonical` because it is 14 import lines over a 137-file subtree; this cycle is 2 lines,
  one of which disappears with a 5-line move.
- **Recommendation: Option A1.** Surfaced as a non-blocking `user_decision` because the task
  explicitly requires the choice to be presented rather than picked silently.

## Context & Scope

Researched: what each side of the cycle actually consumes; whether either edge can be removed
by relocation; what else must change (doc anchors, invariant checks); the cost of the
alternatives; and the state of the CI wiring prerequisite. No files in the source tree were
modified; all compile checks used scratch copies against the current `.lake` build (after a
concurrent `lake build` by another agent completed).

## Findings

### Codebase Patterns

**Edge 1: `Conservativity/Plus/Corollaries.lean:8 -> Deterministic.Completeness`.**
The only consumer is the final theorem:

```lean
theorem detDerivable_ofFormula_iff (fc : FrameClass) (φ : Formula) :
    Deterministic.DetDerivable fc [] (ofFormula φ) ↔ ProofSystem.Derivable fc [] φ := by
  have h := Deterministic.detDerivable_iff_derivable_erasePlus fc (ofFormula φ)
  rwa [Deterministic.erasePlus_ofFormula] at h
```

It uses `DetDerivable` (Deterministic/System), `detDerivable_iff_derivable_erasePlus`
(Deterministic/Completeness.lean:184) and `erasePlus_ofFormula` (Deterministic/Erasure.lean:78,
in `Completeness`'s closure via `Collapse`). Its natural home is directly after
`detDerivable_iff_derivable_erasePlus` in `Deterministic/Completeness.lean`, of which it is the
`φ := ofFormula ψ` specialization.

Static import-closure check of `Conservativity.Plus.Forward`: contains
`Metalogic.StrongCompleteness` (source of `completeness_base` etc. used by
`tmFragIffPlus*`), `Theorems.TemporalDerived`, `Semantics.PlusNonValidities`; does NOT contain
`Deterministic.Completeness`. So the remaining corollaries lose nothing.

**Edge 2: `Deterministic/Soundness.lean:9 -> Conservativity.Plus.PlusSoundness`.**
The only consumed names are `plusAxiom_validIn` and `plusAxiom_swap_validIn`, both defined in
`Conservativity/Plus/AxiomValidity.lean` (lines 155, 276) — `PlusSoundness` itself contributes
only the mirrored proof pattern. Narrowing the import to `AxiomValidity` is a hygiene
improvement but does not change the directory-level edge.

**No reverse dependency on Corollaries.** `Deterministic.Completeness`'s closure does not include
`Conservativity.Plus.Corollaries`; `Corollaries` is imported only by the `Conservativity/Plus.lean`
aggregator. No Lean file or test references `detDerivable_ofFormula_iff`.

### External Resources

- No Mathlib search was needed: the question is purely structural (import graph and declaration
  location). Lean verification was done with `lake env lean` on scratch files.

### Recommendations

#### Option A1 (recommended) — relocate the dependent theorem into `Deterministic/`

Change set:

1. `FormalSystem/Metalogic/Deterministic/Completeness.lean`: add `detDerivable_ofFormula_iff`
   (docstring kept verbatim, including its `Paper: —` line) after
   `detDerivable_iff_derivable_erasePlus`, inside `namespace FormalSystem.Metalogic.Deterministic`;
   drop the `Deterministic.` qualifiers. Add it to the module's "Main Results" list. (`Formula`
   needs `open FormalSystem.Syntax`, already present.)
2. `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean`: delete line 8
   (`import FormalSystem.Metalogic.Deterministic.Completeness`), the "transfer back to the L level"
   section and theorem, and the `detDerivable_ofFormula_iff` bullet in the module docstring (or
   replace it with a one-line pointer to its new home).
3. Fully-qualified name changes `FormalSystem.Metalogic.Conservativity.detDerivable_ofFormula_iff`
   -> `FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff`. Update:
   - `docs/theorem-index.md:177` (name and file columns) — **required**: invariant C15 in
     `check-module-invariants.sh` asserts every theorem-index row is anchored at its declaration;
   - `FormalSystem/Metalogic/Conservativity/Plus/README.md:36` and `:49`;
   - `FormalSystem/Metalogic/Deterministic/README.md` file table row for `Completeness.lean`.
4. Optional hygiene: narrow `Deterministic/Soundness.lean:9` to
   `Conservativity.Plus.AxiomValidity` (and its docstring reference stays valid). Not needed for
   the cycle; only do it if a build confirms nothing else in `Deterministic` relied on
   `PlusSoundness` transitively.
5. `FormalSystem/Metalogic/README.md:73` becomes true again with no textual change; re-verify.
   `scripts/check-metalogic-cycles.sh`, ADR-006, and `docs/development/MODULE_INVARIANTS.md`
   remain correct as written (they all assert count 1).
6. Final phase: wire `bash scripts/check-metalogic-cycles.sh` into `.github/workflows/ci.yml` as
   its own named step (script has no Lake dependency, runs in <1s, can precede the lean-action
   step), following the pattern task 583 records; verify with a deliberately introduced import
   that the step fails and names the script.

Sorry-free path: yes — no proofs change, only declaration location. Axiom footprint of the
relocated theorem verified as the ambient three.

#### Option A2 — lift the other edge's dependency into a third directory

Move `plusAxiom_validIn` / `plusAxiom_swap_validIn` (and so `AxiomValidity.lean`, which imports
`Atomization.lean`; ~520 lines together, plus `PlusSoundness` if kept together) out of
`Conservativity/` into a shared location. These modules are imported by
`Conservativity/Plus/{Forward,PlusSoundness}`, `Conservativity/Star/*`,
`Independence/CoarsenedModels.lean` and `Metalogic/Soundness.lean` references; every importer's
path changes and new directory edges must be re-checked. Several times the cost of A1 for the
same outcome, and it would move the *correct*-direction dependency. Not recommended.

#### Option B — accept and re-baseline

Script count 1 -> 2 with a header naming both cycles; rewrite `Metalogic/README.md:73`,
ADR-006 lines 18/21/62/94-95 and `MODULE_INVARIANTS.md:273`; new ADR recording why the cycle is
accepted. More edits than A1, leaves a genuine layering inversion in place, and contradicts
ADR-006's own consequence ("a future proposal ... must first show the cycle is gone ... by
relocating"). Not recommended.

## Decisions

- Recommend Option A1 over A2 and B on measured cost (A1 compiles; A2 touches 5+ importers; B
  requires more documentation churn than A1's whole change set).
- Relocate into `Deterministic/Completeness.lean` rather than a new file: the theorem is a direct
  specialization of a declaration there, and a new file would need an aggregator entry and C6/C24
  manifest bookkeeping for no benefit.
- `user_decision` set non-blocking: the task text requires presenting the choice, but A1 is
  reversible and unambiguous on the evidence, so the loop may proceed on it.

## Risks & Mitigations

- **Name change breaks an external reference.** Only `docs/theorem-index.md` and two READMEs
  reference the name (grep over repo excluding `.lake`/`specs`). Mitigation: update all three in
  the same commit; C15 catches the index row if missed.
- **Scratch compile was fast (~2s) because oleans were warm.** Mitigation: implementation must
  still run a full guarded `lake build` and `check-module-invariants.sh` (C4, C6, C15, C24).
- **Concurrent agents building.** Another agent's `lake build` was running during research;
  implementation should use the build guard (`lake-build-guard.sh`) per `long-builds.md`.
- **Task 583 not yet done**, so the CI wiring pattern is not yet recorded. Mitigation: plan the CI
  phase to follow 583's pattern if it has landed; otherwise add a minimal self-contained step
  whose name names the script, and note it for 583 to conform.
- **Regression.** The whole reason this landed undetected was lack of CI; the final phase closes
  that.

## Tactic Survey Results

- Not applicable (no tactic survey performed; no proof changes — relocation only).

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| relocated `detDerivable_ofFormula_iff` in `Deterministic` namespace | `have h := ...; rwa [erasePlus_ofFormula] at h` (existing proof) | success | `detDerivable_iff_derivable_erasePlus`, `erasePlus_ofFormula` |

## Context Extension Recommendations

- **Topic**: Resolving directory-level import cycles
- **Gap**: ADR-006 records the Bundle <-> Core precedent (relocate the dependency) but not the
  complementary case where the dependent declaration is misfiled.
- **Recommendation**: add a short "how to break a directory cycle" note (which edge is the
  inversion; relocate the single consuming declaration when the edge has one consumer) to
  `docs/development/MODULE_INVARIANTS.md` next to the cycle-script entry.

## Appendix

Verification commands run:

```
bash scripts/check-metalogic-cycles.sh                          # exit 1, 2 cycles (baseline)
lake env lean scratch/CorNoDet.lean                             # exit 0, no output
lake env lean scratch/DetMoved.lean                             # exit 0; axioms: propext, Classical.choice, Quot.sound
bash sim/scripts/check-metalogic-cycles.sh  (simulated tree)    # PASS exactly 1 cycle, exit 0
grep -rn detDerivable_ofFormula_iff (excl. .lake, specs)        # theorem-index.md:177, Plus/README.md:36,49, Corollaries.lean
```

No rate-limited search tools were used.
