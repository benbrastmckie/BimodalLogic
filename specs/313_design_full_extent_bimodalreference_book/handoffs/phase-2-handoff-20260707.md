# Phase 2 Handoff: Scripted Status Counts Generator

**Status**: COMPLETED
**Files touched**: `scripts/typst-status-counts.sh` (new), `Theories/Bimodal/typst/generated/status.typ` (new, generated)

## What was done

- Wrote `scripts/typst-status-counts.sh`, reproducing the SYNC-MAP.md Phase 1 methodology:
  axiom-constructor count via the `inductive Axiom` awk pattern, `DerivationTree` rule count,
  and comment-stripped `\bsorry\b` counts per `Metalogic/` subtree (Algebraic, BXCanonical,
  Bundle, WeakCanonical split with/without the nested `Kamp/Boneyard/` archive, and
  everything else).
- Script emits JSON to stdout unconditionally (also with a `--json`-only mode for
  `typst-sync-check.sh` in Phase 4) and writes `typst/generated/status.typ` defining
  `#let sorry-total`, `#let sorry-total-excl-boneyard`, `#let sorry-table`,
  `#let axiom-count`, `#let rule-count`, `#let stamp-commit`, `#let stamp-date`.
- Verified: `axiom_count=42`, `rule_count=7`, `sorry_total=43` (41 excl. Boneyard),
  per-subtree breakdown (Algebraic 3 / BXCanonical 4 / Bundle 12 / WeakCanonical 24) —
  all match SYNC-MAP.md's stamped `a883361bf` derivation exactly, zero delta.
- `typst/generated/status.typ` is a committed artifact (per the plan's explicit decision:
  "commit the generated file — it is the stamped artifact"); no new `.gitignore` entry
  needed since it doesn't match the existing `build/`/`*.pdf` patterns.

## Deviation from plan

- None. The primary/secondary sense of "43 vs 41" was initially inverted in a first draft
  (script defaulted to excl-Boneyard as primary); corrected during self-check so that
  `sorry-total` = 43 (incl. Boneyard) matches the number already cited in chapter prose
  (`06-notes.typ`, `04-metalogic.typ`), with `sorry-total-excl-boneyard` as the secondary
  field. Caught before commit; not a plan deviation, an internal drafting correction.

## Verification

`bash scripts/typst-status-counts.sh` runs green and matches SYNC-MAP.md's independent
derivation exactly. Generated `status.typ` compiles standalone (scratch import test) and
the full `typst compile BimodalReference.typ build/BimodalReference.pdf` still exits 0.
