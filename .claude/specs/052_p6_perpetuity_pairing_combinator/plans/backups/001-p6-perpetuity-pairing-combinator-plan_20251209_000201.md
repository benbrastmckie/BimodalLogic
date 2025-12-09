# P6 Perpetuity and Pairing Combinator Implementation Plan

## Metadata

- **Status**: [NOT STARTED]
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/Theorems/Perpetuity.lean
- **Estimated Hours**: 31-47 hours (7-11 hours Phase 1-2, 16-24 hours Phase 3-4, 8-12 hours Phase 5 optional)
- **Dependencies**: None external
- **Created**: 2025-12-08
- **Last Updated**: 2025-12-08

## Overview

This plan addresses TODO.md tasks 19-21 by completing the P5 and P6 perpetuity theorems and optionally deriving the pairing combinator. The primary blocker is the missing S5 Modal Axiom 5 (`◇φ → □◇φ`), which prevents deriving the persistence lemma needed for P5. Once Axiom 5 is added, P5 becomes trivial. P6 requires additional modal and temporal duality lemmas but follows a clear derivation path from P5.

**Research Summary**:
- Report 001: Identified S5 Axiom 5 gap as root cause blocking P5
- Report 002: Outlined proof strategies for P5 (trivial after Axiom 5) and P6 (requires duality lemmas)
- Report 003: Mapped 10 files needing modification, estimated +344-451 LOC

**Priority Tiers**:
1. **HIGH (Phase 1-2)**: Add Axiom 5, derive P5 - unblocks perpetuity principles
2. **MEDIUM (Phase 3-4)**: Prove duality lemmas, derive P6 - completes perpetuity suite
3. **LOW (Phase 5)**: Derive pairing combinator - optional zero-axiom footprint

## Implementation Phases

### Phase 1: Add S5 Modal Axiom 5 [NOT STARTED]

**Goal**: Extend TM logic with S5 Modal Axiom 5 to enable persistence derivation.

**Files Modified**:
- Logos/Core/ProofSystem/Axioms.lean
- Logos/Core/Metalogic/Soundness.lean
- LogosTest/Core/ProofSystem/AxiomsTest.lean
- CLAUDE.md

**Tasks**:

- [ ] **Task 1.1**: Add `modal_5` constructor to `Axiom` inductive type
  - **File**: Logos/Core/ProofSystem/Axioms.lean
  - **Goal**: Extend axiom schema with `| modal_5 (φ : Formula) : Axiom (φ.diamond.imp φ.diamond.box)`
  - **Strategy**: Direct axiom addition following existing modal axiom patterns (MT, M4, MB)
  - **Complexity**: Simple
  - **Estimated LOC**: +8-12 (constructor + docstring)
  - **Dependencies**: None

- [ ] **Task 1.2**: Prove soundness of `modal_5` axiom
  - **File**: Logos/Core/Metalogic/Soundness.lean
  - **Goal**: `theorem modal_5_valid : ∀ M τ t φ, truth_at M τ t (φ.diamond.imp φ.diamond.box)`
  - **Strategy**: Semantic argument using S5 modal structure - if `∃w. R w w'` and `M,w' ⊨ φ`, then `∀w''. R w w'' → (∃w'''. R w'' w''' ∧ M,w''' ⊨ φ)` by reflexivity/transitivity
  - **Complexity**: Medium
  - **Estimated LOC**: +40-60 (proof + helper lemmas)
  - **Dependencies**: [Task 1.1]
  - **Available Resources**:
    - `TaskFrame.reflexive`: Modal accessibility is reflexive
    - `TaskFrame.transitive`: Modal accessibility is transitive
    - Existing soundness proof patterns from MT, M4, MB

- [ ] **Task 1.3**: Add `modal_5` case to main soundness theorem
  - **File**: Logos/Core/Metalogic/Soundness.lean
  - **Goal**: Extend pattern match in `soundness_axiom` with `| Axiom.modal_5 φ => modal_5_valid M τ t φ`
  - **Strategy**: Direct case addition following existing axiom cases
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 1.2]

