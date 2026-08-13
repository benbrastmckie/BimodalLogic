# Bimodal Reference Manual (Typst)

This directory contains the Typst source of the Bimodal TM Logic Reference Manual: a
two-part reference covering the formal *TM* logic, its Lean formalization, and its
automated-reasoning and training-data tooling.

## Building

### Development (with live preview)

```bash
cd typst
typst watch BimodalReference.typ build/BimodalReference.pdf
```

### Production build

```bash
cd typst
typst compile BimodalReference.typ build/BimodalReference.pdf
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
References section (rendered from `bibliography.bib`; only cited entries appear).

## Directory Structure

```
typst/
├── BimodalReference.typ           # Main document (two-part structure, front/back matter)
├── template.typ                   # Shared theorem environments, part-divider
├── bibliography.bib                # Bibliography
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

# Mechanical drift detector (2 checks: backtick name resolution, count freshness)
bash scripts/typst-sync-check.sh
```

`typst-sync-check.sh` exits non-zero with a per-violation report if any check fails; see
its header comment for the check definitions and `sync-check-whitelist.txt` for
deliberate exceptions (external-repo citations, type-signature illustrations).

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

Sweep with `grep -rn "LEAN-ANCHOR-MAY-MOVE" typst/chapters/`. Occurrence list (filled in as
markers are placed; kept in sync with the live grep output):

_pending -- populated when markers are placed against the chapters that cite this territory._

## Relationship to LaTeX Version

This directory began as a parallel port of `latex/`.
**As of 2026-07-06 the LaTeX mirror is stale and the Typst version is
authoritative**: the typst chapters were re-synchronized against the live Lean
source, while `latex/BimodalReference.tex` still describes an older
architecture. A full latex re-sync is a suggested follow-up task.

## Font Requirements

The document uses "New Computer Modern" font. If not available, Typst will fall
back to similar fonts.
