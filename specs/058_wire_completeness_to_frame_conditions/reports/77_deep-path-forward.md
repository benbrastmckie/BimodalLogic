# Deep Research Report: Path Forward for Task 58

**Task**: Wire completeness to frame conditions (eliminate 3 sorries in Completeness.lean)
**Date**: 2026-03-27
**Status**: Research complete -- identifies root cause and viable path forward

## 1. Current State of the Codebase

### 1.1 Target Sorries

Three sorries in `Theories/Bimodal/FrameConditions/Completeness.lean`:

| Theorem | Line | Status |
|---------|------|--------|
| `dense_completeness_fc` | 120 | sorry (direct) |
| `discrete_completeness_fc` | 163 | sorry (direct) |
| `bundle_validity_implies_provability` | 214 | sorry (blocks completeness_over_Int) |

All three depend on `sorryAx` per `lean_verify`.

### 1.2 Sorry-Free Building Blocks (Verified)

The following theorems are PROVEN (no `sorryAx`):

| Theorem | File | What it does |
|---------|------|-------------|
| `boxClassFamilies_bundle_forward_F` | UltrafilterChain.lean | F-witness exists in SOME family |
| `boxClassFamilies_bundle_backward_P` | UltrafilterChain.lean | P-witness exists in SOME family |
| `boxClassFamilies_bundle_temporally_coherent` | UltrafilterChain.lean | Bundle-level temporal coherence |
| `construct_bfmcs_bundle` | UltrafilterChain.lean | Build BFMCS_Bundle from any MCS |
| `mcs_neg_gives_countermodel` | UltrafilterChain.lean | neg(phi) in MCS -> phi not at eval point |
| `bundle_completeness_contradiction` | UltrafilterChain.lean | Completeness contradiction from consistent neg(phi) |
| `not_provable_implies_neg_consistent` | UltrafilterChain.lean | Not provable -> neg consistent |
| `temporal_theory_witness_exists` | UltrafilterChain.lean | F(phi) in MCS -> witness W with phi, G-agree, box-agree |
| `past_theory_witness_exists` | UltrafilterChain.lean | P(phi) in MCS -> witness W with phi, H-agree, box-agree |
| `parametric_canonical_truth_lemma` | ParametricTruthLemma.lean | Full bidirectional truth lemma |
| `parametric_shifted_truth_lemma` | ParametricTruthLemma.lean | Truth lemma with shift-closed Omega |
| `parametric_algebraic_representation_conditional` | ParametricRepresentation.lean | Completeness IF given construct_bfmcs |
| `consistent_implies_satisfiable` | AlgebraicRepresentation.lean | Algebraic completeness (ultrafilters) |
| `constrained_successor_seed_consistent` | SuccExistence.lean | Successor seed consistent (seed subset of u) |
| `constrained_successor_succ` | SuccExistence.lean | Successor satisfies Succ relation |

### 1.3 Sorry Chain Structure

```
Completeness.lean sorries
  └── Need: valid_over Int phi -> Nonempty ([] ⊢ phi)
      └── Need: construct_bfmcs producing BFMCS Int with temporally_coherent
          └── Have: construct_bfmcs_bundle producing BFMCS_Bundle (bundle-level coherence)
          └── Gap: BFMCS_Bundle has BUNDLE-level temporal coherence
                   BFMCS needs FAMILY-level temporal coherence
```

## 2. Root Cause Analysis

### 2.1 The Two Levels of Temporal Coherence

**Family-level** (`BFMCS.temporally_coherent`): For each family fam in the bundle,
F(phi) in fam.mcs(t) implies phi in fam.mcs(s) for some s > t **in the same family**.

**Bundle-level** (`BundleTemporallyCoherent`): For each family fam in the bundle,
F(phi) in fam.mcs(t) implies phi in fam'.mcs(s) for some fam' in the bundle and s > t.
The witness **may be in a different family**.

### 2.2 Why Family-Level is Required

The truth lemma (`parametric_canonical_truth_lemma`) needs family-level coherence in
the backward direction for the `all_future` (G) case:

```
all_future backward: If psi is true at all s >= t in world-history tau, then G(psi) in fam.mcs(t)
```

Proof (by contradiction):
1. Assume G(psi) NOT in fam.mcs(t)
2. Then F(neg(psi)) in fam.mcs(t) (by MCS negation completeness)
3. By **family-level** forward_F: neg(psi) in fam.mcs(s) for some s > t **in the same family**
4. But psi is true at tau/s (hypothesis), so psi in fam.mcs(s) (by IH)
5. neg(psi) and psi in same MCS -> contradiction

