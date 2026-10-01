# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [BLOCKED]
- **Started**: 2026-10-01T00:09:00Z (dispatch 40); dispatch 41 began 2026-10-01T00:47:00Z;
  dispatch 42 began 2026-10-01T01:36:00Z
- **Completed**: not complete — **sub-phase 16.3 and Phase 17 are both COMPLETED**; **Phase 18 is
  BLOCKED** on a demand-level gap in `TailStable` (dispatch 42, recorded at the Phase 18 heading),
  with its two prerequisites landed. Phases 19-21 remain NOT STARTED. Dispatch 42 ended
  2026-10-01T02:15:00Z
- **Effort**: ~35 minutes (dispatch 40, sub-phase 16.3) + ~40 minutes (dispatch 41, Phase 17) +
  ~40 minutes (dispatch 42, Phase 18's prerequisites and its blocker)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable`,
  `...PlusSlicedCertificate.Bridge`, `...PlusSlicedCertificate.FixtureStable`,
  `...PlusSlicedCertificate.Window`, `...PlusSlicedCertificate.Position`,
  `...PlusWitnessFamily.Compression.Types` (all landed before these dispatches); no new external
  dependency
- **Artifacts**: plans/05_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Round 5 covers three dispatches. **Dispatch 40** implemented the user's tail-stability ruling:
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
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Canon.lean` (new, dispatch 42)
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` (new),
  `.../Stable.lean`, `.../Bridge.lean`, `.../FixtureStable.lean`, `.../Window.lean`,
  `.../Position.lean`
