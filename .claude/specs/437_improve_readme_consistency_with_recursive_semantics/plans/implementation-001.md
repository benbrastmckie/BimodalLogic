# Implementation Plan: Task #437

- **Task**: 437 - Improve README consistency with recursive-semantics.md
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/437_improve_readme_consistency_with_recursive_semantics/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan addresses redundancies, internal discrepancies, and the missing ModelChecker reference in the Logos README.md. The approach consolidates overlapping content by replacing duplicated material with concise summaries and cross-references to authoritative documentation (recursive-semantics.md). The implementation follows a prioritized sequence: first adding the high-value ModelChecker reference, then eliminating major redundancy (the Extension Architecture diagram), fixing internal inconsistencies, and finally completing the operator reference table.

### Research Integration

The research identified 5 major redundancies, 5 internal discrepancies, and a critical gap (no ModelChecker mention). Key findings:
- Extension Architecture diagram is nearly identical between README and recursive-semantics.md (~30 duplicate lines)
- Symbol notation inconsistencies (spelled-out vs Unicode symbols)
- Implementation Status table misalignments with actual file names
- Incomplete Operator Reference (missing causal, derived temporal, actuality predicate, universal quantifier)
- Complete absence of ModelChecker parallel implementation reference

## Goals & Non-Goals

**Goals**:
- Add prominent ModelChecker reference and link to https://github.com/benbrastmckie/ModelChecker
- Reduce redundancy by replacing duplicated Extension Architecture diagram with summary + link
- Fix all symbol notation inconsistencies in operator tables
- Correct Implementation Status table to match actual file names
- Complete Operator Reference with missing operators or note incompleteness
- Fix directory structure path error

**Non-Goals**:
- Modifying recursive-semantics.md (that is the authoritative source)
- Modifying layer-extensions.md (separate concern)
- Adding new content beyond what's documented in research
- Restructuring the entire README (only targeted improvements)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking internal links | Medium | Low | Verify all links after changes |
| Removing too much context | Medium | Medium | Keep brief intuitive descriptions, just remove duplication |
| Introducing new inconsistencies | Low | Low | Cross-check all symbols against recursive-semantics.md |

## Implementation Phases

### Phase 1: Add ModelChecker Reference [COMPLETED]

**Goal**: Address the critical gap by adding prominent mention of the parallel ModelChecker implementation

**Tasks**:
- [ ] Add ModelChecker paragraph to "About Logos" section (after line 12)
- [ ] Add ModelChecker entry to "Related Documentation" section (after line 215)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Add 2 new sections

**Steps**:
1. In "About Logos" section, after the bullet list ending at line 12, add a new paragraph explaining the dual implementation approach (Lean proof-checker + Python/Z3 model-checker)
2. In "Related Documentation" section, add a new "Related Projects" subsection with link to ModelChecker repository

**New content for About Logos** (after line 12):
```markdown
Logos is developed in parallel across two implementations:
- **Proof-checker** (this repository): Lean 4 formal verification of logical axioms and inference rules
- **Model-checker**: [ModelChecker](https://github.com/benbrastmckie/ModelChecker) - Z3-based semantic verification for countermodel search
```

**New content for Related Documentation** (new subsection):
```markdown
### Related Projects

- **[ModelChecker](https://github.com/benbrastmckie/ModelChecker)** - Python/Z3 implementation for semantic verification and countermodel search
```

**Verification**:
- Link to ModelChecker repository is accessible
- New text accurately describes the dual implementation approach
- Integration with existing README structure is natural

---

### Phase 2: Consolidate Extension Architecture [NOT STARTED]

**Goal**: Remove redundant 30-line ASCII diagram, replace with concise summary and link

**Tasks**:
- [ ] Replace Extension Architecture diagram (lines 29-59) with brief summary
- [ ] Add cross-reference to recursive-semantics.md for full diagram

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Replace lines 29-61 with condensed version

