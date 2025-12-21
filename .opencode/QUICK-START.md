# Quick Start Guide - LEAN 4 ProofChecker

## Your First Steps

### Step 1: Review Your Repository

Start by analyzing your current repository state:

```bash
/review
```

**What happens:**
- Analyzes repository structure and completeness
- Verifies existing proofs against standards
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
/research "Kaplan semantics for two-dimensional logic"
```

**What happens:**
- Searches LeanSearch (semantic)
- Searches Loogle (formal)
- Conducts web research
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
/plan "Implement proof system axioms for bimodal logic"
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
/lean 003
```

**What happens:**
- Loads implementation plan
- Implements each step using appropriate specialists
- Verifies with lean-lsp-mcp
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

# Verify LEAN files compile
lake build
```

### Step 6: Refactor Code (Optional)

Improve code readability:

```bash
/refactor Logos/BimodalProofs.lean
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

# Verify file still compiles
lake build Logos.BimodalProofs

# Check git diff
git diff Logos/BimodalProofs.lean
```

### Step 7: Update Documentation

Keep docs current:

```bash
/document "bimodal logic proof system"
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
/research "completeness proof for bimodal logic"

# 2. Create implementation plan
/plan "Implement completeness proof based on research"

# 3. Implement the plan
/lean 004

# 4. Document the implementation
/document "completeness proof"
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
/plan "Implement decidability procedure"

# 2. Review plan, identify issues
cat .opencode/specs/005_project/plans/implementation-001.md

# 3. Revise plan
/revise 005

# 4. Implement revised plan
/lean 005
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
echo "Primary agents: $(find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l) (expected: 12)"
echo "Specialist subagents: $(find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 32)"

echo -e "\n=== Command System ==="
echo "Commands: $(find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l) (expected: 12)"

echo -e "\n=== Context Structure ==="
echo "Context directories: $(ls -d .opencode/context/*/ 2>/dev/null | wc -l) (expected: 8)"
echo "LEAN 4 subdirectories: $(ls -d .opencode/context/lean4/*/ 2>/dev/null | wc -l) (expected: 6)"
echo "Logic subdirectories: $(ls -d .opencode/context/logic/*/ 2>/dev/null | wc -l) (expected: 7)"

echo -e "\n=== Specs Directory ==="
echo "TODO.md: $(test -f .opencode/specs/TODO.md && echo "✓" || echo "✗")"
echo "state.json: $(test -f .opencode/specs/state.json && echo "✓" || echo "✗")"
```

### Detailed Verification

#### Agent System
```bash
# Count primary agents (should be 12)
find .opencode/agent/subagents -maxdepth 1 -name "*.md" -type f | wc -l

# Count specialist subagents (should be 32)
find .opencode/agent/subagents/specialists -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all primary agents
ls .opencode/agent/subagents/*.md
```

#### Command System
```bash
# Count commands (should be 12)
find .opencode/command -maxdepth 1 -name "*.md" -type f | grep -v README | wc -l

# List all commands
ls .opencode/command/*.md
```

#### Context Structure
```bash
# Verify context directories exist
ls -d .opencode/context/*/
# Expected: core, lean4, logic, math, physics, project, repo, templates

# Check LEAN 4 context structure
ls .opencode/context/lean4/
# Expected: domain, processes, standards, templates, patterns, tools

# Check logic context structure
ls .opencode/context/logic/
# Expected: domain, metalogic, processes, proof-theory, semantics, standards, type-theory
```

#### Context Directory Verification
```bash
# Verify all context subdirectories
for dir in lean4 logic math; do
  echo "=== $dir context ==="
  ls .opencode/context/$dir/
  echo ""
done

