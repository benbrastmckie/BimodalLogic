# Sorry Debt Policy

## Overview

This file formalizes the project's approach to `sorry` statements in Lean 4 proofs. Sorries represent incomplete proofs and must be managed systematically.

**Cross-references**:
- Lean proof conventions: `project/lean4/standards/proof-conventions-lean.md`
- Sorry registry: `docs/project-info/SORRY_REGISTRY.md`
- Boneyard documentation: `Theories/Bimodal/Boneyard/README.md`

## Philosophy

Sorries are **mathematical debt**, fundamentally different from technical debt:
- Each `sorry` is an **unverified mathematical claim** that may be false
- Sorries propagate: using a lemma with `sorry` inherits that sorry
- **Never acceptable in publication-ready proofs**

### Transitive Sorry Inheritance

Sorries propagate through the dependency graph. If theorem A uses lemma B which contains `sorry`, then:
- A is **also unproven** (mathematically)
- A **inherits** B's mathematical debt
- Any claim about A must acknowledge B's sorry

**Transitively sorry-free** means: the theorem AND all its transitive dependencies contain no sorries. This is the ONLY valid state for publication.

```lean
-- Check transitive sorry-freedom with:
#check @MyTheorem  -- Hover shows axioms used; sorry appears as axiom
```

**Publication requirement**: All theorems claimed as proven must be transitively sorry-free. NO EXCEPTIONS.

**Reporting requirement**: When a sorry exists anywhere in the dependency chain, reports and plans must:
1. Identify all sorries (direct and inherited)
2. Document why each exists
3. Specify the remediation path
4. Note impact on dependent theorems

## Characterizing Sorries in Reports and Plans

When documenting sorries in research reports, implementation plans, or summaries, follow this framing:

**Guiding Principle**: Document what exists, explain WHY it exists, specify the remediation path - never call a sorry acceptable.

### Required Elements

1. **State the fact**: "This file contains N sorries"
2. **Categorize each**: Which category from the taxonomy below
3. **Explain the reason**: Why does this sorry exist
4. **Specify remediation**: What would remove it (even if not planned)
5. **Note transitivity**: What depends on this sorry

### Prohibited Framing

Do NOT use these phrases:
- "acceptable sorry" / "sorry is acceptable"
- "acceptable limitation"
- "sorry is fine" / "okay to have sorry"
- "sorry count is acceptable"
- "<N sorries acceptable"

### Required Framing

USE these phrases instead:
- "tolerated during development"
- "technical debt requiring documentation"
- "blocks publication if not resolved"
- "inherited by all dependents"

### Example Transformations

| Prohibited | Required |
|------------|----------|
| "1 sorry is acceptable" | "1 sorry remains (construction assumption) - documented, blocks transitive sorry-freedom" |
| "sorry state acceptable for publication" | "publication requires resolving all N sorries or documenting as explicit axioms" |
| "<5 acceptable" | "target: 0 sorries; current: N sorries (categorized in SORRY_REGISTRY.md)" |
| "acceptable architectural limitation" | "documented architectural debt - remediation path: [specific approach]" |

### Transitive Inheritance in Reports

ALL sorries propagate transitively through imports. When reporting on a theorem:

1. **Direct sorries**: Sorries in the theorem's proof
2. **Inherited sorries**: Sorries in any lemma the theorem uses
3. **Publication status**: "Transitively sorry-free" or "Depends on N sorries in [files]"

**Critical**: A theorem claimed as "proven" in a publication MUST be transitively sorry-free.

## Sorry Categories

### 1. Construction Assumptions (Tolerated During Development - Technical Debt)
Treated as axiomatic within the current architecture. **This is still mathematical debt that must be documented and tracked.** Example:
```lean
-- Theories/Bimodal/Metalogic/Bundle/Construction.lean
-- In the single-family simplification, we accept this as axiomatic
sorry  -- modal_backward direction
```

### 2. Development Placeholders (Must Resolve)
Temporary gaps with clear resolution paths. Track in `SORRY_REGISTRY.md`.

### 3. Documentation Examples (Excluded from Counts)
Intentional sorries in `Examples/` or demonstration code. Not counted in metrics.

### 4. Fundamental Obstacles (Boneyard Candidates)
Approaches that cannot work. Must archive to Boneyard with documentation. Example: `IsLocallyConsistent` only captures soundness, not negation-completeness.

## Remediation Paths

### Path A: Proof Completion
Fill the gap with valid proof. Preferred when mathematically feasible.

**When to use**: The sorry marks a genuine proof gap, not an architectural issue.

### Path B: Architectural Refactoring
Change approach to avoid the gap entirely.

**When to use**: The sorry reveals a flawed proof strategy. Example: Task 473 replaced syntactic world states with semantic approach, bypassing negation-completeness issues.

### Path C: Boneyard Archival
Archive fundamentally flawed code with documentation.

**When to use**:
- Multiple sorry attempts have failed
- The approach is mathematically impossible
- Preserving the learning is valuable

**Requirements**: Document in Boneyard README why the approach failed.

## Discovery Protocol

When encountering a `sorry` during implementation:

1. **Check SORRY_REGISTRY.md** for existing context
2. **Assess category**: Is this a construction assumption, placeholder, or obstacle?
3. **Check transitive impact**: Does your work depend on this sorry?
4. **Decision tree**:
   - Construction assumption: Document reliance and continue
   - Fixable placeholder: Include fix if in scope, or create task
   - Fundamental obstacle: Flag for Boneyard archival
5. **Update registry** if you add or resolve any sorry

## Boneyard References

### Primary: `Theories/Bimodal/Boneyard/`
Contains deprecated completeness approaches with comprehensive README documenting:
- Why each approach was deprecated
- Key insights from failed attempts
- Related task numbers for traceability

### Overflow: `Boneyard/`
Root-level location for larger deprecated codebases.

### README Requirements
Every Boneyard addition must include:
- **What it contains**: Files and their purpose
- **Why deprecated**: Fundamental reason (not just "has sorries")
- **Key insight**: What was learned
- **Related tasks**: For traceability

## Metrics Integration

### sorry_count Computation
Repository health uses this pattern (excludes Boneyard and Examples):
```bash
grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l
```

**Note**: Metrics count direct sorries only, not transitive inheritance.

### Status Thresholds
| Count | Status | Action |
|-------|--------|--------|
| <100 | good | Maintenance mode |
| 100-299 | manageable | Active reduction |
| >=300 | concerning | Prioritize resolution |

## Usage Checklist

- [ ] No new `sorry` added without SORRY_REGISTRY.md entry
- [ ] Construction assumptions documented in code comments
- [ ] Transitive dependencies checked for critical proofs
- [ ] Fundamental obstacles archived to Boneyard with README
- [ ] Metrics reflect only active development sorries
