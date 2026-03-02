# Research Report: Task #952

**Task**: 952 - sync_theory_claude_improvements_into_proofchecker_claude
**Started**: 2026-03-01T00:00:00Z
**Completed**: 2026-03-01T00:15:00Z
**Effort**: 2-3 hours
**Dependencies**: None
**Sources/Inputs**: - Codebase exploration (Theory/.claude vs ProofChecker/.claude)
**Artifacts**: - specs/952_sync_theory_claude_improvements_into_proofchecker_claude/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **39 files** in Theory/.claude that are missing from ProofChecker/.claude should be brought in
- **32 files** unique to ProofChecker must be preserved (team skills, reference docs, output/)
- **~190 files** exist in both directories, requiring selective merge review for key files
- Theory uses `{NNN}` zero-padding pattern; ProofChecker uses `{N}` - will need to update templates
- Recommended sync order: domain content first, then orchestration files, then skills/agents

## Context & Scope

This research compares the Theory/.claude directory (source) against ProofChecker/.claude (target) to identify files that should be synced while preserving ProofChecker-specific customizations.

### Key Preservation Requirements (from task description)
- `context/core/reference/` directory - ProofChecker-unique reference files
- Model configuration: opus on agents
- Targeted file-by-file git staging patterns
- Multi-agent team skills (skill-team-implement, skill-team-plan, skill-team-research)
- Condensed CLAUDE.md with @-references
- All ProofChecker-specific patterns (team-orchestration, etc.)

### Items to Bring In (from task description)
- typst-research skill+agent
- /merge command
- Zero-padding ({NNN}) in paths and artifact templates
- Domain content: category theory, bilateral semantics, mereology, bilattice-theory, monoidal-posets, scott-topology
- logos-macros.md
- Extra orchestration files (delegation.md, orchestrator.md, routing.md, sessions.md, subagent-validation.md, validation.md)
- context-knowledge-template.md
- README.md files in context/project/ subdirectories
- Extra typst patterns+standards
- Extra latex checklist items (logos-macros.md)
- tts-stt-integration.md, wezterm-integration.md in docs/guides/
- opencode-conventions.md

---

## Findings

### Files in Theory NOT in ProofChecker (39 files to bring in)

#### Agents (1 file)
| Source Path | Purpose |
|-------------|---------|
| `agents/typst-research-agent.md` | Typst documentation research agent |

#### Commands (1 file)
| Source Path | Purpose |
|-------------|---------|
| `commands/merge.md` | GitLab merge request creation command |

#### Orchestration Files (6 files)
| Source Path | Purpose | Notes |
|-------------|---------|-------|
| `context/core/orchestration/delegation.md` | Delegation standard (DEPRECATED) | Consolidated into orchestration-core.md - import for reference |
| `context/core/orchestration/orchestrator.md` | Orchestrator patterns | May have useful content |
| `context/core/orchestration/routing.md` | Command routing (DEPRECATED) | Consolidated - import for reference |
| `context/core/orchestration/sessions.md` | Session management | Session tracking patterns |
| `context/core/orchestration/subagent-validation.md` | Subagent validation | Validation framework |
| `context/core/orchestration/validation.md` | General validation | Validation patterns |

#### Templates (1 file)
| Source Path | Purpose |
|-------------|---------|
| `context/core/templates/context-knowledge-template.md` | Knowledge extraction criteria for research |

#### Logic Domain (6 files)
| Source Path | Purpose |
|-------------|---------|
| `context/project/logic/domain/bilateral-propositions.md` | Bilateral proposition theory |
| `context/project/logic/domain/bilateral-semantics.md` | Exact truthmaker semantics |
| `context/project/logic/domain/counterfactual-semantics.md` | Counterfactual semantics |
| `context/project/logic/domain/lattice-theory-concepts.md` | Lattice theory for logic |
| `context/project/logic/domain/mereology-foundations.md` | Mereology foundations |
| `context/project/logic/domain/spatial-domain.md` | Spatial logic domain |

#### Math Domain - Category Theory (6 files)
| Source Path | Purpose |
|-------------|---------|
| `context/project/math/category-theory/basics.md` | Category fundamentals |
| `context/project/math/category-theory/cauchy-completion.md` | Cauchy completion |
| `context/project/math/category-theory/enriched-categories.md` | Enriched category theory |
| `context/project/math/category-theory/lawvere-metric-spaces.md` | Lawvere metric spaces |
| `context/project/math/category-theory/monoidal-categories.md` | Monoidal categories |
| `context/project/math/category-theory/profunctors.md` | Profunctors |

#### Math Domain - Lattice/Order/Topology (3 files)
| Source Path | Purpose |
|-------------|---------|
| `context/project/math/lattice-theory/bilattice-theory.md` | Bilattice algebraic structure |
| `context/project/math/order-theory/monoidal-posets.md` | Monoidal posets |
| `context/project/math/topology/scott-topology.md` | Scott topology for domain theory |

