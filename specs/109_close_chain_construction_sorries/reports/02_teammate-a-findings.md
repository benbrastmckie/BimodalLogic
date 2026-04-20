# Teammate A Findings: Primary Implementation Approach

## Key Findings

### Sorry Site Classification by Active Path Impact

**Critical distinction**: Only 5 of the 11 sorry sites are on the active completeness path (`bx_completeness` -> `dd_countermodel`). The other 6 are dead code that can be deleted or left as-is.

#### Active Path Sorries (5 sites in RootScopedChain.lean)

| # | Line | Theorem | Goal State |
|---|------|---------|------------|
| 7 | 1065 | `fwd_chain_forward_F` | `exists m, n < m /\ phi in fwd_chain_of_sigma(m)` given `F(phi) in chain(n)` |
| 8 | 1092 | `dd_bfmcs_restricted_tc` (fwd, t-s<0 case) | `exists s1 > t, phi in shifted_dd_fmcs(s1)` when `F(phi)` is in backward chain region |
| 9 | 1099 | `dd_bfmcs_restricted_tc` (bwd direction) | `exists s1 < t, phi in shifted_dd_fmcs(s1)` when `P(phi)` holds |
| 10 | 1107 | `dd_bfmcs_restricted_buc` | `restricted_backward_until_since_coherent root` |
| 11 | 1114 | `dd_bfmcs_restricted_fuc` | `restricted_forward_until_since_coherent root` |

These 5 are all called by `dd_countermodel` (lines 1139-1142).

#### Dead Code Sorries (6 sites in CanonicalModel.lean)

| # | Line | Theorem | Status |
|---|------|---------|--------|
| 1 | 56 | `enriched_seed_consistent` | **Unused** - no callers outside definition |
| 2 | 101 | `fwd_succ_f_carry` | **Unused** - only called in Boneyard |
| 3 | 117 | `enriched_past_seed_consistent` | **Unused** - no callers outside definition |
| 4 | 167 | `bwd_pred_p_carry` | **Unused** - only called in Boneyard |
| 5 | 207 | `g_content_subset_self` | **Used** - in `fwd_chain_g_content_trans` and `sigma_fwd_g_content_trans` |
| 6 | 213 | `h_content_subset_self` | **Used** - in `bwd_chain_h_content_trans` and `sigma_bwd_h_content_trans` |

**Correction**: #5 and #6 ARE on the active path. `g_content_subset_self` is called by `sigma_fwd_g_content_trans` (line 632, 635) which is called by `dd_chain_g_content` (line 676) which feeds `dd_chain_forward_G`, `dd_chain_h_content`, and ultimately `dd_fmcs` properties. Similarly `h_content_subset_self` feeds the backward chain.

So the actual active-path sorry count is **7**: #5, #6, #7, #8, #9, #10, #11.

Items #1, #2, #3, #4 are dead code and can be deleted immediately.

### Sorry #5 and #6: `g_content_subset_self` / `h_content_subset_self`

**Goal**: `g_content M <= M`, i.e., `G(phi) in M -> phi in M`.

**Status**: Genuinely false under irreflexive semantics. `G(phi)` means "phi holds at all strictly future times" which does NOT imply phi holds now.

**Where used**: The base case of `sigma_fwd_g_content_trans` when `m = n` (proving `g_content(chain(m)) <= chain(m)`). This is needed in two places:
1. `m = n = 0` base case (line 632)
2. `m = n + 1` diagonal case (line 635)

**Key insight**: These uses can be ELIMINATED by restructuring the induction. The `m <= n` transitivity only actually needs the step case `g_content(chain(n)) <= chain(n+1)`, which IS proved (via `preserving_fwd_step_g_content`). The base case `m = n` requires `g_content(chain(m)) <= chain(m)`, but this is only needed when the caller requests `g_content(chain(m)) <= chain(m)` -- which is the reflexive case that should never be needed on the active completeness path.

