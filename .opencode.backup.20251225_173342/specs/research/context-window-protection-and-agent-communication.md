# Research Report: Context Window Protection and Artifact-Based Agent Communication

**Research Date**: 2024-12-24  
**Topic**: Best practices for hierarchical agent systems, artifact-based communication, and summary generation  
**Purpose**: Improve /task command system implementation

---

## Executive Summary

This research report synthesizes best practices for building hierarchical agent systems with a focus on:
1. **Context window protection** through artifact-based communication
2. **Subagent delegation patterns** that minimize context bloat
3. **Summary generation standards** for concise reporting
4. **Plan-based vs direct execution workflows** for different task complexities

The findings are based on Anthropic's official guidance on building effective agents, academic research on LLM agents, and established patterns for prompt chaining and agent orchestration.

---

## 1. Context Window Protection in Hierarchical Agent Systems

### 1.1 Core Principles

**Key Finding**: The most successful agent implementations use simple, composable patterns rather than complex frameworks. Context window protection is achieved through careful orchestration rather than sophisticated abstraction layers.

**Source**: Anthropic's "Building Effective Agents" (Dec 2024)

### 1.2 Best Practices for Context Protection

#### A. Workflow Decomposition
- **Prompt Chaining**: Break complex tasks into sequential steps where each LLM call processes the output of the previous one
- **Benefit**: Each step operates on a focused subset of information rather than the entire context
- **Pattern**: Task → Subtask 1 → Subtask 2 → ... → Final Result

#### B. Orchestrator-Workers Pattern
- **Structure**: Central orchestrator delegates to specialized worker agents
- **Context Management**: 
  - Orchestrator maintains high-level task state
  - Workers receive only task-specific context
  - Workers return structured results, not full context
- **When to Use**: Complex tasks where subtasks can't be predicted in advance

#### C. Artifact-Based Communication
- **Pattern**: Subagents create artifacts (files, structured data) and return only:
  1. Reference/path to artifact
  2. Brief summary of contents
  3. Metadata (status, key metrics)
- **Benefit**: Primary agent's context contains pointers, not full content

### 1.3 Anti-Patterns to Avoid

❌ **Passing full responses back to orchestrator**
- Causes: Exponential context growth
- Solution: Extract key information, store details in artifacts

❌ **Nested agent calls without summarization**
- Causes: Context bloat from intermediate steps
- Solution: Each level summarizes before passing up

❌ **Keeping all intermediate results in context**
- Causes: Unnecessary token consumption
- Solution: Write to files, pass references

---

## 2. Artifact-Based Agent Communication

### 2.1 Standard Patterns

#### Pattern 1: Create-Reference-Summarize
```
Subagent Workflow:
1. Execute task
2. Create artifact (file, report, data structure)
3. Return to orchestrator:
   {
     "artifact_path": "path/to/artifact.md",
     "summary": "Brief 2-3 sentence summary",
     "status": "success|partial|failed",
     "key_metrics": {...}
   }
```

#### Pattern 2: Progressive Summarization
```
Level 1 (Worker): Detailed implementation → Artifact
Level 2 (Orchestrator): Artifact references → Summary
Level 3 (Primary): Summaries → Final report
```

### 2.2 Artifact Structure Standards

#### A. Implementation Artifacts
**Location**: `.opencode/specs/{task_id}/`

**Structure**:
```
{task_id}/
├── plans/
│   └── implementation-001.md
├── reports/
│   └── research-001.md
├── summaries/
│   └── implementation-summary-YYYYMMDD.md
└── artifacts/
    └── {generated-files}
```

#### B. Summary Artifacts
**Purpose**: Quick reference without reading full implementation

**Required Sections**:
1. **What Changed**: 2-3 sentences
2. **Files Modified**: List with one-line descriptions
3. **Key Decisions**: Bullet points
4. **Status**: Complete/Partial/Blocked
5. **Next Steps**: If applicable

**Example**:
```markdown
## Summary

Implemented bounded search with depth/visit limits and structural axiom 
matching for all 14 schemas. Replaced stubs with working implementations.

### Files Modified
- `Logos/Core/Automation/ProofSearch.lean`: Added bounded_search, matches_axiom
- `LogosTest/Core/Automation/ProofSearchTest.lean`: Added 12 new tests

### Status
✅ Complete - All acceptance criteria met

### Key Metrics
- Functions implemented: 2
- Tests added: 12
- Axiom schemas covered: 14/14
```

### 2.3 Metadata Standards

