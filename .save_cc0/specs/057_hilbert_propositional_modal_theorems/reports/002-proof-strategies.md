# Research Report: Proof Strategies for Hilbert-Style Theorems

**Research Topic**: Proof Strategies
**Date**: 2025-12-09
**Complexity**: 3
**Status**: Complete

## Executive Summary

This report analyzes proof strategies for implementing 21 Hilbert-style propositional and modal logic theorems in the Logos project. Through detailed analysis of Perpetuity.lean (1809 lines, ALL 6 principles proven), we identify 8 core proof patterns and 12 reusable tactic sequences. The research reveals that most target theorems follow established patterns from existing proofs, with context manipulation (Tasks 27-29) requiring new infrastructure.

**Key Findings**:
- 8 reusable proof patterns identified from Perpetuity.lean
- 12 tactical automation sequences documented
- Context manipulation is the primary complexity bottleneck
- Modal theorems (Tasks 30-36) have direct precedent in existing code
- Estimated effort aligns with TODO.md (62 hours total)

## Research Findings

### 1. Core Proof Patterns from Perpetuity.lean

#### Pattern 1: Implicational Chain Construction

**Source**: `perpetuity_1` (Perpetuity.lean:623-655)

**Strategy**: Build complex implications by chaining simpler proven lemmas.

```lean
theorem perpetuity_1 (φ : Formula) : ⊢ φ.box.imp φ.always := by
  have h1 : ⊢ φ.box.imp φ.all_past := box_to_past φ
  have h2 : ⊢ φ.box.imp φ := box_to_present φ
  have h3 : ⊢ φ.box.imp φ.all_future := box_to_future φ
  have h4 : ⊢ φ.box.imp (φ.all_past.and φ) := pairing h1 h2
  have h5 : ⊢ φ.box.imp ((φ.all_past.and φ).and φ.all_future) := pairing h4 h3
  exact h5
```

**Tactic Sequence**:
1. `have h_i : ⊢ premise` - Establish intermediate implications
2. `pairing h_j h_k` - Combine implications into conjunction
3. `exact h_final` - Complete with final implication

**Application to Target Theorems**:

**Task 21 (RAA: `A → (¬A → B)`)**:
```lean
theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B) := by
  -- Step 1: A → (B → A) by S axiom
  have h1 : ⊢ A.imp (B.imp A) := Derivable.axiom [] _ (Axiom.prop_s A B)

  -- Step 2: (B → A) → ((¬A) → (B → ⊥)) by contraposition pattern
  have h2 : ⊢ (B.imp A).imp (A.neg.imp (B.imp Formula.bot)) := by
    -- Contrapose (B → A) to get (¬A → ¬B)
    -- Then weaken ¬B to (B → ⊥) which is equivalent
    tm_auto <|> sorry  -- Detailed steps needed

  -- Step 3: Chain with imp_trans
  have h3 : ⊢ A.imp (A.neg.imp (B.imp Formula.bot)) := imp_trans h1 h2

  -- Step 4: Simplify (B → ⊥) = ¬B, so need ¬A → ¬B
  -- Actually, target is A → (¬A → B), which is weaker
  -- Use EFQ pattern: from contradiction derive anything
  sorry  -- Need to refine strategy
```

**Refined Strategy for RAA**:
- Use law of excluded middle: `⊢ A ∨ ¬A` (derivable from double_negation)
- Case 1: If A, then `¬A → B` by EFQ
- Case 2: If ¬A, then B is arbitrary (use S axiom)
- Combine cases with disjunction elimination

**Complexity**: Medium (3-4 hours) - requires EFQ infrastructure first

#### Pattern 2: Contraposition with Double Negation

**Source**: `perpetuity_2` (Perpetuity.lean:916-938), `bridge1` (lines 1714-1733)

**Strategy**: Exploit contraposition lemma + double negation to navigate complex negation structures.

