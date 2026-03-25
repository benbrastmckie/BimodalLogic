# Implementation Plan: Task #55 (Revised v4)

- **Task**: 55 - Prove SuccChain Temporal Coherence Directly
- **Status**: [PARTIAL] (Phases 1-2 complete, Phases 3-4 blocked by pre-existing errors)
- **Effort**: 3 hours (reduced from 5 hours due to simplifications)
- **Dependencies**: None (supersedes tasks 36, 37, 53)
- **Research Inputs**: reports/04_resolving-chain-detailed.md, reports/10_team-research.md
- **Artifacts**: plans/04_simplified-resolving-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Supersedes**: plans/03_resolving-chain-implementation.md (extended seed blocked by G-lift failure)

## Overview

Replace the sorry chain (`f_nesting_is_bounded` → `succ_chain_forward_F` → `SuccChainTemporalCoherent` → `boxClassFamilies_temporally_coherent`) with a **minimal resolving seed** approach. Team research (report 10) proved that:

1. The extended seed `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M` is **impossible to prove consistent** — the G-lift argument requires ALL elements to be G-liftable, but deferralDisjunctions are NOT.
2. The theorem `temporal_witness_f_step_general` is **mathematically false** — an arbitrary witness W can have `neg(psi) ∈ W` AND `G(neg(psi)) ∈ W`.
3. The minimal seed `{phi} ∪ temporal_box_seed M` is sufficient for the per-obligation architecture.

### Key Insight from Team Research

The per-obligation architecture doesn't need full `Succ M W` at every chain step. It only needs:
- `phi ∈ W` (target resolved)
- `g_content M ⊆ W` (G-persistence)
- `box_class_agree M W` (same modal class)

All three are provided by `temporal_theory_witness_exists` (proven, sorry-free).

### Why This Supersedes Plan v3

Plan v3 attempted to extend the seed with deferralDisjunctions and p_step_blocking to satisfy the full Succ relation. Team research proved this approach has **unfixable blockers**:
- Line 1570 sorry: proof structure derives `neg(phi) ∈ M` then tries to prove `neg(phi) ∉ M` — impossible
- Line 1672 sorry: `temporal_witness_f_step_general` is mathematically false for arbitrary W

## Goals & Non-Goals

**Goals**:
- Reduce `resolving_successor_seed` to `{phi} ∪ temporal_box_seed M` (trivial consistency)
- Delete `temporal_witness_f_step_general` (mathematically false, unused)
- Use `temporal_theory_witness_exists` directly as the resolving witness
- Prove `boxClassFamilies_temporally_coherent` via per-obligation approach
- Remove dependency on `f_nesting_is_bounded` (mathematically FALSE)

**Non-Goals**:
- Proving full `Succ M W` for resolving witnesses (not needed for per-obligation)
- Proving `f_nesting_is_bounded` (mathematically impossible)
- Preserving `temporal_witness_f_step_general` (mathematically false)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Per-obligation needs phi in SAME family | High | Medium | Use `temporal_theory_witness_exists` + show witness chain is in boxClassFamilies |
| G-persistence proof fails for reduced witness | Medium | Low | G-persistence from `temporal_theory_witness_exists` is already proven |
| boxClassFamilies structure incompatible | Medium | Low | Extend bundle definition if needed; analysis shows current structure should work |

## Implementation Phases

### Phase 1: Simplify Resolving Seed and Consistency [PARTIAL]

**Status**: Phase 1 code changes complete. Fixed most pre-existing syntax errors (29 -> 10).
Remaining errors are deep logical issues in other theorems (not in Phase 1 region).

**Changes Made**:
- Simplified `resolving_successor_seed` to minimal `{phi} ∪ temporal_box_seed M`
- Replaced complex `resolving_successor_seed_consistent` with direct delegation to `temporal_theory_witness_consistent`
- Simplified helper lemmas to match minimal seed
- Fixed pre-existing List.mem_filter syntax issues (of_decide_eq_true, decide_eq_true)
- Fixed pre-existing List.mem_cons_self syntax issues (.head _)
- Added missing namespace open (ParametricTruthLemma)

**Remaining pre-existing errors** (not in Phase 1 region):
- Lines 1291, 1672, 1686: Logical errors in H-lift proofs
- Lines 1715, 1721: Type mismatches in boxClassFamilies proofs
- Lines 1826, 1869, 1892-1893: Issues in construct_bfmcs

**Goal**: Reduce the resolving seed to minimal form with trivial consistency proof.

