# Phase 8 decision record

## The `tactic*` declarations: 11 renamed, 7 exempted

The plan budgets a decision on "the 19 `tactic*` syntax declarations". The measured set is **18**
(Phase 5.1 established this), plus **two** the Phase 5.1 exclusion list got wrong, for 20
findings total after Phase 6.

### Decision rule as applied

The plan's rule: grep `docs/`, `README.md`, `Examples/` for each tactic token; internal-only
tokens are renamed, documented user-facing tokens get `@[nolint defsWithUnderscore]` with a
one-line rationale naming the token.

| Tactic token | `docs/` refs | Lean refs | Decision |
|---|---:|---:|---|
| `apply_axiom` | 47 | 43 | **exempt** |
| `modal_t` | 140 | 234 | **exempt** |
| `assumption_search` | 19 | 36 | **exempt** |
| `modal_k_tactic` | 4 | 10 | **exempt** |
| `temporal_k_tactic` | 3 | 7 | **exempt** |
| `modal_4_tactic` | 12 | 17 | **exempt** |
| `modal_b_tactic` | 3 | 15 | **exempt** |
| `modal_norm` | 0 | 26 | rename -> `modalNorm` |
| `prop_norm` | 0 | 3 | rename -> `propNorm` |
| `modal_op_norm` | 0 | 3 | rename -> `modalOpNorm` |
| `temporal_norm` | 0 | 4 | rename -> `temporalNorm` |
| `modal_norm_all` | 0 | 2 | rename -> `modalNormAll` |
| `modal_fold` | 0 | 8 | rename -> `modalFold` |
| `prop_decide` | 0 | 22 | rename -> `propDecide` |
| `order_refl` | 0 | 8 | rename -> `orderRefl` |
| `order_rev` | 0 | 1 | rename -> `orderRev` |
| `same_order_type_grid` | 0 | 5 | rename -> `sameOrderTypeGrid` |
| `same_order_type_grid_uh` | 0 | 3 | rename -> `sameOrderTypeGridUh` |

126 occurrences rewritten across 16 files.

Before renaming, each internal-only token was checked for a **non-tactic homonym** — a `def`,
`theorem`, or constructor of the same name that a whole-word rewrite would also hit. None had
one. This check is not optional: `modal_t` is simultaneously a tactic token *and* the
constructor `Axiom.modal_t`, and a whole-word rename of `modal_t` would have silently corrupted
234 axiom references. It landed in the exempt column for an unrelated reason, which is luck, not
design.

### Two tokens the plan's list did not contain

- **`modal_norm_at`** (`Normalization.lean:207`) was **not** flagged by the linter — its
  generated declaration name ends in `_`, and `isBadNameWithUnderscore` skips those. It was
  renamed anyway: leaving `modal_norm_at` beside a renamed `modalNorm`/`modalNormAll` would
  have created an incoherent tactic family as a *consequence* of this phase's own work.
- **`tm_lemma`** (`LemmaDB.lean:45`, `register_label_attr`) is a label attribute, not a tactic.
  Same structural class — a name Lean auto-generates from a user-written token — and the same
  rule applies: `docs/` refs 0, so renamed to `tmLemma`, across 38 sites including the two raw
  `` `tm_lemma `` `Name` literals that Phase 7.1 deliberately deferred here.

### The one non-generated name

`Separation.sNestingAboveU.S_nesting_above_U_inner` is not auto-generated at all. It is a
`where`-clause helper spelled literally in source, which the Phase 5.2 table excluded as a
"parent-derived auxiliary" on the theory that Lean regenerates such names from the parent's.
**That theory is false for `where` helpers**: renaming the parent moved only the namespace
component. Renamed to `sNestingAboveUInner`; 8 occurrences in one file.

The other two excluded auxiliaries (`iddfs_search.iterate`, `bestFirst_search.searchLoop`) *are*
genuinely parent-derived and did follow the parent, which is why the error was not symmetric and
why it survived the Phase 5.2 collision audit.

## Recorded dissent: why the exempt column is not smaller

The plan's rename branch implicitly assumes that renaming a tactic token yields a *more*
conformant result. Reading the linter source contradicts that:

```
-- Mathlib/Tactic/Linter/Style.lean, isBadNameWithUnderscore
(`Mathlib.Tactic).isPrefixOf declName || (`Parser).isPrefixOf declName || ...
```

Mathlib has exactly these declarations — `macro "push_neg"` produces `tacticPush_neg` — and
escapes the linter by **whitelisting its own namespace prefix**, not by camelCasing tokens. Every
Lean tactic token is snake_case. So a camelCase tactic token is *less* idiomatic, and the
rename branch buys linter conformance at the cost of surface conformance.

The plan's rule was nonetheless applied as written, because it is executable and the plan is the
contract: the 11 internal-only tokens were renamed rather than exempted. The observation is
recorded here, and in `NAMING_CONVENTION_DEVIATION.md`, so the owner can revisit it as a
deliberate choice rather than rediscover it. Reverting any of the 11 to snake_case is a
mechanical change plus one more line in the `attribute [nolint …]` block.

## `scripts/nolints.json`: deleted

Removed from the tree with `git rm` — not filtered, not emptied. 860 entries.

## Final linter reading, `nolints.json` absent

`lake exe batteries/runLinter FormalSystem`, parsed with `tools/runlinter.py` (the tool that
breaks `LINTER FAILED` out of `simpNF`, so these figures are comparable only to
`baseline/linter-unmasked.json` produced by the same tool):

| Category | Phase 1 unmasked | Final | Delta |
|---|---:|---:|---|
| `defsWithUnderscore` | 861 | **0** | **-861** |
| `unusedArguments` | 124 | 124 | 0 |
| `LINTER FAILED` | 115 | 115 | 0 |
| `docBlame` | 39 | 39 | 0 |
| `tacticDocs` | 4 | 4 | 0 |
| `structureInType` | 1 | 1 | 0 |
| **total** | 1144 | **283** | -861 |

283 = 1144 − 861 exactly. Every sibling category is unchanged to the unit, which is the evidence
that the target count fell by conformance and not by silencing something adjacent.

## Deliberately-retained old spellings

A final whole-word sweep for old declaration finals across `FormalSystem/` (excluding
`Boneyard/`), `Tests/`, `docs/`, `typst/`, `latex/`, and `README.md` returns **four** hits, all
intentional:

| Site | Text | Why |
|---|---|---|
| `Semantics/Truth.lean:432` | `lem:history-time-shift-preservation` | paper cross-reference label, not the declaration `lem`; same `prefix:label` convention as `def:frame`, `app:TaskSemantics` |
| `Automation/Tactics/Helpers.lean:1167` | `tm_lemma` | the decision record naming the token it renamed |
| `docs/development/NAMING_CONVENTION_DEVIATION.md:126` | `tm_lemma` | same |
| `docs/development/LEAN_STYLE_GUIDE.md:72` | `def swap_temporal ...` | an `-- Avoid` example deliberately showing the wrong form |
