# Lean Implementation Plan: Proof Automation Completion (Remaining Tasks)

## Metadata
- **Plan ID**: 065-001-revised
- **Date**: 2025-12-10
- **Feature**: Complete remaining proof automation tasks (blocked phases)
- **Scope**: DeductionTheorem completion, temporal axiom derivation, temporal K infrastructure
- **Status**: [BLOCKED - 0/3 REMAINING]
- **Estimated Hours**: 16-22 hours (remaining)
- **Actual Hours**: ~8 hours (prior iterations)
- **Complexity Score**: 4 (High - well-founded recursion, temporal infrastructure)
- **Structure Level**: 0
- **Estimated Phases**: 3 (remaining)
- **Phases Completed**: 0 (of remaining)
- **Phases Blocked**: 3 (all currently blocked)
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Prior Plan**: 063_proof_automation_tactics_refactor (3/8 phases complete)
- **Research Reports**:
  - [001-deferred-phases-analysis.md](../reports/001-deferred-phases-analysis.md): Detailed technical blockers for 5 deferred phases
- **Execution Summaries**:
  - [001_wave_1_summary.md](../summaries/001_wave_1_summary.md): Phase 1 completion
  - [iteration_2_phase3_assessment.md](../summaries/iteration_2_phase3_assessment.md): Phase 3 blocker analysis
  - [iteration_3_summary.md](../summaries/iteration_3_summary.md): Phase 2 circular dependency discovery
  - [iteration_4_summary.md](../summaries/iteration_4_summary.md): Phase 5 completion
- **Completed Prior Work** (removed from this plan):
  - Phase 1: Helper Lemma Infrastructure ✓
  - Phase 5: Tactic Consolidation ✓

## Executive Summary

This plan contains the **remaining blocked phases** from the proof automation refactor, reorganized by dependency order.

**Dependency Chain** (remaining phases only):
```
Phase 1 (DeductionTheorem) ─── No dependencies, but requires recursion expertise
         │
         ▼
Phase 2 (Temporal Axiom Derivation) ─── Depends on Phase 1
         │
         ▼
Phase 3 (Temporal K Infrastructure) ─── Depends on Phase 2 + architectural refactoring
```

**Critical Path**: Phase 1 (DeductionTheorem) is the key blocker. All other phases depend on it.

**Recommended Execution Order**: 1 → 2 → 3

---

## Blocker Summary

### Phase 1 (DeductionTheorem) - PRIMARY BLOCKER
- **Issue**: Requires well-founded recursion expertise
- **Technical**: No `termination_by` patterns in codebase, `List.Perm` integration needed
- **Resolution**: Human expert session (4-6 hours) or Lean Zulip consultation

### Phase 2 (Temporal Axiom Derivation) - BLOCKED BY PHASE 1
- **Issue**: `future_k_dist` derivation requires complete deduction theorem
- **Resolution**: Complete Phase 1 first

### Phase 3 (Temporal K Infrastructure) - BLOCKED BY PHASE 2 + ARCHITECTURE
- **Issue**: Circular dependency: `Bridge.lean` → `DeductionTheorem.lean` → `Perpetuity` module
- **Resolution**: Extract `lce_imp`, `rce_imp` to separate module after Phase 2

## Success Criteria

### Module Completion (Remaining)
- [ ] 4 remaining axioms proven as theorems (always_dni, always_dne, future_k_dist, always_mono) **[BLOCKED]**
- [ ] All 3 DeductionTheorem sorry cases resolved **[BLOCKED]**

### Quality Standards
- [ ] Zero build errors (`lake build` succeeds after each phase)
- [ ] Zero `sorry` markers in modified modules
- [ ] All new theorems have docstrings with mathematical statements
- [ ] Zero test failures after each phase (`lake test`)

### Documentation
- [ ] IMPLEMENTATION_STATUS.md updated with axiom count (reduce by 4 after derivations)
- [ ] SORRY_REGISTRY.md updated (remove 3 DeductionTheorem entries)

---

## Implementation Phases

### Phase Routing Summary (Remaining Phases)
| Phase | Type | Implementer Agent | Hours | Risk | Dependencies |
|-------|------|-------------------|-------|------|--------------|
| 1 | lean | lean-implementer | 8-12 | High | None (but needs expertise) |
| 2 | lean | lean-implementer | 4-6 | Medium | Phase 1 |
| 3 | lean | lean-implementer | 3-4 | Medium | Phase 2 + architectural refactoring |

