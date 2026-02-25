# Implementation Plan: Task #924

- **Task**: 924 - prove_fully_saturated_bmcs_exists_modal_temporal
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: Task 922 (complete - Preorder generalization providing sorry-free forward_F/backward_P for CanonicalMCS)
- **Research Inputs**: specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the final blocker for the completeness chain: eliminating the sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:819). The fundamental challenge is achieving BOTH temporal coherence AND modal saturation simultaneously, which requires reconciling two incompatible construction approaches:

1. **Temporal coherence** (forward_F, backward_P) is achieved with non-constant families (canonicalMCSBFMCS uses identity mapping w -> w.world)
2. **Modal saturation** (Diamond witnesses) traditionally uses constant families, which CANNOT satisfy temporal coherence

### Research Integration

Research-002 identified that constant witness families fundamentally cannot satisfy temporal coherence because:
- For constant family fam_M: F(psi) in M implies psi in M would require temporal saturation
- Temporal saturation of arbitrary MCS is IMPOSSIBLE (counterexample: {F(psi), neg(psi)} is consistent)

The recommended strategy is a **two-tier BMCS construction**:
- **Eval tier**: Single non-constant family (canonicalMCSBFMCS) providing temporal coherence
- **Witness tier**: Constant families for modal saturation, with a restructured truth lemma that handles G/H differently for constant families

The key insight from research: for constant families, `bmcs_truth_at B fam_M w (G phi) = phi in M` (since all times give the same MCS). So the truth lemma for G at constant families reduces to `G(phi) in M iff phi in M`, which holds for forward (T-axiom) but NOT for backward in general. However, the SPECIFIC formulas that need evaluation at witness families may not involve G/H nesting that requires the problematic backward direction.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:819)
- Construct a BMCS that is simultaneously temporally coherent AND modally saturated
- Preserve the truth lemma properties needed for completeness

**Non-Goals**:
- Eliminating DovetailingChain sorries (forward_F, backward_P for Int domain) - addressed by using CanonicalMCS domain
- Proving the generic `temporal_coherent_family_exists` for arbitrary D - only Int is needed
- Restructuring the fundamental BMCS framework - work within existing infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Constant-family truth lemma fails for nested G/H | High | Medium | Prove restricted truth lemma that avoids G/H at witness families |
| Modal saturation construction incompatible with CanonicalMCS domain | High | Low | Use BoxContent equivalence class approach from research-002 |
| Truth lemma restructuring breaks downstream proofs | High | Medium | Test each case incrementally; preserve original lemmas |
| Complexity explodes during two-tier integration | Medium | Medium | Phase 3 provides early validation checkpoint |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in TemporalCoherentConstruction.lean line 819 (`fully_saturated_bmcs_exists_int`)
- 2 sorries in DovetailingChain.lean lines 1869, 1881 (forward_F, backward_P for Int)
- 1 sorry in Construction.lean line 197 (singleFamily modal_backward)
- 1 sorry in TemporalCoherentConstruction.lean line 613 (generic D temporal_coherent_family_exists)

### Expected Resolution
- Phase 4 eliminates the sorry in `fully_saturated_bmcs_exists_int` (the target)
- DovetailingChain sorries remain (not in scope - they affect Int domain, we use CanonicalMCS)
- Construction.lean sorry remains (not in scope - we use multi-family approach)
- Generic D sorry remains (not in scope - only Int is used downstream)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- `fully_saturated_bmcs_exists_int` will be sorry-free
- DovetailingChain sorries (2) remain but are bypassed via CanonicalMCS approach
- Completeness chain can proceed without axiom dependency for Int-indexed BMCS

## Implementation Phases

### Phase 1: Constant-Family Truth Analysis [NOT STARTED]

- **Dependencies:** None
- **Goal:** Determine exactly when the truth lemma backward direction is needed at constant families and whether the completeness proof avoids those cases.

**Tasks**:
- [ ] Analyze TruthLemma.lean Box case: trace when IH is applied to witness families
- [ ] Identify if G/H formulas ever appear at witness family evaluation points
- [ ] Document the "truth lemma call graph" showing which cases invoke which
- [ ] Prove or disprove: completeness proof only evaluates atom/imp/box at witness families

**Timing**: 2-3 hours

**Files to read**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - truth lemma structure
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - how truth lemma is used

**Verification**:
- Written analysis document with truth lemma call graph
- Clear determination: either "constant families safe" or "need alternative approach"

---

### Phase 2: BoxContent-Equivalence BMCS Foundation [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Build the BMCS infrastructure for BoxContent equivalence class approach

