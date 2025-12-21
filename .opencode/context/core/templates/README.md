# Meta-System Templates

**Purpose**: Reusable templates for creating agents and commands via `/meta`  
**Last Updated**: December 20, 2025

## Overview

This directory contains templates used by the meta-system agent to generate new agents and commands for the ProofChecker system. All templates follow research-backed XML patterns from Stanford and Anthropic for optimal AI performance.

## Available Templates

### Agent Templates

**`orchestrator-template.md`** - Main coordinator agent pattern
- Multi-stage workflow execution
- Intelligent routing to subagents
- 3-level context allocation
- Validation gates and checkpoints

**`subagent-template.md`** - Specialized subagent pattern
- Single responsibility focus
- Stateless operation
- Explicit input/output specifications
- Pre/post execution validation

## Template Structure

All templates include:
- **XML structure** with optimal component ordering (context→role→task→workflow)
- **Placeholder markers** for customization (`{domain}`, `{agent_name}`, etc.)
- **Example content** showing proper usage
- **Validation criteria** for quality assurance
- **Best practices** from research

## Template Variables

Standard placeholders used across templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `{domain}` | Domain name | "LEAN 4 Theorem Proving" |
| `{agent_name}` | Agent identifier | "proof-developer" |
| `{purpose}` | Primary purpose | "Develop formal proofs" |
| `{specialist_domain}` | Area of expertise | "Tactic-based proofs" |
| `{task_scope}` | Specific task | "Implement tactic proofs" |

## Usage by Meta Agent

The meta agent (`@subagents/meta`) uses these templates when:
1. User runs `/meta` command
2. User requests agent or command creation
3. User requests agent or command modification

**Process**:
1. Meta agent loads appropriate template
2. Replaces placeholders with user-provided values
3. Validates generated content against quality standards
4. Writes new agent/command file
5. Returns summary and usage instructions

## Quality Standards

All generated agents/commands must:
- ✅ Follow optimal component ordering (context→role→task→workflow)
- ✅ Include hierarchical context structure
- ✅ Use @ symbol routing for subagents
- ✅ Implement 3-level context allocation
- ✅ Include validation gates (pre_flight, post_flight)
- ✅ Score 8+/10 on XML optimization criteria

## Research-Backed Patterns

Templates implement proven optimizations:
- **+20% routing accuracy** (LLM-based decisions with @ routing)
- **+25% consistency** (XML structure with optimal ordering)
- **80% context efficiency** (3-level allocation: Level 1 for 80% of tasks)
- **+17% overall performance** (position-sensitive component sequencing)

## Related Files

- **Meta Agent**: `.opencode/agent/subagents/meta.md`
- **Meta Command**: `.opencode/command/meta.md`
- **Builder Guide**: `meta-guide.md`
- **System Architecture**: `.opencode/ARCHITECTURE.md`

## Adding New Templates

To add a new template:
1. Create file with descriptive name (e.g., `specialist-template.md`)
2. Follow XML structure with optimal component ordering
3. Include placeholder markers for customization
4. Add example content and validation criteria
5. Document in this README
6. Update meta agent to reference new template
