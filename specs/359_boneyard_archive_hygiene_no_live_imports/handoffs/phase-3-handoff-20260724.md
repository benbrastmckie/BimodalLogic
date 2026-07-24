# Phase 3 Handoff — Boneyard #exit and Header Normalization

## Immediate Next Action

Phase 4: README reconciliation and final verification gate. First step: recount the TB
inventory (`Theories/Bimodal/Boneyard/README.md`) from the tree — 83 `.lean` files measured
(README claims 67 / ~39,619 lines); recompute both counts per subdirectory.

## Current State

- Phase 3 COMPLETED. Phases done: 1 (cafd4849a), 2 (b901a8be1), 3 (this dispatch).
- All 145 Boneyard `.lean` files (83 TB + 62 KB) now conform: `ARCHIVED (Boneyard) — never
  compiled.` marker as first content line of a module docstring positioned after the import
  block, with exactly one `#exit` immediately after that docstring. 143 files changed; the
  2 files created in Phases 1–2 were already conforming.
- Sorry count: 0 introduced (mechanical pass; no proof content touched).
- Build: `lake build` GREEN (1789 jobs). `completeness_discrete` axiom baseline
  byte-identical (`propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler,
  Quot.sound`), no sorryAx.

## Key Decisions

- Comment-aware census: the report baseline (19/24/40 TB exit-before/after/none) counted
  `import` tokens inside block comments; the fresh comment-aware census measured 14/29/100
  (+2 conforming) across both roots. Work list fixed from the fresh census per the plan.
- Files whose only `import` lines sit inside a docstring (e.g. `DenseChronicle/
  CantorIsoCountermodel.lean` "Old Imports" code fence) and the 8 genuinely no-import files
  were treated as position-0 insertions per the plan's no-imports rule.
- Existing docstrings kept all content; the marker line was prepended inside them. Files
  without a docstring at the insertion point received the minimal report-§(c) header with
  the generic reason line.
- Normalization script preserved at `specs/359_boneyard_archive_hygiene_no_live_imports/boneyard_normalize.py`
  (census / dry-run / apply modes; idempotent — re-running census reports 145/145 CONFORMS).

## Sorry Inventory

Empty — no sorries introduced or inherited (`sorry_inventory: []`).

## References

- Plan: `specs/359_boneyard_archive_hygiene_no_live_imports/plans/01_boneyard-hygiene-plan.md`
  (Phase 4 section for the remaining work; report §(e) for the 5-gate final checklist).
