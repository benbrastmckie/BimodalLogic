# Implementation Summary: Rename Metalogical Theorems to Standard Names

- **Task**: 166
- **Plan**: specs/166_rename_metalogical_theorems_standard_names/plans/01_metalogical-naming-hygiene.md
- **Status**: Implemented (4 phases completed)

## Changes

### Phase 1: Rename Completeness Theorems and Countermodels
- Renamed `bx_completeness` to `completeness` in `Completeness.lean`
- Renamed `bx_completeness'` to `completeness'` in `Completeness.lean`
- Renamed `dd_countermodel_chronicle_dense` to `countermodel_dense` in `ChronicleToCountermodel.lean`
- Renamed `doets_countermodel_discrete` to `countermodel_discrete` in `Transfer.lean`
- Updated all call sites, docstrings, comments, `#print axioms`, README.md, ROADMAP.md
- Zero stale references remain in active code

### Phase 2: Normalize Axiom Validity Naming
- Renamed `axiom_base_valid` to `axiom_valid` in `Soundness.lean`
- Renamed `axiom_valid_dense` to `axiom_dense_valid` in `Soundness.lean`
- Renamed `axiom_valid_discrete` to `axiom_discrete_valid` in `Soundness.lean`
- Updated all call sites in DenseSoundness.lean, DiscreteSoundness.lean, FrameConditions/Soundness.lean, Decidability/Correctness.lean, Theories/Bimodal/README.md

### Phase 3: Create completeness_dense and completeness_discrete
- Created `completeness_dense : valid_dense phi -> Nonempty (DerivationTree [] phi)` in `Completeness.lean`
- Created `completeness_discrete : valid_discrete phi -> Nonempty (DerivationTree [] phi)` in `Completeness.lean`
- Created helper `countermodel_dense_enriched` that inlines the Rat-based countermodel construction to preserve `DenselyOrdered` for `valid_dense` application
- Created helper `countermodel_discrete_enriched` (sorried) for Int-based construction
- Added `#print axioms` for both new theorems
- Added `import Mathlib.Data.Int.SuccPred` for `SuccOrder Int` instance

### Phase 4: Documentation Updates
- Updated README.md Result Details table with new theorem names
- Updated Theories/Bimodal/README.md Logic Variants section with `completeness_dense` and `completeness_discrete` references
- Updated Metalogic/Metalogic.lean Publication-Ready Results table

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (renamed + new theorems)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (renamed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (renamed)
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` (comment updates)
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (docstring updates)
- `Theories/Bimodal/Metalogic/Soundness.lean` (renamed axiom validity theorems)
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` (call site + docstring updates)
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` (call site + docstring updates)
- `Theories/Bimodal/FrameConditions/Soundness.lean` (call site updates)
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` (comment updates)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (docstring updates)
- `README.md` (Result Details table)
- `Theories/Bimodal/README.md` (Logic Variants section)
- `specs/ROADMAP.md` (theorem name references)

## Plan Deviations
- `countermodel_dense_enriched` uses an inline construction approach rather than wrapping the existential from `countermodel_dense`, because Lean's existential elimination creates opaque witnesses that prevent type class resolution for `DenselyOrdered D`. The inline approach explicitly constructs the countermodel on `Rat`, preserving the `DenselyOrdered` instance.
- `countermodel_discrete_enriched` is sorried rather than inlining `countermodel_discrete`'s construction, because `countermodel_discrete` delegates to `z_interval_countermodel` which has its own sorry chain.
- Non-dense/non-discrete branches of `completeness_dense`/`completeness_discrete` are sorried, as the MCS construction is over the full axiom system and doesn't distinguish frame classes.
- Boneyard references were not updated (dead code, excluded from scope).
- Two planned sub-tasks (Theories/Bimodal/README.md references to `bx_completeness`, Metalogic/Metalogic.lean references) were skipped because grep found no references to old names in those files.

## Verification
- `lake build` passes with zero errors
- All 8 target theorems (`completeness`, `completeness'`, `completeness_dense`, `completeness_discrete`, `countermodel_dense`, `countermodel_discrete`, `axiom_valid`, `axiom_dense_valid`, `axiom_discrete_valid`) exist in Theories/
- All 7 old names have zero references in active code (excluding Boneyard)
