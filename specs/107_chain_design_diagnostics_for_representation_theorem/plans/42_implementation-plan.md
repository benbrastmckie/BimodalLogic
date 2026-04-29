# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v26)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 52 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md]
- **Artifacts**: plans/42_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v26 revises v25 to align with Burgess's actual construction method: each elimination function constructs g-values as DATA first (modifying the chronicle's g function for new pairs), with c2' (BurgessR3Maximal) following automatically from the construction. The key insight is that Burgess's Lemma 2.4 produces both a DCS interval set B and an MCS endpoint C simultaneously, and Lemma 2.6 splits an existing R(A,B,C) into two halves around a new point. The elimination functions must output a new g function that returns B (from Lemma 2.4 or 2.6) for new adjacent pairs, chi.g for old pairs, and C3 intersections for non-adjacent pairs. The 7 c2' sorry sites and 1 density sorry site are closed by this g-function construction; the 2 FUC/FSC sorry sites follow from the limit chronicle having proper g-values. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42 (team research, 4 teammates)**: All 4 teammates converge on single diagnosis. Root cause: g-values never constructed (g starts as empty_set in singleton chronicle and is never modified). Resolution Path 1 (BX8 seed) is dead (BX8 removed). Resolution Path 4 (remove c2') is infeasible (c2' consumed at lines 409, 546 in sorry-free code). Only viable path: restructure elimination functions to produce g-values matching Burgess's Lemmas 2.4/2.6.

### Prior Plan Reference

Plan v24 (artifact 41) had 9 phases, 45 hours. Phases 1-3 (documentation, A3a/A3b axioms, Lemma 2.3 closure) completed efficiently. Phase 4 (C4 nested case via BX6) also completed, closing 2 sorry sites. Phases 5-8 were BLOCKED because they assumed g-values could be obtained via `burgessR3Maximal_exists_from_seed` with seeds from `g_content` -- but the elimination functions never populate g, so g = empty_set everywhere, making seed extraction impossible.

Plan v25 correctly identified the infrastructure (extended lemma_2_4, Lemma 2.6 splitting) but treated c2' as separate proof obligations to discharge after g-construction. Plan v26 corrects this: c2' is NOT a separate proof obligation -- it is an automatic consequence of defining g correctly. Each phase specifies the exact g-function transformation and shows how BurgessR3Maximal holds by construction.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 9 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Extend `lemma_2_4` to also return B (the BurgessR3Maximal DCS interval set)
- Formalize Lemma 2.6 splitting: R(A,B,C) + delta not in B produces B', D, B'' with R(A,B',D), R(D,B'',C)
- Wire g-values into all 7 c2' sorry sites by constructing g functions whose values ARE BurgessR3Maximal by definition
- Close the density self-pair sorry site (line 1130) via intermediate MCS construction
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
| Lemma 2.6 splitting (three-way decomposition) may require new lattice-theoretic infrastructure for DCS intersection | H | L | The existing burgessR3Maximal infrastructure handles Zorn extension; splitting is a new use pattern but relies on same primitives |
| C3 non-adjacent g-value formula (g(w,z) = g(w,x) cap f(x) cap g(x,z)) may not type-check as a Set Formula intersection | M | L | C3 is already defined in ChronicleTypes.lean; the intersection formula matches the existing c3 definition |

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

### Phase 5: g-Value Infrastructure -- Extend lemma_2_4 to Return B and Formalize Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Build the mathematical infrastructure that produces `BurgessR3Maximal` values as DATA. Extended `lemma_2_4` returns both B (the DCS interval set) and C (the MCS endpoint) so that B can be directly assigned as a g-value. Lemma 2.6 splits an existing `BurgessR3Maximal(A, B, C)` into two halves around a new intermediate point.

