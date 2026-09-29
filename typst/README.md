# Bimodal Reference Manual (Typst)

This directory contains the Typst source of the Bimodal TM Logic Reference Manual: a
two-part reference covering the formal *TM* logic, its Lean formalization, and its
automated-reasoning and training-data tooling.

## Building

Both documents render their References section from the repository-root
`references.bib`, which is the single bibliography shared with the Lean docstrings.
Typst refuses to read a file outside its project root, so every invocation passes
`--root ..` (or `--root .` when run from the repository root).

### Development (with live preview)

```bash
cd typst
typst watch --root .. BimodalReference.typ build/BimodalReference.pdf
```

### Production build

```bash
cd typst
typst compile --root .. BimodalReference.typ build/BimodalReference.pdf
```

## Book Structure

The book is organized into two parts, preceded by the introduction (see
`BimodalReference.typ`'s `#part-divider(...)` calls, which are the authoritative source
of book order):

| Part | Title | Contents |
|------|-------|----------|
| I | The Bimodal System | Syntax, task-frame semantics, the Burgess-Xu proof system, frame classes, metalogic, decidability in practice, theorems, plus LTL-to-TM positioning, the Vlach/BL* tower, and the decidability frontier |
| II | Applications | Proof automation, the training-data pipeline, dual verification and worked examples |

Back matter: `06-notes.typ` (implementation status and discrepancy notes) and the
References section (rendered from the repository-root `references.bib`; only cited
entries appear).

## Directory Structure

```
typst/
├── BimodalReference.typ           # Main document (two-part structure, front/back matter)
├── template.typ                   # Shared theorem environments, part-divider
├── SYNC-MAP.md                     # Dev-side claim-verification history (does not govern the PDF)
├── sync-check-whitelist.txt        # Whitelist for scripts/typst-sync-check.sh Check 1
├── notation/
│   ├── shared-notation.typ        # Shared notation (mirrors notation-standards.sty)
│   └── bimodal-notation.typ       # Bimodal-specific notation
├── generated/
│   └── status.typ                 # GENERATED -- regenerate via scripts/typst-status-counts.sh
├── chapters/
│   ├── 00-introduction.typ        # Front matter: introduction
│   ├── 01-syntax.typ              # Part I: formula syntax
│   ├── 02-semantics.typ           # Part I: task frames and truth conditions
│   ├── 03-proof-theory.typ        # Part I: axioms and inference rules
│   ├── p2-frame-classes.typ       # Part I: frame classes and extensions
│   ├── 04-metalogic.typ           # Part I: soundness, completeness
│   ├── p2-decidability-practice.typ  # Part I: decidability in practice
│   ├── 05-theorems.typ            # Part I: perpetuity principles
│   ├── p3-ltl-to-tm.typ           # Part I: LTL-to-TM positioning (in progress)
│   ├── p3-vlach-blstar.typ        # Part I: Vlach operators and the BL* tower (in progress)
│   ├── p3-decidability-frontier.typ  # Part I: decidability frontier w/ SLOT-IN anchors (embargoed content pending)
│   ├── p4-proof-automation.typ    # Part II: tactics, Aesop, bounded proof search
│   ├── p4-dataset-pipeline.typ    # Part II: the training-data pipeline
│   ├── p4-dual-verification.typ   # Part II: dual verification and worked examples
│   └── 06-notes.typ               # Back matter: implementation status, discrepancy notes
└── build/                         # Output directory (PDF)
```

## Scripts

Two scripts, run from the repository root, keep the book synchronized with Lean source:

```bash
# Regenerate volatile counts (axiom constructors, rules, sorry inventory)
bash scripts/typst-status-counts.sh            # writes typst/generated/status.typ
bash scripts/typst-status-counts.sh --json     # JSON to stdout only

# Mechanical drift detector (4 checks: backtick name resolution; count
# freshness, including the automation-module-map sub-check; machine-appendix
# freshness; and code-environment discipline over typst/chapters/)
bash scripts/typst-sync-check.sh
```

