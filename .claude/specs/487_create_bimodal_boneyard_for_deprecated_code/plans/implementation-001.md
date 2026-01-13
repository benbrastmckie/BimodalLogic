# Implementation Plan: Task #487

- **Task**: 487 - Create Bimodal/Boneyard/ for deprecated code
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/487_create_bimodal_boneyard_for_deprecated_code/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Create a Boneyard directory structure under Theories/Bimodal/ to preserve deprecated completeness code while cleaning up the main files. The research identified approximately 1,700 lines of deprecated code across two files: the syntactic approach in FiniteCanonicalModel.lean (~900 lines) and the infinite Duration-based construction in Completeness.lean (~785 lines). Both have been superseded by the semantic approach using SemanticWorldState.

### Research Integration

Key findings from research-001.md:
- Syntactic approach (FiniteWorldState, finite_truth_lemma) has 6+ sorry gaps due to negation-completeness requirements
- Duration construction (PositiveDuration, Duration types) has multiple sorry gaps in algebraic properties
- Both approaches were superseded by SemanticWorldState in Task 473
- Clear file boundaries identified for extraction

## Goals & Non-Goals

**Goals**:
- Create Boneyard directory with proper structure and README
- Extract syntactic approach code from FiniteCanonicalModel.lean
- Extract Duration construction code from Completeness.lean
- Preserve all deprecated code for historical reference
- Ensure lake build succeeds after refactoring
- Document deprecation reasons clearly

**Non-Goals**:
- Completing the deprecated proofs (they have fundamental design issues)
- Removing all sorries from the extracted code
- Modifying the active semantic approach code
- Changing any external imports

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports after code extraction | Build failure | Medium | Test lake build after each file move |
| Incomplete extraction leaving orphan references | Compiler errors | Medium | Grep for references before/after extraction |
| Losing git history for moved code | Reduced traceability | Low | Use git mv or add history notes in README |
| Boneyard files importing unavailable dependencies | Build failure | Low | Verify imports at extraction time |

## Implementation Phases

### Phase 1: Create Boneyard Directory Structure [NOT STARTED]

**Goal**: Establish the Boneyard directory with README documentation

**Tasks**:
- [ ] Create Theories/Bimodal/Boneyard/ directory
- [ ] Create README.md documenting deprecation reasons and code history
- [ ] Document the two deprecated approaches (syntactic and Duration-based)
- [ ] Note the replacement approach (SemanticWorldState)

**Timing**: 30 minutes

**Files to create**:
- `Theories/Bimodal/Boneyard/README.md` - Deprecation documentation

**Verification**:
- Directory exists with proper structure
- README clearly explains why code was deprecated

---

### Phase 2: Extract Syntactic Approach Code [NOT STARTED]

**Goal**: Move deprecated syntactic approach from FiniteCanonicalModel.lean to Boneyard

**Tasks**:
- [ ] Create Boneyard/SyntacticApproach.lean with proper module header
- [ ] Add necessary imports (Formula, Semantics, ProofSystem, etc.)
- [ ] Extract IsLocallyConsistent definition and related lemmas
- [ ] Extract FiniteWorldState structure and related code
- [ ] Extract FiniteTaskRel namespace
- [ ] Extract finite_truth_lemma and finite_weak_completeness
- [ ] Remove extracted code from FiniteCanonicalModel.lean
- [ ] Verify lake build succeeds

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Remove deprecated sections
- `Theories/Bimodal/Boneyard/SyntacticApproach.lean` - New file with extracted code

**Verification**:
- Boneyard/SyntacticApproach.lean compiles (may have sorries)
- FiniteCanonicalModel.lean compiles without the deprecated code
- No orphan references in FiniteCanonicalModel.lean

---

### Phase 3: Extract Duration Construction Code [NOT STARTED]

**Goal**: Move deprecated Duration-based code from Completeness.lean to Boneyard

**Tasks**:
- [ ] Create Boneyard/DurationConstruction.lean with proper module header
- [ ] Add necessary imports (Mathlib order theory, Grothendieck groups)
- [ ] Extract TemporalChain and ChainSegment structures
- [ ] Extract PositiveDuration type and AddCommMonoid instance
- [ ] Extract Duration type and LinearOrder instance
- [ ] Extract canonical_task_rel and related transfer conditions
- [ ] Remove extracted code from Completeness.lean
- [ ] Verify lake build succeeds

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Remove deprecated sections
- `Theories/Bimodal/Boneyard/DurationConstruction.lean` - New file with extracted code

**Verification**:
- Boneyard/DurationConstruction.lean compiles (may have sorries)
- Completeness.lean compiles without the deprecated code
- No orphan references in Completeness.lean

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Ensure all files build and documentation is complete

**Tasks**:
- [ ] Run lake build to verify full project compiles
- [ ] Check for any remaining references to deprecated code in main files
- [ ] Update lakefile.lean if Boneyard should be excluded from default build (optional)
- [ ] Verify README documentation is complete and accurate
- [ ] Check that SemanticWorldState approach is unaffected

**Timing**: 30 minutes

**Files to review**:
- `lakefile.lean` - May need exclusion of Boneyard
- All files in Theories/Bimodal/Metalogic/

**Verification**:
- `lake build` succeeds
- No compiler warnings about deprecated code
- Boneyard files exist and are properly documented

---

## Testing & Validation

- [ ] `lake build` succeeds for main project
- [ ] FiniteCanonicalModel.lean compiles without deprecated sections
- [ ] Completeness.lean compiles without deprecated sections
- [ ] Boneyard files compile (sorries are acceptable)
- [ ] No references to deprecated code remain in main files
- [ ] README.md accurately documents deprecation history

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/README.md` - Deprecation documentation
- `Theories/Bimodal/Boneyard/SyntacticApproach.lean` - Extracted syntactic approach code
- `Theories/Bimodal/Boneyard/DurationConstruction.lean` - Extracted Duration construction code
- `.claude/specs/487_create_bimodal_boneyard_for_deprecated_code/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Restore FiniteCanonicalModel.lean from git (code not deleted until verified)
2. Restore Completeness.lean from git
3. Delete Boneyard directory
4. Run `lake build` to confirm rollback successful

The extraction will be done incrementally with build verification after each phase, minimizing rollback scope if issues arise.
