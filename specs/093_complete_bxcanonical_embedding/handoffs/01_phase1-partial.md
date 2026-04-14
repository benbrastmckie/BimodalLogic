# Handoff: Phase 1 Partial Progress

## Session
- **Session ID**: sess_1776201199_67640c
- **Task**: 93 - Complete BXCanonical embedding
- **Agent**: lean-implementation-agent
- **Date**: 2026-04-14

## Completed Work

### New Theorems (sorry-free, build-passing)

1. **`bx11_earlier_resolving_seed_strong`** (line ~938-952 in RootScopedChain.lean)
   - Strengthens `bx11_earlier_resolving_seed` with F-extraction property
   - In Case 1 (alpha = chi): F(alpha) = F(chi), trivial
   - In Case 2 (alpha = F(chi)): F(alpha) = F(F(chi)), use FF_imp_F
   - Signature: gives `(F(alpha) in M' -> F(chi) in M')` in addition to `(alpha in M' -> chi in M' or F(chi) in M')`

2. **`target_stays_direct_in_fold`** (line ~1008-1077 in RootScopedChain.lean)
   - KEY THEOREM: When target is bx11_earlier than every formula in others, there exists M' with target in M' (deterministic, not disjunctive)
   - Uses compound fold approach: forms [target.and alpha_1, target.and alpha_2, ...] using bx11_earlier_resolving_seed_strong
   - Folds compounds via resolving_enriched_fwd_exists
   - Direct witness w is always target or (target.and alpha_j), giving target in M' by left conjunction elimination
   - F-extraction for others via bx11_earlier_resolving_seed_strong

### Build Status
- `lake build` passes with 0 errors
- 6 sorry sites remain (same as before, unchanged)
- No new axioms introduced

## Remaining Blocker: rr_fwd_chain_forward_F

### Analysis of the Obstruction

The core challenge is proving `rr_fwd_chain_forward_F`: F(psi) in chain(n) implies psi in chain(s) for some s > n.

`target_stays_direct_in_fold` solves the "Case 3 hijacking" problem: when the target is bx11-earliest among all defects, the fold guarantees the target is directly resolved. However, using this to close `rr_fwd_chain_forward_F` requires additional work:

1. **F-obligation set is constant**: phi in M implies F(phi) in M (by contrapositive of temp_t). So the F-obligation set D(n) = {chi | F(chi) in chain(n)} never decreases. Defects CAN reappear after resolution.

2. **Defect counting fails**: Resolving a defect (target in M') does not permanently remove it from the defect set. At the next step, target might become a defect again.

3. **BX11 ordering changes**: The bx11_earlier ordering depends on the current MCS. After resolving one defect, the ordering among remaining defects may change.

### Proposed Approaches (Not Yet Implemented)

**Approach A: Ordered chain replacement**
- Define `ordered_fwd_chain` that at each step uses `target_stays_direct_in_fold` with the bx11-earliest defect
- Prove forward_F for this chain by showing psi eventually becomes the earliest defect
- Replace `rr_fwd_chain` with `ordered_fwd_chain` in `dd_chain`
- Risk: showing psi eventually becomes earliest is non-trivial

**Approach B: Finite exhaustion**
- Show that after at most |sigma_list|^2 steps, every formula must have been directly resolved at least once
- By pigeonhole on the finite set of defects and the total ordering
- The resolution gives psi in chain(m+1) at that step

**Approach C: Well-founded induction on ordering position**
- Use well-founded induction on the number of formulas bx11_earlier than psi
- At each step, either psi is resolved (done) or some formula earlier than psi is resolved
- The ordering might change but the well-foundedness argument needs care

**Approach D: Direct semantic argument**
- Use `enriched_fwd_step_preserves` (psi in M' or F(psi) in M') at every step
- At psi's scheduled visit step (round-robin), psi IS the target
- Show that at psi's visit step, the fold gives psi in M' (not just disjunctive)
- This requires showing psi is bx11_earlier than all other defects at that step
- Not guaranteed for the existing round-robin chain

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (new theorems added, no existing code modified)

## Recommendations for Next Session
1. Investigate Approach B (finite exhaustion) as the most promising
2. Consider reading Goldblatt 1992 Section 7.4 or Burgess 1984 for the original proof strategy
3. The compound fold approach in target_stays_direct_in_fold is the correct foundation; the challenge is the chain-level argument
