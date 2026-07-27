# SharedWitness — The Shared-Interior-Witness Tower

10 live `.lean` files / 13,594 lines. A layered "tower" constructing a single shared
interior witness for the multi-anchor bridge, together with its soundness and
completeness. Each module is one storey; they are meant to be read in order.

## Modules

| File | Lines | Role |
|------|------:|------|
| `Carrier.lean` | 783 | The joint carrier definition `kvE2_sepBody` — the base of the tower |
| `Slots.lean` | 924 | Slot structure over the carrier |
| `OrderGate.lean` | 1,558 | The order gate constraining slot arrangement |
| `EngineInputs.lean` | 1,405 | Inputs handed to the assembly engine |
| `DisjunctionSpikes.lean` | 1,238 | Disjunction spike handling |
| `FragmentFoldRight.lean` | 1,392 | Right fold over the fragment |
| `KitFold.lean` | 1,814 | The kit fold — the tower's main combinator |
| `Assembly.lean` | 1,723 | Assembly of the shared witness from the folds |
| `Soundness.lean` | 1,618 | Soundness of the assembled witness |
| `Completeness.lean` | 1,139 | Completeness of the assembled witness |

Individual module docstrings identify each file's storey (e.g. `Carrier.lean` is
"Module C of the `SharedWitness` tower"); that lettering is the intended reading order
and is more precise than any summary here.

## Position in the Layering

The deepest directory in `Metalogic/`:
`Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness/`. It is reached
through the sibling aggregator `NfMultiAnchorBridge/SharedWitness.lean`, which is
itself reached from the bridge development one level up.

Note that this is four levels below `Metalogic/` and inside the repository's largest
subtree; nothing outside `NfMultiAnchorBridge/` imports it directly.

## Related Documentation

- [NfMultiAnchorBridge README](../README.md)
- [Kamp README](../../README.md)
- [Metalogic architecture map](../../../../../README.md)
