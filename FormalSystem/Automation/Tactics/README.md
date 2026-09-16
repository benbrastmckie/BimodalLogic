# Tactics

Custom Lean 4 tactic implementations for TM bimodal logic proof development.

This subdirectory holds the tactic elaborators and the proof-search engine behind them.
`modal_search` is the single proof-search tactic: `tm_auto`, `temporal_search` and
`propositional_search` were removed after measurement showed they differed from it only in
`SearchConfig` weight fields that the search never read.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation/Tactics -->
| File | Lines | Description |
|------|-------|-------------|
| `Commands.lean` | 163 | The `modal_search` tactic: its `SearchConfig`, its two syntax forms, and the elaborators that run the search |
| `Deduction.lean` | 182 | `deduction`, `deduction n` and `undischarge`: frame-class-polymorphic applications of `Metalogic.Core.deductionTheorem` to derivability goals |
| `Meta.lean` | 99 | Reusable `MetaM` plumbing for derivability goals: goal recognition, head-symbol readers, context rebuilding -- the third of the old `Helpers.lean` that `PropDecide.lean` and `Commands.lean` share |
| `PropDecide.lean` | 158 | `propDecide`: reflective tautology tactic closing any derivability goal whose imp/bot skeleton is a propositional tautology, schematic in the reification environment |
| `Search.lean` | 657 | The bounded proof-search engine: `searchProof` and its five strategies, working in `TacticM` because `Axiom` is `Prop`-valued and `DerivationTree` is not |
| `UserTactics.lean` | 275 | The tactics a proof author writes by hand -- `apply_axiom`, `modal_t`, `assumption_search` -- and the `Formula` predicates and extractors that decide when they apply |
<!-- END GENERATED -->

## Key Definitions

- `modal_search`: bounded proof search for `Γ ⊢[fc] φ` goals. **The pedagogical entry point,
  not library infrastructure** -- it has three call sites in the whole repository, all in
  `Examples/`. Reach for it when demonstrating that a formula is derivable; do not build a
  proof on it.
- `propDecide`: reflective tautology tactic, and the one genuinely load-bearing tactic here
- `deduction` / `undischarge`: the deduction theorem in tactic form, for interactive
  `Type`-valued work. See `Deduction.lean`'s docstring for why they are not adopted inside
  `Metalogic/Core/DeductionTheorem.lean`.
- `apply_axiom`, `modal_t`: axiom-application macros
- `assumption_search`: context lookup with an explicit failure message

There is no Aesop rule set. One existed and was retired; see
[`Boneyard/RetiredTactics/README.md`](../../Boneyard/RetiredTactics/README.md).

## Dependencies

- **Imports from**: `FormalSystem.ProofSystem`, `FormalSystem.Theorems`,
  `FormalSystem.Metalogic.Core.DeductionTheorem`, `FormalSystem.Automation.LemmaDB`
- **Used by**: `FormalSystem.Automation` (re-exported), and `Examples/`

## Related Documentation

- [Automation README](../README.md)
- [ProofSearch subdirectory](../ProofSearch/README.md)

---

*Last verified: 2026-09-07*
