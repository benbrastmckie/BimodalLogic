# Implementation Summary: Task #622

- **Task**: 622 - Align typst frame-class subscripts (z/d/r) and BX_r with the paper
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T00:00:00Z
- **Completed**: 2026-09-18T19:25:00Z
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_frame-subscript-alignment.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`typst/FormalFoundations.typ` and `typst/chapters/p2-decidability-practice.typ` used the paper's
retired `f`/`d`/`c` frame-class subscripts. This implementation moved them to the paper's current
`z`/`d`/`r` names (`def:BX-z`, `def:BX-d`, `def:BX-r`), fixed a swapped `#leansrc` citation pair
between the section 2 Soundness theorem and section 5 Algebraic soundness proposition, and
rewrote the "Naming provenance" remark. All work is typst prose; no Lean changes were needed.

## What Changed

- `typst/FormalFoundations.typ` — Renamed `"BX"_f`/`op("TM")_f` to `"BX"_z`/`op("TM")_z`
  (pure relabel) at every non-minus site: the `BX_z` definition block, the TM-level "Similarly"
  sentence, the summary table, the "paper attributes them to" sentence, the mixed remark at
  ~1053-1054, the TM-algebra definition, the Algebraic soundness proposition, the Per-class
  remark, and the representation remark. Redefined `"BX"_c`/`op("TM")_c` as `"BX"_r`/`op("TM")_r`,
  an extension of `"BX"_d`/`op("TM")_d` (not of bare BX) with title *Dense and Complete
  Burgess--Xu Tense Logic*; updated the TM-algebra definition ("a `TM_r`-algebra is a
  `TM_d`-algebra that additionally satisfies Prior-U and Sep"), narrowed the Algebraic soundness
  proposition's class from `Dur in {ZZ, RR}` to "`Dur` is dense and Dedekind complete (`Dur =
  RR`)" to match Lean's `soundness_rtime`, and relabeled the Per-class and representation remarks
  (already stated `RR`-only content, so no semantic change there). Dropped the CO-alone footnote
  ("Whether CO alone axiomatizes the same logic... is open") — the conjecture only ever lived in
  a retired, commented-out LaTeX block and the live `def:BX-r` carries no such footnote. Swapped
  the section 2 "Soundness" theorem's four `#leansrc` lines to
  `Metalogic.Conservativity.MinusLanguageSoundness` (`minus_soundness*`, the TM⁻-level family)
  and the section 5 "Algebraic soundness" proposition's four `#leansrc` lines to
  `Metalogic.Soundness` (`soundness*`, the TM-level family) — the two were previously swapped.
  Rewrote the "Naming provenance" remark as a short historical note describing the BL⁺→BL merge,
  the `f/d/c → z/d/r` rename with anchors, and that `c → r` was a redefinition (not a relabel)
  narrowing the class to R-time; removed the stale "still uses the old subscripts" and "not
  transcribed here" sentences; kept the one presentational difference (live definitions cite the
  Extensions section rather than displaying axioms) since it is still current per
  `docs/reference/paper-definitions-of-record.md`.
- `typst/chapters/p2-decidability-practice.typ` — Line 27: `op("TM")_c` -> `op("TM")_r` and
  `op("TM")_f` -> `op("TM")_z` in the finite-model-property counterexample sentence; wording
  ("sound over a class containing a dense or `RR` member", `ZZ times_lex ZZ` witness) still holds
  unchanged under the narrower `TM_r`.

## Decisions

- Left the summary-table caption ("The three frame-class extensions of `op("TM")`") unchanged:
  it remains literally true (all three are still, transitively, extensions of TM), and the
  immediately preceding "Similarly" sentence already states the `TM_r`-extends-`TM_d` dependency
  explicitly.
- Left line 578's Hölder-theorem background sentence ("The complete class is therefore exactly
  `{ZZ, RR}`... and the dense-and-complete class exactly `RR`") unchanged. It backs the later
  TM⁻ discussion (`TM⁻_c` fails over `{ZZ, RR}`, out of scope) and the RTime theorem (`RR` only,
  already correct), not a claim attached to the renamed `TM_r`/`BX_r`.
- Left the "for the dense and complete extensions it is open" phrase (conservativity remark,
  ~line 753) unchanged: it is a generic English descriptor of the three non-minus extensions'
  conservativity-over-TM⁻ status, not a formal reference to the old `TM_c` class semantics, and
  the substance (open, no known counterexample) is unaffected by narrowing `TM_r`'s class from
  `{ZZ, RR}` to `RR`.
- Confirmed the swapped citation targets and the `soundness_rtime` semantics directly against
  Lean source (`FormalSystem/Metalogic/Soundness.lean`,
  `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`) rather than relying on the
  plan's description alone.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: N/A (no Lean changes)
- `typst compile typst/FormalFoundations.typ`: Success
- `typst compile typst/BimodalReference.typ`: Success (compiles the book, including the
  decidability chapter via `#include`)
- `bash scripts/typst-sync-check.sh`: Success (all 3 checks green, including `#leansrc` name
  resolution for the swapped citation targets)
- `bash scripts/check-paper-definitions.sh`: Success (pass, not neutral-skip — reported a
  live-tree checksum notice for `possible_worlds.tex` with all 42 recorded definitions
  unchanged; an upstream observation unrelated to this task's edits)
- Task-number-reference check: manual grep for task-number patterns in both edited files found
  none (`.claude/scripts/check-task-references.sh` does not cover the `typst/` tree — its
  `TREE_ROOTS` are `agent-system/extensions`, `.opencode`, `lua`, `.memory`)
- Final sweep: `grep -nE '"BX"_[fc]|op\("TM"\)_[fc]'` across `typst/FormalFoundations.typ`,
  `typst/chapters/*.typ`, `typst/*.typ` returns hits only inside the Naming provenance remark's
  historical mention of the old names
- `op("TM")^-_` token count: 13 at baseline (Phase 1) and unchanged through Phase 3
- Files verified: Yes

## Impacts

- No downstream code or Lean changes; this is a documentation-consistency fix. Readers of
  `FormalFoundations.typ` now see the paper's current `z`/`d`/`r` naming and a correctly-narrowed
  R-time class for `BX_r`/`TM_r`, and the `#leansrc` citations on the section 2/5
  theorem/proposition now point at the correct Lean theorem families.

## Follow-ups

- None.

## References

- Plan: `specs/622_align_typst_frame_subscripts_zdr_and_bx_r/plans/01_frame-subscript-alignment.md`
- Report: `specs/622_align_typst_frame_subscripts_zdr_and_bx_r/reports/01_frame-subscript-alignment.md`
- `docs/reference/paper-definitions-of-record.md`