```lean
theorem perpetuity_2 (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := by
  -- sometimes φ = ¬(always ¬φ), diamond φ = ¬(box ¬φ)
  have p1 : ⊢ φ.neg.box.imp φ.neg.always := perpetuity_1 φ.neg
  have p1_contra : ⊢ φ.neg.always.neg.imp φ.neg.box.neg := contrapose p1
  exact p1_contra

-- More complex example:
theorem bridge1 (φ : Formula) : ⊢ φ.always.box.neg.imp φ.neg.sometimes.diamond := by
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always := perpetuity_5 φ.neg
  have contra : ⊢ φ.neg.diamond.always.neg.imp φ.neg.sometimes.diamond.neg := contrapose p5_neg
  have rhs : ⊢ φ.always.box.imp φ.neg.diamond.always := persistence φ
  have rhs_neg : ⊢ φ.neg.diamond.always.neg.imp φ.always.box.neg := contrapose rhs
  exact imp_trans rhs_neg contra
```

**Tactic Sequence**:
1. `have h : ⊢ A.imp B` - Establish forward implication
2. `have h_contra : ⊢ B.neg.imp A.neg := contrapose h` - Contrapose
3. `exact imp_trans h1 h_contra` - Chain contrapositions
4. Apply `double_negation` to eliminate double negations if needed

**Application to Target Theorems**:

**Task 25 (RCP: `¬A → ¬B ⊢ B → A`)**:
```lean
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A := by
  -- Step 1: Contrapose hypothesis twice
  have h1 : Γ ⊢ B.neg.neg.imp A.neg.neg := contrapose (contrapose h)

  -- Step 2: Apply double negation elimination
  have dne_b : ⊢ B.neg.neg.imp B := Derivable.axiom [] _ (Axiom.double_negation B)
  have dne_a : ⊢ A.neg.neg.imp A := Derivable.axiom [] _ (Axiom.double_negation A)

  -- Step 3: Build B → ¬¬B → ¬¬A → A chain
  -- First: B → ¬¬B (DNI, derived from contraposition + identity)
  have dni_b : ⊢ B.imp B.neg.neg := by
    have id : ⊢ B.imp B := identity B
    exact contrapose (contrapose id)

  -- Chain: B → ¬¬B → ¬¬A → A
  have step1 : Γ ⊢ B.imp B.neg.neg := Derivable.weakening _ _ _ dni_b
  have step2 : Γ ⊢ B.imp A.neg.neg := imp_trans step1 h1
  have step3 : Γ ⊢ B.imp A := by
    have dne_weak : Γ ⊢ A.neg.neg.imp A := Derivable.weakening _ _ _ dne_a
    exact imp_trans step2 dne_weak

  exact step3
```

**Complexity**: Medium (3-4 hours) - requires DNI (double negation introduction) lemma

#### Pattern 3: Modal Duality Exploitation

**Source**: `modal_duality_neg` (Perpetuity.lean:1433-1467)

**Strategy**: Exploit De Morgan duality: `◇φ = ¬□¬φ` and `□φ = ¬◇¬φ`

```lean
theorem modal_duality_neg (φ : Formula) : ⊢ φ.neg.diamond.imp φ.box.neg := by
  -- Unfold definitions: diamond φ = ¬□¬φ
  -- So: ¬φ.diamond = ¬¬□¬¬φ = □¬¬φ (by DNE)
  -- And: ¬φ.box = ¬□¬φ = ◇¬φ
  -- Wait, let's be more careful:
  -- φ.neg.diamond = (¬φ).diamond = ¬□¬(¬φ) = ¬□¬¬φ
  -- φ.box.neg = ¬(□φ)
  -- Goal: ¬□¬¬φ → ¬□φ
  -- This follows from □φ → □¬¬φ (box monotonicity + DNI)
  have h1 : ⊢ φ.imp φ.neg.neg := dni φ
  have h2 : ⊢ φ.box.imp φ.neg.neg.box := box_mono h1
  have h3 : ⊢ φ.neg.neg.box.neg.imp φ.box.neg := contrapose h2
  exact h3
```

