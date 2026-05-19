import Bimodal.Metalogic.WeakCanonical.Separation.Defs

/-!
# Formula Operations for Separation

Provides substitution, DNF/CNF signatures, and freshness infrastructure
needed by the separation proof.

## Key Definitions

- `subst_formula`: Substitute a formula for an atom
- `IntStructure.withAtom`: Modify valuation at a single atom
- `subst_correctness`: Substitution preserves truth under modified valuation
- `fresh_atom`, `fresh_atoms`: Generate fresh atoms not appearing in a formula

## References

- GHR94, Chapter 10.2: Substitution is used extensively in Lemmas 10.2.5-10.2.8
- Research report Section 6.1
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Substitution -/

/-- Substitute a formula for an atom in a formula.
    Replaces every occurrence of `target` atom with `replacement` formula. -/
def subst_formula (phi : Formula) (target : Atom) (replacement : Formula) : Formula :=
  match phi with
  | .atom a => if a = target then replacement else .atom a
  | .bot => .bot
  | .imp psi1 psi2 => .imp (subst_formula psi1 target replacement)
      (subst_formula psi2 target replacement)
  | .box psi => .box (subst_formula psi target replacement)
  | .untl psi1 psi2 => .untl (subst_formula psi1 target replacement)
      (subst_formula psi2 target replacement)
  | .snce psi1 psi2 => .snce (subst_formula psi1 target replacement)
      (subst_formula psi2 target replacement)

/-- Modify an IntStructure's valuation at a single atom. -/
def IntStructure.withAtom (M : IntStructure) (a : Atom) (S : Set Int) : IntStructure where
  val b := if b = a then S else M.val b

/-- Substitution preserves truth when the atom is interpreted as the replacement.
    This is the key correctness theorem for the substitution operation used
    throughout Lemmas 10.2.5-10.2.8. -/
theorem subst_correctness (phi : Formula) (target : Atom) (replacement : Formula)
    (M : IntStructure) (t : Int) :
    int_truth M t (subst_formula phi target replacement) ↔
    int_truth (M.withAtom target {s | int_truth M s replacement}) t phi := by
  induction phi generalizing t with
  | atom a =>
    simp only [subst_formula]
    split
    · next h => subst h; simp [int_truth, IntStructure.withAtom, Set.mem_setOf_eq]
    · next h => simp [int_truth, IntStructure.withAtom, h]
  | bot => exact Iff.rfl
  | imp p q ihp ihq =>
    constructor
    · intro h hp; exact (ihq t).mp (h ((ihp t).mpr hp))
    · intro h hp; exact (ihq t).mpr (h ((ihp t).mp hp))
  | box p _ih => exact Iff.rfl
  | untl p q ihp ihq =>
    constructor
    · rintro ⟨s, hts, hp, hq⟩
      exact ⟨s, hts, (ihp s).mp hp, fun r hr1 hr2 => (ihq r).mp (hq r hr1 hr2)⟩
    · rintro ⟨s, hts, hp, hq⟩
      exact ⟨s, hts, (ihp s).mpr hp, fun r hr1 hr2 => (ihq r).mpr (hq r hr1 hr2)⟩
  | snce p q ihp ihq =>
    constructor
    · rintro ⟨s, hst, hp, hq⟩
      exact ⟨s, hst, (ihp s).mp hp, fun r hr1 hr2 => (ihq r).mp (hq r hr1 hr2)⟩
    · rintro ⟨s, hst, hp, hq⟩
      exact ⟨s, hst, (ihp s).mpr hp, fun r hr1 hr2 => (ihq r).mpr (hq r hr1 hr2)⟩

/-! ## Normal Form Signatures -/

/-- A literal is either a formula or its negation, tagged by sign. -/
inductive Literal where
  | pos (phi : Formula) : Literal
  | neg (phi : Formula) : Literal

/-- Convert a literal to its underlying formula. -/
def Literal.toFormula : Literal -> Formula
  | .pos phi => phi
  | .neg phi => Formula.neg phi

