# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-30T00:52:00Z (dispatch 21); 2026-09-30T01:20:00Z (dispatch 23);
  2026-09-30T02:05:00Z (dispatch 25); 2026-09-30T10:10:00Z (dispatch 27);
  2026-09-30T10:39:15Z (dispatch 29)
- **Completed**: not complete — Phase 15 is PARTIAL (15.1, 15.2, 15.3 STEPS 1-3 landed; STEPS 4-6
  open), Phase 16 is IN PROGRESS (16.1 complete, 16.2 open) and Phases 17-21 are NOT STARTED.
  Last dispatch ended 2026-09-30T11:14:00Z
- **Effort**: ~30 minutes (dispatch 21, Phase 9) + ~70 minutes (dispatch 23, Phases 10-13)
  + ~125 minutes (dispatch 25, Phase 14 and Phase 15.1) + ~30 minutes (dispatch 27, Phase 15.2)
  + ~35 minutes (dispatch 29, Phase 16.1 and Phase 15.3 STEPS 1-3)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.SharingSkeleton`,
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` (both landed).
  `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is NOT consumed by Stage 1 — see
  Verification.
- **Artifacts**: plans/04_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Stage 1 of the plan is complete and Stage 2 is open.** Five of twenty-one phases are closed —
Phase 9 by dispatch 21, and Phases 10, 11, 12 and 13 by dispatch 23. **The L⁺ compression statement
is now refuted, as a theorem of the tree.** Phase 11 is the load-bearing one: `not_plusCertifies_pumpTarget` proves that
**no** `PlusSharingWitnessFamily` certifies `pumpTarget p`, at any time, for any lasso count, any
segment length, any period and under no hypothesis whatsoever on the succession relation. What
was previously a withdrawal recorded in a report is now a theorem with a counterexample formula,
and the tree's own documentation has been corrected to stop overstating the class's coverage.

Soundness was never in question and is not now. `PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` are byte-identical in statement, and both still print exactly
`[propext, Classical.choice, Quot.sound]` after every change here.

Stage 2 — the time-sliced certificate — is **opened**, not finished. Phase 13 lands its three
types, its readout and its bi-seriality condition, with the plan's pinned field lists confirmed by
writing two of the checker's four clause groups against them rather than by asserting they will do.

**Dispatch 25 closes Phase 14 and the first half of Phase 15.** Phase 14 is where the plan v4
amendment is cashed out: `FrameOver.ofSlicedStep` synthesizes a `FrameOver intOrder` on the carrier
`ℤ × W` — **infinite, with finite fibres** — and `frame_worldState_not_finite` *proves* the carrier
is not finite rather than asserting it in a comment. `FormalSystem/Semantics/IntNormalForm.lean` is
untouched: `git diff` shows no hunk, so the Scope Hypothesis's relocation branch was not taken.
Phase 15.1 lands the finite position space over one slice, the one-step position graph, and the **Q5
factorization** — `stab_factors`, the named declaration that is the justification for
`live = fwdLive ∩ bwdLive`, assembled from the plan's three pieces in the plan's own order.

**One plan obligation was found FALSE and is replaced rather than absorbed.** Phase 15's task list
asks for `succP`/`predP` to be non-empty on the whole position space. A counterexample is recorded
in `Position.lean`'s module header. Positions without successors are not a defect — they are exactly
what the *greatest* fixpoint `fwdLive` exists to discard — and what the fixpoints genuinely need is
`mem_succP_of_path`, which is proved. **A second finding is that the Phase 15 / Phase 16 boundary may
be in the wrong place**, because `fwdLive t` at an arbitrary `t : ℤ` is a ℤ-indexed family rather
than one `Finset`; the full argument and two candidate resolutions are recorded under the plan's
Phase 15 heading for the next dispatch to decide before writing a definition.

Phases 15.2 and 16-21 remain. Nothing anywhere is stubbed: no `sorry`, no vacuous placeholder, no
half-written declaration. The missing halves simply do not exist yet.

### Dispatch 29 — the window width is settled, and settled by proof

Two blockers are closed. **Sub-phase 16.1 is complete**: the window-width fixture is built and its
asymmetry lemmas are proved, so the claim that identical slices can carry different liveness is now a
theorem about a named certificate rather than an expectation — and it decides the width the checker's
wrap may use. **Sub-phase 15.3's window is fixed**, taking plan v6 addendum (d)'s response (α): the
periods are combined by least common multiple with the target path's, so the checker can fold the
slice sequence and the target path *together*, which no landed lemma could do. The rolled timed
carrier and the wrapping time successors follow, with four faithfulness lemmas proving the fold
preserves both objects' data.

Nothing was weakened to get there. The plan's four-state fixture turned out not to be realizable in
this carrier, and the response was to rebuild the fixture, keeping the obligation intact. No
`sorry`, no vacuous placeholder, no new axiom, and no bound on `n`, on a period or on a lasso count.

## What Changed

### Phase 16.1 and Phase 15.3 STEPS 1-3 (dispatch 29, on branch `orchestrate/task-703-29`)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixture.lean` — **created**, ~700
  lines: `Fixture.cert`, a bi-serial two-state certificate of back period `1`, with `biSerial`,
  `slice_of_neg`, `posAt_eq_of_neg`, the one-step asymmetry (`succP_ne_empty_neg_one`,
  `succP_eq_empty_of_le_neg_two`), the fulfilling `run`, the liveness asymmetry (`live_neg_one`,
  `not_exists_labRun_of_le_neg_two`, `not_live_of_le_neg_two`), and the two headline theorems
  `live_not_determined_by_slice` and `window_verdict`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` — **created**, ~290 lines:
  `stepBack` / `stepFwd`, `iterBack` / `iterFwd`, `Φ_back` / `Φ_fwd`, monotonicity at all three
  levels, the two endpoint-placement lemmas, and the soundness pair `fwdLive_subset_stepBack` /
  `bwdLive_subset_stepFwd`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Window.lean` — **created**, ~290 lines:
  the **combined** window `NB` / `NF` / `NM`, the six compatibility facts, `winLo` / `winHi` /
  `winTimes` with the generic inequalities, `exists_combined_window_eq`, `exists_win_eq`, and
  **`forall_iff_win`** — the pair fold Phase 17's existential side needs.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` — **created**, ~330 lines:
  `TPos` and `verts` (with `Fintype` on the subtype and `DecidableEq TPos` confirmed by `example`),
  `slab_congr` / `posAt_congr`, `nextTime` / `prevTime` with `nextTime_edge` / `prevTime_edge` and
  `nextTime_mem` / `prevTime_mem`, the four faithfulness lemmas (`slice_nextTime`, `slice_prevTime`,
  `target_datum_nextTime`, `target_datum_prevTime`), `posAt_nextTime` / `posAt_prevTime`, and
  `slice_nextTime_pred` / `slice_prevTime_succ`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — four import lines and four
  submodule entries added; the missing `Live` entry was added at the same time.
- `FormalSystem.lean`, `typst/generated/status.typ` — regenerated.

### Phase 9 (dispatch 21, already landed on `main` as `9355b68fe`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` — **created**, 456
  lines: the five tense/stability abbreviations (`Xp`, `X¬p`, `Fp`, `⟐Xp`, `⟐X¬p`), the two limit
  targets `hopTarget` = `□⟐Xp → (□⟐X¬p → ⊥)` and `pumpTarget` = `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`,
  the two shared antecedents on the permissive frame, both ℤ-time non-validity theorems, and the
  13-step and 17-step closure-membership chains with the `untl`-shape characterizations. All
  parametric in `(p : Atom)`.

