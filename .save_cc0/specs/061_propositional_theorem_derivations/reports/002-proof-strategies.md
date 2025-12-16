# Proof Strategies Research Report: Propositional Theorem Derivations

## Summary

This report analyzes the Logos TM codebase to identify optimal proof strategies for deriving propositional theorems (Tasks 21-29) from the Hilbert-style axiom system. The analysis reveals:

1. **Strong Infrastructure**: Logos already has a complete combinator calculus foundation (K, S, B, C combinators) plus deduction theorem support
2. **Phase 1 Complete**: All basic propositional theorems (RAA, EFQ, LCE, RCE, LDI, RDI, RCP) are already proven in `Propositional.lean`
3. **Recommended Approach**: Build on existing combinators using compositional proof patterns
4. **Key Discovery**: The deduction theorem is fully proven and can simplify many proofs

---

## Section 1: Axiom Foundation Analysis

### Finding 1.1: Available Axioms and Inference Rules

**Propositional Axioms** (from `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean`):

1. **prop_k (K combinator)**: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` - distribution axiom
2. **prop_s (S combinator)**: `φ → (ψ → φ)` - weakening axiom
3. **double_negation (DNE)**: `¬¬φ → φ` - classical logic principle

**Inference Rules** (from `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Derivation.lean`):

1. **axiom**: Any axiom instance is derivable
2. **assumption**: Formulas in context are derivable
3. **modus_ponens**: If `Γ ⊢ φ → ψ` and `Γ ⊢ φ` then `Γ ⊢ ψ`
4. **weakening**: If `Γ ⊢ φ` and `Γ ⊆ Δ` then `Δ ⊢ φ`
5. **modal_k, temporal_k, temporal_duality**: Modal/temporal operators (not needed for pure propositional)

**Key Observation**: The axiom system is **Turing-complete** for propositional logic. K and S combinators form a complete basis (equivalent to SKI combinators since I = SKK).

### Finding 1.2: Derived Combinators Already Proven

**From** `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`:

- `identity (I combinator)`: `⊢ A → A` (derived as SKK)
- `b_combinator (B combinator)`: `⊢ (B → C) → (A → B) → (A → C)` (composition)
- `theorem_flip (C combinator)`: `⊢ (A → B → C) → (B → A → C)` (argument swap)
- `theorem_app1`: `⊢ A → (A → B) → B` (application)
- `theorem_app2 (Vireo combinator)`: `⊢ A → B → (A → B → C) → C` (pair application)
- `pairing`: `⊢ A → B → (A ∧ B)` (conjunction introduction, derived from `theorem_app2` with C := ⊥)

**From** `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (axioms used as helpers):

- `dni`: `⊢ A → ¬¬A` (double negation introduction) - **axiom placeholder**
- `contraposition`: `⊢ (A → B) → (¬B → ¬A)` (classical contraposition)
- `double_contrapose`: From `⊢ ¬A → ¬B`, derive `⊢ B → A` (combines contraposition with DNE/DNI)

**Critical Infrastructure**:
- `imp_trans`: Transitivity of implication (hypothetical syllogism)
- `mp`: Modus ponens as theorem combinator

### Finding 1.3: Deduction Theorem Infrastructure

**From** `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean`:

The deduction theorem is **fully proven** with all cases handled:

```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B
```

**Key lemmas**:
- `deduction_axiom`: If φ is axiom, then `Γ ⊢ A → φ`
- `deduction_assumption_same`: `Γ ⊢ A → A` (uses `identity`)
- `deduction_assumption_other`: If `B ∈ Γ`, then `Γ ⊢ A → B` (uses `prop_s`)
- `deduction_mp`: Handles modus ponens case (uses `prop_k`)

**Impact**: The deduction theorem allows converting context-based proofs to pure implications, dramatically simplifying many theorem proofs.

---

## Section 2: Derivation Dependency Graph

### Finding 2.1: Phase 1 Theorems (Already Proven)

**From** `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean`:

All Phase 1 propositional theorems are **already complete**:

1. **ecq** (Ex Contradictione Quodlibet): `[A, ¬A] ⊢ B` ✓
2. **raa** (Reductio ad Absurdum): `⊢ A → (¬A → B)` ✓
3. **efq** (Ex Falso Quodlibet): `⊢ ¬A → (A → B)` ✓
4. **ldi** (Left Disjunction Introduction): `[A] ⊢ A ∨ B` ✓
5. **rdi** (Right Disjunction Introduction): `[B] ⊢ A ∨ B` ✓
6. **rcp** (Reverse Contraposition): `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)` ✓
7. **lce** (Left Conjunction Elimination): `[A ∧ B] ⊢ A` ✓
8. **rce** (Right Conjunction Elimination): `[A ∧ B] ⊢ B` ✓

**Implication forms** (using deduction theorem):

9. **lce_imp**: `⊢ (A ∧ B) → A` ✓
10. **rce_imp**: `⊢ (A ∧ B) → B` ✓

### Finding 2.2: Phase 2+ Infrastructure (Partially Complete)

**From** `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean`:

11. **lem** (Law of Excluded Middle): `⊢ A ∨ ¬A` ✓
12. **classical_merge**: `⊢ (P → Q) → ((¬P → Q) → Q)` ✓
13. **contrapose_imp**: `⊢ (A → B) → (¬B → ¬A)` ✓
14. **contrapose_iff**: From `⊢ A ↔ B`, derive `⊢ ¬A ↔ ¬B` ✓
15. **iff_intro**: From `⊢ A → B` and `⊢ B → A`, derive `⊢ A ↔ B` ✓
16. **iff_elim_left**: `[A ↔ B, A] ⊢ B` ✓
17. **iff_elim_right**: `[A ↔ B, B] ⊢ A` ✓

**Phase 4: De Morgan Laws** (Plan 059 Phase 1):

18. **demorgan_conj_neg**: `⊢ ¬(A ∧ B) ↔ (¬A ∨ ¬B)` ✓
19. **demorgan_disj_neg**: `⊢ ¬(A ∨ B) ↔ (¬A ∧ ¬B)` ✓

### Finding 2.3: Optimal Proof Ordering

**Dependency Analysis**:

```
Level 0 (Axioms):
  prop_k, prop_s, double_negation

Level 1 (Basic Combinators):
  identity, b_combinator, theorem_flip
  ↓
Level 2 (Application Patterns):
  theorem_app1, theorem_app2, pairing
  ↓
Level 3 (Negation Infrastructure):
  dni (axiom), contraposition, double_contrapose
  ↓
Level 4 (Contradiction Theorems):
  ecq [A, ¬A] ⊢ B
  raa: A → (¬A → B)
  efq: ¬A → (A → B)
  ↓
Level 5 (Disjunction/Conjunction):
  ldi, rdi (use efq, prop_s)
  lce, rce (use efq, contraposition, DNE)
  ↓
Level 6 (Contraposition):
  rcp (uses dni, contraposition, DNE, b_combinator)
  contrapose_imp (uses b_combinator, theorem_flip)
  ↓
Level 7 (Classical Logic):
  lem (trivial: ¬A → ¬A)
  classical_merge (uses contraposition + DNE)
  ↓
Level 8 (Biconditionals):
  iff_intro, iff_elim_left, iff_elim_right, contrapose_iff
  ↓
Level 9 (De Morgan Laws):
  demorgan_conj_neg, demorgan_disj_neg
```

**Key Insight**: The dependency chain is LINEAR with clear levels. Each level builds on previous infrastructure.

---

## Section 3: Proof Techniques

### Finding 3.1: Core Proof Patterns

**Pattern 1: Combinator Composition**

Used for: Building complex implications from simpler ones

