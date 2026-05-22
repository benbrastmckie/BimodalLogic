# Research Report: Task #196

**Task**: Codebase-wide tactic opportunity survey
**Date**: 2026-05-22
**Mode**: Team Research (4 teammates)

## Summary

Four teammates surveyed 92K lines of active Lean 4 source across 149 files in `Theories/Bimodal/`. The survey identified 11 distinct pattern groups totaling ~3,500-5,000 lines of potential savings, plus several strategic findings that challenge the existing task roadmap (185-193).

The single most important finding is structural, not tactical: **the existing 3,500 lines of automation infrastructure have near-zero adoption** (3 uses of `modal_search`, all in Examples/), and the current 8-phase tactic pipeline (tasks 185-193, estimated 90-115 hours) risks producing another unused system. The survey recommends reorienting the tactic effort around three priorities: (1) completing EF game automation for sorry reduction, (2) registering domain-specific simp sets and macros for immediate wins, and (3) diagnosing non-adoption before building more elaborate infrastructure.

## Key Findings

### Tier 1: Immediate Wins (no dependencies, trivial complexity)

#### 1. Validity Intro Boilerplate — `intros_validity` macro

The single highest-frequency verbatim repetition in the codebase. The intro pattern `intro F M Omega _h_sc τ _h_mem t` appears **224+ times** across 4 files (SoundnessLemmas.lean: 132, Soundness.lean: 39, Validity.lean: 53). A pair of one-line macros eliminates all of them.

- **Occurrences**: 224+ (exact grep count)
- **Lines saved**: ~220 (1 line per occurrence)
- **Complexity**: trivial (pure syntactic macro)
- **Files**: SoundnessLemmas.lean, Soundness.lean, Validity.lean, FrameConditions/Validity.lean
- **Proposed**:
  ```lean
  macro "intros_validity" : tactic := `(tactic| intro F M Omega _h_sc τ _h_mem t)
  macro "intros_validity_framed" : tactic := `(tactic| intro _ _ _ _ _ F M Omega _h_sc τ _h_mem t)
  ```

#### 2. Truth Evaluation Simp Sets — `simp_truth` macro family

The combination `[truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` appears as an identical 5-lemma `simp only` call **43 times** in Soundness.lean alone. Sub-patterns (`[truth_at]` alone: 51x; `[Formula.swap_temporal, truth_at]`: 25x; `[Formula.and, Formula.neg, truth_at]`: 18x) bring the total to **168 simp calls** that could use named macros.

- **Occurrences**: 168 (primary bundle: 43 exact matches)
- **Lines saved**: ~85 (readability gain; many already single-line)
- **Complexity**: trivial (macro definitions)
- **Proposed bundles**: `simp_truth` (43x), `simp_swap_temporal` (25x), `simp_truth_formula` (18x)
- **Note**: Adding `@[simp]` to `truth_at` itself risks simp loops since it's a recursive definition. Named macros are safer.

#### 3. Subformulas Simp Set — `simp_subformulas` macro

`simp only [subformulas, List.mem_cons, List.mem_append]` appears **26 times** identically in 2 files.

- **Complexity**: trivial
- **Lines saved**: minor (readability)

#### 4. `push_neg` Migration

`simp only [not_and, Classical.not_not]` appears **20 times** identically in EFGames.lean. `push_neg at this` is the direct Mathlib replacement — more idiomatic, handles a broader class of negation rewrites.

- **Complexity**: trivial (drop-in replacement)

### Tier 2: High-Impact Patterns (moderate complexity, significant savings)

#### 5. MCS Axiom Application — `mcs_apply` tactic

The three-step pattern of (a) constructing `DerivationTree.axiom [] _ (Axiom.X ...)`, (b) lifting via `theorem_in_mcs`, (c) applying via `implication_property` dominates BXCanonical/ files. **313+ `theorem_in_mcs` calls** across 7 files, with the heaviest concentration in PointInsertion.lean (63), RRelation.lean (45), and ChronicleToCountermodel.lean (34).

