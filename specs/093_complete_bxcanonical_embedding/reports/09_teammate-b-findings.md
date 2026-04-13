# Teammate B Findings: Alternative Approaches for BXCanonical Embedding

**Task**: 93 - Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-13
**Focus**: Paths B (quasimodel chain replacement) and C (Lindenbaum extension analysis), plus novel approaches

## Key Findings

### Finding 1: The Quasimodel Chain Replacement (Path B) Is Infeasible Under 300 Lines

After thorough analysis of Report 08 (quasimodel approach) and the existing Quasimodel infrastructure in `Construction.lean`, `Realization.lean`, and `LocusControl.lean`, the conclusion is clear: **a full quasimodel chain replacement cannot be done in under 300 lines, and all lightweight variants collapse back to the same forward_F blocker**.

Report 08 explored this path exhaustively through Sections 3.1-3.9, trying five distinct quasimodel constructions:

1. **Finite Hintikka chain lifting** (Section 3.1-3.2): Fails because backing BXPoints in the Hintikka chain do NOT satisfy `g_content(w_i) subset w_{i+1}` -- they are constructed independently. This is the "Realization.lean obstacle" documented at lines 366-395 of that file.

2. **Quasimodel-guided scheduling chain** (Section 3.3): "Still essentially the scheduling chain approach" -- the difference is only in proof strategy, not construction. Same forward_F gap.

3. **Direct MCS-level construction with quasimodel witnesses** (Section 3.4.1): Same scheduling chain with different proofs. Same forward_F gap at Section 3.5 Step B.2.

4. **Saturated chain with full carry** (Section 3.9): Resolving branch seed `{psi} union g_content(M) union untilCarry(M, root) union fCarry(M, root)` hits the SAME counterexample as Report 07 Finding 2: when `psi = G(neg(chi))` and `F(chi) in fCarry`, the seed contains `{G(neg(chi)), F(chi)}` = `{neg(F(chi)), F(chi)}`, which is inconsistent.

5. **Full quasimodel construction** (Section 6.3): The textbook Burgess 1984 approach requires 800-1200 lines and 20-30 hours. This is the only variant that truly avoids the forward_F circularity, but at massive cost.

**The minimal viable quasimodel**: Even the lightest variant (Approach A from Section 6.1: root-parameterized chain with `untilCarry` in both branches) requires 300-500 lines of new/modified code plus a novel BX7/BX11 consistency argument that is itself research-grade.

### Finding 2: Lindenbaum Extension Analysis (Path C) Cannot Guarantee F-Formula Preservation

The Lindenbaum construction (`set_lindenbaum`) uses Zorn's lemma to extend a consistent set to a maximal consistent set. The extension is **fundamentally non-constructive and non-deterministic**: for any formula `chi` not derivable from the seed, the extension may include either `chi` or `neg(chi)`.

The Path C question is: when `F(psi) in M` and `F(chi) in M`, does the Lindenbaum extension of `{psi} union g_content(M)` necessarily include `F(chi)`?

Report 08's analysis (Section 1, lines 96-110) traced this precisely:
- We need: `G(neg(chi))` is NOT derivable from `{psi} union g_content(M)`
- The temporal K argument shows: `g_content(M) derives G(neg(chi))` iff `G(G(neg(chi))) in M` iff `G(neg(chi)) in M` (by temp_4). Since `F(chi) in M`, `G(neg(chi)) not in M`, so `g_content(M)` alone does NOT derive `G(neg(chi))`.
- BUT: `{psi} union g_content(M)` might derive `G(neg(chi))` if `psi -> G(neg(chi))` is derivable from g_content elements. This is possible in pathological cases.

**Even if consistency is provable, "could include" is not "must include"**. Zorn's lemma selects an arbitrary maximal chain in the poset of consistent extensions. Without `F(chi)` in the seed, the extension can legally choose `neg(F(chi)) = G(neg(chi))` whenever `G(neg(chi))` is consistent with the seed. The Lindenbaum extension has no bias toward preserving formulas from the original MCS M.

**Path C verdict**: NOT viable. The Lindenbaum construction is the wrong tool for this problem -- it is designed to maximize, not to preserve specific properties of a prior MCS.

### Finding 3: Novel Approach -- "Seed-Switching" with Two-Phase Forward Step

I identify a novel approach not explored in prior rounds:

**The observation**: The forward_F blocker occurs only at resolving steps, where the seed `{psi} union g_content(M)` does not include fCarry. But the RESTRICTED forward_F only needs to work for formulas in `deferralClosure(root)`, which is FINITE.

