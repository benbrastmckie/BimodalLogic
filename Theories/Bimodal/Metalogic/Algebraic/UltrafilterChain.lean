import Bimodal.Metalogic.Algebraic.TenseS5Algebra
import Bimodal.Metalogic.Algebraic.UltrafilterMCS
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Theorems.Perpetuity

/-!
# Ultrafilter Chain Construction

This module implements the Jonsson-Tarski ultrafilter chain construction for
building temporally coherent BFMCS from ultrafilters of the Lindenbaum algebra.

## Key Insight

Ultrafilters have **full negation completeness** by definition: for any element a,
exactly one of a or aᶜ is in the ultrafilter. This eliminates the boundary problems
that plague restricted MCS constructions like the SuccChain approach.

## Main Definitions

- `R_G`: Temporal accessibility on ultrafilters (G-preimage containment)
- `R_Box`: Modal accessibility on ultrafilters (Box-preimage containment)
- `UltrafilterChain`: Int-indexed chain of ultrafilters with R_G connectivity

## References

- Jonsson-Tarski (1951-52): Boolean algebras with operators
- Team research report 33_team-research.md
-/

namespace Bimodal.Metalogic.Algebraic.UltrafilterChain

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure
open Bimodal.Metalogic.Algebraic.InteriorOperators
open Bimodal.Metalogic.Algebraic.TenseS5Algebra
open Bimodal.Metalogic.Algebraic.UltrafilterMCS
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle

/-!
## Phase 1: Temporal Accessibility Relations

Define R_G and R_Box on ultrafilters of LindenbaumAlg with basic properties.
-/

/--
Temporal accessibility relation R_G on ultrafilters.

R_G(U, V) holds iff for all a, G(a) ∈ U implies a ∈ V.
This is the preimage containment: V contains all elements whose G is in U.
-/
def R_G (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.G a ∈ U → a ∈ V

/--
Modal accessibility relation R_Box on ultrafilters.

R_Box(U, V) holds iff for all a, □a ∈ U implies a ∈ V.
-/
def R_Box (U V : Ultrafilter LindenbaumAlg) : Prop :=
  ∀ a : LindenbaumAlg, STSA.box a ∈ U → a ∈ V

/-!
### R_G Properties
-/

/--
R_G is reflexive: every ultrafilter is R_G-related to itself.

Proof: From temp_t_future, we have G(a) ≤ a. Since G(a) ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_G_refl (U : Ultrafilter LindenbaumAlg) : R_G U U := by
  intro a h_Ga_in
  -- G_quot a ≤ a by temp_t_future
  have h_le : STSA.G a ≤ a := by
    -- Use the STSA instance
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ toQuot φ
      show Derives φ.all_future φ
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩
  exact U.mem_of_le h_Ga_in h_le

/--
R_G is transitive: R_G(U, V) and R_G(V, W) imply R_G(U, W).

Proof: If G(a) ∈ U and R_G(U, V), then we need a ∈ W.
From temp_4_future: G(a) ≤ G(G(a)), so G(G(a)) ∈ U.
By R_G(U, V): G(a) ∈ V.
By R_G(V, W): a ∈ W.
-/
theorem R_G_trans {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_G U V) (h_VW : R_G V W) : R_G U W := by
  intro a h_Ga_in
  -- Need G(G(a)) ∈ U to apply h_UV and get G(a) ∈ V
  -- From temp_4_future: G(a) → G(G(a)), i.e., G(a) ≤ G(G(a))
  have h_le : STSA.G a ≤ STSA.G (STSA.G a) := by
    induction a using Quotient.ind with
    | _ φ =>
      show G_quot (toQuot φ) ≤ G_quot (G_quot (toQuot φ))
      show Derives φ.all_future φ.all_future.all_future
      exact ⟨DerivationTree.axiom [] _ (Axiom.temp_4 φ)⟩
  have h_GGa_in : STSA.G (STSA.G a) ∈ U := U.mem_of_le h_Ga_in h_le
  have h_Ga_in_V : STSA.G a ∈ V := h_UV (STSA.G a) h_GGa_in
  exact h_VW a h_Ga_in_V

/-!
### R_Box Properties
-/

/--
R_Box is reflexive: every ultrafilter is R_Box-related to itself.

Proof: From modal_t, we have □a ≤ a. Since □a ∈ U and U is
upward closed, a ∈ U follows.
-/
theorem R_Box_refl (U : Ultrafilter LindenbaumAlg) : R_Box U U := by
  intro a h_boxa_in
  have h_le : STSA.box a ≤ a := STSA.box_deflationary a
  exact U.mem_of_le h_boxa_in h_le

/--
R_Box is Euclidean: R_Box(U, V) and R_Box(U, W) imply R_Box(V, W).

This is the S5 collapse property. From box_s5, (□a)ᶜ ≤ □(□a)ᶜ.
If □a ∈ V, we show a ∈ W.

Proof: Suppose □a ∈ V but a ∉ W.
- Since a ∉ W and W is ultrafilter: aᶜ ∈ W
- We need to derive a contradiction from the S5 properties.

Actually, we use a simpler argument via box_idempotent:
If □a ∈ V, then by R_Box(U, V) backwards we need □(□a) ∈ U.
By box_idempotent: □(□a) = □a.
-/
theorem R_Box_euclidean {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_Box U V) (h_UW : R_Box U W) : R_Box V W := by
  -- This requires showing: if □a ∈ V then a ∈ W
  -- In S5, R_Box is an equivalence relation, so this should hold.
  -- We need to use the S5 axioms to prove this.

  -- Standard S5 argument: □a ∈ V implies □□a ∈ V (by 4), and then
  -- since U R_Box V, we can transfer. But we need the reverse direction.

  -- Alternative: use that in S5, if R(U,V) and R(U,W), then R(V,W)
  -- The key is: (□a)ᶜ ∈ V implies □(□a)ᶜ ∈ V (by S5 collapse)
  -- Then by R_Box(U, V) backwards... this is getting circular.

  -- Let's use: □a ∈ V, need a ∈ W
  -- By contraposition: assume a ∉ W, derive □a ∉ V

  intro a h_boxa_in_V
  by_contra h_a_notin_W
  -- a ∉ W means aᶜ ∈ W (ultrafilter)
  have h_ac_in_W : aᶜ ∈ W := by
    cases W.compl_or a with
    | inl h => exact absurd h h_a_notin_W
    | inr h => exact h
  -- □a ∈ V means (□a)ᶜ ∉ V
  have h_boxac_notin_V : (STSA.box a)ᶜ ∉ V := V.compl_not (STSA.box a) h_boxa_in_V
  -- By S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ
  have h_s5 : (STSA.box a)ᶜ ≤ STSA.box ((STSA.box a)ᶜ) := STSA.box_s5 a
  -- If (□a)ᶜ ∈ V, then □(□a)ᶜ ∈ V
  -- Since (□a)ᶜ ∉ V, this is vacuously usable.

  -- Different approach: use that □ distributes
  -- We know □a ∈ V. In S5 with universal accessibility in the bundle,
  -- □a should be accessible everywhere.

  -- Key insight: box_idempotent says □(□a) = □a
  -- So if □a ∈ V, we need □a ∈ U to use R_Box(U, W).
  -- But we don't directly have □a ∈ U.

  -- S5 property we need: R_Box(U,V) should imply that U and V have the same □-formulas
  -- Actually, let's use: if □a ∈ V and □a ∉ U, then ¬□a ∈ U, then □¬□a ∈ U (S5)

  -- The correct S5 Euclidean proof:
  -- Assume □a ∈ V. We show a ∈ W.
  -- Case 1: □a ∈ U. Then by R_Box(U, W): a ∈ W. Done.
  -- Case 2: □a ∉ U. Then (□a)ᶜ ∈ U.
  --   By S5 collapse: (□a)ᶜ ≤ □(□a)ᶜ, so □(□a)ᶜ ∈ U.
  --   By R_Box(U, V): (□a)ᶜ ∈ V.
  --   But □a ∈ V, contradiction.

  by_cases h_boxa_in_U : STSA.box a ∈ U
  · -- Case 1: □a ∈ U
    exact h_a_notin_W (h_UW a h_boxa_in_U)
  · -- Case 2: □a ∉ U, so (□a)ᶜ ∈ U
    have h_boxac_in_U : (STSA.box a)ᶜ ∈ U := by
      cases U.compl_or (STSA.box a) with
      | inl h => exact absurd h h_boxa_in_U
      | inr h => exact h
    -- By S5 collapse and upward closure: □(□a)ᶜ ∈ U
    have h_box_boxac_in_U : STSA.box ((STSA.box a)ᶜ) ∈ U :=
      U.mem_of_le h_boxac_in_U h_s5
    -- By R_Box(U, V): (□a)ᶜ ∈ V
    have h_boxac_in_V : (STSA.box a)ᶜ ∈ V := h_UV ((STSA.box a)ᶜ) h_box_boxac_in_U
    -- But □a ∈ V, so both (□a) and (□a)ᶜ are in V, contradiction
    exact V.compl_not (STSA.box a) h_boxa_in_V h_boxac_in_V

/--
R_Box is symmetric: R_Box(U, V) implies R_Box(V, U).

Proof using Euclidean + reflexive:
R_Box(U, V) and R_Box(U, U) (reflexivity) imply R_Box(V, U) by Euclidean.
-/
theorem R_Box_symm {U V : Ultrafilter LindenbaumAlg} (h : R_Box U V) : R_Box V U :=
  R_Box_euclidean h (R_Box_refl U)

/--
R_Box is transitive: R_Box(U, V) and R_Box(V, W) imply R_Box(U, W).

Proof using symmetric + Euclidean:
R_Box(U, V) implies R_Box(V, U) by symmetry.
R_Box(V, U) and R_Box(V, W) imply R_Box(U, W) by Euclidean.
-/
theorem R_Box_trans {U V W : Ultrafilter LindenbaumAlg}
    (h_UV : R_Box U V) (h_VW : R_Box V W) : R_Box U W :=
  R_Box_euclidean (R_Box_symm h_UV) h_VW

/-!
## Phase 2: Box-Class BFMCS Construction

Rather than building the BFMCS through ultrafilter chains (which requires complex
filter extension lemmas), we use the MCS-level SuccChain infrastructure directly.

### Key Components:
1. `SuccChainFMCS` / `SuccChainTemporalCoherent` - sorry-free FMCS with temporal coherence
2. `parametric_box_persistent` - Box formulas are constant along any FMCS chain
3. `saturated_modal_backward` - modal_backward from modal saturation
4. Box-class witness consistency - the mathematical core

### Construction Strategy:
Given MCS M0, build a BFMCS as follows:
- The bundle contains all shifted SuccChainFMCS from MCSes with the same box-content as M0
- Modal forward follows from box-content agreement + box persistence
- Modal saturation follows from the box-class witness existence lemma
- Modal backward follows from saturated_modal_backward
- Temporal coherence follows from SuccChainTemporalCoherent
-/

/-!
### Box Content and Box Class

The box content of an MCS determines which Box-formulas it contains.
Two MCSes in the same "box class" agree on all Box-formulas.
-/

/--
The box content of an MCS: the set of inner formulas phi where Box(phi) is in the MCS.
-/
def box_content (M : Set Formula) : Set Formula :=
  { phi | Formula.box phi ∈ M }

/--
Two MCSes agree on box content iff they contain the same Box-formulas.
-/
def box_class_agree (M W : Set Formula) : Prop :=
  ∀ phi : Formula, Formula.box phi ∈ M ↔ Formula.box phi ∈ W

theorem box_class_agree_refl (M : Set Formula) : box_class_agree M M :=
  fun _ => Iff.rfl

theorem box_class_agree_symm {M W : Set Formula} (h : box_class_agree M W) :
    box_class_agree W M :=
  fun phi => (h phi).symm

/-!
### Shifted FMCS

A shifted FMCS moves the time origin by an integer offset.
This is needed so that witness chains can place their base MCS at any time point.
-/

/--
Shift an FMCS by offset k: the new family maps time t to the original family at t - k.
-/
noncomputable def shifted_fmcs (f : FMCS Int) (k : Int) : FMCS Int where
  mcs := fun t => f.mcs (t - k)
  is_mcs := fun t => f.is_mcs (t - k)
  forward_G := fun t t' phi h_le h_G => f.forward_G (t - k) (t' - k) phi (by omega) h_G
  backward_H := fun t t' phi h_le h_H => f.backward_H (t - k) (t' - k) phi (by omega) h_H

