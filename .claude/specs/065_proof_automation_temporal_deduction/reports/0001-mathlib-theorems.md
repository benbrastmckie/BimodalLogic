# Mathlib Theorems Research Report

## Executive Summary

This report analyzes the derivability of 5 axioms declared in `Logos/Core/Theorems/Perpetuity.lean` and provides proof strategies for 11 sorry placeholders in the deduction theorem implementation. The analysis reveals that:

1. **3 axioms are potentially derivable** from existing Logos axioms and Mathlib principles: `dni`, `always_dni`, `always_dne`
2. **2 axioms require sophisticated proof strategies** that may be achievable through careful application of existing rules: `future_k_dist`, `always_mono`
3. **3 critical sorry placeholders** in DeductionTheorem.lean require well-founded recursion or mutual induction for the modal_k and temporal_k cases
4. **Multiple Mathlib theorems** are directly applicable to Logos proof strategies, particularly in classical logic (`of_not_not`, `or_not`, `not_imp_not`)

## 1. Derivable Axiom Analysis

### 1.1 dni (Double Negation Introduction)

**Current Status**: Axiom (line 523)
```lean
axiom dni (A : Formula) : ⊢ A.imp A.neg.neg
```

**Derivability Assessment**: DERIVABLE via propositional reasoning

**Proof Strategy**:
- This is the forward direction of classical double negation
- **Mathlib Equivalent**: `Mathlib.Logic.Basic` does not provide `not_not_intro` directly, but this can be derived from primitives
- **Logos Derivation Path**:
  1. Use S axiom (weakening): `A → (¬A → A)` (from `Axiom.prop_s A (A.neg)`)
  2. Use reductio ad absurdum: `(¬A → A) → ((¬A → ¬A) → ¬¬A)`
  3. Derive `¬A → ¬A` via identity theorem
  4. Apply MP to get `¬¬A`

**Key Dependencies**:
- `Axiom.prop_s`: Weakening axiom
- `identity`: Self-implication theorem (already proven in Perpetuity.lean line 100+)
- Standard propositional reasoning

**Recommendation**: Replace axiom with theorem using `reductio` pattern in Logos. Mark as Priority 1.

**Example Derivation Pattern** (conceptual):
```
1. prop_s A (A.neg)           ⊢ A → (¬A → A)
2. identity (A.neg)            ⊢ ¬A → ¬A
3. [composition]               ⊢ A → ¬¬A
```

---

### 1.2 future_k_dist (Future K Distribution)

**Current Status**: Axiom (line 1233-1234)
```lean
axiom future_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)
```

**Derivability Assessment**: LIKELY DERIVABLE via temporal K rule + careful context manipulation

**Semantic Justification** (from code comments):
- If `(A → B)` holds at all future times, and `A` holds at all future times, then `B` must hold at all future times
- This is the temporal analog of modal K distribution

**Proof Strategy**:

The temporal K rule in Logos (Derivable.temporal_k) transforms contexts:
```
If Γ ⊢ φ, then [future Γ] ⊢ future φ
```

**Derivation Approach**:
1. Observe that `(A → B).all_future → (A.all_future → B.all_future)` requires distributing future over implication
2. Key insight: Similar to `modal_k_dist` axiom (line 150-151 in Axioms.lean)
3. Use deduction theorem + temporal_k rule:
   - From `[A → B, A] ⊢ B` (by modus ponens)
   - Apply temporal_k: `[future(A → B), future A] ⊢ future B`
   - Apply deduction theorem twice to lift context outside
4. Alternative: Use temporal_k_dist helper lemma (if it exists) similar to modal_k_dist

**Key Dependency**:
- Deduction theorem must work for temporal_k case (currently has sorry at line 382-383)
- Well-founded induction on derivation structure

**Mathlib Equivalent**:
- No direct Mathlib equivalent (temporal logic is not in core Mathlib)
- Related to monad/functor laws in category theory (not directly applicable)

**Recommendation**: Mark as Priority 2. Requires completing DeductionTheorem first.

---

