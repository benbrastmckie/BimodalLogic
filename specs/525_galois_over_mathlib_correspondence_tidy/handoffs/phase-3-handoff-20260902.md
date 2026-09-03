# Phase 3 handoff — task 525

**Status**: Phase 3 [COMPLETED]. Scoped build of
`FormalSystem.Semantics.Correspondence.DurationFrames` green (1342 jobs).

## Done
Six additive declarations in `DurationFrames.lean`: `translationHF`, `translation_realizes`,
`translation_realizes_allPast`, `translation_realizes_allFuture`, `permissiveHF`,
`permissive_realizes`; plus the header inventory line. No existing declaration touched.

## Not taken
The optional `WorldHistory.ofTotal` stretch — plan marks it droppable and outside acceptance.

## Next action
Phase 4: rewrite the three (T1) (⇒) branches against these lemmas, starting with
`validOn_co_iff_isComplete` (largest mechanical win: the 11-line inline `hHiff` becomes
`translation_realizes_allPast`), then `validOn_df_iff_isDiscrete`, then
`validOn_dn_iff_denselyOrdered` (permissive twin). Then delete `private def corrAtom` and
retarget ~13 `Formula.atom corrAtom` sites to `Formula.atom (Atom.mkBase "p")`, plus
`FwdRec.lean:88,97`'s two `Atom.mk "p" none` inlines.
