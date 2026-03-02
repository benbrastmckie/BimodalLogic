# Context Knowledge Extraction Template

## Overview

This template guides research agents in evaluating findings for potential context file additions. The goal is to capture **domain-general knowledge** that may benefit future tasks - established mathematical facts, standard definitions, notation conventions, and proven techniques.

## Inclusion Criteria

Knowledge candidates MUST satisfy ALL of the following:

### 1. Domain-General Applicability
- Established mathematical facts (theorems, definitions, lemmas)
- Standard notation conventions used in the field
- Well-known proof techniques or strategies
- General patterns applicable beyond this specific task

### 2. Stability
- Published in peer-reviewed literature or standard references
- Not novel research or speculative conclusions
- Not subject to ongoing revision or debate

### 3. Reusability
- Likely to be useful in multiple future tasks
- Not specific to a single theorem or proof
- Provides foundational knowledge for the domain

## Exclusion Criteria

Do NOT include as candidates:

### Implementation-Specific
- Logos-specific design decisions
- Project-specific conventions or patterns
- Task-specific findings or solutions
- Internal API details

### Novel or Uncertain
- New research findings that need verification
- Speculative approaches or hypotheses
- Techniques invented for this specific task
- Conclusions drawn from limited evidence

### Already Documented
- Knowledge already in existing context files
- Standard textbook material that would be redundant
- Information easily found in primary sources

## Candidate Format

When identifying candidates, format them in the research report appendix as:

```markdown
## Appendix: Context Knowledge Candidates

### Candidate 1: {Brief Title}

**Type**: Definition | Theorem | Lemma | Pattern | Notation | Technique
**Domain**: {e.g., modal-logic, topology, proof-theory}
**Target Context**: {e.g., .claude/context/project/math/modal-logic.md}

**Content**:
{The actual knowledge to be documented}

**Source**: {Citation or reference}

**Rationale**: {Why this is domain-general and reusable}

---

### Candidate 2: {Brief Title}
...
```

## Knowledge Types

### Definition
Standard mathematical definitions that provide foundational vocabulary.

**Example**:
```
**Type**: Definition
**Domain**: modal-logic
**Content**: A Kripke frame F = (W, R) is reflexive if for all w in W, wRw.
**Source**: Hughes & Cresswell, "A New Introduction to Modal Logic"
```

### Theorem
Established results with known proofs.

**Example**:
```
**Type**: Theorem
**Domain**: topology
**Content**: Alexander Subbase Theorem: A space is compact iff every cover
by subbase elements has a finite subcover.
**Source**: Munkres, "Topology" (2nd ed.), Theorem 26.7
```

### Lemma
Supporting results frequently used in proofs.

**Example**:
```
**Type**: Lemma
**Domain**: proof-theory
**Content**: Truth Lemma: In a canonical model, a formula is true at a
maximal consistent set iff the formula is a member of that set.
**Source**: Blackburn et al., "Modal Logic", Lemma 4.20
```

### Pattern
Recurring proof patterns or construction techniques.

**Example**:
```
**Type**: Pattern
**Domain**: modal-logic
**Content**: Canonical Model Construction - To prove completeness, construct
a model where worlds are maximal consistent sets and the accessibility
relation is defined by: wRv iff {B : Box B in w} subset v.
**Source**: Standard technique, see Blackburn et al.
```

### Notation
Standard notation conventions in the field.

**Example**:
```
**Type**: Notation
**Domain**: modal-logic
**Content**: Box (necessity), Diamond (possibility), Turnstile (semantic entailment)
**Source**: Standard modal logic notation
```

### Technique
General proof techniques or methods.

**Example**:
```
**Type**: Technique
**Domain**: topology
**Content**: Point-finite refinement technique: Given an open cover,
construct a refinement where each point is in only finitely many sets.
**Source**: Engelking, "General Topology"
```

## Usage Instructions

### During Research

1. As you gather findings, note any domain-general knowledge
2. Apply inclusion/exclusion criteria to filter candidates
3. Format qualifying candidates in the appendix section

### In Research Report

1. Include the "Context Knowledge Candidates" appendix if candidates exist
2. Leave the appendix empty or omit it if no candidates qualify
3. Be conservative - only include clearly domain-general knowledge

### In Metadata

Include candidate count in metadata:
```json
{
  "context_candidates_count": 2
}
```

This enables the postflight task-creation prompt to appear only when candidates exist.

## Context File Targets

Common context file locations for different domains:

| Domain | Target Path |
|--------|-------------|
| Modal Logic | `.claude/context/project/logic/domain/` |
| Topology | `.claude/context/project/math/topology.md` |
| Proof Theory | `.claude/context/project/logic/techniques/` |
| Lean 4 Tactics | `.claude/context/project/lean4/patterns/` |
| Category Theory | `.claude/context/project/math/category-theory.md` |

## Quality Checklist

Before finalizing candidates:

- [ ] Is this truly domain-general (not task-specific)?
- [ ] Is this established knowledge (not novel research)?
- [ ] Would this benefit future tasks in this domain?
- [ ] Is this not already in existing context files?
- [ ] Is the source reliable and citable?
- [ ] Is the formatting complete and correct?

## Notes

- Err on the side of exclusion - quality over quantity
- Context files are for agent consumption, not user documentation
- The task creation step allows user review before any files are modified
- Multiple candidates can target the same context file
