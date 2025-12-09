# P6 Perpetuity and Pairing Combinator Implementation Plan

## Metadata

- **Status**: [IN PROGRESS]
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/Theorems/Perpetuity.lean
- **Estimated Hours**: 26-39 hours (2-3 hours Phase 1, 10-14 hours Phase 2, 6-10 hours Phase 3, 8-12 hours Phase 4 optional)
- **Dependencies**: None - P5 Plan prerequisites now satisfied (`diamond_4` and `modal_5` are available)
- **Created**: 2025-12-08
- **Last Updated**: 2025-12-09
- **Revised**: 2025-12-09 - Prerequisites satisfied: `diamond_4` and `modal_5` theorems now available from P5 plan

## Overview

This plan addresses TODO.md tasks 19-21 by completing the P5 and P6 perpetuity theorems and optionally deriving the pairing combinator.

**Key Insight**: The S5 Modal property `◇φ → □◇φ` (modal_5) is **derived as a theorem** in the P5 plan (050_p5_perpetuity_s5_derivation), NOT added as a new axiom. This plan depends on that derivation being complete.

**P5 Plan Provides**:
- `diamond_4`: `⊢ φ.diamond.diamond.imp φ.diamond` (from M4 contraposition)
- `modal_5`: `⊢ φ.diamond.imp φ.diamond.box` (from MB + diamond_4 + MK)

**Research Summary**:
- Report 001: Identified S5 Axiom 5 gap as root cause blocking P5
- Report 002: Outlined proof strategies for P5 (trivial after modal_5) and P6 (requires duality lemmas)
- Report 003: Mapped 7 files needing modification, estimated +234-351 LOC
- Report revision_s5_derivation_strategy.md: S5 is derived in P5 plan, not added as axiom

**Priority Tiers**:
1. **HIGH (Phase 1)**: Complete persistence lemma, derive P5 - unblocks perpetuity principles
2. **MEDIUM (Phases 2-3)**: Prove duality lemmas, derive P6 - completes perpetuity suite
3. **LOW (Phase 4)**: Derive pairing combinator - optional zero-axiom footprint

## Prerequisites

### P5 Plan Prerequisites: SATISFIED ✓

The P5 plan (050_p5_perpetuity_s5_derivation) has completed the required theorems:
- **`diamond_4`**: `⊢ φ.diamond.diamond.imp φ.diamond` ✓ AVAILABLE
- **`modal_5`**: `⊢ φ.diamond.imp φ.diamond.box` ✓ AVAILABLE

These theorems provide the S5 characteristic property needed for the persistence lemma. **This plan can now proceed immediately.**

## Implementation Phases

### Phase 1: Complete Persistence Lemma and Derive P5 [COMPLETE]

**Goal**: Remove sorry from persistence lemma using the derived `modal_5` theorem, then derive P5 as theorem.

**Prerequisites**: ✓ SATISFIED - `diamond_4` and `modal_5` theorems now available from P5 plan

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md
- Documentation/ProjectInfo/SORRY_REGISTRY.md

**Tasks**:

- [x] **Task 1.1**: Complete proof of `persistence` lemma
  - **File**: Logos/Core/Theorems/Perpetuity.lean (line 827)
  - **Goal**: `theorem persistence (φ : Formula) : Derivable [] (φ.diamond.imp φ.diamond.always)`
  - **Strategy**:
    1. Apply `modal_5` theorem (from P5 plan) to get `◇φ → □◇φ`
    2. Use TF axiom (`□φ → △φ`) to get `□◇φ → △◇φ`
    3. Chain implications via `imp_trans`
  - **Complexity**: Medium
  - **Estimated LOC**: +25-35 (replacing sorry)
  - **Dependencies**: None - `modal_5` theorem now available
  - **Available Resources**:
    - `modal_5` theorem: `◇φ → □◇φ` ✓ AVAILABLE (derived in P5 plan, NOT an axiom)
    - `Axiom.TF`: `□φ → △φ`
    - `imp_trans`: Transitivity of implication
    - Existing modal/temporal K tactics

