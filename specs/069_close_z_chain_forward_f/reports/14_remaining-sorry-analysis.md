# Research Report: Remaining Sorries in f_preserving_seed_consistent

**Task**: 69 - close_z_chain_forward_f
**Session**: sess_1774905215_d7710e
**Date**: 2026-03-30
**Focus**: Lines 2068 and 2073 in f_preserving_seed_consistent

---

## Executive Summary

Two sorries remain at lines 2068 and 2073 in `f_preserving_seed_consistent`. Both arise from the same root cause: the proof attempts to derive `False` from an inconsistent subset of the seed, but the current proof structure cannot close the final contradiction in the `neg(G(phi))` branch.

**Key Finding**: The proof structure has a fundamental flaw. When `neg(G(phi)) ∈ M`, the proof constructs an inconsistent subset `[F(psi), phi, G(phi -> neg(F(psi)))]` of the seed - but this proves the seed IS inconsistent, contradicting our goal of proving consistency.

**Recommended Fix**: Restructure the entire proof using strong induction on F-formula count from the start, rather than trying to handle the `neg(G(phi))` case separately.

---

## Sorry 1: Line 2068 (G(phi) not in M subcase)

### Proof State
```lean
case pos.inr
M : Set Formula
h_mcs : SetMaximalConsistent M
phi : Formula
h_F : phi.some_future ∈ M
L : List Formula
h_L_sub : ∀ φ ∈ L, φ ∈ f_preserving_seed M phi
d : L ⊢ Formula.bot
psi : Formula
h_Fpsi_M : psi.some_future ∈ M
h_psi_not_M : psi ∉ M
L_no_F : List Formula := List.filter (fun x => decide (x ≠ psi.some_future)) L
L_no_phi : List Formula := List.filter (fun x => decide (x ≠ phi)) L_no_F
h_L_no_phi_standard : ∀ x ∈ L_no_phi, x ∈ temporal_box_seed M
h_G_imp : (phi.imp psi.some_future.neg).all_future ∈ M
h_neg_G_phi : phi.all_future.neg ∈ M  -- neg(G(phi)) ∈ M
h_d3 : [psi.some_future, phi, (phi.imp psi.some_future.neg).all_future] ⊢ Formula.bot
h_list_sub : ∀ x ∈ [psi.some_future, phi, (phi.imp psi.some_future.neg).all_future],
             x ∈ f_preserving_seed M phi
⊢ False
```

### Analysis

The proof has derived:
1. `G(phi -> G(neg psi)) ∈ M` via G-lift from `L_no_phi`
2. An explicit derivation `[F(psi), phi, G(phi -> G(neg psi))] ⊢ bot`
3. All three formulas are in `f_preserving_seed M phi`

**The fundamental problem**: This shows the seed IS inconsistent (we found a finite inconsistent subset). But we're trying to prove the seed is CONSISTENT. The proof by contradiction assumed `L ⊢ bot` for some L in the seed, and we've now proven this assumption is SATISFIABLE, not contradictory.

### Why neg(G(phi)) Blocks the Proof

When `G(phi) ∈ M`, the proof works:
- `G(phi) → G(G(neg psi)) ∈ M` (by K-axiom distribution)
- Modus ponens: `G(G(neg psi)) ∈ M`
- T-axiom: `G(neg psi) ∈ M`
- Contradiction with `F(psi) ∈ M`

When `neg(G(phi)) ∈ M` (i.e., `F(neg phi) ∈ M`):
- We have `G(phi) → G(neg psi) ∈ M`
- `G(phi) ∉ M` (since `neg(G(phi)) ∈ M`)
- The implication is vacuously true
- We cannot derive `G(neg psi) ∈ M`

### Root Cause

The proof structure handles `phi` extraction separately from F-formula extraction. This creates an asymmetry: extracting `phi` leaves us with `L_no_phi ⊢ phi → G(neg psi)`, which we try to G-lift. But the G-lift only works when `G(phi) ∈ M`.

The correct approach is to treat `phi` as "just another formula to extract" in the inductive process, building a disjunction that includes `neg(phi)`.

---

## Sorry 2: Line 2073 (Non-standard elements in L_no_phi)

