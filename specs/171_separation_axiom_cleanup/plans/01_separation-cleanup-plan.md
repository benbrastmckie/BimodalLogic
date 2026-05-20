# Implementation Plan: Separation Axiom Cleanup

- **Task**: 171 - Eliminate remaining separation axioms and clean up post-task-157 artifacts
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: Task 157 (completed)
- **Research Inputs**: reports/02_post-157-analysis.md
- **Artifacts**: plans/01_separation-cleanup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 157 eliminated 4 temporal closure axioms from the syntactic separation hierarchy (`is_separable`). Five axioms remain in SeparationThm.lean for the proper separation predicate (`is_properly_separable`) and atom preservation. Research discovered that `is_syntactically_separated` and `is_properly_separated` are provably equal for all formulas, reducing Group A (4 proper separation temporal closure axioms) from 6-10 hours to 1-2 hours. Group B (atom preservation axiom) requires strengthening the hierarchy to track `formula_atoms` through the separation procedure (8-10 hours). Group C (cleanup of 22+ stale comments and 2 dead wrappers) is straightforward text editing. Definition of done: zero axioms remain in SeparationThm.lean, `lake build` passes, all stale Phase 6 references are updated.

### Research Integration

Research report `reports/02_post-157-analysis.md` provided the key insight:
- `is_S_free = is_future_only` and `is_U_free = is_past_only` at the 6-constructor `Formula` level
- This makes `is_syntactically_separated = is_properly_separated` provable by structural induction
- 2 of 5 axioms (`all_past_properly_separable`, `all_future_properly_separable`) are dead code
- 2 used axioms (`untl_properly_separable`, `snce_properly_separable`) become trivial one-liners
- `proper_separation_preserves_atoms` requires tracking atoms through the full hierarchy (Option A)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation requested for this task.

## Goals & Non-Goals

**Goals**:
- Eliminate all 5 remaining axioms from SeparationThm.lean (lines 212-270)
- Prove predicate equivalence `syn_sep_eq_proper_sep` in Defs.lean
- Prove `proper_separation_preserves_atoms` as a theorem via hierarchy strengthening
- Delete 2 dead wrapper functions from Hierarchy.lean
- Update 22+ stale comments across Hierarchy.lean, SeparationThm.lean, Eliminations.lean, TemporalClosure.lean, DualEliminations.lean
- Maintain passing `lake build` at each phase boundary

