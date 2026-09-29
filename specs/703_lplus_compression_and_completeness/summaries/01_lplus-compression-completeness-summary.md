# Implementation Summary: Task #703

- **Task**: 703 - L⁺ Compression and Completeness
- **Status**: [BLOCKED]
- **Started**: 2026-09-29T16:51:00Z
- **Completed**: 2026-09-29T17:18:50Z
- **Effort**: ~2.5 hours (6 of 13 phases complete, 1 blocked, 6 not started)
- **Dependencies**: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (landed);
  the redesigned sharing substrate as finally corrected (landed). Neither was a blocker.
- **Artifacts**: plans/01_lplus-compression-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1 through 6 of the thirteen-phase L⁺ compression plan are complete, sorry-free and
axiom-clean, and Phase 7's transcription half is landed. Phase 7 is **[BLOCKED]** on its
Invariant A, which is not provable as written and whose stated purpose does not describe the
landed substrate. The compression theorem
`exists_plusSharingWitnessFamily_of_not_plusValidZTime` is **not** proved, and neither is
`plusFamilyBound` defined; those belong to Phases 8 through 13, all of which depend on Phase 7.

Soundness was never touched. `plusTruth_iff_mem` and `plusRefutes_of_certifies` have unchanged
statements, confirmed by an empty diff over `PlusWitnessFamily/Agreement.lean`.

## What Changed

New modules, all under `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/`:

- `TransId.lean` — the hop-free collapse. `plusLocalCoherentShare_of_transId` and
  `plusThreadFulfilling_of_transId` derive the two branching conditions (C1') and (C2') from the
  per-lasso `PlusLocalCoherentLab` and `PlusFulfillingLab`, given that succession relates an
  index only to itself. These are the exact converses of the landed
  `plusLocalCoherentLab_of_share` and `plusFulfillingLab_of_thread`. Also
  `transId_forces_const_thread`, `thread_eq_const_of_transId` and `transIdOf_hid`.
- `Compression/Types.lean` — `plusTypeAtM`, `PlusLocalCoherentSeqLab`, `PlusFulfillingSeqLab`
  and the two realization lemmas, plus three supporting truth lemmas with no L⁺ counterpart in
  the tree: `plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred`.
- `Compression/Cycle.lean` — `PlusTypeState` and its cardinality bounds, `PlusSeqStepT`, the
  `plusJoinPathT` interface, `exists_recurring_plusTypeState`, the two event decoders with their
  inversions, `plusCycleBoundC`, `exists_base_plusCycleT` and
  `exists_good_cycle_of_plusTypeSeq`.
- `Compression/Fulfil.lean` — the two interior-eventuality propagation lemmas, the two iterated
  periodicities, and `plusFulfillingSeqLab_of_good_cycles`.
- `Compression/Extract.lean` — `plusTypeOfT_unrollOf`, `plusMidBoundC`, `plusCompressionBound`
  with its ordering lemmas and `plusCompressionBound_pos`;
  `plusLocalCoherentSeqLab_of_edges`, `exists_plusLabelledLasso_of_history_realized`, its
  realization-free corollary, and `plusLocalCoherentSeqLab_congr_bx`.

Modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — four aggregator import lines.
- `FormalSystem.lean` — regenerated with `lake exe mk_all --lib FormalSystem`.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — generated
  inventory blocks regenerated.

## Decisions

- **Reuse over transcription where the source is generic.** Ten declarations of the
  `Formula`-side compression are polymorphic in the carrier and mention no formula type: the
  pigeonhole pair `exists_iterT_lt_card_aux` / `exists_iterT_lt_card`, and the eight readout
  lemmas `getD_mapC`, `getD_range_mapC`, `reduce_emodC`, `emod_succ_congrC`,
  `periodic_rel_of_windowC`, `readout_backC`, `readout_midC`, `readout_fwdC`. All ten are reused
  by importing the `Formula`-side modules. Everything monomorphic in `Formula` through the
  `TypeState` subtype was transcribed, because `Formula` and `PlusFormula` share no supertype.
- **`⊡` gets no event decoder, and that is now a theorem rather than an implicit match arm.**
  `plusUntlEventT_stab` and `plusSnceEventT_stab` both state `= none`. The consequence is that a
  `stab` closure member takes the event-free branch of the good-cycle induction, so
  `plusCycleBoundC` keeps its `Formula`-side form `(2k + 1) · 2^k` and only `k` grows. This is
  the same finding that makes `Compression/Fulfil.lean` mention the stability modal nowhere.
- **`plusThreadFulfilling_of_transId` routes through a named `thread_eq_const_of_transId`**
  rather than inlining the `Thread.ext` step, because Phases 9 and 12 both want the extensional
  form.

## Plan Deviations

- **Phase 3** altered: the generic pigeonhole pair was reused by import rather than transcribed.
  This is the branch the phase's own Scope Hypothesis directs when the signatures turn out to be
  formula-agnostic, which they are.
- **Phase 1** altered: `plusThreadFulfilling_of_transId` routes through an extracted
  `thread_eq_const_of_transId` rather than inlining `Thread.ext` plus `Thread.const_idx`.
- **Phase 2, 6, 7** additions, each recorded in the plan rather than absorbed: three supporting
  truth lemmas (`plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred`),
  `plusCompressionBound_pos`, and `plusLocalCoherentSeqLab_of_edges`.
- **Phase 7 BLOCKED** on Invariant A. Full record in the plan file under the Phase 7 heading; the
  substance is repeated under Follow-ups below.

## Verification

- Build: Success. Full `lake build` exits 0, 2776 jobs, zero `error:` lines across both captured
  streams.
