# Research Report: Task #579

**Task**: 579 - Nest MinusLanguage/, PlusLanguage/, StarLanguage/ under Syntax/
**Started**: 2026-09-15T21:03:03-07:00
**Completed**: 2026-09-15T21:26:00-07:00
**Effort**: Medium (mechanical move; the cost is in the documentation/invariant sweep, not the Lean)
**Dependencies**: None
**Sources/Inputs**:
- Codebase (`FormalSystem/`, `docs/`, `scripts/`, `Tests/`)
- `scripts/check-module-invariants.sh` (C4/C5/C6/C8/C12/C13/C14/C20/INV), `scripts/readme-lint.sh`
- `specs/reviews/review-2026-09-15.md` Findings H1, L1, M2
- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`
- Measured baselines: `lake build`, `check-module-invariants.sh --no-build`, `readme-lint.sh`
**Artifacts**:
- `specs/579_nest_minuslanguage_pluslanguage_starlang/reports/01_nest-language-family-under-syntax.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The move is safe and there is no Lean-level obstruction.** Real blast radius is **41 import
  lines across 26 `.lean` files** (the review's "24 files" undercounts). There is no import
  cycle: the three trees import *down* into `Syntax` leaf modules and *up* into
  `ProofSystem`/`Theorems`/`Metalogic.Core`, but never through the `FormalSystem.Syntax`
  aggregator, and Lean cycles are per-module, not per-directory.
- **Namespaces must stay flat** (`FormalSystem.MinusLanguage`, not
  `FormalSystem.Syntax.MinusLanguage`). Renaming them would touch **103 sites** (79 `open` lines
  + 24 fully-qualified uses) plus the C14 `#print axioms` baseline inside
  `check-module-invariants.sh`. Module/namespace divergence is already this repo's convention for
  nested directories (`Syntax/SubformulaClosure/Closure.lean` declares `namespace
  FormalSystem.Syntax`; `Metalogic/Conservativity/Plus/Forward.lean` declares `namespace
  FormalSystem.Metalogic.Conservativity`).
- **Scope item 4 carries a hidden prerequisite.** Adding `"FormalSystem/Syntax"` to C8's `parent`
  tuple makes C8 walk *every* Lean-bearing subdirectory of `Syntax/` — which today includes
  `SubformulaClosure/`, and `FormalSystem/Syntax/SubformulaClosure.lean` **does not exist**.
  Without creating it, item 4 alone turns a currently-green C8 red.
- **Scope item 3's premise is false.** `FormalSystem/MinusLanguage/README.md` already exists (74
  lines, committed 2026-09-08), and `readme-lint.sh` reports `Missing READMEs: 0` across 56
  READMEs. The real defect is the stale `| MinusLanguage/ | No | ... (no README yet) |` row at
  `FormalSystem/README.md:311`, plus the table's missing `StarLanguage/` row.
- **`FormalSystem/Syntax.lean` must NOT import the three nested aggregators.** Doing so would make
  the 15 files that `import FormalSystem.Syntax` transitively pull in `Theorems/` and
  `Metalogic/Core/`. C8 does not require a parent→child aggregator import, so keeping the three
  imports in `FormalSystem/FormalSystem.lean` is both correct and compliant.
- **Baseline is mixed**: `lake build` is green (2651 jobs, exit 0), but
  `check-module-invariants.sh` is **already RED** with one pre-existing failure unrelated to this
  task (`FAIL C13`, two dangling links to `.github/workflows/docs.yml`, renamed to
  `docs.yml.disabled` by commit `9bcbe9e41`). The dispatch's verify criterion cannot be met
  without repairing those two lines.

## Context & Scope

Researched whether `FormalSystem/MinusLanguage/`, `FormalSystem/PlusLanguage/` and
`FormalSystem/StarLanguage/` can be physically nested under `FormalSystem/Syntax/` with proof
content preserved verbatim, and what the full mechanical consequence set is: Lean import graph,
namespace resolution, the 26 machine-checked invariants in
`scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`, and the documentation surface.

Constraints honoured: module-path rename only, zero proof-content change (C3's zero-`sorry`
invariant is preserved trivially — no tactic or term is touched), and no new axioms.

## Findings

### Codebase Patterns

**Measured blast radius (corrected).** `grep -c '^import FormalSystem\.\(Minus\|Plus\|Star\)Language'`
over the tree:

| Category | Import lines | Files |
|---|---|---|
| Internal to the three moved directories | 14 | 11 |
| The three sibling aggregators (`MinusLanguage.lean` 5, `PlusLanguage.lean` 4, `StarLanguage.lean` 4) | 13 | 3 |
| External consumers | 14 | 12 |
| **Total** | **41** | **26** |

External consumers are `FormalSystem/FormalSystem.lean` (3 lines),
`Metalogic/Conservativity/Backward.lean`, `Metalogic/Conservativity/Plus/{AxiomValidity,PlusSoundness}.lean`,
`Metalogic/Conservativity/Star/{StarAxiomValidity,StarSoundness}.lean`,
`Metalogic/Deterministic/System.lean`, `Metalogic/Independence/NaiveSystem.lean`, and
`Semantics/{MinusFrame,MinusTruth,PlusTruth,StarTruth}.lean`. **Zero in `Tests/`** — the test
suite reaches these namespaces through `open`, not `import`.

The review's "7 + 11 + 6 = 24 files" is a per-language file count that double-counts across
languages and omits several; the authoritative figure for planning is 41 lines / 26 files.

**No cycle, and the reason is precise.** Every dependency the three trees have on `Syntax/` is on
a *leaf* module (`FormalSystem.Syntax.Atom`, `.Formula`, `.Context`), never on the
`FormalSystem.Syntax` aggregator. Likewise `ProofSystem/`, `Theorems/` and `Metalogic/Core/`
import `FormalSystem.Syntax.Formula`/`.Context`/`.SubformulaClosure.*` directly, never the
aggregator. So the post-move graph has no module-level cycle — which is what Lean checks.

**But the upward dependency is real and constrains the aggregator wiring.**
`MinusLanguage/AxiomDischarge.lean` imports `FormalSystem.Metalogic.Core.DeductionTheorem` and
six `FormalSystem.Theorems.*` modules. If `FormalSystem/Syntax.lean` were made to import
`FormalSystem.Syntax.MinusLanguage`, then the 15 files that do a bare `import FormalSystem.Syntax`
— seven under `Automation/`, two under `Metalogic/Decidability/`, `FormalSystem.lean`, and four
under `Tests/` — would start transitively elaborating the whole `Theorems` + `Metalogic.Core`
layer. **Recommendation: leave `Syntax.lean` alone and keep the three aggregator imports in
`FormalSystem/FormalSystem.lean`, repointed to the new paths.** C8 only checks that a sibling
`X.lean` exists beside `X/` (and that no self-named `X/X.lean` exists); it never checks that a
parent aggregator imports its children, so this is fully compliant.

**Namespaces: leave them alone.** All three trees declare `namespace FormalSystem.MinusLanguage`
/ `.PlusLanguage` / `.StarLanguage`. Renaming to match the new module depth would touch 79 `open`
lines and 24 fully-qualified references (103 sites), and would additionally invalidate two entries
in `scripts/module-invariants-allowlist.txt` and the C14 axiom baseline embedded in
`scripts/check-module-invariants.sh` (`#print axioms FormalSystem.StarLanguage.StarDerivationTree`
at lines 1469 and 1581). It is also unnecessary: this repository already keeps namespaces flatter
than module paths for nested subdirectories, so the post-move divergence is the existing
convention rather than an exception to it.

**The language family is not a linear chain, and the README section should say so.** Measured
constructor sets:

| Directory (post-move) | Language | Type | Constructors |
|---|---|---|---|
| `Syntax/` | L | `Formula` | `atom`, `bot`, `imp`, `box`, `untl`, `snce` (6) |
| `Syntax/MinusLanguage/` | L⁻ | `MinusFormula` | `atom`, `bot`, `imp`, `box`, `allPast`, `allFuture` (6) |
| `Syntax/PlusLanguage/` | L⁺ | `PlusFormula` | L's six + `stab` (`⊡`) (7) |
| `Syntax/StarLanguage/` | L⋆ | `StarFormula` | L⁺'s seven + `timeStore` (`↑ⁱ`), `timeRecall` (`↓ⁱ`) (9) |

