# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v27)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 58 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md]
- **Artifacts**: plans/43_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v27 revises v26 to incorporate Report 43 findings: (1) the density self-pair `BurgessR3Maximal(A,B,A)` is provably impossible under irreflexive semantics, so density must use Lemma 2.6 splitting instead of f(z)=f(x) copying; (2) C5 elimination must implement Burgess's full Lemma 2.10 case analysis -- n=0 works via `burgessR3Maximal_from_g_content_sub` (already available), but n>0 requires recursive reduction plus Lemma 2.7/2.8 splitting; (3) Lemma 2.7 validity under strict semantics must be verified as a gate before committing to Strategy 1 (full Burgess alignment). The plan restructures phases 5-10 from v26 into a gated approach: verify Lemma 2.7 first, then formalize splitting lemmas, then close sorry sites case by case. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42 (team research, 4 teammates)**: Root cause diagnosis -- g-values never constructed. Only viable path: restructure elimination functions to produce g-values matching Burgess's Lemmas 2.4/2.6. Integrated in plan v26.
- **Report 43 (team research, 4 teammates)**: Three critical findings: (a) density self-pair impossible under irreflexive semantics, (b) C5 n=0 works via g_content but n>0 needs full Lemma 2.10, (c) Lemma 2.7 validity is the gating question for Strategy 1 vs Strategy 2. Integrated in this plan (v27).

### Prior Plan Reference

