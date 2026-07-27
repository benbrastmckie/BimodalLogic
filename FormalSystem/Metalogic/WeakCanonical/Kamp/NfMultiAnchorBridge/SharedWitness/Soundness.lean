/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.EngineInputs

/-! # Shared-Interior-Witness Joint Carrier — O3 joint soundness extraction

Module F of the `SharedWitness` tower. From a REALIZED joint disjunct of `kvE2_sepBody`,
extract the shared witness `w` (the one `ptW` slot) and the per-σ segment-form exclusions
(Rabinovich Cor 5.4, PDF p.5). Carries `kvE2_sepHonest_hLR_absurd` and
`kvE2_sepHonestOrder'`. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ### Completeness reduction to the single delegated `.holds`

The Phase-5 sorry-free deliverable terminates here (design gate report 06 Q4/Q5, phase sizing).
`kvE2_sepHonestOrder_mem_arr'` (5B) is the carrier member; the remaining obligation to make the
separated body hold is the realization of the honest disjunct's own bracket — the single
337-owned `.holds`, produced by `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1290) over
the engine-precondition regions bundle (consecutive distinct-anchor intervals: `hpos`/`hlink` from
the keystone-strict anchor family + `kvE2_ordRank_strictMono`, `hnd` per-zone base-type `Nodup`,
`hreal` from the honest bundles `kvE2_sepHonestBundleL/R`) fed to `k1v_sorted_realizationK`
(SubBracket2V.lean:633). That regions realization — including any meet-type folding for a foreign
base witness forced onto an anchor (report 06 R3) — is downstream territory, NOT a carrier change.
Below is the complete, axiom-clean reduction taking that one `.holds` as the delegated step. -/

-- NOTE: `kvE2_sepBody_complete_holds` (Phase 5D, the completeness
-- hand-off) is RELOCATED below the grouped/flat singleton-compatibility block —
-- post-rewire the carrier emits GROUPED disjuncts, and the flat `hdisj` is converted via
-- `kvE2_sepDisjunct'_map_singleton_iff` on the honest order's singleton tie classes
-- (`kvE2_sepHonestOrder_slotsLOf/ROf_gidx_nodup`). Statement unchanged.

/-! ## O3 — Joint soundness extraction

From a REALIZED joint disjunct of `kvE2_sepBody`, extract the shared witness `w` (the one
`ptW` slot at bracket position `|lL|`; `x < w < t` from the bracket's OWN range — FM-x1t:
witness bounds ride the bracket's range/ordering, never a chain) and, per positive interior
σ, the witness bundle `(x1_σ, hxx1, hx1t, hanchor, hbelow)` — the inputs the
closer `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`) consumes. Positions are
carried by the arrangement's slot INDICES (structural reads; LITMUS: no `x1 < e_i`
relative-position literal anywhere). The shared-`w` pivot CONSUMES the Lemma 5.1 kit
`BracketFormula.leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`; D4 — the
kit is never rebuilt). Templates (new N-slot code regardless):
`kvE_sub2V_bounded_anchor_of_outer` (`SubBracket2V.lean:1182`, public) and the private
`kvE_subBracket2V_extract` (`SubBracket2V.lean:762`, pattern only). Rabinovich 2014:
Def 3.1 monotone enumeration (PDF p.4), Lemma 5.1 (PDF p.3, PDF p.6, PDF p.8),
Cor 5.4 (PDF p.5). -/

/-- Membership in the positive-sub spine is exactly fold-bit truth (Fintype enumeration). -/
theorem kvE2_sepPos_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (σ : NormalForm sig 1 4) :
    σ ∈ kvE2_sepPos qnf ↔ qnf.2 σ = true := by
  unfold kvE2_sepPos
  rw [List.mem_filter]
  simp

/-- **Per-σ LEFT-interior soundness bundle at the shared witness** (O3): σ's fresh witness
    `x1` strictly inside `(x, w)` realizing the folded fresh point type `kvE2_sepPtX1L`
    (head = the `charK (nfk_projFresh σ)` E[Σ]-atom anchor — Lemma 5.1, PDF p.3), with every
    `zXU`-positive 1-type realized strictly BELOW `x1` (Cor 5.4, PDF p.5). Bounds ride
    the bracket's own ordering (FM-x1t). -/
def kvE2_sepBundleL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x : M.carrier) : Prop :=
  ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
    (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1 ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
      ∃ u : M.carrier, x < u ∧ u < x1 ∧
        (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u)

/-- **Per-σ RIGHT-interior soundness bundle at the shared witness** (O3, mirrored class):
    σ's fresh witness `x1` strictly inside `(w, t)` realizing `kvE2_sepPtX1R`, with every
    `zWX1`-positive 1-type (region `(w, x1)`) realized strictly BELOW `x1` and above `w`.
    NOTE (Phase-7 watch item): no landed per-σ correctness kit serves this class yet; the
    bundle is extracted for Phases 9-10 arbitration. -/
def kvE2_sepBundleR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w t : M.carrier) : Prop :=
  ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
    (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1 ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true →
      ∃ u : M.carrier, w < u ∧ u < x1 ∧
        (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u)

/-- The `charK` E[Σ]-atom anchor head of a realized LEFT-interior fresh point type
    (Lemma 5.1, PDF p.3 — the atom predicates only of its own point; the
    `kvE_subBracket2V_extract` head-projection pattern, `SubBracket2V.lean:798-802`). -/
theorem kvE2_sepPtX1L_anchor {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (h : (kvE2_sepPtX1L charBase charK σ).eval_at M atomMap x1) :
    (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  simp only [kvE2_sepPtX1L, TemporalPred.eval_at] at h ⊢
  rw [formula_conjList_iff] at h
  exact h _ List.mem_cons_self

/-- Mirrored anchor head projection for the RIGHT-interior fresh point type. -/
theorem kvE2_sepPtX1R_anchor {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x1 : M.carrier)
    (h : (kvE2_sepPtX1R charBase charK σ).eval_at M atomMap x1) :
    (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  simp only [kvE2_sepPtX1R, TemporalPred.eval_at] at h ⊢
  rw [formula_conjList_iff] at h
  exact h _ List.mem_cons_self

/-- A left-interior bundle under `w < t` yields EXACTLY the
    `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`) input 5-tuple
    `(x1, hxx1, hx1t, hanchor, hbelow)` — `x1 < t` rides `x1 < w < t`, the bracket's own
    ordering (FM-x1t; never a formula literal, LITMUS). -/
theorem kvE2_sepBundleL_parts {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {w x t : M.carrier} (hwt : w < t)
    (h : kvE2_sepBundleL charBase charK σ M atomMap w x) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 ∧
      (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, x < u ∧ u < x1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  obtain ⟨x1, hxx1, hx1w, hpt, hbelow⟩ := h
  exact ⟨x1, hxx1, hx1w.trans hwt,
    kvE2_sepPtX1L_anchor charBase charK σ M atomMap x1 hpt, hbelow⟩

/-- Mirrored bounded-anchor fragment for a right-interior bundle under `x < w`
    (Phase-7 watch item: recorded for Phases 9-10 arbitration; no landed consumer yet). -/
theorem kvE2_sepBundleR_parts {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {w x t : M.carrier} (hxw : x < w)
    (h : kvE2_sepBundleR charBase charK σ M atomMap w t) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < t ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap x1 := by
  obtain ⟨x1, hwx1, hx1t, hpt, -⟩ := h
  exact ⟨x1, hxw.trans hwx1, hx1t,
    kvE2_sepPtX1R_anchor charBase charK σ M atomMap x1 hpt⟩

/-! ### Witness-count normalization and the shared-`w` split (Lemma 5.1 kit consumption) -/

/-- Witness-count normalization for bracket formulas: the joint count `|lL| + 1 + |lR|` is
    not SYNTACTICALLY a successor, so re-type it without touching content (definitional
    structure eta makes `kvE2_sepCastBracket rfl bf ≡ bf`). -/
def kvE2_sepCastBracket {m n : Nat} (h : m = n) (bf : BracketFormula m) :
    BracketFormula n where
  pointTypes := fun i => bf.pointTypes ⟨i.val, by omega⟩
  segmentTypes := fun i => bf.segmentTypes ⟨i.val, by omega⟩

/-- The count cast preserves the bracket semantics. -/
theorem kvE2_sepCastBracket_holds {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h : m = n) (bf : BracketFormula m) (z0 z1 : M.carrier) :
    (kvE2_sepCastBracket h bf).holds M atomMap z0 z1 ↔ bf.holds M atomMap z0 z1 := by
  subst h
  exact Iff.rfl

/-- **Shared-witness split for a realized bracket** (Lemma 5.1, PDF p.6: the
    `A_i^-`/`A_i^+` decomposition at "which `i` the new point corresponds to", PDF p.8):
    from `holds` over `(x, t)`, the witness at index `i` is strictly inside `(x, t)`,
    realizes its point type, and BOTH halves hold at it — CONSUMING the landed kit
    `BracketFormula.leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`;
    D4: the kit is consumed for every shared-`w` pivot, never rebuilt). -/
theorem kvE2_sepBracket_split_at {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (x t : M.carrier) (i : Fin (n + 1))
    (h : bf.holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (bf.pointTypes i).eval_at M atomMap w ∧
      (bf.leftPart i).holds M atomMap x w ∧
      (bf.rightPart i).holds M atomMap w t := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
    IntervalPattern.holds] at h
  obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegmid, hsegn⟩ := h
  exact ⟨ws i, (hrange i).1, (hrange i).2, hpt i,
    BracketFormula.leftPart_holds M atomMap bf x t i ws hmono hrange hpt hseg0 hsegmid hsegn,
    BracketFormula.rightPart_holds M atomMap bf x t i ws hmono hrange hpt hseg0 hsegmid hsegn⟩

/-! ### Structural navigation helpers (private plumbing) -/

/-- Point-list read at the shared `ptW` position `|L|` (§5 bracket, PDF p.7). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I,J).
theorem kvE2_sep_getElem_mid {α : Type} (L R : List α) (p : α) :
    (L ++ p :: R)[L.length]'(by
      simp only [List.length_append, List.length_cons]; omega) = p := by
  rw [List.getElem_append_right (Nat.le_refl _)]
  simp only [Nat.sub_self, List.getElem_cons_zero]

/-- Point-list read strictly left of the shared slot. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I,J).
theorem kvE2_sep_getElem_left {α : Type} (L R : List α) (p : α)
    (i : Nat) (hi : i < L.length) :
    (L ++ p :: R)[i]'(by
      simp only [List.length_append, List.length_cons]; omega) = L[i]'hi := by
  rw [List.getElem_append_left hi]

/-- Point-list read strictly right of the shared slot (offset `|L| + 1 + j`). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I,J).
theorem kvE2_sep_getElem_right {α : Type} (L R : List α) (p : α)
    (j : Nat) (hj : j < R.length) :
    (L ++ p :: R)[L.length + 1 + j]'(by
      simp only [List.length_append, List.length_cons]; omega) = R[j]'hj := by
  rw [List.getElem_append_right (by omega)]
  simp only [show L.length + 1 + j - L.length = j + 1 by omega, List.getElem_cons_succ]

/-- In a valid arrangement, a slot of the SAME σ with strictly smaller region rank sits at
    a strictly smaller index (the structural position read — LITMUS: positions by
    arrangement index, never an `x1 < e_i` literal). -/
