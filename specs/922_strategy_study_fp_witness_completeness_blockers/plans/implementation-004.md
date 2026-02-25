# Implementation Plan: Task #922 - Reflexive Forward Completeness Proof (v4)

- **Task**: 922 - strategy_study_fp_witness_completeness_blockers
- **Version**: 004
- **Created**: 2026-02-24
- **Status**: [NOT STARTED]
- **Effort**: 10-17 hours total
- **Dependencies**: None (Phase A from v3 provides optional infrastructure but is not required)
- **Research Inputs**: research-005.md (breakthrough finding: reflexive forward_F suffices)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**v3 -> v4**: FUNDAMENTAL APPROACH CHANGE based on research-005 breakthrough.

### Key Breakthrough (research-005, confidence 98%)

**TruthLemma only needs REFLEXIVE forward_F (s >= t instead of s > t)**. The contrapositive argument in `temporal_backward_G` works for both s = t and s > t cases:

1. Assume G(phi) NOT in mcs(t)
2. Then F(neg(phi)) in mcs(t) [temporal duality]
3. By forward_F: exists s with t <= s and neg(phi) in mcs(s)
4. By hypothesis h_all: phi in mcs(s) [since s >= t]
5. Contradiction: phi and neg(phi) in mcs(s) -- holds whether s = t OR s > t

**This eliminates the strict-future-witness problem** that blocked 12+ prior approaches.

### Strategy Change

- **v3 (ABANDONED)**: Quotient-to-Int isomorphism requiring NoMaxOrder/NoMinOrder
- **v4 (NEW)**: Weaken forward_F to reflexive, drop vestigial AddCommGroup, build BFMCS on canonical frame directly

### Research Findings Integrated

| Finding | Confidence | Action |
|---------|------------|--------|
| Reflexive forward_F suffices for TruthLemma | 98% | Phase 1: weaken forward_F |
| AddCommGroup constraint is vestigial | 99% | Phase 2: drop constraint |
| NoMaxOrder likely unprovable | 70% | v4 AVOIDS this entirely |
| Representative-based approach flawed | 95% | v4 AVOIDS quotient-to-Int |

## Overview

This plan implements the breakthrough approach from research-005: instead of solving the strict-future-witness problem, we ELIMINATE it by weakening forward_F/backward_P to use reflexive witnesses (s >= t instead of s > t).

**Strategy**:
1. Weaken TemporalCoherentFamily.forward_F from `t < s` to `t <= s`
2. Drop vestigial AddCommGroup constraint from BFMCS/BMCS chain
3. Build BFMCS over CanonicalReachable where reflexive temporal properties follow trivially
4. Wire into completeness chain, replacing `fully_saturated_bmcs_exists_int`

This approach completely sidesteps the NoMaxOrder problem, the quotient-to-Int isomorphism, and the representative selection problem identified in research-005.

### Research Integration

**From research-005**:
- `temporal_backward_G` proof uses `le_of_lt h_lt` to convert strict to non-strict -- with reflexive forward_F, this becomes direct `h_le`
- Same pattern for `temporal_backward_H`
- canonical_forward_F gives witnesses satisfying CanonicalR, which is reflexive
- AddCommGroup appears in 15+ files but NO proof uses additive operations

## Goals & Non-Goals

**Goals**:
- Weaken forward_F/backward_P to reflexive witnesses (s >= t, s <= t)
- Remove vestigial AddCommGroup constraint from BFMCS/BMCS chain
- Construct BFMCS over CanonicalReachable with trivial temporal proofs
- Achieve zero-sorry completeness chain for temporal components
- Maintain publication-quality code

