# NfMultiAnchorBridge — The Multi-Anchor Characteristic-Formula Bridge

43 live `.lean` files / 41,859 lines — the largest subdirectory in the repository, and
roughly 59% of all of `Kamp/`. It builds the depth-graded, multi-anchor characteristic
formula bridge that connects normal forms to the separation argument.

## Structure

| | Files | Lines |
|---|------:|------:|
| loose modules | 33 | 28,265 |
| [`SharedWitness/`](SharedWitness/README.md) | 10 | 13,594 |

The 33 loose modules group by role:

- **Base and carriers** — `Base.lean`, `CarrierK1V.lean`, `CarrierKv.lean`
- **Exterior gate** — the `Exterior*K.lean` family (bracket, converter, fiber, negation,
  pinned-converse, navigation), the bulk of the directory
- **Interior and outer gates** — `InteriorGateGeneralK.lean`, `OuterGate.lean`,
  `ExteriorZoneTriage.lean`
- **Aggregation** — `AggregateHookDischarge.lean`, `AggregateOffDiagK1.lean`,
  `AggregatePointMergeK1.lean`
- **Sub-brackets and spine** — `SubBracket.lean`, `SubBracket2.lean`, `SubBracket2V.lean`,
  `NavigatedSpine.lean`, `EndIntervalConsumerK.lean`
- **Interfaces** — `PriorInterface.lean`, `SharedWitness.lean` (the sibling aggregator
  for `SharedWitness/`)

## Position in the Layering

Inside `Kamp/`, reached from the loose module `Kamp/NfMultiAnchorBridge.lean` that sits
beside this directory. That file's module docstring is the authoritative statement of
what the bridge delivers and which phase delivered each piece; its long block of import
notes explains why several apparently unused import edges are load-bearing (an
unreachable transcription or refutation rots invisibly, so the edges keep them in the
build graph deliberately).

## Related Documentation

- [Kamp README](../README.md)
- [SharedWitness README](SharedWitness/README.md)
- [Metalogic architecture map](../../../../README.md)
