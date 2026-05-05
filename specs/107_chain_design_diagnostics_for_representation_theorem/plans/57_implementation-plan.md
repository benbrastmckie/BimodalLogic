# Implementation Plan: Task #107 — Chronicle Construction (Burgess-Aligned D0 Fix)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 24-34 hours
- **Dependencies**: None (self-contained within Chronicle/)
- **Research Inputs**: reports/57_zorn-gap-resolution.md, reports/58_inconsistent-case-resolution.md, reports/59_team-research.md, reports/59_teammate-a-findings.md, reports/59_teammate-b-findings.md, reports/59_teammate-c-findings.md, reports/59_teammate-d-findings.md
- **Artifacts**: plans/57_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 11 remaining sorries across PointInsertion.lean (2), CounterexampleElimination.lean (2), and ChronicleToCountermodel.lean (2) by fixing the Phase 2 pos sub-case blocker through Burgess-aligned D0 seed restructuring. The current D0 seed incorrectly includes B (making it potentially inconsistent when B contains negations of untl-formulas). The correct fix removes B from D0_seed (matching Burgess 1982 exactly), proves consistency of the smaller seed WITHOUT needing BX14/neg-until (eliminating the pos sub-case entirely), then restructures downstream to propagate B-membership through the Lindenbaum extension.

### Research Integration

**Report 57** (integrated v2): Proves RRelation.lean:801 sorry is UNPROVABLE, motivating the definition revert (Phase 1, now complete).

**Report 58** (integrated v2): Identifies case-split approach for inconsistent sub-case. The neg sub-case (now complete) uses `burgess_zeta_consistent`. The pos sub-case was left open.

**Report 59 Team Research** (integrated v3): Unanimous finding that the case split is a formalization artifact from `SetDeductivelyClosed` requiring consistency. Key findings:
1. irr_until axiom is UNSOUND for discrete orders -- must NOT be used
2. Burgess's DCS does not require consistency; his D0 does NOT include B
3. The pos sub-case is blocked because BX14 cannot fire when all untl(r, gamma_hat) are in A (left_mono from bot makes ALL Until formulas with the same event positive in A)
4. The correct fix aligns D0 with Burgess's original: remove B from the seed, prove the smaller seed consistent from MCS properties of A alone

