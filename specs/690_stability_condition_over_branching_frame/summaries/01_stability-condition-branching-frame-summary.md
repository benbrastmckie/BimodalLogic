# Implementation Summary: Task #690

- **Task**: 690 - Build the stability condition (C5) `StabFaithful` on the branching witness frame
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-28T18:21:12Z
- **Completed**: 2026-09-28T19:33:00Z (dispatch end; task not complete)
- **Effort**: ~8 hours across 16 of 22 phases
- **Dependencies**: None blocking. Territory overlap with concurrent tasks 623 and 684, honored.
- **Artifacts**: plans/01_stability-condition-branching-frame.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1–15 of 22 are complete and green. The stability condition (C5) `StabFaithful` is now
**stated natively over `PlusFormula.stab`** on an L⁺-indexed branching certificate, and is
**decidable by a bounded window scan** that quantifies over no walk of the frame. Stage A
extracted the branching substrate into a label-free `SharingSkeleton`, which the L⁺ certificate
inherits rather than duplicates; the shipping deterministic certificate and its JSON export
contract are unchanged in name, meaning and shape.

Phase 21 is also complete, executed **out of plan order** while Phase 16 is blocked: its declared
`Depends on: 20` was wrong, and its real dependencies (Phases 12 and 15) were already met. (C5)
now has a concrete two-lasso witness on which it **holds and separates** `⊡Fp` from `Fp`, and a
proof that it **degenerates** to `⊡φ ↔ φ` on any deterministic specialization.

Phase 16 is **[BLOCKED]** — not on a proof difficulty, but on this plan's own Phase 1 gate, which
Phase 1's measurement has now tripped. See "Follow-ups". Phases 17–20 and 22 are not started.

## What Changed

### Stage A — the label-free substrate (Phases 2–5)

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — **new, 944 lines**.
  `SharingSkeleton` and the entire branching theory on it: `rep`, `share` and its equivalence
  laws and two periodicities; `Thread`/`Step`/`ReachN` and their four congruences; the
  `shareSetoid` quotient, `Conn`, `RelZ`, the `FrameOver intOrder` `frame` and all four
  `def:frame` constraints; `hist`, `thread_is_history` and `total_eq_thread`.
- `Sharing/{Basic,Thread,Frame,Histories}.lean` — reduced to re-export shells (208/179/258/105
  lines from 254/273/397/141). Every name they exported still resolves at its original statement
  and original implicit/explicit argument structure. `SharingWitnessFamily.skeleton` added.
- `Sharing/README.md` — records the measurement licensing the split and the three shell
  mechanisms below.

### Stage B–E — the L⁺ certificate (Phases 6–15)

- `FormalSystem/PlusLanguage/Subformulas.lean` — **new, 255 lines**. `PlusFormula.subformulas`
  (seven arms), the eight membership lemmas, `subformulas_trans`, `plusSubformulaClosure` and its
  eight projections including `plusClosure_stab`. Imports only `PlusLanguage/Formula.lean`.
- `PlusWitnessFamily/Closure.lean` — **new, 160 lines**. `plusClosureOf` and its eight
  projections including **`plusClosureOf_stab`**, the one (C5) gates on.
- `PlusWitnessFamily/Basic.lean` — **new, 350 lines**. `PlusLabelledLasso` (with `deriving
  DecidableEq`), `PlusWitnessFamily`, `PlusSharingWitnessFamily` and its `skeleton` projection
  with the thin re-exports of the whole substrate.