/-- A clause is a list of literals (conjunction in DNF, disjunction in CNF). -/
abbrev Clause := List Literal

/-- Convert a conjunctive clause to a formula. -/
def clause_to_conj : Clause -> Formula
  | [] => Formula.neg .bot  -- True
  | [l] => l.toFormula
  | l :: ls => Formula.and l.toFormula (clause_to_conj ls)

/-- Convert a disjunctive clause to a formula. -/
def clause_to_disj : Clause -> Formula
  | [] => .bot
  | [l] => l.toFormula
  | l :: ls => Formula.or l.toFormula (clause_to_disj ls)

/-- Convert a DNF representation (list of conjunctive clauses) to a formula.
    DNF = disjunction of conjunctions. -/
def from_DNF : List Clause -> Formula
  | [] => .bot
  | [c] => clause_to_conj c
  | c :: cs => Formula.or (clause_to_conj c) (from_DNF cs)

/-- Convert a CNF representation (list of disjunctive clauses) to a formula.
    CNF = conjunction of disjunctions. -/
def from_CNF : List Clause -> Formula
  | [] => Formula.neg .bot  -- True
  | [c] => clause_to_disj c
  | c :: cs => Formula.and (clause_to_disj c) (from_CNF cs)

/-- Put a formula in DNF (trivial normal form: single clause with the formula itself).
    Returns a list of conjunctive clauses whose disjunction is equivalent to phi.
    Note: This is the identity embedding -- a formula is trivially its own 1-clause DNF.
    The full normalization is not needed; the separation proof only requires correctness. -/
def to_DNF (phi : Formula) : List Clause := [[Literal.pos phi]]

/-- Put a formula in CNF (trivial normal form: single clause with the formula itself).
    Returns a list of disjunctive clauses whose conjunction is equivalent to phi.
    Note: This is the identity embedding -- a formula is trivially its own 1-clause CNF. -/
def to_CNF (phi : Formula) : List Clause := [[Literal.pos phi]]

/-- DNF conversion preserves integer-time equivalence. -/
theorem dnf_equiv (phi : Formula) : int_equiv phi (from_DNF (to_DNF phi)) := by
  show int_equiv phi (from_DNF [[Literal.pos phi]])
  simp only [from_DNF, clause_to_conj, Literal.toFormula]
  exact int_equiv_refl phi

/-- CNF conversion preserves integer-time equivalence. -/
theorem cnf_equiv (phi : Formula) : int_equiv phi (from_CNF (to_CNF phi)) := by
  show int_equiv phi (from_CNF [[Literal.pos phi]])
  simp only [from_CNF, clause_to_disj, Literal.toFormula]
  exact int_equiv_refl phi

/-! ## Freshness Infrastructure -/

/-- For any finset of atoms, there exists an atom not in it.
    Proof: Atom is infinite (via injective mk_fresh from Nat), so no finite set covers all atoms. -/
private theorem exists_atom_not_in_finset (S : Finset Atom) : ∃ a : Atom, a ∉ S := by
  by_contra h
  push_neg at h
  -- h : ∀ a : Atom, a ∈ S
  -- The map n ↦ mk_fresh "" n is injective, giving infinitely many atoms
  -- But if all are in S, then S would need to be infinite, contradicting Finset.finite
  have hinj := Atom.mk_fresh_injective ""
  have himg : ∀ n : Nat, Atom.mk_fresh "" n ∈ S := fun n => h _
  -- Finset.range (S.card + 1) has S.card + 1 elements, and its image under mk_fresh ""
  -- has S.card + 1 elements (by injectivity), all in S (by himg).
  -- But S only has S.card elements. Contradiction.
  have hle : S.card + 1 ≤ S.card := by
    calc S.card + 1
        = (Finset.image (Atom.mk_fresh "") (Finset.range (S.card + 1))).card := by
          rw [Finset.card_image_of_injective _ hinj, Finset.card_range]
      _ ≤ S.card := Finset.card_le_card (fun x hx => by
          simp only [Finset.mem_image, Finset.mem_range] at hx
          obtain ⟨n, _, rfl⟩ := hx
          exact himg n)
  omega