**Analysis of actual callers of `sigma_fwd_g_content_trans`**: It's called from `dd_chain_g_content` with argument `h_le : t <= t'`. The only place where `t = t'` matters is if the caller passes reflexive arguments. Let me check...

`dd_chain_g_content` is called by:
- `dd_chain_forward_G` with `h_le : t <= t'` (strict `t < t'` would suffice for F-resolution)
- `dd_chain_h_content` via `g_content_subset_implies_h_content_reverse`
- `dd_fmcs` `forward_G` field

The FMCS `forward_G` field requires: `G(phi) in chain(t) -> phi in chain(t')` for `t <= t'`. This is the semantic meaning of G under **reflexive** interpretation. Under irreflexive semantics, the correct version should be `t < t'` (strict).

**Recommended approach**: Change the FMCS `forward_G`/`backward_H` fields from `t <= t'` to `t < t'`, matching the irreflexive semantics. Then `g_content_subset_self` is no longer needed. The chain construction naturally satisfies `g_content(chain(n)) <= chain(n+1)` for strict successor.

**Risk**: This would require updating `FMCS`, `BFMCS`, and all consumers. The `g_content_subset_implies_h_content_reverse` duality might need adjustment.

**Alternative**: Keep `t <= t'` but handle the `t = t'` case separately. When `t = t'`, `G(phi) in chain(t) -> phi in chain(t)` is just `g_content_subset_self`, which we can't prove. But do we actually NEED the reflexive case? If the truth lemma only uses strict ordering for temporal operators...

### Sorry #7: `fwd_chain_forward_F`

**Goal**: Given `F(phi) in fwd_chain_of_sigma(n)` and `phi in sigma_list`, show `exists m > n, phi in chain(m)`.

**Current infrastructure**: The `preserving_fwd_step` already guarantees:
- At each step with active defects, at least one defect `w` is directly resolved (`w in chain(n+1)`)
- ALL F-obligations are preserved (`chi in chain(n+1) \/ F(chi) in chain(n+1)`)

**Proof strategy**: Pigeonhole argument.
- `sigma_list` is finite with `|sigma_list| = k`.
- At each step, active defects form a subset of `sigma_list`.
- If `F(phi)` persists through all steps without phi being resolved, then at every step some OTHER defect w is resolved.
- But a resolved defect w (where `w in chain(n+1)`) may get a NEW `F(w)` obligation in later steps. This is the core difficulty.

**Critical observation**: The `defect_step_early` (line 491) guarantees that at each step, at least one w from the active defects satisfies `w in M'`. But this w might be `phi` itself! The issue is we don't control WHICH w is resolved.

**Better approach**: The `target_stays_direct_in_fold` theorem (line 934) shows that when `target` is `bx11_earlier` than all others, `target in M'` is guaranteed (not just disjunctive). But determining `bx11_earlier` requires case analysis on the BX11 outcome, which is non-deterministic (classical choice).

**Recommended termination argument**:
1. Define `active_defect_count(n) = |{chi in sigma_list | F(chi) in chain(n), chi not_in chain(n)}|`
2. Show: if `active_defect_count(n) > 0`, then `active_defect_count(n+1) < active_defect_count(n)` OR some resolved defect chi satisfies `chi in chain(n+1)`.
3. Problem: a resolved chi might have `F(chi)` re-introduced at a later step. But under the current chain construction, `F(chi) in chain(n+1)` only if `F(chi) in chain(n)` AND the defect step preserves it. Actually, `defect_step_choice_early_spec` only says `chi in M' \/ F(chi) in M'`. If `chi in M'`, that's resolution. If `F(chi) in M'`, the defect persists.

**Key missing piece**: We need that at each step, the count of ACTIVE defects (those with `F(chi) in chain(n)` but `chi not_in chain(n)`) strictly decreases. The `resolving_enriched_fwd_exists` guarantees `w in M'` for some w. If `w` was an active defect (meaning `F(w) in chain(n)` but `w not_in chain(n)`), then at step n+1, w IS in chain(n+1), so w is no longer an active defect. The question is whether OTHER defects can become active.

