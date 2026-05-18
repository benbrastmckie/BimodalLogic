# Implementation Plan: Task #163

- **Task**: 163 - rename_representation_to_completeness
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/163_rename_representation_to_completeness/reports/01_team-research.md
- **Artifacts**: plans/01_rename-recover-ultrafilter.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task has two independent parts: (A) rename misnamed "representation" theorems to "completeness" across the Algebraic module (7 theorem renames, 2 file renames, 4 call site updates, docstring/comment updates), and (B) recover ultrafilter frame infrastructure from the Boneyard (~lines 56-1519 of UltrafilterChain.lean) into a new `Algebraic/UltrafilterFrame.lean`, generalizing definitions from concrete `LindenbaumAlg` to abstract `[STSA alpha]` where STSA axioms suffice. Part A is mechanical. Part B requires careful import surgery, generalization analysis, and sorry annotation preservation.

### Research Integration

Key findings from team research (4 teammates):
- All current "representation" theorems are unambiguously completeness theorems (contrapositive Henkin: not provable implies countermodel exists)
- Phase 1 of UltrafilterChain.lean (lines 56-1519) defines R_G, R_H, R_Box with key properties; Phase 2 (line 1520+) contains box-class BFMCS construction that stays in Boneyard
- Phase 1 has exactly 2 code-level sorries (both for `temp_4` removed in BX, at lines 103 and 509)
- Generalization from `LindenbaumAlg` to `[STSA alpha]` is possible for R_G, R_H, R_Box definitions and properties that only use STSA typeclass methods (box_deflationary, box_s5, G_monotone, sigma_G/H, TA, etc.)
- Properties using formula-level constructions (ultrafilter_F_resolution, UltrafilterChain_to_FMCS) must remain LindenbaumAlg-specific

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances Roadmap Phase 4 (Algebraic representation):
- The rename (Part A) corrects naming confusion between completeness and representation
- The ultrafilter frame recovery (Part B) provides the seed infrastructure for the Jonsson-Tarski representation theorem (task 125)
- R_G, R_H, R_Box on ultrafilters are exactly the canonical relations needed for the ultrafilter frame `A_+`

## Goals & Non-Goals

**Goals**:
- Rename all 7 "representation" theorems to "completeness" with consistent naming
- Rename AlgebraicRepresentation.lean to AlgebraicCompleteness.lean
- Rename ParametricRepresentation.lean to ParametricCompleteness.lean
- Update all call sites (4 in active code) to use new names
- Update the Algebraic.lean module root to reference new filenames
- Recover Phase 1 infrastructure from Boneyard UltrafilterChain.lean into new UltrafilterFrame.lean
- Generalize R_G, R_H, R_Box definitions to abstract `[STSA alpha]`
- Preserve all 2 sorry annotations with clear comments about their source (temp_4 removed in BX)
- Ensure `lake build` succeeds after all changes

**Non-Goals**:
- Restructure Algebraic/ into subdirectories (deferred to task 125)
- Resolve the 2 temp_4 sorries (requires BX derivation work)
- Recover Phase 2 of UltrafilterChain.lean (box-class BFMCS construction)
- Add Since/Until operators to STSA typeclass
- Implement the actual representation theorem (task 125)
- Modify Boneyard files (read-only source for recovery)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missed call sites in Boneyard code | L | M | Boneyard call sites use old names but are dead code; only update active code paths |
| Import cycle from new UltrafilterFrame.lean | H | L | Place imports carefully; the file only needs TenseS5Algebra, UltrafilterMCS, and Mathlib |
| Generalization breaks proofs that implicitly rely on LindenbaumAlg structure | M | M | Keep LindenbaumAlg-specific instances as corollaries; only generalize where STSA axioms suffice |
| temp_4 sorries propagate to dependent theorems | L | H | Annotate clearly; these are known engineering debt from BX axiom restructuring |
| Build failures from namespace changes | M | M | Test incrementally: do renames first, then recovery |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 1, 2, 3, 4 |

### Phase 1: Rename Theorem Definitions and File Names [COMPLETED]

**Goal**: Rename the 7 theorem definitions and 2 source files, updating namespaces and module docstrings.

