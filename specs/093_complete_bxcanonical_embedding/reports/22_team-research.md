# Research Report: Task #93 — Team Research Synthesis (Round 22)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1776360019_7dfbab

## Summary

Round 22 team research with 4 teammates investigated the mathematically correct long-term solution for closing 6 sorry sites in RootScopedChain.lean. All teammates converge on a unified diagnosis and a clear recommended path, with significant downward revision of prior confidence estimates for buc/fuc independence (85% → 40-55%) and upward convergence on the ordered-discharge chain approach (Plan v18).

## Key Findings

### Finding 1: Unified Root Cause — Non-Deterministic Lindenbaum Extension (All teammates agree, HIGH confidence)

All 4 teammates independently confirmed: the single root cause of all 6 sorry sites is the non-deterministic `Classical.choice` in `set_lindenbaum`. The BX11 fold gives only a DISJUNCTIVE guarantee (`ψ ∈ M' ∨ F(ψ) ∈ M'`), and `Classical.choice` is opaque — it could systematically pick F-protection over direct resolution for any specific formula, indefinitely.

**The precise obstruction** (Teammate A): `enriched_fwd_step_preserves` gives `ψ ∈ M' ∨ F(ψ) ∈ M'`. Combined with `rr_fwd_chain_F_propagate` (proved), forward_F reduces to "F(ψ) cannot persist forever without ψ appearing." But perpetual deferral (always picking the right disjunct) is not a contradiction in the syntactic framework — it would require semantic truth-in-a-model arguments.

### Finding 2: ALL 6 Sorries Depend on forward_F — buc/fuc Are NOT Independent (HIGH confidence, 90%)

**Critical revision from Round 21**: The Round 21 synthesis claimed buc/fuc closeable independently at 85% confidence. Summary 21 (implementation attempt) and all 4 Round 22 teammates **contradict this**:

- **restricted_fuc** (line 1396): Reduces to forward_F via BX10 (`(φ U ψ) → F(ψ)`). The quasimodel `bx_until_eventuality_resolution` produces BXPoints, but there is NO bridge from BXPoints to integer chain indices.
- **restricted_buc** (line 1391): Requires step transfer (`(φ U ψ) ∈ chain(r+1), φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`), which UntilSinceCoherence.lean:27-28 explicitly states is NOT derivable from bare FMCS structure.

**Revised confidence for buc/fuc independent closure**: 40-55% (down from 85%).

### Finding 3: f_carry Seed Inconsistency Is Genuine (HIGH confidence)

**Confirmed dead end** (Teammate C with concrete counterexample): `{target} ∪ g_content(M) ∪ f_carry(M)` is provably inconsistent when `G(F(α) → ¬ψ) ∈ M`, `F(α) ∈ M`, `F(ψ) ∈ M`. This definitively closes the full f_carry seed approach documented in the "correct approach" comment at RootScopedChain.lean:1274-1288.

### Finding 4: The Restricted Sigma-List Seed May Be Consistent (MEDIUM confidence, 55-65%)

**Critical distinction** (Teammate A): While the FULL f_carry seed is inconsistent, the RESTRICTED seed using only sigma_list F-obligations may be consistent:

```
{ψ_j} ∪ {F(ψ_k) | k ≠ j, ψ_k ∈ sigma_list} ∪ g_content(M)
```

**Why**: The counterexample uses `F(α)` where α may NOT be in sigma_list. With the restricted seed containing only sigma_list elements, the counterexample's `G(F(α) → ¬ψ)` only applies if α ∈ sigma_list.

**The key new lemma** (Teammate A, Recommendation 5):
```lean
theorem extended_defect_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M)
    (defects : List Formula)
    (h_F : ∀ ψ ∈ defects, Formula.some_future ψ ∈ M) :
    defects.length > 0 →
    ∃ j : Fin defects.length,
      SetConsistent ({defects.get j} ∪
        (defects.toFinset.erase (defects.get j)).image Formula.some_future ∪
        g_content M)
```

This is an EXISTENCE theorem — it says some target j can be resolved while F-protecting all others in the defect list. The 2-defect case is already proved (`ordered_two_defect_seed_consistent`). The n-defect case requires a novel inductive argument handling BX11 3-cycles.

**The 3-cycle obstruction**: BX11's partial order has 3-cycles (confirmed counterexample from Report 16). No global BX11-minimum exists for 3+ defects. But Teammate A's running-compound iteration approach may avoid this: iterate BX11 maintaining a "current target" that switches when a new formula is found to be earlier, accumulating F-protected formulas. The final compound `F(target ∧ F-rest)` gives the consistent seed via `enriched_resolving_seed_consistent` + conjunction elimination.

### Finding 5: Fold-Order Trick — Partial Fix Only (35% confidence, unchanged)

All teammates agree: processing target LAST in the BX11 fold eliminates Case 3 (displacement) but NOT Case 2 (deferral). Case 2 gives `F(β ∧ F(target)) ∈ M` → `F(target) ∈ M'` only. No BX axiom prevents Case 2 from firing at every visit step.

