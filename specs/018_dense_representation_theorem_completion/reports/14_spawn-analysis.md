# Blocker Analysis: Task #18

**Parent Task**: #18 - dense_representation_theorem_completion
**Generated**: 2026-03-21
**Blocker**: The `dense_completeness_theorem` is blocked by a truth lemma gap in `timelineQuot_not_valid_of_neg_consistent` at TimelineQuotCompleteness.lean:127

## Root Cause

The `timelineQuot_not_valid_of_neg_consistent` theorem requires instantiating the parametric truth lemma infrastructure at `D = DovetailedTimelineQuot`. This requires:

1. **A BFMCS over DovetailedTimelineQuot**: The existing `DovetailedTimelineQuotBFMCS` module provides modal saturation via `closedFlags`, but does NOT construct a full `BFMCS` type with temporal coherence.

2. **Temporal coherence proof**: The parametric truth lemma (`parametric_canonical_truth_lemma` and `parametric_shifted_truth_lemma`) requires `B.temporally_coherent` - a proof that all families in the BFMCS have `forward_F` and `backward_P` properties.

3. **Root MCS connection**: Need to connect `phi.neg` membership in the root MCS to semantic falsity via the truth lemma.

### What Exists vs What's Missing

**Exists (complete)**:
- `dovetailedFMCS`: FMCS over DovetailedTimelineQuot with `forward_G` and `backward_H`
- `dovetailedFMCS_forward_F` and `dovetailedFMCS_backward_P`: Temporal coherence for the primary family
- `dovetailedTimelineQuotClosedFlags`: Modally saturated closed flags
- `dovetailedTimelineQuotBFMCS_modal_forward/backward`: Modal coherence proofs
- `parametric_canonical_truth_lemma`: Generic truth lemma for any D
- `parametric_shifted_truth_lemma`: Shift-closed version for completeness

**Missing**:
1. A complete `BFMCS (DovetailedTimelineQuot ...)` structure bundling modal and temporal coherence
2. Proof that ALL families in the closedFlags-based construction have `forward_F` and `backward_P`
3. The wiring that connects the BFMCS to `valid_over` negation

### Architectural Gap

The current `DovetailedTimelineQuotBFMCS` module is built on `CanonicalMCS` (all MCS) for modal saturation, but the temporal coherence requires reasoning about `FMCS (DovetailedTimelineQuot)` families. These are two different indexing schemes:

- **Modal domain**: `CanonicalMCS` - the set of all maximal consistent sets
- **Temporal domain**: `DovetailedTimelineQuot` - the dense linear order

The existing code provides pieces for both, but they are not wired together into a single `BFMCS` construction with proven temporal coherence.

## Proposed New Tasks

### New Task 1: Build Temporally Coherent Dense BFMCS

- **Effort**: 3-4 hours
- **Language**: lean4
- **Rationale**: This task creates the missing `BFMCS (DovetailedTimelineQuot ...)` structure with a proven `temporally_coherent` field. The BFMCS must contain families that are indexed by `DovetailedTimelineQuot` (not `CanonicalMCS`) to support the parametric truth lemma.
- **Depends on**: None

**Implementation approach**:
1. Define `dovetailedTimelineQuotBFMCS : BFMCS (DovetailedTimelineQuot root_mcs root_mcs_proof)`
2. Use singleton or closedFlags-based family construction
3. Prove `dovetailedTimelineQuotBFMCS_temporally_coherent` by lifting `dovetailedFMCS_forward_F` and `dovetailedFMCS_backward_P` to all families

**Key insight**: The `DirectMultiFamilyBFMCS` pattern from the discrete case (Task 28) provides a template. Each family in the BFMCS is constructed from a `CanonicalMCS` world, but the FMCS structure uses `DovetailedTimelineQuot` for temporal indexing.

### New Task 2: Wire Dense Truth Lemma Instantiation

- **Effort**: 2-3 hours
- **Language**: lean4
- **Rationale**: Once the temporally coherent BFMCS exists, this task instantiates `parametric_shifted_truth_lemma` at D = DovetailedTimelineQuot and proves `timelineQuot_not_valid_of_neg_consistent`. This directly unblocks the parent task's sorry at line 127.
- **Depends on**: New Task 1, because the truth lemma requires a BFMCS with proven temporal coherence (the specific structure from Task 1 affects how the instantiation is done)

**Implementation approach**:
1. In TimelineQuotCompleteness.lean, instantiate `parametric_shifted_truth_lemma` with the BFMCS from Task 1
2. Construct the canonical model: `ParametricCanonicalTaskModel (DovetailedTimelineQuot ...)`
3. Construct the shift-closed Omega: `ShiftClosedParametricCanonicalOmega B`
4. Connect root MCS membership to semantic truth via the truth lemma
5. Close the sorry in `timelineQuot_not_valid_of_neg_consistent`

## Dependency Reasoning

- **Task 2 depends on Task 1**: The truth lemma instantiation requires passing a `BFMCS D` and its `temporally_coherent` proof. The specific structure of the BFMCS (how families are constructed, how temporal coherence is proven) directly determines how the truth lemma can be applied. Without Task 1's BFMCS construction, Task 2 cannot proceed.

## After Completion

Once both spawned tasks are complete, resume the parent task #18 with `/implement 18`.

The blocker will be resolved because:
1. Task 1 provides the temporally coherent BFMCS required by the parametric truth lemma
2. Task 2 wires this BFMCS into the existing TimelineQuotCompleteness framework
3. Together, they close the sorry in `timelineQuot_not_valid_of_neg_consistent`
4. With this sorry resolved, `dense_completeness_theorem` compiles without sorry
