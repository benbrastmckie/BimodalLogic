# Teammate C: Critical Analysis

**Task**: #196 — Codebase-wide tactic opportunity survey
**Date**: 2026-05-22
**Angle**: Gaps, risks, blind spots, assumption validation

---

## Key Findings

### Gap 1: The Line-Savings Estimate Is Directionally Correct But Domain-Misallocated

- **What's being assumed**: The 1200-2500 line savings estimate from the task description and task 193/195 research is achievable and represents meaningful progress. The savings are roughly evenly distributed across EF game infrastructure and Theorems/ directory.
- **Why it might be wrong**: The estimate conflates two fundamentally different domains. The EF game savings (960-1,230 lines across Components A-D in task 195) involve active proof work where the patterns are in ongoing flux — the same_order_type proofs in ExpressivenessGeneral.lean are still partially sorry'd (8 executable sorry calls confirmed by direct grep). The Theorems/ savings (~6,880 lines, "~120 proofs") involve proofs that are ALREADY STABLE AND SORRY-FREE — they haven't changed in any of the last 200 commits tracked by git. Compressing stable sorry-free proofs saves no mathematical work; it only changes proof style.
- **Evidence**: Direct git log analysis shows `Theories/Bimodal/Theorems/` files appear zero times in the last 200 commits. The only non-Boneyard, non-WeakCanonical files that changed recently are in `Automation/` (5 commits) and `ProofSystem/` (3 commits). The EF game files (EFGames.lean: 19 commits, ExpressivenessGeneral.lean: 25 commits) are by far the most actively changed files.
- **Recommendation**: Weight the survey output by "lines saved × (change_frequency + sorry_reduction_impact)" not just "lines saved." The EF game patterns score 20-50x higher on this metric than Theorems/ refactoring.

---

### Gap 2: The Sorry Count Is Significantly Larger Than Documented, With Unclear Tactic Relevance

- **What's being assumed**: The task 195 research document states 12 total sorries across EFGames.lean (4) and ExpressivenessGeneral.lean (8). Task 155's tactic-needs report says "9 remaining sorries" at the time of writing. The survey assumes these are the sorries that matter.
- **Why it might be wrong**: Direct grep analysis of the active codebase (excluding Boneyard) finds **175 sorry instances across 34 files**. The top-sorry files are:
  - ExpressivenessGeneral.lean: 31 (of which 8 are executable `sorry` calls)
  - BXCanonical/Completeness.lean: 23 (of which 4 are executable, on the dense completeness path)
  - WeakCanonical/TruthLemma.lean: 20 (mostly in comment/analysis context)
  - BXCanonical/Chronicle/ChronicleToCountermodel.lean: 18
  - Theorems/Perpetuity/Bridge.lean: 13

  The critical distinction: of the 175 sorry instances, most are in comments, status annotations, and descriptive text — not executable `sorry` tactics. Direct executable sorry count (strict grep) yields approximately 41 executable sorry calls in non-Boneyard files. Of those 41:
  - ~8 are in ExpressivenessGeneral.lean and are blocked on **mathematical issues** (strategy restriction infrastructure, infimum construction, Case 3 gap detection), not proof engineering
  - ~4 are in BXCanonical/Completeness.lean on the dense countermodel path (blocked on density g-value consistency — a mathematical problem)
  - ~7 are in Theorems/Perpetuity/Bridge.lean (partially in comment/plan text)
  - The remaining ~22 are spread across 6+ files in the metalogic pipeline

- **Evidence**: `grep -c "sorry"` on ExpressivenessGeneral.lean returns 31, but `grep -n "^ *sorry$"` returns only 8 executable sorry calls. The same pattern holds throughout the codebase.
- **Recommendation**: The survey must distinguish executable sorry calls from comment mentions. Of the ~41 executable sorries, categorize each as: (a) mathematical blocker — tactics cannot help, (b) proof engineering — tactics can help, (c) infrastructure dependency — sorry propagated from upstream, tactics help only after resolving upstream. Category (b) is the target for tactic investment.

---

### Gap 3: Task 195 Claims COMPLETED but its Core Goal (Closing Same-Order-Type Sorries) Was Deferred