Example (from `raa` proof):
```lean
-- Goal: A → (¬A → B)
-- Step 1: Build ⊥ → B using prop_s and DNE
have bot_to_b : ⊢ ⊥ → B := ...
-- Step 2: Build A → ¬¬A → (¬A → B) using b_combinator
have b_comp : ⊢ (¬¬A → (¬A → B)) → ((A → ¬¬A) → (A → (¬A → B)))
-- Step 3: Compose using modus ponens
```

**Pattern 2: Deduction Theorem**

Used for: Converting context-based proofs to implications

Example (from `lce_imp` proof):
```lean
theorem lce_imp (A B : Formula) : ⊢ (A ∧ B) → A := by
  have h : [A ∧ B] ⊢ A := lce A B  -- Context-based proof
  exact deduction_theorem [] (A ∧ B) A h  -- Convert to implication
```

**Pattern 3: Contraposition Chain**

Used for: Deriving reverse implications

Example (from `rcp` proof):
```lean
-- Goal: From ¬A → ¬B, derive B → A
-- Step 1: DNI for B: B → ¬¬B
-- Step 2: Contrapose hypothesis: ¬¬B → ¬¬A
-- Step 3: DNE for A: ¬¬A → A
-- Step 4: Compose: B → ¬¬B → ¬¬A → A
```

**Pattern 4: Classical Merge**

Used for: Case analysis using LEM

Example (from `classical_merge` proof):
```lean
-- Goal: (P → Q) → ((¬P → Q) → Q)
-- Use case analysis: either P or ¬P (by LEM)
-- If P: get Q from P → Q
-- If ¬P: get Q from ¬P → Q
-- Build using contraposition: from ¬Q derive both ¬P and ¬¬P (contradiction)
```

### Finding 3.2: Specific Proof Strategies for Key Theorems

#### **RAA (Reductio ad Absurdum)**: `⊢ A → (¬A → B)`

**Strategy**:
1. Derive `⊥ → B` using `prop_s` and `double_negation`
2. Build `A → ¬A → ⊥` using `theorem_app1` (application pattern)
3. Compose using nested `b_combinator` applications

**Complexity**: Medium (requires 2-3 nested combinator compositions)

**Current Status**: ✓ **PROVEN** (lines 150-198 in Propositional.lean)

#### **EFQ (Ex Falso Quodlibet)**: `⊢ ¬A → (A → B)`

**Strategy**:
1. Apply `theorem_flip` to RAA to swap argument order
2. Direct modus ponens application

**Complexity**: Simple (1 flip + 1 MP)

**Current Status**: ✓ **PROVEN** (lines 209-222 in Propositional.lean)

#### **LCE (Left Conjunction Elimination)**: `[A ∧ B] ⊢ A`

**Strategy**:
1. Recall: `A ∧ B = ¬(A → ¬B)`
2. From `¬(A → ¬B)` in context, derive `¬¬A`
   - Show `¬A → (A → ¬B)` by EFQ
   - Contrapose: `¬(A → ¬B) → ¬¬A`
3. Apply DNE to get A

**Complexity**: Medium (requires EFQ + contraposition + DNE)

**Current Status**: ✓ **PROVEN** (lines 419-477 in Propositional.lean)

#### **RCE (Right Conjunction Elimination)**: `[A ∧ B] ⊢ B`

**Strategy**:
1. Recall: `A ∧ B = ¬(A → ¬B)`
2. From `¬(A → ¬B)` in context, derive `¬¬B`
   - Show `¬B → (A → ¬B)` by prop_s
   - Contrapose: `¬(A → ¬B) → ¬¬B`
3. Apply DNE to get B

**Complexity**: Medium (requires prop_s + contraposition + DNE)

**Current Status**: ✓ **PROVEN** (lines 491-548 in Propositional.lean)

#### **LDI (Left Disjunction Introduction)**: `[A] ⊢ A ∨ B`

**Strategy**:
1. Recall: `A ∨ B = ¬A → B`
2. From A in context, derive `¬A → B` using EFQ and prop_s
3. Apply modus ponens with context assumption

