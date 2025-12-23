# Testing Guide - .opencode AI Agent System

## Overview

Comprehensive testing checklist for validating the .opencode system functionality.

## Phase 1: Component Testing

### Test Orchestrator

**Test 1: Basic Routing**
```bash
# Test that orchestrator can route simple requests
# Expected: Orchestrator analyzes request and routes to appropriate agent
```

**Test 2: Context Allocation**
```bash
# Verify orchestrator allocates appropriate context levels
# Expected: 80% Level 1, 20% Level 2, <5% Level 3
```

### Test Primary Agents

**Test 3: Reviewer Agent**
```bash
/review

# Expected Output:
# - Analysis report created in .opencode/specs/NNN_review_YYYYMMDD/reports/
# - Verification report created
# - TODO.md updated with findings
# - Summary returned (not full artifacts)
```

**Test 4: Researcher Agent**
```bash
/research "REST API design patterns"

# Expected Output:
# - Research report created in specs/NNN_research_*/reports/
# - Multiple specialist reports (web-research, doc-research)
# - Summary with key findings returned
```

**Test 5: Planner Agent**
```bash
/plan "Implement user authentication system"

# Expected Output:
# - Implementation plan created in specs/NNN_*/plans/implementation-001.md
# - Complexity assessment included
# - Dependencies mapped
# - Summary returned
```

**Test 6: Developer Agent**
```bash
/implement 003

# Expected Output:
# - Code implemented
# - Tests passed
# - Git commits made
# - Implementation summary created
```

**Test 7: Refactorer Agent**
```bash
/refactor src/api/users.py

# Expected Output:
# - Code refactored for readability
# - Style guide applied
# - Tests passed
# - Git commit made
# - Refactoring report created
```

**Test 8: Documenter Agent**
```bash
/document "authentication system"

# Expected Output:
# - Documentation updated
# - Gaps filled
# - Bloat removed
# - Documentation summary created
```

**Test 9: Meta Agent**
```bash
/meta "Create test agent for validation"

# Expected Output:
# - New agent file created
# - XML structure validated
# - Testing recommendations provided
```

## Phase 2: Workflow Testing

### Test Complete Development Cycle

**Workflow 1: Research → Plan → Implement**
```bash
# Step 1: Research
/research "microservices architecture patterns"
# Verify: Research report created with findings

# Step 2: Plan
/plan "Implement microservices architecture based on research"
# Verify: Implementation plan created with steps

# Step 3: Implement
/implement [project_number]
# Verify: Code implemented, tested, committed

# Step 4: Document
/document "microservices architecture"
# Verify: Documentation updated
```

**Workflow 2: Review → Fix → Verify**
```bash
# Step 1: Review
/review
# Verify: Issues identified and added to TODO.md

# Step 2: Fix
/refactor [file_with_issues]
# Verify: Issues fixed, code improved

# Step 3: Verify
/review
# Verify: Issues resolved, compliance improved
```

**Workflow 3: Plan → Revise → Implement**
```bash
# Step 1: Initial Plan
/plan "Implement caching layer"
# Verify: Plan version 001 created

# Step 2: Revise
/revise [project_number]
# Verify: Plan version 002 created with revision notes

# Step 3: Implement
/implement [project_number]
# Verify: Latest plan version used for implementation
```

## Phase 3: Context Protection Testing

### Test Artifact Creation

**Test 10: Verify Artifacts Created**
```bash
# After running /research
ls specs/NNN_*/reports/
# Expected: research-001.md, web-research-001.md, doc-research-001.md

# After running /plan
ls specs/NNN_*/plans/
# Expected: implementation-001.md

# After running /implement
ls specs/NNN_*/summaries/
# Expected: implementation-summary.md
```

**Test 11: Verify References Returned (Not Full Artifacts)**
```bash
# Run any command and check output
/research "test topic"

# Expected Output Format:
# {
#   "artifacts": ["path/to/report"],
#   "summary": "Brief 3-5 sentence summary",
#   "key_findings": ["finding1", "finding2"],
#   "status": "completed"
# }

# NOT Expected: Full artifact content in response
```

**Test 11a: Verify Agent and Command Counts**
```bash
# Count primary agents (should be 10)
find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l

# Count specialists (should be 19)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# Count commands (should be 11)
find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# Verify context directory structure
ls .opencode/context/
# Expected: core, templates, project, repo
```

## Phase 4: State Management Testing

### Test State Files

**Test 12: Project State**
```bash
# After creating a project
cat .opencode/specs/NNN_*/state.json

# Expected Fields:
# - project_name
# - project_number
# - type
# - phase
# - reports[]
# - plans[]
# - summaries[]
# - status
# - created
# - last_updated
```

**Test 13: Global State**
```bash
cat .opencode/specs/state.json

# Expected Fields:
# - active_projects[]
# - completed_projects[]
# - next_project_number
# - recent_activities[]
# - pending_tasks[]
```

**Test 14: TODO.md Synchronization**
```bash
# Before review
cat .opencode/specs/TODO.md
# Note task count

# Run review
/review

# After review
cat .opencode/specs/TODO.md
# Expected: New tasks added with links to reports
```

## Phase 5: Integration Testing

### Test Tool Integrations

**Test 15: Code Quality Integration**
```bash
# Implement a feature
/implement [project_number]

# Expected:
# - Code quality checks performed
# - Tests run and passed
# - Only valid code accepted
```

**Test 16: Web Research Integration**
```bash
/research "GraphQL best practices"

# Expected:
# - Web search conducted
# - Relevant results returned
# - Results in web-research-001.md
```

