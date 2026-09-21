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
| `Standard.lean` | 133 | <!-- TODO: add description --> |
<!-- END GENERATED -->

## Key Definitions

- `translationFrame` — the translation flow over an arbitrary duration group
- `permissiveFrame` — the frame whose task relation relates everything

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
