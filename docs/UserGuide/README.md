# UserGuide Documentation

[Back to Documentation](../README.md)

Project-wide user documentation for integrating ProofChecker with external tools and systems.

**Audience**: Users integrating ProofChecker with external tools

## Theory-Specific Guides

Most user documentation is theory-specific. See:

| Theory | Quick Start | Additional Guides |
|--------|-------------|-------------------|
| **Bimodal** | [Quick Start](../../Bimodal/docs/UserGuide/QUICKSTART.md) | [Tutorial](../../Bimodal/docs/UserGuide/TUTORIAL.md), [Examples](../../Bimodal/docs/UserGuide/EXAMPLES.md), [Proof Patterns](../../Bimodal/docs/UserGuide/PROOF_PATTERNS.md) |
| **Logos** | [Quick Start](../../Logos/docs/UserGuide/QUICKSTART.md) | [Methodology](../../Logos/docs/UserGuide/METHODOLOGY.md), [Current Status](../../Logos/docs/UserGuide/CURRENT_STATUS.md) |

## Project-Wide Integration

This directory contains integration guides applicable across all theories:

| Document | Description |
|----------|-------------|
| [INTEGRATION.md](INTEGRATION.md) | Model-checker integration and external tool connectivity |
| [MCP_INTEGRATION.md](MCP_INTEGRATION.md) | MCP server integration (advanced users/developers) |

## Integration Overview

### Model-Checker Integration

[INTEGRATION.md](INTEGRATION.md) covers:
- Connecting ProofChecker with the Model-Checker for semantic verification
- SMT-LIB export for external tool connectivity
- Dual verification architecture for AI training

### MCP Server Integration

[MCP_INTEGRATION.md](MCP_INTEGRATION.md) covers:
- Setting up MCP servers for AI-assisted development
- Lean LSP tools for proof development
- Advanced workflow integration

## Getting Started

For tutorials and examples, see theory-specific UserGuide directories:
- **Bimodal**: [Tutorial](../../Bimodal/docs/UserGuide/TUTORIAL.md), [Examples](../../Bimodal/docs/UserGuide/EXAMPLES.md)
- **Logos**: [Quick Start](../../Logos/docs/UserGuide/QUICKSTART.md)

For advanced tactic development, see:
- **Bimodal**: [Tactic Development](../../Bimodal/docs/UserGuide/TACTIC_DEVELOPMENT.md)

## Related Documentation

- [Development Standards](../Development/) - Coding conventions and contribution guidelines
- [Project Status](../ProjectInfo/) - Implementation status and registries
- [Reference Materials](../Reference/) - APIs and terminology
- [Installation Guide](../Installation/) - Setup instructions

---

[Back to Documentation](../README.md)
