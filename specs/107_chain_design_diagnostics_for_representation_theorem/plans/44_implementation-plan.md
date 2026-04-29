# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v29)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 42 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md], [reports/44_team-research.md]
- **Artifacts**: plans/44_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v29 revises v28 to adopt the user's chosen Option C: add A4a as a new `separation_until` axiom. Report 44 confirmed A4a (`untl(q,p) AND NOT untl(r,p) -> untl(q, q AND NOT r)` in BX convention) is semantically valid under open-guard semantics. Adding it as a BX axiom is sound and enables the direct Burgess Lemma 2.6 consistency proof, eliminating the need for Xu's Lemma 2.4 workaround. Phase 5b (Xu splitting, BLOCKED in v28) is replaced with a streamlined Phase 5b that adds the axiom, proves soundness, and formalizes Lemma 2.6. The Xu splitting and `left_mono_until_G` approaches are dropped entirely. Downstream phases (density, C4/g_prop/h_prop, C5) now use Burgess Lemma 2.6 splitting instead of Xu splitting. Definition of done: all Chronicle/ sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42 (team research, 4 teammates)**: Root cause diagnosis -- g-values never constructed. Only viable path: restructure elimination functions to produce g-values matching Burgess's Lemmas 2.4/2.6. Integrated in plan v26.
- **Report 43 (team research, 4 teammates)**: Three critical findings: (a) density self-pair impossible under irreflexive semantics, (b) C5 n=0 works via g_content but n>0 needs full Lemma 2.10, (c) Lemma 2.7 validity is the gating question for Strategy 1 vs Strategy 2. Integrated in plan v27.
- **Report 44 (team research, 4 teammates)**: A4a is semantically valid but NOT derivable from BX axioms. User chose Option C: add A4a as `separation_until` axiom. Enables direct Burgess Lemma 2.6. Replaces Xu splitting approach (v28). Integrated in this plan (v29).

### Prior Plan Reference