A defect chi can ONLY be active at step n+1 if `F(chi) in chain(n+1)`. By `preserving_fwd_step_defect_preserved`, if `F(chi) in chain(n)`, then either `chi in chain(n+1)` or `F(chi) in chain(n+1)`. So existing active defects are preserved or resolved. Can NEW defects appear? A formula chi with `F(chi) not_in chain(n)` could have `F(chi) in chain(n+1)` only if... the Lindenbaum extension introduces it. Since the extension is non-deterministic (choice), we can't rule this out in general.

**However**: active defects are only tracked for `chi in sigma_list`. The seed includes `g_content(M)` and explicit formulas. `F(chi) in chain(n+1)` requires `F(chi)` to be in the chosen MCS. New `F(chi)` could appear through the Lindenbaum extension adding arbitrary consistent formulas. So new active defects CAN appear.

**This means simple defect count decrease doesn't work.**

**Alternative termination**: Instead of counting active defects, use the fact that `sigma_list` is finite and the chain is infinite. By the infinite pigeonhole principle: some formula chi appears as the resolved witness `w` infinitely often. But we need a SPECIFIC phi to be resolved, not just some chi.

**Most promising approach for #7**: Well-founded induction on defect multisets, tracking which formulas have been resolved at least once. Since sigma_list is finite, after at most `|sigma_list|` steps of defect resolution, either phi has been resolved, or all other formulas have been resolved leaving phi as the only active defect, at which point it MUST be the resolved witness.

