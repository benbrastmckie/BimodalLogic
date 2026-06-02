# Implementation Plan: Task #260 - Resumable Dataset Generation Pipeline

- **Task**: 260 - Make dataset generation pipeline resumable after interruption
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/260_dataset_generation_resumable_interruption/reports/01_resumable-pipeline-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The dataset generation pipeline (`run_dataset_generation.sh` + `DatasetExport.lean`) currently loses all progress on interruption. The labeling phase already streams records line-by-line via `writeRecordJSONL`, providing a strong foundation for resumability. The core problems are: (1) the file is opened in truncate mode (`.write`), destroying partial output on restart; (2) there is no mechanism to skip already-labeled formulas; and (3) the shell script has no resume detection. This plan adds a `--resume-from N` flag to the Lean executable for conditional append mode and formula skipping, a formula checkpoint file to eliminate non-determinism from `IO.rand` in `generateValidBatch`, and shell-side resume detection with user prompting.

### Research Integration

Key findings from the research report integrated into this plan:
- The labeling phase already streams records immediately via `writeRecordJSONL` -- no architectural change needed for streaming
- Formula enumeration is deterministic for exhaustive/stratified modes but `generateValidBatch` uses `IO.rand`, creating non-determinism -- mitigated by a formula checkpoint file (Strategy 2 from research)
- The `.write` file open mode on line 595 of `DatasetExport.lean` is the primary cause of data loss on restart
- JSONL record sizes are well under PIPE_BUF (4096 bytes), so per-line writes are atomic on POSIX
- Resume is only critical for c9/c11 tiers (30 min to 4 hours); c5/c7 complete in seconds/minutes

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap items are directly advanced by this task. This is an infrastructure improvement for the dataset generation tooling.

## Goals & Non-Goals

**Goals**:
- Add `--resume-from N` CLI flag to `DatasetExport.lean` enabling skip-and-append behavior
- Write a formula checkpoint file after enumeration to enable deterministic resume without re-enumeration non-determinism
- Add shell-side detection of partial output files with interactive resume/restart prompt
- Validate the last line of partial JSONL before resuming to prevent corrupt records
- Preserve existing streaming architecture unchanged

**Non-Goals**:
- Checkpointing during the enumeration phase itself (enumeration is fast relative to labeling)
- Real-time progress metadata file (`.progress`) -- deferred to a future enhancement
- Changing the formula enumeration algorithm or sampling strategy
- Supporting resume across different CLI parameter sets (mismatched params = fresh start)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula checkpoint file introduces serialization bugs | H | L | Use existing `Formula.toSExpr` / parsing; test round-trip on c5 |
| Append mode produces duplicate records at resume boundary | M | L | Shell validates last JSONL line; truncate corrupt trailing line before append |
| `IO.rand` in `generateValidBatch` changes formula ordering across runs | M | M | Formula checkpoint file eliminates re-enumeration entirely on resume |
| Large checkpoint files for c9/c11 (50-100MB) | L | M | Acceptable for multi-hour runs; cleaned up after successful completion |
| Lean compilation time for DatasetExport.lean changes | L | L | Changes isolated to DatasetExport.lean; no proof module changes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add --resume-from Flag and Append Mode to Lean Executable [COMPLETED]

**Goal**: Extend `DatasetExport.lean` to accept a `--resume-from N` flag that skips the first N formulas during labeling and opens the output file in append mode instead of truncate mode.

