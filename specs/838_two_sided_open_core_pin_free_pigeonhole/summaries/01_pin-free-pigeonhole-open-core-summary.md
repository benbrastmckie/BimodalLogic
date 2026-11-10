# Implementation Summary: Task #838

- **Task**: 838 - Two-sided open core: attack the depth-`0` cell obligation through a `(K2)`-level pigeonhole over region starts on the pin-free side, or restate the obligation under a new name
- **Status**: [COMPLETED]
- **Started**: 2026-11-03T17:42:40Z
- **Completed**: 2026-11-10T09:05:00Z
- **Effort**: ~4 hours of wall clock over ten landed phases (Phase 5's earlier blocker withdrawn as mis-anchored and the phase then landed; Phase 9 closed `[COMPLETED WITH EXCLUSIONS]` on its FAIL branch)
- **Dependencies**: None at the `state.json` level. Parent: the task whose pump layer is this round's entire input. The ladder realization theorem's depth-`0` induction is the downstream consumer; nothing here edits any of its artifacts
- **Artifacts**: plans/01_pin-free-pigeonhole-open-core.md, prototype/pin-free-side.lean, prototype/spanning-divisibility.lean, prototype/idle-gap-lengthening.lean
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

Phase 8's decision gate — does lengthening the idle gap above `z`'s region buy the missing slack
type-respectingly? — returned **FAIL**, on sub-question (i), ADMISSIBILITY, with a compiled
refuting object. The obstruction is not the pin condition the gate expected to test against but
one level below it, in `step` itself: an idle run of length two requires an idle-to-idle edge in
the object's own step graph, and an object satisfying `ParamsOk` need not have one. The idle run's
length is therefore a datum of the object, not a parameter the construction may raise, so the
lengthening cannot be promoted to the slack-normalization lemma the downward cell inclusion would
consume. Sub-question (ii), type preservation, was never reached and is recorded as untouched.
No library file was changed by the gate — it runs in a `specs/**` prototype by construction.

Phase 9 therefore took its FAIL branch and landed the obligation's FORWARD-SLACK-RESTRICTED form
as a THEOREM under a name of its own, `cellLE_zero_const_of_kappa_eq_of_forwardSlack`, with the
reserved name `cellLE_zero_const_of_kappa_eq` still claimed by nothing. The route is the state-level
DOWNWARD cell inclusion, which the round's last piece of new ground made available: a per-path
state-level regime is refuted (`ClimbWitness.hasForwardSlack_refuted_unconditional`), but an
EXISTENTIAL-over-paths one is not, and `ForwardSlackWitnessed` — every type a cell realizes is
realized there by SOME path with forward slack — lifts the landed path-level inclusion to the state
level as `cellAt_subset_of_shift_of_pend_past_rev`, with no new pump and no new pin. Against the
upward inclusion that is cell EQUALITY by `Set.Subset.antisymm`. The restricted schema carries FOUR
added hypotheses, one more than the plan anticipated: the fourth is the EQUAL-REGISTER restriction
`n = n'`, and it is carried for a compiled reason —
`kappa_collision_two_regimes_refuted_of_pend_gap` shows the saturated-gap branch of the collision
case split survives restriction to the pending-forever regime at countdowns above the threshold, and
on that residue no landed inclusion applies in either direction. Phase 10 then brought every record
that states the obligation's status current, with no Lean declaration added or removed.

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
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` — NEW,
  standalone prototype (namespace `Probe838C`), not a wired probe and not on the Lake library
  path. Holds the gate's schema `IdleGapLengthening`, the generic mechanism lemma
  `no_consecutive_idle_of_no_idle_step`, the two-state refuting object (`Qo := Bool`,
  `stepO x y = x || y`, serial in both directions via `fwdO`/`bwdO`), the witnessing path
  `exists_gO`, the stab-free atomic closure `aO` with its parameter tuple discharged by
  `paramsOk_params`, and the verdict object `idleGapLengthening_refuted`.

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — grew 299 → 498 lines with the
  FAIL branch's closing assembly, five declarations, all on a subset of
  `[propext, Classical.choice, Quot.sound]` and none carrying `sorryAx`:
  - `ForwardSlackWitnessed` — the forward-slack regime lifted from one path to a whole cell: every
    type the cell at a state realizes is realized there by SOME path carrying
    `HasForwardSlack · z l n`. Existential over paths, which is exactly why
    `ClimbWitness.hasForwardSlack_refuted_unconditional` does not touch it. It asserts nothing; it
    is a hypothesis a consumer supplies.
  - `cellAt_subset_of_shift_of_pend_past_rev` — the DOWNWARD cell inclusion at the STATE level, the
    mirror of the landed upward `cellAt_subset_of_shift_of_pend_past`. Body: the landed path-level
    `mem_cellAt_of_shift_of_hasForwardSlack_exact` applied to the witnessing path. No new pump, no
    new pin.
  - `CellLEZeroConstOfKappaEqForwardSlack` — the obligation with four hypotheses added, all four
    visible in the quantifier: the equal-register restriction `n = n'`; the pending-forever gap at
    both pairs; the threshold bounds at both pairs; and the forward-slack witnessing of whichever
    pair carries the higher countdown, at exactly the displacement separating the two.
  - `cellLE_zero_const_of_kappa_eq_of_forwardSlack` — that schema as a THEOREM at every tuple
    `ParamsOk` admits, concluding cell EQUALITY: upward half
    `cellAt_subset_of_shift_of_pend_past`, downward half `cellAt_subset_of_shift_of_pend_past_rev`,
    closed by `Set.Subset.antisymm`.
  - `kappa_collision_two_regimes_refuted_of_pend_gap` — the compiled reason the equal-register
    hypothesis is carried, at `[propext, Quot.sound]`, below the standard profile.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — a new requirement-(W) block headed
  "the FORWARD-SLACK-RESTRICTED depth-`0` cell obligation" with four pins (the three positive
  declarations plus the refutation), saying that the unrestricted obligation is still open, that the
  pins are of a strictly stronger statement, and what a consumer must supply.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — Phase 10: the `LadderCell.lean`
  description cell brought current with the downward inclusion, the pending-regime refutation and
  the restricted obligation; the depth-`0`-status paragraph given its forward pointer; and the
  paragraph that previously closed "no finite deletion-derivative of which lifts (argued, not
  compiled)" REPLACED by what the gate compiled — the per-path/existential asymmetry in the shape of
  a working hypothesis, the idle-gap route's refutation with its `step`-level mechanism, the
  restricted obligation with its four hypotheses and the compiled reason for the fourth, and the two
  routes left open.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — Phase 10: the restricted-obligation
  block's narrative extended with the gate's verdict and its mechanism (previously absent from the
  ledger), and with the two open routes; the recorded `longFile` ceiling raised 2,200 → 2,300.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md`
  — this file, brought current in place (same round, same path) rather than superseded by a second
  summary for the same round.

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

- **Phase 8: the gate's verdict is FAIL, and the obstruction is NOT where the plan expected it.**
  The plan's mechanism claim was that `pinCompat_of_ladderPath` does not forbid lengthening the
  idle gap, because moving a region start farther from `z` while holding its countdown makes the
  pin demand strictly looser. That claim is correct and irrelevant: the lengthening is denied one
  level below the pin condition, by `step`. A ladder path's object walk satisfies
  `step (objAt g v) (objAt g (v + 1)) = true` at every position, so an idle run of length two
  requires an idle-to-idle edge in the object's step graph.
  `no_consecutive_idle_of_no_idle_step` states that generically, and the two-state object `Qo`
  (`pendO = id`, `stepO x y = x || y` — exactly the idle-to-idle edge missing) is the witness.
  `idleGapLengthening_refuted` instantiates the schema's every hypothesis on it at `z = 0`,
  `I = 1`, `l = 1` — the gap `0 + 2 ≤ T_c` from `(K3)`'s `2 · T_short + T_idle + 2 ≤ T_c`, the
  countdown bound `T_c ≤ cntAt g 0`, the idle run `{T_c + 1}` and the region start at `T_c + 2` —
  and contradicts the conclusion, which asks for a ladder path idle at both `T_c + 1` and
  `T_c + 2`. The parameters are the periodicity fixpoint's own outputs for the stab-free atomic
  closure, discharged by `paramsOk_params`, so the refutation is at a tuple the parameter
  conditions genuinely admit.

- **Phase 8: a fresh object was declared rather than the sibling prototypes' reused.**
  `pin-free-side.lean` and `spanning-divisibility.lean` both use `stepC = fun _ _ => true`, which
  admits every idle run and so cannot carry this refutation at all. The new object is the minimal
  one that can: two states, one edge removed.

- **Phase 8: the type clause stays in the schema's conclusion even though the refutation never
  reaches it.** Dropping it would have made the schema a weaker statement than the plan specified,
  and refuting a weaker statement is a weaker result. Carrying it means the refutation refutes the
  conjunction at its first failing conjunct, which is what the record says.

- **Phase 9: the hypothesis that buys the downward inclusion is EXISTENTIAL over paths, not
  per-path.** This is the round's one genuinely new piece of ground and the reason a state-level
  downward inclusion exists at all. `ClimbWitness.hasForwardSlack_refuted_unconditional` compiles
  that no state-level hypothesis implies `HasForwardSlack` of a given path through the state — the
  climbing-register path passes through a state satisfying every state-level hypothesis a consumer
  carries while violating the regime. `ForwardSlackWitnessed` asks something the climbing path does
  not contradict: that every type the cell realizes be realized by SOME path with slack, which is
  compatible with the climbing path sitting among the paths through that state and realizing the
  same type without slack. The refutation therefore does not reach it, and the lift
  `cellAt_subset_of_shift_of_pend_past_rev` goes through on the witnessing path the hypothesis
  supplies.
- **Phase 9: the fourth hypothesis is carried rather than dispatched, for a compiled reason.** With
  the collision restricted to the pending-forever regime at countdowns above the threshold, the
  saturated-gap branch of `kappa_collision_regimes` does NOT drop out:
  `kappa_collision_two_regimes_refuted_of_pend_gap` exhibits `Tc = Tn = P = 0`, `B = 2` and the
  pairs `(2, 0)`, `(4, 1)` — both clipped coordinates pinned at their thresholds, both residues
  trivial at `P + 1 = 1`, the gap coordinate saturated below the window on both, every gap and
  threshold hypothesis satisfied, the registers differing, and no single `m` displacing both
  coordinates (`4 = 2 + m` forces `m = 2` while `1 = 0 + m` forces `m = 1`). On that residue no
  landed inclusion applies in either direction, and forward slack does not reach it: slack buys the
  deletion inside the lower position's region, while the obstruction there is that the register must
  move by an amount the countdown does not match. Hence `n = n'`.
