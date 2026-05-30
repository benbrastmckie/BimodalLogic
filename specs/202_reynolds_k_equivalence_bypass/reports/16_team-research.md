# Research Report: Task 202 — Reynolds Model Surgery Sub-Task Decomposition

**Task**: 202 — Reynolds k-equivalence bypass for sorry-free completeness_discrete
**Date**: 2026-05-30
**Mode**: Team Research (4 teammates)
**Session**: sess_1780160597_res202t

## Summary

Team research across 4 parallel investigators converged on a single clear finding: the TRUE blocker preventing progress across 17 implementation cycles is that **no agent has ever attempted to construct the `MonadicFormula sig 1` encoding `right_gap_class_prop`** (Reynolds Lemma 6). Every cycle instead tries a simpler bridge lemma, discovers it's impossible, refactors the surrounding infrastructure, and exits. The model surgery decomposes cleanly into 4 sub-tasks with a clear dependency chain.

## Key Findings

### 1. The True Blocker (Teammate C)

The pattern of failure across 17 cycles is consistent: agents arrive at the sorry, attempt a shortcut (class_temporal_formula, enriched-signature class membership, direct predicate argument), discover it fails, add infrastructure around the sorry, and exit. The actual work — constructing a `MonadicFormula sig 1` term encoding `right_gap_class_prop` — has never been attempted. This is Reynolds Lemma 6 and it is the mandatory first step.

### 2. Decomposition into 4 Sub-Tasks (Teammates A + C)

All teammates agree the model surgery decomposes into 4 sequential sub-tasks:

| Sub-Task | Content | Lines | Depends On |
|----------|---------|-------|------------|
| **A: Gap Formula R** | Construct MonadicFormula sig 1 for right_gap_class, apply US_expressively_complete_over_prior | 60-100 | None |
| **B: R-interval Analysis** | Show R holds at a, use prior_UZ_first_transition for transition analysis | 40-60 | A |
| **C: Model Surgery + Truth Preservation** | Construct surgery domain, prove temporal truth preservation (26 U/S subcases) | 250-350 | A, B |
| **D: Contradiction** | R true at surgery point in M, false in surgery model → False | 30-60 | C |

Total: 380-570 lines (UZ case) + 50-100 lines (SZ case via Order.dual or symmetric argument).

### 3. Rich Existing Infrastructure (Teammate B)

16 sorry-free lemmas are directly reusable:
- `right_gap_class_prop`, `right_gap_class_invariant`, `right_gap_class_succ`, `right_gap_class_pred` (GoodStructuresModelSurgery.lean)
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean:371)
- `prior_UZ_first_transition`, `prior_SZ_last_transition` (GoodStructuresModelSurgery.lean)
- `contemp_equiv_is_equiv`, `no_boundary_at_successor`, `contemp_equiv_convex` (GoodStructures.lean)
- `doets_lemma_1_4`, `k_equiv_of_iso` (OrderedSum.lean, NEquivalence.lean)
- `orderedSum`, ShiftAndGlue patterns (OrderedSum.lean, ShiftAndGlue.lean)

### 4. Strategic Assessment (Teammate D)

- completeness_discrete IS the right goal — no substitute for the actual theorem
- The model surgery IS the only confirmed-correct path (all alternatives exhaustively ruled out)
- Chronicle-specific shortcut identified as genuinely unexplored backup (2-4 hour sprint if surgery stalls)
- Accept-and-defer via `axiom` is viable but premature — recommended only after 5+ more cycles fail

## Synthesis

### Conflict Resolution

**Sub-task granularity** (A: 4 sub-tasks vs C: 8 sub-tasks): Resolved as 4 main sub-tasks. Sub-Task C (model surgery) can be further split if needed, but the dependency chain is linear so finer granularity doesn't enable more parallelism.

**Enriched signature approach** (B: suggests for formula vs C: warns dead end): Resolved. The FAILED enriched-signature approach was for **class membership** (circular with Theorem 14). The approach for **right_gap_class** is DIFFERENT — it adds a structural predicate, not class membership. This needs investigation but is not confirmed circular. However, the Classical.choice approach (prove existence without explicit construction) may be simpler.

### Gaps Identified

1. **MonadicFormula construction technique**: No teammate provided actual Lean code for the formula. The specific challenge is encoding `very_good sig k (M.subinterval sig (min t y) (max t y))` as a MonadicFormula with free variable `t` and quantified `y`. This requires:
   - Expressing `k_equiv` as a finite disjunction over NormalForm sig k 0 (which is Fintype)
   - Encoding `subinterval` membership via order constraints
   - Using `nf_eval` or `nf_characteristic` formulas within the MonadicFormula

2. **Surgery domain type theory**: How to construct `OrderedMonadicStructure sig` on the surgery domain (Q- ∪ I ∪ Q+) when it's a non-convex subset of M.carrier. Teammate B suggests using `orderedSum` over 3 pieces (reusing ShiftAndGlue patterns).

3. **SZ reduction via Order.dual**: Whether `gap_prior_SZ_contradiction` can be derived from `gap_prior_UZ_contradiction` via `Order.dual`. This would save ~300 lines but requires verifying that all type class instances transfer correctly.

### Recommendations

**Immediate action**: Create 4 new sub-tasks for task 202, each independently implementable:

1. **Task 202a**: Construct `right_gap_class_formula : MonadicFormula sig 1` and prove correctness (`∀ t, eval M (fun _ => t) rho ↔ right_gap_class_prop sig k M t`). This is the MANDATORY FIRST STEP. Approach: use Classical.choice to prove existence, or construct explicitly using NormalForm Fintype.

2. **Task 202b**: Apply `US_expressively_complete_over_prior` to get temporal formula R, prove R holds at `a`, analyze R-intervals via `prior_UZ_first_transition`. This is straightforward given Sub-Task A.

3. **Task 202c**: Construct surgery model N using `orderedSum` pattern (Q- + I + Q+), prove temporal truth preservation for all 6 formula constructors (26 subcases for U/S). This is the largest sub-task (~300 lines).

4. **Task 202d**: Derive contradiction (R true at I in M, R false at I in N, truth preservation says R(I) must agree → False). Wire into `gap_prior_UZ_contradiction`. Derive `gap_prior_SZ_contradiction` via Order.dual or symmetric argument.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary decomposition | completed | high |
| B | Infrastructure reuse | completed | high |
| C | Critic (failure analysis) | completed | high |
| D | Strategic horizons | completed | medium |

## References

- Reynolds 1994, "Axiomatising U and S over integer time", Section 7, Lemmas 6-13, Theorem 14
- Teammate A report: specs/202_reynolds_k_equivalence_bypass/reports/16_teammate-a-findings.md
- Teammate B report: specs/202_reynolds_k_equivalence_bypass/reports/16_teammate-b-findings.md
- Teammate C report: specs/202_reynolds_k_equivalence_bypass/reports/16_teammate-c-findings.md
- Teammate D report: specs/202_reynolds_k_equivalence_bypass/reports/16_teammate-d-findings.md
