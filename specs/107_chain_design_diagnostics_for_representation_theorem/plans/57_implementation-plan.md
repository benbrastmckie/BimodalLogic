# Implementation Plan: Task #107 — Chronicle Construction (Revert and Complete)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 21-30 hours
- **Dependencies**: None (self-contained within Chronicle/)
- **Research Inputs**: reports/57_zorn-gap-resolution.md (proves RRelation.lean:801 sorry is unprovable, identifies correct fix), reports/58_inconsistent-case-resolution.md (case-split approach for Phase 2 inconsistent sub-case)
- **Artifacts**: plans/57_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 13 remaining sorries across RRelation.lean (1), PointInsertion.lean (3), CounterexampleElimination.lean (7), and ChronicleToCountermodel.lean (2) by REVERTING the `BurgessR3Maximal` maximality clause back to `SetDeductivelyClosed D` (matching Burgess 1982 Section 2.3), which eliminates the unprovable sorry at RRelation.lean:801 immediately. The revert requires restructuring `BurgessR3Maximal_extension_fails` to re-add a consistency hypothesis and handling the inconsistent case separately via `neg_mem_of_inconsistent_union`. Remaining phases close Lemma 2.6/2.7 seed consistency, C4/C5 elimination with c2' invariant, limit C5 full, and FUC/FSC.

### Research Integration

**Report 57** proves definitively that the sorry at RRelation.lean:801 is UNPROVABLE: `burgessR3(A, Set.univ, C)` is satisfiable on discrete linear orders (where `untl(bot, gamma)` holds vacuously). The BX axiom system has no density axiom and cannot derive a contradiction from this configuration. The root cause is that plan 56 Phase 1 changed the maximality clause from `SetDeductivelyClosed D` (Burgess's original, which requires consistency) to `ClosedUnderDerivation D` (which includes `Set.univ`). The correct fix is to revert this change. Burgess's proofs only ever construct consistent extensions, so maximality over consistent DCSs is sufficient.

**Report 58** identifies the root cause of the two Phase 2 sorries (h_ev_b, h_ev_untl at PointInsertion.lean:1886-1887): the formalization's `SetDeductivelyClosed` includes a consistency requirement that Burgess's original "deductively closed" does not. This forces a case split on `SetConsistent ({beta} union B)` that doesn't exist in Burgess's proof. The inconsistent case lacks the BX14 step because the maximality witness is not obtainable. The fix: case-split on `(untl(b AND beta, gamma_hat)).neg in A`. Key discovery: `burgess_zeta_consistent` has an UNUSED parameter `h_F_beta_neg`, enabling direct call from the neg sub-case.

### Prior Plan Reference

Plan 56 had 7 phases. Phase 1 (definition change to `ClosedUnderDerivation`) is being REVERTED by this plan. Phases 2-7 (Lemma 2.6/2.7, C4/C5 elimination, C4 hard cases, limit C5 full + FUC/FSC, final audit) remain structurally valid. Key lessons: Lemma 2.7 (BX7 three-way) is the hardest single theorem at 4-5 hours; C4/C5 co-construction takes 7-9 hours; the omega_chain c2' threading is already done. Plan 56 assumed no consistency hypothesis would be needed for `extension_fails`, but the research proves that assumption wrong -- the consistent/inconsistent cases must be handled separately.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Revert `BurgessR3Maximal` maximality clause back to `SetDeductivelyClosed D` (Burgess's original)
- Eliminate the unprovable sorry at RRelation.lean:801 (falls outside the quantifier with `SetDeductivelyClosed`)
- Close all 13 remaining sorries: 1 in RRelation, 3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel
- Deliver fully sorry-free `dd_countermodel_chronicle`