**Tasks**:
- [x] Add `resumeFrom : Nat := 0` field to the `CLIArgs` structure (line ~459)
- [x] Add `"--resume-from" :: n :: rest` case to `parseCLIArgs` (line ~494)
- [x] In `main`, change the file open mode from `.write` to `.append` when `resumeFrom > 0` (line ~595): `let handle <- IO.FS.Handle.mk outputPath (if cliArgs.resumeFrom > 0 then .append else .write)` *(deviation: altered -- used `IO.FS.Mode.append`/`.write` variable pattern instead of inline conditional)*
- [x] After enumeration and optional dual enrichment, skip the first `resumeFrom` formulas using `List.drop`: `let formulasToLabel := formulas'.drop cliArgs.resumeFrom`
- [x] Adjust the `count` counter initialization to start from `cliArgs.resumeFrom` so IDs continue correctly (e.g., `let mut count : Nat := cliArgs.resumeFrom`)
- [x] Adjust `validCount`, `invalidCount`, `timeoutCount` initialization -- these can start at 0 since they only affect the metadata/stats for the resumed portion (acceptable tradeoff)
- [x] Print resume information when `resumeFrom > 0`: `IO.println s!"Resuming from formula {cliArgs.resumeFrom}..."`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add resumeFrom to CLIArgs, modify parseCLIArgs, modify main function file open and formula iteration

**Verification**:
- `lake build dataset_generator` compiles without errors
- `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --output data/test-resume.jsonl` produces output (fresh run)
- `lake exe dataset_generator -- --max-complexity 3 --max-formulas 20 --output data/test-resume.jsonl --resume-from 10` appends to existing file and skips first 10 formulas

---

### Phase 2: Formula Checkpoint File for Deterministic Resume [COMPLETED]

**Goal**: After enumeration completes, write the formula list to a checkpoint file so that resume can load formulas from the checkpoint instead of re-enumerating (avoiding `IO.rand` non-determinism in `generateValidBatch`).

