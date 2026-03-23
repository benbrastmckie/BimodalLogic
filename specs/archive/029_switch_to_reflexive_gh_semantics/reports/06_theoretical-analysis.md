# Theoretical Analysis: Reflexive vs Strict G/H Semantics

**Date**: 2026-03-22
**Session**: sess_1774166463_107a7b
**Focus**: Mathematical foundations, expressiveness, natural properties

## Executive Summary

The choice between reflexive and strict (irreflexive) semantics for temporal operators G (future) and H (past) represents a fundamental design decision with profound consequences for proof complexity, frame definability, and logical expressiveness. This analysis examines the mathematical trade-offs from first principles.

**Key Finding**: The choice is not merely technical but represents a trade-off between **frame-definability expressiveness** (favoring strict semantics) and **proof-theoretic simplicity** (favoring reflexive semantics). For the TM logic's specific goals (completeness theorems for linear temporal reasoning), reflexive semantics offers substantial advantages: the T-axiom becomes valid, irreflexivity is definitionally avoided, and the three-variant frame class structure collapses to a simpler single logic. The loss of frame-definability for density/seriality properties is acceptable because these are not the primary semantic distinctions TM needs to capture.

## 1. The Semantic Distinction

### Reflexive Semantics (<=)

Under reflexive semantics, temporal quantification includes the present moment:

```
M, t |= G phi  iff  forall s >= t, M, s |= phi   ("phi at all times now-and-later")
M, t |= H phi  iff  forall s <= t, M, s |= phi   ("phi at all times now-and-earlier")
```

**Consequences**:
- **T-axiom is valid**: G phi -> phi holds definitionally (take s = t)
- **F phi and P phi trivially satisfied by present**: phi -> F phi (witnessed by t itself)
- **Seriality axioms become trivial**: G phi -> F phi always holds (present witnesses F phi)
- **Density axiom becomes trivial**: GG phi -> G phi holds on any transitive frame

### Irreflexive Semantics (<)

Under strict semantics, temporal quantification excludes the present moment:

```
M, t |= G phi  iff  forall s > t, M, s |= phi   ("phi at all strictly future times")
M, t |= H phi  iff  forall s < t, M, s |= phi   ("phi at all strictly past times")
```

**Consequences**:
- **T-axiom is INVALID**: G phi -> phi fails (no s > t equals t)
- **Seriality is non-trivial**: G phi -> F phi requires NoMaxOrder (existence of s > t)
- **Density is non-trivial**: GG phi -> G phi requires DenselyOrdered (intermediate points)
- **Discreteness is non-trivial**: The DF axiom requires SuccOrder (immediate successors)

### Historical Context

**Prior's Original Semantics (1957-1968)**: Arthur Prior invented tense logic using **strict semantics**. His operators F ("it will be the case") and P ("it was the case") quantified over strictly future and strictly past times respectively. The relation 'l' (is-later-than) was explicitly irreflexive.

Prior demonstrated systematic correspondences between temporal axioms and frame properties:
- **Transitivity** yields FF phi -> F phi and PP phi -> P phi
- **Density** yields F phi -> FF phi and P phi -> PP phi
- **No final moment** (seriality) yields G phi -> F phi

This strict approach was continued in the foundational temporal logic literature (Goldblatt, van Benthem, Blackburn-de Rijke-Venema).

**Computer Science Shift**: In verification and model checking (LTL, CTL), the reflexive closure is often preferred. CTL* uses reflexive versions of G and U. The "weak until" operator includes the present moment. This shift reflects practical concerns: finite state systems, discrete time steps, and algorithmic decidability.

**The TM Logic History**: The ProofChecker codebase has oscillated:
- Initial: Reflexive semantics
- Task 956: Switched to strict (density concern, later shown unfounded)
- Task 967: Switched back to reflexive (T-axiom approach for irreflexivity)
- Task 991: Reverted to strict (frame class separation motivation)
- Task 29: Investigating return to reflexive

