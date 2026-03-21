# Torsor Construction Research Findings

**Task**: 1006 - canonical_taskframe_completeness
**Focus**: Torsor-based construction for duration domain D
**Date**: 2026-03-20
**Teammate**: A

---

## Key Findings

### 1. TranslationGroup.lean Status (Sorry-Free)

The existing `TranslationGroup.lean` in `Theories/Bimodal/Boneyard/Task956_IntRat/` is **fully sorry-free**. It proves:

**Proven Properties**:
- `AddGroup (TranslationGroup M₀ h_mcs₀)` via `RelIso.instGroup` + `Additive` wrapper
- `TranslationGroup.apply_zero`: Identity action (0 +v w = w)
- `TranslationGroup.apply_add`: Composition (d₁ + d₂).apply w = d₂.apply(d₁.apply w)
- `TranslationGroup.apply_neg_cancel_left/right`: Inverse cancellation
- `TranslationGroup.apply_injective`: Injectivity (from OrderIso)
- `TranslationGroup.apply_monotone`: Order-preservation (from OrderIso)
- `torsor_task_rel_nullity`: TaskFrame nullity
- `torsor_task_rel_compositionality`: TaskFrame compositionality
- `torsor_task_rel_deterministic`: Functional task relation
- `torsor_task_rel_reversible`: Negative duration reverses transition

**Construction Mechanism**:
```lean
abbrev TranslationGroup (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Additive (CanonicalTimeline M₀ h_mcs₀ ≃o CanonicalTimeline M₀ h_mcs₀)
```

The action uses the INVERSE convention: `d.apply w = (Additive.toMul d).symm w` to ensure compositionality works with `RelIso.instGroup`'s multiplication definition (`f * g = g.trans f`).

### 2. Deferred Properties (The Gap)

The file explicitly lists what is NOT proven:

| Property | Requirement | Status |
|----------|-------------|--------|
| `AddCommGroup D` | Holder's theorem | **DEFERRED** |
| `LinearOrder D` | eval-at-origin injectivity (rigidity) | **DEFERRED** |
| `IsOrderedAddMonoid D` | LinearOrder + order compatibility | **DEFERRED** |
| `AddTorsor D T` | Homogeneity (transitivity of action) | **DEFERRED** |

**Critical Insight**: TaskFrame requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. TranslationGroup.lean only provides `AddGroup`, not `AddCommGroup`.

### 3. Holder's Theorem Analysis

**Theorem** (Holder, 1901): If a group G acts freely and order-preservingly on a linearly ordered set, then G is abelian.

**Proof Strategy** (from research-005.md):
1. The ordering on G pulled back via eval at any point is **bi-invariant**
2. A bi-invariantly ordered group is abelian
3. This follows because: for any a, b in G, both a+b and b+a map the origin to the same point (since the action is free and the ordering is bi-invariant)

**Mathlib Status**: Holder's theorem is NOT directly available in Mathlib. However, the ingredients exist:
- `AddTorsor G P` provides the torsor structure
- `LinearOrder` transfer via `LinearOrder.lift` and `Equiv.vaddConst`
- The commutativity proof must be done manually for our case

