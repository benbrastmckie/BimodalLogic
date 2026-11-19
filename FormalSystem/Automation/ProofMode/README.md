# Compositional proof modes

For native TM/TM⁺ trees, import [`ProofMode.lean`](../ProofMode.lean). For indexed semantic
truth and its explicit soundness seam, import [`Semantic.lean`](Semantic.lean). The typed
judgment selects the proof builder; ordinary Lean tactics remain available.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation/ProofMode -->
| File | Lines | Description |
|------|------:|-------------|
| `Basic.lean` | 235 | Named assumptions, opaque application, cut, and propositional branches |
| `Discrete.lean` | 172 | Next/Previous scopes and invariance with explicit ZTime certificates |
| `Meta.lean` | 285 | Native judgment recognition and checked context adaptation |
| `Modal.lean` | 285 | Necessity, stability, and possibility scopes |
| `Positions.lean` | 147 | Formula occurrences, derived views, reconstruction and bounded traversal |
| `Rewriting.lean` | 618 | Role/polarity-aware checked rewriting with explicit scope evidence |
| `RuleRegistry.lean` | 65 | Validated native schema registration and fixed simp orientations |
| `Semantic.lean` | 22 | Pointed semantic frontend aggregator, including rewriting, transport and soundness |
| `SemanticCore.lean` | 1,181 | Clause-directed logical/modal/temporal steps, witnesses, persistence and soundness |
| `SemanticMeta.lean` | 262 | Exact indexed truth views, clauses, point and proposition-type comparison |
| `SemanticRewriting.lean` | 487 | Signed scoped semantic rewriting with quantified evidence and explicit demands |
| `SemanticSimplification.lean` | 116 | Bounded decreasing semantic normalization with complete rollback |
| `SemanticTransport.lean` | 401 | Typed fact/goal certificates, locality recognition and converse-model reflection |
| `Simplification.lean` | 170 | Deterministic bounded normalization with decrease guards and rollback |
| `Temporal.lean` | 907 | Future/past scopes, eventuality composition, progress, and Until/Since mapping |
<!-- END GENERATED -->

The elaborators use the [pure derivation rules](../../Theorems/ProofMode/README.md).
Named proofs retain their source object contexts; changing scope requires a checked rule.
Use explicit `using [...]` to keep reusable proofs independent of unrelated outer assumptions.

See the [usage guide](../../../docs/user-guide/derivation-proof-mode.md) and
[examples](../../../Tests/BimodalTest/Automation/ProofModeTest.lean), plus the
[semantic guide](../../../docs/user-guide/semantic-proof-mode.md) and shared
[extension examples](../../../Tests/BimodalTest/Automation/ProofModeExtensionsTest.lean).

*Last verified: 2026-11-19*
