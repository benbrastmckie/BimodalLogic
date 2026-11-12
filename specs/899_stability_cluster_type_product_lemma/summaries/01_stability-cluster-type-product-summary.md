# Implementation Summary: Task #899

- **Task**: 899 - The stability cluster's (past-type, future-type) set is a full product
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T02:46:33Z
- **Completed**: 2026-11-12T03:09:05Z
- **Effort**: ~4 hours across three single-phase hard-mode dispatches (seq 7, 9, 11)
- **Dependencies**: None
- **Artifacts**: plans/01_stability-cluster-type-product.md, reports/01_stability-cluster-type-product.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The product statement the task asks for is now in the tree, sorry-free and gate-clean: for a
regular frame, the set of (past-type, future-type) pairs realized by histories through
`τ.state t` at `t` equals the product of the realized past-types with the realized future-types.
Six declarations landed in `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` by
the route the dispatch named — `paste` with `paste_agreeUpTo`/`paste_agreeFrom` feeding the
semantic `PastDet`/`FutDet` predicates — the headline theorem is pinned in both ledger surfaces
at its *measured* axiom profile, and every line-count surface the Lean edit moved is reconciled.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` — six new declarations
  (Phase 1, commit `8ce83e659`), 610 -> 743 lines:
  - `pastType`, `futType`, `typePair` — plain computable `Set PlusFormula`-valued definitions
    (`Bool`/`Finset` forms would need `Decidable (PlusTruthAt M σ t φ)` and force
    `noncomputable`).
  - `typePair_image_stabClass` — the headline product theorem, `[F.IsRegular]` plus pointwise
    `PastDet`/`FutDet` hypotheses. The `⊇` direction is where `paste` and regularity are
    consumed: given `ρ, σ ∈ stabClass τ t` agreeing at `t`, `paste ρ σ t hsame` lies in the
    cluster and inherits `ρ`'s past-type (via `paste_agreeUpTo` + `PastDet`) and `σ`'s
    future-type (via `paste_agreeFrom` + `FutDet`).
  - `typePair_image_stabClass_state_congr` — the declaration that literally says "state-level
    datum": the image depends only on `τ.state t`, needing neither regularity nor
    determinedness.
  - `typePair_image_stabClass_of_sepClauses` — the clause-pair corollary, so a separated clause
    list plugs in without reshaping.
- `docs/theorem-index.md` — exactly one new row (Phase 2, commit `b3bca557c`) at the end of the
  Expressiveness band's open-future-elimination table, plus one prose paragraph stating what the
  row is and is not.
- `scripts/check-module-invariants.sh` — one matched C14 heredoc pair pinning
  `typePair_image_stabClass`'s measured axiom profile.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks (Phase 3):
  `Expressiveness/` 111,723 -> 111,856 lines (= +133, matching 743 - 610) and the root totals.
- `FormalSystem/Metalogic/Expressiveness/README.md` — the hand-maintained Modules-table row for
  `OpenFutureElimination.lean`: Lines 599 -> the measured 743, Description extended to name the
  type product, `*Last verified:*` refreshed to 2026-11-11.

## Decisions

- **Siting is `OpenFutureElimination.lean`, not the dispatched `PlusPasting.lean`.** The import
  chain `PlusPasting → OpenClasses → OpenLanguage → OpenFutureElimination` makes the dispatched
  target unable to see `PastDet`, `FutDet` or `stabClass`; a compiled negative probe measured
  exactly that. The correction travelled through the plan's `Files to modify` blocks.
- **Two independent lists `A B : List PlusFormula` with pointwise hypotheses is the primary
  shape**, with the `SepClauses` clause-pair form derived. Nothing in the product statement pairs
  the `i`-th past formula with the `i`-th future one.
- **The Axioms cell carries the measured `[propext, Quot.sound]`, not the neighbours' `pcq`.**
  The profile is genuinely unusual in this ledger, which is why the row is landed together with
  the C14 baseline pair that re-asserts it on every run.
- **R5 (the `hA`/`hB` non-droppability countermodel) is a docstring remark, not a Lean
  declaration**, and says so: a concrete model over `intOrder` realizing two distinct types
  inside one stability cluster is a model-construction job of uncertain size, and no gate decides
  the question.
- **The `sepZ` instantiation stayed out of scope** for the same import-direction reason;
  `typePair_image_stabClass_of_sepClauses` plus `probes/02_sepz-plug-point.lean` record what a
  future consumer needs.
- **Lines cells are set to measured values, never to a delta on a stale one.** The Expressiveness
  README's 599 carried pre-existing drift against a 610-line pre-task file.

## Plan Deviations

- **Testing & Validation, `lean-challenge-snapshot.sh --check` item** altered: no Challenge
  manifest exists for this task (`--check 899 <root>` exits 71 with nothing to compare against),
  and taking a snapshot post-implementation would trivially match and certify nothing. Statement
  Fidelity was evidenced instead by a verbatim comparison of the six landed signatures against
  the plan's own `## Lean Challenge Statements` block — they match exactly, modulo `sorry` being
  replaced by a real proof body. The verdict is ADVISORY by the script's own header and is
  recorded, not waived.
- Phases 1 and 2 recorded no deviations. Phase 3's checklist executed as written otherwise.

## Verification

