# Implementation Summary: Task #157

**Completed**: 2026-05-18
**Mode**: Team Implementation (2 max concurrent teammates)
**Status**: PARTIAL (sorry elimination complete, axiom elimination blocked)

## Wave Execution

### Wave 1 (Phases 7A + 6A, parallel)
- Phase 7A: [COMPLETED] (phase-7a) -- Atom containment helper lemmas + closed 2 sorries
- Phase 6A: [COMPLETED] (phase-6a) -- abstract_snce infrastructure + junction-depth lemmas

### Wave 2 (Phases 7B + 6B, parallel)
- Phase 7B: [COMPLETED] (phase-7b, phase-7b-fix) -- elimExtFromSep_correct + closed atom_elim_correct sorry
- Phase 6B: [BLOCKED] (phase-6b) -- GHR94 Cases 5-8 incorrect for integer time

### Waves 3-4 (Phases 6C, 8)
- Phase 6C: [BLOCKED] -- Depends on Phase 6B
- Phase 8: [BLOCKED] -- Depends on Phase 6C

## Key Achievement

**ExpressiveCompleteness.lean is now SORRY-FREE.** The theorem `US_expressively_complete_over_Z` (Reynolds Theorem 5) is fully proved without sorry. This was the highest-value goal of the task.

## Changes Made

### ExpressiveCompleteness.lean (+978 lines)
- `formula_atoms_subst_formula`: atom set under single substitution
- `formula_atoms_applySubsts_subset`: atom set under substitution list
- `formula_atoms_elimExtFromSep_subset`: output atoms ⊆ range atomMap
- `formula_atoms_guardFormula_subset`: guard formula atoms ⊆ range atomMap
- `formula_atoms_foldl_or_subset`: atoms of foldl or
- `formula_atoms_quantElimFormula_subset`: quantifier elimination atoms ⊆ range atomMap
- Closed 2 atom containment sorries (Phase 7A)
- `elimExtFromSep_correct`: core semantic correctness theorem (all 8 formula cases)
- Closed `quantElimFormula_correct_iff` sorry (Phase 7B)

### Hierarchy.lean (+418 lines)
- `abstract_snce`: dual of `abstract_untl`, replaces S-nodes with atoms
- `abstract_snce_correct`: semantic roundtrip theorem
- 4 preservation lemmas (U-free, S-free, no-U-nested, makes-S-free)
- 10+ junction-depth monotonicity lemmas (all constructors, both sides)
- Junction-depth decrease lemmas for abstract_snce inside untl arguments
- `snce_achieves_max_jdU`, `snce_inside_U_arg` predicates

## Phase 6B Blocker

GHR94 Cases 5-8 of Lemma 10.2.3 are INCORRECT for integer (discrete) time. The formula assumes U-chain B-coverage propagates to t, which fails on integers due to vacuous empty intervals. This creates a circular dependency: `junction_depth_separable` needs the axioms it's meant to eliminate. Documented in `Eliminations.lean:460-494`.

**Options for unblocking** (requires new research round):
1. Find correct Case 5-8 equivalents for integer time
2. Find alternative proof of `no_S_nested_in_U → is_separable` bypassing Cases 5-8
3. Find direct proof of temporal closure axioms without Cases 5-8

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` -- sorry-free
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- infrastructure

## Verification

- Build: Pass (1647 jobs, zero errors)
- Sorry count in ExpressiveCompleteness.lean: 0
- Axioms in SeparationThm.lean: 9 (unchanged, blocked)

## Team Metrics

| Metric | Value |
|--------|-------|
| Total phases | 6 |
| Phases completed | 3 (7A, 6A, 7B) |
| Phases blocked | 3 (6B, 6C, 8) |
| Waves executed | 2 |
| Max parallelism | 2 |
| Debugger invocations | 0 |
| Total teammates spawned | 5 |
