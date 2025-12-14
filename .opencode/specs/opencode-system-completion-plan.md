# OpenCode System Completion Plan

**Status:** Planning  
**Created:** 2025-12-14  
**Priority:** Medium  
**Estimated Effort:** 3-4 hours

## Overview

Complete the `.opencode` system cleanup and enhancement by:
1. Renaming remaining `lean-*` agents for consistency
2. Creating missing context files referenced by agents
3. Updating all references throughout the system

This builds on the completed work:
- Agent renaming (openagent → general, opencoder → coder, etc.)
- Removal of generic multi-language agents
- Creation of LEAN 4-specific `/commit` command
- Enhancement of implementer with error handling

## Goals

1. **Consistency:** All agent names follow short, clear naming pattern (no `lean-` prefix)
2. **Completeness:** All referenced context files exist and contain accurate information
3. **Correctness:** All references updated across agent registry, README, docs, workflows
4. **Quality:** Context files derived from authoritative Logos documentation

## Phase 1: Agent Renaming

### 1.1 Rename Agent Files

**Files to rename:**

| Current Name | New Name | Location |
|--------------|----------|----------|
| `orchestrator.md` | `orchestrator.md` | `.opencode/agent/` |
| `implementer.md` | `implementer.md` | `.opencode/agent/` |
| `planner.md` | `planner.md` | `.opencode/agent/subagents/` |
| `reviser.md` | `reviser.md` | `.opencode/agent/subagents/` |
| `refactor.md` | `refactor.md` | `.opencode/agent/subagents/` |
| `researcher.md` | `researcher.md` | `.opencode/agent/subagents/` |
| `translator.md` | `translator.md` | `.opencode/agent/subagents/` |
| `project.md` | `project.md` | `.opencode/agent/subagents/` |

**Rationale:**
- Shorter names are easier to type and remember
- `lean-` prefix is redundant (this is a LEAN 4-only project)
- Consistent with already-renamed agents (general, coder, builder, codebase)

### 1.2 Rename Subagent Directories

**Directories to rename:**

| Current Name | New Name | Location |
|--------------|----------|----------|
| `lean-codebase-manager/` | `codebase/` | `.opencode/agent/subagents/` |
| `implementer/` | `implementer/` | `.opencode/agent/subagents/` |
| `translator/` | `translator/` | `.opencode/agent/subagents/` |
| `reviser/` | `reviser/` | `.opencode/agent/subagents/` |
| `planner/` | `planner/` | `.opencode/agent/subagents/` |
| `project/` | `project/` | `.opencode/agent/subagents/` |
| `refactor/` | `refactor/` | `.opencode/agent/subagents/` |
| `researcher/` | `researcher/` | `.opencode/agent/subagents/` |

**Note:** Some of these may already be renamed from previous work. Verify before renaming.

### 1.3 Update Agent Internal References

**For each renamed agent file:**
1. Update `<agent_name>` tag in agent file
2. Update `subagent_type` references in delegation sections
3. Update any self-references in examples or documentation

**Example:**
```markdown
<!-- Before -->
<agent_name>implementer</agent_name>

<!-- After -->
<agent_name>implementer</agent_name>
```

## Phase 2: Create Missing Context Files

### 2.1 Create LEAN Style Standards

**File:** `.opencode/context/lean4/standards/lean-style.md`

**Source Material:**
- `Documentation/Development/LEAN_STYLE_GUIDE.md` (primary source)
- `Documentation/Development/MODULE_ORGANIZATION.md`

**Content Sections:**
1. Naming Conventions
   - PascalCase for types/theorems
   - snake_case for functions/variables
   - Namespace rules
2. Formatting Rules
   - 100-char line limit
   - 2-space indentation
   - Flush-left declarations
3. Documentation Requirements
   - Docstring format
   - Module headers
   - Inline comments
4. Code Organization
   - Import order
   - Declaration order
   - File structure

**Extraction Strategy:**
- Copy relevant sections from LEAN_STYLE_GUIDE.md
- Condense to essential rules (no rationale/examples unless critical)
- Add quick reference table for naming conventions
- Include common violations and fixes

### 2.2 Create Tactic Patterns

**File:** `.opencode/context/lean4/patterns/tactic-patterns.md`

**Source Material:**
- `Documentation/ProjectInfo/TACTIC_DEVELOPMENT.md` (primary source)
- `Documentation/Development/METAPROGRAMMING_GUIDE.md`
- `Logos/Core/Automation/Tactics.lean` (implementation examples)

**Content Sections:**
1. Tactic Development Approaches
   - `elab_rules` pattern (recommended)
   - Macro-based approach
   - Direct TacticM for complex cases
