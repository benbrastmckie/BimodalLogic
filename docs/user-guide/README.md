# User Guide Documentation

[Back to Documentation](../README.md)

Project-wide user documentation for integrating ProofChecker with external tools and systems.

**Audience**: Users integrating ProofChecker with external tools

## Theory-Specific Guides

The primary working system is **Bimodal**, which has complete soundness and completeness proofs.

| Theory | Status | Quick Start | Additional Guides |
|--------|--------|-------------|-------------------|
| **Bimodal** | Complete | [Quick Start](quickstart.md) | [Tutorial](tutorial.md), [Examples](examples.md), [Proof Patterns](proof-patterns.md) |

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

1. [Bimodal Quick Start](quickstart.md) - Get started with proofs
2. [Bimodal Tutorial](tutorial.md) - Step-by-step introduction
3. [Bimodal Examples](examples.md) - Worked examples

For advanced tactic development:
- [Tactic Development](tactic-development.md) - Custom tactics for Bimodal

## Related Documentation

- [Development Standards](../development/) - Coding conventions and contribution guidelines
- [Project Status](../project-info/) - Implementation status and registries
- [Reference Materials](../reference/) - APIs and terminology
- [Installation Guide](../installation/) - Setup instructions

---

[Back to Documentation](../README.md)

---

## Merged from the Lean source tree

The `docs/` tree was folded into this one. Previously the repository
carried two parallel `docs/` trees, and this file cross-linked into the other via
`docs/...` — an incoherence that the merge removes. The index below
came from the source-tree copy of this file; its entries now refer to files in this
directory.

Documentation for users working with the Bimodal TM logic library.

## Contents

| Document | Description |
|----------|-------------|
| [quickstart.md](quickstart.md) | Getting started with your first Bimodal proofs |
| [proof-patterns.md](proof-patterns.md) | Common patterns for modal and temporal reasoning |
| [examples.md](examples.md) | Worked examples with exercises and solutions |
| [troubleshooting.md](troubleshooting.md) | Common errors and how to fix them |

## Reading Order

1. **First**: [quickstart.md](quickstart.md) - Basics of writing Bimodal proofs
2. **Next**: [proof-patterns.md](proof-patterns.md) - Patterns for different proof types
3. **Practice**: [examples.md](examples.md) - Examples and exercises with solutions
4. **Reference**: [troubleshooting.md](troubleshooting.md) - When you encounter errors

## See Also

- [Bimodal Axiom Reference](../reference/axiom-reference.md) - Complete axiom schemas
- [Project Tutorial](../../../docs/user-guide/tutorial.md) - General tutorial
- [Bimodal README](../../README.md) - Library overview

## Navigation

- **Up**: [Bimodal Documentation](../)
- **Reference**: [Reference/](../reference/)
- **Project Info**: [ProjectInfo/](../project-info/)
