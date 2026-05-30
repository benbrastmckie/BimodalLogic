# Research Report: Task #183 — Plan Revision Delta

**Task**: 183 - Documentation Standards: READMEs and Comments
**Started**: 2026-05-29T18:00:00Z
**Completed**: 2026-05-29T19:00:00Z
**Effort**: 1 hour
**Dependencies**: None (delta research, reads existing artifacts)
**Sources/Inputs**:
- `specs/183_documentation_standards_readmes_comments/reports/01_documentation-audit.md` (original audit, 2026-05-21)
- `specs/183_documentation_standards_readmes_comments/plans/01_documentation-standards.md` (existing plan)
- Live filesystem audit: `find`, `ls`, `grep` across `Theories/Bimodal/`
- `specs/state.json` (task status for 131, 174, 175, 201-215)
- Git log for file creation provenance
**Artifacts**:
- `specs/183_documentation_standards_readmes_comments/reports/02_plan-revision-delta.md` (this file)
**Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

---

## Executive Summary

- The repository grew from 152 to 196 active .lean files (+44), with 12 entirely new directories that the original plan does not account for, raising the missing-README count from 8 to 20.
- Task 174 (file splitting, completed) created 9 new subdirectories by splitting large lean files; none received READMEs during that task.
- Tasks 201, 203, 205–207, 209–213 (dataset/benchmark automation, completed) expanded Automation from 4 to 16 top-level files + 2 subdirectories, making the Automation README severely stale (it still describes only the original 4 files).
- The ProofSystem axiom count grew from 40 to 55 constructors; READMEs that referenced the already-wrong "15 axioms" now have an even larger gap.
- Both dependency tasks remain incomplete: task 131 (module reorg) is [NOT STARTED], task 175 (naming cleanup) is [RESEARCHED]; the risk they will shift file structure after documentation work is real.
- The original plan's Phase 2 (8 missing READMEs) must expand to cover 20 directories; the effort estimate of 10 hours is materially underestimated and should increase to approximately 16–20 hours.

---

## Context & Scope

The original documentation audit (01_documentation-audit.md, dated 2026-05-21) and implementation plan (01_documentation-standards.md) were written when the repository had 152 active lean files across 26 directories (excluding Boneyard). Since then, 663+ commits have been added. This delta report does not re-audit the entire codebase; it focuses on identifying exactly what has changed and how those changes affect the existing plan.

---

## Findings

### 1. File Count Changes

| Metric | Original Audit | Current State | Delta |
|--------|----------------|---------------|-------|
| Active .lean files (ex. Boneyard) | 152 | 196 | +44 |
| Directories with .lean files | 26 | 34 | +8 net (+12 new, a few absorbed into subdirectories) |
| Directories with READMEs | 16 | 14 | −2 (two lost coverage: READMEs describe files that became dirs) |
| Directories missing READMEs | 8 | 20 | +12 |
| Axiom constructors (Axioms.lean) | 40 | 55 | +15 |
| sorry occurrences | 145 | 181 | +36 |
| sorry-bearing files | 35 | 43 | +8 |

### 2. New Directories Requiring READMEs (the 12 plan-gaps)

These directories did not exist when the plan was written. All have lean files and no README:

| Directory | Files | Created By | Priority |
|-----------|-------|------------|----------|
| `Automation/ProofSearch` | 2 | Task 174 (split ProofSearch.lean) | Medium |
| `Automation/Tactics` | 2 | Task 174 (split Tactics.lean) | Medium |
| `Metalogic/Core/RestrictedMCS` | 2 | Task 174 (split RestrictedMCS.lean) | Medium |
| `Metalogic/SoundnessLemmas` | 3 | Task 174 (split SoundnessLemmas.lean) | Medium |
| `Metalogic/WeakCanonical/EFGames` | 9 | Task 174 (split EFGames.lean) | High |
| `Metalogic/WeakCanonical/ExpressiveCompleteness` | 2 | Task 174 (split ExpressivenessGeneral.lean) | Medium |
| `Metalogic/WeakCanonical/Expressiveness` | 5 | Task 174 (split) | Medium |
| `Metalogic/WeakCanonical/IntegerModel` | 3 | Task 174 (split IntegerModel.lean) | Medium |
| `Metalogic/WeakCanonical/Separation/DedekindZ` | 2 | Task 174 (split DedekindZ.lean) | Low |
| `Metalogic/WeakCanonical/Separation/Hierarchy` | 3 | Task 174 (split Hierarchy.lean) | Low |
| `Syntax/SubformulaClosure` | 3 | Task 174 (split SubformulaClosure.lean) | High |
| `Theorems/Propositional` | 3 | Task 174 (split Propositional.lean) | Medium |

