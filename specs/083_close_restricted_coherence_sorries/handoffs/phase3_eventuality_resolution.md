# Handoff: Phase 3 Eventuality Resolution

## Current State

TruthLemma.lean is structurally complete with no direct sorries. The proof structure for `until_iff_mcs` and `since_iff_mcs` is:

### Forward Direction (phi U psi in w -> exists witness)
- Case psi in w: reflexive witness (DONE, no sorry)
- Case psi not in w: delegates to `bx_until_eventuality_resolution` in Frame.lean

### Backward Direction (exists witness -> phi U psi in w)
- Case psi in w: BX8 psi_imp_until (DONE, no sorry)
- Case psi not in w: delegates to `bx_until_backward` in Frame.lean

### Since: Mirror of Until using Since axioms (BX8'/BX9'/BX10')

## 5 Remaining Sorries (all in Frame.lean)

1. `until_zorn_chain_seed_consistent` (line 526) - Zorn chain upper bound consistency
2. `bx_until_eventuality_resolution` (line 541) - Forward Until with guard
3. `bx_until_backward` (line 556) - Backward Until
4. `bx_since_eventuality_resolution` (line 567) - Forward Since with guard
5. `bx_since_backward` (line 578) - Backward Since

## Mathematical Analysis

### The Guard Verification Problem

The core difficulty: given phi U psi in w and psi not in w, find v >= w with psi in v such that for all u with w <= u < v, phi in u.

**What works**:
- BX10 gives F(psi) in w
- bx_forward_witness gives SOME v >= w with psi in v
- BX9 gives phi v psi in w, and since psi not in w, phi in w

**What fails**:
- The v from bx_forward_witness may not satisfy the guard
- g_content(w) subset u only gives G-formulas at u, not phi directly
- BX4 (connectedness) gives P(phi U psi) at intermediate points, but P(alpha) in u only means alpha at some u' <= u, not at u itself
- BX5 (self-accumulation) enriches the guard syntactically but doesn't help verify the semantic guard at intermediate MCS

### Attempted Approaches

1. **Direct seed construction**: Build v from {psi} union g_content(w). Guard fails because g_content(w) doesn't contain enough info about phi at intermediate points.

2. **Enriched seed with H(phi)**: Adding H(phi) to the seed would make the guard trivial (H(phi) in v means phi at all past points). But cannot show {psi, H(phi)} union g_content(w) is consistent without circular reasoning.

3. **Contradiction for backward**: Assume not(phi U psi) in w. By BX4: G(P(not(phi U psi))) in w. At v: P(not(phi U psi)) in v. By bx_backward_witness: exists u <= v with not(phi U psi) in u and not(psi) in u. But F(psi) in u (from BX4' on psi in v). This gives not(phi U psi), not(psi), and F(psi) at u - no contradiction arises.

4. **Zorn maximal element**: Define S = {M : MCS | g_content(w) subset M, phi U psi in M, psi not in M}. Find maximal m in S. Get v from bx_forward_witness at m. Guard for [w,v): points between w and m are in S (have phi U psi, not psi, so by BX9: phi). Points between m and v: by maximality of m, not in S, so either psi in u OR phi U psi not in u.

### Recommended Approach: Zorn with BX7 Linearity

The most promising approach uses Zorn + BX7 to show the canonical ordering is "locally linear" on the interval [w, v]:

1. Build maximal m in S as above
2. At m: F(psi) in m, get v >= m with psi in v
3. For u with w <= u < v:
   - If u <= m (provable via Zorn chain structure): u in S, so phi U psi in u, psi not in u, hence phi in u by BX9
   - If m < u < v: Need BX7 linearity to show u is comparable with m. Use BX7 instantiated with (phi U psi) at w and a suitable formula to establish comparability.

The BX7 argument for comparability is the key missing piece. BX7 says two Until witnesses are linearly ordered. If we can express the "being in the chain" as a property related to Until witnesses, BX7 would ensure all relevant points are comparable with m.

### Alternative: Change the Guard Condition

If the Zorn + BX7 approach stalls, consider modifying the guard in until_iff_mcs to:
- Use phi U psi in u instead of phi in u (weaker but easier to verify)
- Then derive phi in u when psi not in u via BX9

This would change the theorem statement but might be sufficient for the completeness theorem.

## New Infrastructure Added

### TruthLemma.lean (sorry-free)
- `F_from_witness`: If bx_le w v and psi in v, then F(psi) in w
- `P_from_witness`: Mirror for past direction
- Both until_iff_mcs and since_iff_mcs fully structured

### Frame.lean (5 sorry helpers)
- `until_zorn_chain_seed_consistent`: Chain upper bound for Zorn
- `bx_until_eventuality_resolution`: Forward Until with guard
- `bx_until_backward`: Backward Until
- `bx_since_eventuality_resolution`: Forward Since with guard
- `bx_since_backward`: Backward Since

## Build Status

`lake build` passes with 0 errors. All BXCanonical modules compile.
TruthLemma.lean has 0 direct sorries (all delegated to Frame.lean helpers).
