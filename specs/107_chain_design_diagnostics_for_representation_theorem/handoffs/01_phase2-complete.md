# Handoff: Task 107 — Phases 1-2 Complete, Phase 3 Partial

## Session
- **Session ID**: sess_1777387372_ae0206
- **Phases Completed**: 1 (Review), 2 (Cleanup)
- **Phase 3**: PARTIAL (c2' upgraded to BurgessR3Maximal, Xu's Lemma 3.2.1 not yet implemented)
- **Phases Remaining**: 3 (finish), 4-8
- **Build Status**: `lake build` passes (1097 jobs)

## What Was Done

### Phase 1: Review and Snapshot ROADMAP.md [COMPLETED]
- Read ROADMAP.md and identified stale claims:
  - Says "13 sorry sites remain across 4 files" -- actual count is 11 (2 RRelation, 7+2 CounterexampleElimination, 2 ChronicleToCountermodel). After Phase 2: 0 RRelation, 9 CounterexampleElimination, 2 ChronicleToCountermodel = 11 total.
  - PointInsertion.lean is sorry-free (not 4 files with sorries, just 3)
  - Module line counts are stale
  - Current Strategy section describes old plan v11 approach
- Noted items for Phase 8 ROADMAP update

### Phase 2: Cleanup [COMPLETED]
- **Deleted** `burgessR3_gamma_not_in_B_nested` and `burgessR3_gamma_not_in_B_since_nested` from RRelation.lean (INVALID under open guard)
- **Updated** call sites in CounterexampleElimination.lean (lines ~421-422, ~536-537) to use inline sorry with documentation comments
- **Updated** Completeness.lean sorry count documentation (was "4 total", corrected to "11 total")
- `lake build` passes

### Phase 3: Upgrade C2' [PARTIAL]
- **Upgraded c2' definition** in ChronicleTypes.lean from `DCS ∧ burgessR3` to `BurgessR3Maximal`
  - Old: `∀ x y, Adjacent dom x y → SetDeductivelyClosed (g x y) ∧ burgessR3 (f x) (g x y) (f y)`
  - New: `∀ x y, Adjacent dom x y → BurgessR3Maximal (f x) (g x y) (f y)`
- **Updated downstream code** in CounterexampleElimination.lean:
  - Changed `obtain ⟨h_dcs_wn, h_r3_wn⟩ := h_c2' ...` to extract from BurgessR3Maximal triple
  - Both C4 (line ~409) and C4' (line ~527) updated
- **Build passes** with upgraded c2'
- **NOT YET DONE**: Xu's Lemma 3.2.1 implementation, Since mirror, update construction sites

## Current Sorry Sites (11 total)

### CounterexampleElimination.lean (9 sorries)
1. **Line ~423**: C4 hard case nested bridging (Until) -- Phase 4
2. **Line ~539**: C4' hard case nested bridging (Since) -- Phase 4
3. **Line ~788**: c2' for C5 forward elimination -- now needs BurgessR3Maximal
4. **Line ~826**: c2' for C5 backward elimination -- now needs BurgessR3Maximal
5. **Line ~866**: c2' for C4 forward elimination -- now needs BurgessR3Maximal
6. **Line ~904**: c2' for C4 backward elimination -- now needs BurgessR3Maximal
7. **Line ~940**: c2' for G-propagation elimination -- now needs BurgessR3Maximal
8. **Line ~972**: c2' for density elimination -- now needs BurgessR3Maximal
9. **Line ~1088**: c2' for general case -- now needs BurgessR3Maximal

### ChronicleToCountermodel.lean (2 sorries)
10. **Line 615**: Forward Until coherence (FUC)
11. **Line 619**: Forward Since coherence (FUC)

## Phase 3 Remaining Work

### Xu's Lemma 3.2.1
The plan states: `BurgessR3Maximal A B C -> beta in B -> gamma in C -> untl(gamma, beta) in B`

**Implementation approach** (needs careful proof engineering):
- Proof by contradiction using maximality: if `untl(gamma, beta) not in B`, then by DCS, `{neg(untl(gamma,beta))} union B` is consistent, extend to DCS B' superset B, show `burgessR3(A, B', C)` still holds, contradicting maximality.
- The key challenge is showing `burgessR3(A, B', C)` for the extended B'. Elements of B' are in the deductive closure of `{neg(untl(gamma,beta))} union B`. For each new element alpha in B', we need `forall delta in C, untl(alpha, delta) in A`.
- BX5 (self_accum) is used to establish the required Until formulas in A.
- The `burgessR3Maximal_exists_from_seed` theorem provides the machinery.

### Since mirror
- `BurgessR3Maximal A B C -> beta in B -> alpha in A -> snce(beta, alpha) in B`

### Update construction sites
- The singleton_c2' is already vacuously true (no adjacent pairs in {0}).
- The omega_chain c2' field uses sorry sites that are already sorry'd.

## Key Files Modified
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- deleted nested bridging stubs
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- upgraded c2' to BurgessR3Maximal
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- updated c2' destructuring
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- updated sorry count docs

## Design Decisions Made
1. c2' now requires BurgessR3Maximal (full maximality), matching Burgess 1982 Definition 2.5
2. Deleted `burgessR3_gamma_not_in_B_nested` and its Since mirror (INVALID under open guard)
3. Replaced call sites with inline sorry placeholders (will be restructured in Phase 4)

## Notes for Next Agent
- `lake build` passes. No regressions.
- The c2' upgrade is a TYPE change only -- all sorry sites were already sorry'd, so the type change from `DCS ∧ burgessR3` to `BurgessR3Maximal` just changes what the sorry needs to produce.
- `burgessR3Maximal_exists_from_seed` in RRelation.lean is sorry-free and is the key tool for producing BurgessR3Maximal g-values. It requires a seed element eta with `burgessR(A, eta, C)`, `burgessRSince(C, eta, A)`, and `eta in A`.
- For each elimination function, the seed element should come from the context of the elimination (e.g., for C5 elimination, the Until guard provides the seed).
- The plan requires strict adherence to Burgess/Xu constructions per plan-compliance rule.