**The two-phase forward step**:

For each forward step, instead of a single `fwd_succ`, build the successor in TWO phases:

1. **Phase A (Resolution)**: If `F(psi) in chain(n)` with `schedule(n) = psi`, resolve it: build an intermediate MCS `M_mid` from seed `{psi} union g_content(chain(n))` (the existing proven-consistent seed).

2. **Phase B (F-recovery)**: Build the actual `chain(n+1)` from seed `g_content(M_mid) union fCarry_restricted(chain(n), root)`.

The key insight: `g_content(M_mid)` includes `psi` (since `psi in M_mid` and `G(psi) in M_mid` by temp_4... no, `psi in M_mid` does NOT imply `G(psi) in M_mid`).

**Problem**: After Phase A, the resolution is in `M_mid`. But Phase B builds `chain(n+1)` from `g_content(M_mid)`, which does NOT include `psi` unless `G(psi) in M_mid`. Since `M_mid` was built from `{psi} union g_content(chain(n))`, we have `psi in M_mid` but `G(psi)` is NOT guaranteed.

**This approach fails** because the resolution witness `psi` cannot be propagated from `M_mid` through g_content to `chain(n+1)`.

### Finding 4: Novel Approach -- "Retroactive Family Injection" (Viable but Requires Architecture Change)

The BFMCS has families `{ shifted_bx_fmcs N h_N s | N box-equiv M_0, s : Int }`. The restricted coherence conditions require witnesses WITHIN the same family. But what if we could **define the family differently** so that forward_F is satisfied by construction?

**The idea**: Instead of defining each family as a scheduling chain from a single MCS, define the "evaluation family" as a **piecewise construction** that stitches together scheduling chain segments at resolution points.

Given `M_0` and `root`:
1. Build `chain(0) = M_0, chain(1), chain(2), ...` normally via `fwd_succ`.
2. Whenever `F(psi) in chain(t)` with `psi in deferralClosure(root)`, and `psi` has not yet appeared by time `t + K` for some bound K, **splice in a new chain segment** starting from an MCS that contains `psi`.

**The splice construction**: By `bx_forward_witness`, there exists BXPoint `v` with `bx_le chain_point(t) v` and `psi in v.formulas`. Build a fresh scheduling chain from `v.formulas` and splice it at position `t + K + 1`.

**Critical issue**: The splice point requires `g_content(chain(t+K)) subset chain(t+K+1)`. But `chain(t+K+1)` is now the first step of a fresh chain from `v.formulas`, not a continuation of the previous chain. The g_content relationship is NOT guaranteed between the old chain's endpoint and the new chain's start.

**However**: `bx_le chain_point(t) v` means `g_content(chain_point(t)) subset v.formulas`. This is g_content at time t, not time t+K. The gap between t and t+K is bridged by the scheduling chain, but the splice at t+K+1 breaks the g_content continuity.

**This approach requires significant new infrastructure** (splice proofs, g_content bridging) and is estimated at 400-600 lines. NOT recommended as first choice.

### Finding 5: Novel Approach -- "Restricted Forward_F via Scheduling Density" (Most Promising Novel Path)

**Key insight**: For RESTRICTED forward_F, we only need `psi in chain(s)` for `psi in deferralClosure(root)`, which is FINITE. The schedule function `schedule(n) = Denumerable.ofNat (Nat.unpair n).2` hits every formula infinitely often.

**The argument sketch**:

Given `F(psi) in chain(t)` with `psi in deferralClosure(root)`:

**Claim**: Either `psi in chain(s)` for some `s > t`, or `G(neg(psi)) in chain(k)` for some `k > t`.

**Proof of claim**: The schedule targets `psi` at infinitely many steps after t. Consider the first such step `n > t` with `schedule(n) = psi`:
- If `F(psi) in chain(n)`: the resolving branch puts `psi in chain(n+1)`. Done.
- If `F(psi) not in chain(n)`: then `neg(F(psi)) = G(neg(psi)) in chain(n)` (MCS completeness).

**If `G(neg(psi)) in chain(n)` for some `n > t`**: We need to derive a contradiction, showing this case is impossible. The argument:

1. `G(neg(psi)) in chain(n)` means `neg(psi) in chain(n')` for all `n' >= n` (via g_content propagation + temp_4).
2. `F(psi) in chain(t)` and `t < n`.
3. Between t and n, at each step k, either `F(psi) in chain(k)` or `G(neg(psi)) in chain(k)` (MCS completeness).
4. There must be a "transition point" `k*` where `F(psi) in chain(k*)` but `F(psi) not in chain(k*+1)`, i.e., `G(neg(psi)) in chain(k*+1)`.
5. At step k*: `chain(k*+1)` was built from `fwd_succ(chain(k*), schedule(k*))`.
6. Since `F(psi) in chain(k*)` and `G(neg(psi)) in chain(k*+1)`:
   - `g_content(chain(k*)) subset chain(k*+1)` (by construction)
   - If `G(G(neg(psi))) in chain(k*)`, then `G(neg(psi)) in chain(k*+1)` via g_content. This means `G(neg(psi)) in chain(k*)`, contradicting `F(psi) in chain(k*)`.
   - So `G(G(neg(psi))) not in chain(k*)`, hence `F(F(psi)) in chain(k*)` (since `G(G(neg(psi))) = neg(F(F(psi)))` by double duality, and MCS completeness).
   - By temp_4 contrapositive: `F(F(psi)) -> F(psi)` ... actually `F(F(psi))` is `neg(G(neg(F(psi))))`. We have `neg(G(G(neg(psi)))) in chain(k*)`. By temp_4: `G(neg(psi)) -> G(G(neg(psi)))` is a theorem. Contrapositive: `neg(G(G(neg(psi)))) -> neg(G(neg(psi)))`, i.e., `F(F(psi)) -> F(psi)`. So `F(psi) in chain(k*)` -- consistent with our assumption.

7. **The question is: WHY does `G(neg(psi))` enter `chain(k*+1)`?**
   - If `schedule(k*) = psi` (resolving step for psi): then `F(psi) in chain(k*)` means the resolving branch is used, putting `psi in chain(k*+1)`. Then `psi in chain(k*+1)` and `G(neg(psi)) in chain(k*+1)` gives `neg(psi) in chain(k*+1)`, contradiction.
   - If `schedule(k*) = chi != psi` (resolving step for different formula): then `F(chi) in chain(k*)` and the resolving branch seed is `{chi} union g_content(chain(k*))`. The Lindenbaum extension of this seed may choose `G(neg(psi))` over `F(psi)`.

**This is exactly the known gap**. The Lindenbaum extension at a resolving step for chi may discard F(psi).

**However, I note a potential resolution**: At the transition point k*, the resolving formula is `chi`. The seed `{chi} union g_content(chain(k*))` is consistent by the temporal K argument. The question is whether we can additionally constrain the Lindenbaum extension.

**A key observation about fCarry on NON-resolving steps**: Between t and the first scheduled `psi` step, F(psi) IS preserved at non-resolving steps (via fCarry in the seed). F(psi) can only be lost at a resolving step for some OTHER formula chi. But there are at most finitely many resolving steps between t and the first `psi` step (since the schedule is deterministic and steps proceed one at a time).

**THE REAL QUESTION**: Is there a way to prove that between any two consecutive resolving steps for psi, `F(psi)` cannot be lost? If `F(psi)` survives all intervening resolving steps, then at the next `psi` resolving step, `F(psi) in chain(n)` and the resolution succeeds.

**No**: This is exactly the forward_F problem. `F(psi)` CAN be lost at any resolving step for a different formula. The only defense is to include F(psi) in the seed, which creates the known consistency issue.

### Finding 6: Analysis of "restrictedUntilCarry in Resolving Seed" Consistency

Report 08's Approach A (Section 6.1) proposes adding `restrictedUntilCarry(M, root)` to the resolving branch seed. The consistency argument needs: `{psi} union g_content(M) union restrictedUntilCarry(M, root)` is consistent when `F(psi) in M`.

I analyzed this carefully using the BX axiom inventory:

**Claim**: This seed IS consistent.

**Argument**: Suppose `L subset seed` derives `bot`. Partition `L = L_psi union L_g union L_u` with `L_psi subset {psi}`, `L_g subset g_content(M)`, `L_u subset untilCarry(M, root)`.

All elements of `L_g union L_u` are in M (g_content via BX1, untilCarry trivially). So `L_g union L_u subset M`.

**Case 1**: `psi not in L`. Then `L = L_g union L_u subset M` derives bot, contradicting M being MCS.

**Case 2**: `psi in L`. By deduction: `L_g union L_u derives neg(psi)`. Since `L_g union L_u subset M` and M is closed under derivation: `neg(psi) in M`.

