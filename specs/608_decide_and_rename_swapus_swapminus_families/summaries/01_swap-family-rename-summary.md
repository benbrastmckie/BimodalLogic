# Implementation Summary: Task #608

- **Task**: 608 - Decide and rename the swapUS / swapMinus / *_swap_valid* families
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T14:20:11Z
- **Completed**: 2026-09-18T14:40:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_swap-family-rename.md, rename-map.tsv, prose-ledger.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Applied the split verdict from report 01: `swapMinus` -> `reflectTime` (on `MinusFormula`) and
`_swap_valid` -> `_reflect_time_valid` were renamed as a map-driven whole-token substitution
(279 occurrences, 27 files), while `swapUS`, `truth_swap`, `MinusFrame.swap` and the serialized
`*_swap` wire tags were kept. Contrast prose was reworded to name `MinusFormula.reflectTime` vs
`Formula.reflectTime`, and the record of paper definitions now states the verdict. Pure rename,
no proof changes.

## What Changed

- `specs/608_.../rename-map.tsv` — map file: 2 rename rows plus the EXCLUSIONS block
- 22 Lean files under `FormalSystem/` (MinusLanguage syntax/semantics, Soundness,
  SoundnessLemmas/FrameClassVariants, Deterministic/Soundness, Independence/CoarsenedModels,
  Conservativity Backward/MinusLanguageSoundness/Plus*/Star*, Plus/StarLanguage Axioms) — identifier rename;
  newly over-100-char lines rewrapped (two signatures split, prose reflowed)
- 5 READMEs — renamed backticked mentions; 5 generated inventory blocks refreshed
  (`check-module-invariants.sh --emit-inventory`, line counts only) incl. root `README.md`
- `Syntax/MinusLanguage/{Derivation,Translation,Formula}.lean`, `Conservativity/Backward.lean`,
  `Semantics/MinusLanguage/{MinusFrame,MinusSchemaValidity}.lean` — contrast prose reworded (see prose-ledger.md)
- `Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean` — `swapUS` docstring states it is
  deliberately distinct from `Formula.reflectTime`
- `docs/reference/paper-definitions-of-record.md` — "Not in the decided set" bullet replaced by
  the per-family verdict with reasons and the adjacent-family follow-up note

## Decisions

- Split verdict per the report's test "does it denote `φ⟨S|U⟩`?"; no deprecation aliases.
- Compound spelling is a pure substring rule (`tr_swapMinus` -> `tr_reflectTime`, camelCase kept).
- In `MinusFrame.lean`, the analogue of the paper's temporal-duality lemma is named in prose, not
  as an anchor citation, so module-invariant check C15 stays green without a new KNOWN-ANCHORS row.

## Plan Deviations

- **Task 1.7** altered: pre-existing long markdown table rows left as-is; only newly-long lines rewrapped.
- **Task 1.8** altered: BimodalTest verified by building the `BimodalTest` library target.
- **Task 2.6** skipped: optional "swap-validity" -> "reflection validity" rewording not taken.
- **Task 3.3** altered: inventory blocks regenerated; `lem:temporal-duality` citation reworded to prose.
- **Task 3.4** altered: residual grep hits only the two intentional old -> new lines in the record.

## Verification

- Build: Success (`lake build` of `FormalSystem`, all 13 `lean_exe` roots and `BimodalTest`)
- Sorry count: 0 (none introduced)
- Vacuous count: 0
- Axiom count: 12 (unchanged); `check-module-invariants.sh` C2/C14 axiom baselines pass
- Tests: Passed (BimodalTest builds); `check-module-invariants.sh`, `check-paper-definitions.sh`,
  `readme-lint.sh`, `typst-sync-check.sh` all pass
- String literals in touched files byte-identical (snapshot diff empty)
- Files verified: Yes

## Impacts

- Downstream references must use `MinusFormula.reflectTime`, `MinusLanguage.tr_reflectTime` and
  the `*_reflect_time_valid*` lemma names; old names no longer exist (no aliases).

## Follow-ups

- Possible follow-up: classify the adjacent `swap` families (`swap_norm`, `*_swap_of_tm*`,
  `cValid` swaps, `starValid_*_swap`) and "swap-validity" prose.

## References

- specs/608_decide_and_rename_swapus_swapminus_families/reports/01_swap-family-rename-decision.md
- specs/608_decide_and_rename_swapus_swapminus_families/plans/01_swap-family-rename.md
- specs/608_decide_and_rename_swapus_swapminus_families/rename-map.tsv
- specs/608_decide_and_rename_swapus_swapminus_families/prose-ledger.md