**Minimum Required Metadata**:
```json
{
  "task_id": "126",
  "status": "complete|partial|blocked",
  "artifact_type": "implementation|research|plan|summary",
  "created": "2024-12-24",
  "files_modified": ["path1", "path2"],
  "key_metrics": {
    "functions_added": 2,
    "tests_added": 12,
    "lines_changed": 450
  }
}
```

---

## 3. Summary Generation Standards

### 3.1 Principles for Effective Summaries

**From Research**: Summaries should balance brevity with completeness by focusing on:
1. **Actionable information**: What changed, what's next
2. **Decision points**: Key choices made and why
3. **Status indicators**: Clear success/failure/partial markers
4. **Context preservation**: Enough info to understand without reading full artifact

### 3.2 Summary Templates by Task Type

#### A. Simple Task Summary (Direct Execution)
```markdown
## Task {ID}: {Title}

**Status**: ✅ Complete | ⚠️ Partial | ❌ Blocked

### Changes
- {File}: {One-line description}
- {File}: {One-line description}

### Commit
{commit-hash}: {commit-message}

### Notes
{Any important context or decisions}
```

#### B. Complex Task Summary (Multi-Phase)
```markdown
## Task {ID}: {Title}

**Status**: ✅ Complete | ⚠️ Partial | ❌ Blocked  
**Phases Completed**: {X}/{Y}

### Phase Summaries
1. **{Phase Name}**: {One sentence outcome}
2. **{Phase Name}**: {One sentence outcome}

### Key Artifacts
- Plan: `.opencode/specs/{id}/plans/implementation-001.md`
- Research: `.opencode/specs/{id}/reports/research-001.md`
- Summary: `.opencode/specs/{id}/summaries/summary-YYYYMMDD.md`

### Files Modified
- {File}: {Description}

### Commits
- {hash}: {Phase 1 message}
- {hash}: {Phase 2 message}

### Impact
{2-3 sentences on what this enables or improves}
```

### 3.3 Summary Length Guidelines

| Task Complexity | Summary Length | Detail Level |
|----------------|----------------|--------------|
| Simple (1 file, <100 LOC) | 3-5 sentences | High-level only |
| Medium (2-3 files, <500 LOC) | 1 paragraph + bullets | Key changes + decisions |
| Complex (4+ files, 500+ LOC) | 2-3 paragraphs + structured sections | Full context with references |

### 3.4 Summary Anti-Patterns

❌ **Too Detailed**: Copying large code blocks or full file contents
- Solution: Reference line numbers, describe changes conceptually

❌ **Too Vague**: "Updated files" without specifics
- Solution: Name files and describe what changed in each

❌ **Missing Context**: No explanation of why changes were made
- Solution: Include 1-2 sentences on motivation/rationale

❌ **No Status Indicators**: Unclear if task is complete
- Solution: Always include clear status markers (✅ ⚠️ ❌)

---

## 4. Plan-Based vs Direct Execution Workflows

### 4.1 Decision Framework

**Use Direct Execution When**:
- Single file modification
- Well-defined, straightforward change
- No research or design decisions needed
- Estimated effort < 2 hours
- Clear acceptance criteria

**Use Plan-Based Execution When**:
- Multiple files affected
- Requires research or design decisions
- Complex interdependencies
- Estimated effort > 2 hours
- Unclear implementation path

### 4.2 Workflow Patterns

#### A. Simple Task (Direct Execution)
```
1. Parse task from TODO.md
2. Execute implementation directly
3. Run tests
4. Create single commit
5. Update TODO.md with completion
6. Return brief summary (3-5 sentences)
```

**Context Protection**:
- No intermediate artifacts needed
- Summary returned directly in response
- Minimal context consumption

**Git Pattern**:
```bash
git commit -m "Complete Task {ID}: {Title}

{2-3 sentence description}

Closes #{ID}"
```

#### B. Complex Task (Plan-Based Execution)
```
Phase 1: Research & Planning
  - Create research report → artifact
  - Create implementation plan → artifact
  - Return: {research_path, plan_path, summary}

Phase 2: Implementation
  - Execute plan phases
  - Create phase summaries → artifacts
  - Commit per phase or logical unit
  - Return: {commits[], summary}

Phase 3: Finalization
  - Create final summary → artifact
  - Update registries
  - Return: {summary_path, brief_summary}
```

**Context Protection**:
- Each phase creates artifacts
- Orchestrator receives only summaries
- Full details in artifact files

