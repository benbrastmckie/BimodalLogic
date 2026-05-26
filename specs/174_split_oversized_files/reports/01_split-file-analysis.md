# Task 174: Split Oversized Files -- Research Report

**Session**: sess_1779809662_d9784a
**Date**: 2026-05-26
**Status**: Complete research

## 1. File Inventory (Current Line Counts)

| # | File | Lines | Directory | In Scope? |
|---|------|------:|-----------|-----------|
| 1 | EFGames.lean | 10170 | Metalogic/WeakCanonical/ | YES (not in original list, but largest file) |
| 2 | ExpressivenessGeneral.lean | 9988 | Metalogic/WeakCanonical/ | YES |
| 3 | Hierarchy.lean | 3845 | Metalogic/WeakCanonical/Separation/ | YES |
| 4 | SoundnessLemmas.lean | 2407 | Metalogic/ | YES |
| 5 | DedekindZ.lean | 2236 | Metalogic/WeakCanonical/Separation/ | YES |
| 6 | ExpressiveCompleteness.lean | 2129 | Metalogic/WeakCanonical/ | YES |
| 7 | SubformulaClosure.lean | 1889 | Syntax/ | YES |
| 8 | IntegerModel.lean | 1816 | Metalogic/WeakCanonical/ | YES (not in original list, but >1500) |
| 9 | Propositional.lean | 1704 | Theorems/ | YES |
| 10 | Soundness.lean | 1355 | Metalogic/ | BORDERLINE (below 1500 but related to SoundnessLemmas) |
| 11 | RestrictedMCS.lean | 1407 | Metalogic/Core/ | YES (borderline) |
| 12 | ProofSearch.lean | 1388 | Automation/ | YES (borderline) |
| 13 | Tactics.lean | 1342 | Automation/ | YES (borderline) |

**Notes**:
- EFGames.lean (10170) was not in the original task description but is the single largest file in the codebase and should be prioritized.
- IntegerModel.lean (1816) was also omitted but exceeds the 1500-line threshold.
- SoundnessLemmas.lean is 2407 lines (slightly different from the 2422 stated in the task, likely due to post-task-168 changes).

## 2. Per-File Split Proposals

### 2.1 EFGames.lean (10170 lines) -- PRIORITY 1

**Current structure**: Contains ALL GHR93 game infrastructure -- definitions, gaps, rank embedding, type formulas, gap detection (Lemma 9), custom game, strategy restriction, decomposition (Lemma 11), Stavi translation, and NF characterization.

**Proposed split into 5 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `EFGames/Defs.lean` | ~900 | Game configuration, EFPosition, depth function, n-equivalence, Gap structure, ExtendedCarrier, IsPoint/IsGap, discrete no-gaps |
| `EFGames/RankEmbedding.lean` | ~1500 | Rank embedding infrastructure, relativized formulas, mu-relativized truth, type formulas, rank embedding formula agreement transfer (lines 580-1608) |
| `EFGames/GapDetection.lean` | ~2800 | Gap detection formulas (Def 8.5), rank bounds, mu-relativized truth at actual points, gap uniqueness, core gap detection helper, Lemma 9 left direction (lines 1609-4456) |
| `EFGames/GapDetectionRight.lean` | ~2200 | Lemma 9 right direction (lines 4457-6651) |
| `EFGames/GameMechanics.lean` | ~2100 | Custom game G_{n;r} (Def 8.7), game tuple simplification, order preservation, Lemma 10 monotonicity, rank lifting, K+/K- operators, rank monotonicity of winning strategies, strategy restriction (lines 6652-8230) |
| `EFGames/Decomposition.lean` | ~700 | Decomposition formulas, Lemma 11, Stavi expressive completeness statement, standard translation, Stavi combinators, NF characterization (lines 8231-10170) |

**Internal dependencies**: Defs <- RankEmbedding <- GapDetection <- GapDetectionRight, and Defs <- GameMechanics. Decomposition depends on GameMechanics and GapDetection.

**Key risk**: The gap detection proofs (Lemma 9) are 3958 lines total and naturally split into left/right directions. The GameMechanics section has well-defined boundaries at the `## Custom Game` header.

