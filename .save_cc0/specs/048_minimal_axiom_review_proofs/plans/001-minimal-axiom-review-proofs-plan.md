# Implementation Plan: Minimal Axiom Review - Documentation and Infrastructure

- **Feature**: Complete tasks from axiom system systematic review
- **Status**: [COMPLETE]
- **Created**: 2025-12-08
- **Plan Type**: research-and-plan (Lean specialization)

## Context

Based on the systematic review at `.claude/specs/048_minimal_axiom_review_proofs/reports/001-axiom-system-systematic-review.md`, this plan addresses:

1. **CRITICAL**: Documentation inaccuracies claiming "4/8 inference rules proven" when actually **8/8 are proven**
2. **CRITICAL**: Prove the deduction theorem (infrastructure for paper alignment)
3. **HIGH PRIORITY**: Update documentation about MK/TK as primitive inference rules
4. **MEDIUM PRIORITY**: Derive `pairing` and `dni` axioms from propositional axioms

## Metadata

- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Logos/Core/ProofSystem/Derivation.lean (primary)
- **Dependencies**: []
- **Estimated Hours**: 10-15

---

## Phase 1: Critical Documentation Fixes [COMPLETE]

**Goal**: Fix inaccurate claims about soundness proof status in documentation.

**Rationale**: Soundness.lean proves ALL 8 inference rules (verified: no sorry markers). Documentation claims "4/8" which is incorrect and misleading.

### Tasks

- [x] `task_update_claude_md_soundness`: Update CLAUDE.md line 11 from "4/8 inference rules proven" to "8/8 inference rules proven"
  - Goal: Fix factual error in project overview
  - Strategy: Direct text replacement
  - Complexity: Simple

- [x] `task_update_claude_md_metalogic`: Update CLAUDE.md lines 194-197 to remove "Incomplete rules: modal_k, temporal_k, temporal_duality, necessitation"
  - Goal: Remove incorrect claim about incomplete rules
  - Strategy: Replace with accurate list of all 8 proven rules
  - Complexity: Simple

- [x] `task_update_implementation_status`: Reconcile IMPLEMENTATION_STATUS.md with reality
  - Goal: Align documentation with actual Soundness.lean state
  - Strategy: Find and fix any "4/7 rules" or similar claims
  - Complexity: Simple

### Success Criteria

- [x] CLAUDE.md accurately states "8/8 inference rules proven"
- [x] CLAUDE.md lists all 8 rules as proven
- [x] IMPLEMENTATION_STATUS.md matches Soundness.lean (no sorry)
- [x] `lake build` passes after changes

### Verification Commands

```bash
# Verify no sorry in Soundness.lean
grep -c "sorry" Logos/Core/Metalogic/Soundness.lean

# Verify documentation claims
grep -n "4/8\|4/7" CLAUDE.md Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
```

---

## Phase 2: Derive necessitation from MK [COMPLETE]

**Goal**: Prove that the necessitation rule is a special case of modal_k with empty context.

**Rationale**: The paper uses MK as a primitive inference rule. Necessitation (if `⊢ φ` then `⊢ □φ`) is derivable from MK by applying it with empty context `[]`.

### Tasks

- [x] `theorem_necessitation_from_mk`: Prove necessitation is derivable from modal_k
  - Goal: `theorem necessitation_from_modal_k (φ : Formula) (h : ⊢ φ) : ⊢ φ.box`
  - Strategy: Apply `Derivable.modal_k [] φ h`, then simplify `[].map box = []`
  - Complexity: Simple
  - Dependencies: []

- [x] `task_add_docstring_necessitation`: Add docstring explaining necessitation is derived
  - Goal: Document the derivability relationship in Derivation.lean
  - Strategy: Add comment block before necessitation constructor explaining it's a convenience form of MK
  - Complexity: Simple

### Success Criteria

- [x] `necessitation_from_modal_k` theorem compiles with zero sorry
- [x] Docstring clearly explains the derivability relationship
- [x] `lake build` passes

### Lean File

```lean
-- Logos/Core/ProofSystem/Derivation.lean or new PropositionalLemmas.lean

/--
Necessitation derived from modal_k with empty context.

The necessitation rule (if `⊢ φ` then `⊢ □φ`) is a special case of
the modal K rule applied with empty context:
- modal_k: if `Γ ⊢ φ` then `□Γ ⊢ □φ`
- When Γ = [], we have `[] ⊢ φ` and `[].map box = []`, so `[] ⊢ □φ`

This shows that modal_k (MK) is the more general primitive inference rule.
-/
theorem necessitation_from_modal_k (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  have h_mk := Derivable.modal_k [] φ h
  simp only [Context.map] at h_mk
  exact h_mk
```

---

## Phase 3: Prove the Deduction Theorem [COMPLETE]

**Goal**: Prove the deduction theorem: `(φ :: Γ) ⊢ ψ → Γ ⊢ φ → ψ`