- **Occurrences**: 313+ (exact grep)
- **Lines saved**: ~600 (3 lines × 200 distinct patterns)
- **Complexity**: medium (elab tactic that inspects goal formula and chains the three steps)
- **Caveat**: These files are in BXCanonical/ which is not on the current sorry-reduction critical path (WeakCanonical/ is). ROI depends on whether BXCanonical/ will be activated post-168.

#### 6. Formula Structural Induction — `formula_induct_simp`

In Separation/Hierarchy.lean (38 inductions), TemporalClosure.lean (22), SubformulaClosure.lean (~20), and other files, **167 formula inductions** follow a stereotyped per-case pattern: `simp [defn] at h; simp [defn, ih h.1, ih h.2]` for each Formula constructor. If 50% of cases can be auto-dispatched via `simp [*]; try omega`, savings are **~1,500-2,000 lines**.

- **Occurrences**: 167 inductions, ~714 case lines
- **Lines saved**: ~1,500-2,000 (if half auto-closable)
- **Complexity**: medium-high (needs `@[simp]`-completeness audit for formula predicates)
- **Note**: Hierarchy.lean (3,845 lines) was overlooked in all prior reports (Teammate C finding). Also has 262 simp-heavy lines with `abstract_untl`/`abstract_snce` patterns.

#### 7. Validity Intro + Truth Simp Combined — `unfold_validity`

Combining patterns 1 and 2 into a single `unfold_validity` macro that does both the intro and the simp would replace the most common 2-line boilerplate in Soundness/SoundnessLemmas files with a single tactic call.

- **Occurrences**: ~100 combined (where both appear consecutively)
- **Lines saved**: ~200 (2 lines × 100)
- **Complexity**: trivial (compose existing macros)

### Tier 3: EF Game Automation (critical path, sorry-reducing)

#### 8. Complete Task 195 Component A — `same_order_type_grid`

The `same_order_type_grid` macro exists but was **never validated against actual sorry sites**. The 2 BLOCKED sorries in ExpressivenessGeneral.lean at lines ~3199/3404 (task 155 Phase 1) are directly addressable by this component. Each `same_order_type` proof is 100-220 lines that would compress to 1-3 lines.

- **Lines saved**: ~600-1,300 (6+ proof blocks)
- **Complexity**: medium (macro already exists; needs application and debugging)
- **Sorry impact**: potentially closes 2 executable sorries on the bx_completeness critical path
- **Status**: Teammate C identified this as the highest-ROI action currently pending

#### 9. `pivot_order` Context-Search Elab Tactic

63 `pivot_chain_order'`/`pivot_chain_order_rev'` calls with explicit bound arguments in ExpressivenessGeneral.lean. The deferred elab tactic (~100 lines of metaprogramming) would auto-discover arguments from local context, eliminating all manual argument assembly.

- **Occurrences**: 63 call sites
- **Lines saved**: ~130-195
- **Complexity**: medium-high (getLCtx, isDefEq matching)
- **Dependencies**: Task 195 Components B/C already done

#### 10. `winning_condition_tac` — Automated index split

Automates the 4-way `game_tuple` index split used in `formula_agreement`, `gap_point_agreement`, and `same_order_type` proofs. Takes sub-game winning conditions as arguments and dispatches each index category.

- **Lines saved**: ~350-700
- **Complexity**: medium

### Tier 4: Infrastructure-Dependent (requires prior tasks)

#### 11. DerivationTree.modus_ponens Assembly — `modal_search` adoption

451 manual `DerivationTree.modus_ponens` calls, 450 `weakening`/`assumption` calls. If 40% can be replaced by `modal_search`, savings ≈ ~540 lines. But `modal_search` currently has **3 uses total** (all in Examples/).

- **Depends on**: Task 185 (extend axiom coverage), then task 193 (adoption)
- **Note**: Adoption problem must be diagnosed first (see Strategic Findings)

#### 12. imp_trans Chains

180 `imp_trans` calls in Theorems/. These are combinator-chain proofs that `modal_search` could close with a backward-chaining lemma database.