`typst-sync-check.sh` exits non-zero with a per-violation report if any check fails; see
its header comment for the check definitions and `sync-check-whitelist.txt` for
deliberate exceptions (external-repo citations, type-signature illustrations). Check 4
(code-environment discipline) is build-free like the others: it fails on a bare fenced
code block under `chapters/` not wrapped in `lean-code()`, on a code line over that
environment's column budget, and on a `lean-code(source: (module, name))` call whose
`name` does not resolve in live, non-Boneyard Lean source (reusing Check 1's
grep-based resolution and whitelist).

## Style

`STYLE.md` in this directory is the single house style for every chapter under `chapters/`
(chapter opening shape, section rhythm, element order, Lean-citation forms, cross-reference
convention, list syntax, table/figure convention, and the no-local-helpers rule). New chapters
and any editorial pass over existing chapters follow it; the two appendices are governed by their
own conventions instead, as `STYLE.md` states at its top.

## Code Environment

Every Lean, JSON, and Python code block in the manual is presented through one environment,
`lean-code()`, defined once in `template.typ` and used by every chapter -- no chapter carries
its own file-local raw-block or spacing rules for code.

**Two kinds**, selected at the call site by whether `source:` is given:

- **Source excerpt** -- `#lean-code(source: ("Module.Path", "declName"))[ ...code... ]` --
  quotes the live source verbatim up to whitespace (docstrings omitted), and renders the
  module-qualified `> Module.Path.declName.` label and the code as one unbreakable unit, the
  label closer to its code than the code is to the surrounding prose.
- **Didactic example** -- `#lean-code[ ...code... ]`, no `source:` argument -- a worked example
  written for the manual, same visible family, no label.

A block's language (Lean, JSON, Python, shell, ...) is carried by the fence's own tag
(` ```json `, ` ```python `, or a bare fence with no tag for Lean); `lean-code()` needs no
separate language parameter, and renders every language identically in black -- there is no
syntax highlighting, matching the template's austere, black-only, no-fills aesthetic.

**Geometry**: 8pt raw text in the explicit font `"DejaVu Sans Mono"` (chosen over the raw
element's implicit default font, whose per-glyph width was found uneven across the manual's
Lean unicode operators, and confirmed by a rendered glyph check to cover every non-ASCII symbol
appearing in a code block: `¬ ↑ → ↔ ∀ ∃ ∈ ∧ ≤ ⊆ ⊢ ⊨ □ △ ▽ ◇ ⟨ ⟩ ₁ ₂ Γ Δ σ τ φ ψ`). 11pt spacing
above and below the whole block, in absolute units (not em, which inside a raw show rule
resolves to the 8pt code size rather than the 11pt body size). A 1em left inset separates code
from prose without a left rule, which would visually compete with `thmbox`'s own colored left
bar already marking `#example`/`#definition`/etc. Unbreakable by default (`breakable: false`);
pass `breakable: true` to opt out for a listing too long to fit one page.