- **Phase 9: routed through `kappa_eq_components`, not the case split.** With `n = n'` carried,
  `kappa_collision_regimes`' branch structure supplies nothing the countdown residue does not: its
  equal-register branch gives exactly the displacement the proof uses, its common-shift branch
  collapses to `m = 0`, and its saturated branch — which the restricted schema does not exclude —
  needs the residue congruence all the same. The case split is cited for the scope statement rather
  than consumed in the derivation.
- **Phase 9: the common-shift sub-regime's DOWNWARD direction was decided, not deferred.** The
  landed deletion `mem_cellAt_of_shift_of_hasForwardSlack_exact` HOLDS the register, and nothing
  landed lowers it, so a common-shift mirror would need a register-lowering deletion that does not
  exist. It is named as a candidate follow-up route rather than left as an open phase item.
- **Phase 10: the axiom ledger's `longFile` ceiling was raised rather than the prose cut.** The
  gate's verdict and its `step`-level mechanism were absent from the ledger entirely, which is the
  one thing Phase 10's own task list names it must carry; the file is one ledger by design (its
  header comment says so) and the ceiling had already been raised once on the same grounds. No
  declaration was added.

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

- **Phase 8** sub-question (i) was to "build the lengthened walk and its countdown explicitly"
  and discharge the five counter and pin clauses against it. No such walk was built: on the
  refuting object none exists, so there is nothing to discharge the clauses against. The
  sub-question is answered NEGATIVELY by a compiled object instead — the phase's own FAIL branch,
  which the plan provides for explicitly, rather than a substituted step.
