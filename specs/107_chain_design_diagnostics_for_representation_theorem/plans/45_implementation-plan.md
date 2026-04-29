# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v30)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 36 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md], [reports/44_team-research.md], [reports/45_team-research.md]
- **Artifacts**: plans/45_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v30 replaces the PARTIAL Phase 5b (A4a-based splitting_seed_consistent, blocked) with a simpler approach based on Report 45's breakthrough: add `left_mono_until_G` axiom, prove `g_content(A) subset B` via BurgessR3Maximal's maximality, and close `splitting_seed_consistent` trivially since the seed becomes a subset of `{beta.neg} union B`. This eliminates the need for A4a in the splitting proof entirely. The corrected sorry count is 10 (not 12-13 as previously estimated). Phases 1-5a are completed from prior plan versions. Definition of done: all 10 Chronicle sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds.

### Research Integration

- **Report 42 (team research)**: Root cause diagnosis -- g-values never constructed. Integrated in plan v26.
- **Report 43 (team research)**: Density self-pair impossible, C5 n=0 via g_content, Lemma 2.7 gating question. Integrated in plan v27.
- **Report 44 (team research)**: A4a is valid but not needed for splitting. Integrated in plan v29.
- **Report 45 (team research)**: Breakthrough -- left_mono_until_G + g_content(A) subset B via maximality makes splitting_seed_consistent trivial. 3-step solution replaces blocked Phase 5b. Corrected sorry count to 10. Integrated in this plan (v30).

### Prior Plan Reference

Plan v29 had 11 phases, 42 hours. Phases 1-5a completed (documentation, A3a/A3b, Lemma 2.3, C4 nested case, Lemma 2.7 GATE). Phase 5b was PARTIAL: `lemma_2_6_splitting` body type-checks with 1 sorry at `splitting_seed_consistent`. The A4a-based seed consistency proof was blocked. v30 replaces Phase 5b with the left_mono_until_G + g_content(A) subset B approach (Report 45). Phases 6-11 structure is preserved (they are independent of axiom choice). Effort reduced by 6 hours due to simpler Phase 5b resolution.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 10 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Add `left_mono_until_G` and `left_mono_since_H` axiom constructors to the BX system
- Prove soundness of both new axioms (3 lines each under open-guard semantics)
- Prove `g_content(A) subset B` when `BurgessR3Maximal(A, B, C)` via maximality contradiction
- Prove dual `h_content(C) subset B`
- Close `splitting_seed_consistent` (PointInsertion.lean line 306) via subset argument
- Formalize Lemma 2.7 splitting (BX5 + BX7 + BX13, independent of axiom choice)
- Extend `lemma_2_4` to return both B and C
- Close 7 c2' sorry sites in CounterexampleElimination.lean (6 invariant + 1 density)
- Close 2 FUC/FSC sorry sites in ChronicleToCountermodel.lean
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- A4a removal (already in codebase, sound, can be retained)
- Xu Lemma 2.3/2.4 full formalization (not needed for splitting)
- BXCanonical sorry closure (task 109)
- BX2 redundant conjunct cleanup (separate task)
- Task 115 cleanup (subsumed by this plan)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- ROADMAP.md updates

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| g_content subset B maximality argument harder to formalize than sketch suggests | M | M | dc_delta_B_controlled and burgessR3 infrastructure already exist; the proof uses only established tools |
| left_mono_until_G soundness requires careful open-guard interval reasoning | L | L | Semantic argument is 3 lines; open guard (t,s) is strictly future of t, covered by G |
| Density self-pair sorry (line 1130) has a structural subtlety not captured by Lemma 2.6 | M | M | Inspect with lean_goal first; may need special-case argument for burgessR3(f(x), g(x,y), f(x)) when f(z)=f(x) |
| C5 n>0 recursive case analysis adds significant complexity | H | M | Start with n=0 (straightforward); n>0 sub-case 3 uses Lemma 2.7 which is independent |
| FUC/FSC coherence requires threading g through Cantor isomorphism | M | M | Phase is independent; partial progress still reduces sorry count |
| dc_delta_B_controlled may not decompose exactly as the proof sketch requires | M | L | Inspect existing lemma signature; the decomposition into cases (a) psi in B vs (b) beta AND phi implies psi is standard for deductive closures |

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

