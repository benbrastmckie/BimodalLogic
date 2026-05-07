# Implementation Plan: Task #107 -- Sorry-Free bx_completeness via Guard Threading and Convention Alignment

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 28-40 hours (15-20h sorry closure + 2-4h NoUnivBurgessR3 + 8-16h convention migration + 3-4h cleanup)
- **Dependencies**: None (all prerequisite infrastructure exists; Phases 1-2 of prior plan completed)
- **Research Inputs**: reports/64_team-research.md
- **Artifacts**: plans/64_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorry sites in ChronicleConstruction.lean (lines 1445, 1457) and prove NoUnivBurgessR3 to deliver a fully unconditional, sorry-free `bx_completeness` theorem. The sorries require proving `ξ ∈ limit_f(w)` for intermediate w between x and y at the limit. The closure chain is: (a) strengthen `EliminationResult.c5_forward_witness` to return guard info (`ξ ∈ val.g pc.x y`), (b) thread guard through all 18+ case-construction sites in CounterexampleElimination.lean, (c) strengthen `omega_chain_c5_witness` to return guard from the elimination stage, and (d) use the sorry-free `adj_g_mem_limit_f` to bridge finite-stage guard to limit. After sorry closure, prove `NoUnivBurgessR3` from `Set.univ` inconsistency to make `bx_completeness` unconditional. Then migrate the untl/snce convention to match Burgess U(event, guard). Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; convention matches Burgess 1982.

### Research Integration

**Report 64 (team-research.md)**: Four-teammate analysis confirming three blockers: (1) 2 sorry sites at ChronicleConstruction.lean:1445,1457 needing guard threading through EliminationResult, (2) NoUnivBurgessR3 as unproved hypothesis in bx_completeness (Completeness.lean:128), (3) convention migration (33 files, 2,141 references). Key findings: h_actual check is already Burgess C5a aligned (g-values); the "not actual" case at CE:1479 discards guard witness; Walk A n=0 uses `lemma_2_4` instead of `lemma_2_4_with_guard`; Walk B eta-shortcut (CE:984-1004) needs ~40-60 lines for guard proof; lemma_2_7/2_8 need DC(B union {xi}) seed for xi in B'. All sorry-free infrastructure exists: `adj_g_mem_limit_f`, `adj_g_mem_f_at_stage`, `lemma_2_4_with_guard`, `burgessR3Maximal_with_guard`.

### Prior Plan Reference

Plan v63 had 6 phases (18-26h). Phases 1-2 completed: `lemma_2_4_with_guard` created, `lemma_2_7` fixed to return `B ⊆ B'`, Burgess 2.10 condition (i) aligned (forward + backward walks). Phase 3 partially completed: Tasks 3.1-3.6 done (g_sub_f_insert, g_sub_g_new, dom_new_unique, adj_g_mem_f_at_stage, adj_g_mem_limit_f all proved). Task 3.7 blocked: root cause identified as needing `xi ∈ B'` via DC(B union {xi}) seed, not just `B ⊆ B'`. Phases 4-5 partially completed: limit_satisfies_c5_strong/c5'_strong stated with sorry at guard step; ChronicleToCountermodel.lean rewired to use strong C5 (sorry-free modulo Phase 4 guard). Phase 6 (convention migration) not started. Key lesson: the prior plan underestimated the cascading type-change effort (50 lines type change + 18 case updates for c5_forward_witness enrichment).

### Roadmap Alignment

- Directly advances ROADMAP Phase 7 "FUC/FSC coherence" (2 sorry sites) toward 0
- Completes the Chronicle construction for BX completeness (representation theorem)
- ROADMAP sorry tables are stale (show 9 critical-path sorries; actual is 2)
- Convention migration addresses ROADMAP "Burgess 1982 Alignment Migration" section

## Goals & Non-Goals