/--
The shifted FMCS at the offset equals the original FMCS at 0.
-/
theorem shifted_fmcs_at_offset (f : FMCS Int) (k : Int) :
    (shifted_fmcs f k).mcs k = f.mcs 0 := by
  unfold shifted_fmcs
  simp

/--
Temporal coherence is preserved by shifting.
-/
theorem shifted_temporal_forward_F (f : FMCS Int)
    (h_fwd : ∀ t : Int, ∀ φ : Formula, Formula.some_future φ ∈ f.mcs t →
      ∃ s : Int, t < s ∧ φ ∈ f.mcs s)
    (k : Int) (t : Int) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (shifted_fmcs f k).mcs t) :
    ∃ s : Int, t < s ∧ φ ∈ (shifted_fmcs f k).mcs s := by
  unfold shifted_fmcs at h_F ⊢
  simp only at h_F ⊢
  obtain ⟨s, h_lt, h_phi⟩ := h_fwd (t - k) φ h_F
  exact ⟨s + k, by omega, by ring_nf; exact h_phi⟩

theorem shifted_temporal_backward_P (f : FMCS Int)
    (h_bwd : ∀ t : Int, ∀ φ : Formula, Formula.some_past φ ∈ f.mcs t →
      ∃ s : Int, s < t ∧ φ ∈ f.mcs s)
    (k : Int) (t : Int) (φ : Formula)
    (h_P : Formula.some_past φ ∈ (shifted_fmcs f k).mcs t) :
    ∃ s : Int, s < t ∧ φ ∈ (shifted_fmcs f k).mcs s := by
  unfold shifted_fmcs at h_P ⊢
  simp only at h_P ⊢
  obtain ⟨s, h_lt, h_phi⟩ := h_bwd (t - k) φ h_P
  exact ⟨s + k, by omega, by ring_nf; exact h_phi⟩

/-!
### Box Persistence in SuccChain

Box-formulas are constant along any FMCS (using parametric_box_persistent).
For SuccChainFMCS specifically, this means box_content is the same at all times.
-/

/--
Box formulas are constant along a SuccChainFMCS: Box(phi) at time 0 iff Box(phi) at time t.
-/
theorem succ_chain_box_persistent (M0 : SerialMCS) (phi : Formula) (t : Int) :
    Formula.box phi ∈ (SuccChainFMCS M0).mcs 0 ↔
    Formula.box phi ∈ (SuccChainFMCS M0).mcs t := by
  constructor
  · intro h => exact parametric_box_persistent (SuccChainFMCS M0) phi 0 t h
  · intro h => exact parametric_box_persistent (SuccChainFMCS M0) phi t 0 h

/--
Box formulas are constant in shifted SuccChainFMCS.
-/
theorem shifted_succ_chain_box_persistent (M0 : SerialMCS) (k : Int)
    (phi : Formula) (t : Int) :
    Formula.box phi ∈ (shifted_fmcs (SuccChainFMCS M0) k).mcs k ↔
    Formula.box phi ∈ (shifted_fmcs (SuccChainFMCS M0) k).mcs t := by
  unfold shifted_fmcs
  simp only
  constructor
  · intro h => exact parametric_box_persistent (SuccChainFMCS M0) phi (k - k) (t - k) h
  · intro h => exact parametric_box_persistent (SuccChainFMCS M0) phi (t - k) (k - k) h

/-!
### Box-Class Witness Consistency

The mathematical core: if Diamond(psi) is in an MCS M, then {psi} ∪ box_content(M)
is consistent. This uses the S5 axiom (negative introspection) to reduce all
hypotheses to Box-formulas, then applies necessitation and K-distribution.
-/

/--
If Diamond(psi) is in an MCS M, then {psi} ∪ box_content(M) is consistent.

