# Implementation Plan: Task #707

- **Task**: 707 - replace_propositional_atom_with_sentence_letter_in_bimodal
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Priority**: low
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Replace occurrences of "propositional atom" with "sentence letter" throughout the Bimodal reference documentation to achieve consistent terminology. The semantics chapter (02-semantics.typ) already uses "sentence letter", so this change aligns the syntax chapter (01-syntax.typ) and metalogic chapter (04-metalogic.typ) with that established convention.

### Research Integration

No formal research was conducted. The NOTE tag at line 20 of 01-syntax.typ explicitly requests this terminology change. The target terminology "sentence letter" is already consistently used in 02-semantics.typ (4 occurrences), confirming this is the project's preferred term.

## Goals & Non-Goals

**Goals**:
- Replace all instances of "propositional atom" with "sentence letter" in Bimodal Typst documentation
- Replace standalone "atom" references (in the metalogic context) with "sentence letter"
- Remove the NOTE tag that requested this change
- Maintain grammatical correctness in all modified sentences

**Non-Goals**:
- Changing the Lean code identifiers (e.g., `atom s` remains unchanged)
- Modifying the "Atom" constructor name in tables (this is a technical name)
- Changing terminology in other logic theories outside Bimodal

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent capitalization | L | L | Review each replacement in context |
| Breaking table alignment | L | L | Preview changes to ensure formatting preserved |

## Implementation Phases

### Phase 1: Update 01-syntax.typ [NOT STARTED]

**Goal**: Replace "propositional atom" terminology and remove the NOTE tag in the syntax chapter

**Tasks**:
- [ ] Line 17: Change "propositional atoms" to "sentence letters" in the Formula definition
- [ ] Line 20: Remove the NOTE comment (the change will be implemented)
- [ ] Line 31: Change "propositional atom" to "sentence letter" in the table Reading column

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/01-syntax.typ` - 3 changes (2 replacements + 1 deletion)

**Verification**:
- Grep for "propositional atom" returns no results in 01-syntax.typ
- The NOTE tag is removed
- Document compiles without errors (if Typst toolchain available)

---

### Phase 2: Update 04-metalogic.typ [NOT STARTED]

**Goal**: Replace standalone "atom" terminology in the metalogic chapter

**Tasks**:
- [ ] Line 151: Change "An atom $p$" to "A sentence letter $p$" in the Canonical Valuation definition

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - 1 change

**Verification**:
- Grep for standalone "atom" in metalogic context shows no inappropriate uses
- The sentence reads naturally with "sentence letter"

---

### Phase 3: Final Verification [NOT STARTED]

**Goal**: Confirm all terminology is consistent across Bimodal documentation

**Tasks**:
- [ ] Run grep for "propositional atom" across all Bimodal Typst files - should return 0 results
- [ ] Run grep for "sentence letter" to verify consistent usage
- [ ] Verify no unintended changes to Lean code references or constructor names

**Timing**: 5 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `grep -ri "propositional atom" Theories/Bimodal/typst/` returns no matches
- All "sentence letter" usages are grammatically correct
- Table formatting and Lean code references remain intact

## Testing & Validation

- [ ] No occurrences of "propositional atom" remain in Bimodal Typst documentation
- [ ] "sentence letter" is used consistently (should appear in 02-semantics.typ and newly in 01-syntax.typ and 04-metalogic.typ)
- [ ] NOTE tag at line 20 of 01-syntax.typ is removed
- [ ] Lean code snippets (e.g., `atom s`) remain unchanged
- [ ] Table structure and alignment preserved

## Artifacts & Outputs

- Modified files:
  - `Theories/Bimodal/typst/chapters/01-syntax.typ` (3 changes)
  - `Theories/Bimodal/typst/chapters/04-metalogic.typ` (1 change)

## Rollback/Contingency

Changes are simple text replacements in version-controlled files. If any issues arise:
1. Revert to previous commit with `git checkout HEAD~1 -- Theories/Bimodal/typst/`
2. Re-evaluate terminology decisions if consistency concerns emerge