**Non-Goals**:
- Prove `burgessR3(A, Set.univ, C)` is inconsistent (proven impossible by research)
- Rewrite the elimination algorithm structure
- Introduce new axioms or change semantics
- Modify limit_dom, limit_f, limit_g, limit_c3 (all already sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Reverting definition breaks `g_content_sub_B` proof strategy | Blocks Phase 1 | Medium | Research identifies direct approach: inconsistent case uses `neg_mem_of_inconsistent_union` (φ.neg in B directly), no need for Set.univ maximality |
| Lemma 2.6 pos sub-case (untl(b AND beta, gamma_hat) in A) requires novel proof | Delays Phase 2 | Medium | Three fallback strategies: (A) derive contradiction from inconsistency, (B) BX7 enrichment restart from q AND gamma_hat, (C) use irr_until axiom if available on branch. Neg sub-case is straightforward (direct burgess_zeta_consistent call). |
| Lemma 2.7 BX7 three-way combinatorially blocked | Delays Phase 3 | Medium | Use `lce_imp`/`rce_imp` for propositional simplifications; left/right mono existing tools |
| g-value construction breaks all call sites (Phase 4) | Build churn | High | Commit after each elimination function change; fix call sites incrementally |
| `finite_stage_guard_in_g` lemma unprovable (Phase 6) | Blocks limit C5 | Low | Direct approach: use limit_g definition + c2' invariant to show guard universally present |

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

Critical path: Phase 1 (2-3h) -> Phase 2 (3-4h) / Phase 3 (4-5h) -> Phase 4 (7-9h) -> Phase 5 (3-4h) -> Phase 6 (5-7h) -> Phase 7 (1h) = 21-30h (Phases 2/3 parallel).

---

### Phase 1: Revert Definition and Restructure [COMPLETED]

**Goal**: Revert `BurgessR3Maximal` maximality clause back to `SetDeductivelyClosed D`, eliminating the unprovable sorry at RRelation.lean:801. Restructure `BurgessR3Maximal_extension_fails` to require a consistency hypothesis. Update call sites.

**Tasks**:
- [ ] **Task 1.1**: Revert `BurgessR3Maximal` maximality clause (ChronicleTypes.lean:323) from `ClosedUnderDerivation D` back to `SetDeductivelyClosed D`. The first two conjuncts remain unchanged.
- [ ] **Task 1.2**: Verify the sorry at RRelation.lean:801 is now UNREACHABLE. The Zorn construction produces a `SetDeductivelyClosed` B that is maximal among all `SetDeductivelyClosed` extensions satisfying `burgessR3`. The "inconsistent D" case cannot arise because `SetDeductivelyClosed` requires consistency. Remove the sorry and close the proof with the standard Zorn contradiction argument.
- [ ] **Task 1.3**: Re-add `h_cons : SetConsistent ({delta} union B)` hypothesis to `BurgessR3Maximal_extension_fails` (PointInsertion.lean:568). The proof needs `deductiveClosure ({delta} union B)` to be `SetDeductivelyClosed` (not just `ClosedUnderDerivation`), which requires consistency of the input. Alternatively, restructure the theorem to conclude `delta.neg in B` when the union is inconsistent.
- [ ] **Task 1.4**: Create helper `BurgessR3Maximal_neg_or_ext_fails`: Given `BurgessR3Maximal(A, B, C)` and `delta not in B`, EITHER `delta.neg in B` (inconsistent case, via `neg_mem_of_inconsistent_union`) OR `not burgessR3(A, DC({delta} union B), C)` (consistent case, via maximality). This unified interface handles both branches.
- [ ] **Task 1.5**: Update all call sites of `BurgessR3Maximal_extension_fails` to use the new interface. Call sites already branch on consistency (the code at Lemma 2.6/2.7 already has `by_cases h_cons`), so most only need the consistent branch which passes `h_cons` directly.
- [ ] **Task 1.6**: Fix `g_content_sub_B` (PointInsertion.lean:746-758 comment block). The inconsistent case now uses `neg_mem_of_inconsistent_union` directly: when `{phi} union B` is inconsistent, `phi.neg in B`. Since G(phi) in A and B is DCS, we show phi in B by contradiction (phi.neg in B + G(phi) in A gives G(phi.neg.neg) in A via MCS double negation, but we actually need phi in B, not phi.neg.neg in B -- handle via: if phi.neg in B, derive ⊥ from G(phi) + phi.neg in B using BX2G, contradicting B's consistency). Actually simpler: the consistent case gives the contradiction directly via `BurgessR3Maximal_extension_fails` + `dc_delta_B_burgessR3`; the inconsistent case gives phi.neg in B but G(phi) in A means phi is in every DCS satisfying the R3-maximal (via the G-content lemma `g_formula_in_dcs`), so phi in B directly.
- [ ] **Task 1.7**: Keep `deductiveClosure_closed_under_derivation` lemma (still useful for other contexts). Verify `lake build` passes with no new errors.

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `ChronicleTypes.lean:323` - Revert maximality clause to `SetDeductivelyClosed D`
- `RRelation.lean:801` - Remove sorry (now unreachable or provable by Zorn maximality over DCSs)
- `PointInsertion.lean:568-581` - Restructure `BurgessR3Maximal_extension_fails` with `h_cons` or create `BurgessR3Maximal_neg_or_ext_fails`
- `PointInsertion.lean` - Update call sites, fix `g_content_sub_B`

**Verification**:
- `lake build` passes with no new errors
- RRelation.lean sorry count: 1 -> 0
- `BurgessR3Maximal_extension_fails` proof strategy documented

---

### Phase 2: Lemma 2.6 — Inconsistent Case Resolution [NOT STARTED]

**Goal**: Close the 2 sorries at PointInsertion.lean:1886-1887 (`h_ev_b` and `h_ev_untl`) in `burgess_D0_finite_subset_consistent_incons` by restructuring the inconsistent sub-case with a case-split on `(untl(b AND beta, gamma_hat)).neg in A`.

**Paper reference**: Burgess Section 2.6, p.370-371 (D0 seed consistency). Report 58 analysis of why the inconsistent case fails and the fix via negation-complete case-split.

**Root Cause** (from report 58): The formalization's `SetDeductivelyClosed` includes consistency (unlike Burgess's "deductively closed"). When `{beta} union B` is inconsistent, `deductiveClosure({beta} union B)` is NOT `SetDeductivelyClosed`, so `BurgessR3Maximal_extension_fails` cannot be called. The current enrichment starts from `gamma_hat` with guard `q = b AND untl(b, gamma_hat)`, producing an event that implies gamma_hat but NOT b or untl(b, gamma_hat).

**Strategy**: Case-split on `(untl(b AND beta, gamma_hat)).neg in A` using MCS negation-completeness. The neg sub-case calls `burgess_zeta_consistent` directly (which has an unused `h_F_beta_neg` parameter). The pos sub-case uses BX7-based argument or derives contradiction from the inconsistency guard.

**Tasks**:
- [ ] **Task 2.1**: Add case-split inside `burgess_D0_finite_subset_consistent_incons` after constructing `b` and `gamma_hat`:
  ```lean
  rcases SetMaximalConsistent.negation_complete h_mcs_A
    (Formula.untl (Formula.and b β) γ_hat) with h_pos | h_neg
  ```
  This splits on whether `untl(b AND beta, gamma_hat)` or its negation is in A.

- [ ] **Task 2.2**: Implement the **neg sub-case** (`h_neg : (untl(b AND beta, gamma_hat)).neg in A`). Call `burgess_zeta_consistent` directly:
  - Derive `h_beta_not_B : beta not in B` from `beta.neg in B` + B consistent (since we are in the inconsistent case where `beta.neg in B`)
  - Pass `h_neg` as the `h_neg_until` argument to `burgess_zeta_consistent`
  - The `h_F_beta_neg` parameter is unused (report 58 Section 4), so pass any dummy or `sorry`-free witness
  - Extract `event`, `h_F_event`, `h_ev_b`, `h_ev_untl`, `h_ev_snce` from the result
  - This sub-case then proceeds exactly like the consistent case proof

- [ ] **Task 2.3**: Implement the **pos sub-case** (`h_pos : untl(b AND beta, gamma_hat) in A`). Two strategies ordered by preference:
  - **Strategy A (ex falso)**: Since `{beta} union B` is inconsistent AND `b in B`, we have `beta.neg in B`. Combined with `b AND beta` being derivably inconsistent (from b containing beta.neg components), show `untl(b AND beta, gamma_hat)` contradicts some element of A using BX axioms (e.g., if `G((b AND beta).neg)` is derivable, then `irr_until` or BX2G gives `(untl(b AND beta, gamma_hat)).neg in A`, contradicting h_pos).
  - **Strategy B (BX7 enrichment restart)**: Apply BX7 to `untl(q, gamma_hat)` and `untl(gamma_hat.neg, gamma_hat)` to get D1/D2/D3. Eliminate D2 (target inconsistent). For D3 = `untl(q AND gamma_hat.neg, q AND gamma_hat)`: restart enrichment from `q AND gamma_hat` as initial event (which DOES imply q, hence b and untl(b, gamma_hat)). For D1: apply BX14 separation with different witnesses.
  - **Strategy C (fallback)**: If `irr_until` axiom is available on this branch, it directly makes the pos sub-case unreachable since `G((b AND beta).neg) -> (untl(b AND beta, gamma_hat)).neg` forces h_neg always.

- [ ] **Task 2.4**: Verify `h_F_beta_neg` unused status in `burgess_zeta_consistent` (lines 1265-1359). If confirmed unused, optionally mark with comment or remove parameter entirely. If removing breaks callers, keep parameter but document it as vestigial.

- [ ] **Task 2.5**: Verify `lemma_2_6_splitting` (line 2328) still compiles and PointInsertion.lean sorry count drops from 3 to 1.

**Timing**: 3-4 hours (increased from 2-3h due to pos sub-case complexity)

**Depends on**: 1

**Files to modify**:
- `PointInsertion.lean:1886-1887` - Replace sorries with case-split proof
- `PointInsertion.lean:1265-1359` - Optionally remove/document unused `h_F_beta_neg` parameter in `burgess_zeta_consistent`

**Verification**:
- `PointInsertion.lean` sorry count: 3 -> 1 (only `lemma_2_7_seed_consistent` remains)
- `lake build` passes
- `lemma_2_6_splitting` compiles
- Neg sub-case calls `burgess_zeta_consistent` successfully
- Pos sub-case resolved (either contradiction, BX7 restart, or irr_until)

---

### Phase 3: Lemma 2.7 — Seed Consistency (BX7 Three-Way) [NOT STARTED]

**Goal**: Implement `lemma_2_7_seed_consistent` (PointInsertion.lean:2416). This is the hardest single theorem -- the BX7 three-way disjunction with D1/D2 elimination.

**Paper reference**: Burgess Section 2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)

