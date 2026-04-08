# Teammate C Findings: New Construction Strategy and Risk Analysis

**Task**: 84 -- Establish Until/Since Coherence for Bundle Completeness
**Focus**: Design concrete chain construction strategies for forward Until/Since coherence
**Date**: 2026-04-08

## Key Findings

### Finding 1: Strategy 3 (Until-Aware Dovetailing) Is the Recommended Approach

After analyzing all five strategies against the actual codebase, Strategy 3 is the most viable path. It reuses the existing `temporal_theory_witness_with_g_consistent` infrastructure directly, requires no new consistency arguments beyond what is already proved, and addresses the Until persistence gap via a reframing that avoids the X-vs-G mismatch entirely.

### Finding 2: The Multi-Target Enriched Seed (Strategy 1) Has a Fatal Consistency Gap

Strategy 1 proposes adding multiple targets `{target_1, ..., target_k}` to the seed. I verified the proof of `temporal_theory_witness_with_g_consistent` at UltrafilterChain.lean:2272-2299. The G-lift argument works as follows:

1. Assume `L proves bot` where `L subset {phi} union temporal_box_g_seed(M)`
2. Extract phi by deduction: `L' proves neg(phi)` where `L' subset temporal_box_g_seed(M)`
3. G-lift all of L': every element x of the seed has `G(x) in M`
4. So `G(neg(phi)) in M`, contradicting `F(phi) = neg(G(neg(phi))) in M`

For multiple targets `{phi_1, ..., phi_k}`, the deduction step fails: from `L proves bot` with `L subset {phi_1, ..., phi_k} union g_seed`, we can only extract `L' proves neg(phi_1 and ... and phi_k)`, which gives `G(neg(phi_1 and ... and phi_k)) in M`. We need `F(phi_1 and ... and phi_k) in M` to get a contradiction, but we only have `F(phi_i) in M` individually. Since `F(a) and F(b)` does NOT imply `F(a and b)` in temporal logic (a and b may be true at different future times), the multi-target consistency argument fails.

**Verdict**: BLOCKED. The G-lift argument is fundamentally single-target.

However, there is a partial rescue: for Until obligations `(phi U psi) in M`, we have `F(psi) in M` (by BX10). So instead of adding `(phi U psi)` to the seed (which lacks G-liftability), we add `psi` as the target (since `F(psi) in M`). This means we can resolve ONE Until obligation per step, which is exactly what Strategy 3 does.

### Finding 3: Strategy 2 (Two-Phase Construction) Is Circular

Strategy 2 proposes using the dovetailed chain's forward_F to witness Until obligations. The logic:

- `(phi U psi) in chain(t)` implies `F(psi) in chain(t)` (by BX10)
- If forward_F works, `exists s > t, psi in chain(s)`
- Then backward Until gives `(phi U psi) in chain(t)`

But forward_F itself depends on Until persistence (`forward_dovetailed_until_persists`, line 614-650, which is sorry). The chain of dependencies:

```
forward_Until -> forward_F -> until_persists -> SORRY
```

And backward_Until needs forward_Until to provide the witness s with psi at s. So:
```
backward_Until(step) -> forward_Until(witness) -> forward_F -> until_persists -> SORRY
```

Additionally, the DovetailedFMCS `forward_F` at line 700-743 uses `until_persists` in its proof. The comment at line 1292-1293 confirms: "Even the non-strict `dovetailed_fam_forward_F` depends on Until persistence which has a sorry."

**Verdict**: CIRCULAR. Cannot use forward_F to establish forward_Until because forward_F depends on Until persistence.

### Finding 4: Strategy 3 Works by Targeting psi Instead of (phi U psi)

The key insight: when `(phi U psi) in chain(t)` and `psi not in chain(t)`, do NOT try to propagate `(phi U psi)` through the chain. Instead, add `psi` as the dovetailing target at a scheduled step.

**Why this avoids the X-vs-G mismatch**: The current construction targets `schedule_formula(n)` at step n. If `F(schedule_formula(n)) in chain(n)`, it resolves by putting the target in the seed. For Until obligations, `F(psi) in chain(t)` (from BX10), so `psi` is a valid dovetailing target. The standard `temporal_theory_witness_with_g_consistent` gives `{psi} union g_seed(chain(n))` is consistent. No Until formula ever needs to appear in the seed.

