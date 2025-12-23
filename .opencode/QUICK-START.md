# Quick Start Guide - .opencode AI Agent System

## Your First Steps

### Step 1: Review Your Repository

Start by analyzing your current repository state:

```bash
/review
```

**What happens:**
- Analyzes repository structure and completeness
- Verifies code quality against standards
- Identifies gaps and improvements
- Updates TODO.md with findings
- Creates reports in `.opencode/specs/NNN_review_YYYYMMDD/`

**Expected output:**
- Analysis report reference
- Verification report reference
- Key findings summary
- Updated TODO.md

**Verification:**
```bash
# Verify review artifacts were created
ls .opencode/specs/ | grep review

# Check TODO.md was updated
cat .opencode/specs/TODO.md | head -20
```

### Step 2: Check Your TODO List

Review the updated TODO.md:

```bash
cat .opencode/specs/TODO.md
```

You'll see prioritized tasks with links to relevant reports.

**Verification:**
```bash
# Count tasks in TODO.md
grep -c "^- \[ \]" .opencode/specs/TODO.md

# Show high-priority tasks
grep -A 2 "Priority: High" .opencode/specs/TODO.md | head -20
```

### Step 3: Research a Topic

Pick a topic from TODO or explore something new:

```bash
/research "GraphQL API design patterns"
```

**What happens:**
- Conducts web research
- Searches documentation and best practices
- Synthesizes findings into comprehensive report
- Creates report in `.opencode/specs/NNN_research_{topic}/reports/`

**Expected output:**
- Research report reference
- Key findings summary
- Relevant LEAN definitions/theorems
- Implementation recommendations

**Verification:**
```bash
# Find research project directory
ls .opencode/specs/ | grep research

# Check research report was created
find .opencode/specs -name "research-*.md" -type f | tail -1

# View research summary
cat .opencode/specs/*/summaries/research-summary.md | tail -20
```

### Step 4: Create an Implementation Plan

Choose a task from TODO.md:

```bash
/plan "Implement GraphQL API with authentication"
```

**What happens:**
- Analyzes task complexity
- Maps dependencies
- Creates detailed step-by-step plan
- Stores plan in `.opencode/specs/NNN_project/plans/implementation-001.md`

**Expected output:**
- Implementation plan reference
- Complexity assessment
- Estimated effort
- Key steps and dependencies

**Verification:**
```bash
# Find latest plan
find .opencode/specs -name "implementation-*.md" -type f | tail -1

# View plan structure
cat $(find .opencode/specs -name "implementation-*.md" -type f | tail -1) | head -50

# Check project state
cat $(find .opencode/specs -maxdepth 2 -name "state.json" -type f | tail -1)
```

### Step 5: Implement the Plan

Execute the implementation plan:

```bash
/implement 003
```

**What happens:**
- Loads implementation plan
- Implements each step using appropriate specialists
- Runs tests and validation
- Commits to git after substantial changes
- Creates implementation summary

**Expected output:**
- Implementation summary reference
- Files created/modified
- Verification status
- Git commits made

**Verification:**
```bash
# Check implementation summary
find .opencode/specs -name "implementation-summary.md" -type f | tail -1 | xargs cat

# Verify files were created/modified
git status

# Check recent commits
git log --oneline -5

# Run tests
npm test  # or pytest, cargo test, etc.
```

### Step 6: Refactor Code (Optional)

Improve code readability:

```bash
/refactor src/api/graphql.py
```

**What happens:**
- Checks style adherence
- Identifies simplification opportunities
- Applies improvements
- Verifies changes
- Commits to git

**Verification:**
```bash
# Check refactoring report
find .opencode/specs -name "refactor-*.md" -type f | tail -1 | xargs cat

# Verify file still works
npm test  # or appropriate test command

# Check git diff
git diff src/api/graphql.py
```

### Step 7: Update Documentation

Keep docs current:

```bash
/document "GraphQL API"
```

**What happens:**
- Analyzes documentation gaps
- Updates documentation
- Removes outdated content
- Ensures completeness and accuracy

**Verification:**
```bash
# Check documentation report
find .opencode/specs -name "documentation-*.md" -type f | tail -1 | xargs cat

# Verify documentation files were updated
git status Documentation/

# Check documentation quality
grep -r "TODO\|FIXME\|XXX" Documentation/ | wc -l
```

## Common Workflows

### Research → Plan → Implement

```bash
# 1. Research the topic
/research "microservices architecture patterns"

# 2. Create implementation plan
/plan "Implement microservices architecture based on research"

# 3. Implement the plan
/implement 004

# 4. Document the implementation
/document "microservices architecture"
```

### Review → Fix → Verify

```bash
# 1. Review repository
/review

# 2. Check TODO for issues found
cat .opencode/specs/TODO.md

# 3. Fix identified issues
/refactor [file with issues]

# 4. Verify fixes
/review
```

