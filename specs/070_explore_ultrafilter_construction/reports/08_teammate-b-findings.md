# Teammate B Findings: MCS Impossibility Proof for Corner Case

**Task**: Investigate whether the corner case `φ ∈ L_no_phi` but `φ ∉ G_seed` is impossible,
and develop a proof strategy for the two symmetric sorries in UltrafilterChain.lean.

---

## Key Findings

### 1. The Corner Case Is NOT Impossible

The scenario `φ ∈ L_no_phi` AND `φ ∉ G_seed` is **genuinely reachable**. A concrete example:

- Let `φ ∉ G_seed` (i.e., `G(φ) ∉ U`).
- Let `L = [φ, φ]`, which is a valid list with `L ⊆ seed = G_seed ∪ {φ}`.
- After splitting at the first occurrence: `L_pre = []`, `L_post = [φ]`, `L_no_phi = [φ]`.
- Now `φ ∈ L_no_phi` but `φ ∉ G_seed`.

So the current proof approach — trying to show `φ ∈ G_seed` in this branch — is **impossible to complete**. The sorry cannot be filled in the current proof structure.

### 2. The Current Proof Structure Is Wrong

The existing proof at lines 1049-1113 (F_resolution) and 1307-1322 (P_resolution) tries to establish:
```
hL_no_phi_in_Gseed : ∀ ψ ∈ L_no_phi, ψ ∈ G_seed
```
This cannot be proved because `L_no_phi` may contain `φ`, which may not be in `G_seed`.

### 3. A Complete Proof Strategy Exists Using the Filter-Deduction-Contraction Approach

The fix requires restructuring the `h_phi_in_L` branch. Instead of proving
`hL_no_phi_in_Gseed` for `L_no_phi`, we:

1. Filter all `φ`-occurrences from `L_no_phi` to get `L_filt`
2. Prove `L_filt ⊢ ¬φ` via the exchange + deduction + contraction argument
3. Use `L_filt` (which is provably `⊆ G_seed`) for the G-fold argument

This approach is sound and all required lemmas already exist in the codebase.

---

## Recommended Approach (Detailed Proof Sketch)

### Phase 1: Filter Setup

Replace the current `hL_no_phi_in_Gseed` block with:

```lean
-- Define the φ-free version of L_no_phi
let L_filt := L_no_phi.filter (fun y => decide (y ≠ φ))

-- Step A: Prove L_filt ⊆ G_seed
have hL_filt_in_Gseed : ∀ ψ ∈ L_filt, ψ ∈ G_seed := by
  intro ψ hψ
  -- ψ ∈ L_filt means ψ ∈ L_no_phi AND ψ ≠ φ
  simp only [L_filt, List.mem_filter, decide_eq_true_eq] at hψ
  obtain ⟨hψ_in_L_no_phi, hψ_ne_phi⟩ := hψ
  -- ψ ∈ L_no_phi ⊆ L ⊆ seed = G_seed ∪ {φ}
  have hψ_in_L : ψ ∈ L := by
    rw [h_L_eq]; simp only [List.mem_append, List.mem_singleton]
    cases List.mem_append.mp hψ_in_L_no_phi with
    | inl h => left; exact h
    | inr h => right; right; exact h
  have hψ_in_seed := hL_in_seed ψ hψ_in_L
  simp only [Set.mem_union, Set.mem_singleton_iff] at hψ_in_seed
  rcases hψ_in_seed with h_Gseed | h_eq_phi
  · exact h_Gseed
  · exact absurd h_eq_phi hψ_ne_phi

-- Step B: Prove L_filt ⊢ ¬φ
have d_neg_phi_filt : DerivationTree L_filt φ.neg := by
  by_cases h_phi_in_L_no_phi : φ ∈ L_no_phi
  · -- φ ∈ L_no_phi: L_no_phi and (φ :: L_filt) have the same set membership
    -- (cons_filter_neq_perm removes all φ and prepends one)
    have h_perm := cons_filter_neq_perm h_phi_in_L_no_phi
    -- Exchange: L_no_phi ⊢ ¬φ → (φ :: L_filt) ⊢ ¬φ
    have d_rearranged : DerivationTree (φ :: L_filt) φ.neg :=
      derivation_exchange d_neg_phi (fun x => (h_perm x).symm)
    -- Deduction theorem: (φ :: L_filt) ⊢ ¬φ → L_filt ⊢ φ → ¬φ
    have d_phi_imp_neg : DerivationTree L_filt (φ.imp φ.neg) :=
      Bimodal.Metalogic.Core.deduction_theorem L_filt φ Formula.bot d_rearranged
    -- Contraction: ⊢ (φ → ¬φ) → ¬φ
    -- i.e., ⊢ (φ → φ → ⊥) → (φ → ⊥)
    -- Proof: flip(prop_k φ φ ⊥) applied to identity φ
    have d_contr : ⊢ (φ.imp φ.neg).imp φ.neg :=
      Bimodal.Theorems.Combinators.mp
        (Bimodal.Theorems.Combinators.identity φ)
        (Bimodal.Theorems.Combinators.theorem_flip
          (DerivationTree.axiom [] _ (Axiom.prop_k φ φ Formula.bot)))
    -- Apply: L_filt ⊢ ¬φ
    apply DerivationTree.modus_ponens L_filt _ _
    · exact DerivationTree.weakening [] L_filt _ d_contr (List.nil_subset _)
    · exact d_phi_imp_neg
  · -- φ ∉ L_no_phi: L_filt has the same set membership as L_no_phi
    -- (filter changes nothing since φ ∉ L_no_phi)
    apply derivation_exchange d_neg_phi
    intro x
    simp only [L_filt, List.mem_filter, decide_eq_true_eq]
    constructor
    · intro h; exact h.1
    · intro h_in
      refine ⟨h_in, fun h_eq => ?_⟩
      exact h_phi_in_L_no_phi (h_eq ▸ h_in)
```