**The guard argument**: Between t and the resolution step s where psi appears, we need `phi in chain(r)` for all r in [t, s). At each such r:
- If `psi not in chain(r)`, then by `until_unfold_thm`: `(phi U psi) in chain(r)` implies `psi or (phi and (phi U psi)) in chain(r)`. Since `psi not in chain(r)`, the MCS disjunction resolution gives `phi and (phi U psi) in chain(r)`, hence `phi in chain(r)`.

**The persistence argument**: We need `(phi U psi) in chain(r)` for intermediate r. This is the SAME blocker as before -- but with one critical difference under Strategy 3. Under BX reflexive semantics:
- `(phi U psi) in chain(r)` implies `psi or (phi and (phi U psi)) in chain(r)` (BX5+BX9, sorry-free)
- If `psi not in chain(r)`: `phi and (phi U psi) in chain(r)`, so `(phi U psi) in chain(r)` (tautological)
- If `psi in chain(r)` for some r < s: done! psi appeared before s, pick the EARLIEST r >= t with `psi in chain(r)` as the witness instead

So the guard argument becomes: define s = min{r >= t : psi in chain(r)}. Then for all r in [t, s), `psi not in chain(r)`, so the unfold gives `phi in chain(r)`. No Until persistence through Lindenbaum steps is needed!

**BUT**: This assumes `psi` eventually appears in the chain. This requires the dovetailing to schedule `psi` and resolve it. The fair scheduling gives `exists n >= t, schedule_formula(n) = psi`. At step n, if `F(psi) in chain(n)` (which requires Until persistence to maintain `(phi U psi)` and hence `F(psi)` through to step n), we get `psi in chain(n+1)`.

**The remaining gap**: We need `F(psi) in chain(n)` at the scheduling step n. We have `F(psi) in chain(t)` (from BX10). For F(psi) to persist to step n, we need... F-persistence through Lindenbaum steps. But `F(psi) = neg(G(neg(psi)))`, and Lindenbaum extensions can freely add `G(neg(psi))`, killing F(psi).

This brings us back to the fundamental issue. F-persistence fails for the same reason Until persistence fails.

### Finding 5: The Bundle-Level Forward_F Bypass (True Path Forward)

Looking at the actual completeness proof, I discovered something critical. The BFMCS_Bundle construction at DovetailedChain.lean:1416-1460 has TWO different forward_F mechanisms:

1. **Intra-family forward_F** (DovetailedFMCS_forward_F, line 1296): Same-family F-witness. SORRY, blocked by Until persistence.

2. **Bundle-level bundle_forward_F** (line 1422-1437): Cross-family F-witness. SORRY-FREE. Given `F(phi) in fam.mcs t`, it constructs a NEW family `fam'` shifted to t+1 with `phi in fam'.mcs (t+1)`.

The bundle_forward_F at lines 1422-1437 is completely sorry-free. It uses `temporal_theory_witness_exists` to get a witness MCS W' with `phi in W'`, then builds `shifted_fmcs(DovetailedFMCS W' h_W', t+1)` as the witness family. This works because the witness is in a DIFFERENT family, so no persistence through the original chain is needed.

**For Until/Since coherence**: The 4-conjunct definition at TemporalCoherence.lean:466-479 is PER-FAMILY. It requires:
```
forall fam in B.families, ...
  forward_until at fam, backward_until at fam,
  forward_since at fam, backward_since at fam
