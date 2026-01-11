# Architecture Decision Records

[Back to Documentation](../README.md)

Architectural Decision Records (ADRs) documenting significant design decisions for the Logos
project. ADRs capture the context, decision, and consequences of architectural choices.

**Audience**: Architects, maintainers, contributors understanding design rationale

## What are ADRs?

Architecture Decision Records document:
- **Context**: What problem or situation prompted the decision
- **Decision**: What was decided and why
- **Consequences**: What are the implications of this decision

ADRs provide a historical record of key architectural choices, helping future contributors
understand why the system is designed the way it is.

## ADR Catalog

| ADR | Title | Status |
|-----|-------|--------|
| [ADR-001](ADR-001-Classical-Logic-Noncomputable.md) | Classical Logic for Metalogic | Accepted |
| [ADR-004](ADR-004-Remove-Project-Level-State-Files.md) | Remove Project-Level State Files | Accepted |

**Note**: ADR-002 and ADR-003 are reserved for future decisions or were superseded.

## ADR Details

### ADR-001: Classical Logic for Metalogic

Establishes the use of Classical logic (including `noncomputable` definitions and
`Classical.choice`) for metalogic proofs in the Logos system. This enables:
- Proof by contradiction
- Law of excluded middle
- Classical existence proofs

### ADR-004: Remove Project-Level State Files

Documents the decision to remove project-level state tracking files in favor of centralized
management through the `.claude/specs/` directory structure.

## Creating New ADRs

When a significant architectural decision is made:

1. **Assign next ADR number** (check existing ADRs to avoid conflicts)
2. **Create file**: `ADR-{NNN}-{Title-With-Hyphens}.md`
3. **Follow template** with sections: Context, Decision, Consequences
4. **Update this README** with new entry in the catalog

## Related Documentation

- [Module Organization](../development/MODULE_ORGANIZATION.md) - Directory structure patterns
- [LEAN Style Guide](../development/LEAN_STYLE_GUIDE.md) - Coding conventions
- [Noncomputable Guide](../development/NONCOMPUTABLE_GUIDE.md) - Details on ADR-001 implementation

---

[Back to Documentation](../README.md)
