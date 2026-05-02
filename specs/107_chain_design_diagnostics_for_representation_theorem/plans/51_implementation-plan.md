# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v37)

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 20 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/51_team-research.md], [reports/50_sorry-architecture-audit.md], handoffs/49_phase3-seed-analysis.md
- **Artifacts**: plans/51_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Plan Version**: 37

## Overview

Plan v37 supersedes plan v36, which chose pragmatic shortcuts (bypassing g, recovering discarded guards) over mathematical fidelity to Burgess 1982. The user requires mathematical excellence: (1) extend g during point insertion so that g is a first-class mathematical object at every finite stage, and (2) close FUC/FSC via Burgess Claim 2.11 with proper g-values instead of workaround hacks. The key architectural change is threading c2' through the omega_chain by making each elimination function assign proper g-values (B, B', B'' from Lemmas 2.4, 2.6, 2.7) to the EliminationResult. With c2' available at finite stages, C4 elimination can call lemma_2_6_splitting directly per Burgess Lemma 2.9 n=0, and C5 elimination produces guard information via g-membership, enabling FUC/FSC closure through Claim 2.11. Definition of done: `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 51** (team research, 4 teammates): Overturned dead-code diagnosis, identified g-function phantom and incomplete C5 as root causes. Produced streamlined 6-phase plan. Confirmed C4/C4' and FUC/FSC are independent workstreams. Identified non-Burgess seed helpers as true dead code (~150 lines safe to delete).
- **Report 50** (sorry architecture audit): Census of 22 sorry sites, 4 on critical path (correct for C4+FUC/FSC, but misses 3 upstream PointInsertion sorries that feed them). Dead-code diagnosis was wrong per report 51.
- **Handoff 49** (phase 3 seed analysis): Proved `g_content_sub_B` is unprovable for MCS B in BX without density. Confirmed Burgess D0 seed bypass is the correct approach.
- **Revision reason (v36->v37)**: User requires mathematical fidelity over implementation ease. Two specific changes: (1) extend g during point insertion instead of bypassing g, (2) FUC/FSC via Burgess Claim 2.11 with proper g-values instead of workaround.

### Prior Plan Reference

Plan v36 had 7 phases (0-6), all [NOT STARTED]. Key lessons carried forward: (1) Non-Burgess seed has unprovable density gap -- Burgess D0 seed is the only path. (2) Previously, v36 proposed bypassing g entirely and recovering discarded guard info at CE.lean:763. v37 replaces both with the mathematically correct approach: extend g at each insertion so c2' is maintained as an omega_chain invariant. (3) SoundnessLemmas fix and ROADMAP snapshot already done (v35 phases 1-2). (4) Phases 0, 1, 2 from v36 carry over unchanged.

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
- Implement lemma_2_7 body (Burgess Lemma 2.7, Until-formula splitting)
- Extend g during point insertion: modify EliminationResult to carry new g-values, update each elimination function (C4, C4', C5, C5', density) to assign proper B, B', B'' values from Lemmas 2.4, 2.6, 2.7
- Thread c0+c2' through the omega_chain as joint invariant (not just c0)
- Close C4/C4' sorry sites using lemma_2_6_splitting with c2' available from the omega_chain invariant
- Implement full Lemma 2.10 (C5 with guard) including n>0 case via Lemma 2.7/2.8
- Prove limit_satisfies_c5_full connecting finite g-values to limit_g
- Close FUC/FSC via Burgess Claim 2.11: C5 gives eta in g(x,y), C3 gives g(x,y) subset f(z)
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary
- Update ROADMAP.md to reflect chronicle completion

