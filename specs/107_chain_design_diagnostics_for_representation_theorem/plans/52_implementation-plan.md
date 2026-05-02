# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v53)

- **Task**: 107 - Chain design diagnostics for representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/52_team-research.md], [reports/52_teammate-a-findings.md], [reports/52_teammate-b-findings.md], [reports/52_teammate-c-findings.md], [reports/52_teammate-d-findings.md]
- **Artifacts**: plans/52_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Plan Version**: 53

## Overview

This plan closes all 9 remaining sorry sites in the Burgess chronicle construction to achieve a sorry-free `dd_countermodel_chronicle` and, by extension, the BX completeness representation theorem. The sorry sites span three files: 5 in PointInsertion.lean (Burgess D0 seed consistency for Lemmas 2.6 and 2.7), 2 in CounterexampleElimination.lean (C4/C4' hard cases requiring c2' invariant), and 2 in ChronicleToCountermodel.lean (FUC/FSC coherence requiring full C5 with guard). The approach follows Burgess 1982 faithfully: compression of finite subsets into a single event formula, BX5+BX14+BX13+BX10 axiom chains, and BX7 linearity for the Lemma 2.7 variant.

Definition of done: `#print axioms dd_countermodel_chronicle` clean (no `sorryAx`), `lake build` succeeds.

### Research Integration

Team research report (52) with 4 teammates confirmed:
- All 5 PointInsertion sorry sites are closeable with existing BX axiom infrastructure plus 4 helper lemmas (`collect_guards_mem_of_untl`, `collect_guards_mem_of_snce`, `d0_c_event_list_gamma_mem`, `d0_a_event_list_alpha_mem`)
- BX7 (`linear_until`) is the critical axiom for Lemma 2.7's 5th seed component
- Formula constructor injectivity (`Formula.untl.injEq`, `Formula.snce.injEq`) resolves Classical.choose determinism
- C4/C4' requires restoring c2' (BurgessR3Maximal at adjacent pairs) as omega_chain invariant
- FUC/FSC requires `limit_satisfies_c5_full` (C5 with guard, not just weak endpoint)
- Dead code (~250 lines) identified for cleanup

### Prior Plan Reference

Plan v52 established the correct architectural direction: direct D0 seed construction (bypassing the unprovable Since condition for DC({beta}union B)), g-value tracking as first-class chronicle object, and c2' threading through omega_chain. Phases 0-1 are completed (cruft cleanup, BX axiom sufficiency verification). Phases 2-3 are partially done (D0 seed defined, lemma_2_6_splitting body sorry-free, lemma_2_7 body sorry-free except seed consistency). The remaining work is the 3 seed consistency proofs, 2 C4/C4' closures, and 2 FUC/FSC closures. Prior plan effort estimate of 20 hours was slightly optimistic; the new research reveals the BX7 chain for Lemma 2.7 is a 10-step proof, and c2' threading is more involved than initially assessed.

### Roadmap Alignment

This plan advances the primary ROADMAP milestone: sorry-free BX completeness representation theorem (Path B, D=Rat). Completing task 107 closes the longest-running open work item and unblocks tasks 95 (axiom audit) and 109 (BXCanonical cleanup).

## Goals & Non-Goals