**Column budget: 63 monospace columns**, one number applied book-wide. It is derived from the
narrowest real case -- a block nested inside `#example`/`#definition` (`thmbox`'s insets narrow
the page's 343.28pt text width to 321.28pt there), combined with the environment's own 1em left
inset -- where a rendered boundary sweep of real appendix content found 64 columns fit and 65
wrapped; 63 keeps a one-column margin. Every plain, top-level block has strictly more headroom
at the same budget.

**Excerpt-fidelity policy**: a source excerpt is verbatim up to whitespace; docstrings are
omitted; a line exceeding the column budget is re-broken at whitespace only, in one consistent
layout for a declaration (name and parameters, then hypotheses, then conclusion), and no token
is ever altered by a re-break.

**Compatibility**: `leansrc(module, name)` stays exported with its original two-argument
signature, as a thin wrapper over `lean-code()`'s own label rendering, so `FormalFoundations.typ`
(whose `#leansrc` calls are attribution-only, never followed by a code block) compiles
unchanged. `leanref(name)` renders an inline Lean identifier in the same explicit monospace font
as `lean-code()`, for visual consistency between an inline citation and a block excerpt; it is
not applied retroactively to the manual's existing inline backtick spans.

## Package Dependencies

- `@preview/thmbox:0.3.0` - Theorem environments (imported via `template.typ`)
- `@preview/cetz:0.3.4` - Diagrams (light cone, in the introduction)
- `@preview/fletcher:0.5.8` - Diagrams (unification-grid frontispiece, `extension-node`/`part-divider` helpers)

Packages are downloaded automatically on first compile.

## Source Synchronization

The chapters are synchronized against the live Lean source in `FormalSystem/`
(excluding `Boneyard/`). `SYNC-MAP.md` in this directory is a repo-side development
document recording the claim-verification history; it does not govern the compiled PDF.
When the Lean source moves, regenerate via the scripts above rather than editing counts
by hand.

## Follow-Up Work

The remaining in-progress chapters are completed by follow-up work, tracked internally in this
repository's task-management system (not cited here by number -- see the repository rule against
task-number references in deliverables):

| Chapter(s) / Artifact | Scope |
|------------------------|-------|
| `p3-ltl-to-tm.typ`, `p3-vlach-blstar.typ`, `p3-decidability-frontier.typ` | Part I positioning chapters (Lk-abstracted; see EMBARGO note in `p3-decidability-frontier.typ`) |
| `generated/machine-appendix.*` (pointer in `p4-dataset-pipeline.typ`) | Machine-readable JSONL appendix, exported from Lean |
| Part III/IV chapters (tensed counterfactual logic, then constitutive structure) | Superseded -- Parts III/IV were cut entirely, so this scope no longer applies |
| Decidability Frontier `// SLOT-IN:` anchors (`ladder-table`, `complexity-map`, `case-study`) | Lk slot-in for the Decidability Frontier chapter, post-TACAS-acceptance only |

## Marker Convention

Some claims cite a Lean anchor that sits in territory an in-flight Lean formalization task is
expected to move (canonical-frame/completeness proofs, the semantic FMP, and the CO/Reynolds-triple
independence result). Rather than hedge the reader-facing prose, the anchor itself is flagged with
a maintainer-only marker so a later re-sync sweep is a `grep`, not a re-audit:

```
// LEAN-ANCHOR-MAY-MOVE: <scope> -- see typst/README.md
```

placed as a plain Typst line comment immediately above the citing line (invisible in the compiled
PDF). The `<scope>` suffix names what will move the anchor, not a task number:

- `canonical-completeness` -- canonical-frame and completeness anchors under `Metalogic/BXCanonical/`
- `semantic-fmp` -- FMP anchors under `Metalogic/Decidability/FMP/`
- `co-reynolds-independence` -- `ProofSystem/Axioms.lean` Layer 9, immediately above the
  `Axiom.prior_U_gap` constructor

Sweep with `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/chapters/`. Occurrence list (7 markers,
matching the live grep output as of this revision):

| Scope | File | Line | What it guards |
|-------|------|------|----------------|
| `canonical-completeness` | `chapters/04-metalogic.typ` | 172 | `Weak Completeness (ZTime)`/`(RTime)` theorem boxes (`soundness_dense`/`soundness_ztime`/`soundness_rtime`) |
| `canonical-completeness` | `chapters/04-metalogic.typ` | 178 | `Completeness (Base)` theorem box and its `sorryAx` status note |
| `canonical-completeness` | `chapters/04-metalogic.typ` | 235 | Base-frame completeness open-step paragraph (`WeakCanonical.countermodel_discrete` dependency) |
| `canonical-completeness` | `chapters/06-notes.typ` | 75 | Completeness Status subsection's `Metalogic/BXCanonical/Completeness.lean` citation |
| `semantic-fmp` | `chapters/p2-decidability-practice.typ` | 34 | `FMP-Based Completeness` theorem box (`fmp_completeness`) |
| `semantic-fmp` | `chapters/p2-decidability-practice.typ` | 61 | `filtered_world_bound`/`assignmentSpace_card` sentence |
| `co-reynolds-independence` | `chapters/p2-frame-classes.typ` | 84 | `RTime` row of the axiom-assignment table (`prior_U_gap`/`prior_S_gap`/`sep`) |