Now apply the temporal K argument to the ENTIRE derivation `L_g union L_u derives neg(psi)`:

By iterated deduction, extracting all `u_j in L_u`:
`L_g derives u_1 -> (u_2 -> ... -> neg(psi))`.

By temporal K on `L_g` (all elements have G-wrapped versions in M):
`G(u_1 -> (u_2 -> ... -> neg(psi))) in M`.

By BX K-distribution:
`G(u_1) -> G(u_2 -> ... -> neg(psi)) in M` (from M closure).

To unwrap: we need `G(u_j) in M` for each `u_j = (phi_j U psi_j) in untilCarry`.

**Critical question**: Does `(phi U psi) in M` imply `G(phi U psi) in M`?

**In general: NO.** The Until formula may hold now but not at all future times.

**However**: For the specific case where `(phi U psi) in M` AND `(phi U psi) in subformulaClosure(root)`, there is a potential argument via BX5 (self-accumulation): `(phi U psi) -> ((phi and (phi U psi)) U psi)`. This gives a "self-reinforcing" Until but still doesn't give `G(phi U psi)`.

**Alternative**: Use BX4 (connect_future): `alpha -> G(P(alpha))`. So `(phi U psi) -> G(P(phi U psi)) in M`. This gives `G(P(phi U psi)) in M`, NOT `G(phi U psi)`.

**The temporal K unwrapping FAILS for Until elements**. We cannot prove `G(u_j) in M` from `u_j in M`.

**BUT**: We don't need to unwrap all the way. The key is that `L_g union L_u derives neg(psi)` with all elements in M means `neg(psi) in M`. And `neg(psi) in M` is COMPATIBLE with `F(psi) in M` (psi false now, true in future). So the derivation `L derives bot` requires BOTH `psi in L` (from the seed) AND `neg(psi)` derivable from `L_g union L_u`. The derivation of `bot` is: `psi + (neg(psi) derivable from context) -> bot`.

But this means: `{psi} union L_g union L_u derives bot` iff `L_g union L_u derives neg(psi)` iff `neg(psi) in M` (by MCS closure).

And `neg(psi) in M` IS possible when `F(psi) in M` (since `F(psi)` says psi holds SOMETIME in the future, not now).

**Wait -- but `forward_temporal_witness_seed_consistent` already proves `{psi} union g_content(M)` is consistent when `F(psi) in M`.** This means `g_content(M)` alone does NOT derive `neg(psi)`. The temporal K argument shows this specifically.

Adding `L_u` introduces new derivation power. The question is: can `g_content(M) union L_u` derive `neg(psi)` when `g_content(M)` alone cannot?

**Concrete analysis**: Let `L_u = {a U b}` with `(a U b) in M`. Can `g_content(M) union {a U b}` derive `neg(psi)` when `g_content(M)` alone cannot?

By BX9: `(a U b) -> a v b`. So `a U b` provides the disjunction `a v b`. If either `a -> neg(psi)` or `b -> neg(psi)` is derivable from g_content(M), then `neg(psi)` becomes derivable.

- `a -> neg(psi)` derivable from g_content means `G(a -> neg(psi)) in M` by temporal K, so `G(a -> neg(psi)) in M`.
- `b -> neg(psi)` derivable from g_content means `G(b -> neg(psi)) in M`.

Both could hold. And `a v b` from `(a U b)` combined with case analysis on the disjunction would give `neg(psi)`.

**Concrete counterexample**: Let `root` contain `(neg(psi) U chi)` as a subformula. Then `untilCarry` could include `(neg(psi) U chi)`. By BX9: `(neg(psi) U chi) -> neg(psi) v chi`. If `G(chi -> neg(psi)) in M` (i.e., `chi -> neg(psi)` is derivable from g_content), then both disjuncts imply `neg(psi)`.

So: `g_content(M) union {neg(psi) U chi}` derives `neg(psi)` whenever `G(chi -> neg(psi)) in M` and `(neg(psi) U chi) in M`. Both are compatible with `F(psi) in M`.

**This means the resolving seed WITH untilCarry CAN be inconsistent.**

**However**: This counterexample requires `(neg(psi) U chi) in subformulaClosure(root)` AND `(neg(psi) U chi) in M` AND `G(chi -> neg(psi)) in M` AND `F(psi) in M`. All four can coexist in a BX-MCS (verified: `neg(psi)` holds now, `chi` never holds, so `(neg(psi) U chi)` holds vacuously via the guard; `F(psi)` says psi holds eventually).