**Rationale**: This fundamental metatheorem is required to:
1. Formally derive `modal_k_dist` from the MK rule
2. Complete lemmas in Completeness.lean (`maximal_consistent_closed`, `maximal_negation_complete`)
3. Enable general propositional reasoning patterns

### Tasks

- [ ] `theorem_deduction_base_axiom`: Prove deduction theorem base case for axioms
  - Goal: If ψ is an axiom, then `Γ ⊢ φ → ψ` (via prop_s)
  - Strategy: Use `prop_s` to get `ψ → (φ → ψ)`, then modus ponens with axiom
  - Complexity: Medium

- [ ] `theorem_deduction_base_phi`: Prove deduction theorem base case when ψ = φ
  - Goal: `Γ ⊢ φ → φ` (identity, already proven)
  - Strategy: Use existing `identity` theorem from Perpetuity.lean
  - Complexity: Simple

- [ ] `theorem_deduction_base_assumption`: Prove deduction theorem base case when ψ ∈ Γ
  - Goal: If `ψ ∈ Γ`, then `Γ ⊢ φ → ψ`
  - Strategy: Use prop_s to get `ψ → (φ → ψ)`, then modus ponens with assumption
  - Complexity: Simple

- [ ] `theorem_deduction_inductive_mp`: Prove modus ponens inductive case
  - Goal: If `φ :: Γ ⊢ χ → ψ` and `φ :: Γ ⊢ χ`, derive `Γ ⊢ φ → ψ`
  - Strategy: Apply IH to get `Γ ⊢ φ → (χ → ψ)` and `Γ ⊢ φ → χ`, use prop_k to combine
  - Complexity: Medium

- [ ] `theorem_deduction_full`: Prove complete deduction theorem
  - Goal: `theorem deduction_theorem (Γ : Context) (φ ψ : Formula) : (φ :: Γ) ⊢ ψ → Γ ⊢ φ → ψ`
  - Strategy: Induction on derivation structure combining all cases
  - Complexity: Complex
  - Dependencies: [deduction_base_axiom, deduction_base_phi, deduction_base_assumption, deduction_inductive_mp]

### Success Criteria

- [ ] `deduction_theorem` compiles with zero sorry
- [ ] Docstring explains the proof strategy and dependencies
- [ ] Test theorem: `example : [A] ⊢ (B.imp A) := by apply deduction_theorem; apply Derivable.assumption; simp`
- [ ] `lake build` passes

### Verification Commands

```bash
# Verify no sorry in implementation
grep -c "sorry" Logos/Core/ProofSystem/Derivation.lean

# Run tests
lake test
```

### Notes

- The deduction theorem requires careful handling of modal_k and temporal_k cases
- MK changes context from Γ to □Γ, complicating the inductive step
- Consider whether to exclude modal/temporal rules initially (propositional deduction first)

---

## Phase 4: Update MK/TK Documentation [COMPLETE]

**Goal**: Document that MK and TK are the primitive inference rules, with modal_k_dist and necessitation being derivable consequences.

**Rationale**: The paper uses MK and TK as primitives. The LEAN implementation includes modal_k_dist as an axiom and necessitation as a rule for convenience, but this relationship should be documented clearly.

### Tasks

- [x] `task_update_architecture_mk_tk`: Update ARCHITECTURE.md to explain MK/TK as primitives
  - Goal: Add section explaining derivability relationships
  - Strategy: Add subsection under proof system explaining primitive vs derived rules
  - Complexity: Simple

- [x] `task_update_derivation_header`: Update Derivation.lean module docstring
  - Goal: Explain that necessitation is derivable from modal_k
  - Strategy: Add note to module docstring about primitive rule structure
  - Complexity: Simple

- [x] `task_update_axioms_header`: Update Axioms.lean docstring for modal_k_dist
  - Goal: Note that modal_k_dist can be derived from MK + deduction theorem
  - Strategy: Add note to modal_k_dist constructor docstring
  - Complexity: Simple

### Success Criteria

- [x] ARCHITECTURE.md explains MK/TK as primitive rules
- [x] Derivation.lean notes necessitation derivability
- [x] Axioms.lean notes modal_k_dist derivability (requires deduction theorem)
- [x] Documentation is consistent across files

---

## Phase 5: Derive pairing Axiom [COMPLETE]

**Goal**: Prove the pairing axiom `⊢ A → B → A ∧ B` from prop_k and prop_s combinators.

**Rationale**: The pairing axiom in Perpetuity.lean is semantically justified but can be derived purely from propositional combinators without needing the deduction theorem.

### Tasks

- [ ] `theorem_pairing_derived`: Derive pairing from prop_k and prop_s
  - Goal: `theorem pairing_derived (A B : Formula) : ⊢ A.imp (B.imp (A.and B))`
  - Strategy: Use S and K combinators with the encoding `A ∧ B = ¬(A → ¬B)`
  - Complexity: Medium
  - Dependencies: [identity from Perpetuity.lean]

