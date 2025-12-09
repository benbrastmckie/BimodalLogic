# Mathlib Theorems Research: Remove Derivable Axioms from Perpetuity.lean

## Research Summary

This report documents the relevant Mathlib theorems and Lean 4 patterns for deriving P4-P6 perpetuity principles and completing the `contraposition` proof.

## 1. Current State Analysis

### 1.1 Existing Axioms to Remove

From `Perpetuity.lean`, the following are currently axiomatized:

1. **`pairing`** (line 146): `⊢ A → B → A ∧ B`
   - Used by: `combine_imp_conj`, `combine_imp_conj_3`, `box_conj_intro`
   - Status: OPTIONAL - complex combinator derivation

2. **`perpetuity_4`** (line 501): `⊢ φ.sometimes.diamond.imp φ.diamond`
   - Derivation: Contraposition of P3 applied to `¬φ`

3. **`perpetuity_5`** (line 541): `⊢ φ.sometimes.diamond.imp φ.diamond.always`
   - Derivation: P4 composed with persistence lemma

4. **`perpetuity_6`** (line 582): `⊢ φ.box.sometimes.imp φ.always.box`
   - Derivation: P5 equivalence or temporal necessitation

### 1.2 Existing Sorry Markers

1. **`contraposition`** (line 306): `sorry`
   - Proof strategy: B combinator derivation from K and S

## 2. Mathlib Patterns for Propositional Reasoning

### 2.1 Combinator Derivations

The B combinator (composition) `(B → C) → (A → B) → (A → C)` can be derived from S and K:

```lean
-- B = S(KS)(K)
-- Where S = (P → Q → R) → (P → Q) → P → R
-- And K = A → B → A
```

For `contraposition {A B} (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg`:
- Goal: `(B → ⊥) → (A → ⊥)`
- This IS the B combinator with C = ⊥

### 2.2 Lean 4 Derivation Pattern

```lean
-- B combinator construction
-- b_combinator : ⊢ (B → C) → (A → B) → (A → C)
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) := by
  -- S(KS)(K)
  -- Step 1: K gives us (B → C) → A → (B → C)
  have ks : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)
  -- Step 2: Use K axiom distribution pattern
  -- Need: (A → (B → C)) → ((A → B) → (A → C))
  have k_dist : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  -- Step 3: Compose via imp_trans (already proven)
  exact imp_trans ks k_dist
```

This derivation is INCORRECT - the B combinator requires a different construction.

### 2.3 Correct B Combinator Derivation

The actual derivation requires S combinator application:

```lean
-- Correct B combinator: (B → C) → (A → B) → (A → C)
-- This is derivable from K and S axioms
--
-- Proof outline:
-- 1. From K: (B → C) → A → (B → C)                    [K instantiation]
-- 2. From K: (A → (B → C)) → ((A → B) → (A → C))      [distribution]
-- 3. Compose 1 and 2 via modus ponens
```

## 3. Formula Structure for P4-P6

### 3.1 Key Definitions

```lean
-- From Formula.lean:
def sometimes (φ : Formula) : Formula := φ.neg.always.neg
def diamond (φ : Formula) : Formula := φ.neg.box.neg
def always (φ : Formula) : Formula := φ.all_past.and (φ.and φ.all_future)
```

### 3.2 P4 Formula Expansion

```lean
-- φ.sometimes.diamond
-- = (φ.neg.always.neg).diamond
-- = (φ.neg.always.neg).neg.box.neg
-- = φ.neg.always.neg.neg.box.neg
--
-- φ.diamond
-- = φ.neg.box.neg
```

**Key observation**: P4 has nested double negation `φ.neg.always.neg.neg` that must reduce to `φ.neg.always` via DNE.

### 3.3 P5 and P6 Operator Interactions

P5: `◇▽φ → △◇φ`
- Requires proving `◇φ → △◇φ` (persistence lemma)
- Uses MB axiom: `φ → □◇φ`

P6: `▽□φ → □△φ`
- Either via P5 equivalence or temporal necessitation

## 4. Derivation Strategies

### 4.1 Phase 1: Complete `contraposition` proof

