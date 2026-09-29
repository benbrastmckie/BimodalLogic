# Research: One Lean-Code Environment for the Reference Manual

## Scope

Design research for a single Typst environment, defined once in `typst/template.typ`, that
presents every Lean (and non-Lean) code listing in the Bimodal Reference Manual uniformly. Covers
the current state (re-measured against live files, not the dispatch's approximate figures),
the `ax-lean-appendix.typ` prototype the new environment should generalize, concrete geometry
facts gathered by actually compiling the book and rendering affected pages, the enforcement
surface, and the compatibility constraint with `typst/FormalFoundations.typ`. This is formatting
research only; no prose or Lean-token content is proposed for change.

Verification performed: `typst compile --root .. BimodalReference.typ` and
`typst compile --root .. FormalFoundations.typ` both run clean (0 errors, 0 warnings) from a
clean `typst/` working tree, `pdftoppm`-rendered PNGs of eight pages spanning every code-bearing
chapter, and `pdftotext -layout` column measurements against the compiled PDF (not just the
source `.typ` line lengths).

## Current State, Re-Measured

### Inventory (exact, not approximate)

| File | `#leansrc` calls | Bare ` ``` ` blocks | Notes |
|---|---|---|---|
| `chapters/ax-lean-appendix.typ` | 30 | 30 | file-local rules (below) already solve this file's problem |
| `chapters/p2-decidability-practice.typ` | 2 | 2 | book-wide default rules apply, unmodified |
| `chapters/p2-frame-classes.typ` | 1 | 1 | book-wide default rules apply, unmodified |
| `chapters/p4-dual-verification.typ` | 0 | 1 | didactic example, nested inside `#example(...)[ ]`, indented |
| `chapters/p4-dataset-pipeline.typ` | 0 | 1 (` ```json `) | didactic/illustrative, not source-quoted |
| `chapters/ax-machine-appendix.typ` | 0 | 1 (` ```python `) | didactic/illustrative, not source-quoted |
| `typst/FormalFoundations.typ` | ~45 | **0** | attribution-only `#leansrc` calls, no code block ever follows |

The dispatch's "about fifteen" for `ax-lean-appendix.typ` undercounts; the live count (post-task
647/648, both already archived/completed — `specs/archive/647_.../`, `specs/archive/648_.../`) is
30 matched `#leansrc(` calls, every one immediately followed by a ` ``` ` block within the next
non-blank line — grep-verified with no exception across the whole manual. **`FormalFoundations.typ`
never pairs `#leansrc` with a code block at all** — every citation there is attribution-only prose
support after a `#definition`/`#theorem`, which is `STYLE.md` Rule 4's documented "standalone
attribution" form. This means the new environment's "source excerpt" kind (label + code as one
inseparable unit) has **zero existing call sites in `FormalFoundations.typ`** — that file only
ever needs the current `leansrc(module, name)` signature unchanged, confirming design requirement
(5)'s compatibility approach (thin wrapper or deprecated alias) is sufficient and that no
migration work is needed there.

### Geometry, confirmed by rendering the compiled PDF

Page: A4, margin 1.75in each side (`typst/BimodalReference.typ:46`) → text width
8.27in − 3.5in = 4.77in ≈ **343pt**. Body: `New Computer Modern`, 11pt,
`leading`/`spacing` both 0.55em (`typst/BimodalReference.typ:33-40`). No `raw` font override
anywhere in `typst/` (`grep -rn "raw(" | grep -i mono` → only comments), so `raw()` uses Typst's
built-in monospace fallback (DejaVu Sans Mono) throughout.

Column-fit measurements, done by re-rendering and diffing wrapped vs. unwrapped:

| Location | Font size / budget | Widest line (chars) | Wraps? |
|---|---|---|---|
| `ax-lean-appendix.typ` (file-local 8pt/71-col rule) | 8pt, 71 cols | 71 | No — confirmed on p.94 render |
| `p2-decidability-practice.typ` `decide` signature (11pt default) | default raw size, ~64-col budget | 78 | **Yes** — confirmed on p.53 render, wraps mid-signature with zero blank line before the next paragraph |
| `p4-dual-verification.typ` `modal_search` example, nested in `#example(...)[ ]` | default | 88 | **Yes** — confirmed on p.87 render; wraps *worse* than the plain 78-col case because `#example`'s thmbox box adds a `1em` left inset (see "Nested-width tax" below), narrowing the available width further |
| `p4-dataset-pipeline.typ` JSON record | default | 78 | **Yes** — confirmed on p.82 render, the `"right": ...}, ` continuation line visibly wraps |
| `ax-machine-appendix.typ` Python loader | default | 71 | No (already ≤71, coincidentally under the appendix's own budget) |

All four dispatch-stated widths (78, 88, 78, 71) are confirmed exactly against the compiled PDF,
not just the source text — i.e. these are genuine visual wraps a reader sees, not merely
long source lines that Typst might have reflowed cleanly.

### Spacing, confirmed by rendering

- **Book-wide default (no file-local rule)**: on p.53 (`p2-decidability-practice.typ`), the wrapped
  `decide` block runs straight into the explanatory sentence that follows with **no visible gap** —
  `raw` blocks inherit ordinary block spacing, which equals the book's tight 0.55em paragraph
  spacing (`typst/BimodalReference.typ:38`). The preceding `#leansrc` label line is likewise
  spaced identically to ordinary prose — nothing visually bands the label to its code.
- **`ax-lean-appendix.typ`'s file-local rules** (`typst/chapters/ax-lean-appendix.typ:45-51`):
  `show raw.where(block: true): set text(size: 8pt)` then
  `show raw.where(block: true): it => block(above: 11pt, below: 11pt, breakable: false, it)`, plus
  a locally-shadowed `leansrc` wrapping the template's line in
  `block(sticky: true, above: 1em, below: 1em, ...)`. Rendered on p.94: visible, deliberate gaps
  both above and below the `Derivable` code block, and the `> FormalSystem.ProofSystem.Derivable.`
  label sits closer to its code than the code sits to the following paragraph. This is exactly the
  dispatch's "prototype" and it visibly works — **this is the pattern to generalize, not
  redesign**.
- Absolute units (`11pt`/`1em` where 1em = 8pt code size = 8pt, not the 11pt body size) are used
  deliberately in the local rule specifically because `em` inside a `show raw` rule resolves to the
  *raw* text size, not the body size — the file's own comment states this
  (`typst/chapters/ax-lean-appendix.typ:43-44`) and it must be preserved as the reason
  spacing is stated in absolute `pt`, not `em`, in the promoted template version.

### Nested-width tax (new finding, not in the dispatch's current-state description)

`@preview/thmbox:0.3.0`'s box constructor (`thmbox.typ:125-134`) applies
`inset: (left: 1em, right: opposite-inset)` where `opposite-inset` is `0em` whenever `fill: none`
— which is every environment style this template defines (`theorem-style`, `definition-style`,
`example-style`, etc. all set `fill: none`). So a code block nested inside `#example`/`#definition`
/`#remark`/`#theorem` sits in an effective text width of **343pt − 1em(11pt) ≈ 332pt**, not the
full 343pt. This is exactly why the `modal_search` example (88 cols) wraps *worse* — visibly
two lines instead of one graceful overflow — than the plain 78-col `decide` case: it is
simultaneously the widest line **and** the one rendered in the narrowest available box. **A column
budget validated only at the bare 343pt text width (as the appendix's 71-column rule effectively
was) is not automatically safe inside a nested environment** — design requirement (2)'s explicit
"correct behavior inside #example, #definition, #remark, figures and list items" is a real
constraint, not a formality, and the column-budget arithmetic should be re-checked at ~332pt, the
narrowest case, not 343pt.

### An unrelated but real aesthetic inconsistency, found while rendering

The template's header comment states the aesthetic is "austere, black-only body text, no
background colors" (`typst/template.typ:5-7`), and `example-style`/every other `*-style` block
explicitly sets `fill: none, stroke: none`. But the rendered `#example` box (p.87) shows a colored
green left bar and green bold title text — this is thmbox's own built-in default coloring for the
`example` kind, applied through a channel other than `fill`/`stroke` (not investigated further;
out of this task's scope, which is code-block presentation only). Noted here only because it means
the new code environment must render correctly *inside* an already-colored box, which is one more
reason design requirement (2)'s "no fills/no syntax color without an explicit before/after case"
should be read as applying strictly to the *code block itself*, not to the theorem-box family it
sits inside.

### Existing, undocumented syntax highlighting — a real defect to fix, not merely a decision to write down

Typst's `raw()` auto-highlights known languages via its built-in syntect theme whenever a `lang`
tag is present, and nothing in `typst/` disables this (`grep -rn "theme:\|syntax:"` over
`template.typ`, `BimodalReference.typ`, and every chapter returns nothing relevant). Rendering
confirmed this is live, not theoretical:

- p.82 (`p4-dataset-pipeline.typ`, ` ```json `): keys/strings/`null` render in teal, orange, green,
  and red — full syntax coloring.
- p.123 (`ax-machine-appendix.typ`, ` ```python `): keywords/strings render in purple, orange,
  green — full syntax coloring.
- Every ` ``` ` Lean block (no `lang` tag anywhere in the manual) renders plain black, because
  Typst has no language named "" to highlight.

So the manual is **already inconsistent** in exactly the dimension design requirement (2) asks to
decide deliberately: two listings are colored, thirty-three are not, and the difference is an
accident of whether a `lang` tag happens to be present — not a decision anyone made. This is
in-scope evidence for the "no fills or colored syntax highlighting without making that case
explicitly" requirement: the honest baseline to render before/after against is "JSON/Python
currently colored, Lean currently black," and the deliverable's before/after renders should show
whichever choice is made (uniform black via `#show raw: set text(fill: black)` or an explicit
`theme: none`, vs. keeping/spreading syntax color) against *this* real baseline, not an assumed
uncolored one.

## The `leansrc`/`leanref` Convention — What Already Exists Elsewhere

`typst/STYLE.md` Rule 4 already documents three citation forms (`#leansrc` block attribution,
inline backtick or `#leanref`, and a plain backtick path for files) as settled house style — this
convention is not new, and the task is generalizing its *code-block* half only.

`leanref` is defined **twice**, identically, as `raw(name)` — `typst/template.typ:130` and
`typst/notation/shared-notation.typ:60` — and has **zero call sites** anywhere under
`typst/chapters/` or in `FormalFoundations.typ` (`grep -rn "leanref" typst/` returns only the two
definitions and the STYLE.md documentation line). It is currently indistinguishable in output from
a bare backtick span.

The typst extension's own domain standard
(`context/project/typst/standards/notation-conventions.md` — source-store copy; the deployed
`.claude/` copy is stale and does not carry this section, per the dispatch's deploy-freshness
warning) documents `leansrc`/`leanref` as **the canonical cross-project pair**: "documented here as
the canonical example... no project currently calls either [leanref/its predecessor]... Prefer
`leansrc`/`leanref`... for new work." This is an argument for *keeping and narrowly adopting*
`leanref` rather than deleting it — deletion would put this manual out of step with a documented
cross-project convention it currently already partially follows (`leansrc` is used extensively).
The dispatch's explicit prohibition on wholesale backtick→`leanref` conversion (Check 1 of
`scripts/typst-sync-check.sh` must keep resolving every backtick span) rules out full adoption;
a *narrow, stated* adoption — e.g. reserving `#leanref` for the first inline mention of a
declaration name immediately adjacent to its own `#leansrc`-cited excerpt, so a reader and a
checker can tell "this identifier is the same one just quoted" from "this identifier merely
happens to be in backticks" — is compatible with both constraints and is the option this research
recommends the plan weigh against outright removal.

