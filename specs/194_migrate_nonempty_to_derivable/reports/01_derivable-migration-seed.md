# Seed Research Report: Migrate Nonempty DerivationTree to Derivable

**Task**: #194 — Migrate Nonempty (DerivationTree ...) patterns to Derivable
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

Task 181 introduced `Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)` as a named wrapper for the existing `Nonempty (DerivationTree ...)` pattern. The codebase already uses this unwrapped pattern in 56 sites across 16 active files, primarily in Metalogic/. Migrating these to use `Derivable` improves readability, enables future aesop/simp automation on those sites, and establishes a consistent API surface for Prop-valued derivability throughout the project.

This migration is mechanical but non-trivial: it touches theorem statements, definition types, and proof terms across the most sensitive part of the codebase (completeness, decidability, canonical model construction). Each site needs careful verification that the migration preserves definitional equality and doesn't break downstream consumers.

## Current State

56 occurrences of `Nonempty (DerivationTree ...)` or `Nonempty (Bimodal.ProofSystem.DerivationTree ...)` across 16 active files (excluding Derivable.lean itself and Boneyard/):

| File | Count | Category |
|------|-------|----------|
| Metalogic/BXCanonical/Completeness.lean | 8 | Completeness theorem statements |
| Metalogic/BXCanonical/Chronicle/PointInsertion.lean | 8 | Chronicle construction |
| Metalogic/Core/RestrictedMCS.lean | 7 | MCS properties |
| Metalogic/Decidability/FMP/FMP.lean | 5 | Finite model property |
| Metalogic/Algebraic/ParametricCompleteness.lean | 5 | Algebraic completeness |
| Metalogic/Core/MaximalConsistent.lean | 4 | Consistency definition |
| Metalogic/BXCanonical/Chronicle/RRelation.lean | 4 | Relation construction |
| Metalogic/Bundle/Construction.lean | 3 | Bundle (has local ContextDerivable) |
| Metalogic/Decidability/FMP/DiscreteFMP.lean | 2 | Discrete FMP |
| Metalogic/Decidability/FMP/DenseFMP.lean | 2 | Dense FMP |
| Metalogic/Decidability/Correctness.lean | 2 | Decidability correctness |
| Metalogic/Core/MCSProperties.lean | 2 | MCS derived properties |
| Metalogic/Decidability/FMP/ClosureMCS.lean | 1 | Closure MCS |
| Metalogic/ConservativeExtension/Lifting.lean | 1 | Conservative extension |
| Metalogic/Algebraic/LindenbaumQuotient.lean | 1 | Lindenbaum algebra |
| Metalogic/Algebraic/AlgebraicCompleteness.lean | 1 | Algebraic completeness |

### Special cases

- **MaximalConsistent.lean**: Contains `def Consistent (G : Context) : Prop := ¬Nonempty (DerivationTree G Formula.bot)`. This is definitionally equal to `¬Derivable G Formula.bot` — migration is safe but changes the canonical definition.
- **Bundle/Construction.lean**: Contains `def ContextDerivable (G : List Formula) (p : Formula) : Prop := Nonempty (Bimodal.ProofSystem.DerivationTree G p)` — a local duplicate of Derivable. Should be replaced by importing `Derivable` directly.

## Proposed Approach

### Phase 1: Import Derivable in all target files
Add `import Bimodal.ProofSystem.Derivable` (or rely on transitive import via `ProofSystem`) to each file.

### Phase 2: Mechanical replacement
Replace all `Nonempty (DerivationTree G p)` with `Derivable G p` and all `¬Nonempty (DerivationTree G Formula.bot)` with `¬Derivable G Formula.bot` (or use `Consistent` where appropriate).

### Phase 3: Remove local ContextDerivable
Replace `ContextDerivable` in Bundle/Construction.lean with `Derivable`.

### Phase 4: Verify build
Run `lake build` to confirm zero errors. The migration should be entirely definitional — no proof changes needed since `Derivable` unfolds to `Nonempty (DerivationTree ...)`.

## Key Questions for Research Phase

1. Are there any sites where `Nonempty (DerivationTree ...)` is used in a way that does NOT correspond to `Derivable` (e.g., with non-standard context types)?
2. Does replacing `Consistent` definition body with `¬Derivable G Formula.bot` cause any `rfl` or `unfold` proof breakage downstream?
3. Are there import cycle risks from adding `Derivable` imports to Metalogic/ files?
4. Should the `Consistent` definition in MaximalConsistent.lean be changed to reference `Derivable`, or kept as-is (they're definitionally equal)?

## Estimated Scope

- **Effort**: small (3-5 hours)
- **Files**: 16 files + 1 deletion (ContextDerivable)
- **Risk**: Low — purely definitional, no proof changes expected

## Dependencies

- **Depends on**: 181 (Derivable wrapper — COMPLETED)
- **Should run after**: 161 (namespace rename) — otherwise migration would need to be redone
- **Blocks**: none directly, but improves readability for all subsequent work

## References

- Task 181 research: `specs/181_derivable_prop_wrapper/reports/01_derivable-prop-wrapper.md` (Section 5.2)
- Task 181 implementation: `Theories/Bimodal/ProofSystem/Derivable.lean`
- Existing ContextDerivable: `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- Existing Consistent: `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