```

So forward_Until must find a witness s >= t WITH PSI IN THE SAME FAMILY. The bundle-level cross-family trick does not help here.

### Finding 6: Strategy 4 (Reflexive Witness) Provides the s=t Case But Not General

Under BX8: `psi -> (phi U psi)`, and by BX9: `(phi U psi) -> psi or (phi and (phi U psi))`.

If `(phi U psi) in chain(t)` and `psi in chain(t)`: witness s = t, guard is empty. Done.

If `psi not in chain(t)`: need strict future witness. This brings back the persistence problem.

The reflexive case is actually already handled by `backward_until_reflexive` in UntilSinceCoherence.lean:81-84. The hard case is when `psi not in chain(t)`.

### Finding 7: Strategy 5 (Fundamentally Different Construction) -- Constraint-Driven Chain

The most promising approach for a complete solution is a constraint-driven chain construction where Until obligations are tracked and resolved explicitly:

**Construction**: Build chain(n) by maintaining an obligation set `Omega(n)`:
```
Omega(0) = all Until/Since obligations from chain(0)
chain(n+1) = Lindenbaum extension of {target(n)} union g_seed(chain(n)) union active_untils(n)
Omega(n+1) = (Omega(n) minus resolved) union new_obligations(chain(n+1))
```

Where `active_untils(n) = {phi U psi : (phi U psi) in Omega(n) and psi not in chain(n)}`.

**Consistency of the enriched seed**: This is the KEY question. We need `{target(n)} union g_seed(chain(n)) union active_untils(n)` to be consistent.

The G-lift argument covers `{target(n)} union g_seed(chain(n))` (standard).

For `active_untils(n)`: each `(phi U psi) in active_untils(n)` is already in `chain(n)` (by Until persistence within the chain itself -- but we DON'T have that).

**Alternative consistency argument**: Under BX reflexive semantics (BX1: G(a) -> a), `g_content(M) subset M` for any MCS M. So `g_seed(M) subset M`. Also `{target} subset M` when `F(target) in M` and we use BX1 on the witness. So `{target} union g_seed(M) subset M`. And `active_untils subset M`. Therefore the entire enriched seed `{target} union g_seed(M) union active_untils` is a SUBSET of M, which is consistent (since M is consistent).

Wait -- this argument proves consistency! Let me verify:

- `g_content(M) = {a : G(a) in M}`. By BX1 (G(a) -> a), `G(a) in M` implies `a in M`. So `g_content(M) subset M`. Check.
- `G_theory(M) = {G(a) : G(a) in M} subset M`. Check.
- `box_theory(M) = {Box(a) : Box(a) in M or neg(Box(a)) in M} subset M`. Check.
- `temporal_box_g_seed(M) = G_theory union box_theory union g_content(M) subset M`. Check.
- If `F(target) in M`, does `target in M`? NO! F(target) = neg(G(neg(target))). BX1 gives `G(neg(target)) -> neg(target)`, i.e., `neg(target) -> F(target)`. So `F(target) in M` does NOT imply `target in M`. Example: `F(p) in M` but `p not in M` (p is true only in the future).

So the subset argument fails for the target. The standard G-lift argument handles the target separately: it extracts `target` by deduction, G-lifts the rest, and uses the contradiction between `G(neg(target))` and `F(target)`.

**Revised consistency argument for enriched seed with active Untils**:

Suppose `L proves bot` with `L subset {target} union g_seed(M) union active_untils(M)`.

Let `L_u = L intersect active_untils(M)` and `L_rest = L setminus L_u`.

By deduction on the Until formulas: if we could extract them one by one via deduction, we'd get `L_rest proves neg(u_1 and ... and u_k)`. But `neg(u_1 and ... and u_k)` is NOT G-liftable.

Alternative: Since every element of `active_untils(M)` is in M (the chain's MCS at step n), and every element of `g_seed(M)` is in M (by BX1), the seed `{target} union g_seed(M) union active_untils(M) = {target} union (g_seed(M) union active_untils(M))`. The set `g_seed(M) union active_untils(M)` is a subset of M, which is consistent. Adding `{target}` where `F(target) in M`:

We need: `{target} union S` is consistent, where `S subset M` and `F(target) in M`.

Suppose `L proves bot` with `L subset {target} union S`. Extract target by deduction: `L' proves neg(target)` where `L' subset S subset M`. Since M is closed under derivation, `neg(target) in M`. But `F(target) = neg(G(neg(target))) in M`. So `G(neg(target)) not in M`. But we also have `neg(target) in M`. Does this lead to contradiction?

We need `G(neg(target)) in M` from `L' proves neg(target)`. But L' is a subset of M, not of g_content(M). We can't G-lift arbitrary elements of M.

