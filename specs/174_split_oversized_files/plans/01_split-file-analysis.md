# Implementation Plan: Split Oversized Lean Files (v2 -- Direct Imports)

- **Task**: 174 - Split Oversized Lean Files
- **Status**: [NOT STARTED]
- **Effort**: 46 hours
- **Dependencies**: None (task 155 paused; ExpressivenessGeneral.lean should be split last to minimize conflict)
- **Research Inputs**: reports/01_split-file-analysis.md
- **Artifacts**: plans/01_split-file-analysis.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Split 12 Lean files exceeding ~1500 lines into 35 focused modules with principled mathematical decomposition. Each module is named for its mathematical identity, not line ranges. Unlike v1 (which used aggregator re-export files), this plan uses **direct imports** (Mathlib convention): the original file is deleted after splitting, and every downstream importer is updated to import the specific split module it needs. The definition of done is: all 12 files split per proposals below, every new file has a module docstring, every former importer uses direct imports to specific split modules, no aggregator files exist, and `lake build` passes after each split.

### Research Integration

The research report (reports/01_split-file-analysis.md) provided per-file split proposals with line ranges, internal dependency maps, and importer counts. Key findings integrated in v1. This v2 revision incorporates:
- Direct import migration replacing the aggregator pattern (Mathlib convention)
- Principled mathematical decomposition with concept-based module names
- Revised wave structure accounting for import migration effort on high-fan-out files
- Refined split boundaries for EFGames (6 modules) and ExpressivenessGeneral (5 modules)

### Prior Plan Reference

v1 plan used aggregator files for backward compatibility. This v2 replaces the aggregator approach entirely with direct imports and updates module decompositions to reflect mathematical structure.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Split all 12 target files so no single file exceeds ~1500 lines (except GapDetection at ~5040 lines, which keeps Lemma 9 both directions together as an indivisible unit)
- Each new file is named for its mathematical identity and has a module docstring
- Use direct imports only -- no aggregator files (Mathlib convention)
- Update all downstream importers to point at the specific split module(s) they need
- Delete the original oversized file after each split
- Pass `lake build` after each individual split
- Reduce incremental build times by enabling parallel compilation of split pieces

