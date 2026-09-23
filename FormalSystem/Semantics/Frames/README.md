# Semantics/Frames

The standard-frame index: the small number of concrete `TaskFrame`s the development builds
directly, together with a linked census of every other standard frame in the tree.

A concrete frame is expensive to build — every one of `def:frame`'s four axioms must be
discharged — so the ones that exist are reused rather than rebuilt, and this directory is where
a reader looks for one before writing another.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Frames -->
| File | Lines | Description |
|------|------:|-------------|
| `Standard.lean` | 143 | The two standard frames built here — `translationFrame` (the translation flow on `D` itself) and `permissiveFrame` (the two-state frame in which every state assignment is a history) — with the linked census of every other standard frame in the tree. |
| `TranslationProduct.lean` | 682 | The translation product `FrameOver.translationProduct` (states `W × D`, a task of duration `x` advances the clock by `x`): a proof device, never an intended model. Every frame condition transfers from the base relation (`prodRel_*`, `colourClock`); histories are history-plus-offset pairs (`liftH`, `projH`); truth in L, L⁺ and L⋆ is preserved by the projection (`truth_invariance`, `plus_invariance`, `star_invariance`); class validity equals validity over the recurrence-free members (`validIn_iff_recurrenceFree` and siblings); frame validity is not reflected (`frame_validity_not_reflected`); the projection is a `HistMorphism` (`translationProductProj`). |
<!-- END GENERATED -->

## Key Definitions

- `translationFrame` — the translation flow over an arbitrary duration group
- `permissiveFrame` — the frame whose task relation relates everything
- `FrameOver.translationProduct` — the translation product of a frame, a proof device (never an
  intended model) showing that `L`, `L⁺` and `L⋆` cannot see recurrence or transposition:
  `validIn_iff_recurrenceFree`, `plusValidIn_iff_recurrenceFree`, `starValidIn_iff_recurrenceFree`
  — at every frame class, validity over the class equals validity over its recurrence-free members

## Frames built in other components

The linked census of every other standard frame is in the module docstring of
[`Standard.lean`](Standard.lean). Frames added since, recorded here rather than by editing that
module:

- `sinkFrame` ([`OpenLanguage/OpenOckhamist.lean`](../../OpenLanguage/OpenOckhamist.lean)) — three
  world states over `ℤ`, one step "stay, or fall into the sink"; built by `FrameOver.ofStep`, so
  all four axioms of `def:frame` hold, *Saturation* through the finite carrier. It refutes the
  stability transposition of the Ockhamist principle.

## Related Documentation

- [Semantics README](../README.md)
- [`TaskFrame.lean`](../TaskFrame.lean) — the frame structure and its four axioms
- [`FrameProperty.lean`](../FrameProperty.lean) — the frame predicates the classes interpret into

---

*Last verified: 2026-09-21*
