# Research Report: Task 859 - Establish Axiom Debt Policy

- **Task**: 859 - establish_axiom_debt_policy
- **Started**: 2026-02-04T10:00:00Z
- **Completed**: 2026-02-04T10:30:00Z
- **Effort**: 1 hour
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Current sorry debt policy
  - `.claude/context/core/formats/plan-format.md` - Plan format with Sorry Characterization
  - `.claude/context/core/formats/report-format.md` - Report format with Sorry Characterization
  - `docs/project-info/SORRY_REGISTRY.md` - Registry tracking both sorries and axioms
  - `specs/857_add_temporal_backward_properties/reports/research-002.md` - Example of axiom framing in practice
  - `specs/state.json` - Repository health tracking axiom_count
- **Artifacts**: specs/859_establish_axiom_debt_policy/reports/research-001.md
- **Standards**: report-format.md, artifact-management.md, tasks.md

## Executive Summary

- Current sorry-debt-policy.md (187 lines) provides comprehensive framing for sorries as mathematical debt
- Axioms are already tracked in the codebase (axiom_count in state.json, SORRY_REGISTRY.md) but lack policy documentation
- Task 857 research demonstrates practical axiom framing: "Axioms are not an acceptable solution"
- Axioms share fundamental characteristics with sorries: both represent unverified mathematical claims that propagate transitively
- Key difference: axioms are explicit declarations while sorries are implicit gaps; both require remediation

## Context & Scope

This research analyzes the existing sorry-debt-policy structure and related format files to propose an expansion covering axioms as a parallel form of mathematical debt. The goal is to:

1. Identify the structure and framing patterns in sorry-debt-policy.md
2. Understand how Sorry Characterization sections work in plan-format.md and report-format.md
3. Propose parallel Axiom Characterization sections with appropriate framing rules
4. Document the unified concept of "proof debt" (sorries + axioms)

## Findings

### 1. Sorry-Debt-Policy Structure Analysis

The current sorry-debt-policy.md contains these sections:

| Section | Lines | Purpose |
|---------|-------|---------|
| Overview | 1-10 | Cross-references and scope |
| Philosophy | 12-39 | Core framing: "mathematical debt", transitive inheritance |
| Characterizing Sorries in Reports | 41-88 | Required elements, prohibited phrases, required phrases, example transformations |
| Sorry Categories | 90-109 | Taxonomy of 4 categories with examples |
| Remediation Paths | 111-131 | 3 paths: completion, refactoring, boneyard |
| Discovery Protocol | 133-144 | Decision tree for encountered sorries |
| Boneyard References | 146-162 | Archive documentation requirements |
| Metrics Integration | 164-179 | Count computation, status thresholds |
| Usage Checklist | 181-186 | Final checklist for compliance |

### 2. Sorry Characterization in Format Files

**plan-format.md (lines 85-133)**:
- Section header: "## Sorry Characterization (Lean plans only)"
- Applicability: Lean implementation plans only
- Required elements: Pre-existing Sorries, Expected Resolution, New Sorries, Remaining Debt
- Framing rules: Explicit NEVER/ALWAYS phrase lists

**report-format.md (lines 39-85)**:
- Section header: "## Sorry Characterization (Lean reports only)"
- Applicability: Lean research reports only
- Required elements: Current State, Transitive Impact, Remediation Path, Publication Blockers
- Same framing rules as plan-format.md

### 3. Axiom Tracking in Current Codebase

Axioms are already tracked in multiple locations:

| Location | Field | Current Value | Description |
|----------|-------|---------------|-------------|
| specs/state.json | repository_health.axiom_count | 18 | Total `axiom` declarations in Theories/ |
| specs/TODO.md | technical_debt.axiom_count | 18 | Mirrored for user visibility |
| SORRY_REGISTRY.md | Per-module axiom counts | Varies | Detailed breakdown with line numbers |

SORRY_REGISTRY.md already documents axioms alongside sorries:
- "Total Axiom Declarations: 7 (5 in Completeness.lean for canonical model construction, 2 in Examples)"
- Lists specific axiom names and line numbers
- Categorizes axioms by module

### 4. Axiom Characteristics (Parallel to Sorries)

