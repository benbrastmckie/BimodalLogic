# Implementation Plan: Task #1006 (v4)

- **Task**: 1006 - canonical_taskframe_completeness
- **Version**: 04 (Three Completeness Theorems)
- **Status**: [NOT STARTED]
- **Effort**: 12-16 hours
- **Dependencies**: None
- **Research Inputs**:
  - `06_team-research.md` - Convexity blocker analysis (convex sorry provably false)
  - `07_dovetailed-z-detailed.md` - Dovetailed approach details (full domain fix)
  - `08_base-dense-discrete-strategy.md` - Three-logic hierarchy (D-polymorphic strategy)
- **Artifacts**: `plans/04_three-completeness-plan.md` (this file)
- **Type**: lean4

## Overview

Prove completeness for all three TM logic variants using the D-polymorphic parametric infrastructure with `parametric_to_history` (full domain, trivially convex):

| Logic | Axioms | D | Construction | Key Theorem |
|-------|--------|---|--------------|-------------|
| **Base** | 15 base | Int (choice) | Either | `base_completeness` |
| **Dense** | +DN | Rat (Cantor) | DovetailedBuild | `dense_completeness` |
| **Discrete** | +DF/DB+seriality | Int (characterization) | discreteStagedBuild | `discrete_completeness` |

### Key Insight from Research

The v3 plan's `shiftedFlagWorldHistory` is **mathematically blocked** — discrete chain image in Rat is never convex. The solution is NOT to fix that sorry, but to use `parametric_to_history` which has **full domain** (`domain = True`), making convexity trivial.

### Changes from v3

| Aspect | v3 (Blocked) | v4 (Three Completeness) |
|--------|--------------|------------------------|
| Scope | Dense only | Base + Dense + Discrete |
| Domain strategy | Restricted (non-convex) | Full domain (trivially convex) |
| WorldHistory | `shiftedFlagWorldHistory` (blocked) | `parametric_to_history` (working) |
| D for dense | Rat (Cantor embedding) | Rat (Cantor isomorphism) |
| D for discrete | N/A | Int (characterization theorem) |

## Goals & Non-Goals

**Goals**:
- Prove `base_completeness : valid_base φ → Nonempty (DerivationTree [] φ)`
- Prove `dense_completeness : valid_dense φ → Nonempty (DerivationTree_dense [] φ)`
- Prove `discrete_completeness : valid_discrete φ → Nonempty (DerivationTree_discrete [] φ)`
- Use shared D-polymorphic infrastructure maximally
- Remove/deprecate blocked `shiftedFlagWorldHistory` construction

