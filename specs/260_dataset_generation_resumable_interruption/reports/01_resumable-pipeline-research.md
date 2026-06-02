# Research Report: Make Dataset Generation Pipeline Resumable After Interruption

**Task**: 260
**Session**: sess_1780357626_e5e4c9
**Date**: 2026-06-01

## 1. Current Pipeline Flow

The dataset generation pipeline has three layers:

### 1.1 Shell Script (`scripts/run_dataset_generation.sh`)

- Entry point for production runs: `smoke`, `c5`, `c7`, `c9`, `c11`, `all`
- Invokes `lake exe dataset_generator` with tier-specific flags
- Has a cleanup trap for `EXIT INT TERM` that preserves partial JSONL files for inspection
- No existing resume logic -- each invocation is a fresh run

### 1.2 Lean Executable (`Theories/Bimodal/Automation/DatasetExport.lean`)

The `main` function in `DatasetExport.lean` is the `dataset_generator` executable entry point (registered in `lakefile.lean` as `lean_exe dataset_generator` with root `Bimodal.Automation.DatasetExport`).

**Pipeline stages within the Lean executable**:

1. **Parse CLI args** -- `parseCLIArgs` handles `--max-complexity`, `--output`, `--mode`, etc.
2. **Enumerate formulas** -- `generateFormulas` (in `FormulaEnumerator.lean`):
   - Exhaustive or stratified enumeration across complexity levels 1..N
   - Axiom-seeded valid formula generation via `generateValidBatch`
   - Hash-based deduplication
   - Progress reporting via `[enum]` and `[valid]` tags
3. **Optionally enrich with temporal duals** -- `enrichWithDuals`
4. **Label + stream** -- The critical long-running step:
   - Opens output JSONL file with `IO.FS.Handle.mk outputPath .write`
   - Iterates through all formulas, calling `labelFormula` on each
   - **Writes each JSONL line immediately** via `writeRecordJSONL`
   - Reports progress every 1000 formulas with `[label]` tag
5. **Write metadata** -- Writes `_metadata.json` companion file

### 1.3 JSONL Output Format

Each line is a self-contained JSON record with fields: `id`, `split`, `formula_str`, `formula_ast`, `frame_class`, `label`, `decision_method`, `proof_trace`, `countermodel`, `metrics`, etc.

- c5: ~1,513 records (exhaustive, ~seconds)
- c7: ~49,904 records (exhaustive, ~minutes)
- c9: ~300K-1.8M records (exhaustive, 30min-2h)
- c11: ~500K-2M records (stratified, 1-4h)

## 2. Where Interruption Causes Data Loss

### 2.1 Enumeration Phase (HIGH IMPACT for c9+)

The enumeration step (`generateFormulas`) runs entirely in memory. All formulas are enumerated, axiom-seeded, and deduplicated in a `List Formula` before any labeling begins. If interrupted during enumeration:

- **All enumeration work is lost** -- no intermediate state is saved
- For c9, enumeration alone can take significant time (the `[enum]` progress lines show per-level timing)
- For c11 with stratified quotas, enumeration is somewhat faster per level but still material

### 2.2 Labeling Phase (HIGHEST IMPACT)

This is the dominant bottleneck. Each formula is passed through the decision procedure (`decideAuto`), which runs a tableau-based validity check. The labeling phase:

- **Already streams to disk**: Each labeled record is written immediately via `writeRecordJSONL` before moving to the next formula
- **BUT**: The file is opened with `.write` mode (truncate), so a restart would overwrite any existing partial output
- **No checkpoint of position**: There is no record of which formulas have been labeled vs. remaining
- Formula IDs are sequential (`bmlogic-00001`, `bmlogic-00002`, ...), so the last line number in the partial JSONL indicates progress

### 2.3 Metadata Phase (LOW IMPACT)

Metadata is written after all labeling completes. If interrupted before metadata:
- JSONL data is intact (already streamed)
- Metadata can be reconstructed from the JSONL file

### 2.4 Key Insight: Labeling Already Streams

The current design already writes each labeled record immediately (lines 605-638 of DatasetExport.lean). This is a major advantage -- the partial JSONL file is already a valid dataset. The problem is only:
1. The file is opened with truncation mode (`.write`), destroying previous partial output on restart
2. Formulas are re-enumerated from scratch on restart with no way to skip already-labeled formulas
3. No metadata tracks progress state

## 3. Checkpoint/Resume Design Options

### Option A: Shell-Side Resume Only (RECOMMENDED)

**Approach**: Keep Lean code unchanged. Add shell-level resume logic that:

1. Detects existing partial JSONL output (`data/bmlogic-c9.jsonl`)
2. Counts completed lines (each line = one labeled formula)
3. Restarts the Lean generator with a `--skip N` flag to skip the first N formulas
4. Uses append mode instead of truncate mode

**Lean changes required**:
- Add `--skip N` CLI flag to skip first N formulas after enumeration
- Change file open mode from `.write` to conditionally `.append` when `--skip > 0`
- Adjust ID numbering to continue from N+1