private theorem kvE2_sep_index_lt_of_rank_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {l : List (KvE2SepSlot sig)}
    (hpw : l.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    {i j : Nat} (hi : i < l.length) (hj : j < l.length)
    (hsub : kvE2_sepSlotSub (l[j]'hj) = kvE2_sepSlotSub (l[i]'hi))
    (hrk : kvE2_sepSlotRank (l[j]'hj) < kvE2_sepSlotRank (l[i]'hi)) :
    j < i := by
  rcases Nat.lt_trichotomy j i with hlt | heq | hgt
  · exact hlt
  · subst heq; exact absurd hrk (lt_irrefl _)
  · exfalso
    have hle := List.pairwise_iff_getElem.mp hpw i j hi hj hgt
    unfold kvE2_sepSlotLe at hle
    rw [if_pos hsub.symm, decide_eq_true_eq] at hle
    omega

/-- σ's fresh-witness slot is in its canonical LEFT block (left-interior σ). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I).
theorem kvE2_sep_lX1_mem_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    (.lX1 σ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [if_pos hzone]
  exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- A left-interior σ's `zXU`-positive 1-type slot is in its canonical LEFT block. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I).
theorem kvE2_sep_lXU_mem_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true) :
    (.lXU σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [if_pos hzone]
  exact List.mem_append.mpr
    (Or.inl (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))

/-- A left-interior σ's `zUW`-positive 1-type slot is in its canonical LEFT block. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (I).
theorem kvE2_sep_lUW_mem_slotsLFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true) :
    (.lUW σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsLFor σ := by
  unfold kvE2_sepSlotsLFor
  rw [if_pos hzone]
  exact List.mem_append.mpr (Or.inr (List.mem_cons.mpr
    (Or.inr (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))))

/-- σ's fresh-witness slot is in its canonical RIGHT block (right-interior σ). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,J).
theorem kvE2_sep_rX1_mem_slotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    (.rX1 σ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- A right-interior σ's `zWX1`-positive 1-type slot is in its canonical RIGHT block. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,J).
theorem kvE2_sep_rWX1_mem_slotsRFor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    {χ : NormalForm sig 0 1} (hbit : σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true) :
    (.rWX1 σ χ : KvE2SepSlot sig) ∈ kvE2_sepSlotsRFor σ := by
  unfold kvE2_sepSlotsRFor
  rw [hzone, if_neg kvE2_sep_zWT3_ne_zXW3, if_pos rfl]
  exact List.mem_append.mpr
    (Or.inl (List.mem_map_of_mem (List.mem_filter.mpr ⟨by simp, hbit⟩)))

-- NOTE: the four `arrL/arrR`-based helpers (`kvE2_sep_mem_arrL/R`,
-- `kvE2_sep_arrL/R_pairwise`) were DELETED with the abandoned additive filter
-- (`kvE2_sepValid`/`kvE2_sepArrL/R`). The facts they supplied — canonical-slot membership and
-- region-rank pairwise ordering of the disjunct's slot lists — are now passed to
-- `kvE2_sepDisjunct_extract` as explicit hypotheses (`hmemL/hpairL/hmemR/hpairR`), discharged at
-- each call site for the arrangement the carrier actually uses.

/-! ### Bracket point-type + segment match (the `.holds` construction)

The mpr dual of `kvE2_sepDisjunct_extract`: assemble `(kvE2_sepBracketN lL ptW lR segs).holds`
from a per-slot witness list. The generic construction below is the N-slot lift of the landed
k=3 template `k1v_bracket_construct3` (SubBracket2V.lean:720): a combined strictly-sorted
witness list `usL ++ w :: usR` (pivot `w` at position `|usL|` — the SINGLE interior
distinguished slot of the §5 bracket, PDF p.7), per-index point-type realizations on each
side, `ptW` at the pivot, and the per-gap segment obligations in `holds_eq_succ`'s three
shapes. All bounds ride the fixed endpoints `x`/`t` and the witness list itself (F4/LITMUS:
no `x1 < e_i` relative-position literal, no owner-to-owner chain). -/

/-- **Generic N-slot bracket construction** (Phase 3 structural core; Rabinovich Lemma 5.3,
    PDF p.5 — per-region segment types; Def 3.1 strictly-increasing witnesses, PDF pp.2-3).
    Point types are read at the combined witness list `usL ++ w :: usR` in block slot-index
    order; the three `beta` families are supplied in exactly `IntervalPattern.holds_eq_succ`'s
    gap shapes. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H).
theorem kvE2_sepBracketN_construct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL : List TemporalPred) (ptW : TemporalPred) (lR : List TemporalPred)
    (segs : Nat → TemporalPred)
    (x w t : M.carrier) (usL usR : List M.carrier)
    (hlenL : usL.length = lL.length) (hlenR : usR.length = lR.length)
    (hsort : (usL ++ w :: usR).Pairwise (· < ·))
    (hrange : ∀ u ∈ usL ++ w :: usR, x < u ∧ u < t)
    (hptL : ∀ (i : Nat) (hi : i < lL.length),
      (lL[i]'hi).eval_at M atomMap (usL[i]'(by omega)))
    (hptW : ptW.eval_at M atomMap w)
    (hptR : ∀ (j : Nat) (hj : j < lR.length),
      (lR[j]'hj).eval_at M atomMap (usR[j]'(by omega)))
    (hseg0 : ∀ y : M.carrier, x < y →
      y < (usL ++ w :: usR)[0]'(by simp) → (segs 0).eval_at M atomMap y)
    (hsegmid : ∀ (i : Nat) (hi : i + 1 < (usL ++ w :: usR).length) (y : M.carrier),
      (usL ++ w :: usR)[i]'(by omega) < y → y < (usL ++ w :: usR)[i + 1]'hi →
      (segs (i + 1)).eval_at M atomMap y)
    (hseglast : ∀ y : M.carrier,
      (usL ++ w :: usR)[(usL ++ w :: usR).length - 1]'(by simp) < y → y < t →
      (segs (usL ++ w :: usR).length).eval_at M atomMap y) :
    (kvE2_sepBracketN lL ptW lR segs).holds M atomMap x t := by
  have hlen : (usL ++ w :: usR).length = lL.length + lR.length + 1 := by
    simp only [List.length_append, List.length_cons, hlenL, hlenR]; omega
  simp only [kvE2_sepBracketN, BracketFormula.holds, BracketFormula.toIntervalPattern]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = lL.length + lR.length + 1 by omega)]
  refine ⟨fun i => (usL ++ w :: usR)[i.val]'(by have := i.isLt; omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity in block slot-index order.
    intro i j hij
    exact List.pairwise_iff_getElem.mp hsort i.val j.val _ _ hij
  · -- Range: every witness strictly inside the fixed endpoints `(x, t)`.
    intro i
    exact hrange _ (List.getElem_mem _)
  · -- Point types: three-way index split around the shared `ptW` pivot at `|lL|`.
    intro i
    rcases Nat.lt_trichotomy i.val lL.length with hi | hi | hi
    · have ht := kvE2_sep_getElem_left lL lR ptW i.val hi
      have hu := kvE2_sep_getElem_left usL usR w i.val (by omega)
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega)) = lL[i.val]'hi from ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega))
            = usL[i.val]'(by omega) from hu]
      exact hptL i.val hi
    · have ht := kvE2_sep_getElem_mid lL lR ptW
      have hu := kvE2_sep_getElem_mid usL usR w
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx hi]; exact ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega)) = w by
          rw [getElem_congr_idx (by omega : i.val = usL.length)]; exact hu]
      exact hptW
    · have hj : i.val - lL.length - 1 < lR.length := by have := i.isLt; omega
      have ht := kvE2_sep_getElem_right lL lR ptW (i.val - lL.length - 1) hj
      have hu := kvE2_sep_getElem_right usL usR w (i.val - lL.length - 1) (by omega)
      simp only []
      rw [show ((lL ++ ptW :: lR)[i.val]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = lR[i.val - lL.length - 1]'hj by
          rw [getElem_congr_idx
            (by omega : i.val = lL.length + 1 + (i.val - lL.length - 1))]; exact ht,
        show ((usL ++ w :: usR)[i.val]'(by have := i.isLt; omega))
            = usR[i.val - lL.length - 1]'(by omega) by
          rw [getElem_congr_idx
            (by omega : i.val = usL.length + 1 + (i.val - lL.length - 1))]; exact hu]
      exact hptR (i.val - lL.length - 1) hj
  · -- First gap `(x, ws 0)`.
    intro y hxy hy0
    exact hseg0 y hxy hy0
  · -- Interior gaps `(ws i, ws (i+1))`.
    intro i y hlo hhi
    exact hsegmid i.val (by have := i.isLt; omega) y hlo hhi
  · -- Last gap `(ws last, t)`.
    intro y hlo hyt
    have h1 := hseglast y
      (lt_of_le_of_lt (le_of_eq (getElem_congr_idx (by simp only; omega))) hlo)
      hyt
    rwa [hlen] at h1

/-! ### Grouped/flat singleton compatibility

When every tie class is a singleton (the tie-free case — any weak order whose
`kvE2_sepSlotGIdx` payload is duplicate-free over the merged chain), the meet-folded grouped
disjunct and the flat per-slot disjunct agree at `.holds` level: `formula_conjList [f]`
eval-equals `f` pointwise, and the grouped cut arithmetic collapses to the flat cuts. The
comparison is `.holds`-level, NOT syntactic (`formula_conjList [f]` is `f ∧ ⊤`). -/

/-- `.holds`-level congruence for `kvE2_sepBracketN` under pointwise eval-equivalent point
    types and equal (bracket-relevant) segment types. The two brackets carry syntactically
    DIFFERENT length expressions; both sides are normalized to a common witness count via
    `IntervalPattern.holds_eq_succ`. -/
private theorem kvE2_sepBracketN_holds_congr {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (aL bL aR bR : List TemporalPred) (ptW : TemporalPred)
    (segsA segsB : Nat → TemporalPred)
    (hL : aL.length = bL.length) (hR : aR.length = bR.length)
    (hptL : ∀ (i : Nat) (hia : i < aL.length) (hib : i < bL.length) (y : M.carrier),
      (aL[i]'hia).eval_at M atomMap y ↔ (bL[i]'hib).eval_at M atomMap y)
    (hptR : ∀ (j : Nat) (hja : j < aR.length) (hjb : j < bR.length) (y : M.carrier),
      (aR[j]'hja).eval_at M atomMap y ↔ (bR[j]'hjb).eval_at M atomMap y)
    (hseg : ∀ i : Nat, i ≤ aL.length + 1 + aR.length → segsA i = segsB i)
    (x t : M.carrier) :
    (kvE2_sepBracketN aL ptW aR segsA).holds M atomMap x t ↔
      (kvE2_sepBracketN bL ptW bR segsB).holds M atomMap x t := by
  -- Combined point-list reads agree at every index (three-way split at the pivot `|aL|`).
  have hpt : ∀ (i : Nat) (hia : i < aL.length + 1 + aR.length)
      (hib : i < bL.length + 1 + bR.length) (y : M.carrier),
      ((aL ++ ptW :: aR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap y ↔
      ((bL ++ ptW :: bR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap y := by
    intro i hia hib y
    rcases Nat.lt_trichotomy i aL.length with hi | hi | hi
    · rw [kvE2_sep_getElem_left aL aR ptW i hi,
        kvE2_sep_getElem_left bL bR ptW i (hL ▸ hi)]
      exact hptL i hi (hL ▸ hi) y
    · rw [show ((aL ++ ptW :: aR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx hi]; exact kvE2_sep_getElem_mid aL aR ptW,
        show ((bL ++ ptW :: bR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega)) = ptW by
          rw [getElem_congr_idx (hi.trans hL)]; exact kvE2_sep_getElem_mid bL bR ptW]
    · have hja : i - aL.length - 1 < aR.length := by omega
      have hjb : i - bL.length - 1 < bR.length := by omega
      rw [show ((aL ++ ptW :: aR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = aR[i - aL.length - 1]'hja by
          rw [getElem_congr_idx (by omega : i = aL.length + 1 + (i - aL.length - 1))]
          exact kvE2_sep_getElem_right aL aR ptW _ hja,
        show ((bL ++ ptW :: bR)[i]'(by
            simp only [List.length_append, List.length_cons]; omega))
            = bR[i - bL.length - 1]'hjb by
          rw [getElem_congr_idx (by omega : i = bL.length + 1 + (i - bL.length - 1))]
          exact kvE2_sep_getElem_right bL bR ptW _ hjb]
      rw [getElem_congr_idx (by omega : i - bL.length - 1 = i - aL.length - 1)]
      exact hptR (i - aL.length - 1) hja (by omega) y
  simp only [kvE2_sepBracketN, BracketFormula.holds, BracketFormula.toIntervalPattern]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show aL.length + 1 + aR.length = aL.length + aR.length + 1 by omega),
    IntervalPattern.holds_eq_succ M atomMap _ _ x t
      (show bL.length + 1 + bR.length = aL.length + aR.length + 1 by omega)]
  constructor
  · rintro ⟨ws, h1, h2, h3, h4, h5, h6⟩
    refine ⟨ws, h1, h2, fun i => (hpt i.val (by omega) (by omega) (ws i)).mp (h3 i),
      fun y hy1 hy2 => ?_, fun i y hy1 hy2 => ?_, fun y hy1 hy2 => ?_⟩
    · change (segsB 0).eval_at M atomMap y
      rw [← hseg 0 (by omega)]
      exact h4 y hy1 hy2
    · change (segsB (i.val + 1)).eval_at M atomMap y
      rw [← hseg (i.val + 1) (by omega)]
      exact h5 i y hy1 hy2
    · change (segsB (aL.length + aR.length + 1)).eval_at M atomMap y
      rw [← hseg (aL.length + aR.length + 1) (by omega)]
      exact h6 y hy1 hy2
  · rintro ⟨ws, h1, h2, h3, h4, h5, h6⟩
    refine ⟨ws, h1, h2, fun i => (hpt i.val (by omega) (by omega) (ws i)).mpr (h3 i),
      fun y hy1 hy2 => ?_, fun i y hy1 hy2 => ?_, fun y hy1 hy2 => ?_⟩
    · change (segsA 0).eval_at M atomMap y
      rw [hseg 0 (by omega)]
      exact h4 y hy1 hy2
    · change (segsA (i.val + 1)).eval_at M atomMap y
      rw [hseg (i.val + 1) (by omega)]
      exact h5 i y hy1 hy2
    · change (segsA (aL.length + aR.length + 1)).eval_at M atomMap y
      rw [hseg (aL.length + aR.length + 1) (by omega)]
      exact h6 y hy1 hy2

/-- **Singleton compatibility, core form**: on the
    singleton partition the grouped meet-folded disjunct agrees with the flat per-slot
    disjunct at `.holds` level. Point types: `formula_conjList [f]` eval-equals `f`
    (`kvE2_sepClassType_singleton_eval`); segments: grouped cuts collapse to flat cuts
    (`kvE2_sepSegsG_map_singleton`); endpoints and the shared `ptW` are shared verbatim. -/
theorem kvE2_sepDisjunct'_map_singleton_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (lL lR : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (kvE2_sepDisjunct' charBase charK qnf
        (lL.map (fun s => [s])) (lR.map (fun s => [s]))).2.holds M atomMap x t ↔
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t := by
  have hptL' : ∀ (i : Nat)
      (hia : i < ((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length)
      (hib : i < (lL.map (kvE2_sepSlotType charBase charK)).length) (y : M.carrier),
      ((((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK))[i]'hia).eval_at
          M atomMap y) ↔
        (((lL.map (kvE2_sepSlotType charBase charK))[i]'hib).eval_at M atomMap y) := by
    intro i hia hib y
    simp only [List.getElem_map]
    exact kvE2_sepClassType_singleton_eval charBase charK _ M atomMap y
  have hptR' : ∀ (j : Nat)
      (hja : j < ((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length)
      (hjb : j < (lR.map (kvE2_sepSlotType charBase charK)).length) (y : M.carrier),
      ((((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK))[j]'hja).eval_at
          M atomMap y) ↔
        (((lR.map (kvE2_sepSlotType charBase charK))[j]'hjb).eval_at M atomMap y) := by
    intro j hja hjb y
    simp only [List.getElem_map]
    exact kvE2_sepClassType_singleton_eval charBase charK _ M atomMap y
  have hseg' : ∀ i : Nat,
      i ≤ ((lL.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length + 1
        + ((lR.map (fun s => [s])).map (kvE2_sepClassType charBase charK)).length →
      kvE2_sepSegsG charBase qnf (lL.map (fun s => [s])) (lR.map (fun s => [s])) i
        = kvE2_sepSegs charBase qnf lL lR i := by
    intro i hi
    exact kvE2_sepSegsG_map_singleton charBase qnf lL lR i (by simpa using hi)
  simp only [kvE2_sepDisjunct', kvE2_sepDisjunct, VecEA2.holds]
  refine and_congr Iff.rfl (and_congr Iff.rfl ?_)
  exact kvE2_sepBracketN_holds_congr M atomMap _ _ _ _ _ _ _
    (by simp) (by simp) hptL' hptR' hseg' x t

/-- All-singleton partitions with a given flatten are exactly the mapped singleton
    partition. -/
private theorem kvE2_sep_eq_map_singleton {α : Type*} :
    ∀ (g : List (List α)) (l : List α), (∀ c ∈ g, ∃ a, c = [a]) → g.flatten = l →
      g = l.map (fun a => [a])
  | [], l, _, hf => by subst hf; rfl
  | c :: g, l, hs, hf => by
    obtain ⟨a, rfl⟩ := hs c List.mem_cons_self
    rw [List.flatten_cons, List.singleton_append] at hf
    subst hf
    have ih := kvE2_sep_eq_map_singleton g g.flatten
      (fun c hc => hs c (List.mem_cons_of_mem _ hc)) rfl
    rw [List.map_cons, ← ih]

/-- **Singleton compatibility, plan shape**: when every tie class of
    `gL`/`gR` is a singleton and the classes flatten to `lL`/`lR`, the grouped meet-folded
    disjunct agrees with the flat per-slot disjunct at `.holds` level. The hypothesis shape
    is exactly what `kvE2_sepTieGroupedL/R_of_nodup` + `_flatten` produce on a `Nodup`
    payload. -/
theorem kvE2_sepDisjunct'_singleton_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {gL gR : List (List (KvE2SepSlot sig))} {lL lR : List (KvE2SepSlot sig)}
    (hgLs : ∀ c ∈ gL, ∃ s, c = [s]) (hgLf : gL.flatten = lL)
    (hgRs : ∀ c ∈ gR, ∃ s, c = [s]) (hgRf : gR.flatten = lR)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (kvE2_sepDisjunct' charBase charK qnf gL gR).2.holds M atomMap x t ↔
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t := by
  rw [kvE2_sep_eq_map_singleton gL lL hgLs hgLf, kvE2_sep_eq_map_singleton gR lR hgRs hgRf]
  exact kvE2_sepDisjunct'_map_singleton_iff charBase charK qnf lL lR M atomMap x t

/-- flatMap is monotone under componentwise sublists. -/
private theorem kvE2_sep_flatMap_sublist {α β : Type*} (f g : α → List β)
    (h : ∀ a, List.Sublist (f a) (g a)) :
    ∀ l : List α, List.Sublist (l.flatMap f) (l.flatMap g)
  | [] => List.Sublist.refl _
  | a :: l => by
    simp only [List.flatMap_cons]
    exact (h a).append (kvE2_sep_flatMap_sublist f g h l)

/-- **Honest merged-chain key family is duplicate-free**:
    on the honest order the mergeSort key reader `kvE2_sepSlotGIdx` coincides with the
    value-faithful `kvE2_sepSlotHonestGIdx` on every block slot (halign bridge), whose
    global family is `Nodup`; any per-owner region sub-family union is a sublist of the full
    family, and the merged chain is a permutation of the union. Hence every honest tie class
    is a singleton (via `kvE2_sepTieGroupedL/R_of_nodup`). -/
private theorem kvE2_sepHonestOrder_merged_gidx_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (F : NormalForm sig 1 4 → List (KvE2SepSlot sig))
    (hFsub : ∀ σ, List.Sublist (F σ) (kvE2_sepSlotBlock σ)) :
    ((((kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h)).flatMap F).mergeSort
        (kvE2_sepSlotMergeLe (kvE2_sepHonestOrder qnf M w x t h))).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  -- The wo-ordered owner list is a permutation of the interior index.
  have hp2 : List.Perm (kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h))
      (kvE2_sepPosI qnf) := by
    have hperm := (List.mergeSort_perm (kvE2_sepHonestOrder qnf M w x t h)
      (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
    rw [kvE2_sepOrderTypes_owners qnf
      (kvE2_sepHonestOrder_mem_orderTypes qnf M w x t h)] at hperm
    exact hperm
  -- The merged chain is a permutation of the interior-index block union.
  have hp1 : List.Perm
      (((kvE2_sepOrderOwners (kvE2_sepHonestOrder qnf M w x t h)).flatMap F).mergeSort
        (kvE2_sepSlotMergeLe (kvE2_sepHonestOrder qnf M w x t h)))
      ((kvE2_sepPosI qnf).flatMap F) :=
    (List.mergeSort_perm _ _).trans (hp2.flatMap_right F)
  rw [List.Perm.nodup_iff (hp1.map (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h)))]
  -- On the union the merge key reads the value-faithful index (halign bridge).
  have hcongr : ((kvE2_sepPosI qnf).flatMap F).map
        (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))
      = ((kvE2_sepPosI qnf).flatMap F).map (kvE2_sepSlotHonestGIdx qnf M w x t h) := by
    apply List.map_congr_left
    intro s hs
    obtain ⟨σ, hσ, hsF⟩ := List.mem_flatMap.mp hs
    exact kvE2_sepSlotGIdx_honestOrder qnf M w x t h (kvE2_sepPosI_subset hσ)
      ((hFsub σ).subset hsF)
  rw [hcongr]
  -- The union is a sublist of the full family; transfer the global value-rank Nodup.
  have hsub : List.Sublist ((kvE2_sepPosI qnf).flatMap F) (kvE2_sepAllSlots qnf) := by
    change List.Sublist ((kvE2_sepPosI qnf).flatMap F)
      ((kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock)
    exact kvE2_sep_flatMap_sublist F kvE2_sepSlotBlock hFsub _
  exact List.Nodup.sublist (hsub.map (kvE2_sepSlotHonestGIdx qnf M w x t h))
    (kvE2_sepAllSlots_map_honestGIdx_nodup qnf M w x t h)

/-- The honest LEFT merged-chain `kvE2_sepSlotGIdx` payload is duplicate-free — every
    honest LEFT tie class is a singleton. -/
theorem kvE2_sepHonestOrder_slotsLOf_gidx_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h)).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  unfold kvE2_sepSlotsLOf
  exact kvE2_sepHonestOrder_merged_gidx_nodup qnf M w x t h kvE2_sepSlotsLFor
    (fun σ => by
      change List.Sublist (kvE2_sepSlotsLFor σ) (kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ)
      exact List.sublist_append_left _ _)

/-- The honest RIGHT merged-chain `kvE2_sepSlotGIdx` payload is duplicate-free — every
    honest RIGHT tie class is a singleton (right mirror). -/
theorem kvE2_sepHonestOrder_slotsROf_gidx_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ((kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h)).map
      (kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h))).Nodup := by
  unfold kvE2_sepSlotsROf
  exact kvE2_sepHonestOrder_merged_gidx_nodup qnf M w x t h kvE2_sepSlotsRFor
    (fun σ => by
      change List.Sublist (kvE2_sepSlotsRFor σ) (kvE2_sepSlotsLFor σ ++ kvE2_sepSlotsRFor σ)
      exact List.sublist_append_right _ _)

/-- **Phase 5D — the completeness hand-off** (RELOCATED here;
    statement unchanged). Given an honest realization and the realization of the
    honest disjunct's own FLAT bracket (`hdisj`, the single 337-owned `.holds`), the
    separated body holds at the fixed endpoints `x`, `t`. Wires the Phase-5B carrier member
    `kvE2_sepHonestOrder_mem_arr'` into `kvE2_sepBody_holds_iff.mpr`; post-rewire the
    carrier's disjunct is GROUPED, and the honest order's `kvE2_sepSlotGIdx` payload is
    `Nodup` (`kvE2_sepHonestOrder_slotsLOf/ROf_gidx_nodup`), so its tie classes are
    singletons and the flat `hdisj` converts via `kvE2_sepDisjunct'_map_singleton_iff`.
    UNCONDITIONAL: owner interiority is a construction invariant of the
    `kvE2_sepPosI` index — no interiority hypothesis (Rabinovich §5, p.7;
    `kvE2_sepHonest_hLR_absurd` documents why none may return). Complete and axiom-clean UP
    TO the delegated `.holds` — the sanctioned Phase-5 completion boundary.
    This is the SINGLETON (tie-free degenerate) variant — the lex payload forces
    singleton tie classes, so the flat `hdisj` suffices; the PRIMARY completeness statement
    covering genuinely-tied honest models is `kvE2_sepBody_complete_holds'` below, stated
    over the tie-grouped disjunct of the tie-reporting order `kvE2_sepHonestOrder'`. -/
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hdisj : (kvE2_sepDisjunct charBase charK qnf
        (kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h))
        (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h))).2.holds M atomMap x t) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t := by
  rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t]
  refine ⟨kvE2_sepHonestOrder qnf M w x t h,
    kvE2_sepHonestOrder_mem_arr' qnf M w x t hxw hwt h, ?_⟩
  rw [kvE2_sepTieGroupedL_of_nodup _ (kvE2_sepHonestOrder_slotsLOf_gidx_nodup qnf M w x t h),
    kvE2_sepTieGroupedR_of_nodup _ (kvE2_sepHonestOrder_slotsROf_gidx_nodup qnf M w x t h)]
  exact (kvE2_sepDisjunct'_map_singleton_iff charBase charK qnf _ _ M atomMap x t).mpr hdisj

/-- **Adversarial finding: the interior-restriction hypothesis
    `hLR` is INCONSISTENT with the honest evaluation `h`.** The characteristic depth-1 type
    `σ_w` of the configuration `(w; w, x, t)` — the shared witness read AT ITSELF — is always
    realized (witness `x1 := w`, `nf_characteristic_satisfies`), so `h`'s quantifier layer
    forces `qnf.2 σ_w = true`, i.e. `σ_w ∈ kvE2_sepPos qnf`. But `σ_w`'s ordering channel at
    the `w`-coordinate is the self-zone pair `(false, false)` (`w < w` is irreflexive), so
    `nf0_zoneSpec σ_w.1` is neither `kvE2_sep_zXW3` (which demands `(true, false)` there) nor
    `kvE2_sep_zWT3` (`(false, true)`) — contradicting `hLR σ_w`. The same construction at
    `x1 := x` / `x1 := t` populates `zAtX3` / `zAtT3`, so EVERY honest `qnf` has positive
    owners in at least three non-interior classes. Consequence: every completeness-layer
    theorem conditional on `h ∧ hLR` (`kvE2_sepBody_complete`,
    `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepBody_complete_holds`, and the downstream
    builders) is vacuously true as stated; a NON-vacuous completeness statement
    must carry the boundary/self-zone positive classes through the endpoint/pivot literal
    machinery (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` already enumerate their
    `kvE2_sepHasPos` bits) instead of excluding them by hypothesis. -/
theorem kvE2_sepHonest_hLR_absurd {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
        nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    False := by
  -- The characteristic depth-1 type of `(w; w, x, t)`: always realized with witness `w`.
  have hreal : nf_eval_nf M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t))))
      (nf_characteristic M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t))))) :=
    nf_characteristic_satisfies M 1 4 _
  set σw : NormalForm sig 1 4 :=
    nf_characteristic M 1 4 (Fin.cons w (Fin.cons w (Fin.cons x (fun _ => t)))) with hσw
  -- `h`'s quantifier layer forces the bit: `σw` is a positive owner.
  have hbit : qnf.2 σw = true := (h.2 σw).mp ⟨w, hreal⟩
  have hmem : σw ∈ kvE2_sepPos qnf := by
    rw [kvE2_sepPos, List.mem_filter]
    exact ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hbit⟩
  -- `σw`'s w-coordinate ordering pair is the self-zone `(false, false)`.
  have hzw : nf0_zoneSpec σw.1 ⟨0, by omega⟩ = (false, false) := by
    rw [hσw]
    change (nf_characteristic M 1 4 _ |>.1 (.order 0 (Fin.succ ⟨0, by omega⟩)
        (Fin.succ_ne_zero ⟨0, by omega⟩).symm),
      nf_characteristic M 1 4 _ |>.1 (.order (Fin.succ ⟨0, by omega⟩) 0
        (Fin.succ_ne_zero ⟨0, by omega⟩))) = (false, false)
    simp only [nf_characteristic]
    refine Prod.ext ?_ ?_ <;>
      · simp only [atom_eval, Fin.cons]
        -- the ambient instance here is `Classical.dec`, not `LinearOrder.toDecidableLT`,
        -- so it has to be supplied explicitly
        exact @decide_eq_false _ (Classical.dec _) (lt_irrefl w)
  rcases hLR σw hmem with hz | hz
  · have h0 := congrFun hz ⟨0, by omega⟩
    rw [hzw] at h0
    exact absurd h0.symm (by rw [kvE2_sep_zXW3]; simp)
  · have h0 := congrFun hz ⟨0, by omega⟩
    rw [hzw] at h0
    exact absurd h0.symm (by rw [kvE2_sep_zWT3]; simp)

/-! ### The tie-REPORTING honest order and the target completeness statement

The Phase 5B/5C honest order (`kvE2_sepHonestOrder`) carries the LEX payload
`(model value, slot index)`: the index tiebreak makes every honest tie class a SINGLETON, so the
tie-admitting carrier machinery (Phases 6/7) is never exercised by it. Phase 9 installs the
value-ONLY payload `kvE2_sepSlotHonestVIdx` (drop the index tiebreak; `kvE2_ordRank` needs no
injectivity): its ranks are EQUAL exactly where honest slot VALUES coincide
(`kvE2_sepSlotHonestVIdx_eq_iff`), so a genuinely-tied honest model produces genuinely
non-singleton tie classes — the payload REPORTS the tie instead of breaking it. Tie classes
remain INDEX-LEVEL data only (strict-quotient guard): every emitted disjunct is a strict
Def-3.1 bracket, one slot per class, point type = the meet of the tied types. Forced by
Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof; corroborated by the
k=m split (p.7) and Def 7.5 (p.13). Anchor-anchor ties stay excluded via the
keystone route (`nf_eval_unique` — a Lean-side, machine-checked pruning with NO
Rabinovich counterpart, audit note D7). -/

/-- **Rank-equality reports value-equality**: under ANY
    family `g`, two indices have equal `kvE2_ordRank` iff their `g`-values are equal. The
    `mpr` is definitional (the strictly-smaller filter set depends only on the value); the
    `mp` is trichotomy + `kvE2_ordRank_strictMono`. This is what makes the value-only rank a
    TIE-REPORTING payload: equal indices exactly where values coincide. -/
theorem kvE2_ordRank_eq_iff {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (a b : Fin n) :
    kvE2_ordRank g a = kvE2_ordRank g b ↔ g a = g b := by
  constructor
  · intro hrank
    rcases lt_trichotomy (g a) (g b) with hlt | heq | hgt
    · exact absurd hrank (Nat.ne_of_lt (kvE2_ordRank_strictMono g hlt))
    · exact heq
    · exact absurd hrank.symm (Nat.ne_of_lt (kvE2_ordRank_strictMono g hgt))
  · intro hval
    unfold kvE2_ordRank
    simp only [hval]

/-- **The honest slot-VALUE family**: the plain (non-lex) value family over
    the full individual-slot enumeration — `V j = value((allSlots).get j)`. NOT injective in
    general: distinct slots may share an honest value (the tie the value-only rank reports). -/
noncomputable def kvE2_sepSlotV {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    Fin (kvE2_sepAllSlots qnf).length → M.carrier :=
  fun j => kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get j)

/-- The value family at an index is the slot value of the enumerated slot (definitional). -/
theorem kvE2_sepSlotV_get {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (j : Fin (kvE2_sepAllSlots qnf).length) :
    kvE2_sepSlotV qnf M w x t h j
      = kvE2_sepSlotValue qnf M w x t h ((kvE2_sepAllSlots qnf).get j) := rfl

/-- **The tie-reporting per-slot index**: slot `s`'s VALUE-ONLY rank
    `kvE2_ordRank (kvE2_sepSlotV …)` at its family position — the slot-index lex tiebreak of
    `kvE2_sepSlotHonestGIdx` is DROPPED (`kvE2_ordRank` needs no injectivity), so two slots
    receive EQUAL indices exactly when their honest values coincide
    (`kvE2_sepSlotHonestVIdx_eq_iff`). A new parallel definition; the banked lex machinery is
    untouched. Off-family defaults to `0`. -/
noncomputable def kvE2_sepSlotHonestVIdx {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (s : KvE2SepSlot sig) : ℕ :=
  if hs : kvE2_sepSlotIndexOf qnf s < (kvE2_sepAllSlots qnf).length then
    kvE2_ordRank (kvE2_sepSlotV qnf M w x t h) ⟨kvE2_sepSlotIndexOf qnf s, hs⟩
  else 0

/-- **Strict monotonicity of the tie-reporting index** (Phase 9 conjunct-(ii) engine): a
    strictly smaller honest value gives a strictly smaller value-only rank. Direct
    `kvE2_ordRank_strictMono` — needs only the single strict inequality. -/
theorem kvE2_sepSlotHonestVIdx_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotHonestVIdx qnf M w x t h a < kvE2_sepSlotHonestVIdx qnf M w x t h b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2_sepSlotHonestVIdx
  rw [dif_pos hal, dif_pos hbl]
  apply kvE2_ordRank_strictMono
  rw [kvE2_sepSlotV_get, kvE2_sepSlotV_get, hga, hgb]
  exact hlt

/-- **The tie-reporting payload law** (the deliverable this section exists
    for): on family members, the value-only ranks are EQUAL exactly where the honest slot
    VALUES coincide. This is what makes honest tie classes non-singleton when the model
    genuinely ties — the payload reports the tie (Def 3.1 equality case, p.4) instead of
    breaking it with the slot-index tiebreak. -/
theorem kvE2_sepSlotHonestVIdx_eq_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepAllSlots qnf) (hb : b ∈ kvE2_sepAllSlots qnf) :
    kvE2_sepSlotHonestVIdx qnf M w x t h a = kvE2_sepSlotHonestVIdx qnf M w x t h b ↔
      kvE2_sepSlotValue qnf M w x t h a = kvE2_sepSlotValue qnf M w x t h b := by
  have hal : kvE2_sepSlotIndexOf qnf a < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf ha
  have hbl : kvE2_sepSlotIndexOf qnf b < (kvE2_sepAllSlots qnf).length :=
    kvE2_sepSlotIndexOf_lt qnf hb
  have hga : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf a, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepAllSlots qnf).get ⟨kvE2_sepSlotIndexOf qnf b, hbl⟩ = b := List.idxOf_get hbl
  unfold kvE2_sepSlotHonestVIdx
  rw [dif_pos hal, dif_pos hbl, kvE2_ordRank_eq_iff,
    kvE2_sepSlotV_get, kvE2_sepSlotV_get, hga, hgb]

/-- **Honest consistency, tie-reporting payload** (Phase 9 conjunct (ii)): the payload
    `block.map kvE2_sepSlotHonestVIdx` extends every region order. Own-slot ties CANNOT occur:
    within a region the owner's rank-ordered slot values are STRICTLY increasing — its base
    witnesses lie strictly inside their sub-intervals, strictly separated from the own anchor
    (`kvE2_sepSlotValue_region_rank_mono`, fed by the honest bundles) — so the value-only ranks
    are strictly increasing (`kvE2_sepSlotHonestVIdx_mono`); ties can only be CROSS-owner. -/
theorem kvE2_sepConsistentBlock_honestV {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) :
    kvE2_sepConsistentBlock σ
      ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) = true := by
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq]
  intro j k hreg hrank
  rw [kvE2_sepBlockMap_getD, kvE2_sepBlockMap_getD]
  have hjmem : (kvE2_sepSlotBlock σ).get j ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  have hkmem : (kvE2_sepSlotBlock σ).get k ∈ kvE2_sepSlotBlock σ := List.get_mem _ _
  refine kvE2_sepSlotHonestVIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ hjmem) (kvE2_sepMem_allSlots qnf hσ hkmem) ?_
  exact kvE2_sepSlotValue_region_rank_mono qnf M w x t hxw hwt h hσ hjmem hkmem hreg hrank

/-- The anchor slot's honest value is its owner's canonical anchor value (both placement
    branches are definitional instances of `kvE2_sepSlotValue_lX1`/`_rX1`). -/
theorem kvE2_sepSlotValue_anchorSlot {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) :
    kvE2_sepSlotValue qnf M w x t h (kvE2_sepAnchorSlot σ)
      = kvE2_sepAnchorVal qnf M w x t h σ := by
  rw [kvE2_sepAnchorSlot]; split <;> rfl

/-- **Base-slot honest realization** (Phase 9 conjunct-(iv) ingredient): every base slot of a
    positive owner's block realizes its base type AT its own honest slot value. Dispatches the
    block membership over the region-block constructors and reads each case off its banked
    Phase-6 value spec (the anchor slots carry no base type and are excluded by `hbt`). -/
theorem kvE2_sepSlotValue_baseType_spec {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {τ : NormalForm sig 1 4} (hτ : τ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock τ)
    {χ : NormalForm sig 0 1} (hbt : kvE2_sepSlotBaseType s = some χ) :
    nf_eval_nf M 0 1 (fun _ => kvE2_sepSlotValue qnf M w x t h s) χ := by
  rw [kvE2_sepMem_slotBlock] at hs
  by_cases hz1 : nf0_zoneSpec τ.1 = kvE2_sep_zXW3
  · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_pos hz1, if_pos hz1] at hs
    rcases hs with hL | hR
    · rcases List.mem_append.mp hL with h1 | h1
      · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
        simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
        subst hbt
        exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h τ hτ hz1 _ hχ').2.2
      · rcases List.mem_cons.mp h1 with rfl | h1
        · simp [kvE2_sepSlotBaseType] at hbt
        · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
          subst hbt
          exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h τ hτ hz1 _ hχ').2.2
    · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp hR
      simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
      subst hbt
      exact (kvE2_sepSlotValue_lWT_spec qnf M w x t h τ hτ _ hχ').2.2
  · by_cases hz2 : nf0_zoneSpec τ.1 = kvE2_sep_zWT3
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_pos hz2, if_pos hz2] at hs
      rcases hs with hL | hR
      · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp hL
        simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
        subst hbt
        exact (kvE2_sepSlotValue_rXW_spec qnf M w x t h τ hτ _ hχ').2.2
      · rcases List.mem_append.mp hR with h1 | h1
        · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
          simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
          subst hbt
          exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h τ hτ hz2 _ hχ').2.2
        · rcases List.mem_cons.mp h1 with rfl | h1
          · simp [kvE2_sepSlotBaseType] at hbt
          · obtain ⟨χ', hχ', rfl⟩ := List.mem_map.mp h1
            simp only [kvE2_sepSlotBaseType, Option.some.injEq] at hbt
            subst hbt
            exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h τ hτ hz2 _ hχ').2.2
    · rw [kvE2_sepSlotsLFor, kvE2_sepSlotsRFor, if_neg hz1, if_neg hz1,
        if_neg hz2, if_neg hz2] at hs
      simp only [List.not_mem_nil, or_self] at hs

/-- **The tie-REPORTING honest order**: all interior owners
    `.coincident`-tagged with the value-ONLY rank payload `block.map kvE2_sepSlotHonestVIdx`.
    Structural mirror of `kvE2_sepHonestOrder` with the tie-reporting payload: where
    `kvE2_sepHonestOrder`'s lex tiebreak forces singleton tie classes, this order's payload
    is EQUAL exactly where honest values coincide, so a genuinely-tied honest model yields
    genuinely non-singleton tie classes under the tie-admitting carrier (Def 3.1 equality
    case, p.4). Tie classes remain index-level data only (strict-quotient guard). -/
noncomputable def kvE2_sepHonestOrder' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : KvE2SepWeakOrder sig :=
  (kvE2_sepPosI qnf).zipIdx.map
    (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
      (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))

/-- The tie-reporting honest order is present in the enumeration index (F2): a
    `kvE2_sepOrderTypes_mem_aux'` instance (`s = 0`, all-coincident tags, value-rank tuple);
    every tuple component `< n` from `kvE2_ordRank_lt`. UNCONDITIONAL: carrier and enumeration
    fold both range over the interior index `kvE2_sepPosI`. -/
theorem kvE2_sepHonestOrder'_mem_orderTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder' qnf M w x t h ∈ kvE2_sepOrderTypes qnf := by
  rw [kvE2_sepHonestOrder', kvE2_sepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' (fun _ => KvE2SepSpikeOrderType.coincident) _
    (fun σ => (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h))
    (kvE2_sepPosI qnf) 0 (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2_sepAllSlots qnf).length
    ((kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestVIdx qnf M w x t h)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      have hidx := kvE2_sepSlotIndexOf_lt qnf
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs)
      rw [kvE2_sepSlotHonestVIdx, dif_pos hidx]
      exact kvE2_ordRank_lt _ _)
  rwa [List.length_map] at h

/-- **Anchor-distinct conjunct (iii′) for the tie-reporting order** (Phase 9): cross-owner
    ANCHOR payload indices are pairwise distinct. The 5A keystone route: distinct interior
    owners have distinct anchor VALUES (`kvE2_sepAnchor_injOn` via `nf_eval_unique` — the
    Lean-side pruning with no Rabinovich counterpart, D7), and the value-only rank is
    injective on distinct values (`kvE2_ordRank_eq_iff` both ways). Reads no zone bit. -/
theorem kvE2_sepHonestOrder'_anchorDistinct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepAnchorDistinct (kvE2_sepHonestOrder' qnf M w x t h) = true := by
  rw [kvE2_sepHonestOrder', kvE2_sepAnchorDistinct, decide_eq_true_eq, List.map_map]
  have hcongr : ((kvE2_sepPosI qnf).zipIdx.map
        (kvE2_sepAnchorPayload ∘
          (fun p => (p.1, KvE2SepSpikeOrderType.coincident,
            (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestVIdx qnf M w x t h)))))
      = (kvE2_sepPosI qnf).zipIdx.map
          (fun p => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot p.1)) := by
    apply List.map_congr_left
    intro p hp
    exact kvE2_sepAnchorPayload_map _ KvE2SepSpikeOrderType.coincident
      (kvE2_sepPosI_zone (List.fst_mem_of_mem_zipIdx hp))
  rw [hcongr]
  have hfst : (kvE2_sepPosI qnf).zipIdx.map
        (fun p => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot p.1))
      = (kvE2_sepPosI qnf).map
          (fun σ => kvE2_sepSlotHonestVIdx qnf M w x t h (kvE2_sepAnchorSlot σ)) := by
    conv_rhs => rw [← List.zipIdx_map_fst 0 (kvE2_sepPosI qnf)]
    rw [List.map_map]
    rfl
  rw [hfst]
  refine List.Nodup.map_on (fun σ hσ τ hτ heq => ?_) (kvE2_sepPosI_nodup qnf)
  have hσa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hσ)
  have hτa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hτ)
  have hveq := (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hσa)
    (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hτa)).mp heq
  rw [kvE2_sepSlotValue_anchorSlot, kvE2_sepSlotValue_anchorSlot] at hveq
  exact kvE2_sepAnchor_injOn qnf M w x t h
    (kvE2_sepPosI_subset hσ) (kvE2_sepPosI_subset hτ) hveq

/-- **Tie-class validity conjunct (iv) for the tie-reporting order** (Phase 9 — the conjunct
    the Phase 8 (a) discharges were shaped for): every anchor-involved payload tie is
    discharged. Route: `kvE2_sepTieRead_of_discharge` reduces (iv) to the per-(anchor,
    base-χ) obligation; equal value-only ranks give equal honest slot VALUES
    (`kvE2_sepSlotHonestVIdx_eq_iff`); the anchor slot's honest value is its owner's
    `kvE2_sepAnchorVal` and the base slot's value realizes χ
    (`kvE2_sepSlotValue_baseType_spec`), so χ is realized AT the anchor value — exactly
    `kvE2_sepClosedLeafAt_discharge_honest`. F5: the only key entering the read is the CLOSED
    self-zone key; base-base ties are read-free (machine-checked in the intro rule). -/
theorem kvE2_sepHonestOrder'_tieRead {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepTieRead (kvE2_sepHonestOrder' qnf M w x t h) = true := by
  apply kvE2_sepTieRead_of_discharge
  intro p hp q hq sj hsj sk hsk hanch heq χ hbt
  rw [kvE2_sepHonestOrder'] at hp hq
  obtain ⟨p', hp', rfl⟩ := List.mem_map.mp hp
  obtain ⟨q', hq', rfl⟩ := List.mem_map.mp hq
  have hσI : p'.1 ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hp'
  have hτI : q'.1 ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hq'
  obtain ⟨hjlt, hjeq⟩ := List.getElem?_eq_some_iff.mp
    (List.mem_zipIdx_iff_getElem?.mp hsj)
  obtain ⟨hklt, hkeq⟩ := List.getElem?_eq_some_iff.mp
    (List.mem_zipIdx_iff_getElem?.mp hsk)
  have hread1 : ((kvE2_sepSlotBlock p'.1).map
        (kvE2_sepSlotHonestVIdx qnf M w x t h)).getD sj.2 0
      = kvE2_sepSlotHonestVIdx qnf M w x t h ((kvE2_sepSlotBlock p'.1).get ⟨sj.2, hjlt⟩) :=
    kvE2_sepBlockMap_getD p'.1 _ ⟨sj.2, hjlt⟩
  have hread2 : ((kvE2_sepSlotBlock q'.1).map
        (kvE2_sepSlotHonestVIdx qnf M w x t h)).getD sk.2 0
      = kvE2_sepSlotHonestVIdx qnf M w x t h ((kvE2_sepSlotBlock q'.1).get ⟨sk.2, hklt⟩) :=
    kvE2_sepBlockMap_getD q'.1 _ ⟨sk.2, hklt⟩
  simp only [List.get_eq_getElem, hjeq, hkeq] at hread1 hread2
  rw [hread1, hread2] at heq
  have hjm : sj.1 ∈ kvE2_sepSlotBlock p'.1 := hjeq ▸ List.getElem_mem hjlt
  have hkm : sk.1 ∈ kvE2_sepSlotBlock q'.1 := hkeq ▸ List.getElem_mem hklt
  -- Equal value-only ranks report equal honest slot VALUES (the tie-reporting law).
  have hveq : kvE2_sepSlotValue qnf M w x t h sj.1 = kvE2_sepSlotValue qnf M w x t h sk.1 :=
    (kvE2_sepSlotHonestVIdx_eq_iff qnf M w x t h
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσI) hjm)
      (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτI) hkm)).mp heq
  -- The anchor slot's honest value is its owner's canonical anchor value.
  have hanchval : kvE2_sepSlotValue qnf M w x t h sj.1
      = kvE2_sepAnchorVal qnf M w x t h p'.1 := by
    have hsub : kvE2_sepSlotSub sj.1 = p'.1 := kvE2_sepSlotSub_of_mem_block hjm
    cases hs1 : sj.1 with
    | lX1 ρ =>
      rw [hs1] at hsub
      simp only [kvE2_sepSlotSub] at hsub
      rw [hsub, kvE2_sepSlotValue_lX1]
    | rX1 ρ =>
      rw [hs1] at hsub
      simp only [kvE2_sepSlotSub] at hsub
      rw [hsub, kvE2_sepSlotValue_rX1]
    | lXU ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | lUW ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | lWT ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rXW ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rWX1 ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
    | rX1T ρ χ' => rw [hs1] at hanch; simp [kvE2_sepSlotIsAnchor] at hanch
  -- The tied base slot realizes χ at its own honest value = the anchor value.
  have hχreal := kvE2_sepSlotValue_baseType_spec qnf M w x t hxw hwt h
    (kvE2_sepPosI_subset hτI) hkm hbt
  rw [← hveq, hanchval] at hχreal
  exact kvE2_sepClosedLeafAt_discharge_honest qnf M w x t hxw hwt h hσI χ hχreal

/-- **The tie-reporting honest order is a carrier member** (the membership
    `kvE2_sepBody_complete_holds'` wires into the completeness hand-off). UNCONDITIONAL:
    owner interiority is a construction invariant of the `kvE2_sepPosI` index (Rabinovich §5,
    p.7), recovered via `kvE2_sepPosI_zone`, never hypothesized. The `kvE2_sepDisjValid`
    conjuncts: (i) all-`.coincident` validity reuses
    `kvE2_sepCoincidentOwner_valid_left/right` VERBATIM (tuple-agnostic, CLOSED self-zone
    bit only); (ii) consistency via `kvE2_sepConsistentBlock_honestV` (own-slot ties cannot
    occur — the owner's own region values are strictly separated); (iii′) anchor-distinct
    via the 5A keystone (D7 — Lean-side pruning, no paper counterpart); (iv) tie-class reads
    via the Phase 8 (a) foreign-base CLOSED-key discharges. Unlike
    `kvE2_sepHonestOrder_mem_arr'`, the tie conjuncts are NOT vacuous here: the payload
    admits genuine cross-owner ties, and (iv) discharges them honestly. -/
theorem kvE2_sepHonestOrder'_mem_arr' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepHonestOrder' qnf M w x t h ∈ kvE2_sepArr' qnf := by
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepHonestOrder'_mem_orderTypes qnf M w x t h, ?_⟩
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- (i) per-owner closed-self-zone validity (all tags `.coincident`), reused verbatim
    -- (definitional interiority via `kvE2_sepPosI_zone` — a construction invariant).
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder', List.mem_map] at hp
    obtain ⟨⟨σ, i⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    change kvE2_sepDisjValidOwner σ KvE2SepSpikeOrderType.coincident = true
    rcases kvE2_sepPosI_zone hσmem with hzone | hzone
    · exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
    · exact kvE2_sepCoincidentOwner_valid_right qnf M w x t hxw hwt h σ
        (kvE2_sepPosI_subset hσmem) hzone
  · -- (ii) per-owner region-scoped consistency via the value-only monotonicity engine.
    rw [List.all_eq_true]
    intro p hp
    rw [kvE2_sepHonestOrder', List.mem_map] at hp
    obtain ⟨⟨σ, k⟩, hmem, rfl⟩ := hp
    have hσmem : σ ∈ kvE2_sepPosI qnf := List.fst_mem_of_mem_zipIdx hmem
    exact kvE2_sepConsistentBlock_honestV qnf M w x t hxw hwt h (kvE2_sepPosI_subset hσmem)
  · -- (iii′) anchor-distinct: the 5A keystone route (D7).
    exact kvE2_sepHonestOrder'_anchorDistinct qnf M w x t h
  · -- (iv) tie-class reads: the Phase 8 (a) foreign-base CLOSED-key discharges.
    exact kvE2_sepHonestOrder'_tieRead qnf M w x t hxw hwt h

/-- **The target completeness statement — `kvE2_sepBody_complete_holds'`** (report 07
    §4 shape; the PRIMARY completeness hand-off of this development). Given an honest
    realization and the realization of the tie-reporting honest order's own GROUPED disjunct
    (`hdisj`, taken over the tie-grouped `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)` —
    NOT flattened through a singleton conversion), the separated body holds at the fixed
    endpoints. No `hLR`-style hypothesis: owners are drawn from the interior index
    `kvE2_sepPosI` (Rabinovich §5, p.7; `kvE2_sepHonest_hLR_absurd` certifies why no such
    hypothesis may return). Because `kvE2_sepHonestOrder'`'s payload reports ties, this
    statement covers genuinely-tied honest models — the models whose tie classes are
    non-singleton — which the Phase 7 singleton variant `kvE2_sepBody_complete_holds`
    (retained below as the degenerate flat-`hdisj` corollary shape) cannot express. Complete
    and axiom-clean UP TO the delegated `.holds` — the sanctioned completion boundary. -/
theorem kvE2_sepBody_complete_holds' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hdisj : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t := by
  rw [kvE2_sepBody_holds_iff charBase charK qnf hg M atomMap x t]
  exact ⟨kvE2_sepHonestOrder' qnf M w x t h,
    kvE2_sepHonestOrder'_mem_arr' qnf M w x t hxw hwt h, hdisj⟩

/-! ### The O3 extraction theorems -/

/-- **O3 — joint soundness extraction from a realized disjunct** (report 07 §2.4
    `kvE2_sepConj_sharedW` shape, Candidate C staging): from a realized
    joint disjunct over valid interleavings, extract BOTH joint endpoint realizations, the
    ONE shared witness `w` (the `ptW` slot at position `|lL|`; `x < w < t` from the
    bracket's OWN range — FM-x1t), and at that SAME `w` the per-σ witness bundle for every
    positive interior σ of either class. Each witness position is read structurally off
    the arrangement's slot indices via Def 3.1 monotone enumeration (PDF p.4) — never an
    `x1 < e_i` literal (LITMUS); each σ's `zXU`/`zWX1` interior content is realized
    strictly below σ's fresh slot by the region-rank validity (Cor 5.4, PDF p.5;
    Lemma 3.2(1), PDF p.3 at the interleaving membership). The coverage
    hypotheses `hmemL`/`hmemR` quantify over the interior index `kvE2_sepPosI` (the carrier's
    own owner index); the bundle conclusions stay zone-guarded over `kvE2_sepPos`, with
    interiority upgraded via `kvE2_sepPosI_mem`. -/
theorem kvE2_sepDisjunct_extract {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    {lL lR : List (KvE2SepSlot sig)}
    (hmemL : ∀ σ ∈ kvE2_sepPosI qnf, ∀ s ∈ kvE2_sepSlotsLFor σ, s ∈ lL)
    (hpairL : lL.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (hmemR : ∀ σ ∈ kvE2_sepPosI qnf, ∀ s ∈ kvE2_sepSlotsRFor σ, s ∈ lR)
    (hpairR : lR.Pairwise (fun a b => kvE2_sepSlotLe a b = true))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t) := by
  obtain ⟨hepL, hepR, hbr⟩ := h
  refine ⟨hepL, hepR, ?_⟩
  -- Destructure the realized N-slot bracket (Def 3.1 monotone enumeration, PDF p.4).
  simp only [kvE2_sepDisjunct, kvE2_sepBracketN, BracketFormula.holds,
    BracketFormula.toIntervalPattern] at hbr
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show (lL.map (kvE2_sepSlotType charBase charK)).length + 1
        + (lR.map (kvE2_sepSlotType charBase charK)).length
      = (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1 by omega)] at hbr
  obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩ := hbr
  -- Canonical point-type reads (defeq re-typing; template `SubBracket2V.lean:699-702`).
  have hpt' : ∀ (i : Nat) (hi : i < (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1),
      ((lL.map (kvE2_sepSlotType charBase charK)
          ++ kvE2_sepPtW charBase charK qnf
            :: lR.map (kvE2_sepSlotType charBase charK))[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩,
    (hrange _).1, (hrange _).2, ?_, ?_, ?_⟩
  · -- The shared `ptW` realization at position `|lL|` (§5 bracket, PDF p.7).
    have h1 := hpt' (lL.map (kvE2_sepSlotType charBase charK)).length (by omega)
    rwa [kvE2_sep_getElem_mid] at h1
  · -- LEFT-interior bundles: σ's fresh slot occurs in the LEFT interleaving.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inl hzone⟩
    obtain ⟨iσ, hiσ, hgetiσ⟩ := List.mem_iff_getElem.mp
      (hmemL σ hσI _ (kvE2_sep_lX1_mem_slotsLFor hzone))
    have hiσm : iσ < (lL.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨iσ, by omega⟩, (hrange _).1,
      hmono _ _ (Fin.mk_lt_mk.mpr hiσm), ?_, ?_⟩
    · -- σ's folded fresh point type at its own slot (Lemma 5.1, PDF p.3).
      have h1 := hpt' iσ (by omega)
      rwa [kvE2_sep_getElem_left _ _ _ iσ hiσm, List.getElem_map, hgetiσ] at h1
    · -- Every `zXU`-positive 1-type strictly below σ's fresh slot (region-rank validity).
      intro χ hbit
      obtain ⟨jχ, hjχ, hgetjχ⟩ := List.mem_iff_getElem.mp
        (hmemL σ hσI _ (kvE2_sep_lXU_mem_slotsLFor hzone hbit))
      have hji : jχ < iσ := kvE2_sep_index_lt_of_rank_lt hpairL
        hiσ hjχ (by rw [hgetjχ, hgetiσ]; rfl) (by rw [hgetjχ, hgetiσ]; exact Nat.zero_lt_one)
      have hjχm : jχ < (lL.map (kvE2_sepSlotType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨jχ, by omega⟩, (hrange _).1,
        hmono _ _ (Fin.mk_lt_mk.mpr hji), ?_⟩
      have h1 := hpt' jχ (by omega)
      rwa [kvE2_sep_getElem_left _ _ _ jχ hjχm, List.getElem_map, hgetjχ] at h1
  · -- RIGHT-interior bundles (mirrored): σ's fresh slot occurs in the RIGHT interleaving.
    intro σ hσpos hzone
    have hσI : σ ∈ kvE2_sepPosI qnf :=
      (kvE2_sepPosI_mem qnf σ).mpr ⟨hσpos, Or.inr hzone⟩
    obtain ⟨jσ, hjσ, hgetjσ⟩ := List.mem_iff_getElem.mp
      (hmemR σ hσI _ (kvE2_sep_rX1_mem_slotsRFor hzone))
    have hjσm : jσ < (lR.map (kvE2_sepSlotType charBase charK)).length := by
      simp only [List.length_map]; omega
    refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ, by omega⟩,
      hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), (hrange _).2, ?_, ?_⟩
    · have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + jσ)
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ jσ hjσm, List.getElem_map, hgetjσ] at h1
    · intro χ hbit
      obtain ⟨j', hj', hgetj'⟩ := List.mem_iff_getElem.mp
        (hmemR σ hσI _ (kvE2_sep_rWX1_mem_slotsRFor hzone hbit))
      have hji : j' < jσ := kvE2_sep_index_lt_of_rank_lt hpairR
        hjσ hj' (by rw [hgetj', hgetjσ]; rfl) (by rw [hgetj', hgetjσ]; exact Nat.zero_lt_one)
      have hj'm : j' < (lR.map (kvE2_sepSlotType charBase charK)).length := by
        simp only [List.length_map]; omega
      refine ⟨ws ⟨(lL.map (kvE2_sepSlotType charBase charK)).length + 1 + j', by omega⟩,
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)),
        hmono _ _ (Fin.mk_lt_mk.mpr (by omega)), ?_⟩
      have h1 := hpt' ((lL.map (kvE2_sepSlotType charBase charK)).length + 1 + j')
        (by omega)
      rwa [kvE2_sep_getElem_right _ _ _ j' hj'm, List.getElem_map, hgetj'] at h1

/-- **Shared-`w` pivot for the joint disjunct** (Lemma 5.1, PDF p.6/PDF p.8 — the
    `A_i^-`/`A_i^+` split at the index of the ONE shared `ptW` slot): from a realized
    joint disjunct, the shared witness realizes `kvE2_sepPtW` and BOTH halves of the
    count-normalized joint bracket hold at it — through the CONSUMED kit
    `kvE2_sepBracket_split_at` = `BracketFormula.leftPart_holds`/`rightPart_holds` (D4).
    The halves carry the refined-conjunction segment realizations for the Phase 9 (O4)
    `hgate` derivation. -/
theorem kvE2_sepDisjunct_halves {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (h : (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      ((kvE2_sepCastBracket
          (n := (lL.map (kvE2_sepSlotType charBase charK)).length
            + (lR.map (kvE2_sepSlotType charBase charK)).length + 1)
                (by simp only [kvE2_sepDisjunct]; omega)
          (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).leftPart
        ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩).holds
          M atomMap x w ∧
      ((kvE2_sepCastBracket
          (n := (lL.map (kvE2_sepSlotType charBase charK)).length
            + (lR.map (kvE2_sepSlotType charBase charK)).length + 1)
                (by simp only [kvE2_sepDisjunct]; omega)
          (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).rightPart
        ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩).holds
          M atomMap w t := by
  obtain ⟨-, -, hbr⟩ := h
  have hbr' := (kvE2_sepCastBracket_holds M atomMap
    (n := (lL.map (kvE2_sepSlotType charBase charK)).length
      + (lR.map (kvE2_sepSlotType charBase charK)).length + 1)
          (by simp only [kvE2_sepDisjunct]; omega)
    ((kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket) x t).mpr hbr
  obtain ⟨w, hxw, hwt, hptw, hleft, hright⟩ := kvE2_sepBracket_split_at M atomMap _ x t
    ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩ hbr'
  refine ⟨w, hxw, hwt, ?_, hleft, hright⟩
  have h2 : (kvE2_sepCastBracket
      (n := (lL.map (kvE2_sepSlotType charBase charK)).length
        + (lR.map (kvE2_sepSlotType charBase charK)).length + 1)
            (by simp only [kvE2_sepDisjunct]; omega)
      (kvE2_sepDisjunct charBase charK qnf lL lR).2.bracket).pointTypes
      ⟨(lL.map (kvE2_sepSlotType charBase charK)).length, by omega⟩
      = kvE2_sepPtW charBase charK qnf := kvE2_sep_getElem_mid _ _ _
  rwa [h2] at hptw

-- NOTE: the former side-condition-laden `kvE2_sepBody_extract`
-- (universal `hpairL`/`hpairR`/`hnd` over all `wo ∈ kvE2_sepArr' qnf` — FALSE for general
-- `qnf`, machine-checked blocker record above at the R2 section) and its tie-free singleton
-- conversion were REPLACED by the hypothesis-free tie-admitting pair
-- `kvE2_sepDisjunct'_extract` / `kvE2_sepBody_extract` below (after the tie-run index
-- lemmas they consume). `kvE2_sepTieGroupedL/R_of_nodup` and
-- `kvE2_sepDisjunct'_map_singleton_iff` remain — the completeness side still uses them.

/-! ## Phase 9 (O4) — carrier-side per-σ `hgate` derivation: the derivable core

The `hgate` bundle the downstream closers consume (`kvE_subBracket2V_sound_of_parts`
`SubBracket2V.lean:1025`, spec verbatim at `kvE_subBracket2V_correctness_pair`
`:1868-1882`) has six conjuncts. The lemmas in this section derive the pieces the joint
carrier's realized content DOES determine: the arity-4 nine-zone consistency (the N-point
re-derivation of the private template `kvE_sub2V_zone_consistent`, `SubBracket2V.lean:1270`),
the inner off-fiber conjunct (gate clause (iii)), the inner nine-zone falsity clause (gate
clause (iv)), and the refined-segment exclusion channel (Cor 5.4, PDF p.5: a bit-false
1-type is excluded throughout every realized refined sub-interval). -/

/-- Any zone spec realized by a point over the anchor env `[x1, w, x, t]` with
    `x < x1 < w < t` is one of the NINE order-consistent inner zones
    `kvE2_sepInnerConsistentL` (Def 3.1, PDF pp.2-3: disjunctions range only over consistent
    order types). Public arity-4 re-derivation of the PRIVATE template
    `kvE_sub2V_zone_consistent` (`SubBracket2V.lean:1270`, template only); its
    contrapositive discharges the inconsistent-zone cases of the `hgate`
    forward-zone conjunct. Prop 3.5 (PDF p.3) at each navigation literal: every case is a
    pure order-trichotomy read of the evaluation point `u` against the env — no
    `x1 < e_i` literal (LITMUS). -/
theorem kvE2_sep_zone4_consistent {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t u : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs u) :
    kvE2_sepInnerConsistentL zs := by
  unfold kvE2_sepInnerConsistentL
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  have h3 := hz ⟨3, by omega⟩
  simp only [Fin.cons] at h0 h1 h2 h3
  have hzs : ∀ (p0 p1 p2 p3 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
        zs ⟨3, by omega⟩ = p3 →
      zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
    intro p0 p1 p2 p3 e0 e1 e2 e3
    funext i
    match i with
    | ⟨0, _⟩ => exact e0
    | ⟨1, _⟩ => exact e1
    | ⟨2, _⟩ => exact e2
    | ⟨3, _⟩ => exact e3
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x : zPastX
    have hux1 : u < x1 := hux.trans hxx1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hux, k1v_bool_eq_false h2.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxx1, k1v_bool_eq_false h0.2 (lt_asymm hxx1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hxw, k1v_bool_eq_false h1.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
        k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hxt, k1v_bool_eq_false h3.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against x1
    rcases lt_trichotomy u x1 with hux1 | hux1 | hux1
    · -- x < u < x1 : zXU
      have huw : u < w := hux1.trans hx1w
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))
    · -- u = x1 : zAtX1
      subst hux1
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hx1w, k1v_bool_eq_false h1.2 (lt_asymm hx1w)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxx1), h2.2.mp hxx1⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hx1t, k1v_bool_eq_false h3.2 (lt_asymm hx1t)⟩)))))
    · -- x1 < u : split against w
      rcases lt_trichotomy u w with huw | huw | huw
      · -- x1 < u < w : zUW
        have hut : u < t := huw.trans hwt
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux1), h0.2.mp hux1⟩)
          (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))
      · -- u = w : zAtW
        subst huw
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1w), h0.2.mp hx1w⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
            k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxw), h2.2.mp hxw⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hwt, k1v_bool_eq_false h3.2 (lt_asymm hwt)⟩)))))))
      · -- w < u : split against t
        have hx1u : x1 < u := hx1w.trans huw
        have hxu : x < u := hxw.trans huw
        rcases lt_trichotomy u t with hut | hut | hut
        · -- w < u < t : zWT
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))))
        · -- u = t : zAtT
          subst hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_irrefl u),
              k1v_bool_eq_false h3.2 (lt_irrefl u)⟩)))))))))
        · -- t < u : zFutT
          have hx1u' : x1 < u := hx1t.trans hut
          have hxu' : x < u := hxt.trans hut
          have hwu' : w < u := hwt.trans hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u'), h0.2.mp hx1u'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu'), h1.2.mp hwu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_asymm hut), h3.2.mp hut⟩)))))))))

