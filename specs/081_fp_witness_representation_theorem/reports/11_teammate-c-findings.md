# Report 11C: Option C -- Dovetailed Chain with temporal_theory_witness_exists

**Task**: 81 -- F/P Witness Representation Theorem
**Date**: 2026-04-01
**Focus**: Rigorous analysis of the dovetailed chain approach using `temporal_theory_witness_exists`
**Confidence Level**: HIGH (for the full MCS dovetailed approach), MEDIUM (for bridging to DRM)

---

## Executive Summary

The dovetailed chain approach using `temporal_theory_witness_exists` is **the most mathematically clean path** to same-family forward_F/backward_P. The existing `DovetailedChain.lean` already contains a sorry-free forward chain construction with proven G-propagation, H-propagation, and box_class_agree. The forward_F resolution proof is the missing piece, and the codebase contains extensive design analysis documenting exactly why it is hard and what the correct approach is.

The fundamental insight: **F-persistence is NOT needed** for the dovetailed chain to work. The resolve-or-lose dichotomy (either phi appears somewhere in the chain, or G(neg phi) enters and kills F(phi)) combined with the construction's ability to resolve F(phi) at step n+1 whenever F(phi) is still in chain(n), is sufficient -- provided the chain uses `temporal_theory_witness_exists` which gives resolution BY CONSTRUCTION at each step.

However, there is a real gap: `temporal_theory_witness_exists` works with **full MCS** (SetMaximalConsistent), not DeferralRestrictedMCS. The completeness theorem needs DRM chains (for the truth lemma). Bridging this gap via `restricted_chain_ext` is possible but requires additional work.

---

## Key Finding 1: temporal_theory_witness_exists -- Exact Statement and Properties

**Location**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean:2212`

```lean
theorem temporal_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W
```

This theorem provides, given any full MCS M with F(phi) in M:
1. A new full MCS W
2. phi in W (the F-obligation is resolved)
3. G-theory agreement: G(a) in M implies G(a) in W
4. box_class_agree between M and W

**Proof mechanism**: Uses `temporal_theory_witness_consistent` which proves `{phi} ∪ temporal_box_seed(M)` is consistent via the **G-lift argument**: if L subset of seed derives bot, then by deduction theorem L' derives neg(phi), then by generalized temporal K, G(neg(phi)) in M, contradicting F(phi) in M.

**Status**: SORRY-FREE. Both `temporal_theory_witness_consistent` and `temporal_theory_witness_exists` are fully proven.

### temporal_theory_witness_consistent -- The G-Lift Argument

**Location**: `UltrafilterChain.lean:2167`

The seed is `{phi} ∪ G_theory(M) ∪ box_theory(M)` where:
- `G_theory(M) = {G(a) | G(a) in M}` -- these are G-liftable by temp_4: G(a) implies G(G(a))
- `box_theory(M) = {Box(a) | Box(a) in M} ∪ {neg(Box(a)) | Box(a) not in M}` -- G-liftable via modal_future + S5 axioms

Every element x of `temporal_box_seed(M)` satisfies `G(x) in M`. This is the key property enabling the G-lift consistency argument.

### forward_temporal_witness_seed_consistent -- The Simpler Version

**Location**: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean:79`

```lean
theorem forward_temporal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    SetConsistent (forward_temporal_witness_seed M psi)
```

This is the simpler seed `{psi} ∪ g_content(M)` (without box_theory). Also sorry-free. This is sufficient for G-propagation and forward_F; box_class_agree requires the full temporal_box_seed.

---

## Key Finding 2: The Existing Dovetailed Chain Infrastructure