All 12 were created by task 174 ("split large lean files into subdirectories"), which completed but did not create READMEs for the new directories.

### 3. Automation Directory: Now Severely Stale

The Automation README was marked "Accurate" in the original audit (4 files matched). It is now severely stale:

**README describes**: Tactics.lean, AesopRules.lean, ProofSearch.lean, SuccessPatterns.lean (4 files)

**Actual top-level files** (16): AesopRules.lean, BenchmarkAnchors.lean, BenchmarkOracle.lean, DataExport.lean, DatasetExporter.lean, DatasetExport.lean, DatasetGenerator.lean, DatasetValidator.lean, EFGameTactics.lean, EnrichedCountermodel.lean, EnumBenchmark.lean, FormulaEnumerator.lean, FormulaMutator.lean, ProofStepExport.lean, ProofStepExtractor.lean, SuccessPatterns.lean

**Actual subdirectories** (2 with files): `ProofSearch/` (Core.lean, Strategies.lean), `Tactics/` (Commands.lean, Helpers.lean)

**Files referenced in README but no longer top-level**: `Tactics.lean` (now `Tactics/` directory), `ProofSearch.lean` (now `ProofSearch/` directory)

**New files by task**:
- Task 201: DatasetExporter.lean, DatasetGenerator.lean, DatasetValidator.lean
- Task 203: Updated Automation.lean re-export
- Task 206: BenchmarkOracle.lean, FormulaMutator.lean
- Task 207: BenchmarkAnchors.lean, DatasetExport.lean
- Task 212: ProofStepExport.lean (ProofStepExtractor.lean existed earlier)
- Task 213: EnumBenchmark.lean, FormulaEnumerator.lean (via task 210)
- Task 174: Moved Tactics.lean → Tactics/, ProofSearch.lean → ProofSearch/

The README describes a pure proof-automation library. The directory is now primarily a **dataset generation pipeline** with 12 of 16 top-level files serving ML/benchmark purposes (DatasetGenerator, DatasetValidator, DatasetExporter, DatasetExport, DataExport, FormulaEnumerator, FormulaMutator, BenchmarkOracle, BenchmarkAnchors, EnumBenchmark, ProofStepExtractor, ProofStepExport).

### 4. READMEs Now Describing Files That Became Directories

Two READMEs list a .lean file that has since been converted to a subdirectory:

| README | Listed as file | Current status |
|--------|----------------|----------------|
| `Syntax/README.md` | `SubformulaClosure.lean` | Now `SubformulaClosure/` directory (3 files) |
| `Metalogic/Core/README.md` | `RestrictedMCS.lean` | Now `RestrictedMCS/` directory (2 files) |
| `Theorems/README.md` | `Propositional.lean` | Now `Propositional/` directory (3 files) |

These READMEs need updating to remove the file entries and add subdirectory descriptions.

### 5. ProofSystem README: Axiom Count Now 55 (was "15", actual was 40)

The ProofSystem README claims "15 TM axiom schemas" (already wrong at audit time when actual was 40). The current count is **55 constructors** in the `Axiom` inductive type. The original plan's Phase 3 task to "Update axiom count from 15 to actual count (currently 40)" must be revised to "update to 55".

Additionally: ProofSystem now has 5 files (added `LinearityDerivedFacts.lean`), but the README still lists only 3. The plan already covers adding `Substitution.lean`, but `LinearityDerivedFacts.lean` must also be added.

### 6. Root README Status

The Root README still references three non-existent files:
- `Examples/Demo.lean` — does not exist (only BimodalProofs.lean and TemporalStructures.lean)
- `LogicVariants.lean` — does not exist
- `Metalogic/BaseCompleteness.lean` — does not exist

