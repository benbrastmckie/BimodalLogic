# Implementation Plan: Task #157 (v6) -- expand_temporal + Junction-Depth Induction

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [IN PROGRESS]
- **Effort**: 14 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/03_team-research.md (Phase 6 breakthrough), reports/01-07 (prior)
- **Artifacts**: plans/03_hierarchy-first-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v6 incorporates the breakthrough from team research (Report 03): the Phase 6 blocker is resolved by preprocessing with `expand_temporal` to eliminate primitive `all_past`/`all_future` constructors before junction-depth induction. After expansion, formulas use only `{atom, bot, imp, snce, untl, box}`, where `junction_depth = 0` genuinely implies `is_syntactically_separated = true`. Duality via `swap_temporal` halves the proof: prove the `snce` direction, derive `untl` automatically.

Phase 7 uses well-founded induction on `qdepth` (not structural recursion) to handle the quantifier cases that recurse at `extSignature` (different type). The atom-elimination pipeline uses a case-split over `Fintype (sig.preds -> Bool)` and level-aware substitution.

Definition of done: `lake build` passes with zero axioms in SeparationThm.lean and zero sorry in ExpressiveCompleteness.lean.

### Research Integration

Report 03 (team research) identified:
1. `junction_depth = 0` does NOT imply separated when `all_past`/`all_future` are primitive (counterexample: `all_past (untl a b)` has JD=0 but is not separated)
2. Fix: `expand_temporal` replaces `all_past phi` with `neg (snce (neg phi) top)` and `all_future phi` with `neg (untl (neg phi) top)` -- valid on integer time
3. After expansion, JD=0 genuinely implies separated in the `{atom, bot, imp, snce, untl, box}` fragment
4. Duality halves Phase 6 work: prove `snce_separable`, derive `untl_separable` via `swap_temporal`
5. Phase 7 needs WF induction on qdepth, not structural recursion

### Prior Plan Reference

Plan v5 (7 phases): Phases 1-5 completed successfully (0 axioms in Eliminations.lean, hierarchy infrastructure built). Phase 6 was blocked by the false assumption that JD=0 implies separated with primitive `all_past`/`all_future`. Phase 7 was partially complete (quantifier infrastructure built, 2 sorries remain). The `expand_temporal` preprocessing strategy from Report 03 resolves Phase 6's blocker entirely. Effort calibration from v5: Phase 5 took less effort than estimated (used `all_separable` directly); Phase 6 blocker consumed ~20 hours of failed attempts.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `all_separable` and `all_properly_separable` without axioms, eliminating all 8 axioms from SeparationThm.lean
- Complete `separation_implies_expressiveness` in ExpressiveCompleteness.lean (close 2 sorries)
- Achieve zero-axiom, zero-sorry `lake build` for the full Separation/ + ExpressiveCompleteness stack

**Non-Goals**:
- Proving DualEliminations.lean (dead code, contains independent sorries)
- Performance optimization of proof terms
- Alternative proof approaches (Reynolds pipeline, EF games)
- Eliminating axioms outside the Separation/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `expand_temporal_equiv` proof is harder than expected (recursion through snce/untl subterms) | M | L | Each recursive case follows pattern of `replace_box_equiv`; research report confirms approach |
| `expand_jd_zero_separated` base case has edge cases we missed | M | L | Machine-verified counterexample from Report 03 covers the critical case; after expansion no all_past/all_future remain |
| WF induction on qdepth requires universe-polymorphic termination argument | M | M | Use `WellFoundedRelation` on Nat with `qdepth` as measure; MonadicFormula types are in same universe |
| Case-split over `Fintype (sig.preds -> Bool)` has Fintype instance issues | M | M | `Fintype` instance for `A -> Bool` is standard Mathlib (`Pi.instFintype`); verify with lean_hover_info |
| Duality derivation of `untl_separable` requires `swap_temporal` to commute with `expand_temporal` | L | M | Research confirms swap preserves junction_depth; may need separate `expand_temporal_swap` lemma (~30 LOC) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5 | -- (COMPLETED) |
| 2 | 6 | 1-5 |
| 3 | 7 | 6 |
| 4 | 8 | 6, 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Purity Predicates and Adjust Cases 2-4 [COMPLETED]

Defined `is_future_only`, `is_past_only`, `is_properly_separated`, `is_properly_separable`. Proved duality and closure. Added proper separability axioms. Updated ExpressiveCompleteness.lean.

---

### Phase 2: Lemma 10.2.4 -- Normal Form Reduction to 8 Cases [COMPLETED]

