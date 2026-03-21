# Implementation Plan: Task #991 (Axiom-Based Completion)

- **Task**: 991 - temporal_algebraic_representation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: reports/06_irreflexivity-rigorous-analysis.md, reports/07_axiom-vs-irr-analysis.md
- **Artifacts**: plans/03_axiom-based-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan completes the irreflexive temporal semantics refactoring using the **axiom declaration approach** recommended by Report 07. Phases 1-3 are already complete (semantic core change, axiom system refactoring, soundness proof updates). The blocking issue at Phase 4 is resolved by accepting irreflexivity as a semantic axiom rather than attempting syntactic derivation.

### Research Integration

**Report 06 (Rigorous Analysis)**: Proves irreflexivity is NOT modally definable (van Benthem theorem). No TM formula characterizes irreflexive frames.

**Report 07 (Axiom vs IRR)**: Confirms axiom declaration is standard practice in modal logic embeddings, NOT technical debt. The codebase already uses this pattern with `discrete_Icc_finite_axiom`.

### Prior Progress Preservation

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | [COMPLETED] | Semantic Core Change |
| 2 | [COMPLETED] | Axiom System Refactoring |
| 3 | [COMPLETED] | Soundness Proof Updates |
| 4 | [BLOCKED] | Irreflexivity proof - THIS PLAN resolves |

## Goals & Non-Goals

**Goals**:
- Replace sorry with mathematically justified axiom declaration
- Complete truth lemma simplification (remove reflexive branches)
- Update staged construction and Cantor prerequisites
- Update algebraic representation modules
- Verify derived theorems and perpetuity principles
- Achieve clean build with no sorry in production code
- Document axiom usage for publication

**Non-Goals**:
- Adding X/Y (next/prev) operators (discrete extension scope)
- Proving irreflexivity syntactically (mathematically impossible)
- Backward compatibility with reflexive semantics
- Changing axiom architecture (seriality stays in extensions)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden T-axiom dependencies in remaining phases | M | L | Grep for temp_t references before each phase |
| Algebraic module incompatibility | L | L | Check InteriorOperators.lean for T-axiom early |
| Publication concern about axiom | M | L | Comprehensive docstring with mathematical justification |
| Downstream theorem failures | H | L | Build verification after each phase |

## Implementation Phases

### Phase 4: Axiom Declaration [COMPLETED]

**Goal**: Replace the sorry at line 1257 of CanonicalIrreflexivity.lean with a proper axiom declaration.

**Tasks**:
- [ ] Read current CanonicalIrreflexivity.lean structure
- [ ] Add `axiom canonicalR_irreflexive_axiom` with comprehensive docstring
- [ ] Include mathematical justification (van Benthem non-definability)
- [ ] Include semantic argument (strict G/H cannot have t > t)
- [ ] Reference reports 06 and 07 in docstring
- [ ] Replace sorry with axiom invocation
- [ ] Update module docstring to note axiom usage
- [ ] Run `lake build` to verify compilation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Add axiom, remove sorry

**Verification**:
- No sorry remains in CanonicalIrreflexivity.lean
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds
- Docstring explains mathematical justification

---

### Phase 5: Truth Lemma Simplification [COMPLETED]

**Goal**: Remove reflexive case branches from the canonical model truth lemma.

**Tasks**:
- [ ] In CanonicalConstruction.lean, find all_future case (around lines 592-627)
- [ ] Remove `rcases hts.lt_or_eq with hts_lt | hts_eq` branch pattern
- [ ] Keep only strict case: `exact (ih fam hfam s).mp (fam.forward_G ...)`
- [ ] Apply same simplification to all_past case (around lines 628-663)
- [ ] Remove any temp_t_future or temp_t_past references
- [ ] Check ChainFMCS.lean for T-axiom uses (1 reference found)
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Remove reflexive branches
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - Remove T-axiom reference

**Verification**:
- Truth lemma proof is shorter (single code path)
- No temp_t references in Bundle/ directory
- `lake build Bimodal.Metalogic.Bundle` succeeds

---

### Phase 6: Staged Construction & Cantor [PARTIAL]

**Goal**: Remove reflexive case splits from staged construction, update Cantor prerequisites.

