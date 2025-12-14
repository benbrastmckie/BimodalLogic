# Agent Comparison: coder vs lean-implementer

**Date**: 2025-12-14  
**Purpose**: Determine if these agents are redundant or serve different purposes

---

## Executive Summary

**Recommendation**: **Remove `coder.md`** - it's a generic multi-language development agent that doesn't belong in this LEAN 4-specific project.

**Reason**: The two agents serve completely different purposes. `lean-implementer` is LEAN 4-specific and essential to the proof workflow, while `coder` is a leftover generic development agent from the opencode-agents system.

---

## Detailed Comparison

### `coder.md`

**Purpose**: Generic multi-language development agent

**Description**: "Multi-language implementation agent for modular and functional development"

**Key Characteristics**:
- **Domain**: Generic software development (TypeScript, Python, Go, Rust, etc.)
- **Focus**: General code implementation with plan-and-approve workflow
- **Language**: Multi-language (TypeScript, Python, Go, Rust)
- **Tools**: npm, tsc, mypy, go build, cargo check, eslint, pylint, golangci-lint, clippy
- **Workflow**: Plan → Approve → Load Context → Execute → Validate → Handoff
- **Delegates to**:
  - `subagents/core/task-manager` - Feature breakdown
  - `subagents/code/coder-agent` - Simple implementations
  - `subagents/code/tester` - Testing
  - `subagents/core/documentation` - Documentation
- **Integration**: Generic, not LEAN-specific
- **Signature**: "DIGGING IN..." (generic development agent catchphrase)

**Referenced by**:
- `.opencode/README.md` - Listed as "Coding agent for systematic implementation"
- No LEAN-specific workflows or orchestrators reference it

### `lean-implementer.md`

**Purpose**: LEAN 4-specific proof implementation manager

**Description**: "Manages a team of subagents to write, lint, and verify LEAN 4 code based on a formal proof plan."

**Key Characteristics**:
- **Domain**: LEAN 4 formal verification
- **Focus**: Translating proof plans into LEAN 4 code
- **Language**: LEAN 4 only
- **Tools**: LEAN 4 compiler, LEAN linter
- **Workflow**: Plan Interpretation → Tactical Implementation → Validation & Linting → Finalize
- **Delegates to**:
  - `@tactic-selector` - Choose LEAN 4 tactics for proof steps
  - `@code-generator` - Write LEAN 4 code lines
  - `@lean-linter` - Check LEAN 4 style and formatting
- **Integration**: Core part of LEAN 4 Development Suite
- **Input**: Structured proof plan from `@lean-planner`
- **Output**: Complete, compiled `.lean` file

**Subagents** (in `.opencode/agent/subagents/lean-implementer/`):
- `tactic-selector.md` - Selects appropriate LEAN 4 tactics
- `code-generator.md` - Generates LEAN 4 code
- `lean-linter.md` - Lints LEAN 4 code

**Referenced by**:
- `lean-dev-orchestrator.md` - Routes proof implementation tasks
- `command/implement.md` - `/implement` command uses this agent
- `command/prove.md` - Part of end-to-end proving workflow
- `AGENTS_GUIDE.md` - Documented as core LEAN agent
- `WORKFLOWS.md` - Central to implementation workflow
- `README.md` - Listed as LEAN 4 primary agent

---

## Analysis

### Are They Redundant?

**No, they serve completely different purposes:**

| Aspect | coder | lean-implementer |
|--------|-------|------------------|
| **Domain** | Generic multi-language | LEAN 4 formal verification |
| **Purpose** | General code implementation | Proof plan → LEAN 4 code |
| **Languages** | TypeScript, Python, Go, Rust, etc. | LEAN 4 only |
| **Input** | User requirements, feature specs | Structured proof plan |
| **Output** | Generic code files | Compiled `.lean` files |
| **Tools** | npm, tsc, mypy, cargo, etc. | LEAN compiler, LEAN linter |
| **Workflow** | Generic development workflow | Proof-specific workflow |
| **Subagents** | Generic (task-manager, coder-agent, tester) | LEAN-specific (tactic-selector, code-generator, lean-linter) |
| **Integration** | Standalone generic agent | Core part of LEAN 4 suite |
| **Referenced** | Only in README | Orchestrator, commands, workflows, docs |

### The Problem with `coder.md`

**`coder.md` is a leftover from the opencode-agents system:**

