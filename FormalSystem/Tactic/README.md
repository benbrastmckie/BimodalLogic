# Tactic

The library's layer-0 metaprogramming directory: declarations that must sit strictly upstream of
every other module because of a compilation-unit constraint, not because of a mathematical
dependency.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Tactic -->
| File | Lines | Description |
|------|------:|-------------|
| `Attr.lean` | 104 | Every attribute and named simp set the library uses: `truth_norm`, `reflect_time_norm`, `formula_unfold`, `formula_fold`, `@[tmLemma]` |
| `Meta.lean` | 119 | Shared `MetaM` plumbing for derivability goals: goal recognition, head-symbol readers, context rebuilding |
<!-- END GENERATED -->

## The `Attr.lean` constraint

`Attr.lean` carries **attribute and simp-set declarations only** — no lemmas, no definitions, no
instances. Two facts force this:

1. `register_simp_attr` expands to an `initialize` block plus a `syntax` declaration, and neither
   the attribute nor the simp-set identifier is usable in the compilation unit that declares it.
   The declarations therefore have to live strictly upstream of every tag site and every
   `simp only` call site.
2. `FormalSystem/Init.lean` imports `Attr.lean`, and check C24 asserts that every module in the
   library's closure reaches `Init`. So `Attr.lean` is upstream of the entire library by
   construction — anything heavier placed here would be recompiled by every module in it.

`Attr.lean` imports `Lean` only. It may **not** import `FormalSystem.Init`: `Init` imports it,
and the reverse edge would be a cycle.

Because `Init` carries the declarations on every module's behalf, nothing in the library imports
`Attr.lean` directly. That is the point of the directory: the eleven upward
`import FormalSystem.Automation.{TruthNormAttr,NormalizationAttr,LemmaDB}` lines that `Syntax/`,
`Semantics/`, `ProofSystem/` and `Theorems/` used to carry were deleted outright when these
declarations moved here.

## `Meta.lean` carries no such constraint

`Meta.lean` is ordinary metaprogramming: the shared `MetaM` plumbing for derivability goals —
goal recognition, head-symbol readers, context rebuilding. It imports `FormalSystem.ProofSystem`
and `Lean`, reaches `FormalSystem.Init` in the usual way, needs no C24 exception, and is imported
by name at each of its three consumers (`Automation/Tactics/{Commands,Search}.lean` and
`Metalogic/Decidability/Propositional/Tactic.lean`).

It is in this directory for a different reason from `Attr.lean`: not a compilation-unit
constraint, but the absence of a natural home. Its consumers are spread across `Automation/` and
`Metalogic/`, so leaving it under `Automation/Tactics/` meant relocating `propDecide` into
`Metalogic/Decidability/Propositional/` would merely have traded one `Metalogic -> Automation`
import line for another.

## Related Documentation

- [FormalSystem README](../README.md)
- [`FormalSystem/Init.lean`](../Init.lean) — the module that imports `Attr.lean` on the whole
  library's behalf
- [`FormalSystem/Automation/`](../Automation/README.md) — the tactics and proof search that
  *read* these attributes
- [`ORGANISATION.md`](../../ORGANISATION.md) — the layer table this directory sits at the bottom of

---

*Last verified: 2026-09-20*
