# Research Report: Enhance Task Command with Description Improvement

- **Task**: 756 - enhance_task_command_with_description_improvement
- **Started**: 2026-01-29T12:00:00Z
- **Completed**: 2026-01-29T12:15:00Z
- **Effort**: 1-2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/task.md` - Current task command implementation
  - `specs/state.json` - Sample task descriptions
  - `specs/TODO.md` - Sample task descriptions in context
  - `.claude/context/core/formats/report-format.md` - Report standards
- **Artifacts**:
  - `specs/756_enhance_task_command_with_description_improvement/reports/research-001.md`
- **Standards**: report-format.md, artifact-formats.md, state-management.md

## Executive Summary

- Current `/task` command stores descriptions verbatim with no refinement
- Description quality varies significantly: some are detailed and action-oriented, others are just slugs
- A lightweight transformation step can improve consistency without over-engineering
- Integration point is clearly between Step 2 (parse description) and Step 3 (detect language)
- Transformation should use inline Claude reasoning, not external tools or services
- Key constraint: preserve ALL technical details while improving clarity

## Context & Scope

### Problem Statement

User-provided task descriptions vary in quality:
- Some are complete sentences with clear verbs: "Update TODO.md header metrics to reflect current sorry count"
- Some are abbreviated: "fix bug in x.py"
- Some are project slugs only: "implement_option_c_forward_truth_lemma"
- Some use passive voice or unclear structure

### Constraints

1. **Lightweight**: No external API calls, web lookups, or heavy processing
2. **Preserve intent**: Never change the meaning or drop technical details
3. **Fast execution**: Must not slow down task creation perceptibly
4. **Contained change**: Modify only the "Create Task Mode" section of task.md
5. **Idempotent**: Re-processing an already-good description should not degrade it

### Current Implementation Flow

From `.claude/commands/task.md`:

```
Step 1: Read next_project_number via jq
Step 2: Parse description from $ARGUMENTS (extract flags, optional params)
Step 3: Detect language from keywords
Step 4: Create slug from description
Step 5: Update state.json
Step 6: Update TODO.md
Step 7: Git commit
Step 8: Output
```

**Insertion Point**: New Step 2.5 between parsing and language detection.

## Findings

### Current Task Description Quality Analysis

**Well-formed descriptions** (from recent tasks):
- "Update TODO.md header metrics to reflect current sorry count. Header shows sorry_count: 205 but actual count is 265."
- "Audit and reduce sorry count in Theories/Bimodal/Metalogic/ (excluding Boneyard). Currently 45 sorries..."
- "Create/update README.md in each subdirectory of Bimodal/Metalogic/ providing full and accurate documentation..."

**Poorly-formed descriptions** (needing improvement):
- `implement_option_c_forward_truth_lemma` (slug-only, no verb, no context)
- `prove_sorries_in_coherentconstruction` (slug-only)
- "fix bug in X" (vague, no specifics)

### Transformation Principles

Based on analysis, the improvement step should:

1. **Ensure action-oriented opening**: Start with a verb (implement, create, fix, update, refactor, investigate)
2. **Expand slugs**: Convert `snake_case` slugs to human-readable sentences
3. **Clarify vague terms**: "fix bug" -> "Fix [specific bug description]" (but only if context allows)
4. **Standardize formatting**: Consistent capitalization, punctuation
5. **Preserve technical precision**: File paths, line numbers, error messages, mathematical terms must remain exact

### What NOT to Transform

- **Technical terms**: Keep "Kripke semantics", "forwardTruth", "modal logic" exactly as written
- **File paths**: Keep `/home/benjamin/Projects/...` exactly as written
- **Code references**: Keep `CoherentConstruction.lean`, `sorry_count: 205` exactly
- **Mathematical notation**: Keep `n < m`, `\forall`, etc. exactly
- **Quoted strings**: Keep anything in quotes exactly as written
- **Abbreviations that are clear**: "README", "TODO", "API", "MCP" are fine

### Slug Expansion Patterns

| Input Pattern | Output Pattern |
|---------------|----------------|
| `implement_feature_name` | "Implement feature name" |
| `fix_bug_in_module` | "Fix bug in module" |
| `prove_sorries_in_X` | "Prove sorries in X" |
| `refactor_system_component` | "Refactor system component" |
| `create_new_agent` | "Create new agent" |

### Transformation Algorithm

```
function improve_description(raw_input):
    # Step 1: Check if already well-formed (starts with capital letter and verb)
    if starts_with_action_verb(raw_input) and is_sentence(raw_input):
        return raw_input  # No change needed

    # Step 2: Detect if it's a slug (contains underscores, no spaces)
    if is_slug_format(raw_input):
        # Convert snake_case to title case with spaces
        improved = slug_to_sentence(raw_input)
        return capitalize_first(improved)

    # Step 3: Handle short/abbreviated input
    if word_count(raw_input) < 5 and no_verb_detected(raw_input):
        # Prepend appropriate action verb based on keywords
        return infer_and_prepend_verb(raw_input)

    # Step 4: Fix capitalization and punctuation
    return normalize_formatting(raw_input)
