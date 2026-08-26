# Implementation Plan: Task #483

- **Task**: 483 - route1_restricted_applyrule_emitted_time_mem
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None (task 481 is the parent; it is blocked, not a prerequisite)
- **Research Inputs**: `specs/481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md`
- **Artifacts**: plans/01_route1-restricted-time-sweep.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Attempt Route 1 and only Route 1: a re-derivation of `applyRule_emitted_time_mem` that replaces its
`haux : OrdTimesKnown b ord` hypothesis with a *branch-level syntactic* hypothesis
`∀ x ∈ b, untlSnceFree x.formula = true`, then propagate that haux-free form down the existing
chain (`pickBranches_knownTimes_subset` -> `unorderedSuccessor_knownTimes_subset` -> section D4's
propositional composite) until either `universeClosedAt_signedUniverse_of_propositional` becomes
stateable and provable, or a specific rule is identified that genuinely still needs `OrdTimesKnown`
on the fragment. Either outcome closes the task; the negative outcome is recorded as a C9 register
amendment rather than as a failure.

The load-bearing structural claim — verified against the source during planning, but still to be
*proved* rather than assumed at implementation time — is that every use of `haux` inside
`applyRule_emitted_time_mem`'s proof lives in exactly five rule arms, and all five are shape-gated
by `untlSnceFree`:

| Arm | Where `haux` is used | Why `untlSnceFree` excludes it |
|-----|----------------------|-------------------------------|
| `.allFuturePos` | `mem_filterMap_futureOf_time haux` | `applyRule`'s arm pattern is `.pos, .allFuture ψ`, and `Formula.allFuture ψ = ((⊥→⊥) untl (ψ→⊥)) → ⊥`, an `imp` whose antecedent is an `untl` node |
| `.allPastPos` | `mem_filterMap_pastOf_time haux` | same, via `Formula.allPast` and `snce` |
| `.someFutureNeg` | `mem_filterMap_futureOf_time haux` | the arm is `.neg, φ` guarded by `match asSomeFuture? φ`, and `asSomeFuture_eq_none_of_untlSnceFree` (already landed, section D3) returns `none` |
| `.somePastNeg` | `mem_filterMap_pastOf_time haux` | same, via `asSomePast_eq_none_of_untlSnceFree` |
| `.orderTrichotomy` | `applyRule_orderTrichotomy_emitted_time`'s `mem_knownTimes_of_mem_pastOf haux` | the `fires` guard requires `branch.contains (SignedFormula.neg d l0)` for some `d ∈ disjuncts φ ψ`, and every `d` is `Formula.someFuture (...) = untl ⊤ (...)`; an `untlSnceFree` branch carries no `untl`-headed formula, so `candidates.find? fires = none` and the result is `.notApplicable` |

Two corrections to the starting evidence, both of which make Route 1 *cheaper* than the task
description projects and both of which must be confirmed at implementation time rather than taken
on this plan's word:

1. **`boxFree` is not needed for the time coordinate.** `boxFree` is what closes the *world*
   coordinate in section D4. Every `haux` site above is excluded by `untlSnceFree` alone. The
   restricted theorem therefore belongs in section D3's territory, exactly as D4's boundary block
   predicted, and carries one syntactic hypothesis rather than two.
2. **The needed hypothesis is branch-level, not trigger-level.** Four of the five arms are gated by
   the *trigger's* shape, but `.orderTrichotomy` is gated by what the *branch* carries. A
   trigger-only hypothesis will not close it. The branch-level form is the right one anyway,
   because it is exactly what `UniverseClosedAt`'s clause 1 already hands over:
   `(∀ x ∈ b, x ∈ signedUniverse C L)` plus `hfree : ∀ φ ∈ C, untlSnceFree φ = true` yields it in one
   line, and section D4's proof already performs that step. That asymmetry — clause 1 *can* supply
   branch-level freeness but *cannot* supply `OrdTimesKnown` — is the whole reason Route 1 can work
   where the existing chain cannot.

### Research Integration

`reports/02_spawn-analysis.md` supplies the scoping decision (one task, Route 1 only, negative
result acceptable) and the three starting observations. It does not supply a rule-by-rule audit;
this plan's Phase 1 is that audit, and Phases 2-3 are the proof work that converts it from a
plausibility argument into a compiled fact.