---

### Phase 1: DeductionTheorem Sorry Resolution [BLOCKED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Metalogic/DeductionTheorem.lean
dependencies: []

**Status**: BLOCKED - Requires well-founded recursion expertise
**Blocker**: No existing `termination_by` patterns in codebase, `List.Perm` integration needed
**Assessment**: See summaries/iteration_2_phase3_assessment.md
**Recommendation**: Human expert session (4-6 hours) with Lean 4 recursion expertise

**Effort**: 8-12 hours

**Objective**: Resolve all 3 sorry cases using well-founded recursion (from original Phase 3)

**Background**:
The deduction theorem has 3 sorry markers in complex cases:
1. **modal_k case** (line 370): Context transformed via `map box`
2. **temporal_k case** (line 383): Context transformed via `map all_future`
3. **weakening case with A ∈ Γ'** (line 419): Requires exchange lemma

**Technical Analysis**:
- The IH doesn't apply directly because context structure changes
- Need recursive call on sub-derivation, which requires well-founded recursion
- Standard solution: prove auxiliary "boxed deduction theorem"

**Theorems**:

- [ ] `Derivable.size`: Termination metric
  - Goal: `{Γ : Context} → {φ : Formula} → (Γ ⊢ φ) → Nat`
  - Strategy: Recursively compute derivation tree depth
  - Complexity: Medium
  - Dependencies: None

- [ ] `derivable_permutation`: Exchange lemma
  - Goal: `(Γ Γ' : Context) → (h_perm : Γ.Perm Γ') → (h : Γ ⊢ φ) → Γ' ⊢ φ`
  - Strategy: Induction on derivation, context permutation doesn't affect derivability
  - Complexity: Medium
  - Dependencies: `List.Perm` from Mathlib/Std

- [ ] `boxed_deduction_helper`: Auxiliary for modal_k case
  - Goal: `(Γ' : Context) → (A φ : Formula) → (h : (A :: Γ') ⊢ φ) → (map box Γ') ⊢ (box A).imp (box φ)`
  - Strategy: Apply deduction theorem to sub-derivation, then modal_k, then K distribution
  - Complexity: Complex (recursive)
  - Dependencies: `Derivable.size`, well-founded recursion

- [ ] `temporal_deduction_helper`: Auxiliary for temporal_k case
  - Goal: `(Γ' : Context) → (A φ : Formula) → (h : (A :: Γ') ⊢ φ) → (map all_future Γ') ⊢ (all_future A).imp (all_future φ)`
  - Strategy: Mirror of boxed_deduction_helper with temporal operators
  - Complexity: Complex
  - Dependencies: Same as boxed_deduction_helper

- [ ] `deduction_theorem` (modal_k case): Line 370 sorry resolution
  - Goal: Complete the modal_k branch without sorry
  - Strategy: Use `boxed_deduction_helper` with termination proof
  - Complexity: Complex
  - Dependencies: `boxed_deduction_helper`, `Derivable.size`

- [ ] `deduction_theorem` (temporal_k case): Line 383 sorry resolution
  - Goal: Complete the temporal_k branch without sorry
  - Strategy: Use `temporal_deduction_helper`
  - Complexity: Complex
  - Dependencies: `temporal_deduction_helper`

- [ ] `deduction_theorem` (weakening case): Line 419 sorry resolution
  - Goal: Complete the `A ∈ Γ'` sub-case
  - Strategy: Use `derivable_permutation` to reorder, then recursive deduction
  - Complexity: Medium
  - Dependencies: `derivable_permutation`

**Implementation Strategy**:

1. **Define Derivable.size**:
```lean
def Derivable.size : {Γ : Context} → {φ : Formula} → (Γ ⊢ φ) → Nat
| _, _, .axiom _ _ _ => 1
| _, _, .assumption _ _ _ => 1
| _, _, .modus_ponens _ _ _ h1 h2 => 1 + h1.size + h2.size
| _, _, .modal_k _ _ h => 1 + h.size
| _, _, .temporal_k _ _ h => 1 + h.size
| _, _, .temporal_duality _ h => 1 + h.size
| _, _, .weakening _ _ _ h _ => 1 + h.size
```

