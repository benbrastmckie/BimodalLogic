# Temporal Logic Automation in LEAN 4: Research Report

**Date:** December 21, 2025  
**Topic:** Temporal Logic Automation, Modal Logic, Decision Procedures, and Proof Automation in LEAN 4  
**Researcher:** Web Research Specialist

## Executive Summary

This report presents findings on temporal logic automation in LEAN 4 and related theorem proving systems. The research reveals a growing but still nascent ecosystem for temporal and modal logic automation in LEAN 4, with several promising frameworks and tools that could be adapted for bimodal TM logic systems.

**Key Findings:**
- **LeanLTL** is the most mature LEAN 4 framework for linear temporal logic
- **Aesop** provides powerful white-box automation that can be customized for modal/temporal logics
- Limited native LEAN 4 support for CTL and decision procedures
- Strong theoretical foundations exist but practical automation tools are still developing
- Several modal logic formalizations exist but lack comprehensive automation

---

## 1. Linear Temporal Logic (LTL) Frameworks

### 1.1 LeanLTL (UCSC Formal Methods)

**Source:** https://github.com/UCSCFormalMethods/LeanLTL  
**Paper:** arXiv:2507.01780 (ITP 2025)

**Description:**  
A unifying framework for linear temporal logics in LEAN 4 that supports both infinite and finite traces.

**Capabilities:**
- Combines traditional LTL syntax with arbitrary LEAN expressions
- Supports reasoning about infinite and finite linear time
- Provides automation for LeanLTL formulas
- Facilitates using LEAN's existing tactics
- Embeddings for standard LTL and LTLf (finite traces)

**Key Features:**
- Core library under `LeanLTL/Trace`, `LeanLTL/TraceFun`, `LeanLTL/TraceSet`
- Automation and utilities in `LeanLTL/Tactics` and `LeanLTL/Utils`
- Examples: traffic lights, induction proofs, temporal properties
- Logical embeddings for LTL and LTLf

**LEAN 4 Compatible:** ✅ Yes (native LEAN 4)

**Relevance Score:** 9/10  
*Highly relevant - provides a solid foundation for temporal reasoning that could be extended to bimodal systems*

**Adaptation Potential:**
- Could serve as base for temporal component of bimodal TM logic
- Automation tactics could be extended for task-modal combinations
- Trace-based semantics align well with task execution models

---

### 1.2 LeanearTemporalLogic (mrigankpawagi)

**Source:** https://github.com/mrigankpawagi/LeanearTemporalLogic

**Description:**  
Formalization of Linear Temporal Logic in LEAN 4 with focus on model checking and transition systems.

**Capabilities:**
- LTL syntax with basic and derived operators
- Transition systems and execution fragments
- Path fragments and traces
- Satisfaction relations for LTL formulas
- LT properties and safety/liveness decomposition

**Key Components:**
- **LTL Module:** Syntax for temporal operators (next, until, eventually, always)
- **TransitionSystems:** States, actions, transitions, execution fragments
- **Satisfaction:** World-based semantics, formula equivalence
- **LT Properties:** Safety, liveness, invariants

**Theorems Proven:**
- Duality laws (eventually/always, until/weakuntil)
- Expansion laws for temporal operators
- Decomposition of properties into safety and liveness
- Trace inclusion and equivalence results

**LEAN 4 Compatible:** ✅ Yes

**Relevance Score:** 8/10  
*Very relevant - comprehensive LTL formalization with model checking focus*

**Adaptation Potential:**
- Transition system model could represent task execution
- Safety/liveness decomposition useful for task properties
- Satisfaction relations could be extended to bimodal case

---

## 2. Modal Logic Frameworks

### 2.1 Modal Logic Repositories (GitHub Search Results)

Several LEAN 4 modal logic projects were identified:

#### 2.1.1 m4lvin/tablean (Lean 3, archived)
- Tableau for basic modal logic
- **Note:** Lean 3 only, not maintained
- Successor project: https://github.com/m4lvin/lean4-pdl

#### 2.1.2 SnO2WMaN/lean4-modallogic (archived)
- Formalization of modal logic in LEAN 4
- Includes incompleteness results
- **Status:** Archived, last updated March 2024

#### 2.1.3 FormalizedFormalLogic/LabelledSystem
**Source:** https://github.com/FormalizedFormalLogic/LabelledSystem

