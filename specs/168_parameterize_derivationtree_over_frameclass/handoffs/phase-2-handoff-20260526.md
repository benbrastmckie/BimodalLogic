# Phase 2 Handoff: Fix completeness_dense

## What was done
- Changed `completeness_dense` return type from `DerivationTree FrameClass.Base` to `DerivationTree FrameClass.Dense`
- Parameterized `countermodel_dense_enriched` over `{fc : FrameClass}` (was hardcoded to Base)
- Updated proof to use `neg_consistent_of_not_derivable (fc := FrameClass.Dense)`
- Lindenbaum now produces a Dense-MCS instead of Base-MCS
- Dense case branch: closes correctly via countermodel on Rat
- Non-dense case branch: sorry remains but is now a GENUINE open question (can a Dense-MCS lack box(F'T)?) rather than a false statement (the old sorry guarded the unprovable valid_dense -> Base-derivable)

## Investigation result (Task 2.4)
The density axiom (GGphi -> Gphi) is a temporal axiom, not a modal axiom. It does NOT directly force box(F'T) into every Dense-MCS. Whether a Dense-MCS must contain box(F'T) depends on the interaction between the density axiom and the modal S5 axioms in the canonical model construction. This is a genuine open question, distinct from the previous false sorry.

## Next action
Phase 3: Fix `completeness_discrete` return type similarly.

## Key decisions
- Parameterized countermodel_dense_enriched with implicit {fc} rather than explicit (fc) since callers pass it implicitly
- Kept the sorry in non-dense branch (genuine open question, not false statement)
