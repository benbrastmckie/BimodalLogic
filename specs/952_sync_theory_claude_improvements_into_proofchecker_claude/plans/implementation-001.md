# Implementation Plan: Sync Theory/.claude Improvements into ProofChecker/.claude

- **Task**: 952 - sync_theory_claude_improvements_into_proofchecker_claude
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/952_sync_theory_claude_improvements_into_proofchecker_claude/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan syncs 39 files from Theory/.claude into ProofChecker/.claude while preserving 32 ProofChecker-unique files. The sync covers domain content (category theory, bilateral semantics, mereology), skills/agents (typst-research), commands (/merge), orchestration references, documentation guides, and template updates including zero-padding pattern adoption.

### Research Integration

Research report (research-001.md) identified:
- 39 files to bring in (agents, commands, domain content, templates, guides)
- 32 files to preserve (reference/, team skills, output/, condensed CLAUDE.md)
- Zero-padding pattern: Theory uses `{NNN}`, ProofChecker uses `{N}` - update needed
- Recommended sync order: domain content -> orchestration -> skills/agents -> templates

## Goals & Non-Goals

**Goals**:
- Copy all 39 identified files from Theory/.claude to ProofChecker/.claude
- Update artifact path templates from `{N}` to `{NNN}` pattern
- Preserve all 32 ProofChecker-unique files
- Regenerate context index after sync
- Maintain functional equivalence of existing commands/agents

**Non-Goals**:
- Modifying ProofChecker's condensed CLAUDE.md
- Copying output/ directory from Theory
- Changing model configurations (opus on agents preserved)
- Updating existing task specs paths (only templates)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental overwrite of ProofChecker-unique files | High | Medium | Use targeted file-by-file git staging; verify critical files after each phase |
| Index.json becomes stale | Medium | High | Regenerate index as final phase step |
| Zero-padding update breaks existing patterns | Medium | Low | Review all affected files; test artifact creation after |
| Missing directory creation | Low | Medium | Create parent directories before copying files |

## Implementation Phases

### Phase 1: Create Directory Structure and Copy Domain Content [COMPLETED]

- **Dependencies:** None
- **Goal:** Establish new directories and copy all domain content files (math and logic)

**Tasks:**
- [ ] Create `context/project/math/category-theory/` directory
- [ ] Copy 6 category theory files (basics.md, cauchy-completion.md, enriched-categories.md, lawvere-metric-spaces.md, monoidal-categories.md, profunctors.md)
- [ ] Copy 3 additional math files (bilattice-theory.md, monoidal-posets.md, scott-topology.md)
- [ ] Copy 6 logic domain files (bilateral-propositions.md, bilateral-semantics.md, counterfactual-semantics.md, lattice-theory-concepts.md, mereology-foundations.md, spatial-domain.md)
- [ ] Verify: All 15 domain files present and readable

**Timing:** 30 minutes

**Files to create:**
- `.claude/context/project/math/category-theory/` (directory)
- `.claude/context/project/math/category-theory/basics.md`
- `.claude/context/project/math/category-theory/cauchy-completion.md`
- `.claude/context/project/math/category-theory/enriched-categories.md`
- `.claude/context/project/math/category-theory/lawvere-metric-spaces.md`
- `.claude/context/project/math/category-theory/monoidal-categories.md`
- `.claude/context/project/math/category-theory/profunctors.md`
- `.claude/context/project/math/lattice-theory/bilattice-theory.md`
- `.claude/context/project/math/order-theory/monoidal-posets.md`
- `.claude/context/project/math/topology/scott-topology.md`
- `.claude/context/project/logic/domain/bilateral-propositions.md`
- `.claude/context/project/logic/domain/bilateral-semantics.md`
- `.claude/context/project/logic/domain/counterfactual-semantics.md`
- `.claude/context/project/logic/domain/lattice-theory-concepts.md`
- `.claude/context/project/logic/domain/mereology-foundations.md`
- `.claude/context/project/logic/domain/spatial-domain.md`

