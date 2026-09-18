# Implementation Plan: Task #620

- **Task**: 620 - Lean 4 appendix for BimodalReference.typ
- **Status**: [COMPLETED]
- **Effort**: 7.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/620_lean_appendix_bimodal_reference/reports/01_lean-appendix-research.md
- **Artifacts**: plans/01_lean-appendix-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false (Typst deliverable; Lean is used only to compile-verify snippets, no library code changes)

## Overview

Add a new back-matter appendix `typst/chapters/ax-lean-appendix.typ` ("Appendix: Reading the
Lean Formalization", label `<lean-appendix>`) that builds from what Lean is up to reading the
`FormalSystem/` source the book's formal claims point to. The appendix goes before the machine
appendix in `typst/BimodalReference.typ` and is cross-referenced from the introduction's
"Outline" and "How to Read This Book" sections. The seed docs (`docs/user-guide/tutorial.md`,
`quickstart.md`, `docs/development/LEAN_STYLE_GUIDE.md`, `docs/reference/tactic-reference.md`)
supply framing only. Every Lean excerpt is either a `#leansrc` block quoted from a live
declaration or a new didactic example compiled first in a scratch file with `lake env lean`.

### Research Integration

- Seed status (report §4): `tutorial.md` is the intended "Lean guide" but is heavily out of date
  (`import Logos`, `Formula.atom "p"` with a String, camelCase `modusPonens`, `DerivationTree`
  without the `FrameClass` parameter, wrong completeness theorem names). `quickstart.md` is
  partly out of date (`.future`/`.past`). `LEAN_STYLE_GUIDE.md` is current apart from its
  Namespaces example. `tactic-reference.md` is current. Reuse the framing only; never copy the
  snippets verbatim.
- `/home/benjamin/Projects/Logos/Verification/` holds no Lean primer, and `LogosManual.typ`'s
  `sec-lean-implementation` is only a pointer. Neither is revisited.
- Conventions (report §2-3): use the `#leansrc(module, name)` helper plus a bare fenced block
  with no `lean` tag (as in `p2-frame-classes.typ`). Write inline identifiers in single
  backticks. Never cite `file:line`. Take every count from `typst/generated/status.typ`
  bindings, never type it by hand. Every single-line backtick span must resolve under
  `scripts/typst-sync-check.sh` Check 1 or be whitelisted. Check 1's regex is
  `` `([^`\n]+)` ``, so multi-line fenced blocks are not scanned, but inline spans such as
  `` `lake build` `` or `` `#check` `` are.
- Open item resolved during planning: a Prop-valued counterpart exists. `Derivable fc G p :=
  Nonempty (DerivationTree fc G p)` lives in `FormalSystem/ProofSystem/Derivable.lean` with
  notation `G |-![fc] p`. This gives the Type-vs-Prop section its contrast pair.

### Decisions (planning-phase calls on the report's open items)

- **Ordering**: include `ax-lean-appendix.typ` before `ax-machine-appendix.typ`. The machine
  appendix assumes the reader knows what a Lean declaration is.
- **Label**: `<lean-appendix>`, matching the `<machine-appendix>` style.
- **External references**: use plain `#link(...)` to the Lean 4 docs, Theorem Proving in
  Lean 4, and Mathlib docs. Add no `bibliography.bib` entry.
- **Snippet verification record**: new didactic snippets go in one scratch file at
  `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean`. It is compiled
  with `lake env lean` from the repo root. It is not added to `Tests/` or `FormalSystem/`, so
  the Lean library surface is unchanged. Any snippet that is later edited must be re-run
  through this file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consulted (no roadmap_path in dispatch).

## Goals & Non-Goals

**Goals**:
- A self-contained Lean primer covering the nine required topics: what Lean is; types vs.
  Props and dependent types; propositions-as-types and proof terms; inductive types (with
  `Formula` and `DerivationTree` as running examples); structures and classes; tactic vs. term
  proofs; Mathlib conventions; lake and project layout; reading `FormalSystem/` source.
