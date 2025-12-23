# Implementation Plan: Add Missing Directory READMEs

**Task**: #61
**Complexity**: Simple
**Estimated Effort**: 1 hour (30 minutes per README)
**Created**: 2025-12-18

## Task Description

Add README.md files to two directories lacking them, following DIRECTORY_README_STANDARD.md Template D (LEAN Source Directory - Lightweight).

**Verification Finding** (Project 004 - 2025-12-16):
- ✅ Verified 2 missing READMEs: `Automation/` and `Perpetuity/`
- ✅ Confirmed as reducing discoverability and understanding
- ✅ Repository organization score: 98/100 (2 points deducted for missing READMEs)

## Missing READMEs

1. **`Logos/Core/Theorems/Perpetuity/README.md`**
   - Document P1-P6 perpetuity principles
   - Document helper lemmas (temporal components, boilerplate reduction)
   - Document bridge lemmas (modal/temporal duality, monotonicity)
   - Files: Principles.lean, Helpers.lean, Bridge.lean

2. **`Logos/Core/Automation/README.md`**
   - Document custom tactics (apply_axiom, modal_t, tm_auto)
   - Document proof search infrastructure
   - Document Aesop integration and rule set
   - Files: Tactics.lean, ProofSearch.lean, AesopRules.lean

## Changes Required

### 1. Create `Logos/Core/Theorems/Perpetuity/README.md`

Following Template D structure:
- Brief purpose statement (perpetuity principles P1-P6)
- Submodules section listing 3 files with descriptions
- Quick reference for finding specific theorems
- Building/type-checking instructions
- API documentation links
- Related documentation links

**Content Focus**:
- P1-P6 theorem statements (brief, not full proofs)
- Helper lemma categories (temporal components, boilerplate reduction)
- Bridge lemma categories (duality, monotonicity, double negation)
- Navigation to specific files for details

### 2. Create `Logos/Core/Automation/README.md`

Following Template D structure:
- Brief purpose statement (proof automation for TM logic)
- Submodules section listing 3 files with descriptions
- Quick reference for tactics and automation
- Usage examples (apply_axiom, modal_t, tm_auto)
- Implementation status notes
- Related documentation links

**Content Focus**:
- Main tactics overview (apply_axiom, modal_t, tm_auto)
- Aesop integration explanation
- Proof search infrastructure (planned)
- Usage examples for each tactic
- Implementation status (Phase 4-7)

## Files Affected

- `Logos/Core/Theorems/Perpetuity/README.md` (create)
- `Logos/Core/Automation/README.md` (create)

## Template Compliance

Both READMEs will follow **Template D: LEAN Source Directory (Lightweight)** from DIRECTORY_README_STANDARD.md:

**Required Sections**:
1. Title and brief purpose (1-2 sentences)
2. Submodules list with one-line descriptions
3. Quick Reference (where to find specific functionality)
4. Building and Type-Checking commands
5. API Documentation links
6. Related Documentation links

**Length Target**: 40-70 lines (lightweight, navigation-focused)

**Anti-patterns to Avoid**:
- ✗ Don't duplicate docstrings from .lean files
- ✗ Don't include full theorem proofs
- ✗ Don't duplicate API documentation
- ✓ Focus on navigation and organization
- ✓ Provide quick reference links
- ✓ Keep lightweight and concise

## Verification Steps

After creating both READMEs:

- [ ] Both files follow Template D structure
- [ ] Both files are 40-70 lines (lightweight)
- [ ] All file references are accurate
- [ ] All links are valid and point to existing files
- [ ] No duplication of .lean docstrings
- [ ] Navigation value is clear
- [ ] Building instructions are correct
- [ ] Related documentation links are complete

## Success Criteria

1. ✅ `Logos/Core/Theorems/Perpetuity/README.md` created
2. ✅ `Logos/Core/Automation/README.md` created
3. ✅ Both READMEs follow Template D structure
4. ✅ Both READMEs are lightweight (40-70 lines)
5. ✅ All file references and links are valid
6. ✅ Repository organization score improves from 98/100 to 100/100
7. ✅ Discoverability and understanding improved for both directories

## Implementation Notes

**Reference Examples**:
- Good example: `Logos/README.md` (Template D, 182 lines - comprehensive)
- Target style: Lighter version of Logos/README.md for subdirectories

**Key Differences from Parent README**:
- Perpetuity/README.md: Focus on P1-P6 principles, not full module structure
- Automation/README.md: Focus on tactics and Aesop, not full automation suite

**Consistency**:
- Match tone and style of existing Logos/README.md
- Use same formatting conventions
- Follow same link structure patterns
