# Implementation Plan: Task #1006 (v5)

- **Task**: 1006 - canonical_taskframe_completeness
- **Version**: 05 (Torsor Construction Approach)
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (bypasses v4 blockers)
- **Research Inputs**:
  - `12_torsor-construction-full.md` - Complete torsor mathematical development
  - `11_pure-syntax-d-vs-parametric.md` - Pure-syntax D construction rationale
- **Artifacts**: `plans/05_torsor-construction-plan.md` (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Construct a canonical TaskFrame using D = Aut+(T) where T is the BidirectionalQuotient (canonical timeline). This approach derives D structure axiomatically from T's properties rather than transferring from concrete Rat/Int, bypassing the v4 Phase 1 blocker (DovetailedTimelineQuot FMCS coverage theorems).

**Key Mathematical Components**:
1. **Rigidity**: If f : T ≃o T fixes any point, then f = id (enables antisymmetry on D)
2. **Homogeneity**: For any a, b ∈ T, exists f with f(a) = b (enables vsub for AddTorsor)
3. **Holder's Theorem**: Free + order-preserving action implies abelian (enables AddCommGroup)

**Why This Bypasses v4 Blockers**: The v4 plan attempted to prove `forward_F`/`backward_P` via DovetailedTimelineQuot FMCS coverage theorems. The torsor approach instead derives the full D structure directly from T = BidirectionalQuotient, using only base-logic properties (LinearOrder, NoMaxOrder, NoMinOrder) plus density axiom (+DN) for the dense case.

### Research Integration

From `12_torsor-construction-full.md`:
- D = Additive(T ≃o T) with group structure from RelIso.instGroup (Section 2)
- Rigidity proof via orbit argument (Section 3)
- Homogeneity via back-and-forth construction (Section 4)
- Holder's theorem for commutativity (Section 5)
- LinearOrder D via eval-at-origin (Section 6)
- AddTorsor D T from rigidity + homogeneity (Section 7)
- TaskFrame assembly (Section 8)
- Dependency graph and estimates (Section 9)

## Goals & Non-Goals

**Goals**:
- Prove rigidity theorem for order automorphisms on T
- Prove homogeneity (transitivity of action) for dense case
- Prove Holder's theorem deriving AddCommGroup D from freeness
- Establish LinearOrder D and IsOrderedAddMonoid D
- Establish AddTorsor D T
- Construct TaskFrame D with sorry-free nullity, compositionality, converse
- Wire to completeness for dense logic (+DN case, D ~ Rat)

**Non-Goals**:
- Discrete case completeness (task 989 scope)
- Proving DenselyOrdered T (already in DovetailedBuild)
- Modifying WorldHistory convexity (parametric_to_history uses full domain)
- Conservative extension proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Rigidity orbit argument hard to formalize | H | M | Standard textbook proof, multiple reference formulations available |
| Homogeneity requires modified back-and-forth | M | M | Cantor's theorem in Mathlib is close; may need custom proof |
| Holder's theorem proof complexity | M | L | Well-documented standard result with clean proof sketch |
| DiscreteCase infrastructure gaps | L | N/A | Dense case priority; discrete deferred to task 989 |
| Connection to existing FMCS infrastructure | M | L | parametric_to_history already handles full-domain case |

## Implementation Phases

### Phase 1: Rigidity Theorem [BLOCKED]

**Goal**: Prove that any order automorphism fixing a point is the identity.

**Mathematical Statement**:
```lean
theorem orderIso_eq_id_of_fixedPt
    (T : Type*) [LinearOrder T] [NoMaxOrder T] [NoMinOrder T]
    (f : T ≃o T) (t₀ : T) (h : f t₀ = t₀) : f = OrderIso.refl T
```

**Approach**: Orbit argument from research Section 3.3:
1. If f ≠ id, exists s with f(s) ≠ s
2. WLOG f(s) > s, form orbit {fⁿ(s) : n ∈ Z}
3. Orbit is Z-like (unbounded above and below by NoMaxOrder/NoMinOrder)
4. Fixed point t₀ must lie between consecutive orbit elements
5. Order-preservation of f leads to contradiction

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/Rigidity.lean`
- [ ] Prove `orbit_strictly_increasing` lemma
- [ ] Prove `orbit_unbounded_above` and `orbit_unbounded_below`
- [ ] Prove `fixedPt_between_orbit_contradiction`
- [ ] Assemble main `orderIso_eq_id_of_fixedPt` theorem
- [ ] Derive `TranslationGroup.freeness` corollary for D

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/Rigidity.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.Rigidity` passes
- No sorries in rigidity theorem

**Estimated effort**: 2 hours

---

### Phase 2: Homogeneity via Back-and-Forth [NOT STARTED]

**Goal**: Prove transitivity of the action - for any a, b ∈ T, exists f : T ≃o T with f(a) = b.

**Mathematical Statement**:
```lean
theorem exists_orderIso_sending
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T]
    (a b : T) : ∃ f : T ≃o T, f a = b
```

**Approach**: Modified Cantor back-and-forth from research Section 4.2:
1. Enumerate T = {t₀, t₁, ...} with t₀ = a
2. Build partial isomorphisms fₙ : Xₙ → Yₙ with f₀(a) = b
3. Alternate forth (extend domain) and back (extend codomain) steps
4. At each step, density guarantees intermediate point existence
5. Union f = ⋃ₙ fₙ is total order isomorphism with f(a) = b

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/Homogeneity.lean`
- [ ] Define partial isomorphism type and extension operations
- [ ] Prove extension step validity using density/seriality
- [ ] Prove back-and-forth convergence to total isomorphism
- [ ] Assemble main `exists_orderIso_sending` theorem
- [ ] Instantiate for CanonicalTimeline (verify instances: Countable, DenselyOrdered, etc.)

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/Homogeneity.lean`
- May modify: `Theories/Bimodal/Boneyard/Task956_IntRat/BidirectionalReachable.lean` (add instances)

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.Homogeneity` passes
- No sorries in homogeneity theorem
- CanonicalTimeline satisfies all required instances

**Estimated effort**: 2.5 hours

---

### Phase 3: Holder's Theorem (Commutativity) [NOT STARTED]

**Goal**: Prove that a free order-preserving group action on a linear order implies commutativity.

**Mathematical Statement**:
```lean
theorem holder_theorem
    (G : Type*) (T : Type*) [AddGroup G] [LinearOrder T]
    [NoMaxOrder T] [NoMinOrder T]
    (act : G → T ≃o T)
    (h_hom : ∀ g₁ g₂, act (g₁ + g₂) = (act g₂).trans (act g₁))
    (h_free : ∀ g t, (act g) t = t → g = 0) :
    ∀ g₁ g₂ : G, g₁ + g₂ = g₂ + g₁
```

**Approach**: From research Section 5.2:
1. Define order on G via eval-at-origin: g₁ ≤ g₂ iff g₁(t₀) ≤ g₂(t₀)
2. Prove order is well-defined (independent of t₀) using freeness
3. Prove bi-invariance of order
4. Show commutator [g, h] = g + h - h - g fixes t₀ for any t₀
5. By freeness, [g, h] = 0, hence g + h = h + g

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/HolderTheorem.lean`
- [ ] Define `evalOrder` on group elements via base point
- [ ] Prove `evalOrder_wellDefined` (independence of base point)
- [ ] Prove `evalOrder_leftInvariant` and `evalOrder_rightInvariant`
- [ ] Prove `commutator_fixes_origin`
- [ ] Derive `holder_theorem` from freeness
- [ ] Instantiate `AddCommGroup (TranslationGroup M₀ h_mcs₀)`

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/HolderTheorem.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.HolderTheorem` passes
- `AddCommGroup (TranslationGroup M₀ h_mcs₀)` compiles without sorry

**Estimated effort**: 2 hours

---

### Phase 4: LinearOrder and IsOrderedAddMonoid on D [NOT STARTED]

**Goal**: Establish LinearOrder D and IsOrderedAddMonoid D from rigidity and bi-invariance.

**Mathematical Statements**:
```lean
noncomputable instance instLinearOrderTranslationGroup :
    LinearOrder (TranslationGroup M₀ h_mcs₀)

instance instIsOrderedAddMonoidTranslationGroup :
    IsOrderedAddMonoid (TranslationGroup M₀ h_mcs₀)
```

**Approach**: From research Section 6:
1. Define d₁ ≤ d₂ iff d₁ +ᵥ origin ≤ d₂ +ᵥ origin
2. Reflexivity/transitivity/totality: from T's order
3. Antisymmetry: from rigidity (if d₁ +ᵥ origin = d₂ +ᵥ origin, then d₁⁻¹ ∘ d₂ fixes origin, so d₁ = d₂)
4. IsOrderedAddMonoid: from bi-invariance (Holder proof step 2)

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TranslationGroupOrder.lean`
- [ ] Define `translationGroupLE` using eval-at-origin
- [ ] Prove Preorder properties (refl, trans)
- [ ] Prove `le_antisymm` using rigidity
- [ ] Prove `le_total` from T's totality
- [ ] Assemble `LinearOrder` instance
- [ ] Prove `add_le_add_left` and `add_le_add_right` from bi-invariance
- [ ] Assemble `IsOrderedAddMonoid` instance

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/TranslationGroupOrder.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TranslationGroupOrder` passes
- Both instances compile without sorry

**Estimated effort**: 1.5 hours

---

### Phase 5: AddTorsor D T [NOT STARTED]

**Goal**: Establish AddTorsor D T from rigidity (uniqueness of vsub) and homogeneity (existence of vsub).

**Mathematical Statement**:
```lean
noncomputable instance instAddTorsorTranslationGroup :
    AddTorsor (TranslationGroup M₀ h_mcs₀) (CanonicalTimeline M₀ h_mcs₀)
```

**Approach**: From research Section 7:
1. `vadd d w := d.apply w` (already defined in TranslationGroup.lean)
2. `vsub w₁ w₂ := Classical.choose (exists_orderIso_sending w₂ w₁)` (from homogeneity)
3. `vsub_vadd'`: by definition of Classical.choose
4. `vadd_vsub'`: uniqueness from rigidity

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TranslationGroupTorsor.lean`
- [ ] Define `translationGroupVSub` using Classical.choose from homogeneity
- [ ] Prove `vsub_vadd'` from choose_spec
- [ ] Prove `vadd_vsub'` from rigidity (uniqueness)
- [ ] Assemble `AddTorsor` instance

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/TranslationGroupTorsor.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.TranslationGroupTorsor` passes
- AddTorsor instance compiles without sorry

**Estimated effort**: 1.5 hours

---

### Phase 6: TaskFrame Construction and Completeness Wiring [NOT STARTED]

**Goal**: Construct TaskFrame D and wire to dense completeness theorem.

**Components**:
1. TaskFrame D from torsor structure (nullity, compositionality, converse from TranslationGroup.lean)
2. Connect to parametric_to_history for WorldHistory
3. Wire final dense_completeness theorem

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TorsorTaskFrame.lean`
- [ ] Define `TorsorTaskFrame : TaskFrame (TranslationGroup M₀ h_mcs₀)`
- [ ] Verify nullity_identity, forward_comp, converse (from existing TranslationGroup theorems)
- [ ] Connect to FMCS infrastructure (mcs function, temporal properties)
- [ ] Wire to `parametric_to_history` for WorldHistory
- [ ] Wire to `parametric_shifted_truth_lemma`
- [ ] Assemble `dense_completeness` theorem in completion module

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/TorsorTaskFrame.lean`
- New: `Theories/Bimodal/Metalogic/TorsorDenseCompleteness.lean`
- Modify: `Theories/Bimodal/Metalogic/Metalogic.lean` (exports)

**Verification**:
- `lake build Bimodal.Metalogic.TorsorDenseCompleteness` passes
- `dense_completeness : valid_dense φ → Nonempty (DerivationTree_dense [] φ)` compiles without sorry
- Full `lake build` passes

**Estimated effort**: 2 hours

---

## Testing & Validation

- [ ] Phase 1: `orderIso_eq_id_of_fixedPt` proven without sorry
- [ ] Phase 2: `exists_orderIso_sending` proven without sorry
- [ ] Phase 3: `AddCommGroup (TranslationGroup M₀ h_mcs₀)` instance without sorry
- [ ] Phase 4: `LinearOrder` and `IsOrderedAddMonoid` instances without sorry
- [ ] Phase 5: `AddTorsor D T` instance without sorry
- [ ] Phase 6: `TaskFrame D` and `dense_completeness` without sorry
- [ ] Full `lake build` passes
- [ ] No non-axiom sorries in completeness chain

## Artifacts & Outputs

### New Files
- `Theories/Bimodal/Metalogic/Bundle/Rigidity.lean` - Rigidity theorem
- `Theories/Bimodal/Metalogic/Bundle/Homogeneity.lean` - Homogeneity via back-and-forth
- `Theories/Bimodal/Metalogic/Bundle/HolderTheorem.lean` - Holder's theorem for commutativity
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroupOrder.lean` - LinearOrder D
- `Theories/Bimodal/Metalogic/Bundle/TranslationGroupTorsor.lean` - AddTorsor D T
- `Theories/Bimodal/Metalogic/Bundle/TorsorTaskFrame.lean` - TaskFrame D
- `Theories/Bimodal/Metalogic/TorsorDenseCompleteness.lean` - Completeness wiring

### Estimated New Code: 430-530 lines

| Component | Estimated Lines |
|-----------|-----------------|
| Rigidity | 60 |
| Homogeneity | 80-120 |
| Holder's Theorem | 60-80 |
| LinearOrder D | 30-50 |
| IsOrderedAddMonoid D | 20-30 |
| AddTorsor D T | 40-60 |
| TaskFrame + Completeness | 80-100 |

## Rollback/Contingency

If torsor approach encounters unexpected blockers:
1. **Rigidity blocked**: Can axiomatize freeness temporarily
2. **Homogeneity blocked**: Can use Mathlib's Cantor theorem and derive transitivity indirectly
3. **Holder's blocked**: Can axiomatize commutativity and revisit later
4. **Full approach blocked**: Fall back to v4 approach with F/P coverage axioms

All new files are in separate modules, allowing clean rollback without affecting existing infrastructure.

## Dependencies on Existing Infrastructure

| Component | Location | Status | Usage |
|-----------|----------|--------|-------|
| `TranslationGroup` | `Boneyard/Task956_IntRat/TranslationGroup.lean` | Working | D definition, AddGroup, action |
| `BidirectionalQuotient` | `Boneyard/Task956_IntRat/BidirectionalReachable.lean` | Working | T definition, LinearOrder |
| `parametric_to_history` | `Algebraic/ParametricHistory.lean` | Working | Full-domain WorldHistory |
| `parametric_shifted_truth_lemma` | `Algebraic/ParametricTruthLemma.lean` | Working | MCS ↔ truth correspondence |
| `DovetailedBuild` | `StagedConstruction/DovetailedBuild.lean` | Working | DenselyOrdered, Countable instances |
| `RelIso.instGroup` | Mathlib | Working | Group on T ≃o T |
| `Additive.addGroup` | Mathlib | Working | Additive wrapper |

## Success Criteria

1. Rigidity, Homogeneity, and Holder's theorem proven without sorry
2. LinearOrder D and IsOrderedAddMonoid D instances without sorry
3. AddTorsor D T instance without sorry
4. TaskFrame D construction without sorry
5. `dense_completeness` theorem proven without sorry (using torsor approach)
6. Full `lake build` succeeds
7. New code integrates cleanly with existing infrastructure
