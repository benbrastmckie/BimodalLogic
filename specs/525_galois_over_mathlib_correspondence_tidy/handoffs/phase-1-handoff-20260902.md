# Phase 1 handoff — task 525

**Status**: Phase 1 [COMPLETED]. Full `lake build` green (2521 jobs).

## Done
- `Galois.lean` re-based on `Mathlib.Order.Concept`: `validOnRel`, `abbrev Th/Mod/GaloisClosed`,
  7 projection bodies, `mod_th_gc`, `galoisClosed_iff`, `galoisClosed_of_indicator_iff`,
  `galoisClosed_iInter/inter/univ`, `mod_union/mod_iUnion/mod_empty/th_empty`; header seam +
  main-results rewritten.
- Fix-forward: strict-implicit call-site repairs in `RationalWitness.lean:198`,
  `LexIntWitness.lean:162`, `FwdRecBridge.lean:149`.

## Key decision / gotcha for successors
The risk that materialised was **binder info**, not the simp set. `Mod S` membership is now
`∀ ⦃φ⦄, φ ∈ S → …` (strict implicit). Applications must NOT pass `φ` positionally. Producing a
membership with `fun _ h => …` is fine. If any later phase adds a `Mod`/`Th` application, use
`hF hmem`, not `hF φ hmem`.

## Next action
Phase 3 (additive realisation layer in `DurationFrames.lean`), then Phase 4, Phase 2, Phase 5,
Phase 6.
