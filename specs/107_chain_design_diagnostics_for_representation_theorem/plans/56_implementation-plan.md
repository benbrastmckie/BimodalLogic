# Implementation Plan: Task #107 — Chronicle Construction (Revised with Definition Fix)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 22-30 hours
- **Dependencies**: None (self-contained within Chronicle/)
- **Research Inputs**: reports/56_phase2-resolution.md (root cause analysis of Phase 2 blocker)
- **Artifacts**: plans/56_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 12 remaining sorries across PointInsertion.lean (3), CounterexampleElimination.lean (7), and ChronicleToCountermodel.lean (2) by first fixing the `BurgessR3Maximal` definition to match Burgess 1982 (strengthening the maximality clause from `SetDeductivelyClosed D` to `ClosedUnderDerivation D`), then implementing the uniform proof approach that eliminates the inconsistent case entirely. The definition fix unblocks Phase 2 from the prior plan by allowing `BurgessR3Maximal_extension_fails` to work without a consistency hypothesis, making BX14 witnesses available in all cases.

### Research Integration

Report 56 identifies the root cause of the Phase 2 blocker: the maximality clause in `BurgessR3Maximal` (ChronicleTypes.lean:323) restricts maximality to `SetDeductivelyClosed D` (which requires consistency), whereas Burgess 1982 Section 2.3 uses ALL deductively closed sets (including inconsistent ones like `Set.univ`). The fix: change `SetDeductivelyClosed D` to `ClosedUnderDerivation D` in the maximality clause. This makes the proof uniform -- no consistent/inconsistent case split is needed, and the `burgess_D0_finite_subset_consistent_incons` function (lines 1811-1976) becomes deletable.

### Prior Plan Reference

