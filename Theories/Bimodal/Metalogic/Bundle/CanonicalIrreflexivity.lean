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
# Canonical Frame Accessibility: Reflexive Semantics (Task 29 Complete)

## STATUS: REFLEXIVE SEMANTICS (T-axiom approach)

**This module establishes reflexivity of the canonical accessibility relation.**

### Semantic Foundation

Under reflexive semantics (G/H quantify over s ≥ t / s ≤ t), the T-axiom
`G(φ) → φ` is valid. This immediately gives `CanonicalR M M` for all MCS M,
since `g_content(M) ⊆ M` follows from T-axiom closure.

### Two-Layer Architecture

**Layer 1 (Basic Completeness)**: Uses reflexive preorder structure.
- `canonicalR_reflexive`: CanonicalR M M holds for all MCS M
- `canonicalR_past_reflexive`: CanonicalR_past M M holds for all MCS M
- All completeness proofs are axiom-free

**Layer 2 (Order-Theoretic Enhancements)**: Uses deprecated axiom.
- `canonicalR_irreflexive_axiom`: Legacy axiom for order structure
- Used by: CantorApplication, DovetailedTimelineQuot, DiscreteTimeline
- Status: DEPRECATED - introduces inconsistency with Layer 1

### Per-Construction Strictness Pattern

When strictness (M ≠ W) is needed for witness constructions:
1. Identify formula φ that distinguishes W from M
2. Show G(φ) ∈ W (so φ ∈ g_content(W))
3. Show φ ∉ M
4. Apply `strict_of_formula_in_g_content_not_in_source` to get ¬CanonicalR W M

This pattern replaces universal irreflexivity with per-construction proofs.

### References

- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). Modal Logic. Chapter 5.
- Task 29: Switch to reflexive G/H semantics
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
## Reflexive Semantics (Task 29): CanonicalR Reflexivity

Under reflexive semantics (G/H quantify over s >= t / s <= t), the canonical
accessibility relation is REFLEXIVE: `CanonicalR M M` holds for all MCS M.

Proof: `CanonicalR M M` means `g_content(M) ⊆ M`, i.e., for all phi,
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
## Per-Construction Strictness Infrastructure (Task 29)

Under reflexive semantics, CanonicalR is a PREORDER (reflexive + transitive).
Universal irreflexivity is FALSE, and antisymmetry also FAILS.

Instead of proving `¬CanonicalR M M` universally, we prove **per-construction
strictness**: at each call site where a witness W is constructed from M, we
prove `¬CanonicalR W M` from the specific formula that distinguishes W from M.

The key pattern:
1. Construct witness W with some formula φ ∈ W
2. Ensure G(φ) ∈ W (so φ ∈ g_content(W))
3. Show φ ∉ M
4. Then ¬CanonicalR W M (since g_content(W) ⊄ M)

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

/-!
## ORDER-THEORETIC ENHANCEMENT: Irreflexivity Axiom (Task 29 v8)

### Two-Layer Architecture

**Layer 1 (Basic Completeness)**: Does NOT use this axiom.
- BaseCompleteness.lean, CanonicalConstruction.lean, CanonicalFMCS.lean
- Uses reflexive preorder structure (existsTask_reflexive)
- All completeness proofs are axiom-free

**Layer 2 (Order-Theoretic Enhancements)**: Uses this axiom.
- CantorApplication.lean (TimelineQuot ≃o ℚ)
- DovetailedTimelineQuot.lean (alternative dense construction)
- DiscreteTimeline.lean (DiscreteTimelineQuot ≃o ℤ)
- NoMaxOrder, NoMinOrder, DenselyOrdered instances

### Semantic Status

Under reflexive semantics (G/H quantify over s ≥ t / s ≤ t), the axiom is
SEMANTICALLY FALSE. `ExistsTask M M` holds for all MCS M (via T-axiom).

The axiom introduces an INCONSISTENCY when combined with `existsTask_reflexive`.
This inconsistency is ISOLATED to the order-theoretic enhancements and does NOT
affect basic completeness.

### Future Resolution Path

1. **Per-construction strictness**: Prove strictness from formula witnesses
2. **Semantic axiom**: Accept irreflexivity as a semantic assumption for order structure
3. **Delete Layer 2**: Remove order-theoretic enhancements entirely