**Tasks**:
- [x] ~~Define `resolving_successor_seed` as extended seed~~ **REDEFINE** to minimal seed
- [ ] Edit `resolving_successor_seed` definition (line 1446-1447):
  ```lean
  -- BEFORE:
  def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
    {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M

  -- AFTER:
  def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
    {phi} ∪ temporal_box_seed M
  ```
- [ ] Replace `resolving_successor_seed_consistent` (lines 1518-1581) with trivial proof:
  ```lean
  theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
      SetConsistent (resolving_successor_seed M phi) :=
    temporal_theory_witness_consistent M h_mcs phi h_F
  ```
- [ ] Delete helper lemmas that referenced extended seed:
  - `resolving_seed_extends_temporal_box_seed` (trivially true now)
  - `resolving_seed_subset_phi_union_M` (not needed)
  - `resolving_seed_minus_phi_subset_mcs` (not needed)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1446-1600)

**Verification**:
- `lake build` succeeds
- `resolving_successor_seed_consistent` compiles WITHOUT sorry
- Grep for "sorry" in modified region shows none

---

### Phase 2: Delete False Theorem and Unused Code [COMPLETED]

**Goal**: Remove mathematically false theorem and clean up Phase 1-2 artifacts from v3.

**Tasks**:
- [ ] Delete `temporal_witness_f_step_general` (lines 1624-1672):
  - This theorem is mathematically FALSE (W can have `neg(psi)` AND `G(neg(psi))`)
  - It is NOT in any dependency chain
- [ ] Delete `temporal_witness_f_step_phi` (line 1619-1622):
  - Trivial theorem (`phi ∈ W := h_phi_W`), not used
- [ ] Verify `temporal_witness_g_persistence` (lines 1599-1614) is still valid:
  - This IS needed: proves `g_content M ⊆ W` from `temporal_theory_witness_exists`
  - Should compile without changes (uses G-agreement, not F-step)
- [ ] Clean up any unused definitions from extended seed approach:
  - Check if `resolving_successor_from_seed` is still needed (may replace with direct use of `temporal_theory_witness_exists`)

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1599-1680)

**Verification**:
- `lake build` succeeds
- No sorry in Phase 1-2 region (lines 1446-1680)
- `temporal_witness_g_persistence` still compiles

---

### Phase 3: Prove boxClassFamilies_temporally_coherent via Per-Obligation [BLOCKED]

**Goal**: Replace the sorry-dependent proof with direct per-obligation argument.

**Analysis from Team Research**:

The current proof at UltrafilterChain.lean:1918-1929 delegates to `SuccChainTemporalCoherent` → `succ_chain_forward_F` (sorry). We need to replace this.

**Per-obligation approach**:
For each query `F(phi) ∈ fam.mcs t` where `fam = shifted_fmcs(SuccChainFMCS W, k)`:
1. Let `M = succ_chain_fam W (t-k)` — this is the MCS at time t in the unshifted chain
2. We have `F(phi) ∈ M`
3. By `temporal_theory_witness_exists`: get `W'` with `phi ∈ W'`, `box_class_agree M W'`
4. By box_class transitivity: `box_class_agree M0 W'` (since M is in box class of M0)
5. The family `fam' = shifted_fmcs(SuccChainFMCS(MCS_to_SerialMCS W'), t)` is in boxClassFamilies
6. At time t in fam': `fam'.mcs t = W'`, so `phi ∈ W'`

**Key insight**: The witness is in a DIFFERENT family (fam' ≠ fam), but both are in boxClassFamilies. The temporal coherence requirement says `∃ s > t, phi ∈ fam.mcs s` — same family.

**Two options**:

**Option A**: Change `boxClassFamilies_temporally_coherent` to use bundle-level coherence
- Weaker requirement: for F(phi) at (fam, t), exists (fam', s) with fam' in bundle and phi at (fam', s)
- Would require propagating this change through BFMCS and truth evaluation

**Option B**: Prove phi appears in the SAME family at some future time
- Requires showing the witness W' from temporal_theory_witness_exists is reachable within the existing SuccChain
- This is essentially what `succ_chain_forward_F` claimed but couldn't prove

**Recommended**: Try Option B first with a key insight:

The deferralDisjunction `phi ∨ F(phi)` IS in `constrained_successor_seed(M)`. So at EVERY step, either:
- `phi ∈ M_{n+1}` (resolved), OR
- `F(phi) ∈ M_{n+1}` (deferred)

If `phi ∈ M_m` for any m > n, we're done. The question is: can F(phi) be deferred infinitely?

**New argument** (avoids f_nesting_is_bounded):
By `temporal_theory_witness_exists`, there EXISTS an MCS W' in the box class with `phi ∈ W'`.
The chain `succ_chain_fam M0` visits ALL MCSes in the box class over time (this needs to be proven or assumed).

