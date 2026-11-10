# Implementation Plan: Task #838

- **Task**: 838 - Two-sided open core: attack the depth-`0` cell obligation through a `(K2)`-level pigeonhole over region starts on the pin-free side, or restate the obligation under a new name
- **Status**: [IMPLEMENTING]
- **Effort**: 17.5 hours. 9 hours are landed (Phases 1-4 and 6, at 2 / 2 / 1.5 / 2 / 1.5) and 8.5 hours remain (Phases 5, 7, 8, 9, 10 at 1 / 2 / 2 / 2 / 1.5). Phase 8 is a decision gate and Phase 9 is branch-selected by it: on the PASS branch Phase 9 lands the obligation under the reserved name, on the FAIL branch it states the forward-slack-restricted obligation under a NEW name and closes in roughly one hour, so the honest range is 16.5-17.5 hours
- **Dependencies**: None at the `state.json` level. Parent: task 836, whose Phase 10 closed `[BLOCKED]` on exactly this core and whose landed pump layer was this plan's original input. Task 761 is the downstream CONSUMER (its Phase 11.6 inducts from the depth-`0` base case); nothing here edits any artifact of 761 or 836. Two follow-up tasks spawned from this plan's own Phase 5 blocker have since landed the whole re-anchored deletion layer this plan now consumes — `exists_deleted_ladderPath_of_pend_past_nxt`, `anchor_clause_of_first_region_start`, `HasForwardSlack` with its four support lemmas, `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` and `mem_cellAt_of_shift_of_hasForwardSlack_exact`, all in `LadderChain.lean` — so those names are INPUTS here, not deliverables. A serializing dependency edge is recorded against the ladder-path insertion-cascade task (task 853, `[RESEARCHED]`): Phase 8's gate below and that task both construct an INSERTION into a ladder path, and both touch `LadderAgree.lean`
- **Research Inputs**: `specs/838_two_sided_open_core_pin_free_pigeonhole/.dispatch/4-aux-plan-revision.md` — the blocker research delivered in a plan-revision dispatch's own context, which produced no file under `reports/`. There is no research report for this task in either round; the other inputs are the landed library, the two compiled prototypes of task 836, this task's own two prototypes, and the task description. See "Research Integration" for both the Stage 1.5 assessment and the blocker research's four findings
- **Artifacts**: plans/01_pin-free-pigeonhole-open-core.md (this file); summaries/01_pin-free-pigeonhole-open-core-summary.md (brought current by Phase 10)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The depth-`0` cell obligation `CellLEZeroConstOfKappaEq` is neither proved nor refuted under the
repaired `(K4)`, and the one device that would rebuild the next-deadline register
type-respectingly across a tight pin — a type-respecting block SPANNING a region start — is
refuted in both directions as a consequence of `ParamsOk`. This plan takes the first of the two
named open routes: a `(K2)`-level pigeonhole over region starts, exploiting the pin-free side
that both refuting objects carry. The route is decomposed into three pieces that are each
provable on their own (a pin-free dichotomy, a pigeonhole over region starts, and the
exponential `(K2)` bound that makes pins dense wherever the register is tight), one decision gate
that names the exact residual obstruction, and a branch-selected closing phase that either lands
the obligation under the reserved name or states a regime-restricted obligation under a new one.

The decomposition's point is that the FAIL branch is as informative as the PASS branch: whichever
way the gate falls, the task ends with the obstruction compiled rather than argued, which is how
task 836's Phase 3 gate settled the spanning-block device.

That gate returned FAIL and the closing phase's recorded blocker has since been withdrawn as
mis-anchored (see "Research Integration" and Phase 5). The whole re-anchored deletion layer is
landed, up to a DOWNWARD cell inclusion on the witnessing path under a named forward-slack
regime, so the obstruction has moved and the plan continues at the sharper question that layer
exposes: `cellAt` is existential over histories, so the obligation needs not slack on a GIVEN
path but SOME slack-carrying path realizing each type at the upper state. Phases 5 and 7 compile
the accounting and the cell-level pieces that are provable on their own, Phase 8 gates the one
device that can still supply the missing slack — lengthening the idle gap above the compared
position's region — and Phase 9 is branch-selected by it on exactly the shape Phase 5 had under
Phase 4.

### Research Integration

No research report exists for this round, so the Stage 1.5 opening assessment applies and is
recorded here rather than left implicit. The assessment's verdict was to plan directly, on three
grounds, each re-derived in this dispatch by reading the repository:

- **Every fact the plan rests on is in the tree and was read.** The two refuting objects
  (`spanningBlockBwd_refuted`, `spanningBlockFwd_refuted`) and the tight doubling chain
  (`tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`) are compiled in
  `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean`
  (575 lines, re-derived by `wc -l` at authoring); the obligation schema and its mechanism
  docstring are in `LadderAgree.lean`; the pump layer's pigeonhole, forward window, both type
  lemmas and deletion admissibility are in `LadderPump.lean`; the budget lemmas, the
  realized-chain bridge, `typeBlock_length_dvd_of_paramsOk` and the one-directional regime-A
  assembly are in `LadderChain.lean`. Nothing here needed a literature search or an external API.
- **The route's arithmetic is already in the landed parameter conditions.**
  `cascadeBound pend φ = 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)` and `(K2)` says
  `cascadeBound pend φ ≤ Tc`, so `2 ^ Fintype.card (ProdState Q φ) ≤ Tc` — the `(K2)` bound is
  EXPONENTIAL in the pigeonhole budget, not linear in it. That is exactly the quantity a
  pigeonhole over region starts needs, because a doubling chain whose last region has countdown
  at least `Tc` must carry on the order of `log₂ Tc` region starts below it, and `(K2)` makes
  `log₂ Tc` dominate `Fintype.card (ProdState Q φ)`. This is the plannable content of route (a),
  and it was read off `CounterQuotient.lean` and `LadderChain.lean`, not guessed.
- **The pin-free side is a landed dichotomy, not a new hypothesis.**
  `cntAt_le_nxtAt_succ_of_idle_past` and `pend_past_of_nxtAt_lt` already split every pending
  position into "pending forever into the past" (no pin below at all — the regime-A hypothesis
  `n + 2 ≤ c` the upward inclusion already consumes) and "a pin below, so `c ≤ n + 1`". Both
  refuting objects sit on the first side: on `gB` the register below the single idle position is
  free of every pin, on `gC` the register above `z`'s region is.

Correction to a carried figure in the task description, re-derived at authoring:
`grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns exactly two lines, both
docstrings in `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (2184, 2274);
`LadderChain.lean` does not mention the name at all. The reserved name's home for every grep in
this plan is `LadderAgree.lean`. The substance of the description's claim — that the name is
reserved and claimed by nothing — holds.

#### The blocker research integrated in this revision

The one new input is the plan-revision dispatch context
`specs/838_two_sided_open_core_pin_free_pigeonhole/.dispatch/4-aux-plan-revision.md`; it produced
no report file, so there is nothing under `reports/` to cite. Its finding is that the blocker
recorded against Phase 5 is arithmetically correct and computed against the WRONG ANCHOR, so its
conclusion does not follow. Each clause below was re-derived in this revision by reading the
source, not taken on the dispatch's word:

- **The anchor is a free parameter, not a datum.** The undischargeable goal the blocker quotes
  carries `nxtAt g 0`: the anchor VALUE inherited from the original path, at the anchor POSITION
  `0` that `exists_ladderPath_of_walk` (`LadderAgree.lean`) hardwires. `n₀` is not read off `g`
  at all — it is an explicit argument of `exists_rlad_hist_of_walk` (`RunLayer.lean`), of
  `exists_ladderPath_of_walk`, and of `exists_ladderPath_of_walk_nxt` (`LadderChain.lean`),
  discharged existentially as `nxtAt g' 0 = n₀`.
- **The landed deletion already defeats that exact bound.**
  `exists_deleted_ladderPath_of_pend_past` (`LadderPump.lean`) passes `nxtAt g (l : ℤ)` — the
  register re-read at the SHIFTED position — and closes its anchor clause in four lines whose
  load-bearing step is `nxtAt_lipschitz_two_sided g hg (v + (l : ℤ)) (l : ℤ)`, giving
  `|nxtAt g (v + l) − nxtAt g l| ≤ |v + l − l| = |v|` exactly, with zero slack. So
  `tightChain_slack_zero` does not refute the route: zero slack is precisely what the re-anchored
  bound consumes, which is why the landed proof works, and the `l`-sized gap the blocker reports
  is the artefact of measuring the shift against position `0` rather than against the deletion
  point.
- **The re-anchoring has since been carried all the way to the cell level.** `LadderChain.lean`
  is 2227 lines (`wc -l` at this revision, against its own in-source baseline
  `set_option linter.style.longFile 2300` — 73 lines of headroom, which is why Phases 7 and 9
  below land in a NEW module). It now carries the anchor-freed lift
  `exists_ladderPath_of_walk_nxt_at`, the register-exposing deletion
  `exists_deleted_ladderPath_of_pend_past_nxt`, the collapse of its anchor clause to the first
  region start (`anchor_clause_of_first_region_start`), the named regime `HasForwardSlack` with
  entry (`hasForwardSlack_of_next_region_cnt_le`), monotonicity, the two exact transports
  (`hasForwardSlack_del`, `hasForwardSlack_raise`) and vacuity
  (`hasForwardSlack_of_idle_above`), the up-first exact-shift theorem
  `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`, and the DOWNWARD cell inclusion
  on the witnessing path `mem_cellAt_of_shift_of_hasForwardSlack_exact`. Every one of the three
  absences the blocker inventoried — no iterated deletion, no downward assembly, no deletion
  mirror — is now a landed name.
- **What the remaining gap actually is, stated against those names.** `HasForwardSlack g z l n`
  reduces, at the single idle position `s₀ = z + cntAt g z + I` before the first region start
  above `z`'s region, to `nxtAt g s₀ ≤ n + cntAt g z + I − l`. Its lower direction follows from
  the consumer's gap hypothesis alone; its upper direction is short by exactly `l`, and
  `ClimbWitness.hasForwardSlack_refuted_unconditional` compiles that no STATE-level hypothesis can
  supply it — `Drift` admits the rung `n' = n + 1` at every step, so the climbing-register path
  passes through a state satisfying every state-level hypothesis the consumer carries and
  violates the regime. But `cellAt` is EXISTENTIAL over histories, so the obligation never needs
  slack on a GIVEN path: it needs, for each type realized at the upper state, SOME path realizing
  that type there WITH slack. That weaker demand is what Phase 8 gates, and it is neither asked
  nor answered anywhere in the tree.

### Prior Plan Reference

No prior plan for task 838. Task 836's plan
(`specs/836_ladder_type_preserving_cell_agreement_construction/plans/01_obligation-repair-and-pump-layer.md`)
is the PARENT's plan and is read here for calibration only, not as a template:

- **Effort calibration**: 836 ran eleven phases at 1.5-2 hours each over the same modules and
  landed them; the 2-hour ceiling per Lean phase in that range is validated, so this plan holds
  to it.
- **Validated approach**: 836's Phase 3 gate shape — state the candidate device as a named `def`,
  refute or confirm it with a compiled object, and let the FAIL branch be a recorded outcome
  rather than a failure — is reused verbatim as this plan's Phase 4.
