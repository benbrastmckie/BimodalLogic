# Implementation Plan: Task #48 (v9)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 3-4 hours
- **Dependencies**: Team research report 15 (Option C analysis)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/15_team-research.md
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/15_teammate-b-findings.md
- **Previous Plans**:
  - plans/08_g-content-fix.md (BLOCKED - hypothesis strengthening cannot work)
- **Artifacts**: plans/09_boundary-resolution-seed.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plans v7 and v8 attempted to prove the existing theorems by strengthening hypotheses. Team research confirmed this approach **cannot work** due to the MCS maximality gap: the Succ relation only imposes *inclusion* constraints, not *exclusion* constraints, so F(psi) can appear in chain(k+1) via Lindenbaum maximality regardless of which propagation paths are blocked.

### The Solution: Option C

Modify the chain construction to add a `boundary_resolution_set` to the seed. When F(chi) is at the boundary (FF(chi) ∉ dc, GF(chi) ∉ u), add chi directly to the seed, forcing chi ∈ chain(k+1).

This makes `restricted_single_step_forcing` trivial: chi ∈ seed ⊆ chain(k+1).

## Goals & Non-Goals

**Goals**:
- Add `boundary_resolution_set` to constrained_successor_seed_restricted
- Prove the augmented seed is consistent
- Simplify `restricted_single_step_forcing` using the new seed
- Remove boundary case sorries (lines 3077, 3236)
- Net sorry reduction: from 7 to 2 (only deprecated sorries remain)

**Non-Goals**:
- Proving the primed theorems from v8 (they are not needed with Option C)
- Modifying deferralClosure structure
- Changing the unrestricted chain construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Consistency proof fails | High | Medium | Verify neg(chi) ∉ old_seed carefully |
| Breaks downstream theorems | Medium | Medium | Run lake build after each phase |
| Succ properties violated | High | Low | Prove f_step still holds |

## Implementation Phases

### Phase 1: Define boundary_resolution_set [NOT STARTED]

**Goal**: Add the boundary resolution set definition.

**Definition**:
```lean
/-- Formulas that must be resolved at the boundary.
    When F(chi) ∈ u, FF(chi) ∉ dc, and GF(chi) ∉ u, add chi to seed. -/
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

**Tasks**:
- [ ] Add definition to SuccChainFMCS.lean (near constrained_successor_seed_restricted)
- [ ] Prove `boundary_resolution_set phi u ⊆ deferralClosure phi`
  - chi is inner formula of F(chi) ∈ u ⊆ dc, so chi ∈ subformulaClosure ⊆ dc
- [ ] Prove boundary_resolution_set is finite (follows from u being finite/decidable)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 2: Prove consistency of augmented seed [NOT STARTED]

**Goal**: Prove `old_seed ∪ boundary_resolution_set` is consistent.

**Strategy**:
```lean
theorem boundary_resolution_seed_consistent (phi : Formula)
    (u : DeferralRestrictedSerialMCS phi) :
    SetConsistent (constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u) := by
  -- Key argument:
  -- 1. old_seed ⊆ u, so old_seed is consistent
  -- 2. For each chi ∈ boundary_resolution_set:
  --    - chi ∨ F(chi) ∈ old_seed (deferral disjunction, since F(chi) ∈ u ∩ closureWithNeg)
  --    - neg(chi) ∉ old_seed (g_content doesn't contain it, deferralDisjunctions are disjunctions, p_step_blocking doesn't contain it)
  -- 3. Since neg(chi) is not in old_seed and not derivable from old_seed, adding chi preserves consistency
  sorry
```

**Key lemma needed**:
```lean
lemma neg_not_in_constrained_seed (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_F_in : Formula.some_future chi ∈ u)
    (h_FF_not_dc : Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula))
    (h_GF_not : Formula.all_future (Formula.some_future chi) ∉ u) :
    chi.neg ∉ constrained_successor_seed_restricted phi u := by
  -- g_content(u) = {psi | G(psi) ∈ u}. chi.neg ∈ g_content(u) iff G(chi.neg) ∈ u.
  --   G(chi.neg) = G(neg(chi)) = neg(F(chi)). So need neg(F(chi)) ∈ u.
  --   By negation completeness on F(chi) (which is in dc): F(chi) ∈ u OR neg(F(chi)) ∈ u.
  --   Since F(chi) ∈ u (hypothesis), this branch is taken. So neg(F(chi)) ∉ u typically,
  --   unless u is inconsistent. But u is an MCS, so consistent.
  --   Actually, F(chi) ∈ u means neg(F(chi)) ∉ u by consistency.
  --   So G(chi.neg) = neg(F(chi)) ∉ u, hence chi.neg ∉ g_content(u).
  --
  -- deferralDisjunctions: these are disjunctions psi ∨ F(psi), not chi.neg directly.
  --
  -- p_step_blocking: these are specific formulas related to P-step. Need to check.
  sorry
