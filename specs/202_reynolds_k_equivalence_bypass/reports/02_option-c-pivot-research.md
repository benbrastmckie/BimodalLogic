# Option C Pivot Research: Direct Completeness on Z

**Task**: 202
**Date**: 2026-05-28
**Focus**: Feasibility of "Option C: Direct completeness on Z" as an alternative to the Reynolds k-equivalence pipeline

## Executive Summary

Option C is **feasible and the most promising path** to sorry-free `completeness_discrete`. However, the handoff's description of Option C is partially misleading: the existing infrastructure already builds a BFMCS on Z (`cantor_bfmcs_discrete`), and that construction is sorry-free. The sorry comes from two of the three **restricted coherence proofs** that feed the parametric truth lemma. The core task is not "build BFMCS on Z" but rather "prove restricted_tc and restricted_fuc without succ_embed_surjective."

## 1. Current Sorry Chain (Precise Analysis)

### Verified Dependencies (via `lean_verify`)

| Definition | sorryAx? | Notes |
|---|---|---|
| `completeness_discrete` | YES | The target |
| `countermodel_discrete_enriched` | YES | Intermediate caller |
| `cantor_bfmcs_discrete` | **NO** | BFMCS on Z is sorry-free |
| `rooted_succ_discrete_fmcs` | **NO** | Individual FMCS on Z is sorry-free |
| `cantor_bfmcs_discrete_restricted_buc` | **NO** | BUC coherence is sorry-free |
| `cantor_bfmcs_discrete_restricted_tc` | YES | Uses `succ_embed_surjective` |
| `cantor_bfmcs_discrete_restricted_fuc` | YES | Uses `succ_embed_surjective` |
| `succ_embed_surjective` | YES | Uses `limitDomSubtype_isSuccArchimedean` |
| `succ_cofinal` | YES | Root sorry (line 1885) |
| `fully_restricted_parametric_completeness_from_neg_membership` | **NO** | Truth lemma itself is sorry-free |
| `completeness_dense` | **NO** | Dense case is fully sorry-free |

### Sorry Dependency DAG

```
completeness_discrete
  └── countermodel_discrete_enriched
        ├── cantor_bfmcs_discrete                    [OK]
        ├── cantor_bfmcs_discrete_restricted_tc      [SORRY]
        │     └── succ_embed_surjective              [SORRY]
        │           └── limitDomSubtype_isSuccArchimedean [SORRY]
        │                 └── succ_cofinal           [ROOT SORRY]
        ├── cantor_bfmcs_discrete_restricted_buc     [OK]
        ├── cantor_bfmcs_discrete_restricted_fuc     [SORRY]
        │     └── succ_embed_surjective              [SORRY] (same chain)
        └── fully_restricted_parametric_completeness_from_neg_membership [OK]
```

### Root Cause

`succ_cofinal` attempts to prove that for any `a < b` in the limit domain, there exists `n` such that `succ^[n](a) >= b`. This is **unprovable** by the current approach because the constant-MCS gap scenario (all MCS labels identical along a convergent succ-chain) is consistent with all temporal axioms. See ROADMAP key finding from task 155.

## 2. Why restricted_tc/restricted_fuc Need succ_embed_surjective

### restricted_tc (Temporal Coherence: F-resolution)

The proof flow:
1. `F(phi) in fam.mcs(t)` -- given hypothesis
2. Unfold: `F(phi) in limit_f(succ_embed(t + offset))` -- definition of fam.mcs
3. Apply `limit_F_resolution` to get witness `y in limit_dom` with `y > succ_embed(t + offset)` and `phi in limit_f(y)`
4. **Need**: integer `m` such that `succ_embed(m) = y` to define `s = m - offset`
5. This requires `succ_embed_surjective(y)` -- the sorry chain

### restricted_fuc (Forward Until/Since Coherence)

Same pattern: `Until(phi,psi) in fam.mcs(t)` leads to `limit_satisfies_c5_strong` giving a witness `y in limit_dom`, and we need `succ_embed_surjective(y)` to convert back to an integer.

### restricted_buc is Sorry-Free