L ⊂ L⁺ ⊂ L⋆ is genuine constructor extension. **L⁻ is not an extension of L** — it is a sibling
variant with `H`/`G` primitive in place of `untl`/`snce`, related to L by the translation
`tr : MinusFormula → Formula` (`MinusLanguage/Translation.lean`). Describing the four as one
"extension hierarchy" (the review's phrasing, carried into the task description) would put a
false claim in the very README section written to fix a discoverability problem.

### External Resources

No Mathlib lemma search was required: this task moves modules and edits documentation, and
introduces no new mathematical content. `lean_local_search` / `leansearch` / `loogle` were
therefore not exercised. No Mathlib API is affected — nothing under the three directories imports
`Mathlib` in a way the move perturbs.

### Invariant-Gate Impact (the substantive work)

**C8 — `scripts/check-module-invariants.sh:947`.** The loop is
`for parent in ("FormalSystem", "FormalSystem/Metalogic"):` and, for each Lean-bearing
subdirectory, requires a sibling `X.lean`. Adding `"FormalSystem/Syntax"` brings **four**
subdirectories into scope post-move: the three new ones (whose aggregators arrive with them) and
**`SubformulaClosure/`, which has no sibling aggregator today**. `FormalSystem/Syntax.lean`
currently imports that directory's four leaf modules individually. Create
`FormalSystem/Syntax/SubformulaClosure.lean` importing `Closure`, `NestingDepth`,
`TemporalFormulas` and `IteratedTemporal`, and repoint `Syntax.lean` at the aggregator — that also
keeps the new file reachable, so C6/C7 do not report it as an unreachable module needing a
manifest entry.

**C5 — markdown module paths.** C5 resolves any `FormalSystem.Xxx.Yyy` token in non-`specs/`
markdown against the filesystem and cannot distinguish a namespace from a module path. Nine
tokens resolve today and will not after the move:

- Module-shaped, rewrite to `FormalSystem.Syntax.MinusLanguage.*`:
  `.Formula`, `.Axioms`, `.Derivation`, `.Translation`, `.AxiomDischarge` — all five at
  `docs/development/MODULE_ORGANIZATION.md:301-305`.
- Bare `FormalSystem.MinusLanguage` / `.PlusLanguage` / `.StarLanguage` — at `NOTATION.md:49`,
  `docs/reference/API_REFERENCE.md:791`, `docs/theorem-index.md:43-45`,
  `docs/development/NAMING_CONVENTION_DEVIATION.md:291`. These read as *namespaces* in
  `theorem-index.md` and `NOTATION.md` but as *module headings* in `API_REFERENCE.md`. Rewrite the
  module readings; add the namespace readings to `scripts/module-invariants-allowlist.txt`,
  following that file's existing one-comment-per-entry convention (it already carries
  `FormalSystem.StarLanguage.StarAxiom` and `FormalSystem.StarLanguage.StarDerivationTree` for
  exactly this reason).

`FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness` is unaffected — different
directory.

**C12 / C13 / readme-lint Check 3 — path and link references.** 106 slash-shaped references to
`FormalSystem/{Minus,Plus,Star}Language` across 57 non-`specs/` files. Gated subsets:
C12 (slash paths in `docs/` + `README.md`, 78 markdown files, currently PASS), C13 (relative
markdown links in the same scope), and `readme-lint.sh` Check 3 (broken relative file references,
currently 0 and exit-code-affecting). Concretely broken by the move:
- The 10 `../`-relative links in `MinusLanguage/README.md:62-66` and `PlusLanguage/README.md:83-87`
  all gain a level (`../README.md` → `../../README.md`, `../Syntax/README.md` → `../README.md`, …).
- `FormalSystem/README.md:303-313` — the `Submodule Navigation` table's
  `[PlusLanguage/](PlusLanguage/README.md)` link must become `Syntax/PlusLanguage/README.md`.
- `FormalSystem/README.md:251-256, 265-267` — the aggregator/component tables list these as
  root-level modules.

**INV — generated inventory blocks.** Three gated blocks change: `README.md:17`
(`dir=FormalSystem rows=totals`), `FormalSystem/README.md:240` (`dir=FormalSystem rows=loose`),
and `FormalSystem/Syntax/README.md:7` (`dir=FormalSystem/Syntax`, which gains three subdirectory
rows). Regenerate with `bash scripts/check-module-invariants.sh --emit-inventory`, verify with
`--emit-inventory --check`.

**C20 — no work needed.** Its resolver matches a citation `X/Y.lean` against any live path ending
in `/X/Y.lean`, so `StarLanguage/Axioms.lean:133` still resolves at the deeper path, and no line
numbers change. Verified by reading the resolver at `scripts/check-module-invariants.sh:1851-1859`.

**C4 / C14 / C22 / C23 / C24 / C26 — unaffected**, provided namespaces and proof content are left
verbatim. C14's `#print axioms` baseline keys on declaration names, not module paths.

### Measured Baselines