**Pros**: Minimal Lean changes, shell handles detection/prompting
**Cons**: Re-enumerates all formulas (but skips labeling), so enumeration cost is repeated

### Option B: Lean-Side Checkpoint File (FULL SOLUTION)

**Approach**: Add a `.progress` metadata file alongside the JSONL output that tracks:

```json
{
  "stage": "labeling",
  "total_formulas": 300000,
  "labeled_count": 150000,
  "last_id": "bmlogic-150000",
  "enumeration_hash": "abc123",
  "started_at": "2026-06-01T10:00:00Z",
  "params": { ... }
}
```

**Lean changes**:
- Write `.progress` file periodically (every 1000 formulas, matching existing progress reporting)
- On startup, check for existing `.progress` file
- If found and params match, skip enumeration and resume labeling from `labeled_count`
- Write progress file atomically (write to `.progress.tmp`, rename)

**Pros**: Full resume including skipping re-enumeration
**Cons**: More complex Lean changes, needs parameter matching logic

### Option C: Two-Stage Pipeline with Intermediate File

**Approach**: Split the pipeline into two explicit stages:

1. **Stage 1 (Enumerate)**: Write enumerated formulas to an intermediate file (`data/bmlogic-c9.formulas.txt`, one formula per line in S-expression format)
2. **Stage 2 (Label)**: Read formulas from intermediate file, label, write JSONL with append mode

**Lean changes**:
- New `--enumerate-only` flag that writes formulas to an intermediate file
- New `--label-from FILE --skip N` flag that reads formulas and labels from offset
- Shell script orchestrates the two stages

**Pros**: Clean separation, intermediate file is a checkpoint, each stage is independently restartable
**Cons**: More disk I/O, intermediate file for c9 could be large, formula serialization/deserialization needed

## 4. Recommended Approach: Option A (Shell-Side Resume) Enhanced

The recommended approach is Option A with targeted enhancements, because:

1. **Labeling already streams** -- the hardest part is already solved
2. **Enumeration is deterministic** -- same params always produce the same formula list in the same order, so re-enumeration is safe (just costs time, not correctness)
3. **Minimal Lean surface area** -- reduces risk of introducing bugs in the formally verified codebase
4. **c5/c7 don't need it** -- they complete in seconds/minutes; resume is only critical for c9/c11

### 4.1 Shell-Script Changes

```bash
# In run_dataset_generation.sh, before calling lake exe:

# Check for existing partial output
if [ -f "$output_file" ] && [ -s "$output_file" ]; then
    completed=$(wc -l < "$output_file")
    echo "Found partial output: $output_file ($completed lines)"
    read -p "Resume from line $completed? [Y/n/restart] " choice
    case "$choice" in
        n|restart)
            rm -f "$output_file" "${output_file%.jsonl}_metadata.json"
            SKIP=0
            ;;
        *)
            SKIP=$completed
            ;;
    esac
else
    SKIP=0
fi

# Pass --resume-from to Lean executable
lake exe dataset_generator -- \
    --max-complexity 9 \
    ... \
    --resume-from $SKIP \
    --output $output_file
```

### 4.2 Lean Executable Changes

In `DatasetExport.lean`:

1. **New CLI flag**: `--resume-from N` (default 0)
2. **Append mode**: When `resumeFrom > 0`, open file with `.append` instead of `.write`
3. **Skip labeling**: After enumeration, skip first `resumeFrom` formulas before labeling
4. **Adjust IDs**: Start sequential IDs from `resumeFrom + 1`
5. **Adjust counters**: Initialize `count`, `validCount`, etc. by scanning existing file (or accept from CLI)

### 4.3 Atomic Write Safety

The current streaming design (one `writeRecordJSONL` call per formula) is already close to atomic per-line. To prevent corrupted last lines:

- Each `handle.putStrLn` writes a complete JSON line followed by newline
- On POSIX, `write()` calls up to PIPE_BUF (4096 bytes) are atomic to regular files
- Most JSONL records are well under 4KB, so each line write is atomic
- As extra safety, the shell resume logic can validate the last line of the partial file before resuming

### 4.4 Progress Metadata File

Additionally, write a `.progress` file alongside the JSONL for easier resume detection:

```json
{
  "output_file": "data/bmlogic-c9.jsonl",
  "stage": "labeling",
  "total_formulas": 1800000,
  "labeled_count": 150000,
  "params_hash": "sha256_of_cli_args",
  "started_at": "2026-06-01T10:00:00Z"
}
```

This can be updated every 1000 formulas (aligned with existing progress reporting) and used by the shell script for richer resume information.

## 5. Enumeration Determinism Analysis

A critical requirement for resume correctness: the enumeration must produce the **same formulas in the same order** on restart.

### 5.1 Exhaustive Mode

- `enumerateWithProgress` iterates complexity levels 1..N, calling `enumExactBudget` per level
- `enumExactBudget` is a pure function with memoization -- fully deterministic
- `passesFilter` is a pure predicate -- deterministic
- Formula ordering within each level is determined by the recursive enumeration structure
- **Verdict: DETERMINISTIC** -- same params always produce the same formula list