### 2.2 ExpressivenessGeneral.lean (9988 lines) -- PRIORITY 1

**Current structure**: GHR93 Theorem 6 (forward-to-backward game transfer) with all supporting infrastructure.

**Proposed split into 4 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Expressiveness/Claim1Infrastructure.lean` | ~1600 | Base case helper, continuation predicate, gap construction, S_C properties, infimum cut, gap r-definability, cross-structure gap r-definability (lines 33-1644) |
| `Expressiveness/DConsistencyAndRankTransport.lean` | ~730 | D-consistency left/right, game rank downward transport (Lemma 10 rank part) (lines 1645-2372) |
| `Expressiveness/InductiveStep.lean` | ~5900 | Inductive step infrastructure (obtain_split_point_props through Cases I-IV and assembly) (lines 2373-9689). This is still large but is a single continuous proof with deep interdependencies. |
| `Expressiveness/ForwardToBackward.lean` | ~300 | Final forward-to-backward theorems (uniform rank + rank-varying versions) (lines 9690-9988) |

**Alternative**: Split InductiveStep further:

| Sub-file | Lines | Contents |
|----------|------:|----------|
| `Expressiveness/InductiveStepSetup.lean` | ~4643 | obtain_split_point_props and supporting infrastructure (lines 2373-7015) |
| `Expressiveness/CaseAnalysis.lean` | ~2635 | Cases I, II, III-IV, assembly (lines 7016-9650) |

**Internal dependencies**: Linear chain: Claim1Infrastructure <- DConsistencyAndRankTransport <- InductiveStep <- ForwardToBackward. All depend on EFGames/.

**Key risk**: The "Inductive Step Infrastructure" section (lines 2373-7015, 4643 lines) is the densest block. It consists of `obtain_split_point_props` (a single giant theorem) and supporting lemmas. Splitting within it requires careful analysis of which private defs are used where. The CaseAnalysis sections (Case I: 1137 lines, Case II: 1429 lines) are self-contained within the inductive step.

### 2.3 Hierarchy.lean (3845 lines) -- PRIORITY 2

**Current structure**: GHR94 Lemmas 10.2.5-10.2.8 for the separation hierarchy, organized by induction level.

**Proposed split into 3 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Separation/HierarchyDefs.lean` | ~700 | Single U/S-type predicates, Lemma 10.2.5 (single-U separability), U/S-formula abstraction, semantic correctness, preservation lemmas, count properties, junction-depth monotonicity (lines 31-820) |
| `Separation/HierarchyInduction.lean` | ~1600 | Hierarchy theorem steps 1-5b: substitution preservation, strict count decrease, count_U_total lemmas, substitution into separated formulas, S-nesting depth measure, U-nesting depth measure, callback infrastructure (lines 821-2240) |
| `Separation/HierarchyCompletion.lean` | ~1600 | Steps 5c-5d and JD infrastructure: separable_with_U_type strengthening, combinators, Cases 5-8 with U-type preservation, single-U-type separability (axiom-free), GHR94 Lemma 10.2.6/10.2.7, oracle threading, all_formulas_separable (lines 2241-3845) |

**Internal dependencies**: HierarchyDefs <- HierarchyInduction <- HierarchyCompletion (linear chain).

**Key risk**: Low. The file has clear section boundaries aligned with GHR94 lemma numbering.

### 2.4 SoundnessLemmas.lean (2407 lines) -- PRIORITY 2

**Current structure**: Three parallel blocks of axiom validity proofs for different frame classes (Dense, General/Base, Discrete), plus rule preservation and combined theorems.

**Proposed split into 3 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `SoundnessLemmas/SwapValidity.lean` | ~800 | Swap validity infrastructure, individual swap axiom proofs, rule preservation for swap, axiom_swap_valid master theorem (lines 7-815) |
| `SoundnessLemmas/LocalValidity.lean` | ~650 | Axiom validity (local), rule preservation for local validity, combined soundness theorems, extracted theorems (lines 816-1459) |
| `SoundnessLemmas/FrameClassVersions.lean` | ~950 | General (frame-class-free) versions, discrete frame versions (lines 1460-2407) |