**Git Pattern**:
```bash
# Phase 1
git commit -m "Task {ID} Phase 1: Research and Planning"

# Phase 2
git commit -m "Task {ID} Phase 2: Implement {component}"

# Phase 3
git commit -m "Task {ID} Phase 3: Tests and Documentation

Complete Task {ID}: {Title}
Closes #{ID}"
```

### 4.3 Complexity Indicators

**Metrics for Determining Complexity**:

| Indicator | Simple | Complex |
|-----------|--------|---------|
| Files affected | 1 | 2+ |
| Estimated LOC | <100 | 100+ |
| Dependencies | None | Multiple |
| Research needed | No | Yes |
| Design decisions | 0-1 | 2+ |
| Test files | 0-1 | 2+ |
| Estimated time | <2 hours | 2+ hours |

**Scoring**: If 4+ indicators point to "Complex", use plan-based workflow.

---

## 5. Recommendations for /task Command Implementation

### 5.1 Core Architecture

```
/task {id} or /task {start}-{end}

┌─────────────────────────────────────┐
│   Primary Agent (Orchestrator)      │
│   - Parse task(s) from TODO.md      │
│   - Determine complexity             │
│   - Delegate to appropriate workflow │
└─────────────────────────────────────┘
           │
           ├─── Simple Task ───────────────────┐
           │                                   │
           │    ┌──────────────────────────┐  │
           │    │  Direct Executor Agent   │  │
           │    │  - Implement             │  │
           │    │  - Test                  │  │
           │    │  - Commit                │  │
           │    │  - Return summary        │  │
           │    └──────────────────────────┘  │
           │                                   │
           └─── Complex Task ─────────────────┐
                                               │
                ┌──────────────────────────┐  │
                │  Plan-Based Executor     │  │
                │  Phase 1: Research       │  │
                │    → Create artifacts    │  │
                │    → Return summary      │  │
                │  Phase 2: Implement      │  │
                │    → Create artifacts    │  │
                │    → Return summary      │  │
                │  Phase 3: Finalize       │  │
                │    → Create summary      │  │
                │    → Return reference    │  │
                └──────────────────────────┘  │
```

### 5.2 Context Window Protection Strategy

**Level 1: Primary Agent**
- Receives: Task ID(s), TODO.md content
- Maintains: Task queue, high-level status
- Stores: Artifact references, brief summaries
- Returns to user: Consolidated summary with artifact links

**Level 2: Executor Agents**
- Receive: Single task specification
- Maintain: Implementation details
- Store: Full artifacts in `.opencode/specs/{id}/`
- Return: Summary + artifact references

**Level 3: Specialist Agents (if needed)**
- Receive: Specific subtask (e.g., "research X")
- Maintain: Detailed findings
- Store: Specialized artifacts
- Return: Focused summary

### 5.3 Artifact Organization

```
.opencode/specs/{task_id}/
├── plans/
│   └── implementation-{version}.md
├── reports/
│   ├── research-{topic}.md
│   └── analysis-{aspect}.md
├── summaries/
│   ├── phase-{N}-summary.md
│   └── final-summary-YYYYMMDD.md
└── artifacts/
    └── {any-generated-files}
```

### 5.4 Summary Return Format

**For Simple Tasks**:
```json
{
  "task_id": "126",
  "status": "complete",
  "summary": "Implemented bounded_search and matches_axiom in ProofSearch.lean. Added 12 tests covering all 14 axiom schemas. All acceptance criteria met.",
  "files_modified": [
    "Logos/Core/Automation/ProofSearch.lean",
    "LogosTest/Core/Automation/ProofSearchTest.lean"
  ],
  "commit": "abc123: Complete Task 126: Implement bounded_search and matches_axiom"
}
```

**For Complex Tasks**:
```json
{
  "task_id": "148",
  "status": "complete",
  "summary": "Updated command standards to require registry synchronization. Modified 4 command specifications and 2 workflow documents.",
  "artifacts": {
    "plan": ".opencode/specs/148/plans/implementation-001.md",
    "research": ".opencode/specs/148/reports/research-001.md",
    "summary": ".opencode/specs/148/summaries/final-summary-20241224.md"
  },
  "phases_completed": 3,
  "commits": [
    "def456: Task 148 Phase 1: Research command patterns",
    "ghi789: Task 148 Phase 2: Update command specs",
    "jkl012: Task 148 Phase 3: Update workflow docs"
  ]
}
```

### 5.5 Implementation Checklist

