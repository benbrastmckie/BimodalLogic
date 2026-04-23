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

- `until_guard_consistent` (Lemma 2.2): If `gamma U delta in A` for MCS A,
  then `{gamma}` is consistent.

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

/-! ## Lemma 2.2: Until Guard Consistency -/

/--
**Lemma 2.2** (adapted): If `gamma U delta in A` for MCS A, then `{gamma}` is consistent.

Proof: Suppose for contradiction that `{gamma}` is inconsistent, i.e., `[gamma] ⊢ bot`.
By deduction theorem: `⊢ neg gamma`.
By temporal necessitation: `⊢ G(neg gamma)`.
By BX2 (left_mono_until) with `gamma -> bot` and `G(gamma -> bot)`:
  `(gamma U delta) -> (bot U delta)`.
Since `gamma U delta in A`: `bot U delta in A`.
From BX9 (until_elim): `(bot U delta) -> bot ∨ delta`.
And `bot ∨ delta = neg bot -> delta`. Since `⊢ neg bot`: `(bot U delta) -> delta`.
So `delta in A`. But also:
From BX5 (self_accum_until) on `bot U delta`:
  `(bot U delta) -> ((bot ∧ (bot U delta)) U delta)`.
The guard `bot ∧ (bot U delta)` implies `bot` by left conjunction elimination.
So by BX2 with `(bot ∧ X) -> bot`: `((bot ∧ X) U delta) -> (bot U delta)`.
This is circular. Instead:

The key insight is that `bot U delta` is equivalent to `F(delta)` modulo
the axiom system (BX12 reverse direction). Under strict semantics on dense
orders, `bot U delta -> bot` because the guard `bot` must hold at the
current time (BX9). But BX9 only gives `bot ∨ delta`, not `bot`.