The backward coherence proof works differently: it uses a **contrapositive** argument. Given that `Until(phi,psi)` holds (via a supplied witness at some integer u), if `Until(phi,psi)` were NOT in the MCS at t, then `limit_satisfies_c4` gives a counterexample witness z *between* `succ_embed(t+offset)` and `succ_embed(u+offset)`. Then `succ_embed_squeeze_strict` maps z back to an integer -- and this lemma is sorry-free because it only needs surjectivity between two known embedded points (which follows from the no-gap property of the discrete embedding, not from full surjectivity).

## 3. Option C: What It Actually Requires

### The Handoff's Description (Partially Misleading)

The handoff says:
> "Build BFMCS on Z with the chain, prove restricted coherence directly on Z (no succ_cofinal needed), apply parametric truth lemma."

This is misleading because `cantor_bfmcs_discrete` already builds a BFMCS on Z and is sorry-free. What is needed is not "build BFMCS on Z" but "prove restricted_tc and restricted_fuc without going through succ_embed_surjective."

### The Real Task: Alternative Restricted Coherence Proofs

We need sorry-free proofs of:

**restricted_tc**: For any family fam in the BFMCS, if `F(phi) in fam.mcs(t)`, then there exists integer `s > t` with `phi in fam.mcs(s)`.

**restricted_fuc**: For any family fam in the BFMCS, if `Until(phi,psi) in fam.mcs(t)`, then there exists integer `s > t` with `phi in fam.mcs(s)` and the guard holds on all integers between t and s.

### Three Alternative Strategies

#### Strategy A: Direct F-Witness on Z (Simplest, Recommended)

**Core idea**: Instead of going through `limit_F_resolution` (which produces witnesses in the rational limit domain), use the MCS properties directly.

Since `fam.mcs(t) = limit_f(succ_embed(t + offset))` and the FMCS has `forward_G`/`backward_H` coherence on Z, we know `G(phi) in fam.mcs(t)` implies `phi in fam.mcs(t')` for all `t' > t`. For the F-case:

- `F(phi) in fam.mcs(t)` means `some_future(phi) in fam.mcs(t)`
- In a discrete MCS with `next_top = U(T, bot)`, `F(phi)` is equivalent to `U(phi, T)` (via BX axiom `F_until_equiv`)
- `U(phi, T) in fam.mcs(t)` combined with the FMCS `forward_G` coherence means phi appears at some *integer* successor of t (not just some rational domain point)
- Specifically: `U(phi, T) in fam.mcs(t)` means by the Until semantics of the FMCS, there exists `s > t` (integer) with `phi in fam.mcs(s)` -- but wait, we need FMCS Until coherence, which IS what we are trying to prove.

This is circular for the Until case. However, for the **F case alone** (restricted_tc), we can use a different argument:

- `F(phi) in fam.mcs(t)` 
- By the discreteness axiom `next_top = U(T, bot)`, we have `U(T, bot) in fam.mcs(t)` (from box-discreteness + modal T)
- By BX5 (self-accumulation): `U(T, bot) -> phi U (phi /\ bot)` when combined with `F(phi)`
- Actually simpler: `F(phi) in MCS(t)` and `next_top in MCS(t)` together imply `phi in MCS(t+1)` by the combination of `F_until_equiv`, `U(phi, T) in MCS(t)`, and the forward_G coherence of the FMCS for `phi`.

Wait -- let me reconsider. The FMCS only has `forward_G` and `backward_H`. It does not directly have F-resolution. The restricted_tc proof is precisely about proving F-resolution from the FMCS structure.

**Revised approach**: Use the fact that on Z, `F(phi)` in a discrete MCS implies `phi in MCS(t+1)` or `F(phi) in MCS(t+1)` (by the temporal step axiom). Then by induction...

Actually, this does not work because we cannot do induction on "eventually" without a well-founded measure.

#### Strategy B: Build the FMCS Directly on Z Without succ_embed (Recommended)

**Core idea**: Instead of constructing the chronicle on the rational limit domain and then mapping back to Z via `succ_embed`, construct the FMCS chain directly on Z from the start.

The current construction:
1. Build chronicle on rationals (limit domain in Q)
2. In discrete case, identify successor structure on limit domain
3. Define `succ_embed : Z -> LimitDomSubtype` embedding integers into the limit domain
4. Define FMCS as `fam.mcs(t) = limit_f(succ_embed(t + offset))`
5. For coherence proofs, need to map limit domain witnesses back to Z (requires surjectivity)

