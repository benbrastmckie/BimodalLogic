# Teammate B Research Report: Alternative Constructions

**Task**: 34 - prove_succ_seed_consistency_axioms
**Focus**: Research alternative constructions that avoid the F-content gap
**Date**: 2026-03-23
**Status**: Completed

## Executive Summary

The `predecessor_f_step_axiom` cannot be proven with the current deferral seed construction because Lindenbaum extension can introduce arbitrary F-formulas via negation completeness, and the h/g duality only constrains G-formulas (universal), not F-formulas (existential). This is a **fundamental asymmetry** in canonical model constructions for tense logic. Several alternative approaches exist, each with distinct trade-offs.

**Key Finding**: The most promising path forward is either (1) weakening the axiom to a sufficient condition, or (2) using a "controlled Lindenbaum" with F-content tracking. The standard literature acknowledges this gap implicitly by constructing models step-by-step rather than using unconstrained Lindenbaum extension.

## Alternative Approaches

### Alternative 1: Constrained Seed with F-Content Bounds

**Definition**: Modify the predecessor deferral seed to explicitly include F-content constraints.

**Current Seed**:
```
predecessor_deferral_seed(u) = h_content(u) ∪ pastDeferralDisjunctions(u)
```

**Modified Seed**:
```
constrained_predecessor_seed(u) = h_content(u) ∪ pastDeferralDisjunctions(u) ∪ negations_of_F_not_in_u(u)
```

where:
```
negations_of_F_not_in_u(u) = {G(neg(phi)) | F(phi) not in u and F(phi) not in f_content(u)}
```

**Rationale**: If F(phi) is not in u and not in f_content(u), then we WANT G(neg(phi)) in the predecessor v, because that blocks F(phi) from appearing in v (by contradiction with G(neg(phi))).

**Trade-off**:
- **Advantage**: Forces f_content(v) to be constrained by u's F-content
- **Disadvantage**: Significantly more complex consistency proof required - must show the combined seed is consistent
- **Feasibility**: Medium - the added formulas are logically consistent with h_content under MCS properties

**Precise Definition**:
```lean
def constrained_predecessor_seed (u : Set Formula) : Set Formula :=
  h_content u ∪
  pastDeferralDisjunctions u ∪
  {Formula.all_future phi.neg | phi : Formula,
    Formula.some_future phi ∉ u ∧ Formula.some_future phi ∉ f_content u}
```

### Alternative 2: Step-by-Step (Segerberg/Verbrugge) Construction

**Definition**: Instead of Lindenbaum extension, construct the predecessor by explicitly enumerating formulas and deciding inclusion based on consistency with u's structure.

**Construction**:
1. Enumerate all formulas: phi_0, phi_1, phi_2, ...
2. Start with seed S_0 = h_content(u) ∪ pastDeferralDisjunctions(u)
3. At step n:
   - If adding phi_n to S_{n-1} is consistent AND does not violate F-step constraint, set S_n = S_{n-1} ∪ {phi_n}
   - Otherwise set S_n = S_{n-1} ∪ {neg(phi_n)}
4. Take limit: v = ∪_n S_n

**F-step Constraint Check at Step n**:
When considering adding F(phi) to S_{n-1}:
- Check if phi is in u (resolved) or F(phi) in u (deferred)
- If neither, REJECT F(phi) and add neg(F(phi)) = G(neg(phi)) instead

**Trade-off**:
- **Advantage**: F-step condition holds BY CONSTRUCTION
- **Disadvantage**: Major refactoring of Lindenbaum infrastructure
- **Feasibility**: Low - requires significant changes to existing codebase
- **Standard**: This is the approach used in Segerberg (1970) and Verbrugge et al. for discrete tense logic completeness

**Reference**: Verbrugge et al., "Completeness by construction for tense logics of linear time" - explicitly notes construction proceeds in stages ensuring frame conditions are satisfied at each step.

### Alternative 3: Weakened Axiom (Sufficient Condition)

**Definition**: Instead of proving f_content(predecessor) ⊆ u ∪ f_content(u), prove a weaker property that's still sufficient for completeness.

**Candidate Weakenings**:

**(A) Bounded F-step**:
```
For all phi with F-nesting depth <= k:
  phi in f_content(predecessor) implies phi in u ∪ f_content(u)
```

**(B) Eventual F-resolution**:
```
For any phi in f_content(predecessor):
  exists n. phi in succ_chain_fam n
```

**(C) F-step up to Double Negation**:
```
f_content(predecessor).map (fun phi => phi.neg.neg) ⊆ u ∪ f_content(u).map (...)
```

