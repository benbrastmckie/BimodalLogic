# Phase 5 Handoff: Case 5-8 Axiom Elimination

**Date**: 2026-05-17
**Session**: sess_1779003456_c5b522
**Phase**: 5 of 7
**Status**: COMPLETED

## What Was Done

Eliminated all 4 Case 5-8 axioms (`elim_case_5_axiom`, `elim_case_6_axiom`, `elim_case_7_axiom`, `elim_case_8_axiom`) from Eliminations.lean.

## Key Insight

`all_separable` in SeparationThm.lean is proved using structural induction + 4 temporal closure axioms. It does NOT depend on Cases 5-8 axioms. Therefore, Cases 5-8 can be trivially proved by applying `all_separable _` to the target formula.

## Import Restructuring

- NormalForm.lean now imports SeparationThm.lean (in addition to Eliminations.lean)
- This creates a diamond import (SeparationThm imported both directly and via Eliminations), which is fine
- No circular imports
- `case5_separable` through `case8_separable` in NormalForm.lean now use `all_separable _` directly

## Current State

- **Axioms remaining**: 8 (all in SeparationThm.lean: 4 weak temporal closure + 4 proper temporal closure)
- **Axioms in Eliminations.lean**: 0
- **Sorries in modified files**: 0 (DualEliminations.lean has 8 sorries but is dead code)
- **Build**: passes

## Next Action

Phase 6: Prove `all_separable` via junction-depth induction, eliminating the 8 temporal closure axioms from SeparationThm.lean.
