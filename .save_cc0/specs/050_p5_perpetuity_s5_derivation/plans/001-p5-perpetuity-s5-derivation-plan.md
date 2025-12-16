# Implementation Plan: P5 Perpetuity S5 Derivation

## Metadata

- **Feature**: Derive P5 and P6 perpetuity theorems from existing TM axioms (no new axioms)
- **Status**: [IN PROGRESS]
- **Priority**: Medium
- **Complexity**: 3 (Medium-High)
- **Estimated Hours**: 8-12
- **Created**: 2025-12-08
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Executive Summary

This plan derives P5 (`◇▽φ → △◇φ`, persistent possibility) and P6 (`▽□φ → □△φ`, occurrent necessity is perpetual) as theorems without adding new axioms. The key insight is that `◇φ → □◇φ` (S5 characteristic for diamond) is derivable from existing TM axioms (MB, M4, MK distribution), enabling completion of the persistence lemma.

## Research Summary

Based on analysis in reports:
- `001-s5-axiom-analysis.md`: Determined `◇φ → □◇φ` is derivable from MB + M4 + MK
- `002-proof-strategy.md`: Complete derivation strategy for P5 and P6
- `003-project-structure.md`: Identified exact file locations and dependencies

## Success Criteria

- [ ] `diamond_4` theorem proven with zero sorry
- [ ] `modal_5` theorem proven with zero sorry
- [ ] `persistence` lemma proven with zero sorry (removes 1 existing sorry)
- [ ] P5 converted from axiom to theorem with zero sorry
- [ ] P6 converted from axiom to theorem with zero sorry
- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] Total axiom count in Perpetuity.lean reduced from 4 to 2 (keep pairing, dni)
- [ ] Documentation updated

---

## Phase 1: Derive Diamond-4 (◇◇φ → ◇φ) [IN PROGRESS]

### Description
Derive the S5 property that possible-possible implies possible, via contraposition of M4.

### Theorem Specification
- [ ] `theorem diamond_4`
  - Goal: `⊢ φ.diamond.diamond.imp φ.diamond`
  - Strategy: M4 on ¬φ gives `□¬φ → □□¬φ`, contrapose to get `◇◇φ → ◇φ`
  - Complexity: Medium
  - Dependencies: M4 axiom (modal_4), contraposition theorem

### Implementation Details
```lean
/--
Diamond 4: `◇◇φ → ◇φ` (possible-possible implies possible).

Derived from M4 (`□φ → □□φ`) via contraposition on `¬φ`:
1. M4 for `¬φ`: `⊢ □¬φ → □□¬φ`
2. By definition: `□¬φ = ¬◇φ` and `□□¬φ = ¬◇◇φ`
3. So step 1 is: `⊢ ¬◇φ → ¬◇◇φ`
4. Contraposition: `⊢ ◇◇φ → ◇φ`
-/
theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := by
  have m4_neg : ⊢ φ.neg.box.imp φ.neg.box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 φ.neg)
  exact contraposition m4_neg
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Type signature matches expected

### Location
Insert after `contraposition` theorem (around line 453)

---

## Phase 2: Derive Modal-5 (◇φ → □◇φ) [NOT STARTED]

### Description
Derive the S5 characteristic axiom for diamond: if something is possible, it is necessarily possible.

### Theorem Specification
- [ ] `theorem modal_5`
  - Goal: `⊢ φ.diamond.imp φ.diamond.box`
  - Strategy: MB on ◇φ + diamond_4 lifted to box via MK
  - Complexity: Medium
  - Dependencies: mb_diamond, diamond_4, modal_k_dist, necessitation

### Implementation Details
```lean
/--
Modal 5: `◇φ → □◇φ` (S5 characteristic for diamond).

If something is possible, it is necessarily possible.

Derived from MB + diamond_4 + MK distribution:
1. MB on `◇φ`: `⊢ ◇φ → □◇◇φ`
2. diamond_4: `⊢ ◇◇φ → ◇φ`
3. Necessitate: `⊢ □(◇◇φ → ◇φ)`
4. MK distribution: `⊢ □◇◇φ → □◇φ`
5. Compose steps 1 and 4: `⊢ ◇φ → □◇φ`
-/
theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box := by
  -- Step 1: MB on ◇φ
  have mb_dia : ⊢ φ.diamond.imp φ.diamond.diamond.box :=
    Derivable.axiom [] _ (Axiom.modal_b φ.diamond)

  -- Step 2: diamond_4 for φ
  have d4 : ⊢ φ.diamond.diamond.imp φ.diamond := diamond_4 φ

  -- Step 3: Necessitate d4
  have box_d4 : ⊢ (φ.diamond.diamond.imp φ.diamond).box :=
    Derivable.necessitation _ d4

  -- Step 4: MK distribution
  have mk : ⊢ (φ.diamond.diamond.imp φ.diamond).box.imp
               (φ.diamond.diamond.box.imp φ.diamond.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.diamond.diamond φ.diamond)

  have d4_box : ⊢ φ.diamond.diamond.box.imp φ.diamond.box :=
    Derivable.modus_ponens [] _ _ mk box_d4

  -- Step 5: Compose
  exact imp_trans mb_dia d4_box
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Verify by checking `#check modal_5`