/-- For any finset of atoms and natural number n, there exist n distinct atoms not in the finset. -/
private theorem exists_n_fresh_atoms (S : Finset Atom) (n : Nat) :
    ∃ L : List Atom, L.length = n ∧ L.Nodup ∧ ∀ a ∈ L, a ∉ S := by
  induction n with
  | zero => exact ⟨[], rfl, List.nodup_nil, fun _ h => by simp at h⟩
  | succ k ih =>
    obtain ⟨L, hlen, hnodup, hfresh⟩ := ih
    have hex : ∃ a : Atom, a ∉ S ∧ a ∉ L.toFinset := by
      have := exists_atom_not_in_finset (S ∪ L.toFinset)
      obtain ⟨a, ha⟩ := this
      rw [Finset.mem_union] at ha
      push_neg at ha
      exact ⟨a, ha.1, ha.2⟩
    obtain ⟨a, ha_fresh, ha_nodup⟩ := hex
    refine ⟨a :: L, by simp [hlen], ?_, ?_⟩
    · refine List.Nodup.cons ?_ hnodup
      rwa [← List.mem_toFinset]
    · intro b hb
      simp only [List.mem_cons] at hb
      rcases hb with rfl | hb
      · exact ha_fresh
      · exact hfresh b hb

/-- Generate a fresh atom not appearing in a formula.
    Uses classical choice from the fact that Atom is infinite. -/
noncomputable def fresh_atom (phi : Formula) : Atom :=
  (exists_atom_not_in_finset phi.atoms).choose

/-- The fresh atom does not appear in the formula. -/
theorem fresh_atom_not_in (phi : Formula) : fresh_atom phi ∉ phi.atoms :=
  (exists_atom_not_in_finset phi.atoms).choose_spec

/-- Generate n fresh atoms not appearing in a formula or each other. -/
noncomputable def fresh_atoms (phi : Formula) (n : Nat) : List Atom :=
  (exists_n_fresh_atoms phi.atoms n).choose

/-- All atoms in fresh_atoms are distinct from each other and from atoms in phi. -/
theorem fresh_atoms_disjoint (phi : Formula) (n : Nat) :
    ∀ a ∈ fresh_atoms phi n, a ∉ phi.atoms := by
  exact (exists_n_fresh_atoms phi.atoms n).choose_spec.2.2

/-- Fresh atoms are pairwise distinct. -/
theorem fresh_atoms_nodup (phi : Formula) (n : Nat) :
    (fresh_atoms phi n).Nodup :=
  (exists_n_fresh_atoms phi.atoms n).choose_spec.2.1

/-- The number of fresh atoms equals n. -/
theorem fresh_atoms_length (phi : Formula) (n : Nat) :
    (fresh_atoms phi n).length = n :=
  (exists_n_fresh_atoms phi.atoms n).choose_spec.1

/-! ## Multi-Substitution

Substitute multiple atoms simultaneously. Used in Lemma 10.2.6 when
abstracting multiple U-types to fresh atoms and substituting back. -/

/-- Apply a list of substitutions sequentially: for each (atom, formula) pair,
    replace atom with formula in the result of prior substitutions. -/
def multi_subst (phi : Formula) (subs : List (Atom × Formula)) : Formula :=
  subs.foldl (fun acc ⟨a, f⟩ => subst_formula acc a f) phi

/-- Multi-substitution with an empty list is the identity. -/
theorem multi_subst_nil (phi : Formula) : multi_subst phi [] = phi := rfl

/-- Multi-substitution with a single entry is just subst_formula. -/
theorem multi_subst_singleton (phi : Formula) (a : Atom) (f : Formula) :
    multi_subst phi [(a, f)] = subst_formula phi a f := rfl

end Bimodal.Metalogic.WeakCanonical.Separation
