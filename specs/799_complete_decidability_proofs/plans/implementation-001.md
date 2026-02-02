# Implementation Plan: Task #799

- **Task**: 799 - Complete Decidability proofs
- **Status**: [IMPLEMENTING]
- **Effort**: 6-8 hours
- **Dependencies**: None (builds on existing FMP infrastructure)
- **Research Inputs**: specs/799_complete_decidability_proofs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete 6 remaining sorries in the Decidability module across three files. The implementation follows a bottom-up approach: start with the simplest lemmas in Closure.lean (list monotonicity), then proceed to the termination lemma in Saturation.lean, and finally tackle the completeness theorems in Correctness.lean which depend on the existing FMP infrastructure.

### Research Integration

The research report identifies:
- **Closure.lean sorries**: Self-contained list lemmas requiring `List.findSome?` monotonicity
- **Saturation.lean sorry**: Termination measure decreases lemma requiring formula complexity analysis
- **Correctness.lean sorries**: Completeness theorems requiring FMP bridge from `Theories/Bimodal/Metalogic/FMP/`

## Goals & Non-Goals

**Goals**:
- Complete all 6 sorries in Decidability module
- Maintain clean builds with no new sorries introduced
- Integrate properly with existing FMP infrastructure

**Non-Goals**:
- Refactoring existing proof structure
- Adding new decision procedure features
- Optimizing performance of the tableau procedure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMP integration complexity | High | Medium | Start with easier lemmas to build intuition; review FMP module structure first |
| List lemma complexity | Low | Low | Use simp/decide tactics; check Mathlib for existing lemmas |
| Termination proof difficult | Medium | Medium | May need to strengthen `expansionMeasure` definition or add helper lemmas |
| matchAxiom behavior unclear | Medium | Low | Review ProofSearch.lean implementation before tackling decide_axiom_valid |

## Implementation Phases

### Phase 1: Closure.lean List Monotonicity Lemmas [IN PROGRESS]

**Goal**: Complete the two sorries in Closure.lean - `closed_extend_closed` and `add_neg_causes_closure`

**Estimated effort**: 1.5 hours

**Objectives**:
1. Prove `closed_extend_closed`: A closed branch remains closed when extended
2. Prove `add_neg_causes_closure`: Adding F(phi) to a branch with T(phi) causes closure

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` - Lines 175-195

**Steps**:
1. Read the `findClosure`, `checkBotPos`, `checkContradiction`, and `checkAxiomNeg` definitions to understand the closure detection logic
2. For `closed_extend_closed` (line 175-185):
   - Case analysis on which closure type was found in `b`
   - For `botPos`: Show `hasBotPos b -> hasBotPos (sf :: b)` (monotonicity)
   - For `contradiction`: Show `findSome?` on a cons list either finds the same element or finds it earlier
   - For `axiomNeg`: Similar to contradiction case
   - Use `List.findSome?_cons` from Mathlib or prove a custom monotonicity lemma
3. For `add_neg_causes_closure` (line 190-195):
   - Show that `checkContradiction (SignedFormula.neg phi :: b)` returns `some (.contradiction phi)`
   - The key is that when we reach the positive formula in `b`, we check `hasNeg phi` on the extended list
   - `SignedFormula.neg phi` is at the head, so `hasNeg phi` holds
   - Use `List.findSome?_cons` and unfold `hasNeg` definition

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Closure` succeeds with no sorries
- Use `lean_goal` to verify proof state at each step

---

### Phase 2: Saturation.lean Termination Lemma [NOT STARTED]

**Goal**: Complete `expansion_decreases_measure` - the key termination lemma for tableau expansion

**Estimated effort**: 2 hours

**Objectives**:
1. Prove that applying a tableau rule decreases the `expansionMeasure`
2. Handle both `extended` (linear rule) and `split` (branching rule) cases

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Lines 217-221

**Steps**:
1. Review the `expansionMeasure` definition (line 208-211): sum of complexities for unexpanded formulas
2. Review `expandOnce` in Tableau.lean to understand what happens during expansion:
   - `findUnexpanded` finds an unexpanded formula `sf`
   - A rule is applied, which decomposes `sf` into simpler formulas
   - The original `sf` is removed, and new formulas are added
3. Prove the core insight: For any tableau rule, the conclusions have total complexity less than the principal formula
   - For linear rules: `sum(conclusions) < complexity(principal)`
   - For branching rules: each branch has `sum(conclusions) < complexity(principal)`
4. May need helper lemmas:
   - `complexity_pos`: Every formula has positive complexity
   - `complexity_subformula`: Subformulas have strictly smaller complexity
   - `rule_decreases_complexity`: For each rule, show complexity decreases
5. Structure the proof:
   ```lean
   intro b' hexp
   -- Get the unexpanded formula that was expanded
   have h_unexp : findUnexpanded b ≠ none := by
     intro h_none
     simp [isSaturated] at h
     exact h h_none
   obtain ⟨sf, hsf⟩ := Option.ne_none_iff_exists'.mp h_unexp
   -- Case analysis on the rule applied
   cases hexp with
   | inl hext =>
     -- Linear extension case
     simp [expandOnce] at hext
     ...
   | inr hsplit =>
     -- Split case
     ...
   ```