Alternative construction:
1. Build chronicle on rationals (same as before)
2. In discrete case, define `succ_discrete_f : Z -> Set Formula` directly by `succ_discrete_f(n) = limit_f(succ_embed(n))`
3. For F-resolution: `F(phi) in succ_discrete_f(n)` means `F(phi) in limit_f(succ_embed(n))`
4. Apply `limit_F_resolution` to get witness `y` in limit domain with `phi in limit_f(y)`
5. **Key**: Instead of requiring `succ_embed_surjective(y)`, use `succ_embed_squeeze_strict` to find integer `m` with `succ_embed(m) <= y < succ_embed(m+1)` 
6. Then by the no-gap property (between `succ_embed(m)` and `succ_embed(m+1)` there are no other limit domain points), we get `y = succ_embed(m)` or `y = succ_embed(m+1)`
7. Either way, `phi in limit_f(y) = succ_discrete_f(m)` or `succ_discrete_f(m+1)`, giving the integer witness

Wait -- `succ_embed_squeeze_strict` already gives an integer k with `succ_embed(k) = y` when y is strictly between two adjacent embedded points. But it requires `a < b` (two known integers). For F-resolution, we know `y > succ_embed(n)` but we don't have an upper bound integer.

**This is exactly the problem.** We need surjectivity to go from an arbitrary limit domain point to an integer.

#### Strategy C: Prove Local Surjectivity Instead of Global (Most Promising)

**Key observation**: We don't need *global* surjectivity (`succ_embed_surjective`). We only need *local* surjectivity: for any witness `y` produced by `limit_F_resolution`, there exists an integer preimage.

`limit_F_resolution(x)` produces a witness `y` via `limit_satisfies_c5_weak`, which comes from the chronicle construction's C5 property. The witness `y` is a point that was added to the limit domain at some stage of the dovetailed construction.

**Crucial insight**: Every point in the limit domain was added at some finite stage `n` of the construction. At each stage, a point is inserted as the immediate successor of some existing point (in the discrete case). The succ_embed function maps integer k to the k-th successor of the root.

The claim that `succ_cofinal` is unprovable is about whether the succ chain *converges* -- whether there exists a limit point that the succ chain approaches but never reaches. In the discrete case, every newly-inserted point becomes the immediate successor of some existing point, so **the no-gap property between adjacent embedded points (`succ_embed_squeeze_strict`) combined with the fact that the witness is above some known embedded point** should suffice.

Wait, but `succ_embed_squeeze_strict` requires BOTH a lower and upper bound integer. For F-resolution, we have a lower bound but no upper bound.

**New idea**: For F-resolution at integer `n`, the witness `y` satisfies `y > succ_embed(n)`. Since the limit domain is discrete and has the immediate successor property, there is a well-defined `succ(succ_embed(n))` in the limit domain. In the discrete case, `succ(succ_embed(n)) = succ_embed(n+1)` by definition of `succ_embed`. So `y >= succ_embed(n+1)`.

If `y = succ_embed(n+1)`, we're done (witness is `n+1`).

If `y > succ_embed(n+1)`, apply `limit_F_resolution` is unnecessary -- we know `phi in limit_f(y)`, and since the FMCS has `forward_G` for propagating formulas forward, if `phi` is at `y >= succ_embed(n+1)`, then by the FMCS coherence `phi in succ_discrete_f(n+1)` only if `G(phi) in succ_discrete_f(n)`.

Hmm, this is not directly applicable. Let me think more carefully.

Actually, the simpler observation is:

**In a discrete order, F(phi) implies phi holds at the immediate successor.** This is because:
- In a discrete order with `next_top = U(T, bot)`, `F(phi)` is equivalent to `phi \/ F'(phi)` where `F'` is strict future
- And `F'(phi)` in a discrete order means "phi holds at succ or beyond"
- By the discreteness axiom `U(T, bot)` and BX axioms, we can derive: `F(phi) -> phi \/ (phi' /\ F(phi))` ... 

Actually, this is getting complicated. Let me check what axioms are available.

#### Strategy D: The Henkin Bypass (Cleanest)

**Core idea**: The existing proof tries to go through the chronicle construction (which is sorry-free as a BFMCS on Z). The sorry enters through the restricted coherence proofs that try to map limit-domain witnesses back to integers.