**Verification:**
- `ls .claude/context/project/math/category-theory/` shows 6 files
- `ls .claude/context/project/math/lattice-theory/` includes bilattice-theory.md
- `ls .claude/context/project/logic/domain/` includes 6 new files

---

### Phase 2: Copy Typst and LaTeX Standards [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Copy Typst patterns/standards and LaTeX logos-macros

**Tasks:**
- [ ] Copy 2 Typst pattern files (fletcher-diagrams.md, rule-environments.md)
- [ ] Copy 2 Typst standard files (dtt-foundation-standard.md, textbook-standards.md)
- [ ] Copy LaTeX logos-macros.md
- [ ] Verify: All 5 files present

**Timing:** 15 minutes

**Files to create:**
- `.claude/context/project/typst/patterns/fletcher-diagrams.md`
- `.claude/context/project/typst/patterns/rule-environments.md`
- `.claude/context/project/typst/standards/dtt-foundation-standard.md`
- `.claude/context/project/typst/standards/textbook-standards.md`
- `.claude/context/project/latex/standards/logos-macros.md`

**Verification:**
- `ls .claude/context/project/typst/patterns/` includes 2 new files
- `ls .claude/context/project/typst/standards/` includes 2 new files
- `ls .claude/context/project/latex/standards/` includes logos-macros.md

---

### Phase 3: Copy Skills, Agents, and Commands [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add typst-research skill/agent and /merge command

**Tasks:**
- [ ] Create `skills/skill-typst-research/` directory
- [ ] Copy skill-typst-research/SKILL.md
- [ ] Copy typst-research-agent.md to agents/
- [ ] Copy merge.md to commands/
- [ ] Verify: All 3 files present and contain expected content

**Timing:** 20 minutes

**Files to create:**
- `.claude/skills/skill-typst-research/` (directory)
- `.claude/skills/skill-typst-research/SKILL.md`
- `.claude/agents/typst-research-agent.md`
- `.claude/commands/merge.md`

**Verification:**
- `ls .claude/skills/skill-typst-research/` shows SKILL.md
- `ls .claude/agents/` includes typst-research-agent.md
- `ls .claude/commands/` includes merge.md
- Verify skill-team-* directories still exist (preserved)

---

### Phase 4: Copy Orchestration and Template Files [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Copy orchestration reference files and context-knowledge-template

**Tasks:**
- [ ] Copy 6 orchestration files (delegation.md, orchestrator.md, routing.md, sessions.md, subagent-validation.md, validation.md) - marked as deprecated but useful reference
- [ ] Copy context-knowledge-template.md to templates/
- [ ] Verify: All 7 files present

**Timing:** 20 minutes

**Files to create:**
- `.claude/context/core/orchestration/delegation.md`
- `.claude/context/core/orchestration/orchestrator.md`
- `.claude/context/core/orchestration/routing.md`
- `.claude/context/core/orchestration/sessions.md`
- `.claude/context/core/orchestration/subagent-validation.md`
- `.claude/context/core/orchestration/validation.md`
- `.claude/context/core/templates/context-knowledge-template.md`

**Verification:**
- `ls .claude/context/core/orchestration/` includes 6 new files
- Verify orchestration-core.md still exists (preserved)
- `ls .claude/context/core/templates/` includes context-knowledge-template.md

---

### Phase 5: Copy README Files and Documentation Guides [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add README files and integration guides

**Tasks:**
- [ ] Create `context/project/opencode/` directory
- [ ] Copy opencode-conventions.md to opencode/
- [ ] Copy README.md files to: context/project/, context/project/meta/, context/project/physics/, context/project/processes/, context/project/repo/
- [ ] Copy claude-directory-export.md to .claude/
- [ ] Copy tts-stt-integration.md and wezterm-integration.md to docs/guides/
- [ ] Verify: All 9 files present

