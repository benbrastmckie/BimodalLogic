# Implementation Plan: Task #157 (v7) -- Junction-Depth Induction via Research Resolution

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/04_team-research.md (Phase 6 blocker resolution), reports/03_team-research.md (expand_temporal breakthrough)
- **Artifacts**: plans/04_junction-depth-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v7 replaces the blocked Phase 6 from plan v6 with the research-resolved approach: prove `no_S_nested_in_U_separable` by strong induction on junction_depth using Cases 1-4 plus `neg_until_equiv`, where Cases 5-8 are handled WITHIN the induction at lower junction_depth rather than as standalone lemmas. This breaks the circular dependency (`all_separable` -> temporal closure axioms -> Cases 5-8 -> `all_separable`) identified in plan v6. The existing `expand_temporal` infrastructure (Tasks 6.1-6.6, completed) handles `all_past`/`all_future` via Z-equivalences. Duality via `swap_temporal` halves the work: prove the snce direction, derive untl automatically.

Definition of done: `lake build` passes with zero axioms in SeparationThm.lean and zero sorry in ExpressiveCompleteness.lean.

### Research Integration

Report 04 (team research, 4 teammates) identified the blocker resolution:
1. The circular dependency is ARCHITECTURAL, not mathematical -- Cases 5-8 only use `all_separable` as a shortcut, not logically
2. All 4 teammates converge: prove `no_S_nested_in_U_separable` by strong induction on junction_depth
3. The `snce` case of `no_S_nested_in_U_separable` is TRIVIAL (U-free snce args mean already separated)
4. The hard cases (`all_past`/`all_future`) are handled by `expand_temporal` (Tasks 6.1-6.6)
5. Key new infrastructure: `abstract_snce` (~100 LOC), junction depth decrease lemmas (~100 LOC)
6. Backup: GHR94 Ch 10.3 Dedekind formulas specialize correctly to Z (K+=K-=T, G+-=bot)

Report 03 (prior team research) identified `expand_temporal` preprocessing as the fix for JD=0 not implying separated with primitive `all_past`/`all_future`. This infrastructure is now fully built.

### Prior Plan Reference

Plan v6 (03_hierarchy-first-plan.md): Phases 1-5 completed successfully (purity predicates, Lemmas 10.2.4-10.2.6, Cases 5-8 via hierarchy, Eliminations.lean axiom-free). Phase 6 was blocked on Tasks 6.7-6.14 (temporal closure axiom elimination) due to circular dependency. Tasks 6.1-6.6 (expand_temporal infrastructure) completed. Phase 7 (quantifier cases) is in progress via a separate agent. Phase 8 (integration) was not started. Effort calibration: Phase 6 blocker consumed ~20 hours of failed attempts in v6 -- the research resolution should reduce this significantly. Key lesson: the substitution bridge (`abstract_untl` + substitute back) does NOT preserve syntactic separation -- the junction-depth induction must handle Cases 5-8 internally.

### Roadmap Alignment

- Advances "Phase 2 -- Frame hierarchy + axiom cleanup" in ROADMAP.md
- Advances "Phase 3 -- Expressive extensions" prerequisite (expressive completeness of {S,U})
- This is Reynolds Theorem 5, required as prerequisite for Phase 3B of task 155

## Goals & Non-Goals

**Goals**:
- Prove `no_S_nested_in_U_separable` by strong induction on junction_depth without axioms
- Derive all 4 weak temporal closure axioms as theorems from `no_S_nested_in_U_separable`
- Derive all 4 proper temporal closure axioms as theorems
- Replace all 8 axioms in SeparationThm.lean with proved theorems
- Complete `separation_implies_expressiveness` in ExpressiveCompleteness.lean (close 2 sorries)
- Achieve zero-axiom, zero-sorry `lake build` for Separation/ + ExpressiveCompleteness stack

