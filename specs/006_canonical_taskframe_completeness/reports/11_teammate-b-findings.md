# Torsor Approach Feasibility and Blockers Analysis

**Task**: 1006 - canonical_taskframe_completeness
**Focus**: Torsor/TranslationGroup feasibility, Holder's theorem, homogeneity blockers
**Date**: 2026-03-20
**Teammate**: B

---

## Key Findings

### 1. Holder's Theorem Requirements

**What It Proves**: If a group G acts freely and order-preservingly on a linearly ordered set T, then G is abelian.

**Proof Requirements**:
1. **Rigidity (Freeness)**: If f in Aut+(T) fixes any point, then f = id
2. **Order on G**: Define d1 <= d2 iff d1(w0) <= d2(w0) for any base point w0
3. **Bi-invariance**: This order is translation-stable (both left and right)
4. **Levi's Theorem**: Bi-invariant + total order implies commutativity

**Mathlib Status**:
- `OrderIso.trans`, `OrderIso.symm` exist (needed for Group structure)
- `Additive` wrapper converts multiplicative group to additive
- `LinearOrder.lift` can transfer order from T to D
- **Holder's theorem NOT in Mathlib** - must prove manually

**Estimated Complexity**: 50-100 lines of Lean for full proof chain:
- Rigidity: ~15-20 lines (use no-endpoint + connectivity)
- Order well-definedness: ~10 lines
- Bi-invariance: ~20-30 lines (key technical step)
- Commutativity: ~15-20 lines (apply bi-invariance)

### 2. Homogeneity (AddTorsor) Requirements

**Definition**: For any a, b in T, exists d in D such that d.apply(a) = b.

**Back-and-Forth Construction** (for countable T):
```
Input: a, b in T
Output: f in Aut+(T) with f(a) = b

1. Enumerate T = {t0, t1, t2, ...}
2. Initialize: f0 = {(a, b)} (partial iso)
3. For n = 0, 1, 2, ...:
   - FORTH: If tn not in domain(fn), extend fn to cover tn
   - BACK: If tn not in range(fn), extend fn-1 to cover tn
4. f = union of all fn
```

