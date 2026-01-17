# Research Report: Task #437

**Task**: Improve README consistency with recursive-semantics.md
**Date**: 2026-01-12
**Focus**: Compare README.md with recursive-semantics.md for consistency, identify discrepancies, clarify layer terminology, assess redundancy, and recommend ModelChecker integration points

## Summary

The README.md (336 lines) and recursive-semantics.md (591 lines) present the Logos framework with some inconsistencies in terminology and layer structure. Key issues include: (1) README uses "Layers" while recursive-semantics.md uses "Extensions", (2) README lists 6 layers while recursive-semantics.md describes 6 extensions with different names, (3) "Causal Layer" vs "Explanatory Extension" terminology mismatch, (4) README lacks clear dependency structure shown in recursive-semantics.md, and (5) ModelChecker integration is mentioned but could be more prominent. The documents are largely compatible but need alignment for consistency.

## Findings

### 1. Terminology Comparison: Layers vs Extensions

| README.md (Line 88-96) | recursive-semantics.md | Notes |
|------------------------|------------------------|-------|
| **Constitutive** | **Constitutive Foundation** | Same concept, different naming |
| **Causal** | **Explanatory Extension** | MAJOR MISMATCH - Different names |
| **Epistemic** | **Epistemic Extension** | Same |
| **Normative** | **Normative Extension** | Same |
| **Spatial** | **Spatial Extension** | Same |
| **Agential** | **Agential Extension** | Same |

**Key Discrepancy**: The README uses "Causal Layer" (line 91) while recursive-semantics.md uses "Explanatory Extension" (line 228). The recursive-semantics.md terminology is more accurate because the Explanatory Extension includes modal, temporal, counterfactual, AND causal operators - not just causal.

### 2. Operator Assignment Inconsistencies

**README.md (lines 88-96)**:
```markdown
| Layer              | Operators                                        | Status         |
| **Constitutive**   | Extensional, constitutive                        | Complete (MVP) |
| **Causal**         | Modal, temporal, counterfactual, causal          | Complete (MVP) |
| **Epistemic**      | Belief, probability, indicative                  | Planned        |
| **Normative**      | Deontic, preferential                            | Planned        |
| **Spatial**        | Spatial relations, locations                     | Planned        |
| **Agential**       | Agency, action, intention                        | Planned        |
```

**recursive-semantics.md (lines 54-59)**:
```markdown
1. **Constitutive Foundation**: Hyperintensional semantics over a mereological state space
2. **Explanatory Extension**: Hyperintensional and intensional semantics over a task space
3. **Epistemic Extension**: Extensions for belief, knowledge, and probability [DETAILS]
4. **Normative Extension**: Extensions for obligation, permission, and value [DETAILS]
5. **Spatial Extension**: Extensions for spatial reasoning [DETAILS]
6. **Agential Extension**: Extensions for multi-agent reasoning [DETAILS]
```

**Inconsistencies Identified**:
1. README says "Causal" - should say "Explanatory" or "Causal/Explanatory"
2. README omits "knowledge" from Epistemic operators (recursive-semantics.md line 56 includes it)
3. README's "Constitutive" description ("Extensional, constitutive") doesn't match recursive-semantics.md's richer description including "Hyperintensional semantics over a mereological state space"

### 3. Extension Dependency Structure

The recursive-semantics.md (lines 17-52) provides a clear dependency diagram:

```
┌─────────────────────────────────────────────────┐
│           Constitutive Foundation               │
│         (hyperintensional base layer)           │
└───────────────────────┬─────────────────────────┘
                        │ required
                        ▼
┌─────────────────────────────────────────────────┐
│              Explanatory Extension              │
│    (modal, temporal, counterfactual, causal)    │
└───────────────────────┬─────────────────────────┘
                        │
       ┌────────────────┼────────────────┐
       │ optional       │ optional       │ optional
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Epistemic   │ │  Normative   │ │   Spatial    │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       └────────────────┼────────────────┘
                        │ at least one required
                        ▼
┌─────────────────────────────────────────────────┐
│             Agential Extension                  │
└─────────────────────────────────────────────────┘
```

