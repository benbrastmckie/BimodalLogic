# Teammate D: Strategic Horizons

**Task**: #196 — Codebase-wide tactic opportunity survey
**Date**: 2026-05-22
**Angle**: Strategic alignment, long-term vision, sequencing, publication readiness

---

## Key Findings

### Strategic Consideration 1: The Survey Is Arriving at the Wrong Time

- **Current approach**: Task 196 is listed as a Phase 5 prerequisite (after 155 and 161), but it still depends on 161 (rename) which depends on 168 (FrameClass parameterization). This means the survey runs BEFORE the most disruptive structural change in the project.
- **Alternative/enhancement**: Bifurcate the survey. Run a **Phase 1 survey NOW** that focuses only on patterns safe to implement before task 168 (Formula normalization, semantic truth lemmas, EF game automation). Run a **Phase 2 survey AFTER task 168** to capture the full picture with stable DerivationTree signatures. The TODO.md already acknowledges "Note: Task 196 (survey) may generate new tasks and restructure Phases 5a-8. Existing tasks 185-195 are provisional until the survey completes." This note reveals the problem: the survey is positioned as a planning gate for tasks 185-195, but those tasks were created BEFORE 168, meaning the survey validates work designed for an architecture that is about to change.
- **Long-term impact**: A pre-168 survey that generates task roadmaps will be invalidated in Phase 3. The survey should either (a) be narrow (safe patterns only) now, or (b) be deferred to after task 168 so it can reason about the stable post-refactor architecture. Option (b) better maximizes return on investment.

### Strategic Consideration 2: The Tactic Pipeline Has a Usage Adoption Problem, Not a Feature Gap

- **Current approach**: Tasks 185-195 propose an elaborate 4-tier tactic library (modal_search extension → lemma DB → weakening-aware search → deduction theorem tactic → normalization tactic → master dispatch). The survey is meant to validate whether these are the right things to build.
- **Alternative/enhancement**: The task 179 team research established a critical fact: the existing ~3,500 lines of `Automation/` code are essentially unused outside their own directory (`modal_search` has 3 uses, all in Examples; `apply_axiom`, `modal_t`, `tm_auto` have 0 uses in real proofs). Before building a more elaborate pipeline, the survey should diagnose **why the existing tactics were not adopted**. There are four plausible causes: (a) the tactics existed before the proofs were written (ordering problem), (b) the tactics are not ergonomic enough to justify the cognitive overhead, (c) there is no documentation pointing users to the tactics, (d) the tactics do not match the actual proof shapes in Metalogic/ (where 78% of the code lives). The survey should produce a root-cause analysis of non-adoption, not just a feature list.
- **Long-term impact**: Without diagnosing non-adoption, a more elaborate tactic library risks the same fate. The 20-30 hour estimate for the tactic pipeline could produce another 3,500 lines of unused infrastructure.

### Strategic Consideration 3: The Wrong Layer Is Being Automated

- **Current approach**: Tasks 185-192 target `Theorems/` (6,450 lines, 8% of codebase) where the proof patterns are Hilbert-style combinator chains — verbose but comprehensible. The planned tactics are designed for this layer.
- **Alternative/enhancement**: `Metalogic/` is 78% of the codebase (~72K lines). It uses standard Lean tactics (`simp`, `intro`, `obtain`, `cases`, `induction`) not domain-specific patterns. The high-value automation opportunities in Metalogic/ are different from those in Theorems/:
  - **EF game infrastructure** (EFGames.lean: 9,087 lines, 4 active sorries; ExpressivenessGeneral.lean: 4,503 lines, 31 active sorries) — this is the critical path and has already received targeted automation in task 195.
  - **WeakCanonical sorry reduction** — the 50 sorries in WeakCanonical/ are the actual blockers for sorry-free bx_completeness. Tactics that help here have immediate, measurable value.
  - **Context membership boilerplate** — 167 `List.mem_cons` patterns in Metalogic/ are more impactful than any Theorems/ optimization.
  The survey should prioritize patterns by (frequency × impact_on_sorries) × urgency, not by (frequency × line_savings) in the abstract.
- **Long-term impact**: A Metalogic/-focused tactic survey produces automation that directly unblocks sorry elimination. A Theorems/-focused survey produces cosmetic line compression with no impact on correctness.

### Strategic Consideration 4: EF Game Tactics Are the Highest-Leverage Investment and Are Already Partially Done