### Prior Plan Reference

Task 481's plan (`plans/01_sharpen-replace-labelclosed-residual.md`) is read as reference, not as a
template. What is taken from it:

- **Effort calibration**: its Phase 4 ("mirror D3's time machinery in the world coordinate") was
  estimated at ~1.5h and landed first try. Phases 3-4 of this plan are the same *kind* of work
  (transport a landed proof shape one hypothesis to the side), so 1h-1.25h each is the right band;
  Phase 2 (five new arm-exclusion facts against `applyRule`'s raw match) is the one genuinely
  unpredictable phase and is budgeted highest.
- **Additive discipline**: task 481 kept all nine `signedUniverse` carriers and both `_of_headroom`
  originals byte-identical and added new declarations beside them. The same discipline applies here
  and is a completion condition, not a preference.
- **Risk awareness**: task 481's Phase 5 recorded a *reasoned exclusion* rather than forcing a
  statement through with an added hypothesis. This plan inherits that rule verbatim: no `sorry`, no
  vacuous placeholder, and no new hypothesis invented to make a statement typecheck.
- **What is deliberately not copied**: task 481's Phases 6 and 7 (terminus restatement and
  non-vacuity). They stay in task 481. This task assesses their reachability and stops.

### Roadmap Alignment

No `specs/ROADMAP.md` was provided in the delegation context and no roadmap flag was set. No
roadmap alignment recorded.

## Goals & Non-Goals

**Goals**:

- Decide Route 1 one way or the other, with the decision compiled rather than argued.
- If Route 1 succeeds: land `applyRule_emitted_time_mem_of_untlSnceFree` and propagate it far
  enough that `universeClosedAt_signedUniverse_of_propositional` — the exact item task 481's Phase 5
  recorded as *not stateable* — is stated and proved.
- If Route 1 fails: record the failure as a C9 register amendment naming the precise rule, the
  precise configuration, and why `untlSnceFree` does not exclude it.
- Either way: state explicitly whether task 481's Phases 6 and 7 are now reachable, and whether
  landing them belongs to a resumption of task 481 or to a further follow-up task.
- Either way: `lake build` green, `lake build BimodalTest` green, `check-module-invariants.sh` with
  no check failing that passed at the pre-task baseline.

**Non-Goals**:

- Route 2 (an `Ord`-flavoured `UniverseClosedAt` and `DifficultyBounded` cascading to
  `buildTableauAt`). Explicitly out of scope even if Route 1 fails. Not a single restatement of it
  may be started under this task.
- Landing task 481's Phase 6 terminus
  (`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_*` with `hlab` deleted) or Phase 7's
  non-vacuity stock. This task assesses reachability; it does not land them.
- Modifying `applyRule_emitted_time_mem` itself, or weakening
  `applyRule_emitted_time_mem_ordTimesKnown_needed`. The unconditional statement stays refuted; the
  restricted statement is a *different, incomparable* statement and must be a separate declaration.