**Non-Goals**:
- Prove NoMaxOrder/NoMinOrder for canonical quotient (v3 approach abandoned)
- Construct OrderIso to Int (no longer needed)
- Modify TruthLemma logic (only modify the forward_F type, proofs adapt trivially)
- Remove modal saturation axiom (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Reflexive forward_F breaks TruthLemma | High | 2% | Research-005 audit confirms proofs adapt; test incrementally |
| AddCommGroup removal breaks hidden dependency | Medium | 10% | Build after each file change; revert if needed |
| CanonicalReachable lacks needed properties | Medium | 5% | CanonicalR already proven reflexive, transitive; canonical_forward_F exists |
| Interface incompatibility with completeness chain | Medium | 15% | Map CanonicalReachable to LinearOrder via existing Preorder |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `DovetailingChain.lean`: `forward_F`, `backward_P` (become dead code after v4)
- 1 sorry in `TemporalCoherentConstruction.lean`: `fully_saturated_bmcs_exists_int` (target)

### Expected Resolution
- Phase 4 replaces `fully_saturated_bmcs_exists_int` sorry with constructive proof
- DovetailingChain sorries become unreferenced (not in active dependency chain)
- Final sorry count in completeness chain: 0 (temporal components)

### New Sorries
- ZERO permitted. This plan has absolute zero-sorry constraint.

### Remaining Debt
After this implementation:
- 0 sorries in temporal coherence construction
- DovetailingChain sorries remain but are dead code
- Modal saturation axiom remains (out of scope)

---

## Implementation Phases

### Phase 1: Weaken forward_F/backward_P to Reflexive [NOT STARTED]

- **Dependencies:** None
- **Goal:** Change temporal witness requirements from strict (t < s) to reflexive (t <= s)
- **Estimated Effort:** 2-3 hours

**Rationale**: Research-005 confirms the TruthLemma only needs reflexive witnesses. The contraposition argument produces a contradiction whether s = t or s > t.

**Tasks**:
1. [ ] Modify `TemporalCoherentFamily.forward_F` signature:
   - Change `∃ s, t < s ∧ phi ∈ mcs s` to `∃ s, t ≤ s ∧ phi ∈ mcs s`
2. [ ] Modify `TemporalCoherentFamily.backward_P` signature:
   - Change `∃ s, s < t ∧ phi ∈ mcs s` to `∃ s, s ≤ t ∧ phi ∈ mcs s`
3. [ ] Update `BMCS.temporally_coherent` to match new signatures
4. [ ] Update `temporal_backward_G` proof in BMCSTruth.lean:
   - Replace `le_of_lt h_lt` with direct `h_le`
5. [ ] Update `temporal_backward_H` proof in BMCSTruth.lean:
   - Same pattern as temporal_backward_G
6. [ ] Update `DovetailingChain.lean` signatures:
   - `temporal_coherent_family_exists_Int` and related
7. [ ] Run `lake build` to verify all proofs adapt

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - forward_F/backward_P signatures
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - temporal_backward_G/H proofs
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - family signatures
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - interface alignment

**Verification**:
- `lake build` succeeds with zero new errors
- Grep for `< s` in temporal contexts shows no remaining strict requirements
- TruthLemma.lean compiles unchanged (relies on temporal_backward_G/H)

---

### Phase 2: Drop AddCommGroup Constraint [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Remove vestigial AddCommGroup and IsOrderedAddMonoid constraints from BFMCS/BMCS chain
- **Estimated Effort:** 3-5 hours

**Rationale**: Research-005 audit confirms NO proof in the completeness chain uses additive operations. The constraints were inherited from an earlier design and are now technical debt.

**Tasks**:
1. [ ] Audit files for AddCommGroup usage (confirm research-005 findings):
   ```
   grep -r "AddCommGroup" Theories/Bimodal/Metalogic/Bundle/
   ```
2. [ ] Remove constraints from `BFMCS.lean`:
   - Change `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` to `[LinearOrder D]`
3. [ ] Remove constraints from `BMCS.lean`:
   - Same pattern
4. [ ] Remove constraints from `BMCSTruth.lean`:
   - Same pattern
5. [ ] Remove constraints from `TruthLemma.lean`:
   - Same pattern
6. [ ] Remove constraints from `Completeness.lean`:
   - Same pattern
7. [ ] Remove constraints from `ModalSaturation.lean`:
   - Same pattern
8. [ ] Remove constraints from remaining files:
   - `Construction.lean`, `CoherentConstruction.lean`, `TemporalCoherentConstruction.lean`
   - `SoundnessLemmas.lean`, `Soundness.lean`
9. [ ] Run `lake build` after each file to catch any hidden dependencies
10. [ ] If any proof breaks, analyze and document the dependency

**Files to modify** (approximately 15 files):
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/SoundnessLemmas.lean`
- `Theories/Bimodal/Metalogic/Bundle/Soundness.lean`

**Verification**:
- `lake build` succeeds after all changes
- `grep -r "AddCommGroup" Theories/Bimodal/Metalogic/Bundle/` returns no active files
- No proofs required modification (constraints were unused)

---

### Phase 3: Build BFMCS on Canonical Frame [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Construct BFMCS over CanonicalReachable with trivial temporal property proofs
- **Estimated Effort:** 3-5 hours

**Rationale**: With reflexive forward_F and no AddCommGroup requirement, we can construct BFMCS directly over the canonical frame's reachable fragment. The temporal properties follow trivially from existing canonical lemmas.

**Tasks**:
1. [ ] Define Preorder on CanonicalReachable (if not already from Phase A v3):
   ```lean
   instance : Preorder (CanonicalReachable M₀ h_mcs₀) where
     le := fun a b => CanonicalR a.world b.world
     le_refl := canonicalR_reflexive
     le_trans := canonicalR_transitive
   ```
2. [ ] Define `canonicalBFMCS_mcs : CanonicalReachable M₀ h_mcs₀ → Set Formula`:
   ```lean
   def canonicalBFMCS_mcs (w : CanonicalReachable M₀ h_mcs₀) : Set Formula := w.world
   ```
3. [ ] Prove MCS property:
   ```lean
   lemma canonicalBFMCS_mcs_property (w : CanonicalReachable M₀ h_mcs₀) :
     SetMaximalConsistent (canonicalBFMCS_mcs w) := w.is_mcs
   ```
4. [ ] Prove forward_G (trivial from canonical_forward_G):
   ```lean
   lemma canonicalBFMCS_forward_G (t s : CanonicalReachable M₀ h_mcs₀)
     (h_le : t ≤ s) (h_mem : Formula.all_future phi ∈ canonicalBFMCS_mcs t) :
     phi ∈ canonicalBFMCS_mcs s := canonical_forward_G h_le h_mem
   ```
5. [ ] Prove backward_H (trivial from canonical_backward_H):
   - Same pattern using CanonicalR_past
6. [ ] Prove forward_F (reflexive, trivial from canonical_forward_F):
   ```lean
   lemma canonicalBFMCS_forward_F (t : CanonicalReachable M₀ h_mcs₀)
     (h_mem : Formula.some_future phi ∈ canonicalBFMCS_mcs t) :
     ∃ s, t ≤ s ∧ phi ∈ canonicalBFMCS_mcs s :=
     -- canonical_forward_F gives W with phi in W and CanonicalR(t, W)
     -- CanonicalR(t, W) means t ≤ W by Preorder definition
   ```
7. [ ] Prove backward_P (reflexive, trivial from canonical_backward_P):
   - Same pattern
8. [ ] Assemble `canonicalBFMCS : BFMCS (CanonicalReachable M₀ h_mcs₀)`:
   ```lean
   def canonicalBFMCS : BFMCS (CanonicalReachable M₀ h_mcs₀) where
     mcs := canonicalBFMCS_mcs
     mcs_property := canonicalBFMCS_mcs_property
     forward_G := canonicalBFMCS_forward_G
     backward_H := canonicalBFMCS_backward_H
     forward_F := canonicalBFMCS_forward_F
     backward_P := canonicalBFMCS_backward_P
   ```
9. [ ] Run `lake build` to verify construction

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (new file)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` (Preorder instance if not present)

**Verification**:
- `canonicalBFMCS` constructed with zero sorries
- All four temporal properties proven trivially
- `lake build` succeeds

---

### Phase 4: Wire into Completeness Chain [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Replace `fully_saturated_bmcs_exists_int` sorry and verify completeness theorem
- **Estimated Effort:** 2-4 hours

**Rationale**: The new BFMCS over CanonicalReachable needs to be wired into the existing completeness infrastructure. This may require adapting the interface or generalizing away from Int.

**Tasks**:
1. [ ] Analyze current `fully_saturated_bmcs_exists_int` interface:
   - What does it return? (`BFMCS Int` or more general?)
   - What properties does completeness chain need?
2. [ ] Option A - Generalize away from Int:
   - If completeness chain only needs `BFMCS D` for some `[LinearOrder D]`
   - Replace Int-specific construction with CanonicalReachable-based construction
3. [ ] Option B - Embed CanonicalReachable into Int:
   - If Int is required, use existing CanonicalQuotient infrastructure (from v3 Phase A)
   - Apply orderIsoIntOfLinearSuccPredArch (may need NoMaxOrder workaround)
4. [ ] Define `fully_saturated_bmcs_exists`:
   ```lean
   theorem fully_saturated_bmcs_exists (Gamma : Set Formula) (h_cons : Consistent Gamma) :
     ∃ (D : Type) [LinearOrder D] (bfmcs : BFMCS D),
       Gamma ⊆ bfmcs.mcs (origin D) := by
     -- Use CanonicalReachable as D
     -- Use canonicalBFMCS as bfmcs
     -- origin is the root M₀
   ```
5. [ ] Wire into modal saturation:
   - Combine with existing `BMCS_modal_saturated` construction
6. [ ] Replace sorry in `TemporalCoherentConstruction.lean`:
   - Use new `fully_saturated_bmcs_exists` construction
7. [ ] Verify `Completeness.lean` compiles:
   - Run `lake build Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
8. [ ] Run full `lake build` to confirm zero errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - replace sorry
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - verify compilation
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - integration lemmas

**Verification**:
- `fully_saturated_bmcs_exists_int` sorry eliminated (or generalized)
- `Completeness.lean` compiles with zero errors
- `lake build` succeeds with zero errors
- `lean_verify` on completeness theorem shows clean axiom dependencies

---

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1 (reflexive forward_F)
- [ ] `lake build` succeeds after Phase 2 (AddCommGroup removed)
- [ ] `lake build` succeeds after Phase 3 (canonicalBFMCS constructed)
- [ ] `lake build` succeeds after Phase 4 (completeness wired)
- [ ] No new sorries introduced in any phase
- [ ] TruthLemma.lean compiles unchanged after Phase 1
- [ ] Completeness.lean compiles after Phase 4
- [ ] `lean_verify Completeness.lean strong_completeness` shows clean dependencies

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (Phase 1: weakened signatures)
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` (Phase 1: updated proofs)
- `Theories/Bimodal/Metalogic/Bundle/*.lean` (Phase 2: ~15 files with constraints removed)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (Phase 3: new file)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (Phase 4: sorry eliminated)
- `specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

1. **Phase 1 failure (TruthLemma breaks)**:
   - Unlikely (research-005 audit gives 98% confidence)
   - If it fails, the proof structure genuinely needs strict witnesses
   - Rollback: restore original forward_F signatures
   - Escalate: re-analyze TruthLemma proof structure

2. **Phase 2 failure (hidden AddCommGroup dependency)**:
   - If a proof breaks, it reveals an actual usage
   - Rollback: restore AddCommGroup for that specific file
   - Document: which file/proof uses additive operations

3. **Phase 3 failure (canonical properties insufficient)**:
   - Unlikely given canonical_forward_F/canonical_backward_P exist
   - Fallback: Use CanonicalQuotient from v3 Phase A as intermediate layer
   - Alternative: Strengthen CanonicalReachable properties

4. **Phase 4 failure (interface incompatibility)**:
   - If Int is strictly required, use v3 CanonicalQuotient + OrderIso approach
   - May need to revisit NoMaxOrder (but v4 should avoid this)
   - Alternative: Generalize completeness chain to accept any LinearOrder

## Critical Success Factors

1. **Reflexive forward_F must work**: Phase 1 is the linchpin. Research-005 analysis gives 98% confidence.

2. **AddCommGroup must be vestigial**: Phase 2 validates research-005 claim. If any proof breaks, document it.

3. **Canonical frame properties must suffice**: canonical_forward_F and canonical_backward_P are known to exist.

4. **Zero sorries constraint is absolute**: Every phase must produce sorry-free code.

5. **Build after each modification**: Catch issues early, avoid cascading failures.

## Technical Notes

### Why This Approach Works

The key insight from research-005 is that the TruthLemma's backward direction uses forward_F only in a contraposition argument:

1. Assume G(phi) NOT in mcs(t)
2. Get F(neg(phi)) in mcs(t) [duality]
3. Apply forward_F to get witness s with t <= s (or t < s) and neg(phi) in mcs(s)
4. From hypothesis h_all, get phi in mcs(s) [since s >= t, not s > t]
5. Contradiction: phi and neg(phi) in same mcs

The contradiction at step 5 holds regardless of whether s = t or s > t. The proof never needed strict future witnesses; it only needed the witness to be at a time >= t.

### Relationship to v3 Artifacts

Phase A of v3 (CanonicalQuotient.lean) created infrastructure for the quotient-to-Int approach. This infrastructure:
- Is NOT required for v4
- Remains as optional infrastructure
- Could be useful if Phase 4 interface incompatibility forces Int requirement
- Will become dead code if v4 succeeds fully

### Comparison: v3 vs v4

| Aspect | v3 | v4 |
|--------|-----|-----|
| Forward_F | Strict (t < s) | Reflexive (t <= s) |
| Time domain | Int via OrderIso | CanonicalReachable directly |
| NoMaxOrder | Required | Not needed |
| AddCommGroup | Required | Removed |
| Complexity | High (quotient, OrderIso) | Low (direct construction) |
| Confidence | 40-60% | 85-95% |