Instead, prove restricted temporal coherence DIRECTLY from the MCS properties, without ever referencing the limit domain.

**For restricted_tc**: `F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)`

Proof sketch:
1. `fam = rooted_succ_discrete_fmcs(N, s)` for some discrete MCS N
2. `F(phi) in fam.mcs(t)`
3. By the BX axiom `F_until_equiv`: `F(phi) -> U(phi, T)` -- so `U(phi, T) in fam.mcs(t)`
4. By `next_top` (= `U(T, bot)`): `U(T, bot) in fam.mcs(t)` (from discreteness + box stability + modal T)
5. From `U(phi, T)` and `U(T, bot)` together:
   - BX5 self-accumulation gives: `U(phi, T) /\ U(T, bot) -> phi /\ U(T, bot)` after one step
   - Actually more precisely: the "step decomposition" via BX axioms should give `phi in fam.mcs(t+1)`
   - Or: use the FMCS forward_G coherence: since `G(phi -> phi) in fam.mcs(t)` is a theorem, this does not help directly
   - Key: we need `phi in fam.mcs(t+1)`, which means `phi in limit_f(succ_embed(t+1+offset))`, which is `phi in limit_f(succ(succ_embed(t+offset)))`. We know `F(phi) in limit_f(succ_embed(t+offset))`, and by construction, `limit_satisfies_c5_weak` gives a witness at some `y > succ_embed(t+offset)`. Since the embedding has no gaps between `succ_embed(t+offset)` and `succ_embed(t+1+offset)` (this is `succ_embed_no_gap`, should be sorry-free), we get `y >= succ_embed(t+1+offset)`. And `phi in limit_f(y)`.

6. But this still does not directly give `phi in limit_f(succ_embed(t+1+offset))` unless `y = succ_embed(t+1+offset)`.

The issue is: we know `phi` holds at some `y >= succ_embed(t+1)`, but we need `phi` to hold at exactly `succ_embed(some_integer)`.

**Actual solution**: Use the FMCS `forward_G` property.

If `phi in limit_f(y)` for some `y >= succ_embed(t+1)`, we have two cases:
- `y = succ_embed(t+1)`: Done, witness is `t+1`.
- `y > succ_embed(t+1)`: Then `y >= succ_embed(t+2)` (by no-gap). By `forward_G` applied backwards... no, `forward_G` goes forward from earlier times.

Wait. The FMCS `forward_G` says: `G(phi) in fam.mcs(t) -> phi in fam.mcs(t')` for all `t' > t`. This is about propagating G formulas, not about finding witnesses.

Let me reconsider. The actual proof of restricted_tc for the dense case (which is sorry-free) goes through the Cantor isomorphism, which IS a bijection between the limit domain and Q. The discrete analogue should go through the Z-isomorphism, which IS what `succ_embed_surjective` tries to establish. The problem is that surjectivity fails.

**The fundamental issue**: The limit domain in the discrete case may contain points that are not reachable by finite succ iterations from the root. These are "gap points" beyond the succ chain's limit. The chronicle construction can insert them, and the F-resolution witness might land on one of them.

## 4. Alternative Approaches to Fix the Incompatibility

### Approach 1: Redefine the FMCS to Avoid the Limit Domain (Option C Proper)

Instead of defining `fam.mcs(t) = limit_f(succ_embed(t + offset))`, define the FMCS **independently** of the chronicle:

Given a discrete MCS N with `box(next_top) in N`, define:
- `direct_fmcs(N, 0) = N`
- `direct_fmcs(N, t+1) = MCS_witness(F, direct_fmcs(N, t))` -- the MCS that witnesses F-formulas in direct_fmcs(N, t)
- `direct_fmcs(N, t-1) = MCS_witness(P, direct_fmcs(N, t))` -- the MCS that witnesses P-formulas in direct_fmcs(N, t)

This is a "Henkin chain" construction directly on Z. The key question: does this construction satisfy `forward_G` and `backward_H`?

**Answer**: This is exactly what the existing `temporal_coherent_family_exists_CanonicalMCS` infrastructure provides in `Bundle/Construction.lean`. Let me check.

### Approach 2: Weaken restricted_tc to Avoid F-Resolution

