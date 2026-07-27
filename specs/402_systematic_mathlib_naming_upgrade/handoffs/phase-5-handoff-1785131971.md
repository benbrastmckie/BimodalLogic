# Handoff after Phase 5.2 (REVIEW GATE reached)

## Immediate next action

**Phase 6.1 must NOT begin until a human accepts `target-names/README.md`.** The plan makes
Phase 5.2 the terminus of an autonomous run for exactly this reason.

Two items need an explicit decision before Phase 6:

1. **`truth_at` -> `TruthAt`, not `truthAt`.** The classifier finds `Semantics.truth_at` is
   `Prop`-valued after telescoping, so the plan's own three-branch rule mandates
   UpperCamelCase. The plan's worked example (`truthAt`) predates that rule -- it comes from
   the research mechanism experiment, where the rename existed only to prove the rewriter
   worked. This is the most-referenced declaration in the migration.
2. **The two collision overrides**: `apply_modus_ponens -> applyModusPonensRule` and
   `r_definable_gap -> IsRDefinableGap`.

## State

Phases 1, 2, 3, 4.1, 4.2, 5.1, 5.2 COMPLETE and committed, each ending green.

| Invariant | Value |
|---|---|
| `lake build` | GREEN, 1883 jobs |
| `lake build BimodalTest` | GREEN, 1923 jobs |
| live `sorry` outside `Boneyard/` | 1, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`, in `theorem countermodel_discrete` |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED |
| masked `defsWithUnderscore` | 1 (the known `temp_linearity_derivation` drift entry) |
| unmasked `defsWithUnderscore` | 855 (861 baseline minus 6 Phase 4.1 deletions) |
| new axioms | 0 |
| `@[deprecated]` aliases introduced | 0 |

Part A is fully done: the library lives at `FormalSystem/` with root module `FormalSystem.lean`,
the root namespace is `FormalSystem`, and `scripts/nolints.json` entries are reprefixed.

## What Phase 6 consumes

`target-names/target-names.tsv` -- 845 rows, columns
`old_name / target_final / full_target / category / module / usages / source`.

Regenerate with `python3 specs/402_.../tools/derive_names.py` (never hand-edit); resolutions
live in the `OVERRIDE` dict at the top of that file.

## Phase 6.1 procedure (unchanged from the plan)

```
bash .claude/scripts/git-snapshot.sh 402
lake clean && lake build                     # ~9 min, one fresh complete .ilean corpus
python3 specs/402_.../tools/rename.py \
    --map specs/402_.../target-names/target-names.tsv \
    --rejections specs/402_.../guard-rejections.md \
    --plan specs/402_.../edit-set.json \
    --apply
lake build 2>&1 | tee specs/402_.../build-errors-initial.txt
```

`rename.py --apply` already implements the single-snapshot, one-pass, per-line right-to-left
discipline (postmortem constraint 4) and refuses to write overlapping spans.

**Run `rename.py --self-test` first**: it must report >= 99.7% and reproduce only the five
known mismatch buckets. It measured 99.8126% on the current corpus.

## Tooling built (all in `specs/402_.../tools/`)

| Tool | Purpose |
|---|---|
| `ilean.py` | `.ilean` v5 loader; 0-indexed lines, UTF-16 columns; skips stale artifacts |
| `rename.py` | the guarded suffix-anchored rewriter, plus `--self-test` |
| `leanmask.py` | depth-counting comment/string lexer; separates code from prose |
| `runlinter.py` | batteries linter parser, with the mandatory `@`-strip repair |
| `refcount.py` | resolved-reference counts (use INSTEAD of grep for "is this dead?") |
| `derive_names.py` | the Phase 5.2 derivation, collision audit, and table generator |
| `Classify.lean` | environment result-type classifier |
| `check-sorry.sh` | the sorry invariant, located by content |

## Traps confirmed live during this run — do not relearn them

- **`nolints.json` silently unmasks after a namespace rename.** Observed directly: masked
  `defsWithUnderscore` jumped 284 -> 1144 before the reprefix, back to 284 after. Postmortem
  constraint 13 is real.
- **The linter's `@` pretty-printing loses 425 of 861 names** if unstripped. Reproduced exactly.
- **`grep` cannot answer "is this declaration dead?"** Three of the plan's four "zero-caller"
  declarations were live. `bi_imp` in particular has zero `.ilean` usages but is registered via
  `@[tm_lemma]` in `modal_search`'s database -- a reference count of 0 is not evidence of
  deadness for an attribute-registered declaration.
- **`grep -rn '\bsorry\b'` returns 813 hits** on this tree, almost all prose. Always use
  `.claude/scripts/lean-sorry-census.sh`.
- **`open private … from <Module>` carries a module path that no import-line pass can see.**
  Three such clauses were the ONLY Phase 2 build failure.
- **A longer namespace re-wraps pretty-printer output.** `check-module-invariants.sh` C2 broke
  purely because `FormalSystem.` pushed one `#print axioms` record onto a continuation line.

## Remaining work

| Phase | Status | Notes |
|---|---|---|
| 6.1 / 6.2 | NOT STARTED | blocked on the review gate; must be run as a paired unit, 6.1 ends RED by construction |
| 7.1 / 7.2 | NOT STARTED | silent-staleness sweep; can run in parallel (disjoint trees) |
| 8 | NOT STARTED | delete `scripts/nolints.json`, decide the 18 `tactic*` declarations, prove `defsWithUnderscore = 0` |

Phase 8 must diff against `baseline/README.md`'s unmasked column **using
`tools/runlinter.py`** -- that tool breaks `LINTER FAILED` out of `simpNF`, so its split is not
comparable to figures produced any other way.