### 5.2 Stratified Mode

- `enumerateStratifiedWithProgress` is also deterministic: exhaustive up to quota, then `deterministicSampleFormulas` uses LCG with `level * 12345 + 42` seed
- **Verdict: DETERMINISTIC**

### 5.3 Valid Seed Generation

- `generateValidBatch` uses `IO.rand` for axiom instantiation -- NOT deterministic across runs
- However, valid seeds are mixed in AFTER enumeration and before labeling
- If we re-enumerate on resume, valid seeds will differ, which means formula ordering may change
- **Mitigation**: Either (a) accept that some formulas may be re-labeled (harmless, just wasted work), or (b) save the enumerated formula list to a checkpoint file

### 5.4 Temporal Dual Enrichment

- `enrichWithDuals` is deterministic (pure function)
- `hashDedup` is deterministic (HashMap iteration order depends on hash values, which are deterministic for the same formulas)

### 5.5 Resume Correctness Strategy

Since `generateValidBatch` uses `IO.rand`, the formula list on re-enumeration may differ from the original run. Two mitigation strategies:

**Strategy 1 (Simple)**: Accept potential re-labeling. When resuming, re-enumerate all formulas. Skip the first N (already labeled) and label the rest. If formula ordering shifted due to different random seeds in valid batch:
- Some formulas already in the JSONL may be re-labeled (producing duplicate entries)
- The shell script can deduplicate by `formula_str` after the run completes
- This is simple but imperfect

**Strategy 2 (Robust, RECOMMENDED)**: Save the enumerated formula list to a checkpoint file before labeling begins. On resume, load formulas from the checkpoint file instead of re-enumerating.

- Write `data/bmlogic-c9.formulas.checkpoint` with one S-expression per line
- This file is written once, after enumeration completes
- On resume, if the checkpoint file exists and params match, skip enumeration entirely
- Parse the formulas from the checkpoint file and resume labeling from offset N

This adds a formula serialization/deserialization step but eliminates the non-determinism problem entirely.

## 6. Implementation Scope Estimate

### Lean Changes (DatasetExport.lean)

1. Add `--resume-from N` CLI arg parsing (~5 lines in `parseCLIArgs`)
2. Conditional file open mode (`.write` vs `.append`) (~3 lines)
3. Skip first N formulas after enumeration (~5 lines)
4. Adjust ID counter start (~2 lines)
5. Optional: Write/read formula checkpoint file (~30-50 lines for S-expr serialization/parsing)
6. Optional: Write `.progress` file every 1000 formulas (~15 lines)

Total Lean: ~30-80 lines depending on checkpoint file approach

### Shell Changes (run_dataset_generation.sh)

1. Detect partial output and prompt for resume (~15 lines)
2. Pass `--resume-from` flag to Lean executable (~5 lines)
3. Validate last line of partial JSONL (~5 lines)
4. Optional: Add `--resume` flag to the shell script (~10 lines)
5. Add progress file cleanup on successful completion (~3 lines)

Total Shell: ~25-40 lines

### Testing

- Smoke test with interruption simulation (kill -INT)
- Verify resume produces valid JSONL (no duplicate/corrupt lines)
- Verify c5 end-to-end with resume (fast enough for CI)

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Formula ordering non-determinism from `IO.rand` in valid seeds | Medium | Use checkpoint file for formula list |
| Corrupted last JSONL line on interrupt | Low | Validate last line before resume; line writes are atomic under PIPE_BUF |
| Stale checkpoint from different params | Medium | Include params hash in checkpoint; reject mismatched checkpoints |
| Extra disk space for checkpoint file | Low | c9 formula checkpoint ~50-100MB; acceptable for multi-hour runs |
| Lean compilation time for changes | Low | Changes are in DatasetExport.lean only, isolated from proof modules |

## 8. File Locations Summary

| File | Purpose |
|------|---------|
| `scripts/run_dataset_generation.sh` | Shell entry point, tier configs |
| `Theories/Bimodal/Automation/DatasetExport.lean` | `main` entry point, CLI parsing, streaming pipeline |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Formula enumeration, sampling, valid seed generation |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Labeling pipeline (`labelFormula`, `labelBatch`) |
| `Theories/Bimodal/Automation/DataExport.lean` | JSON serialization primitives |
| `Theories/Bimodal/Automation/DatasetExporter.lean` | Older structured JSON export (not used by CLI) |
| `lakefile.lean` | Declares `dataset_generator` executable (line 37-40) |

## 9. Recommendations

1. **Implement Option A Enhanced** with formula checkpoint file (Strategy 2)
2. **Phase the implementation**:
   - Phase 1: Shell-side resume detection + `--resume-from` flag in Lean (minimal viable resume)
   - Phase 2: Formula checkpoint file for deterministic resume (eliminates re-enumeration)
   - Phase 3: `.progress` metadata file for richer status reporting
3. **Focus on c9/c11** -- c5/c7 complete fast enough that resume is not critical
4. **Validate last line** of partial JSONL before appending (truncate if corrupt)
5. **Do NOT change the streaming architecture** -- it is already well-designed for resumability
