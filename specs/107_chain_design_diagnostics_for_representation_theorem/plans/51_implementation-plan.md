# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v36)

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/51_team-research.md], [reports/50_sorry-architecture-audit.md], handoffs/49_phase3-seed-analysis.md
- **Artifacts**: plans/51_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v36 supersedes plan v35, which was found misaligned with the codebase after the sorry architecture audit (report 50) and team research (report 51). The team research overturned the "dead code" diagnosis: `lemma_2_6_splitting` and `lemma_2_7` have zero callers because their call sites ARE the sorry sites (unfinished integration, not dead code). Two architectural gaps were identified: (A) the g-function phantom (never populated at finite stages, blocking c2' for C4 elimination) and (B) incomplete C5 elimination (base case only, missing guard info for FUC/FSC). The plan addresses 7 sorry sites across 3 files in Chronicle/, targeting sorry-free `dd_countermodel_chronicle`. Definition of done: `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 51** (team research, 4 teammates): Overturned dead-code diagnosis, identified g-function phantom and incomplete C5 as root causes. Produced streamlined 6-phase plan. Confirmed C4/C4' and FUC/FSC are independent workstreams. Identified non-Burgess seed helpers as true dead code (~150 lines safe to delete).
- **Report 50** (sorry architecture audit): Census of 22 sorry sites, 4 on critical path (correct for C4+FUC/FSC, but misses 3 upstream PointInsertion sorries that feed them). Dead-code diagnosis was wrong per report 51.
- **Handoff 49** (phase 3 seed analysis): Proved `g_content_sub_B` is unprovable for MCS B in BX without density. Confirmed Burgess D0 seed bypass is the correct approach.

### Prior Plan Reference

Plan v35 had phases 1-2 [COMPLETED] (ROADMAP snapshot, SoundnessLemmas build fix), phase 3 [PARTIAL] (seed restructuring started but stalled on density gap), phases 4-9 [NOT STARTED]. Key lessons: (1) The non-Burgess seed `{beta.neg} union g_content(A) union h_content(C)` has an unprovable density gap sorry -- Burgess D0 seed is the only path. (2) g-function at finite stages is empty (phantom), so c2' reconstruction from g-values is impossible -- must inline the D0 argument bypassing g entirely. (3) C4/C4' and FUC/FSC are independent and can be parallelized. (4) SoundnessLemmas fix and ROADMAP snapshot already done. (5) Effort for seed restructuring was underestimated (handoff 49 estimates 8-10h, not 5h).

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Clean non-Burgess cruft from PointInsertion.lean (user-requested first phase)
- Verify BX13/BX14 provide A3a/A4a roles for Burgess D0 seed consistency proof
- Replace non-Burgess seed in lemma_2_6_splitting with Burgess D0 seed, closing 3 sorry sites in PointInsertion.lean
- Close C4/C4' sorry sites (CounterexampleElimination.lean lines 412, 510) using lemma_2_6_splitting
- Strengthen C5 elimination to carry guard info, close FUC/FSC sorry sites (ChronicleToCountermodel.lean lines 615, 619)
- Implement lemma_2_7 body for full C5 elimination (n>0 case)
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary
- Update ROADMAP.md to reflect chronicle completion

**Non-Goals**:
- A4a removal (separate task 115, post-107 cleanup)
- BXCanonical sorry closure (task 109, secondary path)
- Removing BX7 (A7a coexists alongside BX7)
- Full Burgess Lemma 2.8 formalization (not needed for our C5 scheme)
- Density axiom addition (Burgess D0 bypasses the density gap entirely)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Burgess D0 seed consistency proof is complex with BX axioms (BX5+BX14+BX13 chain) | H | M | Handoff 49 provides detailed axiom mapping. Team research (report 51) confirms the mathematical path. Start with BX axiom sufficiency verification (Phase 1) before committing to implementation. |
| BX13 does not provide A3a's exact role in D0 consistency | H | L | Phase 1 explicitly verifies this before implementation. Fallback: if BX13 is insufficient, identify what additional axiom or lemma is needed and adjust. |
| g-function phantom blocks C4 even after D0 seed rewrite | M | M | Report 51 recommends Option 3 (inline D0 argument at sorry site, bypassing g entirely). The lemma_2_6_splitting output provides BurgessR3Maximal without needing stored g-values. |
| FUC/FSC requires full C5 with guard, which needs lemma_2_7 (n>0 case) | H | M | Two-pronged: (1) recover discarded guard at CE.lean:763 for "already witnessed" case, (2) implement lemma_2_7 for "new insertion" case. If lemma_2_7 is too complex, a direct limit argument via limit_g + C3 may suffice. |
| Lemma 2.7 seed consistency with A7a is non-trivial | M | M | A7a is already in the codebase. Burgess's proof (p. 371) translates step by step. The D0 pattern from Phase 2 serves as template. |
| Effort underestimation (handoff 49 says 8-10h for seed alone) | M | M | Total plan budget 14h with explicit phase boundaries. Each phase independently committable. Partial completion acceptable. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Clean Non-Burgess Cruft [NOT STARTED]

**Goal**: Remove dead code and stale comments that caused confusion during previous implementation attempts, establishing a clean working baseline. This was specifically requested by the user to avoid distractions.

**Tasks**:
- [ ] Delete `g_content_sub_B` private theorem (PointInsertion.lean ~line 824-857) -- unprovable density gap sorry, replaced by Burgess D0 approach
- [ ] Delete `h_content_sub_B` private theorem (PointInsertion.lean ~line 860-879) -- same density gap sorry
- [ ] Delete `splitting_seed_consistent` (PointInsertion.lean ~line 889-907) -- uses non-Burgess seed depending on deleted helpers
- [ ] Delete `G_conj_strengthen` helper (~line 772) -- only used by deleted g_content_sub_B
- [ ] Delete `H_conj_strengthen` helper (~line 803) -- only used by deleted h_content_sub_B
- [ ] Update stale docstring comments (lines 881-888) referencing the density gap
- [ ] Remove stale comment block referencing prior archival (lines 1054-1061 area)
- [ ] Ensure `lemma_2_6_splitting` and `lemma_2_7` stubs are preserved (these are rewrite targets, NOT dead code)
- [ ] Run `lake build` to confirm no breakage

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- delete ~150 lines of dead helpers, update comments

**Verification**:
- `lake build` succeeds
- `lemma_2_6_splitting` and `lemma_2_7` stubs still present (with sorry)
- No references to `g_content_sub_B`, `h_content_sub_B`, `splitting_seed_consistent`, `G_conj_strengthen`, `H_conj_strengthen` in active code
- PointInsertion.lean line count reduced by ~150

---

### Phase 1: Verify BX Axiom Sufficiency for D0 Seed [NOT STARTED]

**Goal**: Confirm that BX13 (enrichment_until) and BX14 (separation_until) provide the roles of Burgess's A3a and A4a in the D0 seed consistency proof, before committing to implementation.

**Tasks**:
- [ ] Use `lean_hover_info` on BX13 (`enrichment_until`) to check exact statement
- [ ] Use `lean_hover_info` on BX14 (`separation_until`) to check exact statement
- [ ] Map Burgess's D0 consistency proof steps to BX axioms:
  - Step 1: R(A,B,C) with delta not in B gives beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND delta) in A
  - Step 2: BX5 on U(gamma,beta): U(gamma AND U(gamma,beta), beta) in A
  - Step 3: BX14 on step 2 output: enrichment step
  - Step 4: BX13 on step 3 output: final seed consistency