- **Validated module shape**: 836's Phases 4 and 8 established what a new `RaySummary` module
  costs (the module, two root imports, one regenerated README inventory block plus its
  description cell, one axiom-test pin block, one certificate-freedom grep). Phase 1 here follows
  that list exactly.
- **Risk encountered and inherited**: 836's attempt to split `LadderPump.lean` at 1000 lines was
  reverted because the contingency file was never harvested into `file_scope` and the commit
  pathspec dropped it. This plan therefore declares its new module in a per-phase
  `Files to modify` list from the outset rather than as a Scope Hypothesis contingency.
- **Prohibition inherited**: 836's Phase 10 recorded that no narrowed or regime-restricted
  restatement may be landed under the reserved name. This plan carries that prohibition into
  Phase 5's FAIL branch as a hard constraint.

### Roadmap Alignment

The dispatch context carried no `roadmap_path`, so no roadmap was injected; `specs/ROADMAP.md`
was nevertheless consulted read-only at authoring and is not modified by this plan. The relevant
item is **"761 — the ladder realization theorem"**, which records Phase 11.5 as the depth-`0`
cell agreement, names `AtomPreservingCountMove` as the refuted construction, and states that what
is refuted is the CONSTRUCTION, not the obligation. This plan advances that item by settling
whether route (a) closes the obligation's remaining gap; it does not advance any other roadmap
item.

## Goals & Non-Goals

**Goals**:

- A new certificate-free module `LadderPin.lean` holding the pin layer: the pin-free dichotomy
  (`pend_past_or_idle_of_no_pin_below`, `pendPast_or_cntAt_le_nxtAt_succ`) and the pigeonhole
  over region starts (`exists_pinTypeBlock_of_budget_lt_pins`), each a theorem on the standard
  axiom profile and pinned in the axiom test.
- The `(K2)` exponential bound `two_pow_card_prodState_le_Tc` landed in `LadderChain.lean` beside
  `budget_le_Tc`.
- The pin-free side of both refuting objects compiled as a prototype, so the claim "both refuting
  objects have a pin-free side" is a theorem about named objects rather than a remark.
- A compiled decision gate (Phase 4) answering ONE question with a named verdict: does a
  type-respecting block spanning a region start have a length that `(K1)` constrains?
- On the gate's PASS branch: `cellLE_zero_const_of_kappa_eq : CellLEZeroConstOfKappaEq …` landed
  as a theorem on the standard axiom profile.
- On the gate's FAIL branch: a regime-restricted obligation under a NEW name, compiled, with the
  record naming exactly what the consumer must additionally supply, and the reserved name still
  reserved.
- The free slack baseline `hasForwardSlack_zero` landed in `LadderChain.lean`, so the accounting
  of the landed raise and deletion transports is compiled rather than argued.
- A new module `LadderCell.lean` holding the cell level: the common-shift upward inclusion
  `cellAt_subset_of_common_shift_of_pend_past` (the sub-regime the landed upward inclusion's
  docstring names and does not state) and the collision case split `kappa_collision_regimes`.
- A second compiled decision gate (Phase 8) answering ONE question with a named verdict: does
  lengthening the idle gap above `z`'s region by `l` yield an admissible ladder path with the
  register at `z` held and the realized stab-free type at `z` held? That is the one remaining
  source of the `l` the re-anchored deletion's anchor clause is short by.
- On Phase 8's PASS branch: the slack-normalization lemma
  `exists_hasForwardSlack_realizing_of_pend_past`, the state-level downward inclusion it buys,
  and `cellLE_zero_const_of_kappa_eq` under the reserved name.
- On Phase 8's FAIL branch: `cellLE_zero_const_of_kappa_eq_of_forwardSlack` under a NEW name,
  compiled, carrying the forward-slack regime on the witnessing path, with the reserved name
  still reserved.

**Non-Goals**:

- No change to `ParamsOk`, `paramsOkK1`, `paramsOkK2`, `paramsOkK3` or `paramsOkK4`. A `(K1)`
  amendment is one possible outcome of Phase 4's analysis and is recorded as a follow-up, never
  implemented here: it would alter the parameter contract every wired probe discharges.
- No `sorry`, no `def X := True`, no vacuous placeholder anywhere, and no restatement — narrowed,
  regime-restricted or otherwise — under the reserved name `cellLE_zero_const_of_kappa_eq`.
- No edit to any artifact of task 761 or task 836, and no edit to `specs/ROADMAP.md`.
- No `set_option linter.style.longFile` baseline bump on `LadderPump.lean`. The new material goes
  into a new module precisely so that no length baseline moves.
- No attempt to revive the spanning-block DEVICE as derivable from `ParamsOk`. It is refuted in
  both directions; this plan uses the pigeonhole to produce a spanning block AT A GIVEN OBJECT
  where pins are dense, which is a different claim.
- No bisimulation, relabelling, or splice-transport framework beyond the two index-map transports
  the landed pump layer already carries.
- No `set_option linter.style.longFile` baseline bump on `LadderChain.lean` either. Its baseline
  of 2300 stays where it is; material that does not fit under it goes into `LadderCell.lean`.
- No STATE-level forward-slack hypothesis anywhere. `ClimbWitness.hasForwardSlack_refuted_unconditional`
  compiles that no such hypothesis is implied by the state, so a statement carrying one would be
  carrying a hypothesis the consumer cannot discharge.
- No re-derivation of the landed re-anchored deletion layer. `exists_deleted_ladderPath_of_pend_past_nxt`,
  `anchor_clause_of_first_region_start`, `HasForwardSlack`'s four support lemmas, the up-first
  exact-shift theorem and `mem_cellAt_of_shift_of_hasForwardSlack_exact` are INPUTS; this plan
  consumes them and does not restate, rename or reprove them.

## Decisions

- **Route (a) first, route (b) only on a gate FAIL.** Route (b) weakens what the consumer can
  induct from, so it is not attempted while route (a) is unsettled. Phase 4 is the one gate that
  decides between them, and it sits as early as the three provable pieces allow so the
  orchestrator learns the branch before the closing phases are entered.
- **The new material goes into `LadderPin.lean`, not into `LadderPump.lean`.**
  `LadderPump.lean` is 1485 lines against the package-wide `longFile` limit of 1500
  (`lakefile.toml`; re-derived at authoring by `wc -l` and by `grep -n longFile` over
  `RaySummary/*.lean`, which shows no baseline option on `LadderPump.lean`), leaving 15 lines of
  headroom. Adding the pin layer there would force a baseline bump on a module whose contract
  docstring states one argument; a new module with its own contract is the cheaper and more
  honest placement. `LadderChain.lean` at 612 lines has room for the `(K2)` bound and the closing
  assembly, and is the right home for both because they read `ProdState` and `cascadeBound`,
  which `LadderPin.lean`'s certificate-freedom grep forbids.
- **The pigeonhole is pinned over `2 · budget + 2` region starts, not `budget + 1`.** The device
  needs a block whose two ends carry equal object state and equal realized type AND which
  contains a region start strictly inside it, so the two colliding pins must be at least two
  apart. Restricting the pigeonhole to even-indexed pins buys that at the cost of a factor two.
  The constant is tightened only by a proof, never loosened — the same posture 836 took on the
  `(K4)` repair's factor two.
- **The pin-free side is compiled on the refuting objects, not asserted.** Phase 3 adds the two
  one-line instances to a prototype rather than to the library, because they are facts about two
  specific witnesses and belong with the witnesses.
- **The Challenge block is elaborated at authoring time, and the gated theorems are not pinned.**
  Phases 1-3's four Goals are pinned below and were elaborated standalone (see that section).
  Phase 4's gate statement and Phase 5's closing theorem are deliberately NOT pinned: a pinned
  signature is a contract that the statement is the intended one, and whether
  `CellLEZeroConstOfKappaEq` is provable is exactly what Phase 4 decides. Pinning it would pin a
  statement this plan cannot vouch for — the same reason 836 left its Phase 10 theorem unpinned.
- **The closing assembly lands in a NEW module `LadderCell.lean`, not in `LadderChain.lean`.**
  `LadderChain.lean` is 2227 lines against its own in-source baseline
  `set_option linter.style.longFile 2300` (both re-derived at this revision by `wc -l` and
  `grep -n longFile`), leaving 73 lines of headroom — enough for Phase 5's two short lemmas and
  nothing more. The cell-level assembly is 150-350 lines, so it gets its own module with its own
  contract docstring rather than a baseline bump on a module whose contract docstring already
  states one argument. `LadderCell.lean` is already declared in this task's `file_scope`, so no
  contingency harvest is needed.
- **The gate of Phase 8 asks about LENGTHENING THE IDLE GAP, not about another pigeonhole.** The
  anchor clause is short by exactly `l` in the upper direction
  `nxtAt g s₀ ≤ n + cntAt g z + I − l`, and `I` — the length of the idle run between `z`'s region
  and the first region start above it — appears on the RIGHT. Inserting `l` idle positions into
  that run therefore buys exactly the missing `l`, provided the region start above keeps its
  countdown. This is the one device the two refutations on the record do not touch, and the
  reason is mechanical: `pinCompat_of_ladderPath` demands
  `|cntAt g (s + 1) − cntAt g (v + 1)| ≤ |s − v|` between region starts, so moving a region start
  FARTHER from `z` while holding its countdown makes the pin demand strictly LOOSER. That is the
  opposite of the pending-block splice, whose demand reads `|s − v| + l ≤ |s − v|` on a pin-tight
  original and is false for `l > 0` (`tightChain_slack_zero`). What Phase 8 must decide is
  therefore not the pin side of admissibility but TYPE PRESERVATION at `z`: the inserted
  positions lie in `z`'s FUTURE, where a `U` formula of the closure can see them.
- **The baseline accounting is compiled before the gate is asked.** `HasForwardSlack g z 0 n` at
  `n = nxtAt g z` is free from `nxtAt_lipschitz_two_sided`, and `hasForwardSlack_raise` increases
  the amount by EXACTLY the raise while `hasForwardSlack_del` decreases it by EXACTLY the
  deletion. Phase 5 lands the free baseline so that the net-zero accounting of every composition
  of the landed transports is read off two exact transports rather than argued, which is what
  makes Phase 8's gate the only remaining source of slack rather than one candidate among
  several.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A spanning block's length is not constrained by `(K1)` (`prodCycleLens` membership needs `l ≤ cntAt g u`, which a block crossing an idle position violates), so the shift cannot be made exactly `m · (P + 1)` | H | H | This is precisely Phase 4's gate question, asked early and answered by a compiled object either way. On FAIL, Phase 5's branch states the regime-restricted obligation and the record names the `(K1)` amendment as a follow-up task rather than attempting it |