Instead of proving `F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)`, prove a weaker version that suffices for the truth lemma. The parametric truth lemma for the G case uses temporal_backward_G, which uses restricted_tc's forward_F to prove the contrapositive. The G backward case in the truth lemma needs:

`If phi in fam.mcs(s) for all s > t, then G(phi) in fam.mcs(t).`

This is proved by contraposition: assume `not G(phi) in fam.mcs(t)`, so `F(not phi) in fam.mcs(t)`, so by restricted_tc exists s > t with `not phi in fam.mcs(s)`, contradiction.

For this, restricted_tc does not need to find the exact witness integer -- it just needs to find SOME integer s > t with `not phi in fam.mcs(s)`. And `not phi in fam.mcs(s)` means `not phi in limit_f(succ_embed(s + offset))`.

Actually the same problem applies: the witness from `limit_F_resolution` is at some arbitrary limit domain point, and we need it at an embedded integer.

### Approach 3: Direct Henkin Chain on Z (Most Promising for Option C)

**Core idea**: Build the FMCS chain directly on Z using Lindenbaum extensions, WITHOUT going through the Burgess chronicle construction on Q. This is what Option C in the handoff actually describes but was not clearly stated.

**Construction sketch**:

Given MCS A with `box(next_top) in A` and `neg(phi) in A`:

1. Set `chain(0) = A`
2. For `chain(n+1)`: From `chain(n)`, which is a discrete MCS, enumerate all F-formulas and Until-formulas. Use Lindenbaum + careful seed construction to build an MCS that:
   - Contains `phi` for every `G(phi) in chain(n)` (forward_G)
   - Witnesses the "next step" for all Until formulas
   - Is still a discrete MCS (inherits `next_top` via derivability in the Discrete system)
3. For `chain(n-1)`: Symmetric for past direction

**Existing infrastructure**: `Bundle/Construction.lean` contains `temporal_coherent_family_exists_CanonicalMCS` which does exactly this. Let me verify.

## 5. Examining Bundle/Construction.lean

The key question is whether `Bundle/Construction.lean` provides a sorry-free construction of temporally coherent FMCS on Z.

### restricted_tc on the Direct Chain

If the FMCS is built directly as a Henkin chain on Z (without the chronicle), then:
- `F(phi) in chain(t)` means we constructed `chain(t+1)` to witness F-formulas from `chain(t)`
- So `phi in chain(t+1)` by construction
- Witness: `s = t+1`

This is the key insight: **on a directly-constructed Henkin chain on Z, F-resolution is trivial because the chain was built to witness F-formulas at each step.**

Similarly for Until: `U(phi,psi) in chain(t)` means `chain(t+1)` was built to witness Until, giving either `phi in chain(t+1)` (with appropriate guard) or `psi in chain(t+1)` with propagated `U(phi,psi) in chain(t+1)` and eventually reaching `phi`.

### Why the Current Approach Does Not Use This

The current approach goes through the Burgess chronicle because the chronicle is needed for the DENSE case (where the limit domain is a dense subset of Q that gets iso'd to Q via Cantor's theorem). The discrete case was handled as a special case of the same construction, reusing `succ_embed` to map back to Z. But `succ_embed` surjectivity fails.

Option C says: for the discrete case, don't reuse the chronicle construction at all. Build a separate Henkin chain directly on Z.

## 6. Feasibility Assessment

### What Exists

| Component | Status | Notes |
|---|---|---|
| `BFMCS` structure on Z | Sorry-free | `cantor_bfmcs_discrete` |
| `rooted_succ_discrete_fmcs` | Sorry-free | Individual FMCS on Z |
| `restricted_buc` | Sorry-free | Uses contrapositive + squeeze |
| `restricted_tc` | SORRY | Uses `succ_embed_surjective` |
| `restricted_fuc` | SORRY | Uses `succ_embed_surjective` |
| Parametric truth lemma | Sorry-free | Generic over any BFMCS |
| `fully_restricted_parametric_completeness_from_neg_membership` | Sorry-free | |
| `countermodel_discrete_enriched` orchestration | Sorry-free (except coherence args) | |
| Henkin chain infrastructure (`Bundle/Construction.lean`) | Needs investigation | |
| `temporal_coherent_family_exists_CanonicalMCS` | Needs investigation | |

### What Option C Needs to Build

