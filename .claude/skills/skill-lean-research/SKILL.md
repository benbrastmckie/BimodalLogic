---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Invoke for Lean-language research using LeanSearch, Loogle, and lean-lsp tools.
allowed-tools: Task
context: fork
agent: lean-research-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/lean4/tools/mcp-tools-guide.md
#   - .claude/context/project/lean4/tools/leansearch-api.md
#   - .claude/context/project/lean4/tools/loogle-api.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
#   - mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle
#   - mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search
#   - mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search
#   - mcp__lean-lsp__lean_hammer_premise
---

# Lean Research Skill

Specialized research for Lean 4 theorem proving tasks using MCP tools.

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- Research involves Mathlib, theorems, or proofs
- Lean-specific MCP tools are needed

---

## Systematic Research Workflow

### Step 1: Understand Task Requirements

Before searching:
1. Extract key mathematical concepts from task description
2. Identify target theorem or definition type
3. Note any known related theorems or patterns
4. Determine if this is proof search, definition lookup, or tactic discovery

### Step 2: Search Local Project First

Always start local (no rate limits):
```
1. lean_local_search with key terms
2. Grep for related code patterns
3. Read relevant .lean files for context
```

**Why local first?**
- No rate limit on lean_local_search
- Project may already have relevant definitions
- Understand existing patterns before searching externally

### Step 3: Search Mathlib with Appropriate Tool

Choose tool based on what you know (see Tool Selection Matrix below):
```
Know the concept? → lean_leansearch or lean_leanfinder
Know the type pattern? → lean_loogle
Have a goal to close? → lean_state_search
Need simp hints? → lean_hammer_premise
```

### Step 4: Verify and Cross-Reference

After finding candidates:
```
1. lean_local_search to verify name exists
2. lean_hover_info for full type signature
3. Check imports are available
```

### Step 5: Synthesize into Research Report

Compile findings into actionable report:
- List verified theorems with types
- Provide proof sketch
- Document required imports
- Note potential challenges

---

## Tool Selection Matrix

| I need to... | Use this tool | Rate limit |
|--------------|---------------|------------|
| Check if X exists locally | `lean_local_search` | None |
| Find theorem by concept | `lean_leansearch` | 3/30s |
| Find theorem by type pattern | `lean_loogle` | 3/30s |
| Find Lean name for math concept | `lean_leanfinder` | 10/30s |
| Find lemma to close goal | `lean_state_search` | 3/30s |
| Get simp/aesop hints | `lean_hammer_premise` | 3/30s |
| Get type signature | `lean_hover_info` | None |

### Search Decision Tree

```
1. "Does X exist in this project?"
   → lean_local_search (ALWAYS FIRST)

2. "I need a theorem that says X"
   → lean_leansearch (natural language)

3. "Find theorem matching this type"
   → lean_loogle (type pattern like "?a → ?b")

4. "What's the Lean name for concept X?"
   → lean_leanfinder (mathematical concept)

5. "What closes this specific goal?"
   → lean_state_search (at file:line:col)

6. "What should I feed to simp?"
   → lean_hammer_premise (at file:line:col)
```

### After Finding a Name

Always verify before using:
```
1. lean_local_search → confirm it exists
2. lean_hover_info → get full signature and docs
```

---

## Rate Limit Management

### Rate Limits by Tool

| Tool | Limit | Strategy |
|------|-------|----------|
| `lean_leansearch` | 3 req/30s | Use for initial exploration |
| `lean_loogle` | 3 req/30s | Use when type pattern is known |
| `lean_leanfinder` | 10 req/30s | Preferred for concepts (higher limit) |
| `lean_state_search` | 3 req/30s | Use only at specific goals |
| `lean_hammer_premise` | 3 req/30s | Use only when automating |

### Best Practices

1. **Always search locally first** - `lean_local_search` has no rate limit
2. **Prefer lean_leanfinder** - 10/30s vs 3/30s for conceptual queries
3. **Batch similar queries** - think before searching
4. **Cache found names** - note theorems for reuse
5. **Use hover_info generously** - no rate limit for verification

### Fallback Strategies

If rate limited:
- Wait 30 seconds before next search request
- Use `lean_local_search` in the meantime
- Use web search for Mathlib documentation
- Read Mathlib source files directly

---

## Common Research Patterns

### Pattern 1: Find Theorem by Name