- **What's being assumed**: Task 195 is marked [COMPLETED] in state.json. The implementation summary says "0 sorries in new file," "lake build passes." The task 155 plan shows same_order_type sigma/tau at line ~3199/3404 as "BLOCKED — game_tuple noncomputable."
- **Why it might be wrong**: The plan deviations section of task 195 explicitly states: Phase 5, Task validation was "skipped — existing proof blocks work correctly with current tactics, refactoring deferred." The `same_order_type_grid` macro (Component A) was implemented as a 2-line macro (`intro i j; simp only [game_tuple]; split_ifs`) but was never applied to an actual same_order_type proof block. The core deliverable — resolving the 2 BLOCKED sorries in task 155 at lines ~3199 and ~3404 — was not done.
- **Evidence**: Task 155 plan still shows "Phase 1, Task 1.6 same_order_type (sigma + tau) | BLOCKED | Round 8-9 | game_tuple noncomputable". The sorry at line 3263 in ExpressivenessGeneral.lean has the comment "TODO(Phase 1): Fix compilation — multi_attempt confirms proof works" but the proof is surrounded by a block comment, with `sorry` as the executable statement. The actual `game_tuple_simp` lemmas (Component B) ARE implemented and used, but Component A is a scaffold with no validation.
- **Recommendation**: Before the survey recommends building more tactic infrastructure, the most immediate action is completing the validation of task 195 Component A against the known BLOCKED sorries in task 155. This is the highest-ROI action currently pending and would close 2 real sorries. The survey should explicitly flag this gap.

---

### Gap 4: The Dependency Chain 185-193 Has a Structural Problem That the Survey Is Meant to Fix, But Might Replicate

- **What's being assumed**: The dependency chain 185 → 187 → 188 → 192 → 193 is correct and represents the right sequencing. Task 196 "may generate new tasks and restructure Phases 5a-8."
- **Why it might be wrong**: The dependency chain assumes that `modal_search` extension (185) is a prerequisite for lemma DB (187) which is a prerequisite for weakening-aware search (188) which is a prerequisite for master dispatch (192) which is a prerequisite for codebase refactoring (193). But:
  1. The `Theorems/` proofs that task 193 targets don't use `DerivationTree` tactics at all — they use combinator chains (`imp_trans`, `b_combinator`). `modal_search` is a depth-first tree search over `DerivationTree` goals, which is orthogonal to combinator composition. Task 185 is NOT a prerequisite for simplifying combinator proofs.
  2. Task 191 (propositional decision procedure) is listed as requiring 185 as a prerequisite, but propositional decision can be done independently via `decide` on formula syntax or a standalone checker — the prerequisite is artificial.
  3. Task 194 (migrate Nonempty→Derivable) is listed as [NOT STARTED] but appears to be a prerequisite for task 192's Prop-level dispatch. The dependency is missing from the task list.
  4. Task 181 (Derivable wrapper) is marked [COMPLETED]. Task 192 depends on it, but no downstream task has been marked as depending on 181's completion — creating a gap where 181's work is done but nothing builds on it.
- **Evidence**: Zero uses of `modal_search` in `Theories/Bimodal/Theorems/` files — the tactics and the proof corpus operate in disjoint domains. Grep confirms `modal_search` has 3 uses total in the codebase (all in Examples/).
- **Recommendation**: The survey should map the actual dependency graph from tasks to proof targets. The chain 185→186→187→188 targets DerivationTree automation; this is separate from the chain 190→191→192 targeting Prop-level (Derivable) automation; these are separate from the chain "simp sets + lemma tagging" targeting Theorems/ compression. These three chains can run in parallel, not serially.

---

### Gap 5: The Theorems/ Directory Is Stable and Sorry-Free — Tactic Refactoring Has Low ROI

- **What's being assumed**: Task 193's 40-hour refactoring of Theorems/ (~6,880 lines, ~120 proofs) will save ~2,000-4,000 lines, demonstrating the tactics library as a "product."
- **Why it might be wrong**: The Theorems/ files have NOT been modified in the last 200 commits. They are already complete and sorry-free. Direct measurement:
  - `Theorems/Propositional.lean` (1,712 lines): 1 sorry mention (in a comment), zero executable sorries
  - `Theorems/Combinators.lean` (673 lines): zero sorries
  - `Theorems/Perpetuity/Bridge.lean` (993 lines): 13 sorry mentions but most are in comment/status text
  - `Theorems/TemporalDerived.lean` (366 lines): 3 sorry mentions, likely comment annotations
  
  The actual sorry count in the pure Theorems/ directory is effectively zero for executable proofs. Refactoring these proofs with `modal_search` or `tm_prove` would produce shorter code but would NOT close any sorries and would NOT advance publication.

  More importantly: the existing `Automation/Tactics.lean` (1,317 lines) of tactic infrastructure has ZERO adoption in Theorems/. The proofs were written before the tactics existed, and there is no observable pressure to migrate them. Introducing a new `tm_prove` master tactic (task 192, ~25 hours) without first understanding why the existing tactics weren't adopted risks creating another unused system.
