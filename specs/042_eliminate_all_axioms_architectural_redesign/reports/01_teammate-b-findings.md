# Task 42 Research: Task Inventory and Critical Path Analysis

**Teammate**: B (task review and path-to-completeness analysis)
**Date**: 2026-03-22
**Session**: Reviewing all open tasks for distraction vs. critical path

---

## Key Findings

- The project has **18 active tasks** across a wide range of status (planning → implementing → blocked)
- The **succ-chain pipeline** (tasks 34, 35, 36, 37, 40) is the primary critical path for axiom elimination
- Task 40 plan is **actively harmful**: it proposes adding a 10th axiom (`successor_p_step_axiom`) instead of proving it — directly contradicts task 42's mandate
- Tasks 988, 989, 41 involve the **D=CanonicalMCS conflation anti-pattern** and are either blocked indefinitely or represent a fundamentally wrong architecture; they should be abandoned or deferred until task 41 is resolved
- Tasks 22, 24, 18 belong to the **dense/discrete pipeline** which uses the old architecture and are not on the critical path to sorry-free, axiom-free base completeness
- Task 41 (D=CanonicalMCS elimination) is a **large architectural refactor** that is research-complete but not critical for axiom elimination — it's a separate concern
- Tasks 6, 8 are high-investment completeness rewrites that address the `truth_at` vs `satisfies_at` distinction; important for publication quality but not blocking axiom count
- **7 tasks are clear abandon/defer candidates**: 988, 989, 22, 24, 993, 998, 999

---

## Task Inventory Table

| # | Name | Status | Critical Path? | Recommendation |
|---|------|--------|----------------|----------------|
| 42 | Eliminate ALL axioms (architectural redesign) | RESEARCHING | YES — umbrella task | **ACTIVE** (this task) |
| 41 | Eliminate D=CanonicalMCS pattern | RESEARCHED | NO (separate concern) | DEFER — research done, plan when 35/40 complete |
| 40 | Prove/add p-step for Succ | PLANNED | YES — blocks task 35 Phase 4 | **SUBSUME into 42**: plan proposes adding axiom, must pivot to proving it |
| 39 | Study preorder semantics conformance | RESEARCHED | NO (theoretical) | DEFER — valuable but not blocking |
| 38 | Prove Box backward truth lemma | BLOCKED | NO (not used in completeness) | ABANDON or DEFER — architecturally impossible with current model |
| 37 | Prove p_nesting_boundary axiom | NOT STARTED | YES (depends on 36) | SUBSUME into 42 or keep as sub-task |
| 36 | Prove f_nesting_boundary axiom | NOT STARTED | YES | SUBSUME into 42 or keep as sub-task |
| 35 | Prove remaining Succ-chain sorries | IMPLEMENTING (3/4) | YES | **RESUME** after 40 is resolved |
| 34 | Prove SuccExistence seed consistency axioms | NOT STARTED | YES (3 of 9 axioms) | SUBSUME into 42 or execute independently |
| 26 | Remove/justify canonicalR_irreflexive_axiom | PLANNED | PARTIAL (one axiom) | SUBSUME into 42 |
| 25 | Shift architecture to CanonicalTask/Succ | COMPLETED | N/A | Archive in next /todo |
| 22 | Direct multi-family bundle construction | RESEARCHED | NO (discrete pipeline) | ABANDON — superseded by succ-chain approach |
| 24 | Discrete axiom removal and cleanup | NOT STARTED | NO (depends on 22) | ABANDON — depends on 22 |
| 21 | Tech debt cleanup (tasks 9-20) | PLANNED | NO | DEFER — depends on 18 (blocked) |
| 20 | Audit parametric canonical infrastructure | NOT STARTED | NO | DEFER — depends on 18 (blocked) |
| 19 | Deprecate old discrete pipeline | NOT STARTED | LOW | DEFER — cosmetic |
| 18 | Dense representation theorem completion | BLOCKED | NO (dense, not base) | DEFER — stuck for days, not critical path |
| 8 | Genuine truth_at completeness | RESEARCHED | LONG-TERM | DEFER — important but high-investment |
| 6 | Canonical TaskFrame completeness | RESEARCHED | LONG-TERM | DEFER — superseded by current pipeline |
| 992 | STSA representation theorem | RESEARCHED | NO | DEFER |
| 993 | Add stability operator | NOT STARTED | NO | ABANDON or DEFER |
| 998 | FMP redesign for strict semantics | NOT STARTED | NO | DEFER |
| 999 | Derive F→FF from density axiom | NOT STARTED | NO | DEFER |
| 988 | Dense algebraic completeness | BLOCKED (old arch) | NO | ABANDON — superseded |
| 989 | Discrete algebraic completeness | RESEARCHING | NO | ABANDON — superseded |
| 953 | Bilateral proof system | RESEARCHED | NO | DEFER — theoretical, 55-90h |
| 949 | Update Demo.lean | RESEARCHED | NO | DEFER — cosmetic |
| 619 | Migrate skills to context:fork | PLANNING | NO | BLOCKED on GitHub issue |
| 39 | Preorder semantics conformance | RESEARCHED | NO | DEFER |