**For /task Command**:
- [ ] Parse task ID(s) from TODO.md
- [ ] Determine complexity using metrics (Section 4.3)
- [ ] Route to appropriate executor (simple vs complex)
- [ ] Ensure executors create artifacts, not inline content
- [ ] Collect summaries from executors
- [ ] Update TODO.md with completion status
- [ ] Update registries (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY)
- [ ] Return consolidated summary with artifact references
- [ ] Never return full artifact content in response

**For Simple Task Executor**:
- [ ] Implement changes directly
- [ ] Run tests
- [ ] Create single commit
- [ ] Generate 3-5 sentence summary
- [ ] Return summary + file list

**For Complex Task Executor**:
- [ ] Phase 1: Research → Create artifacts → Return summary
- [ ] Phase 2: Implement → Create artifacts → Return summary
- [ ] Phase 3: Finalize → Create summary artifact → Return reference
- [ ] Each phase commits separately
- [ ] Final summary references all artifacts

---

## 6. Key Insights from Research

### 6.1 From Anthropic's "Building Effective Agents"

1. **Simplicity Over Sophistication**: "The most successful implementations weren't using complex frameworks or specialized libraries. Instead, they were building with simple, composable patterns."

2. **Transparency is Critical**: "Prioritize transparency by explicitly showing the agent's planning steps."

3. **Tool Documentation Matters**: "Put yourself in the model's shoes. Is it obvious how to use this tool, based on the description and parameters?"

4. **Agents for Open-Ended Problems**: "Agents can be used for open-ended problems where it's difficult or impossible to predict the required number of steps."

### 6.2 From Academic Research

**CodeAct Pattern** (arXiv:2402.01030):
- Using executable code as a unified action space outperforms JSON/text formats
- Dynamic revision of actions based on feedback improves success rates
- Multi-turn interactions with environment feedback are essential

**Agent Architecture** (arXiv:2309.07864):
- Brain (LLM core) + Perception (input processing) + Action (output execution)
- Memory systems crucial for maintaining context across interactions
- Social phenomena emerge from multi-agent interactions

### 6.3 From Prompt Engineering Patterns

**Prompt Chaining Benefits**:
- Improves reliability by breaking complex tasks into manageable steps
- Increases transparency and debuggability
- Allows for programmatic validation at each step
- Reduces cognitive load on individual LLM calls

**Orchestrator-Workers Pattern**:
- Central orchestrator maintains high-level task state
- Workers handle specialized subtasks
- Results synthesized by orchestrator
- Scales better than monolithic approaches

---

## 7. Conclusion

### 7.1 Core Recommendations

1. **Use Artifact-Based Communication**: Subagents should always create artifacts and return only references + brief summaries

2. **Implement Two-Tier Execution**: Simple tasks use direct execution, complex tasks use plan-based multi-phase execution

3. **Standardize Summary Format**: Use consistent templates based on task complexity (Section 3.2)

4. **Protect Context Windows**: Never pass full artifact content back to orchestrator; use progressive summarization

5. **Clear Complexity Metrics**: Use objective criteria (Section 4.3) to determine execution path

### 7.2 Success Metrics

**Context Efficiency**:
- Primary agent context < 10K tokens per task
- Artifact references instead of content
- Progressive summarization at each level

**Transparency**:
- Clear artifact trails for all complex tasks
- Summaries enable understanding without reading full artifacts
- Status indicators always present

**Maintainability**:
- Consistent artifact organization
- Standardized summary formats
- Clear separation of concerns

### 7.3 Next Steps

1. Implement /task command with complexity routing
2. Create executor agents for simple and complex paths
3. Standardize artifact creation and summary generation
4. Test with existing TODO tasks
5. Iterate based on context consumption metrics

---

## References

1. Anthropic (2024). "Building Effective Agents". https://www.anthropic.com/research/building-effective-agents

2. Wang, X., et al. (2024). "Executable Code Actions Elicit Better LLM Agents". arXiv:2402.01030

3. Xi, Z., et al. (2023). "The Rise and Potential of Large Language Model Based Agents: A Survey". arXiv:2309.07864

4. Prompt Engineering Guide. "Prompt Chaining". https://www.promptingguide.ai/techniques/prompt_chaining

5. Anthropic Cookbook. "Agent Patterns". https://github.com/anthropics/anthropic-cookbook/tree/main/patterns/agents

---

**Report Prepared By**: Web Research Specialist  
**Date**: 2024-12-24  
**Status**: Complete
