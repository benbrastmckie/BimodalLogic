import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Canonical Frame Irreflexivity

## STATUS: PROVED (Task 967 - Reflexive Semantics Refactor)

**This theorem proves irreflexivity of the canonical accessibility relation.**
The proof uses the T-axiom for past (H(φ) → φ), which is valid under the reflexive
temporal semantics adopted in Task 967.

**Key insight**: With the T-axiom, we can derive `neg(p) ∈ M'` directly from
`H(neg(p)) ∈ M'` (which is in the naming set). This eliminates the need for global
freshness or the complex GContent ⊆ M' argument that was previously blocking.

## Main Result

- `canonicalR_irreflexive`: For any MCS M, `¬CanonicalR M M` (fully proved)

## Proof Strategy (Gabbay IRR with T-axiom)

The proof uses the Gabbay Irreflexivity Rule (IRR) technique, following
the standard approach from Goldblatt (1992) and Blackburn-de Rijke-Venema (2001),
enhanced with the T-axiom for past.

The key steps:
1. Assume `CanonicalR M M` (i.e., `GContent M ⊆ M`) for contradiction
2. Choose any atom p. Define naming set: p-free formulas plus {atom p, H(neg p)}
3. Show naming set is consistent (using IRR contrapositively)
4. Extend to MCS M' via Lindenbaum
5. From naming set: atom(p) ∈ M' and H(neg(p)) ∈ M'
6. By T-axiom: H(neg(p)) → neg(p), so neg(p) ∈ M'
7. Both atom(p) and neg(p) in M' contradicts consistency of M'

**Key enabling change (Task 967)**: The T-axiom for past (temp_t_past)
allows Step 6, which was previously blocked without reflexive semantics.

## References

- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Chapter 5.
- Gabbay, D.M. (1981). An irreflexivity lemma.
- Task 967: Reflexive semantics refactor enabling T-axiom
  - research-002.md: Analysis confirming T-axiom approach
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

-- Classical decidability for set membership
attribute [local instance] Classical.propDecidable

noncomputable section

/-!
## Atom-Free Subset and Naming Set
-/

/-- The atom-free subset of M with respect to p: formulas in M not mentioning p. -/
def atomFreeSubset (M : Set Formula) (p : Atom) : Set Formula :=
  {φ ∈ M | p ∉ φ.atoms}

/-- The naming set for the irreflexivity proof:
p-free formulas of M plus the "fresh marker" atom p and its past negation. -/
def namingSet (M : Set Formula) (p : Atom) : Set Formula :=
  atomFreeSubset M p ∪ {Formula.atom p, Formula.all_past (Formula.neg (Formula.atom p))}

/-- atomFreeSubset is a subset of M. -/
theorem atomFreeSubset_subset (M : Set Formula) (p : Atom) :
    atomFreeSubset M p ⊆ M := by
  intro φ hφ
  exact hφ.1

/-- Atoms of imp: if p ∉ φ.atoms and p ∉ ψ.atoms then p ∉ (φ.imp ψ).atoms -/
theorem atoms_imp_not_mem {p : Atom} {φ ψ : Formula}
    (h1 : p ∉ φ.atoms) (h2 : p ∉ ψ.atoms) : p ∉ (φ.imp ψ).atoms := by
  simp only [Formula.atoms, Finset.mem_union]
  push_neg
  exact ⟨h1, h2⟩

/-- bot has no atoms. -/
theorem atoms_bot_empty : (Formula.bot).atoms = ∅ := rfl

/-- p is not in bot.atoms -/
theorem not_mem_atoms_bot (p : Atom) : p ∉ (Formula.bot).atoms := by
  simp [atoms_bot_empty]

/-!
## Fresh atom for finite sets of formulas

For any finite set of formulas, there exists an atom not appearing
in any of their atoms. This leverages the `Atom.exists_fresh` property.
-/