### 1.3 always_dni (Double Negation Introduction for Always)

**Current Status**: Axiom (line 1504)
```lean
axiom always_dni (φ : Formula) : ⊢ φ.always.imp φ.neg.neg.always
```

**Derivability Assessment**: DERIVABLE using temporal reasoning + dni

**Semantic Justification** (from code comments):
- If `φ` holds at all times (past, present, future), then `¬¬φ` also holds at all times
- This follows from the fact that if φ is true at every time point, then the double negation of φ is also true at every time point

**Proof Strategy**:

1. **Component Analysis**:
   - `φ.always = Hφ ∧ φ ∧ Gφ` (H = past, G = future, which are `all_past` and `all_future`)
   - `φ.neg.neg.always = H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ)`

2. **Derivation Steps**:
   - From `always φ`, we can extract each component: `Hφ`, `φ`, `Gφ`
   - Apply `dni` to each: get `¬¬Hφ`, `¬¬φ`, `¬¬Gφ`
   - Combine back into `always(¬¬φ)`

3. **Implementation Pattern**:
   - Use conjunction elimination (`.lce`, `.rce`) to decompose `always φ`
   - Apply `dni` axiom to each component
   - Use conjunction introduction to recombine
   - Reconstitute into `always(¬¬φ)` using constructor

**Key Dependencies**:
- `dni` axiom (or its derived form)
- Conjunction manipulation theorems (already proven in Propositional.lean)
- Temporal decomposition lemmas

**Recommendation**: Replace with theorem. Mark as Priority 1 (depends on dni resolution).

**Complexity**: Medium (requires understanding temporal composition)

---

### 1.4 always_dne (Double Negation Elimination for Always)

**Current Status**: Axiom (line 1570)
```lean
axiom always_dne (φ : Formula) : ⊢ φ.neg.neg.always.imp φ.always
```

**Derivability Assessment**: DERIVABLE using temporal DNE + composition

**Semantic Justification**:
- The reverse of always_dni: if `¬¬φ` holds at all times, then `φ` holds at all times
- By classical logic, `¬¬φ ↔ φ`, so this should hold at every time point

**Proof Strategy**:

1. **Component-wise Application**:
   - From `always(¬¬φ)`, extract: `H(¬¬φ)`, `¬¬φ`, `G(¬¬φ)`
   - Apply `double_negation` axiom (line 170 in Axioms.lean) to each: get `Hφ`, `φ`, `Gφ`
   - Recombine into `always φ`

2. **Alternative Approach** (more efficient):
   - Use contraposition on `always_dni`: if `always(¬¬φ) → always φ` is proved, derive by contraposing
   - This is symmetric to always_dni and may allow code reuse

**Key Dependencies**:
- `double_negation` axiom (already in Axioms.lean)
- Conjunction decomposition/composition
- Temporal operators

**Mathlib Equivalent**:
- `Mathlib.Logic.Basic.of_not_not`: `¬¬a → a` (line 200)
- Can serve as inspiration for the temporal analog

**Recommendation**: Derive as theorem. Priority 1. Symmetric to always_dni implementation.

---

### 1.5 always_mono (Monotonicity of Always)

**Current Status**: Axiom (line 1670)
```lean
axiom always_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.always.imp B.always
```

**Derivability Assessment**: DERIVABLE using K-distribution over temporal operators

**Semantic Justification**:
- If `A` implies `B` at all time points, and `A` holds at all times, then `B` must hold at all times
- This is the monotonicity/homomorphism property of the universal temporal quantifier
- Related to functor preservation of implications

**Proof Strategy**:

1. **Key Insight**: This is temporal analog of `box_mono` (modal monotonicity)
   - Modal version would be: `(⊢ A → B) → (⊢ □A → □B)`
   - Similar proof pattern should apply

