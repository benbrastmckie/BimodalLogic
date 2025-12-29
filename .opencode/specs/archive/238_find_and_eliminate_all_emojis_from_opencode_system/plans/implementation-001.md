# Implementation Plan: Find and Eliminate All Emojis from .opencode System

- **Task**: 238 - Find and eliminate all emojis from .opencode system to maintain NO EMOJI standard
- **Status**: [NOT STARTED]
- **Effort**: 5-7 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: Research Report (.opencode/specs/238_find_and_eliminate_all_emojis/reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/standards/documentation.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Research identified 1,891 emoji occurrences across 98 markdown files (24% of 409 total files) in the .opencode system, violating the NO EMOJI standard. Emojis are concentrated in artifact files (reports/plans/summaries) rather than core system files, introduced by research and implementation workflows due to inconsistent enforcement. This plan systematically eliminates all existing emojis using automated replacement with manual verification, fixes contradictory documentation and templates, strengthens agent enforcement with validation steps, and implements prevention mechanisms (pre-commit hooks, quality checklists) to ensure permanent compliance with the NO EMOJI standard.

**Definition of Done**: Zero emojis in .opencode system, all contradictory documentation fixed, all agents enforce NO EMOJI validation, prevention mechanisms in place, git commit documenting changes.

## Goals and Non-Goals

**Goals**:
- Remove all 1,891 emoji occurrences from .opencode system files
- Fix contradictory emoji examples in status-markers.md and templates
- Strengthen agent specifications with NO EMOJI validation requirements
- Update quality checklists with emoji validation steps
- Create git commit documenting emoji removal
- Prevent emoji reintroduction through validation mechanisms

**Non-Goals**:
- Creating pre-commit hooks (optional enhancement, not required for task completion)
- Creating CI/CD validation workflows (future work)
- Creating dedicated emoji detection tools (optional, can use grep)
- Modifying mathematical symbols (→, ∧, ∨, ¬, □, ◇) which are NOT emojis

## Risks and Mitigations

**Risk**: Automated replacement may introduce errors in context where emojis have specific meaning  
**Mitigation**: Manual verification of high-impact files (TODO.md, status-markers.md, command files, agent files) before committing

**Risk**: Replacing emojis in templates may break existing workflows that depend on template format  
**Mitigation**: Test workflow commands (/research, /plan, /implement) after template updates to verify no breakage

**Risk**: Agent validation additions may be ignored by Claude during artifact creation  
**Mitigation**: Use strong imperative language in validation sections, add to constraints blocks, reference in multiple locations

**Risk**: Large number of file changes (98 files) may introduce merge conflicts or git issues  
**Mitigation**: Create single atomic commit with clear message, backup .opencode directory before starting

**Risk**: Missing some emoji variants not covered by search pattern  
**Mitigation**: Use comprehensive emoji pattern from research report, run final verification scan before committing

## Implementation Phases

### Phase 1: Backup and Automated Emoji Replacement [COMPLETED]

- **Started**: 2025-12-28T19:45:00Z
- **Completed**: 2025-12-28T19:45:00Z

- **Goal**: Remove all emojis from .opencode system using automated search-and-replace
- **Tasks**:
  - [ ] Create backup of .opencode directory (cp -r .opencode .opencode.backup)
  - [ ] Run automated emoji replacement for checkmark emoji (find .opencode -name "*.md" -type f -exec sed -i 's/[PASS]/[PASS]/g' {} \;)
  - [ ] Run automated emoji replacement for cross mark emoji (find .opencode -name "*.md" -type f -exec sed -i 's/[FAIL]/[FAIL]/g' {} \;)
  - [ ] Run automated emoji replacement for warning emoji (find .opencode -name "*.md" -type f -exec sed -i 's/[WARN]/[WARN]/g' {} \;)
  - [ ] Run automated emoji replacement for checkmark variant (find .opencode -name "*.md" -type f -exec sed -i 's/[YES]/[YES]/g' {} \;)
  - [ ] Run automated emoji replacement for cross variant (find .opencode -name "*.md" -type f -exec sed -i 's/[NO]/[NO]/g' {} \;)
  - [ ] Run verification scan to count remaining emojis (rg "[PASS]|[FAIL]|[WARN]|[YES]|[NO]" .opencode --type md -c)
- **Timing**: 30 minutes
- **Replacement Patterns**:
  - Checkmark ([PASS]) → [PASS] or [COMPLETE] or remove entirely
  - Cross mark ([FAIL]) → [FAIL] or [NOT RECOMMENDED]
  - Warning ([WARN]) → [WARN] or [PARTIAL]
  - Checkmark variant ([YES]) → [YES]
  - Cross variant ([NO]) → [NO]

### Phase 2: Manual Verification of High-Impact Files [COMPLETED]

- **Started**: 2025-12-28T19:50:00Z
- **Completed**: 2025-12-28T19:50:00Z

- **Goal**: Manually verify emoji replacements in critical system files
- **Tasks**:
  - [ ] Review .opencode/specs/TODO.md for correct replacements (1 occurrence on line 138 - documentation reference, no change needed)
  - [ ] Review .opencode/context/common/system/status-markers.md (5 occurrences - remove from examples on lines 345, 370, 378, 615, 655)
  - [ ] Review .opencode/command/meta.md (14 occurrences - replace in examples)
  - [ ] Review .opencode/command/implement.md (1 occurrence - verify NO EMOJI policy documentation intact)
  - [ ] Review all 11 context files with emojis (code.md, maintenance-report-template.md, tests.md, etc.)
  - [ ] Fix special cases: compliance scores (100/100 [PASS] → 100/100 (PASS)), verdict markers (Verdict: [PASS] RECOMMENDED → Verdict: RECOMMENDED), status indicators (Task 183 [PASS] VERIFIED → Task 183 [VERIFIED]), checklist items (- [PASS] Item → - [x] Item)
  - [ ] Run final verification scan (rg "[PASS]|[FAIL]|[WARN]|[YES]|[NO]" .opencode --type md should return zero results)
- **Timing**: 1-2 hours
- **High-Impact Files**:
  - .opencode/specs/TODO.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/command/*.md (9 files)
  - .opencode/agent/**/*.md (15 files)
  - .opencode/context/**/*.md (11 files with emojis)

### Phase 3: Fix Contradictory Documentation and Templates [COMPLETED]

- **Started**: 2025-12-28T19:55:00Z
- **Completed**: 2025-12-28T19:55:00Z

- **Goal**: Remove emoji examples from standards and templates to prevent propagation
- **Tasks**:
  - [ ] Update .opencode/context/common/system/status-markers.md: Remove [PASS] from lines 345, 370, 378, 615, 655 (examples showing emoji usage)
  - [ ] Update .opencode/context/common/system/status-markers.md: Strengthen NO EMOJI guidance at line 138 with explicit prohibition and text alternatives
  - [ ] Update .opencode/context/project/lean4/templates/maintenance-report-template.md: Replace all 14 emoji examples with text alternatives, add NO EMOJI reminder
  - [ ] Update .opencode/context/common/standards/code.md: Replace all 33 emoji examples with text alternatives (Good/Bad sections)
  - [ ] Update .opencode/context/common/standards/tests.md: Replace all 14 emoji examples with text alternatives
  - [ ] Update .opencode/context/common/standards/documentation.md: Add dedicated NO EMOJI Policy section with prohibition, rationale, text alternatives table, validation procedures
  - [ ] Verify all template files in .opencode/context/ are emoji-free
- **Timing**: 1 hour
- **Text Replacement Examples**:
  - Build Status: "[PASS] All modules compile" → "[PASS] All modules compile"
  - Good/Bad: "[PASS] Clear names" → "[GOOD] Clear names"
  - Warnings: "[WARN] 3 warnings" → "[WARN] 3 warnings"

### Phase 4: Strengthen Agent Enforcement with Validation [COMPLETED]

- **Started**: 2025-12-28T20:00:00Z
- **Completed**: 2025-12-28T20:00:00Z

- **Goal**: Add NO EMOJI validation requirements to all artifact-creating agents
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/researcher.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks, reference documentation.md NO EMOJI policy
  - [ ] Update .opencode/agent/subagents/planner.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks, reference documentation.md NO EMOJI policy
  - [ ] Update .opencode/agent/subagents/implementer.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks, reference documentation.md NO EMOJI policy
  - [ ] Update .opencode/agent/subagents/task-executor.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks, reference documentation.md NO EMOJI policy
  - [ ] Update .opencode/agent/subagents/lean-research-agent.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks
  - [ ] Update .opencode/agent/subagents/lean-implementation-agent.md: Add NO EMOJI constraint to constraints block, add validation step to post_execution checks
  - [ ] Verify all 6 agent files have consistent NO EMOJI validation language
- **Timing**: 1-2 hours
- **Validation Pattern**:
  ```markdown
  <constraints>
    <must>Follow NO EMOJI standard per documentation.md</must>
    <must>Use text-based alternatives for status indicators</must>
    <must>Validate artifacts are emoji-free before returning</must>
    <must_not>Use checkmark ([PASS]), cross mark ([FAIL]), or warning ([WARN]) emojis</must_not>
    <must_not>Use any Unicode emoji characters in artifacts</must_not>
  </constraints>
  
  <validation_checks>
    <post_execution>
      - Verify artifact contains no emoji characters
      - Verify summary contains no emoji characters
      - Verify all status indicators use text format ([PASS]/[FAIL]/[WARN])
    </post_execution>
  </validation_checks>
  ```

### Phase 5: Update Quality Checklists and Command Specifications [COMPLETED]

- **Started**: 2025-12-28T20:05:00Z
- **Completed**: 2025-12-28T20:05:00Z

- **Goal**: Add emoji validation to quality checklists and strengthen command NO EMOJI tags
- **Tasks**:
  - [ ] Update .opencode/context/common/standards/documentation.md: Add emoji validation item to Quality Checklist section (line ~200)
  - [ ] Update .opencode/command/research.md: Enhance no_emojis tag with validation requirements
  - [ ] Update .opencode/command/plan.md: Enhance no_emojis tag with validation requirements
  - [ ] Update .opencode/command/implement.md: Enhance no_emojis tag with validation requirements
  - [ ] Update .opencode/command/revise.md: Enhance no_emojis tag with validation requirements
  - [ ] Update .opencode/command/task.md: Enhance no_emojis tag with validation requirements
  - [ ] Update .opencode/command/review.md: Enhance no_emojis tag with validation requirements
  - [ ] Verify all command files have consistent NO EMOJI validation language
- **Timing**: 30 minutes
- **Quality Checklist Addition**:
  ```markdown
  - [ ] No emojis used (verified with grep -E "[PASS]|[FAIL]|[WARN]" file.md)
  ```
- **Command Tag Enhancement**:
  ```markdown
  <no_emojis>
    No emojis in research reports, summaries, or status updates
    
    Validation: Before returning artifacts, verify:
    - grep -E "[PASS]|[FAIL]|[WARN]" artifact.md returns no results
    - If emojis found: Replace with text alternatives
    - Fail command if emojis cannot be removed
  </no_emojis>
  ```

### Phase 6: Final Validation and Git Commit [COMPLETED]

- **Started**: 2025-12-28T20:10:00Z
- **Completed**: 2025-12-28T20:10:00Z

- **Goal**: Verify zero emojis remain and create git commit documenting changes
- **Tasks**:
  - [ ] Run comprehensive emoji scan across entire .opencode system (rg "[PASS]|[FAIL]|[WARN]|[YES]|[NO]" .opencode --type md)
  - [ ] Verify scan returns zero results
  - [ ] Test /research command to verify no emoji artifacts created
  - [ ] Test /plan command to verify no emoji artifacts created
  - [ ] Test /implement command to verify no emoji artifacts created
  - [ ] Review git diff to verify all changes are emoji removals and documentation updates
  - [ ] Create git commit with message: "Remove all emojis from .opencode system per NO EMOJI standard (task 238)"
  - [ ] Remove backup directory (.opencode.backup) after successful commit
  - [ ] Update TODO.md task 238 status to [COMPLETED] with completion timestamp
- **Timing**: 30 minutes
- **Validation Commands**:
  ```bash
  # Should return zero results
  rg "[PASS]|[FAIL]|[WARN]|[YES]|[NO]" .opencode --type md
  
  # Count files changed
  git diff --stat
  
  # Review changes
  git diff .opencode/context/common/system/status-markers.md
  git diff .opencode/agent/subagents/researcher.md
  ```

## Testing and Validation

**Pre-Implementation Testing**:
- [ ] Verify backup created successfully (ls -la .opencode.backup)
- [ ] Verify emoji pattern matches all variants (test with sample file)

**Post-Phase-1 Testing**:
- [ ] Count remaining emojis (should be significantly reduced)
- [ ] Verify no file corruption from sed replacements (spot check 5-10 files)

**Post-Phase-2 Testing**:
- [ ] Verify high-impact files are emoji-free and semantically correct
- [ ] Verify special cases handled correctly (compliance scores, verdicts, checklists)

**Post-Phase-3 Testing**:
- [ ] Verify templates are emoji-free
- [ ] Verify status-markers.md examples are consistent with NO EMOJI policy

**Post-Phase-4 Testing**:
- [ ] Verify all 6 agent files have validation sections
- [ ] Verify validation language is consistent across agents

**Post-Phase-5 Testing**:
- [ ] Verify quality checklist includes emoji validation
- [ ] Verify all command files have enhanced NO EMOJI tags

**Final Validation**:
- [ ] Run comprehensive emoji scan (zero results expected)
- [ ] Test workflow commands (/research, /plan, /implement) to verify no emoji artifacts
- [ ] Verify git commit includes all expected changes
- [ ] Verify TODO.md updated to [COMPLETED]

## Artifacts and Outputs

**Created**:
- .opencode/specs/238_find_and_eliminate_all_emojis/plans/implementation-001.md (this file)

**Modified** (98 files total):
- .opencode/specs/TODO.md (verification only, no changes needed)
- .opencode/specs/*/reports/*.md (95 files - emoji replacements)
- .opencode/specs/*/summaries/*.md (included in 95 files)
- .opencode/specs/*/plans/*.md (included in 95 files)
- .opencode/context/common/system/status-markers.md (remove emoji examples, strengthen guidance)
- .opencode/context/common/standards/documentation.md (add NO EMOJI Policy section, update quality checklist)
- .opencode/context/common/standards/code.md (replace emoji examples)
- .opencode/context/common/standards/tests.md (replace emoji examples)
- .opencode/context/project/lean4/templates/maintenance-report-template.md (replace emoji examples)
- .opencode/context/**/*.md (11 files total with emoji replacements)
- .opencode/command/meta.md (replace emoji examples)
- .opencode/command/implement.md (verification only)
- .opencode/command/research.md (enhance NO EMOJI tag)
- .opencode/command/plan.md (enhance NO EMOJI tag)
- .opencode/command/revise.md (enhance NO EMOJI tag)
- .opencode/command/task.md (enhance NO EMOJI tag)
- .opencode/command/review.md (enhance NO EMOJI tag)
- .opencode/agent/subagents/researcher.md (add validation)
- .opencode/agent/subagents/planner.md (add validation)
- .opencode/agent/subagents/implementer.md (add validation)
- .opencode/agent/subagents/task-executor.md (add validation)
- .opencode/agent/subagents/lean-research-agent.md (add validation)
- .opencode/agent/subagents/lean-implementation-agent.md (add validation)

**Git Commit**:
- Single atomic commit documenting emoji removal and prevention mechanisms

## Rollback and Contingency

**If automated replacement introduces errors**:
- Restore from backup: rm -rf .opencode && mv .opencode.backup .opencode
- Perform manual emoji replacement on smaller file sets
- Use more conservative sed patterns with backup flags (sed -i.bak)

**If template updates break workflows**:
- Revert template changes: git checkout .opencode/context/
- Test workflows individually to identify problematic template
- Fix specific template causing issue

**If agent validation is ignored**:
- Strengthen validation language with imperative commands
- Add validation to multiple sections (constraints, process_flow, validation_checks)
- Consider adding explicit validation examples in agent specifications

**If git commit fails**:
- Review git status for conflicts or issues
- Split commit into smaller logical chunks (artifacts, documentation, agents)
- Ensure all files are staged correctly

**If emoji reintroduction occurs after implementation**:
- Review agent specifications for compliance
- Add pre-commit hook as additional enforcement layer
- Investigate which workflow introduced emojis and strengthen validation

## Success Criteria

**Completion Criteria**:
- [ ] Zero emojis in .opencode system (verified with comprehensive scan)
- [ ] All 98 files with emojis updated with text alternatives
- [ ] status-markers.md contradictions resolved
- [ ] All templates emoji-free
- [ ] All 6 agents have NO EMOJI validation
- [ ] Quality checklist includes emoji validation
- [ ] All command files have enhanced NO EMOJI tags
- [ ] Git commit created documenting changes
- [ ] TODO.md task 238 marked [COMPLETED]
- [ ] Workflow commands tested and produce emoji-free artifacts

**Quality Criteria**:
- All emoji replacements semantically correct
- No file corruption from automated replacements
- Documentation updates improve clarity
- Agent validation language is strong and imperative
- Git commit message is clear and descriptive
- No regression in workflow functionality

## Notes

**Research Integration**:
- Research report identified 1,891 emojis across 98 files
- Primary sources: research reports (1,200+), implementation summaries (400+), plans (200+)
- Root causes: inconsistent enforcement, contradictory examples, template propagation
- Recommended 5-phase approach adopted in this plan

**Emoji Replacement Patterns**:
- Checkmark ([PASS]) → [PASS], [COMPLETE], or remove
- Cross mark ([FAIL]) → [FAIL], [NOT RECOMMENDED]
- Warning ([WARN]) → [WARN], [PARTIAL]
- Checkmark variant ([YES]) → [YES]
- Cross variant ([NO]) → [NO]

**Mathematical Symbols Preserved**:
- → (arrow), ∧ (and), ∨ (or), ¬ (not), □ (box), ◇ (diamond)
- These are NOT emojis and must be preserved per documentation.md

**Effort Breakdown**:
- Phase 1: 30 minutes (automated replacement)
- Phase 2: 1-2 hours (manual verification)
- Phase 3: 1 hour (documentation/templates)
- Phase 4: 1-2 hours (agent enforcement)
- Phase 5: 30 minutes (quality checklists)
- Phase 6: 30 minutes (validation/commit)
- **Total**: 5-7 hours

**Prevention Mechanisms**:
- Agent validation (primary enforcement)
- Quality checklists (secondary enforcement)
- Enhanced command tags (tertiary enforcement)
- Optional: pre-commit hooks (future enhancement)
- Optional: CI/CD validation (future enhancement)