**Internal dependencies**: SwapValidity <- LocalValidity <- FrameClassVersions (linear).

**Key risk**: Low. Task 168 already collapsed the 4 near-duplicate frame-class blocks (the description mentions this). The remaining structure has clear section boundaries.

### 2.5 DedekindZ.lean (2236 lines) -- PRIORITY 3

**Current structure**: GHR94 Section 10.3 specialization to integer time -- Q-lemma, Case 3 equivalence, Cases 5-8 separability.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Separation/DedekindZDefs.lean` | ~700 | K+/K-/Gamma definitions, triviality on Z, Q-lemma (fwd/bwd), Q_Z syntactic properties, Case 3 equivalence, helper lemmas for Cases 5-8, replace U with True/False infrastructure, congruence lemmas (lines 5-983) |
| `Separation/DedekindZCases.lean` | ~1250 | Cases 5-8 separability proofs (Case 5, Case 6 infrastructure + direct formula, Case 7, Case 8) (lines 984-2236) |

**Internal dependencies**: DedekindZDefs <- DedekindZCases (linear).

**Key risk**: Low. Cases are well-separated. Case 6 alone is 664 lines but is a single continuous proof.

### 2.6 ExpressiveCompleteness.lean (2129 lines) -- PRIORITY 3

**Current structure**: FO-to-temporal translation, purity lemmas, quantifier elimination, atom elimination, core expressiveness lemma, final theorem.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `ExpressiveCompleteness/Infrastructure.lean` | ~850 | FO-to-Temporal infrastructure, purity semantic lemmas, substitution under purity, extended signature, quantifier elimination, atom elimination infrastructure, QE correctness, atom membership, guard formulas (lines 4-894) |
| `ExpressiveCompleteness/MainTheorem.lean` | ~1300 | Atom containment lemmas (899 lines of casework), core expressiveness lemma, final Theorem 10.2.10 (lines 895-2129) |

**Internal dependencies**: Infrastructure <- MainTheorem (linear).

**Key risk**: The "Atom Containment Lemmas" section is 899 lines of dense casework. It could be a separate file, but it feeds directly into the core expressiveness lemma.

### 2.7 SubformulaClosure.lean (1889 lines) -- PRIORITY 3

**Current structure**: Subformula closure, closure with negations, diamond detection, nesting depth, deferral closure, seriality formulas, temporal blocking set, deferral closure structural lemmas.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Syntax/SubformulaClosure.lean` | ~770 | Subformula closure as Finset, closure with negations, diamond detection/subformulas, subformula membership lemmas, F/P-nesting depth, max depth in closure, F/P inner formula extraction (lines 7-772) |
| `Syntax/DeferralClosure.lean` | ~1120 | Deferral closure definitions, Until/Since deferral infrastructure, seriality formulas, temporal blocking set, F/P-depth bounding for deferral closure, structural lemmas for DeferralClosure (lines 773-1889) |

**Internal dependencies**: SubformulaClosure <- DeferralClosure (linear).

**External impact**: 10 files import SubformulaClosure. The deferral closure material is only used by the MCS/decidability files, not by all 10 importers. Splitting cleanly reduces unnecessary transitive imports.

**Key risk**: Low. Natural split point at the "Temporal Blocking Set" section.

### 2.8 IntegerModel.lean (1816 lines) -- PRIORITY 4

**Current structure**: Z-interval structures, good structures, succ-iteration, transitivity helpers (Reynolds Lemma 17), contemporaneous equivalence, one-class theorem, very good -> good (Lemma 16), chronicle is good.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `IntegerModel/Defs.lean` | ~900 | Z-interval structures, good structures, succ-iteration, transitivity helpers, contemporaneous equivalence, no gaps in discrete orders, one-class theorem (lines 7-928) |
| `IntegerModel/GoodConstruction.lean` | ~900 | Very good -> good (Lemma 16), half-open partition, shift-and-glue helpers, chronicle is good (lines 929-1816) |

**Internal dependencies**: Defs <- GoodConstruction (linear).

**Key risk**: Low. Clean split at the "Very Good -> Good" boundary.

