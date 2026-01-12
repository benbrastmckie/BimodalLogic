# Implementation Plan: Task #445

- **Task**: 445 - Maximal Consistent Set Properties
- **Status**: [NOT STARTED]
- **Effort**: 10-12 hours
- **Priority**: Medium
- **Dependencies**: Task 444 (Formula Countability and Set-List Bridge) - Complete
- **Research Inputs**: `.claude/specs/445_maximal_consistent_set_properties/reports/research-001.md`
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Phase 2 of the completeness proofs for TM bimodal logic. This task implements the key properties of maximal consistent sets (MCS) that are essential for the truth lemma and canonical model construction. The two core axiom stubs to prove are `maximal_consistent_closed` and `maximal_negation_complete`, plus additional saturation properties for logical connectives and modal/temporal operators. All proofs build on the deduction theorem (complete in DeductionTheorem.lean) and the set-based infrastructure from Task 444.

### Research Integration

Key findings from research-001.md:
1. Axiom stubs use list-based `MaximalConsistent`, but canonical model uses set-based `SetMaximalConsistent`
2. Proof strategies follow standard contrapositive arguments using deduction theorem
3. Dependency ordering: Tier 1 (closure) -> Tier 2 (negation, implication) -> Tier 3 (boolean) -> Tier 4-5 (saturation, depends on later phases)
4. Modal/temporal saturation lemmas depend on canonical frame construction (Phase 4) and canonical history (Phase 5)

## Goals & Non-Goals

**Goals**:
- Convert `maximal_consistent_closed` axiom stub to theorem
- Convert `maximal_negation_complete` axiom stub to theorem
- Add and prove implication property for MCS
- Add and prove conjunction/disjunction properties for MCS
- Add basic modal closure lemma (box implies formula)
- State modal/temporal saturation lemmas with partial proofs

**Non-Goals**:
- Full modal saturation proof (requires canonical frame from Task 447)
- Full temporal saturation proof (requires canonical history from Task 450)
- Set vs list reconciliation for all cases (bridge lemmas sufficient)
- Performance optimization of proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deduction theorem integration complex | Medium | Medium | Start with simple cases, factor out helper lemmas |
| Set/list definition mismatch | Medium | High | Work primarily with set-based definitions, add bridge lemmas |
| Missing axiom derivations for EFQ | Low | Medium | Derive EFQ from existing axiom schemas if needed |
| Long proof scripts | Low | Low | Factor into small well-named helper lemmas |
| Modal saturation depends on later phases | Low | Certain | State lemmas with `sorry` for dependent parts |

## Implementation Phases

### Phase 1: Foundation - Helper Lemmas and EFQ [NOT STARTED]

**Goal**: Establish foundational helper lemmas needed for MCS property proofs, including ex falso quodlibet derivation.

**Tasks**:
- [ ] Add helper lemma: `inconsistent_derives_bot` - Inconsistent context derives bottom
- [ ] Add helper lemma: `derives_neg_from_inconsistent_extension` - If `phi :: G` inconsistent, then `G |- neg phi`
- [ ] Add helper lemma: `derives_bot_from_phi_neg_phi` - From `G |- phi` and `G |- neg phi`, derive `G |- bot`
- [ ] Verify EFQ derivation exists or add if needed
- [ ] Add bridge lemma: `set_mcs_implies_list_consistent` for finite subsets

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add helper lemmas section

**Verification**:
- All helper lemmas compile without `sorry`
- `lean_diagnostic_messages` shows no errors
- `lake build Bimodal.Metalogic.Completeness` succeeds

---

### Phase 2: Core Closure - maximal_consistent_closed [NOT STARTED]

**Goal**: Convert the `maximal_consistent_closed` axiom stub to a proven theorem.

**Tasks**:
- [ ] Understand exact signature: `MaximalConsistent G -> DerivationTree G phi -> phi in G`
- [ ] Implement proof by contrapositive:
  - Assume `MaximalConsistent G` and `phi notin G`
  - By maximality definition: `not Consistent (phi :: G)`
  - So there exists derivation `(phi :: G) |- bot`
  - By deduction theorem: `G |- phi -> bot` (i.e., `G |- neg phi`)
  - Given `G |- phi`, combine with `G |- neg phi` to get `G |- bot`
  - Contradiction with `Consistent G`
- [ ] Replace `axiom` with `theorem` declaration
- [ ] Verify proof compiles

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 423-424

**Verification**:
- `maximal_consistent_closed` is a theorem (not axiom)
- `lean_hover_info` confirms it's a proven theorem
- No `sorry` in proof

---

### Phase 3: Negation Completeness - maximal_negation_complete [NOT STARTED]

**Goal**: Convert the `maximal_negation_complete` axiom stub to a proven theorem.

**Tasks**:
- [ ] Understand exact signature: `MaximalConsistent G -> phi notin G -> Formula.neg phi in G`
- [ ] Implement proof using maximal_consistent_closed:
  - Assume `MaximalConsistent G` and `phi notin G`
  - By maximality: `(phi :: G)` inconsistent, so `(phi :: G) |- bot`
  - By deduction theorem: `G |- phi -> bot`, i.e., `G |- neg phi`
  - By `maximal_consistent_closed`: `neg phi in G`
- [ ] Replace `axiom` with `theorem` declaration
- [ ] Verify proof compiles

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 437-438