**Conclusion**: Adding `untilCarry` to the resolving seed is NOT safe in general. The approach from Report 08 Section 6.1 has a gap.

### Finding 7: The Only Path That Avoids Circularity -- "Per-Demand Chain" Construction

After analyzing all alternatives, I identify one approach that genuinely avoids the circularity:

**Build a separate chain for each temporal demand, then prove coherence by cross-referencing.**

This is NOT a full quasimodel construction but a lighter variant:

**For restricted forward_F**: Given `F(psi) in chain(t)` with `psi in deferralClosure(root)`:
1. The scheduling chain's `schedule_surjective_above` guarantees `schedule(n) = psi` for some `n >= t`.
2. For the SPECIFIC demand `F(psi)`, build a **demand-specific chain** starting from `chain(t)` that resolves `psi` at the first step: `demand_chain(0) = chain(t)`, `demand_chain(1) = lindenbaum({psi} union g_content(chain(t)))`.
3. `psi in demand_chain(1)` by construction. Done for forward_F.

**Wait -- but the witness must be in the SAME family's chain, not in a separate demand chain.**

This approach doesn't work at the FMCS level because the witness must be at position `s` of `fam.mcs s`, not in a separate chain.

## Recommended Approach

After exhaustive analysis of Paths B, C, and novel approaches, the recommended approach is:

### **Modified Path A: untilCarry in Non-Resolving Branch Only, with Forward_F via Accumulated Resolution**