**Strategy**: Derive B combinator from K and S, apply to `h : ⊢ A.imp B`

```lean
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- B combinator: (B → ⊥) → (A → B) → (A → ⊥)
  -- We need: (B.neg) → (A → B) → (A.neg)
  -- Which is: (B → ⊥) → (A → B) → (A → ⊥)
  -- This IS composition with C = ⊥

  -- Build: ⊢ (B → ⊥) → ((A → B) → (A → ⊥))
  -- Then apply to h : ⊢ A → B

  have b_comb : ⊢ B.neg.imp ((A.imp B).imp A.neg) := by
    -- Construction from K and S
    sorry  -- Detailed in Phase 1 implementation

  -- Apply: from B.neg → (A.imp B).imp A.neg and A.imp B, get B.neg → A.neg
  have h1 : ⊢ (A.imp B).imp A.neg.imp (B.neg.imp A.neg) := by
    -- Permutation via S
    sorry

  exact Derivable.modus_ponens [] _ _ h1 h
```

### 4.2 Phase 2: Derive P4 from P3

```lean
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- P3 for ¬φ: □(¬φ) → □△(¬φ)
  have p3_neg : ⊢ φ.neg.box.imp φ.neg.always.box := perpetuity_3 φ.neg

  -- Contrapose: ¬□△(¬φ) → ¬□(¬φ)
  have contra : ⊢ φ.neg.always.box.neg.imp φ.neg.box.neg := contraposition p3_neg

  -- Now we need to show:
  -- φ.sometimes.diamond = (φ.neg.always.neg).neg.box.neg = φ.neg.always.box.neg
  -- This requires double negation: φ.neg.always.neg.neg = φ.neg.always

  -- Use DNE axiom to handle double negation in formula type
  sorry  -- Requires formula identity or simp lemma
```

### 4.3 Phase 3: Derive P5 from P4

```lean
-- First: persistence lemma
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- MB: φ → □◇φ
  have mb : ⊢ φ.imp φ.diamond.box := Derivable.axiom [] _ (Axiom.modal_b φ)
  -- From φ → □◇φ, we need ◇φ → △◇φ
  -- This requires modal lifting: if φ → □ψ then ◇φ → □◇ψ
  sorry  -- Complex modal-temporal interaction

theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := by
  -- P4: ◇▽φ → ◇φ
  have p4 : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ
  -- Persistence: ◇φ → △◇φ
  have pers : ⊢ φ.diamond.imp φ.diamond.always := persistence φ
  -- Compose via imp_trans
  exact imp_trans p4 pers
```

### 4.4 Phase 4: Derive P6 from P5

```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- P5 for ¬φ: ◇▽(¬φ) → △◇(¬φ)
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always := perpetuity_5 φ.neg

  -- By operator duality:
  -- ▽□φ = ¬△¬(□φ) = ¬△(◇(¬φ)) [since ◇ψ = ¬□¬ψ]
  -- □△φ = □¬▽¬φ

  -- Contrapose P5 for ¬φ and apply duality
  sorry  -- Complex operator duality manipulation
```

## 5. Key Findings

### Finding 1: B Combinator is Derivable
The B combinator `(B → C) → (A → B) → (A → C)` can be derived from K and S axioms, enabling contraposition derivation.

### Finding 2: Double Negation Handling
P4 requires showing `φ.neg.always.neg.neg = φ.neg.always` at the formula level. This may need:
- A simp lemma for double negation reduction
- Or explicit DNE application within the derivation

### Finding 3: Persistence Lemma is Key
P5 depends on the persistence lemma `◇φ → △◇φ`, which requires MB axiom and modal lifting.

### Finding 4: Pairing Can Remain Axiomatized
The `pairing` axiom is complex to derive from K and S (requires S(S(KS)(S(KK)I))(KI) construction). For MVP, it can remain axiomatized with semantic justification.

## 6. Recommendations

1. **Priority**: Complete `contraposition` first (unblocks P2, P4)
2. **Formula Identity**: May need simp lemmas for formula equivalences
3. **Incremental Approach**: Prove P4, then P5, then P6 sequentially
4. **Pairing**: Leave axiomatized unless specifically needed for zero-axiom goal
