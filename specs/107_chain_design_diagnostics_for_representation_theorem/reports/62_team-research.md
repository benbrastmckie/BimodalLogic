# Research Report: Task #107

**Task**: Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-05
**Mode**: Team Research (4 teammates)

## Summary

Four-teammate analysis of 13 remaining sorry sites against Burgess 1982, comparing the current Lean implementation with the paper's proof strategy. Key breakthrough: the sorry count is 13 (not 8), due to 5 inline `c2' := by sorry` patterns. Convention alignment is verified correct throughout. Plan v60 is significantly stale and needs revision. The hardest sorry is Lemma 2.7 seed consistency (#2), a 12-step axiomatic chain. The most strategically important question — whether `NoUnivBurgessR3` is provable from J₀ — was resolved: it is NOT a J₀ theorem (confirmed by semantic model on two-point discrete order), so it requires either a definition fix or structural justification.

## Key Findings

### Primary Approach (from Teammate A)

**Sorry-by-sorry Burgess alignment**: Each sorry was mapped to its exact Burgess passage:

| # | File:Line | Burgess Ref | Root Cause | Confidence |
|---|-----------|-------------|------------|------------|
| 1 | PointInsertion:1977 | Lemma 2.6 | Unnecessary MCS case split; extract witness via DC(B∪{β}) + BX2 contrapositive | HIGH |
| 2 | PointInsertion:2744 | Lemma 2.7 | Seed consistency: 12-step BX5+BX7+A3a chain | MED-HIGH |
| 3 | PointInsertion:2875 | Lemma 2.7 | Unnecessary case split on {xi}∪B consistency; use Zorn variant | HIGH |
| 4 | CounterexampleElim:413 | Lemma 2.9 (n=m+1) | c2' invariant missing | HIGH |
| 5 | CounterexampleElim:511 | Lemma 2.9' | Mirror of #4 | HIGH |
| 6-10 | CounterexampleElim:758-920 | C2' invariant | g-values not updated during elimination | HIGH |
| 11 | ChronicleToCountermodel:621 | Claim 2.11 | Full C5 with guard needs c2' + C3 at limit | MEDIUM |
| 12 | ChronicleToCountermodel:625 | Claim 2.11 | Mirror of #11 | MEDIUM |
| 13 | Completeness:152 | Implicit | burgessR3 lacks consistency requirement matching Burgess DCS | MEDIUM |

**Key insight**: Sorries #1 and #3 stem from case splits that Burgess never makes — they are formalization artifacts. Removing them and following Burgess directly resolves both.

**Key helper lemmas needed**:
1. `deductiveClosure_elem_witness`: Extract conjunction of base elements from DC(B ∪ {β})
2. `burgessR3Maximal_neg_until_witness`: From maximality + δ ∉ B, extract witness β₀ ∈ B, γ₀ ∈ C
3. `burgessR3Maximal_extension_exists_cud`: Zorn variant accepting ClosedUnderDerivation seed

### Alternative Approaches (from Teammate B)

**Mirror symmetry halves proof obligations**: Sorries #4/#5, #6/#7, #8/#9, #11/#12 are exact mirror pairs. Once one direction is proved, the mirror is mechanical. Effective unique proof obligations: ~8.

**c2' architecture gap**: The 5 c2' sorries (#6-10) are architectural, not mathematical. Each elimination function preserves old g-values but c2' needs `BurgessR3Maximal` on NEW adjacent pairs with the old g. Fix: refactor elimination return types to update g-values, or prove `omega_chain_c2'` by induction on the stage (Teammate D's unconventional suggestion).