Step 3 REQUIRES same-family coherence. With bundle-level, neg(psi) is in fam'.mcs(s)
where fam' may differ from fam. The truth at tau/s (step 4) refers to fam, not fam',
so no contradiction arises.

The `all_past` (H) backward case has the symmetric requirement.

The `imp` backward case also requires BOTH directions of the truth lemma (forward and
backward), so we cannot use a "forward-only" truth lemma for completeness.

### 2.3 Why Family-Level Coherence is Hard

Building a single chain (family) satisfying forward_F requires: if F(phi) is in chain(n),
then phi appears at chain(m) for some m > n.

The existing tools for building successor chains:

1. **constrained_successor_seed** (g_content + deferralDisjunctions + p_step_blocking):
   - All elements are subsets of u, so consistency is trivial
   - Satisfies Succ(u, v): G-persistence + F-deferral
   - Problem: F-obligations may be deferred FOREVER (infinite deferral)
   - This is the `f_nesting_is_bounded` issue (proven mathematically FALSE)

2. **temporal_theory_witness_exists** ({phi} + G_theory + box_theory):
   - Resolves one specific F-obligation (phi appears in witness)
   - Preserves G-theory (enables forward_G in chain)
   - Does NOT preserve F-obligations (other F(psi) may be killed)
   - Consistency proven via G-lift argument

The fundamental tension: the G-lift consistency argument requires G(x) in M for every x
in the seed. The constrained_successor_seed contains deferralDisjunctions where G(x) is
NOT in M. The temporal witness seed supports G-lift but doesn't preserve other F-obligations.

### 2.4 Why Enlarging the Seed Fails

Attempts to combine the seeds (resolve one F-obligation while preserving others) all fail:

**Seed: {phi} + G_theory + box_theory + deferralDisjunctions**: For consistency,
if L contains phi and some deferralDisjunction element x, by deduction L' |- neg(phi),
but G-lift on L' fails because G(x) not in M for x in deferralDisjunctions.

**Seed: {phi} + G_theory + box_theory + {F(psi) | F(psi) in M}**: For consistency,
G-lift on F-formula elements requires G(F(psi)) in M. But G(F(psi)) ("always eventually psi")
is NOT implied by F(psi) ("eventually psi"). These are logically independent.

**Seed: {phi} + constrained_successor_seed**: Same failure as above.

### 2.5 Why the Lindenbaum Extension Can Kill F-obligations

When building a temporal witness W for phi from M, the Lindenbaum extension can
introduce G(neg(psi)) for any F(psi) in M. This permanently kills F(psi) in the chain
(G(neg(psi)) propagates forward, making neg(psi) true at all future times).

Concretely: if M contains F(p) and F(neg(p)), and we resolve F(p) at step 1 (putting p
in chain(1)), the Lindenbaum extension might add G(p) to chain(1). Then neg(p) never
appears in the chain, violating forward_F for F(neg(p)).

A model satisfying both F(p) and F(neg(p)) exists (p at time 1, neg(p) at time 2), but
the Lindenbaum construction might not produce it.

## 3. Failed Approaches (All 12 Documented, Plus New Analysis)

1. **Naive multi-BRS G-wrapping**: G(chi) not in u for BRS elements
2. **Subset consistency (BRS subset of u)**: BRS not subset of u by definition
3. **Semantic model building**: Circular (needs consistency to build model)
4. **Compactness arguments**: Restates the problem
5. **proof_by_cases_bot**: Second branch false
6. **"No contradictory pairs" alone**: Insufficient in Hilbert systems
7. **Direct substitution**: Invalid in Hilbert calculus
8. **Deduction theorem elimination**: Produces psi.neg, not bot
9. **Iterated deduction + MP chain**: psi.neg cannot feed the implication chain
10. **neg_not_in_boundary_resolution_set**: Theorem is mathematically FALSE
11. **Simultaneous G-wrapping**: G(psi_i) not derivable from F(psi_i)
12. **Greedy Extension (Plan v17)**: Multi-BRS case blocked by G-wrapping

**New analysis from this research** (approaches 13-16):
13. **Combined temporal witness + deferralDisjunctions seed**: G-lift fails on deferralDisjunctions
14. **Adding F-preservation formulas to seed**: G(F(psi)) not in M, G-lift fails
15. **Simultaneous resolution of all F-obligations**: {psi_1,...,psi_k} + G_theory inconsistent when k > 1
16. **Controlling Lindenbaum to avoid bad G-formulas**: No mechanism available

