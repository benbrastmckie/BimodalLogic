# Implementation Plan: Pragmatic /add Command Improvements

**Project**: #165  
**Version**: 002  
**Date**: 2025-12-24  
**Complexity**: Simple  
**Estimated Effort**: 2-4 hours  
**Language**: markdown  
**Status**: [PLANNED]  
**Revision Reason**: Original plan was over-engineered; this revision focuses on pragmatic improvements that add value without unnecessary complexity

---

## Revision Summary

After researching the current /add command implementation, this revised plan scales back the original ambitious redesign in favor of targeted, pragmatic improvements. The current implementation already works well with atomic numbering, lazy creation, and intelligent task breakdown. This revision preserves those strengths while making modest enhancements.

### What Changed from v001

**Removed (Over-Engineering):**
- Moving atomic number allocation to orchestrator (current delegation works fine)
- Removing batch/file/plan support (these are valuable features)
- Complex metadata inference algorithms (simple defaults are sufficient)
- Extensive auto-generation of acceptance criteria and impact statements
- 10-step phased implementation (too complex for the actual changes needed)

**Preserved (What Works):**
- Current atomic numbering via task-adder → atomic-task-number.sh
- Batch task support (multiple descriptions in one call)
- File extraction support (--file flag)
- Lazy directory creation (already correct)
- State consistency guarantees (already correct)

**Added (Pragmatic Improvements):**
- Better default values for optional metadata
- Clearer documentation of what's required vs. optional
- Simplified input validation
- Better error messages

---

## Research Inputs

This implementation plan is based on:

1. **`.opencode/specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-001.md`**
   - Atomic number reservation patterns (fetch-and-add)
   - CLI command design best practices (clig.dev)
   - State management consistency patterns

2. **`.opencode/specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-002.md`**
   - Current /add command implementation analysis
   - Gap analysis: current vs. desired behavior
   - Atomic numbering verification (already correct)

3. **Current Implementation Analysis**
   - `.opencode/command/add.md` - Already supports single-description input
   - `.opencode/agent/subagents/task-adder.md` - Already has intelligent breakdown and metadata inference
   - Atomic numbering already implemented correctly via atomic-task-number.sh

---

## Context

### System Context

The /add command already implements atomic task numbering, lazy directory creation, and intelligent task breakdown. The current system works well but could benefit from clearer documentation and better defaults for optional metadata.

### Domain Context

CLI command design for task management, focusing on:
- Minimal required input (description only)
- Sensible defaults for optional metadata
- Clear error messages
- Preserving advanced features (batch, file extraction) for power users

### Task Context

Make targeted improvements to /add command:
1. Clarify that only description is required
2. Provide better defaults for optional metadata
3. Improve documentation and error messages
4. Preserve existing features that work well

---

## Implementation Steps

### Step 1: Update Command Documentation

**File**: `.opencode/command/add.md`

**Action**: Clarify required vs. optional inputs and document defaults

**Changes**:
1. Update description to emphasize single description is sufficient
2. Document that all other metadata has sensible defaults
3. Keep usage examples showing both simple and advanced usage
4. Add section on metadata defaults

**Implementation**:
```markdown
## Description

Add tasks to TODO.md with atomic number allocation and intelligent metadata inference.

**Minimal Usage**: Provide just a description - all other metadata will be auto-populated with sensible defaults.

**Advanced Usage**: Override defaults with flags for priority, language, effort, files, etc.

**Batch Usage**: Provide multiple descriptions or use --file for bulk task creation.

## Required Input

- **Description**: Task description (required)

## Optional Input (Auto-Populated if Not Provided)

- **Priority**: Default = Medium
- **Language**: Default = markdown (inferred from description/files if possible)
- **Effort**: Default = 2 hours (inferred from description complexity)
- **Files Affected**: Default = TBD
- **Dependencies**: Default = None
- **Blocking**: Default = None
- **Acceptance Criteria**: Default = Generic checklist based on description
- **Impact**: Default = Generic statement based on description

## Usage Examples

### Simple (Recommended for Quick Tasks)
```bash
/add "Fix typo in README"
# → Task #168 created with all metadata auto-populated
```

### With Optional Overrides
```bash
/add "Implement feature X" --priority High --language lean --effort "4 hours"
# → Task #169 created with specified metadata
```

### Batch Creation
```bash
/add "Task 1" "Task 2" "Task 3"
# → Tasks #170, #171, #172 created
```

### File Extraction
```bash
/add --file docs/FEATURES.md
# → Extracts tasks from file and creates them
```
```

