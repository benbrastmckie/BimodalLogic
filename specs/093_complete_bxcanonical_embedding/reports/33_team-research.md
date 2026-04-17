# Research Report: Task #93 (Round 33)

**Task**: 93 - Complete BXCanonical embedding (close 6 sorry sites)
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Session**: sess_1776401927_d8ebc7

## Summary

Round 33 assembled four independent analysts to rigorously study how to implement the defect-driven chain construction from scratch. The unanimous conclusion: **the defect-driven chain approach is correct and is the only viable path**, but Plan v32's implementation details contain four critical errors that must be fixed before implementation can succeed. The key insight emerging from cross-teammate analysis is that `target_resolving_fwd_exists_strong` (RootScopedChain.lean:1143) is the correct primitive — it resolves the target AND preserves all other F-obligations — but the chain must use a FIXED ordering (not bx11_earlier) and a NEW Lindenbaum extension (not plain fwd_succ).

## Key Findings

### Finding 1: Four Critical Errors in Plan v32 (Teammate C, confirmed by A and B)

Teammate C identified four blocking issues in Plan v32's proof sketches, all confirmed by cross-analysis:

**Error 1: fwd_succ interface mismatch** — Plan v32 says "use fwd_succ with seed {psi_n} ∪ g_content(chain(n-1))" but `fwd_succ` (CanonicalModel.lean:66) has a FIXED seed constructor. It cannot accept a custom seed. A new Lindenbaum extension with a custom consistency proof is required. This is a material scope underestimate (5-8 additional hours).

**Error 2: bx11_earlier non-transitivity** — Plan v32 proposes "ordered list of F-defects" but `bx11_earlier` (line 928) admits 3-cycles (established by concrete counterexample in Report 16). There is no valid total order derived from bx11_earlier. Plans v14-v16 failed on exactly this.

**Error 3: Sorry 2 proof sketch conflates F(ψ) with G(F(ψ))** — g_content carries G-formulas, not F-formulas. `F(ψ) ∈ chain(t)` does NOT imply `F(ψ) ∈ g_content(chain(t))`. The plan's claim that "g_content propagates F(ψ) forward through the backward chain" is false.

**Error 4: Sorry 5 proof sketch misuses BX5** — BX5 gives `(φ U ψ) → (φ ∧ (φ U ψ)) U ψ`, NOT `(φ U ψ) → G(φ U ψ)`. The plan claims BX5 provides G-persistence of Until formulas, which it does not.

### Finding 2: The Correct Primitive Already Exists (Teammates A, B, D converge)

All three non-critic teammates independently identified `target_resolving_fwd_exists_strong` (RootScopedChain.lean:1143) as the key building block:

- **What it guarantees**: Given target ψ that is `bx11_earlier` than all other defects, produces MCS M' with:
  - `ψ ∈ M'` (target directly resolved, not disjunctive)
  - `F(χ) ∈ M'` for ALL other χ with F(χ) ∈ M (all F-obligations preserved)
  - `g_content(M) ⊆ M'` (G-propagation maintained)

- **Why this bypasses the perpetual deferral**: Unlike `enriched_fwd_step` (which gives `ψ ∈ M' ∨ F(ψ) ∈ M'`), this theorem gives `ψ ∈ M'` WITHOUT disjunction when ψ is bx11_earliest. No Lindenbaum non-determinism on the target.

### Finding 3: The Ordering Problem Has a Resolution (Synthesis of A, C, D)

**The conflict**: Teammate A proposes BX11-ordered chain. Teammate C proves BX11 ordering has 3-cycles and is non-transitive. Teammate D proposes lexicographic ordering.

**Resolution**: The `target_resolving_fwd_exists_strong` theorem requires only that the target is `bx11_earlier` than all OTHER active defects at the CURRENT step — not a global ordering. The key insight from Teammate A's analysis:

- At each step, pick ANY formula ψ that is `bx11_earlier` than all other active defects in the current MCS
- `bx11_earlier_total` (line 934, sorry-free) guarantees that for any two F-defects, one is bx11_earlier
- Even though bx11_earlier admits 3-cycles globally, at each individual step there EXISTS a minimum (by totality + finite set)
- The minimum at each step may differ (ordering is relative to the current MCS), but we only need A minimum, not THE minimum

