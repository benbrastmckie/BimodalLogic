# Reference Normal Form

[Back to Development Documentation](README.md)

The single shape every `## References` block in the live Lean trees (`FormalSystem/`,
`BimodalTools/`, `Tests/`) is written in, and the recorded gate baselines a sweep of those
blocks must hold constant. It is a convention document, like
[LEAN_STYLE_GUIDE.md](LEAN_STYLE_GUIDE.md); the programme it serves is
[PUBLICATION_REFACTOR.md](PUBLICATION_REFACTOR.md).

**Audience**: anyone editing a module docstring, or adding a citation to one.

## 1. Why a normal form

`## References` in this tree is mostly not a bibliography. Measured across the live trees:
181 bibliographic entries against 532 module cross-references. Three different things are
cited under one heading, and each has its own failure mode:

- a **published work**, which needs a key resolving in the repository-root `references.bib`
  so the citation has a bibliographic target rather than a bare surname and year;
- a **paper anchor** into the JPL paper's LaTeX sources, which check C15 of
  `scripts/check-module-invariants.sh` resolves against
  `docs/reference/paper-definitions-of-record.md`;
- a **sibling module**, which a reader navigates to and which must therefore be a path that
  still resolves after the tree is rearranged.

Writing all three as bare markdown links — a bracketed name followed by a parenthesised
`../../../Some/Path.lean` — produced the two failures this form removes: a bibkey with nothing
behind it, and a relative path whose `../` depth is wrong for the file it sits in.

## 2. The three forms

### Bibliographic

```
* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4
```

Initialled author, italicised title, the `references.bib` key in the second bracket pair, then
the locator. This is Mathlib's citation form. Every key must resolve:

```bash
comm -23 \
  <(grep -rhoE '\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean \
    | tr -d '[]' | sort -u) \
  <(grep -oE '^@[a-z]+\{[^,]+' references.bib | sed 's/.*{//' | sort -u)
```

must print nothing. **Check C31 of `scripts/check-module-invariants.sh` gates this**, so the
pipeline above is an explanation rather than a chore: C31 reads the interior of every
`## References` and `### References` block in the live Lean trees and fails on any key that
`references.bib` does not hold. It also reports — never gates — the entries that no `.lean`
and no `.typ` file cites. See [MODULE_INVARIANTS.md](MODULE_INVARIANTS.md) for both rows.
There is exactly one bibliography, `references.bib` at the repository root; both typst
documents render from it too, which is why they are compiled with `--root ..`.

Do not invent an entry. If a citation's bibliographic details cannot be verified from inside
this repository, re-point it at a key that is already verified and covers the same content, or
leave it alone and say so.

### Paper anchor

```
* JPL paper `def:BLstar-semantics` — the `⊡` clause
```

The anchor is **not** qualified with the paper's `.tex` filename. The citation source of
record is `docs/reference/paper-definitions-of-record.md`, not the paper source — several
module docstrings say so in terms, and the record retains the last resolved text of anchors the
paper has since retired. Naming a `.tex` file would point a reader at something this repository
does not hold and does not track.

Anchors of the form `def:`, `thm:`, `lem:`, `cor:`, `app:` and `rmk:` are read by check C15 and
must already have a row in `docs/reference/paper-definitions-of-record.md` (its MANIFEST or its
KNOWN-ANCHORS table). Add the row before writing the citation, never after.

**`sub:` anchors are copied verbatim and never reshaped.** C15's regex does not match `sub:`,
so a `sub:` citation is ungated; rewriting one into a gated prefix turns a green check red on
an anchor nobody pinned. The six live ones are `sub:`, `sub:Extension`, `sub:Logic`,
`sub:NecessarilyAlways`, `sub:OpenFuture`, `sub:RestrictedModalities` and `sub:Soundness`.

### Module cross-reference

```
* `FormalSystem/Semantics/Truth.lean` — the six L clauses
```

Repository-relative, backticked, em-dash, then what the reader will find there. Backticked
rather than a markdown link, and repository-relative rather than `../`-relative, because a
repository-relative path has no depth to get wrong: it reads the same from every file, and
`scripts/typst-sync-check.sh` Check 1 already resolves paths written this way.

Cite a declaration name, not a line number, wherever the reference is to a *declaration*.
Check C20 tier 1 gates every `file.lean:NNN` citation in the tree onto a real, non-blank line,
and tier 2 reports any that survive on a publication-facing surface. A name survives edits that
a line number does not.

Where a line number is kept, **put the declaration's name immediately before it** — the
backticked name, then the parenthesised anchor. C20's declaration-span assertion then checks
the line against the span of the declaration you named, which is the only way a citation
pointing at the *wrong declaration* is ever caught: tier 1 sees only a citation pointing at
nothing. A citation with no name is counted in the residual C20 prints at every gate, and
nothing but tier 1 can check it.

A markdown link inside a Lean docstring is legal but discouraged — the backticked
repository-relative path above has no depth to get wrong. Where one is written, check C32
resolves it relative to the citing file.

### Worked example

`FormalSystem/PlusLanguage/PlusLimitClosure.lean` carries all three forms in one block and is
the reference implementation.

## 3. What does not belong under `## References`

- Tooling notes: measured benchmark ratios, "the companion markdown transcription is corrupt",
  phase-history lines. A statement that tells a reader how to *use* the module stays, in the
  body; a note to whoever last maintained the file goes.