- [ ] **Task 1.4**: Add test for `modal_5` axiom
  - **File**: LogosTest/Core/ProofSystem/AxiomsTest.lean
  - **Goal**: `theorem test_modal_5_derivable : Derivable [] ((atom 0).diamond.imp (atom 0).diamond.box)`
  - **Strategy**: Instantiate axiom with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 1.1]

- [ ] **Task 1.5**: Update documentation for new axiom
  - **File**: CLAUDE.md
  - **Goal**: Update axiom count (12 → 13), add modal_5 to axiom list
  - **Strategy**: Update "## 6. Key Packages" ProofSystem section with modal_5
  - **Complexity**: Simple
  - **Estimated LOC**: +3-5
  - **Dependencies**: [Task 1.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `modal_5` constructor type-checks in Axioms.lean
- [ ] `modal_5_valid` proven with zero sorry
- [ ] Main soundness theorem includes modal_5 case
- [ ] AxiomsTest includes `test_modal_5_derivable`
- [ ] CLAUDE.md reflects 13 axioms (was 12)

**Estimated Effort**: 3-5 hours

---

### Phase 2: Complete Persistence Lemma and Derive P5 [NOT STARTED]

**Goal**: Remove sorry from persistence lemma using new modal_5 axiom, then derive P5 as theorem.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md
- Documentation/ProjectInfo/SORRY_REGISTRY.md

**Tasks**:

- [ ] **Task 2.1**: Complete proof of `persistence` lemma
  - **File**: Logos/Core/Theorems/Perpetuity.lean (line 827)
  - **Goal**: `theorem persistence (φ : Formula) : Derivable [] (φ.diamond.imp φ.diamond.always)`
  - **Strategy**:
    1. Apply `modal_5` to get `◇φ → □◇φ`
    2. Use TF axiom (`□φ → △φ`) to get `□◇φ → △◇φ`
    3. Chain implications via `imp_trans`
  - **Complexity**: Medium
  - **Estimated LOC**: +25-35 (replacing sorry)
  - **Dependencies**: [Phase 1 complete]
  - **Available Resources**:
    - `Axiom.modal_5`: `◇φ → □◇φ`
    - `Axiom.TF`: `□φ → △φ`
    - `imp_trans`: Transitivity of implication
    - Existing modal/temporal K tactics

- [ ] **Task 2.2**: Replace `perpetuity_5` axiom with theorem
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem perpetuity_5 (φ : Formula) : Derivable [] (φ.sometimes.diamond.imp φ.diamond.always)`
  - **Strategy**:
    1. Use `perpetuity_4`: `◇▽φ → ◇φ`
    2. Use `persistence`: `◇φ → □◇φ → △◇φ`
    3. Combine via `imp_trans (perpetuity_4 φ) (persistence φ)`
  - **Complexity**: Simple
  - **Estimated LOC**: +8-12 (replacing axiom declaration)
  - **Dependencies**: [Task 2.1]
  - **Note**: Remove `axiom perpetuity_5`, replace with `theorem perpetuity_5`

- [ ] **Task 2.3**: Add test for P5 theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_perpetuity_5_derived : Derivable [] ((atom 0).sometimes.diamond.imp (atom 0).diamond.always)`
  - **Strategy**: Instantiate `perpetuity_5` with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 2.2]

- [ ] **Task 2.4**: Update TODO.md Task 19 status
  - **File**: TODO.md
  - **Goal**: Mark "### 19. Complete Persistence Lemma (Blocked by S5 Axiom Gap)" as COMPLETE
  - **Strategy**: Update status from BLOCKED to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 2.1]