This list is not claimed exhaustive of every citation that could plausibly move -- it covers the
headline theorem boxes and summary claims for each scope, which is where a re-sync sweep should
start; a full re-audit after 415/417/419 land may still surface secondary prose mentions the
grep-based sweep above did not individually mark.

## CONFIRM Tag Convention

The manual states the *target end state* of the system — what the finished Lean repository and
the finished source paper both deliver — rather than a progress report. Wherever the body asserts
a result that one of those two artifacts has not yet established, the obligation is carried by a
`CONFIRM` comment, invisible in the compiled PDF:

```
// CONFIRM(lean): <assertion>
// CONFIRM(paper): <assertion>
```

- **Syntax**: exactly this shape — two slashes, one space, `CONFIRM`, parenthesized lowercase
  target qualifier, colon, space, assertion on one line (continuation lines start `//   `).
- **Target qualifiers**: `lean` = the finished Lean repo must satisfy the assertion; `paper` =
  the finished paper must state/restore the assertion.
- **Placement**: immediately above the claim it guards (adjacent line, same indentation), the
  same placement rule as `LEAN-ANCHOR-MAY-MOVE`.
- **Checkability**: every CONFIRM states a checkable proposition — a fully qualified Lean
  theorem name that must exist and be axiom-free (verifiable via `lean_verify` or
  `#print axioms`), a script output condition (e.g. `scripts/typst-status-counts.sh --json`
  reports `sorry_total_excl_boneyard = 0`), or a named paper anchor that must state a given
  proposition. Never "verify this section". CONFIRM comments are the ONLY place in `typst/`
  where paper anchors may appear, and anchors there are written WITHOUT backticks so they never
  become sync-check Check-1 candidates.
- **Extraction commands** (scoped to `.typ` sources so this README's own examples never match):
  `grep -rn --include='*.typ' 'CONFIRM(' typst/` — filter with
  `grep -rn --include='*.typ' 'CONFIRM(lean)' typst/` or
  `grep -rn --include='*.typ' 'CONFIRM(paper)' typst/`.
- **Well-formedness check**:
  `grep -rn --include='*.typ' 'CONFIRM(' typst/ | grep -vE '// *CONFIRM\((lean|paper)\): ' | grep -vE '//   '`
  must output nothing.

## Relationship to LaTeX Version

This directory began as a parallel port of a now-retired LaTeX edition.
**As of 2026-07-06 the LaTeX mirror was declared stale and the Typst version
authoritative**: the typst chapters were re-synchronized against the live Lean
source, while the LaTeX edition still described an older architecture. The
LaTeX edition has since been removed from the tracked tree; this typst
directory is now the sole maintained reference.

## Font Requirements

The document uses "New Computer Modern" font. If not available, Typst will fall
back to similar fonts.

## Standalone Reports

This directory also hosts standalone research reports that are **not** chapters of
`BimodalReference.typ` and are not `#include`d by it -- they import the book's
`template.typ` and `notation/bimodal-notation.typ` so notation cannot drift, and cite
the repository-root `references.bib`, but compile to their own, separate PDF.

### `FormalFoundations.typ`

Formal foundations of bimodal *TM* logic: completeness and representation. A
research-facing report on what is proved, what is not, and what a general
representation theorem would require.

```bash
cd typst
typst compile --root .. FormalFoundations.typ build/FormalFoundations.pdf
```