**Complexity**: Simple (uses EFQ + prop_k + prop_s)

**Current Status**: ✓ **PROVEN** (lines 235-286 in Propositional.lean)

#### **RDI (Right Disjunction Introduction)**: `[B] ⊢ A ∨ B`

**Strategy**:
1. Recall: `A ∨ B = ¬A → B`
2. From B, derive `¬A → B` using prop_s (weakening)
3. Direct application

**Complexity**: Trivial (just prop_s)

**Current Status**: ✓ **PROVEN** (lines 298-318 in Propositional.lean)

#### **RCP (Reverse Contraposition)**: `(Γ ⊢ ¬A → ¬B) → (Γ ⊢ B → A)`

**Strategy**:
1. DNI for B: `B → ¬¬B`
2. Contrapose hypothesis to get: `¬¬B → ¬¬A`
3. DNE for A: `¬¬A → A`
4. Compose chain: `B → ¬¬B → ¬¬A → A` using b_combinator

**Complexity**: Medium (requires DNI + contraposition + DNE + composition)

**Current Status**: ✓ **PROVEN** (lines 334-403 in Propositional.lean)

### Finding 3.3: Advanced Proof Patterns

#### **Deduction Theorem Pattern**

**When to use**: Converting context-based proofs to pure implications

**Template**:
```lean
-- From [A, B, C] ⊢ D, derive ⊢ A → B → C → D
theorem example_thm (A B C D : Formula) : ⊢ A.imp (B.imp (C.imp D)) := by
  -- Step 1: Prove in context
  have h1 : [C, B, A] ⊢ D := ...  -- Note: reverse order (newest first)

  -- Step 2: Apply deduction theorem iteratively
  have h2 : [B, A] ⊢ C.imp D := deduction_theorem [B, A] C D h1
  have h3 : [A] ⊢ B.imp (C.imp D) := deduction_theorem [A] B (C.imp D) h2
  exact deduction_theorem [] A (B.imp (C.imp D)) h3
```

**Key Insight**: Context ordering matters! Deduction theorem expects newest assumption at HEAD of list.

#### **Contradiction Introduction Pattern**

**When to use**: Deriving `¬A` from contradiction

**Template** (from `classical_merge` proof):
```lean
-- Goal: (A → B) → ((A → ¬B) → ¬A)
-- Build in context [A, A → ¬B, A → B], derive ⊥
have h_in_ctx : [A, (A.imp B.neg), (A.imp B)] ⊢ Formula.bot := by
  have h_a : ... ⊢ A := assumption
  have h_b : ... ⊢ B := modus_ponens (h_ab) h_a
  have h_nb : ... ⊢ ¬B := modus_ponens (h_a_nb) h_a
  exact modus_ponens h_nb h_b  -- ⊥
-- Apply deduction theorem 3 times
```

**Key Insight**: Build contradiction in context, then use deduction theorem to "discharge" assumptions.

#### **De Morgan Pattern**

**When to use**: Relating negated conjunctions/disjunctions

**Forward direction** (`¬(A ∧ B) → (¬A ∨ ¬B)`):
1. Recall: `A ∧ B = ¬(A → ¬B)` and `¬A ∨ ¬B = ¬¬A → ¬B`
2. Apply DNE: `¬¬(A → ¬B) → (A → ¬B)`
3. Build `(A → ¬B) → (¬¬A → ¬B)` using DNE on A + b_combinator
4. Compose

**Backward direction** (`(¬A ∨ ¬B) → ¬(A ∧ B)`):
1. Use deduction theorem: assume both `¬¬A → ¬B` and `A ∧ B`
2. Extract A and B from conjunction (using lce, rce)
3. Derive `¬¬A` from A (using dni)
4. Apply hypothesis to get `¬B`
5. From B and `¬B`, derive ⊥
6. Discharge assumptions via deduction theorem

**Current Status**: ✓ **PROVEN** (lines 948-1279 in Propositional.lean)

---

## Recommendations