The Root README axiom counts now have three layers of incorrectness: it claims "21 axiom schemata" in the overview table and "21 TM axiom schemata" in the Submodules section, when the actual count is 55. The `Discrete (Base + 3 = 21)` framing in the Logic Variants section is a variant count (17+1+3=21), which is architecturally meaningful, but the top-level "21 axiom schemata" and ProofSystem description "21 axioms, 7 rules" are misleading since 55 constructors exist.

Note: The 21-axiom framing may reflect intentional logical schema grouping (21 distinct schemas versus 55 constructors that may include instances or fine-grained splits). This must be investigated during implementation to determine whether to update counts or clarify the schema vs. constructor distinction.

### 7. Metalogic README Status

The Metalogic README architecture diagram lists `SoundnessLemmas.lean` as a top-level file in the `Metalogic/` tree. It is now a **directory** (`Metalogic/SoundnessLemmas/`) with 3 files (Core.lean, DenseValidity.lean, FrameClassVariants.lean). The file `Metalogic/SoundnessLemmas.lean` no longer exists as a single file.

Additionally, the Metalogic README does not mention `DenseSoundness.lean` and `DiscreteSoundness.lean` which exist at the Metalogic top level (added by tasks 166/168 before the original audit — this was an existing gap in the audit).

The architecture diagram also does not list the `BXCanonical/TruthLemma.lean` file which now exists (previously Metalogic/Bundle/TruthLemma.lean was listed as missing; that file is still missing, but BXCanonical has its own TruthLemma.lean).

The subdirectory summary table in Metalogic README shows `ConservativeExtension/` with "No" README — this was already accurate at audit time and remains so.

### 8. Theorems README Status

The Theorems README still:
- Lists `Discreteness.lean` (does not exist)
- Lists `Propositional.lean` (now a directory `Propositional/`)
- Missing `TemporalDerived.lean` (exists)
- Missing documentation for `Propositional/` subdirectory (3 files)

This was already flagged as stale in the original audit; the file-to-directory conversion for Propositional has made it more stale.

### 9. Decidability README Status

Decidability README still has no mention of `FMP/` subdirectory (7 files: ClosureMCS.lean, DenseFMP.lean, DiscreteFMP.lean, Filtration.lean, FiniteModel.lean, FMP.lean, TruthPreservation.lean). The `Decidability/FMP.lean` re-export file also exists at top level but is not documented. Broken link to `../Soundness/README.md` persists.

### 10. Syntax README Status

Missing `BigConj.lean` (was flagged in original audit). Now additionally missing the `SubformulaClosure/` subdirectory description.

### 11. BXCanonical Status

BXCanonical directory has grown: 7 top-level files (BXCanonical.lean, CanonicalChain.lean, CanonicalModel.lean, Completeness.lean, Frame.lean, OrderedSeedConsistency.lean, TruthLemma.lean). Chronicle has 7 files (was 6), Quasimodel has 6 files (unchanged), Filtration has 1 file (unchanged). No READMEs exist for any BXCanonical directory — this was already flagged in the original plan.

### 12. Dependency Task Status

| Task | Status | Impact |
|------|--------|--------|
| 131 - Module reorg | [NOT STARTED] | Could shift directory structure; may obsolete some documentation written before it runs |
| 175 - Naming cleanup | [RESEARCHED] | Could rename files/directories; would require README updates after completion |
| 174 - File splitting | [COMPLETED] | Already created 12 new directories needing READMEs (fully landed) |

---

## Decisions

1. **Automation README requires a complete rewrite**, not a minor update — the directory's purpose has fundamentally changed from proof automation to dataset generation pipeline with proof automation as a subset.
2. **The missing README count for Phase 2 must expand from 8 to 20 directories** — the 12 new directories from task 174 are all in scope.
3. **The effort estimate of 10 hours is insufficient** — with 20 missing READMEs (was 8), 7+ stale READMEs requiring updates (was 6, now includes Automation and 3 file-to-directory conversions), and a larger Automation directory, a revised estimate of 16–20 hours is appropriate.
4. **The axiom count in all README updates should be 55** (not "40" as the original plan specified), until the implementation phase verifies whether the logical-schema count (21) or constructor count (55) is the intended documentation target.

---

## Recommendations

### Plan Revision: Phase 2 — Expand to 20 Missing READMEs

Replace the Phase 2 task list (currently 8 items) with:

