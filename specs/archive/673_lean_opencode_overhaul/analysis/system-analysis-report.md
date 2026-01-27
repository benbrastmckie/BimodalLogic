# System Analysis Report: .claude vs .opencode Architecture

## Executive Summary

Analysis of ProofChecker's dual agent systems reveals a fundamental architecture mismatch: .opencode/ system expects Python infrastructure while the project is actually LEAN 4. The .claude/ system works correctly using bash-based command execution and LEAN-specific tools. This report recommends complete migration of working .claude/ patterns to .opencode/ structure with LEAN optimizations.

## Current State Analysis

### Working .claude/ System

**Strengths:**
- Bash-based command execution actually works
- LEAN 4-specific skills (skill-lean-research, skill-lean-implementation)
- Functional task management (specs/state.json + TODO.md)
- Proven agent delegation patterns
- LEAN tool integration (LeanSearch, Loogle, lean-lsp)
- ProofChecker-specific context (Logos, Bimodal theories)

**Structure:**
```
.claude/
├── commands/*.sh          # Working bash scripts
├── skills/*/SKILL.md       # LEAN-specific capabilities
├── agents/*.md           # Functional agents
├── context/project/        # ProofChecker-specific knowledge
└── proven workflows       # Research → Plan → Implement
```

### Broken .opencode/ System

**Critical Issues:**
- Expects `poetry run python src/main.py` (non-existent)
- No Python project structure (no pyproject.toml, src/)
- Generic agent patterns not adapted for LEAN 4
- Command definitions expect Python execution
- Missing LEAN-specific workflows

**Evidence of Failure:**
```
/task --abandon 671
→ poetry: command not found
→ Command fails completely
```

## Architecture Mismatch Details

### 1. Project Type Confusion
- **Expected**: Python project with Poetry dependency management
- **Actual**: LEAN 4 project with Lake build system
- **Impact**: Every command fails with "poetry: command not found"

### 2. Execution Infrastructure
- **.claude/**: Uses bash scripts directly (`#!/usr/bin/env bash`)
- **.opencode/**: Assumes Python entry point
- **Solution**: Use bash execution model in .opencode/

### 3. LEAN 4 Specialization Gap
- **.claude/**: Has LEAN research, implementation, and Mathlib integration
- **.opencode/**: Generic patterns, no LEAN-specific workflows
- **Need**: Port LEAN expertise to .opencode/

## Migration Strategy

### Phase 1: Fix Command Execution (Priority 1)
Create bash-based command execution in .opencode/
- Replace Python expectations with bash scripts
- Update command frontmatter to use bash
- Test with currently failing /task command

### Phase 2: Port Core Agents (Priority 2)
Migrate working agents from .claude/ to .opencode/
- proofchecker-orchestrator (from skill-orchestrator)
- lean-research-agent (LEAN 4 + Mathlib)
- lean-implementation-agent (proof development)
- lean-verification-agent (proof checking)

### Phase 3: LEAN Command Enhancement (Priority 3)
Create LEAN-specific commands
- lean-build, lean-test, lean-proof
- theorem-research, proof-verify
- mathlib-search integration

### Phase 4: Context Migration (Priority 4)
Organize LEAN-optimized context
- LEAN 4 standards and conventions
- ProofChecker-specific knowledge (Logos, Bimodal)
- Tool integration guides

## Risk Assessment

### High Risk Items
1. **Command Execution Failure**: Current state breaks all functionality
   - **Mitigation**: Fix bash execution first, preserve .claude/ as backup

2. **Data Loss During Migration**: Task state corruption
   - **Mitigation**: Preserve specs/ structure unchanged

### Medium Risk Items
1. **Agent Integration Complexity**: LEAN tool dependencies
   - **Mitigation**: Start with basic LEAN commands, enhance iteratively

2. **User Workflow Disruption**: Learning new command patterns
   - **Mitigation**: Maintain similar command interface where possible

## Recommended Solution

**Complete Migration to LEAN-Optimized .opencode/**

1. **Immediate**: Fix command execution using bash model
2. **Port**: All working .claude/ components to .opencode/
3. **Enhance**: With LEAN 4-specific capabilities
4. **Test**: End-to-end functionality
5. **Document**: New system architecture and usage

This approach transforms the broken system into a LEAN 4-optimized environment while preserving all functional patterns from the working .claude/ system.

## Conclusion

The .opencode/ system requires complete overhaul to work with LEAN 4 projects. The .claude/ system provides proven patterns that can be successfully migrated with LEAN-specific enhancements. Priority should be fixing command execution first, then migrating agents and commands.

**Next Step**: Implement Phase 1 (bash execution fix) to restore basic functionality.