1. **Wrong domain**: Multi-language development agent in a LEAN 4-only project
2. **Wrong tools**: References TypeScript, Python, Go, Rust tools - none relevant to LEAN
3. **Wrong workflow**: Generic development workflow, not proof-specific
4. **Not integrated**: Not referenced by any LEAN workflows or orchestrators
5. **Duplicate functionality**: Generic coding is not needed when we have LEAN-specific implementer
6. **Misleading**: Suggests this project does multi-language development (it doesn't)

### Evidence of Mismatch

**From `coder.md`**:
```markdown
Adapt to the project's language based on the files you encounter 
(TypeScript, Python, Go, Rust, etc.).
```
→ **This project only uses LEAN 4**

**From `coder.md`**:
```markdown
- Use appropriate runtime (node/bun for TS/JS, python, go run, cargo run)
- Run type checks if applicable (tsc, mypy, go build, cargo check)
- Run linting if configured (eslint, pylint, golangci-lint, clippy)
```
→ **None of these tools are used in this project**

**From `lean-implementer.md`**:
```markdown
The domain is the practical implementation of formal proofs in the LEAN 4 language.
This involves translating a logical proof plan into valid LEAN 4 syntax, selecting 
appropriate tactics, writing the code, and ensuring it compiles and adheres to 
style guidelines.
```
→ **This is exactly what this project needs**

---

## Workflow Integration

### `coder` Integration
- **Used by**: Nothing in the LEAN 4 workflow
- **Routes to**: Generic subagents (task-manager, coder-agent, tester)
- **Commands**: None
- **Workflows**: None

### `lean-implementer` Integration
- **Used by**: `@lean-dev-orchestrator` (main coordinator)
- **Routes to**: LEAN-specific subagents (tactic-selector, code-generator, lean-linter)
- **Commands**: `/implement`, `/prove`
- **Workflows**: End-to-end theorem proving, proof implementation

### Example: End-to-End Proving Workflow

**From `command/prove.md`**:
```
1. Research (lean-researcher)
2. Planning (lean-planner)
3. Plan Revision (lean-plan-reviser) if needed
4. Implementation (lean-implementer) ← Uses lean-implementer
5. Refactoring (lean-refactor-agent)
6. Documentation (codebase)
```

**Notice**: `coder` is not part of any LEAN workflow.

---

## Recommendation

### Remove `coder.md`

**Reasons**:
1. **Not relevant to LEAN 4**: This is a formal verification project, not a multi-language development project
2. **Not integrated**: Not used by any LEAN workflows, orchestrators, or commands
3. **Misleading**: Suggests the project does TypeScript/Python/Go/Rust development
4. **Leftover from opencode-agents**: Part of the old generic system
5. **No unique value**: All coding needs are handled by `lean-implementer` for LEAN 4

### Keep `lean-implementer.md`

**Reasons**:
1. **LEAN-specific**: Designed specifically for LEAN 4 proof implementation
2. **Core functionality**: Essential for translating proof plans into LEAN code
3. **Integrated with suite**: Central to LEAN 4 Development Suite workflow
4. **Has specialized subagents**: 3 LEAN-specific subagents (tactic-selector, code-generator, lean-linter)
5. **Actively used**: Referenced in orchestrator, commands (`/implement`, `/prove`), and workflows
6. **Unique workflow**: Proof plan interpretation → tactical implementation → validation

---

## Comparison Table

| Feature | coder | lean-implementer | Verdict |
|---------|-------|------------------|---------|
| **Relevant to Logos** | ❌ No (multi-language) | ✅ Yes (LEAN 4 specific) | Keep lean-implementer |
| **Unique functionality** | ❌ No (generic coding) | ✅ Yes (proof implementation) | Keep lean-implementer |
| **Has subagents** | ⚠️ Generic subagents | ✅ 3 LEAN-specific subagents | Keep lean-implementer |
| **Integrated with suite** | ❌ No | ✅ Yes (core component) | Keep lean-implementer |
| **Used in workflows** | ❌ No | ✅ Yes (prove, implement) | Keep lean-implementer |
| **Referenced in docs** | ⚠️ Minimal (only README) | ✅ Extensive (orchestrator, commands, workflows) | Keep lean-implementer |
| **Correct domain** | ❌ No (wrong languages) | ✅ Yes (LEAN 4) | Keep lean-implementer |

---

## What About Generic Coding Needs?

**Question**: What if we need to write non-LEAN code (e.g., scripts, tools)?

**Answer**: 
1. **This project is LEAN 4-only**: The Logos project is a formal verification system written entirely in LEAN 4
2. **`.opencode` system**: The `.opencode` directory contains markdown files, not code that needs a development agent
3. **General agent exists**: The `general` agent can handle any ad-hoc coding needs
4. **Not a use case**: There's no evidence of multi-language development in this project

**Evidence from project structure**:
```
Logos/                  # LEAN 4 code
LogosTest/              # LEAN 4 tests
Archive/                # LEAN 4 examples
Documentation/          # Markdown docs
.opencode/              # Markdown agent configs
```
→ **100% LEAN 4 code, no TypeScript/Python/Go/Rust**

---

## Implementation Plan

### Step 1: Remove `coder.md`

```bash
rm .opencode/agent/coder.md
```

### Step 2: Update `.opencode/README.md`

Remove the line:
```markdown
- **`coder`**: Coding agent for systematic implementation.
```

### Step 3: Verify No Other References

Check for any other references to the `coder` agent:
```bash
grep -r "@coder" .opencode --include="*.md"
grep -r "coder.md" .opencode --include="*.md"
```

**Expected result**: Only references to `@coder-agent` (subagent), not `@coder` (main agent)

---

## Conclusion

**`coder.md` should be removed** because:
1. It's a generic multi-language development agent in a LEAN 4-only project
2. It references tools (npm, tsc, mypy, cargo) that are not used in this project
3. It's not integrated with any LEAN workflows or orchestrators
4. It was created as part of the opencode-agents system and doesn't belong here
5. All coding needs are handled by `lean-implementer` for LEAN 4

**`lean-implementer.md` should be kept** because:
1. It's specifically designed for LEAN 4 proof implementation
2. It's a core component of the LEAN 4 Development Suite
3. It has unique functionality (proof plan → LEAN code)
4. It has specialized subagents for LEAN-specific tasks
5. It's actively used in workflows, commands, and the orchestrator
6. It's essential for the `/prove` and `/implement` commands

---

**Next Step**: Remove `coder.md` and update references.
