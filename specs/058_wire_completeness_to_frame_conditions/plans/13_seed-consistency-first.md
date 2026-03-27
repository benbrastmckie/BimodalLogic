# Implementation Plan: Task #58 - Seed Consistency First (v13)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/61_path-forward-analysis.md
- **Previous Plan**: plans/12_restricted-truth-lemma-path.md (partially implemented, blockers identified)
- **Artifacts**: plans/13_seed-consistency-first.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## Revision Summary

Plan v12 identified the correct path (restricted construction) but Phase 1 targeted the wrong sorries (unused helper lemmas in RestrictedTruthLemma.lean) and Phase 2 hit the Lindenbaum extension blocker. Report 61 pinpoints the **real root sorry**: `constrained_successor_seed_restricted_consistent` at SuccChainFMCS.lean:1543.

This plan attacks the root cause first, then follows a different wiring path that avoids the `restricted_tc_family_to_fmcs` blocker (CanonicalConstruction.lean:873,876).

## Architecture: Sorry Dependency Chain

```
Completeness.lean sorries (lines 120, 163, 214)
  └── bundle_validity_implies_provability (line 214, model-theoretic glue)
        └── [NEEDS: TaskModel from restricted construction]
              └── RestrictedTemporallyCoherentFamily (SuccChainFMCS.lean:4191)
                    └── build_restricted_tc_family (sorryAx via chain)
                          └── restricted_forward_chain_forward_F (sorryAx)
                                └── restricted_forward_chain (sorryAx)
                                      └── constrained_successor_restricted (sorryAx)
                                            └── constrained_successor_seed_restricted_consistent ← ROOT SORRY (line 1543)
```

## What's Sorry-Free

| Component | Location | Status |
|-----------|----------|--------|
| `construct_bfmcs_bundle` | UltrafilterChain.lean:2853 | Sorry-free |
| `bundle_completeness_contradiction` | UltrafilterChain.lean | Sorry-free |
| `shifted_truth_lemma` | CanonicalConstruction.lean:493 | Sorry-free |
| `constrained_predecessor_seed_restricted_consistent` | SuccChainFMCS.lean:2968 | Sorry-free (seed ⊆ u) |
| `restricted_truth_lemma` (main theorem) | RestrictedTruthLemma.lean:268 | Structurally complete (sorry dependency only via chain) |

## What Has Sorries

| Sorry | Location | Root Cause |
|-------|----------|------------|
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:1543 | BRS elements not in u |
| `augmented_seed_consistent` | SuccChainFMCS.lean:1480 | Reduces to above (absorption lemma) |
| `restricted_tc_family_to_fmcs` forward_G/backward_H | CanonicalConstruction.lean:873,876 | Independent Lindenbaum gap (AVOID) |
| `bundle_validity_implies_provability` | Completeness.lean:214 | Missing model-theoretic glue |
| `dense_completeness_fc` | Completeness.lean:120 | Depends on above |
| `discrete_completeness_fc` | Completeness.lean:163 | Separate blocker (discrete_Icc_finite_axiom) |

## Goals & Non-Goals

**Goals**:
- Prove `constrained_successor_seed_restricted_consistent` (root sorry)
- Build TaskModel directly from RestrictedTemporallyCoherentFamily (bypassing FMCS conversion)
- Wire to `bundle_validity_implies_provability` and `dense_completeness_fc`

**Non-Goals**:
- Fixing `restricted_tc_family_to_fmcs` (CanonicalConstruction.lean:873,876) — avoid this path
- Fixing `discrete_completeness_fc` — separate blocker (`discrete_Icc_finite_axiom`)
- Deleting unused helper lemmas in RestrictedTruthLemma.lean (cleanup, not critical)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof is harder than neg-exclusion suggests | H | M | Fallback to Option B (direct BFMCS_Bundle to TaskModel) |
| TaskModel from RTCF requires new infrastructure | M | L | Follow existing CanonicalTaskModel patterns |
| shifted_truth_lemma type mismatch with restricted construction | M | M | Use restricted_truth_lemma instead (DRM-level) |

---

## Implementation Phases

### Phase 1: Prove Seed Consistency [BLOCKED]