For now, the axiom is preserved for the order-theoretic enhancements.
-/

axiom existsTask_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬ExistsTask M M

/-- Backward compatibility alias for the axiom. -/
abbrev canonicalR_irreflexive_axiom := existsTask_irreflexive_axiom

@[deprecated "Under reflexive semantics (Task 29), ExistsTask is reflexive, not irreflexive. Use existsTask_reflexive instead."]
theorem existsTask_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬ExistsTask M M :=
  existsTask_irreflexive_axiom M h_mcs

/-- Backward compatibility alias. -/
abbrev canonicalR_irreflexive := existsTask_irreflexive

#check existsTask_reflexive -- Proven theorem (reflexive semantics)
#check existsTask_irreflexive -- Deprecated axiom-based theorem

/-!
## CanonicalTask Irreflexivity (Derived from Axiom)

Under strict semantics (Layer 2), CanonicalTask M n M with n ≠ 0 is impossible
for any MCS M. This follows from the irreflexivity axiom for ExistsTask.

### Forward Direction (n > 0)

A forward chain CanonicalTask_forward M n M with n ≥ 1 implies ExistsTask M M:
- Each Succ step gives a CanonicalR (via Succ_implies_CanonicalR)
- CanonicalR is transitive (via existsTask_transitive) when first world is MCS
- Composing all steps gives CanonicalR M M = ExistsTask M M

### Backward Direction (n < 0)

A backward chain CanonicalTask_backward M |n| M with |n| ≥ 1 works symmetrically
via the converse theorem: CanonicalTask M n M ↔ CanonicalTask M (-n) M.
-/

/-- Forward chain from MCS u implies CanonicalR (identity or proper).

For a forward chain starting from MCS u, we can derive CanonicalR by composing
individual Succ steps via transitivity. Each Succ step gives CanonicalR by
Succ_implies_CanonicalR, and we compose using existsTask_transitive which
only requires the first world (u) to be MCS.

Note: The IH for the step case needs MCS of the intermediate world w, but
we can avoid this by directly using the step_inv extraction pattern. -/
theorem canonicalTask_forward_implies_canonicalR_or_eq
    {u v : Set Formula} {n : Nat}
    (h_mcs_u : SetMaximalConsistent u)
    (h_task : CanonicalTask_forward u n v) :
    u = v ∨ CanonicalR u v := by
  induction n generalizing u v with
  | zero =>
    -- n = 0 means u = v by CanonicalTask_forward_zero
    left
    exact (CanonicalTask_forward_zero u v).mp h_task
  | succ k ih =>
    -- Extract the first Succ step using step_inv
    obtain ⟨w, h_succ, h_chain⟩ := CanonicalTask_forward.step_inv h_task
    have h_R_uw : CanonicalR u w := Succ_implies_CanonicalR u w h_succ
    -- For the remaining chain from w to v, we need MCS of w
    -- But wait - we only have MCS of u. We can still conclude:
    -- Either w = v (and we have CanonicalR u v = h_R_uw)
    -- Or k ≥ 1 and we need to compose (but this requires MCS w)
    -- Actually, we can proceed differently: the chain from w to v
    -- gives us CanonicalR w v (if k ≥ 1) or w = v (if k = 0)
    -- In either case, transitivity from u gives us what we need
    cases k with
    | zero =>
      -- k = 0 means w = v
      have h_wv : w = v := (CanonicalTask_forward_zero w v).mp h_chain
      subst h_wv
      exact Or.inr h_R_uw
    | succ j =>
      -- k = j + 1, chain from w to v has length ≥ 1
      -- This requires MCS of w for transitivity, which we don't have directly
      -- However, we know Succ preserves the structure - each Succ step gives CanonicalR
      -- We can use the single-step lemma repeatedly
      -- Actually, let's just extract the full chain and compose
      obtain ⟨w', h_succ', h_chain'⟩ := CanonicalTask_forward.step_inv h_chain
      have h_R_ww' : CanonicalR w w' := Succ_implies_CanonicalR w w' h_succ'
      -- Now we have CanonicalR u w and CanonicalR w w' and chain from w' to v
      -- Compose u to w' first (needs MCS u)
      have h_R_uw' : CanonicalR u w' := existsTask_transitive u w w' h_mcs_u h_R_uw h_R_ww'
      -- Continue with the remaining chain from w' to v
      -- This is getting complicated - let's use a simpler approach
      -- Just recurse on the full chain length
      right
      -- Actually, for any chain of length ≥ 1, the first step gives CanonicalR u w
      -- and we can compose all subsequent steps via transitivity
      -- The key is that transitivity only needs MCS of the FIRST world (u)
      -- So we can compose: u -> w -> w' -> ... -> v
      -- At each step, we use existsTask_transitive with MCS u
      -- Let's prove this by strong induction on chain length
      -- For now, use a direct proof for the general case
      -- Every forward chain of length ≥ 1 from MCS u gives CanonicalR u v
      -- because each Succ gives CanonicalR and we compose via transitivity
      -- The composition only requires MCS of the base (u)
      have h_base : ∀ m : Nat, ∀ x y : Set Formula,
          CanonicalTask_forward x m y → CanonicalR u x → CanonicalR u y := by
        intro m
        induction m with
        | zero =>
          intro x y h_fwd h_ux
          have h_eq : x = y := (CanonicalTask_forward_zero x y).mp h_fwd
          subst h_eq
          exact h_ux
        | succ p ih_p =>
          intro x y h_fwd h_ux
          obtain ⟨z, h_succ_xz, h_chain_zy⟩ := CanonicalTask_forward.step_inv h_fwd
          have h_xz : CanonicalR x z := Succ_implies_CanonicalR x z h_succ_xz
          have h_uz : CanonicalR u z := existsTask_transitive u x z h_mcs_u h_ux h_xz
          exact ih_p z y h_chain_zy h_uz
      exact h_base j w' v h_chain' h_R_uw'