**Goals**:
- Strengthen `EliminationResult.c5_forward_witness` to include guard membership (`ξ ∈ val.g pc.x y`)
- Thread guard info through all case-construction sites in CounterexampleElimination.lean
- Strengthen `omega_chain_c5_witness` to return guard from the elimination stage
- Close the 2 sorry sites at ChronicleConstruction.lean:1445,1457
- Prove `NoUnivBurgessR3` and make `bx_completeness` unconditional
- Migrate untl/snce convention to match Burgess U(event, guard)
- Update stale ROADMAP sorry documentation

**Non-Goals**:
- Restructure the omega chain or limit construction architecture
- Close the 15 BXCanonical dead-code sorries (task 109 scope)
- Close the 19 TemporalDerived.lean invalid stubs (separate task)
- Generalize the chronicle construction to arbitrary dense linear orders (Burgess uses Q as a concrete construction medium for the countermodel, exploiting density and midpoint insertion at (x+y)/2; the completeness result itself applies to all linear orders K_0)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Walk B eta-shortcut requires non-trivial guard proof (~60 lines) | Delays Phase 2 | Medium | The eta-shortcut case has `u_next` as direct witness where `η ∈ f(u_next)`. For guard, need `ξ ∈ g(pc.x, u_next)`. Can use walk invariant: guard propagates through condition (i) from x to u_max, then from u_max to u_next via the walk step. If too complex, can restructure to avoid the shortcut (fall through to splitting). |
| lemma_2_7 DC(B union {xi}) seed consistency proof is non-trivial | Delays Phase 3 | Medium | The existing `lemma_2_7_seed_consistent` proves consistency for B-seeded version. Adding xi to the seed requires showing DC(B union {xi}) is consistent. Since xi not in B and B is DCS, DC(B union {xi}) consistency should follow from `deductiveClosure_consistent` (RRelation.lean:192) combined with a union-consistency argument. Alternatively, use `burgessR3Maximal_extension_exists` which already handles the Zorn construction. |
| Convention migration causes silent semantic corruption (same-type args) | Breaks correctness | Medium | Strategy B (full swap + variable rename) mitigates confusion. `lake build` catches structural mismatches. Manual audit of 10 axiom proofs + 5 Chronicle lemmas required. Perform on separate commit for clean revert. |
| EliminationResult type change cascades through 18+ sites | Extended effort | High | Research estimates 50 lines type change + 18 case updates. Each case is mechanical: non-C5 cases extend trivially via absurd; C5 cases need real guard proofs. Proceed case-by-case with `lake build` validation after each batch. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 7, 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Strengthen EliminationResult to Include Guard [NOT STARTED]

**Goal**: Add guard membership to the `c5_forward_witness` and `c5_backward_witness` fields of `EliminationResult`, so the elimination step returns `ξ ∈ val.g pc.x y` (forward) and `ξ ∈ val.g y pc.x` (backward) alongside the existing event witness.

**Paper reference**: Burgess 2.10 (p.374), condition C5a: the elimination produces y with `η ∈ f(y)` AND `ξ ∈ g(x,y)`.