**Original 8 (retained)**:
1. `Metalogic/WeakCanonical/README.md` (14 top-level files)
2. `Metalogic/WeakCanonical/Separation/README.md` (11 top-level files)
3. `Metalogic/BXCanonical/README.md` (7 files)
4. `Metalogic/BXCanonical/Chronicle/README.md` (7 files)
5. `Metalogic/BXCanonical/Quasimodel/README.md` (6 files)
6. `Metalogic/BXCanonical/Filtration/README.md` (1 file)
7. `FrameConditions/README.md` (4 files)
8. `Metalogic/Decidability/FMP/README.md` (7 files)

**New 12 (add to Phase 2)**:
9. `Automation/ProofSearch/README.md` (2 files: Core.lean, Strategies.lean)
10. `Automation/Tactics/README.md` (2 files: Commands.lean, Helpers.lean)
11. `Metalogic/Core/RestrictedMCS/README.md` (2 files: Basic.lean, Deferral.lean)
12. `Metalogic/SoundnessLemmas/README.md` (3 files: Core.lean, DenseValidity.lean, FrameClassVariants.lean)
13. `Metalogic/WeakCanonical/EFGames/README.md` (9 files — High priority, large active area)
14. `Metalogic/WeakCanonical/ExpressiveCompleteness/README.md` (2 files)
15. `Metalogic/WeakCanonical/Expressiveness/README.md` (5 files)
16. `Metalogic/WeakCanonical/IntegerModel/README.md` (3 files)
17. `Metalogic/WeakCanonical/Separation/DedekindZ/README.md` (2 files)
18. `Metalogic/WeakCanonical/Separation/Hierarchy/README.md` (3 files)
19. `Syntax/SubformulaClosure/README.md` (3 files: Closure.lean, NestingDepth.lean, TemporalFormulas.lean)
20. `Theorems/Propositional/README.md` (3 files: Connectives.lean, Core.lean, Reasoning.lean)

Estimated Phase 2 timing: **5–6 hours** (was 2.5 hours).

### Plan Revision: Phase 3 — Add New Stale READMEs and Updated Fixes

Add to Phase 3's task list:

**New items**:
- Rewrite `Automation/README.md` entirely (4 → 16 top-level + 2 subdirectories; two-thirds of the directory is now ML dataset infrastructure, not proof automation)
- Update `Syntax/README.md`: remove `SubformulaClosure.lean` entry, add `SubformulaClosure/` subdirectory entry; add missing `BigConj.lean`
- Update `Metalogic/Core/README.md`: change `RestrictedMCS.lean` to `RestrictedMCS/` subdirectory entry
- Update `Theorems/README.md`: change `Propositional.lean` to `Propositional/` subdirectory entry (Propositional is already listed but its type changed)
- Update `Metalogic/README.md`: change `SoundnessLemmas.lean` to `SoundnessLemmas/` directory entry; add `DenseSoundness.lean` and `DiscreteSoundness.lean` to architecture tree

**Retained from original plan** (with updated axiom count):
- Rewrite `ProofSystem/README.md`: update "15 axioms" → investigate schema count vs. constructor count; document 5 files (was 3), add Substitution.lean and LinearityDerivedFacts.lean
- Update `Metalogic/Decidability/README.md`: add `FMP/` subdirectory documentation, add `FMP.lean` re-export, fix `../Soundness/README.md` link
- Update `Root README.md`: fix axiom counts (21 → investigate 55 vs. 21 schema distinction), remove Demo.lean/LogicVariants.lean/BaseCompleteness.lean references
- Update `Metalogic/README.md`: update architecture diagram for Bundle stale refs (TruthLemma, BFMCSTruth, Completeness still missing from Bundle/)
- Fix `Semantics/README.md` broken link

Estimated Phase 3 timing: **3.5–4 hours** (was 2 hours).

### Effort Estimate Update

| Phase | Original Estimate | Revised Estimate | Reason |
|-------|------------------|------------------|--------|
| 1: Standards + Scripts | 2 hours | 2 hours | Unchanged |
| 2: Missing READMEs | 2.5 hours | 5–6 hours | 8 → 20 missing READMEs |
| 3: Fix Stale READMEs | 2 hours | 3.5–4 hours | 3 new stale READMEs; Automation rewrite is large |
| 4: Docstring Quality | 1.5 hours | 1.5 hours | Unchanged (196 files, same quality issues) |
| 5: Root + Cross-links | 2 hours | 2.5–3 hours | More directories to cross-link (34 vs. 26) |
| **Total** | **10 hours** | **14.5–16.5 hours** | |

