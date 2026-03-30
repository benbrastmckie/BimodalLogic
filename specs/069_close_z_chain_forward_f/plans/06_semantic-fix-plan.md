# Implementation Plan: Fix Semantic Mismatch and Close Z_chain_forward_F

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/069_close_z_chain_forward_f/reports/04_team-research.md
  - specs/069_close_z_chain_forward_f/summaries/06_sorry-closure-summary.md
- **Artifacts**: plans/06_semantic-fix-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 6 (semantic fix approach)
- **Lean Intent**: true

## Overview

The previous implementation attempt (v5) was blocked by a fundamental semantic mismatch: the project uses **reflexive temporal semantics** (Truth.lean:125 uses `t ≤ s`), but temporal coherence uses **strict inequality** (TemporalCoherence.lean:148-149 uses `t < s`). This creates an edge case where F(phi) is semantically satisfied at t (when phi ∈ chain(t)), but the strict temporal coherence definition demands a witness at s > t that may not exist.

**Strategy**: Weaken temporal coherence from strict (`t < s`) to reflexive (`t ≤ s`) to align with the actual semantics. This is semantically justified by the reflexive G operator and T-axiom (Gφ → φ).

### Research Integration

From team research report (04_team-research.md):
- **Finding 1**: Semantic mismatch confirmed. G semantics uses `t ≤ s` (reflexive), but forward_F uses `t < s` (strict)
- **Finding 2**: f_preserving_seed_consistent may be unprovable as stated, but becomes unnecessary under weak coherence
- **Recommendation**: Strategy A (weaken coherence) is simplest and semantically justified

## Goals & Non-Goals

**Goals**:
- Align temporal coherence definition with reflexive semantics
- Close the edge case sorry in omega_F_preserving_forward_F_resolution
- Close Z_chain_forward_F and Z_chain_forward_F' theorems
- Unblock bfmcs_from_mcs_temporally_coherent and bundle_validity_implies_provability
- Fix incorrect comment at TemporalCoherence.lean:144

**Non-Goals**:
- Proving f_preserving_seed_consistent (likely bypassed by weak coherence)
- Restructuring the entire F-preserving construction
- Changing the semantic definition of G/F operators

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Downstream proofs break | High | Low | temporal_backward_G proof structure unchanged; s > t still derived from forward_F |
| Multiple files need updates | Medium | Medium | Systematic grep for all consumers of forward_F/backward_P |
| Type constraint complications | Medium | Low | Both `t < s` and `t ≤ s` use same Preorder typeclass |
| f_preserving_seed still needed | Medium | Medium | If needed, use Lindenbaum extension fallback |

## Implementation Phases

### Phase 1: Weaken Temporal Coherence Definition [NOT STARTED]

**Goal**: Change forward_F from `t < s` to `t ≤ s` and backward_P from `s < t` to `s ≤ t`

**Tasks**:
- [ ] Edit `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`:
  - Line 144: Fix comment from "irreflexive semantics" to "reflexive semantics"
  - Line 149: Change `t < s` to `t ≤ s` in forward_F
  - Line 152: Change `s < t` to `s ≤ t` in backward_P
- [ ] Edit `BFMCS.temporally_coherent` predicate (line 218-219):
  - Change `t < s` to `t ≤ s`
  - Change `s < t` to `s ≤ t`