Plan v28 (this file, previous version) had 11 phases, 50 hours. Phases 1-5a completed (documentation, A3a/A3b axioms, Lemma 2.3 closure, C4 nested case via BX6, Lemma 2.7 GATE passed). Phase 5b was BLOCKED on Xu splitting -- the DCS consistency argument required a guard strengthening axiom not derivable from BX. v29 replaces Phase 5b entirely: instead of the Xu workaround, add A4a directly as a sound axiom and use Burgess's original Lemma 2.6 proof. This simplifies the plan by ~8 hours and removes all Xu-related complexity.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 9 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Add `separation_until` (A4a) and `separation_since` (A4b) axiom constructors to the BX system
- Prove soundness of A4a/A4b (~30 lines, using Teammate A's semantic argument from Report 44)
- Formalize Burgess Lemma 2.6: R(A,B,C) + beta not in B -> exists B', D, B'' with R(A,B',D) and R(D,B'',C) and neg beta in D -- using A4a directly
- Extend `lemma_2_4` to return both B (DCS interval set) and C (MCS endpoint)
- Formalize Lemma 2.7 splitting: R(A,B,C) + U(xi,eta) in A + eta not in B -> exists B', D, B'' with xi in D, eta in B'
- Close 2 C5 sorry sites: n=0 via g_content, n>0 via Lemma 2.10 recursive case analysis (using Lemma 2.7 for sub-case 3)
- Close 1 density sorry site via Lemma 2.6 splitting (fresh D, NOT self-pair)
- Close 4 C4/g_prop/h_prop sorry sites via Lemma 2.6 splitting
- Close 2 FUC/FSC sorry sites in ChronicleToCountermodel.lean
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- Xu Lemma 2.4 workaround (explicitly dropped in favor of A4a axiom)
- `left_mono_until_G` axiom approach (dropped)
- BXCanonical sorry closure (task 109)
- BX2 redundant conjunct cleanup (separate task)
- BX4 redundancy investigation (separate task)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- ROADMAP.md updates
- Strategy 2 (remove c2' from finite stages) -- no longer needed since Lemma 2.7 GATE passed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A4a soundness proof harder than expected in Lean formalization | L | L | Semantic argument is straightforward (6 steps, Report 44 Teammate A); only open-guard interval reasoning needed |
| Burgess Lemma 2.6 consistency proof requires careful A4a application | M | M | The proof uses A4a at exactly one point (step 5); rest follows from BX1/BX2+BX13 already in codebase |
| Extended lemma_2_4 return type causes cascading call-site changes | M | L | Current lemma_2_4 is called from CounterexampleElimination.lean only; changes are local |
| C5 n>0 recursive reduction adds significant structural complexity | H | M | Start with n=0 case (straightforward), then tackle n>0; partial progress still closes 2 sorry sites |
| Density restructuring changes f(z) from f(x) copy to fresh MCS, affecting downstream proofs | M | M | Fresh D from Lemma 2.6 splitting satisfies all c1-c5 properties by construction |
| ChronicleToCountermodel FUC/FSC requires threading g through Cantor isomorphism | M | M | This phase is independent; partial progress still reduces sorry count |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4, 5a | (already completed from v24/v27) |
| 1 | 5b | -- (no dependencies beyond completed phases) |
| 2 | 6, 7 | 5b |
| 3 | 8, 9 | 7 |
| 4 | 10 | 8, 9 |
| 5 | 11 | 10 |

Phase 5b is the critical path: add A4a axiom + Lemma 2.6. Phases 6 and 7 can execute in parallel once 5b completes (Lemma 2.7 splitting vs lemma_2_4 extension). Phases 8 and 9 can execute in parallel (density vs C4/g_prop/h_prop).

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

### Phase 5a: GATE -- Verify Lemma 2.7 Validity Under Strict Semantics [COMPLETED]

**Goal**: Determine whether Lemma 2.7 (Until-formula splitting) holds under strict/open-guard semantics.

**Result**: GATE PASSED. Lemma 2.7 is valid under strict semantics. Strategy 1 (full Burgess alignment, maintaining c2' at finite stages) proceeds.

**Timing**: 4 hours

**Depends on**: none (phases 1-4 already completed)

**Completed**: Phase 5 of plan v27. Documented in handoffs/01_phase5-gate-complete.md.

---

### Phase 5b: Add A4a/A4b Axioms and Formalize Lemma 2.6 [PARTIAL]

**Goal**: Add `separation_until` (A4a) and `separation_since` (A4b) as new BX axiom constructors, prove their soundness, and formalize Burgess Lemma 2.6 (splitting via A4a). This replaces the BLOCKED Xu splitting approach from v28.

**A4a in BX convention**: `untl(q,p) AND NOT untl(r,p) -> untl(q, q AND NOT r)`
(Burgess convention: `U(p,q) AND NOT U(p,r) -> U(q AND NOT r, q)` where U(event, guard))

**A4b (Since dual)**: `snce(q,p) AND NOT snce(r,p) -> snce(q, q AND NOT r)`

**Soundness proof outline** (from Report 44, Teammate A):
1. From `untl(q,p)` at t: witness s0 > t with p(s0), guard q on (t,s0)
2. From `NOT untl(r,p)` at t applied to s0: since p(s0), exists u0 in (t,s0) with NOT r(u0)
3. u0 in (t,s0) implies q(u0) from step 1's guard
4. (q AND NOT r)(u0) holds
5. For v in (t,u0): v in (t,s0) implies q(v) from step 1's guard
6. u0 witnesses `untl(q, q AND NOT r)` at t

**Lemma 2.6 formalization** (Burgess 1982): Given `BurgessR3Maximal(A, B, C)` with `beta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `neg beta in D`. The proof constructs a consistent set using A4a at step 5 (the only point where A4a is needed), then extends via Lindenbaum to MCS D, and applies `burgessR3Maximal_exists_from_seed` for both directions.

**Tasks**:
- [x] Add `separation_until` constructor to `BXAxiom` inductive in Axioms.lean
- [x] Add `separation_since` constructor (dual) to Axioms.lean
- [x] Prove soundness of `separation_until` in Soundness.lean (~30 lines, following the 6-step argument)
- [x] Prove soundness of `separation_since` in Soundness.lean (symmetric argument)
- [ ] Formalize Lemma 2.6 consistency argument using A4a:
  - Input: `h_r3m : BurgessR3Maximal A B C`, `h_beta : beta not in B`, `h_mcs_A : SetMaximalConsistent A`, `h_mcs_C : SetMaximalConsistent C`
  - Output: `exists B' D B'', BurgessR3Maximal A B' D /\ BurgessR3Maximal D B'' C /\ SetMaximalConsistent D /\ neg beta in D`
- [ ] Package as `lemma_2_6` theorem in PointInsertion.lean
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: none (phases 1-5a already completed)

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add 2 constructors (~10 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add 2 soundness proofs (~60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Lemma 2.6 (~80 lines)

**Verification**:
- `separation_until` and `separation_since` constructors compile
- Soundness proofs compile sorry-free
- `lemma_2_6` compiles sorry-free
- `lake build` succeeds

---

### Phase 6: Formalize Lemma 2.7 Splitting [NOT STARTED]

**Goal**: Formalize Lemma 2.7 (Until-formula splitting): given `BurgessR3Maximal(A, B, C)` with `U(xi, eta) in A` and `eta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `xi in D` and `eta in B'`. This is needed for C5 n>0 sub-case 3 (Phase 10).

**Difference from Lemma 2.6 (Phase 5b)**: Lemma 2.6 only guarantees `neg beta in D`. Lemma 2.7 additionally guarantees `xi in D` and `eta in B'` (the Until formula's components are placed in specific locations). The construction uses BX5 (self-accumulation) to ensure xi propagates to D, and BX7 (linearity) to steer eta into B'.

**Note**: Lemma 2.7 does NOT depend on A4a (confirmed in Report 44). It uses only BX5 + BX7 + BX13.

**Tasks**:
- [ ] Build on the Lemma 2.7 proof structure verified in Phase 5a
- [ ] Formalize the full splitting theorem:
  - Input: `h_r3m : BurgessR3Maximal A B C`, `h_until : U(xi, eta) in A`, `h_eta : eta not in B`
  - Output: `exists B' D B'', BurgessR3Maximal A B' D /\ BurgessR3Maximal D B'' C /\ SetMaximalConsistent D /\ xi in D /\ eta in B'`
- [ ] Connect to BX5 and BX7 axiom infrastructure
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5b

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Lemma 2.7 splitting (~100 lines)

**Verification**:
- Lemma 2.7 splitting theorem compiles sorry-free
- `lake build` succeeds

---

### Phase 7: Extend lemma_2_4 Return Type [NOT STARTED]

**Goal**: Extend `lemma_2_4` to return both B (the DCS interval set) and C (the MCS endpoint) so that B can be directly assigned as a g-value. Currently `lemma_2_4` returns only C. The B is the `BurgessR3Maximal` DCS interval set that witnesses R(A, B, C).

**Tasks**:
- [ ] Modify `lemma_2_4` return type to include B: `exists B C, BurgessR3Maximal A B C /\ SetMaximalConsistent C /\ beta in C /\ g_content A subset C /\ P(U(gamma,beta)) in C`
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean to destructure the new return type
- [ ] Verify `lake build` succeeds with the extended return type (no sorry regressions)

**Timing**: 4 hours

**Depends on**: 5b

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- extend lemma_2_4 (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update call sites (~20 lines)

**Verification**:
- `lemma_2_4` extended return type compiles sorry-free
- All existing call sites updated and compile
- `lake build` succeeds

---

### Phase 8: Density Fix -- Lemma 2.6 Splitting Instead of Self-Pair [NOT STARTED]

**Goal**: Fix the density sorry site by using Lemma 2.6 (Phase 5b) on the existing `BurgessR3Maximal(f(x), g(x,y), f(y))` to produce an intermediate D (a fresh MCS, distinct from both f(x) and f(y)). The formula to negate is chosen from `g(x,y)` -- any formula whose negation is consistent with `g(x,y)` (exists because `g(x,y)` is a proper DCS, not the full formula set).

**Construction**: The density case inserts z between adjacent (x, y).
```
-- Lemma 2.6 approach:
-- Apply lemma_2_6 to BurgessR3Maximal(f(x), g(x,y), f(y)) with some beta not in g(x,y)
-- (beta exists because g(x,y) is a proper DCS, not the full formula set)
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
- [ ] Identify a formula beta guaranteed not in g(x,y) (any formula not in the DCS; existence follows from g(x,y) being proper)
- [ ] Apply `lemma_2_6` (from Phase 5b) to `BurgessR3Maximal(f(x), g(x,y), f(y))` with beta
- [ ] Replace density f-function: `f'(z) = D` (fresh MCS from splitting, NOT f(x))
- [ ] Replace density g-function: `g'(x,z) = B'`, `g'(z,y) = B''` (from splitting output)
- [ ] Prove c2' for new pairs using Lemma 2.6 output directly
- [ ] Verify c1 (MCS property) for f'(z) = D (holds since D is MCS by Lemma 2.6)
- [ ] Verify c5 (Until/Since witnesses) still holds for f'(z) -- may need additional argument
- [ ] Close density sorry site
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure density case (~100 lines)

**Verification**:
- Density sorry site closed
- `lake build` succeeds

---

### Phase 9: C4/g_prop/h_prop g-Value Construction via Lemma 2.6 Splitting [NOT STARTED]

**Goal**: Close the 4 harder c2' sorry sites (C4 forward, C4 backward, g_prop forward, h_prop backward) by constructing g-values via Lemma 2.6 splitting. These insert a new point z BETWEEN existing adjacent points (x, y) and need g-values for TWO new adjacent pairs: (x, z) and (z, y).

**Data flow**: Same pattern as density (Phase 8) but with a specific counterexample formula beta:
1. Input: `h_c2' : BurgessR3Maximal(f(x), chi.g(x, x_next), f(x_next))` from `chi.c2'`
2. Input: `beta` (the counterexample formula) with `beta not in chi.g(x, x_next)`
3. Apply `lemma_2_6`: produces B', D, B'' with `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(x_next))`
4. Set: `f'(z) = D`, `g'(x, z) = B'`, `g'(z, x_next) = B''`
5. c2' follows directly from splitting output

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal` to understand exact proof states
- [ ] For C4 forward: extract `h_c2'_xy := chi.c2' x x_next h_adj`, apply `lemma_2_6` with the C4 counterexample formula, construct g-function with B' and B''
- [ ] Close C4 forward sorry site
- [ ] For C4 backward: mirror using Since-direction splitting
- [ ] Close C4 backward sorry site
- [ ] For g_prop forward: same pattern with G-formula as beta
- [ ] Close g_prop forward sorry site
- [ ] For h_prop backward: mirror of g_prop
- [ ] Close h_prop backward sorry site
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- replace g-functions in 4 elimination cases (~80 lines each)

**Verification**:
- CounterexampleElimination.lean sorry count drops by 4
- `lake build` succeeds

---

### Phase 10: C5 g-Value Construction -- Full Lemma 2.10 Case Analysis [NOT STARTED]

**Goal**: Close the 2 C5 c2' sorry sites by implementing Burgess's full Lemma 2.10 case analysis. The n=0 case (x is domain max) uses `burgessR3Maximal_from_g_content_sub` (already available). The n>0 case (x is not domain max) requires recursive reduction plus Lemma 2.7 splitting (Phase 6).

**C5 n=0 case** (x is max): `lemma_2_4` produces (B, C) with `g_content(f(x)) <= C`. Chain `g_content(f(x)) <= C` into `burgessR3Maximal_from_g_content_sub` to get B for g'(x, y_new). Set f'(y_new) = C, g'(x, y_new) = B. c2' holds by construction.

**C5 n>0 case** (x is not max, let x' = successor of x): Three sub-cases:
1. U(xi,eta) and eta propagate to x': reduce to n-1 (recurse on x')
2. xi in f(x') and eta in g(x,x'): x' is already a witness (impossible for counterexample)
3. Otherwise: apply Lemma 2.7 splitting (Phase 6) to R(f(x), g(x,x'), f(x')) with U(xi,eta) to insert z between x and x'. g-values B', B'' come from splitting output. c2' follows automatically.

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

**Timing**: 8 hours

**Depends on**: 8, 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure C5 cases with full case analysis (~120 lines each direction)

**Verification**:
- Sorry count in CounterexampleElimination.lean drops by 2 (C5 sites closed)
- `lake build` succeeds

---

### Phase 11: ChronicleToCountermodel -- Forward Until/Since Coherence and Final Validation [NOT STARTED]

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

**Timing**: 5 hours

**Depends on**: 10

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
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 11
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type (returns both B and C)
- [ ] `separation_until` and `separation_since` axiom constructors compile and pass soundness
- [ ] Lemma 2.6 splitting theorem (`lemma_2_6`) compiles sorry-free -- uses A4a at exactly one point
- [ ] Lemma 2.7 splitting theorem compiles sorry-free
- [ ] `burgessR3Maximal_exists_from_seed` remains sorry-free throughout
- [ ] Open-guard compatibility verified for all new infrastructure
- [ ] Density case uses fresh MCS D (NOT f(x) copy) -- no self-pair
- [ ] Each elimination function's g-function correctly handles: new adjacent pairs (explicit B/B' values from splitting), old adjacent pairs (chi.g pass-through)

## Artifacts & Outputs

- `plans/44_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (separation_until, separation_since constructors)
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` (A4a/A4b soundness proofs)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (extended lemma_2_4, Lemma 2.6, Lemma 2.7 splitting)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 c2' sorries + 1 density sorry closed via g-function construction)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 FUC/FSC sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **A4a soundness harder than expected**: Unlikely -- the semantic argument is 6 lines (Report 44). Fallback: add as `sorry` temporarily, close later.
- **Lemma 2.6 formalization blocked**: The proof uses A4a at exactly one step. If the Lean encoding is tricky, isolate that step as a separate lemma and iterate.
- **Lemma 2.7 formalization blocked**: Use only Lemma 2.6 for C5 n>0 sub-case 3 (losing the xi/eta placement guarantees, but still achieving the split). BX6 absorption (Phase 4) may handle sub-cases that would otherwise need Lemma 2.7.
- All changes are additive (new axioms, new lemmas, proof completions, return type extensions) -- no destructive modifications to existing sorry-free code.
- Git history preserves all prior states; each phase is independently committable.
- If C5 n>0 case analysis is harder than expected (Phase 10), the n=0 case still closes sorry sites for the domain-max configuration.
- If density restructuring (Phase 8) has unexpected downstream effects, it is independent of C4/g_prop/h_prop (Phase 9).
- The BXCanonical path (task 109) remains as an independent backup completeness route.
