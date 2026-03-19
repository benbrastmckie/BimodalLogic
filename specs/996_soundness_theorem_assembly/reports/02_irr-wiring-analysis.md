# Research Report: Task #996 - IRR Wiring Analysis

**Task**: soundness_theorem_assembly
**Date**: 2026-03-19
**Focus**: Mathematically correct approach for wiring the IRR case in soundness_dense

## Summary

The IRR case in `soundness_dense` (line 696) requires wiring the `irr_sound_dense_at_domain` theorem from IRRSoundness.lean. The key challenge is a scope mismatch between the induction hypothesis `ih` (model-specific) and `irr_sound_dense_at_domain`'s requirement `h_premise : valid_dense (...)` (universally quantified). Additionally, `irr_sound_dense_at_domain` requires `h_dom : tau.domain t` which `soundness_dense` doesn't currently provide.

## Findings

### 1. Type Signature Analysis

**Current IRR case context (from lean_goal):**
```lean
case irr
ih : ∀ τ ∈ Omega, ∀ (t : D), (∀ ψ ∈ [], truth_at M Omega τ t ψ) →
     truth_at M Omega τ t (((Formula.atom p).and (Formula.atom p).neg.all_past).imp φ')
τ : WorldHistory F
h_mem : τ ∈ Omega
t : D
h_ctx : ∀ ψ ∈ [], truth_at M Omega τ t ψ
⊢ truth_at M Omega τ t φ'
```

**irr_sound_dense_at_domain signature:**
```lean
theorem irr_sound_dense_at_domain
    {p : Atom} {phi : Formula}
    (h_fresh : p ∉ phi.atoms)
    (h_premise : valid_dense ((Formula.and (Formula.atom p)
        (Formula.all_past (Formula.neg (Formula.atom p)))).imp phi))
    {D' : Type} [AddCommGroup D'] [LinearOrder D'] [IsOrderedAddMonoid D']
    [DenselyOrdered D'] [Nontrivial D']
    {F : TaskFrame D'} {M : TaskModel F} {Omega : Set (WorldHistory F)}
    (h_sc : ShiftClosed Omega)
    {tau : WorldHistory F} (h_mem : tau ∈ Omega)
    {t : D'} (h_dom : tau.domain t) :
    truth_at M Omega tau t phi
```

**Key Mismatch:**
| Parameter | `ih` provides | `irr_sound_dense_at_domain` needs |
|-----------|---------------|-----------------------------------|
| Premise validity | Model-specific: `truth_at M Omega τ t (premise.imp φ')` | Universal: `valid_dense (premise.imp φ')` |
| Domain membership | Not available | `h_dom : tau.domain t` |

### 2. The ih-to-valid_dense Gap

The induction hypothesis `ih` is "local" - it provides truth of the premise implication for the specific model `(D, F, M, Omega, h_sc)` already in scope. But `valid_dense` requires truth for ALL dense models:

```lean
def valid_dense (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

This gap cannot be bridged directly. The `ih` only gives information about the current model, not all possible models.

### 3. Domain Restriction Semantics

The `h_dom : tau.domain t` requirement in `irr_sound_dense_at_domain` is semantically meaningful:

**Why h_dom is needed:**
- The IRR proof constructs a product model where `prod_model.valuation (s, t0) p = (t0 = t)`
- This requires `lift_history tau` to have state `(tau.states t ht, t)` at time `t`
- The `lift_history` construction only defines states at domain times
- At non-domain time `t`, the product model construction cannot guarantee the truth of `(p ∧ H(¬p))`

**The counterexample from IRRSoundness.lean comments:**
For `box(q) → q`, if `t` is outside the domain, the box quantifies over all histories including those where `q` holds at `t`, but we cannot evaluate `q` at `(tau, t)` when `¬tau.domain t`.

### 4. Canonical Model Compatibility

Canonical models use `domain := Set.univ` (full domain), where `h_dom` is trivially satisfied:
```lean
def universal (F : TaskFrame D) (w : F.WorldState) (h_refl : ∀ d, F.task_rel w d w) : WorldHistory F where
  domain := fun _ => True  -- Full domain!
  ...
```

For completeness proofs via canonical models, the domain restriction poses no obstacle.

### 5. Mathematical Options Analysis

**Option A: Add h_dom to soundness_dense**

Modify `soundness_dense` signature:
```lean
theorem soundness_dense (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ) (h_dc : d.isDenseCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D)
    (h_dom : τ.domain t)  -- NEW PARAMETER
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) :
    truth_at M Omega τ t φ
