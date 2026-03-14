import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Syntax.Formula

/-!
# Canonical Construction: Direct TruthLemma at TaskFrame Level

This module defines the canonical TaskFrame, TaskModel, world-histories, and Omega
for the direct TruthLemma connecting MCS membership to standard `truth_at` evaluation.

## Key Insight (research-006)

The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally
identical to `truth_at` when canonical definitions are chosen correctly. Therefore
we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate.

## Definitions

- `CanonicalWorldState`: Subtype of MCS (maximal consistent sets)
- `CanonicalTaskFrame`: TaskFrame Int with semantically meaningful task_rel
- `CanonicalTaskModel`: TaskModel with valuation = MCS membership
- `to_history`: Convert FMCS to WorldHistory
- `CanonicalOmega`: Set of world-histories from bundle families

## Task Relation Design

The canonical task relation captures the temporal ordering between MCSs:

- **Positive duration** (d > 0): GContent M ⊆ N (M sees N in the future)
- **Negative duration** (d < 0): HContent N ⊆ M (N sees M in the past)
- **Zero duration** (d = 0): vacuously true (no condition imposed)

This is the MOST semantically meaningful task_rel possible on MCS pairs under
irreflexive semantics (where the T-axiom G(φ) → φ is unsound). The d = 0 case
uses vacuous truth because GContent M ⊆ M would require the T-axiom.

### Compositionality

Same-sign compositionality follows from transitivity of CanonicalR (using temp_4:
G(φ) → G(G(φ))) and HContent chains (using temp_4_past: H(φ) → H(H(φ))).

Mixed-sign compositionality uses the interplay between CanonicalR and CanonicalR_past
established by temp_a (φ → G(P(φ))) and its past dual:
- CanonicalR M N → CanonicalR_past N M (Goldblatt 1992, §3.6)
- CanonicalR_past M N → CanonicalR N M (symmetric argument)

### Relationship to DurationTransfer

