# Implementation Plan: Task #484 (v002)

- **Task**: 484 - Sync TikZ diagram operators with GLOSSARY.md
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false
- **Previous Version**: implementation-001.md
- **Revision Reason**: User specified concrete operator changes for Epistemic and Normative extensions, plus symbol standardization for indicative conditional

## Revision Summary

Key changes from v001:
- **Epistemic**: User requests removing K, adding Pr, Mi, Mu, and indicative conditional
- **Normative**: User requests adding preference ordering and normative explanation symbols
- **Symbol Standardization**: Indicative conditional should use hook-right arrow (good Unicode + LaTeX support)

## Overview

Synchronize operators between the TikZ extension dependencies diagram in 00-Introduction.tex and the GLOSSARY.md reference document, with specific user-directed changes to the Epistemic and Normative extension boxes.

## Goals & Non-Goals

**Goals**:
- Update Epistemic box: Remove K, add Pr, Mi, Mu, and indicative conditional
- Update Normative box: Add preference ordering and normative explanation symbols
- Standardize indicative conditional symbol to hook-right arrow in GLOSSARY.md
- Ensure bidirectional consistency between TikZ and GLOSSARY.md
- Add missing Reflection and Spatial operator tables to GLOSSARY.md

**Non-Goals**:
- Restructuring the TikZ diagram layout
- Modifying operator semantics or definitions
- Updating Lean implementations

## Symbol Research: Indicative Conditional

The user wants a "hook-right arrow" for the indicative conditional. Options:

| Unicode | Name | LaTeX | Notes |
|---------|------|-------|-------|
| `↪` (U+21AA) | Rightwards Arrow with Hook | `\hookrightarrow` | Standard, widely supported |
| `⊃` (U+2283) | Superset | `\supset` | Traditional material conditional (not hook) |
| `⊳` (U+22B3) | Contains as Normal Subgroup | `\rhd` | Less semantic match |

**Recommended**: `↪` (U+21AA) with LaTeX `\hookrightarrow` - has excellent Unicode support in markdown and standard LaTeX support without extra packages.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ box overflow with more operators | Medium | Medium | Use concise operator list, abbreviations |
| LaTeX aux file corruption on rebuild | Low | Low | Clean aux files if errors occur |
| Unicode character rendering issues | Low | Low | Test in markdown preview |

## Implementation Phases

### Phase 1: Update GLOSSARY.md Symbol [COMPLETED]

**Goal**: Standardize indicative conditional symbol to hook-right arrow

**Tasks**:
- [ ] Change indicative conditional from `⟹` to `↪` in Epistemic Operators table
- [ ] Verify Unicode renders correctly in markdown preview
- [ ] Document LaTeX equivalent (`\hookrightarrow`) in a comment or note

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Logos/docs/reference/GLOSSARY.md` - Update symbol in Epistemic table

**Current State**:
```markdown
| `⟹` | Indicative Conditional | "If...then" under actual beliefs | Conditional reasoning |
```

**Target State**:
```markdown
| `↪` | Indicative Conditional | "If A then B" (under actual beliefs) | Conditional reasoning |
```

**Verification**:
- Symbol renders correctly in markdown preview

---

### Phase 2: Update TikZ Epistemic Box [COMPLETED]

**Goal**: Replace K with Pr, Mi, Mu, and indicative conditional per user request

**Tasks**:
- [ ] Modify Epistemic box: change operators from (B, K) to (B, Pr, Mi, Mu, ↪)
- [ ] Update description text accordingly (remove "knowledge", add "probability", "might/must", "conditional")
- [ ] Verify TikZ compiles without errors
- [ ] Check box doesn't overflow

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Epistemic box in TikZ diagram

**Current State**:
```latex
\node[smallbox, left=0.6cm of normative] (epistemic) {
  \begin{tabular}{c}
    \textbf{Epistemic} \\
    {\footnotesize belief,} \\
    {\footnotesize knowledge} \\
    {\small ($\mathsf{B}$, $\mathsf{K}$)}
  \end{tabular}
};
```

**Target State**:
```latex
\node[smallbox, left=0.6cm of normative] (epistemic) {
  \begin{tabular}{c}
    \textbf{Epistemic} \\
    {\footnotesize belief, probability,} \\
    {\footnotesize might/must, conditional} \\
    {\small ($\mathsf{B}$, $\mathsf{Pr}$, $\mathsf{Mi}$, $\mathsf{Mu}$, $\hookrightarrow$)}
  \end{tabular}
};
```

**Verification**:
- `pdflatex 00-Introduction.tex` compiles without errors
- Box fits within layout

---

### Phase 3: Update TikZ Normative Box [COMPLETED]

**Goal**: Add preference ordering and normative explanation symbols

**Tasks**:
- [ ] Add preference ordering symbol to Normative box
- [ ] Add normative explanation symbol to Normative box
- [ ] Update description text accordingly
- [ ] Verify TikZ compiles without errors

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Normative box in TikZ diagram

**Current State**:
```latex
\node[smallbox, below=2.2cm of explanatory] (normative) {
  \begin{tabular}{c}
    \textbf{Normative} \\
    {\footnotesize obligation,} \\
    {\footnotesize permission} \\
    {\small ($\mathsf{O}$, $\mathsf{P}$)}
  \end{tabular}
};
```

**Target State** (symbols from GLOSSARY.md):
```latex
\node[smallbox, below=2.2cm of explanatory] (normative) {
  \begin{tabular}{c}
    \textbf{Normative} \\
    {\footnotesize obligation, permission,} \\
    {\footnotesize preference, explanation} \\
    {\small ($\mathsf{O}$, $\mathsf{P}$, $\prec$, $\mapsto$)}
  \end{tabular}
};
```

Note: GLOSSARY.md uses `≺_a` for preference and `↦` for normative explanation. In LaTeX: `\prec` and `\mapsto`.

**Verification**:
- `pdflatex 00-Introduction.tex` compiles without errors
- Box fits within layout

---

### Phase 4: Update GLOSSARY.md Tables [IN PROGRESS]

**Goal**: Add missing Reflection and Spatial operator tables for bidirectional sync

**Tasks**:
- [ ] Add Reflection Extension section with I operator table
- [ ] Add Spatial Extension operator table with @, Near, Between
- [ ] Verify K_a entry in Epistemic section (keep in GLOSSARY even if removed from TikZ - GLOSSARY is comprehensive reference)
- [ ] Verify table formatting matches existing conventions

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/docs/reference/GLOSSARY.md` - Add operator tables

