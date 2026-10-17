# SharedWitness — The Shared-Interior-Witness Tower

10 live `.lean` files / 13,594 lines. A layered "tower" constructing a single shared
interior witness for the multi-anchor bridge, together with its soundness and
completeness. Each module is one storey; they are meant to be read in order.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness -->
| File | Lines | Role |
|------|------:|------|
| `Assembly.lean` | 1,725 | Assembly of the shared witness from the folds |
| `Carrier.lean` | 784 | The joint carrier definition `kvE2_sepBody` — the base of the tower |
| `Completeness.lean` | 1,139 | Completeness of the assembled witness |
| `DisjunctionSpikes.lean` | 1,238 | Disjunction spike handling |
| `EngineInputs.lean` | 1,404 | Inputs handed to the assembly engine |
| `FragmentFoldRight.lean` | 1,392 | Right fold over the fragment |
| `KitFold.lean` | 1,816 | The kit fold — the tower's main combinator |
| `OrderGate.lean` | 1,560 | The order gate constraining slot arrangement |
| `Slots.lean` | 917 | Slot structure over the carrier |
| `Soundness.lean` | 1,618 | Soundness of the assembled witness |
<!-- END GENERATED -->

Individual module docstrings identify each file's storey (e.g. `Carrier.lean` is
"Module C of the `SharedWitness` tower"); that lettering is the intended reading order
and is more precise than any summary here.

## Position in the Layering

The deepest directory in `Metalogic/`:
`Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness/`. It is reached
through the sibling aggregator `NfMultiAnchorBridge/SharedWitness.lean`, which is
itself reached from the bridge development one level up.

Note that this is four levels below `Metalogic/` and inside the repository's largest
subtree; nothing outside `NfMultiAnchorBridge/` imports it directly.

## Related Documentation

- [NfMultiAnchorBridge README](../README.md)
- [Kamp README](../../README.md)
- [Metalogic architecture map](../../../../../README.md)

---

*Last verified: 2026-09-21*