**Location**: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`

### What Exists (Sorry-Free)

| Definition/Theorem | Line | Status |
|---------------------|------|--------|
| `forward_step` | 66 | Sorry-free. Single step resolving targeted F-obligation |
| `forward_step_mcs` | 78 | Sorry-free. Step produces MCS |
| `forward_step_resolves` | 89 | Sorry-free. If F(phi) in M, then phi in forward_step |
| `forward_step_G_agree` | 99 | Sorry-free. G-theory propagates |
| `forward_step_box_agree` | 111 | Sorry-free. box_class_agree propagates |
| `forward_step_g_content` | 123 | Sorry-free. g_content propagates |
| `schedule_formula` | 139 | Sorry-free. Fair scheduling via Nat.unpair |
| `forward_dovetailed` | 146 | Sorry-free. Full Nat-indexed chain |
| `forward_dovetailed_mcs` | 156 | Sorry-free. Every point is MCS |
| `forward_dovetailed_G_step` | 170 | Sorry-free. G propagation step |
| `forward_dovetailed_G_propagate` | 181 | Sorry-free. G propagation multi-step |
| `forward_dovetailed_g_content_step` | 196 | Sorry-free. g_content propagation |
| `forward_dovetailed_forward_G` | 205 | Sorry-free. Forward G coherence |
| `forward_dovetailed_h_content_reverse` | 220 | Sorry-free. Backward H coherence |
| `forward_dovetailed_backward_H_step` | 234 | Sorry-free. H propagation backward step |
| `forward_dovetailed_backward_H` | 258 | Sorry-free. H propagation multi-step |
| `forward_dovetailed_box_agree` | 279 | Sorry-free. box_class_agree through chain |

### What Is Missing

The **forward_F resolution theorem** is NOT implemented. The file contains extensive design analysis (lines 288-605) exploring why F-persistence fails and what the correct approach is. The analysis concludes:

> "THIS APPROACH FUNDAMENTALLY DOESN'T WORK for same-family forward_F with Lindenbaum-based chains, because Lindenbaum can introduce G(neg(phi)) before the scheduler gets to phi."

And then proposes:

> "DEFINITIVE SOLUTION: Instead of arbitrary Lindenbaum extensions, use CONSTRAINED extensions that preserve F-content."

### Missing Definitions (Declared in Header, Not Implemented)

- `dovetailed_fmcs` -- FMCS Int with forward_G, backward_H, forward_F, backward_P
- `construct_bfmcs_int` -- The `construct_bfmcs` function for D = Int

---

## Key Finding 3: The F-Persistence Problem -- Deep Analysis

### The Problem Statement

Given F(phi) in chain(t), we need phi in chain(s) for some s > t. The dovetailed chain resolves the **scheduled** formula at each step. But F(phi) may not persist from chain(t) to chain(n) where n is the step that targets phi.

### Why F-Persistence Fails

At each step, chain(n+1) is a Lindenbaum extension of `{resolution_formula} ∪ temporal_box_seed(chain(n))`. The Lindenbaum extension is free to add G(neg(phi)) to the MCS (which would kill F(phi) = neg(G(neg(phi)))). This happens when:

1. G(neg(phi)) is consistent with the seed
2. G(neg(phi)) is NOT in temporal_box_seed(chain(n)) (since G(G(neg(phi))) is not in chain(n))
3. Lindenbaum can freely choose to include G(neg(phi))

Once G(neg(phi)) enters chain(k), it propagates forward via G_propagate, permanently preventing phi from appearing.

### The Key Realization: F-Persistence Is NOT Needed

The correct argument does NOT require tracking F-persistence. Instead:

**Claim**: For any F(phi) in chain(t), either:
- (a) phi appears in chain(s) for some s >= t (done), or
- (b) phi never appears, meaning neg(phi) in chain(s) for all s >= t

In case (b): At chain(t), F(phi) in chain(t) and neg(phi) in chain(t) is consistent (F(phi) means phi holds EVENTUALLY, neg(phi) means not NOW). But G(neg(phi)) is NOT in chain(t) (since that contradicts F(phi)). If G(neg(phi)) enters at some later step k, then F(phi) is lost from chain(k) onward. But between t and k, F(phi) might still be in some intermediate chain(s).

**The resolution**: At each step n, if F(schedule_formula(n)) is in chain(n), the forward_step resolves it. By the scheduling's surjectivity (Nat.unpair covers all pairs), for any (t, phi), there exists n = Nat.pair(t, encode(phi)) that targets phi. If F(phi) is STILL in chain(n) at that step, it gets resolved. If F(phi) was already killed (G(neg(phi)) entered earlier), then we're in case (b) -- but this contradicts F(phi) in chain(t) only if we can show the chain would have resolved phi earlier.

**This is the gap**: We cannot guarantee that F(phi) survives until the scheduling step targets it.

---

## Key Finding 4: The DeferralDisjunction Alternative

### The Resolve-or-Defer Property

The `deferralDisjunction` mechanism provides an alternative route. When F(phi) is in an MCS u, the deferral disjunction `phi ∨ F(phi)` is a tautological consequence of F(phi) (via right disjunction introduction: F(phi) implies phi ∨ F(phi)). In any MCS extending a seed containing this disjunction, either:
- phi is in the MCS (obligation resolved), OR
- F(phi) is in the MCS (obligation deferred)

This gives the **weak f_step**: `f_content(u) ⊆ v ∪ f_content(v)`.

### The DRM Bounded Resolution Argument

For DeferralRestrictedMCS chains, the weak f_step combines with **bounded F-nesting** to force resolution:

1. `f_nesting_is_bounded_restricted` (SuccChainFMCS.lean:737): For any RestrictedMCS M over phi, if F(phi) in M, then iter_F(n)(phi) is not in M for some n >= 2.

2. `restricted_mcs_F_bounded` (RestrictedMCS.lean:478): If F(phi) in DRM M, there exists d >= 1 such that iter_F(d)(phi) in M but iter_F(d+1)(phi) not in M.

3. `closure_F_bound phi`: The explicit bound where iter_F leaves deferralClosure(phi).

The key point: within deferralClosure, the F-nesting depth is bounded. Each deferral step preserves or increases the F-nesting level. When the boundary is reached (F^d(phi) in chain but F^(d+1)(phi) not in chain because it left deferralClosure), the deferral disjunction `F^(d-1)(phi) ∨ F^d(phi)` must resolve to `F^(d-1)(phi)` (since F^d(phi) cannot defer further). This cascades back to resolve phi itself.

**This argument works for DRM chains but NOT for full MCS chains** (where F-nesting is unbounded).

---

## Key Finding 5: Full MCS vs DRM Gap

### The Two Approaches

| Approach | Works With | Forward_F Method | Status |
|----------|-----------|-----------------|--------|
| Dovetailed chain (DovetailedChain.lean) | Full MCS | Fair scheduling + temporal_theory_witness_exists | forward_F NOT proven |
| Restricted chain (SuccChainFMCS.lean) | DRM | Weak f_step + bounded F-nesting | Depends on sorry in seed consistency |
| Simplified chain (SimplifiedChain.lean) | DRM | Weak f_step + bounded F-nesting | sorry in targeted_restricted_seed_consistent |

### The restricted_chain_ext Bridge

**Location**: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean:186`