**Key Formula** (why commutativity follows from order-preservation):
If the action of G on T is free and order-preserving, and T is linearly ordered, then for d₁, d₂ ∈ G:
- Define `d₁ ≤ d₂` iff `d₁(w₀) ≤ d₂(w₀)` for any base point w₀
- This order is bi-invariant: `d₁ ≤ d₂ ⟹ d + d₁ ≤ d + d₂` AND `d₁ + d ≤ d₂ + d`
- Bi-invariance + totality implies commutativity (Levi's theorem for ordered groups)

### 4. Homogeneity Requirement (AddTorsor D T)

**Definition**: The action of D on T is **homogeneous** (transitive) if: ∀ a b ∈ T, ∃ d ∈ D such that d.apply(a) = b.

**Why It's Hard**: Homogeneity requires a **back-and-forth argument** using the existence lemma. Given any two MCSs a, b in the canonical timeline, we must construct an order automorphism mapping a to b.

**Prior Research Assessment** (research-005.md):
- **Strategy A (Direct)**: Construct automorphism via transfinite back-and-forth (works for countable T)
- **Strategy B (Axiom uniformity)**: Use model-theoretic argument that temporal axioms are uniform
- **Strategy C (FMCS-based)**: Define torsor structure directly from FMCS coherence

**Recommended**: Strategy C - The FMCS structure already provides `mcs : D → Set Formula` which IS the group action. Instead of constructing Aut+(T) from scratch, extract D from FMCS.

### 5. Alternative Construction: D as Difference Group

From research-005.md, an alternative formulation:

```
D = T × T / ~
where (a, b) ~ (c, d) iff "displacement from a to b equals displacement from c to d"
```

Group operations:
- Addition: [(a, b)] + [(b, c)] = [(a, c)]
- Zero: [(a, a)]
- Negation: -[(a, b)] = [(b, a)]

**Advantage**: Avoids explicit automorphism construction.
**Challenge**: Well-definedness circles back to homogeneity.

### 6. Current Dense Completeness Path (Task 956/1006 Context)

From research-049.md, the **dense completeness pipeline is FULLY PROVEN**:
- `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` - PROVEN
- `DenselyOrdered TimelineQuot` - PROVEN
- `NoMaxOrder`, `NoMinOrder` - PROVEN

The Cantor isomorphism provides a **different** path to AddCommGroup:
1. `TimelineQuot ≃o Rat` (Cantor's theorem, proven)
2. Transfer `AddCommGroup` from `Rat` to `TimelineQuot` via the isomorphism
3. This gives AddCommGroup **without proving Holder's theorem**

**This is the approach used in DovetailedTimelineQuot.lean**:
```lean
noncomputable def dovetailedTimelineQuotAddCommGroup :
    AddCommGroup (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  ratAddCommGroup (DovetailedTimelineQuot root_mcs root_mcs_proof)
```

---

## Recommended Approach

### For Task 1006 Completeness

**Primary Path**: Use the **Cantor isomorphism transfer** rather than proving Holder's theorem directly.

1. The dense pipeline already proves `TimelineQuot ≃o Rat`
2. Transfer `AddCommGroup` from `Rat` via `Equiv.addCommGroup`
3. Transfer `LinearOrder` and `IsOrderedAddMonoid` similarly
4. This sidesteps the torsor homogeneity proof entirely

**Why Not Torsor Approach**:
- Homogeneity proof is non-trivial (back-and-forth construction)
- Holder's theorem formalization adds complexity
- Cantor transfer is already working in Boneyard code

### If Torsor Approach Is Preferred

1. **Prove Rigidity First**: Show that if f ∈ Aut+(T) fixes any point, then f = id. This follows from connectivity of linear orders without endpoints.

2. **Prove Homogeneity**: Use back-and-forth on countable T. For any a, b ∈ T:
   - Enumerate T = {t₀, t₁, t₂, ...}
   - Build partial isomorphisms fₙ : Xₙ → Yₙ with a ∈ X₀, b ∈ Y₀
   - Extend to cover tₙ at each step
   - Union gives total automorphism

3. **Derive Commutativity**: Once homogeneity + rigidity are proven:
   - Define order on D via eval-at-origin
   - Show bi-invariance
   - Apply Levi's theorem (bi-invariant ordered group is abelian)

---

## Evidence/Examples

### Existing Infrastructure Supporting Cantor Transfer

From `DovetailedTimelineQuot.lean` (Boneyard):
```lean
-- AddCommGroup structure transferred from Q via Cantor isomorphism
noncomputable def dovetailedTimelineQuotAddCommGroup :
    AddCommGroup (DovetailedTimelineQuot root_mcs root_mcs_proof) :=
  ratAddCommGroup (DovetailedTimelineQuot root_mcs root_mcs_proof)

-- IsOrderedAddMonoid structure transferred from Q
theorem dovetailedTimelineQuotIsOrderedAddMonoid :
    @IsOrderedAddMonoid (DovetailedTimelineQuot root_mcs root_mcs_proof)
      (dovetailedTimelineQuotAddCommGroup root_mcs root_mcs_proof).toAddCommMonoid
```

### Mathlib Support for Torsor Approach

From `Mathlib.Algebra.AddTorsor.Defs`:
- `AddTorsor G P` class with `vadd`, `vsub`
- `Equiv.vaddConst (p : P) : G ≃ P` (eval-at-p map)
- `Equiv.constVSub (p : P) : P ≃ G` (difference-from-p map)

From `Mathlib.Algebra.Order.Group.End`:
- `Group (α ≃o α)` instance for order automorphisms
- Can wrap with `Additive` to get `AddGroup`

---

## Confidence Level

**High Confidence**:
- Cantor transfer approach will work (code exists in Boneyard)
- TranslationGroup.lean is correctly structured (sorry-free for what it claims)
- AddGroup structure is immediate from Mathlib

**Medium Confidence**:
- Homogeneity proof via back-and-forth is feasible but non-trivial
- Holder's theorem can be formalized in ~50-100 lines

**Low Confidence**:
- Whether the torsor approach provides any advantage over Cantor transfer for Task 1006's goals

---

## Summary Recommendation

**Use the Cantor isomorphism transfer approach** for Task 1006. The dense completeness pipeline already has `TimelineQuot ≃o Rat` proven, and transferring algebraic structure from Rat is straightforward. The torsor/TranslationGroup approach is mathematically elegant but adds proof obligations (homogeneity, Holder) that are not on the critical path.

If future tasks require the pure-torsor construction (e.g., for base completeness without density axioms), the TranslationGroup.lean file provides a solid foundation - just add homogeneity and commutativity proofs.