### Phase 10 (this dispatch, commit `09ab45be9`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean` — **created**, ~320
  lines:
  - `hopFree_branchesTrue`, `hopFree_branchesFalse` — every position of *any* certifying family has
    a share-class member branching to `p` and one branching to `¬p`. No hop-freedom hypothesis:
    these are facts about the whole class, derived from (C4), (C1')'s `imp` clause, (C3), (C5) and
    the reflexive instance of (C1')'s `untl` clause.
  - `hopFree_deviates` — (C0) then forces, at every time, a successor state of the main index's
    state **distinct from its own**.
  - `not_plusCertifies_hopTarget_of_hopFree` — the counting step, and the only place hop-freedom is
    spent: `lift` tracks each deviation by a succession path, hop-freedom makes that path constant,
    so `lassos.length + 1` deviation times need `lassos.length + 1` pairwise-distinct indices in a
    type of cardinality `lassos.length`.
  - `not_exists_hopFree_plusCertifies_hopTarget` — the existential form the plan's Lean Challenge
    Statement pins.
  - A "What this does **not** say" docstring section: hop-freedom is incomplete; `TransId.lean`'s
    four collapse theorems remain true and remain in the tree; the theorem bounds a *strategy*, not
    the substrate; and `hopTarget p` is refutable, just not this way.

### Phase 11 (this dispatch, commit `726b6d99f`)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` — **created**,
  ~445 lines:
  - `seqPostpone` — the long-postponement branching sequence, stated over abstract successor
    functions so it carries no family
  - `not_plusCertifies_pumpTarget` — **the class-level incompleteness.** Start on the main index at
    time `S.NM` (inside the forward-periodic region), follow `¬p`-successors for
    `k := S.lassos.length * S.perFwd + 1` steps, then take one `p`-successor; `lift` tracks it;
    (C0) transports the atom facts onto the tracking path; `⊤ ∈` every label propagates `Fp`
    backwards along it; pigeonhole over the `n + 1` times spaced by `S.NF` gives `v < v'` with the
    same index; `transRaw_congr_NF` and `data_congr_fwd` make the folded path a genuine `S.Thread`
    with the same labels; that thread carries `Fp` at `v` and never reads `p`, contradicting (C2').
  - `not_exists_plusCertifies_pumpTarget`, `plusCompression_fails_at_pumpTarget`
  - A "scope of the failure" docstring section stating, at its true generality, that the root cause
    is limit closure against a finite, eventually periodic, all-threads-fulfilling structure, and
    that **no bound repairs it**.

### Phase 13 (this dispatch, commit `5908fc924`) — Stage 2 opens

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Basic.lean` — **created**, 604 lines:
  - `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate` with exactly the fields the plan's second
    Lean Challenge Statement block pins. **No `lift`, `trans`, `witness`, `stepR` or `stateLab`
    field** — each absence is a decision the module docstring names and justifies, and a grep for
    those five as field names over all three structures returns 0.
  - `PlusGraphPath.datum`/`.lab`/`.st`, `.datum_mem`, `.lab_sub`, `.n_pos`, three decoding-region
    lemmas, four periodicity lemmas
  - `PlusSlicedCertificate.slice`/`.edge`/`.slab`/`.slab_sub`, three decoding-region lemmas,
    `slice_periodic_back`/`_fwd`, and `exists_window_eq` — proved by **residue**, not by induction
  - `PlusSlice.BiSerialAt`, `.BiSerial`, `.BiSerialWindow`, and `biSerial_iff_window` in **both**
    directions (`←` is what the checker needs, `→` what the frame construction needs)
  - `BoxFaithful` (C3) and `Target` (C4) — two of the checker's four clause groups, written here
    against the declared fields because that, and not an assertion, is what discharges this phase's
    Scope Hypothesis; plus `forall_slab_iff_window`, showing the box clause's `∀ t` quantifier costs
    the checker nothing. Phase 17 consumes these rather than restating them.
  - `onePointCertificate` and `slice_onePointCertificate` — the finite-graph special case, exhibited
    **and proved** to have a constant slice sequence. "Nothing was lost by slicing" is a theorem
    here, not a claim.
  - Two lemmas the `Formula`-side readout layer does not state, because that side never needs a
    decoded datum's *membership*: `getD_mem_of_lt` and `cyc_mem`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — **created**, the aggregator,
  with a header stating why this subtree exists beside `PlusWitnessFamily/` (which is sound and
  stays) and which of `Limits/`'s two failures each design choice answers.
- `FormalSystem/Metalogic/Decidability.lean` — one added import.

### Phase 12 (this dispatch — the record corrections and the gate pins)

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — a new `### Non-empty is not
  complete` subsection under the "the certificate class was empty, and is not any more" heading.
  The heading's claim stays (it is true); what is added is that non-empty is not complete, by
  `not_exists_plusCertifies_pumpTarget`, and that **which fragment the class does cover is an open
  question**. Plus the two `## Submodules` bullets for the new modules.
- `…/PlusWitnessFamily/Incompleteness.lean` — the header sentence "It no longer records an
  obstruction, because there is no longer one to record" corrected: it no longer records *the*
  obstruction it once recorded (the `share`-congruence collapse), but there **is** one to record, at
  a different target and for a different reason, and it is named and pointed at.
- `…/PlusWitnessFamily/README.md` — "What failed, and is now repaired, was completeness of the
  certificate class" qualified to "**on these two targets**", with completeness in general recorded
  as refuted rather than repaired.
- `…/PlusWitnessFamily/TransId.lean` — a new `## There is no compression, and hop-freedom is
  incomplete` section; "the compression's choice" softened to "the intended producer's choice"; and
  an explicit statement that the four collapse theorems remain true, remain proved, and are kept.
- `…/WitnessFamily/Sharing/README.md` — the "empty certificate class that bounds what it can
  refute" cross-reference corrected. Per Phase 12's conditional instruction, this **was** a
  coverage claim about the live L⁺ class rather than a note on pre-redesign history, so it was
  corrected and the reasoning is recorded inline.
- `…/PlusWitnessFamily/Compression/Extract.lean` — a new `## The alignment half is retained and
  unused` section: everything from `plusAlignOffset` (line 147) through
  `exists_plusLabelledLasso_of_history_aligned` (line 770) has no consumer and is expected to have
  none, why it is kept rather than deleted, and that **C17's dead-declaration census is expected to
  report it**. C17 is reporting-only, so this is documentation of an intended state, not a waiver.
- `docs/theorem-index.md` — **four** rows added after the `not_untl_shift_share_congr` anchor, for
  `not_plusValidZTime_hopTarget`, `not_exists_hopFree_plusCertifies_hopTarget`,
  `not_plusValidZTime_pumpTarget` and `not_exists_plusCertifies_pumpTarget`. Paper label `—`; frame
  class `ZTime` for the two non-validities and `—` for the two incompleteness theorems; axioms
  `pcq pinned:C2`.
- `scripts/check-module-invariants.sh` — the same four names added to the `AX_SRC` heredoc and to
  the `AXIOM_BASELINE` heredoc **in the same relative order** (C2 is a whole-string equality), and
  the C2 pass message's number word moved from `eighteen` to `twenty-two`.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `Boneyard/README.md` —
  generated inventory blocks regenerated by `check-module-invariants.sh --emit-inventory` for the
  two added modules.
- `FormalSystem.lean` — regenerated twice by `lake exe mk_all --lib FormalSystem`, never
  hand-edited (invariant C33).
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix` for the file and
  line-count drift each commit causes; the repository's pre-commit gate requires it.

### Phase 14 (dispatch 25, on branch `orchestrate/task-703-25`)

- `FormalSystem/Semantics/SlicedFrame.lean` — **created** (14.1, commit `d02fad200`). The
  time-indexed iterate `iterS` with `iterS_add` carrying the slice index; the two-sided
  `ofSlicedStepRel`, whose **first conjunct pins the target's time component** (`q.1 = p.1 + d`) and
  is the single fact that buys finite fibres over an infinite carrier; the five frame laws as
  **named** lemmas (`ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial`,
  `ofSlicedStep_limit`, `ofSlicedStep_saturation`, with `ofSlicedStep_fib_finite` beneath the last);
  `FrameOver.ofSlicedStep` and its `IsRegular` instance; `ofSlicedStep_not_finite_worldState`, proved
  through an `Infinite` instance; and `ofSlicedStep_mem_HF_iff`, the history space as exactly the
  **offset** step paths (`IsSlicedStepPath`), a proved biconditional.
- `FormalSystem/Semantics.lean` — one added import line.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Frame.lean` — **created** (14.2, commit
  `24690da51`). `G.stepRel` (the decoded edge relation, named rather than inlined) with its two
  seriality lemmas; `G.frame h`; `instNeZeroN`, `instIsRegular` and `instIsRegularTask`;
  `frame_worldState_eq`, `frame_worldState_not_finite`, `frame_step`; `G.model h` with
  `model_valuation`; `mem_HF_iff_slicedPath` (both directions); `pathHistory` with
  `pathHistory_path`; and the shift-normalization pair `plusTruthAt_shiftBack` /
  `timeShift_offset_zero`.

### Phase 15.1 (dispatch 25)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Splice.lean` — **created** (commit
  `1f0140244`). The **Q5 factorization**, frame-generic: `forall_forall_or_iff`,
  `histories_through_paste` (citing `paste` / `paste_agreeUpTo` / `paste_agreeFrom`, not re-proving
  them), `truth_of_agree_of_type_eq` with its `paste` instance `label_splices_of_type_eq`, the three
  closure-closure helpers, and `stab_factors` with its `⊡`-shaped reading `not_stab_factors`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Position.lean` — **created** (commit
  `1f0140244`). `Lab`, `Pos`, `pos_lab_sub`, `card_Pos`; `IsStateShape`, `AgreesOnState`,
  `impClauseAt`, `LabCoherent`, `posAt`, `mem_posAt`, all with `Decidable` instances that synthesize;
  `untlClauseAt`, `snceClauseAt`, `StepClause`, `succP`, `predP`, `mem_succP`, `mem_predP`,
  `mem_succP_iff_mem_predP`; and `posOf` / `mem_posAt_of_path` / `mem_succP_of_path` /
  `mem_predP_of_path`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — three added imports and four
  added Submodules entries.
- `FormalSystem/Semantics/README.md` — the hand-maintained inventory row for `SlicedFrame.lean`
  (commit `3dc438278`); `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `README.md`
  regenerated by `check-module-invariants.sh --emit-inventory`.

### Phase 15.2 (dispatch 27)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean` — **new file, 529 lines.**
  The declarative liveness layer: `PlusFwdFulfilling` / `PlusBwdFulfilling` (the two halves of
  `PlusFulfillingSeqLab`, with `plusFulfillingSeqLab_iff_halves`); `untl_push` / `snce_push` (an
  undischarged eventuality propagates across a splice time — the phase's actual content) and their
  half-line forms `plusFwdFulfilling_of_ge` / `plusBwdFulfilling_of_le`; `PlusSlicedCertificate.LabRun`
  (a bi-infinite labelled run) with `pos`, `pos_eq_iff`, `pos_mem_posAt`, `pos_mem_succP`,
  `pos_mem_predP`; `FwdLive` / `BwdLive` / `Live` with `mem_posAt_of_fwdLive`, `mem_posAt_of_live`,
  `fwdLive_step`, `bwdLive_step`; the label-level splice `spliceSt` / `spliceLab` / `splice` with
  `splice_pos`, `splice_fwdFulfilling`, `splice_bwdFulfilling`; and the two characterization
  directions `live_of_path`, `exists_path_of_live`, packaged as `live_iff`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one added import line.
- `FormalSystem.lean` — one added import line.

**Both directions of the liveness characterization are named declarations at `∀ t : ℤ`**, which is
the plan's own verification criterion for Phase 15 and is what Phases 18 and 19 cite. No window
restriction was taken, deliberately: see the Decisions entry below.


## Decisions

- **(dispatch 29) The fixture was redesigned and the theorem was not.** `Fixture.fourState` as the
  plan words it is not realizable in this carrier, for three independent reasons: slice width is
  uniform and `edge` is per slice, so the plan's `a → c` edges would hold at every negative time;
  "`q` true at `b` only" in the back slice would let a run at `-2` discharge the eventuality at
  `-1`, destroying the very asymmetry the fixture exists for; and `XX` is not in L⁺ while `⊡`-truth
  is a universal over histories of an infinite carrier and so not `Decidable`, which makes the
  `#eval` / `#guard` half of the task impossible rather than merely awkward. The obligation — a
  proved instance of "identical slices, different liveness" — is discharged, on a **temporal**
  mechanism (distance to the non-periodic window) rather than a branching one. Two states are kept
  rather than one so the failure at `-2` is visibly not a lack of successors: the edge relation is
  total at every slice.
- **(dispatch 29) Addendum (d) response (α) is taken: the window is combined by least common
  multiple.** (β) — the three compatibility facts as `Certifies` hypotheses — was not taken and is
  not held in reserve, because (α) turned out to need no new field and no new hypothesis at all:
  every compatibility fact is a theorem about the certificate's own data. That is strictly cheaper
  here than the `Formula` side's field-carrying `SharingWindow`.
- **(dispatch 29) `verts` filters by `posAt`, unlike `SharingWitnessFamily.verts`.** There the first
  coordinate is a lasso index, legitimate at every time; here it is a (state, label) pair and `posAt`
  is exactly the legitimacy predicate. Starting a greatest-fixpoint iteration from a set containing
  pairs that are not positions of their own slice would make the fixpoint's statement harder.
- **The three forced-successor facts are named lemmas in `HopFree.lean` and re-derived, not
  imported, in `NoCertificate.lean`.** This is not duplication by oversight: `plusClosureOf` is
  indexed by the context, so `hopClosure p` and `pumpClosure p` are distinct `Finset PlusFormula`
  values and no membership fact transports between them without a monotonicity principle neither
  limit theorem needs. The plan's Phase 11 task list says so explicitly.
- **`not_exists_hopFree_plusCertifies_hopTarget` was given the plan's pinned existential shape, and
  the universally-quantified workhorse was renamed.** The first version of Phase 10 stated the
  theorem as `(S) (t) (hid) : ¬ S.PlusCertifies t`, which is logically equivalent to the plan's
  `¬ ∃ S t, hid ∧ PlusCertifies` but is **not the same statement**. Since the Lean Challenge
  Statement block pins the flagship shapes and the plan's own risk register exists to stop exactly
  this kind of silent drift, the pinned shape was added under the pinned name and the workhorse
  became `not_plusCertifies_hopTarget_of_hopFree`. The theorem-index row and the C2 baseline cite
  the pinned name.
- **The two limit theorems are parametric in `(p : Atom)`.** Strictly stronger than the Challenge
  block's atom-free shape, and available because `natModel`'s valuation is atom-agnostic.
- **Hop-freedom's incompleteness is recorded as bounding a strategy, not the substrate.** Deleting
  `TransId.lean`'s four collapse theorems was considered and rejected: they are true statements
  about what hop-freedom buys a producer that already has per-lasso data, and the fact that no
  general producer can feed them does not touch them. Their header now says this.
- **The retained-and-unused alignment half of `Compression/Extract.lean` is kept, not deleted.** It
  is correct, non-trivial, and its `two_mul_plusAlignOffset_le` arithmetic is cheaper to keep than
  to re-derive; and deleting it would erase the record of what the withdrawn route required.
- **`NeZero G.n` is a global instance, not a `haveI` inside `G.frame`.** A `haveI` bakes one
  particular `Nonempty (Fin G.n)` term into the frame, and every later lemma about the frame would
  then have to reproduce that same term to unify. As an instance, `Nonempty` and `Finite (Fin G.n)`
  are found by synthesis, so `G.frame h` is a bare `FrameOver.ofSlicedStep` application whose
  instance arguments reproduce at every call site.
- **The edge relation is the named `G.stepRel`, not an inline lambda.** Five declarations
  (`stepRel_fwd`, `stepRel_bwd`, `frame_step`, `mem_HF_iff_slicedPath`, `pathHistory`) cite one
  relation instead of five copies of a lambda that would have to unify syntactically.
- **The carrier's infinitude is proved generically, not on a concrete two-slice certificate.** The
  plan's verification offered either an `example` on a concrete `G` or an `Infinite` instance; the
  generic theorems `ofSlicedStep_not_finite_worldState` and `frame_worldState_not_finite` are
  strictly stronger than the `example` and cover every certificate, so the `example` was not written.
- **`stab_factors` is stated over abstract `Bwd`/`Fwd` predicates with explicit locality
  hypotheses**, rather than hard-wiring `snce`-past-fulfilment and `untl`-future-fulfilment. The two
  hypotheses are exactly what `label_splices_of_type_eq` delivers, so the factorization applies to
  any backward/forward condition expressible in the `C`-labels — including whatever Phase 16's
  transfer operators turn out to need.
- **`LabCoherent` and `StepClause` are separated by arity, not by convenience.** The clauses internal
  to one label (`⊥`-absence, the implication clause) gate `posAt`; the clauses relating two
  consecutive labels (the `untl` clause forwards, the `snce` clause backwards) gate the edge. The
  `□`-clause and the fulfilment clauses are in neither: the first is global and the second is what
  liveness computes.
- **15.1 landed in `Splice.lean` and `Position.lean`, not in `Live.lean`.** A `Live.lean` containing
  no `live` would mislead a reader about what is proved. `Live.lean` is left for 15.2, which is what
  defines `live`.

- **The Phase 15/16 ordering question was dissolved by a carrier change, and the split was taken at
  the Prop/compute seam.** The question the previous dispatch left open ("is `fwdLive` defined on the
  window only, or do Phase 16's transfer operators come first?") had a false presupposition: that
  eventual periodicity is what makes the liveness fixpoint finite. It is not — `AUFix` terminates by
  the cardinality of an explicit `V : Finset α` and asks for no `Fintype` on the carrier. What is
  actually wrong is that `Pos` factors time **out**, so the fixpoint would live in `(Finset Pos)^ℤ`.
  The `Formula` side does the opposite in the very module Phase 15 imports `AUFix` from
  (`SharingWitnessFamily.Pos = Fin S.lassos.length × ℤ`, finiteness on `verts := univ ×ˢ winTimes`,
  wrapping `nextTime` / `prevTime`), and its own docstring says the choice is load-bearing. 15.2
  therefore lands the declarative object with both characterization directions at `∀ t`, and 15.3
  transcribes the rolled carrier for the computation. The alternative seam — route (ii)'s
  window-only statements — was rejected because Phases 18 and 19 need the `∀ t` forms and would each
  have had to re-extend a lemma the plan promised them whole.
- **Eventual periodicity survives, with a sharper job: wrap SOUNDNESS, not termination.**
  `exists_window_eq` gives a genuine slice *equality*, but identical local graphs do not imply
  identical liveness: an eventuality may only be dischargeable by reaching the non-periodic window,
  and the distance to it differs between two same-residue times. The landed window is
  **single**-period `[-nb, nm + nf)`; the `Formula` side's is **doubled** on both sides. Phase 16's
  four-state fixture is exactly that phenomenon (`⊡(XX ¬q)` differing at `(-1, a)` and `(-2, a)` at
  back period 1), so the fixture was promoted to a **prerequisite of 15.3** and 15.3 was not started
  in this dispatch. Fixing a window width before the fixture confirms it is precisely the
  improvisation the research's anti-goals forbid.
- **`live = fwdLive ∩ bwdLive` is now justified twice, at two levels, and neither justification
  derives the other.** `stab_factors` (15.1, `Splice.lean`) splits the existential over
  `WorldHistory`; `live_iff` (15.2, `Live.lean`) splits the same existential over label sequences.
  The semantic half is what Phases 18 and 19 read the `⊡`-clause through; the syntactic half is what
  the liveness computation is about. A reader could reasonably expect one to be a corollary of the
  other, so the plan now states that it is not.
- **Non-emptiness of `LabRun` is Phase 19's obligation and is flagged, not assumed.** Nothing in 15.2
  exhibits a run. If a certificate admitted none, every position would be non-live and the checker's
  `⊡`-clause would be trivially satisfied. `live_iff`'s `→` direction is what makes that visible
  rather than silent; Phase 19 must exhibit runs from `G.BiSerial` plus type completion.

## Plan Deviations

- **Phase 16.1, altered (the fixture)**: `Fixture.fourState` redesigned as `Fixture.cert`; the
  `#eval` / `#guard` half dropped as impossible. See Decisions and the plan's 16.1 record.
- **Phase 16, altered (files)**: the phase's single `Stable.lean` landed as **two** modules —
  `Fixture.lean` for the fixture and `Stable.lean` for the Φ operators — and `Stable.lean` was
  written without `TailStable`, which needs 15.3's computed liveness set and is 16.2's business.
- **Phase 16.1, added**: `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd`, a soundness pair the
  plan does not name. They settle that Φ over-approximates and that the converse is false, which is
  *why* 16.2's `TailStable` must be an equation rather than an inclusion.
- **Phase 15.3, altered (`verts`)**: filtered by `posAt`; see Decisions.
- **Phase 15.3, altered (file placement)**: `slab_congr` and `posAt_congr` belong with
  `Position.lean`'s development and were landed in `Timed.lean` instead, so that no already-landed
  module had to be reopened.
- **Phase 16.2 and Phase 15.3 STEPS 4-6, deferred**: not started, nothing stubbed.
- **Phase 10, altered**: the three forced-successor steps were factored into named lemmas rather
  than left inline, because each is a fact about an arbitrary family and Phase 11 asks for the same
  three facts.
- **Phase 10, altered**: the probe's `Int.induction_on` route to "a hop-free succession path is
  constant" did not elaborate in this module's import closure. Replaced with an `ℕ`-shift lemma
  plus `omega`.
- **Phase 10, altered (statement shape)**: see Decisions — the pinned existential form was added
  and the workhorse renamed, after the first version drifted from the Challenge block.
- **Phase 11, altered**: three explicit Mathlib imports added (`Mathlib.Data.Fintype.Pigeonhole`,
  `Mathlib.Tactic.Ring`, `Mathlib.Tactic.WLOG`), which the plan's file list did not anticipate
  because the probe it transcribes does `import FormalSystem`.
- **Phase 11, Scope Hypothesis resolved, not split**: the module is ~445 lines and fit one run. No
  decomposition into 11.1/11.2 was needed and none was made.
- **Phase 12, Scope Hypothesis confirmed**: the gate edits were exactly the asserted ten
  line-groups, and `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc moved from
  **18 to 22**, as predicted.
- **Phase 12, added work not in the plan**: the `INV` invariant (generated inventory blocks in four
  `README.md` files) went stale because two modules were added. Fixed in this phase by
  `check-module-invariants.sh --emit-inventory`, per the phase's own instruction to fix rather than
  defer anything the new subtree newly breaks.
- **Phase 12, excluded**: invariant **B0** does not pass. See Verification.
- **Phase 13, Scope Hypothesis confirmed, both halves**: the field lists are sufficient (confirmed
  by *writing* `BiSerial`, `BoxFaithful` and `Target` against them — no field was found missing or
  wrong, so no correction to the Challenge block was needed), and the generic readout lemmas
  instantiate at `PlusSlice n C` with no change (confirmed by reading their binders: all six are
  over `{α : Type*} [Inhabited α]`).
- **Phase 13, altered**: `Inhabited (PlusSlice n C)` needs no `n_pos` — the inert slice is definable
  at `n = 0`, so the hypothesis is not threaded. `Inhabited (Finset PlusFormula × Fin n)` is
  supplied from `back_ne` (the path's own `back.head`) rather than from a positivity field, which
  makes the default automatically a *member* of the path's data; `PlusGraphPath.n_pos` is recovered
  as a theorem.
- **Phase 13, altered**: `BiSerial` is the `∀ t` form and `BiSerialWindow` the window-decided one,
  not the other way round as the plan's wording has it — `G.frame (h : G.BiSerial)` reads the
  condition at an arbitrary time, so the `∀ t` form has to be the one the Challenge signature names.
  Both exist and `biSerial_iff_window` proves them equivalent, so nothing is lost.
- **Phase 13, altered**: `exists_window_eq` is proved by residue rather than by the double induction
  the plan's "extended to all `t` by the two periodicity lemmas" suggests. Stating bi-seriality *at
  one slice* is what makes that possible. Both periodicity lemmas are still proved and exported.
- **Phase 14, altered (three ways)**: split into 14.1 and 14.2 as its own Contingency directs and
  committed separately; `Nonempty (Fin G.n)` supplied through a `NeZero` instance rather than a
  `haveI` in `frame`'s body; shift-normalization landed as **two** lemmas
  (`plusTruthAt_shiftBack`, `timeShift_offset_zero`) rather than one, because one cannot carry both
  a fact about truth and a fact about the path.
- **Phase 14, Scope Hypothesis CONFIRMED both halves.** `ofSlicedStep` needs no private definition
  of `IntNormalForm.lean` (`iterS` is new work, not a reuse of `iter`), so the relocation branch was
  not taken and no landed core file is edited; and the *Limit* and *Saturation* discharges are one
  `TaskFrame` lemma each, with the finite-fibre fact written as its own named lemma per that
  hypothesis's own instruction.
- **Phase 15, altered — `G.Pos` carries no `χ` parameter.** The relevant formula set is already
  determined by the certificate's indices (`plusClosureOf (Γ ++ Del)`), which is what `slab`,
  `lab_sub`, `BoxFaithful` and `PlusLocalCoherentSeqLab` are all stated against; a separate `χ` would
  be a second, redundant set that every lemma would then have to relate to the first.
- **Phase 15, altered — `forall_forall_or_iff` needs no inhabited index type.** The plan says
  non-emptiness "is supplied by `G.BiSerial`"; it is not needed at all, since an empty index type
  makes the corresponding universal vacuously true on both sides. The lemma is stated over bare
  `Sort*` and `G.BiSerial` is not consumed by it.
- **Phase 15, altered — `not_stab_factors` added** beside `stab_factors`, because the `⊡`-shaped
  reading is the form a `⊡χ`-clause is actually read through and it is one `not_and_or` away.
- **Phase 15, SKIPPED as false — `succP`/`predP` totality on the position space.** The plan's task
  reads "Prove `succP` and `predP` are non-empty on the position space, from `G.BiSerial` and the
  type-completion argument. Without this the fixpoints are vacuous." The claim does not hold:
  with `untl g e` in the closure, `g` and `e` both atoms, and a certificate whose slice labelling
  carries no atom, `X = {untl g e}` is a legitimate member of `G.posAt t` with **no** successor,
  because every successor label must also carry no atom and the `untl` clause then demands
  `untl g e ∉ X`. The parenthetical worry is mistaken too: successor-less positions are exactly what
  the *greatest* fixpoint discards. Replaced by `mem_succP_of_path` / `mem_predP_of_path`, both
  proved. A machine-checked `#eval` witness for the counterexample is **not** landed and is flagged
  rather than concealed.
- **Phase 15, PARTIAL — 15.2 not started.** `fwdLive`, `bwdLive`, `live`, the fixpoint properties,
  `mem_live_of_path` and `exists_path_of_mem_live` do not exist. Nothing is stubbed for them.
- **Phases 16-21, not started.**

- **Phase 15.2, altered — the greatest-fixpoint `Finset` is NOT in 15.2, and the reason is a
  root-caused defect in the carrier rather than a scheduling choice.** `Position.lean`'s
  `Pos := Fin G.n × Lab Γ Del` factors time out of the carrier, so a greatest fixpoint of the
  slice-indexed liveness condition lives in `(Finset Pos)^ℤ`, a lattice of infinite height; the
  finite-lattice termination argument is not merely unavailable there but false as a *uniform*
  claim, because bad news propagates one slice per iteration and no single iteration count works
  for every `t`. 15.2 landed the declarative `FwdLive` / `BwdLive` / `Live` with both
  characterization directions instead; the computation moves to sub-phase 15.3 on a rolled timed
  carrier. Recorded in full under the plan's Phase 15 heading as the **RESOLUTION OF THE 15.2
  ORDERING QUESTION**.
- **Phase 15.2, altered — the plan's own two candidate routes were SUPERSEDED, not chosen
  between.** Route (i) (move Phase 16's transfer operators earlier) is unnecessary: termination never
  needed eventual periodicity, since `AUFix` takes an explicit `V : Finset α` and terminates by
  `V.card`. Route (ii) (define `fwdLive` on the window only) has the right statement shape but keeps
  `fwdLive` a `t`-indexed object and so keeps the disease. The seam actually taken is neither: it
  cuts along **Prop vs. compute**, leaving both characterization lemmas in the `∀ t` form Phases 18
  and 19 need — which route (ii) would have forced those phases to re-establish.
- **Phase 15.2, altered — `mem_live_of_path` landed as `live_of_path` and `exists_path_of_mem_live`
  as `exists_path_of_live`.** `Live` is a `Prop`, so there is no `∈` for the names to describe.
- **Phase 15.2, altered — `exists_path_of_live` is factored through the LABEL-level splice, not
  through `stab_factors`.** Two runs agreeing at `t` splice by a literal `if s ≤ t`; `PlusPasting` is
  needed only once the claim is transported to histories, which is Phase 18/19's business.
  `stab_factors` (15.1) remains the semantic counterpart. Neither derives the other, and the plan now
  says so at the Phase 15 heading.
- **Phase 15.2, altered — `BwdLive` was WRITTEN, not DERIVED by time reflection.** The plan asks for
  the `PlusFormula.reflectTime` route "if the reflection is cheap; if it is not, write both and
  record that it was written rather than derived". At the declarative level it is not cheap — a
  reflection would have to act on `LabRun`'s five fields and on `PlusLocalCoherentSeqLab`'s clause
  order — so the whole backward chain (`snce_push`, `plusBwdFulfilling_of_le`,
  `splice_bwdFulfilling`, `bwdLive_step`) is the mirror of the forward chain, written out. Whether
  15.3's *computed* backward fixpoint can be derived by reflection is reopened there, where the
  objects are `Finset`s and a reflection is a concrete map.
- **Phase 15.2, altered — "computed rather than demanded" became the weaker and true claim.**
  `Live.lean`'s header records why liveness is a property of the certificate's own runs rather than a
  demanded field, naming `not_exists_plusCertifies_pumpTarget`. It does not claim liveness is
  computed; that is 15.3's word.
- **Phase 15 remains PARTIAL.** 15.1 and 15.2 are landed; **15.3 is not started and nothing is
  stubbed.** 15.3's first step depends on Phase 16's four-state fixture (see Decisions), so this is a
  genuine reorder rather than a deferral.
- **Phase 16, AMENDED at its heading, not executed.** The job of `Φ_back`, `Φ_fwd`, `TailStable`,
  `tailStable_iff_window` and `exists_tailStable_repr` was reframed: they are no longer what makes
  the liveness computation finite, they are what certifies the **wrap is faithful**. Statements
  unchanged. The four-state fixture was promoted to a prerequisite of 15.3.

## Verification

### Dispatch 29 (the current end state)

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2791 jobs**, **zero** `error:` and **zero** `warning:` lines. Run four times over the dispatch,
  once per green sub-step, clean each time. Tier 3 confirmed: the `.olean` of `Fixture`, `Stable`,
  `Window` and `Timed` are each newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1**, identical to `main`'s — pre-existing, not introduced here.
- Axiom count: **14**, identical to `main`'s — unchanged.
- `#print axioms` on all sixty-four new declarations: each within
  `[propext, Classical.choice, Quot.sound]`; no `sorryAx` anywhere in the output.
- Anti-goal compliance checked explicitly: **no `[Fintype TPos]`** anywhere (the `Fintype` on
  `verts`' subtype and `DecidableEq TPos` are confirmed by `example … := inferInstance`); `live_iff`
  untouched, so no one-directional weakening; the widening to `-2 * NB` / `NM + 2 * NF` is recorded
  loudly with the fixture as its justification; and `NB` / `NF` / `NM` are an lcm, an lcm and a max
  **of the certificate's own segment lengths**, so no declaration states a bound on `n`, on a period
  or on a lasso count.
- Files verified: Yes.

### Dispatches 21-27 (retained)

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2780 jobs** through Phase 12 and **2782 jobs** after Phase 13, **zero** `error:` and **zero**
  `warning:` lines over both captured streams. Run four times over the dispatch (after Phase 11,
  after the Phase 12 docstring edits, after the statement-shape fix, and after Phase 13), clean each
  time. Tier 3 confirmed: the `.olean` of `Limits/HopFree`,
  `Limits/NoCertificate`, `Limits/Targets`, `PlusWitnessFamily` and the `FormalSystem` root are all
  newer than their sources.
- **A false pass was caught and must be recorded.** `lake-build-guard.sh` shares its lock, result
  and log files **by hardlink** between the main tree and every `.orchestrate-worktrees/*` worktree
  (verified: `.lake/build-guard.log` has the same inode in both). The first guarded build in this
  dispatch therefore **replayed a stale main-tree result and reported `exit_status=0` for a module
  that had never been compiled** — with no `.olean` written. Every build after that passed
  `--no-share`. Any future dispatch building inside a worktree must do the same and must confirm
  the verdict against `.olean` timestamps rather than the exit code alone.
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots; empty inventory).
- Vacuous count: **0 attributable to this task.** The repository-wide scan reports one pre-existing
  match, `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal … := trivial`), outside this task's file scope and not a placeholder — the
  ℤ-time history's domain is total by construction. Reported rather than silently filtered.
- Axiom count: **unchanged at 14** over all resolved roots. No new module declares an `axiom`.
  `#print axioms` on every new declaration across all four new files returns a subset of
  `[propext, Classical.choice, Quot.sound]` — `getD_mem_of_lt` needs only `[propext]` and `cyc_mem`
  only `[propext, Quot.sound]`.
- **Phase 13's field-absence criterion was checked by reading the declarations, not assumed.**
  `PlusGraphPath` has exactly `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`label_sub`; `PlusSlice` exactly
  `edge`/`lab`/`lab_sub`; `PlusSlicedCertificate` exactly
  `n`/`n_pos`/`back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`bx`/`target`/`targetTime`. A grep for `lift`,
  `trans`, `witness`, `stepR`, `stateLab` as field names returns 0.
- **The gate was last run in full at Phase 12** (verdict below). Phase 13's four added/changed files
  postdate it; its own verification tier is `interface`, and Stage 2's gate rows and axiom pins are
  assigned to Phase 21, so no C2 divergence is possible from Phase 13's declarations. A full gate
  re-run belongs to the next dispatch.
- **Soundness survives, measured**: `plusTruth_iff_mem` and `plusRefutes_of_certifies` both still
  print exactly `[propext, Classical.choice, Quot.sound]`, and neither statement was edited.
- `bash scripts/check-module-invariants.sh`: **one check group fails, B0, and it is environmental.**
  - `PASS C2 all twenty-two pinned axiom sets match baseline` — the four new pins verified against
    a live compile, not transcribed.
  - `PASS C15` for all 61 paper-anchor citations and all 231 theorem-index rows carrying their
    anchor (or `Paper: —`) at the declaration.
  - `PASS` for C8, C11, C16, C21, C22, C23, C24, C25, C25N, C33, C34b, C35, C9D and the rest.
  - `INV` failed on the first run and **passes now** — it was genuinely caused by the two added
    modules and was fixed, not waived.
  - `FAIL B0 expected exactly 1 Boneyard directory at ./Boneyard, found 2` — **enumerated,
    reasoned, evidenced exclusion.** The second directory is
    `./.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard`, a leftover *harness* worktree from the
    aborted dispatch 21, still registered in `git worktree list`. It is gitignored, contains no
    work of this task, and its only commit (`228168b3b`) is already landed on `main` as
    `9355b68fe`, so nothing is lost by removing it. **It fails identically at `main`'s own HEAD
    with none of this dispatch's changes present** — confirmed by running the same `find` in the
    main tree with the dispatch worktree excluded. It was deliberately **not** removed here:
    deleting a registered git worktree belonging to another session is a destructive git operation
    outside an implementation agent's scope, and `/refresh` is the sanctioned remedy. One command
    clears it: `git worktree remove --force .claude/worktrees/agent-aa19bfa3bfef394ff`.
- `scripts/typst-sync-check.sh`: PASS after `--fix` (status.typ, module map and machine appendix all
  in sync). The repository's pre-commit hook is this check in `--counts-only` form and was confirmed
  green.
- Tests: N/A — no executable added and no test surface changed.
- Files verified: Yes.
- **No file under `/home/benjamin/Projects/ModelChecker` was created, edited or staged.** Confirmed:
  `git -C /home/benjamin/Projects/ModelChecker status --porcelain` shows only its pre-existing
  ` M specs/events.jsonl`, unchanged before and after the read.

### Dispatch 25 (Phase 14 and Phase 15.1) — measured

- Build: **Success**. Full `lake build`, guarded and detached with `--no-share`, run twice: after
  Phase 14 (`exit_status=0`, **2784 jobs**) and after Phase 15.1 (`exit_status=0`, **2786 jobs**),
  **zero** `error:` and **zero** `warning:` lines over both captured streams each time. Four scoped
  `--no-share` module builds in between, all clean; `Splice.lean` compiled with zero errors and zero
  warnings on the **first** attempt.
- Tier 3 confirmed by an explicit `-nt` check: the `.olean` of `Semantics/SlicedFrame`,
  `PlusSlicedCertificate/Frame`, `PlusSlicedCertificate/Splice` and `PlusSlicedCertificate/Position`
  are each newer than their source.
- `lean-sorry-census.sh` over all resolved source roots: `sorry_count: 0`, empty inventory.
- Vacuous-definition grep over all resolved source roots: **1 match, unchanged from `main`'s
  baseline of 1**, and it is a false positive — `Examples/TemporalStructures.lean`'s
  `int_domain_universal` is a genuine statement (`intTimeHistory.domain t`) whose proof happens to be
  `trivial`. Zero vacuous definitions were introduced.
- Axiom count: **14 across all resolved source roots, identical to `main`'s baseline of 14**; and
  `grep '^axiom '` over the four new modules returns **0**.
- `#print axioms` on all twenty-nine new declarations checked: each within
  `[propext, Classical.choice, Quot.sound]`. Four are strictly cheaper — `iterS_add`,
  `ofSlicedStep_serial` and `ofSlicedStep_compositional` need only `[propext, Quot.sound]`, and
  `truth_of_agree_of_type_eq` needs only `[propext]` — so `Classical.choice` enters at the
  *Saturation* discharge and nowhere else in the generic frame layer.
- `git diff` over `FormalSystem/Semantics/IntNormalForm.lean`: **no hunk.** Over
  `PlusWitnessFamily/Agreement.lean`: **no hunk**, across the whole task.
- **Plan compliance spot-check**: of the eleven declaration names in the plan's Goals block, nine
  resolve; the two that do not are `exists_plusSlicedCertificate_of_tailStable_countermodel` (Phase
  19) and `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` (Phase 20), neither of which
  is in scope for a dispatch that reached Phase 15.1. The mechanical verdict is therefore `failed`,
  and it is `failed` **because the task is unfinished**, not because a landed declaration drifted
  from its pinned name.
- `bash scripts/check-module-invariants.sh` (full): exits 1 with **three** failing groups, all
  dispositioned by name under the plan's Phase 21 heading. `INV` failed, was **caused by this
  dispatch** (the new `Semantics/SlicedFrame.lean` had no hand-maintained inventory row, and three
  generated blocks were stale), and was **fixed, not waived** — it passes now. The three that remain:
  - `FAIL B0` — pre-existing at `main`'s HEAD, the same leftover harness worktree recorded above.
  - `FAIL C23` — pre-existing at `main`'s HEAD: the `datum` base-name pair
    (`BiLasso/Realized.lean:156` vs `PlusSlicedCertificate/Basic.lean:178`). **Both declarations were
    confirmed present on `main`**, so this dispatch neither caused nor worsened it.
  - `FAIL C9` — four `specs/{NNN}_.../probes/...` citations in Lean docstrings. One
    (`Basic.lean:22`) was already on `main`; three are new here. **This plan mandates those citations
    in four separate places** and the exemption taxonomy has no covering category, so it is a genuine
    plan-versus-rule conflict rather than an oversight. Two candidate resolutions are recorded under
    Phase 21, with the path-dropping one recommended; the decision must be made once and applied to
    all four.


### Dispatch 27 (Phase 15.2) — measured

- **Guarded, detached, `--no-share` scoped build** of
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live`: `exit_status=0`, 1213 jobs,
  **zero** `error:` and **zero** `warning:` lines. `Live.olean` confirmed newer than `Live.lean`
  (the three-tier verdict, not the success bar alone). `Live.lean` compiled on the **first**
  attempt; the only findings on that first build were two unused `simp` arguments, removed before
  the recorded run.
- `#print axioms` on all twenty-six new declarations, via `lake env lean` on a scratch file outside
  the library: every one within `[propext, Classical.choice, Quot.sound]`, and **no other axiom
  appears anywhere in the output** (checked by inverting the grep, not by eyeballing).
- `lean-sorry-census.sh` over all four source roots: `sorry_count: 0`, empty inventory.
- **Vacuous-definition census: 1, unchanged from `main`.** The single hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal ... := trivial`), is pre-existing and is a true statement about the `Int`
  time domain rather than a placeholder. Delta from `main`: **0**.
- **Axiom census: 14, unchanged from `main`.** Delta: **0**.
- **Soundness survives, measured.** `plusTruth_iff_mem` (`Agreement.lean:183`) and
  `plusRefutes_of_certifies` (`Agreement.lean:413`) both carry their statements unchanged;
  `git diff --stat HEAD -- .../PlusWitnessFamily/` is **empty**, so the whole subtree is untouched
  by this dispatch.
- **Plan compliance spot-check: 9 of the 11 declaration names in the plan's Goals block are
  present**, the same 9 as dispatch 25. The two absent —
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and
  `exists_plusSlicedCertificate_of_tailStable_countermodel` — are Phase 19's and Phase 20's top-level
  theorems, and Phases 16-21 are NOT STARTED. The mechanical check therefore reports `failed`, and
  that is the honest reading: the task is `partial`, not `implemented`.
- **The `--no-share` hazard is still live and was respected on every build in this dispatch.**
- **Gate state: `check-module-invariants.sh` was NOT run to completion from the main tree in this
  dispatch.** It exceeds ten minutes and, as plan v5 requires, Phase 21's gate must be run from the
  main tree with **no nested checkout live** — which this dispatch's own worktree violates by
  construction. The three pre-existing failing groups recorded at dispatch 25 (B0's Boneyard count,
  C23's `datum` base-name pair, C9's `specs/**/probes/` citations in Lean docstrings) are
  re-reported unresolved below; none is introduced or worsened here.
- **C9 is re-reported as a direct conflict with this plan, and was NOT resolved by weakening the
  invariant.** The plan mandates citing `specs/{NNN}_.../probes/...` paths in Lean docstrings in four
  places and the exemption taxonomy has no covering category. `Live.lean` was written to cite
  **declaration names only** and adds **no** new C9 occurrence, so the count is unchanged; the
  standing four still need one decision applied to all four at Phase 21.
## The paired repository's export contract

Phase 12's original bullet instructed the implementer to record that the contract "changes shape
from a list of lassos to a finite model … whose search bound is a bound on the number of world
states". **Plan v4's own amendment supersedes that**, on report 706's Q1.3 and Q7, and the
superseded wording is not recorded here. The five points the amendment directs be recorded instead
are, restated so that this summary is self-contained:

1. The **finite-graph** certificate must not become an export contract: it cannot represent
   countermodels the current lasso-family contract already represents — `θ.neg` is a `⊡`-free
   target the landed L family certifies and no finite-carrier certificate can.
2. The intended L⁺ contract is the **time-sliced graph**: per slice, an edge matrix and a state
   labelling; three segments `back`/`mid`/`fwd` of slices; one target path and time; `bx`. The
   current lasso family is the special case of `k` lassos with edges `i → i` only, so the wire
   format is a **strict extension, not a replacement**.
3. The search bound is a **tuple** `(n, nb, nm, nf)` — slice width and three segment lengths. **No
   bound on `n` is proved for any L⁺ target**, and none should be configured from a formula yet.
   "The search bound is a bound on the number of world states" is wrong in kind: there is no finite
   number of world states to bound. For `⊡`-free targets the landed L bounds apply unchanged, and
   the registry's period-folding caveat carries over to `nb`/`nf`.
4. The checker additionally requires **tail-stability**, so a search that finds a countermodel with
   unstable tails must re-present it with the pre-period moved into `mid` and the period multiplied.
5. The never-report-validity discipline stands: an empty search at any bound licenses nothing for
   L⁺ targets containing `⊡`, and will until a finite model property is proved.

**What this dispatch adds to that, from Stage 1's own results**: the compression bound that
`ModelChecker`'s #200 lists as the fourth of its four needs **does not exist, and cannot exist for
the landed certificate class.** That is no longer an expectation to be managed — it is
`not_exists_plusCertifies_pumpTarget`. The cross-repository hand-off note's item 5 ("the L⁺
compression theorem and its bound — task 703") is therefore answered in the negative, and the
O3 bound warning that note carries forward ("the paired repository's search-bound expectations for
#200's fourth need must not be set from the `Formula` side's `|closure| + 1` figure") is upgraded
from a caution to a settled fact: there is no `|closure| + 1` figure, and no figure of any shape,
for a class that certifies nothing at `pumpTarget`.

**Status of the confirmatory read.** The read of `/home/benjamin/Projects/ModelChecker`'s *current*
export format and bound configuration was delegated to a read-only subagent, which had not reported
by the time this dispatch closed — and which is owned by the parent session, so its report is
addressed there rather than into this dispatch's record. Whoever receives it should reconcile it
against points 1-5 above and, if it corrects any of them, amend this section rather than adding a
second account; whatever it establishes is a confirmation of, or a correction to, points 1-5 above,
which come from this repository's own report 706 rather than from an assumption about the paired
repository. The obligation to read rather than assume is therefore **partially discharged**: the
five points recorded above are read off report 706 and plan v4, not off the paired repository, and
a successor closing Phase 21 should complete the read. This is stated plainly rather than presented
as a completed read.

## Impacts

- **The L⁺ compression statement is refuted in the tree.** `plusCompression_fails_at_pumpTarget`
  bundles the non-validity and the absence of a certificate, so the withdrawal can be cited as one
  declaration rather than argued from a report.
- **Stage 2's design constraints are now forced rather than chosen.** "All-threads fulfilment is
  replaced by fulfilment of live positions only" is exactly what
  `not_exists_plusCertifies_pumpTarget` compels; Phases 13-21 inherit it as a theorem.
- **The hop-free producer is retired as a completeness strategy while its theorems survive.** Any
  future producer of L⁺ certificates now has a named reason not to be hop-free.
- **Four new C2 pins.** The two non-validities and the two incompleteness theorems are now pinned
  against a live compile, so a later change that silently widened their foundation would be a hard
  stop rather than a quiet regression.
- The `Limits/` subtree is self-contained: nothing outside it changed behaviourally, and the only
  edits to existing Lean modules are docstrings plus two import lines and the generated root.

## Follow-ups

- **NEXT (dispatch 29's seam): sub-phase 15.3 STEP 4**, the timed graph `succT` / `predT`. All four
  lemmas it needs are landed (`posAt_nextTime` / `posAt_prevTime` and `slice_nextTime_pred` /
  `slice_prevTime_succ`); the intended definitions are written out in the dispatch-29 handoff. Then
  STEP 5 (the two fixpoints, with a **generic** decreasing `Finset` iteration written once), STEP 6
  (the bridge to `Live`), then Phase 16.2.
- **The fixture does not settle everything it might be read as settling.** It proves the doubling
  necessary, and sufficient *for itself* at `NB = 1`; the general wrap-soundness claim is the four
  faithfulness lemmas of `Timed.lean`, proved from the generic inequalities rather than from the
  factor `2`. It also does **not** adjudicate between addendum (d)'s (α) and (β), since its target
  path has back period `1` too.
- **`git-commit-scoped.sh` cannot commit inside a dispatch worktree**, and fails as a silent "Nothing
  to commit". It derives `PROJECT_ROOT` from its own location under `.claude/scripts/` and `cd`s
  there, so it always operates on the main tree. This is the cause of seq 27's missing attribution
  trailers; dispatch 29's four commits use plain `git -C <worktree>` with an explicit file list and
  carry the trailers. Recorded in the handoff as an environment hazard.
- **RESOLVED in dispatch 27 — the Phase 15 / Phase 16 ordering question, and both of its candidate
  routes, are superseded.** The presupposition was false: eventual periodicity is not what makes the
  liveness fixpoint finite (`AUFix` terminates by the cardinality of an explicit `V : Finset α` and
  asks for no `Fintype`). The real defect is that `Pos` factors time **out** of the carrier, so the
  fixpoint would live in `(Finset Pos)^ℤ`. Route (i) is unnecessary; route (ii) keeps the disease. The
  seam taken instead is Prop-vs-compute: 15.2 landed the declarative liveness with both
  characterization directions at `∀ t`, and 15.3 transcribes the `Formula` side's rolled timed carrier
  for the computation. Full record: the plan's Phase 15 heading, block **RESOLUTION OF THE 15.2
  ORDERING QUESTION**, plus the **AMENDMENT TO PHASE 16**.
- **BUILD PHASE 16's `Fixture.fourState` BEFORE starting sub-phase 15.3.** 15.3's STEP 2 fixes
  `winLo`/`winHi`, and the landed `exists_window_eq` window is **single**-period `[-nb, nm + nf)`
  where the `Formula` side's is **doubled**. Identical local graphs do not imply identical liveness,
  so the single-period window cannot give a sound wrap; the fixture is the test of whether doubling
  suffices. Two cautions are recorded in the dispatch-27 handoff: the fixture as worded may not be
  realizable at uniform slice width with a per-slice `edge` and back period 1, and `⊡`-truth is not
  `#eval`-able, so the plan's *named-lemma* requirement is the one to satisfy.
- **Land the machine-checked `#eval` witness for the `succP`-totality counterexample.** The argument
  is recorded in `Position.lean`'s header and is sound over the definitions in this tree, but a
  concrete certificate (`onePointCertificate` at `n = 1`, empty slice labelling, a closure containing
  `untl` over two atoms) with `#guard G.succP t p = ∅` would make the record a fact of the tree
  rather than a prose argument. Cheap: the position space there has 2^|closure| elements.
- **`--emit-inventory` belongs to every phase that adds a module, not only to Phase 21.** Each new
  `.lean` file reproduces the `INV` failure (a missing hand-maintained subtree-README row plus stale
  generated blocks). Same for `scripts/typst-sync-check.sh --fix`, which the pre-commit hook gates on.
- **Stage 2 is opened but not finished; Phase 15.3 and Phases 16-21 remain.** Phase 13 landed the
  three types, the readout and bi-seriality. What is left: the frame on `ℤ × Fin n` and its
  histories characterization (14), computed liveness with **both** directions (15), tail-stability
  with its four-state counterexample fixture (16), the decidable checker (17), soundness into the
  unchanged `PlusRefutes` export (18), completeness relative to tail-stable sliced models (19), the
  embedding of the landed L witness family (20), and the acceptance gates and closing record (21).
  **No Stage 2 probe exists**, so unlike Phases 9-11 none of it can be transcribed. Phases 15 and 16
  are the plan's own two highest-risk phases and 16 is deliberately scheduled before the checker.
- **Phase 17 should consume `BoxFaithful`, `Target` and `forall_slab_iff_window` from Phase 13
  rather than restating them.** They were written in Phase 13 specifically to discharge its Scope
  Hypothesis, and duplicating them would leave two definitions of the same clause group.
- **B0** is open and environmental: `git worktree remove --force
  .claude/worktrees/agent-aa19bfa3bfef394ff` in the main tree clears it. Until then
  `check-module-invariants.sh` reports one failing group in both the main tree and any worktree.
- **Four Mathlib names are unavailable in these modules' import closures** and cost iteration this
  dispatch: `ring`, `neg_one_mul`, `dvd_rfl`, `add_sub_cancel_right`, `le_or_lt` and
  `List.getD_eq_getElem`. Working substitutes are recorded in the Phase 13 handoff. Any further
  transcription from a probe (every probe does `import FormalSystem`) should expect to hit this.
- **The build-guard hardlink sharing is a live false-pass hazard** for every worktree-based
  dispatch in this repository, not just this task. Recorded in full under Verification. A fix in
  the guard (keying the result path on the resolved project root rather than sharing it) would
  close it; `--no-share` is the workaround.
- **Complete the paired-repository read** before Phase 21 closes, and reconcile it against the five
  points recorded above.
- **`trans_refl` remains a live risk, now for the two landed limit modules.** Both call
  `S.trans_refl'` at one identified step (obtaining the one-step `untl` unfolding at the *same*
  index). If task 699 Part A's proposed follow-on drops `trans_refl` from the substrate, both
  modules need a different route to that step. Phase 9's `Targets.lean` is unaffected.
- **`plusValidZTime_iff_plusValidInt` is still unconsumed.** Stage 1 states its non-validities
  against `PlusValidZTime` and never mentions `PlusValidInt`, consistent with plan v4's note that
  the carrier-normalization prerequisite is no longer on this plan's critical path.

## References

- `specs/703_lplus_compression_and_completeness/plans/04_lplus-sliced-certificate-and-completeness.md`
  — the plan. Phases 9, 10, 11 and 13 are `[COMPLETED]` and Phase 12 is
  `[COMPLETED WITH EXCLUSIONS]`, each with a `Verification — MEASURED` block under its heading.
- `specs/703_lplus_compression_and_completeness/probes/HopFreeIncomplete.lean` and
  `probes/NoFiniteCertificate.lean` — the provenance record for Phases 10 and 11; untouched, as the
  plan requires.
- `specs/703_lplus_compression_and_completeness/handoffs/phase-10-handoff-20260930T014500Z.md`,
  `handoffs/phase-11-handoff-20260930T015500Z.md`,
  `handoffs/phase-12-handoff-20260930T021000Z.md`,
  `handoffs/phase-13-handoff-20260930T023000Z.md`
- `specs/703_lplus_compression_and_completeness/handoffs/phase-14-handoff-20260930T094316Z.md`,
  `specs/703_lplus_compression_and_completeness/handoffs/phase-15-handoff-20260930T095826Z.md` — dispatch 25's two phase handoffs; the second carries the gate-state findings and the
  Phase 15 / Phase 16 ordering question
- `specs/703_lplus_compression_and_completeness/probes/TypePreservingPaste.lean` — the provenance
  record for `Splice.lean`'s `truth_of_agree_of_type_eq`; transcribed with no added hypothesis and
  left untouched, as the plan requires
- `specs/703_lplus_compression_and_completeness/.dispatch/23.md` and `.dispatch/25.md` — the two
  dispatch contexts behind this summary
- `specs/archive/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md` — the
  five must-land results and the O3 bound warning this task answers
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/` — Stage 1's three landed modules
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/` — Stage 2's four landed modules:
  `Basic.lean`, `Frame.lean`, `Splice.lean`, `Position.lean`
- `FormalSystem/Semantics/SlicedFrame.lean` — the generic sliced frame, the only file this task adds
  outside the `PlusSlicedCertificate/` subtree