### Location
Insert immediately after `diamond_4`

---

## Phase 3: Temporal K Distribution Lemmas [NOT STARTED]

### Description
Derive temporal distribution lemmas needed for pushing MT inside H and G operators.

### Theorem Specifications
- [ ] `theorem temp_k_dist_future`
  - Goal: `⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)`
  - Strategy: Use TK inference rule similar to how MK distribution is derived from MK rule
  - Complexity: Medium
  - Dependencies: TK rule (temporal_k), propositional lemmas

- [ ] `theorem temp_k_dist_past`
  - Goal: `⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past)`
  - Strategy: Temporal duality of temp_k_dist_future
  - Complexity: Low (after temp_k_dist_future)
  - Dependencies: temp_k_dist_future, temporal_duality

### Implementation Details
```lean
/--
Temporal K distribution for future: `G(A → B) → (GA → GB)`.

Future distributes over implication. This is the temporal analog of modal K distribution.
-/
theorem temp_k_dist_future (A B : Formula) :
    ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future) := by
  -- Use TK rule to derive this
  -- TK: If GΓ ⊢ φ then Γ ⊢ Gφ
  -- Strategy: From [G(A → B), GA] derive B, then apply TK to get GB
  sorry -- Will implement based on TK rule structure

/--
Temporal K distribution for past: `H(A → B) → (HA → HB)`.

Derived via temporal duality from temp_k_dist_future.
-/
theorem temp_k_dist_past (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past) := by
  have h_future := temp_k_dist_future A.swap_temporal B.swap_temporal
  have h_dual := Derivable.temporal_duality _ h_future
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual
```

### Success Criteria
- [ ] Both theorems compile without sorry
- [ ] Verify distribution property

### Location
Insert after `box_diamond_to_past_box_diamond` (around line 762)

### Note
This phase may require alternative approaches if direct use of TK rule proves difficult. Alternative: derive from already-proven box distribution by lifting through modal-temporal interaction.

---

## Phase 4: Complete Persistence Lemma [NOT STARTED]

### Description
Replace the sorry in the persistence lemma with a complete proof using modal_5.

### Theorem Specification
- [ ] `theorem persistence` (fix existing)
  - Goal: `⊢ φ.diamond.imp φ.diamond.always`
  - Strategy: Use modal_5 to bridge ◇φ → □◇φ, then use existing helpers
  - Complexity: High
  - Dependencies: modal_5, box_diamond_to_future_box_diamond, box_diamond_to_past_box_diamond, combine_imp_conj_3 or equivalent

### Implementation Details
```lean
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Goal: ◇φ → △◇φ where △◇φ = H◇φ ∧ ◇φ ∧ G◇φ

  -- Key bridge: modal_5 gives ◇φ → □◇φ
  have m5 : ⊢ φ.diamond.imp φ.diamond.box := modal_5 φ

  -- From □◇φ, derive each temporal component:
  -- Past: □◇φ → H□◇φ → H◇φ
  have h_past_box : ⊢ φ.diamond.box.imp φ.diamond.box.all_past :=
    box_diamond_to_past_box_diamond φ
  have mt_dia : ⊢ φ.diamond.box.imp φ.diamond :=
    Derivable.axiom [] _ (Axiom.modal_t φ.diamond)
  -- Need: H□◇φ → H◇φ (apply MT inside H)
  -- This requires temp_k_dist_past
  have h_mt_nec : ⊢ (φ.diamond.box.imp φ.diamond).all_past :=
    sorry -- Necessitate MT for past
  have h_dist : ⊢ φ.diamond.box.all_past.imp φ.diamond.all_past :=
    sorry -- Apply temp_k_dist_past
  have h_past : ⊢ φ.diamond.box.imp φ.diamond.all_past :=
    imp_trans h_past_box h_dist

  -- Present: □◇φ → ◇φ (MT)
  have h_present : ⊢ φ.diamond.box.imp φ.diamond := mt_dia

  -- Future: □◇φ → G□◇φ → G◇φ (similar to past)
  have h_future_box : ⊢ φ.diamond.box.imp φ.diamond.box.all_future :=
    box_diamond_to_future_box_diamond φ
  have h_future : ⊢ φ.diamond.box.imp φ.diamond.all_future :=
    sorry -- Similar to h_past

  -- Combine: □◇φ → H◇φ ∧ ◇φ ∧ G◇φ
  have h_box_to_always : ⊢ φ.diamond.box.imp φ.diamond.always :=
    combine_imp_conj_3 h_past h_present h_future

  -- Final: ◇φ → □◇φ → △◇φ
  exact imp_trans m5 h_box_to_always
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Sorry count in Perpetuity.lean decreases from 1 to 0
- [ ] Verify: `#check persistence`

### Location
Replace existing sorry at line 827

---

## Phase 5: Derive P5 from P4 + Persistence [NOT STARTED]

### Description
Convert P5 from axiom to theorem using composition of P4 and persistence.

