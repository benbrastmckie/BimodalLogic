# Teammate A: Sorry Blocker Root Cause & Infrastructure Needs

## Executive Summary

There are **~61 sorry sites** across the canonical completeness path. They cluster into **5 distinct tiers** with clear dependency ordering. The single deepest root cause is the **removal of the T-axiom** (`G(phi) -> phi` / `H(phi) -> phi`) during the reflexive-to-strict semantics transition. This removal cascades into 3 derivative problems: (1) `g_content(u) ⊆ u` can no longer be proven, (2) Until/Since truth lemma cases have no proof strategy, and (3) X/Y-content propagation infrastructure is missing.

---

## Complete Sorry Inventory

### Tier 1: T-Axiom Ghost References (11 sorry sites)

These sorry sites literally contained `Axiom.temp_t_future` or `Axiom.temp_t_past` before the strict semantics transition. They need a replacement derivation for `G(phi) -> phi` or `H(phi) -> phi` under strict semantics (which is NOT valid in general -- the fix requires restructuring, not just providing a new axiom).

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 1 | SuccChainFMCS.lean | 1244 | `⊢ False` (needs `[] ⊢ G(chi).imp chi`) | g_content ⊆ DRM | T-axiom removed | HIGH |
| 2 | SuccChainFMCS.lean | 4009 | `⊢ False` (needs `[] ⊢ H(chi).imp chi`) | h_content ⊆ DRM | T-axiom removed | HIGH |
| 3 | SuccChainFMCS.lean | 4276 | `⊢ False` (needs `[] ⊢ G(chi).imp chi`) | DRM consistency | T-axiom removed | HIGH |
| 4 | SuccChainFMCS.lean | 4419 | `⊢ False` (needs `[] ⊢ G(neg_neg_bot).imp neg_neg_bot`) | DRM consistency | T-axiom removed | HIGH |
| 5 | TargetedChain.lean | 255 | needs `⊢ phi.all_future.imp phi` for `theorem_in_mcs` | forward G coherence | T-axiom removed | HIGH |
| 6 | TargetedChain.lean | 359 | needs `⊢ phi.all_past.imp phi` for `theorem_in_mcs` | backward H coherence | T-axiom removed | HIGH |
| 7 | TargetedChain.lean | 491 | needs `⊢ phi.all_future.imp phi` for fam G coherence | fam forward_G | T-axiom removed | HIGH |
| 8 | TargetedChain.lean | 525 | needs `⊢ phi.all_past.imp phi` for fam H coherence | fam backward_H | T-axiom removed | HIGH |

**Root Cause**: Under reflexive semantics, `G(phi)` means "phi at all times >= t" which includes t itself, so `G(phi) -> phi` is valid. Under strict semantics, `G(phi)` means "phi at all times > t", which does NOT include t. The T-axiom `Axiom.temp_t_future`/`Axiom.temp_t_past` was correctly removed because it's unsound under strict semantics.

**Fix Strategy**: The proofs that used the T-axiom to show `g_content(u) ⊆ u` (i.e., `G(chi) in u` implies `chi in u`) need restructuring. Under strict semantics, `G(chi) in MCS` does NOT imply `chi in MCS`. The entire `g_content ⊆ u` approach is invalid for strict semantics. The correct approach is:
- For the successor seed consistency: Instead of showing `g_content(u) ⊆ u`, use the `seriality_future` axiom: `G(phi) -> F(phi)`. So `G(chi) in u` implies `F(chi) in u`, NOT `chi in u`. The seed should contain `F`-deferrals, not stripped `g_content`.
- For the targeted chain: The G-propagation `G(phi) at n -> phi at m` for `m > n` IS valid under strict semantics (via `temp_4` + induction on the chain), but the final step `G(phi) at m -> phi at m` is NOT. The fix is to only claim `phi at m` for `m > n` (strict inequality), which is what the strict semantics actually gives.

**Confidence**: HIGH -- this is a well-understood semantic issue with clear fix path.