- [ ] Verify `burgessR3_gamma_not_in_B` (RRelation.lean:836) provides the maximality extraction needed for step 1
- [ ] Document any gaps or adjustments needed in a brief note (inline comment or handoff)

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (read-only verification). If gaps found, create handoff file.

**Verification**:
- BX13 and BX14 confirmed sufficient (or gaps identified with mitigation)
- Axiom mapping documented for use in Phase 2

---

### Phase 2: Rewrite lemma_2_6_splitting with Burgess D0 Seed [NOT STARTED]

**Goal**: Replace the non-Burgess seed in `lemma_2_6_splitting` with Burgess's actual D0 seed, making it sorry-free. This also closes the `g_content_sub_B` and `h_content_sub_B` dependency chain (deleted in Phase 0).

**Burgess D0 seed (Lemma 2.6, pp. 370-371)**:
```
D0 = {S(alpha, beta) : alpha in A, beta in B}
     union B
     union {neg-delta}
     union {U(gamma, beta) : gamma in C, beta in B}
```

**D0 consistency proof chain**:
1. From R(A,B,C) with delta not in B: obtain beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND delta) in A (via `burgessR3_gamma_not_in_B` or maximality)
2. WLOG beta0=beta, gamma0=gamma (replace with conjunctions via right_mono)
3. From U(gamma,beta) in A and neg-U(gamma, beta AND delta) in A: BX5 gives U(gamma AND U(gamma,beta), beta) in A
4. BX14 gives separation: U(beta AND U(gamma,beta) AND neg-delta, beta) in A
5. BX13 gives enrichment: U(beta AND U(gamma,beta) AND neg-delta AND S(alpha,beta), beta) in A
6. Lemma 2.2 (MCS consistency criterion): zeta = S(alpha,beta) AND beta AND neg-delta AND U(gamma,beta) is consistent
7. Lindenbaum extension to MCS D with D0 subset D

