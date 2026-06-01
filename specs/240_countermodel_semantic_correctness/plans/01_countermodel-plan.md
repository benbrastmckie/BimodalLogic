# Implementation Plan: Countermodel Semantic Correctness

- **Task**: 240 - Countermodel semantic correctness
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/240_countermodel_semantic_correctness/reports/01_countermodel-research.md
- **Artifacts**: plans/01_countermodel-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the vacuous `branchTruthLemma` (conclusion `forall sf in b, True`) in `CountermodelExtraction.lean` with a genuine truth lemma connecting saturated open branch membership to semantic truth in an extracted model. The approach defines a `SemanticCountermodel` structure capturing world states, time domain, temporal ordering, and valuation from a saturated branch, defines a recursive `branchTruth` evaluation function on this structure, and proves the truth lemma by well-founded induction on formula complexity. The plan follows the research report's two-layer strategy: first define the branch model directly (avoiding full TaskFrame/WorldHistory construction to sidestep universe level issues), then prove the truth lemma using saturation invariants.

### Research Integration

Key findings from the research report integrated into this plan:
- **Vacuous placeholder**: `branchTruthLemma` at lines 149-153 has conclusion `forall sf in b, True`, which is trivially true and provides no semantic guarantee.
- **SimpleCountermodel limitation**: Only tracks atom true/false lists; no world states, time domain, temporal ordering, or valuation for modal/temporal formulas.
- **TimeOrdering gap**: `ExpandedTableau.hasOpen` currently stores only the branch, discarding the `TimeOrdering`. This must be fixed as a prerequisite.
- **Two-layer approach**: Define `branchTruth` directly on the countermodel (Layer 1), prove correspondence with branch membership (Layer 2), defer optional TaskModel connection (Layer 3) to a future task.
- **Saturation invariants**: The truth lemma proof requires 5 categories of saturation invariants (propositional, modal S5, temporal future/past, until/since decomposition, closure absence). These must be proved as separate lemmas from `findUnexpanded b = none` and `findClosure b fc = none`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "tableau-training" topic. It is a dependency of task 164 (prove tableau correctness) and task 241 (tableau formula labeling). Proving genuine countermodel correctness is prerequisite to the claim that the decision procedure produces valid semantic countermodels for invalid formulas.

## Goals & Non-Goals

**Goals**:
- Define `SemanticCountermodel` structure with world states, time domain, temporal ordering, and valuation extracted from a saturated open branch
- Define `branchTruth` recursive evaluation function on the countermodel
- Prove the genuine truth lemma: for all `sf` in a saturated open branch, `T(phi)` implies `branchTruth` and `F(phi)` implies `not branchTruth`
- Prove saturation invariants as reusable lemmas
- Thread `TimeOrdering` through `ExpandedTableau.hasOpen`