**C4 hard cases (#4/#5)**: Straightforward once `h_c2'` parameter is added to `eliminate_C4_counterexample` (currently missing from function signature).

### Gaps and Shortcomings (from Critic)

1. **Case B sorry (#1) is NOW closable**: The ClosedUnderDerivation cascade (recent commit) fixed the underlying issue, but the proof wasn't updated. The comment at line 1969-1976 is stale — it describes a problem that no longer exists.

2. **Plan v60 is significantly stale**: Sorry count changed (12→13→now 8 standalone + 5 inline = 13), Phases 1-2 already completed, Phase 3 blocker claim is false after cascade, Phase 6 claim of "7 CE sorries" is wrong (now 2 standalone + 5 inline).

3. **Convention alignment verified correct**: No remaining misalignments between Lean code and Burgess 1982. The persistent convention confusion (untl(guard, event) vs U(event, guard)) has been fully resolved.

4. **NoUnivBurgessR3 is NOT a J₀ theorem**: Confirmed via both syntactic analysis and semantic counterexample on discrete orders.

5. **bot_until_bot_absurd**: Extra sorry in TemporalDerived.lean (not on critical path) is closable via BX10. Low priority.

### Strategic Horizons (from Horizons)

**Dependency DAG**:
```
                NoUnivBurgessR3 (#13)
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
Case B (#1)              Lemma 2.7 (#2, #3)
(Lemma 2.6)            (seed consistency +
                        inconsistent case)
          │                     │
          └──────────┬──────────┘
                     ▼
           c2' maintenance (#6-#10)
           (5 elimination types)
                     │
                     ▼
          C4/C4' hard cases (#4, #5)
                     │
                     ▼
          FUC/FSC coherence (#11, #12)
```

**Architecture fitness**: Excellent. File boundaries align with Burgess's proof structure. No restructuring needed.

**Risk assessment**: Lemma 2.7 seed consistency (#2) is the single biggest risk — the only non-trivial multi-step axiomatic proof chain.

## Synthesis

### Conflicts Resolved

**1. NoUnivBurgessR3 provability (CRITICAL CONFLICT)**

- Teammate D claimed it IS provable via Lemma 2.2 ("⊥ is consistent" contradiction)
- Teammates B and C claimed it is NOT provable from J₀
- Teammate A explored extensively but couldn't find the contradiction

**Resolution**: Teammate D is **incorrect**. The error: Lemma 2.2 states "if U(γ, δ) ∈ A then γ is consistent" — γ is the FIRST argument (event), not the second (guard). For untl(⊥, γ) = U(γ, ⊥), Lemma 2.2 gives "γ is consistent" (trivially true since γ ∈ C, an MCS), NOT "⊥ is consistent."

**Semantic proof of non-derivability**: On a two-point discrete order {0, 1} with 0 < 1, and MCSs A (at 0) and C (at 1): U(γ, ⊥) at point 0 requires ∃ y > 0 with γ ∈ V(y) and ⊥ at all intermediate points. With y=1 and no intermediate points, this holds whenever γ ∈ V(1) = γ ∈ C. So burgessR3(A, Set.univ, C) IS satisfiable on discrete orders. Since J₀ is sound for all linear orders, ¬burgessR3(A, Set.univ, C) cannot be a J₀ theorem.

**Recommended resolution for NoUnivBurgessR3**:
- **Option A (cleanest)**: Add `SetConsistent B` to `burgessR3` definition, matching Burgess's implicit DCS requirement (§1.3: DCSs are consistent). NoUnivBurgessR3 becomes trivial. Requires cascade audit.
- **Option B (least disruptive)**: Prove from construction properties — the chronicle uses Q (dense), where g(x,y) intervals always have intermediate points, making untl(⊥, γ) unsatisfiable.
- **Option C (current approach)**: Keep as sorry/axiom, justified by semantic argument for dense orders.

**2. Sorry count: 13, not 8**

Five inline `c2' := by sorry` patterns at CounterexampleElimination.lean:758,796,836,874,920 were missed by the initial grep. Total: 3 (PointInsertion) + 7 (CounterexampleElimination) + 2 (ChronicleToCountermodel) + 1 (Completeness) = 13.

### Gaps Identified

1. **Plan v60 needs revision**: Multiple phases completed, sorry count wrong, blocker claims stale
2. **c2' parameter missing from `eliminate_C4_counterexample`**: Function signature lacks `h_c2'`, blocking sorries #4/#5
3. **FUC/FSC guard propagation**: Requires full C5 (not just C5_weak) — all upstream c2' + C3 infrastructure must be in place first
4. **EliminationResult type doesn't capture g-value updates**: Architectural gap blocking all 5 c2' sorries

### Recommendations

**Priority-ordered execution (following Burgess exactly)**:

| Priority | Sorry | Approach | Effort | Blocks |
|----------|-------|----------|--------|--------|
| 1 | #13 NoUnivBurgessR3 | Option A (add SetConsistent to burgessR3) or Option B (semantic from construction) | 2-4h | #1, #2, #3 |
| 2 | #1 Case B | Remove MCS case split, extract maximality witness via DC(B∪{β}) + BX2 contrapositive | 3-5h | #6-10 |
| 3 | #2 Seed consistency | 12-step BX5+BX7+A3a chain per Burgess p.372 | 6-10h | #6-10 |
| 4 | #3 Inconsistent case | Remove {xi}∪B case split, use Zorn with ClosedUnderDerivation seed | 2-3h | #6-10 |
| 5 | #6-10 c2' plumbing | Refactor elimination return types or prove omega_chain_c2' by induction | 6-10h | #4, #5 |
| 6 | #4, #5 C4 hard cases | Add h_c2' parameter, follow Burgess 2.9 case n=m+1 | 2-3h | #11, #12 |
| 7 | #11, #12 FUC/FSC | Full C5 with guard via limit_g + C3 | 4-6h | completeness |

**Total revised estimate**: 25-41 hours

**Plan v60 status**: Needs `/revise` to update for NoUnivBurgessR3, correct sorry inventory, mark completed phases, and adjust effort estimates.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary Burgess alignment | completed | high |
| B | Alternative approaches & infrastructure | completed | high |
| C | Critic: gaps and blind spots | completed | high |
| D | Strategic horizons | completed | high (but NoUnivBurgessR3 claim incorrect) |

## Complete Sorry Inventory

| # | File | Line | Description | Burgess Ref | Category |
|---|------|------|-------------|-------------|----------|
| 1 | PointInsertion.lean | 1977 | Case B pos sub-case (B is MCS) | Lemma 2.6 | Point insertion |
| 2 | PointInsertion.lean | 2744 | lemma_2_7_seed_consistent | Lemma 2.7 | Point insertion |
| 3 | PointInsertion.lean | 2875 | Lemma 2.7 inconsistent case | Lemma 2.7 | Point insertion |
| 4 | CounterexampleElimination.lean | 413 | C4 hard case (Until) | Lemma 2.9 | Counterexample elim |
| 5 | CounterexampleElimination.lean | 511 | C4' hard case (Since) | Lemma 2.9' | Counterexample elim |
| 6 | CounterexampleElimination.lean | 758 | c2' from C5 elimination | C2' invariant | c2' plumbing |
| 7 | CounterexampleElimination.lean | 796 | c2' from C5' elimination | C2' invariant | c2' plumbing |
| 8 | CounterexampleElimination.lean | 836 | c2' from C4 elimination | C2' invariant | c2' plumbing |
| 9 | CounterexampleElimination.lean | 874 | c2' from C4' elimination | C2' invariant | c2' plumbing |
| 10 | CounterexampleElimination.lean | 920 | c2' for density insertion | C2' invariant | c2' plumbing |
| 11 | ChronicleToCountermodel.lean | 621 | Forward Until coherence (FUC) | Claim 2.11 | Truth lemma |
| 12 | ChronicleToCountermodel.lean | 625 | Forward Since coherence (FSC) | Claim 2.11 | Truth lemma |
| 13 | Completeness.lean | 152 | NoUnivBurgessR3 | Implicit in Burgess | Foundation |

## References

- Burgess, J. P. (1982). "Axioms for Tense Logic I: 'Since' and 'Until'." Notre Dame Journal of Formal Logic, 23(4).
- Teammate A: specs/107_.../reports/62_teammate-a-findings.md
- Teammate B: specs/107_.../reports/62_teammate-b-findings.md
- Teammate C: specs/107_.../reports/62_teammate-c-findings.md
- Teammate D: specs/107_.../reports/62_teammate-d-findings.md
