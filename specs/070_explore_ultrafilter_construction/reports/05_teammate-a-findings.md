# Research Report: Teammate A Findings - Phase 4 Sorries (Task #70)

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Date**: 2026-03-30
**Focus**: Rigorous analysis of the 3 Phase 4 sorries

---

## Key Findings

### Critical Infrastructure Discovery

The project uses a **custom** `Ultrafilter` type defined in `UltrafilterMCS.lean`, NOT
Mathlib's `Ultrafilter` (which lives on `Set α`). This distinction is foundational:

```lean
-- Our custom type (UltrafilterMCS.lean:38)
structure Ultrafilter (α : Type*) [BooleanAlgebra α] where
  carrier : Set α
  top_mem : ⊤ ∈ carrier
  bot_not_mem : ⊥ ∉ carrier
  mem_of_le : ∀ {a b}, a ∈ carrier → a ≤ b → b ∈ carrier
  inf_mem : ∀ {a b}, a ∈ carrier → b ∈ carrier → a ⊓ b ∈ carrier
  compl_or : ∀ a, a ∈ carrier ∨ aᶜ ∈ carrier
  compl_not : ∀ a, a ∈ carrier → aᶜ ∉ carrier
```

This is a ultrafilter on a Boolean algebra (a prime filter = maximal proper filter on the
lattice). Mathlib's `Ultrafilter α` is an ultrafilter on `Set α` (the powerset lattice).
The filter extension infrastructure (`Ultrafilter.of`, `Filter.generate`, etc.) from
Mathlib operates in `Set α`, not on arbitrary Boolean algebras.

**Consequence**: We cannot directly use `Ultrafilter.of` or `Filter.generate` from Mathlib.
Instead, the correct approach mirrors the existing `set_lindenbaum` pattern via
`zorn_subset_nonempty`, which the codebase already uses successfully.

---

## Sorry 1: `G_preimage_inf`

### What Needs to Be Proven

```lean
theorem G_preimage_inf (U : Ultrafilter LindenbaumAlg) (a b : LindenbaumAlg)
    (ha : a ∈ G_preimage U) (hb : b ∈ G_preimage U) : a ⊓ b ∈ G_preimage U
```

The goal after unfolding: given `STSA.G a ∈ U` and `STSA.G b ∈ U`, prove `STSA.G (a ⊓ b) ∈ U`.

The current proof reduces to:

```
h_inf : STSA.G a ⊓ STSA.G b ∈ U     -- from U.inf_mem ha hb
Goal : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b)   -- the sorry
```

### Mathematical Content

We need: `G(a) ∧ G(b) → G(a ∧ b)` at the quotient algebra level.

This is the standard K-axiom consequence. The derivation in `G_monotone` shows the pattern:

```
⊢ φ → ψ  (by necessitation)  =>  G(φ → ψ) ∈ LindenbaumAlg
               + temp_k_dist  =>  G(φ) → G(ψ)
```

For `G(a) ∧ G(b) → G(a ∧ b)`, unfolding `a ⊓ b` via `inf_quot`:

```lean
a ⊓ b = inf_quot a b = and_quot a b
-- where and_quot is Quotient.lift₂ (fun φ ψ => toQuot (φ.and ψ)) ...
```

So for representatives `φ` and `ψ`, we need:

```lean
G_quot (toQuot φ) ⊓ G_quot (toQuot ψ) ≤ G_quot (toQuot (φ.and ψ))
-- i.e.: Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
```

### Proof Sketch (Lean Tactics)

The derivation needs:
1. `⊢ ψ → (φ → φ ∧ ψ)` -- from `pairing` (Combinators)
2. `⊢ G(ψ → (φ → φ ∧ ψ))` -- temporal_necessitation
3. `⊢ G(ψ) → G(φ → φ ∧ ψ)` -- temp_k_dist ψ (φ.imp (φ.and ψ))
4. `⊢ G(φ → φ ∧ ψ) → (G(φ) → G(φ ∧ ψ))` -- temp_k_dist φ (φ.and ψ)
5. Compose steps 3-4 to get: `⊢ G(ψ) → G(φ) → G(φ ∧ ψ)`
6. Since `G(φ) ∧ G(ψ) ≤ G(φ) → G(ψ) → G(φ ∧ ψ)` in the algebra...

Wait: step 5 gives `G(ψ) → G(φ) → G(φ∧ψ)`. We need to get from `G(φ) ∧ G(ψ)` to `G(φ∧ψ)`.