**Tasks**:
- [ ] Define `burgess_D0_splitting` computing D0 from A, B, C, delta
- [ ] Prove seed element membership lemmas (S-formulas in A, B subset trivially, neg-delta standalone, U-formulas in A)
- [ ] Prove `burgess_D0_splitting_consistent` following the 6-step BX chain above
- [ ] Rewrite `lemma_2_6_splitting` body to use D0:
  - Lindenbaum extend D0 to MCS D
  - Extract neg-delta in D (from seed)
  - Extract B subset D (from seed includes B)
  - Derive burgessR3(A, -, D) from S-formulas in D (for all alpha in A, beta in B: S(alpha,beta) in D, hence burgessR3 via Since semantics)
  - Derive burgessR3(D, -, C) from U-formulas in D (for all gamma in C, beta in B: U(gamma,beta) in D, hence burgessR3 via Until semantics)
  - Obtain B', B'' via BurgessR3Maximal (Zorn)
- [ ] Verify `lemma_2_6_splitting` compiles sorry-free
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 1 (BX axiom sufficiency confirmed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- new D0 seed definition and consistency proof (~200 lines), rewritten lemma_2_6_splitting body (~50 lines)

**Verification**:
- `lemma_2_6_splitting` sorry-free
- `lake build` succeeds
- PointInsertion.lean sorry count: 1 (only lemma_2_7 remains)

---

### Phase 3: Close C4/C4' Sorry Sites [NOT STARTED]

**Goal**: Close the 2 sorry sites in CounterexampleElimination.lean (lines 412, 510) for the C4/C4' hard cases by wiring in `lemma_2_6_splitting`.

**Approach**: For adjacent pair (w, w_next) in the chronicle domain where gamma is in both f(w) and f(w_next):
1. The C4 counterexample gives neg(U(gamma, delta)) in f(w) for some gamma, delta
2. From chronicle invariant c2: R(f(w), g(w,w_next), f(w_next)) -- but g is phantom (empty)
3. **Bypass g**: Instead of using stored g-values, construct BurgessR3Maximal inline from f(w) and f(w_next) using the Burgess D0 argument
4. Apply `lemma_2_6_splitting` with the constructed BurgessR3Maximal to get MCS D with neg-gamma in D
5. Use D as the splitting point

**Key insight from report 51**: The g-function phantom means we cannot use c2' from stored g-values. Instead, we construct the BurgessR3Maximal relationship at the sorry site using available f-values and the axiom system, then feed it to lemma_2_6_splitting.

**Tasks**:
- [ ] Inspect C4 sorry at line 412 with `lean_goal` to understand exact proof obligation
- [ ] Determine what BurgessR3Maximal hypothesis is available or constructible from the context at line 412
- [ ] If BurgessR3Maximal(f(w), -, f(w_next)) is not directly available, construct it:
  - Use `burgessR3Maximal_from_g_content_sub` if g_content(f(w)) subset f(w_next) is provable
  - Or construct directly from chronicle invariants and axiom system
- [ ] Apply `lemma_2_6_splitting` to get D with neg-gamma in D
- [ ] Close sorry at line 412
- [ ] Inspect C4' sorry at line 510 with `lean_goal`
- [ ] Close sorry at line 510 (Since direction mirror, using dual construction)
- [ ] Run `lake build`

**Timing**: 2 hours

**Depends on**: 2 (lemma_2_6_splitting sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (~60 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 4: Strengthen C5 Witness and Implement lemma_2_7 [NOT STARTED]

**Goal**: Close the upstream dependencies for FUC/FSC by (a) recovering discarded guard info in the "already witnessed" C5 case, (b) strengthening `EliminationResult.c5_forward_witness` to carry guard info, and (c) implementing lemma_2_7 for the C5 n>0 case.

**Two sub-goals**:

**4a: Recover discarded guard info (quick win)**
- At CE.lean:763, the code destructures `⟨y, hy_dom, hy_lt, hy_eta, _⟩` -- the `_` IS the guard info being discarded
- Change `_` to a named binding and thread it through to the output
- This handles the "already witnessed" case

**4b: Implement lemma_2_7 (full C5 n>0 case)**
- Burgess Lemma 2.7 inserts a point between x and x' (successor of x in dom) when:
  - eta AND U(xi, eta) in f(x'), eta in g(x, x'), BUT xi not in f(x')
- The D0 seed for Lemma 2.7: `{S(alpha, beta AND eta) : alpha in A, beta in B} union B union {xi} union {U(gamma, beta) : gamma in C, beta in B}`
- Consistency proof uses BX5 + A7a + BX13 chain (Burgess p. 371)
- This follows the same D0 pattern established in Phase 2

**Tasks**:
- [ ] **4a**: At CE.lean:763, recover the discarded guard info (change `_` to named binding)
- [ ] **4a**: Thread guard info through to `EliminationResult.c5_forward_witness`
- [ ] **4a**: Verify the "already witnessed" case now carries guard info
- [ ] **4b**: Define `burgess_D0_until` computing D0 for Lemma 2.7
- [ ] **4b**: Prove maximality extraction: from eta not in B, obtain beta0, gamma0, neg-U(gamma0, beta0 AND eta) in A
- [ ] **4b**: Prove seed consistency using BX5 + A7a + BX13 chain
- [ ] **4b**: Implement lemma_2_7 body using the D0 pattern from Phase 2
- [ ] **4b**: Verify lemma_2_7 compiles sorry-free
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: 2 (D0 seed pattern from Phase 2 serves as template)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement lemma_2_7 body (~200 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- recover guard info at line 763 (~10 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- if EliminationResult needs guard field addition (~20 lines)

**Verification**:
- `lemma_2_7` sorry-free
- PointInsertion.lean sorry count: 0
- Guard info available at C5 elimination output
- `lake build` succeeds

---

### Phase 5: Close FUC/FSC Sorry Sites [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and forward Since coherence.

**Coherence argument**: With C5 strengthened to carry guard info (Phase 4) and all upstream lemmas sorry-free:
- For U(phi, psi) in f(t): C5 (now with guard) gives witness y > t with psi in f(y) and phi in f(r) for intermediate r
- The limit_g function provides interval values: limit_g(x,y) = {phi | forall r in dom, x < r < y -> phi in limit_f(r)}
- C3 in the limit: g(t,y) subset f(r) inter g(t,r) inter g(r,y) for intermediate r
- The Cantor isomorphism maps chronicle indices to Rat countermodel indices
- Guard transfer: phi in limit_g(x,y) implies phi in limit_f(r) for all r in (x,y), which is exactly the guard condition

**Tasks**:
- [ ] Inspect FUC sorry at line 615 with `lean_goal` to understand exact proof obligation
- [ ] Trace how strengthened C5 (with guard) is available in the limit chronicle
- [ ] Determine how `limit_satisfies_c5_full` (or equivalent with guard) provides the witness
- [ ] Establish guard transfer through Cantor isomorphism
- [ ] Close FUC sorry site (forward Until coherence)
- [ ] Inspect FSC sorry at line 619 with `lean_goal`
- [ ] Close FSC sorry site (forward Since coherence, mirror of FUC)
- [ ] Run `lake build`

**Timing**: 2 hours

**Depends on**: 3 (C4/C4' closed, ensuring limit construction is sound), 4 (C5 with guard provides the witnesses)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~80 lines each)

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Final Audit, Validation, and ROADMAP Update [NOT STARTED]

**Goal**: Comprehensive verification that the chronicle construction is sorry-free, plus ROADMAP update to reflect completion.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`
- [ ] Run `lake build` on full project -- verify no regressions
- [ ] Grep for sorry in all Chronicle/ files -- verify no active sorry sites remain
- [ ] Grep for sorry in all BXCanonical/ files -- verify no new sorry sites introduced
- [ ] Verify all previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Update module docstrings in Chronicle/ files to reflect final proof structure
- [ ] Update ROADMAP.md:
  - Mark chronicle sorry sites as closed (update from "4 sorry sites" to "0 sorry sites")
  - Update "Current state" in Chronicle Construction section
  - Update sorry census tables
  - Add completion annotation: `*(Completed: Task 107, 2026-05-01)*` to relevant items
  - Update task 107 status in cross-reference table
  - Update "Last updated" timestamp

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- Documentation updates across Chronicle/ files (docstrings only)
- `specs/ROADMAP.md` -- update chronicle status, sorry counts, completion annotations

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- Full `lake build` clean
- ROADMAP.md reflects 0 chronicle sorry sites with completion annotation

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] Phase 0: no references to deleted helpers in active code
- [ ] Phase 1: BX13/BX14 axiom roles confirmed for D0 seed
- [ ] Phase 2: `lemma_2_6_splitting` sorry-free (Burgess D0 seed)
- [ ] Phase 3: C4/C4' sorry sites (lines 412, 510) closed
- [ ] Phase 4: `lemma_2_7` sorry-free, guard info available in C5 output
- [ ] Phase 5: FUC/FSC sorry sites (lines 615, 619) closed
- [ ] Phase 6: `grep -rn "sorry" Chronicle/` returns no active sorry usages
- [ ] Phase 6: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)

## Artifacts & Outputs

- `plans/51_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (cruft cleanup + Burgess D0 seed for 2.6 and 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (C4/C4' sorry closure + guard recovery)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (EliminationResult guard field, if needed)
- Updated `specs/ROADMAP.md` (chronicle completion)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Phase 0 (cruft cleanup)**: Revert via git if any breakage. All deleted code is non-Burgess helpers with sorry bodies -- no functional loss.
- **Phase 2 (D0 seed consistency proof too complex)**: If the BX5+BX14+BX13 chain does not translate cleanly, the handoff 49 Approach 3 (weakened output without g_content conditions) is a viable interim target. This defers full BurgessR3Maximal output but may unblock C4/C4'.
- **Phase 3 (C4 cannot reconstruct BurgessR3Maximal)**: If BurgessR3Maximal for adjacent pairs is not available from the context, c2' can be re-added as a local lemma in CounterexampleElimination.lean (not as omega_chain invariant).
- **Phase 4 (lemma_2_7 A7a chain fails)**: If D1/D2 elimination via neg-U(gamma0, beta0 AND eta) does not work, the two-step BX7 derivation chain (from prior handoff) can substitute for A7a in the seed consistency proof.
- **Phase 5 (FUC/FSC blocked by C5 guard weakness)**: If strengthened C5 is insufficient, a direct limit argument via `limit_g` + C3 construction may bypass the need for finite-stage guard info entirely. This is Teammate D's alternative from report 51.
- Git history preserves all prior states; each phase is independently committable.
