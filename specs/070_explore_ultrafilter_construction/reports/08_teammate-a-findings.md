# Teammate A Findings: Strong Induction for Seed Consistency Sorries

**Task**: Resolve the corner-case sorries in `ultrafilter_F_resolution` and `ultrafilter_P_resolution`
**File**: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
**Sorries**: Lines ~1113 (F_resolution) and ~1322 (P_resolution, symmetric)

---

## Key Findings

- The sorry at line 1113 is NOT provable as-is from the immediately available hypotheses. The `exfalso` framing is wrong — the case does not lead to an internal contradiction; it requires restructuring the proof strategy.
- The correct fix is a proof by **strong induction on `L.count φ`** (number of φ occurrences in the list), applied at the level of the whole `φ ∈ L` branch of `h_seed_cons`, not just within `hL_no_phi_in_Gseed`.
- The induction works because each application of the deduction theorem strictly reduces the count of φ in the list.
- Formula has `DecidableEq` (from `deriving DecidableEq` in `Formula.lean`), so `List.count` is available.
- Lean 4 / Mathlib provides: `List.count_erase_self`, `List.erase_subset`, and the existing `deduction_theorem` in `Bimodal.Metalogic.Core`.
- The P_resolution sorry at line 1322 is entirely symmetric and resolved by the identical approach substituting H_seed for G_seed.

---

## Recommended Approach: Strong Induction on φ-Count

### The Core Insight

When `φ ∈ L` and we form `L_no_phi = L_pre ++ L_post`, it is possible that `φ ∈ L_no_phi` (if L contained multiple copies of φ). The current proof attempts `hL_no_phi_in_Gseed : ∀ ψ ∈ L_no_phi, ψ ∈ G_seed` but hits the sorry when ψ = φ and φ ∉ G_seed.

The mathematical reality: if `L_no_phi ⊢ ¬φ` and `φ ∈ L_no_phi`, we can apply the deduction theorem again to get `(L_no_phi.erase φ) ⊢ φ → ¬φ`. Since `φ → ¬φ` is derivably equivalent to `¬φ` (via contraction: `A → A → B ↔ A → B`), we obtain `(L_no_phi.erase φ) ⊢ ¬φ`. This strictly reduces `L_no_phi.count φ`, giving a well-founded recursion.

### The Contraction Step

The key sub-lemma needed (not yet in the codebase):

```lean
-- Contraction: if φ ∈ L and L ⊢ ¬φ, then (L.erase φ) ⊢ ¬φ
lemma derive_neg_erase_phi (L : List Formula) (φ : Formula)
    (h_mem : φ ∈ L) (d : L ⊢ φ.neg) : L.erase φ ⊢ φ.neg := by
  -- Step 1: by deduction theorem: (L.erase φ) ⊢ φ → ¬φ
  have d_rearranged : DerivationTree (φ :: L.erase φ) Formula.bot := by
    apply DerivationTree.weakening L (φ :: L.erase φ) Formula.bot
      (DerivationTree.weakening (L.erase φ) L φ.neg d (List.erase_subset))
    -- φ :: (L.erase φ) contains the same elements as L
    intro ψ hψ
    simp only [List.mem_cons]
    by_cases h : ψ = φ
    · left; exact h
    · right; exact List.mem_erase_of_ne h |>.mpr (List.mem_erase_of_ne h |>.mp sorry)
    -- (needs List membership reasoning)
  have d_imp : L.erase φ ⊢ φ.imp φ.neg :=
    Bimodal.Metalogic.Core.deduction_theorem (L.erase φ) φ Formula.bot d_rearranged
  -- Step 2: φ → ¬φ is equivalent to ¬φ (contraction)
  -- ¬φ = φ → ⊥. φ → (φ → ⊥) is A → A → B style contraction.
  -- We need: from L.erase φ ⊢ φ → (φ → ⊥), derive L.erase φ ⊢ φ → ⊥
  -- This is: Γ ⊢ (A → A → B) → (A → B) which follows from axiom prop_k (S) pattern
  sorry -- see detailed sketch below
```