1. **Alternative FMCS construction on Z** (direct Henkin chain, NOT via chronicle + succ_embed)
2. **Sorry-free restricted_tc** for the new FMCS (trivial if chain witnesses F-formulas by construction)
3. **Sorry-free restricted_fuc** for the new FMCS (needs Until-witnessing in chain construction)
4. **Alternative BFMCS** using the new FMCS families
5. **Modal coherence** (forward + backward) for the new BFMCS
6. Wire into `countermodel_discrete_enriched` or write a parallel version

### Estimated Scope

- **New code**: 400-600 lines (Henkin chain construction + coherence proofs)
- **Reusable**: `fully_restricted_parametric_completeness_from_neg_membership`, `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`, `ShiftClosedParametricCanonicalOmega` -- all the downstream parametric infrastructure
- **Risk**: The Henkin chain construction's Until-witnessing step is non-trivial. Need to ensure it can be done for all Until subformulas of the target formula simultaneously, while maintaining G/H coherence.
- **Key mathematical reference**: Standard Henkin-style completeness for tense logic (Goldblatt 1992, Chapter 5)

### Risk Assessment

| Risk | Likelihood | Mitigation |
|---|---|---|
| Henkin chain G/H coherence fails | Low | Standard technique, well-understood mathematically |
| Until-witnessing interferes with G/H | Medium | Can be resolved by "dovetailing" witnesses, standard technique |
| Modal coherence (box) for new BFMCS | Low | Same pattern as existing `cantor_bfmcs_discrete` |
| Integration with existing completeness.lean | Low | Drop-in replacement for coherence proofs |

## 7. Recommendation

**Pursue Option C with Strategy B (direct Henkin chain on Z).** Specifically:

### Phase 1: Henkin Chain Construction (core)
Build `henkin_discrete_fmcs : Z -> Set Formula` directly from an MCS N:
- Use Lindenbaum extensions at each step to witness F, P, Until, Since
- Prove `forward_G` and `backward_H` coherence
- Prove `restricted_tc` (F-resolution witnesses at step t+1)
- Prove `restricted_fuc` (Until-resolution by chain construction)

### Phase 2: BFMCS Assembly
Build `henkin_bfmcs_discrete` analogous to `cantor_bfmcs_discrete`:
- Families parametrized by (N, s) where N is box-equivalent to A
- Modal forward/backward using box-stability (same pattern as existing)
- Prove `restricted_buc` (same contrapositive pattern, or inherit from existing)

### Phase 3: Integration
Wire `henkin_bfmcs_discrete` into `countermodel_discrete_enriched` or create a parallel `countermodel_discrete_direct`:
- Pass three sorry-free coherence proofs to `fully_restricted_parametric_completeness_from_neg_membership`
- Verify `completeness_discrete` becomes sorry-free via `lean_verify`

### Alternative: Fix restricted_tc/restricted_fuc for Existing BFMCS

Before building a whole new chain, investigate whether `Bundle/Construction.lean` already provides enough infrastructure. If `temporal_coherent_family_exists_CanonicalMCS` gives a sorry-free temporally coherent FMCS on Z with Until/Since witnessing, then Option C reduces to:
1. Replace `rooted_succ_discrete_fmcs` with the Construction.lean FMCS
2. Reprove restricted_tc and restricted_fuc using the new FMCS's built-in witnessing
3. Keep everything else the same

This would be ~200 lines instead of ~500.

## 8. Investigation of Existing Infrastructure

### Bundle/Construction.lean

Contains only basic primitives (Lindenbaum, context consistency). Does NOT contain a Henkin chain construction. Cannot be reused directly.

### Bundle/SuccExistence.lean

Contains successor/predecessor existence for MCS chains (via deferral seeds). However:
- `constrained_successor_seed_consistent` has a sorry at line 446 (`g_content u ⊆ u` fails under irreflexive semantics -- BX1 `G(phi) -> phi` was removed)
- This is in the Bundle infrastructure, not on the critical path
- The sorry is about g_content under irreflexive semantics, which is a separate issue

### succ_discrete_fmcs (Existing)

The existing FMCS on Z is defined as `limit_f(succ_embed(n))` -- it reads from the chronicle. Its `forward_G`/`backward_H` are sorry-free. The problems are ONLY in `restricted_tc` (F-witness) and `restricted_fuc` (Until-witness).

