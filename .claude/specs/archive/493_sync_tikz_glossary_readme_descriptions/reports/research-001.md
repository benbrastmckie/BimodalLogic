# Research Report: Task #493

**Task**: 493 - Sync TikZ diagram, GLOSSARY.md, and README.md descriptions
**Started**: 2026-01-14T00:06:30Z
**Completed**: 2026-01-14T00:15:00Z
**Effort**: 1 hour (research)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` (TikZ diagram)
- `Theories/Logos/docs/reference/GLOSSARY.md`
- `README.md`
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All three sources describe the same layered architecture but with significant terminology and structural inconsistencies
- The README ASCII diagram shows Agential and Reflection as sequential layers; TikZ shows them as parallel within a third grey box
- GLOSSARY.md references "Agential Extension" but TikZ diagram splits this into "Agential" and "Abilities" as separate boxes
- Operator inventories differ across sources (TikZ is most comprehensive, GLOSSARY has details not in others)
- The "Social" extension appears only in TikZ diagram but is absent from README and GLOSSARY
- "Choice Extension" operators differ: TikZ shows `Perm/Forb/Ch`, GLOSSARY shows `FP/FF/Ch`, README mentions `free choice`

## Context & Scope

This research compares three documentation sources describing the Logos extension architecture:

1. **TikZ Diagram** (`00-Introduction.tex`): Visual dependency diagram in LaTeX
2. **GLOSSARY.md**: Technical reference with operator tables
3. **README.md**: User-facing project overview with ASCII diagram

The goal is to identify all discrepancies to enable synchronization.

## Findings

### 1. Layer Structure Discrepancies

| Aspect | TikZ Diagram | README.md | GLOSSARY.md |
|--------|--------------|-----------|-------------|
| Foundation layer | "Constitutive Foundation" | "Constitutive Foundation" | "Constitutive Foundation" |
| Second layer | "Explanatory Extension" | "Explanatory Extension" | "Explanatory Extension" |
| Middle extensions | Epistemic, Abilities, Normative, Choice, Spatial | Epistemic, Abilities, Normative, Choice, Spatial | Same (as table entries) |
| Bottom layer | Agential, Social, Reflection (parallel, grey box) | Agential then Reflection (sequential) | "Agential Extension" (requires middle extension) |
| Social extension | YES (in grey box with Agential, Reflection) | NO | NO |

**Key discrepancy**: TikZ shows Agential/Social/Reflection as peer extensions in a "Agent-dependent extensions" grey box. README shows Agential and Reflection as sequential layers with arrows.

### 2. Dependency/Inheritance Differences

| Source | Agential depends on | Reflection depends on |
|--------|---------------------|----------------------|
| TikZ | Middle extensions (implicit via arrow) | Middle extensions (same grey box as Agential) |
| README | "at least one required" from middle | "inherits from Epistemic" |
| GLOSSARY | "(requires middle extension)" | "pending" |

**Key discrepancy**: README explicitly states Reflection "inherits from Epistemic" but TikZ shows no such specific dependency.

### 3. Operator Symbol Differences

#### 3.1 Epistemic Extension

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Belief | B | B | B_a |
| Probability | Pr | Pr | Pr |
| Might | Mi | - | Mi |
| Must | Mu | - | Mu |
| Indicative | hookrightarrow | - | hookarrow |
| Knowledge | - | K | K_a |

**Discrepancy**: TikZ omits Knowledge (K); README omits Mi/Mu; agent-indexing varies (B vs B_a).

#### 3.2 Abilities Extension

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Can | Can | Can | Can_a |
| Stit | Stit | stit | - (STIT in concepts) |
| Able | - | Able | Able_a |

**Discrepancy**: TikZ omits Able; agent-indexing varies.

#### 3.3 Normative Extension

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Obligation | O | O | O |
| Permission | P | P | P |
| Preference | prec | - | prec_a |
| Explanation | mapsto | - | mapsto |

**Discrepancy**: README omits preference and explanation operators.

#### 3.4 Choice Extension

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Free Permission | Perm | - | FP |
| Forbidden | Forb | - | FF |
| Choice | Ch | - | Ch |

**Critical discrepancy**: TikZ uses `Perm/Forb/Ch`, GLOSSARY uses `FP/FF/Ch`. README only mentions "free choice, alternatives" without symbols.

#### 3.5 Spatial Extension

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Location | @ | location | @_l |
| Between | Btw | - | Between |
| Other | "..." | spatial relations | Near |

**Discrepancy**: Symbol style varies (@, @_l); operator inventory incomplete in README.

### 4. Constitutive Foundation Operators

| Operator | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Prop Identity | equiv | equiv | equiv |
| Grounding | leq | leq | leq |
| Essence | sqsubseteq | sqsubseteq | sqsubseteq |
| Reduction | Rightarrow | - | - |
| Relevance | - | - | preccurlyeq |

**Discrepancy**: TikZ shows "reduction" (Rightarrow) not in GLOSSARY; GLOSSARY shows "relevance" (preccurlyeq) not in TikZ.

### 5. Explanatory Extension Operators

| Category | TikZ | README | GLOSSARY |
|----------|------|--------|----------|
| Modal | Box, Diamond | Box, Diamond | Box, Diamond |
| Temporal | H, G, P, F | H, G, P, F | H, G, P, F |
| Store/Recall | downarrow, uparrow | - | uparrow^i, downarrow^i |
| Counterfactual | boxright, diamondright | boxright, diamondright | boxright, diamondright |
| Causal | circleright, dotcircleright | circleright | circleright |
| Since/Until | - | - | triangleleft, triangleright |
| Quantifiers | forall, exists | - | - |
| Actuality | Act | - | Act(t) |

**Discrepancy**: Store/recall, quantifiers, actuality, since/until inconsistently documented.

### 6. Description Differences

#### Social Extension (TikZ only)
- TikZ: "common ground"
- README: Not mentioned
- GLOSSARY: Not mentioned

#### Reflection Extension
- TikZ: "metacognition"
- README: "metacognition, self-modeling, I operator"
- GLOSSARY: `I` operator for "the reasoning agent"

#### Agential Extension
- TikZ: "agent-indexing"
- README: "multi-agent reasoning"
- GLOSSARY: Combines ability and free choice operators

### 7. Text Prose Discrepancies

**On Reflection Extension requirements**:
- 00-Introduction.tex (line 206): "Requires at least one middle extension, positioned in parallel with the Agential Extension"
- README (line 69): "The Agential Extension requires at least one middle extension"
- GLOSSARY (line 16): "Agential Extension...requires middle extension"

**Discrepancy**: TikZ says Reflection requires middle extension; README says Agential requires it; both may be true but documentation is unclear.

### 8. Missing Elements by Source

**TikZ missing**:
- Knowledge operator (K) NOTE: remove this operator from consideration everywhere
- Able operator (generic ability) NOTE: remove this operator from consideration everywhere
- Since/Until operators NOTE: it does have these already but uses 'S' and 'U' instead of the correct symbols
- Relevance operator NOTE: this can be omitted

**README missing**:
- Social extension entirely
- Store/recall operators
- Mi/Mu epistemic modals
- Preference/explanation normative operators
- Quantifiers in foundation NOTE: quantifiers live in the Explanatory layer

**GLOSSARY missing**:
- Social extension NOTE: the glossary is for operators whereas the social extension is more theoretical
- Reduction operator
- dotcircleright (causal might)

## Decisions

Based on this analysis, the following decisions should be made during planning:

1. **Social extension**: Decide whether to add to GLOSSARY/README or remove from TikZ
2. **Choice operator symbols**: Standardize on either Perm/Forb or FP/FF
3. **Agent indexing**: Decide whether operators use subscript (B_a) or not (B)
4. **Reflection dependency**: Clarify if it requires middle extension, Epistemic specifically, or both
5. **Store/recall notation**: Standardize on whether index is superscript (uparrow^i) or described separately

## Recommendations

### Priority 1: Structural Alignment
1. **Resolve Agential/Reflection parallel vs sequential**: Update README ASCII diagram to show Agential/Reflection as parallel (matching TikZ) or update TikZ to show sequential
2. **Decide on Social extension**: Either add to README/GLOSSARY or remove from TikZ

### Priority 2: Operator Inventory Sync
1. **Create master operator list**: TikZ appears most complete; use as baseline
2. **Add missing operators to GLOSSARY**: K (knowledge), reduction, dotcircleright
3. **Add missing operators to README**: Store/recall, since/until, Mi/Mu

### Priority 3: Symbol Standardization
1. **Standardize Choice symbols**: Recommend GLOSSARY notation (FP/FF/Ch) as more semantically clear
2. **Standardize agent indexing**: Recommend subscript notation (B_a) for clarity
3. **Update TikZ to match**: Change Perm to FP, Forb to FF

### Priority 4: Prose Alignment
1. **Clarify extension dependencies**: Create consistent statement about what each extension requires
2. **Sync descriptions**: Ensure Agential/Reflection descriptions match across all three

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Changes to TikZ require LaTeX rebuild | Medium | Test PDF generation after changes |
| Symbol changes may affect other docs | Medium | Search for affected references before changing |
| Removing Social extension loses information | Low | Document rationale in commit message |
| README diagram complexity | Low | Keep ASCII simple; refer to LaTeX for details |

## Appendix

### Files Analyzed

1. `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/00-Introduction.tex`
   - Lines 1-259
   - TikZ diagram: lines 27-168
   - Layer descriptions: lines 183-207

2. `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/reference/GLOSSARY.md`
   - Lines 1-268
   - Extension architecture table: lines 9-19
   - Operator tables: lines 21-164

3. `/home/benjamin/Projects/ProofChecker/README.md`
   - Lines 1-365
   - ASCII diagram: lines 13-49
   - Extension descriptions: lines 51-68

### Search Queries Used

- File reads for all three sources
- Glob search for GLOSSARY location
- Grep search for task 493 description