**Detailed argument**:
- After n steps, we track `S(n) = {chi in sigma_list | F(chi) in chain(n)}`.
- At each step, `w in chain(n+1)` for some w in S(n).
- `S(n+1) <= S(n)` (no new F-obligations appear for sigma_list formulas that weren't already F-active).

Wait, is this true? Can new F-obligations appear? `F(chi) in chain(n+1)` requires `F(chi)` in the Lindenbaum extension. The seed contains `g_content(chain(n))`. If `G(F(chi)) in chain(n)`, then `F(chi) in g_content(chain(n)) <= chain(n+1)`. But `G(F(chi)) in chain(n)` means `F(chi)` is G-propagated, which is a very specific condition.

Actually, this is exactly the problem. New F-obligations CAN appear through g_content. If `G(F(chi)) in chain(n)`, then `F(chi) in chain(n+1)`.

**But**: if `G(F(chi)) in chain(n)`, then by temp_4 `G(G(F(chi))) in chain(n)`, so `G(F(chi)) in chain(n+1)` too. This means `F(chi)` is G-propagated and will appear at ALL future steps. So once `G(F(chi))` appears, `F(chi)` is permanent. This is fine -- it means phi is ALWAYS an active defect (if F(phi) appeared via G-propagation), and will ALWAYS get resolved.

But wait -- `F(phi) in chain(n)` and `phi in sigma_list` doesn't tell us HOW `F(phi)` got there. The issue remains.

**Simplest correct approach for #7**: The argument should be:
1. `F(phi) in chain(n)`.
2. At step n, active_defects is non-empty (contains at least phi).
3. The preserving step takes the active defects, applies BX11 fold, resolves one directly.
4. If the resolved one is phi, done.
5. If not, `F(phi) in chain(n+1)` by preservation.
6. Repeat from step n+1.
7. This terminates because... it might not! We're in an infinite loop.

**The real issue**: The chain is infinite but we need a FINITE witness. The termination argument is the crux.

**Breakthrough observation**: At each step, the resolved witness `w` satisfies `w in chain(n+1)`. By the construction, `w` was chosen from the active defects list. If the list is ordered (e.g., by position in sigma_list), and `phi` is first, then... no, the resolving witness comes from the BX11 fold which is non-deterministic.

**Correct approach**: Use the `target_stays_direct_in_fold` theorem. If we can prove that `phi` is `bx11_earlier` than all other active defects, then `phi in chain(n+1)` is guaranteed. But `bx11_earlier` is defined as `F(phi /\ F(other)) in M` which comes from BX11 case 2.

Actually, let's reconsider. The chain construction currently uses `defect_step_early` which doesn't specify WHICH formula gets resolved. We need to modify the chain construction to prioritize the target. This means changing `preserving_fwd_step` to use `target_stays_direct_in_fold` or a similar preferential resolution.

### Sorry #8: `dd_bfmcs_restricted_tc` (backward chain F-case)

**Goal**: When `t - s < 0` (we're in the backward chain region), and `F(phi) in chain(t)`, find `s1 > t` with `phi in chain(s1)`.

**Issue**: The backward chain uses `bwd_pred` (simple non-preserving step). It doesn't have F-preservation infrastructure. But F-formulas in the backward chain can propagate to the forward chain via the boundary at time 0 (= s).

**Strategy**: Since `t - s < 0` means we're at a negative offset, and `F(phi)` says phi holds in the strict future. The chain extends infinitely in both directions. From position t (in backward region), we need phi at some s1 > t. We could use:
1. The forward chain starting from position s (the shifted origin) extends infinitely.
2. `F(phi) in chain(t)` with t in backward region. By BX4 (connect_future), if `F(phi) in chain(t)`, then... actually BX4 says `phi -> G(P(phi))`, not directly useful.
3. `F(phi) in chain(t)` means `phi.some_future in bwd_chain_of_sigma(|t-s|)`. We need to propagate F(phi) from the backward chain to the origin and then into the forward chain where it can be resolved.

**Key path**:
- `F(phi) in chain(t)` (t in backward region)
- We need `F(phi)` to reach chain(s) = M0_origin
- Then from chain(s), F(phi) enters the forward chain where `fwd_chain_forward_F` can resolve it
- But how does F(phi) propagate backward-to-forward? g_content(chain(t)) <= chain(t') for t <= t'. F(phi) is NOT in g_content (g_content only has G-prefixed content).

**This is a deep problem.** F-formulas don't propagate through g_content. The backward chain doesn't preserve F-formulas. So F(phi) in the backward chain is stranded.

**Resolution**: The backward chain needs a symmetric preserving construction (preserving P-obligations). And for the cross-boundary case, we need a different argument.

### Sorry #9: `dd_bfmcs_restricted_tc` (P-direction)

**Goal**: `P(phi) in chain(t) -> exists s1 < t, phi in chain(s1)`.

**Symmetric to #8 but for P-formulas**. The forward chain doesn't have P-preservation, and the backward chain uses simple `bwd_pred` without P-preservation. Same structural issue.

### Sorry #10: `dd_bfmcs_restricted_buc`

**Goal**: `restricted_backward_until_since_coherent root`.

This requires: if `exists s > t, psi in chain(s) /\ forall r, t <= r < s -> phi in chain(r)`, then `untl phi psi in chain(t)`.

This is a SEMANTIC property: if Until is witnessed, then Until holds. For canonical models, this is typically proved by:
- `BX9 (until_elim): (phi U psi) -> (phi \/ psi)` -- the elimination direction
- We need the INTRODUCTION direction: witnesses -> Until-membership in MCS

**Standard approach**: Use the fact that MCS are maximal, so if `untl phi psi not_in chain(t)`, then `neg(untl phi psi) in chain(t)`, and derive a contradiction using the Until axioms to show the witness can't exist.

This requires careful reasoning with BX axioms (BX2-BX7, BX9-BX12) and the chain construction. The argument goes: if `neg(phi U psi) in chain(t)`, then by BX12 contrapositive and BX10 contrapositive, we can show that the witness can't exist.

### Sorry #11: `dd_bfmcs_restricted_fuc`

**Goal**: `restricted_forward_until_since_coherent root`.

This requires: if `untl phi psi in chain(t)`, then `exists s > t, psi in chain(s) /\ forall r, t <= r < s -> phi in chain(r)`.

This is the EXISTENCE direction of Until coherence. It's harder than #10 because it requires constructing a witness. Key ingredients:
- BX10: `(phi U psi) -> F(psi)` gives `F(psi) in chain(t)`
- BX9: `(phi U psi) -> (phi \/ psi)` gives phi or psi holds now
- BX5: self-accumulation ensures the Until persists at intermediate points
- The chain construction must eventually resolve F(psi) to get psi at some future time s

This depends on #7 (fwd_chain_forward_F) for getting the psi-witness, and then needs to show the guard phi holds at all intermediate points. The guard persistence follows from BX5 (self-accumulation) + the chain preserving g_content.

## Recommended Approach

### Phase 1: Delete Dead Code (4 sorries eliminated trivially)

Delete `enriched_seed_consistent`, `fwd_succ_f_carry`, `enriched_past_seed_consistent`, `bwd_pred_p_carry` from CanonicalModel.lean. These are unused on the active path.

**Confidence**: HIGH

### Phase 2: Fix `g_content_subset_self` / `h_content_subset_self` (2 sorries)

Two sub-approaches:

**Option A (Recommended): Restructure the transitivity induction.**

The `sigma_fwd_g_content_trans` induction currently needs `g_content_subset_self` for the `m = n` case. Restructure to only prove `m < n -> g_content(chain(m)) <= chain(n)` (strict inequality). The `m = n` case is never needed if we audit callers.

Check: `dd_chain_g_content` passes `h_le : t <= t'`. Can we change to `t < t'`? The FMCS `forward_G` field requires `t <= t'`. Under irreflexive semantics, `G(phi) in chain(t)` should give `phi in chain(t')` only for `t' > t`. So the FMCS definition should use strict `<`.

The change cascade:
1. `FMCS.forward_G`: change `t <= t'` to `t < t'`
2. `FMCS.backward_H`: change `t' <= t` to `t' < t`
3. Update all FMCS constructions
4. Update the truth lemma (which evaluates G as "for all strictly future")
5. `sigma_fwd_g_content_trans` only needs `m < n` case
6. Remove `g_content_subset_self` and `h_content_subset_self`

**Risk**: Medium-high. Cascading changes through FMCS/BFMCS/truth lemma.

**Option B: Alternative base case proof.**

Instead of proving `g_content(M) <= M` (false), prove that the chain construction satisfies a weaker property that suffices for the callers. For example, proving `g_content(chain(m)) <= chain(n)` for `m <= n` directly without the reflexive base case, using `G(phi) -> G(G(phi))` to propagate through induction steps.

Actually, re-examining the induction: when `m = n = 0`, we need `g_content(chain(0)) <= chain(0)`, which IS `g_content_subset_self` and IS false. But when is this case actually reached? Only when a caller requests `g_content(chain(0)) <= chain(0)`. If we ensure callers always request strict `m < n`, the base case is never hit.

**Confidence**: MEDIUM (depends on successfully auditing all callers)

### Phase 3: Solve `fwd_chain_forward_F` (#7)

**Approach**: Modify the chain construction to use a deterministic round-robin that guarantees each sigma_list formula is eventually the designated target.

Current construction: at each step, if there are active defects, resolve one (non-deterministic which one). If no defects, round-robin through sigma_list.

Modified construction: at each step, the round-robin target is `sigma_list[n % |sigma_list|]`. If the target has an F-obligation (`F(target) in chain(n)`), use `target_stays_direct_in_fold` to guarantee `target in chain(n+1)`. If not, use regular `fwd_succ`.

This way, every `|sigma_list|` steps, each formula gets a chance to be the priority target. If `F(phi) in chain(n)`, then at step `m = n + (k * |sigma_list|)` where k is chosen so `m % |sigma_list| = phi's index`, phi is the priority target and gets resolved.

But we need F(phi) to persist until step m. By `preserving_fwd_step_defect_preserved`, F-obligations are preserved one step at a time. If we can show F(phi) persists for `|sigma_list|` steps (or is resolved earlier), we're done.

**Better**: Use the existing `preserving_fwd_step` but with a modified priority selection. Instead of non-deterministic resolution, always resolve the target corresponding to the current round-robin index. Use `target_stays_direct_in_fold` with the round-robin target.

This requires changing `preserving_fwd_step` to be target-aware.

**Confidence**: MEDIUM-HIGH (the mathematical argument is sound; implementation requires chain construction refactoring)

### Phase 4: Build Symmetric Backward Infrastructure (#8, #9)

The backward chain (`bwd_chain_of_sigma`) currently uses simple `bwd_pred` without P-preservation. Build a symmetric `preserving_bwd_step` that:
1. Tracks active P-defects: `{chi | P(chi) in chain(n)}`
2. Uses BX11' (past linearity) fold to resolve one P-defect per step while preserving all others
3. Proves `bwd_chain_backward_P`: `P(phi) in chain(n) -> exists m > n, phi in chain(m)` (where m is backward step index)

This requires:
- `enriched_resolving_seed_consistent` for the past direction (using `past_temporal_witness_seed_consistent`)
- Past linearity fold analogous to `enriched_fwd_fold`
- `resolving_enriched_bwd_exists` analogous to `resolving_enriched_fwd_exists`

For the cross-boundary cases (#8: F in backward region, #9: P in forward region):
- F(phi) in backward chain at time t -> need phi at some t' > t
  - If t' can be in the forward chain region: need F(phi) to reach the origin, then enter forward chain
  - Alternative: extend the backward chain to also preserve F-formulas (via including f_carry in backward seeds)
- P(phi) in forward chain at time t -> need phi at some t' < t
  - Symmetric: need P(phi) to reach origin, then enter backward chain

**Confidence**: MEDIUM (substantial new code but follows existing patterns)

### Phase 5: Until/Since Coherence (#10, #11)

**#10 (backward Until coherence)**: If the Until witness exists in the chain, then Until is in the MCS.

Proof sketch: By maximality of MCS. If `untl phi psi not_in chain(t)`, then `neg(untl phi psi) in chain(t)`. Need to derive contradiction from the existence of witness s with `psi in chain(s)` and guard phi on [t,s).

Use BX axioms to show: `neg(phi U psi) in chain(t)` and `psi in chain(s)` for some s > t with phi on [t,s) leads to contradiction. The argument uses induction on s - t:
- Base: if s = t+1, `phi U psi` holds trivially (psi at next step, guard phi at t by BX9)
- Step: `neg(phi U psi) in chain(t)` and connectedness axioms...

Actually this is more subtle. The standard argument: MCS are deductively closed. If `exists s > t, psi(s) /\ forall r in [t,s), phi(r)`, we need to show `(phi U psi) in chain(t)`. This is the step transfer property.

**#11 (forward Until coherence)**: If `(phi U psi) in chain(t)`, construct the witness.

Approach:
1. `(phi U psi) in chain(t)` -> by BX10, `F(psi) in chain(t)`
2. By `fwd_chain_forward_F` (#7), exists s > t with `psi in chain(s)`.
3. Need: guard phi holds on [t,s).
4. By BX5 (self-accumulation): `(phi U psi) -> ((phi /\ (phi U psi)) U psi)`.
5. By BX9 (until_elim): `(phi U psi) -> phi \/ psi`. So phi holds at t.
6. By g_content propagation: `G(phi U psi -> phi) in chain(t)` (by BX9 internalized via G-distribution).
7. Actually, `(phi U psi) in chain(t)` doesn't propagate to chain(t+1) via g_content. g_content only propagates G-wrapped formulas.

This is the fundamental difficulty: Until formulas don't propagate through the chain automatically. The chain construction only guarantees g_content (G-formulas) propagation and F-defect preservation. Until formulas need separate treatment.

**Confidence**: LOW-MEDIUM (Until coherence is the hardest part; may require significant chain redesign)

## Evidence/Examples

### BX Axioms Relevant to This Task

| Axiom | Statement | Role |
|-------|-----------|------|
| BX1 (serial_future) | `T -> F(T)` | Seriality (consistency of g_content) |
| BX1' (serial_past) | `T -> P(T)` | Seriality (consistency of h_content) |
| BX5 (self_accum_until) | `(phi U psi) -> ((phi /\ phi U psi) U psi)` | Guard persistence for Until |
| BX9 (until_elim) | `(phi U psi) -> (phi \/ psi)` | Current-time extraction |
| BX10 (until_F) | `(phi U psi) -> F(psi)` | Eventuality extraction |
| BX11 (temp_linearity) | `F(a) /\ F(b) -> F(a/\b) \/ F(a/\F(b)) \/ F(F(a)/\b)` | F-witness ordering |
| BX12 (F_until_equiv) | `F(phi) -> (T U phi)` | F-to-Until bridge |
| temp_4 | `G(phi) -> G(G(phi))` | G-transitivity |

### Existing Infrastructure That Can Be Reused

1. `resolving_enriched_fwd_exists` - BX11 fold with guaranteed direct witness
2. `target_stays_direct_in_fold` - Priority resolution when target is bx11_earlier
3. `defect_step_early` / `defect_step_choice_early` - Non-deterministic defect resolution
4. `preserving_fwd_step_defect_preserved` - One-step F-preservation
5. `FF_imp_F` / `FF_imp_F_mcs` - F(F(psi)) -> F(psi) collapse
6. `F_conj_left_mcs` / `F_conj_right_mcs` - F-monotonicity for conjunctions
7. `g_content_set_consistent` / `h_content_set_consistent` - Seriality-based consistency

### Key Definitions

- `g_content(M) = {phi | G(phi) in M}` - the "G-interior"
- `h_content(M) = {phi | H(phi) in M}` - the "H-interior"
- `f_carry(M) = {phi in M | exists chi, phi = F(chi)}` - F-formulas in M
- `active_defects(M, sigma) = {chi in sigma | F(chi) in M}` - unresolved F-obligations
- `fwd_chain_of_sigma` - iterates preserving_fwd_step
- `bwd_chain_of_sigma` - iterates bwd_pred (simple, no P-preservation)

## Confidence Levels

| Sorry | Approach | Confidence | Notes |
|-------|----------|------------|-------|
| #1-4 | Delete (dead code) | HIGH | Verified unused on active path |
| #5-6 | Restructure induction or change FMCS to strict | MEDIUM | Cascading changes through FMCS |
| #7 | Priority round-robin + pigeonhole | MEDIUM-HIGH | Sound math, needs chain refactor |
| #8-9 | Symmetric backward infrastructure + cross-boundary | MEDIUM | Substantial new code |
| #10 | MCS maximality argument | MEDIUM | Standard but needs careful axiom reasoning |
| #11 | BX10 + #7 + guard persistence | LOW-MEDIUM | Hardest; Until propagation through chain |

## Summary of Recommended Priority

1. **Immediate wins**: Delete #1-4 (dead code) -> 4 sorries gone
2. **FMCS redesign**: Fix #5-6 by changing to strict ordering -> 2 sorries gone
3. **Chain refactor**: Fix #7 with priority resolution -> 1 sorry gone
4. **Backward chain**: Build symmetric P-preserving backward chain for #8-9 -> 2 sorries gone
5. **Until coherence**: Fix #10-11 using MCS properties + BX axioms -> 2 sorries gone

The total dependency order is: (#1-4) independent; (#5-6) independent; (#7) before (#8,#9,#11); (#10) independent of #7; (#11) depends on (#7, #10).