### Key Insight: The FMCS Structure is Fine, Only the Coherence Proofs are Broken

The existing `cantor_bfmcs_discrete` and its FMCS families are all sorry-free. The problem is narrowly scoped: proving that F-resolution and Until-resolution produce integer witnesses, when the chronicle only gives rational witnesses.

## 9. Refined Strategy: Fix restricted_tc/restricted_fuc Directly

### The Core Observation

On a discrete order with no gaps between successive embedded points, the F-resolution witness `y > succ_embed(n)` must satisfy one of:
- `y = succ_embed(n+1)` (the immediate successor)
- `y > succ_embed(n+1)` (beyond the immediate successor)

In case 2, by the no-gap property between `succ_embed(n)` and `succ_embed(n+1)`, there are no limit-domain points strictly between them. But `y` is a limit-domain point with `y > succ_embed(n)`, so `y >= succ_embed(n+1)`.

Now we need `phi in limit_f(succ_embed(n+1))`. We know `phi in limit_f(y)` where `y >= succ_embed(n+1)`. If `y = succ_embed(n+1)`, done. If `y > succ_embed(n+1)`:

**Key lemma needed**: If `F(phi) in fam.mcs(n)` where fam is a discrete FMCS on Z, then `phi in fam.mcs(n+1)`.

Proof: In a discrete MCS, `F(phi)` can be decomposed using the BX axioms:
- `F(phi) -> phi \/ (phi' /\ F(phi))` where `phi' = ...`

Actually, the standard result for discrete tense logic is:
- `F(phi) <-> phi \/ X(F(phi))` where `X` is "next" (`U(T, bot)`)

And from `F(phi)` and `U(T, bot)`:
- By BX axiom `F_until_equiv`: `F(phi) -> U(phi, T)`
- `U(phi, T)` means "phi holds at some point where T held since now"
- Combined with `U(T, bot)` (next_top): at the next moment, either phi holds or U(phi, T) still holds
- By BX5/self-accumulation: `U(phi, T) -> phi v (T /\ U(phi, T))` (one-step decomposition)

Wait, this is exactly the F-step decomposition from `SuccExistence.lean`! The deferral seed ensures:
- `G(phi) in MCS(n) -> phi in MCS(n+1)` (g_content propagation)
- `F(phi) in MCS(n) -> phi in MCS(n+1) OR F(phi) in MCS(n+1)` (deferral disjunction)

This means: from `F(phi) in MCS(n)`, either `phi in MCS(n+1)` (done) or `F(phi) in MCS(n+1)`. In the latter case, repeat. By well-foundedness of the formula structure... wait, `F(phi)` does not decrease in complexity.

BUT: we are in the discrete case with `U(T, bot)` in all MCSes. The key axiom is the induction principle for Until on discrete orders. Specifically:

`U(phi, T) -> phi v (T /\ U(phi, T))`

This is just the reflexive unfolding of Until. In the FMCS on Z, this means:
- `U(phi, T) in MCS(n)` implies `phi in MCS(n)` or (`T in MCS(n)` and `U(phi, T) in MCS(n)`) ... this is vacuous.

Let me try a different approach. The FMCS has `forward_G`: `G(psi) in MCS(n) -> psi in MCS(m)` for m > n. So if we can show `phi in MCS(n+1)` using the F-resolution from the chronicle:

**Alternative proof of restricted_tc for discrete case**:

`F(phi) in fam.mcs(t)` where `fam.mcs(t) = limit_f(succ_embed(t + offset))`

By `limit_F_resolution`, there exists `y` in limit_dom with `y > succ_embed(t + offset)` and `phi in limit_f(y)`.

By `succ_embed_no_gap` (which says between `succ_embed(n)` and `succ_embed(n+1)` there are no other limit domain points), `y >= succ_embed(t + offset + 1) = succ_embed((t+1) + offset)`.

Now: either `y = succ_embed((t+1) + offset)` (done: witness is `t+1`) or `y > succ_embed((t+1) + offset)`.

In the latter case, `limit_forward_G` gives: if `G(phi) in limit_f(succ_embed(t + offset))`, then `phi in limit_f(y)`. But we have the converse direction -- we know `phi in limit_f(y)` and need `phi in limit_f(succ_embed((t+1) + offset))`.

