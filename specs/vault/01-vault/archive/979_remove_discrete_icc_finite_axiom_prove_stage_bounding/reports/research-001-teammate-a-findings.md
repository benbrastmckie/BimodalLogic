# Teammate A Findings: Primary Proof Strategy for discrete_Icc_stage_bounded

**Task**: 979 - Remove discrete_Icc_finite_axiom and prove stage-bounding lemma
**Focus**: Mathematical proof strategy for `discrete_Icc_stage_bounded`
**Date**: 2026-03-16

## Executive Summary

The proof strategy for eliminating `discrete_Icc_finite_axiom` centers on proving that any element `c` in `Set.Icc a b` (in the quotient order) has a representative in `discreteStagedBuild (max (minStage a) (minStage b))`. This is achievable through the structural properties of the discrete staged construction, particularly the "stage-completeness" property that arises from the absence of density insertion.

**Confidence Level**: HIGH (85%)

The strategy is sound and leverages existing infrastructure well. The main risk is the complexity of the quotient-level argument.

---

## Key Findings

### 1. Structure of the Discrete Staged Construction

The discrete construction (`discreteStagedBuild`) differs fundamentally from the dense construction:

```lean
noncomputable def discreteStagedBuild : Nat -> Finset StagedPoint
  | 0 => stage0 root_mcs root_mcs_proof
  | n + 1 => evenStage (discreteStagedBuild n) n (n + 1)
```

**Key Properties**:
- Each stage applies `evenStage` which processes F/P formula obligations
- NO density insertion (no `oddStage` calls)
- Each stage adds only witnesses for F(phi) and P(phi) obligations
- `discreteStagedBuild_monotone_le`: stages are monotonically increasing

### 2. The Quotient Order Structure

The quotient `DiscreteTimelineQuot` is defined as:

```lean
def DiscreteTimelineQuot : Type :=
  Antisymmetrization (DiscreteTimelineElem root_mcs root_mcs_proof) (. <= .)
```

Where `DiscreteTimelineElem` is the subtype of `StagedPoint` in the timeline union.

**Critical Insight**: The order on `DiscreteTimelineQuot` is induced by `StagedPoint.le`:

```lean
def StagedPoint.le (a b : StagedPoint) : Prop :=
  a.mcs = b.mcs \/ CanonicalR a.mcs b.mcs
```

This means `[a] <= [b]` in the quotient iff there exist representatives `a', b'` with `a'.mcs = b'.mcs` or `CanonicalR a'.mcs b'.mcs`.

### 3. The Stage-Completeness Hypothesis

**Claim**: If `a, b` are in `discreteStagedBuild N`, and `c` is any element with `[a] <= [c] <= [b]` in the quotient, then `c` has a representative in `discreteStagedBuild N`.

**Intuition**: The discrete construction (unlike dense) never inserts "new" points between existing ones. All reachability relationships present at stage N are "closed" at stage N.

### 4. Why Stage-Completeness Should Hold

The key observation is about how `evenStage` works:

1. For each existing point `p` and formula `phi`, if `F(phi) in p.mcs`, we add a witness `w` with `CanonicalR p.mcs w.mcs`
2. This witness is the **unique** canonical witness for that obligation
3. No additional points are inserted between `p` and `w`

**Consequence**: If `[a] < [c] < [b]` in the quotient where `a, b` are at stage N, then:
- `c` must be related to both `a` and `b` via CanonicalR chains
- These chains must pass through points already in stage N (by linearity)
- Therefore `c` itself (or an equivalent MCS) must be in stage N

### 5. Proof Strategy: Stage-Bounded Interval Containment

**Main Theorem to Prove**:

```lean
theorem discrete_Icc_stage_bounded (a b : DiscreteTimelineQuot) :
    Set.Icc a b <=
    (discreteStagedBuild (max (minStage a) (minStage b))).image
      (Quotient.mk (antisymmRel (. <= .)) . Subtype.val)
```

**Strategy**:

1. Let `N = max (minStage a) (minStage b)`
2. By `minStage_spec`, we have representatives `a', b'` in `discreteStagedBuild N`
3. Let `c in Set.Icc a b`, so `a <= c <= b`
4. We need to show `c` is in the image of `discreteStagedBuild N`

**Step 4 Approach**:
- Use `Antisymmetrization.ind` to work with a representative `c'` of `c`
- Show that `c' in buildDiscreteStagedTimeline.union`
- Extract the stage `M` where `c'` was introduced
- Prove `M <= N` using the CanonicalR chain structure

### 6. Required Lemmas

#### Lemma 1: CanonicalR Chain Implies Stage Bound