This is the key lemma for modal saturation. The proof uses:
1. Suppose {psi} ∪ box_content(M) is inconsistent
2. Then exists a1,...,an with Box(ai) in M and {psi, a1,...,an} derives bot
3. By deduction theorem: derives a1 -> ... -> an -> neg(psi)
4. By necessitation: derives Box(a1 -> ... -> an -> neg(psi))
5. By K-distribution (n times): Box(a1) -> ... -> Box(an) -> Box(neg(psi))
6. Since all Box(ai) in M: Box(neg(psi)) in M
7. But Diamond(psi) = neg(Box(neg(psi))) in M: contradiction
-/
theorem box_class_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    SetConsistent ({psi} ∪ box_content M) := by
  -- SetConsistent means: for every finite list L ⊆ S, L does not derive bot
  intro L h_L_sub ⟨d⟩
  -- L is a list of formulas from {psi} ∪ box_content(M)
  -- d : L ⊢ bot

  -- Every element of L is either psi or some ai with Box(ai) ∈ M
  -- We can weaken to a derivation from [psi] ++ [a1, ..., an] where Box(ai) ∈ M

  -- Strategy: use deduction theorem to move all assumptions into the theorem,
  -- then apply necessitation and K-distribution.

  -- First, move all hypotheses out via repeated deduction theorem:
  -- From L ⊢ bot, by weakening to include all of L in a single context,
  -- we can derive: [] ⊢ l1 → l2 → ... → ln → bot = neg(l1 ∧ ... ∧ ln)

  -- Actually, the key insight is simpler. We use:
  -- 1. L ⊆ {psi} ∪ box_content(M) means every li is psi or in box_content(M)
  -- 2. For li in box_content(M), Box(li) ∈ M, so by T axiom, li ∈ M
  -- 3. For li = psi, we handle separately

  -- Case: psi ∉ L. Then L ⊆ box_content(M), and every li has Box(li) ∈ M.
  -- By T axiom: li ∈ M. So L ⊆ M. But M is consistent: L ⊆ M and L ⊢ bot
  -- contradicts MCS consistency.

  -- Case: psi ∈ L. Let L' = L without psi occurrences. Then all l ∈ L' have
  -- Box(l) ∈ M, so l ∈ M (by T). And L' ∪ {psi} ⊢ bot (by weakening from L).

  -- By repeated deduction theorem on L':
  -- [psi] ⊢ l1 → l2 → ... → bot  (removing L' elements one by one)
  -- Then [] ⊢ psi → (l1 → l2 → ... → bot)
  -- i.e., [] ⊢ neg(psi) assuming L' derives bot with psi

  -- Actually let's work more directly. Since L ⊢ bot:
  -- By weakening, M_list ++ [psi] ⊢ bot where M_list consists of elements of M
  -- (because for x ∈ L ∩ box_content(M), Box(x) ∈ M so x ∈ M by T)

  -- Hmm, but psi might appear multiple times. Let me use a cleaner approach.

  -- Simplest approach: show that L ⊆ M ∪ {psi}, and then get M_full ⊢ bot
  -- where M_full contains all of M plus psi.

  -- Actually, the cleanest approach is:
  -- 1. From L ⊢ bot, derive [] ⊢ (conjunction of L) → bot
  -- 2. The conjunction of L elements is a conjunction of psi and ai where Box(ai) ∈ M
  -- 3. Apply necessitation and K to get Box(neg(psi)) ∈ M

  -- Let me use the direct list-based approach from the MCS consistency proof.

  -- All elements of L either equal psi or have their Box in M
  -- For elements with Box in M, they are also in M (by T axiom)
  have h_T := fun (phi : Formula) (h_box : Formula.box phi ∈ M) =>
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.modal_t phi))) h_box

  -- Split L into psi-part and box_content part
  -- Weaken L to M-context by replacing box_content elements with their M-membership
  -- The key: every element of L is in M ∪ {psi}
  have h_L_in_M_or_psi : ∀ x ∈ L, x ∈ M ∨ x = psi := by
    intro x hx
    have hx_in_S := h_L_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at hx_in_S
    rcases hx_in_S with h_psi | h_bc
    · right; exact h_psi
    · left
      -- x ∈ box_content M means Box(x) ∈ M, so x ∈ M by T
      exact h_T x h_bc

  -- Now we have L ⊢ bot and every element of L is in M ∪ {psi}
  -- Weaken the derivation to work from the context M ∪ {psi}
  -- Since M is consistent, adding psi might make it inconsistent
  -- But we'll show this leads to Box(neg(psi)) ∈ M, contradicting Diamond(psi) ∈ M

  -- Approach: weaken L to (insert psi M)-list
  -- L ⊢ bot, and L ⊆ insert psi M
  -- So insert psi M is SetConsistent → False? No, SetConsistent uses finite subsets.
  -- Actually L IS a finite subset of insert psi M.
  -- So ¬SetConsistent (insert psi M).

  have h_not_cons : ¬SetConsistent (insert psi M) := by
    intro h_cons
    have h_L_sub' : ∀ x ∈ L, x ∈ insert psi M := by
      intro x hx
      rcases h_L_in_M_or_psi x hx with h_M | h_psi
      · exact Set.mem_insert_of_mem psi h_M
      · rw [h_psi]; exact Set.mem_insert psi M
    exact h_cons L h_L_sub' ⟨d⟩

  -- Since M is MCS and insert psi M is inconsistent,
  -- by MCS maximality: psi ∉ M implies ¬SetConsistent (insert psi M)
  -- Conversely: if psi ∈ M, then insert psi M = M, which is consistent.

  -- So psi ∉ M (otherwise insert psi M = M which is consistent)
  have h_psi_notin : psi ∉ M := by
    intro h_in
    have h_eq : insert psi M = M := Set.insert_eq_of_mem h_in
    rw [h_eq] at h_not_cons
    exact h_not_cons h_mcs.1

  -- By MCS negation completeness: neg(psi) ∈ M
  have h_neg_psi : Formula.neg psi ∈ M := by
    rcases SetMaximalConsistent.negation_complete h_mcs psi with h | h
    · exact absurd h h_psi_notin
    · exact h

  -- By MCS maximality: psi ∉ M implies ¬SetConsistent(insert psi M)
  -- We already have this: h_not_cons
  -- From ¬SetConsistent(insert psi M), there's a finite list L' ⊆ insert psi M with L' ⊢ bot
  -- Using the deduction theorem approach:

  -- Since insert psi M is inconsistent, ∃ L' ⊆ insert psi M, L' ⊢ bot
  -- Remove psi from L' to get L'' ⊆ M with L'' ⊢ psi → bot = neg(psi)
  -- But neg(psi) ∈ M already, and M is consistent. This doesn't directly give Box.

  -- Let me use the direct S5 argument instead.
  -- We have neg(psi) ∈ M. Can we get Box(neg(psi)) ∈ M?
  -- Not directly from neg(psi) ∈ M. We need a different approach.

  -- Going back to the original argument:
  -- From L ⊢ bot where L ⊆ {psi} ∪ box_content(M):
  -- Separate psi from the rest: let L' = L \ {psi}
  -- Then L' ⊆ box_content(M), i.e., ∀ x ∈ L', Box(x) ∈ M
  -- And L' ++ [psi, ..., psi] ⊢ bot (some copies of psi from L)
  -- By weakening: L' ++ [psi] ⊢ bot (since duplicate psi adds nothing)
  -- By deduction theorem: L' ⊢ neg(psi) = psi → bot

  -- Now L' ⊢ neg(psi) where ∀ x ∈ L', Box(x) ∈ M.
  -- Weaken to the full list [a1,...,an] where ai = elements of L' (with Box(ai) ∈ M):
  -- [] ⊢ a1 → a2 → ... → an → neg(psi)  (by repeated deduction theorem)

  -- Apply necessitation: [] ⊢ Box(a1 → a2 → ... → an → neg(psi))
  -- Apply K-distribution n times:
  -- [] ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(neg(psi))

  -- Since Box(ai) ∈ M for all i, by MCS modus ponens: Box(neg(psi)) ∈ M
  -- But Diamond(psi) = neg(Box(neg(psi))) ∈ M: contradiction with MCS consistency.

  -- The full argument requires careful handling of the list operations.
  -- Let's use the fact that M is MCS and work with the MCS-level inconsistency.

  -- From h_not_cons, insert psi M is inconsistent.
  -- From h_mcs.2: for any phi ∉ M, insert phi M is inconsistent.
  -- This is exactly what h_psi_notin + h_mcs.2 gives us.

  -- Now: since neg(psi) ∈ M, can we derive Box(neg(psi))?
  -- In general no. But we can use the S5-specific argument.

  -- The actual argument: L ⊢ bot, L ⊆ {psi} ∪ box_content(M).
  -- We need to show this leads to Box(neg(psi)) ∈ M.

  -- Approach using the MCS-level proof:
  -- We'll construct a derivation [] ⊢ Box(neg(psi)) using:
  -- 1. From L ⊢ bot, extract [] ⊢ a1 → ... → an → neg(psi) where Box(ai) ∈ M
  -- 2. By necessitation and K: [] ⊢ Box(a1) → ... → Box(an) → Box(neg(psi))
  -- 3. Since Box(ai) ∈ M: Box(neg(psi)) ∈ M

  -- However, constructing this in Lean requires manipulating DerivationTree for
  -- arbitrary-length lists. This is technically involved but mathematically straightforward.

  -- For now, we'll use a simpler argument that avoids list manipulation:
  -- We directly show the contradiction using diamond_excludes_box_neg from ModalSaturation.

  -- diamond_excludes_box_neg: Diamond(psi) ∈ M → Box(neg(psi)) ∉ M
  have h_box_neg_notin : Formula.box (Formula.neg psi) ∉ M :=
    diamond_excludes_box_neg h_mcs psi h_diamond

  -- We need Box(neg(psi)) ∈ M for the contradiction.
  -- The inconsistency of {psi} ∪ box_content(M) means:
  -- exists L ⊆ {psi} ∪ box_content(M) with L ⊢ bot.
  -- We have this: L, d.

  -- Key insight: we prove this by induction on the derivation,
  -- but that's complex. Instead, use the finitary MCS argument:

  -- Since L ⊢ bot and all non-psi elements of L are in M (via T axiom on Box),
  -- we can weaken to [psi] ++ M_list ⊢ bot where M_list ⊆ M.
  -- By deduction: M_list ⊢ neg(psi).
  -- Since M_list ⊆ M and M is an MCS: neg(psi) ∈ M.
  -- But this only gives neg(psi) ∈ M, not Box(neg(psi)) ∈ M.

  -- The S5-specific step: we need to lift from formulas to Box-formulas.
  -- The derivation L ⊢ bot where L ⊆ {psi} ∪ box_content(M) means:
  -- There exist a1,...,an with Box(ai) ∈ M such that {psi, a1,...,an} ⊢ bot.
  -- This means ⊢ a1 → ... → an → neg(psi) (after repeated deduction theorem).
  -- By necessitation: ⊢ Box(a1 → ... → an → neg(psi))
  -- By K-distribution: ⊢ Box(a1) → ... → Box(an) → Box(neg(psi))
  -- Since Box(ai) ∈ M: Box(neg(psi)) ∈ M.

  -- We formalize this using an auxiliary lemma that handles the K-distribution chain.

  -- Step 1: Extract the box_content elements from L
  -- Weaken d to work with elements that are all in M or equal to psi
  -- Then apply the deduction theorem for psi to get M_list ⊢ neg(psi)

  -- For the formalization, we use the list-based approach.
  -- Filter L into psi-copies and box_content elements.
  let L_no_psi := L.filter (· ≠ psi)

  -- All elements of L_no_psi are in box_content(M)
  have h_L_no_psi_bc : ∀ x ∈ L_no_psi, x ∈ box_content M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ psi := by
      simp only [List.mem_filter, ne_eq, decide_eq_true_eq] at hx
      exact hx.2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  -- Step 2: Weaken the derivation. L ⊢ bot can be weakened to (psi :: L_no_psi) ⊢ bot
  -- because L_no_psi ⊆ L (modulo psi which we add back)
  -- Actually, we need to weaken from L to a list containing psi and the L_no_psi elements.
  -- Since L ⊆ {psi} ∪ set_of(L_no_psi ++ [psi]), we can weaken.

  -- Simplification: just use the fact that L ⊆ insert psi M gives insert psi M inconsistent,
  -- then use the MCS property to derive Box(neg(psi)) ∈ M through the S5 argument.

  -- The S5 argument at the MCS level:
  -- insert psi M is inconsistent → neg(psi) can be derived from M
  -- → ¬SetConsistent (insert psi M)
  -- → by maximality applied to (neg (neg psi)): if neg(neg(psi)) ∉ M then contradiction...
  -- This is going in circles.

  -- Let me use the DIRECT finitary argument.
  -- We have d : DerivationTree L Formula.bot
  -- We know every x ∈ L is in M ∪ {psi} (h_L_in_M_or_psi)
  -- Weaken d to derive from M ∪ {psi}:

  -- Weaken to [psi] ++ M_elems where M_elems are the non-psi elements of L, all in M.
  -- Then apply deduction theorem for psi: M_elems ⊢ neg(psi).
  -- Then [] ⊢ m1 → ... → mk → neg(psi) by repeated deduction.
  -- By necessitation: ⊢ Box(m1 → ... → mk → neg(psi))
  -- The mi are in M. But are Box(mi) in M? Only if mi ∈ box_content(M),
  -- meaning Box(mi) ∈ M. For mi ∈ box_content(M), yes. For mi = some arbitrary
  -- element of M, Box(mi) might not be in M.

  -- AH - here's the key: the elements of L that are in M came from box_content(M).
  -- They are ai where Box(ai) ∈ M. We used T axiom to put ai in M.
  -- But for the K-distribution argument, we need Box(ai) ∈ M, which we have!

  -- So: L = [psi, a1, ..., an] where Box(ai) ∈ M.
  -- L ⊢ bot.
  -- By repeated deduction: ⊢ psi → a1 → ... → an → bot = a1 → ... → an → neg(psi)
  -- Wait, the order matters for deduction theorem.

  -- Actually: L ⊢ bot. After deduction theorem removing psi:
  -- L \ {psi} ⊢ neg(psi). Where L \ {psi} ⊆ box_content(M).
  -- After repeated deduction on L \ {psi} = [a1,...,an]:
  -- ⊢ a1 → a2 → ... → an → neg(psi)
  -- By necessitation: ⊢ Box(a1 → ... → an → neg(psi))
  -- By K (n times): ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(neg(psi))
  -- Since Box(ai) ∈ M: Box(neg(psi)) ∈ M.
  -- Contradiction with Diamond(psi) = neg(Box(neg(psi))) ∈ M.

  -- The challenge is formalizing the "repeated deduction theorem" and
  -- "K-distribution n times" for arbitrary n. Let me use a helper lemma.

  -- Helper: if ⊢ A → B and Box(A) ∈ M, then Box(B) ∈ M.
  -- Proof: By necessitation: ⊢ Box(A → B). By K: ⊢ Box(A) → Box(B).
  -- Since Box(A) ∈ M: Box(B) ∈ M.

  -- So we need: ⊢ a1 → (a2 → ... → (an → neg(psi))...)
  -- Then: Box(a1) ∈ M → Box(a2 → ... → neg(psi)) ∈ M (by helper)
  -- Then: Box(a2) ∈ M → Box(a3 → ... → neg(psi)) ∈ M (by helper on unboxed inner)
  -- Wait, this doesn't quite work because Box distributes as Box(A→B) → (Box(A) → Box(B))

  -- Let me use the standard "Box-lift" lemma:
  -- If ⊢ A → B, then ⊢ Box(A) → Box(B)
  -- Proof: Necessitate A → B, then apply K.

  -- And the iterated version:
  -- If ⊢ a1 → a2 → ... → an → C, then ⊢ Box(a1) → Box(a2) → ... → Box(an) → Box(C)
  -- Proof by induction on n using the above.

  -- For the formalization, we use List.foldl or induction on the list.
  -- This is the "box_lift_chain" lemma.

  -- Rather than formalizing the full iterated version (which requires complex list
  -- manipulation), we use a key simplification:

  -- From L ⊢ bot where L ⊆ {psi} ∪ box_content(M), we weaken L to M:
  -- Every non-psi element ai of L has Box(ai) ∈ M, so ai ∈ M (by T).
  -- So L ⊆ M ∪ {psi}. We already know insert psi M is inconsistent (h_not_cons).
  -- By MCS maximality: neg(psi) ∈ M (h_neg_psi).

  -- Now the key question: can we get Box(neg(psi)) ∈ M from this specific structure?

  -- The answer is YES, using a more refined argument:
  -- h_not_cons tells us insert psi M is inconsistent.
  -- There exists a finite L' ⊆ insert psi M with L' ⊢ bot.
  -- Take L' minimal. Then psi ∈ L' (otherwise L' ⊆ M and M inconsistent).
  -- Remove psi: L'' = L' \ [psi]. L'' ⊆ M. [psi] ++ L'' ⊢ bot.
  -- By deduction: L'' ⊢ neg(psi). By repeated deduction: ⊢ l1 → ... → lk → neg(psi).

  -- Here l1,...,lk are elements of M. But we can't necessitate unless they are theorems.
  -- The issue: l1,...,lk are arbitrary elements of M, not box_content elements.

  -- BUT wait: in our specific case, L ⊆ {psi} ∪ box_content(M), not L ⊆ {psi} ∪ M.
  -- So the non-psi elements of L are in box_content(M), meaning Box(li) ∈ M.

  -- So the refined argument IS: L'' (non-psi part of L) ⊆ box_content(M).
  -- ⊢ l1 → l2 → ... → lk → neg(psi) where Box(li) ∈ M.
  -- Necessitate and distribute K:
  -- ⊢ Box(l1) → Box(l2) → ... → Box(lk) → Box(neg(psi))
  -- Since Box(li) ∈ M: Box(neg(psi)) ∈ M. Contradiction.

  -- Let me now formalize this properly using induction on the list.

  -- First, let's establish that we can extract a derivation from non-psi elements.
  -- We have d : L ⊢ bot and L ⊆ {psi} ∪ box_content(M).
  -- Weaken to (psi :: L_no_psi) ⊢ bot.

  -- Actually, L might have psi in any position. We can weaken from L to any
  -- superlist. The key fact: L ⊆ psi :: L_no_psi (as sets).
  -- Wait, we need the opposite: weaken FROM L TO a smaller/different context.
  -- Weakening goes: if L ⊆ L' then L ⊢ bot implies L' ⊢ bot.
  -- So we need L ⊆ (psi :: L_no_psi).

  -- This is true: every element of L is either psi (in head) or in L_no_psi (by filter).
  -- Actually L_no_psi = L.filter (· ≠ psi) so L ⊆ [psi] ++ L_no_psi.

  have h_L_sub_psi_Lnp : ∀ x ∈ L, x ∈ psi :: L_no_psi := by
    intro x hx
    by_cases h_eq : x = psi
    · rw [h_eq]; exact List.mem_cons_self psi L_no_psi
    · exact List.mem_cons_of_mem psi (List.mem_filter.mpr ⟨hx, h_eq⟩)

  -- Weaken: psi :: L_no_psi ⊢ bot
  have d_weak : DerivationTree (psi :: L_no_psi) Formula.bot :=
    DerivationTree.weakening L (psi :: L_no_psi) Formula.bot d h_L_sub_psi_Lnp

  -- Deduction theorem: L_no_psi ⊢ neg(psi) = psi → bot
  have d_neg_psi : DerivationTree L_no_psi (Formula.neg psi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_psi psi Formula.bot d_weak

  -- Now we need: ⊢ l1 → l2 → ... → lk → neg(psi) by repeated deduction,
  -- then necessitate and K-distribute.

  -- We prove: Box(neg(psi)) ∈ M by induction on L_no_psi.
  -- The invariant: if ctx ⊢ neg(psi) and ∀ x ∈ ctx, Box(x) ∈ M, then Box(neg(psi)) ∈ M.

  -- This is the "box_lift_from_context" lemma.
  suffices h : ∀ (ctx : List Formula) (phi : Formula),
      DerivationTree ctx phi → (∀ x ∈ ctx, Formula.box x ∈ M) → Formula.box phi ∈ M by
    exact h_box_neg_notin (h L_no_psi (Formula.neg psi) d_neg_psi
      (fun x hx => h_L_no_psi_bc x hx))

  -- Prove the box_lift_from_context by induction on the context length
  intro ctx phi d_ctx h_ctx_box
  induction ctx generalizing phi with
  | nil =>
    -- Empty context: d_ctx is a theorem ([] ⊢ phi)
    -- By necessitation: ⊢ Box(phi). So Box(phi) ∈ M.
    have d_box : DerivationTree [] (Formula.box phi) := DerivationTree.necessitation phi d_ctx
    exact theorem_in_mcs h_mcs d_box
  | cons a rest ih =>
    -- Context is a :: rest.
    -- d_ctx : (a :: rest) ⊢ phi
    -- By deduction theorem: rest ⊢ a → phi
    have d_imp : DerivationTree rest (a.imp phi) :=
      Bimodal.Metalogic.Core.deduction_theorem rest a phi d_ctx
    -- By induction hypothesis (since all elements of rest have their Box in M):
    -- Box(a → phi) ∈ M
    have h_rest_box : ∀ x ∈ rest, Formula.box x ∈ M :=
      fun x hx => h_ctx_box x (List.mem_cons_of_mem a hx)
    have h_box_imp : Formula.box (a.imp phi) ∈ M := ih (a.imp phi) d_imp h_rest_box
    -- Box(a) ∈ M (from h_ctx_box)
    have h_box_a : Formula.box a ∈ M := h_ctx_box a (List.mem_cons_self a rest)
    -- K-distribution: Box(a → phi) → (Box(a) → Box(phi))
    have h_K : [] ⊢ (Formula.box (a.imp phi)).imp ((Formula.box a).imp (Formula.box phi)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist a phi)
    -- Box(a → phi) ∈ M and K ∈ M give Box(a) → Box(phi) ∈ M
    have h_imp_in_M : (Formula.box a).imp (Formula.box phi) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_K) h_box_imp
    -- Box(a) ∈ M and (Box(a) → Box(phi)) ∈ M give Box(phi) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_box_a

/-!
### Box-Class Witness Existence

From box_class_witness_consistent, we extend to a full MCS in the same box class.
-/

/-!
### Strengthened Box-Class Witness

We strengthen the seed to include Box-formulas directly, along with
neg(Box) formulas for non-box elements, ensuring full box-class agreement.
-/

/--
The "box theory" of an MCS: the set of Box-formulas and their negations that are in M.
This is {Box(a) | Box(a) ∈ M} ∪ {neg(Box(a)) | Box(a) ∉ M}.
-/
def box_theory (M : Set Formula) : Set Formula :=
  { f | (∃ a, f = Formula.box a ∧ Formula.box a ∈ M) ∨
        (∃ a, f = Formula.neg (Formula.box a) ∧ Formula.box a ∉ M) }

/--
All elements of box_theory(M) are in M (when M is an MCS).
-/
theorem box_theory_subset_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    box_theory M ⊆ M := by
  intro f hf
  simp only [box_theory, Set.mem_setOf_eq] at hf
  rcases hf with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · exact ha
  · -- Box(a) ∉ M, so neg(Box(a)) ∈ M by negation completeness
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
    · exact absurd h ha
    · exact h

/--
The strengthened consistency lemma: {psi} ∪ box_theory(M) is consistent
when Diamond(psi) is in M.

The proof uses S5 negative introspection to convert all hypotheses to Box-formulas.
-/
theorem box_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    SetConsistent ({psi} ∪ box_theory M) := by
  -- The key: box_theory(M) ⊆ M, and {psi} ∪ M might be inconsistent,
  -- but {psi} ∪ box_theory(M) is a SUBSET of {psi} ∪ M, so this doesn't help directly.

  -- We use the S5 argument. Suppose {psi} ∪ box_theory(M) is inconsistent.
  -- Then ∃ L ⊆ {psi} ∪ box_theory(M) with L ⊢ bot.
  intro L h_L_sub ⟨d⟩

  -- Every element of L is either psi, some Box(a) with Box(a) ∈ M,
  -- or some neg(Box(a)) with Box(a) ∉ M.
  -- In the latter case, by S5 axiom 5: neg(Box(a)) → Box(neg(Box(a)))
  -- So Box(neg(Box(a))) ∈ M.

  -- Strategy: show all elements of L are in M, then use MCS consistency.
  -- box_theory(M) ⊆ M (by box_theory_subset_mcs), so L ⊆ {psi} ∪ M = insert psi M.
  have h_bt_sub := box_theory_subset_mcs M h_mcs
  have h_L_in_M_or_psi : ∀ x ∈ L, x ∈ insert psi M := by
    intro x hx
    have := h_L_sub x hx
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · exact Set.mem_insert_iff.mpr (Or.inl h)
    · exact Set.mem_insert_of_mem psi (h_bt_sub h)

  -- Now the argument parallels box_class_witness_consistent but with box_theory.

  -- We need all non-psi elements to have their Box in M.
  -- For Box(a) ∈ box_theory: Box(Box(a)) ∈ M (by axiom 4: Box(a) → Box(Box(a)))
  -- For neg(Box(a)) ∈ box_theory: Box(neg(Box(a))) ∈ M (by axiom 5)

  -- So ALL non-psi elements of L from box_theory have their Box in M!

  -- Extract box-boxing property
  have h_box_of_bt : ∀ x ∈ box_theory M, Formula.box x ∈ M := by
    intro x hx
    simp only [box_theory, Set.mem_setOf_eq] at hx
    rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
    · -- x = Box(a), Box(a) ∈ M. Need Box(Box(a)) ∈ M.
      -- By axiom 4: Box(a) → Box(Box(a))
      have h_4 : [] ⊢ (Formula.box a).imp (Formula.box (Formula.box a)) :=
        DerivationTree.axiom [] _ (Axiom.modal_4 a)
      exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_4) ha
    · -- x = neg(Box(a)), Box(a) ∉ M. Need Box(neg(Box(a))) ∈ M.
      -- By S5 axiom 5 (negative introspection): neg(Box(a)) → Box(neg(Box(a)))
      have h_neg_box : (Formula.box a).neg ∈ M := by
        rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
        · exact absurd h ha
        · exact h
      exact SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box

  -- Now use the same box_lift_from_context argument as before.
  -- Filter L into psi-part and box_theory part
  let L_no_psi := L.filter (· ≠ psi)

  have h_L_no_psi_bt : ∀ x ∈ L_no_psi, x ∈ box_theory M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ psi := by
      simp only [List.mem_filter, ne_eq, decide_eq_true_eq] at hx
      exact hx.2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_psi_Lnp : ∀ x ∈ L, x ∈ psi :: L_no_psi := by
    intro x hx
    by_cases h_eq : x = psi
    · rw [h_eq]; exact List.mem_cons_self psi L_no_psi
    · exact List.mem_cons_of_mem psi (List.mem_filter.mpr ⟨hx, h_eq⟩)

  have d_weak : DerivationTree (psi :: L_no_psi) Formula.bot :=
    DerivationTree.weakening L (psi :: L_no_psi) Formula.bot d h_L_sub_psi_Lnp

  have d_neg_psi : DerivationTree L_no_psi (Formula.neg psi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_psi psi Formula.bot d_weak

  -- All elements of L_no_psi are in box_theory(M), so their Box is in M
  have h_L_no_psi_box : ∀ x ∈ L_no_psi, Formula.box x ∈ M :=
    fun x hx => h_box_of_bt x (h_L_no_psi_bt x hx)

  -- Box-lift: from L_no_psi ⊢ neg(psi) and all Box(x) ∈ M for x ∈ L_no_psi,
  -- derive Box(neg(psi)) ∈ M.
  have h_box_neg_psi : Formula.box (Formula.neg psi) ∈ M := by
    -- Induction on context (same as box_lift_from_context from above)
    suffices h : ∀ (ctx : List Formula) (phi : Formula),
        DerivationTree ctx phi → (∀ x ∈ ctx, Formula.box x ∈ M) → Formula.box phi ∈ M by
      exact h L_no_psi (Formula.neg psi) d_neg_psi h_L_no_psi_box
    intro ctx phi d_ctx h_ctx_box
    induction ctx generalizing phi with
    | nil =>
      exact theorem_in_mcs h_mcs (DerivationTree.necessitation phi d_ctx)
    | cons a rest ih =>
      have d_imp := Bimodal.Metalogic.Core.deduction_theorem rest a phi d_ctx
      have h_rest_box := fun x hx => h_ctx_box x (List.mem_cons_of_mem a hx)
      have h_box_imp := ih (a.imp phi) d_imp h_rest_box
      have h_box_a := h_ctx_box a (List.mem_cons_self a rest)
      have h_K := DerivationTree.axiom [] _ (Axiom.modal_k_dist a phi)
      have h_imp_in_M := SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs h_K) h_box_imp
      exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_box_a

  -- But Diamond(psi) = neg(Box(neg(psi))) ∈ M
  exact diamond_excludes_box_neg h_mcs psi h_diamond h_box_neg_psi

