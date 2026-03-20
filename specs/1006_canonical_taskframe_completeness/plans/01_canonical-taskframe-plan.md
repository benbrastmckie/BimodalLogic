# Implementation Plan: Task #1006

- **Task**: 1006 - canonical_taskframe_completeness
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (supersedes task 997)
- **Research Inputs**: specs/1006_canonical_taskframe_completeness/reports/01_team-research.md
- **Artifacts**: plans/01_canonical-taskframe-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the FlagBFMCS `satisfies_at` relation with a canonical TaskFrame construction using the official `truth_at` from the semantic layer. The approach leverages the existing parametric algebraic infrastructure (`ParametricCanonical`, `ParametricHistory`, `ParametricTruthLemma`, `ParametricRepresentation`) which is already sorry-free. The core challenge is constructing a `BFMCS Int` from `FlagBFMCS` data by embedding `ChainFMCSDomain F` (Flag chain positions) into `Int` while preserving temporal coherence properties.

### Research Integration

Key findings from team research:
- **Type Gap**: `satisfies_at` operates on `(Flag, ChainFMCSDomain)` pairs without a duration group `D`, while `truth_at` requires explicit `D` with `AddCommGroup` structure
- **Reusable Pipeline**: `ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean`, `ParametricRepresentation.lean` provide a complete sorry-free path from `BFMCS D` to `valid`-based completeness
- **Core Obstacle**: `ChainFMCSDomain F` lacks `AddCommGroup` - resolution is to use `D = Int` and embed Flag positions via order-preserving maps
- **Modal Coherence**: `FlagBFMCS.modally_saturated` must be shown equivalent to `BFMCS.modal_forward`/`modal_backward` after embedding

## Goals & Non-Goals

**Goals**:
- Construct a canonical `BFMCS Int` from `FlagBFMCS` data
- Define order-preserving embeddings from `ChainFMCSDomain F` to `Int` for each Flag
- Prove the completeness theorem using `truth_at` and `valid` (not `satisfies_at`)
- Eliminate `satisfies_at` from the completeness proof path