2. **Rewrite deduction_theorem with termination_by**:
```lean
theorem deduction_theorem (Γ : Context) (A B : Formula)
    (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B := by
  -- Use match instead of induction for explicit termination
  termination_by h.size
```

3. **Prove exchange lemma** before tackling weakening case

**Tasks**:
- [ ] Implement `Derivable.size` metric
- [ ] Prove `derivable_permutation` exchange lemma
- [ ] Implement `boxed_deduction_helper` with termination
- [ ] Implement `temporal_deduction_helper` with termination
- [ ] Resolve modal_k sorry (line 370)
- [ ] Resolve temporal_k sorry (line 383)
- [ ] Resolve weakening sorry (line 419)
- [ ] Verify: `lake build Logos.Core.Metalogic.DeductionTheorem`
- [ ] Run `lake test`

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Metalogic/DeductionTheorem.lean
# Expected: 0
lake test
```

**Expected Duration**: 8-12 hours

**Risk Mitigation**:
- Well-founded recursion in Lean 4 can be tricky
- If blocked: Consult Lean Zulip, study Mathlib patterns
- Fallback: Keep as axioms with clear documentation

---

### Phase 2: Temporal Axiom Derivation [BLOCKED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Bridge.lean
dependencies: [1]

**Status**: BLOCKED - Depends on Phase 1 completion
**Blocker**: `future_k_dist` derivation requires complete deduction theorem (Phase 1)
**Resolution**: Complete Phase 1 first

**Effort**: 4-6 hours

**Objective**: Derive future_k_dist and always_mono using complete deduction theorem

**Background**:
With the complete deduction theorem, we can derive temporal K distribution by:
1. Starting with `[A → B, A] ⊢ B` (modus ponens)
2. Apply temporal_k to get `[G(A → B), GA] ⊢ GB`
3. Apply deduction theorem twice to lift context

**Theorems**:

- [ ] `future_k_dist`: Temporal K Distribution (replace axiom)
  - Goal: `⊢ G(A → B) → (GA → GB)`
  - Strategy:
    1. `[A → B, A] ⊢ B` by assumption + modus ponens
    2. `[G(A → B), GA] ⊢ GB` by temporal_k
    3. `[G(A → B)] ⊢ GA → GB` by deduction theorem
    4. `⊢ G(A → B) → (GA → GB)` by deduction theorem
  - Complexity: Medium
  - Dependencies: `deduction_theorem` (Phase 1)

- [ ] `past_k_dist`: Past K Distribution
  - Goal: `⊢ H(A → B) → (HA → HB)`
  - Strategy: Temporal duality on future_k_dist
  - Complexity: Simple
  - Dependencies: `future_k_dist`

- [ ] `always_mono`: Always Monotonicity (replace axiom)
  - Goal: `{A B : Formula} → (h : ⊢ A.imp B) → ⊢ A.always.imp B.always`
  - Strategy:
    1. Decompose `always` into `H ∧ present ∧ G`
    2. Apply `past_k_dist`: `HA → HB`
    3. Apply identity: `A → B`
    4. Apply `future_k_dist`: `GA → GB`
    5. Combine with conjunction to get `△A → △B`
  - Complexity: Medium
  - Dependencies: `future_k_dist`, `past_k_dist`, decomposition lemmas from Phase 3

**Tasks**:
- [ ] Derive `future_k_dist` theorem using complete deduction theorem
- [ ] Remove `axiom future_k_dist` declaration from Bridge.lean
- [ ] Derive `always_mono` theorem using K distributions
- [ ] Remove `axiom always_mono` declaration from Bridge.lean
- [ ] Verify: `lake build Logos.Core.Theorems.Perpetuity.Bridge`
- [ ] Update axiom count in IMPLEMENTATION_STATUS.md
- [ ] Run `lake test`

**Testing**:
```bash
lake build
grep -c "axiom" Logos/Core/Theorems/Perpetuity/Bridge.lean
# Expected: 2 fewer axioms (future_k_dist, always_mono removed)
lake test
```

**Expected Duration**: 4-6 hours

---

### Phase 3: Temporal K Infrastructure [BLOCKED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity/Bridge.lean
dependencies: [2]

**Status**: BLOCKED - Circular dependency + depends on Phase 2
**Blocker**: Bridge.lean → DeductionTheorem → Perpetuity module creates import cycle
**Assessment**: See summaries/iteration_3_summary.md
**Resolution**: Requires architectural refactoring to extract basic propositional theorems AFTER Phase 2 provides K distributions

**Effort**: 3-4 hours (+ architectural refactoring)

**Objective**: Build infrastructure to derive always_dni and always_dne

**Background**:
The `always` operator is defined as `always φ = Hφ ∧ φ ∧ Gφ`. To derive `always_dni` and `always_dne`, we need:
1. Decomposition lemmas to extract each component
2. K distribution for past (H) operator (from Phase 2)
3. Composition lemmas to recombine

**Prerequisite Architectural Refactoring**:
Extract `lce_imp`, `rce_imp` to separate module (e.g., `Propositional/Basics.lean`) that both `DeductionTheorem.lean` and `Bridge.lean` can import without circular dependencies.

**Theorems**:

- [ ] `always_to_past`: Decomposition lemma
  - Goal: `⊢ △φ → Hφ`
  - Strategy: First conjunct elimination from `always φ = Hφ ∧ (φ ∧ Gφ)`
  - Complexity: Simple
  - Dependencies: Conjunction elimination

- [ ] `always_to_present`: Decomposition lemma
  - Goal: `⊢ △φ → φ`
  - Strategy: Second conjunct (nested first) from `always φ`
  - Complexity: Simple
  - Dependencies: Conjunction elimination

- [ ] `always_to_future`: Decomposition lemma
  - Goal: `⊢ △φ → Gφ`
  - Strategy: Third conjunct from `always φ`
  - Complexity: Simple
  - Dependencies: Conjunction elimination

- [ ] `past_present_future_to_always`: Composition lemma
  - Goal: `⊢ (Hφ ∧ (φ ∧ Gφ)) → △φ`
  - Strategy: Identity on definition (trivial by definitional equality)
  - Complexity: Simple
  - Dependencies: None (definitional)

- [ ] `always_dni`: Derived from components
  - Goal: `⊢ △φ → △(¬¬φ)`
  - Strategy:
    1. Decompose `△φ` into `Hφ ∧ φ ∧ Gφ`
    2. Apply `dni` to `φ`: `φ → ¬¬φ`
    3. Apply `past_k_dist` and `future_k_dist` to get `Hφ → H(¬¬φ)` and `Gφ → G(¬¬φ)`
    4. Recombine: `H(¬¬φ) ∧ ¬¬φ ∧ G(¬¬φ) = △(¬¬φ)`
  - Complexity: Medium
  - Dependencies: `dni`, `past_k_dist` (Phase 2), `future_k_dist` (Phase 2), decomposition/composition lemmas

- [ ] `always_dne`: Derived from components
  - Goal: `⊢ △(¬¬φ) → △φ`
  - Strategy: Same as always_dni but using `double_negation` axiom instead of `dni`
  - Complexity: Medium
  - Dependencies: `Axiom.double_negation`, `past_k_dist`, decomposition/composition

**Tasks**:
- [ ] **PREREQUISITE**: Extract `lce_imp`, `rce_imp` to new `Propositional/Basics.lean` module
- [ ] Update imports in `DeductionTheorem.lean` and `Bridge.lean`
- [ ] Derive conjunction elimination helper (or identify existing pattern)
- [ ] Implement `always_to_past`, `always_to_present`, `always_to_future`
- [ ] Implement `past_present_future_to_always`
- [ ] Replace `axiom always_dni` with theorem
- [ ] Replace `axiom always_dne` with theorem
- [ ] Verify: `lake build Logos.Core.Theorems.Perpetuity.Bridge`
- [ ] Run `lake test`

**Testing**:
```bash
lake build
grep -c "axiom" Logos/Core/Theorems/Perpetuity/Bridge.lean
# Expected: 2 fewer axioms (always_dni, always_dne removed)
lake test
```

**Expected Duration**: 3-4 hours (+ architectural refactoring time)

---

## Risk Assessment

### High Risk
- **Phase 1 (DeductionTheorem)**: Well-founded recursion is complex
  - Mitigation: Study Mathlib patterns, consult Lean Zulip
  - Fallback: Keep sorry placeholders with documented blockers

### Medium Risk
- **Phase 2 (Temporal Axioms)**: Depends on Phase 1 completion
- **Phase 3 (Temporal K Infrastructure)**: Requires conjunction elimination pattern + architectural refactoring

---

## Rollback Plan

If phases encounter blocking issues:

1. **Phase 1**: Keep sorry placeholders, document in SORRY_REGISTRY.md
2. **Phase 2**: Keep `future_k_dist/always_mono` as axioms (blocked by Phase 1)
3. **Phase 3**: Keep `always_dni/always_dne` as axioms (blocked by Phase 2)

**Git Strategy**: Create feature branch per phase, merge only after tests pass.

---

## Documentation Updates Required

After completion:

- [ ] **IMPLEMENTATION_STATUS.md**: Update axiom count (reduce by 4 after derivations)
- [ ] **SORRY_REGISTRY.md**: Remove 3 DeductionTheorem entries (after Phase 1)
- [ ] **CLAUDE.md**: Update axiom list in "Key Packages" section

---

## Appendix A: Testing Strategy

1. **After Phase 1**: Verify 0 sorry in DeductionTheorem, run metalogic tests
2. **After Phase 2**: Verify axiom count reduced by 2 (future_k_dist, always_mono), run perpetuity tests
3. **After Phase 3**: Verify axiom count reduced by 2 more (always_dni, always_dne), run temporal tests

**Continuous Integration**: `lake build && lake test` after each task.

---

## Appendix B: File References (Remaining Phases)

### Phase 1 Target [BLOCKED]
- **Logos/Core/Metalogic/DeductionTheorem.lean**: 3 sorry markers (lines 370, 383, 419)
- Blocker: Requires well-founded recursion expertise

### Phase 2 Targets [BLOCKED]
- **Logos/Core/Theorems/Perpetuity/Bridge.lean**: `future_k_dist`, `always_mono` axioms
- Blocker: Depends on Phase 1 completion

### Phase 3 Targets [BLOCKED]
- **Logos/Core/Theorems/Perpetuity/Bridge.lean**: `always_dni`, `always_dne` axioms (lines 138, 204)
- **Logos/Core/Syntax/Formula.lean**: `always` definition (line 127)
- Blocker: Circular dependency + depends on Phase 2

---

## Appendix C: Dependency Visualization (Remaining Phases)

```
Phase 1 (DeductionTheorem) ─── No external dependencies, but needs recursion expertise
         │
         │ (enables future_k_dist derivation)
         ▼
