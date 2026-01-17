# Implementation Plan: Task #430

**Task**: Refactor documentation to present ProofChecker as general framework
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Refactor README.md and docs/README.md to present ProofChecker as a framework supporting multiple theories while maintaining Logos as the primary focus. Present Bimodal as an excellent starting point and point of comparison developed in parallel with Logos, highlighting Logos's hyperintensional foundation and greater expressive power.

**Key framing per user guidance**:
- Logos remains the emphasized theory throughout
- Bimodal (purely intensional) vs Logos (hyperintensional) contrast demonstrates advantages
- Bimodal serves as starting point and comparison baseline
- The contrast shows hyperintensional semantics supports wider range of operators

## Phases

### Phase 1: Root README.md Framework Introduction

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Update title and opening to present as framework while keeping Logos focus
2. Add early "Supported Theories" section presenting both theories with Logos emphasis
3. Add theory comparison link prominently
4. Keep existing Logos content largely intact

**Files to modify**:
- `README.md` - Add framework framing, theory overview table

**Steps**:
1. Update title from "Logos: Verified Reasoning..." to "Logos: A Framework for Verified Formal Logic in Lean 4" (keeps Logos in title)
2. Revise opening paragraph to present as framework that currently implements Logos with Bimodal as comparison
3. Add "Supported Theories" table after opening showing:
   - Logos (hyperintensional, primary) with status and documentation link
   - Bimodal (intensional, comparison baseline) with status and documentation link
4. Add sentence emphasizing Bimodal/Logos contrast demonstrates hyperintensional advantages
5. Add prominent link to docs/research/theory-comparison.md
6. Keep all existing Logos-focused content (layers, operators, axioms)

**Edits to README.md**:

```markdown
# Current title (line 1):
# Logos: Verified Reasoning in a Formal Language of Thought

# New title:
# Logos: A Framework for Verified Formal Logic in Lean 4
```

```markdown
# After line 3 (current opening paragraph), insert new framing paragraph:

**Logos** is a formal verification framework in Lean 4 implementing hyperintensional logics for verified AI reasoning. The project develops two theories in parallel:

| Theory | Foundation | Status | Focus |
|--------|------------|--------|-------|
| **Logos** | Hyperintensional | Active | Primary research direction with layered extensions |
| **Bimodal** | Intensional (TM logic) | Complete | Starting point and comparison baseline |

The contrast between Bimodal's purely intensional semantics and Logos's hyperintensional foundation demonstrates the advantages of hyperintensional semantics for supporting a wide range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

**See also**: [Theory Comparison](docs/research/theory-comparison.md) for detailed differences
```

```markdown
# Update existing opening paragraph (line 3) to be secondary:
The Logos theory is an extensible formal language equipped with...
```

**Verification**:
- README.md renders correctly with new structure
- Both theories are presented early with Logos emphasis maintained
- Links to theory-comparison.md work
- Existing Logos content preserved intact

---

### Phase 2: Update Bimodal Section as Comparison Baseline

**Estimated effort**: 0.75 hours
**Status**: [COMPLETED]

**Objectives**:
1. Rename "Causal Layer (TM Logic)" to clarify Bimodal as standalone comparison theory
2. Position Bimodal as excellent starting point developed in parallel
3. Highlight what Bimodal demonstrates about intensional semantics

**Files to modify**:
- `README.md` - Update Bimodal section framing

**Steps**:
1. Find "## Causal Layer (TM Logic)" section (around line 99)
2. Rename to "## Bimodal Theory (TM Logic)"
3. Add opening paragraph positioning as starting point and comparison:
   ```markdown
   The Bimodal theory implements TM (Tense and Modality) logic as a complete,
   self-contained intensional logic. Developed in parallel with Logos, Bimodal
   serves as an excellent starting point for understanding modal-temporal
   reasoning and as a comparison baseline demonstrating the boundaries of purely
   intensional semantics.
   ```
4. Keep all existing operator and axiom content
5. Add closing note: "For hyperintensional extensions beyond Bimodal's intensional semantics, see the Logos theory layers."

**Verification**:
- Bimodal section clearly positioned as comparison baseline
- All operator/axiom content preserved
- Clear path from Bimodal to Logos for readers wanting more

---

### Phase 3: Enhance Logos Section with Hyperintensional Contrast

**Estimated effort**: 0.75 hours
**Status**: [COMPLETED]

**Objectives**:
1. Strengthen Logos layer descriptions with hyperintensional emphasis
2. Clarify what hyperintensionality enables that Bimodal cannot express
3. Keep existing structure but enhance contrast messaging

**Files to modify**:
- `README.md` - Enhance Logos layer descriptions