### 2.9 Propositional.lean (1704 lines) -- PRIORITY 4

**Current structure**: Propositional proof combinators in 5 phases.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Theorems/PropositionalCore.lean` | ~1000 | Helper lemmas, axiomatic helpers, derived classical principles, Phase 1 (propositional foundations: ecq, raa, efq, ldi, rdi, rcp, lce, rce), Phase 3 (context manipulation: classical_merge, iff_intro, iff_elim) (lines 6-1064) |
| `Theorems/PropositionalDeMorgan.lean` | ~700 | Phase 4 (De Morgan laws), biconditional manipulation, Phase 5 (natural deduction rules: ni, ne, bi_imp) (lines 1065-1704) |

**Internal dependencies**: PropositionalCore <- PropositionalDeMorgan (linear).

**External impact**: HIGH -- 19 files import Propositional.lean. However, most importers only use the Phase 1 foundations (ecq, raa, efq, ldi, rdi, lce, rce). Splitting means most importers only need PropositionalCore, reducing transitive imports.

**Key risk**: Low. The phases are well-defined.

### 2.10 RestrictedMCS.lean (1407 lines) -- PRIORITY 5

**Current structure**: Closure-restricted MCS, Lindenbaum construction, bounded iteration, then deferral-restricted MCS (parallel structure).

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Core/RestrictedMCS.lean` | ~650 | RestrictedConsistent/RestrictedMCS definitions, basic properties, negation completeness, Lindenbaum, constructing MCS from formula, iter_F/P boundedness (lines 9-651) |
| `Core/DeferralRestrictedMCS.lean` | ~760 | DeferralRestricted* definitions, negation completeness, iter_F/P boundedness, closure under derivation, implication property, theorem_in_drm, G_neg lemma (lines 652-1407) |

**Internal dependencies**: RestrictedMCS <- DeferralRestrictedMCS (linear).

**Key risk**: Low. Clean split between the two MCS variants.

### 2.11 ProofSearch.lean (1388 lines) -- PRIORITY 5