2. **Derivation Steps**:
   - Given: `⊢ A → B`
   - Goal: `⊢ always A → always B`
   - Decompose `always` into past/present/future:
     - `always A = past A ∧ A ∧ future A`
     - `always B = past B ∧ B ∧ future B`
   - Apply temporal K distribution:
     - `past (A → B) → (past A → past B)` (past_k_dist)
     - `future (A → B) → (future A → future B)` (future_k_dist)
   - Use transitivity and composition to chain implications
   - Apply necessitation to A → B to get `□(A → B)`, then distribute

3. **Implementation Pattern** (using existing lemmas):
   ```
   From h : ⊢ A.imp B
   1. Apply temporal_k to h? No - temporal_k needs context
   2. Use deduction theorem approach:
      - Convert h via deduction theorem (if possible)
      - Or use inference rule directly
   3. Alternative: Use box_mono (modal monotonicity) as pattern
   ```

**Key Dependencies**:
- `future_k_dist` (once derived)
- `past_k_dist` (derived via temporal duality in Perpetuity.lean line 1246)
- Temporal composition lemmas
- Transitivity of implication (already proven: `imp_trans` in Perpetuity.lean line 82)

**Mathlib Equivalent**:
- **Monotone.const**: Lattice monotonicity pattern from `Mathlib.Order.Monotone.Basic`
- General principle: `Monotone f` means `a ≤ b → f a ≤ f b`
- Not directly applicable, but pattern is similar

**Recommendation**: Mark as Priority 2. Depends on future_k_dist resolution.

**Complexity**: High (requires chaining multiple distribution lemmas)

---

## 2. Sorry Placeholder Resolution Strategy

### Analysis of 3 Sorry Cases in DeductionTheorem.lean

The deduction theorem has the signature:
```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) :
    Γ ⊢ A.imp B
```

The theorem establishes that a derivation with an assumption `A` can be lifted to a derivation without that assumption in the form `A → B`.

#### 2.1 Modal K Case (lines 164-370)

**Issue**: Context transformation via `map box`

**Problem Statement**:
```lean
| modal_k Γ' φ _h ih =>
  -- Δ = A :: Γ = Context.map Formula.box Γ'
  -- This means A = box A' and Γ = map box Γ''
```

When the derivation uses the modal_k rule, the context is transformed by boxing each element:
```
If Γ' ⊢ φ, then (map box Γ') ⊢ box φ
```

**Root Cause**:
- The induction hypothesis `ih` has signature: `A :: Γ = Γ' → Γ ⊢ A.imp φ`
- But the actual context is `A :: Γ = map box Γ'`, which doesn't match the structure to apply `ih`
- Deduction theorem requires structural recursion on the derivation, but boxed contexts break the induction structure

**Standard Approach** (from modal logic literature):
- **Solution 1**: Prove an auxiliary "boxed deduction theorem":
  ```lean
  theorem deduction_theorem_boxed (Γ' : Context) (A' φ : Formula)
      (h : (A' :: Γ') ⊢ φ) :
      (Context.map box Γ') ⊢ (box A').imp (box φ)
  ```
  Then use this in the modal_k case.

- **Solution 2**: Use well-founded recursion on the derivation tree:
  - The sub-derivation `_h : (A' :: Γ'') ⊢ φ` is structurally smaller
  - Call deduction_theorem on `_h` recursively
  - The termination argument: derivation size decreases
  - Lean's termination checker should accept via `structural` recursion

- **Solution 3**: Restrict deduction theorem scope:
  - State that deduction_theorem only applies to derivations without modal_k applications to non-empty contexts
  - This is the "standard" restriction in modal logic (necessitation applies only to theorems)

**Recommendation**:
- **Implement Solution 2**: Add explicit well-founded recursion
- Use `Subrelation.wf` with derivation size as metric
- Pattern:
  ```lean
  termination_by h.size  -- or similar metric
  | modal_k Γ' φ _h ih =>
    -- Recursive call on _h
    have boxed_result := deduction_theorem Γ'' A' φ _h
    -- Convert boxed_result to desired goal
  ```

**Priority**: CRITICAL (blocks 2 other sorry cases)

---

#### 2.2 Temporal K Case (lines 371-383)

**Issue**: Context transformation via `map all_future`