Phases within the same wave can execute in parallel. Phase 5b is the critical path entry point. Phases 6 and 7 can run in parallel once 5b completes.

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

**Result**: GATE PASSED. Lemma 2.7 is valid under strict semantics.

**Timing**: 4 hours

**Depends on**: none (phases 1-4 already completed)

**Completed**: Phase 5 of plan v27

---

### Phase 5b: left_mono_until_G + g_content subset B + splitting_seed_consistent [NOT STARTED]

**Goal**: Add `left_mono_until_G` and `left_mono_since_H` axioms, prove `g_content(A) subset B` when `BurgessR3Maximal(A, B, C)` via maximality, and close the `splitting_seed_consistent` sorry (PointInsertion.lean line 306). This replaces the A4a-based approach from v29.

**Approach** (from Report 45):

Step 1 -- Add axioms:
- `left_mono_until_G`: `G(phi -> chi) -> untl(phi, psi) -> untl(chi, psi)`
- `left_mono_since_H`: `H(phi -> chi) -> snce(phi, psi) -> snce(chi, psi)`
- Soundness: Under open-guard semantics, `untl(phi, psi)` at t means exists s>t with psi(s) and phi on (t,s). G(phi->chi) gives (phi->chi) at all u>t, covering (t,s). So chi holds on (t,s), giving untl(chi, psi). 3-line proof.

Step 2 -- Prove `g_content(A) subset B`:
- Suppose phi in g_content(A) but phi not in B.
- DC({phi} union B) is a proper DCS extension of B.
- Show burgessR3(A, DC({phi} union B), C) holds:
  - For psi in DC({phi} union B), gamma in C: by `dc_delta_B_controlled`, either psi in B (use existing burgessR3) or exists beta in B with theorem (beta AND phi) -> psi, then G(phi) in A and TG give G(beta -> psi) in A, then `left_mono_until_G` gives untl(psi, gamma) in A from untl(beta, gamma) in A.
  - Since direction: from `burgessR_implies_burgessRSince` (sorry-free).
- Contradicts BurgessR3Maximal's maximality. So phi in B.
- Dual: `h_content(C) subset B` via mirror argument with `left_mono_since_H`.

Step 3 -- Close splitting_seed_consistent:
- With g_content(A) subset B and h_content(C) subset B:
  `{beta.neg} union g_content(A) union h_content(C) subset {beta.neg} union B`
- beta not in B and B is DCS implies `{beta.neg} union B` consistent by `dcs_neg_union_consistent`.
- Subset of consistent set is consistent. Done in ~5 lines.

**Tasks**:
- [ ] Add `left_mono_until_G` constructor to `BXAxiom` in Axioms.lean (~8 lines)
- [ ] Add `left_mono_since_H` constructor (dual) to Axioms.lean (~8 lines)
- [ ] Prove soundness of `left_mono_until_G` in Soundness.lean (~15 lines)
- [ ] Prove soundness of `left_mono_since_H` in Soundness.lean (~15 lines)
- [ ] Prove `g_content_sub_B_of_BurgessR3Maximal` in PointInsertion.lean or RRelation.lean (~40 lines)
- [ ] Prove `h_content_sub_B_of_BurgessR3Maximal` (dual) (~40 lines)
- [ ] Close `splitting_seed_consistent` sorry at line 306 (~10 lines)
- [ ] Verify `lemma_2_6_splitting` is now sorry-free
- [ ] Run `lake build`

**Timing**: 4 hours