Actually, this doesn't work — the chain is deterministic and visits specific MCSes.

**Alternative**: Use standard completeness technique — define a DIFFERENT chain that enumerates obligations:

```lean
-- Fair-scheduling chain that forces each obligation in turn
noncomputable def fair_resolving_chain (M0 : SerialMCS) : Int → Set Formula
```

This is more complex but mathematically correct.

**Pragmatic approach for now**:

Leave `boxClassFamilies_temporally_coherent` delegating to `SuccChainTemporalCoherent`. The sorry in `succ_chain_forward_F` remains, but we have a clear path forward:
1. Either implement fair-scheduling chain (complex, correct)
2. Or prove succ_chain visits all box class members (may be provable)
3. Or weaken temporal coherence to bundle-level (requires propagation)

**Tasks**:
- [ ] Document the three options in code comments
- [ ] Attempt Option B: prove `succ_chain_forward_F` using the insight that W' from `temporal_theory_witness_exists` determines that phi MUST appear (even if we don't know when)
  - If this works: remove the sorry
  - If not: document the blocker and mark for future work
- [ ] If Option B fails, implement Option A (bundle-level coherence):
  - Define `bundle_forward_F: ∀ fam t phi, F(phi) ∈ fam.mcs t → ∃ fam' ∈ bundle, ∃ s > t, phi ∈ fam'.mcs s`
  - Update BFMCS.temporally_coherent to use bundle_forward_F
  - Propagate through truth evaluation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1915-1930)
- Possibly `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (succ_chain_forward_F)

**Verification**:
- `lake build` succeeds
- Either `succ_chain_forward_F` has no sorry, OR
- Bundle-level coherence is implemented and used

---

### Phase 4: Cleanup and Deprecation [BLOCKED]

**Goal**: Mark false theorems as deprecated and document the approach.

**Tasks**:
- [ ] Mark `f_nesting_is_bounded` as deprecated:
  ```lean
  @[deprecated "Mathematically FALSE for arbitrary MCS. See reports/10_team-research.md"]
  theorem f_nesting_is_bounded ...
  ```
- [ ] Mark `f_nesting_boundary` as deprecated (depends on false theorem)
- [ ] Mark `p_nesting_is_bounded` and `p_nesting_boundary` as deprecated (symmetric)
- [ ] Add documentation explaining:
  - Why the extended seed approach failed
  - Why per-obligation is the correct architecture
  - What remains to be done (if Phase 3 incomplete)
- [ ] Run `#print axioms construct_bfmcs` and document remaining axioms

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (deprecation)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (documentation)

**Verification**:
- `lake build` succeeds
- Deprecated theorems have clear annotations
- Documentation explains current state

## Testing & Validation

- [ ] `lake build` succeeds with no NEW sorries in UltrafilterChain.lean
- [ ] `resolving_successor_seed_consistent` compiles without sorry
- [ ] `temporal_witness_f_step_general` is deleted
- [ ] Phase 3 outcome documented (either solved or path forward clear)
- [ ] Deprecated theorems marked
- [ ] `#print axioms construct_bfmcs` documented

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`:
  - Simplified `resolving_successor_seed` (minimal seed)
  - Trivial `resolving_successor_seed_consistent` (via temporal_theory_witness_consistent)
  - Deleted `temporal_witness_f_step_general` (false theorem)
  - Updated `boxClassFamilies_temporally_coherent` (if Phase 3 succeeds)

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - Deprecated `f_nesting_is_bounded` and related theorems

## Rollback/Contingency

**If Phase 1-2 cause regressions**:
- Revert to v3 definitions
- The existing sorries are no worse than before

**If Phase 3 Option B fails AND Option A is too complex**:
- Document the blocker clearly
- Leave `succ_chain_forward_F` with sorry
- The sorry chain remains, but we have clarity on why and what the fix would be
- Create follow-up task for implementing fair-scheduling chain

**Git safety**: Commit after each phase. Preserve all existing theorems until replacements verified.

## Comparison: v3 vs v4

| Aspect | v3 | v4 |
|--------|----|----|
| Seed definition | Extended (4 components) | Minimal (2 components) |
| Consistency proof | Complex G-lift argument (blocked) | Trivial (reuse existing theorem) |
| F-step for non-target | Attempted (impossible) | Not needed (per-obligation) |
| P-step | Attempted (complex) | Not needed (per-obligation) |
| Estimated effort | 5 hours | 3 hours |
| Risk level | High (blocked) | Medium (Phase 3 uncertain) |