**Non-Goals**:
- Fixing DualEliminations.lean (dead code, 8 sorries, independent)
- Performance optimization of proof terms
- Alternative proof approaches (Reynolds pipeline, EF games, Dedekind formulas) unless primary fails
- Eliminating axioms outside the Separation/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Junction depth induction step is harder than research suggests (Cases 5-8 within induction) | H | L | Research has 4 independent confirmations; expand_temporal + Cases 1-4 + neg_until_equiv covers all subcases at lower JD |
| `abstract_snce` implementation has unexpected complications (dual of `abstract_untl`) | M | L | `abstract_untl` is already implemented (~400 LOC in Hierarchy.lean); `abstract_snce` follows same pattern with S/U swapped |
| Lean termination checker rejects strong induction on junction_depth | M | M | Use `Nat.strongRecOn` (recommended by research) instead of `termination_by`; explicit well-founded measure avoids structural recursion limitations |
| `multi_U_formula_separable` replacement (currently shortcuts to `all_separable`) is complex | M | L | The replacement IS the junction-depth induction itself; once `no_S_nested_in_U_separable` is proved, it replaces the shortcut |
| Phase 7 quantifier cases interact unexpectedly with axiom elimination | L | L | Phase 7 is confirmed independent by Critic teammate; quantifier cases use `all_properly_separable` which is downstream of axiom elimination |
| `expand_temporal` + `swap_temporal` interaction needs a commutation lemma | L | M | May need `expand_temporal_swap` (~30 LOC); swap preserves junction_depth per research |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 6 | -- (Phases 1-5 completed in v6) |
| 1 | 7 | -- (independent, in progress separately) |
| 2 | 8 | 6, 7 |

Phases within the same wave can execute in parallel.

Note: Phases 1-5 from plan v6 are COMPLETED and not repeated here. Phase numbering continues from v6 for consistency. Phase 7 is included for completeness but is being worked on by a separate agent.

---

### Phase 6: Prove no_S_nested_in_U_separable and Eliminate 8 Axioms [IN PROGRESS]

**Goal**: Break the circular dependency by proving `no_S_nested_in_U_separable` via strong induction on junction_depth, then derive all 8 temporal closure axioms as theorems, replacing the 8 axioms in SeparationThm.lean.

**Strategy**: The proof proceeds in layers:
1. **Build missing infrastructure**: `abstract_snce` (dual of `abstract_untl`), junction depth decrease lemmas, `abstract_untl_identity_on_U_free`
2. **Prove the core theorem**: `no_S_nested_in_U_separable` by `Nat.strongRecOn` on `junction_depth (expand_temporal phi)`. Base case uses `expanded_jd_zero_imp_separated`. Inductive step uses Cases 1-4 + `neg_until_equiv` to reduce junction depth; Cases 5-8 situations arise at lower JD and are handled by the induction hypothesis
3. **Derive temporal closure axioms**: `snce_separable` from box-normalization + `no_S_nested_in_U` property; `untl_separable` via `swap_temporal` duality; `all_past_separable`/`all_future_separable` via `expand_temporal` equivalences
4. **Replace axioms**: Remove 4 weak + 4 proper temporal closure axioms from SeparationThm.lean, replacing with the proved theorems
5. **Fix downstream**: Replace `multi_U_formula_separable`'s shortcut to `all_separable` (Hierarchy.lean line 547) with the actual junction-depth induction proof

