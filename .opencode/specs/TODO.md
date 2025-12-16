# TODO - LEAN 4 ProofChecker

## High Priority

### System Configuration Issues
- [x] Fix invalid frontmatter in specialist subagents (mode: specialist → mode: subagent)

### Core Development
- [ ] Review current repository state and identify gaps
- [ ] Research Kripke semantics for bimodal logic
- [ ] Implement proof system axioms (K axioms, dual axioms)
- [ ] Define bimodal Kripke model structure

## Medium Priority

### Proof Development
- [ ] Create implementation plan for soundness proof
- [ ] Refactor existing modal logic proofs for readability
- [ ] Document bimodal logic proof system
- [ ] Set up CI/CD for automated proof verification

### System Enhancement - Specialist Subagents (14 agents)
- [ ] Create syntax-checker specialist (validates LEAN 4 syntax correctness)
- [ ] Create tactic-advisor specialist (recommends tactics for proof goals)
- [ ] Create library-navigator specialist (finds relevant mathlib functions)
- [ ] Create performance-optimizer specialist (optimizes proof performance)
- [ ] Create error-diagnostics specialist (analyzes and explains LEAN errors)
- [ ] Create dependency-analyzer specialist (maps proof dependencies)
- [ ] Create test-generator specialist (generates test cases for theorems)
- [ ] Create example-builder specialist (creates illustrative examples)
- [ ] Create documentation-formatter specialist (formats documentation)
- [ ] Create git-workflow-manager specialist (manages git operations)
- [ ] Create code-reviewer specialist (reviews code quality)
- [ ] Create refactoring-assistant specialist (suggests refactorings)
- [ ] Create learning-path-generator specialist (creates learning paths)
- [ ] Create concept-explainer specialist (explains complex concepts)

### System Enhancement - Context Files
- [ ] Research and populate context/logic/processes/ directory
- [ ] Research and populate context/logic/standards/ directory
- [ ] Research and populate context/logic/templates/ directory
- [ ] Research and populate context/logic/patterns/ directory
- [ ] Research and populate context/math/analysis/ directory (real analysis, complex analysis, functional analysis)
- [ ] Research and populate context/math/category-theory/ directory (categories, functors, natural transformations)
- [ ] Research and populate context/math/linear-algebra/ directory (vector spaces, linear maps, matrices)

## Low Priority

- [ ] Explore decidability procedures for bimodal logic
- [ ] Research alternative proof strategies
- [ ] Investigate metaprogramming for custom tactics

## Completed

- [x] Set up .opencode system for LEAN 4 ProofChecker
- [x] Create orchestrator and primary agents
- [x] Configure context files for lean4 and logic domains

---

## Usage

To add tasks from this list to projects:
```bash
/plan "Task description from above"
```

To update this file after review:
```bash
/review
```

To mark tasks complete, check the box and move to Completed section.
