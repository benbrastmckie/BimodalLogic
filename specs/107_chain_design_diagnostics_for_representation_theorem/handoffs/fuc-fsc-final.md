# Handoff: FUC/FSC Forward Until/Since Coherence (Task 107)

Session: sess_1778014444_dca927
Date: 2026-05-06
Status: BLOCKED — deep architectural issue identified

## Current State

Build passes with 2 sorries in `ChronicleToCountermodel.lean`:
- Line 634: Forward Until Coherence (FUC)
- Line 638: Forward Since Coherence (FSC)

All other Chronicle files are sorry-free. The completeness theorem compiles modulo these 2 sorries.

## Proof Obligation

FUC goal (at line 634):
```
⊢ ∃ s_1, t < s_1 ∧ ψ ∈ (rooted_cantor_fmcs N h_N h_nubr3 s).mcs s_1 ∧
    ∀ (r : ℚ), t < r → r < s_1 → φ ∈ (rooted_cantor_fmcs N h_N h_nubr3 s).mcs r
```

Given: `φ.untl ψ ∈ (rooted_cantor_fmcs N h_N h_nubr3 s).mcs t`

Need: endpoint s1 > t with ψ at s1, AND guard φ at ALL rationals r between t and s1.

FSC is the temporal mirror (Since direction).

## Root Cause Analysis

### What Burgess 2.11 Requires

Burgess's truth lemma (2.11) for U(β,γ):
> "If α ∈ f(x), then by C5a there is y with x < y and γ ∈ f(y) and **β ∈ g(x,y)**. If z and x < z < y, then by C3 **g(x,y) ⊆ f(z)**, whence β ∈ f(z)."

Two ingredients:
1. **C5 with g-value**: The C5 witness y comes with β ∈ g(x,y) (not just γ ∈ f(y))
2. **C3**: g(x,y) ⊆ f(z) for intermediate z (gives β at all intermediate points)

### What Our Code Has

- `limit_satisfies_c5_weak`: provides ONLY γ ∈ f(y). Does NOT provide β ∈ g(x,y).
- `limit_g` is defined as `{φ | ∀ w ∈ limit_dom, x < w → w < y → φ ∈ limit_f(w)}`, which automatically satisfies C3 by definition. But proving β ∈ limit_g(x,y) IS EQUIVALENT to proving the guard (circular).
- `limit_satisfies_c4`: backward direction works (proved for BUC).

### Why the Guard Can't Be Proved at the Limit Level

Attempted approaches that DON'T work:

1. **BX5 self-accumulation**: `U(φ,ψ) → U(φ∧U(φ,ψ), ψ)`. Enriches the guard but C5_weak still doesn't export guard values.

2. **Contradiction via C4**: Given U(φ,ψ) at x and ψ at y, if φ fails at intermediate w, C4 requires neg(U(...)) at some point — which we don't have at x (we have U(...) at x).