```lean
noncomputable def restricted_chain_ext (phi : Formula)
    (fam : RestrictedTemporallyCoherentFamily phi) (n : Int) : Set Formula :=
  lindenbaumMCS_set (restricted_succ_chain_fam phi fam.seed n) ...
```

This takes a DRM chain and extends each point to a full MCS via unrestricted Lindenbaum. The `restricted_truth_lemma` (line 291) shows that for formulas in `subformulaClosure(phi)`, membership in the DRM equals membership in the extended chain.

**However**: `restricted_tc_family_to_fmcs` (CanonicalConstruction.lean:838) which uses this extension has sorries at lines 889 and 893 for forward_G and backward_H. These sorries exist because G-propagation through Lindenbaum extensions is not automatic -- G(phi) in ext(n) does not immediately give phi in ext(n+1) because the Lindenbaum extensions at n and n+1 are INDEPENDENT.

### Can We Use Full MCS Dovetailed Chain Directly?

If we could prove forward_F for the full MCS dovetailed chain, we would NOT need the DRM machinery at all. The `construct_bfmcs_bundle` (UltrafilterChain.lean:3540) already builds BFMCS from full MCS chains. The gap is ONLY forward_F.

---

## Key Finding 6: The Correct Dovetailed Forward_F Argument

### The Two-Phase Proof Strategy