Plan v26 (artifact 42) had 10 phases, 52 hours. Phases 1-4 completed (documentation, A3a/A3b axioms, Lemma 2.3 closure, C4 nested case via BX6). Phase 5 was PARTIAL (`burgessR3Maximal_from_g_content_sub` added). Phases 6-10 assumed g_content ordering would work universally and that density could use self-pair -- both assumptions falsified by Report 43.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 9 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Verify Lemma 2.7 validity under strict/open-guard semantics (GATE)
- Extend `lemma_2_4` to return both B (DCS interval set) and C (MCS endpoint)
- Formalize Lemma 2.6 splitting: R(A,B,C) + delta not in B produces B', D, B'' with R(A,B',D), R(D,B'',C)
- Formalize Lemma 2.7 splitting: R(A,B,C) + U(xi,eta) in A + eta not in B produces B', D, B'' with xi in D, eta in B'
- Close 2 C5 sorry sites: n=0 via g_content, n>0 via Lemma 2.10 recursive case analysis
- Close 1 density sorry site via Lemma 2.6 splitting (NOT self-pair)
- Close 4 C4/g_prop/h_prop sorry sites via Lemma 2.6 splitting
- Close 2 FUC/FSC sorry sites in ChronicleToCountermodel.lean
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- BXCanonical sorry closure (task 109)
- BX2 redundant conjunct cleanup (separate task)
- BX4 redundancy investigation (separate task)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- ROADMAP.md updates
- Strategy 2 (remove c2' from finite stages) -- only pursued if Lemma 2.7 gate fails

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.7 is invalid under strict/open-guard semantics | H | M | Phase 5 is a GATE; if it fails, pivot to Strategy 2 (remove c2' from EliminationResult, construct g at limit only) via /revise |
| Lemma 2.8 is invalid under strict semantics (flagged by Teammate C) | M | M | BX6 absorption argument (Phase 4, already proved) may substitute for Lemma 2.8's role in sub-case 3; alternatively use only Lemma 2.7 |
| Extended lemma_2_4 return type causes cascading call-site changes | M | L | Current lemma_2_4 is called from CounterexampleElimination.lean only; changes are local |
| C5 n>0 recursive reduction adds significant structural complexity | H | M | Start with n=0 case (straightforward), then tackle n>0; partial progress still closes 2 sorry sites |
| Density restructuring changes f(z) from f(x) copy to fresh MCS, affecting downstream proofs | M | M | Fresh D from splitting satisfies all c1-c5 properties by construction; downstream proofs should be simpler |
| ChronicleToCountermodel FUC/FSC requires threading g through Cantor isomorphism | M | M | This phase is independent; partial progress still reduces sorry count |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4 | (already completed from v24) |
| 1 | 5 | -- (GATE) |
| 2 | 6, 7 | 5 |
| 3 | 8, 9 | 6, 7 |
| 4 | 10, 11 | 8 |
| 5 | 12 | 9, 10, 11 |

Phases 6 and 7 can execute in parallel (Lemma 2.6 vs Lemma 2.7). Phases 10 and 11 can execute in parallel (density vs C4/g_prop/h_prop). Phase 9 depends only on Phase 8 (C5 n=0 needs extended lemma_2_4 but not the splitting lemmas).

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

### Phase 5: GATE -- Verify Lemma 2.7 Validity Under Strict Semantics [COMPLETED]

**Goal**: Determine whether Lemma 2.7 (Until-formula splitting) holds under strict/open-guard semantics. This is a GATE: if Lemma 2.7 is valid, the plan proceeds with Strategy 1 (full Burgess alignment, maintaining c2' at finite stages). If invalid, the entire plan must be revised to Strategy 2 (remove c2' from finite stages, construct g at limit only).

**Lemma 2.7 statement**: Given `BurgessR3Maximal(A, B, C)` with `U(xi, eta) in A` and `eta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` and `xi in D` and `eta in B'`.

**Key axiom dependencies**: Lemma 2.7 uses A5a (BX5, self-accumulation: `U(p,q) -> U(p, p & U(p,q))`) and A7a (BX7, linearity: `U(p,q) -> U(p & r, q) | U(p & ~r, q) | G(~r) | F(r & ~U(p,q))`). Both are in the axiom system.

**Tasks**:
- [ ] Locate any existing `lemma_2_7` or related definitions in the codebase (PointInsertion.lean, RRelation.lean)
- [ ] If Lemma 2.7 exists with sorry, inspect the sorry site with `lean_goal` to understand what remains
- [ ] If Lemma 2.7 does not exist, formalize the statement and attempt proof using BX5 + BX7
- [ ] Test whether the proof goes through under open-guard semantics (the `guard_open` variant)
- [ ] If Lemma 2.7 is valid: proceed to Phase 6. Document the proof structure
- [ ] If Lemma 2.7 is INVALID: stop and run `/revise 107` with findings to pivot to Strategy 2
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: none (phases 1-4 already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- verify or formalize Lemma 2.7

**Verification**:
- Lemma 2.7 compiles sorry-free, OR
- Gate failure documented with specific error for Strategy 2 pivot

---

### Phase 6: Formalize Lemma 2.6 Splitting [BLOCKED]

**Goal**: Formalize Lemma 2.6 (counterexample splitting): given `BurgessR3Maximal(A, B, C)` and `delta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `delta.neg in D`. This is the workhorse lemma used by C4/g_prop/h_prop (Phase 11) and density (Phase 10).

**Construction outline**:
1. Use `lemma_2_6` (counterexample insertion) to get intermediate MCS D with `delta.neg in D`
2. Use `burgessR3Maximal_extension_exists` (Zorn) to extend seed sets to maximal B' (between A and D) and B'' (between D and C)
3. The seed for B' comes from `{phi | F(phi) in A} union {phi | P(phi) in D}` intersected appropriately
4. The seed for B'' comes from `{phi | F(phi) in D} union {phi | P(phi) in C}` intersected appropriately

**Tasks**:
- [ ] Check whether `lemma_2_6` already exists in PointInsertion.lean and what it returns
- [ ] Formalize the splitting theorem:
  - Input: `h_r3m : BurgessR3Maximal A B C`, `h_delta : delta not in B`, `h_mcs_A : SetMaximalConsistent A`, `h_mcs_C : SetMaximalConsistent C`
  - Output: `exists B' D B'', BurgessR3Maximal A B' D /\ BurgessR3Maximal D B'' C /\ SetMaximalConsistent D /\ delta.neg in D`
- [ ] Verify open-guard compatibility with `lean_goal` inspection
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Lemma 2.6 splitting (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- possibly new splitting seed infrastructure (~40 lines)

**Verification**:
- Lemma 2.6 splitting theorem compiles sorry-free
- `lake build` succeeds

---

### Phase 7: Formalize Lemma 2.7 Splitting [NOT STARTED]

**Goal**: Formalize Lemma 2.7 (Until-formula splitting): given `BurgessR3Maximal(A, B, C)` with `U(xi, eta) in A` and `eta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `xi in D` and `eta in B'`. This is needed for C5 n>0 sub-case 3 (Phase 9).

**Difference from Lemma 2.6**: Lemma 2.6 only guarantees `delta.neg in D`. Lemma 2.7 additionally guarantees `xi in D` and `eta in B'` (the Until formula's components are placed in specific locations). The construction uses BX5 (self-accumulation) to ensure xi propagates to D, and BX7 (linearity) to steer eta into B'.

**Tasks**:
- [ ] Build on the Lemma 2.7 proof structure verified in Phase 5
- [ ] Formalize the full splitting theorem:
  - Input: `h_r3m : BurgessR3Maximal A B C`, `h_until : U(xi, eta) in A`, `h_eta : eta not in B`
  - Output: `exists B' D B'', BurgessR3Maximal A B' D /\ BurgessR3Maximal D B'' C /\ SetMaximalConsistent D /\ xi in D /\ eta in B'`
- [ ] Connect to BX5 and BX7 axiom infrastructure
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Lemma 2.7 splitting (~100 lines)

**Verification**:
- Lemma 2.7 splitting theorem compiles sorry-free
- `lake build` succeeds

---

### Phase 8: Extend lemma_2_4 Return Type [NOT STARTED]

**Goal**: Extend `lemma_2_4` to return both B (the DCS interval set) and C (the MCS endpoint) so that B can be directly assigned as a g-value. Currently `lemma_2_4` returns only C. The B is the `BurgessR3Maximal` DCS interval set that witnesses R(A, B, C).

**Tasks**:
- [ ] Modify `lemma_2_4` return type to include B: `exists B C, BurgessR3Maximal A B C /\ SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\ P(U(gamma,beta)) in C`
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean to destructure the new return type
- [ ] Verify `lake build` succeeds with the extended return type (no sorry regressions)

**Timing**: 4 hours

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- extend lemma_2_4 (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update call sites (~20 lines)

**Verification**:
- `lemma_2_4` extended return type compiles sorry-free
- All existing call sites updated and compile
- `lake build` succeeds

---

### Phase 9: C5 g-Value Construction -- Full Lemma 2.10 Case Analysis [NOT STARTED]

**Goal**: Close the 2 C5 c2' sorry sites by implementing Burgess's full Lemma 2.10 case analysis. The n=0 case (x is domain max) uses `burgessR3Maximal_from_g_content_sub` (already available). The n>0 case (x is not domain max) requires recursive reduction plus Lemma 2.7 splitting.

**C5 n=0 case** (x is max): `lemma_2_4` produces (B, C) with `g_content(f(x)) <= C`. Chain `g_content(f(x)) <= C` into `burgessR3Maximal_from_g_content_sub` to get B for g'(x, y_new). Set f'(y_new) = C, g'(x, y_new) = B. c2' holds by construction.

**C5 n>0 case** (x is not max, let x' = successor of x): Three sub-cases:
1. U(xi,eta) and eta propagate to x': reduce to n-1 (recurse on x')
2. xi in f(x') and eta in g(x,x'): x' is already a witness (impossible for counterexample)
3. Otherwise: apply Lemma 2.7 splitting to R(f(x), g(x,x'), f(x')) with U(xi,eta) to insert z between x and x'. g-values B', B'' come from splitting output. c2' follows automatically.

**Tasks**:
- [ ] Inspect sorry site at C5 forward with `lean_goal` to capture exact proof state
- [ ] Implement n=0 case: extract B from extended `lemma_2_4`, assign g'(x_max, y_new) = B
- [ ] Prove c2' for n=0: `BurgessR3Maximal(f(x_max), B, C)` holds by `lemma_2_4` output
- [ ] Implement n>0 case analysis:
  - Sub-case 1 (propagation check): verify U(xi,eta) + eta propagate; reduce to n-1
  - Sub-case 2 (witness already exists): derive contradiction with counterexample assumption
  - Sub-case 3 (splitting): apply Lemma 2.7 to R(f(x), g(x,x'), f(x')) to get B', D, B''
- [ ] For n>0 sub-case 3, construct g-function:
  ```
  g' a b :=
    if (a, b) = (x, z_new) then B'
    else if (a, b) = (z_new, x') then B''
    else chi.g a b
  ```
- [ ] Prove c2' for n>0 sub-case 3: both new adjacent pairs have BurgessR3Maximal by Lemma 2.7 output
- [ ] Close C5 forward sorry site
- [ ] Mirror for C5 backward (Since direction) using Since variants of Lemma 2.7
- [ ] Close C5 backward sorry site
- [ ] Run `lake build`

**Timing**: 10 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure C5 cases with full case analysis (~120 lines each direction)

**Verification**:
- Sorry count in CounterexampleElimination.lean drops by 2 (C5 sites closed)
- `lake build` succeeds

---

### Phase 10: Density Fix -- Lemma 2.6 Splitting Instead of Self-Pair [NOT STARTED]

**Goal**: Fix the density sorry site by restructuring density elimination to NOT set f(z) = f(x). Report 43 proved that `BurgessR3Maximal(A, B, A)` is impossible under irreflexive semantics when A contains `G(phi)` with `phi not in A`. Instead, use Lemma 2.6 splitting on the existing `R(f(x), g(x,y), f(y))` to produce an intermediate D (a fresh MCS, distinct from both f(x) and f(y)).

**Construction**: The density case inserts z between adjacent (x, y). Currently:
```
-- WRONG (v26): f(z) = f(x), creating self-pair
f' w := if w = z then f(x) else chi.f w
g' a b := if (a = x /\ b = z) \/ (a = z /\ b = y) then chi.g x y else chi.g a b
```

Corrected approach:
```
-- CORRECT (v27): f(z) = D from Lemma 2.6 splitting, a fresh MCS
-- Apply Lemma 2.6 to BurgessR3Maximal(f(x), g(x,y), f(y)) with some delta not in g(x,y)
-- (delta exists because g(x,y) is a proper DCS, not the full formula set)
-- Produces B', D, B'' with BurgessR3Maximal(f(x), B', D) and BurgessR3Maximal(D, B'', f(y))
f' w := if w = z then D else chi.f w
g' a b :=
  if (a, b) = (x, z) then B'
  else if (a, b) = (z, y) then B''
  else chi.g a b
```

c2' for new pairs: `BurgessR3Maximal(f(x), B', D)` = `BurgessR3Maximal(f'(x), g'(x,z), f'(z))` holds by Lemma 2.6 output. `BurgessR3Maximal(D, B'', f(y))` = `BurgessR3Maximal(f'(z), g'(z,y), f'(y))` holds by Lemma 2.6 output.

**Tasks**:
- [ ] Inspect density sorry site with `lean_goal` to understand exact constraint
- [ ] Identify a formula delta guaranteed not in g(x,y) (any formula not in the DCS; existence follows from g(x,y) being proper)
- [ ] Apply Lemma 2.6 splitting (from Phase 6) to `BurgessR3Maximal(f(x), g(x,y), f(y))` with delta
- [ ] Replace density f-function: `f'(z) = D` (fresh MCS from splitting, NOT f(x))
- [ ] Replace density g-function: `g'(x,z) = B'`, `g'(z,y) = B''` (from splitting output)
- [ ] Prove c2' for new pairs using Lemma 2.6 output directly
- [ ] Verify c1 (MCS property) for f'(z) = D (holds since D is MCS by Lemma 2.6)
- [ ] Verify c5 (Until/Since witnesses) still holds for f'(z) -- may need additional argument
- [ ] Close density sorry site
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure density case (~100 lines)

**Verification**:
- Density sorry site closed
- `lake build` succeeds

---

### Phase 11: C4/g_prop/h_prop g-Value Construction via Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Close the 4 harder c2' sorry sites (C4 forward, C4 backward, g_prop forward, h_prop backward) by constructing g-values via Lemma 2.6 splitting. These insert a new point z BETWEEN existing adjacent points (x, y) and need g-values for TWO new adjacent pairs: (x, z) and (z, y).

**Data flow**: Same pattern as density (Phase 10) but with a specific counterexample formula delta:
1. Input: `h_c2' : BurgessR3Maximal(f(x), chi.g(x, x_next), f(x_next))` from `chi.c2'`
2. Input: `delta` (the counterexample formula) with `delta not in chi.g(x, x_next)`
3. Apply Lemma 2.6 splitting: produces B', D, B'' with `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(x_next))`
4. Set: `f'(z) = D`, `g'(x, z) = B'`, `g'(z, x_next) = B''`
5. c2' follows directly from splitting output

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal` to understand exact proof states
- [ ] For C4 forward: extract `h_c2'_xy := chi.c2' x x_next h_adj`, apply Lemma 2.6 splitting with the C4 counterexample formula, construct g-function with B' and B''
- [ ] Close C4 forward sorry site
- [ ] For C4 backward: mirror using Since-direction splitting
- [ ] Close C4 backward sorry site
- [ ] For g_prop forward: same pattern with G-formula as delta
- [ ] Close g_prop forward sorry site
- [ ] For h_prop backward: mirror of g_prop
- [ ] Close h_prop backward sorry site
- [ ] Run `lake build`

**Timing**: 10 hours

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- replace g-functions in 4 elimination cases (~80 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count drops by 4
- `lake build` succeeds

---

### Phase 12: ChronicleToCountermodel -- Forward Until/Since Coherence and Final Validation [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean for `cantor_bfmcs_restricted_fuc`, then verify the full sorry-free chronicle path, run axiom audits, and clean up.

**Coherence argument**: Now that g-values are properly constructed at every finite stage, the limit chronicle has well-defined g-values (via omega chain convergence). C5 + C3 properties thread through the Cantor isomorphism to prove Until/Since coherence in the rational countermodel. For U(phi, psi) in f(t), there exists y > t with psi in f(y). The limit g(t, y) provides `BurgessR3Maximal(f(t), g(t,y), f(y))`. For intermediate r with t < r < y, C3 gives `g(t,y) subset g(t,r) cap f(r) cap g(r,y)`, so phi in g(t,y) implies phi in f(r), providing the guard condition.

**Tasks**:
- [ ] Inspect sorry sites at FUC/FSC with `lean_goal`
- [ ] Trace how C5 (Until witness existence) is available in the limit chronicle
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to rational countermodel witnesses
- [ ] Close FUC sorry site (forward Until coherence)
- [ ] Close FSC sorry site (forward Since coherence)
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` to confirm zero sorry sites (excluding comments)
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Update Completeness.lean documentation to reflect sorry-free chronicle path
- [ ] Clean up temporary scaffolding, commented-out code, or outdated TODOs in Chronicle/ files
- [ ] Update sorry counts in file-level documentation headers

**Timing**: 9 hours

**Depends on**: 9, 10, 11

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- possibly limit g immutability helper
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty (or only comments/docstrings)
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] Phase 5 GATE: Lemma 2.7 validity confirmed or Strategy 2 pivot initiated
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 12
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type (returns both B and C)
- [ ] Lemma 2.6 splitting theorem compiles sorry-free
- [ ] Lemma 2.7 splitting theorem compiles sorry-free
- [ ] `burgessR3Maximal_exists_from_seed` remains sorry-free throughout
- [ ] Open-guard compatibility verified for all new infrastructure
- [ ] Density case uses fresh MCS D (NOT f(x) copy) -- no self-pair
- [ ] Each elimination function's g-function correctly handles: new adjacent pairs (explicit B/B' values from splitting), old adjacent pairs (chi.g pass-through)

## Artifacts & Outputs

- `plans/43_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (extended lemma_2_4, Lemma 2.6 splitting, Lemma 2.7 splitting)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 c2' sorries + 1 density sorry closed via g-function construction)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 FUC/FSC sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (possible new splitting infrastructure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Phase 5 GATE failure** (Lemma 2.7 invalid): Run `/revise 107` to pivot to Strategy 2 -- remove c2' from `EliminationResult`, construct g at limit only. This is the primary contingency path.
- **Lemma 2.8 invalid but 2.7 valid**: Use only Lemma 2.7 for C5 n>0 sub-case 3. The BX6 absorption argument (Phase 4) may handle sub-cases that would otherwise need Lemma 2.8.
- All changes are additive (new lemmas, proof completions, return type extensions) -- no destructive modifications to existing sorry-free code.
- Git history preserves all prior states; each phase is independently committable.
- If C5 n>0 case analysis is harder than expected (Phase 9), the n=0 case still closes sorry sites for the domain-max configuration.
- If density restructuring (Phase 10) has unexpected downstream effects, it is independent of C4/g_prop/h_prop (Phase 11).
- The BXCanonical path (task 109) remains as an independent backup completeness route.