2. Common Tactic Patterns
   - Axiom application
   - Assumption search
   - Inference rule application
   - Bounded search
3. Aesop Integration
   - Rule set declaration
   - Safe rule marking
   - Custom tactic integration
4. Testing Patterns
   - Unit test structure
   - Example-based tests
   - Edge case coverage

**Extraction Strategy:**
- Extract implementation patterns from TACTIC_DEVELOPMENT.md
- Include code snippets for each pattern
- Add decision tree: when to use which approach
- Reference Logos-specific tactics as examples

### 2.3 Create Proof Conventions

**File:** `.opencode/context/lean4/standards/proof-conventions.md`

**Source Material:**
- `Documentation/Development/LEAN_STYLE_GUIDE.md` (proof style section)
- `Logos/Core/Metalogic/Soundness.lean` (soundness proof patterns)
- `Logos/Core/Theorems/Perpetuity.lean` (theorem proof patterns)
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` (sorry policy)

**Content Sections:**
1. Proof Structure
   - Theorem statement format
   - Proof sketch in docstring
   - Tactic vs term mode
2. Logos-Specific Patterns
   - Soundness proofs (axiom validity)
   - Derivability proofs (inference rules)
   - Semantic validity proofs
3. Sorry Policy
   - When sorry is acceptable (never in main branch)
   - Documentation requirements for sorry
   - SORRY_REGISTRY.md workflow
4. Common Proof Techniques
   - Induction on derivability
   - Case analysis on formulas
   - Semantic evaluation
   - Contraposition and duality

**Extraction Strategy:**
- Extract proof patterns from completed proofs in Logos
- Document Logos-specific proof strategies
- Include anti-patterns (what to avoid)
- Add checklist for proof quality

### 2.4 Directory Structure

**Create directories:**
```
.opencode/context/lean4/
├── standards/
│   ├── lean-style.md
│   └── proof-conventions.md
└── patterns/
    └── tactic-patterns.md
```

**Verification:**
- Ensure all paths referenced in `implementer.md` exist
- Check fallback logic still works (Mathlib best practices)

## Phase 3: Update All References

### 3.1 Update Agent Registry

**File:** `.opencode/agent/agent-registry.json`

**Changes:**
1. Update all `lean-*` agent names to new short names
2. Update `subagent_type` values
3. Update file paths for renamed agents
4. Verify JSON validity after changes

**Example:**
```json
{
  "agents": {
    "implementer": {
      "name": "implementer",
      "file": ".opencode/agent/implementer.md",
      "subagent_type": "implementer",
      "description": "LEAN 4 code generation and proof implementation"
    }
  }
}
```

### 3.2 Update README

**File:** `.opencode/README.md`

**Changes:**
1. Update agent name table
2. Update subagent listings
3. Update example invocations
4. Update file tree structure

**Sections to update:**
- "Available Agents" table
- "Subagent Organization" section
- "Usage Examples"
- File structure diagram

### 3.3 Update Documentation Files

**Files to update:**

| File | Changes |
|------|---------|
| `.opencode/docs/guides/development/agent-development/agent-development-fundamentals.md` | Update agent name examples |
| `.opencode/docs/guides/development/command-development/command-development-fundamentals.md` | Update agent references in examples |
| `.opencode/docs/reference/standards/code-standards.md` | Update agent name references |
| `.opencode/docs/workflows/agent-coordination.md` | Update delegation examples |
| `.opencode/docs/workflows/task-breakdown.md` | Update orchestrator references |

**Search pattern:**
```bash
# Find all references to old agent names
rg "orchestrator|implementer|planner|reviser|refactor|researcher|translator|project" .opencode/
```

### 3.4 Update Workflow Files

**Files to update:**

| File | Changes |
|------|---------|
| `.opencode/workflows/proof-development.md` | Update planner/implementer/reviser references |
| `.opencode/workflows/codebase-maintenance.md` | Update codebase agent references |
| `.opencode/workflows/research-integration.md` | Update researcher references |
| `.opencode/workflows/latex-translation.md` | Update translator references |

### 3.5 Update Command Files

**Files to update:**

| File | Changes |
|------|---------|
| `.opencode/command/prove.md` | Update planner/implementer delegation |
| `.opencode/command/refactor.md` | Update refactor agent references |
| `.opencode/command/research.md` | Update researcher references |
| `.opencode/command/translate.md` | Update translator references |

**Pattern:**
```markdown
<!-- Before -->
subagent_type="implementer"