- [ ] **Task 2.5**: Update SORRY_REGISTRY.md
  - **File**: Documentation/ProjectInfo/SORRY_REGISTRY.md
  - **Goal**: Remove persistence lemma entry (line referencing Perpetuity.lean:827)
  - **Strategy**: Delete entry for `persistence` sorry, update summary statistics
  - **Complexity**: Simple
  - **Estimated LOC**: -8-12
  - **Dependencies**: [Task 2.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `persistence` proof has zero sorry
- [ ] `perpetuity_5` is theorem (not axiom)
- [ ] PerpetuityTest includes `test_perpetuity_5_derived`
- [ ] TODO.md Task 19 marked COMPLETE
- [ ] SORRY_REGISTRY.md has no persistence entry

**Estimated Effort**: 4-6 hours

---

### Phase 3: Prove Modal and Temporal Duality Lemmas [NOT STARTED]

**Goal**: Establish duality lemmas connecting negation with modal/temporal operators to enable P6 derivation.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean

**Tasks**:

- [ ] **Task 3.1**: Prove modal duality lemma (forward direction)
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem modal_duality_neg (φ : Formula) : Derivable [] (φ.neg.diamond.imp φ.box.neg)`
  - **Strategy**:
    1. Use `box_dne`: `□¬¬φ → □φ` (contraposed: `¬□φ → ¬□¬¬φ`)
    2. Apply modal K to distribute negation
    3. Use contraposition to flip implication direction
  - **Complexity**: Medium
  - **Estimated LOC**: +30-40
  - **Dependencies**: None (uses existing lemmas)
  - **Available Resources**:
    - `box_dne`: Double negation elimination under box
    - `modal_k_tactic`: Modal K distribution
    - Contraposition lemmas from propositional logic

- [ ] **Task 3.2**: Prove modal duality lemma (reverse direction)
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem modal_duality_neg_rev (φ : Formula) : Derivable [] (φ.box.neg.imp φ.neg.diamond)`
  - **Strategy**:
    1. Use `dni`: `φ → ¬¬φ` (double negation introduction)
    2. Apply to `□φ → ◇φ` (from modal T axiom contraposed)
    3. Contrapose to get `¬□φ → ◇¬φ`
  - **Complexity**: Medium
  - **Estimated LOC**: +30-40
  - **Dependencies**: None (uses existing lemmas)
  - **Available Resources**:
    - `dni`: Double negation introduction
    - `Axiom.MT`: `□φ → φ` (modal T)
    - Contraposition tactics

- [ ] **Task 3.3**: Prove temporal duality lemma (forward direction)
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem temporal_duality_neg (φ : Formula) : Derivable [] (φ.neg.sometimes.imp φ.always.neg)`
  - **Strategy**:
    1. Expand `sometimes` = `¬always ¬` and `always` = `¬sometimes ¬`
    2. Use temporal K distribution to push negations through
    3. Apply double negation elimination
  - **Complexity**: Complex (requires careful temporal operator manipulation)
  - **Estimated LOC**: +50-70
  - **Dependencies**: None (uses existing lemmas)
  - **Available Resources**:
    - `temporal_k_tactic`: Temporal K distribution
    - `swap_temporal`: Temporal duality (all_past ↔ all_future)
    - DNE/DNI lemmas

- [ ] **Task 3.4**: Prove temporal duality lemma (reverse direction)
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem temporal_duality_neg_rev (φ : Formula) : Derivable [] (φ.always.neg.imp φ.neg.sometimes)`
  - **Strategy**:
    1. Apply temporal K distribution in reverse
    2. Use double negation introduction to flip signs
    3. Contrapose to get desired direction
  - **Complexity**: Complex (requires careful temporal operator manipulation)
  - **Estimated LOC**: +50-70
  - **Dependencies**: None (uses existing lemmas)
  - **Available Resources**:
    - `temporal_k_tactic`: Temporal K distribution
    - `swap_temporal`: Temporal duality
    - DNI lemmas

- [ ] **Task 3.5**: Add tests for all four duality lemmas
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: Four test theorems verifying each duality lemma
  - **Strategy**: Instantiate each lemma with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +40-60
  - **Dependencies**: [Tasks 3.1-3.4]
  - **Tests**:
    - `test_modal_duality_neg`
    - `test_modal_duality_neg_rev`
    - `test_temporal_duality_neg`
    - `test_temporal_duality_neg_rev`

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] All four duality lemmas proven with zero sorry
- [ ] PerpetuityTest includes all four duality tests
- [ ] Each test verifies lemma derivability with concrete formula