Phase 3 declares `**Verification Tier**: full`, unchanged. The dispatch directive's Batch Gate
Deferral applies, and the narrowing was UNMAPPABLE in both offered forms — checked rather than
assumed: `.claude/scripts/tests/` carries no suite basename for `check-module-invariants.sh`,
`scripts/typst-sync-check.sh`, `scripts/readme-lint.sh`, `scripts/check-metalogic-cycles.sh` or
`scripts/check-copyright-headers.sh`, and `verify-deploy.sh` resolves
deploy-tree-vs-source-store gates with no gate expressing a `FormalSystem/**` Lean build. Under
the directive's UNMAPPABLE CRITERION clause the six named checks were therefore run DIRECTLY, and
that is the recorded scoped discharge; the complete gate set is deferred to the batch stage at
the end of the invocation, never forgiven.

- Build: **Success**. `lake-build-guard.sh build --timeout 1800 -- build`, detached as a
  shell-level background job with the bounded `kill -0` waiter in one call: `GUARD_EXIT=0`;
  `Build completed successfully (2974 jobs)`; 0 `error:`, 0 `warning:` across both captured
  streams; `OpenFutureElimination.olean` confirmed newer than its source. All three verdict tiers
  green.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **0** for this task. The single-line grep returns one tree-wide hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal ... := trivial`) — a genuinely trivial-closed goal in a
  pre-existing, out-of-scope file, recorded identically by all three phases.
- Axiom count: **14**, equal to the baseline. No new axiom. `typePair_image_stabClass` itself
  measures `[propext, Quot.sound]`, which is what the C14 baseline pins.
- `scripts/check-module-invariants.sh` (full, build-backed): **exit 0, zero FAIL lines**. The one
  INV FAIL Phase 2 recorded is resolved by Phase 3's regeneration. Read explicitly: `PASS C1`
  (both `lake build` and `lake build BimodalTest`), `PASS INV`, `PASS C14` (both assertions —
  including the new baseline line), `PASS C15` (93 paper anchors resolve; all 455 index rows
  carry their anchor), `PASS C16`, `PASS C19` (90.60% vs a 90% floor), `PASS C23`, `PASS C26`,
  `PASS C9` / `PASS C9D`.
- `scripts/check-module-invariants.sh --emit-inventory --check`: exit 0, no stale block. The
  Scope Hypothesis was confirmed BEFORE regeneration — the pre-run named exactly `README.md` and
  `FormalSystem/Metalogic/README.md`, and no surface the hypothesis omits.
- `scripts/typst-sync-check.sh`: exit 0, all 4 checks green. No `typst/` file was dirty in
  Phase 3, so nothing needed staging there.
- `scripts/readme-lint.sh`: exit 0, `RESULT: PASS`. 59 informational `STALE DATE` lines.
- `scripts/check-metalogic-cycles.sh`: exit 0. `scripts/check-copyright-headers.sh`: exit 0,
  755/755 conforming.
- Plan compliance: `COMPLIANCE_CHECK: passed` — all six planned declarations found in the
  resolved source roots.
- Files verified: Yes.

**Pre-existing findings naming no file in this task's scope**, enumerated as this run's recorded
baseline: the single vacuous-grep hit above, and 58 of the 59 `readme-lint` stale-date lines. The
59th names a file this task did touch — `FormalSystem/Metalogic/README.md`, stamped 2026-10-02
against a directory last changed 2026-11-11 — but is evidenced pre-existing rather than caused
here: at `8ce83e659~1`, before this task's first commit, that directory had already last changed
on 2026-11-11 (a different task's reconciliation phase) against the same stamp. It was not
refreshed, because the date-refresh step names only `Expressiveness/README.md` and the gate
passes.

## Impacts

- The initialization of the forward and backward Auxiliary-Atoms automata at the clock cut is now
  a state-level datum, available as a cited Lean theorem rather than an argued step:
  `typePair_image_stabClass_state_congr` says the realized pair-set depends only on `τ.state t`,
  and `typePair_image_stabClass` says that set is a full product.
- `typePair_image_stabClass_of_sepClauses` is the plug point for a separated clause list, so a
  consumer holding `SepClauses F L` needs no reshaping.
- `docs/theorem-index.md` and the C14 baseline set now assert the headline theorem's axiom
  profile on every gate run, so a future proof-body change that smuggles in `Classical.choice`
  fails C14 rather than passing silently.

## Follow-ups

- The `sepZ` instantiation — the point at which `separationOver_ztime` is actually consumed —
  remains unlanded by design. It cannot be sited in `OpenFutureElimination.lean` for the same
  import-direction reason the dispatched siting fails; it needs a module downstream of both.
  `probes/02_sepz-plug-point.lean` records the plug shape.
- The `hA`/`hB` non-droppability argument is reasoned from the definitions in a docstring remark,
  not machine-checked. A countermodel over `intOrder` realizing two distinct types inside one
  stability cluster would close that.
- No Challenge manifest was ever snapshotted for this task, so
  `lean-challenge-snapshot.sh --check` has no baseline here. A task wanting that advisory signal
  must take the snapshot at plan time, before implementation.
- `FormalSystem/Metalogic/README.md` carries a pre-existing stale `*Last verified:*` stamp
  (2026-10-02). Out of this task's scope and informational only.

## References

- `specs/899_stability_cluster_type_product_lemma/plans/01_stability-cluster-type-product.md` —
  the plan, including the pinned `## Lean Challenge Statements` block and the per-phase measured
  verification notes
- `specs/899_stability_cluster_type_product_lemma/reports/01_stability-cluster-type-product.md` —
  the research report
- `specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean`,
  `probes/02_sepz-plug-point.lean` — the compiled probes the proof body was transcribed from
- `specs/899_stability_cluster_type_product_lemma/handoffs/` — the three progressive phase
  handoffs
- Commits `8ce83e659` (phase 1), `b3bca557c` (phase 2), and this phase's own commit