- Removing `hmint : ruleMintsFreshTime rule = false` from the restricted theorem. It may well be
  droppable on this fragment (an `untlSnceFree` trigger fails every minting rule's shape view), but
  that is a bonus, not a deliverable, and chasing it will cost Phase 3 time it does not have.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `applyRule`'s `.allFuturePos` / `.allPastPos` arms pattern-match on the `Formula.allFuture` *def*, so the existing `asAllFuture_eq_none_of_untlSnceFree` view lemma does not apply directly to the raw match | M | M | Phase 2 states the exclusion facts against the raw constructors (`.imp (.untl _ _) .bot`), mirroring how `asAllFuture_eq_none_of_untlSnceFree` itself has to `cases a` through the implication. Do not try to route through the `as…?` views for these two arms. |
| The existing sweep in `applyRule_emitted_time_mem` is one large `first`-chain; a restricted copy may not reuse its script cleanly | H | M | Phase 3 copies the existing script verbatim and *adds* alternatives ahead of the `mem_filterMap_futureOf_time` / `_pastOf` closers, rather than writing a fresh arm-by-arm proof. If the copy does not go through inside the phase budget, that is a proof-engineering result, not a Route 1 refutation — record it as such and do not convert it into a negative verdict. |
| The `.orderTrichotomy` exclusion needs the branch hypothesis threaded into a `find?`-to-membership step | M | M | Phase 2's fifth item proves `candidates.find? fires = none` from the branch hypothesis directly, before Phase 3 touches the sweep. If it will not close, the `fires` guard is the named negative-result site — capture it exactly. |
| A `haux` use exists that the Phase 1 audit misses (e.g. inside a helper the sweep calls) | H | L | Phase 1's deliverable is a *mechanical* census (`grep`-level, then read), not a reading impression, and Phase 3's compile is the actual check: a missed site surfaces as an unsolved goal naming the helper. |
| Downstream signature change breaks D3's landed discharge | M | L | `unorderedSuccessor_knownTimes_subset`'s *signature* is left unchanged; only its proof is re-routed through the new haux-free form (which is strictly stronger with the same `hfree`). Its consumer `mintPaysForTime_of_untlSnceFree` is untouched. |
| Scope creep into Route 2 once clause 1 is discharged | H | M | Phase 5 stops at `universeClosedAt_signedUniverse_of_propositional`. The terminus restatement is a named non-goal and Phase 6's verdict is prose plus a register amendment, not code. |
| Register drift (a 25th entry) | L | M | Phase 6 amends entry 16 (and secondarily 21 / the D4 boundary block). The register must still open "Twenty-four statements" and hold exactly 24 numbered entries at task close; this is a verification item, not a preference. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is a strict chain: each phase's
input is the previous phase's compiled output, and every phase carries an escape to Phase 6.

**The escape rule, which applies to every phase below.** If a phase cannot be completed, do **not**
force it, do **not** add a hypothesis to make it typecheck, and do **not** proceed to the next
phase. Jump directly to Phase 6 carrying: the rule name, the exact configuration or goal state that
resisted, and the reason `untlSnceFree` does not exclude it. That is the negative result, and it is
a complete deliverable.

---

### Phase 1: The `haux` census inside the time sweep [COMPLETED]

**Goal**: A mechanical, per-arm enumeration of every place `OrdTimesKnown` is consumed in the proof
of `applyRule_emitted_time_mem` and of its helper `applyRule_orderTrichotomy_emitted_time`, each
paired with the `untlSnceFree`-derived fact that would exclude that arm — or marked as *not
excluded*, which is the negative result.

**Tasks**:
- [x] Re-locate by declaration name (not line number — the file is ~14,770 lines and every line
      number in task 481's artifacts predates task 462's section D5 insertion):
      `applyRule_emitted_time_mem`, `applyRule_orderTrichotomy_emitted_time`,
      `applyRule_emitted_time_mem_ordTimesKnown_needed`, `mem_filterMap_futureOf_time`,
      `mem_filterMap_pastOf_time`, `mem_knownTimes_of_mem_pastOf`, and section D3's six
      `as…_eq_none_of_untlSnceFree` view lemmas.
- [x] Enumerate every syntactic occurrence of `haux` in the two proofs. There should be exactly
      three closer families: `mem_filterMap_futureOf_time haux`, `mem_filterMap_pastOf_time haux`,
      and `mem_knownTimes_of_mem_pastOf haux`. Record the actual count; a fourth family is a
      finding.
- [x] For each of the four propagation rules (`.allFuturePos`, `.allPastPos`, `.someFutureNeg`,
      `.somePastNeg`), read `applyRule`'s own arm in `FormalSystem/Metalogic/Decidability/Tableau.lean`
      and record whether the arm is gated by a raw constructor pattern or by an `as…?` view. This
      determines which exclusion lemma shape Phase 2 must produce.
- [x] Read `applyRule`'s `.orderTrichotomy` arm and record the `fires` guard's final conjunct
      (`ds.any fun d => branch.contains (SignedFormula.neg d l0)`) and the shape of `disjuncts`.
      Confirm every member of `disjuncts φ ψ` is `Formula.someFuture`-headed.
- [x] Confirm no *other* rule arm reachable under `ruleMintsFreshTime rule = false` reads a time off
      the ordering. In particular check `serialityRule`, `timeLinearity`, `boxTemporal`,
      `denseIndicatorClosure`, `priorUZ`/`priorSZ`/`z1Rule`, `priorUGap`/`priorSGap`/`sepRule`, and
      the `boxPos`/`diamondNeg`/`boxNeg`/`diamondPos` world family. The sweep's own docstring claims
      they all emit at the trigger's time or at a constant time; verify against the arms rather than
      trusting the docstring.
- [x] Write the census into the task's `reports/` directory as a short table (arm, `haux` closer,
      excluding fact, status). This is the input Phase 2 works from and the evidence Phase 6 cites
      in the negative case.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts that `haux` is consumed at exactly five rule arms and by
