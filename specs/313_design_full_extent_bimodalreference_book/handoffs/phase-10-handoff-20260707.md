# Phase 10 Handoff: Part IV Chapter — The BMLogic Dataset Pipeline

**Status**: COMPLETED
**Files touched**: `chapters/p4-dataset-pipeline.typ` (filled from Phase-5 shell), `docs/training/PIPELINE.md` (pointerized), `sync-check-whitelist.txt`

## What was done

- Wrote the chapter as the canonical narrative home (move-and-cite from `docs/training/
  PIPELINE.md`): dual-signal architecture (proof traces to policy network, countermodels to
  value network, quoted verbatim with citation), the pipeline flow and module map (with the
  6-vs-7-module count discrepancy flagged rather than silently resolved), the two `lake exe`
  executables, the artifact-only BimodalHarness integration, the full Tier-1 feasibility gate
  table (3 of 6 hard criteria FAILED, including the 3.2%-valid provability-ratio shortfall),
  and the Tier-2 theorem-mining/biased-enumeration/`EnrichedCountermodel`-wiring response
  (marked ◇, code exists but not wired).
- Reduced `docs/training/PIPELINE.md` (797 -> 703 lines) by replacing its Overview,
  Architecture-narrative, Feasibility-Gate-Results, and Recommended-Next-Steps prose with
  short pointers to the book chapter, while *keeping* the genuinely operational reference
  material intact: the Pipeline Flow ASCII diagram, the full Module Reference (7 modules'
  API tables), Executable Targets (CLI flags/examples), Python Tensor Converter, Dataset
  Schemas, BimodalHarness Integration (sync mechanism, dataclass correspondence, schema
  contract), and the Planned Tasks / Related Tasks tables.

## Deviations from plan

- The plan's "~50 line" estimate for the `PIPELINE.md` delta undercounted how much of the
  file is genuine operational reference (CLI flags, schemas, dataclass mappings) rather than
  narrative -- the net reduction is ~94 lines, smaller than a full narrative-strip would have
  produced, because the postmortem "no duplicated architecture prose" rule targets prose
  narrative specifically, not operational tables the book chapter does not reproduce.
- Flagged (not silently resolved) `docs/training/PIPELINE.md`'s own internal inconsistency:
  its Overview claims "6 Lean modules" while its Module Reference section documents 7.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 447 backtick candidates, up from 417).
`docs/training/PIPELINE.md` still serves `lake exe dataset_generator`/`dataset_validator`
users: its Executable Targets, Python Tensor Converter, and Dataset Schemas sections are
unchanged.