### Phase 2: Replace L_no_phi with L_filt in the remainder

After establishing `d_neg_phi_filt` and `hL_filt_in_Gseed`, replace the subsequent steps:

```lean
-- From L_filt ⊢ ¬φ
have h_fold_le : List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L_filt ≤ toQuot φ.neg :=
  fold_le_of_derives L_filt φ.neg d_neg_phi_filt

-- All elements of L_filt have their G in U (since they're in G_seed)
have h_all_G_in_U : ∀ ψ ∈ L_filt, toQuot ψ.all_future ∈ U :=
  fun ψ hψ => hL_filt_in_Gseed ψ hψ

-- G(fold(L_filt)) ∈ U [same h_helper argument as before]
-- G(fold(L_filt)) ≤ G(¬φ) → G(¬φ) ∈ U → contradiction
```

The remainder of the proof (lines 1122-1154 for F_resolution) applies unchanged with `L_filt` substituting for `L_no_phi`.

### Phase 3: Contraction Lemma

The contraction step `⊢ (φ → φ → ⊥) → (φ → ⊥)` is proved using:

```lean
-- theorem_flip : ⊢ (A → B → C) → (B → A → C)
-- prop_k φ φ ⊥ : ⊢ (φ → φ → ⊥) → (φ → φ) → (φ → ⊥)
-- After flipping: ⊢ (φ → φ) → (φ → φ → ⊥) → (φ → ⊥)
-- identity φ : ⊢ φ → φ
-- mp: ⊢ (φ → φ → ⊥) → (φ → ⊥)

Bimodal.Theorems.Combinators.mp
  (Bimodal.Theorems.Combinators.identity φ)
  (Bimodal.Theorems.Combinators.theorem_flip
    (DerivationTree.axiom [] _ (Axiom.prop_k φ φ Formula.bot)))
```

Both `Combinators.mp`, `Combinators.identity`, and `Combinators.theorem_flip` exist in
`/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Combinators.lean`.

### Phase 4: P_resolution (line 1322)

The P_resolution sorry (line 1322) is strictly symmetric to F_resolution (line 1113):
- Replace `G_seed` with `H_seed` and `all_future` with `all_past`
- Replace `STSA.G` with `STSA.H`
- All other structure is identical

Apply the same filter-deduction-contraction approach to both.

---

## Evidence/Examples (Specific Code References)

### Relevant Tools Already in Codebase

| Tool | File | Purpose |
|------|------|---------|
| `cons_filter_neq_perm` | `Core/MCSProperties.lean:37` | `A :: L'.filter(≠A)` has same membership as `L'` |
| `derivation_exchange` | `Core/MCSProperties.lean:61` | Convert derivation between iso-membership contexts |
| `deduction_theorem` | `Core/DeductionTheorem.lean:336` | Remove hypothesis from context |
| `Combinators.identity` | `Theorems/Combinators.lean:108` | `⊢ A → A` |
| `Combinators.theorem_flip` | `Theorems/Combinators.lean:148` | `⊢ (A → B → C) → (B → A → C)` |
| `Combinators.mp` | `Theorems/Combinators.lean:97` | `⊢ A, ⊢ A → B → ⊢ B` |
| `Axiom.prop_k` | `ProofSystem/Axioms.lean:103` | `⊢ (A → B → C) → (A → B) → (A → C)` |
| `fold_le_of_derives` | `Algebraic/UltrafilterMCS.lean:551` | `L ⊢ ψ → fold(L) ≤ [ψ]` |

### Pattern Already Used in MCSProperties.lean (lines 96-111)

The filter + exchange + deduction pattern is used identically in `SetMaximalConsistent.closed_under_derivation`. The UltrafilterChain fix mirrors this exact pattern but adds the contraction step at the end.

### The `cons_filter_neq_perm` Clarification

The filter `L.filter (fun y => decide (y ≠ φ))` removes **all** occurrences of `φ`, not just one. The `cons_filter_neq_perm` lemma then shows that `φ :: L.filter(≠φ)` has the same **set membership** as `L` (when `φ ∈ L`). Since `derivation_exchange` (and weakening) care only about set membership, this is sufficient.

---

## Confidence Level: HIGH

The approach is:
1. **Mathematically sound**: The contraction principle `(φ → ¬φ) → ¬φ` is a classical tautology provable from the available axioms.
2. **Technically concrete**: All required lemmas exist in the codebase.
3. **Pattern-validated**: The filter + exchange + deduction pattern is already used in `MCSProperties.lean:96-111`.
4. **Zero sorry**: The proposed proof sketch introduces no new sorries; all steps have explicit justifications.

The main implementation effort is restructuring the `h_phi_in_L` branch in both `ultrafilter_F_resolution` and `ultrafilter_P_resolution` to:
- Use `L_filt` instead of `L_no_phi` as the G-fold target
- Prove `L_filt ⊢ ¬φ` via exchange + deduction + contraction (only needed when `φ ∈ L_no_phi`)

The proof is decidedly achievable without any new axioms, sorry deferral, or external lemmas.