- **Phase 8** sub-question (ii), TYPE PRESERVATION, was NOT REACHED and is recorded as untouched
  rather than silently skipped. The refutation closes from `step` alone.
- **Phase 8** Scope Hypothesis predicted a 200-400 line prototype with the refuting object as the
  larger half, one file created and the plan file edited. Actual: a 299-line prototype in which
  the refuting object is NOT the larger half — the generic mechanism lemma is four lines and the
  object's seriality and path construction dominate — and exactly the two predicted files plus
  `issues.jsonl`. `git diff --stat -- FormalSystem/ Tests/` is empty, as the hypothesis required.

- **Phase 9** closed `[COMPLETED WITH EXCLUSIONS]`: the gate's FAIL verdict excluded all five
  PASS-branch tasks, each with a reason and evidence in the plan's `#### Reasoned Exclusions`
  table — the normalization lemma (its only route is refuted, so it is not applicable rather than
  deferred), the reserved name's claim, the `LadderAgree.lean` docstring rewrite (PASS-only; the
  existing docstrings are correct as they stand and any edit would make them false), and the pin
  and `(W)` prose for a PROVED unrestricted obligation (replaced by the FAIL-branch form of the
  same task, which is done).
- **Phase 9** landed a FOURTH restriction the plan did not anticipate, `n = n'`, and routed through
  `kappa_eq_components` rather than `kappa_collision_regimes`. Both departures have the one compiled
  cause recorded under Decisions; because `rules/plan-compliance.md` governs `.lean` files, they are
  recorded in the plan body under `#### Deviation: the equal-register hypothesis` rather than
  annotated silently, and in `issues.jsonl` at severity `costly`.