#### LaTeX Standards (1 file)
| Source Path | Purpose |
|-------------|---------|
| `context/project/latex/standards/logos-macros.md` | Logos LaTeX macro conventions |

#### Typst Patterns/Standards (4 files)
| Source Path | Purpose |
|-------------|---------|
| `context/project/typst/patterns/fletcher-diagrams.md` | Fletcher diagram patterns |
| `context/project/typst/patterns/rule-environments.md` | Inference rule environments |
| `context/project/typst/standards/dtt-foundation-standard.md` | DTT foundation standards |
| `context/project/typst/standards/textbook-standards.md` | Textbook conventions |

#### README Files (7 files)
| Source Path | Purpose |
|-------------|---------|
| `context/project/README.md` | Project context overview |
| `context/project/meta/README.md` | Meta domain overview |
| `context/project/physics/README.md` | Physics domain overview |
| `context/project/processes/README.md` | Processes overview |
| `context/project/repo/README.md` | Repository overview |
| `context/project/opencode/opencode-conventions.md` | OpenCode conventions |
| `claude-directory-export.md` | Export documentation |

#### Documentation Guides (2 files)
| Source Path | Purpose |
|-------------|---------|
| `docs/guides/tts-stt-integration.md` | TTS/STT integration guide |
| `docs/guides/wezterm-integration.md` | WezTerm integration guide |

#### Skills (1 file)
| Source Path | Purpose |
|-------------|---------|
| `skills/skill-typst-research/SKILL.md` | Typst research skill |

---

### Files Unique to ProofChecker (32 files - MUST PRESERVE)

#### Reference Directory (5 files) - CRITICAL
| Path | Purpose |
|------|---------|
| `context/core/reference/artifact-templates.md` | Artifact template conventions |
| `context/core/reference/command-reference.md` | Command quick reference |
| `context/core/reference/error-recovery-procedures.md` | Error recovery procedures |
| `context/core/reference/skill-agent-mapping.md` | Skill-to-agent routing |
| `context/core/reference/state-json-schema.md` | State.json schema |

#### Team Skills (3 files) - CRITICAL
| Path | Purpose |
|------|---------|
| `skills/skill-team-implement/SKILL.md` | Multi-agent implementation |
| `skills/skill-team-plan/SKILL.md` | Multi-agent planning |
| `skills/skill-team-research/SKILL.md` | Multi-agent research |

#### Team Support (2 files)
| Path | Purpose |
|------|---------|
| `utils/team-wave-helpers.md` | Team wave helper patterns |
| `context/core/patterns/team-orchestration.md` | Team orchestration patterns |

#### Formats (6 files)
| Path | Purpose |
|------|---------|
| `context/core/formats/changelog-format.md` | Changelog format |
| `context/core/formats/debug-report-format.md` | Debug report format |
| `context/core/formats/handoff-artifact.md` | Handoff artifacts |
| `context/core/formats/metadata-quick-ref.md` | Metadata quick reference |
| `context/core/formats/progress-file.md` | Progress file format |
| `context/core/formats/team-metadata-extension.md` | Team metadata extensions |

#### Patterns (1 file)
| Path | Purpose |
|------|---------|
| `context/core/patterns/roadmap-reflection-pattern.md` | Roadmap reflection |

#### Standards (1 file)
| Path | Purpose |
|------|---------|
| `context/core/standards/git-staging-scope.md` | Git staging scope rules |

#### Output Directory (9 files)
| Path | Purpose |
|------|---------|
| `output/implement.md` | Implementation output template |
| `output/lean-implement.md` | Lean implementation output |
| `output/lean-research-2.md` | Lean research output v2 |
| `output/lean-research.md` | Lean research output |
| `output/learn.md` | Learn output |
| `output/plan.md` | Plan output |
| `output/research.md` | Research output |
| `output/revise.md` | Revise output |
| `output/todo.md` | Todo output |

#### Scripts (3 files)
| Path | Purpose |
|------|---------|
| `scripts/generate-context-index.sh` | Context index generator |
| `scripts/update-plan-status.sh` | Plan status updater |
| `scripts/validate-context-index.sh` | Context index validator |

#### Hooks (1 file - in different location)
| Path | Purpose |
|------|---------|
| `context/project/hooks/wezterm-integration.md` | WezTerm hooks docs |

#### Lean Standards (1 file)
| Path | Purpose |
|------|---------|
| `context/project/lean4/standards/proof-conventions.md` | Proof conventions (additional) |

---

### Files in Both Directories (~190 files - Selective Merge Needed)

Most files exist in both directories. Key files that may need review:

#### High-Priority Merge Candidates (check for improvements in Theory)

| File | Concern |
|------|---------|
| `agents/*.md` | Zero-padding {NNN} pattern - Theory may have updated templates |
| `settings.json` | May have different model configurations |
| `CLAUDE.md` | ProofChecker has condensed version with @-references - PRESERVE |
| `README.md` | May have improvements |
| `context/index.json` | Will need regeneration after sync |
| `context/index.md` | Will need regeneration after sync |