exactly three closer families. Confirm at implementation time by counting occurrences in the source
rather than by reading this plan's overview table; if a sixth arm or a fourth closer family appears,
that arm is a Route 1 candidate obstruction and must be carried into Phase 2 as an explicit item
rather than silently absorbed.

**Files to modify**:
- `specs/483_route1_restricted_applyrule_emitted_time_mem/reports/01_haux-census.md` — new; the
  per-arm census table.

**Verification**:
- The census names every `haux` occurrence in both proofs, with no "and similar" or "etc."
- Every arm in the census is marked either *excluded by `untlSnceFree`, via <named fact>* or *not
  excluded* — no third status.
- No source file under `FormalSystem/` is modified in this phase.

---

### Phase 2: The five arm-exclusion facts, in a probe [COMPLETED]

**Goal**: Five compiled facts, each saying that the named rule emits nothing when the branch is
`untlSnceFree` — proved standalone in a probe file before any production source is touched, exactly
as task 481 proved its Phase 5 composite standalone first.

**Tasks**:
- [x] Create `specs/483_route1_restricted_applyrule_emitted_time_mem/probes/Probe1.lean`, importing
      the `MintBound` module so section D3's view lemmas are in scope.
- [x] State and prove the two trigger-shape exclusions for the propagation rules whose arms match a
      raw constructor pattern (per Phase 1's finding — expected to be `.allFuturePos` and
      `.allPastPos`):
      `untlSnceFree φ = true → (applyRule .allFuturePos ⟨sign, φ, l⟩ b ord).1.emitted = []`
      and its `.allPastPos` mirror. Route through the raw constructor shape
      (`Formula.allFuture ψ` is `.imp (.untl (.imp .bot .bot) (.imp ψ .bot)) .bot`), mirroring how
      `asAllFuture_eq_none_of_untlSnceFree` has to `cases a` through the implication.
- [x] State and prove the two view-gated exclusions (`.someFutureNeg`, `.somePastNeg`) directly from
      `asSomeFuture_eq_none_of_untlSnceFree` / `asSomePast_eq_none_of_untlSnceFree`. These should be
      two-line proofs: the view returns `none`, the arm returns `.notApplicable`, `.emitted` is `[]`.
- [x] State and prove the `.orderTrichotomy` exclusion from the branch hypothesis:
      `(∀ x ∈ b, untlSnceFree x.formula = true) → (applyRule .orderTrichotomy sf b ord).1.emitted = []`.
      The argument: every `d ∈ disjuncts φ ψ` is `untl`-headed, so `branch.contains
      (SignedFormula.neg d l0) = false` for every candidate, so `fires` is false everywhere, so
      `candidates.find? fires = none`, so the arm is `.notApplicable`. Prove the
      "`untl`-headed formulas are not on an `untlSnceFree` branch" step as its own named lemma —
      it is reused by nothing else, but it is the step most likely to need shape massaging and it
      should fail in isolation if it fails.
- [x] Do **not** attempt the full restricted sweep in this phase. Five separate facts, each
      compiling, is the deliverable.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that all five exclusions conclude `emitted = []` (rather
than the weaker "every emission is at a known time"). Confirm at implementation time by proving the
`.someFutureNeg` case first, since it is the cheapest: if `applyRule`'s arm returns something other
than `.notApplicable` on a `none` view, every one of the five statements is the wrong shape and the
whole phase must be restated against `∀ g ∈ …, g.label.time ∈ b.knownTimes` before proceeding.

**Files to modify**:
- `specs/483_route1_restricted_applyrule_emitted_time_mem/probes/Probe1.lean` — new; probe only,
  never imported by production code.

**Verification**:
- `lake env lean` on the probe exits 0 with no `sorry` and no error.
- Each of the five facts is a separate named declaration, not a conjunction.
- Nothing under `FormalSystem/` is modified in this phase.

---

### Phase 3: The restricted sweep, `applyRule_emitted_time_mem_of_untlSnceFree` [IN PROGRESS]