/--
If Diamond(psi) is in MCS M, there exists MCS W with psi in W and same box theory.
-/
theorem box_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.diamond psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ psi ∈ W ∧ box_class_agree M W := by
  have h_cons := box_theory_witness_consistent M h_mcs psi h_diamond
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({psi} ∪ box_theory M) h_cons
  use W, h_W_mcs
  constructor
  · exact h_extends (Set.mem_union_left _ (Set.mem_singleton psi))
  · intro phi
    constructor
    · -- Box(phi) ∈ M → Box(phi) ∈ W
      intro h_box
      -- Box(phi) is in box_theory(M), so in the seed, so in W
      have : Formula.box phi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨phi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ this)
    · -- Box(phi) ∈ W → Box(phi) ∈ M
      intro h_box_W
      -- neg(Box(phi)) ∈ box_theory(M) if Box(phi) ∉ M
      by_contra h_not_in_M
      have : Formula.neg (Formula.box phi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨phi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box phi) ∈ W :=
        h_extends (Set.mem_union_right _ this)
      -- Box(phi) ∈ W and neg(Box(phi)) ∈ W contradicts W being MCS
      exact set_consistent_not_both h_W_mcs.1 (Formula.box phi) h_box_W h_neg_in_W

/-!
### Temporal Theory and Witness Consistency