**Technical Challenges**:
- Extension step requires finding extension points that preserve order
- For dense T without endpoints: always possible (Cantor's theorem ingredients)
- For discrete T: may need different argument

**Estimated Complexity**: 100-150 lines:
- Partial isomorphism definition: ~20 lines
- Extension lemmas: ~40-50 lines
- Induction/recursion: ~40-50 lines
- Final assembly: ~20 lines

### 3. Countability of CanonicalTimeline/BidirectionalQuotient

**Current Status**: `Countable (BidirectionalQuotient M0 h_mcs0)` is **NOT directly proven** in TranslationGroup.lean.

**Where It IS Proven**: In `ConstructiveFragment.lean`:
```lean
noncomputable instance : Countable (ConstructiveFragment M0 h_mcs0) := by
  apply Function.Injective.countable
    (f := fun (w : ConstructiveFragment M0 h_mcs0) => w.property.some.encode)
  ...

noncomputable instance : Countable (ConstructiveQuotient M0 h_mcs0) :=
  -- From antisymmetrization of countable type
```

**Key Insight**: Formula is countable, paths are finite sequences, so the reachable fragment is countable. However:
- BidirectionalReachable may reach **more** MCSes than ConstructiveReachable
- Need to verify they're the same or prove countability separately for BidirectionalQuotient

**Potential Blocker**: If BidirectionalReachable includes MCSes not constructively reachable, countability could fail. However, MCSes are determined by their formula membership, and there are only countably many formulas, so this should be safe.

### 4. Density/Discreteness of BidirectionalQuotient

**For Dense Logic**: The timeline should be dense (from DN axiom saturation)
- Research shows DovetailedTimelineQuot satisfies `DenselyOrdered` (proven)
- BidirectionalQuotient should inherit this from density axiom saturation

**For Discrete Logic**: The timeline should be discrete (from DF/DB axioms)
- Discrete axioms force immediate successor/predecessor structure
- `LocallyFiniteOrder` should follow from DF/DB saturation
- Currently **axiomatized** in DiscreteTimeline.lean (`discrete_Icc_finite_axiom`)

**For Base Logic**: Neither dense nor discrete is forced
- Timeline could be either, depending on which MCSes are reachable
- This is the problematic case for the torsor approach

### 5. Circular Dependency Analysis

**Dependency Chain**:
```
TaskFrame D requires:
  <- AddCommGroup D (from Holder)
    <- Rigidity (from homogeneity? NO - from no-fixed-points)
    <- Bi-invariant order (from order-preservation of Aut+(T))
  <- AddTorsor D T (homogeneity)
    <- Back-and-forth construction
    <- Countable T (for enumeration)
    <- No endpoints (for extension)
    <- LinearOrder T (proven from antisymmetrization)
```

**No Circularity Detected**:
- Holder's theorem does NOT require AddTorsor
- Rigidity comes from freeness of action, not homogeneity
- The two main requirements (Holder + homogeneity) are independent

### 6. Comparison: Torsor vs Cantor Transfer

| Aspect | Torsor Approach | Cantor Transfer |
|--------|-----------------|-----------------|
| **Works for** | Base, dense, discrete | Dense only |
| **Requires proving** | Holder + homogeneity | Nothing new (proven) |
| **D construction** | D = Aut+(T) | D = Rat via isomorphism |
| **Philosophical appeal** | Structure from syntax | Externally imposed |
| **Effort estimate** | 150-250 lines | 0 (exists in Boneyard) |
| **Risk** | Medium (new proofs) | Low (working code) |
| **Base completeness** | Native | Requires separate path |

### 7. Hidden Sorries and Blockers

**TranslationGroup.lean**: Fully sorry-free for what it claims (AddGroup, basic properties)

**BidirectionalReachable.lean**: Located in Boneyard at `/Theories/Bimodal/Boneyard/Task956_IntRat/BidirectionalReachable.lean`. Key theorems:
- `canonical_forward_reachable_linear` - PROVEN (no sorry)
- `canonical_backward_reachable_linear` - PROVEN
- `bidirectional_totality` - PROVEN (LinearOrder on fragment)
- `forward_F_stays_in_fragment` - PROVEN
- `backward_P_stays_in_fragment` - PROVEN

**Critical Gap**: F/P witness staying in **chain** (not just fragment):
- F-witness is CanonicalR-accessible from source MCS
- But may not be in the same linear chain as other elements
- This is the "off-chain" blocker documented in 09_fp-crux-analysis.md

### 8. What Happens if Homogeneity Fails for Base Logic

If base logic timeline is **not homogeneous** (e.g., has fixed points under all automorphisms):

**Consequences**:
- D = Aut+(T) would be trivial or small
- Cannot use D as duration domain (needs transitive action)
- Torsor structure fails

**Mitigations**:
- For base completeness: fall back to Cantor transfer (treat base as conservative extension of dense)
- Accept axiom: assume base timeline satisfies homogeneity
- Different construction: use parametric D without deriving from automorphisms

**Assessment**: This is a real concern for base logic. The torsor approach may only work cleanly for dense/discrete where saturation ensures rich structure.

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Holder proof more complex than estimated | Low | Medium | Use Mathlib OrderedGroup infrastructure |
| Homogeneity proof fails | Low | High | Fall back to Cantor transfer |
| Countability not proven | Low | Medium | Follow ConstructiveFragment pattern |
| Base logic lacks homogeneity | Medium | Medium | Use conservative extension argument |
| Circular dependency discovered | Low | High | Re-examine dependency chain |

**Overall Success Probability for Torsor Approach**: 70-80%

The main uncertainty is whether base logic timelines are sufficiently structured for homogeneity. For dense completeness specifically, the Cantor transfer is lower risk.

---

## Recommended Approach

### For Task 1006 (Dense Completeness)

**Primary**: Use **Cantor isomorphism transfer** (already proven in Boneyard)
- DovetailedTimelineQuot ≃o Rat (PROVEN)
- Transfer AddCommGroup, LinearOrder, IsOrderedAddMonoid from Rat
- Zero new proof obligations

### For Base Completeness (Future)

**Option A** (Simpler): Conservative extension argument
- Prove base-valid formulas are dense-valid
- Use dense completeness with Rat
- ~20 lines to establish conservative extension

**Option B** (More work but cleaner): Full torsor construction
- Prove Holder's theorem (~80 lines)
- Prove homogeneity via back-and-forth (~100 lines)
- Gives D from pure syntax
- Satisfies "structure from axioms" philosophy

### For Discrete Completeness

Use characterization theorem approach:
- DiscreteTimelineQuot ≃o Int (from countable discrete without endpoints)
- Transfer AddCommGroup from Int
- Accept `discrete_Icc_finite_axiom` or prove it

---

## Evidence/Examples

### Rigidity Proof Sketch

```lean
theorem automorphism_rigidity (f : T ≃o T) (t : T) (hf : f t = t) : f = OrderIso.refl T := by
  -- T is linearly ordered without endpoints
  -- If f(t) = t but f ≠ id, then ∃ s with f(s) ≠ s
  -- WLOG f(s) > s. Then for all s' > s, f(s') > s' (order preservation)
  -- But T has no max, so f moves all sufficiently large elements up
  -- Contradiction: f is surjective but image misses elements between t and f(s)
  sorry -- actual proof in ~15-20 lines
```

### Homogeneity Extension Step Sketch

```lean
-- For dense T: between any two points, there's a third
-- So partial isomorphism can always be extended
theorem extend_partial_iso (f : Finset T → T) (hf : StrictMono f)
    (t : T) (ht : t ∉ f.domain) :
    ∃ f' : Finset T → T, f ⊆ f' ∧ t ∈ f'.domain ∧ StrictMono f' := by
  -- Find position of t relative to domain elements
  -- Insert at appropriate position using density
  sorry
```

---

## Confidence Level

**High Confidence**:
- Cantor transfer approach works (code exists)
- No circular dependencies in torsor approach
- Countability follows standard patterns

**Medium Confidence**:
- Holder's theorem formalization is feasible
- Homogeneity via back-and-forth is standard

**Lower Confidence**:
- Base logic timeline has homogeneous automorphism group
- Effort estimates are accurate

---

## Summary

The torsor approach (D = Aut+(T)) is **theoretically viable** but requires proving:
1. Holder's theorem (~80 lines, no Mathlib support)
2. Homogeneity via back-and-forth (~100 lines)
3. Countability (pattern exists in ConstructiveFragment.lean)

**For Task 1006 dense completeness**, the Cantor transfer is strongly recommended as it requires no new proofs. The torsor approach should be deferred to a separate task focused on base completeness with "structure from axioms" philosophy.

The key blocker remains the F/P infrastructure ("off-chain" witness problem), which affects both approaches equally. This is documented in 09_fp-crux-analysis.md and is the crux of Phase 1 in plan v4.