- **Current approach**: Task 195 built EFGameTactics.lean (208 lines, Components A-D). The file currently only implements Component B (simp_game_tuple) and Component C (pivot_order) stubs. Components A (same_order_type_grid) and D (winning_condition_tac) are the high-impact ones (600-1300 lines and 350-700 lines saved, respectively) and are still to be built.
- **Alternative/enhancement**: The survey should formally recognize that task 195 is a **partial implementation** of the highest-priority tactic cluster. Rather than treating task 196 as designing the EF game tactic from scratch, it should assess: (a) does the 208-line stub from task 195 provide the right API surface, (b) what are the remaining implementation gaps, (c) how many sorries in ExpressivenessGeneral.lean would be closed by the full Components A and D. The 31 active sorries in ExpressivenessGeneral.lean are on the critical path to bx_completeness — automating the grid case dispatch directly attacks the sorry count.
- **Long-term impact**: Completing Components A and D of EFGameTactics.lean is probably the single highest-leverage tactic investment in the project, with direct sorry-reduction impact in the critical path.

### Strategic Consideration 5: The Sequencing Has Task 193 (Codebase Refactor) Structurally Misconceived

- **Current approach**: Task 193 is the "tactics as product" outcome — refactor ALL proofs in Theorems/ using the new automation, producing dramatic line compression. It follows task 192 (master dispatch), creating an 8-phase dependency chain.
- **Alternative/enhancement**: Task 193 is dependent on completing the full tactic library (tasks 185-192), which is estimated at 90-115 hours of work AFTER the structural refactor. But task 193's actual output is Theorems/ being shorter — which is aesthetically nice for publication but not a correctness or completeness gate. The risk is that tasks 185-193 consume enormous effort for cosmetic improvement, while the real publication blockers (sorry-free completeness, documentation, structural refactor) are more urgent. A lighter-weight alternative: instead of building all 8 tactic tiers and then refactoring, add `@[simp]` annotations and helper lemmas opportunistically during the structural refactor itself (tasks 168-175). This collapses the "design then implement then refactor" pipeline into a single pass.
- **Long-term impact**: The 8-phase sequential tactic pipeline (tasks 185-193) carries high sequencing risk — any bottleneck in an early tier delays everything downstream. A more incremental "tactic opportunism during refactoring" approach produces the same end state with less coordination overhead.

### Strategic Consideration 6: Publication Goals Are Under-Specified, Creating Scope Creep Risk

- **Current approach**: The roadmap header says "BX Completeness and Publication" but does not specify what "publication" means. Is it (a) the Lean formalization paper, (b) a Lean library release on GitHub, (c) a standalone LNCS/ITP/CPP conference paper about the formalization, (d) Mathlib submission of the modal logic fragment, or (e) simply a clean codebase accompanying the "Construction of Possible Worlds" paper?
- **Alternative/enhancement**: Each publication target has different quality thresholds. For a GitHub release + companion formalization paper: zero sorries in active code, clean documentation, buildable lakefile, README. This is achievable without the full tactic pipeline. For a CPP/ITP submission specifically about the Lean formalization: the tactic library would be a genuine contribution if it's novel (a verified Hilbert-style proof automation for bimodal logics). For Mathlib: not advisable per task 179's analysis. The survey should be scoped differently depending on the publication target. Currently the task 196 description assumes a comprehensive survey without anchoring to a specific publication destination.
- **Long-term impact**: Clarifying the publication target before conducting the survey would allow the survey to produce a ranked list tied to publication-readiness milestones, not an abstract feature inventory.

---

## Roadmap Alignment Assessment

### How well does task 196 fit the current roadmap?

Task 196 is positioned as the **survey gate** for Phases 5a-7 (tactic implementation, 7 tasks, ~90-115 hours). Its placement after Phase 3 (structural refactor) is correct in principle — building tactics before FrameClass parameterization (168) would waste effort. However, the **current dependency specification** says task 196 depends on "155, 161" — which means it can run before 168. This is an inconsistency: the survey should depend on 168 (since 168 changes the type signatures that tactics will operate on) but the TODO.md does not list this dependency.

The implication is either:
1. The survey is intentionally scoped to patterns that survive the 168 refactor — in which case it should explicitly say so and exclude DerivationTree-touching tactics from scope.
2. The survey was positioned before 168 by mistake, and the dependency should be updated to `155, 161, 168`.

### Suggested adjustments to sequencing or scope

**Option A (minimal change)**: Keep current timing, but restrict survey scope to patterns safe before 168:
- Formula/syntax normalization patterns
- Semantic truth evaluation patterns
- EF game automation (independent of DerivationTree)
- `@[simp]` tagging on Formula definitions and Truth lemmas
- List.mem_cons context membership

**Option B (recommended)**: Move task 196 to after task 168, update dependency to `155, 168`. This produces a survey with full context. The 2-month cost is offset by better recommendations.

