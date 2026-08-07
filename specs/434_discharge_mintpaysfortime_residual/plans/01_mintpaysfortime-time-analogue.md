# Implementation Plan: Task #434

- **Task**: 434 - Discharge `MintPaysForTime fc U Tmax` (the open mathematical core on the totality terminus)
- **Status**: PARTIAL
- **Effort**: 15 hours
- **Dependencies**: None (unblocks task 432 Phase 7)
- **Research Inputs**: `specs/434_discharge_mintpaysfortime_residual/reports/01_spawn-inherited-research.md`
- **Artifacts**: plans/01_mintpaysfortime-time-analogue.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md, lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The residual `MintPaysForTime fc U Tmax`
(`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4010`) is the last open
mathematical obligation on `buildTableauAt_isSome_of_budget`. This plan attacks it in the order the
source file itself dictates: first land the **missing time-coordinate accounting over `applyRule`**
that the file names by its absence in three separate docstrings, then use that accounting to render
a satisfiability verdict on `MintPaysForTime` as literally stated, then either prove it or repair it
by the same pattern the two completed siblings used (`OrdTimesKnown` for task 431's coordinate,
`UniverseClosedAt` + `TimeMergeClosed` for task 432's).

The time-coordinate accounting is scheduled first and delivered under a stable name because it is
also **task 432's Phase 7 blocker** and its value is independent of whether `MintPaysForTime`
survives. Nothing downstream of it in this plan can invalidate it.

### Research Integration

The research input is the inherited spawn analysis; the substantive findings driving this plan come
from reading the source, and each is cited by declaration name rather than by line number (the line
numbers in the task description are stale):

1. **The deliverable is named in-source by its absence, three times.** `MintPaysForTime`'s own
   docstring, the section note preceding `applyRule_emitted_world_dichotomy`, and
   `UnorderedSuccessorLabelClosed`'s obligation map all say the same thing: *"There is no
   `applyRule_emitted_time_mem` — no statement bounding the times a rule emits at by `b.knownTimes`,
   with the time-minting rules separated out."* The name to use is therefore already chosen by the
   file. Phase 3 lands exactly it.

2. **All fresh times in `applyRule` are `branch.nextTime`, uniformly.** Verified at every fresh-time
   emission site in `Tableau.lean` (`freshTime := branch.nextTime` at the `allFutureNeg` /
   `allPastNeg` / `someFuturePos` / `somePastPos` / `untlPos` / `sncePos` sites, at the `untlNeg` /
   `snceNeg` ACTIVE arms, and at `densityRule`'s interpolation site). So the time dichotomy has the
   **same two-case shape** as the landed world dichotomy — `∈ b.knownTimes ∨ = b.nextTime`, no third
   case, no `nextTime + k` widening. Phase 5 mirrors `applyRule_emitted_world_dichotomy` line for
   line.

3. **The two rule lists are incomparable, not nested.** `freshLabelRules` is
   `{boxNeg, diamondPos, allFutureNeg, allPastNeg, someFuturePos, somePastPos, untlPos, sncePos}`
   (`freshLabelRules_card = 8`). `boxNeg`/`diamondPos` emit at `nextWorld` at the trigger's *own*
   time, so they mint no time; `densityRule` (absent from the list, carrying its own
   `existingIntermediates` guard) and the `untlNeg`/`snceNeg` ACTIVE arms (classified
   `ruleSelfGuarded`) mint times while absent from it. So neither list contains the other. This is
   the precise content of the caution task 432 recorded and this task's description repeats, and
   Phase 1 makes it a machine-checked fact rather than a comment.

4. **`expandOnceNoFresh` is the in-repo evidence for the ordering-length test.** It rejects
   time-introducing candidates with `newOrd.constraints.length > timeOrd.constraints.length`, *after*
   a separate `ruleMintsFreshLabel` test — two distinct tests in sequence, which is only necessary if
   neither subsumes the other. Confirms finding 3 operationally.

5. **A concrete refutation vehicle for `MintPaysForTime` exists and is cheap to check.** `untlNeg`
   is in `carrierBase` (available at *every* frame class), its ACTIVE arm returns `.branching` —
   hence a genuine `unorderedSuccessorBranches` entry — and it mints `branch.nextTime` while sitting
   outside `freshLabelRules`. At such a step: disjunct 1's first conjunct fails (a known time was
   added), and disjunct 2 needs `mintPotential` to *strictly* decrease over the index set
   `freshLabelRules ×ˢ U` — which a non-`freshLabelRules` rule has no reason to move at all, and
   `mintTimeBudget = knownTimes.card + mintPotential` rises with the new time. Both disjuncts fail.
   `densityRule` is a second vehicle but is gated to `.Dense`/`.Dedekind` (`denseRules`), so
   `untlNeg` is the one that gives a frame-class-universal witness. This is why Phase 4 is a verdict
   phase with a refutation as its *expected* outcome rather than a formality.

6. **The file is currently sorry-free** (`grep -c sorry` = 0) and every terminus is conditional only
   through named hypotheses. That property is a hard gate at Phase 9.

### Prior Plan Reference

No prior plan for this task. Two completed sibling residuals on the same terminus supply effort
calibration and a validated repair pattern:

- **Task 431** (`DifficultyBounded`): refutable at every `D` and every frame class
  (`difficultyBounded_multiplicity_false`); repaired by `StepLengthBounded` plus sibling termini.
- **Task 432** (`UniverseClosed`): clause 2 refutable at every nonempty `U`
  (`universeClosed_identify_retime_false`), clause 1 refutable at a concrete finite `signedUniverse`
  (`universeClosed_fresh_world_escapes`); repaired by `UniverseClosedAt` + `TimeMergeClosed L`, with
  `universeClosedAt_of_universeClosed` recording that the repair is a *weakening* of the hypothesis
  and hence a strengthening of every theorem restated against it.

The pattern both siblings validated, and which this plan follows: **refute with a machine-checked
witness → repair so the new hypothesis is weaker than the old → prove the direction lemma → restate
the termini → discharge the repaired form at a concrete instantiation → retain the original verbatim
and add a register entry.** Two-for-two refutations is why Phase 4 exists at all and why it precedes
every proof-side investment.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no ROADMAP.md was consulted.

## Goals & Non-Goals

**Goals**:
- Land `applyRule_emitted_time_mem` and `applyRule_emitted_time_dichotomy` in `MintBound.lean` under
  those exact names, sorry-free, as **standalone early deliverables** consumable by task 432 Phase 7.
- Settle, by machine-checked fact, which of `TableauRule`'s 36 constructors can emit at a time
  outside `b.knownTimes`, and that this list is incomparable with `freshLabelRules`.
- Render an explicit satisfiability verdict on `MintPaysForTime` as literally stated, with a witness
  if it is refutable.
- Render an explicit verdict on the open time-reuse sub-question (can the engine re-issue a time an
  earlier `identifyTime` retired?).
- Deliver a theorem establishing `MintPaysForTime` — or, if refuted, its repaired form that leaks no
  new hypothesis into the terminus — at a concrete, useful instantiation, sorry-free and axiom-free.
- `lake build` green at task end.

**Non-Goals**:
- Discharging the other three residual hypotheses on `buildTableauAt_isSome_of_budget`
  (`PostBlockingSettles`, `ArmSettlement`, `UnorderedSuccessorLabelClosed`).
- Editing `Saturation.lean`, `Fuel.lean`, or `Tableau.lean` — md5-pinned frozen by the parent plan.
- Withdrawing, weakening, or re-proving any landed declaration. All work is **additive**; every
  previously-landed proof term stays byte-unchanged.
- Re-attempting anything in the 12-entry do-not-re-attempt register (section C9), in particular
  entry 5 (`witnessPresent_identifyTime` unconditional) and entry 7 (`OrdTimesLeMaxTime` across the
  identification arm).
- Raising `maxBranches`, changing fuel figures, or touching the engine's runtime guards.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The 36-arm time sweep does not close with the world sweep's tactic skeleton (times are *rewritten* by `identifyTime`, worlds are not) | H | H | Phase 2 lands the time-coordinate plumbing helpers *before* the sweep, and Phase 3 pre-declares the `timeLinearity` identification arm as the one arm expected to need its own treatment. If it resists, the fallback is stated in Phase 3: exclude `timeLinearity` by hypothesis (as the world lemma excludes `boxNeg`/`diamondPos`) and let the dichotomy in Phase 5 re-absorb it. |
| Elaboration blows the heartbeat budget (the world sweep needed `set_option maxHeartbeats 4000000`) | M | H | Budget `maxHeartbeats 4000000` from the start on the sweep; use scoped `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` for per-phase verification and reserve full `lake build` for Phase 9. |
| `MintPaysForTime` turns out **provable**, invalidating Phases 6-8's repair framing | M | L | Phase 4's pre-declared outcome table routes explicitly: on a "provable" verdict, Phases 7-8 collapse to a direct proof at the concrete instantiation and Phase 6's verdict is still required (the σ-hit obligation is what the proof must discharge). No phase is wasted either way. |
| The time-reuse sub-question is genuinely undecided at phase end | M | M | Phase 6 is scoped as a **verdict** phase, not a proof phase: an "open, with the obstruction localised and the decision-relevant configuration exhibited" verdict is a valid, pre-declared outcome, recorded in-source. It must not be papered over with a vacuous definition (prohibited by `lean4.md`). |
| Repairing `MintPaysForTime` requires restating a long tail of termini (11 consuming sites) | M | M | Phase 8 restates only the two seed-level termini, mirroring exactly how the 432 repair landed `buildTableauAt_isSome_of_budget_at` rather than restating every site. The originals are retained verbatim. |
| A "repair" that is secretly a weakening (the entry-7 trap) | H | L | Phase 7 must land the direction lemma (`..._of_...`, mirroring `ordTimesLeMaxTime_of_ordTimesKnown` / `universeClosedAt_of_universeClosed`) as a **gate**: no repaired predicate lands without a machine-checked implication fixing its direction relative to the original. |
| A vacuous-definition shortcut under time pressure | H | L | `lean4.md`'s prohibition is absolute. Phase 9's gate greps for `:= True`, `:= trivial`, `:= Unit` on every declaration this task adds. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 (and 2, for phase 3) |
| 3 | 5 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 4, 5, 6 |
| 6 | 8 | 7 |
| 7 | 9 | 1-8 |

Phases within the same wave can execute in parallel. All phases write to the single file
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`, appending to a new
section; a parallel dispatch of waves 1 and 2 must therefore serialise the writes or partition by
declaration block.

---

### Phase 1: The time-minting rule census [COMPLETED]

**Goal**: Settle, as machine-checked fact, which `TableauRule` constructors can emit at a time
outside `b.knownTimes`, and that this list is **incomparable** with `freshLabelRules`. The source
says "no statement in the development says what that list is"; this phase makes that statement.

**Tasks**:
- [x] Add a new section (`## D1. The time coordinate: the minting census`) at the end of
      `MintBound.lean`'s declaration body, before section C9, with a docstring explaining why
      `ruleMintsFreshLabel` is the wrong list, citing `densityRule`'s `existingIntermediates` guard
      and the `untlNeg`/`snceNeg` ACTIVE arms by name.
- [x] Define `ruleMintsFreshTime : TableauRule → Bool`, listing exactly the constructors whose
      `applyRule` arms reach a `freshTime := branch.nextTime` binding. Derive the list by reading
      `Tableau.lean`'s `applyRule` — do **not** guess it from `ruleMintsFreshLabel`.
- [x] Define `freshTimeRules : Finset TableauRule` and prove `mem_freshTimeRules :
      r ∈ freshTimeRules ↔ ruleMintsFreshTime r = true` by `cases r <;> simp [...]`, mirroring
      `mem_freshLabelRules`. This is the anti-drift guarantee the `freshLabelRules` pair already has.
- [x] Prove `freshTimeRules_card` by `decide`.
- [x] Prove the incomparability, both directions, by `decide`:
      `boxNeg ∈ freshLabelRules ∧ boxNeg ∉ freshTimeRules` (world minting is not time minting) and
      `densityRule ∈ freshTimeRules ∧ densityRule ∉ freshLabelRules`, plus the `untlNeg`/`snceNeg`
      instances. Name the assembled statement `freshTimeRules_incomparable_freshLabelRules`.
- [x] Docstring the incomparability theorem with the `expandOnceNoFresh` evidence: it runs the
      `ruleMintsFreshLabel` test **and then** the `newOrd.constraints.length` test, two tests in
      sequence, which is only necessary because neither subsumes the other.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The census is expected to contain **9** constructors — `allFutureNeg`,
`allPastNeg`, `someFuturePos`, `somePastPos`, `untlPos`, `sncePos`, `untlNeg`, `snceNeg`,
`densityRule` — and to exclude `boxNeg` and `diamondPos`. This is a hypothesis read off the
`freshTime := branch.nextTime` binding sites, **not** a fact: confirm it by walking every one of
`applyRule`'s 36 constructor arms in `Tableau.lean` and recording, per arm, whether any emitted
formula's label time can differ from the trigger's or from a branch time. If the count differs, the
census is what changes — the plan's later phases consume `freshTimeRules` by name, not by cardinality.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - new section D1 appended
  before section C9; `ruleMintsFreshTime`, `freshTimeRules`, `mem_freshTimeRules`,
  `freshTimeRules_card`, `freshTimeRules_incomparable_freshLabelRules`.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `mem_freshTimeRules` closes by `cases r <;> simp [...]` over all 36 constructors (no `sorry`, no
  `decide` on the iff — the `simp` route is what keeps it a genuine agreement proof).
- `lean_verify FormalSystem.Metalogic.Decidability.freshTimeRules_incomparable_freshLabelRules`
  reports axiom-free.

---

### Phase 2: Time-coordinate plumbing helpers [COMPLETED]

**Goal**: Land the time-coordinate analogues of the three helper lemmas the world sweep is built
from, so Phase 3's sweep has the same closers available that `applyRule_emitted_world_mem` had.

**Tasks**:
- [x] `mem_filterMap_time` — the analogue of `mem_filterMap_world`: a propagation block reading
      formulas off the branch through a `List.filter` selector and relabelling them emits only at
      times the branch already carries, given
      `hF : ∀ x y, F x = some y → y.label.time = x.label.time`. Conclusion in `b.knownTimes` via
      `mem_knownTimes_of_mem`.
- [x] `mem_filterMap_const_time` — the analogue of `mem_filterMap_const_world`, for the blocks that
      relabel to a single constant time (`freshTime`): given
      `hF : ∀ x y, F x = some y → y.label.time = t`, conclude `g.label.time = t`.
- [x] `mem_boxDiamondPersistence_time` — read off the existing `mem_boxDiamondPersistence_label`
      (the world sweep uses `(… hg).1`; this phase needs the time component `.2`, or an explicit
      restatement if the existing lemma's conjunct order differs). Do **not** re-prove
      `mem_boxDiamondPersistence_label`; project from it. *(deviation: altered - cannot be a standalone declaration; `boxDiamondPersistence` is `private` to `Tableau.lean`, so its name is unstateable outside that module. Recorded as an in-source note instead; the projection is applied inline at the per-rule pinning lemmas, exactly as the world sweep applies it.)*
- [x] `mem_identifyTime_time` — the analogue of `mem_identifyTime_world`, and the one that is **not**
      a mirror: `Branch.identifyTime src tgt` rewrites times, so the honest conclusion is
      `g.label.time = tgt ∨ g.label.time ∈ b.knownTimes`. State it in exactly that disjunctive form.
      Do **not** attempt an unconditional `∈ b.knownTimes` conclusion — that is the shape register
      entry 10 refutes in a neighbouring coordinate, and `knownTimes_identifyTime_subset` /
      `src_not_mem_knownTimes_identifyTime` in `Fuel.lean` are the available true facts.
- [x] Add a companion `mem_identifyTime_time_at_trigger`: when `tgt` is the `t₁` of
      `firstIncomparablePair b ord`, `firstIncomparablePair_spec` already gives `t₁ ∈ b.knownTimes`,
      so the disjunction collapses. This is the exact move
      `universeClosedAt_identify_at_trigger` makes for the 432 repair; reuse that bridge's shape.

*(deviation: altered - six additional helpers landed beside the five planned ones, because the time coordinate has emission shapes the world coordinate does not: `exists_constraint_from_of_pathN` and `exists_constraint_from_of_mem_pastOf` (past-directed mirrors of the existing forward lemmas), `mem_knownTimes_of_mem_futureOf` / `mem_knownTimes_of_mem_pastOf` (the `OrdTimesKnown` bridge the four universal-propagation rules need), and `mem_filterMap_futureOf_time` / `mem_filterMap_pastOf_time`. `mem_filterMap_const_time` is generic in the source list's element type rather than fixed to `List SignedFormula`, since `boxPos`/`diamondNeg` range over worlds.)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D1 continued;
  `mem_filterMap_time`, `mem_filterMap_const_time`, `mem_boxDiamondPersistence_time`,
  `mem_identifyTime_time`, `mem_identifyTime_time_at_trigger`.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Each helper's statement is checked against its world counterpart for shape parity via
  `lean_hover_info`; `mem_identifyTime_time`'s deliberate *departure* from parity (the disjunction)
  is recorded in its docstring with the reason.
- No `sorry` introduced; existing declarations byte-unchanged (`git diff` shows additions only).

---

### Phase 3: `applyRule_emitted_time_mem` — the deliverable task 432 consumes [COMPLETED]

**Goal**: Land the time-dimension analogue of `applyRule_emitted_world_mem` under that exact name.
**This is the phase whose output task 432 Phase 7 consumes by name.** It must land as a standalone,
stably-named theorem — not folded into a larger composite — and it is valid regardless of every
verdict rendered later in this plan.

**Tasks**:
- [x] State, mirroring `applyRule_emitted_world_mem`'s signature in the time coordinate: *(deviation: altered — the landed signature additionally carries `haux : OrdTimesKnown b ord`. Not a convenience: `allFuturePos` / `allPastPos` / `someFutureNeg` / `somePastNeg` propagate to `TimeOrdering.futureOf` / `pastOf` and nothing in `applyRule` ties an ordering time to the branch, so the plan's unconditional form is FALSE, not merely unproved — `applyRule_emitted_time_mem_ordTimesKnown_needed` decides a refuting configuration. Phase 2's landed docstring already pre-declared this hypothesis and named that witness. The invariant is available at every consuming site via `ordTimesKnown_expandOnceUnblocked`, so it leaks nothing into the terminus.)*
      ```
      theorem applyRule_emitted_time_mem {rule : TableauRule} {sf : SignedFormula}
          {b : Branch} {ord : TimeOrdering}
          (hsf : sf ∈ b) (hmint : ruleMintsFreshTime rule = false) :
          ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes
      ```
      Use `ruleMintsFreshTime rule = false` as the single exclusion hypothesis rather than a chain of
      `rule ≠ …` inequalities: the census is 9 rules wide, where the world lemma's was 2, and the
      `Bool` form keeps the signature stable if Phase 1's census count moves.
- [x] Add the `b.timeFinset` corollary `applyRule_emitted_timeFinset_mem` (one line, via
      `List.mem_toFinset`) so consumers can work in either the `List` or the `Finset` coordinate —
      the world lemma concludes in `b.worldFinset`, so this restores full shape parity.
- [x] Prove by `cases sf with | mk sign formula label => cases rule <;> first | …`, following the
      world sweep's tactic skeleton: `exact absurd rfl hmint`-style discharge of the excluded rules
      (adapted to the `Bool` hypothesis — `simp at hmint` on each minting constructor), then the
      per-arm closer chain built from Phase 2's helpers plus `mem_knownTimes_of_mem hsf` for the
      trigger's own time.
- [x] Set `set_option maxHeartbeats 4000000 in` on the sweep, matching the world sweep's measured
      budget.
- [x] Docstring it as the answer to the three in-source "there is no `applyRule_emitted_time_mem`"
      notes, naming which arms fall to which closer (trigger's own time / branch time via the
      filterMap helpers / `boxDiamondPersistence` block / the identification arm).

*(deviation: altered — the Scope Hypothesis's "identification arm is the only hard one" claim is refuted by execution. `timeLinearity` closed exactly as planned via `mem_identifyTime_time_at_trigger`, and the pre-declared narrowing fallback was **not** taken: the signature excludes no rule by name. The arm that actually needed separate treatment was `orderTrichotomy`, which emits at the common predecessor `t₀` reachable only through the candidate list's `ord.pastOf` source; it is discharged by its own lemma `applyRule_orderTrichotomy_emitted_time`. Two extra closers landed with it: `mem_filterMap_const_time_mem` and `fst_mem_of_mem_trichotomyCandidates`.)*

*(deviation: altered — every closer in the sweep is a tactic-mode `refine … ?_` rather than an `exact … (by …)`. A term-level `by` block inside a `first` alternative elaborates with error recovery, so a failing side goal is filled with `sorryAx` and the alternative appears to succeed. The first draft of the sweep did exactly that and `#print axioms` reported `sorryAx`; the landed form is verified axiom-free. This is recorded in `mem_filterMap_const_time_mem`'s docstring.)*

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: interface

**Scope Hypothesis**: The sweep is expected to discharge **27** non-minting constructors (36 minus
Phase 1's 9), with the `timeLinearity` identification arm as the single arm needing
`mem_identifyTime_time_at_trigger` rather than a mirror closer. Both the arm count and the
"identification arm is the only hard one" claim are hypotheses. Confirm by running the sweep and
reading the residual goal list; if the identification arm resists, apply the pre-declared fallback —
add `rule ≠ .timeLinearity` to the signature and let Phase 5's dichotomy re-absorb `timeLinearity`
by name, exactly as the world dichotomy re-absorbs `boxNeg`/`diamondPos`. Record the fallback in the
docstring if taken; do **not** widen it to further rules without escalating per
`plan-compliance.md`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D1 continued;
  `applyRule_emitted_time_mem`, `applyRule_emitted_timeFinset_mem`.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `lean_verify FormalSystem.Metalogic.Decidability.applyRule_emitted_time_mem` reports sorry-free
  and axiom-free.
- `grep -n "applyRule_emitted_time_mem" MintBound.lean` shows the name declared exactly once at
  top level (not `private`, not inside a section that scopes it away) — task 432 resolves it by name.
- The three in-source notes that assert its absence are located but **not yet edited** (that is
  Phase 9's reconciliation), so the transitional inconsistency is deliberate and recorded.

---

### Phase 4: Satisfiability verdict on `MintPaysForTime` as stated [COMPLETED]

**Goal**: Decide, before any proof-side investment, whether `MintPaysForTime fc U Tmax` is provable,
repairable, or refutable. Both completed siblings on this terminus came out refutable as literally
stated; this phase treats that as the leading hypothesis and tests it.

**Tasks**:
- [x] Read `MintPaysForTime`'s two disjuncts against Phase 1's census and record the decision
      structure: at an `unorderedSuccessorBranches` step, either no known time was added (disjunct 1
      is live) or the rule that fired is in `freshTimeRules` (disjunct 2 must carry it). Note that
      `mintPotential`'s index set is `freshLabelRules ×ˢ U`, so a `freshTimeRules \ freshLabelRules`
      rule moves neither disjunct.
- [x] Attempt the refutation at the `untlNeg` ACTIVE arm: construct a concrete `b`, `ord`, `tr`,
      `fc`, `U`, `σ` where `expandOnceUnblocked` fires `untlNeg`, the successor gains a known time,
      and no `freshLabelRules ×ˢ U` pair flips. `untlNeg` is in `carrierBase`, so the witness is
      available at **every** frame class — state the witness universally quantified in `fc`, as
      `difficultyBounded_multiplicity_false` and `universeClosed_identify_retime_false` are.
- [x] Name the witness `mintPaysForTime_untlNeg_false` (or `_densityRule_false` if the
      `.Dense`-gated vehicle is the one that lands; then also record why the frame-class-universal
      version was not available).
- [x] Check the vacuity boundary, mirroring `universeClosed_identify_empty` /
      `universeClosed_nonempty_false`: does `MintPaysForTime` hold at `U = ∅` (confinement forces
      `b = []`, no unordered successors)? If so, land `mintPaysForTime_empty` and state whether
      `{∅}` is the whole satisfiability set.
- [x] Write the verdict as a `/-! ### … -/` section note above the witness, in the register's voice:
      one-line cause, the refuting declaration name, and the repair direction.

**VERDICT RECORDED: refutable.** Evidence: `mintPaysForTime_untlNeg_false`, universally quantified
in the frame class **and** in `Tmax`, axiom-free. The `untlNeg` ACTIVE-arm vehicle landed as
expected (the `.Dense`-gated `densityRule` was not needed). The vacuity boundary landed as
`mintPaysForTime_empty`. One additional structural fact landed beside the witness and is load-bearing
for Phase 7: `witnessPresent_eq_false_of_not_freshLabel` proves `witnessPresent` is identically
`false` outside `freshLabelRules`, which **rules out** the obvious repair of re-indexing
`mintPotential` on `freshTimeRules` — the three added columns would be permanently false, adding
`3 · |U|` to the count and never moving. The rule coordinate is not where the repair lives; disjunct
1's first conjunct is.

*(deviation: altered — the witness universe is a concrete three-element `Finset`, not a universally
quantified nonempty `U`. This mirrors `universeClosed_fresh_world_escapes` rather than
`universeClosed_identify_retime_false`: the refutation is driven by the engine's rule scheduler
choosing `untlNeg`, which is a property of the concrete configuration, not of `U` as such.)*

**Pre-declared outcomes** (exactly one must be recorded, with its named evidence):
| Verdict | Evidence required | Routes to |
|---------|-------------------|-----------|
| **Provable as stated** | a sorry-free proof sketch identified, with the σ-hit obligation named as its one open input | Phase 7 collapses to a direct proof; Phase 6 still required |
| **Repairable** | the specific quantifier or index set that is too wide, plus the narrowing that fixes it and leaks no new terminus hypothesis | Phase 7 as planned |
| **Refutable** | a machine-checked witness theorem, universally quantified in `fc` if available | Phase 7 as planned, repair mandatory |

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The expected verdict is **refutable**, via `untlNeg`, at every frame class.
This is a hypothesis grounded in `untlNeg`'s `carrierBase` membership, its `.branching` return shape
(hence a real `unorderedSuccessorBranches` entry), its `freshTime := branch.nextTime` binding, and
its absence from `freshLabelRules`. Confirm by actually constructing and `decide`-ing the witness
configuration — do not record a refutable verdict on the argument sketch alone. If the witness will
not close, downgrade to the "repairable" row and say which step of the sketch failed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - new section D2
  (`## D2. `MintPaysForTime`: the verdict`); the verdict note, the witness theorem, and the vacuity
  boundary lemma. `MintPaysForTime` itself is retained **verbatim** — nothing in this file is
  withdrawn.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Exactly one verdict row recorded, with its named evidence present as a declaration.
- If refutable: `lean_verify` on the witness reports axiom-free, and the witness statement is
  universally quantified in `fc` (or the reason it cannot be is written down).
- `MintPaysForTime`'s existing declaration and every theorem stated against it are byte-unchanged.

---

### Phase 5: The time dichotomy and its engine-level lift [COMPLETED]

**Goal**: Complete the time coordinate the way the world coordinate is complete: every emission sits
at a branch time or at `Branch.nextTime`, no third case — then lift it to the level
`MintPaysForTime` and `UnorderedSuccessorLabelClosed` actually quantify over.

**Tasks**:
- [x] Per minting rule in `freshTimeRules`, prove the `nextTime` pinning lemma, mirroring
      `applyRule_boxNeg_emitted_world` / `applyRule_diamondPos_emitted_world`. Group them where the
      proof is shared (the six `freshLabelRules ∩ freshTimeRules` members share the
      `freshTime := branch.nextTime` + `boxDiamondPersistence` shape); handle `densityRule`,
      `untlNeg`, `snceNeg` individually since their arms differ.
      Note these lemmas cannot conclude `= b.nextTime` unconditionally for the rules whose arms also
      re-include the source formula (`untlNeg`/`snceNeg` re-include their trigger in every arm, per
      `ruleSelfGuarded`'s docstring) — for those, the conclusion is the disjunction directly.
- [x] Assemble `applyRule_emitted_time_dichotomy`, mirroring `applyRule_emitted_world_dichotomy`
      exactly:
      ```
      theorem applyRule_emitted_time_dichotomy {rule : TableauRule} {sf : SignedFormula}
          {b : Branch} {ord : TimeOrdering} (hsf : sf ∈ b) :
          ∀ g ∈ (applyRule rule sf b ord).1.emitted,
            g.label.time ∈ b.knownTimes ∨ g.label.time = b.nextTime
      ```
      Assemble it from Phase 3's sweep plus the per-rule pinning lemmas and nothing else — the world
      dichotomy's proof is a `by_cases` chain of exactly that shape; follow it.
- [x] Lift to the engine: `unorderedSuccessor_time_dichotomy`, quantified over
      `nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1`, giving
      `∀ t ∈ nb.knownTimes, t ∈ b.knownTimes ∨ t = b.nextTime`. Route through the existing
      `expandOnceUnblocked` shape lemmas and `knownTimes_mono`; do not re-derive the pick
      destructuring.
- [x] Derive the cardinality corollary `knownTimes_card_le_succ_of_unorderedSuccessor`:
      `nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card + 1`. This is the quantitative form
      `MintPaysForTime`'s disjunct 1 is really about, and Phase 7's repair will be stated against it.

*(deviation: altered — the nine minting rules landed as **two** lemmas rather than nine. The six in
`freshTimeRules ∩ freshLabelRules` share one arm shape and are grouped as
`applyRule_emitted_nextTime_of_freshLabel` (conclusion `= b.nextTime`, no `hsf` needed); the three
in `freshTimeRules \ freshLabelRules` are grouped as
`applyRule_emitted_time_dichotomy_selfGuarded` (conclusion the disjunction, `hsf` needed). This is
the grouping the plan's own task text authorises — "group them where the proof is shared" — with the
three individually-handled rules sharing enough arm structure that splitting them further would
have duplicated one tactic block three times. `OrdTimesKnown` is not needed by either minting
lemma; it enters the dichotomy only through the sweep.)*

*(deviation: altered — `applyRule_emitted_time_dichotomy` carries `haux : OrdTimesKnown b ord`,
inherited from `applyRule_emitted_time_mem`. Same cause and same justification as the Phase 3
deviation; `expandOnceUnblocked_ordTimesKnown` supplies it at every consuming site.)*

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D1 continued;
  the per-rule `nextTime` pinning lemmas, `applyRule_emitted_time_dichotomy`,
  `unorderedSuccessor_time_dichotomy`, `knownTimes_card_le_succ_of_unorderedSuccessor`.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `lean_verify FormalSystem.Metalogic.Decidability.applyRule_emitted_time_dichotomy` reports
  sorry-free and axiom-free.
- The dichotomy's proof cites only Phase 3's sweep and the per-rule lemmas — no new `sorry`, no
  appeal to an unproved hypothesis. Confirmed by reading the proof term, not by the build alone.

---

### Phase 6: Verdict on the time-reuse sub-question [COMPLETED]

**Goal**: Settle, with an explicit verdict, the genuinely open sub-question the source names: since
`Branch.nextTime = Branch.maxTime + 1` and `Branch.identifyTime` can *lower* `maxTime`, can the
engine re-issue a time an earlier identification retired? This is the σ-hit obligation of
`mintPotential_lt_of_mint` and it is intrinsic — the live-times reformulation carries it identically.

**Tasks**:
- [x] Restate the obligation precisely: `mintPotential_lt_of_mint` requires the firing formula to be
      `σ sf` for some `sf ∈ U`, and `σ`'s image omits exactly the times earlier identifications
      merged away. So the obligation is: *a minting formula does not sit at a merged-away time.*
- [x] Attempt the affirmative direction: does the run invariant already forbid reuse? Candidate
      route — `OrdTimesKnown` plus `src_not_mem_knownTimes_identifyTime` and
      `knownTimes_card_lt_identifyTime` (`Fuel.lean`) may show a retired time cannot re-enter
      `knownTimes` without a fresh mint above the current `maxTime`. Check whether `maxTime` dropping
      to a value *below* a retired time actually re-exposes that value as a future `nextTime`.
- [x] If the affirmative fails, exhibit the decision-relevant configuration: a concrete run prefix
      where `identifyTime` retires time `k`, `maxTime` drops below `k`, and a subsequent mint issues
      `k` again. Decide it if decidable; if the configuration cannot be driven through
      `expandOnceUnblocked` concretely, say so and say why.
- [x] Cross-check the live-times reformulation (filter additionally on the formula's time being a
      fixed point of `σ`) and confirm in-source that it carries the identical obligation — the source
      asserts this; verify it rather than repeating it.
- [x] Record the verdict as a `/-! ### … -/` note under section D2, and add the corresponding
      do-not-re-attempt register entry in Phase 9.

**VERDICT RECORDED: reuse possible.** Evidence, all decided or axiom-free:
`nextTime_reissues_retired_time` (`firstIncomparablePair` merges the branch's largest time away,
`Branch.maxTime` drops with it, and the post-identification `Branch.nextTime` is the retired value
again), `reuse_driven_through_engine` (two `expandOnceUnblocked` steps later the retired time is
back on the branch — so this is a run, not a hand-assembled `Branch`), `rhoSF_time_ne_src` and
`mint_not_in_rhoSF_image` (the σ-hit hypothesis of `mintPotential_lt_of_mint` is therefore **false**
at such a step, not merely unproved), and `rho_src_ne_src` (the live-times reformulation's fixed-point
filter excludes the re-minted formula for exactly the same reason, so the obstruction is intrinsic).

Consequence for the plan: the σ-hit obligation must be carried structurally by Phase 7's repair
rather than discharged, which is the pre-declared "reuse possible" route.

**Pre-declared outcomes** (exactly one):
| Verdict | Evidence required |
|---------|-------------------|
| **Reuse impossible** | a sorry-free lemma (`nextTime_not_reissued_of_runInvariant` or similar) discharging the σ-hit hypothesis of `mintPotential_lt_of_mint` |
| **Reuse possible** | a concrete configuration exhibiting it, decided; the σ-hit obligation then must be carried structurally (Phase 7's repair) rather than discharged |
| **Open, obstruction localised** | the exact missing fact named, the reason it is not available from the run invariant, and the configuration that would decide it — recorded in-source, **not** substituted by a vacuous definition |

**Timing**: 1.5 hours

**Depends on**: 4, 5

**Verification Tier**: local

**Scope Hypothesis**: No count is asserted. The task description and the source both frame this as
genuinely open; do not treat "open, obstruction localised" as a failure outcome, and do not treat the
"reuse impossible" outcome as the expected one. The hypothesis under test is only that **one** of the
three rows is reachable within the phase; if none is, mark the phase `[BLOCKED]` per
`plan-compliance.md` rather than annotating past it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D2 continued;
  the verdict note plus whichever declaration the chosen row requires.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Exactly one verdict row recorded with its evidence present.
- `grep -nE ":=\s*(True|trivial|Trivial|Unit)\s*$"` over the phase's additions returns nothing
  (`lean4.md` vacuous-definition prohibition).

---

### Phase 7: The repaired predicate and its direction lemma [BLOCKED]

**Goal**: Land the satisfiable form of the residual, with a machine-checked implication fixing its
direction relative to `MintPaysForTime`. The direction lemma is a **gate**, not a nicety: register
entry 7 exists because a "simplification" that was secretly a weakening was mistaken for a repair.

**BLOCKER** (Phase 7):
- **What failed**: No satisfiable repair of `MintPaysForTime` could be constructed. Both repair
  routes the plan and the Phase 4 verdict identify are refuted by machine-checked statements.
- **What was tried**:
  1. *The rule-coordinate narrowing* the plan's task 1 specifies ("the second disjunct's index set
     must cover `freshTimeRules`, not merely `freshLabelRules`"). Refuted in Phase 4:
     `witnessPresent_eq_false_of_not_freshLabel` proves `witnessPresent`'s match has exactly eight
     arms — one per `freshLabelRules` member — so the three added columns (`densityRule`, `untlNeg`,
     `snceNeg`) are `false` at every state of every run. The wider potential is the narrower one
     plus `3 · |U|` and moves exactly when it does.
  2. *Stating disjunct 1 against `knownTimes_card_le_succ_of_unorderedSuccessor`*, which the plan's
     task 1 also specifies. Since that inequality is now a theorem, the honest weakening is to drop
     disjunct 1's cardinality conjunct entirely and leave the ordering-rank conjunct. Refuted:
     `splitOrderedRank Tmax b ord = knownTimes.card * (Tmax² + 1) + (incompPairs b ord).card`, and
     the base `Tmax² + 1` is by construction one more than `incompPairs`' range
     (`incompPairs_card_le` plus the carried time bound), so one extra known time raises the rank by
     at least 1 regardless of what the pair count does. `splitOrderedRank_lt_of_knownTimes_lt` is
     that in general; `mintPaysForTime_rank_repair_false` decides the weakened predicate false at
     the Phase 4 configuration, at every frame class, for every `Tmax ≥ 3`.
- **Why it's stuck**: The rank conjunct fails at **every** time-minting step, and the potential
  conjunct fails at exactly the three self-guarded minting rules. Each of those three has its own
  termination argument and none of them is `mintPotential`: `untlNeg`/`snceNeg` are guarded by
  `futureOf`/`pastOf` emptiness plus `ord.timeCount < 4`, and `densityRule` by the
  maximal-unfilled-gap set. The obvious candidate potential for `untlNeg` — "branch times with empty
  forward reach" — does not decrease, because the arm removes the trigger's empty future and mints a
  fresh time whose future is empty, for a net change of zero. Composing the three into one measure
  that also survives the identification arm (which can *lower* `ord.timeCount`, the very quantity
  `untlNeg`'s cap is stated against — the same `maxTime`-lowering mechanism Phase 6's verdict turns
  on) is open mathematics, not a proof-engineering gap.
- **What is needed**: A fourth measure component paying for the three self-guarded minting rules
  and preserved across `TimeOrdering.identifyTime`. Designing and validating it is a research task
  in its own right and exceeds this plan's Phase 7 scope; it should be spawned rather than absorbed.
- **Prohibited workarounds**: Do NOT land a `MintPaysForTimeAt` that is itself false (both
  candidates above are), and do NOT use `sorry`, `def X := True`, or any vacuous placeholder. The
  refutations above are landed in-source precisely so a future reader does not re-attempt them; see
  do-not-re-attempt register entry 14.

**Tasks**:
- [ ] Define the repaired predicate, following Phase 4's verdict. Under the expected refutable
      verdict, the narrowing is on the **rule coordinate**: the second disjunct's index set must
      cover `freshTimeRules`, not merely `freshLabelRules`. Name it `MintPaysForTimeAt`, mirroring
      `UniverseClosedAt`'s naming. State disjunct 1 against Phase 5's
      `knownTimes_card_le_succ_of_unorderedSuccessor` rather than against a bare inequality.
- [ ] Prove the direction lemma. Under a **weakening** repair (the `UniverseClosedAt` case), it is
      `mintPaysForTimeAt_of_mintPaysForTime` and every theorem restated against the new predicate is
      a strengthening. Under a **strengthening** repair (the `OrdTimesKnown` case), it is
      `mintPaysForTime_of_mintPaysForTimeAt` and the docstring must say so explicitly. Establish
      which case applies and prove that lemma — do not land the predicate without it.
- [ ] Confirm the repair **leaks no new hypothesis into the terminus**: every quantity the repaired
      predicate newly constrains must already be reachable at the consuming site. Mirror
      `universeClosedAt_identify_at_trigger`'s role and land the analogous bridge lemma if one is
      needed. If a genuinely new terminus hypothesis is unavoidable, that is a blocker to escalate,
      not a cost to absorb silently.
- [ ] Docstring `MintPaysForTimeAt` with its obligation map, per coordinate, in the voice
      `UnorderedSuccessorLabelClosed`'s docstring uses: what is discharged (the time accounting, from
      Phases 3 and 5), what is carried (the σ-hit, per Phase 6's verdict), and what is assumed by
      nothing else.

**Timing**: 2 hours

**Depends on**: 4, 5, 6

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D2 continued;
  `MintPaysForTimeAt`, its direction lemma, and the bridge lemma if required.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- The direction lemma exists, is sorry-free, and its **direction** is stated in the docstring in
  words ("weaker, so every restatement is a strengthening" or the converse). A repaired predicate
  without this is not accepted.
- `MintPaysForTime` retained verbatim; every theorem currently stated against it unchanged.

---

### Phase 8: Terminus restatement and the concrete instantiation [BLOCKED]

**Goal**: Deliver the task's "done" condition: a sorry-free, axiom-free theorem establishing the
residual (repaired if Phase 4 refuted it) at a **concrete, useful instantiation**, plus the seed-level
terminus restated at the repaired shape.

**BLOCKER** (Phase 8): Depends on Phase 7, which is `[BLOCKED]`. There is no repaired predicate to
restate the termini against or to discharge at a concrete universe. Per the plan's own
Rollback/Contingency section, "a repair that trades one named residual for another is not a
discharge" — so nothing is landed here rather than landing a weaker substitute under the
deliverable's name. `MintPaysForTime` is retained verbatim and every theorem stated against it is
unchanged.

**Tasks**:
- [ ] Restate the two seed-level termini at the repaired predicate, mirroring how the 432 repair
      landed `buildTableauAt_isSome_of_budget_at`: `buildTableauAt_isSome_of_budget_at_mint` and
      `buildTableauAt_isSome_at_seed_at_mint` (or the naming the file's existing `_at` convention
      dictates). Restate **only** these two — the originals and the other consuming sites stay as
      they are.
- [ ] Discharge the repaired predicate at the concrete instantiation `U = signedUniverse C L`,
      `σ = id`, `Tmax = derivedTmax ((seedBranch phi).knownTimes.toFinset.card) U.card`, at an
      arbitrary frame class. Model the discharge on
      `timeMergeClosed_identifyTime_signedUniverse`, which is the analogous "repaired clause
      discharged at a concrete useful universe" theorem the 432 repair landed.
- [ ] If the discharge needs a closure condition on `L` (the `TimeMergeClosed` pattern), state it,
      name it, and prove that it is satisfiable at a concrete finite `L` — do **not** leave it as a
      third unproved residual. Note that the world-side analogue of such a condition is refuted
      (`freshWorldHeadroom_not_universal`, register entry 11), so verify satisfiability rather than
      assuming the time side behaves like `TimeMergeClosed`.
- [ ] Verify axiom-freedom of the delivered theorem with `lean_verify` on the fully qualified name.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: "Two seed-level termini" is a hypothesis read off the 11 `MintPaysForTime`
consuming sites in the file, of which the seed-level ones appear to be
`buildTableauAt_isSome_at_seed` and `buildTableauAt_isSome_at_seed_lengthBudget`. Confirm the set by
grepping `MintPaysForTime` in `MintBound.lean` and classifying each site as seed-level or
intermediate before restating anything. If more than two are genuinely seed-level, restate those and
record the count; do not silently expand into intermediate sites.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - section D2 continued;
  the restated termini and the concrete-instantiation discharge theorem.

**Verification**:
- Full `lake build` green.
- `lean_verify` on the delivered theorem reports **sorry-free and axiom-free**.
- The delivered theorem's statement mentions a concrete `U` (a `signedUniverse C L`, not a
  universally quantified `U`) — a universally quantified restatement is not the deliverable.
- `git diff --stat` shows `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched.

---

### Phase 9: Register entries, docstring reconciliation, and the closing gate [COMPLETED]

**Goal**: Bring the file's own narrative into agreement with what landed, and run the closing gates.
Three docstrings currently assert that `applyRule_emitted_time_mem` does not exist; after Phase 3 it
does, and leaving them is a correctness defect in the file's documentation.

**Tasks**:
- [x] Update the three in-source notes that assert the time analogue's absence:
      `MintPaysForTime`'s docstring, the section note preceding `applyRule_emitted_world_dichotomy`,
      and `UnorderedSuccessorLabelClosed`'s obligation map. Replace "there is no
      `applyRule_emitted_time_mem`" with the landed name and what it gives. These are doc comments,
      not proof terms — the byte-unchanged constraint on landed proof terms is not violated.
- [x] Add do-not-re-attempt register entries (section C9, continuing from entry 12):
      - the naive "non-`ruleMintsFreshLabel` implies no new time" reading, refuted by
        `freshTimeRules_incomparable_freshLabelRules`, with `expandOnceNoFresh`'s two-test sequence
        as the operational evidence;
      - `MintPaysForTime` as literally stated, cited to Phase 4's witness, with the repair named;
      - the time-reuse sub-question at whichever verdict Phase 6 reached, so a future reader who
        finds it attractive learns what is already known.
      Update the section header's "Twelve statements" count to match.
- [x] Update the residual roster note (the "`MintPaysForTime` — the development's one genuinely open
      mathematical obligation, unchanged" line) to reflect the new status.
- [x] Run the closing gates.

*(deviation: altered — the register grew by **four** entries rather than three, and the header count
went 12 → 16 rather than 12 → 15. The fourth is the unconditional `applyRule_emitted_time_mem`
without `OrdTimesKnown` (entry 16), which became a re-attemptable statement only because Phase 3
landed the hypothesis-carrying form; it is refuted by
`applyRule_emitted_time_mem_ordTimesKnown_needed`. The time-reuse entry (15) records a **settled
negative** rather than an open question, per Phase 6's verdict.)*

*(deviation: altered — this phase ran with Phases 7 and 8 `[BLOCKED]` rather than after them. The
docstring reconciliation could not wait: three in-source notes asserted that
`applyRule_emitted_time_mem` does not exist, and after Phase 3 that is a false statement in the
file's own documentation regardless of what happens to the repair. The register entries likewise
record what was settled, which is independent of the blocked repair.)*

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - docstring and register
  updates only; no new declarations.

**Verification**:
- Full `lake build` green from clean-ish state.
- `grep -c sorry FormalSystem/.../MintBound.lean` returns `0`.
- `grep -nE ":=\s*(True|trivial|Trivial|Unit)\s*$"` over the task's additions returns nothing.
- `git diff --stat` confirms `Saturation.lean`, `Fuel.lean`, `Tableau.lean` untouched, and confirms
  `MintBound.lean` changes are additions plus doc-comment edits only.
- No file outside `specs/**` added by this task cites a task number
  (`no-task-references-in-deliverables.md`); the register cites declaration names only, per its own
  stated convention.
- `grep -n "applyRule_emitted_time_mem"` confirms the name task 432 consumes is present and
  top-level.

---

## Testing & Validation

- [ ] `lake build` green for the whole project at task end.
- [ ] `applyRule_emitted_time_mem` and `applyRule_emitted_time_dichotomy` present at top level,
      sorry-free, axiom-free, resolvable by name from outside the file (the deliverable task 432
      consumes).
- [ ] `mem_freshTimeRules` proves the `Finset`/`Bool` agreement over all 36 constructors, so the
      census cannot silently drift from `applyRule`.
- [ ] Exactly one verdict recorded for `MintPaysForTime` (Phase 4) and exactly one for the time-reuse
      sub-question (Phase 6), each with named evidence present as a declaration.
- [ ] The delivered residual theorem is at a **concrete** universe, sorry-free and axiom-free per
      `lean_verify`.
- [ ] Any repaired predicate carries a direction lemma whose direction is stated in words.
- [ ] `Saturation.lean`, `Fuel.lean`, `Tableau.lean` byte-unchanged; all previously-landed proof
      terms in `MintBound.lean` byte-unchanged.
- [ ] Zero `sorry`, zero vacuous definitions, zero new unproved hypotheses on any terminus.
- [ ] No re-attempt of any of the 12 (now 15) do-not-re-attempt register entries.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new sections D1 (time
  coordinate accounting) and D2 (the residual's verdict and repair), plus register and docstring
  reconciliation.
- `specs/434_discharge_mintpaysfortime_residual/summaries/01_*-summary.md` — execution summary at
  task end.
- **For task 432**: `applyRule_emitted_time_mem` (Phase 3) and `applyRule_emitted_time_dichotomy`
  (Phase 5), landing at the end of waves 2 and 3 respectively — earlier than any other deliverable
  in this plan, and independent of every verdict rendered after them.

## Rollback/Contingency

Every phase is purely additive to one file, so rollback is per-phase `git revert` of that phase's
commit with no cross-file fallout. Specifically:

- **Phase 3 resists** (the 36-arm sweep will not close): take the pre-declared narrowing — exclude
  `timeLinearity` by hypothesis and let Phase 5's dichotomy re-absorb it. If the sweep resists more
  broadly than that one arm, mark the phase `[BLOCKED]`, record the residual goal list, and escalate;
  do **not** substitute a weaker statement under the same name, since task 432 will resolve that name
  and consume whatever it finds.
- **Phase 4 returns "provable"**: Phases 7-8 collapse to a direct proof at the concrete
  instantiation; Phase 6 still runs, because the σ-hit obligation is exactly what such a proof must
  discharge.
- **Phase 6 returns "open"**: Phase 7's repair carries the σ-hit structurally rather than discharging
  it, and Phase 8's deliverable is the repaired form at the concrete instantiation. That is still a
  sorry-free, axiom-free theorem and still satisfies "done"; what it is *not* is a discharge of the
  open sub-question, and the register entry must say so plainly.
- **Phase 8 cannot reach a concrete instantiation without a new residual**: this is the one outcome
  that must be escalated rather than absorbed. The whole point of the sibling repairs was that they
  leaked no new hypothesis into the terminus; a repair that trades one named residual for another is
  not a discharge. Mark `[BLOCKED]` with the specific hypothesis that could not be eliminated.
- **Any phase tempted toward `Saturation.lean` / `Fuel.lean` / `Tableau.lean`**: `private` blocks
  name resolution, not unfolding (register entry 9's second paragraph). A bound is statable and
  provable from `MintBound.lean` with the frozen files exactly as they are. Reaching for them is a
  signal the statement is wrong, not that the visibility is.
