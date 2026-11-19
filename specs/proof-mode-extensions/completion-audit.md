# P0–P5 completion audit

Implementation branches stack in order: `feat/proof-mode-rewriting` (`fc85c61`),
`feat/proof-mode-temporal` (`1f545ea`), then `feat/proof-mode-semantics`.
The [implementation record](implementation.md) and [review directory](implementation-reviews/README.md)
retain the source inventory, independent grades and defect dispositions.

| Milestone | Required behavior | Implemented evidence |
| --- | --- | --- |
| P0 | Source directions, Plus schema substitution, conditional Next, pointed soundness | `source-inventory.md`; signed/Plus prototypes, Base Since fold and abstract-Γ soundness |
| P1 | Native signed congruence and composable demands | `Theorems/ProofMode/Congruence.lean`; checked TM/Plus step adapters and finite scope conversions |
| P2 | Goal/fact/equality rewriting; deterministic bounded simplification | Native `Rewriting`, `RuleRegistry`, `Simplification`; unique paths, explicit demands, actual decrease, frame gates and rollback |
| P3 | Strict U/S, dual/inclusive views, contextual reflection, progress and persistence | `TemporalComposition`, optional `TemporalViews`, shared modal/temporal scope helpers and `using rule` routes |
| P4 | Generic clauses, indexed witnesses, covers, explicit soundness, semantic rewriting | Lower `ProofModeRules`/`ProofModeTemporalRules`; `SemanticMeta`/`SemanticCore`/`SemanticRewriting`; `Metalogic/ProofModeSoundness` |
| P5 | Typed transport, repeated advance, occurrence-based rank progress | `ProofModeTransport`, `SemanticTransport`, generic rank theorem, native and semantic S2 examples |

Semantic release/trigger and weak Until/Since have four generic truth characterizations and
literal TM/Plus pins in `ProofModeIntervals`, imported by the semantic aggregator. Inclusive
views retain their endpoint guard separately. Semantic U/S witnesses and general-duration
covers are direct clause reasoning; native discrete unfolding retains its integer-time gate.

The shared extension module demonstrates all acceptance mechanisms, including mixed □/⊡/G
paths, refusal of current-only scope evidence, equality casts, fixed-direction simplification,
Base conditional Next, integer-time refusal, whole-context reflection, opaque-provider repeated
advance, covering witnesses, abstract-Γ soundness, rank occurrence premises and one-way transport.
Extra short regressions cover defects actually found in review (implicit holes, orphaned jobs,
parameter inference, native registration after semantic imports, and indexed side conditions).
It is one reused suite, without a language/operator cross-product. With dependencies cached, the extension module compiled in about
2–3 seconds in recorded runs; Lake job totals include cached dependencies.

## Trust and reuse

Native tactics construct source derivations. Semantic tactics consume existing truth clauses.
Soundness goes only from a native tree plus `fc.Sat F` and all context truths to the selected
point. Providers remain constants/local references; their proof bodies are not inspected.
No new Lean axiom, `sorry`, `unsafe` or `native_decide` is introduced. Representative axiom
prints contain only the existing `propext`, `Classical.choice` and `Quot.sound`.

Correspondence, shift, reversal, locality and history-morphism factories wrap existing theorems
with their actual hypotheses. Their points and valuation assumptions remain explicit. Fact and
goal directions are separate; no inverse is inferred from a one-way certificate. Typed Point
families instantiate only from the demanded point. Unknown semantic positions require explicit
proof instead of exploiting index erasure under definitional equality.

## Deliberate interface boundaries

- Public frontend languages are TM and TM⁺; pure semantic helpers are capability-parametric.
- Native U/S fold/unfold and Z1 induction are P3. Semantic generic durations use witnesses,
  covering evidence and supplied proved rules; there is no automatic integer induction.
- `lrewrite`/`lsimp` select the backend from the main goal. Mixed-kind facts can be transformed
  inside an ordinary `have` subproof with the intended judgment.
- Generic semantic rules may need an explicit carrier. Simplification elaborates rules per
  bounded attempt to freshen metavariables. A cache remains an optional measured optimization.
- Rich contracts/views, stored indices, counterfactuals, metric syntax and Veil integration are
  outside this plan's implementation scope, rather than missing P0–P5 work.

## Final verification

Final source builds and both proof-mode test targets pass with `--wfail`; the FormalSystem
linter passes. The full invariant script reports ALL CHECKS PASSED, README lint passes, and
book synchronization passes all four checks. Post-fix axiom, semantic registration and guide
probes pass. The [branch-3 closeout](implementation-reviews/branch3-closeout.md) records the
evidence. Both independent reviews' original scores are retained; required findings were
fixed and Opus gives source-level GO. No P0–P5 requirement remains open.
