# Teammate B: Canonical Frame / Fresh-Witness Approaches

## Key Findings

1. **The canonical frame in `CanonicalFrame.lean` already proves `canonical_forward_F` with zero sorry.** The proof is trivially 8 lines: given `F(psi) in M`, build `forward_temporal_witness_seed M psi`, extend via `set_lindenbaum`, and the resulting MCS witnesses both `ExistsTask M W` and `psi in W`. Each F-obligation gets an independently-constructed fresh witness. This is the construction the linear chain fundamentally cannot replicate.

2. **The canonical frame is a DAG, not a linear chain, and cannot be directly embedded into `FMCS Int`.** The canonical frame's `ExistsTask` relation produces a TREE of witnesses (each F-obligation spawns a new branch). An `FMCS Int` requires a single linear function `Int -> Set Formula`. Any embedding of the canonical frame's tree into a linear chain must merge branches, which recreates the persistence problem.

3. **The `Succ` relation from `SuccRelation.lean` offers a partial solution via deferral disjunctions.** The successor deferral seed `g_content(u) U deferralDisjunctions(u)` guarantees `Succ(u, v)` where the F-step condition `f_content(u) subset v U f_content(v)` ensures each F-obligation is either resolved or deferred. However, proving termination of deferral (i.e., eventual resolution) requires additional argument.

4. **A "biased Lindenbaum" construction is the most viable fix for the current chain approach.** Rather than switching away from linear chains entirely, modifying `set_lindenbaum` to bias toward preserving F-formulas eliminates the persistence problem without restructuring the BFMCS.

5. **Tree-indexed FMCS (`D = List Nat` or similar) is theoretically possible but incompatible with the existing parametric infrastructure.** The parametric infrastructure requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, which tree types do not satisfy.

## Detailed Analysis

### Approach 1: Canonical Frame (No Linear Chain)

The canonical frame construction in `Bundle/CanonicalFrame.lean` defines:
- `ExistsTask M M'` iff `g_content M subset M'`
- `ExistsTask_past M M'` iff `h_content M subset M'`

**Why forward_F is trivial here**: The proof of `canonical_forward_F` (lines 133-148) constructs a fresh MCS `W` for each `F(psi) in M` independently:
1. `forward_temporal_witness_seed_consistent` proves `{psi} U g_content(M)` is consistent
2. `set_lindenbaum` extends to MCS `W`
3. `g_content(M) subset W` gives `ExistsTask M W`
4. `psi in W` from the seed

This avoids inter-obligation interference entirely because each F-obligation gets its own independent Lindenbaum extension.

**The embedding problem**: To use this for `bx_fmcs_forward_F`, we would need to show that when `F(psi) in int_chain M0 h0 t`, there exists `s > t` with `psi in int_chain M0 h0 s`. The canonical frame gives us a FRESH MCS `W` with `psi in W`, but `W` is not necessarily equal to `int_chain M0 h0 s` for any `s`. The chain's MCS at each position is determined by the `fwd_succ`/`bwd_pred` construction, not by `canonical_forward_F`.

**Could we define `int_chain` using canonical frame navigation?** In principle, we could trace a path through the canonical frame: at each step, choose the canonical frame successor that resolves the scheduled F-obligation. But this is exactly what `fwd_succ` already does -- and the problem is that Lindenbaum may not preserve OTHER F-obligations while resolving the scheduled one.

### Approach 2: Succ-Based Chain with Deferral

The `SuccExistence.lean` file provides a more sophisticated construction via `successor_deferral_seed`:
```
successor_deferral_seed(u) = g_content(u) U {phi V F(phi) | F(phi) in u}
```

The Lindenbaum extension of this seed yields an MCS `v` where `Succ(u, v)` holds, meaning:
- `g_content(u) subset v` (G-persistence)
- `f_content(u) subset v U f_content(v)` (F-step: each F-obligation is resolved or deferred)

**Advantage**: The deferral disjunction `phi V F(phi)` ensures that each F-obligation from `u` is either resolved (phi in v) or carried forward (F(phi) in v). No F-obligation is silently dropped.

