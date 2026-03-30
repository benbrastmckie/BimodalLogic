# Research Report: Task #67 — Chain Stabilization Lemma Analysis

**Task**: prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Teammate**: A (chain stabilization focus)
**Session**: lean-research-agent investigation

---

## Key Findings

### Finding 1: The `k >= B` Case Is Semantically Reachable — Stabilization Lemma Is False As Stated

The proposed lemma `boundary_implies_position_lt_bound`:

```lean
theorem boundary_implies_position_lt_bound (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_iter_in  : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    k < closure_F_bound phi
```

is **NOT directly provable** from the current chain construction. The `restricted_forward_chain` is built via iterated `constrained_successor_restricted`, which uses Lindenbaum extension (Zorn's lemma). This extension can, in principle, include `iter_F d theta` at chain position k for arbitrarily large k.

**Evidence**: The Lindenbaum extension in `deferral_restricted_lindenbaum` is noncomputable and non-unique. No property of the construction prevents `iter_F d theta ∈ chain(k)` for k >> B.

---

### Finding 2: The `boundary_resolution_set` Provides Partial But Not Full Stabilization

The `boundary_resolution_set` in `constrained_successor_seed_restricted` forces resolution at the deepest F-nesting level:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u}
```

**Proven**: When `iter_F (B-1) theta ∈ chain(k)` (depth = B-1 = `closure_F_bound phi - 1`), then since `iter_F B theta ∉ deferralClosure phi` (by `iter_F_not_mem_closureWithNeg`), the `boundary_resolution_set` forces `iter_F (B-2) theta ∈ chain(k+1)`. This means depth B-1 FORCES a resolve at the next step.

**Not Proven**: For depths d < B-1, deferral IS possible indefinitely. The `boundary_resolution_set` does NOT prevent `iter_F d theta ∈ chain(k)` for all k when d < B-1.

**Consequence**: After forced resolution at depth B-1, the new boundary depth at chain(k+1) is determined by `F_bounded` applied to `iter_F (B-3) theta`. This gives depth d' + (B-3) where d' < 3. If d' = 2: new depth = B-1 again (forced resolve at k+2), but `iter_F (B-1) theta ∈ chain(k+1)` is possible (not excluded by the construction). The depth can oscillate at B-1.

---

### Finding 3: The Existing `restricted_forward_chain_depth_bounded` Lemma Is Correct But Insufficient

The lemma at line 2811:

```lean
private theorem restricted_forward_chain_depth_bounded (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    d < closure_F_bound phi
```

This correctly proves `d < B` (the DEPTH is bounded), but gives no bound on `k` (the POSITION). The sorry at line 3006 needs `k < B`, not `d < B`.

---

### Finding 4: The Fuel Invariant Gap Cannot Be Closed With Simple Bounds

The sorry at lines 3006 and 3037 need `remaining' >= 1` given only:
- `h_inv : remaining_steps >= (B - k) * B + 1` (degenerates to `remaining_steps >= 1` when k >= B)
- `remaining_steps = remaining' + 1`

This requires `remaining_steps >= 2`. The current initial fuel `B*(B+1)+1` does NOT guarantee this because the k >= B regime can last for MULTIPLE recursive steps (each decrementing fuel), potentially draining fuel to exactly 1.

**Verified**: The k >= B regime can last indefinitely (k can grow unboundedly) because:
1. Case 2 (defer) at depth d < B-1 is possible (Lindenbaum extension may choose F(theta) over theta)
2. Each defer step increments k and may reset depth to anything in [n+1, B-1]
3. No finite number of additional defer steps is guaranteed before Case 1

---

### Finding 5: The Correct Fix Requires Either Construction-Level Changes or a Different Termination Argument

Two viable paths exist:

**Path A: Strengthen the chain construction to guarantee eventual resolution**

The `constrained_successor_restricted` must be modified to guarantee that any F-formula with d <= B-1 is eventually resolved. One approach: use a "schedule-aware" Lindenbaum extension that picks the resolving disjunct (`psi` rather than `F(psi)`) whenever the formula has been deferred `B` times. This mirrors the "bulldozing" construction in classical completeness proofs.

However, Plan 8 showed that bulldozing fails because F-formulas can be LOST during Lindenbaum extension when the witness construction adds contradictory formulas.

**Path B: Prove the bounded witness using a stronger induction principle that doesn't require fuel**

The correct measure is NOT the current depth `d` (which can increase) but rather a LEXICOGRAPHIC measure on:
- Outer: `f_nesting_depth(iter_F d theta)` = `d + f_nesting_depth(theta)` — strictly decreases on resolve (Case 1 peels one F, outer decreases by at least 1 - d')
- Inner: `B - d` — bounded by B

But "outer decreases on resolve" needs verification:
- Case 1: d_new = d' + (n-1) where n = d-1. `d_new = d' + d - 2`. Outer_new = d' + d - 2 + f_depth(theta). Outer_old = d + f_depth(theta). Need: d' + d - 2 < d, i.e., d' < 2. So d' = 1. But d' can be B-1!

So this also FAILS when d' > 1 in the resolve case.

---

### Finding 6: The True Termination Argument Requires A Separate Key Lemma

The only way to make this work is to prove a CONSTRUCTION LEMMA:

```lean
-- The chain resolves all F-obligations in at most B steps:
lemma restricted_forward_chain_F_resolves_in_B (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    ∃ m, k < m ∧ m <= k + closure_F_bound phi ∧ psi ∈ restricted_forward_chain phi M0 m
```

If this lemma holds, then the bounded witness terminates in at most `B * B` steps (B levels of F-nesting, each resolved in at most B steps).

However, proving this lemma requires showing that the chain EVENTUALLY resolves F-formulas — which is exactly the property the construction currently lacks (as noted in Finding 1).

---

## Evidence Summary

| Claim | Status | Evidence |
|-------|--------|----------|
| `d < B` given boundary condition | PROVABLE (exists as `restricted_forward_chain_depth_bounded`) | Line 2811 |
| `k < B` given boundary condition | LIKELY FALSE | Lindenbaum extension can include F-formulas at any position |
| `boundary_resolution_set` forces depth B-1 to resolve | TRUE | `iter_F B theta ∉ deferralClosure phi` (omega from `closure_F_bound` def) |
| Chain can have depth B-1 at ANY position k | TRUE | Lindenbaum can include `iter_F (B-1) theta` in any chain(k) |
| Fuel invariant `remaining_steps >= (B-k)*B + 1` preserved when k >= B | FALSE | Requires `remaining' >= 1` but only have `remaining' >= 0` |

---

## Recommended Approach

The sorry at lines 3006 and 3037 cannot be discharged by a simple stabilization lemma. The root cause is that the `restricted_forward_chain` construction does NOT guarantee eventual resolution of all F-obligations.

**Option 1 (Preferred)**: Strengthen the chain construction's Lindenbaum step to use a PRIORITY scheme that ensures F-formulas at depth d are resolved within B steps. This avoids indefinite deferral at sub-maximal depths.

**Option 2**: Accept that `restricted_bounded_witness_wf` cannot be proved with fuel alone, and restructure using a DIFFERENT TERMINATION ARGUMENT that directly uses the chain construction properties at each step.

**Option 3 (Structural)**: Add `k < B` as a HYPOTHESIS to `restricted_bounded_witness_wf` and prove at the CALL SITES that k < B. For the initial external call, this requires proving the boundary condition implies k < B (which requires Option 1 or a different construction).

**Option 4 (Alternative Construction)**: Use the Z-chain approach with the full MCS (not restricted) and prove bounded witness there using classical LTL arguments, then transfer back to the restricted chain via the extension lemmas.

---

## Confidence Level

**High** for Findings 1-5 (analysis of why current approach fails).
**Medium** for the recommended approach (Option 1 requires construction changes; risk of Plan 8-style blockers).
**Low** for any quick fix at the current sorry locations without construction changes.

---

## Files Analyzed

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — lines 2811, 2890-3040, 2600-2620
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — lines 270-352 (boundary_resolution_set)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` — lines 663-692 (DeferralRestrictedMCS def)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — lines 145-188 (closure_F_bound)
- Plan v11: `specs/067_prove_bundle_validity_implies_provability/plans/11_fuel-invariant.md`
- Summary v11: `specs/067_prove_bundle_validity_implies_provability/summaries/11_fuel-invariant-partial.md`