### Recommendation 1: Proof Order for Future Theorems

**If additional propositional theorems are needed**, follow this order:

1. **Conjunction Distributivity**: `(A ∧ B) ∨ C ↔ (A ∨ C) ∧ (B ∨ C)`
   - Depends on: lce, rce, ldi, rdi, iff_intro
   - Complexity: Medium-High (4-6 lemmas)

2. **Disjunction Distributivity**: `(A ∨ B) ∧ C ↔ (A ∧ C) ∨ (B ∧ C)`
   - Depends on: Previous + classical_merge
   - Complexity: Medium-High (4-6 lemmas)

3. **Implication Distributivity**: `(A → B) ∧ (A → C) → (A → (B ∧ C))`
   - Depends on: pairing, prop_k
   - Complexity: Simple (direct from combinators)

4. **Biconditional Symmetry**: `(A ↔ B) → (B ↔ A)`
   - Depends on: iff_intro, lce_imp, rce_imp, theorem_flip
   - Complexity: Simple (flip + reconstruct)

5. **Biconditional Transitivity**: `(A ↔ B) → (B ↔ C) → (A ↔ C)`
   - Depends on: iff_intro, imp_trans, lce_imp, rce_imp
   - Complexity: Medium (extract + compose + rebuild)

### Recommendation 2: Helper Lemma Recommendations

**For modal theorem work** (Tasks 30+), prioritize these propositional helpers:

1. **iff_mp_left**: From `⊢ A ↔ B` and `⊢ A`, derive `⊢ B`
   - **Purpose**: Simplifies biconditional reasoning in modal proofs
   - **Strategy**: Extract `A → B` using lce_imp, apply MP
   - **Complexity**: Trivial

2. **iff_mp_right**: From `⊢ A ↔ B` and `⊢ B`, derive `⊢ A`
   - **Purpose**: Dual of iff_mp_left
   - **Strategy**: Extract `B → A` using rce_imp, apply MP
   - **Complexity**: Trivial

3. **iff_of_equiv**: From `⊢ A → B` and `⊢ B → A`, derive `⊢ A ↔ B`
   - **Purpose**: Already exists as `iff_intro`, no action needed
   - **Status**: ✓ Already proven

4. **not_congr**: From `⊢ A ↔ B`, derive `⊢ ¬A ↔ ¬B`
   - **Purpose**: Already exists as `contrapose_iff`, no action needed
   - **Status**: ✓ Already proven

5. **imp_congr_left**: From `⊢ B ↔ C`, derive `⊢ (A → B) ↔ (A → C)`
   - **Purpose**: Congruence for implication right side
   - **Strategy**: Use b_combinator + iff_intro
   - **Complexity**: Simple

6. **imp_congr_right**: From `⊢ A ↔ B`, derive `⊢ (A → C) ↔ (B → C)`
   - **Purpose**: Congruence for implication left side (contravariant)
   - **Strategy**: Use contraposition on biconditional + iff_intro
   - **Complexity**: Medium

### Recommendation 3: Axiom Cleanup

**Action Items**:

1. **Convert `dni` from axiom to theorem**
   - Current: Axiom placeholder (line 523 in Perpetuity.lean)
   - Target: Derive from `theorem_app1` with B := ⊥
   - Reason: Reduces axiom count, demonstrates proof from combinators
   - **Note**: Actually `dni` is `A → ¬¬A = A → (A → ⊥) → ⊥` which is exactly `theorem_app1`!
   - **Status**: Can be replaced immediately

2. **Convert temporal axioms to theorems where possible**
   - `always_dni` (line 1504): May be derivable from temporal K + dni
   - `always_dne` (line 1570): May be derivable from temporal K + DNE
   - `always_mono` (line 1670): May be derivable from temporal K + prop_k
   - `future_k_dist` (line 1233): Check if derivable from temporal_k rule

3. **Document combinator correspondence**
   - Add comments linking each combinator to SKI calculus
   - Reference: `I = SKK`, `B = S(KS)K`, `C = S(BBS)(KK)`