The algebra level: working at the quotient level (lifting to formulas and working in `Derives`).
After `induction a using Quotient.ind; induction b using Quotient.ind`:

```lean
show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
-- i.e.: (φ.all_future.and ψ.all_future) → (φ.and ψ).all_future is provable
-- where F.and G = ¬(F → ¬G) = (F → G → ⊥) → ⊥
```

Actually, since `a ⊓ b ≤ c` in the Lindenbaum algebra means `⊢ (a ∧ b) → c`, the target is:

```lean
Derives (G_quot (toQuot φ) ⊓ G_quot (toQuot ψ)) (G_quot (toQuot (φ.and ψ)))
-- expands to:
⊢ (φ.all_future.and ψ.all_future) → (φ.and ψ).all_future
```

**Complete proof sequence** (showing the derivation tree construction):

```lean
have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  -- Goal: G_quot (toQuot φ) ⊓ G_quot (toQuot ψ) ≤ G_quot (toQuot (φ.and ψ))
  -- i.e.: Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
  show Derives (φ.all_future.and ψ.all_future) (φ.and ψ).all_future
  -- Step 1: ⊢ φ → (ψ → φ ∧ ψ)  [pairing]
  have pair : [] ⊢ φ.imp (ψ.imp (φ.and ψ)) :=
    Bimodal.Theorems.Combinators.pairing φ ψ
  -- Step 2: ⊢ G(φ → ψ → φ ∧ ψ) [necessitation]
  have d_nec : [] ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future :=
    DerivationTree.temporal_necessitation _ pair
  -- Step 3: ⊢ G(φ → ψ → φ ∧ ψ) → G(φ) → G(ψ → φ ∧ ψ)  [temp_k_dist]
  have dk1 : [] ⊢ (φ.imp (ψ.imp (φ.and ψ))).all_future.imp
      (φ.all_future.imp (ψ.imp (φ.and ψ)).all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ (ψ.imp (φ.and ψ)))
  have h1 : [] ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
    DerivationTree.modus_ponens [] _ _ dk1 d_nec
  -- Step 4: ⊢ G(ψ → φ ∧ ψ) → G(ψ) → G(φ ∧ ψ)  [temp_k_dist]
  have dk2 : [] ⊢ (ψ.imp (φ.and ψ)).all_future.imp
      (ψ.all_future.imp (φ.and ψ).all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ (φ.and ψ))
  -- Step 5: Compose: ⊢ G(φ) → G(ψ) → G(φ ∧ ψ)
  have h2 : [] ⊢ φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
    Bimodal.Theorems.Combinators.imp_trans h1 dk2
  -- Step 6: Need to go from G(φ) ∧ G(ψ) to G(φ ∧ ψ)
  -- G(φ) ∧ G(ψ) = (G(φ) → G(ψ) → ⊥) → ⊥  by definition of .and
  -- From (G(φ) → G(ψ) → G(φ∧ψ)) and G(φ) ∧ G(ψ), get G(φ∧ψ)
  -- The Derives relation here is: ⊢ (G(φ) ∧ G(ψ)) → G(φ ∧ ψ)
  -- Use prop_s + modus_ponens manipulation or a direct conjunction elimination approach
  have h3 : [] ⊢ φ.all_future.and ψ.all_future.imp (φ.and ψ).all_future := by
    -- Use prop_k and prop_s to build from h2
    -- h2 : ⊢ G(φ) → (G(ψ) → G(φ∧ψ))
    -- pairing_inv : ⊢ (A ∧ B) → A  [proj1]
    -- pairing_inv : ⊢ (A ∧ B) → B  [proj2]
    -- Need proj1 and proj2 for .and (the custom conjunction)
    -- .and is defined as (A → B → ⊥) → ⊥ = ¬(A → ¬B)
    -- proj1 : ⊢ (A ∧ B) → A  from theorem_app1 variant
    -- proj2 : ⊢ (A ∧ B) → B  from theorem_app2 variant
    sorry -- see note below
  unfold Derives
  exact ⟨h3⟩
```

**Note on Step 6**: Getting from `G(φ) ∧ G(ψ)` to `G(φ∧ψ)` at the derivation level
requires conjunction elimination (`∧E`). Looking at the `Combinators.lean` file, `pairing`
gives `A → B → A∧B` (introduction). We need projection lemmas. However, there is a cleaner
approach using the existing `G_monotone` pattern plus a rewrite:

**Alternative cleaner approach**: The goal `STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b)` means
`G(a) ∧ G(b) ≤ G(a ∧ b)`. This can be decomposed:
- `G(a) ∧ G(b) ≤ G(a)` (inf_le_left)
- `G(a) ∧ G(b) ≤ G(b)` (inf_le_right)
- We need these to give `G(a ∧ b)`