The fully algebraic task relation (w + d = w', with WorldState = D) is constructed
separately in `DurationTransfer.canonicalTaskFrame`. That construction achieves
compositionality via `add_assoc` on the group structure, requiring WorldState = D.

The task_rel defined here is WEAKER but more informative: it captures the
GContent/HContent temporal relationships directly, at the cost of sorry-dependent
interplay lemmas that require formalization of temp_a-based derivations.

## Main Result

```
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

## References

- Task 945: Design canonical model construction for TruthLemma
- research-005.md: Step-by-step construction, D=Z
- research-006.md: Direct TruthLemma, bmcs_truth_at redundancy
- Goldblatt 1992, Logics of Time and Computation, §3.6
-/

namespace Bimodal.Metalogic.Bundle.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics

/-!
## Phase 1: Canonical Structures
-/

/--
Canonical world state: a maximal consistent set packaged as a subtype.

This is the WorldState of the canonical TaskFrame.
-/
def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

/--
Canonical task relation between world states: temporal content inclusion.

The task relation captures the canonical temporal ordering between MCSs:
- **d > 0** (future): GContent M ⊆ N — all G-formulas of M are satisfied at N
- **d < 0** (past): HContent N ⊆ M — all H-formulas of N are satisfied at M
- **d = 0**: vacuously true (no condition imposed)

**Why d = 0 is vacuous**: The natural condition for d = 0 would be M = N or
GContent M ⊆ M, but the latter requires the temporal T-axiom (G(φ) → φ),
which is NOT sound under irreflexive semantics where G quantifies over
strictly future times (t < s, not t ≤ s). The vacuous condition at d = 0
preserves nullity while honestly reflecting this limitation.

**Semantic content**: For positive durations, the relation says exactly that
N can serve as a "future world" of M in the canonical frame (CanonicalR).
For negative durations, it says M can serve as a "past world" of N.
This directly mirrors the evaluation of G and H operators in the truth lemma.

**Note on WorldHistory type restriction**: Unlike the trivial `True` relation,
this task_rel meaningfully restricts which functions qualify as WorldHistories.
A history must satisfy: for s ≤ t, the state at t is a CanonicalR-successor
of the state at s (when t - s > 0). This eliminates histories that make
arbitrary jumps between unrelated MCSs.
-/
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  (d > 0 → CanonicalR M.val N.val) ∧ (d < 0 → HContent N.val ⊆ M.val)

/--
Nullity: for duration d = 0, the canonical task relation holds trivially.

Since 0 > 0 and 0 < 0 are both false, both implications in canonical_task_rel
are vacuously true. This avoids the T-axiom obstruction entirely.
-/
theorem canonical_task_rel_nullity (M : CanonicalWorldState) :
    canonical_task_rel M 0 M := by
  constructor
  · intro h; exact absurd h (by omega)
  · intro h; exact absurd h (by omega)

/--
Compositionality: sequential canonical task relations compose.

Given task_rel M x U and task_rel U y V, we derive task_rel M (x + y) V.

The proof splits by signs of x, y, and x + y:
- **Same-sign positive** (x > 0, y > 0, x + y > 0): Uses CanonicalR transitivity
  (canonicalR_transitive, which relies on temp_4: G(φ) → G(G(φ))).
- **Same-sign negative** (x < 0, y < 0, x + y < 0): Uses HContent chain transitivity
  (HContent_chain_transitive, which relies on temp_4_past: H(φ) → H(H(φ))).
- **Mixed signs**: Uses the interplay lemmas (canonicalR_implies_past_reverse,
  canonicalR_past_implies_forward_reverse) to convert between CanonicalR and
  CanonicalR_past, then chains with transitivity.
- **Sum = 0**: Both implications vacuously true.
-/
theorem canonical_task_rel_compositionality
    (M U V : CanonicalWorldState) (x y : Int)
    (h1 : canonical_task_rel M x U) (h2 : canonical_task_rel U y V) :
    canonical_task_rel M (x + y) V := by
  obtain ⟨h1_pos, h1_neg⟩ := h1
  obtain ⟨h2_pos, h2_neg⟩ := h2
  constructor
  · -- Need: x + y > 0 → CanonicalR M.val V.val
    intro h_sum_pos
    -- We need GContent M.val ⊆ V.val
    -- Strategy: get CanonicalR M U and CanonicalR U V, then chain
    by_cases hx : x > 0
    · -- x > 0
      have hR_MU : CanonicalR M.val U.val := h1_pos hx
      by_cases hy : y > 0
      · -- x > 0, y > 0 → both forward, chain via transitivity
        have hR_UV : CanonicalR U.val V.val := h2_pos hy
        exact canonicalR_transitive M.val U.val V.val M.property hR_MU hR_UV
      · -- x > 0, y ≤ 0 → forward then backward/neutral
        by_cases hy_neg : y < 0
        · -- x > 0, y < 0, x + y > 0
          -- HContent V ⊆ U from h2_neg
          have hH_VU : HContent V.val ⊆ U.val := h2_neg hy_neg
          -- CanonicalR_past V U → CanonicalR U V (by interplay lemma)
          have hR_UV := canonicalR_past_implies_forward_reverse V.val U.val
            V.property U.property hH_VU
          exact canonicalR_transitive M.val U.val V.val M.property hR_MU hR_UV
        · -- x > 0, y = 0 → x + y = x > 0
          -- y = 0, so task_rel U 0 V is vacuously true (gives no info about U-V)
          -- But x + y = x > 0 and we need CanonicalR M V
          -- From h2 with y = 0: both branches vacuous, so we know nothing about U-V
          -- However, y = 0 means y ≤ 0 ∧ ¬(y < 0), so y = 0
          have hy_eq : y = 0 := by omega
          subst hy_eq
          simp at h_sum_pos
          -- x + 0 > 0 → x > 0, and we need CanonicalR M.val V.val
          -- With y = 0, compositionality should give task_rel M x V
          -- But we don't know the M-V relationship directly
          -- The issue: task_rel U 0 V is vacuous (gives nothing about U-V relation)
          -- This case requires: GContent M ⊆ U and "U and V are related by d=0"
          -- Since d=0 is vacuous, we cannot conclude GContent M ⊆ V
          -- This is a genuine limitation of the vacuous d=0 definition.
          -- With the full group structure (DurationTransfer), this is resolved by
          -- the fact that d=0 forces U=V (since w + 0 = w).
          sorry
    · -- x ≤ 0
      by_cases hx_neg : x < 0
      · -- x < 0, y must be > 0 (since x + y > 0 and x < 0)
        have hy : y > 0 := by omega
        have hH_UM : HContent U.val ⊆ M.val := h1_neg hx_neg
        have hR_UV : CanonicalR U.val V.val := h2_pos hy
        -- HContent U ⊆ M → CanonicalR_past U M → CanonicalR M U
        have hR_MU := canonicalR_past_implies_forward_reverse U.val M.val
          U.property M.property hH_UM
        exact canonicalR_transitive M.val U.val V.val M.property hR_MU hR_UV
      · -- x = 0
        have hx_eq : x = 0 := by omega
        subst hx_eq
        simp at h_sum_pos
        -- 0 + y > 0 → y > 0
        have hR_UV : CanonicalR U.val V.val := h2_pos h_sum_pos
        -- Same issue as the symmetric case: task_rel M 0 U is vacuous
        sorry
  · -- Need: x + y < 0 → HContent V.val ⊆ M.val
    intro h_sum_neg
    by_cases hy : y < 0
    · -- y < 0
      have hH_VU : HContent V.val ⊆ U.val := h2_neg hy
      by_cases hx : x < 0
      · -- x < 0, y < 0 → both backward, chain via HContent transitivity
        have hH_UM : HContent U.val ⊆ M.val := h1_neg hx
        exact HContent_chain_transitive M.val U.val V.val V.property hH_VU hH_UM
      · -- x ≥ 0, y < 0, x + y < 0
        by_cases hx_pos : x > 0
        · -- x > 0, y < 0, x + y < 0
          have hR_MU : CanonicalR M.val U.val := h1_pos hx_pos
          -- CanonicalR M U → CanonicalR_past U M (by interplay lemma)
          have hH_UM := canonicalR_implies_past_reverse M.val U.val
            M.property U.property hR_MU
          exact HContent_chain_transitive M.val U.val V.val V.property hH_VU hH_UM
        · -- x = 0, y < 0, x + y < 0
          have hx_eq : x = 0 := by omega
          subst hx_eq
          simp at h_sum_neg
          -- Same d=0 limitation
          sorry
    · -- y ≥ 0
      by_cases hy_pos : y > 0
      · -- y > 0, x must be < 0 (since x + y < 0 and y > 0)
        -- Actually x + y < 0 and y > 0 implies x < -y < 0, impossible if y > 0
        -- Wait: x + y < 0 and y > 0 means x < -y, and -y < 0, so x < 0
        have hx : x < 0 := by omega
        have hH_UM : HContent U.val ⊆ M.val := h1_neg hx
        have hR_UV : CanonicalR U.val V.val := h2_pos hy_pos
        -- CanonicalR U V → CanonicalR_past V U (by interplay lemma)
        have hH_VU := canonicalR_implies_past_reverse U.val V.val
          U.property V.property hR_UV
        exact HContent_chain_transitive M.val U.val V.val V.property hH_VU hH_UM
      · -- y = 0
        have hy_eq : y = 0 := by omega
        subst hy_eq
        simp at h_sum_neg
        have hH_UM : HContent U.val ⊆ M.val := h1_neg h_sum_neg
        -- Same d=0 limitation
        sorry

/--
The canonical task frame for the direct TruthLemma.

WorldState = CanonicalWorldState (subtype of MCS)
task_rel = canonical_task_rel (GContent/HContent by duration sign)
D = Int

The task relation captures the temporal ordering between MCSs semantically.
Nullity holds vacuously at d = 0 (avoiding the T-axiom obstruction).
Compositionality relies on CanonicalR/HContent transitivity and interplay lemmas.

**Compositionality sorry dependencies**: Three sorry cases remain where d = 0
acts as an intermediate. These arise because the vacuous d = 0 condition provides
no information about the M-U or U-V relationship. The full algebraic approach
in `DurationTransfer.canonicalTaskFrame` resolves this by making d = 0 force
U = V (via `add_zero`).
-/
def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := fun M U V x y h1 h2 =>
    canonical_task_rel_compositionality M U V x y h1 h2

/--
The canonical task model: valuation is MCS membership.

An atom p is true at world-state M iff `atom p in M.val`.
-/
def CanonicalTaskModel : TaskModel CanonicalTaskFrame where
  valuation := fun M p => Formula.atom p ∈ M.val

/--
Convert an FMCS to a WorldHistory in the canonical TaskFrame.

- domain: full (every integer time is in the domain)
- states: the MCS at time t IS the world-state
- respects_task: proved using forward_G from the FMCS structure

Key property: domain = fun _ => True eliminates all domain-related complexity.

**respects_task proof**: For s ≤ t in Int, the duration d = t - s ≥ 0.
- If d > 0 (i.e., s < t): need GContent(mcs s) ⊆ mcs t.
  This is exactly FMCS.forward_G applied to all G-formulas.
- If d = 0 (i.e., s = t): both implications vacuously true.
- d < 0 is impossible since s ≤ t implies t - s ≥ 0.
-/
def to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := fun s t _ _ hst => by
    -- Need: canonical_task_rel ⟨fam.mcs s, ...⟩ (t - s) ⟨fam.mcs t, ...⟩
    constructor
    · -- t - s > 0 → GContent (fam.mcs s) ⊆ fam.mcs t
      intro h_pos
      have hst_strict : s < t := by omega
      intro phi h_G_phi
      -- h_G_phi : phi ∈ GContent (fam.mcs s), i.e., all_future phi ∈ fam.mcs s
      exact fam.forward_G s t phi hst_strict h_G_phi
    · -- t - s < 0 → HContent (fam.mcs t) ⊆ fam.mcs s
      intro h_neg
      -- But s ≤ t implies t - s ≥ 0, contradicting t - s < 0
      exact absurd h_neg (by omega)

/--
The canonical Omega: the set of world-histories from bundle families.

CanonicalOmega B = { tau | exists fam in B.families, tau = to_history fam }

This set is NOT necessarily ShiftClosed. ShiftClosed is not needed for
the TruthLemma (only for the connection to standard validity).
-/
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | ∃ fam ∈ B.families, tau = to_history fam }

/-!
## Phase 2-5: The Direct TruthLemma
-/

/--
The direct canonical truth lemma: MCS membership corresponds to truth_at evaluation.

This is THE KEY THEOREM connecting the BFMCS construction to standard TaskFrame semantics.
It eliminates the bmcs_truth_at intermediate entirely.

The proof proceeds by structural induction on phi, with cases:
- atom: domain is full (True.intro), valuation = MCS membership
- bot: MCS consistency vs False
- imp: MCS modus ponens + negation completeness (uses IH in both directions)
- box: modal_forward/backward + IH
- all_future (G): forward_G + temporal_backward_G via h_tc
- all_past (H): backward_H + temporal_backward_H via h_tc

**Note**: The truth lemma does NOT use the task_rel in its proof — temporal
operators (G, H) use the strict order < on D directly, and the box operator
quantifies over histories in Omega (whose membership is determined by the
BFMCS families, not by respects_task filtering). The task_rel matters only
for which functions qualify as `WorldHistory CanonicalTaskFrame`, affecting
the TYPE of the box quantification, but the CanonicalOmega set is constructed
to ensure all its members satisfy respects_task.
-/
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi := by
  induction phi generalizing fam t with
  | atom p =>
    -- atom case: phi in fam.mcs t <-> exists ht, M.valuation (tau.states t ht) p
    -- Since domain = True, ht = True.intro
    -- valuation (fam.mcs t, is_mcs t) p = (atom p in fam.mcs t)
    simp only [truth_at, CanonicalTaskModel, to_history]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- bot case: bot in fam.mcs t <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      -- bot in MCS contradicts consistency
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- imp case: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases set_mcs_negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: psi is true
        have h_psi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t psi :=
          (ih_psi fam hfam t).mp h_psi_mcs
        -- By hypothesis: chi is true
        have h_chi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t chi :=
          h_truth_imp h_psi_true
        -- By IH: chi in MCS
        have h_chi_mcs : chi ∈ fam.mcs t := (ih_chi fam hfam t).mpr h_chi_true
        -- Contradiction: chi and neg(chi) in consistent MCS
        exact set_consistent_not_both (fam.is_mcs t).1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    -- box case: box psi in MCS <-> forall sigma in Omega, truth sigma t psi
    simp only [truth_at]
    constructor
    · -- Forward: box psi in MCS -> forall sigma in Omega, truth sigma t psi
      intro h_box sigma h_sigma_mem
      -- sigma in CanonicalOmega B means sigma = to_history fam' for some fam' in B.families
      obtain ⟨fam', hfam', h_eq⟩ := h_sigma_mem
      subst h_eq
      -- By modal_forward: psi in fam'.mcs t
      have h_psi_mcs : psi ∈ fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
      -- By IH: truth at fam'
      exact (ih fam' hfam' t).mp h_psi_mcs
    · -- Backward: forall sigma in Omega, truth sigma t psi -> box psi in MCS
      intro h_all
      -- For each fam' in B.families, to_history fam' is in CanonicalOmega
      -- By IH backward: psi in fam'.mcs t
      have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_in_omega : to_history fam' ∈ CanonicalOmega B := ⟨fam', hfam', rfl⟩
        have h_truth := h_all (to_history fam') h_in_omega
        exact (ih fam' hfam' t).mpr h_truth
      -- By modal_backward: box psi in MCS
      exact B.modal_backward fam hfam psi t h_psi_all_mcs
  | all_future psi ih =>
    -- G case: G psi in MCS <-> forall s > t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s > t, truth tau s psi
      intro h_G s hts
      -- By forward_G: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s > t, truth tau s psi -> G psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s > t
      have h_all_mcs : ∀ s : Int, t < s → psi ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      -- Apply temporal_backward_G
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H case: H psi in MCS <-> forall s < t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s < t, truth tau s psi
      intro h_H s hst
      -- By backward_H: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.backward_H t s psi hst h_H
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s < t, truth tau s psi -> H psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s < t
      have h_all_mcs : ∀ s : Int, s < t → psi ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      -- Apply temporal_backward_H
      exact temporal_backward_H tcf t psi h_all_mcs

end Bimodal.Metalogic.Bundle.Canonical