### Tier 2: g_content/h_content Subset Failure (3 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 9 | SuccExistence.lean | 473 | `⊢ g_content u ⊆ u` | constrained_successor_seed_consistent | T-axiom derivative | HIGH |
| 10 | SuccExistence.lean | 788 | `⊢ g_content u ⊆ u` | successor_deferral_seed_consistent_axiom | T-axiom derivative | HIGH |
| 11 | SuccExistence.lean | 873 | `⊢ h_content u ⊆ u` | predecessor_deferral_seed_consistent_axiom | T-axiom derivative | HIGH |

**Root Cause**: `g_content(u) = { chi | G(chi) in u }`. Under reflexive semantics, `G(chi) in MCS -> chi in MCS` by T-axiom, giving `g_content(u) ⊆ u`. Under strict semantics, this is FALSE.

**Fix Strategy**: Redesign the successor seed. Instead of `g_content(u) ∪ deferralDisjunctions(u)`, the seed should be `{ F(chi) | G(chi) in u } ∪ deferralDisjunctions(u)`. Since `G(phi) -> F(phi)` (seriality axiom), each `F(chi)` is in `u` when `G(chi)` is. Then `seed ⊆ u` holds, giving consistency.

This requires changing the definitions of `constrained_successor_seed`, `successor_deferral_seed`, and `predecessor_deferral_seed`.

**Confidence**: HIGH -- the fix is structural but well-defined.

### Tier 3: Until/Since Truth Lemma (8 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 12 | CanonicalConstruction.lean | 631 | `phi.untl psi ∈ fam.mcs t ↔ truth_at ...` | canonical_truth_lemma | Until semantics | MEDIUM |
| 13 | CanonicalConstruction.lean | 632 | `phi.snce psi ∈ fam.mcs t ↔ truth_at ...` | canonical_truth_lemma | Since semantics | MEDIUM |
| 14 | CanonicalConstruction.lean | 940 | `phi.untl psi ∈ fam.mcs t ↔ truth_at ...` (restricted) | restricted_shifted_truth_lemma | Until semantics | MEDIUM |
| 15 | CanonicalConstruction.lean | 943 | `phi.snce psi ∈ fam.mcs t ↔ truth_at ...` (restricted) | restricted_shifted_truth_lemma | Since semantics | MEDIUM |
| 16 | ParametricTruthLemma.lean | 358 | `phi.untl psi ∈ fam.mcs t ↔ truth_at ...` | parametric_truth_lemma | Until semantics | MEDIUM |
| 17 | ParametricTruthLemma.lean | 361 | `phi.snce psi ∈ fam.mcs t ↔ truth_at ...` | parametric_truth_lemma | Since semantics | MEDIUM |
| 18 | ParametricTruthLemma.lean | 514 | `phi.untl psi ∈ fam.mcs t ↔ truth_at ...` (shifted) | shifted_parametric_truth_lemma | Until semantics | MEDIUM |
| 19 | ParametricTruthLemma.lean | 517 | `phi.snce psi ∈ fam.mcs t ↔ truth_at ...` (shifted) | shifted_parametric_truth_lemma | Since semantics | MEDIUM |

**Root Cause**: The truth lemma for `phi U psi` requires:
- **Forward**: `(phi U psi) in mcs(t)` implies `exists s > t, psi in mcs(s) AND forall r in (t,s), phi in mcs(r)`
  - Step 1: `(phi U psi) -> F(psi)` via `until_implies_some_future` (ITSELF HAS SORRY -- see Tier 5)
  - Step 2: `F(psi) in mcs(t)` implies `exists s > t, psi in mcs(s)` (requires `forward_F` temporal coherence)
  - Step 3: At intermediate `r`: `phi U psi` persists through Succ chain (requires X-content propagation -- Tier 4)
  - Step 4: Minimal witness via well-ordering on Int
- **Backward**: Semantic truth implies MCS membership. Requires `until_intro` axiom + induction.

**Fix Strategy**: This requires:
1. Sorry-free `until_implies_some_future` (Tier 5 dependency)
2. X-content propagation: `X(alpha) in mcs(t) -> alpha in mcs(t+1)` (Tier 4 dependency)
3. Until persistence through Succ: `(phi U psi) in u, neg(psi) in u -> (phi U psi) in v` for Succ(u,v) (SuccRelation.lean:551)
4. Well-ordering argument on the chain to find minimal witness

