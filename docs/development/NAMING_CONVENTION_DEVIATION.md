# Naming Convention Deviation: `defsWithUnderscore` — CLOSED

**Status: closed.** The deviation this document recorded no longer exists. The migration it named
as its successor has landed: every affected declaration was renamed to Mathlib conventions,
`scripts/nolints.json` was deleted from the tree, and
`lake exe batteries/runLinter FormalSystem` reports `defsWithUnderscore = 0` by genuine
conformance.

This file is retained rather than deleted because two things in it survive the migration: the
architectural root cause, which is still true and still shapes the `Theorems/` layer, and the
operational warning about what does and does not count as evidence for this linter.

## Outcome

| Measure | Before | After |
|---|---|---|
| `defsWithUnderscore`, unmasked | **861** | **0** |
| `scripts/nolints.json` | 860 entries | **deleted from the tree** |
| Inline `@[nolint defsWithUnderscore]` attributes | 0 | **7**, all on auto-generated `tactic*` names |
| `unusedArguments` | 124 | 124 |
| `LINTER FAILED` | 115 | 115 |
| `docBlame` | 39 | 39 |
| `tacticDocs` | 4 | 4 |
| `structureInType` | 1 | 1 |

Every sibling category is unchanged to the unit, which is the evidence that the count fell by
conformance rather than by silencing something.

Alongside the renames, the library root moved from `Theories/Bimodal/` to `FormalSystem/` and the
root namespace `Bimodal` became `FormalSystem`.

## The naming rule now in force

Keyed on what a declaration *produces*, not on which command declares it:

| Declaration produces | Convention | Example |
|---|---|---|
| data (including all `DerivationTree`-valued results) | lowerCamelCase | `allFuture`, `swapTemporal` |
| a `Prop` — i.e. it *defines a predicate* | UpperCamelCase | `TruthAt`, `TemporalTruth`, `IsRDefinableGap` |
| a `Sort`/`Type` | UpperCamelCase | `TaskFrame` |
| a proof (`theorem`/`lemma`) | snake_case | `soundness`, `truth_lemma` |

The `Prop`-valued row is the one that surprises. `α → Prop` has type `Type`, not `Prop`, so a
predicate definition **cannot** be restated as a `theorem` — the conversion is a type error, not
a judgement call. 121 declarations fell in this category, `Semantics.TruthAt` (515 resolved
usages) among them.

## The architectural root cause — still true

`DerivationTree`, defined in
[`FormalSystem/ProofSystem/Derivation.lean`](../../FormalSystem/ProofSystem/Derivation.lean), is
`Type`-valued rather than `Prop`-valued. Every derived result built from it therefore *must* be a
`def` rather than a `theorem` — and `def` is precisely what this linter inspects. A result that is
mathematically a theorem is forced by the encoding into the syntactic category the linter treats
as data.

The `Type`-valued encoding is load-bearing, not incidental:

- `DerivationTree.height` is a computable `Nat`-valued recursor over the tree, with dozens of
  references. It cannot be recovered from a `Nonempty` witness.
- The `Automation/` proof-search layer consumes actual derivation trees — it inspects and
  transforms proof structure, so `Nonempty (DerivationTree …)` would not serve.

**What the migration changed about this argument**: nothing structural. The `Theorems/` layer is
still 135-of-135 `DerivationTree`-valued and still declared with `def`. What changed is the
conclusion drawn from it. The old reading was that a mathematically-theorem-shaped result
deserves a theorem's `snake_case` name and the linter should be suppressed. The rule that
actually applies keys on the syntactic category, so those declarations now take lowerCamelCase
(`impTrans`, `perpetuity3`, `boxMono`) and the linter is satisfied without any exemption.

**Scope of the explanation, unchanged.** It was always precise for `Theorems/` and never extended
to the ordinary data definitions elsewhere in the library, whose names were a plain stylistic
choice. The migration confirmed the proportion: the churn was dominated by data names, not by the
mathematical layer.

## How to re-audit: a green build still proves nothing here