**Description:**  
Label-based calculi for modal logic in LEAN 4.

**Topics:** logic, modal-logic, sequent-calculus, lean4

**Relevance Score:** 7/10  
*Relevant for proof-theoretic approaches to modal logic*

#### 2.1.4 James-Oswald/first-order-modal-logic
- First-order modal logic textbook exercises
- Educational focus

#### 2.1.5 splch/lean4ufpl
- Typed, multi-modal logic for philosophy
- Philosophical applications

**LEAN 4 Compatible:** Mixed (some archived, some active)

**Relevance Score:** 6/10  
*Useful for understanding modal logic formalization patterns, but limited automation*

---

## 3. Proof Automation Frameworks

### 3.1 Aesop (Automated Extensible Search for Obvious Proofs)

**Source:** https://github.com/leanprover-community/aesop  
**Documentation:** Comprehensive README with examples

**Description:**  
White-box automation for LEAN 4, broadly similar to Isabelle's `auto` tactic.

**Type:** Tactic framework / Proof search automation

**Capabilities:**
- Customizable rule sets with `@[aesop]` attribute
- Best-first search with configurable priorities
- Safe and unsafe rules with backtracking
- Normalisation rules (including `simp_all`)
- Built-in rules for logical connectives
- Proof script generation with `aesop?`
- Indexing for performance with large rule sets

**Rule Types:**
1. **Normalisation rules:** Applied in fixpoint loop, must generate 0-1 subgoals
2. **Safe rules:** Applied eagerly, never backtracked
3. **Unsafe rules:** Can backtrack, have success probabilities (0-100%)

**Rule Builders:**
- `apply`: Apply lemmas/theorems
- `forward`: Forward reasoning from hypotheses
- `destruct`: Eliminate hypotheses
- `constructors`: Try all constructors
- `cases`: Case analysis on inductive types
- `simp`: Simplification rules
- `unfold`: Definition unfolding
- `tactic`: Custom tactics

**Use Cases:**
1. General-purpose automation (powerful `simp`)
2. Special-purpose automation (domain-specific rule sets)
3. Mathlib tactics: `measurability`, `continuity`

**LEAN 4 Compatible:** ✅ Yes (native LEAN 4)

**Relevance Score:** 10/10  
*Extremely relevant - provides the automation infrastructure needed for bimodal TM logic*

**Adaptation Potential:**
- Create custom rule sets for TM logic axioms
- Define safe rules for modal/temporal necessitation
- Implement unsafe rules for complex modal reasoning
- Use normalisation for simplifying bimodal formulas
- Build domain-specific tactics for task reasoning

**Example Application:**
```lean
-- Register TM logic rules
@[aesop safe apply]
theorem task_necessitation : ⊢ φ → ⊢ □ₜ φ

@[aesop unsafe 80% apply]
theorem temporal_induction : (φ ∧ ◯φ) → □φ

-- Use in proofs
example : task_property := by aesop
```

---

### 3.2 Mathlib4 Logic Infrastructure

**Source:** https://leanprover-community.github.io/mathlib4_docs/

**Description:**  
LEAN 4's mathematics library with extensive logic foundations.

**Relevant Components:**
- Propositional logic
- First-order logic
- Type theory foundations
- Automated tactics (`simp`, `ring`, `omega`, etc.)

**LEAN 4 Compatible:** ✅ Yes

**Relevance Score:** 8/10  
*Essential foundation, but lacks specific temporal/modal automation*

---

## 4. Decision Procedures and Automation

### 4.1 Current State

**Findings:**
- No native LTL/CTL decision procedures in LEAN 4
- No automated tableau or resolution procedures for temporal logic
- Limited model checking automation
- Most work focuses on formalization, not automation

### 4.2 Related Work from Literature

#### 4.2.1 ScenicProver (arXiv:2511.02164)
**Paper:** "ScenicProver: A Framework for Compositional Probabilistic Verification"

**Description:**  
Framework for verifying learning-enabled cyber-physical systems using LTL extended with Scenic expressions.

**Key Features:**
- Compositional system description
- Assume-guarantee contracts using extended LTL
- Evidence generation through testing and formal proofs
- **LEAN 4 integration** for formal proofs
- Automatic assurance case generation

**Relevance:** Demonstrates LEAN 4 integration for temporal verification