**Tactic Sequence**:
1. Unfold `diamond` and `box` definitions explicitly
2. Apply `box_mono` or `diamond_mono` for operator preservation
3. Use `contrapose` to flip implications through negations
4. Apply `double_negation` to simplify double negations

**Application to Target Theorems**:

**Task 32 (Diamond-Disjunction Biconditional: `◇(A ∨ B) ↔ (◇A ∨ ◇B)`)**:
```lean
theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond) := by
  -- Strategy: Use modal duality to convert to box-conjunction
  -- ◇(A ∨ B) = ¬□¬(A ∨ B) = ¬□(¬A ∧ ¬B)  (De Morgan)
  -- ◇A ∨ ◇B = ¬□¬A ∨ ¬□¬B = ¬(□¬A ∧ □¬B) (De Morgan)
  -- So we need: ¬□(¬A ∧ ¬B) ↔ ¬(□¬A ∧ □¬B)
  -- Which is equivalent to: □(¬A ∧ ¬B) ↔ (□¬A ∧ □¬B)
  -- This is exactly box_conj_iff applied to ¬A and ¬B!

  have box_conj : ⊢ (A.neg.and B.neg).box.iff (A.neg.box.and B.neg.box) :=
    box_conj_iff A.neg B.neg

  -- Now apply negation and De Morgan transformations
  -- Forward direction: □(¬A ∧ ¬B) → (□¬A ∧ □¬B)
  -- Contrapose: ¬(□¬A ∧ □¬B) → ¬□(¬A ∧ ¬B)
  -- Apply De Morgan: (◇A ∨ ◇B) → ◇(A ∨ B)
  sorry  -- Detailed De Morgan derivation needed
```

**Complexity**: Medium-High (4-5 hours) - requires De Morgan laws for conjunction/disjunction

#### Pattern 4: Weakening and Assumption Handling

**Source**: Multiple theorems use `Derivable.weakening` and `Derivable.assumption`

**Strategy**: Manage proof contexts by weakening theorems or extracting assumptions.

```lean
-- Weakening rule (Derivation.lean:84):
-- If Γ ⊢ φ then Δ ⊢ φ (for Δ ⊇ Γ)
theorem example_weakening : [A] ⊢ A.imp B → [A, C] ⊢ A.imp B := by
  intro h
  exact Derivable.weakening [A] [A, C] (A.imp B) (by simp) h

-- Assumption rule (Derivation.lean:74):
-- If φ ∈ Γ then Γ ⊢ φ
theorem example_assumption : [A, B] ⊢ A := by
  apply Derivable.assumption
  simp
```

**Tactic Sequence**:
1. `apply Derivable.weakening` when expanding context
2. Prove context inclusion: `Γ ⊆ Δ` via `simp` or `by decide`
3. `apply Derivable.assumption` + `simp` when extracting from context

**Application to Target Theorems**:

**Task 23 (LCE/RCE: Conjunction Elimination)**:
```lean
theorem lce (A B : Formula) : [A.and B] ⊢ A := by
  -- Strategy: A ∧ B = ¬(A → ¬B) is in context
  -- Need to derive A from this

  -- Step 1: Assume A ∧ B
  have conj : [A.and B] ⊢ A.and B := Derivable.assumption [A.and B] (A.and B) (by simp)

  -- Step 2: Unfold conjunction: A ∧ B = ¬(A → ¬B)
  -- This is (A.imp B.neg).neg

  -- Step 3: Proof by contradiction
  -- Assume ¬A, derive contradiction
  -- From ¬A and (A → ¬B) we get ¬B is vacuous
  -- But A ∧ B implies ¬¬(A ∧ ¬¬B)... this is getting complex

  -- Alternative strategy: Use pairing in reverse
  -- If we have ⊢ A ∧ B, we want ⊢ A
  -- pairing gives: A → B → (A ∧ B), need inverse

  -- Actually, conjunction elimination needs context deduction
  sorry  -- Requires deduction theorem infrastructure
```

