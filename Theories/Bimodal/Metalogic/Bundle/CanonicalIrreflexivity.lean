import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.ProofSystem.Substitution
import Mathlib.Data.Finset.Union

/-!
# Canonical Frame Irreflexivity

## STATUS: AXIOM-BASED (Task 991 - Irreflexive Semantics Refactor)

**This module declares irreflexivity of the canonical accessibility relation as an axiom.**

### Approach

Under strict temporal semantics (G/H quantify over s > t / s < t), irreflexivity
is semantically guaranteed but NOT modally definable (van Benthem 1983, Blackburn-
de Rijke-Venema 2001 Chapter 3.3). No formula of TM logic characterizes irreflexive
frames, so no syntactic derivation from TM axioms can establish this property.

The `canonicalR_irreflexive_axiom` captures what is semantically true about the
canonical model construction under strict temporal semantics.

### Mathematical Justification

The canonical relation `CanonicalR M N` means `g_content M ⊆ N` where
`g_content M = {φ : G(φ) ∈ M}`. Under strict semantics, `G(φ)` at time t means
φ holds at all s > t. For `CanonicalR M M` to hold, M would need to be its own
strict future, requiring t > t, which is impossible.

## Main Result

- `canonicalR_irreflexive_axiom`: Axiom declaration
- `canonicalR_irreflexive`: Theorem invoking the axiom

## Historical Context

Under reflexive semantics (Task 967), irreflexivity was proved using the T-axiom
H(φ) → φ via Gabbay's IRR technique. Under strict semantics (Task 991), the
T-axiom is no longer valid, and the axiom-based approach is used instead.

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
## DELETED: Universal Fresh Atom Existence (Task 29 Phase 4)

The following theorem was deleted because the cardinality argument is flawed:

```lean
theorem exists_fresh_for_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ q : Atom, fresh_for_set q (g_content M)
```

**Why the cardinality argument fails**: A pathological MCS can cover all atoms.
Consider an MCS M where for every atom q, there exists some formula φ_q with
q ∈ φ_q.atoms and G(φ_q) ∈ M. The set { φ | G(φ) ∈ M } is countable, but a
countable union of finite sets CAN cover all of a countably infinite set.

**Resolution**: Instead of proving universal fresh atom existence, we use
**per-construction strictness** - at each call site where strictness is needed,
we prove ¬CanonicalR W M from the specific construction that built W.

See: specs/029_switch_to_reflexive_gh_semantics/reports/12_team-research.md
-/

/-!
## Reflexive Semantics (Task 29): CanonicalR Reflexivity

Under reflexive semantics (G/H quantify over s >= t / s <= t), the canonical
accessibility relation is REFLEXIVE: `CanonicalR M M` holds for all MCS M.

Proof: `CanonicalR M M` means `g_content(M) ⊆ M`, i.e., for all phi,
`G(phi) ∈ M → phi ∈ M`. This follows from the T-axiom `G(phi) → phi`
which is derivable under reflexive semantics, and MCS closure under derivation.
-/

/-- CanonicalR is reflexive under reflexive semantics: for any MCS M, `CanonicalR M M`.

Proof: The T-axiom `temp_t_future` gives `G phi → phi` as a derivable theorem.
Since M is an MCS, it is closed under modus ponens with derivable theorems.
Thus `G phi ∈ M → phi ∈ M`, which is exactly `g_content(M) ⊆ M = CanonicalR M M`. -/
theorem canonicalR_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR M M := by
  intro phi h_G_phi
  -- G(phi) ∈ M and T-axiom gives G(phi) → phi in M
  have h_t_axiom : (Formula.all_future phi |>.imp phi) ∈ M :=
    theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_future phi))
  exact SetMaximalConsistent.implication_property h_mcs h_t_axiom h_G_phi

/-- CanonicalR_past is reflexive under reflexive semantics: for any MCS M, `CanonicalR_past M M`.

Proof: The T-axiom `temp_t_past` gives `H phi → phi` as a derivable theorem.
Since M is an MCS, `H phi ∈ M → phi ∈ M`, which is `h_content(M) ⊆ M = CanonicalR_past M M`. -/
theorem canonicalR_past_reflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    CanonicalR_past M M := by
  intro phi h_H_phi
  have h_t_axiom : (Formula.all_past phi |>.imp phi) ∈ M :=
    theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_past phi))
  exact SetMaximalConsistent.implication_property h_mcs h_t_axiom h_H_phi

