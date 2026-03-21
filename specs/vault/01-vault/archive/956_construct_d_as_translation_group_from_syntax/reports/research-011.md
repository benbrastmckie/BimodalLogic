# Research Report: Classification of Transitive Linear Orders and TM Completeness

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-011
**Date**: 2026-03-08
**Session**: sess_1773100800_a8f2c1
**Status**: Findings ready for planning

---

## 1. Executive Summary

This report corrects a significant mathematical error in research-010 and provides rigorous answers to the seven research questions about the classification of countable homogeneous linear orders and its implications for TM completeness.

**Critical Correction**: Research-010 claimed "the only countable linear orders without endpoints on which Aut+(T) acts transitively are Q (dense) and Z (discrete)." **This is FALSE.** Morel's classification theorem (1965) shows that the countable transitive linear orders are precisely those of order type zeta^gamma or zeta^gamma * eta for countable ordinals gamma (where zeta = order type of Z, eta = order type of Q). This includes orders like Z^2 (lexicographic product of Z-copies of Z), Z^omega, Z^2 * Q, etc.

**Key Implications**:
1. The TM axiom system (without discreteness or density) IS complete for the class of all reflexive linear orders -- this is an established result (Burgess 1982, Goldblatt 1992).
2. The canonical model may have ANY transitive linear order type, not just Z or Q.
3. For order types Z^gamma with gamma >= 2, Aut+(T) is NON-ABELIAN, which means the translation group D cannot be equipped with an abelian group structure by automorphism composition alone.
4. This makes the discreteness axiom path (DP/DF) not merely "simplest" but mathematically NECESSARY if we want D to be abelian (as required by the JPL paper's task semantics).

---

## 2. Question 1: Is the Classification Theorem Established?

### 2.1 Morel's Classification (The Correct Theorem)

**Theorem (Morel 1965)**: A linear order L is transitive (i.e., Aut(L) acts transitively on L) if and only if L is isomorphic to Z^gamma * D for some ordinal gamma and dense transitive D.

**Corollary (Morel)**: A countable linear order is transitive if and only if its order type is either zeta^gamma or zeta^gamma * eta for some countable ordinal gamma.

Here:
- zeta = order type of Z (the integers)
- eta = order type of Q (the rationals)
- Z^gamma = ordinal power (iterated lexicographic product)
- Z^gamma * Q = lexicographic product of Q-copies of Z^gamma

**Source**: Morel, A.C. (1965). "A class of relation types isomorphic to the ordinals." Michigan Mathematical Journal.

**Additional references**:
- Rosenstein, J. (1982). *Linear Orderings*. Academic Press. Chapter 8: Transitive Linear Orderings.
- The arxiv paper "Exponentiable linear orders need not be transitive" (2024) cites this as Theorem 3.15 and Corollary 3.16.

### 2.2 What Was Wrong in Research-010

Research-010 claimed:
> "The only countable linear orders without endpoints on which Aut+(T) acts transitively are Q (dense) and Z (discrete)."

The "proof sketch" in research-010 contained a logical error in Case 1: from "t0 has an immediate successor" and transitivity, it concluded T must be isomorphic to Z. But this does not follow. In Z^2 (the lexicographic product), every point has an immediate successor (the next element in the same Z-copy), and the automorphism group acts transitively, but Z^2 is NOT isomorphic to Z. The error was in assuming that SuccOrder + PredOrder + transitivity + no endpoints forces Z, when in fact it only forces Z under the additional assumption of Archimedeanness (IsSuccArchimedean).

### 2.3 The Correct Dichotomy

The correct dichotomy for countable transitive linear orders without endpoints is:

| Order Type | Dense? | Discrete? | Archimedean? | Aut+(T) abelian? |
|-----------|--------|-----------|-------------|-----------------|
| zeta (= Z) | No | Yes | Yes | Yes |
| eta (= Q) | Yes | N/A | N/A | No* |
| zeta^2 (= Z^2) | No | Yes | No | No |
| zeta^n for n >= 2 | No | Yes | No | No |
| zeta^omega | No | Yes | No | No |
| zeta^gamma * eta | Partially | Mixed | No | No |

(*Note: Aut+(Q) is actually non-abelian as well -- order-preserving bijections of Q do not commute in general. However, the *translation subgroup* of Q that acts freely and transitively is abelian: it is (Q, +) itself.)

### 2.4 Mathlib Formalization

The following Mathlib theorems are directly relevant:

1. **`Order.iso_of_countable_dense`**: For countable, densely ordered types alpha, beta without min/max, there exists an order isomorphism alpha ≃o beta. (Cantor's theorem for dense orders.)

2. **`orderIsoIntOfLinearSuccPredArch`**: For a nonempty linear order with SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, and IsSuccArchimedean, there is an order isomorphism to Z. **This requires Archimedeanness.**

3. **`isFraisseLimit_of_countable_nonempty_dlo`**: Q is the Fraisse limit of finite linear orders.

4. **`countable_of_linear_succ_pred_arch`**: Linear + SuccOrder + PredOrder + IsSuccArchimedean implies Countable.

---

## 3. Question 2: TM Completeness Implications

### 3.1 TM Is Complete for All Reflexive Linear Orders

The current TM axiom system (without discreteness or density) is **complete for the class of all reflexive linear orders**. This is an established result in temporal logic.

**The key axiom systems and their frame classes (from SEP and Venema)**:

| System | Axioms | Complete for |
|--------|--------|-------------|
| Kt | K distribution + necessitation | All frames |
| Kt + reflexivity | + Gp -> p, Hp -> p | All reflexive frames |
| Kt + ref + trans | + Gp -> GGp, Hp -> HHp | All reflexive transitive frames |
| Kt + ref + trans + lin | + linearity axiom | All reflexive transitive linear orders |
| Above + discreteness | + DP, DF | Discrete reflexive linear orders |
| Above + density | + DN (Fp -> FFp) | Dense reflexive linear orders |

The TM system includes reflexivity (TT-G, TT-H), transitivity (T4), connectedness (TA, TL), and linearity (temp_linearity). It is complete for the class of all reflexive transitive linear orders without endpoints.

**This means TM is NOT incomplete.** It proves exactly the formulas valid on ALL reflexive transitive linear orders. It simply does not prove formulas that are only valid on discrete orders or only valid on dense orders, because those are not valid on ALL linear orders.

### 3.2 What "Completeness" Means Here

There are multiple notions of completeness:

1. **Frame completeness**: TM is complete for the class of all reflexive transitive linear frames. This means: if phi is valid on all reflexive transitive linear frames, then TM proves phi. **This holds.**

2. **Completeness for a specific frame**: TM is NOT complete for the specific frame (Z, <=) because it does not prove discreteness axioms. TM is also NOT complete for (Q, <=) because it does not prove density axioms.

3. **Completeness for the canonical model**: The canonical model produces SOME reflexive transitive linear order. Since TM is frame-complete for all such orders, the canonical model construction works -- but the resulting order type is not determined.

### 3.3 The Real Issue: Not Incompleteness but Indeterminacy

The issue is NOT that TM is incomplete. The issue is that the canonical timeline T has an underdetermined order type. For the translation group D = Aut+(T) to serve as the duration type in the JPL paper's task semantics, we need D to be:
- A linearly ordered abelian group (from JPL paper)
- Acting freely and transitively on T (torsor property)

If T has order type Z^2 (which is consistent with TM), then Aut+(T) is non-abelian (it contains the wreath product Z wr Z), which violates the abelian group requirement.

**The problem is not incompleteness but structural underdetermination of the canonical model.**

---

## 4. Question 3: Disjunction of Axioms

### 4.1 Would "Discreteness OR Density" as an Axiom Help?

Adding "DP or DN" (discreteness or density) as a disjunctive axiom is mathematically coherent but has significant problems:

**Problem 1: Not a standard axiom schema.** TM axiom schemata are universally quantified formula patterns. A disjunction of axiom schemata is not a single axiom schema -- it would need to be formulated as something like:
```
(Gp -> p v FGp) v (Fp -> FFp)
```
But this is a disjunction of two universally quantified schemata, which is weaker than either schema individually. It says "for this SPECIFIC formula p, either discreteness or density holds," which does not force the frame to be globally discrete or globally dense.

**Problem 2: Morel's classification shows more options.** Even if we could force the frame to be "discrete or dense," Morel's classification includes order types like Z^2 that are neither dense nor discrete in the simple sense. (Z^2 has immediate successors everywhere but is not Archimedean.)

Wait -- actually Z^2 IS discrete (every element has an immediate successor and predecessor). The key issue is that Z^2 satisfies the discreteness axioms DP/DF but is NOT isomorphic to Z because it is not Archimedean.

### 4.2 Revised Analysis: Discreteness Axioms Are Not Sufficient

**Critical insight**: The discreteness axioms DP/DF force SuccOrder and PredOrder on T, but they do NOT force IsSuccArchimedean. Without Archimedeanness, Mathlib's `orderIsoIntOfLinearSuccPredArch` does not apply, and T could be Z^2, Z^3, Z^omega, etc.

This means research-009's claim that "DP/DF yield T isomorphic to Z" via `orderIsoIntOfLinearSuccPredArch` is **also incorrect** unless we can prove Archimedeanness from the temporal axioms.

### 4.3 Can Archimedeanness Be Proven from TM + DP/DF?

**Conjecture**: For the canonical model construction, Archimedeanness follows from the bidirectional reachability structure.

**Argument**: In the canonical model, every MCS in the bidirectional fragment is reachable from the origin M0 by a finite sequence of forward/backward steps. Each forward step takes M to its F-witness (immediate successor under DP). So every MCS is succ^[n] or pred^[n] of some other MCS, for finite n. This means the SuccOrder is Archimedean.

**Formalization check**: This argument depends on the specific construction of the bidirectional fragment, not just the axioms. The key lemma would be:

```
theorem bidirectional_succ_archimedean :
    forall a b : BidirectionalQuotient M0 h_mcs0,
      a <= b -> exists n : Nat, succ^[n] a = b
```

This should follow from the inductive definition of bidirectional reachability: every point in the fragment is reached by finitely many canonical-R steps from the origin, and under DP/DF, each canonical-R step corresponds to exactly one succ/pred step.

### 4.4 Conclusion on Disjunction

Adding "Discreteness OR Density" as a single axiom is problematic. The cleaner approach is:
1. Choose one (discreteness via DP/DF is simpler)
2. Prove Archimedeanness from the canonical model construction
3. Apply `orderIsoIntOfLinearSuccPredArch` to get T isomorphic to Z

---

## 5. Question 4: Homogeneity Axiom

### 5.1 Is Homogeneity Expressible in the Temporal Modal Language?

**No.** Homogeneity (transitivity of Aut+(T)) is a second-order property: it quantifies over automorphisms. The temporal modal language TM is propositional -- it cannot quantify over automorphisms or even over time points.

More precisely, homogeneity says:
> For all a, b in T, there exists f in Aut+(T) such that f(a) = b.

This requires:
- Universal quantification over pairs of time points (second-order over the domain)
- Existential quantification over order-preserving bijections (third-order)

No first-order modal axiom schema can express this.

### 5.2 What CAN the Modal Language Express?

The modal language can express local structural properties:
- Discreteness: "every point has an immediate successor" (DP/DF)
- Density: "between any two points there is a third" (DN: Fp -> FFp)
- No endpoints: implicit in T-axioms + linearity
- Reflexivity, transitivity, linearity: already in TM

It CANNOT express:
- Homogeneity (global symmetry)
- Archimedeanness (finite reachability)
- Specific order type (being isomorphic to Z, Q, etc.)

### 5.3 Could Homogeneity Be Derivable from Simpler Axioms?

Given Morel's classification, the question is: which axiom schemata force the canonical model's order type to be one where Aut+(T) acts freely and transitively WITH an abelian automorphism group?

The answer is: **discreteness + Archimedeanness** (forcing T isomorphic to Z) is the only option yielding an abelian Aut+(T). The density axioms yield Q, but Aut+(Q) is non-abelian (though Q has an abelian subgroup acting freely and transitively: the additive group (Q,+)).

---

## 6. Question 5: Candidate Axioms Evaluation

### 6.1 Uniform Witness Axiom

"If F phi, then among all future phi-times, there is a first."

Formulation: `F(phi) -> F(phi & H(neg phi))` ("there is a first future phi-time")

**Analysis**: This IS expressible in TM. It says: if phi holds sometime in the future, then there is a future time where phi holds and at all earlier times phi fails.

**Does it imply discreteness?** Taking phi = top: `F(top) -> F(top & H(neg top))`. But H(neg top) = "top has always been false", which is absurd. So this axiom is trivially valid for phi = top and does not constrain the frame.

For non-trivial phi, this axiom asserts a form of well-ordering for phi-witnesses in the future. It is related to the "first-time" or "Until" operator. It does NOT directly imply discreteness. A dense order (Q) satisfies this for SOME phi but not others.

**Verdict**: Not useful for our purposes. It is too formula-specific and does not constrain global frame structure.

### 6.2 Bisimulation Axiom

"F phi -> diamond phi" (future implies possibility)

**Analysis**: This says "if phi holds at some future time, then phi is possible." In the current TM semantics, this IS derivable:
- F(phi) means: there exists t' > t with phi at t'
- diamond(phi) means: there exists a world (history) tau' with phi at (tau', t)
- These are different! F is temporal, diamond is modal.

This axiom connects the temporal and modal dimensions. It is NOT derivable from current TM axioms. Whether it is sound depends on the task semantics: does every temporal witness correspond to a modal witness?

**Verdict**: Interesting but orthogonal to the homogeneity question. It constrains modal-temporal interaction, not timeline structure.

---

## 7. Question 6: HomogeneousTimeline Typeclass Strategy

### 7.1 Mathematical Coherence

The `HomogeneousTimeline` typeclass strategy from research-010 is mathematically coherent as a software engineering abstraction, but the analysis must be corrected:

```lean
class HomogeneousTimeline (T : Type*) [LinearOrder T] where
  homogeneous : forall a b : T, exists f : T ≃o T, f a = b
```

**Issue**: This typeclass captures transitivity of Aut(T), but NOT freeness. For the torsor property, we also need freeness: if f(a) = a for some a, then f = id.

**Stronger typeclass needed**:
```lean
class RegularTimeline (T : Type*) [LinearOrder T] where
  homogeneous : forall a b : T, exists! f : T ≃o T, f a = b
```

The uniqueness (exists!) gives both transitivity and freeness.

### 7.2 When Does RegularTimeline Hold?

- For T isomorphic to Z: Yes. The unique automorphism taking a to b is translation by (b - a). Aut+(Z) = Z.
- For T isomorphic to Q: **No.** There are many order-preserving bijections taking a to b. For example, both "translate by (b-a)" and "scale by 2 around a then translate" are distinct automorphisms Q -> Q fixing different sets of points. So Aut+(Q) does NOT act freely on Q.
- For T isomorphic to Z^2: **No.** Multiple automorphisms can take a given point to another.

### 7.3 Critical Implication

**Only Z among countable transitive linear orders without endpoints has the property that Aut+(T) acts FREELY and transitively (i.e., is a regular action making T an Aut+(T)-torsor with abelian Aut+(T)).**

This means:
1. The discreteness axioms DP/DF are not just "simplest" but essentially NECESSARY
2. Archimedeanness must also hold (to distinguish Z from Z^2, Z^3, etc.)
3. The density path (Q) does NOT yield a torsor because Aut+(Q) does not act freely

### 7.4 Revised Typeclass Strategy

```lean
-- This is the right abstraction:
class DiscreteArchimedeanTimeline (T : Type*) [LinearOrder T]
    [SuccOrder T] [PredOrder T] extends
    NoMaxOrder T, NoMinOrder T, IsSuccArchimedean T where

-- Theorem: DiscreteArchimedeanTimeline T -> T ≃o Z
-- This follows directly from Mathlib's orderIsoIntOfLinearSuccPredArch
```

---

## 8. Question 7: Current TM System Assessment

### 8.1 Frame Completeness: YES

The current TM system IS frame-complete for the class of all reflexive transitive linear orders without endpoints. This is an established result.

**References**:
- Burgess (1982): Axiomatizations for various classes of linear orders
- Goldblatt (1992): *Logics of Time and Computation*
- Blackburn, de Rijke, Venema (2001): *Modal Logic*
- SEP entry on Temporal Logic (confirms Lt(X) is complete for various linear order classes)

### 8.2 Completeness for the Intended Semantics: UNCLEAR

The JPL paper's intended semantics uses a SPECIFIC model structure: a task frame with a linearly ordered abelian group D acting on a timeline. The current TM system does not prove the axioms needed to force this structure. Specifically:

- TM does not prove discreteness (DP/DF)
- TM does not prove density (DN)
- TM does not prove Archimedeanness
- TM does not prove any axiom forcing Aut+(T) to be abelian

### 8.3 Minimal Extension for the Intended Semantics

**Option A (Recommended): Add DP/DF + Prove Archimedeanness**

Add the two discreteness axioms:
- DP: `Hp -> p v PHp` ("if p has always held, then either p holds now or there was a last time before which p always held")
- DF: `Gp -> p v FGp` (dual)

Then prove Archimedeanness from the canonical model construction (see Section 4.3).

This yields T isomorphic to Z via `orderIsoIntOfLinearSuccPredArch`, and D = Aut+(Z) = Z with all required properties.

**Effort estimate**: 100-200 lines for DP/DF axioms + SuccOrder/PredOrder proofs. 50-100 lines for Archimedeanness from bidirectional reachability. Total: 150-300 lines.

**Option B (Alternative): Add DP/DF + explicit Archimedean axiom**

If Archimedeanness cannot be proven from the construction, add an explicit axiom:

Archimedean axiom (potential formulation): `Fp -> F(p & G(neg p))` combined with an induction-like schema. However, Archimedeanness is NOT first-order expressible in the modal language. It is a property of the frame, not of formulas.

**Better approach**: Archimedeanness should follow from the construction, not from an axiom.

### 8.4 What About Density?

If density were chosen instead (DN: `Fp -> FFp`), the situation is worse:
- T isomorphic to Q (by Cantor's theorem / `Order.iso_of_countable_dense`)
- Aut+(Q) is non-abelian
- Aut+(Q) does not act freely on Q
- D = Aut+(Q) cannot be used as a torsor over Q
- Would need to use the ADDITIVE group (Q,+) as a subgroup of Aut+(Q), but this requires an embedding theorem

**Conclusion**: The density path is mathematically viable but significantly more complex and requires proving that the canonical model has a natural (Q,+)-action, not just a generic Aut+(Q)-action.

---

## 9. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient | Medium | Bidirectional fragment is correct, but order type is underdetermined |
| DovetailingChain | Medium | DovetailingChain produces a Z-indexed timeline, which is correct IF DP/DF are added |
| Single-Family BFMCS | Low | Not relevant to timeline structure |
| Non-Standard Validity | Low | Completeness for standard validity is what matters |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | DP/DF would give canonical Z-indexing |
| CoherentConstruction Two-Chain | SUPERSEDED | Dovetailing approach is the successor |
| Representation-First | CONCLUDED | The representation still works; DP/DF extend it |

### Key ROAD_MAP Insight

The "Indexed MCS Family Approach" strategy (ACTIVE) uses `fmcs : D -> Set Formula`. If D = Z (from DP/DF), this becomes `fmcs : Z -> Set Formula`, which is exactly the dovetailing chain indexed by integers. This is consistent with the existing DovetailingChain.lean approach.

---

## 10. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Morel's classification of transitive linear orders | Section 2 | No | new_file |
| Distinction: transitive vs free+transitive (regular) actions | Section 7.2 | No | extension |
| Archimedeanness requirement for Z identification | Section 4.2 | No | extension |
| Abelianness of Aut+(T) and its dependence on T | Section 2.3 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `transitive-linear-orders-domain.md` | `domain/` | Morel's classification, transitive vs regular, abelianness conditions | High | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Temporal Frame Classes | Discreteness axioms DP/DF, Archimedeanness, order type constraints | Medium | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 1
- **Tasks to create**: 0
- **High priority gaps**: 1

---

## 11. Decisions

1. **Research-010's classification claim is FALSE.** Morel's theorem shows many countable transitive linear orders exist beyond Z and Q.

2. **TM is frame-complete for all reflexive transitive linear orders.** The issue is structural indeterminacy, not incompleteness.

3. **DP/DF are necessary, not merely convenient.** Only T isomorphic to Z yields an abelian Aut+(T) acting freely and transitively.

4. **Archimedeanness must be proven from the construction.** DP/DF alone do not exclude order types like Z^2. The bidirectional reachability construction should provide this.

5. **The density path (Q) is NOT viable** for the torsor-based D construction because Aut+(Q) is non-abelian and does not act freely.

---

## 12. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Archimedeanness proof fails | Medium | High | Would need explicit construction ensuring finite-step reachability |
| DP/DF conflict with existing proofs | Low | High | Verify soundness of DP/DF against all existing TaskFrame models |
| Z^2 satisfies DP/DF | Certain | Medium | Must PROVE Archimedeanness, not assume it from DP/DF alone |
| Soundness of DP/DF for task semantics | Low | High | DP/DF are sound for (Z, <=) which is the intended frame |

---

## 13. Appendix

### Search Queries Used

1. "classification countable homogeneous linear orders without endpoints Rosenstein Fraisse"
2. "countable transitive linear order automorphism group classification theorem integers rationals"
3. "temporal logic completeness discrete dense axioms DP DF density discreteness"
4. "homogeneous linear order classification Z or Q countable without endpoints"
5. "Venema temporal logic axioms discrete completeness"
6. "1-transitive linear order countable classification"
7. "Morel classification order automorphism transitive countable linear order"
8. "Rosenstein Linear Orderings chapter 8 transitive linear order classification"
9. "automorphism group lexicographic product integers non-abelian"
10. "temporal logic Kt4.3 complete for class of all linear orders"
11. "Burgess 1982 basic tense logic complete all linear orders"

### Mathlib Lookup Results

1. `Order.iso_of_countable_dense` -- Cantor's theorem: countable dense unbounded linear orders are isomorphic
2. `orderIsoIntOfLinearSuccPredArch` -- T ≃o Z from LinearOrder + SuccOrder + PredOrder + NoMax + NoMin + IsSuccArchimedean
3. `isFraisseLimit_of_countable_nonempty_dlo` -- Q is Fraisse limit of finite linear orders
4. `countable_of_linear_succ_pred_arch` -- SuccOrder + PredOrder + IsSuccArchimedean implies Countable
5. `Int.instIsSuccArchimedean` -- Z has IsSuccArchimedean

### References

- Morel, A.C. (1965). "A class of relation types isomorphic to the ordinals." Michigan Mathematical Journal.
- Rosenstein, J. (1982). *Linear Orderings*. Academic Press. Chapter 8: Transitive Linear Orderings.
- Burgess, J.P. (1982). "Axioms for tense logic I: 'Since' and 'Until'." Notre Dame J. Formal Logic 23(4), 367-374.
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Stanford Encyclopedia of Philosophy. "Temporal Logic." https://plato.stanford.edu/entries/logic-temporal/
- Mathlib: `Mathlib.Order.CountableDenseLinearOrder`, `Mathlib.Order.SuccPred.LinearLocallyFinite`, `Mathlib.ModelTheory.Fraisse`

---

## 14. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-011.md`
- **Key referenced files**:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system
  - `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D construction
  - `specs/956_construct_d_as_translation_group_from_syntax/reports/research-009.md` -- Prior analysis (back-and-forth)
  - `specs/956_construct_d_as_translation_group_from_syntax/reports/research-010.md` -- Prior analysis (corrected herein)

---

## 15. Next Steps

1. **Decision**: Accept DP/DF axioms as necessary (not merely convenient)
2. **Verify**: Prove that Archimedeanness follows from the bidirectional reachability construction with DP/DF
3. **Implementation**: Add DP/DF to Axioms.lean, prove SuccOrder/PredOrder on BidirectionalQuotient
4. **Integration**: Prove IsSuccArchimedean, apply `orderIsoIntOfLinearSuccPredArch` to get T ≃o Z
5. **Completion**: Transfer Z's properties to D, resolving all deferred obligations
