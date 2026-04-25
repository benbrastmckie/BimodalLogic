import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Theorems.TemporalDerived
import Bimodal.Theorems.Propositional
import Mathlib.Order.Zorn

/-!
# r-Relation Lemmas (Burgess 1982, Lemmas 2.2-2.3)

This module proves the foundational lemmas about the r-relation
from Burgess 1982 Section 2, adapted for irreflexive (strict) temporal semantics.

## Main Results

- `until_disjunction_in_mcs` (weakened Lemma 2.2): If `gamma U delta in A` for MCS A,
  then `gamma ∨ delta in A`. (The stronger "{gamma} consistent" is FALSE for gamma = bot.)

- `rRelation_guard_continues` (Lemma 2.3 consequence): If r(A, B) and
  gamma U delta in A with delta not in B, then gamma in B and gamma U delta in B.

- `rRelation_dcs_seed`: Any MCS is a valid r-relation partner for itself.

- `rMaximal_extension_exists`: Existence of R-maximal DCS extensions via Zorn's lemma.

- `deductiveClosure_is_dcs`: The deductive closure of a consistent set is a DCS.

## Adaptation for Strict Semantics

Under strict semantics, A3a is not valid. The r-relation lemmas use:
- BX5 (self_accum_until): `(phi U psi) -> ((phi ∧ (phi U psi)) U psi)`
- BX9 (until_elim): `(phi U psi) -> (phi ∨ psi)`
- BX10 (until_F): `(phi U psi) -> F(psi)`

## References

- Burgess 1982: "Axioms for tense logic II: Time periods", Lemmas 2.2-2.3
-/

namespace Bimodal.Metalogic.BXCanonical.Chronicle

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Combinators

/-! ## Note on Lemma 2.2 (Until Guard Consistency)

Burgess's Lemma 2.2 states: if `gamma U delta in A` for MCS A, then `{gamma}` is
consistent. This is **FALSE** under strict (irreflexive) Until semantics for gamma = bot.

**Concrete counterexample**: Let gamma = bot. Then {bot} is trivially inconsistent
(it derives bot). But bot U delta can be in an MCS A: by BX9 (until_elim),
bot U delta -> bot ∨ delta = delta, so delta ∈ A. The formula bot U delta is
semantically absurd on dense orders (the guard bot can never hold at any point)
but is syntactically consistent with the BX axiom system -- BX9 only gives
bot ∨ delta, not bot, so no contradiction in A.

The correct weaker statement IS provable: `gamma U delta ∈ A -> gamma ∨ delta ∈ A`
(see `until_disjunction_in_mcs` below). The chronicle construction uses the
r-relation machinery instead of guard consistency; no downstream code depends
on this lemma.

Withdrawn in Phase 1 of the revised plan (task 107).
-/

/--
Variant of Lemma 2.2 that IS provable: `gamma U delta in A` implies
`gamma ∨ delta in A` (and in particular, either gamma or delta is in A).

This follows directly from BX9 (until_elim).
-/
theorem until_disjunction_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    Formula.or γ δ ∈ A := by
  have h_elim : DerivationTree [] ((Formula.untl γ δ).imp (Formula.or γ δ)) :=
    DerivationTree.axiom [] _ (Axiom.until_elim γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_elim) h_until

/--
`gamma U delta in A` implies `F(delta) in A` (by BX10).
-/
theorem until_implies_F_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    Formula.some_future δ ∈ A := by
  have h_F : DerivationTree [] ((Formula.untl γ δ).imp (Formula.some_future δ)) :=
    DerivationTree.axiom [] _ (Axiom.until_F γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_F) h_until

/--
`gamma U delta in A` implies `(gamma ∧ (gamma U delta)) U delta in A` (by BX5).
-/
theorem until_self_accum_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    Formula.untl (Formula.and γ (Formula.untl γ δ)) δ ∈ A := by
  have h_sa : DerivationTree []
      ((Formula.untl γ δ).imp
        (Formula.untl (Formula.and γ (Formula.untl γ δ)) δ)) :=
    DerivationTree.axiom [] _ (Axiom.self_accum_until γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_sa) h_until

