# Implementation Plan: Split Oversized Lean Files

- **Task**: 174 - Split Oversized Lean Files
- **Status**: [NOT STARTED]
- **Effort**: 34 hours
- **Dependencies**: None (task 155 paused; ExpressivenessGeneral.lean should be split last to minimize conflict)
- **Research Inputs**: reports/01_split-file-analysis.md
- **Artifacts**: plans/01_split-file-analysis.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Split 12 Lean files exceeding ~1500 lines into focused modules with clear single responsibilities and module docstrings. The codebase contains two 10K-line files (EFGames.lean, ExpressivenessGeneral.lean) that dominate build times, plus 10 additional files between 1342 and 3845 lines. Each split uses the aggregator pattern (original filename imports all split pieces) so existing `import` statements continue to work. The definition of done is: all 12 files split per research proposals, every new file has a module docstring, `lake build` passes after each split, and no downstream import breaks.

### Research Integration

The research report (reports/01_split-file-analysis.md) provided per-file split proposals with line ranges, internal dependency maps, and importer counts. Key findings integrated:
- 5-wave execution order based on importer count (0 importers first, 19 importers last)
- Aggregator re-export pattern for backward-compatible imports
- Pre-split checklist: map `private` defs, audit `open` scopes, create aggregator first
- EFGames.lean splits into 6 files; ExpressivenessGeneral.lean into 4-5 files
- Propositional.lean (19 importers) and SubformulaClosure.lean (10 importers) need careful aggregator handling

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Split all 12 target files so no single file exceeds ~1500 lines
- Each new file has a clear single responsibility and a module docstring
- Use aggregator pattern so existing imports remain unchanged
- Pass `lake build` after each individual split
- Reduce incremental build times for the WeakCanonical directory by enabling parallel compilation of split pieces

