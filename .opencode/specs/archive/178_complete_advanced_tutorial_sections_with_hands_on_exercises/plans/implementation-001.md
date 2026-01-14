# Implementation Plan: Task #178

**Task**: Complete Bimodal advanced tutorial with exercises
**Version**: 001
**Created**: 2026-01-11
**Language**: markdown

## Revision Summary

This plan replaces the original task 178 scope (which targeted the general `docs/UserGuide/TUTORIAL.md`) with a redesigned scope for the `Bimodal/` theory.

### Previous Scope (Obsolete)
- Targeted general `docs/UserGuide/TUTORIAL.md`
- Referenced deprecated dependency on Task 172
- Files now live in `Bimodal/docs/`

### New Scope (Current)
The `Bimodal/docs/UserGuide/` already has:
- `QUICKSTART.md` - Basic getting started guide
- `PROOF_PATTERNS.md` - 10 common proof patterns
- `README.md` - User guide overview

This plan creates the **advanced content**:
1. Advanced tutorial covering proof search tactics and metalogic
2. Hands-on exercises with solutions
3. Comprehensive troubleshooting guide

## Overview

Create three complementary documents in `Bimodal/docs/UserGuide/`:
- **ADVANCED_TUTORIAL.md**: Deep dive into proof automation and metalogic
- **EXERCISES.md**: Graded exercises from beginner to advanced with solutions
- **TROUBLESHOOTING.md**: Common errors and their fixes

## Phases

### Phase 1: Advanced Tutorial - Proof Search Automation

**Status**: [NOT STARTED]
**Estimated effort**: 3 hours

**Objectives**:
1. Document the `modal_search` and `temporal_search` tactics
2. Explain heuristic weights and configuration
3. Show when to use each search strategy

**Files to create/modify**:
- `Bimodal/docs/UserGuide/ADVANCED_TUTORIAL.md` (new)

**Content sections**:

```markdown
# Advanced Bimodal Tutorial

## Part 1: Proof Search Automation

### The modal_search Tactic
- Basic usage: `modal_search`, `modal_search 5`, `modal_search (depth := 10)`
- Search strategies: IDDFS (default) vs BoundedDFS
- When to use modal_search vs manual proof

### The temporal_search Tactic
- Optimized for temporal formulas
- Configuration options: `temporal_search (depth := 20)`

### Search Configuration
- Named parameters: depth, visitLimit, axiomWeight, etc.
- Tuning heuristics for complex proofs
- Performance characteristics

### Examples
- Proving modal axioms automatically
- Proving temporal axioms
- Mixed bimodal proofs
```

**Verification**:
- All code examples compile
- Examples demonstrate increasing complexity

---

### Phase 2: Advanced Tutorial - Custom Tactic Development

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Explain how to create Bimodal-specific tactics
2. Document the tactic factory pattern used in Tactics.lean
3. Show integration with Aesop rules

**Content sections**:

```markdown
## Part 2: Custom Tactic Development

### Understanding DerivationTree Goals
- Goal structure: `DerivationTree Γ φ`
- Extracting context and formula

### Creating Simple Tactics
- Macro-based tactics (apply_axiom, modal_t)
- Elaboration-based tactics (modal_4_tactic)
- Using mkAppM for proof construction

### The Tactic Factory Pattern
- mkOperatorKTactic for operator-specific tactics
- Reducing code duplication

### Aesop Integration
- @[aesop safe apply] rules
- @[aesop safe forward] rules
- When to use Aesop vs modal_search

### Examples
- Creating a custom axiom tactic
- Adding new forward rules
```

**Verification**:
- Tactic examples reference existing code in Tactics.lean
- Patterns match actual implementation

---

### Phase 3: Advanced Tutorial - Metalogic

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Explain soundness and what it guarantees
2. Overview of completeness framework (even if incomplete)
3. Understanding the deduction theorem

**Content sections**:

```markdown
## Part 3: Metalogic

### Soundness
- What soundness means: derivable → valid
- TaskFrame and TaskModel semantics
- Key soundness lemmas

### The Deduction Theorem
- Statement and significance
- How it enables proof transformations
- Using generalized_modal_k and generalized_temporal_k

### Completeness (Framework)
- Canonical model construction
- Lindenbaum's lemma
- Current implementation status

### Semantic Evaluation
- Evaluating formulas in models
- Valid vs satisfiable formulas
- Using semantics for counterexamples
```

**Verification**:
- References correct module names (Bimodal.Metalogic.Soundness, etc.)
- Accurately describes implementation status

---

### Phase 4: Exercises with Solutions

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Objectives**:
1. Create graded exercises (beginner to advanced)
2. Include solutions with explanations
3. Cover modal, temporal, and bimodal proofs

**Files to create**:
- `Bimodal/docs/UserGuide/EXERCISES.md` (new)

**Content structure**:

```markdown
# Bimodal Exercises

## Beginner Exercises

### Exercise 1: Direct Axiom Application
Prove: `⊢ □p → p`
*Hint: Use modal_t or modal_search*

<details><summary>Solution</summary>
[Solution with explanation]
</details>

### Exercise 2: Simple Modus Ponens
...

## Intermediate Exercises

### Exercise 5: Chained Implications
...

### Exercise 6: Modal K Application
...

## Advanced Exercises

### Exercise 10: Custom Proof Strategy
...

### Exercise 11: Bimodal Interaction
...

## Challenge Exercises

### Exercise 15: Prove Without modal_search
Implement a proof of □□p → □p manually...
```

**Verification**:
- All solutions compile
- Difficulty progression is reasonable
- Mix of tactic-based and manual proofs

---

### Phase 5: Troubleshooting Guide

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Document common Bimodal errors
2. Provide clear fixes for each
3. Include diagnostic tips

**Files to create**:
- `Bimodal/docs/UserGuide/TROUBLESHOOTING.md` (new)

**Content structure**:

```markdown
# Troubleshooting Bimodal Proofs

## Error Categories

### Import Errors
- "unknown identifier 'Formula'"
- "unknown namespace 'Bimodal'"

### Type Errors
- "type mismatch" in goals
- "application type mismatch"

### Proof Errors
- "unsolved goals"
- "no axiom matched" from modal_search
- "depth exceeded" messages

### Build Errors
- Lake configuration issues
- Mathlib dependency problems

## Diagnostic Tools

### Using lean_goal
### Using lean_diagnostic_messages
### VS Code Goal View

## Common Fixes

### Fix 1: Wrong Imports
### Fix 2: Missing Opens
### Fix 3: Type Annotation Needed
...
```

**Verification**:
- Errors match actual Lean 4 error messages
- Fixes are accurate and tested

---

## Dependencies

- Phase 1-3 can be developed in parallel (same file, different sections)
- Phase 4 depends on understanding from Phases 1-3
- Phase 5 is independent

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Code examples become outdated | Medium | Reference existing examples where possible |
| Exercises too difficult | Low | Test with fresh perspective; provide hints |
| Missing common errors | Low | Mine existing Examples/ for actual errors |

## Success Criteria

- [ ] ADVANCED_TUTORIAL.md covers proof automation, custom tactics, and metalogic
- [ ] All code examples in tutorial compile without errors
- [ ] EXERCISES.md has 15+ exercises with solutions across difficulty levels
- [ ] TROUBLESHOOTING.md covers at least 10 common error scenarios
- [ ] Navigation links connect all documents in UserGuide/
- [ ] Project builds without errors after all phases