**Goal**: The Route 1 deliverable itself — `applyRule_emitted_time_mem` with `haux : OrdTimesKnown b
ord` replaced by `hbfree : ∀ x ∈ b, untlSnceFree x.formula = true` — proved in the probe, then landed
in section D3 beside the original.

**Tasks**:
- [ ] In the probe, state:
      ```
      theorem applyRule_emitted_time_mem_of_untlSnceFree {rule : TableauRule}
          {sf : SignedFormula} {b : Branch} {ord : TimeOrdering}
          (hsf : sf ∈ b) (hbfree : ∀ x ∈ b, untlSnceFree x.formula = true)
          (hmint : ruleMintsFreshTime rule = false) :
          ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes
      ```
      Note it takes `hbfree`, not a trigger-level hypothesis: the trigger-level fact is recovered as
      `hbfree sf hsf` where needed, and `.orderTrichotomy` needs the branch-level form.
- [ ] Prove it by copying the existing sweep's script verbatim and inserting Phase 2's five facts as
      `first` alternatives *ahead of* the `mem_filterMap_futureOf_time` / `mem_filterMap_pastOf_time`
      closers and in place of the `applyRule_orderTrichotomy_emitted_time` alternative. Do not
      rewrite the sweep from scratch; the existing script's ordering is load-bearing (its docstring
      records that a term-level `by` inside a `first` alternative can silently absorb a failing goal
      into `sorryAx`, which is why every closer is a backtrackable `refine … ?_`). Preserve that
      property.
- [ ] Keep the existing `set_option maxHeartbeats 4000000 in` (or raise it only if the restricted
      version genuinely needs more; record the value actually used).
- [ ] Land the theorem in `MintBound.lean` **section D3**, immediately after
      `applyRule_emitted_time_mem_ordTimesKnown_needed` and its witness block, so a reader hitting
      the refutation immediately meets the restricted form that survives it. Do **not** move, edit,
      or reprove `applyRule_emitted_time_mem` or the refutation.
- [ ] Docstring it to state three things and no more: (a) it is *incomparable* to the original, not
      stronger — it trades a semantic run invariant for a syntactic branch condition; (b) it does
      **not** contradict `applyRule_emitted_time_mem_ordTimesKnown_needed`, whose refuted statement
      is the *unconditional* one; (c) the five arms that consume `OrdTimesKnown` are precisely the
      five the syntactic hypothesis shape-gates, named individually.
- [ ] Add the `Finset`-coordinate sibling (`…_timeFinset_mem_of_untlSnceFree`) only if Phase 4 turns
      out to need it. Do not add it speculatively.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the restricted theorem needs exactly the three hypotheses
`hsf`, `hbfree`, `hmint`. Confirm at implementation time by reading the elaborated signature back
from the built module (`#check`) rather than trusting the statement as typed; any fourth hypothesis
that had to be added to make the proof go through is itself a partial negative result and must be
carried into Phase 6 rather than quietly accepted — an added hypothesis is exactly the failure mode
task 481 exists to avoid.

**Files to modify**:
- `specs/483_route1_restricted_applyrule_emitted_time_mem/probes/Probe1.lean` — the standalone proof.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D3, after the
  `OrdTimesKnown`-necessity witness block.

**Verification**:
- `lake build` exits 0.
- `#print axioms applyRule_emitted_time_mem_of_untlSnceFree` shows only
  `[propext, Classical.choice, Quot.sound]`.
- `git diff` shows `applyRule_emitted_time_mem` and
  `applyRule_emitted_time_mem_ordTimesKnown_needed` unmodified.
- Zero `sorry` in the new declaration; `lake build` emits no `declaration uses sorry` warning.

---

### Phase 4: Propagate through the pick and the engine step [IN PROGRESS]

**Goal**: The haux-free form carried from `applyRule` up to
`unorderedSuccessorBranches (expandOnceUnblocked …)`, so that section D4's composite can consume it.

**Tasks**:
- [ ] Add a haux-free `pickBranches_knownTimes_subset` variant. The original is `private` and takes
      `(haux, hp)`; the variant takes `(hbfree, hp)` with the same `hp` source obligation. Route it
      through Phase 3's theorem at the one site where the original calls
      `applyRule_emitted_time_mem`. Note the source obligation `hp` already carries
      `ruleMintsFreshTime r = false`, so `hmint` costs nothing here.
