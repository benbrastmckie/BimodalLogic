# Implementation Summary: Task #838

- **Task**: 838 - Two-sided open core: attack the depth-`0` cell obligation through a `(K2)`-level pigeonhole over region starts on the pin-free side, or restate the obligation under a new name
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-03T17:42:40Z
- **Completed**: 2026-11-03T19:05:00Z
- **Effort**: ~1.5 hours of wall clock over four landed phases and one blocked phase
- **Dependencies**: None at the `state.json` level. Parent: the task whose pump layer is this round's entire input. The ladder realization theorem's depth-`0` induction is the downstream consumer; nothing here edits any of its artifacts
- **Artifacts**: plans/01_pin-free-pigeonhole-open-core.md, prototype/pin-free-side.lean, prototype/spanning-divisibility.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Route (a) of the two named open routes was taken: a `(K2)`-level pigeonhole over region starts
exploiting the pin-free side both refuting objects carry. Its three provable pieces landed — the
pin-free dichotomy, the pigeonhole over the pins, and the exponential `(K2)` bound — and the
decision gate they fed returned **FAIL** with a compiled refuting object: `(K1)` does not
constrain the length of a type-respecting block that spans a pin. The closing phase is
**`[BLOCKED]`**: the FAIL branch's route to a regime-restricted obligation rests on a deletion
mirror that is not landed and whose obstruction this task localized to one undischargeable
register bound. Nothing weakened was landed under the reserved name or under the planned new one.

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
- **Phase 5** is `[BLOCKED]`, not completed. Its full blocker record is in the plan file's Phase 5
  body.

## Verification

- Build: Success. Unscoped full `lake build` through the build guard reports `exit_status=0`,
  zero `error:` across both captured streams, and `.olean` newer than source on every module this
  task touched.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 0.
- Axiom count: unchanged — no `^axiom ` line added anywhere.
- Axiom profiles: all five new library declarations and all five new prototype headlines carry a
  subset of `[propext, Classical.choice, Quot.sound]`; no `sorryAx` anywhere.
- Tests: `BimodalTest.Metalogic.KTypeSummaryAxiomTest` builds green with all eight new pins.
- Gates: `check-module-invariants.sh --emit-inventory --check` exit 0;
  `check-task-references.sh --quiet` exit 0 on every changed non-`specs/**` file;
  `check-evidence-probes.sh` and `verify-deploy.sh` results recorded in the Phase 6 handoff.
- Certificate-freedom grep returns no match on `LadderPin.lean`.
- Both prototypes compile standalone through the build guard with zero errors and zero
  `declaration uses 'sorry'`.
- Files verified: Yes.

## Impacts

- The pin layer is available to every `RaySummary` consumer: the dichotomy names the two sides a
  cell-level replacement argument must treat separately, in a form the landed upward inclusion's
  hypothesis consumes directly.
- The exponential `(K2)` reading is available beside the linear one, which is what any pigeonhole
  over the region starts of a doubling chain needs.
- The gate's FAIL closes one of the two named open routes at the level of its arithmetic: no
  derivation of a spanning block's divisibility from `(K1)` is possible, so route (a) cannot
  deliver the downward inclusion without an amendment or a new forward hypothesis.
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

## References

- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` —
  the plan, with Phase 4's verdict and Phase 5's blocker recorded in their phase bodies.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean`,
  `.../prototype/spanning-divisibility.lean` — the two prototypes.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/handoffs/` — the five per-phase handoffs.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/issues.jsonl` — the issue and win log.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the brought-current narrative.