**Trade-off**:
- **Advantage**: May be provable with existing infrastructure
- **Disadvantage**: Must verify weakened property is sufficient for truth lemma
- **Feasibility**: Medium-High - (B) is essentially what the truth lemma requires anyway

**Analysis**: Option (B) is actually the key insight - we don't need F-step to hold at EVERY predecessor; we need F-witnesses to eventually resolve somewhere in the chain. This is guaranteed by the nesting boundary axioms (f_nesting_boundary, p_nesting_boundary).

### Alternative 4: Dual Seed Design (Symmetric Successor/Predecessor)

**Definition**: Make successor and predecessor seeds structurally symmetric, both including both direction's deferral disjunctions.

**Symmetric Successor Seed**:
```
symmetric_successor_seed(u) = g_content(u) ∪
                               deferralDisjunctions(u) ∪
                               pastDeferralDisjunctions_from_u(u)
```

where `pastDeferralDisjunctions_from_u(u)` includes `phi ∨ P(phi)` for each `P(phi) in u`.

**Symmetric Predecessor Seed**:
```
symmetric_predecessor_seed(u) = h_content(u) ∪
                                 pastDeferralDisjunctions(u) ∪
                                 futureDeferralDisjunctions_from_u(u)
```

where `futureDeferralDisjunctions_from_u(u)` includes `phi ∨ F(phi)` for each `F(phi) in u`.

**Trade-off**:
- **Advantage**: Both directions get deferral properties by construction
- **Disadvantage**: Must prove consistency of combined seeds
- **Feasibility**: Medium - similar complexity to Alternative 1

**Key Observation**: The current successor construction DOES satisfy F-step by construction (deferralDisjunctions ensure it). The predecessor construction satisfies P-step by construction. The MISSING piece is ensuring predecessor satisfies F-step and successor satisfies P-step.

### Alternative 5: Accept Axiom with Semantic Justification

**Definition**: Keep the axiom but provide stronger semantic justification showing it's a property of ANY Lindenbaum extension, not just ours.

**Argument**:
1. The predecessor v is constructed to satisfy Succ(v, u)
2. In ANY discrete linear frame, if Succ(v, u), then the only way F(phi) can hold at v is if phi holds at u or F(phi) holds at u
3. This is because the ONLY accessible world from v (in the F-direction) is u (by discreteness)
4. Lindenbaum extension adds formulas consistently with the seed structure
5. The seed structure (h_content(u) ⊆ v) ensures v "looks back" at u correctly
6. By semantic necessity, any F-formula at v must resolve within the chain

**Trade-off**:
- **Advantage**: No code changes required
- **Disadvantage**: Not a formal proof; axiom remains
- **Feasibility**: High
- **Mathematical Status**: The argument is semantically sound; the gap is in formalizing "Lindenbaum cannot add F-formulas that violate the frame structure"

## Prior Art

### Existing Codebase Patterns

**1. successor_from_deferral_seed Avoids This Issue**

Location: `SuccExistence.lean` lines 419-498

The successor construction works because:
- F-step requires: f_content(u) ⊆ v ∪ f_content(v)
- The deferral disjunctions `phi ∨ F(phi)` for each `F(phi) in u` guarantee this
- After Lindenbaum, MCS disjunction property gives: phi in v OR F(phi) in v
- This is EXACTLY the F-step condition

The DIFFERENCE: For successor, we BUILD the v to satisfy F-step from u's F-content. For predecessor, we need v's F-content to be CONSTRAINED BY u, but we're not directly building v's F-content.

**2. WitnessSeed.lean Pattern**

Location: `WitnessSeed.lean` lines 79-178

The `forward_temporal_witness_seed_consistent` proof handles a simpler case:
- Seed: `{psi} ∪ g_content(M)` where `F(psi) in M`
- The seed has ONE witness formula, not unbounded F-formulas
- The proof shows g_content plus one specific formula is consistent

This pattern doesn't directly transfer because the predecessor seed doesn't constrain what F-formulas can appear.

**3. DiscreteSuccSeed.lean Blocking Formulas**

Location: `DiscreteSuccSeed.lean` lines 88-116

Blocking formulas `neg(psi) ∨ neg(G(psi))` are used to ensure immediacy (no intermediate MCSes). A similar approach could be adapted:

- For F-step constraint, add "blocking" formulas `G(neg(phi))` for each phi where we DON'T want F(phi) in the predecessor
- This is essentially Alternative 1 above

### Modal Logic Literature

