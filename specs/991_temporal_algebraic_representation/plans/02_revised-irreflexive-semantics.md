# Implementation Plan: Task #991 (Revised)

- **Task**: 991 - temporal_algebraic_representation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours (reduced from 16)
- **Dependencies**: None
- **Research Inputs**: 04_synthesis.md, 05_extension-lattice-analysis.md, research-003-irreflexive-refactoring-plan.md
- **Artifacts**: plans/02_revised-irreflexive-semantics.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is a REVISED plan addressing the Phase 4 blocker discovered during implementation. The original 10-phase plan blocked at the irreflexivity proof because the naming set approach requires T-axiom `H(phi) -> phi`, which is invalid under strict semantics.

The revised plan uses the **temp_a + linearity proof strategy** identified in the synthesis research: assume `CanonicalR M M` (i.e., `g_content M subset M`), use temp_a and linearity axioms to derive an infinite regress contradiction. This preserves the current axiom architecture (seriality stays in Discrete extension) while achieving the ~1200-line reduction goal.

### Research Integration

**04_synthesis.md findings**:
- Strict semantics is confirmed correct (standard in mathematical logic)
- Naming set proof fails because `{p, H(neg p)}` is consistent under strict semantics
- temp_a + linearity proof works without requiring seriality in base

**05_extension-lattice-analysis.md findings**:
- TM logic corresponds to Kt.Lin.Ser (unbounded linear time)
- The extension hierarchy is: Base -> +Seriality -> (+Density OR +Discreteness)
- Sahlqvist property holds for base, seriality, and density axioms (automatic representation)
- Discreteness requires non-canonical completeness proof

### Progress Preservation

**Completed phases from original plan**:
- Phase 1: Semantic Core Change [COMPLETED]
- Phase 2: Axiom System Refactoring [COMPLETED]
- Phase 3: Soundness Proof Updates [COMPLETED]

This revised plan continues from Phase 4 with a new proof strategy.

## Goals & Non-Goals

**Goals**:
- Unblock Phase 4 with temp_a + linearity irreflexivity proof
- Replace 1200-line Gabbay IRR proof with ~50-100 line proof
- Complete remaining phases 5-10 from original plan
- Achieve clean, publication-ready codebase with strict semantics

**Non-Goals**:
- Adding X/Y (next/prev) operators (deferred to discrete extension)
- Adding stability operator (deferred to STSAS completion)
- Changing axiom architecture (seriality stays in Discrete extension)
- Backward compatibility with reflexive semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| temp_a proof formalization harder than expected | H | M | Fallback to seriality-in-base approach |
| Hidden T-axiom dependencies in later phases | M | L | Grep for temp_t references before each phase |
| Linearity axiom interaction complexity | M | M | Detailed proof sketch before implementation |
| Algebraic module incompatibility | L | L | Check InteriorOperators.lean for T-axiom |

## Implementation Phases

### Phase 4: Irreflexivity via temp_a + Linearity [BLOCKED]

**Goal**: Replace the blocked naming set proof with a direct proof using temp_a and linearity axioms.

**Proof Strategy**:
Assume `CanonicalR M M` (i.e., `g_content M subset M`). Derive contradiction:

1. Take any `phi in M`. By temp_a axiom: `G(P(phi)) in M`
2. Since `G(P(phi)) in M`, we have `P(phi) in g_content(M)`
3. By assumption `CanonicalR M M`: `P(phi) in M`
4. `P(phi) = neg H(neg phi)`, so `H(neg phi) notin M`
5. By linearity (temp_l/temp_lin), M is linearly ordered among worlds
6. Combined with `G(P(phi)) in M` for all `phi in M`, this creates infinite regress
7. Contradiction with MCS finiteness/well-foundedness

**Tasks**:
- [ ] Study current CanonicalIrreflexivity.lean structure (~1283 lines)
- [ ] Identify auxiliary lemmas that can be deleted
- [ ] Write new `canonicalR_irreflexive` proof (~50-100 lines)
- [ ] Formalize the temp_a + linearity argument rigorously
- [ ] Delete obsolete Gabbay IRR infrastructure
- [ ] Update CanonicalIrreflexivityAxiom.lean if needed
- [ ] Verify IRRSoundness.lean references are updated

**Timing**: 3 hours (increased from 2 hours due to proof complexity)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Complete rewrite (~1200 lines -> ~100 lines)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - May need updates

**Verification**:
- New proof compiles without sorry
- No Gabbay IRR technique artifacts remain
- Proof uses only temp_a, linearity, and MCS properties

**Fallback**: If temp_a proof is too complex, fall back to seriality-in-base approach (add G(phi)->F(phi) to base axioms).

### BLOCKING ISSUE (2026-03-18)

The temp_a + linearity proof strategy does NOT close the proof gap. Analysis:

**Why the current naming set approach fails (confirmed)**:
- Under strict semantics, `{p, H(neg p)}` is semantically consistent
- It models "p is true now for the first time" (p now, neg p at all strictly past times)
- Without T-axiom (`H(phi) -> phi`), we cannot derive `neg p in M'` from `H(neg p) in M'`

**Why temp_a + linearity doesn't help (discovered)**:
- The temp_a closure gives: for any `phi in M`, `P(phi) in M` (via `G(P(phi)) in M` + CanonicalR closure)
- This means `H(neg phi) not-in M` for any `phi in M`
- BUT: This is analyzed in DirectIrreflexivity.lean which concludes **"Path A is impossible"**
- The reason: any theorem psi is automatically in M (MCS closure), so neg(psi) not-in M
- There is NO formula psi where both "derives psi" and "neg(psi) in M"
- The contradiction REQUIRES comparing M with a DIFFERENT MCS M' (the naming set approach)

