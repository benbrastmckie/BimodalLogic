# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v24)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 45 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/41_team-research.md]
- **Artifacts**: plans/41_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v24 continues the Burgess chronicle construction after phases 1-3 (documentation cleanup, A3a/A3b axioms, Lemma 2.3) are already completed. This plan replaces the blocked Phase 4 from plan v23 with a targeted sorry-elimination strategy informed by report 41's breakthrough: the C4 nested case can be resolved directly via BX6 (`absorb_until`) without restructuring the elimination strategy. The remaining 11 sorry sites (9 in CounterexampleElimination.lean, 2 in ChronicleToCountermodel.lean) are decomposed into five implementation phases by difficulty tier and dependency, plus an integration phase. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 41 (team research, 4 teammates)**: Primary input. Key breakthrough: C4 nested case (lines 425, 543) resolved via BX6 `absorb_until` -- direct contradiction argument within existing burgessR3 framework, no restructuring needed. Sorry sites classified into tiers: C4 nested (2 sites, BX6 fix), Tier 1 c2' (2 sites, C5 cases with Lemma 2.4 seeds), Tier 2 c2' (4 sites, C4/g_prop/h_prop with g-value seeds), density self-pair (1 site, intermediate MCS fix), Phase 5 ChronicleToCountermodel (2 sites, C3 guard propagation). Revised estimate 40-55h (down from 100h).

### Prior Plan Reference

Plan v23 (artifact 40) had 6 phases, 40 hours. Phases 1-3 completed: documentation cleanup (half-open -> open guard), A3a/A3b axioms with soundness proofs, Lemma 2.3 closure + Xu 3.2.1 archival to Boneyard. Phase 4 was blocked because it assumed Xu 3.2.1 B-closure was needed for C4 nested case -- report 41 showed BX6 gives a direct proof instead. Effort calibration: Phase 2 (A3a/A3b) took approximately the estimated 2h; Phase 3 was faster than estimated due to archival shortcut.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 11 chronicle sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Add `burgessR3_gamma_not_in_B_nested` lemma using BX6 argument (C4 nested case fix)
- Close the 2 C4 nested sorry sites in CounterexampleElimination.lean (lines 425, 543)
- Close the 2 Tier 1 c2' sorry sites (C5 forward/backward, lines 792, 830)
- Close the 4 Tier 2 c2' sorry sites (C4/g_prop/h_prop, lines 870, 908, 944, 976)
- Fix density self-pair sorry site (line 1092) using intermediate MCS construction
- Close the 2 ChronicleToCountermodel sorry sites (lines 615, 619)
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
| BX6 argument requires infrastructure not yet in RRelation.lean (burgessRSet interaction with absorb_until) | H | M | Inspect goal state with `lean_goal` before committing to approach; BX6 is already in axiom system so derivation infrastructure should exist |
| Tier 2 c2' seed construction requires new lemmas connecting existing g-values to burgessR3Maximal_exists_from_seed | M | H | Budget 15-20h for Tier 2; if seeds are harder than expected, document gap and handoff |
| Density case restructuring (intermediate MCS D) changes EliminationResult type with cascading effects | H | M | Assess ripple effects before modifying type; if too invasive, consider alternative approach keeping f(z) but fixing the BurgessR3Maximal constraint |
| ChronicleToCountermodel C3 guard propagation through Cantor isomorphism is more complex than estimated | M | M | Phase 8 is independent of phases 4-7; can handoff partial progress if blocked |
| CounterexampleElimination sorry counts differ from research report due to code changes on branch | L | L | Verified current state: 9 sorry sites match report 41's analysis |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3 | (already completed) |
| 1 | 4 | -- |
| 2 | 5, 6 | 4 |
| 3 | 7, 8 | 5 |
| 4 | 9 | 7, 8 |

Phases 5 and 6 can execute in parallel (Tier 1 c2' vs density fix). Phases 7 and 8 can also execute in parallel once their respective dependencies are met (Tier 2 c2' depends on Tier 1 patterns; ChronicleToCountermodel is independent).

---

### Phase 1: Documentation Cleanup -- Fix Stale Half-Open Guard References [COMPLETED]

**Goal**: Fix all stale documentation claiming "half-open guard [t,s)" to correctly state "open guard (t,s)", and remove the wrong A3a counterexample from TemporalDerived.lean.

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

### Phase 4: C4 Nested Case Fix via BX6 [NOT STARTED]

**Goal**: Add a new lemma using BX6 (`absorb_until`) to close the C4 nested case sorry sites (lines 425, 543). This is the breakthrough from report 41 -- a direct contradiction argument that sidesteps the previously-assumed need for `untl_absorb_nested`.

**Tasks**:
- [ ] Inspect sorry sites at lines 425 and 543 with `lean_goal` to capture exact proof state
- [ ] Add lemma `burgessR3_gamma_not_in_B_nested` (or similar) in RRelation.lean or CounterexampleElimination.lean, proving: if gamma in g(w, w_next) and untl(gamma, delta) in f(w_next), then contradiction with neg(untl(gamma, delta)) in f(w) via:
  1. gamma in f(w_next) from no_witness condition
  2. gamma AND untl(gamma, delta) in f(w_next) by MCS conjunction
  3. burgessRSet gives untl(gamma, gamma AND untl(gamma, delta)) in f(w)
  4. BX6 absorb_until gives untl(gamma, delta) in f(w)
  5. Contradiction with neg(untl(gamma, delta)) in f(w)
