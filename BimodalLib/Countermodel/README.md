# Countermodel

The countermodel registry's machinery. The entry type itself and the registry walk live in the
sibling `Countermodel.lean`; this directory holds the three pieces that act on entries once they
exist. The entries themselves are filed under `Countermodels/`, not here.

| Path | Description |
|------|-------------|
| `Gates.lean` | The branch gates bundled as one decidable `Bool`, with the gate theorem that lets the GATED TABLEAU grade admit an open saturated branch as a refutation |
| `Lookup.lean` | Looking a refuted inference up in the library to renaming of atoms. The proof mode's entry point: where a tableau leaves a leaf unclosed, the leaf's inference is matched against the registered rows |
| `Transfer.lean` | Transfer of a registered countermodel to every weaker reading of the same inference, each of the two transfers resting on a named theorem rather than on a convention |

*Last verified: 2026-11-24*