**Non-Goals**:
- Modify `WorldHistory.convex` requirement (semantics unchanged)
- Conservative extension proofs (different approach)
- Decidability (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DovetailedTimelineQuot FMCS forward_F/P blocked | H | M | Use coverage theorems from DovetailedCoverage.lean |
| DenselyOrdered instance hard to prove | M | L | Density witnesses exist from processDensityDovetailed |
| DiscreteTimeline LocallyFiniteOrder axiomatized | M | L | Accept axiom or prove from construction |
| Base completeness still blocked by IntFMCSTransfer | H | M | Use dovetailed chain for all three (unifying approach) |

## Implementation Phases

### Phase 1: Fix Common F/P Infrastructure [BLOCKED]

**Goal**: Establish self-contained F/P witness infrastructure that works for all three logics.

**Key Insight**: The F/P coherence problem is the **same** for base, dense, and discrete. DovetailedBuild's coverage theorems (`dovetailedTimeline_has_future/past`) provide self-contained witnesses. We unify all three by using dovetailed chains as the foundation.

**Tasks**:
1. Verify `dovetailedTimeline_has_future` and `dovetailedTimeline_has_past` are sorry-free
2. Verify these give witnesses **in the same timeline** (not just somewhere in CanonicalMCS)
3. Establish `DovetailedTimelineQuotFMCS` with all four temporal properties:
   - `forward_G` (from canonical MCS G-closure)
   - `backward_H` (from canonical MCS H-closure)
   - `forward_F` (from `dovetailedTimeline_has_future`)
   - `backward_P` (from `dovetailedTimeline_has_past`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - verify coverage
- Extract from Boneyard: `DovetailedTimelineQuot.lean` if needed

**Verification**:
- `DovetailedTimelineQuotFMCS` compiles without sorry
- Coverage theorems give in-timeline witnesses

**Estimated effort**: 3 hours

---

### Phase 2: Base Completeness via Dovetailed + Int [NOT STARTED]

**Goal**: Prove base completeness using dovetailed chain mapped to Int.

**Approach**: Rather than fixing `IntFMCSTransfer.lean`, use the unified dovetailed approach:
1. Build dovetailed chain (skipping density processing for base)
2. Map to Int (any order-preserving enumeration works since base is order-neutral)
3. Apply `parametric_to_history` with full domain
4. Apply `parametric_shifted_truth_lemma`
5. Wire to `algebraic_base_completeness`

**Alternative**: If the dovetailed chain is inherently dense, simply use the dense construction with D = Rat for base completeness. Base-valid formulas are also dense-valid, so a Rat model suffices as a countermodel.

**Tasks**:
1. Determine if base can reuse dense construction (simpler) or needs separate chain
2. Build `BaseFMCS Int` or reuse `DovetailedFMCS Rat`
3. Apply `parametric_to_history`
4. Wire to completeness theorem

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`
- Possibly new: `Theories/Bimodal/Metalogic/DovetailedBaseCompleteness.lean`

**Verification**:
- `base_completeness` proven without sorry
- `lake build` passes

**Estimated effort**: 3 hours

---

### Phase 3: Dense Completeness via Cantor Isomorphism [NOT STARTED]

**Goal**: Prove dense completeness using DovetailedBuild + Cantor isomorphism to Rat.

**Approach**:
1. DovetailedBuild produces `DovetailedTimelineQuot` (countable, dense, no endpoints)
2. Apply Cantor's theorem: `Order.iso_of_countable_dense` gives `DovetailedTimelineQuot ≃o Rat`
3. Transfer AddCommGroup from Rat via `Equiv.addCommGroup`
4. Build `FMCS Rat` from `DovetailedTimelineQuotFMCS`
5. Apply `parametric_to_history` → WorldHistory with full domain
6. Apply `parametric_shifted_truth_lemma`
7. Wire final completeness theorem

**Required Instances on DovetailedTimelineQuot**:
- `Countable` - from countable dovetailed union
- `DenselyOrdered` - from `processDensityDovetailed`
- `NoMaxOrder` - from `dovetailedTimeline_has_future`
- `NoMinOrder` - from `dovetailedTimeline_has_past`
- `Nonempty` - from root point

**Tasks**:
1. Prove/verify `Countable DovetailedTimelineQuot`
2. Prove `DenselyOrdered DovetailedTimelineQuot` from density witnesses
3. Construct `DovetailedRatOrderIso : DovetailedTimelineQuot ≃o Rat`
4. Transfer AddCommGroup: `dovetailedAddCommGroup`
5. Build `DovetailedFMCS_Rat : FMCS Rat`
6. Apply pipeline: `parametric_to_history` → `parametric_shifted_truth_lemma`
7. Wire `dense_completeness`

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - Cantor iso
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - wire completeness
- New: `Theories/Bimodal/Metalogic/DovetailedDenseCompleteness.lean`

**Verification**:
- `dense_completeness` proven without sorry
- Cantor isomorphism is well-typed
- `lake build` passes

**Estimated effort**: 4 hours

---

### Phase 4: Discrete Completeness via Characterization Theorem [NOT STARTED]

**Goal**: Prove discrete completeness using discreteStagedBuild + Int characterization.

**Approach**:
1. `discreteStagedBuild` produces `DiscreteTimelineQuot` (countable, discrete, no endpoints)
2. Apply characterization: `orderIsoIntOfLinearSuccPredArch` gives `DiscreteTimelineQuot ≃o Int`
3. Int already has AddCommGroup
4. Build `FMCS Int` from `DiscreteFMCS`
5. Apply `parametric_to_history` → WorldHistory with full domain
6. Apply `parametric_shifted_truth_lemma`
7. Wire final completeness theorem

**Required Instances on DiscreteTimelineQuot**:
- `LinearOrder` - from Antisymmetrization
- `SuccOrder` - from discreteness (LocallyFiniteOrder)
- `PredOrder` - from discreteness
- `IsSuccArchimedean` - from LocallyFiniteOrder
- `NoMaxOrder` - from seriality_future
- `NoMinOrder` - from seriality_past
- `Nonempty` - from root point

**Note**: `DiscreteTimeline.lean` has `discrete_Icc_finite_axiom` (axiomatized LocallyFiniteOrder). Either prove this or accept the axiom.

**Tasks**:
1. Verify `discreteStagedBuild` produces appropriate chain structure
2. Verify `SuccOrder`/`PredOrder` instances on `DiscreteTimelineQuot`
3. Construct `DiscreteIntOrderIso : DiscreteTimelineQuot ≃o Int`
4. Build `DiscreteFMCS_Int : FMCS Int`
5. Apply pipeline: `parametric_to_history` → `parametric_shifted_truth_lemma`
6. Wire `discrete_completeness`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - verify instances
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - wire completeness
- New: `Theories/Bimodal/Metalogic/DovetailedDiscreteCompleteness.lean`

**Verification**:
- `discrete_completeness` proven (with acceptable axiom if needed)
- Characterization theorem applies
- `lake build` passes

**Estimated effort**: 3 hours

---

### Phase 5: Cleanup and Integration [NOT STARTED]

**Goal**: Remove blocked code, integrate three completeness theorems, update exports.

**Tasks**:
1. Deprecate/remove `shiftedFlagWorldHistory` from `FlagBFMCSRatBundle.lean`
2. Deprecate/remove blocked sorries from `IntFMCSTransfer.lean` (if superseded)
3. Update `Metalogic.lean` exports to include all three completeness theorems
4. Add `Completeness.lean` umbrella module with:
   - `base_completeness`
   - `dense_completeness`
   - `discrete_completeness`
5. Run full `lake build` verification
6. Update docstrings to reflect new architecture

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean` - cleanup
- `Theories/Bimodal/Metalogic/Metalogic.lean` - exports
- New: `Theories/Bimodal/Metalogic/Completeness.lean` - umbrella

**Verification**:
- Full `lake build` passes
- All three completeness theorems accessible from `Bimodal.Metalogic.Completeness`
- No sorries in completeness chain

**Estimated effort**: 2 hours

---

## Testing & Validation

- [ ] Phase 1: `DovetailedTimelineQuotFMCS` compiles without sorry
- [ ] Phase 2: `base_completeness` proven
- [ ] Phase 3: `dense_completeness` proven
- [ ] Phase 4: `discrete_completeness` proven (acceptable axiom documented)
- [ ] Phase 5: Full `lake build` passes
- [ ] All three theorems use shared `parametric_to_history` with full domain
- [ ] No non-axiom sorries in completeness proofs

## Alternative Simplification

If proving all three separately is too complex, consider:

**Unified Dense Construction for All Three**:
1. Dense frames include base frames (base is valid on all frames, including dense)
2. Prove only `dense_completeness` with D = Rat
3. For base completeness: use dense construction (Rat model is valid for base formulas)
4. For discrete: accept as future work (task 989)

This simplifies to 2 phases but loses separate characterization for discrete.

## Dependencies on Existing Infrastructure

| Component | Location | Status | Usage |
|-----------|----------|--------|-------|
| `parametric_to_history` | `ParametricHistory.lean` | Working | Full domain WorldHistory |
| `parametric_shifted_truth_lemma` | `ParametricTruthLemma.lean` | Working | MCS ↔ truth |
| `DovetailedBuild` | `DovetailedBuild.lean` | Working | Dense chain construction |
| `dovetailedTimeline_has_future/past` | `DovetailedCoverage.lean` | Verify | Self-contained F/P |
| `discreteStagedBuild` | `StagedExecution.lean` | Working | Discrete chain construction |
| `Order.iso_of_countable_dense` | Mathlib | Working | Cantor isomorphism |
| `orderIsoIntOfLinearSuccPredArch` | Mathlib | Working | Discrete characterization |
| `Equiv.addCommGroup` | Mathlib | Working | Group transfer |
| `DurationTransfer` | `DurationTransfer.lean` | Working | `transferAddCommGroup` |

## Success Criteria

1. `base_completeness` proven without sorry
2. `dense_completeness` proven without sorry
3. `discrete_completeness` proven (acceptable axiom documented if needed)
4. All three use `parametric_to_history` with full domain
5. Full `lake build` succeeds
6. Blocked `shiftedFlagWorldHistory` construction removed/deprecated
