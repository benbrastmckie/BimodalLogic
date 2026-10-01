# Implementation Summary: Task #703

- **Task**: 703 - L⁺ compression and completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-01T18:00:00Z
- **Completed**: 2026-10-01T20:30:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: tasks 695, 696 (substrate as finally corrected), 699, 700, 706
- **Artifacts**: plans/06_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed the user's option-1 ruling of 2026-10-01T17:59:36Z — mirror the liveness filter — which
resolves the Phase 20 blocker. Sub-phases 20.3 and 20.4 are COMPLETE and verified: the single
unproved input the mirror filter rested on is now a theorem, and `PlusSlicedCertificate.TailStable`'s
backward conjunct is the filtered one, with every result stated from the old conjunct's functional
form restated. Sub-phase 20.5 is PARTIAL: its first structural input landed and its remaining
obligation is now stated exactly rather than estimated. No `sorry`, no new axiom, no weakened
statement, and the soundness interface is untouched.

## What Changed

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — `bwdVertFold` and its
  five structural lemmas (`bwdVertFold_lab`, `bwdVertFold_snd`, `bwdVertFold_self`,
  `bwdVertFold_mem_verts`, `bwdVertFold_mem_predT`), `foldB_sub_nat`, `foldB_bwdOrbit_fold`, and
  **`mem_bwdLiveT_of_bwdLive_fold`** — the mirror filter's one unproved input, now proved.
  `mem_bwdLiveT_of_bwdLive` restated as its diagonal instance via `G.foldB_refl s`, with its
  statement unchanged. The "Why there is no backward counterpart" paragraph rewritten (heading
  included) as "Why the forward filter is one-directional": its true claim about the right tail is
  retained, its false implication that no backward fold lemma exists is gone.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` — `bwdLiveAt`,
  `mem_bwdLiveAt`, `bwdLiveAt_subset_posAt`, `liveAt_subset_bwdLiveAt`, `L₀bwd`, `L₀_subset_L₀bwd`
  (the promoted filter); `foldB_tail`, `prevTime_le_left`, `mem_L₀bwd_of_bwdLive_tail` (its soundness
  chain) and the generic `foldB_shift`, `mem_bwdLiveAt_of_bwdLive_tail`;
  **`TailStable`'s backward conjunct swapped to the filtered form**, residue indexing preserved, with
  `decidableTailStable` still synthesized; `tailStable_of_raw` re-proved on both sides;
  `liveAt_refBack_subset_Φ`, `L₀_subset_Φ_back_L₀`, `liveAt_refBack_subset_iterBack`,
  `L₀_subset_iterBack`, `forall_mem_L₀_of_live_tail`, `forall_mem_liveAt_of_live_tail` added;
  `iterBack_liveAt_refBack` and `iterBack_L₀` now take `TailStableRaw`. The asymmetry note is
  DELETED, replaced by one note saying both directions carry the obstruction.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Tail.lean` —
  `live_of_mem_liveAt_tail`'s `hstab` is now the inclusion rather than the equation, mirroring
  `live_of_mem_liveAt_head`; `live_of_mem_liveAt_refBack` and `live_of_mem_L₀_tail` re-routed. All
  three statements unchanged for consumers.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/EmbedComplete.lean` — candidate retired
  (`bwdLiveAtCand`, `liveAt_subset_bwdLiveAtCand`, `TailStableMirror`, `decidableTailStableMirror`
  deleted); `TailStableBack` is now the filtered isolated conjunct with `TailStableBackRaw` beside it
  and `tailStableBack_of_raw` between them; the four verdict theorems restated, the two refuting
  families now carrying POSITIVE `TailStable` verdicts; the asymmetry paragraph deleted; new
  `BotTargets` namespace with the `⊥ U ⊥` / `⊥ S ⊥` regression pair; new `Embedded`
  `sliced_run_st_const` / `sliced_run_pos_fst` and the 20.5 reduction docstring.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` —
  `Φ_back_L₀_inter_ne_cert` (the FILTERED backward conjunct still fails at `Fixture.cert`, a `⊇`
  failure no filter repairs); `not_tailStable_cert`'s first component restated against it; the
  standing probe-shape rule added to the header.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` — header note recording
  `posAt`'s over-approximation and the `⊆`/`⊇` dichotomy once, where a reader meets it.
- `typst/generated/status.typ` — mandated line-count regeneration (`typst-sync-check.sh --fix`).

## Decisions

- **The both-filtered demand is a demand, not a theorem**, and `TailStable` stays a field of
  `Certifies`. This is landed as `FixtureStable.Φ_back_L₀_inter_ne_cert`, which confirms the demand
  is not vacuous after the repair: `p₀` is genuinely live at the reference time so the filter does
  not remove it, and the failure is a `⊇` one that only re-presentation repairs.
- **The 20.3 transcription was exact.** No consumer outside `Bridge.lean` needed to change, which was
  the plan's own pre-declared signal that 20.4 could proceed on the mirror hypothesis.
- **`iterBack_liveAt_refBack` and `iterBack_L₀` moved to `TailStableRaw`** rather than being deleted,
  mirroring what sub-phase 16.3 did to `iterFwd_liveAt_refFwd` / `iterFwd_R₀`, so the backward
  equation's functional form survives somewhere and nothing is silently lost.
- **`Stable.lean` carries `set_option linter.style.longFile 1700`** (1528 lines after the swap),
  following `FormalSystem/Metalogic/Soundness.lean`'s existing convention rather than splitting the
  module mid-repair.
- **20.5's remaining obligation is recorded in Lean, not only in the plan** — in
  `EmbedComplete.lean`'s own section docstring, so the next reader of the module meets it.

## Plan Deviations

- **Sub-phase 20.4**, `⊥`-target regression pair, **altered**: landed in `EmbedComplete.lean`'s new
  `BotTargets` namespace rather than in `FixtureStable.lean`, because the pair needs `WitnessFamily`
  and `.sliced`, which `FixtureStable.lean` does not carry and `EmbedComplete.lean` already does
  beside the two `snce` probes. `FixtureStable.lean`'s header names the namespace, so the record is
  reachable from where the plan said to put it.
- **Sub-phase 20.5**, `hTS` in general, **partial**: the first input landed
  (`Embedded.sliced_run_st_const` — every run of the embedded certificate has constant state, from
  `sliced_edge`'s identity edge relation) and the remaining obligation is stated exactly. See
  "Follow-ups". This is NOT a refutation: no certificate refutes `TailStable`, so the 20.5
  Contingency's escalation trigger (a refuting certificate, with its residue named) did not fire.
- **Sub-phase 20.5**, `hconc` and the flagship, **deferred**: depends on `hTS`.
- Sub-phases 20.3 and 20.4 otherwise followed their task lists exactly.

## Verification

- Build: Success — full `lake build`, "Build completed successfully (2805 jobs)", exit 0, zero
  `error:` lines across both captured streams, and every module this task touched has an `.olean`
  newer than its source (Bridge, Stable, Tail, FixtureStable, EmbedComplete, Position all checked).
- Sorry count: 0
- Vacuous count: 0 new. The census's single hit,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`), is
  pre-existing, untouched by this task, and a genuine theorem rather than a placeholder — a false
  positive of the single-line grep.