### Plan → Revise → Implement

```bash
# 1. Create initial plan
/plan "Implement caching layer"

# 2. Review plan, identify issues
cat .opencode/specs/005_project/plans/implementation-001.md

# 3. Revise plan
/revise 005

# 4. Implement revised plan
/implement 005
```

## Understanding the Output

### Artifact References

All commands return artifact references like:
```
.opencode/specs/NNN_bimodal_axioms/reports/research-001.md
```

These are detailed reports created by subagents. You can read them directly:
```bash
cat .opencode/specs/NNN_bimodal_axioms/reports/research-001.md
```

### Summaries

Commands also return brief summaries (3-5 sentences) for quick understanding without reading full artifacts.

### Project Numbers

Each workflow creates a numbered project directory:
- `001_review_20250116`
- `002_research_kripke_semantics`
- `003_bimodal_axioms`
- etc.

Use project numbers to reference plans:
```bash
/lean 003
/revise 003
```

## System Verification

Verify system integrity and setup:

### Quick Verification
```bash
# Run complete system check
echo "=== Agent System ==="
echo "Primary agents: $(find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l) (expected: 10)"
echo "Specialist subagents: $(find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 19)"

echo -e "\n=== Command System ==="
echo "Commands: $(find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 11)"

echo -e "\n=== Context Structure ==="
echo "Context directories: $(ls -d .opencode/context/*/ 2>/dev/null | wc -l) (expected: 4)"

echo -e "\n=== Specs Directory ==="
echo "TODO.md: $(test -f .opencode/specs/TODO.md && echo "✓" || echo "✗")"
echo "state.json: $(test -f .opencode/specs/state.json && echo "✓" || echo "✗")"
```

### Detailed Verification

#### Agent System
```bash
# Count primary agents (should be 10)
find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l

# Count specialist subagents (should be 19)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all primary agents
ls .opencode/agent/subagents/*.md
```

#### Command System
```bash
# Count commands (should be 11)
find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all commands
ls .opencode/command/*.md
```

#### Context Structure
```bash
# Verify context directories exist
ls -d .opencode/context/*/
# Expected: templates, core, project, repo
```

#### Context Directory Verification
```bash
# Verify all context subdirectories
for dir in core project repo templates; do
  echo "=== $dir context ==="
  ls .opencode/context/$dir/ 2>/dev/null || echo "Directory structure varies"
  echo ""
done
```

## Exploring the System

### View Context Files

All context files are in `.opencode/context/`:

```bash
# Project-specific knowledge
ls .opencode/context/project/

# Repository conventions
ls .opencode/context/repo/

# Core system patterns
ls .opencode/context/common/

# Meta-system templates
ls .opencode/context/templates/
```

### View Agents

```bash
# Main orchestrator
cat .opencode/agent/orchestrator.md

# Primary agents
ls .opencode/agent/subagents/

# Specialist subagents
ls .opencode/agent/subagents/specialists/
```

### View Commands

```bash
ls .opencode/command/
```

## Customizing the System

### Create a New Agent

```bash
/meta "Create agent that analyzes code complexity and suggests optimizations"
```

### Create a New Command

```bash
/meta "Create command /optimize that analyzes and optimizes code performance"
```

### Modify an Existing Agent

```bash
/meta "Modify researcher agent to add support for arXiv paper search"
```

### Modify an Existing Command

```bash
/meta "Modify review command to include performance metrics in review"
```

### Add Tasks to TODO

```bash
/add "Implement user authentication with JWT"
```

### Execute TODO Tasks

```bash
/todo              # Display TODO list
/task 63           # Execute task #63
```

## Advanced Usage

### Multi-Step Workflows

Complex development tasks often require coordinating multiple commands in sequence. Here are proven patterns:

#### Complete Feature Development Workflow

```bash
# 1. Research the technical foundation
/research "JWT authentication best practices"

# 2. Create implementation plan based on research
/plan "Implement JWT authentication with refresh tokens"

# 3. Implement the plan
/implement 005

# 4. Verify implementation quality
/review

# 5. Refactor if needed (based on review findings)
/refactor src/auth/jwt.py

# 6. Document the implementation
/document "JWT authentication system"

# 7. Run tests
npm test  # or appropriate test command
```

**Expected Timeline**: 1-3 hours for complete feature development

**Verification at Each Step**:
```bash
# After research: Check research report
cat .opencode/specs/005_*/reports/research-001.md | head -50

# After plan: Verify plan complexity and steps
cat .opencode/specs/005_*/plans/implementation-001.md | grep -A 5 "Complexity"

# After implementation: Run tests
npm test  # or pytest, cargo test, etc.

# After review: Check for issues
cat .opencode/specs/006_*/reports/review-001.md | grep "Issues Found"

# After documentation: Verify docs updated
git diff docs/
```