**Goal**: Eliminate the root sorry at SuccChainFMCS.lean:1543

**Target**: `constrained_successor_seed_restricted_consistent`

**What we're proving**: `SetConsistent (constrained_successor_seed_restricted phi u)` where `u` is a `DeferralRestrictedMCS`.

**Seed composition**:
```
constrained_successor_seed_restricted phi u =
  g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u) ∪ boundary_resolution_set(phi, u)
```

**Why predecessor was easy**: `constrained_predecessor_seed_restricted phi u ⊆ u`, so consistency inherits from u. The successor seed is harder because `boundary_resolution_set(phi, u)` contains elements NOT in u.

**Proof Strategy**:

The key insight is that negations of BRS elements cannot appear in the seed:

1. **Already proven**: `neg_not_in_constrained_successor_seed_restricted` (line 1440) — for any `chi` where `F(chi) ∈ u`, `chi.neg ∉ seed`. This uses three helper lemmas:
   - `neg_not_in_g_content_when_F_in` — ¬chi ∉ g_content when F(chi) ∈ u
   - `neg_not_in_deferralDisjunctions` — structural
   - `neg_not_in_p_step_blocking_restricted` — structural
   - `neg_not_in_boundary_resolution_set` — structural

2. **Proof approach**: Suppose for contradiction that L ⊆ seed and L ⊢ ⊥. Partition L into:
   - `L_u` = L ∩ u (non-boundary elements, subset of u)
   - `L_brs` = L ∩ BRS \ u (boundary elements: each chi where F(chi) ∈ u but chi ∉ u)

   For each chi ∈ L_brs, by deduction: `L_u ∪ (L_brs \ {chi}) ⊢ chi → ⊥ = ¬chi`.

   But we know F(chi) ∈ u. By the axiom `F(chi) → chi ∨ F(chi)` and deferralDisjunctions membership, `chi ∨ F(chi) ∈ u`. Combined with ¬chi derivable from u-elements, we get F(chi) derivable from u-elements. Iterating this for all BRS elements gives a set entirely in u that derives ⊥, contradicting u's consistency.

   **Alternative (simpler)**: If |L_brs| = 1 (single BRS element chi), the argument above works directly. For |L_brs| > 1, induction on |L_brs| with the deduction theorem at each step.

**Tasks**:
- [ ] Examine goal state at SuccChainFMCS.lean:1543 with `lean_goal`
- [ ] Verify `boundary_resolution_set` definition and membership characterization
- [ ] Implement the partition argument (L_u / L_brs split)
- [ ] Handle single-BRS-element base case
- [ ] Handle multi-BRS-element inductive case via deduction theorem
- [ ] Also fix `augmented_seed_consistent` (line 1480) — follows from absorption + this theorem
- [ ] Verify: `lake build` on SuccChainFMCS.lean, `#print axioms constrained_successor_seed_restricted_consistent` shows no sorryAx

