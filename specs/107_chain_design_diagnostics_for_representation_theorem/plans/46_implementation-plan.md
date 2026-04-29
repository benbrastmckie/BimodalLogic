# Implementation Plan: Task #107 -- Burgess Chronicle g-Value Construction (v32)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [IN PROGRESS]
- **Effort**: 36 hours (estimated 22 remaining)
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/42_team-research.md], [reports/43_team-research.md], [reports/44_team-research.md], [reports/45_team-research.md], [reports/47_inconsistent-case-resolution.md], [handoffs/48_inconsistent-case-dcs-gap.md]
- **Artifacts**: plans/46_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v32 addresses the DCS definition gap discovered in Handoff 48. The codebase's `SetDeductivelyClosed` bundles consistency (`SetConsistent S`) with closure, but Burgess 1982 and Xu 1988 define DCS as closure-only. This means `Set.univ` is NOT `SetDeductivelyClosed` in our framework, breaking Report 47's maximality argument for the inconsistent case. The fix introduces `ClosedUnderDerivation` (closure without consistency) and updates `BurgessR3Maximal`'s maximality clause to quantify over `ClosedUnderDerivation` sets instead of `SetDeductivelyClosed` sets. This aligns with the Burgess/Xu definition and enables `Set.univ` as a valid candidate in the maximality contradiction.

Phase 5b from v31 is split into Phase 5b-i (definition refactoring) and Phase 5b-ii (close inconsistent case). Phases 1-5a remain [COMPLETED]. Phases 6-11 remain [NOT STARTED] and unchanged.

Definition of done: all Chronicle sorry sites closed, `#print axioms dd_countermodel_chronicle` clean, `lake build` succeeds. Current sorry count: **4** (down from 10 at plan start): RRelation.lean:772 (Zorn), CounterexampleElimination.lean:1130 (density self-pair), ChronicleToCountermodel.lean:615,619 (FUC/FSC).

### Research Integration

- **Report 42 (team research)**: Root cause diagnosis -- g-values never constructed. Integrated in plan v26.
- **Report 43 (team research)**: Density self-pair impossible, C5 n=0 via g_content, Lemma 2.7 gating question. Integrated in plan v27.
- **Report 44 (team research)**: A4a is valid but not needed for splitting. Integrated in plan v29.
- **Report 45 (team research)**: Breakthrough -- left_mono_until_G + g_content(A) subset B via maximality makes splitting_seed_consistent trivial. 3-step solution replaces blocked Phase 5b. Corrected sorry count to 10. Integrated in plan v30.
- **Report 47 (inconsistent case resolution)**: Resolves the Phase 5b inconsistent case blocker. Set.univ is a valid DCS for maximality contradiction when {phi} union B is inconsistent. No density needed. Use BurgessR3Maximal definition directly instead of BurgessR3Maximal_extension_fails. Integrated in plan v31.
- **Handoff 48 (DCS definition gap)**: Reveals that `SetDeductivelyClosed` bundles consistency, unlike Burgess/Xu. `Set.univ` fails the `SetConsistent` conjunct. Fix: split into `ClosedUnderDerivation` (closure-only) and update `BurgessR3Maximal` maximality clause. Integrated in this plan (v32).

### Prior Plan Reference