**Phase 1**: Show that for any F(phi) in chain(t), at the step n = Nat.pair(t, encode(phi)):
- If F(phi) in chain(n), then chain(n+1) resolves it (by forward_step_resolves)
- If F(phi) not in chain(n), then G(neg(phi)) entered the chain at some step k with t < k <= n

**Phase 2**: Show that case 2 leads to a contradiction with F(phi) in chain(t).

The difficulty is in Phase 2. G(neg(phi)) entering at step k means the Lindenbaum extension at step k included G(neg(phi)). This is consistent with temporal_box_seed(chain(k-1)) because G(G(neg(phi))) might not be in chain(k-1). So we CANNOT derive a contradiction in general.

### Why The Standard Textbook Approach Works (But Our Formalization Doesn't Match)

In the standard textbook proof (e.g., Goldblatt, Hughes & Cresswell), the canonical model construction builds MCS using:
1. Enumerate ALL formulas
2. At each step, add the formula if consistent
3. This ensures completeness (Lindenbaum)

For temporal completeness, the construction dovetails formula enumeration with F-obligation resolution:
1. At step 2n: add formula n if consistent (Lindenbaum)
2. At step 2n+1: if F(phi_n) is in the current set, extend with a witness for phi_n

The critical difference: the textbook builds ONE MCS incrementally (each step adds one formula). Our construction builds a CHAIN of complete MCS (each step produces a whole new MCS via Lindenbaum). In the textbook approach, F-persistence is guaranteed because the MCS is built incrementally.

### The Viable Path: Dovetailed Chain WITH DeferralDisjunctions

Combine the dovetailed chain approach with the bounded-F-nesting argument:

1. **Build chain using dovetailed steps** but with a MODIFIED seed that includes deferralDisjunctions (from the simplified restricted seed)
2. At each step n+1, the seed is `{schedule_formula(n)} ∪ g_content(chain(n)) ∪ deferralDisjunctions(chain(n))`
3. The deferralDisjunctions ensure weak f_step (resolve-or-defer) at each step
4. **If working within DRM**: bounded F-nesting forces resolution
5. **If working with full MCS**: need to additionally show that the scheduled resolution targets the right formula at the right time

For DRM: this IS the simplified chain approach from SimplifiedChain.lean, and the missing piece is `targeted_restricted_seed_consistent`.

---

## Key Finding 7: targeted_restricted_seed_consistent -- The Core Sorry

**Location**: `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean:155`

```lean
theorem targeted_restricted_seed_consistent (phi : Formula) (u : Set Formula) (target : Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_target : Formula.some_future target ∈ u)
    (h_target_dc : target ∈ (deferralClosure phi : Set Formula)) :
    SetConsistent (targeted_restricted_seed phi u target)
```

The seed is `simplified_restricted_seed(phi, u) ∪ {target}` where:
- simplified_restricted_seed = g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_restricted(phi, u)
- target is the specific formula we want to force into the successor

**The sorry is at line 195**: When target is in L, we need the G-lift argument, but deferralDisjunctions and p_step_blocking elements are NOT G-liftable. The proof comment says:

> "The full proof requires the G-lift argument from temporal_theory_witness_consistent applied to a context that includes the non-G-liftable elements from u."

### Path to Closing This Sorry

The key observation: `simplified_restricted_seed ⊆ u` (proven as `simplified_restricted_seed_subset_u`). So `targeted_restricted_seed = simplified_restricted_seed ∪ {target} ⊆ u ∪ {target}`.

If we could show `u ∪ {target}` is consistent when F(target) in u, we'd be done. But this is FALSE in general: neg(target) may be in u (u can contain both neg(target) and F(target) simultaneously).

The correct argument splits L into g_content elements (G-liftable) and non-g_content elements (in u but not G-liftable):

