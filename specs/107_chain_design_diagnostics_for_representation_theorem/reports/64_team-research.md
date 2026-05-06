# Research Report: Task #107

**Task**: Burgess chronicle construction for BX representation theorem
**Date**: 2026-05-06
**Mode**: Team Research (4 teammates)

## Summary

Comprehensive analysis of all remaining work for sorry-free `bx_completeness`. The 2 critical-path sorries (ChronicleConstruction.lean:1445, 1457) have a clear closure chain via guard propagation through `EliminationResult` and `lemma_2_7` DC(B∪{xi}) seed enrichment. A third blocker — `NoUnivBurgessR3` as an unproved hypothesis in the completeness theorem — was identified by the Critic as a blind spot in the current plan. Convention migration (untl/snce arg swap) affects 33 files / 2,141 references and should happen AFTER sorry closure. Total remaining: 15-20h for sorry closure, 8-16h for convention migration, plus 3-8h for documentation and cleanup.

## Key Findings

### 1. Exact Sorry State and Closure Chain (Teammate A)

The 2 sorries need `ξ ∈ limit_f(w)` for intermediate w between x and y at the limit. The definition of `limit_g` (line 878) makes this equivalent to proving `ξ ∈ limit_g(x, y)`. The sorry-free infrastructure `adj_g_mem_limit_f` (line 1406) bridges finite-stage g-membership to limit f-membership. The gap is getting guard INTO g at a finite stage.

Three independent sources of guard info must be threaded through `EliminationResult`:

| Case | Location | What's Missing | Fix |
|------|----------|---------------|-----|
| **Not actual** (unchanged) | CE:1479 | `ξ ∈ χ.g(x,y)` discarded | Stop discarding the guard witness |
| **n=0 (Walk A)** | CE:848 | Uses `lemma_2_4` not `lemma_2_4_with_guard` | Switch to `_with_guard` variant |
| **n≥1 splitting** | CE:1036-1069 | `lemma_2_7`/`2_8` don't return `xi ∈ B'` | Change Zorn seed to DC(B∪{xi}) |

The `h_actual` counterexample check is **already Burgess C5a aligned** (g-values), done in a prior implementation phase. The remaining work is threading guard info that's available but unused.

### 2. NoUnivBurgessR3: Hidden Third Blocker (Teammate C)

**Critical finding**: `bx_completeness` (Completeness.lean:128) takes `h_nubr3 : Chronicle.NoUnivBurgessR3` as a **hypothesis parameter**, not a proved theorem. This means `#print axioms bx_completeness` will still show `sorryAx` even after closing the 2 ChronicleConstruction sorries — unless `NoUnivBurgessR3` is separately proved.

`NoUnivBurgessR3` states: for all MCS pairs A, C, `¬burgessR3 A Set.univ C`. This should follow from Set.univ being inconsistent (contains both φ and ¬φ), making it unable to satisfy the DCS consistency requirements of burgessR3. Estimated effort: 2-4h. Currently tracked as part of task 95 (axiom audit) but needs to be pulled forward.

### 3. Convention Migration: 5 Notational Divergences (Teammate B)

