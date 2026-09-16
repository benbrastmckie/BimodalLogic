# Sweep Evidence Report: Task #586

**Task**: 586 — Rewrite `typst/chapters/p4-proof-automation.typ`'s tactic and Aesop sections against the retired-tactics tree
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Medium. Two prose sections and one table, all publication-facing, all verifiable against live source.
**Dependencies**: **591** — that task may rename modules in `Automation/`, and this chapter's Module Map enumerates them. Rewrite the table once, after the names are final.
**Sources/Inputs**:
- `bash scripts/typst-sync-check.sh` (Check 1 output)
- `typst/chapters/p4-proof-automation.typ`, `typst/sync-check-whitelist.txt`
- `FormalSystem/Automation/`, `FormalSystem/Automation.lean`, `FormalSystem/Boneyard/RetiredTactics/README.md`
- `specs/reviews/review-2026-09-16.md`, Finding M1

## Executive Summary

- **`scripts/typst-sync-check.sh` exits 1** with 4 Check-1 violations, all in this one chapter.
  Checks 2 and 3 (count freshness, machine-appendix freshness) pass.
- **The four flagged spans understate the problem.** They are the citations whose *paths* no
  longer resolve. The chapter also describes, in the present tense, a tactic that was removed and
  a module that was archived — and its Module Map table has three of seven rows naming files that
  do not exist where it says, with every line count stale.
- **The cause is the 2026-09-07 retirement** recorded in `FormalSystem/Boneyard/RetiredTactics/README.md`:
  fourteen tactic declarations and two whole modules were archived *on measured evidence* of zero
  invocations anywhere in the live library or `Tests/`. That was a good decision, correctly
  recorded; the chapter simply was not updated with it.
- **This is publication-facing.** A reader following the chapter reaches for tactics that do not
  exist.

## The four flagged violations

```
VIOLATION: `AesopRules.lean`                  -- path does not exist under FormalSystem/ (excl. Boneyard/)
VIOLATION: `Automation/Tactics/Helpers.lean`  -- path does not exist
VIOLATION: `Tactics/Helpers.lean`             -- path does not exist
VIOLATION: `tm_auto 5`                        -- multi-word span not found verbatim in Lean source
TOTAL_VIOLATIONS=4
```

Both named files are now in `FormalSystem/Boneyard/RetiredTactics/` (`AesopRules.lean`,
`AesopRuleSet.lean`, `Helpers.lean`, `Normalization.lean`).

## What actually changed in the tree

Per `FormalSystem/Automation.lean`'s own module docstring:

> `modal_search`: Bounded proof search for TM derivability goals — **the single proof-search entry
> point. It replaced `temporal_search`, `propositional_search` and `tm_auto`**, which differed
> from it only in `SearchConfig` weight fields that `searchProof` never read, and which have been
> removed.

And `apply_axiom` / `modal_t` now live in `FormalSystem/Automation/Tactics/UserTactics.lean`
(275 lines), not in the archived `Helpers.lean`.

## Section-by-section damage

### `== Tactics` (chapter line ~20)

States "Three user-facing tactics automate common derivation patterns; `apply_axiom` and
`modal_t` live in `Automation/Tactics/Helpers.lean`, and `tm_auto` in `Tactics/Commands.lean`."
All three locations are wrong and `tm_auto` no longer exists. The `#items` block then documents
`tm_auto`'s delegation to `runModalSearch` with `SearchConfig.default` and its `tm_auto 5` depth
override, and the following paragraph makes `tm_auto` the worked example for the whole bounded-
search section. The closing line cites `temporal_search` and `propositional_search` as "related
tactics" — both removed.

### `== Aesop Integration` (chapter line ~33)

Four paragraphs describing `AesopRules.lean`'s rule registrations (7 axiom apply rules, 7
forward-chaining variants, 3 inference-rule apply rules, 4 normalization unfold rules), its
exclusions, its use of Aesop's default rule set, and advice on when to "reach for plain `aesop`"
versus `tm_auto`. The file is archived and `tm_auto` is gone, so the section describes archived
code as live from beginning to end. It should be deleted, or rewritten as a short historical note
pointing at `Boneyard/RetiredTactics/README.md` and the measurement that retired it — which is
genuinely interesting content for a chapter about proof automation, and arguably better than what
is there now.

### `== Module Map` table

| Table row | Claimed lines | Reality |
|---|---|---|
| `Tactics/Helpers.lean` | 1,032 | **absent** — archived to `Boneyard/RetiredTactics/` |
| `Tactics/Commands.lean` | 710 | live, **586** |
| `ProofSearch/Core.lean` | 1,195 | live, **1,283** |
| `ProofSearch/Strategies.lean` | 379 | live, **401** |
| `AesopRules.lean` | 276 | **absent** — archived |
| `SuccessPatterns.lean` | 423 | live, **429** |
| `EFGameTactics.lean` | 326 | exists at `Metalogic/WeakCanonical/EFGameTactics.lean`, **not under `Automation/`** — the table's caption says it covers "the tactic and proof-search half of `Automation/`" |

Missing entirely: `Tactics/UserTactics.lean` (275), `Tactics/Deduction.lean` (182),
`Tactics/Meta.lean` (99), `Tactics/PropDecide.lean` (158), `Tactics/Search.lean` (657).

The caption claims "(live line counts)" and the paragraph below asserts "All modules in the table
are sorry-free" — a claim that cannot be true of two absent files.

## Note on the generated-inventory option

`scripts/check-module-invariants.sh --emit-inventory` owns generated inventory tables in
*markdown* via `<!-- BEGIN GENERATED: inventory dir=… -->` markers. This table is in Typst and is
hand-maintained. Consider whether it is worth teaching the emitter a Typst dialect, or whether
`typst-sync-check.sh` Check 2 (which already recomputes counts from live source for
`generated/status.typ`) should be extended to cover it. Either would prevent recurrence; a
hand-fix would not. That evaluation is in scope for this task even if the answer is "hand-fix for
now, and record why."

## Recommended approach

1. Verify the current tactic surface directly from `FormalSystem/Automation/Tactics/*.lean` and
   `FormalSystem/Automation.lean`'s docstring — do not infer it from the chapter.
2. Rewrite `== Tactics` around `modal_search`, `apply_axiom`, `modal_t` and the actual
   `UserTactics.lean` / `Commands.lean` split.
3. Replace `== Aesop Integration` with either nothing or a short retirement note citing the
   measurement in `Boneyard/RetiredTactics/README.md`.
4. Regenerate the Module Map from live source, including the five currently-missing modules, and
   either drop `EFGameTactics.lean` or re-caption the table to say it is included as a
   cross-reference.
5. Decide the recurrence question (generated vs hand-maintained) and record the decision.
6. Only add to `typst/sync-check-whitelist.txt` what is genuinely "intentional exposition, not a
   claim" — the whitelist is not the fix here.

## Verification

- `bash scripts/typst-sync-check.sh` exits 0 (`TOTAL_VIOLATIONS=0`, and Checks 2/3 still pass).
- `typst compile typst/BimodalReference.typ build/BimodalReference.pdf` succeeds.
- Every module named in the rewritten chapter resolves to a live file, and every line count
  matches `wc -l` at the time of the commit.
- No claim in the chapter describes an archived declaration in the present tense.
