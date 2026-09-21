# RetiredTactics -- the bespoke tactics measurement retired

Archived 2026-09-07.

Fourteen tactic declarations and two whole modules, retired together from
`FormalSystem/Automation/`. They did not die of a design change: they died of a **measurement**.
Every artefact here was found to have zero invocations anywhere in the live library and zero in
`Tests/`, counting only real invocations and not docstring mentions or the defining file's own
round-trip examples.

## CONVENTION: these files are GUARD-FIRST, unlike the rest of this archive

The archive-wide banner in [`../README.md`](../README.md) tells you to swap the two arguments of
every `Formula.untl` and `Formula.snce` before resurrecting an archived file. **That instruction
does not apply to anything in this directory**, exactly as it does not apply to
[`../BundleDeadHalf/`](../BundleDeadHalf/README.md). These files were live-tree files at the
moment they were archived, long after the guard-first migration, so they already read the current
way round. Applying the banner's swap to them would silently invert their meaning while still
compiling -- precisely the failure the banner exists to prevent.

The occurrences that would be affected are the `modalFold` fold-lemma orientations in
`Normalization.lean` (`Formula.bot.untl φ = φ.next` and `Formula.bot.snce φ = φ.prev`), which are
written guard-first and are correct as they stand.

## What was retired, and the measurement that retired it

### The normalization tactic macros (`Normalization.lean`)

Seven `macro`/`syntax` tactic declarations lifted out of
`FormalSystem/Automation/Normalization.lean`, together with the round-trip `example` block that
was their only exercise.

| Tactic | Live invocations | Test invocations | Note |
|---|---:|---:|---|
| `modalNorm` | 0 | 0 | 17 occurrences, every one inside its own defining file's round-trip examples |
| `propNorm` | 0 | 0 | never invoked anywhere, including its own file |
| `modalOpNorm` | 0 | 0 | never invoked anywhere, including its own file |
| `temporalNorm` | 0 | 0 | one occurrence, in a docstring example |
| `modalNormAt` | 0 | 0 | one occurrence, its own `macro_rules` body |
| `modalNormAll` | 0 | 0 | never invoked anywhere |
| `modalFold` | 0 | 0 | 3 occurrences, all in its own file's fold tests |

**What stayed live.** The 21 `@[formula_unfold]` lemmas, the 10 `@[formula_fold]` lemmas, the
`EnrichedFormula` ADT, `Formula.foldFormula`, `EnrichedFormula.toPrimitive` and the whole
serialization layer all remain in `FormalSystem/Automation/Normalization.lean`. Only the
tactic wrappers left. Each was a one-line `simp only [...]` over a simp set that is still there,
so anything these tactics did is still available by writing the `simp only` out.

### The operator-K and modal-axiom tactics (`Helpers.lean`)

Four `elab` tactics and the factory that built two of them, lifted out of
`FormalSystem/Automation/Tactics/Helpers.lean`.

| Tactic | Live invocations | Test invocations | Note |
|---|---:|---:|---|
| `modal_k_tactic` | 0 | 0 | one occurrence, in its own docstring's example block |
| `temporal_k_tactic` | 0 | 0 | one occurrence, in its own docstring's example block |
| `modal_4_tactic` | 0 | 0 | one occurrence, in its own docstring's example block |
| `modal_b_tactic` | 0 | 0 | one occurrence, in its own docstring's example block |
| `mkOperatorKTactic` | 0 | 0 | the factory behind the first two; no other consumer |

The test files carried section headings and `/-- Test NN: modal_4_tactic ... -/` docstrings that
*named* these tactics, but the examples underneath them applied `DerivationTree.axiom` and the
axiom constructors directly and never invoked a tactic. Those headings were corrected in place
rather than deleted, so the axioms they exercise are still tested; what went away is the claim
that a tactic was under test.

`isBoxFormula`, `isFutureFormula`, `extractFromBox` and `extractFromFuture` -- the formula
predicates and extractors these tactics used -- **stayed live**: they carry genuine test
coverage of their own in `Tests/BimodalTest/Automation/TacticsTest.lean`.

### The `truth_simp` wrapper (`Automation/TruthNormAttr.lean`)

| Tactic | Live invocations | Test invocations | Note |
|---|---:|---:|---|
| `truth_simp` | 0 | 0 | six occurrences, every one its own docstring |

A `macro "truth_simp" loc? : tactic` expanding to `simp only [truth_norm] $loc?`. Same shape and
same measurement as the seven normalization wrappers above. The `truth_norm` and `swap_norm`
simp sets it fronted are untouched and still live; the `simp only` it expanded to is the same
length as the tactic and says what it does. Retired without a Boneyard copy of its own: the
declaration is three lines and is reproduced in this row.

### The `TMLogic` Aesop rule set (`AesopRules.lean`, `AesopRuleSet.lean`)

Two whole modules, 322 lines, moved unchanged.

`AesopRuleSet.lean` declares the `TMLogic` Aesop rule set; `AesopRules.lean` populates it with
`@[aesop safe apply (rule_sets := [TMLogic])]` attributes. Both files already carried a
deprecation notice recording that the tactic they were built for stopped using Aesop -- Aesop's
proof reconstruction fails on `DerivationTree`-valued goals, which are `Type`-valued rather than
`Prop`-valued. Because the rules live in a *dedicated* rule set, plain `aesop` never sees them,
and a `aesop (rule_sets := [TMLogic])` invocation is what would be needed to reach them. There
was no such invocation anywhere in the live tree or in `Tests/`. The rule set therefore had zero
consumers of any kind: it was not merely unused, it was unreachable.

## Resurrecting something from here

1. Read the guard-first note above; do **not** apply the archive banner's argument swap.
2. Both `Normalization.lean` and `Helpers.lean` here are **excerpts**, not whole modules: they
   carry the retired declarations plus the imports and `namespace` framing they need, not the
   surrounding file. Paste the declarations back into their original modules rather than
   restoring these files as modules.
3. Whatever you restore, restore a **caller** with it. Everything here was retired for having
   none, and a second retirement pass will find it again on the same evidence.
