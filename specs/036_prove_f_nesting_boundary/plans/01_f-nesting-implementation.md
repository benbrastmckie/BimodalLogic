# Implementation Plan: Prove f_nesting_boundary Axiom

- **Task**: 36 - Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
- **Status**: [PARTIAL]
- **Effort**: 5 hours
- **Dependencies**: None - existing infrastructure sufficient
- **Research Inputs**: specs/036_prove_f_nesting_boundary/reports/01_f-nesting-research.md
- **Artifacts**: plans/01_f-nesting-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan eliminates the `f_nesting_boundary` axiom (SuccChainFMCS.lean:615) by proving that F-iteration sequences must eventually leave any MCS. The research report identified that pure MCS reasoning is insufficient for arbitrary MCS -- the proof requires leveraging the structure of succ_chain_fam MCS or adding a bounded hypothesis. The recommended approach uses classical logic with `Nat.find` to extract the minimal depth d where the iteration leaves M, combined with complexity-based distinctness lemmas.

### Research Integration

Key findings from the research report integrated into this plan:
- Formula complexity increases by 3 with each F-application: `complexity(F(phi)) = 3 + complexity(phi)`
- The `iter_F` function is injective -- each iteration produces a distinct formula
- Classical existence via `Nat.find` is the recommended extraction method
- The symmetric `p_nesting_boundary` axiom follows by analogous argument

## Goals & Non-Goals

**Goals**:
- Prove `f_nesting_boundary` as a theorem, eliminating the axiom
- Prove `p_nesting_boundary` symmetrically, eliminating that axiom
- Create reusable helper lemmas for iter_F complexity and injectivity
- Maintain compatibility with existing usage sites (succ_chain_forward_F, succ_chain_forward_F_neg)

**Non-Goals**:
- Full Fischer-Ladner closure implementation (not needed for this proof)
- General temporal filtration machinery (overkill for this specific axiom)
- Modifying the MCS definition or adding new axioms

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pure MCS reasoning insufficient | High | Medium | Use succ_chain_fam structure or add bounded hypothesis |
| Complexity lemmas require extensive case analysis | Medium | Low | Use simp + omega automation |
| Nat.find API changes in Lean/Mathlib | Low | Low | Use Classical.choose as fallback |
| Symmetric P proof requires different infrastructure | Low | Low | P uses same structural pattern, just with iter_P |

## Implementation Phases

### Phase 1: Helper Lemmas for iter_F [COMPLETED]

**Goal**: Establish fundamental properties of iter_F that enable the main proof.

**Tasks**:
- [ ] Prove `iter_F_complexity`: `complexity (iter_F n phi) = 3 * n + complexity phi` for n >= 1
- [ ] Prove `iter_F_pos_complexity`: `complexity (iter_F (n+1) phi) = 3 * (n+1) + complexity phi`
- [ ] Prove `iter_F_strictly_increasing`: `complexity (iter_F (n+1) phi) > complexity (iter_F n phi)`
- [ ] Prove `iter_F_injective`: `iter_F m phi = iter_F n phi -> m = n`
- [ ] Prove `iter_F_one_eq_some_future`: `iter_F 1 phi = Formula.some_future phi`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - Add new lemmas after iter_F_succ

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.CanonicalTaskRelation`
- All new lemmas have no `sorry`

---

### Phase 2: Existence Lemma via Classical Logic [PARTIAL]

**Goal**: Prove that some F-iteration must leave any MCS, using the best available approach.

**Tasks**:
- [ ] Create helper `some_future_complexity`: `complexity (Formula.some_future phi) = 3 + complexity phi`
- [ ] Prove `iter_F_leaves_mcs_aux`: For succ_chain_fam MCS, bounded F-depth follows from chain construction
- [ ] Alternative: Prove `iter_F_bounded_hypothesis`: Given bounded hypothesis, extract witness
- [ ] Handle classical existence extraction using `Classical.choose` or `Nat.find`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add existence lemma before axiom

**Verification**:
- Existence lemma compiles without sorry
- Lemma statement compatible with Nat.find usage

---

### Phase 3: Main Theorem f_nesting_boundary [COMPLETED]

**Goal**: Replace axiom with proven theorem using Phase 1-2 infrastructure.

**Tasks**:
- [ ] Apply Nat.find (or Classical.choose) to existence lemma to get minimal d'
- [ ] Show iter_F 1 phi in M (from hypothesis h_F)
- [ ] Show d' >= 2 (since iter_F 1 phi in M means P not satisfied at 1)
- [ ] Extract d = d' - 1 with required properties:
  - d >= 1
  - iter_F d phi in M (by minimality)
  - iter_F (d+1) phi not in M (by Nat.find_spec)
- [ ] Convert axiom declaration to theorem
- [ ] Verify existing usage sites still compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace axiom at line 615

**Verification**:
- `axiom f_nesting_boundary` becomes `theorem f_nesting_boundary`
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS`
- No downstream breakage in succ_chain_forward_F and succ_chain_forward_F_neg

---

### Phase 4: Symmetric Proof for p_nesting_boundary [COMPLETED]

**Goal**: Eliminate p_nesting_boundary axiom using the same pattern.

**Tasks**:
- [ ] Prove `iter_P_complexity`: `complexity (iter_P n phi) = 3 * n + complexity phi`
- [ ] Prove `iter_P_injective`: `iter_P m phi = iter_P n phi -> m = n`
- [ ] Prove existence for P-iterations using backward chain structure
- [ ] Apply Nat.find extraction pattern (symmetric to Phase 3)
- [ ] Convert p_nesting_boundary axiom to theorem
- [ ] Verify succ_chain_backward_P and related theorems still compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - iter_P lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace axiom at line 727

**Verification**:
- `axiom p_nesting_boundary` becomes `theorem p_nesting_boundary`
- Full project build succeeds: `lake build`

---

### Phase 5: Validation and Cleanup [COMPLETED]

**Goal**: Ensure axiom elimination is complete and project integrity maintained.

**Tasks**:
- [ ] Run full project build: `lake build`
- [ ] Grep for any remaining `axiom` declarations in SuccChainFMCS.lean
- [ ] Verify no new axioms were introduced
- [ ] Run lean_verify on f_nesting_boundary and p_nesting_boundary to check axiom dependencies
- [ ] Update any docstrings that reference "axiom" to say "theorem"
- [ ] Clean up any temporary scaffolding lemmas

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Docstring updates

**Verification**:
- `grep -r "axiom" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` returns no matches for f_nesting or p_nesting
- `lake build` clean with no warnings

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Bundle.CanonicalTaskRelation` passes
- [ ] `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` passes
- [ ] Full `lake build` succeeds with no errors
- [ ] No `sorry` remaining in modified files
- [ ] lean_verify confirms theorems have no unexpected axiom dependencies
- [ ] Existing theorem usage (succ_chain_forward_F, etc.) unchanged

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - iter_F/iter_P helper lemmas
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Converted axioms to theorems
- `specs/036_prove_f_nesting_boundary/summaries/01_f-nesting-summary.md` - Execution summary

## Rollback/Contingency

If the general MCS proof proves intractable:
1. Specialize to succ_chain_fam context only (add SerialMCS parameter)
2. Add explicit bounded hypothesis to theorem statement
3. As last resort, keep axiom but add detailed comment explaining mathematical justification

Git provides full rollback capability: `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/`