**Timing:** 25 minutes

**Files to create:**
- `.claude/context/project/opencode/` (directory)
- `.claude/context/project/opencode/opencode-conventions.md`
- `.claude/context/project/README.md`
- `.claude/context/project/meta/README.md`
- `.claude/context/project/physics/README.md`
- `.claude/context/project/processes/README.md`
- `.claude/context/project/repo/README.md`
- `.claude/claude-directory-export.md`
- `.claude/docs/guides/tts-stt-integration.md`
- `.claude/docs/guides/wezterm-integration.md`

**Verification:**
- `ls .claude/context/project/opencode/` shows opencode-conventions.md
- `find .claude/context/project -name "README.md"` shows 5 files
- `ls .claude/docs/guides/` includes both integration guides

---

### Phase 6: Update Zero-Padding Pattern in Templates [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Update artifact path templates from `{N}` to `{NNN}` pattern

**Tasks:**
- [ ] Review artifact-templates.md for {N} pattern usage
- [ ] Update return-metadata-file.md path examples from `{N}` to `{NNN}` if applicable
- [ ] Review agent files for path template patterns
- [ ] Update any affected template references
- [ ] Verify: grep for `{N}_` returns no matches in templates (should be `{NNN}_`)

**Timing:** 30 minutes

**Files to modify:**
- `.claude/context/core/reference/artifact-templates.md` (if contains {N} pattern)
- `.claude/context/core/formats/return-metadata-file.md` (path examples)
- Agent files as needed

**Verification:**
- `grep -r "specs/{N}_" .claude/context/` returns minimal matches (existing references OK)
- Artifact templates show `{NNN}` pattern for padding
- Note: Actual spec directories remain unpadded (952_, not 952_) - only templates updated

---

### Phase 7: Regenerate Context Index and Final Verification [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6
- **Goal:** Regenerate context index and verify all files preserved/created

**Tasks:**
- [ ] Run `.claude/scripts/generate-context-index.sh` to regenerate index
- [ ] Verify context/index.json is updated with new files
- [ ] Verify context/index.md reflects new entries
- [ ] Verify preservation: context/core/reference/ has 5 files
- [ ] Verify preservation: skills/skill-team-* has 3 directories
- [ ] Verify preservation: output/ directory unchanged
- [ ] Verify preservation: CLAUDE.md is condensed version with @-references
- [ ] Count total files: expect ~39 new files added

**Timing:** 20 minutes

**Verification:**
- `ls .claude/context/core/reference/` shows 5 files
- `ls .claude/skills/skill-team-*` shows 3 directories
- `ls .claude/output/` shows 9 ProofChecker output files
- `head -20 .claude/CLAUDE.md` shows condensed format with @-references
- `jq '.entries | length' .claude/context/index.json` shows increased count

---

## Testing & Validation

### File Integrity
- [ ] All 39 new files present and readable
- [ ] All 32 preserved files unchanged
- [ ] No duplicate files created

### Functional Verification
- [ ] `/merge` command accessible (syntax check)
- [ ] `typst-research` skill loads correctly
- [ ] Context index regenerated successfully
- [ ] Existing commands still work (spot check /task, /research)

### Zero-Padding Verification
- [ ] Template files show `{NNN}` pattern where appropriate
- [ ] Existing spec directories unaffected (remain unpadded)

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-20260301.md` (after completion)
- 39 new files in `.claude/` directory structure
- Updated `context/index.json` and `context/index.md`

## Rollback/Contingency

1. **Git provides rollback**: All changes tracked via git
2. **Phase-by-phase commits**: Each phase committed separately for granular rollback
3. **No destructive operations**: All operations are additive (copy, not move)
4. **Preservation verification**: Each phase verifies critical files preserved

**Emergency rollback**:
```bash
# If sync breaks something, reset to pre-sync state
git checkout HEAD~N -- .claude/
# Where N = number of phase commits to undo
```