- [x] **Task 1.2**: Replace `perpetuity_5` axiom with theorem
  - **File**: Logos/Core/Theorems/Perpetuity.lean
  - **Goal**: `theorem perpetuity_5 (φ : Formula) : Derivable [] (φ.sometimes.diamond.imp φ.diamond.always)`
  - **Strategy**:
    1. Use `perpetuity_4`: `◇▽φ → ◇φ`
    2. Use `persistence`: `◇φ → □◇φ → △◇φ`
    3. Combine via `imp_trans (perpetuity_4 φ) (persistence φ)`
  - **Complexity**: Simple
  - **Estimated LOC**: +8-12 (replacing axiom declaration)
  - **Dependencies**: [Task 1.1]
  - **Note**: Remove `axiom perpetuity_5`, replace with `theorem perpetuity_5`

- [x] **Task 1.3**: Add test for P5 theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_perpetuity_5_derived : Derivable [] ((atom 0).sometimes.diamond.imp (atom 0).diamond.always)`
  - **Strategy**: Instantiate `perpetuity_5` with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 1.2]

- [x] **Task 1.4**: Update TODO.md Task 19 status
  - **File**: TODO.md
  - **Goal**: Mark "### 19. Complete Persistence Lemma (Blocked by S5 Axiom Gap)" as COMPLETE
  - **Strategy**: Update status from BLOCKED to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 1.1]

- [x] **Task 1.5**: Update SORRY_REGISTRY.md
  - **File**: Documentation/ProjectInfo/SORRY_REGISTRY.md
  - **Goal**: Remove persistence lemma entry (line referencing Perpetuity.lean:827)
  - **Strategy**: Delete entry for `persistence` sorry, update summary statistics
  - **Complexity**: Simple
  - **Estimated LOC**: -8-12
  - **Dependencies**: [Task 1.1]

**Success Criteria**:
- [x] `lake build` succeeds with zero errors
- [x] `persistence` proof has zero sorry
- [x] `perpetuity_5` is theorem (not axiom)
- [x] PerpetuityTest includes `test_perpetuity_5_derived`
- [x] TODO.md Task 19 marked COMPLETE
- [x] SORRY_REGISTRY.md has no persistence entry

**Estimated Effort**: 2-3 hours

---

### Phase 2: Prove Modal and Temporal Duality Lemmas [NOT STARTED]

**Goal**: Establish duality lemmas connecting negation with modal/temporal operators to enable P6 derivation.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean

**Tasks**:

- [ ] **Task 2.1**: Prove modal duality lemma (forward direction)
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

- [ ] **Task 2.2**: Prove modal duality lemma (reverse direction)
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

- [ ] **Task 2.3**: Prove temporal duality lemma (forward direction)
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

- [ ] **Task 2.4**: Prove temporal duality lemma (reverse direction)
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

- [ ] **Task 2.5**: Add tests for all four duality lemmas
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: Four test theorems verifying each duality lemma
  - **Strategy**: Instantiate each lemma with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +40-60
  - **Dependencies**: [Tasks 2.1-2.4]
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

### Phase 3: Derive P6 from P5 via Duality [NOT STARTED]

**Goal**: Replace axiomatized P6 with theorem derived from P5 using modal and temporal duality.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md
- CLAUDE.md

**Tasks**:

- [ ] **Task 3.1**: Replace `perpetuity_6` axiom with theorem
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
  - **Dependencies**: [Phase 1 complete, Phase 2 complete]
  - **Available Resources**:
    - `perpetuity_5`: P5 theorem (from Phase 1)
    - All four duality lemmas from Phase 2
    - `imp_trans`: Implication transitivity
    - Contraposition lemmas
  - **Note**: Remove `axiom perpetuity_6`, replace with `theorem perpetuity_6`

- [ ] **Task 3.2**: Add test for P6 theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_perpetuity_6_derived : Derivable [] ((atom 0).box.sometimes.imp (atom 0).always.box)`
  - **Strategy**: Instantiate `perpetuity_6` with `atom 0`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 3.1]

- [ ] **Task 3.3**: Update TODO.md Task 20 status
  - **File**: TODO.md
  - **Goal**: Mark "### 20. Derive P6 Perpetuity Theorem (Blocked by P5 Dependency)" as COMPLETE
  - **Strategy**: Update status from BLOCKED to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 3.1]