**Tasks**:
- [ ] Define `BoxEquivMCS M0 := { w : CanonicalMCS | BoxContent w.world = BoxContent M0.world }`
- [ ] Prove BoxEquivMCS is non-empty (contains M0)
- [ ] Prove BoxEquivMCS inherits Preorder from CanonicalMCS
- [ ] Prove modal coherence within BoxEquivMCS:
  - [ ] Box(phi) in M implies phi in all M' with same BoxContent
  - [ ] phi in all M' with same BoxContent implies Box(phi) in M (via diamond_boxcontent_consistent)

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - add BoxEquivMCS definitions

**Verification**:
- `lake build` passes
- All new lemmas compile without sorry

---

### Phase 3: Two-Tier BMCS Construction [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Construct the combined BMCS with temporal eval family + modal witness families

**Tasks**:
- [ ] Define `TwoTierBMCS` structure:
  ```lean
  structure TwoTierBMCS where
    eval_family : BFMCS CanonicalMCS  -- canonicalMCSBFMCS
    witness_families : Set (BFMCS CanonicalMCS)  -- constant families
    eval_temporally_coherent : ...  -- forward_F, backward_P for eval
    witnesses_modally_coherent : ...  -- BoxContent agreement
  ```
- [ ] Prove `TwoTierBMCS.toBMCS` conversion preserving key properties
- [ ] Prove eval_family provides context preservation (Gamma subset)
- [ ] Prove modal_forward holds across all families
- [ ] Prove modal_backward holds via saturation

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TwoTierConstruction.lean` (new file)

**Verification**:
- `lake build` passes
- `TwoTierBMCS.toBMCS` compiles with all required BMCS properties

---

### Phase 4: Restricted Truth Lemma for Two-Tier [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove truth lemma works for the two-tier construction

**Tasks**:
- [ ] If Phase 1 shows constant families are safe: prove standard truth lemma works
- [ ] If Phase 1 shows G/H issues: implement restricted truth lemma approach
  - [ ] Define `restricted_truth_at` that handles constant families specially
  - [ ] Prove G/H at constant families: `G(phi) in M iff phi in M` (forward: T-axiom; backward: trivial since semantic truth = phi in M)
  - [ ] Prove truth lemma for restricted_truth_at
- [ ] Prove completeness-relevant corollary: eval family truth matches MCS membership

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TwoTierTruthLemma.lean` (new file)

**Verification**:
- `lake build` passes
- Truth lemma statement proven without sorry

---

### Phase 5: Complete fully_saturated_bmcs_exists_int [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Eliminate the sorry in `fully_saturated_bmcs_exists_int`

**Tasks**:
- [ ] Construct TwoTierBMCS from consistent context Gamma
- [ ] Prove all three required properties:
  - [ ] Context preservation: all gamma in Gamma are in eval_family.mcs at 0
  - [ ] Temporal coherence: forward_F and backward_P for all families
  - [ ] Modal saturation: every Diamond has a witness family
- [ ] Replace sorry with constructive proof
- [ ] Update documentation to reflect sorry elimination

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - eliminate sorry at line 819

**Verification**:
- `lake build` passes with no errors
- `grep -n "sorry" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` shows sorry only at line 613 (generic D, out of scope)
- Completeness.lean continues to build

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` shows only line 613 (generic D)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Specific Validation
- [ ] `fully_saturated_bmcs_exists_int` compiles without sorry
- [ ] Completeness.lean imports and uses the theorem successfully
- [ ] No new axioms introduced anywhere in the completeness chain

## Artifacts & Outputs

- `specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/TwoTierConstruction.lean` (new, Phase 3)
- `Theories/Bimodal/Metalogic/Bundle/TwoTierTruthLemma.lean` (new, Phase 4)
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (modified, Phase 2)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (modified, Phase 5)
- `specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If the two-tier approach fails:
1. **Fallback A**: Investigate if the CanonicalMCS all-identity BMCS (canonicalMCSBFMCS) alone provides sufficient structure for completeness without explicit multi-family saturation
2. **Fallback B**: Restructure BMCS to quantify Box over time points within BoxContent equivalence class rather than over families
3. **Preserve work**: All intermediate lemmas and constructions remain useful for future approaches

If any phase blocks:
- Mark phase [BLOCKED] with detailed analysis
- Preserve all partial work in version-controlled files
- Document the specific mathematical obstruction for future reference

## Alternative Approach: CanonicalMCS Single-Family with BoxContent Semantics

If the two-tier approach proves too complex, research-002 identified an alternative:

**Key observation**: With D = CanonicalMCS and single family canonicalMCSBFMCS:
- `fam.mcs(w) = w.world` for all w
- Temporal coherence is sorry-free (via CanonicalBFMCS.lean)
- Modal semantics can be redefined to quantify over BoxContent equivalence class

This would require modifying `bmcs_truth_at` for Box, but may be simpler than maintaining two-tier families.

Document this alternative if Phase 3 takes longer than estimated or encounters unexpected blockers.