**Tasks**:
- [ ] Extend `lemma_2_4` return type to include B: `exists B C, BurgessR3Maximal A B C /\ SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\ P(U(gamma,beta)) in C`. The key change: B is now a **named output** that callers assign as a g-value, not a discarded intermediate
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean to destructure the new return type (extract both B and C)
- [ ] Verify `lake build` succeeds with the extended return type (no sorry regressions)
- [ ] Formalize Lemma 2.6 splitting in PointInsertion.lean: given `BurgessR3Maximal A B C` and `delta not in B`, produce `B', D, B''` with `BurgessR3Maximal A B' D` and `BurgessR3Maximal D B'' C`. Specifically:
  - Input: `h_r3m : BurgessR3Maximal A B C`, `h_delta : delta not in B`, `h_mcs_A : SetMaximalConsistent A`, `h_mcs_C : SetMaximalConsistent C`
  - Output: `exists B' D B'', BurgessR3Maximal A B' D /\ BurgessR3Maximal D B'' C /\ SetMaximalConsistent D /\ delta.neg in D`
  - Construction: use `lemma_2_6` (counterexample insertion) to get D with delta.neg in D, then use `burgessR3Maximal_extension_exists` (Zorn) to extend to B' and B'' maximally
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

### Phase 6: C5 g-Value Construction -- g-Function Data for New Endpoint Pairs [NOT STARTED]

**Goal**: Close the 2 C5 c2' sorry sites (lines 830, 868) by constructing a g function whose values for new adjacent pairs ARE `BurgessR3Maximal` by definition. Burgess Lemma 2.10: "apply 2.4 to A=f(x) obtaining B,C. Set f'(y)=C, g'(x,y)=B."

**g-function transformation**: The EliminationResult's g field changes from `fun a b => chi.g a b` to:

```
g' a b :=
  if (a, b) = (x_max, y_new) then B       -- B from extended lemma_2_4
  else chi.g a b                            -- old pairs unchanged
```

where B is the `BurgessR3Maximal` DCS interval set returned by extended `lemma_2_4`. For c2', the new adjacent pair (x_max, y_new) has `BurgessR3Maximal(f(x_max), g'(x_max, y_new), f(y_new))` = `BurgessR3Maximal(f(x_max), B, C)` which holds by construction (it is exactly what `lemma_2_4` returns). Old adjacent pairs are unchanged, so c2' holds by `chi.c2'`.

**Tasks**:
- [ ] Inspect sorry site at line 830 (C5 forward) with `lean_goal` to capture exact proof state
- [ ] Identify where `lemma_2_4` is already called in the C5 forward case to obtain C (the MCS endpoint). Extract B from the same call using the extended return type
- [ ] Replace `g' = chi.g` with `g' a b := if (a = x_max /\ b = y_new) then B else chi.g a b` where B is from extended `lemma_2_4` applied to `f(x_max)` with the Until formula
- [ ] Prove c2' for the new chronicle:
  - Case (a,b) = (x_max, y_new): `g'(x_max, y_new) = B` and `BurgessR3Maximal(f(x_max), B, C)` holds by `lemma_2_4` output. Since `f'(y_new) = C`, this gives `BurgessR3Maximal(f'(x_max), g'(x_max, y_new), f'(y_new))`
  - Case (a,b) is an old adjacent pair: `g'(a,b) = chi.g(a,b)` and `f'(a) = chi.f(a)`, `f'(b) = chi.f(b)`, so `BurgessR3Maximal` holds by `chi.c2'`
- [ ] Close sorry site at line 830
- [ ] Inspect sorry site at line 868 (C5 backward / Since direction) with `lean_goal`
- [ ] Mirror for Since: extended `lemma_2_4` (Since variant) applied to `f(x_min)` with the Since formula gives B,C. Set `g' a b := if (a = y_new /\ b = x_min) then B else chi.g a b`
- [ ] Close sorry site at line 868
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- replace `g' = chi.g` with constructed g function in C5 cases (~60 lines of proof each)

**Verification**:
- Sorry count in CounterexampleElimination.lean drops from 7 to 5
- `lake build` succeeds

---

### Phase 7: Density Self-Pair Fix -- g-Value Construction via Intermediate MCS [NOT STARTED]

**Goal**: Fix the density sorry site (line 1130) where `BurgessR3Maximal(f(x), g', f(x))` (same MCS on both sides) is required. The current g-value `chi.g(pc.x, pc.y)` was constructed for endpoints `f(pc.x)` and `f(pc.y)`, but the density case sets `f(z) = f(pc.x)` so the new adjacent pair (pc.x, z) needs `BurgessR3Maximal(f(pc.x), ?, f(pc.x))`.