```

**Pros:**
- Mathematically honest about the semantic restriction
- Directly wirable to `irr_sound_dense_at_domain`
- Works for all use cases where domain is known (e.g., canonical models)

**Cons:**
- Changes the theorem statement (may affect downstream users)
- Other cases (non-IRR) don't actually need `h_dom`
- `valid_dense` definition doesn't have domain restriction, creating inconsistency

**Option B: Create a localized IRR lemma**

Create a new theorem that takes model-specific validity instead of universal:
```lean
theorem irr_sound_dense_local
    {p : Atom} {phi : Formula}
    (h_fresh : p ∉ phi.atoms)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    {F : TaskFrame D} {M : TaskModel F} {Omega : Set (WorldHistory F)}
    (h_sc : ShiftClosed Omega)
    (h_premise_local : ∀ σ ∈ Omega, ∀ t, truth_at M Omega σ t (premise.imp phi))
    {tau : WorldHistory F} (h_mem : tau ∈ Omega)
    {t : D} (h_dom : tau.domain t) :
    truth_at M Omega tau t phi
```

**Pros:**
- Can be wired directly from `ih`
- Preserves current `soundness_dense` signature (except h_dom)

**Cons:**
- Requires proving the localized lemma (non-trivial)
- Still needs `h_dom`

**Option C: Strengthen the soundness theorem structure**

Use well-founded induction on derivation height and prove validity simultaneously for all models. This is similar to the approach in `derivable_valid_and_swap_valid` in SoundnessLemmas.lean.

```lean
theorem soundness_dense_derivable {φ : Formula} (d : DerivationTree [] φ)
    (h_dc : d.isDenseCompatible) : valid_dense φ
```

Then derive the model-specific version as a corollary.

**Pros:**
- Cleanest mathematical formulation
- `valid_dense` matches `h_premise` requirement exactly
- No domain restriction needed at theorem level

**Cons:**
- Requires significant restructuring of proof
- The IRR case still needs `h_dom` internally

**Option D: Restrict IRR to full-domain models**

Modify `isDenseCompatible` or create a predicate `isFullDomainCompatible` that marks derivations using IRR as requiring full-domain evaluation.

**Pros:**
- Makes domain restriction explicit in derivation structure

**Cons:**
- Complex predicate hierarchy
- May be over-engineering

## Recommendations

### Primary Recommendation: Option C (Restructure to prove valid_dense directly)

The most mathematically correct approach is to restructure `soundness_dense` to prove `valid_dense` for derivable formulas, matching the pattern used in `derivable_valid_and_swap_valid`:

```lean
theorem soundness_dense_theorem {φ : Formula} (d : DerivationTree [] φ)
    (h_dc : d.isDenseCompatible) : valid_dense φ := by
  induction d with
  | irr p φ' h_fresh _ ih =>
    -- ih : valid_dense (premise.imp φ')
    -- Now h_premise := ih matches irr_sound_dense_at_domain exactly
    intro D _ _ _ _ _ F M Omega h_sc τ h_mem t
    -- For full domain models (canonical models), h_dom is trivially True
    -- For partial domain models, truth_at of atoms requires h_dom anyway
    sorry -- Needs domain case analysis
  | ...
```

This approach aligns the theorem structure with the semantic definitions and resolves the ih-to-valid_dense gap.

### Secondary Recommendation: Handle domain restriction explicitly

Regardless of approach, the `h_dom` requirement needs addressing:

1. **For canonical model applications**: Domain is `Set.univ`, so `h_dom` is trivial
2. **For general models**: The truth_at definition for atoms already requires domain membership:
   ```lean
   | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
   ```
   So if any atomic formula in φ' is true at `(τ, t)`, then `τ.domain t` holds.

The semantic interplay is:
- If `truth_at M Omega τ t φ'` is the goal, and φ' contains atoms, the truth of those atoms implicitly provides domain membership
- If φ' = Formula.bot, truth is trivially false
- If φ' is purely propositional/modal without atoms, truth doesn't depend on domain

### Implementation Path

1. **Create `soundness_dense_valid` theorem** that proves `valid_dense φ` for dense-compatible derivations from empty context
2. **Wire IRR case** using `irr_sound_dense_at_domain` where `ih` provides `valid_dense (premise.imp φ')`
3. **Handle h_dom** via case analysis:
   - If `τ.domain t`: Apply `irr_sound_dense_at_domain` directly
   - If `¬τ.domain t`: Need to show truth_at cannot hold (atoms require domain membership)
4. **Derive `soundness_dense`** as corollary by instantiating `valid_dense`

## Context Extension Recommendations

None. This research pertains to existing metalogic infrastructure, not project context gaps.

## Next Steps

1. Create new theorem `soundness_dense_valid` with signature proving `valid_dense`
2. Adapt the induction structure to provide universal validity at each step
3. Wire IRR case with domain case analysis
4. Verify build passes
5. Update documentation

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean` - Current soundness_dense with IRR sorry
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/IRRSoundness.lean` - irr_sound_dense_at_domain theorem
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - derivable_valid_and_swap_valid pattern
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean` - valid_dense definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory.domain structure