**Verification**:
- [ ] Documentation clearly states description is the only required field
- [ ] Defaults are documented for all optional fields
- [ ] Examples show both simple and advanced usage
- [ ] Batch and file extraction examples preserved

---

### Step 2: Update Task-Adder Metadata Defaults

**File**: `.opencode/agent/subagents/task-adder.md`

**Action**: Document and improve default metadata values

**Changes**:
1. Add explicit default values section
2. Document inference logic for effort and language
3. Keep existing intelligent breakdown and grouping
4. Simplify acceptance criteria and impact generation

**Implementation**:
```markdown
## Metadata Defaults

When metadata is not provided by user, task-adder applies these defaults:

### Always Auto-Populated
- **Status**: [NOT STARTED]
- **Task Number**: From atomic-task-number.sh

### Sensible Defaults (Used if Not Provided)
- **Priority**: Medium
- **Language**: markdown (or inferred from file paths/keywords)
- **Effort**: 2 hours (or inferred from description complexity)
- **Files Affected**: TBD
- **Dependencies**: None
- **Blocking**: None

### Auto-Generated (Simple Templates)
- **Acceptance Criteria**: 
  - [ ] {Description} completed
  - [ ] Changes tested
  - [ ] Documentation updated (if applicable)

- **Impact**: 
  - Addresses: {Description}

### Inference Logic

**Language Inference**:
- If description mentions "Lean", "proof", "theorem" → language: lean
- If description mentions "markdown", "README", "docs" → language: markdown
- If file paths provided → infer from extensions
- Otherwise → default: markdown

**Effort Inference**:
- Description < 10 words → 1 hour
- Description 10-20 words → 2 hours
- Description 20-40 words → 3-4 hours
- Description > 40 words or mentions "research", "implement" → 4+ hours
- User can always override with --effort flag
```

**Verification**:
- [ ] Defaults are clearly documented
- [ ] Inference logic is simple and understandable
- [ ] Auto-generation uses simple templates (not complex algorithms)
- [ ] User can override any default

---

### Step 3: Improve Input Validation and Error Messages

**File**: `.opencode/command/add.md`

**Action**: Add better validation and error messages

**Changes**:
1. Validate description is non-empty
2. Provide helpful error messages
3. Suggest correct usage on errors

**Implementation**:
```markdown
## Input Validation

<validation>
  <pre_flight>
    1. Validate at least one description provided
    2. Validate descriptions are non-empty strings
    3. Validate --file path exists if provided
    4. Reject invalid flag combinations
  </pre_flight>
  
  <error_messages>
    - Empty description: "Error: Description cannot be empty. Usage: /add \"task description\""
    - No input: "Error: No task description provided. Usage: /add \"task description\""
    - Invalid file: "Error: File not found: {path}. Check the path and try again."
    - Invalid flags: "Error: Unknown flag: {flag}. See /add --help for valid flags."
  </error_messages>
</validation>
```

**Verification**:
- [ ] Empty descriptions rejected with clear error
- [ ] Error messages suggest correct usage
- [ ] Invalid file paths caught early
- [ ] Unknown flags reported clearly

---

### Step 4: Update Standards Documentation

**File**: `.opencode/context/core/standards/tasks.md`