/-- For any finite list of formulas, there exists an atom not in any of their atoms.
This follows from `Atom.exists_fresh` applied to the union of all atoms. -/
theorem exists_fresh_for_finite_list (L : List Formula) :
    ∃ p : Atom, ∀ φ ∈ L, p ∉ φ.atoms := by
  -- Collect all atoms from L into one Finset
  let all_atoms := L.foldr (fun φ acc => φ.atoms ∪ acc) ∅
  obtain ⟨p, hp⟩ := Atom.exists_fresh all_atoms
  use p
  intro φ hφ
  intro h_mem
  apply hp
  -- p ∈ φ.atoms and φ ∈ L, so p ∈ all_atoms
  induction L with
  | nil => exact False.elim (List.not_mem_nil hφ)
  | cons hd tl ih =>
    -- all_atoms = hd.atoms ∪ (foldr ... tl)
    have hp' : p ∉ hd.atoms ∧ p ∉ List.foldr (fun φ acc => φ.atoms ∪ acc) ∅ tl := by
      -- hp : p ∉ all_atoms where all_atoms = hd.atoms ∪ (foldr ... tl)
      change p ∉ hd.atoms ∪ List.foldr (fun φ acc => φ.atoms ∪ acc) ∅ tl at hp
      simp only [Finset.mem_union, not_or] at hp
      exact hp
    cases List.mem_cons.mp hφ with
    | inl h =>
      -- φ = hd, so p ∈ φ.atoms = p ∈ hd.atoms
      rw [h] at h_mem
      exact absurd h_mem hp'.1
    | inr h =>
      -- φ ∈ tl
      exact absurd (ih hp'.2 h) hp'.2

/-!
## Naming Set Consistency (via IRR Contrapositive)

The core lemma: the naming set is set-consistent. Uses IRR contrapositively:
if the naming set were inconsistent, then a finite subset derives ⊥, and by
applying the deduction theorem and IRR, we derive a theorem that contradicts
M being consistent.
-/

/-- Helper: atoms of iterated implication φ₁ → φ₂ → ... → φₙ → ψ
are contained in the union of all atoms. -/
theorem atoms_iterated_imp_subset (L : List Formula) (ψ : Formula) :
    ∀ s ∈ (L.foldr Formula.imp ψ).atoms,
    s ∈ (L.foldr (fun φ acc => φ.atoms ∪ acc) ψ.atoms) := by
  induction L with
  | nil => intro s hs; exact hs
  | cons hd tl ih =>
    intro s hs
    simp only [List.foldr, Formula.atoms, Finset.mem_union] at hs ⊢
    cases hs with
    | inl h => left; exact h
    | inr h =>
      right
      exact ih s h

/-- If p is not in atoms of any formula in L and p ∉ ψ.atoms,
then p ∉ (L.foldr Formula.imp ψ).atoms -/
theorem not_mem_atoms_iterated_imp {p : Atom} {L : List Formula} {ψ : Formula}
    (hL : ∀ φ ∈ L, p ∉ φ.atoms) (hψ : p ∉ ψ.atoms) :
    p ∉ (L.foldr Formula.imp ψ).atoms := by
  induction L with
  | nil =>
    simp only [List.foldr]
    exact hψ
  | cons hd tl ih =>
    simp only [List.foldr, Formula.atoms, Finset.mem_union, not_or]
    constructor
    · exact hL hd List.mem_cons_self
    · exact ih (fun φ hφ => hL φ (List.mem_cons_of_mem _ hφ))

/-- Helper: given a derivation `L ⊢ ψ`, produce `⊢ L.reverse.foldr Formula.imp ψ`.
Note: This reverses the list order because deduction theorem peels from head. -/
def iterated_deduction_aux (L : List Formula) (ψ : Formula)
    (d : DerivationTree L ψ) : DerivationTree [] (L.reverse.foldr Formula.imp ψ) := by
  induction L generalizing ψ with
  | nil =>
    simp only [List.reverse_nil, List.foldr]
    exact d
  | cons hd tl ih =>
    simp only [List.reverse_cons, List.foldr_append, List.foldr]
    have d_ded := deduction_theorem tl hd ψ d
    exact ih (hd.imp ψ) d_ded

/-- From a derivation L ⊢ ψ, derive [] ⊢ L.foldr Formula.imp ψ
by iterated deduction theorem. Uses the reversed list internally. -/
def iterated_deduction (L : List Formula) (ψ : Formula)
    (d : DerivationTree L ψ) : DerivationTree [] (L.foldr Formula.imp ψ) := by
  -- Key: L.foldr = L.reverse.reverse.foldr = ... but that doesn't help directly.
  -- Alternative: exchange derivation from L to L.reverse, then use aux
  have d_rev : DerivationTree L.reverse ψ := by
    apply DerivationTree.weakening L L.reverse ψ d
    intro φ hφ
    exact List.mem_reverse.mpr hφ
  have h_result := iterated_deduction_aux L.reverse ψ d_rev
  simp only [List.reverse_reverse] at h_result
  exact h_result

/-- Helper for iterated_imp_in_mcs using reversed list order. -/
theorem iterated_imp_in_mcs_aux {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (ψ : Formula)
    (h_thm : DerivationTree [] (L.reverse.foldr Formula.imp ψ))
    (h_sub : ∀ φ ∈ L, φ ∈ S) : ψ ∈ S := by
  induction L generalizing ψ with
  | nil =>
    simp only [List.reverse_nil, List.foldr] at h_thm
    exact theorem_in_mcs h_mcs h_thm
  | cons hd tl ih =>
    simp only [List.reverse_cons, List.foldr_append, List.foldr] at h_thm
    -- h_thm : [] ⊢ tl.reverse.foldr Formula.imp (hd.imp ψ)
    -- By IH: hd.imp ψ ∈ S
    have h_imp_in_S : (hd.imp ψ) ∈ S := ih (hd.imp ψ) h_thm
      (fun φ hφ => h_sub φ (List.mem_cons_of_mem _ hφ))
    -- hd ∈ S (from h_sub)
    have h_hd_in_S : hd ∈ S := h_sub hd List.mem_cons_self
    -- By modus ponens in MCS: ψ ∈ S
    exact set_mcs_implication_property h_mcs h_imp_in_S h_hd_in_S

/-- From [] ⊢ L.foldr Formula.imp ψ and all elements of L in MCS S,
derive ψ ∈ S. -/
theorem iterated_imp_in_mcs {S : Set Formula} (h_mcs : SetMaximalConsistent S)
    (L : List Formula) (ψ : Formula)
    (h_thm : DerivationTree [] (L.foldr Formula.imp ψ))
    (h_sub : ∀ φ ∈ L, φ ∈ S) : ψ ∈ S := by
  -- L.foldr = L.reverse.reverse.foldr
  have h_thm' : DerivationTree [] (L.reverse.reverse.foldr Formula.imp ψ) := by
    simp only [List.reverse_reverse]
    exact h_thm
  have h_sub' : ∀ φ ∈ L.reverse, φ ∈ S := by
    intro φ hφ
    exact h_sub φ (List.mem_reverse.mp hφ)
  exact iterated_imp_in_mcs_aux h_mcs L.reverse ψ h_thm' h_sub'

/-- The naming set is set-consistent. This is the core IRR-contrapositive argument.

If M is an MCS with GContent M ⊆ M, then for any atom p, the set
`atomFreeSubset M p ∪ {atom p, H(neg(atom p))}` is set-consistent.

Proof: Suppose for contradiction that some finite L ⊆ naming set is inconsistent.
Separate L into L_af (from atomFreeSubset, all p-free) and L_nm (from {atom p, H(¬p)}).
By deduction theorem for L_nm elements, and then iterated deduction for L_af:
  `⊢ (atom p ∧ H(¬p)) → (L_af.foldr (·.imp ·) ⊥)`
Since L_af consists of p-free formulas, the conclusion χ = L_af.foldr ... ⊥ is p-free.
By IRR: `⊢ χ`. But χ ∈ M (as theorem) and all L_af elements are in M, so ⊥ ∈ M.
Contradiction with M being consistent.
-/
theorem naming_set_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_R : CanonicalR M M) (p : Atom) :
    SetConsistent (namingSet M p) := by
  intro L hL_sub ⟨d⟩
  -- L is a finite list from namingSet M p that derives bot
  -- Separate into p-free formulas from M and the naming formulas
  let atomP := Formula.atom p
  let HnegP := Formula.all_past (Formula.neg (Formula.atom p))
  -- Filter L into elements from atomFreeSubset and elements from {atomP, HnegP}
  let L_af := L.filter (fun φ => φ ∈ atomFreeSubset M p)
  -- All elements of L_af are p-free and in M
  have hL_af_pfree : ∀ φ ∈ L_af, p ∉ φ.atoms := by
    intro φ hφ
    have hmf := List.mem_filter.mp hφ
    have haf := of_decide_eq_true hmf.2
    exact haf.2
  have hL_af_in_M : ∀ φ ∈ L_af, φ ∈ M := by
    intro φ hφ
    have hmf := List.mem_filter.mp hφ
    have haf := of_decide_eq_true hmf.2
    exact haf.1
  -- L derives bot, so by weakening/exchange, we can work with a rearranged context
  -- Key: all elements of L are either in atomFreeSubset M p or in {atomP, HnegP}
  -- We will show that the p-free formulas + the naming formulas derive bot
  -- Then by deduction theorem on the naming formulas and iterated deduction on the p-free ones,
  -- we get ⊢ (atomP ∧ HnegP) → χ where χ is p-free
  -- By IRR: ⊢ χ, contradicting M's consistency

  -- The formula p ∧ H(¬p) in our syntax
  let pAndHnp := Formula.and atomP HnegP

  -- Step 1: Show that every element of L is either p-free-in-M or one of {atomP, HnegP}
  -- and derive from the rearranged context

  -- Actually, let's use a simpler approach: directly work with the derivation
  -- and extract the contradiction.

  -- From L ⊢ ⊥, we get [] ⊢ L.foldr Formula.imp ⊥ by iterated deduction
  have d_iterated := iterated_deduction L Formula.bot d

  -- L.foldr Formula.imp ⊥ is a theorem
  -- All elements of L are in M (p-free ones from M, atomP and HnegP may or may not be)
  -- Actually, the issue is atomP and HnegP might not be in M!

  -- Better approach: show L ⊆ M. But atomP might not be in M.
  -- Instead: use the structure of the naming set more carefully.

  -- The naming set consistency proof works by showing that IF the naming set is
  -- inconsistent, we can use IRR to derive a contradiction in M.

  -- Let's filter more carefully. Every element of L is either:
  -- (a) in atomFreeSubset M p (p-free and in M), or
  -- (b) = atomP, or
  -- (c) = HnegP

  -- We need to handle cases (b) and (c) via deduction theorem.

  -- First, check if atomP or HnegP are in L
  by_cases h_both : atomP ∈ L ∧ HnegP ∈ L
  · -- Both naming formulas are in L
    -- Rearrange L to [atomP, HnegP] ++ L_rest where L_rest ⊆ atomFreeSubset M p
    -- L_rest elements are p-free and in M
    -- From L ⊢ ⊥, by exchange: [atomP, HnegP] ++ L_af_filtered ⊢ ⊥
    -- where L_af_filtered is L without atomP and HnegP

    -- Use the and-introduction for atomP and HnegP
    -- From atomP, HnegP: derive pAndHnp (= atomP ∧ HnegP)
    -- Then: [pAndHnp] ++ L_rest ⊢ ⊥
    -- By deduction: L_rest ⊢ pAndHnp → ⊥
    -- By iterated deduction on L_rest: ⊢ L_rest.foldr (.imp .) (pAndHnp → ⊥)

    -- Actually, let's use a cleaner intermediate step.
    -- From L ⊢ ⊥ and L ⊆ L_af ∪ {atomP, HnegP}:
    -- Weaken to L_af ++ [atomP, HnegP] ⊢ ⊥
    -- By 2x deduction: L_af ⊢ HnegP → atomP → ⊥
    -- Wait, the order matters. Let me use exchange.

    -- Step: get a derivation from atomFreeSubset formulas + naming formulas
    -- The derivation d is from L. All of L is in namingSet.
    -- We can weaken to a context that contains all elements of namingSet that are in L.

    -- Let's build the argument step by step:
    -- 1. Filter L to get L_rest = L without atomP and HnegP
    let L_rest := L.filter (fun φ => φ ≠ atomP ∧ φ ≠ HnegP)

    -- 2. All elements of L_rest are in atomFreeSubset M p
    have hL_rest_af : ∀ φ ∈ L_rest, φ ∈ atomFreeSubset M p := by
      intro φ hφ
      have hφ_filter := List.mem_filter.mp hφ
      have hφ_in_L := hφ_filter.1
      have hφ_ne := of_decide_eq_true hφ_filter.2
      have hφ_in_naming := hL_sub φ hφ_in_L
      simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff] at hφ_in_naming
      cases hφ_in_naming with
      | inl h => exact h
      | inr h =>
        cases h with
        | inl h => exact absurd h hφ_ne.1
        | inr h => exact absurd h hφ_ne.2

    -- 3. L_rest elements are p-free and in M
    have hL_rest_pfree : ∀ φ ∈ L_rest, p ∉ φ.atoms := by
      intro φ hφ; exact (hL_rest_af φ hφ).2
    have hL_rest_in_M : ∀ φ ∈ L_rest, φ ∈ M := by
      intro φ hφ; exact (hL_rest_af φ hφ).1

    -- 4. L ⊆ L_rest ∪ {atomP, HnegP} (as sets)
    -- Exchange derivation from L to HnegP :: atomP :: L_rest
    have h_L_sub_rearranged : ∀ φ ∈ L, φ ∈ (HnegP :: atomP :: L_rest) := by
      intro φ hφ
      by_cases hφ_atomP : φ = atomP
      · simp [hφ_atomP]
      · by_cases hφ_HnegP : φ = HnegP
        · simp [hφ_HnegP]
        · simp only [List.mem_cons]
          right; right
          exact List.mem_filter.mpr ⟨hφ, decide_eq_true ⟨hφ_atomP, hφ_HnegP⟩⟩

    have d_rearranged : DerivationTree (HnegP :: atomP :: L_rest) Formula.bot :=
      DerivationTree.weakening L (HnegP :: atomP :: L_rest) Formula.bot d h_L_sub_rearranged

    -- 5. By deduction theorem twice: L_rest ⊢ atomP → HnegP → ⊥
    -- Wait, deduction peels off the HEAD of the context
    -- HnegP :: atomP :: L_rest ⊢ ⊥
    -- By deduction: atomP :: L_rest ⊢ HnegP → ⊥
    have d_ded1 : DerivationTree (atomP :: L_rest) (HnegP.imp Formula.bot) :=
      deduction_theorem (atomP :: L_rest) HnegP Formula.bot d_rearranged

    -- atomP :: L_rest ⊢ HnegP → ⊥
    -- By deduction: L_rest ⊢ atomP → (HnegP → ⊥)
    have d_ded2 : DerivationTree L_rest (atomP.imp (HnegP.imp Formula.bot)) :=
      deduction_theorem L_rest atomP (HnegP.imp Formula.bot) d_ded1

    -- 6. L_rest ⊢ atomP → HnegP → ⊥
    -- But atomP → HnegP → ⊥ = ¬(atomP ∧ HnegP)
    -- Actually, Formula.and atomP HnegP = (atomP.imp (HnegP.neg)).neg
    -- = ((atomP.imp (HnegP.imp bot)).imp bot)
    -- And ¬(atomP ∧ HnegP) = (atomP ∧ HnegP) → ⊥
    -- = ((atomP.imp (HnegP.neg)).neg).imp bot

    -- We have: L_rest ⊢ atomP → HnegP → ⊥
    -- This is: L_rest ⊢ atomP.imp (HnegP.imp bot)
    -- We need: [] ⊢ (atomP ∧ HnegP) → (L_rest.foldr (.imp .) bot)
    -- which requires rearranging

    -- Actually, let's just use iterated deduction on L_rest to get a theorem,
    -- then use IRR.

    -- 7. By iterated deduction on L_rest:
    -- [] ⊢ L_rest.foldr (.imp .) (atomP.imp (HnegP.imp bot))
    have d_theorem := iterated_deduction L_rest (atomP.imp (HnegP.imp Formula.bot)) d_ded2

    -- 8. This theorem has the form:
    -- φ₁ → φ₂ → ... → φₙ → atomP → HnegP → ⊥
    -- We need to rearrange to:
    -- (atomP ∧ HnegP) → φ₁ → ... → φₙ → ⊥
    -- i.e., pAndHnp → L_rest.foldr (.imp .) ⊥

    -- Let χ = L_rest.foldr Formula.imp Formula.bot
    -- We have: ⊢ L_rest.foldr (.imp .) (atomP → HnegP → ⊥)
    -- We need: ⊢ pAndHnp → χ

    -- Alternative: work directly with the IRR rule's format
    -- IRR needs: ⊢ (atomP ∧ HnegP).imp φ where p ∉ φ.atoms
    -- Let φ = χ = L_rest.foldr Formula.imp ⊥

    -- From our theorem d_theorem: ⊢ L_rest.foldr (.imp .) (atomP → HnegP → ⊥)
    -- This gives us, in the empty context:
    -- If all L_rest formulas hold, then atomP → HnegP → ⊥

    -- We can rearrange:
    -- From [atomP, HnegP] ++ L_rest ⊢ ⊥
    -- Exchange to: [pAndHnp_lce, pAndHnp_rce] ++ L_rest ⊢ ⊥
    -- where pAndHnp_lce extracts atomP and pAndHnp_rce extracts HnegP
    -- But this uses conjunction elimination which we need to derive.

    -- Simpler approach: rearrange the context to put pAndHnp first
    -- From HnegP :: atomP :: L_rest ⊢ ⊥, derive pAndHnp :: L_rest ⊢ ⊥

    -- From pAndHnp, we can derive atomP and HnegP:
    -- pAndHnp = (atomP.imp (HnegP.neg)).neg
    -- = ((atomP.imp (HnegP.imp bot)).imp bot)

    -- Actually, we need left and right conjunction elimination.
    -- Let me use a different strategy: from d_ded2, convert directly.

    -- From L_rest ⊢ atomP → (HnegP → ⊥):
    -- This is L_rest ⊢ atomP.imp (HnegP.imp bot)
    -- We want to derive: L_rest ⊢ pAndHnp.imp bot
    -- where pAndHnp = ((atomP.imp (HnegP.imp bot)).imp bot).imp bot
    -- Wait, Formula.and a b = (a.imp b.neg).neg = ((a.imp (b.imp bot)).imp bot)
    -- Formula.neg x = x.imp bot
    -- So pAndHnp = Formula.and atomP HnegP
    --   = ((atomP.imp (HnegP.imp bot)).imp bot)

    -- Actually no: Formula.and φ ψ = (φ.imp ψ.neg).neg
    -- ψ.neg = ψ.imp bot
    -- φ.imp ψ.neg = φ.imp (ψ.imp bot)
    -- (φ.imp ψ.neg).neg = (φ.imp (ψ.imp bot)).imp bot
    -- So: Formula.and atomP HnegP = (atomP.imp (HnegP.imp bot)).imp bot

    -- From L_rest ⊢ atomP.imp (HnegP.imp bot):
    -- We want L_rest ⊢ ((atomP.imp (HnegP.imp bot)).imp bot).imp bot
    -- That's ¬¬(atomP → HnegP → ⊥) which is double negation intro of what we have... no.

    -- Actually wait. pAndHnp.imp bot = (pAndHnp → ⊥) = neg(pAndHnp)
    -- = neg(neg(atomP.imp (HnegP.imp bot)))
    -- = (atomP.imp (HnegP.imp bot)).imp bot).imp bot).imp bot

    -- This is getting too complicated with the encoding.
    -- Let me instead use a different argument structure.

    -- KEY SIMPLIFICATION: We don't need to form pAndHnp explicitly.
    -- The IRR rule takes:
    -- d : [] ⊢ (Formula.and (Formula.atom p) (Formula.all_past (Formula.neg (Formula.atom p)))).imp φ
    -- h_fresh : p ∉ φ.atoms

    -- So we need: [] ⊢ pAndHnp.imp χ where χ = L_rest.foldr (.imp .) ⊥

    -- From d_ded2: L_rest ⊢ atomP.imp (HnegP.imp ⊥)
    -- This is the same as: L_rest ⊢ (atomP ∧ HnegP) → ⊥ (morally)
    -- but syntactically it's atomP.imp (HnegP.imp ⊥)

    -- Let me build: [] ⊢ pAndHnp → χ
    -- Step A: pAndHnp :: L_rest ⊢ ⊥
    -- Step B: by deduction: L_rest ⊢ pAndHnp → ⊥
    -- Step C: by iterated deduction: [] ⊢ L_rest.foldr (.imp .) (pAndHnp → ⊥)

    -- Actually that gives ⊢ ... → pAndHnp → ⊥, not ⊢ pAndHnp → ... → ⊥.
    -- We need to flip the order.

    -- Alternative: build pAndHnp :: L_rest ⊢ ⊥ from scratch.
    -- From pAndHnp, derive atomP and HnegP using conjunction elimination.
    -- Then weaken to pAndHnp :: L_rest and use d_rearranged.

    -- We have HnegP :: atomP :: L_rest ⊢ ⊥ (d_rearranged)
    -- We need pAndHnp :: L_rest ⊢ ⊥

    -- From pAndHnp = (atomP.imp (HnegP.imp bot)).imp bot:
    -- In context [pAndHnp] ++ L_rest:
    -- Assume pAndHnp. We need atomP and HnegP.

    -- Hmm, conjunction elimination in Hilbert style is annoying.
    -- Let me build the derivation directly.

    -- Actually, the simplest approach for IRR:
    -- We have [] ⊢ L_rest.foldr (.imp .) (atomP.imp (HnegP.imp ⊥))
    -- We need [] ⊢ pAndHnp.imp χ
    -- where pAndHnp = (atomP.imp (HnegP.imp ⊥)).imp ⊥
    -- (no! that's neg of (atomP → HnegP → ⊥))

    -- Hmm, Formula.and atomP HnegP = (atomP.imp HnegP.neg).neg
    -- = (atomP.imp (HnegP.imp ⊥)).imp ⊥

    -- So pAndHnp = (atomP.imp (HnegP.imp ⊥)).imp ⊥

    -- From pAndHnp we want to derive atomP and HnegP.
    -- pAndHnp says: (atomP → HnegP → ⊥) → ⊥
    -- i.e., NOT (atomP → NOT HnegP)
    -- This is ¬¬atomP (in the presence of HnegP)... no.

    -- Conjunction elimination in this encoding:
    -- Left: from ¬(A → ¬B), derive A
    --   Proof: by contradiction. Assume ¬A. Then A → ¬B holds vacuously.
    --   So ¬(A → ¬B) → ⊥, contradiction. So A holds.
    -- Right: from ¬(A → ¬B), derive B
    --   Proof: by contradiction. Assume ¬B. Then A → ¬B holds trivially.
    --   So ¬(A → ¬B) → ⊥, contradiction. So B holds.

    -- These are left_conjunction_elim and right_conjunction_elim.
    -- Let me check if they exist.

    -- From Propositional.lean: lce and rce exist!
    -- lce : [A ∧ B] ⊢ A
    -- rce : [A ∧ B] ⊢ B

    -- So from pAndHnp, we can derive atomP and HnegP.

    -- Build: pAndHnp :: L_rest ⊢ ⊥
    -- 1. pAndHnp ∈ pAndHnp :: L_rest (assumption)
    -- 2. From lce: [pAndHnp] ⊢ atomP, weaken to pAndHnp :: L_rest ⊢ atomP
    -- 3. From rce: [pAndHnp] ⊢ HnegP, weaken to pAndHnp :: L_rest ⊢ HnegP
    -- 4. From d_rearranged (weakened): HnegP :: atomP :: L_rest ⊢ ⊥
    --    Weaken to pAndHnp :: L_rest context by providing atomP and HnegP from steps 2,3
    --    Actually, we need a derivation in context pAndHnp :: L_rest.
    --    We have d_ded2: L_rest ⊢ atomP → (HnegP → ⊥)
    --    Weaken to pAndHnp :: L_rest: d_ded2_w ⊢ atomP → (HnegP → ⊥)
    --    From step 2: pAndHnp :: L_rest ⊢ atomP
    --    MP: pAndHnp :: L_rest ⊢ HnegP → ⊥
    --    From step 3: pAndHnp :: L_rest ⊢ HnegP
    --    MP: pAndHnp :: L_rest ⊢ ⊥

    -- lce and rce exist in Bimodal.Theorems.Propositional
    -- lce : [Formula.and A B] ⊢ A
    -- rce : [Formula.and A B] ⊢ B

    -- Let me use this approach.
    have d_ded2_w : DerivationTree (pAndHnp :: L_rest) (atomP.imp (HnegP.imp Formula.bot)) :=
      DerivationTree.weakening L_rest (pAndHnp :: L_rest) _ d_ded2 (List.subset_cons_of_subset _ (List.Subset.refl _))

    have d_lce : DerivationTree [pAndHnp] atomP :=
      Bimodal.Theorems.Propositional.lce atomP HnegP
    have d_atomP : DerivationTree (pAndHnp :: L_rest) atomP :=
      DerivationTree.weakening [pAndHnp] (pAndHnp :: L_rest) atomP d_lce (by intro φ hφ; simp at hφ; simp [hφ])

    have d_rce : DerivationTree [pAndHnp] HnegP :=
      Bimodal.Theorems.Propositional.rce atomP HnegP
    have d_HnegP : DerivationTree (pAndHnp :: L_rest) HnegP :=
      DerivationTree.weakening [pAndHnp] (pAndHnp :: L_rest) HnegP d_rce (by intro φ hφ; simp at hφ; simp [hφ])

    -- MP: atomP → (HnegP → ⊥) and atomP gives HnegP → ⊥
    have d_HnegP_imp_bot : DerivationTree (pAndHnp :: L_rest) (HnegP.imp Formula.bot) :=
      DerivationTree.modus_ponens _ atomP _ d_ded2_w d_atomP

    -- MP: HnegP → ⊥ and HnegP gives ⊥
    have d_bot : DerivationTree (pAndHnp :: L_rest) Formula.bot :=
      DerivationTree.modus_ponens _ HnegP _ d_HnegP_imp_bot d_HnegP

    -- 9. By deduction: L_rest ⊢ pAndHnp → ⊥
    have d_neg_naming : DerivationTree L_rest (pAndHnp.imp Formula.bot) :=
      deduction_theorem L_rest pAndHnp Formula.bot d_bot

    -- 10. By iterated deduction: [] ⊢ L_rest.foldr (.imp .) (pAndHnp → ⊥)
    have d_full_theorem := iterated_deduction L_rest (pAndHnp.imp Formula.bot) d_neg_naming

    -- 11. Rearrange: we need ⊢ pAndHnp → (L_rest.foldr (.imp .) ⊥)
    -- From ⊢ L_rest.foldr (.imp .) (pAndHnp → ⊥), we want ⊢ pAndHnp → χ
    -- where χ = L_rest.foldr (.imp .) ⊥

    -- These are different! We have:
    -- ⊢ φ₁ → φ₂ → ... → φₙ → (pAndHnp → ⊥)
    -- We want:
    -- ⊢ pAndHnp → (φ₁ → φ₂ → ... → φₙ → ⊥)

    -- To go from the first to the second, we need to "move pAndHnp to the front".
    -- In context terms:
    -- From L_rest ⊢ pAndHnp → ⊥, and pAndHnp :: L_rest ⊢ ⊥ (step d_bot)
    -- By deduction on each L_rest element (putting pAndHnp first):
    -- pAndHnp :: L_rest ⊢ ⊥ (d_bot)
    -- By iterated deduction removing L_rest:
    -- [pAndHnp] ⊢ L_rest.foldr (.imp .) ⊥
    -- ... actually this requires deduction theorem on List elements, not head.

    -- Simpler: just use d_bot directly.
    -- pAndHnp :: L_rest ⊢ ⊥
    -- By deduction: L_rest ⊢ pAndHnp → ⊥ (already have this)
    -- Hmm, but we need ⊢ pAndHnp → χ, not ⊢ χ → pAndHnp → ⊥.

    -- Let me just rearrange the derivation.
    -- From d_bot: pAndHnp :: L_rest ⊢ ⊥
    -- By iterated deduction on L_rest (keeping pAndHnp):
    -- [pAndHnp] ⊢ L_rest.foldr (.imp .) ⊥

    -- iterated_deduction works on the FULL context. With context = pAndHnp :: L_rest:
    -- We can't directly use iterated_deduction because it peels off ALL elements.

    -- Alternative: use deduction_theorem for pAndHnp first:
    -- From pAndHnp :: L_rest ⊢ ⊥ (d_bot)
    -- Want: [] ⊢ pAndHnp.imp (L_rest.foldr (.imp .) ⊥)
    -- = [] ⊢ pAndHnp → φ₁ → ... → φₙ → ⊥

    -- From d_bot: (pAndHnp :: L_rest) ⊢ ⊥
    -- Apply iterated_deduction to get:
    -- [] ⊢ (pAndHnp :: L_rest).foldr (.imp .) ⊥
    -- = [] ⊢ pAndHnp → L_rest.foldr (.imp .) ⊥

    have d_irr_input : DerivationTree [] (pAndHnp.imp (L_rest.foldr Formula.imp Formula.bot)) :=
      iterated_deduction (pAndHnp :: L_rest) Formula.bot d_bot

    -- The formula χ = L_rest.foldr Formula.imp ⊥
    let χ := L_rest.foldr Formula.imp Formula.bot

    -- 12. χ is p-free (since all L_rest elements are p-free and ⊥ is p-free)
    have hχ_pfree : p ∉ χ.atoms := by
      exact not_mem_atoms_iterated_imp hL_rest_pfree (not_mem_atoms_bot p)

    -- 13. Apply IRR: ⊢ χ
    -- pAndHnp = Formula.and atomP HnegP
    -- IRR needs: ⊢ (Formula.and (Formula.atom p) (Formula.all_past (Formula.neg (Formula.atom p)))).imp φ
    -- Our d_irr_input is: ⊢ pAndHnp.imp χ where pAndHnp = Formula.and atomP HnegP
    -- and atomP = Formula.atom p, HnegP = Formula.all_past (Formula.neg (Formula.atom p))
    -- So this matches!
    have d_chi : DerivationTree [] χ :=
      DerivationTree.irr p χ hχ_pfree d_irr_input

    -- 14. χ is a theorem, so χ ∈ M
    -- χ = L_rest.foldr (.imp .) ⊥ = φ₁ → (φ₂ → ... → (φₙ → ⊥)...)
    -- All φᵢ are in M (since L_rest ⊆ M)
    -- So by iterated modus ponens: ⊥ ∈ M
    -- This contradicts M being consistent

    have h_bot_in_M : Formula.bot ∈ M :=
      iterated_imp_in_mcs h_mcs L_rest Formula.bot d_chi hL_rest_in_M

    -- M is consistent but contains ⊥
    have h_M_cons := h_mcs.1
    -- SetConsistent means all finite subsets are consistent
    -- [⊥] ⊆ M and [⊥] ⊢ ⊥ (identity)
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ List.mem_cons_self
    exact h_M_cons [Formula.bot] (by intro φ hφ; simp at hφ; rw [hφ]; exact h_bot_in_M) ⟨h_bot_deriv⟩

  · -- Not both naming formulas in L
    -- At most one of atomP, HnegP is in L
    -- So L contains at most one naming formula, rest is p-free and in M
    push_neg at h_both

    -- If atomP ∉ L:
    by_cases h_atomP : atomP ∈ L
    · -- atomP ∈ L but HnegP ∉ L (from h_both)
      have h_no_HnegP : HnegP ∉ L := h_both h_atomP

      -- All elements of L except atomP are in atomFreeSubset M p ⊆ M
      -- Filter to get L_rest without atomP
      let L_rest := L.filter (fun φ => φ ≠ atomP)
      have hL_rest_af : ∀ φ ∈ L_rest, φ ∈ atomFreeSubset M p := by
        intro φ hφ
        have hφ_filter := List.mem_filter.mp hφ
        have hφ_in_L := hφ_filter.1
        have hφ_ne := of_decide_eq_true hφ_filter.2
        have hφ_in_naming := hL_sub φ hφ_in_L
        simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff] at hφ_in_naming
        cases hφ_in_naming with
        | inl h => exact h
        | inr h =>
          cases h with
          | inl h => exact absurd h hφ_ne
          | inr h => exact absurd h (fun heq => h_no_HnegP (by simp only [HnegP]; rw [← heq]; exact hφ_in_L))
      have hL_rest_in_M : ∀ φ ∈ L_rest, φ ∈ M := by
        intro φ hφ; exact (hL_rest_af φ hφ).1

      -- Rearrange: atomP :: L_rest ⊢ ⊥
      have h_L_sub_rearr : ∀ φ ∈ L, φ ∈ (atomP :: L_rest) := by
        intro φ hφ
        by_cases hφ_eq : φ = atomP
        · simp [hφ_eq]
        · simp only [List.mem_cons]
          right; exact List.mem_filter.mpr ⟨hφ, decide_eq_true hφ_eq⟩
      have d_rearr : DerivationTree (atomP :: L_rest) Formula.bot :=
        DerivationTree.weakening L (atomP :: L_rest) _ d h_L_sub_rearr

      -- Deduction: L_rest ⊢ atomP → ⊥ = neg(atomP)
      have d_neg_atomP : DerivationTree L_rest (Formula.neg atomP) :=
        deduction_theorem L_rest atomP Formula.bot d_rearr

      -- L_rest ⊆ M and L_rest ⊢ neg(atomP)
      -- By MCS closure: neg(atomP) ∈ M
      have h_neg_atomP_in_M : Formula.neg atomP ∈ M :=
        set_mcs_closed_under_derivation h_mcs L_rest hL_rest_in_M d_neg_atomP

      -- Also, atomP may or may not be in M. We don't need this for contradiction.
      -- neg(atomP) ∈ M means (atom p → ⊥) ∈ M.
      -- From G-closure (CanonicalR M M): G(neg(atomP)) may or may not be in M.

      -- Wait, this doesn't give a contradiction in M yet.
      -- L_rest ⊆ M and L_rest ⊢ neg(atomP), so neg(atomP) ∈ M by MCS closure.
      -- But we derived this from the inconsistency of L, which includes atomP.
      -- The issue: L = L_rest ∪ {atomP} ⊢ ⊥ means L_rest ⊢ neg(atomP).
      -- So neg(atomP) ∈ M. This is fine - it just means atom p is false in M.
      -- No contradiction.

      -- Hmm, actually the contradiction should come from L being inconsistent.
      -- L ⊆ naming set, and L ⊢ ⊥. But L_rest ⊆ M and L_rest ⊢ neg(atomP).
      -- neg(atomP) ∈ M. Is atomP ∈ M? If atom p ∈ M, then both atom p and neg(atom p) in M,
      -- contradiction. If atom p ∉ M, that's fine.

      -- But wait: what if atom p ∉ M? Then L = L_rest ∪ {atomP} where atomP ∉ M.
      -- L ⊢ ⊥ just means L_rest together with an EXTRA formula atomP derives ⊥.
      -- L_rest ⊆ M is consistent (since M is consistent). So adding atomP makes it
      -- inconsistent. This is expected if neg(atomP) ∈ M.

      -- The issue is: L being a subset of the naming set and L ⊢ ⊥ doesn't
      -- necessarily mean the naming set is inconsistent if we're just witnessing
      -- that atomP is independent of M. The naming set is SUPPOSED to be consistent
      -- because IRR says so.

      -- But in this branch, HnegP ∉ L, so L only has atomP and some M-formulas.
      -- The inconsistency of L means: L_rest ⊢ neg(atomP). So neg(atomP) ∈ M.
      -- This is perfectly fine and doesn't mean the naming set is inconsistent.
      -- It just means THIS particular L is inconsistent.

      -- But the naming set is SetConsistent iff ALL finite subsets are consistent.
      -- This particular L is inconsistent, and it IS a subset of the naming set.
      -- So the naming set IS inconsistent.

      -- Wait but we haven't derived a contradiction yet! We assumed the naming set
      -- has an inconsistent finite subset L, and we're trying to reach a contradiction.

      -- In this case with only atomP (no HnegP), we can't use IRR because IRR
      -- needs (atomP AND HnegP) → φ.

      -- With just atomP: L_rest ⊢ ¬(atomP), so neg(atomP) ∈ M.
      -- Nothing wrong there. But we need to show THIS specific L is actually consistent.
      -- I.e., L = L_rest ∪ {atomP} should be consistent.

      -- L_rest ⊆ atomFreeSubset M p ⊆ M, so L_rest is consistent.
      -- atomP may or may not be in M.
      -- If neg(atomP) ∈ M (which the derivation shows), then adding atomP to L_rest
      -- makes it inconsistent. So L IS inconsistent. We need to show a contradiction.

      -- The contradiction comes from: L is a subset of the naming set, and L ⊢ ⊥.
      -- We assumed L ⊢ ⊥ (hypothesis d) and are trying to derive False.
      -- In this case, we need: the fact that L is inconsistent contradicts something.

      -- Since L ⊆ naming set and L ⊢ ⊥, this means the naming set is NOT set-consistent.
      -- That's the conclusion we DON'T want (we're trying to prove it IS consistent).

      -- Wait, I'm confused about the proof structure. Let me re-read.
      -- We're proving: naming_set_consistent, i.e., SetConsistent (namingSet M p).
      -- SetConsistent means: ∀ L, (∀ φ ∈ L, φ ∈ namingSet M p) → Consistent L.
      -- We assume L and hL_sub and ⟨d⟩ (L ⊢ ⊥) and need to derive False.

      -- In this case: L ⊆ namingSet but L ⊢ ⊥. We need False.
      -- L_rest ⊆ M and L_rest derives neg(atomP). So neg(atomP) ∈ M.
      -- This is not a contradiction per se.

      -- BUT: if atom p ∉ L (because only atomP ∈ L means atomP = atom p),
      -- wait atomP = Formula.atom p, so atomP IS atom p.

      -- Hmm. L_rest ⊆ M, and L_rest ⊢ neg(atomP). So neg(atomP) ∈ M.
      -- All of L_rest is in M. L_rest ∪ {atomP} ⊢ ⊥. L_rest ⊢ neg(atomP).
      -- neg(atomP) ∈ M.

      -- I need a contradiction. The only way is if M is somehow inconsistent.
      -- L_rest ⊆ M and Consistent L_rest (since M is consistent).
      -- neg(atomP) ∈ M. atomP may or may not be in M.
      -- If atomP ∈ M: then {atomP, neg(atomP)} ⊆ M, and {atomP, neg(atomP)} ⊢ ⊥.
      --   This contradicts SetConsistent M. So M is inconsistent. But M is MCS.
      --   So atomP ∉ M.

      -- So: atomP ∉ M. That's fine.

      -- The key issue: even though L ⊆ namingSet and L ⊢ ⊥, this is because
      -- atomP ∉ M but atomP IS in the naming set. The naming set extends M
      -- with formulas not in M, so adding atomP could create inconsistency.

      -- We can't derive False in this case without using IRR or the H formula.
      -- Since HnegP ∉ L, we can't use the IRR contrapositive argument.

      -- This means: the naming set might genuinely be inconsistent in this case!
      -- If neg(atomP) is derivable from p-free formulas of M (which are in the naming set),
      -- then atomP is in the naming set but neg(atomP) is derivable, so {atomP} ∪ L_rest ⊢ ⊥.

      -- So the naming set CAN be inconsistent even without the H formula, if p is chosen poorly.
      -- Specifically, if neg(atom p) ∈ M and neg(atom p) is p-free... but neg(atom p) mentions p!
      -- So neg(atom p) ∉ atomFreeSubset M p. Good.

      -- BUT: neg(atom p) might be DERIVABLE from p-free formulas in M.
      -- E.g., if some p-free formula implies neg(atom p).
      -- Actually, a p-free formula can't directly mention atom p, so it can't derive neg(atom p)
      -- by pure propositional reasoning. But it could derive it if there's a relevant axiom.

      -- Hmm, can a p-free derivation prove neg(atom p)?
      -- neg(atom p) = (atom p).imp bot. If we could derive this from p-free formulas,
      -- we'd need the derivation to "produce" atom p from nothing. But atom p can only
      -- appear in a derivation via an assumption or axiom mentioning p.
      -- Axioms are schema instances; an axiom instance could mention p.
      -- E.g., prop_s (atom p) (atom q): ⊢ (atom p) → ((atom q) → (atom p))
      -- This theorem mentions p.

      -- Wait, but the context L_rest is p-free. The derivation from L_rest might use
      -- axioms mentioning p (axiom instances are free to use any formula).
      -- So YES, a derivation from p-free context could produce neg(atom p) by using
      -- axiom instances that mention p!

      -- But for the IRR argument, we need the CONCLUSION to be p-free, not the axiom
      -- instances. The derivation itself can use any axiom instances.

      -- OK so in THIS case (atomP ∈ L, HnegP ∉ L), L is genuinely inconsistent,
      -- and we can't derive a contradiction. This means the naming set IS inconsistent
      -- (for this particular L).

      -- Solution: show that this case is impossible, i.e., L can't be inconsistent
      -- with only atomP from the naming formulas and p-free M-formulas.

      -- Actually wait. If L_rest are p-free M-formulas and atomP = atom p,
      -- can L_rest ∪ {atom p} ⊢ ⊥?

      -- L_rest ⊆ M (consistent), so L_rest doesn't derive ⊥.
      -- Adding atom p: L_rest ∪ {atom p} ⊢ ⊥ means L_rest ⊢ neg(atom p).
      -- neg(atom p) ∈ M (by MCS closure).
      -- neg(atom p) = atom p → ⊥ which mentions p.
      -- neg(atom p) ∉ atomFreeSubset M p (mentions p).
      -- But neg(atom p) IS derivable from L_rest, which is in M.
      -- This means M contains neg(atom p) AND all of L_rest.
      -- Nothing contradictory.

      -- The naming set contains atom p AND L_rest. Since neg(atom p) is derivable
      -- from L_rest (which are in the naming set), the naming set contains
      -- atom p and (effectively) neg(atom p). So it IS inconsistent.

      -- This means: the naming set is NOT necessarily consistent!
      -- The IRR argument only works for the case where BOTH atom p and H(¬p) are needed.

      -- CONCLUSION: This branch (atomP ∈ L, HnegP ∉ L) is problematic.
      -- The naming set can be inconsistent without using H(¬p).

      -- Wait, let me reconsider. Can L_rest (p-free formulas from M) really derive neg(atom p)?
      -- L_rest ⊢ neg(atom p) means L_rest ⊢ atom p → ⊥.
      -- The derivation tree might use axiom instances mentioning p.
      -- But can it? Axiom instances like prop_s (atom p) ... mention p.
      -- But the conclusion atom p → ⊥ mentions p.
      -- The deduction theorem: L_rest ⊢ atom p → ⊥ is obtained from
      -- (atom p :: L_rest) ⊢ ⊥ by deduction.

      -- Hmm, (atom p :: L_rest) ⊢ ⊥ requires a derivation from atom p and L_rest.
      -- atom p is an extra assumption. L_rest is p-free.
      -- Can we derive ⊥ from atom p and p-free formulas?
      -- Example: if L_rest contains nothing, can we derive ⊥ from atom p alone?
      -- [atom p] ⊢ ⊥? Only if atom p → ⊥ is a theorem. But it's not.
      -- So with L_rest = [], we can't derive ⊥.

      -- What if L_rest = [neg(neg(atom p))]? But neg(neg(atom p)) mentions p,
      -- so it's not in atomFreeSubset M p. Contradiction with L_rest being p-free.

      -- What if L_rest = [neg(atom p).imp (atom p)]? This has atoms = {p} ∪ {p} = {p}.
      -- Not p-free. Contradiction.

      -- So: can L_rest (genuinely p-free, meaning no formula mentions p) derive neg(atom p)?
      -- A p-free formula has no occurrence of p in its atoms.
      -- A derivation from p-free formulas uses axiom instances (which are universal schema
      -- instantiations and CAN mention p) and the p-free assumptions.
      -- The derivation CAN produce formulas mentioning p (via axiom instances).

      -- Example: from [], we can derive atom p → atom p (identity). This mentions p.
      -- Similarly, from [], we can derive (atom p → ⊥) → (atom p → ⊥) (identity of neg p).
      -- But can we derive atom p → ⊥ from []? No, that would make atom p inconsistent.

      -- So: from p-free L_rest, we CANNOT derive neg(atom p).
      -- Because: if L_rest ⊢ neg(atom p), then by iterated deduction [] ⊢ χ where
      -- χ is p-free (all of L_rest is p-free). But χ = L_rest.foldr (.imp .) neg(atom p).
      -- neg(atom p) mentions p, so χ mentions p. χ is NOT p-free!

      -- Wait, χ = φ₁ → ... → φₙ → neg(atom p). atoms of χ = ⋃ φᵢ.atoms ∪ neg(atom p).atoms.
      -- neg(atom p).atoms = {p}. So p ∈ χ.atoms. χ is NOT p-free.

      -- But we claimed L_rest is p-free. The derivation L_rest ⊢ neg(atom p) is valid
      -- (derivation trees can derive formulas with atoms not in the context via axiom instances).
      -- However, by iterated deduction: [] ⊢ L_rest.foldr (.imp .) neg(atom p).
      -- This theorem mentions p (in neg(atom p)).

      -- Now, is this theorem actually derivable? From L_rest (p-free) ⊢ neg(atom p):
      -- The derivation might use axiom instances mentioning p.
      -- For example: prop_s ⊥ (atom p) : ⊢ ⊥ → atom p → ⊥ = ⊢ ⊥ → neg(atom p).
      -- Combined with ⊥ from L_rest... but L_rest is consistent!

      -- Actually, L_rest ⊢ neg(atom p) can't happen if L_rest is consistent!
      -- Because L_rest ⊢ atom p → ⊥ means adding atom p to L_rest gives inconsistency.
      -- But L_rest is p-free, and adding an independent atom shouldn't cause inconsistency.
      -- Unless the derivation uses axiom instances that connect p to the L_rest formulas.

      -- Hmm, actually it CAN happen. Consider: L_rest = [neg(neg(atom q))].
      -- This is p-free (only mentions q). Can [neg(neg(atom q))] ⊢ neg(atom p)?
      -- neg(atom p) = atom p → ⊥. From neg(neg(atom q)) alone, can we derive atom p → ⊥?
      -- No, because neg(neg(atom q)) says nothing about atom p.
      -- More precisely: in any model where atom q is true and atom p is true,
      -- neg(neg(atom q)) is true and neg(atom p) is false. So the derivation is unsound.
      -- Hence it can't exist (by soundness of the proof system).

      -- So: from p-free L_rest, we CANNOT derive neg(atom p) (by soundness!).
      -- Because: if L_rest ⊢ neg(atom p), then by soundness L_rest ⊨ neg(atom p).
      -- But in a model where all L_rest formulas are true AND atom p is true,
      -- neg(atom p) is false. Such a model exists (since L_rest is p-free,
      -- the truth of L_rest doesn't depend on atom p's value).

      -- This is the key insight! L_rest (p-free) ⊢ neg(atom p) contradicts soundness.

      -- So this case (L ⊆ naming set, L ⊢ ⊥, atomP ∈ L, HnegP ∉ L) is IMPOSSIBLE.
      -- L_rest ⊢ neg(atomP) is impossible since L_rest is p-free.

      -- To formalize this, we'd need soundness. But that's a heavyweight dependency.
      -- Alternative: use the IRR rule directly to derive a contradiction.

      -- Actually, a simpler argument: from L_rest ⊢ neg(atom p):
      -- By iterated deduction: ⊢ L_rest.foldr (.imp .) (neg(atom p))
      -- The formula χ = L_rest.foldr (.imp .) (neg(atom p)) has p ∈ χ.atoms.
      -- But all subformulas from L_rest are p-free.
      -- χ.atoms = ⋃ atoms of L_rest formulas ∪ {p} (from neg(atom p))
      -- So p ∈ χ.atoms ONLY because of neg(atom p).

      -- We can split: from L_rest ⊢ atom p → ⊥, and L_rest is p-free:
      -- atom p :: L_rest ⊢ ⊥
      -- Equivalently: {atom p} ∪ L_rest ⊢ ⊥
      -- But atom p is "independent" of L_rest (they don't mention p).

      -- By a syntactic independence argument (or by invoking the IRR rule):
      -- From atom p :: L_rest ⊢ ⊥, by deduction: L_rest ⊢ atom p → ⊥ = neg(atom p)
      -- By iterated deduction: ⊢ L_rest.foldr (.imp .) (neg(atom p))
      -- Now, neg(atom p) = (atom p).imp ⊥.
      -- L_rest.foldr (.imp .) ((atom p).imp ⊥) mentions p only via (atom p).imp ⊥.

      -- Use the weakening trick: from ⊢ χ where χ = ... → atom p → ⊥:
      -- Since ⊢ ⊥ → ⊥ (identity of ⊥) and ⊢ χ, we can derive ⊢ ... → ⊥ → ⊥.
      -- No, that's not the same.

      -- Let me use IRR! We have:
      -- ⊢ (atom p ∧ H(¬p)) → anything_p_free (by assuming and deriving)
      -- Hmm, not directly.

      -- Actually, the simple argument is:
      -- L_rest ⊢ neg(atom p)
      -- This means L_rest ∪ {atom p} ⊢ ⊥
      -- But also, atom p does not appear in L_rest (p-free formulas).
      -- By a substitution argument: replace atom p with ⊥ everywhere in the derivation.
      -- All L_rest formulas are unchanged (p-free). atom p becomes ⊥.
      -- So L_rest ∪ {⊥} ⊢ ⊥. Which gives L_rest ⊢ ⊥ → ⊥... no, L_rest ⊢ neg(⊥)... no.

      -- This substitution argument is hard to formalize.

      -- The CLEANEST approach: from L_rest ⊢ neg(atom p):
      -- neg(atom p) = atom p → ⊥
      -- ⊢ ⊥ → (atom p → ⊥) (by prop_s ⊥ (atom p))
      -- i.e., ⊢ ⊥ → neg(atom p)
      -- Also, ⊢ (⊥ → neg(atom p)) → (neg(neg(atom p)) → ⊥) ... hmm, contraposition.

      -- I think the cleanest route is: use the fact that L_rest ⊆ M and M is consistent.
      -- L_rest ⊢ neg(atom p). So neg(atom p) ∈ M (by MCS closure).
      -- Then, L_rest ∪ {atom p} ⊢ ⊥. All of L_rest is in M. atom p may not be in M.
      -- neg(atom p) ∈ M means atom p ∉ M (by MCS consistency).
      -- Nothing contradictory yet.

      -- Hmm, we need a CONTRADICTION (prove False). The whole point is that
      -- L ⊆ namingSet and L ⊢ ⊥ should lead to False.

      -- I think the issue is that our naming set CAN be inconsistent when only
      -- atomP is used (without HnegP). The fix: use a DIFFERENT naming set
      -- or prove that this case doesn't arise.

      -- WAIT. Actually, let me reconsider. If L ⊆ namingSet and L ⊢ ⊥ and
      -- HnegP ∉ L, then all of L ⊆ atomFreeSubset M p ∪ {atomP}.
      -- L_rest ⊆ atomFreeSubset M p ⊆ M.
      -- If atomP ∈ M: then all of L ⊆ M, so L ⊆ M, and L ⊢ ⊥ contradicts SetConsistent M.
      -- If atomP ∉ M: L_rest ⊢ neg(atomP), so neg(atomP) ∈ M. atomP ∉ M. Fine.
      --   But we need to show L is consistent. L = L_rest ∪ {atomP}.
      --   L_rest is consistent (M is consistent).
      --   Adding atomP: is L_rest ∪ {atomP} consistent?
      --   If neg(atomP) is derivable from L_rest, then NO.
      --   But is neg(atomP) derivable from L_rest?

      -- We're going in circles. The key question is whether p-free formulas can derive neg(atom p).

      -- I'll use a direct soundness argument to show this is impossible,
      -- or alternatively, I'll restrict the naming set differently.

      -- SIMPLEST FIX: change the naming set to include BOTH atom p AND H(neg p) always.
      -- I.e., any subset L of the naming set that contains atom p must also contain H(neg p)
      -- for the IRR argument to work.

      -- Actually, the issue is that the naming set AS DEFINED can have inconsistent
      -- subsets not involving H(neg p). The standard proof assumes this can't happen
      -- because p is "fresh" (not appearing in M at all). In that case,
      -- atomFreeSubset M p = M (all of M is p-free), and M is consistent.
      -- Adding {atom p, H(neg p)} can't make it inconsistent from just atom p alone
      -- because atom p is "independent" of M.

      -- In our case, atomFreeSubset M p ⊊ M (some formulas in M mention p).
      -- The p-free part of M together with atom p might be inconsistent if
      -- the p-free part derives neg(atom p). But by soundness, p-free formulas
      -- can't derive anything about atom p.

      -- TO FORMALIZE: we use the fact that p-free derivations can't produce
      -- conclusions that essentially "depend on" p. Concretely:
      -- If L_rest is p-free and L_rest ⊢ ⊥, then M is inconsistent (contradiction).
      -- If L_rest is p-free and L_rest ⊬ ⊥, then L_rest ∪ {atom p} ⊬ ⊥
      -- (because atom p is "fresh" relative to L_rest).

      -- The last point needs a proof. It's essentially: if a set of formulas S
      -- doesn't derive ⊥, and p is a fresh atom not in any formula of S,
      -- then S ∪ {atom p} doesn't derive ⊥.

      -- This follows from: if S ∪ {atom p} ⊢ ⊥, then S ⊢ neg(atom p).
      -- And ⊢ neg(atom p) → (atom p → ⊥). By deduction and weakening:
      -- [] ⊢ S.foldr (.imp .) (neg(atom p)). Then we can use a substitution
      -- or model-theoretic argument.

      -- I think the cleanest formalization uses IRR:
      -- From L_rest ⊢ neg(atom p) = atom p → ⊥:
      -- By prop_s: ⊢ (atom p → ⊥) → ((H(¬p)) → (atom p → ⊥))
      -- So L_rest ⊢ H(¬p) → (atom p → ⊥)
      -- Which gives L_rest ⊢ (atom p ∧ H(¬p)) → ⊥ (roughly)
      -- Actually we need (atom p ∧ H(¬p)) → ⊥ from L_rest.

      -- Hmm, let me try: from L_rest ⊢ atom p → ⊥:
      -- In context (atom p ∧ H(¬p)) :: L_rest:
      -- Derive atom p (from conjunction) and then ⊥ (from L_rest ⊢ atom p → ⊥).
      -- So (pAndHnp :: L_rest) ⊢ ⊥.
      -- By iterated deduction: ⊢ pAndHnp → L_rest.foldr (.imp .) ⊥.
      -- Let χ = L_rest.foldr (.imp .) ⊥. χ is p-free.
      -- By IRR: ⊢ χ. Then χ ∈ M. All L_rest in M. So ⊥ ∈ M. Contradiction.

      -- YES! This works! Even in the case where only atomP is in L (not HnegP),
      -- we can STILL use IRR by artificially adding the H(¬p) assumption.
      -- The derivation just ignores H(¬p) (via weakening).

      -- Let me build this derivation.

      -- We have d_neg_atomP : L_rest ⊢ neg(atomP) = atom p → ⊥

      -- Build: pAndHnp :: L_rest ⊢ ⊥
      have d_lce' : DerivationTree [pAndHnp] atomP :=
        Bimodal.Theorems.Propositional.lce atomP HnegP
      have d_atomP' : DerivationTree (pAndHnp :: L_rest) atomP :=
        DerivationTree.weakening [pAndHnp] (pAndHnp :: L_rest) atomP d_lce'
          (by intro φ hφ; simp at hφ; simp [hφ])
      have d_neg_w : DerivationTree (pAndHnp :: L_rest) (Formula.neg atomP) :=
        DerivationTree.weakening L_rest (pAndHnp :: L_rest) _ d_neg_atomP
          (List.subset_cons_of_subset _ (List.Subset.refl _))
      have d_bot' : DerivationTree (pAndHnp :: L_rest) Formula.bot :=
        DerivationTree.modus_ponens _ atomP _ d_neg_w d_atomP'

      -- pAndHnp :: L_rest ⊢ ⊥. By iterated deduction:
      have d_irr_input' : DerivationTree [] (pAndHnp.imp (L_rest.foldr Formula.imp Formula.bot)) :=
        iterated_deduction (pAndHnp :: L_rest) Formula.bot d_bot'

      -- L_rest is p-free, so χ is p-free
      let L_rest_filtered := L.filter (fun φ => φ ≠ atomP)
      -- Actually L_rest was already defined above. Let me use hL_rest_pfree.
      -- Wait, L_rest here is defined as L.filter (fun φ => φ ≠ atomP).
      -- But earlier in the other branch, L_rest was L.filter (fun φ => φ ≠ atomP ∧ φ ≠ HnegP).
      -- Since HnegP ∉ L in this branch, both definitions give the same result.

      -- We need p ∉ atoms of L_rest formulas. All L_rest are in atomFreeSubset M p.
      have hL_rest_pfree' : ∀ φ ∈ L_rest, p ∉ φ.atoms := by
        intro φ hφ
        exact (hL_rest_af φ hφ).2

      have hχ_pfree' : p ∉ (L_rest.foldr Formula.imp Formula.bot).atoms :=
        not_mem_atoms_iterated_imp hL_rest_pfree' (not_mem_atoms_bot p)

      have d_chi' : DerivationTree [] (L_rest.foldr Formula.imp Formula.bot) :=
        DerivationTree.irr p _ hχ_pfree' d_irr_input'

      have h_bot_in_M' : Formula.bot ∈ M :=
        iterated_imp_in_mcs h_mcs L_rest Formula.bot d_chi' hL_rest_in_M

      have h_bot_deriv' : DerivationTree [Formula.bot] Formula.bot :=
        DerivationTree.assumption _ _ List.mem_cons_self
      exact h_mcs.1 [Formula.bot] (by intro φ hφ; simp at hφ; rw [hφ]; exact h_bot_in_M') ⟨h_bot_deriv'⟩

    · -- atomP ∉ L
      by_cases h_HnegP : HnegP ∈ L
      · -- HnegP ∈ L but atomP ∉ L
        -- Similar to above: L_rest ⊆ atomFreeSubset M p ∪ {HnegP}
        -- Since atomP ∉ L, all elements are either in atomFreeSubset or = HnegP

        let L_rest := L.filter (fun φ => φ ≠ HnegP)
        have hL_rest_af : ∀ φ ∈ L_rest, φ ∈ atomFreeSubset M p := by
          intro φ hφ
          have hφ_filter := List.mem_filter.mp hφ
          have hφ_in_L := hφ_filter.1
          have hφ_ne := of_decide_eq_true hφ_filter.2
          have hφ_in_naming := hL_sub φ hφ_in_L
          simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff] at hφ_in_naming
          cases hφ_in_naming with
          | inl h => exact h
          | inr h =>
            cases h with
            | inl h => exact absurd h (fun heq => h_atomP (by simp only [atomP]; rw [← heq]; exact hφ_in_L))
            | inr h => exact absurd h hφ_ne
        have hL_rest_pfree : ∀ φ ∈ L_rest, p ∉ φ.atoms := by
          intro φ hφ; exact (hL_rest_af φ hφ).2
        have hL_rest_in_M : ∀ φ ∈ L_rest, φ ∈ M := by
          intro φ hφ; exact (hL_rest_af φ hφ).1

        -- Rearrange: HnegP :: L_rest ⊢ ⊥
        have h_L_sub_rearr : ∀ φ ∈ L, φ ∈ (HnegP :: L_rest) := by
          intro φ hφ
          by_cases hφ_eq : φ = HnegP
          · simp [hφ_eq]
          · simp only [List.mem_cons]; right; exact List.mem_filter.mpr ⟨hφ, decide_eq_true hφ_eq⟩
        have d_rearr : DerivationTree (HnegP :: L_rest) Formula.bot :=
          DerivationTree.weakening L (HnegP :: L_rest) _ d h_L_sub_rearr

        -- Similar IRR argument: artificially add atomP
        -- Build pAndHnp :: L_rest ⊢ ⊥
        have d_rce' : DerivationTree [pAndHnp] HnegP :=
          Bimodal.Theorems.Propositional.rce atomP HnegP
        have d_HnegP' : DerivationTree (pAndHnp :: L_rest) HnegP :=
          DerivationTree.weakening [pAndHnp] (pAndHnp :: L_rest) HnegP d_rce'
            (by intro φ hφ; simp at hφ; simp [hφ])

        -- Deduction from HnegP :: L_rest: L_rest ⊢ HnegP → ⊥
        have d_ded_hnp : DerivationTree L_rest (HnegP.imp Formula.bot) :=
          deduction_theorem L_rest HnegP Formula.bot d_rearr

        -- Weaken to pAndHnp :: L_rest
        have d_ded_w : DerivationTree (pAndHnp :: L_rest) (HnegP.imp Formula.bot) :=
          DerivationTree.weakening L_rest (pAndHnp :: L_rest) _ d_ded_hnp
            (List.subset_cons_of_subset _ (List.Subset.refl _))

        -- MP: HnegP → ⊥ and HnegP gives ⊥
        have d_bot' : DerivationTree (pAndHnp :: L_rest) Formula.bot :=
          DerivationTree.modus_ponens _ HnegP _ d_ded_w d_HnegP'

        have d_irr_input' : DerivationTree [] (pAndHnp.imp (L_rest.foldr Formula.imp Formula.bot)) :=
          iterated_deduction (pAndHnp :: L_rest) Formula.bot d_bot'

        have hχ_pfree' : p ∉ (L_rest.foldr Formula.imp Formula.bot).atoms :=
          not_mem_atoms_iterated_imp hL_rest_pfree (not_mem_atoms_bot p)

        have d_chi' : DerivationTree [] (L_rest.foldr Formula.imp Formula.bot) :=
          DerivationTree.irr p _ hχ_pfree' d_irr_input'

        have h_bot_in_M' : Formula.bot ∈ M :=
          iterated_imp_in_mcs h_mcs L_rest Formula.bot d_chi' hL_rest_in_M

        have h_bot_deriv' : DerivationTree [Formula.bot] Formula.bot :=
          DerivationTree.assumption _ _ List.mem_cons_self
        exact h_mcs.1 [Formula.bot] (by intro φ hφ; simp at hφ; rw [hφ]; exact h_bot_in_M') ⟨h_bot_deriv'⟩

      · -- Neither atomP nor HnegP in L
        -- All of L ⊆ atomFreeSubset M p ⊆ M
        have hL_in_M : ∀ φ ∈ L, φ ∈ M := by
          intro φ hφ
          have hφ_in_naming := hL_sub φ hφ
          simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff] at hφ_in_naming
          cases hφ_in_naming with
          | inl h => exact h.1
          | inr h =>
            cases h with
            | inl h => exact absurd h (fun heq => h_atomP (by simp only [atomP]; rw [← heq]; exact hφ))
            | inr h => exact absurd h (fun heq => h_HnegP (by simp only [HnegP]; rw [← heq]; exact hφ))
        -- L ⊆ M and L ⊢ ⊥ contradicts SetConsistent M
        exact h_mcs.1 L hL_in_M ⟨d⟩

/-!
## GContent M ⊆ M' (CanonicalR preservation)

When M' extends the naming set, we need GContent M ⊆ M'.
For p-free formulas in GContent M, this is direct.
For formulas mentioning p: they are theorems (and hence in M') or
they are atom p (which is in M').
-/

-- Note: The GContent ⊆ M' argument is not needed for the main theorem below,
-- which uses the naming set construction directly.

/-!
## Main Theorem: CanonicalR Irreflexivity
-/

/--
CanonicalR is irreflexive: for any MCS M, `¬CanonicalR M M`.

**STATUS: PROVED (Task 967 - Reflexive Semantics Refactor)**

Proof uses the T-axiom for past (H(φ) → φ), which is valid under the reflexive
temporal semantics adopted in Task 967. This enables the key step:
  H(neg(p)) ∈ M' → neg(p) ∈ M'
which provides the contradiction with atom(p) ∈ M' from the naming set.

Proof outline (Gabbay IRR):
1. Assume `CanonicalR M M` (i.e., `GContent M ⊆ M`) for contradiction.
2. Choose any atom p. The naming set `atomFreeSubset M p ∪ {atom p, H(¬p)}`
   is set-consistent (by naming_set_consistent).
3. Extend to MCS M' via Lindenbaum.
4. From naming set: atom(p) ∈ M' and H(neg(p)) ∈ M'.
5. By T-axiom for past: H(neg(p)) → neg(p), so neg(p) ∈ M'.
6. Both atom(p) and neg(p) in M' contradicts M' being consistent.

References:
- Goldblatt (1992), Logics of Time and Computation, Chapter 6.
- Gabbay (1981), Irreflexivity Lemma.
- Task 967 research-002.md: Analysis of T-axiom enabling this proof.
-/
theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M := by
  intro h_R
  -- Choose any atom p. We use Atom.mk_base "p" for concreteness.
  let p : Atom := Atom.mk_base "p"
  -- The naming set is consistent
  have h_ns_cons := naming_set_consistent M h_mcs h_R p
  -- Extend to MCS M'
  obtain ⟨M', h_ext, h_mcs'⟩ := set_lindenbaum (namingSet M p) h_ns_cons
  -- atom p ∈ M' (from naming set)
  have h_atomP_in_M' : Formula.atom p ∈ M' := by
    apply h_ext
    simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff]
    right; left; trivial
  -- H(neg(atom p)) ∈ M' (from naming set)
  have h_HnegP_in_M' : Formula.all_past (Formula.neg (Formula.atom p)) ∈ M' := by
    apply h_ext
    simp only [namingSet, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff]
    right; right; trivial

  -- KEY STEP: Apply T-axiom for past to get neg(atom p) ∈ M'
  -- T-axiom (past): H(φ) → φ is an axiom (temp_t_past)
  -- Since M' is an MCS and temp_t_past is an axiom, (H(neg(p)) → neg(p)) ∈ M'
  have h_T_axiom_in_M' : (Formula.all_past (Formula.neg (Formula.atom p))).imp
      (Formula.neg (Formula.atom p)) ∈ M' :=
    theorem_in_mcs h_mcs' (DerivationTree.axiom [] _ (Axiom.temp_t_past (Formula.neg (Formula.atom p))))
  -- By modus ponens: from H(neg(p)) ∈ M' and (H(neg(p)) → neg(p)) ∈ M', get neg(p) ∈ M'
  have h_negP_in_M' : Formula.neg (Formula.atom p) ∈ M' :=
    set_mcs_implication_property h_mcs' h_T_axiom_in_M' h_HnegP_in_M'

  -- CONTRADICTION: Both atom p and neg(atom p) are in M'
  -- M' is an MCS, so it is consistent. But having both p and ¬p contradicts consistency.
  -- neg(atom p) = (atom p).imp bot, so from atom p and neg(atom p), derive bot
  have h_bot_in_M' : Formula.bot ∈ M' :=
    set_mcs_implication_property h_mcs' h_negP_in_M' h_atomP_in_M'
  -- But M' is SetConsistent (since M' is SetMaximalConsistent), so bot ∉ M'
  -- SetConsistent M' means: for any L ⊆ M', Consistent L
  -- If bot ∈ M', then [bot] ⊆ M', so Consistent [bot]
  -- But [bot] ⊢ bot (trivially), contradicting Consistent [bot]
  have h_set_consistent : SetConsistent M' := h_mcs'.1
  have h_bot_list_consistent : Consistent [Formula.bot] := by
    apply h_set_consistent [Formula.bot]
    intro φ hφ
    simp at hφ
    rw [hφ]
    exact h_bot_in_M'
  -- But [bot] ⊢ bot trivially (context contains bot)
  have h_bot_in_list : Formula.bot ∈ [Formula.bot] := List.mem_singleton.mpr rfl
  have h_bot_derives : DerivationTree [Formula.bot] Formula.bot :=
    DerivationTree.assumption [Formula.bot] Formula.bot h_bot_in_list
  exact h_bot_list_consistent ⟨h_bot_derives⟩

end

end Bimodal.Metalogic.Bundle
