# Research Report: Task #107 — Burgess Chronicle Construction

**Task**: 107 — Chain design diagnostics for representation theorem
**Date**: 2026-05-02
**Mode**: Team Research (4 teammates)
**Session**: sess_1777758350_184c2f

## Summary

Four teammates conducted parallel research into the remaining sorry sites and infrastructure needs for completing the Burgess chronicle construction. All unanimously confirmed that the 5 remaining sorry sites in PointInsertion.lean are closeable with existing BX axiom infrastructure plus a small set of helper lemmas. No new axioms or mathematical breakthroughs are needed — the gaps are engineering, not conceptual.

## Key Findings

### 1. Sorry Site Census (Unanimous)

5 active sorry sites in PointInsertion.lean across 3 theorem bodies:

| # | Line | Theorem | Difficulty | Status |
|---|------|---------|-----------|--------|
| 1 | 1573 | `burgess_D0_finite_subset_consistent` (φ∈B case) | LOW | Closeable now |
| 2 | 1581 | `burgess_D0_finite_subset_consistent` (untl case) | MEDIUM | Needs 2 helpers |
| 3 | 1584 | `burgess_D0_finite_subset_consistent` (snce case) | MEDIUM | Needs 2 helpers |
| 4 | 1614 | `burgess_D0_finite_subset_consistent_incons` | MEDIUM | Complete rewrite (simpler) |
| 5 | 2050 | `lemma_2_7_seed_consistent` | HARD | BX7 chain needed |

Additionally, 4 sorry sites exist downstream (2 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean) but these are Phases 4-5, not the current focus.

### 2. All BX Axioms Present (Teammate B, confirmed by all)

Complete inventory verified: BX5, BX7, BX10, BX13, BX14 and all Since-direction mirrors exist in Axioms.lean with MCS-level wrappers in PointInsertion.lean. No missing axioms.

**Critical note**: Burgess's A7a is REMOVED as unsound under open guard semantics. Our BX7 (`linear_until`) has different events per disjunct. This affects Lemma 2.7 but the proof still works (Teammates A and D confirmed via case analysis).

### 3. All Derivation-Level Tools Present (Teammate B)

`untl_left_mono_deriv`, `snce_left_mono_deriv`, `untl_right_mono_deriv`, `list_conj_implies_elem`, `derivation_from_implied`, `iterated_enrichment` — all proved (no sorry).

### 4. Required Helper Lemma Inventory (Teammate A, refined by B)

**Tier 1 — Blocking sites 1-3:**

| Helper | Signature | Difficulty |
|--------|-----------|-----------|
| `collect_guards_mem_of_untl` | If `untl(β',γ')∈L`, then `β'∈collect_guards output` | LOW (mirrors `collect_guards_mem_of_B`) |
| `collect_guards_mem_of_snce` | If `snce(β',α')∈L`, then `β'∈collect_guards output` | LOW (same pattern) |
| `d0_c_event_list_γ_mem` | If `untl(β',γ')∈L`, then `γ'∈d0_c_event_list` | MEDIUM (filterMap + `Formula.untl.injEq`) |
| `d0_a_event_list_α_mem` | If `snce(β',α')∈L`, then `α'∈d0_a_event_list` | MEDIUM (filterMap + `Formula.snce.injEq`) |

**Note on Classical.choose**: All teammates identified the `d0_guard`/`d0_c_event_list`/`d0_a_event_list` Classical.choose issue. The resolution is Formula constructor injectivity: `untl(β'',γ'') = untl(β',γ')` implies `β''=β'` and `γ''=γ'` by `Formula.untl.injEq` (derived from `DecidableEq`). This makes Classical.choose deterministic for these cases.

**Tier 2 — Site 4 (inconsistent case):**

No new helpers needed. The inconsistent case can either:
- (a) Reuse `burgess_D0_finite_subset_consistent` with β₀=β.neg as witness (Teammates C, D recommend this), OR
- (b) Be a standalone simpler proof without BX14 (Teammate A analysis)

**Tier 3 — Site 5 (lemma_2_7_seed_consistent):**

| Helper | Difficulty |
|--------|-----------|
| `lemma_2_7_neg_untl_exists`: Extract β₀∈B, γ₀∈C with ¬U(β₀∧eta, γ₀)∈A | LOW |
| `lemma_2_7_zeta_consistent`: BX5+BX7+BX13+BX10 chain with xi/eta | HARD |

### 5. Dead Code Inventory (Teammate C)