- **Evidence**: Zero tactic calls (`modal_search`, `tm_auto`, `propositional_search`, `temporal_search`) in any of the Theorems/ Lean files. Git history confirms Theorems/ has been stable for the entire observable commit history.
- **Recommendation**: Deprioritize task 193 significantly. If the publication goal is a codebase accompanying a logic paper (the most likely use case), stable sorry-free proofs that compile correctly are already sufficient. Tactic refactoring of Theorems/ should be considered optional documentation work, not a required pre-publication task.

---

### Gap 6: SoundnessLemmas.lean Has High Repetitive Pattern Count That Wasn't Mentioned

- **What's being assumed**: The tactic survey scope is WeakCanonical/ + Theorems/. The seed reports (193 and 192) don't analyze SoundnessLemmas.lean.
- **Why it might be wrong**: `SoundnessLemmas.lean` (2,389 lines) has 79 instances of `simp only [truth_at, ...]` plus an additional 1,000 `simp only`, `intro`, `apply`, and `exact` calls. The file follows a highly repetitive semantic truth unfolding pattern: every axiom validity proof does the same sequence of `intro T _ _ _ _ F M Omega _h_sc τ _h_mem t; simp only [truth_at, Truth.future_iff, Truth.past_iff, ...]; intro h_...`. A custom `tm_truth_setup` tactic that handles this preamble would save 40-60 lines per proof, with ~25-30 axiom validity proofs in the file.
- **Evidence**: Direct examination of `Soundness.lean` lines 106-140 shows the exact repetitive pattern 4 times in 35 lines. The pattern is: (1) `intro T _ _ _ _ F M Omega _h_sc τ _h_mem t`, (2) `simp only [truth_at, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]`, (3) `intro h1 h2 h_phi`, (4) `exact h1 h_phi (h2 h_phi)`. The simp set in step (2) alone appears ~79 times.
- **Recommendation**: Add `SoundnessLemmas.lean` and `Soundness.lean` to the tactic survey scope. A `@[tm_sem]` simp attribute set for truth evaluation lemmas (as proposed in task 179 report) directly addresses this. This is lower-hanging fruit than the EF game automation: it's a simple simp set registration, not an elab tactic.

---

### Gap 7: Hierarchy.lean (3,845 Lines, Sorry-Free) Is Overlooked in All Prior Reports

- **What's being assumed**: The survey targets WeakCanonical/EFGames.lean, WeakCanonical/ExpressivenessGeneral.lean, and Theorems/ as the main candidates. The `Separation/` subdirectory isn't mentioned.
- **Why it might be wrong**: `Separation/Hierarchy.lean` is the 5th-largest file in the codebase (3,845 lines) and has 262 uses of `simp only`, most around `abstract_untl`, `abstract_snce`, `int_truth`, `subst_formula`, and `count_U_subformulas`. This is a highly repetitive pattern. The file is SORRY-FREE, meaning it represents well-structured proofs that could be compressed with domain-specific simp sets. The `abstract_untl`/`abstract_snce` unfolding appears in clusters of 3-5 consecutive simp calls.
- **Evidence**: `grep -c "simp only\|omega\|decide" Separation/Hierarchy.lean` returns 262. Sample lines show `simp only [abstract_untl]` alone appears at least 15+ times. The pattern suggests a `simp_untl` / `simp_snce` abbreviation tactic would compress the file by 100-200 lines.
- **Recommendation**: Include Separation/ in the survey scope. The `abstract_untl`, `abstract_snce`, and `int_truth` simp lemmas appear to be natural candidates for a `@[separation_norm]` simp attribute set.

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Task 195 Component A never applied to actual sorries | HIGH | HIGH — 2 sorries remain blocked in task 155 | Explicitly track Component A validation as part of survey deliverables |
| Tactic infrastructure (185-193) not adopted, like existing Automation/ | MEDIUM-HIGH | HIGH — 90-115 hours wasted | Diagnose adoption barriers in survey; require adoption contract (at least 5 proof blocks refactored per tactic) before marking task complete |
| Survey produces task list for pre-168 architecture that 168 invalidates | MEDIUM | MEDIUM — DerivationTree signature changes could break tactic implementations | Survey team should assess which recommended tactics are 168-safe vs. 168-dependent |
| Large simp sets slow compilation | MEDIUM | MEDIUM — e.g., `simp only [tm_sem]` with 79 lemmas could be slow | Profile first with `lean_profile_proof`; use explicit lemma lists for hot paths |
| Same_order_type tactic (Component A) is too complex to implement reliably | MEDIUM | MEDIUM — two variants (split/no-split) require different case logic | Implement grid-setup + manual dispatch first; full automation is optional enhancement |
| BXCanonical sorries (23 comment-counted, 4 executable) misclassified as tactic opportunities | LOW | MEDIUM — effort spent on mathematical blockers, not engineering | Sort sorries into mathematical vs. engineering categories before tactic design |
| Task dependency graph errors cause blocked work | MEDIUM | MEDIUM — if 185 is incorrectly listed as prereq for 191, both stall unnecessarily | Re-audit dependency graph in survey output |

