import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.ProofSystem.Substitution
import Mathlib.Data.Finset.Union

/-!
# Canonical Frame Accessibility: Reflexive Semantics

## STATUS: AXIOM-FREE

**This module establishes reflexivity of the canonical accessibility relation.**

### Semantic Foundation

Under reflexive semantics (G/H quantify over s >= t / s <= t), the T-axiom
`G(phi) -> phi` is valid. This immediately gives `ExistsTask M M` for all MCS M,
since `g_content(M) subseteq M` follows from T-axiom closure.

### Key Theorems

- `existsTask_reflexive`: ExistsTask M M holds for all MCS M (via T-axiom)
- `existsTask_past_reflexive`: ExistsTask_past M M holds for all MCS M
- All proofs are axiom-free

### Per-Construction Strictness Pattern

When strictness (M != W) is needed for witness constructions:
1. Identify formula phi that distinguishes W from M
2. Show G(phi) in W (so phi in g_content(W))
3. Show phi not in M
4. Apply `strict_of_formula_in_g_content_not_in_source` to get not ExistsTask W M

This pattern provides local strictness proofs without requiring universal
irreflexivity (which is false under reflexive semantics).

### References

- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Chapter 5.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

-- Classical decidability for set membership
attribute [local instance] Classical.propDecidable

noncomputable section

/-!
## Atoms of a Set of Formulas

For any set S of formulas, we define atoms_of_set(S) as the union of all atoms
appearing in formulas of S. This is used for freshness arguments.
-/

/-- All atoms appearing in formulas of a set. -/
def atoms_of_set (S : Set Formula) : Set Atom :=
  { q | ∃ φ ∈ S, q ∈ φ.atoms }

/-- Membership in atoms_of_set. -/
theorem mem_atoms_of_set_iff {q : Atom} {S : Set Formula} :
    q ∈ atoms_of_set S ↔ ∃ φ ∈ S, q ∈ φ.atoms := Iff.rfl

/-- atoms_of_set is monotone. -/
theorem atoms_of_set_mono {S T : Set Formula} (h : S ⊆ T) :
    atoms_of_set S ⊆ atoms_of_set T := by
  intro q ⟨φ, hφS, hq⟩
  exact ⟨φ, h hφS, hq⟩

/-- An atom is fresh for a set if it doesn't appear in any formula of the set. -/
def fresh_for_set (q : Atom) (S : Set Formula) : Prop :=
  q ∉ atoms_of_set S

/-- Equivalent characterization of fresh_for_set. -/
theorem fresh_for_set_iff {q : Atom} {S : Set Formula} :
    fresh_for_set q S ↔ ∀ φ ∈ S, q ∉ φ.atoms := by
  simp only [fresh_for_set, atoms_of_set, Set.mem_setOf_eq, not_exists, not_and]

/-- If S is a subset of T and q is fresh for T, then q is fresh for S. -/
theorem fresh_for_set_of_subset {q : Atom} {S T : Set Formula} (h : S ⊆ T)
    (hfresh : fresh_for_set q T) : fresh_for_set q S :=
  fun hq => hfresh (atoms_of_set_mono h hq)

/-!
## Fresh Atoms Exist for Countable Sets

For any countable set of formulas, there exist infinitely many fresh atoms.
The key insight is that each formula has finitely many atoms, so a countable
set of formulas has at most countably many atoms. Since Atom is countably
infinite, some atoms must be fresh.
-/

/-- atoms_of_set for a singleton. -/
theorem atoms_of_set_singleton (φ : Formula) :
    atoms_of_set {φ} = (φ.atoms : Set Atom) := by
  ext q
  simp [atoms_of_set, Set.mem_setOf_eq, Set.mem_singleton_iff]

/-- atoms_of_set for a union. -/
theorem atoms_of_set_union (S T : Set Formula) :
    atoms_of_set (S ∪ T) = atoms_of_set S ∪ atoms_of_set T := by
  ext q
  simp only [atoms_of_set, Set.mem_setOf_eq, Set.mem_union]
  constructor
  · intro ⟨φ, hφ, hq⟩
    cases hφ with
    | inl h => exact Or.inl ⟨φ, h, hq⟩
    | inr h => exact Or.inr ⟨φ, h, hq⟩
  · intro h
    rcases h with ⟨φ, hφ, hq⟩ | ⟨φ, hφ, hq⟩
    · exact ⟨φ, Or.inl hφ, hq⟩
    · exact ⟨φ, Or.inr hφ, hq⟩

/-- For any finite set of formulas, there exists a fresh atom. -/
theorem exists_fresh_for_finset (S : Finset Formula) :
    ∃ q : Atom, fresh_for_set q (S : Set Formula) := by
  -- Collect all atoms from S into a finite set
  let all_atoms := S.biUnion (fun φ => φ.atoms)
  obtain ⟨q, hq⟩ := Atom.exists_fresh all_atoms
  use q
  rw [fresh_for_set_iff]
  intro φ hφ h
  apply hq
  exact Finset.mem_biUnion.mpr ⟨φ, hφ, h⟩

/-!
## Reflexive Semantics: ExistsTask Reflexivity

Under reflexive semantics (G/H quantify over s >= t / s <= t), the canonical
accessibility relation is REFLEXIVE: `ExistsTask M M` holds for all MCS M.

