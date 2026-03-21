# Research Report: Homogeneity Without Discreteness or Density

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-010
**Date**: 2026-03-07
**Session**: sess_1772922052_dcd9b8
**Status**: Findings ready for planning

---

## 1. Executive Summary

This report investigates whether homogeneity of the canonical timeline T can be achieved without assuming discreteness (axioms DP/DF) or density (axiom DN), and how this compares to the axiomatic abstraction approach of research-009.

**Principal Findings**:

1. **No syntactic axiom can force homogeneity without implying density or discreteness.** This is a model-theoretic impossibility: the only countable linear orders without endpoints on which Aut+(T) acts transitively are Q (dense) and Z (discrete). There is no "third kind" of homogeneous linear order.

2. **Back-and-forth without discreteness/density is impossible for the same reason.** A back-and-forth argument needs either the density extension property (between any two points there is a third) or the discrete extension property (every point has an immediate successor/predecessor). Without one of these, the extension step fails.

3. **Controlled Lindenbaum construction necessarily produces Z or Q.** Any deterministic construction that maintains back-and-forth invariants and produces a homogeneous timeline must produce one of these two order types. It cannot avoid choosing between discrete and dense.

4. **The HomogeneousTimeline typeclass from research-009 Option D is the correct abstraction**, but it is NOT a way to avoid the choice -- it merely defers it. Any concrete instance must still be Z or Q.

**Recommendation**: Accept that the choice between discrete and dense is **mathematically forced**, not a design limitation. The discreteness axiom path (DP/DF, yielding T isomorphic to Z) remains the simplest and most natural for formalization.

---

## 2. The Key Model-Theoretic Fact

### 2.1 Precise Formulation of Homogeneity

For the translation group D = Aut+(T) to form a torsor over T (required for eval-at-origin to be a bijection), we need:

> **Transitivity**: For every a, b in T, there exists f in Aut+(T) with f(a) = b.

This is equivalent to saying Aut+(T) acts **transitively** on T.

### 2.2 Classification of Transitive Linear Orders

**Theorem** (classical, folklore in model theory): Let (T, <) be a countable linear order without endpoints such that Aut+(T) acts transitively on T. Then T is order-isomorphic to one of:
- **(Z, <)** -- the integers with standard order (discrete)
- **(Q, <)** -- the rationals with standard order (dense)

**Proof sketch**: Suppose Aut+(T) acts transitively. Fix any point t0 in T.