**Option C (split approach)**: Create two survey tasks — "196a: Pre-168 safe patterns survey" (quick, 4-6 hours) and "196b: Full post-168 tactic design" (comprehensive, 8-12 hours). This maintains velocity while not committing to a post-168 architecture prematurely.

The current roadmap's "Note: Task 196 may generate new tasks and restructure Phases 5a-8" is a tacit acknowledgment that the survey is exploratory. This is appropriate — but the survey should be DESIGNED as exploratory rather than positioned as a comprehensive pre-implementation gate.

---

## Publication and Reuse Potential

### Which patterns/tactics have value beyond this project?

Three automation components have genuine reuse value beyond ProofChecker:

1. **Hilbert-calculus proof automation pattern** (`modal_search`-style): The combination of a backward-chaining lemma database (`@[tm_lemma]`) with weakening-aware search is a general pattern for any Hilbert-style proof system in Lean 4. The pattern is not TM-specific — the same architecture works for K, S4, S5, PDL, or any modal logic. A clean implementation could serve as a reference for formalizations of other Hilbert systems. The `FormalizedFormalLogic/Foundation` project would be the natural upstream target.

2. **`@[simp]` audit methodology**: The pattern of auditing a codebase for untagged simp lemmas and registering domain-specific simp sets (`registerSimpAttr`) is a reusable workflow that other Lean 4 formalizations could adopt. A short blog post or Zulip discussion documenting the methodology would have community value.

3. **EF game automation tactics**: The `same_order_type_grid` and `winning_condition_tac` tactics are specific to the GHR93 expressive completeness proof structure. However, similar "grid dispatch" automation patterns arise in any formalization of model-theoretic games (Ehrenfeucht-Fraïssé games, bisimulation games). The underlying pattern — automating N×N case analysis with interval-indexed sub-game dispatch — could be generalized.

### Mathlib submission candidates

Per task 179's analysis (report 02_mathlib-submission.md), the realistic Mathlib candidates are:

| Component | Mathlib Suitability | Notes |
|-----------|--------------------|-|
| Generic Kripke frame structures | Medium | Basic Frame + FrameClass — has value if cleaned up |
| Propositional modal syntax `Formula α` | Medium-High | Very general; would need polymorphic atoms |
| Basic K/S4/S5 soundness | Medium | Standard textbook material |
| Lindenbaum-Tarski BooleanAlgebra instance | Medium | Connects to existing Mathlib algebra |
| Deduction theorem meta-theorem | Low-Medium | TM-specific proof shape, hard to generalize |
| BX-specific tactics (modal_search, tm_prove) | Low | Too domain-specific |
| Task frame semantics | Very Low | Too specialized |

The task 179 analysis is correct: **do not attempt Mathlib submission of the core logic**. Foundation took the same approach. However, the generic infrastructure items (Kripke frames, Formula α, basic soundness) could become a `Mathlib.Logic.Modal` contribution in a future dedicated project, provided the ProofChecker codebase first separates these from the TM-specific material.

---

## Creative Approaches

### Proof mining for tactic discovery

Rather than manually surveying for patterns, consider **proof mining**: extract every sorry-free proof from Theorems/ and Metalogic/, parse the tactic sequences (or term-level constructors), and cluster by structural similarity. This produces a data-driven ranking of patterns by frequency. Tools: `grep` on proof terms, or a simple Lean elaborator that logs which constructors are applied in each proof. This approach is faster than manual inspection for a 92K-line codebase and is less prone to sampling bias.

### LLM-assisted pattern extraction

The teammate prompt mentions "LLM-assisted proof repair." A lighter application: use an LLM to scan proof files and identify repeated patterns that could be abstracted. This is not proof repair — it is pattern extraction at the textual level. A simple prompt like "identify repeated 5-line patterns in the following proof file" over each Theorems/ file would quickly surface candidates. This is already partially what a human would do manually, but faster.

### Incremental tactic measurement instead of upfront survey

Instead of a comprehensive upfront survey producing a multi-phase roadmap, consider an **incremental measurement approach**: implement one tactic (e.g., `game_tuple_simp`), measure actual line savings across the codebase, compare to predicted savings, and use the accuracy of that prediction to calibrate confidence in the survey estimates. This replaces the survey's predictive function with empirical validation. It is lower-overhead and produces harder evidence.

### Generating tactics from proof diffs

If the codebase undergoes the structural refactor (task 168), the git diff between pre-168 and post-168 proofs would be a goldmine for tactic discovery: patterns that changed uniformly across many files are exactly the patterns that should be automated. This approach is only applicable post-168, which argues for deferring the comprehensive survey until then.

### EF game tactics as a standalone publication

