# Implementation Summary: Archive Dead Sorries to the Boneyard

- **Task**: 393 - review_archivable_sorries_to_boneyard
- **Type**: lean4
- **Status**: COMPLETED
- **Plan**: `specs/393_review_archivable_sorries_to_boneyard/plans/01_archive-dead-sorries-boneyard.md`
- **Research**: `specs/393_review_archivable_sorries_to_boneyard/reports/01_sorry-archivability-verdicts.md`
- **Phases**: 5 of 5 completed

## Outcome

**Live `sorry` count: 12 → 1.** Eleven verified-dead sorries were retired by moving three
declaration closures into `Theories/Bimodal/Boneyard/`. No proof work was performed; every
change is a move-plus-bookkeeping operation validated by `lake build`.

The single remaining live sorry is `WeakCanonical.countermodel_discrete`
(`Metalogic/WeakCanonical/Transfer.lean`), deliberately left untouched — it is the sole
`sorryAx` source reaching `BXCanonical.completeness`.

### Sorry trajectory

| Point | Live sorries | Build |
|-------|-------------:|-------|
| Baseline | 12 | green (1877 jobs) |
| After Phase 1 | 9 | green |
| After Phase 2 | 2 | green |
| After Phase 3 | 1 | green |
| After Phase 4 (docs only) | 1 | green |
| Final | **1** | green (1875 jobs); `BimodalTest` green (1910 jobs) |

### Machine verification (Phase 5)

- Whole-environment `Lean.collectAxioms` scan over all `Bimodal.*` constants: the `sorryAx`
  tainted set shrank from **47 declarations to exactly 3** — `countermodel_discrete`,
  `completeness`, `completeness'`. This is precisely the research report's predicted end state
  (islands 1 and 2 eliminated, island 3 intact).
- `#print axioms` on the four headline theorems, unchanged from the research baseline:

  | Theorem | Axioms |
  |---------|--------|
  | `completeness` | `[propext, sorryAx, Classical.choice, Quot.sound]` |
  | `completeness'` | `[propext, sorryAx, Classical.choice, Quot.sound]` |
  | `completeness_dense` | `[propext, Classical.choice, Quot.sound]` (clean) |
  | `completeness_discrete` | `[propext, Classical.choice, Quot.sound]` (clean) |
  | `countermodel_discrete` | `[propext, sorryAx]` (direct terminal sorry) |

- Zero live imports of any `Bimodal.Boneyard.*` module, and zero live references to
  `Bimodal.Metalogic.Bundle.SuccExistence`.
- Zero declared `axiom`s in live code, unchanged from baseline.
- Zero vacuous definitions introduced. (One pre-existing `:= trivial` hit in
  `Examples/TemporalStructures.lean:275` is a legitimate proof — the goal is definitionally
  `True` — and predates this work.)

## What Was Archived

### Phase 1 — `Boneyard/BundleSuccessorSeed/` (3 sorries)

Whole-file move of `Metalogic/Bundle/SuccExistence.lean` (1,178 lines, 72 declarations) via
`git mv`, with an `ARCHIVED (Boneyard) — never compiled.` docstring and `#exit` after the import
block. Its single live import edge (`Metalogic/Core/RestrictedMCS/Basic.lean`) used no
declaration from the file and was deleted.

All three sorries reduce to the same hole — `g_content u ⊆ u` / `h_content u ⊆ u`, i.e. the
T-axiom for `G`/`H`, unsound under open-guard `(t,s)` semantics. The two `..._axiom`-suffixed
declarations were **not** promoted to declared Lean `axiom`s: they have zero live consumers, and
their only written justification is the removed BX1.

### Phase 2 — `Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean` (7 sorries)

Declaration excision of the `## Until/Since Step Properties` section from
`Bundle/SuccRelation.lean` (`until_unfold_in_mcs`, `since_unfold_in_mcs`,
`until_persists_through_succ`, `or_until_in_mcs`, `or_since_in_mcs`, `g_content_subset_mcs`,
`h_content_subset_mcs`). The rest of `SuccRelation.lean` stays live and its consumers still
build. Prose references in `Bundle/TemporalCoherence.lean` and `Bundle/UntilSinceCoherence.lean`
were re-pointed at the archive.

### Phase 3 — `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean` (1 sorry)

The `chronicle_gap_contradiction` `sorryAx` closure, moved as ONE unit spanning two files: 9
declarations from `BXCanonical/Chronicle/ChronicleToCountermodel.lean` plus
`countermodel_discrete_reynolds` from `WeakCanonical/Transfer.lean`.

**The closure did not grow.** Sub-step 3.1 (heads) was committed green; after sub-step 3.2
(tails), `lake build` was green on the first attempt, so the fixpoint in 3.3 closed immediately.
Final closure: 10 declarations — the 8 audited plus the two adjacent sorry-free private helpers
`limit_f_some_future_of_lt` and `limit_f_not_G_neg_of_mem`, which had no call sites outside the
moved section. (Contrast the `StaviDiscretePath` precedent, where an audited 16-declaration
closure grew to 24.)