- Axiom count: unchanged. `git diff HEAD~3 -- '*.lean' | grep -cE '^\+axiom '` is 0. The live census
  reads 14 over all source roots (12 in `FormalSystem/`, 2 in `Tests/BimodalTest/`); the base commit
  reads the same.
- `#print axioms` on every new load-bearing declaration checked
  (`mem_bwdLiveT_of_bwdLive_fold`, `mem_L₀bwd_of_bwdLive_tail`, `Fixture.not_tailStable_cert`,
  `BotTargets.not_validZTime_botSnce`) reports exactly `[propext, Classical.choice, Quot.sound]`.
- `example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable := inferInstance` elaborates —
  decidability is synthesized, not asserted, after the conjunct swap.
- `Sound.lean` and `Complete.lean`: empty `git diff`, and they elaborate. So
  `PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` survive with their
  statements unchanged, as the task description requires.
- `PlusWitnessFamily/Agreement.lean` and `WitnessFamily/Compression/Family.lean`: empty `git diff`.
  `Family.lean` stayed closed, which is what the option-1 ruling buys.
- `mem_bwdLiveT_of_bwdLive`'s statement unchanged, confirmed by `#check` rather than by line number.
- `grep` confirms no module states or implies that the both-filtered demand is a theorem, and no
  module retains the deleted asymmetry claim.
