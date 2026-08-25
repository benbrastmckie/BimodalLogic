# FrameConditions

A typeclass API layer over the frame conditions distinguishing the Base, Dense, Discrete, and
Dedekind variants of TM logic. Four modules, 892 lines.

## Modules

| File | Lines | Description |
|------|------:|-------------|
| `FrameClass.lean` | 292 | The five marker typeclasses bundling the Mathlib order constraints |
| `Validity.lean` | 209 | `valid_over`: validity parameterized by a temporal frame |
| `Soundness.lean` | 204 | Soundness stated through the typeclass constraints |
| `Compatibility.lean` | 187 | `AxiomCompatible`: which axioms hold on which frame class |

## Two Different Things Named `FrameClass`

96 live files mention the identifier `FrameClass`. Nearly all of them mean something
this directory does not define, and a name-based audit will conflate them:

| | Defined in | Kind | Used as |
|---|---|---|---|
| `FrameClass` | `ProofSystem/Axioms.lean:519` | `inductive` | `FrameClass.Base`, `FrameClass.Discrete` |
| `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, `DedekindTemporalFrame` | `FrameConditions/FrameClass.lean` | `class ... : Prop` | instance constraints, e.g. `[DiscreteTemporalFrame D]` |

The `inductive` is a proof-system-level tag naming an axiom layer. The typeclasses here
are semantic constraints on a carrier type `D`. They are related in intent and unrelated
in type. This directory's file happens to share the inductive's name, which is why the
distinction is stated here rather than assumed.

## Placement: This Directory Stays Separate from `Metalogic/`

Whether `FrameConditions/` should merge into `Metalogic/` is settled by measurement,
not preference.

**Measured dependency direction:**

- Files under `Metalogic/` that import `FormalSystem.FrameConditions`: **0**
- This directory imports, from outside itself:
  - `FormalSystem.Metalogic.Soundness`
  - `FormalSystem.ProofSystem.Axioms`
  - `FormalSystem.Semantics.Validity`
- Live importers of `FormalSystem.FrameConditions` anywhere: **1** —
  `FormalSystem/FormalSystem.lean:13`, the library aggregator.

The direction is unambiguous: `FrameConditions/` sits strictly **above** `Metalogic/` and
consumes it. It is a thin API layer, not a part of the metalogic development.

**Consequence:** merging it into `Metalogic/` would invert the dependency direction —
`Metalogic/` would contain a module importing `Metalogic.Soundness` from above — and
manufacture a third directory-level cycle in a directory that already has two
(see [`../Metalogic/README.md`](../Metalogic/README.md)). The evidence resolves the
question; no judgement call is required.

Note that an earlier version of this README claimed this directory was "imported by
`FormalSystem.Metalogic.SoundnessLemmas`, `FormalSystem.Metalogic.Soundness`". That was backwards
— those are among the things it imports — and is the reason the counts above are stated
as measurements rather than as prose.

## Key Definitions

- `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`,
  `DedekindTemporalFrame` — five marker typeclasses bundling the Mathlib order constraints a
  temporal carrier needs

  `DedekindTemporalFrame` (`FrameClass.lean:182`) is **a side-car, not the load-bearing layer**.
  Neither `Metalogic/Soundness.lean` nor `Metalogic/BXCanonical/Completeness.lean` consumes it,
  exactly as neither consumes `DenseTemporalFrame` or `DiscreteTemporalFrame`. Those theorems
  consume the raw instance-binder validity predicates in `Semantics/Validity.lean` —
  `ValidDedekind` and `ValidDedekindDense`. The class exists for parity with the four markers
  above and for callers that want a named bundle; adding a field here changes nothing about what
  is provable. Note also that `DenselyOrdered D` is **not** among its binders, matching
  `ValidDedekind`; the real-flow class adds `[DenselyOrdered D]`, corresponding to
  `ValidDedekindDense`.
- `valid_over` — validity parameterized over any such carrier
- `AxiomCompatible` — relates an axiom schema to the frame classes validating it

## Usage

```lean
import FormalSystem.FrameConditions
open FormalSystem.FrameConditions

example [DiscreteTemporalFrame D] : soundness_discrete D := ...
```

## Verification

```bash
# The layering claims above, re-derived:
grep -rl 'FormalSystem\.FrameConditions' FormalSystem/Metalogic --include='*.lean'   # expect: no output
grep -h '^import' FormalSystem/FrameConditions/*.lean | sort -u
```

## Related Documentation

- [Parent README](../README.md)
- [Metalogic architecture map](../Metalogic/README.md)
- [ProofSystem README](../ProofSystem/README.md) — home of the `FrameClass` inductive