## 4. Viable Path Forward

### 4.1 The Key Insight: Bundle-Level Truth Lemma

The root problem is that the existing truth lemma requires family-level temporal coherence.
Rather than trying to BUILD family-level coherence (which all 16 approaches above have
failed to do), we should ELIMINATE THE REQUIREMENT.

**Proposed approach**: Write a new truth lemma that works with `BFMCS_Bundle`
(bundle-level temporal coherence) instead of `BFMCS` (family-level).

### 4.2 How the Bundle-Level Truth Lemma Would Work

The only cases that use family-level coherence are the backward directions of
`all_future` and `all_past`. We need new proofs for these cases.

**Bundle backward G**: Show G(phi) in fam.mcs(t) given phi in fam.mcs(s) for all s >= t.

**New proof sketch**:
1. Assume G(phi) NOT in fam.mcs(t)
2. Then F(neg(phi)) in fam.mcs(t)
3. By bundle forward_F: neg(phi) in fam'.mcs(s') for some fam' in bundle, s' > t
4. **New step**: By the box injectivity property of BFMCS_Bundle:
   fam and fam' agree on Box-formulas. So for any Box(psi), Box(psi) in fam.mcs(s')
   iff Box(psi) in fam'.mcs(s').
5. **Key question**: Can we derive a contradiction from neg(phi) in fam'.mcs(s')
   and the hypothesis that phi is true at all future times OF fam?