| The pin-density hypothesis is not derivable from `ParamsOk` for a general path (a path may have one long region and no pins at all — `gC` is such an object) | H | H | The dichotomy of Phase 1 is the answer by construction: the sparse-pin side IS the pin-free side, where the landed regime-A assembly already applies. Phase 4's gate statement is written over the dichotomy, not over a density assumption |
| The pigeonhole over region starts needs the pins' realized types, which depend on the history `σ`, and the two sides of the obligation quantify over ALL histories | M | M | The landed pigeonhole `exists_typeBlock_of_budget_le_cnt_within` already takes a single `σ` and is applied per-history by its consumers; Phase 2's Goal follows that shape exactly (one `σ`, no offset hypothesis read) |
| `LadderPin.lean` accidentally reaches a certificate object through a transitive `LadderPump` re-export | M | L | Phase 1 runs the same explicit grep `LadderPump.lean`'s contract names and the phase does not close until it returns nothing |
| Phase 5's FAIL branch produces a restated obligation the consumer (761's Phase 11.6) cannot induct from | M | M | Phase 5's FAIL branch does not merely state the restriction: it records, in the module docstring and the summary, exactly which hypothesis the consumer must now supply, and raises `user_decision` (already filed by this plan, non-blocking) on whether to accept that or leave the obligation open |
| A new module plus axiom-test pins ripples into the generated README inventories, as it did in 836 | L | H | Phase 1's task list includes `check-module-invariants.sh --emit-inventory` and the hand-written description cell, and the three generated inventory blocks are named in `Files to modify` |
| Lengthening the idle gap does not preserve the realized stab-free type at `z`, because a `U` formula of the closure sees the inserted positions | H | M | This is exactly Phase 8's second sub-question, asked in a prototype and answered by a compiled object either way. On FAIL the refuting object is the deliverable, and Phase 9 takes its FAIL branch, which has content independent of the gate |
| The common-shift anchor clause of Phase 7 does not close from the widened window, so the sub-regime `n' = n + m · (P + 1)` stays unstated | M | M | Phase 7 is ordered before the gate and is independently useful: the `kappa`-collision case split it also lands is what Phase 9 consumes on EITHER branch. If the anchor clause does not close, Phase 7 closes `[BLOCKED]` with the goal state recorded and Phase 9 proceeds on the sub-regime `n' = n` alone |
| Phase 8's insertion collides with the sibling insertion-cascade task over `LadderAgree.lean` | M | M | Phase 8 touches no library file at all — its verdict is reached in a `specs/**` prototype — and the serializing dependency edge recorded in **Dependencies** is what keeps the two out of each other's commits. If Phase 9's PASS branch needs an insertion constructor in the library, it lands in `LadderCell.lean`, which that task does not touch |
| `LadderChain.lean` crosses its own `longFile` baseline when Phase 5's two lemmas land | L | M | 73 lines of headroom against two lemmas whose proofs are two and six lines; if it crosses anyway, the two lemmas move to `LadderCell.lean` with Phase 7, which is already declared and already imports `LadderChain.lean`. Never bump the baseline to fit them |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 6 | 4 |
| 5 | 5 | 4 |
| 6 | 7, 8 | 5 |
| 7 | 9 | 7, 8 |
| 8 | 10 | 9 |

Phases within the same wave can execute in parallel; Phases 7 and 8 are the one parallel pair
left, and they are genuinely disjoint — Phase 7 writes a new library module, Phase 8 writes a
`specs/**` prototype and touches no library file. Phase 6 closed `[COMPLETED]` as the records
phase over what Phases 1-4 landed, which is why it sits at wave 4 here while its own body still
records `Depends on: 5`; Phase 10 is the terminal records phase and depends, transitively through
Phase 9 and Phase 8, on every other phase.

### Phase 1: `LadderPin.lean` — the Pin-Free Dichotomy and Module Wiring [COMPLETED]

**Goal**: A new certificate-free module beside `LadderPump.lean` holds the pin layer's first
half: no pin below a position forces the past to be uniformly idle or uniformly pending, and
every pending position of a ladder path is either pin-free below (pending forever into the past)
or has its countdown bounded by its register plus one. The module is wired into both root
imports, the generated README inventories and the axiom test.

**Tasks**:

- [x] Re-run the authoring greps and announce the evidence tier *(completed: both greps re-ran as grep-tier evidence; the reserved-name grep returned the two `LadderAgree.lean` docstring lines plus one `RaySummary/README.md` narrative line, and the new-name grep returned nothing)* (`lean_local_search` may report
  `index: unavailable` or `warming`, in which case an empty result is NOT proof of absence and the
  tier degrades to grep):
  `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only the two docstring
  lines of `LadderAgree.lean`; `grep -rnE 'LadderPin|pend_past_or_idle_of_no_pin_below|pinTypeBlock|two_pow_card_prodState' FormalSystem/ Tests/`
  returns nothing.
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` *(completed)*: copyright header;
  `import FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` and nothing else; module
  docstring stating its contract — certificate-free under `LadderPump.lean`'s own grep
  (`certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod`),
  holding ONE argument: what the PINS of a ladder path (an idle position followed by a pending
  one) force about the path and about the types realized along it. The docstring names the two
  landed windows it sits between (`cntAt_le_nxtAt_succ_of_idle_past` backward,
  `nxtAt_le_cntAt_add_of_next_region` forward) and states that it holds no cell-level agreement
  and no `ParamsOk`-level assembly.
- [x] `pend_past_or_idle_of_no_pin_below` (Goal, signature as pinned below) *(completed)*: from "no `s` with
  `s + 1 ≤ p`, `objAt g s` idle and `objAt g (s + 1)` pending", the pending positions at or below
  `p` are downward closed, so either every position at or below `p` is idle, or some `v ≤ p` has
  every position at or below `v` pending. The proof is by contraposition on a single step: a
  pending `w` with an idle `w - 1` IS a pin at `w - 1`.
- [x] `pendPast_or_cntAt_le_nxtAt_succ` (Goal, signature as pinned below) *(completed; the pin-free branch consumes `pend_past_or_idle_of_no_pin_below`'s uniformly-idle disjunct to refute it at `z` itself, and reaches the uniformly-pending conclusion through the shared single-step helper `idle_of_idle_of_no_pin_below` that this phase's Scope Hypothesis budgets, because the dichotomy's existential disjunct names SOME `v ≤ p` rather than `p` itself)*: the counter-level
  dichotomy at a pending `z` — either the past is uniformly pending, or `cntAt g z ≤ nxtAt g z + 1`.
  Routed through the landed `cntAt_le_nxtAt_succ_of_idle_past` on the second branch and through
  `pend_past_or_idle_of_no_pin_below` on the first; `pend_past_of_nxtAt_lt` is the landed converse
  and is cited in the docstring, not re-proved.
- [x] A `noPinBelow` / `noPinAbove` abbreviation pair ONLY if *(completed on the do-not-introduce branch: the unfolded hypotheses read fine and the Challenge block pins the unfolded form, so no abbreviation was introduced)* the two Goals' statements read more
  clearly through them; if the unfolded hypotheses read fine, do not introduce the abbreviations
  (the Challenge block below pins the unfolded form, which is the contract).
- [x] Wiring *(completed)*: `import FormalSystem.Metalogic.Decidability.RaySummary.LadderPin` after the
  `LadderPump` line in `FormalSystem/Metalogic/Decidability/RaySummary.lean` and in
  `FormalSystem.lean`'s RaySummary block; `bash scripts/check-module-invariants.sh --emit-inventory`
  then hand-write the `LadderPin.lean` description cell in the regenerated tables (the generator
  seeds `<!-- TODO: add description -->` for a new file); `--emit-inventory --check` exits 0.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` *(completed; both pins read `[propext, Classical.choice, Quot.sound]`)*: a new
  `/-! ## Requirement (W): the pin layer (`RaySummary/LadderPin.lean`) … -/` block with
  `#guard_msgs in #print axioms` pins for both Goals.
- [x] The certificate-freedom grep above returns nothing on `LadderPin.lean`. *(completed)*
- [x] Record in `issues.jsonl` whether the three generated inventory blocks needed regeneration
  and whether any other file moved. *(completed: FOUR generated inventory blocks needed regeneration, not three — `FormalSystem/README.md` is a fourth consumer of a RaySummary module's line count; no other file moved)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The pin layer's first half is 90-160 lines (the two Goals plus their
single-step helpers; the landed dichotomy they route through is `LadderAgree.lean` lines 790-860
by the section markers, re-derived at authoring), and six files change: the new module, the two
root imports, the three generated inventory blocks (`RaySummary/README.md`,
`Metalogic/README.md`, `README.md` — 836 found all three move when a module's line count enters
the inventory), and the axiom test. Confirm by `wc -l` on the new module and `git diff --stat`
before the commit; if only one inventory block moves, that is a narrower outcome, not a deviation.

**Tier Justification**: The new module's only externally visible effect is two import edges
(`RaySummary.lean`, `FormalSystem.lean`) plus the axiom-test pins, so guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderPin`, of `FormalSystem` (the root that now
imports it) and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus
`bash scripts/check-module-invariants.sh`, enumerate that one-hop dependent set exactly.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` - new certificate-free module, the pin-free dichotomy
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line
- `FormalSystem.lean` - one import line
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated inventory block plus the new row's description cell
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - new pin block, no existing pin changed

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPin` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0. Read the guard's `result` subcommand, never a piped exit code.
- `#print axioms` on both Goals shows `[propext, Classical.choice, Quot.sound]` or a subset, and no `sorryAx`; `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` is 0.
- The certificate-freedom grep returns nothing; `bash scripts/check-module-invariants.sh` exits 0 (inventory current, C9 clean, C14 counts match).
- `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` exits 0.
- Both Goals' signatures match the `## Lean Challenge Statements` block token for token.
- `LadderPump.lean` is unchanged and still under the package `longFile` limit of 1500 (`wc -l` is 1485 ± 0).

---

### Phase 2: The `(K2)`-Level Pigeonhole Over Region Starts [COMPLETED]

**Goal**: `LadderPin.lean`'s second half: given enough region starts in a window, two of them at
least two apart carry the same object state and the same realized type at their successor
positions, which yields a type-respecting block that SPANS a region start — the data the
refuted device would have had to construct unconditionally, now produced at a given object from
pin density alone.

**Tasks**:

- [x] `exists_pinTypeBlock_of_budget_lt_pins` (Goal, signature as pinned below) *(completed; the even-index collision is factored through one internal `key` step so the two symmetric branches of the pigeonhole share a single proof)*: with
  `s : ℕ → ℤ` strictly monotone, `N` region starts at `s 0 … s (N - 1)`, and
  `2 · (Fintype.card Q · 2 ^ (plusSubformulaClosure φ).card) + 2 ≤ N`, the map
  `i ↦ (objAt g (s (2 · i) + 1), tpOf M φ σ (s (2 · i) + 1))` on the even indices has domain
  larger than `Q × (plusSubformulaClosure φ).powerset`, so `Fintype.exists_ne_map_eq_of_card_lt`
  gives `i < j` even with `j ≥ i + 2`. Take `u := s i + 1`, `l := (s j - s i).toNat`,
  `t := s (i + 1)`. The block's interior region start is `t` (`u ≤ t` by monotonicity and
  `t + 1 < u + l` because `s (i + 1) < s j`).
- [x] Model the proof on `exists_typeBlock_of_budget_le_cnt_within` *(completed)* (`LadderPump.lean`): the same
  `Fintype.exists_ne_map_eq_of_card_lt` over `Q × {T // T ∈ (plusSubformulaClosure φ).powerset}`,
  the same `Finset.card_powerset` / `Fintype.card_prod` arithmetic, the same `rcases` on which of
  the two indices is smaller. Do NOT route through the certificate layer's `ProdState` — that is
  `LadderChain.lean`'s and is on this module's forbidden grep.
- [x] A corollary naming the spanning-block data in the shape task 836's refuted `def`s took *(completed as `exists_spanningBlock_of_pins_below`, the backward shape; the forward shape needs no corollary because the Goal already delivers `s 0 < u`, which IS `SpanningBlockFwd`'s `z < u` at `z := s 0`)*
  (`u`, `l`, the interior region start, the two endpoint equalities), so Phase 4's gate statement
  can consume it without re-deriving the tuple.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` *(completed; both pins read the standard profile)*: extend Phase 1's pin block with a
  `#guard_msgs in #print axioms` pin for the Goal and the corollary.
