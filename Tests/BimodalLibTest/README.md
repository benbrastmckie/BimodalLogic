# BimodalLibTest

Tests for `BimodalLib`, the library of TM results. Built by `lake build BimodalLibTest`, not by
`lake test`: the library is outside `defaultTargets`, and its tests are kept out of the
published library's test run in the same way.

Each command of the library is tested in both directions: that it accepts what it should and
that it fails, with a pinned message, on what it should not.

| File | Description |
|------|-------------|
| `FragmentTest.lean` | The fragment and operator set of sample formulas of both languages; the axioms of the agreement theorem |
| `RegistryCheckTest.lean` | `assert_registry_complete` fails on the fixture's unregistered derivation and passes once it is registered; `register_theorem` refuses a rule and a non-derivation |
| `PairingTest.lean` | `reprove` accepts a second proof, rejects a drifted one as a type error, and refuses a declaration with no row |
| `IndexTest.lean` | The polarity census on each defined operator; a declared dual read back from its row |
| `EdgeTableTest.lean` | The status of each conservativity edge read off its verdict; a verdict cannot be built without its proof; the rendered edge section lists every registered edge |
| `ProofFragmentTest.lean` | `assert_proof_fragments_recorded` fails on the fixture's theorem, whose proof leaves the cell of its statement, passes once a reason is recorded, and reports a reason recorded for a proof that stays inside its cell; a proved edge is a reason by itself |
| `Fixtures/` | `UnregisteredDerivation.lean`: one closed derivation that no registration module names. `UnrecordedProofFragment.lean`: one registered theorem in Until alone derived through `□`, with no recorded reason |

*Last verified: 2026-11-23*