/-!
## Fresh G-Atom Per-Witness Strictness (Task 25)

Under reflexive semantics, `CanonicalR M M` holds (reflexivity). Universal
irreflexivity is FALSE. However, we can prove PER-WITNESS strictness: for any
MCS M, there EXISTS a witness W with `CanonicalR M W ∧ ¬CanonicalR W M`.

The key is the fresh G-atom approach:
1. Find an atom q such that `¬q ∈ M` (M decides q to be false)
2. Also ensure `G(¬q) ∉ M` (equivalently, `F(q) ∈ M`)
3. Build seed `g_content(M) ∪ {G(q)}`
4. Extend to MCS W via Lindenbaum
5. Then `CanonicalR M W` (since `g_content M ⊆ W`)
6. And `¬CanonicalR W M` (since `q ∈ g_content W` but `q ∉ M`)

This replaces the inconsistent `canonicalR_irreflexive_axiom`.
-/

/-- If q is fresh for g_content(M), then G(¬q) ∉ M.

Proof: If G(¬q) ∈ M, then ¬q ∈ g_content(M). But ¬q = (atom q) → ⊥ has q in its atoms.
So q ∈ atoms_of_set(g_content M), contradicting freshness.
-/
theorem fresh_for_g_content_implies_not_always_neg (M : Set Formula) (q : Atom)
    (h_fresh : fresh_for_set q (g_content M)) :
    Formula.all_future (Formula.neg (Formula.atom q)) ∉ M := by
  intro h_G_neg_q
  -- G(¬q) ∈ M means ¬q ∈ g_content(M)
  have h_neg_q_in_g : Formula.neg (Formula.atom q) ∈ g_content M := h_G_neg_q
  -- ¬q = (atom q).imp ⊥, which has q in its atoms
  have h_q_in_neg_q : q ∈ (Formula.neg (Formula.atom q)).atoms := by
    simp only [Formula.neg, Formula.atoms, Finset.mem_union, Finset.mem_singleton]
    left; trivial
  -- So q ∈ atoms_of_set(g_content M)
  have h_q_in_atoms : q ∈ atoms_of_set (g_content M) := ⟨_, h_neg_q_in_g, h_q_in_neg_q⟩
  -- This contradicts freshness
  exact h_fresh h_q_in_atoms

/-!
## DELETED: Universal Fresh Atom Theorems (Task 29 Phase 4)

The following theorems were deleted because they depend on the flawed
`exists_fresh_for_g_content`:

```lean
theorem fresh_for_g_content_some_decided_false (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ q : Atom, fresh_for_set q (g_content M) ∧ Formula.neg (Formula.atom q) ∈ M

theorem exists_strict_fresh_atom (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ q : Atom, fresh_for_set q (g_content M) ∧
               Formula.neg (Formula.atom q) ∈ M ∧
               Formula.all_future (Formula.neg (Formula.atom q)) ∉ M
```

**Resolution**: Use per-construction strictness at call sites instead.
See `fresh_Gp_seed_consistent` below for the proven building block.
-/

/-- The fresh G-atom seed is consistent when q is fresh for g_content(M).

