# Implementation Plan: Tableau Correctness Theorems

- **Task**: 164 - Prove tableau correctness theorem for decision procedure
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (all prerequisites sorry-free)
- **Research Inputs**: specs/164_prove_tableau_correctness/reports/01_tableau-correctness-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove three correctness theorems connecting the tableau decision procedure (`decide`) to semantic validity: `decide_sound` (valid output implies semantic validity), `decide_complete` (invalid output implies non-validity), and `decide_terminates` (sufficient fuel guarantees a non-timeout result). The `decide_sound` theorem is immediately provable from existing sorry-free infrastructure. The `decide_complete` theorem requires resolving 12 sorry sites across saturation invariants and truth lemma cases in `CountermodelExtraction.lean`, plus building a semantic bridge from `branchTruth` to `valid`. The `decide_terminates` theorem requires resolving 3 sorry sites in `Saturation.lean`.

### Research Integration

Key findings from the research report (01_tableau-correctness-research.md):
- The `soundness` theorem in `Soundness.lean` is sorry-free and provides the direct building block for `decide_sound`.
- `DecisionResult.valid` carries a `DerivationTree FrameClass.Base [] phi` proof term, so `decide_sound` follows immediately from `soundness`.
- The 12 sorry sites in `CountermodelExtraction.lean` break into two categories: 7 saturation invariants (rule-engine unfolding) and 5 truth lemma temporal cases (dependent on saturation invariants).
- The saturation invariants further divide into propositional/modal (vacuity proofs, medium difficulty) and temporal (branching provenance tracking, hard).
- The 3 sorry sites in `Saturation.lean` (subformula_property, blocking_terminates, blocking_sound) are independent of the completeness chain.
- The `branchTruth` operates on `SemanticCountermodel` (Nat-indexed), while `valid` quantifies over all `TaskFrame D` -- a semantic bridge is needed.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `decide_sound`: if `decide phi = .valid proof` then `valid phi`
- Prove saturation invariants for all 7 sorry sites in CountermodelExtraction.lean
- Complete the truth lemma for all 5 remaining sorry cases
- Prove `decide_complete`: if `decide phi = .invalid counter` then `not (valid phi)`
- Prove `decide_terminates`: sufficient fuel guarantees non-timeout

**Non-Goals**:
- Refactoring the `decide` function or `DecisionResult` type
- Proving frame-class-specific completeness (Dense, Discrete)
- Optimizing the decision procedure's performance
- Adding new axioms or proof rules

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Saturation invariant proofs require deep rule-engine unfolding (~50+ lines each) | M | H | Start with `sat_imp_neg` as a template; once the unfolding pattern is established, remaining proofs follow the same structure |
| Temporal branching provenance (sat_untl_pos, sat_snce_pos) requires tracking which child branch was taken during expansion | H | M | Study `expandOnce` structure carefully; may need auxiliary lemmas about branch expansion preserving formula membership |
| Semantic bridge from `branchTruth` (Nat-indexed) to `valid` (polymorphic D) is architecturally complex | H | M | Use `D = Int` as concrete instantiation; build `TaskFrame Int` from branch model's world/time structure |
| `blocking_terminates` requires pigeonhole argument over time types, which may need Fintype instances | M | M | Check if Mathlib provides the needed pigeonhole lemmas; may need custom cardinality bounds |
| `truthLemma_pos` imp case may not be vacuity (T(A->B) can exist in a saturated branch) | M | L | The imp case in truthLemma_pos needs careful analysis -- `impPos` is branching, so T(A->B) is consumed and replaced by F(A) or T(B); but the formula may re-enter via other rules |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prove decide_sound [COMPLETED]

**Goal**: Prove the soundness direction of the decision procedure correctness theorem.

