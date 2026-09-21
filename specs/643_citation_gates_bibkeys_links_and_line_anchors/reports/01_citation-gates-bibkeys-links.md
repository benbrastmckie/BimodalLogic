# Research Report: Task #643

- **Task**: 643 - Citation gates: bibkeys, links and line anchors
- **Started**: 2026-09-21
- **Completed**: 2026-09-21
- **Effort**: one research dispatch
- **Dependencies**: None (task 636 landed already; this task closes the gates that let its
  defects survive undetected)
- **Sources/Inputs**: `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`,
  `scripts/reanchor-lean-citations.py`, `docs/development/REFERENCE_NORMAL_FORM.md`,
  `docs/development/MODULE_INVARIANTS.md`, `references.bib`, `specs/archive/636_.../summaries`,
  a disposable clone under the scratchpad directory used to empirically test `--recompute`
- **Artifacts**: this report
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All three gaps are real and confirmed by direct inspection**, but the tree they will gate is
  already clean on every measured dimension: 0 dangling bibkeys, 0 broken docstring markdown
  links, C20 tier 1 at its recorded 1028/0-unverifiable baseline, C15 both halves PASS. The two
  brand-new checks (bibkeys, docstring links) will go green on their first run — build them,
  then prove they catch the injected negative case, exactly like this repo's C15/C24/C25/C26
  precedent.
- **`--recompute` already exists and is already idempotent** — task 636 built it in response to
  its own double-run mistake. I reproduced the exact double-shift bug against a disposable clone
  (doubled 3-line shift on `KPlusFaithful.lean`, 72 citations, 19 citer files) and confirmed
  `--recompute` repairs it exactly and a second `--recompute` changes 0 lines. Deliverable (4) is
  therefore mostly "prove it and pin it down with a fixture," not "build it from scratch" — see
  Finding 3's one real gap: recompute only repairs a citer *line* that is byte-identical to the
  base revision outside its citation digits, so a line edited for content in the same batch as
  the double-shift is silently left un-repaired.
- **The declaration-name cross-check (deliverable 5) needs a design decision this report
  surfaces with a live example**, not a hypothetical one: `PriorExpressivenessDense.lean:91`
  cites `` `prior_hasFaithfulDedekindSUP_dense` (…, `Kamp/KPlusFaithful.lean:479`, `:524`) `` —
  line 479 is the *closing `-/` of a different theorem's docstring* (`..._INF_dense`, declared at
  480) and line 524 is *inside* `..._SUP_dense`'s own docstring, five lines above its `theorem`
  keyword at 530. Both are non-blank, so C20 tier 1 passes both, and neither is a mistake once
  "at the declaration" is read as "within its docstring-through-body span" rather than "on the
  exact `theorem` line" — but the check has to *choose* that span definition, and choosing it
  wrong turns every loosely-anchored citation in the tree red.
- Of the three files the dispatch names as the worst-shifted, **`KPlusFaithful.lean` (72
  citations, 38 already carry an adjacent declaration name), `Formula.lean` (27 citations, 15
  named) and `DerivedAxioms.lean` (2 citations, 0 named)** — roughly half of even the worst
  file's citations are already in the target form; the residual (unnamed, bare `file.lean:NNN`)
  count is what deliverable (5) asks to record honestly rather than force to zero.
- The bibkey check and the docstring-link check are two different regressions with two
  different false-positive traps: a bibkey regex is safe against the tree's content, but the
  advisory "cited by nothing" half needs **two citation syntaxes** (Lean's `[key]`, Typst's
  `@key`) or it will silently under-count. A docstring markdown-link regex is **not** safe
  without a path-shaped filter — inline math like `` `[z_0, z_1](x, y)` `` in the
  `Kamp/NfMultiAnchorBridge/` subtree produces dozens of false "links" per file under a naive
  `\[.*?\]\(...\)` match.

## Context & Scope