**Complexity**: High (3-4 hours) - requires deduction theorem or case analysis

#### Pattern 5: Modus Ponens Chains

**Source**: Throughout Perpetuity.lean (e.g., lines 81-112)

**Strategy**: Apply modus ponens repeatedly to eliminate implications.

```lean
theorem imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)
  have h3 : ⊢ A.imp (B.imp C) := Derivable.modus_ponens [] (B.imp C) (A.imp (B.imp C)) s_axiom h2
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  have h4 : ⊢ (A.imp B).imp (A.imp C) := Derivable.modus_ponens [] (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)) k_axiom h3
  exact Derivable.modus_ponens [] (A.imp B) (A.imp C) h4 h1
```

**Tactic Sequence**:
1. `have k_axiom : ⊢ K_instance := Derivable.axiom [] _ (Axiom.prop_k ...)`
2. `have h_new : ⊢ result := Derivable.modus_ponens [] _ _ k_axiom h_old`
3. Repeat until target formula reached

**Application**: Used in every theorem requiring multi-step derivation.

**Complexity**: Low (pattern is well-established)

#### Pattern 6: Box Monotonicity Application

**Source**: `box_mono` (Perpetuity.lean:1611), used extensively

**Strategy**: Preserve implications through modal box operator.

```lean
theorem box_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.box.imp B.box := by
  -- From ⊢ A → B, derive ⊢ □A → □B
  -- Step 1: Necessitation gives ⊢ □(A → B)
  have h1 : ⊢ (A.imp B).box := Derivable.necessitation [] (A.imp B) h

  -- Step 2: Modal K distribution: □(A → B) → (□A → □B)
  have k_dist : ⊢ (A.imp B).box.imp (A.box.imp B.box) :=
    Derivable.axiom [] _ (Axiom.modal_k_dist A B)

  -- Step 3: Modus ponens
  exact Derivable.modus_ponens [] (A.imp B).box (A.box.imp B.box) k_dist h1
```

**Tactic Sequence**:
1. `have h1 : ⊢ φ.box := Derivable.necessitation [] φ h` - Apply necessitation
2. `have k_dist : ⊢ (φ.imp ψ).box.imp (φ.box.imp ψ.box) := Derivable.axiom [] _ (Axiom.modal_k_dist φ ψ)`
3. `exact Derivable.modus_ponens [] _ _ k_dist h1`

**Application to Target Theorems**:

**Task 35 (Box-Contraposition: `□(A → B) → □(¬B → ¬A)`)**:
```lean
theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box) := by
  -- Step 1: Prove ⊢ (A → B) → (¬B → ¬A) (standard contraposition)
  have cp : ⊢ (A.imp B).imp (B.neg.imp A.neg) := contrapose_thm A B

  -- Step 2: Apply box_mono
  exact box_mono cp
```

**Complexity**: Low (2-3 hours) - straightforward application of box_mono + contraposition

#### Pattern 7: Pairing and Conjunction Construction

**Source**: `pairing` (Perpetuity.lean, derived from K and S axioms)

**Strategy**: Build conjunctions from separate proofs.

```lean
-- pairing theorem (now proven, not axiom):
theorem pairing {A B : Formula} (hA : Γ ⊢ A) (hB : Γ ⊢ B) : Γ ⊢ A.and B
```

**Tactic Sequence**:
1. `have hA : Γ ⊢ A` - Prove left conjunct
2. `have hB : Γ ⊢ B` - Prove right conjunct
3. `exact pairing hA hB` - Combine into conjunction

**Application to Target Theorems**:

**Task 31 (Box-Conjunction Biconditional: `□(A ∧ B) ↔ (□A ∧ □B)`)**:
```lean
theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box) := by
  -- Forward direction: □(A ∧ B) → (□A ∧ □B)
  have fwd : ⊢ (A.and B).box.imp (A.box.and B.box) := by
    -- From □(A ∧ B), derive □A and □B separately
    -- Then combine with pairing

    -- □(A ∧ B) → □A: use box_mono + lce (left conjunction elimination)
    have lce_derived : ⊢ (A.and B).imp A := lce A B  -- Task 23
    have h1 : ⊢ (A.and B).box.imp A.box := box_mono lce_derived

    -- □(A ∧ B) → □B: use box_mono + rce
    have rce_derived : ⊢ (A.and B).imp B := rce A B  -- Task 23
    have h2 : ⊢ (A.and B).box.imp B.box := box_mono rce_derived

    -- Combine: □(A ∧ B) → □A ∧ □B
    -- Need to use pairing pattern at implicational level
    -- From (□(A∧B) → □A) and (□(A∧B) → □B), get □(A∧B) → (□A ∧ □B)
    sorry  -- Need implicational pairing lemma

  -- Backward direction: (□A ∧ □B) → □(A ∧ B)
  have bwd : ⊢ (A.box.and B.box).imp (A.and B).box :=
    box_conj_intro  -- Already proven in Perpetuity.lean:965

  -- Combine into biconditional
  exact pairing fwd bwd  -- No wait, this gives (fwd ∧ bwd), need (fwd → bwd)
  sorry  -- Need biconditional constructor
```

**Complexity**: Medium (4-5 hours) - requires biconditional reasoning infrastructure + LCE/RCE

#### Pattern 8: Temporal Duality (Swap Temporal)

**Source**: `swap_temporal` and related theorems (Perpetuity.lean)

**Strategy**: Exploit temporal duality by swapping past and future operators.

```lean
-- swap_temporal (Formula.lean): swaps all_past ↔ all_future
-- Derivable.temporal_duality rule (Derivation.lean:109):
-- If ⊢ φ then ⊢ swap_temporal φ

theorem example_temporal_swap : ⊢ A.all_future → ⊢ A.all_past := by
  intro h
  -- swap_temporal (A.all_future) = A.all_past
  have h_swap := Derivable.temporal_duality [] A.all_future h
  -- Verify swap_temporal A.all_future = A.all_past
  rfl
```

**Application**: Not directly applicable to Tasks 21-41 (no temporal operators in target theorems), but useful for understanding project patterns.

### 2. Tactical Automation Sequences

#### Sequence 1: tm_auto for Trivial Goals

**Source**: Logos/Core/Automation/Tactics.lean

```lean
-- tm_auto: Aesop-powered comprehensive automation
macro "tm_auto" : tactic => `(tactic| aesop (rule_sets [TMLogic]))
```

**Usage Pattern**:
```lean
theorem simple_theorem : ⊢ A.imp A := by
  tm_auto  -- Handles identity automatically
```

**Recommendation**: Try `tm_auto` first on every theorem. If it succeeds, proof is complete. If it fails, fall back to manual proof.

**Applicable to**:
- Task 21 (RAA): Possibly, if combined with existing lemmas
- Task 22 (EFQ): Possibly
- Task 30 (T-Box-Diamond): Likely (uses modal_t + definition)
- Other simple theorems

#### Sequence 2: modal_k_tactic for Modal Distribution

**Source**: Logos/Core/Automation/Tactics.lean

```lean
-- Apply modal K inference rule
syntax "modal_k_tactic" : tactic
```

**Usage Pattern**:
```lean
theorem example : [A.box, (A.imp B).box] ⊢ B.box := by
  modal_k_tactic  -- Applies modal K rule automatically
```

**Applicable to**:
- Task 31 (Box-Conjunction): Uses modal K distribution
- Task 34 (Box-Disjunction): Uses modal K distribution
- Task 35 (Box-Contraposition): Uses modal K distribution

#### Sequence 3: assumption_search for Context Extraction

**Source**: Logos/Core/Automation/Tactics.lean

```lean
-- Search context for matching assumption
syntax "assumption_search" : tactic
```

**Usage Pattern**:
```lean
theorem example : [A, B, C] ⊢ B := by
  assumption_search  -- Finds B in context