A cleaner factoring: prove the lemma `G_inf_le : G a ⊓ G b ≤ G (a ⊓ b)` by showing
`⊢ G(a) → G(b) → G(a ∧ b)` (from steps 1-5 above) and then applying it twice:

```lean
-- Cleaner approach: directly at the algebra level
have h_ga_imp : STSA.G a ⊓ STSA.G b ≤ STSA.G a := inf_le_left
have h_gb_imp : STSA.G a ⊓ STSA.G b ≤ STSA.G b := inf_le_right
-- Use that a ⊓ b ≤ a and G monotone: G(a ∧ b) ≤ G(a) but we need ≤ not ≥
-- This direction doesn't immediately help
```

Actually the cleanest proof uses the derivation-level `box_conj_intro` pattern, adapted
for G. Looking at `Perpetuity/Principles.lean`:

```lean
-- Analogous to box_conj_intro but for G (temporal_necessitation + temp_k_dist)
-- From ⊢ φ → (ψ → φ ∧ ψ) [pairing], we build
-- ⊢ G(φ → (ψ → φ ∧ ψ))  [temporal_necessitation]
-- ⊢ G(φ) → G(ψ → φ ∧ ψ)  [temp_k_dist φ (ψ.imp (φ.and ψ))]
-- ⊢ G(ψ → φ ∧ ψ) → G(ψ) → G(φ ∧ ψ)  [temp_k_dist ψ (φ.and ψ)]
-- Compose: ⊢ G(φ) → G(ψ) → G(φ ∧ ψ)
-- This gives the inequality G(φ) ∧ G(ψ) ≤ G(φ ∧ ψ) at algebra level
```

**Final complete tactic sequence**:

```lean
have h_K_inf : STSA.G a ⊓ STSA.G b ≤ STSA.G (a ⊓ b) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives (G_quot (toQuot φ) ⊓ G_quot (toQuot ψ)) (G_quot (toQuot (φ.and ψ)))
  -- Need: ⊢ G(φ) ∧ G(ψ) → G(φ ∧ ψ)
  -- At quotient level: (φ.all_future.and ψ.all_future) → (φ.and ψ).all_future
  unfold Derives
  have pair : [] ⊢ φ.imp (ψ.imp (φ.and ψ)) := Bimodal.Theorems.Combinators.pairing φ ψ
  have d_nec := DerivationTree.temporal_necessitation _ pair
  have dk1 := DerivationTree.axiom [] _
                (Axiom.temp_k_dist φ (ψ.imp (φ.and ψ)))
  have h1 : [] ⊢ φ.all_future.imp (ψ.imp (φ.and ψ)).all_future :=
    DerivationTree.modus_ponens [] _ _ dk1 d_nec
  have dk2 := DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ (φ.and ψ))
  -- h1 : ⊢ G(φ) → G(ψ → φ∧ψ)
  -- dk2 : ⊢ G(ψ → φ∧ψ) → G(ψ) → G(φ∧ψ)
  -- So: ⊢ G(φ) → G(ψ) → G(φ∧ψ)
  have h_chain : [] ⊢ φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
    Bimodal.Theorems.Combinators.imp_trans h1 dk2
  -- Now need to use: G(φ) ∧ G(ψ) ≤ G(φ∧ψ)
  -- i.e., ⊢ (G(φ) ∧ G(ψ)) → G(φ∧ψ)
  -- Use: A ∧ B → A [proj1], A ∧ B → B [proj2], plus h_chain
  -- For proj1 and proj2: need conj_elim lemmas
  -- Likely: Bimodal.Theorems.Combinators or Propositional contains these
  -- The .and definition: A.and B = A.neg.imp B.neg = ¬A → ¬B
  -- Actually check: Formula.and φ ψ = (φ.imp (ψ.imp Formula.bot)).imp Formula.bot
  -- This means: ¬(φ → ¬ψ)
  -- Proj1: (A ∧ B) → A follows from: ¬¬A = A ← ¬(¬A), and ¬A → (A → ¬B) by ex_falso
  -- This gets complex. Better to use `by_contra + push_neg` or a direct derivation helper
  -- Check if Propositional.lean has and_elim_left / and_elim_right
  constructor
  exact sorry -- see analysis of and_elim below
```

**Critical subproblem**: Conjunction elimination. We need:
- `⊢ (φ ∧ ψ) → φ`  (and_elim_left)
- `⊢ (φ ∧ ψ) → ψ`  (and_elim_right)