Task 636 (archived, `specs/archive/636_docstring_and_citation_normalisation/`) normalised every
`## References`/`### References` block in `FormalSystem/`, `BimodalTools/` and `Tests/` to a
three-way form (bibliographic `[key]`, paper anchor, module cross-reference) and merged the
bibliography into the repository-root `references.bib` (77 entries). It found and fixed two
dangling bibkeys, 37 broken docstring markdown links (16 stale `Logos/Core/` paths), and wrote
`scripts/reanchor-lean-citations.py` after tripping its own re-anchor bug twice. None of those
three defect classes has a standing gate: C15 only reads `def|thm|lem|cor|app|rmk:` paper
anchors, `readme-lint.sh` only scans files literally named `README.md`, and C20 tier 1 only
asserts a citation's target line exists and is non-blank — never that it names the right
declaration. This task's job is to build those three gates (plus harden the re-anchor tool and
begin the C20 declaration-name upgrade) so the normal form task 636 installed cannot decay
unnoticed the way it already did once.

Scope, per the dispatch: `FormalSystem/`, `BimodalTools/`, `Tests/`, excluding `Boneyard/`;
`sub:` anchors are out of scope for the two new checks (they are not bibkeys or markdown links,
so this is a non-issue in practice, but the exclusion should be stated explicitly wherever the
new checks' scope is documented, for the same reason C15's docstring already calls it out).

## Findings

### Finding 1 — GAP A (bibkeys) is real, unaddressed, and currently green

`grep -n "references.bib\|## References\|### References" scripts/check-module-invariants.sh`
returns nothing: no check anywhere resolves a `[key]` citation against `references.bib`. The
mechanism is fully specified today, though, as a one-off shell pipeline in
`docs/development/REFERENCE_NORMAL_FORM.md` §2 ("Bibliographic"):

```bash
comm -23 \
  <(grep -rhoE '\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean \
    | tr -d '[]' | sort -u) \
  <(grep -oE '^@[a-z]+\{[^,]+' references.bib | sed 's/.*{//' | sort -u)
```

Running that exact pipeline today: **empty output** (0 dangling). The two keys the dispatch
names, `stavi1979` and `gabbay1980`, were already re-pointed to `gabbay1994` by task 636 (see
its summary's Decisions section) — they are not currently dangling, they are the *historical
evidence* for why this check needs to exist, not a residual defect to fix here.

Measured directly: 22 distinct bibkeys are cited inside `## References`/`### References` blocks
under `FormalSystem/`, `Tests/`, `BimodalTools/` (all 22 resolve). `references.bib` carries 77
entries; the deliverable's advisory half ("bib entries cited by no `.lean` and no `.typ` file")
currently reports 55 apparently-unused entries when scanned against Lean's `[key]` syntax and
Typst's citation syntax together — **but Typst does not use `[key]`, it uses `@key`**
(`typst/FormalFoundations.typ:141`: `@brastmckie2026construction`). A scanner that only greps
`\[key\]` across `--include=*.typ` too (as the existing shell one-liner would if naively
extended) will double-count every Typst-only-cited entry as unused. The advisory half needs two
regexes, one per citation syntax, unioned before the `comm`.

**Design note on scope**: the deliverable text says "every `[key]` in a `## References` or
`### References` block," which is narrower than "every `[key]` in the file." Task 636's summary
records 231 total bibkey occurrences in the tree, 150 in "display form" (inside a References
block) and 81 in inline prose the normal form deliberately does not govern (e.g. `` Cite
[rabinovich2014] by **PDF page only** ``). A scanner that greps the whole file rather than only
block-scoped citations would need to either accept those 81 as in-scope too (a scope
*widening* beyond what the dispatch asks) or filter to block-scoped occurrences only, which
requires locating each `## References`/`### References` heading and its extent (next
heading-of-equal-or-higher-level, or end of the doc comment). Recommend scoping strictly to
block interiors, matching the dispatch's literal wording and REFERENCE_NORMAL_FORM.md's own
"what belongs under `## References`" framing.

### Finding 2 — GAP B (docstring markdown links) is real, its historical instances are already
fixed, and a naive implementation will false-positive heavily

`readme-lint.sh` Check 3 only opens files matched by `scope_md()`, which for a Lean root
(`is_lean_root` true — `FormalSystem/`, `BimodalTools/` both qualify) is `find "$r" -name
README.md` — it never opens a `.lean` file, so a broken link inside a docstring is invisible to
it by construction.

I scanned every `.lean` file under `FormalSystem/` and `BimodalTools/` (Boneyard excluded) for
markdown-link-shaped text with a naive `\[([^\]]*)\]\(([^)]+)\)` regex: **80 matches, 72
"broken."** Nearly all 72 are false positives from inline math notation in the
`Kamp/NfMultiAnchorBridge/` proof-engineering subtree — e.g. `` `EANegationClosure.lean` `` has
`` [z_0, z_1](x, y) `` (a function application written in bracket-then-paren math notation, not
a markdown link). Filtering to path-shaped targets only (matches `^[\w./\-]+$`, and contains
either `/` or `.`) collapses this to **8 real markdown-link-shaped citations in the whole
`FormalSystem/` + `BimodalTools/` + `Tests/` tree, all of which currently resolve** (all 8 live
in `FormalSystem/Automation/Tactics/Search.lean`, `.../UserTactics.lean` and
`FormalSystem/Tactic/Meta.lean`, cross-referencing each other and resolving via `../`-relative
paths). Zero occurrences of `Logos/Core` remain anywhere under `FormalSystem/`, `BimodalTools/`
or `Tests/` — the 16 stale paths the dispatch cites were part of the 37 task 636 already found
and fixed by hand, and the check being proposed here is the guard against a *future* recurrence,
not a repair of a present one.

**Implementation consequence**: the path-shaped filter is not optional polish, it is load-bearing
— without it, the very first run of this check on the current tree would fail loudly with ~72
false positives and nobody would trust it afterward. Recommend requiring the link target to
match a conservative path-token grammar (word characters, `.`, `/`, `-`, no whitespace or
commas) and to contain at least one `/` or a recognized extension before treating it as a link
to resolve, mirroring how `readme-lint.sh` itself only ever sees genuine `[text](path)` syntax
because it operates on markdown files where that ambiguity does not arise.

### Finding 3 — GAP C's `--recompute` mode already exists, is already idempotent, and I proved it

`scripts/reanchor-lean-citations.py` already has a `--recompute` mode (added in task 636's own
Phase 4/8 repair, per its git log: `b4d3d08ab task 636 phase 2: re-anchor tool and reference
normal form`, extended in later phases). Its docstring and `REFERENCE_NORMAL_FORM.md` §4 both
already document it as "the idempotent counterpart to the Δ pass" and "the way to repair a tree
the Δ pass was run over twice."

I did not take that on faith. Using a disposable `git clone` under the scratchpad directory (no
risk to the shared working tree other sibling tasks are using this cycle), I reproduced the
exact defect described in the dispatch:

1. Added 3 lines inside `KPlusFaithful.lean`'s leading docstring (the file with 72 citations
   into it, across 19 citer files).