Proved that any formula `S(C, F)` with single U-formula type U(A,B) can be reduced to a boolean combination of 8 standard case patterns. Implemented as `lemma_10_2_4` in NormalForm.lean.

---

### Phase 3: Lemma 10.2.5 -- Single-U Elimination by S-Nesting Induction [COMPLETED]

Proved single-U formula separability using structural induction with `snce_separable` temporal closure axiom for the snce case. Defined `has_single_U_type` predicate.

---

### Phase 4: Lemma 10.2.6 -- Multi-U Induction on Count [COMPLETED]

Built multi-U elimination infrastructure: `abstract_untl_correct`, `abstract_untl_makes_U_free`, `abstract_untl_count_le`, `abstract_untl_count_zero_of_single`. Proof uses `all_separable` at this stage.

---

### Phase 5: Prove Cases 5-8 Using Hierarchy (Eliminate Eliminations.lean Axioms) [COMPLETED]

Replaced 4 axioms in Eliminations.lean with proofs via `all_separable` in NormalForm.lean. Zero axioms remain in Eliminations.lean.

---

### Phase 6: Prove all_separable via expand_temporal + Junction-Depth Induction [NOT STARTED]

**Goal**: Eliminate all 8 axioms from SeparationThm.lean by proving `all_separable` and `all_properly_separable` without axioms. The key strategy is `expand_temporal` preprocessing + junction-depth induction + duality.

**Tasks**:
- [ ] Task 6.1: Define `expand_temporal : Formula -> Formula` that recursively replaces `all_past phi` with `neg (snce (neg phi) top)` and `all_future phi` with `neg (untl (neg phi) top)` (~30 LOC)
- [ ] Task 6.2: Prove `all_past_equiv_neg_snce : int_equiv (.all_past phi) (.neg (.snce (.neg phi) (.neg .bot)))` on Z (~60 LOC, uses integer density: for any s < t, either witness exists or all_past holds vacuously)
- [ ] Task 6.3: Prove `all_future_equiv_neg_untl : int_equiv (.all_future phi) (.neg (.untl (.neg phi) (.neg .bot)))` on Z (~60 LOC, symmetric to 6.2)
- [ ] Task 6.4: Prove `expand_temporal_equiv : int_equiv phi (expand_temporal phi)` by structural induction using 6.2 and 6.3 for the all_past/all_future cases (~50 LOC)
- [ ] Task 6.5: Prove `expand_has_no_all : expand_temporal phi` contains no `all_past`/`all_future` constructors (~30 LOC, structural induction on definition)
- [ ] Task 6.6: Prove `expand_jd_zero_separated : junction_depth (expand_temporal phi) = 0 -> is_syntactically_separated (expand_temporal phi) = true` -- in the `{atom, bot, imp, snce, untl, box}` fragment (no all_past/all_future), JD=0 means untl args are S-free and snce args are U-free (~80 LOC)
- [ ] Task 6.7: Prove `snce_separable_expanded` -- given `is_separable phi`, `is_separable psi`, expand their separated witnesses, form `snce`, apply junction-depth induction on expanded formula using Cases 1-8 from Eliminations.lean (~150 LOC)
- [ ] Task 6.8: Derive `untl_separable_expanded` from `snce_separable_expanded` via `swap_temporal` duality (~80 LOC, using `dual_separable` + `swap_no_U_nested_gives_no_S_nested` infrastructure)
- [ ] Task 6.9: Derive `all_past_separable` from `snce_separable_expanded` (since `all_past phi = neg (snce (neg phi) top)` is separable when phi is separable) (~30 LOC)
- [ ] Task 6.10: Derive `all_future_separable` from `untl_separable_expanded` (symmetric) (~30 LOC)
- [ ] Task 6.11: Replace 4 weak temporal closure axioms with proofs of `all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable` (~40 LOC, restructure theorem declarations from axiom to theorem)
- [ ] Task 6.12: Prove `all_properly_separable` without axioms -- prove proper versions of temporal closure using analogous argument with `is_properly_separable` + proper expansion equivalences (~80 LOC)
- [ ] Task 6.13: Remove 4 proper temporal closure axioms from SeparationThm.lean (~10 LOC, delete axiom declarations)
- [ ] Task 6.14: Verify `lake build` passes with 0 axioms in SeparationThm.lean

**Timing**: 6 hours