/--
`gamma S delta in A` implies `delta ∨ (gamma ∧ (gamma S delta)) in A`.
Derived from BX5' + BX9'.
-/
theorem since_disjunction_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_since : Formula.snce γ δ ∈ A) :
    Formula.or γ δ ∈ A := by
  have h_elim : DerivationTree [] ((Formula.snce γ δ).imp (Formula.or γ δ)) :=
    DerivationTree.axiom [] _ (Axiom.since_elim γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_elim) h_since

/--
`gamma S delta in A` implies `P(delta) in A` (by BX10').
-/
theorem since_implies_P_in_mcs {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_since : Formula.snce γ δ ∈ A) :
    Formula.some_past δ ∈ A := by
  have h_P : DerivationTree [] ((Formula.snce γ δ).imp (Formula.some_past δ)) :=
    DerivationTree.axiom [] _ (Axiom.since_P γ δ)
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs h_P) h_since

/-! ## Lemma 2.3: r-Relation Properties -/

/--
**Key property from Lemma 2.3**: If r(A, B) and gamma U delta in A with delta not in B,
then gamma in B and gamma U delta in B.

This is the "guard continues" property of the r-relation.
-/
theorem rRelation_guard_continues' {A B : Set Formula}
    (h_r : rRelation A B) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) (h_not_delta : δ ∉ B) :
    γ ∈ B ∧ Formula.untl γ δ ∈ B := by
  rcases h_r γ δ h_until with h_delta | h_guard
  · exact absurd h_delta h_not_delta
  · exact h_guard

/--
The r-relation for any MCS B such that A ⊆ B.

If A ⊆ B and B is an MCS, then r(A, B) holds because:
For gamma U delta ∈ A, we have gamma U delta ∈ B (by subset).
By BX9 in B: gamma ∨ delta ∈ B. By MCS negation completeness,
either gamma ∈ B (right disjunct with gamma U delta ∈ B)
or ¬gamma ∈ B, and from gamma ∨ delta (= ¬gamma → delta): delta ∈ B.
-/
theorem rRelation_of_subset_mcs {A B : Set Formula}
    (h_mcs_B : SetMaximalConsistent B)
    (h_sub : A ⊆ B) : rRelation A B :=
  rRelation_of_superset_mcs h_mcs_B h_sub

/-! ## Deductive Closure -/

/--
Deductive closure of a set: the set of all formulas derivable from finite subsets of S.
-/
noncomputable def deductiveClosure (S : Set Formula) : Set Formula :=
  {φ | ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ S) ∧ Nonempty (DerivationTree L φ)}

/-- The deductive closure contains the original set. -/
theorem subset_deductiveClosure (S : Set Formula) : S ⊆ deductiveClosure S := by
  intro φ hφ
  exact ⟨[φ], fun ψ hψ => by simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ; exact hψ ▸ hφ,
         ⟨DerivationTree.assumption _ φ (by simp)⟩⟩