/-- `hgate` conjunct — INNER OFF-FIBER falsity for a positive σ (spec conjunct at
    `SubBracket2V.lean:1872`), read directly off joint gate clause (iii): the depth-2 gate
    already carries this conjunct model-independently for EVERY positive sub. -/
theorem kvE2_sepHgate_offFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hσ : qnf.2 σ = true) :
    ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false :=
  hg.2.2.1 σ hσ

/-- Joint gate clause (iv) surfaced for the O4 pipeline: inner NINE-zone falsity for a
    left-interior positive σ. Combined with `kvE2_sep_zone4_consistent`'s contrapositive
    this discharges the `hgate` forward-zone conjunct (`SubBracket2V.lean:1873-1877`) for
    every INCONSISTENT zone pattern: no model point realizes such a zone, and its fold bit
    is `false`. -/
theorem kvE2_sepHgate_innerNine {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (hg : kvE2_sepGate qnf)
    (σ : NormalForm sig 1 4) (hσ : qnf.2 σ = true)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ kvE2_sepInnerConsistentL zs →
      σ.2 (nf0_assemble zs χ σ.1) = false :=
  hg.2.2.2.1 σ hσ hzone

/-- **Refined-segment exclusion channel** (Cor 5.4, PDF p.5 — the quantifier-free
    segment read; Lemma 5.1, PDF p.3 at the segment formula's quantifier-free shape): a
    realized per-σ exclusion segment falsifies every bit-FALSE 1-type at its point. This is
    the ONLY carrier channel that converts model facts on the OPEN refined sub-intervals
    into fold-bit information; its contrapositive is the `hgate` forward-zone conjunct
    restricted to segment-interior points. -/
theorem kvE2_sepSegForm_excludes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (σ : NormalForm sig 1 4) (zs : ZoneSpec 4) (χ : NormalForm sig 0 1)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (u : M.carrier)
    (h : (⟨kvE2_sepSegForm charBase σ zs⟩ : TemporalPred).eval_at M atomMap u)
    (hbit : kvE2_sepBits σ zs χ = false) :
    ¬ (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  simp only [kvE2_sepSegForm, TemporalPred.eval_at] at h
  rw [formula_conjList_iff] at h
  have hneg := h ((charBase χ).neg)
    (List.mem_map.mpr ⟨χ, by simp, by simp [hbit]⟩)
  simp only [TemporalPred.eval_at, Formula.neg, temporal_truth] at hneg ⊢
  exact hneg

/-! ## O4 CRUX RECORD — verdict: **FAIL** (inert; decision-gate input)

**This is NOT a route NO-GO.** The derivable core above (`kvE2_sep_zone4_consistent`,
`kvE2_sepHgate_offFiber`, `kvE2_sepHgate_innerNine`, `kvE2_sepSegForm_excludes`) plus the
biconditional endpoint/witness literals (`kvE2_sepEpL`/`EpR`/`PtW`/`PtX1L` — covering the
six at/exterior inner zones `zPastX4`/`zAtX4`/`zAtX1L`/`zAtWL`/`zAtT4`/`zFutT4` in BOTH
directions) and σ's OWN slot channel (its `kvE2_sepS`-enumerated bit-true 1-types realized
at its `lXU`/`lUW`/`lWT` slots) determine five of the six `hgate` conjuncts
(`SubBracket2V.lean:1868-1882`) at the extracted anchor. What fails is exactly the
forward-zone conjunct (`:1873-1877`) at a CROSS-σ slot point — the residue both prior
handoffs flagged ("bracket points inside another σ's zone are not covered by segment
exclusions; points sit between segments").

**Captured crux (`lean_goal`, minimal instance; hypothesis set is the FULL superset — the
realized joint disjunct `h` itself, arrangement memberships `hL`/`hR`, the gate `hg`, and
every Phase-8-extractable fact `hepL`/`hepR`/`hptW`/`hptX1`/`hbundleL`, so the failure is
not attributable to a dropped input).** With σ, τ distinct left-interior positives,
`hτbit : kvE2_sepBits τ kvE_sub2_zXU χ = true`, and τ's χ-slot interleaved before σ's
fresh slot (`kvE2_sepSlotLe` leaves cross-σ order free), the slot's witness `v` satisfies
`x < v < x1` with `hχv : nf_eval_nf M 0 1 (fun _ => v) χ` in EVERY realization of that
arrangement, and the forward-zone conjunct instantiated at `v` demands:

    ⊢ σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true

**Failed closers on the captured crux (five):**
  1. `exact hτbit` → *Type mismatch: has type `kvE2_sepBits τ kvE_sub2_zXU χ = true` but
     is expected to have type `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`.* τ's bit does
     not transfer to σ — the carrier has NO cross-σ bit channel.
  2. `simp_all [kvE2_sepBits, kvE2_sepGate, kvE2_sepInnerConsistentL]` → unfolds the gate
     to its four clauses; goal UNSOLVED. All four gate clauses conclude `… = false`
     (off-fiber ×2, inconsistent-zone ×2); no clause in the entire carrier concludes a
     bit-TRUE for σ from another σ's data.
  3. `exact hg.2.2.2 σ hσ hσzone kvE_sub2_zXU χ (by simp [kvE2_sepInnerConsistentL])` →
     residual sub-goal `¬ kvE_sub2_zXU = …` over the nine consistent patterns is FALSE
     (`kvE_sub2_zXU` IS the third consistent pattern), and the clause's conclusion has the
     wrong polarity (`= false`) besides.
  4. `exact kvE2_sepSegForm_excludes … v (by assumption) (by assumption)` → leaves goals
     `TemporalPred.eval_at M atomMap' ⟨kvE2_sepSegForm … σ kvE_sub2_zXU⟩ v` (unprovable:
     `v` is a bracket POINT — the realized disjunct asserts segments only on the OPEN
     intervals between consecutive witnesses, never at a witness) and
     `kvE2_sepBits σ kvE_sub2_zXU χ = false` (wrong polarity: the exclusion channel
     consumes a false bit; it cannot produce a true one at a non-segment point).
  5. `aesop` → *failed to prove the goal after exhaustive search.*

**Channel exhaustion (why no derivation exists, not merely none found).** The carrier's
only model-fact→fold-bit channels are: (a) the segment contrapositive
(`kvE2_sepSegForm_excludes`) — fires only at segment-covered points, and `v` is a witness
point between segments; (b) the `kvE2_sepLit` biconditional literals at `x`/`w`/`t`/`x1` —
stated only for the six at/exterior zones, never for the three open interior regions
`zXU`/`zUW`/`zWT`; (c) σ's own slot membership (`kvE2_sepS σ zs` enumerates σ's bit-TRUE
1-types) — τ's slot is not in σ's enumeration. The gate `kvE2_sepGate` contributes only
falsity clauses. Hence `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is underdetermined
by the realized carrier content — the plan's Phase 10 FAIL criterion verbatim ("a per-σ
zone bit required by `hgate` underdetermined by the refined-conjunction segments +
E[Σ]-atom literals").

**Why no ADDITIVE repair closes it (probed at the bit level, not re-designed here):**
  * A conjunctive cross-σ gate clause (`τ`'s `zXU`-bit true → σ's `zXU`- AND `zUW`- AND
    `zAtX1`-bits true for that χ) is sound-sufficient but NOT honest-derivable: an honest
    model may place every χ-point of `(x,w)` strictly above `x1_σ`, leaving σ's `zXU`-bit
    honestly false — the clause would break `kvE2_sepGate_holds_of_honest` and non-vacuity
    (FM-vac, prohibited).
  * The honest-derivable DISJUNCTIVE clause (σ's `zXU`- OR `zAtX1`- OR `zUW`-bit true)
    cannot select the disjunct matching the REALIZED arrangement's placement of τ's slot —
    the Bool disjunction is arrangement-blind while the placement is arrangement-chosen.
  * The faithful repair is BIT-COMPATIBILITY FILTERING of the interleaving enumeration
    (admit an arrangement only when every cross-σ slot placement matches a true bit of
    every other interior positive — Lemma 3.2(1)'s disjunction ranges over CONSISTENT
    refinements, PDF p.3). That re-defines `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR`
    (Phase 7 carrier structure) with knock-on rework of O1b non-vacuity (the canonical
    identity arrangement is no longer always admitted) and the O2/O3 membership plumbing —
    a carrier re-definition outside this phase's additive scope, owned by the Phase 10
    decision gate.

**Second, independent obstruction to the ∀-anchor form (`:1868` binds every
`a ∈ (x,t)` realizing the `charK` anchor).** Conjunct `a < w` requires the right region to
EXCLUDE anchor-realizing points, but the right-region segment content for a left-interior
σ (`kvE2_sepSegRForSub` = `kvE2_sepSegForm … kvE_sub2_zWT`) conjoins only depth-0
`charBase` 1-type negations — the depth-1 `charK (nfk_projFresh σ)` E[Σ]-atom is never
excluded there, and a right-interior τ with `nfk_projFresh τ = nfk_projFresh σ` even
POSITIVELY realizes it above `w` at its `rX1` slot.

**LITMUS.** No `x1 < e_i` relative-position literal was introduced or needed; the
obstruction is a missing arrangement-bit compatibility constraint, not a positioning
literal. Prohibited patches (chain splicing FM-merge, `x1 < e_i`, gate-modulo-assumed
`hgate`, vacuous placeholder, `sorry`) were NOT applied.

**Consequence (Phase 10 routing input).** O4 FAIL → per the plan's decision-gate table the
indicated route is **N2** (single-positive-sub fragment): with ONE interior positive there
are no cross-σ slots — every left-list witness is σ's own bit-true 1-type or the
literal-covered self-zones — so the residue vanishes; this is exactly the configuration
the landed `kvE_subBracket2V_sound_of_outer` (`SubBracket2V.lean:1216`) +
`kvE_sub2V_bounded_anchor_of_outer` (`:1182`) already serve. The derivable core landed
above remains live input to N2's per-σ gate work. This record is additive and inert. -/

/-! ## MAKE-OR-BREAK SPIKE: faithful order-type disjunction composes

The plan-02 additive open-zone filter (`kvE2_sepValid`/`kvE2_sepArrL/R`) was proven FALSE on a
concrete 2-owner coincidence (handoff 05): with a foreign owner τ's χ-witness coinciding EXACTLY
with σ's fresh anchor `x1_σ`, the extractor's reverse channels force σ's OPEN-zone bits
`kvE2_sepBits σ zXU χ = false` and `kvE2_sepBits σ zUW χ = false`, while the CLOSED-zone bit
`kvE2_sepBits σ zAtX1L χ = true` (via `kvE2_sepCoincidentAnchor_discharge`). The additive filter
reads ONLY the open bits, so `kvE2_sepArrL = []` and `kvE2_sepBody_nonvacuous` is FALSE.

This spike ABANDONS the additive-filter framing and builds the faithful Rabinovich Lemma 3.2(1)
form (PDF p.3): an order-type disjunction over the merged anchor set, where EACH disjunct reads the
zone bit appropriate to ITS arrangement — strict disjuncts the OPEN `zXU`/`zUW` bits, the
coincidence disjunct the CLOSED `zAtX1L` bit (§5 meet-typed shared point, PDF p.6). The
coincidence is a first-class DISJUNCT admitted by the closed channel, NOT a tie refuted by an
open-bit inequality. This is per-order-type validity, NOT handoff-05's rejected "Option A" (a
single disjunctive open∨closed filter over the same flat union). -/

end FormalSystem.Metalogic.WeakCanonical.Kamp
