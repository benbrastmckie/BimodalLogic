# Research Report: Task #107 -- g-Value Construction Blocker Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1777428819_57c6d5

## Summary

All 4 teammates converge on a single diagnosis and a single recommended fix. The 7 c2' sorry sites in CounterexampleElimination.lean are caused by an **architectural mismatch** between Burgess's proof and the formalization: Burgess constructs f-values (MCS endpoints) and g-values (DCS interval sets) **jointly** at each elimination step via Lemmas 2.4/2.6/2.7/2.8, but the formalization decouples them -- it constructs new f-values while leaving g unchanged (`g' = chi.g`). The fix is to restructure the elimination functions to produce g-values for new adjacent pairs, matching Burgess's simultaneous construction.

Resolution Path 1 (seed lemma from g_content) is **dead** -- BX8 was removed in task 113, so the G-to-Until bridge is impossible. Resolution Path 4 (remove c2' from invariant) is **not feasible** -- c2' is consumed in sorry-free C4/C4' elimination code (lines 409, 546). The only viable path is **Path 2: restructure elimination functions to implement Burgess's Lemma 2.6 splitting**.

## Key Findings

### 1. Root Cause: g-Values Never Constructed (Unanimous)

All teammates confirm: the chronicle's g function starts as `fun _ _ => empty_set` (singleton chronicle) and is never modified by any elimination function. Each `eliminate_C5_counterexample`, `eliminate_C4_counterexample`, etc. sets `g' = chi.g`, passing through the old g unchanged. New adjacent pairs created by point insertion therefore have g = empty_set, and `BurgessR3Maximal(A, empty_set, C)` is false because empty_set is not DCS.

**Burgess's approach**: At every finite stage, elimination lemmas produce g-values for new adjacent pairs:
- **Lemma 2.4** (C5 elimination): Given U(gamma, beta) in A, produces B (DCS) and C (MCS) with R(A,B,C). Sets `g'(x,y) = B`, `f'(y) = C`.
- **Lemma 2.6** (C4 elimination): Given R(A,B,C) and delta not in B, produces B', D, B'' with R(A,B',D), R(D,B'',C), and B = B' cap D cap B''. Sets `g'(x,z) = B'`, `f'(z) = D`, `g'(z,y) = B''`.
- **C3 determines non-adjacent g-values**: `g'(w,z) = g(w,x) cap f(x) cap g'(x,z)`.

**The formalization's `lemma_2_4`** (PointInsertion.lean) returns C (the MCS) but **discards B** (the DCS). This is where the construction diverges from the paper.

### 2. Resolution Path 1 Is Dead (Unanimous)

The seed lemma approach requires deriving `untl(eta, gamma) in A` from `G(eta) in A`, which needs `G(eta) -> eta U gamma`. This requires BX8, which was **removed in task 113** (open guard semantics). The file `TemporalDerived.lean` confirms `G_implies_topUntil` is sorry-stubbed with "Requires BX8 (removed)."

No combination of BX6/BX7/BX10 can substitute:
- BX10: `(phi U psi) -> F(psi)` -- extracts eventuality from existing Until, cannot CREATE Until from G
- BX7: relates two existing Until formulas, cannot bridge from G
- BX6: absorbs nested Untils, cannot bridge from G

### 3. Resolution Path 4 Is Not Feasible (Teammates B, C confirm)

`omega_chain_c2'` is indeed never used downstream at the limit level. However, `h_c2'` IS consumed **within** the C4/C4' elimination functions themselves:
- **Line 409**: `have h_r3m_wn := h_c2' w w_next h_adj` -- sorry-free code that extracts BurgessR3Maximal for the adjacent pair to perform the C4 hard case bridging argument
- **Line 546**: Mirror for C4'

Removing c2' from EliminationResult would break this sorry-free code. Moreover, even if c2' were removed, the limit g would still be empty_set everywhere (since no finite stage ever populates it), making C2 at the limit false. **Removing c2' moves the problem, not solves it.**

Burgess 1982, Section 2.9: "Case n = 0. By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6..." -- C2' is the premise that triggers Lemma 2.6.

### 4. Chronicle Construction Is the Only Viable Path (Teammate D)

Survey of all alternative literature:
- **Reynolds 1992**: Uses Burgess construction directly ("the more complicated U and S construction of Burgess is necessary for us"). Does NOT avoid g-values.
- **Verbrugge 2004**: Only handles G/H (no Until/Since). Not applicable.
- **FMP**: Dead end #10 in ROADMAP. Cannot bridge to completeness.
- **Clean sheet**: Would look almost identical to current codebase. Wastes 5787 lines of sorry-free work.

95% of existing code is sorry-free and fully salvageable. The g-value problem is **local** (concentrated in elimination function outputs), not a fundamental architectural flaw of the chronicle approach.

### 5. The Fix: Restructure Elimination Functions (Unanimous)

Each elimination function must be modified to construct and return proper g-values:

| Elimination | Burgess Lemma | New g-values | Input |
|-------------|---------------|--------------|-------|
| C5 forward | 2.4 | g'(x_max, y) = B from Lemma 2.4 | U(gamma, beta) in f(x_max) |
| C5 backward | 2.4 (Since) | g'(y, x_min) = B from Lemma 2.4 | S(gamma, beta) in f(x_min) |
| C4 forward | 2.6 | g'(x,z) = B', g'(z,y) = B'' | R(f(x), g(x,y), f(y)), delta not in g(x,y) |
| C4 backward | 2.6 (mirror) | Mirror | Mirror |
| G-prop | 2.6 (variant) | Split existing g via absorption | Same as C4 |
| H-prop | 2.6 (variant) | Mirror | Mirror |
| Density | Special | g'(x,z) via Lemma 2.4 on f(x),f(x) | Self-pair |

**Critical prerequisite**: `lemma_2_4` must be extended to also return B (the DCS interval set), not just C (the MCS endpoint). Currently it returns `exists C, SetMaximalConsistent C /\ ...` but discards B entirely.

**For C4/g_prop/h_prop**: Need to formalize Lemma 2.6 as a function taking R(A,B,C) and delta not in B, returning B', D, B'' with R(A,B',D), R(D,B'',C), B = B' cap D cap B''. The existing `burgessR3Maximal_extension_exists` in RRelation.lean provides the maximality infrastructure; Lemma 2.6 is the construction that decomposes an existing R into two halves around a new point.