**Why linearity doesn't provide the needed contradiction**:
- The linearity axiom `temp_linearity` governs ordering between F-witnesses
- Steps 5-7 of the proof sketch (infinite regress via linearity) are not rigorously specified
- The DirectIrreflexivity.lean systematic search found no usable contradiction

**Why seriality fallback also fails**:
- Moving seriality (`G(phi) -> F(phi)`, `H(phi) -> P(phi)`) to base doesn't help
- Seriality gives `P(neg p) in M'` from `H(neg p) in M'`
- But `P(neg p)` means "neg p at some past time", NOT "neg p now"
- Still cannot derive `neg p in M'`

**Fundamental Issue**:
Under strict semantics, irreflexivity is **not derivable from the base axioms**. This is a known result:
irreflexivity is NOT modally definable (no modal formula characterizes it). The Gabbay IRR rule was invented precisely for this.

**Options to Resolve**:
1. **Keep the T-axiom** (revert to reflexive semantics) - contradicts Task 991 goal
2. **Use IRR rule explicitly** - requires atom freshness which has implementation issues with String atoms
3. **Accept irreflexivity as axiomatic** - change `canonicalR_irreflexive` to an axiom, not a theorem
4. **Product frame/bulldozing** - semantic post-processing to enforce irreflexivity

**Recommendation**: Option 3 (axiom) is simplest. The irreflexivity is semantically correct under strict semantics; we just cannot derive it syntactically without additional apparatus.

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

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Remove reflexive branches
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` - Check for T-axiom usage

**Verification**:
- Truth lemma proof is shorter (fewer cases)
- No T-axiom references in canonical model construction

---

### Phase 6: Staged Construction and Cantor Prerequisites [NOT STARTED]

**Goal**: Remove reflexive case splits from staged construction, update Cantor prerequisites.

**Tasks**:
- [ ] In CantorPrereqs.lean:111, fix `derive_F_to_FF` (derive Fphi->FFphi from GGphi->Gphi)
- [ ] In CanonicalTimeline.lean:183, fix `density_of_canonicalR` (same derivation)
- [ ] In DenseTimeline.lean, remove reflexive branch from densityIntermediateMCS
- [ ] Delete `density_frame_condition_reflexive_source` branch entirely
- [ ] In DensityFrameCondition.lean, verify strict intermediates (W != M and W != M')
- [ ] In CantorApplication.lean, remove axiom dependencies from DenselyOrdered instance
- [ ] Remove canonicalR_irreflexive invocations where strictness is now automatic
- [ ] Update NoMaxOrder/NoMinOrder instances similarly

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` - Fix F->FF derivation
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalTimeline.lean` - Fix density derivation
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` - Remove case split
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - Verify strictness
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - Remove axiom deps

**Verification**:
- Single code path for density intermediate construction
- Cantor isomorphism proof has fewer dependencies
- `derive_F_to_FF` uses correct derivation from GGphi->Gphi

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
- [ ] P1 (box p -> always p): verify decomposition still works without modal T
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

### Phase 9: Decidability and Final Cleanup [NOT STARTED]

**Goal**: Update decidability modules, remove all cruft, verify clean build.

**Tasks**:
- [ ] In Decidability/ directory, check for T-axiom usage
- [ ] Update Tableau.lean axiom cases for new axiom system
- [ ] In Automation/Tactics.lean, remove hardcoded temp_t references
- [ ] Grep for any remaining temp_t_future/temp_t_past references
- [ ] Grep for any remaining reflexive `<=` in temporal quantification
- [ ] Remove any orphaned helper lemmas or bridge definitions
- [ ] Run `lake build` and fix any remaining errors
- [ ] Verify no sorry remains in production code

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/*.lean` - Update axiom cases
- `Theories/Bimodal/Automation/Tactics.lean` - Remove T-axiom references
- Various cleanup across touched files

**Verification**:
- `lake build` succeeds with no errors
- `grep -r "temp_t_future\|temp_t_past" Theories/` returns nothing
- No sorry in Theories/Bimodal/ (excluding Boneyard and Examples)

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No temp_t_future or temp_t_past references remain
- [ ] IRR proof is under 100 lines using temp_a + linearity
- [ ] Truth lemma has no reflexive case branches
- [ ] Cantor prerequisites have no axiom dependencies on reflexivity
- [ ] All perpetuity principles compile without sorry
- [ ] Extension lattice structure matches research findings (Kt.Lin.Ser base)

## Artifacts & Outputs

- plans/01_irreflexive-semantics-refactoring.md (original plan, blocked)
- plans/02_revised-irreflexive-semantics.md (this file)
- summaries/01_irreflexive-semantics-summary.md (after implementation)
- ~1200 lines deleted from CanonicalIrreflexivity
- ~50-100 lines of new temp_a + linearity IRR proof
- Net reduction of ~1100 lines of proof code

## Rollback/Contingency

### If temp_a + linearity proof fails
1. Fall back to seriality-in-base approach:
   - Move `seriality_future` and `seriality_past` to Base axioms
   - Add NoMaxOrder/NoMinOrder as frame conditions
   - Use seriality-based irreflexivity proof (~30 lines)
2. This changes the logic slightly (base now requires unbounded frames)
3. Document the architectural decision

### If refactoring encounters other insurmountable obstacles
1. Git reset to pre-phase-4 commit (phases 1-3 complete)
2. Preserve research findings for future attempts
3. Consider incremental approach: keep both reflexive and strict modules