**Case 1**: t0 has an immediate successor s. Then by transitivity, every point has an immediate successor (apply the automorphism taking t0 to any other point). Similarly every point has an immediate predecessor (apply the automorphism taking s to any point's immediate successor, then its preimage under f is an immediate predecessor). This gives T with `SuccOrder` and `PredOrder`, and the no-endpoints condition plus countability gives T isomorphic to Z via `orderIsoIntOfLinearSuccPredArch`.

**Case 2**: t0 has no immediate successor. Then between t0 and any point above t0, there exists another point. By transitivity, the SAME holds for every point: between any two comparable points there exists a third. This makes T dense. By Cantor's theorem (formalized in Mathlib as `Order.iso_of_countable_dense`), T is isomorphic to Q.

**Why there is no third option**: Every point in a linear order either has an immediate successor or it doesn't. If Aut+(T) acts transitively, this property is uniform across all points. So T is either everywhere-discrete or everywhere-dense. There is no hybrid.

### 2.3 Implications for the Research Questions

This classification theorem directly answers the research questions:

1. **Q: Can we maintain back-and-forth without discreteness or density?**
   A: No. The extension property in back-and-forth requires either density (to find intermediate points) or discreteness (to match immediate successors). These are the only two mechanisms.

2. **Q: Is there an axiom forcing homogeneity without implying density or discreteness?**
   A: No. Any axiom system whose canonical model has a transitive automorphism group necessarily has a model that is either dense or discrete. The axiom would have to imply one of these.

3. **Q: Can controlled Lindenbaum avoid choosing between discrete and dense?**
   A: No. Any construction producing a homogeneous timeline produces either Z or Q.

---

## 3. Detailed Analysis of Each Path

### 3.1 Path A: Back-and-Forth Without Discreteness/Density

**Goal**: Build a back-and-forth argument for homogeneity using only the existing temporal axioms (TK, T4, TA, TL, TT-G, TT-H).

**Why it fails**: The back-and-forth extension step requires solving:

> Given a finite partial automorphism p : T -> T and a point a not in dom(p), find b not in ran(p) such that p union {(a,b)} is still a partial automorphism.

For this to work, when a falls between two mapped points p(ai) < a < p(aj), we need to find b between p(ai) and p(aj). This requires either:
- **Density**: There exists a point between any two points (so b exists trivially)
- **Discreteness**: The gap structure is uniform (exactly one point between consecutive mapped points, so b is uniquely determined)

Without either property, the gap between p(ai) and p(aj) might have a different cardinality than the gap between ai and aj. For example:
- Between M_a and M_c there might be 3 points
- Between p(M_a) and p(M_c) there might be 7 points
- No order-preserving matching is possible

The temporal axioms TK/T4/TA/TL ensure linearity and no endpoints but do NOT constrain gap sizes.

### 3.2 Path B: Syntactic Homogeneity Axiom

**Goal**: Find an axiom schema that forces homogeneity without implying density or discreteness.

**Why it is impossible**: By the classification theorem (Section 2.2), forcing transitivity of Aut+(T) necessarily forces T to be isomorphic to Z or Q. Any axiom achieving this must logically imply either:
- Discreteness properties (equivalent to DP/DF), or
- Density properties (equivalent to DN: F phi -> FF phi)

**Candidate axioms examined**:

1. **"Shift axiom"**: Something like `phi <-> G(P phi)` (every truth recurs at the same relative position). This is already derivable from TA + T4 + TT and does NOT force homogeneity. It only says "the present is in the future of the past" but not "the future looks the same from every point."

2. **"Uniform witness axiom"**: Something like `F phi -> exists unique immediate F-witness`. This IS a discreteness axiom in disguise (it asserts immediate successors exist).

3. **"Bisimulation axiom"**: Something like "every temporal formula has the same truth value at shifts." This is NOT expressible as a single axiom schema in the TM language without quantifying over all formulas (which TM cannot do -- it lacks second-order quantification).

**Conclusion**: No first-order modal axiom can force homogeneity without implying density or discreteness. The reason is fundamental: homogeneity is a second-order property (quantifying over automorphisms), while TM axioms are first-order modal.

### 3.3 Path C: Controlled Lindenbaum Construction

**Goal**: Design a deterministic Lindenbaum-like construction that produces a homogeneous timeline by construction.

**Analysis**: A controlled construction CAN produce a homogeneous timeline, but it must choose:
- **Discrete construction** (dovetailed Z-indexing, as in research-009 Section 5.2): Produces T isomorphic to Z
- **Dense construction** (rational-indexed back-and-forth, as in research-009 Section 5.3): Produces T isomorphic to Q

**Key insight**: The controlled construction does NOT avoid the choice between discrete and dense. It simply makes the choice at construction time rather than at the axiom level. The construction FORCES a specific order type.

**Trade-offs**:
- Discrete construction: Simpler (200-400 lines), matches natural intuition about time steps
- Dense construction: More complex (400-600 lines), requires more sophisticated seed design

**Either construction works**, but both implicitly assume a structural property (discreteness or density) that could more cleanly be captured at the axiom level.

---

## 4. Comparison with Research-009 Approaches

### 4.1 Option C (Axiomatic Discreteness via DP/DF) -- RECOMMENDED

**From research-009**: Add axioms DP (Hphi -> phi or PHphi) and DF (Gphi -> phi or FGphi), yielding T isomorphic to Z.

**Assessment**: This is the mathematically cleanest path.

Pros:
- Effort: 100-200 lines of Lean
- Leverages Mathlib's `orderIsoIntOfLinearSuccPredArch` directly
- The axioms are well-established in temporal logic literature (Venema, Reynolds)
- Makes the structural assumption explicit and auditable
- Homogeneity of Z is trivial (translation by n)

Cons:
- Restricts the logic to discrete time only
- Some philosophical contexts prefer continuous or dense time

**Mathlib support**: `orderIsoIntOfLinearSuccPredArch` (confirmed in Mathlib, see Section 6) gives the isomorphism T isomorphic to Z directly from `LinearOrder + SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + IsSuccArchimedean`.

### 4.2 Option D (Axiomatic Abstraction via HomogeneousTimeline) -- VIABLE BUT DEFERRED

**From research-009**: Define a `HomogeneousTimeline` typeclass that bundles the homogeneity assumption.

**Assessment**: This is a valid SOFTWARE ENGINEERING approach but does not solve the MATHEMATICAL problem.

```lean
class HomogeneousTimeline (T : Type*) [LinearOrder T] where
  homogeneous : forall a b : T, exists f : T ≃o T, f a = b
```

**Key observation**: Any concrete instance of `HomogeneousTimeline` on a countable T without endpoints must be either Z or Q (by Section 2.2). The typeclass does not avoid the choice; it merely defers it.

**When this is useful**:
- If the project wants to develop the theory parametrically (proving theorems about D that work for both Z and Q timelines)
- If future extensions might support both discrete and dense time
- As a temporary abstraction layer while the axiom choice is debated

**When this is NOT useful**:
- If we need a CONCRETE canonical model (completeness proofs need actual constructions)
- If the typeclass can never be instantiated without additional axioms

**Recommendation**: Use `HomogeneousTimeline` as an intermediate typeclass in the D-construction theorems, but provide the concrete instance via DP/DF axioms. This gives both generality and concreteness.

### 4.3 Option E (Controlled Lindenbaum) -- HIGHER EFFORT, SAME RESULT

**From research-009**: Build homogeneity into the canonical model via controlled construction.

**Assessment**: This is mathematically equivalent to Option C (discrete version) or a hypothetical density axiom (dense version), but with more proof effort.

The controlled construction produces T isomorphic to Z (or Q), but proving this requires:
1. Defining the positioned fragment (PositionedMCS)
2. Proving order preservation
3. Proving completeness of the enumeration
4. Proving the truth lemma still holds

This is 200-400 lines for Z (vs 100-200 for Option C) with the same end result.

The ONLY advantage is not modifying the axiom system. But the construction effectively ASSUMES discreteness (or density) by how it builds the timeline. This assumption is just hidden in the construction rather than stated in the axioms.

---

## 5. Why Discreteness Is Natural for TM

### 5.1 Philosophical Argument

The TM logic includes both temporal operators (G/H) and a modal operator (Box). The modal operator represents metaphysical necessity. In many philosophical frameworks where metaphysical necessity is discussed (e.g., possible worlds semantics for modal logic), time is treated as discrete -- each "moment" is a complete specification of temporal facts.

The discreteness axioms DP/DF are standard in the temporal logic literature:
- They appear in Venema's axiomatization of Z_t (temporal logic of the integers)
- They are included in Prior's original tense logic formulations for discrete time
- They do not conflict with any of the existing TM axioms

### 5.2 Technical Argument

With T isomorphic to Z:
- D = Aut+(Z) = Z (translations only)
- The group structure is trivially abelian (Z is abelian)
- Holder's theorem is not needed (commutativity is immediate)
- The linear order on D is the standard order on Z
- The torsor structure is standard (Z acts on Z by translation)

This eliminates ALL of the deferred proof obligations listed in TranslationGroup.lean:
- `AddCommGroup D`: Z is commutative -- trivial
- `LinearOrder D`: Z has standard order -- trivial
- `IsOrderedAddMonoid D`: Z is ordered -- trivial
- `AddTorsor D T`: Z acts freely and transitively on Z -- trivial

### 5.3 Formalization Argument

Mathlib has comprehensive support for Z:
- `orderIsoIntOfLinearSuccPredArch`: T isomorphic to Z from SuccOrder + PredOrder + Archimedean
- `Int.instLinearOrder`: Z has LinearOrder
- `Int.instAddCommGroup`: Z has AddCommGroup
- `Int.instOrderedAddCommGroup`: Z has OrderedAddCommGroup
- `Int.instIsSuccArchimedean`: Z is succ-Archimedean

All the deferred properties become DEFINITIONAL or follow from existing Mathlib instances.

---

## 6. Mathlib Infrastructure Available

### 6.1 For the Discrete Path (T isomorphic to Z)

| Mathlib Declaration | Module | Purpose |
|---------------------|--------|---------|
| `orderIsoIntOfLinearSuccPredArch` | `Mathlib.Order.SuccPred.LinearLocallyFinite` | T isomorphic to Z |
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | T isomorphic to Q (dense case) |
| `FirstOrder.Language.IsUltrahomogeneous` | `Mathlib.ModelTheory.Fraisse` | Ultrahomogeneity definition |
| `FirstOrder.Language.IsFraisseLimit` | `Mathlib.ModelTheory.Fraisse` | Fraisse limit = ultrahomogeneous + age |
| `isFraisseLimit_of_countable_nonempty_dlo` | `Mathlib.ModelTheory.Order` | Q is Fraisse limit of finite linear orders |
| `aleph0_categorical_dlo` | `Mathlib.ModelTheory.Order` | DLO is aleph0-categorical |
| `Int.instIsSuccArchimedean` | Mathlib | Z is succ-Archimedean |

### 6.2 For the HomogeneousTimeline Abstraction

No direct Mathlib support for a "HomogeneousTimeline" typeclass -- this would be custom.

However, `AddTorsor` in Mathlib provides a close analog:
- `AddTorsor G P` requires free and transitive action of G on P
- If we can establish `AddTorsor Z T`, this gives homogeneity as a consequence

---

## 7. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Single-Family BFMCS modal_backward | Low | Not directly relevant to homogeneity question |
| CanonicalReachable/CanonicalQuotient Stack | Medium | Confirmed that forward-only reachability is insufficient; bidirectional fragment is correct |
| Constant Witness Family | Low | Not relevant |
| Cross-Origin Coherence | Low | Not on critical path |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Directly relevant -- homogeneity is needed for the MCS family to work as a torsor |
| CoherentConstruction Two-Chain | SUPERSEDED | The dovetailing approach in DovetailingChain.lean is the successor |
| Representation-First Architecture | CONCLUDED | Discreteness axioms would need integration with existing representation |

**Key alignment**: The recommendation to add discreteness axioms is consistent with the "Indexed MCS Family Approach" strategy. The axioms give the family a canonical Z-indexing.

---

## 8. Concrete Implementation Sketch

### If Discreteness Axioms Are Chosen (Recommended)

**Step 1**: Add axioms to `Axioms.lean`:
```lean
| discrete_future (phi : Formula) : Axiom (Formula.always_future phi |>.imp
    (phi.or (Formula.some_future (Formula.always_future phi))))
| discrete_past (phi : Formula) : Axiom (Formula.always_past phi |>.imp
    (phi.or (Formula.some_past (Formula.always_past phi))))
```

**Step 2**: Prove `SuccOrder` and `PredOrder` on `BidirectionalQuotient`:
- Use `discrete_future` to show each equivalence class has an immediate successor
- Use `discrete_past` to show each equivalence class has an immediate predecessor

**Step 3**: Prove `IsSuccArchimedean`:
- Use existing bidirectional reachability to show iterated successors reach any point

**Step 4**: Apply `orderIsoIntOfLinearSuccPredArch`:
```lean
noncomputable def timeline_iso_int : CanonicalTimeline M0 h_mcs0 ≃o Z :=
  orderIsoIntOfLinearSuccPredArch
```

**Step 5**: Transfer group structure:
- D = Aut+(T) isomorphic to Aut+(Z) = Z
- All deferred properties (AddCommGroup, LinearOrder, etc.) follow from Z's instances

### If HomogeneousTimeline Abstraction Is Chosen (Alternative)

**Step 1**: Define the typeclass:
```lean
class HomogeneousTimeline (T : Type*) [LinearOrder T] where
  homogeneous : forall a b : T, exists f : T ≃o T, f a = b
```

**Step 2**: Prove D properties ASSUMING `HomogeneousTimeline T`:
- Transitivity of action: directly from `homogeneous`
- Linear order on D: from transitivity + injectivity of eval-at-origin
- Commutativity: still needs Holder's theorem or similar

**Step 3**: Later, instantiate with DP/DF to get the concrete model.

---

## 9. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Classification of transitive linear orders | Section 2.2 | No | new_file |
| Fraisse limits and ultrahomogeneity | Section 6.1 | No | extension |
| Discreteness axioms DP/DF | Section 5 | No | extension |
| Relationship between axiom classes and order types | Section 2 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `temporal-order-types.md` | `domain/` | Classification of linear orders by axiom class (Z from DP/DF, Q from density, general from base TM) | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Temporal Frame Classes | Discreteness/density axioms and their frame conditions | Medium | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 1
- **Tasks to create**: 0
- **High priority gaps**: 0

---

## 10. Decisions

1. **Homogeneity without discreteness/density is mathematically impossible** for countable linear orders without endpoints (Section 2.2).
2. **The discreteness axiom path (DP/DF) is recommended** as the simplest, best-supported, and most explicit approach (Section 4.1).
3. **The HomogeneousTimeline typeclass is a viable intermediate abstraction** that can coexist with concrete DP/DF instantiation (Section 4.2).
4. **Controlled Lindenbaum is strictly dominated** by DP/DF in effort and clarity (Section 4.3).

---

## 11. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| DP/DF axioms conflict with existing proofs | Low | High | Verify soundness of extended axiom set against all existing semantics |
| Adding axioms requires updating all soundness proofs | Medium | Medium | Soundness proof is modular; only need new cases for DP/DF |
| Restricting to discrete time limits future applicability | Low | Low | Can later add a separate dense-time development |
| Holder's theorem still needed even with Z | Low | Low | With T isomorphic to Z, commutativity of D=Z is immediate without Holder |

---

## 12. Appendix

### Search Queries Used

1. "temporal logic homogeneous linear order axiom without density discreteness Kripke semantics"
2. "homogeneous linear order back and forth construction completeness temporal logic canonical model"
3. "ultrahomogeneous linear order classification countable model theory Fraisse"
4. "classification countable homogeneous linear orders Rosenstein"
5. "integers Z homogeneous linear order ultrahomogeneous order automorphism transitive"
6. "Venema temporal logic completeness canonical model linear order homogeneity"

### Mathlib Lookup Results

1. `Order.iso_of_countable_dense` (Mathlib.Order.CountableDenseLinearOrder) -- uniqueness of countable DLO
2. `orderIsoIntOfLinearSuccPredArch` (Mathlib.Order.SuccPred.LinearLocallyFinite) -- T isomorphic to Z
3. `FirstOrder.Language.IsUltrahomogeneous` (Mathlib.ModelTheory.Fraisse) -- ultrahomogeneity definition
4. `isFraisseLimit_of_countable_nonempty_dlo` (Mathlib.ModelTheory.Order) -- Q is Fraisse limit
5. `aleph0_categorical_dlo` (Mathlib.ModelTheory.Order) -- DLO aleph0-categorical
6. `Int.instIsSuccArchimedean` -- Z is succ-Archimedean

### References

- Venema, Y. "Temporal Logic." Chapter 10 in Handbook of Philosophical Logic.
- Stanford Encyclopedia of Philosophy, "Temporal Logic."
- Rosenstein, J. "Linear Orderings." Academic Press, 1982.
- Mathlib: `Mathlib.ModelTheory.Fraisse`, `Mathlib.ModelTheory.Order`, `Mathlib.Order.CountableDenseLinearOrder`
- nLab: DLO (Dense Linear Order)

---

## 13. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-010.md`
- **Key referenced files**:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system (no DP/DF)
  - `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D construction
  - `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- T with LinearOrder
  - `specs/956_construct_d_as_translation_group_from_syntax/reports/research-009.md` -- Prior analysis

---

## 14. Next Steps

1. **Decision**: Accept discreteness axiom path (DP/DF) as the way forward
2. **Implementation**: Add DP/DF to Axioms.lean, prove SuccOrder/PredOrder on BidirectionalQuotient
3. **Integration**: Apply `orderIsoIntOfLinearSuccPredArch` to get T isomorphic to Z
4. **Completion**: Transfer Z's properties to D, resolving all deferred obligations