- [ ] `task_replace_pairing_axiom`: Replace axiom with theorem in Perpetuity.lean
  - Goal: Change `axiom pairing` to `theorem pairing`
  - Strategy: Use the derived proof
  - Complexity: Simple
  - Dependencies: [pairing_derived]

### Success Criteria

- [ ] `pairing_derived` compiles with zero sorry
- [ ] All downstream proofs (P1-P4) still compile
- [ ] No new `axiom` declarations in Perpetuity.lean for pairing
- [ ] `lake build` passes

### Notes

- The encoding `A ∧ B = ¬(A → ¬B) = (A → (B → ⊥)) → ⊥` complicates the derivation
- Consider using the S combinator pattern: `S (S (K S) (S (K K) I)) (K I)`
- May require ~30-50 lines of combinator manipulation

---

## Phase 6: Derive dni Axiom [COMPLETE]

**Goal**: Prove double negation introduction `⊢ A → ¬¬A` from prop_k and prop_s.

**Rationale**: The dni axiom in Perpetuity.lean is semantically justified but should be derivable from the propositional axioms.

### Tasks

- [ ] `theorem_dni_derived`: Derive dni from prop_k and prop_s
  - Goal: `theorem dni_derived (A : Formula) : ⊢ A.imp A.neg.neg`
  - Strategy: Use C (flip) combinator pattern: `¬¬A = (A → ⊥) → ⊥`, derive `A → ((A → ⊥) → ⊥)`
  - Complexity: Medium

- [ ] `task_replace_dni_axiom`: Replace axiom with theorem in Perpetuity.lean
  - Goal: Change `axiom dni` to `theorem dni`
  - Strategy: Use the derived proof
  - Complexity: Simple
  - Dependencies: [dni_derived]

### Success Criteria

- [ ] `dni_derived` compiles with zero sorry
- [ ] P4 perpetuity proof still compiles
- [ ] No new `axiom` declarations in Perpetuity.lean for dni
- [ ] `lake build` passes

---

## Phase 7: Verification and Cleanup [COMPLETE]

**Goal**: Final verification that all changes are consistent and complete.

### Tasks

- [ ] `task_run_full_build`: Verify full project builds
  - Goal: `lake build` with zero errors
  - Strategy: Run build and fix any issues
  - Complexity: Simple

- [ ] `task_run_tests`: Verify all tests pass
  - Goal: `lake test` with all tests passing
  - Strategy: Run tests and fix any failures
  - Complexity: Simple

- [ ] `task_update_sorry_registry`: Update SORRY_REGISTRY.md if any sorries changed
  - Goal: Accurate sorry count
  - Strategy: Run sorry count script
  - Complexity: Simple

- [ ] `task_verify_lint`: Ensure lint passes
  - Goal: `lake lint` with zero warnings
  - Strategy: Run lint and fix issues
  - Complexity: Simple

### Success Criteria

- [ ] `lake build` succeeds
- [ ] `lake test` passes all tests
- [ ] `lake lint` has zero warnings
- [ ] Documentation matches implementation

### Verification Commands

```bash
lake build
lake test
lake lint
grep -c "sorry" Logos/Core/**/*.lean
```

---

## Risk Assessment

### High Risk

1. **Deduction Theorem Complexity**: The modal_k and temporal_k cases in deduction theorem induction are non-trivial. May require restricting to propositional fragment first.

### Medium Risk

1. **Combinator Derivations**: Deriving pairing and dni requires careful combinator manipulation that could be error-prone.

### Low Risk

1. **Documentation Updates**: Pure text changes with clear targets.
2. **necessitation_from_mk**: Simple application of modal_k with empty context.

---

## Dependencies Graph

```
Phase 1 (Docs) ──────────────────────────────────────────┐
                                                          │
Phase 2 (necessitation_from_mk) ─────────────────────────┤
                                                          │
Phase 3 (Deduction Theorem) ─────────────────────────────┼──→ Phase 4 (MK/TK Docs)
                                                          │
Phase 5 (pairing) ───────────────────────────────────────┤
                                                          │
Phase 6 (dni) ───────────────────────────────────────────┤
                                                          │
                                                          └──→ Phase 7 (Verification)
```

**Notes**:
- Phases 1, 2, 5, 6 can proceed in parallel
- Phase 4 depends on Phase 3 for accurate documentation about modal_k_dist derivability
- Phase 7 depends on all other phases

---

## Summary

| Phase | Description | Complexity | Hours |
|-------|-------------|------------|-------|
| 1 | Documentation Fixes | Simple | 1 |
| 2 | necessitation from MK | Simple | 0.5 |
| 3 | Deduction Theorem | Complex | 5-8 |
| 4 | MK/TK Documentation | Simple | 1 |
| 5 | Derive pairing | Medium | 2 |
| 6 | Derive dni | Medium | 1.5 |
| 7 | Verification | Simple | 1 |
| **Total** | | | **12-15** |

PLAN_CREATED: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/048_minimal_axiom_review_proofs/plans/001-minimal-axiom-review-proofs-plan.md
