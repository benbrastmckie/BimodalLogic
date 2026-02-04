# Implementation Summary: Task 858

**Completed**: 2026-02-04
**Duration**: ~30 minutes

## Overview

Removed misleading comments that incorrectly claimed omega-saturation/omega-rule is a "fundamental limitation" for proving temporal backward directions (G/H operators). The correct explanation is that these proofs require structural properties (`temporal_backward_G/H`) on IndexedMCSFamily, using the same MCS maximality pattern as `modal_backward` in BMCS.

## Changes Made

### TruthLemma.lean (Primary)

1. **Module docstring (lines 58-77)**: Replaced omega-saturation claims with accurate explanation of temporal_backward_G/H structural property approach

2. **Mid-file note (lines 148-158)**: Updated to explain structural properties and reference Task 857

3. **Inline comments at sorry locations (lines 384, 396)**: Changed from "omega-saturation" to "temporal_backward_G/H property (Task 857)" with explanation of the contraposition pattern

4. **Summary section (lines 450-455)**: Replaced "fundamental limitation" language with accurate characterization of pending Task 857

### Completeness.lean

- **Line 445**: Corrected sorry count from 4 to 2 and replaced "(omega-saturation)" with "(pending Task 857 temporal_backward properties)"

### README.md

- **Line 164**: Updated future work item from "Add omega-saturation" to "Add temporal_backward_G/H properties to IndexedMCSFamily (Task 857)"

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | 4 comment sections updated |
| `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | 1 line updated |
| `Theories/Bimodal/Metalogic/Bundle/README.md` | 1 line updated |

## Verification

- Build passes with no errors for all modified files
- No remaining "fundamental limitation" references in Bundle/
- Remaining "omega-saturation" and "omega-rule" references are accurate (explaining why the approach is NOT the omega-rule)

## Key Technical Insight

The temporal backward directions use the **same proof pattern as modal_backward**:
1. Contraposition: if G phi NOT in MCS, then F(neg phi) IS in MCS (by maximality)
2. By forward coherence: neg phi at some future time s > t
3. This contradicts the hypothesis that phi holds at ALL times >= t

This is a **structural property** that the IndexedMCSFamily construction must establish, not an infinitary omega-rule. Task 857 adds these `temporal_backward_G` and `temporal_backward_H` properties.

## Notes

- This is a documentation-only task - no proof code was modified
- All sorries remain in place (their resolution is Task 857's responsibility)
- The comments now accurately reflect the technical approach and next steps