**README Lacks**: This dependency structure is not represented in README.md. The README presents layers as a flat list without showing:
- Constitutive Foundation and Explanatory Extension are REQUIRED
- Epistemic, Normative, Spatial are OPTIONAL and can be combined
- Agential requires at least one middle extension

### 4. Overview Section Comparison

**README.md (lines 30-41)**:
- Lists four "layers": Constitutive, Causal, Epistemic, Normative
- Doesn't mention Spatial or Agential layers in the Overview
- Description is concise but misses the hyperintensional foundation

**recursive-semantics.md Introduction (lines 10-62)**:
- Lists six extensions with clear dependency
- Explains hyperintensional vs intensional distinction
- Provides semantic frame progression

**Discrepancy**: README's Overview only mentions 4 layers, but the Layered Architecture table (line 88-96) lists 6. The recursive-semantics.md consistently refers to 6 extensions.

### 5. Constitutive Layer Description

**README.md (lines 101-106)**:
```markdown
The Constitutive Layer provides fundamental descriptive resources---predicates and
functions for expressing facts, quantifiers for generalizing over individuals,
extensional connectives for truth-functional reasoning, and constitutive operators
for expressing what grounds and explains what.
```

**recursive-semantics.md (lines 65-68)**:
```markdown
The Constitutive Foundation provides the foundational semantic structure based on
exact truthmaker semantics. Evaluation is hyperintensional, distinguishing propositions
that agree on truth-value across all possible worlds but differ in their exact
verification and falsification conditions.
```

**Assessment**: Both are accurate but emphasize different aspects:
- README: Syntactic primitives (predicates, functions, quantifiers)
- recursive-semantics.md: Semantic character (hyperintensional, exact truthmakers)

Both perspectives are valid and complementary.

### 6. Formal Specification Links

**README.md (lines 5-8)** correctly links to:
- recursive-semantics.md (markdown)
- LogosReference.tex/pdf (tex/pdf format)

This is well-formatted per the task 434 recommendations.

### 7. ModelChecker Integration

**Current README mentions** (line 334):
```markdown
- **[Model-Checker](https://github.com/benbrastmckie/ModelChecker)** - Z3-based semantic verification (v1.2.12)
```

**Task description requirement**: "Emphasize the parallel development of Logos in the ModelChecker"

