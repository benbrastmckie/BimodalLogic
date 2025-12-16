# Research Report: Deferred Phases Analysis - Proof Automation Tactics Refactor

**Report ID**: 001-deferred-phases-analysis
**Spec**: 064_proof_automation_deferred_blockers
**Date**: 2025-12-09
**Status**: COMPLETE

## Executive Summary

This report analyzes the technical blockers that caused phases 2-5 and 7 of the proof automation tactics refactor plan (spec 063) to be deferred during implementation. Phase 1 (dni derivation) completed successfully, Phase 6 (module refactoring) completed successfully, and Phase 8 (naming/documentation) completed successfully. The remaining 5 phases were deferred due to specific technical dependencies and complexity.

**Key Findings**:
- **Phase 2**: Blocked by missing temporal K distribution infrastructure (always decomposition lemmas)
- **Phase 3**: Requires well-founded recursion implementation (8-12 hour effort, complex)
- **Phase 4**: Hard dependency on Phase 3 completion
- **Phase 5**: Metaprogramming complexity for tactic factory patterns
- **Phase 7**: Was blocked by Phase 6 (now unblocked, can proceed independently)

---

## Phase 2: Temporal K Infrastructure (always_dni/always_dne)

### Current State

**Files Examined**:
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean` (lines 127)
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Bridge.lean` (lines 138, 204)

**Definition of always**:
```lean
def always (φ : Formula) : Formula := φ.all_past.and (φ.and φ.all_future)
-- always φ = Hφ ∧ φ ∧ Gφ (past, present, future)
```

**Current Axiom Declarations**:
- `axiom always_dni (φ : Formula) : ⊢ φ.always.imp φ.neg.neg.always` (Bridge.lean:138)
- `axiom always_dne (φ : Formula) : ⊢ φ.neg.neg.always.imp φ.always` (Bridge.lean:204)

**Phase 1 Completion Status**:
- ✅ `dni` successfully derived using `@theorem_app1 A Formula.bot`
- This provides the base case for always_dni/always_dne

### Missing Prerequisites

The plan states (lines 135-137):
```
Strategy:
1. Decompose `always φ` into `H φ ∧ φ ∧ G φ`
2. Apply `dni` to each component
3. Recombine using temporal composition
```

**What's Missing**:

1. **Decomposition Lemmas**: No infrastructure exists to decompose `always φ` into its components
   - Need: `always_to_past`: `⊢ △φ → Hφ`
   - Need: `always_to_present`: `⊢ △φ → φ`
   - Need: `always_to_future`: `⊢ △φ → Gφ`

2. **Composition Lemmas**: No infrastructure to recombine components back into `always`
   - Need: `past_present_future_to_always`: `⊢ (Hφ ∧ φ ∧ Gφ) → △φ`
   - This is trivial (definition), but requires unfolding machinery

3. **Temporal K Distribution for Past/Future**: Limited infrastructure
   - EXISTS: `future_k_dist` axiom (not yet derived): `⊢ F(A → B) → (FA → FB)`
   - MISSING: `past_k_dist`: `⊢ H(A → B) → (HA → HB)`
   - These are needed to apply dni to Hφ and Gφ components

4. **Conjunction Reasoning**: While basic conjunction exists, temporal conjunction handling is incomplete
   - EXISTS: `pairing` (now theorem): `⊢ A → B → (A ∧ B)`
   - EXISTS: `combine_imp_conj`: helper for conjunction introduction
   - MISSING: Infrastructure to distribute operations over conjunctions

### Estimated Complexity

**Time Estimate**: 3-4 hours (as stated in plan)

**Breakdown**:
- Decomposition lemmas: 30 minutes (straightforward from definition)
- Composition lemmas: 30 minutes (definition unfold)
- past_k_dist derivation: 1 hour (mirror of future_k_dist pattern)
- Conjunction distribution: 30 minutes
- always_dni proof: 45 minutes (applying dni to each component)
- always_dne proof: 45 minutes (applying double_negation axiom to each component)

