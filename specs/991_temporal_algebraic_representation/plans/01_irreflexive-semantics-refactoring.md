# Implementation Plan: Task #991

- **Task**: 991 - temporal_algebraic_representation
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None
- **Research Inputs**: research-003-irreflexive-refactoring-plan.md, research-002.md, research-001.md
- **Artifacts**: plans/01_irreflexive-semantics-refactoring.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Refactor the ProofChecker codebase from reflexive (<=, >=) to irreflexive (<, >) temporal semantics, eliminating ~1200 lines of Gabbay IRR proof complexity and enabling parametric representation theorems for distinct frame classes (base, dense, discrete). The refactoring follows research-003's complete file-by-file specification, prioritizing publication-ready elegance with no bridge lemmas, wrappers, or compatibility shims.

### Research Integration

This plan integrates findings from three research reports:

- **research-003**: Complete file-by-file refactoring specification (primary guide)
- **research-002**: STSAS axiomatization, strict semantics recommendation
- **research-001**: STSA algebraic structure design

The key insight is that irreflexive semantics makes the canonical ordering align with the semantic ordering, eliminating the domain mismatch that plagued the reflexive approach.

## Goals & Non-Goals

**Goals**:
- Change truth definition from <= to < (2 lines in Truth.lean)
- Drop temp_t_future and temp_t_past axioms (reflexive T-axioms)
- Reformulate density to GGp -> Gp (Sahlqvist form)
- Reformulate seriality to Gp -> Fp and Hp -> Pp (Sahlqvist forms)
- Replace 1200-line Gabbay IRR proof with ~50-line definitional argument
- Simplify truth lemma and staged construction (remove reflexive case branches)
- Eliminate all unnecessary aliases, bridge lemmas, and wrappers
- Achieve clean, publication-ready codebase

**Non-Goals**:
- Adding X/Y (next/prev) operators (deferred to discrete extension task)
- Adding stability operator (deferred to STSAS completion task)
- Adding Until/Since operators (deferred to Kamp-completeness task)
- Backward compatibility with reflexive semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof breakage cascade | H | H | Use sorry liberally in Phases 2-3, fill incrementally |
| Algebraic lemma incompatibility | M | M | sub_lt_iff_lt_add variants exist in Mathlib |
| Hidden T-axiom dependencies | M | M | Grep for temp_t_future/temp_t_past in all files |
| Decidability module breakage | M | L | FMP is largely reflexivity-independent |
| Perpetuity principles change | L | M | P1-P6 remain valid, proofs need minor reformulation |

## Implementation Phases

### Phase 1: Semantic Core Change [COMPLETED]

**Goal**: Change the fundamental truth definition from reflexive to strict temporal quantification.

**Tasks**:
- [ ] In Truth.lean, change line ~119: `s <= t` to `s < t` (all_past)
- [ ] In Truth.lean, change line ~120: `t <= s` to `t < s` (all_future)
- [ ] Update past_iff lemma (line ~209): change `s <= t` to `s < t`
- [ ] Update future_iff lemma (line ~222): change `t <= s` to `t < s`
- [ ] Update time_shift_preserves_truth (lines 345-498): replace le with lt
- [ ] Update all docstrings to say "strict" instead of "reflexive"
- [ ] Verify no other semantic files need changes (WorldHistory, TaskFrame, TaskModel, Validity)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Core truth definition and related lemmas

**Verification**:
- Project will NOT compile after this phase (expected)
- Grep confirms all temporal quantification uses `<` not `<=`

---

### Phase 2: Axiom System Refactoring [COMPLETED]

**Goal**: Remove reflexive T-axioms, reformulate density and seriality to Sahlqvist forms.

**Tasks**:
- [ ] Delete `temp_t_future` constructor from Axioms.lean (lines 242-256)
- [ ] Delete `temp_t_past` constructor from Axioms.lean (lines 258-272)
- [ ] Reformulate density axiom: change `Fp -> FFp` to `GGp -> Gp` (line ~365)
- [ ] Reformulate seriality_future: change `F(top)` to `Gp -> Fp` (line ~403)
- [ ] Reformulate seriality_past: change `P(top)` to `Hp -> Pp` (line ~420)
- [ ] Update classification predicates (isBase, isDenseCompatible, isDiscreteCompatible)
- [ ] Verify all 16 base axioms remain valid under strict semantics

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Axiom definitions