1. Suppose L ⊆ targeted_seed and L derives bot
2. target in L (otherwise L ⊆ u, contradiction)
3. L' = L \ {target} derives neg(target) (by deduction theorem)
4. Partition L' = L_g ∪ L_other where L_g ⊆ g_content(u) and L_other ⊆ deferralDisjunctions(u) ∪ p_step_blocking(u)
5. L_other ⊆ u, so each element of L_other is derivable from u
6. Since L_g ∪ L_other derives neg(target), and L_other ⊆ u, we can derive neg(target) from L_g ∪ u_elements
7. **Critical**: Since L_g ⊆ g_content(u), every element of L_g has G(element) in u
8. If we could G-lift: from L_g derives neg(target), get G(neg(target)) in u, contradicting F(target) in u
9. **Problem**: We can only G-lift from L_g, not from L_g ∪ L_other

The resolution requires showing that L_other elements can be "absorbed" into the G-lift. Since L_other ⊆ u and every derivation L_g ∪ L_other ⊢ neg(target) can be transformed (by modus ponens from u) into a derivation using only L_g plus formulas already in u, the G-lift gives G(neg(target)) given that all the u-elements have their G-versions in u... which is NOT guaranteed for arbitrary u-elements.

**Alternative**: Use `temporal_theory_witness_consistent` directly (which works with the full temporal_box_seed including G_theory AND box_theory). The temporal_box_seed elements are ALL G-liftable. Show that targeted_restricted_seed ⊆ {target} ∪ temporal_box_seed(M_ext) where M_ext is a full MCS extending u. But this introduces circularity.