/-- The deductive closure is closed under derivation. -/
theorem deductiveClosure_closed (S : Set Formula) :
    ∀ (L : List Formula) (φ : Formula),
      (∀ ψ ∈ L, ψ ∈ deductiveClosure S) → DerivationTree L φ → φ ∈ deductiveClosure S := by
  intro L
  induction L with
  | nil =>
    intro φ _ d
    exact ⟨[], fun _ h => absurd h List.not_mem_nil, ⟨d⟩⟩
  | cons ψ L' ih =>
    intro φ hL d
    -- (ψ :: L') ⊢ φ. By deduction theorem: L' ⊢ ψ.imp φ.
    have d_imp : DerivationTree L' (ψ.imp φ) := deduction_theorem L' ψ φ d
    -- ψ ∈ deductiveClosure S
    have hψ := hL ψ (List.mem_cons_self)
    -- L' ⊆ deductiveClosure S
    have hL' : ∀ χ ∈ L', χ ∈ deductiveClosure S :=
      fun χ hχ => hL χ (List.mem_cons_of_mem ψ hχ)
    -- By IH (with ψ.imp φ): ψ.imp φ ∈ deductiveClosure S
    have h_imp := ih (ψ.imp φ) hL' d_imp
    -- Combine: ψ and ψ.imp φ are both in deductiveClosure S
    obtain ⟨M1, hM1_sub, ⟨d1⟩⟩ := h_imp  -- M1 ⊢ ψ → φ, M1 ⊆ S
    obtain ⟨M2, hM2_sub, ⟨d2⟩⟩ := hψ      -- M2 ⊢ ψ, M2 ⊆ S
    -- Take M = M1 ++ M2, derive M ⊢ φ by modus ponens
    refine ⟨M1 ++ M2, fun χ hχ => ?_, ?_⟩
    · rcases List.mem_append.mp hχ with h | h
      · exact hM1_sub χ h
      · exact hM2_sub χ h
    · have d1' : DerivationTree (M1 ++ M2) (ψ.imp φ) :=
        DerivationTree.weakening M1 (M1 ++ M2) (ψ.imp φ) d1
          (List.subset_append_left M1 M2)
      have d2' : DerivationTree (M1 ++ M2) ψ :=
        DerivationTree.weakening M2 (M1 ++ M2) ψ d2
          (List.subset_append_right M1 M2)
      exact ⟨DerivationTree.modus_ponens (M1 ++ M2) ψ φ d1' d2'⟩

/-- If S is consistent, then deductiveClosure S is consistent. -/
theorem deductiveClosure_consistent {S : Set Formula} (h : SetConsistent S) :
    SetConsistent (deductiveClosure S) := by
  intro L hL ⟨d⟩
  have h_bot : Formula.bot ∈ deductiveClosure S :=
    deductiveClosure_closed S L Formula.bot hL d
  obtain ⟨M, hM_sub, ⟨dM⟩⟩ := h_bot
  exact h M hM_sub ⟨dM⟩

/-- The deductive closure of a consistent set is a DCS. -/
theorem deductiveClosure_is_dcs {S : Set Formula} (h : SetConsistent S) :
    SetDeductivelyClosed (deductiveClosure S) :=
  ⟨deductiveClosure_consistent h, deductiveClosure_closed S⟩

/-! ## R-Maximal Extension Existence -/

/--
The set of all DCS that extend S, are deductively closed, and satisfy r(A, -).
-/
def rDCSExtensions (A S : Set Formula) : Set (Set Formula) :=
  {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ rRelation A B}

/--
Given an MCS A and a DCS S with r(A, S), there exists an R-maximal DCS B
with S ⊆ B and r(A, B).

Proof: Apply Zorn's lemma to the set of DCS extending S and satisfying r(A, -),
ordered by subset inclusion. Every chain has an upper bound (its union),
which is again a DCS satisfying the r-relation.
-/
theorem rMaximal_extension_exists {A : Set Formula}
    (_h_mcs : SetMaximalConsistent A)
    {S : Set Formula} (h_dcs : SetDeductivelyClosed S) (h_r : rRelation A S) :
    ∃ B : Set Formula, S ⊆ B ∧ rMaximal A B := by
  -- Verify S is in the extension set
  have h_S_in : S ∈ rDCSExtensions A S := ⟨Set.Subset.refl _, h_dcs, h_r⟩
  -- Apply Zorn's subset lemma
  obtain ⟨B, hB_in, hB_max⟩ := zorn_subset (rDCSExtensions A S) (by
    intro c hc_sub hc_chain
    by_cases hc_empty : c = ∅
    · exact ⟨S, h_S_in, by intro t ht; exact absurd ht (by rw [hc_empty]; exact Set.notMem_empty _)⟩
    · obtain ⟨T₀, hT₀⟩ := Set.nonempty_iff_ne_empty.mpr hc_empty
      refine ⟨⋃₀ c, ?_, fun t ht => Set.subset_sUnion_of_mem ht⟩
      refine ⟨Set.subset_sUnion_of_subset c T₀ (hc_sub hT₀).1 hT₀, ?_, ?_⟩
      · -- ⋃₀ c is a DCS
        constructor
        · -- Consistency: any finite L ⊆ ⋃₀ c is in some element of chain
          intro L hL ⟨d⟩
          obtain ⟨T, hTc, hLT⟩ := chain_finite_subset_in_element hc_chain hT₀ L
            (fun φ hφ => hL φ hφ)
          exact (hc_sub hTc).2.1.1 L hLT ⟨d⟩
        · -- Closure under derivation: same finite subset argument
          intro L φ hL d
          obtain ⟨T, hTc, hLT⟩ := chain_finite_subset_in_element hc_chain hT₀ L
            (fun ψ hψ => hL ψ hψ)
          exact Set.mem_sUnion.mpr ⟨T, hTc, (hc_sub hTc).2.1.2 L φ hLT d⟩
      · -- r(A, ⋃₀ c): pick any element from chain
        intro γ δ h_until
        rcases (hc_sub hT₀).2.2 γ δ h_until with h_d | ⟨h_g, h_u⟩
        · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
        · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                         Set.mem_sUnion.mpr ⟨T₀, hT₀, h_u⟩⟩)
  -- Extract the R-maximal properties
  obtain ⟨hSB, hB_dcs, hB_r⟩ := hB_in
  refine ⟨B, hSB, hB_dcs, hB_r, ?_⟩
  -- Maximality: no proper DCS extension satisfies r(A, -)
  intro C hC_dcs hBC hC_r
  have hC_in : C ∈ rDCSExtensions A S :=
    ⟨Set.Subset.trans hSB hBC.1, hC_dcs, hC_r⟩
  -- hB_max gives C ⊆ B, contradicting hBC : B ⊂ C (which has ¬(C ⊆ B))
  exact hBC.2 (hB_max hC_in hBC.1)
where
  /-- Helper: for a chain of sets and a finite list L whose elements are each in
  some element of the chain, all of L is contained in a single chain element. -/
  chain_finite_subset_in_element {c : Set (Set Formula)} {T₀ : Set Formula}
      (hc_chain : IsChain (· ⊆ ·) c) (hT₀ : T₀ ∈ c)
      (L : List Formula)
      (hL : ∀ φ ∈ L, φ ∈ ⋃₀ c) :
      ∃ T ∈ c, ∀ φ ∈ L, φ ∈ T := by
    induction L with
    | nil => exact ⟨T₀, hT₀, fun _ h => absurd h List.not_mem_nil⟩
    | cons a L ih =>
      obtain ⟨Ta, hTa, ha⟩ := Set.mem_sUnion.mp (hL a (List.mem_cons_self))
      obtain ⟨TL, hTL, hLTL⟩ := ih (fun φ hφ => hL φ (List.mem_cons_of_mem a hφ))
      rcases hc_chain.total hTa hTL with h_le | h_le
      · exact ⟨TL, hTL, fun φ hφ => by
          rcases List.mem_cons.mp hφ with rfl | h
          · exact h_le ha
          · exact hLTL φ h⟩
      · exact ⟨Ta, hTa, fun φ hφ => by
          rcases List.mem_cons.mp hφ with rfl | h
          · exact ha
          · exact h_le (hLTL φ h)⟩

/--
Similarly for Since: R-maximal Since extensions exist.
-/
theorem rMaximalSince_extension_exists {A : Set Formula}
    (_h_mcs : SetMaximalConsistent A)
    {S : Set Formula} (h_dcs : SetDeductivelyClosed S)
    (h_r : rRelationSince A S) :
    ∃ B : Set Formula, S ⊆ B ∧ rMaximalSince A B := by
  have h_S_in : S ∈ {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ rRelationSince A B} :=
    ⟨Set.Subset.refl _, h_dcs, h_r⟩
  obtain ⟨B, hB_in, hB_max⟩ := zorn_subset {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ rRelationSince A B} (by
    intro c hc_sub hc_chain
    by_cases hc_empty : c = ∅
    · exact ⟨S, h_S_in, by intro t ht; exact absurd ht (by rw [hc_empty]; exact Set.notMem_empty _)⟩
    · obtain ⟨T₀, hT₀⟩ := Set.nonempty_iff_ne_empty.mpr hc_empty
      refine ⟨⋃₀ c, ?_, fun t ht => Set.subset_sUnion_of_mem ht⟩
      refine ⟨Set.subset_sUnion_of_subset c T₀ (hc_sub hT₀).1 hT₀, ?_, ?_⟩
      · constructor
        · intro L hL ⟨d⟩
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun φ hφ => hL φ hφ)
          exact (hc_sub hTc).2.1.1 L hLT ⟨d⟩
        · intro L φ hL d
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun ψ hψ => hL ψ hψ)
          exact Set.mem_sUnion.mpr ⟨T, hTc, (hc_sub hTc).2.1.2 L φ hLT d⟩
      · intro γ δ h_since
        rcases (hc_sub hT₀).2.2 γ δ h_since with h_d | ⟨h_g, h_s⟩
        · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
        · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                         Set.mem_sUnion.mpr ⟨T₀, hT₀, h_s⟩⟩)
  obtain ⟨hSB, hB_dcs, hB_r⟩ := hB_in
  refine ⟨B, hSB, hB_dcs, hB_r, ?_⟩
  intro C hC_dcs hBC hC_r
  have hC_in : C ∈ {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ rRelationSince A B} :=
    ⟨Set.Subset.trans hSB hBC.1, hC_dcs, hC_r⟩
  exact hBC.2 (hB_max hC_in hBC.1)

