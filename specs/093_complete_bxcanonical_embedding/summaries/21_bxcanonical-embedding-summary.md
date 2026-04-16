# Implementation Summary: Close BXCanonical Embedding (v21)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: BLOCKED
- **Plan**: plans/21_bxcanonical-embedding.md
- **Phases Completed**: 0/5

## Outcome

All 5 phases are BLOCKED. Deep analysis of the 6 sorry sites in `RootScopedChain.lean` revealed that all 6 depend on the same fundamental obstruction: the F-propagation gap in the enriched forward chain construction. The plan's hypothesis that buc/fuc (Problem B) are independent of forward_F (Problem A) was incorrect.

## Analysis

### Why buc/fuc are NOT independent of forward_F

The plan (informed by Report 21) estimated 85% confidence that `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` could be closed independently using quasimodel infrastructure. Detailed proof-state analysis shows this is not the case:

**restricted_fuc** (line 1396): Forward Until/Since coherence requires, given `(phi U psi) in fam.mcs t`, finding `s >= t` with `psi in fam.mcs s`. By BX10, `(phi U psi) -> F(psi)`, so this reduces directly to the forward_F problem for psi along the chain. The quasimodel infrastructure (`bx_until_eventuality_resolution` in Frame.lean) provides a BXPoint witness via `bx_le`, but this is in the canonical frame -- not in the integer-indexed dd_chain. There is no bridge from BXPoint witnesses to chain indices.

**restricted_buc** (line 1391): Backward Until/Since coherence (given witness pattern, derive `(phi U psi) in fam.mcs t`) requires the "step transfer" property: `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs r` implies `(phi U psi) in fam.mcs r`. The `UntilSinceCoherence.lean` module (line 27-28) explicitly states: "The step transfer is NOT derivable from the bare FMCS structure (forward_G, backward_H)." The dd_chain's enriched_fwd_step is a Lindenbaum extension whose only backward property is `h_content(chain(r+1)) ⊆ chain(r)`. Since `(phi U psi)` is not an H-formula, h_content cannot pull it backward. BX4' (connect_past) only gives `F(phi U psi) in chain(r)` from `(phi U psi) in chain(r+1)`, not `(phi U psi) in chain(r)`.

**restricted_tc** (line 1386): Directly requires forward_F and backward_P.

### Why the fold-order trick fails

The plan proposed testing whether processing target LAST in the BX11 fold (`enriched_fwd_fold_with_witness`) deterministically resolves the target. Analysis of the BX11 cases at the last fold step (combining accumulated compound beta with target):

- Case 1: `F(beta and target)` -- target in M' (deterministic, good)
- Case 2: `F(beta and F(target))` -- only F(target) in M' (DEFERRED, bad)
- Case 3: `F(F(beta) and target)` -- target in M' (deterministic, good)

Case 2 cannot be ruled out. BX11 is a genuine three-way disjunction, and there is no structural reason why Case 2 is excluded when target is processed last. The fold-order trick provides a 2/3 chance of deterministic resolution but not a guarantee.

### The fundamental obstruction

The "Correct approach" comment (RootScopedChain.lean lines 1274-1288) correctly identifies the fix: prove consistency of `{target} ∪ g_content(M) ∪ f_carry(M)` when `F(target) in M`. This would enable a forward step that BOTH resolves the target AND preserves all F-formulas.

The obstruction to this consistency proof: the standard `generalized_temporal_k` argument works for seeds containing only G-formulas (g_content), but f_carry contains F-formulas. G(F(chi)) in M is NOT guaranteed from F(chi) in M, so the temporal necessitation step fails for f_carry elements. A new consistency argument is needed that handles the interaction between G-formulas and F-formulas in the seed.

## Dependency Graph of Sorry Sites

```
rr_fwd_chain_forward_F (line 1295) -- PRIMARY BLOCKER
    |
    +-- dd_fmcs_forward_F (line 1326, t<0 case) -- depends on forward_F
    |
    +-- dd_fmcs_backward_P (line 1333) -- symmetric blocker
    |
    +-- dd_bfmcs_restricted_tc (line 1386) -- depends on forward_F + backward_P
    |
    +-- dd_bfmcs_restricted_fuc (line 1396) -- reduces to forward_F via BX10
    |
    +-- dd_bfmcs_restricted_buc (line 1391) -- requires step transfer (same gap)
```

## Recommendations

1. **Do not attempt Plan v21 again.** All phases are blocked by the same obstruction.

2. **Next step**: A new plan focused exclusively on the extended seed consistency proof:
   - Prove `SetConsistent ({target} ∪ g_content(M) ∪ f_carry(M))` when `F(target) in M`
   - This requires a novel argument handling G-formula/F-formula interaction
   - Estimated effort: 25-35 hours (per Report 18 and Plan v18 assessment)
   - If this consistency is proved, ALL 6 sorries close in sequence

3. **Alternative approach**: Consider a semantic/tree-based construction (Summary 18 recommendation) that avoids the chain-based approach entirely. This would build a countermodel directly from BXPoints using the quasimodel infrastructure, bypassing the integer-indexed chain and its F-propagation difficulties.

## Files Analyzed (no modifications)

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites, all blocked
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` -- step transfer parameterized
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- restricted coherence definitions
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- or_until_in_mcs
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- seed consistency proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- bx_until_eventuality_resolution
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- quasimodel Until/Since
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX axiom definitions
