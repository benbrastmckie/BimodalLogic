# Implementation Plan: Task #107 -- Burgess Chronicle Construction (v33)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IMPLEMENTING]
- **Effort**: 30 hours (estimated 18 remaining)
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md], [reports/44_team-research.md], [reports/45_team-research.md], [reports/47_team-research.md]
- **Artifacts**: plans/47_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v33 incorporates critical findings from Report 47 (team research, 4 teammates). The central insight is that the current proof strategy for Phases 6-9 diverges from Burgess 1982 in ways that cause structural blockers. Phase 6 (Lemma 2.7) uses a wrong case-split approach instead of Burgess's direct seed consistency argument. Phases 8-9 are blocked because c2' cannot be proved at finite stages for g_prop/h_prop counterexamples (the h_gc hypothesis is directly contradicted by the counterexample condition). The fix is twofold: (1) rewrite Lemma 2.7 using Burgess's actual proof (A5a, A7a, A3a chain), and (2) adopt Option B -- remove c2' from EliminationResult and prove it only at the limit (where the domain is dense, so c2' is vacuously true). This eliminates 6 of the 7 CounterexampleElimination sorry sites in one architectural change.

Current sorry count: **12** across 4 files (RRelation:1, CounterexampleElimination:7, PointInsertion:2 from Lemma 2.7 partial, ChronicleToCountermodel:2). Definition of done: all Chronicle sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42**: Root cause -- g-values never constructed. Integrated v26.
- **Report 43**: Density self-pair impossible, C5 n=0 via g_content. Integrated v27.
- **Report 44**: A4a valid but not needed for splitting. Integrated v29.
- **Report 45**: left_mono_until_G + g_content(A) subset B via maximality. Integrated v30.
- **Report 47** (NEW, this version): Phase 6 uses wrong strategy (case split instead of Burgess's direct seed). Phases 8-9 blocked structurally -- Option B (remove c2' from EliminationResult) resolves. g_prop/h_prop cases are NOT in Burgess. Density-at-limit proof needed. Zorn sorry may be straightforward.

### Prior Plan Reference

Plan v32 had 11 phases. Phases 1-5b-ii completed (DCS definition aligned, splitting_seed_consistent sorry-free, PointInsertion sorry-free). Phases 6-11 remain. Phase 6 was [IN PROGRESS] with wrong approach (case split on {eta} union B consistency). Phase 8 was [IN PROGRESS] with density self-pair blocker. Phase 9 was [BLOCKED] -- g_prop/h_prop c2' unprovable at finite stages. v33 consolidates the remaining work using Burgess-aligned strategies: direct seed for Lemma 2.7, Option B for c2'.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Rewrite Lemma 2.7 using Burgess's direct seed argument (delete current Case 1/Case 2)
- Remove c2' from EliminationResult (Option B)
- Remove g_prop/h_prop counterexample cases from EliminationResult (not in Burgess)
- Prove density at the limit (vacuously true: no adjacent pairs in dense domain)
- Close Zorn sorry (RRelation.lean:772)
- Close C5 g-value construction sorry sites
- Close FUC/FSC coherence sorry sites
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- A4a removal (separate task 115)
- BXCanonical sorry closure (task 109)
- Xu Lemma 2.3/2.4 full formalization
- ROADMAP.md updates
- g_ordered invariant (Option A -- rejected in favor of Option B)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing c2' from EliminationResult causes cascading type errors | M | M | The change is architectural but localized to CounterexampleElimination.lean and ChronicleConstruction.lean. c2' is only used to establish the limit c2'; removing it from finite stages simplifies the invariant threading. |
| Burgess's direct seed argument for Lemma 2.7 is harder than expected | H | M | The proof structure is well-understood from Report 47: A5a -> A7a -> A3a. All axioms are available in the codebase. The current partial code (2 sorries in PointInsertion) can be deleted and restarted. |
| Density-at-limit proof has unexpected subtlety | M | L | The argument is standard: for any adjacent pair (x,y) in chronicle n, the density counterexample is eventually enumerated and resolved. The omega-chain construction already enumerates all counterexamples. |
| FUC/FSC coherence requires deep understanding of Cantor isomorphism | M | M | Phase is independent; can be attempted last. The Cantor iso is already sorry-free. |
| Zorn sorry is NOT straightforward (burgessR3 for Set.univ) | M | M | Report 47 suggests it may be easy (Set.univ is inconsistent, so burgessR3 fails trivially). Verify against exact definition. If harder, investigate semantic argument. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4, 5a, 5b-i, 5b-ii | (already completed) |
| 1 | 6, 7, 8 | -- (no dependencies beyond completed phases) |
| 2 | 9 | 7, 8 |
| 3 | 10 | 6, 9 |
| 4 | 11 | 10 |

Phases within the same wave can execute in parallel. Phases 6, 7, and 8 are all independent of each other and can run in parallel.

---

### Phase 1: Documentation Cleanup -- Fix Stale Half-Open Guard References [COMPLETED]

**Goal**: Fix all stale documentation claiming "half-open guard [t,s)" to correctly state "open guard (t,s)".

**Timing**: 1.5 hours

**Depends on**: none

**Completed**: Phase 1 of plan v23

---

### Phase 2: Add A3a/A3b Axioms with Soundness Proofs [COMPLETED]

**Goal**: Add enrichment_until (A3a/BX13) and enrichment_since (A3b/BX13') as new BX axiom constructors with soundness proofs.

**Timing**: 2 hours

**Depends on**: 1

**Completed**: Phase 2 of plan v23

---

### Phase 3: Close Lemma 2.3 Sorry Sites in RRelation.lean [COMPLETED]

**Goal**: Close Lemma 2.3 (burgessR <=> burgessRSince) using A3a/A3b.

**Timing**: 3 hours

**Depends on**: 2

**Completed**: Phase 3 of plan v23

---

### Phase 4: C4 Nested Case Fix via BX6 [COMPLETED]

**Goal**: Close the 2 C4 nested case sorry sites using BX6 (absorb_until).

**Timing**: 5 hours

**Depends on**: none (phases 1-3 already completed)

**Completed**: Phase 4 of plan v24

---

### Phase 5a: GATE -- Verify Lemma 2.7 Validity Under Strict Semantics [COMPLETED]

**Goal**: Determine whether Lemma 2.7 (Until-formula splitting) holds under strict/open-guard semantics.

**Result**: GATE PASSED. Lemma 2.7 is valid under strict semantics.

**Timing**: 4 hours

**Depends on**: none (phases 1-4 already completed)

**Completed**: Phase 5 of plan v27

---

### Phase 5b-i: Split DCS Definition + Update BurgessR3Maximal [COMPLETED]

**Goal**: Introduce `ClosedUnderDerivation` predicate, refactor `SetDeductivelyClosed`, update `BurgessR3Maximal` maximality clause.

**Timing**: 2-3 hours

**Depends on**: none (phases 1-5a already completed)

**Completed**: Phase 5b-i of plan v32

---

### Phase 5b-ii: Close Inconsistent Case + splitting_seed_consistent [COMPLETED]

**Goal**: Close inconsistent case of g_content_sub_B, h_content_sub_B, and splitting_seed_consistent.

**Timing**: 1-2 hours

**Depends on**: 5b-i

**Completed**: Phase 5b-ii of plan v32

---

### Phase 6: Rewrite Lemma 2.7 Using Burgess's Direct Seed Argument [IN PROGRESS]

**Goal**: Delete the current Case 1/Case 2 approach to Lemma 2.7 and implement Burgess's actual proof from 1982 p. 371. The proof is a single unified seed consistency argument, not a case split on {eta} union B consistency.

**Burgess's proof structure**:
1. From `eta not in B` and maximality of B: obtain `beta_0 in B`, `gamma_0 in C` with `neg U(gamma_0, beta_0 and eta) in A`
2. Construct seed D_0 = {S(alpha, beta and eta) : alpha in A, beta in B} union B union {xi} union {U(gamma, beta) : gamma in C, beta in B}
3. Prove each conjunction in D_0 is consistent using:
   - BX5 (self_accum_until) twice to enrich U-formulas
   - BX7 (linear_until) on the two enriched U-formulas, giving three-way disjunction
   - First two disjuncts eliminated using neg U(gamma_0, beta_0 and eta) in A + BX1a/BX2a
   - Third disjunct survives, giving U(beta and U(gamma,beta) and xi, theta) in A
   - BX13 (enrichment_until) gives U(xi, beta and eta) in A, proving consistency by Lemma 2.2
4. Lindenbaum gives MCS D with xi in D, B subset D
5. B' maximal with r(A, B', D), B'' maximal with r(D, B'', C)
6. eta in B' follows from U(xi, beta and eta) in A for each beta in B plus maximality of B'

**Tasks**:
- [ ] Delete the current Case 1/Case 2 code in PointInsertion.lean (lines ~937-1095)
- [ ] Implement Burgess's seed construction D_0
- [ ] Prove seed consistency using BX5 + BX7 + BX13 chain
- [ ] Prove BX7 three-way disjunction and eliminate first two disjuncts
- [ ] Apply BX13 to get U(xi, beta and eta) in A
- [ ] Construct D via Lindenbaum, then B' and B'' via burgessR3Maximal
- [ ] Prove xi in D and eta in B' from the constructed seed
- [ ] Verify theorem compiles sorry-free
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: none (phases 1-5b-ii already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- delete Case 1/Case 2, implement Burgess's direct seed (~150 lines net)

**Verification**:
- Lemma 2.7 splitting theorem compiles sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 7: Remove c2' from EliminationResult (Option B) [COMPLETED]

**Goal**: Remove c2' from the finite-stage EliminationResult structure and update all callers. This eliminates 6 sorry sites in CounterexampleElimination.lean (lines 830, 868, 908, 946, 982, 1014) in one architectural change. Also remove g_prop/h_prop counterexample cases entirely (they are not in Burgess's construction and exist only because the codebase uses forward_G in FMCS).

**Rationale** (Report 47, 3 of 4 teammates recommend):
- Burgess leaves c2' verification at finite stages to the reader; it is NOT an explicit part of his elimination result
- c2' is vacuously true at the limit (dense domain, no adjacent pairs)
- g_prop/h_prop cases are NOT in Burgess -- they exist only because of forward_G in FMCS
- Removing c2' eliminates the structural blocker that makes Phases 8-9 impossible

**Tasks**:
- [ ] Remove `c2' : val.c2'` field from `EliminationResult` structure
- [ ] Remove g_prop and h_prop cases from `eliminate_potential_counterexample`
- [ ] Remove `PotentialCounterexample.g_prop` and `PotentialCounterexample.h_prop` constructors
- [ ] Update `eliminate_potential_counterexample` to handle only C4/C4'/C5/C5' cases
- [ ] Update `omega_chain` to not thread c2' through iterations
- [ ] Fix all downstream compilation errors in ChronicleConstruction.lean
- [ ] Verify the limit construction still gets the properties it needs (c0, f_agrees, g_agrees, witness)
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: none (phases 1-5b-ii already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- remove c2' field, remove g_prop/h_prop cases (~-200 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- update omega_chain invariant (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- possibly update PotentialCounterexample type

**Verification**:
- CounterexampleElimination.lean sorry count drops from 7 to 1 (density site remains)
- g_prop/h_prop code removed
- `lake build` succeeds

---

### Phase 8: Close Zorn Sorry + Density Sorry [NOT STARTED]

**Goal**: Close the Zorn sorry (RRelation.lean:772) and the density self-pair sorry (CounterexampleElimination.lean:1130).

**Zorn sorry**: The sorry requires proving `neg burgessR3(A, Set.univ, C)`. Since `burgessR3` requires the middle argument to satisfy certain properties, and `Set.univ` contains both phi and phi.neg for all phi (making it inconsistent), `burgessR3(A, Set.univ, C)` should fail because the middle set cannot be a valid DCS (or the R-relation breaks for inconsistent sets). Verify against the exact `burgessR3` definition.

**Density sorry**: After Phase 7 removes c2' from EliminationResult, the density sorry site (line 1130) changes character. It currently requires `BurgessR3Maximal(f(x), g(x,y), f(x))` for a self-pair -- but with c2' removed, the density construction only needs to produce a new point z between x and y with some f(z) and valid f_agrees/g_agrees. The construction via `lemma_2_6_splitting` with the extended return type (g_content A subset D, g_content D subset C) should work once c2' is not required.

**Tasks**:
- [ ] Inspect Zorn sorry with `lean_goal` to understand exact constraint
- [ ] Prove `neg burgessR3(A, Set.univ, C)` from Set.univ inconsistency
- [ ] Close Zorn sorry in RRelation.lean:772
- [ ] Re-inspect density sorry after Phase 7 changes
- [ ] Apply `lemma_2_6_splitting` to produce intermediate D for density insertion
- [ ] Close density sorry site
- [ ] Run `lake build`

**Timing**: 3 hours

**Depends on**: 7 (density sorry changes after c2' removal)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- close Zorn sorry (~20 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- close density sorry (~40 lines)

**Verification**:
- RRelation.lean sorry count: 0
- CounterexampleElimination.lean sorry count: 0
- `lake build` succeeds

---

### Phase 9: Density at the Limit + C5 g-Value Construction [NOT STARTED]

**Goal**: Prove c2' at the limit (vacuously true since the limit domain is dense with no adjacent pairs) and close the C5 g-value construction. With c2' removed from finite stages (Phase 7), c2' must be established at the limit for the final chronicle to satisfy all invariants.

**Density-at-limit argument**: For any pair (x, y) in the limit domain with x < y, they appeared as an adjacent pair in some chronicle n. The density counterexample (x, y) was eventually enumerated at some step m >= n, and resolved by inserting (x+y)/2. After step m, (x, y) is no longer adjacent. In the limit (union of all finite domains), no pair is adjacent, so c2' is vacuously true.

**C5 g-value construction**: With Phase 7 removing c2' from EliminationResult, the C5 construction only needs to produce a valid witness point. The n=0 case uses `lemma_2_4` (extended return type). The n>0 case has three sub-cases, with sub-case 3 using Lemma 2.7 (Phase 6). Since c2' is no longer threaded through finite stages, the C5 construction simplifies significantly.

**Tasks**:
- [ ] Prove `limit_dom_no_adjacent_pairs`: for the limit chronicle, no pair is adjacent
- [ ] Prove c2' at the limit from `limit_dom_no_adjacent_pairs` (vacuously true)
- [ ] Integrate limit c2' into the ChronicleToCountermodel construction
- [ ] Verify C5 elimination works without c2' threading (may already compile after Phase 7)
- [ ] If C5 still has sorry sites, implement n=0 case via extended `lemma_2_4`
- [ ] If C5 n>0 sub-case 3 needed, connect to Lemma 2.7 from Phase 6
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: 7 (c2' removed from EliminationResult), 8 (density sorry closed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- limit density proof (~40 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- integrate limit c2' (~20 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C5 construction if needed (~60 lines)

**Verification**:
- Limit chronicle satisfies c2' (sorry-free)
- ChronicleConstruction.lean sorry count: 0
- `lake build` succeeds

---

### Phase 10: FUC/FSC Coherence and Final Validation [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc` and `cantor_bfmcs_restricted_fsc`, then verify the full sorry-free chronicle path.

**Coherence argument**: With g-values properly constructed and c2' proved at the limit, the chronicle has well-defined g-values everywhere. C5 + C3 properties thread through the Cantor isomorphism to prove Until/Since coherence. For U(phi, psi) in f(t), C5 gives a witness y > t with psi in f(y). The limit g(t, y) provides BurgessR3Maximal(f(t), g(t,y), f(y)). For intermediate r, C3 gives g(t,y) subset g(t,r) inter f(r) inter g(r,y), so phi in g(t,y) implies phi in f(r).

**Tasks**:
- [ ] Inspect sorry sites at FUC/FSC with `lean_goal`
- [ ] Trace how C5 is available in the limit chronicle
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to countermodel witnesses
- [ ] Close FUC sorry site (line 615, forward Until coherence)
- [ ] Close FSC sorry site (line 619, forward Since coherence)
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run grep for sorry in Chronicle/ to confirm zero sorry sites
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Clean up temporary scaffolding and outdated TODOs in Chronicle/ files

**Timing**: 5 hours

**Depends on**: 6, 9 (Lemma 2.7 needed for C5 n>0, limit c2' needed for coherence)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] Lemma 2.7 (Burgess direct seed) compiles sorry-free after Phase 6
- [ ] EliminationResult has no c2' field after Phase 7
- [ ] g_prop/h_prop cases removed from CounterexampleElimination after Phase 7
- [ ] Zorn sorry (RRelation.lean:772) closed after Phase 8
- [ ] Density sorry (CounterexampleElimination.lean:1130) closed after Phase 8
- [ ] Limit chronicle satisfies c2' (vacuously) after Phase 9
- [ ] FUC/FSC sorry sites closed after Phase 10
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 10
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)

## Artifacts & Outputs

- `plans/47_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Lemma 2.7 rewrite)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (c2' removal, g_prop/h_prop removal, density fix)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (omega_chain update, limit density)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (limit c2', FUC/FSC closure)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (Zorn sorry closed)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **Lemma 2.7 rewrite blocked**: The current Case 1/Case 2 code can be preserved in a separate lemma while the Burgess approach is developed alongside. If Burgess's direct seed proof is too complex, fall back to completing Case 1/Case 2 (Report 47 identified specific steps for both cases).
- **Option B (c2' removal) causes unexpected breakage**: The c2' field can be restored with a `sorry` placeholder. The architectural change is designed to be reversible since the limit c2' proof is the only consumer of c2' information, and it uses density (no adjacent pairs) rather than finite-stage c2'.
- **Density-at-limit proof harder than expected**: The omega-chain enumeration is well-understood and already formalized. If the density argument is subtle, break into smaller lemmas (each counterexample eventually resolved, adjacent pairs cannot persist).
- **FUC/FSC coherence blocked**: This phase is independent. Partial progress still reduces sorry count. The Cantor isomorphism is already sorry-free, so the gap is limited to threading C5 witnesses through the isomorphism.
- Git history preserves all prior states; each phase is independently committable.
- The BXCanonical path (task 109) remains as an independent backup completeness route.
