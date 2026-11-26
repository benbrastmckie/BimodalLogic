# Derivation proof mode

Named, compositional tactics for native TM and TM⁺ derivations. Import the sibling
[`ProofMode.lean`](../ProofMode.lean) aggregator; ordinary Lean tactics remain available.

## Modules

The shared formula planner and named views live in [Formulas and tactics](../../Tactic/README.md).

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation/ProofMode -->
| File | Lines | Description |
|------|------:|-------------|
| `Basic.lean` | 254 | Named assumptions, opaque application, cut, and propositional branches |
| `Carrying.lean` | 91 | Carrying table (`CarryRule`, `carryRules`, `carryRule?`, `carriedFacts`): one rule per source-operator/target-scope pair, shared by the scope tactics' `keeping` clause |
| `Discrete.lean` | 129 | Next/Previous scopes, invariance, and `linduction`, with the ZTime certificate reused or decided rather than always explicit |
| `Meta.lean` | 197 | Native judgment recognition and checked context adaptation |
| `Modal.lean` | 287 | Necessity, stability, and possibility scopes |
| `ModalBoolean.lean` | 21 | Preferred orientations for explicit simplifier rules |
| `Rewriting.lean` | 554 | Role/polarity-aware checked rewriting with explicit scope evidence |
| `RuleRegistry.lean` | 65 | Validated native schema registration and fixed simp orientations |
| `Simplification.lean` | 166 | Deterministic bounded normalization with decrease guards and rollback |
| `Temporal.lean` | 507 | Future/past scopes, eventuality composition and advance, the integer-time gate, Until/Since mapping and monotonicity, and whole-judgment time reflection |
| `TemporalBoolean.lean` | 170 | Strict leads-to composition |
| `TemporalZTime.lean` | 95 | Adjacent Until and Since expansion and contraction |
<!-- END GENERATED -->

The elaborators use the [pure derivation rules](../../Theorems/ProofMode/README.md).
Named proofs retain their source object contexts; changing scope requires a checked rule.
Use explicit `using [...]` to keep reusable proofs independent of unrelated outer assumptions.

See the [usage guide](../../../docs/user-guide/derivation-proof-mode.md) and
[examples](../../../Tests/BimodalTest/Automation/ProofModeTest.lean).

*Last verified: 2026-11-25*