Let me check if these exist:

### Confidence Level: **HIGH**

The proof is mathematically routine. The main implementation question is whether
`and_elim_left` / `and_elim_right` exist as named lemmas. If not, they need to be constructed
from propositional combinators (similar to how `pairing` is built from `theorem_app2`). Given
the existing infrastructure (`pairing`, `imp_trans`, `prop_k`, `prop_s`), these can definitely
be built. The derivation is completely standard.

**Dependencies**: `Bimodal.Theorems.Combinators.pairing`, `Axiom.temp_k_dist`,
`DerivationTree.temporal_necessitation`, `Bimodal.Theorems.Combinators.imp_trans`.

---

## Sorry 2: `ultrafilter_F_resolution`

### What Needs to Be Proven

```lean
theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : (STSA.G aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V
```

Note: `F(a) = ¬G(¬a) = (G(aᶜ))ᶜ`, so `h_F : (G(aᶜ))ᶜ ∈ U` means `F(a) ∈ U`.

### Mathematical Content

The argument is a classical ultrafilter extension:

1. Define `S := G_preimage(U) ∪ {a}` (the seed set)
2. Show S generates a proper filter (i.e., the "upward closure of finite meets of S" never
   reaches ⊥)
3. Extend to an ultrafilter V via Zorn's lemma
4. V satisfies `R_G(U, V)` by construction (G_preimage(U) ⊆ V.carrier)
5. `a ∈ V` because V extends S

**Key consistency argument**: If S generates an improper filter, there exist elements
`b₁, ..., bₙ ∈ G_preimage(U)` such that `b₁ ⊓ ... ⊓ bₙ ⊓ a = ⊥`. This means:
- `b₁ ⊓ ... ⊓ bₙ ≤ aᶜ`  (since `x ⊓ a = ⊥ ↔ x ≤ aᶜ` in Boolean algebras)
- `G(b₁ ⊓ ... ⊓ bₙ) ≤ G(aᶜ)` by G_monotone
- `G(b₁ ⊓ ... ⊓ bₙ) ∈ U` by repeated G_preimage_inf
- So `G(aᶜ) ∈ U` by upward closure of U
- But `(G(aᶜ))ᶜ ∈ U` (this is h_F), so both `G(aᶜ)` and `(G(aᶜ))ᶜ` are in U
- This contradicts `U.compl_not`

### The Zorn Argument (Detailed)

We need to extend the filter generated by `G_preimage(U) ∪ {a}` to an ultrafilter of our
custom `Ultrafilter LindenbaumAlg` type.

**Approach**: Use the MCS bijection! Since ultrafilters on LindenbaumAlg correspond bijectively
to MCSes (via `mcsToUltrafilter` / `ultrafilterToSet_mcs`), we can:
1. Translate the filter seed to formulas
2. Apply `set_lindenbaum` (Zorn-based MCS extension)
3. Translate the resulting MCS back to an ultrafilter

Specifically:
- The seed `G_preimage(U) ∪ {a}` at the algebra level corresponds to formulas
  `{ ψ | all_future ψ ∈ ultrafilterToSet U } ∪ { repr(a) }` at the formula level
- The consistency of this formula set follows from the algebraic consistency argument
- `set_lindenbaum` gives us an MCS M extending this
- `mcsToUltrafilter ⟨M, hM⟩` is the desired ultrafilter V

**Alternative Approach**: Direct Zorn on ultrafilters of the Boolean algebra.

Define the "proper filter extension" order on proper filters of `LindenbaumAlg` that extend
`G_preimage(U) ∪ {a}`, and apply Zorn's lemma directly.

### Recommended Proof Strategy (via MCS bijection)

