# Task 996 Research Report: Soundness Theorem Assembly

## Executive Summary

The soundness theorem in `Theories/Bimodal/Metalogic/Soundness.lean` (lines 533-601) has **6 remaining sorries** at lines 565, 569, 572, 575, 595, and 598. The analysis reveals that all component proofs exist and are accessible, but the current soundness theorem signature quantifies over ALL temporal types D without the frame conditions required by the extension axioms.

**Primary Finding**: The sorries cannot be resolved by simple wiring because the soundness theorem's current signature (`D : Type`) lacks the typeclass constraints needed by the extension axioms. Resolution requires **either** restricting the soundness statement to frame-class-specific theorems **or** splitting into multiple soundness lemmas.

**Recommended Approach**: Create three soundness theorems (`soundness_base`, `soundness_dense`, `soundness_discrete`) with appropriate frame constraints.

---

## 1. Sorry Analysis

### Location and Content

| Line | Case | Formula | Required Frame Condition | Existing Proof |
|------|------|---------|-------------------------|----------------|
| 565 | `density ψ` | `GGψ → Gψ` | `DenselyOrdered D` | `density_valid` (line 299) |
| 569 | `discreteness_forward ψ` | `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` | `SuccOrder D` | `discreteness_forward_valid` (line 318) |
| 572 | `seriality_future ψ` | `Gψ → Fψ` | `NoMaxOrder D` | `seriality_future_valid` (line 347) |
| 575 | `seriality_past ψ` | `Hψ → Pψ` | `NoMinOrder D` | `seriality_past_valid` (line 362) |
| 595 | `temporal_duality φ' d' ih` | `swap(φ')` | `DenselyOrdered D`, `Nontrivial D` | `axiom_swap_valid` in SoundnessLemmas |
| 598 | `irr p φ' h_fresh _ ih` | IRR rule | `DenselyOrdered D`, `Nontrivial D` | `irr_sound_dense_at_domain` in IRRSoundness |

### Root Cause

The soundness theorem signature is:

```lean
theorem soundness (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ → (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] →
    (F : TaskFrame D) → (M : TaskModel F) →
    (Omega : Set (WorldHistory F)) → (h_sc : ShiftClosed Omega) →
    (τ : WorldHistory F) → (h_mem : τ ∈ Omega) → (t : D) →
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ
```

This quantifies over all D, but:
- Density axiom requires `[DenselyOrdered D]`
- Discreteness axioms require `[SuccOrder D]`, `[PredOrder D]`, `[Nontrivial D]`
- Temporal duality and IRR require `[DenselyOrdered D]`, `[Nontrivial D]`

---

## 2. Existing Component Theorems

### 2.1 Axiom Validity (Soundness.lean)

**Base axioms** (universally valid, lines 97-295):
- `prop_k_valid`, `prop_s_valid`, `ex_falso_valid`, `peirce_valid`
- `modal_t_valid`, `modal_4_valid`, `modal_b_valid`, `modal_5_collapse_valid`
- `modal_k_dist_valid`, `temp_k_dist_valid`
- `temp_4_valid`, `temp_a_valid`, `temp_l_valid`
- `modal_future_valid`, `temp_future_valid`, `temp_linearity_valid`

**Dense extension** (requires `DenselyOrdered D`, lines 296-310):
- `density_valid` - Already proven with `[DenselyOrdered D]` constraint

**Discrete extension** (requires `SuccOrder D` / `PredOrder D`, lines 312-372):
- `discreteness_forward_valid` - Already proven with `[SuccOrder D]` constraint
- `seriality_future_valid` - Already proven with `[SuccOrder D]` constraint (uses `Order.lt_succ`)
- `seriality_past_valid` - Already proven with `[PredOrder D]` constraint (uses `Order.pred_lt`)

### 2.2 Combined Validators (Soundness.lean)

- `axiom_base_valid` (line 377): All base axioms, signature `Axiom φ → h_base → ⊨ φ`
- `axiom_valid_dense` (line 403): Dense-compatible axioms, signature `Axiom φ → h_dc → valid_dense φ`
- `axiom_valid_discrete` (line 445): Discrete-compatible axioms, signature `Axiom φ → h_dc → valid_discrete φ`

### 2.3 Rule Preservation (Soundness.lean)

- `necessitation_preserves_valid` (line 496): `⊨ φ → ⊨ □φ`
- `temporal_necessitation_preserves_valid` (line 507): `⊨ φ → ⊨ Gφ`

### 2.4 Temporal Duality (SoundnessLemmas.lean)