**Root Cause Analysis** (from deep code examination): The code's `burgess_D0_seed` (line 894) includes `B` as a component: `B U {beta.neg} U untl-formulas U snce-formulas`. When B contains `(untl(beta', gamma)).neg` (possible when B is close to MCS), D0 contains both `untl(beta', gamma)` AND its negation, making D0 INCONSISTENT. Burgess's original D0 is simply `{beta.neg} U untl-formulas U snce-formulas` (no B). The B-membership is recovered AFTER Lindenbaum extension using the untl/snce formulas + DCS closure.

### Prior Plan Reference

Plan 57 v2 had 7 phases. Phase 1 (definition revert) is COMPLETED. Phase 2 neg sub-case is COMPLETED but pos sub-case has a sorry. The revised Phase 2 replaces the problematic approach entirely. Phases 3-7 remain structurally valid with minor adjustments to account for the new D0 seed structure.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix the pos sub-case blocker in Phase 2 by aligning D0_seed with Burgess's original
- Close all 11 remaining sorries: 2 in PointInsertion, 2 in CounterexampleElimination, 2 in ChronicleToCountermodel (plus 5 in Phases 4-6 via c2'/limit work)
- Deliver fully sorry-free `dd_countermodel_chronicle`
- Follow Burgess 1982 EXACTLY -- no shortcuts, no unsound axioms

**Non-Goals**:
- Add irr_until axiom (proven UNSOUND for discrete orders)
- Add density axioms (would restrict completeness theorem)
- Skip Phase 2 sorries (user directive: work through them systematically)
- Introduce any axiom not in Burgess's base system J0

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing B from D0_seed breaks Lindenbaum extension properties | Blocks Phase 2 | Medium | Prove B-membership propagates through burgessR3 + DCS closure after extension (Burgess's original argument) |
| Smaller D0 seed insufficient for establishing burgessR3(A, B', D) | Blocks Phase 2 | Low | The untl/snce formulas in D0 directly establish burgessR3 after Lindenbaum extension; B-subset not needed |
| Restructured Phase 2 breaks Phase 3 (Lemma 2.7) which uses same seed structure | Cascading delay | Medium | Lemma 2.7 seed is independent (uses different seed definition). Verify Phase 3 still works. |
| g-value construction in Phase 4 depends on lemma_2_6_splitting output type | Build churn | Low | Output type (exists B' D B'' with BurgessR3Maximal) unchanged |
| Phase 2 restructuring introduces new sorry in place of old | Delays | Low | The new approach avoids BX14 entirely for inconsistent case; all steps use established BX chain tools |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | 1 (complete) |
| 2 | 3 | 1 (complete) |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases 2 and 3 are independent (both only need Phase 1, which is complete). Phases 4-7 are sequential on the critical path.

Critical path: Phase 2 (5-7h) / Phase 3 (4-5h) -> Phase 4 (7-9h) -> Phase 5 (3-4h) -> Phase 6 (5-7h) -> Phase 7 (1h) = 20-28h remaining (Phases 2/3 parallel).

---

### Phase 1: Revert Definition and Restructure [COMPLETED]

**Goal**: Revert `BurgessR3Maximal` maximality clause back to `SetDeductivelyClosed D`, eliminating the unprovable sorry at RRelation.lean:801.

**Status**: All tasks completed. Build passes. RRelation.lean sorry eliminated. `BurgessR3Maximal_neg_or_ext_fails` helper implemented. Sorry count: 12 -> 11.

**Verification**:
- RRelation.lean sorry count: 1 -> 0 (DONE)
- `lake build` passes (DONE)
- `BurgessR3Maximal_neg_or_ext_fails` implemented (DONE)

---

### Phase 2: Lemma 2.6 — Burgess-Aligned D0 Seed Restructuring [PARTIAL]

**Goal**: Fix the pos sub-case sorry at PointInsertion.lean:1891 by restructuring the inconsistent-case proof into two cases based on whether B is MCS, eliminating the need for BX14 in the problematic pos sub-case.

**Paper reference**: Burgess Section 2.6, p.370-371.

**Root Cause**: The current proof attempts a BX14 case split on `(untl(b AND beta, gamma_hat)).neg in A`. In the inconsistent case (beta.neg in B), the conjunction `b AND beta` is propositionally false (since beta.neg is in b_list), giving `untl(bot, gamma_hat) in A`. This makes ALL `untl(r, gamma_hat)` positive in A via left_mono from bot, so BX14 can never fire -- the pos sub-case is stuck.

**Strategy**: Case-split on whether B is a maximal consistent set (MCS):

- **Case A (B not MCS)**: There exists delta' not in B with {delta'} U B consistent. Use `extension_fails` on delta' to get witness (beta0, gamma0) with `(untl(beta0 AND delta', gamma0)).neg in A`. Include gamma0 in c_list so gamma_hat implies gamma0. Then the pos sub-case `untl(b AND beta, gamma_hat) in A` is VACUOUSLY CONTRADICTORY: left_mono from bot gives `untl(beta0 AND delta', gamma_hat) in A`, while right_mono contrapositive (from gamma_hat -> gamma0) gives `(untl(beta0 AND delta', gamma_hat)).neg in A` -- contradicting MCS consistency of A.

- **Case B (B is MCS)**: B itself serves as the splitting MCS D. Since beta.neg in B and B is MCS, we can bypass the D0 seed construction entirely. Set D = B. Construct B' and B'' via the existing `burgessR3Maximal_extension_exists` / Zorn machinery for burgessR3(A, B', B) and burgessR3(B, B'', C). Return the splitting triple (B', B, B'').

**Tasks**:
- [ ] **Task 2.1**: Define `burgess_D0_seed_small` as the Burgess-original seed WITHOUT B:
  ```lean
  private def burgess_D0_seed_small (A B C : Set Formula) (beta : Formula) : Set Formula :=
    {beta.neg} ∪ 
    {phi | ∃ beta' ∈ B, ∃ gamma ∈ C, phi = Formula.untl beta' gamma} ∪
    {phi | ∃ beta' ∈ B, ∃ alpha ∈ A, phi = Formula.snce beta' alpha}
  ```
  Place this adjacent to the existing `burgess_D0_seed` definition (line 894).

- [ ] **Task 2.2**: Prove `burgess_D0_seed_small_consistent`: For BurgessR3Maximal(A, B, C) with beta not in B, the small seed is consistent.

  **Proof approach**: The small seed is a SUBSET of the original D0_seed (since `{beta.neg} U untl U snce` is contained in `B U {beta.neg} U untl U snce`). The original `burgess_D0_finite_subset_consistent` already proves the full seed consistent in the neg sub-case (where BX14 fires). Since the small seed is a subset, any finite subset of the small seed is also a finite subset of the full seed -- hence consistent. This handles the neg sub-case directly.

  For the inconsistent sub-case: delegate to the two-case structure (Tasks 2.4-2.5).

- [ ] **Task 2.3**: Implement the neg sub-case consistency proof for the small seed. This reuses the existing `burgess_zeta_consistent` call (already implemented and working). The neg sub-case provides the BX14 witness `(untl(r, gamma_hat)).neg in A`, enabling the full BX5+BX14+BX13+BX10 chain. Since this path is already complete, verify it still compiles with the small seed.

- [ ] **Task 2.4**: Implement Case A (B not MCS) -- pos sub-case is vacuously contradictory.

  Steps:
  1. From `not SetMaximalConsistent B`: extract delta' not in B with {delta'} U B consistent (by classical logic on the negation of MCS)
  2. Apply `BurgessR3Maximal_extension_fails` with delta' to get witness (beta0, gamma0) with `(untl(beta0 AND delta', gamma0)).neg in A`
  3. Include gamma0 in c_list (so gamma_hat = list_conj c_list implies gamma0)
  4. In the pos sub-case, derive contradiction:
     - `untl(b AND beta, gamma_hat) in A` (pos hypothesis)
     - left_mono from `(b AND beta -> bot)`: `untl(bot, gamma_hat) in A`
     - left_mono from `(bot -> beta0 AND delta')`: `untl(beta0 AND delta', gamma_hat) in A`
     - right_mono contrapositive from `G(gamma_hat -> gamma0)` theorem and `(untl(beta0 AND delta', gamma0)).neg in A`: `(untl(beta0 AND delta', gamma_hat)).neg in A`
     - Contradiction: both formula and its negation in MCS A

- [ ] **Task 2.5**: Implement Case B (B is MCS) -- bypass D0 seed entirely.

  Steps:
  1. Verify B is SetMaximalConsistent
  2. Set D = B (beta.neg in B holds by hypothesis; B is MCS)
  3. Construct B' = Zorn-maximal DCS with burgessR3(A, B', B) using existing `zorn_burgessR3Maximal`
  4. Construct B'' = Zorn-maximal DCS with burgessR3(B, B'', C) using existing `zorn_burgessR3Maximal`
  5. Return `(B', B, B'', h_r3m_A_B'_B, h_r3m_B_B''_C, h_mcs_B, h_beta_neg_in_B)`

- [ ] **Task 2.6**: Restructure `lemma_2_6_splitting` to dispatch on the two cases:
  ```lean
  by_cases h_mcs_B : SetMaximalConsistent B
  · -- Case B is MCS: bypass D0, use D = B directly
    exact case_B_mcs_splitting h_r3m h_mcs_B h_beta_neg_in_B
  · -- Case B not MCS: find delta with {delta}UB consistent
    -- pos sub-case is vacuously contradictory
    -- neg sub-case uses existing burgess_zeta_consistent
    exact case_A_not_mcs_splitting h_r3m h_not_mcs h_beta_not_B
  ```

- [ ] **Task 2.7**: Remove the sorry at line 1891. With the restructuring, the pos sub-case either derives contradiction (Case A) or never arises (Case B, handled by fast path before reaching seed consistency).

- [ ] **Task 2.8**: Verify `lemma_2_7_seed_consistent` (line 2461) still compiles. Lemma 2.7 has its own seed definition and should be unaffected by Phase 2 changes. Confirm independence.

- [ ] **Task 2.9**: Run `lake build` and verify PointInsertion.lean sorry count drops from 2 to 1 (only lemma_2_7_seed_consistent remains).

**Timing**: 5-7 hours

**Depends on**: 1 (complete)

**Files to modify**:
- `PointInsertion.lean:1825-1891` - Restructure inconsistent case with two-case approach
- `PointInsertion.lean:2337-2366` - Restructure lemma_2_6_splitting for MCS fast path
- `PointInsertion.lean:894` - Define `burgess_D0_seed_small`

**Verification**:
- PointInsertion.lean sorry count: 2 -> 1 (only `lemma_2_7_seed_consistent` remains)
- `lake build` passes
- `lemma_2_6_splitting` compiles in both MCS and non-MCS cases
- Pos sub-case sorry at line 1891 removed
- irr_until axiom NOT used (confirmed)
- No new axioms introduced

---

### Phase 3: Lemma 2.7 — Seed Consistency (BX7 Three-Way) [NOT STARTED]

**Goal**: Implement `lemma_2_7_seed_consistent` (PointInsertion.lean:2461). This is the hardest single theorem -- the BX7 three-way disjunction with D1/D2 elimination.

**Paper reference**: Burgess Section 2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)

**Tasks**:
- [ ] **Task 3.1**: Extract witness from `eta not in B` + BurgessR3Maximal. Use `BurgessR3Maximal_neg_or_ext_fails` (Phase 1): since eta not in B, case split. If inconsistent (eta.neg in B): this contradicts h_until (untl(xi, eta) in A with eta.neg in B leads to contradiction via `neg_untl_event` or direct semantic argument). So the consistent case must hold: extract `beta0, gamma0` with `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.2**: Apply BX5 self-accumulation on both Until formulas to get enriched guards: `untl(beta0 AND untl(beta0, gamma0), gamma0) in A` and `untl(xi AND untl(xi, eta), eta) in A`.
- [ ] **Task 3.3**: Apply BX7 three-way disjunction (`linear_until_mcs`) with appropriate guards/events to produce D1 or D2 or D3 in A (by MCS disjunction property).
- [ ] **Task 3.4**: Eliminate D1 -- use left_mono on event component containing `eta AND gamma0`, reduce to show it contradicts the witness `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.5**: Eliminate D2 -- mirror argument of D1 elimination.
- [ ] **Task 3.6**: Work with surviving D3. Apply right_mono to reduce guard. Apply BX14 separation with witness, then BX13 iterated enrichment to pack snce-formulas, then BX10 for F(event) in A.
- [ ] **Task 3.7**: Assemble proof: show event implies all 5 seed components (B-elements via b conjunction, xi from event component, untl/snce formulas via mono). Close `lemma_2_7_seed_consistent` and verify `lemma_2_7` (line 2463) compiles.

**Timing**: 4-5 hours

**Depends on**: 1 (complete)

**Files to modify**:
- `PointInsertion.lean:2461` - Replace sorry with full proof

**Verification**:
- `PointInsertion.lean` sorry count: 1 -> 0
- `lemma_2_7` (line 2463) compiles
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
- [ ] **Task 5.2**: Close C4' backward hard case (line 510) -- mirror for Since using the Since analogue of the Phase 1 helper.

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
- [ ] **Task 7.4**: Generate summary artifact: `specs/107_.../summaries/57_execution-summary.md` with verification results, axiom audit, and metrics (sorry count 11 -> 0).

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
- [ ] Phase 2 pos sub-case resolved WITHOUT irr_until axiom
- [ ] All elimination functions' g-field non-empty for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`
- [ ] No density or discreteness axioms added

## Artifacts & Outputs

- `plans/57_implementation-plan.md` (this file)
- `summaries/57_execution-summary.md` (Phase 7)
- Modified source files:
  - `PointInsertion.lean` (Phases 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5)
  - `ChronicleConstruction.lean` (Phase 6)
  - `ChronicleToCountermodel.lean` (Phase 6)

## Rollback/Contingency

- **If pos sub-case contradiction argument fails in Case A (Phase 2 Task 2.4)**: Verify that right_mono contrapositive gives the neg-until for gamma_hat. If not, try: include BOTH beta0 AND gamma0 from the delta-witness in b_list and c_list, then show the formula `untl(b AND delta, gamma_hat)` is in A (left_mono from bot) AND its negation is in A (right_mono contrapositive from the witness). This should always work when {delta}UB consistent provides the witness.
- **If B-is-MCS fast path (Phase 2 Task 2.5) has unexpected complexity**: Fall back to showing B is NEVER MCS when BurgessR3Maximal(A, B, C) holds with beta not-in B. Proof sketch: B not MCS means there exists phi with phi not-in B and phi.neg not-in B; if this fails for all phi, then B is MCS; but then for the specific beta not-in B: beta.neg in B, and we can still construct D = B.
- **If Lemma 2.7 BX7 three-way is blocked (Phase 3)**: Use `lce_imp`/`rce_imp` for propositional simplifications; left/right mono existing tools. If D1/D2 elimination fails, check event formula constructors for BX7 output formatting.
- **If `finite_stage_guard_in_g` proves unprovable (Phase 6)**: Fall back to direct approach using limit_g definition + c2' invariant.
- **Build instability**: Commit after each task modification. Verify `lake build` incrementally.
