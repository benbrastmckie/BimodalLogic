# Implementation Plan: Task #455

**Task**: Improve README extension layer descriptions
**Version**: 001
**Created**: 2026-01-13
**Language**: general
**Session**: sess_1768262465_9d2ead

## Overview

Replace the current terse bullet-point descriptions of each extension layer (lines 51-57 of README.md) with clear, concise explanations that articulate:
1. What expressive resources each layer adds (new operators)
2. What semantic machinery supports those operators
3. What types of reasoning become possible
4. How complexity increases through the progressive layers

The tone should remain accessible while conveying technical precision. Each description should be 2-3 sentences, expanding on operators and explaining the reasoning capabilities unlocked.

## Current State (lines 51-57)

```markdown
- **Constitutive Foundation**: Predicates, functions, lambdas, quantifiers, extensional operators, and constitutive explanatory operators.
- **Explanatory Extension**: Modal, temporal, counterfactual, and causal operators for reasoning about past, future, contingency, and causation.
- **Epistemic Extension**: Belief, knowledge, probability, and indicative conditional operators for reasoning under uncertainty.
- **Normative Extension**: Permission, obligation, preference, and normative explanatory operators for reasoning about values and laws.
- **Spatial Extension**: Spatial relations and locations for reasoning about space.
- **Agential Extension**: Agency, action, and intention operators for multi-agent reasoning.
- **Reflection Extension**: Self-modeling and metacognitive operators for first-person reasoning about one's own beliefs, abilities, preferences, and goals.
```

## Phases

### Phase 1: Draft Improved Descriptions

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Write improved descriptions for all 7 layers
2. Balance technical accuracy with accessibility
3. Keep each description to 2-3 sentences
4. Highlight operators with symbols where helpful
5. Connect layers to types of reasoning tasks

**Target Content**:

- **Constitutive Foundation**: Provides the hyperintensional base with predicates, functions, quantifiers, and constitutive operators (propositional identity `=`, grounding `<=`, essence `=>`) over a state lattice with bilateral propositions (verifier/falsifier pairs). This enables fine-grained distinctions between propositions with identical truth-values but different verification conditions---essential for exact specification of what makes a claim true.

- **Explanatory Extension**: Adds modal operators (`[]`, `<>`) for necessity and possibility, temporal operators (`H`, `G`, `P`, `F`) for reasoning across time, counterfactual conditionals (`[]->`, `<>->`) for hypothetical reasoning, and causal operators (`o->`) for explanatory links. Together these resources enable reasoning about action sequences, future contingency, what would have happened under different circumstances, and causal relationships.

- **Epistemic Extension**: Introduces belief (`B`), knowledge (`K`), probability (`Pr`), and indicative conditional (`=>`) operators for reasoning under uncertainty. By extending the temporal framework with credence functions over state transitions, agents can track how evidence updates beliefs across time and distinguish what an agent believes from what is actually the case.

- **Normative Extension**: Adds obligation (`O`), permission (`P`), and preference (`<`) operators with value orderings over states for reasoning about what ought to be done, what is permitted, and how to rank alternatives. This enables ethical reasoning, multi-party preference aggregation, and grounding obligations in factual circumstances.

- **Spatial Extension**: Provides location-dependent operators (`Here`, `Somewhere`, `Everywhere`, `Near`) and spatial relations for reasoning about where things are and how spatial proximity affects truth conditions. This supports navigation, containment reasoning, and location-sensitive planning.

- **Agential Extension**: Indexes epistemic and normative operators to specific agents, enabling reasoning about what different agents believe, prefer, and are obligated to do. This transforms single-perspective reasoning into multi-agent coordination where agents can model each other's epistemic and normative states.

- **Reflection Extension**: Adds first-person metacognitive operators (`I`, `I_K`, `I_Can`) for self-directed reasoning about one's own beliefs, knowledge, abilities, and goal progress. This enables an agent to reason about what it knows versus believes, recognize its own limitations, and track progress toward goals---essential for AI systems that must understand their own capabilities.

**Steps**:
1. Review current bullet points and architecture diagram context
2. Draft improved descriptions following target content above
3. Ensure symbol notation matches conventions elsewhere in README

**Verification**:
- Each description has 2-3 sentences
- Operators are named with symbols
- Semantic resources are mentioned
- Types of reasoning are explained

---

### Phase 2: Update README.md

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace bullet points with improved descriptions
2. Preserve ASCII diagram (unchanged)
3. Preserve concluding paragraph (lines 59-61)

**Files to modify**:
- `README.md` - Replace lines 51-57

**Steps**:
1. Use Edit tool to replace the 7 bullet points
2. Verify formatting renders correctly

**Verification**:
- All 7 layers have updated descriptions
- Markdown formatting is correct
- No broken links or symbols

---

### Phase 3: Verify and Commit

**Estimated effort**: 5 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Review final result in context
2. Git commit changes

**Steps**:
1. Re-read Overview section to verify coherence
2. Stage and commit with task-scoped message

**Verification**:
- README.md renders correctly
- Descriptions flow naturally after diagram
- Commit completes successfully

---

## Dependencies

None - this is a self-contained documentation task.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Descriptions too technical | Low accessibility | Keep to 2-3 sentences, focus on "what reasoning is possible" |
| Symbol notation inconsistent | Confusion | Cross-reference with OPERATORS.md and existing README usage |
| Over-expansion | README bloat | Strict 2-3 sentence limit per layer |

## Success Criteria

- [ ] All 7 layer descriptions updated with expanded content
- [ ] Each description explains operators, semantic resources, and reasoning types
- [ ] Descriptions are 2-3 sentences, not mere lists
- [ ] README.md maintains consistent formatting
- [ ] Git commit completes