#### 4.2.2 Mechanized Uniform Interpolation (arXiv:2402.10494)
**Paper:** "Mechanised uniform interpolation for modal logics K, GL, and iSL"

**Tool:** Coq proof assistant

**Description:**  
Mechanized computation of propositional quantifiers for modal logics.

**Relevance:** Shows proof assistant approaches to modal logic automation

#### 4.2.3 Lax Modal Lambda Calculi (arXiv:2512.10779)
**Paper:** "Lax Modal Lambda Calculi" (CSL 2026)

**Tool:** Agda proof assistant

**Description:**  
Typed lambda calculi for intuitionistic modal logics with diamonds.

**Relevance:** Demonstrates modal type theory formalization

---

## 5. Proof Assistant Comparisons

### 5.1 Modal Logic in Other Proof Assistants

#### Coq
- Mechanized modal logic semantics
- Uniform interpolation procedures
- Kripke model formalizations

#### Agda
- Modal type theory
- Normalization proofs
- Synthetic Tait computability

#### Isabelle/HOL
- Leo-III: Higher-order modal logic prover
- Extensional paramodulation
- TPTP integration

#### HOL Light
- HOLMS library for modal systems
- Adequacy theorems for K, T, K4, GL
- Automated decision procedures

**Key Insight:** Other proof assistants have more mature modal logic automation, but LEAN 4's metaprogramming capabilities offer unique opportunities.

---

## 6. Gaps and Opportunities

### 6.1 Current Gaps

1. **No native CTL formalization** in LEAN 4
2. **Limited decision procedures** for temporal logics
3. **No automated tableau methods** for modal/temporal logic
4. **Sparse automation** for complex modal reasoning
5. **No integrated model checkers** in LEAN 4

### 6.2 Opportunities for Bimodal TM Logic

1. **Leverage LeanLTL** for temporal component
2. **Extend Aesop** with TM-specific rules
3. **Develop custom tactics** for bimodal reasoning
4. **Create decision procedures** for TM fragments
5. **Build on modal logic formalizations** for task modality
6. **Integrate with existing automation** (simp, omega, etc.)

---

## 7. Recommendations for ProofChecker

### 7.1 Immediate Actions

1. **Study LeanLTL architecture**
   - Understand trace-based semantics
   - Examine automation tactics
   - Identify extension points

2. **Experiment with Aesop**
   - Create simple TM logic rule sets
   - Test safe/unsafe rule combinations
   - Develop normalisation strategies

3. **Review modal logic patterns**
   - Study FormalizedFormalLogic/LabelledSystem
   - Examine Kripke model formalizations
   - Understand necessitation rules

### 7.2 Medium-Term Goals

1. **Develop TM Logic Automation**
   - Custom Aesop rule sets for task modality
   - Temporal reasoning tactics
   - Bimodal formula simplification

2. **Create Decision Procedures**
   - Tableau method for TM logic fragments
   - Model checking for finite task models
   - Satisfiability checking

3. **Build Integration Layer**
   - Connect temporal and modal components
   - Unified syntax for bimodal formulas
   - Proof search coordination

### 7.3 Long-Term Vision

1. **Comprehensive TM Logic Library**
   - Complete formalization of bimodal semantics
   - Automated proof search
   - Verified decision procedures

2. **Tool Integration**
   - External model checkers
   - SMT solver integration
   - Proof certificate generation

3. **Application Domains**
   - Task planning verification
   - Workflow correctness
   - Temporal constraint checking

---

## 8. Detailed Findings Summary

### 8.1 Tools and Libraries

| Name | Type | LEAN 4 | Capabilities | Relevance |
|------|------|--------|--------------|-----------|
| LeanLTL | Framework | ✅ | LTL formalization, automation, traces | 9/10 |
| LeanearTemporalLogic | Framework | ✅ | LTL, transition systems, model checking | 8/10 |
| Aesop | Tactic | ✅ | White-box automation, customizable rules | 10/10 |
| Mathlib4 | Library | ✅ | Logic foundations, basic tactics | 8/10 |
| FormalizedFormalLogic | Framework | ✅ | Modal logic, sequent calculus | 7/10 |
| SnO2WMaN/lean4-modallogic | Framework | ✅ | Modal logic formalization | 6/10 |

### 8.2 Research Papers