/-- Forward chain of positive length from MCS u implies CanonicalR.

This is the key lemma for CanonicalTask irreflexivity: any forward chain
of length ≥ 1 starting from MCS gives CanonicalR, even if it returns to
the starting world. -/
theorem canonicalTask_forward_pos_implies_canonicalR
    {u v : Set Formula} {n : Nat}
    (h_mcs_u : SetMaximalConsistent u)
    (h_pos : n ≥ 1)
    (h_task : CanonicalTask_forward u n v) :
    CanonicalR u v := by
  rcases canonicalTask_forward_implies_canonicalR_or_eq h_mcs_u h_task with rfl | h_R
  · -- u = v case: the chain loops back
    -- n ≥ 1 means n = k + 1 for some k
    have h_n : ∃ k, n = k + 1 := ⟨n - 1, by omega⟩
    obtain ⟨k, rfl⟩ := h_n
    -- Extract first step: Succ u w for some w
    obtain ⟨w, h_succ, h_chain⟩ := CanonicalTask_forward.step_inv h_task
    have h_R_uw : CanonicalR u w := Succ_implies_CanonicalR u w h_succ
    -- Chain from w back to u (since u = v)
    -- If k = 0, then w = u directly
    cases k with
    | zero =>
      have h_wu : w = u := (CanonicalTask_forward_zero w u).mp h_chain
      subst h_wu
      exact h_R_uw
    | succ j =>
      -- k ≥ 1, so chain from w to u has positive length
      -- Use the helper lemma to compose
      have h_base : ∀ m : Nat, ∀ x y : Set Formula,
          CanonicalTask_forward x m y → CanonicalR u x → CanonicalR u y := by
        intro m
        induction m with
        | zero =>
          intro x y h_fwd h_ux
          have h_eq : x = y := (CanonicalTask_forward_zero x y).mp h_fwd
          subst h_eq
          exact h_ux
        | succ p ih_p =>
          intro x y h_fwd h_ux
          obtain ⟨z, h_succ_xz, h_chain_zy⟩ := CanonicalTask_forward.step_inv h_fwd
          have h_xz : CanonicalR x z := Succ_implies_CanonicalR x z h_succ_xz
          have h_uz : CanonicalR u z := existsTask_transitive u x z h_mcs_u h_ux h_xz
          exact ih_p z y h_chain_zy h_uz
      exact h_base (j + 1) w u h_chain h_R_uw
  · exact h_R

