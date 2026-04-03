# Teammate B Findings: Alternative Proof Strategies for g_content Blocker

**Task**: 83 - Close Restricted Coherence Sorries
**Role**: Teammate B - Alternative strategies bypassing/restructuring g_content requirement
**Date**: 2026-04-03

## Executive Summary

The `g_content(M) ⊆ successor(M)` requirement cannot be eliminated -- it is essential for temporal coherence. However, the current proof strategy (showing `seed ⊆ u` via the T-axiom) is not the only way to achieve it. I identify three alternative strategies, of which **Strategy A (extended temporal witness seed)** is the most promising and cleanest. Strategy B (derivation of `G(a) -> X(a)`) is valid but does NOT directly solve the sorry sites. Strategy C (seed consistency via G-lift without seed-subset) works for the DovetailedChain path but NOT for SuccExistence seeds that include deferral disjunctions.

## Key Findings

### Finding 1: The Seed Already Includes g_content (HIGH confidence)

The `successor_deferral_seed` in SuccExistence.lean IS already defined as:
```
successor_deferral_seed u = g_content u ∪ deferralDisjunctions u
```

So `g_content(u) ⊆ successor(u)` follows trivially from the Lindenbaum extension containing the seed. The sorry is NOT about g_content inclusion in the successor. It is about proving the **seed is consistent**. The current proof strategy requires `seed ⊆ u` (lines 472, 788 in SuccExistence.lean), which requires `g_content(u) ⊆ u`, which requires the T-axiom.

Similarly, in DovetailedChain.lean, the sorry at line 142 is in `forward_step_g_content`, where the proof tries to derive `a ∈ W` from `G(a) ∈ W` using the T-axiom. The witness W comes from `temporal_theory_witness_exists` whose seed is `{phi} ∪ temporal_box_seed(M)` and does NOT include g_content.

**These are two fundamentally different problems** requiring different solutions:
1. DovetailedChain: W doesn't include g_content at all (seed design issue)
2. SuccExistence: Seed includes g_content but can't prove consistency (proof strategy issue)

### Finding 2: Extended Temporal Witness Seed -- The Clean Fix for DovetailedChain (HIGH confidence)

**Strategy A**: Modify the seed of `temporal_theory_witness_exists` from `{phi} ∪ temporal_box_seed(M)` to `{phi} ∪ temporal_box_seed(M) ∪ g_content(M)`.

**Proof of consistency**: The extended seed is consistent by the standard G-lift argument.

All elements of the seed (except phi) are G-liftable:
- `G_theory(M)` elements x: `G(x) ∈ M` by temp_4 (since x = G(a) and G(G(a)) is derivable from G(a))
- `box_theory(M)` elements x: `G(x) ∈ M` by modal_future/temp_future axioms
- `g_content(M)` elements a: `G(a) ∈ M` by definition of g_content

The proof follows `temporal_theory_witness_consistent` exactly:
1. If phi not in L: L is all G-liftable, G-lift gives G(bot) in M, contradicting G(top) in M via seriality
2. If phi in L: extract phi by deduction theorem, L' all G-liftable, G-lift gives G(neg phi) in M, contradicting F(phi) = neg(G(neg phi)) in M

The Lindenbaum extension V then satisfies:
- phi in V (target resolution)
- G_theory(M) ⊆ V (G-agreement)
- box_theory(M) ⊆ V (box-class agreement)
- **g_content(M) ⊆ V** (the new guarantee!)

This directly resolves `forward_step_g_content` (line 142 sorry) without needing any new axiom derivation.

**Implementation**: Create `temporal_theory_witness_with_g_content_consistent` and `temporal_theory_witness_with_g_content_exists` in UltrafilterChain.lean, then update `forward_step` in DovetailedChain.lean to use the new witness.

### Finding 3: G(a) -> X(a) Is Derivable But Does NOT Fix the Sorries (MEDIUM confidence)

The derivation of `G(a) -> X(a)` using `until_induction(bot, neg(bot), a)` is sound and correct:

```
until_induction(bot, neg(bot), a):
  G(neg(bot) -> a) ∧ G((bot ∧ X(a)) -> a) -> (X(top) -> X(a))

Simplifications:
  - G(neg(bot) -> a) = G(top -> a), derivable from G(a) via temp_k_dist
  - G((bot ∧ X(a)) -> a) = G(bot -> a) = G(tautology), derivable by temporal necessitation
  - X(top) = bot U neg(bot), present in any MCS with F(top) via disc_next

So from G(a) and F(top): X(a) is derivable.
```

However, this does NOT directly fix the sorry sites because:
- The sorry at DovetailedChain.lean:142 needs `a ∈ W` (where W is the successor MCS)
- G(a) -> X(a) gives `X(a) ∈ W`, meaning "a at W's next time," NOT "a ∈ W"
- X(a) ∈ W does not imply a ∈ W

The derivation IS useful for showing g_content(chain(n)) ⊆ chain(n+1) in a chain construction where the Succ relation resolves X-formulas. But this requires the chain to already have Succ established -- creating a circular dependency if the Succ relation itself depends on g_content.

### Finding 4: SuccExistence Seed Consistency Cannot Use Pure G-Lift (HIGH confidence)

The `successor_deferral_seed = g_content(u) ∪ deferralDisjunctions(u)` mixes two types of elements:
- `g_content(u)`: G-liftable (for each a, G(a) in u)
- `deferralDisjunctions(u)`: in u, but NOT G-liftable

I proved that `g_content(u)` alone is consistent by G-lift. But when combined with deferralDisjunctions, the G-lift argument breaks because:
1. Extracting deferral elements by deduction theorem and G-lifting gives G(d1 -> d2 -> ... -> bot) in u
2. Applying temp_k_dist requires G(d_i) in u for each deferral disjunction d_i
3. G(a_i ∨ F(a_i)) is NOT in u in general (semantically: F(a) at t does not imply G(a ∨ F(a)) at t)

The seed IS semantically consistent (at time t+1: g_content elements hold by G, and deferral disjunctions hold by case analysis on the F-witness). But proving this syntactically without soundness appears to require a new technique.

**Potential approach**: Use the `temporal_theory_witness_consistent` result directly. Since `temporal_theory_witness_consistent` proves `{phi} ∪ temporal_box_seed(M)` consistent when F(phi) in M, and we can extend this to include g_content (Finding 2), the SuccExistence seeds could be reformulated to use temporal_box_seed + g_content as the base, with consistency proven via G-lift, and then add deferral disjunctions separately since they are in u.

However, this requires showing that adding elements from u to a consistent set preserves consistency -- which is the general problem of "consistent extension."

**Observation**: Since deferralDisjunctions(u) ⊆ u and u is consistent, and g_content(u) is independently consistent (by G-lift), the question is whether these two consistent sets are jointly consistent. This is a non-trivial syntactic question.

### Finding 5: Boneyard Review -- Past Failures and Strict Semantics (MEDIUM confidence)

Reviewed three archived approaches:

**FPreservingSeed.lean** (archived Task 80):
- Approach: Include unresolved F-formulas in the seed to prevent Lindenbaum from negating them
- Failure: Task 69 proved F-preserving seed consistency is FALSE. The G-lift of F-formulas is not derivable in TM.
- Strict semantics relevance: Same fundamental issue -- F-formulas are NOT G-liftable, just as deferral disjunctions are not. This confirms that mixing F-related formulas with G-liftable seeds is problematic.

**BidirectionalSeed.lean** (archived Task 80):
- Approach: Build seeds that propagate both G-forward and H-backward
- Failure: `H(a) -> G(H(a))` is NOT derivable in TM logic
- Strict semantics relevance: Still invalid. Strict semantics does not help here.

**CoherentZChain.lean** (archived Task 80):
- Approach: Refinement of Z-chain construction with cross-direction coherence
- Failure: Same structural gaps as the base Z-chain
- Strict semantics relevance: No change. Cross-direction coherence remains fundamentally hard.

**Pattern**: All failed approaches tried to include non-G-liftable elements in the seed and could not prove consistency. The successful approach (temporal_theory_witness_consistent) works precisely because its seed is fully G-liftable (plus one target formula handled by deduction theorem). **Strategy A aligns with this pattern** by adding only G-liftable elements (g_content) to the seed.

### Finding 6: Forward/Backward Coherence Under Strict Semantics (HIGH confidence)