Define G_theory (the "temporal theory" of an MCS) and prove witness consistency:
if F(phi) ∈ M (MCS), then {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent.

This is the temporal analog of box_theory_witness_consistent, using:
- temp_4: G(a) → G(G(a)) for G-lifting G_theory elements
- temp_future: Box(a) → G(Box(a)) for G-lifting box_theory elements
- temp_k_dist + temporal_necessitation for the G-lift induction

Unlike box_theory which has negative introspection (S5 axiom 5), the temporal
logic lacks neg(G(a)) → G(neg(G(a))). So we use only positive G-formulas
in G_theory, which is sufficient for the witness consistency proof.
-/

/--
The "G theory" of an MCS: the set of formulas whose G is in M.
G_theory(M) = {G(a) | G(a) ∈ M}

This contains the G-WRAPPED formulas, not the inner formulas.
Using G-wrapped formulas enables the G-lift argument via temp_4.

Note: Unlike box_theory which includes both positive and negative parts
(using S5 axiom 5), G_theory only has the positive part because the
temporal logic lacks negative introspection for G.
-/
def G_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_future a ∧ Formula.all_future a ∈ M }

/--
All elements of G_theory(M) are in M (trivially, since they ARE M's G-formulas).
-/
theorem G_theory_subset_mcs (M : Set Formula) :
    G_theory M ⊆ M := by
  intro f hf
  simp only [G_theory, Set.mem_setOf_eq] at hf
  obtain ⟨a, rfl, ha⟩ := hf
  exact ha

/--
Every element of G_theory(M) can be G-lifted: G(G(a)) ∈ M when G(a) ∈ M.
This uses temp_4: G(a) → G(G(a)).
-/
theorem G_of_G_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ G_theory M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [G_theory, Set.mem_setOf_eq] at hx
  obtain ⟨a, rfl, ha⟩ := hx
  -- Need G(G(a)) ∈ M. By temp_4: G(a) → G(G(a))
  have h_4 : [] ⊢ (Formula.all_future a).imp (Formula.all_future (Formula.all_future a)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 a)
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_4) ha

/--
Every element of box_theory(M) can be G-lifted: G(f) ∈ M for f ∈ box_theory(M).

- For Box(a) ∈ M: G(Box(a)) ∈ M by temp_future (Box(a) → G(Box(a)))
- For neg(Box(a)) with Box(a) ∉ M: neg(Box(a)) ∈ M (negation completeness),
  then Box(neg(Box(a))) ∈ M (S5 axiom 5), then G(Box(neg(Box(a)))) ∈ M (temp_future),
  then G(neg(Box(a))) ∈ M (by G distributing over Box-T: G(Box(x)) → G(x)).
-/
theorem G_of_box_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ box_theory M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [box_theory, Set.mem_setOf_eq] at hx
  rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · -- x = Box(a), Box(a) ∈ M. Need G(Box(a)) ∈ M.
    -- By temp_future: Box(a) → G(Box(a))
    have h_tf : [] ⊢ (Formula.box a).imp (Formula.all_future (Formula.box a)) :=
      DerivationTree.axiom [] _ (Axiom.temp_future a)
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_tf) ha
  · -- x = neg(Box(a)), Box(a) ∉ M. Need G(neg(Box(a))) ∈ M.
    -- Step 1: neg(Box(a)) ∈ M (negation completeness)
    have h_neg_box : (Formula.box a).neg ∈ M := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
      · exact absurd h ha
      · exact h
    -- Step 2: Box(neg(Box(a))) ∈ M (S5 axiom 5: neg(Box(a)) → Box(neg(Box(a))))
    have h_box_neg_box : Formula.box ((Formula.box a).neg) ∈ M :=
      SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box
    -- Step 3: G(Box(neg(Box(a)))) ∈ M (temp_future)
    have h_tf : [] ⊢ (Formula.box ((Formula.box a).neg)).imp
        (Formula.all_future (Formula.box ((Formula.box a).neg))) :=
      DerivationTree.axiom [] _ (Axiom.temp_future ((Formula.box a).neg))
    have h_G_box : Formula.all_future (Formula.box ((Formula.box a).neg)) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_tf) h_box_neg_box
    -- Step 4: G(neg(Box(a))) ∈ M via G(Box(x)) → G(x)
    -- Box(x) → x is modal_t. G(Box(x) → x) by temporal necessitation.
    -- G(Box(x) → x) → (G(Box(x)) → G(x)) by temp_k_dist.
    -- So [] ⊢ G(Box(x)).imp G(x). Then use implication_property.
    have h_box_t : [] ⊢ (Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t ((Formula.box a).neg))
    -- G(Box(x) → x) by temporal necessitation
    have h_G_box_t : [] ⊢ Formula.all_future ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)) :=
      DerivationTree.temporal_necessitation _ h_box_t
    -- G(A → B) → (G(A) → G(B)) by temp_k_dist
    have h_k : [] ⊢ (Formula.all_future ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg))).imp
        ((Formula.all_future (Formula.box ((Formula.box a).neg))).imp
         (Formula.all_future ((Formula.box a).neg))) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist (Formula.box ((Formula.box a).neg)) ((Formula.box a).neg))
    -- Combine via modus ponens: [] ⊢ G(Box(x)).imp G(x)
    have h_G_imp : [] ⊢ (Formula.all_future (Formula.box ((Formula.box a).neg))).imp
        (Formula.all_future ((Formula.box a).neg)) :=
      DerivationTree.modus_ponens [] _ _ h_k h_G_box_t
    -- Apply implication_property with h_G_box to get G(neg(Box(a))) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_G_imp) h_G_box