**Steps**:
1. Find "## Constitutive Layer" section (around line 95)
2. Add paragraph connecting to hyperintensional foundation:
   ```markdown
   The Constitutive Layer leverages Logos's hyperintensional semantics to
   distinguish constitutive grounding from other necessary connections. Unlike
   intensional semantics where all necessary truths are equivalent,
   hyperintensional semantics captures that "being crimson grounds being red"
   differs from "2+2=4" even though both are necessary.
   ```
3. Similar enhancements to Causal, Epistemic, Normative layer descriptions
4. Ensure "Layered Architecture" table prominently shows this is Logos-specific

**Verification**:
- Each layer description shows hyperintensional advantage
- Contrast with Bimodal's intensional limitation is clear
- Logos remains primary focus throughout

---

### Phase 4: Update docs/README.md with Framework Context

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add "Framework Overview" section explaining multi-theory architecture
2. Enhance theory table with Logos emphasis
3. Add guidance on Bimodal as starting point
4. Ensure theory-comparison.md is prominently linked

**Files to modify**:
- `docs/README.md` - Add framework context, enhance theory guidance

**Steps**:
1. Add new section after line 7 "## Framework Overview":
   ```markdown
   ## Framework Overview

   ProofChecker implements formal logic theories in Lean 4 with shared
   infrastructure for syntax, proof systems, semantics, and metalogic. The
   project's primary focus is **Logos**, a hyperintensional logic supporting
   layered extensions for explanatory, epistemic, and normative reasoning.

   **Bimodal** provides a complete intensional logic (TM bimodal) that serves
   as an excellent starting point for newcomers and a comparison baseline
   demonstrating what purely intensional semantics can and cannot express.

   The contrast between theories illuminates the power of hyperintensional
   semantics for distinguishing necessarily equivalent propositions.
   ```
2. Update theory table to show Logos first with "(primary)" designation
3. Add "Getting Started" recommendation directing newcomers to Bimodal first, then Logos
4. Ensure theory-comparison.md link appears in multiple navigation sections

**Verification**:
- Framework context clearly explains multi-theory structure
- Logos emphasis maintained throughout
- Bimodal positioned as starting point
- All navigation links work

---

### Phase 5: Update docs/research/theory-comparison.md

**Estimated effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Enhance contrast between intensional and hyperintensional semantics
2. Position Bimodal as "developed in parallel" rather than "precursor"
3. Add section on what hyperintensionality enables

**Files to modify**:
- `docs/research/theory-comparison.md` - Enhance comparison content

**Steps**:
1. Update overview to mention parallel development
2. Add "Hyperintensional Advantages" section explaining what Logos can express that Bimodal cannot:
   - Propositional attitude distinctions (believing P vs believing necessarily-equivalent Q)
   - Explanatory relations (grounding, essence)
   - Fine-grained content beyond truth conditions
3. Ensure "When to Use Each" recommends Bimodal as starting point
4. Update any language suggesting Logos "will" do things to current tense where applicable

**Verification**:
- Comparison clearly shows advantages of hyperintensional approach
- Bimodal positioned as parallel development and starting point
- Document is balanced but Logos-emphasizing

---

### Phase 6: Verify Cross-References and Links

**Estimated effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Verify all new links work
2. Check consistency of messaging across files
3. Ensure no broken references from changes

**Files to modify**:
- None (verification only)

**Steps**:
1. Check all links in modified README.md
2. Check all links in modified docs/README.md
3. Check all links in modified theory-comparison.md
4. Verify Theories/README.md still accurate
5. Grep for any "TM logic" references that should be updated to "Bimodal"
6. Check for consistency in terminology

**Verification**:
- All links resolve correctly
- Terminology is consistent across documents
- No orphaned references

---

## Dependencies

- Research report at `specs/430_refactor_documentation_general_framework/reports/research-001.md` provides detailed analysis of current state

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing links | High | Phase 6 link verification |
| Diluting Logos emphasis | Medium | User guidance incorporated - maintain Logos throughout |
| Confusing existing users | Low | Clear framework narrative, gradual restructure |
| Inconsistent terminology | Medium | Phase 6 consistency check |

## Success Criteria

- [ ] README.md presents framework concept while keeping Logos emphasis
- [ ] Both Bimodal and Logos clearly presented with relationship explained
- [ ] Bimodal positioned as starting point and comparison baseline
- [ ] Hyperintensional advantages of Logos clearly articulated
- [ ] Theory-comparison.md prominently linked
- [ ] All cross-references work
- [ ] Existing Logos-focused content preserved
- [ ] Readers understand Bimodal/Logos contrast demonstrates hyperintensional power