- `PlusWitnessFamily/Predicates.lean` — **new, 315 lines**. (C0) `PlusAtomCoherent`, (C1')
  `PlusLocalCoherentShare` (five clauses, not six), (C2') `PlusThreadFulfilling`, (C3)
  `PlusBoxFaithful`, (C4) `PlusTarget`, the two reductions, and **(C5) `StabFaithful`** with
  `stabFaithful_share_congr` and `stabFaithful_self`.
- `PlusWitnessFamily/Decide.lean` — **new, 772 lines**. The combined window at L⁺, the (C0) and
  (C1') collapses and instances, and **(C5)'s collapse and `decidableStabFaithful`**, plus a
  computed smoke test.

### Stage G — non-vacuity (Phase 21)

- `PlusWitnessFamily/Examples.lean` — **new, 400 lines**. `stabFaithful_diagonal`, the two-lasso
  witness `stabFamily` with its label and representative decodings, `stabFamily_stabFaithful`,
  `stabFamily_separates`, and a `#guard` running `decidableStabFaithful` on the witness.

Net across this task's own files: **+3,414 / −498 lines over 12 files**, in 15 commits
(`71cc381d7` … `99d2a9f4e`).

### The deliverable

```lean
def StabFaithful (S : PlusSharingWitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula),
    PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Del) →
      (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
```

It is not a `sorry`-bodied `def` carrying prose. It has two proved consequences
(`stabFaithful_share_congr`, `stabFaithful_self`), a `Decidable` instance that reduces to a
Boolean on a concrete family, a header recording why it is not a clause of (C1'), and — as of
Phase 21 — a concrete family that **satisfies it while separating `⊡Fp` from `Fp`**, plus a proof
that it collapses to the identity exactly when the frame stops branching.

### The non-vacuity witness

`stabFamily p` has two lassos over the closure of `⊡Fp` (`Fp := ⊤ U p`). Lasso `0` carries
`{⊡Fp, Fp, p}` at every time except `u = 0`, where it carries `{Fp}` alone; lasso `1` carries
`∅` everywhere. The representative segments are `repBack = [id]`, `repMid = [const 0]`,
`repFwd = [id]`, so the two indices name **one** world state at `u = 0` and distinct states
elsewhere.

`⊡Fp` is absent from the origin label because (C5) forces it out — the shared class at `u = 0`
contains lasso `1`, which lacks `Fp` — and present everywhere else, where the class is a
singleton. A global Boolean, which is what (C3)'s `box` clause reads, cannot vary that way, so
the witness is a direct demonstration that (C5) is strictly stronger than a box-shaped clause.

## Decisions

- **Stage A was taken rather than the R2 fallback.** All four substrate modules measured zero
  occurrences of `Formula`, `.L `, `.lab` and `.bx` across 1,065 lines, so the extraction was
  licensed, and its closeout passed. The L⁺ side duplicates **no** substrate: the whole Phase 9
  region contains no tactic proof at all.
- **Three shell mechanisms** were needed beyond the plan's plain delegations, each forced by a
  concrete downstream site and each recorded in `Sharing/README.md`:
  - `SharingWitnessFamily.skeleton` is `@[reducible]`, so `Fin S.skeleton.n` and
    `Fin S.lassos.length` unify at the transparency `rw`'s keyed matching uses
    (`Fulfil.lean:1177`).
  - `SharingWitnessFamily.Thread.step` is restated at the family's own `share` beside the
    `abbrev Thread`; dot notation resolves the family name first (`Fulfil.lean:1137`).
  - `SharingWitnessFamily.Conn` is restated *definitionally* rather than delegated, because
    `Specialize.lean:282` does `unfold SharingWitnessFamily.Conn` and then `split`s.
- **(C1') has five clauses, not six.** A sixth `stab` clause modelled on `box` would be a
  strictly weaker, wrongly-shaped condition wearing the right name. `grep -c 'PlusFormula.stab'`
  over `Predicates.lean` at Phase 10 returned 1, in the header note. The `stab` arm of
  `plusAtomClauseAt` and `plusShareClauseAt` is `True` for the same reason.
- **Phases 4 and 5 were closed as one atomic batch.** `Histories.lean` reads `Conn`
  definitionally, so there is no green intermediate state between them.
- **The witness places `p` everywhere except the origin, not only at `t = 1`.** A lasso's labels
  are periodic, so "only at `t = 1`" is not expressible on a singleton cycle; and putting the
  `p`-free position at the origin is what lets (C0) atom coherence hold across the one shared
  class as well. The separation the phase asks for is unaffected.
- **`stabFaithful_diagonal` is stated at a hypothesis, not against a constructed L⁺
  `toSharing`.** Building that construction is Phase 20's bundle work; the hypothesis form
  (`∀ u i j, skeleton.share u i j ↔ i = j`) covers every deterministic specialization, including
  the one Phase 20 will build, and is the shape the plan's own pinned signature uses.

## Plan Deviations

- **Phase 3** (`Leave SharingWitnessFamily.Thread as an abbrev`) altered: the `abbrev` is kept,
  but a family-level `Thread.step` restatement was added beside it, because the skeleton's field
  is stated at `S.skeleton.share` and two `rw [S.share_def]` sites in `Fulfil.lean` broke. The
  phase's requirement that `Fulfil.lean` be unmodified is met.
- **Phase 5** (`If any closeout check fails, revert Stage A`) not applicable: no closeout check
  attributable to Stage A failed.
- **Phase 9** (`If Phase 5's closeout failed, duplicate the substrate`) not applicable.
- **Phase 11** (`the two reductions`) altered: there is no deterministic L⁺ certificate to reduce
  to, so the reductions target `PlusWitnessFamily.PlusLocalCoherentLab` and `PlusFulfillingLab`
  — the one-position and per-lasso *shapes* of (C1') and (C2') — stated in the same phase.
- **Phase 13** (`delegate label-free lemmas to the skeleton`) altered: `rep_congr_back` and
  `rep_congr_fwd` are label-free but could not be sited on `SharingSkeleton`, because the
  `Periodic.unrollOf_congr_*` lemmas they instantiate are declared in `Sharing/Decide.lean`,
  downstream of `Skeleton.lean` in the import order.
- **Phase 16** BLOCKED before starting — see "Follow-ups".
- **Phase 21** (`Depends on: 20`) altered: executed out of plan order, ahead of Phases 16–20. The
  declared dependency was wrong — the phase touches no part of the Phase 20 bundle; its real
  dependencies are Phases 12 and 15, both complete. The plan's Phase 16 blocker entry and Phase
  21 dependency line both now record this.
- **Phase 21** (`p` labelled on lasso `0` at `t = 1`) altered: `p` is labelled at every time
  except `u = 0` instead, for the two reasons under "Decisions".
- **Phase 21** (`stabFaithful_diagonal` against the L⁺ analogue of `WitnessFamily.toSharing`)
  altered: stated at the pinned signature's `hdet` hypothesis instead.

## Verification

- **Build**: Success. Full `lake build` green, guard exit `0`, `Build completed successfully
  (2759 jobs)`, `grep -c 'error:'` over the captured log = `0`. The new `PlusWitnessFamily/`
  subtree is **not reachable from `FormalSystem.lean`** until Phase 22 registers it, so a plain
  `lake build` does not compile it; it was verified by the explicit module target
  `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples`, guard exit `0`,
  `Build completed successfully (1219 jobs)`, with the `.olean` written. `.olean` currency confirmed for all ten touched
  modules (nine by mtime; `Skeleton.lean` by a scoped `lake build` that exits 0 doing no work —
  its source mtime is newer only because the file was rewritten byte-identically during a revert,
  and Lake's cache is content-hash based).
- **Sorry count**: 0 (`lean-sorry-census.sh` over the resolved source roots).
- **Vacuous count**: 1, **pre-existing and not this task's** —
  `FormalSystem/Examples/TemporalStructures.lean:495`, last touched by task 656.
- **Axiom count**: 14, **unchanged** from the pre-change baseline at `71cc381d7`.
- **Deterministic path**: `#print axioms` over twelve baselined `SharingWitnessFamily`
  declarations spanning every layer Stage A moved is byte-identical to the Phase 1 record; every
  one is `[propext, Classical.choice, Quot.sound]`. `WitnessFamily/Examples.lean`'s six `#guard`s
  fire. `Predicates.lean`, `Decide.lean`, `Fulfil.lean`, `Agreement.lean` and `Specialize.lean`
  are unmodified.
- **(C5) decides, and computes**: `example ... : Decidable S.StabFaithful := inferInstance`
  elaborates, and three `#guard`s in `PlusWitnessFamily/Decide.lean`'s smoke test reduce
  `decidableStabFaithful`, `decidablePlusAtomCoherent` and `decidablePlusLocalCoherentShare` to
  Booleans on a concrete family whose target closure is `{⊡p, p}` — so the (C5) check is not
  vacuous on it.
- **Choice-freedom**: `grep -rn 'open Classical' PlusWitnessFamily/` returns nothing.
- **Plan compliance**: 28 of the 34 pinned declarations elaborate, checked by
  `#check @<name>` rather than by name grep. The 6 absent are exactly Phases 18–20's deliverables
  (`model`, `plusTruth_iff_mem`, `PlusCertifies`, `decidablePlusCertifies`, `PlusRefutes`,
  `plusRefutes_of_certifies`), all downstream of the blocked Phase 16. Phase 21's three
  (`stabFamily`, `stabFamily_separates`, `stabFaithful_diagonal`) now elaborate at the pinned
  shapes, and both theorems `#print axioms` to `[propext, Classical.choice, Quot.sound]`.
- **The witness computes**: the `#guard` on
  `decidableStabFaithful (stabFamily (Atom.mkBase "p"))` fires, so (C5)'s decision procedure
  accepts a family the branching structure makes non-trivial — not only the one-lasso smoke
  family whose classes are singletons.
- **Module invariants**: `check-module-invariants.sh --no-build` was run and every failure
  compared against the same run at `71cc381d7`, before any Lean change. The only new row
  attributable to this task is C33's `Sharing.Skeleton` (one of 11 modules missing from
  `FormalSystem.lean`; 10 predate this task), which Phase 22 registers.
- **Tests**: N/A (no test-suite change).
- **Files verified**: Yes.

## Impacts

- `SharingSkeleton` is now the single home of the branching substrate. Any certificate indexed by
  any formula type projects onto it and inherits 944 green lines rather than duplicating them —
  which is what made the L⁺ certificate affordable at all.
- The L⁺ certificate is a **parallel** export. No field was added to `WitnessFamily`,
  `SharingWitnessFamily` or `LabelledLasso`, so the consuming model checker's JSON contract is
  untouched, exactly as the recorded user decision (Route 1) requires.
- `Sharing/Predicates.lean`'s "Recorded gap: (C5) is not stateable here" header is now out of
  date in one respect — the condition *is* stated, in `PlusWitnessFamily/Predicates.lean`. Phase
  22 amends it to point there.
- Task 684's `Sharing/Stability.lean` consumes `total_eq_thread`, `share_of_cls_eq`, `cls_eq` and
  `Thread.const` and continues to compile unmodified through the Stage A shells.

## Follow-ups

- **Phase 16 is [BLOCKED] on this plan's own gate, and needs a decision before implementation
  resumes.** Phase 1 measured `Sharing/Fulfil.lean`'s label-dependent span, per declaration, at
  **723 lines** (806 label-free, 141 preamble) against research's ≈400 estimate. The plan's own
  Phase 16 Scope Hypothesis and Rollback/Contingency both set the trigger at ≈700 and instruct:
  "stop, report, and revise the plan." Three recorded options, with a recommendation, are in the
  plan's Phase 16 blocker entry; the recommended one is a `SharingWindow` structure extending
  `SharingSkeleton` with the combined-period triple (~60 lines, additive to Stage A).
- **Finding F-M3**, which bears on the same decision: the position graph does **not** factor onto
  the bare `SharingSkeleton`. `perBack` joins the skeleton's `repBack` length with the *lassos'*
  label-segment lengths, so `NB`/`NF`/`NM`, the window bounds and everything defined over the
  window are not functions of the skeleton alone.
- **(C5) is two-thirds of a fully pinned obligation.** The plan names three things that pin it;
  two are now delivered — it is stated, decidable, has two proved consequences, and Phase 21
  exhibits it as non-vacuous (`stabFamily_separates`) and as degenerate exactly on the
  deterministic diagonal (`stabFaithful_diagonal`). The third, `plusTruth_iff_mem` consuming it
  as a hypothesis (Phase 19), is still downstream of the blocked Phase 16.
- **Registration is deferred to Phase 22**, per plan R1 (territory): `Sharing/Skeleton.lean` and
  `PlusLanguage/Subformulas.lean` are not yet listed in their aggregators, `PlusWitnessFamily/`
  has no sibling aggregator (invariant C8), and the `INV` stale-inventory failure is left alone
  because regenerating it would sweep concurrent siblings' new files into this task's commits.
  The practical consequence is worth stating plainly: **a plain `lake build` is not a green
  signal for the L⁺ subtree** until Phase 22 lands. Verify it with the explicit module target.
- **`lake-build-guard.sh` replays results across differently-scoped builds.** The first module
  build of this dispatch omitted `--no-share` and reported a false green — "Build completed
  successfully (1200 jobs)" — while writing no `.olean` for the module actually requested. Every
  subsequent build here passed `--no-share`. Worth a guard-side fix or a documented warning.

## References

- `specs/690_stability_condition_over_branching_frame/plans/01_stability-condition-branching-frame.md`
- `specs/690_stability_condition_over_branching_frame/reports/01_stability-condition-branching-frame.md`
- `specs/690_stability_condition_over_branching_frame/.measurements/01_substrate-measurement.md`
  (Phase 1's record; gitignored, regenerable from the commands quoted inside it)
- `specs/690_stability_condition_over_branching_frame/handoffs/phase-6-handoff-20260928.md`
- `specs/690_stability_condition_over_branching_frame/handoffs/phase-21-handoff-20260928.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`