**Non-Goals**:
- Constructing a full `TaskFrame`/`WorldHistory`/`TaskModel` from the countermodel (deferred to a future task)
- Proving blocking correctness theorems (`subformula_property`, `blocking_terminates`, `blocking_sound` -- those are separate stubs)
- Modifying the `EnrichedCountermodel` in the Automation module (that is for training data, not semantic correctness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Saturation invariants are hard to derive from `findUnexpanded b = none` | H | M | Start with the simplest invariants (atoms, bot); may need to add provenance tracking to the branch if the saturation proof is too indirect |
| Persistent formula handling (box, G, H) requires reasoning about "all known worlds/times" | M | M | The `knownWorlds`/`knownTimes` branch helpers already exist; use them directly in `branchTruth` definition |
| Until/Since induction step requires tracking which branch was taken after a branching rule | H | M | The research report identifies that consumed formulas are removed; for persistent formulas, full propagation entails the quantifier. Document clearly if any case requires sorry |
| ExpandedTableau TimeOrdering threading may break downstream consumers | M | L | The change adds a field to the `hasOpen` constructor; update all pattern matches (few call sites) |
| Universe level issues if trying to connect to full TaskModel semantics | L | L | Explicitly out of scope -- the branchTruth definition avoids the TaskModel stack entirely |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Thread TimeOrdering through ExpandedTableau [COMPLETED]

**Goal**: Modify `ExpandedTableau.hasOpen` to carry `TimeOrdering` so that countermodel extraction can access temporal ordering constraints from the saturated branch.

**Tasks**:
- [x] Add `timeOrdering : TimeOrdering` field to `ExpandedTableau.hasOpen` constructor in `Saturation.lean`
- [x] Update `expandBranchWithFuel` to return the final `TimeOrdering` alongside the branch in the `some (.inr openBr)` path *(deviation: altered — changed return type to `Option (ClosedBranch ⊕ (Branch × TimeOrdering))` instead of adding a separate field)*
- [x] Update `expandBranchesWithFuel` to thread `TimeOrdering` through the `foundOpen` case
- [x] Update `buildTableau` to propagate the `TimeOrdering` into `ExpandedTableau.hasOpen`
- [x] Fix all downstream pattern matches on `ExpandedTableau.hasOpen` (in `CountermodelExtraction.lean`, `EnrichedCountermodel.lean`, `DecisionProcedure.lean`, `ProofExtraction.lean`, and all test/eval sites)
- [x] Verify `lake build` passes with no errors

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add `TimeOrdering` to `hasOpen`, update expansion functions
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Update pattern matches
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean` - Update pattern matches
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Update pattern matches (if it references `ExpandedTableau`)

**Verification**:
- `lake build` passes
- All existing `#eval` tests in `Saturation.lean` still produce the same results

---

### Phase 2: Define SemanticCountermodel and branchTruth [COMPLETED]

**Goal**: Define the `SemanticCountermodel` structure and a recursive `branchTruth` evaluation function that interprets formulas directly on the countermodel's world/time/valuation structure.

**Tasks**:
- [x] Define `SemanticCountermodel` structure in `CountermodelExtraction.lean` with fields: `formula`, `branch`, `worlds : List WorldIndex`, `times : List TimeIndex`, `timeOrdering : TimeOrdering`, `atomValuation : WorldIndex -> TimeIndex -> Atom -> Bool`
- [x] Define `branchTruth : SemanticCountermodel -> WorldIndex -> TimeIndex -> Formula -> Prop` by recursion on formula structure:
  - `atom p`: `cm.atomValuation w t p = true`
  - `bot`: `False`
  - `imp phi psi`: `branchTruth cm w t phi -> branchTruth cm w t psi`
  - `box phi`: `forall w' in cm.worlds, branchTruth cm w' t phi`
  - `untl event guard`: `exists t' in cm.times, cm.timeOrdering orders t < t' AND branchTruth cm w t' event AND forall t'' between t and t', branchTruth cm w t'' guard`
  - `snce event guard`: mirror of until with past ordering
- [x] Define helper `isTimeOrderedBefore (ord : TimeOrdering) (t1 t2 : TimeIndex) : Bool` using transitive closure of `ord.constraints` *(deviation: altered — standalone function instead of method on SemanticCountermodel)*
- [x] Define `extractSemanticCountermodel : Formula -> Branch -> TimeOrdering -> SemanticCountermodel` that builds the countermodel from a saturated open branch by extracting `knownWorlds`, `knownTimes`, the `TimeOrdering`, and computing `atomValuation` from positive atom occurrences
- [x] Define `signedTruthInModel (cm : SemanticCountermodel) (sf : SignedFormula) : Prop` as: if `sf.sign = .pos` then `branchTruth cm sf.label.world sf.label.time sf.formula`, if `sf.sign = .neg` then `not (branchTruth cm sf.label.world sf.label.time sf.formula)`
- [x] Verify definitions compile with `lake build`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Add `SemanticCountermodel`, `branchTruth`, `extractSemanticCountermodel`, `signedTruthInModel`

**Verification**:
- `lake build` passes
- Definitions are well-founded (Lean accepts the recursive `branchTruth` definition)

---

### Phase 3: Prove Saturation Invariants [COMPLETED]

**Goal**: Prove the saturation invariant lemmas that the truth lemma proof requires. These derive properties of saturated open branches from `findUnexpanded b = none` and `findClosure b fc = none`.

**Tasks**:
- [x] Prove `sat_no_bot_pos`: if `findClosure b fc = none` then no `T(bot)` in `b` *(completed)*
- [x] Prove `sat_no_contradiction`: if `findClosure b fc = none` then no complementary pair `T(phi)` and `F(phi)` at the same label *(completed)*
- [x] Prove `sat_atom_consistent`: if open and saturated, then for any atom `p` and label `l`, not both `hasPosAt b (atom p) l` and `hasNegAt b (atom p) l` *(completed)*
- [ ] Prove `sat_imp_pos`: if `T(psi -> chi)` was in a branch that is now saturated, then the source formula was consumed and either `F(psi)` or `T(chi)` (or both) are in the branch. *(deviation: skipped -- not needed; impPos is branching so the branch already contains one alternative)*
- [x] Prove `sat_imp_neg`: if `F(psi -> chi)` is in a saturated branch, then `T(psi)` and `F(chi)` are in the branch *(deviation: altered -- proof left as sorry with documented strategy; requires unfolding rule engine internals)*
- [x] Prove `sat_box_pos`: if `T(box phi)` at `(w, t)` is in a saturated branch, then for all `w'` in `knownWorlds b`, `T(phi)` at `(w', t)` is in the branch *(deviation: altered -- sorry with documented strategy)*
- [x] Prove `sat_box_neg`: if `F(box phi)` at `(w, t)` is in a saturated branch, then there exists `w'` in `knownWorlds b` such that `F(phi)` at `(w', t)` is in the branch *(deviation: altered -- sorry with documented strategy)*
- [ ] Prove temporal saturation lemmas (G/H/F/P cases) *(deviation: skipped -- G/H/F/P are derived operators encoded as Until/Since with top guard, covered by the until/since cases)*
- [x] State until/since saturation invariants with sorry:
  - `sat_untl_pos`: stated with sorry and documented blocker (branching provenance tracking)
  - `sat_untl_neg`: stated with sorry and documented blocker (persistent rule analysis)
  - `sat_snce_pos`: stated with sorry (mirror of untl_pos)
  - `sat_snce_neg`: stated with sorry (mirror of untl_neg)
- [x] Verify `lake build` passes *(completed -- 8 sorry in CountermodelExtraction.lean, all documented)*

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Add saturation invariant lemmas (new section)

**Verification**:
- `lake build` passes
- Each lemma either has a complete proof or a clearly documented sorry with explanation of what blocks it

---

### Phase 4: Prove the Truth Lemma [IN PROGRESS]

**Goal**: State and prove the genuine `branchTruthLemma` by well-founded induction on formula complexity, using the saturation invariants from Phase 3.

**Tasks**:
- [ ] Replace the vacuous `branchTruthLemma` with the genuine statement:
  ```
  theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
      (fc : FrameClass := .Base) (hOpen : findClosure b fc = none)
      (cm : SemanticCountermodel) (hCm : cm = extractSemanticCountermodel ...) :
      forall sf in b, signedTruthInModel cm sf
  ```
- [ ] Prove the atom case using `sat_atom_consistent` and the construction of `atomValuation`
- [ ] Prove the bot case using `sat_no_bot_pos` (T(bot) cannot be in an open branch) and the fact that bot is always false in the model
- [ ] Prove the imp case:
  - For `T(psi -> chi)`: use `sat_imp_pos` to get either `F(psi)` or `T(chi)` in the branch; by IH on subformulas, `psi` is false or `chi` is true; conclude `psi -> chi` is true
  - For `F(psi -> chi)`: use `sat_imp_neg` to get `T(psi)` and `F(chi)` in the branch; by IH, `psi` is true and `chi` is false; conclude `psi -> chi` is false
- [ ] Prove the box case:
  - For `T(box phi)`: use `sat_box_pos` to get `T(phi)` at all known worlds; by IH, `phi` is true at all known worlds; since the model only contains known worlds, `box phi` is true
  - For `F(box phi)`: use `sat_box_neg` to get a witness world with `F(phi)`; by IH, `phi` is false there; conclude `box phi` is false
- [ ] Prove the untl case (or document with sorry if blocked):
  - For `T(U(event, guard))`: use saturation to find event-witness or guard+continue; by IH, the truth conditions are met
  - For `F(U(event, guard))`: use Reynolds co-decomposition saturation; for all future times, the negation conditions hold
- [ ] Prove the snce case (mirror of untl)
- [ ] Update `extractCountermodelFromTableau` to construct `SemanticCountermodel` using the new `TimeOrdering` from `ExpandedTableau.hasOpen`
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Replace `branchTruthLemma`, update `extractCountermodelFromTableau`

**Verification**:
- `lake build` passes
- The old vacuous `branchTruthLemma` is completely replaced (no `forall sf in b, True` remains)
- The new truth lemma is either sorry-free or has clearly scoped sorries on specific formula cases with documented blockers

---

### Phase 5: Integration and Verification [NOT STARTED]

**Goal**: Wire the `SemanticCountermodel` into the decision procedure integration points, update `findCountermodel` to return the richer type, and perform full verification.

**Tasks**:
- [ ] Update `CountermodelResult` to include a `SemanticCountermodel` variant alongside `SimpleCountermodel`
- [ ] Update `findCountermodel` to produce `SemanticCountermodel` when the branch has a `TimeOrdering`
- [ ] Ensure backward compatibility: `SimpleCountermodel` extraction still works (keep as a projection from `SemanticCountermodel`)
- [ ] Add documentation/docstrings explaining the semantic guarantee provided by the truth lemma
- [ ] Run full `lake build` to verify no regressions
- [ ] Check `#print axioms branchTruthLemma` to audit sorry usage
- [ ] Update module docstring in `CountermodelExtraction.lean` to reflect the new semantic correctness guarantee

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Update `CountermodelResult`, `findCountermodel`, module docstring

**Verification**:
- `lake build` passes with zero new errors
- `#print axioms branchTruthLemma` shows only expected axioms (document any remaining sorries)
- All `#eval` tests in `Saturation.lean` still pass
- The `SimpleCountermodel` interface remains available for downstream consumers

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] All existing `#eval` tests in `Saturation.lean` produce unchanged results
- [ ] `#print axioms branchTruthLemma` shows no sorryAx (or clearly documented scoped sorries)
- [ ] Pattern match exhaustiveness: no `ExpandedTableau` pattern matches broken by Phase 1 change
- [ ] `findCountermodel` still returns correct results for known valid/invalid formulas

## Artifacts & Outputs

- `specs/240_countermodel_semantic_correctness/plans/01_countermodel-plan.md` (this file)
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` (primary modified file)
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (Phase 1 TimeOrdering threading)

## Rollback/Contingency

All changes are confined to the Decidability module. If implementation fails:
- Phase 1 (TimeOrdering threading) can be reverted by restoring the original `ExpandedTableau` definition and removing the extra field
- Phases 2-5 add new definitions/theorems alongside existing code; the old `SimpleCountermodel` is preserved throughout, so reverting just removes the new additions
- If the truth lemma proof is blocked on until/since cases, those specific cases can be left as sorry stubs while the atom/bot/imp/box cases provide value. The sorry stubs are clearly more informative than the current vacuous `forall sf in b, True`
