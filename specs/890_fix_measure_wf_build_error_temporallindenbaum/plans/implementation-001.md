# Implementation Plan: Task #890

**Task**: Fix measure_wf build error in TemporalLindenbaum.lean
**Version**: 001
**Created**: 2026-02-17
**Language**: lean
**Status**: [COMPLETED]
**Effort**: 5 minutes

## Overview

Replace `measure_wf` with `measure` and change alternative name from `ind` to `h` at two locations in TemporalLindenbaum.lean.

### Research Integration

From research-001.md:
- **Root cause**: `measure_wf` was never defined - should be `measure` from `Init.WF`
- **Fix type**: Syntactic replacement (2 changes)
- **No new imports required**: `measure` is auto-imported from `Init.WF`

## Goals & Non-Goals

**Goals**:
- Fix the Unknown identifier `measure_wf` error at lines 220 and 263
- Enable `lake build` to succeed for TemporalLindenbaum.lean
- Unblock task 888

**Non-Goals**:
- Refactoring the induction structure
- Changing the proof logic

## Implementation Phases

### Phase 1: Apply Fix [COMPLETED]

**Dependencies**: None
**Estimated effort**: 5 minutes

**Tasks**:
- [ ] Edit line 220: Replace `measure_wf` with `measure` and `ind` with `h`
- [ ] Edit line 263: Replace `measure_wf` with `measure` and `ind` with `h`

**Exact Changes**:

**Line 220** - Change:
```lean
induction φ using (measure_wf Formula.complexity).wf.induction with
| ind χ ih =>
```
To:
```lean
induction φ using (measure Formula.complexity).wf.induction with
| h χ ih =>
```

**Line 263** - Same change as above.

**Verification**:
- Run `lake build Bimodal.Metalogic.Bundle.TemporalLindenbaum`
- Run `lake build` for full verification
- Confirm no new errors introduced

---

## Testing & Validation

- [ ] TemporalLindenbaum.lean compiles without the `measure_wf` error
- [ ] Full `lake build` succeeds
- [ ] No new errors introduced

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Fixed file

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Proof body needs adjustment | Low | Research confirmed bindings have same types |

## Success Criteria

- [ ] Both `measure_wf` errors fixed
- [ ] `lake build` succeeds
- [ ] Task 888 unblocked
