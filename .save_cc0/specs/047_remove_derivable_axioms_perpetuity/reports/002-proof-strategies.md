# Proof Strategies Research: Remove Derivable Axioms from Perpetuity.lean

## Research Summary

This report documents detailed proof strategies for each theorem to be derived, including tactic sequences and complexity estimates.

## 1. Contraposition Proof Strategy

### 1.1 Current State

```lean
-- Line 284-306 in Perpetuity.lean
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  sorry
```

### 1.2 Mathematical Analysis

**Goal**: Given `⊢ A → B`, derive `⊢ (B → ⊥) → (A → ⊥)`

**Key insight**: This is the B combinator (composition) applied to bottom:
- B combinator: `(B → C) → (A → B) → (A → C)`
- With C = ⊥: `(B → ⊥) → (A → B) → (A → ⊥)`

### 1.3 Derivation from K and S

The B combinator can be derived:

```
1. K axiom: X → Y → X
2. S axiom: (X → Y → Z) → (X → Y) → X → Z

B combinator = S(KS)K

Detailed construction:
- KS : K applied to S = (B → C) → (A → (B → C))
- S(KS) : S applied to KS = ((B → C) → (A → (B → C))) → ((B → C) → (A → B)) → (B → C) → (A → B)
  Wait, this is getting complex...
```

**Alternative approach**: Direct proof using implication chaining

```lean
-- From A → B, we want (B → ⊥) → (A → ⊥)
-- This is: (B.neg) → A.neg

-- Proof:
-- 1. Assume B.neg (i.e., B → ⊥)
-- 2. Assume A
-- 3. From A and A → B, get B (modus ponens)
-- 4. From B and B → ⊥, get ⊥ (modus ponens)
-- 5. By discharging assumptions: (B → ⊥) → (A → ⊥)
```

The challenge is encoding this in the TM derivation system which doesn't have direct assumption discharge.

### 1.4 Implementable Strategy

Using S and K axioms directly:

```lean
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- B.neg = B.imp bot
  -- A.neg = A.imp bot
  -- Goal: (B → ⊥) → (A → ⊥)

  -- Step 1: Build (A → B) → (B → ⊥) → (A → ⊥)
  -- This is the permuted B combinator

  -- From S: (X → Y → Z) → (X → Y) → (X → Z)
  -- Let X = A, Y = B, Z = ⊥
  -- S gives: (A → B → ⊥) → (A → B) → (A → ⊥)

  have s_inst : ⊢ (A.imp (B.imp Formula.bot)).imp ((A.imp B).imp (A.imp Formula.bot)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B Formula.bot)

  -- Step 2: Build A → B → ⊥ from B → ⊥
  -- From K: X → Y → X
  -- Let X = B → ⊥, Y = A
  -- K gives: (B → ⊥) → A → (B → ⊥)

  have k_inst : ⊢ (B.imp Formula.bot).imp (A.imp (B.imp Formula.bot)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp Formula.bot) A)

  -- Step 3: Permutation to get (B → ⊥) → (A → B) → (A → ⊥)
  -- Compose k_inst and s_inst

  -- k_inst : (B → ⊥) → A → (B → ⊥)
  -- s_inst : (A → B → ⊥) → (A → B) → (A → ⊥)
  -- Need: (B → ⊥) → (A → B) → (A → ⊥)

  -- Use imp_trans: (B → ⊥) → A → (B → ⊥) and then need something else...

  -- Actually the issue is that k_inst gives us A → (B → ⊥), not A → B → ⊥
  -- These are different: A → (B → ⊥) vs (A → B) → ⊥

  -- Let me reconsider...
  sorry
```

### 1.5 Correct Strategy Using B Combinator

The B combinator `(B → C) → (A → B) → (A → C)` derivation from S and K:

```lean
-- B = S(KS)K in combinator notation
-- In typed lambda calculus:
-- B f g x = f (g x)

-- Derivation:
-- 1. K : α → β → α
-- 2. S : (α → β → γ) → (α → β) → α → γ
-- 3. KS : instantiate K with α = (β → γ → δ) → (β → γ) → β → δ
--         KS : ((β → γ → δ) → (β → γ) → β → δ) → X → ((β → γ → δ) → (β → γ) → β → δ)
-- ... this is getting very complex
```

**Recommended approach**: Derive B combinator as a separate helper lemma, then apply.

### 1.6 Complexity Estimate

- **Without B combinator helper**: 20-40 lines, high complexity
- **With B combinator helper**: 10-15 lines for B combinator, 5-10 lines for contraposition
- **Total effort**: 4-6 hours (including debugging)