**The fundamental obstacle remains**: Elements of `active_untils(M)` are in M but are NOT G-liftable. The G-lift consistency argument requires ALL seed elements (except the target) to have G-lifts in M. Until formulas don't satisfy this.

However, there IS a different consistency argument available. Let me check:

Since `{target} union S subset {target} union M`, and `M` is consistent, and `target not in M` is possible, we need to prove `{target} union M_subset` is consistent. A subset of a consistent set is consistent if we don't add contradictory elements. But `{target} union S` with `S subset M` could be consistent even when `target not in M`, as long as `neg(target) not in S`. But S is a proper subset of M, and `neg(target)` might be in M and hence potentially in S.

Wait: if `F(target) in M`, then `neg(G(neg(target))) in M`, which means `G(neg(target)) not in M`. But `neg(target)` could still be in M! Example: target = p, and neg(p) in M but G(neg(p)) not in M (neg(p) is true now but not always in the future). In this case, both `{neg(p)}` and `{p}` are subsets of `M union {p}`, and `neg(p) proves neg(p)`, `p proves p`, so `{p, neg(p)} proves bot`. This would make `{p} union M_subset` inconsistent whenever `neg(target) in M_subset`.

So the subset argument ALSO fails. The only proven consistency argument is the G-lift one, which requires G-liftable seed elements.

### Finding 8: The True Solution -- Modify the BFMCS Definition or Use Bundle Forward_F

After exhaustive analysis, I see two genuine paths forward:

**Path A: Weaken `until_since_coherent` to use bundle-level witnesses (RECOMMENDED)**

Instead of requiring the Until witness s in the SAME family, allow it in ANY family in the bundle:

```lean
-- Current (per-family):
forall fam in B.families, forall t phi psi,
  (phi U psi) in fam.mcs t ->
  exists s >= t, psi in fam.mcs s and guard(phi, [t,s))

-- Proposed (bundle-level):
forall fam in B.families, forall t phi psi,
  (phi U psi) in fam.mcs t ->
  exists fam' in B.families, exists s >= t,
    psi in fam'.mcs s and guard_in_fam'(phi, [t,s))
```

This would allow the bundle_forward_F (sorry-free!) to provide the witness family. The shifted truth lemma would need modification, but the canonical model construction already evaluates truth across families (via ShiftClosedCanonicalOmega).

**Risk**: CONFIRMED FATAL. The truth lemma Until case at ParametricTruthLemma.lean:365-380 uses `h_fwd_U t phi psi h_U` which requires `psi in fam.mcs s` (same family). The semantic side at Truth.lean:128 evaluates `truth_at M Omega tau s psi` using the SAME history tau. Since `tau = parametric_to_history fam`, the witness must be in the same family. Bundle-level witnesses would require reworking the semantics of Until itself, which is not viable.

**VERDICT**: Path A is BLOCKED. The truth lemma and semantic definition of Until fundamentally require same-history evaluation.

**Path B: Prove Until persistence via BX4 + enriched backward construction**

BX4 gives `alpha -> G(P(alpha))`. So `(phi U psi) -> G(P(phi U psi))`. If `(phi U psi) in chain(n)`, then `G(P(phi U psi)) in chain(n)`, hence `P(phi U psi) in g_content(chain(n)) subset chain(n+1)`.

Now `P(phi U psi) in chain(n+1)`. This says "at some past time, (phi U psi) held." If we have backward_P coherence for the chain (which is sorry in the dovetailed construction but available at the bundle level), then there exists s < n+1 with `(phi U psi) in chain(s)`. But this gives s <= n, which we already know!

The information propagated is `P(phi U psi)`, not `(phi U psi)` itself. Under BX reflexive semantics, `P(alpha) = neg(H(neg(alpha)))`. BX1' gives `H(alpha) -> alpha`, so `neg(alpha) -> P(alpha)`. This means P(alpha) is weaker than alpha: having `P(phi U psi) in chain(n+1)` tells us the Until held in the past, not that it holds now.

**Verdict**: BX4 propagates P-information forward, but P-information cannot reconstruct the original formula at the successor step.