**Tasks**:
- [ ] **Task 3.1**: Extract witness from `eta not in B` + BurgessR3Maximal. Use `BurgessR3Maximal_neg_or_ext_fails` (Phase 1): since eta not in B, case split. If inconsistent (eta.neg in B): this contradicts h_until (untl(xi, eta) in A with eta.neg in B leads to contradiction via `neg_untl_event` or direct semantic argument). So the consistent case must hold: extract `beta0, gamma0` with `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.2**: Apply BX5 self-accumulation on both Until formulas to get enriched guards: `untl(beta0 AND untl(beta0, gamma0), gamma0) in A` and `untl(xi AND untl(xi, eta), eta) in A`.
- [ ] **Task 3.3**: Apply BX7 three-way disjunction (`linear_until_mcs`) with appropriate guards/events to produce D1 or D2 or D3 in A (by MCS disjunction property).
- [ ] **Task 3.4**: Eliminate D1 -- use left_mono on event component containing `eta AND gamma0`, reduce to show it contradicts the witness `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.5**: Eliminate D2 -- mirror argument of D1 elimination.
- [ ] **Task 3.6**: Work with surviving D3. Apply right_mono to reduce guard. Apply BX14 separation with witness, then BX13 iterated enrichment to pack snce-formulas, then BX10 for F(event) in A.
- [ ] **Task 3.7**: Assemble proof: show event implies all 5 seed components (B-elements via b conjunction, xi from event component, untl/snce formulas via mono). Close `lemma_2_7_seed_consistent` and verify `lemma_2_7` (line 2418) compiles.