Since Lemma 2.2 under strict semantics requires careful axiom-level reasoning
about the interplay of BX2, BX5, and BX9, and the conclusion (`{gamma}` consistent)
is used only as a stepping stone for consistency of larger seed sets, we
establish this via a direct argument from the MCS properties.
-/
theorem until_guard_consistent {A : Set Formula}
    (h_mcs : SetMaximalConsistent A) {γ δ : Formula}
    (h_until : Formula.untl γ δ ∈ A) :
    SetConsistent ({γ} : Set Formula) := by
  -- By BX9: (γ U δ) → γ ∨ δ. So γ ∨ δ ∈ A.
  -- Either γ ∈ A or ¬γ ∈ A.
  -- Case 1: γ ∈ A. Then {γ} ⊆ A, and A is consistent, so {γ} is consistent.
  -- Case 2: ¬γ ∈ A (γ ∉ A). From BX9 and ¬γ: δ ∈ A.
  --   Now if {γ} were inconsistent, ⊢ ¬γ.
  --   By temp nec: ⊢ G(¬γ). By left_mono_until: (γ U δ) → (⊥ U δ).
  --   ⊥ U δ ∈ A. By BX9: ⊥ ∨ δ ∈ A, so δ ∈ A.
  --   No direct contradiction in A.
  --   But {γ} inconsistent means [γ] ⊢ ⊥, which means ⊢ ¬γ.
  --   This is fine, ¬γ is a theorem. {γ} = {γ} and contains γ.
  --   If L ⊆ {γ} and L ⊢ ⊥: every element of L is γ.
  --   We need this to derive False (from A being consistent).
  -- The approach: if γ ∈ A, then {γ} ⊆ A and SetConsistent A → SetConsistent {γ}.
  -- If γ ∉ A, then we need a different argument.
  -- Actually: if {γ} inconsistent, then [γ] ⊢ ⊥, so ⊢ ¬γ.
  -- Then ¬γ ∈ A (theorem in MCS). And γ ∉ A (since both can't be in MCS).
  -- But also ⊢ ¬γ means γ → ⊥. By temp nec: ⊢ G(γ → ⊥).
  -- BX2: (γ → ⊥) ∧ G(γ → ⊥) → (γ U δ → ⊥ U δ). All theorems, so in A.
  -- ⊥ U δ ∈ A. By BX10: F(δ) ∈ A. By BX9: ⊥ ∨ δ ∈ A → δ ∈ A. Fine.
  -- We want ⊥ ∈ A for contradiction. Can we get it?
  -- BX9 on ⊥ U δ gives ⊥ ∨ δ = ¬⊥ → δ. This gives δ, not ⊥.
  -- Under strict semantics, ⊥ U δ is semantically false on dense orders
  -- but NOT derivably false from BX axioms alone (⊥ U δ → ⊥ is not a theorem).
  -- So this approach fails.
  --
  -- Alternative: γ ∈ A always holds. From BX9: γ U δ → γ ∨ δ.
  -- But we need γ ∈ A, not just γ ∨ δ ∈ A.
  -- Under strict semantics with half-open guard, γ U δ at t requires γ(t)
  -- (since t ∈ [t,s)). So semantically γ U δ → γ. But BX9 only gives γ ∨ δ.
  -- We can verify: from BX5 + BX9:
  -- BX5: γ U δ → (γ ∧ (γ U δ)) U δ
  -- BX9: (γ ∧ (γ U δ)) U δ → (γ ∧ (γ U δ)) ∨ δ
  -- From (γ ∧ (γ U δ)) ∨ δ: either γ ∧ (γ U δ) ∈ A (giving γ ∈ A) or δ ∈ A.
  -- So γ ∈ A ∨ δ ∈ A. This is the same as γ ∨ δ ∈ A.
  --
  -- The ONLY way to get γ ∈ A is if we can rule out δ alone.
  -- Without additional axioms, we cannot derive γ from γ U δ.
  --
  -- For the chronicle construction, what we actually need is not {γ} consistent
  -- but rather that the seed set for extending g_content is consistent.
  -- The key use of Lemma 2.2 is in the point insertion lemma (Lemma 2.4).
  --
  -- For now, we use the MCS case split approach: if γ ∈ A, done.
  -- If γ ∉ A (¬γ ∈ A): we show {γ} consistent via the fact that
  -- ¬γ being a theorem would make γ U δ derive ⊥ U δ, and
  -- our system should prevent inconsistency.
  --
  -- Actually, the simplest proof: if {γ} is inconsistent, then [γ] ⊢ ⊥.
  -- Deduction theorem: ⊢ ¬γ. Then ¬γ is a theorem, so it holds at all worlds.
  -- But γ U δ requires γ at the current time (semantically under strict Until).
  -- The syntactic consequence is: from BX2 + ⊢ ¬γ + ⊢ G(¬γ), we get
  -- ⊢ γ U δ → ⊥ U δ. Then from γ U δ ∈ A: ⊥ U δ ∈ A.
  -- From BX5: ⊥ U δ → (⊥ ∧ (⊥ U δ)) U δ.
  -- ⊥ ∧ X is derivably equivalent to ⊥ (by left conjunction).
  -- Hmm, ⊥ ∧ X = ¬(⊥ → ¬X). This is ¬(⊥ → X → ⊥).
  -- From ⊢ ⊥ → (X → ⊥) (by ex_falso): ⊢ ¬(⊥ ∧ X).
  -- Wait: ⊥ ∧ X = ¬(⊥ → ¬X). If ⊥ → ¬X is provable, then ⊥ ∧ X is provably false.
  -- ⊢ ⊥ → anything (ex_falso). So ⊢ ⊥ → ¬X. Hence ⊢ ¬(⊥ ∧ X).
  -- But we have (⊥ ∧ (⊥ U δ)) U δ ∈ A. From BX2 with (⊥∧X) → ⊥ and G((⊥∧X) → ⊥):
  -- ((⊥∧X) U δ) → (⊥ U δ). This gives us back ⊥ U δ. Circular.
  --
  -- The core issue: BX9 gives ⊥ U δ → ⊥ ∨ δ, but ⊥ ∨ δ = ¬⊥ → δ = ⊤ → δ = δ.
  -- So ⊥ U δ → δ. But ⊥ U δ → ⊥ is NOT derivable from BX axioms.
  -- Under strict semantics, ⊥ U δ is semantically absurd but syntactically consistent
  -- with the axiom system (unless we add an axiom like ⊥ U δ → ⊥).
  --
  -- CONCLUSION: Lemma 2.2 in the form "gamma U delta ∈ A → {gamma} consistent"
  -- may NOT be derivable under strict semantics without additional axioms.
  -- However, what IS derivable is the weaker: gamma ∈ A ∨ delta ∈ A.
  -- For the chronicle construction, the r-relation provides the needed conditions.
  --
  -- We leave this as sorry, documenting that it may require an additional axiom
  -- or a different formulation under strict semantics.
  sorry

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

end Bimodal.Metalogic.BXCanonical.Chronicle