**Confidence**: MEDIUM -- the proof strategy is clear but the dependencies are deep.

### Tier 4: X/Y-Content Propagation & Until/Since Persistence (12 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 20 | DovetailedChain.lean | 608 | `⊤ U psi ∈ forward_dovetailed(n+1)` | until persistence | X-content missing | MEDIUM |
| 21 | DovetailedChain.lean | 974 | `⊤ S psi ∈ backward_dovetailed(n+1)` | since persistence | Y-content missing | MEDIUM |
| 22 | DovetailedChain.lean | 1070 | `∃ j ≤ k, psi ∈ backward_dovetailed(j) ∨ ⊤ U psi ∈ M_0` | until backward propagation | X-content missing | MEDIUM |
| 23 | DovetailedChain.lean | 1083 | `∃ j ≤ k, psi ∈ forward_dovetailed(j) ∨ ⊤ S psi ∈ M_0` | since forward propagation | Y-content missing | MEDIUM |
| 24 | DovetailedChain.lean | 1240 | `∃ s, t < s ∧ psi ∈ DovetailedFMCS.mcs s` | DovetailedFMCS_forward_F | Strict F-resolution | MEDIUM |
| 25 | DovetailedChain.lean | 1247 | `∃ s, s < t ∧ psi ∈ DovetailedFMCS.mcs s` | DovetailedFMCS_backward_P | Strict P-resolution | MEDIUM |
| 26 | SuccRelation.lean | 551 | `phi.untl psi ∈ v` (given Succ(u,v)) | until_persists_through_succ | X-based unfold | MEDIUM |
| 27 | SuccChainFMCS.lean | 2160 | (multi-BRS case, constrained_successor_seed_restricted_consistent) | seed consistency | BRS + G-wrapping | LOW |
| 28 | SuccChainFMCS.lean | 2182 | (augmented_seed_consistent, reduces to #27) | seed consistency | FALSE theorem | N/A |
| 29 | SuccChainFMCS.lean | 2499 | (no contradictory pairs argument) | seed consistency | Proof gap | LOW |
| 30 | SuccChainFMCS.lean | 5803 | `theta ∈ restricted_backward_chain(k+1)` (fuel=0) | bounded witness | Unreachable branch | HIGH |
| 31 | SuccChainFMCS.lean | 5961 | `theta ∈ restricted_succ_chain_fam(n+1)` (fuel=0) | bounded witness | Unreachable branch | HIGH |

**Root Cause**: Under strict semantics, `until_unfold` gives `(phi U psi) -> X(psi ∨ (phi ∧ (phi U psi)))` where `X(chi) = bot U chi`. The X-formula encodes a "next-step obligation" but X-content propagation through the Succ chain (`X(alpha) in mcs(t) -> alpha in mcs(t+1)`) has not been implemented.

The key mechanism for Until persistence:
1. `(phi U psi) in u` with `neg(psi) in u`
2. By `until_unfold`: `X(psi ∨ (phi ∧ (phi U psi))) in u`
3. By Succ(u,v): the X-content should resolve to `psi ∨ (phi ∧ (phi U psi)) in v`
4. Since `neg(psi) in u` and neg(psi) propagates via `f_content`, we get `phi ∧ (phi U psi) in v`

Step 3 requires: "X(alpha) in u and Succ(u,v) implies alpha in v". This is the X-content resolution property, which should follow from the definition of X as `bot U alpha` and the Succ relation's `f_step` property.

**Fix Strategy**:
1. Prove `X_content_resolution`: `X(alpha) in u ∧ Succ(u,v) -> alpha in v`
   - `X(alpha) = bot U alpha`. By `until_unfold`: `X(alpha) -> X(alpha ∨ (bot ∧ X(alpha)))`, simplifies to `X(alpha) -> X(alpha)` (circular).
   - Better: By the Succ relation definition, `f_content(u) ⊆ v ∪ f_content(v)`. Since `X(alpha) = F(alpha) ∧ ...` (NOT exactly -- X is `bot U alpha`). Need to use `disc_next` axiom on discrete frames: `F(top) -> X(top)`, plus the resolution mechanism.
   - Actually, the correct approach: Under discrete semantics, `X(alpha)` at t means `alpha` at t+1. The Succ chain advances by 1 step. So `X(alpha) in mcs(t)` should give `alpha in mcs(t+1)` directly from the chain construction. This should be provable from `f_step` + `disc_next`.
2. Prove `until_persists_through_succ` using X-content resolution.
3. Prove DovetailedChain persistence using the above.

**Note**: Sites #28 is explicitly marked **FALSE** in the source code comments. Site #27 has a known counterexample documented. These theorems need to be deleted or restructured, not proven.

**Confidence**: MEDIUM -- the mechanism is understood but implementation requires careful axiom-level reasoning.

### Tier 5: Derived Temporal Theorems (4 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 32 | TemporalDerived.lean | 240 | `⊢ (bot U bot).imp bot` | X_bot_absurd | Complex derivation | MEDIUM |
| 33 | TemporalDerived.lean | 247 | `⊢ (bot S bot).imp bot` | Y_bot_absurd | Complex derivation | MEDIUM |
| 34 | TemporalDerived.lean | 263 | `⊢ (phi.untl psi).imp psi.some_future` | until_implies_some_future | Needs X_bot_absurd | MEDIUM |
| 35 | TemporalDerived.lean | 271 | `⊢ (phi.snce psi).imp psi.some_past` | since_implies_some_past | Needs Y_bot_absurd | MEDIUM |

**Root Cause**: These are proof-theoretic derivations in the axiom system that have not been completed. The semantic arguments are clear but the syntactic derivation tree construction is non-trivial.

**Fix Strategy for X_bot_absurd**:
1. `X(bot) = bot U bot`. By `until_induction` with `chi = bot`:
   - Premise 1: `G(bot -> bot)` -- trivially `G(top)`, which is a theorem
   - Premise 2: `G((bot ∧ X(bot)) -> bot)` -- `bot ∧ anything -> bot` is trivial, so `G(trivial_imp)` is a theorem
   - Conclusion: `(bot U bot) -> X(bot)` = `X(bot) -> X(bot)` -- this is circular!
2. Alternative: Use `seriality_future`: `G(phi) -> F(phi)`. With phi = bot: `G(bot) -> F(bot)`. Then `G(bot)` is provable (vacuously, since seriality gives `G(bot) -> F(bot)`, and `F(bot)` is `neg(G(neg(bot)))` = `neg(G(top))`). Hmm, `G(bot)` is NOT provable -- it says "bot holds at all future times".
3. Better approach: From `until_unfold`, `X(bot) -> X(bot ∨ (bot ∧ X(bot)))` simplifies to `X(bot) -> X(bot)` (still circular).
4. Actually: `X(bot)` means `bot U bot`, which under strict semantics means "there exists s > t with bot(s) and bot at all r in (t,s)". Since bot is never true, this is false. The derivation needs `until_induction` more carefully:
   - With chi = neg(bot) = top: `G(bot -> top) ∧ G((bot ∧ X(top)) -> top) -> (bot U bot) -> X(top)`.
   - Both G-premises are theorems. So `(bot U bot) -> X(top)`.
   - `X(top) = bot U top`. Now from `seriality_future` we know `G(top) -> F(top)`, and `G(top)` is provable, so `F(top)` is provable, and `F(top) -> X(top)` via `disc_next` on discrete frames.
   - But we need `X(bot) -> bot`, not `X(bot) -> X(top)`. Hmm.
   - Better: Use `until_induction` with chi = bot directly but with modified premises. Actually, the `until_induction` conclusion is `(phi U psi) -> X(chi)`, not `(phi U psi) -> chi`. We need `X(bot) -> bot`.
   - The key insight: `X(bot) -> X(top)` from above. Also `X(bot) -> X(bot ∨ stuff)` from unfold. But to get `X(bot) -> bot`, consider: `X(bot)` means "at the next step, bot". If we can derive `X(bot) ∧ X(top)` (the second from disc_next), then by `until_linearity` we can decompose. This is the approach sketched in the source.

**Confidence**: MEDIUM -- requires careful axiom-level proof tree construction.

### Tier 6: FMCS forward_G / backward_H for Independent Extensions (2 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 36 | CanonicalConstruction.lean | 1054 | `psi ∈ restricted_chain_ext t'` (given `G(psi) in ext(t)`, `t < t'`) | FMCS construction | Independent Lindenbaum extensions | LOW |
| 37 | CanonicalConstruction.lean | 1058 | `psi ∈ restricted_chain_ext t'` (given `H(psi) in ext(t)`, `t' < t`) | FMCS construction | Independent Lindenbaum extensions | LOW |

**Root Cause**: When extending DRM chains to full MCS via Lindenbaum's lemma, each extension is independent. `G(psi) in ext(t)` does NOT imply `psi in ext(t')` because the extensions at different times are not coordinated. This is a fundamental structural issue, not a bug.

**Fix Strategy**: These sorry sites are in a DEPRECATED construction path. The comments explicitly state this blocks the "general FMCS construction" and recommend the alternative path via `restricted_shifted_truth_lemma` which only needs restricted temporal coherence. The correct approach is to NOT fix these but to route completeness through the restricted path.

**Confidence**: LOW for direct fix (structurally impossible for arbitrary formulas). HIGH for avoidance (use restricted path instead).

### Tier 7: Restricted Chain Forward_F / Backward_P (2 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 38 | UltrafilterChain.lean | 3928 | `∃ m, n < m ∧ psi ∈ succ_chain_fam S m` | succ_chain_restricted_forward_F | Core completeness gap | LOW-MEDIUM |
| 39 | UltrafilterChain.lean | 3938 | `∃ m, m < n ∧ psi ∈ succ_chain_fam S m` | succ_chain_restricted_backward_P | Core completeness gap | LOW-MEDIUM |

**Root Cause**: This is the CENTRAL sorry for canonical completeness. Given `F(psi) in succ_chain_fam(n)`, find `m > n` with `psi in succ_chain_fam(m)`. The f_step property only guarantees `f_content(chain(n)) ⊆ chain(n+1) ∪ f_content(chain(n+1))` -- the F-obligation may be DEFERRED rather than resolved. The bounded resolution argument (using bounded F-nesting within deferralClosure) is partially implemented but the fuel-based recursion has sorry in the fuel=0 branch.

**Fix Strategy**: Two approaches:
1. **Dovetailed chain approach**: Build a chain where fair scheduling ensures every F-obligation is eventually resolved. This is what DovetailedChain.lean attempts, but it has its own sorry sites (Tier 4).
2. **Bounded witness approach**: The restricted_succ_chain already implements bounded witness resolution with fuel = B*B+1 where B is the deferralClosure bound. The sorry sites at lines 5803/5961 are in the fuel=0 branch which is "semantically unreachable" -- they could be closed by providing sufficient fuel at the call site.

**Confidence**: LOW-MEDIUM -- this requires either completing the dovetailed chain infrastructure (which has its own deep dependencies) or proving the bounded witness argument terminates (which is partly done).

### Tier 8: WitnessSeed Until/Since Consistency (2 sorry sites)

| # | File | Line | Goal State | Blocks | Root Cause | Confidence |
|---|------|------|------------|--------|------------|------------|
| 40 | WitnessSeed.lean | 469 | `⊢ False` (from G(neg psi) ∧ G(...) ∧ (phi U psi) in M) | until_witness_seed_consistent | until_induction axiom application | MEDIUM |
| 41 | WitnessSeed.lean | 577 | `⊢ False` (mirror for Since) | since_witness_seed_consistent | since_induction axiom application | MEDIUM |

**Root Cause**: The proof has assembled the conjunction `G(neg(psi)) ∧ G((phi ∧ X(bot)) -> bot)` in M, and `phi U psi` in M. By `until_induction`, this gives `(phi U psi) -> X(bot)`, so `X(bot) in M`. But then `X_bot_absurd` (Tier 5, #32) gives `bot in M`, contradicting M being MCS. The sorry is because `until_induction` axiom application is not yet fully derived in the proof tree.

**Fix Strategy**: Complete the proof-theoretic derivation:
1. Form the conjunction from the hypotheses (already done in the proof)
2. Apply `until_induction` axiom instance
3. Apply modus ponens to get `(phi U psi) -> X(bot)`
4. Apply to `phi U psi in M` to get `X(bot) in M`
5. Apply `X_bot_absurd` to get `bot in M` -- NEEDS `X_bot_absurd` (Tier 5 dependency)
6. Contradiction with M being MCS

**Confidence**: MEDIUM -- depends on Tier 5 completion.

### Tier 9: Soundness Axiom Cases (19 sorry sites)

| # | File | Lines | Axioms | Blocks | Root Cause | Confidence |
|---|------|-------|--------|--------|------------|------------|
| 42-60 | Soundness.lean | 977-994, 1018 | density, discreteness_forward, seriality_future/past, disc_next/prev, until_unfold/intro/induction/linearity, since_unfold/intro/induction/linearity, until/since_connectedness, F_until_equiv, P_since_equiv | frame-specific soundness | Missing semantic proofs | HIGH |

**Root Cause**: These are the frame-class-restricted axiom soundness proofs. The general `soundness` theorem cannot handle them without frame constraints (density, discreteness, seriality). The individual proofs require semantic arguments about the frame properties.

**Fix Strategy**: Each axiom case needs a semantic validity proof under the appropriate frame class:
- `density`: Requires `DenselyOrdered D` hypothesis
- `discreteness_forward`, `disc_next/prev`, `seriality_future/past`: Require `SuccOrder D`, `NoMaxOrder D`, `NoMinOrder D`
- `until_*`, `since_*`, `F_until_equiv`, `P_since_equiv`: Require discrete frame + Until/Since semantic interpretation

These are independent of the completeness path and can be proven separately. The semantic arguments are standard.

**Confidence**: HIGH -- these are routine semantic proofs, just tedious.

### Tier 10: Dead Code / Non-Critical (5 sorry sites)

| # | File | Line | Status | Blocks |
|---|------|------|--------|--------|
| 61 | RestrictedTruthLemma.lean | 121 | DEAD CODE (0 references) | Nothing |
| 62 | RestrictedTruthLemma.lean | 168 | DEAD CODE (0 references) | Nothing |
| 63 | SimplifiedChain.lean | 195 | Alternative path, not on critical path | Nothing critical |
| 64 | SuccChainFMCS.lean | 6157 | fuel=0 backward (unreachable) | Non-critical |

---

## Infrastructure Dependency Graph

```
                    Tier 5: X_bot_absurd / Y_bot_absurd
                    (TemporalDerived.lean)
                           |
                           v
                    Tier 5: until_implies_some_future
                    (TemporalDerived.lean)
                           |
                    +------+------+
                    |             |
                    v             v
         Tier 8: WitnessSeed    Tier 3: Until/Since
         consistency            Truth Lemma
         (WitnessSeed.lean)     (CanonicalConstruction.lean,
                                 ParametricTruthLemma.lean)
                    |             |
                    v             v
         Tier 4: X-content    Tier 4: Until persistence
         propagation           through Succ
         (DovetailedChain,     (SuccRelation.lean)
          SuccChainFMCS)              |
                    |                 |
                    v                 v
         Tier 7: Restricted     Tier 1+2: T-axiom ghost
         forward_F/backward_P   + g_content subset
         (UltrafilterChain)     (SuccChainFMCS, SuccExistence)
                    |
                    v
              COMPLETENESS
              THEOREM
