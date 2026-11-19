# Codex review: temporal branch, initial integrated source

Independent source review written before reading Opus's branch-2 review. This is a review of
P3, not a claim that the semantic milestones are complete. Targeted compilation and final
directory/documentation gates remain separate evidence.

| Criterion | Score / 10 |
| --- | ---: |
| Correctness and source grounding (30%) | 8.9 |
| Compositionality (25%) | 9.0 |
| Reuse (20%) | 8.4 |
| Predictable automation (15%) | 8.3 |
| Clarity and validation economy (10%) | 8.0 |

Weighted grade: **86.45/100**. Provisional GO for P3 after the named checks and any independent
review findings are resolved. The grade does not override a defect.

## Findings and dispositions

- **Required, fixed:** the staged frontend duplicated guarantee selection and mapped-context
  introduction. Moved both to `Modal.lean`; modal, temporal and discrete commands now share the
  checked substitution path. Moved pure `nextKeep`/`prevKeep` rules to the theorem layer.
- **Required, fixed:** the old `lapply` only exposed telescope arguments, missing implicit holes
  inserted while elaborating the theorem term. A common `proofParameters` helper now collects
  both routes; rewriting reuses it. Native application checks its result and is atomic. Generic
  temporal application also rolls back if its later frame-premise resolution refuses a rule.
- **Required, fixed:** literal reverse folding could specialize an undetermined pre-existing
  formula variable while identifying a view. It now refuses any such assignment.
- **Required checks:** targeted original/extension acceptance build, linter for public docstrings,
  structural/layer/README checks, inventory and book synchronization. Do not interpret a source
  review as evidence these ran.

## Rule audit

- Base fold and integer-time forward unfold remain asymmetric. Unfold cases retain X/Y in both
  alternatives, and both branches establish the common conclusion. No witness is extracted
  from a native tree.
- Native `untilIntro` uses G guard and F event; its past mirror uses H/P. Exact dual definitions
  preserve the existing event-first wrapper convention, while inclusive U/S stays guard-first.
  Literal AST equalities and native equivalences pin the inclusive expansion.
- Reflection maps the full assumption list with the conclusion. Its proof is contextual
  deduction plus closed reflection (native Plus lifting), not reflection of open assumptions.
- Current leads-to transitivity requires a persistent second guarantee; consequence requires
  a persistent postcondition map. Strict G never supplies a present-time premise.
- `keeping` preserves only G/H facts through temporal 4. Ordinary `using` unwraps once. The S2
  example composes opaque providers across two witnesses; no proof-body analysis is involved.
- ZTime premises reuse exact certificates or decided compatible concrete tags; abstract tags
  remain goals. The legacy shifted-context commands retain their explicit abstract gate.

## Deliberate limits

The dual-view command rewrites every exact occurrence; exact occurrence choice uses `lrewrite`
with an expansion equality. It does not invent congruence for wrappers with duplicated operands.
`keeping` is G/H only; other preservation theorems use the generic rule interface. Generic rule
application delegates to the statement instead of searching a theorem database. Semantic
witnesses, ranks, model changes and soundness remain branch 3 work.