/--
The combined seed for temporal-modal witnesses: G_theory ∪ box_theory.
-/
def temporal_box_seed (M : Set Formula) : Set Formula :=
  G_theory M ∪ box_theory M

/--
Every element of the combined seed can be G-lifted.
-/
theorem G_of_temporal_box_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ temporal_box_seed M, Formula.all_future x ∈ M := by
  intro x hx
  simp only [temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact G_of_G_theory M h_mcs x h
  · exact G_of_box_theory M h_mcs x h

/--
The G-lift lemma for temporal theory: from a derivation using elements of
temporal_box_seed(M), derive the G-lift is in M.

If ctx ⊢ phi and all elements of ctx have their G in M, then G(phi) ∈ M.
-/
theorem G_lift_from_context (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ctx : List Formula) (phi : Formula)
    (h_deriv : DerivationTree ctx phi)
    (h_ctx_G : ∀ x ∈ ctx, Formula.all_future x ∈ M) :
    Formula.all_future phi ∈ M := by
  induction ctx generalizing phi with
  | nil =>
    exact theorem_in_mcs h_mcs (DerivationTree.temporal_necessitation phi h_deriv)
  | cons a rest ih =>
    have d_imp := Bimodal.Metalogic.Core.deduction_theorem rest a phi h_deriv
    have h_rest_G := fun x hx => h_ctx_G x (List.mem_cons_of_mem a hx)
    have h_G_imp := ih (a.imp phi) d_imp h_rest_G
    have h_G_a := h_ctx_G a (List.mem_cons_self a rest)
    have h_K := DerivationTree.axiom [] _ (Axiom.temp_k_dist a phi)
    have h_imp_in_M := SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_K) h_G_imp
    exact SetMaximalConsistent.implication_property h_mcs h_imp_in_M h_G_a

/--
F(phi) ∈ M excludes G(neg(phi)) from M.

Since F(phi) = neg(G(neg(phi))), having both F(phi) and G(neg(phi)) in M
would violate MCS consistency.
-/
theorem some_future_excludes_all_future_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Formula.all_future (Formula.neg phi) ∉ M := by
  intro h_G
  -- F(phi) = neg(G(neg(phi))) = phi.neg.all_future.neg
  -- So F(phi) and G(neg(phi)) = phi.neg.all_future
  -- F(phi) = (phi.neg.all_future).neg
  have h_eq : Formula.some_future phi = Formula.neg (Formula.all_future (Formula.neg phi)) := rfl
  rw [h_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future (Formula.neg phi)) h_G h_F

/--
The temporal theory witness consistency lemma:
If F(phi) ∈ M (MCS), then {phi} ∪ G_theory(M) ∪ box_theory(M) is consistent.

**Proof**: Suppose inconsistent. Then finite L ⊆ {phi} ∪ G_theory(M) ∪ box_theory(M)
with L ⊢ bot. By deduction theorem: L_rest ⊢ neg(phi) where
L_rest ⊆ G_theory(M) ∪ box_theory(M). By G_lift_from_context: G(neg(phi)) ∈ M.
But F(phi) = neg(G(neg(phi))) ∈ M, contradiction.
-/
theorem temporal_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetConsistent ({phi} ∪ temporal_box_seed M) := by
  intro L h_L_sub ⟨d⟩
  -- Filter L into phi-part and seed part
  let L_no_phi := L.filter (· ≠ phi)

  have h_L_no_phi_seed : ∀ x ∈ L_no_phi, x ∈ temporal_box_seed M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ phi := by
      simp only [List.mem_filter, ne_eq, decide_eq_true_eq] at hx
      exact hx.2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_phi_Lnp : ∀ x ∈ L, x ∈ phi :: L_no_phi := by
    intro x hx
    by_cases h_eq : x = phi
    · rw [h_eq]; exact List.mem_cons_self phi L_no_phi
    · exact List.mem_cons_of_mem phi (List.mem_filter.mpr ⟨hx, h_eq⟩)

  have d_weak : DerivationTree (phi :: L_no_phi) Formula.bot :=
    DerivationTree.weakening L (phi :: L_no_phi) Formula.bot d h_L_sub_phi_Lnp

  have d_neg_phi : DerivationTree L_no_phi (Formula.neg phi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi Formula.bot d_weak

  -- All elements of L_no_phi are in temporal_box_seed(M), so their G is in M
  have h_L_no_phi_G : ∀ x ∈ L_no_phi, Formula.all_future x ∈ M :=
    fun x hx => G_of_temporal_box_seed M h_mcs x (h_L_no_phi_seed x hx)

  -- G-lift: from L_no_phi ⊢ neg(phi) and all G(x) ∈ M for x ∈ L_no_phi,
  -- derive G(neg(phi)) ∈ M.
  have h_G_neg_phi : Formula.all_future (Formula.neg phi) ∈ M :=
    G_lift_from_context M h_mcs L_no_phi (Formula.neg phi) d_neg_phi h_L_no_phi_G

  -- But F(phi) = neg(G(neg(phi))) ∈ M
  exact some_future_excludes_all_future_neg h_mcs phi h_F h_G_neg_phi

/--
If F(phi) ∈ M (MCS), there exists MCS W with phi ∈ W,
G_theory agreement (G(a) ∈ M → G(a) ∈ W), and box_class_agree(M, W).
-/
theorem temporal_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_future a ∈ M → Formula.all_future a ∈ W) ∧
      box_class_agree M W := by
  have h_cons := temporal_theory_witness_consistent M h_mcs phi h_F
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({phi} ∪ temporal_box_seed M) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_⟩
  · -- phi ∈ W
    exact h_extends (Set.mem_union_left _ (Set.mem_singleton phi))
  · -- G_theory agreement: G(a) ∈ M → G(a) ∈ W
    intro a ha
    have : Formula.all_future a ∈ G_theory M := by
      simp only [G_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (Set.mem_union_right _ (Set.mem_union_left _ this))
  · -- box_class_agree M W (same as in box_theory_witness_exists)
    intro psi
    constructor
    · intro h_box
      have : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
    · intro h_box_W
      by_contra h_not_in_M
      have : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

/-!
### H_theory and Past Direction Witness

Symmetric to G_theory for the past direction. If P(phi) ∈ M (MCS), then
{phi} ∪ H_theory(M) ∪ box_theory(M) is consistent.
-/

/--
The "H theory" of an MCS: the set of formulas whose H is in M.
H_theory(M) = {H(a) | H(a) ∈ M}
-/
def H_theory (M : Set Formula) : Set Formula :=
  { f | ∃ a, f = Formula.all_past a ∧ Formula.all_past a ∈ M }

/--
All elements of H_theory(M) are in M.
-/
theorem H_theory_subset_mcs (M : Set Formula) :
    H_theory M ⊆ M := by
  intro f hf
  simp only [H_theory, Set.mem_setOf_eq] at hf
  obtain ⟨a, rfl, ha⟩ := hf
  exact ha

/--
P(phi) ∈ M excludes H(neg(phi)) from M.
-/
theorem some_past_excludes_all_past_neg {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    Formula.all_past (Formula.neg phi) ∉ M := by
  intro h_H
  have h_eq : Formula.some_past phi = Formula.neg (Formula.all_past (Formula.neg phi)) := rfl
  rw [h_eq] at h_P
  exact set_consistent_not_both h_mcs.1 (Formula.all_past (Formula.neg phi)) h_H h_P

/--
The combined seed for past-direction witnesses: H_theory ∪ box_theory.
-/
def past_temporal_box_seed (M : Set Formula) : Set Formula :=
  H_theory M ∪ box_theory M

/--
Past temp_4: H(a) → H(H(a)), derived via temporal duality from temp_4.
-/
private noncomputable def past_temp_4 (a : Formula) :
    [] ⊢ (Formula.all_past a).imp (Formula.all_past (Formula.all_past a)) := by
  have h_4 := DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.swap_temporal a))
  have h_dual := DerivationTree.temporal_duality _ h_4
  simp [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/--
Past temp_future: Box(a) → H(Box(a)), derived via temporal duality from temp_future.
-/
private noncomputable def past_temp_future (a : Formula) :
    [] ⊢ (Formula.box a).imp (Formula.all_past (Formula.box a)) := by
  have h_tf := DerivationTree.axiom [] _ (Axiom.temp_future (Formula.swap_temporal a))
  have h_dual := DerivationTree.temporal_duality _ h_tf
  simp [Formula.swap_temporal, Formula.swap_temporal_involution] at h_dual
  exact h_dual

/--
Every element of H_theory(M) can be H-lifted: H(H(a)) ∈ M when H(a) ∈ M.
-/
theorem H_of_H_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ H_theory M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [H_theory, Set.mem_setOf_eq] at hx
  obtain ⟨a, rfl, ha⟩ := hx
  exact SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (past_temp_4 a)) ha

/--
Every element of box_theory(M) can be H-lifted: H(f) ∈ M for f ∈ box_theory(M).

Symmetric to G_of_box_theory, using past_temp_future and past K-distribution.
-/
theorem H_of_box_theory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ box_theory M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [box_theory, Set.mem_setOf_eq] at hx
  rcases hx with ⟨a, rfl, ha⟩ | ⟨a, rfl, ha⟩
  · -- x = Box(a), Box(a) ∈ M. Need H(Box(a)) ∈ M.
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (past_temp_future a)) ha
  · -- x = neg(Box(a)), Box(a) ∉ M. Need H(neg(Box(a))) ∈ M.
    have h_neg_box : (Formula.box a).neg ∈ M := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box a) with h | h
      · exact absurd h ha
      · exact h
    have h_box_neg_box : Formula.box ((Formula.box a).neg) ∈ M :=
      SetMaximalConsistent.neg_box_implies_box_neg_box h_mcs a h_neg_box
    -- H(Box(neg(Box(a)))) ∈ M by past_temp_future
    have h_H_box : Formula.all_past (Formula.box ((Formula.box a).neg)) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (theorem_in_mcs h_mcs (past_temp_future ((Formula.box a).neg))) h_box_neg_box
    -- H(neg(Box(a))) ∈ M via H(Box(x)) → H(x)
    -- Box(x) → x is modal_t. H(Box(x) → x) by past necessitation (temporal duality).
    -- H(Box(x) → x) → (H(Box(x)) → H(x)) by past K-distribution.
    have h_box_t : [] ⊢ (Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg) :=
      DerivationTree.axiom [] _ (Axiom.modal_t ((Formula.box a).neg))
    -- H(Box(x) → x) via past necessitation (temporal duality of temporal necessitation)
    have h_H_box_t_deriv : [(Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)] ⊢
        Formula.all_past ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)) := by
      exact Bimodal.Theorems.generalized_past_k
        [(Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)]
        _ (DerivationTree.assumption _ _ (by simp))
    -- Actually use the empty context version
    have h_H_box_t : [] ⊢ Formula.all_past ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)) := by
      have h_mapped : (Context.map Formula.all_past []) ⊢ ((Formula.box ((Formula.box a).neg)).imp ((Formula.box a).neg)).all_past :=
        Bimodal.Theorems.generalized_past_k [] _ h_box_t
      simp [Context.map] at h_mapped
      exact h_mapped
    -- past K-distribution: H(A → B) → (H(A) → H(B))
    have h_pk := Bimodal.Theorems.past_k_dist (Formula.box ((Formula.box a).neg)) ((Formula.box a).neg)
    -- Combine: H(Box(neg(Box(a)))) → H(neg(Box(a)))
    have h_H_imp : [] ⊢ (Formula.all_past (Formula.box ((Formula.box a).neg))).imp
        (Formula.all_past ((Formula.box a).neg)) :=
      DerivationTree.modus_ponens [] _ _ h_pk h_H_box_t
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs h_H_imp) h_H_box

