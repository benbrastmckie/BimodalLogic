# Naming Convention Deviation: `defsWithUnderscore`

**Status: interim.** This document records a deliberate, time-bounded engineering position, not a
permanent architectural decision. A full migration of the affected names to `lowerCamelCase` is
planned as separate work; the suppression described here exists so that the linter surface is
clean and reviewable *now*, while that migration is designed and executed with its own research
and verification strategy. See [What replaces this](#what-replaces-this).

## What the deviation is

Mathlib's `defsWithUnderscore` environment linter flags any `def` whose name contains an
underscore, on the convention that `def`s take `lowerCamelCase` and only `theorem`s take
`snake_case`. This repository currently has **860** declarations that the linter flags. They are
suppressed via a curated [`scripts/nolints.json`](../../scripts/nolints.json) containing exactly
those 860 entries and nothing else.

Alongside the suppression, the declarations that were *genuinely* misclassified have been fixed
rather than suppressed — see [What was actually fixed](#what-was-actually-fixed).

## Why the names are `snake_case` today

The names read as mathematics. `box_conj_iff`, `perpetuity_5`, and `s4_box_diamond_box` are the
project's rendering of statements from the modal-logic literature, and the underscore is doing the
same work a space does in prose. Under `lowerCamelCase` they become `boxConjIff`, `perpetuity5`,
and `s4BoxDiamondBox`, which is a readability cost concentrated exactly in the layer where the
library's mathematical content lives.

That said, this is a *stylistic* argument, and it is not the whole story — see the next section
for the part that is structural, and [What replaces this](#what-replaces-this) for why the
stylistic argument was ultimately judged insufficient to settle the question permanently.

## The architectural root cause

`DerivationTree`, defined in
[`Theories/Bimodal/ProofSystem/Derivation.lean`](../../Theories/Bimodal/ProofSystem/Derivation.lean),
is `Type`-valued rather than `Prop`-valued. Every derived result built from it therefore *must* be
a `def` rather than a `theorem` — and `def` is precisely what this linter inspects. A result that
is mathematically a theorem is forced by the encoding into the syntactic category the linter
treats as data.

The `Type`-valued encoding is load-bearing, not incidental:

- `DerivationTree.height` is a computable `Nat`-valued recursor over the tree, with dozens of
  references. It cannot be recovered from a `Nonempty` witness.
- The `Automation/` proof-search layer consumes actual derivation trees — it inspects and
  transforms proof structure, so `Nonempty (DerivationTree …)` would not serve.

**Scope of this explanation.** It is precise for the `Theorems/` layer, where it accounts for
100% of the findings. It does *not* extend to the ordinary data definitions elsewhere in the
library, whose `snake_case` names are a plain stylistic choice with no structural forcing behind
them. Conflating the two would overstate the case: the structural argument covers a minority of
the 860, and the majority are style.

## Upstream precedent for curated suppression

Mathlib's own `scripts/nolints.json` carries **719** entries, of which **493** are
`defsWithUnderscore` (the remaining 226 are `docBlame`). Mathlib carries **zero** inline
`@[nolint defsWithUnderscore]` attributes — it treats this linter as a curated suppression list
rather than a hard gate, and keeps the entire list in one auditable file.

This repository follows that mechanism exactly: one JSON file, no inline attributes. Note for
proportion, though, that 860 entries is roughly 1.7× Mathlib's own volume in a codebase a
fraction of its size — which is itself part of why the deviation is treated as interim rather
than settled.

## What was actually fixed

Suppression was applied only to the residual. Thirty-eight declarations were genuinely
misclassified — `Prop`-typed `def`s that should always have been `theorem`s — and these were
converted rather than suppressed:

| Linter | Before | After |
|---|---|---|
| `linter.defProp` | 38 | **0** |
| `classDefReducibility` | 2 | **0** |
| `defsWithUnderscore` | 888 | 860 (suppressed to **0**) |

The conversion dropped the `noncomputable` modifier on the 31 declarations that carried it
(`noncomputable theorem` does not elaborate) and removed one `@[instance_reducible]` attribute
that is invalid on a `theorem`. Total build warnings fell from 70 to 30 with none added. No
declaration was renamed.

## How to re-audit: a green build proves nothing here

This is the single most important operational fact in this document.

`defsWithUnderscore` is an *environment* linter. It emits **nothing** during `lake build`, and CI
runs `lean-action` with `lint: false`. A green build therefore carries **no information** about
this category. The only gate that observes it is an explicit:

```
lake exe runLinter Bimodal
```

`nolintsFile` resolves to `scripts/nolints.json` relative to the invocation working directory, so
run this from the repository root. Expect `defsWithUnderscore` to be absent from the output, and
the sibling categories (`unusedArguments`, `simpNF`/`LINTER FAILED`, `docBlame`, `tacticDocs`,
`structureInType`) to remain live and unchanged.

> **Trap when regenerating.** `lake exe runLinter Bimodal --update` rewrites
> `scripts/nolints.json` in one command, but it is **indiscriminate**: it sweeps in every other
> linter category too. On the run that produced the current file it emitted 1141 rows, of which
> 281 belonged to unrelated categories. Any regeneration must filter the output back down to
> `defsWithUnderscore` rows only, and must then verify that the sibling category counts are
> *unchanged* — a sibling count that dropped is a silenced linter, not a bonus.

## What replaces this

A full migration of the affected names to `lowerCamelCase` is planned as separate work. When it
lands, `scripts/nolints.json` entries are expected to be **deleted as the migration progresses**.
The file is a checkpoint, not an asset to be maintained in perpetuity; a growing nolints file
would be a regression, not a neutral event.

### What the migration will have to contend with

Recorded here so the migration inherits these figures rather than rediscovering them. Usage counts
are resolved, elaborator-authoritative references drawn from the `references` blocks of the
compiled `.ilean` files — not textual matches.

| Metric | Value |
|---|---|
| Resolved usages of the flagged names | **24,364** |
| Modules containing at least one usage | **258 of 300 (86%)** |
| Flagged names that are a proper prefix of another project identifier | **398 of 873 (45.6%)** |
| Sites a naive substring pass would touch | **68,076** |
| Of those, sites it would touch *wrongly* | **46.4%** |

Three consequences follow, and each is a hard constraint on how the migration may be executed:

1. **Identifier-prefix collision is the central hazard.** With 45.6% of the names being proper
   prefixes of other identifiers, a substring replacement is not merely risky but wrong at scale —
   nearly half of the sites it touches. Position-anchored replacement, driven by resolved
   reference positions rather than by text matching, is **mandatory**. A prior sweep in this
   repository silently corrupted `List.take_succ_cons` precisely because `List.take_succ` is a
   prefix of it.

2. **Deprecation shims make the problem worse, not better.** A `@[deprecated] alias` retains the
   old `snake_case` name as a new `def`, so it is itself flagged: adding one alias measurably
   raised `defsWithUnderscore` from 860 to **861**. Shims cannot be used as a soft-landing
   strategy for this particular linter.

3. **The churn is concentrated in data names, not in the mathematical layer.** This inverts the
   intuition suggested by the architectural argument above. The 12 flagged names in
   `Theories/Bimodal/Syntax/Formula.lean` carry **4,929** resolved usages — roughly 5× the entire
   `Theorems/` layer, whose 135 flagged declarations account for 994. `all_future` alone has 1,647
   usages. Any migration should expect its cost to be dominated by a handful of `Formula`
   constructor-adjacent names, and should sequence accordingly.

### What would independently reopen or force the decision

A port into a downstream library that enforces the environment linters as a hard gate. In that
setting curated suppression is not available, and the migration becomes a prerequisite rather
than a planned improvement.

## Related

- [`LEAN_STYLE_GUIDE.md`](LEAN_STYLE_GUIDE.md) — the naming conventions this document records a
  deviation from
- [`scripts/nolints.json`](../../scripts/nolints.json) — the suppression list itself
- [`Theories/Bimodal/ProofSystem/Derivation.lean`](../../Theories/Bimodal/ProofSystem/Derivation.lean)
  — the `Type`-valued `DerivationTree` that forces `def` over `theorem`