- [ ] **Task 3.4**: Update CLAUDE.md perpetuity status
  - **File**: CLAUDE.md
  - **Goal**: Update perpetuity section to reflect P5-P6 fully proven (was axiomatized)
  - **Strategy**: Update "## 6. Key Packages" Theorems section, change "P5-P6 axiomatized" to "P5-P6 fully proven"
  - **Complexity**: Simple
  - **Estimated LOC**: +2-4
  - **Dependencies**: [Task 3.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `perpetuity_6` is theorem (not axiom)
- [ ] PerpetuityTest includes `test_perpetuity_6_derived`
- [ ] TODO.md Task 20 marked COMPLETE
- [ ] CLAUDE.md reflects P5-P6 fully proven

**Estimated Effort**: 6-10 hours

---

### Phase 4: (OPTIONAL) Derive Pairing Combinator [NOT STARTED]

**Goal**: Replace axiomatized pairing combinator with derivation from K and S combinators.

**Priority**: LOW - Skip unless zero-axiom footprint is required. Pairing axiom adds no logical power (derivable from K/S) but derivation is tedious and provides minimal insight.

**Files Modified**:
- Logos/Core/Theorems/Perpetuity.lean
- LogosTest/Core/Theorems/PerpetuityTest.lean
- TODO.md

**Tasks**:

- [ ] **Task 4.1**: Derive pairing combinator from K and S
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

- [ ] **Task 4.2**: Add test for pairing theorem
  - **File**: LogosTest/Core/Theorems/PerpetuityTest.lean
  - **Goal**: `theorem test_pairing_derived : Derivable [] ((atom 0).imp ((atom 1).imp ((atom 0).and (atom 1))))`
  - **Strategy**: Instantiate `pairing_derived` with `atom 0` and `atom 1`, verify derivability
  - **Complexity**: Simple
  - **Estimated LOC**: +12-18
  - **Dependencies**: [Task 4.1]

- [ ] **Task 4.3**: Update TODO.md Task 21 status
  - **File**: TODO.md
  - **Goal**: Mark "### 21. Derive Pairing Combinator" as COMPLETE
  - **Strategy**: Update status to COMPLETE, add completion note
  - **Complexity**: Simple
  - **Estimated LOC**: +2-3
  - **Dependencies**: [Task 4.1]

**Success Criteria**:
- [ ] `lake build` succeeds with zero errors
- [ ] `pairing_derived` is theorem (not axiom)
- [ ] PerpetuityTest includes `test_pairing_derived`
- [ ] TODO.md Task 21 marked COMPLETE

**Estimated Effort**: 8-12 hours

**Recommendation**: SKIP unless zero-axiom footprint is explicitly required. Pairing axiom is harmless and derivation adds no mathematical insight.

---

## File Modification Summary

### Files to Modify (Phases 1-3)

| File | LOC Change | Phases | Purpose |
|------|------------|--------|---------|
| Logos/Core/Theorems/Perpetuity.lean | +163-237 | 1,2,3 | Prove persistence, P5, dualities, P6 |
| LogosTest/Core/Theorems/PerpetuityTest.lean | +64-96 | 1,2,3 | Test P5, dualities, P6 |
| TODO.md | +4-6 | 1,3 | Mark tasks 19-20 complete |
| CLAUDE.md | +2-4 | 3 | Update perpetuity status (no axiom count change) |
| Documentation/ProjectInfo/SORRY_REGISTRY.md | -8-12 | 1 | Remove persistence entry |

**Note**: No changes to Axioms.lean or Soundness.lean - modal_5 is derived as a theorem in P5 plan, not added as an axiom.

**Total Estimated LOC (Phases 1-3)**: +225-331

### Additional Files (Phase 4 - Optional)

| File | LOC Change | Purpose |
|------|------------|---------|
| Logos/Core/Theorems/Perpetuity.lean | +80-120 | Derive pairing combinator |
| LogosTest/Core/Theorems/PerpetuityTest.lean | +12-18 | Test pairing derivation |
| TODO.md | +2-3 | Mark task 21 complete |

**Total Estimated LOC (Phase 4)**: +94-141

**Grand Total (All Phases)**: +319-472 LOC

---

## Dependencies and Blockers

### External Dependencies
- **P5 Plan (050_p5_perpetuity_s5_derivation)**: ✓ SATISFIED - `diamond_4` and `modal_5` theorems now available

### Internal Dependencies
- **Phase 1** depends on ~~P5 Plan~~ ✓ SATISFIED (`modal_5` theorem available)
- **Phase 3** depends on **Phase 1** (requires P5 theorem)
- **Phase 3** depends on **Phase 2** (requires duality lemmas)
- **Phase 4** is independent (optional pairing derivation)

### Current Blockers
- **None** - All prerequisites satisfied, plan can proceed immediately

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

### Prerequisite (P5 Plan)
- [x] P5 Plan Phases 1-2 complete (`diamond_4` and `modal_5` theorems available) ✓ SATISFIED

### Phase 1 (HIGH PRIORITY) [COMPLETE]
- [x] Persistence lemma sorry removed (uses `modal_5` theorem)
- [x] P5 converted from axiom to theorem
- [x] TODO.md Task 19 marked COMPLETE
- [x] Zero build errors, zero lint warnings

### Phases 2-3 (MEDIUM PRIORITY)
- [ ] All four duality lemmas proven (zero sorry)
- [ ] P6 converted from axiom to theorem
- [ ] TODO.md Task 20 marked COMPLETE
- [ ] All perpetuity principles (P1-P6) fully proven
- [ ] CLAUDE.md updated to reflect complete perpetuity suite

### Phase 4 (LOW PRIORITY - OPTIONAL)
- [ ] Pairing combinator derived from K/S (if pursued)
- [ ] TODO.md Task 21 marked COMPLETE (if pursued)
- [ ] Zero-axiom footprint achieved (if required)

---

## Risk Assessment

### External Risk
- **P5 Plan Dependency**: ✓ RESOLVED - `diamond_4` and `modal_5` theorems now available

### Low Risk
- **Phase 1**: Persistence proof straightforward - `modal_5` now available

### Medium Risk
- **Phase 2**: Temporal duality lemmas involve complex operator manipulation
- **Phase 3**: P6 derivation requires careful substitution and contraposition chain

### High Risk
- **Phase 4**: Combinator derivation tedious and error-prone (recommend skipping)

### Mitigation Strategies
- Use incremental testing (verify each lemma independently)
- Leverage existing automation tactics (tm_auto, modal_k, temporal_k)
- Consult research reports for proof strategy details
- Skip Phase 4 unless explicitly required

---

## Notes

### Research Report References
- **001-mathlib-theorems.md**: Identified S5 Axiom 5 gap, confirmed pairing derivable
- **002-proof-strategies.md**: Outlined proof strategies for P5 (trivial) and P6 (duality chain)
- **003-project-structure.md**: Mapped file modification requirements, estimated LOC
- **revision_s5_derivation_strategy.md**: Documents that S5 is derived in P5 plan, not added as axiom

### Key Design Decisions
1. **REVISED: Use derived modal_5 theorem**: The P5 plan (050_p5_perpetuity_s5_derivation) derives `modal_5` (`◇φ → □◇φ`) from existing TM axioms (MB + M4 + MK). No new axioms needed.
2. **Derive P5 from modal_5**: Once `modal_5` theorem proven (in P5 plan), P5 follows immediately
3. **Derive P6 from P5**: Requires duality lemmas but follows clear proof path
4. **Keep pairing axiomatized (Phase 4 optional)**: Derivation tedious, adds no insight

### Key Insight: S5 Derivable from TM
The S5 characteristic property `◇φ → □◇φ` is **derived** in the P5 plan via:
1. `diamond_4 : ◇◇φ → ◇φ` (from M4 contraposition)
2. `modal_5 : ◇φ → □◇φ` (from MB + diamond_4 + MK distribution)

This means no changes to axiom count (remains 12) and no soundness proofs needed.

### Future Work
- Consider S5 axiom derivations as example of emergent properties from TM
- Explore automation for duality lemma proofs (simp lemmas, custom tactics)
- Document P5/P6 derivation strategies in ARCHITECTURE.md

---

## Completion Checklist

- [x] **Prerequisite**: P5 Plan Phases 1-2 complete (provides `diamond_4` and `modal_5` theorems) ✓ SATISFIED
- [ ] Phase 1: Persistence lemma and P5 completed (uses `modal_5`)
- [ ] Phase 2: Duality lemmas proven
- [ ] Phase 3: P6 derived from P5
- [ ] Phase 4: (Optional) Pairing combinator derived
- [ ] All tests passing (lake test succeeds)
- [ ] Zero lint warnings (lake lint clean)
- [ ] Documentation updated (CLAUDE.md, TODO.md, SORRY_REGISTRY.md)
- [ ] TODO.md tasks 19-20 marked COMPLETE (task 21 if Phase 4 completed)
- [ ] Axiom count remains 12 (no new axioms added)