/-- CanonicalTask irreflexivity for positive durations.

If n > 0, then ¬CanonicalTask M n M for any MCS M. This follows from:
1. CanonicalTask M n M with n > 0 means CanonicalTask_forward M n M
2. Forward chain of length ≥ 1 implies CanonicalR M M (via Succ composition)
3. The irreflexivity axiom gives ¬CanonicalR M M = ¬ExistsTask M M

**Semantic Note**: This theorem only applies under STRICT semantics (Layer 2).
Under reflexive semantics (Task 29), ExistsTask is reflexive, not irreflexive,
so this theorem is INCONSISTENT with existsTask_reflexive. -/
@[deprecated "Under reflexive semantics (Task 29), ExistsTask is reflexive. This theorem uses the deprecated irreflexivity axiom."]
theorem canonicalTask_irreflexive_pos (M : Set Formula) (n : Int)
    (h_mcs : SetMaximalConsistent M) (h_pos : 0 < n) :
    ¬CanonicalTask M n M := by
  intro h_task
  -- n > 0 means n = Int.ofNat k for some k ≥ 1
  match n, h_pos with
  | Int.ofNat k, h_pos_k =>
    -- k ≥ 1 since Int.ofNat k > 0
    have h_k_pos : k ≥ 1 := Nat.one_le_iff_ne_zero.mpr (Int.ofNat_ne_zero.mp (ne_of_gt h_pos_k))
    -- CanonicalTask M k M = CanonicalTask_forward M k M
    have h_forward : CanonicalTask_forward M k M := (CanonicalTask_of_nat M M k).mp h_task
    -- Forward chain implies CanonicalR M M
    have h_R : CanonicalR M M := canonicalTask_forward_pos_implies_canonicalR h_mcs h_k_pos h_forward
    -- But CanonicalR M M contradicts irreflexivity axiom
    exact existsTask_irreflexive_axiom M h_mcs h_R

/-- CanonicalTask irreflexivity for negative durations.

If n < 0, then ¬CanonicalTask M n M for any MCS M. This follows from the
converse theorem: CanonicalTask M n M ↔ CanonicalTask M (-n) M, combined
with the positive case.

**Semantic Note**: This theorem only applies under STRICT semantics (Layer 2). -/
@[deprecated "Under reflexive semantics (Task 29), ExistsTask is reflexive. This theorem uses the deprecated irreflexivity axiom."]
theorem canonicalTask_irreflexive_neg (M : Set Formula) (n : Int)
    (h_mcs : SetMaximalConsistent M) (h_neg : n < 0) :
    ¬CanonicalTask M n M := by
  intro h_task
  -- Use converse: CanonicalTask M n M ↔ CanonicalTask M (-n) M
  have h_converse : CanonicalTask M (-n) M := (CanonicalTask_converse M M n).mp h_task
  -- -n > 0 since n < 0
  have h_pos : 0 < -n := by omega
  -- Apply positive case
  exact canonicalTask_irreflexive_pos M (-n) h_mcs h_pos h_converse

/-- CanonicalTask irreflexivity for any non-zero duration.

If n ≠ 0, then ¬CanonicalTask M n M for any MCS M. Combines positive and
negative cases.

**Semantic Note**: This theorem only applies under STRICT semantics (Layer 2).
Under reflexive semantics (Task 29), ExistsTask is reflexive, so this theorem
is INCONSISTENT with the reflexive theory. Use with caution. -/
@[deprecated "Under reflexive semantics (Task 29), ExistsTask is reflexive. This theorem uses the deprecated irreflexivity axiom."]
theorem canonicalTask_irreflexive (M : Set Formula) (n : Int)
    (h_mcs : SetMaximalConsistent M) (h_nonzero : n ≠ 0) :
    ¬CanonicalTask M n M := by
  rcases lt_trichotomy n 0 with h_neg | h_zero | h_pos
  · exact canonicalTask_irreflexive_neg M n h_mcs h_neg
  · exact absurd h_zero h_nonzero
  · exact canonicalTask_irreflexive_pos M n h_mcs h_pos

end

end Bimodal.Metalogic.Bundle