The EFGameTactics.lean work (task 195 + completion) formalizes automation for the GHR93 proof of expressive completeness. This is actually an interesting proof automation story: the GHR93 proof requires a specific N×N game-theoretic case analysis structure that appears repeatedly, and a custom tactic automates the entire pattern. A short paper at a venue like CICM or ITP describing the formalization + automation of GHR93 could be a standalone contribution. The `same_order_type_grid` tactic would be the centerpiece: "we automated a recurring proof obligation in a 9,087-line formalization of expressive completeness, reducing 100-220 line proofs to 1-3 line tactic invocations."

---

## Recommendations

### 1. Fix the dependency specification immediately

The TODO.md says task 196 depends on "155, 161" but not 168. This is either intentional (survey is scoped to pre-168-safe patterns) or an oversight. Either update the dependency to include 168, or explicitly scope the survey description to only include patterns independent of DerivationTree type signatures.

### 2. Prioritize sorry-reduction over cosmetic compression

The survey should rank opportunities by (impact on sorry count) first, then (line savings), then (implementation effort). The 31 sorries in ExpressivenessGeneral.lean and 4 sorries in EFGames.lean are on the critical path to bx_completeness. Any tactic that closes even one of these sorries is higher priority than a Theorems/ optimization that reduces a 7-line proof to a 1-line invocation.

### 3. Complete EFGameTactics.lean before expanding the survey

Task 195 created the right abstraction (EFGameTactics.lean) but only partially implemented it. Components A (same_order_type_grid) and D (winning_condition_tac) are the high-impact ones. Before surveying for new tactic opportunities, complete the existing high-confidence ones. The survey should validate whether these are sufficient for the WeakCanonical/ sorry sites or whether additional tactics are needed.

### 4. Diagnose non-adoption of existing automation

The survey must answer: why are the existing 3,500 lines of Automation/ not used? The answer determines whether more automation infrastructure is the right investment. If the answer is "the proofs predate the tactics," then adoption is a matter of applying the tactics retroactively (task 193). If the answer is "the tactics are not ergonomic," then the survey should focus on ergonomics improvements, not new tactics. If the answer is "nobody knew about them," then documentation is the bottleneck.

### 5. Consider collapsing the 8-phase tactic pipeline

The current roadmap has a 90-115 hour tactic development pipeline (tasks 185-192) before the codebase refactoring (task 193). Consider whether a more incremental approach — develop tactics as needed during the structural refactor itself, rather than front-loading all tactic development — would produce a better outcome with lower sequencing risk. The survey could produce recommendations for which tactics are load-bearing (need to exist before refactoring) vs. which can be built incrementally.

### 6. Anchor the survey to a specific publication target

Before conducting the survey, decide what "publication-ready" means for this project. The answer determines what quality threshold the tactic library needs to meet. For a formalization accompanying a journal paper: a clean, well-documented codebase with zero sorries is sufficient. For a standalone ITP/CPP paper about the formalization itself: the novel EF game automation and the BX completeness proof are the contributions, and the tactic library would need to be presented as a contribution rather than internal tooling.

---

## Confidence Level

**High** for the structural observations (dependency mismatch, non-adoption problem, wrong-layer targeting, EF game tactics completeness, sequencing risk in 8-phase pipeline). These are based on direct reading of the task descriptions, TODO.md, ROADMAP.md, and the task 179 research reports.

**Medium** for the creative suggestions (proof mining, LLM-assisted extraction, incremental measurement, EF game tactics as publication). These are plausible but have not been validated against the actual codebase proof patterns.

**Medium-Low** for the publication target recommendations, since the project's publication goals are not fully specified in the available documents. The recommendations assume a formalization-companion paper goal; they would change if the goal is a standalone tactics-focused paper.

---

## Appendix: Sorry Distribution at Time of Survey

| Location | Sorry Count | Critical Path? |
|----------|-------------|----------------|
| WeakCanonical/ExpressivenessGeneral.lean | ~31 | Yes (direct path to bx_completeness) |
| WeakCanonical/ (total) | ~50 | Mostly yes |
| BXCanonical/ (excluding Chronicle/) | ~19 | No (dead code under irreflexive semantics) |
| Non-WeakCanonical Metalogic/ | ~65 | Mixed |
| Total non-Boneyard | ~148 | — |

The TODO.md header reports 1 "publication-path sorry" (succ_cofinal), but the active WeakCanonical/ sorry count is much higher. The discrepancy is because the 1-sorry count refers specifically to the bx_completeness critical path theorem, while the WeakCanonical sorries are on the critical path to FULLY sorry-free completeness (including all lemmas and supporting infrastructure). The survey should confirm the actual publication-blocker sorry count rather than relying on the header metric.
