# Implementation Summary: Task #559

- **Task**: 559 - Nondeterministic canonical model / TM⋆ completeness (narrowed to the naming-rule soundness toolkit)
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T00:07:24Z
- **Completed**: 2026-11-05T01:50:00Z
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/04_naming-rule-soundness-toolkit.md, summaries/04_naming-rule-soundness-toolkit-summary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Report 03's naming-rule soundness toolkit is ported from its Mathlib-only probe into the library,
restated against the repository's own `FrameOver`, `WorldHistory` and `PlusTruthAt`. Three of the
dispatch's four deliverables landed sorry-free with no new axiom: truth invariance under two-way
bounded morphisms (the load-bearing lemma), Gabbay's plain irreflexivity rule, and the stronger
clock rule. The fourth, the Auxiliary-Atoms expansion, did not port; its obstruction is located
precisely and recorded in the library rather than in this task's disposable directory.

## What Changed

- `FormalSystem/Semantics/HistoryMorphism.lean` — deliverable item (1) and its toolkit.
  `HistMorphism.plus_invariance` (L⁺ truth is invariant along any history-lifting morphism — the
  seven-case induction, ported from `HybridInvariance.lean`'s `regFree_invariance`);
  `HistMorphism.plusValidOn` (L⁺ frame validity travels from the source of a morphism to its
  image); `TwoWayBounded` with `exists_preimage_step` and `exists_preimage_step_neg`;
  `TwoWayBounded.exists_histMorphism_of_isZTime` (over discrete time `HistMap.lift` is derivable
  from the one-task `step` condition, so it need not be primitive) and
  `TwoWayBounded.plus_invariance_of_isZTime` (the composition, landed as a named corollary so the
  claim is machine-checked rather than asserted). New imports:
  `FormalSystem.PlusLanguage.PlusValidity` and `FormalSystem.Semantics.DurationClassification`.
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` —
  `FrameOver.translationProduct_twoWayBounded`, the worked non-vacuity instance of
  `TwoWayBounded`: `Prod.fst` on a translation product, the underlying function of the existing
  `FrameOver.translationProductProj`.
- `FormalSystem/Metalogic/NamingRules.lean` — **created**. `Fresh` (with three non-vacuity
  `example`s), `plusTruthAt_congr_of_fresh` (what discharges the auxiliary letter), the antecedent
  bundle `nm` / `once` / `rigid` / `clockAnte`, the clock valuation `clockModel` with its four
  truth characterisations (`plusTruthAt_atom_clock`, `plusTruthAt_nm`, `plusTruthAt_once`,
  `plusTruthAt_rigid`, `plusTruthAt_clockAnte`), and the two rules: `clock_irr_sound`
  (deliverable item 3) and `irr_sound` (deliverable item 2).
- `FormalSystem/Metalogic.lean` — the new module's import, plus a `## Naming rules` docstring
  section stating what the two rules do and do not settle.
- `FormalSystem.lean` — regenerated with `lake exe mk_all --lib FormalSystem` (check C33).
- `docs/theorem-index.md` — new `### Naming rules and model transformations` subsection, ten rows.
- `scripts/check-module-invariants.sh` — ten `#print axioms` lines and the ten matching measured
  baseline lines, in the same order, in the C14 heredoc pair.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Semantics/README.md`, `FormalSystem/README.md`,
  `FormalSystem/Semantics/Frames/README.md`, `README.md` — module rows and regenerated inventory
  counts.
- `typst/generated/status.typ` — regenerated at each commit (the pre-commit gate compares its
  recorded line count against a live regeneration).

## Decisions

- **The lift is built through `intIso`, not through a `succ`/`pred` Archimedean iterate.**
  `Semantics/DurationClassification.lean`'s `intIso : ↑D ≃+o ℤ` makes `m • δ = intIso.symm m`
  exact for `δ := intIso.symm 1`, so the history to be lifted is a `ℤ`-indexed chain of base
  states and the two recursion halves are ordinary `ℕ`-recursions glued by one `chain` function.
  This avoids having to prove that `Order.succ` is translation by a fixed step as a side lemma.
- **`chain_rel` is the step the probe got for free.** A world history must respect the task
  relation at *every* pair of times, not only at consecutive ones, so single `δ`-tasks have to be
  composed (`FrameOver.forward_comp`, with `FrameOver.reflection` for the backward direction).
  The digraph mirror gets this from `IsWalk`; the library does not.
- **`HistMorphism.plusValidOn` is landed in the only direction that holds.** The plan's
  parenthetical reads "validity on the source follows from validity on the image" while naming
  `plusValidOn_of_prod` as the template; those are opposite, and `frame_validity_not_reflected`
  refutes the image-to-source direction. Landed source-to-image.
- **The clock rule reuses the library's translation product.** No second clock construction was
  built: `translationProduct_sat`, `translationProduct_isRegular`, `clock_eq`, `liftH`,
  `liftModel`, `plus_invariance` and `projH_liftH` cover every model-transformation step, which is
  what the plan's Phase-5 Scope Hypothesis predicted.
- **`Fresh` is naming-rule-local.** No `atoms` function was added to the syntax layer, so no
  dependent of `PlusLanguage/Formula.lean` was rebuilt for a notion only these two rules consume.
- **The Phase-7 obstruction is recorded in the library, not only in `specs/`.** The probes and
  reports are disposable by design, so the account lives in `NamingRules.lean`'s module
  docstring, citing no `specs/` path (which would leave checks C9/C32 pointing at deleted files).

## Plan Deviations

- **Phase 1** altered: imported `FormalSystem.PlusLanguage.PlusValidity` rather than the plan's
  `PlusTruth`, which does not supply `TaskFrame.PlusValidOn`. No cycle — `HistoryMorphism` is
  absent from PlusValidity's 28-module import closure.
- **Phase 1** altered: `HistMorphism.plusValidOn`'s direction, per the decision above.
- **Phase 2** skipped: `TwoWayBounded.ofHistMap` / `HistMap.twoWayBounded`. Phase 3 consumes
  neither direction, and the step's own text forbids adding them speculatively.
- **Phase 2** altered: the worked `TwoWayBounded` instance landed in
  `Frames/TranslationProduct.lean`, which the phase's Files-to-modify list omits, because
  `HistoryMorphism.lean` is below it in the import order. The phase's own verification criterion
  requires the instance "as a worked instance, not as prose", so the file list was the defect.
- **Phase 3** altered: both recursion halves are `ℕ`-recursions glued by a `ℤ`-indexed `chain`
  rather than `Order.succ`/`Order.pred` recursions, and the phase added
  `import FormalSystem.Semantics.DurationClassification`, which its no-import-change tier
  assumption did not anticipate. `PredOrder`/`IsPredArchimedean` are carried as binders for the
  `IsZTime` reading of the name without being consumed.
- **Phase 5** altered: four truth characterisations rather than three — `plusTruthAt_rigid` was
  split out from `plusTruthAt_clockAnte`, since the `⊡`-rigidity argument is independent of the
  trichotomy argument for `once`.
- **Phase 7** closed `[COMPLETED WITH EXCLUSIONS]`: `aa_expand` did not land. See
  *Follow-ups* and the plan's `#### Reasoned Exclusions` table.
- **Scope**: task 559's declared `file_scope` omitted `Frames/TranslationProduct.lean` and
  `FormalSystem.lean`; `git-commit-scoped.sh`'s V10 guard dropped the first from the Phase-2
  commit. `file_scope` was extended with both and the dropped file landed as a Phase-2.1
  sub-step commit.

## Verification

- Build: Success — full `lake build` through `lake-build-guard.sh`, `exit_status=0`,
  2898 jobs, zero `error:` lines over both captured streams, and every touched module's `.olean`
  newer than its source. A full-project build gated every phase boundary, not only the end.
- Sorry count: 0
- Vacuous count: 0
- Axiom count: 0 new axioms (`grep -c '^axiom ' ` unchanged)
- Measured axiom profiles (`#print axioms`, never typed by hand; now pinned by C14):
  - `HistMorphism.plus_invariance` — `[propext, Quot.sound]`
  - `HistMorphism.plusValidOn` — `[propext, Quot.sound]`
  - `TwoWayBounded.exists_preimage_step_neg` — `[propext, Classical.choice, Quot.sound]`
  - `FrameOver.translationProduct_twoWayBounded` — `[propext, Classical.choice, Quot.sound]`
  - `TwoWayBounded.exists_histMorphism_of_isZTime` — `[propext, Classical.choice, Quot.sound]`
  - `TwoWayBounded.plus_invariance_of_isZTime` — `[propext, Classical.choice, Quot.sound]`
  - `NamingRules.plusTruthAt_congr_of_fresh` — `[propext]`
  - `NamingRules.plusTruthAt_clockAnte` — `[propext, Classical.choice, Quot.sound]`
  - `NamingRules.clock_irr_sound` — `[propext, Classical.choice, Quot.sound]`
  - `NamingRules.irr_sound` — `[propext, Classical.choice, Quot.sound]`
- `bash scripts/check-module-invariants.sh`: 53 checks PASS — C1 (`lake build` exits 0), C2, C3
  (zero structural `sorry`), C5 (markdown module paths, with the two namespace entries this task
  added to `scripts/module-invariants-allowlist.txt`), C14 (both halves: no stale documented
  counts, and every pinned declaration matches its axiom baseline, including the ten rows this
  task measured and pasted), C15 (all 337 theorem-index rows anchored at their declaration), C23
  (with the `plus_invariance` shadow pair recorded in `SHADOW_PAIR_ALLOW`), C33 (the regenerated
  root aggregator is byte-current) and INV (regenerated inventories) among them. **One group
  fails: C16**, and its single finding is `mem_cellAt_of_shift_of_hasForwardSlack` in
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — a declaration in a file this
  task never touched (`git status` reports it unmodified; it was last committed by earlier work).
  This task introduced exactly one C16 finding of its own, an unused `[IsPredArchimedean ↑D]`
  instance binder on `TwoWayBounded.exists_histMorphism_of_isZTime`, and removed it; the
  invariants run that followed reports one error where the run before it reported two. The
  foreign finding is **not** grandfathered: `lake exe runLinter --update` was deliberately not
  run, since it would grandfather that genuine regression along with everything else.
- Gate set: `bash .claude/scripts/verify-deploy.sh` → **PASS, 15 checks, 0 failures** (gates 20-24
  SKIP by their own source-store-only guard, this repository being a deploy consumer). Run in
  full, so the dispatch's batch-stage deferral was not used.
- Tests: N/A (no test-library change)
- Files verified: Yes
- Non-vacuity is machine-checked, not asserted: `TwoWayBounded` has the worked
  `translationProduct_twoWayBounded` instance, `Fresh` has its three accept/reject `example`s,
  and `plusTruthAt_clockAnte` exhibits the clock rule's antecedent as satisfiable on the product,
  so its premise is not trivially unprovable.

## Impacts

- `HistMap.lift` is no longer the only route to a history-lifting morphism: a caller with a
  two-way bounded surjection over discrete time gets one from
  `TwoWayBounded.exists_histMorphism_of_isZTime`, and L⁺ invariance with it. That is a reusable
  model-transformation tool with no previous substitute in the tree.
- `HistMorphism.plus_invariance` generalises `Frames/TranslationProduct.lean`'s
  translation-product-specific `plus_invariance` to an arbitrary morphism, which is the form any
  future completeness engine for this logic would consume.
- Any such engine now has the soundness of both naming rules available as library facts rather
  than as sketches.
- `FormalSystem/Semantics/` now transitively imports `FormalSystem/PlusLanguage/`. That widening
  was the plan's own choice of home for the L⁺ invariance; it is acyclic and the full gate set is
  green with it.

## Follow-ups

- `aa_expand` (the Auxiliary-Atoms expansion) is **not** landed. The obstruction is
  `TaskFrame.Saturation`, a required argument of `FrameOver.ofReflectiveRegular`: on the
  unravelled carrier none of this tree's three discharges applies —
  `saturation_of_finite` binds `[Finite W]` (and the unravelled carrier is infinite whenever the
  base carrier is, which `FrameOver.worldNonempty` guarantees for every frame);
  `saturation_of_fib_finite` wants finite fibres that an arbitrary `FrameOver D` does not supply;
  `saturation_of_deterministic` wants determinism that the unravelling contradicts by design.
  Unblocking it needs a direct *Saturation* proof for a path-recording relation, or a fourth
  discharge route in `Semantics/TaskFrame.lean`. That is a research-grade subproblem.
- The plan's finding (d) is **refuted**: a step-counting path record IS compositional over
  discrete time, as Phase 3's own `chain_rel` machine-checks for exactly this shape of
  construction. Anyone revisiting `aa_expand` should not re-litigate compositionality.
- Lifting a history along a two-way bounded morphism over **dense** time is left explicitly
  unattempted: the walk has no next step to take there, and the construction would need a
  fibre-relative saturation property that `forth` and `step` do not supply.
- The four reports and five probes under this task's directory are now disposable, as the
  dispatch intended, with the exception of `probes/05_stab-definable-from-open-modals.lean`,
  which belongs to another live task and was not touched.

## References

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/plans/04_naming-rule-soundness-toolkit.md`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/03_morphisms-clock-rule-lc-schema.lean`
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/handoffs/` — the seven
  phase-end handoffs, including the Phase-7 obstruction record
