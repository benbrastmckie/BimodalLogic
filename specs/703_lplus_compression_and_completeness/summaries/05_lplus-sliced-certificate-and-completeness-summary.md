# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-01T00:09:00Z (dispatch 40); dispatch 41 began 2026-10-01T00:47:00Z;
  dispatch 42 began 2026-10-01T01:36:00Z; dispatch 44 began 2026-10-01T03:15:25Z; dispatch 46 began
  2026-10-01T04:05:37Z; dispatch 47 began 2026-10-01T05:22:34Z
- **Completed**: not complete — **sub-phase 16.3 and Phases 17, 18 and 19 are all closed** (19 as
  [COMPLETED WITH EXCLUSIONS]). Phase 18's blocker (a demand-level gap in `TailStable`, recorded at
  dispatch 42) is **RESOLVED** at dispatch 44 by the residue-indexed demand the user ruled for in
  cycle 3. **Phase 20 is now [PARTIAL]: dispatch 47 closed sub-phase 20.1 and left 20.2 open.**
  Phase 21 remains NOT STARTED. Dispatch 44 ended 2026-10-01T04:05:00Z; dispatch 46
  ended 2026-10-01T05:05:00Z; dispatch 47 ended 2026-10-01T05:53:00Z
- **Effort**: ~35 minutes (dispatch 40, sub-phase 16.3) + ~40 minutes (dispatch 41, Phase 17) +
  ~40 minutes (dispatch 42, Phase 18's prerequisites and its blocker) + ~50 minutes (dispatch 44,
  the demand change and Phase 18) + ~60 minutes (dispatch 46, Phase 19) + ~30 minutes (dispatch 47,
  sub-phase 20.1)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable`,
  `...PlusSlicedCertificate.Bridge`, `...PlusSlicedCertificate.FixtureStable`,
  `...PlusSlicedCertificate.Window`, `...PlusSlicedCertificate.Position`,
  `...PlusWitnessFamily.Compression.Types` (all landed before these dispatches); no new external
  dependency. Dispatch 46 adds no external dependency either: Phase 19 consumes
  `...PlusSlicedCertificate.Sound` and, through it, `...PlusSlicedCertificate.Canon` and
  `...PlusSlicedCertificate.Tail`. Dispatch 47 adds **one** new intra-repository dependency:
  `Embed.lean` imports `...WitnessFamily.Agreement` alongside `...PlusSlicedCertificate.Complete`,
  which is the first time this subtree depends on the `Formula`-side witness-family layer at all —
  necessarily, since the embedding's source object lives there
- **Artifacts**: plans/05_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Dispatch 47 closes sub-phase 20.1** — the construction half of the embedding of the landed
`Formula`-side witness family — and splits Phase 20 as that phase's own Contingency declares.
`Embed.lean` lands a generic layer the subtree did not have (an eventually periodic function cut
into the three segments that decode back to it), the identification of an embedded context's L⁺
closure with the `ofFormula`-image of the base closure, the certificate `WitnessFamily.sliced`
itself with slice width the lasso count and edges `i → i` only, its readout, the collapse of the
combined window onto the family's own periods, and `sliced_biSerial`. Two consequences of the
closure identification are landed as results rather than noted as remarks: **no `⊡`-formula lies in
an embedded closure at all**, so (C5) `StabFaithful` is vacuous there (`sliced_stabFaithful`) and so
is the second clause of `SlabTrue`.

**The phase's mandated PROBE-FIRST step ran and returned favourable**: `decide G.TailStable` is
**true** at two embedded certificates while `TailStableRaw` is **false** at both, so the liveness
filter the user ruled for in cycle 5 is load-bearing on this route. Both verdicts are landed as
kernel-checked theorems rather than left as transient measurements. `TailStable` in general,
`SlabTrue`'s `□` clause, the canonical-label identification and the flagship are sub-phase 20.2.

**One plan claim is corrected rather than absorbed**: Phase 20's "the backward half of `TailStable`
is genuinely short, because `Φ_back` is the identity on the position sets it acts on" is **false**,
and that is why `TailStable` moved out of 20.1. See Plan Deviations.

**Dispatch 46 closes Phase 19**, the converse of Phase 18. `Complete.lean` lands
`exists_plusSlicedCertificate_of_tailStable_countermodel`: a bi-serial, tail-stable sliced structure
whose slice labelling reports the truth of its own `□`- and `⊡`-arguments, and which carries a
canonically labelled refuting path, admits a **box guess** making the checker of `Check.lean` accept
— on the same carrier. Soundness and completeness then meet on the unchanged
`PlusWitnessFamily.PlusRefutes Γ Del` interface
(`plusRefutes_of_tailStable_countermodel`), and the hypothesis set is proved satisfiable rather than
left open (`Probe.exists_certifying_triv`). The phase closes WITH EXCLUSIONS, because one of its
plan bullets rested on a claim about `TailStable` that turned out to be false; see Plan Deviations.

**Dispatch 44 closes Phase 18.** The sliced certificate now has a truth lemma
(`plusTruthAt_iff_canAt`, all seven cases) and lands the L⁺ refutation interface:
`PlusSlicedCertificate.plusRefutes_of_certifies` produces `PlusWitnessFamily.PlusRefutes Γ Del` —
the same proposition the landed `PlusSharingWitnessFamily.plusRefutes_of_certifies` produces, beside
it and not in place of it. Closing the phase required the demand change the user ruled for in cycle
3: `TailStable` is now **residue-indexed**, a bounded quantifier over each period's residues rather
than one equation per direction, which is what makes the truth lemma's `⊡` clause provable at an
arbitrary time. The narrowing is real and Phases 19-20 must be re-checked against it; that is the
cost the ruling accepted.

Soundness was not touched. `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` carries no diff
at all across this whole round, and both landed soundness theorems still report exactly
`[propext, Classical.choice, Quot.sound]`.

Round 5 covers four dispatches. The three earlier ones: **Dispatch 40** implemented the user's tail-stability ruling:
`TailStable`'s forward conjunct became the liveness-filtered transfer `Φ_fwd R₀ ∩ R₀fwd = R₀`, with
the raw demand preserved as `TailStableRaw`. **Dispatch 41** wrote Phase 17, the decidable checker:
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` defines `Certifies` as nine
clauses and synthesizes `decidableCertifies` from them, and the checker has been **run** — a
concrete certificate is exhibited and accepted, by `#guard` lines that evaluate during the build
rather than by assertion.

The three structural conjuncts are `BiSerial`, `TailStable` and `BoxLabelFaithful`, each decided
through a landed window biconditional. Two of the three needed a `Decidable` instance written here,
and one of those needed a piece the plan had not anticipated: `BoxLabelFaithful`'s
`∀ χ, □χ ∈ closure → …` is not a bounded quantifier and no instance resolves against it, so the
reindexing `boxArgs` / `stabArgs` had to be written first.

