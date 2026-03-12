# User Guide Documentation

[Back to Documentation](../README.md)

Project-wide user documentation for integrating ProofChecker with external tools and systems.

**Audience**: Users integrating ProofChecker with external tools

## Theory-Specific Guides

The primary working system is **Bimodal**, which has complete soundness and completeness proofs.

| Theory | Status | Quick Start | Additional Guides |
|--------|--------|-------------|-------------------|
| **Bimodal** | Complete | [Quick Start](../../Theories/Bimodal/docs/user-guide/QUICKSTART.md) | [Tutorial](../../Theories/Bimodal/docs/user-guide/TUTORIAL.md), [Examples](../../Theories/Bimodal/docs/user-guide/EXAMPLES.md), [Proof Patterns](../../Theories/Bimodal/docs/user-guide/PROOF_PATTERNS.md) |

**Recommendation**: Start with Bimodal for a production-ready modal-temporal logic implementation.

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

**Start with Bimodal** - the complete, verified implementation:

1. [Bimodal Quick Start](../../Theories/Bimodal/docs/user-guide/QUICKSTART.md) - Get started with proofs
2. [Bimodal Tutorial](../../Theories/Bimodal/docs/user-guide/TUTORIAL.md) - Step-by-step introduction
3. [Bimodal Examples](../../Theories/Bimodal/docs/user-guide/EXAMPLES.md) - Worked examples

For advanced tactic development:
- [Tactic Development](../../Theories/Bimodal/docs/user-guide/TACTIC_DEVELOPMENT.md) - Custom tactics for Bimodal

## Related Documentation

- [Development Standards](../development/) - Coding conventions and contribution guidelines
- [Project Status](../project-info/) - Implementation status and registries
- [Reference Materials](../reference/) - APIs and terminology
- [Installation Guide](../installation/) - Setup instructions

---

[Back to Documentation](../README.md)