- [ ] Re-route `unorderedSuccessor_knownTimes_subset` so that `haux` is no longer used. Its `hfree :
      ∀ x ∈ b, untlSnceFree x.formula = true` is already exactly the hypothesis Phase 3 needs, so the
      haux-free form is *strictly stronger* with no new currency.
      - **Preferred shape**: state the strengthened form as a new declaration
        `unorderedSuccessor_knownTimes_subset_of_untlSnceFree` (hypotheses: `hfree` only), and
        re-derive the existing `unorderedSuccessor_knownTimes_subset` from it in one line with its
        **signature byte-identical** so that D3's `mintPaysForTime_of_untlSnceFree` and every other
        consumer is untouched. Changing the original's proof body is allowed; changing its signature
        is not.
      - Do not delete the original even though it becomes redundant: it is cited by name in section
        D3's prose and in the D4 boundary block.
- [ ] Confirm by `git diff` that `mintPaysForTime_of_untlSnceFree`,
      `mintPaysForTimeFixed_of_untlSnceFree`, and `mintPaysForTimeFixed_signedUniverse_untlSnceFree`
      are unmodified.
- [ ] Update section D3's prose only where it now says something false. The section note claiming
      the time coordinate carries `OrdTimesKnown` unavoidably is the one to check; leave every other
      sentence alone. Prose edits are additive footnotes where possible, not rewrites.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that exactly two declarations sit between
`applyRule_emitted_time_mem` and section D4's composite
(`pickBranches_knownTimes_subset` and `unorderedSuccessor_knownTimes_subset`). Confirm at
implementation time by grepping every consumer of `applyRule_emitted_time_mem` and of
`unorderedSuccessor_knownTimes_subset` across `FormalSystem/` before editing; a third intermediary,
or a consumer outside `MintBound.lean`, changes the propagation surface and must be recorded.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D3.

**Verification**:
- `lake build` exits 0.
- `unorderedSuccessor_knownTimes_subset`'s elaborated signature is unchanged (read back with
  `#check`, compared against the pre-phase signature).
- `#print axioms` on both new/re-routed declarations shows only the three standard axioms.
- `git diff --stat` touches only `MintBound.lean`.

---

### Phase 5: Clause 1 without `OrdTimesKnown`, and the excluded theorem landed [IN PROGRESS]

**Goal**: The item task 481's Phase 5 recorded as *not stateable* — stated and proved. This is what
converts "Route 1 succeeded" from a claim into a compiled fact.

**Tasks**:
- [ ] Add `unorderedSuccessor_label_mem_of_propositional_ordFree` (or re-route the existing
      `unorderedSuccessor_label_mem_of_propositional` if its signature can lose `haux` without
      breaking a consumer — check consumers first; it currently has exactly one). Its hypotheses:
      `hL : TimeMergeClosed L`, `hbox`, `hfree`, `hbl` — and **no** `OrdTimesKnown`.
- [ ] Add the `signedUniverse` form without the `OrdTimesKnown` binder in the quantifier prefix. The
      original `unorderedSuccessor_confined_signedUniverse_of_propositional` has
      `OrdTimesKnown b ord →` inside its `∀ b ord tr` prefix; the new form drops exactly that arrow
      and nothing else.
- [ ] Land `universeClosedAt_signedUniverse_of_propositional`, mirroring
      `universeClosedAt_signedUniverse_of_headroom`'s two-component anonymous constructor: clause 1
      from the new composite, clause 2 from `timeMergeClosed_identifyTime_signedUniverse hL` exactly
      as the `_of_headroom` original does. Its hypotheses should be `hC : TableauClosed C`,
      `hT : TrichStock C`, `hL : TimeMergeClosed L`, `hbox : ∀ φ ∈ C, boxFree φ = true`,
      `hfree : ∀ φ ∈ C, untlSnceFree φ = true` — and **no** `UnorderedSuccessorLabelClosed` and **no**
      frame-class restriction.
- [ ] Leave `unorderedSuccessor_confined_signedUniverse_of_headroom` and
      `universeClosedAt_signedUniverse_of_headroom` byte-identical. Leave all nine `signedUniverse`
      carriers byte-identical. Confirm programmatically against the pre-task baseline commit, not by
      eyeball — this is the standard task 481 set and met.