- Task-management metadata: plan versions, report numbers, phase numbers.
- Absolute paths under anyone's home directory, and repository-relative `literature/…`
  pointers. Both become the bibliographic citation they stand in for.
- `## Paper Specification Reference` and `## Implementation Status` as headings. The paper
  anchors under the former move into `## References`; the verbatim transcription and the
  design-record prose stay in the module body under a descriptive heading. A *status* claim
  goes; a pinned declaration-name list that C14 or C21 reads does not.

A block that records history — what an earlier revision cited, what gap was closed rather than
deleted, what never existed — is a historical record and is preserved verbatim. Mechanical
rewriting that falsifies one of those is the most expensive mistake available here.

## 4. Re-anchoring after a docstring edit

Editing a module's leading `/-! … -/` docstring moves every line below it, so every
`file.lean:NNN` citation pointing into that file goes stale at once.
`scripts/reanchor-lean-citations.py` computes the per-file shift and rewrites the citations:

```bash
python3 scripts/reanchor-lean-citations.py --files <the files you edited>
```

Run it **once, at the end of a batch**, after every line-count-changing edit in that batch —
never interleaved with the edits — and **always name the batch's files explicitly**. The tool
has three passes, and only the first is unsafe to repeat:

- **The Δ pass (the default) is not idempotent.** It computes the shift from the base revision
  to the working tree, so a second run applies the same shift again and every citation ends up
  doubly shifted. C20 tier 1 does not catch that, because a doubly shifted citation usually
  still lands on some non-blank line; C20's declaration-span assertion catches it only for a
  citation that names its declaration, and only when the shift is larger than that
  declaration's span. The default file selection (everything changed since the base) makes a
  second run especially dangerous, since the citers the first run rewrote have themselves
  changed and join the target list.
- **`--recompute` is idempotent**, and is the recovery from a doubled Δ pass. It rebuilds every
  citation from the base revision by content alignment. Its one blind spot: a citer line whose
  *content* was also edited in the same batch is left as it is, because there is no
  base-revision number on that line to trust. Re-anchor such a line by hand.
- **`--by-name` is idempotent**, and repairs what no revision-relative pass can: a citation that
  was already stale at the base revision. It re-points every citation that names a declaration
  but lands outside it — exactly what C20's declaration-span assertion reports — at that
  declaration's own line, and reports as `SKIPPED` any whose names do not single out one
  declaration per anchor. Read its diff: a sentence that puts a declared name directly before a
  citation of something *else* is fixed by rewording the sentence, not by this pass.

```bash
python3 scripts/reanchor-lean-citations.py --recompute
python3 scripts/reanchor-lean-citations.py --by-name --files <the target files>
```

It is a maintenance tool, not a gate; the gate is C20. It refuses rather than guesses, and
`--exact` handles a file whose body docstrings also moved. `--selftest` asserts all of the
above rather than narrating it, in five probes: a Δ=0 run over the whole tree changes zero
bytes; a synthetic edit moves exactly the citations it should; the Δ pass run twice is repaired
by `--recompute` and a **second `--recompute` rewrites nothing**; the content-edited-line blind
spot behaves as stated; and the same doubled pass is detected and repaired by `--by-name`, whose
second run likewise rewrites nothing.

## 5. Recorded baselines

Measured on a clean tree before the normalisation sweep began, with
`bash scripts/check-module-invariants.sh --no-build`, `bash scripts/readme-lint.sh` and
`bash scripts/typst-sync-check.sh`. A sweep of docstrings asserts these are unchanged, not
merely that nothing failed.

| Gate | Baseline | Direction |
|------|----------|-----------|
| C20 tier 1 | 1028 resolvable citations, 0 unverifiable | must stay 1028, all on non-blank lines |
| C20 tier 2 | 0 in publication-facing scope | must stay 0 |
| C15 paper anchors | 59 resolving | may rise, must never fall |
| C15 theorem-index rows | 76 carrying their anchor | must not fall |
| C19 refined docstring coverage | 94.01% (10261/10915), floor 90% | must stay above the floor |
| C14 | both halves PASS | every stated count and pinned name preserved |
| INV | clean after `--emit-inventory --check` | zero byte changes |
| `readme-lint.sh` broken references | 21 | unchanged — these are a separate, known-red item |
| `typst-sync-check.sh` Check 1 | 9 violations | unchanged — likewise |
| `typst-sync-check.sh` Checks 2, 2b, 3 | 0 mismatches | must stay 0 |
| C31 bibkeys | 215 block citations over 22 distinct keys, 0 dangling | must stay 0 dangling |
| C31 advisory | 11 of 77 `references.bib` entries cited by no `.lean` and no `.typ` file | advisory; may fall |
| C32 docstring links | 8 path-shaped relative links, 0 broken | must stay 0 broken |
| C20 declaration span | 0 named citations outside their declaration beyond the recorded baseline | must stay 0 |
| C20 recorded baseline | 10 keys in `scripts/c20-declaration-baseline.txt` | may only fall |
| C20 name-less residual | 155 of 1028 citations carry no declaration name; 40 more are unverifiable | should fall; a rise means citations lost their names |

The C31, C32 and C20 declaration-span rows were measured when those checks were added, after
the normalisation sweep and after 315 wrong-declaration citations were re-pointed by name.

`unverifiable` is not a pass. C20 matches an unqualified citation on basename and reports an
ambiguous or unresolvable one as `unverifiable` rather than failed; a rise in that count is a
regression hiding behind a PASS line. Assert the *resolvable* count.
