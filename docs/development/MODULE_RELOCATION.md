# Module Relocation

How to move Lean modules in this repository without breaking what cites them, and what the
tooling can and cannot check for you. Read this before writing a module map.

A relocation here is never just a `git mv`. A module's name appears in `import` lines (live and
archived), in docstrings as a dotted name and as a slash path, in markdown and typst prose, in the
`scripts/` gate harness, and in relative links inside the moved files themselves.
`scripts/move-modules.py` performs all of those rewrites from one mapping file; this document
records the method around it — the ordering constraints, the traps each past move surfaced, and
the one class of error no gate catches.

Past moves are referred to below by what they moved: **the archive relocation** (the archive left
the main library for the repository root, recorded in
[ADR-010](../architecture/ADR-010-Boneyard-At-Repository-Root.md)), **the tooling-library split**
(tooling modules left the main library for their own), **the language-directory merge** (six
per-language syntax and semantics directories became three self-contained components), and **the
Expressiveness extraction** (two subtrees left the weak-canonical directory).

```bash
python3 scripts/move-modules.py --module-map MAP --dry-run     # always first
python3 scripts/test-move-modules.py                           # the tool's own fixture tests
```

## The seven rewrite classes

The executable source of truth is the module docstring of `scripts/move-modules.py`; the numbering
below is the code's and must not drift from it.

| Class | What is rewritten |
|-------|-------------------|
| 1 | `import` lines in `.lean` files under the library and test roots |
| 2 | Dotted citations elsewhere: `.lean` docstrings, markdown, typst, `scripts/` |
| 3 | Slash-path citations, same scope plus `.github/workflows/` |
| 4 | `namespace` / `open` / fully-qualified-name occurrences (needs `--namespace-map`) |
| 5 | The axiom baselines pinned as data in the invariant harness, and `#print axioms` lines |
| 6 | The tree move itself, one `git mv` per mapping, so `git log --follow` crosses it |
| 7 | Relative links inside moved markdown |

**Order matters.** On each line the classes run 1, then 2, then 3, then 4. A namespace that
coincides with a moved module prefix is therefore rewritten by class 2 — everywhere the dotted
name appears, including `namespace` declarations in archived files outside the move — and class 4
then finds nothing left to do. The Expressiveness extraction renamed 83 archived namespace
declarations this way while reporting zero class 4 occurrences. Two consequences:

- `--namespace-map` is needed only where a namespace and the module prefix that declares it
  *differ*. Where they coincide the module map alone renames both.
- `--namespace-paths` scopes class 4 only. It cannot scope what class 2 does.

## The bare-form trap

Every rewrite rule is anchored on the **full** old prefix, never on its bare final component. A
citation that already uses the bare form is typically relative to the old parent directory, and
becomes a correct repository-root path the moment the subtree moves; rewriting it corrupts it. So
a bare-form citation must come through a relocation byte-identical.

A passing total does not distinguish "left alone" from "rewritten twice", so the report carries an
explicit audit line: the count of bare-form occurrences before, and the count after a second run
of the same rewrite with opaque replacements. The two figures must be equal; the tool exits
non-zero when they are not.