| Item | Lines | Action |
|------|-------|--------|
| `until_implies_F_mcs` | 1000-1004 | Remove (duplicate of `until_F_mcs`) |
| `and_left_impl`/`and_right_impl` | 1047-1054 | Remove (trivial wrappers around `lce_imp`/`rce_imp`) |
| `collect_guards_mem_of_B` | 1432-1444 | KEEP but wire into sorry at 1573 |
| ~250 lines inline design commentary | 1633-1900 | Reduce to concise proof comments |

### 6. Downstream Caller Gap (Teammate C critical finding)

`lemma_2_6_splitting` and `lemma_2_7` have **NO callers** in ChronicleConstruction.lean or CounterexampleElimination.lean. They must be wired into the C4/C4' hard cases (Phase 4) to complete the construction.

## Synthesis

### Conflicts Resolved

1. **Sorry count discrepancy**: Plan says "3 sorries", teammates found 5. Resolution: 3 theorem-level sorry bodies, but `burgess_D0_finite_subset_consistent` has 3 internal sorry branches (1573/1581/1584). Both counts are correct at different granularity levels.

2. **Infrastructure completeness**: Teammate B says "no missing infrastructure", Teammate A lists 4 missing helpers. Resolution: All BX axioms and derivation tools exist. The missing pieces are **membership-tracking lemmas** for the compression argument's finite-list operations, not axiom-level tools. Both are correct.

3. **Inconsistent case approach**: Teammate A proposes standalone proof, Teammates C/D propose reusing consistent case. Resolution: Reusing `burgess_D0_finite_subset_consistent` with β₀=β.neg is cleaner if the witnesses can be constructed. Standalone is fallback if witness extraction is difficult.

### Gaps Identified

1. **Formula constructor injectivity**: Need to verify `Formula.untl.injEq` and `Formula.snce.injEq` exist or can be derived from `deriving DecidableEq`. This is critical for Tier 1 helpers.

2. **BX7 at MCS level**: Need `linear_until_mcs` wrapper (BX7 with MCS-level inputs/outputs). Teammate B noted BX7 exists as axiom but no MCS wrapper was found.

3. **Argument order convention**: Multiple teammates noted the Burgess vs codebase convention difference for untl/snce argument order. The codebase uses `untl(guard, event)` while Burgess uses `U(event, guard)`. This must be tracked carefully during implementation.

### Execution Plan

**Phase A: Foundation (1-2 hours)**
1. Verify Formula.untl.injEq / Formula.snce.injEq exist
2. Add `collect_guards_mem_of_untl` and `collect_guards_mem_of_snce`
3. Add `d0_c_event_list_γ_mem` and `d0_a_event_list_α_mem`
4. Remove dead code (until_implies_F_mcs, and_left_impl, and_right_impl)

**Phase B: Close sites 1-3 (2-3 hours)**
1. Site 1 (1573, φ∈B): Wire `collect_guards_mem_of_B` → `list_conj_implies_elem` → `imp_trans h_ev_b`
2. Site 2 (1581, untl): Use collect_guards + d0_c_event_list_γ_mem → left_mono + right_mono
3. Site 3 (1584, snce): Use collect_guards + d0_a_event_list_α_mem → left_mono

**Phase C: Close site 4 (1-2 hours)**
Reuse `burgess_D0_finite_subset_consistent` with witnesses β₀=β.neg, γ₀∈C, h_neg_until via inconsistency of β.neg∧β.

**Phase D: Close site 5 (3-5 hours)**
1. Add `lemma_2_7_neg_untl_exists`
2. Build `lemma_2_7_zeta_consistent` with BX5+BX7+BX13+BX10 chain
3. Wire into `lemma_2_7_seed_consistent`

**Total estimated effort**: 7-12 hours for all 5 sorry sites.

### Phases 4-8 Assessment (Teammate D)

After PointInsertion sorries are closed:
- **Phase 4** (C4/C4' hard case): Restore c2' as omega_chain invariant, wire lemma_2_6_splitting. 6-12 hours.
- **Phase 5** (FUC/FSC): Prove limit_satisfies_c5_full, close ChronicleToCountermodel sorries. 3-6 hours.
- **Phase 6** (Final audit): 1-2 hours.

No mathematical obstacles identified in Phases 4-8. All are engineering/formalization work.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Sorry site analysis + helper inventory | completed | high |
| B | BX axiom + derivation tool audit | completed | high |
| C | Cruft audit + code quality | completed | high |
| D | Burgess paper deep dive + roadmap | completed | high |

## References

- Burgess, J. P. (1982). "Axioms for tense logic. I. 'Since' and 'Until'." Notre Dame Journal of Formal Logic, 23(4), 367-374.
- Implementation plan v52: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/52_implementation-plan.md`
- Burgess paper (local): `/home/benjamin/Projects/ProofChecker/literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
