# UserGuide Documentation

[Back to Documentation](../README.md)

Project-wide user documentation for integrating ProofChecker with external tools and systems.

**Audience**: Users integrating ProofChecker with external tools

## Theory-Specific Guides

Most user documentation is theory-specific. See:

| Theory | Quick Start | Additional Guides |
|--------|-------------|-------------------|
| **Bimodal** | [Quick Start](../../Bimodal/docs/user-guide/QUICKSTART.md) | [Tutorial](../../Bimodal/docs/user-guide/TUTORIAL.md), [Examples](../../Bimodal/docs/user-guide/EXAMPLES.md), [Proof Patterns](../../Bimodal/docs/user-guide/PROOF_PATTERNS.md) |
| **Logos** | [Quick Start](../../Logos/docs/user-guide/QUICKSTART.md) | [Methodology](../../Logos/docs/user-guide/METHODOLOGY.md), [Current Status](../../Logos/docs/user-guide/CURRENT_STATUS.md) |

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
- **Bimodal**: [Tutorial](../../Bimodal/docs/user-guide/TUTORIAL.md), [Examples](../../Bimodal/docs/user-guide/EXAMPLES.md)
- **Logos**: [Quick Start](../../Logos/docs/user-guide/QUICKSTART.md)

For advanced tactic development, see:
- **Bimodal**: [Tactic Development](../../Bimodal/docs/user-guide/TACTIC_DEVELOPMENT.md)

## Related Documentation

- [Development Standards](../development/) - Coding conventions and contribution guidelines
- [Project Status](../project-info/) - Implementation status and registries
- [Reference Materials](../reference/) - APIs and terminology
- [Installation Guide](../installation/) - Setup instructions

---

[Back to Documentation](../README.md)