The anchoring has a cost, recorded under [the historical-statement blind
spot](#the-historical-statement-blind-spot): a bare-form citation that was *already stale* is left
stale.

## Resolve-map-recompute for relative links

Class 7 re-bases each relative link in a moved markdown file in three steps: **resolve** the
target against the file's old directory to a repository-relative path, **apply the path mapping**
to that path, and **recompute** the relative path from the file's new directory.

Never count `../` segments instead. A heuristic that strips or adds one `../` per level of depth
change is wrong whenever the target stays put while the file's distance to the repository root
changes in the other direction, and wrong again when the target moves with the file. Those links
mostly sit outside `docs/`, the only tree a link gate covers, so nothing would catch the error.

Class 7 runs first, while the file is still at its old location. A link that does not resolve
before the move is left alone: a relocation is not the place to repair a broken link.

## Assert the denominator

A re-rooted counting gate can **pass on a shrunken scan set**. When a gate's scan root or its
pattern stops matching what it used to match, the count of violations falls to zero for the wrong
reason and the board stays green.

So when a gate is re-rooted, assert how many items it scanned, not only that it passed.
[MODULE_INVARIANTS.md](MODULE_INVARIANTS.md)'s C11 row is the worked case: after the archive
relocation, reusing the live-import pattern for the archived-import check would have matched no
archived module name and printed PASS on an empty denominator. The practice that catches this is
to carry the pre-move figure across the move — the number of import lines, files or citations the
gate scanned before — and compare it with the post-move figure in the same report.

## Widen every gate's scan root before the move

Widen each gate's scan root **before** anything moves, so that every widening is a verifiable
no-op: same figures, same verdict, larger root. A narrowing is then loud instead of silent.

Where a widening is *not* a no-op, the widening and the move are one atomic step, and the reason
is worth checking rather than assuming:

- **Widened first**, pre-existing bare citations of the subtree enter the gate's scope while the
  subtree is still at its old location, where they do not resolve. The gate goes red.
- **Moved first**, citations silently leave the gate's scope, and the board is green with fewer
  citations gated than before.

Neither ordering is green on its own, so the two changes land in one commit, with the scanned
count asserted on both sides of it.

## Re-rooting a gate to a top-level directory narrows what a pattern can match

A path-shaped pattern needs a parent component to anchor on, and a module-shaped pattern needs a
dot. A **bare top-level name** has neither, so neither kind of pattern gates it. After the archive
relocation, of the citations gated before the move only those naming something *inside* the
archive stayed gated; every citation of the archive root itself fell out of scope, because at the
repository root that citation is one bare word.

The same narrowing affects measurement. A directory that sits outside the layer map has no layer,
so every import into or out of it is invisible to the upward-edge measurement in
`scripts/measure-refactor-partitions.py`. No harness check catches a regression there. Before
re-rooting anything to a top-level directory, decide which gate will cover the bare name and
which layer the directory belongs to.

## Exe roots sit outside every build closure

`lake build` elaborates what is reachable from the library targets. Nothing imports a `lean_exe`
root, so every exe root sits outside both library closures: a library build, `lake build` and
`lake test` can all be green while exe roots do not compile. During the tooling-library split five
of thirteen exe roots were broken with every one of those green.

Only the build-inclusive invariant harness catches it — [MODULE_INVARIANTS.md](MODULE_INVARIANTS.md)'s
C25 compiles each exe root declared in `lakefile.toml`. The `--no-build` harness run that
`move-modules.py` ends with does **not** include C25. A move that touches anything an exe root
imports is not verified until the full harness has run:

```bash
bash scripts/check-module-invariants.sh
```

## A namespace-audit simulation must precede any directory merge

A directory merge decided on paths alone will misfile modules. The language-directory merge's
first, paths-only map would have moved fourteen files into the bucket the audit calls *unrelated*
— files whose declared namespace has nothing to do with the directory they would have landed in.

Run the audit **before** committing to the module map, against the proposed layout, not only as
post-move verification:

```bash
python3 scripts/measure-refactor-partitions.py namespace-audit
```

Compare each file's first `namespace` with the directory the map sends it to. Every file the merge
would make *unrelated* is either a row to change or a recorded exception, decided before the move
rather than discovered after it.

## The historical-statement blind spot

The tool cannot tell a **citation of a module's current location** from a **historical statement
about its old one**. Both are the same string. Every scripted move so far has falsified history
somewhere: "moved from X to Y" became "moved from Y to Y" in an architecture decision record, in
the refactor programme document, in a gate's own header comment, in merged READMEs, and in the
archive's provenance READMEs, whose table columns are headed *path before consolidation* and *live
origin before archival*. Each instance was found by hand review and none by a gate.

The operative test, sentence by sentence: **does the sentence assert something about the past?**

- A provenance column, an "original location", a "used to be", a dated audit stamp — historical.
  The old name is the truth; revert the rewrite.
- A navigational link, a "the live tree keeps …", an import to copy — present tense. Update it.

**The inverse error is just as real.** The bare-form anchoring leaves untouched any present-tense
citation that was already written in a form the rules do not match, and the default
`--no-rewrite` list deliberately leaves present-tense lines inside archived READMEs alone. The
Expressiveness extraction left ten stale present-tense citations behind, including one in the root
`README.md`. No flag addresses this half.

What the tooling does about it, and what it does not:

- `--no-rewrite` suppresses the false-positive half only, and only in the files it names.
- The identical-sides warning catches a rewrite that collapses the two sides of one sentence or
  one table row, in the files that *are* written. It is a syntactic comparison, not a tense
  detector: a historical statement naming only the old location collapses nothing and is rewritten
  silently.
- Measured on a dry-run replay of the Expressiveness extraction against its own pre-move tree:
  twenty files on the default list carried would-be rewrites — seventeen provenance READMEs, two
  architecture decision records and the typst sync map — and the identical-sides warning fired on
  none of them, with the list enabled or disabled. Every one was single-sided: a provenance column
  or an "original location", naming only the old path. The skip list is what protects those; the
  warning protects the two-sided sentences that earlier moves collapsed.
- **Hand review of the skipped list remains mandatory**, and so does a grep for the old names
  after the move.

## Moving a directory that has an aggregator file

`Foo.lean` beside `Foo/` is the normal Lean aggregator layout; this repository has dozens of such
pairs. A map row whose stem names both is **refused**, naming both paths, before anything is
written. Earlier versions of the tool silently preferred the directory, which rewrote every
citation of the aggregator and then left the file behind.

The remedy is two invocations:

1. Move the directory's contents with child rows (one per child module or sub-directory), composed
   with `--no-verify`.
2. Remove the emptied directory, then move the aggregator file with its own row in a second
   invocation. With the directory gone the stem names only the file.

## Tooling

All flags belong to `scripts/move-modules.py`; `--help` carries the same contract.

| Flag or behavior | Contract |
|------------------|----------|
| `--no-rewrite PATH_OR_GLOB` | Repeatable. Matching files are walked and reported, never written — by any class, including class 7. Supplied values **add to** three built-in defaults, `Boneyard/**/README.md`, `typst/SYNC-MAP.md` and `docs/architecture/ADR-*.md`; nothing clears the defaults, so a file on that list is only ever edited by hand. The report lists every skipped file that would have been rewritten, with its would-be count, and lists separately any skipped file that is itself moved (its relative links are not re-based). Class counts exclude skipped files. |
| Identical-sides warning, `--strict` | A warning, naming file and line, whenever a rewrite makes the two sides of one sentence (two names joined by `to`, `into`, `->`, `→` or `=>`) or any two cells of one markdown table row identical when they differed before. `--strict` promotes any such warning to a non-zero exit. Skipped files are never checked: nothing is written to them. |
| Ambiguous stem | A row whose stem is both a directory and a same-named `.lean` file is refused up front, naming both. See [the aggregator remedy](#moving-a-directory-that-has-an-aggregator-file). |
| Namespace-declaration refusal | A `--namespace-map` row is refused when class 4 would rewrite a `namespace` *declaration* in a file outside the move set; every offending file and line is printed and nothing is written. Not refused: a file that merely cites the old prefix (`open`, a fully-qualified name), and a declaration class 2 has already renamed because namespace and module prefix coincide. |
| `--namespace-paths PATH_OR_GLOB` | Repeatable. Scopes class 4 to matching files, named by their **pre-move** paths. The scope must include the external `open` and fully-qualified-name sites that should follow the rename, not only the moved files. Class 2 is not scoped, and class 5's axiom baselines are never scoped out. |
| Moved-versus-rewritten line | The report states files actually moved next to citations rewritten, on one line. |
| Zero-move exit | When rows were requested and nothing moved, the run exits non-zero — in a dry run too. There is no override: a run that rewrites citations and moves nothing is always worth investigating. |

Globs use one explicit dialect: `**/` matches zero or more directories, a bare `**` matches
anything, `*` and `?` never cross a `/`, and the pattern must match the whole repository-relative
path. The tool and its fixture tests are never rewrite targets themselves.

## Pre-move checklist

1. Write the module map, longest prefixes included. Check every stem for [an aggregator
   pair](#moving-a-directory-that-has-an-aggregator-file) and split those rows now.
2. If the move merges directories, run the [namespace
   audit](#a-namespace-audit-simulation-must-precede-any-directory-merge) against the proposed
   layout.
3. Write a namespace map only for namespaces that differ from their module prefix. For a prefix
   shared between moved and staying files, plan `--namespace-paths`.
4. Record the baseline: `bash scripts/check-module-invariants.sh` (build-inclusive), and the
   scanned counts of every gate whose root the move crosses.
5. [Widen each of those gates' scan roots](#widen-every-gates-scan-root-before-the-move) and
   confirm every widening is a no-op; where it is not, fold it into the move commit.
6. Dry run: `python3 scripts/move-modules.py --module-map MAP --dry-run --strict`.
7. Read the report: files moved against citations rewritten; bare-form figures equal; every
   identical-sides warning; the whole skipped list, file by file, against [the historical-statement
   test](#the-historical-statement-blind-spot).
8. Apply, then run the build-inclusive harness — [exe roots](#exe-roots-sit-outside-every-build-closure)
   are verified by nothing else.
9. Grep for the old dotted and slash names. What remains is either history, which stays, or a stale
   present-tense citation, which is fixed by hand.
10. [Assert the denominator](#assert-the-denominator) of every re-rooted gate against the figure
    recorded in step 4.
