# Implementation Plan: Task #922 - Preorder Generalization (v5)

- **Task**: 922 - strategy_study_fp_witness_completeness_blockers
- **Version**: 005
- **Created**: 2026-02-24
- **Status**: [NOT STARTED]
- **Effort**: 6-10 hours
- **Dependencies**: None
- **Research Inputs**: research-008.md (Preorder generalization confirmed as correct path)
- **Artifacts**: plans/implementation-005.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**v4 -> v5**: ARCHITECTURAL CHANGE from quotient-based to direct Preorder construction.

### Key Insight (research-008, confirmed)

**LinearOrder is only used in SOUNDNESS** (specifically `le_total` for the temporal linearity axiom in `SoundnessLemmas.lean`), NOT in completeness. The completeness chain never appeals to totality - it only needs Preorder properties (reflexivity and transitivity).

### Root Cause of v4 Blocker

The v4 approach used CanonicalQuotient (Antisymmetrization) to obtain LinearOrder. This introduced the **quotient representative mismatch problem**:
- `canonical_forward_F` produces witness W with `phi in W`
- When mapping W to the quotient, `s.repr` (representative) may differ from W
- Individual formulas (like phi) do NOT propagate between equivalent representatives
- Only G-formulas propagate (via GContent equality)

### v5 Resolution

Generalize BFMCS from `[LinearOrder D]` to `[Preorder D]`, then use CanonicalReachable directly as domain D:
- `mcs w := w.world` (each CanonicalReachable element IS its MCS)
- forward_F/backward_P become trivial (use canonical_forward_F/canonical_backward_P from CanonicalFrame.lean)
- No quotient, no representative mismatch

### Research Findings Integrated

| Finding | Source | Action |
|---------|--------|--------|
| LinearOrder only used in soundness (le_total) | research-008 | Generalize to Preorder |
| AddCommGroup already removed (completeness uses trivial task relation) | research-008 | Already done in v4 |
| forward_F blocker is quotient representative mismatch | research-008 | Use CanonicalReachable directly |
| CanonicalR is reflexive and transitive (Preorder) | CanonicalQuotient.lean | Use as Preorder on CanonicalReachable |

## Overview

This plan implements the Preorder generalization approach identified in research-008. Instead of forcing CanonicalReachable into a LinearOrder via quotient (which breaks forward_F/backward_P), we generalize the BFMCS infrastructure to accept Preorder and use CanonicalReachable directly.

**Strategy**:
1. Phase A: Weaken forward_G/backward_H from strict `<` to reflexive `<=`
2. Phase B: Generalize BFMCS from `[LinearOrder D]` to `[Preorder D]`
3. Phase C: Build BFMCS on CanonicalReachable (forward_F/backward_P trivial)
4. Phase D: Wire into completeness chain, eliminate `fully_saturated_bmcs_exists_int` sorry

**Relationship to v4**:
- Phases 1-2 of v4 are preserved (reflexive witnesses, AddCommGroup removal)
- Phase 3 of v4 (CanonicalBFMCS on quotient) is REPLACED by Phase C (on CanonicalReachable)
- Phase 4 of v4 becomes Phase D (different wiring due to changed interface)

## Goals & Non-Goals

**Goals**:
- Generalize BFMCS from LinearOrder to Preorder
- Use CanonicalReachable as BFMCS domain (eliminate quotient representative mismatch)
- Prove forward_F/backward_P trivially via canonical_forward_F/canonical_backward_P
- Eliminate `fully_saturated_bmcs_exists_int` sorry
- Maintain zero-sorry policy for all new code