- `axiom_swap_valid` (line 448): All axioms remain valid after swap
  - Signature: `[DenselyOrdered D] [Nontrivial D] → h_dc : isDenseCompatible → is_valid D φ.swap_past_future`
  - Handles all axiom cases including density and seriality

### 2.5 IRR Rule (IRRSoundness.lean)

- `irr_sound_dense_at_domain` (line 283): IRR rule is sound on dense irreflexive frames
  - Signature: `p ∉ φ.atoms → valid_dense ((p ∧ H¬p) → φ) → [DenselyOrdered D'] [Nontrivial D'] → h_dom : τ.domain t → truth_at M Omega τ t φ`
  - Uses product frame construction to avoid state aliasing
  - Restricted to times in the history's domain

---

## 3. Frame Class Analysis

### 3.1 Axiom.frameClass (Axioms.lean lines 477-497)

```lean
def Axiom.frameClass {φ : Formula} : Axiom φ → FrameClass
  | Axiom.prop_k _ _ _ => .Base
  | ... (15 base axioms) ... => .Base
  | Axiom.density _ => .Dense
  | Axiom.discreteness_forward _ => .Discrete
  | Axiom.seriality_future _ => .Discrete
  | Axiom.seriality_past _ => .Discrete
```

### 3.2 Classification Predicates

- `Axiom.isBase`: Excludes density, discreteness, and seriality axioms
- `Axiom.isDenseCompatible`: Excludes `discreteness_forward` only
- `Axiom.isDiscreteCompatible`: Excludes `density` only

**Key Insight**: The seriality axioms are classified as `FrameClass.Discrete` but marked `isDenseCompatible = True`. This is semantically correct:
- On discrete frames: seriality uses `Order.lt_succ` / `Order.pred_lt`
- On dense frames: seriality uses `NoMaxOrder` / `NoMinOrder` (derived from `DenselyOrdered + Nontrivial`)

---

## 4. Resolution Strategy

### Option A: Frame-Class-Restricted Soundness (RECOMMENDED)

Create three separate soundness theorems with appropriate frame constraints:

```lean
/-- Soundness for base axiom proofs (no extension axioms allowed) -/
theorem soundness_base (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (h_base : derivation_uses_base_only d)  -- New predicate
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    ... : truth_at M Omega τ t φ

/-- Soundness for dense-compatible proofs -/
theorem soundness_dense (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    ... : truth_at M Omega τ t φ

/-- Soundness for discrete-compatible proofs -/
theorem soundness_discrete (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (h_discrete : derivation_avoids_density d)  -- New predicate
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D] [Nontrivial D]
    ... : truth_at M Omega τ t φ
```

**Advantages**:
- Clean separation of concerns
- Each theorem is fully provable with available components
- Matches the mathematical reality (density and discreteness are incompatible)

**Disadvantages**:
- Requires defining `derivation_uses_base_only` and `derivation_avoids_density` predicates
- More API surface area

### Option B: Dispatch via Axiom.frameClass

Modify soundness to dispatch to the correct frame class at runtime:

```lean
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (frame_class : FrameClass)
    (h_frame : frame_class_satisfied D frame_class)  -- Typeclass dispatch
    ... : truth_at M Omega τ t φ
```

Where `frame_class_satisfied` is:
```lean
class frame_class_satisfied (D : Type*) : FrameClass → Prop
  | Base => True
  | Dense => DenselyOrdered D ∧ Nontrivial D
  | Discrete => SuccOrder D ∧ PredOrder D ∧ Nontrivial D
```

**Disadvantages**:
- Requires runtime dispatch
- Complex error messages when frame conditions don't match derivation
- Doesn't catch axiom misuse at definition time

### Option C: Add Frame Constraints to Soundness (Current Path)

Add `[DenselyOrdered D] [Nontrivial D]` to the single soundness theorem.

```lean
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]  -- Add these
    ... : truth_at M Omega τ t φ
```

**Advantages**:
- Simplest change
- All current sorries would be directly fillable

**Disadvantages**:
- Excludes discrete frames entirely (the density axiom is NOT valid on discrete frames)
- Incorrectly claims soundness for proofs using discreteness axioms

### Recommendation

**Option A** is the recommended approach because:
1. It correctly models the mathematical situation (incompatible frame classes)
2. It provides the strongest guarantees (type-level enforcement)
3. Each theorem uses existing components with no new proofs needed

---

## 5. Implementation Path

### Phase 1: Create soundness_dense (Primary Focus)

The `soundness_dense` theorem is the most complete and easiest to assemble:

```lean
theorem soundness_dense (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ →
    (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] →
    [DenselyOrdered D] → [Nontrivial D] →
    (F : TaskFrame D) → (M : TaskModel F) →
    (Omega : Set (WorldHistory F)) → (h_sc : ShiftClosed Omega) →
    (τ : WorldHistory F) → (h_mem : τ ∈ Omega) → (t : D) →
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ := by
  intro d D _ _ _ _ _ F M Omega h_sc τ h_mem t h_ctx
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax =>
    -- Use axiom_valid_dense with appropriate isDenseCompatible proof
    cases h_ax with
    | prop_k φ ψ χ => exact prop_k_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | ... -- All base axioms work the same way
    | density ψ => exact density_valid ψ D _ _ _ _ _ F M Omega h_sc τ h_mem t
    | discreteness_forward ψ =>
      -- This axiom is NOT dense-compatible, but we can't derive it anyway
      -- The DerivationTree doesn't distinguish axiom types, so we need a different approach
      sorry -- This is a design issue
    | seriality_future ψ =>
      -- DenselyOrdered + Nontrivial implies NoMaxOrder
      have h_nomax : NoMaxOrder D := inferInstance
      ...
    | seriality_past ψ =>
      -- DenselyOrdered + Nontrivial implies NoMinOrder
      have h_nomin : NoMinOrder D := inferInstance
      ...
  | temporal_duality φ' d' ih =>
    -- Use axiom_swap_valid from SoundnessLemmas
    -- This works because we have DenselyOrdered D and Nontrivial D
    ...
  | irr p φ' h_fresh _ ih =>
    -- Use irr_sound_dense_at_domain from IRRSoundness
    -- Note: requires h_dom : τ.domain t which we don't have in general
    -- This is a known limitation of the IRR soundness proof
    ...
```

**Issue Discovered**: The `discreteness_forward` axiom case in `soundness_dense` is problematic. Even though we're on a dense frame where this axiom is invalid, the DerivationTree could theoretically contain this axiom. This reveals that the axiom case needs to validate that the axiom used is compatible with the frame.

### Phase 2: Address IRR Limitation

The `irr_sound_dense_at_domain` theorem has a precondition `h_dom : τ.domain t` that the general soundness theorem doesn't provide. Options:

1. **Accept the limitation**: Document that soundness holds only at domain times for IRR-using proofs
2. **Strengthen semantics**: Require all histories to have full domain (`τ.domain = Set.univ`)
3. **Weaken IRR soundness**: Find a way to extend the proof to non-domain times

The IRRSoundness.lean comments (around line 280) discuss this limitation. The recommended approach is option 1, with a note that canonical models use `Set.univ` domains.

### Phase 3: Define derivation predicates

To properly implement Option A, we need:

```lean
/-- A derivation uses only base axioms (no density, discreteness, seriality) -/
def DerivationTree.uses_base_only {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Prop
  | .axiom _ _ h => h.isBase
  | .assumption _ _ _ => True
  | .modus_ponens _ _ _ d1 d2 => d1.uses_base_only ∧ d2.uses_base_only
  | .necessitation _ d => d.uses_base_only
  | .temporal_necessitation _ d => d.uses_base_only
  | .temporal_duality _ d => d.uses_base_only
  | .irr _ _ _ d => d.uses_base_only
  | .weakening _ _ _ d _ => d.uses_base_only

/-- A derivation is dense-compatible (avoids discreteness_forward) -/
def DerivationTree.is_dense_compatible {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Prop
  | .axiom _ _ h => h.isDenseCompatible
  | .assumption _ _ _ => True
  | .modus_ponens _ _ _ d1 d2 => d1.is_dense_compatible ∧ d2.is_dense_compatible
  | .necessitation _ d => d.is_dense_compatible
  | .temporal_necessitation _ d => d.is_dense_compatible
  | .temporal_duality _ d => d.is_dense_compatible
  | .irr _ _ _ d => d.is_dense_compatible
  | .weakening _ _ _ d _ => d.is_dense_compatible
```

---

## 6. Wiring Details for Each Sorry

### Line 565: `| density ψ =>`

**Current context**: Inside `soundness` theorem, no `DenselyOrdered D` instance available.

**Required wiring** (in `soundness_dense`):
```lean
| density ψ =>
  exact density_valid ψ D _ _ _ _ _ F M Omega h_sc τ h_mem t
```

The `density_valid` theorem has signature:
```lean
theorem density_valid (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future)
```

### Line 569: `| discreteness_forward ψ =>`

**Current context**: Inside `soundness` theorem, no `SuccOrder D` instance available.

**Required wiring** (in `soundness_discrete`):
```lean
| discreteness_forward ψ =>
  exact discreteness_forward_valid ψ D _ _ _ h_succ h_pred h_nontriv F M Omega h_sc τ h_mem t
```

### Lines 572, 575: `| seriality_future ψ =>`, `| seriality_past ψ =>`