3. **BX7 linearity**: Can show U(φ.neg, top) ∉ limit_f(x) from U(φ,ψ) ∈ limit_f(x) using linearity + density (U(bot, anything) can't hold at the dense limit). Then C4 gives: for any y > x, ∃ z ∈ (x,y) with φ ∈ f(z). But this gives ONE point per interval, not ALL points.

4. **Forward propagation via BX4**: `U(φ,ψ) → G(P(U(φ,ψ)))`. At intermediate w: P(U(φ,ψ)) ∈ f(w). But P(U(φ,ψ)) means U(φ,ψ) held in the past, not that φ holds now.

5. **BX8/BX9 (step/elimination)**: REMOVED — unsound under open guard semantics.

### Why the Finite-Stage Construction Doesn't Help

The `EliminationResult.c5_forward_witness` field only exports the endpoint (η ∈ val.f y), not the guard. The guard at intermediate points is established by the construction internally through BurgessR3Maximal (c2') and the g-function, but:

1. **C3 is NOT maintained** at finite stages. The omega chain stores `{χ : Chronicle // χ.c0 ∧ χ.c2'}` but NOT χ.c3. The elimination code only sets g-values for new adjacent pairs — it does NOT update g-values for spanning pairs, so C3 breaks for non-local triples.

2. **Condition (i) mismatch**: Burgess's condition (i) in 2.10 checks BOTH `η ∧ U(ξ,η) ∈ f(x')` AND `η ∈ g(x, x')`. Our code's condition (i) only checks `ξ ∧ U(ξ,η) ∈ f(x')` (the g-check is missing). This means the "walk" in our code might traverse points where the guard is not in g(x, x'), making the Burgess reduction step invalid for guard preservation.

3. **g_agrees only preserves OLD g-values**: When both endpoints are old domain points, g is preserved. But for new points, g-values are only set for new adjacent pairs.

## Proposed Solutions (Ranked by Feasibility)

### Solution A: Strengthen EliminationResult (RECOMMENDED)

**Effort**: High (modify ~20 instances in CounterexampleElimination.lean)
**Correctness**: Architecturally correct, matches Burgess

Steps:
1. Add `c5_forward_witness_guard` field to EliminationResult (or strengthen existing field)
2. Fix condition (i) in the C5_forward branch to also check `ξ ∈ g(x, x')` (matching Burgess)
3. Prove the guard for each case:
   - n=0 and Walk-A cases where y is after max: guard is VACUOUS (no intermediate points)
   - Walk-B (eta ∈ u_next): may need to create a different witness
   - Split cases: guard is vacuous (z between adjacent points)
   - Not-actual case: guard from push_neg (EASY)
4. Propagate through `omega_chain_c5_witness` → `limit_satisfies_c5_full`
5. Close FUC/FSC using `limit_satisfies_c5_full`

**Risk**: The Walk-B case (eta ∈ u_next at line 950) may not satisfy the guard in its current form. The witness u_next has eta, but intermediate points between pc.x and u_next might lack ξ. May need restructuring of the walk.

### Solution B: Track C3 in the omega chain

**Effort**: Very high (add c3 to ChronicleInvariant tracking, prove preservation)
**Correctness**: Would enable the limit-level C5_full proof

Steps:
1. Add c3 to the omega chain subtype: `{χ : Chronicle // χ.c0 ∧ χ.c2' ∧ χ.c3}`
2. Prove c3 preservation in EliminationResult (requires updating g-values for spanning pairs)
3. Track finite-stage g-values to the limit
4. Prove β ∈ limit_g(x,y) from finite-stage g-values

**Risk**: Very invasive changes. Current g-value management doesn't maintain C3 for non-adjacent pairs.

### Solution C: Hybrid limit-level proof

**Effort**: Medium
**Correctness**: Depends on proving U(φ.neg, top) ∉ limit_f(x) → φ at all intermediate points

Steps:
1. Prove `untl_bot_not_in_limit_mcs`: U(bot, p) ∉ limit_f(x) at dense limit
2. Prove `untl_neg_guard_excluded`: From U(φ,ψ) ∈ limit_f(x), derive neg(U(φ.neg, top)) ∈ limit_f(x)
3. Use C4 + density to get φ at some point in every interval
4. Close the gap from "some point per interval" to "all points"

**Risk**: Step 4 is the unsolved gap. Density of {z : φ ∈ f(z)} does NOT imply universality. This approach likely CANNOT close the sorries by itself.

## Recommended Next Steps

1. **Run `/revise 107`** to update the plan with Solution A.
2. Fix the condition (i) check in `eliminate_potential_counterexample` to match Burgess (add `ξ ∈ g(x, x')` check).
3. Strengthen `c5_forward_witness` to include the guard.
4. Handle each C5_forward case. The most critical is Walk Case B (eta ∈ u_next).
5. Mirror for c5_backward_witness.
6. Close FUC/FSC.

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (lines 634, 638 — the 2 sorries)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (lines 602-614 — EliminationResult; line 795 — condition (i) check)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (lines 590-607 — limit_satisfies_c5_weak; lines 845-849 — limit_g definition)
- `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md` (section 2.10, 2.11)

## Convention Reminder

Our `untl(guard, event)` = Burgess `U(event, guard)`. SWAPPED.
- Our ξ (first arg) = guard = Burgess's η
- Our η (second arg) = event = Burgess's ξ