**Test 17: Documentation Research Integration**
```bash
/research "Python async/await patterns"

# Expected:
# - Documentation searched
# - Best practices found
# - Results in doc-research-001.md
```

**Test 18: Git Integration**
```bash
# Implement feature
/implement [project_number]

# Check git log
git log --oneline -5

# Expected:
# - Commits made after substantial changes
# - Commit messages descriptive
# - Changes properly staged
```

## Phase 6: Edge Case Testing

### Test Error Handling

**Test 19: Invalid Project Number**
```bash
/lean 999

# Expected:
# - Error message: "Project 999 not found"
# - Graceful failure
# - No state corruption
```

**Test 20: Missing Context Files**
```bash
# Temporarily rename a context file
# Run command that needs it

# Expected:
# - Error message about missing context
# - Suggestion to restore file
# - Graceful degradation
```

**Test 21: Validation Failure**
```bash
# Implement feature with intentional error
/implement [project_number]

# Expected:
# - Tests catch error
# - Implementation halted
# - Error reported to user
# - No git commit made
```

### Test Version Control

**Test 22: Plan Revision Incrementing**
```bash
# Create initial plan
/plan "Test task"
# Verify: implementation-001.md created

# Revise plan
/revise [project_number]
# Verify: implementation-002.md created

# Revise again
/revise [project_number]
# Verify: implementation-003.md created
```

**Test 23: Report Numbering**
```bash
# Research same topic twice
/research "test topic"
# Verify: research-001.md created

/research "test topic again"
# Verify: research-002.md created (incremented)
```

## Phase 7: Performance Testing

### Test Context Efficiency

**Test 24: Context Level Distribution**
```bash
# Run 20 diverse commands
# Track context levels used

# Expected Distribution:
# - ~16 commands use Level 1 (80%)
# - ~4 commands use Level 2 (20%)
# - ~0 commands use Level 3 (<5%)
```

**Test 25: Response Time**
```bash
# Measure response times for different workflows

# Expected:
# - Simple commands (Level 1): <5 seconds
# - Moderate commands (Level 2): <15 seconds
# - Complex commands (Level 3): <30 seconds
```

## Phase 8: Meta-System Testing

### Test Agent/Command Creation

**Test 26: Create New Agent**
```bash
/meta "Create agent that analyzes code complexity"

# Expected:
# - New agent file created in .opencode/agent/subagents/
# - XML structure valid
# - Frontmatter correct
# - Testing recommendations provided
```

**Test 27: Create New Command**
```bash
/meta "Create command /analyze that runs code complexity analysis"

# Expected:
# - New command file created in .opencode/command/
# - Routing specified
# - Syntax documented
# - Examples provided
```

**Test 28: Modify Existing Agent**
```bash
/meta "Modify researcher agent to add support for arXiv search"

# Expected:
# - Agent file updated
# - Functionality preserved
# - New feature added
# - Summary of changes provided
```

## Testing Checklist

### Component Tests
- [ ] Orchestrator routing works
- [ ] Reviewer agent creates reports and updates TODO
- [ ] Researcher agent queries all sources
- [ ] Planner agent creates detailed plans
- [ ] Developer implements and validates
- [ ] Refactorer improves code quality
- [ ] Documenter maintains docs
- [ ] Meta agent creates/modifies components

### Workflow Tests
- [ ] Research → Plan → Implement cycle works
- [ ] Review → Fix → Verify cycle works
- [ ] Plan → Revise → Implement cycle works

### Context Protection Tests
- [ ] Artifacts created in correct locations
- [ ] Only references returned (not full content)
- [ ] Context window stays clean

### State Management Tests
- [ ] Project state files created and updated
- [ ] Global state synchronized
- [ ] TODO.md synced with findings

### Integration Tests
- [ ] Code quality checks work
- [ ] Web research queries successful
- [ ] Documentation research successful
- [ ] Git commits made properly

### Edge Case Tests
- [ ] Invalid inputs handled gracefully
- [ ] Missing files detected
- [ ] Verification failures caught
- [ ] Version control works correctly

### Performance Tests
- [ ] Context levels distributed correctly
- [ ] Response times acceptable

### Meta-System Tests
- [ ] New agents created successfully
- [ ] New commands created successfully
- [ ] Modifications work correctly

## Success Criteria

### Minimum Requirements
- All component tests pass
- At least one complete workflow cycle succeeds
- Artifacts created in correct locations
- State files updated properly
- No context window overflow

### Recommended Requirements
- All workflow tests pass
- All integration tests pass
- Context distribution matches targets (80/20/<5)
- Response times within expected ranges

### Excellent Performance
- All tests pass
- No errors or warnings
- Performance exceeds targets
- User experience smooth and intuitive

## Troubleshooting

### Common Issues

**Issue: Command not found**
- Check: `ls .opencode/command/`
- Fix: Verify command file exists and has correct name

**Issue: Agent routing fails**
- Check: Orchestrator logs for routing decision
- Fix: Verify agent exists in `.opencode/agent/subagents/`

**Issue: Artifacts not created**
- Check: `.opencode/specs/` directory structure
- Fix: Verify project directory created before artifact generation

**Issue: Incorrect agent/command counts**
- Check: Run verification commands from Test 11a
- Fix: Verify all agent and command files exist and are properly named

**Issue: State not synchronized**
- Check: state.json files for updates
- Fix: Verify state update logic in agents

**Issue: Context overflow**
- Check: Context level allocation
- Fix: Ensure subagents return only references, not full artifacts

## Next Steps

After completing testing:
1. Document any issues found
2. Fix critical bugs
3. Optimize performance bottlenecks
4. Add additional tests for edge cases
5. Create regression test suite

---

**Thorough testing ensures a robust, reliable development system!**
