# Implementation Plan: Task 945 - Design Canonical Model Construction for TruthLemma

- **Task**: 945 - Design canonical model construction for TruthLemma
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/945_canonical_model_construction_design/reports/research-001.md
  - specs/945_canonical_model_construction_design/reports/research-002.md
  - specs/945_canonical_model_construction_design/reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the canonical model construction design from research-003.md, which resolves the single blocking sorry `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600). The construction uses **dovetailing over CanonicalMCS** rather than over Int, leveraging the key insight that each MCS in a chain is an independent Lindenbaum witness that is never modified after placement.

### Research Integration

**research-003.md Key Findings**:
1. **Times vs States**: CanonicalMCS is the set of world-states, NOT the time domain. Times are positions in a linear order (Int).
2. **Maximal Chains as Histories**: Build Z-indexed chains where each element is an independent MCS from CanonicalMCS. The linearity axiom ensures F-witnesses are mutually comparable.
3. **Avoiding DovetailingChain Failure**: Int-indexed DovetailingChain fails because GContent truncation corrupts F-witnesses. CanonicalMCS chains grow by addition (independent Lindenbaum MCS), not modification.
4. **Multi-Family Bundle**: For modal saturation, build separate chains for each diamond witness, all indexed by Z.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `fully_saturated_bfmcs_exists_int`
- Produce a BFMCS Int satisfying: context preservation, temporal coherence (ALL families), modal saturation
- Use standard semantics (`bmcs_truth_at`, NOT the banned MCS-membership variant)
- Be sorry-free and axiom-free in the construction

**Non-Goals**:
- Generalizing to non-Int time domains (only Int is needed for completeness)
- Proving density or discreteness properties (the logic does not include such axioms)
- FMP bypass approach (explicitly rejected by user)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Linearity axiom insufficient for all F-witnesses to be CanonicalR-comparable | High | Medium | Use controlled Lindenbaum extension that respects chain structure; include temporal ordering constraints in seed |
| Modal coherence (modal_forward) for witness families hard to prove | Medium | Medium | BoxContent inclusion in diamond witness seed ensures propagation; leverage existing `saturated_modal_backward` |
| Construction produces uncountable result (Zorn) | Medium | Low | Explicit dovetailing is countable; enumerate formulas via `Encodable` |
| Cross-family temporal interference during saturation closure | Medium | Medium | Process diamond obligations via dovetailing; each witness family is built independently |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `TemporalCoherentConstruction.lean` at line 600 (`fully_saturated_bfmcs_exists_int`)
- 2 sorries in `DovetailingChain.lean` at lines 1869, 1881 (`forward_F`, `backward_P` for Int chain)

### Expected Resolution
- Phase 4 provides a new construction that eliminates `fully_saturated_bfmcs_exists_int` sorry
- The DovetailingChain sorries become irrelevant (Int-indexed chain is bypassed by CanonicalMCS-based construction)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in the critical path to completeness
- DovetailingChain sorries remain but are not in the dependency chain

---

## Implementation Phases

### Phase 1: Core Infrastructure for CanonicalMCS-Indexed Chains [NOT STARTED]

- **Dependencies:** None
- **Goal:** Establish the foundation for building Z-indexed chains of MCS elements through CanonicalMCS

**Tasks:**
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean`
- [ ] Define `CanonicalChain` structure: `Z -> CanonicalMCS` with ordering constraints
- [ ] Prove `GContent` propagation along chains (adapt from `GContent_path_propagates`)
- [ ] Prove `HContent` propagation along chains (adapt from `HContent_path_propagates`)
- [ ] Define `ChainSeed` for constructing chain elements: includes psi, GContent/HContent as appropriate
- [ ] Prove `ChainSeed` consistency using `forward_temporal_witness_seed_consistent` and `past_temporal_witness_seed_consistent`

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - create new
- `Theories/Bimodal/Metalogic/Bundle.lean` - add import

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalChain` passes
- All lemmas are sorry-free
- `lean_goal` shows no remaining goals in proofs

---

### Phase 2: Dovetailing Enumeration Infrastructure [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Build enumeration machinery for processing F/P-obligations across all chain positions

**Tasks:**
- [ ] Define formula enumeration using `Encodable Formula` (or define instance if missing)
- [ ] Define joint (time, formula) enumeration via `Nat.unpair`
- [ ] Define `FObligationQueue`: structure tracking which F-obligations from which chain positions need witnesses
- [ ] Define `PObligationQueue`: symmetric structure for P-obligations
- [ ] Prove enumeration completeness: every F/P obligation is eventually processed

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - extend with enumeration

**Verification:**
- `lake build` passes
- Enumeration lemmas are sorry-free

---

### Phase 3: Single Chain Construction with F/P Witnesses [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Build a single Z-indexed chain through a root MCS that satisfies forward_F and backward_P

**Tasks:**
- [ ] Define `buildCanonicalChain`: given root MCS M_0, construct Z-indexed chain
- [ ] For positive indices: h(n+1) = Lindenbaum({phi_n} union GContent(h(n))) where phi_n is next F-witness
- [ ] For negative indices: h(-n-1) = Lindenbaum({psi_n} union HContent(h(-n))) where psi_n is next P-witness
- [ ] Use dovetailing to ensure ALL F-obligations from ALL positions get witnessed
- [ ] Prove chain ordering: h(m) <= h(n) for m < n (CanonicalR ordering)
- [ ] Prove forward_F: F(psi) in h(t) implies exists s >= t with psi in h(s)
- [ ] Prove backward_P: P(psi) in h(t) implies exists s <= t with psi in h(s)
- [ ] Prove forward_G: G(phi) in h(t) and t <= s implies phi in h(s)
- [ ] Prove backward_H: H(phi) in h(t) and s <= t implies phi in h(s)

**Timing:** 3-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - main construction

**Verification:**
- `lake build` passes
- All temporal coherence properties are sorry-free
- `grep -n "\bsorry\b" CanonicalChain.lean` returns empty

---

### Phase 4: Multi-Family Bundle with Modal Saturation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Build a BFMCS with multiple temporally coherent families achieving modal saturation

**Tasks:**
- [ ] Define `CanonicalFamilyBundle`: set of Z-indexed chains with modal coherence
- [ ] Define `buildEvalChain`: construct the eval family chain from consistent context Gamma
- [ ] Define `buildWitnessChain`: for diamond obligation at (fam, t), build witness chain through diamond-witness MCS
- [ ] Prove diamond witness MCS consistency: {psi} union BoxContent(fam.mcs t) is consistent
- [ ] Define bundle closure: iterate witness chain construction until saturated
- [ ] Prove closure terminates (or use Zorn for existence)
- [ ] Prove modal_forward: Box(phi) in fam.mcs t implies phi in fam'.mcs t for all fam' in bundle
- [ ] Prove modal_backward: follows from `saturated_modal_backward` (already sorry-free)
- [ ] Prove all witness families are temporally coherent (each is a canonical chain)

**Timing:** 3-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - create new

**Verification:**
- `lake build` passes
- `is_modally_saturated` holds without sorry
- All families satisfy forward_F and backward_P

---

### Phase 5: Integrate and Eliminate Blocking Sorry [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Replace `fully_saturated_bfmcs_exists_int` sorry with the new construction

**Tasks:**
- [ ] Define `constructCanonicalBFMCS`: given consistent Gamma, build the full BFMCS
- [ ] Prove `constructCanonicalBFMCS_context_preserves`: Gamma in eval_family.mcs 0
- [ ] Prove `constructCanonicalBFMCS_temporally_coherent`: B.temporally_coherent
- [ ] Prove `constructCanonicalBFMCS_modally_saturated`: is_modally_saturated B
- [ ] Update `fully_saturated_bfmcs_exists_int` to use new construction (remove sorry)
- [ ] Verify `bmcs_truth_lemma` still compiles with new construction
- [ ] Verify `Completeness.lean` and `Representation.lean` compile

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - update sorry'd theorem
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - final construction

**Verification:**
- `lake build` passes for full project
- `grep -n "sorry" TemporalCoherentConstruction.lean` shows only DovetailingChain sorries (not in critical path)
- `#print axioms bmcs_strong_completeness` shows no sorryAx

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` shows no new axioms
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Chain Verification
- [ ] `#print axioms bmcs_truth_lemma` - verify no sorryAx
- [ ] `#print axioms bmcs_strong_completeness` - verify no sorryAx
- [ ] `#print axioms standard_strong_completeness` - verify no sorryAx

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalChain.lean` - chain infrastructure
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - multi-family bundle construction
- `specs/945_canonical_model_construction_design/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If the construction proves blocked at any phase:
1. Mark the phase [BLOCKED] with detailed explanation
2. Do NOT introduce sorries to continue
3. Options:
   - Revise approach based on where blockage occurs
   - Split into smaller tasks addressing specific sub-problems
   - Document findings for future research

If Phase 3 (forward_F proof) is blocked:
- The linearity axiom may need more careful analysis
- Consider: controlled Lindenbaum extension with explicit comparability constraints
- Alternative: weaken to forward_F_weak (exists s > t OR s = t) and strengthen later

If Phase 4 (modal saturation closure) is blocked:
- Consider finite saturation (only process diamond obligations for subformulas of input)
- This may require restructuring the proof but maintains soundness