## Enforcement Surface — Where the New Check Belongs

**Critical finding for planning, not previously stated in the dispatch**: `scripts/typst-sync-check.sh`
is a real, git-tracked repository script (`git ls-files` confirms it). `.claude/scripts/typst-element-lint.sh`
and `.claude/scripts/chapter-quality-check.sh` are **not** — `.claude/` is listed in `.gitignore`
(`.gitignore:106`) and is a disposable deploy artifact regenerated from a source store
(`.claude-extensions.json`'s `typst` extension has `source_dir:
/home/benjamin/.config/nvim/agent-system/extensions/typst`), per
`.claude/rules/source-store-deploy-boundary.md`. Hand-editing `.claude/scripts/typst-element-lint.sh`
directly would be silently wiped by the next deploy/regeneration and would violate that rule; the
only correct way to extend "the element lint" would be to edit the source-store copy under
`/home/benjamin/.config/nvim/agent-system/extensions/typst/...`, which is an entirely different
repository outside this task's `typst/`/`scripts/` file scope.

**Recommendation**: satisfy design requirement (6) by adding a new Check (a Check 4, or a
`--code-blocks` mode) to `scripts/typst-sync-check.sh` — the file this task can actually edit and
commit — rather than touching the deployed element lint. The existing Check 1 in that same script
already contains the exact machinery the new check needs: it resolves a backtick span against
live, non-`Boneyard` Lean source across `LEAN_SRC_ROOTS`
(`${REPO_ROOT}/FormalSystem:${REPO_ROOT}/BimodalTools`) using `grep -rl --include=*.lean -F`, with
a `sync-check-whitelist.txt` escape hatch (`scripts/typst-sync-check.sh:150-220`). The new check's
"a source-excerpt call whose module-qualified declaration does not resolve" requirement is a small
variant of that same resolution logic, applied specifically to `#leansrc(module, name)` call
arguments (concatenate `module + "." + name"` and grep-resolve it, or resolve `name` alone the way
Check 1 already does for bare backticks) rather than a fresh design. The other two required
findings — "a bare triple-backtick block outside the environment in `typst/chapters/`" and "a Lean
block line over the column budget" — are pure text/regex scans over `typst/chapters/*.typ` and
need no Lean-source cross-reference at all, so they are cheaper than Check 1 and can run in
`--counts-only`-style build-free mode.

## Design Requirement Notes (for planning, not decisions made here)

1. **Kind discrimination.** The two kinds already exist as a real distinction in current usage —
   a `#leansrc`-preceded block (source excerpt, all 33 current call sites in the manual, i.e.
   everywhere except the two non-Lean listings and the one didactic `#example`) vs. a bare block
   with no `#leansrc` (didactic: the `p4-dual-verification.typ` `modal_search` example, plus the
   JSON/Python listings). A single environment taking an optional `source: (module, name)`
   argument (present → excerpt kind, absent → didactic kind) matches this cleanly and requires no
   new call-site vocabulary beyond what chapters already write.

2. **Non-Lean listings.** Two real, current, non-Lean call sites exist (JSON in
   `p4-dataset-pipeline.typ`, Python in `ax-machine-appendix.typ`), both already fenced with a
   `lang` tag Typst auto-highlights. Both are didactic (no `#leansrc`), not source excerpts, so
   kind-discrimination is orthogonal to language — a `lang:` parameter on the same environment
   (defaulting to no highlighting, or explicitly `lang: "lean"`-shaped, per whatever the
   highlighting decision above lands on) covers both without a sibling environment, and keeps the
   "one environment" framing design requirement (1) asks for.

3. **Atomicity mechanism.** The appendix prototype achieves label+code inseparability via two
   *separate* properties — `sticky: true` on the label's own block (Typst's `sticky` prevents a
   page break immediately after that block) plus `breakable: false` on the following raw block
   (prevents the code itself from splitting) — which combine correctly in practice (confirmed by
   the p.94 render) but rely on both pieces staying paired at every call site. A single outer
   `block(breakable: false)[ #label #code ]` wrapping both the label and the code as one literal
   Typst block would guarantee the same atomicity more robustly (one property, not two coordinated
   ones) and is worth planning as the more defensive choice, with the appendix's
   `sticky`+`breakable:false` combination as the documented fallback if wrapping both in one block
   turns out to fight the label's own internal spacing.