<!-- After -->
subagent_type="implementer"
```

### 3.6 Update Spec Files

**Files to update:**
- All files in `.opencode/specs/` that reference old agent names
- Update implementation summaries
- Update design documents

**Note:** Historical spec files can retain old names in "before" sections for context.

## Phase 4: Verification

### 4.1 Automated Checks

**Run these commands to verify completeness:**

```bash
# 1. Check for remaining lean-* agent references (should be minimal)
rg "orchestrator|implementer|planner|reviser|refactor|researcher|translator|project" .opencode/ --type md

# 2. Verify all context files exist
test -f .opencode/context/lean4/standards/lean-style.md && echo "✓ lean-style.md exists"
test -f .opencode/context/lean4/patterns/tactic-patterns.md && echo "✓ tactic-patterns.md exists"
test -f .opencode/context/lean4/standards/proof-conventions.md && echo "✓ proof-conventions.md exists"

# 3. Verify agent registry is valid JSON
python3 -m json.tool .opencode/agent/agent-registry.json > /dev/null && echo "✓ agent-registry.json is valid"

# 4. Check for broken internal links in README
# (manual review recommended)
```

### 4.2 Manual Verification

**Checklist:**
- [ ] All agent files renamed and updated
- [ ] All subagent directories renamed
- [ ] All context files created with accurate content
- [ ] Agent registry updated and valid
- [ ] README updated with new names
- [ ] All documentation files updated
- [ ] All workflow files updated
- [ ] All command files updated
- [ ] No broken references in `.opencode/`
- [ ] Context files match source documentation

### 4.3 Test Agent Invocations

**Test each renamed agent:**
```bash
# Test orchestrator
# (invoke via Claude Code with task tool)

# Test implementer
# (invoke via /prove or task tool)

# Test planner
# (invoke via /prove or task tool)

# Verify delegation works with new names
```

## Implementation Order

### Day 1: Agent Renaming (2 hours)
1. Phase 1.1: Rename agent files (30 min)
2. Phase 1.2: Rename subagent directories (15 min)
3. Phase 1.3: Update agent internal references (45 min)
4. Phase 3.1: Update agent registry (30 min)

### Day 2: Context Files (2 hours)
1. Phase 2.1: Create lean-style.md (45 min)
2. Phase 2.2: Create tactic-patterns.md (45 min)
3. Phase 2.3: Create proof-conventions.md (30 min)

### Day 3: Update References (1.5 hours)
1. Phase 3.2: Update README (30 min)
2. Phase 3.3: Update documentation files (30 min)
3. Phase 3.4: Update workflow files (15 min)
4. Phase 3.5: Update command files (15 min)

### Day 4: Verification (30 min)
1. Phase 4.1: Run automated checks (10 min)
2. Phase 4.2: Manual verification (15 min)
3. Phase 4.3: Test agent invocations (5 min)

**Total Estimated Time:** 6 hours (conservative estimate)

## Success Criteria

1. **Naming Consistency:** All agents use short names without `lean-` prefix
2. **Reference Completeness:** Zero broken references in `.opencode/`
3. **Context Accuracy:** All context files accurately reflect Logos documentation
4. **Functional Verification:** All agents can be invoked with new names
5. **Documentation Quality:** README and docs clearly explain new structure

## Risks and Mitigations

### Risk 1: Breaking Existing Workflows
**Mitigation:** Test agent invocations after renaming, update all command files

### Risk 2: Context Files Out of Sync
**Mitigation:** Extract directly from authoritative Logos docs, add source references

### Risk 3: Missed References
**Mitigation:** Use comprehensive grep/rg search, manual review of critical files

### Risk 4: Agent Registry Corruption
**Mitigation:** Validate JSON after each change, keep backup of original

## Rollback Plan

If issues arise:
1. Revert agent file renames (git checkout)
2. Restore agent registry from backup
3. Remove context files if inaccurate
4. Document issues in this spec for future attempt

## Post-Completion Tasks

1. Update `.opencode/specs/codebase-agent-cleanup-summary.md` with Phase 2 results
2. Create `.opencode/specs/opencode-system-completion-summary.md` documenting final state
3. Test full proof development workflow with new agent names
4. Consider creating migration guide for users familiar with old names

## Notes

- This plan assumes the previous cleanup work (general, coder, builder, codebase) is complete
- Some directories may already be renamed; verify before attempting rename
- Context files should be concise (1-2 pages max) for quick agent loading
- Prioritize accuracy over completeness in context files (agents can fall back to Mathlib docs)

## References

- Previous work: `.opencode/specs/codebase-agent-cleanup-summary.md`
- Commit command: `.opencode/specs/commit-command-refactor-implementation.md`
- Agent comparison: `.opencode/specs/agent-comparison-coder-vs-implementer.md`
- Integration analysis: `.opencode/specs/coder-to-implementer-integration-analysis.md`