**Path C: Accept the sorry for forward Until, close backward Until NOW**

The backward Until/Since direction is closable using `backward_until_from_step` + `backward_since_from_step` from UntilSinceCoherence.lean, given the step transfer property. Under BX reflexive semantics with `x_implies_id` (X(a) -> a, equivalently a -> X(a)), the step transfer IS derivable:

For the step: `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)` implies `(phi U psi) in fam.mcs(r)`.

Under BX: `psi_imp_until` gives `psi -> (phi U psi)`. And `or_until_imp` gives `(psi or (phi and (phi U psi))) -> (phi U psi)`.

We need to show: if `(phi U psi) in M'` (successor) and `phi in M` (current), then `(phi U psi) in M`. This requires a LINK between M and M' -- specifically, information flow from M' back to M.

For g_content chains: `g_content(M) subset M'`, going FORWARD. The backward direction is: `h_content(M') subset M` (from `g_content_subset_implies_h_content_reverse`). So `H(phi U psi) in M'` would give `(phi U psi) in h_content(M') subset M`. But we need `H(phi U psi) in M'`, not just `(phi U psi) in M'`.

Does `(phi U psi) in M'` imply `H(phi U psi) in M'`? By BX4': `alpha -> H(F(alpha))`. So `(phi U psi) -> H(F(phi U psi))`. But that gives `H(F(phi U psi))`, not `H(phi U psi)`.

The step transfer requires information flowing backward (from successor to predecessor), but the chain construction only provides forward information flow (g_content) and the backward direction gives h_content, which requires H-wrapped formulas.

**This confirms the fundamental finding**: the step transfer for backward Until requires either (a) deterministic chain (x_content bidirectional), or (b) a new mechanism.

## Recommended Approach

### Primary Recommendation: Path C -- Close Backward, Narrow Forward Sorry

**Confidence**: 85%

Path A (bundle-level coherence) is BLOCKED: the semantic definition of Until at Truth.lean:128 evaluates along a single history, and the truth lemma at ParametricTruthLemma.lean:365-380 inherently requires same-family witnesses. There is no viable shortcut around the per-family requirement.

**Confidence**: 85%

If Path A's truth lemma refactoring proves infeasible:
1. Close backward Until/Since immediately (already infrastructure-ready)
2. Refactor `until_since_coherent` into separate forward and backward predicates
3. Use backward coherence in the truth lemma wherever possible
4. Leave forward Until as a precisely scoped sorry

**Estimated LOC**: 200-300
**Key risk**: Forward sorry remains, but scope is narrower and well-characterized.

### Not Recommended: Strategies 1-4 as Originally Proposed