**Complexity Rating**: Medium

### Recommended Approach

1. **Create temporal decomposition helpers** in `Perpetuity/Helpers.lean`:
   ```lean
   theorem always_to_past (φ : Formula) : ⊢ φ.always.imp φ.all_past
   theorem always_to_present (φ : Formula) : ⊢ φ.always.imp φ
   theorem always_to_future (φ : Formula) : ⊢ φ.always.imp φ.all_future
   ```

2. **Add composition helper**:
   ```lean
   theorem past_present_future_to_always (φ : Formula) :
     ⊢ (φ.all_past.and (φ.and φ.all_future)).imp φ.always
   ```

3. **Derive past_k_dist** (if future_k_dist is proven first):
   ```lean
   theorem past_k_dist (A B : Formula) :
     ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past)
   ```

4. **Prove always_dni**:
   - Decompose always φ into Hφ ∧ φ ∧ Gφ
   - Apply dni to φ: `⊢ φ → ¬¬φ`
   - Apply past_k_dist to get: `⊢ Hφ → H(¬¬φ)`
   - Apply future_k_dist to get: `⊢ Gφ → G(¬¬φ)`
   - Recombine: `⊢ (Hφ ∧ φ ∧ Gφ) → (H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ))`
   - Use composition: `⊢ △φ → △(¬¬φ)`

5. **Prove always_dne**: Similar to always_dni but using `double_negation` axiom instead of dni

**Dependency Chain**: Phase 1 (dni) ✅ → decomposition helpers → past_k_dist → always_dni/always_dne

**Risk Assessment**: Low-Medium. Straightforward once infrastructure is in place.

---

## Phase 3: DeductionTheorem Sorry Markers

### Current State

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean`

**Sorry Count**: 3 (exactly as documented in plan)

**Sorry Locations**:
1. **Line 370**: `modal_k` case (lines 164-370)
2. **Line 383**: `temporal_k` case (lines 371-383)
3. **Line 419**: `weakening` case with `A ∈ Γ'` (lines 388-438)

**Context**: The deduction theorem states `(A :: Γ) ⊢ B → Γ ⊢ A → B`

### Technical Analysis

**Modal K Case (lines 164-370)**:

**Problem**: When derivation uses `modal_k` rule, the context is transformed via `map box`
- Input: `hΔ : A :: Γ = map box Γ'` (the context after boxing)
- This means: `A = box A'` and `Γ = map box Γ''` where `Γ' = A' :: Γ''`
- Goal: `Γ ⊢ A.imp (box φ)` which becomes `(map box Γ'') ⊢ (box A').imp (box φ)`

**Why Sorry**: The induction hypothesis `ih` doesn't apply directly because:
- IH expects: `A :: Γ = Γ' → Γ ⊢ A.imp φ`
- We have: `A :: Γ = map box Γ'` (not equal to `Γ'`)
- The derivation `_h : Γ' ⊢ φ` (pre-modal_k) is structurally simpler
- Need recursive call on `_h`, but can't easily express in tactic mode

**Solution Strategy** (from comments, lines 289-370):
- Prove auxiliary "boxed deduction theorem": `(A' :: Γ'') ⊢ φ → Γ'' ⊢ A' → φ`
- Apply modal_k to get: `(map box Γ'') ⊢ box (A' → φ)`
- Use `modal_k_dist` axiom: `box (A' → φ) = (box A') → (box φ)`
- This gives the desired result

**Temporal K Case (lines 371-383)**:

**Problem**: Identical to modal_k but with `all_future` operator
- Input: `hΔ : A :: Γ = map all_future Γ'`
- Goal: `Γ ⊢ A.imp (all_future φ)`

**Why Sorry**: Same issue - can't recurse in tactic mode