**Non-Goals**:
- Remove `satisfies_at` definition entirely (may be useful for other purposes)
- Modify the existing parametric infrastructure (it's already complete)
- Support dense time (D = Rat) - this task focuses on base completeness with D = Int

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Countable embedding construction is complex | H | M | Leverage `Countable CanonicalMCS` from countability of formula language; use `Nat.find` pattern |
| Modal coherence transfer fails | H | L | `modally_saturated` and `modal_forward`/`modal_backward` are semantically equivalent; may need explicit witness construction |
| Temporal coherence lost in embedding | M | L | Embedding preserves order; `chainFMCS.forward_G`/`backward_H` transfer directly |
| BFMCS bundle construction requires new infrastructure | M | M | May need intermediate types; can construct incrementally |

## Implementation Phases

### Phase 1: Countable Order Embedding Infrastructure [NOT STARTED]

**Goal**: Define order-preserving embeddings from `ChainFMCSDomain F` into `Int` for each Flag.

**Tasks**:
- [ ] Create `FlagBFMCSToInt.lean` in `Theories/Bimodal/Metalogic/Bundle/`
- [ ] Define `embed_flag : ChainFMCSDomain F -> Int` as order-preserving injection
- [ ] Prove `embed_flag` is order-preserving: `x < y -> embed_flag x < embed_flag y`
- [ ] Prove `embed_flag` is injective: `embed_flag x = embed_flag y -> x = y`
- [ ] Use `Countable CanonicalMCS` to construct enumeration-based embedding

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSToInt.lean` - new file

**Verification**:
- All theorems compile without `sorry`
- `embed_flag` is monotone and injective
- Can convert any `ChainFMCSDomain F` element to `Int`

---

### Phase 2: Int-Indexed FMCS Per Flag [NOT STARTED]

**Goal**: Convert `chainFMCS F : FMCS (ChainFMCSDomain F)` to `FMCS Int` using the embedding.

**Tasks**:
- [ ] Define `intFMCS_from_flag : Flag CanonicalMCS -> FMCS Int`
- [ ] Define `mcs : Int -> Set Formula` by mapping through inverse embedding or default
- [ ] Prove `is_mcs t : SetMaximalConsistent (mcs t)` for all `t : Int`
- [ ] Transfer `forward_G` and `backward_H` from `chainFMCS` through the embedding
- [ ] Handle domain boundary: times outside the embedded range should map to some fixed MCS

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSToInt.lean` - add FMCS construction

**Verification**:
- `intFMCS_from_flag F` is a valid `FMCS Int`
- `forward_G` and `backward_H` hold for the Int-indexed FMCS
- Building Lake passes with no `sorry`

---

### Phase 3: BFMCS Int Bundle Construction [NOT STARTED]

**Goal**: Bundle all Int-indexed FMCS from `FlagBFMCS` into a `BFMCS Int` with modal/temporal coherence.

**Tasks**:
- [ ] Define `bfmcs_from_flagbfmcs : FlagBFMCS -> BFMCS Int`
- [ ] Define `families` as the set of Int-indexed FMCS from each Flag
- [ ] Prove `modal_forward`: derive from `FlagBFMCS.modally_saturated`
- [ ] Prove `modal_backward`: derive from completeness of Flag coverage
- [ ] Define `temporally_coherent` predicate satisfaction

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSToInt.lean` - add BFMCS construction
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean` - may need helper lemmas

**Verification**:
- `bfmcs_from_flagbfmcs` produces valid `BFMCS Int`
- Modal forward/backward conditions hold
- `temporally_coherent` is satisfied
- Lake build passes

---

### Phase 4: Canonical TaskFrame Completeness Theorem [NOT STARTED]

**Goal**: State and prove the completeness theorem using `valid` instead of `satisfies_at`.

**Tasks**:
- [ ] Create `FlagBFMCSCanonicalCompleteness.lean` in `Theories/Bimodal/Metalogic/Bundle/`
- [ ] Define theorem: `consistent S -> exists TaskModel where truth_at holds for all phi in S`
- [ ] Wire through parametric pipeline: `bfmcs_from_flagbfmcs` -> `parametric_to_history` -> `parametric_shifted_truth_lemma` -> `parametric_representation_from_neg_membership`
- [ ] Prove completeness against `valid` using the `AlgebraicBaseCompleteness` pattern
- [ ] Add `FlagBFMCS_canonical_completeness` as main theorem

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCanonicalCompleteness.lean` - new file
- `Theories/Bimodal/Metalogic/Metalogic.lean` - add import

**Verification**:
- Completeness theorem compiles without `sorry`
- Uses `valid` (not `satisfies_at`) in the statement
- Matches the parametric completeness pattern from `AlgebraicBaseCompleteness.lean`

---

### Phase 5: Integration and Cleanup [NOT STARTED]

**Goal**: Integrate the new completeness theorem and update documentation.

**Tasks**:
- [ ] Add imports to `Metalogic.lean` for new modules
- [ ] Verify full Lake build succeeds
- [ ] Add docstrings explaining the canonical TaskFrame approach
- [ ] Update `FlagBFMCSCompleteness.lean` header comments to note supersession
- [ ] Consider marking `satisfies_at` as deprecated or internal

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - add imports
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean` - update docs
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean` - update docs

**Verification**:
- Full `lake build` passes
- New completeness theorem is accessible from main module
- Documentation accurately describes the architectural relationship

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors or warnings
- [ ] `lean_verify` on new theorems confirms no sorries
- [ ] New completeness theorem matches type signature of `valid`
- [ ] Parametric pipeline components remain unchanged
- [ ] All new theorems are importable from `Bimodal.Metalogic.Metalogic`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSToInt.lean` - embedding and FMCS/BFMCS construction
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCanonicalCompleteness.lean` - completeness theorem

## Rollback/Contingency

If the countable embedding construction proves intractable:
1. **Alternative**: Use `D = ChainFMCSDomain F` for a single specific Flag F, artificially adding `AddCommGroup` structure
2. **Fallback**: Mark incomplete phases as `[PARTIAL]` and document remaining work
3. **Preservation**: All changes are additive; existing `FlagBFMCSCompleteness.lean` remains functional

## Success Criteria

1. New `FlagBFMCS_canonical_completeness` theorem proven without `sorry`
2. Theorem states: `consistent S -> exists (F : TaskFrame Int) (M : TaskModel F) (Omega) (tau) (t), tau in Omega /\ forall phi in S, truth_at M Omega tau t phi`
3. Uses parametric infrastructure (`ParametricCanonicalTaskFrame`, `parametric_to_history`, `parametric_shifted_truth_lemma`)
4. Full Lake build succeeds
5. Architecture matches research recommendation (BFMCS Int from FlagBFMCS)