**Timing**: 3-4 hours (this is the hardest phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 2: Build TaskModel from Restricted Construction [NOT STARTED]

**Goal**: Create model-theoretic infrastructure connecting the restricted chain to `valid_over`

**Key Decision**: Bypass `restricted_tc_family_to_fmcs` (blocked by Lindenbaum gap). Instead, build a TaskModel directly from the `RestrictedTemporallyCoherentFamily` using the `restricted_truth_lemma` (which works at DRM level, not full MCS level).

**Approach**: Define a restricted canonical model where:
1. Each world is a DeferralRestrictedMCS position in the chain
2. Valuation is membership in the DRM
3. The restricted_truth_lemma provides MCS-membership ↔ truth_at for formulas in subformulaClosure(phi)

**Mathematical Content**:

```lean
-- The restricted canonical task model
-- Uses DRM chain positions directly (no Lindenbaum extension needed)
def RestrictedCanonicalTaskModel (phi : Formula)
    (rtcf : RestrictedTemporallyCoherentFamily phi) : TaskModel CanonicalTaskFrame :=
  -- Valuation: atom p is true at position n iff p ∈ restricted_succ_chain_fam phi seed n
  ...

-- Omega: single history + time shifts (shift-closed by construction)
def RestrictedOmega (phi : Formula) (rtcf : RestrictedTemporallyCoherentFamily phi) :
    Set (WorldHistory CanonicalTaskFrame) :=
  { sigma | ∃ delta : Int, sigma = WorldHistory.time_shift (restricted_history rtcf) delta }

-- The key theorem: for phi (the formula being evaluated),
-- membership in restricted chain at position 0 ↔ truth_at in RestrictedCanonicalTaskModel
theorem restricted_completeness_truth (phi : Formula)
    (rtcf : RestrictedTemporallyCoherentFamily phi) :
    phi ∈ restricted_succ_chain_fam phi rtcf.seed 0 ↔
    truth_at (RestrictedCanonicalTaskModel phi rtcf) (RestrictedOmega phi rtcf) (restricted_history rtcf) 0 phi
```

**Tasks**:
- [ ] Define `restricted_history` converting RTCF to WorldHistory
- [ ] Define `RestrictedOmega` as single history + time-shifts
- [ ] Prove `restrictedOmega_shift_closed`
- [ ] Define `RestrictedCanonicalTaskModel`
- [ ] Prove `restricted_completeness_truth` using `restricted_truth_lemma`
- [ ] Verify: `lake build`, `#print axioms restricted_completeness_truth`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (new section) or
- New file: `Theories/Bimodal/Metalogic/Bundle/RestrictedCanonicalModel.lean`

---

### Phase 3: Wire to Completeness.lean [NOT STARTED]

**Goal**: Eliminate `bundle_validity_implies_provability` sorry (line 214) and `dense_completeness_fc` sorry (line 120)

**Proof structure** (contrapositive):
1. Assume phi not provable
2. Then neg(phi) is consistent (`not_provable_implies_neg_consistent`)
3. Extend neg(phi) to DeferralRestrictedMCS for phi
4. Build `RestrictedTemporallyCoherentFamily` from that DRM
5. Build `RestrictedCanonicalTaskModel` from RTCF
6. By `restricted_completeness_truth`: neg(phi) true at position 0
7. Therefore phi is false at position 0 → phi is not valid over Int
8. Contrapositive: valid_over Int phi → provable phi

**Tasks**:
- [ ] Define `restricted_mcs_from_consistent`: consistent set → DeferralRestrictedMCS
- [ ] Wire `bundle_validity_implies_provability` using restricted construction
- [ ] Wire `dense_completeness_fc` via `dense_implies_int + completeness_over_Int` (or directly)
- [ ] Final axiom verification: `#print axioms` for all three targets
- [ ] `lake build` succeeds clean

**Note on `discrete_completeness_fc`**: This sorry has a SEPARATE blocker (`discrete_Icc_finite_axiom`). It cannot be resolved in this task and should remain as documented debt.

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

---

## Fallback: Option B (Direct BFMCS_Bundle to TaskModel)

If Phase 1 proves intractable (seed consistency is harder than expected), pivot to Option B from report 61:

1. Build TaskModel directly from `BFMCS_Bundle` (which IS sorry-free)
2. Define `BundleCanonicalTaskModel` with bundle-level coherence
3. Prove forward-only truth lemma (MCS membership → truth_at) — only forward direction needed for completeness
4. Wire to Completeness.lean

This avoids needing `constrained_successor_seed_restricted_consistent` entirely but requires more new infrastructure.

**Trigger**: If Phase 1 exceeds 4 hours without convergence.

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorryAx)
- [ ] Final: `bundle_validity_implies_provability` and `dense_completeness_fc` sorry-free
- [ ] `discrete_completeness_fc` remains sorry (documented, separate blocker)

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Omega-enumeration for arbitrary MCS | Doesn't exist, never implemented | Report 60 |
| Bundle-level as truth lemma input | G backward needs same-family | Reports 45, 50 |
| Forward-only truth lemma | imp forward uses backward IH | Reports 50, 17 |
| restricted_tc_family_to_fmcs | Independent Lindenbaum extensions break Succ | Report 61, CanonicalConstruction.lean:865 |
| Fix RestrictedTruthLemma.lean helper sorries | Unused helper lemmas, not on critical path | Report 61 |