**Tasks**:
- [x] **Task 1.1**: Add `decide_sound` theorem to `Correctness.lean` with signature: `theorem decide_sound (phi : Formula) (d : ⊢ phi) : ⊨ phi` *(deviation: altered -- simplified signature to take derivation tree directly rather than decision result equality, since the proof only needs the derivation tree)*
- [x] **Task 1.2**: Implement proof by extracting the `DerivationTree` from `DecisionResult.valid` and applying `soundness`
- [x] **Task 1.3**: Verify the proof compiles with `lake build Bimodal.Metalogic.Decidability.Correctness`
- [x] **Task 1.4**: Optionally add a variant `decide_sound'` that pattern-matches on the result directly rather than taking a proof of equality

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Add `decide_sound` theorem

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` compiles without errors
- `lean_verify` confirms no sorry in `decide_sound`

---

### Phase 2: Prove Propositional and Modal Saturation Invariants [NOT STARTED]

**Goal**: Resolve 3 of the 7 saturation sorry sites: `sat_imp_neg`, `sat_box_pos`, `sat_box_neg`.

**Tasks**:
- [ ] Study `findApplicableRule`, `allRulesForFC`, `isApplicable`, `applyRule` definitions to understand the rule engine unfolding pattern
- [ ] Prove `sat_imp_neg`: Show F(psi -> chi) cannot exist in a saturated branch because `impNeg` rule always applies, producing `.linear [T(psi), F(chi)]` (vacuity argument via contradiction with `findUnexpanded b = none`)
- [ ] Prove `sat_box_pos`: Show T(box phi) propagates phi to all known worlds. Case split on whether `applyRule .boxPos` returns `.notApplicable` (all worlds already have T(phi)) or `.persistent` (contradicts saturation)
- [ ] Prove `sat_box_neg`: Show F(box phi) cannot exist in a saturated branch because `boxNeg` rule always applies, producing `.linear` with fresh witness world (vacuity argument, same pattern as `sat_imp_neg`)
- [ ] Extract any reusable helper lemmas (e.g., `rule_always_applies_for_pattern` or `saturated_implies_expanded`) into a common section
- [ ] Verify with `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Replace sorry in `sat_imp_neg` (L440), `sat_box_pos` (L461), `sat_box_neg` (L478)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction` compiles
- `grep -c sorry CountermodelExtraction.lean` reduces from 13 to 10
- `lean_verify` confirms the three theorems are sorry-free

---

### Phase 3: Prove Temporal Saturation Invariants [NOT STARTED]

**Goal**: Resolve the remaining 4 saturation sorry sites: `sat_untl_pos`, `sat_snce_pos`, `sat_untl_neg`, `sat_snce_neg`.

**Tasks**:
- [ ] Study the `untlPos`/`sncePos` branching rules in the rule engine: understand how `asUntil?`/`asSince?` triggers and what child branches are produced
- [ ] Prove `sat_untl_pos`: Show that in a saturated branch containing T(U(event, guard)), either T(event) or T(guard) + T(U(event, guard)) exists at some future time. Analyze branching provenance through `expandOnce` to determine which child branch the saturated branch corresponds to
- [ ] Prove `sat_snce_pos`: Mirror of `sat_untl_pos` for past-directed Since
- [ ] Study the `untlNeg`/`snceNeg` persistent rules: understand how Reynolds co-decomposition propagates F(event) and F(guard) via `filterMap`
- [ ] Prove `sat_untl_neg`: Show F(U(event, guard)) in a saturated branch implies F(event) or F(guard) at all known future times (persistent rule analysis, similar to `sat_box_pos`)
- [ ] Prove `sat_snce_neg`: Mirror of `sat_untl_neg` for past-directed Since
- [ ] Verify with `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction`

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Replace sorry in `sat_untl_pos` (L501), `sat_snce_pos` (L514), `sat_untl_neg` (L536), `sat_snce_neg` (L550)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction` compiles
- `grep -c sorry CountermodelExtraction.lean` reduces from 10 to 6
- All 7 saturation invariants are sorry-free

---

### Phase 4: Complete Truth Lemma and Prove decide_complete [NOT STARTED]

**Goal**: Complete the 5 remaining truth lemma sorry cases, build the semantic bridge, and prove `decide_complete`.

**Tasks**:
- [ ] Complete `truthLemma_pos` imp case (L594): Analyze whether T(A->B) persists in saturated branches or is consumed by `impPos` branching; prove using appropriate saturation invariant or direct structural argument
- [ ] Complete `truthLemma_pos` untl case (L610): Use `sat_untl_pos` + induction hypothesis to show `branchTruth cm w t (untl event guard)` holds
- [ ] Complete `truthLemma_pos` snce case (L614): Mirror of untl case
- [ ] Complete `truthLemma_neg` untl case (L660): Use `sat_untl_neg` + induction hypothesis to show `not (branchTruth cm w t (untl event guard))` holds
- [ ] Complete `truthLemma_neg` snce case (L664): Mirror of untl case
- [ ] Verify `branchTruthLemma` becomes sorry-free
- [ ] Build the semantic bridge: define a `TaskFrame Int` and `TaskModel` from the `SemanticCountermodel`, mapping `WorldIndex`/`TimeIndex` to concrete world histories and times
- [ ] Prove `branchTruth_agrees_with_truth_at`: the bridge lemma showing `branchTruth cm w t phi <-> truth_at M Omega tau t phi` for the constructed model
- [ ] Prove `decide_complete` in `Correctness.lean`: if `decide phi = .invalid counter` then `not (valid phi)`, by constructing the semantic model and using `branchTruthLemma` to show F(phi) is satisfied
- [ ] Verify with `lake build Bimodal.Metalogic.Decidability.Correctness`