/-! ## Three-Argument R-Maximal Extension Existence -/

/--
The set of DCS extending S that satisfy r3Relation A - C.
-/
def r3DCSExtensions (A S C : Set Formula) : Set (Set Formula) :=
  {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ r3Relation A B C}

/--
Given MCS A and C, and a DCS S with r3Relation A S C, there exists an
R3-maximal DCS B with S ⊆ B and R3Maximal A B C.

The proof is identical in structure to `rMaximal_extension_exists`:
Zorn's lemma on the set of DCS extending S satisfying r3Relation A - C.
Every chain has an upper bound (its union), which preserves both the
rRelation A - and rRelationSince C - conditions.
-/
theorem r3Maximal_extension_exists {A C : Set Formula}
    (_h_mcs_A : SetMaximalConsistent A) (_h_mcs_C : SetMaximalConsistent C)
    {S : Set Formula} (h_dcs : SetDeductivelyClosed S) (h_r3 : r3Relation A S C) :
    ∃ B : Set Formula, S ⊆ B ∧ R3Maximal A B C := by
  have h_S_in : S ∈ r3DCSExtensions A S C := ⟨Set.Subset.refl _, h_dcs, h_r3⟩
  obtain ⟨B, hB_in, hB_max⟩ := zorn_subset (r3DCSExtensions A S C) (by
    intro c hc_sub hc_chain
    by_cases hc_empty : c = ∅
    · exact ⟨S, h_S_in, by intro t ht; exact absurd ht (by rw [hc_empty]; exact Set.notMem_empty _)⟩
    · obtain ⟨T₀, hT₀⟩ := Set.nonempty_iff_ne_empty.mpr hc_empty
      refine ⟨⋃₀ c, ?_, fun t ht => Set.subset_sUnion_of_mem ht⟩
      refine ⟨Set.subset_sUnion_of_subset c T₀ (hc_sub hT₀).1 hT₀, ?_, ?_⟩
      · -- ⋃₀ c is a DCS (same argument as rMaximal case)
        constructor
        · intro L hL ⟨d⟩
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun φ hφ => hL φ hφ)
          exact (hc_sub hTc).2.1.1 L hLT ⟨d⟩
        · intro L φ hL d
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun ψ hψ => hL ψ hψ)
          exact Set.mem_sUnion.mpr ⟨T, hTc, (hc_sub hTc).2.1.2 L φ hLT d⟩
      · -- r3Relation A (⋃₀ c) C: both rRelation A - and rRelationSince C - hold
        constructor
        · -- rRelation A (⋃₀ c)
          intro γ δ h_until
          rcases (hc_sub hT₀).2.2.1 γ δ h_until with h_d | ⟨h_g, h_u⟩
          · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
          · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                           Set.mem_sUnion.mpr ⟨T₀, hT₀, h_u⟩⟩
        · -- rRelationSince C (⋃₀ c)
          intro γ δ h_since
          rcases (hc_sub hT₀).2.2.2 γ δ h_since with h_d | ⟨h_g, h_s⟩
          · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
          · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                           Set.mem_sUnion.mpr ⟨T₀, hT₀, h_s⟩⟩)
  obtain ⟨hSB, hB_dcs, hB_r3⟩ := hB_in
  refine ⟨B, hSB, hB_dcs, hB_r3, ?_⟩
  intro D hD_dcs hBD hD_r3
  have hD_in : D ∈ r3DCSExtensions A S C :=
    ⟨Set.Subset.trans hSB hBD.1, hD_dcs, hD_r3⟩
  exact hBD.2 (hB_max hD_in hBD.1)

