# Research Report: Task #67 — Pattern Analysis from 11 Plans

**Task**: prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Teammate**: B (meta-level pattern analysis)
**Session**: team research (plan v11 blocker resolution)

---

## Key Findings

### Finding 1: Single Root Cause Persists Across All 11 Plans

Every plan has been blocked by exactly one core problem: **the fuel=0 base case in bounded witness lemmas cannot be discharged without a chain stabilization argument**. The problem has been re-encountered in different guises, but the root cause is the same:

- The recursion explores (F-nesting depth) × (chain positions), bounded by B² total steps.
- When fuel is exhausted or position k reaches the bound B, the code must claim no more work is needed.
- No local syntactic measure has succeeded because the termination argument is semantic: the chain stabilizes after B steps, so any unresolved F-boundary at position k implies k < B.

**Evidence**: Plans 3, 6, 9, 10, 11 all attempted different syntactic measures (depth alone, lexicographic `(B²-k, d)`, fuel invariant `fuel > (B-k)*B`). All fail because `k >= B` can occur syntactically and requires a semantic discharge.

---

### Finding 2: Architecture Has Converged — It Is Correct

Plans 1–7 evolved the proof architecture through many changes (bypassing Z-chain, extending deferralClosure, wiring restricted chain). By Plan 9, the architecture is essentially settled and correct:

1. `not_provable_implies_neg_consistent` (sorry-free)
2. `deferral_restricted_lindenbaum` (sorry-free)
3. `DeferralRestrictedSerialMCS` with F_top/P_top (sorry-free after Plan 5 extended deferralClosure)
4. `build_restricted_tc_family` → `RestrictedTemporallyCoherentFamily` (BLOCKED at fuel sorries)
5. `restricted_truth_lemma` → `bundle_validity_implies_provability`

Steps 1–3 and 5 are sorry-free. Only step 4 (and specifically the four bounded witness lemmas) is blocked.

**The proof architecture is not the problem. The problem is entirely localized to termination discharge in four lemmas.**

---

### Finding 3: The k >= B Case Is the Sole Unresolved Subproblem

Plan 11 (fuel invariant `remaining_steps >= (B-k)*B + 1`) successfully eliminated the original fuel=0 sorries and reduced the problem to exactly two `sorry` sites at lines 3006 and 3037. Both are in the `k >= B` branch of the same case split.

The pattern at both sites:
```
h_inv : remaining_steps >= (B - k) * B + 1
hk    : k >= B
-- Thus: (B - k) = 0, so h_inv degenerates to: remaining_steps >= 1
-- Need: remaining_steps >= 1 (i.e., remaining' >= 0) after one more step
-- Actually need: remaining' >= 1 to satisfy the invariant for the recursive call
-- Have: remaining_steps = remaining' + 1, so remaining' = remaining_steps - 1
-- From h_inv (degenerate): remaining_steps >= 1, so remaining' >= 0
-- CANNOT conclude remaining' >= 1 without knowing remaining_steps >= 2
```

The discharge strategy: `k >= B` is semantically impossible when `h_iter_not` holds (the boundary condition). If the chain stabilizes at position B, then `iter_F (d+1) theta` is either always in or always out of `restricted_forward_chain phi M0 k` for all `k >= B`. The existence of a boundary (in at k but not at k+1) requires k < B.

**This is the one lemma needed: "chain_stabilizes_at_B" or "boundary_implies_lt_B".**

---

### Finding 4: Three Past Approaches to This Sub-Problem Have All Identified the Stabilization Argument

Examining plans 11, 12_well-founded-summary, and report 31 together reveals that all three independently identified stabilization as the resolution:

1. **Summary 11** (fuel-invariant-partial): "Prove chain stabilization lemma for `k >= B` case. This is a semantic property of `restricted_forward_chain` that should be provable from the chain construction."

2. **Report 31** (team synthesis): Teammate B identified that `d < B` is always provable from DRM bounds, and this is what gives the contradiction in the `fuel=0` case.

3. **Plan 10** (well-founded analysis): Documented that the termination argument is "semantic (fuel always suffices globally)" and converting it requires "tracking global invariant: remaining_work ≤ remaining_fuel" — the stabilization argument is exactly this.

**Implication**: Three independent analyses agree on what is needed. No analysis has found a reason why stabilization is unprovable. The lemma has simply not been proven yet.

---

### Finding 5: Anti-Pattern — Repeated Architecture Pivots Have Delayed Stabilization Proof

A recurring anti-pattern across all 11 plans:

1. Approach hits a blocker
2. Team pivots to new architecture (new plan)
3. New architecture reaches the same underlying blocker in a different form
4. Pivot again

Plans 1–7 are architecture pivots. Plans 8–11 are termination-fix attempts that all identify the stabilization gap but defer it in favor of yet another structural approach.