**Verification**:
- Axiom count reduces from 22 to 20
- All modified axioms have Sahlqvist form

---

### Phase 3: Soundness Proof Updates [PARTIAL]

**Goal**: Fix all soundness proofs to work with strict semantics.

**Tasks**:
- [ ] Delete `temp_t_future_valid` theorem from Soundness.lean (lines 190-196)
- [ ] Delete `temp_t_past_valid` theorem from Soundness.lean (lines 198-204)
- [ ] Rewrite `density_valid` with genuine density proof using DenselyOrdered witness
- [ ] Rewrite `seriality_future_valid` with NoMaxOrder witness
- [ ] Rewrite `seriality_past_valid` with NoMinOrder witness
- [ ] Update `axiom_base_valid`: remove temp_t_future/temp_t_past cases
- [ ] Update `axiom_valid_dense`: remove temp_t cases, update density case
- [ ] Update `axiom_valid_discrete`: remove temp_t cases, update seriality cases
- [ ] Update SoundnessLemmas.lean: remove T-axiom swap cases
- [ ] Update temp_l swap validity (use trichotomy argument)
- [ ] Update DenseSoundness.lean: delegate to genuine density proof

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Delete and rewrite validity proofs
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Update swap validity
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` - Non-trivial density proof
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Update seriality proofs

**Verification**:
- Soundness module compiles without sorry
- Density proof uses DenselyOrdered.dense explicitly

---

### Phase 4: Canonical Irreflexivity Simplification [NOT STARTED]

**Goal**: Replace the 1200-line Gabbay IRR proof with a simple definitional argument.

**Tasks**:
- [ ] Read current CanonicalIrreflexivity.lean to understand structure (~1268 lines)
- [ ] Also check: CanonicalIrreflexivityAxiom.lean (find in structure)
- [ ] Write new canonicalR_irreflexive proof (~30-50 lines):
  - Under strict semantics, CanonicalR M M is false by construction
  - Use temp_a axiom and linearity to derive contradiction
  - Proof: assume g_content M subset M, derive infinite chain, contradiction
- [ ] Delete all auxiliary lemmas no longer needed
- [ ] Update related imports and exports

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Complete rewrite (~1200 lines -> ~50 lines)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - May need updates

**Verification**:
- New proof is under 100 lines
- No Gabbay IRR technique artifacts remain
- IRRSoundness.lean references are updated

---

### Phase 5: Canonical Truth Lemma Simplification [NOT STARTED]

**Goal**: Remove reflexive case branches from the truth lemma.

**Tasks**:
- [ ] In CanonicalConstruction.lean, find all_future case (lines ~592-627)
- [ ] Remove the `rcases hts.lt_or_eq with hts_lt | hts_eq` branch
- [ ] Keep only the strict case: `exact (ih fam hfam s).mp (fam.forward_G ...)`
- [ ] Apply same simplification to all_past case (lines ~628-663)
- [ ] Remove any `temp_t_future` or `temp_t_past` axiom invocations
- [ ] Check ChainFMCS.lean for T-axiom uses and remove
- [ ] Verify WitnessSeed.lean needs no changes (already strict-compatible per research-003)
- [ ] Check CanonicalFMCS.lean preorder instance (reflexive closure still needed for Preorder)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Remove reflexive branches
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - Check for T-axiom usage

**Verification**:
- Truth lemma proof is shorter (fewer cases)
- No T-axiom references in canonical model construction

---

### Phase 6: Staged Construction Cleanup [NOT STARTED]

**Goal**: Remove reflexive case splits from staged construction and Cantor prerequisites.

**Tasks**:
- [ ] In DenseTimeline.lean, remove reflexive branch from densityIntermediateMCS (~48-72)
- [ ] Delete `density_frame_condition_reflexive_source` branch entirely
- [ ] Keep only the single-path construction using `density_frame_condition`
- [ ] In DensityFrameCondition.lean, verify strict intermediates (W != M and W != M')
- [ ] In CantorApplication.lean, remove axiom dependencies from DenselyOrdered instance
- [ ] Remove canonicalR_irreflexive invocations (strictness now automatic)
- [ ] Update NoMaxOrder/NoMinOrder instances similarly
- [ ] In CantorPrereqs.lean, remove axiom dependencies

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Remove case split
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Verify strictness
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - Remove axiom deps
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - Remove axiom deps

**Verification**:
- Single code path for density intermediate construction
- Cantor isomorphism proof has fewer dependencies

---

### Phase 7: Algebraic and Parametric Updates [NOT STARTED]

**Goal**: Update algebraic representation and parametric truth lemma modules.

**Tasks**:
- [ ] In ParametricTruthLemma.lean, remove reflexive case branches
- [ ] Check InteriorOperators.lean for T-axiom usage
- [ ] Verify ParametricRepresentation.lean needs no changes (D-parametric)
- [ ] Check AlgebraicRepresentation.lean for any reflexive dependencies
- [ ] Update any remaining T-axiom references in Algebraic/ directory

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Remove reflexive branches
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - Check T-axiom usage

**Verification**:
- Algebraic module compiles cleanly
- No T-axiom references remain

---

### Phase 8: Derived Theorems and Perpetuity [NOT STARTED]

**Goal**: Verify and update perpetuity principles P1-P6 and linearity facts.

**Tasks**:
- [ ] Verify P1-P6 remain valid under strict semantics
- [ ] P1 (box p -> always p): decompose via TF + modal T + H-mirror
- [ ] Update proofs in Perpetuity/Principles.lean if needed
- [ ] Update Perpetuity/Bridge.lean and Perpetuity/Helpers.lean as needed
- [ ] In LinearityDerivedFacts.lean, update counterexample frame description
- [ ] Remove references to "satisfying temp_t_future, temp_t_past"

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Verify/update proofs
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - Check dependencies
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean` - Check dependencies
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` - Update counterexample

**Verification**:
- All six perpetuity principles compile without sorry
- Linearity non-derivability proof updated

---

### Phase 9: Decidability and Automation [NOT STARTED]

**Goal**: Update decidability and automation modules for new axiom system.

**Tasks**:
- [ ] In Decidability/TruthPreservation.lean (if exists), check for T-axiom usage
- [ ] Update Tableau.lean axiom cases for new axiom system
- [ ] In Automation/Tactics.lean, remove hardcoded temp_t references
- [ ] In Automation/ProofSearch.lean, update axiom references
- [ ] In Automation/AesopRules.lean, verify compatibility

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/*.lean` - Update axiom cases
- `Theories/Bimodal/Automation/Tactics.lean` - Remove T-axiom references
- `Theories/Bimodal/Automation/ProofSearch.lean` - Update axiom references