```lean
theorem ultrafilter_F_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_F : (STSA.G aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_G U V ∧ a ∈ V := by
  -- Step 1: Get a formula representative for a
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a
  -- Step 2: Define the seed formula set
  let MU := ultrafilterToSet U     -- the MCS corresponding to U
  have hMU_mcs := ultrafilterToSet_mcs U
  -- Seed: { ψ | G(ψ) ∈ MU } ∪ {φ}
  let seed : Set Formula := { ψ | Formula.all_future ψ ∈ MU } ∪ {φ}
  -- Step 3: Show seed is SetConsistent
  have h_seed_cons : SetConsistent seed := by
    -- Proof by contradiction: assume L ⊆ seed with L ⊢ ⊥
    -- Partition L into L_G (from G-preimage) and L_φ (containing φ)
    -- If L_φ = ∅: L ⊆ { ψ | G(ψ) ∈ MU }, so G(⊓ L) ∈ MU, and ⊓ L ≤ ⊥, so G(⊥) ∈ MU
    --   But G(⊥) = G(¬⊤) = ¬F(⊤) and F(⊤) ∈ MU (seriality), contradiction
    -- If φ ∈ L: L' = L.remove φ ⊆ G-preimage part
    --   L' ⊢ ¬φ (since L ⊢ ⊥), so ⊓ L' ≤ φᶜ
    --   G(⊓ L') ∈ MU and G(⊓ L') ≤ G(φᶜ), so G(φᶜ) ∈ MU
    --   But h_F says G(φᶜ) ∉ MU (via ultrafilter_neg_iff + h_F), contradiction
    sorry -- detailed argument using h_F and G_preimage_inf
  -- Step 4: Apply set_lindenbaum to extend seed to MCS
  obtain ⟨M, hM_extends, hM_mcs⟩ :=
    Bimodal.Metalogic.Core.set_lindenbaum seed h_seed_cons
  -- Step 5: Build the ultrafilter V from M
  let V := mcsToUltrafilter ⟨M, hM_mcs⟩
  use V
  constructor
  · -- Show R_G(U, V): for all b, G(b) ∈ U → b ∈ V
    intro b h_Gb_in_U
    -- G(b) ∈ U means G(b) ∈ MU (by definition of MU = ultrafilterToSet U)
    -- So repr(b) ∈ { ψ | G(ψ) ∈ MU } ⊆ seed ⊆ M
    -- Hence b ∈ V = mcsToUltrafilter M
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    show toQuot ψ ∈ V.carrier
    -- h_Gb_in_U : G_quot (toQuot ψ) ∈ U
    -- = toQuot (ψ.all_future) ∈ U   (by def of G_quot)
    -- = ψ.all_future ∈ ultrafilterToSet U = MU
    have h_in_seed : ψ ∈ seed := Set.mem_union_left _ (by
      show ψ.all_future ∈ MU
      exact h_Gb_in_U)
    have h_in_M : ψ ∈ M := hM_extends h_in_seed
    exact ⟨ψ, h_in_M, rfl⟩
  · -- Show a ∈ V, i.e., φ ∈ M
    show toQuot φ ∈ V.carrier
    have h_phi_seed : φ ∈ seed := Set.mem_union_right _ (Set.mem_singleton φ)
    have h_phi_M : φ ∈ M := hM_extends h_phi_seed
    exact ⟨φ, h_phi_M, rfl⟩
```

### Detailed Consistency Proof (Step 3)

The main complexity is proving `seed` is consistent. This uses `G_preimage_inf` (sorry 1)
plus the contradiction with `h_F`:

```lean
have h_seed_cons : SetConsistent seed := by
  intro L hL h_incons
  -- hL : ∀ ψ ∈ L, ψ ∈ seed
  -- h_incons : ¬Consistent L, i.e., L ⊢ ⊥
  obtain ⟨d_bot⟩ := inconsistent_derives_bot h_incons
  -- Partition L into φ-part and G-preimage part
  let L_noφ := L.filter (· ≠ φ)
  have h_L_noφ_sub : ∀ ψ ∈ L_noφ, ψ.all_future ∈ MU := by
    intro ψ hψ
    have := List.mem_filter.mp hψ
    have hmem := hL ψ this.1
    simp only [seed, Set.mem_union, Set.mem_setOf_eq, Set.mem_singleton_iff] at hmem
    cases hmem with
    | inl hg => exact hg
    | inr heq => exact absurd heq this.2
  -- If φ ∈ L:
  by_cases h_phi_in_L : φ ∈ L
  · -- The hard case: φ is among the inconsistent witnesses
    -- L = L_noφ ++ [φ] essentially
    -- From L ⊢ ⊥, get L_noφ ⊢ ¬φ (deduction theorem)
    -- The fold of G(ψ_i) for ψ_i ∈ L_noφ is in U
    -- G(fold ψ_i) ≤ G(¬φ)  (since fold ψ_i ≤ ¬φ from L_noφ ⊢ ¬φ, plus G monotone)
    -- So G(¬φ) ∈ U
    -- But h_F says (G(¬φ))ᶜ ∈ U → contradiction via compl_not
    ...
  · -- Easy case: φ ∉ L, so L ⊆ G-preimage part
    -- All ψ ∈ L have G(ψ) ∈ MU, so fold G(ψ) ∈ U
    -- fold G(ψ) = G(fold ψ) by repeated G_preimage_inf
    -- From L ⊢ ⊥: fold ψ ≤ ⊥
    -- So G(⊥) ∈ U → contradiction (G(⊥) ≤ ⊥ since G_monotone and ⊥ ≤ G(⊥) implies ⊥ ∈ U → contradiction)
    ...
```