#### Parallel Research Workflow

When researching multiple related topics, you can work on them in parallel:

```bash
# Research multiple aspects simultaneously
/research "React state management patterns"
# (While waiting, open new terminal)
/research "Redux vs Context API performance"
# (In another terminal)
/research "React testing best practices"

# Then synthesize findings
/plan "Implement state management based on all three research reports"
```

**Benefits**:
- Faster research phase (parallel vs sequential)
- Comprehensive understanding before implementation
- Better architectural decisions

**Verification**:
```bash
# Find all research reports
find .opencode/specs -name "research-*.md" -type f | tail -3

# Compare findings
for report in $(find .opencode/specs -name "research-*.md" -type f | tail -3); do
  echo "=== $report ==="
  grep -A 3 "Key Findings" "$report"
  echo ""
done
```

#### Error Recovery Patterns

When a command fails or produces unexpected results:

**Pattern 1: Plan Revision**
```bash
# Initial plan
/plan "Implement decidability procedure for bimodal logic"

# Implementation fails due to complexity
/lean 007
# Error: "Complexity too high, need to break down into smaller steps"

# Revise plan with more granular steps
/revise 007
# Specify: "Break into 3 phases: syntax, semantics, decidability algorithm"

# Retry implementation
/lean 007
```

**Pattern 2: Incremental Implementation**
```bash
# If implementation is too large, break it down
/plan "Implement Phase 1: Database models only"
/implement 008

# Verify Phase 1 works
npm test

# Continue with Phase 2
/plan "Implement Phase 2: API endpoints (depends on Phase 1)"
/implement 009

# And so on...
```

**Pattern 3: Rollback and Retry**
```bash
# If implementation introduces errors
git status
# Shows modified files

# Check what changed
git diff src/models/user.py

# If changes are problematic, rollback
git checkout src/models/user.py

# Revise approach
/plan "Implement user model with simpler schema"
/implement 010
```

**Verification**:
```bash
# Always verify after recovery
npm test  # or appropriate test command
git status
git log --oneline -3
```

### Command Composition Examples

#### Using Research Output in Planning

```bash
# 1. Research and capture key findings
/research "database connection pooling strategies"

# 2. Read research findings
RESEARCH_FILE=$(find .opencode/specs -name "research-*.md" -type f | tail -1)
cat "$RESEARCH_FILE" | grep -A 10 "Implementation Recommendations"

# 3. Use findings to create detailed plan
/plan "Implement connection pooling based on research findings in $RESEARCH_FILE"
```

#### Chaining Review → Fix → Verify

```bash
# 1. Review and capture issues
/review > /tmp/review-output.txt

# 2. Extract specific issues
cat /tmp/review-output.txt | grep "Issue:"

# 3. Fix each issue systematically
for issue in $(cat /tmp/review-output.txt | grep "File:" | cut -d: -f2); do
  echo "Fixing $issue"
  /refactor "$issue"
done

# 4. Verify all fixes
/review
```

#### Automated TODO Processing

```bash
# 1. Get TODO count
TODO_COUNT=$(grep -c "^- \[ \]" .opencode/specs/TODO.md)
echo "Total tasks: $TODO_COUNT"

# 2. Process high-priority tasks
grep -B 1 "Priority: High" .opencode/specs/TODO.md | grep "^- \[ \]" | head -5 | while read task; do
  echo "Processing: $task"
  # Extract task description
  TASK_DESC=$(echo "$task" | sed 's/^- \[ \] //')
  /plan "$TASK_DESC"
done

# 3. Verify progress
TODO_COUNT_AFTER=$(grep -c "^- \[ \]" .opencode/specs/TODO.md)
echo "Completed: $((TODO_COUNT - TODO_COUNT_AFTER)) tasks"
```

### Workflow Automation Patterns

#### Daily Development Routine

```bash
#!/bin/bash
# daily-dev.sh - Automated daily development workflow

echo "=== Daily Development Workflow ==="

# 1. Review current state
echo "Step 1: Reviewing repository..."
/review

# 2. Check TODO for high-priority tasks
echo "Step 2: Checking TODO..."
HIGH_PRIORITY=$(grep -c "Priority: High" .opencode/specs/TODO.md)
echo "High-priority tasks: $HIGH_PRIORITY"

# 3. Pick top task and create plan
if [ "$HIGH_PRIORITY" -gt 0 ]; then
  TASK=$(grep -A 1 "Priority: High" .opencode/specs/TODO.md | grep "^- \[ \]" | head -1 | sed 's/^- \[ \] //')
  echo "Step 3: Planning task: $TASK"
  /plan "$TASK"
  
  # 4. Get project number
  PROJECT_NUM=$(ls -d .opencode/specs/[0-9]* | tail -1 | grep -o '[0-9]\+' | head -1)
  echo "Step 4: Implementing project $PROJECT_NUM"
  /lean "$PROJECT_NUM"
  
  # 5. Verify and document
  echo "Step 5: Verifying implementation..."
  lake build
  
  echo "Step 6: Updating documentation..."
  /document "$TASK"
else
  echo "No high-priority tasks found!"
fi

echo "=== Workflow Complete ==="
```