**Non-Goals**:
- Refactoring proof content or improving proof style
- Changing any theorem statements or definitions
- Optimizing import graphs beyond the immediate split (can be a follow-up task)
- Splitting files below the 1500-line threshold (Soundness.lean at 1355, NEquivalence.lean at 1227, etc.)
- Updating task 155 branch (will be handled separately when task 155 resumes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `private` definitions become cross-file after split | H | H | Map all private def usages before splitting; convert necessary privates to `protected` |
| Direct import migration misses a consumer | H | M | Use `grep -rl` to find ALL importers, build after each import update; `lake build` catches any miss |
| EFGames.lean internal dependencies more tangled than analyzed | H | M | Build after each file move; keep GapDetection as one ~5040-line file (both Lemma 9 directions) |
| Propositional.lean split requires updating 19 downstream importers | H | L | Systematic grep-based migration; most importers use the same subset (Core) |
| ExpressivenessGeneral.lean conflict with paused task 155 | M | M | Split ExpressivenessGeneral last; document split boundaries for task 155 rebase |
| `open` scope issues after file split | M | H | Audit `open` declarations per split file; add necessary `open` to each new file |
| Build timeout during verification of large splits | M | L | Build incrementally (one file move at a time); use `lake build` not full rebuild |
| SplitPoint.lean remains ~4640 lines | L | H | Accept as single cohesive unit (obtain_split_point_props); flag for future decomposition |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6, 7 | 1, 2, 3, 4 |
| 3 | 8 | 6 |
| 4 | 9, 10 | 1, 2, 3, 4 |
| 5 | 11, 12 | 8, 9, 10 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Split ExpressiveCompleteness.lean (0 importers) [COMPLETED]

**Goal**: Split ExpressiveCompleteness.lean (2129 lines, 0 downstream importers) into 2 focused modules. Zero import impact -- safest first split.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in ExpressiveCompleteness.lean
- [x] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/`
- [x] Create `ExpressiveCompleteness/QuantifierElimination.lean` (~1600 lines): FO-to-temporal translation infrastructure, purity semantic lemmas, substitution under purity, extended signature, quantifier elimination, atom elimination infrastructure, QE correctness, atom membership, guard formulas. Module docstring: "Quantifier elimination and atom elimination for the FO-to-temporal translation." *(deviation: altered -- 5 private defs made public instead of protected, needed for cross-file access from Theorem.lean)*
- [x] Create `ExpressiveCompleteness/Theorem.lean` (~530 lines): Core expressiveness lemma, final Theorem 10.2.10 linking FO-definability to temporal definability. Module docstring: "Expressive completeness theorem (Theorem 10.2.10): every FO-definable property is temporal."
- [x] Add module docstrings to both new files
- [x] Delete `ExpressiveCompleteness.lean` (no importers to update)
- [x] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: none

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/QuantifierElimination.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/Theorem.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean`

**Verification**:
- `lake build` passes
- Both new files have module docstrings
- No aggregator file exists

---

### Phase 2: Split Tactics.lean (1 importer) [COMPLETED]

**Goal**: Split Tactics.lean (1342 lines) into 2 focused modules. Only `Automation.lean` imports it.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in Tactics.lean *(no private defs found)*
- [x] Create directory `Theories/Bimodal/Automation/Tactics/`
- [x] Create `Tactics/Helpers.lean` (921 lines): Basic macros, assumption_search, formula helpers, tactic factory, inference rule tactics, axiom tactics, core search implementation. *(deviation: used sed extraction from original — preserves original docstring instead of plan-specified docstring)*
- [x] Create `Tactics/Commands.lean` (431 lines): SearchConfig, main tactic definitions, tests. *(deviation: same — original section header preserved as docstring)*
- [x] Add module docstrings to both new files *(original file headers preserved)*
- [x] Update `Theories/Bimodal/Automation.lean`: `import Bimodal.Automation.Tactics.Commands` *(also updated 3 test files: TacticsTest.lean, TacticsTest_Simple.lean, EdgeCaseTest.lean)*
- [x] Delete `Theories/Bimodal/Automation/Tactics.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 1.5 hours

**Depends on**: none

**Files created**:
- `Theories/Bimodal/Automation/Tactics/Helpers.lean`
- `Theories/Bimodal/Automation/Tactics/Commands.lean`

**Files deleted**:
- `Theories/Bimodal/Automation/Tactics.lean`

**Import migration** (1 file):
- `Theories/Bimodal/Automation.lean`: `import Bimodal.Automation.Tactics` -> `import Bimodal.Automation.Tactics.Commands`

**Verification**:
- `lake build` passes
- `Automation.lean` uses direct import to `Tactics.Commands`

---

### Phase 3: Split ProofSearch.lean (2 importers) [COMPLETED]

**Goal**: Split ProofSearch.lean (1388 lines) into 2 focused modules.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in ProofSearch.lean *(no private defs needed conversion)*
- [x] Create directory `Theories/Bimodal/Automation/ProofSearch/`
- [x] Create `ProofSearch/Core.lean` (1018 lines): Types, helpers, heuristics, bounded search, matchDerived, bounded_search_with_proof, iddfs_search. *(sed extraction — original docstring preserved)*
- [x] Create `ProofSearch/Strategies.lean` (379 lines): Best-first search, strategy configuration, learning-enabled search, batch search. *(sed extraction — original section header preserved)*
- [x] Add module docstrings to both new files *(original file headers preserved)*
- [x] Map importers: found 7 total (Automation.lean, Closure.lean, DecisionProcedure.lean + 4 test files)
- [x] Update `Theories/Bimodal/Automation.lean`: imports both Core + Strategies
- [x] Update `Theories/Bimodal/Metalogic/Decidability/Closure.lean`: imports Core *(also updated DecisionProcedure.lean, ProofSearchBenchmark.lean, ProofSearchTest.lean, EdgeCaseTest.lean, TacticsTest.lean)*
- [x] Delete `Theories/Bimodal/Automation/ProofSearch.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: none

**Files created**:
- `Theories/Bimodal/Automation/ProofSearch/Core.lean`
- `Theories/Bimodal/Automation/ProofSearch/Strategies.lean`

**Files deleted**:
- `Theories/Bimodal/Automation/ProofSearch.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Automation.lean`: `import Bimodal.Automation.ProofSearch` -> direct import(s)
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean`: `import Bimodal.Automation.ProofSearch` -> direct import(s)

**Verification**:
- `lake build` passes
- Both importers use direct imports

---

### Phase 4: Split RestrictedMCS.lean (2 importers) [COMPLETED]

**Goal**: Split RestrictedMCS.lean (1407 lines) into 2 focused modules at the boundary between closure-restricted and deferral-restricted MCS.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in RestrictedMCS.lean *(no private defs needed conversion)*
- [x] Create directory `Theories/Bimodal/Metalogic/Core/RestrictedMCS/`
- [x] Create `RestrictedMCS/Basic.lean` (653 lines): ClosureRestricted, RestrictedConsistent, RestrictedMCS definitions, basic properties, negation completeness, Lindenbaum, constructing MCS from formula, iter_F/P boundedness. *(sed extraction — original docstring preserved)*
- [x] Create `RestrictedMCS/Deferral.lean` (763 lines): DeferralRestrictedConsistent, DeferralRestrictedMCS definitions, negation completeness, iter_F/P boundedness, closure under derivation, implication property, theorem_in_drm, G_neg lemma. *(sed extraction — original section header preserved)*
- [x] Add module docstrings to both new files *(original file headers preserved)*
- [x] Map importers: found 9 total (Core.lean, ClosureMCS.lean + 6 Boneyard files + Deferral cross-import)
- [x] Update `Theories/Bimodal/Metalogic/Core/Core.lean`: imports both Basic + Deferral
- [x] Update `Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean`: imports Basic *(also updated 6 Boneyard files to import Deferral)*
- [x] Delete `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: none

**Files created**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean`
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Metalogic/Core/Core.lean`: `import Bimodal.Metalogic.Core.RestrictedMCS` -> direct import(s)
- `Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean`: `import Bimodal.Metalogic.Core.RestrictedMCS` -> direct import(s)

**Verification**:
- `lake build` passes
- Both importers use direct imports

---

### Phase 5: Split SoundnessLemmas.lean (2 active importers) [COMPLETED]

**Goal**: Split SoundnessLemmas.lean (2407 lines) into 3 focused modules aligned with frame-class boundaries.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in SoundnessLemmas.lean
- [x] Create directory `Theories/Bimodal/Metalogic/SoundnessLemmas/`
- [x] Create `SoundnessLemmas/Core.lean` (106 lines): `is_valid` definition, `truth_at_swap_swap`, core infrastructure. Module docstring: "Core Validity Definitions and Swap Infrastructure for Soundness Proofs"
- [x] Create `SoundnessLemmas/DenseValidity.lean` (1338 lines): Swap validity, local validity, combined soundness theorems for the dense frame class. Module docstring: "Axiom and Rule Validity for the Dense Frame Class"
- [x] Create `SoundnessLemmas/FrameClassVariants.lean` (971 lines): General (Base) and discrete frame class validity variants. Module docstring: "Soundness Lemmas for General and Discrete Frame Classes"
- [x] Add module docstrings to all three new files
- [x] Map importers: `Metalogic.lean` and `Soundness.lean` (2 importers as planned)
- [x] Update `Theories/Bimodal/Metalogic.lean`: imports all three modules (Core, DenseValidity, FrameClassVariants)
- [x] Update `Theories/Bimodal/Metalogic/Soundness.lean`: imports FrameClassVariants
- [x] Delete `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 2.5 hours

**Depends on**: 1, 2, 3, 4

**Files created**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas/Core.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas/DenseValidity.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas/FrameClassVariants.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Metalogic.lean`: `import Bimodal.Metalogic.SoundnessLemmas` -> direct import(s)
- `Theories/Bimodal/Metalogic/Soundness.lean`: `import Bimodal.Metalogic.SoundnessLemmas` -> direct import(s)

**Verification**:
- `lake build` passes
- Metalogic.lean and Soundness.lean use direct imports

---

### Phase 6: Split DedekindZ.lean (2 importers) [COMPLETED]

**Goal**: Split DedekindZ.lean (2236 lines) into 2 focused modules within the existing `Separation/DedekindZ/` directory path.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in DedekindZ.lean
- [x] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/`
- [x] Create `DedekindZ/QLemma.lean` (459 lines): K+/K- definitions, Q-lemma, Q_Z syntactic properties. Module docstring: "K+/K- Operators and Q-Lemma for Dedekind-Complete Integer Orders"
- [x] Create `DedekindZ/Cases.lean` (1768 lines): Replace-U infrastructure, congruence lemmas, Cases 5-8 separability proofs. Module docstring: "Cases 5-8 Separability on Z via Replacement and Direct-Formula Construction"
- [x] Add module docstrings to both new files
- [x] Map importers: `Hierarchy.lean` and `NormalForm.lean` (2 importers as planned)
- [x] Update `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`: imports Cases
- [x] Update `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`: imports Cases
- [x] Delete `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 2.5 hours

**Depends on**: 1, 2, 3, 4

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/QLemma.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/Cases.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean`: direct import(s)

**Verification**:
- `lake build` passes
- Hierarchy.lean and NormalForm.lean use direct imports

---

### Phase 7: Split IntegerModel.lean (2 importers) [COMPLETED]

**Goal**: Split IntegerModel.lean (1816 lines) into 2 focused modules at the good/very-good boundary.

**Tasks**:
- [x] Audit `private` definitions and `open` scopes in IntegerModel.lean
- [x] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/`
- [x] Create `IntegerModel/GoodStructures.lean` (909 lines): Z-interval structures, good structures, succ-iteration, transitivity helpers, contemporaneous equivalence, one-class theorem. Module docstring: "Good Z-Interval Structures: Foundations, Succ-Iteration, and the One-Class Theorem"
- [x] Create `IntegerModel/ShiftAndGlue.lean` (904 lines): Very-good→good, half-open partition, shift-and-glue helpers, chronicle-is-good. Module docstring: "Shift-and-Glue Construction: Very-Good to Good via Reynolds Lemma 16"
- [x] Add module docstrings to both new files
- [x] Map importers: `Transfer.lean` and `WeakCanonical.lean` (2 importers as planned)
- [x] Update `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`: imports GoodStructures
- [x] Update `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`: imports GoodStructures + ShiftAndGlue
- [x] Delete `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- [x] Run `lake build` and verify no errors

**Timing**: 2.5 hours

**Depends on**: 1, 2, 3, 4

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`: direct import(s)

**Verification**:
- `lake build` passes
- Transfer.lean and WeakCanonical.lean use direct imports

---

### Phase 8: Split Hierarchy.lean (2 importers, 3-file split) [NOT STARTED]

**Goal**: Split Hierarchy.lean (3845 lines) into 3 focused modules aligned with the GHR94 separation hierarchy stages.

**Tasks**:
- [ ] Audit `private` definitions, `open` scopes, and internal theorem dependencies in Hierarchy.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/`
- [ ] Create `Hierarchy/HierarchyDefs.lean` (~820 lines): Single U/S-type predicates, Lemma 10.2.5 (single-U separability), U/S-formula abstraction, semantic correctness, preservation lemmas, count properties, junction-depth monotonicity. Module docstring: "Separation hierarchy definitions: U/S-type predicates, abstraction, and junction-depth monotonicity."
- [ ] Create `Hierarchy/HierarchyInduction.lean` (~1600 lines): Hierarchy theorem steps 1-5b: substitution preservation, strict count decrease, count_U_total lemmas, substitution into separated formulas, S/U-nesting depth measures, callback infrastructure. Module docstring: "Substitution-based induction engine for the separation hierarchy (Steps 1-5b)."
- [ ] Create `Hierarchy/HierarchyCompletion.lean` (~1600 lines): Steps 5c-5d and JD infrastructure: U-type-preserving separation, separable_with_U_type strengthening, combinators, Cases 5-8 with U-type preservation, single-U-type separability (axiom-free), GHR94 Lemma 10.2.6/10.2.7, oracle threading, all_formulas_separable. Module docstring: "Hierarchy completion: U-type-preserving separation and final all_formulas_separable."
- [ ] Add module docstrings to all three new files
- [ ] Map importers: `Separation.lean` and `SeparationThm.lean` import `Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`
- [ ] Update `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean`: change to direct import(s)
- [ ] Update `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`: change to direct import(s)
- [ ] Delete `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- [ ] Run `lake build` and verify no errors

**Timing**: 3.5 hours

**Depends on**: 6

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyDefs.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/HierarchyCompletion.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

**Import migration** (2 files):
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`: direct import(s)

**Internal DAG**: HierarchyDefs -> HierarchyInduction -> HierarchyCompletion (linear)

**Verification**:
- `lake build` passes
- Separation.lean and SeparationThm.lean use direct imports
- DedekindZ split (Phase 6) still works with Hierarchy split

---

### Phase 9: Split SubformulaClosure.lean (7 active importers, 3-file split) [IN PROGRESS]

**Goal**: Split SubformulaClosure.lean (1889 lines in `Theories/Bimodal/Syntax/`) into 3 focused modules. Note: only `Bimodal.Syntax.SubformulaClosure` is being split (1889 lines); the separate `BXCanonical/Quasimodel/SubformulaClosure.lean` (112 lines) is not affected.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- [ ] Create directory `Theories/Bimodal/Syntax/SubformulaClosure/`
- [ ] Create `SubformulaClosure/Closure.lean` (~550 lines): Core subformula closure as Finset, closureWithNeg, diamond detection/subformulas, subformula membership lemmas. Module docstring: "Core subformula closure: Finset-based closure, negation closure, and membership lemmas."
- [ ] Create `SubformulaClosure/NestingDepth.lean` (~550 lines): F/P-nesting depth, max nesting depth in closure, F/P inner formula extraction. Module docstring: "F/P-nesting depth computation and maximum depth within closure sets."
- [ ] Create `SubformulaClosure/TemporalFormulas.lean` (~790 lines): Future/past formula extraction, deferral types (Until/Since deferral infrastructure), seriality formulas, temporal blocking set, deferral closure definitions, F/P-depth bounding for deferral closure, structural lemmas. Module docstring: "Temporal formula infrastructure: deferral types, blocking sets, and deferral closure."
- [ ] Add module docstrings to all three new files
- [ ] Map all 7 active importers of `Bimodal.Syntax.SubformulaClosure`:
  1. `Theories/Bimodal/Syntax.lean`
  2. `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
  3. `Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean`
  4. `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean`
  5. `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` (was RestrictedMCS.lean, split in Phase 4) or `RestrictedMCS/Deferral.lean`
  6. `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
  7. `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- [ ] For each importer, determine which specific split module(s) it needs:
  - Most importers likely only need `Closure` (core subformula closure)
  - MCS/decidability files may also need `TemporalFormulas` (deferral closure)
- [ ] Update each importer to use direct imports to the specific module(s) it needs
- [ ] Delete `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- [ ] Run `lake build` and verify no errors across all 7 importers

**Timing**: 3.5 hours

**Depends on**: 1, 2, 3, 4

**Files created**:
- `Theories/Bimodal/Syntax/SubformulaClosure/Closure.lean`
- `Theories/Bimodal/Syntax/SubformulaClosure/NestingDepth.lean`
- `Theories/Bimodal/Syntax/SubformulaClosure/TemporalFormulas.lean`

**Files deleted**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean`

**Import migration** (7 files):
- `Theories/Bimodal/Syntax.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Decidability/FMP/ClosureMCS.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Basic.lean` or `Deferral.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`: direct import(s)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`: direct import(s)

**Internal DAG**: Closure -> NestingDepth -> TemporalFormulas (linear)

**Verification**:
- `lake build` passes
- All 7 importers use direct imports
- BXCanonical/Quasimodel/SubformulaClosure.lean (112 lines, separate file) is NOT affected

---

### Phase 10: Split Propositional.lean (19 active importers, 3-file split) [NOT STARTED]

**Goal**: Split Propositional.lean (1704 lines) into 3 focused modules. This is the highest-fan-out split: 19 files import `Bimodal.Theorems.Propositional`. The decomposition aligns with proof-theoretic levels.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in Propositional.lean
- [ ] Create directory `Theories/Bimodal/Theorems/Propositional/`
- [ ] Create `Propositional/Core.lean` (~750 lines): LEM, ex falso quodlibet (efq), ex contradictione quodlibet (ecq), reductio ad absurdum (raa), left/right disjunction introduction (ldi, rdi), left/right conjunction elimination (lce, rce), right conjunction principle (rcp). Module docstring: "Core propositional proof combinators: LEM, efq, ecq, raa, disjunction intro, conjunction elim."
- [ ] Create `Propositional/Connectives.lean` (~730 lines): Classical merge (classical_merge), iff introduction/elimination (iff_intro, iff_elim), contraposition, De Morgan laws, biconditional manipulation. Module docstring: "Derived connective reasoning: classical merge, iff, contraposition, and De Morgan laws."
- [ ] Create `Propositional/Reasoning.lean` (~230 lines): Negation introduction/elimination (ni, ne), biconditional intro (bi_imp), disjunction elimination. Module docstring: "Natural deduction rules: negation intro/elim, biconditional, disjunction elimination."
- [ ] Add module docstrings to all three new files
- [ ] Map all 19 active importers of `Bimodal.Theorems.Propositional`:
  1. `Theories/Bimodal/Theorems.lean`
  2. `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`
  3. `Theories/Bimodal/Theorems/ModalS4.lean`
  4. `Theories/Bimodal/Theorems/ModalS5.lean`
  5. `Theories/Bimodal/Theorems/TemporalDerived.lean`
  6. `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean`
  7. `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`
  8. `Theories/Bimodal/Metalogic/Completeness.lean`
  9. `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
  10. `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean`
  11. `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
  12. `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
  13. `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
  14. `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
  15. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
  16. `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean`
  17. `Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean`
  18. `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
  19. `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean`
- [ ] For each importer, determine which specific split module(s) it needs:
  - Most importers use only `Core` (ecq, raa, efq, ldi, rdi, lce, rce)
  - Some use `Connectives` (iff, De Morgan, classical_merge)
  - Few use `Reasoning` (ni, ne, bi_imp)
- [ ] Update each of the 19 importers to use direct imports to the specific module(s)
- [ ] Delete `Theories/Bimodal/Theorems/Propositional.lean`
- [ ] Run `lake build` and verify no errors across all 19 importers

**Timing**: 5 hours

**Depends on**: 1, 2, 3, 4

**Files created**:
- `Theories/Bimodal/Theorems/Propositional/Core.lean`
- `Theories/Bimodal/Theorems/Propositional/Connectives.lean`
- `Theories/Bimodal/Theorems/Propositional/Reasoning.lean`

**Files deleted**:
- `Theories/Bimodal/Theorems/Propositional.lean`

**Import migration** (19 files): Each updated individually to import only the specific module(s) it needs.

**Internal DAG**: Core -> Connectives -> Reasoning (linear)

**Verification**:
- `lake build` passes
- All 19 importers use direct imports
- No regression in any downstream proof

---

### Phase 11: Split EFGames.lean (10K lines, 3 importers, 6-file split) [NOT STARTED]

**Goal**: Split EFGames.lean (10170 lines) into 6 focused modules. This is the largest file in the codebase. The decomposition follows the mathematical structure of EF game theory: foundations, type formulas, gap detection (Lemma 9 both directions kept together), custom game, decomposition, and Stavi completeness.

**Tasks**:
- [ ] Map all `private` definitions and cross-section usages in EFGames.lean
- [ ] Map all `open` declarations and determine scope per split file
- [ ] Verify all importers: `WeakCanonical.lean`, `EFGameTactics.lean`, `ExpressivenessGeneral.lean`
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/`
- [ ] Create `EFGames/Defs.lean` (~580 lines): Game configuration, EFPosition, depth function, n-equivalence, Gap structure, ExtendedCarrier, IsPoint/IsGap, discrete no-gaps, rank embedding foundations. Module docstring: "EF game foundations: positions, n-equivalence, gap structures, and rank embedding basics."
- [ ] Build and verify after Defs.lean
- [ ] Create `EFGames/TypeFormulas.lean` (~880 lines): Mu-relativized temporal truth, type formulas, rank-embedding formula transfer. Module docstring: "Type formulas and mu-relativized truth for rank-embedding transfer."
- [ ] Build and verify after TypeFormulas.lean
- [ ] Create `EFGames/GapDetection.lean` (~5040 lines): Gap detection formulas (Def 8.5), rank bounds, mu-relativized truth at actual points, gap uniqueness, core gap detection helper, Lemma 9 BOTH directions (left and right). Kept together because they share private definitions and Lemma 9 is mathematically indivisible. Module docstring: "Gap detection formulas and Lemma 9 (both directions): the core EF game characterization."
- [ ] Build and verify after GapDetection.lean
- [ ] Create `EFGames/CustomGame.lean` (~1580 lines): Custom game G_{n;r} (Def 8.7), winning condition, round monotonicity, strategy restriction, game tuple simplification, order preservation, Lemma 10, rank lifting. Module docstring: "Custom game G_{n;r}: definition, winning conditions, and strategy restriction."
- [ ] Build and verify after CustomGame.lean
- [ ] Create `EFGames/Decomposition.lean` (~330 lines): Decomposition agreement, game-decomposition equivalence (Lemma 11). Module docstring: "Decomposition formulas and Lemma 11: game-decomposition equivalence."
- [ ] Build and verify after Decomposition.lean
- [ ] Create `EFGames/StaviCompleteness.lean` (~1610 lines): Standard translation, mu-table correctness, NF characterization, Stavi combinators, main expressive completeness statement. Module docstring: "Stavi expressive completeness: standard translation, NF characterization, and the main theorem."
- [ ] Add module docstrings to all 6 new files
- [ ] Map importers and update each:
  - `WeakCanonical.lean`: likely needs `StaviCompleteness` (for the main theorem)
  - `EFGameTactics.lean`: needs `Defs` and possibly other modules
  - `ExpressivenessGeneral.lean`: needs `Defs`, `GapDetection`, `CustomGame`, `Decomposition` (for Claim 1 and game transfer)
- [ ] Delete `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`
- [ ] Run full `lake build` and verify no errors

**Timing**: 8 hours

**Depends on**: 8, 9, 10

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Defs.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/TypeFormulas.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`

**Import migration** (3 files):
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`: direct import(s) to specific module(s)
- `Theories/Bimodal/Automation/EFGameTactics.lean`: direct import(s) to specific module(s)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`: direct import(s) to specific module(s)

**Internal DAG**:
```
Defs -> TypeFormulas -> GapDetection
Defs -> CustomGame -> Decomposition
TypeFormulas + Decomposition -> StaviCompleteness
```

**Verification**:
- `lake build` passes
- All 3 importers use direct imports
- No file exceeds ~5040 lines (GapDetection.lean is the largest piece, keeping Lemma 9 together)

---

### Phase 12: Split ExpressivenessGeneral.lean (10K lines, 1 importer, 5-file split) [NOT STARTED]

**Goal**: Split ExpressivenessGeneral.lean (9988 lines) into 5 focused modules. This is the second-largest file; only WeakCanonical.lean imports it but it is actively used by paused task 155. The decomposition follows the logical structure of GHR93 Theorem 6.

**Tasks**:
- [ ] Map all `private` definitions and cross-section usages in ExpressivenessGeneral.lean
- [ ] Map all `open` declarations and determine scope per split file
- [ ] Document split boundaries for task 155 rebase reference
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/`
- [ ] Create `Expressiveness/Claim1.lean` (~1610 lines): GHR93 Claim 1 -- continuation predicate, gap construction from infimum, S_C properties, infimum cut, gap r-definability, cross-structure gap r-definability. Module docstring: "GHR93 Claim 1: continuation predicates, gap construction, and gap r-definability."
- [ ] Build and verify after Claim1.lean
- [ ] Create `Expressiveness/DConsistencyTransport.lean` (~730 lines): D-consistency left/right, game rank downward transport (Lemma 10 rank part). Module docstring: "D-consistency and game rank downward transport."
- [ ] Build and verify after DConsistencyTransport.lean
- [ ] Create `Expressiveness/SplitPoint.lean` (~4640 lines): SplitPointProps structure, obtain_split_point_props (the core inductive-step theorem), and all supporting lemmas. This remains large because it is a single cohesive proof with deep interdependencies. Module docstring: "Split-point infrastructure: SplitPointProps and the main obtain_split_point_props theorem."
- [ ] Build and verify after SplitPoint.lean
- [ ] Create `Expressiveness/CaseAnalysis.lean` (~2680 lines): Cases I, II, III-IV analysis and assembly of the inductive step. Module docstring: "Case analysis: Cases I, II, III-IV for the inductive step of Theorem 6."
- [ ] Build and verify after CaseAnalysis.lean
- [ ] Create `Expressiveness/Theorem6.lean` (~300 lines): Final forward-to-backward theorem (uniform rank + rank-varying versions). Module docstring: "Theorem 6: forward-to-backward game transfer for expressive completeness."
- [ ] Add module docstrings to all 5 new files
- [ ] Update `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`: change `import Bimodal.Metalogic.WeakCanonical.ExpressivenessGeneral` to direct import of the specific module(s) it needs (likely `Theorem6`)
- [ ] Delete `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`
- [ ] Run full `lake build` and verify no errors

**Timing**: 7 hours

**Depends on**: 8, 9, 10

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Claim1.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean`

**Files deleted**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

**Import migration** (1 file):
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean`: `import Bimodal.Metalogic.WeakCanonical.ExpressivenessGeneral` -> direct import(s)

**Internal DAG**: Claim1 -> DConsistencyTransport -> SplitPoint -> CaseAnalysis -> Theorem6 (linear)

**Verification**:
- `lake build` passes
- WeakCanonical.lean uses direct imports
- Document split boundaries clearly for task 155 rebase

---

## Testing & Validation

- [ ] `lake build` passes after every individual file split (per-phase verification)
- [ ] Full `lake build` from clean state after all phases complete
- [ ] No file in the codebase exceeds ~5100 lines (GapDetection.lean at ~5040 and SplitPoint.lean at ~4640 are acceptable as indivisible mathematical units)
- [ ] Every new file has a module docstring (first comment block)
- [ ] No aggregator files exist -- all imports are direct to specific split modules
- [ ] `grep -rl "import.*OriginalName" Theories/` shows zero results for every original file name
- [ ] No `private` definition is referenced from a file that cannot see it
- [ ] 35 new module files created across 12 split operations
- [ ] 12 original files deleted

## Artifacts & Outputs

- `specs/174_split_oversized_files/plans/01_split-file-analysis.md` (this plan)
- `specs/174_split_oversized_files/reports/01_split-file-analysis.md` (research report)
- 35 new Lean source files across 12 split operations
- 0 aggregator files (all deleted after migration)
- `specs/174_split_oversized_files/summaries/01_split-file-summary.md` (post-implementation)

### Module Summary

| Original File | Lines | Split Into | New Modules | Importers to Update |
|----------------|------:|:----------:|:-----------:|:-------------------:|
| ExpressiveCompleteness.lean | 2129 | 2 | QuantifierElimination, Theorem | 0 |
| Tactics.lean | 1342 | 2 | Helpers, Commands | 1 |
| ProofSearch.lean | 1388 | 2 | Core, Strategies | 2 |
| RestrictedMCS.lean | 1407 | 2 | Basic, Deferral | 2 |
| SoundnessLemmas.lean | 2407 | 3 | Core, DenseValidity, FrameClassVariants | 2 |
| DedekindZ.lean | 2236 | 2 | QLemma, Cases | 2 |
| IntegerModel.lean | 1816 | 2 | GoodStructures, ShiftAndGlue | 2 |
| Hierarchy.lean | 3845 | 3 | HierarchyDefs, HierarchyInduction, HierarchyCompletion | 2 |
| SubformulaClosure.lean | 1889 | 3 | Closure, NestingDepth, TemporalFormulas | 7 |
| Propositional.lean | 1704 | 3 | Core, Connectives, Reasoning | 19 |
| EFGames.lean | 10170 | 6 | Defs, TypeFormulas, GapDetection, CustomGame, Decomposition, StaviCompleteness | 3 |
| ExpressivenessGeneral.lean | 9988 | 5 | Claim1, DConsistencyTransport, SplitPoint, CaseAnalysis, Theorem6 | 1 |
| **TOTAL** | **50326** | **35** | | **43** |

## Rollback/Contingency

Each split is an independent git-committable unit. If a split fails:
1. `git checkout -- Theories/Bimodal/path/to/OriginalFile.lean` to restore the original
2. `rm -rf Theories/Bimodal/path/to/OriginalFile/` to remove the split directory
3. Restore any modified importers with `git checkout -- <importer-path>`
4. Run `lake build` to confirm clean state
5. Investigate the failure, adjust split boundaries, retry

If the entire task needs to be reverted:
- Each phase is committed separately, so `git revert` can undo individual phases
- The direct-import approach means reverting requires restoring the original file AND reverting all importer changes for that split

For task 155 conflict mitigation:
- If task 155 resumes before this task completes, pause remaining phases
- Document which splits are complete so task 155 can rebase against the new structure
- ExpressivenessGeneral is deliberately scheduled last (Phase 12) to minimize conflict