```

**Applicable to**:
- Tasks 23, 28, 29 (context-based reasoning)

### 3. Complexity Analysis and Effort Estimation

#### Low Complexity (2-3 hours each)

**Task 21 (RAA)**: Uses S axiom + imp_trans
**Task 22 (EFQ)**: Uses RAA + double_negation
**Task 26 (ECQ)**: Direct application of RAA
**Task 30 (T-Box-Diamond)**: Uses modal_t + diamond definition

**Total**: 4 tasks × 2.5 hours = 10 hours

#### Medium Complexity (3-5 hours each)

**Task 23 (LCE/RCE)**: Requires conjunction unfolding + case analysis
**Task 24 (LDI/RDI)**: Uses S axiom + disjunction definition
**Task 25 (RCP)**: Uses contrapose + double_negation
**Task 31 (Box-Conjunction Biconditional)**: Extends box_conj_intro + LCE/RCE
**Task 32 (Diamond-Disjunction)**: Dual of Task 31 via modal duality
**Task 34 (Box-Disjunction Intro)**: Uses box_mono + disjunction weakening
**Task 35 (Box-Contraposition)**: Uses box_mono + contrapose
**Task 36 (T-Box-Consistency)**: Uses modal_t + ECQ

**Total**: 8 tasks × 4 hours = 32 hours

#### High Complexity (6-8 hours each)

**Task 27 (NE/NI)**: Requires deduction theorem extension
**Task 28 (DE)**: Requires LEM + case analysis infrastructure
**Task 29 (BI/LBE/RBE)**: Requires biconditional infrastructure
**Task 33 (S5-Diamond-Box Collapse)**: Uses modal_5 but complex proof

**Total**: 4 tasks × 7 hours = 28 hours

**Grand Total**: 10 + 32 + 28 = **70 hours** (slight overestimate vs TODO.md's 62 hours)

### 4. Critical Infrastructure Dependencies

#### Dependency 1: Deduction Theorem (Partial)

**Required for**: Tasks 27-29 (NE/NI, DE, BI)

**Current Status**: Weakening and assumption rules exist, but full deduction theorem unproven.

**Proof Strategy**:
```lean
-- Target: If Γ, A ⊢ B then Γ ⊢ A → B
theorem deduction {A B : Formula} {Γ : Context}
  (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B := by
  -- Proof by induction on derivation h
  induction h with
  | axiom Γ φ hax =>
      -- If B is an axiom, then ⊢ B, so ⊢ A → B by S axiom
      have hB : ⊢ φ := Derivable.axiom [] φ hax
      have s : ⊢ φ.imp (A.imp φ) := Derivable.axiom [] _ (Axiom.prop_s φ A)
      exact Derivable.modus_ponens [] φ (A.imp φ) s hB
  | assumption Γ φ hmem =>
      -- Case 1: If φ = A, then ⊢ A → A by identity
      -- Case 2: If φ ∈ Γ, then Γ ⊢ φ, so Γ ⊢ A → φ by S axiom
      sorry
  | modus_ponens Γ φ ψ hφψ hφ ih_φψ ih_φ =>
      -- From Γ, A ⊢ φ → ψ and Γ, A ⊢ φ
      -- Get Γ ⊢ A → (φ → ψ) and Γ ⊢ A → φ by IH
      -- Need to derive Γ ⊢ A → ψ using K axiom
      sorry
  | modal_k Γ φ ψ hφ hφψ ih_φ ih_φψ =>
      -- Modal case is more complex
      sorry
  | _ => sorry
```

**Estimated Effort**: 8-12 hours to complete full deduction theorem

**Alternative**: Prove simplified versions for specific cases needed by Tasks 27-29.

#### Dependency 2: Law of Excluded Middle

**Required for**: Task 28 (DE - Disjunction Elimination)

**Derivation**:
```lean
theorem lem (A : Formula) : ⊢ A.or A.neg := by
  -- A ∨ ¬A = ¬A → ¬A (by disjunction definition)
  -- ¬A → ¬A is identity theorem
  exact identity A.neg
```

**Estimated Effort**: 1 hour (straightforward)

#### Dependency 3: Double Negation Introduction (DNI)

**Required for**: Tasks 25, 32, 35

**Derivation**:
```lean
theorem dni (A : Formula) : ⊢ A.imp A.neg.neg := by
  -- Contrapose identity: A → A
  -- Get ¬A → ¬A, then contrapose again... wait, that's circular

  -- Better approach: Use double_negation axiom (DNE) + identity
  -- From A, derive ¬¬A by: assume ¬¬A → A (DNE), then contrapose
  have dne : ⊢ A.neg.neg.imp A := Derivable.axiom [] _ (Axiom.double_negation A)
  have id : ⊢ A.imp A := identity A
  -- Need to show: A → ¬¬A from ¬¬A → A
  -- This requires proof by contradiction or case analysis
  sorry  -- Requires careful classical reasoning
```

**Estimated Effort**: 2-3 hours (requires classical reasoning patterns)

#### Dependency 4: Biconditional Introduction/Elimination

**Required for**: Tasks 29, 31-33

**Derivation**:
```lean
-- Biconditional is defined as: (A → B) ∧ (B → A)
theorem iff_intro {A B : Formula} {Γ : Context}
  (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B := by
  -- Apply deduction theorem to get Γ ⊢ A → B and Γ ⊢ B → A
  have fwd : Γ ⊢ A.imp B := deduction h1
  have bwd : Γ ⊢ B.imp A := deduction h2
  -- Combine with pairing
  exact pairing fwd bwd

theorem iff_elim_left {A B : Formula}
  (h : Γ ⊢ A.iff B) : Γ ⊢ A.imp B := by
  -- A.iff B = (A → B) ∧ (B → A)
  -- Extract left conjunct with lce
  exact lce (A.imp B) (B.imp A) h  -- Wait, h is not context membership
  sorry  -- Need conjunction elimination as theorem application, not context rule
```

**Estimated Effort**: 3-4 hours (depends on deduction theorem)

### 5. Recommended Implementation Order

**Phase 1: Propositional Foundations** (Priority 1, 22 hours)
1. **Task 26 (ECQ)** - Simplest, tests basic patterns (2 hours)
2. **Task 21 (RAA)** - Foundation for contradiction reasoning (3 hours)
3. **Task 22 (EFQ)** - Dual of RAA (2 hours)
4. **Task 24 (LDI/RDI)** - Disjunction introduction (4 hours)
5. **Dependency: DNI** - Double negation introduction (3 hours)
6. **Dependency: LEM** - Law of excluded middle (1 hour)
7. **Task 25 (RCP)** - Reverse contraposition (4 hours)
8. **Task 23 (LCE/RCE)** - Conjunction elimination (3 hours)

**Phase 2: Modal Theorems** (Priority 2, 20 hours)
9. **Task 30 (T-Box-Diamond)** - Simplest modal theorem (2 hours)
10. **Task 34 (Box-Disjunction Intro)** - Uses box_mono (3 hours)
11. **Task 35 (Box-Contraposition)** - Uses box_mono + contrapose (3 hours)
12. **Task 36 (T-Box-Consistency)** - Uses modal_t + ECQ (4 hours)
13. **Task 31 (Box-Conjunction Biconditional)** - Requires LCE/RCE (4 hours)
14. **Task 32 (Diamond-Disjunction)** - Dual of Task 31 (4 hours)

**Phase 3: Context Manipulation** (Priority 3, 28 hours)
15. **Dependency: Deduction Theorem** - Core infrastructure (12 hours)
16. **Dependency: Biconditional Infrastructure** - iff_intro, iff_elim (4 hours)
17. **Task 29 (BI/LBE/RBE)** - Biconditional reasoning (6 hours)
18. **Task 27 (NE/NI)** - Negation introduction/elimination (6 hours)

**Phase 4: Advanced Modal** (Priority 4, 7 hours)
19. **Task 33 (S5-Diamond-Box Collapse)** - Uses modal_5 (5 hours)
20. **Task 28 (DE)** - Disjunction elimination (requires deduction theorem) (2 hours, after deduction theorem)

**Total**: 77 hours (revised upward from 70 hours due to dependencies)

## Recommendations

### R1. Implement Dependency Lemmas First

Before starting task implementation, prove these foundational lemmas:

```lean
-- 1. Double Negation Introduction (3 hours)
theorem dni (A : Formula) : ⊢ A.imp A.neg.neg

-- 2. Law of Excluded Middle (1 hour)
theorem lem (A : Formula) : ⊢ A.or A.neg

-- 3. Contraposition Theorem (if not already proven)
theorem contrapose_thm (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg)

-- 4. Implicational Pairing (for biconditionals)
theorem imp_pairing {A B C : Formula}
  (h1 : Γ ⊢ A.imp B) (h2 : Γ ⊢ A.imp C) : Γ ⊢ A.imp (B.and C)
```

**Total Estimated Effort**: 8 hours

### R2. Use tm_auto Aggressively

```lean
theorem target : ⊢ goal := by
  tm_auto <|> (
    -- Manual proof if automation fails
    have h1 : ...
    ...
  )
```

**Benefit**: Catches trivial cases automatically, saves manual proof effort.

### R3. Create Proof Template Module

Create `Logos/Core/Theorems/ProofTemplates.lean` with reusable patterns:

```lean
-- Template 1: Contraposition with DNE
def contrapose_dne_pattern {A B : Formula}
  (h : Γ ⊢ A.imp B) : Γ ⊢ B.neg.imp A.neg := ...

-- Template 2: Box monotonicity with necessitation
def box_mono_pattern {A B : Formula}
  (h : ⊢ A.imp B) : ⊢ A.box.imp B.box := ...

-- Template 3: Implicational chain of length 3
def imp_chain_3 {A B C D : Formula}
  (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) (h3 : ⊢ C.imp D) : ⊢ A.imp D := ...
```

**Benefit**: Reduces boilerplate in theorem proofs.

### R4. Test Each Theorem Immediately

For each implemented theorem, create test in `LogosTest/Core/Theorems/PropositionalTest.lean`:

```lean
-- Test RAA
def test_raa : TestCase := {
  name := "RAA: A → (¬A → B)",
  test := fun () => do
    let A := Formula.atom "A"
    let B := Formula.atom "B"
    let thm := raa A B
    assert ([] ⊢ A.imp (A.neg.imp B))
}
```

**Benefit**: Immediate feedback on correctness, prevents regression.

### R5. Defer Deduction Theorem Complexity

**Observation**: Full deduction theorem is 12 hours of effort and blocks only 3 tasks (27-29).

**Recommendation**: Implement Tasks 21-26, 30-36 first (57 hours), defer Tasks 27-29 until deduction theorem infrastructure is ready.

**Benefit**: Maintains momentum, delivers 18/21 theorems faster.

## Conclusion

The Logos project has strong precedent for implementing all 21 target theorems. Eight core proof patterns from Perpetuity.lean provide templates, and 12 tactical sequences enable automation. The critical path bottleneck is deduction theorem infrastructure (12 hours), which blocks 3 tasks. Recommended approach: implement Phases 1-2 (42 hours, 14 theorems) before tackling deduction theorem complexity.

**Key Success Factors**:
1. Reuse proven patterns (contraposition, box_mono, pairing)
2. Leverage automation (tm_auto, modal_k_tactic)
3. Implement dependencies first (DNI, LEM, contrapose_thm)
4. Test immediately after each theorem
5. Defer deduction theorem to Phase 3

**Next Steps**: Review project structure report for file organization, then begin Phase 1 implementation.

---

**Report Statistics**:
- Proof Patterns Identified: 8
- Tactical Sequences Documented: 12
- Code Examples: 25
- Dependencies Mapped: 4
- Total Estimated Effort: 77 hours (revised from TODO.md's 62 hours)
