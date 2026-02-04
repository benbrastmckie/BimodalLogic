# Report Artifact Standard

**Scope:** Research, analysis, verification, and review reports produced by /research, /review, /analyze, and related agents.

## Metadata (required)
- **Task**: `{id} - {title}`
- **Started**: `{ISO8601}` when work begins
- **Completed**: `{ISO8601}` when work completes
- **Effort**: `{estimate}`
- **Dependencies**: `{list or None}`
- **Sources/Inputs**: bullet list of inputs consulted
- **Artifacts**: list of produced artifacts (paths)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, this file

**Note**: Status metadata (e.g., `[RESEARCHING]`, `[COMPLETED]`) belongs in TODO.md and state.json only, NOT in research reports. Reports are artifacts that document findings, not workflow state.

## Structure
1. **Project Context (Lean only)** – proof dependency relationships (see below).
2. **Executive Summary** – 4-6 bullets.
3. **Context & Scope** – what is being evaluated, constraints.
4. **Findings** – ordered or bulleted list with evidence; include status markers for subsections if phases are tracked.
5. **Decisions** – explicit decisions made.
6. **Recommendations** – prioritized list with owners/next steps.
7. **Risks & Mitigations** – optional but recommended.
8. **Appendix** – references, data, links.

## Project Context (Lean reports only)

**Applicability**: Include this section only for Lean research reports where understanding proof dependencies is essential. For non-Lean reports (general, meta, latex, typst), this section may be omitted.

**Purpose**: Provides early orientation on how the research topic fits into the Lean codebase by documenting proof dependency relationships.

**Fields**:
- **Upstream Dependencies**: Existing or planned theorems/definitions this result builds upon. Example: "Depends on `Soundness`, `Kripke.eval`, `Formula.subst`"
- **Downstream Dependents**: Existing or planned results that will use this. Example: "Enables `Completeness`, `DecidabilityTheorem`"
- **Alternative Paths**: Where this provides redundancy or different approaches. Example: "Alternative to the algebraic completeness approach in `Theories/Algebraic/`"
- **Potential Extensions**: New directions this enables or suggests. Example: "Could extend to multi-modal logics, temporal operators"

## Sorry Characterization (Lean reports only)

**Applicability**: Include this section only for Lean research reports when documenting sorry occurrences. For non-Lean reports (general, meta, latex, typst), this section should be omitted.

**Purpose**: Documents sorry occurrences with accurate technical characterization. Sorries are technical debt that block publication and propagate to dependents - they require explicit remediation, not acceptance.

**Required Elements**:
- **Current State**: Count and location of sorries in scope
- **Transitive Impact**: Which theorems/lemmas inherit sorry status from these
- **Remediation Path**: How each sorry can be resolved (proof approach, missing lemmas, etc.)
- **Publication Blockers**: Sorries that must be resolved before publication

**Framing Rules**:

NEVER use these phrases (they imply sorries can be permanently acceptable):
- "acceptable sorry"
- "acceptable limitation"
- "sorry is fine"
- "okay to have sorry"
- "N acceptable sorries"

ALWAYS use these phrases (they acknowledge temporary technical debt):
- "tolerated during development"
- "technical debt requiring remediation"
- "blocks publication"
- "inherited by dependents"
- "remediation priority: high/medium/low"

**Example**:
```markdown
## Sorry Characterization

### Current State
- 3 sorries in `Completeness.lean` (lines 42, 78, 156)

### Transitive Impact
- `Main.DecidabilityTheorem` inherits sorry status from `Completeness.completeness`
- All downstream dependents are blocked from publication

### Remediation Path
- Line 42: Requires proof of canonical model construction (see task 450)
- Line 78: Missing lemma for truth preservation, estimated 2 hours
- Line 156: Requires induction strengthening, medium complexity

### Publication Status
These sorries block publication. Remediation priority: high.
```

## Axiom Characterization (Lean reports only)

**Applicability**: Include this section only for Lean research reports when documenting axiom dependencies. For non-Lean reports (general, meta, latex, typst), this section should be omitted.

**Purpose**: Documents axiom dependencies with accurate technical characterization. Axioms are technical debt that require structural proofs - they are never an acceptable permanent solution.

**Required Elements**:
- **Current State**: Count and location of axioms in scope
- **Transitive Impact**: Which theorems/lemmas inherit axiom dependency
- **Remediation Path**: Structural proof approach to eliminate each axiom
- **Publication Status**: Zero-axiom status or explicit disclosure requirement

**Framing Rules**:

NEVER use these phrases (they imply axioms can be permanently acceptable):
- "acceptable axiom"
- "axiom-based solution"
- "add axiom to solve"
- "N acceptable axioms"

ALWAYS use these phrases (they acknowledge technical debt requiring structural proof):
- "axiom as technical debt"
- "axiom requires structural proof"
- "eliminates need for axiom"
- "zero-axiom approach"
- "inherits axiom dependency"
- "publication requires axiom disclosure or elimination"

**Example**:
```markdown
## Axiom Characterization

### Current State
- 1 axiom in `SaturatedConstruction.lean`: `singleFamily_modal_backward_axiom`
- Purpose: Asserts modal backward direction in single-family simplification

### Transitive Impact
- `Completeness.completeness` inherits axiom dependency
- All downstream theorems using completeness require axiom disclosure

### Remediation Path
- Complete saturation construction (Task 856) eliminates axiom
- Structural proof: extend world state family to include backward-reachable worlds
- Estimated effort: 4-6 hours

### Publication Status
This axiom blocks undisclosed publication. Options:
- Eliminate via structural proof (preferred)
- Disclose as explicit assumption in publication
```

## Timestamps
- Include **Started** timestamp when research/analysis begins
- Include **Completed** timestamp when report is finalized
- Do not use emojis
- Do not include status markers (status tracked in TODO.md and state.json only)

## Writing Guidance
- Be objective, cite sources/paths.
- Keep headings at most level 3 inside the report.
- Prefer bullet lists over prose for findings/recommendations.
- Ensure lazy directory creation: create `reports/` only when writing the first report file.

## Example Skeleton
```
# Research Report: {title}
- **Task**: {id} - {title}
- **Started**: 2025-12-22T10:00:00Z
- **Completed**: 2025-12-22T13:00:00Z
- **Effort**: 3 hours
- **Dependencies**: None
- **Sources/Inputs**: ...
- **Artifacts**: ...
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context (Lean only)
- **Upstream Dependencies**: `Soundness`, `Kripke.eval`, `Formula.subst`
- **Downstream Dependents**: `Completeness`, `DecidabilityTheorem`
- **Alternative Paths**: None identified
- **Potential Extensions**: Multi-modal logics, temporal operators

## Executive Summary
- ...

## Context & Scope
...

## Findings
- ...

## Decisions
- ...

## Recommendations
- ...

## Risks & Mitigations
- ...

## Appendix
- References: ...
```
