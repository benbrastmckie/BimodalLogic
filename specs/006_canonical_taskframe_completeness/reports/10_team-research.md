# Research Report: Parametric D Construction via Torsor and Alternative Approaches

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Mode**: Team Research (2 teammates)
**Session**: sess_1774029403_f41681
**Focus**: Constructing a parametric D with AddCommGroup structure, torsor-based approaches, and deriving density/discreteness from logic axioms

## Executive Summary

The completeness proof requires a duration domain D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. CanonicalMCS has sorry-free F/P properties but lacks this algebraic structure. Two main paths exist:

1. **Torsor/TranslationGroup approach**: Define D = Aut+(T) where T is the canonical timeline. Proven: AddGroup. Missing: AddCommGroup (requires Holder's theorem) + homogeneity (AddTorsor).

2. **Cantor isomorphism transfer**: For dense logics, TimelineQuot ≃o Rat is already proven, allowing direct transfer of AddCommGroup from Rat.

**Key insight**: The task relation only uses the SIGN of d, not its magnitude. This suggests the algebraic structure is a frame-level requirement rather than semantically essential.

**Recommendation**: For dense completeness, use Cantor transfer (simpler, already working). For base completeness without density axioms, the torsor approach could provide D from pure syntax - but requires proving homogeneity and Holder's theorem.

---

## Team Contributions

| Teammate | Focus | Key Finding | Confidence |
|----------|-------|-------------|------------|
| A | Torsor construction | TranslationGroup.lean is sorry-free for AddGroup; Cantor transfer bypasses Holder | High |
| B | Alternative approaches | Core blocker is structural; parametric_to_history with full domain is cleanest path | Medium-High |

No conflicts between teammates. Both converge on avoiding direct CanonicalMCS -> AddCommGroup transfer.

---

## Key Findings

### 1. TranslationGroup Construction Status

**What Exists** (sorry-free in `TranslationGroup.lean`):
```lean
TranslationGroup M₀ h_mcs₀ := Additive (CanonicalTimeline M₀ h_mcs₀ ≃o CanonicalTimeline M₀ h_mcs₀)
```

| Property | Status | Proof Method |
|----------|--------|--------------|
| AddGroup | PROVEN | `RelIso.instGroup` + `Additive` wrapper |
| apply_zero (identity) | PROVEN | reflexivity |
| apply_add (composition) | PROVEN | `RelIso.trans` definition |
| apply_neg_cancel | PROVEN | `OrderIso.symm` |
| torsor_task_rel_nullity | PROVEN | From apply_zero |
| torsor_task_rel_compositionality | PROVEN | From apply_add |

**What's Missing** (deferred):

| Property | Requirement | Blocking Issue |
|----------|-------------|----------------|
| AddCommGroup | Holder's theorem | Needs freeness + bi-invariant order |
| LinearOrder D | Rigidity of action | eval-at-origin must be injective |
| IsOrderedAddMonoid | LinearOrder + compatibility | Depends on above |
| AddTorsor D T | Homogeneity | ∀ a b ∈ T, ∃ d such that d.apply a = b |

### 2. Holder's Theorem Path

**Theorem** (Holder, 1901): If a group G acts freely and order-preservingly on a linearly ordered set, then G is abelian.

**Proof requirements**:
1. **Rigidity**: If f ∈ Aut+(T) fixes any point, then f = id
2. **Order transfer**: Define d₁ ≤ d₂ iff d₁(w₀) ≤ d₂(w₀) for base point w₀
3. **Bi-invariance**: This order is bi-invariant (translation-stable)
4. **Commutativity**: Bi-invariant + total order implies abelian (Levi's theorem)

**Mathlib support**: The building blocks exist but Holder's theorem must be manually proven (~50-100 lines estimated).

### 3. Homogeneity Requirement

For `AddTorsor D T` (the torsor structure):
- **Requirement**: The action is transitive - for any a, b ∈ T, there exists d ∈ D with d.apply(a) = b
- **Proof approach**: Back-and-forth construction for countable T
  1. Enumerate T = {t₀, t₁, ...}
  2. Build partial isomorphisms fₙ : Xₙ → Yₙ with a ∈ X₀, b ∈ Y₀
  3. Extend alternately to cover new points
  4. Union gives total automorphism mapping a to b

**Complexity**: Non-trivial but feasible for countable T.

### 4. The Structural Blocker

The core tension (from 09_fp-crux-analysis.md):

1. **CanonicalR is not total**: Not every pair of MCSes is comparable
2. **Linear chains require totality**: FMCS over linearly ordered D needs consecutive MCSes to be CanonicalR-related
3. **F-witnesses are "off-chain"**: Witness from canonical_forward_F is CanonicalR-accessible from source but not necessarily from other chain elements

This is NOT a formalization artifact - it's a genuine mathematical obstruction affecting all omega-saturation constructions.

### 5. Task Relation Uses Only Sign of d

From `ParametricCanonical.lean`:
```lean
parametric_canonical_task_rel M d N :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

**Implication**: The AddCommGroup structure is used by frame axioms (nullity_identity, forward_comp, converse) but NOT by temporal operator evaluation. All positive durations are semantically equivalent.

### 6. Cantor Isomorphism Transfer (Alternative to Torsor)

For dense completeness, a simpler path exists:
1. Prove `DovetailedTimelineQuot ≃o Rat` (Cantor's theorem - PROVEN)
2. Transfer `AddCommGroup` from `Rat` via `Equiv.addCommGroup`
3. Transfer `LinearOrder` and `IsOrderedAddMonoid` similarly

This bypasses Holder's theorem and homogeneity proofs entirely.

---

## Synthesis: Deriving Structure from Axioms

### The User's Vision

> "Once a general D can be constructed, the next steps are to derive density or discreteness by adding appropriate axioms to the logic. That way the structure of time emerges from the logic rather than being imposed onto it."

### How This Would Work

**Base Logic** (15 axioms, no density/discreteness):
- D = TranslationGroup (order automorphisms)
- Structure emerges from CanonicalR (reflexive-transitive closure of modal accessibility)
- No guarantee of density or discreteness - both are compatible

**Dense Logic** (+DN axiom):
- DN axiom: `□ □ p → □ □ □ p` (or equivalent density axiom)
- This forces the canonical timeline to be densely ordered
- D = Rat (via Cantor isomorphism from countable dense without endpoints)
- Density is a **theorem** about models of the dense axioms

**Discrete Logic** (+DF/DB + seriality):
- DF: `F p → F (G ¬p ∧ F p)` (immediate future exists)
- DB: `P p → P (H ¬p ∧ P p)` (immediate past exists)
- These force the canonical timeline to be discretely ordered
- D = Int (via characterization theorem)
- Discreteness is a **theorem** about models of the discrete axioms

### The Torsor Approach Supports This Vision

If we pursue the torsor construction:
1. **D emerges from syntax**: D = Aut+(CanonicalTimeline), not assumed to be Int/Rat
2. **Structure is derived**: Density/discreteness of D follows from density/discreteness of CanonicalTimeline, which follows from axioms
3. **No external algebraic structure imported**: The AddCommGroup comes from Holder's theorem applied to the order automorphism group

This is philosophically cleaner than using Int/Rat directly, but requires proving:
- Homogeneity (for AddTorsor, enabling Holder)
- Holder's theorem (freeness + order → abelian)

---

## Recommendations

### Path 1: Dense Completeness (Recommended for Task 1006)

Use **Cantor isomorphism transfer**:
1. DovetailedBuild produces countable, dense, no-endpoint timeline
2. Cantor's theorem gives TimelineQuot ≃o Rat (PROVEN)
3. Transfer AddCommGroup from Rat
4. Apply parametric_to_history with full domain
5. Wire to dense_completeness

**Effort**: Low (infrastructure exists)

### Path 2: Base Completeness

Two options:

**Option A**: Reuse dense construction with Rat
- Base-valid formulas are dense-valid (conservative extension)
- A Rat countermodel for unprovable phi suffices

**Option B**: Full torsor construction
- Prove homogeneity via back-and-forth
- Prove Holder's theorem for commutativity
- Gives D from pure syntax, no external structure

**Effort**: Option A is low; Option B is medium-high but philosophically satisfying

### Path 3: Discrete Completeness

Use discreteStagedBuild + characterization:
1. Build discrete timeline with DF/DB saturation
2. Prove LocallyFiniteOrder (from discrete axioms)
3. Apply characterization theorem: countable discrete without endpoints ≃o Z
4. Transfer AddCommGroup from Int

**Effort**: Medium (characterization theorem may need axiom or proof)

---

## Gaps Identified

1. **Holder's theorem formalization**: Not in Mathlib, needs manual proof
2. **Back-and-forth homogeneity proof**: Standard but not yet implemented
3. **Flag saturation lemma**: Needed if pursuing flag-based F/P construction
4. **DovetailedBuild F/P verification**: Plan v4 Phase 1 must verify witnesses are in-timeline

---

## Conclusion

The torsor approach (TranslationGroup as D) is viable and would make D emerge from the logic's axioms. The key missing pieces are homogeneity (AddTorsor) and Holder's theorem (AddCommGroup). For practical progress on Task 1006, the Cantor transfer approach is recommended as it requires less new infrastructure. However, the torsor approach remains valuable for the philosophical goal of deriving time structure from axioms.

---

## References

- `TranslationGroup.lean` - Existing torsor construction (AddGroup proven)
- `09_fp-crux-analysis.md` - Detailed structural blocker analysis
- `research-005.md` (Task 956) - Original torsor research
- `ParametricCanonical.lean` - Sign-only task relation
- `DovetailedTimelineQuot.lean` - Cantor transfer implementation
