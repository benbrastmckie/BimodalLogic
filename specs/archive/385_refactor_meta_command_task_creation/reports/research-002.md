# Research Report: Task #385 (Supplemental)

**Task**: Refactor /meta command to create tasks instead of direct implementation
**Date**: 2026-01-12
**Focus**: OpenAgents meta.md command interview patterns and workflow structure

## Summary

The OpenAgents `/meta` command at `/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md` provides an excellent reference implementation for structured interviewing and system building. It uses an 8-stage workflow with progressive questioning, validation checkpoints, and explicit user confirmation before any generation. Key lessons can be adapted for ProofChecker's task-creation-focused /meta command.

## Findings

### 1. Stage-Based Workflow Structure

OpenAgents uses 9 stages (0-8) with explicit transitions:

| Stage | Name | Purpose |
|-------|------|---------|
| 0 | DetectExistingProject | Check for existing system, offer merge options |
| 1 | InitiateInterview | Greet user, explain process, set expectations |
| 2 | GatherDomainInfo | Collect domain, purpose, user personas (3 questions) |
| 2.5 | DetectDomainType | Classify domain, adapt subsequent questions |
| 3 | IdentifyUseCases | Top 3-5 use cases, complexity, dependencies (3 questions) |
| 4 | AssessComplexity | Agent count, knowledge types, state requirements (3 questions) |
| 5 | IdentifyIntegrations | External tools, file operations, custom commands (3 questions) |
| 6 | ReviewAndConfirm | Present summary, get explicit user confirmation |
| 7 | GenerateSystem | Route to builder agent for generation |
| 8 | DeliverSystem | Present completed system with docs |

**Key Insight**: Stage 6 (ReviewAndConfirm) is critical - the user MUST confirm before generation. This prevents the issue we had where /meta immediately implemented changes.

### 2. Question Structure Pattern

Each question in OpenAgents follows a consistent pattern:

```xml
<question_N>
  <ask>What is your primary domain or industry?</ask>
  <examples>
    - E-commerce and online retail
    - Data engineering and analytics
    - Customer support and service
    ...
  </examples>
  <capture>domain_name, industry_type</capture>
</question_N>
```

**Key Elements**:
- Clear question text
- Concrete examples to guide user thinking
- Explicit capture variables (what data to extract from response)

### 3. Checkpoint Pattern

Every stage ends with a checkpoint that validates completion:

```xml
<checkpoint>Domain, purpose, and users clearly identified</checkpoint>
```

This ensures:
- All required information is captured before proceeding
- Progress can be tracked through stages
- User can request to return to earlier stages

### 4. Review and Confirmation Stage (Critical)

Stage 6 presents a comprehensive summary with explicit options:

```
**Does this architecture meet your needs?**

Options:
- ✅ **Proceed** - Generate the complete system
- 🔄 **Revise** - Adjust specific components
- ❌ **Cancel** - Start over
```

**Key Insight**: This is where the OpenAgents pattern differs from ProofChecker's problematic behavior. The user MUST explicitly confirm before any generation happens.

### 5. Existing Project Detection (Stage 0)

OpenAgents checks for existing infrastructure and offers merge options:

```
**Option 1: Extend Existing System** (Recommended)
- ✅ Keep all existing files
- ✅ Add new agents/workflows/commands for your new domain
...

**Option 2: Create Separate System**
...

**Option 3: Replace Existing System**
...

**Option 4: Cancel**
```

**Adaptation for ProofChecker**: /meta should analyze existing `.claude/` structure and offer options for how new tasks relate to existing system.

### 6. Interview Patterns Section

The command explicitly documents interview patterns:

```xml
<interview_patterns>
  <progressive_disclosure>
    Start with broad questions, then drill into specifics based on responses
  </progressive_disclosure>

  <adaptive_questioning>
    Adjust question complexity based on user's technical level and domain familiarity
  </adaptive_questioning>

  <example_driven>
    Provide concrete examples for every question to guide user thinking
  </example_driven>

  <validation_checkpoints>
    Summarize and confirm understanding after each phase before proceeding
  </validation_checkpoints>
</interview_patterns>
```

### 7. Key Differences from Current ProofChecker /meta

| Aspect | OpenAgents | Current ProofChecker |
|--------|------------|---------------------|
| Output | Direct file generation | Should create tasks |
| Confirmation | Required before generation | Missing |
| Stage structure | 9 explicit stages | 8 stages (poorly followed) |
| Questions | Structured with examples | Informal |
| Checkpoints | After each stage | None |
| Existing detection | Comprehensive | None |

### 8. Adaptation Strategy

For ProofChecker's task-creation /meta:

**Stage Mapping**:
1. **DetectExistingProject** → Analyze .claude/ structure, identify existing tasks
2. **InitiateInterview** → Explain task creation process (if no args)
3. **GatherDomainInfo** → Understand what user wants to accomplish
4. **DetectDomainType** → Classify: lean, meta, latex, general
5. **IdentifyUseCases** → Break down into discrete tasks
6. **AssessComplexity** → Estimate effort, identify dependencies
7. **ReviewAndConfirm** → Present task list with dependencies, get confirmation
8. **CreateTasks** → Create tasks in TODO.md + state.json (NOT implement)
9. **DeliverSummary** → Show created tasks, suggest next steps

**With Prompt**:
- Skip stages 1-3, jump to analysis
- Use AskUserQuestion for clarification
- Present task breakdown in Stage 7
- Create tasks after confirmation

**Without Prompt**:
- Full interview process
- Progressive questioning
- Build understanding of requirements
- Present task breakdown
- Create tasks after confirmation

## Recommendations

### 1. Adopt Stage-Based Structure

Replace current loose stages with explicit numbered stages with checkpoints.

### 2. Add Mandatory Confirmation Stage

Before creating ANY tasks, present a summary and require explicit user confirmation.

### 3. Use AskUserQuestion for Interactive Questioning

Leverage the existing `AskUserQuestion` tool for structured questioning:
```
AskUserQuestion:
  question: "What is the primary purpose of this change?"
  options:
    - "Add new feature"
    - "Fix existing bug"
    - "Refactor/improve"
    - "Other (describe)"
```

### 4. Implement Existing System Detection

When /meta runs with a prompt:
1. Analyze .claude/ structure
2. Identify related existing tasks/components
3. Offer options: extend, replace, or new domain

### 5. Capture Variables Pattern

For each question, explicitly define what data to capture for task creation.

### 6. Add Dependency Detection

During use case identification, explicitly ask about:
- Which tasks depend on others
- Blocking relationships
- Suggested execution order

## References

- `/home/benjamin/Projects/OpenAgents/.opencode/command/meta.md` - OpenAgents meta command
- `specs/meta-command-refactor-guide.md` - Existing refactor guide
- `.claude/context/project/meta/interview-patterns.md` - Interview patterns documentation

## Next Steps

1. Create implementation plan incorporating:
   - Stage-based structure from OpenAgents
   - Mandatory confirmation before task creation
   - AskUserQuestion for interactive questioning
   - Existing system detection
   - Dependency identification
2. Ensure the plan explicitly forbids direct implementation
3. Include test cases for both prompt and no-prompt modes
