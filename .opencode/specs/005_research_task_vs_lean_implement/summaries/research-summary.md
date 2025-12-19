# Research Summary: `/task` vs `/lean implement` Command Comparison

**Project**: #005  
**Date**: 2025-12-19  
**Type**: Command Capability Analysis

---

## Key Findings

1. **Commands Serve Different Purposes - NOT Interchangeable**
   - `/task` = Task execution orchestrator (routes to workflows based on complexity)
   - `/lean` = LEAN 4 proof implementation (specialized proof development)
   - `/implement` = General code implementation (for .opencode/ utilities)

2. **Critical Discovery: Missing Specialist Agents**
   - **14 specialist agents referenced in architecture but NOT FOUND in codebase**
   - **3 CRITICAL missing**: `tactic-specialist`, `term-mode-specialist`, `metaprogramming-specialist`
   - Impact: `/lean` command cannot delegate to specialists as designed

3. **Correct Workflow for LEAN Proof Development**
   - Step 1: `/task {number}` → Executes TODO.md task, creates research + plan
   - Step 2: `/lean {project}` → Implements proof following plan with verification
   - Step 3: Manual TODO.md completion (or use todo-manager)

4. **Unique Capabilities by Command**
   - `/task`: Batch execution, TODO.md tracking, adaptive workflow (research + plan OR plan only)
   - `/lean`: lean-lsp-mcp integration, git commits, LEAN-specific verification
   - `/implement`: General code, pattern compliance, security validation

5. **Answer to Research Question**
   - **NO**, `/task` does NOT provide same advantages as `/lean` for proof development
   - `/task` handles task management and planning; `/lean` handles implementation
   - Both commands are needed for complete LEAN proof workflow

---

## Most Relevant Resources

### Command Specifications
- `.opencode/command/task.md` - Task execution with batch support and TODO.md tracking
- `.opencode/command/lean.md` - LEAN 4 proof implementation with lean-lsp-mcp
- `.opencode/command/implement.md` - General code implementation

### Agent Specifications
- `.opencode/agent/subagents/task-executor.md` - Complexity analysis, adaptive workflow
- `.opencode/agent/subagents/proof-developer.md` - Proof implementation (references missing specialists)
- `.opencode/agent/subagents/researcher.md` - Multi-source research coordination

### Architecture
- `.opencode/ARCHITECTURE.md` - System overview showing specialist agent gap
- `.opencode/agent/orchestrator.md` - Routing intelligence and context allocation

---

## Recommendations

### For User (Immediate)

1. **Use `/task` for TODO.md task execution** - It will create plans and recommend next steps
2. **Use `/lean` for LEAN 4 proof implementation** - It has lean-lsp-mcp integration
3. **Do NOT expect `/task` to implement proofs directly** - It routes to other commands
4. **Be aware of missing specialists** - Architecture docs describe features not yet implemented

### For Development (Future)

1. **High Priority**: Create 3 CRITICAL specialists (tactic, term-mode, metaprogramming)
2. **Medium Priority**: Create research specialists (lean-search, loogle, web-research)
3. **Documentation**: Update architecture to match actual implementation OR implement missing agents
4. **Testing**: Verify actual workflow behavior vs. documented capabilities

---

## Command Selection Quick Reference

```
TODO.md task? → /task {number}
  ├─ Creates plan
  ├─ Recommends /lean or /implement
  └─ Tracks status

LEAN proof? → /lean {project}
  ├─ Implements following plan
  ├─ Verifies with lean-lsp-mcp
  └─ Makes git commits

General code? → /implement {description}
  ├─ Implements .opencode/ utilities
  ├─ Validates patterns
  └─ Checks security
```

---

## Full Report

See: `.opencode/specs/005_research_task_vs_lean_implement/reports/research-001.md`

**Report Sections:**
- Executive Summary
- Command Comparison Table (detailed feature comparison)
- Specialist Agent Access Analysis (with missing agent list)
- Workflow Analysis (stage-by-stage breakdown)
- Use Case Recommendations (when to use each command)
- Comparative Advantages and Limitations
- Critical Findings: Missing Specialist Agents
- Implementation Recommendations
- Decision Tree and Best Practices
