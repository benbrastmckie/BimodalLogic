# Lean Implementation Plan: Hilbert Propositional and Modal Theorems

## Metadata
- **Date**: 2025-12-09
- **Feature**: Implement Medium Priority Tasks 21-41: Hilbert theorem derivations for propositional and modal logic
- **Scope**: Formalize 21 Hilbert-style theorems across propositional logic (RAA, EFQ, ECQ, LCE/RCE, LDI/RDI, RCP, NE/NI, DE, BI) and modal S5/S4 logic. Output: 3 new modules (Propositional.lean, ModalS5.lean, ModalS4.lean) with complete proofs.
- **Status**: [IN PROGRESS]
- **Estimated Hours**: 65-85 hours
- **Complexity Score**: 51
- **Structure Level**: 0
- **Estimated Phases**: 6
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Mathlib Theorems Report](../reports/001-mathlib-theorems.md)
  - [Proof Strategies Report](../reports/002-proof-strategies.md)
  - [Project Structure Report](../reports/003-project-structure.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker

## Progress Summary (Updated 2025-12-09)

| Phase | Status | Theorems Proven | Sorry Count |
|-------|--------|-----------------|-------------|
| 0 | SKIPPED | N/A | N/A |
| 1 | **COMPLETE** ✓ | 9/9 | 0 |
| 2 | IN PROGRESS | 3/6 | 4 |
| 3 | NOT STARTED | 0/? | - |
| 4 | NOT STARTED | 0/6 | - |
| 5 | NOT STARTED | - | - |

**Total Theorems Proven**: 12 (9 propositional + 3 modal)
**Total Sorry Placeholders**: 4 (all in ModalS5.lean)

---

## Research Summary

### Key Findings from Research Reports

**From Mathlib Theorems Report**:
- Logos has robust K/S combinator foundation (imp_trans, identity, b_combinator, theorem_flip)
- All 6 perpetuity principles (P1-P6) fully proven with zero sorry placeholders
- Existing modal infrastructure (box_conj_intro, diamond_4, modal_5) provides templates
- Limited need for Mathlib imports; project is self-contained

**From Proof Strategies Report**:
- 8 core proof patterns identified from Perpetuity.lean (implicational chains, contraposition, modal duality, box monotonicity, pairing)
- Context manipulation (Tasks 27-29) is primary complexity bottleneck requiring deduction theorem infrastructure
- Modal theorems (Tasks 30-36) have direct precedent in existing code
- Recommended order: Propositional foundations → Modal theorems → Context manipulation

**From Project Structure Report**:
- Current Theorems/ directory has single file (Perpetuity.lean, 1889 lines)
- Recommended approach: Create 2 new modules (Propositional.lean ~600 LOC, ModalS5.lean ~500 LOC)
- LogosTest/ mirrors source structure with dedicated test files
- Clean import graph: Perpetuity → Propositional → ModalS5

### Implementation Architecture

**New Modules**:
1. `Logos/Core/Theorems/Propositional.lean` - Tasks 21-29 (9 propositional theorems)
2. `Logos/Core/Theorems/ModalS5.lean` - Tasks 30-37 (8 modal S5 theorems)
3. `Logos/Core/Theorems/ModalS4.lean` - Tasks 38-41 (4 modal S4 theorems)

**Test Modules**:
1. `LogosTest/Core/Theorems/PropositionalTest.lean` - 29 tests minimum
2. `LogosTest/Core/Theorems/ModalS5Test.lean` - 16 tests minimum
3. `LogosTest/Core/Theorems/ModalS4Test.lean` - 8 tests minimum

**Import Dependencies**:
```
Logos.Core.ProofSystem.Derivation
         ↓
Logos.Core.Theorems.Perpetuity
         ↓
Logos.Core.Theorems.Propositional
         ↓
Logos.Core.Theorems.ModalS5
         ↓
Logos.Core.Theorems.ModalS4
```

---

## Success Criteria

### Module Completion
- [ ] Propositional.lean: All 9 theorems proven with zero sorry
- [ ] ModalS5.lean: All 8 theorems proven with zero sorry
- [ ] ModalS4.lean: All 4 theorems proven with zero sorry

### Test Coverage
- [ ] PropositionalTest.lean: ≥29 tests passing, ≥85% coverage
- [ ] ModalS5Test.lean: ≥16 tests passing, ≥85% coverage
- [ ] ModalS4Test.lean: ≥8 tests passing, ≥85% coverage

### Quality Standards
- [ ] Zero `#lint` warnings in all new modules
- [ ] All public theorems have docstrings with mathematical statements
- [ ] Build time <3 minutes total
- [ ] Test execution time <1 minute total

### Documentation
- [ ] CLAUDE.md updated with new theorem catalog
- [ ] IMPLEMENTATION_STATUS.md reflects new modules
- [ ] TODO.md Tasks 21-41 removed after completion
- [ ] Module docstrings document theorem organization

---

## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 0 | software | implementer-coordinator |
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | software | implementer-coordinator |

---

### Phase 0: Infrastructure Setup [NOT STARTED]
implementer: software
dependencies: []

**Effort**: 4 hours

Create file structure and dependency infrastructure before theorem implementation.

**Tasks**:
1. Create module files with docstrings and namespace declarations
2. Set up test file infrastructure with TestCase structures
3. Define critical dependency lemmas (DNI, LEM, contrapose_thm)
4. Verify build system integration

**Success Criteria**:
- [ ] Propositional.lean compiles with stub theorem signatures
- [ ] ModalS5.lean compiles with stub theorem signatures
- [ ] ModalS4.lean compiles with stub theorem signatures
- [ ] Test files run (with expected failures for unimplemented theorems)
- [ ] `lake build` succeeds with new modules

**Deliverables**:
- Propositional.lean (module skeleton, ~100 LOC)
- ModalS5.lean (module skeleton, ~80 LOC)
- ModalS4.lean (module skeleton, ~60 LOC)
- PropositionalTest.lean (test infrastructure, ~150 LOC)
- ModalS5Test.lean (test infrastructure, ~100 LOC)
- ModalS4Test.lean (test infrastructure, ~80 LOC)

---

### Phase 1: Propositional Foundations  ✓ [IN PROGRESS]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: [0]

**Effort**: 22 hours (Actual: ~2 iterations)

Implement low-complexity propositional theorems (Tasks 21-26) and critical dependency lemmas.

**Theorem Implementation Order**:
1. DNI (Double Negation Introduction) - Infrastructure lemma
2. LEM (Law of Excluded Middle) - Infrastructure lemma
3. Task 26: ECQ (Ex Contradictione Quodlibet)
4. Task 21: RAA (Reductio ad Absurdum)
5. Task 22: EFQ (Ex Falso Quodlibet)
6. Task 24: LDI/RDI (Disjunction Introduction)
7. Task 25: RCP (Reverse Contraposition)
8. Task 23: LCE/RCE (Conjunction Elimination)

**Task 26: ECQ (Ex Contradictione Quodlibet)** [COMPLETE] ✓
- **Goal**: `theorem ecq (A B : Formula) : [A, A.neg] ⊢ B`
- **Strategy**: Direct application of RAA or EFQ with contradiction in context
- **Location**: Propositional.lean:90-135
- **Status**: [IN PROGRESS]

**Task 21: RAA (Reductio ad Absurdum)** [COMPLETE] ✓
- **Goal**: `theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B)`
- **Strategy**: Use S axiom + imp_trans + contradiction reasoning
- **Location**: Propositional.lean:149-197
- **Status**: [IN PROGRESS]

**Task 22: EFQ (Ex Falso Quodlibet)** [COMPLETE] ✓
- **Goal**: `theorem efq (A B : Formula) : [] ⊢ A.neg.imp (A.imp B)`
- **Strategy**: Dual of RAA using theorem_flip
- **Location**: Propositional.lean:208-221
- **Status**: [IN PROGRESS]

**Task 24: LDI/RDI (Disjunction Introduction)** [COMPLETE] ✓
- **Goal**:
  - `theorem ldi (A B : Formula) : [A] ⊢ A.or B`
  - `theorem rdi (A B : Formula) : [B] ⊢ A.or B`
- **Strategy**: Use EFQ + prop_k + prop_s for ldi; prop_s for rdi
- **Location**: Propositional.lean:234-285, 297-317
- **Status**: [IN PROGRESS]

**Task 25: RCP (Reverse Contraposition)** [COMPLETE] ✓
- **Goal**: `theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A`
- **Strategy**: Chain contraposition + double_negation + DNI with unfold Formula.neg
- **Location**: Propositional.lean (added in iteration 2)
- **Status**: [IN PROGRESS]

**Task 23: LCE/RCE (Conjunction Elimination)** [COMPLETE] ✓
- **Goal**:
  - `theorem lce (A B : Formula) : [A.and B] ⊢ A`
  - `theorem rce (A B : Formula) : [A.and B] ⊢ B`
- **Strategy**: Use EFQ/prop_s + contraposition + DNE with conjunction definition
- **Location**: Propositional.lean (added in iteration 2)
- **Status**: [IN PROGRESS]

**LEM (Law of Excluded Middle)** [COMPLETE] ✓
- **Goal**: `theorem lem (A : Formula) : [] ⊢ A.or A.neg`
- **Strategy**: Unfold disjunction to ¬A → ¬A, then apply identity
- **Location**: Propositional.lean:66-70
- **Status**: [IN PROGRESS]

**Success Criteria**:
- [x] All 8 propositional theorems proven (ECQ, RAA, EFQ, LDI, RDI, RCP, LCE, RCE)
- [x] LEM infrastructure lemma proven
- [ ] 18+ tests passing for Phase 1 theorems (test file not yet created)
- [x] Zero sorry placeholders in Phase 1 code

**Deliverables**:
- [x] Propositional.lean: 333 LOC (9 theorems + docstrings) - **Created**
- [ ] PropositionalTest.lean: ~180 LOC (18 tests minimum) - **Pending**

---

### Phase 2: Modal S5 Theorems [IN PROGRESS]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS5.lean
dependencies: [1]

**Effort**: 20 hours (Actual: 2 iterations, partial completion)

Implement modal S5 theorems (Tasks 30-36) using existing modal infrastructure.

**Theorem Implementation Order**:
1. Task 30: T-Box-Diamond
2. Task 34: Box-Disjunction Introduction
3. Task 35: Box-Contraposition
4. Task 36: T-Box-Consistency
5. Task 31: Box-Conjunction Biconditional
6. Task 32: Diamond-Disjunction Biconditional

**Task 30: T-Box-Diamond** [COMPLETE] ✓
- **Goal**: `theorem t_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond`
- **Strategy**: Use modal_t axiom (□A → A) + diamond definition (¬□¬A) + RAA + b_combinator
- **Location**: ModalS5.lean:121-183
- **Status**: [IN PROGRESS]

**Task 34: Box-Disjunction Introduction** [BLOCKED]
- **Goal**: `theorem box_disj_intro (A B : Formula) : [] ⊢ (A.box.or B.box).imp ((A.or B).box)`
- **Strategy**: Apply box_mono + disjunction weakening
- **Dependencies**: [Phase 1: LDI, RDI]
- **Status**: [IN PROGRESS]
- **Location**: ModalS5.lean:197-221 (sorry at line 221)

**Task 35: Box-Contraposition** [COMPLETE] ✓
- **Goal**: `theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box)`
- **Strategy**: Build contraposition with b_combinator + theorem_flip, then apply box_mono
- **Location**: ModalS5.lean:235-256
- **Status**: [IN PROGRESS]

**Task 36: T-Box-Consistency** [COMPLETE] ✓
- **Goal**: `theorem t_box_consistency (A : Formula) : [] ⊢ (A.and A.neg).box.neg`
- **Strategy**: Use modal_t + theorem_app1 (DNI) to show contradiction → ⊥
- **Location**: ModalS5.lean:267-354
- **Status**: [IN PROGRESS]

**Task 31: Box-Conjunction Biconditional** [BLOCKED]
- **Goal**: `theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box)`
- **Strategy**: Extend box_conj_intro with elimination direction using LCE/RCE + box_mono
- **Dependencies**: [Phase 1: LCE, RCE, biconditional infrastructure]
- **Status**: [IN PROGRESS]
- **Location**: ModalS5.lean:363-364 (sorry)

**Task 32: Diamond-Disjunction Biconditional** [BLOCKED]
- **Goal**: `theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond)`
- **Strategy**: Dual of box_conj_iff via modal duality + De Morgan laws
- **Dependencies**: [Task 31, biconditional infrastructure]
- **Status**: [IN PROGRESS]
- **Location**: ModalS5.lean:373-374 (sorry)

**Helper Infrastructure**:
- `classical_merge` lemma: `(P → Q) → (¬P → Q) → Q` - ⚠ Not yet proven (sorry at line 103)
- `iff` definition: `def iff (A B : Formula) := (A.imp B).and (B.imp A)` - ✓ Defined

**Success Criteria**:
- [~] All 6 modal theorems proven (Tasks 30-32, 34-36) - **3/6 complete, 3 blocked**
- [ ] 12+ tests passing for Phase 2 theorems - **Pending test file creation**
- [~] Zero sorry placeholders in Phase 2 code - **4 sorry (infrastructure gaps documented)**

**Deliverables**:
- [x] ModalS5.lean: 390 LOC (7 theorems + infrastructure + docstrings) - **Created**
- [ ] ModalS5Test.lean: ~150 LOC (12 tests minimum) - **Pending**

**Blockers for Completion**:
1. **Classical Merge Lemma**: Need `(P → Q) → (¬P → Q) → Q` for box_disj_intro
2. **Biconditional Introduction**: Need way to construct `(A ↔ B)` from proofs of `(A → B)` and `(B → A)`
3. Both blockers may require Phase 3 deduction theorem infrastructure

---

### Phase 3: Context Manipulation [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: [1, 2]

**Effort**: 19 hours

Implement context-dependent theorems (Tasks 27-29) requiring deduction theorem infrastructure.

**Deduction Theorem Infrastructure** [NOT STARTED]
- **Goal**: Prove partial deduction theorem for specific cases needed by NE/NI/DE/BI
- **Strategy**: Induction on derivation structure for axiom, assumption, modus_ponens cases
- **Complexity**: Complex (8-10 hours)
- **Dependencies**: [Phase 1]

**Biconditional Infrastructure** [NOT STARTED]
- **Goal**: Prove iff_intro, iff_elim_left, iff_elim_right lemmas
- **Strategy**: Use pairing for introduction, conjunction elimination for extraction
- **Complexity**: Medium (3-4 hours)
- **Dependencies**: [Deduction Theorem, Phase 1: LCE/RCE]

**Task 27: NE/NI (Negation Introduction/Elimination)** [NOT STARTED]
- **Goal**:
  - `theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A`
  - `theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg`
- **Strategy**: Apply deduction theorem to derive contradiction, use double_negation
- **Complexity**: Complex (3-4 hours each)
- **Dependencies**: [Deduction Theorem]

**Task 28: DE (Disjunction Elimination)** [NOT STARTED]
- **Goal**: `theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C`
- **Strategy**: Use deduction theorem + LEM + case analysis on A ∨ B
- **Complexity**: Complex (5-7 hours)
- **Dependencies**: [Deduction Theorem, Phase 1: LEM]

**Task 29: BI/LBE/RBE (Biconditional Reasoning)** [NOT STARTED]
- **Goal**:
  - `theorem bi (A B : Formula) (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B`
  - `theorem lbe (A B : Formula) : [A.iff B, A] ⊢ B`
  - `theorem rbe (A B : Formula) : [A.iff B, B] ⊢ A`
- **Strategy**: Use biconditional infrastructure + deduction theorem
- **Complexity**: Complex (6-8 hours total)
- **Dependencies**: [Biconditional Infrastructure]

**Success Criteria**:
- [ ] Deduction theorem infrastructure proven for needed cases
- [ ] All 3 theorem groups proven (NE/NI, DE, BI/LBE/RBE)
- [ ] 11+ tests passing for Phase 3 theorems
- [ ] Zero sorry placeholders in Phase 3 code

**Deliverables**:
- Propositional.lean: Additional ~300 LOC (context theorems + deduction infrastructure)
- PropositionalTest.lean: Additional ~120 LOC (11 tests minimum)

---

### Phase 4: Advanced Modal (S5 + S4) [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/ModalS4.lean
dependencies: [2, 3]

**Effort**: 12 hours

Implement advanced S5 theorem (Task 33, 37) and S4-specific theorems (Tasks 38-41).

**Task 33: S5-Diamond-Box Collapse** [NOT STARTED]
- **Goal**: `theorem s5_diamond_box (A : Formula) : [] ⊢ (A.box.diamond).iff A.box`
- **Strategy**: Use modal_5 theorem (◇φ → □◇φ) + modal reasoning
- **Complexity**: Complex (5-7 hours)
- **Dependencies**: [Phase 2: Task 30]

**Task 37: S5-Diamond-Box-to-Truth** [NOT STARTED]
- **Goal**: `theorem s5_diamond_box_to_truth (A : Formula) : [] ⊢ (A.box.diamond).imp A`
- **Strategy**: Chain s5_diamond_box collapse + modal_t (□A → A)
- **Complexity**: Medium (2-3 hours)
- **Dependencies**: [Task 33]

**Task 38: S4-Diamond-Box-Conjunction** [NOT STARTED]
- **Goal**: `theorem s4_diamond_box_conj (A B : Formula) : [] ⊢ (A.diamond.and B.box).imp ((A.and B.box).diamond)`
- **Strategy**: Use modal_4 axiom + complex modal distribution reasoning
- **Complexity**: Complex (3-4 hours)
- **Dependencies**: [Phase 2: Task 31]

**Task 39: S4-Box-Diamond-Box** [NOT STARTED]
- **Goal**: `theorem s4_box_diamond_box (A : Formula) : [] ⊢ A.box.imp ((A.box.diamond).box)`
- **Strategy**: Apply modal_4 (□φ → □□φ) + modal_b axioms with nested reasoning
- **Complexity**: Complex (3-4 hours)
- **Dependencies**: []

**Task 40: S4-Diamond-Box-Diamond Equivalence** [NOT STARTED]
- **Goal**: `theorem s4_diamond_box_diamond (A : Formula) : [] ⊢ (A.diamond.box.diamond).iff A.diamond`
- **Strategy**: Use modal_4 + sophisticated nested modality reasoning
- **Complexity**: Complex (3-4 hours)
- **Dependencies**: []

**Task 41: S5-Diamond-Conjunction-Diamond** [NOT STARTED]
- **Goal**: `theorem s5_diamond_conj_diamond (A B : Formula) : [] ⊢ ((A.and B.diamond).diamond).iff (A.diamond.and B.diamond)`
- **Strategy**: Use modal_5 + complex S5 distribution properties
- **Complexity**: Complex (3-4 hours)
- **Dependencies**: [Phase 2: Task 32]

**Success Criteria**:
- [ ] All 6 advanced theorems proven (Tasks 33, 37-41)
- [ ] 12+ tests passing for Phase 4 theorems
- [ ] Zero sorry placeholders in Phase 4 code

**Deliverables**:
- ModalS5.lean: Additional ~100 LOC (Tasks 33, 37, 41)
- ModalS4.lean: ~400 LOC (Tasks 38-40 + infrastructure)
- ModalS5Test.lean: Additional ~50 LOC (4 tests)
- ModalS4Test.lean: ~100 LOC (8 tests)

---

### Phase 5: Documentation and Validation [NOT STARTED]
implementer: software
dependencies: [0, 1, 2, 3, 4]

**Effort**: 4 hours

Complete documentation updates and final validation.

**Documentation Updates**:
1. Update CLAUDE.md Theorems Package section with new theorem catalog
2. Update IMPLEMENTATION_STATUS.md with module statistics
3. Remove Tasks 21-41 from TODO.md with completion notes
4. Add examples to ARCHITECTURE.md and EXAMPLES.md
5. Update .claude/TODO.md with completion summary

**Validation Checks**:
1. Run `lake lint` - verify zero warnings
2. Check test coverage ≥85% for all new modules
3. Verify build time <3 minutes
4. Review import graph for circular dependencies
5. Final `lake build && lake test` verification

**Success Criteria**:
- [ ] All documentation files updated and consistent
- [ ] Zero lint warnings across all new modules
- [ ] Test coverage reports show ≥85% for Propositional, ModalS5, ModalS4
- [ ] Build and test performance within targets
- [ ] No circular import dependencies

**Deliverables**:
- Updated CLAUDE.md
- Updated IMPLEMENTATION_STATUS.md
- Updated TODO.md
- Updated ARCHITECTURE.md
- Updated EXAMPLES.md
- Updated .claude/TODO.md

---

## Critical Risks and Mitigations

### Risk 1: Deduction Theorem Complexity Explosion
**Probability**: High
**Impact**: High (blocks Tasks 27-29)
**Mitigation**:
- Implement simplified deduction theorem for specific cases only
- Defer full general deduction theorem to future work
- Prove NI before NE (simpler case analysis)
- Use proof by cases where possible to avoid deduction theorem

### Risk 2: Context Manipulation Axiom Gaps
**Probability**: Medium
**Impact**: High (may require new axioms)
**Mitigation**:
- Audit existing axioms (prop_k, prop_s, double_negation) for sufficiency
- Consult with existing Perpetuity.lean patterns for workarounds
- If axiom gaps found, propose minimal extensions rather than ad-hoc additions
- Consider alternative formulations (e.g., sequent calculus) if Hilbert system insufficient

### Risk 3: Test Coverage Gaps in Complex Theorems
**Probability**: Medium
**Impact**: Medium (quality assurance)
**Mitigation**:
- Implement 2-3 tests per theorem minimum (simple, nested, edge cases)
- Use property-based testing for biconditionals (forward/backward directions)
- Test context-dependent theorems with empty and non-empty contexts
- Add integration tests combining multiple theorems

### Risk 4: Build Time Exceeds Target
**Probability**: Low
**Impact**: Medium (developer experience)
**Mitigation**:
- Profile build times after each phase
- Optimize proof terms if timeouts occur
- Use `sorry` placeholders during development, replace incrementally
- Parallelize independent theorem development across modules

---

## Testing Strategy

### Unit Test Organization
**File Structure**:
- PropositionalTest.lean: 29 tests (18 Phase 1 + 11 Phase 3)
- ModalS5Test.lean: 16 tests (12 Phase 2 + 4 Phase 4)
- ModalS4Test.lean: 8 tests (Phase 4 only)

**Test Categories per Theorem**:
1. **Simple Case**: Atomic formulas (e.g., `A`, `B`)
2. **Nested Case**: Complex formulas (e.g., `(P → Q)`, `(A ∧ B) → C`)
3. **Edge Case**: Boundary conditions (e.g., empty context, self-negation)

**Context Testing Pattern** (for context-dependent theorems):
- Test with empty context `[]`
- Test with single assumption `[A]`
- Test with multiple assumptions `[A, B, C]`

### Test Naming Convention
Format: `test_<theorem>_<scenario>`

Examples:
- `test_raa_simple_atoms` - RAA with atomic formulas
- `test_lce_nested_formula` - LCE with nested conjunction
- `test_de_empty_context` - DE with empty context Γ

### Coverage Requirements
- **Overall**: ≥85% line coverage for Theorems modules
- **Theorems**: Every theorem must have ≥2 tests
- **Context theorems**: Must test both empty and non-empty contexts
- **Biconditionals**: Must test forward and backward directions separately

---

## Validation Checklist

### Pre-Implementation
- [ ] Phase 0 infrastructure compiles without errors
- [ ] Test files run (with expected failures)
- [ ] Import graph verified (no circular dependencies)
- [ ] Module docstrings complete with theorem catalog

### Per-Phase Validation
- [ ] All theorems in phase proven (zero sorry)
- [ ] Phase-specific tests passing (≥2 per theorem)
- [ ] No new lint warnings introduced
- [ ] Build time impact measured and acceptable

### Final Validation
- [ ] All 21 theorems proven across 3 modules
- [ ] 53+ tests passing (29 Propositional + 16 ModalS5 + 8 ModalS4)
- [ ] Zero sorry placeholders in delivered code
- [ ] Test coverage ≥85% for all new modules
- [ ] Zero lint warnings (`lake lint` clean)
- [ ] Build time <3 minutes
- [ ] Test execution time <1 minute
- [ ] Documentation complete and consistent
- [ ] TODO.md Tasks 21-41 removed

---

## Dependencies on External Work

### Existing Project Infrastructure (Required)
- **Perpetuity.lean**: Combinators (imp_trans, identity, b_combinator, theorem_flip, pairing)
- **Perpetuity.lean**: Modal lemmas (modal_5, diamond_4, box_mono, diamond_mono, box_conj_intro)
- **Axioms.lean**: prop_k, prop_s, double_negation, modal_t, modal_4, modal_b, modal_k_dist
- **Derivation.lean**: Derivable relation and inference rules

### No External Blockers
This implementation is self-contained within the Logos project. All dependencies are existing proven theorems and axioms.

---

## Notes

### Proof Pattern Reuse
The research reports identify 8 core proof patterns from Perpetuity.lean that will be heavily reused:
1. Implicational chain construction (imp_trans)
2. Contraposition with double negation
3. Modal duality exploitation (box ↔ diamond)
4. Weakening and assumption handling
5. Modus ponens chains
6. Box monotonicity application
7. Pairing and conjunction construction
8. Temporal duality (not applicable to these tasks)

### Tactical Automation
Leverage existing tactics throughout implementation:
- `tm_auto` - Try first on every theorem for trivial cases
- `modal_k_tactic` - Modal K distribution steps
- `assumption_search` - Context formula extraction
- Manual `apply`, `have`, `exact` for complex proofs

### Alternative Formulation Strategy
If deduction theorem proves intractable in Phase 3:
1. Prove simplified versions for specific formula patterns
2. Document limitations in IMPLEMENTATION_STATUS.md Known Limitations
3. Propose alternative sequent calculus formulation in future work
4. Still deliver 18/21 theorems (Phases 1-2) as substantial progress

### S4 vs S5 Distinction
- Tasks 30-37 are S5-specific (use modal_5 axiom)
- Tasks 38-40 are S4-specific (use modal_4 axiom, avoid modal_5)
- Task 41 is S5-specific with nested modalities
- ModalS4.lean may require axiom discipline (disable modal_5 in proofs)

---

**Plan Created**: 2025-12-09
**Last Updated**: 2025-12-09
**Plan Version**: 1.1

## Implementation Log

### Session 2025-12-09

**Iterations**: 4 (across lean-coordinator agents)

**Phase 1 Completed**:
- Created `Logos/Core/Theorems/Propositional.lean` (333 LOC)
- 9 theorems proven: lem, ecq, raa, efq, ldi, rdi, rcp, lce, rce
- Zero sorry placeholders
- Build successful

**Phase 2 Partial**:
- Created `Logos/Core/Theorems/ModalS5.lean` (390 LOC)
- 3 theorems proven: t_box_to_diamond, box_contrapose, t_box_consistency
- 4 sorry placeholders (blocked on classical_merge and biconditional infrastructure)
- Build successful (with warnings for sorry)

**Key Technical Discoveries**:
1. `Formula.neg` must be unfolded before `b_combinator` for type unification
2. `theorem_flip` critical for reordering `b_combinator` arguments
3. Conjunction `A ∧ B = (A → ¬B).neg` requires careful DNE application
4. Classical merge `(P → Q) → (¬P → Q) → Q` harder than expected - may need deduction theorem

**Files Created**:
- `Logos/Core/Theorems/Propositional.lean`
- `Logos/Core/Theorems/ModalS5.lean`

**Summary Reports**:
- `.claude/specs/057_hilbert_propositional_modal_theorems/summaries/001-phase1-propositional-foundations.md`
- `.claude/specs/057_hilbert_propositional_modal_theorems/summaries/002-phase1-complete.md`
- `.claude/specs/057_hilbert_propositional_modal_theorems/summaries/phase-2-iteration-3-summary.md`
- `.claude/specs/057_hilbert_propositional_modal_theorems/summaries/phase-2-iteration-4-summary.md`