**Gap**: Proving that deferred obligations are EVENTUALLY resolved requires showing the deferral chain terminates. For an arbitrary formula phi, F(phi) could be deferred infinitely. The schedule-based dovetailing ensures each phi is TARGETED infinitely often, but a targeted step that resolves F(phi) by putting phi in the seed may still see F(chi) for some other chi get deferred.

**Key insight**: The deferral-based `Succ` relation is STRICTLY STRONGER than the current `fwd_succ` construction. Current `fwd_succ` only includes `g_content(M)` (plus optionally `{psi}` for resolving or `f_carry(M)` for non-resolving). It does NOT include deferral disjunctions. Switching to a `Succ`-based chain would automatically preserve all F-obligations through every step.

**Concrete proposal**: Replace `fwd_succ` with a `Succ`-successor construction:
```lean
noncomputable def fwd_succ_v2 (M : Set Formula) (h_mcs : SetMaximalConsistent M) (psi : Formula) :
    Set Formula :=
  -- Always use the deferral seed to preserve ALL F-obligations
  -- When resolving F(psi), the seed is {psi} U g_content(M) U deferralDisjunctions(M)
  -- When not resolving, the seed is g_content(M) U deferralDisjunctions(M)
  ...
```

**Problem with this proposal**: The seed `{psi} U g_content(M) U deferralDisjunctions(M)` may be inconsistent. The deferral disjunctions include `chi V F(chi)` for all F(chi) in M. If `G(neg chi) in M` (which can happen consistently with `F(chi) in M`... wait, no: `G(neg chi) in M` contradicts `F(chi) in M` by temporal duality. So `G(neg chi) notin M` whenever `F(chi) in M`. But could `psi` conflict with some deferral disjunction? The seed `{psi} U g_content(M)` is already known consistent (from `forward_temporal_witness_seed_consistent`). Adding deferral disjunctions: each `chi V F(chi)` is a theorem of TM (derivable from `F(chi) -> chi V F(chi)` via temporal unfolding), so if `F(chi) in M`, then `chi V F(chi) in M` (by MCS closure). Since all formulas in the deferral seed are in M, and `g_content(M) subset M`, the only non-M formula in the seed is `psi`. The seed is `{psi} U (subset of M)`, and we know `{psi} U g_content(M)` is consistent. But `{psi} U g_content(M) U deferralDisjunctions(M) subset {psi} U M`... this requires showing `{psi} U M` is consistent, which follows from `{psi} U g_content(M)` being consistent ONLY if `M` does not add inconsistency beyond `g_content(M)`.

Actually, `deferralDisjunctions(M) subset M` since each `chi V F(chi) in M` when `F(chi) in M`. And `g_content(M) subset M` by the T-axiom. So the seed is `{psi} U (subset of M)`. Consistency: any finite subset of the seed either contains psi or not. If not, it's a subset of M, hence consistent. If yes, it's `{psi} U L` where `L subset M`. We need `{psi} U L` consistent. This follows from `{psi} U g_content(M)` consistent because L subset M, but that's not quite right -- we need to know `{psi} U L` is consistent for arbitrary `L subset M`, not just `L subset g_content(M)`.

**Realization**: The enriched resolving seed `{psi} U g_content(M) U deferralDisjunctions(M)` has `deferralDisjunctions(M) subset M` and `g_content(M) subset M`, so the whole seed (except psi) is in M. Since M is an MCS, any finite subset of M is consistent. For the seed `{psi} U S` where `S subset M`: the seed is consistent iff `psi` is consistent with every finite subset of S. Since `S subset M` and `{psi} U g_content(M)` is consistent, we need: does the larger seed `{psi} U M_sub` remain consistent? NOT NECESSARILY. The issue is that M might contain formulas that together with psi are inconsistent, even though `{psi} U g_content(M)` is consistent. For example, `neg psi in M` would make `{psi} U M` inconsistent. But we assumed `F(psi) in M`, which means `neg G(neg psi) in M`, which does NOT prevent `neg psi in M` (F(psi) says psi holds at SOME future time, not at the current time).

So the enriched resolving seed CAN be inconsistent. This is precisely the problem noted in the plan's blocker section.

### Approach 3: Biased Lindenbaum (Recommended Fix)

The core problem is: when extending `{psi} U g_content(M)` to an MCS via Lindenbaum, the extension may include `G(neg chi)` for some other chi with `F(chi) in M`, permanently killing `F(chi)`.

A **biased Lindenbaum** would modify the extension process:

```
biased_set_lindenbaum(seed, bias) :
  Enumerate all formulas: phi_0, phi_1, ...
  S_0 = seed
  S_{n+1} =
    if S_n U {phi_n} is consistent:
      if phi_n in bias:
        S_n U {phi_n}   -- always include bias formulas when consistent
      else if S_n U {phi_n} U (consistent subset of remaining bias) is consistent:
        S_n U {phi_n}   -- include non-bias only if it doesn't kill all remaining bias
      else:
        S_n             -- skip
    else:
      S_n               -- skip (inconsistent)
```

Actually, a simpler formulation: the standard Lindenbaum lemma builds the MCS by enumerating formulas and including each one if consistent with the current set. A biased version would:

1. First include all bias formulas that are individually consistent with the seed
2. Then proceed with standard Lindenbaum for the remaining formulas

But this doesn't work either -- a bias formula might become inconsistent after other bias formulas are added.

**Simplest viable approach**: At each resolving step, build the seed as `{psi} U g_content(M)`, and then SEPARATELY verify that F-obligations survive. For each `F(chi) in M` with `chi != psi`, we need `F(chi)` or `chi` in the resulting MCS. Since the resulting MCS is SOME extension of `{psi} U g_content(M)`, and `F(chi) in M` implies `chi V F(chi) in M` (by temporal unfolding axiom), and `chi V F(chi)` is a theorem of TM given `F(chi)`, we have: the resulting MCS contains either `chi` or `F(chi)` because it's an MCS and `chi V F(chi)` is provable from `F(chi)`.

**WAIT -- this is the key insight!**

For any MCS W extending `g_content(M)`: if `F(chi) in M`, then by BX1 (temporal unfolding for F), `chi V F(chi)` is provable from `F(chi)`. Since `G(chi V F(chi)) in M` (by necessitation + the fact that `chi V F(chi)` is a theorem derivable from `F(chi)`, wait no...).

Let me think more carefully. We have `F(chi) in M`. The axiom BX3 gives `F(chi) -> chi V F(chi)` (this is `some_future_unfold` or similar). So `chi V F(chi) in M` by MCS closure. But `chi V F(chi) in M` does NOT imply `chi V F(chi) in W`. We need `G(chi V F(chi)) in M` to propagate to W.

Do we have `F(chi) -> G(chi V F(chi))`? This would require `G(F(chi) -> chi V F(chi))` which is `G(BX3_instance)`. By necessitation of the theorem `F(chi) -> chi V F(chi)`, we get `G(F(chi) -> chi V F(chi))`. Combined with `G(F(chi))` (if we had it), we'd get `G(chi V F(chi))` by distribution. But we don't have `G(F(chi))` -- we only have `F(chi) in M`.

However, with BX T-axiom `G(phi) -> phi`: if `F(chi) in M`, does `G(F(chi)) in M`? No -- `F(chi)` says chi holds at some future time, which does not imply `G(F(chi))` (that chi holds at some time after every future time).

**Conclusion on Approach 3**: The biased Lindenbaum idea cannot be resolved by purely logical argument about F-formula preservation through arbitrary Lindenbaum extensions. The fundamental issue is that `g_content(M)` does not carry enough information to force F-formula preservation.

### Approach 4: Deferral-Based Chain (Most Promising)

Returning to the `Succ` relation: the deferral disjunction approach from `SuccExistence.lean` DOES solve persistence:

Given MCS u with Succ(u, v):
- `f_content(u) subset v U f_content(v)` means every `F(chi) in u` has either `chi in v` (resolved) or `F(chi) in v` (deferred)

So F-obligations are NEVER silently dropped -- they are either resolved or explicitly deferred to the successor.

The consistency of the successor deferral seed `g_content(u) U deferralDisjunctions(u)` is proved in `successor_deferral_seed_consistent` (SuccExistence.lean). The proof works because:
- `g_content(u) subset u` (T-axiom)
- Each `chi V F(chi) in u` when `F(chi) in u` (temporal unfolding)
- So the entire seed is a subset of u, hence consistent

**For the resolving step**: We need the ENRICHED seed `{psi} U g_content(u) U deferralDisjunctions(u)`. As shown above, `deferralDisjunctions(u) subset u`, so the seed is `{psi} U (subset of u)`. The question is: is `{psi} U g_content(u) U deferralDisjunctions(u)` consistent?

Since `deferralDisjunctions(u) subset u` and `g_content(u) subset u`, the seed minus psi is in u. But `{psi} U g_content(u)` IS consistent (proved by `forward_temporal_witness_seed_consistent`). Does adding more formulas from u break consistency?

YES, potentially. If `neg psi in u` (which is possible -- F(psi) in u doesn't mean psi in u), then `{psi, neg psi} subset` the seed, making it inconsistent.

BUT: `neg psi in deferralDisjunctions(u)` only if `neg psi = chi V F(chi)` for some F(chi) in u. This is a very specific form. And `neg psi in g_content(u)` only if `G(neg psi) in u`, which contradicts `F(psi) in u`.

**So the enriched resolving seed IS consistent** as long as the only "dangerous" formulas from u that are added are deferral disjunctions. Each deferral disjunction `chi V F(chi)` is not `neg psi` (it's a disjunction). The seed `{psi} U g_content(u)` is consistent, and adding disjunctions `chi V F(chi)` (which are in u, hence consistent with all of u's content including g_content(u)) should preserve consistency.

**Formal argument**: Suppose `{psi} U g_content(u) U deferralDisjunctions(u)` is inconsistent. Then some finite `L subset {psi} U g_content(u) U deferralDisjunctions(u)` derives bot. Since `g_content(u) U deferralDisjunctions(u) subset u` (an MCS), the subset of L without psi is consistent. So psi must be in L, and `{psi} U L'` derives bot where `L' subset g_content(u) U deferralDisjunctions(u) subset u`. By deduction: `L'` derives `neg psi`. But `L' subset u` and u is an MCS, so `neg psi in u`. Also `L' subset g_content(u) U deferralDisjunctions(u)`, so we can lift: each element of L' is either in g_content(u) (so its G-form is in u) or is a deferral disjunction (which is in u).

For L' elements in g_content(u): `phi in g_content(u)` means `G(phi) in u`. By temporal necessitation of `L' derives neg psi`, we get a derivation involving G-forms. The key is: from `g_content(u) derives neg psi`, we get `G(neg psi) in u` (by generalized temporal K). But `G(neg psi) in u` contradicts `F(psi) in u` (temporal duality).

But L' may also contain deferral disjunctions, not just g_content elements. These cannot be lifted to G-form. So the argument doesn't go through cleanly.

**However**: the deferral disjunctions `chi V F(chi)` are provable from `F(chi)` (BX3 axiom). And `F(chi) in u`, and `G(F(chi)) in u` is NOT guaranteed. So we cannot lift them.

**Bottom line**: The enriched resolving seed consistency is NOT trivially provable. This remains an open question requiring careful analysis of the interaction between `psi`, `g_content(u)`, and `deferralDisjunctions(u)`.

### Approach 5: Replace Chain with Canonical Frame + Path Extraction

Instead of building a chain step-by-step, use the canonical frame to extract a maximal path:

1. Start at MCS M0
2. The canonical frame gives a DAG of MCS connected by ExistsTask
3. Extract a maximal forward-path: M0, M1, M2, ... where ExistsTask(M_i, M_{i+1})
4. Use Zorn's lemma to ensure the path is maximal (cannot be extended)
5. In a maximal path, every F-obligation MUST be resolved: if F(psi) in M_i and psi is never in any M_j for j > i, then M_i has an unresolved F-obligation. By canonical_forward_F, there exists W with psi in W and ExistsTask(M_i, W). Extending the path through W contradicts maximality.

**Problem**: This argument is flawed. A "maximal path" through the canonical frame is maximal in the sense of "cannot be extended at the endpoint." But we need an INFINITE path (Z-indexed), and maximality at the endpoint means the path is already infinite. The issue is that maximality doesn't guarantee F-resolution in the INTERIOR of the path.

Specifically: F(psi) in M_5 means there exists W with psi in W and ExistsTask(M_5, W). But W may not be on our path -- it could be on a different branch. Maximality of our path means we can't extend it at infinity, not that every branch point was resolved along our path.

**Could we use a different maximality notion?** A path P is "F-resolving" if for every F(psi) in P(i), there exists j > i with psi in P(j). We want a maximal F-resolving path. But the existence of such a path is exactly what we're trying to prove.

### Approach 6: Use `Succ`-Based Chain (RECOMMENDED)

The most promising approach combines the `Succ` relation with the schedule:

1. At each step n, let psi = schedule(n)
2. Build successor v_n = Lindenbaum extension of `successor_deferral_seed(u_n)`
   - This seed is `g_content(u_n) U deferralDisjunctions(u_n)`, which is a subset of u_n, hence consistent
   - The resulting v_n satisfies `Succ(u_n, v_n)`
3. If also `F(psi) in u_n`, we want to ADDITIONALLY include psi in v_n
   - Use the resolving seed: `{psi} U g_content(u_n) U deferralDisjunctions(u_n)`
   - Consistency of this enriched seed needs proof (see analysis above)
   - Alternatively: use `{psi} U g_content(u_n)` (known consistent) and ACCEPT that some F-obligations may be deferred rather than preserved
   - But with deferral disjunctions: even the non-enriched seed gives `Succ(u_n, v_n)`, meaning deferred F-obligations appear as `F(chi) in v_n`

**The key argument for eventual resolution**: With the schedule-based dovetailing, every formula psi is targeted infinitely often. When psi is targeted at step n and F(psi) in u_n:
- If we use the resolving seed `{psi} U g_content(u_n)`, psi enters v_n
- Some F-obligations may NOT be in v_n (the persistence problem)
- BUT: with the Succ-based seed (non-enriched), EVERY F-obligation is either resolved or deferred
- So using the NON-resolving Succ seed preserves all obligations
- At the RESOLVING step for psi, use the resolving seed and accept that other obligations may be lost
- Those lost obligations have `G(neg chi) in v_n` (by MCS maximality), meaning they CANNOT be resolved anywhere later in the chain (since G(neg chi) propagates forward)

Wait, this is the SAME problem. If a resolving step kills F(chi), then G(neg chi) enters the chain, permanently blocking chi.

**But with the Succ approach**: Instead of choosing between "resolving seed" and "non-resolving seed", ALWAYS use the Succ deferral seed. Don't try to explicitly resolve F-obligations. Just let the deferral disjunctions handle everything.

In a Succ chain: Succ(u_0, u_1), Succ(u_1, u_2), ...
- F(chi) in u_0 implies: chi in u_1 or F(chi) in u_1
- If F(chi) in u_1: chi in u_2 or F(chi) in u_2
- ...
- F(chi) is deferred at most omega times

But CAN F(chi) be deferred infinitely? That would mean F(chi) in u_n for all n >= 0 and chi not in u_n for all n >= 0. Is this consistent? We'd have F(chi) in every u_n and neg(chi) in every u_n (by MCS maximality, since chi not in u_n). This gives G(neg(chi)) ... no, having neg(chi) at every point doesn't give G(neg(chi)) at any point without the backward_G lemma, which requires forward_F -- circular again.

**Resolution via a counting argument**: We need a separate argument that F-obligations cannot be deferred infinitely in a Succ chain. One approach: use the BX linearity axiom BX11 to show that conflicting F-obligations create a strict ordering that must terminate. But this doesn't directly apply.

**Alternative**: Accept the Succ chain as-is (with possible infinite deferral) and prove forward_F by contradiction: If F(psi) in chain(t) and psi not in chain(s) for all s > t, then neg(psi) in chain(s) for all s > t (MCS maximality). From the chain's G-coherence and the fact that neg(psi) is in every future state, we can derive G(neg(psi)) in chain(t) -- BUT this requires backward_G, which requires forward_F. Still circular.

## Recommended Approach

**Use the Succ deferral seed for chain construction, combined with a direct consistency proof for the enriched resolving seed.**

The most viable path is:

1. **Prove enriched resolving seed consistency**: Show `{psi} U g_content(M) U deferralDisjunctions(M)` is consistent when `F(psi) in M`. The argument: suppose inconsistent. Then some finite `L subset {psi} U g_content(M) U deferralDisjunctions(M)` derives bot. Partition L into `L_psi = {psi}`, `L_g subset g_content(M)`, `L_d subset deferralDisjunctions(M)`. Since each element of `L_d` is `chi_i V F(chi_i)` where `F(chi_i) in M`, and `F(chi_i) -> chi_i V F(chi_i)` is a theorem, we can replace each `chi_i V F(chi_i)` in the derivation with `F(chi_i)`. This gives a derivation from `{psi} U L_g U {F(chi_i) | ...}`. But `{F(chi_i)} subset M` and `L_g subset g_content(M) subset M`, so this is `{psi} U (subset of M)`. By the same argument as `forward_temporal_witness_seed_consistent`, this gives `G(neg psi) in M`, contradicting `F(psi) in M`.

   **Actually, the replacement step is not straightforward in the derivation calculus.** We can't simply substitute formulas in a derivation tree. The correct approach: from `{psi} U L_g U L_d derives bot`, by the deduction theorem applied to each element of `L_d`, we get `{psi} U L_g derives (chi_1 V F(chi_1)) -> ... -> bot`. But this gets complicated.

2. **If enriched seed consistency is provable**: Use `fwd_succ_v2` that always uses the enriched seed. Then:
   - Every F-obligation is either resolved or deferred (from deferral disjunctions)
   - Scheduled obligations are additionally resolved (from psi in the seed)
   - By schedule surjectivity, every obligation is targeted infinitely often
   - When targeted: the obligation is resolved (psi enters the MCS)
   - Done. forward_F follows directly.

3. **If enriched seed consistency is NOT provable**: Fall back to the "biased Lindenbaum" approach where the Lindenbaum extension is modified to preferentially include F-formulas.

## Evidence/Examples

- `CanonicalFrame.lean:133-148`: `canonical_forward_F` proof (trivial, 8 lines)
- `SuccExistence.lean:87-88`: `successor_deferral_seed` definition
- `SuccExistence.lean:100+`: `successor_deferral_seed_consistent` proof
- `CanonicalModel.lean:491-495`: The sorry at `bx_fmcs_forward_F`
- `CanonicalModel.lean:72-78`: Current `fwd_succ` definition (no deferral disjunctions)
- `WitnessSeed.lean:81+`: `forward_temporal_witness_seed_consistent` proof

## Confidence Level

**6/10 that the enriched resolving seed approach works.**

The key uncertainty is the consistency proof for `{psi} U g_content(M) U deferralDisjunctions(M)`. The informal argument (deferral disjunctions are provable from their corresponding F-formulas, which are in M) is plausible but the formal derivation-level proof requires care with the deduction theorem and generalized temporal K.

If this consistency proof goes through, the entire forward_F proof reduces to:
1. Use enriched Succ seed at every step (~50 lines to define)
2. Show F-obligations persist via Succ property (~30 lines)
3. Show scheduled resolution works (~30 lines)
4. Conclude forward_F (~20 lines)

If the consistency proof does NOT go through, we fall back to biased Lindenbaum, which is more complex (~150-200 lines for the modified Lindenbaum lemma) but well-understood in the literature.

## References

### Codebase Files Analyzed
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (canonical frame, forward_F trivial)
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (Succ relation, deferral seeds)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (Succ definition)
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (FMCS structure)
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (BFMCS structure)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (temporal coherence)
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (seed consistency proofs)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (D constraints)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` (parametric frame)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` (history conversion)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (the sorry, current chain)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (completeness wiring)
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` (prior failed attempt)

### Literature
- Goldblatt 1992: Logics of Time and Computation (canonical model for tense logics)
- Burgess 1984: Basic Tense Logic (completeness for discrete tense logic)