### Theorem Specification
- [ ] `theorem perpetuity_5` (replace axiom)
  - Goal: `⊢ φ.sometimes.diamond.imp φ.diamond.always`
  - Strategy: Simple composition of P4 and persistence
  - Complexity: Simple
  - Dependencies: perpetuity_4, persistence

### Implementation Details
```lean
/--
P5: `◇▽φ → △◇φ` (persistent possibility)

If it's possible that φ happens sometime, then it's always possible.

Derived from P4 composed with persistence lemma:
1. P4: `◇▽φ → ◇φ`
2. Persistence: `◇φ → △◇φ`
3. Transitivity: `◇▽φ → △◇φ`
-/
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  have p4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ
  have pers : ⊢ φ.diamond.imp φ.diamond.always := persistence φ
  exact imp_trans p4 pers
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Remove `axiom perpetuity_5` declaration
- [ ] Existing tests still pass

### Location
Replace axiom at line 859

---

## Phase 6: Derive P6 [NOT STARTED]

### Description
Convert P6 from axiom to theorem. This may use P5 via duality or be derived directly.

### Theorem Specification
- [ ] `theorem perpetuity_6` (replace axiom)
  - Goal: `⊢ φ.box.sometimes.imp φ.always.box`
  - Strategy: Direct derivation or via P5 + duality
  - Complexity: Medium-High
  - Dependencies: TBD based on chosen approach

### Approach Options

**Option A: Via P5 + Duality**
1. P5 for `¬φ`: `◇▽¬φ → △◇¬φ`
2. Apply operator duality theorems
3. Contraposition

**Option B: Direct Derivation**
1. Use TF: `□φ → F□φ` and TD to get temporal propagation
2. Key insight: If `□φ` holds at any time, it holds at all times (S5 time-invariance)
3. Lift to `▽□φ → △□φ` then necessitate

### Implementation (Option B sketch)
```lean
/--
P6: `▽□φ → □△φ` (occurrent necessity is perpetual)

If necessity occurs at some time, then it's always necessary.

**Derivation Strategy** (Direct):
1. From TF: `□φ → G□φ` (necessity persists to future)
2. From TD of TF: `□φ → H□φ` (necessity extends to past)
3. From MT: `□φ → φ`
4. Combine: `□φ → △□φ`
5. Use S5 property: modal facts are time-invariant within a history
6. Therefore: `▽□φ → △□φ`
7. Necessitate appropriately to get: `▽□φ → □△φ`
-/
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  sorry -- Complex derivation TBD
```

### Success Criteria
- [ ] Theorem compiles without sorry
- [ ] Remove `axiom perpetuity_6` declaration
- [ ] Existing tests still pass

### Location
Replace axiom at line 926

---

## Phase 7: Documentation and Tests [NOT STARTED]

### Description
Update documentation and add tests for new theorems.

### Tasks
- [ ] Update Perpetuity.lean module docstring
- [ ] Update Summary section in Perpetuity.lean
- [ ] Update IMPLEMENTATION_STATUS.md
- [ ] Update SORRY_REGISTRY.md
- [ ] Update TODO.md (Task 18, Task 19)
- [ ] Add tests in PerpetuityTest.lean for:
  - [ ] diamond_4
  - [ ] modal_5
  - [ ] temp_k_dist_future
  - [ ] temp_k_dist_past

### Success Criteria
- [ ] `lake build` succeeds
- [ ] `lake test` passes
- [ ] `lake lint` shows no new warnings
- [ ] Documentation accurately reflects implementation status

---

## Risk Assessment

### High Risk Items
1. **Phase 3 (Temporal K Distribution)**: May require alternative approaches
   - Mitigation: Can attempt direct proof from TK rule structure, or prove temp distribution from box distribution via temporal-modal interaction

2. **Phase 6 (P6)**: Complex derivation, may need alternative strategy
   - Mitigation: Detailed Option A vs Option B analysis in implementation

### Medium Risk Items
1. **Formula structure matching**: Need to verify definitional equalities
   - Mitigation: Use `simp` lemmas for formula normalization

2. **Proof length**: Some proofs may be longer than estimated
   - Mitigation: Build incrementally, test each theorem

### Low Risk Items
1. **Phase 1, 2, 5**: Standard S5 derivations, well-understood
2. **Phase 7**: Documentation updates are straightforward

## Estimated Total Effort

| Phase | Estimated Hours | Risk |
|-------|-----------------|------|
| Phase 1: diamond_4 | 1-2 | Low |
| Phase 2: modal_5 | 1-2 | Low |
| Phase 3: Temporal K dist | 2-3 | High |
| Phase 4: persistence | 2-3 | Medium |
| Phase 5: P5 | 0.5-1 | Low |
| Phase 6: P6 | 2-3 | Medium-High |
| Phase 7: Documentation | 1-2 | Low |
| **Total** | **9.5-16** | Medium |

## Verification Commands

```bash
# After each phase:
lake build Logos.Core.Theorems.Perpetuity

# After all phases:
lake build
lake test
lake lint

# Check sorry count:
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
# Expected: 0

# Check axiom count:
grep -c "^axiom" Logos/Core/Theorems/Perpetuity.lean
# Expected: 2 (pairing, dni)
```