**Non-Goals**:
- Modifying ExpressiveCompleteness.lean (not in build target, uses the axiom but works with the theorem replacement)
- Refactoring the separation hierarchy architecture (only eliminating axioms)
- Changing the `is_separable` / `is_properly_separable` API surface (signatures preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Predicate equivalence proof fails to compile | H | L | Already verified via `lean_run_code` in research; structural induction is straightforward |
| Atom tracking through `abstract_untl`/`subst_formula` is harder than estimated | H | M | Each sub-lemma is independently verifiable; can mark phase [PARTIAL] and resume |
| `Set`-based atom reasoning creates proof complexity | M | M | Use `Set.mem_union`, `Set.subset_union_left`, etc.; fall back to `Finset` conversion if needed |
| Stale comments missed in inventory | L | M | Run `grep -rn "Phase 6\|axiom" Separation/` after cleanup to catch stragglers |
| `lake build` regression from comment edits | L | L | Comments are non-semantic; build after each file edit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Predicate Equivalence Lemmas [COMPLETED]

**Goal**: Prove `is_S_free = is_future_only`, `is_U_free = is_past_only`, and `is_syntactically_separated = is_properly_separated` as theorems.

**Tasks**:
- [x] Add `s_free_eq_future_only` theorem to Defs.lean (structural induction on Formula)
- [x] Add `u_free_eq_past_only` theorem to Defs.lean (structural induction on Formula)
- [x] Add `syn_sep_eq_proper_sep` theorem to Defs.lean (uses the two lemmas above at `.untl` and `.snce` cases)
- [x] Add `separable_iff_properly_separable` corollary connecting `is_separable` and `is_properly_separable`
- [x] Run `lake build` to verify

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- add 3-4 theorems after `is_properly_separable` definition (after line ~308)

**Verification**:
- `lake build` passes
- `#check syn_sep_eq_proper_sep` shows correct type

---

### Phase 2: Eliminate Group A Axioms (1-4) [COMPLETED]

**Goal**: Replace all 4 proper separation temporal closure axioms with theorems, simplify `all_properly_separable`, and delete dead code.

**Tasks**:
- [x] Add `all_formulas_properly_separable` theorem to SeparationThm.lean using `all_formulas_separable` + `syn_sep_eq_proper_sep`
- [x] Delete dead axiom `all_past_properly_separable` *(deviation: altered -- converted to theorem with unused arg instead of deleting, to preserve API)*
- [x] Delete dead axiom `all_future_properly_separable` *(deviation: altered -- converted to theorem with unused arg instead of deleting, to preserve API)*
- [x] Replace `axiom untl_properly_separable` (lines 222-224) with `theorem` proved via `all_formulas_properly_separable _`
- [x] Replace `axiom snce_properly_separable` (lines 228-230) with `theorem` proved via `all_formulas_properly_separable _`
- [x] Simplify `all_properly_separable` body to use `all_formulas_properly_separable phi` directly (removing structural induction)
- [x] Run `lake build` to verify zero axiom regressions

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- lines 197-270: rewrite proper separation section

**Verification**:
- `lake build` passes
- `#print axioms all_properly_separable` shows no axioms (or only `propext`, `Classical.choice`, etc.)
- `#print axioms proper_separation_theorem_int` shows no custom axioms
- `grep -rn "^axiom" SeparationThm.lean` returns only `proper_separation_preserves_atoms`

---

### Phase 3: Prove Atom Preservation (Group B) [NOT STARTED]

**Goal**: Prove `proper_separation_preserves_atoms` as a theorem by strengthening the hierarchy to track `formula_atoms` through the separation procedure.

**Tasks**:
- [ ] Prove `formula_atoms_replace_box_with_top_subset`: `formula_atoms (replace_box_with_top phi) ⊆ formula_atoms phi` (structural induction in TemporalClosure.lean or FormulaOps.lean)
- [ ] Prove `formula_atoms_expand_temporal_eq`: `formula_atoms (expand_temporal phi) = formula_atoms phi` (structural induction in TemporalClosure.lean)
- [ ] Prove `formula_atoms_subst_formula_subset`: `formula_atoms (subst_formula psi p r) ⊆ (formula_atoms psi \ {p}) ∪ formula_atoms r` (structural induction in FormulaOps.lean)
- [ ] Prove `formula_atoms_abstract_untl_subset`: `formula_atoms (abstract_untl phi A B p) ⊆ formula_atoms phi ∪ {p}` (structural induction in Hierarchy.lean)
- [ ] Prove case output atom containment for case1_psi through case8_psi elimination cases (in Eliminations.lean or NormalForm.lean)
- [ ] Strengthen `subst_in_separated_separable` (or create `subst_in_separated_separable_atoms` variant) to return atom-preserving witnesses
- [ ] Strengthen `no_S_nested_sep` (or create atom-tracking variant) to return `formula_atoms psi ⊆ formula_atoms phi`
- [ ] Strengthen `all_formulas_separable_aux` (or create `all_formulas_separable_aux_atoms` variant) to thread atom tracking through the JD/structural double induction
- [ ] Create `all_formulas_separable_atoms`: `∃ psi, is_syntactically_separated psi ∧ int_equiv phi psi ∧ formula_atoms psi ⊆ formula_atoms phi`
- [ ] Replace `axiom proper_separation_preserves_atoms` with theorem using `all_formulas_separable_atoms` + `syn_sep_eq_proper_sep`
- [ ] Run `lake build` to verify

**Timing**: 9 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` -- add `formula_atoms_subst_formula_subset`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- add `formula_atoms_replace_box_with_top_subset`, `formula_atoms_expand_temporal_eq`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `formula_atoms_abstract_untl_subset`, strengthen hierarchy functions or create atom-tracking variants
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- replace final axiom with theorem

**Verification**:
- `lake build` passes
- `grep -rn "^axiom" SeparationThm.lean` returns no results
- `#print axioms proper_separation_preserves_atoms` shows no custom axioms

---

### Phase 4: Cleanup Stale Comments and Dead Wrappers (Group C) [NOT STARTED]

**Goal**: Update all stale comments referencing Phase 6, axiom status, or outdated architecture. Delete dead backward-compat wrappers.

**Tasks**:
- [ ] **Hierarchy.lean** -- Update header comment (lines 19-20): "temporal closure axioms" -> "temporal closure theorems, proved in task 157"
- [ ] **Hierarchy.lean** -- Update line 102-104: "`snce_separable` (temporal closure axiom)" -> "`snce_separable` (temporal closure theorem)"
- [ ] **Hierarchy.lean** -- Update line 160-161: "These used the `snce_separable` axiom" -> clarify these were replaced by oracle-free versions
- [ ] **Hierarchy.lean** -- Update line 177-179: remove "In Phase 6..." text
- [ ] **Hierarchy.lean** -- Update line 673: simplify comment about current state
- [ ] **Hierarchy.lean** -- Update line 803: remove "Key theorem for Phase 6B" reference
- [ ] **Hierarchy.lean** -- Delete dead wrapper `no_S_nested_in_U_separable_noax` (lines 2946-2951)
- [ ] **Hierarchy.lean** -- Delete dead wrapper `no_S_nested_in_U_separable_direct` (lines 3624-3627)
- [ ] **SeparationThm.lean** -- Update header comment (lines 15-16): correct "consolidated in Eliminations.lean" to "now in Hierarchy.lean as all_formulas_separable"
- [ ] **SeparationThm.lean** -- Rewrite comment block lines 64-83: temporal closure is now fully proved, not axiomatized
- [ ] **SeparationThm.lean** -- Remove or rewrite comment lines 109-122: axiom soundness no longer relevant
- [ ] **SeparationThm.lean** -- Rewrite proper separation section comment (lines 197-208): axioms are now theorems
- [ ] **SeparationThm.lean** -- Update atom preservation comment (lines 260-267): now a theorem, not axiom
- [ ] **TemporalClosure.lean** -- Update lines 23-27: "temporal closure axioms state that" -> "temporal closure theorems show that"
- [ ] **TemporalClosure.lean** -- Remove "Phase 6 blocker" text at line 34-35
- [ ] **TemporalClosure.lean** -- Remove "Phase 6 goal" at line 276
- [ ] **Eliminations.lean** -- Update lines 786-795: clarify Cases 5-8 architecture
- [ ] **Eliminations.lean** -- Update lines 893-900: update `all_separable` reference
- [ ] **DualEliminations.lean** -- Update line 9: clarify `all_separable` location
- [ ] Run `grep -rn "Phase 6\|axiom.*separable\|temporal closure axiom" Separation/` to catch any remaining stale references
- [ ] Run `lake build` to verify no breakage

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- comments + delete 2 dead wrappers
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` -- comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- comments
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` -- comment

**Verification**:
- `lake build` passes
- `grep -rn "Phase 6" Separation/` returns no results
- `grep -rn "temporal closure axiom" Separation/` returns no results (should say "theorem" everywhere)

---

### Phase 5: Final Verification and Axiom Audit [NOT STARTED]

**Goal**: Comprehensive verification that all axioms are eliminated and the build is clean.

**Tasks**:
- [ ] Run `lake build` for full project build
- [ ] Run `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` to verify zero axioms in Separation module
- [ ] Run `#print axioms Bimodal.Metalogic.WeakCanonical.Separation.proper_separation_theorem_int` to confirm only Lean/Mathlib axioms
- [ ] Run `#print axioms Bimodal.Metalogic.WeakCanonical.Separation.proper_separation_preserves_atoms` to confirm only Lean/Mathlib axioms
- [ ] Verify `ExpressiveCompleteness.lean` type-checks if it imports the separation module (not in build target, but should still work)
- [ ] Run final `grep -rn "Phase 6\|axiom.*separable\|temporal closure axiom" Separation/` for stale references

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` passes with zero warnings in Separation module
- Zero custom axioms in Separation module
- All stale references eliminated

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns empty (zero axioms)
- [ ] `#print axioms all_properly_separable` shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] `#print axioms proper_separation_preserves_atoms` shows only standard Lean axioms
- [ ] No "Phase 6" references remain in `Separation/` directory
- [ ] No "temporal closure axiom" references remain (all should say "theorem")
- [ ] `ExpressiveCompleteness.lean` compiles against the updated SeparationThm.lean

## Artifacts & Outputs

- `specs/171_separation_axiom_cleanup/plans/01_separation-cleanup-plan.md` (this plan)
- `specs/171_separation_axiom_cleanup/reports/02_post-157-analysis.md` (existing research)
- Modified files:
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean`

## Rollback/Contingency

- Git revert to pre-task-171 commit if any phase introduces regressions
- Phase 3 (atom preservation) is the highest-risk phase: if it proves intractable, phases 1-2 and 4 still deliver value (4 of 5 axioms eliminated, all cleanup done). The remaining axiom can be deferred to a follow-up task.
- If `Set`-based atom reasoning is too complex, consider converting `formula_atoms` to `Finset` for decidable membership, or using a simpler statement with `Decidable` instances.
