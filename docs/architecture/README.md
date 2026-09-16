# Architecture Decision Records

[Back to Documentation](../README.md)

Architectural Decision Records (ADRs) documenting significant design decisions for the
ProofChecker project. ADRs capture the context, decision, and consequences of architectural choices.

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
| [ADR-005](ADR-005-Single-Boneyard.md) | One Archive, Excluded by Directory Name | Accepted |
| [ADR-006](ADR-006-Metalogic-No-Physical-Regroup.md) | No Physical Regroup of the Three Completeness Routes | Accepted |
| [ADR-007](ADR-007-Decidability-One-Directional.md) | Decidability Is One-Directional, and Says So | Accepted |
| [ADR-008](ADR-008-FrameClass-Validity-Seam.md) | `FrameClass.Sat` Lives in `Semantics/`, and the Seam Stays There | Accepted |
| [ADR-009](ADR-009-Boneyard-Retention.md) | The Archive Ships, and Says Why | Accepted |

**Note**: ADR-002 and ADR-003 are reserved for future decisions or were superseded.

**This directory is the one ADR convention in the repository.** There is no `docs/decisions/`;
a second location for the same genre would recreate exactly the duplicate-authority problem ADRs
exist to remove. See `docs/README.md`'s "Durable Records Placement" for the full rule on what
belongs here versus in `docs/reference/`.

## Specification and Decision Documents

Non-ADR architectural specification and decision-record documents:

| Document | Description |
|----------|-------------|
| [BFMCS_architecture.md](BFMCS_ARCHITECTURE.md) | Base Finite Canonical Model Construction (BFMCS) proof architecture specification |
| [total-history-validity-decisions.md](total-history-validity-decisions.md) | Decision record for the total-history validity refactor (Omega-free semantics core): four settled decisions on `H_F`, quantifier domains, and the frame-alignment axioms |
| [untl-snce-argument-order.md](untl-snce-argument-order.md) | Decision record for the `untl`/`snce` guard-first argument order: the escalation, the retracted original reasoning, and the resolving migration |

## ADR Details

### ADR-001: Classical Logic for Metalogic

Establishes the use of Classical logic (including `noncomputable` definitions and
`Classical.choice`) for metalogic proofs in the Bimodal library. This enables:
- Proof by contradiction
- Law of excluded middle
- Classical existence proofs

### ADR-004: Remove Project-Level State Files

Documents the decision to remove project-level state tracking files in favor of centralized
management through the `specs/` directory structure.

### ADR-005: One Archive, Excluded by Directory Name

Records why archived code lives in exactly one tree and why every traversal filters on the
`Boneyard` directory **name** rather than a path prefix. B0 asserts the count is 1.

### ADR-006: No Physical Regroup of the Three Completeness Routes

Records the measurement that declined nesting the three completeness routes: the single
directory-level cycle `BXCanonical` <-> `WeakCanonical`, enumerated edge-by-edge, plus the
partial-move risk. `scripts/check-metalogic-cycles.sh` regenerates the enumeration.

### ADR-007: Decidability Is One-Directional, and Says So

Records why `validity_decidable` and `validity_has_decision_procedure` were retired as vacuous,
what actually holds (the sound direction), what is open (the completeness direction), and why no
`isValid`-shaped biconditional may be written before it can be proved.

### ADR-008: `FrameClass.Sat` Lives in `Semantics/`, and the Seam Stays There

Records the one `Semantics -> ProofSystem` import edge, the acyclicity argument that makes it
safe, and the two relocations that were considered and rejected on cost.

### ADR-009: The Archive Ships, and Says Why

Records the decision to keep `FormalSystem/Boneyard/` rather than split or cut it: why cutting is
unavailable (96 citing files outside the archive, including the published LaTeX), why splitting
buys ~2% of the archive's lines at the cost of ADR-005's single-archive invariant, and the four
obligations keeping it carries.

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
