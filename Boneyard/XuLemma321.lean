/-
# Xu's Lemma 3.2.1 (i) and (ii) — Archived from RRelation.lean

These theorems state that BurgessR3Maximal(A, B, C) implies B is closed under
Until formation (with C) and Since formation (with A). They correspond to
Xu's Lemma 3.2.1 in his PhD thesis on chronicle constructions.

## Why archived

The proof by contradiction splits into two sub-cases:
- **Consistent case** (B ∪ {formula} is consistent): Works — deductive closure
  gives a proper DCS extension still satisfying burgessR3, contradicting maximality.
- **Inconsistent case** (B ∪ {formula} is inconsistent): Blocked. Having
  ¬(β U γ) ∈ B should lead to contradiction, but `untl(⊥, δ)` is satisfiable
  on discrete orders (where the open guard interval (t,s) can be empty). Without
  BX9 (removed as unsound under open guard semantics), ¬(⊥ U δ) is not derivable
  in the proof system.

## Downstream usage

None. No theorem in CounterexampleElimination.lean, ChronicleToCountermodel.lean,
or any other file references these. They were infrastructure for potential future use.

## Recovery options (if needed later)

1. Strengthen `BurgessR3Maximal` definition to directly encode Xu's 2.0(iii) witness property.
2. Prove B ∪ {untl(β,γ)} is always consistent using a model-theoretic argument.
3. Add a "guard non-vacuity" axiom (e.g., untl(⊥, φ) → ⊥) restricting to dense orders.
4. Find a novel proof avoiding the inconsistency case entirely.

## Original location

RRelation.lean, lines 1419–1482 (as of commit 51bdc854d on irr_until branch).
-/

-- The original code is preserved below for reference. It will not compile
-- standalone since it depends on the full Chronicle namespace and imports.

/-
/--
**Xu's Lemma 3.2.1(i)**: BurgessR3Maximal(A, B, C) implies B is closed under
Until formation: for β ∈ B and γ ∈ C, untl(β, γ) ∈ B.

Proof by contradiction:
1. Assume untl(β, γ) ∉ B.
2. B ∪ {untl(β, γ)} is consistent (else neg(untl(β,γ)) ∈ B, derive contradiction).
3. B' = DC(B ∪ {untl(β, γ)}) properly extends B and is DCS.
4. burgessRSet(A, B', C): by BX5 argument (core helper above).
5. burgessRSetSince(C, B', A): by Burgess 2.3 equivalence.
6. So burgessR3(A, B', C), contradicting maximality.
-/
theorem burgessR3Maximal_untl_mem_B {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_max : BurgessR3Maximal A B C)
    {β : Formula} (hβ : β ∈ B) {γ : Formula} (hγ : γ ∈ C) :
    Formula.untl β γ ∈ B := by
  by_contra h_not
  have h_dcs := h_max.1
  have h_r3 := h_max.2.1
  have h_maximal := h_max.2.2
  sorry

/--
**Xu's Lemma 3.2.1(ii)**: BurgessR3Maximal(A, B, C) implies B is closed under
Since formation: for β ∈ B and α ∈ A, snce(β, α) ∈ B.

Mirror of `burgessR3Maximal_untl_mem_B` using BX5' + BX2'/BX3'.
-/
theorem burgessR3Maximal_snce_mem_B {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_max : BurgessR3Maximal A B C)
    {β : Formula} (hβ : β ∈ B) {α : Formula} (hα : α ∈ A) :
    Formula.snce β α ∈ B := by
  sorry
-/