# Verify domain files have examples
echo "=== Domain Files with Examples ==="
grep -l "## Examples" .opencode/context/lean4/domain/*.md
echo ""

# Count examples in key domain files
echo "=== Example Count ==="
echo "lean4-syntax.md: $(grep -c '```lean' .opencode/context/lean4/domain/lean4-syntax.md) code blocks"
echo "mathlib-overview.md: $(grep -c '```lean' .opencode/context/lean4/domain/mathlib-overview.md) code blocks"
echo "tactic-patterns.md: $(grep -c '```lean' .opencode/context/lean4/patterns/tactic-patterns.md) code blocks"
```

## Exploring the System

### View Context Files

All context files are in `.opencode/context/`:

```bash
# LEAN 4 domain knowledge
ls .opencode/context/lean4/domain/

# Logic domain knowledge
ls .opencode/context/logic/domain/

# Math domain knowledge
ls .opencode/context/math/domain/

# Repository conventions
ls .opencode/context/repo/

# Process guides
ls .opencode/context/lean4/processes/
ls .opencode/context/logic/processes/

# Core system patterns
ls .opencode/context/core/
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
/meta "Create agent that analyzes proof complexity and suggests optimizations"
```

### Create a New Command

```bash
/meta "Create command /optimize that analyzes and optimizes proof performance"
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
/add "Implement completeness proof for bimodal logic"
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
# 1. Research the theoretical foundation
/research "soundness and completeness for modal logic S4"

# 2. Create implementation plan based on research
/plan "Implement S4 modal logic proof system with soundness and completeness proofs"

# 3. Implement the plan
/lean 005

# 4. Verify implementation quality
/review

# 5. Refactor if needed (based on review findings)
/refactor Logos/Core/Theorems/ModalS4.lean

# 6. Document the implementation
/document "S4 modal logic proof system"

# 7. Add tests
/test Logos/Core/Theorems/ModalS4.lean
```

**Expected Timeline**: 2-4 hours for complete feature development

**Verification at Each Step**:
```bash
# After research: Check research report
cat .opencode/specs/005_*/reports/research-001.md | head -50

# After plan: Verify plan complexity and steps
cat .opencode/specs/005_*/plans/implementation-001.md | grep -A 5 "Complexity"

# After implementation: Verify files compile
lake build

# After review: Check for issues
cat .opencode/specs/006_*/reports/review-001.md | grep "Issues Found"

# After documentation: Verify docs updated
git diff Documentation/
```

#### Parallel Research Workflow

When researching multiple related topics, you can work on them in parallel:

```bash
# Research multiple aspects simultaneously
/research "Kripke semantics for modal logic"
# (While waiting, open new terminal)
/research "frame correspondence for modal axioms"
# (In another terminal)
/research "canonical model construction"

# Then synthesize findings
/plan "Implement modal logic semantics based on all three research reports"
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
/plan "Implement Phase 1: Syntax definitions only"
/lean 008

# Verify Phase 1 works
lake build

# Continue with Phase 2
/plan "Implement Phase 2: Semantics (depends on Phase 1)"
/lean 009

# And so on...
```

**Pattern 3: Rollback and Retry**
```bash
# If implementation introduces errors
git status
# Shows modified files

# Check what changed
git diff Logos/Core/Syntax/Formula.lean

# If changes are problematic, rollback
git checkout Logos/Core/Syntax/Formula.lean

# Revise approach
/plan "Implement formula syntax with simpler inductive definition"
/lean 010
```

**Verification**:
```bash
# Always verify after recovery
lake build
git status
git log --oneline -3
```

### Command Composition Examples

#### Using Research Output in Planning

```bash
# 1. Research and capture key findings
/research "proof automation with Aesop tactic"

# 2. Read research findings
RESEARCH_FILE=$(find .opencode/specs -name "research-*.md" -type f | tail -1)
cat "$RESEARCH_FILE" | grep -A 10 "Implementation Recommendations"

# 3. Use findings to create detailed plan
/plan "Implement Aesop integration for automated proof search based on research findings in $RESEARCH_FILE"
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

# 1. Verify all files compile
echo "Step 1: Building project..."
if ! lake build; then
  echo "✗ Build failed! Fix errors before committing."
  exit 1
fi

# 2. Run tests
echo "Step 2: Running tests..."
if ! lake test; then
  echo "✗ Tests failed! Fix tests before committing."
  exit 1
fi

# 3. Check documentation is up-to-date
echo "Step 3: Checking documentation..."
MODIFIED_LEAN=$(git diff --name-only | grep "\.lean$" | wc -l)
MODIFIED_DOCS=$(git diff --name-only | grep "Documentation/" | wc -l)

if [ "$MODIFIED_LEAN" -gt 0 ] && [ "$MODIFIED_DOCS" -eq 0 ]; then
  echo "⚠ Warning: LEAN files modified but no documentation updated"
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
FILES=$(find Logos -name "*.lean" -type f)

for file in $FILES; do
  echo "Processing: $file"
  
  # Check if file needs refactoring
  if grep -q "sorry" "$file"; then
    echo "  → Contains sorry, skipping for now"
    continue
  fi
  
  # Refactor file
  /refactor "$file"
  
  # Verify still compiles
  if ! lake build "${file%.lean}"; then
    echo "  ✗ Refactoring broke compilation, reverting..."
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

**You're ready to start theorem proving!**

For more details, see:
- **README.md**: System overview
- **ARCHITECTURE.md**: Detailed architecture
- **TESTING.md**: Testing procedures