- [ ] Rewrite section D4's `### The boundary: why this section stops here` block. It currently says
      the section stops at the shape mismatch and that Route 1 is *unattempted*. Both halves are now
      false. Replace with: what Route 1 turned out to be, which hypothesis replaced which, the five
      shape-gated arms, and the boundary that remains (the terminus restatement, which is task 481's
      Phase 6 and is not landed here).
- [ ] Do **not** proceed into the terminus restatement, the `_at`/`_selfGuarded`/`_fixed` families,
      or any non-vacuity stock. Phase 5 ends at `universeClosedAt_signedUniverse_of_propositional`.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that clause 2 needs nothing new — that
`timeMergeClosed_identifyTime_signedUniverse hL` discharges it exactly as it does for the
`_of_headroom` original. Confirm at implementation time by assembling
`universeClosedAt_signedUniverse_of_propositional` as a literal two-component anonymous constructor
mirroring the `_of_headroom` line; if clause 2 needs an argument the `_of_headroom` form does not,
that is a second shape mismatch and must be recorded in Phase 6 rather than paid for with a new
hypothesis.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section D4, plus its
  boundary block.

**Verification**:
- `lake build` exits 0.
- `#check universeClosedAt_signedUniverse_of_propositional` shows no `UnorderedSuccessorLabelClosed`
  argument, no `OrdTimesKnown` argument, and no frame-class hypothesis.
- `#print axioms` on it shows only `[propext, Classical.choice, Quot.sound]`.
- All nine `signedUniverse` carriers and both `_of_headroom` originals verified byte-identical
  against the pre-task baseline commit by programmatic comparison.

---

### Phase 6: The verdict — register amendment, Phase 6/7 reachability, and the final gate [IN PROGRESS]

**Goal**: The task's decision recorded durably in the source, the reachability question answered
explicitly, and every acceptance gate run. This phase executes in **both** the success and the
failure case; only its content differs.

**Tasks**:
- [ ] **Amend the C9 register. Entry 16 is the primary site**, not 11 or 21. Entry 16 is
      *"An unconditional `applyRule_emitted_time_mem`, without `OrdTimesKnown`"* — it is the entry a
      reader would otherwise cite to conclude that the restricted form is forbidden, and it is the
      entry that becomes misleading the moment a restricted form lands. The task description names
      11 or 21 as the likely sites; this plan deviates deliberately, and the deviation must be
      stated in the summary.
      - *Success case*: amend entry 16 to record that the **unconditional** statement remains refuted
        (unchanged), and that a **syntactically restricted** form now exists, is named, and reaches
        exactly the `untl`/`snce`-free fragment; state that it does not weaken the refutation
        because the two statements are incomparable.
      - *Failure case*: amend entry 16 to record the negative result — the specific rule, the
        specific configuration, and why `untlSnceFree` does not exclude it — so that a future reader
        does not re-attempt Route 1 on the same evidence this task started from.
- [ ] Amend entry 21's closing section and the D4 boundary block only to the extent they now assert
      something false. In the success case both currently say Route 1 is *unattempted*, which must
      change. In the failure case both are nearly correct already and need only "unattempted"
      changed to "attempted and refuted, see entry 16".
- [ ] **Do not add a 25th entry.** The register must still open "Twenty-four statements" and hold
      exactly 24 numbered entries. Verify by counting, not by intent.
- [ ] **Answer the reachability question explicitly**, in the task summary, in these terms:
      - Is task 481's Phase 6 (`universeClosedAt_signedUniverse_of_propositional` plus the terminus
        restatement) now reachable *as originally written*? In the success case, note that the first
        half is now landed by this task's Phase 5 and that only the terminus restatement remains;
        re-read task 481's Phase 6 task list and state which of its bullets survive unchanged and
        which need rewording.
      - Is Phase 7 (non-vacuity for that terminus) reachable? Its blocker was purely transitive, but
        it carries its own open question — task 481's Phase 7 note flags that the seriality rule
        emits `T(someFuture ⊤)` at every branch and that `someFuture φ = untl ⊤ φ`, which deserves
        inspection against `TableauClosed C` on a nonempty `untlSnceFree` stock. State whether that
        question is settled or still open; do not assert Phase 7 is reachable without addressing it.
      - Should landing them be a **resumption of task 481** or a **further follow-up task**? Give one
        recommendation with a reason, not a menu.