**Tasks**:
- [x] Rename `AlgebraicRepresentation.lean` to `AlgebraicCompleteness.lean`
- [x] Update namespace from `AlgebraicRepresentation` to `AlgebraicCompleteness` in the file
- [x] Rename `algebraic_representation_theorem` to `algebraic_completeness_theorem`
- [x] Rename `algebraic_representation_theorem'` to `algebraic_completeness_theorem'`
- [x] Update the internal reference (`algebraic_representation_theorem phi` at line 189)
- [x] Update docstrings/comments in AlgebraicCompleteness.lean to say "completeness" not "representation"
- [x] Rename `ParametricRepresentation.lean` to `ParametricCompleteness.lean`
- [x] Update namespace from `ParametricRepresentation` to `ParametricCompleteness`
- [x] Rename `parametric_algebraic_representation_relative` to `parametric_canonical_completeness_relative`
- [x] Rename `parametric_representation_from_neg_membership` to `parametric_completeness_from_neg_membership`
- [x] Rename `parametric_algebraic_representation_conditional` to `parametric_canonical_completeness_conditional`
- [x] Update internal reference at line 269 (`parametric_representation_from_neg_membership`)
- [x] Update module docstrings in ParametricCompleteness.lean

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - rename to `AlgebraicCompleteness.lean`, update namespace and theorem names
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - rename to `ParametricCompleteness.lean`, update namespace and theorem names

**Verification**:
- Both files compile without errors after namespace and theorem name changes
- `grep -r "representation" Theories/Bimodal/Metalogic/Algebraic/` returns only the new file (no stale references in active code)

---

### Phase 2: Rename Restricted Representation Theorems [COMPLETED]

**Goal**: Rename the 2 restricted representation theorems in RestrictedParametricTruthLemma.lean.

**Tasks**:
- [x] Rename `restricted_parametric_representation_from_neg_membership` to `restricted_parametric_completeness_from_neg_membership`
- [x] Rename `fully_restricted_parametric_representation_from_neg_membership` to `fully_restricted_parametric_completeness_from_neg_membership`
- [x] Update docstrings/comments referencing "representation" in that file

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` - rename 2 theorems and update comments

**Verification**:
- File compiles without errors
- `grep -n "representation" RestrictedParametricTruthLemma.lean` returns no hits

---

### Phase 3: Update Call Sites and Module Root [COMPLETED]

**Goal**: Update all call sites referencing old theorem names, and update the Algebraic.lean module root to import the renamed files.

**Tasks**:
- [x] Update `Algebraic.lean` line 5: change `import ...AlgebraicRepresentation` to `import ...AlgebraicCompleteness`
- [x] Update `Algebraic.lean` line 11: change `import ...ParametricRepresentation` to `import ...ParametricCompleteness`
- [x] Update `Algebraic.lean` open statements (lines 89, 96) to use new namespace names
- [x] Update `Algebraic.lean` module docstring to say "Algebraic Completeness Theorem" instead of "Algebraic Representation Theorem"
- [x] Update `Algebraic.lean` architecture diagram comments to reflect new filenames
- [x] Update `RootScopedChain.lean` line 220: `fully_restricted_parametric_representation_from_neg_membership` to `fully_restricted_parametric_completeness_from_neg_membership`
- [x] Update `ChronicleToCountermodel.lean` line 812: same rename
- [x] Update `ChronicleToCountermodel.lean` line 3307: same rename
- [x] Run `lake build` and verify zero errors in active code

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - update imports, opens, and docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - update call site at line 220
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - update call sites at lines 812 and 3307

**Verification**:
- `lake build` succeeds with no errors in active modules
- `grep -rn "representation" Theories/Bimodal/Metalogic/Algebraic/ Theories/Bimodal/Metalogic/BXCanonical/` shows no stale references (except Boneyard paths in comments)

---

### Phase 4: Recover UltrafilterFrame.lean from Boneyard [NOT STARTED]

**Goal**: Create `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` by recovering Phase 1 (lines 56-1519) of the Boneyard UltrafilterChain.lean, generalizing definitions from `LindenbaumAlg` to abstract `[STSA alpha]` where possible.

**Tasks**:
- [ ] Create new file `UltrafilterFrame.lean` with appropriate module header and imports
- [ ] Import only active modules: `TenseS5Algebra`, `UltrafilterMCS`, and needed Mathlib (no Boneyard imports)
- [ ] Define generalized `R_G`, `R_H`, `R_Box` over `Ultrafilter alpha` for `[STSA alpha]`
- [ ] Prove `R_Box_refl`, `R_Box_euclidean`, `R_Box_symm`, `R_Box_trans` generically (these only use `box_deflationary`, `box_s5`, `box_idempotent`)
- [ ] Prove `R_G_R_H_converse` generically (uses `TA`, `sigma_G`, `sigma_H`, `sigma_involution`, `sigma_neg`, `sigma_sup`)
- [ ] Keep `R_G_trans` and `R_H_trans` as LindenbaumAlg-specific with sorry annotations (require temp_4/temp_4_past which need derivation trees)
- [ ] Recover `G_preimage`, `H_preimage` definitions and properties (generalizable: only use `G_monotone`, `H_monotone`, and temp_k_dist logic)
- [ ] Recover `G_preimage_top`, `G_preimage_upward`, `G_preimage_inf` with generalization where possible
- [ ] Recover `H_preimage_top`, `H_preimage_upward`, `H_preimage_inf` symmetrically
- [ ] Recover `ultrafilter_F_resolution` and `ultrafilter_P_resolution` as LindenbaumAlg-specific (use formula-level Zorn argument)
- [ ] Recover `UltrafilterChain` structure and its theorems (forward_G, backward_H, shift, etc.) as LindenbaumAlg-specific
- [ ] Recover `UltrafilterChain_to_FMCS` conversion
- [ ] Preserve all 2 sorry annotations with clear comments: `sorry /- temp_4: Gp -> GGp, derivable from BX1+K but removed during axiom cleanup -/`
- [ ] Add module docstring explaining provenance from Boneyard and relationship to task 125

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` - new file (recovered + generalized)