**Tasks**:
- [ ] Task 6.7: Implement `abstract_snce` in Hierarchy.lean (~100 LOC, dual of `abstract_untl`): replace all occurrences of a specific `S(A,B)` with a fresh atom. Prove `abstract_snce_correct` (semantic equivalence under withAtom), `abstract_snce_makes_S_free` (S-count decreases)
- [ ] Task 6.8: Prove `abstract_untl_identity_on_U_free` in Hierarchy.lean (~20 LOC): when phi is U-free, `abstract_untl phi A B p = phi`. Needed to show that the junction-depth induction step preserves structure of U-free subterms
- [ ] Task 6.9: Prove `abstract_untl_preserves_separated` in Hierarchy.lean (~50 LOC): in a separated formula, U-free snce/all_past args are untouched by `abstract_untl` (identity on U-free), so separation is preserved. Research teammate B confirmed proof sketch is sound
- [ ] Task 6.10: Prove junction depth decrease lemmas in TemporalClosure.lean (~100 LOC): after applying Cases 1-4 + `neg_until_equiv` to a formula with JD=n+1, the resulting formula has JD <= n. Key lemma: `case_application_decreases_jd` showing each case strictly reduces junction depth of the relevant subterm
- [ ] Task 6.11: Prove `no_S_nested_in_U_separable` in Hierarchy.lean (~200 LOC): the main theorem by `Nat.strongRecOn` on `junction_depth (expand_temporal phi)`. Structure: expand_temporal -> box-normalize -> if JD=0 use `expanded_jd_zero_imp_separated`, else apply case analysis (Cases 1-4 + `neg_until_equiv`) to reduce JD and invoke IH
- [ ] Task 6.12: Derive `no_U_nested_in_S_separable` via `swap_temporal` duality in Hierarchy.lean (~30 LOC): use `swap_temporal_int_truth` to convert between the two predicates
- [ ] Task 6.13: Replace `multi_U_formula_separable` shortcut (Hierarchy.lean line 547) with actual proof via `no_S_nested_in_U_separable` (~20 LOC): remove the `all_separable phi` call, use the proved theorem directly
- [ ] Task 6.14: Derive 4 weak temporal closure theorems in SeparationThm.lean (~80 LOC total): `snce_separable` (separated args -> box-normalize -> `replace_box_separated_no_S_nested` -> `no_S_nested_in_U_separable`), `untl_separable` (via `swap_temporal` duality from `snce_separable`), `all_past_separable` (via `expand_temporal` equivalence + `snce_separable`), `all_future_separable` (via duality)
- [ ] Task 6.15: Derive 4 proper temporal closure theorems in SeparationThm.lean (~60 LOC total): proper variants follow from weak variants + proper separability closure lemmas (already exist in Defs.lean)
- [ ] Task 6.16: Remove all 8 axioms from SeparationThm.lean, replacing with `theorem` declarations using the proofs from Tasks 6.14-6.15
- [ ] Task 6.17: Verify `lake build` passes with 0 axioms in Separation/ directory

**Timing**: 5 hours