- **Phase 9** Scope Hypothesis CONFIRMED for the Lean files (199 lines added, `LadderCell.lean` at
  498 against the package `longFile` limit of 1,500) and EXCEEDED by four generated/derived files it
  did not anticipate: the three inventory-block READMEs and `typst/generated/status.typ`, each a
  regenerated block rather than hand-authored content.
- **Phase 10** raised the axiom ledger's recorded `longFile` ceiling from 2,200 to 2,300 — not in
  the phase's declared file-change list as a *kind* of change, though the file itself is listed. The
  reason is under Decisions. Its Scope Hypothesis holds as stated:
  `git diff -U0 -- 'FormalSystem/**/*.lean' | grep -cE '^[+-](theorem|def|lemma|abbrev)'` is 0 for
  this phase.
- **Phase 10**'s declared `Verification Tier` is `full`, and the complete gate set was NOT
  independently run in its dispatch: it is deferred to the batch stage of the dispatching
  invocation, per the dispatch's batch gate deferral, and the narrowing scoped invocation that
  covers this phase's touched files was run instead. Deferred, not forgiven.

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

- **Phase 8**: `bash .claude/scripts/lake-build-guard.sh build --timeout 840 -- env lean
  specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` reports
  `exit_status=0`, zero `error:` lines, zero `warning:` lines, zero `declaration uses 'sorry'`.
  `#print axioms Probe838C.idleGapLengthening_refuted` shows
  `[propext, Classical.choice, Quot.sound]` and `#print axioms
  Probe838C.no_consecutive_idle_of_no_idle_step` shows `[propext]` — no `sorryAx` on either.
  `bash .claude/scripts/validate-artifact.sh …/plans/01_pin-free-pigeonhole-open-core.md plan`
  exits 0 with zero warnings. `bash .claude/scripts/check-task-references.sh --quiet` on the new
  prototype reports 0 occurrences, exit 0. `git diff --stat -- FormalSystem/ Tests/` is empty.
  `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` still shows no `theorem`, `def`
  or `lemma` claiming the reserved name.