**Tasks**:
- [x] Add `--checkpoint-file PATH` CLI flag to `CLIArgs` (default: derive from output path by replacing `.jsonl` with `.checkpoint`)
- [x] Add `"--checkpoint-file" :: p :: rest` case to `parseCLIArgs`
- [x] After formula enumeration and dual enrichment in `main`, write the formula list to the checkpoint file (one S-expression per line) using `Formula.toSExpr`
- [x] Add a `--use-checkpoint` flag that, when set, reads formulas from the checkpoint file instead of re-enumerating
- [x] Implement checkpoint file reading: parse each line as an S-expression back to a `Formula` using `Formula.ofSExpr` (or equivalent parser) *(deviation: altered -- implemented custom S-expression parser `parseSExprFormula` using `String.Pos.Raw` since Lean 4.27 changed `String.Pos` to be a dependent type)*
- [x] In `main`, when `resumeFrom > 0`, automatically check for checkpoint file existence and use it if available; fall back to re-enumeration with a warning if not found
- [x] Skip writing the checkpoint file when `resumeFrom > 0` (the checkpoint already exists)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Checkpoint file read/write logic, CLIArgs extension, main function branching
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` - Only if `Formula.ofSExpr` parser does not exist and needs to be added (check `DataExport.lean` for existing S-expression serialization)

**Verification**:
- Fresh c5 run produces both `.jsonl` and `.checkpoint` files
- Checkpoint file contains one S-expression per line, line count matches formula count
- Running with `--use-checkpoint` and `--resume-from 500` loads from checkpoint and resumes correctly
- Round-trip test: formulas read from checkpoint match formulas from fresh enumeration (for deterministic modes)

---

### Phase 3: Shell-Side Resume Detection and User Prompting [NOT STARTED]

**Goal**: Modify `run_dataset_generation.sh` to detect partial output files, prompt the user to resume or restart, and pass the appropriate flags to the Lean executable.

**Tasks**:
- [ ] Create a `detect_resume()` function that checks if the output JSONL file exists and is non-empty
- [ ] When partial output is detected, count completed lines with `wc -l`, display the count, and prompt the user: `"Found partial output: $file ($N lines). Resume from line $N? [Y/n/restart]"`
- [ ] Validate the last line of the partial JSONL file with `tail -1 | python3 -m json.tool`; if invalid, truncate the last line and decrement the resume count
- [ ] Set `RESUME_FROM` variable based on user response (0 for fresh start, line count for resume)
- [ ] Pass `--resume-from $RESUME_FROM` to the `lake exe dataset_generator` invocation in each `run_*` function
- [ ] Also check for and pass `--use-checkpoint` when the `.checkpoint` file exists alongside the JSONL
- [ ] On successful completion, clean up the `.checkpoint` file: `rm -f "${output_file%.jsonl}.checkpoint"`
- [ ] Update the cleanup trap to also mention checkpoint files in the interruption message
- [ ] Add `--resume` and `--no-resume` flags to the shell script itself for non-interactive use (CI/scripted runs)

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `scripts/run_dataset_generation.sh` - Add resume detection function, modify run_* functions, add CLI flags

**Verification**:
- `./scripts/run_dataset_generation.sh c5` completes normally (no resume prompt on fresh run)
- Interrupt a c5 run (Ctrl+C), then re-run: script detects partial output and prompts for resume
- Choosing "resume" passes correct `--resume-from` and `--use-checkpoint` flags
- Choosing "restart" removes partial files and starts fresh
- `--no-resume` flag skips the prompt and always starts fresh
- `--resume` flag skips the prompt and always resumes

---

### Phase 4: Integration Testing and Edge Case Handling [NOT STARTED]

**Goal**: End-to-end validation of the resume pipeline including edge cases (empty files, corrupt last lines, mismatched parameters).

**Tasks**:
- [ ] Run a full c5 generation, interrupt at ~50%, resume, and verify the final JSONL has no duplicate IDs and all lines are valid JSON
- [ ] Test edge case: empty JSONL file (0 lines) -- should treat as fresh start
- [ ] Test edge case: JSONL with corrupt last line (simulate by appending partial JSON) -- should truncate and resume
- [ ] Test edge case: checkpoint file exists but JSONL does not -- should re-generate from checkpoint
- [ ] Test edge case: JSONL exists but no checkpoint -- should re-enumerate with warning and resume
- [ ] Verify `--dry-run` mode still works correctly with resume detection
- [ ] Run `lake build` to confirm no regressions in the full project build
- [ ] Update the shell script header comments to document the new resume behavior and flags

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `scripts/run_dataset_generation.sh` - Header comment updates
- `Theories/Bimodal/Automation/DatasetExport.lean` - Any edge case fixes discovered during testing

**Verification**:
- All edge case tests pass
- `lake build` succeeds with no errors
- c5 end-to-end resume test produces valid output
- Shell script help text (`--help`) documents resume flags

## Testing & Validation

- [ ] `lake build dataset_generator` compiles successfully after all Lean changes
- [ ] Fresh c5 run produces valid JSONL and checkpoint files
- [ ] Interrupted c5 run followed by resume produces valid merged output with no duplicate IDs
- [ ] Last-line validation correctly detects and truncates corrupt trailing JSON
- [ ] Shell script resume prompt works interactively (Y/n/restart)
- [ ] `--resume` and `--no-resume` flags work for non-interactive use
- [ ] `--dry-run` mode displays resume-aware commands
- [ ] `lake build` passes (full project, no regressions)

## Artifacts & Outputs

- `specs/260_dataset_generation_resumable_interruption/plans/01_implementation-plan.md` (this file)
- Modified: `Theories/Bimodal/Automation/DatasetExport.lean` (--resume-from, checkpoint file support)
- Modified: `scripts/run_dataset_generation.sh` (resume detection, user prompting, cleanup)
- Possibly modified: `Theories/Bimodal/Automation/FormulaEnumerator.lean` (if S-expression parser needed)

## Rollback/Contingency

All changes are additive. The `--resume-from` flag defaults to 0 (no resume), so existing behavior is preserved when the flag is omitted. If checkpoint file support proves too complex, Phase 2 can be deferred and Phase 1+3 alone provide a functional (though not perfectly deterministic) resume capability. To revert, remove the `resumeFrom` field from `CLIArgs` and revert `main` to always use `.write` mode.