**For dense frames** (using NoMaxOrder/NoMinOrder from DenselyOrdered):
```lean
| seriality_future ψ =>
  intro h_G h_neg_F
  have h_nomax : NoMaxOrder D := inferInstance  -- DenselyOrdered + Nontrivial
  obtain ⟨s, hts⟩ := h_nomax.exists_gt t
  exact h_neg_F s hts (h_G s hts)
```

**For discrete frames** (using Order.lt_succ from SuccOrder):
```lean
| seriality_future ψ =>
  exact seriality_future_valid ψ D _ _ _ h_succ h_pred h_nontriv F M Omega h_sc τ h_mem t
```

### Line 595: `| temporal_duality φ' d' ih =>`

**Required wiring** (in `soundness_dense`):
```lean
| temporal_duality φ' d' ih =>
  -- The ih gives truth of φ' from derivation d'
  -- Need to show truth of φ'.swap_past_future
  -- Use axiom_swap_valid from SoundnessLemmas
  -- This requires proving that the swap of a valid formula is valid
  -- which is done by induction over the derivation d' itself
  sorry -- Complex: needs to thread the derivation structure through
```

**Analysis**: The `axiom_swap_valid` theorem in SoundnessLemmas proves that each axiom's swap is valid. However, the temporal_duality case in soundness needs to show that if `d'` derives `φ'` and `φ'` is valid (by ih), then `φ'.swap` is valid.

The issue is that `axiom_swap_valid` proves validity of swapped **axioms**, not swapped **arbitrary valid formulas**. The SoundnessLemmas file explicitly notes (lines 155-189) that `is_valid D φ.swap → is_valid D φ` is **UNPROVABLE** for arbitrary formulas.

**Resolution**: The temporal_duality case should use a derivation-indexed proof. Since we have `d' : DerivationTree [] φ'`, we can prove `truth_at ... φ'.swap` by induction on `d'`, using:
- `axiom_swap_valid` for axiom cases
- `mp_preserves_swap_valid`, `modal_k_preserves_swap_valid`, etc. for rule cases

This is exactly what `derivable_implies_swap_valid` should do (mentioned in comments but not fully implemented in SoundnessLemmas).

### Line 598: `| irr p φ' h_fresh _ ih =>`

**Required wiring** (in `soundness_dense`):
```lean
| irr p φ' h_fresh _ ih =>
  -- ih : truth_at ... ((p ∧ H¬p) → φ')
  -- Need: truth_at ... φ'
  -- Use irr_sound_dense_at_domain
  -- But that requires h_dom : τ.domain t
  -- Current solution: add h_dom as a hypothesis, document limitation
  sorry
```

The `irr_sound_dense_at_domain` theorem requires `h_dom : τ.domain t`. This is a fundamental limitation noted in IRRSoundness.lean. The proof constructs a product frame where p is true only at time t, which requires t to be in the domain.

---

## 7. Summary and Recommendations

### Immediate Actions

1. **Create `soundness_dense`**: A soundness theorem restricted to dense frames with `[DenselyOrdered D] [Nontrivial D]` constraints. This resolves sorries at lines 565, 572, 575.

2. **Create `soundness_discrete`**: A soundness theorem restricted to discrete frames with `[SuccOrder D] [PredOrder D] [Nontrivial D]` constraints. This resolves sorry at line 569.

3. **Complete temporal_duality soundness**: Implement the derivation-indexed proof of swap validity using the rule preservation lemmas in SoundnessLemmas. This resolves sorry at line 595.

4. **Document IRR limitation**: The IRR sorry at line 598 requires `h_dom : τ.domain t`. Either add this as a hypothesis or document that soundness holds for canonical models (which use full domains).

### Dependencies

- **DenseSoundness.lean** and **DiscreteSoundness.lean**: Already exist and re-export the appropriate validators
- **SoundnessLemmas.lean**: Contains `axiom_swap_valid` and rule preservation lemmas
- **IRRSoundness.lean**: Contains `irr_sound_dense_at_domain` with documented limitation

### Files to Modify

1. `Theories/Bimodal/Metalogic/Soundness.lean` - Add frame-class-restricted soundness theorems
2. `Theories/Bimodal/ProofSystem/Derivation.lean` - Optionally add `is_dense_compatible` predicate

### Estimated Effort

- `soundness_dense`: 2-3 hours (mostly straightforward wiring)
- `soundness_discrete`: 1-2 hours (parallel structure)
- Temporal duality completion: 2-4 hours (derivation-indexed proof)
- IRR resolution: 1 hour (documentation + hypothesis addition)

Total: 6-10 hours of implementation work.