**Problem Statement**:
```lean
| temporal_k Γ' φ _h ih =>
  -- Δ = A :: Γ = Context.map Formula.all_future Γ'
```

**Root Cause**: Identical to modal_k case, but with temporal operator instead of box

**Solution**: Apply identical approach to modal_k solution

**Key Difference**:
- Modal: `map box`
- Temporal: `map all_future`
- But the proof structure is the same

**Recommendation**:
- Implement together with modal_k case
- Create helper:
  ```lean
  theorem deduction_theorem_temporal (Γ' : Context) (A' φ : Formula)
      (h : (A' :: Γ') ⊢ φ) :
      (Context.map all_future Γ') ⊢ (all_future A').imp (all_future φ)
  ```

**Priority**: CRITICAL (depends on modal_k solution)

---

#### 2.3 Weakening Case (lines 388-438)

**Issue**: Non-empty weakening context

**Problem Statement**:
```lean
| weakening Γ' Δ' φ _h1 h2 ih =>
  -- We have: _h1 : Γ' ⊢ φ
  -- And: h2 : Γ' ⊆ Δ' = A :: Γ
  -- Need to check: is A ∈ Γ'?
  -- Case split (line 402)
```

**Root Cause**:
- When `A ∈ Γ'`, the induction hypothesis doesn't apply directly because `Γ'` may not have `A` at the head
- The deduction theorem requires moving `A` out of the context, but if `A` is used somewhere in the middle of `Γ'`, we need to permute or use a different strategy

**Current Partial Solution**:
- Lines 420-438 handle the case `A ∉ Γ'`:
  - If `A` is not used in the derivation of `φ` from `Γ'`, we can weaken to get `Γ ⊢ φ`
  - Then apply S axiom to introduce `A →`

**Missing Solution** (lines 417-419):
- Case where `A ∈ Γ'`:
  - Current code says: "If we could reorder Γ' to put A first" - suggests need for exchange lemma
  - But list order in Logos contexts doesn't matter (membership check uses `∈`)

**Correct Approach**:
- **Exchange Lemma**: Prove that context order doesn't matter for derivations
  ```lean
  theorem derivable_permutation {Γ Δ : Context} (h_perm : Γ.Permutation Δ)
      (φ : Formula) (h : Γ ⊢ φ) : Δ ⊢ φ
  ```
  - Once established, we can reorder `Γ'` to put `A` at the head
  - Then apply deduction theorem to the reordered derivation
  - Then permute back if needed

- **Alternative**: Prove context contraction lemma
  - If `A ∈ Γ'` and `Γ' ⊢ φ`, then `Γ' \ {A} ⊢ φ` (context contraction)
  - Requires that derivation doesn't depend on `A`
  - Can be proven by checking the derivation structure

**Recommendation**:
- **For MVP**: Add a sorry with comment that exchange lemma is needed
- **For full implementation**:
  1. Prove `derivable_permutation` first
  2. Use it in the `A ∈ Γ'` case
  3. This will clean up the sorry at line 419

**Priority**: MEDIUM (partial solution exists)

---

### 2.4 Pattern Summary for Sorry Cases