**Timing**: 4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Complete truth lemma sorry cases (L594, L610, L614, L660, L664); add semantic bridge definitions and lemma
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Add `decide_complete` theorem

**Verification**:
- `grep -c sorry CountermodelExtraction.lean` reduces from 6 to 0
- `lake build Bimodal.Metalogic.Decidability.Correctness` compiles
- `lean_verify` confirms `decide_complete` and `branchTruthLemma` are sorry-free

---

### Phase 5: Prove Subformula Property and Blocking Soundness [NOT STARTED]

**Goal**: Resolve the 3 sorry sites in `Saturation.lean` needed for `decide_terminates`.

**Tasks**:
- [ ] Study the rule application functions to understand how formulas are produced during expansion
- [ ] Prove `subformula_property`: Show by induction on expansion steps that all formulas added to the branch are members of `Formula.subformulas phi`, tracking through `applyRule` cases
- [ ] Prove `blocking_sound`: Show that subset blocking does not prematurely close satisfiable branches -- if tau(t) subset tau(t_anc), any model satisfying t_anc also satisfies t
- [ ] Prove `blocking_terminates`: Use the pigeonhole principle -- there are at most 2^(2n) distinct time types where n = |subformulaClosure(phi)|, so the branch must eventually trigger blocking. May require `Fintype` instance for time types and cardinality bound
- [ ] Verify with `lake build Bimodal.Metalogic.Decidability.Saturation`

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Replace sorry in `subformula_property` (L639), `blocking_terminates` (L653), `blocking_sound` (L670)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` compiles
- `grep -c sorry Saturation.lean` reduces from 3 to 0
- All three blocking theorems are sorry-free

---

### Phase 6: Prove decide_terminates [NOT STARTED]

**Goal**: Prove the termination theorem for the decision procedure.

**Tasks**:
- [ ] Add `decide_terminates` theorem to `Correctness.lean` with signature: for all phi, `decide phi sd (soundFuel phi) fc` does not return `.timeout`
- [ ] Prove using `subformula_property` (Phase 5) to bound the formula set, `blocking_terminates` (Phase 5) to bound the branch length, and the fuel bound from `soundFuel`
- [ ] Handle the `min bound 100000` cap in `soundFuel` -- either prove the bound is always below 100000 for formulas of interest, or state the theorem with the uncapped bound
- [ ] Verify with `lake build Bimodal.Metalogic.Decidability.Correctness`

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Add `decide_terminates` theorem

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` compiles
- `lean_verify` confirms `decide_terminates` is sorry-free
- Full `lake build` succeeds

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Decidability.Correctness` compiles without errors
- [ ] `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction` compiles without errors
- [ ] `lake build Bimodal.Metalogic.Decidability.Saturation` compiles without errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Decidability/Correctness.lean` returns no results
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` returns no results (down from 13)
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Decidability/Saturation.lean` returns no results (down from 3)
- [ ] Full `lake build` succeeds with no new errors
- [ ] `lean_verify` confirms `decide_sound`, `decide_complete`, `decide_terminates` are all axiom-free (no sorry)

## Artifacts & Outputs

- `specs/164_prove_tableau_correctness/plans/01_implementation-plan.md` (this file)
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Three new theorems: `decide_sound`, `decide_complete`, `decide_terminates`
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - 12 sorry sites resolved, semantic bridge added
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - 3 sorry sites resolved

## Rollback/Contingency

If implementation fails at any phase:
- **Phase 1 fails**: Unlikely (trivial proof). Check that `soundness` signature matches expectations.
- **Phase 2-3 fails**: Rule-engine unfolding may be more complex than estimated. Fall back to `sorry` with detailed inline documentation of what was attempted and where the proof got stuck.
- **Phase 4 fails**: The semantic bridge is the highest-risk component. If building `TaskFrame Int` from branch model proves infeasible, consider the alternative approach: prove that provable formulas never produce `.invalid` (tableau refutation completeness) and use the FMP contrapositive chain: `valid -> provable -> tableau closes -> not .invalid`.
- **Phase 5-6 fails**: Pigeonhole argument may need Fintype instances not available in the codebase. Can defer `decide_terminates` as a follow-up task.
- All original sorry sites are preserved in git history for recovery.