**Timing**: 4-5 hours

**Depends on**: 1

**Files to modify**:
- `PointInsertion.lean:2416` - Replace sorry with full proof

**Verification**:
- `PointInsertion.lean` sorry count: 1 -> 0
- `lemma_2_7` (line 2418) compiles
- `lake build` passes

---

### Phase 4: C4/C5 Elimination — Co-Constructed g-Values and c2' [NOT STARTED]

**Goal**: Rewrite C4, C4', C5, C5' elimination functions in CounterexampleElimination.lean to populate g-values at new adjacent pairs, then close all 5 c2' sorries (lines 756, 794, 834, 872, 918). After this phase, g-values at new adjacent pairs satisfy `BurgessR3Maximal` and the c2' invariant is maintained.

**Paper reference**: Burgess Sections 2.9 (p.373) and 2.10 (p.374)

**Tasks**:
- [ ] **Task 4.1**: Rewrite `eliminate_C5_counterexample` (line 167) -- extract B from `lemma_2_4`, set `g'(x, y) = B`. Update return type to populate g-field for new pair.
- [ ] **Task 4.2**: Rewrite `eliminate_C5'_counterexample` -- mirror for Since direction.
- [ ] **Task 4.3**: Rewrite `eliminate_C4_counterexample` (line 304) -- call `lemma_2_6_splitting`, set `g'(x,z)=B'`, `g'(z,y)=B''`. Handle easy cases with `burgessR3Maximal_singleton`.
- [ ] **Task 4.4**: Rewrite `eliminate_C4'_counterexample` -- mirror for Since.
- [ ] **Task 4.5**: Fix call sites in `eliminate_potential_counterexample` and `omega_chain`. Verify compilation.
- [ ] **Task 4.6**: Close C5 forward c2' (line 756) -- BurgessR3Maximal from lemma_2_4 output.
- [ ] **Task 4.7**: Close C5' backward c2' (line 794) -- mirror.
- [ ] **Task 4.8**: Close C4 forward c2' (line 834) -- from lemma_2_6_splitting output, old pairs inherit, new pairs from splitting result.
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
- [ ] **Task 5.1**: Close C4 forward hard case (line 412). Apply `BurgessR3Maximal_neg_or_ext_fails` at `(f(w), g(w,w_next))` with extension candidate `gamma`. Extract witness, derive contradiction with counterexample condition. Assemble output with new midpoint MCS D where `gamma.neg in D`.
- [ ] **Task 5.2**: Close C4' backward hard case (line 510) -- mirror for Since using `BurgessR3MaximalSince_extension_fails` (or the Since analogue of the Phase 1 helper).

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
- [ ] **Task 6.1**: Prove `finite_stage_guard_in_g` -- by induction on finite stage n, show that when witness y is added, guard xi is in every g-value for adjacent pairs between x and y. Uses c2' invariant (Phases 4/5) and the fact that Lemma 2.4's BurgessR3Maximal includes the guard in the interval DCS.
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
- [ ] **Task 7.4**: Generate summary artifact: `specs/107_.../summaries/57_execution-summary.md` with verification results, axiom audit, and metrics (sorry count 13 -> 0).