**Depends on**: none (Phases 1-5 completed in v6; Tasks 6.1-6.6 completed in v6)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `abstract_snce`, `abstract_untl_identity_on_U_free`, `abstract_untl_preserves_separated`, `no_S_nested_in_U_separable`, `no_U_nested_in_S_separable`; replace `multi_U_formula_separable` shortcut
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- add junction depth decrease lemmas
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 8 axioms with theorems

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty (excluding comments)
- `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns empty

---

### Phase 7: Complete Theorem 9.3.1 -- Quantifier Cases with WF Induction [IN PROGRESS]

**Goal**: Close the 4 sorries in ExpressiveCompleteness.lean (the `.all` and `.ex` quantifier cases of `expressiveness_fixed_atomMap`, 2 pairs at lines 667 and 685).

**Note**: This phase is being worked on by a separate implementation agent. It is included here for completeness and dependency tracking. The Critic teammate confirmed Phase 7 is fully independent of Phase 6 -- the quantifier cases operate on `extSignature` types and do not depend on the temporal closure axiom machinery.

**Strategy**: Use well-founded induction on `qdepth` (quantifier depth). The quantifier case recurses at `extSignature sig` (different type) with `reduceElimLast` reducing qdepth by 1. Apply the atom-elimination pipeline: case-split over `Fintype (sig.preds -> Bool)` for const_at_ref, level-aware substitution for lt_ref/gt_ref using purity lemmas.

**Tasks**:
- [ ] Task 7.1: Restructure `expressiveness_fixed_atomMap` for WF induction on qdepth (~80 LOC)
- [ ] Task 7.2: Prove `reduceElimLast_correct` (~100 LOC)
- [ ] Task 7.3: Prove `extAtomMap_injective` (~40 LOC)
- [ ] Task 7.4: Define `elimExtAtoms` level-aware substitution (~50 LOC)
- [ ] Task 7.5: Prove `elimExtAtoms_correct` (~150 LOC)
- [ ] Task 7.6: Implement case-split assembly (~100 LOC)
- [ ] Task 7.7: Close `.ex` case (~80 LOC)
- [ ] Task 7.8: Close `.all` case via negation (~40 LOC)
- [ ] Task 7.9: Verify `lake build` passes with 0 sorry in ExpressiveCompleteness.lean

**Timing**: 5 hours

**Depends on**: none (independent of Phase 6; uses `all_properly_separable` which will be available once Phase 6 completes, but the bulk of the work can proceed in parallel)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- restructure for WF induction, implement atom elimination, close sorries

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- `separation_implies_expressiveness` and `US_expressively_complete_over_Z` compile cleanly

---

### Phase 8: Final Integration and Verification [NOT STARTED]

**Goal**: Full end-to-end verification that the proof chain is complete and axiom-free.

**Tasks**:
- [ ] Task 8.1: Run `lake build` and verify clean build with no warnings
- [ ] Task 8.2: Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify empty output
- [ ] Task 8.3: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` and verify empty output
- [ ] Task 8.4: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean (dead code)
- [ ] Task 8.5: Verify `US_expressively_complete_over_Z` has no axioms in its transitive closure (use `lean_verify` MCP tool)
- [ ] Task 8.6: Update documentation comments in SeparationThm.lean and ExpressiveCompleteness.lean to reflect axiom-free status
- [ ] Task 8.7: Clean up any unused imports or dead code introduced during development

**Timing**: 1 hour

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- update doc comments
- Possibly remove unused helpers from TemporalClosure.lean or Hierarchy.lean

**Verification**:
- All checks from Tasks 8.1-8.5 pass
- `lake build` produces no warnings related to Separation/ or ExpressiveCompleteness

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns empty
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `US_expressively_complete_over_Z` verified axiom-free via `lean_verify`
- [ ] `no_S_nested_in_U_separable` verified axiom-free via `lean_verify`

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/04_junction-depth-plan.md` (this file, v7)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- `abstract_snce`, `no_S_nested_in_U_separable`, `no_U_nested_in_S_separable`; `multi_U_formula_separable` shortcut replaced
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- junction depth decrease lemmas
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 8 axioms replaced with theorems
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- 4 sorries closed (Phase 7)

## Rollback/Contingency

- **Phase 6 primary fallback**: If junction-depth induction step proves unexpectedly difficult for specific case patterns, use GHR94 Ch 10.3 Dedekind formula specialization for Z (K+=K-=T, G+-=bot) as backup. This produces correct explicit Case 5-8 formulas (~200-350 LOC per case) but higher total LOC.
- **Phase 6 partial fallback**: If proper separability axioms resist elimination but weak axioms are eliminated, keep 4 proper axioms (half the current 8). The weak axioms are the critical ones for the separation theorem.
- **Phase 7 fallback**: If WF induction on qdepth has universe issues, attempt universe-polymorphic reformulation. If atom elimination is intractable, the 4 sorries remain but separation theorem is fully proved.
- **Priority if time-constrained**: Phase 6 (axiom elimination) > Phase 7 (sorry closure) > Phase 8 (cleanup). Phase 6 alone validates the entire separation theorem proof chain.
- **Git safety**: Each task within Phase 6 should be committed individually so that partial progress is preserved if a later task fails.