- Sorry count: 0
- Vacuous count: 1 — **pre-existing, not introduced**. It is
  `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, and the
  pre-task baseline at commit `111de7c59` carries the same single occurrence.
- Axiom count: 14 — **unchanged from the pre-task baseline at `111de7c59`**. Every new
  declaration reports exactly `[propext, Classical.choice, Quot.sound]`.
- Tests: N/A (no test additions in the phases completed)
- Files verified: Yes
- Module invariants: `check-module-invariants.sh --no-build` passes every structural group,
  including C33 (library root byte-for-byte generated) and INV (inventory blocks current), after
  the Phase 7.2 regeneration.
- Plan compliance: 3 of the plan's 5 named goal declarations exist
  (`plusLocalCoherentShare_of_transId`, `plusThreadFulfilling_of_transId`,
  `plusCompressionBound`). Two do not
  (`exists_plusSharingWitnessFamily_of_not_plusValidZTime`, `plusFamilyBound`), because they
  belong to Phases 8 and 12, which Phase 7's blocker gates.

## Impacts

- The whole `Formula`-side compression pipeline now has an L⁺ twin up to and including
  single-history lasso extraction. Any later task can compress an arbitrary ℤ-frame L⁺
  countermodel history into a bounded `PlusLabelledLasso` that is locally coherent, fulfilling,
  and realized, with segments bounded by `plusCompressionBound`.
- `TransId.lean` is reusable beyond this task: any producer of a `PlusSharingWitnessFamily` that
  chooses the hop-free succession bundle now discharges (C1') and (C2') from per-lasso data.
- The count-freshness pre-commit hook is currently unsatisfied. Every commit in this dispatch
  used the hook's documented `--no-verify` bypass, because the remedy writes
  `typst/generated/status.typ`, which the dispatch's territory contract assigns to the
  concurrently running task 650. The drift is caused by this task's own five new `.lean` files.
  CI's `typst-sync-check.sh` Check 2 remains the authoritative backstop.

## Follow-ups

- **Resolve Phase 7's Invariant A — this is the blocker and needs a plan decision, not a proof.**
  "Pad `back` and `fwd` by repetition so every extracted lasso has
  `back.length = fwd.length = plusCompressionBound Γ Del`" is not provable. Repetition preserves
  the decoded label function only at multiples of the cycle length, so the invariant needs
  `L ∣ plusCompressionBound` for every extracted `L`, which `exists_good_cycle_of_plusTypeSeq`
  does not provide. Concretely, at a three-member closure `exists_base_plusCycleT` permits every
  cycle length in 1…8 while `plusCompressionBound` is 56, and three lassos with back lengths 5, 7
  and 8 admit no common padded length below 280. Separately, the invariant's stated purpose is
  wrong about this tree: `PlusWitnessFamily/Decide.lean`'s `perBack` is
  `repBack.length * (lassos.map (·.back.length)).prod`, a **product**, never a least common
  multiple, so a common length `L` gives `NB = |repBack| · L^n`, not `plusCompressionBound`.
  Recommended resolution: **drop Invariant A**. Nothing downstream needs it for correctness —
  the segment bounds Phase 12 states come free from the unpadded extraction, and `NB`/`NF` are
  derived quantities whose well-formedness is already proved for an arbitrary family.
- **Invariant B should survive, by a different mechanism.** Shifting a lasso rightward by `k` —
  prepend the labels `lab (-k) … lab (-1)` to `mid` and rotate `back` by `-k` — gives
  `lab' t = lab (t - k)` on all four decoding regions, and taking `k` to the maximum landing
  offset keeps `|mid'| < 3 · 2^κ ≤ plusCompressionBound` for `κ ≥ 1`. It was not implemented,
  because its planned mechanism ("rotating the padded segments") presupposes Invariant A and
  substituting a different mechanism while A is unresolved is the silent substitution
  `plan-compliance.md` forbids on `.lean` files.
- **Phases 8 through 13 are untouched** and all depend on Phase 7.
- **Regenerate `typst/generated/status.typ`.** Task 650 has since landed: `specs/state.json`
  reports it `completed`, so the file is released and the team lead's precondition for the
  regeneration is met. (`specs/TODO.md` still showed `[IMPLEMENTING]` and was stale;
  `state.json` is authoritative.) The lead scoped the regeneration to this task's Phase 13
  acceptance step, which Phase 7's blocker makes unreachable for now, so it remains outstanding.
  The remedy is `bash scripts/typst-sync-check.sh --fix` followed by a commit of only
  `typst/generated/status.typ` by explicit path. Verified at dispatch 16: the status-file count
  drift is the **only** failing gate, the checker reporting exactly `formalsystem-file-count`
  (605 committed against 610 live) and `formalsystem-line-count`, so every `--no-verify` use in
  this dispatch stayed inside the lead's condition.
- **One process lesson worth keeping.** Four library-root edits failed silently because they ran
  inside backgrounded commands whose Python guard asserted the new module name was absent from
  the file, and each Plus-side name is a substring match against the already-present
  Formula-side name. The builds still passed, because the aggregator imported everything, so
  only C33's byte-for-byte check caught it. Edit the library root with
  `lake exe mk_all --lib FormalSystem`, never by hand, and read the output of a backgrounded
  command that performs edits rather than only its build log.

## References

- `specs/703_lplus_compression_and_completeness/plans/01_lplus-compression-completeness.md`
  (the Phase 7 heading carries the full BLOCKER record)
- `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
- `specs/703_lplus_compression_and_completeness/handoffs/` (one handoff per completed phase)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` (the `Formula`-side originals)
