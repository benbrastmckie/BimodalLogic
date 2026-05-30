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
| **Bimodal** | [Implementation Status](../../Theories/Bimodal/docs/project-info/implementation-status.md), [Known Limitations](../../Theories/Bimodal/docs/project-info/known-limitations.md) |

## Documentation Overview

Project Info maintains the authoritative records of implementation progress, feature capabilities,
technical debt (sorry placeholders), and the workflow for managing these documents.

## Status Tracking

Module-by-module implementation status and technical debt:

| Document | Description |
|----------|-------------|
| [implementation-status.md](implementation-status.md) | Module completion percentages and Known Limitations section |
| [SORRY_REGISTRY.md](SORRY_REGISTRY.md) | Technical debt tracking (sorry placeholders with resolution context) |

## Feature Tracking

Registry of features:

| Document | Description |
|----------|-------------|
| [FEATURE_REGISTRY.md](FEATURE_REGISTRY.md) | Feature tracking and capability documentation |

> **Theory-specific tactics**: See [Theories/Bimodal/docs/project-info/tactic-registry.md](../../Theories/Bimodal/docs/project-info/tactic-registry.md)
> for tactic implementation status and usage patterns.

## Workflow Documentation

Task management and documentation synchronization:

| Document | Description |
|----------|-------------|
| [MAINTENANCE.md](MAINTENANCE.md) | TODO management workflow, git-based history model |

## The Four-Document Model

The project uses a Four-Document Model for tracking project state:

1. **[TODO.md](../../specs/TODO.md)** - Active task tracking (active work only)
2. **[implementation-status.md](implementation-status.md)** - Module-by-module completion tracking
3. **[FEATURE_REGISTRY.md](FEATURE_REGISTRY.md)** - Feature tracking and capabilities
4. **[SORRY_REGISTRY.md](SORRY_REGISTRY.md)** - Technical debt tracking

See [MAINTENANCE.md](MAINTENANCE.md) for the complete workflow for updating these documents.

## Quick Reference

### Finding Implementation Status

- **Module completion**: [implementation-status.md](implementation-status.md)
- **Known limitations**: [implementation-status.md#known-limitations](implementation-status.md#known-limitations)
- **Sorry placeholders**: [SORRY_REGISTRY.md](SORRY_REGISTRY.md)

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
