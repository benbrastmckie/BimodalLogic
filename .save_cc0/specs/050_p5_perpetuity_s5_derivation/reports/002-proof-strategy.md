# Proof Strategy for P5 Perpetuity Theorem Derivation

## Executive Summary

This report details the complete proof strategy for deriving P5 (`◇▽φ → △◇φ`, persistent possibility) without adding new axioms. The key insight from the S5 analysis is that `◇φ → □◇φ` is derivable from existing TM axioms (MB, M4, MK), enabling completion of the persistence lemma.

## Current State Analysis

### P5 Blocking Issue (from Perpetuity.lean:799-859)

The persistence lemma `◇φ → △◇φ` is blocked at the step requiring `◇φ → □◇φ`:

```lean
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Has MB: φ → □◇φ
  -- Has TF: □◇φ → F□◇φ
  -- Has TD of TF: □◇φ → H□◇φ
  -- BLOCKED: Need ◇φ → □◇φ to connect the pieces
  sorry
```

### What We Have vs What We Need

**Available Theorems**:
- `mb_diamond`: `⊢ φ → □◇φ` (MB axiom)
- `box_diamond_to_future_box_diamond`: `⊢ □◇φ → F□◇φ` (TF on ◇φ)
- `box_diamond_to_past_box_diamond`: `⊢ □◇φ → H□◇φ` (TD of TF)
- `identity`: `⊢ □◇φ → □◇φ`
- `box_to_present`: `⊢ □◇φ → ◇φ` (MT on ◇φ)

**Missing Link**:
- `◇φ → □◇φ` (required to connect ◇φ to the box_diamond machinery)

## Derivation Strategy

### Phase 1: Derive Diamond-4 (◇◇φ → ◇φ)

**Goal**: `⊢ ◇◇φ → ◇φ`

**Strategy**: Contraposition of M4 on ¬φ

```
Step 1: M4 on ¬φ
  ⊢ □¬φ → □□¬φ

Step 2: Expand using diamond definition (◇ψ = ¬□¬ψ)
  ¬◇φ = □¬φ
  ¬◇◇φ = □¬◇φ = □□¬φ

Step 3: Rewrite step 1
  ⊢ ¬◇φ → ¬◇◇φ

Step 4: Contraposition
  ⊢ ◇◇φ → ◇φ
```

**Lean Implementation Sketch**:

```lean
theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond := by
  -- M4 for ¬φ: □(¬φ) → □□(¬φ)
  have m4_neg : ⊢ φ.neg.box.imp φ.neg.box.box :=
    Derivable.axiom [] _ (Axiom.modal_4 φ.neg)
  -- This is: ¬◇φ → ¬◇◇φ (by definition)
  -- diamond φ = φ.neg.box.neg, so neg(diamond φ) = φ.neg.box
  -- diamond (diamond φ) = (φ.neg.box.neg).neg.box.neg = φ.neg.box.box.neg
  -- So m4_neg is: φ.neg.box → φ.neg.box.box
  -- Which is: (diamond φ).neg → (diamond (diamond φ)).neg
  -- Contraposition gives: diamond (diamond φ) → diamond φ
  exact contraposition m4_neg
```

**Note**: The formula structure needs careful handling because:
- `φ.diamond = φ.neg.box.neg`
- `φ.diamond.neg = φ.neg.box.neg.neg = φ.neg.box` (by DNE)
- But we need to verify this definitional equality in Lean

### Phase 2: Derive Modal-5 (◇φ → □◇φ)

**Goal**: `⊢ ◇φ → □◇φ`

**Strategy**: MB on ◇φ composed with diamond_4 lifted to box

```
Step 1: MB instantiated on ◇φ
  ⊢ ◇φ → □◇◇φ

Step 2: Necessitate diamond_4
  ⊢ □(◇◇φ → ◇φ)

Step 3: Apply MK distribution
  ⊢ □◇◇φ → □◇φ

Step 4: Compose steps 1 and 3
  ⊢ ◇φ → □◇φ
```

**Lean Implementation Sketch**:

```lean
theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box := by
  -- Step 1: MB on ◇φ
  have mb_dia : ⊢ φ.diamond.imp φ.diamond.diamond.box :=
    mb_diamond φ.diamond

  -- Step 2: diamond_4 for φ
  have d4 : ⊢ φ.diamond.diamond.imp φ.diamond := diamond_4 φ

  -- Step 3: Necessitate d4
  have box_d4 : ⊢ (φ.diamond.diamond.imp φ.diamond).box :=
    Derivable.necessitation _ d4

  -- Step 4: MK distribution
  have mk : ⊢ (φ.diamond.diamond.imp φ.diamond).box.imp
               (φ.diamond.diamond.box.imp φ.diamond.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist φ.diamond.diamond φ.diamond)

  -- Step 5: Apply MK
  have d4_box : ⊢ φ.diamond.diamond.box.imp φ.diamond.box :=
    Derivable.modus_ponens [] _ _ mk box_d4

  -- Step 6: Compose MB and lifted d4
  exact imp_trans mb_dia d4_box
```

### Phase 3: Complete Persistence Lemma

**Goal**: `⊢ ◇φ → △◇φ` (where △◇φ = H◇φ ∧ ◇φ ∧ G◇φ)

**Strategy**: Use modal_5 to bridge from ◇φ to the existing □◇φ machinery

```
Step 1: modal_5 gives us the bridge
  ⊢ ◇φ → □◇φ

Step 2: Past component via TD
  ⊢ □◇φ → H□◇φ   (already proved as box_diamond_to_past_box_diamond)
  ⊢ □◇φ → H◇φ    (apply MT inside H)

Step 3: Present component
  ⊢ □◇φ → ◇φ     (MT on ◇φ)

Step 4: Future component via TF
  ⊢ □◇φ → F□◇φ   (already proved as box_diamond_to_future_box_diamond)
  ⊢ □◇φ → F◇φ    (apply MT inside F)

Step 5: Combine components
  From ⊢ ◇φ → □◇φ and steps 2-4:
  ⊢ ◇φ → H◇φ ∧ ◇φ ∧ G◇φ = △◇φ
```

**Critical Sub-lemmas Needed**:

1. `box_to_past_point`: `⊢ □Hψ → Hψ` (MT on Hψ - already have as special case)
2. `hbox_to_hdiamond`: `⊢ H□◇φ → H◇φ` (push MT inside H)
3. `gbox_to_gdiamond`: `⊢ G□◇φ → G◇φ` (push MT inside G)

**Sub-lemma Derivations**:

For `H□◇φ → H◇φ`:
```
1. MT on ◇φ: ⊢ □◇φ → ◇φ
2. Necessitate: ⊢ □(□◇φ → ◇φ)  -- Wait, we need temporal necessitation
```

**Issue**: We need a temporal version of necessitation or K rule to push implications inside H.

The temporal K rule (TK) gives us:
- If `GΓ ⊢ φ` then `Γ ⊢ Gφ`

We need the analogous temporal distribution axiom for H and G.

**Alternative Approach**: Use the axiom system's temporal K inference rule

Actually, looking at the derivation more carefully:

We have `⊢ □◇φ → ◇φ` (MT). To get `⊢ H□◇φ → H◇φ`, we need to "map" this implication over H.

This requires the **temporal distribution property**:
- `H(A → B) → (HA → HB)`

Is this derivable? Let's check:
- TK rule: If `GΓ ⊢ φ` then `Γ ⊢ Gφ`
- By temporal duality: If `HΓ ⊢ φ` then `Γ ⊢ Hφ`

So we can derive `⊢ H(A → B) → (HA → HB)` similarly to how MK distribution is derived from MK rule.

### Phase 4: Derive P5 from P4 + Persistence

**Goal**: `⊢ ◇▽φ → △◇φ`

**Strategy**: Transitivity of P4 and persistence

```
1. P4: ⊢ ◇▽φ → ◇φ (already proven)
2. Persistence: ⊢ ◇φ → △◇φ (from Phase 3)
3. Compose: ⊢ ◇▽φ → △◇φ
```

**Lean Implementation**:

```lean
theorem perpetuity_5_derived (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  have p4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ
  have pers : ⊢ φ.diamond.imp φ.diamond.always := persistence φ
  exact imp_trans p4 pers
```

### Phase 5: Derive P6 from P5 (or directly)

**Goal**: `⊢ ▽□φ → □△φ`

**Strategy 1**: Via P5 and duality (requires operator duality theorems)

**Strategy 2**: Direct derivation using TF and modal_5 pattern

The direct approach mirrors the P5 derivation but for boxed formulas:

```
1. From ⊢ □φ, using TF: ⊢ □φ → G□φ
2. From ⊢ □φ, using TD of TF: ⊢ □φ → H□φ
3. Combine: ⊢ □φ → H□φ ∧ □φ ∧ G□φ = △□φ
4. Necessitate: ⊢ □(□φ → △□φ)
5. Apply MK to ▽□φ to lift to ⊢ □▽□φ → □△□φ -- This doesn't work directly
```

**Alternative Direct Strategy**:

Start from the semantic meaning: If `▽□φ` holds at (M,τ,t), then at some time s, `□φ` holds at (M,τ,s). By TF, `□φ` holds at all times after s. By TD of TF, `□φ` holds at all times before s. Together, `□φ` holds at all times, hence `△□φ`. By S5, if `□φ` holds at one time in τ, it holds at all times (since □ doesn't depend on time within a fixed history).

**Key Insight**: The modal operator □ quantifies over world histories at a fixed time, but the task frame structure (nullity + compositionality) makes necessity time-independent within a history.

The derivation needs:
1. If `□φ` at time s, then `□φ` at time t for any t (modal facts are time-invariant in TM)
2. This follows from MF + temporal reasoning

I'll defer the detailed P6 derivation to the implementation plan, as it may require additional helper lemmas about the time-invariance of modal facts.

## Dependency Graph

```
M4 (axiom)
    |
    v
diamond_4: ◇◇φ → ◇φ
    |
    v
MB (axiom) -+
            |
            v
    modal_5: ◇φ → □◇φ
            |
            v
TF (axiom) + TD (rule)
            |
            v
    persistence: ◇φ → △◇φ
            |
            v
P4 (theorem) -+
              |
              v
      P5: ◇▽φ → △◇φ
              |
              v (with additional lemmas)
      P6: ▽□φ → □△φ
```

## Implementation Complexity Estimates

| Theorem | Estimated LOC | Difficulty |
|---------|---------------|------------|
| diamond_4 | 15-25 | Medium |
| modal_5 | 20-30 | Medium |
| temporal_k_dist_past | 15-20 | Medium |
| temporal_k_dist_future | 15-20 | Medium |
| persistence | 40-60 | High |
| P5 (derived) | 5-10 | Low |
| P6 (derived) | 30-50 | Medium-High |

**Total Estimate**: 140-215 lines of new proof code

## Risk Assessment

### Low Risk
- diamond_4: Standard S5 derivation, well-understood
- modal_5: Follows directly from diamond_4 + MB + MK

### Medium Risk
- Temporal K distribution lemmas: May require careful handling of temporal duality
- persistence: Many components to compose, but individual pieces are available

### Higher Risk
- P6: May require additional helper lemmas about time-invariance of modal facts
- Formula structure: Need to verify definitional equalities (◇◇φ = φ.diamond.diamond)

## Success Criteria

1. `diamond_4` compiles with zero sorry
2. `modal_5` compiles with zero sorry
3. `persistence` compiles with zero sorry (removes current 1 sorry)
4. P5 changes from axiom to theorem with zero sorry
5. P6 changes from axiom to theorem with zero sorry
6. `lake build` succeeds
7. Existing tests pass
8. Total axiom count decreases by 2 (perpetuity_5, perpetuity_6)

## Summary

The P5 perpetuity theorem can be derived **without adding new axioms** by:

1. Deriving `diamond_4` from M4 via contraposition
2. Deriving `modal_5` from MB + diamond_4 + MK distribution
3. Using `modal_5` to complete the persistence lemma
4. Composing P4 with persistence to get P5
5. Using P5 (or direct reasoning) to derive P6

This maintains the minimal axiom philosophy of the Logos project.
