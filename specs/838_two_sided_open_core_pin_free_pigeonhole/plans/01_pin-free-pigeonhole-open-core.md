# Implementation Plan: Task #838

- **Task**: 838 - Two-sided open core: attack the depth-`0` cell obligation through a `(K2)`-level pigeonhole over region starts on the pin-free side, or restate the obligation under a new name
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours (Phases 1-6 at 2 / 2 / 1.5 / 2 / 2 / 1.5). Phase 4 is a decision gate and Phase 5 is branch-selected by it: on the PASS branch Phase 5 lands the obligation under the reserved name, on the FAIL branch it states a regime-restricted obligation under a NEW name and closes in roughly one hour, so the honest range is 10-11 hours
- **Dependencies**: None at the `state.json` level. Parent: task 836, whose Phase 10 closed `[BLOCKED]` on exactly this core and whose landed pump layer is this plan's entire input. Task 761 is the downstream CONSUMER (its Phase 11.6 inducts from the depth-`0` base case); nothing here edits any artifact of 761 or 836
- **Research Inputs**: None. No research report was dispatched for this round; the inputs are the landed library, the two compiled prototypes of task 836, and the task description. See "Research Integration" for the Stage 1.5 assessment that settled this
- **Artifacts**: plans/01_pin-free-pigeonhole-open-core.md (this file)
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
- **Risk encountered and inherited**: 836's attempt to split `LadderPump.lean` at 1,000 lines was
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

## Decisions

- **Route (a) first, route (b) only on a gate FAIL.** Route (b) weakens what the consumer can
  induct from, so it is not attempted while route (a) is unsettled. Phase 4 is the one gate that
  decides between them, and it sits as early as the three provable pieces allow so the
  orchestrator learns the branch before the closing phases are entered.
- **The new material goes into `LadderPin.lean`, not into `LadderPump.lean`.**
  `LadderPump.lean` is 1,485 lines against the package-wide `longFile` limit of 1500
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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A spanning block's length is not constrained by `(K1)` (`prodCycleLens` membership needs `l ≤ cntAt g u`, which a block crossing an idle position violates), so the shift cannot be made exactly `m · (P + 1)` | H | H | This is precisely Phase 4's gate question, asked early and answered by a compiled object either way. On FAIL, Phase 5's branch states the regime-restricted obligation and the record names the `(K1)` amendment as a follow-up task rather than attempting it |
| The pin-density hypothesis is not derivable from `ParamsOk` for a general path (a path may have one long region and no pins at all — `gC` is such an object) | H | H | The dichotomy of Phase 1 is the answer by construction: the sparse-pin side IS the pin-free side, where the landed regime-A assembly already applies. Phase 4's gate statement is written over the dichotomy, not over a density assumption |
| The pigeonhole over region starts needs the pins' realized types, which depend on the history `σ`, and the two sides of the obligation quantify over ALL histories | M | M | The landed pigeonhole `exists_typeBlock_of_budget_le_cnt_within` already takes a single `σ` and is applied per-history by its consumers; Phase 2's Goal follows that shape exactly (one `σ`, no offset hypothesis read) |
| `LadderPin.lean` accidentally reaches a certificate object through a transitive `LadderPump` re-export | M | L | Phase 1 runs the same explicit grep `LadderPump.lean`'s contract names and the phase does not close until it returns nothing |
| Phase 5's FAIL branch produces a restated obligation the consumer (761's Phase 11.6) cannot induct from | M | M | Phase 5's FAIL branch does not merely state the restriction: it records, in the module docstring and the summary, exactly which hypothesis the consumer must now supply, and raises `user_decision` (already filed by this plan, non-blocking) on whether to accept that or leave the obligation open |
| A new module plus axiom-test pins ripples into the generated README inventories, as it did in 836 | L | H | Phase 1's task list includes `check-module-invariants.sh --emit-inventory` and the hand-written description cell, and the three generated inventory blocks are named in `Files to modify` |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phase 6 is the final phase: it is a terminal
node of this graph and depends, transitively through Phase 5 and Phase 4, on every other phase.

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
- `LadderPump.lean` is unchanged and still under the package `longFile` limit of 1500 (`wc -l` is 1,485 ± 0).

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

### Phase 5: Close the Obligation — GATED ON PHASE 4 [NOT STARTED]