**The correct construction**: At each step n, compute `bx11_min(activeDefects(chain(n)))` — the bx11_earlier-minimum of the current defect set. Apply `target_resolving_fwd_exists_strong` with this minimum as the target.

**Why forward_F follows**: Given `F(ψ) ∈ chain(n)` with `ψ ∉ chain(n)`:
- ψ is an active defect at step n
- At step n, some bx11_min target χ is resolved
- If χ = ψ: done, ψ ∈ chain(n+1)
- If χ ≠ ψ: F(ψ) ∈ chain(n+1) (preserved by `target_resolving_fwd_exists_strong`)
- ψ remains an active defect at step n+1
- By Teammate A's `count_earlier` measure: the number of defects that are bx11_earlier than ψ in chain(n+1) is ≤ count in chain(n) minus 1 (χ was resolved)
- Wait — χ ∈ chain(n+1), so F(χ) ∈ chain(n+1) by `phi_in_mcs_imp_F_phi`. χ is STILL an active defect!

**The phi_in_mcs_imp_F_phi problem** (Teammate C's Finding 1): Resolving χ does NOT remove it from active defects. F(χ) regenerates immediately. The defect count is CONSTANT.

### Finding 4: The Defect Count Is Constant — But Forward_F May Still Be Provable (Key Synthesis)

This is the central tension of Round 33. All teammates agree:
- F-obligation count does NOT decrease (phi_in_mcs_imp_F_phi, line 1128)
- The quasimodel's defect_count uses Until-defects on a finite model, which DO decrease — this does not transfer to the MCS setting

**However**, Teammate D identifies the crucial distinction: forward_F does NOT require the defect count to decrease. It only requires each formula to be eventually targeted. The correct framing:

- Define "unresolved defect" as `F(ψ) ∈ chain(n) ∧ ψ ∉ chain(n)` (not just F(ψ) ∈ chain(n))
- After resolving ψ at step n+1: `ψ ∈ chain(n+1)`, so ψ is NO LONGER an unresolved defect
- F(ψ) ∈ chain(n+1) is true (by phi_in_mcs_imp_F_phi), but ψ ∈ chain(n+1) is ALSO true
- The unresolved defect count `|{χ ∈ sigma_list : F(χ) ∈ chain(n) ∧ χ ∉ chain(n)}|` DOES decrease
- **Critical question**: Does ψ STAY in chain(n+2), chain(n+3), ...? If ψ ∉ chain(n+2) (it falls out at the next step), then ψ re-enters the unresolved defect set

**The G(¬ψ) entry problem** (Teammate A, Section 5.5): At step n+2 (resolving some other χ'), the seed is `{χ'} ∪ g_content(chain(n+1))`. If `G(ψ) ∉ chain(n+1)`, then ψ is NOT in g_content, and Lindenbaum may produce an MCS containing `¬ψ`. So ψ can fall out at step n+2.

**Teammate A's resolution**: Use `fwd_succ_with_guard` — an enriched seed `{χ', F(ψ)} ∪ g_content(M)` that protects F(ψ) at each step. This prevents G(¬ψ) from entering. The enriched seed is consistent when χ' is bx11_earlier than ψ (BX11 cases 1 or 2).

### Finding 5: The Required New Infrastructure (Synthesis)

Based on all four teammates, the implementation requires:

1. **A new Lindenbaum extension function** (NOT plain fwd_succ): Takes target + guard formula + g_content as seed. ~50-80 LOC including consistency proof. Uses `enriched_resolving_seed_consistent` (OrderedSeedConsistency.lean:70).

2. **A chain construction using `target_resolving_fwd_exists_strong`**: At each step, the bx11_min of current unresolved defects is resolved, all other F-obligations preserved. ~100-150 LOC.

3. **A forward_F proof by well-founded induction**: The measure is the count of unresolved defects (formulas with F(ψ) ∈ chain(n) AND ψ ∉ chain(n)). This count may NOT strictly decrease at each step (ψ can re-enter). The WF argument needs careful handling.

4. **A symmetric backward chain**: Using `bwd_pred` with P-defect tracking. ~100-150 LOC.

5. **Sorry 2 fix**: Cannot use g_content propagation for F-formulas. Need an alternative path (possibly BX4-based: `F(ψ) → G(P(F(ψ)))` gives `P(F(ψ)) ∈ h_content`, propagating backward).

6. **Sorry 5 fix**: Step transfer cannot use BX5 for G-persistence. Need chain-level enrichment or use of the restricted parametric truth lemma.

### Finding 6: The Infinite Tail Problem (Teammate B's Key Discovery)

Teammate B's exhaustive analysis of 6 alternatives reveals the fundamental challenge: **any finite-discharge construction that resolves ψ finitely many times leaves all t > last_resolution as counterexamples for forward_F.**

After the k-step defect-discharge region:
- F(ψ) persists forever (by phi_in_mcs_imp_F_phi + F-obligation constancy)
- ψ may not be in chain(t) for t >> k (no G(ψ) to propagate)
- Forward_F requires a witness s > t for EVERY t

**Teammate D's counter**: The defect-driven chain should NOT have a finite discharge region followed by a non-resolving tail. Instead, it should resolve defects INFINITELY — cycling through the defect list forever. At each cycle, every defect is targeted at least once. Since the cycle length is bounded by |sigma_list|, every defect is resolved within |sigma_list| steps.

**Synthesis**: The correct chain alternates indefinitely between resolving and non-resolving steps, ensuring every defect is targeted infinitely often. This is structurally similar to the round-robin chain BUT uses `target_resolving_fwd_exists_strong` (direct resolution) instead of `enriched_fwd_step` (disjunctive resolution).

### Finding 7: Architecture Is Correct — No Pivot Needed (Teammate D, 85% confidence)

The FMCS/BFMCS layer is load-bearing, not an unnecessary intermediary. A "quasimodel-first" completeness proof would trade 6 sorry sites for ~600 new ones by dismantling the sorry-free parametric truth lemma pipeline. The 6 sorries should be closed by engineering, not accepted as axioms.

## Synthesis

### Conflicts Found and Resolved

**Conflict 1: Ordering principle**
- Teammate A: BX11 ordering with bx11_first_defect
- Teammate C: BX11 is non-transitive (3-cycles), kills ordered list
- Teammate D: Lexicographic ordering
- **Resolution**: BX11 ordering is used only LOCALLY at each step (find bx11_min of current defects). Non-transitivity is irrelevant because we only need a minimum at each individual step, which totality guarantees. The ordering changes from step to step (relative to MCS), but `target_resolving_fwd_exists_strong` only needs the target to be bx11_earlier than all others AT THAT STEP.

**Conflict 2: Defect count decrease**
- Teammates A, D: Assume defect-driven chain makes progress
- Teammate C: phi_in_mcs_imp_F_phi means F-defect count is CONSTANT
- Teammate B: Confirms defect set never shrinks
- **Resolution**: Redefine "unresolved defect" as `F(ψ) ∈ M ∧ ψ ∉ M`. This count CAN decrease when ψ is resolved. But ψ can re-enter the unresolved set at the next step if it falls out of the chain. The WF argument must account for this — either by using `fwd_succ_with_guard` to prevent ψ from falling out, or by accepting that the chain resolves each defect infinitely often (cyclic schedule).

**Conflict 3: Confidence levels**
- Teammate A: 55-65% (medium)
- Teammate B: 20% for alternatives, 85% for plan v32 being the only path
- Teammate C: 25% for plan v32 as written
- Teammate D: 85% strategic, 65% implementation
- **Resolution**: Plan v32's ARCHITECTURE is correct (85% consensus). Plan v32's IMPLEMENTATION DETAILS have critical errors (25% as written). With the corrections identified in this round, confidence rises to **55-65%** for the corrected approach.

### Gaps Identified

1. **The unresolved defect re-entry gap**: After resolving ψ at step n+1, does ψ stay resolved? If not, the WF argument on unresolved defect count fails. The `fwd_succ_with_guard` approach (Teammate A) may prevent re-entry by including F(ψ) in subsequent seeds, but this hasn't been formally verified. **Severity: High, 60% probability of blocking.**

2. **Sorry 2 propagation gap**: F-formulas do not propagate through g_content. An alternative mechanism is needed. **Severity: Medium, 40% probability of blocking.**

3. **Sorry 5 step transfer gap**: No clean derivation from BX axioms + chain structure. **Severity: Medium, 40% probability of blocking.**

4. **New Lindenbaum extension scope**: Defining a custom seed Lindenbaum extension with consistency proof is 5-8 hours of additional work not in Plan v32's estimates. **Severity: Low (scope, not blocking).**

### Recommendations

**Primary path (55-65% confidence)**: Implement the defect-driven chain with these corrections to Plan v32:

1. **Replace `fwd_succ` with a custom Lindenbaum extension** that accepts target + guard formula + g_content as seed. Use `enriched_resolving_seed_consistent` for consistency.

2. **Use `target_resolving_fwd_exists_strong` at each step**, targeting the bx11_min of current unresolved defects. Do NOT assume a global ordering — compute the minimum locally at each step.

3. **Cycle the defect schedule infinitely** (not finite discharge + non-resolving tail). At each step, resolve the bx11_min unresolved defect. After resolution, the formula may re-enter the unresolved set at the next step, but it will be targeted again within |sigma_list| steps.

4. **Fix sorry 2**: Use BX4 (`G(P(F(ψ)))` from `F(ψ)`) to propagate P(F(ψ)) backward through h_content, then use backward_P to get F(ψ) propagation. Alternatively, handle the t < 0 case by showing F(ψ) ∈ chain(0) = M₀ directly from the backward chain's g_content/h_content properties.

5. **Fix sorry 5**: Investigate whether the restricted parametric truth lemma can discharge step transfer without chain-level enrichment. If not, include Until formulas in the chain seed.

6. **Revise effort estimate**: 10 hours (Plan v32) → 15-20 hours accounting for the new Lindenbaum extension, WF argument complexity, and sorry 2/5 fixes.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Approach | completed | 55-65% | BX11-ordered chain with fwd_succ_with_guard; G(¬ψ) entry problem analysis; count_earlier measure |
| B | Alternative Approaches | completed | 20%/85% | 6 alternatives systematically eliminated; infinite tail problem; target_resolving_fwd_exists_strong identified |
| C | Critic | completed | 25% | 4 critical errors in Plan v32; fwd_succ interface mismatch; bx11_earlier non-transitivity; phi_in_mcs_imp_F_phi regeneration |
| D | Horizons | completed | 85%/65% | Architecture validation; no pivot needed; defect-driven scheduling makes forward_F definitional; anti-patterns |

## References

### Key Codebase Paths
- `RootScopedChain.lean:1413` - Sorry 1 (forward_F depth-0)
- `RootScopedChain.lean:1457` - Sorry 2 (forward_F t<0)
- `RootScopedChain.lean:1464` - Sorry 3 (backward_P)
- `RootScopedChain.lean:1517` - Sorry 4 (restricted_tc)
- `RootScopedChain.lean:1522` - Sorry 5 (restricted_buc)
- `RootScopedChain.lean:1527` - Sorry 6 (restricted_fuc)
- `RootScopedChain.lean:1143` - target_resolving_fwd_exists_strong (KEY PRIMITIVE)
- `RootScopedChain.lean:928` - bx11_earlier definition
- `RootScopedChain.lean:934` - bx11_earlier_total (totality)
- `RootScopedChain.lean:1031` - target_stays_direct_in_fold
- `RootScopedChain.lean:1128` - phi_in_mcs_imp_F_phi (F regeneration)
- `RootScopedChain.lean:1188` - rr_fwd_chain_F_obligation_forward (F-obligation constancy)
- `CanonicalModel.lean:66` - fwd_succ (fixed-seed interface)
- `CanonicalModel.lean:92-97` - fwd_succ_resolves (one-step forward_F)
- `OrderedSeedConsistency.lean:70` - enriched_resolving_seed_consistent
- `Frame.lean:164` - bx_forward_witness
- `Frame.lean:623` - bx_until_eventuality_resolution
- `Quasimodel/Construction.lean:45-52` - hintikka_step
- `Bundle/UntilSinceCoherence.lean:111` - backward_until_from_step (step transfer parameterization)

### Dead Ends Confirmed This Round
- Dead end 22 (perpetual deferral): DEFINITIVELY confirmed as structural (all 4 teammates)
- Dead end 13 (extended seed / full f_carry): Confirmed inconsistent; single-formula variant may work
- BX11 ordering as global total order: Confirmed non-transitive (3-cycles); local minimum still viable
- G(F(ψ)) propagation: Confirmed not derivable from F(ψ) (dead ends 23, 24)
- Quasimodel-first completeness pivot: Rejected (would cost more than current approach)