- **Depends on**: Tasks 185, 187

#### 13. Deduction Theorem Boilerplate

143 `deduction_theorem` calls. Task 189 addresses this directly.

- **Depends on**: Task 189

## Strategic Findings

### 1. Existing Automation Has a Non-Adoption Problem

The 3,500 lines of `Automation/Tactics.lean` (1,317 lines) + `ProofSearch.lean` (1,384 lines) have **zero adoption** in real proofs — `modal_search` has 3 uses, all in Examples/. Before building the 185-192 pipeline (90-115 hours), the survey should diagnose why: (a) proofs predate tactics (ordering), (b) tactics aren't ergonomic enough, (c) no documentation, or (d) tactics don't match actual proof shapes in Metalogic/ (78% of codebase). Without this diagnosis, more infrastructure risks the same fate.

### 2. The Wrong Layer Is Being Targeted

Tasks 185-192 target `Theorems/` (6,450 lines, 8% of codebase) — proofs that are **sorry-free, stable (zero changes in 200 commits), and already complete**. The high-value automation opportunities are in `Metalogic/WeakCanonical/` (32,656 lines, 50 active sorries on the critical path). The survey finds that EF game tactics directly attack sorry sites, while Theorems/ tactics produce cosmetic compression. Recommend weighting opportunities by `(frequency × sorry_impact)`, not just `(frequency × line_savings)`.

### 3. Dependency Chain Errors in Tasks 185-193

Three structural problems identified:

1. **Task 189** (deduction theorem tactic) doesn't depend on 185 — it's self-contained using existing `Core/DeductionTheorem.lean`
2. **Task 191** (propositional decision) can be built independently — the 185 dependency is artificial
3. **Task 193** is missing a dependency on 189 — `tm_prove` needs the deduction theorem for Theorems/ proofs
4. **Task 194** (Nonempty→Derivable) is orphaned — nothing depends on it despite being a prerequisite for 192's Prop-level dispatch

**Recommended restructuring** into parallel streams:
```
Stream 1 (EF game — immediate, sorry-reducing):
  195-completion → validate Component A against task 155 sorries

Stream 2 (simp sets + macros — no dependencies):
  intros_validity, simp_truth, simp_subformulas, push_neg migration

Stream 3 (DerivationTree automation):
  185 → 186, 187, 189 (parallel) → 188 → 192 → 193

Stream 4 (Prop-level migration):
  181 (done) → 194 → 192 (Prop dispatch path)
```

Streams 1, 2, and 4 can proceed immediately without waiting for Stream 3.

### 4. Survey Timing vs. Task 168

Task 196 depends on "155, 161" but not 168 (FrameClass parameterization). Since 168 changes `DerivationTree` type signatures, tactics built before 168 that touch `DerivationTree` will need updating. However, patterns in Tier 1-2 (macros, simp sets, formula induction) are **168-safe** — they don't touch `DerivationTree`. EF game tactics (Tier 3) are also likely 168-safe since they operate on `LinearOrder`/`game_tuple` structures, not derivation trees.

**Recommendation**: The Tier 1-3 patterns can be implemented before 168. Only Tier 4 patterns (DerivationTree automation, tasks 185-193) should wait for post-168 stability.

### 5. Sorry Triage

Of ~41 executable sorries in the active codebase:
- **2** are proof-engineering problems resolvable by task 195 Component A
- **6-8** are mathematical blockers (strategy restriction, infimum construction)
- **4** are blocked on task 117 (BXCanonical architectural fix)
- **~15-20** are infrastructure-propagated (resolve when upstream clears)
- **~10-12** are unanalyzed

**Tactics cannot help with the majority of active sorries.** The critical path runs through completing task 155's Phase 1, then Phases 3-6 (mathematical construction), not tactic engineering.

### 6. SoundnessLemmas.lean and Hierarchy.lean Were Overlooked