- [ ] Run `lake build` to identify all compilation errors

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`

**Verification**:
- [ ] Definition changes compile
- [ ] Error list captured for Phase 2

### Phase 2: Fix Downstream Proofs in TemporalCoherence.lean [NOT STARTED]

**Goal**: Update temporal_backward_G and temporal_backward_H to work with weak coherence

**Analysis**: The backward proofs use contraposition:
1. Assume G(phi) not in fam.mcs t
2. Derive F(neg phi) in fam.mcs t
3. Apply forward_F to get s with `t ≤ s` (was `t < s`) and neg(phi) in fam.mcs s
4. Apply hypothesis `h_all : ∀ s, t < s → phi ∈ fam.mcs s` -- **MISMATCH**

**Fix**: The hypothesis h_all uses `t < s` because the semantics for G is "at all s ≥ t". When forward_F gives `t ≤ s`:
- If `s = t`: Use h_all with reflexivity (phi ∈ fam.mcs t from hypothesis OR derive contradiction from neg(phi) ∈ fam.mcs t with phi ∈ fam.mcs t)
- If `s > t`: Existing proof works unchanged

**Tasks**:
- [ ] Update `temporal_backward_G` (line 165-178):
  ```lean
  -- After obtaining ⟨s, h_le, h_neg_phi_s⟩ from forward_F:
  rcases h_le.lt_or_eq with h_lt | h_eq
  · -- Case s > t: existing proof
    have h_phi_s : φ ∈ fam.mcs s := h_all s h_lt
    exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s
  · -- Case s = t: need phi ∈ fam.mcs t, but we're proving G(phi) ∈ fam.mcs t
    -- Wait - this is wrong. The hypothesis h_all : ∀ s, t < s → φ ∈ fam.mcs s
    -- does NOT give us phi at t. So we need a different approach.
    -- Actually, the forward_F with t ≤ s can give s = t, but then:
    -- neg(phi) ∈ fam.mcs t AND we assumed G(phi) ∉ fam.mcs t
    -- This is consistent! The hypothesis only covers s > t.
  ```

  **Critical insight**: The hypothesis `h_all : ∀ s, t < s → phi ∈ fam.mcs s` MUST be strengthened to `h_all : ∀ s, t ≤ s → phi ∈ fam.mcs s` for the proof to work. This matches the G semantics!

- [ ] Update `temporal_backward_G` signature:
  - From: `(h_all : ∀ s : D, t < s → φ ∈ fam.mcs s)`
  - To: `(h_all : ∀ s : D, t ≤ s → φ ∈ fam.mcs s)`
- [ ] Update `temporal_backward_H` signature similarly:
  - From: `(h_all : ∀ s : D, s < t → φ ∈ fam.mcs s)`
  - To: `(h_all : ∀ s : D, s ≤ t → φ ∈ fam.mcs s)`
- [ ] Verify proofs compile

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`

**Verification**:
- [ ] temporal_backward_G compiles
- [ ] temporal_backward_H compiles

### Phase 3: Propagate Changes to UltrafilterChain.lean [NOT STARTED]

**Goal**: Update all consumers of forward_F in UltrafilterChain.lean

**Tasks**:
- [ ] Update `shifted_temporal_forward_F` (line 303-308):
  - Change signature from `t < s` to `t ≤ s`
  - Proof should adapt naturally (shifting preserves ≤)
- [ ] Update `omega_F_preserving_forward_F_resolution` (around line 4509):
  - The sorry at the edge case `phi ∈ chain(t)` is now trivially closeable
  - Return witness `s = t` with `t ≤ t` (reflexivity)
- [ ] Update any other forward_F consumers found by `lake build`
- [ ] Run `lake build` and verify compilation

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] shifted_temporal_forward_F compiles
- [ ] Edge case sorry closed
- [ ] `lake build` succeeds

### Phase 4: Close Z_chain_forward_F Theorems [NOT STARTED]

**Goal**: Close Z_chain_forward_F (line 2772) and Z_chain_forward_F' (line 3965)

**Analysis**: With weak coherence, when `phi ∈ chain(t)` already:
- We can return `s = t` as the witness
- `t ≤ t` is trivially true
- `phi ∈ chain(t)` is given

**Tasks**:
- [ ] Update `Z_chain_forward_F` proof (line 2772-2833):
  - Add case split: `phi ∈ chain(t)` vs `phi ∉ chain(t)`
  - Edge case: `exact ⟨t, le_refl t, h_phi_t⟩`
  - Main case: existing construction finds s > t
- [ ] Update `Z_chain_forward_F'` proof (line 3965):
  - Same structure as above
- [ ] Update `Z_chain_backward_P` (line 2837-2842):
  - Symmetric treatment for past operator
- [ ] Run `lake build`

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] Z_chain_forward_F sorry closed
- [ ] Z_chain_forward_F' sorry closed
- [ ] Z_chain_backward_P sorry closed