**Proposed Additions**:

**Reflection Extension** (after Agential):
```markdown
## Reflection Operators (Reflection Extension)

[DETAILS: Full semantic specifications pending]

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `I` | Reflection | "I (the reasoning agent) believe/know that A" | Metacognition |
```

**Spatial Extension** (after Normative):
```markdown
## Spatial Operators (Spatial Extension)

[DETAILS: Full semantic specifications pending]

| Symbol | Name | Definition | Domain |
|--------|------|------------|--------|
| `@_l` | Location | "A holds at location l" | Spatial reasoning |
| `Near` | Proximity | "Location l is near location l'" | Spatial relations |
| `Between` | Betweenness | "Location l is between l' and l''" | Spatial relations |
```

**Verification**:
- Markdown renders correctly
- Tables follow existing format conventions

---

### Phase 5: Build Verification [NOT STARTED]

**Goal**: Verify all changes build correctly and are consistent

**Tasks**:
- [ ] Build full LaTeX document (LogosReference.tex)
- [ ] Review rendered PDF for diagram quality
- [ ] Verify no LaTeX warnings about overfull boxes
- [ ] Review GLOSSARY.md in rendered markdown

**Timing**: 15 minutes

**Verification**:
- `pdflatex LogosReference.tex` succeeds
- No overfull hbox warnings in diagram area
- GLOSSARY.md displays correctly

## Testing & Validation

- [ ] TikZ diagram compiles without LaTeX errors
- [ ] Full document (LogosReference.tex) builds successfully
- [ ] Diagram maintains visual balance and readability
- [ ] GLOSSARY.md tables render correctly in markdown
- [ ] Epistemic box shows: B, Pr, Mi, Mu, ↪ (no K)
- [ ] Normative box shows: O, P, ≺, ↦
- [ ] Indicative conditional uses ↪ consistently in GLOSSARY.md

## Artifacts & Outputs

- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Updated TikZ diagram
- `Theories/Logos/docs/reference/GLOSSARY.md` - Updated symbol + new tables
- `.claude/specs/484_sync_tikz_diagram_operators_with_glossary/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

Both files are under git version control. If changes cause issues:
1. Revert 00-Introduction.tex with `git checkout HEAD -- Theories/Logos/latex/subfiles/00-Introduction.tex`
2. Revert GLOSSARY.md with `git checkout HEAD -- Theories/Logos/docs/reference/GLOSSARY.md`
3. Clean LaTeX auxiliary files if corruption occurs: `rm -f *.aux *.log *.out`