**Verification**:
- `maximal_negation_complete` is a theorem (not axiom)
- Proof uses `maximal_consistent_closed`
- No `sorry` in proof

---

### Phase 4: Set-Based Properties - Implication and Boolean [NOT STARTED]

**Goal**: Add MCS properties for implication, conjunction, and disjunction using set-based definitions.

**Tasks**:
- [ ] Define `set_mcs_implication_property`:
  ```lean
  SetMaximalConsistent S -> (phi.imp psi) in S -> phi in S -> psi in S
  ```
- [ ] Prove using modus ponens derivation and closure property
- [ ] Define `set_mcs_conjunction_iff`:
  ```lean
  SetMaximalConsistent S -> ((phi.and psi) in S <-> phi in S and psi in S)
  ```
  Note: `phi.and psi = neg (phi.imp (neg psi))` by definition
- [ ] Define `set_mcs_disjunction_iff`:
  ```lean
  SetMaximalConsistent S -> ((phi.or psi) in S <-> phi in S or psi in S)
  ```
  Note: `phi.or psi = (neg phi).imp psi` by definition
- [ ] Prove both directions of conjunction/disjunction equivalences

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after negation_complete

**Verification**:
- All three properties compile without `sorry`
- Properties work with `SetMaximalConsistent` (set-based)
- Can be used with `CanonicalWorldState` subtype

---

### Phase 5: Modal Closure - Basic Box Property [NOT STARTED]

**Goal**: Prove basic modal closure property using Modal T axiom.

**Tasks**:
- [ ] Define `set_mcs_box_closure`:
  ```lean
  SetMaximalConsistent S -> Formula.box phi in S -> phi in S
  ```
- [ ] Proof strategy:
  - Modal T axiom: `box phi -> phi`
  - Derive `S |- phi` from `box phi in S` using modus ponens
  - Apply closure property
- [ ] Define `set_mcs_diamond_box_duality`:
  ```lean
  SetMaximalConsistent S -> (neg (box phi) in S <-> diamond (neg phi) in S)
  ```
  (If diamond is defined; otherwise state in terms of negation)
- [ ] Verify Modal T axiom instance exists in Axioms.lean

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add after boolean properties

**Verification**:
- `set_mcs_box_closure` compiles without `sorry`
- Uses Modal T axiom derivation
- Integrates with existing axiom schema

---

### Phase 6: Saturation Lemma Stubs [NOT STARTED]

**Goal**: State modal and temporal saturation lemmas with partial proofs, marking dependencies on later phases.

**Tasks**:
- [ ] State `set_mcs_modal_saturation`:
  ```lean
  SetMaximalConsistent S ->
    (box phi in S <-> forall T : CanonicalWorldState, canonical_task_rel S 0 T -> phi in T.val)
  ```
  - Prove forward direction (uses box_closure)
  - Mark backward direction with `sorry` (needs canonical frame from Phase 4)
- [ ] State `set_mcs_temporal_future_saturation`:
  ```lean
  SetMaximalConsistent S ->
    (G phi in S <-> forall t > 0, forall history path, phi at t)
  ```
  - State with `sorry` (needs canonical history from Phase 5)
- [ ] State `set_mcs_temporal_past_saturation`:
  ```lean
  SetMaximalConsistent S ->
    (H phi in S <-> forall t < 0, forall history path, phi at t)
  ```
  - State with `sorry` (needs canonical history from Phase 5)
- [ ] Document dependencies in comments

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add saturation section

**Verification**:
- All saturation lemmas stated with correct types
- Forward directions proven where possible
- Dependencies on later phases documented
- `sorry` placeholders clearly marked for Phase 4/5 completion

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] `grep -c "^axiom" Theories/Bimodal/Metalogic/Completeness.lean` shows reduction by 2
- [ ] `maximal_consistent_closed` is now a theorem (verify with `#check @maximal_consistent_closed`)
- [ ] `maximal_negation_complete` is now a theorem (verify with `#check`)
- [ ] All new lemmas compile without errors
- [ ] `lean_diagnostic_messages` shows no errors for the file
- [ ] Saturation lemmas have `sorry` only in documented dependency locations

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Modified with proven theorems
- `.claude/specs/445_maximal_consistent_set_properties/plans/implementation-001.md` - This plan
- `.claude/specs/445_maximal_consistent_set_properties/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If proofs become intractable:

1. **Keep axiom stubs**: Revert to axiom declarations if proof strategy fails
2. **Simplify scope**: Focus on core properties (closure, negation) before boolean/modal
3. **Bridge lemma fallback**: If set/list mismatch is problematic, add explicit conversion lemmas
4. **Document blockers**: If stuck, create research-002.md documenting issues for next iteration

The existing axiom stubs serve as safe checkpoints - any proven theorem can be reverted to axiom if needed.

## Notes

- The list-based `MaximalConsistent` in axiom stubs vs set-based `SetMaximalConsistent` in canonical model is a key consideration. Proofs should bridge between these representations.
- `Formula.neg phi = phi.imp bot` by definition - this is important for negation-related proofs.
- The deduction theorem is the key tool: `(A :: G) |- B -> G |- A.imp B`
- Modal T axiom: `box phi -> phi` is essential for box closure.
- Temporal axioms (TK, T4, TA, TL) will be needed in Phase 5/6 saturation proofs.
- Keep proofs modular - each lemma should be independently useful for later phases.