| Title | Year | Relevance | Key Contribution |
|-------|------|-----------|------------------|
| LeanLTL: A unifying framework | 2025 | High | LEAN 4 LTL framework with automation |
| ScenicProver | 2025 | Medium | LEAN 4 integration for verification |
| Mechanised uniform interpolation | 2024 | Medium | Modal logic automation in Coq |
| Lax Modal Lambda Calculi | 2025 | Medium | Modal type theory in Agda |
| Semantical Analysis of IML | 2024 | Low | Intuitionistic modal logic in Coq |

---

## 9. Technical Insights

### 9.1 Automation Strategies

**From Aesop:**
- Use safe rules for deterministic reasoning (e.g., modal necessitation)
- Use unsafe rules with probabilities for heuristic search
- Normalisation for formula simplification
- Indexing for performance with large rule sets

**From LeanLTL:**
- Trace-based semantics for temporal reasoning
- Integration with LEAN's tactic system
- Combining domain-specific and general automation

**From Modal Logic Work:**
- Kripke semantics for possible worlds
- Accessibility relations for modalities
- Frame conditions for axiom systems

### 9.2 Formalization Patterns

**Syntax:**
```lean
inductive Formula (AP : Type) where
  | atom : AP → Formula AP
  | neg : Formula AP → Formula AP
  | and : Formula AP → Formula AP → Formula AP
  | box : Formula AP → Formula AP  -- Modal necessity
  | next : Formula AP → Formula AP  -- Temporal next
```

**Semantics:**
```lean
def satisfies (M : Model) (w : World) (φ : Formula) : Prop :=
  match φ with
  | atom p => p ∈ M.valuation w
  | neg ψ => ¬(satisfies M w ψ)
  | and ψ₁ ψ₂ => satisfies M w ψ₁ ∧ satisfies M w ψ₂
  | box ψ => ∀ w', M.accessible w w' → satisfies M w' ψ
  | next ψ => satisfies M (M.successor w) ψ
```

**Automation:**
```lean
@[aesop safe apply]
theorem necessitation : ⊢ φ → ⊢ □φ

@[aesop norm simp]
theorem box_and : □(φ ∧ ψ) ↔ □φ ∧ □ψ

@[aesop unsafe 70% apply]
theorem temporal_induction : (φ ∧ ◯φ) → ◯◯φ
```

---

## 10. Conclusion

The LEAN 4 ecosystem for temporal and modal logic automation is developing rapidly but remains incomplete. The most promising approach for bimodal TM logic automation combines:

1. **LeanLTL** for temporal reasoning infrastructure
2. **Aesop** for customizable proof automation
3. **Custom tactics** for bimodal-specific reasoning
4. **Mathlib4** for foundational logic support

The lack of native CTL and comprehensive decision procedures represents both a challenge and an opportunity. Building these tools for TM logic would contribute to the LEAN 4 ecosystem while serving the ProofChecker project's needs.

**Next Steps:**
1. Prototype TM logic formalization using LeanLTL patterns
2. Develop initial Aesop rule sets for common TM reasoning
3. Create proof-of-concept automation for simple TM theorems
4. Evaluate performance and identify optimization opportunities

---

## References

### Primary Sources
1. LeanLTL GitHub: https://github.com/UCSCFormalMethods/LeanLTL
2. LeanLTL Paper: arXiv:2507.01780
3. LeanearTemporalLogic: https://github.com/mrigankpawagi/LeanearTemporalLogic
4. Aesop: https://github.com/leanprover-community/aesop
5. Mathlib4: https://github.com/leanprover-community/mathlib4

### Secondary Sources
6. ScenicProver: arXiv:2511.02164
7. Mechanised Uniform Interpolation: arXiv:2402.10494
8. Lax Modal Lambda Calculi: arXiv:2512.10779
9. FormalizedFormalLogic: https://github.com/FormalizedFormalLogic/LabelledSystem
10. LEAN 4 Documentation: https://lean-lang.org/lean4/doc/

### Additional Resources
11. Theorem Proving in Lean 4: https://leanprover.github.io/theorem_proving_in_lean4/
12. Principles of Model Checking (Baier & Katoen)
13. Modal Logic (Blackburn, de Rijke, Venema)
14. Temporal Logic (Emerson)

---

**Report Generated:** December 21, 2025  
**Research Specialist:** Web Research Specialist  
**Project:** ProofChecker - Bimodal TM Logic Automation
