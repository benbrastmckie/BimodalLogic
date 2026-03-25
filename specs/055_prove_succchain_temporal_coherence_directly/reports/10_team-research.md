# Team Research Report: Task #55 Blockers

**Task**: 55 - Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1774399641_e22b47

## Summary

Both blockers are resolved. The two sorries (line 1570 and line 1672 in UltrafilterChain.lean) stem from attempting to prove theorems that are either **mathematically false** (F-step for arbitrary witness) or **structurally broken** (G-lift for non-G-liftable elements). The solution is architectural: reduce the resolving seed, delete the false theorem, and rely on the per-obligation approach.

## Key Findings

### Blocker 1: G-lift for Extended Seed (line 1570 sorry)

**Status**: UNFIXABLE as written. Must restructure.

The sorry at `resolving_successor_seed_consistent` (UltrafilterChain.lean:1570) attempts `absurd h_neg_phi_in_M (sorry)` — trying to prove `neg(phi) ∉ M` after having already derived `neg(phi) ∈ M` at line 1552. This is **impossible**: `neg(phi) ∈ M` and `F(phi) ∈ M` coexist validly in temporal logic (phi is false now but true in the future).

**Root cause**: The G-lift argument from `temporal_theory_witness_consistent` requires ALL context elements to be G-liftable (`∀ x ∈ context, G(x) ∈ M`). This holds for `temporal_box_seed M` (via `G_of_temporal_box_seed`, line 1053) but NOT for:
- `deferralDisjunctions M`: elements of form `psi ∨ F(psi)` — `G(psi ∨ F(psi)) ∈ M` would require `A → G(A)`, which is FALSE in temporal logic
- `p_step_blocking_formulas M`: elements of form `H(neg(chi))` — no reason `G(H(neg(chi))) ∈ M`

**Both teammates independently verified**: Option B (factoring derivations via cut) also fails because M-elements cannot be eliminated from derivations without a G-lift. The extended seed's consistency CANNOT be proven with the G-lift approach.

### Blocker 2: F-step for Non-Target Formulas (line 1672 sorry)

**Status**: Theorem is MATHEMATICALLY FALSE. Delete it.

`temporal_witness_f_step_general` claims `f_content M ⊆ W ∪ f_content W` for an arbitrary temporal witness W. This is false: W can contain both `neg(psi) ∈ W` and `G(neg(psi)) ∈ W` (i.e., `neg(F(psi)) ∈ W`), making neither `psi ∈ W` nor `F(psi) ∈ W`.

**Impact**: This theorem is NOT in the implementation plan's dependency chain. It is a dead-end helper that was explored but proved impossible. Safe to delete.

## Synthesis

### Conflicts Resolved

No conflicts between teammates. Both independently converged on the same conclusion:

1. Reduce `resolving_successor_seed` to `{phi} ∪ temporal_box_seed M`
2. Delete `temporal_witness_f_step_general`
3. Use `temporal_theory_witness_consistent` directly for consistency

### Recommended Solution

**Step 1: Redefine `resolving_successor_seed`**

```lean
-- BEFORE (line 1446-1447):
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M

-- AFTER:
def resolving_successor_seed (M : Set Formula) (phi : Formula) : Set Formula :=
  {phi} ∪ temporal_box_seed M
```

**Step 2: Replace `resolving_successor_seed_consistent`**

```lean
-- BEFORE (lines 1518-1581): complex proof with sorry
-- AFTER:
theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent (resolving_successor_seed M phi) :=
  temporal_theory_witness_consistent M h_mcs phi h_F
```

**Step 3: Delete `temporal_witness_f_step_general`** (lines 1624-1672)

This theorem is mathematically false and not needed.

**Step 4: Use `temporal_theory_witness_exists` directly for resolving successors**

The witness from `temporal_theory_witness_exists` provides exactly what the per-obligation approach needs:
- `phi ∈ W` (target resolved)
- `∀ a, G(a) ∈ M → G(a) ∈ W` (G-persistence: `g_content M ⊆ W`)
- `box_class_agree M W` (same modal equivalence class)

### Remaining Architectural Question

**Does `boxClassFamilies_temporally_coherent` require full `Succ` at each chain step?**

Analysis of UltrafilterChain.lean:1918-1929 shows:
- The proof delegates to `SuccChainTemporalCoherent` which uses `succ_chain_forward_F`
- `succ_chain_forward_F` requires phi to appear in the SAME family at some future time
- The per-obligation approach (different witness W' for each phi) gives W' in a DIFFERENT family

**Resolution**: This is a Phase 3-4 concern, not a Phase 1-2 concern. The reduced seed and consistency proof are correct and sufficient for Phase 1-2. Phase 3-4 must address how to construct chains that internally resolve F-obligations. Options include:
1. Fair scheduling enumeration over formulas (standard completeness technique)
2. Replacing `boxClassFamilies` to use resolving chains with per-step forcing
3. Proving `forward_F` via the existing chain by showing deferral is bounded (requires new argument, since `f_nesting_is_bounded` is false for the current construction)

### Impact on Implementation Plan (v3)

| Phase | Impact | Action |
|-------|--------|--------|
| Phase 1 | **Major simplification** | Reduce seed, replace sorry with trivial proof |
| Phase 2 | **Scope reduction** | Drop F-step-general and P-step from seed requirements; only prove G-persistence and box_class_agree |
| Phase 3 | **Unchanged** | Still needs ResolvingChainFMCS construction |
| Phase 4 | **Clarified** | Per-obligation architecture confirmed correct |
| Phase 5 | **Unchanged** | Cleanup and deprecation |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | G-lift blocker analysis | completed | high |
| B | F-step requirement analysis | completed | high |

### Teammate A Key Insight
The sorry at line 1570 tries to prove `neg(phi) ∉ M` after deriving `neg(phi) ∈ M` — structurally impossible. The G-lift cannot extend to non-G-liftable elements without `A → G(A)`, which this logic lacks.

### Teammate B Key Insight
`temporal_witness_f_step_general` is mathematically false for arbitrary W and not in the dependency chain. The per-obligation architecture only needs phi resolved, not all F-obligations. The simplest fix is to not include deferralDisjunctions in the seed at all.

## References

| Source | Location | Relevance |
|--------|----------|-----------|
| `temporal_theory_witness_consistent` | UltrafilterChain.lean:1111-1152 | Proven; handles `{phi} ∪ temporal_box_seed M` |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:1158-1191 | Proven; provides complete resolving witness |
| `G_of_temporal_box_seed` | UltrafilterChain.lean:1053-1059 | G-liftability of temporal_box_seed |
| `G_lift_from_context` | UltrafilterChain.lean:1067-1083 | G-lift requires ALL elements G-liftable |
| `resolving_successor_seed` | UltrafilterChain.lean:1446-1447 | Current extended seed (to be reduced) |
| `resolving_successor_seed_consistent` | UltrafilterChain.lean:1518-1581 | Sorry at line 1570 (to be replaced) |
| `temporal_witness_f_step_general` | UltrafilterChain.lean:1638-1672 | Sorry at line 1672 (to be deleted) |
| `boxClassFamilies_temporally_coherent` | UltrafilterChain.lean:1918-1929 | Delegates to SuccChainTemporalCoherent |
| Research report 04 §3.4 | reports/04_resolving-chain-detailed.md | Confirms G-lift failure for extended seed |
