# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v25)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 50 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md]
- **Artifacts**: plans/42_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v25 continues the Burgess chronicle construction after phases 1-4 of plan v24 are completed. The remaining 9 sorry sites (7 c2' in CounterexampleElimination.lean, 2 FUC/FSC in ChronicleToCountermodel.lean) are all caused by the same root cause: elimination functions set `g' = chi.g` (unchanged) instead of constructing g-values for new adjacent pairs. Burgess constructs f AND g jointly at every step via Lemmas 2.4/2.6. The fix is to extend `lemma_2_4` to return B (the DCS interval set, currently discarded), formalize Lemma 2.6 splitting, and wire g-values into each elimination function output. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42 (team research, 4 teammates)**: All 4 teammates converge on single diagnosis. Root cause: g-values never constructed (g starts as empty_set in singleton chronicle and is never modified). Resolution Path 1 (BX8 seed) is dead (BX8 removed). Resolution Path 4 (remove c2') is infeasible (c2' consumed at lines 409, 546 in sorry-free code). Only viable path: restructure elimination functions to produce g-values matching Burgess's Lemmas 2.4/2.6. Risk flag: open guard interaction with Lemma 2.6 splitting needs verification.

### Prior Plan Reference

Plan v24 (artifact 41) had 9 phases, 45 hours. Phases 1-3 (documentation, A3a/A3b axioms, Lemma 2.3 closure) completed efficiently. Phase 4 (C4 nested case via BX6) also completed, closing 2 sorry sites. Phases 5-8 were BLOCKED because they assumed g-values could be obtained via `burgessR3Maximal_exists_from_seed` with seeds from `g_content` -- but the elimination functions never populate g, so g = empty_set everywhere, making seed extraction impossible. Lesson: the g-value problem is upstream of individual sorry sites; infrastructure must be built before any c2' site can be closed. Effort calibration: Phase 4 took ~5h as estimated; the seed-finding approach for Phases 5-7 was fundamentally wrong.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 9 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Extend `lemma_2_4` to also return B (the DCS interval set)
- Formalize Lemma 2.6 splitting: R(A,B,C) + delta not in B produces B', D, B'' with R(A,B',D), R(D,B'',C)
- Wire g-values into all 7 c2' sorry sites in CounterexampleElimination.lean
- Close the density self-pair sorry site (line 1130)
- Close the 2 FUC/FSC sorry sites in ChronicleToCountermodel.lean (lines 615, 619)
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- BXCanonical sorry closure (task 109)
- BX2 redundant conjunct cleanup (separate task)
- BX4 redundancy investigation (separate task)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- ROADMAP.md updates

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Open guard interaction with Lemma 2.6 splitting: Burgess uses closed guard; open guard may break the Zorn extension in burgessR3Maximal_extension_exists | H | M | Verify with lean_goal before deep implementation; existing burgessR3Maximal_extension_exists is sorry-free, so open-guard compatibility is likely already handled |
| Extended lemma_2_4 return type causes cascading call-site changes | M | L | Current lemma_2_4 is called from CounterexampleElimination.lean only; changes are local |
| Density self-pair case (f(z) = f(x)) has no Burgess analog; may need novel construction | M | M | Budget dedicated phase; can use intermediate MCS D via existing lemma_2_4 infrastructure |
| ChronicleToCountermodel FUC/FSC requires threading g through Cantor isomorphism, which may be more complex than estimated | M | M | This phase is independent; partial progress still reduces sorry count |
| Lemma 2.6 splitting (three-way decomposition B = B' cap D cap B'') may require new lattice-theoretic infrastructure for DCS intersection | H | L | The existing burgessR3Maximal infrastructure handles Zorn extension; splitting is a new use pattern but relies on same primitives |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4 | (already completed from v24) |
| 1 | 5 | -- |
| 2 | 6, 7 | 5 |
| 3 | 8, 9 | 6 |
| 4 | 10 | 7, 8, 9 |

Phases 6 and 7 can execute in parallel (C5 g-values vs density fix). Phases 8 and 9 can execute in parallel once Phase 6 is done (C4 g-values vs FUC/FSC wiring).

---

### Phase 1: Documentation Cleanup -- Fix Stale Half-Open Guard References [COMPLETED]

**Goal**: Fix all stale documentation claiming "half-open guard [t,s)" to correctly state "open guard (t,s)".

**Tasks**:
- [x] Fix Truth.lean docstring and implementation notes
- [x] Fix Axioms.lean stale comments (5 locations)
- [x] Fix Soundness.lean stale comments (3 locations)
- [x] Remove wrong A3a counterexample from TemporalDerived.lean
- [x] `lake build` succeeds

**Timing**: 1.5 hours

**Depends on**: none

**Completed**: Phase 1 of plan v23

---

### Phase 2: Add A3a/A3b Axioms with Soundness Proofs [COMPLETED]

**Goal**: Add enrichment_until (A3a/BX13) and enrichment_since (A3b/BX13') as new BX axiom constructors with soundness proofs.

**Tasks**:
- [x] Add `enrichment_until` and `enrichment_since` constructors to Axioms.lean
- [x] Prove soundness of both in Soundness.lean
- [x] `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 1

**Completed**: Phase 2 of plan v23

---

### Phase 3: Close Lemma 2.3 Sorry Sites in RRelation.lean [COMPLETED]

**Goal**: Close Lemma 2.3 (burgessR <=> burgessRSince) using A3a/A3b. Archive Xu 3.2.1 to Boneyard.

**Tasks**:
- [x] Close `burgessR_implies_burgessRSince` and `burgessRSince_implies_burgessR`
- [x] Archive Xu 3.2.1 to Boneyard/XuLemma321.lean
- [x] RRelation.lean is sorry-free
- [x] `lake build` succeeds

**Timing**: 3 hours

**Depends on**: 2

**Completed**: Phase 3 of plan v23

---

### Phase 4: C4 Nested Case Fix via BX6 [COMPLETED]

**Goal**: Close the 2 C4 nested case sorry sites using BX6 (`absorb_until`).

**Tasks**:
- [x] Add `burgessR3_gamma_not_in_B_nested` lemma using BX6 contradiction argument
- [x] Close sorry sites at former lines 425, 543
- [x] `lake build` succeeds

**Timing**: 5 hours

**Depends on**: none (phases 1-3 already completed)

**Completed**: Phase 4 of plan v24

---

### Phase 5: g-Value Infrastructure -- Extend lemma_2_4 and Formalize Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Build the mathematical infrastructure needed by all downstream c2' closures. Extend `lemma_2_4` to also return B (the BurgessR3Maximal DCS interval set), and formalize Lemma 2.6 splitting as a new theorem.

**Tasks**:
- [ ] Extend `lemma_2_4` return type to include B: `exists B C, BurgessR3Maximal A B C /\ SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\ P(U(gamma,beta)) in C`
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean to destructure the new return type
- [ ] Verify `lake build` succeeds with the extended return type (no sorry regressions)
- [ ] Formalize Lemma 2.6 splitting in PointInsertion.lean or RRelation.lean: given `BurgessR3Maximal A B C` and `delta not in B`, produce `B', D, B''` with `BurgessR3Maximal A B' D`, `BurgessR3Maximal D B'' C`, and `B = B' cap D cap B''` (or weaker: B subset B' cap D cap B'')
- [ ] Verify open-guard compatibility: confirm `burgessR3Maximal_extension_exists` works correctly with the splitting seed by inspecting goal states with `lean_goal`
- [ ] Run `lake build`

**Timing**: 12 hours

**Depends on**: none (phases 1-4 already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- extend lemma_2_4 (~30 lines), add Lemma 2.6 splitting (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- possibly new splitting infrastructure (~40 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update call sites (~20 lines)

**Verification**:
- `lemma_2_4` extended return type compiles sorry-free
- Lemma 2.6 splitting theorem compiles sorry-free
- `lake build` succeeds with no sorry regressions

---

### Phase 6: C5 c2' Closure -- Forward/Backward g-Values via Extended lemma_2_4 [NOT STARTED]

**Goal**: Close the 2 C5 c2' sorry sites (lines 830, 868) using the extended `lemma_2_4` that now returns B. C5 elimination appends a new point beyond all existing domain; `lemma_2_4` gives both the MCS endpoint C and the BurgessR3Maximal DCS interval B for the new adjacent pair.

**Tasks**:
- [ ] Inspect sorry site at line 830 (C5 forward) with `lean_goal` to capture exact proof state
- [ ] Use extended `lemma_2_4` to obtain B for the new adjacent pair (x_max, y): `BurgessR3Maximal(f(x_max), B, C)` where C = new endpoint
- [ ] Wire B into the c2' field: construct the proof that `BurgessR3Maximal(chi.f a, chi'.g a b, chi.f b)` for the new pair
- [ ] Close sorry site at line 830
- [ ] Inspect sorry site at line 868 (C5 backward / Since direction) with `lean_goal`
- [ ] Mirror: use extended `lemma_2_4` (Since variant) for (y, x_min) pair
- [ ] Close sorry site at line 868
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (~60 lines of proof each)

**Verification**:
- Sorry count in CounterexampleElimination.lean drops from 7 to 5
- `lake build` succeeds

---

### Phase 7: Density Self-Pair Fix [NOT STARTED]

**Goal**: Fix the density sorry site (line 1130) where `BurgessR3Maximal(f(x), g', f(x))` (same MCS on both sides) is required but the existing g-value was constructed for `BurgessR3Maximal(f(x), g(x,y), f(y))` with different endpoints. Restructure to use an intermediate MCS D.

**Tasks**:
- [ ] Inspect sorry site at line 1130 with `lean_goal` to understand the exact constraint
- [ ] Assess whether the density case needs to insert a genuine new intermediate point D between x and y (via `lemma_2_4` on a self-Until/F formula), rather than reusing f(x) as the new point
- [ ] If type changes needed in EliminationResult for density case, implement and fix all pattern matches
- [ ] Construct intermediate MCS D and its BurgessR3Maximal relationships using extended `lemma_2_4` or `burgessR3Maximal_exists_from_seed`
- [ ] Close sorry site at line 1130
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure density case (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- possibly modify EliminationResult type

**Verification**:
- Sorry count in CounterexampleElimination.lean drops by 1 (density site closed)
- `lake build` succeeds

---

### Phase 8: C4/g_prop/h_prop c2' Closure via Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Close the 4 harder c2' sorry sites (lines 908, 946, 982, 1014). These insert new points BETWEEN existing adjacent points and need g-values derived by splitting the existing g(x, x_next) via Lemma 2.6.

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal` to understand the exact proof states
- [ ] For C4 forward (line 908): apply Lemma 2.6 splitting to `BurgessR3Maximal(f(x), g(x, x_next), f(x_next))` with the new point z, producing `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(x_next))`
- [ ] Close sorry site at line 908 (C4 g_prop forward)
- [ ] Close sorry site at line 946 (C4 g_prop backward / mirror)
- [ ] For h_prop (line 982): apply same Lemma 2.6 splitting pattern with the modal variant
- [ ] Close sorry site at line 982 (h_prop forward)
- [ ] Close sorry site at line 1014 (h_prop backward / mirror)
- [ ] Run `lake build`

**Timing**: 14 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 4 sorry sites (~80 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count drops from 5 to 0 (assuming phases 6, 7 done)
- `lake build` succeeds

---

### Phase 9: ChronicleToCountermodel -- Forward Until/Since Coherence [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc`. These require wiring the limit chronicle's C5 + C3 properties through the Cantor isomorphism to prove Until/Since coherence in the rational countermodel.

**Tasks**:
- [ ] Inspect sorry sites at lines 615 and 619 with `lean_goal`
- [ ] Trace how C5 (Until witness existence) and C3 (three-way decomposition) are available in the limit chronicle, now that g-values are properly constructed
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to rational countermodel witnesses
- [ ] Close sorry at line 615 (forward Until coherence): For U(phi, psi) in mcs(t), use C5 for witness y with psi in f(y), then g(t, y) provides the guard via BurgessR3Maximal
- [ ] Close sorry at line 619 (forward Since coherence): Mirror using C5' and corresponding g-values
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- possibly limit g immutability helper

**Verification**:
- `grep -cn "sorry" ChronicleToCountermodel.lean` returns 0 (excluding comments)
- `lake build` succeeds

---

### Phase 10: Integration, Validation, and Cleanup [NOT STARTED]

**Goal**: Verify the full sorry-free chronicle path, run axiom audits, and clean up.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` to confirm zero sorry sites across all files (excluding comments)
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Update Completeness.lean documentation to reflect sorry-free chronicle path
- [ ] Clean up temporary scaffolding, commented-out code, or outdated TODOs in Chronicle/ files
- [ ] Update sorry counts in file-level documentation headers

**Timing**: 2 hours

**Depends on**: 8, 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty (or only comments/docstrings)
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 10
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type
- [ ] Lemma 2.6 splitting theorem compiles sorry-free
- [ ] `burgessR3Maximal_exists_from_seed` remains sorry-free throughout
- [ ] Open-guard compatibility verified for all new infrastructure

## Artifacts & Outputs

- `plans/42_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (extended lemma_2_4, Lemma 2.6 splitting)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (possible new splitting infrastructure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- All changes are additive (new lemmas, proof completions, return type extensions) -- no destructive modifications to existing sorry-free code
- Git history preserves all prior states; each phase is independently committable
- If Lemma 2.6 splitting proves harder than expected (Phase 5), partial progress on extended lemma_2_4 still enables C5 phases
- If density case requires type changes (Phase 7), it is independent and does not block C4/g_prop/h_prop phases
- If ChronicleToCountermodel FUC/FSC is blocked (Phase 9), it is independent and does not affect CounterexampleElimination progress
- The BXCanonical path (task 109) remains as an independent backup completeness route
- If open-guard incompatibility is discovered in Phase 5, escalate to `/revise` with detailed handoff