```

Parallel (independent) path:
```
         Tier 9: Soundness axiom cases
         (Soundness.lean, 19 sorry sites)
              |
              v
         SOUNDNESS THEOREM
```

---

## Critical Path Analysis

### Path to Completeness Theorem

The completeness theorem `completeness_over_Int` requires:

1. **Truth Lemma** (restricted or full) -- blocked by Tier 3 (Until/Since cases)
2. **Temporal Coherence** -- blocked by Tier 7 (restricted forward_F/backward_P)
3. **Successor Construction** -- blocked by Tier 1+2 (g_content subset)

The SHORTEST path to completeness avoids the Until/Since truth lemma entirely by:
- Restricting to the Until/Since-free fragment of the logic (G, H, F, P, Box, Diamond only)
- This gives completeness for the TEMPORAL fragment without Until/Since

For FULL completeness including Until/Since:
1. First close Tier 5 (X_bot_absurd, until_implies_some_future) -- 4 sorry sites
2. Then close Tier 4 (X-content propagation) -- 6-8 sorry sites
3. Then close Tier 3 (Until/Since truth lemma) -- 8 sorry sites
4. In parallel, close Tier 1+2 (seed redesign for strict semantics) -- 11 sorry sites

### Path to Soundness Theorem

The 19 soundness sorry sites (Tier 9) are entirely independent of completeness. They can be closed in parallel with any completeness work. Each is a standalone semantic validity proof.

---

## Recommended Implementation Order

### Phase 1: Seed Redesign (Tier 1 + 2) -- Highest Impact
**Priority**: CRITICAL
**Estimated sorry closures**: 14
**Confidence**: HIGH

1. Redesign `constrained_successor_seed` to not rely on `g_content(u) ⊆ u`
2. Instead use `seriality_future` to convert g_content obligations to F-deferrals
3. Fix all TargetedChain T-axiom ghosts by changing `G(phi) -> phi` to strict-inequality propagation
4. Fix SuccChainFMCS T-axiom ghosts similarly

### Phase 2: Derived Temporal Theorems (Tier 5)
**Priority**: HIGH
**Estimated sorry closures**: 4
**Confidence**: MEDIUM

1. Prove `X_bot_absurd`: `⊢ X(bot) -> bot`
2. Prove `Y_bot_absurd`: `⊢ Y(bot) -> bot`
3. Prove `until_implies_some_future`: `⊢ (phi U psi) -> F(psi)`
4. Prove `since_implies_some_past`: `⊢ (phi S psi) -> P(psi)`

### Phase 3: X/Y-Content Propagation (Tier 4)
**Priority**: HIGH
**Estimated sorry closures**: 8
**Confidence**: MEDIUM

1. Prove `X_content_resolution`: `X(alpha) in u ∧ Succ(u,v) -> alpha in v`
2. Prove `until_persists_through_succ` using X-content resolution
3. Complete DovetailedChain persistence theorems
4. Complete DovetailedFMCS forward_F / backward_P (strict version)

### Phase 4: WitnessSeed + Truth Lemma (Tier 8 + 3)
**Priority**: HIGH (depends on Phase 2)
**Estimated sorry closures**: 10
**Confidence**: MEDIUM

1. Complete WitnessSeed until/since consistency proofs
2. Complete Until/Since truth lemma cases in CanonicalConstruction
3. Complete Until/Since truth lemma cases in ParametricTruthLemma

### Phase 5: Restricted Forward_F / Backward_P (Tier 7)
**Priority**: MEDIUM
**Estimated sorry closures**: 2
**Confidence**: LOW-MEDIUM

1. Either complete the bounded witness resolution argument
2. Or route through the dovetailed chain approach

### Phase 6: Soundness (Tier 9) -- Independent Track
**Priority**: MEDIUM (independent of completeness)
**Estimated sorry closures**: 19
**Confidence**: HIGH

Can be done in parallel with any phase above.

---

## Key Insights

1. **The T-axiom removal is the ROOT CAUSE of ~25 sorry sites** (Tiers 1, 2, and their cascading effects). Redesigning the successor seed to not depend on `g_content ⊆ u` is the single highest-impact change.

2. **Until/Since support is the HARDEST part** (~20 sorry sites across Tiers 3-5, 7-8). The proof-theoretic infrastructure for X/Y-content propagation is the missing foundation.

3. **Soundness sorry sites are low-hanging fruit** (19 sites, HIGH confidence, independent of completeness). These are standard semantic validity proofs.

4. **Two theorems are FALSE** (SuccChainFMCS.lean lines 2160, 2182 -- explicitly documented as having counterexamples). These should be deleted, not fixed.

5. **Dead code sorry sites** (RestrictedTruthLemma.lean lines 121, 168) can be safely ignored -- they have zero references.

6. **The "fuel=0 unreachable branch" sorry sites** (SuccChainFMCS.lean lines 5803, 5961, 6157) can be closed by either proving fuel sufficiency at the call site or restructuring to use `Nat.strongRecOn` instead of manual fuel.