- Every Lean snippet compiles against `leanprover/lean4:v4.33.0-rc1` / Mathlib `v4.33.0-rc1`
  and cites real, live (non-Boneyard) declarations.
- `typst compile` and `scripts/typst-sync-check.sh` both pass. `typst/SYNC-MAP.md` gets a
  dated entry.

**Non-Goals**:
- Fixing the out-of-date `docs/user-guide/*.md` seed docs. This could become a follow-up task,
  but it is out of scope here.
- Any change to Lean library source, or adding a Lean test file.
- A general Lean 4 textbook. The primer covers only what is needed to read `FormalSystem/`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Out-of-date seed snippets leak into the book | H | M | Phase 2 builds the snippet corpus from live source and the scratch compile. Prose phases may use only Phase 2's verified snippets |
| Inline backtick spans (`lake build`, `#check`, `sorry`, tactic keywords) fail Check 1 | M | H | Phase 6 runs sync-check and adds whitelist entries under the existing categories. Prefer spans that literally occur in Lean source |
| A hand-typed axiom/rule count drifts | M | L | Import `generated/status.typ` bindings (`axiom-count`, `rule-count`, `sorry-total-excl-boneyard`) the same way the machine appendix does |
| `#leansrc` excerpt drifts from source formatting | M | M | Copy excerpts byte-for-byte from source during Phase 2 and re-diff them in Phase 6 |
| `apply_axiom` short names (MT/M4/...) listed in the seed docs are out of date | L | M | Phase 2 compiles each tactic example. Drop any name that does not elaborate |
| Appendix grows too long | L | M | Target about 500-800 typst lines. Link to the machine appendix and `tactic-reference.md`-style content instead of duplicating it |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files (typst
wiring vs. the specs scratch Lean file). Phases 3-5 all edit the same `.typ` file, so they are
serialized.

### Phase 1: Skeleton file and book wiring [COMPLETED]

**Goal**: Create the appendix file with its header, heading, label, and nine section stubs.
Wire it into the book and the introduction. The book must still compile.

**Tasks**:
- [x] Create `typst/chapters/ax-lean-appendix.typ` with a header comment block like the one in
      `ax-machine-appendix.typ`. Add `#import "../template.typ": *`, plus an
      `#import "../generated/status.typ": ...` for the count bindings needed later. Add
      `#pagebreak()` and `#heading(numbering: none)[Appendix: Reading the Lean Formalization] <lean-appendix>`
- [x] Add nine `==` section stubs (one per topic, in the order in Goals), each with a label
      (e.g. `<lean-appendix-inductive>`) for internal cross-references
- [x] Add `#include "chapters/ax-lean-appendix.typ"` between the `06-notes.typ` and
      `ax-machine-appendix.typ` includes in `typst/BimodalReference.typ`
- [x] In `chapters/00-introduction.typ`: add a clause for `@lean-appendix` to the Outline
      back-matter sentence, and a one-line pointer in the "How to Read This Book" closing
      sentence for readers who want to go from a cited identifier to its source
- [x] Add the new file to `typst/chapters/README.md`'s file listing if it has one

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - new
- `typst/BimodalReference.typ` - add include
- `typst/chapters/00-introduction.typ` - two cross-reference edits
- `typst/chapters/README.md` - list new file (if applicable)

**Verification**:
- `cd typst && typst compile BimodalReference.typ build/BimodalReference.pdf` succeeds, and
  `@lean-appendix` resolves

---

### Phase 2: Verified snippet corpus [COMPLETED]

**Goal**: Compile every didactic Lean example and collect every `#leansrc` excerpt before any
prose is written, so the prose phases only ever use verified material.

**Tasks**:
- [x] Create `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean` with
      `import FormalSystem`, `open FormalSystem.Syntax FormalSystem.ProofSystem`, and one
      commented block per appendix section:
  - `#check` examples: `Formula`, `DerivationTree`, `Derivable`, `FrameClass`, `Formula.atomS`
  - formula construction via `Formula.atomS "p"`, including `.box`, `.imp`, `.always`, `.sometimes`
  - a Type-vs-Prop pair: a `DerivationTree` value, and the `Derivable` fact obtained from it
    via `⟨d⟩`
  - a term-mode proof of `⊢ □p → p` using `DerivationTree.axiom` with `Axiom.modal_t`, and an
    example that applies `DerivationTree.modus_ponens`
  - the same kind of result proved in tactic mode, using at least one of `modal_search` or
    `apply_axiom`, whichever elaborates. Use `tactic-reference.md` as the guide
  - a small structure/class illustration grounded in live code: derived instances on `Formula`
    (`DecidableEq`), and `inferInstance` checks