```
Goal: Find "add_comm" or similar
1. lean_local_search "add_comm" → check local
2. lean_loogle "?a + ?b = ?b + ?a" → find by type
3. lean_hover_info on result → get full signature
```

### Pattern 2: Find Theorem by Type

```
Goal: Find theorem with specific type signature
1. lean_loogle "(?a → ?b) → List ?a → List ?b"
2. Or: lean_loogle "_ * (_ ^ _)" for patterns
3. Verify with lean_hover_info
```

### Pattern 3: Find Tactic for Goal

```
Goal: Close a specific proof goal
1. lean_state_search at goal position
2. Or: lean_hammer_premise for automation hints
3. Try suggested lemmas with lean_multi_attempt
```

### Pattern 4: Explore Unfamiliar Area

```
Goal: Understand what's available in an area
1. lean_leansearch with natural language
2. lean_leanfinder for conceptual exploration
3. Read returned theorem docs
```

---

## Research Tools Reference

### lean_local_search (No Rate Limit)
Fast local declaration search. ALWAYS use first.
```
Query: "Frame"
Returns: Local project declarations matching name
```

### lean_leansearch (3 req/30s)
Natural language → Mathlib theorems
```
Query: "sum of two even numbers is even"
Returns: Relevant theorem names and signatures
```

### lean_loogle (3 req/30s)
Type pattern → Mathlib lemmas
```
Query: "(?a → ?b) → List ?a → List ?b"
Query: "_ * (_ ^ _)"
Query: "Real.sin"
Returns: Matching type signatures
```

### lean_leanfinder (10 req/30s)
Semantic/conceptual search (preferred for concepts)
```
Query: "commutativity of addition on natural numbers"
Returns: Conceptually related theorems
```

### lean_state_search (3 req/30s)
Find lemmas to close goal at position
```
Parameters: file_path, line, column
Returns: Lemmas that could close the goal
```

### lean_hammer_premise (3 req/30s)
Get premises for simp/aesop automation
```
Parameters: file_path, line, column
Returns: Lemma names for simp only [...] or aesop
```

### lean_hover_info (No Rate Limit)
Get type signature and documentation
```
Parameters: file_path, line, column (at START of identifier)
Returns: Full type and docstring
```

---

## Research Report Format

```markdown
# Lean Research Report: Task #{N}

**Task**: {title}
**Date**: {date}
**Focus**: {focus}

## Summary

{2-3 sentence overview of findings}

## Local Project Findings

### Related Definitions
- `Namespace.Definition` - {description}

### Related Theorems
- `Namespace.theorem_name` - {what it proves}

## Mathlib Findings

### Relevant Theorems
| Name | Type | Relevance |
|------|------|-----------|
| `Theorem.name` | `Type` | {why useful} |

### Proof Patterns
{Common patterns found in similar proofs}

### Required Imports
```lean
import Mathlib.Tactic
import Mathlib.{Specific.Module}
```

## Recommended Approach

1. {Step 1 with specific theorems to use}
2. {Step 2}

## Proof Sketch

```lean
theorem target_theorem : Statement := by
  -- Use {theorem1} for first step
  -- Apply {theorem2} to transform
  -- Finish with {tactic}
```

## Potential Challenges

- {Challenge and how to address}

## References

- {Mathlib doc links if applicable}
```

---

## Return Format

```json
{
  "status": "completed",
  "summary": "Found N relevant theorems for proof",
  "artifacts": [
    {
      "path": ".claude/specs/{N}_{SLUG}/reports/research-001.md",
      "type": "research",
      "description": "Lean research report"
    }
  ],
  "theorems_found": [
    {"name": "Theorem.name", "relevance": "high"}
  ],
  "imports_needed": [
    "Mathlib.Specific.Module"
  ],
  "proof_approach": "Description of recommended approach"
}
```

---

## Error Handling

### MCP Tool Errors

If MCP tools return errors:
1. Check if `LEAN_PROJECT_PATH` is correct in `.mcp.json`
2. Verify lean-lsp-mcp server is running
3. Fall back to web search for Mathlib docs
4. Use `lake build` for local verification

### Rate Limit Errors

If rate limited:
1. Wait 30 seconds
2. Use non-rate-limited tools (`lean_local_search`, `lean_hover_info`)
3. Batch remaining queries more efficiently