### Proof State
```lean
case neg
M : Set Formula
h_mcs : SetMaximalConsistent M
phi : Formula
h_F : phi.some_future ∈ M
L : List Formula
h_L_sub : ∀ φ ∈ L, φ ∈ f_preserving_seed M phi
d : L ⊢ Formula.bot
psi : Formula
h_Fpsi_M : psi.some_future ∈ M
h_psi_not_M : psi ∉ M
L_no_F : List Formula := List.filter (fun x => decide (x ≠ psi.some_future)) L
L_no_phi : List Formula := List.filter (fun x => decide (x ≠ phi)) L_no_F
h_L_no_phi_standard : ¬∀ x ∈ L_no_phi, x ∈ temporal_box_seed M
⊢ False
```

### Analysis

`h_L_no_phi_standard` says that after filtering out `F(psi)` and `phi`, the remaining list `L_no_phi` still contains elements NOT in `temporal_box_seed M`. These must be OTHER F-formulas from `F_unresolved_theory M`.

The proof needs to:
1. Identify these additional F-formulas
2. Extract them one by one using the deduction theorem
3. Recursively apply the same argument
4. Eventually reach a context with only `temporal_box_seed` elements

### Why Strong Induction is Needed

Each F-formula extraction:
- Takes `L ⊢ bot` to `L \ {F(sigma)} ⊢ G(neg sigma)`
- Adds `G(neg sigma)` to the "disjunction accumulator"
- Decreases `List.countP (is_F_unresolved)` by 1

The induction terminates when no F-formulas remain, yielding a context in `temporal_box_seed M` that derives a disjunction of `G(neg sigma_i)` formulas.

---

## Recommended Solution: Refactored Strong Induction Proof

### Step 1: Define the Induction Measure

```lean
def countFUnresolved (M : Set Formula) (phi : Formula) (L : List Formula) : Nat :=
  L.countP (fun x => x ∈ F_unresolved_theory M ∧ x ∉ {phi} ∪ temporal_box_seed M)
```

Note: `phi` itself should NOT be counted, only F-formulas from `F_unresolved_theory M`.

### Step 2: Main Induction Lemma

```lean
lemma consistency_by_F_extraction (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ (n : Nat) (L : List Formula),
      (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
      countFUnresolved M phi L = n →
      ¬∃ d : DerivationTree L Formula.bot, True := by
  intro n
  induction n using Nat.strong_induction_on with
  | ind n ih =>
    intro L h_L_sub h_count
    intro ⟨d, _⟩
    by_cases h_zero : n = 0
    · -- Base case: all elements in {phi} ∪ temporal_box_seed M
      -- Apply temporal_theory_witness_consistent
      ...
    · -- Inductive case: extract one F-formula, recurse
      ...
```

### Step 3: Base Case (n = 0)

When `countFUnresolved M phi L = 0`:
- All elements of L are in `{phi} ∪ temporal_box_seed M`
- Apply `temporal_theory_witness_consistent M h_mcs phi h_F L`
- This already handles the `phi` extraction case correctly via G-lift

### Step 4: Inductive Case (n > 0)

```lean
obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero h_zero
-- Find F(sigma) in L from F_unresolved_theory
have ⟨F_sigma, hF_in_L, hF_unres⟩ := exists_F_in_L_of_count_pos h_count ...
-- Extract using deduction theorem
let L_no_F := L.filter (· ≠ F_sigma)
have d_neg : L_no_F ⊢ Formula.neg F_sigma := deduction_theorem ...
-- Count decreases
have h_count' : countFUnresolved M phi L_no_F < n.succ := ...
-- But we now have L_no_F ⊢ G(neg sigma), not L_no_F ⊢ bot!
-- Need to accumulate into a disjunction
```

### Step 5: The Disjunction Accumulation Pattern

The key insight is that extraction doesn't preserve `⊢ bot`. Instead:
- `L ⊢ bot` becomes `L \ {F(psi)} ⊢ G(neg psi)` (not bot!)
- Further extractions add to a disjunction: `L_core ⊢ G(neg psi_1) ∨ G(neg psi_2) ∨ ...`

The induction needs to track this disjunction:

```lean
lemma F_extraction_to_disjunction (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∀ (n : Nat) (L : List Formula) (target : Formula),
      (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
      countFUnresolved M phi L = n →
      L ⊢ target →
      ∃ (L_core : List Formula) (gs : List Formula),
        (∀ x ∈ L_core, x ∈ {phi} ∪ temporal_box_seed M) ∧
        (∀ g ∈ gs, ∃ sigma, g = G(neg sigma) ∧ F(sigma) ∈ F_unresolved_theory M) ∧
        L_core ⊢ (gs.foldr Formula.or target)
```

### Step 6: Final Contradiction

After full extraction with `target = bot`:
1. `L_core ⊆ {phi} ∪ temporal_box_seed M`
2. `L_core ⊢ G(neg sigma_1) ∨ ... ∨ G(neg sigma_k)` (the "or-bot" = disjunction)
3. By `temporal_theory_witness_consistent`: `L_core` is consistent
4. So `G(neg sigma_1) ∨ ... ∈ M` (since derivable from consistent subset)
   Wait - this doesn't work. L_core being consistent doesn't mean its derivations are in M.

**Alternative final step**:
1. Handle `phi` extraction specially at the end
2. After extracting all F-formulas AND phi:
   - `L_final ⊆ temporal_box_seed M`
   - `L_final ⊢ (G(neg sigma_1) ∨ ...) ∨ neg(phi)` (phi included in disjunction)
3. G-lift: `G((G(neg sigma_1) ∨ ...) ∨ neg(phi)) ∈ M`
4. By modal logic: `G(G(neg sigma_1)) ∨ ... ∨ G(neg phi) ∈ M`
5. By T-axiom: at least one `G(neg sigma_i) ∈ M` or `G(neg phi) ∈ M`
6. If `G(neg phi) ∈ M`: contradicts `F(phi) ∈ M`
7. If `G(neg sigma_i) ∈ M`: contradicts `F(sigma_i) ∈ M` (from F_unresolved_theory)

---

## Key Mathlib Lemmas

### For Strong Induction
- `Nat.strong_induction_on : ∀ {p : ℕ → Prop} (n : ℕ), (∀ n, (∀ m < n, p m) → p n) → p n`
- `Nat.strongRecOn' : {P : ℕ → Sort*} → (n : ℕ) → ((n : ℕ) → ((m : ℕ) → m < n → P m) → P n) → P n`

### For List Count Manipulation
- `List.countP_filter : countP p (filter q l) = countP (fun a => p a && q a) l`
- `List.countP_eq_countP_filter_add : countP p l = countP p (filter q l) + countP p (filter (!q) l)`
- `List.countP_pos : 0 < countP p l ↔ ∃ a ∈ l, p a`

### For Showing Count Decreases
When filtering out element `x` from `L` where `p x = true`:
```lean
theorem countP_filter_ne_lt {α} [DecidableEq α] {p : α → Bool} {L : List α} {x : α}
    (hx : x ∈ L) (hp : p x) :
    List.countP p (L.filter (· ≠ x)) < List.countP p L
```
This may need to be proven locally if not in Mathlib.

---

## Implementation Recommendation

1. **Delete the current proof structure** at lines 1384-2101 (the complex case analysis)

2. **Replace with a single strong induction proof** that:
   - Extracts F-formulas AND phi together into a disjunction
   - Ends with G-lift from pure `temporal_box_seed M` context
   - Uses `G_of_disjunction_in_mcs_elim` to get witness
   - Applies `some_future_excludes_all_future_neg` for contradiction

3. **Estimated lines**: 80-120 lines (vs current 700+ lines with sorries)

4. **Key helper lemma needed**:
   ```lean
   theorem countP_filter_out_element_lt ...
   ```

---

## Verification Checklist

- [ ] `Nat.strong_induction_on` signature verified in Mathlib
- [ ] `List.countP_filter` signature verified in Init.Data.List.Count
- [ ] `G_of_disjunction_in_mcs_elim` exists at line 1255 (verified)
- [ ] `some_future_excludes_all_future_neg` exists at line 1090 (verified)
- [ ] `G_lift_from_context` exists at line 1066 (verified)
- [ ] `temporal_theory_witness_consistent` handles base case (needs verification)