**Current structure**: Computable proof search with heuristics, bounded search, IDDFS, best-first search, learning-enabled search.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Automation/ProofSearch/Core.lean` | ~750 | Types, helper functions, heuristics, bounded search, matchDerived, bounded_search_with_proof, iddfs_search (lines 8-1016) |
| `Automation/ProofSearch/Advanced.lean` | ~640 | Best-first search, search strategy configuration, learning-enabled search, batch search (lines 1017-1388) |

**Internal dependencies**: Core <- Advanced (linear).

**Key risk**: Low. The SearchNode/PriorityQueue boundary is a natural split point.

### 2.12 Tactics.lean (1342 lines) -- PRIORITY 5

**Current structure**: Macro tactics, meta-level tactics, formula helpers, search config, main tactic definitions, tests.

**Proposed split into 2 files**:

| New File | Lines | Contents |
|----------|------:|----------|
| `Automation/TacticHelpers.lean` | ~860 | Basic macros (apply_axiom, modal_t), assumption_search, formula helpers (is_box, extract_from_box, etc.), tactic factory, inference rule tactics, axiom tactics, core search implementation (extractDerivationGoal, tryAxiomMatch, tryModusPonens, tryModalK, tryTemporalK) (lines 6-865) |
| `Automation/TacticMain.lean` | ~480 | SearchConfig, main tactic definitions (modal_search, temporal_search, propositional_search, tm_auto), tests (lines 866-1342) |

**Internal dependencies**: TacticHelpers <- TacticMain (linear).

**Key risk**: Low. Tests at the end of the file should move to a separate test file or remain with TacticMain.

## 3. Import Impact Analysis

| File | Current Importers | Split Impact |
|------|------------------:|:-------------|
| EFGames.lean | 3 | WeakCanonical.lean, EFGameTactics.lean, ExpressivenessGeneral.lean need new import paths |
| ExpressivenessGeneral.lean | 1 | WeakCanonical.lean only |
| Hierarchy.lean | 2 | Separation.lean, SeparationThm.lean |
| SoundnessLemmas.lean | 3 | Metalogic.lean, Soundness.lean, SoundnessLemmas.lean (self-import via sections) |
| DedekindZ.lean | 2 | Hierarchy.lean, NormalForm.lean (Separation/) |
| ExpressiveCompleteness.lean | 0 | No downstream importers -- safest to split |
| SubformulaClosure.lean | 10 | Syntax.lean, BXCanonical.lean, EnrichedClosure.lean, RestrictedMCS.lean, RestrictedParametricTruthLemma.lean, SuccExistence.lean, HintikkaPoint.lean, CanonicalTaskRelation.lean, ClosureMCS.lean, TemporalCoherence.lean |
| IntegerModel.lean | (check below) | Likely few importers |
| Propositional.lean | 19 | HIGHEST IMPACT -- 19 files across Theorems/, Metalogic/, many deep consumers |
| RestrictedMCS.lean | 2 | Core.lean, ClosureMCS.lean |
| ProofSearch.lean | 2 | Automation.lean, Closure.lean |
| Tactics.lean | 1 | Automation.lean only |

**Mitigation strategy for high-impact splits**: For files with many importers (Propositional, SubformulaClosure), create a re-export aggregator file that imports all split pieces and re-exports them. Existing importers initially import the aggregator (no change), then can be migrated to import only what they need.

## 4. Recommended Execution Order

### Wave 1: Zero-Importer and Low-Risk Splits (parallel)

| File | Importers | Est. Effort | Rationale |
|------|----------:|:-----------:|-----------|
| ExpressiveCompleteness.lean | 0 | 2h | Zero importers, clean sections |
| Tactics.lean | 1 | 1.5h | Only Automation.lean imports it |
| ProofSearch.lean | 2 | 1.5h | Clean split point, minimal importers |
| RestrictedMCS.lean | 2 | 1.5h | Clean split, minimal importers |

**Estimated wave effort**: 6.5h (parallelizable to ~3h)

### Wave 2: Medium-Impact Splits (parallel)

| File | Importers | Est. Effort | Rationale |
|------|----------:|:-----------:|-----------|
| SoundnessLemmas.lean | 3 | 2h | Clear section boundaries |
| DedekindZ.lean | 2 | 2h | Clean case-by-case split |
| IntegerModel.lean | ~2 | 2h | Clean boundary at Lemma 16 |

**Estimated wave effort**: 6h (parallelizable to ~3h)

### Wave 3: Separation Module (sequential)

| File | Importers | Est. Effort | Rationale |
|------|----------:|:-----------:|-----------|
| Hierarchy.lean | 2 | 3h | 3-file split, clear GHR94 boundaries |

**Estimated wave effort**: 3h

### Wave 4: High-Impact Splits (sequential, careful)

| File | Importers | Est. Effort | Rationale |
|------|----------:|:-----------:|-----------|
| SubformulaClosure.lean | 10 | 3h | Many importers, needs aggregator |
| Propositional.lean | 19 | 4h | Most importers, needs careful aggregator |

**Estimated wave effort**: 7h

### Wave 5: The Giants (sequential)

| File | Importers | Est. Effort | Rationale |
|------|----------:|:-----------:|-----------|
| EFGames.lean | 3 | 6h | 10K lines into 6 files, complex dependencies |
| ExpressivenessGeneral.lean | 1 | 5h | 10K lines into 4 files, but only 1 importer |

**Estimated wave effort**: 11h

**Total estimated effort**: ~33.5h across 5 waves

## 5. Risk Assessment

### High Risk

| File | Risk | Mitigation |
|------|------|------------|
| EFGames.lean | Dense internal dependencies between gap detection, rank embedding, and game mechanics. Many `private` defs that become cross-file. | Map all private def usages before splitting. Convert necessary privates to non-private. |
| ExpressivenessGeneral.lean | 4643-line "Inductive Step Infrastructure" block. `obtain_split_point_props` is a single massive theorem with many supporting private defs. | May need to keep InductiveStep as one file (still better than 10K). Split Cases I-IV out. |

### Medium Risk

| File | Risk | Mitigation |
|------|------|------------|
| Propositional.lean | 19 importers need updating | Use aggregator re-export pattern |
| SubformulaClosure.lean | 10 importers, some depend on deferral closure specifically | Use aggregator; audit which importers need DeferralClosure |
| Hierarchy.lean | Deep inductive proofs may reference earlier sections | Map theorem-to-theorem dependencies within file |

### Low Risk

| File | Risk | Mitigation |
|------|------|------------|
| ExpressiveCompleteness.lean | None -- 0 importers | Straightforward |
| SoundnessLemmas.lean | Clear frame-class boundaries | Simple linear split |
| DedekindZ.lean | Cases are independent | Clean case split |
| IntegerModel.lean | Clean section boundaries | Straightforward |
| Tactics.lean | Tests at end | Move tests to TacticMain |
| ProofSearch.lean | Clean architecture | Simple split |
| RestrictedMCS.lean | Parallel structure | Split on the parallel boundary |

## 6. Build Parallelism Impact

Current build graph has two massive bottlenecks:
- **EFGames.lean (10170 lines)**: Blocks ExpressivenessGeneral.lean (9988 lines) and EFGameTactics.lean
- **ExpressivenessGeneral.lean**: Blocks WeakCanonical.lean aggregator

After splitting:
- EFGames/ splits into ~6 files that can partially compile in parallel (Defs compiles first, then RankEmbedding and GameMechanics in parallel, then GapDetection, etc.)
- ExpressivenessGeneral/ splits into 4 files in a linear chain, but each is ~1/4 the size, so individual recompilation after edits is much faster
- SubformulaClosure split helps because most files only need the base closure, not the deferral closure
- SoundnessLemmas split helps because Soundness.lean only needs the master theorem, not the individual axiom validity proofs

**Estimated build time reduction**: The two 10K files currently dominate incremental build times. Splitting them means a change to a Case II proof (1429 lines) only recompiles that module and its dependents, not the entire 10K file. Conservative estimate: 30-50% reduction in typical incremental build times for the WeakCanonical directory.

## 7. Files NOT Recommended for Splitting

| File | Lines | Reason |
|------|------:|--------|
| Soundness.lean | 1355 | Below 1500 threshold; could be combined with SoundnessLemmas split files instead |
| NEquivalence.lean | 1227 | Below threshold |
| SuccExistence.lean | 1172 | Below threshold |
| UltrafilterMCS.lean | 1053 | Below threshold |
| CanonicalTaskRelation.lean | 1043 | Below threshold |

## 8. Module Naming Conventions

For subdirectory splits, use this pattern:
- **Single file becomes directory**: `Foo.lean` -> `Foo/Defs.lean`, `Foo/Bar.lean`, `Foo.lean` (aggregator)
- **Aggregator pattern**: The original filename becomes a lean file that imports all split pieces:
  ```lean
  -- Foo.lean (aggregator)
  import Foo.Defs
  import Foo.Bar
  import Foo.Baz
  ```
- This ensures existing `import Foo` statements continue to work unchanged.

**Naming choices per file**:
- `EFGames.lean` -> `EFGames/` directory (6 files) + `EFGames.lean` aggregator
- `ExpressivenessGeneral.lean` -> `Expressiveness/` directory (4 files) + rename aggregator
- `Hierarchy.lean` -> `Separation/Hierarchy/` directory (3 files) + `Hierarchy.lean` aggregator
- `SoundnessLemmas.lean` -> `SoundnessLemmas/` directory (3 files) + `SoundnessLemmas.lean` aggregator
- `SubformulaClosure.lean` -> `SubformulaClosure.lean` (keep) + new `DeferralClosure.lean` (extracted)
- `Propositional.lean` -> `Propositional/` directory (2 files) + `Propositional.lean` aggregator

## 9. Pre-Split Checklist (Per File)

Before splitting each file:

1. [ ] Identify all `private` definitions and which are cross-section
2. [ ] Map theorem-to-theorem internal dependencies
3. [ ] Count `open` declarations and determine scope per split file
4. [ ] Verify all importers with `grep -rl "import.*FileName"`
5. [ ] Create aggregator file first, verify `lake build` passes
6. [ ] Move sections to new files one at a time, building between moves
7. [ ] Add module docstrings to each new file
8. [ ] Final `lake build` verification