**Estimated Effort**: 10-14 hours

---

### Phase 4: Derive P6 from P5 via Duality [NOT STARTED]

**Goal**: Replace axiomatized P6 with theorem derived from P5 using modal and temporal duality.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md
- CLAUDE.md

**Tasks**:

- [ ] **Task 4.1**: Replace `perpetuity_6` axiom with theorem
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem perpetuity_6 (φ : Formula) : Derivable [] (φ.box.sometimes.imp φ.always.box)`
  - **Strategy**:
    1. Start with P5: `◇▽φ → △◇φ`
    2. Substitute `¬φ` for `φ`: `◇▽¬φ → △◇¬φ`
    3. Apply `temporal_duality_neg`: `▽¬φ → ¬△φ` gives `◇¬△φ → △◇¬φ`
    4. Apply `modal_duality_neg`: `◇¬φ → ¬□φ` gives `◇¬△φ → ¬□△φ`
    5. Apply `temporal_duality_neg_rev`: `¬△φ → ▽¬φ` gives `¬□△φ → ▽¬□φ`
    6. Apply `modal_duality_neg_rev`: `¬□φ → ◇¬φ` gives `¬□△φ → □¬△¬φ`
    7. Contrapose entire chain to get `□▽φ → △□φ`
  - **Complexity**: Complex (requires careful substitution and contraposition)
  - **Estimated LOC**: +60-80
  - **Dependencies**: [Phase 2 complete, Phase 3 complete]
  - **Available Resources**:
    - `perpetuity_5`: P5 theorem
    - All four duality lemmas from Phase 3
    - `imp_trans`: Implication transitivity
    - Contraposition lemmas
  - **Note**: Remove `axiom perpetuity_6`, replace with `theorem perpetuity_6`

- [ ] **Task 4.2**: Add test for P6 theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_perpetuity_6_derived : Derivable [] ((atom 0).box.sometimes.imp (atom 0).always.box)`
  - **Strategy**: Instantiate `perpetuity_6` with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 4.1]

- [ ] **Task 4.3**: Update TODO.md Task 20 status
  - **File**: TODO.md
  - **Goal**: Mark "### 20. Derive P6 Perpetuity Theorem (Blocked by P5 Dependency)" as COMPLETE
  - **Strategy**: Update status from BLOCKED to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 4.1]