- [x] Record in `issues.jsonl` whether the even-index restriction was needed as written *(completed: needed exactly as written; no tighter constant fell out, and the pinned constant was not loosened)* or whether
  a tighter constant (`budget + 2` rather than `2 · budget + 2`) fell out of the proof. Do NOT
  loosen the pinned constant to match a tighter proof: a tightening is a follow-up, and the
  pinned signature is the contract (`rules/plan-compliance.md`, Statement Fidelity).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The pigeonhole is 70-120 lines (the landed model it mirrors,
`exists_typeBlock_of_budget_le_cnt_within`, is 54 lines by its own section markers in
`LadderPump.lean`, re-derived at authoring; the pin version adds the even-index bookkeeping), and
two files change: `LadderPin.lean` and the axiom test. Confirm by `wc -l` and `git diff --stat`
before the commit.

**Tier Justification**: The edit adds declarations to `LadderPin.lean` and pins in the axiom
test, changing no existing signature, so guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderPin` and
`BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check — Phase 1 already
established and verified the module's two import edges, and no third file reads the new names yet.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` - the pigeonhole over region starts and its spanning-block corollary
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins added to the Phase 1 block

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPin` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on the Goal shows no `sorryAx`; `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' …/LadderPin.lean` is 0.
- The Goal's signature matches the Challenge block token for token.
- The certificate-freedom grep still returns nothing on `LadderPin.lean`; `bash scripts/check-module-invariants.sh` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` exits 0.

---

### Phase 3: The `(K2)` Exponential Bound, and the Pin-Free Side of Both Refuting Objects [COMPLETED]

**Goal**: `LadderChain.lean` carries the arithmetic that makes pins dense wherever the register
is tight — `2 ^ Fintype.card (ProdState Q φ) ≤ Tc` from `(K2)` and `cascadeBound` alone — and a
prototype compiles that each of the two refuting objects has the pin-free side the task's route
(a) is named for, so that claim is a theorem about named objects rather than a remark.

**Tasks**:

- [x] `two_pow_card_prodState_le_Tc` (Goal, signature as pinned below) *(completed; six lines, beside `budget_le_Tc`, plus the docstring sentence)* in `LadderChain.lean`'s
  `section Budget`, beside `budget_le_Tc`: `cascadeBound pend φ = 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2)`
  by `rw [cascadeBound]`, `tIdle pend + 2 ≥ 1`, `Nat.le_mul_of_pos_right`, then `(K2)`'s first
  conjunct `hp.2.1.1`. The module docstring's budget paragraph gains one sentence: `(K2)` bounds
  `Tc` below by an EXPONENTIAL in the product carrier's cardinality, not by the carrier's
  cardinality, which is what a pigeonhole over region starts of a doubling chain consumes.
- [x] Create `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean` *(completed at 474 lines; the sibling prototype was NOT importable, so the object, the chain and both witnesses are re-declared verbatim. `tightChain_pin_count_ge` reaches the pin count through `tightChain_pin` + `nxtAt_lipschitz_two_sided` from the pin at `0` + the landed backward window, which bounds the countdown at a pending `z` by `z + 1`, rather than by extracting `z`'s region index from `idleT`; `cT_pin_succ` and `pin_eq` are read transitively through `tightChain_pin` and `tightChain_pins`)*:
  import `LadderPin`, namespace `Probe838A`, header stating it is a prototype compiled standalone
  through the build guard and NOT a wired probe. Re-declare (or import, if the 836 prototype is
  importable as written — check, do not assume) the two refuting objects `gB` and `gC` of
  `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean`
  and compile:
  - `gB_pinFree_below`: on `gB`, no pin lies at or below `-1`, so by
    `pend_past_or_idle_of_no_pin_below` the past below the single idle position at `0` is
    uniformly pending — the regime-A hypothesis holds there.
  - `gC_pinFree_above`: on `gC`, no pin lies above any `z`, which is the forward mirror and is
    exactly the fact `spanningBlockFwd_refuted` already consumes.
  - `tightChain_pin_count_ge`: on the tight doubling chain, a region at `z` of countdown at
    least `2 ^ k` forces at least `k` pins strictly below `z`. This is the quantitative half of
    route (a) and the one new mathematical step of this phase; it reads `cT_pin_succ` and
    `pin_eq` from the 836 prototype.
  Each headline gets a `#print axioms` line, as the 836 prototypes do.
- [x] Extend the axiom test's pin block with `#guard_msgs in #print axioms` for
  `two_pow_card_prodState_le_Tc`. *(completed as its own `(W)` block; the standard profile)*
- [x] Record in `issues.jsonl` whether the 836 prototype was importable or had to be re-declared,
  and what `tightChain_pin_count_ge` actually cost. *(completed: not importable, re-declared; the pin count cost roughly 30 lines)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: `two_pow_card_prodState_le_Tc` is 6-12 lines (the landed
`budget_le_cascadeBound` it mirrors is 13 lines, re-derived at authoring from `LadderChain.lean`
lines 64-76) and the prototype is 120-220 lines, most of it the two objects re-declared from the
836 prototype if they prove not to be importable. Three files change: `LadderChain.lean`, the new
prototype, the axiom test. Confirm by `wc -l` and `git diff --stat`; a prototype materially larger
than 220 lines means the objects were re-declared in full, which is a recorded outcome, not a
scope change.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
plus the same for `BimodalTest.Metalogic.KTypeSummaryAxiomTest` plus the guarded standalone
`lake env lean` of the new prototype is the complete covering check: the added theorem is a new
name no existing declaration reads, and the prototype lives under `specs/**` where no suite maps
(`suite_selection_select` returns `__FULL_SWEEP__` for it), so for the prototype the honest check
is `bash .claude/scripts/validate-artifact.sh` on no artifact and the `local` row's build of that
one file.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - `two_pow_card_prodState_le_Tc` in `section Budget`, plus one docstring sentence
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean` - new prototype, the two pin-free instances and the chain's pin-count bound
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin added

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean` reports `exit_status=0` with zero errors and zero `declaration uses 'sorry'` warnings.
- `#print axioms` on the Goal and on each prototype headline shows no `sorryAx`; `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on both changed Lean files.
- The Goal's signature matches the Challenge block token for token.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` exits 0.

---

### Phase 4: DECISION GATE — Is a Spanning Block's Length Constrained by `(K1)`? [COMPLETED]

**Goal**: ONE question, answered by a compiled object, with a named verdict recorded in the plan
and in `issues.jsonl`: a type-respecting block `[u, u + l)` that SPANS a region start — the data
Phase 2 now produces from pin density — crosses an idle position, so the landed bridge
`realized_typeBlock_mem_prodCycleLens` does not apply to it (its hypothesis `l ≤ cntAt g u` puts
the block inside one pending region). Is `l ∣ P + 1` nevertheless derivable from `(K1)`, through
`objCycleLens` or `satPeriod`, or is it not?

**VERDICT: FAIL.** `(K1)` does NOT constrain the length of a type-respecting block that spans a
pin, and the schema is refuted rather than merely unproved. The verdict object is
`Probe838B.spanningBlockLengthDvd_refuted` in
`specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean`
(`[propext, Classical.choice, Quot.sound]`, no `sorryAx`).

Mechanism, conjunct by conjunct. `prodCycleLens` and `objCycleLens` both carry
`∀ i, pend (f i) = true` on the closed walk they quantify — the walk is PENDING THROUGHOUT, which
is the region-interior restriction — and the walk a spanning block induces is idle at the index of
the pin strictly inside it, so the block's own length witnesses neither membership
(`spanning_walk_not_pending`, compiled). `objCycleLens` additionally bounds the length by
`Fintype.card Q`, which the pigeonhole's block does not respect either: its length is bounded by
the pin window. `satPeriod` is a datum of `step`, `lab` and `φ` alone and is not quantified over
block lengths at all, so it constrains `P + 1` without constraining `l`. The refuting object is
the ALTERNATING path (idle at every even position, pending at every odd one, every countdown `0`,
register constantly `0`), which for the stab-free atomic closure carries a type-respecting block
of EVERY even length with the pin at `0` strictly inside it; at the periodicity fixpoint's own
outputs, discharged by the landed `paramsOk_params`, the length `2 · (P + 1)` exceeds `P + 1` and
so cannot divide it.

Consequence: Phase 5 proceeds on its FAIL branch, and the `(K1)` amendment the analysis points at
is recorded as a follow-up candidate in Phase 6's summary, never implemented here.

**Tasks**:

- [x] State the gate as a named `def` in the prototype
  `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean`
  (namespace `Probe838B`, standalone, not wired): `SpanningBlockLengthDvd`, carrying `ParamsOk`,
  the stab-free closure hypothesis, a ladder path, and Phase 2's spanning-block tuple, concluding
  `l ∣ P + 1`. State it as a schema so the verdict is a theorem about a named object either way,
  on the precedent of `AtomPreservingCountMove` and `SpanningBlockBwd`.