---

## Tasks to Archive/Abandon

### Immediate Abandon Candidates

1. **Task 988** (dense algebraic completeness) — Plans v4-v12 all blocked. Superseded by task 18 approach. The D=CanonicalMCS conflation (task 41) means the whole architecture is wrong. Waiting for task 41 resolution at minimum; better to simply abandon and reopen as a subtask of task 8 once the genuine `truth_at` path is clear.

2. **Task 989** (discrete algebraic completeness) — Superseded by the succ-chain approach (task 997 completed base completeness). The succ-chain pipeline is the correct discrete path. All its SuccOrder/quotient infrastructure is deprecated.

3. **Task 22** (direct multi-family bundle) — The 5-phase implementation is based on ClosedFlagIntBFMCS bridge pattern. Research report 03 itself concludes the cross-family `modal_forward` is "fundamentally impossible." Superseded by succ-chain approach.

4. **Task 24** (discrete axiom removal) — Directly depends on task 22. Cannot proceed. The 3 axioms it targets (`discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`) are tracked under task 42 (axioms 7, 8, 9).

5. **Task 38** (Box backward truth lemma) — Implementation summary explicitly documents this as architecturally impossible without a multi-history BFMCS model. Not used in completeness (per task 42 description). Blocked indefinitely.

### Defer (Not Abandon) Candidates

6. **Task 41** (D=CanonicalMCS elimination) — Research complete, but this is a large architectural refactor that should wait until axiom elimination (task 42) is done. The two are somewhat orthogonal — axiom elimination can proceed in the current architecture.

7. **Task 39** (preorder semantics conformance) — Theoretical study, valuable but not blocking. Research already done with 5 reports.

8. **Task 18** (dense representation theorem) — Blocked on DenseTimeline/DovetailedTimeline bridge. Complex, multi-week blocker. Defer until base completeness is axiom-free.

9. **Tasks 21, 19, 20** — Tech debt and refactoring. Depend on task 18 or cosmetic. Defer.

10. **Tasks 993, 998, 999** — Nice-to-haves. No urgency.

11. **Tasks 6, 8** — Important for publication (`truth_at` correctness) but high investment. These are the long-term "right" completeness theorems. Defer until axiom-free base completeness with `succ_chain_truth_lemma` is achieved.

---

## Critical Path Definition

**Goal**: Zero custom axioms; `#print axioms succ_chain_completeness` shows only Lean built-ins.

**The 9 axioms and their critical path assignment:**

| Axiom | Location | Critical Path Task |
|-------|----------|-------------------|
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean:266 | Task 34 (subsume into 42) |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean:311 | Task 34 (subsume into 42) |
| `predecessor_f_step_axiom` | SuccExistence.lean:516 | Task 34 or 42 directly |
| `f_nesting_boundary` | SuccChainFMCS.lean:615 | Task 36 (subsume into 42) |
| `p_nesting_boundary` | SuccChainFMCS.lean:727 | Task 37 → 36 dependency |
| `existsTask_irreflexive_axiom` | CanonicalIrreflexivity.lean:279 | Task 26 (subsume into 42) |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean:319 | Task 42 directly (task 24 abandoned) |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean:300 | Task 42 directly (task 24 abandoned) |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean:430 | Task 42 directly (task 24 abandoned) |

**Minimal critical path** (tasks that must complete):
1. **Task 34** — Prove 3 SuccExistence seed consistency axioms (independent, no deps)
2. **Task 36** — Prove f_nesting_boundary via Fischer-Ladner closure (independent)
3. **Task 37** — Prove p_nesting_boundary (depends on 36 infrastructure)
4. **Task 40 (revised)** — Prove `successor_satisfies_p_step` WITHOUT adding axiom (plan must be overridden)
5. **Task 35 Phase 4** — Fill forward chain p_step sorry (blocked on 40)
6. **Task 26** — Prove/remove `existsTask_irreflexive_axiom`
7. **Task 42 direct** — Address `discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom`

---

## Dependency Graph Analysis

```
Task 42 (umbrella)
├── GROUP A: Succ seed axioms (SuccExistence.lean)
│   └── Task 34: successor/predecessor_deferral_seed_consistent + predecessor_f_step
│       └── Independent — can start now
│
├── GROUP B: Nesting boundary axioms (SuccChainFMCS.lean)
│   ├── Task 36: f_nesting_boundary (Fischer-Ladner)
│   │   └── Independent — can start now
│   └── Task 37: p_nesting_boundary
│       └── Depends on Task 36 infrastructure
│
├── GROUP C: P-step for forward chain
│   ├── Task 40 (REVISED): prove successor_satisfies_p_step (NOT add axiom)
│   │   └── Independent — can start now
│   └── Task 35 Phase 4: fill forward chain p_step sorry
│       └── Depends on Task 40
│
├── GROUP D: ExistsTask irreflexivity
│   └── Task 26: prove/remove existsTask_irreflexive_axiom
│       └── Independent — can start now
│
└── GROUP E: Discrete pipeline axioms
    ├── discrete_Icc_finite_axiom (DiscreteTimeline.lean)
    ├── discreteImmediateSuccSeed_consistent_axiom (DiscreteSuccSeed.lean)
    └── discreteImmediateSucc_covers_axiom (DiscreteSuccSeed.lean)
        └── Independent — can start now (task 24 abandoned)
```