The difficulty: phi being true at all future times of fam means phi in fam.mcs(s) for all
s >= t. But fam' is a different family. phi might not be in fam'.mcs(s').

**This approach FAILS for the same structural reason**: truth at tau refers to fam,
not fam'. The semantics of G binds to a single world-history.

### 4.3 The Actually Viable Approach: Semantic Relativization

Instead of modifying the truth lemma, modify the MODEL CONSTRUCTION so that bundle-level
coherence IMPLIES family-level coherence in the constructed model.

**Strategy: Collapse all families into a single family.**

Given a BFMCS_Bundle B, define a single FMCS that "merges" all families:

For each time t, at each family fam, if F(phi) in fam.mcs(t), there exists fam' and
s > t with phi in fam'.mcs(s). Build a new "merged" FMCS where:
- mcs(0) = eval_family.mcs(0) = M_0
- mcs(1) = some witness W_1 (resolving one F-obligation from mcs(0))
- mcs(2) = some witness W_2 (resolving one F-obligation from mcs(1))
- etc.

This is the omega chain approach. The issue is that resolving one obligation can kill others.

**But**: we now have the bundle_forward_F guarantee. For any F(psi) in mcs(n), there
exists SOME family fam' and s > n with psi in fam'.mcs(s). The witness exists in the
bundle. The question is: can we route the chain through these witnesses?

### 4.4 The Dovetailed Omega Chain (Recommended Approach)

**Core idea**: Build the chain so that at step n, we always use
`temporal_theory_witness_exists` to resolve the SPECIFIC F-obligation that is most urgent.
If an F-obligation is killed by a step, that's OK -- we prove it was actually resolved.

**Claim**: If F(psi) in chain(m), then at step m+1 (or the next step targeting psi),
either:
(a) psi in chain(m+1) (directly resolved), or
(b) F(psi) in chain(m+1) (deferred), or
(c) G(neg(psi)) in chain(m+1) -- but then neg(psi) in chain(m+1), which means the chain
    is INCOMPATIBLE with F(psi) at chain(m). This means the chain cannot be part of a
    consistent temporal model.

But (c) IS possible with the temporal witness construction. So we need to prevent it.

**Prevention strategy**: At step m+1, instead of resolving an arbitrary obligation,
resolve F(psi) for the oldest unresolved obligation. Specifically:

Build chain(m+1) = `temporal_theory_witness_exists` for psi from chain(m), where
F(psi) in chain(m).

This GUARANTEES psi in chain(m+1). So F(psi) at chain(m) is resolved at chain(m+1).

What about OTHER obligations F(chi) in chain(m)?
- They might survive (F(chi) in chain(m+1)) - will be resolved later
- They might be killed (G(neg(chi)) in chain(m+1))

If killed: F(chi) in chain(m) but chi never appears after m+1. This violates forward_F
for chain(m).

**To prevent killing**: at step m+1, resolve F(psi) for the oldest obligation. If F(chi)
is killed at this step, then chi was never going to be resolvable anyway... WRONG.
Bundle-level coherence guarantees chi IS resolvable (in some family). The chain just
picked a bad extension.

### 4.5 The Correct Solution: Strong Temporal Witness

**Theorem to prove**: Given MCS M with F(phi) in M, there exists MCS W with:
- phi in W
- G-theory(M) subset of W (G-preservation)
- box_class_agree(M, W)
- **F-theory preservation**: for all F(psi) in M, either psi in W or F(psi) in W

The last condition ensures Succ(M, W) and prevents F-obligation killing.

**Seed**: {phi} union G_theory(M) union box_theory(M) union {F(psi) | F(psi) in M, psi != phi}

**Consistency proof challenge**: The G-lift fails because G(F(psi)) not in M.

**New approach to consistency**: Instead of G-lifting the entire context, use a
TWO-PHASE argument:

Phase 1: From L = L_phi union L_G_box union L_F (subset of seed) with L |- bot:
- If L_F = empty: reduces to temporal_theory_witness_consistent (proven)
- If L_F = {F(psi_1), ..., F(psi_k)}: by iterated deduction,
  L_G_box |- phi -> (F(psi_1) -> ... -> (F(psi_k) -> bot)...)
  Equivalently: L_G_box |- phi -> neg(F(psi_1) /\ ... /\ F(psi_k))

Phase 2: G-lift on L_G_box: G(phi -> neg(F(psi_1) /\ ... /\ F(psi_k))) in M.
By K-axiom distribution: G(phi) -> G(neg(F(psi_1) /\ ... /\ F(psi_k))) in M.
Since G(phi) not necessarily in M, this doesn't immediately help.

But alternatively: from L_G_box |- phi -> neg(conjunction of F-formulas),
G-lift gives G(phi -> ...) in M. By T-axiom: (phi -> ...) in M.
So phi -> neg(F(psi_1) /\ ... /\ F(psi_k)) in M.

Now: F(phi) in M, so in any MCS containing M, either neg(phi) or phi.
If phi in M: then neg(F(psi_1) /\ ... /\ F(psi_k)) in M. This means
not all of F(psi_1), ..., F(psi_k) are in M simultaneously. But by hypothesis,
each F(psi_i) IS in M! Contradiction only if k >= 2 and the conjunction is in M.

Hmm, M might not contain F(psi_1) /\ ... /\ F(psi_k) as a single formula even if
each F(psi_i) is in M (conjunction closure of MCS gives it, but conjunction is a
derived notion).

Actually: MCS IS closed under conjunction. If F(psi_1) in M and F(psi_2) in M, then
F(psi_1) /\ F(psi_2) in M (where /\ is the derived conjunction). So the conjunction
IS in M. And then neg of the conjunction contradicts. So phi -> neg(conjunction) in M,
phi not directly in M (phi may or may not be in M).

But wait: F(phi) in M means neg(G(neg(phi))) in M. If phi were in M, then G(phi) might
or might not be in M. phi in M doesn't follow from F(phi) in M.

Let me reconsider. We have: (phi -> neg(conjunction of F(psi_i))) in M. And
all F(psi_i) in M, so conjunction of F(psi_i) in M. So phi -> False in M, meaning
neg(phi) in M. And F(phi) = neg(G(neg(phi))) in M. neg(phi) and F(phi) are compatible
(phi is false now, but G(neg(phi)) is also false - phi might be true later).

So this argument doesn't give a contradiction. We're stuck again.

### 4.6 Assessment: The Problem is Genuinely Hard

After exhaustive analysis, the fundamental obstacle is:

**The G-lift argument cannot handle F-formulas in the seed**, because G(F(psi)) is
logically independent of F(psi). No manipulation of the deduction theorem, K-axiom,
or MCS closure changes this.

This means: **there is no known proof technique that can show the combined seed
{phi} + G_theory + box_theory + F-preservation is consistent.** All 16+ approaches
founder on this specific obstacle.

## 5. Recommended Path Forward

### 5.1 Option A: Bypass the Truth Lemma (Recommended)

Instead of proving family-level temporal coherence and using the existing truth lemma,
prove completeness DIRECTLY from the algebraic infrastructure.

**The algebraic path is already sorry-free**:
- `consistent_implies_satisfiable`: Not provable -> ultrafilter model exists
- `bundle_completeness_contradiction`: Not provable -> not all MCSes contain phi
- `not_provable_implies_neg_consistent`: Not provable -> neg consistent

What's missing: connecting "not all MCSes contain phi" to "there exists a TaskModel
over Int where phi is false" (the `valid_over Int phi` definition).

**Approach**: Define a TaskModel directly from the BFMCS_Bundle structure using
bundle-level coherence:

1. TaskFrame: WorldState = Set Formula (MCSes from all families at all times)
2. TaskModel: valuation from atom membership in MCSes
3. Omega: world-histories from families (one per family, using shifted_fmcs)
4. Prove a FORWARD-ONLY truth lemma: phi in fam.mcs(t) -> truth_at ... phi

**Why forward-only suffices**: For completeness (contrapositive), we need: neg(phi) in M
implies neg(phi) true in model. This is the FORWARD direction. We do NOT need the backward
direction for the completeness argument itself.

**The imp case issue**: The forward direction of imp says: (psi -> chi) in MCS and
truth(psi) -> truth(chi). This uses truth(psi) as an input, requiring psi in MCS
(backward direction). So forward-only doesn't literally work for imp.

**Resolution**: Instead of a forward-only truth lemma, prove completeness by
structural induction on phi directly:

Prove: for all phi, if phi is not provable, then neg(phi) is in some MCS M,
and there exists a TaskModel/world-history/time where phi is false.

The base cases (atom, bot) are easy. For imp, use the algebraic structure. For box,
use the bundle structure. For G/H, the forward direction from FMCS suffices since
we're showing EXISTENCE of a falsifying point, not an equivalence.

### 5.2 Option B: Weaker Completeness Statement

Prove completeness with respect to a weaker semantics that uses bundle-level evaluation
instead of family-level evaluation.

Define `bundle_valid_over` where G(phi) at time t means phi at all s >= t in SOME family
(not necessarily the same one). This matches bundle-level coherence.

This changes the logic slightly but might be acceptable as a first milestone.

**NOT recommended**: This changes the mathematical content. The standard TM logic has
family-level (single-timeline) semantics for G.

### 5.3 Option C: Accept the Sorry as Documented Technical Debt

The sorry in `bundle_validity_implies_provability` is the "model-theoretic glue" connecting
the sorry-free algebraic completeness proof to the TaskFrame semantics. The algebraic
core IS complete and sorry-free:
- `construct_bfmcs_bundle`: Sorry-free
- `boxClassFamilies_bundle_temporally_coherent`: Sorry-free
- `mcs_neg_gives_countermodel`: Sorry-free
- `not_provable_implies_neg_consistent`: Sorry-free

The gap is PURELY in the model construction (building a TaskModel from the bundle).
The proof-theoretic content is fully formalized.

### 5.4 Recommended: Option A with Specific Implementation Plan

**Phase 1**: Prove a direct completeness theorem that bypasses the parametric truth lemma.

The theorem: `completeness_direct`: If phi is valid over Int, then phi is provable.

Proof by contrapositive:
1. Assume phi not provable
2. neg(phi) consistent (by not_provable_implies_neg_consistent)
3. Extend to MCS M (by Lindenbaum)
4. Build BFMCS_Bundle B from M (by construct_bfmcs_bundle, sorry-free)
5. Build TaskModel from B:
   - TaskFrame: the ParametricCanonicalTaskFrame Int (already exists, sorry-free)
   - TaskModel: ParametricCanonicalTaskModel Int (already exists, sorry-free)
   - Omega: ShiftClosedParametricCanonicalOmega (already exists, sorry-free)
6. Show phi is false at (parametric_to_history eval_family, 0):
   - neg(phi) in M = eval_family.mcs(0) (by construction)
   - Need: neg(phi) in MCS implies phi is false in model

Step 6 requires: neg(phi) in fam.mcs(t) implies NOT truth_at ... phi.
This is equivalent to: phi in fam.mcs(t) implies truth_at ... phi (forward truth)
PLUS: phi NOT in fam.mcs(t) implies NOT truth_at ... phi (backward truth).

But backward truth requires the full truth lemma, which needs family-level coherence!

**Alternative for step 6**: Instead of showing truth_at ... neg(phi), show NOT truth_at ... phi.
If phi NOT in fam.mcs(0), and we can show: truth_at ... phi implies phi in fam.mcs(0)
(backward direction), then NOT phi in fam.mcs(0) implies NOT truth_at ... phi.

This is STILL the backward truth lemma.

**Revised approach for step 6**: We need to show phi is false in SOME model over Int.
We don't have to use the canonical model. ANY model over Int where phi fails suffices.

**What if we build a much simpler model?** A degenerate model where ALL formulas are
evaluated purely by MCS membership, without going through the full truth_at semantics?

The problem is that `valid_over Int phi` quantifies over ALL TaskModels and ALL Omega.
We need to find ONE where phi fails. The canonical model is the standard choice, but
any model works.

**Ultra-simple model approach**: Build a model where the valuation is designed so that
truth_at EXACTLY matches MCS membership for the specific formula phi and its subformulas.

This is essentially a finite model approach: restrict attention to subformulaClosure(phi)
and build a model that agrees with MCS on just those formulas.

**But**: even for this restricted model, the G/H cases still need temporal coherence
within a single timeline.

### 5.5 Revised Recommendation

After this exhaustive analysis, the most viable approaches are:

**Path A (Best)**: Prove that the omega chain from UltrafilterChain.lean can be modified
to achieve family-level forward_F by using a TARGETED resolution strategy where at each
step, we resolve the F-obligation from the CURRENT MCS (not a past one).

The key theorem to prove:

```
theorem targeted_omega_chain_forward_F :
  ∀ n phi, F(phi) ∈ omega_chain(n) →
    ∃ m > n, phi ∈ omega_chain(m)
```

Strategy: when F(phi) ∈ chain(n), build chain(n+1) as the temporal witness for phi.
Then phi ∈ chain(n+1) by construction. The remaining challenge is showing that ALL
F-obligations from chain(n) are handled, not just phi.

For obligations F(psi) where psi != phi:
- If F(psi) survives to chain(n+1): it will be targeted at a future step
- If psi ∈ chain(n+1): already resolved
- If neither (G(neg(psi)) introduced): this obligation at chain(n) is problematic

**To handle the third case**: prove that if F(psi) ∈ chain(n) and the temporal witness
for phi from chain(n) introduces G(neg(psi)), then actually psi or F(psi) was already
going to be in chain(n+1) anyway. This seems very hard to prove in general.

**Path B (Pragmatic)**: Mark `bundle_validity_implies_provability` as documented
technical debt. The sorry is in the model-theoretic glue, not in any proof-theoretic
content. The algebraic completeness core is fully formalized. Wire `dense_completeness_fc`
and `discrete_completeness_fc` through `completeness_over_Int`, so only ONE sorry remains.

Specifically:
- `completeness_over_Int` calls `bundle_validity_implies_provability` (1 sorry)
- `dense_completeness_fc` should call `completeness_over_Int` (Int is embeddable in dense orders)
- `discrete_completeness_fc` should call `completeness_over_Int` (Int is discrete)
- This reduces 3 sorries to 1

**Path C (Most Ambitious)**: Develop a new truth lemma that works at the bundle level
by changing the evaluation semantics. Instead of evaluating G(phi) at a single
world-history, evaluate it across all world-histories in the bundle that share the same
"modal component". This would be a novel semantic framework.

## 6. Concrete Recommendation

**Immediate (reduces sorries from 3 to 1)**:
Wire `dense_completeness_fc` and `discrete_completeness_fc` through `completeness_over_Int`.
This requires showing that Int is an instance of both dense and discrete frame classes
(it's a totally ordered group with successor/predecessor). This is mostly typeclass wiring.

**Medium-term (eliminates the last sorry)**:
The `bundle_validity_implies_provability` sorry requires either:
(a) A proof that the omega chain can be built with family-level forward_F, OR
(b) A new truth lemma framework that works with bundle-level coherence, OR
(c) A completely different completeness proof strategy

Option (a) requires solving the "Lindenbaum extension kills F-obligations" problem.
This is the hardest open problem in the formalization and has resisted all 16+ attempts.

Option (b) requires a novel semantic framework not present in standard literature.

Option (c) might involve the finite model property or other techniques.

## 7. Summary

- The codebase has extensive sorry-free algebraic infrastructure for completeness
- The gap is ENTIRELY in building a TaskModel from the algebraic structure
- The specific obstacle: the truth lemma needs family-level temporal coherence
- Family-level coherence requires each chain to resolve ALL its F-obligations internally
- The Lindenbaum extension can non-deterministically kill F-obligations
- No known proof technique prevents this (16+ failed approaches documented)
- Reducing from 3 sorries to 1 is achievable by wiring dense/discrete through Int
- The remaining sorry is genuine mathematical difficulty, not a formalization artifact