/--
Every element of the past combined seed can be H-lifted.
-/
theorem H_of_past_temporal_box_seed (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∀ x ∈ past_temporal_box_seed M, Formula.all_past x ∈ M := by
  intro x hx
  simp only [past_temporal_box_seed, Set.mem_union] at hx
  rcases hx with h | h
  · exact H_of_H_theory M h_mcs x h
  · exact H_of_box_theory M h_mcs x h

/--
The H-lift lemma: from ctx ⊢ phi and all H(x) ∈ M for x ∈ ctx, derive H(phi) ∈ M.
Symmetric to G_lift_from_context.
-/
theorem H_lift_from_context (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (ctx : List Formula) (phi : Formula)
    (h_deriv : DerivationTree ctx phi)
    (h_ctx_H : ∀ x ∈ ctx, Formula.all_past x ∈ M) :
    Formula.all_past phi ∈ M := by
  -- Use generalized_past_k: Γ ⊢ φ implies H[Γ] ⊢ H(φ)
  have h_H_deriv := Bimodal.Theorems.generalized_past_k ctx phi h_deriv
  -- H[ctx] ⊢ H(phi). Need all H[ctx] elements in M, then H(phi) ∈ M.
  have h_H_ctx_in_M : ∀ x ∈ Context.map Formula.all_past ctx, x ∈ M := by
    intro x hx
    simp [Context.map, List.mem_map] at hx
    obtain ⟨y, hy_mem, rfl⟩ := hx
    exact h_ctx_H y hy_mem
  exact SetMaximalConsistent.closed_under_derivation h_mcs
    (Context.map Formula.all_past ctx) h_H_ctx_in_M h_H_deriv

/--
The past temporal theory witness consistency:
If P(phi) ∈ M (MCS), then {phi} ∪ H_theory(M) ∪ box_theory(M) is consistent.

The proof is symmetric to temporal_theory_witness_consistent, using H-lift.
-/
theorem past_theory_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    SetConsistent ({phi} ∪ past_temporal_box_seed M) := by
  intro L h_L_sub ⟨d⟩
  let L_no_phi := L.filter (· ≠ phi)

  have h_L_no_phi_seed : ∀ x ∈ L_no_phi, x ∈ past_temporal_box_seed M := by
    intro x hx
    have hx_L := List.mem_of_mem_filter hx
    have hx_ne : x ≠ phi := by
      simp only [List.mem_filter, ne_eq, decide_eq_true_eq] at hx
      exact hx.2
    have := h_L_sub x hx_L
    simp only [Set.mem_union, Set.mem_singleton_iff] at this
    rcases this with h | h
    · rw [h] at hx_ne; exact absurd rfl hx_ne
    · exact h

  have h_L_sub_phi_Lnp : ∀ x ∈ L, x ∈ phi :: L_no_phi := by
    intro x hx
    by_cases h_eq : x = phi
    · rw [h_eq]; exact List.mem_cons_self phi L_no_phi
    · exact List.mem_cons_of_mem phi (List.mem_filter.mpr ⟨hx, h_eq⟩)

  have d_weak : DerivationTree (phi :: L_no_phi) Formula.bot :=
    DerivationTree.weakening L (phi :: L_no_phi) Formula.bot d h_L_sub_phi_Lnp

  have d_neg_phi : DerivationTree L_no_phi (Formula.neg phi) :=
    Bimodal.Metalogic.Core.deduction_theorem L_no_phi phi Formula.bot d_weak

  have h_L_no_phi_H : ∀ x ∈ L_no_phi, Formula.all_past x ∈ M :=
    fun x hx => H_of_past_temporal_box_seed M h_mcs x (h_L_no_phi_seed x hx)

  have h_H_neg_phi : Formula.all_past (Formula.neg phi) ∈ M :=
    H_lift_from_context M h_mcs L_no_phi (Formula.neg phi) d_neg_phi h_L_no_phi_H

  exact some_past_excludes_all_past_neg h_mcs phi h_P h_H_neg_phi

/--
If P(phi) ∈ M (MCS), there exists MCS W with phi ∈ W,
H_theory agreement (H(a) ∈ M → H(a) ∈ W), and box_class_agree(M, W).
-/
theorem past_theory_witness_exists (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
      (∀ a, Formula.all_past a ∈ M → Formula.all_past a ∈ W) ∧
      box_class_agree M W := by
  have h_cons := past_theory_witness_consistent M h_mcs phi h_P
  obtain ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum ({phi} ∪ past_temporal_box_seed M) h_cons
  use W, h_W_mcs
  refine ⟨?_, ?_, ?_⟩
  · exact h_extends (Set.mem_union_left _ (Set.mem_singleton phi))
  · intro a ha
    have : Formula.all_past a ∈ H_theory M := by
      simp only [H_theory, Set.mem_setOf_eq]
      exact ⟨a, rfl, ha⟩
    exact h_extends (Set.mem_union_right _ (Set.mem_union_left _ this))
  · intro psi
    constructor
    · intro h_box
      have : Formula.box psi ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inl ⟨psi, rfl, h_box⟩
      exact h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
    · intro h_box_W
      by_contra h_not_in_M
      have : Formula.neg (Formula.box psi) ∈ box_theory M := by
        simp only [box_theory, Set.mem_setOf_eq]
        exact Or.inr ⟨psi, rfl, h_not_in_M⟩
      have h_neg_in_W : Formula.neg (Formula.box psi) ∈ W :=
        h_extends (Set.mem_union_right _ (Set.mem_union_right _ this))
      exact set_consistent_not_both h_W_mcs.1 (Formula.box psi) h_box_W h_neg_in_W

/-!
### Phase 3: Box-Class Bundle Construction

Build a BFMCS from the box-class of an MCS using shifted SuccChainFMCS.
-/

/--
The bundle families: all shifted SuccChainFMCS from MCSes with the same box theory.
-/
noncomputable def boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k }

/--
The bundle is nonempty (contains the eval chain from M0 at offset 0).
-/
theorem boxClassFamilies_nonempty (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    (boxClassFamilies M0 h_mcs).Nonempty := by
  use SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs)
  simp only [boxClassFamilies, Set.mem_setOf_eq]
  exact ⟨M0, h_mcs, 0, box_class_agree_refl M0, by
    unfold shifted_fmcs; congr; ext t; simp⟩

/--
The eval family (unshifted chain from M0) is in the bundle.
-/
theorem eval_family_mem_boxClassFamilies (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    SuccChainFMCS (MCS_to_SerialMCS M0 h_mcs) ∈ boxClassFamilies M0 h_mcs := by
  simp only [boxClassFamilies, Set.mem_setOf_eq]
  exact ⟨M0, h_mcs, 0, box_class_agree_refl M0, by
    unfold shifted_fmcs; congr; ext t; simp⟩

/-!
### Phase 4: Modal Coherence Proofs

Prove modal_forward, modal saturation, and temporal coherence for the bundle.
-/

/--
Modal forward: Box(phi) in any family's MCS at time t implies phi in ALL families' MCSes at t.

Proof: Box(phi) in fam.mcs(t) → Box(phi) in fam.mcs(0-shifted-base) (by persistence)
→ Box(phi) in base MCS W → Box(phi) in M0 (by box class) → Box(phi) in any W'
→ Box(phi) in fam'.mcs(t) (by persistence) → phi in fam'.mcs(t) (by T).
-/
theorem boxClassFamilies_modal_forward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int) (h_box : Formula.box phi ∈ fam.mcs t)
    (fam' : FMCS Int) (hfam' : fam' ∈ boxClassFamilies M0 h_mcs) :
    phi ∈ fam'.mcs t := by
  -- Extract fam's components
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  -- Extract fam's components
  obtain ⟨W', h_W', k', h_agree', rfl⟩ := hfam'

  -- Box(phi) in shifted_fmcs at t = Box(phi) in SuccChainFMCS at (t - k)
  unfold shifted_fmcs at h_box ⊢
  simp only at h_box ⊢

  -- Box(phi) is persistent: in SuccChainFMCS(W) at (t-k) → at 0
  have h_box_0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 :=
    parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi (t - k) 0 h_box

  -- SuccChainFMCS(W).mcs 0 = W (the base MCS)
  have h_mcs_0 : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
    unfold SuccChainFMCS MCS_to_SerialMCS
    exact succ_chain_fam_zero _

  -- Box(phi) ∈ W
  rw [h_mcs_0] at h_box_0

  -- Box(phi) ∈ M0 (by box class agreement: M0 ↔ W)
  have h_box_M0 : Formula.box phi ∈ M0 := (h_agree phi).mpr h_box_0

  -- Box(phi) ∈ W' (by box class agreement: M0 ↔ W')
  have h_box_W' : Formula.box phi ∈ W' := (h_agree' phi).mp h_box_M0

  -- SuccChainFMCS(W').mcs 0 = W'
  have h_mcs_0' : (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs 0 = W' := by
    unfold SuccChainFMCS MCS_to_SerialMCS
    exact succ_chain_fam_zero _

  -- Box(phi) ∈ SuccChainFMCS(W').mcs 0
  have h_box_0' : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs 0 := by
    rw [h_mcs_0']; exact h_box_W'

  -- Box(phi) ∈ SuccChainFMCS(W').mcs (t - k') (by persistence)
  have h_box_t' : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).mcs (t - k') :=
    parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W' h_W')) phi 0 (t - k') h_box_0'

  -- phi ∈ SuccChainFMCS(W').mcs (t - k') by T axiom
  have h_mcs_t' := (SuccChainFMCS (MCS_to_SerialMCS W' h_W')).is_mcs (t - k')
  have h_T : [] ⊢ (Formula.box phi).imp phi := DerivationTree.axiom [] _ (Axiom.modal_t phi)
  exact SetMaximalConsistent.implication_property h_mcs_t' (theorem_in_mcs h_mcs_t' h_T) h_box_t'

/--
Box-formulas at any time t in any family in the bundle agree with M0.
-/
theorem boxClassFamilies_box_agree (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int) :
    Formula.box phi ∈ fam.mcs t ↔ Formula.box phi ∈ M0 := by
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  unfold shifted_fmcs
  simp only
  constructor
  · intro h =>
    have h0 := parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi (t - k) 0 h
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; exact succ_chain_fam_zero _
    rw [h_eq] at h0
    exact (h_agree phi).mpr h0
  · intro h =>
    have h_W := (h_agree phi).mp h
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; exact succ_chain_fam_zero _
    have h0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 := by
      rw [h_eq]; exact h_W
    exact parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi 0 (t - k) h0

/--
Modal backward: if phi is in ALL families' MCSes at time t, then Box(phi) is in fam.mcs(t).

Proof by contraposition using box_theory_witness_exists:
1. If Box(phi) not in fam.mcs(t), then neg(Box(phi)) in fam.mcs(t)
2. By box-class agreement: neg(Box(phi)) in M0 (since neg(Box) is a box-theory formula)
3. Diamond(neg(phi)) in M0 (derived from neg(Box(phi)) via double negation)
4. By witness existence: exists W' with neg(phi) in W' and box_class_agree(M0, W')
5. The shifted chain from W' at time t is in the bundle
6. neg(phi) is in that chain's MCS at time t
7. But phi is in ALL families, contradiction
-/
theorem boxClassFamilies_modal_backward (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (phi : Formula) (t : Int)
    (h_all : ∀ fam' ∈ boxClassFamilies M0 h_mcs, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t := by
  -- By contradiction
  by_contra h_not_box

  -- Step 1: neg(Box(phi)) in fam.mcs(t)
  obtain ⟨W, h_W, k, h_agree, rfl⟩ := hfam
  unfold shifted_fmcs at h_not_box ⊢
  simp only at h_not_box ⊢
  have h_mcs_t := (SuccChainFMCS (MCS_to_SerialMCS W h_W)).is_mcs (t - k)
  have h_neg_box : Formula.neg (Formula.box phi) ∈
      (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs (t - k) := by
    rcases SetMaximalConsistent.negation_complete h_mcs_t (Formula.box phi) with h | h
    · exact absurd h h_not_box
    · exact h

  -- Step 2: neg(Box(phi)) in M0 (via box-class)
  -- neg(Box(phi)) = (Box phi).neg
  -- Box(phi) not in fam.mcs(t), so Box(phi) not in W (by box persistence)
  have h_box_not_W : Formula.box phi ∉ W := by
    intro h_in_W
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 = W := by
      unfold SuccChainFMCS MCS_to_SerialMCS; exact succ_chain_fam_zero _
    have h0 : Formula.box phi ∈ (SuccChainFMCS (MCS_to_SerialMCS W h_W)).mcs 0 := by
      rw [h_eq]; exact h_in_W
    exact h_not_box (parametric_box_persistent (SuccChainFMCS (MCS_to_SerialMCS W h_W)) phi 0 (t - k) h0)

  -- Box(phi) not in M0 (by box class)
  have h_box_not_M0 : Formula.box phi ∉ M0 := by
    intro h; exact h_box_not_W ((h_agree phi).mp h)

  -- neg(Box(phi)) in M0
  have h_neg_box_M0 : (Formula.box phi).neg ∈ M0 := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box phi) with h | h
    · exact absurd h h_box_not_M0
    · exact h

  -- Step 3: Diamond(neg(phi)) in M0
  -- neg(Box(phi)) = neg(Box(phi))
  -- By Box DNE contraposition: neg(Box(phi)) implies neg(Box(neg(neg(phi)))) = Diamond(neg(phi))
  -- Actually: Diamond(neg(phi)) = neg(Box(neg(neg(phi)))) = neg(Box(phi)) composed with DNE
  -- But Diamond(A) = A.neg.box.neg = neg(Box(neg(A)))
  -- So Diamond(neg(phi)) = neg(Box(neg(neg(phi))))
  -- And neg(Box(phi)) is what we have.
  -- We need: neg(Box(phi)) implies Diamond(neg(phi))
  -- i.e., neg(Box(phi)) implies neg(Box(neg(neg(phi))))
  -- By contraposition of Box(neg(neg(phi))) -> Box(phi) (which is box_dne_theorem)
  have h_diamond_neg : (Formula.neg phi).diamond ∈ M0 := by
    -- Diamond(neg phi) = neg(Box(neg(neg phi)))
    -- = (neg phi).neg.box.neg
    -- We have neg(Box phi) in M0
    -- Need neg(Box(neg(neg phi))) in M0
    -- By box_dne_theorem: Box(neg(neg phi)) -> Box(phi)
    -- Contrapositive: neg(Box(phi)) -> neg(Box(neg(neg phi)))
    have h_bde := box_dne_theorem phi
    have h_contra := SetMaximalConsistent.contrapositive h_mcs h_bde h_neg_box_M0
    -- h_contra : (Formula.box (Formula.neg (Formula.neg phi))).neg ∈ M0
    -- Diamond(neg phi) = (neg phi).diamond = (neg phi).neg.box.neg
    --                   = phi.box.neg... no wait
    -- (neg phi).diamond = ((neg phi).neg).box.neg = (phi.neg.neg).box.neg... no
    -- Formula.diamond A = A.neg.box.neg = neg(Box(neg A))
    -- So (neg phi).diamond = ((neg phi).neg).box.neg = ...
    -- (neg phi).neg = Formula.neg (Formula.neg phi) = phi → ⊥ → ⊥... syntactically
    -- Actually: (Formula.neg phi).diamond = (Formula.neg phi).neg.box.neg
    --         = Formula.neg (Formula.box (Formula.neg (Formula.neg phi)))
    -- This is exactly what h_contra gives us!
    have h_eq : (Formula.neg phi).diamond =
                Formula.neg (Formula.box (Formula.neg (Formula.neg phi))) := rfl
    rw [h_eq]
    exact h_contra

  -- Step 4: By witness existence, get W' with neg(phi) in W' and same box class
  obtain ⟨W', h_W'_mcs, h_neg_phi_W', h_agree'⟩ :=
    box_theory_witness_exists M0 h_mcs (Formula.neg phi) h_diamond_neg

  -- Step 5: Build shifted chain from W' at time t
  let witness_fam := shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)) t

  -- This family is in the bundle
  have h_witness_in : witness_fam ∈ boxClassFamilies M0 h_mcs := by
    simp only [boxClassFamilies, Set.mem_setOf_eq]
    exact ⟨W', h_W'_mcs, t, h_agree', rfl⟩

  -- Step 6: neg(phi) is in witness_fam.mcs(t)
  have h_neg_phi_at_t : Formula.neg phi ∈ witness_fam.mcs t := by
    unfold_let witness_fam
    unfold shifted_fmcs
    simp only
    -- (t - t) = 0, so mcs 0 = W'
    have h_eq : (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs (t - t) =
                (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs 0 := by ring_nf
    rw [h_eq]
    have h_mcs0 : (SuccChainFMCS (MCS_to_SerialMCS W' h_W'_mcs)).mcs 0 = W' := by
      unfold SuccChainFMCS MCS_to_SerialMCS; exact succ_chain_fam_zero _
    rw [h_mcs0]
    exact h_neg_phi_W'

  -- Step 7: phi is in ALL families at time t, including witness_fam
  have h_phi_at_t : phi ∈ witness_fam.mcs t := h_all witness_fam h_witness_in

  -- Step 8: Contradiction
  have h_mcs_witness := witness_fam.is_mcs t
  exact set_consistent_not_both h_mcs_witness.1 phi h_phi_at_t h_neg_phi_at_t

/--
Temporal coherence: all families in the bundle satisfy forward_F and backward_P.
-/
theorem boxClassFamilies_temporally_coherent (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    ∀ fam ∈ boxClassFamilies M0 h_mcs,
      (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
      (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s) := by
  intro fam hfam
  obtain ⟨W, h_W, k, _, rfl⟩ := hfam
  let tcf := SuccChainTemporalCoherent (MCS_to_SerialMCS W h_W)
  constructor
  · exact shifted_temporal_forward_F (SuccChainFMCS (MCS_to_SerialMCS W h_W))
      tcf.forward_F k
  · exact shifted_temporal_backward_P (SuccChainFMCS (MCS_to_SerialMCS W h_W))
      tcf.backward_P k

/-!
### Phase 5: construct_bfmcs

Wire everything together into the signature required by ParametricRepresentation.
-/

/--
The main construction: given an MCS M, produce a temporally coherent BFMCS containing M.
-/
set_option maxHeartbeats 800000 in
noncomputable def construct_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
       (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
       M = fam.mcs t := by
  -- Build the BFMCS
  let B : BFMCS Int := {
    families := boxClassFamilies M h_mcs
    nonempty := boxClassFamilies_nonempty M h_mcs
    modal_forward := boxClassFamilies_modal_forward M h_mcs
    modal_backward := boxClassFamilies_modal_backward M h_mcs
    eval_family := SuccChainFMCS (MCS_to_SerialMCS M h_mcs)
    eval_family_mem := eval_family_mem_boxClassFamilies M h_mcs
  }
  -- Temporal coherence
  have h_tc : B.temporally_coherent := by
    intro fam hfam
    exact boxClassFamilies_temporally_coherent M h_mcs fam hfam
  -- The eval family
  let fam := SuccChainFMCS (MCS_to_SerialMCS M h_mcs)
  have hfam : fam ∈ B.families := eval_family_mem_boxClassFamilies M h_mcs
  -- M = fam.mcs 0
  have h_eq : M = fam.mcs 0 := by
    unfold_let fam
    unfold SuccChainFMCS MCS_to_SerialMCS
    exact (succ_chain_fam_zero _).symm
  exact ⟨B, h_tc, fam, hfam, 0, h_eq⟩

end Bimodal.Metalogic.Algebraic.UltrafilterChain