**Non-Goals**:
- A4a removal (separate task 115, post-107 cleanup)
- BXCanonical sorry closure (task 109, secondary path)
- Removing BX7 (A7a coexists alongside BX7)
- Full Burgess Lemma 2.8 formalization (only needed to the extent required by C5 n>0)
- Density axiom addition (Burgess D0 bypasses the density gap entirely)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Burgess D0 seed consistency proof is complex with BX axioms (BX5+BX14+BX13 chain) | H | M | Handoff 49 provides detailed axiom mapping. Team research (report 51) confirms the mathematical path. Start with BX axiom sufficiency verification (Phase 1) before committing to implementation. |
| BX13 does not provide A3a's exact role in D0 consistency | H | L | Phase 1 explicitly verifies this before implementation. Fallback: if BX13 is insufficient, identify what additional axiom or lemma is needed and adjust. |
| EliminationResult refactor breaks existing proofs | M | M | The refactor adds fields (c2', g-value witnesses) without removing existing ones. Existing proofs that use `g_agrees` will need updating to `g_agrees_old` (g agreement on old pairs only). Build at each step. |
| Threading c2' through omega_chain is harder than c0 alone | H | M | Each elimination function must prove c2' for its output chronicle. The singleton satisfies c2' vacuously. For new adjacent pairs involving the inserted point, the g-value IS the B/B'/B'' from the insertion lemma. For old adjacent pairs, g is unchanged. |
| Lemma 2.7 BX5+BX7+BX13 chain fails to compile | M | M | The helpers `right_mono_until_mcs` and `untl_conj_eta_of_g_content` already exist in PointInsertion.lean. The D0 pattern from Phase 2 (lemma_2_6_splitting) serves as template. |
| Full Lemma 2.10 with n>0 case requires Lemma 2.8 | M | L | Lemma 2.8 is the Since-direction mirror of Lemma 2.7. The structure is identical modulo Since/Until swap. If time-constrained, stub it with a clearly documented sorry. |
| FUC/FSC Claim 2.11 argument requires connecting finite g-values to limit_g | H | M | The limit_g definition (ChronicleConstruction.lean:837) is {phi | forall y in limit_dom, x < y < z -> phi in limit_f(y)}. With proper finite g-values threaded, limit_g(x,y) contains the guard phi because C5 elimination guarantees phi in g_n(x,y) at finite stage n, and g_n(x,y) subset f_n(z) for intermediate z via c2' + C3, which propagates to limit_f(z). |
| Effort underestimation (20h budget for 9 phases) | M | M | Each phase independently committable. Phases 2 and 3 can run in parallel. Partial completion acceptable with sorry stubs clearly marking remaining work. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Clean Non-Burgess Cruft [COMPLETED]

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

### Phase 1: Verify BX Axiom Sufficiency for D0 Seed [COMPLETED]

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

### Phase 2: Rewrite lemma_2_6_splitting with Burgess D0 Seed [IN PROGRESS]

**Status**: Proof strategy documented but NOT implemented. `splitting_seed_consistent` at line 902 still has `sorry`. Documentation for the BX5+BX14+BX13 chain approach is in place, but the actual proof implementation is pending.

**Current State**:
- `splitting_seed` definition exists
- `splitting_seed_consistent` has full proof strategy documented in comments
- `lemma_2_6_splitting` structure is correct but depends on unproven seed consistency
- **BLOCKER**: `splitting_seed_consistent` sorry at line 902

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
- `splitting_seed_consistent` sorry-free
- `lake build` succeeds
- PointInsertion.lean sorry count: TBD (lemma_2_7 work remains)

---

### Phase 3: Implement lemma_2_7 (Until-Formula Splitting) [IN PROGRESS]

**Status**: Proof strategy documented but NOT fully implemented. `lemma_2_7_seed_consistent` at line 1139 still has `sorry`. The `lemma_2_7` theorem body exists but several membership proofs were incorrectly replaced with `sorry` placeholders.

**Current State**:
- `lemma_2_7_seed` definition exists
- `lemma_2_7_seed_consistent` has proof strategy documented but not implemented
- `lemma_2_7` body exists but has 5 sorry sites (lines 1161, 1162, 1164, 1166, 1206)
- **BLOCKERS**: 
  - `lemma_2_7_seed_consistent` sorry at line 1139
  - Membership proofs in `lemma_2_7` need to be completed

**Goal**: Implement the body of `lemma_2_7` (Burgess Lemma 2.7, p. 371), which handles Until-formula splitting. This is needed before Phase 6 because the C5 extension in the n>0 case (full Lemma 2.10) uses lemma_2_7 to split Until-formula witnesses.

**Burgess Lemma 2.7**: Given BurgessR3Maximal(A, B, C) with U(xi, eta) in A and eta not in B, produce B', D, B'' with:
- BurgessR3Maximal(A, B', D) and BurgessR3Maximal(D, B'', C)
- SetMaximalConsistent D
- xi in D (the splitting MCS contains the guard)
- eta in B' (the interval from A to D contains the event)

**D0 seed for Lemma 2.7**:
```
D0 = {S(alpha, beta AND eta) : alpha in A, beta in B}
     union B
     union {xi}
     union {U(gamma, beta) : gamma in C, beta in B}
```

**Consistency proof uses BX5 + BX7 + BX13 chain** (Burgess p. 371):
1. From eta not in B and maximality: obtain beta0 in B, gamma0 in C with neg-U(gamma0, beta0 AND eta) in A
2. BX5 on U(xi, eta): U(xi AND U(xi,eta), eta) in A
3. BX5 on U(beta0, gamma0): U(beta0 AND U(beta0,gamma0), gamma0) in A
4. BX7 (linear_until) on these two enriched Until formulas: three-way disjunction D1 or D2 or D3
5. Eliminate D1 and D2 using neg-U(beta0 AND eta, gamma0) in A + left_mono_until
6. D3 survives: U(phi1 AND phi2, phi1 AND gamma0) in A where phi1 = xi AND U(xi,eta)
7. BX10 gives F(phi1 AND gamma0) in A, so seed including xi and g_content(A) and h_content(C) is consistent
8. Lindenbaum to MCS D with xi in D, g_content(A) subset D, g_content(D) subset C
9. eta in B' from U(xi, beta AND eta) in A for all beta in B (via `untl_conj_eta_of_g_content`), plus maximality

**Tasks**:
- [ ] Define `burgess_D0_until` computing D0 for Lemma 2.7
- [ ] Prove maximality extraction: from eta not in B, obtain beta0, gamma0, neg-U(gamma0, beta0 AND eta) in A
- [ ] Prove BX5+BX7 three-way disjunction and D1/D2 elimination
- [ ] Prove seed consistency using the surviving D3 case
- [ ] Implement lemma_2_7 body using D0 pattern from Phase 2 as template
- [ ] Prove eta in B' from the U(xi, beta AND eta) membership and maximality
- [ ] Verify lemma_2_7 compiles sorry-free
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: 1 (BX axiom sufficiency confirmed; shares same BX axiom infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement lemma_2_7 body (~250 lines, replacing sorry at line 1052)

**Verification**:
- `lemma_2_7` sorry-free
- PointInsertion.lean sorry count reduced (depends on Phase 2 completion)
- `lake build` succeeds

---

### Phase 4: Extend g During Point Insertion + Thread c2' Through omega_chain [NOT STARTED]

**Status**: Architectural design documented but NO implementation done. Previous attempt added documentation-only comments to `EliminationResult` which caused syntax errors (now reverted). Actual implementation of c2' field, g-value tracking, and threading through omega_chain is pending.

**Prerequisites**: Phases 2 and 3 must be complete (lemma_2_6_splitting and lemma_2_7 sorry-free)

**Required Changes**:
1. **EliminationResult**: Add c2' field to track BurgessR3Maximal invariant
2. **g_value tracking**: Track g-values for new adjacent pairs
3. **c2'_preservation**: Prove old adjacent pairs maintain c2'
4. **omega_chain**: Thread c0 AND c2' as joint invariant (currently only c0)

**Goal**: Make g a first-class mathematical object by modifying EliminationResult to carry new g-values and updating each elimination function to assign proper B, B', B'' values. Thread c0+c2' as a joint omega_chain invariant.

This is the core architectural change of v37. Currently, elimination functions set `chi'.g = chi.g` for all pairs (CE.lean:177, line 189), and the omega_chain carries only c0 as an invariant (ChronicleConstruction.lean:253-260). After this phase, each elimination function properly assigns g-values for new adjacent pairs, and the omega_chain carries both c0 and c2'.

**Burgess context**: In Burgess 1982, g is a first-class object of the chronicle (f, g, dom). At each point insertion:
- Lemma 2.4 (C5 elimination) produces B as g'(x,y) for the new pair (x,y)
- Lemma 2.6 (C4 elimination) produces B', B'' as g'(x,z) and g'(z,y) for the split pair
- Lemma 2.7 (C5 n>0, Until-formula splitting) similarly produces B', B''
- C3 determines g'(w,z) for non-adjacent pairs

**Sub-tasks**:

**4a: Refactor EliminationResult to carry c2'**:
- [ ] Add `c2' : val.c2'` field to `EliminationResult` structure (ChronicleTypes.lean or CounterexampleElimination.lean)
- [ ] Add hypothesis `h_c2' : chi.c2'` to `eliminate_potential_counterexample` signature (alongside existing `h_c0`)
- [ ] Update all call sites that construct EliminationResult to provide c2' proof

**4b: Modify C5/C5' elimination to assign g-values**:
- [ ] In `eliminate_C5_counterexample` (CE.lean:167): capture `_B` from `lemma_2_4` output (currently discarded at line 182)
- [ ] Change the chronicle construction (line 187) from `chi.g` to a new g' that assigns B to the new adjacent pair (x, y) where y is the inserted point
- [ ] For pairs not involving the new point, g' = chi.g
- [ ] Prove c2' for the new chronicle: old adjacent pairs have unchanged g (from h_c2'), the new adjacent pair (x,y) has g(x,y) = B from lemma_2_4 which gives BurgessR3Maximal by construction
- [ ] Mirror for `eliminate_C5'_counterexample` (Since direction)

**4c: Modify C4/C4' elimination to assign g-values**:
- [ ] In `eliminate_C4_counterexample` (CE.lean, hard case at line 412): when inserting z between w and w_next, call `lemma_2_6_splitting` (now available from Phase 2) to get B', D, B''
- [ ] Assign g'(w, z) = B' and g'(z, w_next) = B'' in the new chronicle
- [ ] Prove c2': old adjacent pairs unchanged, new pairs (w,z) and (z,w_next) have BurgessR3Maximal from lemma_2_6_splitting output
- [ ] This simultaneously closes the sorry at line 412 (C4 hard case) -- the splitting point D has neg-gamma in D
- [ ] Mirror for C4' (Since direction, sorry at line 510)

**4d: Modify density elimination to assign g-values**:
- [ ] When inserting midpoint z between x and y, split g(x,y) into g'(x,z) and g'(z,y) using BurgessR3Maximal from lemma_2_6_splitting (with the trivial case where delta is arbitrary)
- [ ] Prove c2' for new adjacent pairs

**4e: Thread c2' through omega_chain**:
- [ ] Change `omega_chain` return type from `{ chi : Chronicle // chi.c0 }` to `{ chi : Chronicle // chi.c0 AND chi.c2' }` (ChronicleConstruction.lean:253)
- [ ] Update `omega_chain` base case: singleton_chronicle satisfies c2' vacuously (already proved as `singleton_c2'`)
- [ ] Update `omega_chain` step case: use the c2' field of EliminationResult
- [ ] Update `omega_chain_c0` and add `omega_chain_c2'` accessor
- [ ] Add g-agreement theorem: for old adjacent pairs, g is preserved across steps

**Timing**: 5 hours

**Depends on**: 2, 3 (lemma_2_6_splitting and lemma_2_7 sorry-free, needed for C4/C4' g-value construction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- refactor EliminationResult, update all elimination functions to assign g-values and prove c2' (~200 lines of changes)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- thread c2' through omega_chain, add g-agreement theorems (~80 lines of changes)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- EliminationResult c2' field if structure is defined there

**Verification**:
- C4/C4' sorry sites (CE.lean lines 412, 510) closed as a byproduct of g-value assignment
- CounterexampleElimination.lean sorry count: 0
- omega_chain carries c0+c2' joint invariant
- `lake build` succeeds

---

### Phase 5: Close C4/C4' via Burgess Lemma 2.9 with Proper c2' [NOT STARTED]

**Goal**: Verify that the C4/C4' sorry sites were closed in Phase 4 as a byproduct of g-value assignment, or complete any remaining work.

**Context**: Phase 4c modifies the C4 hard case (CE.lean line 412) to call lemma_2_6_splitting for g-value construction. The splitting point D has neg-gamma in D by construction. This should simultaneously close the sorry. Phase 5 is a verification/cleanup phase.

**If Phase 4c fully closed the sorries**:
- [ ] Verify both C4 (line 412) and C4' (line 510) sorry sites are eliminated
- [ ] Run `lake build` to confirm

**If Phase 4c left residual work** (e.g., the c2' hypothesis for lemma_2_6_splitting at the sorry site):
- [ ] The c2' invariant from the omega_chain provides BurgessR3Maximal(f(w), g(w,w_next), f(w_next)) for the adjacent pair
- [ ] Apply lemma_2_6_splitting directly: given BurgessR3Maximal and gamma not in g(w,w_next) (from maximality), get D with neg-gamma in D
- [ ] Close the sorry using D as the splitting witness

**Timing**: 1 hour

**Depends on**: 4 (c2' available from omega_chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- if residual work remains

**Verification**:
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Implement Full Lemma 2.10 (C5 with Guard) + Prove limit_satisfies_c5_full [NOT STARTED]

**Goal**: Strengthen C5 elimination to include the guard (xi in f(z) for intermediate z) and prove this propagates to the limit. This is the mathematical core that enables FUC/FSC.

**Burgess Lemma 2.10**: When U(xi, eta) in f(x) and no witness exists, add y with eta in f(y). The guard must hold at all intermediate points z with x < z < y.

**Base case (n=0)**: The inserted point y is beyond all domain points, so there are no intermediate domain points. Guard is vacuously satisfied. The current `eliminate_C5_counterexample` already handles this (CE.lean:167). With Phase 4's g-value assignment, B = g'(x,y) from Lemma 2.4 carries the guard info implicitly.

**Inductive case (n>0)**: When there are domain points between x and the endpoint, use Lemma 2.7 (Until-formula splitting) to insert a point that maintains the guard. Specifically:
- If there exists z in dom with x < z < y and xi not in f(z), the guard fails
- Apply Lemma 2.7 to get D with xi in D and eta in B' (the interval from x to D)
- The new point D restores the guard locally
- Iterate until all intermediate points satisfy the guard

**What this changes in EliminationResult**:
- Strengthen `c5_forward_witness` to include: `forall z in val.dom, pc.x < z -> z < y -> pc.xi in val.f z AND Formula.untl pc.xi pc.eta in val.f z`
- This matches the full C5 definition in ChronicleTypes.lean:427-433

**Proving limit_satisfies_c5_full**: With proper g-values at finite stages:
1. C5 at finite stage n gives: y in dom(n) with eta in f(y) and guard (xi in f(z)) for all z in dom(n) between x and y
2. At the limit, the guard must hold for ALL limit_dom points between x and y
3. Key argument: xi in limit_g(x, y) because C5 elimination places xi in g_n(x,y) at the finite stage, and g-values are preserved at later stages. Then limit_g(x,y) subset limit_f(z) for intermediate z by C3 at the limit (already proved as `limit_c3_interval_subset_point`).
4. Additionally, U(xi,eta) in limit_g(x,y) ensures the Until propagation at intermediate points.

**Tasks**:
- [ ] Strengthen `c5_forward_witness` in EliminationResult to include full guard info
- [ ] Update `eliminate_C5_counterexample` to prove the strengthened witness:
  - Base case (no intermediate points): guard vacuously true
  - If intermediate points exist with guard failure: apply lemma_2_7 to fix
- [ ] Mirror strengthening for `c5_backward_witness` (Since direction)
- [ ] Add g-value propagation lemma: at finite stage n, if C5 elimination at step k (k <= n) placed xi in g_k(x,y), then xi in g_n(x,y) for all subsequent stages where (x,y) remains adjacent
- [ ] Prove `limit_satisfies_c5_full`: for U(xi,eta) in limit_f(x), there exists y in limit_dom with eta in limit_f(y) AND xi in limit_f(z) for all z in limit_dom between x and y
  - Use: xi in limit_g(x,y) from finite stage g-values
  - Use: limit_c3_interval_subset_point gives limit_g(x,y) subset limit_f(z) for intermediate z
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 4 (g-values in EliminationResult), 5 (C4/C4' confirmed closed, so limit construction is sound)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- strengthen C5 witness fields (~60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- prove limit_satisfies_c5_full with g-value propagation (~120 lines)

**Verification**:
- `limit_satisfies_c5_full` proved (sorry-free)
- Full C5 guard info available at the limit
- `lake build` succeeds

---

### Phase 7: Close FUC/FSC via Claim 2.11 [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and forward Since coherence, using Burgess's Claim 2.11.

**Burgess Claim 2.11**: The limit chronicle satisfies Until/Since coherence:
- For U(phi, psi) in f(t): C5 at the limit gives witness y > t with psi in f(y) and the guard phi in f(z) for all intermediate z
- The guard follows from: C5 elimination gives phi in g(t,y), and C3 at the limit gives g(t,y) subset f(z) for intermediate z

**Concretely at the sorry sites**:
- `cantor_bfmcs_restricted_fuc` (line 604) needs: given U(phi,psi) in the Cantor-mapped MCS at index t, produce witness s > t with psi at s and guard phi at all intermediate indices
- This follows from `limit_satisfies_c5_full` (Phase 6) composed with the Cantor isomorphism

**Tasks**:
- [ ] Inspect FUC sorry at line 615 with `lean_goal` to understand exact proof obligation
- [ ] Connect `limit_satisfies_c5_full` to the Cantor-based BFMCS structure
- [ ] Map the limit C5 witness through the Cantor isomorphism to get the BFMCS witness
- [ ] Close FUC sorry site (forward Until coherence)
- [ ] Inspect FSC sorry at line 619 with `lean_goal`
- [ ] Close FSC sorry site (forward Since coherence, mirror of FUC using limit_satisfies_c5'_full)
- [ ] Run `lake build`

**Timing**: 2 hours

**Depends on**: 6 (limit_satisfies_c5_full provides the witnesses)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~80 lines each)

**Verification**:
- ChronicleToCountermodel.lean sorry count: 0
- `lake build` succeeds

---

### Phase 8: Final Audit, Validation, and ROADMAP Update [NOT STARTED]

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

**Depends on**: 7

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
- [ ] Phase 3: `lemma_2_7` sorry-free (Burgess Until-formula splitting)
- [ ] Phase 4: EliminationResult carries c2', g-values properly assigned, C4/C4' sorry sites closed as byproduct
- [ ] Phase 5: C4/C4' confirmed closed, CounterexampleElimination sorry count = 0
- [ ] Phase 6: `limit_satisfies_c5_full` proved, full C5 guard at limit
- [ ] Phase 7: FUC/FSC sorry sites (lines 615, 619) closed via Claim 2.11
- [ ] Phase 8: `grep -rn "sorry" Chronicle/` returns no active sorry usages
- [ ] Phase 8: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)

## Artifacts & Outputs

- `plans/51_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (cruft cleanup + Burgess D0 seed for 2.6 and 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (EliminationResult refactor, g-value assignment, C4/C4' sorry closure, C5 guard strengthening)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (c2' omega_chain invariant, g-agreement, limit_satisfies_c5_full)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure via Claim 2.11)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (EliminationResult c2' field, if structure defined there)
- Updated `specs/ROADMAP.md` (chronicle completion)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Phase 0 (cruft cleanup)**: Revert via git if any breakage. All deleted code is non-Burgess helpers with sorry bodies -- no functional loss.
- **Phase 2 (D0 seed consistency proof too complex)**: If the BX5+BX14+BX13 chain does not translate cleanly, the handoff 49 Approach 3 (weakened output without g_content conditions) is a viable interim target. This defers full BurgessR3Maximal output but may unblock later phases.
- **Phase 3 (lemma_2_7 BX7 chain fails)**: If D1/D2 elimination via neg-U(gamma0, beta0 AND eta) does not work, the two-step BX7 derivation chain (from prior handoff) can substitute for A7a in the seed consistency proof.
- **Phase 4 (g-value assignment breaks existing proofs)**: The refactor is additive (new fields), not destructive. If `g_agrees` changes break downstream, temporarily maintain both old and new g-agreement fields and migrate incrementally.
- **Phase 4e (c2' threading too complex)**: If threading c2' through all elimination branches is prohibitive, thread it through only C5/C5' and C4/C4' branches (the ones that need it), and have density/G-propagation branches use a trivial c2' proof.
- **Phase 6 (full Lemma 2.10 n>0 case too complex)**: If the inductive argument is too involved, a weaker version using only the base case (n=0) plus the limit_g C3 property may suffice for many formulas. Stub the n>0 case with sorry and document.
- **Phase 7 (FUC/FSC blocked by limit_satisfies_c5_full weakness)**: If the g-value chain from finite to limit is insufficient, a direct argument via the definition of limit_g (which is exactly the set of formulas in all intermediate limit_f values) may bypass the need for finite-stage g tracking. This is a fallback that works because limit_g is defined as the intersection, not as a limit of finite g-values.
- Git history preserves all prior states; each phase is independently committable.
