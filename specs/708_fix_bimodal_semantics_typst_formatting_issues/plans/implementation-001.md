# Implementation Plan: Task #708

- **Task**: 708 - Fix Bimodal semantics Typst formatting issues
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/708_fix_bimodal_semantics_typst_formatting_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix three Typst formatting issues in the bimodal semantics documentation by updating command definitions in `bimodal-notation.typ`. The issues involve arrow annotation positioning, italic text rendering, and subscript/superscript stacking. All fixes use Typst's built-in `limits()` function and `math.italic()` - no external dependencies needed.

### Research Integration

The research report identified that:
1. `attach()` defaults to script-style positioning (to the side) for non-big-operator symbols
2. `limits()` wrapper forces limits-style positioning (above/below)
3. `math.italic()` provides proper math-mode italics vs content-mode markdown italics
4. Current implementations are close but missing the `limits()` wrapper

## Goals & Non-Goals

**Goals**:
- Duration text appears centered ABOVE the arrow (not as superscript)
- "iff" displays in proper math-mode italics
- Subscript/superscript on approx symbol stack directly above/below (LaTeX-style)
- Minimal changes to existing code

**Non-Goals**:
- Restructuring the notation module
- Adding external package dependencies (xarrow)
- Changing the visual design of the document

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `limits()` changes symbol spacing | Medium | Low | Visual verification after each change |
| Math italic vs text italic appearance differs | Low | Low | Both valid; verify readability |
| Existing usages break | Low | Very Low | Commands maintain same interface |

## Implementation Phases

### Phase 1: Update overset Command [NOT STARTED]

**Goal**: Make duration text appear centered above the arrow instead of as a superscript

**Tasks**:
- [ ] Update `overset` function in bimodal-notation.typ to use `limits()` wrapper

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - line 79

**Change**:
```typst
// Before:
#let overset(base, top) = $attach(#base, t: #top)$

// After:
#let overset(base, top) = $limits(#base)^#top$
```

**Verification**:
- Compile document and check line 28 of semantics chapter
- Duration `x` should appear centered above the double arrow

---

### Phase 2: Update Iff Command [NOT STARTED]

**Goal**: Display "iff" in proper math-mode italics

**Tasks**:
- [ ] Update `Iff` command in bimodal-notation.typ to use `math.italic()`

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - line 76

**Change**:
```typst
// Before:
#let Iff = [~_iff_~]

// After:
#let Iff = math.italic("iff")
```

**Verification**:
- Compile document and check line 79 of semantics chapter
- "iff" should appear in italics with proper math spacing

---

### Phase 3: Update timeshift Command [NOT STARTED]

**Goal**: Make subscript/superscript stack directly above/below the approx symbol (LaTeX-style)

**Tasks**:
- [ ] Update `timeshift` function in bimodal-notation.typ to use `limits()` wrapper

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - line 82

**Change**:
```typst
// Before:
#let timeshift(sub, sup) = $attach(approx, t: #sup, b: #sub)$

// After:
#let timeshift(sub, sup) = $limits(approx)_#sub^#sup$
```

**Verification**:
- Compile document and check lines 106, 112 of semantics chapter
- Subscript and superscript should stack directly above/below the approx symbol

---

### Phase 4: Remove FIX Tags and Final Verification [NOT STARTED]

**Goal**: Clean up FIX tags and verify all changes work together

**Tasks**:
- [ ] Remove any FIX: comments from source files if present
- [ ] Compile full document
- [ ] Visual verification of all three fixes in context

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - remove FIX comments if any
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - remove FIX comments if any

**Verification**:
- Full document compiles without errors
- All three formatting issues resolved
- No visual regressions in other parts of the document

## Testing & Validation

- [ ] Document compiles successfully with `typst compile`
- [ ] Duration text centered above arrow in primitives table (line 28)
- [ ] "iff" appears in italics in Truth definition (line 79)
- [ ] Time-shift subscript/superscript properly stacked (lines 106, 112)
- [ ] No visual regressions elsewhere in document

## Artifacts & Outputs

- Modified `Theories/Bimodal/typst/notation/bimodal-notation.typ` (3 command updates)
- Optionally modified `Theories/Bimodal/typst/chapters/02-semantics.typ` (FIX tag removal)
- Compiled PDF for visual verification

## Rollback/Contingency

If any change causes unexpected issues:
1. Revert the specific command change in bimodal-notation.typ
2. The original implementations are preserved in this plan
3. If `limits()` approach fails, consider xarrow package as documented in research report