**Action**: Document metadata defaults and auto-population strategy

**Changes**:
1. Add section on metadata defaults
2. Document what's required vs. optional
3. Explain when to override defaults

**Implementation**:
```markdown
## Task Metadata Requirements

### Required Fields
- **Description**: Clear description of the task (user must provide)

### Auto-Populated Fields (Defaults Used if Not Provided)
- **Priority**: Medium (override if task is urgent or low priority)
- **Language**: markdown (override if task involves code)
- **Effort**: 2 hours (override if you have better estimate)
- **Files Affected**: TBD (override if you know which files)
- **Dependencies**: None (override if task depends on others)
- **Blocking**: None (override if task blocks others)
- **Acceptance Criteria**: Generic checklist (override for specific criteria)
- **Impact**: Generic statement (override for specific impact)

### When to Override Defaults

**Override Priority** when:
- Task is urgent or blocking critical work → High
- Task is nice-to-have or low impact → Low

**Override Language** when:
- Task involves Lean code → lean
- Task involves specific language → specify language

**Override Effort** when:
- You have a better estimate based on task complexity
- Task is known to be quick (<1 hour) or long (>4 hours)

**Override Files Affected** when:
- You know which files will be modified
- Task is file-specific (e.g., "Fix bug in Foo.lean")

**Override Acceptance Criteria** when:
- Task has specific, measurable success criteria
- Generic checklist is not sufficient

**Override Impact** when:
- Task has significant impact on project
- Generic statement doesn't capture importance
```

**Verification**:
- [ ] Clear distinction between required and optional
- [ ] Guidance on when to override defaults
- [ ] Examples of good override scenarios

---

### Step 5: Add Quick Reference to Command

**File**: `.opencode/command/add.md`

**Action**: Add quick reference section for common patterns

**Changes**:
1. Add "Quick Reference" section at top
2. Show most common usage patterns
3. Link to full documentation

**Implementation**:
```markdown
## Quick Reference

**Most Common Usage** (90% of cases):
```bash
/add "Task description"
```

**With Priority Override**:
```bash
/add "Urgent task" --priority High
```

**Lean Task**:
```bash
/add "Prove theorem X" --language lean
```

**Batch Tasks**:
```bash
/add "Task 1" "Task 2" "Task 3"
```

**From File**:
```bash
/add --file path/to/tasks.md
```

For full documentation, see sections below.
```

**Verification**:
- [ ] Quick reference shows most common patterns
- [ ] Simple usage is emphasized
- [ ] Advanced usage is available but not prominent

---

## File Structure

```
.opencode/
├── command/
│   └── add.md                          # MODIFIED: Better docs, validation, quick reference
├── agent/
│   └── subagents/
│       └── task-adder.md               # MODIFIED: Document defaults, simplify inference
├── context/
│   └── common/
│       └── standards/
│           └── tasks.md                # MODIFIED: Document required vs. optional
└── specs/
    ├── TODO.md                         # NO CHANGES
    ├── state.json                      # NO CHANGES
    └── 165_make_add_command_single_description_with_immediate_number_increment/
        ├── reports/
        │   ├── research-001.md         # RESEARCH INPUT
        │   └── research-002.md         # RESEARCH INPUT
        ├── summaries/
        │   └── research-summary.md     # RESEARCH INPUT
        └── plans/
            ├── implementation-001.md   # PREVIOUS PLAN (over-engineered)
            └── implementation-002.md   # THIS PLAN (pragmatic)
```

---

## Testing Strategy

### Manual Testing

**Test 1: Simple Task Creation**
```bash
Input: /add "Fix typo in README"
Expected: Task created with all metadata auto-populated
Verify: TODO.md entry has sensible defaults
```

**Test 2: Task with Overrides**
```bash
Input: /add "Prove theorem" --priority High --language lean
Expected: Task created with specified priority and language
Verify: Overrides applied correctly
```