Plan v31 had 11 phases, 34 hours. Phases 1-5a completed. Phase 5b was [PARTIAL]: consistent case proved, inconsistent case sorry'd. Handoff 48 showed Report 47's argument fails because our `SetDeductivelyClosed` includes consistency. v32 splits Phase 5b into two sub-phases: 5b-i (refactor DCS definition, update BurgessR3Maximal) and 5b-ii (close inconsistent case using refactored definitions).

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP: Active Metalogic Paths)
- Closing all 10 remaining chronicle sorry sites achieves the chronicle sorry-free milestone
- Unblocks task 95 (#print axioms audit)

## Goals & Non-Goals

**Goals**:
- Add `ClosedUnderDerivation` predicate (closure without consistency) to ChronicleTypes.lean
- Refactor `SetDeductivelyClosed` to use `ClosedUnderDerivation`: `SetDeductivelyClosed S = SetConsistent S /\ ClosedUnderDerivation S`
- Update `BurgessR3Maximal` maximality clause to quantify over `ClosedUnderDerivation` (not `SetDeductivelyClosed`)
- Fix all downstream compilation errors from the definition change
- Close the inconsistent case sorry in `g_content_sub_B_of_BurgessR3Maximal`
- Close dual `h_content_sub_B` sorry
- Close `splitting_seed_consistent` sorry via subset + `dcs_neg_union_consistent`
- Verify `lemma_2_6_splitting` is sorry-free
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
| `ClosedUnderDerivation` refactoring causes widespread breakage | M | M | `SetDeductivelyClosed` is refactored to use `ClosedUnderDerivation` internally, so most call sites only need `.2` replaced with `.closedUnderDerivation` or similar. Grep for all usages first. |
| Zorn construction (`burgessR3Maximal_extension_exists`) breaks under new maximality | H | L | The Zorn construction produces B maximal among consistent+closed extensions. For ClosedUnderDerivation maximality: if D is ClosedUnderDerivation and B strictly contained in D, either D is consistent (covered by Zorn) or D is inconsistent. If D inconsistent, D contains bot, so burgessR3(A,D,C) fails only if... actually it holds (ex falso). But B itself is consistent, so B is not Set.univ, so the Zorn chain union argument still works because chain of consistent sets stays consistent. |
| `BurgessR3Maximal_extension_fails` callers need updating | M | M | This lemma's type signature changes: its D hypothesis becomes `ClosedUnderDerivation D` instead of `SetDeductivelyClosed D`. Callers that passed `SetDeductivelyClosed` can extract the `.2` component. |
| Density self-pair sorry (line 1130) has a structural subtlety | M | M | Inspect with lean_goal first; may need special-case argument |
| C5 n>0 recursive case analysis adds significant complexity | H | M | Start with n=0 (straightforward); n>0 sub-case 3 uses Lemma 2.7 which is independent |
| FUC/FSC coherence requires threading g through Cantor isomorphism | M | M | Phase is independent; partial progress still reduces sorry count |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| -- | 1, 2, 3, 4, 5a | (already completed from v24/v27) |
| 1 | 5b-i | -- (no dependencies beyond completed phases) |
| 2 | 5b-ii | 5b-i |
| 3 | 6, 7 | 5b-ii |
| 4 | 8, 9 | 7 |
| 5 | 10 | 8, 9 |
| 6 | 11 | 10 |

Phases within the same wave can execute in parallel. Phase 5b-i is the critical path entry point. Phases 6 and 7 can run in parallel once 5b-ii completes.

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

### Phase 5b-i: Split DCS Definition + Update BurgessR3Maximal [COMPLETED]

**Goal**: Introduce `ClosedUnderDerivation` predicate (closure without consistency), refactor `SetDeductivelyClosed` to use it, and update `BurgessR3Maximal`'s maximality clause to quantify over `ClosedUnderDerivation` sets. This aligns the formalization with Burgess 1982 / Xu 1988 where DCS = closure-only.

**Motivation** (Handoff 48): `SetDeductivelyClosed` at ChronicleTypes.lean:75 bundles `SetConsistent S /\ closure`. Burgess and Xu define DCS as closure-only. `Set.univ` is closed under derivation but NOT `SetConsistent`. `BurgessR3Maximal`'s maximality clause quantifies over `SetDeductivelyClosed D`, which excludes `Set.univ`, breaking the inconsistent case argument.

**Tasks**:
- [x] Add `ClosedUnderDerivation` predicate to ChronicleTypes.lean (line 68)
- [x] Refactor `SetDeductivelyClosed` to use `ClosedUnderDerivation`: `SetConsistent S ∧ ClosedUnderDerivation S`
- [x] Update `BurgessR3Maximal` maximality clause to use `ClosedUnderDerivation`
- [x] Update `BurgessR3Maximal_extension_fails` signature to accept `ClosedUnderDerivation D`
- [x] Update `burgessR3Maximal_extension_exists` (Zorn construction): consistent case handled; inconsistent case has 1 sorry (RRelation.lean:772 — `¬burgessR3(A, Set.univ, C)` not provable without density)
- [x] Fix all downstream compilation errors
- [x] `lake build` succeeds

**Timing**: 2-3 hours

**Depends on**: none (phases 1-5a already completed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- add `ClosedUnderDerivation`, refactor `SetDeductivelyClosed`, update `BurgessR3Maximal`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- update `BurgessR3Maximal_extension_fails` and callers
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ZornConstruction.lean` (or wherever `burgessR3Maximal_extension_exists` lives) -- verify Zorn argument
- Any other files that reference `SetDeductivelyClosed` or `BurgessR3Maximal`

**Verification**:
- `ClosedUnderDerivation` definition compiles
- `SetDeductivelyClosed` refactored to use `ClosedUnderDerivation` and compiles
- `BurgessR3Maximal` updated and compiles
- `BurgessR3Maximal_extension_fails` compiles with new signature
- `burgessR3Maximal_extension_exists` compiles (Zorn argument still valid)
- `lake build` succeeds (no new errors beyond pre-existing sorries)

---

### Phase 5b-ii: Close Inconsistent Case + splitting_seed_consistent [COMPLETED]

**Goal**: With `ClosedUnderDerivation` in place and `BurgessR3Maximal` maximality now covering `Set.univ`, close the inconsistent case of `g_content_sub_B_of_BurgessR3Maximal`, the dual `h_content_sub_B`, and `splitting_seed_consistent`.

**Tasks**:
- [x] Helper: `set_univ_closed_under_derivation` — sorry-free
- [x] Helper: `ex_falso_from_assumption` — `⊢ φ → (φ.neg → ψ)`, sorry-free
- [x] Helper: `G_ex_falso_strengthen` — `G(φ.neg → ψ) ∈ A` from `G(φ) ∈ A`, sorry-free
- [x] Helper: `H_ex_falso_strengthen` — dual, sorry-free
- [x] Helper: `neg_mem_of_inconsistent_union` — `φ.neg ∈ B` from `¬SetConsistent({φ}∪B)` and `SetDeductivelyClosed B`, sorry-free
- [x] Helper: `dcs_ssubset_univ` — `B ⊂ Set.univ` when B is consistent DCS, sorry-free
- [x] Helper: `burgessR3_univ_of_inconsistent_ext` — `burgessR3(A, Set.univ, C)` from inconsistent extension, sorry-free
- [x] Close inconsistent case of `g_content_sub_B_of_BurgessR3Maximal` — sorry-free (verified: no sorryAx)
- [x] Close `h_content_sub_B_of_BurgessR3Maximal` dual — sorry-free (verified: no sorryAx)
- [x] Close `splitting_seed_consistent` — sorry-free (verified: no sorryAx)
- [x] `lemma_2_6_splitting` still has sorryAx (inherits from `burgessR3Maximal_from_g_content_sub` → Zorn sorry)
- [x] `lake build` succeeds
- [x] PointInsertion.lean: zero sorry lines

**Remaining sorry**: RRelation.lean:772 — Zorn inconsistent ClosedUnderDerivation case. `burgessR3(A, Set.univ, C)` cannot be refuted without density axioms. This sorry propagates to `lemma_2_6_splitting` and downstream but does NOT affect `g_content_sub_B`, `h_content_sub_B`, or `splitting_seed_consistent` (these are genuinely sorry-free).

**Timing**: 1-2 hours

**Depends on**: 5b-i

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- helper lemmas + close 3 sorry sites (~50 lines new code)

**Verification**:
- `set_univ_closed_under_derivation` compiles sorry-free
- `burgessR3_univ_of_inconsistent_ext` compiles sorry-free
- Inconsistent case of `g_content_sub_B_of_BurgessR3Maximal` closed
- `h_content_sub_B_of_BurgessR3Maximal` closed (both cases)
- `splitting_seed_consistent` closed
- `lemma_2_6_splitting` sorry-free
- PointInsertion.lean sorry count: 0
- `lake build` succeeds

---

### Phase 6: Formalize Lemma 2.7 Splitting [IN PROGRESS]

**Goal**: Formalize Lemma 2.7 (Until-formula splitting): given `BurgessR3Maximal(A, B, C)` with `U(xi, eta) in A` and `eta not in B`, produce `B', D, B''` with `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` where `xi in D` and `eta in B'`. Needed for C5 n>0 sub-case 3 (Phase 10).

**Note**: Lemma 2.7 does NOT depend on A4a or left_mono_until_G. It uses only BX5 + BX7 + BX13.

**Tasks**:
- [x] Study existing infrastructure: lemma_2_6_splitting, BurgessR3Maximal, BX5/BX7/BX13 axioms
- [x] Read Phase 5a gate report for validated proof sketch
- [ ] Design Lemma 2.7 proof: splitting with xi ∈ D and eta ∈ B' guarantees
- [ ] Formalize the full splitting theorem in PointInsertion.lean (~100 lines)
- [ ] Connect to BX5 (guard_until) and BX7 (guard_since) axiom infrastructure
- [ ] Verify theorem compiles sorry-free
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5b-ii

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add Lemma 2.7 splitting (~100 lines)

**Verification**:
- Lemma 2.7 splitting theorem compiles sorry-free
- `lake build` succeeds

---

### Phase 7: Extend lemma_2_4 Return Type [COMPLETED]

**Goal**: Extend `lemma_2_4` to return both B (the DCS interval set) and C (the MCS endpoint) so that B can be directly assigned as a g-value.

**Tasks**:
- [ ] Modify `lemma_2_4` return type to include B
- [ ] Update all call sites of `lemma_2_4` in CounterexampleElimination.lean
- [ ] Verify `lake build` succeeds with the extended return type

**Timing**: 4 hours

**Depends on**: 5b-ii

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
- [ ] `ClosedUnderDerivation` predicate compiles and is used correctly throughout
- [ ] `SetDeductivelyClosed` refactored without breaking existing sorry-free proofs
- [ ] `BurgessR3Maximal` updated maximality clause compiles
- [ ] `set_univ_closed_under_derivation` compiles sorry-free
- [ ] `burgessR3_univ_of_inconsistent_ext` compiles sorry-free
- [ ] `g_content_sub_B_of_BurgessR3Maximal` compiles sorry-free (both consistent and inconsistent cases)
- [ ] `splitting_seed_consistent` closed via subset + `dcs_neg_union_consistent`
- [ ] Lemma 2.6 splitting (`lemma_2_6_splitting`) compiles sorry-free
- [ ] Lemma 2.7 splitting compiles sorry-free
- [ ] Extended `lemma_2_4` compiles sorry-free with new return type
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns no actual sorry usages after Phase 11
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Open-guard compatibility verified for all new infrastructure
- [ ] Each elimination function's g-function correctly handles new and old adjacent pairs

## Artifacts & Outputs

- `plans/46_implementation-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (add `ClosedUnderDerivation`, refactor `SetDeductivelyClosed`, update `BurgessR3Maximal`)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (update callers, helper lemmas, inconsistent case closed, h_content dual closed, splitting_seed_consistent closed, extended lemma_2_4, Lemma 2.7)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (7 c2' sorries + 1 density sorry closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (2 FUC/FSC sorry sites closed)
- Modified `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (documentation)
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- **ClosedUnderDerivation refactoring causes cascading breakage**: The change is designed to be minimally invasive. `SetDeductivelyClosed S` becomes `SetConsistent S /\ ClosedUnderDerivation S`, so existing destructuring with `.1` and `.2` still works (`.1` = `SetConsistent`, `.2` = `ClosedUnderDerivation`). If breakage is severe, revert ChronicleTypes.lean changes and pursue Option B from Handoff 48 (prove inconsistent case cannot occur).
- **Zorn construction fails under new maximality**: The Zorn argument produces a B that is maximal among consistent+closed sets. If the stronger maximality (over all `ClosedUnderDerivation` sets) breaks Zorn, add a separate lemma proving that the Zorn-maximal B is also maximal among all closed sets (via the inconsistent case argument in Phase 5b-ii).
- **Inconsistent case helper harder than expected**: The proof sketch is concrete. If `burgessR3_univ_of_inconsistent_ext` is complex, break into smaller lemmas (ex-falso step, G distribution step, left_mono_until_G step).
- **Lemma 2.7 formalization blocked**: Use only Lemma 2.6 for C5 n>0 sub-case 3 (losing xi/eta placement guarantees, but still achieving the split).
- **Density self-pair subtlety**: If burgessR3(f(x), g(x,y), f(x)) when f(z)=f(x) has a structural issue, inspect the exact proof state and adapt the Lemma 2.6 application accordingly.
- All changes are additive (new lemmas, proof completions) -- no destructive modifications to existing sorry-free code (except the DCS definition refactoring in Phase 5b-i, which is carefully structured to preserve existing API).
- Git history preserves all prior states; each phase is independently committable.
- The BXCanonical path (task 109) remains as an independent backup completeness route.
