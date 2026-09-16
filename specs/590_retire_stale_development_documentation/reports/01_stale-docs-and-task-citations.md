# Sweep Evidence Report: Task #590

**Task**: 590 — Retire or rewrite the stale development docs and clear the 142 task-number citations under `docs/`
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Medium. Most of the volume is in one file that is probably deleted rather than edited.
**Dependencies**: None. Feeds **583**, which can flip `ENFORCE_C9_DOCS=1` once this lands.
**Sources/Inputs**:
- `bash scripts/check-module-invariants.sh` C9D output
- `docs/development/PHASED_IMPLEMENTATION.md` (548 lines), `docs/development/LATEX_STANDARDS.md`
- `.claude/rules/no-task-references-in-deliverables.md`, `.claude/context/standards/task-reference-exemptions.md`
- `specs/reviews/review-2026-09-16.md`, Finding M3

## Executive Summary

- **C9D reports 142 task-number citations under `docs/`.** It is computed on every run but is
  soft by default, with the harness noting: *"set `ENFORCE_C9_DOCS=1` to make this
  exit-code-affecting once the citations are cleared."* Clearing them is what makes that flag
  flippable, which is why this task feeds the CI task.
- **One file holds 100 of the 142**, and that file is obsolete on its own terms.
- **A second file documents a repository layout that does not exist.**

## C9D breakdown

| File | Citations |
|---|---|
| `docs/development/PHASED_IMPLEMENTATION.md` | 100 |
| `docs/training/PIPELINE.md` | 11 |
| `docs/research/NONCOMPUTABLE.md` | 5 |
| `docs/project-info/MAINTENANCE.md` | 5 |
| `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md` | 5 |
| **Total** | **142** |

Note `C9` (the hard-gated sibling, covering `FormalSystem/`, `lakefile.lean`, `README.md` and
`scripts/`) is green — zero citations. So `docs/` is the only remaining pocket, and it is why the
rule `.claude/rules/no-task-references-in-deliverables.md` exists: *"Task numbers are renumbered
during vault operations and are meaningless to a future reader. Cite durable anchors instead."*
This repository has performed a vault operation (`vault_count: 1` in `specs/state.json`), so the
numbers in these files are not merely opaque — some are actively wrong.

## `docs/development/PHASED_IMPLEMENTATION.md` (548 lines, 100 citations)

Its own opening states its purpose: *"a systematic implementation strategy for completing Layer 0
(Core TM) of Logos, organizing tasks into execution waves."* Its scope section lists:

> **Total Effort**: Sequential execution: 93–143 hours · Parallel execution: 70–95 hours · **Time
> Savings**: 25–32% with proper task ordering
>
> **Layer 0 Completion Goals**: Fix CI reliability (Task 1) · Complete propositional axioms
> (Task 2) · Finish Archive examples (Task 3) · Complete soundness proofs (Task 5) · Complete
> perpetuity proofs (Task 6) · Implement core automation (Task 7)

Every one of those is long since done — soundness, completeness at four frame classes, strong
completeness at two, a decision procedure, and the automation layer all exist and are
axiom-pinned. The document is a historical artefact of the project's first phase.

**Recommended disposition: delete**, with whatever remains durable folded elsewhere. It is
referenced from `docs/README.md`, `docs/development/README.md` and
`docs/development/MODULE_INVARIANTS.md` — all three need updating in the same change or C13
(relative markdown links) will fail. Check `MODULE_INVARIANTS.md`'s reference specifically: if it
cites this file for something structural rather than historical, that content needs a home.

If deletion is judged too strong, the alternative is to move it to a clearly-marked historical
section and strip the task numbers; but a 548-line roadmap whose goals are all met is not a
document anyone will read, and keeping it costs the 100 citations that block `ENFORCE_C9_DOCS`.

## `docs/development/LATEX_STANDARDS.md`

Documents a multi-theory layout this repository does not have:

```
{Theory}/latex/
{Theory}/latex/assets   {Theory}/latex/subfiles   {Theory}/latex/bib
# {Theory}/latex/latexmkrc
do '../../latex/latexmkrc';
\usepackage{../../latex/formatting}
```

There is no `{Theory}/` tier here — `latex/` sits at the repository root with `assets/` and
`subfiles/` directly under it. The document reads as inherited boilerplate from a multi-theory
parent project.

It also now describes the *frozen* half of the documentation: the sweep repointed `README.md`'s
reference-manual link from `latex/BimodalReference.pdf` to the maintained Typst source, and
`latex/` is explicitly not kept in sync. So this task should decide what `latex/` is for at all:
if it is a frozen historical edition, `LATEX_STANDARDS.md` should say so in two paragraphs rather
than prescribe a build layout for a tree nobody builds; if `latex/` is genuinely dead, it can be
archived and the standards doc deleted with it.

Referenced from `docs/README.md` and `docs/development/README.md`; `docs/development/CONTRIBUTING.md:143`
also lists `latex/` as "LaTeX resources and templates".

## The other three files (21 citations)

`docs/training/PIPELINE.md` (11), `docs/research/NONCOMPUTABLE.md` (5),
`docs/project-info/MAINTENANCE.md` (5), `docs/architecture/ADR-004-…` (5). These are live
documents; the fix is per-citation, replacing each task number with a durable anchor — a filename,
a section heading, a decision-record name, or a verified fact — per
`.claude/rules/no-task-references-in-deliverables.md`.

**Read `.claude/context/standards/task-reference-exemptions.md` before starting.** It defines a
7-category exemption taxonomy and a `task-ref-ok` marker convention; an ADR recording a historical
decision may legitimately name the task that produced it. The goal is zero *unmarked* citations,
not zero mentions of history.

## Recommended approach

1. Decide `PHASED_IMPLEMENTATION.md`'s disposition first — it is 70% of the volume and the answer
   determines whether this is a small task or a large one.
2. Decide what `latex/` is, then write `LATEX_STANDARDS.md` to match (or delete both).
3. De-cite the remaining 21 individually, applying the exemption taxonomy where it genuinely
   applies rather than rewriting history.
4. Update every referring index (`docs/README.md`, `docs/development/README.md`,
   `docs/development/MODULE_INVARIANTS.md`, `docs/development/CONTRIBUTING.md`) in the same change.
5. Hand `ENFORCE_C9_DOCS=1` to task 583 as a ready-to-flip switch, and say so in the summary.

## Verification

- `C9D` reports 0 citations, or only `task-ref-ok`-marked ones.
- `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh --no-build` exits 0.
- C5 (module-shaped paths in markdown), C12 (slash-shaped source paths) and C13 (relative markdown
  links) all still pass — deleting a referenced file breaks C13 if the referrers are missed.
- `bash scripts/readme-lint.sh` still PASS.
