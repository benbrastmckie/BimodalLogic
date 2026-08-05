# Implementation Plan: Task #428

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: None blocking (tasks 426 and 412 are sequenced *behind* this one in state.json; Fuel.lean is unshared for the duration of this task)
- **Research Inputs**: specs/428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md
- **Artifacts**: plans/01_budget-totality-engine-repair.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The originally-specified target theorem is refuted by machine-checked counterexample and must not
be attempted in that shape. This plan implements the user-approved retarget: repair the engine's
arm-settling defect (`resolveOpenArm` tests saturation with the *literal* `findUnexpanded` instead
of the engine's *real* `findUnexpandedUnblocked`), land the already-proved
`saturateBlocked_isSome` asset, add a budget-parameterised entry point **alongside** the frozen
`buildTableau`, discharge the `NoSplit` branching residual against a split-depth-aware fuel figure,
close the world dimension, and land the totality theorem against the repaired engine. Definition of
done: `buildTableauAt_isSome_of_budget` lands sorry-free with no `NoSplit` hypothesis, `lake build`
is green repo-wide, and the world dimension is supplied rather than assumed.

### Research Integration

Five findings from `reports/01_budget-totality-refuted-and-repair.md` are load-bearing here and are
**not** re-derived by any phase:

- **F1 (refutation, settled)**: `buildTableauAt phi (soundFuel' phi) fc maxBranches` returning
  `isSome` under only a `maxBranches` hypothesis is FALSE. `phi = F(G p)` returns `none` at
  `fuel = soundFuel' phi = 229376` and `maxBranches = 10^12`. Cause is `resolveOpenArm`
  (Saturation.lean:563) inside `expandBranchWithFuel`'s split folds (:676, :701) — a fourth `none`
  source neither the task description nor the archived deadlock report enumerates. It is
  independent of both fuel and budget. **Do not re-litigate; do not re-attempt the refuted shape.**
- **F2 (the repair)**: swapping to `findUnexpandedUnblocked` at `resolveOpenArm`'s two decision
  points converts the failures to clean open verdicts and leaves already-succeeding formulas
  unchanged. It carries a soundness obligation on what an open certificate means. Phase 3 discharges
  that obligation by *adding* a weaker, explicitly-named certificate rather than silently weakening
  the existing one.
- **F3 (asset)**: `saturateBlocked_isSome` is proved sorry-free and preserved verbatim at
  `assets/saturateBlocked_isSome.lean.txt`. Phase 1 lifts it; it is never re-proved.
- **F4 (budget is per-path)**: `branchesUsed'` is bound once *before* each split fold, so siblings do
  not accumulate each other's usage; the invariant `branchesUsed + beta * fuel <= maxBranches` is
  linear, not exponential. `splitBudget_preserved`, `extendBudget_preserved` and
  `budget_le_of_betaBudget` are **already landed** in Fuel.lean and are consumed, not re-proved.
- **F5/F6 (what is actually left)**: the world dimension is largely supplied (`worldFuel'`,
  `chain_le_worldFuel'` are proved); the residual is discharging `WorldWitness`. The genuinely hard
  quantitative content of removing `NoSplit` is *fuel decay at splits*
  (`allocateFuelProportionally` hands each arm a proportional share, not the parent's fuel), not
  the two extra match arms.

### Prior Plan Reference

No prior plan for this task. Effort calibration is taken from the research report's own measured
figures (the `saturateBlocked_isSome` asset is ~90 lines including two fold helpers) and from the
shape of the already-landed Fuel.lean section 4.3d, which is the closest in-repo analogue to
Phases 4-6.

### Roadmap Alignment

No `specs/ROADMAP.md` present; no roadmap phases added.

## Goals & Non-Goals

**Goals**:
- Land `saturateBlocked_isSome` from the preserved asset, closing two provably-dead `none` arms.
- Repair `resolveOpenArm` to use the engine's real saturation test at both decision points.
- Add a budget-parameterised entry point `buildTableauAt` **alongside** `buildTableau`, with an
  explicitly-named blocking-aware open certificate and a proved upgrade bridge to the existing
  `ExpandedTableau.hasOpen`.
- Remove the `NoSplit` hypothesis from engine totality by supplying the split-arm fuel accounting
  it currently hides.
- Close the world dimension by discharging the label-count side condition that `worldFuel'`
  consumes.
- Land `buildTableauAt_isSome_of_budget` sorry-free with a caller-dischargeable budget hypothesis.

**Non-Goals**:
- **Never** edit `buildTableau`'s `maxBranches := 50000` default. It is a deliberate runtime guard;
  every new capability is an addition.
- **Never** re-attempt `buildTableau_isSome` or the task's originally-specified
  `buildTableau_isSome_of_budget` shape. Both are on the do-not-re-attempt register.
- **Never** weaken the existing `ExpandedTableau.hasOpen` proof field
  (`findUnexpanded ... = none`). Downstream truth-lemma and countermodel-extraction consumers read
  it; this plan adds a second, weaker, differently-named certificate instead.
- Do not edit `CancellableExpansion.lean`, `Tableau.lean`, or any Bridge/TruthLemma file — they are
  outside this task's declared `file_scope`. Mirror drift introduced by Phase 2 is *recorded*, not
  silently repaired (see Phase 2).
- Do not edit `allocateFuelProportionally` or `estimateBranchDifficulty`. The proportional policy
  stays; the proof accommodates it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 2's behavior change flips verdicts in `Tests/BimodalTest/TableauConformance.lean` or the probe files | H | M | Phase 2 is `full` tier: run the whole test suite, not just Saturation. Any flipped verdict is a finding to record in the summary with the formula named, not a failure to paper over. Research measured `U(p,q)` unchanged and only the `RESOLVE`-failing class changing. |
| `resolveOpenArmCancellable` (CancellableExpansion.lean) drifts out of sync — the file is out of `file_scope` | M | H (certain) | Phase 2 records the drift explicitly in the phase's completion notes and the implementation summary, naming the two call sites. It is a declared, reported out-of-scope divergence, never a silent one. |
| Fuel decay at splits (F6) makes the `NoSplit`-free induction genuinely hard: an arm receives ~`fuel/totalDifficulty`, so the parent's progress measure is not inherited | H | H | Phases 4-6 attack it in the only order that works: first the two quantitative lemmas (split growth, allocation lower bound), then fold preservation, then the main induction. Phase 6 carries an explicit escalation clause instead of a silent reintroduction of `NoSplit`. |
| `WorldWitness` discharge is a 36-case induction over `applyRule` (Fuel.lean's own docstring says so) | H | M | Phase 7 is scoped to the *engine seed run only* (`s = 1`, singleton seed), not the general invariant, and carries a named fallback route. |
| Split arity `<= 3` is a census, not a theorem — a future rule could break it | M | L | Do not bake in the literal `3`. Carry `beta` as a hypothesis exactly as the already-landed `splitBudget_preserved` does. Phase 4 proves the arity lemma if it closes cheaply; otherwise `beta` stays a parameter and nothing downstream changes. |
| A phase's goal turns out to require an edit outside `file_scope` | M | M | Mark the phase `[BLOCKED]` and escalate per `plan-compliance.md`. Do not silently widen scope; do not substitute a different decomposition. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 5 | 1, 4 |
| 3 | 3, 6 | 2, 5 |
| 4 | 7 | 6 |
| 5 | 8 | 3, 7 |

Phases within the same wave can execute in parallel. The two tracks are file-disjoint by
construction: Phases 1-3 touch `Saturation.lean` only, Phases 4-7 touch `Fuel.lean` only. Phase 8
consumes both.

---

### Phase 1: Land `saturateBlocked_isSome` from the preserved asset [COMPLETED]

**Goal**: Close two provably-dead `none` arms by lifting the already-proved, sorry-free asset into
`Saturation.lean`, unchanged except for namespace placement.

**Tasks**:
- [x] Read `specs/428_engine_totality_at_a_quantified_branch_budget/assets/saturateBlocked_isSome.lean.txt` in full.
- [x] Insert `split_fold_isSome`, `splitOrdered_fold_isSome`, and `saturateBlocked_isSome` into
      `Saturation.lean` immediately after `saturateBlocked`, replacing the deferral note at the
      `-- Note: saturateBlocked correctness theorems ... are deferred` block. Strip the asset's
      `import`/`namespace`/`end` wrapper; the body is already inside
      `FormalSystem.Metalogic.Decidability`.
- [x] Update the surviving deferral note so it names only the still-deferred
      `saturateBlocked_sound`, not `saturateBlocked_isSome`.
- [x] Add two corollaries recording what the theorem closes:
      `resolveOpenArm`'s `| none => none  -- Undecided` arm at the `saturateBlocked` match is
      unreachable, and `buildTableau`'s `| none => none  -- Should not happen` last arm is
      unreachable. State each as an explicit lemma rather than a comment.
- [x] Confirm axiom cleanliness with `lean_verify` on the fully-qualified
      `FormalSystem.Metalogic.Decidability.saturateBlocked_isSome`; expect exactly
      `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The asset is asserted to be ~90 lines across exactly three declarations
(two private fold helpers plus the theorem) and to require no modification beyond namespace
placement. Confirm at implementation time by diffing what is inserted against the asset file — any
edit to a tactic block means the hypothesis was wrong and must be reported in the summary.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Saturation.lean` - insert the three declarations after
  `saturateBlocked`; narrow the deferral note; add two dead-arm corollaries.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Saturation` green.
- `grep -c sorry` on the file still reports 0.
- `lean_verify` reports only the three standard axioms.

---

### Phase 2: Blocking-aware `resolveOpenArm` [NOT STARTED]

**Goal**: Swap the *literal* saturation test for the engine's *real* one at `resolveOpenArm`'s two
decision points, converting the refuting class from `none` to clean open verdicts, and prove the
existing invariant survives.

**Tasks**:
- [ ] Replace `findUnexpanded ob (timeOrd := ord) (fc := fc)` with
      `findUnexpandedUnblocked ob ord fc` at `resolveOpenArm`'s first decision point
      (`Saturation.lean:549`).
- [ ] Replace `findUnexpanded satBr (timeOrd := satOrd) (fc := fc)` with
      `findUnexpandedUnblocked satBr satOrd fc` at the second decision point (`:561`).
- [ ] Decide and record the tracker argument explicitly at both sites rather than relying on
      `findUnexpandedUnblocked`'s `EventualityTracker.empty` default. The blocked-time set is
      tracker-dependent, and `resolveOpenArm` is called from a fold that has a live tracker in
      scope. If the live tracker is not threadable without changing `resolveOpenArm`'s signature,
      use the default and state in the docstring exactly which blocked set the certificate is
      relative to.
- [ ] Rewrite `resolveOpenArm`'s docstring and the preceding `/-! ## Resolving an Open Sub-Branch
      Inside a Split -/` section: the `some (.inr r)` bullet currently claims "genuinely open **and
      saturated** (`findUnexpanded = none`)" — that claim is now false and must state the
      blocking-aware notion instead, with a forward reference to Phase 3's certificate type.
- [ ] Re-prove `resolveOpenArm_inr`. Its statement is unchanged (it is about `findClosure`, not
      about saturation), but the `repeat' split at h` structure walks the rewritten match tree.
- [ ] Add `#guard_msgs`/`#eval` probes in a `section` reproducing the research's measured rows:
      `F(G p)` and `¬G(F p)` now settle (previously `none`), and `U(p,q)` is unchanged. These are
      evidence rows, not decoration — they are what makes the repair checkable by running rather
      than by reading.
- [ ] Record the `resolveOpenArmCancellable` mirror drift: add a comment at `resolveOpenArm` naming
      `CancellableExpansion.lean`'s `resolveOpenArmCancellable` and its two call sites as now
      out of sync, and state that the file is outside this task's `file_scope`. Report the same in
      the implementation summary.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Exactly two decision points inside `resolveOpenArm` use `findUnexpanded`
(currently at `Saturation.lean:549` and `:561`), and no other `resolveOpenArm` internal does.
Confirm at implementation time by grepping `findUnexpanded` within the `resolveOpenArm` body before
editing; a third site means the repair is wider than planned and must be reported. Do **not** extend
the swap to `buildTableau:955`/`:963` in this phase — those sites feed the dependently-typed
`ExpandedTableau.hasOpen` constructor and are Phase 3's business.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Saturation.lean` - `resolveOpenArm` body, its docstring, the
  preceding section prose, `resolveOpenArm_inr`'s proof, plus a new probe section.

**Verification**:
- `lake build` (full repo) green — this is a behavior change, so the module-scoped build is not
  sufficient.
- The full test suite runs; any conformance-test verdict that flips is recorded by formula name in
  the phase notes.
- The new `#guard_msgs` probes pass, showing `F(G p)` and `¬G(F p)` settling.

---

### Phase 3: Budget-parameterised entry point and its certificate [NOT STARTED]

**Goal**: Add `buildTableauAt` alongside the frozen `buildTableau`, with a blocking-aware open
certificate that is a *named addition* rather than a weakening of `ExpandedTableau.hasOpen`, plus
the proved bridge relating the two.

**Tasks**:
- [ ] Add a certificate type in `Saturation.lean` carrying the blocking-aware saturation proof —
      e.g. `BudgetedTableau` with an `allClosed` arm and a `hasOpen` arm whose proof field is
      `findUnexpandedUnblockedWith openBranch ord fc (blockedTimes openBranch ord fc tracker) = none`,
      with the tracker carried as a field so the certificate says which blocked set it is relative
      to. Document in its docstring exactly how it is weaker than `ExpandedTableau.hasOpen` and why
      the weaker notion is the honest one for a blocking engine.
- [ ] Add `def buildTableauAt (phi : Formula) (fuel : Nat) (fc : FrameClass) (maxBranches : Nat) :
      Option BudgetedTableau`, mirroring `buildTableau` arm for arm but threading `maxBranches`
      into `expandBranchWithFuel` and using the blocking-aware test at both top-level decision
      points.
- [ ] Prove the **upgrade bridge**: a `BudgetedTableau` `hasOpen` certificate plus the strong
      hypothesis `findUnexpanded openBranch ... = none` yields an `ExpandedTableau.hasOpen`. This
      is the soundness discharge — it shows nothing downstream is weakened, because a consumer that
      needs the strong certificate can still obtain it only under the strong condition.
- [ ] Prove the **pinning lemma** relating the new entry point to the frozen one: at the engine
      default budget, `buildTableauAt phi fuel fc 50000` reports `allClosed` exactly when
      `buildTableau phi fuel fc` does. This is what keeps the existing verified corpus honest about
      the new definition. If a clean `iff` does not close, land the implication that matters
      (`buildTableauAt` closed implies `buildTableau` closed) and state the converse as an explicit
      open question in the docstring — do not assert an unproved `iff`.
- [ ] Prove `buildTableauAt_hasOpen_findClosure_none`: whenever `buildTableauAt` reports open, the
      reported branch has no closure reason — the `resolveOpenArm_inr` analogue at the top level.
- [ ] Add `#eval` probes showing `buildTableauAt` settling `F(G p)` at a quantified budget where the
      research measured `buildTableau` returning `none`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Saturation.lean` - new certificate type, `buildTableauAt`,
  upgrade bridge, pinning lemma, top-level closure-freedom lemma, probes. All additive:
  `ExpandedTableau`, `buildTableau` and every existing declaration are untouched.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Saturation` green, then `lake build` to confirm no
  downstream elaboration was disturbed by the new inductive.
- No existing declaration in the file appears in the diff except by addition.
- Probes show `buildTableauAt` settling the previously-refuting formula.

---

### Phase 4: Split-arm quantitative prerequisites [NOT STARTED]

**Goal**: Prove the two facts about splits that the `NoSplit`-free induction needs and that
Fuel.lean currently only *documents*: sub-branches strictly grow, and each arm's fuel allocation has
a usable lower bound.

**Tasks**:
- [ ] Prove a split-growth lemma: when `(expandOnceUnblocked b ord fc tr).1 = .split bs`, every
      `nb ∈ bs` satisfies `b.toFinset.card < nb.toFinset.card` — the `.split` analogue of the
      already-landed `expandOnceUnblocked_card_lt`. Prove the `.splitOrdered` twin. This is what
      bounds split depth along any root-to-leaf path by the universe cardinality.
- [ ] Prove `allocateFuelProportionally_ge`: if `totalDifficulty * m <= fuel + 1` and `m <= fuel`,
      then every element of `allocateFuelProportionally (fuel + 1) branches` is at least `m`.
      Consume the already-landed `allocateFuelProportionally_pos` for the `max 1` floor.
- [ ] Prove a bound on `totalDifficulty` in terms of branch size and arity, so that the hypothesis
      of the previous lemma is dischargeable from `U.card` and `beta` rather than from an
      unbounded quantity. `estimateBranchDifficulty` is `1 + 3*tempCount + 2*modCount + len/4`, so
      it is bounded by a linear function of branch length.
- [ ] Attempt `expandOnceUnblocked_split_arity_le` (`bs.length <= 3`) and its `splitOrdered` twin.
      If the case analysis over `applyRule` does not close inside this phase's budget, **stop and
      leave `beta` a hypothesis** — the already-landed `splitBudget_preserved` carries `beta`
      generically and nothing downstream requires the literal. Record the outcome either way.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The split-arity claim `bs.length <= 3` is asserted on the basis of a census —
six `.branching` sites in `Tableau.lean` returning two-element literals plus `orderTrichotomy`'s
three-element list. A census is not a theorem. Confirm at implementation time by attempting the
lemma; if it does not close, the arity bound stays a carried hypothesis `beta` and the census
remains documentation, not a proved fact. Do not bake in the literal `3` anywhere.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - new lemmas in the section
  4.3d region, alongside the existing `allocateFuelProportionally_pos` / `splitBudget_preserved`
  cluster.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- The existing `SplitFuelProbes` `#guard_msgs` rows still pass unchanged (they pin the allocation's
  actual behavior and must not drift).

---

### Phase 5: Split-fold preservation helpers [NOT STARTED]

**Goal**: Prove that `expandBranchWithFuel`'s two split folds preserve `isSome`, given that each arm
does — the structural half of removing `NoSplit`, separated from the quantitative half.

**Tasks**:
- [ ] State and prove a fold-preservation lemma for the `.split` fold: given a starting accumulator
      that is `isSome` and a hypothesis that each arm's `expandBranchWithFuel` call is `isSome`,
      the fold's result is `isSome`. Model the shape on the asset's `split_fold_isSome`, which is
      the same argument for `saturateBlocked`.
- [ ] Prove the `.splitOrdered` twin, which additionally carries each arm's own `TimeOrdering`.
- [ ] Both folds pass through `resolveOpenArm` on an arm reported open. Discharge that step using
      Phase 1's `saturateBlocked_isSome` and Phase 2's repaired body: state explicitly which
      `resolveOpenArm` outcomes are reachable and prove the `none` outcome does not defeat the fold
      under the phase's hypotheses. If `resolveOpenArm = none` remains genuinely reachable, that is
      a finding — carry it as a named hypothesis on the arm and report it, rather than assuming it
      away.
- [ ] Keep both lemmas stated over an abstract arm hypothesis so Phase 6 can supply the
      quantitative content without restating the fold reasoning.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - two fold-preservation
  lemmas.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- Each lemma is stated over an abstract hypothesis, verifiable by reading the statement: no
  `worldFuel'`, `soundFuel'`, or `NoSplit` appears in either.

---

### Phase 6: `NoSplit`-free totality of `expandBranchWithFuel` [NOT STARTED]

**Goal**: Land the budget-parameterised totality of `expandBranchWithFuel` with the `NoSplit`
hypothesis removed, using a fuel figure that accounts for split decay.

**Tasks**:
- [ ] Define the split-aware fuel figure. It must carry the multiplicative factor F6 identifies:
      an arm receives a proportional share, so a run of split-depth `d` needs a figure scaling like
      `(bound on totalDifficulty) ^ d` times the unsplit figure, with `d` bounded by Phase 4's
      split-growth lemma. Name it distinctly; do not overload `soundFuel'` or `worldFuel'`, both of
      which are frozen.
- [ ] State `expandBranchWithFuel_isSome_of_budget`: same shape as the landed
      `expandBranchWithFuel_isSome_of_noSplit` but with `hP : NoSplit P fc` **deleted** and the fuel
      hypothesis strengthened to the split-aware figure. Keep the budget hypothesis in the
      `beta`-linear form the landed `splitBudget_preserved` / `budget_le_of_betaBudget` supply.
- [ ] Prove it by induction on fuel: the `saturated` and `extended` arms carry over from the landed
      proof; the two split arms now discharge via Phase 5's fold lemmas plus Phase 4's allocation
      lower bound, which is what re-establishes the arms' progress measure that the landed proof
      could not inherit.
- [ ] Add a non-vacuity witness in the style of the existing `noSplit_nil` / `expandBranchWithFuel_nil_isSome`
      block, but at a branch that actually splits — a theorem that only applies to unbranching runs
      would have removed `NoSplit` in name only.
- [ ] Leave the landed `expandBranchWithFuel_isSome_of_noSplit` and
      `expandBranchWithFuel_isSome_at_worldFuel'` in place. They are consumed elsewhere and this is
      an addition, not a replacement.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the split arms close with no hypothesis beyond the
split-aware fuel figure and the `beta`-linear budget. Confirm by checking the landed theorem's
statement for residual hypotheses at phase end. **Escalation clause**: if the induction cannot be
closed within the phase, mark the phase `[BLOCKED]` and report the exact goal state reached. Do
**not** reintroduce `NoSplit`, do not substitute a different decomposition, and do not weaken the
statement to an unbranching special case — per `plan-compliance.md`, a would-be deviation on a
`.lean` file is escalated, not silently annotated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - split-aware fuel figure,
  the `NoSplit`-free totality theorem, a branching non-vacuity witness.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep` confirms `NoSplit` does not appear in the new theorem's statement.
- The non-vacuity witness is at a genuinely branching branch, checkable by reading it.

---

### Phase 7: Close the world dimension [NOT STARTED]

**Goal**: Discharge the label-count side condition that `worldFuel'` consumes, for the engine's own
seed run — turning the `hL`/`hww` hypotheses from assumptions into supplied facts.

**Tasks**:
- [ ] Read `chain_le_worldFuel'` and `worldFinset_card_le` and confirm the exact shape of what must
      be supplied: `chain_le_worldFuel'` carries `hww : WorldWitness C S (run n)` and its docstring
      states it is an invariant, **not discharged there**.
- [ ] Discharge `WorldWitness` along engine runs for the seed configuration `buildTableauAt` uses
      (`initialBranch = [SignedFormula.neg phi Label.initial]`, so `S.card = 1`). Scope this to the
      seed run, not to the general invariant.
- [ ] Derive `hL : L.card <= (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)` at `s = 1` from
      the discharged witness via `worldFinset_card_le`, in the exact form
      `expandBranchWithFuel_isSome_at_worldFuel'` and Phase 6's theorem consume.
- [ ] **Fallback route, to be taken only if the induction over `applyRule` does not close**: prove
      the narrower statement that the *world* component of the label set along a seed run is bounded
      by the run's fresh-world-minting steps, and state precisely which residual remains. Record the
      residual as a named hypothesis in the terminus statement rather than hiding it, and report it
      in the summary. "Its absence is proved harmless" is an acceptable outcome per the task's DONE
      WHEN only if that harmlessness is itself proved, not asserted.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: The `WorldWitness` discharge is asserted by Fuel.lean's own docstring to be a
36-case induction over `applyRule`. Confirm the case count at implementation time by enumerating
`applyRule`'s arms before starting; a materially different count changes this phase's sizing and
must be reported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - `WorldWitness` discharge for
  the seed run, plus the `hL` derivation in consumable form.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- The resulting lemma's statement contains no undischarged `WorldWitness` hypothesis, or, on the
  fallback route, contains exactly one explicitly named and documented residual.

---

### Phase 8: The terminus — `buildTableauAt_isSome_of_budget` [NOT STARTED]

**Goal**: Land the task's target theorem against the repaired engine, sorry-free and with no
`NoSplit` hypothesis, and close out the register and the final gate.

**Tasks**:
- [ ] State and prove `buildTableauAt_isSome_of_budget`: for `phi`, `fc`, and a quantified
      `maxBranches` satisfying the `beta`-linear budget condition at the split-aware fuel figure,
      `(buildTableauAt phi <fuel figure> fc maxBranches).isSome = true`.
- [ ] Discharge the top-level arms: the `expandBranchWithFuel` call via Phase 6, the
      `saturateBlocked` call via Phase 1, and the two saturation tests via Phase 3's blocking-aware
      certificate. The arm that made the original `buildTableau` non-total (`| some _ => none` after
      the post-blocking pass) is exactly what Phase 3's certificate change eliminates; verify that
      in the proof rather than assuming it.
- [ ] State the budget side condition in a form a caller can actually discharge (the task's
      sub-obligation 3): supply a corollary at the engine's own seed with `maxBranches` given as an
      explicit closed-form expression in `phi`, so a caller reads off a number rather than a proof
      obligation.
- [ ] Append to the do-not-re-attempt register the refuted shape and its counterexample, citing the
      research report's reproduction harness. Place it as a docstring/section comment adjacent to
      the new theorem so a future reader meets it where they would otherwise re-attempt it.
- [ ] Full-repo final gate: `lake build` green, zero `sorry` in both modified files, `lean_verify`
      on the terminus theorem reporting only the three standard axioms.
- [ ] Record for task 412 (which consumes this theorem in place of the refuted
      `buildTableau_isSome`): the replacement is against `buildTableauAt`/`BudgetedTableau`, not
      `buildTableau`/`ExpandedTableau`, and carries a quantified budget hypothesis. Note this in the
      implementation summary so 412 is not planned against the wrong signature.

**Timing**: 1.5 hours

**Depends on**: 3, 7

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - terminus theorem,
  caller-facing corollary, register addition.

**Verification**:
- `lake build` (full repo) green.
- `grep -c sorry` reports 0 in both `Saturation.lean` and `Fuel.lean`.
- `lean_verify` on the fully-qualified terminus theorem reports only
  `[propext, Classical.choice, Quot.sound]`.
- The theorem's statement contains no `NoSplit` hypothesis.

---

## Testing & Validation

- [ ] `lake build` green repo-wide at Phase 2 end and Phase 8 end.
- [ ] Zero `sorry` in `FormalSystem/Metalogic/Decidability/Saturation.lean` and
      `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` (both are at 0 today; this
      is a preservation check, not an improvement target).
- [ ] `saturateBlocked_isSome` and `buildTableauAt_isSome_of_budget` each verify with only
      `[propext, Classical.choice, Quot.sound]`.
- [ ] New `#guard_msgs`/`#eval` probes pass: `F(G p)` and `¬G(F p)` settle under the repaired
      `resolveOpenArm`; `U(p,q)` is unchanged; `buildTableauAt` settles `F(G p)` at a quantified
      budget.
- [ ] The existing `SplitFuelProbes` `#guard_msgs` rows in Fuel.lean still pass unchanged.
- [ ] The full test suite runs after Phase 2; any flipped conformance verdict is named and recorded.
- [ ] `buildTableau`'s signature, its `maxBranches := 50000` default, and `ExpandedTableau.hasOpen`'s
      proof field are byte-identical to their pre-task form — verifiable by `git diff` on those
      declarations.

## Artifacts & Outputs

- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/01_budget-totality-engine-repair.md` (this file)
- `specs/428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md`
- `FormalSystem/Metalogic/Decidability/Saturation.lean` — `saturateBlocked_isSome` + helpers, dead-arm
  corollaries, repaired `resolveOpenArm`, `BudgetedTableau`, `buildTableauAt`, upgrade bridge,
  pinning lemma, probes.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — split-growth and allocation
  lower-bound lemmas, fold-preservation helpers, split-aware fuel figure, `NoSplit`-free
  `expandBranchWithFuel_isSome_of_budget`, world-dimension discharge,
  `buildTableauAt_isSome_of_budget`, register addition.

## Rollback/Contingency

- Every phase except Phase 2 is **purely additive**: reverting its commit restores the prior file
  state with no downstream effect, because no existing declaration is edited.
- Phase 2 is the only behavior-changing phase and is committed as a single `atomic-batch`. Reverting
  that one commit restores the engine's current verdicts exactly; Phases 3-8 then become
  unprovable-as-stated but nothing else breaks, because `buildTableau`, `ExpandedTableau`, and every
  downstream consumer were never touched.
- If Phase 6 blocks, Phases 1-5 stand on their own as landed value (a proved totality lemma, the
  repaired arm-settling, and the budget entry point) and the task is marked `[PARTIAL]` with the
  goal state recorded. Do not reintroduce `NoSplit` to manufacture a green terminus.
- If Phase 7 blocks, take the documented fallback route and carry one explicitly named residual into
  the terminus statement, rather than asserting an undischarged `WorldWitness`.
