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
- Creates reports in `.opencode/specs/001_review_YYYYMMDD/`

**Expected output:**
- Analysis report reference
- Verification report reference
- Key findings summary
- Updated TODO.md

### Step 2: Check Your TODO List

Review the updated TODO.md:

```bash
cat .opencode/specs/TODO.md
```

You'll see prioritized tasks with links to relevant reports.

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
- Creates report in `.opencode/specs/002_research_{topic}/reports/`

**Expected output:**
- Research report reference
- Key findings summary
- Relevant LEAN definitions/theorems
- Implementation recommendations

### Step 4: Create an Implementation Plan

Choose a task from TODO.md:

```bash
/plan "Implement proof system axioms for bimodal logic"
```

**What happens:**
- Analyzes task complexity
- Maps dependencies
- Creates detailed step-by-step plan
- Stores plan in `.opencode/specs/003_project/plans/implementation-001.md`

**Expected output:**
- Implementation plan reference
- Complexity assessment
- Estimated effort
- Key steps and dependencies

### Step 5: Implement the Plan

Execute the implementation plan:

```bash
/implement 003
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

## Common Workflows

### Research → Plan → Implement

```bash
# 1. Research the topic
/research "completeness proof for bimodal logic"

# 2. Create implementation plan
/plan "Implement completeness proof based on research"

# 3. Implement the plan
/implement 004

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
/implement 005
```

## Understanding the Output

### Artifact References

All commands return artifact references like:
```
.opencode/specs/003_bimodal_axioms/reports/research-001.md
```

These are detailed reports created by subagents. You can read them directly:
```bash
cat .opencode/specs/003_bimodal_axioms/reports/research-001.md
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
/implement 003
/revise 003
```

## Exploring the System

### View Context Files

```bash
# LEAN 4 domain knowledge
ls .opencode/context/lean4/domain/

# Logic domain knowledge
ls .opencode/context/logic/domain/

# Process guides
ls .opencode/context/lean4/processes/
ls .opencode/context/logic/processes/
```

### View Agents

```bash
# Main orchestrator
cat .opencode/agent/lean4-orchestrator.md

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
/create-agent "Agent that analyzes proof complexity and suggests optimizations"
```

### Create a New Command

```bash
/create-command "Command /optimize that analyzes and optimizes proof performance"
```

### Modify an Existing Agent

```bash
/modify-agent "researcher" "Add support for arXiv paper search"
```

### Modify an Existing Command

```bash
/modify-command "review" "Include performance metrics in review"
```

## Tips for Success

1. **Start with /review** to understand your current state
2. **Use /research** before implementing complex features
3. **Create plans** before implementing to think through approach
4. **Revise plans** when you discover issues during implementation
5. **Commit regularly** (automatic after substantial changes)
6. **Keep docs updated** to avoid documentation bloat
7. **Check TODO.md** regularly for prioritized tasks

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

**You're ready to start theorem proving!** 🚀

For more details, see:
- **README.md**: System overview
- **ARCHITECTURE.md**: Detailed architecture
- **TESTING.md**: Testing procedures
