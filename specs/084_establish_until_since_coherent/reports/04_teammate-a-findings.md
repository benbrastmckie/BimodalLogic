# Teammate A Findings: G-Lift Failure Root Cause and Enriched Seed Consistency

**Task**: 84 -- Establish Until/Since Coherence for Bundle Completeness
**Focus**: Deep dive into the G-lift failure and whether a mathematically correct consistency argument exists for enriched seeds
**Date**: 2026-04-08

## Key Findings

### 1. The G-Lift Argument Cannot Be Adapted for Mixed Seeds

**Confidence**: HIGH (95%)

The G-lift argument at `UltrafilterChain.lean:2272-2299` (`temporal_theory_witness_with_g_consistent`) has a rigid structure:

1. Assume `L ⊆ {target} ∪ temporal_box_g_seed(M)` derives bot.
2. By deduction theorem: `L' ⊢ neg(target)` where `L' ⊆ temporal_box_g_seed(M)`.
3. G-lift ALL elements of L': for each `x ∈ L'`, we need `G(x) ∈ M`.
4. By generalized temporal K: `G(neg(target)) ∈ M`.
5. Contradiction with `F(target) ∈ M`.

Step 3 is the failure point. For `x ∈ g_content(M)`, we have `G(x) ∈ M` by definition. For `x = (phi U psi)` an active Until formula, we need `G(phi U psi) ∈ M`, which does NOT hold in general.

**Splitting into G-liftable and non-G-liftable parts does NOT help.** After the deduction theorem extracts `target`, the remaining derivation `L' ⊢ neg(target)` may use BOTH G-liftable elements (from g_content) and non-G-liftable elements (Until formulas) as premises. The G-lift rule (`generalized_temporal_k`) applies to the ENTIRE context simultaneously -- you cannot G-lift only some premises and leave others unlifted. The rule is:

```
L ⊢ phi  implies  G(L) ⊢ G(phi)
```

where `G(L)` means every element of L gets G-wrapped. If even one element of L lacks the G-wrapped form in M, the G-lift cannot conclude `G(phi) ∈ M`.

There is no known way to "partially G-lift" a derivation. The necessitation rule and K-distribution are global operations on contexts.

### 2. The "Two-Stage" Consistency Argument IS Valid

**Confidence**: HIGH (95%)

The proposed two-stage argument works, but NOT via G-lifting at all. It works via the **subset-of-MCS** pattern, which is already proven and used in the codebase.

**The argument**:

Given MCS `w_n` (a chain position), suppose we want to show:
```
{target} ∪ g_content(w_n) ∪ {active Until formulas from w_n}
```
is consistent.

**Claim**: We do NOT need to prove this directly. Instead, we observe:

- `g_content(w_n) ⊆ w_n` (by BX1, proven at `SuccRelation.lean:613-617` as `g_content_subset_mcs`)
- Active Until formulas `∈ w_n` (by assumption -- they are the formulas we're tracking)
- Therefore: `g_content(w_n) ∪ {active Untils} ⊆ w_n`
- Since `w_n` is an MCS (consistent), any subset of `w_n` is consistent.

This is EXACTLY the pattern used in `SuccExistence.lean:456-498` (`constrained_successor_seed_consistent`), where the seed `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u) ⊆ u` is shown consistent because all three components are subsets of the MCS `u`.

**BUT**: This only proves `enriched_seed` is consistent. The FULL requirement is that `{target} ∪ enriched_seed` is consistent. This is where the problem re-enters.

### 3. The Three-Way Consistency Problem and Its Resolution

**Confidence**: HIGH (90%)

The chain construction needs `{target} ∪ enriched_seed` consistent, where `target` is the dovetailed F-obligation target. The standard argument requires `F(target) ∈ w_n` and uses G-lift on the seed to derive the contradiction.

**Key insight**: The G-lift argument for `{target} ∪ g_content(w_n)` ALREADY WORKS (this is `temporal_theory_witness_with_g_consistent` at line 2272). The question is whether adding Until formulas to the seed breaks it.

**Resolution**: We do NOT need to include Until formulas in the same seed as `{target}`. The correct architecture is:

**Option A -- Two-Phase Lindenbaum**:
1. First, build `W_0` from `{target} ∪ temporal_box_g_seed(w_n)` using the standard G-lift argument (already proven consistent).
2. Lindenbaum extends this to MCS `W_0`.
3. Now `g_content(w_n) ⊆ W_0` (proven by `temporal_theory_witness_with_g_exists`).
4. But we also need active Until formulas in `W_0`. This is NOT guaranteed -- Lindenbaum may have chosen `neg(phi U psi)` instead.

So Option A fails -- Lindenbaum is nondeterministic and may exclude Until formulas.

**Option B -- Single-Phase with Subset Argument**:
1. Show that `{target} ∪ g_content(w_n) ∪ {active Untils}` is consistent.
2. The subset-of-MCS argument proves `g_content(w_n) ∪ {active Untils} ⊆ w_n` is consistent.
3. For `{target} ∪ (subset of w_n)`: assume for contradiction that `L ⊆ {target} ∪ S` derives bot, where `S ⊆ w_n`.
4. By deduction theorem: `L' ⊢ neg(target)` where `L' ⊆ S ⊆ w_n`.
5. Since `L' ⊆ w_n` and `w_n` is MCS, `neg(target) ∈ w_n` (by MCS derivation closure).
6. We need: this contradicts some property of `w_n`. If `F(target) ∈ w_n`, then `neg(G(neg(target))) ∈ w_n`. But `neg(target) ∈ w_n` does NOT give `G(neg(target)) ∈ w_n` -- the former is just a single-time assertion, not a universal-future assertion.

**So Option B also fails as stated.** The subset-of-MCS argument gives `neg(target) ∈ w_n`, but we need `G(neg(target)) ∈ w_n` to contradict `F(target) ∈ w_n`. The gap between `neg(target)` and `G(neg(target))` is exactly the liftability problem.

### 4. The Fundamental Tension and the Correct Resolution

**Confidence**: HIGH (90%)

The core tension is:

- **G-lift argument**: Can prove `{target} ∪ G-liftable_seed` consistent (via G-lift + contradiction with F(target))
- **Subset-of-MCS argument**: Can prove `any_subset_of_w_n` consistent (no target involved)
- **Neither** directly proves `{target} ∪ mixed_seed` consistent when mixed_seed contains non-G-liftable elements

**The resolution is to use both arguments in sequence, with a monotonicity step**:

1. The standard G-lift proves `{target} ∪ temporal_box_g_seed(w_n)` is consistent.
2. Since `temporal_box_g_seed(w_n) ⊆ temporal_box_g_seed(w_n) ∪ {active Untils}`, and the LARGER set is the one we want consistent, this does NOT help (consistency of a subset does not imply consistency of a superset).

Wait -- actually, we need the REVERSE. Consistency of a SUPERSET implies consistency of any subset. We want to go from a smaller seed to a larger seed, which does NOT follow by monotonicity.

**The correct resolution** is more subtle. We need to check: does `{target} ∪ temporal_box_g_seed(w_n) ∪ {active Untils}` NEED to be consistent? Or can we restructure the chain construction to avoid this three-way seed?

### 5. Restructuring: Separate F-Resolution from Until-Persistence

**Confidence**: MEDIUM-HIGH (80%)

The dovetailed chain resolves one F-obligation per step. The key insight is:

**At step n, do NOT try to put both `target` AND `active Untils` in the seed.** Instead:

1. Use the standard construction `temporal_theory_witness_with_g_exists` to build the successor with `target ∈ W` and `g_content(w_n) ⊆ W`.
2. Since `g_content(w_n) ⊆ W` and `w_n` is MCS with BX1:
   - For each `(phi U psi) ∈ w_n`: we have `G(phi U psi) ∈ w_n` only if the Until formula happens to be G-stable, which is generally NOT the case.
   - But from `g_content(w_n) ⊆ W`, we get all G-persistent formulas transferred. Until formulas are NOT G-persistent.

**So the question reduces to**: Can Until formulas be carried through the chain WITHOUT seed inclusion, by some other mechanism?

**Answer**: Under BX reflexive semantics, if `(phi U psi) ∈ w_n` and `psi ∉ w_n`, then by BX9 (Until elimination): `phi ∈ w_n` and `X(phi U psi) ∈ w_n`. Under BX8+BX9, `X(alpha) <-> alpha` (since `X(alpha) = bot U alpha` and BX8 gives `alpha -> bot U alpha`, BX9 gives `bot U alpha -> bot or alpha = alpha`). So `X(phi U psi) ∈ w_n` implies `(phi U psi) ∈ w_n`, which is circular (already known).

The problem is that at the next chain position `w_{n+1}`, we need `(phi U psi) ∈ w_{n+1}`, but the chain construction only guarantees `g_content(w_n) ⊆ w_{n+1}`, and `(phi U psi) ∉ g_content(w_n)` in general.

### 6. The Correct Architecture: Enriched Seed with Subset-of-MCS for Joint Consistency

**Confidence**: MEDIUM-HIGH (80%)

After analyzing all the options, here is the mathematically correct approach:

**Observation**: The `{target} ∪ enriched_seed` consistency CAN be proven when `F(target) ∈ w_n` AND `enriched_seed ⊆ w_n`, using a COMBINED argument:

1. Assume `L ⊆ {target} ∪ S` derives bot, where `S ⊆ w_n`.
2. By deduction theorem: `L' ⊢ neg(target)` where `L' ⊆ S`.
3. **Case A**: `L'` is empty. Then `⊢ neg(target)` is a theorem, so `neg(target) ∈ w_n`. But `F(target) ∈ w_n` implies (by BX10 or the F-definition) `neg(G(neg(target))) ∈ w_n`. Also BX1 gives `G(neg(target)) -> neg(target)`. But we need the REVERSE: `neg(target) -> G(neg(target))`, which is NOT available. **However**, `⊢ neg(target)` means neg(target) is a theorem, so by necessitation `⊢ G(neg(target))`, so `G(neg(target)) ∈ w_n`, contradicting `F(target) ∈ w_n`. This case works.
4. **Case B**: `L'` is nonempty, with all elements in `S ⊆ w_n`. Then by MCS derivation closure: `neg(target) ∈ w_n`. Now we only know `neg(target) ∈ w_n`, not `G(neg(target)) ∈ w_n`.

**Case B is the problem.** `neg(target) ∈ w_n` and `F(target) ∈ w_n` ARE contradictory! Here is why:

- `F(target) = neg(G(neg(target))) ∈ w_n`
- By BX1: `G(neg(target)) -> neg(target)`. Contrapositive: `neg(neg(target)) -> neg(G(neg(target))) = F(target)`.
- So `neg(neg(target)) -> F(target)`. But we have BOTH `neg(target) ∈ w_n` AND `F(target) ∈ w_n`.
- `F(target) = neg(G(neg(target)))`. So `G(neg(target)) ∉ w_n` (by MCS).
- But `neg(target) ∈ w_n` does not imply `G(neg(target)) ∈ w_n`.
- And `F(target) ∈ w_n` means `neg(G(neg(target))) ∈ w_n`, which only says `G(neg(target)) ∉ w_n`.
- These are NOT contradictory: `neg(target) ∈ w_n` and `G(neg(target)) ∉ w_n` and `F(target) ∈ w_n` are all compatible. (Target is false now but not always false in the future.)

**WAIT.** But `F(target) ∈ w_n` means "target is true at some future time." If `neg(target) ∈ w_n` (target is false now), that's fine -- target can be false now but true later. So `neg(target)` and `F(target)` are NOT contradictory!

**This means**: The subset-of-MCS argument for `{target} ∪ S` where `S ⊆ w_n` does NOT derive a contradiction even when `F(target) ∈ w_n`. The deduction gives `neg(target) ∈ w_n`, which is perfectly compatible with `F(target) ∈ w_n`.

**Critical realization**: The `{target} ∪ S` consistency proof REQUIRES the G-lift to work. The subset-of-MCS argument cannot replace it. Therefore, INCLUDING non-G-liftable elements (like Until formulas) in the seed fundamentally breaks the consistency argument for `{target} ∪ enriched_seed`.

### 7. Resolution: Abandon Enriched Seed for Chain Steps; Use Different Architecture for Until Persistence

**Confidence**: HIGH (85%)

The analysis shows that the three-way `{target} ∪ g_content ∪ {Untils}` consistency argument CANNOT work via either G-lift (Until not G-liftable) or subset-of-MCS (gives neg(target) in w_n which is compatible with F(target) in w_n).

**The correct path is to NOT enrich the chain step seed with Until formulas.** Instead, Until persistence must be achieved by a different mechanism:

**Architecture 1 -- Dovetailed Until Resolution**: Instead of trying to persist Until formulas through chain steps, schedule Until obligations just like F-obligations. When `(phi U psi) ∈ w_t` needs resolution:
- Use `canonical_forward_U` (CanonicalFrame.lean:199-213) to get a witness MCS where `psi` holds.
- The seed is `{psi} ∪ g_content(w_t)` (the `until_witness_seed`), which IS consistent (proven in `WitnessSeed.lean:342`).
- This gives an MCS W with `psi ∈ W` and `g_content(w_t) ⊆ W`.
- The chain at the scheduled resolution step uses W.

**The remaining problem**: Between time t and the resolution step s, we need `phi ∈ w_r` for all `r ∈ [t, s)` (the guard condition). This requires that EITHER:
- (a) `(phi U psi)` persists in w_r for t <= r < s (then BX9 gives phi when psi is absent), OR
- (b) We can derive `phi ∈ w_r` by some other means.

For (a), we circle back to the Until persistence problem. For (b), there is no obvious mechanism.

**Architecture 2 -- Immediate Until Resolution at t+1**: Instead of deferring, resolve EVERY active Until at the very next step. If `(phi U psi) ∈ w_n` and `psi ∉ w_n`, then at step n+1 use the until_witness_seed `{psi} ∪ g_content(w_n)` as the primary seed (not the F-resolution seed). This immediately resolves the Until at the next step with empty guard interval (t=n, s=n+1, guard [n,n+1) = {n} where phi holds by BX9 at w_n).

**Problem with Architecture 2**: This sacrifices the F-resolution schedule. You cannot use step n+1 for BOTH F-resolution (dovetailing target) AND Until-resolution. The chain can only extend with ONE seed per step.

**Architecture 3 -- Parallel Chain Extension**: Maintain TWO objectives per step: the dovetailed F-target AND Until persistence. Use a seed that serves both:
- Seed = `{target, psi_1, psi_2, ...} ∪ g_content(w_n)`
- Where psi_i are the Until witnesses.
- Consistency of `{target, psi_1, ...} ∪ g_content(w_n)` requires G-lifting the g_content part and showing target + psi_i don't jointly contradict.

This is also NOT straightforward because g_content elements can only derive G-conclusions, and the multi-target deduction theorem becomes more complex.

## Recommended Approach

**Confidence**: MEDIUM (65%)

Given that enriching the Lindenbaum seed is fundamentally blocked by the G-lift vs. subset-of-MCS incompatibility, the recommended approach is:

### Primary: Restructure Chain to Interleave Until-Resolution Steps

1. **Interleave**: Alternate between F-resolution steps (using standard `temporal_theory_witness_with_g_exists`) and Until-resolution steps (using `canonical_forward_U` / `until_witness_seed`).

2. **F-resolution step**: Seed = `{F-target} ∪ temporal_box_g_seed(w_n)`. Consistent by G-lift. Gives F-target and g_content propagation.

3. **Until-resolution step**: When `(phi U psi) ∈ w_n` and `psi ∉ w_n`, seed = `{psi} ∪ g_content(w_n)`. Consistent by `until_witness_seed_consistent`. Gives `psi ∈ w_{n+1}`.

4. **Guard condition**: For the interval [t, t+1) = {t}, BX9 gives `phi ∈ w_t` (since `(phi U psi) ∈ w_t` and `psi ∉ w_t`). So the guard is automatically satisfied with s = t+1.

5. **Dovetailing**: Use `Nat.unpair` to interleave F-resolutions and Until-resolutions fairly. This ensures both F-obligations and Until-obligations are eventually resolved.

### Secondary: Backward Until via Existing Infrastructure

The backward direction (witness pattern implies Until membership) is ALREADY handled by `UntilSinceCoherence.lean` parameterized on step transfer. The step transfer requires:
```
(phi U psi) ∈ fam.mcs (r + 1) AND phi ∈ fam.mcs r IMPLIES (phi U psi) ∈ fam.mcs r
```

Under BX8: `psi -> (phi U psi)`. Under `or_until_in_mcs`: `(psi or (phi and (phi U psi))) ∈ M -> (phi U psi) ∈ M`.

If `(phi U psi) ∈ fam.mcs (r+1)`, can we derive `(phi U psi) ∈ fam.mcs r`? Only if there is a chain link connecting r+1 back to r. For forward chains with g_content, we have `g_content(w_r) ⊆ w_{r+1}`, which goes FORWARD. We need the REVERSE: some property of `w_{r+1}` that transfers to `w_r`.

The h_content duality (`g_content(M) ⊆ M' implies h_content(M') ⊆ M`, from `WitnessSeed.lean:600`) gives: if `H(phi U psi) ∈ w_{r+1}`, then `(phi U psi) ∈ w_r`. But we need `H(phi U psi) ∈ w_{r+1}`, which is NOT available from just `(phi U psi) ∈ w_{r+1}`.

The step transfer remains the key blocker for backward Until. The `or_until_in_mcs` approach works if we can show `psi ∈ fam.mcs r` or `(phi and (phi U psi)) ∈ fam.mcs r`. The former is available if r = s (witness time). The latter requires `(phi U psi) ∈ fam.mcs r`, which is what we're trying to prove -- circular.

**For backward Until, the interleaved chain approach helps indirectly**: if the chain resolves Until at step r+1 (giving `psi ∈ w_{r+1}`), then at step r we need `(phi U psi) ∈ w_r`, which by BX8 follows from `psi ∈ w_r`. But `psi` may not be in `w_r`. The backward direction truly requires step transfer or a fundamentally different argument.

## Evidence/Examples

### Concrete Example of G-Lift Failure

Let `w_n` be an MCS with `(p U q) ∈ w_n`, `q ∉ w_n`, `F(target) ∈ w_n`.

Enriched seed: `{target} ∪ g_content(w_n) ∪ {p U q}`.

Suppose `L = {target, G(alpha) |-> alpha_from_g_content, p U q}` derives bot.
By deduction theorem, remove target: `{alpha_from_g_content, p U q} ⊢ neg(target)`.

G-lift the g_content part: `{G(alpha)} ⊢ ???`. But we cannot G-lift `p U q` to `G(p U q)` because `G(p U q) ∉ w_n` in general.

### Concrete Example Where neg(target) and F(target) Coexist

Consider frame Z (integers), w_n evaluates at time 0.
- `p` is false at time 0 (so `neg(p) ∈ w_n`)
- `p` is true at time 1 (so `F(p) ∈ w_n`)
- `G(neg(p)) ∉ w_n` (since p is true at time 1)

Both `neg(p) ∈ w_n` and `F(p) ∈ w_n` hold simultaneously. This confirms that the subset-of-MCS argument for `{target} ∪ S` where `S ⊆ w_n` cannot derive a contradiction just from `F(target) ∈ w_n`.

### Existing Codebase Pattern (SuccExistence.lean:456-498)

The `constrained_successor_seed_consistent` theorem proves seed consistency by showing `seed ⊆ u` (the MCS). It does NOT involve any target formula. This pattern works for seeds without targets but cannot be extended to `{target} ∪ seed` without the G-lift mechanism.

## Confidence Level

- G-lift cannot be adapted for mixed seeds: **95% confident**
- Subset-of-MCS cannot prove `{target} ∪ mixed_seed` consistent: **90% confident** (the neg(target)/F(target) coexistence argument is rigorous)
- Three-way `{target} ∪ g_content ∪ Untils` fundamentally blocked: **90% confident**
- Interleaved chain resolution as correct architecture: **65% confident** (mathematically sound, but implementation complexity and interaction with dovetailing scheduling need verification)
- Backward Until step transfer remains the bottleneck: **85% confident** (multiple failed approaches documented across task 83 and 84 research)

## Summary

The G-lift argument and the subset-of-MCS argument are fundamentally incompatible tools that solve different problems:
- G-lift: proves `{target} ∪ G-liftable_seed` consistent (needs F(target) in MCS)
- Subset-of-MCS: proves `any_subset_of_w_n` consistent (no target)

Neither can prove `{target} ∪ mixed_seed` consistent when the mixed seed contains non-G-liftable elements. The neg(target)/F(target) coexistence phenomenon (target false now but true in the future) is the precise reason the subset-of-MCS argument cannot substitute for G-lift when a target is involved.

The recommended architecture separates Until-resolution from F-resolution into distinct chain steps, avoiding the need for a three-way enriched seed entirely.