### 6. Remaining Distance After This Fix

| Phase | Sorry Sites | Effort | Description |
|-------|-------------|--------|-------------|
| g-value infrastructure | 0 new | 8-12h | Extend lemma_2_4 to return B; formalize Lemma 2.6 splitting |
| C5 c2' closure | 2 sites | 8-12h | Use extended lemma_2_4 for new endpoint pairs |
| C4/g_prop/h_prop c2' | 4 sites | 12-18h | Use Lemma 2.6 splitting for inserted points |
| Density c2' | 1 site | 4-6h | Special case: self-pair via intermediate MCS |
| FUC/FSC wiring | 2 sites | 6-10h | Thread C3+C5 through Cantor isomorphism |
| Verification | 0 sites | 2-3h | lake build, #print axioms audit |
| **Total** | **9 sites** | **40-61h** | |

After all 9 sorry sites are closed, `dd_countermodel_chronicle` becomes sorry-free, and `#print axioms bx_completeness` should show no sorryAx.

## Synthesis

### Conflicts Found and Resolved

**Conflict 1: Local vs Architectural**
- Teammate A and C: "architectural mismatch" -- elimination functions need restructuring
- Teammate D: "local, not architectural" -- just filling in blanks, 95% of code salvageable

**Resolution**: Both are partially correct. The fix requires **modifying the elimination function outputs** (adding g-value construction), which is a structural change to those specific functions (~200-400 lines of new code across 6 cases). However, it does NOT require redesigning the chronicle types, omega chain, limit construction, or any of the 5000+ lines of surrounding sorry-free infrastructure. The scope is "local restructuring" within elimination functions, not "global architectural redesign."

**Conflict 2: Teammate C's self-correction on Path 4**
Teammate C initially suggested c2' could be removed since it's not used downstream, then corrected mid-analysis: c2' is consumed within the elimination functions themselves (lines 409, 546). The final assessment aligns with Teammate B's analysis.

### Gaps Identified

1. **Lemma 2.6 not yet formalized**: The splitting lemma (taking R(A,B,C) and producing B',D,B'') is the mathematical heart of the fix but has no Lean implementation yet. This is the critical prerequisite.

2. **lemma_2_4 returns C but not B**: The DCS component is discarded. Extending the return type is straightforward but requires updating all call sites.

3. **Open guard interaction with Lemma 2.6**: Burgess uses closed guard; our semantics use open guard. Teammate C flags this as a risk: does the Zorn extension in `burgessR3Maximal_extension_exists` still work under the open-guard r-relation? This needs verification.

4. **Density case is non-Burgess**: The self-pair case (f(z) = f(x)) doesn't appear in Burgess 1982 -- it's a formalization-specific addition. Needs special treatment since standard Lemma 2.4/2.6 assumes distinct endpoints.

### Recommendations

1. **Proceed with Path 2**: Restructure elimination functions to construct g-values using Lemma 2.4 (for C5) and Lemma 2.6 (for C4/g_prop/h_prop)
2. **Start with infrastructure**: Extend `lemma_2_4` to return B, then formalize Lemma 2.6 as a new theorem in RRelation.lean or PointInsertion.lean
3. **Verify open-guard compatibility**: Before deep implementation, verify that `burgessR3Maximal_extension_exists` works correctly under open-guard burgessR3 relation
4. **Handle density case separately**: The self-pair case needs a dedicated argument not covered by Burgess

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Burgess g-construction | completed | high | Traced exact mechanism: lemma_2_4 discards B, 3 insertion patterns identified |
| B | c2' removal feasibility | completed | high | Definitively proved Path 4 infeasible: c2' consumed at lines 409/546 |
| C | Critic / gap validation | completed | high | Path 1 dead (BX8 removed), architectural mismatch precisely characterized |
| D | Strategic horizons | completed | high | All alternatives surveyed and eliminated; 44-65h estimate; 95% code salvageable |

## References

- Burgess 1982, "Axioms for tense logic I: 'Since' and 'Until'" -- Sections 2.4-2.10
- Xu 1988, "On some US-tense logics" -- Section 2 (confirms axiom system correctness)
- Reynolds 1992 -- Confirms chronicle is necessary for Until/Since
- Verbrugge 2004 -- G/H only, not applicable
- Handoff artifact: `specs/107_.../handoffs/41_phase5-blocker-analysis.md`
- CounterexampleElimination.lean lines 830, 868, 908, 946, 982, 1014, 1130
- RRelation.lean: `burgessR3Maximal_extension_exists`, `burgessR3Maximal_exists_from_seed`
- PointInsertion.lean: `lemma_2_4` (currently discards DCS component)
