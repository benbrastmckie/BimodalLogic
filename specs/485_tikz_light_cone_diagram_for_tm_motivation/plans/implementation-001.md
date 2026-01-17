# Implementation Plan: Task #485

- **Task**: 485 - Create TikZ light-cone diagram for TM motivation
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/485_tikz_light_cone_diagram_for_tm_motivation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Create a TikZ light-cone diagram for the Bimodal Introduction section to visually motivate TM logic semantics. The diagram shows an S-shaped worldline with a marked point, past and future light cones, and dotted counterfactual paths. This visualization explains why the necessity operator quantifies over all histories while temporal operators quantify along a single history.

### Research Integration

From research-001.md:
- Use Bezier curves (`.. controls ..` syntax) for S-shaped worldlines
- Fill light cone regions with semi-transparent colors (opacity=0.15-0.3)
- Use `dotted` style for counterfactual/past paths
- Light cone boundaries at 45-degree angles
- Match project styling from Logos extension diagram (rounded corners, stealth arrows)
- Insert after line 12 in 00-Introduction.tex

## Goals & Non-Goals

**Goals**:
- Create visually clear light-cone diagram showing worldline, marked point, and cones
- Show alternative/counterfactual paths as dotted lines within cones
- Match existing project TikZ styling conventions
- Compile without errors with pdflatex/latexmk

**Non-Goals**:
- Complex 3D perspective effects
- Animated or interactive diagrams
- Extensive mathematical labeling (keep minimal)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ library import issues | Medium | Low | Libraries already available via main BimodalReference.tex |
| Bezier curve positioning difficulties | Low | Medium | Use iterative refinement with test compilations |
| Diagram too large for column | Low | Low | Use 8cm width constraint as per research |

## Implementation Phases

### Phase 1: Create Basic Diagram Structure [COMPLETED]

**Goal**: Set up TikZ environment with S-curve worldline and marked point

**Tasks**:
- [ ] Read current 00-Introduction.tex to understand insertion context
- [ ] Add TikZ picture environment with appropriate styles (worldline, lightcone, counterfactual)
- [ ] Draw S-shaped main worldline using Bezier controls
- [ ] Add marked point P on the worldline with visible dot

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Insert TikZ diagram after line 12

**Verification**:
- Document compiles without errors
- S-curve and marked point visible in output

---

### Phase 2: Add Light Cone Regions [COMPLETED]

**Goal**: Draw filled past and future light cone regions emanating from point P

**Tasks**:
- [ ] Add future light cone (upward-opening triangle from P at 45-degree angles)
- [ ] Add past light cone (downward-opening triangle from P at 45-degree angles)
- [ ] Apply semi-transparent fills to regions (orange/blue with opacity ~0.15)
- [ ] Draw light cone boundary lines

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Extend TikZ diagram

**Verification**:
- Light cones visible with proper shading
- Proper 45-degree angles maintained

---

### Phase 3: Add Branching Paths and Labels [COMPLETED]

**Goal**: Add counterfactual dotted paths within cones and minimal labels

**Tasks**:
- [ ] Add dotted past path within past light cone
- [ ] Add alternative future paths within future light cone (also dotted or dashed)
- [ ] Add minimal labels (optional: "past", "future", or operator symbols)
- [ ] Ensure visual clarity and proper layering (worldline on top)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Complete TikZ diagram

**Verification**:
- Counterfactual paths clearly visible as dotted
- Labels readable and well-positioned

---

### Phase 4: Final Polish and Compilation Test [COMPLETED]

**Goal**: Verify complete diagram compiles correctly and matches document style

**Tasks**:
- [ ] Run full compilation with latexmk or pdflatex
- [ ] Verify diagram renders correctly in PDF output
- [ ] Adjust sizing if needed to fit within document margins
- [ ] Review visual consistency with rest of document

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Final adjustments if needed

**Verification**:
- Full document compiles without errors
- Diagram appropriately sized and positioned
- Visual style consistent with document

## Testing & Validation

- [ ] pdflatex compiles 00-Introduction.tex without TikZ errors
- [ ] Full BimodalReference.tex document compiles
- [ ] Light cones have correct 45-degree geometry
- [ ] S-curve appears smooth and natural
- [ ] Counterfactual paths distinguishable from main worldline
- [ ] Diagram fits within page margins

## Artifacts & Outputs

- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Modified with TikZ diagram
- `.claude/specs/485_tikz_light_cone_diagram_for_tm_motivation/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Revert changes to 00-Introduction.tex using git checkout
2. The file currently has minimal content, so rollback is straightforward
3. Alternative: Use standalone TikZ file and include as image if integration problematic