**Tasks**:
- [ ] In CantorPrereqs.lean, check `derive_F_to_FF` (derive Fphi->FFphi from density)
- [ ] In CanonicalTimeline.lean, check `density_of_canonicalR`
- [ ] In DenseTimeline.lean, remove reflexive branch from densityIntermediateMCS
- [ ] Delete `density_frame_condition_reflexive_source` if exists
- [ ] In DensityFrameCondition.lean, verify strict intermediates (W != M and W != M')
- [ ] In CantorApplication.lean, remove axiom dependencies on reflexivity
- [ ] Remove unnecessary canonicalR_irreflexive invocations
- [ ] In DiscreteSuccSeed.lean, check temp_t references (2 found)
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- Single code path for density intermediate construction
- Cantor isomorphism proof compiles
- `lake build Bimodal.Metalogic.StagedConstruction` succeeds

---

### Phase 7: Algebraic Module Updates [COMPLETED]

**Goal**: Update algebraic representation and parametric truth lemma modules.

**Tasks**:
- [ ] In ParametricTruthLemma.lean, check 4 temp_t references and remove if applicable
- [ ] In InteriorOperators.lean, check 6 temp_t references and assess impact
- [ ] Verify ParametricRepresentation.lean needs no changes
- [ ] Check AlgebraicRepresentation.lean for reflexive dependencies
- [ ] Update any remaining T-axiom references in Algebraic/ directory
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean`

**Verification**:
- Algebraic module compiles cleanly
- temp_t references removed or documented as intentional
- `lake build Bimodal.Metalogic.Algebraic` succeeds

---

### Phase 8: Derived Theorems [COMPLETED]

**Goal**: Verify and update perpetuity principles and linearity facts.

**Tasks**:
- [ ] Verify P1-P6 perpetuity principles remain valid
- [ ] P1 (box p -> always p): verify decomposition works without modal T
- [ ] Update proofs in Perpetuity/Principles.lean if needed
- [ ] Check Bridge.lean and Helpers.lean dependencies
- [ ] In LinearityDerivedFacts.lean, update counterexample frame description (2 refs)
- [ ] Remove temp_t_future/temp_t_past from counterexample text
- [ ] Run `lake build` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean`
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean`
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean`

**Verification**:
- All perpetuity principles compile without sorry
- Linearity non-derivability proof updated
- `lake build Bimodal.Theorems.Perpetuity` succeeds

---

### Phase 9: Final Cleanup & Documentation [COMPLETED]

**Goal**: Remove all cruft, update documentation, verify clean build.

**Tasks**:
- [ ] Grep for remaining temp_t_future/temp_t_past references
- [ ] Check Decidability/ directory for T-axiom usage
- [ ] Update Tableau.lean axiom cases if needed
- [ ] In Automation/Tactics.lean, check for hardcoded temp_t references
- [ ] Grep for any remaining reflexive `<=` in temporal quantification
- [ ] Remove orphaned helper lemmas
- [ ] Update LogicVariants.lean (2 temp_t refs) - clarify as historical/variant
- [ ] Update Soundness.lean (1 temp_t ref) - clarify as frame condition documentation
- [ ] Run full `lake build` verification
- [ ] Verify no sorry in Theories/Bimodal/ (excluding Boneyard/, Examples/)
- [ ] Update ARCHITECTURE.md noting axiom-based irreflexivity
- [ ] Create completion summary

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/LogicVariants.lean` - Documentation update
- `Theories/Bimodal/FrameConditions/Soundness.lean` - Documentation update
- `ARCHITECTURE.md` or relevant documentation

**Verification**:
- `lake build` succeeds with no errors
- `grep -r "temp_t_future\|temp_t_past" Theories/Bimodal/` shows only intentional references
- No sorry in production code (Theories/Bimodal/ excluding Boneyard/ and Examples/)
- Documentation reflects axiom-based approach

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No temp_t_future or temp_t_past references remain in active code
- [ ] Axiom has comprehensive mathematical justification in docstring
- [ ] Truth lemma has no reflexive case branches
- [ ] Cantor prerequisites have no axiom dependencies on reflexivity
- [ ] All perpetuity principles compile without sorry
- [ ] Documentation updated to reflect axiom-based irreflexivity

## Artifacts & Outputs

- plans/03_axiom-based-completion.md (this file)
- summaries/04_axiom-based-completion-summary.md (after implementation)
- `axiom canonicalR_irreflexive_axiom` added to CanonicalIrreflexivity.lean
- ~35 temp_t references reviewed and handled
- ARCHITECTURE.md updated with axiom documentation

## Rollback/Contingency

### If axiom approach rejected

The axiom approach is the mathematically correct solution per Report 07. If rejected:
1. Keep sorry with comprehensive documentation
2. Mark task as BLOCKED with mathematical justification
3. Future work could explore hybrid logic extension (major scope change)

### If downstream theorems fail

1. Check if failure is due to missing T-axiom assumption
2. Verify the theorem is still valid under strict semantics
3. If theorem requires reflexivity, either:
   - Remove theorem if not needed
   - Move to Boneyard/ with explanation
   - Add explicit frame condition hypothesis
