# Blocker Analysis: Task #58

**Parent Task**: #58 - wire_completeness_to_frame_conditions
**Generated**: 2026-03-26
**Blocker**: Bundle-level vs family-level temporal coherence mismatch prevents connecting BFMCS_Bundle to TaskModel semantics

## Root Cause

The completeness proof requires connecting two incompatible coherence levels:

### Bundle-Level Coherence (What We Construct)

`BFMCS_Bundle` via `construct_bfmcs_bundle` provides:
```lean
bundle_forward_F : ∀ fam ∈ families, ∀ φ t, Formula.some_future φ ∈ fam.mcs t →
    ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
```
The F-witness `fam'` can be ANY family in the bundle.

### Family-Level Coherence (What Truth Lemma Requires)

`shifted_truth_lemma` requires `B.temporally_coherent`:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧ ...
```
The F-witness must be in the SAME family `fam`.

### Why This Blocks Completeness

The backward G case of `shifted_truth_lemma` uses contraposition via `temporal_backward_G`:
1. Assume `G(phi)` not in `fam.mcs t`
2. By MCS maximality: `neg(G(phi))` = `F(neg phi)` in `fam.mcs t`
3. By family-level `forward_F`: exists `s > t` with `neg(phi)` in **`fam.mcs s`** (same family!)
4. But hypothesis says `phi` in `fam.mcs s` for all `s > t`
5. Contradiction: `fam.mcs s` contains both `phi` and `neg(phi)`

With bundle-level coherence, step 3 gives `neg(phi)` in `fam'.mcs s` (different family), breaking the contradiction.

### Genuine Mathematical Obstacle

This is not a Lean encoding issue. The F-witnesses genuinely cross box classes in the bundle construction. Different MCSes can have different box-class theories, so when building shifted chains for F-witnesses, they may land in a different family than the original.

## Resolution Analysis

### Option A: Prove Family-Level from Bundle-Level

**Status**: BLOCKED

This would require showing that F-witnesses can always be found in the same family. However, the construction explicitly allows F-witnesses to cross box classes. The mathematical structure does not support this.

### Option B: Bundle-Level Truth Lemma

**Status**: Viable but high effort (estimated 8-12 hours)

Create an alternative truth lemma that works with bundle-level coherence. This requires:
1. Redefining the canonical model to use bundle-wide Omega (histories from all families)
2. Proving that bundle coherence suffices for the backward cases when Omega spans all families
3. Connecting this to TaskModel semantics

The key insight: if Omega includes histories from ALL families, then bundle-level F-witnesses are still "reachable" through shift-closure.

### Option C: Alternative Completeness Path via Restricted Construction

**Status**: Viable, moderate effort (estimated 4-6 hours)

The `RestrictedTemporallyCoherentFamily` construction already provides family-level coherence for a restricted formula. The gap is connecting this to `valid_over Int phi`:

1. `RestrictedTemporallyCoherentFamily phi` provides family-level F/P coherence within its single chain
2. `restricted_truth_lemma` establishes MCS membership equivalence for subformulas
3. Need: Convert restricted chain to TaskModel satisfying `valid_over Int phi`

This path is more tractable because the restricted construction was designed to provide family-level coherence.

### Option D: Accept as Documented Technical Debt

**Status**: Current state

The 3 sorries remain with documentation explaining the model-theoretic gap. The algebraic completeness proof in UltrafilterChain.lean is sorry-free; only the semantic glue is missing.

## Proposed Resolution

Based on analysis, **Option C (Restricted Construction Path)** is the most tractable:

1. The restricted construction already has the coherence properties needed
2. The gap is well-defined: convert `RestrictedTemporallyCoherentFamily` to `TaskModel`
3. This avoids major refactoring of the semantic infrastructure

This requires two tasks:
1. Build TaskModel from RestrictedTemporallyCoherentFamily
2. Connect to valid_over and eliminate the 3 target sorries

## Proposed New Tasks

### New Task 1: Build TaskModel from Restricted Construction

- **Effort**: 4-6 hours
- **Language**: lean4
- **Rationale**: The restricted construction provides family-level coherence but lacks TaskModel/TaskFrame infrastructure. This task creates the bridge.
- **Depends on**: None

**Scope**:
- Define `RestrictedTaskFrame` from `RestrictedTemporallyCoherentFamily`
- Define `RestrictedTaskModel` with valuation from restricted chain
- Define `RestrictedOmega` (single history from the restricted family)
- Prove shift-closure of `RestrictedOmega`
- Prove `restricted_truth_lemma_semantic`: MCS membership iff truth in RestrictedTaskModel

**Key insight**: The restricted construction is a single Int-indexed chain, so Omega has exactly one history (modulo shifts). This simplifies the shift-closure argument.

### New Task 2: Wire Restricted Completeness to Target Sorries

- **Effort**: 3-4 hours
- **Language**: lean4
- **Rationale**: Once TaskModel exists, connect to the 3 target sorries using contrapositive argument
- **Depends on**: New Task 1, because the TaskModel infrastructure from Task 1 determines how to construct the countermodel and apply valid_over

**Scope**:
- Prove `restricted_completeness`: not provable implies countermodel exists
- Wire `bundle_validity_implies_provability` using restricted completeness
- Wire `dense_completeness_fc` via `dense_implies_int + completeness_over_Int`
- Wire `discrete_completeness_fc` via `discrete_implies_int + completeness_over_Int`
- Final axiom verification (no sorryAx)

**Proof strategy**:
1. If phi not provable, neg(phi) consistent
2. Extend neg(phi) to restricted MCS
3. Build RestrictedTemporallyCoherentFamily from that MCS
4. Build RestrictedTaskModel from the family
5. By restricted_truth_lemma_semantic: neg(phi) true at time 0
6. Therefore phi NOT valid (countermodel exists)
7. Contrapositive: if valid, then provable

## Dependency Reasoning

- **Task 2 depends on Task 1**: Task 1 defines the TaskModel infrastructure (RestrictedTaskFrame, RestrictedTaskModel, RestrictedOmega). Task 2 needs these definitions to construct the countermodel for the completeness proof. The specific choice of how Omega is constructed (single chain vs. bundle) and how truth is defined affects how Task 2 applies the validity hypothesis.

## After Completion

Once both spawned tasks are complete, task 58 can be resumed with `/implement 58` to:
1. Verify all 3 target sorries are eliminated
2. Run final axiom check
3. Complete the implementation summary

The blocker will be resolved because: The restricted construction provides family-level coherence that the shifted_truth_lemma requires. By building TaskModel infrastructure specifically for this construction, we can apply the completeness contrapositive directly without needing to convert bundle-level to family-level coherence.

## References

- `FrameConditions/Completeness.lean:186-214` - Target sorry in `bundle_validity_implies_provability`
- `FrameConditions/Completeness.lean:115-120` - Target sorry in `dense_completeness_fc`
- `FrameConditions/Completeness.lean:158-163` - Target sorry in `discrete_completeness_fc`
- `Bundle/TemporalCoherence.lean:216-219` - Family-level coherence definition
- `Algebraic/UltrafilterChain.lean:2554-2555` - Bundle-level coherence definition
- `Algebraic/RestrictedTruthLemma.lean:268-280` - Restricted truth lemma
- `Bundle/SuccChainFMCS.lean:4191-4202` - RestrictedTemporallyCoherentFamily structure