---

## Dependency Analysis

### Review of Task 185-195 Chain

**What exists**:
- 181 [COMPLETED]: Derivable wrapper — done, but nothing builds on it yet
- 185 [NOT STARTED]: Complete axiom coverage in modal_search
- 186-191 [NOT STARTED]: Various search system improvements
- 192 [NOT STARTED]: Master dispatch tm_prove
- 193 [NOT STARTED]: Codebase refactoring
- 194 [NOT STARTED]: Nonempty → Derivable migration
- 195 [COMPLETED]: EF game tactics (Components B, C, D implemented; A partial)
- 196 [RESEARCHING]: This survey

**Identified structural problems**:

1. **185 is overcoupled**: Task 185 is listed as a dependency for 186, 187, 189, and 192. But the use cases differ:
   - 186 (unify search systems) genuinely needs 185 to align the two search implementations
   - 187 (lemma database) needs 185 only if the lemma DB is indexed by axiom names
   - 189 (deduction theorem tactic) is self-contained and only needs the deduction theorem itself (already in `Core/DeductionTheorem.lean`)
   - 192 (master dispatch) needs 185 only for the `modal_search` dispatch path; the `decide_prop` dispatch path (via 191) is independent

2. **194 is missing from the dependency chain**: Task 192's proposed architecture does `Derivable` → aesop dispatch. This requires `Nonempty → Derivable` migration (task 194) to run first. But 194 is listed without any tasks depending on it.

3. **191 → 192 dependency can be decoupled**: Propositional decision (191) can be built standalone using `decide` on formula syntax trees without needing 185. The 185 dependency is artificial.

4. **193 depends on 192, but 192 won't help with the actual Theorems/ proofs**: `tm_prove` is designed for derivability goals (`⊢ p`). The Theorems/ proofs ARE derivability goals, but they take Lean-level hypotheses (e.g., `imp_trans (h1 : ⊢ A → B) (h2 : ⊢ B → C) : ⊢ A → C`). Using `tm_prove` on these requires integrating the deduction theorem (189), making 193 depend on 189 as well as 192 — but this dependency is missing.

**Recommended restructuring**:
```
Stream 1 (EF game — immediate, high value):
  195-partial → 195-completion (validate Component A against task 155 sorries)

Stream 2 (semantic simp sets — easy wins, no dependencies):
  179-findings → register_simp_attr for tm_sem, separation_norm
  (no prerequisite on 185)

Stream 3 (DerivationTree automation):
  185 → 186, 187, 189 (parallel)
  187 → 188
  185 + 187 + 190 + 191 → 192 → 193

Stream 4 (Prop-level migration):
  181-completed → 194 → 192 (feeds into master dispatch Prop path)
```

Streams 1, 2, and 4 can proceed NOW without waiting for stream 3.

---

## Sorry Analysis

### Total Executable Sorry Count

Direct grep for executable `sorry` calls (not comment mentions): approximately 41 in the active codebase (excluding Boneyard). Distribution:

| File | Executable Sorries | Category | Tactic-Resolvable? |
|------|--------------------|----------|-------------------|
| WeakCanonical/ExpressivenessGeneral.lean | 8 | Mixed: 2 are proof-engineering (same_order_type), 6 are mathematical blockers (strategy restriction infrastructure, Case 3 gap construction, rank-varying induction) | Partially — 2 via task 195 Component A, 6 blocked on upstream math |
| BXCanonical/Completeness.lean | 4 | Mathematical blocker (density g-value consistency) | No — requires task 117 (remove Cantor iso) |
| Theorems/Perpetuity/Bridge.lean | 4 (estimated — 13 text mentions, ~4 executable) | Infrastructure — Bridge.lean propagates sorries from upstream | After upstream resolved |
| WeakCanonical/EFGames.lean | 2 | Mathematical (strategy restriction, game-theoretic proofs) | No — core mathematical work needed |
| Metalogic/Soundness.lean | 4 | Unknown — needs direct inspection | Likely infrastructure-dependent |
| Metalogic/Bundle/SuccRelation.lean | 7 (text count) | Unknown | Likely infrastructure |
| Other | ~17 | Mixed | Unknown |