```

**Tasks**:
- [ ] Prove `chi.neg ∉ g_content(u)` using consistency of u
- [ ] Prove `chi.neg ∉ deferralDisjunctions phi u` (disjunctions are not neg formulas)
- [ ] Prove `chi.neg ∉ p_step_blocking_formulas_restricted phi u`
- [ ] Combine into `neg_not_in_constrained_seed`
- [ ] Use to prove `boundary_resolution_seed_consistent`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 3: Update constrained_successor_restricted [NOT STARTED]

**Goal**: Add boundary_resolution_set to the seed and prove properties.

**Modified construction**:
```lean
def constrained_successor_seed_restricted_v2 (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions phi u ∪ p_step_blocking_formulas_restricted phi u
  ∪ boundary_resolution_set phi u

def constrained_successor_restricted_v2 (phi : Formula) (u : DeferralRestrictedSerialMCS phi) :
    DeferralRestrictedSerialMCS phi :=
  deferral_restricted_lindenbaum phi (constrained_successor_seed_restricted_v2 phi u)
    (boundary_resolution_seed_consistent phi u)
```

**Tasks**:
- [ ] Create v2 versions of seed and constructor
- [ ] Prove Succ u v2 (g_persistence: unchanged; f_step: still holds)
- [ ] Prove seriality preserved
- [ ] Update restricted_forward_chain to use v2

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 4: Simplify restricted_single_step_forcing [NOT STARTED]

**Goal**: Remove boundary case sorry using the new seed.

**New proof**:
```lean
theorem restricted_single_step_forcing_v2 (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F_in : Formula.some_future psi ∈ restricted_forward_chain_v2 phi M0 k)
    (h_FF_not : Formula.some_future (Formula.some_future psi) ∉ restricted_forward_chain_v2 phi M0 k) :
    psi ∈ restricted_forward_chain_v2 phi M0 (k + 1) := by
  -- Case split on whether FF(psi) ∈ dc
  by_cases h_FF_dc : Formula.some_future (Formula.some_future psi) ∈ (deferralClosure phi : Set Formula)
  · -- FF(psi) ∈ dc: use existing negation completeness argument
    -- ... (existing proof)
  · -- FF(psi) ∉ dc: boundary case
    -- Case split on GF(psi) ∈ chain(k)
    by_cases h_GF : Formula.all_future (Formula.some_future psi) ∈ restricted_forward_chain_v2 phi M0 k
    · -- GF(psi) ∈ chain(k): psi ∈ chain(k+1) via g_content
      exact g_content_subset_succ ... psi (by simp [g_content]; exact h_GF)
    · -- GF(psi) ∉ chain(k): psi ∈ boundary_resolution_set
      -- psi ∈ seed ⊆ chain(k+1)
      have h_in_brs : psi ∈ boundary_resolution_set phi (restricted_forward_chain_v2 phi M0 k) := by
        simp [boundary_resolution_set]
        exact ⟨h_F_in, h_FF_dc, h_GF⟩
      exact seed_subset_mcs ... h_in_brs
```

**Tasks**:
- [ ] Implement v2 theorem using boundary_resolution_set
- [ ] Verify no sorries in boundary case
- [ ] Update bounded_witness to use v2

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 5: Update downstream and verify [NOT STARTED]

**Goal**: Update all callers and verify build.

**Tasks**:
- [ ] Update `restricted_bounded_witness` to use v2 theorems
- [ ] Update `restricted_forward_chain_iter_F_witness` entry point
- [ ] Run `lake build`
- [ ] Count sorries: should be 2 (deprecated at lines 736, 971)
- [ ] Remove old primed theorems from v8 if redundant
- [ ] Clean up debug comments

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -c "sorry" SuccChainFMCS.lean` returns 2 (only deprecated sorries)
- [ ] `boundary_resolution_set` is defined and has subset lemma
- [ ] `boundary_resolution_seed_consistent` is proven (no sorry)
- [ ] `restricted_single_step_forcing_v2` has no sorries
- [ ] `restricted_forward_chain_iter_F_witness` works with v2 chain

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Modified chain construction
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/09_boundary-resolution-seed-summary.md` - Summary

## Rollback/Contingency

If the consistency proof fails:

1. **Investigate neg(chi) derivability**: Check if modal axioms applied to g_content can derive neg(chi). If so, restrict boundary_resolution_set further.

2. **Fall back to construction-time enforcement**: Instead of adding to seed, modify the Lindenbaum enumeration to prioritize boundary resolution formulas.

3. **Hybrid approach**: Use Option B (lexicographic) for the cases where consistency fails, Option C for the rest.

## Key Insight

The fundamental problem was that plans v7-v8 tried to prove "F(psi) ∉ chain(k+1) for ALL valid successors." But some valid successors DO contain F(psi) — the Lindenbaum extension can choose freely when the seed doesn't force a choice.

Option C flips the approach: instead of proving exclusion, we **modify the construction** to ensure the seed DOES force the resolution. The theorem then becomes trivially true because we've made it true by construction.