**Goals**:
- Close all 5 sorry sites in PointInsertion.lean (Burgess compression proofs)
- Close all 2 sorry sites in CounterexampleElimination.lean (C4/C4' hard cases)
- Close all 2 sorry sites in ChronicleToCountermodel.lean (FUC/FSC coherence)
- Achieve sorry-free `dd_countermodel_chronicle`
- Remove identified dead code (~250 lines)
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- Generalizing beyond D=Rat to arbitrary ordered groups
- Optimizing proof term sizes or compilation speed
- Refactoring Chronicle type hierarchy beyond c2' addition
- Addressing sorry sites outside the Chronicle/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Classical.choose non-determinism prevents d0_c_event_list tracking | H | L | Formula constructor injectivity (injEq) makes choice canonical; if needed, refactor filterMap to use pattern matching directly |
| BX7 three-way disjunction elimination is more complex than Burgess's prose suggests | M | M | Follow Burgess p.372 literally; the two eliminated disjuncts contradict neg-untl(beta0 AND eta, gamma0) via monotonicity |
| c2' threading through omega_chain breaks existing proofs | H | L | Refactor is additive (new fields), not destructive; maintain both old and new g-agreement fields if needed |
| Lemma 2.7's 5th component (snce(beta AND eta, alpha)) requires eta in the event guard | H | M | BX7 application produces the third disjunct containing xi (from untl(xi,eta)), and the event includes both b and eta via the compound guard |
| Full C5 guard propagation from finite stages to limit is subtle | M | M | Fallback: prove limit_satisfies_c5_full directly from omega_chain construction (each violation eliminated), bypassing finite-stage tracking |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Helper Lemma Infrastructure [NOT STARTED]

**Goal**: Implement the 4 missing helper lemmas that are prerequisites for closing sorry sites 1-3 in `burgess_D0_finite_subset_consistent`, plus verify Formula constructor injectivity. Also remove identified dead code.

**Tasks**:
- [ ] Verify `Formula.untl.injEq` and `Formula.snce.injEq` exist via `lean_local_search`; if not, derive from `DecidableEq` or constructor injectivity
- [ ] Implement `collect_guards_mem_of_untl`: if `untl(beta', gamma') in L` with `beta' in B`, then `beta' in collect_guards output`. Proof by induction on L, following `collect_guards_mem_of_B` pattern but for the untl branch of `d0_guard`
- [ ] Implement `collect_guards_mem_of_snce`: if `snce(beta', alpha') in L` with `beta' in B`, then `beta' in collect_guards output`. Same pattern as above for snce branch
- [ ] Implement `d0_c_event_list_gamma_mem`: if `untl(beta', gamma') in L` with `beta' in B` and `gamma' in C`, then `gamma' in d0_c_event_list`. Uses `Formula.untl.injEq` to show Classical.choose recovers gamma'
- [ ] Implement `d0_a_event_list_alpha_mem`: if `snce(beta', alpha') in L` with `beta' in B` and `alpha' in A`, then `alpha' in d0_a_event_list`. Uses `Formula.snce.injEq` to show Classical.choose recovers alpha'
- [ ] Remove dead code: `until_implies_F_mcs` (duplicate of `until_F_mcs`), `and_left_impl`/`and_right_impl` (trivial wrappers)
- [ ] Reduce ~250 lines of inline design commentary to concise proof comments
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add 4 helper lemmas (~80 lines), remove dead code (~50 lines), trim commentary (~200 lines)

**Verification**:
- All 4 helper lemmas compile sorry-free
- `Formula.untl.injEq` / `Formula.snce.injEq` confirmed available
- `lake build` succeeds
- No regressions in existing sorry-free lemmas

---

### Phase 2: Close PointInsertion Sorry Sites 1-4 (Burgess D0 Compression) [NOT STARTED]

**Goal**: Close the 3 sorry sites in `burgess_D0_finite_subset_consistent` (lines 1573, 1581, 1584) and the sorry in `burgess_D0_finite_subset_consistent_incons` (line 1614) using the Burgess compression argument with the helper lemmas from Phase 1.

**Tasks**:
- [ ] **Site 1 (line 1573, phi in B case)**: Use `collect_guards_mem_of_B` to get `phi in b_list_raw`, then `List.mem_cons.mpr (Or.inr h)` to get `phi in b_list`, then `list_conj_implies_elem` for `b.imp phi`, then chain `event -> b -> phi` via `DerivationTree.modus_ponens`
- [ ] **Site 2 (line 1581, phi = untl(beta', gamma') case)**: Use `collect_guards_mem_of_untl` to get `beta' in b_list_raw` and hence `b.imp beta'` via `list_conj_implies_elem`. Use `d0_c_event_list_gamma_mem` to get `gamma' in c_list` and hence `gamma_hat.imp gamma'`. Apply `untl_left_mono_deriv` (b -> beta') and `untl_right_mono_deriv` (gamma_hat -> gamma') to derive `event -> untl(b, gamma_hat) -> untl(beta', gamma_hat) -> untl(beta', gamma')`
- [ ] **Site 3 (line 1584, phi = snce(beta', alpha') case)**: Use `collect_guards_mem_of_snce` to get `beta' in b_list_raw` and hence `b.imp beta'`. Use `d0_a_event_list_alpha_mem` to get `alpha' in a_list`. Apply `h_ev_snce alpha' h_alpha'_in_a` to get `event.imp (snce b alpha')`. Apply `snce_left_mono_deriv` with `b.imp beta'` to derive `snce(b, alpha') -> snce(beta', alpha')`
- [ ] **Site 4 (line 1614, inconsistent case)**: Implement `burgess_D0_finite_subset_consistent_incons` as a self-contained proof following Burgess. Since beta.neg in B: (a) pick gamma0 in C from MCS nonemptiness, (b) untl(beta.neg, gamma0) in A from burgessR3, (c) BX5 self-accumulation, (d) BX13 iterated enrichment for a_list (Since events), (e) BX10 F-extraction, (f) same `h_event_implies_L` structure as consistent case (beta.neg is just another B-element, no BX14 needed)
- [ ] Verify `burgess_D0_seed_consistent` compiles sorry-free (it dispatches to the above two theorems)
- [ ] Verify `lemma_2_6_splitting` remains sorry-free
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- close 4 sorry sites (~120 lines of proof)

**Verification**:
- `burgess_D0_finite_subset_consistent` sorry-free
- `burgess_D0_finite_subset_consistent_incons` sorry-free
- `burgess_D0_seed_consistent` sorry-free
- `lemma_2_6_splitting` sorry-free
- PointInsertion.lean sorry count reduced from 5 to 1
- `lake build` succeeds

---

### Phase 3: Close PointInsertion Sorry Site 5 (Lemma 2.7 Seed Consistency via BX7) [NOT STARTED]

**Goal**: Close the sorry in `lemma_2_7_seed_consistent` (line 2050) using the full Burgess Lemma 2.7 proof with BX7 (linear_until) for the 5th seed component.

**Tasks**:
- [ ] Implement `lemma_2_7_neg_untl_exists`: extract beta0 in B, gamma0 in C with `neg(untl(beta0 AND eta, gamma0)) in A` from `h_eta_not_B` and `BurgessR3Maximal_extension_fails`
- [ ] Verify `linear_until_mcs` (BX7 MCS wrapper) exists via `lean_local_search "linear_until"`; if missing, implement it from the BX7 axiom in Axioms.lean
- [ ] Implement the BX7 three-way disjunction step (Burgess p.372):
  - From BX5 on `untl(b, gamma_hat)` in A: `untl(b AND untl(b, gamma_hat), gamma_hat)` in A
  - From BX5 on `untl(xi, eta)` in A: `untl(xi AND untl(xi, eta), eta)` in A
  - Apply BX7 to get three disjuncts: `untl(p1, theta)`, `untl(p2, theta)`, `untl(p3, theta)` where theta includes both b and eta
  - Eliminate disjunct 1 via monotonicity + `neg(untl(beta0 AND eta, gamma0))` in A
  - Eliminate disjunct 2 via monotonicity + `neg(untl(beta0 AND eta, gamma0))` in A
  - The surviving disjunct 3 is `untl(b AND untl(b, gamma_hat) AND xi, theta)` in A where theta = `b AND untl(b, gamma_hat) AND xi AND eta`
- [ ] Apply BX14 (separation_until_mcs) to the surviving disjunct to incorporate neg(beta0 AND eta) and hence separate beta from eta in the event
- [ ] Apply BX13 (enrichment_until_mcs) iteratively to pack `snce(guard, alpha_j)` for each alpha_j in a_list, where the guard now contains both b and eta
- [ ] Apply BX10 (until_implies_F_mcs) to extract `F(event)` in A
- [ ] Prove `h_event_implies_L` for the 5-component seed:
  - Components 1-3 (B, xi, untl-formulas): same as Phase 2 pattern
  - Component 4 (snce(beta', alpha)): same as Phase 2 pattern
  - Component 5 (snce(beta' AND eta, alpha)): event implies `snce(guard, alpha)` where guard contains both b and eta; apply `snce_left_mono_deriv` with `guard -> beta' AND eta` (since guard includes b which includes beta', and guard includes eta from BX7 third disjunct)
- [ ] Wire `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false` for the contradiction
- [ ] Verify `lemma_2_7_seed_consistent` compiles sorry-free
- [ ] Verify `lemma_2_7` remains sorry-free
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 2 (reuses same helper infrastructure and same proof pattern as Phase 2)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- implement `lemma_2_7_neg_untl_exists` (~30 lines), `lemma_2_7_zeta_consistent` or inline BX7 chain (~150 lines), close sorry at line 2050 (~80 lines)

**Verification**:
- `lemma_2_7_seed_consistent` sorry-free
- `lemma_2_7` sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 4: Extend g During Point Insertion and Thread c2' Through omega_chain [NOT STARTED]

**Goal**: Make g a first-class mathematical object by modifying EliminationResult to carry c2' (BurgessR3Maximal at adjacent pairs), assign proper g-values in each elimination function, and thread c2' through the omega_chain construction. Close the C4/C4' sorry sites (CounterexampleElimination.lean lines 412, 510) as a byproduct.

**Tasks**:

**4a: Refactor EliminationResult to carry c2'**:
- [ ] Add `c2'` field to `EliminationResult` structure: for all adjacent pairs (x, y) in the new chronicle, `BurgessR3Maximal (f x) (g x y) (f y)`
- [ ] Add `h_c2'` hypothesis to `eliminate_potential_counterexample` signature alongside existing `h_c0`
- [ ] Update all call sites that construct EliminationResult to provide c2' proof

**4b: Modify C5/C5' elimination to assign g-values**:
- [ ] In `eliminate_C5_counterexample`: capture B from `lemma_2_4` output (currently discarded), construct g' that assigns B to the new adjacent pair (x, y)
- [ ] Prove c2' for the new chronicle: old pairs have unchanged g (from h_c2'), new pair has BurgessR3Maximal from lemma_2_4 construction
- [ ] Mirror for `eliminate_C5'_counterexample`

**4c: Modify C4/C4' elimination to assign g-values (closes sorry sites)**:
- [ ] In `eliminate_C4_counterexample` hard case (line 412): call `lemma_2_6_splitting` to get B', D, B'' for the split; assign g'(w, z) = B' and g'(z, w_next) = B''; the splitting point D has neg-gamma in D, closing the sorry
- [ ] Prove c2': old pairs unchanged, new pairs (w,z) and (z,w_next) have BurgessR3Maximal from `lemma_2_6_splitting` output
- [ ] Mirror for C4' (line 510) using Since-direction splitting

**4d: Modify density elimination to assign g-values**:
- [ ] When inserting midpoint z between x and y, split g(x,y) into g'(x,z) and g'(z,y) using BurgessR3Maximal from `lemma_2_6_splitting`
- [ ] Prove c2' for new adjacent pairs

**4e: Thread c2' through omega_chain**:
- [ ] Change `omega_chain` return type to carry both c0 and c2' as joint invariant
- [ ] Update base case: singleton chronicle satisfies c2' vacuously (no adjacent pairs)
- [ ] Update step case: use c2' field from EliminationResult
- [ ] Add `omega_chain_c2'` accessor alongside existing `omega_chain_c0`

- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 2, 3 (lemma_2_6_splitting and lemma_2_7 must be sorry-free for C4/C4' g-value construction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- refactor EliminationResult, update all elimination functions, close C4/C4' sorry sites (~200 lines of changes)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- thread c2' through omega_chain (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- EliminationResult c2' field if structure defined there

**Verification**:
- C4/C4' sorry sites (lines 412, 510) closed
- CounterexampleElimination.lean sorry count: 0
- omega_chain carries c0 + c2' joint invariant
- `lake build` succeeds

---

### Phase 5: Prove limit_satisfies_c5_full and Close FUC/FSC [NOT STARTED]

**Goal**: Strengthen C5 from weak (endpoint only) to full (endpoint plus guard at intermediate points), then close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for forward Until and Since coherence via Burgess Claim 2.11.

**Tasks**:

**5a: Prove limit_satisfies_c5_full**:
- [ ] Prove g-value propagation lemma: at finite stage n, if C5 elimination at step k placed xi in g_k(x,y), then xi in g_n(x,y) for all subsequent stages where (x,y) remains adjacent
- [ ] Prove `limit_satisfies_c5_full`: for `untl(xi, eta) in limit_f(x)`, there exists y in limit_dom with `eta in limit_f(y)` AND `xi in limit_f(z)` for all z in limit_dom between x and y
  - The guard follows from: C5 elimination gives xi in g(x,y) at finite stage, preserved at later stages; limit_g(x,y) inherits; `limit_c3_interval_subset_point` gives limit_g(x,y) subset limit_f(z) for intermediate z
- [ ] Mirror for Since direction: `limit_satisfies_c5'_full`

**5b: Close FUC/FSC sorry sites**:
- [ ] Inspect FUC sorry at line 615 with `lean_goal` to understand exact proof obligation
- [ ] Connect `limit_satisfies_c5_full` to the Cantor-based BFMCS structure; map the limit C5 witness through the Cantor isomorphism
- [ ] Close FUC sorry (forward Until coherence)
- [ ] Inspect FSC sorry at line 619 with `lean_goal`
- [ ] Close FSC sorry (forward Since coherence, mirror of FUC using `limit_satisfies_c5'_full`)
- [ ] Run `lake build`

**5c: Final audit**:
- [ ] Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`
- [ ] Grep for sorry in all Chronicle/ files -- verify no active sorry sites remain
- [ ] Verify all previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Update module docstrings in Chronicle/ files to reflect final proof structure

**Timing**: 4 hours

**Depends on**: 4 (c2' available from omega_chain, g-values assigned at finite stages)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- prove `limit_satisfies_c5_full`, g-value propagation (~120 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~80 lines each)

**Verification**:
- `limit_satisfies_c5_full` proved sorry-free
- ChronicleToCountermodel.lean sorry count: 0
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- Full `lake build` clean

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] Phase 1: all 4 helper lemmas compile sorry-free; dead code removed without breakage
- [ ] Phase 2: `burgess_D0_seed_consistent` sorry-free; `lemma_2_6_splitting` still sorry-free
- [ ] Phase 3: `lemma_2_7_seed_consistent` sorry-free; `lemma_2_7` still sorry-free; PointInsertion sorry count = 0
- [ ] Phase 4: EliminationResult carries c2'; C4/C4' sorry sites closed; CounterexampleElimination sorry count = 0
- [ ] Phase 5: `limit_satisfies_c5_full` sorry-free; FUC/FSC sorry sites closed; ChronicleToCountermodel sorry count = 0
- [ ] Final: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] Final: `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments

## Artifacts & Outputs

- `plans/52_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (helper lemmas, 5 sorry closures, dead code removal)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (EliminationResult refactor, g-value assignment, C4/C4' sorry closure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (c2' omega_chain invariant, limit_satisfies_c5_full)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (FUC/FSC closure via Claim 2.11)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (EliminationResult c2' field if defined there)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Phase 1 (helper lemmas)**: If `Formula.untl.injEq` does not exist, refactor `d0_c_event_list` and `d0_a_event_list` to use direct pattern matching instead of Classical.choose, avoiding the injectivity requirement entirely.
- **Phase 2 (D0 compression)**: Each sorry site is independently closeable. If one site blocks, commit the others and document the blocker. The inconsistent case (site 4) is fully independent from sites 1-3.
- **Phase 3 (BX7 chain)**: If BX7 three-way disjunction elimination is too complex, implement the 4-component version first (without 5th component), mark lemma_2_7_seed_consistent with a weakened sorry that documents exactly what remains, and close all other sorry sites. This gives a partial result with only 1 sorry remaining.
- **Phase 4 (c2' threading)**: The refactor is additive. If threading c2' through all elimination branches is prohibitive, thread it only through C5/C5' and C4/C4' branches (the ones that need it), and have density/G-propagation branches use trivial c2' proofs.
- **Phase 5 (FUC/FSC)**: If limit_satisfies_c5_full is blocked by finite-stage g tracking issues, use a direct argument via limit_g definition (intersection of intermediate f-values) to bypass finite-stage tracking.
- Git history preserves all prior states; each phase is independently committable.

## AGENT INSTRUCTIONS: Proof Architecture Reference

This section provides the exact proof structure for the implementation agent. Do not deviate from this architecture.

### The Burgess Compression Argument (Sites 1-4)

**Structure**: Given finite `L subset D0` and `d : DerivationTree L bot`, derive `False`.

**Step 1**: Classify L elements into (a) phi in B, (b) phi = beta.neg, (c) phi = untl(beta', gamma'), (d) phi = snce(beta', alpha').

**Step 2**: Form compressed conjunction. b = list_conj(beta0 :: b_list_raw) in B (DCS closed under conjunction). gamma_hat = list_conj(gamma0 :: c_list_raw) in C (MCS closed). a_list = alpha values from Since formulas.

**Step 3**: BX chain produces F(event) in A.
1. BX5 (`self_accum_until_mcs`): `untl(b AND untl(b, gamma_hat), gamma_hat) in A`
2. BX14 (`separation_until_mcs`): `untl(q, q AND (b AND beta).neg) in A` where q = b AND untl(b, gamma_hat)
3. BX13 (`enrichment_until_mcs`) applied iteratively for each alpha_j in a_list
4. BX10 (`until_implies_F_mcs`): `F(event) in A`

**Step 4**: Show event implies each element of L via monotonicity derivations.

**Step 5**: `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false` for contradiction.

### The Inconsistent Case (Site 4)

Same structure but simpler: beta.neg in B means it is just another B-element. No BX14 step needed. Use BX5 + BX13 + BX10 directly.

### The Lemma 2.7 BX7 Chain (Site 5)

Follow Burgess p.372 exactly:
1. BX5 on `untl(b, gamma_hat)`: `untl(b AND untl(b, gamma_hat), gamma_hat) in A`
2. BX5 on `untl(xi, eta)`: `untl(xi AND untl(xi, eta), eta) in A`
3. BX7 on the two Until formulas: three disjuncts
4. Eliminate disjuncts 1 and 2 using `neg(untl(beta0 AND eta, gamma0)) in A` + monotonicity
5. Surviving disjunct: `untl(b AND untl(b, gamma_hat) AND xi, theta) in A` where theta contains both b and eta
6. BX14 if needed for delta separation
7. BX13 iterated enrichment
8. BX10 F-extraction
9. Event implies all 5 seed components (component 5 uses guard containing eta from BX7)
10. Contradiction via consistency