- [ ] Close sorry site at line 425 using the new lemma
- [ ] Close sorry site at line 543 using the new lemma (mirror for C4' / Since direction)
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: none (phases 1-3 already completed; RRelation.lean is sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- new lemma (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites

**Verification**:
- Sorry count in CounterexampleElimination.lean drops from 9 to 7
- `lake build` succeeds
- New lemma compiles sorry-free

---

### Phase 5: Tier 1 c2' -- C5 Forward/Backward Cases [NOT STARTED]

**Goal**: Close the 2 easier c2' sorry sites (C5 forward at line 792, C5 backward at line 830). These cases append a new point beyond all existing domain, and Lemma 2.4 provides seed material via `g_content`.

**Tasks**:
- [ ] Inspect sorry sites at lines 792 and 830 with `lean_goal`
- [ ] Identify seed elements from `g_content(f(x_max))` (forward) and `g_content(f(x_min))` (backward) per Lemma 2.4
- [ ] Construct BurgessR3Maximal for new adjacent pair using `burgessR3Maximal_exists_from_seed` with identified seeds
- [ ] Close sorry site at line 792 (C5 forward)
- [ ] Close sorry site at line 830 (C5 backward)
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (~60 lines of proof each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- possibly new seed-extraction lemmas (~20 lines)

**Verification**:
- Sorry count in CounterexampleElimination.lean drops from 7 to 5
- `lake build` succeeds

---

### Phase 6: Density Self-Pair Fix [NOT STARTED]

**Goal**: Fix the density sorry site (line 1092) where `BurgessR3Maximal(f(x), g', f(x))` (same MCS both sides) is required but does not hold in general. Restructure to use an intermediate MCS D constructed via `burgessR3Maximal_exists_from_seed`.

**Tasks**:
- [ ] Inspect sorry site at line 1092 with `lean_goal` to understand exact constraint
- [ ] Assess whether EliminationResult type needs modification for the intermediate MCS approach
- [ ] If EliminationResult change is needed, implement the type change and fix all pattern matches
- [ ] Construct intermediate MCS D using `burgessR3Maximal_exists_from_seed` with seed from existing g(pc.x, pc.y)
- [ ] Close sorry site at line 1092 using intermediate MCS D instead of f(pc.x)
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure density case (~50 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- possibly modify EliminationResult type

**Verification**:
- Sorry count in CounterexampleElimination.lean drops from 5 to 4 (if phase 5 done first) or 8 to 7 (if done in parallel with phase 5)
- `lake build` succeeds

---

### Phase 7: Tier 2 c2' -- C4/g_prop/h_prop Cases [NOT STARTED]

**Goal**: Close the 4 harder c2' sorry sites (lines 870, 908, 944, 976). These insert new points BETWEEN existing adjacent points and need seeds derived from existing g-values of the pair being split.

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal` to understand the exact proof states
- [ ] Identify seed-finding strategy for each case: extract appropriate elements from existing g(x, x_next) or g(z_prev, y) values
- [ ] Add seed-extraction helper lemmas if needed (connecting existing g-values to burgessR3Maximal_exists_from_seed input)
- [ ] Close sorry site at line 870 (C4 g_prop case)
- [ ] Close sorry site at line 908 (C4' g_prop mirror)
- [ ] Close sorry site at line 944 (h_prop case)
- [ ] Close sorry site at line 976 (h_prop mirror)
- [ ] Run `lake build`

**Timing**: 15 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 4 sorry sites (~80 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- seed-extraction lemmas (~40 lines)

**Verification**:
- CounterexampleElimination.lean is sorry-free (0 remaining after density fix in phase 6)
- `lake build` succeeds

---

### Phase 8: ChronicleToCountermodel -- Forward Until/Since Coherence [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc`. These require wiring the limit chronicle's C5 + C3 properties through the Cantor isomorphism to prove Until/Since coherence in the rational countermodel.

**Tasks**:
- [ ] Inspect sorry sites at lines 615 and 619 with `lean_goal`
- [ ] Trace how C5 (Until witness existence) and C3 (three-way decomposition) are available in the limit chronicle
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to rational countermodel witnesses
- [ ] Close sorry at line 615 (forward Until coherence): For U(phi, psi) in mcs(t), use C5 for witness y with psi in f(y) and phi in g(t, y), then C3 for guard at intermediate points
- [ ] Close sorry at line 619 (forward Since coherence): Mirror using C5' and C3
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- possibly g-immutability helper

**Verification**:
- `grep -cn "sorry" ChronicleToCountermodel.lean` returns 0 (excluding comments)
- `lake build` succeeds

---

### Phase 9: Integration, Validation, and Cleanup [NOT STARTED]

**Goal**: Verify the full sorry-free chronicle path, run axiom audits, and clean up.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` to confirm zero sorry sites across all files (excluding comments)
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Update Completeness.lean documentation to reflect sorry-free chronicle path
- [ ] Clean up temporary scaffolding, commented-out code, or outdated TODOs
- [ ] Update sorry counts in file-level documentation headers

**Timing**: 2 hours

**Depends on**: 7, 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty (or only comments)
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 9
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] BX6 (`absorb_until`) lemma used correctly in C4 nested case compiles sorry-free
- [ ] `burgessR3Maximal_exists_from_seed` remains sorry-free throughout

## Artifacts & Outputs

- `plans/41_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (9 sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (new lemmas)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- All changes are additive (new lemmas, proof completions) -- no destructive modifications to existing sorry-free code
- Git history preserves all prior states; each phase is independently committable
- If BX6 argument fails in Phase 4, escalate to `/revise` with detailed handoff of the proof obstacle
- If Tier 2 c2' seeds prove harder than expected (Phase 7), partial progress on Tier 1 and density cases still reduces sorry count meaningfully
- If ChronicleToCountermodel C3 guard propagation is blocked (Phase 8), it is independent and does not affect CounterexampleElimination progress
- The BXCanonical path (task 109) remains as an independent backup completeness route