**Goal**: On Phase 4's PASS verdict, `cellLE_zero_const_of_kappa_eq` is landed in
`LadderChain.lean` as a theorem on the standard axiom profile and the reserved name is claimed.
On FAIL or INCONCLUSIVE, a regime-restricted obligation is stated and compiled under a NEW name,
the record names exactly what the consumer must supply, and the reserved name stays reserved and
claimed by nothing.

**Tasks** (PASS branch):

- [ ] Assemble the two-sided inclusion in `LadderChain.lean`'s `section Assembly`: the upward
  direction is the landed `cellAt_subset_of_shift_of_pend_past`; the downward direction deletes
  `m · ((P + 1) / l)` copies of the Phase 2 spanning block through the landed
  `exists_deleted_ladderPath_of_pend_past` and `tpOf_eq_delIdx_of_tpOf_eq`, with Phase 4's
  divisibility supplying `l ∣ P + 1` and Phase 1's dichotomy supplying the branch split.
- [ ] `cellLE_zero_const_of_kappa_eq : CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B`
  from the two inclusions, with `kappa_eq_components`, `eq_or_both_ge_of_min_eq` and
  `clipIdx_regime_of_eq` splitting the collision hypothesis into the sub-regimes and
  `kappa_eq_of_shift` discharging the common-shift one.
- [ ] `LadderAgree.lean`: the obligation section's docstrings and `CellLEZeroConstOfKappaEq`'s own
  docstring now say the schema is a THEOREM under `ParamsOk`, name `LadderChain.lean` as its home,
  and keep the pre-repair refutation's record intact (it refutes a different, frozen predicate).
  Current-design language only; no "previously", no task number.
- [ ] Axiom-test pin for `cellLE_zero_const_of_kappa_eq`, and the `(W)` prose block amended to say
  the obligation is proved rather than open.

**Tasks** (FAIL / INCONCLUSIVE branch):

- [ ] State the regime-restricted obligation in `LadderChain.lean` under a NEW name —
  `CellLEZeroConstOfKappaEqPinFree` for the schema and
  `cellLE_zero_const_of_kappa_eq_of_pinFree` for the theorem — carrying, in addition to
  `ParamsOk` and the stab-free hypothesis, the explicit pin-free hypothesis Phase 1's dichotomy
  supplies on the side that is settled (uniformly pending into the past at the lower state, which
  is the hypothesis `cellAt_subset_of_shift_of_pend_past` already consumes), and prove it from
  the landed upward inclusion plus the deletion mirror in that regime.
- [ ] `cellLE_zero_const_of_kappa_eq` stays reserved. Verify by
  `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returning only docstring lines,
  and state in the new schema's docstring that it is NOT the reserved statement, which hypothesis
  it adds, and that the unrestricted schema is neither proved nor refuted under `ParamsOk`.
- [ ] Record, in the new schema's docstring and in Phase 6's summary, exactly what the consumer
  (task 761's Phase 11.6 induction) must now supply to use the restricted form, and name the
  `(K1)`-amendment follow-up as a candidate task without creating it.
- [ ] Axiom-test pin for the new theorem; the `(W)` prose block says the obligation is open and
  the restricted form is proved.
- [ ] Prohibited on both branches: no `sorry`, no `def X := True`, no vacuous placeholder, and no
  narrowed or regime-restricted statement under the reserved name.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: On either branch the assembly is 120-250 lines added to
`LadderChain.lean` (bringing it to roughly 740-870 lines, comfortably under the package `longFile`
limit of 1500 — `LadderChain.lean` is 612 lines, re-derived by `wc -l` at authoring), and three or
four files change: `LadderChain.lean`, the axiom test, and on the PASS branch `LadderAgree.lean`'s
obligation docstrings. Confirm by `wc -l` and `git diff --stat`. If `LadderChain.lean` would pass
1500, split the assembly into `LadderCell.lean` and declare that file in the commit pathspec —
the split file is named here, not left as an unharvested contingency.

**Tier Justification**: The phase adds a theorem to `LadderChain.lean` and, on the PASS branch,
edits `LadderAgree.lean` docstrings that every `RaySummary` module transitively imports, so the
covering check is the guarded scoped builds of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, of `FormalSystem` (the root), and
of `BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus `bash scripts/check-module-invariants.sh`
— that enumerated one-hop dependent set is what a docstring edit to an imported module and a new
exported theorem can reach, and nothing in it is a shared tactic or a core type.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the closing assembly and the obligation (reserved name on PASS, new name on FAIL)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - created ONLY if `LadderChain.lean` would pass the 1500-line package limit; if created, it also takes the two root import lines
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - obligation-section docstrings only, PASS branch only
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin plus the `(W)` prose block

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on the landed theorem (`cellLE_zero_const_of_kappa_eq` on PASS, `cellLE_zero_const_of_kappa_eq_of_pinFree` on FAIL) shows `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` is 0.
- On the FAIL branch only: `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` shows the reserved name on docstring lines only, with no `theorem` or `def` claiming it.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed file.

