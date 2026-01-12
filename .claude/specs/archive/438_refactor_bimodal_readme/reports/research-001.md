# Research Report: Task #438

**Task**: Refactor Bimodal README for systematic documentation
**Date**: 2026-01-12
**Focus**: Draw on BimodalReference.tex and Lean code to prepare relevant information for refactor

## Summary

Comprehensive analysis of the Bimodal theory documentation structure, comparing the current README.md against the authoritative BimodalReference.tex and actual Lean implementation. The BimodalReference.tex provides an excellent organizational template with systematic coverage of syntax, semantics, proof theory, and metalogic that the README should mirror at a higher level while linking to the detailed reference.

## Findings

### 1. BimodalReference.tex Structure Analysis

The LaTeX reference document is well-organized into 6 sections:

| Section | Content | Lines |
|---------|---------|-------|
| 00-Introduction | Overview, project structure, implementation status | 29 |
| 01-Syntax | Formulas, derived operators, temporal duality | 115 |
| 02-Semantics | Task frames, world histories, truth conditions, validity | 175 |
| 03-ProofTheory | 14 axiom schemata, 7 inference rules, derivation trees | 196 |
| 04-Metalogic | Soundness, deduction theorem, completeness infrastructure | 128 |
| 05-Theorems | Perpetuity P1-P6, modal S5/S4, propositional theorems | 176 |
| 06-Notes | Implementation status, discrepancy notes, source files | 93 |

**Key strengths of the LaTeX structure**:
- Clear separation of syntax, semantics, and proof theory
- Tables mapping mathematical notation to Lean code
- Explicit implementation status tracking
- Discrepancy notes between paper and implementation

### 2. Current README.md Analysis

The current README (234 lines) contains good content but lacks systematic organization:

**Strengths**:
- Links to theory-specific documentation (docs/)
- Submodule descriptions with file locations
- Quick reference section for finding functionality
- Development guidelines

**Weaknesses**:
- No direct syntax/semantics/proof theory presentation (defers entirely to other docs)
- No link to BimodalReference.pdf/tex (critical omission per task description)
- Redundant with bimodal-logic.md in several places
- Implementation status section duplicates docs/project-info/IMPLEMENTATION_STATUS.md
- Navigation section at bottom is overly complex

### 3. Lean Implementation Correspondence

Verified mapping between BimodalReference.tex and actual Lean code:

#### Syntax (Formula.lean)
- 6 primitive constructors: `atom`, `bot`, `imp`, `box`, `all_past`, `all_future`
- Derived operators: `neg`, `and`, `or`, `diamond`, `some_past`, `some_future`, `always`, `sometimes`
- `swap_temporal` function with involution theorem

#### Proof System (Axioms.lean)
- 14 axiom schemata (correctly documented):
  - Propositional: `prop_k`, `prop_s`, `ex_falso`, `peirce`
  - Modal S5: `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`
  - Temporal: `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`
  - Interaction: `modal_future`, `temp_future`

#### Derivation (Derivation.lean)
- 7 inference rules: `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`
- `DerivationTree` as `Type` (not `Prop`) for computability
- Computable `height` function for well-founded recursion

#### Semantics (TaskFrame.lean, WorldHistory.lean, Truth.lean, Validity.lean)
- `TaskFrame T` structure with world states, task relation, nullity, compositionality
- `WorldHistory` with convex domain and task relation respect
- `TaskModel` with valuation function
- `truth_at` recursive definition for all 6 primitive constructors
- `valid` definition quantifying over all models/histories/times

### 4. Documentation Gaps

**Missing from README that should be added**:
1. Link to BimodalReference.pdf and BimodalReference.tex (explicit task requirement)
2. Brief inline presentation of the logic (not just links)
3. Formal specification summary (operators table with notation)
4. Implementation status summary aligned with LaTeX

**Documentation that should be consolidated**:
1. bimodal-logic.md and README overlap on comparison with Logos
2. Multiple places describe the same axioms
3. Implementation status appears in 3+ locations