4. **Column budget arithmetic.** The appendix's 8pt/71-column pair was tuned at the *plain* 343pt
   text width. Given the confirmed ~332pt nested-width tax inside every `fill: none` thmbox
   environment (theorem/definition/example/remark, all of them), whatever budget is chosen should
   be re-validated at ~332pt if the book-wide default is expected to render inside those
   environments too (it must — `p4-dual-verification.typ`'s example already does). At DejaVu Sans
   Mono's ~0.6em-per-character advance, 71 columns at 8pt needs ≈340.8pt, which already exceeds
   332pt — the nested case will need either a smaller font, a slightly lower column budget (a
   quick check: ~69 columns at 8pt ≈ 331pt, right at the boundary), or accepting that the nested
   and un-nested contexts get different, both-documented budgets. This arithmetic should be
   re-verified by an actual compile-and-render pass once a candidate size is chosen, not trusted
   from the estimate above alone.

## Compatibility Constraints Confirmed

- `FormalFoundations.typ` compiles clean today (`typst compile --root .. FormalFoundations.typ` →
  0 errors) and imports `leansrc` from `template.typ` by name
  (`typst/FormalFoundations.typ:27`). It has zero code blocks, so it never exercises the new
  environment's code-rendering path at all — only the `leansrc(module, name)` call signature must
  keep working unchanged, which a thin wrapper (`#let leansrc(module, name) = new-env(source:
  (module, name))[]`-shaped, or literally unchanged if the new environment's excerpt kind is
  invoked by wrapping the existing `leansrc` output) satisfies trivially.
- `BimodalReference.typ` compiles clean today (0 errors, 0 warnings) — the acceptance criterion's
  "zero errors" bar is the current baseline, already met; the new environment must not regress it.
- Every chapter file's `#leansrc(` call site is untouched by this design (same two-argument
  signature everywhere); only the code block immediately following each one, and the four
  non-`leansrc`-prefixed bare blocks, are migration targets. `ax-lean-appendix.typ`'s three
  file-local `show` rules (raw-text-size, raw-block spacing, `leansrc` shadow) and its
  `sticky`/`breakable:false` combination are the deletion targets once the template supplies the
  same behavior — its **A.n section-numbering rules and list/figure spacing rules are explicitly
  out of scope** per the dispatch and must be left alone.

## Artifacts

None produced beyond this report — this is a research-only dispatch; no `typst/` files were
modified. `/tmp/.../649-render/{BimodalReference,FormalFoundations}.pdf` and eight rendered page
PNGs were produced as scratch verification only, not committed anywhere.

## Open Questions for the Plan Phase

- Whether to disable syntax-highlighting coloring uniformly (matching the currently-black Lean
  blocks) or extend it uniformly (matching the currently-colored JSON/Python blocks) — this
  research surfaces the existing inconsistency as fact but does not recommend a side, per design
  requirement (2)'s explicit call for a before/after-grounded decision.
- Left indent vs. thin left rule for code-block/prose separation — not yet rendered/compared; the
  plan phase should produce the comparison design requirement (2) asks for.
- Exact column budget number and font size, pending the ~332pt-nested-width arithmetic above being
  re-verified by an actual render once a candidate is chosen.
- Narrow-adoption wording for `#leanref`, if the plan phase takes this research's recommendation
  to keep rather than delete it.