- **Phase 8, library state carried forward on Tier-3 evidence rather than a re-run build.** The
  phase changed no `FormalSystem/` or `Tests/` file, so no full unscoped library build was run in
  its dispatch and none is claimed. What was checked instead: every one of the 400+ sources under
  `FormalSystem/` and `Tests/BimodalTest/` has an `.olean` newer than it (0 missing, 0
  source-newer), from the green full build Phase 7 closed on; and the sorry census over the
  resolved source roots reports `sorry_count: 0`. The two standing baseline counts are unchanged
  because nothing in the library moved: 14 `^axiom ` lines, and one grep hit for the vacuity
  pattern (`FormalSystem/Examples/TemporalStructures.lean:495`,
  `int_domain_universal … := trivial`, a pre-existing genuine theorem in a file this phase did not
  touch). The complete gate set is Phase 10's obligation and is deferred to the batch stage there.

### Phase 9 (dispatch 8)

- Build: Success. The three `interface`-tier covering checks each report `exit_status=0` through
  `lake-build-guard.sh` with zero `error:` lines — `… -- build
  FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`, `… -- build FormalSystem`, and
  `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest`.
- Sorry count: 0. `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` on `LadderCell.lean`
  is 0.
- Axiom profiles: the four positive declarations carry `[propext, Classical.choice, Quot.sound]`;
  `kappa_collision_two_regimes_refuted_of_pend_gap` sits BELOW it at `[propext, Quot.sound]`. No
  `sorryAx` on any. All five are pinned under `#guard_msgs`, so the profiles are checked by the
  build rather than asserted in prose.
- Reserved name: `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` shows every hit
  outside the `_of_forwardSlack` name on a docstring or prose line; no `theorem`, `def` or `lemma`
  claims it.