**Actually, a cleaner route**: rather than proving a contraction lemma, restructure the proof to directly carry the right inductive invariant.

### Proof Restructuring: Replace the φ ∈ L Branch

The `φ ∈ L` case in `h_seed_cons` should be replaced with a call to a helper lemma that has the right inductive structure.

```lean
-- Helper: If L ⊆ G_seed ∪ {φ} and L ⊢ ¬φ, then G(¬φ) ∈ U
-- (regardless of how many times φ appears in L)
have h_derive_neg_to_U : ∀ (L : List Formula),
    (∀ ψ ∈ L, ψ ∈ seed) → DerivationTree L φ.neg →
    STSA.G (toQuot φ.neg) ∈ U := by
  -- Induction on L.count φ
  intro L
  induction h : L.count φ using Nat.strong_rec_on generalizing L with
  | _ n ih => ...
```

### Detailed Proof Sketch

The restructured `φ ∈ L` case proceeds as follows:

```lean
-- In h_seed_cons, φ ∈ L branch:
-- Step A: Extract φ from L to get L_no_phi = L_pre ++ L_post
have ⟨L_pre, L_post, h_L_eq⟩ := List.append_of_mem h_phi_in_L
let L_no_phi := L_pre ++ L_post

-- Step B: Derive L_no_phi ⊢ ¬φ (as currently done)
have d_neg_phi : DerivationTree L_no_phi φ.neg := ...  -- existing code

-- Step C: Prove G(¬φ) ∈ U by strong induction on L_no_phi.count φ
-- This replaces both hL_no_phi_in_Gseed and h_G_fold_in_U with a single inductive argument

-- Key inductive helper (extracted as a separate have or top-level lemma):
suffices h : STSA.G (toQuot φ.neg) ∈ U by
  exact h_G_neg_phi_not_in_MU h  -- contradiction!

-- The inductive helper: ∀ L' with L' ⊆ seed and L' ⊢ ¬φ, G(¬φ) ∈ U
-- Induct on L'.count φ
-- This is the replacement for the problematic hL_no_phi_in_Gseed step
```

### The Inductive Helper Lemma

The key new lemma to add (as a `have` or separate `lemma`):