**Verification**:
- Automation module compiles cleanly
- Bounded proof search works with new axiom set

---

### Phase 10: Final Cleanup and Verification [NOT STARTED]

**Goal**: Remove all cruft, verify clean build, run comprehensive tests.

**Tasks**:
- [ ] Grep for any remaining temp_t_future/temp_t_past references
- [ ] Grep for any remaining reflexive `<=` in temporal quantification
- [ ] Remove any orphaned helper lemmas or bridge definitions
- [ ] Run `lake build` and fix any remaining errors
- [ ] Verify no sorry remains in production code
- [ ] Update module-level documentation strings
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- Various cleanup across touched files
- Module documentation updates

**Verification**:
- `lake build` succeeds with no errors
- `grep -r "temp_t_future\|temp_t_past" Theories/` returns nothing
- No sorry in Theories/Bimodal/ (excluding Boneyard and Examples)

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase that should compile
- [ ] No temp_t_future or temp_t_past references remain
- [ ] Density proof uses DenselyOrdered.dense explicitly
- [ ] Seriality proof uses NoMaxOrder.exists_gt explicitly
- [ ] IRR proof is under 100 lines
- [ ] Truth lemma has no reflexive case branches
- [ ] Cantor prerequisites have no axiom dependencies
- [ ] All perpetuity principles compile without sorry

## Artifacts & Outputs

- plans/01_irreflexive-semantics-refactoring.md (this file)
- summaries/01_irreflexive-semantics-summary.md (after implementation)
- ~1200 lines deleted from CanonicalIrreflexivity
- ~50 lines of new simplified IRR proof
- Net reduction of ~1150 lines of proof code

## Rollback/Contingency

If the refactoring encounters insurmountable obstacles:
1. Git reset to pre-refactoring commit
2. Preserve any partial progress in a feature branch
3. Document specific blockers for future attempts
4. Consider incremental approach: strict semantics as separate module first

The primary risk is undiscovered T-axiom dependencies. If found, they can be addressed by:
- Adding explicit reflexive closure operators where genuinely needed
- Using weak_future/weak_past (already defined) to recover reflexive behavior
