# Implementation Plan: Task #334

**Task**: Create LaTeX documentation for Logos system mirroring layer structure
**Version**: 003
**Created**: 2026-01-10
**Language**: general

## Overview

This plan creates LaTeX reference documentation for the Logos system based on RECURSIVE_SEMANTICS.md (the authoritative specification). Unlike the prior plans (v001, v002) which extracted content from LogicNotes.tex, this version uses RECURSIVE_SEMANTICS.md as the primary source document, creating documentation that directly maps to the current semantic specification and will serve as a guide for future Lean 4 refactoring.

**Key differences from v001/v002**:
1. Primary source is RECURSIVE_SEMANTICS.md (591 lines), not LogicNotes.tex
2. Uses new extension architecture (Constitutive Foundation → Core Extension → modular extensions)
3. Includes complete content for two well-specified layers, stub content for four future extensions
4. Designed for parallel LaTeX/Lean development

## Phases

### Phase 1: Directory Structure and Style Files

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Create Documentation/LaTeX/ directory structure
2. Copy and adapt style files from LogicNotes source
3. Create logos-notation.sty with RECURSIVE_SEMANTICS.md notation

**Files to create**:
- `Documentation/LaTeX/` - root directory
- `Documentation/LaTeX/subfiles/` - subfile directory
- `Documentation/LaTeX/assets/` - style files
- `Documentation/LaTeX/bibliography/` - bibliography files
- `Documentation/LaTeX/assets/logos-notation.sty` - custom notation macros

**Steps**:
1. Create directory structure:
   ```
   Documentation/LaTeX/
   ├── subfiles/
   ├── assets/
   └── bibliography/
   ```
2. Copy from /home/benjamin/Projects/Philosophy/Teaching/LogicNotes/:
   - `assets/formatting.sty` → `assets/formatting.sty`
   - `assets/notation.sty` → `assets/notation.sty` (for reference)
   - `assets/bib_style.bst` → `assets/bib_style.bst`
   - `LogicNotes.bib` → `bibliography/LogosReferences.bib`
3. Create `logos-notation.sty` with macros from research-003.md:
   - Constitutive Foundation macros (verification, falsification, bilateral props)
   - Core Extension macros (task relation, world-history, modalities)
   - Cross-reference macro `\leansrc{Module}{definition}`

**Verification**:
- [ ] Directory structure exists
- [ ] Style files copied and compile without errors
- [ ] logos-notation.sty contains all macros from research-003.md

---

### Phase 2: Main Document and Introduction

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Create LogosReference.tex main document with subfile architecture
2. Create 00-Introduction.tex from RECURSIVE_SEMANTICS.md lines 10-62

**Files to modify**:
- `Documentation/LaTeX/LogosReference.tex` - create
- `Documentation/LaTeX/subfiles/00-Introduction.tex` - create

**Steps**:
1. Create LogosReference.tex with:
   - Document class settings
   - Package imports including logos-notation.sty
   - Title page configuration
   - Table of contents
   - Subfile includes (with commented placeholders for future extensions)
   - Bibliography
2. Create 00-Introduction.tex extracting:
   - Semantic frame concept
   - Extension dependency diagram (ASCII → TikZ)
   - Layer descriptions
   - Purpose of document

**Content source**: RECURSIVE_SEMANTICS.md lines 10-62

**Verification**:
- [ ] LogosReference.tex compiles with just 00-Introduction
- [ ] Extension dependency diagram renders correctly
- [ ] Introduction explains semantic frame progression

---

### Phase 3: Constitutive Foundation Subfile

**Estimated effort**: 2 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create 01-ConstitutiveFoundation.tex from RECURSIVE_SEMANTICS.md lines 65-225
2. Include all verification/falsification clauses
3. Include bilateral proposition operations

**Files to modify**:
- `Documentation/LaTeX/subfiles/01-ConstitutiveFoundation.tex` - create

