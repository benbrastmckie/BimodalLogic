# Proof-mode derivation rules

Reusable derivation-producing rules for TM and TM⁺, independent of tactic elaboration.
Import the sibling [`ProofMode.lean`](../ProofMode.lean) aggregator for manual Lean use.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Theorems/ProofMode -->
| File | Lines | Description |
|------|------:|-------------|
| `Basic.lean` | 103 | Context substitution, cut, conjunction, disjunction, and possibility introduction |
| `Discrete.lean` | 198 | Shifted contexts and integer-time invariance |
| `PlusDiscrete.lean` | 93 | Native TM⁺ discrete rules transferred from TM schemas |
| `PlusModal.lean` | 76 | TM⁺ possibility and dual-stability rules |
| `PlusRules.lean` | 269 | Native TM⁺ deduction, substitution, and contextual necessitation |
| `PlusTemporal.lean` | 186 | Native TM⁺ temporal composition at arbitrary formula arguments |
| `Possibility.lean` | 28 | Possibility consequence through necessary implications |
| `Temporal.lean` | 204 | Future/past consequence, bind, progress, and Until/Since mapping |
<!-- END GENERATED -->

Under `FormalSystem`, TM rules use the `Theorems.ProofMode` namespace; TM⁺ counterparts use
`PlusLanguage.ProofMode`. Both construct native derivation trees using existing
calculus rules. TM⁺ schema transfer supports arguments containing stability.
The closed `futureCollapse` and `pastCollapse` schemas are also available for manual composition.

Context substitution supplies opaque guarantees without unfolding their proofs. Modal and
temporal scopes retain their mapped assumptions, and discrete rules expose their frame
certificates. The [frontend](../../Automation/ProofMode/README.md) applies these rules.

*Last verified: 2026-11-18*
