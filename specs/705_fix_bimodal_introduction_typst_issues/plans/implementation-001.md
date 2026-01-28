# Implementation Plan: Task #705

- **Task**: 705 - Fix Bimodal Introduction Typst Issues
- **Status**: [COMPLETED]
- **Effort**: 0.75 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: specs/705_fix_bimodal_introduction_typst_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Fix two FIX: tagged issues in the Bimodal introduction chapter: (1) replace the incorrectly drawn light cone diagram with properly filled CeTZ triangles using `line()` with `close: true`, and (2) add a show rule to automatically bold all "TM" occurrences throughout the document.

### Research Integration

The research report identified:
- Current light cone code uses 6 separate line commands with fill applied incorrectly to non-closed shapes
- CeTZ `line()` with `close: true` and `fill` creates proper filled triangles with just 2 commands
- Typst show rule `#show "TM": strong` automatically bolds all TM occurrences
- Show rule should be placed in BimodalReference.typ after document configuration

## Goals & Non-Goals

**Goals**:
- Fix the light cone diagram to display properly filled past/future cones
- Ensure "TM" appears in bold consistently throughout the document
- Remove FIX: tags after issues are resolved

**Non-Goals**:
- Redesigning the overall diagram layout
- Adding additional visual elements to the figure
- Modifying TM styling in code blocks (show rule correctly excludes these)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CeTZ fill rendering differs from expected | M | L | Test with `typst compile` after changes |
| Show rule conflicts with existing bold TM usages | L | L | Existing `*TM*` will render as bold regardless (redundant but harmless) |

## Implementation Phases

### Phase 1: Fix Light Cone Diagram [COMPLETED]

**Goal**: Replace the current 6-line cone drawing code with 2 properly filled closed polygons

**Tasks**:
- [ ] Replace lines 27-41 in 00-introduction.typ with simplified CeTZ code
- [ ] Use `line(P, vertex1, vertex2, close: true, fill: color, stroke: strokeColor)` pattern
- [ ] Keep counterfactual paths and worldline code unchanged
- [ ] Remove FIX: comment at line 18
- [ ] Verify diagram renders correctly

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - Replace light cone drawing code (lines 27-41) with simplified version

**Implementation Details**:

Current code (lines 27-41) draws cones incorrectly:
```typst
// Past light cone (blue, opens left)
line(P, (-0.7, 1.0), stroke: gray.lighten(40%))
line(P, (-0.7, -1.2), stroke: gray.lighten(40%))
line((-0.7, 1.0), (-0.7, -1.2), stroke: none, fill: blue.transparentize(85%))
// ... similar for future cone
// Fill the past cone
line(P, (-0.7, 1.0), (-0.7, -1.2), close: true, stroke: none, fill: blue.transparentize(85%))
// Fill the future cone
line(P, (1.7, 1.0), (1.7, -1.2), close: true, stroke: none, fill: orange.transparentize(85%))
```

Replace with:
```typst
// Past light cone (blue, opens left) - filled triangle
line(
  P, (-0.7, 1.0), (-0.7, -1.2),
  close: true,
  fill: blue.transparentize(85%),
  stroke: gray.lighten(40%)
)

// Future light cone (orange, opens right) - filled triangle
line(
  P, (1.7, 1.0), (1.7, -1.2),
  close: true,
  fill: orange.transparentize(85%),
  stroke: gray.lighten(40%)
)
```

**Verification**:
- Run `typst compile BimodalReference.typ` from Theories/Bimodal/typst/
- Visually inspect that light cones appear as filled triangles
- Verify past cone is blue-tinted, future cone is orange-tinted

---

### Phase 2: Add Bold TM Show Rule [COMPLETED]

**Goal**: Automatically bold all "TM" occurrences throughout the document

**Tasks**:
- [ ] Add `#show "TM": strong` to BimodalReference.typ after document configuration
- [ ] Place after line 47 (before thmbox-show initialization)
- [ ] Remove FIX: comment at line 78 in 00-introduction.typ
- [ ] Verify TM appears bold in all chapters

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - Add show rule after heading spacing configuration (line 47)
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - Remove FIX: comment at line 78

**Implementation Details**:

Add after line 47 in BimodalReference.typ (after `#show heading: set block(above: 1.4em, below: 1em)`):
```typst
// Automatically bold "TM" throughout the document
#show "TM": strong
```

This placement ensures:
- Rule applies to all content after document configuration
- Rule is scoped to the entire document
- Does not affect raw/code blocks (desired behavior)

**Verification**:
- Run `typst compile BimodalReference.typ`
- Check line 80 in introduction: "TM logic" should appear bold
- Check abstract (lines 111-112): TM should appear bold
- Verify no visual regressions in other chapters

## Testing & Validation

- [ ] `typst compile BimodalReference.typ` completes without errors
- [ ] Light cone diagram shows filled triangular cones (blue left, orange right)
- [ ] "TM" appears bold in introduction chapter (including line 80)
- [ ] "TM" appears bold in abstract section
- [ ] No FIX: comments remain in 00-introduction.typ

## Artifacts & Outputs

- Modified `Theories/Bimodal/typst/chapters/00-introduction.typ` with corrected diagram and removed FIX: comments
- Modified `Theories/Bimodal/typst/BimodalReference.typ` with show rule for bold TM

## Rollback/Contingency

If implementation causes rendering issues:
1. Revert changes to both files using git
2. Re-examine CeTZ documentation for alternative fill syntax
3. Consider using `merge-path` for more complex cone shapes if `line()` insufficient