| Divergence | Scope | Fix Strategy |
|-----------|-------|-------------|
| **A. untl/snce arg order** | 2,141 refs / 33 files | Full swap (Strategy B) |
| **B. Variable naming** (xi=guard vs Burgess xi=event) | ~hundreds of names | Rename during Strategy B |
| **C. burgessR definition** | Currently "accidentally correct" | Must swap after semantics change |
| **D. Axiom naming** (BX# vs A#a) | Docstrings only | Update comments |
| **E. Derived operators** (next/prev) | 2 definitions | Swap args |

**Key insight from Teammate B**: The `burgessR` definition `∀ γ ∈ C, untl(β, γ) ∈ A` accidentally matches Burgess's r(A, β, C) under the current convention. A semantics-only swap (Strategy A) would BREAK burgessR, requiring a cascading fix. Strategy B (full swap of all constructor args + variable renaming) is the only approach that avoids creating a two-layer confusion. Convention comments appear 6 times in PointInsertion.lean alone — a clear code smell confirming the confusion cost.

**Timing**: All 4 teammates and report 67 unanimously agree — AFTER sorry closure. The convention swap does not help close the sorries and would invalidate all handoff documents and code references.

### 4. Comprehensive Work Inventory (Teammate D)

**42 total sorry sites** across 10 active files. Only 2 are on the critical path.

| Category | Count | Priority | Effort |
|----------|-------|----------|--------|
| Critical path (ChronicleConstruction) | 2 | P0 | 12-16h |
| NoUnivBurgessR3 hypothesis | 1 | P0 | 2-4h |
| BXCanonical dead-code sorries | 15 | P3 | (task 109) |
| TemporalDerived invalid stubs | 19 | P2 | 2-4h |
| Bundle legacy sorries | 6 | P4 | Low priority |

**Stale documentation** is significant: ROADMAP claims 9 critical-path sorries when only 2 remain. Completeness.lean comments say 11 sorries. Both need updating.

### 5. Walk Case B: Underestimated Complexity (Teammate C)

The "eta-shortcut" in Walk Case B (CE:984-1004) currently returns the chronicle unchanged with `u_next` as C5 witness but NO guard info. If `c5_forward_witness` is strengthened to include guard, this shortcut case needs rework — it currently has `η ∈ f(u_next)` but not `ξ ∈ g(x, u_next)`. This is underestimated in the handoffs (~20 lines currently, may need 40-60 lines with a splitting argument or new approach). Overall effort likely 500-700 lines rather than the 400 estimated.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| **Effort estimates diverge** (A: 12-16h, D: 4-8h, C: "underestimated") | Adopt 15-20h for sorry closure. Teammate D's 4-8h was optimistic; Teammate C's critique of Walk Case B and cascading type changes is well-founded. |
| **h_actual: already changed or needs changing?** | Already changed to g-values (done in Phase 2). The remaining work is threading guard info through, not changing the check. |
| **"Only 2 sorries on critical path" vs NoUnivBurgessR3** | Both are true. 2 sorry sites + 1 unproved hypothesis = 3 items to resolve for unconditional `bx_completeness`. |

### Gaps Identified

1. **NoUnivBurgessR3 is unproved** — the current plan does not track this
2. **Walk Case B eta-shortcut rework** — underscoped in handoffs
3. **`deductiveClosure_consistent` helper** — needed for DC(B∪{xi}) strategy, not verified to exist in codebase
4. **ROADMAP and Completeness.lean sorry documentation** — significantly stale
5. **TemporalDerived.lean** — 19 invalid sorry stubs, 2 with latent callers in import chain

### Recommendations

#### Priority 1: Close Critical Path (15-20h)

Execute in this order:

1. **Strengthen `EliminationResult.c5_forward_witness`** to include guard (~50 lines type change + 18 case updates). Add `∧ pc.ξ ∈ val.g pc.x y` to the existential. Non-C5 cases trivially extend via absurd; 6 active C5 cases need real updates.

2. **Fix "not actual" case** (CE:1479): Stop discarding `ξ ∈ g(x,y)`. Thread through c5_forward_witness. ~5 lines.

3. **Fix n=0 case**: Switch `lemma_2_4` → `lemma_2_4_with_guard`. ~15 lines.

4. **Fix Walk Case B eta-shortcut** (CE:984-1004): Either prove `ξ ∈ g(x, u_next)` from walk invariant, or restructure to avoid the shortcut. ~40-60 lines.

5. **Fix lemma_2_7/2_8**: Change Zorn seed from B to DC(B∪{xi}). Need helper `burgessR3_deductiveClosure_union` (~50 lines). Then `xi ∈ B'` and `B ⊆ B'` both follow. ~200 lines total including Since mirrors.

6. **Strengthen `omega_chain_c5_witness`**: Add guard to return type. ~20 lines.

7. **Close the 2 sorries**: Use `adj_g_mem_limit_f` with the guard from steps 1-6. ~60 lines.

8. **Prove NoUnivBurgessR3**: Prove `¬burgessR3 A Set.univ C` from Set.univ inconsistency. ~50-100 lines. Then make `bx_completeness` unconditional.

9. **Final validation**: `#print axioms bx_completeness`, `grep sorry`, `lake build`.

#### Priority 2: Convention Migration (8-16h, after P1)

Strategy B (full swap + variable renaming):
1. Swap constructor args at every `Formula.untl`/`Formula.snce` construction site
2. Swap `truth_at` semantics (2 lines)
3. Swap axiom definitions (~35 sites)
4. Fix `burgessR`/`burgessRSince` definitions
5. Update derived operators (next/prev)
6. Rename variables (xi↔eta where convention-bound)
7. Update all comments and docstrings
8. Audit: `lake build` + spot-check 10 axioms + 5 Chronicle lemmas

Do this on a **separate branch** to isolate risk. Both args are `Formula` type — silent corruption is the main danger. The `lake build` type checker catches structural mismatches but not same-type swaps.

#### Priority 3: Documentation and Cleanup (3-8h, can parallel P2)

- Update ROADMAP.md sorry tables (9→2 critical, stale Phase 4-6 items)
- Update Completeness.lean sorry comments (11→2)
- Delete 17 unused TemporalDerived.lean sorry stubs
- Handle `psi_imp_until`/`psi_imp_since` (delete or mark invalid)
- Update plan v63 phase statuses

#### Priority 4: Non-Critical Sorries (20-40h, deferred)

Task 109 covers the 15 BXCanonical sorries (irreflexive-consequence). The 3 RootScopedChain sorries become dead code after task 107 completes. The 6 Bundle sorries are low priority.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Sorry closure path analysis | completed | high |
| B | Convention migration scope | completed | high |
| C | Critic: gaps and blind spots | completed | medium-high |
| D | Strategic roadmap | completed | high |

## References

- Burgess, J.P. (1982). "Axioms for tense logic. I. 'Since' and 'Until'." *Notre Dame Journal of Formal Logic* 23(4): 367-374.
- Plan v63: `specs/107_.../plans/63_implementation-plan.md`
- Handoff: `specs/107_.../handoffs/burgess-c5a-alignment.md`
- Handoff: `specs/107_.../handoffs/dom-unique-done-guard-analysis.md`
- Report 67: `specs/107_.../reports/67_convention-migration-research.md`
- Report 68: `specs/107_.../reports/68_guard-condition-research.md`