/--
Mirror: R3-maximal Since extensions exist.
-/
theorem r3MaximalSince_extension_exists {A C : Set Formula}
    (_h_mcs_A : SetMaximalConsistent A) (_h_mcs_C : SetMaximalConsistent C)
    {S : Set Formula} (h_dcs : SetDeductivelyClosed S) (h_r3 : r3RelationSince A S C) :
    ∃ B : Set Formula, S ⊆ B ∧ R3MaximalSince A B C := by
  have h_S_in : S ∈ {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ r3RelationSince A B C} :=
    ⟨Set.Subset.refl _, h_dcs, h_r3⟩
  obtain ⟨B, hB_in, hB_max⟩ := zorn_subset {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ r3RelationSince A B C} (by
    intro c hc_sub hc_chain
    by_cases hc_empty : c = ∅
    · exact ⟨S, h_S_in, by intro t ht; exact absurd ht (by rw [hc_empty]; exact Set.notMem_empty _)⟩
    · obtain ⟨T₀, hT₀⟩ := Set.nonempty_iff_ne_empty.mpr hc_empty
      refine ⟨⋃₀ c, ?_, fun t ht => Set.subset_sUnion_of_mem ht⟩
      refine ⟨Set.subset_sUnion_of_subset c T₀ (hc_sub hT₀).1 hT₀, ?_, ?_⟩
      · constructor
        · intro L hL ⟨d⟩
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun φ hφ => hL φ hφ)
          exact (hc_sub hTc).2.1.1 L hLT ⟨d⟩
        · intro L φ hL d
          obtain ⟨T, hTc, hLT⟩ := rMaximal_extension_exists.chain_finite_subset_in_element
            hc_chain hT₀ L (fun ψ hψ => hL ψ hψ)
          exact Set.mem_sUnion.mpr ⟨T, hTc, (hc_sub hTc).2.1.2 L φ hLT d⟩
      · -- r3RelationSince A (⋃₀ c) C
        constructor
        · -- rRelationSince A (⋃₀ c)
          intro γ δ h_since
          rcases (hc_sub hT₀).2.2.1 γ δ h_since with h_d | ⟨h_g, h_s⟩
          · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
          · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                           Set.mem_sUnion.mpr ⟨T₀, hT₀, h_s⟩⟩
        · -- rRelation C (⋃₀ c)
          intro γ δ h_until
          rcases (hc_sub hT₀).2.2.2 γ δ h_until with h_d | ⟨h_g, h_u⟩
          · exact Or.inl (Set.mem_sUnion.mpr ⟨T₀, hT₀, h_d⟩)
          · exact Or.inr ⟨Set.mem_sUnion.mpr ⟨T₀, hT₀, h_g⟩,
                           Set.mem_sUnion.mpr ⟨T₀, hT₀, h_u⟩⟩)
  obtain ⟨hSB, hB_dcs, hB_r3⟩ := hB_in
  refine ⟨B, hSB, hB_dcs, hB_r3, ?_⟩
  intro D hD_dcs hBD hD_r3
  have hD_in : D ∈ {B | S ⊆ B ∧ SetDeductivelyClosed B ∧ r3RelationSince A B C} :=
    ⟨Set.Subset.trans hSB hBD.1, hD_dcs, hD_r3⟩
  exact hBD.2 (hB_max hD_in hBD.1)

/--
Any MCS B such that A ⊆ B and C ⊆ B satisfies r3Relation A B C.
This is because rRelation A B holds (from A ⊆ B) and rRelationSince C B holds
(from C ⊆ B).
-/
theorem r3Relation_of_superset_mcs {A B C : Set Formula}
    (h_mcs_B : SetMaximalConsistent B)
    (h_sub_A : A ⊆ B) (h_sub_C : C ⊆ B) : r3Relation A B C :=
  ⟨rRelation_of_superset_mcs h_mcs_B h_sub_A,
   rRelationSince_of_superset_mcs h_mcs_B h_sub_C⟩

/--
A deductive closure seed for r3-relation: given the r-relation seed from
rRelation_of_superset_mcs applied to a superset MCS, the three-argument
version holds automatically.
-/
theorem r3_seed_from_rRelation {A B C : Set Formula}
    (h_r : rRelation A B) (h_rS : rRelationSince C B) : r3Relation A B C :=
  ⟨h_r, h_rS⟩

end Bimodal.Metalogic.BXCanonical.Chronicle