**g-function transformation**: The density case currently sets:
```
g' a b := if (a = pc.x /\ b = z) \/ (a = z /\ b = pc.y) then chi.g pc.x pc.y else chi.g a b
```
This reuses `chi.g(pc.x, pc.y)` which satisfies `BurgessR3Maximal(f(pc.x), chi.g(pc.x, pc.y), f(pc.y))` but NOT `BurgessR3Maximal(f(pc.x), chi.g(pc.x, pc.y), f(pc.x))` when `f(pc.x) /= f(pc.y)`. The fix requires constructing a new g-value for the (pc.x, z) pair.

**Tasks**:
- [ ] Inspect sorry site at line 1130 with `lean_goal` to understand the exact constraint
- [ ] Determine whether `lemma_2_4` can be applied to `f(pc.x)` with a self-Until formula to produce a B with `BurgessR3Maximal(f(pc.x), B, f(pc.x))`
- [ ] If self-Until is not available, construct B via `burgessR3Maximal_extension_exists` directly from `g_content(f(pc.x))` as seed (since f(pc.x) is the same MCS on both sides, the R3 seed conditions simplify)
- [ ] Replace the density g-function: instead of reusing `chi.g(pc.x, pc.y)` for both new pairs, construct fresh B for the (pc.x, z) pair where `BurgessR3Maximal(f(pc.x), B, f(pc.x))` holds by construction
- [ ] Close sorry site at line 1130
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure density case g-function (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- possibly modify EliminationResult type

**Verification**:
- Sorry count in CounterexampleElimination.lean drops by 1 (density site closed)
- `lake build` succeeds

---

### Phase 8: C4/g_prop/h_prop g-Value Construction via Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Close the 4 harder c2' sorry sites (lines 908, 946, 982, 1014) by constructing g-values via Lemma 2.6 splitting. These insert a new point z BETWEEN existing adjacent points (x, y) and need g-values for TWO new adjacent pairs: (x, z) and (z, y). Burgess Lemma 2.9: "apply 2.6 to R(f(x), g(x,y), f(y)) to get B', D, B''. Set g'(x,z)=B', f'(z)=D, g'(z,y)=B''."

**g-function transformation**: The EliminationResult's g field changes from the current pattern:
```
-- CURRENT (wrong): reuses old g for new pairs
g' a b := if (a = x /\ b = z) \/ (a = z /\ b = y) then chi.g x y else chi.g a b
```
to the correct Burgess construction:
```
-- NEW: Lemma 2.6 splitting produces distinct B', B'' for new pairs
g' a b :=
  if (a, b) = (x, z_new)  then B'          -- B' from Lemma 2.6 splitting
  else if (a, b) = (z_new, y)  then B''     -- B'' from Lemma 2.6 splitting
  else if non_adjacent_through_z(a, b)       -- C3 for non-adjacent pairs through z
    then chi.g a x_pred ∩ f(x_pred) ∩ g'(x_pred, b)  -- three-way intersection
  else chi.g a b                             -- old pairs unchanged
```

where B', B'' come from Lemma 2.6 splitting applied to `BurgessR3Maximal(f(x), chi.g(x,y), f(y))` with the counterexample formula delta not in `chi.g(x,y)`.

**Data flow for C4 forward (line 908)**:
1. Input: `h_c2' : BurgessR3Maximal(f(x), chi.g(x, x_next), f(x_next))` from `chi.c2'` on adjacent pair (x, x_next)
2. Input: `delta` (the counterexample formula) with `delta not in chi.g(x, x_next)`
3. Apply Lemma 2.6 splitting to `h_c2'` and `delta not in chi.g(x, x_next)`:
   - Produces: `B' D B''` with `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(x_next))`
   - Also: `SetMaximalConsistent D` and `delta.neg in D`
4. Set: `f'(z) = D`, `g'(x, z) = B'`, `g'(z, x_next) = B''`
5. c2' follows: for (x, z), `BurgessR3Maximal(f(x), B', D) = BurgessR3Maximal(f'(x), g'(x,z), f'(z))` holds by step 3. For (z, x_next), `BurgessR3Maximal(D, B'', f(x_next)) = BurgessR3Maximal(f'(z), g'(z, x_next), f'(x_next))` holds by step 3.

**Non-adjacent pairs**: For pairs (w, z_new) where w < x < z_new and w,x were not adjacent, g follows C3: `g'(w, z_new) = chi.g(w, x) cap f(x) cap g'(x, z_new)`. This is automatic from the existing c3 property of the chronicle since the elimination function already maintains c3. The g-function definition only needs to handle the two NEW adjacent pairs explicitly.

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal` to understand the exact proof states
- [ ] For C4 forward (line 908):
  - Extract `h_c2'_xy := chi.c2' x x_next h_adj` giving `BurgessR3Maximal(f(x), chi.g(x, x_next), f(x_next))`
  - Apply Lemma 2.6 splitting (from Phase 5) to get B', D, B''
  - Replace g-function: `g' a b := if (a = x /\ b = z) then B' else if (a = z /\ b = x_next) then B'' else chi.g a b`
  - Prove c2': case split on which adjacent pair; each case resolves by Lemma 2.6 output