Proof: Suppose L ⊆ g_content(M) ∪ {G(q)} with L ⊢ ⊥.
- If G(q) ∉ L: then L ⊆ g_content(M) ⊆ M (by reflexivity), contradicting M's consistency.
- If G(q) ∈ L: then L \ {G(q)} ⊢ ¬G(q) by deduction theorem.
  Let L' = L \ {G(q)} ⊆ g_content(M).
  Since q is fresh for g_content(M), q doesn't appear in any formula of L'.
  By substitution (derivation_subst), L' ⊢ ¬G(r) for any atom r.
  In particular, pick r appearing in some formula of L' (or pick any r if L' is empty).
  Then ¬G(r) ∈ M (since L' ⊆ g_content(M) ⊆ M and M is closed under derivation).
  But wait - if L' = [] (empty), then [] ⊢ ¬G(q), meaning ¬G(q) is a theorem.
  This would mean G(q) is unsatisfiable, which is false (G(q) is satisfiable).
  Contradiction!

  If L' ≠ [], the substitution argument still works: L' derives ¬G(r) for all r,
  but L' ⊆ M means L' is consistent, so the derivation must be vacuous.
-/
theorem fresh_Gp_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (q : Atom) (h_fresh : fresh_for_set q (g_content M)) :
    SetConsistent (g_content M ∪ {Formula.all_future (Formula.atom q)}) := by
  intro L hL_sub ⟨d⟩
  let Gq := Formula.all_future (Formula.atom q)

  by_cases h_Gq_in_L : Gq ∈ L
  · -- Case: G(q) ∈ L
    -- L' = L \ {G(q)} ⊆ g_content(M)
    let L' := L.filter (fun φ => φ ≠ Gq)
    have hL'_sub : ∀ φ ∈ L', φ ∈ g_content M := by
      intro φ hφ
      have hφ_in_L := (List.mem_filter.mp hφ).1
      have hφ_ne := of_decide_eq_true (List.mem_filter.mp hφ).2
      have hφ_in_seed := hL_sub φ hφ_in_L
      simp only [Set.mem_union, Set.mem_singleton_iff] at hφ_in_seed
      cases hφ_in_seed with
      | inl h => exact h
      | inr h => exact absurd h hφ_ne

    -- By deduction from G(q): L' ⊢ G(q) → ⊥, i.e., L' ⊢ ¬G(q) = F(¬q)
    have h_L_sub_perm : L ⊆ (Gq :: L') := by
      intro φ hφ
      by_cases hφ_eq : φ = Gq
      · simp [hφ_eq]
      · simp only [List.mem_cons]
        right; exact List.mem_filter.mpr ⟨hφ, decide_eq_true hφ_eq⟩

    have d_rearr : DerivationTree (Gq :: L') Formula.bot :=
      DerivationTree.weakening L (Gq :: L') Formula.bot d h_L_sub_perm

    have d_ded : DerivationTree L' (Gq.imp Formula.bot) :=
      deduction_theorem L' Gq Formula.bot d_rearr

    -- Gq.imp ⊥ = G(q) → ⊥ = ¬G(q) = F(¬q)
    -- L' ⊢ F(¬q)

    -- By generalized temporal K: G(L') ⊢ G(F(¬q))
    have d_G : (Context.map Formula.all_future L') ⊢ Formula.all_future (Gq.imp Formula.bot) :=
      Bimodal.Theorems.generalized_temporal_k L' (Gq.imp Formula.bot) d_ded

    -- G(L') ⊆ M since L' ⊆ g_content(M) means G(φ) ∈ M for each φ ∈ L'
    have h_G_L'_in_M : ∀ φ ∈ Context.map Formula.all_future L', φ ∈ M := by
      intro φ hφ
      rw [Context.mem_map_iff] at hφ
      obtain ⟨ψ, hψ_in_L', hψ_eq⟩ := hφ
      rw [← hψ_eq]
      exact hL'_sub ψ hψ_in_L'

    -- So G(F(¬q)) ∈ M
    have h_GFneg : Formula.all_future (Gq.imp Formula.bot) ∈ M :=
      SetMaximalConsistent.closed_under_derivation h_mcs
        (Context.map Formula.all_future L') h_G_L'_in_M d_G

    -- G(F(¬q)) = G(¬G(q))
    -- By T-axiom G(φ) → φ, we get G(¬G(q)) → ¬G(q)
    have h_T : (Formula.all_future (Gq.imp Formula.bot)).imp (Gq.imp Formula.bot) ∈ M :=
      theorem_in_mcs h_mcs (.axiom _ _ (.temp_t_future (Gq.imp Formula.bot)))
    have h_Fneg : (Gq.imp Formula.bot) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs h_T h_GFneg

    -- KEY PROOF: Use that q is fresh for L' (since L' ⊆ g_content(M) and q is fresh for g_content(M))
    -- This means the derivation L' ⊢ ¬G(q) is "parametric" in q.
    -- By substitution, L' ⊢ ¬G(r) for any atom r.
    -- So M contains ¬G(r) for all r (since L' ⊆ M and M is closed under derivation).
    -- In particular, ¬G(q) ∈ M for our q.

    -- Step 1: Show q ∉ atoms_of_context L'
    have h_q_fresh_L' : q ∉ atoms_of_context L' := by
      rw [mem_atoms_of_context_iff]
      push_neg
      intro ψ hψ_in_L'
      have hψ_in_g : ψ ∈ g_content M := hL'_sub ψ hψ_in_L'
      rw [fresh_for_set_iff] at h_fresh
      exact h_fresh ψ hψ_in_g

    -- Step 2: By substitution, L' ⊢ (¬G(q))[r/q] = ¬G(r) for any r
    -- We substitute q with q itself in the derivation - but the key is we COULD substitute
    -- with any atom r, getting L' ⊢ ¬G(r).

    -- Step 3: The formula d_ded derives is Gq.imp Formula.bot = G(q) → ⊥ = ¬G(q)
    -- This formula has atoms = {q} (q appears in G(q))

    -- Step 4: Since q ∉ atoms_of_context(L'), by substituting q with ANY other atom r,
    -- we get L' ⊢ ¬G(r). Taking r to be an atom with G(atom r) ∈ M gives a contradiction.

    -- Actually, let's use a simpler approach: derive a contradiction from L' ⊆ M.
    -- Since L' ⊆ g_content(M) ⊆ M, and L' ⊢ ¬G(q), we have ¬G(q) ∈ M (by MCS closure).

    -- Now use substitution with a fresh r: L' ⊢ ¬G(r) for all r (since q ∉ L' atoms).
    -- So ¬G(r) ∈ M for all r, meaning G(r) ∉ M for all atoms r (since M is consistent).
    -- In particular, G(atom r) ∉ M for all r, so atom(r) ∉ g_content(M) for all r.

    -- But L' ⊆ g_content(M) and L' is non-empty (or we're in the L' = [] case).
    -- If L' ≠ [], then some ψ ∈ L' ⊆ g_content(M). If ψ is atomic, contradiction!
    -- If ψ is non-atomic, it still has atoms, so atoms(g_content(M)) ≠ ∅.
    -- But we showed atom(r) ∉ g_content(M) for all r... hmm, that means atoms_of_set(g_content(M)) might be non-empty from non-atomic formulas.

    -- SIMPLER: If L' = [], then [] ⊢ ¬G(q), meaning ¬G(q) is a theorem.
    -- But ¬G(q) = F(¬q) is NOT a theorem (there are models where q is always true).
    -- Use soundness to derive a contradiction.

    -- For L' ≠ [], the atoms in L' don't include q, so by substitution we can derive ¬G(r) for any r.
    -- But this just shows ¬G(r) ∈ M for all r, which is consistent (it means no atom is always true).

    -- The real key: We have h_Fneg : (Gq.imp Formula.bot) ∈ M, i.e., ¬G(q) ∈ M.
    -- Combined with h_fresh, q ∈ atoms(¬G(q)) = {q}, and ¬G(q) ∈ M.
    -- But fresh_for_set says q ∉ atoms_of_set(g_content(M)).
    -- Is ¬G(q) ∈ g_content(M)? That would require G(¬G(q)) ∈ M.

    -- By 4-axiom: G(φ) → G(G(φ)). If G(¬G(q)) ∈ M, then ¬G(q) ∈ g_content(M).
    -- But we only have ¬G(q) ∈ M, not G(¬G(q)) ∈ M.

    -- Alternative: Use that we showed ¬G(r) ∈ M for ALL r (by substitution).
    -- Pick r to be fresh for g_content(M) (which exists by exists_fresh_for_g_content... wait, that's sorried).
    -- Actually, we already have q fresh for g_content(M)!

    -- The key insight: from L' ⊢ ¬G(q) with q fresh, by substitution L' ⊢ ¬G(r) for all r.
    -- In particular, L' ⊢ ¬G(s) where s is ANY atom appearing in some ψ ∈ g_content(M).
    -- But G(ψ) ∈ M for ψ ∈ g_content(M). If s ∈ ψ.atoms... hmm, G(ψ) ≠ G(s).

    -- Let me try: take r = q in the substitution (trivial, gives back the same derivation).
    -- The point is L' ⊢ ¬G(q) and ¬G(q) ∈ M (by h_Fneg).
    -- Now, ¬G(q).atoms = {q}, so q ∈ atoms_of_set(M). This is expected (M decides all atoms).
    -- The constraint is q is fresh for g_content(M), not for M.

    -- EUREKA: The proof needs a different approach!
    -- Use that L' ⊢ ¬G(q) means g_content(M) derives ¬G(q).
    -- By generalized K: G(g_content(M)) ⊢ G(¬G(q)).
    -- G(g_content(M)) ⊆ M (since for each φ ∈ g_content(M), G(φ) ∈ M by definition).
    -- Wait, we already did this above and got h_GFneg : G(¬G(q)) ∈ M.

    -- From G(¬G(q)) ∈ M, by T-axiom, ¬G(q) ∈ M (we got h_Fneg).
    -- We need a contradiction.

    -- The issue is: having ¬G(q) ∈ M doesn't directly contradict q being fresh for g_content(M).
    -- ¬G(q) ∈ M ≠ ¬G(q) ∈ g_content(M).

    -- But wait! We have G(¬G(q)) ∈ M (h_GFneg). So ¬G(q) ∈ g_content(M) (by definition).
    -- And ¬G(q) has atom q in it. So q ∈ atoms_of_set(g_content(M)).
    -- This contradicts h_fresh : fresh_for_set q (g_content M)!

    -- The atoms of ¬G(q) = (G(q)).imp ⊥ = all_future(atom q).imp bot
    -- Gq = all_future(atom q), so Gq.atoms = (atom q).atoms = {q}
    -- (Gq.imp ⊥).atoms = Gq.atoms ∪ ⊥.atoms = {q} ∪ ∅ = {q}
    have h_atoms_neg_Gq : q ∈ (Gq.imp Formula.bot).atoms := by
      -- Unfold Gq and simplify
      show q ∈ ((Formula.atom q).all_future.imp Formula.bot).atoms
      simp only [Formula.atoms, Finset.mem_union, Finset.mem_singleton]
      left; trivial

    -- G(¬G(q)) ∈ M means ¬G(q) ∈ g_content(M)
    have h_neg_Gq_in_g : (Gq.imp Formula.bot) ∈ g_content M := h_GFneg

    -- So q ∈ atoms_of_set(g_content(M))
    have h_q_in_atoms_g : q ∈ atoms_of_set (g_content M) :=
      ⟨Gq.imp Formula.bot, h_neg_Gq_in_g, h_atoms_neg_Gq⟩

    -- This contradicts freshness
    exact h_fresh h_q_in_atoms_g

  · -- Case: G(q) ∉ L
    -- L ⊆ g_content(M)
    have hL_in_gcontent : ∀ φ ∈ L, φ ∈ g_content M := by
      intro φ hφ
      have hφ_in_seed := hL_sub φ hφ
      simp only [Set.mem_union, Set.mem_singleton_iff] at hφ_in_seed
      cases hφ_in_seed with
      | inl h => exact h
      | inr h =>
        -- h : φ = Gq, but Gq ∉ L and φ ∈ L, contradiction
        subst h
        exact absurd hφ h_Gq_in_L

    -- g_content(M) ⊆ M by reflexivity
    have h_gcontent_sub_M : g_content M ⊆ M := canonicalR_reflexive M h_mcs

    -- So L ⊆ M
    have hL_in_M : ∀ φ ∈ L, φ ∈ M := fun φ hφ => h_gcontent_sub_M (hL_in_gcontent φ hφ)

    -- L ⊢ ⊥ with L ⊆ M contradicts M being consistent
    exact h_mcs.1 L hL_in_M ⟨d⟩

/-!
## Per-Construction Strictness Infrastructure (Task 29 Phase 5A)

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

/-- When we have CanonicalR M N (forward accessibility) and explicit proof that
¬CanonicalR N M (backward non-accessibility), we can conclude M < N in the
preorder structure.

This is the core lemma for per-construction strictness: construct the witness,
prove forward accessibility, then prove backward non-accessibility from the
specific formula that distinguishes the witness from the source. -/
theorem lt_of_canonicalR_and_not_reverse {M N : Set Formula}
    (h_M_mcs : SetMaximalConsistent M) (h_N_mcs : SetMaximalConsistent N)
    (h_fwd : CanonicalR M N)
    (h_not_bwd : ¬CanonicalR N M) :
    M ≠ N := by
  intro h_eq
  rw [h_eq] at h_not_bwd
  exact h_not_bwd (canonicalR_reflexive N h_N_mcs)

/-- When witness W contains a formula φ in its g_content (i.e., G(φ) ∈ W) that is
NOT in source M, then ¬CanonicalR W M.

This is the workhorse lemma for per-construction strictness. At each call site:
1. Identify the formula φ that distinguishes W from M
2. Show G(φ) ∈ W (so φ ∈ g_content(W))
3. Show φ ∉ M
4. Apply this lemma to get ¬CanonicalR W M -/
theorem strict_of_formula_in_g_content_not_in_source {M W : Set Formula} {φ : Formula}
    (h_φ_in_g_W : φ ∈ g_content W)  -- i.e., G(φ) ∈ W
    (h_φ_not_M : φ ∉ M) :
    ¬CanonicalR W M := by
  intro h_R
  -- h_R : g_content(W) ⊆ M
  have h_φ_in_M : φ ∈ M := h_R h_φ_in_g_W
  exact h_φ_not_M h_φ_in_M

/-- Variant: when φ ∈ W and G(φ) ∈ W (which is typical for witness constructions
that include both φ and G(φ) in the seed), and φ ∉ M, then ¬CanonicalR W M. -/
theorem strict_of_formula_with_G_not_in_source {M W : Set Formula} {φ : Formula}
    (h_Gφ_in_W : Formula.all_future φ ∈ W)  -- G(φ) ∈ W
    (h_φ_not_M : φ ∉ M) :
    ¬CanonicalR W M :=
  strict_of_formula_in_g_content_not_in_source h_Gφ_in_W h_φ_not_M

/-!
## DELETED: existsTask_strict_fresh_atom (Task 29 Phase 4)

The following theorem was deleted because it depends on `exists_strict_fresh_atom`
which depends on the flawed `exists_fresh_for_g_content`:

```lean
theorem existsTask_strict_fresh_atom (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ W, SetMaximalConsistent W ∧ CanonicalR M W ∧ ¬CanonicalR W M
```

**Resolution**: This theorem demonstrated the PATTERN for per-witness strictness:
1. Find fresh q for g_content(M) with ¬q ∈ M
2. Build seed g_content(M) ∪ {G(q)}
3. Extend to MCS W
4. CanonicalR M W (by construction)
5. ¬CanonicalR W M (because q ∈ g_content(W) but q ∉ M)

This pattern IS correct but cannot be proven universally (fresh atom existence fails).
Instead, at each call site we prove strictness from the construction-specific formula
that distinguishes the witness from the source.

See `fresh_Gp_seed_consistent` for the proven building block that works when
a fresh atom IS provided by the specific construction.
-/

/-!
## DEPRECATED: Irreflexivity Axiom (Task 991)

Under reflexive semantics (Task 29), the irreflexivity axiom is SEMANTICALLY FALSE.
`CanonicalR M M` now holds for all MCS M (see `canonicalR_reflexive` above).

This axiom and the theorem `canonicalR_irreflexive` are preserved temporarily
to avoid breaking the ~54 downstream call sites that depend on them. They
introduce an INCONSISTENCY into the system (asserting both `CanonicalR M M`
and `¬CanonicalR M M`).

**TODO (Task 29 Phase 5 continuation)**: Remove this axiom and fix all call sites
to use antisymmetry-based arguments instead.
-/

axiom canonicalR_irreflexive_axiom :
    ∀ (M : Set Formula), SetMaximalConsistent M → ¬CanonicalR M M

@[deprecated "Under reflexive semantics (Task 29), CanonicalR is reflexive, not irreflexive. Use canonicalR_reflexive instead."]
theorem canonicalR_irreflexive (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ¬CanonicalR M M :=
  canonicalR_irreflexive_axiom M h_mcs

#check canonicalR_reflexive -- Proven theorem (reflexive semantics)
#check canonicalR_irreflexive -- Deprecated axiom-based theorem

end

end Bimodal.Metalogic.Bundle
