# Conservativity

The conservativity edges of the fragment lattice, stated over derivability within a cell. The
vocabulary (`within`, `DerivableIn`, `ConservativeEdge`, `proofProfile`) is in
`../Conservativity.lean`.

| File | Description |
|------|-------------|
| `Proved.lean` | The proved edges: `conservativeEdge_boolean`, `conservativeEdge_box` and the three forms that follow from them, with the identification of derivability within a cell and the calculus of a sublanguage under `FormalSystem/Metalogic/Conservativity/Fragments/` |
| `TemporalBase.lean` | The refuted edge: `not_conservativeEdge_temporal_base`, by soundness of the temporal cell over every linear order without endpoints and a countermodel on the integers followed by the rationals |
| `Table.lean` | `EdgeVerdict`, `ConservativityEdge` and the registered edges, each with a kernel-checked verdict; rendered as the section "Conservativity edges" of `../INDEX.md` |

*Last verified: 2026-11-23*