**Non-Goals**:
- Modify soundness proofs (they correctly use LinearOrder for le_total)
- Generalize soundness infrastructure to Preorder (not needed, soundness uses full structure)
- Remove CanonicalQuotient.lean (may be useful for other purposes)
- Change semantics layer (Semantics/*.lean files retain full structure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LinearOrder constraint downstream in completeness chain | High | 15% | Audit all files using BFMCS; Representation.lean may need update |
| TruthLemma requires strict `<` somewhere | Medium | 5% | v4 Phase 1 already verified reflexive works; minimal additional risk |
| CanonicalReachable Preorder interface insufficient | Low | 5% | CanonicalQuotient.lean already defines Preorder instance |
| Representation.lean requires Int specifically | Medium | 20% | Generalize or provide alternative path |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalBFMCS.lean`: `canonicalBFMCS_forward_F`, `canonicalBFMCS_backward_P` (v4 Phase 4 blockers)
- 1 sorry in `TemporalCoherentConstruction.lean`: `fully_saturated_bmcs_exists_int` (main target)
- 2 sorries in `DovetailingChain.lean`: `forward_F`, `backward_P` (dead code after v5)

### Expected Resolution
- Phase C eliminates the 2 CanonicalBFMCS sorries (trivial with Preorder approach)
- Phase D eliminates the `fully_saturated_bmcs_exists_int` sorry
- DovetailingChain sorries become unreferenced dead code

### New Sorries
- ZERO permitted. This plan has absolute zero-sorry constraint.

### Remaining Debt
After this implementation:
- 0 sorries in active completeness chain (temporal components fully resolved)
- DovetailingChain sorries remain but are unreferenced
- Modal saturation axiom remains (out of scope for task 922)

---

## Implementation Phases

### Phase A: Weaken forward_G/backward_H to Reflexive [NOT STARTED]

- **Dependencies:** None
- **Goal:** Change BFMCS forward_G/backward_H from strict `<` to reflexive `<=`
- **Estimated Effort:** 1-2 hours

**Rationale**: The current BFMCS uses strict inequality (`t < t'`). For Preorder compatibility, we need reflexive inequality (`t <= t'`). This is the minimal first step that should maintain all existing constructions.

**NOTE**: This may already be partially done by v4 Phase 1. Verify current state before starting.

**Tasks**:
1. [ ] Audit current BFMCS.lean for `<` vs `<=` in forward_G/backward_H
2. [ ] Change `forward_G : forall t t' phi, t < t' -> ...` to `forward_G : forall t t' phi, t <= t' -> ...`
3. [ ] Change `backward_H : forall t t' phi, t' < t -> ...` to `backward_H : forall t t' phi, t' <= t -> ...`
4. [ ] Update derived lemmas (forward_G_chain, backward_H_chain, etc.)
5. [ ] Update BMCSTruth.lean temporal_backward_G/H proofs if needed
6. [ ] Verify DovetailingChain.lean still compiles
7. [ ] Verify TruthLemma.lean still compiles
8. [ ] Run `lake build` to confirm no errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - forward_G/backward_H signatures
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` - temporal backward proofs (if needed)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - family signatures (if needed)

**Verification**:
- `lake build` succeeds with zero new errors
- `grep -n "t < t'" Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` returns empty (no strict inequalities)
- TruthLemma.lean compiles unchanged

---

### Phase B: Generalize BFMCS from LinearOrder to Preorder [NOT STARTED]

- **Dependencies:** Phase A
- **Goal:** Change BFMCS type constraint from `[LinearOrder D]` to `[Preorder D]`
- **Estimated Effort:** 2-3 hours

**Rationale**: With reflexive inequalities, BFMCS no longer requires LinearOrder properties. Generalizing to Preorder enables use of CanonicalReachable as domain.

**Tasks**:
1. [ ] Change BFMCS.lean: `variable (D : Type*) [LinearOrder D]` to `variable (D : Type*) [Preorder D]`
2. [ ] Propagate change to BMCS.lean
3. [ ] Propagate change to BMCSTruth.lean
4. [ ] Propagate change to TruthLemma.lean
5. [ ] Propagate change to Completeness.lean
6. [ ] Propagate change to ModalSaturation.lean
7. [ ] Propagate change to Construction.lean, CoherentConstruction.lean, TemporalCoherentConstruction.lean
8. [ ] Audit files for `LinearOrder`-specific operations (lt_or_eq_of_le, le_total, etc.)
9. [ ] Replace any `LinearOrder`-specific operations with `Preorder`-compatible alternatives
10. [ ] Run `lake build` after each file to catch issues early

**Files to modify** (approximately 10 files):
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- `lake build` succeeds after all changes
- `grep -r "LinearOrder" Theories/Bimodal/Metalogic/Bundle/*.lean` returns only imports/comments (not constraints)
- No proofs required `le_total` or other LinearOrder-specific operations

**Known Potential Issue**:
- TruthLemma.lean uses `lt_or_eq_of_le` (research-008 noted this). This is available from PartialOrder, which is implied by Preorder when the relation is decidable. If this fails, we may need to add `[PartialOrder D]` instead of just `[Preorder D]`.

---

### Phase C: Build BFMCS on CanonicalReachable [NOT STARTED]

- **Dependencies:** Phase B
- **Goal:** Construct BFMCS over CanonicalReachable with trivial forward_F/backward_P proofs
- **Estimated Effort:** 2-3 hours

**Rationale**: With Preorder generalization complete, we can now use CanonicalReachable directly. The key insight is that `mcs w := w.world` means each element IS its MCS, eliminating the quotient representative mismatch.

**Tasks**:
1. [ ] Verify CanonicalReachable has Preorder instance (already in CanonicalQuotient.lean line 64)
2. [ ] Create `canonicalReachableBFMCS_mcs`:
   ```lean
   def canonicalReachableBFMCS_mcs (w : CanonicalReachable M₀ h_mcs₀) : Set Formula :=
     w.world
   ```
3. [ ] Prove MCS property (trivial from `w.is_mcs`)
4. [ ] Prove forward_G (use `canonical_forward_G` + Preorder definition):
   ```lean
   -- w1 <= w2 means CanonicalR w1.world w2.world
   -- G phi in w1.world and CanonicalR w1.world w2.world implies phi in w2.world
   -- by canonical_forward_G
   ```
5. [ ] Prove backward_H (use `GContent_subset_implies_HContent_reverse` + `canonical_backward_H`)
6. [ ] Prove forward_F (TRIVIAL with this approach):
   ```lean
   -- F(phi) in mcs(w) = w.world
   -- canonical_forward_F gives W with phi in W and CanonicalR w.world W
   -- Construct s : CanonicalReachable from W
   -- s.world = W, so phi in mcs(s)
   -- w <= s by definition of Preorder (CanonicalR w.world s.world)
   ```
7. [ ] Prove backward_P (symmetric to forward_F using canonical_backward_P)
8. [ ] Assemble `canonicalReachableBFMCS : BFMCS (CanonicalReachable M₀ h_mcs₀)`
9. [ ] Update or replace CanonicalBFMCS.lean with new construction
10. [ ] Run `lake build` to verify construction

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - Replace quotient-based with Preorder-based

**Verification**:
- `canonicalReachableBFMCS` constructed with zero sorries
- forward_F and backward_P proven (not sorry-backed)
- `lake build` succeeds
- `grep -n "sorry" Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` returns empty

**Why This Works (Technical Explanation)**:
The v4 blocker was: `canonical_forward_F` gives W with phi in W, but when mapping to quotient, s.repr may differ from W, and phi in W does NOT imply phi in s.repr.world.

With the Preorder approach:
- No quotient, no representative selection
- s.world = W directly (by construction)
- phi in W means phi in s.world = mcs(s)
- No mismatch possible

---

### Phase D: Wire into Completeness Chain [NOT STARTED]

- **Dependencies:** Phase C
- **Goal:** Connect CanonicalReachable BFMCS to TruthLemma and eliminate `fully_saturated_bmcs_exists_int` sorry
- **Estimated Effort:** 2-3 hours

**Rationale**: The completeness chain needs a BFMCS. We now have one over CanonicalReachable (Preorder domain). We need to wire this into the existing infrastructure.

**Tasks**:
1. [ ] Analyze `fully_saturated_bmcs_exists_int` interface:
   - Current signature returns `BFMCS Int`
   - Determine what completeness chain actually needs
2. [ ] Option A - Generalize completeness theorems:
   - If only `Nonempty D` and `Zero D` are needed, generalize away from Int
   - Replace `fully_saturated_bmcs_exists_int` with `fully_saturated_bmcs_exists` over CanonicalReachable
3. [ ] Option B - Map CanonicalReachable to Int:
   - If Int is strictly required, investigate OrderIso embedding
   - This is the fallback if Option A fails
4. [ ] Update TemporalCoherentConstruction.lean:
   - Replace sorry-backed `fully_saturated_bmcs_exists_int` with constructive proof
5. [ ] Verify TruthLemma.lean compiles with new interface
6. [ ] Verify Completeness.lean compiles
7. [ ] Check Representation.lean integration:
   - Representation.lean constructs TaskFrame from BFMCS
   - May need to accept `BFMCS D` for general `D` instead of `BFMCS Int`
8. [ ] Run full `lake build` to confirm zero errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Replace sorry
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Interface update if needed
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Verify compilation
- `Theories/Bimodal/Metalogic/Representation.lean` - Generalize if needed

**Verification**:
- `fully_saturated_bmcs_exists_int` sorry eliminated
- TruthLemma.lean compiles with zero errors
- Completeness.lean compiles with zero errors
- Representation.lean compiles with zero errors
- `lake build` succeeds with zero errors
- `lean_verify Completeness.lean strong_completeness` shows clean axiom dependencies

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors after Phase A
- [ ] `lake build` passes with no errors after Phase B
- [ ] `lake build` passes with no errors after Phase C
- [ ] `lake build` passes with no errors after Phase D (final)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` returns empty (zero sorries)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Phase-Specific Tests
- [ ] Phase A: TruthLemma compiles unchanged after reflexive change
- [ ] Phase B: No `LinearOrder`-specific operations remaining in BFMCS chain
- [ ] Phase C: forward_F/backward_P proven without sorry
- [ ] Phase D: `fully_saturated_bmcs_exists_int` sorry eliminated

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (Phase A+B: reflexive, Preorder)
- `Theories/Bimodal/Metalogic/Bundle/*.lean` (Phase B: ~10 files with Preorder)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (Phase C: Preorder-based construction)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (Phase D: sorry eliminated)
- `specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

1. **Phase A failure (TruthLemma breaks with reflexive)**:
   - Unlikely (v4 Phase 1 already verified this)
   - If fails: restore strict inequalities, investigate alternative approach
   - Escalate: fundamental redesign may be needed

2. **Phase B failure (LinearOrder-specific operation needed)**:
   - If `lt_or_eq_of_le` fails: try `[PartialOrder D]` instead of `[Preorder D]`
   - If `le_total` is used: this would contradict research-008 findings; audit more carefully
   - Document which operation is needed and why

3. **Phase C failure (CanonicalReachable properties insufficient)**:
   - Unlikely: all needed properties (reflexivity, transitivity, canonical_forward_F) already proven
   - If fails: investigate what additional property is missing
   - Fallback: use CanonicalQuotient with modified approach

4. **Phase D failure (completeness chain requires Int)**:
   - Option B: Embed CanonicalReachable into Int via OrderIso
   - This requires proving NoMaxOrder/NoMinOrder (v3 approach, known difficulty)
   - Alternative: Generalize Representation.lean to accept any domain

## Critical Success Factors

1. **Preorder generalization must preserve TruthLemma**: Phase B is the linchpin. Research-008 confirms no `le_total` usage in completeness.

2. **forward_F/backward_P must be trivial**: Phase C validates the core insight. With CanonicalReachable, no quotient means no mismatch.

3. **Zero sorries constraint is absolute**: Every phase must produce sorry-free code.

4. **Build after each modification**: Catch issues early, avoid cascading failures.

5. **Completeness chain interface flexibility**: Phase D may require interface generalization. Be prepared to update downstream consumers.

## Technical Notes

### Why v5 Works Where v4 Failed

The v4 approach attempted to obtain LinearOrder by:
1. Taking CanonicalReachable (Preorder)
2. Quotienting by Antisymmetrization to get LinearOrder
3. Using quotient representatives for MCS assignment

This failed because quotient representative selection is non-constructive:
- `canonical_forward_F` gives specific W with phi in W
- The quotient [W] may have a different representative W'
- phi in W does NOT imply phi in W' (only G-formulas share via GContent equality)

The v5 approach recognizes that LinearOrder was never needed:
1. Keep CanonicalReachable as domain (already has Preorder)
2. Use identity mapping: mcs(w) := w.world
3. No representative selection, no mismatch
4. forward_F/backward_P become direct applications of canonical_forward_F/canonical_backward_P

### Relationship to Soundness

Soundness (in SoundnessLemmas.lean) DOES use `le_total` (LinearOrder):
```lean
rcases le_total s1 s2 with h_le | h_le  -- lines 528, 766
```

This is for proving the temporal linearity axiom valid. Soundness quantifies over ALL frames, so it needs the most general structure (LinearOrder + AddCommGroup).

Completeness only needs to construct ONE satisfying model. The canonical model can use a weaker structure (Preorder) because we are not proving validity in all models, just existence of one model.

This architectural separation is standard in completeness proofs: soundness uses full semantic structure, completeness uses minimal constructive structure.

### Comparison: v4 vs v5

| Aspect | v4 | v5 |
|--------|-----|-----|
| Domain | CanonicalQuotient (LinearOrder) | CanonicalReachable (Preorder) |
| MCS assignment | q.repr.world | w.world |
| forward_F/backward_P | BLOCKED (representative mismatch) | Trivial (identity mapping) |
| Interface change | None | BFMCS generalized to Preorder |
| Downstream impact | None | Completeness chain files updated |
| Confidence | 40% (blocked) | 90% (clear path) |
