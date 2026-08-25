# Project Info Documentation

[Back to Documentation](../README.md)

Project-wide status tracking, feature registries, and workflow documentation.
This directory contains the "Four-Document Model" for maintaining project state and tracking
technical debt.

**Audience**: Contributors, maintainers

## Theory-Specific Status

For theory-specific implementation status, see:

| Theory | Status Documents |
|--------|------------------|
| **Bimodal** | [Implementation Status](implementation-status.md), [Known Limitations](known-limitations.md) |

## Documentation Overview

Project Info maintains the authoritative records of implementation progress, feature capabilities,
technical debt (sorry placeholders), and the workflow for managing these documents.

## Status Tracking

Module-by-module implementation status and technical debt:

| Document | Description |
|----------|-------------|
| [implementation-status.md](implementation-status.md) | Module completion percentages and Known Limitations section |

Technical debt is not tracked by hand: check C3 of `scripts/check-module-invariants.sh`
asserts the structural sorry inventory is zero.

## Feature Tracking

Registry of features:

| Document | Description |
|----------|-------------|
| [FEATURE_REGISTRY.md](FEATURE_REGISTRY.md) | Feature tracking and capability documentation |

> **Theory-specific tactics**: See [docs/project-info/tactic-registry.md](tactic-registry.md)
> for tactic implementation status and usage patterns.

## Workflow Documentation

Task management and documentation synchronization:

| Document | Description |
|----------|-------------|
| [MAINTENANCE.md](MAINTENANCE.md) | TODO management workflow, git-based history model |

## The Four-Document Model

The project uses a Three-Document Model for tracking project state, with the sorry
inventory delegated to a mechanical check rather than a fourth document:

1. **[TODO.md](../../specs/TODO.md)** - Active task tracking (active work only)
2. **[implementation-status.md](implementation-status.md)** - Module-by-module completion tracking
3. **[FEATURE_REGISTRY.md](FEATURE_REGISTRY.md)** - Feature tracking and capabilities

Check C3 of `scripts/check-module-invariants.sh` is the sorry inventory: it asserts a hard
zero across `FormalSystem/` by content and is exit-code-affecting.

See [MAINTENANCE.md](MAINTENANCE.md) for the complete workflow for updating these documents.

## Quick Reference

### Finding Implementation Status

- **Module completion**: [implementation-status.md](implementation-status.md)
- **Known limitations**: [implementation-status.md#known-limitations](implementation-status.md#known-limitations)
- **Sorry placeholders**: none; asserted zero by check C3 of `scripts/check-module-invariants.sh`

### Finding Capabilities

- **Available features**: [FEATURE_REGISTRY.md](FEATURE_REGISTRY.md)
- **Theory tactics**: See theory-specific project-info directories

### Managing Tasks

- **Active tasks**: [TODO.md](../../specs/TODO.md)
- **Task workflow**: [MAINTENANCE.md](MAINTENANCE.md)

## Related Documentation

- [Development Standards](../development/) - Coding conventions and contribution guidelines
- [User Guides](../user-guide/) - End-user documentation

---

[Back to Documentation](../README.md)

---

## Merged from the Lean source tree

The `docs/` tree was folded into this one. Previously the repository
carried two parallel `docs/` trees, and this file cross-linked into the other via
`docs/...` — an incoherence that the merge removes. The index below
came from the source-tree copy of this file; its entries now refer to files in this
directory.

Project status and tracking for the Bimodal TM logic implementation.

## Contents

| Document | Description |
|----------|-------------|
| [implementation-status.md](implementation-status.md) | Module-by-module implementation status |
| [known-limitations.md](known-limitations.md) | Current MVP limitations and workarounds |
| [performance-targets.md](performance-targets.md) | Performance baselines and regression thresholds |
| [tactic-registry.md](tactic-registry.md) | Available tactics and automation |

## Quick Status

| Layer | Status | Completion |
|-------|--------|------------|
| Layer 0 (Syntax, ProofSystem) | Complete | 100% |
| Layer 1 (Semantics) | Complete | 100% |
| Layer 2 (Metalogic) | Partial | ~60% |
| Layer 3 (Theorems) | Partial | ~80% |
| Layer 4 (Automation) | Partial | ~50% |

## Key Metrics

- **Total Lean Files**: ~40
- **Soundness**: Proven
- **Completeness**: Dense/discrete frame classes proven sorry-free; general Base-frame case has
  one residual proof debt
- **Known Sorries**: 12 (all in `Metalogic/`; none in `Examples/` or `Tests/`)

## See Also

- [Project Implementation Status](../../../docs/project-info/implementation-status.md) -
  Project-wide status
- [Feature Registry](../../../docs/project-info/FEATURE_REGISTRY.md) - Feature tracking

## Navigation

- **Up**: [Bimodal Documentation](../)
- **User Guide**: [UserGuide/](../user-guide/)
- **Reference**: [Reference/](../reference/)