This remains the single most important operational fact in this document, and deleting
`nolints.json` did not change it.

`defsWithUnderscore` is an *environment* linter. It emits **nothing** during `lake build`, and CI
runs `lean-action` with `lint: false`. A green build therefore carries **no information** about
this category. The only gate that observes it is an explicit:

```
lake exe batteries/runLinter FormalSystem
```

Plain `lake exe runLinter` fails — the package declares no `lintDriver`. Expect
`defsWithUnderscore` to be absent from the output, and the sibling categories to remain live and
unchanged at the counts tabulated above.

> **Trap when parsing the output.** batteries pretty-prints `@Name` for declarations with
> implicit arguments. A parser that does not strip the leading `@` silently loses **425 of 861**
> names — measured, not estimated.

## The surviving exemptions, and why they are not a new suppression file

Seven in-source attributes in
[`FormalSystem/Automation/Tactics/Helpers.lean`](../../FormalSystem/Automation/Tactics/Helpers.lean):

```lean
attribute [nolint defsWithUnderscore]
  tacticApply_axiom          -- from the `apply_axiom` tactic token
  tacticModal_t              -- from the `modal_t` tactic token
  tacticAssumption_search    -- from the `assumption_search` tactic token
  tacticModal_k_tactic       -- from the `modal_k_tactic` tactic token
  tacticTemporal_k_tactic    -- from the `temporal_k_tactic` tactic token
  tacticModal_4_tactic       -- from the `modal_4_tactic` tactic token
  tacticModal_b_tactic       -- from the `modal_b_tactic` tactic token
```

Each of these names is **auto-generated by Lean** from a tactic token: `macro "modal_t" : tactic`
produces a declaration called `tacticModal_t`. The underscore is inherited from the token, and
every Lean tactic token is snake_case (`simp_all`, `norm_num`, `push_neg`, `field_simp`).

Mathlib has exactly the same declarations and escapes the linter not by camelCasing them but
because `isBadNameWithUnderscore` (`Mathlib/Tactic/Linter/Style.lean`) whitelists the
`Mathlib.Tactic` namespace prefix outright. This repository's tactics live under
`FormalSystem.Automation`, so they are not covered by that whitelist.

The seven exempted tokens are the ones referenced from `docs/`, where renaming would be a
user-facing API break. Internal-only tokens were renamed instead rather than exempted:
`modal_norm`, `prop_norm`, `modal_op_norm`, `temporal_norm`, `modal_norm_all`, `modal_norm_at`,
`modal_fold`, `prop_decide`, `order_refl`, `order_rev`, `same_order_type_grid`,
`same_order_type_grid_uh`, and the `tm_lemma` label attribute.

**Why this is categorically different from the deleted file.** A per-declaration in-source
attribute is reviewable in the diff that introduces it, states its reason at the site, and
travels with the declaration. A central JSON list accumulates entries nobody re-justifies — and
it fails silently: during this migration, renaming the root namespace made all 860
fully-qualified entries stop matching at once, and the masked count jumped from 284 to 1144
without a single line of the file changing. That failure mode is a property of the mechanism,
not an accident.

## What would reopen this

Nothing about the naming rule itself; full Mathlib conformance is now the settled convention and
is recorded in [`LEAN_STYLE_GUIDE.md`](LEAN_STYLE_GUIDE.md). The remaining live question is
narrower: if Mathlib's linter ever stops whitelisting the `Mathlib.Tactic` prefix and starts
requiring camelCase tactic tokens, the seven exemptions above become renames.

## Related

- [`LEAN_STYLE_GUIDE.md`](LEAN_STYLE_GUIDE.md) — the naming conventions, now describing the
  settled state rather than a deviation from it
- [`FormalSystem/ProofSystem/Derivation.lean`](../../FormalSystem/ProofSystem/Derivation.lean)
  — the `Type`-valued `DerivationTree` that forces `def` over `theorem`
- [`FormalSystem/Boneyard/README.md`](../../FormalSystem/Boneyard/README.md) — the one tree
  deliberately left un-migrated
