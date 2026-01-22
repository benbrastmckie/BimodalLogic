# Quick Start Guide for .opencode Upgrade

## Overview

This guide helps you quickly understand and implement the key upgrades from .claude to .opencode. Focus on the highest impact changes first.

## Immediate Wins (Implement This Week)

### 1. Eliminate "Continue" Prompts

**Problem**: Users hate the "continue" prompts between workflow stages.

**Solution**: Move postflight operations into subagents.

**Quick Implementation**:
```markdown
# In your subagent (e.g., researcher.md)
<workflow>
1. Update status to [RESEARCHING] immediately
2. Do the research work
3. Update status to [RESEARCHED] 
4. Create git commit
5. Return result
</workflow>

# In your command (e.g., research.md)
<workflow>
1. Parse arguments
2. Delegate to subagent
3. Return (no postflight needed)
</workflow>
```

**Result**: Seamless workflow completion.

### 2. Add Workflow Safety

**Problem**: Workflows can fail silently or leave inconsistent state.

**Solution**: Implement hook system.

**Quick Implementation**:
```bash
# Create .opencode/hooks/subagent-postflight.sh
#!/bin/bash
MARKER_FILE="specs/.postflight-pending"

if [ -f "$MARKER_FILE" ]; then
    echo '{"decision": "block", "reason": "Postflight operations pending"}'
    exit 0
fi

echo '{}'
```

**Result**: Prevents premature termination.

### 3. Fix Data Exchange

**Problem**: Console JSON gets polluted and is hard to parse.

**Solution**: Use file-based metadata.

**Quick Implementation**:
```json
// Subagent writes to specs/{N}_{SLUG}/.return-meta.json
{
  "status": "researched",
  "artifacts": [{"type": "report", "path": "...", "summary": "..."}],
  "metadata": {"session_id": "...", "agent_type": "..."}
}

// Skill reads file for postflight
metadata=$(cat "specs/${task_number}_${slug}/.return-meta.json")
status=$(echo "$metadata" | jq -r '.status')
```

**Result**: Reliable data transfer.

---

## Week 2: Workflow Ownership

### Update All Subagents

1. **Researcher**: Owns complete research workflow
2. **Planner**: Owns planning workflow  
3. **Implementer**: Owns implementation workflow

Each should:
- Update status at start
- Perform work
- Update status at end
- Create git commit
- Return structured result

---

## Week 3-4: Meta System Builder

### Why This Matters

The meta system builder lets users:
- Generate domain-specific agent systems
- Extend .opencode for new areas
- Maintain consistent architecture

### Key Components

1. **Interactive Interview**: 8-stage workflow
2. **Domain Analyzer**: Extract core concepts
3. **Agent Generator**: Create optimized agents
4. **Context Organizer**: Modular knowledge files

### Formal Verification Focus

Add templates for:
- Coq proof strategies
- Isabelle theory patterns
- Lean 4 theorem workflows

---

## Week 5-6: Token Efficiency

### Forked Subagent Pattern

**Current**: Commands load all context upfront
**Problem**: Bloated parent context

**Solution**: Skills stay thin, agents load context

```yaml
# skill-researcher
---
name: skill-researcher
context: fork  # Don't load context
agent: general-research-agent
---
# Just validation + delegation
```

**Benefit**: 15-20% token savings

---

## Testing Your Changes

### 1. Workflow Test
```bash
# Test research workflow
/opencode/research 259

# Should complete without prompts
# Status should update immediately
# Git commit should be created
```

### 2. Hook Test
```bash
# Create marker file
echo '{"test": true}' > specs/.postflight-pending

# Try to stop - should be blocked
# Remove marker - should allow stop
```

### 3. Metadata Test
```bash
# Run research
# Check .return-meta.json exists
# Verify JSON is valid
# Check artifact paths
```

---

## Troubleshooting

### "Continue" Prompts Still Appear
- Check postflight is in subagent, not command
- Verify marker files are created/removed correctly
- Ensure hooks are executable

### Git Commits Missing
- Check git-workflow-manager is invoked
- Verify git status has changes
- Check permissions for git operations

### Token Usage Not Reduced
- Verify `context: fork` in skill frontmatter
- Check agents load context via @-references
- Monitor parent context size

---

## Success Indicators

✅ **Week 1**: No more "continue" prompts  
✅ **Week 2**: All workflows seamless  
✅ **Week 4**: /meta command working  
✅ **Week 6**: 15% token reduction achieved  

---

## Need Help?

- Check `.claude/` for reference implementations
- Review error logs in `.opencode/logs/`
- Use `/errors` command to diagnose issues
- Consult full upgrade plan for details

Remember: Gradual implementation is better than big bang. Start with the immediate wins!