### Phase 5: Re-evaluate f_preserving_seed_consistent [NOT STARTED]

**Goal**: Determine if f_preserving_seed_consistent is still needed

**Analysis**: With weak coherence:
- When `phi ∈ chain(t)` already, F(phi) is "resolved" at t itself
- The complex F-preserving construction may be unnecessary
- If the construction is only needed for strict witnesses, we can bypass it

**Tasks**:
- [ ] Trace dependency chain from Z_chain_forward_F to f_preserving_seed_consistent
- [ ] If bypassed: Mark theorem as `@[deprecated]` with note
- [ ] If still needed: Apply Strategy B1 (Lindenbaum extension) or leave sorry with documentation
- [ ] Update documentation to reflect new construction

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (documentation)

**Verification**:
- [ ] Dependency analysis complete
- [ ] Decision documented

### Phase 6: Close Downstream Theorems and Verify [NOT STARTED]

**Goal**: Verify bfmcs_from_mcs_temporally_coherent and related theorems can close

**Tasks**:
- [ ] Check `bfmcs_from_mcs_temporally_coherent` (if exists)
- [ ] Check `bundle_validity_implies_provability` dependencies
- [ ] Run full `lake build` and count remaining sorries:
  ```bash
  grep -c "sorry" Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
  ```
- [ ] Verify no new axioms introduced:
  ```bash
  lake env lean --run scripts/check_axioms.lean 2>/dev/null || true
  ```
- [ ] Create implementation summary

**Timing**: 0.25 hours

**Files to modify**:
- Various (as needed for remaining sorries)

**Verification**:
- [ ] Sorry count decreased
- [ ] No new axioms
- [ ] `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Use `lean_goal` to inspect proof states at modified theorems
- [ ] Verify semantic alignment: G semantics (t ≤ s) matches coherence (t ≤ s)
- [ ] Check that T-axiom (Gφ → φ) proof still works (it should, as it depends on reflexivity)

## Artifacts & Outputs

- plans/06_semantic-fix-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- summaries/07_semantic-fix-summary.md (post-implementation)

## Key Code References

| Location | Current | Change To |
|----------|---------|-----------|
| TemporalCoherence.lean:144 | "irreflexive semantics" | "reflexive semantics" |
| TemporalCoherence.lean:149 | `t < s` | `t ≤ s` |
| TemporalCoherence.lean:152 | `s < t` | `s ≤ t` |
| TemporalCoherence.lean:166 | `∀ s, t < s →` | `∀ s, t ≤ s →` |
| TemporalCoherence.lean:192 | `∀ s, s < t →` | `∀ s, s ≤ t →` |
| TemporalCoherence.lean:218 | `t < s` | `t ≤ s` |
| TemporalCoherence.lean:219 | `s < t` | `s ≤ t` |
| UltrafilterChain.lean:305 | `t < s` | `t ≤ s` |

## Semantic Justification

The change from strict to reflexive coherence is semantically correct:

1. **G semantics** (Truth.lean:125): `∀ s, t ≤ s → truth_at ... s φ`
   - G(φ) at t means φ holds at all s where t ≤ s (including s = t)

2. **F semantics** (Formula.lean:394): `F(φ) = ¬G(¬φ)`
   - F(φ) at t means ∃ s where t ≤ s and φ at s (including s = t)

3. **T-axiom** (Axioms.lean:290): `Gφ → φ`
   - Valid precisely because G uses reflexive ≤

4. **Temporal coherence alignment**:
   - Old: `F(φ) ∈ mcs t → ∃ s, t < s ∧ φ ∈ mcs s` (too strong)
   - New: `F(φ) ∈ mcs t → ∃ s, t ≤ s ∧ φ ∈ mcs s` (matches semantics)

## Rollback/Contingency

If weak coherence causes unexpected issues:
1. Revert TemporalCoherence.lean changes
2. Fall back to Strategy C (direct_witness_theory construction)
3. Mark Z_chain_forward_F with documented sorry explaining the semantic gap