**Verification**:
- File compiles successfully (sorries accepted, no type errors)
- Generalized definitions type-check with `variable [STSA alpha]`
- LindenbaumAlg-specific instances compile
- No imports from Boneyard modules

---

### Phase 5: Integration and Build Verification [NOT STARTED]

**Goal**: Register the new UltrafilterFrame.lean in the module root, run full build, and clean up.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.Algebraic.UltrafilterFrame` to `Algebraic.lean`
- [ ] Add `open Bimodal.Metalogic.Algebraic.UltrafilterFrame` to the module root
- [ ] Update the architecture diagram comment in `Algebraic.lean` to include UltrafilterFrame.lean
- [ ] Run `lake build` for full project build
- [ ] Verify no regressions (build should complete with same sorry count as before)
- [ ] Verify sorry count: the new file adds 2 sorries (temp_4) which were already counted in Boneyard; net active sorry count changes by +2 relative to pre-task state

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - add import and open for UltrafilterFrame

**Verification**:
- `lake build` succeeds with no new errors
- `grep -rn "sorry" Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` shows exactly 2 sorries (both temp_4)
- `grep -rn "import.*Boneyard" Theories/Bimodal/Metalogic/Algebraic/` returns no hits

## Testing & Validation

- [ ] `lake build` succeeds after all phases
- [ ] No references to old theorem names remain in active code (`grep -rn "algebraic_representation_theorem\|parametric_representation_from_neg\|parametric_algebraic_representation" Theories/Bimodal/Metalogic/` returns only Boneyard hits)
- [ ] New UltrafilterFrame.lean compiles without errors (2 known sorries)
- [ ] All 4 call sites in active code use the new completeness theorem names
- [ ] Module root `Algebraic.lean` correctly imports both renamed files and new UltrafilterFrame
- [ ] Generalized definitions (`R_Box_refl`, `R_Box_symm`, etc.) work for any `[STSA alpha]`, not just LindenbaumAlg

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` - renamed from AlgebraicRepresentation.lean
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean` - renamed from ParametricRepresentation.lean
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` - new file recovered from Boneyard
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` - updated module root

## Rollback/Contingency

If implementation fails:
- Part A (rename) is fully reversible via `git checkout` on the affected files
- Part B (recovery) can be abandoned without affecting existing functionality since UltrafilterFrame.lean is a new file with no dependents
- If generalization proves too complex for certain properties, keep them LindenbaumAlg-specific (same as Boneyard original) and annotate with TODO for future generalization
- If build fails due to import issues with UltrafilterFrame.lean, the file can be excluded from the module root (comment out the import) while debugging