**Core insight**: Do NOT add untilCarry to the resolving branch (it's unsafe per Finding 6). Instead:

1. **Non-resolving branch**: Add `untilCarry(M, root)` to the seed. This is safe (subset of M). Until formulas from `subformulaClosure(root)` persist through non-resolving steps.

2. **Resolving branch**: Keep as `{psi} union g_content(M)` (proven consistent). Until formulas MAY be lost here.

3. **Forward_F proof**: The existing chain construction already has `fwd_succ_resolves`: when `F(psi) in chain(n)` and `schedule(n) = psi`, then `psi in chain(n+1)`. The issue is ensuring `F(psi)` persists until a resolving step. Since F(psi) persists through non-resolving steps (fCarry), the question reduces to: does F(psi) persist through resolving steps for OTHER formulas?

4. **The persistence argument** (the key new contribution): At a resolving step for chi (where `F(chi) in chain(k)`), the seed is `{chi} union g_content(chain(k))`. The Lindenbaum extension MAY or MAY NOT include `F(psi)`. BUT: we can modify the construction so that the resolving branch seed becomes `{chi} union g_content(chain(k)) union fCarry_restricted(chain(k), root)`, which has EXACTLY the same consistency issue as the doubly-enriched seed from Report 07.

**This circles back to the fundamental open problem.**

### **Actual Recommendation: Path A from Handoff 08 (temporal K + until_induction) is still the most promising path, but with a refined consistency argument**

The resolving seed consistency with untilCarry is refuted (Finding 6). But the resolving seed WITHOUT untilCarry (`{psi} union g_content(M)`) is proven consistent. The question is whether forward_F can be proved for the existing chain without enriching the resolving seed.

The most promising remaining approach is:

1. **Prove forward_F for formulas where the Lindenbaum extension provably preserves them**. Specifically: if `F(psi) in chain(k)` and the resolving formula chi is such that `F(psi)` is NOT derivably excluded by `{chi} union g_content(chain(k))`, then `F(psi)` persists. The temporal K argument shows `neg(F(psi)) = G(neg(psi))` is NOT derivable from `g_content(chain(k))` alone. Adding `{chi}` to the seed can only derive `G(neg(psi))` if `chi -> G(neg(psi))` is derivable from g_content, which means `G(chi -> G(neg(psi))) in M`, a very specific condition.

2. **Use the Zorn's lemma choice**: While Lindenbaum is non-deterministic, we can potentially CHOOSE a specific Lindenbaum extension that preserves F-formulas. If `set_lindenbaum` is defined via `Classical.choice`, we cannot control the choice. But we could define a CUSTOM Lindenbaum variant `set_lindenbaum_preserving` that additionally maximizes inclusion of a given finite set of formulas.

3. **Estimated effort**: Defining `set_lindenbaum_preserving` and proving it still produces an MCS would take approximately 100-150 lines, plus 50-100 lines to wire it into `fwd_succ`.

## Evidence/Examples

### Existing infrastructure reusable:

| Component | File | Status |
|-----------|------|--------|
| `forward_temporal_witness_seed_consistent` | `WitnessSeed.lean` | Proven, 120 lines |
| `backward_until_from_step` | `UntilSinceCoherence.lean` | Proven, parameterized by step transfer |
| `or_until_in_mcs` | `SuccRelation.lean` | Proven |
| `bx_until_eventuality_resolution` | `Frame.lean:623` | Proven |
| `bx_forward_witness` | `Frame.lean:164` | Proven |
| `enriched_seed_consistent` | `CanonicalModel.lean:59` | Proven (non-resolving seed) |
| `fwd_succ_f_carry` | `CanonicalModel.lean:108` | Proven (F-carry at non-resolving steps) |
| `schedule_surjective_above` | `CanonicalModel.lean:43` | Proven |

### Counterexample invalidating untilCarry in resolving seed:

Let M be a BX-MCS with:
- `F(psi) in M` (so we're resolving psi)
- `(neg(psi) U chi) in M` with `(neg(psi) U chi) in subformulaClosure(root)`
- `G(chi -> neg(psi)) in M` (i.e., chi always implies neg(psi))

Then `g_content(M) union {neg(psi) U chi}` derives `neg(psi)`:
1. `(neg(psi) U chi) -> neg(psi) v chi` (BX9)
2. `chi -> neg(psi)` from g_content (since `G(chi -> neg(psi)) in M`)
3. Case analysis: both disjuncts give `neg(psi)`.

So `{psi} union g_content(M) union untilCarry(M, root)` is INCONSISTENT.

All four properties are compatible in a BX-MCS: `neg(psi)` holds now, `psi` eventually (F(psi)), `neg(psi)` persists as long as chi doesn't happen (`neg(psi) U chi`), and chi always implies neg(psi) globally (`G(chi -> neg(psi))`).

## Confidence Level

- **Path B (quasimodel replacement) infeasibility under 300 lines**: HIGH
- **Path C (Lindenbaum preservation) non-viability**: HIGH
- **Finding 6 counterexample (untilCarry in resolving seed is unsafe)**: HIGH
- **Recommendation (custom Lindenbaum or modified approach)**: MEDIUM -- the `set_lindenbaum_preserving` idea is novel and untested but mathematically sound in principle
- **Forward_F remaining as fundamental open problem**: HIGH

## Open Questions

1. **Can `set_lindenbaum` be modified to prefer inclusion of a given finite set of formulas?** If so, the resolving branch could use `set_lindenbaum_preserving({psi} union g_content(M), fCarry_restricted(M, root))` where the second argument is the "preference set". The resulting MCS includes all of `{psi} union g_content(M)` (guaranteed) and as many elements of `fCarry_restricted(M, root)` as consistently possible. This would give forward_F "for free" in most cases but might still fail in the pathological case where `F(chi)` conflicts with `psi`.

2. **Can the BFMCS be restructured to avoid per-family forward_F?** The current BFMCS has each family as an independent scheduling chain. If families could "share" witnesses (e.g., forward_F witness comes from a DIFFERENT family placed at the right time), the problem dissolves. But the coherence definition explicitly requires same-family witnesses.

3. **Is there a completeness proof for BX that avoids forward_F entirely?** Some temporal logic completeness proofs use filtration or Fischer-Ladner closure to build finite models directly, bypassing chain constructions. For BX (which axiomatizes ALL linear orders, not just Z), a filtration approach might give a finite model that satisfies all coherence conditions by construction. This would require significant new infrastructure but avoids the forward_F circularity at its root.

4. **Can the restricted forward_F be proved by a well-founded induction on deferralClosure(root)?** The idea: order the formulas in deferralClosure(root) by some well-founded relation, and prove forward_F for each formula assuming forward_F for all "smaller" formulas. Report 08 Section 3.8 attempted this with "F-nesting depth" but it didn't help because F-persistence through resolving steps is the issue at every nesting depth.

5. **Does the existing `fCarry` mechanism ALREADY give restricted forward_F in the common case?** If resolving steps for chi where `F(chi) in chain(k)` are rare relative to non-resolving steps, and deferralClosure(root) is finite, perhaps a pigeonhole/density argument shows that `F(psi)` cannot be lost at ALL resolving steps between t and the first psi-scheduled step. This requires bounding the number of resolving steps, which depends on the schedule function's behavior.