## 2. Natural Properties of Each System

### Reflexive Advantages

1. **T-axiom validity**: G phi -> phi and H phi -> phi are definitionally valid, providing the bridge axiom needed for canonical model irreflexivity proofs without using the Gabbay IRR rule.

2. **Proof simplicity**: The canonical model construction avoids the irreflexivity problem entirely. Under reflexive semantics, CanonicalR M M holds (this is a feature, not a bug), and antisymmetry replaces irreflexivity as the key ordering property.

3. **Reduced axiom count**: The seriality axioms (G phi -> F phi, H phi -> P phi) and density axiom (GG phi -> G phi) become trivially valid, reducing the axiom base from 19 to 16 non-trivial axioms.

4. **Single completeness theorem**: Instead of three separate completeness proofs (Base, Dense, Discrete), a single proof suffices for all frame conditions.

5. **S4-alignment**: Reflexive temporal logic aligns with S4 modal logic (reflexive + transitive frames), a well-studied and elegant system.

6. **Intuitive reading for some applications**: "G phi" as "phi holds at all times including now" is natural for describing invariants that must hold persistently.

### Irreflexive Advantages

1. **Frame definability**: Density, seriality, and other frame properties can be characterized by temporal axioms. This enables genuinely distinct logics for different frame classes.

2. **Expressive power**: Three genuinely different logics (TM Base, TM Dense, TM Discrete) can be distinguished axiomatically.

3. **Prior's tradition**: Aligns with the historical development of tense logic and philosophical treatments of time.

4. **Sharper distinctions**: "F phi" means "phi will be true at some strictly future time" - a stronger, more precise claim than the reflexive reading.

5. **Standard in temporal logic literature**: Most theoretical work on temporal logic completeness uses strict semantics.

6. **Canonical model strict ordering**: The canonical relation is irreflexive, directly giving a strict temporal order on the quotient.

## 3. Frame Definability and Expressive Power

### Under Reflexive Semantics

**Frame properties that CAN be characterized**:
- Transitivity: G phi -> GG phi (4 axiom)
- Linearity: F phi AND F psi -> F(phi AND psi) OR F(phi AND F psi) OR F(F phi AND psi)

**Frame properties that CANNOT be characterized (collapse to trivial)**:
- Density: GG phi -> G phi becomes a theorem of T4 alone
- Seriality (NoMaxOrder): G phi -> F phi holds trivially (present witnesses)
- Seriality (NoMinOrder): H phi -> P phi holds trivially
- Discreteness: DF axiom becomes trivially valid

**The Frame Class Collapse**: Under reflexive semantics, all four extension axioms (DN, DF, SF, SP) are valid on ANY linear order:

| Axiom | Trivial Proof |
|-------|---------------|
| DN: GG phi -> G phi | Take r = t in "forall s >= t, forall r >= s, phi(r)" |
| DF: (F top AND phi AND H phi) -> F(H phi) | s = t witnesses F(H phi) since H phi(t) holds |
| SF: G phi -> F phi | T-axiom: phi(t) witnesses F phi |
| SP: H phi -> P phi | T-axiom: phi(t) witnesses P phi |

### Under Irreflexive Semantics

**Frame properties that CAN be characterized**:
- Transitivity: G phi -> GG phi (4 axiom)
- Density: GG phi -> G phi (DN axiom) - genuinely requires DenselyOrdered
- Seriality: G phi -> F phi (SF axiom) - genuinely requires NoMaxOrder
- Discreteness: DF axiom - genuinely requires SuccOrder
- Linearity: the linearity axiom

**Critical Result from Modal Logic**: **Irreflexivity itself is NOT modally definable**. No temporal formula can characterize exactly the class of irreflexive frames. This is a fundamental result proven via bisimulation arguments (Blackburn, de Rijke, Venema).