- [ ] Run the final gate: `lake build`, `lake build BimodalTest`, and
      `bash scripts/check-module-invariants.sh`. Compare the invariants output against the pre-task
      baseline check-by-check; no check that passed at baseline may fail. Note that the script's
      "C9" check (task-number citations under `FormalSystem/`) is a *different* C9 from
      `MintBound.lean`'s in-file section C9 register — do not conflate them, and in particular do not
      write a task number into any register amendment.
- [ ] Write the task summary to `summaries/01_route1-restricted-time-sweep-summary.md`, including a
      Scope Hypothesis results table for every phase.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the register stands at exactly 24 entries and that entry 16
is the correct amendment site. Confirm at implementation time by re-reading entries 11, 16, and 21
in full before editing any of them and by counting the numbered entries after editing; if entry 16
turns out not to cover the finding, say so in the summary and amend 21 instead — but a 25th entry
requires an explicit justification in the summary, and the task description's default is against it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — section C9 register
  (entry 16, and 21 as needed) and section D4's boundary block.
- `specs/483_route1_restricted_applyrule_emitted_time_mem/summaries/01_route1-restricted-time-sweep-summary.md`
  — new.

**Verification**:
- `lake build` exits 0 and `lake build BimodalTest` exits 0.
- `bash scripts/check-module-invariants.sh` reports no check failing that passed at the pre-task
  baseline.
- The C9 register opens "Twenty-four statements" and contains exactly 24 numbered entries.
- Zero `sorry` added anywhere; `MintBound.lean` still declares zero axioms.
- The summary contains an explicit, unhedged answer to each of the three reachability questions.

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase boundary from Phase 3 onward.
- [ ] `lake build BimodalTest` exits 0 at task close.
- [ ] `bash scripts/check-module-invariants.sh` — no check failing that passed at the pre-task
      baseline commit.
- [ ] Every new public declaration: `#print axioms` shows only
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Zero `sorry` added; zero vacuous definitions added; zero new global `@[simp]` attributes.
- [ ] All nine `signedUniverse` carriers and both `_of_headroom` originals byte-identical against the
      pre-task baseline, verified programmatically.
- [ ] `applyRule_emitted_time_mem` and `applyRule_emitted_time_mem_ordTimesKnown_needed` unmodified.
- [ ] `unorderedSuccessor_knownTimes_subset`'s elaborated signature unchanged.
- [ ] C9 register: exactly 24 entries, opening line unchanged.
- [ ] No file outside `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` and
      the task's own `specs/` directory is modified.

## Artifacts & Outputs

- `specs/483_route1_restricted_applyrule_emitted_time_mem/reports/01_haux-census.md` — the per-arm
  `haux` census (Phase 1).
- `specs/483_route1_restricted_applyrule_emitted_time_mem/probes/Probe1.lean` — standalone proofs of
  the five arm exclusions and the restricted sweep (Phases 2-3).
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — in the success case:
  `applyRule_emitted_time_mem_of_untlSnceFree` (D3), the haux-free pick/engine propagation (D3), the
  haux-free D4 composites, `universeClosedAt_signedUniverse_of_propositional` (D4), a rewritten D4
  boundary block, and a C9 entry 16 amendment. In the failure case: a C9 entry 16 amendment
  recording the negative result, and boundary-block prose changed from "unattempted" to "refuted".
- `specs/483_route1_restricted_applyrule_emitted_time_mem/summaries/01_route1-restricted-time-sweep-summary.md`
  — including the explicit Phase 6/7 reachability verdict and the resumption-vs-follow-up
  recommendation.

## Rollback/Contingency

Every phase from 3 onward is a purely **additive** edit to a single file, committed per substep, so
rollback is `git revert` of the phase's commits with no cross-module fallout. The two structural
guards that make this safe are enforced as verification items rather than assumed: the original
`applyRule_emitted_time_mem` is never edited, and `unorderedSuccessor_knownTimes_subset`'s signature
never changes — so no landed consumer, including D3's discharge and the nine `signedUniverse`
carriers, can break.

If Route 1 fails at any phase, there is nothing to roll back: the escape rule routes directly to
Phase 6, the register amendment is the deliverable, and the probe file stays in `specs/` as the
evidence. The task closes complete either way.
