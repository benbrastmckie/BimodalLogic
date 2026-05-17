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
  | .all_past psi => .all_past (subst_formula psi target replacement)
  | .all_future psi => .all_future (subst_formula psi target replacement)
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
  sorry

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

/-- Put a formula in DNF (abstract signature -- details deferred).
    Returns a list of conjunctive clauses whose disjunction is equivalent to phi. -/
def to_DNF (_phi : Formula) : List Clause := sorry

/-- Put a formula in CNF (abstract signature -- details deferred).
    Returns a list of disjunctive clauses whose conjunction is equivalent to phi. -/
def to_CNF (_phi : Formula) : List Clause := sorry

/-- DNF conversion preserves integer-time equivalence. -/
theorem dnf_equiv (phi : Formula) : int_equiv phi (from_DNF (to_DNF phi)) := sorry

/-- CNF conversion preserves integer-time equivalence. -/
theorem cnf_equiv (phi : Formula) : int_equiv phi (from_CNF (to_CNF phi)) := sorry

/-! ## Freshness Infrastructure -/

/-- Generate a fresh atom not appearing in a formula.
    Uses the fresh_index mechanism of the Atom type.
    The index is chosen as the cardinality of the atom set, which
    guarantees freshness since all atoms "_sep"/k with k < card are distinct. -/
noncomputable def fresh_atom (phi : Formula) : Atom :=
  Atom.mk_fresh "_sep" phi.atoms.card

/-- The fresh atom does not appear in the formula. -/
theorem fresh_atom_not_in (phi : Formula) : fresh_atom phi ∉ phi.atoms := by
  sorry

/-- Generate n fresh atoms not appearing in a formula or each other. -/
noncomputable def fresh_atoms (phi : Formula) (n : Nat) : List Atom :=
  List.range n |>.map fun i => Atom.mk_fresh "_sep" (phi.atoms.card + i)

/-- All atoms in fresh_atoms are distinct from each other and from atoms in phi. -/
theorem fresh_atoms_disjoint (phi : Formula) (n : Nat) :
    ∀ a ∈ fresh_atoms phi n, a ∉ phi.atoms := by
  sorry

/-- Fresh atoms are pairwise distinct. -/
theorem fresh_atoms_nodup (phi : Formula) (n : Nat) :
    (fresh_atoms phi n).Nodup := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