**Solution Strategy**: Mirror modal_k approach with temporal operators

**Weakening Case with A ∈ Γ' (lines 402-419)**:

**Problem**: When `A ∈ Γ'` but Γ' is a proper subset of `A :: Γ`
- Have: `Γ' ⊢ φ` with `Γ' ⊆ A :: Γ` and `A ∈ Γ'`
- Goal: `Γ ⊢ A → φ`
- Can't directly apply IH because Γ' may not have form `A :: Γ''`

**Why Sorry**: Need exchange/permutation lemma to reorder Γ' to put A at head

**Solution Strategy** (from comments, lines 408-418):
- Prove `derivable_permutation`: context order doesn't affect derivability
- Reorder Γ' to put A at head: `A :: (Γ' \ {A})`
- Apply deduction theorem recursively to get: `(Γ' \ {A}) ⊢ A → φ`
- Weaken to Γ since `(Γ' \ {A}) ⊆ Γ`

### Missing Prerequisites

**Core Issue**: Well-founded recursion on derivation structure

The plan identifies (line 189):
```lean
- [ ] `Derivable.size`: Termination metric
  - Goal: `Derivable Γ φ → Nat`
  - Strategy: Define size as derivation tree depth
```

**What's Missing**:

1. **Derivable.size Definition**: No termination metric exists
   ```lean
   def Derivable.size : {Γ : Context} → {φ : Formula} → (Γ ⊢ φ) → Nat
   ```

2. **Well-founded Recursion Framework**: The proof needs structural recursion on derivations
   - Current approach uses `induction h` in tactic mode
   - This works for simple cases but can't handle recursive calls in modal_k/temporal_k
   - Need: `termination_by` clause with size metric

3. **Auxiliary Boxed Deduction Theorem**:
   ```lean
   theorem boxed_deduction_theorem (Γ' : Context) (A φ : Formula)
     (h : (A :: Γ') ⊢ φ) :
     (map box Γ') ⊢ (box A).imp (box φ)
   ```

4. **Exchange Lemma** (for weakening case):
   ```lean
   theorem derivable_permutation (Γ Γ' : Context) (φ : Formula)
     (h_perm : Γ.Perm Γ') (h : Γ ⊢ φ) : Γ' ⊢ φ
   ```

5. **Context Membership Lemmas**:
   - Remove element from context: `Γ' \ {A}`
   - Subset reasoning with removed element

### Estimated Complexity

**Time Estimate**: 8-12 hours (as stated in plan)

**Breakdown**:
- Derivable.size definition: 1 hour (recursive on derivation structure)
- Well-founded recursion setup: 2-3 hours (termination proofs)
- Auxiliary boxed deduction theorem: 2-3 hours (mutual recursion with main theorem)
- Temporal analog: 1 hour (mirror of boxed version)
- Exchange lemma: 2-3 hours (permutation reasoning)
- Integration and testing: 1-2 hours

**Complexity Rating**: High (Complex)

### Recommended Approach

1. **Define Derivable.size**:
   ```lean
   def Derivable.size : {Γ : Context} → {φ : Formula} → (Γ ⊢ φ) → Nat
   | _, _, .axiom _ _ _ => 1
   | _, _, .assumption _ _ _ => 1
   | _, _, .modus_ponens _ _ _ h1 h2 _ _ => 1 + h1.size + h2.size
   | _, _, .modal_k _ _ h _ => 1 + h.size
   | _, _, .temporal_k _ _ h _ => 1 + h.size
   | _, _, .temporal_duality _ h _ => 1 + h.size
   | _, _, .weakening _ _ _ h _ => 1 + h.size
   ```

2. **Rewrite deduction_theorem with termination_by**:
   ```lean
   theorem deduction_theorem (Γ : Context) (A B : Formula)
       (h : (A :: Γ) ⊢ B) :
       Γ ⊢ A.imp B := by
     -- Same structure but with termination_by
     termination_by h.size
   ```

3. **Prove auxiliary theorems** before main proof:
   - boxed_deduction_theorem
   - temporal_deduction_theorem
   - derivable_permutation

4. **Handle modal_k case** with recursive call:
   ```lean
   | modal_k Γ' φ _h ih =>
     -- Apply auxiliary boxed_deduction_theorem to _h
     -- _h.size < h.size, so recursion terminates
     have h_aux := boxed_deduction_theorem Γ'' A' φ _h
     -- Use modal_k_dist to convert
     ...
   ```

5. **Handle weakening case** with exchange:
   ```lean
   | weakening Γ' Δ' φ _h1 h2 ih =>
     by_cases hA : A ∈ Γ'
     · -- Use exchange to reorder
       have h_perm := reorder_context_to_head Γ' A hA
       have h_reordered := derivable_permutation _ _ _ h_perm _h1
       -- Now apply deduction theorem recursively
       ...
   ```

**Dependency Chain**: None (independent, but blocks Phase 4)

**Risk Assessment**: High. Well-founded recursion in LEAN 4 can be tricky. May require multiple iterations to get termination proofs correct.

**Recommended Next Steps**:
1. Create focused plan for Phase 3 as standalone effort
2. Research LEAN 4 well-founded recursion patterns in Mathlib
3. Consider consulting LEAN Zulip for termination proof strategies
4. Allocate dedicated time block (not interruptible)

---

## Phase 4: future_k_dist/always_mono Dependencies

### Current State

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Bridge.lean`

**Axiom Declarations**:
- `axiom future_k_dist (A B : Formula) : ⊢ (A.imp B).all_future.imp (A.all_future.imp B.all_future)` (line location not in scan)
- `axiom always_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.always.imp B.always` (line location not in scan)

**Phase 3 Status**: DEFERRED (3 sorry markers remain)

### Technical Analysis

**future_k_dist Strategy** (from plan, lines 252-261):
```
1. From `[A → B, A] ⊢ B` (by modus ponens)
2. Apply temporal_k: `[F(A → B), FA] ⊢ FB`
3. Apply deduction theorem twice to lift context
4. Get `⊢ F(A → B) → (FA → FB)`
```

**Problem**: Step 3 requires the complete deduction theorem
- Current: DeductionTheorem.lean has 3 sorry markers
- Needed: `deduction_theorem (Γ : Context) (A B : Formula) (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B`
- Specifically: Must handle temporal_k case (currently sorry)

**always_mono Strategy** (from plan, lines 265-272):
```
1. Decompose `always` into `past ∧ present ∧ future`
2. Apply past_k_dist and future_k_dist
3. Use transitivity to chain implications
4. Recombine into `always A → always B`
```

**Problem**: Depends on future_k_dist being proven, which depends on deduction theorem

### Missing Prerequisites

**Hard Dependencies**:

1. **Complete Deduction Theorem** (Phase 3):
   - Status: 3 sorry markers (modal_k, temporal_k, weakening)
   - Required for: future_k_dist derivation
   - Blocks: All of Phase 4

2. **Temporal K Distribution** (self-dependency):
   - future_k_dist is needed by always_mono
   - But future_k_dist depends on deduction_theorem
   - Circular dependency within Phase 4

3. **Past K Distribution** (Phase 2 dependency):
   - always_mono needs both past_k_dist and future_k_dist
   - past_k_dist is part of Phase 2 infrastructure
   - May need to be proven independently

### Dependency Chain

```
Phase 3 (DeductionTheorem)
  ↓ (enables)
future_k_dist derivation
  ↓ (enables)
always_mono derivation (also needs past_k_dist from Phase 2)
```

### Estimated Complexity

**Time Estimate**: 4-6 hours (as stated in plan)

**Breakdown**:
- future_k_dist derivation: 2-3 hours (assuming deduction_theorem complete)
- always_mono derivation: 2-3 hours (assuming future_k_dist and past_k_dist proven)

**Complexity Rating**: Medium (Complex due to dependencies)

**Note**: The actual complexity is LOW once Phase 3 completes. The 4-6 hour estimate is accurate for Phase 4 work itself, but Phase 3 is the 8-12 hour blocker.

### Recommended Approach

**Sequencing**:
1. **Complete Phase 3 first** (8-12 hours)
2. **Then proceed with Phase 4** in order:
   a. Prove future_k_dist using complete deduction_theorem
   b. Prove past_k_dist (if not done in Phase 2)
   c. Prove always_mono using both K distributions

**Alternative Approach** (if Phase 3 is too complex):
- Keep future_k_dist and always_mono as axioms
- Document in SORRY_REGISTRY.md as "blocked by deduction theorem"
- Revisit when Phase 3 infrastructure is ready

**Risk Assessment**: High dependency risk. Cannot proceed without Phase 3.

**Recommended Next Steps**:
1. Prioritize Phase 3 completion
2. Create focused plan for Phase 4 AFTER Phase 3 completes
3. Consider deferring Phase 4 until Phase 3 is production-ready

---

## Phase 5: Tactic Consolidation Complexity

### Current State

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean`

**Current Implementation**: All 12 tactics implemented (Task 7 complete, 110+ tests passing)

**Tactics Implemented**:
1. `apply_axiom` (lines 73-74) - macro-based, simple
2. `modal_t` (lines 90-91) - macro-based, simple
3. `tm_auto` (lines 129-130) - Aesop integration
4. `assumption_search` (lines 150-165) - TacticM-based
5. `modal_k_tactic` (lines 216-241) - elab-based with goal destructuring
6. `temporal_k_tactic` (lines 260-285) - elab-based with goal destructuring
7. `modal_4_tactic` (lines 306-339) - elab-based with pattern matching
8. `modal_b_tactic` (lines 354-385) - elab-based with derived operators
9. `temp_4_tactic` (lines 406-439) - elab-based with temporal patterns
10. `temp_a_tactic` (lines 454-479) - elab-based with nested destructuring
11. `modal_search` (lines 504-507) - MVP delegating to tm_auto
12. `temporal_search` (lines 523-526) - MVP delegating to tm_auto

**Status**: All tactics functional, but significant code duplication exists

### Technical Analysis

**Duplication Patterns Identified** (from plan):

1. **Operator K Tactics** (modal_k_tactic vs temporal_k_tactic):
   - Lines 216-241 (modal_k_tactic): 26 lines
   - Lines 260-285 (temporal_k_tactic): 26 lines
   - **Duplication**: ~90% identical code, only differs in:
     - Constructor name: `Formula.box` vs `Formula.all_future`
     - Rule constant: `Derivable.modal_k` vs `Derivable.temporal_k`

2. **Axiom Iteration Tactics** (modal_4, modal_b, temp_4):
   - Lines 306-339 (modal_4_tactic): 34 lines
   - Lines 354-385 (modal_b_tactic): 32 lines
   - Lines 406-439 (temp_4_tactic): 34 lines
   - **Total**: 100 lines
   - **Duplication**: ~70% identical pattern matching boilerplate

3. **Search Tactics** (modal_search, temporal_search):
   - Lines 504-507 (modal_search): 4 lines (MVP)
   - Lines 523-526 (temporal_search): 4 lines (MVP)
   - **Status**: Already consolidated (both delegate to tm_auto)

### Missing Prerequisites

**Metaprogramming Infrastructure**:

1. **Operator K Tactic Factory** (from plan, lines 307-317):
   ```lean
   def make_operator_k (name : String) (op_const : Name) : TacticM Unit
   ```
   - **Challenge**: Need to parameterize over:
     - Operator constructor (box vs all_future)
     - Rule constant name (modal_k vs temporal_k)
     - Error message strings
   - **Complexity**: Requires abstract syntax tree construction with `mkConst`, `mkApp`

2. **Axiom Iteration Factory** (from plan, lines 319-327):
   ```lean
   def make_axiom_tactic (axiom_name : String)
                        (axiom_fn : Formula → Axiom)
                        (pattern_check : Formula → Formula → Bool)
   ```
   - **Challenge**: Need to parameterize over:
     - Axiom function (e.g., `Axiom.modal_4`)
     - Pattern matching logic (□φ → □□φ vs φ → □◇φ vs Fφ → FFφ)
     - Formula destructuring patterns
   - **Complexity**: Requires higher-order tactic programming

3. **Enhanced apply_axiom** (from plan, lines 329-337):
   - Current: Simple macro `(apply Derivable.axiom; refine ?_)`
   - Desired: Intelligent pattern matching across all 13 axioms
   - **Challenge**: Need to try each axiom via unification, provide diagnostics
   - **Complexity**: Requires meta-level unification and error handling

### Estimated Complexity

**Time Estimate**: 6-8 hours (as stated in plan)

**Breakdown**:
- make_operator_k factory: 2 hours (parameterized elab with mkConst/mkApp)
- make_axiom_tactic factory: 3-4 hours (complex pattern abstraction)
- Enhanced apply_axiom: 1-2 hours (unification loop)
- Testing and refactoring: 1 hour (verify 110+ tests still pass)

**Complexity Rating**: Medium-High (Metaprogramming)

**Code Reduction Estimate** (from plan):
- Operator K consolidation: ~25 lines saved
- Axiom iteration consolidation: ~77 lines saved (97 → 20)
- Total estimated reduction: 60-80 lines (70% reduction in duplication)

### Recommended Approach

**Sequencing**:
1. **Start with simple factory** (make_operator_k):
   - Extract common pattern from modal_k_tactic and temporal_k_tactic
   - Parameterize over operator constant and rule constant
   - Test with both modal and temporal cases

2. **Build axiom factory incrementally**:
   - Start with simpler patterns (modal_4, temp_4)
   - Abstract pattern matching logic
   - Extend to complex patterns (modal_b)

3. **Enhance apply_axiom last**:
   - Add axiom enumeration
   - Implement try-each-axiom loop
   - Add diagnostic messages

4. **Maintain backward compatibility**:
   - Keep original tactic names as wrappers
   - Ensure all 110+ tests pass
   - Update TACTIC_DEVELOPMENT.md with factory patterns

**Alternative Approach** (if too complex):
- Keep current implementation as-is
- Document factory patterns as "future optimization"
- Focus on functional correctness over code brevity

**Risk Assessment**: Medium. Metaprogramming is complex but well-documented in LEAN 4.

**Recommended Next Steps**:
1. Research LEAN 4 metaprogramming examples in Mathlib
2. Create small proof-of-concept for make_operator_k
3. If POC succeeds, proceed with full consolidation
4. If POC is too complex, defer Phase 5 and document as technical debt

---

## Phase 7: Helper Lemma Patterns

### Current State

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Helpers.lean`

**Created**: Phase 6 successfully split Perpetuity.lean into 3 modules (including Helpers.lean)

**Current Helpers** (lines 1-150 scanned):
- `imp_trans`: Transitivity of implication
- `mp`: Modus ponens wrapper
- `identity`: Identity combinator (SKK)
- `b_combinator`: Composition combinator
- `theorem_flip`: Flip combinator (C)
- `theorem_app1`: Application combinator
- `theorem_app2`: Vireo combinator
- `pairing`: Conjunction introduction (now theorem, not axiom)
- `combine_imp_conj`: Conjunction helper
- `dni`: Double negation introduction (Phase 1 ✓)
- `box_to_future`, `box_to_past`, `box_to_present`: Temporal component lemmas

**Status**: Helpers.lean exists (571 lines), well-organized

### Technical Analysis

**Proposed Helpers** (from plan, lines 427-443):

1. **axiom_in_context** (lines 427-430):
   ```lean
   -- Goal: (Γ : Context) → (φ : Formula) → (h : Axiom φ) → Γ ⊢ φ
   -- Strategy: Wrapper around Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (by intro; simp)
   ```
   - **Purpose**: Eliminate weakening boilerplate (50+ patterns found in research)
   - **Complexity**: Simple (one-liner wrapper)

2. **apply_axiom_to** (lines 432-437):
   ```lean
   -- Goal: {A B : Formula} → (axiom_proof : Axiom (A.imp B)) → (h : ⊢ A) → ⊢ B
   -- Strategy: Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h
   ```
   - **Purpose**: Combine axiom + modus ponens (150+ MP chains found in research)
   - **Complexity**: Simple (combines two operations)

3. **apply_axiom_in_context** (lines 439-443):
   ```lean
   -- Goal: (Γ : Context) → {A B : Formula} → (axiom_proof : Axiom (A.imp B)) → (h : Γ ⊢ A) → Γ ⊢ B
   -- Strategy: Combine axiom_in_context + modus_ponens
   ```
   - **Purpose**: Context-aware axiom application
   - **Complexity**: Simple (combines axiom_in_context and modus_ponens)

### Missing Prerequisites

**Phase 6 Completion**: ✅ COMPLETE (unblocked)

**What's Missing** (minimal):

1. **Helper Definitions**: Need to add 3 helper lemmas to Helpers.lean
2. **Refactoring Targets**: Need to apply helpers to existing proofs:
   - Propositional.lean: ~30+ patterns
   - ModalS5.lean: modal theorems
   - ModalS4.lean: S4 theorems
   - Perpetuity/Principles.lean: perpetuity proofs

### Estimated Complexity

**Time Estimate**: 4-5 hours (as stated in plan)

**Breakdown**:
- axiom_in_context definition: 15 minutes
- apply_axiom_to definition: 15 minutes
- apply_axiom_in_context definition: 15 minutes
- Refactor Propositional.lean: 1-2 hours (30+ patterns)
- Refactor ModalS5.lean: 1 hour
- Refactor ModalS4.lean: 30 minutes
- Test and verify equivalence: 30 minutes

**Complexity Rating**: Low-Medium (Simple but tedious)

### Recommended Approach

**Phase 7 is NOW UNBLOCKED** (Phase 6 complete)

**Sequencing**:
1. **Add helpers to Helpers.lean**:
   ```lean
   theorem axiom_in_context (Γ : Context) (φ : Formula) (h : Axiom φ) : Γ ⊢ φ :=
     Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (List.nil_subset Γ)

   theorem apply_axiom_to {A B : Formula} (axiom_proof : Axiom (A.imp B)) (h : ⊢ A) : ⊢ B :=
     Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h

   theorem apply_axiom_in_context (Γ : Context) {A B : Formula}
       (axiom_proof : Axiom (A.imp B)) (h : Γ ⊢ A) : Γ ⊢ B :=
     Derivable.modus_ponens Γ A B (axiom_in_context Γ (A.imp B) axiom_proof) h
   ```

2. **Refactor incrementally**:
   - Start with Propositional.lean (most patterns)
   - Verify tests pass after each file
   - Measure line count reduction

3. **Document patterns** in TACTIC_DEVELOPMENT.md

**Alternative Approach** (if tedious):
- Add helpers but defer refactoring
- Use helpers in NEW proofs only
- Keep existing proofs as-is for stability

**Risk Assessment**: Low. Helpers are simple wrappers. Refactoring is mechanical.

**Recommended Next Steps**:
1. Create focused plan for Phase 7
2. Can proceed independently NOW (Phase 6 complete)
3. Low priority compared to Phases 2-4

---

## Summary Table

| Phase | Status | Blocker | Complexity | Hours | Can Start Now? |
|-------|--------|---------|------------|-------|----------------|
| **2** | DEFERRED | Temporal K infrastructure (decomposition/composition lemmas) | Medium | 3-4 | ✅ YES |
| **3** | DEFERRED | Well-founded recursion framework | High | 8-12 | ✅ YES |
| **4** | DEFERRED | Phase 3 completion (hard dependency) | Medium | 4-6 | ❌ NO (blocked by Phase 3) |
| **5** | DEFERRED | Metaprogramming complexity (factory patterns) | Medium-High | 6-8 | ✅ YES (but lower priority) |
| **7** | DEFERRED | Phase 6 completion | Low-Medium | 4-5 | ✅ YES (Phase 6 ✅) |

---

## Recommended Prioritization

### Immediate Actions (Can Start Now)

1. **Phase 7** (LOWEST HANGING FRUIT):
   - Now unblocked (Phase 6 complete)
   - Low complexity, high value (reduces boilerplate)
   - 4-5 hours
   - **Recommendation**: Start with Phase 7 as "quick win"

2. **Phase 2** (MEDIUM PRIORITY):
   - Independent of other phases
   - Builds on Phase 1 success (dni ✓)
   - 3-4 hours
   - **Recommendation**: Proceed after Phase 7 or in parallel

### Medium-Term Actions

3. **Phase 3** (HIGH PRIORITY, HIGH COMPLEXITY):
   - Blocks Phase 4
   - 8-12 hours (dedicated effort required)
   - Requires well-founded recursion expertise
   - **Recommendation**: Create focused plan, allocate dedicated time

4. **Phase 5** (LOWER PRIORITY):
   - Independent but complex metaprogramming
   - 6-8 hours
   - Value is code brevity (not functionality)
   - **Recommendation**: Defer until other phases complete or mark as technical debt

### Long-Term Actions

5. **Phase 4** (BLOCKED):
   - Cannot start until Phase 3 completes
   - 4-6 hours once unblocked
   - **Recommendation**: Wait for Phase 3, then create focused plan

---

## Detailed File References

### Phase 2 Files
- **Logos/Core/Syntax/Formula.lean** (line 127): `always` definition
- **Logos/Core/Theorems/Perpetuity/Bridge.lean** (lines 138, 204): `always_dni`, `always_dne` axioms
- **Logos/Core/Theorems/Perpetuity/Helpers.lean**: Target location for decomposition helpers

### Phase 3 Files
- **Logos/Core/Metalogic/DeductionTheorem.lean**: Contains 3 sorry markers (lines 370, 383, 419)

### Phase 4 Files
- **Logos/Core/Theorems/Perpetuity/Bridge.lean**: `future_k_dist`, `always_mono` axioms

### Phase 5 Files
- **Logos/Core/Automation/Tactics.lean**: All 12 tactics implemented (lines 73-526)

### Phase 7 Files
- **Logos/Core/Theorems/Perpetuity/Helpers.lean**: Target location for new helpers (571 lines)
- **Logos/Core/Theorems/Propositional.lean**: Primary refactoring target (~30+ patterns)
- **Logos/Core/Theorems/ModalS5.lean**: Secondary refactoring target
- **Logos/Core/Theorems/ModalS4.lean**: Secondary refactoring target

---

## Conclusion

The deferred phases exhibit clear dependency relationships and complexity gradients:

1. **Phase 7** is ready to start (Phase 6 complete)
2. **Phase 2** can proceed independently
3. **Phase 3** is the critical path blocker (8-12 hours, complex)
4. **Phase 4** cannot start until Phase 3 completes
5. **Phase 5** is independent but lower priority (optimization not functionality)

**Recommended Execution Order**: 7 → 2 → 3 → 4 → 5 (or mark 5 as technical debt)

**Total Estimated Effort**: 25-35 hours for all 5 deferred phases