- [ ] **Task 4.4**: Update CLAUDE.md perpetuity status
  - **File**: CLAUDE.md
  - **Goal**: Update perpetuity section to reflect P5-P6 fully proven (was axiomatized)
  - **Strategy**: Update "## 6. Key Packages" Theorems section, change "P5-P6 axiomatized" to "P5-P6 fully proven"
  - **Complexity**: Simple
  - **Estimated LOC**: +2-4
  - **Dependencies**: [Task 4.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `perpetuity_6` is theorem (not axiom)
- [ ] PerpetuityTest includes `test_perpetuity_6_derived`
- [ ] TODO.md Task 20 marked COMPLETE
- [ ] CLAUDE.md reflects P5-P6 fully proven

**Estimated Effort**: 6-10 hours

---

### Phase 5: (OPTIONAL) Derive Pairing Combinator [NOT STARTED]

**Goal**: Replace axiomatized pairing combinator with derivation from K and S combinators.

**Priority**: LOW - Skip unless zero-axiom footprint is required. Pairing axiom adds no logical power (derivable from K/S) but derivation is tedious and provides minimal insight.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md

**Tasks**:

- [ ] **Task 5.1**: Derive pairing combinator from K and S
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem pairing_derived (A B : Formula) : Derivable [] (A.imp (B.imp (A.and B)))`
  - **Strategy**:
    1. Define I combinator: `I = SKK` (identity)
    2. Build pairing: `pairing = S(S(KS)(S(KK)I))(KI)`
    3. Reduce step-by-step using K/S reduction rules
    4. Verify result matches `A → B → A ∧ B`
  - **Complexity**: Complex (40-50 lines of tedious combinator manipulation)
  - **Estimated LOC**: +80-120
  - **Dependencies**: None (uses existing K/S combinators)
  - **Available Resources**:
    - K combinator: `Kxy = x`
    - S combinator: `Sxyz = xz(yz)`
    - Existing combinator reduction tactics
  - **Note**: Remove `axiom pairing`, replace with `theorem pairing_derived`
  - **Warning**: High effort, low value - only pursue if zero-axiom property critical

- [ ] **Task 5.2**: Add test for pairing theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_pairing_derived : Derivable [] ((atom 0).imp ((atom 1).imp ((atom 0).and (atom 1))))`
  - **Strategy**: Instantiate `pairing_derived` with `atom 0` and `atom 1`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 5.1]

- [ ] **Task 5.3**: Update TODO.md Task 21 status
  - **File**: TODO.md
  - **Goal**: Mark "### 21. Derive Pairing Combinator" as COMPLETE
  - **Strategy**: Update status to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 5.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `pairing_derived` is theorem (not axiom)
- [ ] PerpetuityTest includes `test_pairing_derived`
- [ ] TODO.md Task 21 marked COMPLETE

**Estimated Effort**: 8-12 hours

**Recommendation**: SKIP unless zero-axiom footprint is explicitly required. Pairing axiom is harmless and derivation adds no mathematical insight.

---

## File Modification Summary

### Files to Modify (Phases 1-4)

| File | LOC Change | Phases | Purpose |
|------|------------|--------|---------|
| Logos/Core/ProofSystem/Axioms.lean | +8-12 | 1 | Add modal_5 axiom |
| Logos/Core/Metalogic/Soundness.lean | +42-63 | 1 | Prove modal_5 valid |
| LogosTest/Core/ProofSystem/AxiomsTest.lean | +12-18 | 1 | Test modal_5 |
| Logos/Core/Theorems/Perpetuity.lean | +163-237 | 2,3,4 | Prove persistence, P5, dualities, P6 |
| LogosTest/Core/Theorems/PerpetuityTest.lean | +64-96 | 2,3,4 | Test P5, dualities, P6 |
| TODO.md | +4-6 | 2,4 | Mark tasks 19-20 complete |
| CLAUDE.md | +5-9 | 1,4 | Update axiom count, perpetuity status |
| Documentation/ProjectInfo/SORRY_REGISTRY.md | -8-12 | 2 | Remove persistence entry |

**Total Estimated LOC (Phases 1-4)**: +290-429

### Additional Files (Phase 5 - Optional)

| File | LOC Change | Purpose |
|------|------------|---------|
| Logos/Core/Theorems/Perpetuity.lean | +80-120 | Derive pairing combinator |
| LogosTest/Core/Theorems/PerpetuityTest.lean | +12-18 | Test pairing derivation |
| TODO.md | +2-3 | Mark task 21 complete |

**Total Estimated LOC (Phase 5)**: +94-141

**Grand Total (All Phases)**: +384-570 LOC

---

## Dependencies and Blockers

### External Dependencies
- None (all work internal to Logos codebase)

### Internal Dependencies
- **Phase 2** depends on **Phase 1** (requires modal_5 axiom)
- **Phase 4** depends on **Phase 2** (requires P5 theorem)
- **Phase 4** depends on **Phase 3** (requires duality lemmas)
- **Phase 5** is independent (optional pairing derivation)

### Current Blockers
- None (research complete, path forward clear)