**Tasks**:
- [ ] **Task 1.1**: Modify `c5_forward_witness` return type in `EliminationResult` (CE:612-614) from `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` to `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ pc.ξ ∈ val.g pc.x y`.
- [ ] **Task 1.2**: Modify `c5_backward_witness` return type (CE:615-617) similarly: add `∧ pc.ξ ∈ val.g y pc.x`.
- [ ] **Task 1.3**: Fix all non-C5 case sites (c4_forward, c4_backward, density, c2' cases) where `c5_forward_witness` and `c5_backward_witness` are proved trivially via absurd/decide. These should require no substantive changes -- just extend the absurd proofs.
- [ ] **Task 1.4**: Run `lake build` to identify all remaining compilation errors from the type change.

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult structure definition + non-C5 case sites

**Verification**:
- EliminationResult compiles with strengthened types
- All non-C5 case construction sites compile
- `lake build` identifies only C5-case compilation errors (expected)

---

### Phase 2: Thread Guard Through C5 Forward Cases [NOT STARTED]

**Goal**: Fix all 6 active C5 forward case constructions in CounterexampleElimination.lean to provide the guard witness `pc.ξ ∈ val.g pc.x y`. This covers the "not actual" case, Walk A (n=0), Walk B (eta-shortcut), and the splitting cases (n>=1).

**Paper reference**: Burgess 2.4 (guard in B from enriched seed), 2.7 (xi in B' via DC(B union {xi})), 2.10 (walk invariant for guard propagation).

**Tasks**:
- [ ] **Task 2.1**: Fix "not actual" case (CE:1476-1480): Stop discarding the guard witness. Currently `obtain ⟨y, hy_dom, hy_lt, hy_η, _⟩ := h_actual h_mem h_until` discards the 5th component (`pc.ξ ∈ χ.g pc.x y`). Change to `⟨y, hy_dom, hy_lt, hy_η, h_guard⟩` and include `h_guard` in the return. ~5 lines.
- [ ] **Task 2.2**: Fix Walk A n=0 case (CE:749-753, near line 848): Switch from `lemma_2_4` to `lemma_2_4_with_guard` at CE:848. The `_with_guard` variant returns `γ ∈ B` (guard in interval DCS). Thread this through the chronicle construction to get `pc.ξ ∈ val.g pc.x y`. ~15-20 lines.
- [ ] **Task 2.3**: Fix Walk B eta-shortcut (CE:994-997): Currently returns chronicle unchanged with `u_next` as witness but no guard. Need to prove `pc.ξ ∈ χ.g pc.x u_next`. The walk invariant from Burgess 2.10 condition (i) gives `pc.ξ ∈ g(x, w)` at each walk step. For u_next, guard should follow from the walk having advanced with condition (i) satisfied. ~40-60 lines.
- [ ] **Task 2.4**: Fix the n>=1 splitting cases (CE:1037, 1057, 1062, 1067 and nearby): These use `lemma_2_7` which returns `B ⊆ B'` but not `xi ∈ B'` (since `xi ∉ B` is a hypothesis). The guard info needs to come from the walk invariant or from the splitting structure. Thread guard through the splitting return. ~30-40 lines.
- [ ] **Task 2.5**: Run `lake build` to verify all C5 forward cases compile with guard.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- 6 c5_forward_witness construction sites

**Verification**:
- All C5 forward case construction sites compile with guard witness
- `lake build` passes (possibly with C5 backward errors remaining)
- Guard proofs are structurally correct (no sorry introduced)

---

### Phase 3: Thread Guard Through C5 Backward (Since) Cases [NOT STARTED]

**Goal**: Mirror Phase 2 for all C5 backward (Since) case constructions. Fix the "not actual" since case, walk backward cases, and splitting since cases.

**Paper reference**: Burgess C5b (Since mirror of C5a). All arguments are symmetric.

**Tasks**:
- [ ] **Task 3.1**: Fix "not actual" since case (CE:2235-2236): Same pattern as Phase 2 Task 2.1 -- stop discarding the guard witness. ~5 lines.
- [ ] **Task 3.2**: Fix backward walk n=0 case: Switch to `lemma_2_4_with_guard` variant (or since mirror). ~15-20 lines.
- [ ] **Task 3.3**: Fix backward walk eta-shortcut: Mirror of Phase 2 Task 2.3. ~40-60 lines.
- [ ] **Task 3.4**: Fix backward splitting cases (using `lemma_2_7_since`, `lemma_2_8_since`): Thread guard through since splitting return. ~30-40 lines.
- [ ] **Task 3.5**: Run `lake build` to verify all CounterexampleElimination.lean compiles clean.

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C5 backward case construction sites

**Verification**:
- All C5 backward case construction sites compile with guard witness
- CounterexampleElimination.lean has 0 sorry sites
- `lake build` passes

---

### Phase 4: Strengthen omega_chain_c5_witness and Close Sorries [NOT STARTED]

**Goal**: Strengthen `omega_chain_c5_witness` (ChronicleConstruction.lean:392) to return guard from the elimination stage, then close the 2 sorry sites at lines 1445 and 1457 using `adj_g_mem_limit_f`.

**Paper reference**: Burgess 2.11 (truth lemma). The full C5a with guard: `U(ξ,η) ∈ limit_f(x) → ∃ y, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)`.

**Tasks**:
- [ ] **Task 4.1**: Strengthen `omega_chain_c5_witness` return type (CC:392-399) to include `∧ pc.ξ ∈ (omega_chain_val ...).g pc.x y`. This follows directly from the strengthened `EliminationResult.c5_forward_witness`. ~10 lines.
- [ ] **Task 4.2**: Strengthen `omega_chain_c5'_witness` (CC:418-438) similarly for Since. ~10 lines.
- [ ] **Task 4.3**: Prove `limit_satisfies_c5_strong` guard step (CC:1445). The proof: from strengthened `omega_chain_c5_witness`, obtain `ξ ∈ g_{n+1}(x, y)` where y is the C5 witness at stage n+1. Then `adj_g_mem_limit_f` (CC:1406) gives `ξ ∈ limit_f(w)` for any intermediate w in limit_dom. The key connection: `limit_satisfies_c5_strong` currently calls `limit_satisfies_c5_weak` which uses `omega_chain_c5_witness` internally. Need to extract the stage index n and the finite-stage guard membership, then apply `adj_g_mem_limit_f`. ~30 lines.
- [ ] **Task 4.4**: Close `limit_satisfies_c5'_strong` guard sorry (CC:1457). Mirror of Task 4.3 using `omega_chain_c5'_witness` and Since version of `adj_g_mem_limit_f`. ~30 lines.
- [ ] **Task 4.5**: Run `lake build` and `grep -rn "sorry" Chronicle/` to verify 0 sorry sites on critical path.

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- omega_chain_c5_witness, omega_chain_c5'_witness, limit_satisfies_c5_strong, limit_satisfies_c5'_strong

**Verification**:
- Both sorry sites at CC:1445 and CC:1457 are closed
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comment/doc occurrences
- `lake build` passes
- ChronicleToCountermodel.lean remains sorry-free (was rewired in prior plan Phase 5)

---

### Phase 5: Prove NoUnivBurgessR3 [NOT STARTED]

**Goal**: Prove `NoUnivBurgessR3` as a theorem (not just a hypothesis) and make `bx_completeness` unconditional by removing the `h_nubr3` parameter.

**Paper reference**: `burgessR3 A Set.univ C` requires `burgessRSet A Set.univ C ∧ burgessRSetSince C Set.univ A`. But `Set.univ` contains both `φ` and `¬φ` for every `φ`, making it inconsistent. The `BurgessR3Maximal` Zorn construction requires the interval set B to be `ClosedUnderDerivation` but NOT `Set.univ` (the maximality clause uses proper subsets of CUD sets that are not Set.univ). The key: `burgessR3 A Set.univ C` implies `Set.univ` is `ClosedUnderDerivation` (which it is) and satisfies r-relations. But `Set.univ` is inconsistent, so any proper extension of B that contains `Set.univ` would be `Set.univ` itself -- contradicting maximality. The direct proof: show `¬burgessR3 A Set.univ C` by exhibiting the inconsistency contradiction via `SetMaximalConsistent` properties of A and C.

**Tasks**:
- [ ] **Task 5.1**: Prove `noUnivBurgessR3 : NoUnivBurgessR3` in ChronicleTypes.lean or a new file. Show that `burgessR3 A Set.univ C` leads to contradiction for any MCS A, C. ~50-100 lines.
- [ ] **Task 5.2**: Modify `bx_completeness` (Completeness.lean:128) to use `noUnivBurgessR3` directly instead of taking `h_nubr3` as parameter. Update `bx_completeness'` similarly. ~5-10 lines.
- [ ] **Task 5.3**: Update all callers of `bx_completeness` (if any external callers exist) to remove the NoUnivBurgessR3 argument. ~5 lines.
- [ ] **Task 5.4**: Run `#print axioms bx_completeness` and verify no `sorryAx`. Run `lake build`.

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (or new file) -- proof of noUnivBurgessR3
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- remove h_nubr3 parameter

**Verification**:
- `NoUnivBurgessR3` proved as theorem (not sorry)
- `bx_completeness` takes no hypothesis parameters beyond `φ : Formula`
- `#print axioms bx_completeness` shows: `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (no `sorryAx`)
- `lake build` passes

---

### Phase 6: Final Sorry-Free Validation [NOT STARTED]

**Goal**: Comprehensive validation that `bx_completeness` is truly sorry-free and the Chronicle construction is complete.

**Tasks**:
- [ ] **Task 6.1**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` and verify only comment/documentation occurrences remain.
- [ ] **Task 6.2**: Run `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` and verify only comment occurrences.
- [ ] **Task 6.3**: Run `#print axioms bx_completeness` via lean_run_code or lean_verify and capture output.
- [ ] **Task 6.4**: Full `lake build` from clean state.
- [ ] **Task 6.5**: Update Completeness.lean header comments to reflect sorry-free status.

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update comments

**Verification**:
- Zero sorry sites on critical path
- `bx_completeness` axiom-clean (no sorryAx)
- Clean `lake build`

---

### Phase 7: Convention Migration -- untl/snce Argument Swap [NOT STARTED]

**Goal**: Migrate `untl(guard, event)` to `untl(event, guard)` and `snce(guard, event)` to `snce(event, guard)` across the entire codebase to match Burgess 1982's convention `U(event, guard)` / `S(event, guard)`.

**Paper reference**: Burgess 1982, Section 1.2 (p.367): `V(U(alpha, beta))` where alpha = event (endpoint), beta = guard (intermediate).

**Research input**: Report 67 (convention-migration-research.md) -- full scope analysis (33 files, ~2141 references). Strategy B (full swap + variable renaming) recommended.

**Tasks**:
- [ ] **Task 7.1**: Swap `untl`/`snce` constructor argument order in `Formula.lean`. Update `next`/`prev` derived operators.
- [ ] **Task 7.2**: Swap in `Truth.lean` semantics (2 lines: truth_at for untl and snce).
- [ ] **Task 7.3**: Swap in `Axioms.lean` (~35 axiom definitions + Since mirrors).
- [ ] **Task 7.4**: Update `burgessR`/`burgessRSince` and all Chronicle types in `ChronicleTypes.lean`. Both directions: the constructed formulas inside burgessR AND the definitions must swap args.
- [ ] **Task 7.5**: Update all `Formula.untl`/`Formula.snce` constructions across ~33 files (~2141 refs). Use `lake build` error-driven iteration. This is the bulk of the work.
- [ ] **Task 7.6**: Rename variables for clarity: guard params use Burgess beta/eta naming, event params use Burgess alpha/xi naming (where feasible without excessive churn).
- [ ] **Task 7.7**: Update comments and documentation referencing the old convention (at least 6 in PointInsertion.lean).
- [ ] **Task 7.8**: Full `lake build` clean. Verify `#print axioms bx_completeness` unchanged (no sorryAx).
- [ ] **Task 7.9**: Audit: spot-check 10 axiom proofs and 5 Chronicle lemmas for semantic correctness after swap. Both args are `Formula` type -- silent corruption is the main danger.

**Timing**: 8-16 hours (1-2 days focused work)

**Depends on**: 6

**Files to modify**: ~33 files across Syntax/, Semantics/, ProofSystem/, Metalogic/, Theorems/, Automation/, Examples/ (see reports/67_convention-migration-research.md for complete list)

**Verification**:
- `lake build` passes
- `#print axioms bx_completeness` shows same axioms (no sorryAx)
- Convention `untl(event, guard)` matches Burgess `U(event, guard)` throughout
- Spot-check audit passes (10 axioms + 5 Chronicle lemmas)
- All Burgess paper references in comments use consistent notation

---

### Phase 8: ROADMAP and Documentation Cleanup [NOT STARTED]

**Goal**: Update stale ROADMAP sorry tables, Completeness.lean comments, and remove invalid stubs.

**Tasks**:
- [ ] **Task 8.1**: Update ROADMAP.md Chronicle sorry table: change "9 sorry sites remain on critical path" to 0. Update the table at lines 56-63 to reflect actual state. Update "19 sorry proofs across 7 files" count.
- [ ] **Task 8.2**: Update Completeness.lean comments: remove references to "11 sorries" or "remaining leaf sorries" and update to reflect sorry-free status.
- [ ] **Task 8.3**: Update plan v63 phase statuses to reflect completion (all phases completed or superseded).
- [ ] **Task 8.4**: Identify and document (but do NOT delete) the 19 TemporalDerived.lean invalid sorry stubs -- mark them for a separate cleanup task.

**Timing**: 1-2 hours

**Depends on**: 6, 7

**Files to modify**:
- `specs/ROADMAP.md` -- sorry tables and counts
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- header comments
- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/63_implementation-plan.md` -- phase statuses

**Verification**:
- ROADMAP sorry counts match actual state
- Completeness.lean comments accurate
- No stale documentation referencing closed sorries

---

### Phase 9: Final Integration and Summary [NOT STARTED]

**Goal**: Create execution summary and perform final validation of all changes.

**Tasks**:
- [ ] **Task 9.1**: Run comprehensive validation: `lake build`, `#print axioms bx_completeness`, grep for sorry across all modified files.
- [ ] **Task 9.2**: Verify irr_until axiom is NOT used anywhere.
- [ ] **Task 9.3**: Verify no density or discreteness axioms were added.
- [ ] **Task 9.4**: Create execution summary artifact.

**Timing**: 1 hour

**Depends on**: 7, 8

**Files to modify**:
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/64_execution-summary.md` -- new file

**Verification**:
- All validation checks pass
- Summary accurately reflects completed work

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary (Phases 1-6)
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 5
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment/doc occurrences after Phase 4
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only comment occurrences after Phase 5
- [ ] After Phase 7: convention `untl(event, guard)` matches Burgess `U(event, guard)` throughout
- [ ] No density or discreteness axioms added
- [ ] `irr_until` axiom NOT used anywhere
- [ ] All new lemmas follow Burgess 1982 exactly -- no novel mathematical approaches
- [ ] Spot-check audit: 10 axiom proofs + 5 Chronicle lemmas correct after convention swap

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/64_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/64_execution-summary.md` (after Phase 9)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 1-3: EliminationResult type change + 18+ case updates)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 4: omega_chain_c5_witness + close 2 sorries)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (Phase 5: NoUnivBurgessR3 proof)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (Phase 5: unconditional bx_completeness)
  - ~33 files across Syntax/, Semantics/, ProofSystem/, Metalogic/ (Phase 7: convention migration)
  - `specs/ROADMAP.md` (Phase 8: documentation update)

## Rollback/Contingency

- **Phases 1-4 (guard threading)**: Commit after each phase. If a phase fails, revert to the prior commit. The type change in Phase 1 is the riskiest -- if the cascading updates prove unmanageable, an alternative is to add a SEPARATE `c5_forward_guard` field to EliminationResult instead of enriching the existing field.

- **Phase 5 (NoUnivBurgessR3)**: Independent of Phases 1-4. Can be done in parallel or deferred. If the proof is harder than expected, keep `h_nubr3` as a parameter and mark it as a separate task.

- **Phase 7 (convention migration)**: Perform on a separate commit (or branch) for clean revert. Both args are `Formula` type -- `lake build` catches structural mismatches but NOT same-type semantic swaps. The manual audit in Task 7.9 is critical. If corruption is detected, revert the entire convention change.

- **General**: `git stash` or `git revert` at any phase boundary. Each phase produces a self-contained improvement.