Two large files were absent from all prior research:
- **SoundnessLemmas.lean** (2,389 lines): 79 `simp only [truth_at, ...]` patterns — strong candidate for `@[tm_sem]` simp attribute set
- **Separation/Hierarchy.lean** (3,845 lines): 262 simp-heavy lines with `abstract_untl`/`abstract_snce` — candidate for `@[separation_norm]` simp set

### 7. `tauto` Audit Opportunity

545 `by_contra` + 454 `by_cases` calls with **zero `tauto` uses** anywhere in the codebase. Many propositional goals may be closable with `tauto` directly — an audit would identify quick wins.

## Conflicts Resolved

### Conflict 1: MCS Pattern Priority vs. Critical Path Relevance

Teammate A ranks MCS axiom application as #1 by occurrence count (313+ call sites). Teammate D argues BXCanonical/ files are "not on the critical path" (WeakCanonical/ is where the sorries are). **Resolution**: The MCS pattern is genuine and high-frequency, but BXCanonical/ is stable code that's not actively blocking sorry elimination. Rank it as Tier 2 (high impact but not urgent) rather than Tier 1 (immediate wins). If the BXCanonical path is reactivated post-168, this becomes Tier 1.

### Conflict 2: Task 195 Completion Status

Teammate A treats task 195 as partially complete (Components B, C, D done; A pending). Teammate C flags that task 195 is marked [COMPLETED] in state.json but its core goal — closing the same_order_type sorries — was deferred. **Resolution**: Teammate C is correct on the facts. The task created the tactic infrastructure but did not validate Component A against the actual BLOCKED sorry sites. The synthesis adopts C's framing: task 195 Component A needs completion and validation as the highest-ROI action.

### Conflict 3: Survey Timing