6. Use `omega` or `Nat.add_lt_add_right` for arithmetic

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` succeeds with no sorries
- Check that the proof correctly handles all rule types

---

### Phase 3: Correctness.lean - decide_axiom_valid [NOT STARTED]

**Goal**: Prove that axiom instances are correctly decided as valid

**Estimated effort**: 1 hour

**Objectives**:
1. Prove `decide_axiom_valid`: If phi is an axiom instance, decide returns valid

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Lines 168-172

**Steps**:
1. Read the `decide` function in DecisionProcedure.lean to understand its structure
2. Read `matchAxiom` in ProofSearch.lean to understand axiom pattern matching
3. The proof strategy:
   - `decide` first calls `tryAxiomProof` which uses `matchAxiom`
   - If `ax : Axiom phi`, then `matchAxiom phi` should return `some ⟨phi, ax⟩`
   - Need to verify that `matchAxiom` correctly identifies all axiom patterns
4. Structure the proof:
   ```lean
   use DerivationTree.axiom [] phi ax
   simp only [decide]
   -- Show tryAxiomProof succeeds
   -- This requires showing matchAxiom phi = some ⟨phi, ax⟩
   ```
5. May need a helper lemma: `matchAxiom_correct (ax : Axiom phi) : matchAxiom phi = some ⟨phi, ax⟩`
   - This would require proving that every axiom schema is recognized by matchAxiom

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` succeeds with this proof complete
- Test with specific axiom instances if needed

---

### Phase 4: Correctness.lean - Completeness Theorems [NOT STARTED]

**Goal**: Complete `tableau_complete` and `decide_complete` - the main completeness theorems

**Estimated effort**: 2-3 hours

**Objectives**:
1. Prove `tableau_complete`: Valid formulas have closing tableaux
2. Prove `decide_complete`: Decision procedure returns valid for valid formulas

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Lines 74-88

**Steps**:
1. Review the FMP module structure in `Theories/Bimodal/Metalogic/FMP/`:
   - `FiniteModelProperty.lean` - Main FMP theorem
   - `SemanticCanonicalModel.lean` - `semantic_weak_completeness`
   - `ClosureOperations.lean` - Closure size bounds
2. For `tableau_complete` (lines 74-77):
   - Key insight: By FMP, if phi is valid, its negation has no finite model
   - The tableau operates on the subformula closure, which is finite
   - With sufficient fuel (based on `closureSize phi`), the tableau terminates
   - All branches must close because there's no countermodel
   - Structure:
     ```lean
     intro hvalid
     -- Set fuel based on closure size
     use 2^(closureSize phi) * 10 + 100
     constructor
     · -- Show buildTableau returns some
       -- Follows from termination (Phase 2 lemma)
       ...
     · -- Show result is valid (all branches closed)
       intro t ht
       -- By contradiction: if not valid, there's an open saturated branch
       -- An open saturated branch gives a countermodel (by FMP)
       -- But phi is valid, contradiction
       ...
     ```
3. For `decide_complete` (lines 86-88):
   - Build on `tableau_complete`:
     ```lean
     obtain ⟨fuel, hsome, hvalid_t⟩ := tableau_complete phi hvalid
     use fuel
     -- The tableau closes, so decide can extract a proof
     -- Either tryAxiomProof succeeds, or bounded_search_with_proof succeeds
     -- (by semantic_weak_completeness, phi is provable)
     ```
4. May need bridge lemmas:
   - `closed_tableau_gives_proof`: A closed tableau yields a derivation tree
   - `saturated_open_branch_gives_countermodel`: Open saturated branch -> countermodel
   - Import and use `semantic_weak_completeness` from FMP module

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Correctness` succeeds with no sorries
- Full `lake build` passes for the entire project

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Decidability.Closure` - no sorries
- [ ] `lake build Bimodal.Metalogic.Decidability.Saturation` - no sorries
- [ ] `lake build Bimodal.Metalogic.Decidability.Correctness` - no sorries
- [ ] Full `lake build` passes
- [ ] Sorry count in Decidability module is reduced from 6 to 0

## Artifacts & Outputs

- Completed proofs in:
  - `Theories/Bimodal/Metalogic/Decidability/Closure.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
  - `Theories/Bimodal/Metalogic/Decidability/Correctness.lean`
- Possibly new helper lemmas if needed for FMP integration

## Rollback/Contingency

If FMP integration proves too complex:
1. Mark completeness theorems as `axiom` with clear documentation
2. Focus on completing Closure.lean and Saturation.lean sorries first (these are self-contained)
3. Create a follow-up task for completeness theorem completion with more research

If termination proof (`expansion_decreases_measure`) is difficult:
1. Consider strengthening the `expansionMeasure` definition
2. May need to add tracking of which formulas have been expanded
3. Alternative: use a different termination measure (e.g., lexicographic on formula structure)