**Depends on**: Phases 1-5 (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- add `expand_temporal`, equivalence proofs, JD-zero lemma
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace 8 axioms with theorems, reprove `all_separable` and `all_properly_separable`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- possibly add helper predicates for `has_no_all_past_future`

**Verification**:
- `lake build` passes
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns empty (Eliminations already clean)

---

### Phase 7: Complete Theorem 9.3.1 -- Quantifier Cases with WF Induction [NOT STARTED]

**Goal**: Close the 2 sorries in ExpressiveCompleteness.lean (the `.all` and `.ex` quantifier cases of `expressiveness_fixed_atomMap`).

**Strategy**: Use well-founded induction on `qdepth` (quantifier depth). The quantifier case recurses at `extSignature sig` (different type) with `reduceElimLast` reducing qdepth by 1. Then apply the atom-elimination pipeline: case-split over `Fintype (sig.preds -> Bool)` for const_at_ref, level-aware substitution for lt_ref/gt_ref using purity lemmas.

**Tasks**:
- [ ] Task 7.1: Restructure `expressiveness_fixed_atomMap` to use WF induction on qdepth via `Nat.strongRecOn` or `termination_by` with explicit measure (~80 LOC refactoring)
- [ ] Task 7.2: Prove `reduceElimLast_correct` -- semantic correctness relating eval at (z,t) in sig to eval at z in extSignature with extIntStruct (~100 LOC, Fin arithmetic for env management)
- [ ] Task 7.3: Prove `extAtomMap_injective` -- injectivity of the extended atom map (~40 LOC, using distinctness of atom name encoding)
- [ ] Task 7.4: Define `elimExtAtoms` -- level-aware substitution function that walks a properly separated formula and substitutes differently at present/past/future levels (~50 LOC)
- [ ] Task 7.5: Prove `elimExtAtoms_correct` -- for each level (present, past-only, future-only), the substitution preserves truth using `past_only_subst_correct`/`future_only_subst_correct` at time s (~150 LOC)
- [ ] Task 7.6: Implement case-split assembly -- iterate over `Fintype (sig.preds -> Bool)`, build guard formulas, prove exactly one guard is True for each (M, t), prove the selected branch gives correct answer (~100 LOC)
- [ ] Task 7.7: Close `.ex` case by assembling: reduceElimLast_correct + IH at extSignature + q_exists + proper_separation + elimExtAtoms + case-split (~80 LOC)
- [ ] Task 7.8: Close `.all` case by deriving from `.ex` via negation: `forall z. phi(z) <-> not (exists z. not phi(z))` (~40 LOC)
- [ ] Task 7.9: Verify `lake build` passes with 0 sorry in ExpressiveCompleteness.lean

**Timing**: 5 hours

**Depends on**: Phase 6 (all_properly_separable proved without axioms, needed for the separation step)

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
- [ ] Task 8.2: Run `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify empty output
- [ ] Task 8.3: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` and verify empty output
- [ ] Task 8.4: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` and verify only DualEliminations.lean (dead code)
- [ ] Task 8.5: Verify `US_expressively_complete_over_Z` has no axioms in its transitive closure (use `lean_verify` MCP tool)
- [ ] Task 8.6: Update documentation comments in SeparationThm.lean and ExpressiveCompleteness.lean to reflect axiom-free status
- [ ] Task 8.7: Clean up any unused imports or dead code introduced during development

**Timing**: 1 hour

**Depends on**: Phases 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- update doc comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- update doc comments
- Possibly remove unused helpers from TemporalClosure.lean

**Verification**:
- All checks from Tasks 8.1-8.5 pass
- `lake build` produces no warnings related to Separation/ or ExpressiveCompleteness

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `grep -rn "axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns empty
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] `US_expressively_complete_over_Z` verified axiom-free via `lean_verify`

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/03_hierarchy-first-plan.md` (this file, v6)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- 8 axioms removed
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- expand_temporal + proofs
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- 2 sorries closed
- Possibly modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- helper predicates

## Rollback/Contingency

- **Phase 6 fallback**: If `expand_temporal` approach fails (unlikely given machine-verified counterexample), retain 4 weak temporal closure axioms and attempt direct JD induction on the expanded fragment only for snce/untl (4 axioms instead of 8).
- **Phase 6 partial**: If proper separability axioms resist elimination, keep the 4 proper axioms but eliminate the 4 weak ones. Net: 4 axioms (half the current 8).
- **Phase 7 fallback**: If WF induction on qdepth has universe issues, attempt universe-polymorphic reformulation of `expressiveness_fixed_atomMap`. If atom elimination is intractable, the 2 sorries remain but separation theorem is fully proved.
- **Priority if time-constrained**: Phase 6 (axiom elimination) > Phase 7 (sorry closure) > Phase 8 (cleanup). Phase 6 alone validates the entire separation theorem proof chain.