Sorry-free orphans created by this excision were deliberately left live per the plan's non-goals:
`cantor_bfmcs_discrete_restricted_buc`, `succ_embed_squeeze`, `succ_embed_squeeze_strict`,
`succ_embed_no_gap`. Removing them widens the diff without retiring a sorry.

### Phase 4 — Documentation corrections

The load-bearing correction is the `countermodel_discrete_reynolds` vs `..._reynolds_v2`
conflation. `Transfer.lean` asserted the former "is now sorry-free" and called it the active
path; it was in fact `sorryAx`-tainted with zero consumers. The sorry-free discrete theorem is
`countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean`). Corrected in
`Transfer.lean` (module docstring + deprecation block, rewritten as "the one live sorry"),
`BXCanonical/Completeness.lean`, `ReynoldsBridge.lean`, `MCSMixedCase.lean`,
`WeakCanonical.lean`, and `ReflexiveCanonical.lean`.

Two stale records were also corrected:

- `ChronicleToCountermodel.lean`'s retention note ("excising any of them breaks `lake build` —
  keep them") was right about *piecemeal* excision only. Its cited consumer,
  `countermodel_discrete_enriched`, had itself already been archived. Rewritten as a tombstone.
- `DeadChronicleGapElimination/README.md` claimed `chronicle_gap_contradiction` and
  `succ_cofinal` had already been archived; an earlier pass had copied them without excising
  them. The README now states this plainly and corrects its "Sorry Chain" section, which claimed
  `succ_embed_surjective` "still in live code, now uses axiom instead" — it never used an axiom
  (it inherited taint through a `letI` binding), and it has now moved.

### Boneyard bookkeeping

- New: `BundleSuccessorSeed/README.md`, rewritten `DeadChronicleGapElimination/README.md`,
  extended `SorriedDeclExcisions/README.md` (new inventory row; the "must not move" entry for
  the chronicle trio rewritten as a **Superseded** note).
- Root `Boneyard/README.md`: three rows touched (`BundleSuccessorSeed` new;
  `SorriedDeclExcisions` 5 → 6 files / 3,342 lines; `DeadChronicleGapElimination` 2 → 3 files /
  1,939 lines with `Archived From` now spanning both source directories). `**Total**` updated to
  **92 files / 58,476 lines**, measured from the tree.
- All new/updated rows use `--` in the Task column; no Task Cross-References row was added, per
  `.claude/rules/no-task-references-in-deliverables.md`.
- Note: the prior `**Total**` of 89 files / 56,181 lines was itself slightly stale (actual
  pre-task count was 89 / 56,173). The new total is measured, not derived.

## Follow-Up Recommendation

**Prove `WeakCanonical.countermodel_discrete`** — the sole `sorryAx` source reaching
`BXCanonical.completeness`. This is a task in its own right, comparable in effort to the original
Reynolds pipeline landing, and should not be folded into archival or cleanup work.

The obligation: from a **Base**-MCS `A` with `□(U(⊤,⊥)) ∈ A` and `¬φ ∈ A`, build a discrete
countermodel.

- **Scope route (i) first**: a Base-MCS → Discrete-MCS transfer lemma that lets
  `countermodel_discrete_reynolds_v2` apply. That theorem's signature demands
  `SetMaximalConsistent (fc := FrameClass.Discrete)`, and a Base-MCS is not automatically
  Discrete-consistent, which is the entire gap.
- **Route (ii)**: a Henkin-style discrete canonical model built directly from a Base-MCS. Larger.
- **Do not attempt the old BX-pipeline route.** It is *provably* unavailable: it terminates in
  `succ_cofinal`, refuted by the ℤ+ℤ counterexample documented in
  `Boneyard/BXPipelineGapAnalysis/` (two copies of ℤ with constant MCS satisfy all
  `PriorModelData` hypotheses yet have a Dedekind gap). The whole route is now archived in
  `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`.

Until it lands, `completeness` and `completeness'` legitimately carry `sorryAx` while
`completeness_dense` and `completeness_discrete` remain clean — the honest current state.

## Plan Deviations

- None (implementation followed plan).

## Files Modified

**Archived (new or moved into `Boneyard/`)**:
- `Theories/Bimodal/Boneyard/BundleSuccessorSeed/SuccExistence.lean` (moved, `git mv`)
- `Theories/Bimodal/Boneyard/BundleSuccessorSeed/README.md`
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/BundleUntilSinceStep.lean`
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`

**Boneyard bookkeeping**:
- `Theories/Bimodal/Boneyard/README.md`
- `Theories/Bimodal/Boneyard/SorriedDeclExcisions/README.md`
- `Theories/Bimodal/Boneyard/DeadChronicleGapElimination/README.md`

**Trimmed live sources**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean`

**Documentation corrections**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`