**Depends on**: none (phases 1-5a already completed)

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add 2 constructors (~16 lines)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add 2 soundness proofs (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- g_content subset B lemmas + close sorry (~90 lines)

**Verification**:
- `left_mono_until_G` and `left_mono_since_H` constructors compile
- Soundness proofs compile sorry-free
- `splitting_seed_consistent` sorry closed
- `lemma_2_6_splitting` sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Formalize Lemma 2.7 Splitting [NOT STARTED]

**Goal**: Formalize Lemma 2.7 (Until-formula splitting): given `BurgessR3Maximal(A, B, C)` with `U(xi, eta) in A` and `eta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `xi in D` and `eta in B'`. Needed for C5 n>0 sub-case 3 (Phase 10).

**Note**: Lemma 2.7 does NOT depend on A4a or left_mono_until_G. It uses only BX5 + BX7 + BX13.

**Tasks**:
- [ ] Build on the Lemma 2.7 proof structure verified in Phase 5a
- [ ] Formalize the full splitting theorem in PointInsertion.lean
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

**Goal**: Extend `lemma_2_4` to return both B (the DCS interval set) and C (the MCS endpoint) so that B can be directly assigned as a g-value.

**Tasks**:
- [ ] Modify `lemma_2_4` return type to include B
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean
- [ ] Verify `lake build` succeeds with the extended return type

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

**Goal**: Fix the density sorry site (CounterexampleElimination.lean line 1130) by using Lemma 2.6 on the existing `BurgessR3Maximal(f(x), g(x,y), f(y))` to produce an intermediate D (a fresh MCS, distinct from both f(x) and f(y)).

**Construction**: Apply `lemma_2_6` to `BurgessR3Maximal(f(x), g(x,y), f(y))` with some beta not in g(x,y). Set `f'(z) = D`, `g'(x,z) = B'`, `g'(z,y) = B''`. c2' holds by construction.

**Tasks**:
- [ ] Inspect density sorry site with `lean_goal` to understand exact constraint
- [ ] Identify a formula beta guaranteed not in g(x,y)
- [ ] Apply `lemma_2_6` to produce B', D, B''
- [ ] Construct updated f and g functions for the density insertion
- [ ] Prove c2' for new pairs using Lemma 2.6 output directly
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

**Goal**: Close the 4 c2' sorry sites (C4 forward line 908, C4 backward line 946, g_prop forward line 982, h_prop backward line 1014) by constructing g-values via Lemma 2.6 splitting. Each inserts a new point z between existing points and needs g-values for two new adjacent pairs.

**Data flow**: Apply `lemma_2_6` to the existing `BurgessR3Maximal(f(x), g(x,x_next), f(x_next))` with the counterexample formula beta. Produces B', D, B'' for g'(x,z) = B', g'(z,x_next) = B''. c2' follows directly.

**Tasks**:
- [ ] Inspect all 4 sorry sites with `lean_goal`
- [ ] Close C4 forward sorry (line 908) via Lemma 2.6 splitting
- [ ] Close C4 backward sorry (line 946) via mirror
- [ ] Close g_prop forward sorry (line 982) via splitting
- [ ] Close h_prop backward sorry (line 1014) via mirror
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

**Goal**: Close the 2 C5 c2' sorry sites (C5 forward line 830, C5 backward line 868) by implementing Burgess's full Lemma 2.10 case analysis. The n=0 case uses `burgessR3Maximal_from_g_content_sub`. The n>0 case requires Lemma 2.7 splitting (Phase 6).

**C5 n=0 case** (x is max): `lemma_2_4` produces (B, C) with `g_content(f(x)) subset C`. Use `burgessR3Maximal_from_g_content_sub` to get B for g'(x, y_new). c2' holds by construction.

**C5 n>0 case** (x is not max): Three sub-cases, with sub-case 3 applying Lemma 2.7 splitting.

**Tasks**:
- [ ] Inspect sorry sites at C5 forward/backward with `lean_goal`
- [ ] Implement n=0 case using extended `lemma_2_4`
- [ ] Implement n>0 case analysis (3 sub-cases)
- [ ] Close C5 forward sorry site (line 830)
- [ ] Close C5 backward sorry site (line 868)
- [ ] Run `lake build`

**Timing**: 8 hours

**Depends on**: 8, 9

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- restructure C5 cases (~120 lines each direction)

**Verification**:
- CounterexampleElimination.lean sorry count drops by 2 (C5 sites closed)
- CounterexampleElimination.lean is sorry-free (total 7 sorries closed across Phases 8, 9, 10)
- `lake build` succeeds

---

### Phase 11: ChronicleToCountermodel -- FUC/FSC Coherence and Final Validation [NOT STARTED]

**Goal**: Close the 2 sorry sites in ChronicleToCountermodel.lean (lines 615, 619) for `cantor_bfmcs_restricted_fuc`, then verify the full sorry-free chronicle path.

**Coherence argument**: With g-values properly constructed at every finite stage, the limit chronicle has well-defined g-values. C5 + C3 properties thread through the Cantor isomorphism to prove Until/Since coherence. For U(phi, psi) in f(t), C5 gives a witness y > t with psi in f(y). The limit g(t, y) provides `BurgessR3Maximal(f(t), g(t,y), f(y))`. For intermediate r, C3 gives `g(t,y) subset g(t,r) inter f(r) inter g(r,y)`, so phi in g(t,y) implies phi in f(r).

**Tasks**:
- [ ] Inspect sorry sites at FUC/FSC with `lean_goal`
- [ ] Trace how C5 is available in the limit chronicle
- [ ] Determine how the Cantor isomorphism maps chronicle witnesses to countermodel witnesses
- [ ] Close FUC sorry site (line 615, forward Until coherence)
- [ ] Close FSC sorry site (line 619, forward Since coherence)
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run grep for sorry in Chronicle/ to confirm zero sorry sites
- [ ] Verify `lake build` succeeds with no warnings
- [ ] Update Completeness.lean documentation
- [ ] Clean up temporary scaffolding and outdated TODOs in Chronicle/ files

**Timing**: 5 hours

**Depends on**: 10

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- close 2 sorry sites (~60 lines each)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comments/docstrings
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 11
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] `left_mono_until_G` and `left_mono_since_H` axiom constructors compile and pass soundness
- [ ] `g_content_sub_B_of_BurgessR3Maximal` compiles sorry-free
- [ ] `splitting_seed_consistent` closed via subset + `dcs_neg_union_consistent`
- [ ] Lemma 2.6 splitting (`lemma_2_6_splitting`) compiles sorry-free
- [ ] Lemma 2.7 splitting compiles sorry-free
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type
- [ ] Open-guard compatibility verified for all new infrastructure
- [ ] Each elimination function's g-function correctly handles new and old adjacent pairs