#### Continuous Integration Workflow

```bash
#!/bin/bash
# ci-workflow.sh - Pre-commit verification

echo "=== Pre-Commit Verification ==="

# 1. Run linter
echo "Step 1: Running linter..."
if ! npm run lint; then
  echo "✗ Linting failed! Fix errors before committing."
  exit 1
fi

# 2. Run tests
echo "Step 2: Running tests..."
if ! npm test; then
  echo "✗ Tests failed! Fix tests before committing."
  exit 1
fi

# 3. Check documentation is up-to-date
echo "Step 3: Checking documentation..."
MODIFIED_CODE=$(git diff --name-only | grep "src/" | wc -l)
MODIFIED_DOCS=$(git diff --name-only | grep "docs/" | wc -l)

if [ "$MODIFIED_CODE" -gt 0 ] && [ "$MODIFIED_DOCS" -eq 0 ]; then
  echo "⚠ Warning: Code modified but no documentation updated"
  echo "Consider running: /document \"recent changes\""
fi

# 4. Verify code quality
echo "Step 4: Checking code quality..."
/review

echo "✓ All checks passed! Ready to commit."
```

#### Batch Processing Workflow

```bash
#!/bin/bash
# batch-refactor.sh - Refactor multiple files

echo "=== Batch Refactoring Workflow ==="

# Find all files needing refactoring
FILES=$(find src -name "*.py" -type f)

for file in $FILES; do
  echo "Processing: $file"
  
  # Check if file needs refactoring
  if grep -q "TODO" "$file"; then
    echo "  → Contains TODO, skipping for now"
    continue
  fi
  
  # Refactor file
  /refactor "$file"
  
  # Verify still works
  if ! npm test; then
    echo "  ✗ Refactoring broke tests, reverting..."
    git checkout "$file"
  else
    echo "  ✓ Refactored successfully"
  fi
done

echo "=== Batch Refactoring Complete ==="
```

### Session Management

#### Saving Session State

```bash
# Save current work state
cat > .opencode/session-$(date +%Y%m%d).md <<EOF
# Development Session $(date +%Y-%m-%d)

## Current Project
$(ls -d .opencode/specs/[0-9]* | tail -1)

## Recent Commands
$(history | tail -20)

## Modified Files
$(git status --short)

## Next Steps
- [ ] Complete implementation of project $(ls -d .opencode/specs/[0-9]* | tail -1 | grep -o '[0-9]\+')
- [ ] Run verification tests
- [ ] Update documentation

## Notes
[Add session notes here]
EOF
```

#### Resuming Previous Session

```bash
# Find last session
LAST_SESSION=$(ls .opencode/session-*.md | tail -1)
echo "Last session: $LAST_SESSION"
cat "$LAST_SESSION"

# Resume last project
LAST_PROJECT=$(grep "Current Project" "$LAST_SESSION" | cut -d/ -f4 | grep -o '[0-9]\+')
echo "Resuming project $LAST_PROJECT"

# Check project state
cat .opencode/specs/${LAST_PROJECT}_*/state.json
```

## Tips for Success

1. **Start with /review** to understand your current state
2. **Use /research** before implementing complex features
3. **Create plans** before implementing to think through approach
4. **Revise plans** when you discover issues during implementation
5. **Commit regularly** (automatic after substantial changes)
6. **Keep docs updated** to avoid documentation bloat
7. **Check TODO.md** regularly for prioritized tasks
8. **Use multi-step workflows** for complex features
9. **Parallelize research** when exploring multiple topics
10. **Automate repetitive tasks** with shell scripts
11. **Save session state** for long-running projects
12. **Verify at each step** to catch issues early

## Troubleshooting

### Command not working?
- Check command syntax: `cat .opencode/command/{command-name}.md`
- Verify agent exists: `ls .opencode/agent/subagents/`

### Artifact not found?
- Check project number: `ls .opencode/specs/`
- Verify artifact path in command output

### Context file missing?
- Check context structure: `ls .opencode/context/`
- Verify file referenced in command

## Next Steps

1. Run `/review` to analyze your repository
2. Check `.opencode/specs/TODO.md` for identified tasks
3. Pick a high-priority task and run `/plan`
4. Implement the plan with `/implement`
5. Keep documentation updated with `/document`

---

**You're ready to start developing with AI assistance!**

For more details, see:
- **README.md**: System overview
- **ARCHITECTURE.md**: Detailed architecture
- **TESTING.md**: Testing procedures