- [x] Run `lake env lean specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean`
      from the repo root (or `lean_run_code`). Iterate until there are zero errors and no
      `sorry`
- [x] Collect byte-exact excerpts, with their module paths, for `#leansrc` blocks: `inductive
      Formula` (`Syntax/Formula.lean`), `inductive DerivationTree` plus its notation
      (`ProofSystem/Derivation.lean`), `def Derivable` (`ProofSystem/Derivable.lean`),
      `FrameClass`, one `Axiom` constructor such as `modal_t`, one semantics structure such as
      `TaskFrame` (compare with `FormalFoundations.typ`'s existing `leansrc` calls), and the
      top-level `soundness` / `completeness` signatures (`Metalogic/Soundness.lean`,
      `Metalogic/BXCanonical/Completeness.lean`). Save them in a scratch notes section of the
      same file as comments
- [x] Record the `lakefile.toml` / `lean-toolchain` facts (package `BimodalLogic`, library
      `FormalSystem`, test library `BimodalTest`, Mathlib tag) straight from the files

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: about 8-10 `#leansrc` excerpts and about 6-8 compiled didactic snippets.
Confirm by counting the blocks in the finished scratch file.

**Files to modify**:
- `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean` - new (verification record only)

**Verification**:
- `lake env lean` on the scratch file exits 0 with no `sorry` warnings
- Each collected excerpt matches its source file text (`grep -F` on the first line of each)

---

### Phase 3: Sections 1-4 (foundations and inductive types) [COMPLETED]

**Goal**: Write sections "What Lean Is", "Types, Props, and Dependent Types",
"Propositions as Types and Proof Terms", and "Inductive Types: `Formula` and `DerivationTree`".

**Tasks**:
- [x] What Lean is: a dependently typed functional language and proof assistant, the kernel
      as trust anchor, Mathlib, and why the book pairs its claims with Lean identifiers
- [x] Types vs. Props: universes, `Type` vs. `Prop`, dependent types (`DerivationTree fc Γ φ`
      depends on values). Use the `DerivationTree` / `Derivable` contrast from Phase 2, and
      explain proof irrelevance and why `DerivationTree` lives in `Type` (depth, structural
      recursion)
- [x] Propositions-as-types: the term-mode `⊢ □p → p` example and modus-ponens composition
      from Phase 2. Map the reading "a term of type φ is a proof of φ" onto both the Lean
      meta-level (`Prop`) and the object-level (`DerivationTree`)
- [x] Inductive types: `#leansrc` of `Formula` (six primitive constructors) and
      `DerivationTree`, with constructors spelled as in source (`modus_ponens`,
      `temporal_necessitation`, ...). Show derived operators (`always`, `sometimes`) as `def`s
      over the primitives, and cross-reference `@sec:` labels in the syntax and proof-theory
      chapters. State the rule count via `#rule-count`, not typed digits

**Timing**: 1.75 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - fill sections 1-4

**Verification**:
- `typst compile` succeeds
- Every Lean block in these sections is either a Phase 2 `#leansrc` excerpt or a Phase 2
  compiled snippet (spot-check against the scratch file)

---

### Phase 4: Sections 5-8 (structures, tactics, conventions, lake) [COMPLETED]

**Goal**: Write "Structures and Classes", "Tactic Proofs vs. Term Proofs", "Mathlib
Conventions", and "Lake and Project Layout".

**Tasks**:
- [x] Structures and classes: a `#leansrc` of a semantics structure (e.g. `TaskFrame`) with
      field reading, `deriving` clauses on `Formula`, and typeclass resolution
      (`DecidableEq`, `inferInstance`). Keep the explanation small and grounded in Phase 2
      output
- [x] Tactics vs. terms: the Phase 2 tactic-mode proof beside the term-mode proof, and a short
      reading guide for `by` blocks (`intro`, `exact`, `apply`, `simp`, and the project's
      `modal_search` / `apply_axiom`), with a pointer to `@sec:` for the proof-automation
      chapter instead of duplicating it
- [x] Mathlib conventions: naming rules from `LEAN_STYLE_GUIDE.md` (casing split by result
      type, snake_case theorems, dot notation, namespaces `FormalSystem.*` — not the guide's
      out-of-date `Logos.*` example), `open`, `variable`, and docstrings
- [x] Lake: `lean-toolchain`, `lakefile.toml` (package `BimodalLogic`, library `FormalSystem`,
      test library `BimodalTest`, Mathlib pin), `lake build`, `lake env lean FILE`,
      `import FormalSystem`, a top-level directory tour at the project level. External
      `#link`s to the Lean 4 docs, Theorem Proving in Lean 4, and Mathlib docs

**Timing**: 1.75 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - fill sections 5-8

**Verification**:
- `typst compile` succeeds
- The Lean version and Mathlib tag stated in prose match `lean-toolchain` and `lakefile.toml`

**Deviation (structures example)**: the `#leansrc` semantics-structure example uses
`FormalSystem.Semantics.TaskModel` (a genuine one-field structure: `valuation : F.WorldState →
Atom → Prop`) rather than `TaskFrame` itself. `TaskFrame` is a two-field fibration
(`Duration`/`toFibre`) whose actual world-state/task-relation content lives several layers down
in `FrameOver`, too large and indirect to excerpt legibly in a "keep the explanation small"
section; `TaskModel` gives the same "structure parameterized by a value" dependent-type point
(matching @lean-appendix-types-props's discussion) in two lines. The plan's "(e.g. `TaskFrame`)"
phrasing already flagged this as an example, not a fixed requirement.

**Deviation (apply_axiom)**: `docs/reference/tactic-reference.md`'s `apply_axiom MT φ` argument
spelling does not elaborate (confirmed by direct compile attempt) — the live macro
(`FormalSystem/Automation/Tactics/UserTactics.lean`) takes no arguments and expands to `apply
DerivationTree.axiom; refine ?_`, leaving `h`/`h_fc` side goals open rather than searching for
the matching axiom itself, contrary to its own docstring. The appendix's tactic example uses the
verified zero-argument form followed by `case h => exact Axiom.modal_t _` /
`case h_fc => trivial`, and states this discrepancy explicitly rather than silently using the
stale doc spelling. See `typst/SYNC-MAP.md`'s 2026-09-17 "Lean 4 Appendix" entry for the full
record.

---

### Phase 5: Section 9 (reading `FormalSystem/` source) [COMPLETED]

**Goal**: The capstone section. Teach the reader to go from a formal claim in the book to its
declaration in source, and to judge how far to trust it.

**Tasks**:
- [x] Directory tour of `FormalSystem/` (`ForMathlib/`, `Syntax/`, `ProofSystem/`,
      `Semantics/`, `Metalogic/`, `Theorems/`, `Automation/`, `Examples/`), each tied to the
      chapter that cites it (`@sec:` refs). Note that `Boneyard/` is archived, not live
- [x] Worked walkthroughs of two claims: (a) soundness — the `soundness` signature via
      `#leansrc`, how to read hypotheses and conclusion, and the `FrameClass` variants;
      (b) completeness — `completeness` in `FormalSystem.Metalogic.BXCanonical`, and how it
      combines with soundness
- [x] Trust-reading practice: `#print axioms`, the meaning of `sorry` and how the book reports
      it (`#sorry-total-excl-boneyard`, never a typed digit), the no-`file:line` citation
      convention (cite by name, optionally by file), and using `#check` / go-to-definition
      with the lean-lsp editor tooling
- [x] A closing pointer to `@machine-appendix` for the full index of declarations

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `typst/chapters/ax-lean-appendix.typ` - fill section 9

**Verification**:
- `typst compile` succeeds
- Each walkthrough's `#leansrc` excerpt matches source (from Phase 2's corpus)

---

### Phase 6: Sync-check, whitelist, SYNC-MAP, and final gate [COMPLETED]

**Goal**: Pass every mechanical check and record the change in `SYNC-MAP.md`.

**Tasks**:
- [x] Run `scripts/typst-sync-check.sh`. For each Check 1 failure caused by the new file,
      either rename the span to a live identifier or add a whitelist entry to
      `typst/sync-check-whitelist.txt` under the matching category comment (tool names, Lean
      keywords/commands, schematic signatures)
- [x] Confirm no hand-typed counts: grep the new file for bare digits near
      "axiom" / "rule" / "sorry"
- [x] Confirm no `file:line` citations (grep `\.lean:[0-9]`)
- [x] Re-diff every `#leansrc` excerpt against current source. Re-run
      `lake env lean` on the scratch file
- [x] Run `bash .claude/scripts/typst-element-lint.sh --verbose typst/chapters/ax-lean-appendix.typ`
      and fix blocking placement findings
- [x] Append a dated section to `typst/SYNC-MAP.md` (in the style of the "2026-09-17 Decision"
      section) recording: the new appendix, the snippet-verification method, the out-of-date
      seed docs not used verbatim, and the new whitelist entries. No task numbers in any
      deliverable file
- [x] Final full compile of `BimodalReference.typ` and a visual skim of the appendix pages in
      the PDF

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `typst/sync-check-whitelist.txt` - new entries as needed
- `typst/SYNC-MAP.md` - dated entry
- `typst/chapters/ax-lean-appendix.typ` - fixes

**Verification**:
- `scripts/typst-sync-check.sh` exits 0 for Check 1 and Check 3. Check 2b (automation module-map
  freshness) fails independently of this task: `ProofSearch/Core.lean`,
  `ProofSearch/Strategies.lean`, `SuccessPatterns.lean`, `Tactics/Search.lean` had already
  drifted against `generated/automation-module-map.typ` before this task's session started (`git
  status`/`git diff` show no working-tree changes to those files here), and regenerating that
  map is outside this task's file scope (see `typst/SYNC-MAP.md`'s dated entry). Full-script
  exit code is therefore 1, not 0, for a reason unrelated to the new appendix.
- `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 with no warnings
  from the new file
- The scratch file compiles cleanly
- `check-task-references.sh` (if present) reports no hits in the changed typst files -- the
  script's four tree roots do not include `typst/`, so it does not apply here; a manual grep for
  task-number patterns across every changed/new typst file found none

## Testing & Validation

- [x] `typst compile` of `BimodalReference.typ` succeeds
- [x] `scripts/typst-sync-check.sh` Check 1 and Check 3 pass; Check 2b fails for a reason
      unrelated to this task (see Phase 6 Verification above and `typst/SYNC-MAP.md`)
- [x] Scratch snippet file compiles with `lake env lean`, with no errors and no `sorry`
- [x] All nine required topics present as sections, and the introduction cross-references
      resolve
- [x] No `file:line` citations, no hand-typed counts, and no `Boneyard/`-only identifiers cited
      as live

## Artifacts & Outputs

- `typst/chapters/ax-lean-appendix.typ` (new)
- Edits: `typst/BimodalReference.typ`, `typst/chapters/00-introduction.typ`,
  `typst/sync-check-whitelist.txt`, `typst/SYNC-MAP.md`, possibly `typst/chapters/README.md`
- `specs/620_lean_appendix_bimodal_reference/scratch/appendix_snippets.lean` (verification record)
- Implementation summary under `specs/620_lean_appendix_bimodal_reference/summaries/`

## Rollback/Contingency

All changes are additive typst edits plus one include line. To roll back, `git revert` the
phase commits, or remove the `#include` line to hide the appendix while keeping the file. If a
snippet cannot be made to compile (for example, a tactic name no longer elaborates), drop it
and fall back to a `#leansrc` excerpt of a real declaration, which is always available.