Plan 58 had 8 phases. Phase 1 (foundation audit) was marked [PARTIAL] and Phase 6 (omega_chain c2' threading) was [COMPLETED]. Phase 2 (Lemma 2.6 inconsistent case) was BLOCKED by the mathematical gap that research report 56 resolves. Effort calibration from plan 58: Lemma 2.7 is the hardest theorem at 4-5 hours; C4/C5 co-construction takes 6-8 hours; limit C5 full + FUC/FSC takes 6-8 hours. The validated approach for Phases 3-8 is preserved with adjustments. The omega_chain c2' threading (old Phase 6) is already done and does not need a new phase.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix `BurgessR3Maximal` definition to match Burgess 1982 (maximality over `ClosedUnderDerivation`)
- Close all 12 sorries: 3 in PointInsertion.lean, 7 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean
- Delete the unnecessary `burgess_D0_finite_subset_consistent_incons` function (~170 lines)
- Deliver fully sorry-free `dd_countermodel_chronicle`

**Non-Goals**:
- Rewrite the elimination algorithm structure (flat approach is equivalent to Burgess's induction)
- Introduce new axioms or change semantics
- Modify limit_dom, limit_f, limit_g, limit_c3 (all already sorry-free)
- Add Lemma 2.8 as a separate theorem (absorbed into Lemma 2.7 via strengthened gamma)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zorn construction proof needs update for stronger maximality | Delays Phase 1 by 2-3h | Medium | Alternative: add `neg burgessR3 A Set.univ C` as hypothesis (provable at all call sites) |
| Lemma 2.7 BX7 three-way combinatorially blocked | Delays Phase 3 by 3-5h | Medium | Use `lce_imp`/`rce_imp` for propositional simplifications; existing left/right mono tools |
| g-value construction breaks all call sites | Build churn | High | Commit after each elimination function change; fix call sites incrementally |
| `finite_stage_guard_in_g` lemma unprovable (Phase 6) | Blocks limit C5a | Low | Direct approach: use limit_g definition + c2' invariant to show guard universally present |
| Downstream uses of BurgessR3Maximal broken by definition change | Build errors in Phase 1 | Low | The change is strictly MORE permissive in the maximality clause; all existing uses remain valid |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are independent (both only need Phase 1). Phases 4-7 are sequential on the critical path.

Critical path: Phase 1 (2-3h) -> Phase 3 (4-5h) -> Phase 4 (7-9h) -> Phase 5 (3-4h) -> Phase 6 (5-7h) -> Phase 7 (1-2h) = 22-30h.

---

### Phase 1: Definition Fix and Foundation [PARTIAL]

**Goal**: Fix the `BurgessR3Maximal` definition, update the Zorn construction proof, remove the `h_cons` hypothesis from `BurgessR3Maximal_extension_fails`, add `deductiveClosure_closed_under_derivation` lemma, and verify the build passes with no regressions.

**Tasks**:
- [ ] **Task 1.1**: Change `BurgessR3Maximal` maximality clause (ChronicleTypes.lean:323) from `SetDeductivelyClosed D` to `ClosedUnderDerivation D`. The first two conjuncts remain unchanged (`SetDeductivelyClosed B` and `burgessR3 A B C`).
- [ ] **Task 1.2**: Add lemma `deductiveClosure_closed_under_derivation` in RRelation.lean proving that `deductiveClosure S` is always `ClosedUnderDerivation` (regardless of consistency). Derive from existing `deductiveClosure_closed` (RRelation.lean:156-189).
- [ ] **Task 1.3**: Update `burgessR3Maximal_extension_exists` (RRelation.lean:724-765) for the stronger maximality. The Zorn-maximal B over `burgessR3DCSExtensions` (consistent DCSs) must also be maximal over all `ClosedUnderDerivation` sets. Proof strategy: if D is `ClosedUnderDerivation` with `B subset D` and `burgessR3(A,D,C)`, case split on D's consistency. If D consistent: D is DCS, contradicts Zorn maximality. If D inconsistent: `burgessR3_univ_of_inconsistent_ext` (PointInsertion.lean:719, already proved) shows `burgessR3(A, Set.univ, C)` holds; `dcs_ssubset_univ` (line 703) gives `B subset Set.univ`; maximality over consistent DCSs gives contradiction (since any consistent DCS extending B would inherit burgessR3 from Set.univ by anti-monotonicity of burgessR3).
- [ ] **Task 1.4**: Remove `h_cons` hypothesis from `BurgessR3Maximal_extension_fails` (PointInsertion.lean:566-579). New proof: `deductiveClosure ({delta} union B)` is `ClosedUnderDerivation` (from Task 1.2), and `B subset deductiveClosure({delta} union B)` proper (since delta in DC but not in B). Apply the strengthened maximality clause directly.
- [ ] **Task 1.5**: Update all call sites of `BurgessR3Maximal_extension_fails` that currently pass `h_cons`. Remove the consistency argument at each site. Verify `lake build` passes.
- [ ] **Task 1.6**: Verify the existing `g_content_sub_B` proof (PointInsertion.lean:744-756) still works -- it already uses the inconsistent-case strategy via `burgessR3_univ_of_inconsistent_ext` + `Set.univ` + maximality over `ClosedUnderDerivation`.

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `ChronicleTypes.lean:323` - Change maximality clause
- `RRelation.lean` - Add `deductiveClosure_closed_under_derivation`; update `burgessR3Maximal_extension_exists`
- `PointInsertion.lean:566-579` - Remove `h_cons` from `BurgessR3Maximal_extension_fails`
- `PointInsertion.lean` - Update call sites

**Verification**:
- `lake build` passes with no new errors
- `BurgessR3Maximal_extension_fails` no longer requires consistency hypothesis
- Existing proofs using BurgessR3Maximal compile unchanged (the change is strictly more permissive)

---

### Phase 2: Lemma 2.6 — Unified Seed Consistency [NOT STARTED]

**Goal**: Close the 2 sorries at PointInsertion.lean:1872-1873 by eliminating the inconsistent case entirely. With the definition fix, `BurgessR3Maximal_extension_fails` works without `h_cons`, so the BX14 chain applies uniformly. Delete `burgess_D0_finite_subset_consistent_incons` (lines 1811-1976).

**Paper reference**: Burgess Section 2.6, p.370-371 (D0 seed consistency, now uniform)

**Tasks**:
- [ ] **Task 2.1**: In `burgess_D0_seed_consistent` (line 1985-2004), remove the `by_cases h_cons` split. Replace with the single uniform proof path: call `BurgessR3Maximal_extension_fails` (no consistency argument needed) to get `neg burgessR3(A, DC({beta} union B), C)`, then extract Until-direction witness `beta0, gamma0` with `neg untl(beta0 and beta, gamma0) in A`.
- [ ] **Task 2.2**: Chain BX5 + BX14 + BX13 + BX10 to produce the enriched event (same as current consistent case at lines 2044-2143). The event contains `b` and `untl(b, gamma_hat)` as components, so `h_ev_b` and `h_ev_untl` are trivial conjunction eliminations.
- [ ] **Task 2.3**: Prove `SetConsistent ({beta.neg} union B)` for the `burgess_D0_finite_subset_consistent` call. Two sub-cases: if `{beta} union B` was consistent, then beta not in B and B DCS gives `beta.neg not in B` so `{beta.neg} union B` consistent by DNE argument; if `{beta} union B` was inconsistent, then `beta.neg in B` so `{beta.neg} union B = B` which is consistent.
- [ ] **Task 2.4**: Delete `burgess_D0_finite_subset_consistent_incons` (lines 1811-1976) and its call site in `burgess_D0_seed_consistent`. Clean up any unused helper functions.
- [ ] **Task 2.5**: Verify `lemma_2_6_splitting` (line 2328) still compiles and the sorry count for PointInsertion.lean drops from 3 to 1.

**Timing**: 2-3 hours

**Depends on**: 1

**Files to modify**:
- `PointInsertion.lean:1811-1976` - Delete `burgess_D0_finite_subset_consistent_incons`
- `PointInsertion.lean:1985-2319` - Unify `burgess_D0_seed_consistent` to single path

**Verification**:
- `PointInsertion.lean` sorry count: 3 -> 1 (only `lemma_2_7_seed_consistent` remains)
- `lake build` passes
- `lemma_2_6_splitting` compiles

---

### Phase 3: Lemma 2.7 — Seed Consistency (BX7 Three-Way) [NOT STARTED]

**Goal**: Implement `lemma_2_7_seed_consistent` (PointInsertion.lean:2414). This is the hardest single theorem -- the BX7 three-way disjunction with D1/D2 elimination.

**Paper reference**: Burgess Section 2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)

**Tasks**:
- [ ] **Task 3.1**: Implement witness extraction -- from `eta not in B` + BurgessR3Maximal (now with stronger maximality), call `BurgessR3Maximal_extension_fails` (no h_cons needed) to extract `beta0 in B, gamma0 in C` with `neg untl(beta0 and eta, gamma0) in A`. Use `dc_delta_B_controlled` for the extraction.
- [ ] **Task 3.2**: Apply BX5 self-accumulation on both Until formulas: `untl(beta0 and untl(beta0,gamma0), gamma0) in A` and `untl(xi and untl(xi,eta), eta) in A`.
- [ ] **Task 3.3**: Apply BX7 three-way disjunction (`linear_until_mcs`) to produce D1 or D2 or D3 in A (by MCS disjunction property).
- [ ] **Task 3.4**: Eliminate D1 -- left_mono on event containing `eta and gamma0` reduces to `gamma0`, right_mono on guard theta to `beta0 and eta` gives `untl(gamma0, beta0 and eta) in A`, contradicting the witness.
- [ ] **Task 3.5**: Eliminate D2 -- similar left_mono + right_mono argument (mirror of D1).
- [ ] **Task 3.6**: Work with surviving D3. Apply right_mono to reduce guard from theta to `beta0 and eta`. Apply BX14 separation with witness `neg untl(gamma0, beta0 and eta) in A`, then BX13 iterated enrichment to pack snce-formulas, then BX10 for F(event) in A.
- [ ] **Task 3.7**: Assemble proof: show event implies all 5 seed components (B-elements via b conjunction, xi from event component, untl/snce formulas via mono). Close `lemma_2_7_seed_consistent` and verify `lemma_2_7` (line 2416) compiles.

**Timing**: 4-5 hours

**Depends on**: 1

**Files to modify**:
- `PointInsertion.lean:2414` - Replace sorry with full proof

**Verification**:
- `PointInsertion.lean` sorry count: 1 -> 0
- `lemma_2_7` (line 2416) compiles
- `lake build` passes

---

### Phase 4: C4/C5 Elimination — Co-Constructed g-Values and c2' [NOT STARTED]

**Goal**: Rewrite C4, C4', C5, C5' elimination functions in CounterexampleElimination.lean to populate g-values at new adjacent pairs, then close all 5 c2' sorries (lines 756, 794, 834, 872, 918). After this phase, g-values at new adjacent pairs satisfy `BurgessR3Maximal` and the c2' invariant is maintained.

**Paper reference**: Burgess Sections 2.9 (p.373) and 2.10 (p.374)

**Tasks**:
- [ ] **Task 4.1**: Rewrite `eliminate_C5_counterexample` (line 167) -- extract B from `lemma_2_4`, set `g'(x, y) = B`. Update return type to allow g_changed for the new pair.
- [ ] **Task 4.2**: Rewrite `eliminate_C5'_counterexample` -- mirror for Since.
- [ ] **Task 4.3**: Rewrite `eliminate_C4_counterexample` (line 304) -- call `lemma_2_6_splitting`, set `g'(x,z)=B'`, `g'(z,y)=B''`. Handle easy cases with `burgessR3Maximal_singleton`.
- [ ] **Task 4.4**: Rewrite `eliminate_C4'_counterexample` -- mirror for Since.
- [ ] **Task 4.5**: Fix call sites in `eliminate_potential_counterexample` and `omega_chain`. Verify compilation.
- [ ] **Task 4.6**: Close C5 forward c2' (line 756) -- use Task 4.1 output (BurgessR3Maximal from lemma_2_4).
- [ ] **Task 4.7**: Close C5' backward c2' (line 794) -- mirror.
- [ ] **Task 4.8**: Close C4 forward c2' (line 834) -- from lemma_2_6_splitting output, handle old pairs (inherit) and new pairs.
- [ ] **Task 4.9**: Close C4' backward c2' (line 872) -- mirror.
- [ ] **Task 4.10**: Close density c2' (line 918) -- new point copies f(x); prove maximality for both new adjacent pairs.

**Timing**: 7-9 hours

**Depends on**: 2, 3

**Files to modify**:
- `CounterexampleElimination.lean:167` - Rewrite C5 elimination
- `CounterexampleElimination.lean:304` - Rewrite C4 elimination
- `CounterexampleElimination.lean:756,794,834,872,918` - Close c2' sorries

**Verification**:
- `CounterexampleElimination.lean` sorry count: 7 -> 2 (C4 hard cases remain)
- All four elimination functions compile with populated g-values
- `omega_chain` compiles with c2' invariant

---

### Phase 5: C4 Hard Cases — BurgessR3 Bridging [NOT STARTED]

**Goal**: Close the 2 hard-case sorries at CounterexampleElimination.lean lines 412 (C4 forward) and 510 (C4' backward).

**Paper reference**: Burgess Section 2.9 (C4 hard case -- gamma in f(w) and f(w_next))

**Tasks**:
- [ ] **Task 5.1**: Close C4 forward hard case (line 412) -- apply `BurgessR3Maximal_extension_fails` (no h_cons needed) at `(f(w), g(w,w_next))` with extension candidate `gamma`. Extract witness, derive contradiction with counterexample condition. Assemble output with new midpoint MCS D where `gamma.neg in D`.
- [ ] **Task 5.2**: Close C4' backward hard case (line 510) -- mirror for Since using `BurgessR3MaximalSince_extension_fails`.

**Timing**: 3-4 hours

**Depends on**: 4

**Files to modify**:
- `CounterexampleElimination.lean:412` - Close C4 forward hard case
- `CounterexampleElimination.lean:510` - Close C4' backward hard case

**Verification**:
- `CounterexampleElimination.lean` sorry count: 2 -> 0
- Both C4/C4' elimination functions fully sorry-free
- `lake build` passes

---

### Phase 6: Limit C5 Full + FUC/FSC [NOT STARTED]

**Goal**: Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` in ChronicleConstruction.lean, then close the 2 FUC/FSC sorries in ChronicleToCountermodel.lean (lines 615, 619).

**Paper reference**: Burgess Claim 2.11, p.375 (truth lemma -- forward Until/Since coherence at limit)

**Tasks**:
- [ ] **Task 6.1**: Prove `finite_stage_guard_in_g` -- by induction on finite stage n, show that when witness y is added, guard xi is in every g-value for adjacent pairs between x and y. Uses c2' invariant (Phase 4/5) and the fact that Lemma 2.4's BurgessR3Maximal includes the guard in the interval DCS.
- [ ] **Task 6.2**: Lift `finite_stage_guard_in_g` to `xi in limit_g(x,y)` using C3 at the limit (`limit_c3_interval_subset_point`).
- [ ] **Task 6.3**: Assemble `limit_satisfies_c5_full` -- combine Tasks 6.1-6.2 with `limit_satisfies_c5_weak`.
- [ ] **Task 6.4**: Mirror `limit_satisfies_c5'_full` for Since.
- [ ] **Task 6.5**: Close FUC (ChronicleToCountermodel.lean:615) -- unpack hfam hypothesis to get Cantor preimages, apply `limit_satisfies_c5_full`, transfer back through isomorphism using `cantor_bfmcs` ordering/coherence properties.
- [ ] **Task 6.6**: Close FSC (ChronicleToCountermodel.lean:619) -- mirror.

**Timing**: 5-7 hours

**Depends on**: 5

**Files to modify**:
- `ChronicleConstruction.lean` - Add `finite_stage_guard_in_g`, `limit_satisfies_c5_full`, `limit_satisfies_c5'_full`
- `ChronicleToCountermodel.lean:615,619` - Close FUC/FSC sorries

**Verification**:
- `ChronicleToCountermodel.lean` sorry count: 2 -> 0
- `dd_countermodel_chronicle` fully sorry-free
- `lake build` passes

---

### Phase 7: Final Audit and Integration [NOT STARTED]

**Goal**: Verify the entire Chronicle/ directory is sorry-free and the countermodel construction delivers the representation theorem.

**Tasks**:
- [ ] **Task 7.1**: Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`.
- [ ] **Task 7.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment occurrences.
- [ ] **Task 7.3**: Full `lake build` clean from scratch.
- [ ] **Task 7.4**: Generate summary artifact: `specs/107_.../summaries/56_execution-summary.md` with verification results, axiom audit, and metrics (sorry count 12 -> 0).

**Timing**: 1-2 hours

**Depends on**: 6

**Files to modify**:
- None (verification only)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/56_execution-summary.md` - Create summary artifact

**Verification**:
- Chronicle/ sorry count: 0
- `dd_countermodel_chronicle` has no `sorryAx` in its axioms
- Full `lake build` clean

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary
- [ ] `#print axioms dd_countermodel_chronicle` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `BurgessR3Maximal_extension_fails` compiles without `h_cons` parameter
- [ ] All elimination functions' g-field non-empty for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`

## Artifacts & Outputs

- `plans/56_implementation-plan.md` (this file)
- `summaries/56_execution-summary.md` (Phase 7)
- Modified source files:
  - `ChronicleTypes.lean` (Phase 1 -- definition fix)
  - `RRelation.lean` (Phase 1 -- Zorn update, new lemma)
  - `PointInsertion.lean` (Phases 1, 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5)
  - `ChronicleConstruction.lean` (Phase 6)
  - `ChronicleToCountermodel.lean` (Phase 6)

## Rollback/Contingency

- **If Zorn construction update proves difficult (Phase 1 Task 1.3)**: Add `neg burgessR3 A Set.univ C` as an explicit hypothesis to `burgessR3Maximal_from_g_content_sub` and prove it at each call site. This sidesteps the need to prove the inconsistent D case inside the Zorn construction itself.
- **If `finite_stage_guard_in_g` proves unprovable (Phase 6)**: Fall back to direct approach using limit_g definition + c2' invariant -- since limit_g is defined as formulas true at ALL intermediate points, guard propagation follows directly from the finite-stage c2' property.
- **If g-value construction too invasive (Phase 4)**: Start with C5 forward only (critical path). Use trivial g-values for other directions, expand later.
- **Build instability**: Commit after each task modification. Verify `lake build` incrementally.

## Implementation Agent Notes

1. **Phase 1 is the keystone** -- the definition fix cascades through all later phases by eliminating the consistency requirement from `BurgessR3Maximal_extension_fails`. All subsequent phases become simpler.
2. **Argument order convention**: `untl(guard, event)` in our code = `U(event, guard)` in Burgess. Arguments are SWAPPED.
3. **Existing infrastructure already anticipates the fix**: `set_univ_closed_under_derivation` (line 606), `dcs_ssubset_univ` (line 703), `burgessR3_univ_of_inconsistent_ext` (line 719) are all in place for the Zorn update.
4. **Commit after each phase**, verify `lake build`, update phase status.
5. **Parallel opportunity**: Phases 2 and 3 are independent and can run in parallel after Phase 1.
6. **omega_chain c2' threading is already done** (prior plan Phase 6 [COMPLETED]). No phase needed for this.