```lean
-- If L ⊆ G_seed ∪ {φ} and L ⊢ ¬φ, then G(¬φ) ∈ U
-- Proof by strong induction on L.count φ
have key_induction :
    ∀ (L' : List Formula), (∀ ψ ∈ L', ψ ∈ seed) →
    DerivationTree L' φ.neg →
    STSA.G (toQuot φ.neg) ∈ U := by
  intro L' hL'_in_seed d_neg
  -- Induction on the number of φ occurrences in L'
  induction hc : L'.count φ using Nat.strong_rec_on generalizing L' with
  | ind n ih =>
    -- Separate L' into φ-elements and non-φ elements
    -- Let L'_Gseed = L'.filter (· ≠ φ), which has all elements in G_seed
    -- (because seed = G_seed ∪ {φ}, so any ψ ∈ L' with ψ ≠ φ is in G_seed)
    by_cases h_phi_count : L'.count φ = 0
    · -- Base case: φ does not appear in L'
      -- All elements of L' are in G_seed (since φ ∉ L')
      have hL'_in_Gseed : ∀ ψ ∈ L', ψ ∈ G_seed := by
        intro ψ hψ
        rcases hL'_in_seed ψ hψ with hG | heq
        · exact hG
        · -- ψ = φ, but then L'.count φ ≥ 1, contradicting h_phi_count = 0
          exfalso
          rw [heq] at hψ
          have : 0 < L'.count φ := List.count_pos_iff.mpr ⟨hψ, rfl⟩
          omega
      -- Now proceed with the existing fold argument:
      -- G(fold L') ∈ U by the h_helper induction over L'
      -- G(fold L') ≤ G(¬φ) since L' ⊢ ¬φ
      -- Therefore G(¬φ) ∈ U  ✓
      -- (This is exactly the existing code after hL_no_phi_in_Gseed)
      have h_fold_le := fold_le_of_derives L' φ.neg d_neg
      have h_G_fold_in_U : STSA.G (List.foldl (fun acc ψ => acc ⊓ toQuot ψ) ⊤ L') ∈ U := by
        -- ... existing helper_h induction proof ...
        sorry -- fills with existing code verbatim
      exact U.mem_of_le h_G_fold_in_U (STSA.G_monotone _ _ h_fold_le)

    · -- Inductive step: φ appears in L' (count ≥ 1)
      -- Use deduction theorem to remove one φ, then apply contraction
      have h_phi_in_L' : φ ∈ L' := by
        apply List.count_pos_iff.mp
        omega
      -- Apply deduction theorem: (L'.erase φ) ⊢ φ → ¬φ
      have d_rearranged : DerivationTree (φ :: L'.erase φ) Formula.bot := by
        apply DerivationTree.weakening L' (φ :: L'.erase φ)
        · exact d_neg  -- L' ⊢ φ.neg = L' ⊢ φ → ⊥
        · -- need: L' ⊆ φ :: L'.erase φ  (multiset containment)
          sorry  -- requires List.erase_append reasoning
      have d_phi_imp : L'.erase φ ⊢ φ.imp φ.neg :=
        Bimodal.Metalogic.Core.deduction_theorem (L'.erase φ) φ Formula.bot d_rearranged
      -- Apply contraction: (φ → φ → ⊥) → (φ → ⊥)
      -- i.e., derive (L'.erase φ) ⊢ ¬φ from (L'.erase φ) ⊢ φ → ¬φ
      -- and  (L'.erase φ) ⊢ φ    ... wait this is wrong.
      -- Correct: d_phi_imp says "from L'.erase φ, assuming φ, derive ¬φ"
      -- Contraction step uses: if Γ ⊢ A → (A → B) then Γ ⊢ A → B
      -- (by applying the S axiom: S:(A→A→B)→(A→A)→(A→B), and A→A by identity)
      -- Here A = φ, B = ⊥, Γ = L'.erase φ
      -- Actually, d_phi_imp says Γ ⊢ φ → (φ → ⊥)
      -- By contraction (S-axiom applied): Γ ⊢ φ → ⊥ = Γ ⊢ ¬φ
      have d_neg' : L'.erase φ ⊢ φ.neg := by
        -- contraction: from Γ ⊢ A → A → B, derive Γ ⊢ A → B
        -- Use: Γ ⊢ (A → A → B) → (A → B)  (this is a propositional theorem)
        -- = Γ ⊢ (φ → φ → ⊥) → (φ → ⊥)
        have contract_thm : [] ⊢ (φ.imp (φ.imp Formula.bot)).imp (φ.imp Formula.bot) := by
          -- This is: ⊢ (A → A → B) → (A → B)
          -- Proof: assume A → A → B and A. Apply mp twice.
          -- By deduction theorem: [(A → A → B), A] ⊢ B
          -- Then deduction theorem twice gives the result.
          sorry  -- needs to be constructed from existing combinators
        apply DerivationTree.modus_ponens (L'.erase φ) _ _ _ d_phi_imp
        exact DerivationTree.weakening [] (L'.erase φ) _ contract_thm (by intro; simp)
      -- Now apply ih: L'.erase φ has count φ = L'.count φ - 1 < L'.count φ
      apply ih (L'.count φ - 1) (by omega) (L'.erase φ)
      · -- L'.erase φ ⊆ seed
        intro ψ hψ
        exact hL'_in_seed ψ (List.erase_subset hψ)
      · exact d_neg'
      · -- count: (L'.erase φ).count φ = L'.count φ - 1
        exact List.count_erase_self  -- from Init.Data.List.Count
```

### The Missing Contraction Lemma

The proof needs `contract_thm : ⊢ (A → A → B) → (A → B)`. This does not appear to be in the codebase yet. It can be derived as follows:

```lean
-- ⊢ (A → A → B) → (A → B)
def contraction (A B : Formula) : ⊢ (A.imp (A.imp B)).imp (A.imp B) := by
  -- Assume [(A → A → B), A] and derive B
  have inner : [A.imp (A.imp B), A] ⊢ B := by
    have h1 : [A.imp (A.imp B), A] ⊢ A.imp (A.imp B) :=
      DerivationTree.assumption [A.imp (A.imp B), A] _ (by simp)
    have h2 : [A.imp (A.imp B), A] ⊢ A :=
      DerivationTree.assumption [A.imp (A.imp B), A] _ (by simp)
    have h3 : [A.imp (A.imp B), A] ⊢ A.imp B :=
      DerivationTree.modus_ponens _ _ _ h1 h2
    exact DerivationTree.modus_ponens _ _ _ h3 h2
  -- Apply deduction_theorem twice
  have step1 : [A.imp (A.imp B)] ⊢ A.imp B :=
    Bimodal.Metalogic.Core.deduction_theorem [A.imp (A.imp B)] A B inner
  exact Bimodal.Metalogic.Core.deduction_theorem [] (A.imp (A.imp B)) (A.imp B) step1
```

This is provable from first principles using only `DerivationTree.assumption`, `DerivationTree.modus_ponens`, and `deduction_theorem`. It should be added to `Theorems/Propositional.lean` or `Theorems/Combinators.lean`.

### The L' ⊆ φ :: L'.erase φ Step

The step that `L' ⊆ φ :: L'.erase φ` (as multisets/lists for weakening) needs:
- `List.erase_subset : L.erase a ⊆ L`
- `List.mem_cons` reasoning

The key fact: for any `ψ ∈ L'`, either `ψ = φ` (so `ψ ∈ φ :: L'.erase φ` by `List.mem_cons_self`) or `ψ ≠ φ` and `ψ ∈ L'.erase φ` (since `List.erase` only removes ONE occurrence of φ, all non-φ elements are retained). This is:

```lean
-- ∀ ψ ∈ L', ψ ∈ φ :: L'.erase φ
intro ψ hψ
by_cases h : ψ = φ
· exact List.mem_cons_self φ _ |> h ▸ ·
· exact List.mem_cons_of_mem φ (List.mem_erase_of_ne h |>.mpr hψ)
```

The lemma `List.mem_erase_of_ne : a ≠ b → (a ∈ l.erase b ↔ a ∈ l)` (or its equivalent) should be available in Lean 4 core / Mathlib.

---

## Evidence / Code References

| Item | Location |
|------|----------|
| `sorry` at F_resolution | `UltrafilterChain.lean` line 1113, inside `hL_no_phi_in_Gseed`, inside `h_seed_cons` |
| `sorry` at P_resolution | `UltrafilterChain.lean` line 1322, symmetric structure |
| `deduction_theorem` signature | `Bimodal.Metalogic.Core.deduction_theorem (Γ) (A B) (h : A :: Γ ⊢ B) : Γ ⊢ A.imp B` |
| `fold_le_of_derives` | `UltrafilterMCS.lean`, used at line 1117 |
| `List.count_erase_self` | `Init.Data.List.Count`, type: `List.count a (l.erase a) = List.count a l - 1` |
| `List.erase_subset` | `Init.Data.List.Erase`, type: `l.erase a ⊆ l` |
| `Formula` has `DecidableEq` | `Syntax/Formula.lean` line 79: `deriving Repr, DecidableEq, BEq, Hashable, Countable` |
| G_preimage_inf | `UltrafilterChain.lean` line 721, used at line 1142 |
| The existing "φ ∉ L" case | Lines 1156-1201, shows the successful pattern for G_seed-only lists |

### The Two Symmetric Sorries

Both sorries follow exactly the same logical structure:
- Line 1113: `G_seed = { ψ | ψ.all_future ∈ MU }`, uses `STSA.G`, `G_preimage_inf`
- Line 1322: `H_seed = { ψ | ψ.all_past ∈ MU }`, uses `STSA.H`, `H_preimage_inf`