Phase 2 (Temporal Axiom Derivation)
         │
         │ (provides K distributions for past/future)
         ▼
Phase 3 (Temporal K Infrastructure) ─── Also needs architectural refactoring
```

---

**Plan Created**: 2025-12-09
**Plan Version**: 2.0 (revised)
**Last Updated**: 2025-12-10
**Revision**: Removed completed phases, reorganized remaining by dependency order
**Based On**: Plan 063 (deferred phases) + Report 064-001 (blocker analysis)

---

## Appendix D: Execution History

| Date | Iteration | Phase | Status | Notes |
|------|-----------|-------|--------|-------|
| 2025-12-10 | 1 | Helper Lemma Infrastructure | COMPLETE | Moved to prior work |
| 2025-12-10 | 2 | DeductionTheorem | BLOCKED | Recursion expertise needed |
| 2025-12-10 | 3 | Temporal K Infrastructure | BLOCKED | Circular dependency discovered |
| 2025-12-10 | 4 | Tactic Consolidation | COMPLETE | Moved to prior work |
| 2025-12-10 | 5 | Plan Revision | COMPLETE | Removed completed phases, reordered |

### Next Steps to Unblock Remaining Phases

1. **For Phase 1 (DeductionTheorem)** - CRITICAL PATH:
   - Study Mathlib well-founded recursion patterns
   - Consult Lean Zulip for `termination_by` guidance
   - Import `Std.Data.List.Lemmas` for `List.Perm`
   - Consider human expert session (4-6 hours)

2. **For Phase 2 (Temporal Axioms)**:
   - Blocked until Phase 1 completes
   - Once Phase 1 done: derive `future_k_dist` using deduction theorem

3. **For Phase 3 (Temporal K Infrastructure)**:
   - Blocked until Phase 2 completes
   - Also requires architectural refactoring:
     - Extract `lce_imp`, `rce_imp` to new module (e.g., `Propositional/Basics.lean`)
     - Update imports in both `DeductionTheorem.lean` and `Bridge.lean`
     - Test compilation after refactoring
