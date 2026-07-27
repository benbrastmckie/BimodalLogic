# FrameConditions

A typeclass API layer over the frame conditions distinguishing the Base, Dense, and
Discrete variants of TM logic. Four modules, 816 lines.

## Modules

| File | Lines | Description |
|------|------:|-------------|
| `FrameClass.lean` | 220 | The four marker typeclasses bundling the Mathlib order constraints |
| `Validity.lean` | 204 | `valid_over`: validity parameterized by a temporal frame |
| `Soundness.lean` | 190 | Soundness stated through the typeclass constraints |
| `Compatibility.lean` | 176 | `AxiomCompatible`: which axioms hold on which frame class |

## Two Different Things Named `FrameClass`

96 live files mention the identifier `FrameClass`. Nearly all of them mean something
this directory does not define, and a name-based audit will conflate them:

| | Defined in | Kind | Used as |
|---|---|---|---|
| `FrameClass` | `ProofSystem/Axioms.lean:378` | `inductive` | `FrameClass.Base`, `FrameClass.Discrete` |
| `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame` | `FrameConditions/FrameClass.lean` | `class ... : Prop` | instance constraints, e.g. `[DiscreteTemporalFrame D]` |

The `inductive` is a proof-system-level tag naming an axiom layer. The typeclasses here
are semantic constraints on a carrier type `D`. They are related in intent and unrelated
in type. This directory's file happens to share the inductive's name, which is why the
distinction is stated here rather than assumed.

## Placement: This Directory Stays Separate from `Metalogic/`

Whether `FrameConditions/` should merge into `Metalogic/` is settled by measurement,
not preference.

**Measured dependency direction:**

- Files under `Metalogic/` that import `Bimodal.FrameConditions`: **0**
- This directory imports, from outside itself:
  - `Bimodal.Metalogic.Soundness`
  - `Bimodal.ProofSystem.Axioms`
  - `Bimodal.Semantics.Validity`
- Live importers of `Bimodal.FrameConditions` anywhere: **1** — `Theories/Bimodal/Bimodal.lean`,
  the library root.

The direction is unambiguous: `FrameConditions/` sits strictly **above** `Metalogic/` and
consumes it. It is a thin API layer, not a part of the metalogic development.

**Consequence:** merging it into `Metalogic/` would invert the dependency direction —
`Metalogic/` would contain a module importing `Metalogic.Soundness` from above — and
manufacture a third directory-level cycle in a directory that already has two
(see [`../Metalogic/README.md`](../Metalogic/README.md)). The evidence resolves the
question; no judgement call is required.

Note that an earlier version of this README claimed this directory was "imported by
`Bimodal.Metalogic.SoundnessLemmas`, `Bimodal.Metalogic.Soundness`". That was backwards
— those are among the things it imports — and is the reason the counts above are stated
as measurements rather than as prose.

## Key Definitions

- `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame` —
  marker typeclasses bundling the Mathlib order constraints a temporal carrier needs
- `valid_over` — validity parameterized over any such carrier
- `AxiomCompatible` — relates an axiom schema to the frame classes validating it

## Usage

```lean
import Bimodal.FrameConditions
open Bimodal.FrameConditions

example [DiscreteTemporalFrame D] : soundness_discrete D := ...
```

## Verification

```bash
# The layering claims above, re-derived:
grep -rl 'Bimodal\.FrameConditions' Theories/Bimodal/Metalogic --include='*.lean'   # expect: no output
grep -h '^import' Theories/Bimodal/FrameConditions/*.lean | sort -u
```

## Related Documentation

- [Parent README](../README.md)
- [Metalogic architecture map](../Metalogic/README.md)
- [ProofSystem README](../ProofSystem/README.md) — home of the `FrameClass` inductive
