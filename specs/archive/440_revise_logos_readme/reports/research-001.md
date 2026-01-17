# Research Report: Task #440

**Task**: Revise Logos README to reflect current structure and ambitions
**Date**: 2026-01-12
**Focus**: Gap analysis between current README and recursive-semantics.md specification

## Summary

The current Logos README describes an outdated architecture centered on "re-exporting Bimodal TM logic" with layer numbering (Layer 0-4) that does not match the actual implementation. The codebase has evolved to implement the recursive-semantics.md specification with a layered extension architecture (Foundation -> Explanatory -> Epistemic/Normative/Spatial -> Agential). The README needs substantial revision to accurately represent the current system.

## Findings

### 1. Current README Misalignment

The current README (`/home/benjamin/Projects/ProofChecker/Theories/Logos/README.md`) has these issues:

| Issue | Current State | Actual State |
|-------|---------------|--------------|
| **Purpose** | "Re-exports Bimodal TM logic" | Implements independent hyperintensional logic system |
| **Architecture** | Layer 0-4 numbering | Foundation -> Explanatory -> Extensions hierarchy |
| **Directory structure** | Syntax/, ProofSystem/, Semantics/, Metalogic/ | SubTheories/{Foundation,Explanatory,Epistemic,Normative,Spatial}/ |
| **Semantic base** | Task frames with world states | Mereological state space with bilateral propositions |
| **Key concepts** | Not mentioned | Verifiers/falsifiers, task relation, world-histories |

### 2. Actual Implementation Structure

The codebase in `Theories/Logos/SubTheories/` implements:

**Foundation Layer** (Constitutive Foundation):
- `Foundation/Frame.lean` - ConstitutiveFrame with complete lattice state space
- `Foundation/Syntax.lean` - ConstitutiveFormula with atoms, predicates, connectives, identity
- `Foundation/Semantics.lean` - verifies/falsifies mutual recursion
- `Foundation/Proposition.lean` - BilateralProp type
- `Foundation/Interpretation.lean` - Interpretation function I

**Explanatory Layer** (Explanatory Extension):
- `Explanatory/Frame.lean` - CoreFrame with task relation, state modality definitions
- `Explanatory/Syntax.lean` - Formula type with modal/temporal/counterfactual operators
- `Explanatory/Truth.lean` - truthAt evaluation with world-histories

**Future Extensions** (Stubs only):
- `Epistemic/Epistemic.lean` - Belief, knowledge, probability operators (stub)
- `Normative/Normative.lean` - Deontic, preference operators (stub)
- `Spatial/Spatial.lean` - Location operators (stub)

### 3. Key Concepts from recursive-semantics.md

The README should explain these core concepts:

**Hyperintensional Semantics**:
- States (not possible worlds) as semantic primitives
- Bilateral propositions: ordered pairs of verifier/falsifier sets
- Propositional identity (A ≡ B) distinguishes necessarily equivalent propositions

**Mereological Structure**:
- Complete lattice of states with parthood ordering
- Null state (bottom), full state (top), fusion (supremum)
- State modality: possible, impossible, compatible, maximal, world-state

**Task Relation**:
- Ternary relation s ⇒_d t ("task from s to t with duration d")
- Six constraints: nullity, compositionality, parthood (L/R), containment (L/R)
- Temporal order D as totally ordered abelian group

**World-Histories**:
- Functions τ : X → W assigning world-states to convex time subsets
- Task-respecting: τ(x) ⇒_{y-x} τ(y) for x ≤ y

**Operators** (Explanatory Extension):
- Modal: □ (necessity), ◇ (possibility)
- Temporal: H/G (always past/future), P/F (some past/future), Since/Until
- Counterfactual: □→ (would-counterfactual)
- Causal: ○→ (primitive, awaiting Task 394)
- Store/Recall: ↑ⁱ/↓ⁱ for cross-temporal reference

### 4. Implementation Status

| Component | Status | Notes |
|-----------|--------|-------|
| ConstitutiveFrame | Complete | Full lattice structure with lemmas |
| ConstitutiveFormula | Complete | All syntactic primitives |
| verifies/falsifies | Complete | Mutual recursion over formula structure |
| CoreFrame | Complete | Task relation with all constraints |
| WorldHistory | Complete | Convex domains, task-respecting |
| truthAt | Complete | All operators except causal (sorry) |
| Causal operator | Stub | Awaiting Task 394 |
| Epistemic | Stub | Placeholder namespace |
| Normative | Stub | Placeholder namespace |
| Spatial | Stub | Placeholder namespace |

### 5. Proposed README Structure

Based on the analysis, the revised README should include:

1. **About Logos** - Hyperintensional logic for truthmaker semantics
2. **Philosophy** - Brief explanation of hyperintensionality vs intensionality
3. **Architecture** - Extension hierarchy diagram from recursive-semantics.md
4. **Core Concepts** - Bilateral propositions, task relation, world-histories
5. **Implementation Status** - Current state of each extension
6. **Directory Structure** - SubTheories/ organization
7. **Operators Reference** - Table of all operators with readings
8. **Building and Testing** - lake build commands
9. **Related Documentation** - Links to recursive-semantics.md, other docs

## Recommendations

1. **Replace entirely rather than patch** - The current README structure is too different to be revised incrementally

2. **Lead with philosophy** - Explain why hyperintensional semantics matters (distinguishing necessarily equivalent propositions)

3. **Include the extension diagram** - Copy the ASCII diagram from recursive-semantics.md showing Foundation -> Explanatory -> Extensions

4. **Be honest about stubs** - Clearly mark which extensions are implemented vs planned

5. **Reference recursive-semantics.md** - Link to the specification document for detailed semantic clauses

6. **Keep building instructions** - The `lake build` commands are still relevant

7. **Remove obsolete references** - No more references to "re-exporting Bimodal" or Layer 0-4 numbering

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md` - Primary specification
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/` - Implementation source
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/README.md` - Current README (to be replaced)

## Next Steps

Run `/plan 440` to create an implementation plan for the README revision.