---

### Phase 6: Records, the Full Gate Set, and the Summary [NOT STARTED]

**Goal**: Every record that states the depth-`0` obligation's status says what this task
established; the complete gate set runs green; the summary hands task 761's reviser the branch
verdict and, on the FAIL branch, the exact hypothesis its induction must now supply.

**Tasks**:

- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: the narrative sections that
  state the obligation's status are brought current with Phase 4's verdict and Phase 5's branch;
  the pin layer gets its paragraph beside the pump layer's. Durable anchors only — module names,
  declaration names, section headings — no task numbers.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: the `(W)` requirement narrative
  states what the pins now certify, including that the `(K2)` bound is exponential and what the
  pin layer's two halves are.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 and reports all wired probes compiling. The
  two prototypes of this task are NOT wired — they stay prototypes under
  `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/`. If Phase 4's verdict was FAIL
  and its refuting object is the kind of record a wired probe should hold in place, record that as
  a candidate follow-up in the summary rather than wiring it here.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0; all three
  generated inventory blocks are current.
- [ ] Write `specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md`
  per `summary-format.md`: the branch taken, the verdict with its mechanism, every declaration
  landed with its axiom profile, what remains open, and the named follow-up candidates (a `(K1)`
  amendment on the FAIL branch; a tighter pigeonhole constant if Phase 2 found one; wiring Phase
  4's refuting object as a probe if applicable).
- [ ] Run the complete gate set and read its verdict, not a piped exit code.

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

## Lean Challenge Statements

The four `theorem` declarations below are this plan's Goals and carry `sorry` bodies, listed in
the order the phases prove them (Phase 1's two, Phase 2's one, Phase 3's one). Every landed
object (`LadderState`, `IsLadderPath`, `objAt`, `cntAt`, `nxtAt`, `tpOf`, `ladderModel`,
`ladderFrameAdm`, `RladAdm`, `plusSubformulaClosure`, `ParamsOk`, `ProdState`) is imported from
the library rather than pinned, because it is landed. Identifiers are ASCII for the snapshot
tool's regex.

Phase 4's gate schema and Phase 5's closing theorem are deliberately NOT pinned here: a pinned
signature asserts that the statement is the intended one, and whether the unrestricted obligation
is provable is exactly what Phase 4 decides. Pinning either would pin a statement this plan cannot
vouch for.

This block was elaborated standalone at this plan's authoring time through the build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 500 -- env lean <file>`):
`exit_status=0`, zero errors, exactly four `declaration uses 'sorry'` warnings — one per theorem.

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

## Testing & Validation

- [ ] Each of the four Goals is a `theorem` whose signature matches the Challenge block token for token, with `#print axioms` showing no `sorryAx`.
- [ ] `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on `LadderPin.lean`, `LadderChain.lean`, and every other `FormalSystem/` file this task changes.
- [ ] `LadderPin.lean` passes the certificate-freedom grep `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod` with no match.
- [ ] Both prototypes compile standalone through the build guard with zero errors and zero `sorry` warnings.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 (no probe count changes — the two new files are prototypes, not wired probes).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on every changed non-`specs/**` file.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 with no gate filter and no `--skip-slow`.
- [ ] `cellLE_zero_const_of_kappa_eq` is either a landed theorem (PASS) or claimed by nothing at all (FAIL) — never a weakened statement under that name.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPin.lean` — the new certificate-free pin layer.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the `(K2)` exponential bound and the closing assembly.
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
- Nothing in this plan edits task 761's or task 836's artifacts, so no cross-task rollback is
  possible or needed.