## Artifacts & Outputs

- `plans/45_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (left_mono_until_G, left_mono_since_H constructors)
- Modified `Theories/Bimodal/Metalogic/Soundness.lean` (soundness proofs for new axioms)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (g_content subset B, splitting_seed_consistent closed, extended lemma_2_4, Lemma 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 c2' sorries + 1 density sorry closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 FUC/FSC sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **g_content subset B proof harder than expected**: The proof relies on `dc_delta_B_controlled` which already exists. If the Lean encoding is tricky, isolate the DC({phi} union B) satisfies burgessR3 step as a separate lemma and iterate.
- **left_mono_until_G soundness tricky**: Unlikely (3-line semantic argument). Fallback: add as sorry temporarily, close later.
- **Lemma 2.7 formalization blocked**: Use only Lemma 2.6 for C5 n>0 sub-case 3 (losing xi/eta placement guarantees, but still achieving the split).
- **Density self-pair subtlety**: If burgessR3(f(x), g(x,y), f(x)) when f(z)=f(x) has a structural issue, inspect the exact proof state and adapt the Lemma 2.6 application accordingly.
- All changes are additive (new axioms, new lemmas, proof completions) -- no destructive modifications to existing sorry-free code.
- Git history preserves all prior states; each phase is independently committable.
- The BXCanonical path (task 109) remains as an independent backup completeness route.