### Important Type-Matching Issue

The `seed` set contains `Formula` objects, but `h_Gb_in_U : G_quot (toQuot ψ) ∈ U` gives
membership in the algebra. The bridge is `G_quot (toQuot ψ) = toQuot (ψ.all_future)` and
`ultrafilterToSet U = { φ | toQuot φ ∈ U }`. These definitions must be carefully aligned.

### Confidence Level: **MEDIUM**

The mathematical argument is correct and well-understood. The implementation complexity is
moderate:
1. The MCS bijection approach is clean and leverages existing infrastructure
2. The consistency proof needs careful case analysis (φ ∈ L vs. φ ∉ L)
3. The type-matching between `LindenbaumAlg` elements and `Formula`s adds bookkeeping
4. `G_preimage_inf` (sorry 1) is a dependency

**Dependencies**: `G_preimage_inf`, `ultrafilterToSet_mcs`, `mcsToUltrafilter`,
`set_lindenbaum`, `ultrafilterToSet`, `R_G_R_H_converse`.

---

## Sorry 3: `ultrafilter_P_resolution`

### What Needs to Be Proven

```lean
theorem ultrafilter_P_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_P : (STSA.H aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_H U V ∧ a ∈ V
```

`P(a) = ¬H(¬a) = (H(aᶜ))ᶜ`, so `h_P : (H(aᶜ))ᶜ ∈ U` means `P(a) ∈ U`.

### Is It Truly Symmetric?

**Yes, with caveats.** The argument is symmetric under the temporal duality `σ`, but there
are asymmetries in the infrastructure:

1. **Symmetric aspects**: The algebraic argument for F-resolution uses `G_preimage(U)` and
   `G_monotone`. For P-resolution, the parallel uses `H_preimage(U)` and `H_monotone`.
   The Zorn argument structure is identical.

2. **Asymmetry 1**: The proof system treats G and H differently. `temp_k_dist` gives K for G;
   there is a separate past K-axiom. Let me verify:

Looking at the axioms, there should be `temp_k_dist_past` or the analogous rule via
`temporal_duality` (which swaps G↔H). The `H_monotone` proof in `InteriorOperators.lean`
uses `past_mono` from `Perpetuity`, suggesting the infrastructure is there.

3. **Asymmetry 2**: `R_H(U, V)` is defined as `∀ a, H(a) ∈ U → a ∈ V`, while
   `R_G(U, V) = ∀ a, G(a) ∈ U → a ∈ V`. The MCS bijection approach works identically for
   both.

4. **Can we derive P-resolution from F-resolution?** In principle yes, via `R_G_R_H_converse`:
   `R_G(U, V) ↔ R_H(V, U)`. But this swaps the roles of U and V, so it doesn't directly
   give us P-resolution from F-resolution.

5. **Temporal duality `σ` approach**: Since `σ(G(a)) = H(σ(a))` and `σ` is an involutive
   Boolean automorphism, we could transport the F-resolution proof to P-resolution via σ.
   This would be elegant but requires showing that σ preserves the ultrafilter structure.

### Recommended Approach: Direct Symmetric Proof

The cleanest approach is a direct proof mirroring F-resolution:

```lean
theorem ultrafilter_P_resolution (U : Ultrafilter LindenbaumAlg)
    (a : LindenbaumAlg) (h_P : (STSA.H aᶜ)ᶜ ∈ U) :
    ∃ V : Ultrafilter LindenbaumAlg, R_H U V ∧ a ∈ V := by
  -- Mirror of ultrafilter_F_resolution with H instead of G
  obtain ⟨φ, rfl⟩ := Quotient.exists_rep a
  let MU := ultrafilterToSet U
  have hMU_mcs := ultrafilterToSet_mcs U
  -- Seed: { ψ | H(ψ) ∈ MU } ∪ {φ}
  let seed : Set Formula := { ψ | Formula.all_past ψ ∈ MU } ∪ {φ}
  -- Show seed is consistent (same argument with H replacing G)
  have h_seed_cons : SetConsistent seed := by ...  -- symmetric argument
  obtain ⟨M, hM_extends, hM_mcs⟩ := set_lindenbaum seed h_seed_cons
  let V := mcsToUltrafilter ⟨M, hM_mcs⟩
  use V
  constructor
  · intro b h_Hb_in_U
    -- R_H(U, V): H(b) ∈ U → b ∈ V
    obtain ⟨ψ, rfl⟩ := Quotient.exists_rep b
    have h_in_seed : ψ ∈ seed := Set.mem_union_left _ (by
      show ψ.all_past ∈ MU; exact h_Hb_in_U)
    exact ⟨ψ, hM_extends h_in_seed, rfl⟩
  · show toQuot φ ∈ V.carrier
    exact ⟨φ, hM_extends (Set.mem_union_right _ (Set.mem_singleton φ)), rfl⟩
```

