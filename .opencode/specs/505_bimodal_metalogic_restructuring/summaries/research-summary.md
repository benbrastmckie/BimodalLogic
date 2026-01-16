# Research Summary: Bimodal Metalogic Restructuring

Research into the existing bimodal metalogic implementation reveals a dependency inversion where Representation depends on Completeness. The proposed ideal structure places **Representation Theory** (Canonical Model construction) as the foundational module.

**Key Findings:**
- **Current State**: `RepresentationTheorems` imports `Completeness`.
- **Proposed Structure**: `Representation` (Canonical Model) -> `Completeness`, `Compactness`, `Decidability`.
- **Conventions**: Use `Type` for worlds (Subtype of MCS), `Structure` for Models, and separate Finite Model Property (Filtration) for Decidability.

**Next Steps**: Refactor `Completeness.lean` to extract the Canonical Model construction into a dedicated `Representation` module.
