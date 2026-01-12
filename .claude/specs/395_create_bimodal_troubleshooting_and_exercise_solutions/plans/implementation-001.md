# Implementation Plan: Task #395

**Task**: Create Bimodal troubleshooting guide and exercise solutions
**Version**: 001
**Created**: 2026-01-12
**Language**: markdown

## Overview

Create comprehensive troubleshooting documentation and exercise solutions for the Bimodal library. This involves:
1. Creating a new TROUBLESHOOTING.md guide with ~20 categorized error patterns
2. Adding progressive hint/solution sections to the 9 exercises in EXAMPLES.md section 7
3. Cross-referencing from QUICKSTART.md and README.md

The documentation follows existing Bimodal patterns: problem-solution format with code examples, consistent navigation links, and progressive disclosure for solutions.

## Phases

### Phase 1: Create TROUBLESHOOTING.md Structure

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create the new TROUBLESHOOTING.md file with proper header and navigation
2. Add 5 sections covering import, type, proof, tactic, and build errors
3. Document ~20 error patterns with solutions

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/TROUBLESHOOTING.md` - new file

**Steps**:
1. Create file with standard header (title, date, navigation links)
2. Write Section 1: Import and Setup Errors (4-5 items)
   - Missing `import Bimodal`
   - Missing namespace opens (`open Bimodal.Syntax`, `open Bimodal.ProofSystem`)
   - Wrong import path for automation (`import Bimodal.Automation`)
   - Build failures from missing dependencies
3. Write Section 2: Type Errors (5-6 items)
   - Formula vs Prop confusion
   - DerivationTree is Type not Prop
   - Context list type issues
   - Derived operator expansion (`diamond = neg.box.neg`)
   - String vs Formula for atoms
4. Write Section 3: Proof Construction Errors (5-6 items)
   - Wrong axiom selection (guide to axiom patterns)
   - Necessitation requires empty context
   - Temporal duality requires empty context
   - Missing weakening for context manipulation
   - Assumption lookup with list ordering
5. Write Section 4: Tactic Errors (4-5 items)
   - `modal_search` depth configuration
   - `tm_auto`/aesop known issues (reference KNOWN_LIMITATIONS.md)
   - Tactic vs constructor confusion (`modal_t` vs `Axiom.modal_t`)
   - `apply_axiom` usage patterns
6. Write Section 5: Build and Performance (3-4 items)
   - Slow compilation with complex proofs
   - Memory issues with large contexts
   - ProofSearch build failures

**Verification**:
- File renders correctly as markdown
- All code examples are syntactically correct
- Navigation links are valid

---

### Phase 2: Add Exercise Solutions to EXAMPLES.md

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add progressive hints and solutions to all 9 exercises in section 7
2. Use collapsible `<details>` sections for solutions
3. Include explanations of proof techniques

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/EXAMPLES.md` - modify section 7

**Steps**:
1. Read current section 7 format to understand existing structure
2. For each of 9 exercises, add:
   - **Hint 1**: High-level approach (e.g., "Use modal distribution")
   - **Hint 2**: Specific axiom/theorem to use
   - **Solution**: Complete Lean code in collapsible `<details>` block
   - **Explanation**: Why this proof works

3. Exercise solutions outline:
   - **Ex 1**: `⊢ □(P → Q) → (□P → □Q)` - Direct `Axiom.modal_k_dist` application
   - **Ex 2**: `[P, P → Q] ⊢ Q` - `DerivationTree.modus_ponens` with assumptions
   - **Ex 3**: `⊢ □P → ◇P` - Compose `modal_t` with `modal_b` and diamond def
   - **Ex 4**: `⊢ ◇◇P → ◇P` - Use `modal_5_collapse` axiom
   - **Ex 5**: `[always P] ⊢ P` - Conjunction elimination from `always` definition
   - **Ex 6**: `{□P, □Q}` entails `□(P ∧ Q)` - Modal K distribution twice
   - **Ex 7**: P1 perpetuity `⊢ □P → always P` - Use modal-temporal interaction axioms
   - **Ex 8**: `⊢ always □P ↔ □P` - Bimodal equivalence proof
   - **Ex 9**: Canonical model exercise - Reference completeness infrastructure

4. Format each solution consistently:
```markdown
### Exercise N: [Title]

**Problem**: `⊢ formula`

**Hint 1**: [High-level approach]

**Hint 2**: [Specific axiom/theorem]

<details>
<summary>Solution</summary>

```lean
example ... := by
  ...
```

**Explanation**: [Why this works]
</details>
```

**Verification**:
- All solutions type-check (verify against source files)
- Progressive hints don't give away the full answer
- Explanations reference relevant documentation

---

### Phase 3: Update Cross-References and Navigation

**Estimated effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Add TROUBLESHOOTING.md to user-guide README.md
2. Update QUICKSTART.md troubleshooting section to reference new guide
3. Add to main Bimodal README.md table

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/README.md` - add to navigation
- `Theories/Bimodal/docs/user-guide/QUICKSTART.md` - expand troubleshooting section
- `Theories/Bimodal/README.md` - add to documentation table

**Steps**:
1. In `docs/user-guide/README.md`:
   - Add TROUBLESHOOTING.md to the document list with description
   - Ensure navigation links are consistent

2. In `QUICKSTART.md` troubleshooting section:
   - Keep existing 3 quick tips
   - Add "For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)"
   - Add "For exercise solutions, see [EXAMPLES.md](EXAMPLES.md#exercises)"

3. In main `README.md`:
   - Add TROUBLESHOOTING.md to the documentation table
   - Update description if needed

**Verification**:
- All navigation links work
- Documentation structure is consistent
- No broken references

---

## Dependencies

- None (documentation-only task)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Exercise solutions don't type-check | High | Medium | Verify each solution against actual Lean files |
| Inconsistent formatting | Low | Low | Follow existing EXAMPLES.md patterns |
| Missing error patterns | Medium | Low | Research report covers common errors |

## Success Criteria

- [ ] TROUBLESHOOTING.md created with ~20 error patterns in 5 sections
- [ ] All 9 exercises in EXAMPLES.md section 7 have hints and solutions
- [ ] Solutions are type-correct (verified against source)
- [ ] Cross-references updated in 3 files
- [ ] Navigation links work correctly
- [ ] Documentation follows existing Bimodal style

## Rollback Plan

Revert documentation changes via git:
```bash
git checkout HEAD -- Theories/Bimodal/docs/
```

Documentation-only changes have no code impact.
