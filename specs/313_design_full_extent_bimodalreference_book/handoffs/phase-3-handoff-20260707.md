# Phase 3 Handoff: SYNC-MAP Status-Legend Extension and Per-Chapter Banners

**Status**: COMPLETED
**Files touched**: `Theories/Bimodal/typst/SYNC-MAP.md`, `chapters/00-introduction.typ`,
`chapters/01-syntax.typ`, `chapters/02-semantics.typ`, `chapters/03-proof-theory.typ`,
`chapters/04-metalogic.typ`, `chapters/05-theorems.typ`, `chapters/06-notes.typ`,
`scripts/typst-status-counts.sh` (amended)

## What was done

- Added a "Sync-Class Legend" section to `SYNC-MAP.md`: the four classes (✓/⧖/○/◇),
  enforcement rules (no ✓ claim in ○/◇ chapters; no unresolvable backticked name; per-claim
  inline overrides allowed), and a per-chapter assignment table (00 mixed, 01/02/03/05 ✓,
  04/06 ⧖).
- Added `#sync-banner(...)` to all seven chapters 00-06, each citing its dominant Lean/paper
  source and SYNC-MAP as authority.
- Replaced hand-copied count digits with `generated/status.typ` imports in all seven
  chapters (not just 04/06 as minimally required — the phase's territory line explicitly
  scoped "banner block + count-import edits" across 00-06, so 00's project-structure line,
  01/03's axiom/rule counts, and 05's sorry-free claim were also import-backed for
  consistency and to reduce Phase 12 audit rework): `axiom-count`, `rule-count`,
  `sorry-total`, `sorry-total-excl-boneyard`, `stamp-commit`, `stamp-date`, and the
  `sorry-table` (rendered via a typst `map`/`flatten` over the generated array in
  `04-metalogic.typ`'s sorry-inventory figure).
- Recorded in `SYNC-MAP.md` that all banners have landed and counts are import-backed —
  input to Phase 4's Checks 2 and 4.

## Deviation from plan

- **Extended `scripts/typst-status-counts.sh`** (committed in Phase 2) with a new
  frame-class breakdown (`base-count`/`dense-only-count`/`discrete-only-count`, derived from
  `Axiom.minFrameClass`'s explicit `.Dense`/`.Discrete` match arms) to eliminate a
  hand-copied "37 axioms of layers 1-5" digit found in `03-proof-theory.typ` during this
  phase's cleanup sweep. This field is exactly what Phase 7's plan text calls "Base 37 /
  Discrete 3 / Dense 2 from generated counts" — extending the generator now (while the Lean
  source context was already loaded) avoids re-deriving it in Phase 7. Verified: 37/2/3,
  matching SYNC-MAP's independently stated breakdown exactly.
- This amendment technically falls outside Phase 3's stated territory (which lists
  `SYNC-MAP.md` and `chapters/00-06*.typ`, not the script) but is a strict superset addition
  to Phase 2's already-committed generator with no behavior change to existing fields;
  flagged here per the deviation-annotation protocol rather than silently folded in.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. Grep sweep
`grep -nE '[0-9]+ (genuine )?sorr|[0-9]+ axiom' chapters/*.typ` shows zero literal
sorry/axiom-count digits remaining in chapter prose (one false-positive match on `Axiom.modal_4`/`MB` axiom *names*, not a count).