---

## Testing Strategy

### Unit Tests
- **AxiomsTest.lean**: Test modal_5 axiom instantiation
- **PerpetuityTest.lean**: Test P5, duality lemmas, P6 derivations
- **SoundnessTest.lean**: Verify modal_5 soundness (implicit via lake build)

### Integration Tests
- Verify P5 derivation uses modal_5 and persistence
- Verify P6 derivation uses P5 and all four duality lemmas
- Verify all perpetuity theorems (P1-P6) proven with zero sorry

### Regression Tests
- Ensure existing perpetuity tests still pass
- Verify no new lint warnings introduced
- Confirm lake build time remains <2min

---

## Success Metrics

### Phase 1-2 (HIGH PRIORITY)
- [ ] S5 Axiom 5 added and proven sound
- [ ] Persistence lemma sorry removed (line 827)
- [ ] P5 converted from axiom to theorem
- [ ] TODO.md Task 19 marked COMPLETE
- [ ] Zero build errors, zero lint warnings

### Phase 3-4 (MEDIUM PRIORITY)
- [ ] All four duality lemmas proven (zero sorry)
- [ ] P6 converted from axiom to theorem
- [ ] TODO.md Task 20 marked COMPLETE
- [ ] All perpetuity principles (P1-P6) fully proven
- [ ] CLAUDE.md updated to reflect complete perpetuity suite

### Phase 5 (LOW PRIORITY - OPTIONAL)
- [ ] Pairing combinator derived from K/S (if pursued)
- [ ] TODO.md Task 21 marked COMPLETE (if pursued)
- [ ] Zero-axiom footprint achieved (if required)

---

## Risk Assessment

### Low Risk
- **Phase 1**: Axiom addition follows established patterns
- **Phase 2**: Persistence proof straightforward once modal_5 available

### Medium Risk
- **Phase 3**: Temporal duality lemmas involve complex operator manipulation
- **Phase 4**: P6 derivation requires careful substitution and contraposition chain

### High Risk
- **Phase 5**: Combinator derivation tedious and error-prone (recommend skipping)

### Mitigation Strategies
- Use incremental testing (verify each lemma independently)
- Leverage existing automation tactics (tm_auto, modal_k, temporal_k)
- Consult research reports for proof strategy details
- Skip Phase 5 unless explicitly required

---

## Notes

### Research Report References
- **001-mathlib-theorems.md**: Identified S5 Axiom 5 gap, confirmed pairing derivable
- **002-proof-strategies.md**: Outlined proof strategies for P5 (trivial) and P6 (duality chain)
- **003-project-structure.md**: Mapped file modification requirements, estimated LOC

### Key Design Decisions
1. **Add modal_5 as axiom**: S5 Axiom 5 is fundamental, not derivable from existing axioms
2. **Derive P5 from modal_5**: Once axiom added, P5 follows immediately
3. **Derive P6 from P5**: Requires duality lemmas but follows clear proof path
4. **Keep pairing axiomatized (Phase 5 optional)**: Derivation tedious, adds no insight

### Future Work
- Consider adding other S5 axioms (symmetry, transitivity) if needed for future theorems
- Explore automation for duality lemma proofs (simp lemmas, custom tactics)
- Document P5/P6 derivation strategies in ARCHITECTURE.md

---

## Completion Checklist

- [ ] Phase 1: S5 Axiom 5 added and proven sound
- [ ] Phase 2: Persistence lemma and P5 completed
- [ ] Phase 3: Duality lemmas proven
- [ ] Phase 4: P6 derived from P5
- [ ] Phase 5: (Optional) Pairing combinator derived
- [ ] All tests passing (lake test succeeds)
- [ ] Zero lint warnings (lake lint clean)
- [ ] Documentation updated (CLAUDE.md, TODO.md, SORRY_REGISTRY.md)
- [ ] TODO.md tasks 19-20 marked COMPLETE (task 21 if Phase 5 completed)