- Zero lines over the 100-character limit in the touched subtree; no new linter findings.
- Files verified: Yes

## Impacts

- The Phase 20 blocker is RESOLVED. `TailStable` now carries exactly one liveness filter per
  obligation direction, and the two families that refuted the raw backward conjunct
  (`snceProbeFamily`, `snceProbeLiveFamily`) now satisfy the landed demand, as do both of sub-phase
  20.1's certificates and both new `⊥`-targets — seven favourable verdicts, with `Fixture.cert`
  correctly still unfavourable.
- `Stable.lean`'s consumers see unchanged statements for `mem_L₀_of_live_tail`,
  `live_of_mem_L₀_tail`, `live_of_mem_liveAt_refBack` and `mem_liveAt_of_live_refBack`, so Phase 18's
  truth lemma and `exists_win_live_eq`'s left branch are unaffected.
- `Position.lean`'s header is now the single place recording the `⊆`/`⊇` dichotomy, and it is also
  where option 2's refutation is recorded: the undischargeable positions are determined by `posAt`,
  not by any witness family, so no strengthening of a family-producing theorem can exclude them.
- The regression pair and the standing probe-shape rule close the measurement gap that let two
  dispatches return a favourable verdict for the whole demand from `untl`-only certificates.

## Follow-ups

- **Sub-phase 20.5's `hTS` in general** is the remaining work, and the obligation is now sharp: every
  live position at a left residue reference time must carry a label that is period-invariant along
  some fulfilling run. `LabRun.agrees` is demanded at every `s : ℤ`, including the non-negative times
  where `trLab (W.L w ·)` is not `perB`-periodic, so a run cannot simply be shifted by a period; the
  splice machinery exists (`Tail.lean`'s `tailPos` / `runOfPos`) and what is missing is its chain
  input. `Embedded.sliced_run_st_const` is the first input, landed. Recorded in
  `EmbedComplete.lean`'s own section docstring as well as here.
- `hconc` and the flagship `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` depend on
  that.
- Phase 21 (acceptance gates, the `docs/theorem-index.md` row, the C2 `AXIOM_BASELINE` pin) is
  untouched and still NOT STARTED; it cannot close before the flagship exists.
- The **option-3 successor** the user's ruling calls for — evaluate whether the obstruction can be
  removed at its root by carrying full labels in the certificate so `posAt` becomes a singleton,
  refactoring as needed, the known cost being the decidable search `Check.lean` is built around — is
  specified under the plan's "The option-3 successor, specified and deliberately not filed" and is
  still not filed. This dispatch did not file it.
- `prevTime_le_left` landed as the plan's named mirror of `nextTime_ge_right` but has no consumer
  yet; the general `hTS` argument is where it is expected to be used.

## References

- `specs/703_lplus_compression_and_completeness/plans/06_lplus-sliced-certificate-and-completeness.md`
  (plan v12, sub-phases 20.3 / 20.4 / 20.5)
- `specs/703_lplus_compression_and_completeness/.decisions.json` entry 7 — the option-1 ruling
- `specs/703_lplus_compression_and_completeness/reports/06_tailstable-backward-conjunct-repair.md`
- `specs/703_lplus_compression_and_completeness/handoffs/phase-20.3-handoff-*.md`,
  `phase-20.4-handoff-*.md`
