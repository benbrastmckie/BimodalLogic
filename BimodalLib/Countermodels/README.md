# Countermodels

The registered countermodels: one constant of type `CountermodelEntry L` per refuted
inference, discovered by the index walk. There is no registration command, because there is no
declaration to read the statement off — a countermodel row's statement is the refuted
*inference*, which the author writes. The kernel checks the `refutation` field; `profile_eq`,
closed by `rfl`, is what makes the filing computed rather than asserted.

A row is filed by the fragment and frame class it computes: the directory is the fragment, the
file the frame class. `Boolean/GatedTableau.lean` is the exception on the second axis — it is
filed by grade, because explicit branch data carries no frame class of its own.

| Path | Description |
|------|-------------|
| `Complete.lean` | Imports every entry module and runs the build invariants over the whole set; importing it brings the whole countermodel half into scope |
| `Boolean/` | Refuted inferences with no modal or temporal operator |
| `ModalBoolean/` | Refuted inferences with a modal operator and no temporal one |
| `TemporalBoolean/` | Refuted inferences with a temporal operator and no modal one |
| `ModalTemporalBoolean/` | Refuted inferences with both |

*Last verified: 2026-11-24*
