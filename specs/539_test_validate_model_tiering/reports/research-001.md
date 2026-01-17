# Research Report: Task #539

**Task**: 539 - test_validate_model_tiering
**Date**: 2026-01-17
**Session ID**: sess_1768661701_8fd041
**Focus**: Diagnose OOM crashes during `/research 541` and identify agent system improvements

## Executive Summary

The `/research 541` failures were **NOT caused by agent system design flaws**, but by a **known Claude Code memory leak bug** (GitHub #18011). The JavaScript V8 heap exhausts after extended sessions, crashing with `SIGABRT`. However, this research identifies several architectural improvements that could reduce memory pressure and improve resilience.

## Root Cause Analysis

### Observed Symptoms

From `.claude/output/research_1.md` and `research_2.md`:
```
FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed
- JavaScript heap out of memory
```

Both crashes occurred during subagent spawning via the Skill tool, after ~4GB heap accumulation.

### True Root Cause

**GitHub Issue #18011** documents this as a known V8 memory leak affecting Claude Code 2.1.6+:
- Sessions crash after 30+ minutes even on 64GB machines
- Memory accumulates during conversation compaction cycles
- Background processes (statusline updates, MCP polling) contribute
- Subagent spawning without proper garbage collection exacerbates the issue

**This is NOT a problem with the .claude/ agent system design.**

## Agent System Components Analysis

### Current Architecture (171 markdown files, 2.2MB)

| Component | Count | Avg Lines | Memory Risk |
|-----------|-------|-----------|-------------|
| Agents | 7 | ~465 lines | **Medium** - Fully loaded into subagent context |
| Skills | 10 | ~80 lines | **Low** - Run in main context |
| Commands | 9 | ~150 lines | **Low** - Run in main context |
| Context docs | 90+ | ~50 lines | **Low** - Lazy loaded via @-references |
| Rules | 7 | ~100 lines | **Low** - Path-based activation |

### Potential Memory Pressure Points

1. **Large Agent Files** (465 lines average, 3258 total)
   - `lean-research-agent.md`: 402 lines
   - `lean-implementation-agent.md`: 466 lines
   - Entire file loaded into subagent context on spawn

2. **Verbose JSON Returns**
   - Subagent returns include full metadata blocks
   - Large `delegation_path` arrays accumulated

3. **Context Inheritance**
   - While subagents don't inherit full parent context, they do receive:
     - Their own system prompt (agent file)
     - Environment details
     - Task delegation context

4. **MCP Tool Overhead**
   - Lean agents use 16+ MCP tools
   - Each tool invocation adds to context

## Recommendations

### Immediate Mitigations (No Code Changes)

1. **Increase Node.js Heap Size**
   ```bash
   export NODE_OPTIONS="--max-old-space-size=8192"
   ```

2. **Restart Sessions Regularly**
   - Use `/clear` after long research sessions
   - Start fresh for complex multi-phase tasks

3. **Limit Parallel Subagent Usage**
   - Avoid spawning multiple subagents in quick succession
   - Let one complete before starting another

### Short-Term Improvements (Task 541 Scope)

1. **Slim Down Agent Files**
   - Move verbose examples to separate context files
   - Use @-references for return format examples
   - Target: <200 lines per agent

2. **Simplify Return Formats**
   - Remove redundant metadata fields
   - Use compact JSON structure
   - Remove `delegation_path` array (rarely used)

3. **Add Memory Pressure Documentation**
   - Document OOM risk in CLAUDE.md
   - Add troubleshooting guide

### Medium-Term Improvements (Future Tasks)

1. **Context Streaming** (if supported)
   - Load agent context incrementally
   - Stream large documents rather than full load

2. **Agent Inheritance Pattern**
   - Base agent with common elements
   - Specialized agents inherit, add specifics only

3. **Tiered Context Loading**
   - Essential context: Always loaded
   - Optional context: Loaded on-demand
   - Reference context: Never loaded, just linked

## Elegant Solution Proposal

### Progressive Disclosure Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Agent File (~100 lines)                                    │
│  ├── Frontmatter: name, description, model                  │
│  ├── Overview: 2-3 sentences                                │
│  ├── Core Instructions: Essential workflow (inline)         │
│  └── Context References: @-links to detailed docs           │
├─────────────────────────────────────────────────────────────┤
│  Context Files (loaded on-demand via @-reference)           │
│  ├── Execution Flow Details                                 │
│  ├── Return Format Examples                                 │
│  ├── Error Handling Patterns                                │
│  └── Domain-Specific Guidance                               │
└─────────────────────────────────────────────────────────────┘
```

### Implementation Pattern

**Current lean-implementation-agent.md** (466 lines):
```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
model: opus
---

# Lean Implementation Agent

[466 lines of instructions, examples, return formats...]
```

**Proposed lean-implementation-agent.md** (~100 lines):
```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
model: opus
---

# Lean Implementation Agent

## Overview
Implementation agent for Lean 4 proof development. Executes plans by
writing proofs using lean-lsp MCP tools.

## Core Workflow
1. Parse delegation context
2. Load plan, find resume point
3. Execute proof development (use lean_goal constantly)
4. Create implementation summary
5. Return structured JSON

## Context References
- @.claude/context/core/formats/subagent-return.md - Return format
- @.claude/context/project/lean4/tools/mcp-tools-guide.md - MCP tools
- @.claude/context/project/lean4/patterns/proof-development.md - Patterns

## Quick Reference
[Only essential inline guidance, ~50 lines]
```

This reduces initial context load by ~75% while preserving full functionality through @-references.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| OOM bug unfixed upstream | High | Heap size workaround, session rotation |
| Refactored agents miss context | Medium | Comprehensive @-reference coverage |
| Performance degradation | Low | @-references are cached by Claude Code |

## Sources

- [GitHub Issue #18011: Memory leak causing V8 OOM crashes](https://github.com/anthropics/claude-code/issues/18011)
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [How Claude Code Got Better by Protecting Context](https://hyperdev.matsuoka.com/p/how-claude-code-got-better-by-protecting)
- [Best Practices for Claude Code Subagents](https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/)

## Next Steps

1. **Immediate**: Apply heap size workaround in shell configuration
2. **Task 541**: Implement progressive disclosure refactoring
3. **Future**: Monitor upstream fix for GitHub #18011
