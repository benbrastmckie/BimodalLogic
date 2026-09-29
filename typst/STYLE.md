# Bimodal Reference Manual — House Style

This is the single house style the whole manual (`BimodalReference.typ` and everything under
`typst/chapters/`) follows. It governs formatting, structure, and citation convention only — it
is not a content standard and does not license adding new theorems, proofs, or chapters. Every
rule below cites the standard it restates or the finding it closes; nothing here is invented.

**The two appendices (`ax-lean-appendix.typ`, `ax-machine-appendix.typ`) are governed by their
own conventions**, owned by the Lean appendix's own code-environment and define-before-use
maintenance work. This manual's uniformity work touches only their Rule 1.2 citation paths (see
Rule 4 below); their local `#show` rules, `sticky:` overrides, numbering scheme, and declaration
order are intentionally left alone. A reader encountering an appendix convention that differs
from a chapter convention below should read that as a deliberate exception, not drift.

## 1. Chapter opening

Every chapter file (outside the two appendices) opens with exactly this shape:

```
= Chapter Title <sec:chapter-id>

#chapter-header(
  description: [One sentence saying what the chapter covers.],
  dependencies: [What the reader must already have read, as @sec:/@ch: references.],
)
```

`connections:` is optional and used only where a Logos-architecture link is genuinely present.
The first `==` section then opens with at least two sentences of motivating prose before any
semantic element.

Grounds: `textbook-standards.md` Chapter Structure ("Prerequisites stated explicitly", "Chapter
outline") and its Motivation Requirements; closes the 7-file `#chapter-header` gap (all 8
`p2`/`p3`/`p4` chapters used it, none of the 7 numbered `00`–`06` chapters did).

## 2. Section and subsection rhythm

Every `==` and `===` heading is followed by prose stating the reader need — why the section
exists and what it lets the reader do — before any `#definition`, `#theorem`, `#lemma`,
`#example`, or `#remark`.

Grounds: `semantic-element-usage.md`'s Universal Placement Rule, already BLOCKING-enforced by
both `typst-element-lint.sh` and `chapter-quality-check.sh`.

## 3. Element order within a section

Motivation prose, then `#definition`, then an optional grounding `#example`, then prose saying
why the next result matters, then `#theorem`/`#lemma`, then `#proof` closed with `#qed`
immediately after, then a sparing `#remark` only after a landed result. A `#remark` never opens a
section. Consecutive theorem blocks carry at least one connective sentence between them saying
how each relates to the last.

Grounds: `semantic-element-usage.md`'s per-element placement entries.

## 4. Lean citations

Three forms, each with one job. This is the convention that closes the large majority of the
manual's `chapter-quality-check.sh` Rule 1.2 findings.

| What is being cited | Form | Notes |
|---|---|---|
| A declaration, as a standalone attribution after a definition or theorem | `#leansrc("FormalSystem.Module.Path", "declName")` | Block-level; place on its own line after a colon-terminated sentence. Never mid-sentence. |
| A declaration mentioned inline in prose | `` `declName` `` or `#leanref("declName")` | Identifier only, no path, no `.lean`. |
| A file or directory cited as a file, not as a declaration | `` `FormalSystem/Syntax/Formula.lean` `` | Full repo-root-relative path, resolved per occurrence against the live tree. |

Never cite a bare module-relative path in backticks or a footnote (the
`` `Syntax/Formula.lean` ``-shaped pattern, missing the `FormalSystem/` prefix). When a `#leansrc`
block already attributes a declaration, the preceding prose does not repeat the file path — it
names the module in words.

Grounds: `chapter-quality-check.sh` Rule 1.2 resolves a backticked path against the repo root and
the chapter's own directory only, so a module-relative path can never resolve; `#leansrc`/
`#leanref` are not backtick path tokens and never trip Rule 1.2. `#leansrc` and `#leanref` are
the manual's actual Lean-citation commands (see `notation-conventions.md`, which documents them
and marks the older `srcref`/`coderef` names as superseded).

## 5. Cross-references

Always the native label and reference system: `@sec:`, `@ch:`, `@thm:`. Never un-linked prose
like "the semantics chapter" or "see Chapter 3".

Grounds: `document-structure.md`'s Cross-Chapter References mandate.

## 6. Lists

Native Typst list syntax (`- item`, `+ item`) everywhere. The `#items[]`/`#item[]` wrapper
defined in `template.typ` is **deprecated**: it stays defined behind a deprecation comment (other
documents outside this manual may still reference it) but no chapter in this manual calls it.

**Decision**: native syntax wins over `#items[]`. It is both the documented standard
(`typst-style-guide.md`'s Standard List Requirement) and, at the time this style sheet was
written, already the practice in the large majority of chapter files — the smaller edit and the
defensible one. `#items[]` is deprecated in place, not deleted, because other documents in this
repository may still call it.

## 7. Tables and figures

```
#figure(table(columns: ..., stroke: none, table.hline(), table.header(...), ...), caption: none)
```

unchanged from current practice.

Grounds: `typst-style-guide.md`'s Standard Table Format; an audit of the manual at the time this
style sheet was written found zero divergence from this form, so this rule is recorded to hold
the line, not to drive edits.

## 8. No configuration or helpers in chapters

A chapter (outside the two appendices) imports `../template.typ` and nothing else, and defines
no local `#let`, `#set`, or `#show`. Shared formatting helpers live in `template.typ`.

Grounds: `document-structure.md`'s Chapter Guidelines. The two appendices' scoped overrides are
an out-of-scope exception (see the top of this document). A chapter-local helper is kept in place
only when promoting it to `template.typ` would be unsafe (for example, because it turns out to be
chapter-specific data rather than a genuine formatting helper, or because promoting it changes
rendered output) — any such exception is recorded in this file's Exceptions section below, not
left silently unmentioned.

## 9. Numbers and status claims

Every count, version, or status claim is imported from `typst/generated/status.typ` (for example
`#axiom-count`, `#rule-count`) or traced to `SYNC-MAP.md`. No hand-typed number.

Grounds: `chapter-quality.md` Rule 1.4.

## Decision log

Two axes were open or flagged when this style sheet was first written, resolved here rather than
deferred:

1. **Lists: native syntax wins** (Rule 6 above). Rationale: already the documented standard and
   the majority practice, so the smaller and more defensible edit.
2. **`#chapter-header` extends to the numbered chapters** (Rule 1 above). Rationale: the split
   between chapters that used it and chapters that did not was chronological drift, not a
   content-type distinction, and the fields it renders are exactly what `textbook-standards.md`
   already requires of every chapter.

## Exceptions

None recorded yet. Any chapter-local helper kept in place under Rule 8's exception clause, or any
other deliberate per-chapter deviation from a rule above, is recorded here with the file, the
rule, and the reason.