**The consistent near-miss**: Every plan from 3 onwards has the restricted completeness path "almost done." Plans 9 and 11 completed the most concrete progress (backward chain proofs in plan 9, fuel=0 elimination in plan 11), but neither completed the stabilization sub-lemma.

---

### Finding 6: Dovetailing (Plan 8) Was a Separate Dead End

Plan 8 (dovetailed omega FMCS) explored a fundamentally different proof strategy: instead of fixing the fuel/termination issue in the restricted chain, construct a new chain where F-persistence holds by construction. This was blocked by an independent issue (F-formulas can be lost during Lindenbaum extension, not just during chain progression). This approach is entirely separate from the current blocker and should not be conflated with it.

---

## Evidence Summary

| Plan | Key Contribution | Blocking Point |
|------|-----------------|----------------|
| 1–2 | Architecture: restricted completeness path | Fuel/coherence sorries unaddressed |
| 3 | Phases 1-3 completed (termination, G/H props, restricted BFMCS bridge) | Phase 4 blocked at truth lemma |
| 4 | Identified F_top ∉ deferralClosure blocker | Phase 1 blocked |
| 5 | Extended deferralClosure to include F_top/P_top (16 call sites fixed!) | Phase 6 partial, fuel sorries |
| 6 | Identified well-founded measure approach | Phase 2 blocked: depth increases on resolve |
| 7 | Transfer-back via Lindenbaum extension approach | Not fully implemented (backward chain missing) |
| 8 | Dovetailing (independent approach) | Phase 3 blocked: F-persistence not preserved |
| 9 | **Proven**: backward chain sorries at lines 3944, 4001 | Phase 3 blocked: fuel-exhaustion |
| 10 | Documented depth-increase problem precisely | Phase 2 blocked: same fundamental issue |
| 11 | **Proven**: fuel=0 sorries → 2 new sorries at k>=B | Stabilization lemma needed |

---

## Strategic Recommendations

### Primary Recommendation: Prove the Chain Stabilization Lemma

The **only** thing blocking Task 67 completion is a single lemma:

```lean
theorem restricted_forward_chain_stabilizes_at_B (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_k_ge : k >= closure_F_bound phi)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k) :
    iter_F d theta ∈ restricted_forward_chain phi M0 (k + 1)
```

Or equivalently, the boundary condition implies k < B:

```lean
theorem boundary_implies_position_lt_bound (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_iter_in  : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    k < closure_F_bound phi
```

**Why this is likely provable**: The restricted forward chain is defined using `deferralClosure phi` as the constraint set. After B steps, any formula that could appear in `deferralClosure phi` has been fully processed (by the finiteness of `deferralClosure` and the DRM's treatment of F-nesting). The F-nesting depth is bounded by `closure_F_bound phi = B` by the `iter_F_not_mem_closureWithNeg` theorem. If `iter_F (d+1) theta ∉ chain(k)` while `iter_F d theta ∈ chain(k)`, there is an active F-obligation that has not yet been resolved, which requires that fewer than B resolution steps have occurred.

**Key theorem to leverage**: `iter_F_not_mem_closureWithNeg` (RestrictedMCS.lean or similar) which proves F-nesting is bounded within `deferralClosure`. This is the exact property that would give `k < B` as a consequence of the boundary condition.

### Secondary Recommendation: Apply Same Fix to All Four Fueled Lemmas

Once the stabilization lemma is proven for the forward case, the three remaining fueled lemmas (`restricted_backward_bounded_witness_fueled`, `restricted_combined_bounded_witness_fueled`, `restricted_combined_bounded_witness_P_fueled`) can be fixed by applying the same pattern with appropriate analogues (P-direction, Int-indexed variants).

### Anti-Recommendation: Do Not Pivot to New Architecture

Given that the architecture is settled and the remaining blocker is a single lemma, creating a 12th plan with a new proof strategy would be counter-productive. The k>=B sorry sites are concrete, locatable, and their mathematical content is well-understood.

---

## Confidence Level

**High** for the pattern analysis and identification of the stabilization lemma as the sole remaining blocker.

**Medium** for the claim that the stabilization lemma is readily provable. The mathematical argument is clear, but the Lean formalization may require inspecting the exact definition of `restricted_forward_chain` and the chain step function to ensure the bound `B = closure_F_bound phi` is the right quantity.

---

## Files Analyzed

- Plans 01–11: `specs/067_prove_bundle_validity_implies_provability/plans/`
- Summary 11: `specs/067_prove_bundle_validity_implies_provability/summaries/11_fuel-invariant-partial.md`
- Summary 12: `specs/067_prove_bundle_validity_implies_provability/summaries/12_well-founded-summary.md`
- Report 31: `specs/067_prove_bundle_validity_implies_provability/reports/31_team-research.md`
- Current sorry sites: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` lines 3006, 3037, 5610, 5768, 5964