**Steps**:
1. Create section structure per research-003.md:
   - 1. Syntactic Primitives (lines 69-78)
   - 2. Constitutive Frame (lines 80-94)
   - 3. Constitutive Model (lines 96-114)
   - 4. Variable Assignment (lines 116-124)
   - 5. Verification and Falsification Clauses (lines 126-179)
   - 6. Derived Relations (lines 181-197)
   - 7. Bilateral Propositions (lines 199-214)
   - 8. Logical Consequence (lines 216-224)

2. For each section, extract:
   - Definitions using `\begin{definition}...\end{definition}`
   - Tables using `tabular` environment
   - Formulas using `align` environment
   - Remarks using `\begin{remark}...\end{remark}`

3. Add Lean cross-references:
   - `\leansrc{Logos.Foundation.Frame}{ConstitutiveFrame}`
   - `\leansrc{Logos.Foundation.Semantics}{verifies}`
   - etc. (placeholders for future implementation)

**Content source**: RECURSIVE_SEMANTICS.md lines 65-225

**Verification**:
- [ ] All 7 verification/falsification clause types included
- [ ] Bilateral proposition operations (product, sum, ¬, ∧, ∨) defined
- [ ] Essence and Ground defined via propositional identity
- [ ] Subfile compiles independently

---

### Phase 4: Core Extension Subfiles

**Estimated effort**: 2.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create 02-CoreExtension-Syntax.tex (syntactic primitives)
2. Create 03-CoreExtension-Semantics.tex (frames, models, truth conditions)
3. Create 04-CoreExtension-Axioms.tex (counterfactual logic axioms)

**Files to modify**:
- `Documentation/LaTeX/subfiles/02-CoreExtension-Syntax.tex` - create
- `Documentation/LaTeX/subfiles/03-CoreExtension-Semantics.tex` - create
- `Documentation/LaTeX/subfiles/04-CoreExtension-Axioms.tex` - create

**Steps**:

**02-CoreExtension-Syntax.tex** (from lines 233-240):
1. Additional syntactic primitives:
   - Modal operators (□, ◇)
   - Temporal operators (H, G, P, F)
   - Extended temporal operators (◁, ▷)
   - Counterfactual conditional (□→)
   - Store/recall operators (↑ⁱ, ↓ⁱ)

**03-CoreExtension-Semantics.tex** (from lines 243-438):
1. Core Frame definition (lines 245-252)
2. State Modality Definitions (lines 255-267)
3. Task Relation Constraints (lines 269-279)
4. World-History (lines 281-289)
5. Core Model (lines 291-295)
6. Truth Conditions (lines 297-411):
   - Atomic sentences
   - Lambda abstraction
   - Universal quantifier + Actuality predicate
   - Extensional connectives
   - Modal operators
   - Core tense operators
   - Extended tense operators (Since, Until)
   - Counterfactual conditional
   - Store/recall operators
7. Bimodal Interaction Principles P1-P6 (lines 412-424)
8. Temporal Frame Constraints (lines 425-435)
9. Logical Consequence (lines 436-438)

**04-CoreExtension-Axioms.tex** (from lines 440-464):
1. Core Rules (R1)
2. Core Axioms (C1-C7)
3. Modal Axioms (M1-M5)

**Content source**: RECURSIVE_SEMANTICS.md lines 228-464

**Verification**:
- [ ] All 6 task relation constraints included
- [ ] All 6 perpetuity principles (P1-P6) included
- [ ] Counterfactual conditional with mereological formulation
- [ ] Store/recall operators with temporal index
- [ ] All 12 axiom schemata included
- [ ] Each subfile compiles independently

---

### Phase 5: Extension Stub Subfiles

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Create stub subfiles for Epistemic, Normative, Spatial, Agential extensions
2. Preserve [DETAILS] and [QUESTION: ...] markers from source

**Files to modify**:
- `Documentation/LaTeX/subfiles/05-Epistemic.tex` - create
- `Documentation/LaTeX/subfiles/06-Normative.tex` - create
- `Documentation/LaTeX/subfiles/07-Spatial.tex` - create
- `Documentation/LaTeX/subfiles/08-Agential.tex` - create

