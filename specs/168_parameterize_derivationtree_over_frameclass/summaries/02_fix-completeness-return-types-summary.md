# Implementation Summary: Fix completeness_dense/discrete Return Types

## Task
Fix mathematically incorrect return types in `completeness_dense` and `completeness_discrete`.

## Changes Made

### Phase 1: Parameterize neg_consistent_of_not_derivable
- Changed signature from hardcoded `FrameClass.Base` to `{fc : FrameClass}`
- Replaced 6 occurrences of `FrameClass.Base` in proof body with `fc`
- All structural rules (deduction_theorem, double_negation, ex_falso, modus_ponens) were already fc-polymorphic

### Phase 2: Fix completeness_dense
- Changed return type: `DerivationTree FrameClass.Base [] phi` -> `DerivationTree FrameClass.Dense [] phi`
- Parameterized `countermodel_dense_enriched` over `{fc : FrameClass}`
- Dense case branch: closes correctly via countermodel on Rat
- Non-dense case branch: sorry remains (genuine open question about canonical model)

### Phase 3: Fix completeness_discrete
- Changed return type: `DerivationTree FrameClass.Base [] phi` -> `DerivationTree FrameClass.Discrete [] phi`
- Implemented `countermodel_discrete_enriched` with full proof (was sorry) using fc-parameterized Chronicle pipeline
- Discrete case branch: closes correctly via countermodel on Int
- Mixed case branch: eliminated using `mcs_mixed_case_absurd` (was sorry)
- Dense case branch: sorry remains (genuine open question about canonical model)

### Phase 4: Downstream consumers and verification
- No Lean callers outside Completeness.lean (only documentation references)
- Updated Metalogic.lean documentation table
- Full `lake build` passes (1649 jobs)

## Sorry Audit

### Sorries eliminated (2)
1. `countermodel_discrete_enriched` (entire proof body was sorry) -- fully proved
2. `completeness_discrete` mixed case -- eliminated via `mcs_mixed_case_absurd`

### Sorries remaining (2)
1. `completeness_dense` non-dense branch (line 285): GENUINE OPEN QUESTION
   - Goal: Dense-MCS M with not-box(F'T) in M leads to False
   - Question: Can a Dense-MCS fail to contain box(F'T)?
   - Previously: false sorry (guarded unprovable valid_dense -> Base-derivable)

2. `completeness_discrete` dense branch (line 317): GENUINE OPEN QUESTION
   - Goal: Discrete-MCS M with box(F'T) in M leads to False
   - Question: Can a Discrete-MCS contain box(F'T)?
   - Previously: false sorry (guarded unprovable valid_discrete -> Base-derivable)

### Mathematical assessment
Both remaining sorries are about whether frame-class-specific axioms constrain the canonical model's density/discreteness indicator. In standard canonical model completeness theory for frame-class logics, the axiom typically forces the canonical frame to have the corresponding property. However, here the interaction between the temporal density axiom (GGphi -> Gphi) and the modal S5 component requires careful analysis. These are legitimate open mathematical questions, not gaps or false statements.

## Plan Deviations
- Task 3.3: countermodel_discrete_enriched got a full proof (plan expected it would retain a sorry)
- Task 4.2: No callers to update (plan expected there might be some)

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (primary)
- `Theories/Bimodal/Metalogic/Metalogic.lean` (documentation update)