## 2. P4 Derivation Strategy

### 2.1 Target

```lean
-- Replace axiom perpetuity_4 (line 501)
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond
```

### 2.2 Formula Expansion

```lean
-- φ.sometimes = φ.neg.always.neg
-- φ.sometimes.diamond = (φ.neg.always.neg).diamond = (φ.neg.always.neg).neg.box.neg
-- φ.diamond = φ.neg.box.neg

-- Simplify φ.sometimes.diamond:
-- = (φ.neg.always.neg).neg.box.neg
-- = φ.neg.always.neg.neg.box.neg

-- With double negation elimination (DNE):
-- φ.neg.always.neg.neg = φ.neg.always (modulo formula equality)
-- So φ.sometimes.diamond = φ.neg.always.box.neg
```

### 2.3 Proof Strategy

```lean
theorem perpetuity_4 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := by
  -- Strategy: Contrapose P3 applied to ¬φ

  -- P3(¬φ): □(¬φ) → □△(¬φ)
  have p3_neg : ⊢ φ.neg.box.imp φ.neg.always.box := perpetuity_3 φ.neg

  -- Contrapose: ¬□△(¬φ) → ¬□(¬φ)
  have contra : ⊢ φ.neg.always.box.neg.imp φ.neg.box.neg := contraposition p3_neg

  -- Now: φ.neg.always.box.neg = φ.neg.always.neg.neg.box.neg = φ.sometimes.diamond
  -- And: φ.neg.box.neg = φ.diamond

  -- The issue: formula equality
  -- Need to show φ.neg.always.box.neg = φ.sometimes.diamond

  -- φ.sometimes.diamond
  -- = (φ.neg.always.neg).diamond
  -- = (φ.neg.always.neg).neg.box.neg
  -- ≠ φ.neg.always.box.neg (extra double negation)

  -- Solution: Use DNE axiom to bridge the gap
  -- Need: ⊢ φ.neg.always.neg.neg.box.neg.imp φ.neg.always.box.neg
  --       and
  --       ⊢ φ.neg.always.box.neg.imp φ.neg.always.neg.neg.box.neg

  sorry
```

### 2.4 DNE Bridge Lemma

```lean
-- Bridge lemma: Connect double-negated formula to original
theorem dne_box_neg {A : Formula} : ⊢ A.neg.neg.box.neg.imp A.box.neg := by
  -- From DNE: ¬¬A → A
  have dne : ⊢ A.neg.neg.imp A := Derivable.axiom [] _ (Axiom.double_negation A)

  -- Contrapose: ¬A → ¬¬¬A (but this doesn't help directly)

  -- Alternative: Use modal K distribution
  -- □(¬¬A → A) gives □(¬¬A) → □A via modal K
  -- Then contrapose: ¬□A → ¬□(¬¬A)

  sorry
```

### 2.5 Complexity Estimate

- **Formula manipulation**: Complex - need to handle double negation at formula level
- **May require**: Simp lemmas for `Formula.neg.neg = Formula` (not definitionally equal)
- **Total effort**: 4-6 hours

## 3. P5 Derivation Strategy

### 3.1 Target

```lean
-- Replace axiom perpetuity_5 (line 541)
theorem perpetuity_5 (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always
```

### 3.2 Proof Outline

P5 follows from P4 and a persistence lemma:

```lean
-- P4: ◇▽φ → ◇φ
-- Persistence: ◇φ → △◇φ
-- P5 = imp_trans P4 persistence
```

### 3.3 Persistence Lemma Strategy

```lean
theorem persistence (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.always := by
  -- Goal: ◇φ → △◇φ where △ψ = Hψ ∧ ψ ∧ Gψ

  -- Step 1: Use MB axiom
  -- MB: ψ → □◇ψ
  -- For ψ = φ: φ → □◇φ
  have mb : ⊢ φ.imp φ.diamond.box := Derivable.axiom [] _ (Axiom.modal_b φ)

  -- Step 2: From □◇φ derive the temporal components
  -- Using MF and temporal duality on ◇φ

  -- MF(◇φ): □◇φ → □G◇φ
  have mf_diamond : ⊢ φ.diamond.box.imp φ.diamond.all_future.box :=
    Derivable.axiom [] _ (Axiom.modal_future φ.diamond)

  -- MT(□G◇φ): □G◇φ → G◇φ
  have mt_future : ⊢ φ.diamond.all_future.box.imp φ.diamond.all_future :=
    Derivable.axiom [] _ (Axiom.modal_t φ.diamond.all_future)

  -- Compose: □◇φ → G◇φ
  have box_to_g : ⊢ φ.diamond.box.imp φ.diamond.all_future :=
    imp_trans mf_diamond mt_future

  -- Similarly for H◇φ via temporal duality
  -- box_to_h : ⊢ φ.diamond.box.imp φ.diamond.all_past

  -- Step 3: Need to lift from φ → □◇φ to ◇φ → △◇φ
  -- This is the hard part: lifting over ◇

  -- The paper says "by standard modal reasoning" but doesn't specify
  -- Key insight: ◇φ = ¬□¬φ
  -- If φ → □◇φ, we need ◇φ → △◇φ

  -- From φ → □◇φ, can we get ◇φ → □◇◇φ? Not directly.
  -- The issue is that ◇ doesn't preserve implications the same way □ does

  sorry
```