**Simplest correct path**: Prove a RESTRICTED version of `temporal_theory_witness_consistent` that works with DRM u, using only g_content(u) (not the full temporal_box_seed). The `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) already proves `{psi} ∪ g_content(M)` is consistent when F(psi) in M (for full MCS M). The question is whether DRM u being "MCS within deferralClosure" is sufficient for the same argument.

---

## F-Persistence Analysis

### Does F-Persistence Actually Matter?

**Answer: No, for the dovetailed chain approach.** The dovetailed chain resolves F-obligations by construction -- each F(phi) at time t gets a dedicated resolution step. The question is not whether F(phi) persists but whether the resolution step succeeds.

The resolution step succeeds precisely when F(phi) is still in chain(n) at the resolution step n. If F(phi) has been killed (G(neg(phi)) entered), the obligation is "lost" -- but this can only happen if Lindenbaum made a choice that is consistent with the seed.

**For full MCS chains**: F-persistence failure is a real problem because the chain is infinite and unbounded.

**For DRM chains**: F-persistence failure is bounded by the closure depth. The deferralDisjunctions ensure that at each step, every F-obligation is either resolved or deferred. The bounded F-nesting ensures that deferral cannot continue forever. So even without explicit F-persistence in the seed, the chain must eventually resolve every F-obligation.

### The DeferralDisjunction Insight

The deferralDisjunction `phi ∨ F(phi)` in the seed is the key mechanism. In any MCS extending the seed:
- If phi is in the MCS: F-obligation resolved
- If F(phi) is in the MCS: F-obligation deferred (but F-nesting increased)

Since deferralClosure is finite, F-nesting cannot increase indefinitely. At the boundary (when F^d(phi) is in the DRM but F^(d+1)(phi) is outside deferralClosure), the deferral disjunction `F^(d-1)(phi) ∨ F^d(phi)` forces resolution to `F^(d-1)(phi)` because the DRM cannot contain F^d(phi) (it would be outside the closure).

Wait -- this is subtle. The DRM CAN contain F^d(phi) if it is in deferralClosure. The bound says iter_F(closure_F_bound)(phi) is NOT in deferralClosure. So for all psi in DRM with F(psi) in DRM, the F-nesting of psi within deferralClosure is bounded. When we reach the boundary, the deferralDisjunction cannot defer (since F(boundary_formula) is not in deferralClosure, so it cannot be in the DRM), forcing resolution.

---

## Full MCS vs DRM Gap: Can This Be Bridged?

### Option A: Prove forward_F for Full MCS Dovetailed Chain

This requires solving the F-persistence problem for full MCS chains. The codebase analysis (DovetailedChain.lean lines 288-605) conclusively shows this approach fails for Lindenbaum-based chains.

**Verdict**: NOT VIABLE without fundamentally different chain construction.

### Option B: Use DRM Chain + restricted_chain_ext

Build a DRM chain with forward_F (via bounded F-nesting), then extend to full MCS chain via `restricted_chain_ext`. The truth lemma (`restricted_truth_lemma`) handles formulas in subformulaClosure.

**Gap**: `restricted_tc_family_to_fmcs` has sorries for forward_G and backward_H propagation through the Lindenbaum extension. These need separate proofs.

**Verdict**: VIABLE but requires closing the restricted_tc_family_to_fmcs sorries.

### Option C: Bypass the BFMCS Bridge Entirely

Build completeness directly from the DRM chain without going through full MCS. The `restricted_truth_lemma` shows that for formulas in subformulaClosure(phi), DRM membership equals extended MCS membership. For completeness, we only need to evaluate the TARGET formula phi, which is in its own subformulaClosure.

**Verdict**: MOST VIABLE. This is the approach recommended by Report 10.

---

## Infrastructure Reuse Summary

### Can Be Reused Directly (Sorry-Free)

| Component | Location | What It Provides |
|-----------|----------|-----------------|
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:79 | `{psi} ∪ g_content(M)` consistent when F(psi) in MCS M |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | Full MCS witness with G-agree and box_class_agree |
| `forward_step`, `forward_dovetailed` | DovetailedChain.lean:66-200 | Full MCS dovetailed chain with G/H/box properties |
| `simplified_restricted_seed_consistent` | SimplifiedChain.lean:78 | DRM simplified seed consistency |
| `simplified_restricted_seed_subset_dc` | SimplifiedChain.lean:88 | Seed within deferralClosure |
| `deferral_restricted_lindenbaum` | RestrictedMCS.lean | Lindenbaum within deferralClosure |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | DRM iff extended chain for subformulaClosure |
| `f_nesting_is_bounded_restricted` | SuccChainFMCS.lean:737 | Bounded F-nesting for RestrictedMCS |
| `restricted_mcs_F_bounded` | RestrictedMCS.lean:478 | F-boundary for DRM |

### Has Sorries But Provides Architecture

| Component | Location | Sorry | What's Needed |
|-----------|----------|-------|--------------|
| `targeted_restricted_seed_consistent` | SimplifiedChain.lean:195 | G-lift for DRM | G-lift argument for g_content within DRM context |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2082 | Full seed consistency | Same fundamental gap (f_content not G-liftable) |
| `restricted_tc_family_to_fmcs` | CanonicalConstruction.lean:889,893 | forward_G/backward_H | G/H propagation through independent Lindenbaum extensions |

---

## Recommended Approach: Concrete Implementation Strategy

### Strategy: DRM-Based Simplified Chain with Direct Completeness

Avoid the full MCS dovetailed chain entirely. Instead:

1. **Close `targeted_restricted_seed_consistent`** by adapting the G-lift argument from `forward_temporal_witness_seed_consistent`. The adaptation needs:
   - Recognize that g_content elements are G-liftable (by definition)
   - Recognize that non-g_content elements (deferralDisjunctions, p_step_blocking) are in u
   - Use a modified proof: from L' ⊢ neg(target) where L' ⊆ simplified_seed, extract the g_content portion and use the G-lift on ONLY that portion, with the non-g_content portion handled by showing they are derivable from u

2. **Build simplified forward chain** using targeted steps at boundary formulas (where bounded F-nesting forces resolution) and simplified steps elsewhere.

3. **Prove forward_F** via well-founded induction on F-nesting depth within deferralClosure.

4. **Use restricted_truth_lemma** directly for completeness evaluation, bypassing the need for full MCS chain properties.

### Key Technical Step: Closing targeted_restricted_seed_consistent

The proof should follow this structure:

```
Given: L ⊆ targeted_seed, L ⊢ bot, target ∈ L
Need: contradiction