```lean
lemma canonicalR_chain_stage_bound
    (a b : StagedPoint) (ha : a in discreteStagedBuild N) (hb : b in discreteStagedBuild N)
    (c : StagedPoint) (hc : c in buildDiscreteStagedTimeline.union)
    (hac : StagedPoint.le a c) (hcb : StagedPoint.le c b) :
    c in discreteStagedBuild N
```

**Proof Sketch**:
- The CanonicalR relation is built from formula obligations
- If `CanonicalR a.mcs c.mcs`, then `c` was added as a witness for some F-formula in `a.mcs`
- By the enumeration of formulas, this witness is added at or before stage `N`

#### Lemma 2: Quotient Image is Finite

```lean
lemma discreteStagedBuild_image_finite (N : Nat) :
    ((discreteStagedBuild N).image (Quotient.mk _ . Subtype.val)).Finite
```

This follows from `Finset.finite_toSet`.

#### Lemma 3: Finite Subset Implies Finite

```lean
lemma Set.Finite.subset : s.Finite -> t <= s -> t.Finite
```

Already in Mathlib.

---

## Proof Outline

```
discrete_Icc_finite a b
  := Set.Finite.subset
       (discreteStagedBuild_image_finite (max (minStage a) (minStage b)))
       (discrete_Icc_stage_bounded a b)
```

The key work is proving `discrete_Icc_stage_bounded`.

---

## Mathlib Lemmas to Use

| Lemma | Purpose |
|-------|---------|
| `Set.Finite.subset` | Prove finite from subset of finite |
| `Finset.finite_toSet` | Image of Finset is finite Set |
| `Antisymmetrization.ind` | Induction on quotient elements |
| `toAntisymmetrization_le_toAntisymmetrization_iff` | Quotient order characterization |
| `Quotient.mk_surjective` | Surjectivity of quotient map |

---

## Proof Obstacles and Risks

### Risk 1: CanonicalR Chain Structure (MEDIUM)
The argument that CanonicalR chains between a and b stay within stage N requires careful handling. The key insight is that the discrete construction is "closed" under CanonicalR - no new intermediate points are introduced.

### Risk 2: Formula Enumeration Timing (LOW)
The decodeFormulaStaged function enumerates formulas. We need to ensure that the formula responsible for the CanonicalR relation is processed by stage N.

### Risk 3: Quotient Lifting (LOW)
Working with Antisymmetrization requires careful handling of representatives. The proofs use `Antisymmetrization.ind` which is well-established.

---

## Alternative Approaches Considered

### Approach A: Direct Finiteness of Antisymmetrization
Try to prove that Antisymmetrization of a finite preorder is finite. This doesn't work directly because the preorder on DiscreteTimelineElem is over an infinite set (the union).

### Approach B: LocallyFiniteOrder from IsSuccArchimedean
Once SuccOrder and IsSuccArchimedean are established, LocallyFiniteOrder follows from Mathlib. However, this creates a circular dependency since LocallyFiniteOrder is needed to establish SuccOrder.

**Selected**: Primary strategy via stage-bounding is the correct approach.

---

## Implementation Recommendations

1. **Start with Lemma 1** (canonicalR_chain_stage_bound) - this is the core technical result

2. **Factor out helper lemmas**:
   - `discreteStagedBuild_contains_canonicalR_witness`: If F(phi) in p.mcs and p is in stage N, the witness is in stage N
   - `canonicalR_implies_formula_witness`: CanonicalR M N implies some F(phi) witnesses the relation

3. **Use the linearity infrastructure**: The staged construction maintains linearity at each stage (`discreteStagedBuild_linear`)

4. **Leverage monotonicity**: `discreteStagedBuild_monotone_le` ensures points persist across stages

---

## Confidence Assessment

| Aspect | Confidence | Notes |
|--------|------------|-------|
| Overall strategy | HIGH (85%) | Sound mathematical approach |
| Lemma 1 provability | MEDIUM-HIGH (75%) | Requires careful handling of formula enumeration |
| Mathlib integration | HIGH (90%) | Uses standard lemmas |
| Implementation effort | MEDIUM | 2-3 hours estimated |

---

## Files to Modify

1. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
   - Add `discrete_Icc_stage_bounded` theorem
   - Remove `discrete_Icc_finite_axiom`
   - Update `discrete_Icc_finite` to use the new theorem

2. `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
   - Add helper lemmas about CanonicalR witness stage bounds

---

## Conclusion

The proof of `discrete_Icc_stage_bounded` is achievable through the stage-completeness property of the discrete staged construction. The absence of density insertion means that all CanonicalR-related points are captured at the stage where the endpoints exist. The proof requires:

1. Proving that CanonicalR witnesses are added at predictable stages
2. Showing that any element between a and b in the quotient order must be such a witness
3. Using Mathlib's `Set.Finite.subset` to conclude finiteness

This eliminates the `discrete_Icc_finite_axiom` and completes the zero-axiom goal for the discrete timeline construction.