- [ ] Close sorry site at line 908
- [ ] For C4 backward (line 946): mirror using `BurgessR3Maximal(f(y_prev), chi.g(y_prev, y), f(y))` and Since-direction splitting
- [ ] Close sorry site at line 946
- [ ] For g_prop forward (line 982): same pattern -- extract `h_c2'` for (x, x_next), apply Lemma 2.6 with the G-formula as delta
- [ ] Close sorry site at line 982
- [ ] For h_prop backward (line 1014): mirror of g_prop
- [ ] Close sorry site at line 1014
- [ ] Run `lake build`

**Timing**: 14 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- replace g-functions in 4 elimination cases (~80 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count drops from 5 to 0 (assuming phases 6, 7 done)
- `lake build` succeeds

---

### Phase 9: ChronicleToCountermodel -- Forward Until/Since Coherence [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc`. Now that g-values are properly constructed at every finite stage, the limit chronicle has well-defined g-values (via omega chain convergence), and C5 + C3 properties can be threaded through the Cantor isomorphism to prove Until/Since coherence in the rational countermodel.

**Tasks**:
- [ ] Inspect sorry sites at lines 615 and 619 with `lean_goal`
- [ ] Trace how C5 (Until witness existence) is available in the limit chronicle: for U(phi, psi) in f(t), there exists y > t with psi in f(y). The limit g(t, y) now provides `BurgessR3Maximal(f(t), g(t,y), f(y))` (from the finite stage that eliminated this counterexample). For intermediate r with t < r < y, C3 gives `g(t,y) subset g(t,r) cap f(r) cap g(r,y)`, so phi in g(t,y) implies phi in f(r), providing the guard condition
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to rational countermodel witnesses: the isomorphism preserves order and MCS membership, so Until/Since witnesses transfer directly
- [ ] Close sorry at line 615 (forward Until coherence)
- [ ] Close sorry at line 619 (forward Since coherence): mirror using C5' and corresponding g-values
- [ ] Run `lake build`

**Timing**: 7 hours

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

**Depends on**: 7, 8, 9

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
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type (returns both B and C)
- [ ] Lemma 2.6 splitting theorem compiles sorry-free
- [ ] `burgessR3Maximal_exists_from_seed` remains sorry-free throughout
- [ ] Open-guard compatibility verified for all new infrastructure
- [ ] Each elimination function's g-function correctly handles: new adjacent pairs (explicit B values), old adjacent pairs (chi.g pass-through), non-adjacent pairs (C3 or chi.g)

## Artifacts & Outputs

- `plans/42_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (extended lemma_2_4, Lemma 2.6 splitting)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 sorry sites closed via g-function construction)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (possible new splitting infrastructure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- All changes are additive (new lemmas, proof completions, return type extensions) -- no destructive modifications to existing sorry-free code
- Git history preserves all prior states; each phase is independently committable
- If Lemma 2.6 splitting proves harder than expected (Phase 5), partial progress on extended lemma_2_4 still enables C5 phases (Phase 6 is independent of Lemma 2.6)
- If density case requires type changes (Phase 7), it is independent and does not block C4/g_prop/h_prop phases
- If ChronicleToCountermodel FUC/FSC is blocked (Phase 9), it is independent and does not affect CounterexampleElimination progress
- The BXCanonical path (task 109) remains as an independent backup completeness route
- If open-guard incompatibility is discovered in Phase 5, escalate to `/revise` with detailed handoff