### Recommendation 4: Testing Strategy

**For any new propositional theorems**:

1. **Unit tests** in `PropositionalTest.lean`:
   - Test with atomic formulas (simple cases)
   - Test with nested formulas (recursive cases)
   - Test edge cases (⊥, ¬⊥, double negation)

2. **Integration tests**:
   - Use new theorems in modal context
   - Verify they compose with box/diamond operators
   - Check temporal operator interactions

3. **Performance benchmarks**:
   - Proof search time < 1 second
   - Build time impact minimal
   - No exponential proof size growth

### Recommendation 5: Documentation Standards

**For each new theorem**:

1. **Docstring format**:
   ```lean
   /--
   Theorem Name: Mathematical statement.

   [Optional: Intuitive explanation]

   **Proof Strategy**: [High-level approach]

   **Complexity**: [Simple|Medium|High]

   **Dependencies**: [List key lemmas used]
   -/
   ```

2. **Proof sketch in comments**:
   - Number each major step
   - Explain key insights
   - Reference combinator patterns used

3. **Example usage**:
   - Add to `Archive/BimodalProofs.lean` if pedagogically valuable
   - Show modal/temporal applications if applicable

---

## Appendix A: Combinator Reference

### SKI Combinators (Standard)

- **S**: `(A → B → C) → (A → B) → A → C` (substitution)
- **K**: `A → B → A` (constant/weakening) - **Available as `prop_s`**
- **I**: `A → A` (identity) - **Derived as SKK** in `identity`

### Additional Combinators in Logos

- **B** (composition): `(B → C) → (A → B) → A → C` - **Proven as `b_combinator`**
- **C** (flip): `(A → B → C) → B → A → C` - **Proven as `theorem_flip`**
- **Vireo** (pair application): `A → B → (A → B → C) → C` - **Proven as `theorem_app2`**

### Combinator Derivation Paths

```
K, S (axioms)
  ↓
I = SKK (identity)
  ↓
B = S(KS)K (b_combinator)
  ↓
C = S(BB(S(KS)K))(KK) (theorem_flip, using B)
  ↓
Vireo = BCB (theorem_app2, using B and C)
```

**Note**: Logos doesn't strictly follow SKI derivation paths; it uses direct combinator proofs optimized for clarity.

---

## Appendix B: Key File Locations

- **Axioms**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean`
- **Derivation Rules**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Derivation.lean`
- **Combinator Infrastructure**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (lines 69-494)
- **Propositional Theorems**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean` (1282 lines)
- **Deduction Theorem**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean`
- **Tests**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Theorems/PropositionalTest.lean`

---

## Appendix C: Proof Complexity Metrics

**Simple** (1-5 steps):
- RDI, LEM, iff_intro, iff_elim_left, iff_elim_right

**Medium** (6-15 steps):
- RAA, EFQ, LCE, RCE, LDI, RCP, contrapose_imp, classical_merge

**High** (16+ steps):
- demorgan_conj_neg, demorgan_disj_neg, contrapose_iff

**Very High** (30+ steps):
- None currently needed for propositional logic

**Key Insight**: Most propositional theorems are Medium complexity. The deduction theorem can reduce many High complexity proofs to Medium by allowing context-based reasoning.

---

## Conclusion

The Logos TM codebase has **excellent infrastructure** for propositional theorem derivation:

1. **Complete axiom basis** (K, S, DNE)
2. **Rich combinator library** (I, B, C, Vireo, pairing)
3. **Fully proven deduction theorem**
4. **All basic propositional theorems already proven** (Tasks 21-29 complete)

**For future work**: Focus on modal-specific theorems (Tasks 30+) and advanced biconditional manipulation. The propositional foundation is solid and complete.

**Key Discovery**: The `dni` axiom can be eliminated by recognizing it's identical to `theorem_app1` with B := ⊥. This reduces axiom count and demonstrates the power of the combinator approach.
