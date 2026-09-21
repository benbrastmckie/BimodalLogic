# LimitMCSCoherenceDeadCases -- Retired `LimitMCSCoherence.lean` Cases

Five theorems retired from `FormalSystem/Metalogic/Bundle/LimitMCSCoherence.lean` during the
`TemporalSide` parameterization of `Bundle/LimitMCS.lean` (see `Bundle/README.md`'s "Temporal
Duality Discipline" section for the discipline this retirement is downstream of).

## Retirement reason

Each of the five was referenced only by its own declaration and by module-docstring prose in
the live tree, with zero live consumers repository-wide (Boneyard excluded), re-verified at
retirement time:

- `limitSetBelow_forward_G_rat_target`
- `limitSetBelow_forward_G_limit`
- `limitSetBelow_of_rat_of_backward_H_rat_source`
- `limitSetBelow_backward_H_rat_target`
- `limitSetBelow_backward_H_limit`

The live coherence matrix (`Bundle/LimitMCSCoherence.lean`) retains only the two source-rational
cases (`limitSetBelow_forward_G_rat_source`, `limitSetBelow_backward_H_rat_source`) plus the
four `limitMCSBelow_*`-prefixed variants that `Bundle/RealExtension.lean` actually consumes.

## Argument order

This snippet is **guard-first**, like the live tree at retirement time — unlike most of
`Boneyard/`, which predates the guard-first migration and is event-first (see the archive
root README). No argument swap is needed if resurrecting it.

Not part of any `lean_lib` root; not compiled; not imported by any live module.