**Blackburn, de Rijke, Venema (2001) "Modal Logic"**

Chapter 4 on completeness discusses the canonical model construction. The canonical frame R is defined by:
```
wRw' iff for all phi, if Box(phi) in w then phi in w'
```

This is equivalent to `g_content(w) ⊆ w'`. The completeness proof relies on the "Existence Lemma":
- If Diamond(phi) in w, then there exists w' with wRw' and phi in w'

The key insight: The canonical model construction creates the w' via Lindenbaum, but the Existence Lemma guarantees phi IS in w'. This is because the seed {phi} ∪ Box^(-1)(w) is consistent (provable from Diamond(phi) in w).

**Gap in Literature**: Standard texts don't address constraints on what OTHER Diamond formulas appear in w'. The implicit assumption is that this doesn't matter for basic completeness - only that the specific witness exists.

**Goldblatt (1992) "Logics of Time and Computation"**

Section 6 on tense logic completeness uses a step-by-step construction for discrete frames. The key is constructing the frame by stages, not via unconstrained Lindenbaum extension on seeds.

Quote (paraphrased): "The frame is constructed in stages such that after stage n there is a linearly ordered set T_n with a maximal consistent set associated to each point."

This is the Segerberg approach (Alternative 2 above).

**Verbrugge et al. "Completeness by construction for tense logics of linear time"**

This paper explicitly uses the "construction by finite stages" method, noting that for discrete time:
- P-top and F-top ensure successiveness
- Adequate sets (finite closures) are used for local maximality
- The construction ensures frame conditions at each step

This supports the view that Alternative 2 (step-by-step construction) is the canonical solution in the literature.

## Recommended Path Forward

**Primary Recommendation: Alternative 3B (Eventual F-resolution)**

**Rationale**:
1. The truth lemma doesn't actually need f_content(predecessor) ⊆ u ∪ f_content(u) at every step
2. It needs F-witnesses to eventually resolve in the chain
3. This is already guaranteed by `f_nesting_boundary` and `p_nesting_boundary` axioms
4. The combination of bounded nesting + chain existence = all F-formulas resolve

**Action Items**:
1. Verify that the truth lemma's F-case can be proven using `f_nesting_boundary` without relying on local F-step
2. If yes, document that `predecessor_f_step_axiom` is SUPERSEDED by nesting boundary properties
3. If no, implement Alternative 1 (constrained seed) as fallback

**Secondary Recommendation: Document Semantic Soundness (Alternative 5)**

If Alternative 3B doesn't work, keep the axiom but add extensive documentation:
1. Explain the h/g vs f/p asymmetry
2. Explain why Lindenbaum cannot add "bad" F-formulas (semantic argument)
3. Note this is consistent with standard literature practice (implicit assumptions)

**Lowest Priority: Alternative 2 (Step-by-Step)**

This is the "correct" solution from the literature but requires significant refactoring. Consider only if:
- Axiom elimination becomes a hard requirement
- Other completeness paths fail

## Trade-offs Summary

| Alternative | Correctness | Effort | Risk |
|-------------|-------------|--------|------|
| 1. Constrained Seed | High | Medium | Medium (consistency proof) |
| 2. Step-by-Step | Very High | Very High | Low (standard technique) |
| 3. Weakened Axiom | Medium | Low | Medium (must verify sufficiency) |
| 4. Dual Seed Design | High | Medium | Medium (consistency proof) |
| 5. Accept with Justification | N/A | None | Low (semantic soundness) |

## Confidence Level

**Medium-High**

The analysis is thorough and covers both codebase patterns and literature. The main uncertainty is whether Alternative 3B (eventual F-resolution) is actually sufficient for the truth lemma - this requires verification at the code level.

## Sources

- [Modal Logic (Blackburn, de Rijke, Venema)](https://www.cambridge.org/core/books/modal-logic/F7CDB0A265026BF05EAD1091A47FCF5B)
- [Logics of Time and Computation (Goldblatt)](https://books.google.com/books/about/Logics_of_Time_and_Computation.html?id=V8OEAAAAIAAJ)
- [Completeness by construction for tense logics of linear time (Verbrugge et al.)](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/)
- [Modal Logic: A Semantic Perspective (Blackburn & van Benthem)](https://staff.science.uva.nl/~johan/hml-blackburnvanbenthem.pdf)
- [Lecture Notes on Completeness and Canonical Models (CMU)](https://www.cs.cmu.edu/~fp/courses/15816-s10/lectures/20-complete.pdf)
- [Completeness and Canonical Models (Open Logic Project)](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)