**Steps**:
1. Remove the full ASCII diagram from README (lines 29-59)
2. Replace with concise 3-4 sentence summary of the architecture
3. Add link to recursive-semantics.md for the full diagram and formal details

**New content to replace diagram**:
```markdown
### Extension Architecture

Logos follows a layered semantic architecture:

1. **Constitutive Foundation** (required) - Hyperintensional semantics with bilateral propositions over mereological state spaces
2. **Explanatory Extension** (required) - Adds temporal structure and task relation for modal, temporal, and counterfactual reasoning
3. **Middle Extensions** (optional) - Epistemic, Normative, and Spatial modules that can be combined
4. **Agential Extension** - Multi-agent reasoning (requires at least one middle extension)

See [recursive-semantics.md](docs/research/recursive-semantics.md) for the full dependency diagram and formal semantic specifications.
```

**Verification**:
- README still conveys the layered architecture concept
- Link to recursive-semantics.md is correct and functional
- Reduced README by ~25 lines

---

### Phase 3: Fix Symbol Notation [NOT STARTED]

**Goal**: Ensure consistent symbol notation throughout operator tables

**Tasks**:
- [ ] Fix modal operator symbols (replace "box"/"diamond" with consistent notation)
- [ ] Fix temporal operator symbols (replace "triangleleft"/"triangleright")
- [ ] Fix counterfactual operator symbol (replace "box-arrow")
- [ ] Standardize all store/recall and identity operator symbols

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Edit operator tables (lines 144-179)

**Steps**:
1. Review recursive-semantics.md for authoritative symbol notation
2. Update Modal Operators table (lines 144-148):
   - "box" -> use descriptive notation consistent with codebase or ASCII-safe alternative
   - "diamond" -> same treatment
3. Update Temporal Operators table (lines 150-159):
   - "triangleleft" -> use consistent notation (research shows layer-extensions.md uses "A S B")
   - "triangleright" -> same treatment
4. Update Counterfactual table (lines 161-165):
   - "box-arrow" -> consistent notation
5. Update Store/Recall table (lines 167-172):
   - Verify "uparrow^i"/"downarrow^i" match authoritative docs
6. Update Identity table (lines 174-179):
   - Verify "equiv", "sqsubseteq", "leq" notation

**Symbol standardization (based on recursive-semantics.md and layer-extensions.md)**:
| Current | Replacement |
|---------|-------------|
| box | [] or Box |
| diamond | <> or Dia |
| triangleleft | S (since) |
| triangleright | U (until) |
| box-arrow | []-> |
| uparrow^i | Up^i |
| downarrow^i | Down^i |

**Verification**:
- All symbols are consistently notated
- Symbols match those used in recursive-semantics.md where possible
- Tables are readable and clear

---

### Phase 4: Fix Implementation Status Table [NOT STARTED]

**Goal**: Align Implementation Status table with actual file names and clarify component organization

**Tasks**:
- [ ] Fix "Explanatory/truthAt" label to match actual file name (Truth.lean)
- [ ] Clarify Foundation vs Foundation/Semantics distinction
- [ ] Add note about ModelChecker implementation status

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Edit Implementation Status table (lines 99-112)

**Steps**:
1. Change "Explanatory/truthAt" to "Explanatory/Truth" (matches Truth.lean)
2. Merge or clarify Foundation and Foundation/Semantics rows since Semantics.lean is under Foundation/
3. Add a note or footnote about parallel ModelChecker implementation status

**Updated table structure**:
```markdown
| Component | Status | Description |
|-----------|--------|-------------|
| **Foundation** | Complete | ConstitutiveFrame, lattice operations, bilateral propositions, Semantics (verifies/falsifies) |
| **Explanatory/Frame** | Complete | CoreFrame with task relation, state modality definitions |
| **Explanatory/WorldHistory** | Complete | Convex domains, task-respecting functions |
| **Explanatory/Truth** | Complete | All operators except causal (stub) |
| **Causal operator** | Stub | Awaiting specification |
| **Epistemic** | Stub | Placeholder namespace |
| **Normative** | Stub | Placeholder namespace |
| **Spatial** | Stub | Placeholder namespace |

*Note: Parallel implementation in [ModelChecker](https://github.com/benbrastmckie/ModelChecker) covers Constitutive Foundation and Explanatory Extension.*
```