**Non-Goals**:
- Refactoring proof content or improving proof style
- Changing any theorem statements or definitions
- Optimizing import graphs beyond the immediate split (can be a follow-up task)
- Splitting files below the 1500-line threshold (Soundness.lean at 1355, NEquivalence.lean at 1227, etc.)
- Updating task 155 branch (will be handled separately when task 155 resumes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `private` definitions become cross-file after split | H | H | Map all private def usages before splitting; convert necessary privates to non-private with `protected` |
| EFGames.lean internal dependencies more tangled than analyzed | H | M | Build after each file move; keep GapDetection + GapDetectionRight in same file if split fails |
| Propositional.lean split breaks 19 downstream importers | H | L | Create aggregator first, verify build, then move content |
| ExpressivenessGeneral.lean conflict with paused task 155 | M | M | Split ExpressivenessGeneral last; document split boundaries for task 155 rebase |
| `open` scope issues after file split | M | H | Audit `open` declarations per split file; add necessary `open` to each new file |
| Build timeout during verification of large splits | M | L | Build incrementally (one file move at a time); use `lake build` not full rebuild |
| InductiveStep section (4643 lines) cannot be split further | L | M | Accept ~5900-line file if needed; flag for future decomposition |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6, 7 | 1, 2, 3, 4 |
| 3 | 8 | 5, 6, 7 |
| 4 | 9, 10 | 8 |
| 5 | 11, 12 | 9, 10 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Split ExpressiveCompleteness.lean (0 importers) [NOT STARTED]

**Goal**: Split ExpressiveCompleteness.lean (2129 lines, 0 downstream importers) into 2 focused files. This is the safest split -- zero import impact.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in ExpressiveCompleteness.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/`
- [ ] Create `ExpressiveCompleteness/Infrastructure.lean` (~850 lines): FO-to-Temporal infrastructure, purity semantic lemmas, substitution under purity, extended signature, quantifier elimination, atom elimination infrastructure, QE correctness, atom membership, guard formulas (lines 4-894)
- [ ] Create `ExpressiveCompleteness/MainTheorem.lean` (~1300 lines): Atom containment lemmas, core expressiveness lemma, final Theorem 10.2.10 (lines 895-2129)
- [ ] Add module docstrings to both new files
- [ ] Convert `ExpressiveCompleteness.lean` to aggregator (imports Infrastructure + MainTheorem)
- [ ] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/Infrastructure.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/MainTheorem.lean` - New file

**Verification**:
- `lake build` passes
- No new warnings or errors
- Both new files have module docstrings
- Original import path still works

---

### Phase 2: Split Tactics.lean (1 importer) [NOT STARTED]

**Goal**: Split Tactics.lean (1342 lines, only Automation.lean imports it) into 2 focused files.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in Tactics.lean
- [ ] Create directory `Theories/Bimodal/Automation/Tactics/`
- [ ] Create `Tactics/Helpers.lean` (~860 lines): Basic macros, assumption_search, formula helpers, tactic factory, inference rule tactics, axiom tactics, core search implementation (lines 6-865)
- [ ] Create `Tactics/Main.lean` (~480 lines): SearchConfig, main tactic definitions (modal_search, temporal_search, propositional_search, tm_auto), tests (lines 866-1342)
- [ ] Add module docstrings to both new files
- [ ] Convert `Tactics.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics.lean` - Convert to aggregator
- `Theories/Bimodal/Automation/Tactics/Helpers.lean` - New file
- `Theories/Bimodal/Automation/Tactics/Main.lean` - New file

**Verification**:
- `lake build` passes
- `Automation.lean` still imports Tactics without changes

---

### Phase 3: Split ProofSearch.lean (2 importers) [NOT STARTED]

**Goal**: Split ProofSearch.lean (1388 lines, 2 importers: Automation.lean, Closure.lean) into 2 focused files.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in ProofSearch.lean
- [ ] Create directory `Theories/Bimodal/Automation/ProofSearch/`
- [ ] Create `ProofSearch/Core.lean` (~750 lines): Types, helper functions, heuristics, bounded search, matchDerived, bounded_search_with_proof, iddfs_search (lines 8-1016)
- [ ] Create `ProofSearch/Advanced.lean` (~640 lines): Best-first search, search strategy configuration, learning-enabled search, batch search (lines 1017-1388)
- [ ] Add module docstrings to both new files
- [ ] Convert `ProofSearch.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch.lean` - Convert to aggregator
- `Theories/Bimodal/Automation/ProofSearch/Core.lean` - New file
- `Theories/Bimodal/Automation/ProofSearch/Advanced.lean` - New file

**Verification**:
- `lake build` passes
- Both importers (Automation.lean, Closure.lean) still work

---

### Phase 4: Split RestrictedMCS.lean (2 importers) [NOT STARTED]

**Goal**: Split RestrictedMCS.lean (1407 lines, 2 importers: Core.lean, ClosureMCS.lean) into 2 focused files.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in RestrictedMCS.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/Core/RestrictedMCS/`
- [ ] Create `RestrictedMCS/Base.lean` (~650 lines): RestrictedConsistent/RestrictedMCS definitions, basic properties, negation completeness, Lindenbaum, constructing MCS from formula, iter_F/P boundedness (lines 9-651)
- [ ] Create `RestrictedMCS/Deferral.lean` (~760 lines): DeferralRestricted definitions, negation completeness, iter_F/P boundedness, closure under derivation, implication property, theorem_in_drm, G_neg lemma (lines 652-1407)
- [ ] Add module docstrings to both new files
- [ ] Convert `RestrictedMCS.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Base.lean` - New file
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS/Deferral.lean` - New file

**Verification**:
- `lake build` passes
- Core.lean and ClosureMCS.lean still import correctly

---

### Phase 5: Split SoundnessLemmas.lean (3 importers) [NOT STARTED]

**Goal**: Split SoundnessLemmas.lean (2407 lines, 3 importers) into 3 focused files aligned with frame-class boundaries.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in SoundnessLemmas.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/SoundnessLemmas/`
- [ ] Create `SoundnessLemmas/SwapValidity.lean` (~800 lines): Swap validity infrastructure, individual swap axiom proofs, rule preservation for swap, axiom_swap_valid master theorem (lines 7-815)
- [ ] Create `SoundnessLemmas/LocalValidity.lean` (~650 lines): Axiom validity (local), rule preservation for local validity, combined soundness theorems, extracted theorems (lines 816-1459)
- [ ] Create `SoundnessLemmas/FrameClassVersions.lean` (~950 lines): General (frame-class-free) versions, discrete frame versions (lines 1460-2407)
- [ ] Add module docstrings to all three new files
- [ ] Convert `SoundnessLemmas.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/SoundnessLemmas/SwapValidity.lean` - New file
- `Theories/Bimodal/Metalogic/SoundnessLemmas/LocalValidity.lean` - New file
- `Theories/Bimodal/Metalogic/SoundnessLemmas/FrameClassVersions.lean` - New file

**Verification**:
- `lake build` passes
- Metalogic.lean, Soundness.lean importers still work

---

### Phase 6: Split DedekindZ.lean (2 importers) [NOT STARTED]

**Goal**: Split DedekindZ.lean (2236 lines, 2 importers: Hierarchy.lean, NormalForm.lean) into 2 focused files.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in DedekindZ.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/`
- [ ] Create `DedekindZ/Defs.lean` (~700 lines): K+/K-/Gamma definitions, triviality on Z, Q-lemma, Q_Z syntactic properties, Case 3 equivalence, helper lemmas, replace U infrastructure, congruence lemmas (lines 5-983)
- [ ] Create `DedekindZ/Cases.lean` (~1250 lines): Cases 5-8 separability proofs (lines 984-2236)
- [ ] Add module docstrings to both new files
- [ ] Convert `DedekindZ.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/Defs.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ/Cases.lean` - New file

**Verification**:
- `lake build` passes
- Hierarchy.lean and NormalForm.lean still import correctly

---

### Phase 7: Split IntegerModel.lean (few importers) [NOT STARTED]

**Goal**: Split IntegerModel.lean (1816 lines) into 2 focused files at the Lemma 16 boundary.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in IntegerModel.lean
- [ ] Verify importers with `grep -rl "import.*IntegerModel" Theories/`
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/`
- [ ] Create `IntegerModel/Defs.lean` (~900 lines): Z-interval structures, good structures, succ-iteration, transitivity helpers, contemporaneous equivalence, no gaps in discrete orders, one-class theorem (lines 7-928)
- [ ] Create `IntegerModel/GoodConstruction.lean` (~900 lines): Very good -> good (Lemma 16), half-open partition, shift-and-glue helpers, chronicle is good (lines 929-1816)
- [ ] Add module docstrings to both new files
- [ ] Convert `IntegerModel.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/Defs.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodConstruction.lean` - New file

**Verification**:
- `lake build` passes
- All importers still work

---

### Phase 8: Split Hierarchy.lean (2 importers, 3-file split) [NOT STARTED]

**Goal**: Split Hierarchy.lean (3845 lines, 2 importers: Separation.lean, SeparationThm.lean) into 3 focused files aligned with GHR94 lemma numbering.

**Tasks**:
- [ ] Audit `private` definitions, `open` scopes, and internal theorem dependencies in Hierarchy.lean
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/`
- [ ] Create `Hierarchy/Defs.lean` (~700 lines): Single U/S-type predicates, Lemma 10.2.5, U/S-formula abstraction, semantic correctness, preservation lemmas, count properties, junction-depth monotonicity (lines 31-820)
- [ ] Create `Hierarchy/Induction.lean` (~1600 lines): Hierarchy theorem steps 1-5b: substitution preservation, strict count decrease, count_U_total lemmas, S/U-nesting depth measures, callback infrastructure (lines 821-2240)
- [ ] Create `Hierarchy/Completion.lean` (~1600 lines): Steps 5c-5d and JD infrastructure: combinators, Cases 5-8, single-U-type separability, GHR94 Lemma 10.2.6/10.2.7, oracle threading, all_formulas_separable (lines 2241-3845)
- [ ] Add module docstrings to all three new files
- [ ] Convert `Hierarchy.lean` to aggregator
- [ ] Run `lake build` and verify no errors

**Timing**: 3 hours

**Depends on**: 5, 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/Defs.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/Induction.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy/Completion.lean` - New file

**Verification**:
- `lake build` passes
- Separation.lean and SeparationThm.lean still import correctly
- DedekindZ split (Phase 6) still works with Hierarchy split

---

### Phase 9: Split SubformulaClosure.lean (10 importers) [NOT STARTED]

**Goal**: Split SubformulaClosure.lean (1889 lines, 10 importers) into 2 files using an aggregator for backward compatibility. Most importers only need the base closure, not the deferral closure.

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in SubformulaClosure.lean
- [ ] Map which of the 10 importers actually use DeferralClosure definitions vs. just SubformulaClosure
- [ ] Create directory `Theories/Bimodal/Syntax/SubformulaClosure/`
- [ ] Create `SubformulaClosure/Base.lean` (~770 lines): Subformula closure as Finset, closure with negations, diamond detection/subformulas, subformula membership lemmas, F/P-nesting depth, max depth in closure, F/P inner formula extraction (lines 7-772)
- [ ] Create `SubformulaClosure/DeferralClosure.lean` (~1120 lines): Deferral closure definitions, Until/Since deferral infrastructure, seriality formulas, temporal blocking set, F/P-depth bounding, structural lemmas (lines 773-1889)
- [ ] Add module docstrings to both new files
- [ ] Convert `SubformulaClosure.lean` to aggregator (imports Base + DeferralClosure)
- [ ] Run `lake build` and verify no errors across all 10 importers
- [ ] Optionally: update importers that only need Base to import `SubformulaClosure.Base` for faster builds

**Timing**: 3 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Convert to aggregator
- `Theories/Bimodal/Syntax/SubformulaClosure/Base.lean` - New file
- `Theories/Bimodal/Syntax/SubformulaClosure/DeferralClosure.lean` - New file

**Verification**:
- `lake build` passes
- All 10 importers (Syntax.lean, BXCanonical.lean, EnrichedClosure.lean, RestrictedMCS.lean, RestrictedParametricTruthLemma.lean, SuccExistence.lean, HintikkaPoint.lean, CanonicalTaskRelation.lean, ClosureMCS.lean, TemporalCoherence.lean) still work

---

### Phase 10: Split Propositional.lean (19 importers) [NOT STARTED]

**Goal**: Split Propositional.lean (1704 lines, 19 importers -- highest impact) into 2 files. Most importers only use Phase 1 foundations (ecq, raa, efq, ldi, rdi, lce, rce).

**Tasks**:
- [ ] Audit `private` definitions and `open` scopes in Propositional.lean
- [ ] Map which of the 19 importers use Phase 4/5 content (De Morgan, natural deduction) vs. just Phase 1/3
- [ ] Create directory `Theories/Bimodal/Theorems/Propositional/`
- [ ] Create `Propositional/Core.lean` (~1000 lines): Helper lemmas, axiomatic helpers, derived classical principles, Phase 1 (propositional foundations), Phase 3 (context manipulation: classical_merge, iff_intro, iff_elim) (lines 6-1064)
- [ ] Create `Propositional/DeMorgan.lean` (~700 lines): Phase 4 (De Morgan laws), biconditional manipulation, Phase 5 (natural deduction rules) (lines 1065-1704)
- [ ] Add module docstrings to both new files
- [ ] Convert `Propositional.lean` to aggregator (imports Core + DeMorgan)
- [ ] Run `lake build` and verify no errors across all 19 importers
- [ ] Optionally: update importers that only need Core to import `Propositional.Core` for faster builds

**Timing**: 3.5 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Theorems/Propositional.lean` - Convert to aggregator
- `Theories/Bimodal/Theorems/Propositional/Core.lean` - New file
- `Theories/Bimodal/Theorems/Propositional/DeMorgan.lean` - New file

**Verification**:
- `lake build` passes
- All 19 importers still work
- No regression in any downstream proof

---

### Phase 11: Split EFGames.lean (10K lines, 3 importers) [NOT STARTED]

**Goal**: Split EFGames.lean (10170 lines, 3 importers: WeakCanonical.lean, EFGameTactics.lean, ExpressivenessGeneral.lean) into 6 focused files. This is the largest file in the codebase.

**Tasks**:
- [ ] Map all `private` definitions and cross-section usages in EFGames.lean
- [ ] Map all `open` declarations and determine scope per split file
- [ ] Verify all importers: `grep -rl "import.*EFGames" Theories/`
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/`
- [ ] Create `EFGames/Defs.lean` (~900 lines): Game configuration, EFPosition, depth function, n-equivalence, Gap structure, ExtendedCarrier, IsPoint/IsGap, discrete no-gaps (lines 1-580)
- [ ] Build and verify after Defs.lean
- [ ] Create `EFGames/RankEmbedding.lean` (~1500 lines): Rank embedding infrastructure, relativized formulas, mu-relativized truth, type formulas, rank embedding formula agreement transfer (lines 580-1608)
- [ ] Build and verify after RankEmbedding.lean
- [ ] Create `EFGames/GapDetection.lean` (~2800 lines): Gap detection formulas (Def 8.5), rank bounds, mu-relativized truth at actual points, gap uniqueness, core gap detection helper, Lemma 9 left direction (lines 1609-4456)
- [ ] Build and verify after GapDetection.lean
- [ ] Create `EFGames/GapDetectionRight.lean` (~2200 lines): Lemma 9 right direction (lines 4457-6651)
- [ ] Build and verify after GapDetectionRight.lean
- [ ] Create `EFGames/GameMechanics.lean` (~2100 lines): Custom game G_{n;r} (Def 8.7), game tuple simplification, order preservation, Lemma 10, rank lifting, K+/K- operators, strategy restriction (lines 6652-8230)
- [ ] Build and verify after GameMechanics.lean
- [ ] Create `EFGames/Decomposition.lean` (~700 lines): Decomposition formulas, Lemma 11, Stavi expressive completeness, standard translation, Stavi combinators, NF characterization (lines 8231-10170)
- [ ] Add module docstrings to all 6 new files
- [ ] Convert `EFGames.lean` to aggregator
- [ ] Run full `lake build` and verify no errors

**Timing**: 6 hours

**Depends on**: 9, 10

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Defs.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/RankEmbedding.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetectionRight.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GameMechanics.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Decomposition.lean` - New file

**Verification**:
- `lake build` passes
- WeakCanonical.lean, EFGameTactics.lean, ExpressivenessGeneral.lean still import correctly
- No file exceeds ~2800 lines (GapDetection.lean is the largest piece)

---

### Phase 12: Split ExpressivenessGeneral.lean (10K lines, 1 importer) [NOT STARTED]

**Goal**: Split ExpressivenessGeneral.lean (9988 lines, 1 importer: WeakCanonical.lean) into 4-5 focused files. This is the second-largest file; only 1 importer but actively used by paused task 155.

**Tasks**:
- [ ] Map all `private` definitions and cross-section usages in ExpressivenessGeneral.lean
- [ ] Map all `open` declarations and determine scope per split file
- [ ] Document split boundaries for task 155 rebase reference
- [ ] Create directory `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/`
- [ ] Create `Expressiveness/Claim1Infrastructure.lean` (~1600 lines): Base case helper, continuation predicate, gap construction, S_C properties, infimum cut, gap r-definability (lines 33-1644)
- [ ] Build and verify
- [ ] Create `Expressiveness/DConsistencyAndRankTransport.lean` (~730 lines): D-consistency left/right, game rank downward transport (lines 1645-2372)
- [ ] Build and verify
- [ ] Create `Expressiveness/InductiveStep.lean` (~5900 lines or split further into InductiveStepSetup + CaseAnalysis): Inductive step infrastructure through Cases I-IV and assembly (lines 2373-9689)
- [ ] Build and verify
- [ ] Create `Expressiveness/ForwardToBackward.lean` (~300 lines): Final forward-to-backward theorems (lines 9690-9988)
- [ ] Build and verify
- [ ] Add module docstrings to all new files
- [ ] Convert `ExpressivenessGeneral.lean` to aggregator (or create new `Expressiveness.lean` aggregator if renaming)
- [ ] Run full `lake build` and verify no errors
- [ ] If InductiveStep exceeds 3000 lines, attempt secondary split into InductiveStepSetup.lean (~4643 lines) and CaseAnalysis.lean (~2635 lines)

**Timing**: 5.5 hours

**Depends on**: 9, 10

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` - Convert to aggregator
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Claim1Infrastructure.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyAndRankTransport.lean` - New file
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/InductiveStep.lean` - New file (may split further)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/ForwardToBackward.lean` - New file

**Verification**:
- `lake build` passes
- WeakCanonical.lean still imports correctly
- Document split boundaries clearly for task 155 rebase

---

## Testing & Validation

- [ ] `lake build` passes after every individual file split (per-phase verification)
- [ ] Full `lake build` from clean state after all phases complete
- [ ] No file in the codebase exceeds ~3000 lines (GapDetection.lean at ~2800 is acceptable; InductiveStep.lean may remain ~5900 if secondary split fails)
- [ ] Every new file has a module docstring (first comment block)
- [ ] All aggregator files correctly re-export their split pieces
- [ ] `grep -rl "import.*OriginalName" Theories/` shows no broken imports
- [ ] No `private` definition is referenced from a file that cannot see it

## Artifacts & Outputs

- `specs/174_split_oversized_files/plans/01_split-file-analysis.md` (this plan)
- `specs/174_split_oversized_files/reports/01_split-file-analysis.md` (research report)
- ~30 new Lean source files across 12 split operations
- 12 aggregator files (original filenames, now re-exporting split pieces)
- `specs/174_split_oversized_files/summaries/01_split-file-summary.md` (post-implementation)

## Rollback/Contingency

Each split is an independent git-committable unit. If a split fails:
1. `git checkout -- Theories/Bimodal/path/to/OriginalFile.lean` to restore the original
2. `rm -rf Theories/Bimodal/path/to/OriginalFile/` to remove the split directory
3. Run `lake build` to confirm clean state
4. Investigate the failure, adjust split boundaries, retry

If the entire task needs to be reverted:
- Each phase is committed separately, so `git revert` can undo individual phases
- The aggregator pattern means reverting a split only requires restoring one file and removing one directory

For task 155 conflict mitigation:
- If task 155 resumes before this task completes, pause remaining phases
- Document which splits are complete so task 155 can rebase against the new structure