### 3.4 Alternative P5 Strategy

Direct proof using axiom interactions:

```lean
-- Alternative: Build △◇φ directly from ◇▽φ components
-- Use the fact that ◇ distributes over ∨ in classical logic
-- And △ relates to ∧ of temporal operators

-- This approach may be more tractable than the persistence lemma route
```

### 3.5 Complexity Estimate

- **Persistence lemma**: Very complex - modal lifting over ◇ is non-trivial
- **Alternative approaches**: May require additional axioms or lemmas
- **Total effort**: 6-10 hours

## 4. P6 Derivation Strategy

### 4.1 Target

```lean
-- Replace axiom perpetuity_6 (line 582)
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box
```

### 4.2 Duality with P5

P6 is "equivalent" to P5 according to the paper. The duality:

- P5: `◇▽φ → △◇φ`
- P6: `▽□φ → □△φ`

These are related by operator swapping:
- `◇` ↔ `▽` (possibility ↔ sometimes)
- `□` ↔ `△` (necessity ↔ always)

### 4.3 Proof Strategy via Contraposition

```lean
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := by
  -- Strategy: Use P5 on ¬φ and contrapose with duality

  -- P5(¬φ): ◇▽(¬φ) → △◇(¬φ)
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always := perpetuity_5 φ.neg

  -- Operator duality:
  -- ◇(¬φ) = ¬□φ
  -- ▽(¬φ) = sometimes(¬φ) = ¬△φ
  -- △◇(¬φ) = always(◇¬φ) = always(¬□φ)
  -- ◇▽(¬φ) = diamond(sometimes(¬φ)) = ◇(¬△φ)

  -- So P5(¬φ): ◇(¬△φ) → △(¬□φ)
  -- Contrapose: ¬△(¬□φ) → ¬◇(¬△φ)
  -- Which is: ▽(□φ) → □(△φ)

  -- Need to verify formula identities...
  sorry
```

### 4.4 Complexity Estimate

- **Formula duality**: Complex - need to track many negations
- **Depends on**: P5 being proven first
- **Total effort**: 4-6 hours (assuming P5 is complete)

## 5. Pairing Derivation (Optional)

### 5.1 Target

```lean
-- Replace axiom pairing (line 146)
theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

### 5.2 Strategy

The pairing combinator `λa.λb.λf. f a b` corresponds to:
```
S(S(KS)(S(KK)I))(KI) where I = SKK
```

This is a complex combinator construction.

### 5.3 Recommendation

- **Priority**: LOW
- **Complexity**: VERY HIGH
- **Recommendation**: Leave axiomatized for MVP

The pairing axiom is semantically justified and the combinator derivation would obscure the mathematical content without providing significant benefit.

## 6. Summary of Strategies

| Target | Strategy | Complexity | Hours |
|--------|----------|------------|-------|
| contraposition | B combinator from S/K | Medium-High | 4-6 |
| P4 | Contrapose P3 + DNE bridge | Medium | 4-6 |
| P5 | Persistence lemma or direct | High | 6-10 |
| P6 | P5 duality + contraposition | Medium | 4-6 |
| pairing | Combinator construction | Very High | 8+ |

**Total estimated effort**: 18-28 hours (excluding pairing)

## 7. Recommendations

1. **Start with contraposition**: Unblocks P4, and the B combinator is a useful helper
2. **Use DNE creatively**: Bridge lemmas for formula equivalences
3. **Document formula identities**: May need simp lemmas for automation
4. **Consider partial completion**: P4 may be achievable independently of P5/P6
5. **Leave pairing**: Semantic justification sufficient, derivation adds no value