**Steps**:
1. For each extension stub:
   - Add section header with "[Details pending development]"
   - Include brief description from RECURSIVE_SEMANTICS.md
   - List planned operators in table format
   - Preserve [QUESTION: ...] tags as LaTeX `question` environment
   - Add placeholder for frame extension
   - Add placeholder for semantic clauses

2. Specific content:
   - 05-Epistemic.tex: B_a, K_a, Pr operators (lines 467-496)
   - 06-Normative.tex: O, P, ≻ operators (lines 499-528)
   - 07-Spatial.tex: Here, Somewhere, Everywhere, Near operators (lines 531-557)
   - 08-Agential.tex: Multi-agent operators (lines 560-576)

**Content source**: RECURSIVE_SEMANTICS.md lines 467-576

**Verification**:
- [ ] Each stub has consistent structure
- [ ] [QUESTION: ...] tags preserved as LaTeX `question` environment
- [ ] Dependency note in Agential stub (requires Epistemic/Normative/Spatial)
- [ ] Each subfile compiles independently

---

### Phase 6: Final Assembly and Validation

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Assemble complete document
2. Validate compilation
3. Review formatting and consistency
4. Generate PDF

**Files to modify**:
- `Documentation/LaTeX/LogosReference.tex` - update subfile includes
- All subfiles - final review

**Steps**:
1. Update LogosReference.tex to include all subfiles:
   ```latex
   \subfile{subfiles/00-Introduction}
   \subfile{subfiles/01-ConstitutiveFoundation}
   \subfile{subfiles/02-CoreExtension-Syntax}
   \subfile{subfiles/03-CoreExtension-Semantics}
   \subfile{subfiles/04-CoreExtension-Axioms}
   % Future extensions (uncomment when content developed):
   % \subfile{subfiles/05-Epistemic}
   % \subfile{subfiles/06-Normative}
   % \subfile{subfiles/07-Spatial}
   % \subfile{subfiles/08-Agential}
   ```
2. Run full compilation:
   ```bash
   cd Documentation/LaTeX
   pdflatex LogosReference.tex
   bibtex LogosReference
   pdflatex LogosReference.tex
   pdflatex LogosReference.tex
   ```
3. Review generated PDF for:
   - Consistent notation throughout
   - Proper cross-references
   - Table formatting
   - Mathematical alignment
   - Page breaks
4. Fix any compilation warnings or errors
5. Verify page count (expected: 20-30 pages)

**Verification**:
- [ ] Full document compiles without errors
- [ ] No unresolved cross-references
- [ ] Table of contents generated correctly
- [ ] Bibliography renders correctly
- [ ] PDF generated and reviewed

---

## Dependencies

- Access to source directory `/home/benjamin/Projects/Philosophy/Teaching/LogicNotes/`
- LaTeX distribution with subfiles package
- RECURSIVE_SEMANTICS.md (already present in repo)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Style file incompatibility | Med | Low | Copy minimal set, adapt as needed |
| Notation inconsistency | High | Med | Use logos-notation.sty exclusively |
| Missing LaTeX packages | Low | Low | Document requirements in README |
| Content gaps in source | Med | Low | Preserve [DETAILS] markers |

## Success Criteria

- [ ] Documentation/LaTeX/ directory structure created
- [ ] logos-notation.sty contains all required macros
- [ ] 9 subfiles created (00-Introduction through 08-Agential)
- [ ] Complete content for Constitutive Foundation and Core Extension
- [ ] Stub content for 4 future extensions with preserved markers
- [ ] Full document compiles to PDF without errors
- [ ] Notation consistent with RECURSIVE_SEMANTICS.md
- [ ] Lean cross-reference placeholders included

## Rollback Plan

If implementation fails:
1. Delete Documentation/LaTeX/ directory
2. Revert any changes to other files
3. Document issues encountered for future attempt

## Notes

This plan supersedes implementation-001.md and implementation-002.md which were based on LogicNotes.tex extraction. The new approach:
1. Uses RECURSIVE_SEMANTICS.md as authoritative source
2. Creates documentation parallel to planned Lean refactoring
3. Supports incremental extension development via stub files

Total estimated effort: 8.5 hours

---

**End of Implementation Plan**