### Dependency Risk Mitigation

Given that task 131 (module reorg) is still NOT STARTED:

- **Option A (recommended)**: Proceed with task 183 now, noting that task 131 completion will require a documentation re-run. Write README content with "This README was last verified before task 131 (module reorg) completed — verify file list is still current after that task."
- **Option B**: Block task 183 on task 131 completion. However, task 131 has no plan or research and is unlikely to complete soon; indefinite blocking is not practical.

The original plan already identified this risk; it remains valid and Option A is still the correct mitigation.

### Axiom Count Investigation

Before writing ProofSystem or Root README, the implementer must determine whether the intended documentation target is:
- **55 constructors** (current `Axiom` inductive type constructor count) — the raw implementation fact
- **21 logical schemas** (17 base + 1 dense + 3 discrete) — the logically meaningful grouping
- Both should appear, with explanation: "The 21 axiom schemas are implemented as 55 constructors in the `Axiom` inductive type (some schemas are split by frame class or operator)."

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 131 runs after documentation and shifts directory structure | H | M | Note "last verified" dates; run lint scripts after task 131 |
| Task 175 (naming cleanup) renames files/directories | M | H (it's [RESEARCHED]) | Mark READMEs as pending task-175 review; run lint after |
| Automation README rewrite misrepresents the dual nature (proof automation + ML pipeline) | M | M | During implementation, read all 16 .lean files' module docstrings to capture both purposes accurately |
| Axiom count documentation causes confusion (55 vs 21) | L | M | Explain constructor vs. schema distinction explicitly |
| New directories from potential future splits have no READMEs | L | M | Lint scripts from Phase 1 detect this automatically |

---

## Context Extension Recommendations

- **Topic**: Automation directory now serves dual purpose (proof automation + ML dataset generation)
- **Gap**: The `.claude/context/repo/project-overview.md` likely describes Automation as proof automation only; the dataset generation purpose should be documented.
- **Recommendation**: Update `project-overview.md` Automation description to reflect the dual nature after task 183 implementation.

---

## Appendix

### File-to-Directory Conversions by Task 174

Task 174 ("split large lean files into subdirectories") made 12 phase commits splitting single large files into directories:
- Phase 2: Tactics.lean → Tactics/ (Helpers.lean, Commands.lean)
- Phase 3: ProofSearch.lean → ProofSearch/ (Core.lean, Strategies.lean)
- Phase 4: RestrictedMCS.lean → RestrictedMCS/ (Basic.lean, Deferral.lean)
- Phase 5: SoundnessLemmas.lean → SoundnessLemmas/ (Core.lean, DenseValidity.lean, FrameClassVariants.lean)
- Phase 6: DedekindZ.lean → DedekindZ/ (Cases.lean, QLemma.lean)
- Phase 7: IntegerModel.lean → IntegerModel/ (GoodStructures.lean, ReynoldsNoGaps.lean, ShiftAndGlue.lean)
- Phase 8: Hierarchy.lean → Hierarchy/ (HierarchyCompletion.lean, HierarchyDefs.lean, HierarchyInduction.lean)
- Phase 9: SubformulaClosure.lean → SubformulaClosure/ (Closure.lean, NestingDepth.lean, TemporalFormulas.lean)
- Phase 10: Propositional.lean → Propositional/ (Connectives.lean, Core.lean, Reasoning.lean)
- Phase 11: EFGames.lean → EFGames/ (9 files)
- Phase 12: ExpressivenessGeneral.lean → Expressiveness/ + ExpressiveCompleteness/

### Automation Files Added by Task

| File | Added By Task |
|------|--------------|
| DatasetExporter.lean | 201 |
| DatasetGenerator.lean | 201 |
| DatasetValidator.lean | 201 |
| EnrichedCountermodel.lean | 201 |
| BenchmarkOracle.lean | 206 |
| FormulaMutator.lean | 206 |
| BenchmarkAnchors.lean | 207 |
| DatasetExport.lean | 207 |
| DataExport.lean | 207 |
| ProofStepExport.lean | 212 |
| ProofStepExtractor.lean | pre-183 (task 116) |
| EFGameTactics.lean | pre-183 (task 155) |
| EnumBenchmark.lean | 213 |
| FormulaEnumerator.lean | 213 (via task 210) |
| SuccessPatterns.lean | pre-183 (task 116) |

### Current Directory-README Matrix (Complete)

| Directory | Files | Has README | Status |
|-----------|-------|-----------|--------|
| `Theories/Bimodal/` (root) | 9 | Yes | Stale (Demo.lean, LogicVariants.lean, BaseCompleteness.lean refs; 21→55 axiom count) |
| `Syntax/` | 5 | Yes | Stale (SubformulaClosure.lean → dir, missing BigConj.lean) |
| `Syntax/SubformulaClosure/` | 3 | **No** | NEW — needs README |
| `ProofSystem/` | 5 | Yes | Severely Stale ("15 axioms", actual 55; 3→5 files) |
| `Semantics/` | 5 | Yes | Partially stale (broken ../Metalogic/Soundness/README.md link) |
| `Automation/` | 16 | Yes | **Severely Stale** (describes 4 files, actual 16; major purpose change) |
| `Automation/ProofSearch/` | 2 | **No** | NEW — needs README |
| `Automation/Tactics/` | 2 | **No** | NEW — needs README |
| `Examples/` | 2 | Yes | Accurate |
| `FrameConditions/` | 4 | **No** | Missing (carried over from original audit) |
| `Theorems/` | 6 | Yes | Stale (Discreteness.lean ref, Propositional.lean → dir, missing TemporalDerived.lean) |
| `Theorems/Perpetuity/` | 3 | Yes | Accurate |
| `Theorems/Propositional/` | 3 | **No** | NEW — needs README |
| `Metalogic/` | 7 | Yes | Stale (SoundnessLemmas.lean → dir, missing DenseSoundness/DiscreteSoundness, Bundle refs) |
| `Metalogic/Core/` | 4 | Yes | Stale (RestrictedMCS.lean → dir) |
| `Metalogic/Core/RestrictedMCS/` | 2 | **No** | NEW — needs README |
| `Metalogic/SoundnessLemmas/` | 3 | **No** | NEW — needs README |
| `Metalogic/Bundle/` | 14 | Yes | Accurate |
| `Metalogic/Decidability/` | 9 | Yes | Stale (no FMP coverage, broken Soundness link) |
| `Metalogic/Decidability/FMP/` | 7 | **No** | Missing (carried over from original audit) |
| `Metalogic/Algebraic/` | 11 | Yes | Accurate |
| `Metalogic/BXCanonical/` | 7 | **No** | Missing (carried over) |
| `Metalogic/BXCanonical/Chronicle/` | 7 | **No** | Missing (carried over) |
| `Metalogic/BXCanonical/Quasimodel/` | 6 | **No** | Missing (carried over) |
| `Metalogic/BXCanonical/Filtration/` | 1 | **No** | Missing (carried over) |
| `Metalogic/ConservativeExtension/` | 4 | Yes | Accurate |
| `Metalogic/Relational/` | 0 | Yes | Placeholder (correct) |
| `Metalogic/WeakCanonical/` | 14 | **No** | Missing (carried over) |
| `Metalogic/WeakCanonical/EFGames/` | 9 | **No** | NEW — needs README |
| `Metalogic/WeakCanonical/ExpressiveCompleteness/` | 2 | **No** | NEW — needs README |
| `Metalogic/WeakCanonical/Expressiveness/` | 5 | **No** | NEW — needs README |
| `Metalogic/WeakCanonical/IntegerModel/` | 3 | **No** | NEW — needs README |
| `Metalogic/WeakCanonical/Separation/` | 11 | **No** | Missing (carried over) |
| `Metalogic/WeakCanonical/Separation/DedekindZ/` | 2 | **No** | NEW — needs README |
| `Metalogic/WeakCanonical/Separation/Hierarchy/` | 3 | **No** | NEW — needs README |

**Totals**: 34 lean-containing directories; 14 with READMEs (all stale to some degree); 20 without READMEs.