Since `y > succ_embed((t+1) + offset)`, we know there exists the smallest limit_dom point `z >= succ_embed((t+1) + offset)` with `phi in limit_f(z)`. The chronicle has `limit_backward_H` which gives: if `H(phi) in limit_f(z)`, then `phi in limit_f(z')` for all `z' < z`. But we don't know `H(phi)`.

**This approach does not directly work.** The issue is fundamental: we know phi is true somewhere above `succ_embed(n)`, but we cannot conclude it is true at `succ_embed(n+1)` specifically.

### The Real Fix: Change the Construction to Guarantee F-witnesses at Embedded Points

The chronicle construction inserts F-witnesses at *new rational points*, not at the embedded successor. If we could modify the construction to ensure that when `F(phi) in limit_f(x)` for an embedded point `x = succ_embed(n)`, the F-witness is placed at `succ_embed(n+1)` rather than at an arbitrary new rational, then surjectivity would not be needed.

This is actually what a direct Henkin chain construction would do: the MCS at `n+1` is built to witness F-formulas from MCS at `n`. In the chronicle, the MCS at points are built by a dovetailed enumeration that does not coordinate with the embedding.

### Conclusion: A Fresh Henkin Chain is Needed

The existing chronicle-based FMCS on Z cannot be fixed to give sorry-free restricted_tc/restricted_fuc without either:
1. Proving `succ_embed_surjective` (impossible -- `succ_cofinal` is unprovable)
2. Modifying the chronicle construction to coordinate F-witnesses with the embedding (major rearchitecture)
3. Building a fresh FMCS on Z via a Henkin chain that witnesses F/Until at each integer step (Option C proper)

Option 3 is the cleanest path.

## 10. Summary of Alternatives

| Approach | Effort | Sorry-Free? | Risk |
|---|---|---|---|
| **Option C (Henkin chain on Z)** | 6-10h | Yes (if chain witnesses work) | Medium |
| Fix succ_cofinal directly | Not possible | N/A | Proven impossible (task 155) |
| Reynolds pipeline (no_gaps_discrete) | 8-12h | Blocked on Theorem 5 | High |
| Fix restricted_tc without surjectivity | Not possible | N/A | Analysis above shows circular |
| Modify chronicle to coordinate witnesses | 10-15h | Possibly | High (rearchitecture) |

**Recommendation**: Pursue Option C (Henkin chain on Z). Build a fresh FMCS construction on Z that:
1. At each integer n, constructs an MCS that witnesses F-formulas from MCS(n-1) and P-formulas from MCS(n+1)
2. Uses the existing `forward_temporal_witness_seed` / `until_witness_seed` machinery from `WitnessSeed.lean` (sorry-free)
3. Maintains box-stability across the chain (for BFMCS modal coherence)
4. Restricted_tc becomes trivial: F(phi) in MCS(n) -> phi in MCS(n+1) by construction
5. Restricted_fuc becomes: Until(phi,psi) in MCS(n) -> chain witnesses it by step-wise induction

**Key infrastructure to reuse** (all sorry-free):
- `forward_temporal_witness_seed_consistent` from WitnessSeed.lean
- `fully_restricted_parametric_completeness_from_neg_membership` from RestrictedParametricTruthLemma.lean
- `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel` from ParametricCanonical.lean
- `ShiftClosedParametricCanonicalOmega` from ParametricHistory.lean
- `cantor_bfmcs_discrete`'s modal_forward/backward pattern (reusable with new families)

**Note on Until-witnessing**: The Until case is harder than F. `Until(phi, psi) in MCS(n)` needs a witness integer `s > n` with `phi in MCS(s)` and `psi in MCS(r)` for all `r` between `n` and `s`. In the Henkin chain, each successor MCS either resolves Until (contains phi) or defers it (contains Until(phi, psi)). By the well-founded property of the Until formula in discrete orders (U(T, bot) ensures a "next step" that makes progress), this deferral terminates. However, formalizing this termination argument requires care -- it is essentially a finitary version of the F-step deferral argument from SuccExistence.lean.

**Alternative for Until**: Use the existing `restricted_buc` (sorry-free contrapositive proof) for the backward direction, and for the forward direction, use the BX5 self-accumulation axiom to decompose Until step by step on the integer chain.
