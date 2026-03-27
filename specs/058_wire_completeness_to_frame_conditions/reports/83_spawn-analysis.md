# Blocker Analysis: Task #58

**Parent Task**: #58 - Wire completeness to FrameConditions
**Generated**: 2026-03-27
**Blocker**: Two sorries remain after Phase 1 completion: `dense_completeness_fc` (needs dense canonical model) and `bundle_validity_implies_provability` (model-theoretic glue connecting bundle construction to TaskModel semantics)

## Root Cause

Task 58 has made significant progress:
- `discrete_completeness_fc` is now SORRY-FREE (wired through `completeness_over_Int`)
- The algebraic completeness infrastructure is fully sorry-free (`construct_bfmcs_bundle`, `mcs_neg_gives_countermodel`, `not_provable_implies_neg_consistent`)

Two independent sorries remain:

### Sorry 1: `bundle_validity_implies_provability`

This is the "model-theoretic glue" connecting the algebraic bundle construction to the semantic `valid_over Int` definition. The fundamental obstacle is the gap between:

- **Bundle-level temporal coherence** (what exists): F-witnesses can be in ANY family of the bundle
- **Family-level temporal coherence** (what's needed): F-witnesses must be in the SAME family

The truth lemma (`parametric_shifted_truth_lemma`) requires family-level coherence because the backward G case needs to derive a contradiction from `phi` and `neg(phi)` being in the same MCS at the same family. With bundle-level coherence, the witnesses are in different families and no contradiction arises.

24+ approaches have been documented and all hit the same wall: the G-lift barrier. Any seed containing multiple BRS elements requires `G(x) in M` for each seed element `x`, but for BRS elements `psi`, we only have `F(psi) in M`, and `F(psi)` does NOT imply `G(F(psi))` (countermodel exists).

### Sorry 2: `dense_completeness_fc`

This cannot be wired through `completeness_over_Int` because Int is NOT densely ordered (there is no integer between 0 and 1). Dense completeness requires a separate proof path using a dense canonical model (e.g., over Rat).

## Proposed New Tasks

### New Task 1: Prove bundle_validity_implies_provability via direct model construction

- **Effort**: 4-8 hours
- **Language**: lean4
- **Rationale**: This is the core remaining mathematical obstacle for Int completeness. The task should implement the "bypass truth lemma" approach: instead of proving family-level coherence and using the existing truth lemma, construct a TaskModel directly from BFMCS_Bundle and prove a forward-only truth lemma that suffices for the completeness argument.
- **Depends on**: None

**Specific approach**: The completeness argument only needs the FORWARD direction of the truth lemma: `phi in fam.mcs(t) -> truth_at ... phi`. For the `imp` case that uses backward IH, restructure the proof to use direct MCS reasoning instead of semantic evaluation. The key insight is that we need to show `neg(phi)` is satisfiable (exists a model where phi is false), not prove a full truth equivalence.

**Alternative approach if forward-only fails**: Accept that the truth lemma is inherently bidirectional. Instead, prove that the Z-chain construction (lines 2347, 2369, 2485 in UltrafilterChain.lean) can achieve family-level coherence by showing that:
1. The G/H crossing cases (seam propagation) are tractable engineering
2. The forward_F case can be proven via a priority-queue dovetailing argument

### New Task 2: Prove dense_completeness_fc via Rat canonical model

- **Effort**: 6-10 hours
- **Language**: lean4
- **Rationale**: Dense completeness requires a canonical model over a densely ordered domain. Rat is the natural choice (countable, well-supported in Mathlib, densely ordered).
- **Depends on**: New Task 1, because the approach for bundle_validity_implies_provability will inform whether to use the same technique for Rat or if a different strategy is needed. If Task 1 succeeds via direct model construction, the same pattern should apply to Rat.

**Specific requirements**:
1. Define `construct_bfmcs_bundle_rat` or parameterize the existing construction over the domain
2. Prove the corresponding truth lemma for Rat
3. Wire `dense_completeness_fc` through `completeness_over_Rat`

**Why Rat over Real**: Rat is countable, which aligns with the existing Lindenbaum/countable MCS machinery. Real would require additional measure-theoretic or uncountable cardinality handling.

## Dependency Reasoning

**Task 2 depends on Task 1**: The dense completeness proof needs to know HOW the Int completeness sorry was resolved. Specifically:

- If Task 1 proves `bundle_validity_implies_provability` via a forward-only truth lemma approach, the same construction pattern applies to Rat
- If Task 1 proves it via Z-chain family-level coherence, the same priority-queue dovetailing argument transfers to the Rat case
- If Task 1 discovers that Int completeness requires a fundamentally different technique (e.g., finite model property), the Rat proof strategy must adapt accordingly

The implementation details of Task 1 directly affect how Task 2 should be structured. This is not just a completion dependency but a design dependency.

**Potential independence scenario**: If upon deeper analysis we determine that Rat and Int require fundamentally different proof strategies (e.g., Int uses well-ordering properties that Rat lacks), these tasks could become independent. However, based on the current analysis, the proof techniques should transfer between discrete and dense domains.

## After Completion

Once both spawned tasks are complete, resume the parent task #58 with `/implement 58`.

The blocker will be resolved because:
1. `bundle_validity_implies_provability` will be sorry-free, making `completeness_over_Int` fully proven
2. `discrete_completeness_fc` is already sorry-free (depends on `completeness_over_Int`)
3. `dense_completeness_fc` will be sorry-free via the Rat canonical model
4. All three original target sorries will be eliminated

## Summary of Approach Viability

Based on 80+ research reports and 17 plan versions:

**Definitively blocked approaches** (DO NOT retry):
- Bundle-level truth lemma substitution
- Forward-only truth lemma (imp case uses backward IH)
- Algebraic bypass (proves syntactic, not semantic completeness)
- Multi-BRS seed consistency via G-lift
- Any approach needing `G(F(psi))` from `F(psi)`

**Potentially viable approaches** (for Task 1):
- Direct model construction bypassing parametric truth lemma
- Z-chain seam propagation (lines 2347, 2369 - may be tractable engineering)
- Priority-queue dovetailing for forward_F (the genuine mathematical heart)
- Controlled Lindenbaum extension preventing bad G-formulas

**Note**: The remaining sorry is genuine mathematical difficulty, not a formalization artifact. The standard literature hand-waves through the dovetailing argument that the omega-chain resolves all F-obligations.
