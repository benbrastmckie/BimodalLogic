# FMPVariants

Archived from `FormalSystem/Metalogic/Decidability/FMP/`.
Archived 2026-07-24 in commit `56e9f62ff`.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/FMPVariants rows=loose -->
| File | Lines | Description |
|------|------:|-------------|
| `DenseFMP.lean` | 116 | `dense_fmp` — the finite model property for densely ordered temporal types |
| `DiscreteFMP.lean` | 121 | `discrete_mcs_finite_model_property` — the finite model property for discretely ordered temporal types |
<!-- END GENERATED -->

## Why archived

**Superseded approach: an unconsumed interface.** Both modules restate the finite model property
for a specific frame class on top of the Base-variant FMP. No live module imported either file:
the tableau decision procedure consumes the Base-variant FMP interface only, and the MCS-based
filtration underneath is indifferent to whether the order is dense or discrete — which is exactly
why the two wrappers bought nothing.

Neither file is refuted. They are orphans, not dead ends, and the mathematics in them is the same
mathematics the live FMP already carries.

## Relationship to active code

`FormalSystem.Metalogic.Decidability.FMP.FMP` is live and is the sole import of both files.
Resurrecting either means re-establishing a consumer for it first; without one it would be
archived again for the same reason.

## Convention note

Both files predate the guard-first migration but concern only frame-class and filtration
machinery; there are no `untl`/`snce` occurrences for the root README's argument-swap warning to
apply to.