**Timing**: 1 hour

**Depends on**: 6

**Files to modify**:
- None (verification only)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/57_execution-summary.md` - Create summary artifact

**Verification**:
- Chronicle/ sorry count: 0
- `dd_countermodel_chronicle` has no `sorryAx` in its axioms
- Full `lake build` clean

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary
- [ ] `#print axioms dd_countermodel_chronicle` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `BurgessR3Maximal` maximality clause uses `SetDeductivelyClosed D` (matching Burgess 1982)
- [ ] RRelation.lean:801 sorry removed (inconsistent D case no longer applies)
- [ ] All elimination functions' g-field non-empty for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`

## Artifacts & Outputs

- `plans/57_implementation-plan.md` (this file)
- `summaries/57_execution-summary.md` (Phase 7)
- Modified source files:
  - `ChronicleTypes.lean` (Phase 1 -- revert definition)
  - `RRelation.lean` (Phase 1 -- remove sorry)
  - `PointInsertion.lean` (Phases 1, 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5)
  - `ChronicleConstruction.lean` (Phase 6)
  - `ChronicleToCountermodel.lean` (Phase 6)

## Rollback/Contingency

- **If g_content_sub_B restructuring difficult (Phase 1 Task 1.6)**: Use `g_formula_in_dcs` lemma (if it exists) or prove G(phi) in A -> phi in B for any DCS B satisfying burgessR3(A,B,C). Alternatively, bypass g_content_sub entirely if Lemma 2.6/2.7 seed consistency can be proved without it (Burgess's original proof uses BX5 + BX4a + BX3a + Lemma 2.2 directly).
- **If pos sub-case Strategy A fails (Phase 2)**: Fall back to Strategy B (BX7 enrichment restart from q AND gamma_hat as initial event). If D3 analysis is blocked, try Strategy C (irr_until axiom on this branch). If all three strategies fail, the pos sub-case may need a new axiom or restructuring of the formalization's SetDeductivelyClosed to remove the consistency requirement (matching Burgess exactly).
- **If `finite_stage_guard_in_g` proves unprovable (Phase 6)**: Fall back to direct approach using limit_g definition + c2' invariant -- since limit_g is defined as formulas true at ALL intermediate points, guard propagation follows directly from the finite-stage c2' property.
- **Build instability**: Commit after each task modification. Verify `lake build` incrementally.