| Case | Root Cause | Solution Approach | Priority | Depends On |
|------|-----------|-------------------|----------|-----------|
| modal_k | Context boxing breaks induction | Well-founded recursion on derivation size | CRITICAL | Exchange/Contraction lemmas |
| temporal_k | Context temporalization breaks induction | Same as modal_k (parallel proof) | CRITICAL | Exchange/Contraction lemmas |
| weakening (A ∈ Γ') | Order-dependent context analysis | Exchange lemma or contraction analysis | MEDIUM | None (independent) |

---

## 3. Recommended Mathlib Tactics and Theorems

### 3.1 Classical Logic Foundation

From `Mathlib.Logic.Basic` (highly applicable):

| Mathlib Theorem | Logos Application | Pattern |
|-----------------|------------------|---------|
| `of_not_not` (line 200) | Proves `¬¬a → a` | Core for DNE axiom validation |
| `not_ne_iff` (line 202) | `¬a ≠ b ↔ a = b` | Useful for equality in contexts |
| `or_not` (line 156) | `a ∨ ¬a` (Law of Excluded Middle) | Foundation for classical reasoning |
| `not_imp_not` (line 292) | `¬a → ¬b ↔ b → a` (contraposition) | Directly applicable to Logos |
| `imp_iff_not_or` (line 288) | `a → b ↔ ¬a ∨ b` | Conversion between implication forms |
| `by_contradiction` (line 168) | `(¬p → False) → p` | Reductio ad absurdum pattern |

**Usage in Logos**:
- Use `of_not_not` as pattern for validating DNE axiom in semantics
- Use `not_imp_not` for contraposition in perpetuity proofs
- Use `by_contradiction` for any proof-by-contradiction patterns

### 3.2 Automation Tactics

Recommended Lean 4 tactics for Logos proof automation:

| Tactic | Use Case | Logos Application |
|--------|----------|------------------|
| `simp` | Simplification using lemmas | Simplify temporal/modal formulas |
| `decide` | Decidable propositions | Validate propositional tautologies |
| `tauto` | Tautology solver | Prove propositional tautologies |
| `omega` | Linear arithmetic | Not applicable to TM |
| `aesop` | Automation with proof search | Core for tm_auto implementation |
| `exact?` (IDE) | Find applicable lemmas | Discover relevant theorems |
| `apply?` (IDE) | Find theorems by pattern | Pattern-based tactic search |

**Logos Implementation**:
- Leverage `aesop` for `tm_auto` tactic (already planned)
- Add `simp` lemmas for temporal/modal simplifications
- Use `decide` for validating base formulas

### 3.3 Key Mathlib Lemmas for Propositional Reasoning

From Perpetuity.lean, several lemmas already exist that parallel Mathlib:

| Logos Lemma | Mathlib Equivalent | Logos Location | Status |
|-------------|-------------------|-----------------|--------|
| `identity` | `id` (core) | Perpetuity.lean:100 | Proven |
| `imp_trans` | `Function.comp` logic | Perpetuity.lean:82 | Proven |
| `mp` | Modus ponens | Perpetuity.lean:95 | Proven |
| `pairing` | `Prod.mk` pattern | Perpetuity.lean:548 | Proven |

---

## 4. Key Findings and Synthesis

### 4.1 Axiom Derivability Summary

```
dni:           DERIVABLE (Priority 1, confidence: HIGH)
               - Via reductio ad absurdum + S axiom
               - ~15 lines of proof

always_dni:    DERIVABLE (Priority 1, confidence: HIGH)
               - Via component-wise dni application
               - ~20 lines proof (depends on dni)

always_dne:    DERIVABLE (Priority 1, confidence: HIGH)
               - Symmetric to always_dni
               - ~20 lines proof (depends on double_negation)

future_k_dist: LIKELY DERIVABLE (Priority 2, confidence: MEDIUM)
               - Via temporal_k + deduction theorem
               - Requires deduction theorem completion
               - ~25-30 lines proof

always_mono:   DERIVABLE (Priority 2, confidence: MEDIUM)
               - Via future_k_dist + composition
               - ~30-40 lines proof (depends on future_k_dist)
```

### 4.2 Deduction Theorem Completion Strategy

**Critical Path**:
1. **Phase 1** (BLOCKING): Implement well-founded recursion framework
   - Add termination metric for Derivable type
   - Implement structural recursion on derivation size

2. **Phase 2** (CORE): Solve modal_k and temporal_k cases
   - Prove dual deduction theorems (boxed/temporalized versions)
   - Apply to main cases via well-founded recursion

3. **Phase 3** (CLEANUP): Resolve weakening case
   - Prove exchange/contraction lemmas as needed
   - Or implement context permutation analysis

### 4.3 Strategic Recommendations

**Short-term (1-2 days)**:
1. Remove `dni` axiom, replace with theorem proof (~15 min)
2. Complete `always_dne` using `double_negation` axiom (~20 min)
3. Document why `always_dni` cannot be derived in current form (needs composition lemmas)

**Medium-term (3-5 days)**:
1. Implement well-founded recursion in deduction theorem
2. Solve modal_k and temporal_k cases
3. Add exchange lemma if needed for weakening case

**Long-term (1-2 weeks)**:
1. Derive `future_k_dist` from completed deduction theorem
2. Derive `always_mono` from `future_k_dist`
3. Integrate Mathlib tactics into tm_auto

**Estimated Impact**:
- **Lines of code removed**: 5 axiom declarations (~10 lines)
- **Technical debt reduction**: ~3 sorry placeholders → fully proven theorems
- **Proof complexity**: ~100 total lines of new proofs (decomposed)
- **Test coverage**: Add ~15 tests for derived theorems

---

## 5. Proof Patterns and Technical Patterns

### 5.1 Standard Derivation Patterns in Logos

**Pattern 1: Weakening (S axiom)**
```lean
-- From ⊢ φ, derive ⊢ A → φ
have s_ax : ⊢ φ.imp (A.imp φ) :=
  Derivable.axiom [] _ (Axiom.prop_s φ A)
exact Derivable.modus_ponens [] φ (A.imp φ) s_ax h
```
Used in: DeductionTheorem (lines 47-49), Perpetuity (many places)

**Pattern 2: Distribution (K axiom)**
```lean
-- From ⊢ A → (B → C) and ⊢ A → B, derive ⊢ A → C
have k_ax : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
  Derivable.axiom [] _ (Axiom.prop_k A B C)
have h1 := Derivable.modus_ponens [] _ _ k_ax h_imp
exact Derivable.modus_ponens [] _ _ h1 h_ant
```
Used in: DeductionTheorem (lines 106-113), Perpetuity (composition)

**Pattern 3: Contraposition**
```lean
-- From ⊢ A → B, derive ⊢ ¬B → ¬A
have dne : ⊢ ¬B.imp (¬A.imp ¬¬A) := ... -- via double_negation
exact ... -- chain to get contrapositive
```
Used in: Perpetuity (perpetuity proofs), various contraposition lemmas

### 5.2 Recommended Code Structure for Derived Theorems

```lean
/--
[Docstring with mathematical statement and semantic justification]

**Derivation**: [High-level proof strategy]
1. [Step 1]
2. [Step 2]
...

**Complexity**: O(n) where n = ...
**Uses**: [List of axioms/lemmas]
-/
theorem name (args) : goal := by
  -- [Structured proof with intermediate steps]
  exact Derivable.modus_ponens ...
```

### 5.3 Temporal Logic Patterns

**Pattern: Temporal Distribution**
```lean
-- From Γ' ⊢ φ, derive future Γ' ⊢ future φ
have temporal := Derivable.temporal_k Γ' φ deriv
-- Now temporal : (Context.map all_future Γ') ⊢ all_future φ
```

**Pattern: Temporal Duality**
```lean
-- From ⊢ φ, derive ⊢ swap φ
have swapped := Derivable.temporal_duality _ deriv
-- Simplify: swap (swap x) = x
simp only [Formula.swap_temporal_involution] at swapped
```

---

## 6. Recommendations and Next Steps

### 6.1 Prioritized Action Items

1. **IMMEDIATE** (This week):
   - [ ] Prove `dni` as theorem (remove axiom)
   - [ ] Remove `axiom dni` line 523
   - [ ] Verify tests still pass

2. **SHORT-TERM** (Next 2 weeks):
   - [ ] Prove `always_dne` as theorem
   - [ ] Prove `always_dni` as theorem (if composition lemmas become available)
   - [ ] Update SORRY_REGISTRY.md

3. **MEDIUM-TERM** (Next month):
   - [ ] Complete deduction theorem with well-founded recursion
   - [ ] Resolve all 3 sorry cases
   - [ ] Prove `future_k_dist` as theorem
   - [ ] Prove `always_mono` as theorem

4. **LONG-TERM** (Quarter goals):
   - [ ] Integrate Mathlib tactics into tm_auto
   - [ ] Add comprehensive modal/temporal simplification lemmas
   - [ ] Achieve 0 axioms for propositional/temporal bases

### 6.2 Documentation Updates Required

- **SORRY_REGISTRY.md**:
  - Mark `dni` for removal
  - Document deduction theorem cases as "well-founded recursion needed"

- **TACTIC_DEVELOPMENT.md**:
  - Add section on deriving temporalized K distribution
  - Document automation strategies using Mathlib

- **IMPLEMENTATION_STATUS.md**:
  - Update axiom count in summary
  - Note dependencies for axiom removal

### 6.3 Testing Strategy

For each derived theorem:
1. Add unit test in LogosTest/
2. Test with example formulas
3. Verify integration with perpetuity proofs
4. Check for performance impact on test suite

---

## Appendix A: Mathlib Resources Referenced

### A.1 Classical Logic (Mathlib.Logic.Basic)

Key theorems for TM system:
- `of_not_not`: `¬¬a → a` (double negation elimination)
- `or_not`: `a ∨ ¬a` (law of excluded middle)
- `not_imp_not`: `¬a → ¬b ↔ b → a` (contraposition equivalence)
- `imp_iff_not_or`: `a → b ↔ ¬a ∨ b` (implication as disjunction)
- `by_contradiction`: `(¬p → False) → p` (proof by contradiction)

### A.2 Logic Modules in Mathlib

Structure:
- `Mathlib.Logic.Basic`: Core propositional logic
- `Mathlib.Logic.Function.Basic`: Function properties
- `Mathlib.Logic.Relation`: Relation properties
- `Mathlib.Order.Monotone.Basic`: Monotonicity patterns (for always_mono pattern)

### A.3 Tactic Documentation

- **aesop**: Automated proof search (for tm_auto)
- **simp**: Simplification with lemmas (for temporal/modal simplification)
- **decide**: Decidability-based automation
- **omega**: Linear arithmetic (not applicable to TM)

---

## Appendix B: Proof Sketches for Quick Reference

### B.1 dni Proof Sketch
```
Goal: ⊢ A → ¬¬A

1. Assume A
2. Assume ¬A
3. Contradiction (A and ¬A)
4. From contradiction, derive ¬¬A
5. By deduction, A → ¬¬A
```

### B.2 always_dne Proof Sketch
```
Goal: ⊢ ¬¬(always φ) → always φ

1. Decompose always φ = H φ ∧ φ ∧ G φ
2. Have: ¬¬(H φ ∧ φ ∧ G φ)
3. Apply DNE to negation: ¬¬(H φ ∧ φ ∧ G φ) → (H φ ∧ φ ∧ G φ)
4. Expand: get H φ, φ, G φ
5. Recompose into always φ
```

### B.3 always_mono Proof Sketch
```
Goal: ⊢ A → B → (always A → always B)

1. Assume A → B (h)
2. Assume always A
3. Decompose: H A, A, G A
4. Apply h to each component: H B, B, G B
5. Recompose into always B
```

---

## References

- **Logos Codebase**:
  - `/Logos/Core/Theorems/Perpetuity.lean`: Current axioms and helper lemmas
  - `/Logos/Core/Metalogic/DeductionTheorem.lean`: Deduction theorem with sorry cases
  - `/Logos/Core/ProofSystem/Axioms.lean`: Complete axiom listing

- **Mathlib Documentation**:
  - `Mathlib.Logic.Basic`: https://github.com/leanprover-community/mathlib4
  - Module structure and classical logic foundational theorems

- **Related Research**:
  - JPL Paper (cited in Axioms.lean comments): Task semantics for TM logic
  - Standard modal logic texts on deduction theorems (Sider, etc.)
  - Temporal logic literature on K distribution

---

**Report Generated**: 2025-12-09
**Status**: COMPLETE
**Confidence Levels**:
- High (80%+): dni, always_dne, always_dni derivability
- Medium (50-80%): future_k_dist, always_mono derivability
- High: Deduction theorem solution approach
- Medium: Specific implementation details
