# Research Report: Task #107 — Clean-Break vs Incremental for Burgess Alignment

**Task**: 107 — chain_design_diagnostics_for_representation_theorem
**Date**: 2026-05-05
**Mode**: Team Research (4 teammates)
**Session**: sess_1778014444_dca927

## Summary

All 4 teammates converge: **incremental patching is the right path**, not a clean-break refactor. ~80% of the codebase is already Burgess-aligned and sorry-free. The remaining sorries are architectural (c2' g-value propagation) and mathematical (C4 hard cases, FUC/FSC), not primarily definitional. A clean-break would risk breaking 3 recently-closed sorries and the 700-line sorry-free ChronicleConstruction.lean, with no mathematical benefit.

## Key Findings

### 1. Discrepancy Analysis (Teammate A)

Five discrepancies identified between our code and Burgess 1982:

| Discrepancy | Severity | Blocks Sorries? |
|-------------|----------|-----------------|
| Two-track r-relation (rRelation vs burgessR) | Medium | No — c2 uses rRelation, c2' uses correct burgessR3 |
| c1 uses SetDeductivelyClosed (Burgess: just CUD) | Low | No — Zorn always produces consistent g-values |
| NoUnivBurgessR3 stubs (6 sorries) | High | Yes — but PROVABLE via bot-guard argument |
| C5 formulation divergence | Low | Indirectly affects FUC/FSC |
| BurgessR3Maximal first conjunct | FIXED | No — resolved in Phase 2/3 |

**Critical finding**: NoUnivBurgessR3 IS provable. Take β = ⊥ in burgessRSet(A, Set.univ, C) to get untl(⊥, γ) ∈ A for some γ ∈ C. BX10 gives F(⊥) ∈ A, but G(¬⊥) is a theorem so ¬F(⊥) ∈ A, contradiction. Estimated: 2-4 hours.

### 2. Clean-Break Refactor Analysis (Teammate B)

- **80% of codebase is correct and Burgess-aligned**: ChronicleTypes, RRelation, PointInsertion (sorry-free), ChronicleConstruction (sorry-free, 700 lines)
- **Only ~200-300 lines need work**: c2' plumbing in CounterexampleElimination, FUC/FSC in ChronicleToCountermodel
- **Clean-break estimate**: 18-31 hours, HIGH risk of breaking ChronicleConstruction.lean
- **Incremental estimate**: 19-32 hours, LOWER risk
- **Verdict**: Creating Chronicle2/ would be wasteful — the mathematical content is already correct

### 3. Critical Analysis (Teammate C)

- **Actual sorry count is 15**, not 9: includes 6 NoUnivBurgessR3 stubs in PointInsertion.lean (but single root cause, closable in one pass)
- **c2' sorries are NOT trivial**: EliminationResult doesn't propagate B/B'/B'' witnesses from Lemmas 2.4/2.6. The `_B` pattern discards them. Infrastructure gap is real.
- **C4/C4' hard cases are genuinely hard**: need h_c2' parameter (removed in Phase 7), not just plumbing
- **FUC/FSC are most dependent**: require everything upstream
- **Risk flagged**: sorry #3 fix (B' = Set.univ for inconsistent xi) needs soundness verification

### 4. Strategic Horizons (Teammate D)

- **Sorry-free is essential** for publication and downstream tasks (95, 68)
- **No simpler proof exists**: 36+ dead ends documented; Burgess chronicle is canonical
- **Do NOT pivot**: sprint to sorry-free; time-box at ~30 hours
- **Post-completion**: axiom audit (task 115) warranted — BX system has 39 axioms vs Burgess's 7+mirror

## Synthesis

### Conflicts Resolved

1. **Sorry count**: Teammate C says 15, others say 9. Resolution: 15 sorry sites exist, but 6 are NoUnivBurgessR3 stubs with a single root cause. Effective unique obligations: ~10.

2. **c2' difficulty**: Teammate B says "10-20 line proof using burgessR3Maximal_exists_from_seed". Teammate C says "infrastructure gap is real — B witnesses are discarded." Resolution: Both are right. The math IS straightforward once the EliminationResult type is modified to capture B witnesses. The modification itself is the work.

### Gaps Identified

1. **NoUnivBurgessR3 bot-guard proof** not yet attempted — Teammate A provides the argument but it hasn't been verified in Lean
2. **EliminationResult restructuring** not yet scoped — how many callers need updating?
3. **Sorry #3 soundness** — Teammate C flags concern about B' = Set.univ + ex falso; needs independent check

### Recommendations

1. **Close NoUnivBurgessR3** first (6 stubs, single argument, ~2-4 hrs)
2. **Restructure EliminationResult** to capture B/B'/B'' from Lemmas 2.4/2.6 (Phase 4 prerequisite)
3. **Close 5 c2' sorries** using captured witnesses (Phase 4)
4. **Re-add h_c2' to eliminate_C4_counterexample** and close C4/C4' hard cases (Phase 5)
5. **Close FUC/FSC** last (Phase 6, depends on all upstream)
6. **Verify sorry #3 soundness** independently
7. **Do NOT do a clean-break refactor** — the incremental path is lower risk and same effort

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Discrepancy analysis | completed | high |
| B | Clean-break refactor | completed | high |
| C | Critic | completed | high |
| D | Strategic horizons | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for Tense Logic I: 'Since' and 'Until'". Notre Dame Journal of Formal Logic, 23(4).
- specs/107_.../handoffs/sorry3-first-conjunct-fix.md (4-phase alignment plan)
- specs/107_.../plans/62_implementation-plan.md (Phases 4-6)