Proof: `ExistsTask M M` means `g_content(M) ⊆ M`, i.e., for all phi,
`G(phi) ∈ M → phi ∈ M`. This follows from the T-axiom `G(phi) → phi`
which is derivable under reflexive semantics, and MCS closure under derivation.
-/

/-- ExistsTask is reflexive under reflexive semantics: for any MCS M, `ExistsTask M M`.

Proof: The T-axiom `temp_t_future` gives `G phi → phi` as a derivable theorem.
Since M is an MCS, it is closed under modus ponens with derivable theorems.
Thus `G phi ∈ M → phi ∈ M`, which is exactly `g_content(M) ⊆ M = ExistsTask M M`. -/
theorem existsTask_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ExistsTask M M := by
  intro phi h_G_phi
  -- G(phi) ∈ M and T-axiom gives G(phi) → phi in M
  have h_t_axiom : (Formula.all_future phi |>.imp phi) ∈ M :=
    theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_future phi))
  exact SetMaximalConsistent.implication_property h_mcs h_t_axiom h_G_phi

/-- Backward compatibility alias. -/
abbrev canonicalR_reflexive := existsTask_reflexive

/-- ExistsTask_past is reflexive under reflexive semantics: for any MCS M, `ExistsTask_past M M`.

Proof: The T-axiom `temp_t_past` gives `H phi → phi` as a derivable theorem.
Since M is an MCS, `H phi ∈ M → phi ∈ M`, which is `h_content(M) ⊆ M = ExistsTask_past M M`. -/
theorem existsTask_past_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ExistsTask_past M M := by
  intro phi h_H_phi
  have h_t_axiom : (Formula.all_past phi |>.imp phi) ∈ M :=
    theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_past phi))
  exact SetMaximalConsistent.implication_property h_mcs h_t_axiom h_H_phi

/-- Backward compatibility alias. -/
abbrev canonicalR_past_reflexive := existsTask_past_reflexive

/-!
## Per-Construction Strictness Infrastructure

Under reflexive semantics, ExistsTask is a PREORDER (reflexive + transitive).
Universal irreflexivity is FALSE, and antisymmetry also FAILS.

Instead of proving `¬ExistsTask M M` universally, we prove **per-construction
strictness**: at each call site where a witness W is constructed from M, we
prove `¬ExistsTask W M` from the specific formula that distinguishes W from M.

The key pattern:
1. Construct witness W with some formula φ ∈ W
2. Ensure G(φ) ∈ W (so φ ∈ g_content(W))
3. Show φ ∉ M
4. Then ¬ExistsTask W M (since g_content(W) ⊄ M)

The following infrastructure supports this pattern.
-/

/-- When we have ExistsTask M N (forward accessibility) and explicit proof that
¬ExistsTask N M (backward non-accessibility), we can conclude M < N in the
preorder structure.

This is the core lemma for per-construction strictness: construct the witness,
prove forward accessibility, then prove backward non-accessibility from the
specific formula that distinguishes the witness from the source. -/
theorem lt_of_existsTask_and_not_reverse {M N : Set Formula}
    (h_M_mcs : SetMaximalConsistent M) (h_N_mcs : SetMaximalConsistent N)
    (h_fwd : ExistsTask M N)
    (h_not_bwd : ¬ExistsTask N M) :
    M ≠ N := by
  intro h_eq
  rw [h_eq] at h_not_bwd
  exact h_not_bwd (existsTask_reflexive N h_N_mcs)

/-- Backward compatibility alias. -/
abbrev lt_of_canonicalR_and_not_reverse := @lt_of_existsTask_and_not_reverse

/-- When witness W contains a formula φ in its g_content (i.e., G(φ) ∈ W) that is
NOT in source M, then ¬ExistsTask W M.

This is the workhorse lemma for per-construction strictness. At each call site:
1. Identify the formula φ that distinguishes W from M
2. Show G(φ) ∈ W (so φ ∈ g_content(W))
3. Show φ ∉ M
4. Apply this lemma to get ¬ExistsTask W M -/
theorem strict_of_formula_in_g_content_not_in_source {M W : Set Formula} {φ : Formula}
    (h_φ_in_g_W : φ ∈ g_content W)  -- i.e., G(φ) ∈ W
    (h_φ_not_M : φ ∉ M) :
    ¬ExistsTask W M := by
  intro h_R
  -- h_R : g_content(W) ⊆ M
  have h_φ_in_M : φ ∈ M := h_R h_φ_in_g_W
  exact h_φ_not_M h_φ_in_M

/-- Variant: when φ ∈ W and G(φ) ∈ W (which is typical for witness constructions
that include both φ and G(φ) in the seed), and φ ∉ M, then ¬ExistsTask W M. -/
theorem strict_of_formula_with_G_not_in_source {M W : Set Formula} {φ : Formula}
    (h_Gφ_in_W : Formula.all_future φ ∈ W)  -- G(φ) ∈ W
    (h_φ_not_M : φ ∉ M) :
    ¬ExistsTask W M :=
  strict_of_formula_in_g_content_not_in_source h_Gφ_in_W h_φ_not_M

end

end Bimodal.Metalogic.Bundle