```

### Integration Approach

The transformation should be implemented as **inline Claude reasoning** within the command file, not as a separate script or external call. This keeps it:
- Self-contained within task.md
- Visible and auditable
- Easy to modify

### Proposed Implementation

Add between Step 2 and Step 3 in task.md:

```markdown
### Step 2.5: Improve description quality

Apply lightweight transformations to ensure consistency:

**2.5.1 - If description is a snake_case slug**:
- Replace underscores with spaces
- Capitalize the first letter
- Example: `prove_sorries_in_coherentconstruction` -> "Prove sorries in CoherentConstruction"

**2.5.2 - If description lacks an action verb**:
- Prepend an appropriate verb based on context:
  - Contains "bug", "error", "fix" -> "Fix"
  - Contains "new", "create", "add" -> "Create"
  - Contains "update", "change", "modify" -> "Update"
  - Contains "remove", "delete" -> "Remove"
  - Contains "refactor", "improve" -> "Refactor"
  - Contains "investigate", "analyze" -> "Investigate"
  - Default -> "Implement"

**2.5.3 - Ensure proper formatting**:
- Capitalize first letter of sentence
- Remove trailing whitespace
- Do not add period (descriptions are titles, not sentences)

**Preserve exactly**:
- All file paths and line numbers
- All technical terms and identifiers
- All quoted strings
- All numbers and metrics
- All command names and flags
```

### Edge Cases

| Input | Expected Output | Notes |
|-------|-----------------|-------|
| "fix bug" | "Fix bug" | Minimal - just capitalize |
| `implement_feature` | "Implement feature" | Slug expansion |
| "Add new test for X" | "Add new test for X" | Already good - no change |
| "the CoherentConstruction file has issues" | "Fix the CoherentConstruction file issues" or leave as is | Borderline - could infer verb but risky |
| `"quoted_input"` | `"quoted_input"` | Preserve quotes exactly |

### Risk: Over-transformation

The biggest risk is changing user intent. Mitigation:
- Be conservative - when in doubt, don't transform
- Never change technical terms
- Never add information not in the original
- Keep the original description accessible (in git history)

## Decisions

1. **Insertion point**: Step 2.5 between parse and language detection
2. **Implementation style**: Inline Claude reasoning, not external script
3. **Conservative approach**: Only transform clear cases (slugs, missing verbs)
4. **Preservation rule**: Technical details always kept verbatim
5. **No period**: Descriptions are titles, not sentences

## Recommendations

1. **Implement Step 2.5** as described with the three sub-steps (slug expansion, verb addition, formatting)
2. **Add examples** in the command documentation showing before/after transformations
3. **Add a note** reminding the executor to preserve technical details
4. **Consider adding** a `--raw` flag to bypass transformation if users want exact preservation
5. **Test with existing tasks** - verify the algorithm would have improved historic descriptions

### Implementation Priority

- **High**: Slug expansion (2.5.1) - Most common issue, clear transformation
- **High**: Formatting normalization (2.5.3) - Low risk, high consistency value
- **Medium**: Verb inference (2.5.2) - Useful but requires careful keyword matching

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-transformation changes meaning | High | Conservative rules, preserve technical terms |
| Slug expansion misinterprets compound words | Medium | Keep domain-specific terms (CamelCase) intact |
| Verb inference adds wrong verb | Medium | Use "Implement" as safe default |
| Performance impact | Low | Inline reasoning adds negligible overhead |
| User confusion about description changes | Low | Original preserved in git, could log transformation |

## Appendix

### Sample Transformations

| Original | Improved |
|----------|----------|
| `prove_sorries_in_coherentconstruction` | "Prove sorries in CoherentConstruction" |
| `implement_option_b_forward_truth_lemma` | "Implement option B forward truth lemma" |
| "bug in modal evaluator" | "Fix bug in modal evaluator" |
| "Update TODO.md header metrics..." | "Update TODO.md header metrics..." (no change) |
| "the sorry count is wrong" | "Fix the sorry count issue" or "Investigate the sorry count discrepancy" |

### Action Verb Reference

Common task verbs by category:
- **Creation**: Create, Add, Implement, Build, Design
- **Modification**: Update, Modify, Change, Refactor, Enhance
- **Removal**: Remove, Delete, Deprecate, Clean up
- **Investigation**: Investigate, Analyze, Research, Review, Audit
- **Repair**: Fix, Resolve, Repair, Correct, Address
- **Documentation**: Document, Write, Describe, Explain

### Files to Modify

- `.claude/commands/task.md` - Add Step 2.5 between Steps 2 and 3
