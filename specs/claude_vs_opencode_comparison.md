# .claude vs .opencode Feature Comparison

## Architecture Patterns

### .claude (3-Layer Architecture)
```
Orchestrator (Level 0)
├── Skills (Level 1) - Thin wrappers with frontmatter
│   ├── skill-researcher → general-research-agent
│   ├── skill-planner → planner-agent
│   └── skill-lean-research → lean-research-agent
├── Agents (Level 2) - Full execution logic
│   ├── general-research-agent
│   ├── planner-agent
│   └── lean-research-agent
└── Specialists (Level 3) - Focused helpers
```

### .opencode (2-Layer Architecture)
```
Orchestrator (Level 0)
├── Commands (Level 1) - Direct execution
│   ├── /research → researcher
│   ├── /plan → planner
│   └── /implement → implementer
└── Subagents (Level 2) - Execution units
    ├── researcher
    ├── planner
    └── lean-research-agent
```

## Key Feature Differences

| Feature | .claude | .opencode | Impact |
|---------|---------|-----------|--------|
| **Forked Subagents** | ✅ Isolated context loading | ❌ Direct loading | .claude: 15-20% token efficiency |
| **Skill-Internal Postflight** | ✅ No "continue" prompts | ❌ Postflight at command level | .claude: Better UX |
| **Meta System Builder** | ✅ Interactive architecture generation | ❌ Manual system creation | .claude: Extensible |
| **Hook System** | ✅ Automated guardrails | ❌ Manual validation | .claude: Self-healing |
| **File Metadata Exchange** | ✅ Reliable data transfer | ❌ Console JSON | .claude: Robust |
| **Task Tool** | ✅ Spawns isolated conversations | ❌ Direct calls | .claude: True isolation |
| **Skill Frontmatter** | ✅ Declarative configuration | ❌ Imperative code | .claude: Maintainable |
| **Postflight Markers** | ✅ Prevents premature termination | ❌ No protection | .claude: Reliable workflows |
| **jq Workarounds** | ✅ Issue #1132 solutions | ❌ Vulnerable to bugs | .claude: Stable |
| **Lazy Directory Creation** | ✅ Clean structure | ✅ Implemented | Equal |
| **Language Routing** | ✅ Implemented | ✅ Implemented | Equal |
| **State Synchronization** | ✅ Atomic updates | ✅ Implemented | Equal |

## Detailed Analysis

### 1. Forked Subagent Pattern

**.claude Implementation:**
```yaml
# skill-researcher frontmatter
---
name: skill-researcher
context: fork  # Don't load context eagerly
agent: general-research-agent  # Target to spawn
---
```

**Benefits:**
- Parent context stays ~100 tokens
- Subagent loads full context in isolation
- No context accumulation in parent

### 2. Skill-Internal Postflight

**.claude Pattern:**
```
Skill (thin wrapper):
1. Update status to [RESEARCHING]
2. Create postflight marker
3. Invoke subagent
4. Handle postflight internally
5. Return final result

Command:
1. Parse arguments
2. Delegate to skill
3. Return immediately (no postflight)
```

**Result:** No "continue" prompts

### 3. Meta System Builder

**.claude /meta Workflow:**
1. Detect existing project
2. Interactive interview (8 stages)
3. Generate complete system
4. Create agents, context, commands
5. Provide quick-start guide

**.opencode Gap:** Manual system creation only

### 4. Hook System

**.claude Hooks:**
- `subagent-postflight.sh` - Block premature termination
- `log-session.sh` - Session tracking
- `validate-state-sync.sh` - Consistency checks
- `post-command.sh` - Cleanup operations

**Protection Mechanism:**
```json
{
  "decision": "block",
  "reason": "Postflight pending: status update, artifact linking"
}
```

### 5. File-Based Metadata Exchange

**.claude Pattern:**
```json
// specs/{N}_{SLUG}/.return-meta.json
{
  "status": "researched",
  "artifacts": [...],
  "metadata": {...}
}
```

**Benefits:**
- No console pollution
- Reliable parsing
- Structured data exchange

## Upgrade Priority Matrix

| Feature | Impact | Complexity | Priority |
|---------|--------|------------|----------|
| Skill-Internal Postflight | High | Medium | 1 |
| Hook System | High | Low | 2 |
| File Metadata Exchange | Medium | Low | 3 |
| Meta System Builder | High | High | 4 |
| Forked Subagents | Medium | Medium | 5 |
| Skill Frontmatter | Low | Low | 6 |

## Migration Complexity

### Low Complexity (1-2 weeks)
- Implement hook system
- Add file metadata exchange
- Update state management

### Medium Complexity (3-4 weeks)
- Migrate workflow ownership
- Implement forked pattern
- Add skill wrappers

### High Complexity (5-8 weeks)
- Port meta system builder
- Adapt for formal verification
- Complete architecture migration

## Recommendation

Focus on Priority 1-3 first for immediate UX improvements, then tackle the meta system builder for extensibility. The forked subagent pattern, while beneficial, can be implemented incrementally.