Teammate D argues the survey should wait until after task 168. Teammates A and B focus on current patterns without raising timing concerns. **Resolution**: Tier 1-3 patterns are 168-safe (they don't touch DerivationTree). The survey output is valid for immediate implementation of these patterns. Only Tier 4 (DerivationTree automation, tasks 185-193) should be flagged as potentially requiring revision post-168.

## Gaps Identified

1. **Build time profiling**: No data on compilation times. If simp sets like `@[tm_sem]` (79 lemmas) slow compilation, the tactics could make the codebase harder to work with. Needs `lean_profile_proof` benchmarking.

2. **Publication target**: The project's publication goals are under-specified. "Publication-ready" means different things for a companion formalization vs. a standalone ITP/CPP paper. The tactic effort should be scoped differently depending on the target.

3. **Boneyard relevance**: 31 files with sorries in Boneyard/ (~56K lines). If any are candidates for activation post-168, their patterns should inform the survey.

4. **Automation testing**: The existing 1,317 lines of Tactics.lean and 1,384 lines of ProofSearch.lean have no test files. Building more automation on untested infrastructure carries risk.

5. **Stavi formula induction**: 379 `stavi_temporal_truth_mu` occurrences and 46 depth-bounded quantifications in EF game files. Teammate A identifies this as a pattern group but no other teammate assessed its tactic-feasibility.

## Recommended Task Structure

### Immediate Actions (before any new tasks)

1. **Complete task 195 Component A validation**: Apply `same_order_type_grid` to the 2 BLOCKED sorries in task 155 at ExpressivenessGeneral.lean lines ~3199/3404. This is the single highest-ROI action.

### New Task Proposals

**Task A: Soundness/Validity Macro Bundle** (Tier 1)
- Implement `intros_validity`, `intros_validity_framed`, `simp_truth`, `simp_swap_temporal`, `simp_subformulas`, `unfold_validity`
- Apply to SoundnessLemmas.lean, Soundness.lean, Validity.lean
- Effort: small (2-4 hours)
- Dependencies: none
- Lines saved: ~300-400

**Task B: Separation Simp Sets** (Tier 1-2)
- Register `@[separation_norm]` simp attribute set for `abstract_untl`, `abstract_snce`, `int_truth`, related lemmas
- Apply to Hierarchy.lean, TemporalClosure.lean, ExpressiveCompleteness.lean
- Effort: small (2-4 hours)
- Dependencies: none
- Lines saved: ~100-200

**Task C: Formula Induction Automation** (Tier 2)
- Audit `@[simp]` coverage for `is_U_free`, `is_S_free`, `count_U_subformulas`, `junction_depth` and related predicates
- Create `formula_induct_simp` tactic or demonstrate that `all_goals (try simp [*]; try omega)` suffices
- Apply to Hierarchy.lean (38 inductions), TemporalClosure.lean (22), SubformulaClosure.lean (~20)
- Effort: medium (6-8 hours)
- Dependencies: none
- Lines saved: ~1,000-2,000

**Task D: MCS Axiom Application Tactic** (Tier 2)
- Create `mcs_apply` elab tactic wrapping `DerivationTree.axiom [] _ (Axiom.X) → theorem_in_mcs → implication_property`
- Apply to BXCanonical/Chronicle/ files
- Effort: medium (4-6 hours)
- Dependencies: none (but BXCanonical/ is lower priority than WeakCanonical/)
- Lines saved: ~600

**Task E: Complete `pivot_order` Elab Tactic** (Tier 3)
- ~100 lines of metaprogramming: getLCtx, isDefEq, auto-discover arguments
- Apply to 63 call sites in ExpressivenessGeneral.lean
- Effort: small-medium (4-6 hours)
- Dependencies: task 195 Components B/C (done)
- Lines saved: ~130-195

**Task F: `push_neg` + `tauto` Audit** (Tier 1)
- Replace 20 `simp only [not_and, Classical.not_not]` with `push_neg`
- Audit 545 `by_contra` + 454 `by_cases` sites for `tauto` applicability
- Effort: small (2-4 hours)
- Dependencies: none

### Existing Tasks: Keep/Modify/Defer

| Task | Recommendation | Rationale |
|------|---------------|-----------|
| 185 | Keep, but decouple 189 and 191 from it | Genuine prerequisite only for 186 |
| 186 | Keep | Needed for search unification |
| 187 | Keep | Backward chaining enables imp_trans automation |
| 188 | Keep | Depends on 187 |
| 189 | **Modify**: remove 185 dependency | Self-contained using existing DeductionTheorem.lean |
| 190 | Keep | Formula normalization is independently valuable |
| 191 | **Modify**: remove 185 dependency | Can use standalone `decide` on formula syntax |
| 192 | **Modify**: add 194 dependency | Needs Nonempty→Derivable migration for Prop dispatch |
| 193 | **Deprioritize significantly** | Targets stable, sorry-free Theorems/ — cosmetic, not correctness |
| 194 | Keep, add as 192 dependency | Currently orphaned |
| 195 | **Modify**: reopen Component A validation | Core deliverable was deferred |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Unique Findings |
|----------|-------|--------|------------|---------------------|
| A | Primary pattern discovery | completed | high | MCS axiom application (313+), formula induction (167), stavi induction, quantitative file-size reference |
| B | Alternative approaches | completed | high | intros_validity as single most repeated pattern (224+), push_neg migration, tauto audit opportunity, chronicle dite patterns |
| C | Critical analysis | completed | medium-high | Sorry triage (41 executable, most not tactic-resolvable), dependency chain errors, task 195 Component A gap, SoundnessLemmas.lean and Hierarchy.lean overlooked |
| D | Strategic horizons | completed | high (structural), medium (creative) | Non-adoption problem, wrong-layer targeting, survey timing vs 168, EF game tactics as publication, 8-phase pipeline sequencing risk |

## References

- Task 195 research: `specs/195_ef_game_automation_tactics/reports/01_ef-game-tactics.md`
- Task 195 plan: `specs/195_ef_game_automation_tactics/plans/01_ef-game-tactics.md`
- Task 179 research: `specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md`
- Task 179 Mathlib analysis: `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md`
- Task 193 seed: `specs/193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md`
- Task 192 seed: `specs/192_master_tactic_dispatch/reports/01_master-dispatch-seed.md`