**Still worth testing** (2 hours): Never actually implemented despite 21 research rounds. A concrete test would confirm the Case 2 gap empirically.

### Finding 6: BXCanonical Architecture Is Correct — Do Not Abandon (HIGH confidence, 90%)

Teammate D confirms: 6,400+ lines of sorry-free infrastructure, the Until/Since analogue fully solved, all documented alternatives correctly ruled out. The canonical model IS the scientific contribution. The only question is which chain construction to use, not whether to use a chain.

### Finding 7: Dead Code Cleanup Opportunity (Teammate D)

CanonicalModel.lean has 5 sorry sites (`bx_fmcs_forward_F`, `bx_fmcs_backward_P`, `bx_bfmcs_buc`, `bx_bfmcs_fuc`, `bx_bfmcs_restricted_buc/fuc`) that are DEAD CODE — not on the active completeness path. `Completeness.lean` calls `dd_countermodel` from `RootScopedChain.lean`, not `bx_countermodel`. Marking or deleting these would reduce apparent sorry count and clarify scope.

## Synthesis

### Conflicts Resolved

1. **buc/fuc independence (Round 21: 85% vs Round 22: 40-55%)**: Resolved in favor of Round 22/Summary 21. All teammates confirm these are NOT independent of forward_F. The quasimodel BXPoint-to-integer bridge does not exist.

2. **f_carry seed (Report 13 vs Teammate C)**: The FULL f_carry seed is inconsistent (Teammate C is correct). However, the RESTRICTED sigma_list seed (Teammate A) is a different mathematical object and may be consistent — this is the key new insight of Round 22.

3. **Plan v18 discharge_single_step F-preservation gap (Teammates B, C, D)**: `discharge_single_step` uses seed `{target} ∪ g_content(M)` which does NOT preserve F-obligations. Teammate A's `extended_defect_seed_consistent` addresses this by proving (existentially) that a richer seed is consistent. If this lemma holds, discharge_single_step is replaced by a seed that simultaneously resolves target AND F-protects others.

### Gaps Identified

1. **The n-defect consistency proof**: The 2-defect case is proved. The n-defect generalization via BX11 iteration with running-compound target switching needs formal verification. The 3-cycle obstruction is real but may be avoidable with the running-compound approach.

2. **The never-resolved count well-foundedness**: Teammate D claims F-obligation constancy makes this straightforward (F-obligations are stable from step 0). But Teammate C notes formulas can leave and re-enter the "unresolved" category. The resolution depends on whether "never-resolved" means "never appeared in ANY chain step" (monotone) vs "not currently present" (non-monotone).

3. **downstream re-proof cost**: All teammates estimate 25-40 hours total. ~30 theorems depend on `enriched_fwd_step` and need mechanical re-proofs.

### Recommendations

**Recommended execution order**:

1. **Gate check: fold-order trick (2 hours, 35%)**
   - Modify `enriched_fwd_step` to process target last
   - If Case 2 is ruled out empirically: forward_F closes immediately
   - If Case 2 fires: confirms the obstruction with precise failure data

2. **Core lemma: prove `extended_defect_seed_consistent` (10-15 hours, 55-65%)**
   - Start with the 2-defect case (already proved)
   - Extend to n-defect via running-compound BX11 iteration
   - This is the KEY mathematical contribution — if it holds, all 6 sorries close
   - If it fails with a counterexample: we learn the exact mathematical obstruction

3. **Chain replacement: target-resolving chain (15-25 hours, conditional on step 2)**
   - Replace `enriched_fwd_step` with `target_resolving_fwd_step` using the consistent seed from step 2
   - Prove forward_F via well-founded induction on never-resolved count
   - Re-prove ~30 downstream theorems

4. **buc/fuc closure (5-10 hours, conditional on step 3)**
   - Once forward_F is proved, fuc follows via BX10 reduction
   - buc requires enriched seed with Until formulas — additional consistency argument

5. **Dead code cleanup (1 hour, independent)**
   - Mark CanonicalModel.lean sorry sites as dead code

**Total estimated effort**: 33-53 hours (gate check through completion).

**Critical path**: Step 2 (`extended_defect_seed_consistent`) is the mathematical crux. If this lemma holds, the remaining work is mechanical. If it fails, a fundamentally different approach is needed (likely the semantic/quasimodel bridge).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary Approach | completed | high | `extended_defect_seed_consistent` lemma formulation; running-compound iteration |
| B | Alternatives | completed | medium | Fold-order trick precise analysis; buc/fuc guard condition complexity |
| C | Critic | completed | high | f_carry inconsistency proof; false assumption pattern identification |
| D | Horizons | completed | high | Architecture validation; never-resolved count analysis; dead code identification |

## References

- RootScopedChain.lean (sorry sites: lines 1295, 1326, 1333, 1386, 1391, 1396)
- OrderedSeedConsistency.lean (`ordered_two_defect_seed_consistent`, `enriched_resolving_seed_consistent`)
- UntilSinceCoherence.lean:27-28 (step transfer non-derivability)
- Report 16 (BX11 3-cycle counterexample)
- Report 17 (19 failed approaches history)
- Summary 21 (latest implementation failure analysis)