Axioms share fundamental properties with sorries:

| Property | Sorry | Axiom |
|----------|-------|-------|
| Unverified claim | Implicit (proof gap) | Explicit (declared assumption) |
| Transitive propagation | Yes - inherits sorry status | Yes - inherits axiom dependency |
| Publication blocking | Yes - must resolve | Yes - must disclose or resolve |
| Mathematical debt | Yes | Yes |
| Remediation required | Yes | Yes |

Key differences:
- **Visibility**: Axioms are explicit declarations; sorries are implicit gaps
- **Intent**: Axioms are sometimes intentional design choices; sorries are always temporary
- **Disclosure**: Axioms can be published with disclosure; sorries cannot be published

### 5. Practical Axiom Framing (from Task 857)

Task 857 research report demonstrates axiom framing in practice:

**Prohibited framing** (implied):
- "Axiom-based approach" (as acceptable solution)
- "Add axiom to solve this problem"

**Required framing** (explicit in report):
- "Axioms are not an acceptable solution"
- "Axioms are never the appropriate strategy - we must find structural proofs"
- "The existence of [axiom] is technical debt that should be eliminated"
- "Zero axioms" as the target state

### 6. Axiom Categories (Proposed Taxonomy)

Based on codebase analysis, axioms fall into these categories:

| Category | Description | Remediation | Example |
|----------|-------------|-------------|---------|
| Construction Assumptions | Required by current architecture | Complete saturated construction | `singleFamily_modal_backward_axiom` |
| Existence Assumptions | Assert existence without proof | Lindenbaum extension proofs | `someWorldState_exists` |
| Documentation Examples | Intentional in Examples/ | Excluded from counts | Examples/ModalLogic.lean |
| Fundamental Obstacles | Cannot be proven structurally | Archive to Boneyard with documentation | (rare) |

### 7. Proposed Unified Terminology

To unify sorries and axioms under one concept:

| Term | Definition |
|------|------------|
| **Proof Debt** | Umbrella term for unverified mathematical claims (sorries + axioms) |
| **Sorry** | Implicit proof gap marked with `sorry` tactic |
| **Axiom** | Explicit unproven assumption declared with `axiom` keyword |
| **Transitive Freedom** | No proof debt (direct or inherited) in dependency chain |
| **Publication Ready** | Transitively free of both sorries and axioms (or axioms disclosed) |

### 8. Proposed Axiom Framing Rules

**Prohibited Phrases for Axioms**:
- "acceptable axiom" / "axiom is acceptable"
- "axiom-based solution"
- "add axiom to solve"
- "axiom count is acceptable"
- "N acceptable axioms"
- "temporary axiom" (axioms are declarations, not temporary by nature)

**Required Phrases for Axioms**:
- "axiom as technical debt"
- "axiom requires structural proof"
- "eliminates need for axiom"
- "zero-axiom approach"
- "axiom to be removed via [specific approach]"
- "inherits axiom dependency"
- "publication requires axiom disclosure or elimination"

**Example Transformations**:

| Prohibited | Required |
|------------|----------|
| "1 axiom is acceptable" | "1 axiom remains (construction assumption) - documented, requires structural proof" |
| "add axiom to solve this" | "this gap reveals need for completed saturation construction" |
| "acceptable axiom count" | "target: 0 axioms; current: N axioms (categorized in proof-debt-policy.md)" |
| "axiom-based approach" | "structural proof approach (eliminates axiom dependency)" |

### 9. Proposed Axiom Characterization Section Structure

For **plan-format.md**:

```markdown
## Axiom Characterization (Lean plans only)

### Pre-existing Axioms
- N axioms in scope that this implementation addresses
- List each with location and purpose

### Expected Resolution
- Which axioms will be eliminated and how
- Structural proof approach that removes axiom need

### New Axioms
- NEVER introduce new axioms
- If unavoidable, justify and document remediation timeline

### Remaining Debt
- Axioms that will remain after implementation
- Downstream dependents that inherit axiom status
```

For **report-format.md**:

```markdown
## Axiom Characterization (Lean reports only)

### Current State
- Count and location of axioms in scope
- Purpose of each axiom

### Transitive Impact
- Which theorems/lemmas inherit axiom dependency
- Publication implications

### Remediation Path
- Structural proof approach to eliminate each axiom
- Estimated effort and prerequisites

### Publication Status
- Zero-axiom status required for undisclosed publication
- Or explicit disclosure required if axioms remain
```

## Decisions

1. **Rename file**: `sorry-debt-policy.md` -> `proof-debt-policy.md` to reflect unified coverage
2. **Preserve sorry content**: All existing sorry documentation remains intact
3. **Add parallel axiom content**: Mirror structure for axioms with appropriate modifications
4. **Update format files**: Add "Axiom Characterization" sections parallel to "Sorry Characterization"
5. **Unified philosophy**: Both sorries and axioms are "mathematical debt" requiring remediation

## Recommendations

### 1. File Renaming and Expansion (proof-debt-policy.md)

Rename `sorry-debt-policy.md` to `proof-debt-policy.md` and expand with:

- New "Overview" covering both sorries and axioms
- New "Philosophy" section with unified "proof debt" concept
- Preserved "Characterizing Sorries" section (unchanged)
- New "Characterizing Axioms" section (parallel structure)
- Preserved "Sorry Categories" section
- New "Axiom Categories" section (parallel structure)
- Preserved "Remediation Paths" section (applies to both)
- Updated "Discovery Protocol" covering both
- Updated "Metrics Integration" covering both metrics
- Updated "Usage Checklist" covering both

### 2. Update plan-format.md

After the existing "Sorry Characterization" section, add:

```markdown
## Axiom Characterization (Lean plans only)

**Applicability**: Include this section only for Lean implementation plans that involve axiom dependencies.

**Purpose**: Documents how the implementation handles axioms - both pre-existing ones being resolved and any impact on axiom dependencies.

**Required Elements**:
- **Pre-existing Axioms**: Axioms in scope that this implementation addresses
- **Expected Resolution**: Which axioms will be eliminated and how
- **New Axioms**: NEVER introduce new axioms (if unavoidable, justify with remediation timeline)
- **Remaining Debt**: Axioms that will remain after implementation

**Framing Rules**:

NEVER use these phrases:
- "acceptable axiom"
- "axiom-based solution"
- "add axiom to solve"
- "N acceptable axioms"

ALWAYS use these phrases:
- "axiom as technical debt"
- "structural proof eliminates axiom"
- "inherits axiom dependency"
- "zero-axiom target"
```

### 3. Update report-format.md

After the existing "Sorry Characterization" section, add parallel "Axiom Characterization" section following the same pattern.

### 4. Cross-Reference Updates

Update existing cross-references:
- CLAUDE.md reference to sorry-debt-policy.md -> proof-debt-policy.md
- SORRY_REGISTRY.md to note proof-debt-policy.md as governing policy
- Any other references to sorry-debt-policy.md

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Renaming breaks existing references | Medium | Search-replace all references before implementation |
| New axiom sections increase cognitive load | Low | Keep parallel structure to leverage familiarity |
| Confusion between sorry and axiom rules | Medium | Clear section separation, consistent terminology |
| Over-constraining axiom usage | Low | Acknowledge legitimate disclosure path for publication |

## Appendix

### Files to Modify

1. `.claude/context/project/lean4/standards/sorry-debt-policy.md` - Rename to `proof-debt-policy.md` and expand
2. `.claude/context/core/formats/plan-format.md` - Add Axiom Characterization section
3. `.claude/context/core/formats/report-format.md` - Add Axiom Characterization section

### Search Terms Used

- `axiom` in .claude/ directory
- `axiom_count` in specs/ directory
- Review of SORRY_REGISTRY.md for axiom tracking patterns
- Review of Task 857 research for practical axiom framing

### Reference Materials

- sorry-debt-policy.md: Lines 1-187 (full file)
- plan-format.md: Lines 85-133 (Sorry Characterization section)
- report-format.md: Lines 39-85 (Sorry Characterization section)
- SORRY_REGISTRY.md: Lines 1-192 (full file, especially axiom sections)
- Task 857 research-002.md: Practical axiom framing examples
