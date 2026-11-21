# Derivation proof mode

Named, compositional tactics for native TM and TM⁺ derivations. Import the sibling
[`ProofMode.lean`](../ProofMode.lean) aggregator; ordinary Lean tactics remain available.

## Modules

The shared formula planner and named views live in [Formulas and tactics](../../Tactic/README.md).

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation/ProofMode -->
| File | Lines | Description |
|------|------:|-------------|
| `Basic.lean` | 212 | Named assumptions, opaque application, cut, and propositional branches |
| `Discrete.lean` | 86 | Next/Previous scopes and invariance with explicit ZTime certificates |
| `Meta.lean` | 179 | Native judgment recognition and checked context adaptation |
| `Modal.lean` | 274 | Necessity, stability, and possibility scopes |
| `Rewriting.lean` | 558 | Role/polarity-aware checked rewriting with explicit scope evidence |
| `RuleRegistry.lean` | 65 | Validated native schema registration and fixed simp orientations |
| `Simplification.lean` | 177 | Deterministic bounded normalization with decrease guards and rollback |
| `Temporal.lean` | 257 | Future/past scopes, eventuality composition, progress, and Until/Since mapping |
<!-- END GENERATED -->

The elaborators use the [pure derivation rules](../../Theorems/ProofMode/README.md).
Named proofs retain their source object contexts; changing scope requires a checked rule.
Use explicit `using [...]` to keep reusable proofs independent of unrelated outer assumptions.

See the [usage guide](../../../docs/user-guide/derivation-proof-mode.md) and
[examples](../../../Tests/BimodalTest/Automation/ProofModeTest.lean).

*Last verified: 2026-11-19*