The `forward_dovetailed_forward_G` theorem (line 215) states:
```
G(phi) ∈ chain(n) → phi ∈ chain(m) for all m ≥ n
```

Under strict semantics, this should be:
```
G(phi) ∈ chain(n) → phi ∈ chain(m) for all m > n (strictly greater)
```

The `n = m` case (phi ∈ chain(n) from G(phi) ∈ chain(n)) is the T-axiom and is invalid. The `m > n` case is valid and follows from g_content(chain(n)) ⊆ chain(n+1) (which Strategy A provides) plus G-propagation.

Similarly for `forward_dovetailed_backward_H`: the base cases at lines 277 and 282 use the T-axiom for H. These need the same strict inequality treatment.

**Required changes**:
- Change `h_le : n ≤ m` to `h_lt : n < m` in forward_G
- Change the base case from `n = m` to `n + 1 = m`
- Use g_content_step (from Strategy A) for the one-step case

### Finding 7: The Two Sorry Categories Are Independent (HIGH confidence)

The 32 sorry sites fall into two independent categories with different fix paths:

**Category 1: DovetailedChain (9 sorries)**
- Files: DovetailedChain.lean (9 sorry sites)
- Pattern: `forward_step_g_content`, `forward_dovetailed_forward_G`, `forward_dovetailed_backward_H`, and backward chain duals
- Fix: **Strategy A** (extended temporal witness seed with g_content)
- This is clean and self-contained

**Category 2: SuccExistence + SuccChainFMCS (4 sorries)**
- Files: SuccExistence.lean (3), SuccChainFMCS.lean (1)
- Pattern: Seed consistency requiring `g_content(u) ⊆ u` or `h_content(u) ⊆ u`
- Fix: More complex. Options include:
  a. Reformulate seed to avoid mixing g_content with non-G-liftable elements
  b. Use the "add g_content to temporal_box_seed" approach from Strategy A as the base seed, then show extending with deferral disjunctions (from u) preserves consistency
  c. Prove a general "g_content(u) is consistent with u" lemma syntactically

**Other sorries** (UltrafilterChain.lean, etc.) follow the same patterns and would be resolved by fixing the underlying theorems.

## Recommended Approach

### Priority 1: Implement Strategy A for DovetailedChain

1. Create `temporal_theory_witness_with_g_content_consistent` in UltrafilterChain.lean:
   - Seed: `{phi} ∪ temporal_box_seed(M) ∪ g_content(M)`
   - Proof: G-lift argument (straightforward extension of existing proof)

2. Create `temporal_theory_witness_with_g_content_exists` in UltrafilterChain.lean:
   - Returns: W MCS with phi ∈ W, G-agreement, box_class_agree, AND g_content(M) ⊆ W

3. Update `forward_step` in DovetailedChain.lean to use the new witness
   - `forward_step_g_content` becomes trivial: g_content in seed, seed ⊆ extension

4. Fix coherence lemmas:
   - Change `forward_dovetailed_forward_G` to use `n < m` (strict inequality)
   - Fix backward H coherence similarly

### Priority 2: SuccExistence Seed Consistency

The cleanest approach for SuccExistence may be to reformulate the successor construction to use the extended temporal witness as the base, then add the deferral/blocking formulas via a separate consistency-preserving extension step.

Alternatively, prove that `g_content(u) ∪ {finite subset of u}` is consistent by the argument:
- Finite L ⊆ g_content(u) ∪ S where S ⊆ u
- If L ⊢ bot, extract S-elements by deduction: L_gc ⊢ s1 → ... → bot
- G-lift: G(s1 → ... → bot) ∈ u
- Use temp_k_dist iteratively with the fact that each s_i ∈ u (not G(s_i))
- This doesn't close... need different route

**Alternative for Priority 2**: Bypass the `seed ⊆ u` strategy entirely. Instead, prove seed consistency by showing the seed is satisfiable in a model, using the already-established soundness of the Base axioms (which are sorry-free in soundness). This requires partial soundness for the axioms used in the derivation.

## Appendix: Detailed Proof of Extended Seed Consistency

**Theorem**: If M is MCS with F(phi) ∈ M, then `{phi} ∪ temporal_box_seed(M) ∪ g_content(M)` is SetConsistent.

