# Implementation Summary: Task #703

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-30T00:52:00Z (dispatch 21); 2026-09-30T01:20:00Z (dispatch 23);
  2026-09-30T02:05:00Z (dispatch 25); 2026-09-30T10:10:00Z (dispatch 27);
  2026-09-30T10:39:15Z (dispatch 29); 2026-09-30T16:14:55Z (dispatch 31);
  2026-09-30T17:20:00Z (dispatch 33); 2026-09-30T18:40:00Z (dispatch 34);
  2026-09-30T18:05:00Z (dispatch 36)
- **Completed**: not complete — **Phase 15 is COMPLETED** (15.1, 15.2 and 15.3 in full, including
  15.3's own gate), Phase 16 is IN PROGRESS (16.1, 16.2a and 16.2b complete — including
  `tailStable_iff_window` as a biconditional on both tails — with only 16.2c open) and Phases 17-21
  are NOT STARTED. Last dispatch ended 2026-09-30T18:41:00Z
- **Effort**: ~30 minutes (dispatch 21, Phase 9) + ~70 minutes (dispatch 23, Phases 10-13)
  + ~125 minutes (dispatch 25, Phase 14 and Phase 15.1) + ~30 minutes (dispatch 27, Phase 15.2)
  + ~35 minutes (dispatch 29, Phase 16.1 and Phase 15.3 STEPS 1-3)
  + ~40 minutes (dispatch 31, Phase 15.3 STEPS 4, 5, 6a, 6b and the 6c prerequisite)
  + ~55 minutes (dispatch 33, Phase 15.3 STEP 6c complete, and 6d's blocker identified)
  + ~40 minutes (dispatch 34, Phase 15.3 STEP 6d, 15.3's gate, and Phase 15 closed)
  + ~35 minutes (dispatch 36, Phases 16.2a and 16.2b, both tails)
- **Dependencies**: `FormalSystem.Metalogic.Decidability.SharingSkeleton`,
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` (both landed).
  `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is NOT consumed by Stage 1 — see
  Verification.
- **Artifacts**: plans/04_lplus-sliced-certificate-and-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

**Dispatch 33 closed sub-phase 15.3's STEP 6c — the eventuality-aware liveness fixpoint and the
round-robin concatenation the plan named as STEP 6's single largest remaining piece — and identified,
by measurement rather than by reasoning, the exact obstacle that blocks STEP 6d.** Two green
sub-steps, a commit each. `Fixpoint.lean` gains two generic namespaces with no counterpart anywhere
in the tree: `Glue`, which turns a sequence of finite paths into one infinite walk, and `Fair`, which
schedules obligations round-robin across those blocks and proves that a late discharge answers an
early demand. The new module `LiveFix.lean` instantiates both at the timed graph, giving `fwdLiveT`,
`bwdLiveT`, `liveT`, each with **both** directions of its fixpoint characterization, and the two
headline theorems `exists_fwdLive_walk` / `exists_bwdLive_walk`: **one** infinite walk inside the
fixpoint discharging **every** eventuality pending anywhere along it, guard included.

Two corrections to instructions this dispatch was given, both recorded rather than absorbed. First,
the prescribed inner reachability test was insufficient in precisely the way the already-rejected
route (β) was — `EUFix`'s path constrains its interior and says nothing about its endpoint, so a
discharging segment can end outside the set the walk may never leave. The event has to be relativized
too, and that in turn is why monotonicity in the vertex set alone was not enough. Second, the plan's
claim that a spliced walk's "five `LabRun` fields are exactly the eight readouts 6b landed" is four
of five: `coherent`'s **box clause** is supplied by nothing in the condition set, and closing it is a
condition-set decision rather than proof work. STEP 6d therefore stops before its first line, with
both candidate resolutions written out and a recommendation.

**Dispatch 31 closed sub-phase 15.3's STEPS 4 and 5 and two of STEP 6's four pieces**, in five green
sub-steps with a commit each. The timed graph `succT` / `predT` now exists; the two fixpoint operators
the sliced side needs exist **generically**, each with membership proved equivalent to the existence
of the walk it describes; both are instantiated at both graphs; the fold relation that makes a wrapped
graph walk readable at genuine times exists; and a walk is now readable as a ℤ-indexed half-run in
exactly the shape a `LabRun` field consumes. Two findings are corrections to the plan rather than
progress against it: `succT` and `predT` are **not** mutual inverses, so the adjointness is
edge-level only; and `AUFix` — which STEP 5 named for the inner eventuality-discharge step — supplies
**neither** half on the sliced side, because it is the universal operator and the outer condition is
existential. The remaining bridge work is STEP 6c (the eventuality-aware fixpoint, whose design this
dispatch settled, including the finding that the cheaper-looking alternative is unsound) and STEP 6d
(the position-level splice and the equality with `Live`). Phases 17-21 are untouched, and the task's
two headline theorems remain unproved.


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

### Dispatch 34 — the bridge, the gate, and Phase 15 closed

**Sub-phase 15.3's STEP 6d is landed and Phase 15 is `[COMPLETED]`, its last verification bullet
included.** Two green sub-steps, a commit each. The new module `Bridge.lean` proves the equality the
whole computed-liveness development exists to establish —
`G.Live s p ↔ (p, s) ∈ G.liveT` at a window time — and with it `decidableLive`, the `Decidable`
instance Phase 17's checker is written against. `Live` as `Live.lean` states it quantifies over runs
of a structure with an infinite carrier and admits no instance of its own; this is where that
becomes a decidable test.

Dispatch 33's condition-set blocker is **resolved by taking its own recommendation (a)**:
`Basic.lean` gains `BoxLabelFaithful`, the (C3b) box-**label** clause, with the two-directional
window reduction `boxLabelFaithful_iff_window` that costs a checker one more bounded quantifier and
nothing else. The choice was the agent's to make rather than the user's, because it is fully
reversible inside this repository — overturning it costs one `def`, one `theorem` and the removal of
one hypothesis from four declarations, since (C3b) is consumed at exactly one place. Two facts
confirm it narrows nothing that matters: any certificate a genuine countermodel presents satisfies
it (`plusBox_const`), and `Fixture.cert` satisfies it **vacuously**, its closure carrying no
`□`-formula at all.

Two further corrections to the plan, both found by reading the landed definitions rather than by
reasoning about them. The bridge **cannot** be stated at a general time: `FoldF` and `FoldB` are
disjoint away from the diagonal, so no single window time carries both half-line readouts at a time
outside the window, and this plan's instruction to have `exists_foldF` / `exists_foldB` supply the
bridge's time is superseded. And the two directions are **not** symmetric: completeness factors into
independent halves needing no box clause, while soundness factors into none, because `FwdLive`
demands a bi-infinite run that the forward fixpoint alone cannot produce.

15.3's gate — `G.live` on a concrete certificate, neither empty nor the whole position space — is
closed by proof, not by evaluation, and the route was established before a run was spent on it, as
dispatch 33 asked: `liveT` is a greatest fixpoint iterated `verts.card + 1` times whose every
iteration runs an inner least fixpoint of the same height, so `decide` is not a route. The hand route
uses the bridge in **both** directions, which is what makes the gate evidence that neither direction
is vacuous.

## What Changed

### Phase 15.3 STEP 6d and 15.3's gate (dispatch 34, on branch `orchestrate/task-703-34`)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Basic.lean` — **extended** with the
  (C3b) condition: `BoxLabelFaithful`, `BoxLabelFaithfulWindow`, and
  `boxLabelFaithful_iff_window`, the two-directional window reduction, proved by the same residue
  argument as (C3)'s `forall_slab_iff_window`. The docstring states why the clause is not a
  consequence of (C3) — (C3) constrains `G.bx χ` against the subformula `χ`, not against `box χ` —
  and why a genuine model satisfies it.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean` — **new**, 609 lines.
  `fwdOrbit` / `bwdOrbit` and `fwdVert` / `bwdVert` fold a run's own positions into the window;
  `mem_fwdLiveT_of_fwdLive` / `mem_bwdLiveT_of_bwdLive` / `mem_liveT_of_live` are the completeness
  direction; `spliceWalkPos` with `runOfWalks` and its five field lemmas is the **position-level**
  splice and the run it presents; `fwdFulfilling_runOfWalks` / `bwdFulfilling_runOfWalks` lift the
  half-line discharge; `live_of_mem_liveT`, `live_iff_mem_liveT` and `decidableLive` are the bridge
  and its payoff.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixture.lean` — **extended** by 62
  lines with 15.3's gate: `boxLabelFaithful` (vacuous here), `mem_liveT_neg_one`,
  `mem_verts_neg_two`, `not_mem_liveT_neg_two`, and `liveT_ne_empty_and_ne_verts` — one and the same
  position a live vertex at `-1` and a dead one at `-2`, on a certificate whose slice is literally
  the same at both times.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — the `Bridge` import, plus the
  aggregator doc entries for `LiveFix` (missing since dispatch 33) and `Bridge`, and a correction to
  `Stable`'s entry, which still said the computed liveness `Finset` had yet to be built.
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem`.
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix`, once per
  commit, as the pre-commit hook requires.

### Phase 15.3 STEP 6c (dispatch 33, on branch `orchestrate/task-703-33`)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — **extended** by ~454
  lines with two generic namespaces, and corrected in two places:
  - `EUFix.exists_path_of_mem_lfp` now *also* concludes `∀ k < m, f k ∈ V` — strictly more than
    before, so nothing landed is weakened — and `EUFix.lfp_mono_all` generalizes `lfp_mono_V` to
    monotonicity in the **event and guard predicates** as well as the vertex set. `step_mono_V` /
    `iter_mono_V` / `lfp_mono_V` survive unchanged as the special cases.
  - `Glue` — `off` (block addresses), `idx` (an index's block, by recursion rather than by
    minimization), `walk`, and the three readouts `walk_mem` / `walk_step` / `walk_eq`.
  - `Fair` — `inSet` (the endpoint condition), `fair_of_blocks` (propagation plus schedule, at an
    **arbitrary** block structure needing only `n ≤ start n`), `exists_block`,
    `exists_fair_walk_of_blocks`, `exists_fair_walk`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Computed.lean` — `exists_untlPath_of_mem`
  and `exists_sncePath_of_mem` carry the new `∀ k < m, f k ∈ G.verts` conjunct through.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` — **created**, ~471 lines:
  `untlLive` / `snceLive` and their monotonicity; `untlLiveAt` / `snceLiveAt`, the per-formula clause
  in `Position.lean`'s `untlClauseAt` idiom; `fwdLiveStep` / `bwdLiveStep` (deflating, monotone);
  `fwdLiveT` / `bwdLiveT` / `liveT`; `fwdLiveT_fixed` / `fwdLiveT_greatest` and the backward pair;
  `fwdLiveT_subset_fwdWalkable` / `bwdLiveT_subset_bwdWalkable`; `untl_step_dichotomy` /
  `snce_step_dichotomy`, the (C1') propagation clause read along an edge; the four schedule
  declarations; and `exists_fwdLive_walk` / `exists_bwdLive_walk`.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — one added import line.
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem`.
- `typst/generated/status.typ` — regenerated line counts (the pre-commit gate requires it).

Nothing in `LiveFix.lean` mentions `Live`, `FwdLive`, `BwdLive` or `LabRun`: the bridge is STEP 6d and
no placeholder stands in for it.

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

### Dispatch 31 — Phase 15.3 STEPS 4, 5, 6a, 6b and the 6c prerequisite

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` — extended with **STEP 4**,
  the timed graph: `succT` / `predT`, reading `succP` / `predP` at the **unwrapped** time and placing
  the result at the **wrapped** one; `mem_succT` / `mem_predT`, the two `verts` subset lemmas and the
  four projections; two new congruences `succP_congr` (which needs both slices `succP` touches) and
  `predP_congr` (which needs the one `predP` touches) with their transports `predP_nextTime` /
  `succP_prevTime`; and the **edge-level** adjointness `mem_succT_iff_mem_predP` /
  `mem_predT_iff_mem_succP`. 17 new declarations.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fixpoint.lean` — **created**, **STEP
  5a**, and generic: no certificate appears anywhere in it. `Nu.gfp` is the greatest fixpoint of an
  arbitrary deflating monotone contraction on `Finset α`, terminating at `V.card`, with no
  `DecidableEq` needed at that level. `EGFix` is its instance at "has a successor in the set"
  (`EG ⊤`) and `EUFix` is the existential `E[g U e]`, which is `AUFix` with its universal successor
  quantifier replaced by an existential one. Each carries **both** directions of its
  characterization — `EGFix.exists_walk_of_mem_gfp` / `mem_gfp_of_walk`,
  `EUFix.exists_path_of_mem_lfp` / `mem_lfp_of_path` — plus the coinduction and induction
  principles, and `EUFix.lfp_mono_V`, monotonicity in the vertex set. 41 declarations.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Computed.lean` — **created**, **STEP
  5b**: each generic operator instantiated **twice**, once at `succT` and once at `predT`.
  `fwdWalkable` / `bwdWalkable` (`EGFix.gfp`) and `untlReach` / `snceReach` (`EUFix.lfp`), with
  `atPosT`, the subset lemmas, the one-step unfoldings, the two induction principles in
  `untlFix_induction`'s own shape, the four walk-readout lemmas, and each characterization in both
  directions. 28 declarations.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Fold.lean` — **created**, **STEP 6a**:
  `FoldF` / `FoldB`, the equivalences the two wraps generate, each carrying the **residue** condition
  rather than the data agreement it implies. refl/symm/trans for each; the data **pair** for each
  direction (`foldF_slice` with `foldF_target_datum`, and the backward pair); the three graph-layer
  liftings `foldF_edge` / `foldF_posAt` / `foldF_succP` and their backward analogues;
  `foldF_nextTime` / `foldB_prevTime`, each wrap proved to be a fold; `exists_foldF` /
  `exists_foldB`. 24 declarations. Compiled on the **first** attempt, which is the grounding
  addendum's "budget this layer as transcription" prediction coming out right.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Unroll.lean` — **created**, **STEP 6b**:
  a graph walk read as a ℤ-indexed half-run. `fwdWalk_foldF` / `bwdWalk_foldB` are the induction the
  module rests on (a walk's window time at step `k` is fold-equivalent to the genuine time, though it
  is not equal to it); `fwdWalk_posAt` / `fwdWalk_succP` and the backward pair say the walk is a
  genuine one-step path at the **genuine** times; `fwdWalkPos` / `bwdWalkPos` read it off as a
  function of the time; and eight `LabRun`-shaped readouts (`lab_sub`, `labCoherent`, `agrees`,
  `edge`, `stepClause`, in both directions) are what STEP 6d's splice will consume. 26 declarations.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — four added import lines and four
  added `Submodules` bullets.
- `FormalSystem.lean` — regenerated by `lake exe mk_all` after each new module.
- `typst/generated/status.typ` — line/file counts resynced by `scripts/typst-sync-check.sh --fix`
  before each commit, which the pre-commit hook requires (it fires on a *modified* `.lean` file too,
  not only an added one).


### Dispatch 36 — sub-phases 16.2a and 16.2b (three green sub-steps)

- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` — grew from 287 to ~1,300
  lines. No new module, no new import, and no other Lean file touched except the aggregator's
  docstring.
  - **The Φ operators re-indexed to the combined periods.** `Φ_back` now runs `-G.NB → G.winLo` and
    `Φ_fwd` runs `G.NM + G.NF → G.winHi`; `Φ_back_subset_posAt` / `Φ_fwd_subset_posAt` are restated
    on the window's own endpoint slices, and `NBnat_pos` / `NFnat_pos` are added. See Plan
    Deviations.
  - **Transport machinery**: `stepBack_congr` / `stepFwd_congr`, `iterBack_congr` / `iterFwd_congr`,
    `iterBack_add` / `iterFwd_add`, `slice_sub_dvd_of_neg` / `slice_add_dvd_of_ge` with their
    `NB`/`NF`-multiple corollaries, and `iterBack_shift` / `iterFwd_shift`.
  - **The reference sets**: `liveAt` with `mem_liveAt`, `liveAt_subset_posAt`, `mem_liveAt_of_live`,
    `live_of_mem_liveAt` and `mem_liveAt_iff_live`; `neg_NB_mem_winTimes`, `NM_add_NF_mem_winTimes`,
    `winLo_mem_winTimes`; `L₀` and `R₀`.
  - **`TailStable`**, with `decidableTailStable` synthesized by `inferInstanceAs` and confirmed by an
    `example ... := inferInstance`; `iterBack_L₀` / `iterFwd_R₀` turn the one-application demand into
    the `k`-application fact.
  - **Transfer soundness for two-directional `Live`**: `live_subset_stepBack` / `live_subset_stepFwd`
    and `live_subset_iterBack` / `live_subset_iterFwd`.
  - **The forward half of the linchpin**: `mem_L₀_of_live_tail`, `mem_R₀_of_live_head`,
    `live_of_mem_L₀`, `live_of_mem_R₀`, `mem_L₀_iff_live`, `mem_R₀_iff_live`,
    `live_ref_of_live_tail`, `live_ref_of_live_head`, `liveAt_winLo_subset_L₀`.
  - **`runOfPos`** with `coherent_of_pos`, `runOfPos_lab` and `runOfPos_pos` — a `LabRun` from any
    time-indexed family of positions at their own slices stepping along `succP`. `Bridge`'s
    two-region walk splice is a special case; this is the abstraction the middle region forced.
  - **The explicit chains**: `exists_chain_of_mem_iterBack` and `exists_chain_of_mem_iterFwd`.
  - **The three-region runs**: `tailPos` with `tailPos_left` / `_mid` / `_right` / `_le` / `_ge`,
    `tailPos_mem_posAt`, `tailPos_mem_succP` and `live_of_mem_L₀_tail`; then the right-tail mirror
    `headPos` with `headPos_far` / `_mid` / `_near` / `_ge` / `_le`, `headPos_mem_posAt`,
    `headPos_mem_succP` and `live_of_mem_R₀_head`.
  - **The linchpin**: `tailStable_iff_window` and `tailStable_iff_window_fwd` as biconditionals at
    every time down either periodic tail, with `liveAt_tail_eq_L₀` and `liveAt_winLo_eq_L₀` as the
    `Finset` equalities Phase 17 reads.
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` — the `Stable` entry of the
  aggregator docstring rewritten; no import change.
- `typst/generated/status.typ` — regenerated by `scripts/typst-sync-check.sh --fix`, once per commit.

## Decisions

- **(dispatch 34) Resolution (a) is taken for the box-clause gap, and the decision was the agent's
  to make.** `Basic.lean` gains `BoxLabelFaithful`, threaded as an explicit hypothesis through the
  four soundness declarations that need it and through nothing else. Route (b) — folding the box
  clause into `Position.lean`'s `LabCoherent` — stays rejected for the reason dispatch 33 gave: it
  would silently force the same constraint on the certificate through `AgreesOnState`, making
  `posAt t` empty for a violating certificate with no stated clause saying why, and it would perturb
  `succP` / `predP` / `verts` and the landed `mem_posAt_of_path`. Dispatch 33 attached this as a
  non-blocking `user_decision`; it is **not** carried forward, because
  `context/standards/user-decision-contract.md`'s "When NOT to Raise One" is explicit that a fully
  reversible in-repository choice is recorded rather than re-asked, and this one is reversible at the
  cost of one `def`, one `theorem`, and one hypothesis in four signatures.
- **(dispatch 34) The bridge is stated at a window time, and that is forced by the fold relations,
  not chosen for convenience.** `FoldF a b` holds only when `a = b` or both `a, b ≥ NM`; `FoldB a b`
  only when `a = b` or both `a, b < 0`. A biconditional at a general `t` would need one window time
  `s` carrying both, and away from the diagonal the two relations are disjoint, so outside the window
  no such `s` exists. At a window time both hold reflexively. This is not a weakening for the
  checker: `winTimes` is exactly the finite set it iterates over. Consequently `exists_foldF` /
  `exists_foldB` are **not** what supply the bridge's time, contrary to the plan's own instruction;
  they stay `Unroll.lean`'s internal machinery.
- **(dispatch 34) No `fwdLive_iff_mem_fwdLiveT` is landed, deliberately, and it would be false.**
  `G.FwdLive s p` demands a bi-infinite `LabRun`; membership in `G.fwdLiveT` yields a forward walk
  and constrains the past not at all, and `succP`-totality is false (`Position.lean`'s counterexample),
  so no seriality argument recovers a backward half. Soundness therefore consumes both halves of
  `G.liveT` at once. Completeness does factor, and both its halves are landed separately, so Phase 19
  can cite one without the other.
- **(dispatch 34) 15.3's gate is discharged by proof rather than by evaluation, and the infeasibility
  was established before the attempt.** `liveT` is `Nu.gfp` over `verts` iterated `verts.card + 1`
  times, every iteration running an inner `EUFix.lfp` of the same height over a vertex set of size
  `n * 2 ^ |Cl| * |winTimes|`. `decide` is not a route at any patience. The landed route uses the
  bridge in both directions, which is why passing the gate is evidence about the bridge and not only
  about the fixture.

- **(dispatch 33) The inner reachability must relativize its ENDPOINT, not only its interior — and
  the prescription that said otherwise was wrong in the same way route (β) was.** The prescribed test
  `EUFix.lfp X G.succT (G.atPosT e) (G.atPosT g)` puts every *intermediate* vertex of its delivering
  path in the vertex set and constrains the endpoint not at all (`EUFix.mem_lfp_iff`'s disjunction
  takes the delivering successor out of the recursion). A walk obliged to stay inside `X` forever
  cannot splice in a segment that ends outside `X` — which is route (β)'s defect, one level further
  in. Resolution: `Fair.inSet X (G.atPosT e) := G.atPosT e w && decide (w ∈ X)`. This is not a
  refinement for tidiness; without it the round-robin has nothing to concatenate, exactly as the
  plan's own rejection of (β) says.
- **(dispatch 33) `EUFix.lfp_mono_V` was not enough, and `lfp_mono_all` is why the nested fixpoint
  is legal at all.** Once the event predicate carries a `w ∈ X` conjunct it varies with `X`, so
  monotonicity in the vertex set does not give monotonicity of the outer contraction, and `Nu` does
  not apply. `lfp_mono_all` (vertex set, event, guard) closes it; the `_V` forms remain as
  corollaries, so the landed API is extended and not perturbed.
- **(dispatch 33) The round-robin is written at `Nu` / `EUFix`'s level, with the SCHEDULE as a
  parameter.** `fair_of_blocks` asks of the block structure only that `n ≤ start n`, and of the
  schedule only that a servable obligation be scheduled arbitrarily late. That keeps the modular
  arithmetic of a concrete round-robin at the certificate, where the obligation set is known, and
  keeps the concatenation proof about concatenation. It is reusable by anything with the same shape.
- **(dispatch 33) Obligations are indexed by the `(guard, event)` PAIR, not by a formula shape.**
  Indexing by `PlusFormula` would force a seven-constructor case split at every clause; indexing by
  `PlusFormula × PlusFormula` removes all of them, and `untl_step_dichotomy` /
  `snce_step_dichotomy` become four-line proofs off `StepClause`.
- **(dispatch 33) `Glue.idx` and its characterizations are phrased with `off len n + len n`, never
  `off len (n + 1)`.** The two are equal by `rfl`, but `omega` treats `off len (n + 1)` as an atom
  unrelated to `off len n`, so every arithmetic step would otherwise need `off_succ` supplied by hand
  at exactly the right instantiation. The phrasing is load-bearing; reverting it re-introduced four
  arithmetic failures when first written the other way.
- **(dispatch 33) The four schedule declarations are `noncomputable`, deliberately and at no cost.**
  `Finset.toList` is noncomputable, and a schedule is only ever the parameter of an existence
  theorem. Every `Finset` the decidable checker evaluates — `verts`, `succT`, `predT`, `fwdLiveT`,
  `bwdLiveT`, `liveT` — stays computable, which is the property that actually matters.
- **(dispatch 33) STEP 6d is blocked on a MISSING CONDITION, not on proof difficulty, and the
  decision is escalated rather than taken.** `LabRun.coherent` demands
  `PlusLocalCoherentSeqLab Γ Del G.bx lab`, whose box clause is
  `PlusFormula.box χ ∈ lab t ↔ G.bx χ = true`. `Position.lean`'s `LabCoherent` deliberately omits it;
  `AgreesOnState` gives only `box χ ∈ lab t ↔ box χ ∈ G.slab t (st t)`; and (C3) `BoxFaithful` relates
  `G.bx χ` to `∀ t w, χ ∈ G.slab t w` — the **subformula** `χ`, not `box χ`. The subtree's complete
  inventory of `Prop`-valued certificate conditions (`BiSerial`, `BiSerialWindow`, `BoxFaithful`,
  `Target`) closes none of it, and `mem_posAt_of_path` runs the other way, dropping the clause on the
  way in. Recommended resolution **(a)**: add a (C3b) box-**label** clause
  `∀ χ, box χ ∈ plusClosureOf (Γ ++ Del) → ∀ t w, (box χ ∈ G.slab t w ↔ G.bx χ = true)`, decided on
  the window by `exists_window_eq` exactly as `BoxFaithful` is. Resolution **(b)** — folding the
  clause into `LabCoherent` — is rejected as written: combined with `AgreesOnState` it would silently
  force the same constraint on the certificate, emptying `posAt t` for a violating certificate with no
  stated clause saying why, and it perturbs `succP` / `predP` / `verts` and `mem_posAt_of_path`.
  Because either route changes the condition set this task depends on, it is surfaced as a
  non-blocking user decision rather than chosen here.

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

### Dispatch 31

- **`AUFix` is the wrong operator on the sliced side, and the inner eventuality-discharge step is
  existential.** The plan's STEP 5 names `AUFix.lfp G.verts G.succT isE isG` "for the inner
  eventuality-discharge step", and the plan's own Scope Hypothesis asks for `AUFix`'s binders to be
  read at implementation time. Read, they give a conclusion **stronger** than the hypothesis stated:
  `AUFix` supplies neither half here. `AUFix` is the *universal* `A[g U e]`; the outer condition is
  *existential*, and `A[g U e]` at a vertex says nothing about whether the particular walk the outer
  fixpoint is building ever delivers. The all-walks reading is moreover exactly the (C2') demand
  whose failure is why this subtree exists at all. So the inner operator is `EUFix`, the existential
  dual, written generically once. **`AUFix` is untouched and remains in use unchanged on the
  `Formula` side** — the decision removes nothing from the tree.
- **`succT` and `predT` are not mutual inverses, and no lemma pretends otherwise.**
  `prevTime (nextTime u) ≠ u` at the window's right edge, so `w ∈ succT v ↔ v ∈ predT w` is false.
  The adjointness the plan asks for is landed in its honest, *edge-level* form, with the
  time-matching conjunct as a hypothesis rather than a conclusion. Cross-checked against the
  `Formula` side: `SharingWitnessFamily.succF` / `predF` are built the same way and carry no
  adjointness lemma either. The negative is recorded in `Timed.lean`'s header so no later dispatch
  spends a run trying to prove it.
- **STEP 6c's design question was settled here, and the settling is that one of the two routes is
  unsound — not that one is merely preferable.** The eventuality-aware liveness fixpoint must take
  its inner reachability **inside the set being contracted** (the nested, Emerson–Lei shape). The
  cheaper-looking alternative — `fwdWalkable` membership plus a separate clause that every walkable
  position with a pending eventuality lies in `untlReach g e` — is **unsound**, because `untlReach`
  takes its reachability inside all of `verts` and so may certify a discharging path that leaves the
  set from which the walk can be continued forever; the round-robin construction then has nothing to
  concatenate. Recorded in the plan and the handoff so no dispatch spends a run on it.
- **The generic ν-iteration was generalized from a successor function to an arbitrary contraction,
  now rather than later.** Because the liveness fixpoint is nested, it is not of the form
  `EGFix.step succ` and could not be an `EGFix` instance. `Nu` was therefore extracted and `EGFix`
  re-expressed as its instance, which deleted `EGFix`'s six duplicated iteration lemmas and left
  every name `Computed.lean` consumes unchanged. Doing this inside the dispatch that identified the
  need keeps the refactor off the next dispatch's critical path.

### Dispatch 36

- **The indexing mismatch dispatch 34's handoff flagged is settled by re-indexing Φ to the combined
  periods, not by relating two indexings.** The decisive reason is that `Timed.lean`'s
  `prevTime_edge` folds by `G.NB`: an operator fixed for one `G.nb`-period constrains nothing about
  the fold `TailStable` exists to certify. Two further reasons: `L₀` must be readable off `G.liveT`,
  which is supported only on `G.winTimes`, and the re-indexed reference times *are* window times; and
  16.1's own module header already claimed the reference times "match the doubled window endpoints",
  which `-G.nb` / `-2 * G.nb` do not. Recorded as a deviation rather than absorbed.
- **`L₀` is a set of two-directionally live positions, and the transfer soundness was re-proved at
  that strength.** Defining `L₀` from `fwdLiveT` would have made the linchpin's `←` direction false,
  because `fwdLiveT` membership does not yield the bi-infinite run `FwdLive` demands. `G.liveT` is
  exact for `Live` in both directions, so `live_subset_stepBack` / `live_subset_stepFwd` were added
  alongside 16.1's `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` rather than replacing them.
- **The converse half was pursued to completion in this dispatch rather than deferred.** It was
  first scoped out — `Stable.lean` carried a SCOPE section naming the three-region run as a later
  obligation, and 16.2a was committed in that state — and then landed, so the intermediate commit is
  a genuine green checkpoint and not a retracted claim. The SCOPE section is now replaced by a
  statement of what *is* proved.
- **No strengthening of the demand was needed.** The plan's Contingency provides for a deeper `Φ`
  iteration or a type-recurrence cut if the fixture showed one application too weak. One application
  suffices, so that branch was not taken and the fixture was not relaxed.

## Plan Deviations

- **Phase 15.3 STEP 6d, altered (the bridge's time)**: the plan asks for
  `G.Live t p ↔ (p, s) ∈ G.liveT` "at a folded time `s`, with `exists_foldF` / `exists_foldB`
  supplying `s`". Landed as `live_iff_mem_liveT`, quantified over `s ∈ G.winTimes` instead, because
  the general-`t` form is not provable: `FoldF` and `FoldB` are disjoint away from the diagonal, so
  no single window time carries both half-line readouts at a time outside the window. The two fold
  existence lemmas are not consumed here.
- **Phase 15.3 STEP 6d, altered (the condition set)**: (C3b) `BoxLabelFaithful` is **added** to the
  condition set, which the plan's 6d entry did not anticipate; it is dispatch 33's recommended
  resolution (a), and it is consumed at exactly one place, `spliceWalkPos_coherent`'s box clause.
- **Phase 15.3 STEP 6d, altered (the "five fields are the eight readouts" claim)**: four of five, as
  dispatch 33 measured. `lab_sub`, `agrees`, `steps` and the non-box clauses of `coherent` are the
  readouts; `coherent`'s box clause is not a half-line fact at all.
- **Phase 15.3 STEP 6d, altered (the direction symmetry)**: the plan treats soundness and
  completeness symmetrically. Completeness factors into two independent halves; soundness factors
  into none. No `fwdLive_iff_mem_fwdLiveT` exists, and the reason is recorded at the plan's Phase 15
  heading so no later dispatch looks for one.
- **Phase 15's last verification bullet, altered (the method)**: the plan asks that `G.live` be
  "evaluated on a small concrete certificate". It is not evaluated; it is proved, by
  `Fixture.liveT_ne_empty_and_ne_verts`. Evaluation is infeasible for the reason recorded under
  Decisions, and the plan's own stronger preference — named lemmas over an evaluation, stated in
  `Fixture.lean`'s header for the same reason at 16.1 — is what was satisfied.
- **Phase 15.3 STEP 6c, altered (the inner test)**: the resolution block's
  `EUFix.lfp X G.succT (G.atPosT e) (G.atPosT g)` is replaced by the endpoint-relativized
  `EUFix.lfp X G.succT (Fair.inSet X (G.atPosT e)) (G.atPosT g)`, with `EUFix.lfp_mono_all` added to
  keep the outer contraction monotone. See Decisions; the unrelativized form does not support the
  round-robin at all.
- **Phase 15.3 STEP 6c, added**: `Glue`, an infinite-walk-from-blocks layer the plan does not name.
  The round-robin the plan *does* name cannot be stated without it, and it is generic.
- **Phase 15.3 STEP 6d, deferred**: blocked on the box-clause question above. Nothing stubbed, and
  the phase marker stays `[PARTIAL]` rather than advancing.
- **Phase 15's last verification bullet (`G.live` on a concrete certificate), still open**: it is now
  *stateable* — the computed object exists — but `Nu.gfp` iterates `verts.card + 1` times over a
  `Finset` of size `G.n * 2 ^ |closure|`, so whether a `decide`-based evaluation is feasible at all
  must be established before a run is spent on it. Flagged, not attempted.

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
- **(superseded at dispatch 31) Phase 15 remains PARTIAL.** As of dispatch 27, 15.1 and 15.2 were
  landed and 15.3 was not started; 15.3's first step depends on Phase 16's four-state fixture (see
  Decisions), so that was a genuine reorder rather than a deferral. As of dispatch 31, 15.3 STEPS 1-5
  and 6a, 6b are landed and STEPS 6c, 6d are open.

### Dispatch 31

- **STEP 5's `AUFix.lfp` prescription is SUPERSEDED, not skipped.** Landed instead: `EUFix`, the
  existential dual, written generically once in `Fixpoint.lean`. The plan's Phase 15 Scope Hypothesis
  is amended at its own heading with the stronger reading it asked for, and the two deferred
  `fwdLive` / `bwdLive` checklist items are annotated in place. `AUFix` is untouched.
- **STEP 4's "adjointness" is discharged in its edge-level form only**, because the mutual-inverse
  form is false; annotated at the plan's STEP 4 record with the `Formula`-side cross-check.
- **STEP 6 is PART-landed**: 6a (the fold relation) and 6b (a walk read as a ℤ-indexed half-run) are
  complete; 6c (the eventuality-aware fixpoint) and 6d (the position-level splice and the equality
  with `Live`) are open, with nothing stubbed for either and no `sorry` anywhere.
- **Phase 15's last verification bullet is still open and is still 15.3's gate.** `G.live` evaluated
  on a concrete certificate, confirmed neither empty nor the whole position space, needs 6c/6d's
  computed object; only its two halves exist so far. `Fixture.cert` remains the intended subject.
  This is recorded as an open gate rather than a met one.
- **Phase 16, AMENDED at its heading, not executed.** The job of `Φ_back`, `Φ_fwd`, `TailStable`,
  `tailStable_iff_window` and `exists_tailStable_repr` was reframed: they are no longer what makes
  the liveness computation finite, they are what certifies the **wrap is faithful**. Statements
  unchanged. The four-state fixture was promoted to a prerequisite of 15.3.

### Dispatch 36

- **Phase 16, `L₀`/`R₀` bullet** altered: landed as `liveAt` evaluated at two reference times, and
  the Φ operators were **re-indexed to the combined periods** so those reference times are the
  window's own endpoints. The bullet's "computed from the window together with the forward tail" is
  satisfied by `liveAt`'s definition from `G.liveT`, which is the window-and-fold object.
- **Phase 16, `TailStable` / `tailStable_iff_window` bullet** altered: the definition is verbatim as
  asked (`Φ_back L₀ = L₀ ∧ Φ_fwd R₀ = R₀`) and `Decidable` is synthesized, not asserted. The
  biconditional is landed **and** its two halves are separately named, so both options the bullet
  offers are taken. Two corrections to the bullet's own wording: it is about two-directional `Live`
  rather than "the true forward-live sets" (the forward-only version is false in the `←` direction),
  and the period is the combined `G.NB` / `G.NF` rather than `|back|` / `|fwd|`.
- **Phase 16, `exists_tailStable_repr` bullet** deferred to sub-phase 16.2c. Nothing is stubbed for
  it; the declaration does not exist.
- **Phase 16, fixture-re-presentation bullet** deferred to sub-phase 16.2c, with the
  `exists_tailStable_repr` it is the worked example of.
- **Phase 16, module-docstring bullet** discharged in full: what tail-stability is, why it is
  required (the fixture), that it costs the checker exactly one `Φ` application per side beyond the
  Phase 15 fixpoints, and that a search on the paired repository's side must re-present rather than
  reject — the last flagged there as argued but not yet proved, since its proof *is*
  `exists_tailStable_repr`.
- **Phase 16's Scope Hypothesis** is confirmed, and not trivially: `iterBack_L₀` is *not* immediate
  from the equation, because the reference time moves one period left with each application and the
  iterate has to be transported by `iterBack_shift`, which needs slice periodicity at a multiple of
  the combined period.

## Verification

### Dispatch 34 (the current end state)

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2797 jobs**, **zero** `error:` and **zero** `warning:` lines. Run twice, once per green sub-step.
  Tier 3 confirmed: the `.olean` of `Bridge`, `Basic` and `Fixture` are each newer than their
  sources.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1**, identical to `main`'s — the pre-existing
  `FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal`, untouched.
- Axiom count: **14**, identical to `main`'s — unchanged. No axiom was added.
- `#print axioms`: all **48** new declarations audited by name in one pass — every one within
  `[propext, Classical.choice, Quot.sound]`. Zero unknown-constant errors, no `sorryAx` anywhere.
- Anti-goals checked explicitly: no `[Fintype TPos]` and no `Fintype` on any carrier; **both**
  directions of the bridge landed as separately named theorems, so Phase 17 cites one and Phase 18
  the other; no declaration added cites a probe, by path or by declaration name, per the
  `.decisions.json` C9 ruling; the only cardinality mentioned anywhere is `V.card`, a `Finset`
  iteration's termination measure.
- **The same worktree `.lake` inconsistency recurred and was repaired the same way.** Eight modules'
  `<Module>.olean.hash` disagreed with their own `<Module>.trace`'s expected `outputs.o` hash.
  Deleting those eight modules' outputs inside the worktree (hardlinks; the main tree untouched) and
  rebuilding fixed it. This is now the second consecutive dispatch to hit it on a freshly provisioned
  worktree, so treat it as the **expected** first step rather than as a rare hazard. Note also that
  the hash comparison must strip the `.olean` suffix from the trace's `outputs.o` entry, which is a
  one-element list of `<hash>.olean`, before comparing — a naive comparison reports every module as a
  mismatch.
- Tests: **N/A** — no test target covers this subtree yet; Phase 21 owns the gates.
- Files verified: **Yes**.

### Dispatch 33 (superseded as the end state; retained as the record)

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2796 jobs**, **zero** `error:` and **zero** `warning:` lines. Tier 3 confirmed: the `.olean` of
  `Fixpoint`, `Computed`, `LiveFix` and `PlusSlicedCertificate` are each newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1**, identical to `main`'s — the pre-existing
  `FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal`, untouched.
- Axiom count: **14**, identical to `main`'s — unchanged.
- `#print axioms`: all **116** declarations of `Fixpoint.lean` and `LiveFix.lean` audited by name in
  one pass — **60 depend on no axiom at all**, 6 on `[propext, Quot.sound]`, 50 within
  `[propext, Classical.choice, Quot.sound]`. Zero unknown-constant errors, no `sorryAx` anywhere.
- Anti-goals checked explicitly: no `[Fintype TPos]` and no `Fintype` on any carrier; **both**
  directions of every characterization (`fwdLiveT_fixed` **and** `fwdLiveT_greatest`, and the backward
  pair); no declaration added mentions `winLo` or `winHi`; the only cardinality mentioned anywhere is
  `V.card`, a `Finset` iteration's termination measure.
- **One environment repair was required and is recorded**: the worktree's seeded `.lake` carried eight
  modules whose `<Module>.olean.hash` disagreed with their own `<Module>.trace`'s expected
  `outputs.o` hash, so lake served a **stale** `Timed.olean` and reported `succT` "not in the
  environment" — a symptom indistinguishable from a source error. Deleting those eight modules'
  outputs inside the worktree (hardlinks; the main tree untouched) and rebuilding fixed it. Check this
  first on any "unknown constant that plainly exists" error in a dispatch worktree.
- Tests: **N/A** — no test target covers this subtree yet; Phase 21 owns the gates.
- Files verified: **Yes**.

### Dispatch 29 (superseded as the end state; retained as the record)

- Build: **Success**. Full `lake build`, guarded and detached (`--no-share`): `exit_status=0`,
  **2791 jobs**, **zero** `error:` and **zero** `warning:` lines. Run four times over the dispatch,
  once per green sub-step, clean each time. Tier 3 confirmed: the `.olean` of `Fixture`, `Stable`,
  `Window` and `Timed` are each newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over all four resolved source roots).
- Vacuous count: **1**, identical to `main`'s — pre-existing, not introduced here.
- Axiom count: **14**, identical to `main`'s — unchanged.
- `#print axioms`: the four new modules carry **150 declarations, 149 of them public, and all 149
  were audited by name** with zero unknown-constant errors — nine depend on no axiom at all, one on
  `[propext]`, one on `[propext, Quot.sound]`, and 138 on
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx` anywhere in the output. The single
  `private` helper is not nameable from outside and is covered transitively by its users.
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
### Dispatch 31 — measured, not asserted

- **Full guarded, detached, `--no-share` `lake build` after every sub-step**, the last one at
  `exit_status=0`, **2795** jobs, **zero** `error:` and **zero** `warning:` lines. Read off the
  three-tier bar: the guard's own exit code (Tier 1), the success line with zero `error:` over both
  captured streams (Tier 2), and an `.olean`-newer-than-source check for **every** module this
  dispatch touched — `Timed`, `Fixpoint`, `Computed`, `Fold`, `Unroll`, the aggregator and
  `FormalSystem.lean`, all seven confirmed fresh (Tier 3).
- `lean-sorry-census.sh` over all four resolved source roots: **`sorry_count: 0`**, empty inventory.
- **Vacuous census: 1, unchanged from `main`.** The single match is
  `FormalSystem/Examples/TemporalStructures.lean:495`'s `int_domain_universal`, pre-existing and
  untouched — a genuine theorem whose proof happens to be `trivial`, not a placeholder.
- **Axiom census: 14, unchanged from `main`.** No `axiom` was added.
- **`#print axioms` on every declaration of the five new/extended modules, by name — 131 in all,
  zero unknown-constant errors and no `sorryAx` anywhere.** Three depend on no axiom at all, five on
  `[propext, Quot.sound]`, and the remaining 123 within
  `[propext, Classical.choice, Quot.sound]` — the same closure the rest of the subtree already sits
  in. The two `Classical.choice` uses that are genuinely new are
  `EGFix.exists_walk_of_mem_gfp` (a `choose` over the fixpoint's subtype, which is what turns
  membership into an actual infinite walk) and its `Computed.lean` specializations.
- **Each module's first build result, recorded because it is evidence about the plan's own budgeting.**
  STEP 4 (`Timed.lean`) and 6a (`Fold.lean`) each compiled on the **first** attempt with zero errors
  and zero warnings — 6a is the grounding addendum's "budget this layer as transcription" prediction
  coming out right, and no lemma there needed an argument the `Formula`-side source did not need. 5a
  needed two `change`-for-`show` fixes and an `omit`; 6b needed `ring` → `omega` (see the hazard).
- **`--no-share` was respected on every build**, and every build ran detached through the guard.
- **Gate state unchanged: `check-module-invariants.sh` was again NOT run to completion**, for the same
  structural reason — it exceeds ten minutes and Phase 21's gate must run from the main tree with no
  nested checkout live, which a dispatch worktree violates by construction. None of the three
  pre-existing failing groups is introduced or worsened here, and **C9 adds no new occurrence**: none
  of the five modules cites a probe, by path or by declaration name, which is what the user's relayed
  ruling requires.
- **Plan-compliance spot-check: FAILED, and the failure is expected at this point in the plan.** Nine
  of the eleven names in the plan's `Goals` block resolve to landed declarations; the two that do not
  are `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and
  `exists_plusSlicedCertificate_of_tailStable_countermodel`, the task's two headline theorems, owned
  by Phases 19 and 20, which are `[NOT STARTED]`. Nothing regressed and nothing is stubbed for them;
  the check is reported as failing because it is a check on the *task's* goals, and the task is at
  phase 15 of 21.

### Dispatch 36 — measured

- **Build**: Success. Four full guarded, detached, `--no-share` `lake build` runs over the whole
  library — one per green sub-step plus the final docstring pass — each `exit_status=0`, **2797**
  jobs, **zero** `error:` and **zero** `warning:` lines. `.olean`-newer-than-source confirmed for
  `Stable` and the aggregator. Two scoped builds of `…PlusSlicedCertificate.Stable` were used during
  development; the full run is what the record rests on.
- **Sorry count**: 0 (`lean-sorry-census.sh` over all four resolved source roots).
- **Vacuous count**: 1 — unchanged from `main`, the pre-existing
  `FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal`, a genuine theorem whose
  proof is `trivial`.
- **Axiom count**: 14 grep hits, unchanged from `main`, and **none is an `axiom` declaration** — all
  fourteen are wrapped doc-comment lines that happen to begin with the word "axiom" at column 0,
  verified by reading each. `git diff` adds zero `^+axiom ` lines.
- **Axiom audit by name**: all **89** public declarations of `Stable.lean` checked with
  `#print axioms`; every one within `[propext, Classical.choice, Quot.sound]`; zero unknown
  constants, no `sorryAx`.
- **`Decidable` synthesis**: `example (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStable :=
  inferInstance` elaborates, as Phase 16's Verification block requires — the instance is registered
  and found, not asserted.
- **`exists_tailStable_repr` states no bound** — vacuously, since it does not exist yet; the
  Verification block's reading check falls to 16.2c.
- **Plan compliance spot-check**: 9 of the 11 names in the plan's `Goals` block resolve (6 by the
  contract's grep; `PlusGraphPath`, `PlusSlice` and `PlusSlicedCertificate` are `structure`
  declarations the grep pattern does not cover, confirmed by a second grep). The 2 that do not —
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and
  `exists_plusSlicedCertificate_of_tailStable_countermodel` — are this task's two headline theorems,
  owned by Phases 19 and 20, both `[NOT STARTED]`. The plan names no replacement or supersession
  target, so the integrity half of the check is vacuously clean. This is the same reading as at
  dispatches 33 and 34 and is expected at this point in the plan.

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

- **(dispatch 34) Liveness is decidable at a window time, so Phase 17's existential and universal
  clause groups are now stateable.** `decidableLive` is what `Basic.lean`'s own confirmation block
  said was missing: "the other two groups — existential-from-liveness, and universal — need Phase
  15's computed liveness and are not stateable yet". They are stateable now.
- **(dispatch 34) Phase 17's `Certifies` gains a clause.** (C3b) `BoxLabelFaithful` joins `BiSerial`,
  `BoxFaithful` and `Target` in the condition set, and `boxLabelFaithful_iff_window` is the reduction
  the checker evaluates it by. Phase 19 owes the clause for the certificate it builds from a
  countermodel, and `plusBox_const` is what discharges it.
- **(dispatch 34) Phase 16.2's `L₀` / `R₀` now have something to be.** `Stable.lean`'s header says
  `TailStable` waited on "the computed liveness `Finset` that sub-phase 15.3 has yet to build". It is
  built, and `liveT` together with `live_iff_mem_liveT` is what `tailStable_iff_window` will bridge
  from.
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

### Dispatch 31

- **The sliced side now has its own generic fixpoint library**, `Nu` / `EGFix` / `EUFix`, stated at an
  arbitrary vertex type with no `Fintype` and no formula anywhere. Anything later in this repository
  that needs an existential greatest fixpoint or an existential until on a finite graph can cite it
  rather than transcribe `AUFix` a second time.
- **The existential fair-path half the plan called new work now exists as a proved object**, with
  membership equivalent to the walk's existence in both directions, so Phase 18's soundness proof and
  Phase 19's completeness proof each have one direction to cite instead of a shared obligation.
- **`Fold.lean` and `Unroll.lean` together discharge the wrap-faithfulness plumbing for whatever
  liveness object 6c settles on.** They are stated about an arbitrary walk in either graph, not about
  a particular fixpoint, so 6c changing its contraction does not invalidate them.
- **`AUFix`'s role in the tree is now documented rather than assumed.** `Fixpoint.lean`'s header
  states why the universal operator is right for the `Formula` side's (C2') and wrong here, which is
  the kind of claim that was previously only implicit in the two subtrees' shapes.

## Follow-ups

- **NEXT (dispatch 34's seam): sub-phase 16.2**, and it is the last thing between the tree and the
  checker. Four pieces, in dependency order: `L₀` / `R₀` off `liveT`; `TailStable` as
  `Φ_back L₀ = L₀ ∧ Φ_fwd R₀ = R₀` with its `Decidable` instance; `tailStable_iff_window`, which the
  plan calls "the lemma the whole design rests on" and requires as a biconditional or as two named
  implications; and `exists_tailStable_repr`, the re-presentation lemma with a frame isomorphism.
  **Budget the last two as the hard ones** and do not write a `Stable.lean` extension whose headline
  declaration is absent — the plan criticizes that shape twice already (15.1's `Live.lean`, 16.1's
  `Stable.lean`), and both times the right response was to split the sub-phase rather than to stub.
  `exists_tailStable_repr` is the only piece requiring a *new certificate construction* plus a frame
  isomorphism, so it is the natural split point if 16.2 overruns one run.
- **(dispatch 34) The fixture doubles as 16.2's worked example, and `not_mem_liveT_neg_two` is
  already half of it.** The plan's own bullet asks that `Fixture.cert` be proved **not** tail-stable
  as presented and that its re-presentation be exhibited. Its liveness asymmetry at `-1` versus `-2`
  is exactly the failure of one-period stability, and the two gate lemmas landed here are the
  computed-side facts that argument needs.
- **(dispatch 34) (C3b) must be added to Phase 17's `Certifies` and discharged in Phase 19.** It is
  a condition on the certificate, not a fact about it, so it is an obligation for whoever constructs
  a certificate from a countermodel. `plusBox_const` is what discharges it, and
  `boxLabelFaithful_iff_window` is what makes a checker able to evaluate it.
- **NEXT (dispatch 29's seam, now closed): sub-phase 15.3 STEP 4**, the timed graph `succT` / `predT`. All four
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

### Dispatch 31

- **STEP 6c, the eventuality-aware liveness fixpoint, is the next action** and its design is settled
  (nested, with the inner reachability inside the set being contracted). Every prerequisite is landed
  and named in `handoffs/phase-15-handoff-20260930T164815Z.md`.
- **The round-robin concatenation is the single largest remaining piece of STEP 6, and it has no
  counterpart in this tree.** Finitely many eventualities, each deliverable from every vertex of the
  fixpoint without leaving it, spliced in rotation into one infinite fair walk. The `Formula` side
  never needed it because its demand is universal over threads. Write it **generically**, at `Nu` /
  `EUFix`'s level, not at the certificate — and do **not** budget it as transcription.
- **`Live.lean`'s `splice` is not reusable for 6d.** It takes two `LabRun`s, not two half-lines, so it
  justifies `live_iff` and nothing more. 6d's splice is at *position* level and is new, though small:
  `st t := if t₀ ≤ t then (fwdWalkPos …).1 else (bwdWalkPos …).1`, with the five `LabRun` fields
  supplied by the eight readouts `Unroll.lean` landed.
- **`fwdWalkable` / `bwdWalkable` must not be read as liveness by any downstream clause.** They are
  plain `EG ⊤` and are correct as that; `fwdLiveT ⊆ fwdWalkable` will be a one-line consequence, not
  an equality.
- **Two new environment hazards worth carrying**: the `show` tactic is linted in this repository when
  it changes a goal definitionally (use `change`), and a `/-- … -/` doc comment cannot precede
  `namespace` or `variable` (use `/-! … -/`). Both cost a build round here.

### Dispatch 36

- **Sub-phase 16.2c is what remains of Phase 16**: `exists_tailStable_repr`, and `Fixture.cert` shown
  not tail-stable together with its re-presentation as that lemma's worked example. `Frame.lean` is
  where the frame isomorphism has to land. Do the fixture half first — it is small, it needs nothing
  from `exists_tailStable_repr`, and it is the cheap confirmation that `TailStable` is not vacuous.
- **The one hazard 16.2c must decide correctly**: `G'.liveT` is not `G.liveT`. A re-presented
  certificate has a different `NB` / `NF` / `NM`, hence a different `winTimes`, `verts`, fold and
  fixpoint, so the computed sets do not transfer. Route the argument through the declarative `Live`
  (which the frame isomorphism preserves) and re-enter the computed side at the end via
  `mem_liveAt_iff_live` on `G'`.
- **Until 16.2c lands**, `TailStable`'s harmlessness is argued but not proved, and
  `TailStable`'s docstring says so. A reader should not yet take "tail-stability narrows the
  presentations a checker accepts and not the frames a countermodel may have" as a theorem.
- **Phase 17 can be written against what is landed**: its universal side cites
  `mem_L₀_of_live_tail` / `mem_R₀_of_live_head` (or `live_ref_of_live_tail` / `live_ref_of_live_head`)
  and its existential side `live_of_mem_L₀_tail` / `live_of_mem_R₀_head`;
  `liveAt_tail_eq_L₀` is the `Finset` form. Nothing in Phase 17 needs `exists_tailStable_repr`, which
  is about which certificates exist and not about what the checker decides.

## References

- `specs/703_lplus_compression_and_completeness/handoffs/phase-15-handoff-20260930T175901Z.md`
  — dispatch 34's resume point: sub-phase 16.2's four pieces with a recommended split, and the
  carried-forward environment hazards.
- `specs/703_lplus_compression_and_completeness/handoffs/phase-15-handoff-20260930T181500Z.md`
  — dispatch 33's resume point: STEP 6d's blocker, its two resolutions, and 17 environment hazards.
  The blocker is now closed; the resolution is recorded under Decisions.
- `specs/703_lplus_compression_and_completeness/.dispatch/34.md` — this dispatch's context.

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
- `specs/703_lplus_compression_and_completeness/handoffs/phase-16-handoff-20260930T184127Z.md` —
  dispatch 36's handoff: sub-phase 16.2c as the resume point, what it can build on, the one hazard
  specific to it, and the carried-forward environment hazards (nineteen from earlier dispatches plus
  four new ones)
- `specs/703_lplus_compression_and_completeness/.dispatch/36.md` — dispatch 36's context