Consequence: Under strict semantics, the irreflexivity of the temporal ordering relation cannot be "directly" syntactically expressed. This is why the canonical model construction requires the Gabbay IRR rule or an axiom declaration - the property must be proven indirectly.

### The Frame Class Collapse: Feature or Bug?

**Arguments for "Feature" (simplification)**:
1. TM's goal is completeness for linear temporal reasoning, not frame-class taxonomy
2. The quotient ordering is still genuinely strict for distinct MCSes
3. Simpler metatheory with one completeness proof instead of three
4. The mathematical content of density/discreteness is still present in the frame, just not in the axioms

**Arguments for "Bug" (loss of expressiveness)**:
1. Cannot distinguish dense from discrete frames axiomatically
2. Cannot use the logic to define frame properties
3. Loses connection to standard temporal logic hierarchy
4. The axiom system becomes less informative about the underlying frame

**Resolution for TM**: The collapse is a **feature** because:
- TM's primary goal is proving statements about task management, not classifying frames
- The canonical model construction benefits enormously from T-axiom availability
- The FMCS infrastructure already assumes a single linear order (integers or rationals)
- The separate frame class completeness theorems (Tasks 18, 24) become unnecessary

## 4. Natural Logics for Each Semantics

### TM-Specific Considerations

The TM logic is designed for bimodal reasoning about tasks over linear discrete time. Key requirements:
1. **Linear temporal order**: Tasks progress along a single timeline
2. **S5 modality**: Necessity is transworld (all histories)
3. **Interaction axioms**: MF, TF connect modality and temporality
4. **Completeness**: Soundness and completeness for the intended semantics

For these goals, reflexive semantics is more natural because:
- The irreflexivity proof is the major obstacle in completeness (1254 lines in CanonicalIrreflexivity.lean)
- The T-axiom provides the bridge needed for this proof
- Frame class distinctions are not a primary TM concern

### Standard Temporal Logics

**Priorian Tense Logic (Prior 1957-1968)**: Strict semantics. Four operators F, P, G, H with strict quantification. Frame correspondence is a primary concern.

**LTL (Linear Temporal Logic)**: Typically strict for X (next), but reflexive variants exist for "weak until." The distinction matters for liveness vs safety properties.

**CTL/CTL***: Reflexive semantics common. AG phi means "phi at all states including the current one." This aligns with model checking practice.

**S4.3 and S4.3.1**: These modal logics of linear time use reflexive + transitive accessibility. S4.3.1 is complete with respect to linear orders - this is essentially TM with reflexive semantics and no past operators.

**Goldblatt's Logics of Time and Computation**: Provides completeness proofs for various frame classes using strict semantics. The standard reference for frame correspondence in temporal logic.

## 5. Completeness and Representation

### Impact on Completeness Proofs

**Under Strict Semantics**:
- The canonical relation CanonicalR is defined by: CanonicalR M N iff g_content(M) subseteq N
- Irreflexivity (not CanonicalR M M) is NOT derivable from TM axioms
- Proof requires Gabbay IRR rule or axiom declaration
- The 1254-line proof in CanonicalIrreflexivity.lean attempts the IRR approach but requires the T-axiom, which is invalid under strict semantics
- Current solution: axiom declaration (`canonicalR_irreflexive_axiom`)

**Under Reflexive Semantics**:
- CanonicalR M M holds (this is correct - g_content(M) subseteq M by T-axiom)
- Instead of irreflexivity, we establish **antisymmetry**: CanonicalR M N AND CanonicalR N M -> M = N
- The T-axiom (Gp -> p) is available for the Gabbay-style proof
- The proof structure becomes: if CanonicalR M N and M != N, then not CanonicalR N M
- The existing 1170-line Gabbay infrastructure can be "reactivated" for antisymmetry

### Impact on Representation Theorems

**Under Strict Semantics**:
- Three distinct representation theorems: Base (general linear), Dense (Q-like), Discrete (Z-like)
- Each frame class has different axiom requirements
- DovetailedTimelineQuot construction gives D cong Q for dense frames
- Discrete construction gives D cong Z

