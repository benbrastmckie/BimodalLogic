# RestrictedMCSDeferral

Archived from `FormalSystem/Metalogic/Core/RestrictedMCS/`.
Archived 2026-07-14 in commit `c29fa7465`.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/RestrictedMCSDeferral rows=loose -->
| File | Lines | Description |
|------|------:|-------------|
| `Deferral.lean` | 772 | The deferral-restricted MCS development: `DeferralRestricted`, `DeferralRestrictedConsistent`, `DeferralRestrictedMCS`, `deferral_restricted_lindenbaum`, the `iterF`/`iterP` bound lemmas, and the `drm_*` closure properties (19 declarations) |
<!-- END GENERATED -->

## Why archived

**Superseded approach.** This is an MCS restricted to `deferralClosure(φ)` rather than
`closureWithNeg(φ)`. The deferral closure carries the extra disjunctions the successor-seed
construction wanted, while preserving the same F/P-depth bounds — a genuine variant, fully
developed through Lindenbaum, negation-completeness and boundedness.

It has zero live consumers. The construction it was built to serve is itself archived, at
[`../BundleSuccessorSeed/`](../BundleSuccessorSeed/README.md), which this file imports directly.
Retiring the variant alongside the construction it existed for was cheaper than maintaining a
second MCS notion nothing exercised.

## Relationship to active code

`FormalSystem.Metalogic.Core.RestrictedMCS.Basic` is live and supplies `RestrictedMCS`,
`ClosureRestricted` and the closure bounds this file builds on. The *other* archived
`RestrictedMCS` offshoot, [`../RestrictedMCSBoundedness/`](../RestrictedMCSBoundedness/README.md),
was retired for the same shape of reason — its consumer was archived first — and the two should
be read together.

Resurrection requires resurrecting `BundleSuccessorSeed/SuccExistence` first; this file's second
import points into the archive, not into live code.

## Convention note

This directory postdates the guard-first migration in the sense that its subject matter is
closures and deferral disjunctions rather than `untl`/`snce` constructor applications. Check
before swapping anything, per the archive root README.