2. Ran `reanchor-lean-citations.py --files KPlusFaithful.lean` **twice** — the documented mistake
   — and confirmed citations that should have shifted `+3` had shifted `+6` (e.g. `:479 -> :485`,
   `:325 -> :331`).
3. Ran `--recompute` **once**: `recomputed 72 citation line(s) across 19 citer file(s)`, and
   confirmed every citation landed back at the correct `+3` offset (`:479 -> :482`,
   `:325 -> :328`).
4. Ran `--recompute` **again**: `recomputed 0 citation line(s) across 0 citer file(s)` — the
   second run's diff is empty, exactly the acceptance criterion the dispatch states.

**This means deliverable (4) is substantially already delivered by task 636.** What remains is
narrower than "build an idempotent recompute mode": (a) turn the manual test above into a
checked-in fixture/selftest so this property is asserted mechanically rather than trusted, on
the same model as the tool's own existing `--selftest` (which currently only exercises the `Δ`
model, not `--recompute`), and (b) close one real gap the mechanism has.

**The gap**: `recompute()` repairs a citer line only when it is byte-identical to the base
revision except for the citation's digits (`strip_nums(ol) != strip_nums(nl): continue`). If a
citer line was *also* content-edited in the same batch that triggered the double-shift (a
docstring reworded and its citation line happened to be re-anchored in the same sweep), recompute
silently leaves it un-repaired rather than guessing — which is the tool's stated philosophy
("refuses rather than guesses") but means the fixture in deliverable (6) should include this
case explicitly (a citer line edited for content, not just digits, in the same batch as a
double-shift) so it is a known, tested, documented limitation rather than a silent blind spot.

On the "by content alignment (the cited declaration's name, or the cited line's text at a
recorded commit)" phrasing in the dispatch: the existing `--recompute` implements only the
second alternative (line text at `--base`, default `HEAD`). It does not fall back to
declaration-name alignment when the line-text alignment fails. Given the empirical result above,
I do not think a declaration-name-based fallback is necessary to satisfy the acceptance
criterion as written (the double-shift fixture case is fully repaired by the existing
mechanism) — but the plan phase should treat this as an open question rather than a settled one,
since the dispatch names both alternatives and only one is implemented.