| Gate | Result today |
|---|---|
| `lake build` | **PASS** — `Build completed successfully (2651 jobs)`, exit 0 |
| `check-module-invariants.sh --no-build` | **FAIL**, exit 1 — one failure: `C13: 2 unresolved relative markdown link(s)` |
| `readme-lint.sh` | **PASS** — 56 READMEs, `Missing READMEs: 0`, `Broken file references: 0` |

The C13 failure is `README.md:336` and `docs/README.md:308`, both linking
`.github/workflows/docs.yml`; that file is now `.github/workflows/docs.yml.disabled` (commit
`9bcbe9e41`, "ci: disable API Documentation workflow"). It predates this task and is unrelated to
the nesting, but the dispatch's verify criterion is "`scripts/check-module-invariants.sh` passes",
which is unreachable while it stands.

### Recommendations

A sorry-free path is trivially available: **no proof content changes at all**. C3's zero-`sorry`
invariant is preserved by construction. Suggested phase decomposition, each phase independently
verifiable and green-committable:

1. **Prerequisite.** Create `FormalSystem/Syntax/SubformulaClosure.lean`; repoint
   `FormalSystem/Syntax.lean` at it. Verify: `lake build`, C8 still green.
2. **The move.** `git mv` the three trees and their three aggregators into `FormalSystem/Syntax/`
   (preserves history); rewrite all 41 import lines. Delete nothing else; confirm no stale
   `FormalSystem/{Minus,Plus,Star}Language.lean` is left at root. Verify: `lake build`, C4.
3. **C8 extension.** Add `"FormalSystem/Syntax"` to the `parent` tuple at
   `scripts/check-module-invariants.sh:947`. Verify: C8.
4. **Doc/path sweep.** C5 token rewrites + allowlist additions; C12/C13 and readme-lint relative
   links; `FormalSystem/README.md` tables (including the `StarLanguage/` row that has never
   existed and the stale `MinusLanguage/ | No` row). Verify: C5, C12, C13, `readme-lint.sh`.
5. **Inventory re-emit.** `--emit-inventory`, then `--emit-inventory --check`. Verify: INV.
6. **The discoverability fix.** New `## Language family` section in `FormalSystem/Syntax/README.md`
   using the constructor-delta table above, stating plainly that L⁻ is a translation-related
   sibling and L ⊂ L⁺ ⊂ L⋆ is the extension chain, and naming `stab`/`⊡` so a future reader
   searching for boxdot lands on it. Add the namespace-divergence note to
   `docs/development/MODULE_ORGANIZATION.md` §2.
7. **Full gate.** `lake build` + `check-module-invariants.sh` + `readme-lint.sh`.

## Decisions

- **Keep namespaces flat** (`FormalSystem.MinusLanguage`, etc.). Rationale: 103 call sites, the
  C14 axiom baseline, and existing repo precedent for module/namespace divergence.
- **Do not add the nested aggregators to `FormalSystem/Syntax.lean`**; keep them in
  `FormalSystem/FormalSystem.lean`. Rationale: avoids a transitive `Theorems`+`Metalogic.Core`
  dependency for the 15 bare `import FormalSystem.Syntax` consumers. C8 permits this.
- **Reinterpret scope item 3** from "write `MinusLanguage/README.md`" to "repair the stale
  `Submodule Navigation` table in `FormalSystem/README.md`". The README exists; the table lies.
  The dispatch's own carve-out ("`ForMathlib/README.md` is NOT needed here") also rests on the
  same stale row and should be re-read against the filesystem rather than the table.
- **Repair the two C13 links as part of this change** (assumption, stated rather than blocking):
  point `README.md:336` and `docs/README.md:308` at `docs.yml.disabled`, or drop the link and say
  the workflow is disabled. Two lines; without it the dispatch's verify criterion cannot pass. If
  the user prefers strict scope containment, the alternative is to record the pre-existing C13
  failure in the summary and assert "no *new* invariant failures" instead.
- **No ADR is required.** ADR-006 declined a *different* move on measured grounds (339 import
  lines, 137 files, a live directory-level cycle); this move has 41 lines, 26 files, no cycle, and
  the review already records the contrast. A short pointer in `docs/architecture/README.md` is
  optional, not needed for the gates.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Item 4 (C8 parent tuple) done without item 1 turns a green C8 red | Sequence the `SubformulaClosure.lean` prerequisite first; it is phase 1 above |