**Test 3: Batch Creation**
```bash
Input: /add "Task 1" "Task 2" "Task 3"
Expected: Three tasks created with sequential numbers
Verify: All tasks in TODO.md with correct numbers
```

**Test 4: Error Handling**
```bash
Input: /add ""
Expected: Error message with usage guidance
Verify: No task created, clear error message
```

**Test 5: File Extraction**
```bash
Input: /add --file docs/FEATURES.md
Expected: Tasks extracted and created
Verify: All tasks from file in TODO.md
```

### Verification Checklist

- [ ] Simple usage works (description only)
- [ ] Defaults are applied correctly
- [ ] Overrides work as expected
- [ ] Batch creation works
- [ ] File extraction works
- [ ] Error messages are clear and helpful
- [ ] Documentation is accurate
- [ ] Atomic numbering preserved
- [ ] Lazy directory creation preserved
- [ ] State consistency maintained

---

## Success Criteria

### Primary Success Criteria

1. **Simple Usage Works**
   - `/add "description"` creates task with sensible defaults
   - No errors, no prompts, just works

2. **Documentation is Clear**
   - Users understand description is the only required field
   - Users know how to override defaults when needed
   - Examples show common patterns

3. **Existing Features Preserved**
   - Batch creation still works
   - File extraction still works
   - Atomic numbering still works
   - Lazy directory creation still works

4. **Better Defaults**
   - Priority: Medium (reasonable default)
   - Language: markdown (safe default)
   - Effort: 2 hours (reasonable default)
   - Other fields: TBD/None (safe defaults)

### Secondary Success Criteria

5. **Better Error Messages**
   - Empty description rejected with helpful message
   - Invalid flags reported clearly
   - File not found errors are clear

6. **Improved Documentation**
   - Quick reference for common patterns
   - Clear required vs. optional distinction
   - Guidance on when to override defaults

---

## Verification Checkpoints

### Pre-Flight Checks

- [ ] Current /add implementation reviewed
- [ ] Research reports reviewed
- [ ] Over-engineering identified and removed from plan
- [ ] Pragmatic improvements identified

### Mid-Flight Checks

**After Step 1 (Documentation)**:
- [ ] Command documentation updated
- [ ] Quick reference added
- [ ] Usage examples clear

**After Step 2 (Defaults)**:
- [ ] Task-adder defaults documented
- [ ] Inference logic simplified
- [ ] Auto-generation uses simple templates

**After Step 3 (Validation)**:
- [ ] Input validation added
- [ ] Error messages improved
- [ ] Usage guidance in errors

**After Step 4 (Standards)**:
- [ ] Standards documentation updated
- [ ] Required vs. optional clarified
- [ ] Override guidance added

**After Step 5 (Quick Reference)**:
- [ ] Quick reference added
- [ ] Common patterns shown
- [ ] Simple usage emphasized

### Post-Flight Checks

**Functionality**:
- [ ] Simple usage works (description only)
- [ ] Defaults applied correctly
- [ ] Overrides work
- [ ] Batch creation works
- [ ] File extraction works
- [ ] Error handling works

**Documentation**:
- [ ] Documentation accurate
- [ ] Examples work as shown
- [ ] Quick reference helpful
- [ ] Standards updated

**Preservation**:
- [ ] Atomic numbering preserved
- [ ] Lazy directory creation preserved
- [ ] State consistency preserved
- [ ] Batch support preserved
- [ ] File extraction preserved

---

## Documentation Requirements

### Command Documentation

**File**: `.opencode/command/add.md`

**Required Updates**:
1. Quick reference section
2. Required vs. optional inputs
3. Metadata defaults table
4. Usage examples (simple and advanced)
5. Error messages documentation
6. Validation rules

### Standards Documentation

**File**: `.opencode/context/core/standards/tasks.md`

**Required Updates**:
1. Metadata requirements (required vs. optional)
2. Default values table
3. Override guidance
4. Examples of when to override

