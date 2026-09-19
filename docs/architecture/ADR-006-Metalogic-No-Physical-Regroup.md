# ADR-006: No Physical Regroup of the Three Completeness Routes

## Status

**Accepted** - 2026-09-07

Supersession of the "no physical relocation" clause, for the expressiveness subset of
`WeakCanonical/` only, is proposed by [ADR-011](ADR-011-Extract-Expressiveness.md) (Proposed);
this record remains in force until that ADR is accepted.

## Context

`FormalSystem/Metalogic/` carries three distinct routes to completeness — the Chronicle route
(`BXCanonical/`), the Kamp/Reynolds route (`WeakCanonical/`) and the Algebraic route
(`Algebraic/`). They are siblings, not layers. The natural instinct is to nest them under a
`Completeness/` parent, or to nest one inside another. This ADR records why neither was done.

## Decision

Neither nesting is adopted. **Measurement rules both out.**

There is exactly **one** directory-level cycle in `Metalogic/`. It is enumerated
edge-by-edge, file-and-line, in the measurement output this document is drawn from —
regenerated from the tree rather than copied from any report, and
`scripts/check-metalogic-cycles.sh` asserts the count mechanically.

There used to be a second, `Bundle` ↔ `Core`. It is gone: `Core/RestrictedMCS/Basic.lean` was
the sole reverse edge, and it now reaches the iterated-temporal syntax it needed through
`Syntax/SubformulaClosure/IteratedTemporal.lean` instead of through
`Bundle/CanonicalTaskRelation.lean`. `Bundle → Core` remains, one-directionally, at 9 import
lines across 5 files — down from 18 across 10, because six of `Bundle/`'s fifteen modules were
retired to [`Boneyard/BundleDeadHalf/`](../../FormalSystem/Boneyard/BundleDeadHalf/README.md) in the same change.

### The cycle: `BXCanonical` <-> `WeakCanonical`

```
BXCanonical → WeakCanonical  (9 import lines)
  BXCanonical/Chronicle/ChronicleMonadicBridge.lean
      → FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
      → FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful
      → FormalSystem.Metalogic.WeakCanonical.PriorDefsDense
      → FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense
      → FormalSystem.Metalogic.WeakCanonical.Table
      → FormalSystem.Metalogic.WeakCanonical.Transfer
  BXCanonical/Chronicle/ChronicleToCountermodel.lean
      → FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery
  BXCanonical/Completeness.lean
      → FormalSystem.Metalogic.WeakCanonical
  BXCanonical/CompletenessDedekind.lean
      → FormalSystem.Metalogic.WeakCanonical.RealModel.ChronicleRealFlow

WeakCanonical → BXCanonical  (5 import lines)
  WeakCanonical/ChronicleExtraction.lean
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
  WeakCanonical/DenseModelSurgery/ChronicleInstance.lean
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge
  WeakCanonical/ReflexiveCanonical.lean
      → FormalSystem.Metalogic.BXCanonical.OrderedSeedConsistency
  WeakCanonical/Transfer.lean
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
```

The figures above were 2 and 4 until this pass; `ChronicleMonadicBridge.lean` alone contributes
six forward edges the earlier enumeration never mentioned. Regenerate them with
`bash scripts/check-metalogic-cycles.sh`, which prints exactly this list and asserts the cycle
count is 1.

Nesting either of that pair inside the other produces a directory whose contents import upward
out of it — which is not a hierarchy. Lean permits the cycle because it exists only at
*directory* granularity; the module-level dependency graph is acyclic, which is why
the build works at all. Directory structure simply cannot express a mutual dependency.

### The declined regroup, and its evidence

Physically regrouping the three routes was **considered and declined**. Beyond the
cycle argument: `WeakCanonical` is 339 import lines across 137 live files, roughly
five times the next-largest subtree. That makes it the single largest partial-move
risk in the repository, and a half-updated move leaving dangling imports is worse
than no move at all. The deliverable is therefore a correct map plus a standardized
aggregator convention, not a physical relocation.

The `Bundle` ↔ `Core` cycle was broken, and the measurement that once said not to is
superseded. That measurement costed a *different* plan — relocating `Core/RestrictedMCS/Basic.lean`
itself, at 9 files touched, 5 of them markdown — and it was declined on that basis. What was
actually done instead moves the dependency, not the dependent: the 29 pure-syntax iterated-`F`/`P`
declarations `Basic.lean` needed were relocated to
`Syntax/SubformulaClosure/IteratedTemporal.lean`, where nothing about them mentions MCSs,
derivability or frame classes, and the `Core → Bundle` import line was deleted. The reverse edge
had exactly one source, so one relocation removed the whole cycle.

## Consequences

- The deliverable is a correct map plus a standardized aggregator convention, not a physical
  relocation. Check **C8** asserts every subdirectory has exactly one sibling aggregator
  `X.lean` beside `X/`, never `X/X.lean`.
- The edge enumeration above is *regenerated*, not maintained by hand:
  `bash scripts/check-metalogic-cycles.sh` prints exactly this list and asserts the
  directory-level cycle count is 1. If it disagrees with the listing above, the script is right.
- A future proposal to regroup must first show the cycle is gone, the way the `Bundle` <-> `Core`
  cycle was removed: by relocating the *dependency*, not the dependent.

## Related

- `scripts/check-metalogic-cycles.sh` — the mechanical assertion
- [`FormalSystem/Metalogic/README.md`](../../FormalSystem/Metalogic/README.md) — the directory's
  own map, which points here rather than restating this rationale