**Findings from ModelChecker GitHub**:
- ModelChecker includes "Logos" as one of its semantic theories
- Uses Z3 SMT solver for model finding and counterexample generation
- License: GPL-3.0 (vs ProofChecker's MIT license)
- Key feature: Hyperintensional truthmaker semantics with 19 operators

**Gap**: The README doesn't adequately explain:
1. ModelChecker implements the same Logos theory in Python/Z3
2. The dual verification architecture (LEAN proofs + Z3 countermodels)
3. This provides BOTH positive training signal (proofs) AND corrective signal (countermodels)

The RL Training section (lines 11-27) mentions this but the connection to ModelChecker could be stronger.

### 8. Redundancy Assessment

Comparing with task 434 research findings, the current README (post-refactor) has improved but still shows some redundancy:

| Topic | Location | Assessment |
|-------|----------|------------|
| Layer descriptions | Overview (30-41) vs Table (88-96) | MINOR REDUNDANCY - different detail levels, acceptable |
| RL Training | Section (11-27) | GOOD - consolidated from previous version |
| Bimodal discussion | Section (272-280) | GOOD - appropriately brief with link |

The task 434 refactor successfully consolidated redundancy. No major redundancy issues remain.

### 9. Internal Discrepancies in README.md

1. **Line 32-37 vs Line 88-96**: Overview mentions 4 layers; table lists 6
2. **Line 91**: "Causal Layer" should be "Explanatory Extension" or at least acknowledge the broader scope
3. **Line 33**: "Constitutive Layer" - technically "Constitutive Foundation" per recursive-semantics.md

### 10. Cross-Reference Validation

**Links in README that point to recursive-semantics.md**:
- Line 6: `[markdown](Theories/Logos/docs/research/recursive-semantics.md)` - CORRECT

**Links to layer-extensions.md**:
- Line 78, 86, 97, 145, 236: `[Layer Extensions](Theories/Logos/docs/research/layer-extensions.md)` - CORRECT

Both documents are properly cross-referenced.

## Recommendations

### 1. Terminology Alignment (High Priority)

Option A: Update README to use "Extension" terminology
- Change "Constitutive Layer" to "Constitutive Foundation"
- Change "Causal Layer" to "Explanatory Extension"
- Update table headers and descriptions accordingly

Option B: Keep "Layer" in README for accessibility, add note
- Add footnote: "Layers are called 'Extensions' in the formal semantic specification"
- Keep "Causal" but clarify it includes modal, temporal, and counterfactual

**Recommendation**: Option A for consistency with the authoritative recursive-semantics.md

### 2. Align Overview with Table (High Priority)

Update lines 32-37 to mention all 6 layers/extensions:
```markdown
- **Constitutive Foundation**: Predicates, functions, lambdas, quantifiers, extensional operators, and constitutive explanatory operators.
- **Explanatory Extension**: Modal, temporal, counterfactual, and causal operators for reasoning about past, future, contingency, and causation.
- **Epistemic Extension**: Epistemic modals, indicative conditionals, probability, and belief operators for reasoning under uncertainty.
- **Normative Extension**: Permission, obligation, preference, and normative explanatory operators for reasoning about values and laws.
- **Spatial Extension**: Spatial relations and locations for reasoning about space.
- **Agential Extension**: Agency, action, intention for multi-agent reasoning.
```

### 3. Add Dependency Structure (Medium Priority)

Include a simplified version of the extension dependency diagram from recursive-semantics.md in the README, perhaps in the "Layered Architecture" section.

### 4. Strengthen ModelChecker Connection (High Priority)

Add or enhance text explaining:
1. ModelChecker implements Logos theory in Python/Z3
2. Dual verification: LEAN proves validity, ModelChecker finds countermodels
3. Together they provide complete RL training signals

Suggested addition to RL Training section:
```markdown
The [ModelChecker](https://github.com/benbrastmckie/ModelChecker) implements the
same Logos semantic theory, providing Z3-based countermodel generation for
invalid inferences. Together, ProofChecker (LEAN) and ModelChecker (Z3) form
a complete dual verification system.
```

### 5. Operator Description Enhancement (Low Priority)

Update the Constitutive description to mention hyperintensionality:
```markdown
The Constitutive Foundation provides hyperintensional semantics distinguishing
propositions by their exact verification and falsification conditions, not just
truth-values. This enables fine-grained reasoning about grounding and essence.
```

### 6. Add Epistemic "Knowledge" Operator (Low Priority)

Update line 92 to include "knowledge":
```markdown
| **Epistemic**   | Belief, knowledge, probability, indicative        | Planned        |
```

## Summary of Discrepancies to Fix

| Issue | Location | Fix |
|-------|----------|-----|
| "Causal Layer" vs "Explanatory Extension" | README line 91 | Change to "Explanatory" or add clarification |
| Overview lists 4 layers, table lists 6 | README lines 32-37 vs 88-96 | Update Overview to 6 |
| Missing "knowledge" in Epistemic operators | README line 92 | Add "knowledge" |
| No dependency structure shown | README Layered Architecture section | Add simplified diagram |
| Weak ModelChecker integration emphasis | Throughout | Strengthen RL Training section |

## References

- `/home/benjamin/Projects/ProofChecker/README.md` - Current README
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md` - Authoritative semantic specification
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/layer-extensions.md` - Extension architecture
- `/home/benjamin/Projects/ProofChecker/specs/434_refactor_readme_for_investors_and_researchers/reports/research-001.md` - Prior refactor research
- `https://github.com/benbrastmckie/ModelChecker` - ModelChecker repository

## Next Steps

1. Create implementation plan with phased approach
2. Phase 1: Terminology alignment (Causal -> Explanatory)
3. Phase 2: Overview/Table consistency (4 layers -> 6)
4. Phase 3: Add dependency structure diagram
5. Phase 4: Strengthen ModelChecker integration text
6. Phase 5: Minor fixes (knowledge operator, hyperintensional description)
