# Handoff: Forward_F Analysis and Obstruction

## Session
- **Session ID**: sess_1776201199_67640c (continued)
- **Task**: 93 - Complete BXCanonical embedding
- **Agent**: lean-implementation-agent
- **Date**: 2026-04-14

## Completed Work

### Theorems Added (sorry-free, build-passing)

1. **`bx11_earlier_resolving_seed_strong`** (~line 938)
   - Extends `bx11_earlier_resolving_seed` with F-extraction: `F(alpha) in M' -> F(chi) in M'`
   - Case 1 (alpha = chi): trivial. Case 2 (alpha = F(chi)): uses FF_imp_F.

2. **`target_stays_direct_in_fold`** (~line 1008)
   - KEY THEOREM: when target is bx11_earlier than all others, target in M' is guaranteed.
   - Uses compound fold: forms `[target.and alpha_1, ...]` via bx11_earlier_resolving_seed_strong.
   - Folds compounds via resolving_enriched_fwd_exists.
   - Direct witness w is always target or (target.and alpha_j) -> target in M' by lce_imp.
   - F-extraction for others via bx11_earlier_resolving_seed_strong.

### Build Status
- `lake build` passes, 0 errors, 6 sorry sites (unchanged from baseline), 4 axioms (unchanged).

## Analysis: Why rr_fwd_chain_forward_F is Harder Than Expected

### The Core Problem
`rr_fwd_chain_forward_F` asks: F(psi) in chain(n) -> exists s > n, psi in chain(s).
The chain uses `enriched_fwd_step` which gives `psi in M' OR F(psi) in M'` (disjunctive).
We need to show the left disjunct eventually holds.

### Why target_stays_direct_in_fold Doesn't Directly Help
`target_stays_direct_in_fold` requires `bx11_earlier M psi chi` for ALL other defects chi.
This is NOT guaranteed -- some chi might have `bx11_earlier M chi psi` exclusively.

### Why Finding a BX11-Earliest Element is Hard
- `bx11_earlier` is a total binary relation (bx11_earlier_total) but NOT transitive.
- Transitivity would require: F(A and F(B)), F(B and F(C)) -> F(A and F(C)), which is not provable from BX axioms alone.
- Without transitivity, a "minimum" element (one that is bx11_earlier than all others) may not exist.
- A 3-cycle is possible: bx11_earlier M a b, bx11_earlier M b c, bx11_earlier M c a (with NOT bx11_earlier for the reverse).

### Why the Counting Argument Fails
- F-obligation set D(n) = {chi | F(chi) in chain(n)} is CONSTANT across steps.
- Reason: phi in M -> F(phi) in M for any MCS M (by contrapositive of temp_t: G(neg phi) -> neg phi).
- So resolving a defect (chi in M') does not remove chi from D: chi in M' implies F(chi) in M'.
- The defect count never decreases.

### Key Insight About temp_linearity_mcs Implementation
`temp_linearity_mcs` is DETERMINISTIC: checks Case 1 first, then Case 2, then Case 3.
- Case 3 ONLY fires when F(psi and chi) NOT IN M AND F(psi and F(chi)) NOT IN M.
- `bx11_earlier M psi chi` means Case 1 or Case 2 IS in M.
- So `bx11_earlier M psi chi` implies Case 3 does NOT fire for psi vs chi.
- But this only controls the FIRST fold step (when beta = psi). Subsequent steps have compound beta.

### Why Contradiction Arguments Fail
Assuming psi never appears: psi.neg in chain(m) for all m >= n, F(psi) in chain(m) for all m >= n.
- G(psi.neg) NOT in chain(m) (contradicts F(psi)).
- Both F(psi) and F(psi.neg) can coexist in MCS (neither is G-stable).
- No contradiction derivable from MCS properties alone.

## Proposed Approaches for Next Session

### Approach A: Chain Replacement (Most Promising, High Effort)
Replace `rr_fwd_chain` with a chain that GUARANTEES the target is resolved:
- Define `ordered_fwd_step` that selects a specific defect and uses `target_stays_direct_in_fold`.
- The selection doesn't need a "minimum" -- just pick ANY defect where bx11_earlier holds for psi.
- Actually, use `discharge_single_step` for psi-specific resolution (psi in M' guaranteed, g_content preserved, but F-carry lost).
- Build a separate chain per formula, or find a way to resolve ALL defects simultaneously.
- Re-prove g_content propagation, box stability, backward chain properties, dd_chain properties, dd_fmcs, dd_bfmcs, restricted coherence.
- Estimated: 200+ lines of re-proven infrastructure.

### Approach B: Semantic/Model-Theoretic Argument (Lower Effort, Uncertain)
Use the structure of the temporal logic to derive a contradiction from "F(psi) persists forever":
- F(psi) = "psi holds at some future time". If we're building a chain over Int, and F(psi) is never witnessed, the resulting model is not a valid temporal model.
- The restricted truth lemma requires forward_F for the correctness of the countermodel. So forward_F IS needed for the model to work, but the argument might be circular.

### Approach C: Weaker Forward_F via Until Coherence (Novel)
Instead of proving forward_F for ALL formulas in deferralClosure, prove it only for specific forms:
- F(psi) where psi appears in a conjunction F(psi and alpha) in M.
- This restricted form might be easier and might suffice for the restricted_temporally_coherent property.

### Approach D: BX11 Transitivity (Mathematical Research Needed)
Prove that bx11_earlier IS transitive (or a weaker property that suffices for minimum-finding).
This would make the original plan approach work: find the bx11-earliest defect and use target_stays_direct_in_fold.

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean`
  - Added `bx11_earlier_resolving_seed_strong` after line 937
  - Added `target_stays_direct_in_fold` after `discharge_multi_step`
  - No existing code modified

## Recommendation
Approach A (chain replacement) is the most reliable but requires significant effort.
Approach D (proving transitivity) would be the cleanest but requires mathematical insight.
Consider consulting Burgess 1984 / Goldblatt 1992 for the original proof strategy.
