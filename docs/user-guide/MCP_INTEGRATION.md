# MCP Integration Guide

> **Legacy Notice**: This document originally described MCP integration for the OpenCode AI
> development system (which preceded Claude Code). The OpenCode-specific content (opencode.json
> configuration, OpenCode agent definitions) is no longer applicable. The current development
> system is Claude Code, documented at [.claude/CLAUDE.md](../../.claude/CLAUDE.md).
>
> The core concepts below (lean-lsp-mcp server, tool capabilities) remain valid for Claude Code
> as well, which also supports MCP servers.

## Overview

The `lean-lsp-mcp` server provides Lean 4 language server capabilities as MCP tools, enabling
AI agents to interact with Lean code during proof development.

## lean-lsp-mcp Server

### Capabilities

The `lean-lsp-mcp` server exposes the following MCP tools:

| Tool | Description |
|------|-------------|
| `lean_goal` | Inspect goal state at a position in a Lean file |
| `lean_state_search` | Search for relevant tactics or lemmas by goal pattern |
| `lean_hammer_premise` | Query premise selection for automated proof search |
| `lean_loogle` | Search Mathlib by type signature via Loogle |
| `lean_leansearch` | Natural language search of Lean libraries |
| `lean_leanfinder` | Find relevant Lean definitions and theorems |

### Claude Code Configuration

MCP servers are configured in `.claude/settings.json`. See `.claude/CLAUDE.md` for the
current Claude Code system documentation.

## Lean 4 MCP Integration Patterns

### Goal State Inspection

When developing proofs, use `lean_goal` to check proof state:

```
lean_goal(file_path="Theories/Bimodal/Metalogic/Completeness.lean", line=42, column=4)
```

### Mathlib Search

Search for relevant Mathlib lemmas during proof development:

```
lean_loogle("List.length_map")
lean_leansearch("Filter preserves membership")
```

## References

- [Claude Code System](.claude/CLAUDE.md) - Current AI development system
- [Lean Style Guide](../development/LEAN_STYLE_GUIDE.md) - Lean 4 coding conventions
- [Contributing Guide](../development/CONTRIBUTING.md) - Development workflow