### Key Asymmetry in the Consistency Proof

For the P-resolution consistency proof, the contradiction is with `h_P`:
- If the seed generates an improper filter, there exist `b₁, ..., bₙ` with `H(bᵢ) ∈ MU`
  and `b₁ ⊓ ... ⊓ bₙ ⊓ a = ⊥`
- This gives `H(b₁ ⊓ ... ⊓ bₙ) ≤ H(aᶜ)`
- By repeated `H_preimage_inf` (which needs to be proved analogously to `G_preimage_inf`)
- So `H(aᶜ) ∈ U`
- But `h_P : (H(aᶜ))ᶜ ∈ U` -- contradiction via `U.compl_not`

**Missing lemma**: `H_preimage_inf` (analogous to `G_preimage_inf`). This needs the past
K-axiom. Looking at the axioms file, there should be `temp_k_dist_past` or the past version
is derivable via temporal duality. Given that `H_monotone` is proved via `past_mono`, we
need to check if `past_conj_intro` exists or needs to be built.

### Confidence Level: **MEDIUM**

The argument is symmetric in structure but requires:
1. `H_preimage_inf` (needs past K-axiom distribution - analogous to sorry 1)
2. The past K-axiom exists or can be derived from `temp_k_dist` via temporal duality

**Dependencies**: `G_preimage_inf` pattern (for `H_preimage_inf`), `H_monotone`,
`ultrafilterToSet_mcs`, `mcsToUltrafilter`, `set_lindenbaum`.

---

## Recommended Approach (Summary)

### Order of Implementation

1. **First**: Prove `G_preimage_inf` (sorry 1) - standalone, no sorry dependencies
2. **Then**: Prove `H_preimage_inf` as an analogous lemma (needed for sorry 3)
3. **Then**: Prove `ultrafilter_F_resolution` (sorry 2) - depends on sorry 1
4. **Finally**: Prove `ultrafilter_P_resolution` (sorry 3) - depends on H_preimage_inf

### For `G_preimage_inf`

**CONFIRMED**: `Bimodal.Theorems.Propositional` provides exactly the needed lemmas:
- `lce_imp (A B : Formula) : ⊢ (A.and B).imp A`  (Left Conjunction Elimination)
- `rce_imp (A B : Formula) : ⊢ (A.and B).imp B`  (Right Conjunction Elimination)

These exist at lines 737 and 755 of `Propositional.lean`. The complete proof is:

```lean
-- pairing → necessitation → 2x temp_k_dist → compose via imp_trans → use lce_imp/rce_imp
-- Full derivation:
-- 1. ⊢ G(φ) → G(ψ) → G(φ∧ψ)  [from pairing, nec, 2x temp_k_dist, imp_trans]
-- 2. ⊢ (G(φ)∧G(ψ)) → G(φ)    [G_quot version of lce_imp]
-- 3. ⊢ (G(φ)∧G(ψ)) → G(ψ)    [G_quot version of rce_imp]
-- Combine: (G(φ)∧G(ψ)) → G(φ∧ψ)
```

The `lce_imp`/`rce_imp` work at the Formula level. In the Quotient algebra, `a ⊓ b`
corresponds to `Formula.and` at representative level, so the proof via `Quotient.ind` will
use these directly.

### For `ultrafilter_F_resolution` and `ultrafilter_P_resolution`

The MCS bijection approach is optimal because:
- `set_lindenbaum` (Zorn already done) provides the extension
- `mcsToUltrafilter`/`ultrafilterToSet_mcs` provide the bijection
- Avoids reimplementing Zorn directly on the Boolean algebra

The main work is:
1. Formulating `seed` correctly at the formula level
2. Proving `seed` is `SetConsistent` (the key case analysis)
3. Checking the `R_G`/`R_H` membership conditions line up via the bijection

---

## Evidence / Mathlib References