**Proof**: Let seed = {phi} ∪ temporal_box_seed(M) ∪ g_content(M). Suppose for contradiction there exists finite L ⊆ seed with L ⊢ bot.

**Claim**: Every element of `temporal_box_seed(M) ∪ g_content(M)` is G-liftable, i.e., for x in this set, G(x) ∈ M.

- If x ∈ G_theory(M): x = G(a) where G(a) ∈ M. By temp_4: G(G(a)) ∈ M. So G(x) = G(G(a)) ∈ M.
- If x ∈ box_theory(M): x = Box(a) or x = neg(Box(a)). By modal_future/temp_future: G(Box(a)) ∈ M. For neg(Box(a)): if neg(Box(a)) ∈ M, then Box(a) ∉ M (by MCS consistency). If G(neg(Box(a))) ∉ M, then neg(G(neg(Box(a)))) ∈ M, i.e., F(Box(a)) ∈ M. But [need to handle this case from the existing proof -- it IS handled in `G_of_box_theory`].
- If x ∈ g_content(M): G(x) ∈ M by definition.

So all of `temporal_box_seed(M) ∪ g_content(M)` is G-liftable.

**Case 1**: phi ∉ L. Then L ⊆ temporal_box_seed(M) ∪ g_content(M), all G-liftable. By G_lift_from_context: G(bot) ∈ M. But G(top) ∈ M (by temporal necessitation of tautology). G(bot) → F(bot) by seriality_future. F(bot) = neg(G(top)). So neg(G(top)) ∈ M and G(top) ∈ M, contradicting MCS consistency.

**Case 2**: phi ∈ L. Let L_no_phi = L.filter (· ≠ phi). All elements of L_no_phi are G-liftable. By weakening and deduction theorem: L_no_phi ⊢ neg(phi). By G_lift_from_context: G(neg(phi)) ∈ M. But F(phi) = neg(G(neg(phi))) ∈ M. Contradiction with MCS consistency.

QED.

## Appendix: G(a) -> X(a) Derivation Detail

Using `until_induction(bot, neg(bot), a)`:

**Axiom instance** (fully expanded):
```
(G(neg(bot) → a) ∧ G((bot ∧ (bot U a)) → a)) → ((bot U neg(bot)) → (bot U a))
```

Which is:
```
(G(top → a) ∧ G(bot → a)) → (X(top) → X(a))
```

**Step 1**: `G(top → a)` from `G(a)`.
- `[] ⊢ a → (top → a)` (propositional tautology, where top = neg bot)
- By temporal necessitation: `[] ⊢ G(a → (top → a))`
- By temp_k_dist: `[] ⊢ G(a → (top → a)) → (G(a) → G(top → a))`
- By MP twice: `[G(a)] ⊢ G(top → a)`

**Step 2**: `G(bot → a)` is a theorem.
- `[] ⊢ bot → a` (ex falso, propositional tautology)
- By temporal necessitation: `[] ⊢ G(bot → a)`

**Step 3**: Form conjunction and apply until_induction.
- `[G(a)] ⊢ G(top → a) ∧ G(bot → a)`
- By until_induction: `[G(a)] ⊢ X(top) → X(a)`

**Step 4**: Get X(top) from F(top).
- disc_next: `[] ⊢ F(top) → X(top)`
- In any MCS with F(top): X(top) ∈ MCS

**Step 5**: Conclude.
- `[G(a), F(top)] ⊢ X(a)` i.e., `G(a) ∧ F(top) → X(a)`.
- Since F(top) is always in MCS (by seriality + MCS closure), effectively `G(a) → X(a)` in any MCS.

**Note**: This derivation requires both `until_induction` (Discrete axiom) and `disc_next` (Discrete axiom), so it is valid only for discrete TM, not for the dense extension.

## Appendix: Search Queries and Sources

- Codebase files read: SuccExistence.lean, DovetailedChain.lean, UltrafilterChain.lean (temporal_theory_witness_consistent section), Axioms.lean, TemporalContent.lean, WitnessSeed.lean, SuccChainFMCS.lean
- Boneyard files reviewed: FPreservingSeed.lean, BidirectionalSeed.lean, CoherentZChain.lean
- No web searches performed (all findings from codebase analysis and proof-theoretic reasoning)