### Finding 4 — GAP C's C20 strengthening (deliverable 5) needs a declaration-span design
decision, illustrated by a live, non-hypothetical example

Deliverable (5) asks: "a citation carrying a declaration name is checked against the declaration
actually at that line." I looked for a concrete instance to ground the design rather than
inventing one, and found one immediately in the first worst-shift file:

`FormalSystem/Metalogic/Expressiveness/PriorExpressivenessDense.lean:91` reads:

```
the obligation plus `prior_hasFaithfulDedekindINF_dense` /
`prior_hasFaithfulDedekindSUP_dense` (Phase 10.1, `Kamp/KPlusFaithful.lean:479`, `:524`) gives
```

In `KPlusFaithful.lean`: `prior_hasFaithfulDedekindINF_dense` is declared at line 480 (line 479
is the closing `-/` of *its own* leading docstring — one line before the `theorem` keyword).
`prior_hasFaithfulDedekindSUP_dense` is declared at line 530; line 524 sits inside *its own*
`/-- ... -/` docstring, six lines above the `theorem` keyword. Both citations are "close" to
their named declarations but neither lands on the `theorem` line itself, and C20 tier 1 already
passes both (both lines are non-blank).

This is exactly the shape of citation the tree is full of, and it settles the design question
the naive reading of deliverable (5) leaves open: **"the declaration actually at that line"
cannot mean "the line is the exact `theorem`/`def`/... keyword line,"** or the very first
citation checked would fail on a citation that is, on inspection, correct. The check needs a
**declaration span**: from the start of the declaration's own leading `/--`/`/-!` doc comment
(or, absent one, the declaration's own attribute/keyword line) through to the end of its body
(next top-level declaration, or matching brace/indent boundary). A citation resolves if its
`file:NNN` line falls anywhere inside the named declaration's span; C15's second assertion
(`check-module-invariants.sh:2040-2134`) already implements the "find declaration by base name,
walk backward past `@[...]` attributes to the doc comment" half of this for a different purpose
(pairing `docs/theorem-index.md` rows with their `Paper:` line) and is a directly reusable
pattern — the forward half (finding the span's end) is the new piece.

**Sizing, per the dispatch's own instruction to size honestly**: repo-wide there are 1028
resolvable `file.lean:NNN` citations (C20's own count, confirmed green on the current tree).
Of the three named worst-shift files:

| File | Citations into it (repo-wide) | Already carry an adjacent declaration name |
|------|-------------------------------|---------------------------------------------|
| `FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean` | 72 | 38 |
| `FormalSystem/Syntax/Formula.lean` | 27 | 15 |
| `FormalSystem/Theorems/DerivedAxioms.lean` | 2 | 0 |

("Already carry an adjacent declaration name" = a backtick-quoted identifier immediately
preceding the `(File.lean:NNN` parenthetical, measured by direct grep — a conservative
undercount, since a name stated a few words earlier in the same sentence, as in the
`PriorExpressivenessDense.lean:91` example above, is not counted by this narrow pattern but
should still be recognized by the actual checker.) Converting the remainder of even these three
files' citations to name-carrying form, and doing the same across the full 1028, is plainly not
one task's scope. Recommend the plan deliver: the span-resolution mechanism itself (as a new,
reporting-then-gated C20 sub-assertion, on the C16_ROOTS/C9_DOCS soft-then-enforce precedent
this repo already uses for exactly this situation); the actual conversion limited to the three
named files, with residual per-file bare-citation counts recorded in the plan/summary rather
than driven to zero; and the harness printing the tree-wide residual count (name-less
`file.lean:NNN` citations) as an `INFO`/`TODO` line at every gate, the same way `ENFORCE_C16_ROOTS`
and `ENFORCE_C9_DOCS` are surfaced today without holding the gate hostage to a thousand-site
burn-down.

### Finding 5 — where the new checks belong, and what numbering is free

Deliverable (7) points at `docs/development/MODULE_INVARIANTS.md` for rows and
`docs/development/REFERENCE_NORMAL_FORM.md` for a pointer, which settles where the two new
checks are wired: into `scripts/check-module-invariants.sh` (the harness `MODULE_INVARIANTS.md`
documents), not `readme-lint.sh`. `check-module-invariants.sh`'s own header comment enumerates
checks through `C30`, plus `C9D`, `INV`, `B0`-`B3` and the ungated `LAKE` scrape — **`C31` and
`C32` are the next free IDs.** Both new checks are clean on the current tree (0 findings each),
so — per this repo's own stated convention ("C12, C13, C14 and C15 ship enforced, with no flags,
because the work that cleared their debt landed in the same change that added them") — they
should ship **enforced from the outset**, with no `ENFORCE_C31`/`ENFORCE_C32` soft period, and
each should get the same deliberate-negative-test treatment C15/C24/C25/C26 document in
"Adding a Check": inject the defect, observe `FAIL` and a non-zero exit, revert, observe `PASS`
and exit 0 again. This is exactly what the dispatch's ACCEPTANCE section already asks for
("each seen to fail on an injected dangling key, an injected broken link and the double-shift
fixture") — it is this repo's standing protocol for a new check, not a special requirement of
this task.

**Reusable building blocks already in the tree**:
- `scripts/lib/live_walk.py` (`live_files`, `live_loose_files`, `live_subdirs`) — the shared
  Boneyard-exclusion walker every other check and the `--emit-inventory` generator already use;
  both new checks should walk through it rather than re-implementing the exclusion.
- `check-module-invariants.sh`'s C15 second-assertion python block (lines ~2040-2134) —
  the "find a named declaration, locate its doc comment" logic deliverable (5)'s span
  resolution needs half of.
- `reanchor-lean-citations.py`'s `CITE` regex and `make_resolver`/basename-ambiguity handling —
  C20's own resolver, which any declaration-span check must reuse rather than re-derive, or the
  two will silently diverge on an ambiguous basename (the tool's own header already warns about
  this for the `Δ` pass; the same discipline applies to the new span check).

### Finding 6 — fixture mechanism is an open question, not a settled one

Deliverable (6) asks for "fixtures, positive and negative, for each check, including the
double-shift case." This repository's existing precedent for a new check's negative test
(C15/C24/C25/C26/C29/C30, documented in `MODULE_INVARIANTS.md`'s "Adding a Check" section) is a
**manual, one-off, documented-in-prose** test: inject a defect by hand, observe the failure,
revert, observe the pass — never checked in as a re-runnable fixture. `reanchor-lean-citations.py`
takes a different approach for its own correctness: a built-in `--selftest` mode that snapshots
files, injects a synthetic change, asserts a property, and restores the originals — re-runnable,
scriptable, and exactly the shape the double-shift-then-`--recompute` scenario in Finding 3 needs
(the tool's `--selftest` currently covers only the `Δ` pass, not `--recompute`). Recommend the
plan phase choose the `--selftest`-style re-runnable mechanism over the manual-and-documented
one for all three fixtures this task adds, since the dispatch's ACCEPTANCE criteria ("each seen
to fail... `--recompute` run twice in succession gives an empty second diff") read as properties
that should be asserted by a command, not merely narrated in a plan file the way C15's negative
test is today. This is a genuine judgment call for the plan/implementation phase, not something
this research report should decide unilaterally.

## Decisions

- Scope the bibkey check to citations inside `## References`/`### References` block interiors
  only (matching the dispatch's literal wording), not every `[key]`-shaped occurrence in a
  `.lean` file — the tree carries 81 inline-prose bibkey mentions outside those blocks that the
  normal form deliberately does not govern.
- Treat `--recompute`'s existing content-alignment-at-`--base` mechanism as sufficient for the
  stated acceptance criterion (empirically verified in Finding 3); do not treat
  "declaration-name alignment" as a required second mechanism unless a concrete failure case for
  the existing one turns up during implementation.
- Wire both new checks into `scripts/check-module-invariants.sh` as `C31` (bibkeys) and `C32`
  (docstring links), not into `readme-lint.sh` — consistent with deliverable (7)'s pointer to
  `MODULE_INVARIANTS.md`, and with `readme-lint.sh`'s own documented scope boundary (README.md
  files only).

## Risks & Mitigations

- **False positives from inline math notation** (Finding 2) — the single largest risk to a
  trustworthy first run of the docstring-link check. Mitigation: require a path-shaped filter on
  the link target before treating it as a link to resolve; verified in this report that the
  filtered count (8, all resolving) is the true current state.
- **Typst's `@key` vs Lean's `[key]` citation syntax** (Finding 1) — a bibkey-usage scanner that
  only understands one syntax will misreport the advisory "unused entries" list. Mitigation:
  scan both syntaxes for the advisory half; the gated half (citations *inside* the Lean tree)
  only ever needs `[key]`.
- **Declaration-span ambiguity** (Finding 4) — a too-strict span definition (exact `theorem`
  line only) would fail correct, already-in-the-tree citations on the check's first run, which
  is the opposite of "ships green." Mitigation: use a span from the declaration's own leading
  doc comment through its body, reusing C15's existing declaration-location logic as a base.
- **1028 citations is too large a conversion for one task** (Finding 4) — the dispatch itself
  anticipates this ("size the conversion honestly"). Mitigation: mechanism ships as a
  reporting-then-gated sub-check on the `ENFORCE_C16_ROOTS`/`ENFORCE_C9_DOCS` precedent; only the
  three named files are converted; the residual count is recorded rather than hidden.
- **Fixture mechanism choice affects phase sizing** (Finding 6) — building a re-runnable
  `--selftest`-style fixture harness is more work than a one-off manual test but is what the
  acceptance criteria's phrasing implies. Flagged for the plan phase rather than pre-decided
  here, since it changes how many phases the conversion needs.
- **Concurrency**: this task's file scope (`scripts/check-module-invariants.sh`,
  `scripts/reanchor-lean-citations.py`, `docs/development/MODULE_INVARIANTS.md`,
  `docs/development/REFERENCE_NORMAL_FORM.md`, and the three named `.lean` files) does not
  overlap any of this cycle's declared sibling territories (tasks 614, 644, 637). No conflict
  expected, but re-read each file immediately before editing per the standing territory
  discipline.

## Context Extension Recommendations

- **Topic**: `--recompute`'s idempotency is asserted only by trust today (this report's manual
  clone-and-test is the first time it was actually exercised against the documented double-shift
  scenario).
- **Gap**: `reanchor-lean-citations.py --selftest` covers only the `Δ`-pass no-op and a synthetic
  `+3` shift; it has no selftest for `--recompute`, and no selftest exercises the double-run
  bug the tool exists to repair.
- **Recommendation**: add a third selftest ("selftest 3: double-run then `--recompute`") that
  performs exactly the sequence this report performed by hand (edit → run `--files` twice →
  assert the doubled shift → run `--recompute` → assert correctness and 0 further changes on a
  second `--recompute`), and reference it from `REFERENCE_NORMAL_FORM.md` §4 alongside the
  existing `--selftest` mention.

## Appendix

Commands used to establish the findings above (all read-only against the real working tree; the
`--recompute` reproduction ran against a disposable `git clone` under the session scratchpad
directory, since deleted):

```bash
grep -n "references.bib\|## References\|### References" scripts/check-module-invariants.sh
comm -23 <(grep -rhoE '\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean \
  | tr -d '[]' | sort -u) <(grep -oE '^@[a-z]+\{[^,]+' references.bib | sed 's/.*{//' | sort -u)
grep -rhoE '\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean | grep -v Boneyard | sort -u | wc -l
grep -rn "Logos/Core" FormalSystem BimodalTools Tests --include='*.lean' | grep -v Boneyard | wc -l
grep -rhoE "\bKPlusFaithful.lean:[0-9]+\b" FormalSystem BimodalTools docs typst Tests scripts README.md | wc -l
bash scripts/check-module-invariants.sh --no-build   # confirmed 0 FAIL lines, C15/C20 both PASS
git clone --no-hardlinks . /tmp/.../recompute-test    # disposable clone under scratchpad
python3 scripts/reanchor-lean-citations.py --files KPlusFaithful.lean   # run twice
python3 scripts/reanchor-lean-citations.py --recompute                  # once, then again
```

Key files read in full or in the relevant section: `scripts/check-module-invariants.sh` (C15,
C20 sections), `scripts/readme-lint.sh`, `scripts/reanchor-lean-citations.py` (entire file),
`docs/development/REFERENCE_NORMAL_FORM.md` (entire file), `docs/development/MODULE_INVARIANTS.md`
(entire file), `specs/archive/636_docstring_and_citation_normalisation/summaries/01_....md`.