**Verification**:
- All component names match actual file names in directory structure
- Table accurately reflects current implementation status
- ModelChecker reference is present

---

### Phase 5: Complete Operator Reference [NOT STARTED]

**Goal**: Add missing operators or explicitly note that reference is a subset

**Tasks**:
- [ ] Add missing operators: Causal, derived temporal (always/sometimes), Actuality predicate, Universal quantifier
- [ ] Or add note that this is a quick reference subset

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Extend operator tables (lines 140-179)

**Steps**:
1. Review recursive-semantics.md for complete operator list
2. Add missing operators to appropriate sections:
   - **Causal**: A causes B (documented in layer-extensions.md as "A []-> B")
   - **Derived Temporal**: Always (triangle A), Sometimes (nabla A)
   - **Actuality Predicate**: Act(t) - state is part of current world-state
   - **Universal Quantifier**: forall y.A
3. Add introductory note clarifying this is a quick reference

**New sections to add**:

```markdown
## Operators Reference

*This section provides a quick reference for commonly-used operators. See [recursive-semantics.md](docs/research/recursive-semantics.md) for complete formal definitions and truth conditions.*

### Modal Operators
...

### Derived Temporal Operators

| Operator | Symbol | Reading |
|----------|--------|---------|
| Always | Alw A | "At all times A" - HA and A and GA |
| Sometimes | Som A | "At some time A" - PA or A or FA |

### Quantifiers and Predicates

| Operator | Symbol | Reading |
|----------|--------|---------|
| Universal | forall y.A | "For all states y, A holds" |
| Actuality | Act(t) | "t is part of the current world-state" |

### Causal Operators

| Operator | Symbol | Reading |
|----------|--------|---------|
| Causation | A o-> B | "A causes B" (stub - awaiting specification) |
```

**Verification**:
- All major operators from recursive-semantics.md are represented or noted
- Clear indication that full definitions are in recursive-semantics.md
- Causal operator marked as stub consistent with Implementation Status

---

### Phase 6: Fix Directory Structure and Minor Issues [NOT STARTED]

**Goal**: Correct directory path and add cross-reference to layer-extensions.md

**Tasks**:
- [ ] Fix directory structure path (Logos/SubTheories/ -> relative or full path)
- [ ] Add cross-reference to layer-extensions.md in Related Documentation

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/README.md` - Fix line 116, add to Related Documentation

**Steps**:
1. Update directory structure header (line 116) to use relative path from README location
2. Add layer-extensions.md to Related Documentation for application examples

**Changes**:
- Line 116: Change `Logos/SubTheories/` to `SubTheories/` (relative from README)
- Add to Related Documentation - Specification section:
  ```markdown
  - **[layer-extensions.md](docs/research/layer-extensions.md)** - Extension architecture overview with application examples
  ```

**Verification**:
- Directory structure path is accurate relative to README location
- Cross-reference to layer-extensions.md is functional
- All links in Related Documentation work

---

## Testing & Validation

- [ ] All internal links in README.md are functional
- [ ] Link to ModelChecker repository (https://github.com/benbrastmckie/ModelChecker) works
- [ ] Link to recursive-semantics.md works
- [ ] Link to layer-extensions.md works
- [ ] Operator symbols are consistent throughout
- [ ] Implementation Status table matches actual file names
- [ ] Directory structure matches actual paths

## Artifacts & Outputs

- Modified: `Theories/Logos/README.md` (primary deliverable)
- No new files created
- Estimated line change: -30 lines (diagram removal), +40 lines (new content), net +10 lines

## Rollback/Contingency

If implementation introduces issues:
1. Git revert the commit
2. Review specific phase that caused problems
3. Re-implement that phase with adjustments

All changes are to a single file (README.md) so rollback is straightforward via git.
