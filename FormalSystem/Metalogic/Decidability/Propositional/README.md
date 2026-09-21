# Propositional — The Propositional Fragment of the Decision Procedure

The classical propositional core underneath the full bimodal tableau. Kept separate
because the propositional case is decidable by a self-contained Kalmár-style argument
that owes nothing to the modal or temporal machinery, and mixing the two would make
the bimodal decision procedure depend on a completeness result it does not need.

## Modules

| File | Lines | Role |
|------|------:|------|
| `PropForm.lean` | 234 | Propositional formula representation and the embedding of the propositional fragment of `Formula` |
| `Kalmar.lean` | 298 | Kalmár-style tautology soundness: a truth-table-valid propositional formula is derivable |
| `Decidable.lean` | 248 | Assembles the two into a decision procedure for the fragment |
| `Tactic.lean` | 158 | `propDecide`: the reflective tautology tactic that applies `Kalmar.lean`'s soundness theorem to a derivability goal |

## Position in the Layering

Inside `Metalogic/Decidability/`, beneath the full tableau procedure. `Decidable.lean`
imports `FormalSystem.Metalogic.Soundness` — the one place this fragment reaches outside
`Decidability/` — and all four modules are re-exported by the `Decidability.lean`
sibling aggregator.

`Tactic.lean` was `Automation/Tactics/PropDecide.lean` and moved here because it is the
tactic form of `Kalmar.lean`'s soundness theorem and belongs beside it: leaving it under
`Automation/` was the sole reason `Metalogic/Algebraic/BooleanStructure.lean` carried an
upward import into `Automation/`. It imports `FormalSystem.Tactic.Meta` (the shared `MetaM`
plumbing, at layer 0) and `Kalmar.lean`, and nothing else. `FormalSystem/Automation.lean`
imports it, so `propDecide` is still reachable from `import FormalSystem.Automation` — the
user-facing tactic surface did not change.

Nothing here imports any of the three completeness routes (`BXCanonical/`,
`WeakCanonical/`, `Algebraic/`). That independence is the point: the propositional
decision procedure is usable without the completeness development.

## Related Documentation

- [Decidability README](../README.md)
- [Metalogic architecture map](../../README.md)

---

*Last verified: 2026-09-07*