| Mathlib Lemma | Relevance | Status |
|---|---|---|
| `Ultrafilter.exists_ultrafilter_of_finite_inter_nonempty` | FIP → ultrafilter existence | Not directly applicable (wrong `Ultrafilter` type) |
| `Filter.generate_neBot_iff` | filter properness | Not directly applicable |
| `zorn_subset_nonempty` | Zorn's lemma | Already used in `set_lindenbaum` |
| `zorn_le_nonempty` | Alternative Zorn | Available if needed |
| `Axiom.temp_k_dist` | K for G | **Key axiom for sorry 1** |
| `DerivationTree.temporal_necessitation` | Necessitation for G | **Used in sorry 1** |
| `Bimodal.Theorems.Combinators.pairing` | A → B → A∧B | **Used in sorry 1** |
| `Bimodal.Theorems.Combinators.imp_trans` | Implication transitivity | **Used in sorry 1** |
| `set_lindenbaum` | MCS extension | **Key for sorries 2 and 3** |
| `mcsToUltrafilter` / `ultrafilterToSet_mcs` | MCS-ultrafilter bijection | **Key for sorries 2 and 3** |

---

## Risks and Mitigations

### Risk 1: `and_elim` Lemmas Missing

If `and_elim_left`/`and_elim_right` don't exist as named lemmas:

**Mitigation**: Prove them from `theorem_app`. Since `φ.and ψ = ¬(φ → ¬ψ)`:
- `and_elim_left`: Use `theorem_app1`: `⊢ A → (A → B) → B`. Set B := ⊥, then
  `⊢ A → ¬A → ⊥`... this gives `A → ¬¬A = A → (A → ⊥) → ⊥ = A → ¬A → ⊥`.
  Actually for `(A ∧ B) → A` where `A ∧ B = ¬(A → ¬B) = ((A → ¬B) → ⊥)`:
  ```
  -- (A → ¬B) → ⊥) → A
  -- contrapositive of (¬A → (A → ¬B))
  -- ¬A → A → ¬B  (from ex_falso / prop_k)
  -- so contrapositive gives us what we need
  ```
  This is buildable but tedious; check `Propositional.lean` first.

### Risk 2: Past K-Axiom

**CONFIRMED RESOLVED**: `past_k_dist` exists in
`Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` (line 81):

```lean
noncomputable def past_k_dist (A B : Formula) :
    ⊢ (A.imp B).all_past.imp (A.all_past.imp B.all_past)
```

It is derived via `temporal_duality` applied to `temp_k_dist`. This is exactly what
`H_preimage_inf` needs, and the proof structure mirrors `G_preimage_inf` exactly, replacing:
- `DerivationTree.temporal_necessitation` with the analogous past necessitation
- `Axiom.temp_k_dist` with `past_k_dist`

**Note**: `past_k_dist` also appears at line 725 of `Perpetuity/Principles.lean`.
The `GeneralizedNecessitation.lean` version is the canonical one.

### Risk 3: Formula-Level Seed Construction

The `G_preimage(U)` is defined at the algebra level (`Set LindenbaumAlg`), but `seed`
needs to be at the formula level (`Set Formula`) for `set_lindenbaum`.

**Mitigation**: Use `ultrafilterToSet U` to bridge (it is `{ φ | toQuot φ ∈ U }`).
The G-preimage at formula level is `{ ψ | ψ.all_future ∈ ultrafilterToSet U }`.
The `R_G` membership check then needs the chain:
`G_quot (toQuot ψ) ∈ U ↔ toQuot (ψ.all_future) ∈ U ↔ ψ.all_future ∈ ultrafilterToSet U`.

---

## Dependencies Map

```
G_preimage_inf (sorry 1)
    ↑
    |-- pairing (Combinators.lean)
    |-- temp_k_dist (Axioms.lean)
    |-- temporal_necessitation (DerivationTree)
    |-- imp_trans (Combinators.lean)
    |-- and_elim [check Propositional.lean]

H_preimage_inf (new, needed for sorry 3)
    ↑
    |-- analogous to G_preimage_inf (past K-axiom or temporal_duality)

ultrafilter_F_resolution (sorry 2)
    ↑
    |-- G_preimage_inf (sorry 1)  ← BLOCKER
    |-- set_lindenbaum
    |-- ultrafilterToSet_mcs
    |-- mcsToUltrafilter

ultrafilter_P_resolution (sorry 3)
    ↑
    |-- H_preimage_inf (new)  ← needs to be added
    |-- set_lindenbaum
    |-- ultrafilterToSet_mcs
    |-- mcsToUltrafilter
```