| Half-updated doc sweep leaves C5/C12/C13 red while `lake build` is green | Treat the doc sweep as its own phase with its own gate run; do not close on `lake build` alone |
| Blanket search-and-replace of `FormalSystem.MinusLanguage` → `FormalSystem.Syntax.MinusLanguage` corrupts namespace references in 103 sites and the C14 baseline | Restrict rewriting to lines beginning `import `, plus the specific markdown module-path tokens enumerated under C5 above |
| Aggregator left behind at `FormalSystem/MinusLanguage.lean` | C8 does not check sibling→dir, so this would pass C8; C4 catches the dangling imports. Verify with an explicit `ls FormalSystem/*.lean` diff |
| `git mv` not used, losing file history for 14 files | Mandate `git mv` in the plan's phase-2 step text |
| Pre-existing `FAIL C13` read as caused by this task | Baseline recorded in this report; compare against it, not against "green" |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task is a module-path reorganization with an
  explicit no-proof-content-change constraint; there is no proof goal to survey, and
  `lean_multi_attempt` / `lean_hammer_premise` have no target. Proof-level verification is
  delegated to `lake build`, which is green at baseline.

## Context Extension Recommendations

- **Topic**: Namespace-vs-module-path divergence in this repository.
  **Gap**: `docs/development/MODULE_ORGANIZATION.md` §2 asserts "Namespaces mirror directory
  structure" and names `Bimodal` as the root namespace — both false of the current tree
  (`Syntax/SubformulaClosure/`, `Metalogic/Conservativity/Plus/`, and `FormalSystem.*` as the
  actual root). Every future nesting decision will hit this.
  **Recommendation**: Update that section in phase 6, stating the real convention — a nested
  subdirectory keeps its component's namespace — and give the two existing examples.

- **Topic**: What `check-module-invariants.sh` does and does not gate, for reorganization work.
  **Gap**: The C5-cannot-distinguish-namespace-from-module-path behaviour, and C8's
  existence-only (not import-graph) semantics, are each discoverable only by reading the script.
  **Recommendation**: A short `.claude/context/project/lean4/patterns/` note on the invariant
  gates most sensitive to file moves (C4, C5, C8, C12, C13, INV) and the ones that are robust
  (C14, C20).

## Appendix

**Adjacent stale documentation found while measuring** (all cheap, all in files the plan already
opens; none is required for the gates to pass):

- `FormalSystem/Syntax.lean` module docstring lists the primitives as `atom, bot, imp, box,
  allPast, allFuture`, contradicting `Syntax/Formula.lean` (`untl`/`snce`) and
  `FormalSystem/README.md:71`. This is the same operator-delta confusion the new
  `Syntax/README.md` section exists to fix.
- `docs/development/MODULE_ORGANIZATION.md` §1's directory tree omits `StarLanguage/` and
  `ForMathlib/` entirely.
- `FormalSystem/Syntax/README.md:15` describes `SubformulaClosure/` as "(3 files)"; there are 4.
  The count sits in the hand-written description column, which is why INV does not catch it.
- `FormalSystem/StarLanguage/README.md` has no `Last verified` date; `MinusLanguage/README.md`
  carries two different `Last verified` footers. Both reported-not-gated by `readme-lint.sh`.
- `specs/reviews/review-2026-09-15.md`'s metrics table row "Directories missing a README
  (excluding Boneyard) | 2 (`ForMathlib/`, `MinusLanguage/`)" is measured from
  `FormalSystem/README.md`'s table rather than the filesystem; `readme-lint.sh` reports 0.

**Commands used** (all re-runnable):

```
grep -rc '^import FormalSystem\.\(Minus\|Plus\|Star\)Language' --include='*.lean' -r .
grep -rn '^open .*\(Minus\|Plus\|Star\)Language' --include='*.lean' .
grep -rhoE '\bFormalSystem(\.[A-Z][A-Za-z0-9_]*)+' --include='*.md' .
sed -n '939,970p' scripts/check-module-invariants.sh          # C8
sed -n '798,843p' scripts/check-module-invariants.sh          # C5
sed -n '1836,1900p' scripts/check-module-invariants.sh        # C20 resolver
bash scripts/check-module-invariants.sh --no-build
bash scripts/readme-lint.sh
lake build
```

**References**

- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md` — the declined regroup, and the
  measurement standard this task is judged against
- `docs/reference/readme-standard.md` — generated-inventory block syntax
- `scripts/module-invariants-allowlist.txt` — the sanctioned C5 namespace-token exemption
  mechanism and its documented usage rule