**No circular dependencies.** Groups A, B-f_nesting, C-40, D, E are all independent and can be parallelized.

---

## Recommended Execution Order

### Phase 1: Parallel Research/Implementation (Groups A, B-entry, D, E can run in parallel)

1. **Task 34** — Prove SuccExistence seed consistency (3 axioms): `successor_deferral_seed_consistent_axiom`, `predecessor_deferral_seed_consistent_axiom`, `predecessor_f_step_axiom`. Research suggests T-axiom may close these syntactically.

2. **Task 36** — Prove `f_nesting_boundary` via Fischer-Ladner closure finiteness. Standard modal logic technique; Fischer-Ladner closure of any formula is finite.

3. **Task 40 (OVERRIDE PLAN)** — Do NOT implement the plan as written (it adds axiom 10). Instead prove `successor_satisfies_p_step` directly. The predecessor construction proves it via `pastDeferralDisjunctions`; the successor dual should use `futureDeferralDisjunctions`. If not directly provable, explore Succ 4-condition extension without adding axioms.

4. **Task 26** — Prove `existsTask_irreflexive_axiom`. Research (task 26 reports) indicates path A (reflexive T-axiom) may work: `CanonicalIrreflexivity.lean` had 1170 lines of infrastructure from task 967 for reflexive semantics.

5. **Discrete axioms (direct in task 42)** — Address `discrete_Icc_finite_axiom`: Lean's `Finset.Icc_finite` should already handle this for `Int`; the sorry may be trivially closeable. Address `discreteImmediateSuccSeed_consistent_axiom` and `discreteImmediateSucc_covers_axiom` similarly.

### Phase 2: Sequential (depends on Phase 1)

6. **Task 37** — Prove `p_nesting_boundary` after task 36 infrastructure is in place (F/P duality).

7. **Task 35 Phase 4** — Fill `succ_chain_fam_p_step` forward chain sorry after task 40 delivers `successor_satisfies_p_step`.

### Phase 3: Verification

8. Run `#print axioms succ_chain_completeness` (or equivalent) to verify zero custom axioms.

9. Assess task 41 (D=CanonicalMCS elimination) as separate follow-up work.

---

## Task 40 Plan Override — Critical Issue

The task 40 plan (`01_successor-p-step-axiom.md`) explicitly states in its overview:

> "Add `successor_p_step_axiom` to SuccExistence.lean (mirroring `predecessor_f_step_axiom`), then add `forward_chain_p_step` theorem..."

> "The research confirmed that a pure theorem approach is not achievable because the successor deferral seed contains no past-direction content."

This directly contradicts task 42's mandate. The plan must be **revised or overridden**. Options:
- **Option A**: Prove the property by restructuring the successor seed to include `pastDeferralDisjunctions` (symmetric to predecessor seed containing `pastDeferralDisjunctions`)
- **Option B**: Extend Succ to 4 conditions (g-persistence, f-step, h-persistence, p-step) and prove all 4 hold for the successor construction — no new axioms needed if the successor seed is restructured
- **Option C**: If neither is provable, restructure the completeness proof to avoid needing `succ_chain_fam_p_step` in the forward direction (i.e., skip the biconditional and use a forward-only truth lemma for completeness)

Option A/B are preferable. The research conclusion that "pure theorem approach is not achievable" was based on the current seed design — not necessarily on fundamental impossibility.

---

## Axiom-Related Task Subsumption Analysis

Task 42's description says "Tasks 34, 36, 37 target individual axioms and should be subsumed or coordinated."

**Recommendation**: Subsume into task 42's execution phases rather than keeping as separate tasks. This avoids coordination overhead and ensures the no-axiom constraint is applied consistently (e.g., task 40's plan to add an axiom would be caught earlier).

However, keeping them as **labeled sub-phases within task 42** is equivalent and preserves the ability to track progress per-axiom group. The key is ensuring task 40's plan override happens before any implementation begins.

---

## Confidence Level

**High** for:
- Task inventory completeness (read all TODO.md + state.json entries)
- Identification of tasks to abandon (988, 989, 22, 24, 38)
- Task 40 plan conflict with task 42 mandate
- Dependency graph structure (all deps read from state.json + TODO.md)

**Medium** for:
- Axiom provability estimates (Fischer-Ladner for 36/37, T-axiom for 34, T-axiom for 26) — need code-level verification
- Whether `successor_satisfies_p_step` is provable without adding an axiom — research said "not achievable" but this was under a specific seed design assumption

**Low** for:
- Discrete pipeline axioms (7, 8, 9) — haven't read DiscreteTimeline.lean or DiscreteSuccSeed.lean directly; the `discrete_Icc_finite_axiom` may be trivially provable via Mathlib but needs verification