### 5. BimodalReference.tex Key Content to Adapt

**Syntax section adaptable content**:
```
Primitives: p, bot, imp, box, all_past, all_future
Derived: neg, and, or, diamond, some_past, some_future, always, sometimes
```

**Axiom summary table (from 03-ProofTheory)**:
| Axiom | Pattern | Lean |
|-------|---------|------|
| K | Distribution | prop_k |
| S | Weakening | prop_s |
| EFQ | Explosion | ex_falso |
| Peirce | Classical | peirce |
| MT | Reflexivity | modal_t |
| M4 | Transitivity | modal_4 |
| MB | Symmetry | modal_b |
| M5 | S5 collapse | modal_5_collapse |
| MK | Modal distribution | modal_k_dist |
| TK | Temporal distribution | temp_k_dist |
| T4 | Temporal transitivity | temp_4 |
| TA | Connectedness | temp_a |
| TL | Introspection | temp_l |
| MF | Modal-future | modal_future |
| TF | Temporal-modal | temp_future |

**Perpetuity Principles (from 05-Theorems)**:
| Principle | Statement |
|-----------|-----------|
| P1 | necessity implies always |
| P2 | sometimes implies possible |
| P3 | necessity of perpetuity |
| P4 | possibility of occurrence |
| P5 | persistent possibility |
| P6 | occurrent necessity is perpetual |

### 6. Reference Document Availability

**BimodalReference files**:
- LaTeX source: `Theories/Bimodal/latex/BimodalReference.tex`
- PDF output: `Theories/Bimodal/latex/BimodalReference.pdf` (exists per git status)
- Supporting files: `latex/subfiles/`, `latex/bimodal-notation.sty`, `latex/formatting.sty`

## Recommendations

### Structure for Refactored README

1. **Header Section** (5-10 lines)
   - One-line description of TM logic
   - Link to BimodalReference.pdf with format: **BimodalReference** ([tex](latex/BimodalReference.tex) | [pdf](latex/BimodalReference.pdf))

2. **Overview Section** (15-20 lines)
   - Brief classification (propositional intensional logic)
   - Semantic primitives (world-states, times, task relation)
   - Key properties (S5 modal + linear temporal)

3. **Quick Syntax Reference** (condensed table)
   - 6 primitives with notation and reading
   - Key derived operators

4. **Proof System Overview** (condensed table)
   - 14 axioms grouped by category
   - 7 inference rules with descriptions

5. **Semantics Overview** (10-15 lines)
   - Task frame structure
   - Truth conditions summary
   - Link to BimodalReference for details

6. **Implementation Status** (table)
   - Component status (Complete/Partial/Pending)
   - Remove detailed bullets, link to IMPLEMENTATION_STATUS.md

7. **Module Structure** (keep existing, condense)
   - Layer architecture
   - File locations

8. **Documentation Links** (consolidate)
   - Primary: BimodalReference.pdf
   - User guides: Quickstart, Tutorial, Examples
   - Reference: Axioms, Tactics, Operators
   - Research: bimodal-logic.md (comparison with Logos)

9. **Building and Development** (keep existing, condense)

### Key Changes

1. **Add BimodalReference link prominently** at top
2. **Add inline syntax/semantics/proof theory summaries** (compact tables)
3. **Remove redundancy** with bimodal-logic.md (link instead)
4. **Consolidate implementation status** into single table
5. **Simplify navigation** section

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/BimodalReference.tex` - Main LaTeX source
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/subfiles/` - Section subfiles
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/README.md` - Current README
- `/home/benjamin/Projects/ProofChecker/docs/research/bimodal-logic.md` - Comparison document
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Syntax implementation
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Axiom definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Derivation.lean` - Derivation trees
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` - Semantic structures

## Next Steps

1. Run `/plan 438` to create implementation plan based on these findings
2. Implementation should follow the recommended structure above
3. Verify BimodalReference.pdf exists and is current before linking