Step 1: L' = L \ {target}, L' ⊢ neg(target) (deduction theorem)
Step 2: L'_g = L' ∩ g_content(u), L'_other = L' \ g_content(u)
Step 3: L'_other ⊆ u (since simplified_seed ⊆ u)
Step 4: From L'_g ∪ L'_other ⊢ neg(target), use hypothetical syllogism:
         Since each x ∈ L'_other is in u, replace x with "u derives x"
         to get: L'_g ∪ {derivable-from-u} ⊢ neg(target)
Step 5: This means u ∪ L'_g ⊢ neg(target)
Step 6: Since u ⊢ x for each x ∈ L'_other, we have L'_g ⊢ neg(target)
         relative to u as background theory
Step 7: G-lift L'_g ⊢ neg(target): G_list ⊢ G(neg(target))
         where G_list = map G L'_g, and each G(x) ∈ u for x ∈ g_content(u)
Step 8: G(neg(target)) ∈ u (by MCS closure under derivation from G_list ⊆ u)
Step 9: But F(target) = neg(G(neg(target))) ∈ u, contradiction.
```

**The gap in Step 6**: We cannot simply remove L'_other from the derivation. The derivation L'_g ∪ L'_other ⊢ neg(target) may genuinely use L'_other elements. The G-lift only works on the L'_g part.

**The real solution**: The G-lift argument from temporal_theory_witness_consistent handles this by noting that temporal_box_seed(M) = G_theory(M) ∪ box_theory(M), and ALL elements of this seed are G-liftable. But in the DRM context, the simplified seed includes deferralDisjunctions which are NOT G-liftable.

**Possible resolution**: Show that deferralDisjunctions are derivable from g_content within u. A deferralDisjunction `phi ∨ F(phi)` is derivable from `F(phi)`. Since F(phi) ∈ u, the disjunction is redundant given u. If we replace L'_other elements with their derivations from u, and those derivations only use elements whose G is in u... this gets circular.

**Most pragmatic path**: Accept that `targeted_restricted_seed_consistent` may need a different proof technique. Instead, use `temporal_theory_witness_exists` to construct the witness W (a full MCS), then show that the DRM-restriction of W within deferralClosure(phi) is a valid DRM successor. This leverages the existing sorry-free full-MCS witness construction.

---

## Summary of Viability Assessment

| Aspect | Assessment |
|--------|-----------|
| Dovetailed chain (full MCS) forward_F | NOT viable (F-persistence fails) |
| Dovetailed chain (DRM) with bounded F-nesting | VIABLE if targeted seed consistency is proven |
| targeted_restricted_seed_consistent | Hardest remaining gap; G-lift doesn't directly apply |
| DRM chain + restricted_truth_lemma for completeness | VIABLE and recommended |
| Reusing temporal_theory_witness_exists for DRM witnesses | PROMISING: construct full MCS witness, then restrict |
| Overall confidence in dovetailed approach | HIGH for DRM path, given a way to close the targeted seed sorry |

### Recommended Next Steps

1. **Attempt the "construct full MCS, then restrict" approach**: Use `temporal_theory_witness_exists` to get full MCS witness W with target in W and G-agree. Then take W_restricted = W ∩ deferralClosure(phi). Show W_restricted is a valid DRM. This entirely bypasses the targeted seed consistency problem.

2. **If (1) fails**: Prove `targeted_restricted_seed_consistent` using a refined G-lift that handles the mixed seed (g_content + non-G-liftable elements from u) by showing the non-G-liftable elements can be "imported" from u without breaking the argument.

3. **Build forward_F** using the bounded F-nesting argument from `restricted_mcs_F_bounded` combined with weak f_step from deferralDisjunctions.

4. **Build completeness** via `restricted_truth_lemma` directly, bypassing the BFMCS bridge.