- [x] Re-read `paramsOkK1`'s three conjuncts against the schema and decide which, if any, can
  carry a spanning block *(completed; see the VERDICT paragraph above — none of the three can)*: `prodCycleLens` (pending throughout — ruled out by inspection, record
  the one-line reason), `objCycleLens` (the object's own pending cycle lengths — check whether an
  idle-crossing cycle is a member), `satPeriod` (the periodicity fixpoint's period — check whether
  the block's length is forced to be a multiple of it).
- [x] PASS branch: compile `spanningBlockLengthDvd` as a theorem and record the verdict PASS with
  the conjunct it routes through. Phase 5 then proceeds on its PASS branch. *(deviation: skipped — the gate returned FAIL, so this branch does not apply)*
- [x] FAIL branch *(completed; this is the branch taken)*: compile a refuting object — a ladder path, admissible under `ParamsOk` at the
  periodicity fixpoint's own outputs for a stab-free closure, carrying a spanning type-respecting
  block whose length does NOT divide `P + 1` — and name it `spanningBlockLengthDvd_refuted`.
  Record the verdict FAIL with the mechanism. Phase 5 then proceeds on its FAIL branch. If neither
  a proof nor a refutation lands within this phase's budget, record the verdict INCONCLUSIVE with
  what was tried and what goal state was reached, close the phase `[PARTIAL]`, and let Phase 5
  take the FAIL branch — an unproved divisibility is not a usable one.
- [x] Record the verdict in `issues.jsonl` with `--class "decision gate"` and the branch named, and
  write the verdict into this plan's Phase 4 heading status line and body before closing the phase. *(completed)*
- [x] Prohibited on every branch *(honoured: no library file changed in this phase at all)*: no `sorry` in any library file, no `def X := True`, and no edit
  to `paramsOkK1` or any other `ParamsOk` conjunct. A `(K1)` amendment, if the analysis shows one
  would close the gap, is recorded as a follow-up task in Phase 6's summary — never implemented
  here.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Scope Hypothesis**: The gate's prototype is 150-300 lines, and on the FAIL branch the refuting
object is the larger half of that; one file is created and this plan file is edited (the Phase 4
verdict). No library file changes in this phase on either branch — that is the point of running
the gate in a prototype. Confirm by `git diff --stat` showing exactly the prototype and this plan
file.

**Tier Justification**: The phase touches one new `specs/**` prototype and this plan file, neither
of which any module imports, so the complete covering check is the guarded standalone
`lake env lean` of the prototype plus `bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md plan`
— the `__FULL_SWEEP__` sub-case (a) check for a `specs/**`-only edit, since no suite maps to
either path.

**Files to modify**:

- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` - new prototype, the gate's schema and its verdict object
- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` - the Phase 4 verdict recorded in this phase's heading and body

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` reports `exit_status=0`, zero errors, zero `declaration uses 'sorry'` warnings.
- `#print axioms` on the verdict headline (`spanningBlockLengthDvd` on PASS, `spanningBlockLengthDvd_refuted` on FAIL) shows no `sorryAx`.
- `grep -rn 'sorry\|:= True\|:= trivial' FormalSystem/` over the modules this task touched returns nothing new relative to `HEAD` before this phase.
- The verdict (PASS / FAIL / INCONCLUSIVE) appears verbatim in this plan's Phase 4 body, in `issues.jsonl`, and in the phase's commit message body.
- `bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md plan` exits 0.

---

### Phase 5: The Slack Accounting, Compiled — and the Mis-Anchored Blocker Withdrawn [COMPLETED]

**BLOCKER WITHDRAWN** (Phase 5):

- **What the blocker recorded**: that the FAIL branch's load-bearing clause rests on a deletion
  mirror that is not landed, with the undischargeable goal

  ```
  v : ℤ
  hv0 : pend (delObj g a l v) = false
  hv1 : pend (delObj g a l (v + 1)) = true
  ⊢ (↑(delCnt g a l (v + 1)) - ↑(nxtAt g 0)).natAbs ≤ v.natAbs
  ```

  read as an irrecoverable forward register cascade, demanded stronger than supplied by exactly
  `l`.
- **Why it does not hold**: the arithmetic is right and the anchor is wrong. The goal carries
  `nxtAt g 0`, which is the anchor VALUE the original path has at the anchor POSITION `0` that
  `exists_ladderPath_of_walk` hardwires; `n₀` is a free argument of that lemma, of
  `exists_rlad_hist_of_walk` and of `exists_ladderPath_of_walk_nxt`, discharged existentially as
  `nxtAt g' 0 = n₀`. Re-anchored at the deletion point the clause closes with zero slack to
  spare, which is exactly how the already-landed `exists_deleted_ladderPath_of_pend_past` closes
  it: it passes `nxtAt g (l : ℤ)` and finishes with
  `nxtAt_lipschitz_two_sided g hg (v + (l : ℤ)) (l : ℤ)`. The three absences the blocker
  inventoried — no iterated deletion, no downward assembly, no deletion mirror — are all landed
  names now (`exists_iterSpliced_ladderPath_idx_of_pend_past`,
  `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`,
  `exists_deleted_ladderPath_of_pend_past_nxt`), together with the cell-level downward inclusion
  on the witnessing path `mem_cellAt_of_shift_of_hasForwardSlack_exact`.
- **What is still open, stated against those names**: not the anchor, but the quantifier. The
  landed downward inclusion carries `HasForwardSlack g z (m · (P + 1)) n` on the WITNESSING path,
  and `ClimbWitness.hasForwardSlack_refuted_unconditional` compiles that no state-level
  hypothesis implies it. The obligation concludes cell EQUALITY over every path through the
  state, so what it needs is strictly weaker than a state-level regime and strictly stronger than
  the landed path-level one: for each type realized at the upper state, SOME path realizing it
  there with slack. Phase 8 gates exactly that.

**Goal**: The slack accounting of the re-anchored deletion is compiled rather than argued. The
regime holds free at amount `0`; a raise buys slack equal to exactly the raise; a deletion spends
slack equal to exactly the deleted amount. With the free baseline landed, the net-zero accounting
of every composition of the landed transports is read off two exact transports, which is what
leaves Phase 8's gate as the only remaining source of slack.

**Tasks**:

- [x] `hasForwardSlack_zero` in `LadderChain.lean`'s `section Slack`, immediately after
  `hasForwardSlack_mono`: `HasForwardSlack g z 0 (nxtAt g z)` for every ladder path, from
  `nxtAt_lipschitz_two_sided g hg (z + cntAt g z + I) z` and `omega`. Signature pinned in the
  Challenge block below; two lines of proof.
- [x] `hasForwardSlack_raise_of_zero` in the same section *(deviation: altered — placed after `hasForwardSlack_raise` rather than beside `hasForwardSlack_zero`; the composite consumes it, so the literal reading forward-references and the first scoped build failed with `Unknown identifier hasForwardSlack_raise`. Still inside `section Slack` as the task specifies.)*: the raised path of
  `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` carries
  `HasForwardSlack g' z (d · l) (nxtAt g z)` — the composite of `hasForwardSlack_zero` with the
  landed `hasForwardSlack_raise`, which increases the amount by exactly `d · l`. Its docstring
  states the accounting in full: baseline `0` free, raise `+ d · l`, deletion `− l` per step, so
  no composition of the two transports yields slack exceeding the total raised amount, and a
  raise-then-delete round trip is net zero at `z`.
- [x] Do NOT restate the accounting as a theorem quantified over compositions *(honored: the accounting is stated in `hasForwardSlack_raise_of_zero`'s docstring, not as a theorem)*. The two exact
  transports already say it; a theorem quantifying over "every composition" would need a
  reification of the transports this layer does not have, and inventing one here is scope the
  gate does not need.
- [x] Axiom-test pin for `hasForwardSlack_zero` *(deviation: altered — pinned to the MEASURED profile `[propext, Quot.sound]`, which is strictly less than the standard profile the plan predicted; `nxtAt_lipschitz_two_sided` consumes no choice. The narrative line says so explicitly.)* in
  `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, inside the existing obligation block,
  plus one narrative line saying the baseline is free and the two transports are exact.
- [x] Record the blocker's withdrawal *(recorded as `kind: win`, class `design-record defect`, severity `blocking`)* with
  `bash .claude/scripts/issue-record.sh --task 838 --kind win --class "design-record defect"
  --severity blocking --phase implement --resolution fixed_inline --what-happened "..."`, naming
  the wrong anchor and the landed re-anchored deletion. The withdrawal is recorded, not
  back-edited out of the log.
- [x] Prohibited *(honored: `lean-sorry-census.sh` reports `sorry_count: 0` over every source root; the vacuity and `^axiom ` counts are unchanged from HEAD on every changed file; `longFile` stays at 2300 with the file at 2267)*: no `sorry`, no `def X := True`, no vacuous placeholder, and no baseline bump on
  `LadderChain.lean`'s `longFile` option to make the two lemmas fit. If they do not fit, they
  move to `LadderCell.lean` with Phase 7.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Two short lemmas (together 25-40 lines with docstrings) added to
`LadderChain.lean`, bringing it to 2252-2267 lines against its own baseline of 2300, plus one
pin and one narrative line in the axiom test. Two files change. Confirm by `wc -l` on
`LadderChain.lean` reporting under 2300 and by `git diff --stat` showing exactly those two files.

**Tier Justification**: The phase adds two exported theorems to `LadderChain.lean` and a pin to
the axiom test, so the covering check is the guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, of `FormalSystem` (the root), and of
`BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus `bash scripts/check-module-invariants.sh` —
that enumerated one-hop dependent set is everything a new exported theorem in an imported module
can reach, and nothing in it is a shared tactic or a core type.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - `hasForwardSlack_zero` and `hasForwardSlack_raise_of_zero` in `section Slack`
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin plus one narrative line in the obligation block
- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` - this phase's status line

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on `hasForwardSlack_zero` and `hasForwardSlack_raise_of_zero` shows `[propext, Classical.choice, Quot.sound]` or less, and no `sorryAx`.
- `hasForwardSlack_zero`'s signature matches the Challenge block token for token.
- `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is under 2300, and `grep -n 'longFile' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` still reports `2300`.
- `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is 0.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on both changed library files.

**Verification notes (as run)**: all three scoped builds exit 0 through the guard with zero
`error:` lines — `… -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`,
`… -- build FormalSystem`, `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` — and both
touched modules' `.olean` files are newer than their sources. `#print axioms` on
`hasForwardSlack_zero` reports `[propext, Quot.sound]`, strictly less than the standard profile
and with no `sorryAx`; the pinned `#guard_msgs` docstring matches it. `hasForwardSlack_zero`'s
signature matches the Challenge block token for token modulo the block's own stated ASCII
convention (`->`/`Int` there, `→`/`ℤ` in the library). `wc -l` on `LadderChain.lean` reports 2267
against an unbumped `longFile` baseline of 2300. `lean-sorry-census.sh` over every resolved
source root reports `sorry_count: 0`. The `grep -cE 'sorry|…'` criterion reports 1, unchanged
from HEAD: a pre-existing DOCSTRING sentence at line 1445 (“is not a disguised `sorry`”), not a
declaration. `check-module-invariants.sh` exits 0 after regenerating the three generated
inventory blocks (`--emit-inventory`, line-counts only) that this phase's 40 added lines made
stale; `check-task-references.sh --quiet` exits 0 on each of the five changed non-`specs/**`
files. This phase's tier is `interface`, so the dispatch's batch-gate deferral directive (which
scopes a `full`-tier phase) does not apply to it — every check enumerated above was run here
rather than deferred.

---

### Phase 6: Records, the Full Gate Set, and the Summary [COMPLETED]

**Goal**: Every record that states the depth-`0` obligation's status says what this task
established; the complete gate set runs green; the summary hands task 761's reviser the branch
verdict and, on the FAIL branch, the exact hypothesis its induction must now supply.

**Tasks**:

- [x] `FormalSystem/Metalogic/Decidability/RaySummary/README.md` *(completed: two new narrative paragraphs — the pin layer and what it settles, and `(K1)`'s non-constraint of a spanning block's length, with the reserved name's continued reservation stated explicitly)*: the narrative sections that
  state the obligation's status are brought current with Phase 4's verdict and Phase 5's branch;
  the pin layer gets its paragraph beside the pump layer's. Durable anchors only — module names,
  declaration names, section headings — no task numbers.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` *(completed; the obligation block's narrative now names both halves of the pin layer, the exponential `(K2)` reading, and that no regime-restricted variant is claimed either)*: the `(W)` requirement narrative
  states what the pins now certify, including that the `(K2)` bound is exponential and what the
  pin layer's two halves are.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 and reports all wired probes compiling. *(completed: exit 0, `all 47 wired probe(s) compile`; both of this task's prototypes stay prototypes, and wiring the gate's refuting object is recorded as a follow-up candidate in the summary)* The
  two prototypes of this task are NOT wired — they stay prototypes under
  `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/`. If Phase 4's verdict was FAIL
  and its refuting object is the kind of record a wired probe should hold in place, record that as
  a candidate follow-up in the summary rather than wiring it here.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0; all three
  generated inventory blocks are current. *(completed: exit 0; FOUR blocks were in play across the task, as Phase 1 recorded)*
- [x] Write `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md` *(completed; `validate-artifact.sh ... summary` exits 0)*
  per `summary-format.md`: the branch taken, the verdict with its mechanism, every declaration
  landed with its axiom profile, what remains open, and the named follow-up candidates (a `(K1)`
  amendment on the FAIL branch; a tighter pigeonhole constant if Phase 2 found one; wiring Phase
  4's refuting object as a probe if applicable).
- [x] Run the complete gate set and read its verdict, not a piped exit code. *(completed: `verify-deploy.sh` with no gate filter and no `--skip-slow` reports `PASS -- 15 check(s), 0 failure(s)`, exit 0; the unscoped full `lake build` reports `exit_status=0` with zero `error:` and `.olean` newer than source on every touched module)*

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: Three record files plus the summary change (the `RaySummary/README.md`
narrative, the axiom test's `(W)` prose, and any inventory block the regeneration moves), and no
Lean declaration is added or removed in this phase. Confirm by `git diff --stat` showing no change
to any `theorem` or `def` line (`git diff -U0 -- 'FormalSystem/**/*.lean' | grep -cE '^[+-](theorem|def|lemma|abbrev)'` is 0).

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - narrative sections brought current
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - `(W)` requirement narrative, no pin changed
- `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md` - new, the task summary

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete gate set, every gate, no `--only-gate` filter and no `--skip-slow`. A selected-subset or `--skip-slow` pass does NOT satisfy this phase.
- `bash scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 over every file this task changed.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) exits 0, read through the guard's `result` subcommand.
- `grep -rcE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on every `FormalSystem/` file this task touched.
- `bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md summary` exits 0.
- The summary names the branch verdict and, on the FAIL branch, the reserved name's continued reservation.

---

### Phase 7: `LadderCell.lean` — the Common-Shift Sub-Regime and the Collision Case Split [COMPLETED]

**Goal**: A new module `LadderCell.lean` beside `LadderChain.lean`, importing it alone, holding
the cell-level material `LadderChain.lean` has no room for: the UPWARD inclusion in the
common-shift sub-regime `n' = n + m · (P + 1)`, which the landed
`cellAt_subset_of_shift_of_pend_past` docstring names and does not state, and the
`kappa`-collision case split that reduces the obligation's hypothesis to the two sub-regimes the
landed inclusions address. Both are useful on either branch of Phase 8.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` with a contract
  docstring stating its one argument (the cell level: inclusions between cells at
  `kappa`-colliding counter states, and nothing about pumps or pins), and wire it into
  `FormalSystem/Metalogic/Decidability/RaySummary.lean` and `FormalSystem.lean`.
- [x] `cellAt_subset_of_common_shift_of_pend_past`: in the pending-forever regime (`n + 2 ≤ c`)
  at countdown at least `Tc`, the cell at `(q, c, n)` is contained in the cell at
  `(q, c + m · (P + 1), n + m · (P + 1))`. The construction is the landed register-held iterated
  duplication read through `exists_ladderPath_of_walk_nxt_at` with the anchor parameter
  `n₀ := n + m · (P + 1)` instead of `n₀ := nxtAt g z`; the anchor clause closes from the widened
  window, because the duplication raises the countdown at `z` by exactly `m · (P + 1)` while the
  pins above `z` keep their countdowns, so the pin bound has exactly `m · (P + 1)` more room than
  it needs at the base pin. Signature pinned in the Challenge block below.
- [x] If that anchor clause does NOT close from the widened window, do not weaken the statement
  and do not substitute a different one: close this phase `[BLOCKED]`, record the goal state
  reached verbatim, and let Phase 9 proceed on the sub-regime `n' = n` alone. The case split
  below lands either way, so the phase has a deliverable even then. *(escape NOT taken: the anchor clause closed from the widened window as predicted, so the statement landed unweakened at the pinned signature)*
- [x] `kappa_collision_regimes`: a `kappa`-collision `kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')`
  at a common object state, under `ParamsOk`, is in exactly one of the two sub-regimes the landed
  inclusions address — a common shift of both coordinates by a multiple of `P + 1`, or an equal
  register with the countdowns differing by such a multiple. Prove it from the landed destructors
  `kappa_eq_components`, `eq_or_both_ge_of_min_eq` and `clipIdx_regime_of_eq` (the last needs
  `2 ≤ B`, which `(K4)` supplies), with `kappa_eq_of_shift` as the non-vacuity witness. State it
  as a disjunction over named arithmetic facts, not over cells, so Phase 9 can consume it on
  either branch. *(deviation: altered — landed as a THREE-branch disjunction, not two. The planned two-branch shape is NOT derivable from the three named destructors plus `(K4)`'s `2 ≤ B`: the gap coordinate clips at `B`, so a collision whose gaps are both saturated at the clip on the same side of the window satisfies neither alternative. `kappa_collision_two_regimes_refuted` is the compiled refutation, at `Tc = Tn = P = 0`, `B = 2` and the pairs `(0, 2)`, `(0, 3)`; it refutes that derivation alone and asserts nothing about the two-branch form under full `ParamsOk`. The statement was explicitly unpinned in the Challenge block as a composite whose exact shape is fixed by the landed transports it composes, which is the latitude this alteration uses. Phase 9 must dispatch or exclude the third branch.)*
- [x] Regenerate the inventory blocks and add the hand-written description cell for the new
  module: `bash scripts/check-module-invariants.sh --emit-inventory` then `--check`.
- [x] Axiom-test pins for both new theorems, inside the obligation block. *(three pins: the two named theorems plus `kappa_collision_two_regimes_refuted`)*
- [x] Prohibited: no `sorry`, no vacuous placeholder, no statement under the reserved name
  `cellLE_zero_const_of_kappa_eq`, and no edit to any `ParamsOk` conjunct.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: One new module of 150-250 lines, two root import lines, the three generated
inventory blocks plus one hand-written description cell, and two axiom-test pins — six or seven
files. No existing proof changes. Confirm by `git diff --stat` and by
`git diff -U0 -- 'FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean' | grep -cE '^[+-](theorem|def|lemma)'` being 0.

**Tier Justification**: The phase adds a NEW leaf module plus two root import lines, so nothing
imports it yet and the covering check is the guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`, of `FormalSystem` (the root, which
the new import line changes), and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (the pins),
plus `bash scripts/check-module-invariants.sh` for the inventories — a leaf module reaches no
other dependent.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - new module: the common-shift inclusion and the collision case split
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line
- `FormalSystem.lean` - one import line
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated inventory block plus the hand-written description cell
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on both new theorems shows no `sorryAx`.
- `cellAt_subset_of_common_shift_of_pend_past`'s signature matches the Challenge block token for token.
- `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` is 0.
- `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` shows the reserved name on docstring lines only, with no `theorem` or `def` claiming it.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed file.

#### Verification Notes (dispatch 6)

All of this phase's own `interface`-tier criteria were run and are green:

| Check | Result |
|-------|--------|
| guarded scoped build `… LadderCell` | exit 0, zero `error:`, zero `warning:` |
| guarded scoped build `… FormalSystem` | exit 0, zero `error:`, 2,969 jobs |
| guarded scoped build `… BimodalTest.Metalogic.KTypeSummaryAxiomTest` | exit 0, 2,411 jobs |
| `#print axioms` on the three new pins | standard profile on the two positive results, `propext`/`Quot.sound` on the refutation; no `sorryAx` |
| pinned signature of `cellAt_subset_of_common_shift_of_pend_past` | matches the Challenge block token for token (modulo the block's stated ASCII) |
| vacuity grep on `LadderCell.lean` | 0 matches |
| reserved name `cellLE_zero_const_of_kappa_eq` | 10 occurrences repo-wide, all docstring/prose; 0 claimed by a `theorem`/`def`/`lemma` |
| `check-module-invariants.sh --check` | exit 0, ALL CHECKS PASSED |
| `check-task-references.sh --quiet` | exit 0 |
| declaration churn in `LadderChain.lean` | 0 — no existing proof changed |

Scope hypothesis confirmed with one addition: the root `README.md` inventory totals block is a
FOURTH generated block the regeneration rewrites (750 live files, 214,323 lines), so the change is
eight files plus the new module rather than six or seven. `KTypeSummaryAxiomTest.lean`'s recorded
`longFile` ceiling was raised from 2,100 to 2,200 to admit the three new pins and their prose;
`LadderChain.lean`'s own 2,300 baseline was NOT touched and its line count is unchanged at 2,267.

The complete gate set declared by this plan's final phase was NOT independently run here — it is
deferred to the batch stage of the invocation that dispatched this phase, per the dispatch's batch
gate deferral and `context/contracts/phase-closure.md`'s no-promotion-without-evidence carve-out.
This phase's tier is `interface`, and its covering checks are the three guarded scoped builds and
the module-invariants run above, all green.

---

### Phase 8: DECISION GATE — Does Lengthening the Idle Gap Buy the Missing Slack Type-Respectingly? [COMPLETED]

**Goal**: ONE question, answered by a compiled object, with a named verdict recorded in this plan
and in `issues.jsonl`. The anchor clause of the re-anchored deletion is short by exactly `l` in
its upper direction `nxtAt g s₀ ≤ n + cntAt g z + I − l`, where `I` is the length of the idle run
between `z`'s region and the first region start above it. Inserting `l` idle positions into that
run raises `I` by `l` and so supplies exactly the missing amount, and `pinCompat_of_ladderPath`
does not forbid it: moving a region start FARTHER from `z` while holding its countdown makes the
pin demand strictly looser, the opposite of the pending-block splice that is refuted on a
pin-tight original. The question is whether the lengthened path is (i) an admissible ladder path
with the register at `z` held, and (ii) realizing the SAME stab-free type at `z`.

**Tasks**:

- [x] State the gate as a named `def` in a new prototype
  `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean`
  (namespace `Probe838C`, standalone, not wired): `IdleGapLengthening`, carrying `ParamsOk`, the
  stab-free closure hypothesis, a ladder path `g` pending forever into the past at `z` with
  `Tc ≤ cntAt g z`, the idle run of length `I` above `z`'s region and the region start after it,
  and an amount `l`; concluding the existence of a ladder path `g'` with `objAt g' z = objAt g z`,
  `cntAt g' z = cntAt g z`, `nxtAt g' z = nxtAt g z`, an idle run of length `I + l` above `z`'s
  region, the same countdown at the displaced region start, and the same realized stab-free type
  at `z`. State it as a schema so the verdict is a theorem about a named object either way, on
  the precedent of `SpanningBlockBwd` and `SpanningBlockLengthDvd`.
- [x] Sub-question (i), ADMISSIBILITY *(answered NEGATIVELY by a refuting object rather than by building the walk: on the refuting object no lengthened walk exists at all, so there is nothing to discharge the five clauses against — this is the phase's own FAIL branch firing, not a substituted step)*: build the lengthened walk and its countdown explicitly
  (idle positions carry countdown `0`; everything above the gap is displaced by `+ l`), and
  discharge the five counter and pin clauses of `exists_ladderPath_of_walk_nxt_at` with the
  anchor `n₀ := nxtAt g z` at the anchor position `z`. The pin clause is the one to check against
  `pinCompat_of_ladderPath`: the displaced region starts keep their countdowns while every
  pairwise distance either grows or is unchanged.
- [x] Sub-question (ii), TYPE PRESERVATION *(NOT REACHED — the refutation closes at sub-question (i) from `step` alone; the type clause is carried in the schema's conclusion and is the conjunct the refutation never consumes. Recorded as untouched in the prototype's own verdict block)*: decide whether the realized stab-free type at `z` is
  held. The inserted positions are in `z`'s future, so this is a claim about `U` formulas of the
  closure; the landed transports to try first are `tpOf_stabFree_eq_of_objAt_eq` (an object-level
  agreement) and the two index-map transports of the pump layer. If the type is NOT held, the
  refuting object is a closure formula and a path on which the lengthened path's type at `z`
  differs — compile it.
- [x] PASS branch *(not taken)*: compile `idleGapLengthening` as a theorem and record the verdict PASS with the
  transport it routes through. Phase 9 then proceeds on its PASS branch.
- [x] FAIL branch: compile a refuting object, name it `idleGapLengthening_refuted`, record the
  verdict FAIL with the mechanism, and name in the record which of the two sub-questions failed —
  admissibility or type preservation. Phase 9 then proceeds on its FAIL branch. If neither a
  proof nor a refutation lands within this phase's budget, record the verdict INCONCLUSIVE with
  what was tried and what goal state was reached, close the phase `[PARTIAL]`, and let Phase 9
  take the FAIL branch: an unproved lengthening is not a usable one.
- [x] Record the verdict with
  `bash .claude/scripts/issue-record.sh --task 838 --kind issue --class "decision gate" --severity costly --phase implement --what-happened "..."`
  with the branch named, and write the verdict into this phase's heading status line and body
  before closing the phase.
- [x] Prohibited on every branch: no `sorry` in any library file, no `def X := True`, no edit to
  any `ParamsOk` conjunct, and no library file changed at all — the gate runs in a prototype by
  construction.

**VERDICT: FAIL — on sub-question (i), ADMISSIBILITY.** The schema `IdleGapLengthening` is stated
in `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean`
(namespace `Probe838C`) and REFUTED there by the compiled object `idleGapLengthening_refuted`, on
the standard axiom profile `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.

**The mechanism.** `pinCompat_of_ladderPath` is indeed not the obstruction — the obstruction sits
one level BELOW it, in `step` itself. A ladder path's object walk satisfies
`step (objAt g v) (objAt g (v + 1)) = true` at every position, so an idle run of length two
requires an idle-to-idle edge in the object's step graph, and an object need not have one. The
generic reading is `no_consecutive_idle_of_no_idle_step`: if
`∀ x y, pend x = false → pend y = false → step x y = false` then every idle position of every
ladder path is followed by a pending one. The witness is the two-state object `Qo := Bool`
(`pendO = id`, `stepO x y = x || y`, so exactly the idle-to-idle edge is missing), serial in both
directions (`fwdO`, `bwdO`), carrying the witnessing path of `exists_gO`: one region of countdown
`T_c` through `z = 0` with the register constantly `0`, pending forever into its past, then idle
runs of length exactly one. At `I = 1`, `l = 1` that path satisfies every hypothesis of the schema
— the gap `0 + 2 ≤ T_c` from `(K3)`'s `2 · T_short + T_idle + 2 ≤ T_c` (`two_le_TcO`), the
countdown bound `T_c ≤ cntAt g 0`, and the idle run `{T_c + 1}` followed by the region start at
`T_c + 2` — while the conclusion asks for a ladder path idle at BOTH `T_c + 1` and `T_c + 2`, which
no ladder path on this object is. The parameters are the periodicity fixpoint's own outputs for the
stab-free atomic closure `aO`, discharged by the landed `paramsOk_params`, so the refutation sits
at a tuple the parameter conditions genuinely admit.

**What the verdict settles.** The idle run's length is a datum of the object's step graph, not a
parameter the construction may raise. The lengthening is therefore NOT a theorem of the schema and
cannot be promoted to the slack-normalization lemma the downward cell inclusion would consume.
Phase 9 takes its FAIL branch.

**What the verdict does not settle.** Sub-question (ii), TYPE PRESERVATION, is UNTOUCHED: the
refutation closes from `step` alone and never reaches the type clause, so nothing here says whether
a lengthened path, where one exists, holds the realized stab-free type at `z`. Nor does the verdict
say the lengthening fails on every object: an object whose idle states carry a reachable cycle
admits longer idle runs, and `tIdle`'s own shape (`#idle states + 1`) is the bound above which an
idle run must repeat an idle state and so become duplicable. The sharpening — the lengthening is
available exactly where the object's idle states carry a reachable cycle — is an OBJECT hypothesis
and not a consequence of `ParamsOk`; assuming it would be a restriction of the obligation, not a
proof of it. The verdict refutes neither the depth-`0` cell obligation nor any `ParamsOk` conjunct.

**Verification notes.** `bash .claude/scripts/lake-build-guard.sh build --timeout 840 -- env lean
specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` reports
`exit_status=0` with zero `error:` and zero `warning:` lines and no `declaration uses 'sorry'`;
`#print axioms` on both headline objects shows no `sorryAx`. `git diff --stat` shows no
`FormalSystem/` or `Tests/` file changed by this phase. This phase's own tier is `local`, so the
batch-stage deferral the dispatch directive describes for the plan's FINAL phase
(`Verification Tier: full`) does not apply to it; the complete gate set remains Phase 10's
obligation and is deferred to the batch stage there, not forgiven.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The prototype is 200-400 lines, and on the FAIL branch the refuting object
is the larger half of it; one file is created and this plan file is edited (the verdict). No
library file changes on either branch. Confirm by `git diff --stat` showing exactly the prototype
and this plan file.

**Tier Justification**: The phase touches one new `specs/**` prototype and this plan file, neither
of which any module imports, so the complete covering check is the guarded standalone
`lake env lean` of the prototype plus
`bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md plan`
— the `__FULL_SWEEP__` sub-case (a) check for a `specs/**`-only edit, since no suite maps to
either path.

**Files to modify**:

- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` - new prototype: the gate's schema and its verdict object
- `specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md` - the verdict recorded in this phase's heading and body

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- env lean specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` reports `exit_status=0`, zero errors, zero `declaration uses 'sorry'` warnings.
- `#print axioms` on the verdict headline (`idleGapLengthening` on PASS, `idleGapLengthening_refuted` on FAIL) shows no `sorryAx`.
- `git diff --stat` shows no `FormalSystem/` or `Tests/` file changed by this phase.
- The verdict (PASS / FAIL / INCONCLUSIVE) appears verbatim in this phase's body, in `issues.jsonl`, and in the phase's commit message body.
- `bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md plan` exits 0.

---

### Phase 9: Close the Obligation — GATED ON PHASE 8 [IN PROGRESS]

**Goal**: On Phase 8's PASS verdict, the lengthening is promoted to a slack-normalization lemma —
every type realized at the upper state is realized there by SOME path with forward slack — which
with the landed `mem_cellAt_of_shift_of_hasForwardSlack_exact` gives the state-level downward
inclusion, and with Phase 7's upward inclusions and case split gives
`cellLE_zero_const_of_kappa_eq` under the reserved name. On FAIL or INCONCLUSIVE, the
forward-slack-restricted obligation is stated and compiled under a NEW name, the record names
exactly what the consumer must supply, and the reserved name stays reserved and claimed by
nothing.

**Tasks** (PASS branch):

- [ ] `exists_hasForwardSlack_realizing_of_pend_past` in `LadderCell.lean`: for a path `g`
  through `(q, c + m · (P + 1), n)` in the pending-forever regime at countdown at least `Tc`,
  a path `g''` through the SAME state with the SAME realized stab-free type at `z` and
  `HasForwardSlack g'' z (m · (P + 1)) n`, by `m · (P + 1)` applications of Phase 8's lengthening
  to the idle gap above `z`'s region. This is the one statement the gate's PASS verdict buys and
  the climbing-register refutation does not touch, because it is existential over paths rather
  than universal.
- [ ] `cellAt_subset_of_shift_of_pend_past_rev`: the state-level downward inclusion, from the
  normalization lemma and `mem_cellAt_of_shift_of_hasForwardSlack_exact`.
- [ ] `cellLE_zero_const_of_kappa_eq : CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B`
  in `LadderCell.lean`, from the two inclusions in each sub-regime: Phase 7's
  `kappa_collision_regimes` splits the collision, `cellAt_subset_of_shift_of_pend_past` and
  `cellAt_subset_of_common_shift_of_pend_past` give the upward halves, and
  `cellAt_subset_of_shift_of_pend_past_rev` with its common-shift mirror gives the downward
  halves.
- [ ] `LadderAgree.lean`: the obligation section's docstrings and `CellLEZeroConstOfKappaEq`'s own
  docstring now say the schema is a THEOREM under `ParamsOk`, name `LadderCell.lean` as its home,
  and keep the pre-repair refutation's record intact (it refutes a different, frozen predicate).
  Current-design language only; no task number.
- [ ] Axiom-test pin for `cellLE_zero_const_of_kappa_eq`, and the `(W)` prose block amended to
  say the obligation is proved rather than open.

**Tasks** (FAIL / INCONCLUSIVE branch):

- [ ] State the restricted obligation in `LadderCell.lean` under a NEW name —
  `CellLEZeroConstOfKappaEqForwardSlack` for the schema and
  `cellLE_zero_const_of_kappa_eq_of_forwardSlack` for the theorem — carrying, in addition to
  `ParamsOk` and the stab-free hypothesis, the forward-slack regime as an explicit hypothesis on
  the witnessing path of the higher state, which is the hypothesis
  `mem_cellAt_of_shift_of_hasForwardSlack_exact` already consumes, and prove it from the landed
  upward inclusion, Phase 7's common-shift inclusion and case split, and that landed downward
  inclusion. The statement must conclude the SAME relation its name advertises: if what closes is
  an inclusion rather than an equality, name it an inclusion.
- [ ] `cellLE_zero_const_of_kappa_eq` stays reserved. Verify by
  `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returning only docstring lines,
  and state in the new schema's docstring that it is NOT the reserved statement, which hypothesis
  it adds, on which path that hypothesis sits, and that the unrestricted schema is neither proved
  nor refuted under `ParamsOk`.
- [ ] Record, in the new schema's docstring and in Phase 10's summary, exactly what the consumer
  (task 761's Phase 11.6 induction) must supply to use the restricted form — a forward-slack
  witness at each state it inducts through — and name as candidate follow-ups, without creating
  them, the two routes the gate's FAIL verdict leaves: a `(K1)` amendment, and a restatement of
  the obligation over a slack-carrying sub-class of paths.
- [ ] Axiom-test pin for the new theorem; the `(W)` prose block says the obligation is open and
  the restricted form is proved.
- [ ] Prohibited on both branches: no `sorry`, no `def X := True`, no vacuous placeholder, and no
  narrowed, regime-restricted or otherwise weakened statement under the reserved name. A weaker
  statement under the PLANNED new name is equally prohibited: that is the one defect
  `rules/plan-compliance.md` exists to catch.

**Timing**: 2 hours

**Depends on**: 7, 8

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: On either branch the assembly is 120-300 lines added to `LadderCell.lean`
(bringing it to 270-550 lines, well under the package `longFile` limit of 1500), and three or
four files change: `LadderCell.lean`, the axiom test, and on the PASS branch `LadderAgree.lean`'s
obligation docstrings. Confirm by `wc -l` and `git diff --stat`.

**Tier Justification**: The phase adds theorems to `LadderCell.lean` and, on the PASS branch,
edits `LadderAgree.lean` docstrings that every `RaySummary` module transitively imports, so the
covering check is the guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`, of `FormalSystem` (the root), and of
`BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus `bash scripts/check-module-invariants.sh` —
that enumerated one-hop dependent set is what a docstring edit to an imported module and a new
exported theorem can reach, and nothing in it is a shared tactic or a core type.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - the closing assembly and the obligation (reserved name on PASS, new name on FAIL)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - obligation-section docstrings only, PASS branch only
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin plus the `(W)` prose block

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on the landed theorem (`cellLE_zero_const_of_kappa_eq` on PASS, `cellLE_zero_const_of_kappa_eq_of_forwardSlack` on FAIL) shows `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` is 0.
- On the FAIL branch only: `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` shows the reserved name on docstring lines only, with no `theorem` or `def` claiming it.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed file.

---

### Phase 10: Records, the Full Gate Set, and the Summary Brought Current [NOT STARTED]

**Goal**: Every record that states the depth-`0` obligation's status says what the revised phases
established; the complete gate set runs green; the existing summary is brought current so task
761's reviser reads one document, not two.

**Tasks**:

- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: the narrative paragraphs that
  state the obligation's status are brought current with Phase 8's verdict and Phase 9's branch,
  and the new module gets its inventory row and description cell. The paragraph that currently
  ends "the gap between it and the obligation is the tight (doubling) chain, no finite
  deletion-derivative of which lifts (argued, not compiled)" is replaced by what the gate
  compiled. Durable anchors only — module names, declaration names, section headings — no task
  numbers.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: the `(W)` requirement narrative
  states what the pins now certify, including the free slack baseline and the gate's verdict.
- [ ] Bring `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md`
  current in place — same round, same path — so it carries the withdrawal of the Phase 5 blocker,
  every declaration landed by Phases 5, 7 and 9 with its axiom profile, Phase 8's verdict with
  its mechanism, what remains open, and the named follow-up candidates. Do not write a second
  summary file for the same round.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 and reports all wired probes compiling. The
  three prototypes of this task stay prototypes; if Phase 8's refuting object is the kind of
  record a wired probe should hold in place, record that as a candidate follow-up in the summary
  rather than wiring it here.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0; every generated
  inventory block is current.
- [ ] Run the complete gate set and read its verdict, not a piped exit code.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: Three record files plus the summary change (the `RaySummary/README.md`
narrative and inventory, the axiom test's `(W)` prose, and any inventory block the regeneration
moves), and no Lean declaration is added or removed in this phase. Confirm by
`git diff -U0 -- 'FormalSystem/**/*.lean' | grep -cE '^[+-](theorem|def|lemma|abbrev)'` being 0.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - narrative sections and inventory brought current
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - `(W)` requirement narrative, no pin changed
- `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md` - brought current in place

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete gate set, every gate, no `--only-gate` filter and no `--skip-slow`. A selected-subset or `--skip-slow` pass does NOT satisfy this phase.
- `bash scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 over every file this task changed.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, unscoped) exits 0, read through the guard's `result` subcommand.
- `grep -rcE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on every `FormalSystem/` file this task touched.
- `bash .claude/scripts/validate-artifact.sh specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md summary` exits 0.
- The summary names Phase 8's verdict and, on its FAIL branch, the reserved name's continued reservation.

---


## Lean Challenge Statements

The six `theorem` declarations below are this plan's Goals and carry `sorry` bodies, listed in
the order the phases prove them (Phase 1's two, Phase 2's one, Phase 3's one, Phase 5's one,
Phase 7's one). Every landed object (`LadderState`, `IsLadderPath`, `objAt`, `cntAt`, `nxtAt`,
`tpOf`, `ladderModel`, `ladderFrameAdm`, `RladAdm`, `plusSubformulaClosure`, `ParamsOk`,
`ProdState`, `HasForwardSlack`, `cellAt`, `Adm`, `kappa`) is imported from the library rather
than pinned, because it is landed. Identifiers are ASCII for the snapshot tool's regex.

Phase 4's gate schema, Phase 8's gate schema and Phase 9's closing theorem are deliberately NOT
pinned here: a pinned signature asserts that the statement is the intended one, and whether the
unrestricted obligation is provable is exactly what the two gates decide. Pinning any of them
would pin a statement this plan cannot vouch for. Phase 5's second lemma
(`hasForwardSlack_raise_of_zero`) and Phase 7's `kappa_collision_regimes` are also unpinned:
both are composites whose exact shape is fixed by the landed transports they compose, and their
task text names those transports instead.

The first four declarations were elaborated standalone at this plan's original authoring time
through the build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean <file>`):
`exit_status=0`, zero errors, exactly four `declaration uses 'sorry'` warnings — one per theorem.
The last two (`hasForwardSlack_zero`, `cellAt_subset_of_common_shift_of_pend_past`) were
elaborated the same way at this revision, in the namespace `Probe838R` against the same import:
`exit_status=0`, zero errors, exactly two `declaration uses 'sorry'` warnings.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe838P

theorem pend_past_or_idle_of_no_pin_below {Q : Type} {pend : Q -> Bool}
    (g : Int -> LadderState Q pend) (p : Int)
    (hnp : forall s : Int, s + 1 <= p -> pend (objAt g s) = false ->
      pend (objAt g (s + 1)) = true -> False) :
    (forall v : Int, v <= p -> pend (objAt g v) = false)
      \/ (exists v : Int, v <= p /\ forall w : Int, w <= v -> pend (objAt g w) = true) := sorry

theorem pendPast_or_cntAt_le_nxtAt_succ {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    (g : Int -> LadderState Q pend) (hg : IsLadderPath step pend g) (z : Int)
    (hz : pend (objAt g z) = true) :
    (forall w : Int, w <= z -> pend (objAt g w) = true) \/ cntAt g z <= nxtAt g z + 1 := sorry

theorem exists_pinTypeBlock_of_budget_lt_pins {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) {g : Int -> LadderState Q pend}
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (s : Nat -> Int) (hmono : StrictMono s) (N : Nat)
    (hN : 2 * (Fintype.card Q * 2 ^ (plusSubformulaClosure phi).card) + 2 <= N)
    (hpin : forall i : Nat, i < N ->
      pend (objAt g (s i)) = false /\ pend (objAt g (s i + 1)) = true) :
    exists (u : Int) (l : Nat) (t : Int), 0 < l /\ u <= t /\ t + 1 < u + (l : Int) /\
      s 0 < u /\ u + (l : Int) <= s (N - 1) + 1 /\
      pend (objAt g t) = false /\ pend (objAt g (t + 1)) = true /\
      objAt g u = objAt g (u + (l : Int)) /\
      tpOf (ladderModel step pend fwd bwd lab) phi sigma u
        = tpOf (ladderModel step pend fwd bwd lab) phi sigma (u + (l : Int)) := sorry

theorem two_pow_card_prodState_le_Tc {Q : Type} [Fintype Q] (step : Q -> Q -> Bool)
    (pend : Q -> Bool) (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B) :
    2 ^ Fintype.card (ProdState Q phi) <= Tc := sorry

end Probe838P
```

The two statements added at this revision, elaborated against the same import:

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe838R

theorem hasForwardSlack_zero {Q : Type} {pend : Q -> Bool} {step : Q -> Q -> Bool}
    (g : Int -> LadderState Q pend) (hg : IsLadderPath step pend g) (z : Int) :
    HasForwardSlack g z 0 (nxtAt g z) := sorry

theorem cellAt_subset_of_common_shift_of_pend_past {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (hno : forall chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure phi)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q) (m : Nat)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 <= c) (hTc : Tc <= c) (z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) phi
        ((z, ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

end Probe838R
```

## Testing & Validation

- [ ] Each of the six Goals is a `theorem` whose signature matches the Challenge block token for token, with `#print axioms` showing no `sorryAx`.
- [ ] `wc -l` on `LadderChain.lean` reports a count below its own `longFile` baseline of 2300, and that baseline is not bumped.
- [ ] `LadderCell.lean` compiles, carries its own contract docstring, and is reachable from both root imports.
- [ ] All three prototypes compile standalone through the build guard with zero errors and zero `sorry` warnings.
- [ ] `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on `LadderPin.lean`, `LadderChain.lean`, and every other `FormalSystem/` file this task changes.
- [ ] `LadderPin.lean` passes the certificate-freedom grep `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod` with no match.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 (no probe count changes — the two new files are prototypes, not wired probes).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed non-`specs/**` file.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 with no gate filter and no `--skip-slow`.
- [ ] `cellLE_zero_const_of_kappa_eq` is either a landed theorem (PASS) or claimed by nothing at all (FAIL) — never a weakened statement under that name.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` — the new certificate-free pin layer.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the `(K2)` exponential bound and the free slack baseline.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — the new cell-level module: the common-shift inclusion, the collision case split, and the closing assembly.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/idle-gap-lengthening.lean` — the second decision gate's schema and verdict object.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean` — the pin-free side of both refuting objects and the chain's pin-count bound.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean` — the decision gate's schema and verdict object.
- `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md` — the summary, carrying the branch verdict for task 761's reviser.
- Axiom-test pins and the brought-current records (`RaySummary/README.md`, the `(W)` narrative, the three generated inventory blocks).

## Rollback/Contingency

- Every phase is its own commit, and Phases 1-3 land material that is useful on either branch of
  Phase 4, so a FAIL verdict never requires reverting them.
- Phase 4 touches no library file by construction: its verdict is reached in a `specs/**`
  prototype, so an INCONCLUSIVE outcome leaves the build green and the task resumable from Phase
  5's FAIL branch with nothing to undo.
- If Phase 5's PASS branch cannot be completed after Phase 4 returned PASS, close Phase 5
  `[BLOCKED]` with the goal state reached, leave the reserved name unclaimed, and let Phase 6 run
  its records and gate set over what landed. Do NOT reach for a weakened statement under the
  reserved name to make a phase close.
- If a phase needs a defensive checkpoint before risky work, use
  `bash .claude/scripts/git-snapshot.sh 838 --no-revert`. The default reverting form belongs only
  to a genuine rollback.
- Phase 8 touches no library file by construction: its verdict is reached in a `specs/**`
  prototype, so an INCONCLUSIVE outcome leaves the build green and the task resumable from Phase
  9's FAIL branch with nothing to undo. The same holds for Phase 4, which already closed.
- Phases 5 and 7 land material that is useful on either branch of Phase 8, so a FAIL verdict
  never requires reverting them. Phase 7 is a new leaf module plus two import lines, so reverting
  it is the deletion of one file and two lines.
- If Phase 9's PASS branch cannot be completed after Phase 8 returned PASS, close Phase 9
  `[BLOCKED]` with the goal state reached, leave the reserved name unclaimed, and let Phase 10
  run its records and gate set over what landed. Do NOT reach for a weakened statement under the
  reserved name — or under Phase 9's planned new name — to make a phase close.
- Nothing in this plan edits task 761's or task 836's artifacts, so no cross-task rollback is
  possible or needed. The serializing dependency edge against the insertion-cascade task is what
  keeps Phase 8's insertion out of that task's commits.