#### Files with Known Differences

| File | Theory | ProofChecker | Action |
|------|--------|--------------|--------|
| Agent path templates | Uses `{NNN}` | Uses `{N}` | Update PC to use {NNN} |
| CLAUDE.md | Full version | Condensed with @-refs | Preserve PC version |
| Model config | May differ | Has opus for agents | Preserve PC model config |

---

## Zero-Padding Analysis

### Theory Pattern
```
specs/{NNN}_{SLUG}/reports/research-{NNN}.md
specs/{NNN}_{SLUG}/.return-meta.json
```

### ProofChecker Current Pattern
```
specs/{N}_{SLUG}/reports/research-{NNN}.md
specs/{N}_{SLUG}/.return-meta.json
```

### Files to Update for Zero-Padding
All agent files that contain path templates will need updating. The actual project paths (existing specs directories) can remain as-is since they're already created.

---

## Recommended Sync Strategy

### Phase 1: Create New Directories/Files (Safe - No Conflicts)

```bash
# Create category-theory directory
mkdir -p .claude/context/project/math/category-theory

# Copy all new files that don't exist
cp -n Theory/.claude/agents/typst-research-agent.md ProofChecker/.claude/agents/
cp -n Theory/.claude/commands/merge.md ProofChecker/.claude/commands/
cp -n Theory/.claude/skills/skill-typst-research/SKILL.md ProofChecker/.claude/skills/skill-typst-research/
# etc.
```

### Phase 2: Domain Content (39 new files)

Order:
1. Math domain (category-theory/, bilattice-theory, monoidal-posets, scott-topology)
2. Logic domain (bilateral-semantics, mereology, counterfactual-semantics, etc.)
3. Typst patterns/standards
4. LaTeX logos-macros.md
5. README files
6. Documentation guides

### Phase 3: Orchestration Files

The orchestration files from Theory are marked DEPRECATED but contain useful reference content:
- Copy as reference files
- Do NOT replace existing orchestration-core.md patterns

### Phase 4: Templates and Agents

1. Copy context-knowledge-template.md
2. Copy typst-research-agent.md
3. Update existing agents with zero-padding pattern

### Phase 5: Update Zero-Padding

Update path templates in:
- All agent files
- Skill files
- artifact-templates.md (if applicable)

### Phase 6: Regenerate Index

After sync:
```bash
.claude/scripts/generate-context-index.sh
```

---

## Conflict Avoidance Rules

1. **NEVER overwrite** files in `context/core/reference/`
2. **NEVER overwrite** team skill files (`skill-team-*`)
3. **NEVER overwrite** `CLAUDE.md` (condensed version with @-references)
4. **NEVER overwrite** model configurations in `settings.json`
5. **NEVER copy** output/ directory from Theory
6. **PRESERVE** all git-staging-scope.md patterns
7. **PRESERVE** team-orchestration.md patterns

---

## File Mapping Summary

### To Create (directories)
```
.claude/context/project/math/category-theory/
.claude/context/project/opencode/
.claude/skills/skill-typst-research/
```

### To Copy (39 files)
See "Files in Theory NOT in ProofChecker" section above.

### To Preserve (32 files)
See "Files Unique to ProofChecker" section above.

### To Merge Review (key files only)
- `settings.json` - check model configs
- `README.md` - check for improvements
- `context/index.json` - regenerate after sync

---

## Decisions

1. **Zero-padding adoption**: Will adopt Theory's `{NNN}` pattern for consistency
2. **Deprecated files**: Will copy deprecated orchestration files for reference only
3. **CLAUDE.md**: ProofChecker's condensed version will be preserved
4. **Output directory**: Explicitly NOT copied (per task description)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Accidental overwrite of ProofChecker-unique files | Use targeted file-by-file git staging |
| Index.json becomes stale | Regenerate after all copies complete |
| Model config changes | Review settings.json diff before copying |
| Path template inconsistency | Update all agents in single commit |

---

## Appendix

### Sync Command Templates

```bash
# Safe copy new files (Theory -> ProofChecker)
# -n = no clobber (don't overwrite existing)
rsync -av --ignore-existing \
  Theory/.claude/context/project/math/category-theory/ \
  ProofChecker/.claude/context/project/math/category-theory/

# Individual file copy
cp Theory/.claude/commands/merge.md ProofChecker/.claude/commands/

# Create directories
mkdir -p ProofChecker/.claude/context/project/math/category-theory
mkdir -p ProofChecker/.claude/context/project/opencode
mkdir -p ProofChecker/.claude/skills/skill-typst-research
```

### Verification Commands

```bash
# Verify no ProofChecker-unique files were lost
ls ProofChecker/.claude/context/core/reference/
ls ProofChecker/.claude/skills/skill-team-*/

# Count files after sync
find ProofChecker/.claude -type f | wc -l
```