### Subagent Documentation

**File**: `.opencode/agent/subagents/task-adder.md`

**Required Updates**:
1. Metadata defaults section
2. Inference logic documentation
3. Auto-generation templates
4. Override handling

---

## Related Research

### Research Reports

1. **Atomic Number Reservation and CLI Command Design Best Practices**
   - Path: `.opencode/specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-001.md`
   - Key Finding: Current atomic numbering already follows best practices (fetch-and-add pattern)

2. **Current /add Implementation Analysis and Gap Analysis**
   - Path: `.opencode/specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-002.md`
   - Key Finding: Current implementation already supports single-description input and has intelligent features

### Key Insights

1. **Current Implementation is Good**
   - Atomic numbering already correct
   - Lazy directory creation already correct
   - Intelligent task breakdown already exists
   - Batch and file support are valuable features

2. **Original Plan Was Over-Engineered**
   - Moving number allocation to orchestrator: unnecessary complexity
   - Removing batch/file support: removes valuable features
   - Complex inference algorithms: simple defaults are sufficient
   - Extensive auto-generation: simple templates are better

3. **Pragmatic Improvements Needed**
   - Better documentation of what's required vs. optional
   - Clearer default values
   - Better error messages
   - Quick reference for common patterns

---

## Notes

### Why This Revision?

The original plan (implementation-001.md) proposed extensive changes:
- Moving atomic number allocation to orchestrator
- Removing batch/file/plan support
- Complex metadata inference algorithms
- Extensive auto-generation of criteria and impact
- 10-step phased implementation

After researching the current implementation, these changes are **over-engineered**:
- Current atomic numbering already works correctly
- Batch/file support are valuable features worth keeping
- Simple defaults are better than complex inference
- Current task-adder already has intelligent breakdown

This revision focuses on **pragmatic improvements**:
- Better documentation (what's required vs. optional)
- Clearer defaults (simple, understandable)
- Better error messages (helpful, actionable)
- Preserve what works (batch, file, atomic numbering)

### Implementation Philosophy

**Keep It Simple**:
- Don't fix what isn't broken
- Don't remove features that work
- Don't add complexity without clear benefit

**Focus on User Experience**:
- Make simple usage obvious
- Make advanced usage available
- Make errors helpful

**Preserve Correctness**:
- Keep atomic numbering
- Keep lazy directory creation
- Keep state consistency

### Future Enhancements (Not in This Plan)

These could be considered later if needed:
- ML-based effort estimation (current simple heuristic is fine)
- Context-aware language detection (current inference is fine)
- Smart file path inference (TBD placeholder is fine)
- Interactive mode (not needed for CLI)

**Principle**: Don't add features until there's a clear need.

---

## Comparison: v001 vs. v002

### What v001 Proposed (Over-Engineered)

1. Move atomic number allocation to orchestrator
2. Remove batch task support
3. Remove file extraction support
4. Remove plan artifact support
5. Complex metadata inference algorithms
6. Extensive auto-generation of criteria/impact
7. 10-step phased implementation
8. 1730 lines of detailed implementation steps

### What v002 Proposes (Pragmatic)

1. Keep atomic number allocation in task-adder (works fine)
2. Keep batch task support (valuable feature)
3. Keep file extraction support (valuable feature)
4. Keep plan artifact support (valuable feature)
5. Simple metadata defaults (easy to understand)
6. Simple template-based auto-generation (good enough)
7. 5-step focused implementation
8. Clear documentation improvements

### Why v002 is Better

- **Simpler**: 5 steps vs. 10 steps
- **Preserves Features**: Keeps batch/file support
- **Less Risk**: Doesn't change working atomic numbering
- **Better Defaults**: Simple, understandable defaults
- **Clearer Docs**: Focus on documentation improvements
- **Pragmatic**: Solves real problems without over-engineering

---

**End of Implementation Plan**