Three of the plan's clause descriptions could not be implemented as written, and each alternative is
forced rather than chosen. The **existential side** is stated on the position graph (`TargetPathPos`:
the target path's position lies in `G.posAt` at every time and steps along `G.succP`) plus a single
liveness clause, because `PlusFulfillingSeqLab` is an unbounded existential over ℤ and is not
decidable at all, and `PlusLocalCoherentSeqLab` reads `lab (t ± 1)`, which no one-time fold reaches.
Nothing is lost: `targetRun` rebuilds the `LabRun` and `exists_fulfilling_run_at_targetTime` rebuilds
the fulfilling run. The **box clause** is `BoxLiveFaithful`, on live positions, not (C3)
`BoxFaithful` on the slice labelling — which is what the plan's box-clause bullet's own first
sentence asks for, and which its plan-v7 parenthetical contradicted. And one clause was **added**,
`G.targetTime ∈ G.winTimes`, because the computed live set exists only at window times while
`targetTime` is an unconstrained field.

The folding the phase needed did not exist either. `Window.lean`'s `forall_iff_win` folds a predicate
reading **one** time; `succP` reads two consecutive slices. `forall_iff_win_succ` is the
one-step-lookahead fold, proved here from four new combined-period shift lemmas, and the doubled
window endpoints are exactly what make the lookahead land inside the window on both tails.

**Dispatch 42** opened Phase 18 and found that it has **two** gaps, not the one its READ FIRST block
flagged. The prior, unflagged one is closed: `Canon.lean` proves that **every** `G.edge`-path is a
locally coherent, fulfilling `LabRun` — the step "a history of the presented frame is an offset step
path, hence a labelled path of `G`", which the plan asserted and which nothing supplied. The second
gap is real and is a gap in a **demand**, not in a proof: the truth lemma needs the `⊡` clause at an
arbitrary time, and `TailStable` constrains the live set in one residue class mod `G.NB` (and one mod
`G.NF`) while the lemma needs all of them. Phase 18 is `[BLOCKED]` on that, with the replacement
demand written out and raised as this round's `user_decision`, because it narrows the certificate
class Phases 19-20 claim completeness relative to.

## What Changed

### Dispatch 47 (sub-phase 20.1)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Embed.lean` — **created**, 865 lines.
  - **The generic segment layer** (`namespace Periodic`): `segBack` / `segMid` / `segFwd` cut a
    function into three lists, with `unrollOf_seg` proving they decode back to it, off two
    hypotheses (leftward period `pb` below `0`, rightward period `pf` at or past `m`). The two
    multiple-periodicity lemmas `periodic_back_mul` / `periodic_fwd_mul` do the work of getting from
    a residue representative back to the original time. This is the **converse** of the three region
    lemmas `Periodic.unrollOf_neg` / `_mid` / `_fwd`, and the subtree had only the forward direction.
  - **The closure transfer**: `PlusFormula.subformulas_ofFormula`,
    `plusSubformulaClosure_ofFormula`, `plusClosureOf_ofCtx`, `mem_plusClosureOf_ofCtx`,
    `exists_ofFormula_of_mem_plusClosureOf_ofCtx` and — the one this phase turns on —
    `not_stab_mem_plusClosureOf_ofCtx`.
  - **`PlusSlice.ext'`**: two slices with the same edge relation and labelling are equal (the subset
    field is a `Prop`). Needed because the segment layer is applied at `α := PlusSlice n C`.
  - **The common periods**: `WitnessFamily.perB` / `perF` / `perM`, mirroring
    `PlusSharingWitnessFamily.perBack` / `perFwd` / `perMid` — product, product, sum — with
    `perB_pos`, `perF_pos`, `back_length_dvd_perB`, `fwd_length_dvd_perF`, `mid_length_le_perM`.
  - **Lasso periodicity by any multiple**: `lab_sub_dvd`, `lab_add_dvd`, and their instances
    `lab_sub_perB`, `lab_add_perF` at the family's own periods.
  - **The construction**: `trLab`, `embSlice`, `embTargetFun`, `embTarget`, and
    `WitnessFamily.sliced` — the certificate, with `bx := fun _ => false` deliberately.
  - **The readout**: `sliced_slice`, `sliced_edge`, `sliced_slab`, `sliced_target_datum`,
    `sliced_target_lab`, `sliced_target_st`.
  - **The window collapse**: `sliced_NBnat = perB`, `sliced_NFnat = perF`, `sliced_NM = perM`, plus
    `sliced_winLo`, `sliced_winHi`, `sliced_mem_winTimes`.
  - **Proved clauses**: `sliced_biSerial` (C1, both directions), `sliced_stabFaithful` (C5,
    vacuously), `sliced_target_edge` (the `hedge` hypothesis of the Phase-19 headline).
  - **The probe, landed as theorems** (`namespace WitnessFamily.Embedded`): `evTarget` = `p U q`,
    `emptyLasso` / `emptyFamily` and `liveLasso` / `liveFamily`, with
    `emptyFamily_tailStable`, `emptyFamily_not_tailStableRaw`, `liveFamily_certifies`,
    `liveFamily_tailStable`, `liveFamily_not_tailStableRaw` — five `by decide` facts.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one added import, one added
  submodule inventory bullet.
- `FormalSystem.lean` — one added import line.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — regenerated
  inventories (`check-module-invariants.sh --emit-inventory`).
- `typst/generated/status.typ` — regenerated (`typst-sync-check.sh --fix`).

### Dispatch 46 — Phase 19, completeness relative to tail-stable sliced models

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` — **new**, 711 lines,
  40 declarations. Contents, in the order their dependencies force:
  - `SlabTrue` — semantic correctness of the slice labelling at the two non-atomic **state shapes**.
    `□χ` is labelled exactly when `χ` is true at every history and every time (time- and
    history-free because `plusBox_const` makes it so); `⊡χ` is labelled at `(t, w)` exactly when `χ`
    is true at `t` along every history through `(t, w)`. **No atom clause**, because
    `Frame.lean`'s `model_valuation` makes the presented model's valuation the slice labelling by
    definition.
  - `withBx` (`@[reducible]`) and `canonBx` — the structure with a replaced box guess, and the
    canonical guess read off one slice label (so it stays a computable `Finset` membership).
  - the transfer layer — `withBx_posAt` / `_winTimes` / `_liveAt` / `_fwdLiveAt` / `_stepBack` /
    `_stepFwd` / `_slab` and the six field projections, all `rfl`; `withBx_iterBack` /
    `withBx_iterFwd` / `withBx_canAt` by induction; `withBx_tailStable` and `withBx_canLab` on top
    of those.
  - `plusTruthAt_iff_canAt_of_slabTrue` — **the truth lemma with no checker clause as a hypothesis**.
    `Sound.lean`'s `plusTruthAt_iff_canAt` reaches the same conclusion from the checker's four
    clauses; neither subsumes the other, and completeness needs this direction because it *has*
    truth and must reach the clauses.
  - `boxLabelFaithful_of_slabTrue`, `stabFaithful_of_slabTrue`, `boxLiveFaithful_of_slabTrue` — the
    three semantic clauses of `Certifies`, in that order. (C3b) must come first: the
    computed/declarative liveness bridge `mem_liveAt_iff_live` consumes it, and both of the others
    read a live position's label.
  - `targetPos_eq_canRun_pos`, `targetPathPos_of_canLab`, `targetPos_mem_liveAt_of_canLab`,
    `target_of_refutes` — the target group, all four through the one identification that the target
    path's position **is** the canonical run's position.
  - `exists_plusSlicedCertificate_of_tailStable_countermodel`,
    `exists_certifying_of_tailStable_countermodel` (the six carrier equations spelled out),
    `plusRefutes_of_tailStable_countermodel`.
  - `Probe.triv_slice` / `triv_edge` / `path1_lab` / `triv_canLab` / `triv_slabTrue` /
    `exists_certifying_triv` — the satisfiability witness.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one import line and one
  submodule bullet.
- `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `typst/generated/status.typ` — regenerated.

### Dispatch 44 — Phase 18, the demand change and the truth lemma

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` — `TailStable` and
  `TailStableRaw` restated as bounded quantifiers over their own period's residues, with
  `refBack_mem_winTimes` / `refFwd_mem_winTimes` (every reference time is a window time, so
  `decidableTailStable` survives as a bounded conjunction of `Finset` equality tests), the four
  `r = 0` projections `tailStable_back` / `tailStable_fwd` / `tailStableRaw_back` /
  `tailStableRaw_fwd`, residue-generic iterates `iterBack_liveAt_refBack` / `iterFwd_liveAt_refFwd` /
  `liveAt_refFwd_subset_iterFwd` with the old `iterBack_L₀` / `iterFwd_R₀` / `R₀_subset_iterFwd` as
  their `r = 0` instances, the generic forward halves `mem_liveAt_of_live_tail` /
  `forall_mem_liveAt_of_live_head` with `foldF_shift` and `mem_fwdLiveAt_of_fwdLive_head` generalizing
  `foldF_head` / `mem_R₀fwd_of_fwdLive_head`, and the arithmetic `exists_residue_back` /
  `exists_residue_fwd`. 494 lines moved out to `Tail.lean`: the file had reached the 1500-line module
  limit.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Tail.lean` — **created**, 650 lines. The
  three-region construction, now generic in its reference time: `tailPos` / `headPos` and their six
  placement and seam lemmas each, the generic headlines `live_of_mem_liveAt_tail` /
  `live_of_mem_liveAt_head`, the residue instances `live_of_mem_liveAt_refBack` / `_refFwd`, the
  `r = 0` instances `live_of_mem_L₀_tail` / `live_of_mem_R₀_head`, the linchpins
  `tailStable_iff_window` / `_fwd` and the `Finset` forms `liveAt_tail_eq_L₀` / `liveAt_winLo_eq_L₀`
  (all moved, not rewritten), and **`exists_win_live_eq`** — the obligation dispatch 42 named as the
  single remaining one: every time has a window representative carrying the same slice *and* the same
  live set.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Sound.lean` — **created**, 364 lines.
  `frame_isZTime` / `frame_sat_ztime`, `stepHistory` with `exists_stepHistory`, the truth lemma
  `plusTruthAt_iff_canAt`, `mem_canLab_iff_plusTruthAt`, and `plusRefutes_of_certifies`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` —
  `not_tailStableRaw` and `not_tailStable_cert` re-proved through the `r = 0` projections; both
  statements unchanged.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — two added imports and two added
  module bullets; the `Stable` bullet corrected to say the demand is residue-indexed and that the
  reverse half of the linchpin now lives in `Tail`.
- `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `typst/generated/status.typ` — regenerated.

**Theorems proved at dispatch 44**

| Declaration | What it says |
|---|---|
| `plusTruthAt_iff_canAt` | truth in the presented model along an arbitrary `G.edge`-path agrees with `Canon`'s canonical membership predicate, at every time and every closure member |
| `plusRefutes_of_certifies` | an accepted `PlusSlicedCertificate` yields `PlusWitnessFamily.PlusRefutes Γ Del` |
| `exists_win_live_eq` | every time has a window representative carrying the same slice and the same live set |
| `live_of_mem_liveAt_tail` / `_head` | the reverse half of the tail collapse, at an arbitrary stable reference time |
| `mem_liveAt_of_live_tail` / `forall_mem_liveAt_of_live_head` | the forward half, likewise |
| `frame_sat_ztime` | the presented frame satisfies `FrameClass.ZTime` |
| `tailStable_back` / `_fwd` and the two raw mirrors | the `r = 0` projections of the residue-indexed demand |

### Dispatch 42 — Phase 18's two prerequisites

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Canon.lean` — **new file, 544 lines.**
  - `canAt` — the canonical membership predicate of a state path, by recursion on the formula:
    `atom` / `box` / `stab` (the three state shapes) read `G.slab t (g t)` **by fiat**, `bot` is
    absent, `imp` is the implication clause, and `untl` / `snce` are the *existential* forms. Seven
    `@[simp]` clause lemmas plus `canAt_untl_succ` / `canAt_snce_pred`, the one-step unfoldings.
  - `canLab` — the closure filtered by `canAt`, with `mem_canLab` and `canLab_subset`.
  - `canLab_agreesOnState` (**no hypothesis**), `canLab_localCoherent` (from (C3b) alone),
    `canLab_fulfilling` (**no hypothesis**) — the three obligations, and which of them costs
    anything.
  - `canRun` — the `LabRun` an arbitrary `G.edge`-path presents; `canRun_fulfilling`, `canRun_pos`,
    `live_canRun`, `live_canRun_pair`.
  - `untl_pull` / `snce_pull` — a *delivered* eventuality is pending at every earlier (later) time,
    for a bare locally coherent label sequence. The converses of `Live.lean`'s `untl_push` /
    `snce_push`, and the bare-sequence counterparts of `plusUntl_mem_along_thread` /
    `plusSnce_mem_along_thread`, which are stated along a thread of the branching device and do not
    apply here.
  - `canAt_iff_mem_lab`, `lab_eq_canLab` — a fulfilling run's labelling **is** `canLab R.st`: it is
    forced by the state path, not chosen.
  - `live_iff_canLab`, `exists_path_canLab_of_live` — the live positions at a time are exactly the
    canonical positions of the step paths, with nothing else in the set and nothing missing.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one import line and one module
  bullet.
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem` (634 import lines; C33
  byte-for-byte green).
- `typst/generated/status.typ` — regenerated counts.
- No `Sound.lean`: see Plan Deviations and the blocker.

### Dispatch 41 — Phase 17, the decidable checker

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` — **new file, 737 lines.**
  - `boxArgs` / `mem_boxArgs`, `stabArgs` / `mem_stabArgs`: the closure's `□`- and `⊡`-arguments as
    `Finset`s, which is the shape-guarded quantifier read as a domain.
  - `decidableBiSerialAt`, `decidableBiSerialWindow`, `decidableBiSerial` — (C1) through
    `biSerial_iff_window` over a `Finset.Ico` of the **own** window.
  - `decidableBoxLabelFaithfulWindow`, `decidableBoxLabelFaithful` — (C3b) through
    `boxLabelFaithful_iff_window`, over the same own window.
  - `decidableTarget` — (C4); `Basic.lean` declares no instance.
  - `slice_sub_NB`, `target_datum_sub_NB`, `slice_add_NF`, `target_datum_add_NF` — the **combined**
    period shifts, each a residue computation citing `nb_dvd_NB` / `target_nb_dvd_NB` /
    `nf_dvd_NF` / `target_nf_dvd_NF`. `Basic.lean`'s own periodicity lemmas shift by the
    certificate's periods and leave the target path's data behind; these move both at once.
  - `forall_iff_win_succ` — the fold with one step of lookahead, by induction on the number of
    period shifts needed to reach the window, one shift at a time so that each shift's side
    condition is discharged where it holds.
  - `targetPos`, `targetPos_fst` / `targetPos_snd`, `targetPos_congr`, `TargetPathPos`,
    `decidableTargetPathPos`.
  - `target_labCoherent`, `target_agrees`, `target_edge`, `target_stepClause`, `target_coherent`,
    `targetRun` with `targetRun_lab` / `targetRun_st` / `targetRun_pos` — the four local clauses
    projected out, the fifth (box) clause recovered from (C3b) and `AgreesOnState`, and the `LabRun`
    they assemble into. The box-clause derivation mirrors `Bridge.lean`'s `spliceWalkPos_coherent`.
  - `StabFaithful` with `decidableStabFaithful` — (C5) as **one** biconditional carrying both the
    universal obligation (`→`) and the existential one (`←`).
  - `BoxLiveFaithful` with `decidableBoxLiveFaithful` — the box clause, on live positions.
  - `Certifies`, `decidableCertifies`, eight `example … := inferInstance` lines confirming the
    conjuncts in isolation, and nine `…_of_certifies` projections.
  - `exists_fulfilling_run_at_targetTime` — the fulfilling run whose label at `G.targetTime` is the
    target path's own. This is what the dropped `witness` field is paid for with, and it already
    routes through `live_of_mem_liveAt`, hence through `hbox`.
  - `Probe.triv` — the one-slice `onePointCertificate` at the empty context, with `closure_empty`
    stated rather than assumed, and **ten `#guard` lines** (nine clauses plus `Certifies`), each
    `set_option linter.hashCommand false in` with the repository's existing reason comment.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one import line and one
  submodule bullet.
- `FormalSystem.lean` — the regenerated root's one added import.
- `typst/generated/status.typ` — regenerated counts (`typst-sync-check.sh --fix`), required by the
  pre-commit gate.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` — refreshed generated
  inventory blocks (`check-module-invariants.sh --emit-inventory`). The drift was 12 files and
  ~4,400 lines, i.e. mostly Phases 15-16's rather than Phase 17's alone; `INV` now passes.
- `specs/703_lplus_compression_and_completeness/plans/05_lplus-sliced-certificate-and-completeness.md`
  — the PHASE 17 RECORD at Phase 17's heading; all ten Phase 17 checklist items marked `[x]` with
  inline annotations (three of them deviations); the plan's design-decision item 5 amended where it
  named (C3) `BoxFaithful` as a box-group clause; a READ FIRST block at Phase 18's heading naming
  what Phase 17 hands it and the one unverified risk; and Phase 21's gate-state findings re-measured.

### Dispatch 40 — sub-phase 16.3, the repaired forward conjunct

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — new `fwdVertFold` and
  its three facts (`fwdVertFold_mem_verts`, `fwdVertFold_mem_succT`, `foldF_fwdOrbit_fold`), the
  general `foldF_add_nat`, and the headline `mem_fwdLiveT_of_fwdLive_fold`: a position forward-live
  at any `s'` with `G.FoldF s s'` is in the computed forward fixpoint at the window time `s`. The
  landed `mem_fwdLiveT_of_fwdLive` keeps its statement and becomes the diagonal instance, so the
  ~45-line coinduction is written once rather than twice.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` —
  `fwdLiveAt` / `mem_fwdLiveAt` / `fwdLiveAt_subset_posAt` / `liveAt_subset_fwdLiveAt`, `R₀fwd` and
  `R₀_subset_R₀fwd`; `foldF_head` (every `NM + NF + k·NF` is a `FoldF` of `NM + NF`);
  `nextTime_ge_right` (the forward wrap never leaves the right periodic region);
  `mem_R₀fwd_of_fwdLive_head`; `TailStableRaw` with `decidableTailStableRaw`; the repaired
  `TailStable` with `decidableTailStable`; `tailStable_of_raw` (the raw demand is strictly stronger);
  `R₀_subset_Φ_fwd_R₀`; `R₀_subset_iterFwd` (the one-sided replacement for `iterFwd_R₀`);
  `forall_mem_R₀_of_live_head` (the one-period induction) with `mem_R₀_of_live_head` as its
  corollary. `iterFwd_R₀`'s hypothesis becomes `TailStableRaw`, its body unchanged.
  `live_of_mem_R₀_head`'s proof changes by one line. `tailStable_iff_window`,
  `tailStable_iff_window_fwd`, `liveAt_tail_eq_L₀`, `liveAt_winLo_eq_L₀`, `mem_L₀_of_live_tail`,
  `iterBack_L₀` and every other landed declaration keep their statements.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/FixtureStable.lean` — `not_tailStable`
  renamed to `not_tailStableRaw` (same proof, same content, about the demand that is still
  refuted); `not_tailStableRaw_cert` added; `not_tailStable_cert` keeps its statement, now proved
  from the backward conjunct, which the fixture still fails. New: `not_mem_lab_gd`,
  `not_mem_lab_ev` and `not_mem_R₀fwd_pR` — the witness of the raw refutation is forward-dead at
  the reference time, so the filter removes it. Module header records the ruling that settled the
  design question it escalated.

## Decisions

### Dispatch 47 (sub-phase 20.1)

- **Split Phase 20 at a point one bullet earlier than its Contingency names, and say why.** The
  Contingency puts the construction, `BiSerial` **and `TailStable`** in 20.1. `TailStable` is in 20.2
  instead, because the Contingency's split point was chosen on the strength of a false claim about
  the backward conjunct (see Plan Deviations). Reporting 20.1 as "the construction plus `BiSerial`
  plus the probe" is the honest description of what closed.
- **Reuse `Complete.lean`'s headline rather than proving `Certifies` directly.** `Certifies` has nine
  conjuncts, three of which read the computed liveness fixpoint. `Complete.lean`'s
  `exists_plusSlicedCertificate_of_tailStable_countermodel` constructs those three from `SlabTrue`
  and **produces** the box guess, so the embedding owes `BiSerial`, `TailStable`, `SlabTrue` and the
  four path hypotheses instead. This is why `bx := fun _ => false` is a deliberate choice and not a
  placeholder: `canAt`, and hence `canLab`, read the slice labelling rather than the box guess
  (`Complete.lean`'s `withBx_canAt` is the lemma that says so), so nothing 20.2 must establish
  depends on it.
- **`slab t i` is the FULL translated label `trLab (W.L i t)`, not its atom-and-box part.** The plan
  says "the atoms and `bx`-boxes of `(lassos i).lab t`". Restricting is unnecessary —
  `AgreesOnState` quantifies only over the state shapes in the closure, so extra non-state-shape
  content is invisible to it — and the unrestricted image makes `sliced_slab` a one-line readout and
  `mem_trLab` an injectivity transfer. Recorded because it is a divergence from the plan's wording,
  not because it is load-bearing.
- **The embedded target path is cut at exactly the slice sequence's own three lengths.** This is the
  deliberate choice the plan's v10 bullet asks to be made and recorded: it collapses
  `NBnat = Nat.lcm perB perB` to `perB` and likewise forward, keeping the residue count of the
  tail-stability demand at the family's own periods. A coprime choice would have multiplied both
  counts and with them 20.2's proof obligation. **No bound is claimed either way** — a product of the
  family's own periods is a construction, not a complexity claim.
- **Land the probe as kernel-checked theorems rather than as `#eval` measurements.** A `#guard` or a
  scratch-file `#eval` records a number in a report; a `by decide` theorem records it in the build.
  The user ruling on probe citation is satisfied by this route rather than worked around: these are
  ordinary library declarations in `FormalSystem/**`, so the module docstring cites them by name, and
  no `specs/**/probes/...` path and no probe declaration name from outside the library is cited
  anywhere.
- **Prefer `by decide` over `#eval` when probing this subtree.** Measured, not assumed: the module
  with all four `decide`s elaborates in 4.6 s, while the same verdicts through the interpreter took
  15 s and 94 s. The liveness path contains `noncomputable` declarations (`untlTasks` and friends,
  via `Finset.toList`) that make `#eval` refuse outright on anything touching a failed elaboration,
  which is a second reason to stay in the kernel.

### Dispatch 46 — Phase 19

- **The produced certificate keeps `G₀`'s target path and target time, rather than re-extracting a
  path by pigeonhole.** This is the dispatch's one substantive design decision and it was forced by
  a measurement, not chosen for convenience: `Window.lean`'s combined periods are
  `NBnat = Nat.lcm back.length target.back.length` and `NFnat = Nat.lcm fwd.length target.fwd.length`
  with `NM = max nm target.nm`, so the window — and therefore `winTimes`, the `liveT` fixpoint and
  `liveAt`, and therefore `TailStable` itself — depends on the target path's three segment lengths.
  A re-extracted path with different periods changes the demand the hypothesis `hstab` is supposed to
  discharge, and no period-independence theory exists here. Keeping the path makes the conclusion
  **stronger** (six carrier equations, not four) and moves the refuting path into the hypotheses,
  where a countermodel naturally carries it.
- **`SlabTrue` is stated against truth, and the truth lemma is re-proved rather than reused.**
  `Sound.lean`'s truth lemma takes the checker's clauses as hypotheses, which is exactly what this
  phase has to *produce*; reusing it would be circular. The new proof is the same seven cases with
  the `□` and `⊡` cases one rewrite each, and it consumes no checker clause at all.
- **The canonical box guess is read off a slice label, not defined semantically.** `canonBx χ` is
  `decide (box χ ∈ G.slab 0 ⟨0, _⟩)`. A semantic definition would have needed `Classical.dec` and
  made the guess noncomputable for no gain: under `SlabTrue` the `□`-content of the labelling is the
  same at every carrier element, because that clause's right-hand side mentions neither time nor
  state.
- **`withBx` is `@[reducible]`, deliberately.** Not a style choice: `rw` typechecks its motive at
  *implicit* transparency, where a semireducible `withBx` leaves `Finset (G.withBx bx).Pos` and
  `Finset G.Pos` as different types, and the rewrite inside a tail-stability conjunct fails with an
  "Application type mismatch" on an argument that is definitionally fine.
- **Non-vacuity is proved, not asserted.** `Probe.exists_certifying_triv` discharges all eight
  hypotheses at `Check.lean`'s `Probe.triv`. The honest limit is stated in the module itself: it
  shows the hypothesis set is *consistent*, not that the class is interesting.

### Dispatch 44 — Phase 18

- **`TailStableRaw` was strengthened alongside `TailStable`.** Had the raw demand kept its
  single-equation form, `tailStable_of_raw` would have become **false** — the residue-indexed
  `TailStable` does not follow from two equations at `r = 0`. Strengthening both keeps the two demands
  differing in exactly one respect, the liveness filter on the forward conjunct, which is what the
  existing docstrings claim about their relationship.
- **The three-region construction was generalized in place rather than copied.** The blocker record
  asked for "a reference-time-generic copy of `tailPos` and its six lemmas". A copy would have
  duplicated ~150 lines and left two objects to keep in step; adding the reference time as a parameter
  and deriving the `-G.NB` case as an instance costs nothing and cannot drift. The same was done on
  the right tail (`headPos`), which the blocker record did not mention but which `exists_win_live_eq`
  needs — `exists_win_live_eq` quantifies over *every* `t`, including large positive ones.
- **`Tail.lean` was created rather than growing `Stable.lean`.** `Stable.lean` stood at 1498 lines
  against a 1500-line limit; the residue machinery would have pushed it to ~1670. The split line is the
  one the mathematics already draws: the forward half of the collapse is the transfer's own soundness
  iterated and stays, the reverse half is a construction and moves. `runOfPos` is the interface between
  the two and stays where it was.
- **The truth lemma is stated against `canAt`, not against a run's label.** This follows dispatch 42's
  finding rather than being a new decision, but it is what makes the statement's shape look unusual: a
  run's label is recovered as a theorem (`lab_eq_canLab`) rather than assumed.

### Dispatch 41

- **The box clause reads live positions, not the slice labelling.** The Phase 17 bullet's first
  sentence and its plan-v7 parenthetical disagree, and the first sentence is the one that is right.
  `AgreesOnState` pins the slice labelling to a position's label only on the **state shapes**
  (`IsStateShape`: `atom`, `box`, `stab`), so for a `χ` of any other shape `χ ∈ G.slab t w` is
  unconstrained data: a demand stated against it would neither follow from nor imply `χ`'s holding
  at the carrier element, and a countermodel-derived certificate whose `slab` carries the
  state-shaped part of the L⁺ type would be forced to report `G.bx χ = false` for every
  non-state-shaped `χ`. `Certifies` carries `BoxLiveFaithful`; `BoxFaithful` stays in `Basic.lean`,
  unweakened and unused. **Phase 21's condition-set record must be rewritten** — the plan's design
  item 5 is amended accordingly.
- **The existential side is stated on the computed position graph, and fulfilment is supplied rather
  than demanded.** Both halves of this are forced: `PlusFulfillingSeqLab`'s two clauses are
  unbounded existentials over ℤ, so no checker can carry them, and `PlusLocalCoherentSeqLab` reads
  `lab (t ± 1)`, so `forall_iff_win` cannot fold it. `TargetPathPos`'s two `Finset` memberships are
  *exactly* `LabCoherent`, `AgreesOnState`, `G.edge` and `StepClause`, and the box clause follows
  from (C3b). The plan's own instruction — write the clause against the computed form, never against
  `Live` — is what this honours.
- **`G.targetTime ∈ G.winTimes` is added as a target-group side condition.** It is not a fourth
  structural conjunct and not (C3b) under another name; the Scope Hypothesis's check was applied
  before adding it. `Fixture.live_not_determined_by_slice` is the reason it is needed: liveness is
  not a function of the slice, so the computed live set exists only at window times. It narrows the
  class not at all, since `winLo = -2·NB < 0 ≤ NM + 2·NF = winHi`.
- **`forall_iff_win_succ` proves the fold by single-period induction, not by residue arithmetic.**
  The residue route would need the representative's distance from `t` as an explicit multiple of the
  period, which forces reasoning about `Int` division's rounding; the single-shift induction needs
  only `0 < NB` and the two region bounds, and `omega` discharges every side condition.
- **The `#guard`s are `#guard`, not `decide`-in-a-proof.** A kernel proof that `triv.Certifies`
  holds would not show that the instance *computes*; `#guard` runs the compiled instance, which is
  the point of exhibiting a certificate at all. The repository's existing idiom
  (`BiLasso/Examples.lean`, `PlusWitnessFamily/Fulfil.lean`) is followed verbatim, including the
  `linter.hashCommand` reason comment.
- **The second concrete certificate is not exhibited, and the reason is measured.** See Verification.

### Dispatch 40

- **The ruling implemented is option 2, the liveness-filtered transfer, and plan v8's candidate-1
  record is treated as a misattribution.** `.decisions.json`'s third entry, timestamped
  2026-09-30T19:31:18Z with provenance "`/orchestrate` batched ask_user relay (blocking)", selects
  option 2 and states "Options 1 (keep the narrowed class), 3 … and 4 … are NOT taken". Plan v8,
  committed 2026-10-01T00:00:04Z — **after** that entry was written, with no later entry appended —
  records candidate 1 as a user ruling of the same date. Dispatch 40's own context relayed the
  option-2 entry as settled, with instructions not to re-ask. The two records cannot both be the
  user's decision; the `.decisions.json` entry is the one with recorded provenance, the one that
  names its rejected alternatives, and the one this dispatch was handed. The most likely origin of
  the candidate-1 text is aux dispatch 39's blocker-research recommendation read as a ruling.
- **The change is made non-destructively, so that reverting it is a one-line swap.** `TailStableRaw`
  keeps the raw demand and `iterFwd_R₀` keeps its body; `Fixture.Φ_fwd_R₀_ne` and
  `Fixture.mem_Φ_fwd_R₀_pR` are untouched.
- **The filter is the computed FORWARD-live set, not `liveAt`.** (i) `winHi ∉ winTimes`, so
  `liveAt winHi = ∅` and that demand would force `R₀ = ∅`; (ii) the `→` half of the collapse needs
  "genuinely live far down the tail ⟹ in the filter", which `FoldF` supplies for the forward half
  and no relation supplies for a backward half, because `FoldB` relates only negative times.
- **`Fixture.not_tailStable` is renamed rather than weakened or deleted.** Its content is preserved
  verbatim as `not_tailStableRaw`; this is the one landed name that does not survive.
- **No claim is made that `(certRep a b c).TailStable` holds.**

### Dispatch 42 — Phase 18

- **The canonical labelling is syntactic, never the true type.** The plan's design item "every step
  path carries its own true type sequence" is false *as an argument*:
  `plusTypeAtM_localCoherentSeqLab` takes the box guess's semantic correctness as a hypothesis, and
  `AgreesOnState` for the true type *is* that correctness at the `□` and `⊡` shapes, so building a
  run at an arbitrary history needs what building it was meant to prove. The circle does not break
  by induction on the formula, because `AgreesOnState` quantifies over **every** state shape of the
  closure, including shapes larger than the formula in hand. `canAt` reads `G.slab` by fiat instead,
  and so mentions truth nowhere.
- **`canLab` is noncomputable, deliberately.** Its temporal cases are unbounded existentials over ℤ;
  the filter uses `Classical.decPred`, exactly as `plusTypeAtM` does. Nothing computational depends
  on it — a checker reads `G.liveAt`, never a canonical label.
- **The `box` case of the truth lemma needs no liveness transport, and that is a finding, not an
  assumption.** `plusBox_const` makes `∀ σ, PlusTruthAt … σ v χ` independent of `v`, so
  `BoxLiveFaithful` may be read at the single window time `-G.NB`. Route 1 of the plan's READ FIRST
  block therefore does work — for `box`, and only for `box`.
- **The `⊡` clause is kept on live positions and not moved to `G.posAt`.** The `posAt` form
  transports freely (`posAt_congr` + `exists_win_eq_slice`) and would make the `stab` case's `→`
  trivial, but its `←` is false: a position no history occupies constrains nothing. Recorded as a
  prohibited workaround rather than taken.
- **Phase 18 is escalated, not deviated.** The repair edits `TailStable`, a Phase 16 definition, and
  narrows the certificate class; `.claude/rules/plan-compliance.md` requires that be raised rather
  than substituted, and the two prior rulings in this task were of exactly this kind.

## Plan Deviations

### Dispatch 47 (sub-phase 20.1)

- **Phase 20 task 4 ("Prove the embedded certificate is `BiSerial` … and prove the **backward** half
  of `TailStable`") — the bullet's premise is FALSE and the backward half is DEFERRED to 20.2.** The
  bullet reasons that "with edges `i → i` only, `Φ_back` is the identity on the position sets it acts
  on, so the fixed-point demand `Φ_back L₀ = L₀` is immediate", and plan v9's amendment keeps that
  identity argument while making it uniform in `r`. The identity claim does not hold.
  `Stable.lean:130` defines
  `stepBack t X = (posAt (t - 1)).filter (fun p => (succP (t - 1) p ∩ X).Nonempty)` — a
  `succP`-**preimage** — and `succP` constrains the arriving label only through `StepClause`, which
  permits the label to change along the step. The self-loop relation pins the **state** component of
  a position and says nothing about its **label** component, and the label component is where the
  difficulty lives. So `stepBack t X` is "the positions at `t - 1` whose index matches some member of
  `X` and whose label is `StepClause`-compatible with it", at a different time and in general a
  different set. The backward conjunct is an equation between a `succP`-preimage and a computed live
  set, of the same order of difficulty as the forward one, and it does not reduce to the self-loop
  structure. Both conjuncts therefore moved together into 20.2, and `sliced_biSerial` — which **is**
  short, and is proved — is all that closed from this bullet.
- **Phase 20 task 5 (the PRINCIPAL RISK bullet) — the mandated probe RAN; the proof is DEFERRED to
  20.2.** The bullet's instruction was followed to the letter as plan v9 amends it: the object
  evaluated is the **landed** `G.TailStable`, each conjunct separately first, at a concrete embedded
  certificate, with the verdict and the wall time recorded. Verdict: **favourable** — see
  Verification. The bullet's "do not start the proof before the probe returns" is honoured; the proof
  itself did not fit this run.
- **Phase 20 task 2 — altered.** The embedding landed as `WitnessFamily.sliced`, a namespaced member
  taking the family as receiver, rather than as a free `slicedOfWitnessFamily`. Same object, same
  signature content.
- **Phase 20 tasks 6, 8, 10 — deferred to sub-phase 20.2** (`Certifies`, the flagship assembly, the
  task-704 hand-off record).
- **Phase 20 task 7 ((C3b) `BoxLabelFaithful`) — deferred to 20.2, and the route changed.** On
  `Complete.lean`'s headline (C3b) is **produced** from `canonBx` rather than constructed by the
  embedding, so what 20.2 actually owes is `SlabTrue`'s `□` clause. The bullet's observation — that
  `box χ ∈ slab t i ↔ bx χ` holds by construction off the translated label — remains true and is
  available, but it is not the clause the chosen route consumes.
- **Phase 20 task 9 — partially done.** `Embed.lean`'s header records the construction, the period
  choice and, explicitly, the limits of what the probe shows. The "what this theorem buys" paragraph
  (non-vacuity on branching-free targets; **not** completeness for L⁺) belongs with the flagship and
  is deferred to 20.2.
- **Scope Hypothesis — CONFIRMED, no correction needed.** The `WitnessFamily` structure was read
  before the edge relation was fixed, as the hypothesis requires. It carries `bx`, `lassos` and
  `lassos_ne` and **no succession relation of any kind**, and its four conditions quantify over one
  lasso index at a time (`LocalCoherentLab` and `FulfillingLab` at a single `i`; `BoxFaithful`
  universally quantifies indices on its right-hand side but relates no two of them; `Target` reads
  lasso `0`). So `fun i j => decide (i = j)` needs no amendment. The period assertion is confirmed
  too: the L-side family stores no periods at all, so `perB` / `perF` / `perM` mirror the L⁺ side's
  `perBack` / `perFwd` / `perMid` computation, and only divisibility, the sum bound and positivity
  are used.
- **One commit defect, recorded rather than hidden.** Commit `6b8e3d05d` carries `Session:` but not
  the two attribution trailers every other task-703 commit carries;
  `git-commit-scoped.sh` does not add them and they were omitted from the `--message`. The amend was
  attempted and **correctly refused** by `guard-destructive-git.sh` (a live concurrent writer exists
  in this repo), so the commit was left as it stands rather than force-rewritten.

### Dispatch 46 — Phase 19

- **Phase 19 closes as [COMPLETED WITH EXCLUSIONS]**, with three exclusions enumerated under the
  plan's Phase 19 heading. In brief:
  1. **"Build the target path" (paired-carrier pigeonhole) — SKIPPED.** Reason: the plan's own
     justification for expecting the `TailStable` transfer to be a one-liner is **false**. Plan v9's
     READ-FIRST item 3 asserts `TailStable` "quantifies over `n`, `back`, `mid`, `fwd` and the
     closure only"; `Window.lean:95-109` shows it also depends on the target path's three segment
     lengths. The refuting path is carried by hypothesis instead and the conclusion carries **six**
     carrier equations rather than four. The `exists_good_cycle_of_plusTypeSeq` Scope Hypothesis is
     therefore **neither confirmed nor refuted**, and is not carried as settled.
  2. **The five `plusTypeAtM_*` citations the plan names — NOT USED.** The sliced side cannot argue
     from a truth-based labelling at all (`Canon.lean`'s header records why), so the same five
     obligations are discharged against `Canon.lean`: well-definedness is structural, local coherence
     and fulfilment are `canLab_localCoherent` / `canLab_fulfilling`, and the universal side is
     `exists_path_canLab_of_live` — the **uniqueness** half, which gives strictly more than the
     bullet asked for.
  3. **`tailStable_iff_window` — NOT CITED**, per plan v9's own amendment. Only the box clause's `←`
     direction needs a transport to an arbitrary time, and it cites `exists_win_live_eq`.
     `StabFaithful` needs none: its asking time is already a window time.
- **Declaration count recorded** (the Scope Hypothesis asks for it): 40 declarations, 711 lines.

### Dispatch 44 — Phase 18

- **Truth-lemma bullet** altered: landed as `plusTruthAt_iff_canAt` against `canAt` rather than
  against "the label of a labelled path of `G`", for the circularity reason dispatch 42 recorded. The
  bullet's sub-item for `untl` / `snce` ("mirror `plusTruth_iff_mem`'s proof rather than inventing a
  new one") was **not needed**: `canAt` takes the existential form of both, which is the semantic
  clause verbatim, so each direction is a direct transfer under the induction hypotheses. No
  fulfilment and no step clause is consumed anywhere in the truth lemma; both were spent inside
  `Canon.lean`.
- **`box` sub-item** altered: the plan's dispatch-42 record says Route 1 "*does* work — for `box`, and
  only for `box`", i.e. that the box clause may be read at one fixed window time with no transport.
  That is correct about the **formula's** time and incomplete about the **position's**: the live
  position whose label must carry `χ` still sits at an arbitrary time, so the `□` case consumes
  `exists_win_live_eq` as well. Recorded as a finding at the plan's Phase 18 heading.
- **Phase 16's `TailStable` was edited**, which `.claude/rules/plan-compliance.md` requires be
  escalated rather than substituted. It **was** escalated — dispatch 42 returned `user_decision`, the
  user ruled in cycle 3 — and this dispatch implemented the ruling as worded: a bounded quantifier
  over each period's residues, `r = 0` recovering the present conjunct verbatim, every reference time
  a window time so `decidableTailStable` survives.
- The four Phase 18 checklist items dispatch 42 annotated `*(deviation: deferred — …)*` are now
  `- [x]`, each with its deferral replaced by what landed.

### Dispatch 42 — Phase 18

- **`Sound.lean` deferred** (checklist item 1), **truth lemma deferred** (item 2),
  **`plusRefutes_of_certifies` deferred** (item 3), **`Sound.lean` docstring record deferred**
  (item 5) — all four blocked on the residue-indexed `TailStable`. Annotated inline at the plan's
  Phase 18 checklist.
- **The (C3b)-projection item (item 4) altered**: answered as a finding rather than carried out as a
  proof step. The bullet's reading of the `stab` case is confirmed (`→` needs no (C3b); `←` routes
  through `live_of_mem_liveAt`, which takes it), and (C3b) turns out to be needed in a third place
  the bullet does not name — `canLab_localCoherent`'s `□` clause, i.e. in building a run for an
  arbitrary history at all.
- **`Canon.lean` is a file the plan does not list.** Phase 18's "Files to modify" names only
  `Sound.lean`, the aggregator and the regenerated root. `Canon.lean` is the prerequisite the
  phase's third bullet assumed; it is recorded at the Phase 18 heading rather than smuggled in.

### Dispatch 41 — Phase 17

- **Existential-side bullet** altered: stated as `TargetPathPos` + `targetLive` on the computed side,
  not as `PlusLocalCoherentSeqLab` + `PlusFulfillingSeqLab`. Annotated inline; reason above.
- **Universal-side bullet** altered: the universal obligation is the `→` direction of
  `StabFaithful`'s biconditional rather than a clause of its own.
- **Box-clause bullet** altered: `BoxLiveFaithful` on live positions, not (C3) `BoxFaithful` via
  `forall_slab_iff_window`. This one propagates: Phase 21's condition-set record and the plan's
  design item 5 are both amended.
- **Assembly bullet**: one clause added (`G.targetTime ∈ G.winTimes`) and the conjunct count is nine
  rather than "three plus four groups", because the target group is four clauses.
- **Concrete-certificate bullet** altered: the first certificate is exhibited and green; the second
  (the fixture's re-presentation) is **not**, because it does not evaluate at the fixpoints' present
  implementation. Measured, not predicted — see Verification.
- Every other Phase 17 bullet is completed as written. No bullet was skipped and none deferred.

### Dispatch 40 — sub-phase 16.3

- **Phase 16's `TailStable` checklist item** altered: the forward conjunct is now
  `Φ_fwd R₀ ∩ R₀fwd = R₀`; the conjunction the item names is kept as `TailStableRaw`.
- **Phase 17 was not started in dispatch 40**, the repair being its hard prerequisite. Dispatch 41
  closed it.
- **A plan-text correction was written at Phase 17's heading** rather than silently followed or
  silently overridden.

## Verification

### Dispatch 47 (sub-phase 20.1)

- **Build**: full `lake build` **Success** — 2804 jobs (one more than dispatch 46's 2803, the new
  module), **zero errors, zero warnings**, guard exit 0, run detached through
  `lake-build-guard.sh --no-share`. Tier-3 evidence recorded: `.olean` newer than source for
  `Embed.lean`, the aggregator and `FormalSystem.lean`.
- **Sorry count**: 0 (`lean-sorry-census.sh` over the 8 resolved source roots).
- **Vacuous count**: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`), **pre-existing and untouched**, as every prior dispatch in
  this round records.
- **Axiom count**: 14, **unchanged**. `#print axioms` on all twelve new declarations
  (`sliced`, `sliced_biSerial`, `sliced_slice`, `sliced_stabFaithful`, `sliced_target_edge`,
  `plusClosureOf_ofCtx`, `Periodic.unrollOf_seg`, and the five `Embedded.*` probe facts): each
  exactly `[propext, Classical.choice, Quot.sound]`.
- **The two protected soundness theorems survive with their statements unchanged**:
  `git diff --stat -- FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` is **empty**, and
  `PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` report the same
  three-axiom set.
- **THE TAIL-STABILITY PROBE — the phase's mandated measurement.** Each conjunct was evaluated
  separately first, as the bullet asks, then the conjunction:

  | Certificate | window times | timed vertices | backward conjunct | forward (filtered) conjunct | `TailStable` | `TailStableRaw` | raw `Φ_fwd R₀ = R₀` |
  |---|---|---|---|---|---|---|---|
  | `Embedded.emptyFamily.sliced 0` | 4 | 8 | true | true | **true** | false | false |
  | `Embedded.liveFamily.sliced (-1)` | 6 | 12 | — (conjunction only) | — | **true** | false | false |

  Both families have `perB = perF = 1`; `perM` is `0` and `2`. The second is a **certifying**
  `WitnessFamily [] [p U q]` (`liveFamily_certifies : liveFamily.Certifies (-1)`, also by `decide`)
  whose single lasso carries the eventuality at time `0` and discharges it at time `1`, so the demand
  is tested against a live `untl` obligation rather than an empty closure.

  **Wall time, as the bullet requires**: the whole module including all four `decide`s elaborates in
  **4.6 s**; the same verdicts computed through the interpreter in a scratch file took **15 s** and
  **94 s**. Phase 17's fear that the probe itself would be the expensive thing did not materialize at
  these sizes.

  **What the probe shows**: the conjecture is **not refuted** at the embedding, and the liveness
  filter is **load-bearing** there — at the same certificate where the landed demand holds, the raw
  demand fails. **What it does not show**: that `TailStable` holds at every embedded certificate.
  Two certificates of eight and twelve timed vertices is not a general argument, and nothing landed
  claims one.
- **Repo gates**: `scripts/typst-sync-check.sh --fix` **PASS**.
  `scripts/check-module-invariants.sh`: **C2 PASS** (all twenty-two pinned axiom sets match
  baseline), **C3 PASS**, **C9 PASS** (zero task-number citations under `FormalSystem/`), **INV
  PASS**. Residual failures are **exactly** dispatch 46's pre-existing set at **identical counts** —
  `C16`, `C23` (7 `Uppercase_x` + 1 shadowing pair), `C24`, `C26` — and **`Embed` appears nowhere in
  the gate output**. Two C23 regressions this file did introduce
  (`L_sub_perB`/`L_add_perF` as `Uppercase_x` names; `getD_range_map` and `qF` shadowing existing
  declarations at `BiLasso/Extraction.lean:91` and `Conservativity/DenseObstructionTransfer.lean:196`)
  were caught by the gate and renamed before the commit.
- **Files verified**: Yes.
- **Tests**: N/A for this sub-phase (no `BimodalTest` surface added); `C1 lake build BimodalTest`
  passes inside the invariants run.

### Dispatch 46 — Phase 19

- Build: **Success** — full `lake build` through `.claude/scripts/lake-build-guard.sh` (detached,
  `--no-share`, `--timeout 5400`): **2803 jobs**, exit 0, zero errors, zero warnings. The guard's own
  `STATUS: exit_status=0` is the recorded verdict; `Complete.olean` and every module this dispatch
  touched are newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over the 8 roots `lean-src-roots.sh` resolves).
- Vacuous count: **1**, pre-existing and untouched —
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal … := trivial`), a true
  statement about `intTimeHistory.domain` over `ℤ`, not a placeholder.
- Axiom count: **14**, unchanged.
- `#print axioms`: `exists_plusSlicedCertificate_of_tailStable_countermodel`,
  `exists_certifying_of_tailStable_countermodel`, `plusRefutes_of_tailStable_countermodel`,
  `plusTruthAt_iff_canAt_of_slabTrue` and `Probe.exists_certifying_triv` each report exactly
  `[propext, Classical.choice, Quot.sound]`.
- **The two protected soundness theorems are untouched**:
  `PlusSharingWitnessFamily.plusRefutes_of_certifies` and `...plusTruth_iff_mem` report the same
  three axioms, and `git diff --stat` over
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` is **empty**.
- `scripts/typst-sync-check.sh --fix`: **PASS** (status.typ, module map and machine appendix all in
  sync; `status.typ` regenerated and staged).
- `scripts/check-module-invariants.sh`: the two groups this dispatch perturbed are **repaired** — the
  `INV` generated-inventory block (fixed with `--emit-inventory`, rewriting the three README
  inventories) and the warning budget (two `linter.style.longLine` NEW findings in the aggregator's
  added bullet, fixed by reflowing to 100 columns; the budget file was **not** raised). The residual
  four failures are pre-existing and untouched, and none names `Complete.lean`: `C16` (the
  `env_linter defsWithUnderscore` findings on `Φ_back` / `Φ_fwd`), `C23` (seven `Uppercase_x` names
  in `Fixture.lean` / `FixtureStable.lean` / `Stable.lean` plus one outer-shadows-inner pair on
  `datum`), `C24` (`PlusSlicedCertificate.Fixpoint` does not transitively import
  `FormalSystem.Init`), `C26` (`Φ_back` / `Φ_fwd`).
- The headline's hypotheses place **no** bound on `G₀.n`, `|G₀.back|`, `|G₀.mid|` or `|G₀.fwd|`,
  confirmed by reading the statement: the only hypotheses are bi-seriality, tail-stability, slab
  truth, the two path conditions, the window membership of the target time and the two refutation
  conditions.
- The module states no width bound and no period bound, and nowhere describes the sliced finite model
  property as refuted: it says the opposite ("open, not refuted"), confirmed by grep for `refut` in
  its docstrings.
- Files verified: Yes.
- **Plan-compliance spot-check: FAILED, and recorded as failed rather than smoothed over** — but
  neither finding class is a defect of this dispatch, and the dispatch status is deliberately not
  demoted. The check scans *every* `**Goals**:` block in the plan, including `[NOT STARTED]` phases,
  so it structurally cannot pass until the last phase lands. Three of its four findings are **false
  negatives**: `PlusGraphPath`, `PlusSlice` and `PlusSlicedCertificate` are `structure` declarations
  and the check's grep matches only `theorem`/`def`/`lemma`/`instance`; all three are present at
  `PlusSlicedCertificate/Basic.lean:140`, `:280` and `:328`. The fourth is genuinely absent:
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` is **Phase 20's** goal and Phase 20
  is `[NOT STARTED]`. Phase 19's own goal,
  `exists_plusSlicedCertificate_of_tailStable_countermodel`, is `[OK]`.

### Dispatch 44 — Phase 18

- Build: Success — full `lake build`, **2802 jobs**, exit 0, zero errors, zero warnings.
- Sorry count: 0.
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`), pre-existing, landed under a much earlier task, untouched
  here, and a true statement about `intTimeHistory.domain` over `ℤ` rather than a placeholder.
- Axiom count: 14, unchanged.
- `#print axioms`: `plusRefutes_of_certifies`, `plusTruthAt_iff_canAt` and `exists_win_live_eq` each
  report exactly `[propext, Classical.choice, Quot.sound]`.
- **Soundness untouched**: `git diff` over
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` against the dispatch's base commit shows
  **no hunk at all**, and `PlusSharingWitnessFamily.plusRefutes_of_certifies` /
  `...plusTruth_iff_mem` still report the same three axioms.
- The new theorem's conclusion is `PlusWitnessFamily.PlusRefutes Γ Del` verbatim, not a new
  refutation predicate.
- `#guard decide triv.TailStable` still passes under the residue-indexed demand.
- `scripts/typst-sync-check.sh --fix`: PASS.
- `scripts/check-module-invariants.sh`: **4** failing groups, down from 5. The `FAIL INV` this
  dispatch introduced by adding two modules was repaired with `--emit-inventory`. `C16` (the
  `env_linter` `defsWithUnderscore` findings on `Φ_back` / `Φ_fwd`), `C23`, `C24`
  (`PlusSlicedCertificate.Fixpoint` does not transitively import `FormalSystem.Init`) and `C26` are
  pre-existing, name declarations and modules this dispatch did not create, and are untouched.
- Tests: N/A (no test-suite change). Files verified: Yes.

**Mechanical notes that cost time, recorded so they are not re-discovered.** `ring` is **not** in
`Stable.lean`'s import closure, so `exists_residue_back` / `_fwd` use `Nat.mod_add_div'` plus
`sub_add_eq_sub_sub` / `← add_assoc`. Mixing `ℤ × Fin G.n` and `(G.frame h).WorldState` in a `rw`
motive produces an "Application type mismatch … expected to have type `(G.frame h).WorldState`" note
and then leaves a goal that *prints* as `X = X` unsolved; keep every intermediate equation ascribed at
one of the two types and hand the result to `WorldHistory.ext_state` by `exact`. `omega` fails on a
`WorldHistory.ext_state` binder, whose type is `F.Duration.carrier` rather than syntactically `ℤ`:
prove the pointwise statement over `v : ℤ` first. A `show` that changes the goal now trips a style
linter; use `change`.

### Dispatch 42 — Phase 18's prerequisites

- Build: **Success.** Full `lake build` through the build guard, detached, `--no-share`:
  **2800 jobs, `exit_status=0`, zero `error:` and zero `warning:`** across both captured streams
  (run twice: once after sub-step 18.1 and once after 18.2). Tier 3 checked by hand: the `.olean`
  for `PlusSlicedCertificate.Canon`, `PlusSlicedCertificate` and `FormalSystem` is newer than its
  source.
- Sorry count: **0** (`lean-sorry-census.sh` over the eight resolved source roots; empty inventory).
- Vacuous count: **1, pre-existing and not a placeholder** — the same
  `FormalSystem/Examples/TemporalStructures.lean:495` hit the dispatch-41 block below records, last
  touched many tasks ago (`git log -1` on that file) and untouched here.
- Axiom count: **14, unchanged**. No new axiom.
- **Axiom footprint of the new declarations confirmed by `#print axioms`**, not assumed:
  `canRun`, `live_canRun`, `lab_eq_canLab`, `live_iff_canLab` and `canLab_fulfilling` each depend on
  exactly `[propext, Classical.choice, Quot.sound]`. `Classical.choice` enters through `canLab`'s
  `Classical.decPred` filter and nowhere else.
- Tests: N/A — no test-suite change in scope; `lake build` covers `Tests/BimodalTest`.
- Files verified: Yes.
- `scripts/typst-sync-check.sh --fix`: **PASS** (status.typ, module map and machine appendix all in
  sync). Note it cannot run before a **full** build: it reads the axiom sets off the built library
  and fails with "could not read axiom sets" after a scoped module build.
- `scripts/check-module-invariants.sh`: the same **5** groups as dispatch 41 — `INV` (the generated
  inventory blocks, repaired here by `--emit-inventory`, as the new module changes them) plus the
  four pre-existing `C16`, `C23` ×2 and `C24` this task already owns from Phases 15-16.
- `lake exe mk_all --lib FormalSystem` exits **non-zero when it updates the file**; C33 then confirms
  the root is byte-for-byte generated (634 import lines).

### Dispatch 41 — Phase 17

- Build: **Success.** Full `lake build` through the build guard, detached, `--no-share`:
  **2799 jobs, `exit_status=0`, zero `error:` and zero `warning:`** across both captured streams.
  Tier 3 checked by hand: the `.olean` for `PlusSlicedCertificate.Check`,
  `PlusSlicedCertificate` and `FormalSystem` is newer than its source.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots; empty inventory).
- Vacuous count: **1, pre-existing and not a placeholder.** `FormalSystem/Examples/
  TemporalStructures.lean:495` `theorem int_domain_universal (t : Int) : intTimeHistory.domain t :=
  trivial` — a true statement about the `Int` time domain whose proof happens to be `trivial`. The
  file is untouched by this dispatch (`git diff HEAD -- …` is empty) and the same count holds at
  main-tree `HEAD`.
- Axiom count: **14, unchanged**, identical at main-tree `HEAD`. No new axiom.
- Tests: N/A — no test-suite change in scope; `lake build` covers `Tests/BimodalTest`.
- Files verified: Yes.
- **Decidability confirmed by synthesis, never by assertion.** Eight `example … := inferInstance`
  lines elaborate: `Decidable G.BiSerial`, `G.TailStable`, `G.BoxLabelFaithful`, `G.TargetPathPos`,
  `G.StabFaithful`, `G.BoxLiveFaithful`, `G.Target` and `G.Certifies`. The first attempt at
  `decidableCertifies` failed for two of them, which is why they are confirmed separately: a
  "`Certifies` is not decidable" message does not say which conjunct caused it.
- **No clause is aligned.** `grep -n plusAlignOffset Check.lean` returns nothing, and no clause
  mentions a period product or an absolute origin.
- **The checker runs, and it is green on a concrete certificate.** `Probe.triv` — the one-slice
  `onePointCertificate` at the empty context — satisfies all nine clauses and `Certifies`; the ten
  `#guard` lines evaluate during `lake build` and all return `true`. Measured wall time, by
  `IO.monoMsNow` either side of the `decide`s in a scratch file, interpreted under Lean
  v4.33.0-rc1: **11 ms** for all nine clauses together and **under 1 ms** for `Certifies`.
- **What does not run, measured rather than predicted.** The liveness fixpoint at `Fixture.cert`
  did **not** produce a value in **15 minutes** interpreted, so the plan's second concrete
  certificate is not exhibited. `Fixture.cert` is the family's smallest member
  (`cert = certRep 0 0 0`), and the **scale is not the reason**: `Fixture.cert.posAt 0` has **4**
  positions, `winTimes` has **5** times and `verts` has **20** timed vertices, all three of those
  counts evaluate instantly, and `fwdLiveT.card` evaluates too — it is **10**. What does not
  return is the pair: a run asking for `fwdLiveT.card` and then `bwdLiveT.card` did not finish in
  **7 minutes**, and the full clause sweep including `TailStable` did not finish in **15**. The cost is the nested fixpoint's and is visible in its shape:
  `fwdLiveStep` calls `untlLiveAt` once per vertex per closure member, each call an `EUFix.lfp`
  iterating `|verts| + 1` times over `|verts|` vertices, and `Nu.gfp` calls `fwdLiveStep`
  `|verts| + 1` times — with no sharing between calls, and `G.liveT` recomputed at every use site.
  **This is a statement about the fixpoints' present implementation, not about decidability:**
  `decidableCertifies` is a proof, and `Nu.gfp`'s iteration count is `V.card + 1`, a bound chosen
  for provability rather than for speed. (The 15-minute run's own `IO.println` output was lost to
  stdout buffering when `timeout` killed it, so the time is attributed to the fixpoint rather than
  to one named line; the surrounding counts were measured in separate, fast runs.)
- **Gate set re-measured in full.** `check-module-invariants.sh`: **five** groups failed before this
  dispatch's fix, four after. `INV` was fixed here by `--emit-inventory`. `B0` and `C9`, both
  recorded as failing at dispatch 25, now **pass**. The four survivors — `C16` (`Φ_back` / `Φ_fwd`
  underscores), `C23` Uppercase_x (7 names), `C23` shadowing (the `datum` pair) and `C24`
  (`Fixpoint` does not transitively import `FormalSystem.Init`) — are each attributable to Phases
  15-16, not to Phase 17: `Check.lean` introduces no underscore name, no `Uppercase_x` name, no
  shadowing pair and no new minimal element. All four are tabulated with disposal advice at Phase
  21's heading.
- `typst-sync-check.sh --fix`: **PASS** on all three checks after the full build.
- `validate-artifact.sh … plan`: **PASS**, 0 warnings.
- Plan compliance spot-check: the plan's Lean Challenge Statement names
  `PlusSlicedCertificate.Certifies` and `PlusSlicedCertificate.decidableCertifies`; both now exist
  under those exact names in `Check.lean`, and neither delegates to a replaced declaration.

### Environment hazards (carried forward from dispatch 40, both re-encountered)

The dispatch-41 worktree, provisioned from the main tree, inherited the **mismatched olean/trace
pairs** dispatch 40 reported: `PlusSlicedCertificate.Timed.olean` lacked `edge_congr`,
`succP_congr` and `predP_congr`; `Stable.olean` lacked `TailStableRaw`, `R₀fwd` and `fwdLiveAt`;
`Basic.olean` lacked `boxLabelFaithful_iff_window` — while every `.trace` claimed them current.
Seven of the subtree's sixteen modules had no `.olean` at all. The fix applied here was to delete
the whole `PlusSlicedCertificate` subtree's build artifacts (lib and ir) plus
`PlusSlicedCertificate.*` and `FormalSystem.*`, then rebuild. **The main tree still carries the
stale pairs** (link count 2), so the next worktree provisioned from it will inherit them again.
Every `lake` invocation in this dispatch went through the build guard, detached, with `--no-share`.

## Impacts

### Dispatch 47 (sub-phase 20.1)

- **The embedding's source object is now reachable from this subtree.** `Embed.lean` is the first
  module under `PlusSlicedCertificate/` to import the `Formula`-side witness-family layer
  (`WitnessFamily.Agreement`). Anything 20.2 needs from the L side — notably the two label-level
  inner inductions `untl_mem_of_witness` and `snce_mem_of_witness` — is in scope without a further
  import.
- **`Periodic.unrollOf_seg` is generic and reusable.** It is the converse of the three region
  lemmas, stated at an arbitrary `[Inhabited α]`, so any later construction that knows a function's
  two eventual periods can cut it into a lasso or a slice sequence without a bespoke argument. It is
  already used at two different `α` here (`PlusSlice n C` and `Finset PlusFormula × Fin n`, the
  latter at the path-dependent `Inhabited` instance `PlusGraphPath.inh`).
- **`plusClosureOf_ofCtx` removes a whole clause group from the `⊡`-free fragment.** Every
  `stab`-guarded clause in the condition set — (C5) `StabFaithful` and `SlabTrue`'s second
  conjunct — is vacuous on an embedded context. Any later work on the `⊡`-free fragment inherits
  that for free.
- **The liveness filter now has a positive witness, not only a negative one.** `FixtureStable.lean`
  shows the raw demand is unsatisfiable at a named certificate; these two certificates show the
  filtered demand is satisfiable at an embedded one while the raw demand still fails there. Together
  they are the two-sided evidence the cycle-5 ruling was taken on.

### Dispatch 46 — Phase 19

- **The sliced certificate class now has both adequacy directions.** `Sound.lean` takes an accepted
  certificate to `PlusWitnessFamily.PlusRefutes Γ Del`; `Complete.lean` takes a countermodel in the
  tail-stable, semantically labelled class to an accepted certificate, and composes the two
  (`plusRefutes_of_tailStable_countermodel`). Neither export was weakened to make them meet.
- **`plusTruthAt_iff_canAt_of_slabTrue` is reusable beyond this phase.** It is a truth lemma for the
  presented model that costs only semantic correctness of the slice labelling — no checker clause —
  so any later construction that *builds* a sliced structure from a model (Phase 20's embedding, or
  a Stage 3 successor) can read truth off `canAt` without first discharging the checker.
- **A correction to the record propagates.** Plan v9 asserts in two places that `TailStable` does not
  depend on the target path. It does, through the combined window. Any later phase that plans to
  re-present a certificate with a different target path must treat its tail-stability demand as a
  **new** demand, not a transferred one.

- **Dispatch 44 supersedes the first dispatch-42 bullet below and both dispatch-41 bullets it in turn
  supersedes.** Phase 18 is **not** blocked: it is `[COMPLETED]`. `exists_win_live_eq` — the single
  remaining obligation that bullet names — is landed in `Tail.lean`, and the `⊡` case consumes it in
  both directions as predicted. The bullets are kept verbatim below as the records they are.
- **The certificate class is narrower, and this is the live consequence for Phases 19-20.** A frame
  whose liveness wraps faithfully at one residue but not at another is now rejected. Phase 19's
  construction must satisfy the demand at **every** residue `r < G.NBnat` and `r < G.NFnat`, not only
  at `r = 0`, and Phase 20's embedding of the landed L witness family must be re-checked against the
  same. This is what the dispatch-42 `TailScheme`-level bullet anticipated; it is now actual rather
  than prospective.
- **The checker's cost rises** from two `Φ` applications and two `Finset` equality tests to
  `G.NBnat + G.NFnat` of each. Both sides of every conjunct remain computed `Finset`s, so the paired
  repository's search-bound expectations change by a factor of the period lengths, not in kind.
- **`PlusSlicedCertificate.plusRefutes_of_certifies` is now available** to any later module wanting a
  ℤ-time countermodel from a sliced certificate, with no hypothesis beyond `G.Certifies`.
- **Phase 21's acceptance gates are now actionable** — a `docs/theorem-index.md` row and a C2
  `AXIOM_BASELINE` pin for the new theorem. They were not before, because the theorem did not exist.
- **The reference-time-generic `tailPos` / `headPos` and the four `r = 0` projections are reusable.**
  Any later argument needing the tail collapse at a reference time other than `-G.NB` or `G.NM + G.NF`
  can instantiate the generic headline instead of re-running the construction.
- **Dispatch 42 supersedes the next two bullets.** Phase 18 is *not* unblocked: it is `[BLOCKED]`,
  the flagged risk is now a measured demand-level defect rather than a risk, and the `box` half of it
  has dissolved. The two bullets are kept verbatim below as the dispatch-41 record they are.
- **Phase 18's prerequisite is landed and its remaining obligation is a single named one.**
  `Canon.lean` closes the unflagged gap (every history is a fulfilling run) and sharpens liveness to
  `live_iff_canLab` — the live set at a time *is* the canonical image of the edge-path space. What
  remains is `exists_win_live_eq`: for every `t`, a window representative `s` with
  `∀ p, (G.Live t p ↔ G.Live s p)`. Both directions of the `⊡` case consume exactly that, and
  nothing else in Phase 18 does.
- **`TailScheme`-level consequence for Phases 19-20**: the residue-indexed `TailStable` the blocker
  names narrows the certificate class, so Phase 19's "completeness relative to tail-stable sliced
  models" is relative to a **smaller** class than plan v8 assumes, and Phase 20's embedding of the
  landed L witness family must be re-checked against the narrower demand. Neither is re-planned here.
- **`untl_pull` / `snce_pull` and `lab_eq_canLab` are reusable beyond Phase 18.** Any later argument
  that must pin a run's labels — Phase 19's reading of a countermodel's history as a labelled path is
  the obvious consumer — can cite the forcing lemma instead of re-deriving a labelling.
- **Phase 18 is unblocked and is handed four things to consume rather than rebuild**: `targetRun`,
  `exists_fulfilling_run_at_targetTime` (which already performs the (C3b) projection that phase's
  fourth bullet asks for), the nine `…_of_certifies` projections, and `StabFaithful` /
  `BoxLiveFaithful` as the clauses its `stab` and `box` cases read. A READ FIRST block at its
  heading says so.
- **One unverified risk is flagged for Phase 18, with both routes to check named.** `StabFaithful`
  and `BoxLiveFaithful` are stated at **window** times, because that is the only decidable form;
  the truth lemma needs the `stab` clause at an **arbitrary** time. The slab side folds freely, but
  the liveness side needs `{p | Live t p}` to agree with `{p | Live s p}` at the window
  representative, and the landed linchpins give that only at the period multiples
  `-NB - k·NB` and `NM + NF + k·NF`, not at an arbitrary tail time of a different residue. Check
  frame-side normalization (`plusTruthAt_shiftBack` / `timeShift_offset_zero`) first; a
  liveness-periodicity lemma at an arbitrary residue is the expensive fallback and belongs to Phase
  16's machinery. Dispatch 41 attempted neither, so this is a risk and not a measured defect.
- **Phase 21's condition-set record must change**: `BiSerial`, `TailStable`, (C3b)
  `BoxLabelFaithful`, `BoxLiveFaithful`, (C4) `Target`, plus (C5) `StabFaithful` and the three
  remaining target-group clauses — nine conjuncts, and **not** (C3) `BoxFaithful`.
- **Phase 20's `#guard` probe is not available at the present implementation.** Risk row R2b expects
  the satisfiability of `Φ_fwd R₀ ∩ R₀fwd = R₀` at `Fixture.certRep` to be answered by evaluation;
  the 15-minute non-finish above says it cannot be, so that row should expect a hand proof instead.
- **`forall_iff_win_succ` and the four combined-period shifts are reusable.** Any later clause or
  lemma that must fold a predicate reading two consecutive times — or that needs `G.slice` and
  `G.target.datum` moved together by one combined period — can cite them.
- **Phase 19's relative completeness is unaffected in form** and its hypothesis is now weaker
  (dispatch 40's filtered conjunct), so the theorem it will state is stronger.
- A reviser pass is still needed on plan v8's Phase 17 candidate-1 paragraph and on its revision
  record (lines 55-140), which describes four edits made on the candidate-1 premise.

## Follow-ups

### Dispatch 47 (sub-phase 20.1)

- **Sub-phase 20.2 is the next work**, and it owes four things in this order: `TailStable` for the
  embedded certificate in general (both conjuncts — the phase's principal risk, now with favourable
  probe evidence behind it but still unproved); `SlabTrue`'s `□` clause; the identification
  `target.lab t = canLab target.st t`; and the flagship
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`.
- **The route to the two semantic obligations is mapped in the dispatch-47 handoff and should not be
  re-derived.** Two facts make it tractable: every `G.edge`-path of the embedded certificate is
  **constant** in its index (so the frame's histories are the stepHistories of constant paths and
  their shifts, and `□`'s semantics collapses to "true at every index and every time"); and the two
  ℤ-distance inner inductions are already landed, label-level, on the L side. One trap is recorded
  there too: `WitnessFamily.truth_iff_mem` is **not** reusable, because it is stated at the L side's
  own shift-set model on `Fin k × ℤ` rather than at the sliced frame on `ℤ × Fin k`.
- **Phase 21's two acceptance obligations are still outstanding and are not touched here**: the
  `docs/theorem-index.md` row and the C2 `AXIOM_BASELINE` pin for the flagship. Neither can be added
  before the flagship exists.
- **The stale-olean hazard reproduced a fifth time** and the main tree still carries the stale
  `.olean`/`.trace` pairs, so dispatch 48's worktree will inherit them a sixth time. The fix is
  mechanical and is recorded in the handoff; the underlying hardlinked-`.lake` provisioning issue is
  not a task-703 concern and has not been filed as one.
- **Commit `6b8e3d05d` lacks its two attribution trailers** and could not be amended (the
  concurrency guard correctly refused). A human working this branch solo can repair it.

### Dispatch 46 — what Phase 20 should know before it starts

- **Phase 20's PRINCIPAL RISK bullet retains a superseded body beneath a correction block — read the
  block, not the body.** Plan v9 corrected the bullet in place and plan v10 added the
  window-propagation sub-points; an earlier version of this summary and of the phase-19 handoff
  claimed the bullet was uncorrected, which was **wrong**. The cause was a stale read, not a missing
  label: the plan was revised in place between this dispatch's two reads of it, and the Phase 20
  excerpt came from the pre-v9 state. This plan uses the retained-body pattern in several places
  (Phase 17's heading, Phase 18's blocker, R2b, Phase 20's risk bullet). The substance of the
  correction, which the plan already states, is: the superseded body budgets
  the phase's hard work on proving `Φ_fwd R₀ = R₀` for the embedded certificate — candidate 1. The
  user's cycle-5 ruling replaced that conjunct by the **liveness-filtered** transfer
  `Φ_fwd R₀ ∩ R₀fwd = R₀`, and the cycle-3 ruling then made both conjuncts **residue-indexed**. The
  probe that bullet mandates should therefore evaluate `decide G.TailStable` (or the two residue
  families separately, so a failure localizes) on a concrete embedded certificate — **not**
  `Φ_fwd R₀ = R₀`, which is no longer the demand. The STOP-and-ESCALATE fallback and the prohibition
  on weakening `TailStable` or stating `exists_tailStable_repr` are unaffected and still stand.
- **Phase 20 inherits the window finding.** Its embedding chooses the tails and the window from the
  lassos' common periods, and `NBnat`/`NFnat` are least common multiples of the *certificate's* and
  the *target path's* segment lengths. The embedded certificate's target path must be built with
  that in mind, because its periods feed the very window the tail-stability demand is read in.
- **`Complete.lean`'s headline is ready to consume.** Phase 20's embedded certificate, once it meets
  `SlabTrue`, bi-seriality, tail-stability and the two path conditions, does not need its own box
  guess argued: `exists_plusSlicedCertificate_of_tailStable_countermodel` supplies one. Whether that
  is the cheaper route than discharging `BoxLabelFaithful`/`BoxLiveFaithful` by hand on the
  embedding's `bx`-boxes definition is a judgement for that phase; both are available.

- **Phase 19 must be re-read against the narrowed class before `Complete.lean` is written.** Its
  construction currently assumes the `r = 0`-only obligation. This is the first thing dispatch 45
  should do, and the Phase 18 handoff says so at its head.
- **Superseded by dispatch 44**: "Phase 18's blocker is the next decision, not the next dispatch", and
  the whole of its remaining-work list — the demand was changed, `decidableTailStable` re-derived, the
  `r = 0` instances confirmed to discharge every landed theorem, the reference-time-generic
  construction and `exists_win_live_eq` written, and `Sound.lean` landed. The bullet is kept below as
  the record it is.
- **The stale olean/trace hazard reproduced a third time** in the dispatch-44 worktree, exactly as the
  dispatch-41 and -42 handoffs predicted, and **the main tree still carries the stale pairs**. Dispatch
  45's worktree will inherit them a fourth time unless the main tree's
  `.lake/build/{lib/lean,ir}/…/PlusSlicedCertificate/` is cleaned first.
- **`ring` is absent from `Stable.lean`'s import closure.** Worth knowing before a later module in this
  subtree reaches for it.
- **Phase 18's blocker is the next decision, not the next dispatch.** Answer this round's
  `user_decision` (accept the residue-indexed `TailStable`, or re-plan Phase 18). On acceptance the
  remaining work is: change `TailStable`, re-derive `decidableTailStable`, confirm the `r = 0`
  instances still discharge every landed theorem stated from it, write the reference-time-generic
  copy of `tailPos` + its six lemmas and `exists_win_live_eq`, and only then `Sound.lean`.
- **Do not re-derive two dead ends.** `A_r := iterBack (-G.NB) G.L₀ r` satisfies the residue
  stability equation but is not contained in the live set at `-G.NB - r`; and the live set at
  `-G.NB - r` satisfies no equation the landed demand implies. Both are worked out at the Phase 18
  heading.
- **Superseded**: "start with the frame-side normalization check before writing the `stab` case" —
  dispatch 42 ran that check. It closes the `box` case and does not touch `stab`.
- **Reviser**: rewrite plan v8's Phase 17 candidate-1 paragraph to record the option-2 ruling, and
  fold both the dispatch-40 correction block and the dispatch-41 PHASE 17 RECORD into it.
- **A fixpoint that iterates to stability** rather than to the `V.card + 1` cardinality bound is what
  would make the checker run at fixture scale. It is also the only cheap route to the satisfiability
  question dispatch 40 left open. Separate work; not attempted here.
- **The four surviving gate failures** (`C16`, `C23` ×2, `C24`) are this task's, all from Phases
  15-16, and are tabulated with disposal advice at Phase 21's heading.
- **The main tree's stale olean/trace pairs** should be cleared before the next dispatch is
  provisioned from it.
- `iterFwd_R₀` still has no consumer inside the subtree; kept deliberately (dispatch 40's record).

## References

### Dispatch 46

- `specs/703_lplus_compression_and_completeness/plans/05_lplus-sliced-certificate-and-completeness.md`
  — Phase 19 heading, including this dispatch's CLOSURE RECORD and the three enumerated exclusions
- `specs/703_lplus_compression_and_completeness/handoffs/phase-18-handoff-20261001T035749Z.md` — the
  dispatch-44 handoff this dispatch opened from
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` — the phase's output
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Window.lean` lines 95-109 — the
  measurement that contradicts the plan's claim about `TailStable`'s dependencies

- `specs/703_lplus_compression_and_completeness/plans/05_lplus-sliced-certificate-and-completeness.md`
  — the PHASE 17 RECORD and annotated checklist (Phase 17), the READ FIRST block (Phase 18), the
  amended design item 5, the re-measured gate state (Phase 21), and dispatch 40's sub-phase 16.3
  record (Phase 16)
- `specs/703_lplus_compression_and_completeness/.decisions.json` — the option-2 ruling, entry 3
- `specs/703_lplus_compression_and_completeness/summaries/04_lplus-sliced-certificate-and-completeness-summary.md`
  — dispatches 21-38, including 16.2c's refutation
- `specs/703_lplus_compression_and_completeness/handoffs/phase-17-handoff-20261001T004227Z.md`
  — dispatch 40's resume point, consumed by dispatch 41
- `specs/703_lplus_compression_and_completeness/handoffs/phase-18-handoff-20261001T020855Z.md`
  — dispatch 42's resume point, with both gaps, the two dead ends, and the environment hazards
- `specs/703_lplus_compression_and_completeness/handoffs/phase-18-handoff-20261001T035749Z.md`
  — dispatch 44's resume point: the demand change stated so it is not re-litigated, the two
  truth-lemma findings, the mechanical notes, and the Phase 19 re-check obligation
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Tail.lean` (new, dispatch 44),
  `.../Sound.lean` (new, dispatch 44)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Canon.lean` (new, dispatch 42)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` (new),
  `.../Stable.lean`, `.../Bridge.lean`, `.../FixtureStable.lean`, `.../Window.lean`,
  `.../Position.lean`