The proof for line 1322 is line-for-line identical to the fix for line 1113, substituting `H_seed`, `H`, `all_past`, `H_preimage_inf`.

---

## Implementation Plan

The cleanest implementation has three components:

### Component 1: Add `contraction` to Combinators or Propositional (new lemma)

```lean
-- File: Theories/Bimodal/Theorems/Combinators.lean or Propositional.lean
def contraction (A B : Formula) : ⊢ (A.imp (A.imp B)).imp (A.imp B)
```

This is derivable from existing `DerivationTree.assumption`, `DerivationTree.modus_ponens`, and `deduction_theorem`. Estimated 10-15 lines.

### Component 2: Restructure the `φ ∈ L` branch of `h_seed_cons`

Replace the current `hL_no_phi_in_Gseed` have-chain with a strong induction on `L_no_phi.count φ`. The induction is an inner `have` block using `Nat.strongRecOn` or `induction hc : L_no_phi.count φ using Nat.strong_rec_on`.

The **base case** (`count = 0`) reproduces the existing lines 1115-1154 verbatim (the fold argument works when all elements are in G_seed).

The **inductive step** (`count = n+1`) applies deduction theorem + contraction to reduce to count `n`, then applies the inductive hypothesis.

### Component 3: Apply the symmetric fix to P_resolution (line 1322)

Identical restructuring, substituting H for G throughout.

---

## Confidence Assessment

**Confidence: High (85%)**

### Why High

1. The mathematical argument is sound: `φ → (φ → ⊥)` derives to `φ → ⊥` via contraction, which is a standard theorem of propositional logic provable in any Hilbert system with the S and K axioms (which this system has via `prop_s` and `prop_k`).

2. The induction measure `L.count φ` is strictly decreasing: `List.count_erase_self` gives `(L.erase φ).count φ = L.count φ - 1`, so the recursion terminates.

3. `List.erase_subset` ensures the weakening step `L.erase φ ⊆ L` goes through.

4. `DecidableEq Formula` is available, so `List.count` is well-typed.

5. The base case exactly matches the existing proof pattern (lines 1120-1154), which compiles successfully in the symmetric "φ ∉ L" branch.

### Remaining Uncertainty (15%)

- The `contraction` lemma, while mathematically trivial, needs to be encoded in the specific Hilbert system syntax used in this codebase. The proof should work but there is some risk the combinator encoding is not exactly right on the first attempt.

- The `L' ⊆ φ :: L'.erase φ` membership step requires finding the right Lean 4 / Mathlib lemma for `List.mem_erase_of_ne`. The lemma exists (confirmed via Loogle: `List.count_erase_of_ne` exists in `Init.Data.List.Count`), but the exact name for the membership version needs checking.

- `Nat.strong_rec_on` vs `Nat.strongRecOn` naming convention needs verification in Lean 4.27.

### What Would Lower Confidence

- If there is no `Nat.strong_rec_on` available and `omega` + `termination_by` is needed instead.
- If the Hilbert system does not admit `contraction` due to the presence of weakening in derivation trees (it should, since weakening is a rule, not a structural axiom, but needs checking).

---

## Alternative Approach (Simpler, If Available)

An even simpler approach avoids induction entirely: instead of working with `L_no_phi`, define `L_Gseed = L_no_phi.filter (· ≠ φ)` from the start, show:

1. `(L_Gseed ++ (List.replicate (L_no_phi.count φ) φ)) ⊢ ¬φ` (by weakening from `L_no_phi ⊢ ¬φ`)
2. By applying deduction theorem `L_no_phi.count φ` times, get `L_Gseed ⊢ φ → φ → ... → ¬φ`
3. By applying contraction `L_no_phi.count φ - 1` times, get `L_Gseed ⊢ ¬φ`
4. Since all elements of `L_Gseed` are in `G_seed`, proceed with the fold argument.

This produces a closed-form rather than an inductive argument, but requires the same `contraction` lemma and also requires formalizing "apply deduction theorem k times." The strong induction approach is preferable because it can be expressed as a single Lean 4 `induction` block.