### Key conclusion on sorries and tactics

Of the ~41 executable sorries, approximately:
- **2** (ExpressivenessGeneral.lean same_order_type sigma/tau) are directly blocked on proof engineering and would be resolved by completing task 195 Component A
- **6-8** (ExpressivenessGeneral.lean other) are blocked on mathematical infrastructure not yet built (strategy restriction, infimum construction for gap case)
- **4** (BXCanonical dense path) are blocked on task 117 (architectural fix to remove Cantor isomorphism)
- **~10-15** are infrastructure-propagated sorries that will resolve when upstream mathematical blockers are cleared
- **~10-12** are in files that haven't been analyzed yet

**Tactics cannot help with the majority of active sorries.** The critical path to sorry-free `bx_completeness` runs through: (1) completing task 155's Phase 1 (which needs Component A from task 195), (2) Phases 3-6 of task 155 (mathematical construction work), and (3) task 117 (BXCanonical architectural fix for dense path). None of these phases are primarily tactic-engineering problems.

---

## Questions Not Being Asked

1. **Why weren't the existing 1,317 lines of Automation/Tactics.lean adopted?** The survey would produce a much better recommendation if it answered this question. The data point (0 uses in Theorems/, 3 uses total) is striking.

2. **What is the build time of the codebase?** No attempt has been made to measure compilation time. If a simp set like `@[tm_sem]` or a `same_order_type_grid` macro introduces a 10-second compilation overhead per invocation (because Lean's simp is slow on large sets), the tactics could make the codebase harder to work with, not easier.

3. **Which sorry sites have been "attempted and failed" vs. "never attempted"?** The task 155 plan mentions proofs where `multi_attempt` confirms the proof works but compilation fails due to `simp_all` behavioral differences. These are proof-engineering problems. There may be other sorries that have never been attempted. The distinction matters for tactic design.

4. **Does the survey account for the Boneyard?** The Boneyard contains 31 files with sorries and ~56,000 lines of code. If ANY of these files are candidates for activation (e.g., by the task 168 structural refactor), their sorry-elimination needs should inform the tactic survey.

5. **Is task 196 generating tasks or recommendations?** The task description says "generates tasks" but also says it might "refine/replace existing tasks 185-195." These are different activities: generating new tasks creates more TODO entries; replacing existing ones requires task management operations. The survey should be explicit about which mode it's operating in.

6. **What is the actual publication target?** Teammate D raises this question (Gap 6). Without a clear answer, the survey cannot prioritize between "cosmetic improvement" (Theorems/ refactoring) and "correctness improvement" (sorry elimination). These have different valuations depending on the publication venue.

7. **Are the existing Automation/ files tested?** The 1,317 lines of Tactics.lean and 1,384 lines of ProofSearch.lean have no test file in `Tests/BimodalTest/`. If the tactics have latent bugs, building more automation on top of them is risky.

---

## Confidence Level

**Medium** overall, with high confidence on specific sub-claims:

- **High confidence**: Task 195 Component A was not validated against actual sorry sites (direct evidence from plan deviations + sorry locations in task 155 plan)
- **High confidence**: Theorems/ has zero tactic adoption and zero sorries (direct grep + git log analysis)
- **High confidence**: 175 text sorry mentions vs. ~41 executable sorry calls — the discrepancy is significant (direct grep)
- **High confidence**: Separation/Hierarchy.lean has 262 simp-heavy lines not mentioned in any prior report
- **Medium confidence**: Dependency chain analysis (some hidden dependencies may not be visible from code inspection alone)
- **Medium confidence**: ROI ranking (sorries × change_frequency metric is derived, not directly measured)
- **Lower confidence**: Build time estimates (no profiling data available; would need `lean_profile_proof` runs to confirm)

The main uncertainty is whether tasks I'm identifying as "mathematical blockers" might be addressable by proof engineering (e.g., a sufficiently clever tactic could handle the `same_order_type` proof variants even for the Case III/IV cases that are still sorry'd). Direct examination of the proof goals would be needed to settle this.
