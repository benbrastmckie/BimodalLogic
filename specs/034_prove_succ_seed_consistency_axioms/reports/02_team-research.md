# Research Report: Task #34 - predecessor_f_step_axiom Blocker Analysis

**Task**: Prove SuccExistence seed consistency axioms
**Date**: 2026-03-23
**Mode**: Team Research (3 teammates)
**Focus**: Mathematical analysis of predecessor_f_step_axiom blocker

## Summary

Three independent research agents unanimously conclude that `predecessor_f_step_axiom` is **not provable** from the current proof infrastructure. The fundamental gap is an asymmetry between universal (G/H) and existential (F/P) temporal operators: the h/g duality theorems use axioms `temp_a` (φ → G(P(φ))) and `past_temp_a` (φ → H(F(φ))) to transfer G/H-content between MCSes, but no analogous axioms exist for F/P-content. Lindenbaum extension, being purely syntactic, can introduce arbitrary F-formulas via negation completeness without respecting the intended frame structure.

The axiom is semantically valid in discrete linear reflexive frames and is load-bearing for the completeness proof (required by `predecessor_succ` → `backward_chain_pred` → `SuccChainFMCS` → truth lemma).

## Key Findings

### 1. Provability Analysis (Teammate A) — Confidence: HIGH

**The fundamental asymmetry**:

| Duality | Transfer | Axiom Used | Status |
|---------|----------|------------|--------|
| g→h | g_content(u) ⊆ v ⟹ h_content(v) ⊆ u | φ → G(P(φ)) | **Proven** |
| h→g | h_content(u) ⊆ v ⟹ g_content(v) ⊆ u | φ → H(F(φ)) | **Proven** |
| f→p | f_content(u) ⊆ v ⟹ p_content(v) ⊆ u | None exists | **No axiom** |
| p→f | p_content(u) ⊆ v ⟹ f_content(v) ⊆ u | None exists | **No axiom** |

**Why no f/p duality is possible**: Existential operators (F, P) are witnesses, not constraints. The axioms `temp_a` and `past_temp_a` work because they involve universal operators (G, H) which provide leverage for subset proofs. No standard temporal logic axiom has the form `F(φ) → ?` that would constrain existential content.

**Four proof strategies attempted**, all failing at the same gap:
1. f/g duality: Knowing G(¬φ) ∉ v tells us nothing about u
2. Contrapositive: Cannot derive G-membership from raw membership (T-axiom goes wrong direction)
3. Via past_temp_a: F(¬φ) ∈ v doesn't block F(φ) ∈ v (MCS can contain both)
4. Seriality chain: Doesn't constrain F-content

**The minimal closing lemma would be the axiom itself** — no smaller lemma suffices.

### 2. Alternative Constructions (Teammate B) — Confidence: MEDIUM-HIGH

Five alternatives analyzed with precise definitions:

| Alternative | Correctness | Effort | Risk | Key Trade-off |
|-------------|-------------|--------|------|---------------|
| **1. Constrained seed** | High | Medium | Medium | Add G(¬φ) to seed for unwanted F(φ); complex consistency proof |
| **2. Step-by-step (Segerberg)** | Very High | Very High | Low | Standard literature approach; requires major refactor |
| **3B. Eventual F-resolution** | Medium | Low | Medium | Bypass local F-step via nesting boundary |
| **4. Dual seed design** | High | Medium | Medium | Symmetric seeds; similar complexity to Alt 1 |
| **5. Accept as axiom** | N/A | None | Low | Semantic argument is sound |

**Most promising: Alternative 3B (Eventual F-resolution)**

The truth lemma may not need local F-step at every predecessor. Instead, F-witnesses only need to *eventually resolve* somewhere in the chain, which is already guaranteed by `f_nesting_boundary` and `p_nesting_boundary`. If verified, this would make `predecessor_f_step_axiom` **superseded** by existing nesting boundary infrastructure.

