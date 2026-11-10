# Implementation Summary: Task #838

- **Task**: 838 - Two-sided open core: attack the depth-`0` cell obligation through a `(K2)`-level pigeonhole over region starts on the pin-free side, or restate the obligation under a new name
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-03T17:42:40Z
- **Completed**: 2026-11-10T07:30:00Z
- **Effort**: ~2.5 hours of wall clock over seven landed phases (Phase 5's earlier blocker withdrawn as mis-anchored and the phase then landed)
- **Dependencies**: None at the `state.json` level. Parent: the task whose pump layer is this round's entire input. The ladder realization theorem's depth-`0` induction is the downstream consumer; nothing here edits any of its artifacts
- **Artifacts**: plans/01_pin-free-pigeonhole-open-core.md, prototype/pin-free-side.lean, prototype/spanning-divisibility.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Route (a) of the two named open routes was taken: a `(K2)`-level pigeonhole over region starts
exploiting the pin-free side both refuting objects carry. Its three provable pieces landed — the
pin-free dichotomy, the pigeonhole over the pins, and the exponential `(K2)` bound — and the
decision gate they fed returned **FAIL** with a compiled refuting object: `(K1)` does not
constrain the length of a type-respecting block that spans a pin. Phase 5's earlier blocker was
then **withdrawn as mis-anchored** — the goal it quoted carried the anchor VALUE at the hardwired
anchor POSITION `0`, while that anchor is a free argument discharged existentially, and the
re-anchored deletion is landed — and the phase landed the slack accounting instead: the regime's
baseline is free at amount `0` and the two transports around it are exact, so the regime is not
itself a source of slack. Nothing weakened was landed under the reserved name or under the
planned new one, and the depth-`0` obligation remains neither proved nor refuted.

Phase 7 then landed the cell level as a new leaf module `LadderCell.lean`: the UPWARD cell
inclusion along the COMMON-SHIFT chain (the sub-regime the landed register-held inclusion's
docstring names and does not state), and the arithmetic case split that says which sub-regimes a
`kappa`-collision can occupy. The inclusion landed at its pinned Challenge signature with no
weakening; the case split landed with THREE branches rather than the planned two, because the
planned two-branch shape is not derivable from the destructors it was to be proved from — the
gap coordinate clips at `B`, and a collision saturated at that clip on both sides satisfies
neither alternative. That is recorded as a compiled refutation, not as prose.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` — NEW, 261 lines,
  certificate-free under the pump layer's own grep and importing it alone. Five declarations:
  - `idle_of_idle_of_no_pin_below` — pending is downward closed below a pin-free position.
  - `pend_past_or_idle_of_no_pin_below` — the PIN-FREE DICHOTOMY: below a position carrying no
    pin, the past is either uniformly idle or uniformly pending from some position down.
  - `pendPast_or_cntAt_le_nxtAt_succ` — its counter-level form: every pending position of a
    ladder path has either a uniformly pending past (the pin-free side the upward cell inclusion
    already consumes) or a countdown at most its register plus one (the backward window).
  - `exists_pinTypeBlock_of_budget_lt_pins` — the PIGEONHOLE OVER REGION STARTS: more than twice
    the type-pigeonhole budget of pins in a window forces a type-respecting block SPANNING a pin.
  - `exists_spanningBlock_of_pins_below` — that tuple in the refuted condition's own shape.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — `section Slack` gained the
  slack accounting: `hasForwardSlack_zero`, the FREE BASELINE (`HasForwardSlack g z 0 (nxtAt g z)`
  on every ladder path, from `nxtAt_lipschitz_two_sided` alone — the regime becomes a constraint
  only at a positive amount), and `hasForwardSlack_raise_of_zero`, its composite with
  `hasForwardSlack_raise` (the raised path carries slack `d · l` from no slack hypothesis at all),
  whose docstring states the accounting in full: baseline `0` free, raise `+ d · l` exact,
  deletion `− l` per step exact, hence no composition yields slack exceeding the total raised
  amount and a raise-then-delete round trip at `z` is net zero. No theorem quantified over
  compositions was written — the plan prohibits one, and the two exact transports already say it.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — `two_pow_card_prodState_le_Tc`
  in `section Budget`: `(K2)` bounds `T_c` below by `2 ^ Fintype.card (ProdState Q φ)`, an
  EXPONENTIAL in the product carrier's cardinality, which is the quantity a pigeonhole over the
  region starts of a doubling chain consumes. Plus one docstring sentence.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` — one import line each.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the new module's inventory row and
  description, the `LadderChain.lean` row's new clause, and two new narrative paragraphs: the pin
  layer and what it settles, and `(K1)`'s non-constraint of a spanning block's length.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — regenerated
  inventory blocks (FOUR blocks move for a new `RaySummary` module, not three).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — three new `(W)` blocks pinning the
  five new declarations' axiom profiles, and the obligation block's narrative brought current.
- `typst/generated/status.typ` — regenerated on each phase commit (see Decisions).
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean` — NEW, 474
  lines. `gB_pinFree_below`, `gC_pinFree_above`, `tightChain_pin_count_ge`.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` — NEW,
  the gate: `SpanningBlockLengthDvd`, `spanning_walk_not_pending`,
  `spanningBlockLengthDvd_refuted`.

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — NEW, 299 lines, importing
  `LadderChain.lean` alone. Four declarations:
  - `exists_ladderPath_through_common_shifted_of_pend_past` — the regime-A assembly with the
    register CARRIED along the shift rather than held. The walk and every countdown are the
    landed path's; only the deadline register is rebuilt, by the freed-anchor lift
    `exists_ladderPath_of_walk_nxt_at` at `z` with the anchor value `nxtAt g z + m · (P + 1)`.
  - `cellAt_subset_of_common_shift_of_pend_past` — the UPWARD cell inclusion along the
    common-shift chain, at the pinned Challenge signature token for token. One direction only.
  - `kappa_collision_regimes` — the collision case split over named arithmetic facts, THREE
    branches: equal register `n = n'` (with the countdowns congruent mod `P + 1` and the two
    counter regimes segregated by `clipIdx_regime_of_eq`), common shift of both coordinates by
    the same multiple of `P + 1`, and a SATURATED gap coordinate at both pairs on the same side
    of the window.
  - `kappa_collision_two_regimes_refuted` — the compiled refutation of the two-branch form as a
    consequence of the three destructors together with `(K4)`'s `2 ≤ B`, at `Tc = Tn = P = 0`,
    `B = 2` and the pairs `(0, 2)`, `(0, 3)`. Scoped to that derivation: it asserts nothing about
    the two-branch form under full `ParamsOk`.
- `FormalSystem.lean`, `FormalSystem/Metalogic/Decidability/RaySummary.lean` — one import line
  each for the new module.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/README.md`, `README.md` — regenerated inventory blocks plus the hand-written
  description cell for `LadderCell.lean`.
- `typst/generated/status.typ` — regenerated counts (the pre-commit sync gate requires it once a
  live `.lean` file is added).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — a new requirement-(W) cell-level
  prose block and three axiom-profile pins; the file's recorded `longFile` ceiling raised from
  2,100 to 2,200 to admit them.

## Decisions

- **The decision gate's verdict is FAIL, and refuted rather than merely unproved.** `(K1)`'s two
  cycle-length conjuncts both carry `∀ i, pend (f i) = true` on the closed walk they quantify —
  the walk is PENDING THROUGHOUT — and a spanning block's induced walk is idle at the pin strictly
  inside it (`spanning_walk_not_pending`); `objCycleLens` additionally bounds the length by
  `Fintype.card Q`, which a pin-window pigeonhole does not respect; and `satPeriod` is a datum of
  `step`, `lab` and `φ` alone, not quantified over block lengths. The refuting object is the
  ALTERNATING path — idle at every even position, pending at every odd one — which for a stab-free
  atomic closure at the periodicity fixpoint's own outputs carries a type-respecting block of
  EVERY even length with a pin strictly inside it, so the length `2 · (P + 1)` cannot divide
  `P + 1`.
- **The closing phase was escalated, not substituted.** A strictly weaker directed INCLUSION was
  deliberately NOT landed under the planned name `cellLE_zero_const_of_kappa_eq_of_pinFree`: the
  planned statement concludes cell EQUALITY, and a same-named weaker statement is the defect
  `rules/plan-compliance.md` exists to catch. The reserved name `cellLE_zero_const_of_kappa_eq`
  stays claimed by nothing.
- **The pigeonhole is restricted to the even-indexed pins**, as planned, and the pinned constant
  `2 · budget + 2` was not loosened. The restriction buys the two-apart separation a third pin
  strictly inside the block needs, and nothing cheaper supplies it.
- **Only the backward-shaped spanning-block corollary was landed.** The pigeonhole's own
  `s 0 < u` already IS the forward condition's `z < u` at `z := s 0`, so a forward corollary
  would restate it.
- **The sibling prototype is not importable** — a standalone file under `specs/**` is not a module
  on the Lake library path — so the object, the chain and both witnesses are re-declared verbatim
  in both new prototypes.
- **Every phase commit carries a regenerated `typst/generated/status.typ`.** A commit touching
  `FormalSystem/**/*.lean` is refused by the typst-sync pre-commit gate without it; the plan's
  per-phase `Files to modify` lists do not name that file.

- **Phase 7: reuse the landed assembly rather than re-derive the duplication.** The plan's route
  for the common shift was the landed register-held iterated duplication read through
  `exists_ladderPath_of_walk_nxt_at` with the anchor raised. That was taken in the cheapest
  faithful form: call the landed regime-A assembly for the walk and the countdowns, then re-run
  ONLY the register rebuild at the freed anchor. The anchor clause closes from the widened window
  alone — the raise pushes every pin of the raised path past `z + cntAt g z + m · (P + 1)`, while
  the pending-forever gap `n + 2 ≤ c` bounds the register at `z` by `cntAt g z − 2`, leaving
  exactly `m · (P + 1)` to spare in both directions — so no new pump construction was needed and
  the phase's escape hatch (close `[BLOCKED]` if the clause does not close) was not used.
- **Phase 7: state the collision split honestly, and compile the refutation of the planned
  shape.** Rather than restate the planned two-branch disjunction as if it followed, the
  three-branch form was landed and the two-branch form refuted by a compiled object, in this
  repository's own idiom. The Challenge block had explicitly left this statement unpinned as a
  composite whose exact shape is fixed by the transports it composes, which is the latitude used.

## Plan Deviations

- **Phase 1** Scope Hypothesis predicted three generated inventory blocks would move; FOUR did
  (`FormalSystem/README.md` is a fourth consumer of a `RaySummary` module's line count). A wider
  but harmless outcome; no file outside the declared list changed.
- **Phase 1**, `pendPast_or_cntAt_le_nxtAt_succ`: the pin-free branch consumes the dichotomy's
  uniformly-idle disjunct (refuted at the position itself) and reaches the uniformly-pending
  conclusion through the shared single-step helper `idle_of_idle_of_no_pin_below` that the phase's
  Scope Hypothesis budgets, because the dichotomy's existential disjunct names SOME `v ≤ p` rather
  than `p` itself.
- **Phase 2**, the corollary: one, backward-shaped, for the reason recorded under Decisions.
- **Phase 3**, the prototype landed at 474 lines against a 120-220 estimate — the plan's own
  recorded wider outcome, since the objects were re-declared in full. `tightChain_pin_count_ge`
  routes through the chain's register tightness and the landed backward window rather than by
  extracting a region index from the chain's idle predicate.
- **Phase 4**, the PASS-branch task is skipped: the gate returned FAIL.
- **Phase 5**'s earlier `[BLOCKED]` record is WITHDRAWN as mis-anchored, and the phase is
  `[COMPLETED]`. The withdrawal is recorded in the plan file's Phase 5 body and in the issue log
  as a `win`, not back-edited out.
- **Phase 5**, `hasForwardSlack_raise_of_zero` placement: after `hasForwardSlack_raise` rather
  than beside `hasForwardSlack_zero`. The composite consumes that lemma, so the plan's two
  placement sentences read literally would forward-reference it; the first scoped build failed
  with `Unknown identifier hasForwardSlack_raise`. It remains inside `section Slack` as specified.
- **Phase 5**, the axiom-test pin: written to the MEASURED profile `[propext, Quot.sound]`,
  strictly less than the standard profile the plan predicted, because
  `nxtAt_lipschitz_two_sided` consumes no choice. The plan's criterion reads “or less”, and the
  test block's narrative line states the lesser profile explicitly rather than claiming the
  standard one.
- **Phase 5** touched three files beyond its enumerated list — the generated inventory blocks in
  two `README.md` files and the root `README.md` — plus `typst/generated/status.typ`. All four are
  line-count regenerations that this phase's 40 added library lines made stale, each prescribed by
  the gate that detected it (`check-module-invariants.sh --emit-inventory`,
  `typst-sync-check.sh --fix`).
- **Phase 5**'s criterion `grep -cE 'sorry|…'` on `LadderChain.lean` reports 1, not 0 — unchanged
  from HEAD. The single match is a pre-existing DOCSTRING sentence (“is not a disguised `sorry`”),
  not a declaration; `lean-sorry-census.sh` reports `sorry_count: 0` over every source root.

- **Phase 7**, `kappa_collision_regimes`: altered — landed as a THREE-branch disjunction, not
  the planned two. The planned shape (equal register OR common shift) is NOT a consequence of the
  three named destructors plus `(K4)`'s `2 ≤ B`: `clipIdx` clips the gap at `B`, so a collision
  whose gaps are both saturated at that clip on the same side of the window satisfies neither
  alternative. `kappa_collision_two_regimes_refuted` is the compiled refutation at
  `Tc = Tn = P = 0`, `B = 2` and the pairs `(0, 2)`, `(0, 3)`. The statement was explicitly
  unpinned in the Challenge block, so no pinned signature was weakened; the consequence for the
  plan is that Phase 9 must dispatch or exclude the third branch, which it does not currently
  budget for.
- **Phase 7** Scope Hypothesis predicted six or seven files; nine changed. The root `README.md`
  inventory totals block is a FOURTH generated consumer, and `typst/generated/status.typ` is a
  fifth derived artifact the pre-commit sync gate requires once a live `.lean` file is added.
  Wider but harmless; no existing proof changed (`git diff -U0` on `LadderChain.lean` reports
  zero declaration lines touched).
- **Phase 7** added a THIRD axiom pin beyond the plan's "both new theorems" — the refutation
  object — because it is the evidence for the three-branch shape and belongs in the ledger beside
  what it justifies. Additive, not a substitution.

## Verification

- Build: Success. Unscoped full `lake build` through the build guard reports `exit_status=0`,
  zero `error:` across both captured streams, and `.olean` newer than source on every module this
  task touched.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 0.
- Axiom count: unchanged — no `^axiom ` line added anywhere.
- Axiom profiles: all seven new library declarations and all five new prototype headlines carry a
  subset of `[propext, Classical.choice, Quot.sound]`; no `sorryAx` anywhere.
  `hasForwardSlack_zero` is strictly below that profile at `[propext, Quot.sound]`.
- Tests: `BimodalTest.Metalogic.KTypeSummaryAxiomTest` builds green with all nine new pins.
- `LadderChain.lean` is 2,267 lines against an unbumped `longFile` baseline of 2,300.
- Gates: `check-module-invariants.sh --emit-inventory --check` exit 0;
  `check-task-references.sh --quiet` exit 0 on every changed non-`specs/**` file;
  `check-evidence-probes.sh` and `verify-deploy.sh` results recorded in the Phase 6 handoff.
- Certificate-freedom grep returns no match on `LadderPin.lean`.
- Both prototypes compile standalone through the build guard with zero errors and zero
  `declaration uses 'sorry'`.
- Files verified: Yes.

### Phase 7 (dispatch 6)

- Build: Success. Unscoped full guarded `lake build` reports `exit_status=0`, zero `error:` and
  zero `warning:` across both captured streams, 2,969 jobs, and `LadderCell.olean` newer than
  `LadderCell.lean`. The three covering scoped builds (`… LadderCell`, `… FormalSystem`,
  `… BimodalTest.Metalogic.KTypeSummaryAxiomTest`) each exit 0.
- Sorry count: 0. `lean-sorry-census.sh --cross-check` over the resolved source roots reports
  `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Vacuous count: 0 on `LadderCell.lean`. The one repo-wide match of the vacuity grep
  (`FormalSystem/Examples/TemporalStructures.lean:495`, a domain-membership theorem whose goal
  reduces to `True` on `Int`) is pre-existing and untouched.
- Axiom count: 14, unchanged — no `^axiom ` line added.
- Axiom profiles: `cellAt_subset_of_common_shift_of_pend_past`,
  `exists_ladderPath_through_common_shifted_of_pend_past` and `kappa_collision_regimes` carry the
  standard `[propext, Classical.choice, Quot.sound]`; `kappa_collision_two_regimes_refuted` is
  strictly below it at `[propext, Quot.sound]`. No `sorryAx`.
- `cellAt_subset_of_common_shift_of_pend_past`'s signature matches the Challenge block token for
  token, modulo the block's own stated ASCII rendering.
- Reserved name: 10 occurrences of `cellLE_zero_const_of_kappa_eq` repo-wide, every one on a
  docstring or prose line; zero claimed by a `theorem`, `def` or `lemma`.
- `LadderChain.lean` is still 2,267 lines against its unbumped 2,300 baseline.
- Gates: `check-module-invariants.sh --emit-inventory` then `--check` exits 0, ALL CHECKS PASSED
  (C1, C33 and the inventory/description-cell checks included);
  `check-task-references.sh --quiet` exits 0; `typst-sync-check.sh` exits 0 after `--fix`.
- The complete gate set declared by the plan's final phase was NOT independently run in this
  dispatch; it is deferred to the batch stage of the dispatching invocation, per the dispatch's
  batch gate deferral. Phase 7's own tier is `interface` and its covering checks are listed above.

## Impacts

- The pin layer is available to every `RaySummary` consumer: the dichotomy names the two sides a
  cell-level replacement argument must treat separately, in a form the landed upward inclusion's
  hypothesis consumes directly.
- The exponential `(K2)` reading is available beside the linear one, which is what any pigeonhole
  over the region starts of a doubling chain needs.
- The gate's FAIL closes one of the two named open routes at the level of its arithmetic: no
  derivation of a spanning block's divisibility from `(K1)` is possible, so route (a) cannot
  deliver the downward inclusion without an amendment or a new forward hypothesis.
- The slack accounting leaves Phase 8's decision gate as the only remaining candidate source of
  slack: every positive amount in any composition of the landed transports is paid for by a raise,
  so the regime supplies none of its own. What the obligation still needs is strictly weaker than
  a state-level regime (refuted by `ClimbWitness.hasForwardSlack_refuted_unconditional`) and
  strictly stronger than the landed path-level hypothesis: for each type realized at the upper
  state, SOME path realizing it there with slack.
- The depth-`0` obligation is still neither proved nor refuted under `ParamsOk`, and the reserved
  name is still claimed by nothing. The downstream induction remains unenterable along this route.

## Follow-ups

- **The user decision raised on this dispatch.** The prior cycle's recorded answer — land the
  regime-restricted obligation under `cellLE_zero_const_of_kappa_eq_of_pinFree` — rests on a
  premise this round refuted. Three options are on the table and are stated in
  `.return-meta.json`'s `user_decision`.
- **A downward/deletion assembly carrying an explicit forward-slack hypothesis.** The missing
  piece is precisely localized: feeding the deleted walk to `exists_ladderPath_of_walk_nxt`
  leaves exactly one goal, `(↑(delCnt g a l (v + 1)) - ↑(nxtAt g 0)).natAbs ≤ v.natAbs`, in which
  the deleted walk's pin `v` is the original's pin `v + l`, so the demand exceeds what
  `pinCompat_of_ladderPath` supplies by exactly `l` — and by exactly `m · (P + 1)` when iterated.
  Building it needs a decision about how a cell's universal quantification over paths is to be
  restricted so that a forward hypothesis is statable at a counter state at all.
- **A `(K1)` amendment** is the candidate the gate's analysis points at. It is NOT implemented
  here and should not be taken lightly: it would alter the parameter contract every wired probe
  discharges.
- **Wiring the gate's refuting object as a probe** is a candidate: `spanningBlockLengthDvd_refuted`
  is the kind of record a wired probe holds in place. It stays a prototype here.
- **A tighter pigeonhole constant** was looked for and not found: the even-index factor two buys
  the separation a third pin strictly inside the block needs. Tightening it remains open and is a
  proof obligation, never a loosening of the pinned signature.

- **Phase 9 must handle the saturated-gap branch.** `kappa_collision_regimes`'s third branch is
  addressed by NEITHER landed inclusion. Phase 9's planned close consumes the split expecting two
  branches; it must either exclude the saturated branch from the obligation's own hypotheses or
  carry it as an explicit extra hypothesis on whatever it lands. Nothing in this round settles
  which.
- Phase 8's decision gate (does lengthening the idle gap buy the missing slack
  type-respectingly?) is untouched by this dispatch and remains the next action.

## References

- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` —
  the plan, with Phase 4's verdict and Phase 5's blocker recorded in their phase bodies.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean`,
  `.../prototype/spanning-divisibility.lean` — the two prototypes.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/handoffs/` — the five per-phase handoffs.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/issues.jsonl` — the issue and win log.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the brought-current narrative.
