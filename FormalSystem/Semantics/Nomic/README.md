# Nomic — nomic frames, law-histories, and the nomic hierarchy

The frame-level half of the paper's nomic appendix. A **nomic frame** (`def:nomic-frame`) keeps
one carrier `W` and replaces the single task relation by a relativized family `⇒ʷ`, one task
relation per world state, each satisfying `def:frame`; the `w`-th member `F^w = (W, D, ⇒ʷ)` is an
ordinary task frame, its possible worlds are the **law-histories** `H_F^w`, and `H_F` is their
union over `w`.

## Modules

| File | Description |
|------|-------------|
| `Frame.lean` | `def:nomic-frame`, the derived family `NomicFrame.at`, the regularity class and the instance that feeds it back to `FrameOver.IsRegular`, the relativized `TaskRel`, `lawHist`/`HF` with the `WorldHistory` bridge `mem_lawHist_iff`, the three properties of `def:nomic-properties` (*Lawful*, *Static*, *Uniform*), the two implications from *Uniform*, and `lem:nomic-occurrence` |

## Siting, and its cost

This cluster sits under `Semantics/`, not under `OpenLanguage/`. A nomic frame mentions no object
language, no formula and no model, and every tool it consumes (`FrameOver`, `PartialHistory`,
`Extension`, `IntNormalForm`) lives under `Semantics/`. `OpenLanguage/` imports `Semantics/`,
never the reverse, so the nomic *operator* can live in `OpenLanguage/` and import these frames;
siting the frames under `OpenLanguage/` would invert that dependency and put `def:nomic-frame` in
a directory whose other modules are all about formulas.

**The cost, stated plainly**: the operator will then live in a different directory from its
frames, so it carries one extra import and the two halves of the nomic appendix are not
co-located. The alternative buys that co-location at the price of the dependency inversion and of
making the frames unreachable for a purely semantic consumer that does not want `OpenLanguage`'s
imports. The import direction is the deciding argument.

## Choice dependence

`lem:nomic-occurrence` is a theorem of **ZFC**, not of ZF: it applies `cor:occurrence` at `F^w`,
and that corollary runs through `thm:extension`, whose proof appeals to Zorn's lemma. `rmk:choice`
lists the paper's choice-free results and the nomic lemmas are not among them. Nothing in this
directory advertises them as choice-free.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Extension` (hence `TaskFrame`, `PartialHistory`)
- **Imported by**: `FormalSystem.Semantics.Nomic` (the sibling aggregator)

## Related Documentation

- [Semantics README](../README.md)
- [FormalSystem README](../../README.md)

---

**Last verified**: 2026-10-14
