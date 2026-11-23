# Theorems

The registered theorems: one `register_theorem` line per closed derivation declared under
`FormalSystem/Theorems/`, outside its `ProofMode/` directory. The derivations stay where they
are; a line here registers one by reference.

A line is filed by the fragment and frame class its row computes: the directory is the
fragment, the file the frame class.

| Path | Description |
|------|-------------|
| `Complete.lean` | Runs `assert_registry_complete` over the published library; the build fails when a closed derivation is unregistered |
| `Boolean/` | Statements with no modal or temporal operator |
| `ModalBoolean/` | Statements with a modal operator and no temporal one |
| `TemporalBoolean/` | Statements with a temporal operator and no modal one |
| `ModalTemporalBoolean/` | Statements with both |

*Last verified: 2026-11-23*