**Under Reflexive Semantics**:
- Single representation theorem: all TM-derivable statements are valid on linear orders
- The distinction between dense and discrete becomes a frame property, not an axiom property
- The D-from-syntax characterization (TimelineQuot cong Q) remains mathematically valid but is not needed for completeness

## 6. Recommendation

### For TM Logic Specifically

**Recommendation: Switch to reflexive semantics (Task 29 should proceed)**

Justification:

1. **Eliminates the irreflexivity blocker**: The `canonicalR_irreflexive_axiom` (currently an axiom) becomes FALSE and must be removed, but this is a feature - the concept is replaced by antisymmetry which is provable.

2. **Enables T-axiom approach**: The 1170-line Gabbay infrastructure can be used for the antisymmetry proof, eliminating the need for the axiom.

3. **Simplifies completeness architecture**: Three completeness theorems collapse to one. Tasks 18 (dense completeness) and 24 (discrete axiom proofs) become reduced-scope or unnecessary.

4. **Supersedes Task 26**: The goal of removing canonicalR_irreflexive_axiom is achieved by the switch.

5. **Aligns with existing documentation**: ROAD_MAP.md already says reflexive semantics is "ADOPTED" (a Task 991 documentation inconsistency).

6. **FMCS infrastructure compatibility**: The FMCS coherence conditions are already documented for reflexive semantics in the "Indexed MCS Family Approach" strategy.

**Trade-offs accepted**:
- Loss of frame-definability for density/seriality (acceptable for TM's goals)
- Departure from strict temporal logic tradition (acceptable given practical benefits)
- Frame class collapse to single logic (simplification, not a problem)

### General Guidance

**Use strict (irreflexive) semantics when**:
- Frame definability is a primary concern
- You need to distinguish dense from discrete frames axiomatically
- Working in the tradition of tense logic / temporal representation
- The T-axiom would cause problems in your application

**Use reflexive semantics when**:
- Proof simplicity is prioritized
- You want S4-style modal properties for temporal operators
- The frame class is fixed externally (e.g., working over Z or Q specifically)
- You need the T-axiom for canonical model constructions

## References

### Primary Sources Consulted

**Stanford Encyclopedia of Philosophy**:
- [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) - Comprehensive treatment of strict vs reflexive semantics
- [Arthur Prior](https://plato.stanford.edu/entries/prior/) - Prior's original strict semantics

**Internet Encyclopedia of Philosophy**:
- [Arthur Prior: Logic](https://iep.utm.edu/prior-an/) - Hamblin's axiomatization, Ockhamist vs Peircean semantics

**Textbooks and Handbooks**:
- Blackburn, de Rijke, Venema (2001) *Modal Logic* - Frame correspondence, modal definability
- Goldblatt (1992) *Logics of Time and Computation* - Completeness for frame classes

**Open Logic Project**:
- [Frame Definability](https://builds.openlogicproject.org/content/normal-modal-logic/frame-definability/frame-definability.pdf) - Irreflexivity is not modally definable

**Research Papers**:
- Verbrugge (ILLC Festschrift) - Completeness by construction for tense logics of linear time
- van Benthem - Notes on modal definability; frame correspondence theory

### Key Technical Results

1. **Irreflexivity is not modally definable** (Blackburn, de Rijke, Venema): No modal formula holds exactly at those points w where not Rww. Proof by bisimulation.

2. **Gabbay Irreflexivity Rule (IRR)**: If |- p AND H not-p -> A and p does not occur in A, then |- A. Introduced by Gabbay (1981) for handling irreflexivity in completeness proofs.

3. **S4.3.1 completeness**: The modal logic S4.3.1 is complete with respect to linear orders (reflexive + transitive + connected + antisymmetric).

4. **Frame class collapse theorem**: Under reflexive semantics, DN, DF, SF, SP are valid on all linear orders (any reflexive transitive linear frame).