| Strategy | Verdict | Reason |
|----------|---------|--------|
| 1. Multi-Target Seed | BLOCKED | G-lift consistency is fundamentally single-target |
| 2. Two-Phase | CIRCULAR | forward_F depends on Until persistence (the very thing we're trying to prove) |
| 3. Until-Aware Dovetailing | BLOCKED | F-persistence through Lindenbaum fails for same reason as Until persistence |
| 4. Reflexive Witness | PARTIAL | Handles s=t case only; strict future case requires persistence |
| 5. Constraint-Driven | BLOCKED | Enriched seed consistency fails (Until formulas not G-liftable) |

## Evidence/Examples

### BX Reflexive Properties Verified in Codebase

All the following are sorry-free in `TemporalDerived.lean`:
- `x_implies_id` (line 385): `X(a) -> a` (makes X trivial)
- `psi_imp_until` (line ~350): `psi -> (phi U psi)` (BX8)
- `until_unfold_thm` (line 443): `(phi U psi) -> psi or (phi and (phi U psi))` (BX5+BX9)
- `or_until_imp` (line 408): `(psi or (phi and (phi U psi))) -> (phi U psi)` (Peirce)
- `until_intro` (line 474): `X(psi or (phi and (phi U psi))) -> (phi U psi)` (x_implies_id + or_until_imp)

### Bundle Forward_F Is Sorry-Free

DovetailedChain.lean:1422-1437 proves `bundle_forward_F` without sorry by constructing a NEW family:
```lean
bundle_forward_F := fun fam hfam phi t h_F => by
  obtain <W, h_W, k, h_agree, rfl> := hfam
  have h_mcs_t := (DovetailedFMCS W h_W).is_mcs (t - k)
  obtain <W', h_W'_mcs, h_phi_W', _, h_box_agree> :=
    temporal_theory_witness_exists _ h_mcs_t phi h_F
  ...
  exact <shifted_fmcs (DovetailedFMCS W' h_W'_mcs) (t + 1), ..., t + 1, ..., h_phi_W'>
```

This creates `fam' = shifted(DovetailedFMCS(W'), t+1)` with `phi in fam'.mcs(t+1)`. The witness is in a different family than the original.

### Until_since_coherent Is Per-Family

TemporalCoherence.lean:466-479 defines the coherence property as:
```lean
def BFMCS.until_since_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families, ...
    (phi U psi) in fam.mcs t -> exists s >= t, psi in fam.mcs s and guard
```

The `exists s, psi in fam.mcs s` requires s in the SAME family. This is the core obstacle.

### G-Lift Is Single-Target

UltrafilterChain.lean:2272-2299: The proof of `temporal_theory_witness_with_g_consistent` extracts the single target by deduction theorem, G-lifts the remainder, and uses `F(target) in M` for contradiction. Multi-target extraction produces `neg(target_1 and ... and target_k)`, but `F(target_1 and ... and target_k) in M` is NOT available from individual `F(target_i) in M`.

## Confidence Level

- **Path A (bundle-level coherence)**: BLOCKED -- truth lemma and semantics require same-family witnesses (verified at Truth.lean:128, ParametricTruthLemma.lean:365-380)
- **Primary recommendation (Path C)**: 85% -- partial but definitely achievable; closes backward, leaves forward as precisely scoped sorry
- **All five proposed strategies as originally stated**: 5-15% each -- each hits the same fundamental obstacle (Until/F non-persistence through Lindenbaum extensions)
- **Quasimodel approach (literature)**: 50% -- would solve the problem but requires ~2000 LOC of new infrastructure replacing the chain construction entirely

## Risk Summary

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| Truth lemma requires same-family Until witness | Path A fails | CONFIRMED | Truth.lean:128 and ParametricTruthLemma.lean:365-380 verified |
| G-lift cannot be extended to multi-target | Strategies 1, 5 fail | Confirmed | Already verified in codebase |
| F-persistence through Lindenbaum impossible | Strategies 2, 3 fail | Confirmed | Fundamental architectural limitation |
| Backward Until step transfer needs chain-specific mechanism | Delays Path C | Medium | Already parameterized in UntilSinceCoherence.lean |

## Appendix: Why the Problem Is Hard

The root cause is a tension between two properties of the chain construction:

1. **Lindenbaum extension freedom**: Each chain step is a Lindenbaum extension of a seed. The extension can freely add ANY consistent formula, including negations of Until formulas.

2. **Until persistence requirement**: Forward Until needs `(phi U psi)` to survive through chain steps until psi appears. This requires either (a) `(phi U psi)` in the seed (blocked: not G-liftable), or (b) `(phi U psi)` derivable from the seed (blocked: no derivation from g_content alone).

Under STRICT temporal semantics (the original axiom system), this was already blocked. Under BX REFLEXIVE semantics, we gain `G(a) -> a` (BX1) and `X(a) <-> a`, but these help with the base case (s=t), not the inductive case (s>t). The inductive case requires information to persist through a non-deterministic Lindenbaum extension, which is fundamentally incompatible with the freedom of Lindenbaum's lemma.

The only known resolutions in the literature are:
1. **Deterministic chains** (x_content bidirectional) -- but these are constant under reflexive X, making forward_F vacuous
2. **Quasimodels** (GHR 1994) -- constraint-satisfaction approach that avoids Lindenbaum entirely
3. **Filtration** (finite model property) -- already implemented in the codebase for decidability, but uses different infrastructure

The bundle-level approach (Path A) sidesteps the issue by relaxing the per-family requirement, which may be mathematically justified since the canonical model evaluates truth across all families anyway.