- Gates: `check-module-invariants.sh` exits 0 (after `--emit-inventory` refreshed the three
  generated inventory blocks the new line count moved, a mechanical consequence recorded as outside
  the phase's declared file list); `check-task-references.sh --quiet` exits 0 on every changed file.
- `LadderCell.lean` is 498 lines against the package `longFile` limit of 1,500.

### Phase 10 (dispatch 9)

- Build: Success, and at the terminal full-project bar rather than a scoped one.
  `lake-build-guard.sh build --timeout 1800 -- build` (unscoped) gives `GUARD_EXIT=0` (Tier 1),
  `Build completed successfully (2969 jobs)` with a zero `error:` count over both captured streams
  (Tier 2), and `.olean` newer than source on the one module this phase touched (Tier 3). The
  covering scoped build `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` separately gives
  `exit_status=0`, zero `error:`, 2,411 jobs.
- Sorry count: 0. `lean-sorry-census.sh --cross-check` over the resolved source roots reports
  `stripper_sorry_count: 0`, `compiler_sorry_count: 0`, `cross_check: MATCH`.
- Vacuous count: 0. The vacuity grep's 4 hits on the axiom ledger are prose sentences about
  `sorryAx`, byte-identical in count to HEAD; no declaration matches.
- Axiom count: 14 over `FormalSystem/` and `Tests/`, identical to HEAD.
- Scope Hypothesis confirmed: `git diff -U0 -- 'FormalSystem/**/*.lean' | grep -cE
  '^[+-](theorem|def|lemma|abbrev)'` is 0 — no Lean declaration added or removed.
- Reserved name: `grep -rnE '(theorem|def|lemma|abbrev)\s+cellLE_zero_const_of_kappa_eq\b'` over
  `FormalSystem/` and `Tests/` returns nothing. The one declaration line carrying the string as a
  prefix is `cellLE_zero_const_of_kappa_eq_of_forwardSlack` at `LadderCell.lean:465`.
- Gates: `check-module-invariants.sh` exits 0, ALL CHECKS PASSED (including C9D, zero task-number
  citations under `docs/`); `check-evidence-probes.sh` exits 0, all 52 wired probes compile, the one
  SKIP being the pre-existing deferred `spike-untl-unfolding-and-fwd-obstruction`;
  `check-task-references.sh --quiet` exits 0 with 0 occurrences;
  `typst-sync-check.sh` FAILED on Check 2 (count freshness) and `--fix` repaired it to PASS, a
  three-line regeneration of `typst/generated/status.typ` (the test-library line count and the
  commit stamp) caused by this phase's prose addition;
  `validate-artifact.sh` exits 0 with zero warnings on both this summary and the plan.
- **The complete gate set was NOT independently run, and the two narrowing forms the dispatch
  directive names do not cover this phase.** `run-all.sh --only SUITE` runs the agent system's
  shell test suites and `verify-deploy.sh --only-gate N` compares the deployed `.claude/` tree
  against its source store; this phase touched a `FormalSystem/` README narrative, one prose block
  in a `Tests/` Lean file, `typst/generated/status.typ` and this summary, none of which either form
  reaches. (The deployed tree is independently reported STALE for four extensions, so a full
  `verify-deploy.sh` run would fail here for reasons unrelated to this task.) The covering scoped
  checks actually run are the project gates listed above plus the unscoped full build; the complete
  gate set is deferred to the batch stage of the dispatching invocation and attributed back to this
  task by its `modified_files`. Deferred, not forgiven — and the mismatch is recorded in
  `issues.jsonl` under class `gate collision` rather than papered over by invoking an unrelated
  gate for the appearance of compliance.

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

- Phase 8's FAIL closes the last candidate source of the missing slack that the landed layer
  could have supplied on its own. Phase 9 therefore took its FAIL branch: the obligation is stated
  and compiled under the NEW name `cellLE_zero_const_of_kappa_eq_of_forwardSlack`, carrying the
  forward-slack regime as an existential-over-paths hypothesis at the STATE level plus three
  further restrictions, and the reserved name `cellLE_zero_const_of_kappa_eq` stays reserved and
  claimed by nothing.
- **The state-level downward cell inclusion is now available to every `RaySummary` consumer**
  (`cellAt_subset_of_shift_of_pend_past_rev`), where before only the path-level one was. With the
  upward inclusion it is the first assembly in the layer that concludes cell EQUALITY rather than a
  one-directional inclusion, and the hypothesis it needs (`ForwardSlackWitnessed`) is statable at a
  counter state — which is what the mis-anchored blocker's withdrawal said was the open question
  and what this round answers.
- **The shape of a working restriction is settled in both directions**, which is reusable
  independently of this obligation: a per-path state-level regime is refuted
  (`ClimbWitness.hasForwardSlack_refuted_unconditional`), an existential-over-paths one is not.
  Any future attempt to restrict a cell-level statement by a path property must take the
  existential form.
- `no_consecutive_idle_of_no_idle_step` is a generic fact about the relationship between an
  object's step graph and the idle-run structure of its ladder paths. Nothing in the library states
  it; it lives in the prototype, and a consumer that needs it would have to land it.

## Follow-ups

- **The user decision raised mid-round is SETTLED, and the record is the decision file.** Three
  answers are on file in `.decisions.json`, each superseding the last as a compiled object refuted
  its predecessor's premise, and all three were filed non-blocking and proceeded on the dispatched
  agent's own recommendation. The standing one: accept the equal-register-restricted equality as
  landed under the planned name `cellLE_zero_const_of_kappa_eq_of_forwardSlack`, with the extra
  restriction visible in the signature and the register-lowering deletion recorded as a named
  candidate follow-up route. Nothing in this round is awaiting an answer.
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

- **The saturated-gap branch was handled by carrying an explicit hypothesis, not by excluding it.**
  Of the two options this round left open for it, Phase 9 took the second: the restricted schema
  carries `n = n'`, which covers the `n = n'` slice of the saturated branch (and the case split's
  first branch entire) and nothing else. `kappa_collision_two_regimes_refuted_of_pend_gap` is the
  compiled reason the branch could not simply be excluded by the regime restriction.

- **The sharpening Phase 8's verdict leaves open, named rather than created**: the lengthening is
  available exactly where the object's idle states carry a reachable cycle — `tIdle pend`
  (`#idle states + 1`) is the length above which an idle run must repeat an idle state and so
  become duplicable by the landed splice type lemma. That is an OBJECT hypothesis and not a
  consequence of `ParamsOk`; adding it would restrict the obligation rather than prove it, which
  is the same shape as the forward-slack restriction Phase 9 lands. Not created as a task.
- **Sub-question (ii), type preservation, is open.** Whether a lengthened path, on an object that
  admits one, holds the realized stab-free type at `z` was never tested. Any future route through
  gap lengthening must answer it before the lengthening is usable.
- **Wiring `idleGapLengthening_refuted` as a probe** is a candidate on the same footing as
  `spanningBlockLengthDvd_refuted`: it stays a prototype here. Phase 10's own task list directed
  that this be recorded here rather than wired in that phase, and `check-evidence-probes.sh` passes
  with all 52 currently wired probes compiling.

- **The two routes the FAIL verdict leaves, named and NOT created as tasks.** (1) A `(K1)`
  AMENDMENT constraining the length of a type-respecting block that spans a region start — which
  `(K1)` does not do, compiled — would reopen the spanning-block device the two-sided refutation
  closed; it would alter the parameter contract every wired probe discharges. (2) A
  REGISTER-LOWERING DELETION, the common-shift mirror of
  `mem_cellAt_of_shift_of_hasForwardSlack_exact` carrying the register DOWN by the same multiple of
  `P + 1` as the countdown, where the landed deletion holds it and nothing landed lowers it. It
  would buy the common-shift sub-regime's downward direction and so drop the equal-register
  hypothesis on the case split's first branch; it would NOT reach the saturated residue.
- **What a consumer of the restricted obligation must supply**, at each state it inducts through:
  the register equality across the collision, and a forward-slack witness at the higher state.
  Neither is a consequence of `ParamsOk`. The unrestricted `CellLEZeroConstOfKappaEq` is still
  neither proved nor refuted under `ParamsOk`, `cellLE_zero_const_of_kappa_eq` is still claimed by
  nothing, and the downstream ladder-realization induction remains unenterable without one of the
  two routes above or the consumer's two extra hypotheses.

## References

- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` —
  the plan, with Phase 4's verdict and Phase 5's blocker recorded in their phase bodies.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean`,
  `.../prototype/spanning-divisibility.lean` — the two prototypes.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/handoffs/` — the five per-phase handoffs.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/issues.jsonl` — the issue and win log.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the brought-current narrative.

- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` — the
  Phase 8 decision gate's schema, mechanism lemma, refuting object and verdict.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — the FAIL branch's closing
  assembly (the `ForwardSlack` section and the pending-regime refutation).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — the requirement-(W) block headed "the
  FORWARD-SLACK-RESTRICTED depth-`0` cell obligation", with its four pins, the gate's verdict and
  the two open routes.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/.decisions.json` — the three recorded answers,
  each superseding the last.