**Literature support**: Goldblatt (1992) and Verbrugge et al. use stage-by-stage construction (Alternative 2) for discrete tense logic completeness. Standard texts (Blackburn, de Rijke, Venema 2001) implicitly assume F-content constraints without explicit proof.

### 3. Semantic Necessity (Teammate C) — Confidence: HIGH

**The axiom IS required for the completeness proof.** Dependency chain:

```
predecessor_f_step_axiom
  → predecessor_succ (establishes Succ(predecessor, u))
    → backward_chain_pred (backward chain construction)
      → succ_chain_fam_succ (Succ for negative indices)
        → SuccChainFMCS (complete temporal structure)
          → truth lemma (F/P cases for negative indices)
```

**No viable weaker form found**: Subformula restriction is insufficient for full completeness. Derivability-from-seed reformulation reduces to the same gap.

**Semantically true**: In discrete linear frames where v is the immediate predecessor of u, any F-witness at v must be at u (→ φ ∈ u) or beyond u (→ F(φ) ∈ u). This is a consequence of discreteness + linearity.

## Synthesis

### Conflicts Resolved

**Conflict 1: Accept vs. Bypass**
- Teammates A and C recommend accepting the axiom with documentation
- Teammate B suggests Alternative 3B might bypass the need entirely
- **Resolution**: Alternative 3B is the most mathematically interesting path forward. If the truth lemma can be refactored to use nesting boundary instead of local F-step, the axiom becomes genuinely unnecessary. This should be investigated before accepting the axiom as permanent.

**Conflict 2: Effort assessment**
- All agree current infrastructure cannot prove it
- Disagreement on whether constrained construction is worth the effort
- **Resolution**: Effort should go to verifying Alternative 3B first (low effort, high reward). Only invest in constrained construction if 3B fails.

### Gaps Identified

1. **Alternative 3B verification needed**: Nobody verified whether the truth lemma's F-case can actually use `f_nesting_boundary` instead of local F-step. This is the critical open question.

2. **Symmetric axiom for successor**: Task 40 identifies a symmetric `successor_p_step_axiom` with identical analysis. Any solution should address both.

3. **Interaction with task 42 (architectural redesign)**: Task 42 tracks axiom elimination broadly. The decision here should align with that task's strategy.

### Recommendations (Priority Order)

1. **Investigate Alternative 3B** (Eventual F-resolution via nesting boundary):
   - Check if `SuccChainTruth.lean` truth lemma F-case can be restructured
   - The key question: does the F-case need `f_content(v) ⊆ u ∪ f_content(u)` at every adjacent pair, or can it use `f_nesting_boundary` to find the witness anywhere in the chain?
   - If YES: predecessor_f_step_axiom is superseded; delete it
   - Estimated effort: 2-4 hours to verify

2. **If 3B fails, accept as axiom** with enhanced documentation:
   - The semantic argument is mathematically sound
   - The syntactic gap is well-understood (h/g vs f/p asymmetry)
   - This is consistent with standard literature practice
   - Mark task as [COMPLETED] with 2/3 axioms eliminated + 1 justified

3. **Long-term: Constrained Lindenbaum** (only if axiom-freedom becomes a hard requirement):
   - Follow Segerberg/Verbrugge stage-by-stage approach
   - Major refactor, but standard technique in the literature
   - Would resolve both predecessor_f_step and successor_p_step simultaneously

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Provability analysis | completed | high | Systematic proof of unprovability; identified exact gap |
| B | Alternative constructions | completed | medium-high | 5 alternatives with literature survey; identified Alt 3B |
| C | Semantic necessity | completed | high | Dependency chain analysis; no weaker form sufficient |

## References

- Blackburn, de Rijke, Venema (2001). *Modal Logic*. Cambridge University Press.
- Goldblatt (1992). *Logics of Time and Computation*. CSLI Publications.
- Verbrugge et al. *Completeness by construction for tense logics of linear time*.
- Stanford Encyclopedia of Philosophy: Temporal Logic.
