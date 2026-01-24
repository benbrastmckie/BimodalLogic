# Implementation Plan: Revise Lean Source Code for Logos Theory Definitions
- **Task**: 666 - Revise Lean Source Code for Logos Theory Definitions
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/666_revise_lean_source_code_logos_theory_definitions/reports/research-003.md (Set vs Prop mathematical equivalence analysis)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview
Research identified that while the Lean implementation uses `Set ((Fin n → State) → State)` and LaTeX uses `((Fin n → State) → State) → Prop`, these are mathematically equivalent in Lean 4 since `Set α := α → Prop`. The task is to update documentation to clarify this equivalence and improve code readability without changing the mathematical logic.

## Goals & Non-Goals
- **Goals**: 
  - Add explanatory comments in Lean source code about Set/Prop equivalence
  - Update LaTeX documentation to acknowledge Set-based formulation
  - Clean up outdated TODO comments in LaTeX
  - Document the design decision and mathematical reasoning
- **Non-Goals**:
  - Change mathematical logic or implementation (already correct)
  - Modify verification/falsification semantics
  - Alter mereological constraints implementation

## Risks & Mitigations
- Risk: Documentation changes might confuse users about the notation difference
  - Mitigation: Include clear explanation of mathematical equivalence and design rationale
- Risk: LaTeX updates might introduce formatting issues
  - Mitigation: Test LaTeX compilation after changes
- Risk: Comments might become outdated if implementation changes
  - Mitigation: Reference the mathematical definition, not specific implementation details

## Implementation Phases

### Phase 1: Update Lean Source Code Documentation [NOT STARTED]
- **Goal:** Add explanatory comments about Set/Prop equivalence in Interpretation.lean
- **Tasks:**
  - [ ] Add module-level comment explaining Set/Prop relationship in Lean 4
  - [ ] Update structure field comments to clarify equivalence with LaTeX predicates
  - [ ] Add remark about design decision (collectional vs logical emphasis)
  - [ ] Reference mathematical equivalence in documentation
- **Timing:** 45 minutes

### Phase 2: Update LaTeX Documentation [NOT STARTED]
- **Goal:** Acknowledge Set-based formulation in LaTeX specification
- **Tasks:**
  - [ ] Add explanatory footnote about Set/Prop equivalence in Lean 4
  - [ ] Update outdated TODO comment (line 70) to reflect current status
  - [ ] Add note about alternative mathematically equivalent formulation
  - [ ] Verify LaTeX compilation after changes
- **Timing:** 30 minutes

### Phase 3: Create Implementation Summary [NOT STARTED]
- **Goal:** Document changes and mathematical correctness verification
- **Tasks:**
  - [ ] Create implementation summary with before/after comparison
  - [ ] Document mathematical equivalence proof (Set α := α → Prop)
  - [ ] Include verification that no logic changes were made
  - [ ] Add guidance for future maintainers
- **Timing:** 15 minutes

## Testing & Validation
- [ ] Verify Lean code compiles without errors
- [ ] Check LaTeX document compiles correctly
- [ ] Confirm no changes to mathematical logic (lean-lsp verification)
- [ ] Validate documentation clarity and accuracy

## Artifacts & Outputs
- plans/implementation-001.md (this file)
- Updated: Theories/Logos/SubTheories/Foundation/Interpretation.lean
- Updated: Theories/Logos/latex/subfiles/01-ConstitutiveFoundation.tex
- summaries/implementation-summary-20260124.md

## Rollback/Contingency
- If LaTeX compilation fails: revert LaTeX changes, keep Lean documentation updates
- If Lean compilation fails: revert all changes to Interpretation.lean
- If documentation proves confusing: add additional clarifying examples