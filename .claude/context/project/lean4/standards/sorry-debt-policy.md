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

A proof is only as sound as its dependencies. If theorem A uses lemma B which contains `sorry`, then A is also unproven.

**Truly sorry-free** means: the theorem AND all its transitive dependencies contain no sorries.

```lean
-- Check transitive sorry-freedom with:
#check @MyTheorem  -- Hover shows axioms used; sorry appears as axiom
```

**Publication requirement**: All theorems claimed as proven must be transitively sorry-free.

## Sorry Categories

### 1. Construction Assumptions (Acceptable for Development)
Accepted as axiomatic within the current architecture. Example:
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
