/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Completeness

/-! # Shared-Interior-Witness Joint Carrier — engine inputs

Module E of the `SharedWitness` tower. The honest bundles, the keystone-strict anchor
family and its rank strict-monotonicity, and the per-zone `Nodup`/realization inputs
consumed by the `SubBracket2V` sorted-realization engine. Internal scaffolding: no symbol
here is part of the external contract. -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ### The halign FOUNDATION bridge

The joint sorted lists `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` are `mergeSort`ed by
`kvE2_sepSlotMergeLe`, whose key reader is `kvE2_sepSlotGIdx wo`. On the honest order this reader
projects, at `kvE2_sepBlockPos s`, the payload tuple `block.map kvE2_sepSlotHonestGIdx` — so the
merge key of slot `s` is exactly its value-faithful index `kvE2_sepSlotHonestGIdx … s`. This is the
load-bearing bridge from the structural sort key to the model value order. -/

/-- **halign FOUNDATION bridge**: under the honest order, the mergeSort key
    reader `kvE2_sepSlotGIdx` coincides with the value-faithful per-slot index
    `kvE2_sepSlotHonestGIdx` on every slot of every positive owner's block. Resolves the honest
    order's `find?` (owners are `kvE2_sepPos`-distinct) to `σ`'s payload, then reads it at
    `kvE2_sepBlockPos s` via `kvE2_sepBlockMap_getD` / `List.idxOf_get`. -/
theorem kvE2_sepSlotGIdx_honestOrder {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotBlock σ) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) s
      = kvE2_sepSlotHonestGIdx qnf M w x t h s := by
  have hsub : kvE2_sepSlotSub s = σ := kvE2_sepSlotSub_of_mem_block hs
  have hfind : (kvE2_sepHonestOrder qnf M w x t h).find?
        (fun p => decide (p.1 = kvE2_sepSlotSub s))
      = some (σ, KvE2SepSpikeOrderType.coincident,
          (kvE2_sepSlotBlock σ).map (kvE2_sepSlotHonestGIdx qnf M w x t h)) := by
    rw [hsub, kvE2_sepHonestOrder, List.find?_map]
    have hex : ∃ q ∈ (kvE2_sepPosI qnf).zipIdx,
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))) q = true := by
      have hm : σ ∈ (kvE2_sepPosI qnf).zipIdx.map Prod.fst := by
        rw [List.zipIdx_map_fst]; exact kvE2_sepMem_posI_of_slot hσ hs
      obtain ⟨q, hq, hq1⟩ := List.mem_map.mp hm
      exact ⟨q, hq, by simp [Function.comp, hq1]⟩
    obtain ⟨q, hq, hqp⟩ := hex
    cases hf : (kvE2_sepPosI qnf).zipIdx.find?
        ((fun p => decide (p.1 = σ)) ∘
          (fun p : NormalForm sig 1 4 × ℕ =>
            (p.1, KvE2SepSpikeOrderType.coincident,
              (kvE2_sepSlotBlock p.1).map (kvE2_sepSlotHonestGIdx qnf M w x t h)))) with
    | none =>
      rw [List.find?_eq_none] at hf
      exact absurd hqp (by simpa using hf q hq)
    | some r =>
      have hr := List.find?_some hf
      simp only [Function.comp, decide_eq_true_eq] at hr
      simp [hr]
  unfold kvE2_sepSlotGIdx
  rw [hfind]
  simp only [Option.map_some, Option.getD_some]
  have hidx : kvE2_sepBlockPos s = (kvE2_sepSlotBlock σ).idxOf s := by
    rw [kvE2_sepBlockPos, hsub]
  rw [hidx]
  have hlt : (kvE2_sepSlotBlock σ).idxOf s < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem hs
  rw [List.getD_eq_getElem?_getD, List.getElem?_map, List.getElem?_eq_getElem hlt]
  simp only [Option.map_some, Option.getD_some]
  congr 1
  exact List.idxOf_get hlt

/-- **halign monotonicity**: on the honest order the mergeSort key
    `kvE2_sepSlotGIdx` is strictly monotone in the slot value across the whole family. Composes the
    bridge `kvE2_sepSlotGIdx_honestOrder` with the value-faithful `kvE2_sepSlotHonestGIdx_mono`.
    This is the fact that makes `kvE2_sepSlotsLOf/ROf` a genuinely value-sorted chain. -/
theorem kvE2_sepSlotGIdx_honestOrder_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (hlt : kvE2_sepSlotValue qnf M w x t h a < kvE2_sepSlotValue qnf M w x t h b) :
    kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) a
      < kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) b := by
  rw [kvE2_sepSlotGIdx_honestOrder qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder qnf M w x t h hτ hb]
  exact kvE2_sepSlotHonestGIdx_mono qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) hlt

/-- **halign injectivity**: on the honest order the mergeSort
    key `kvE2_sepSlotGIdx` is injective on the whole slot family. Composes the bridge with the
    value-faithful `kvE2_sepSlotHonestGIdx_injOn`. This is the no-ties fact behind the joint sorted
    lists' `Nodup`. -/
theorem kvE2_sepSlotGIdx_honestOrder_injOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock τ)
    (heq : kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) a
      = kvE2_sepSlotGIdx (kvE2_sepHonestOrder qnf M w x t h) b) :
    a = b := by
  rw [kvE2_sepSlotGIdx_honestOrder qnf M w x t h hσ ha,
      kvE2_sepSlotGIdx_honestOrder qnf M w x t h hτ hb] at heq
  exact kvE2_sepSlotHonestGIdx_injOn qnf M w x t h
    (kvE2_sepMem_allSlots qnf hσ ha) (kvE2_sepMem_allSlots qnf hτ hb) heq

/-! ### Value-sorted merged slot lists (halign consumers)

The joint lists `kvE2_sepSlotsLOf/ROf wo` are `mergeSort`ed by the merge key `kvE2_sepSlotMergeLe
wo`
(`= decide (kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b)`). Because that key is a total preorder
(`≤` on the global-index ℕ), `List.pairwise_mergeSort` gives the lists `Pairwise` under the key —
for ANY `wo`. Specialised to the honest order and threaded through the banked halign trio
(`kvE2_sepSlotGIdx_honestOrder{,_mono,_injOn}`), the lists become genuinely value-sorted. These are
the value-sortedness facts P2/P3 consume; they are NOT re-derivations of the trio. -/

/-- The merge key `kvE2_sepSlotMergeLe wo` is transitive (globally, `≤` on ℕ). -/
theorem kvE2_sepSlotMergeLe_trans {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig)
    (a b c : KvE2SepSlot sig)
    (hab : kvE2_sepSlotMergeLe wo a b = true) (hbc : kvE2_sepSlotMergeLe wo b c = true) :
    kvE2_sepSlotMergeLe wo a c = true := by
  simp only [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab hbc ⊢
  exact le_trans hab hbc

/-- The merge key `kvE2_sepSlotMergeLe wo` is total (globally, `≤` on ℕ). -/
theorem kvE2_sepSlotMergeLe_total {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig)
    (a b : KvE2SepSlot sig) :
    kvE2_sepSlotMergeLe wo a b || kvE2_sepSlotMergeLe wo b a := by
  simp only [kvE2_sepSlotMergeLe, Bool.or_eq_true, decide_eq_true_eq]
  exact le_total _ _

/-- **Merge-key sortedness, LEFT**: the joint LEFT slot list is
    `Pairwise` under the merge key `kvE2_sepSlotMergeLe wo`. Direct `List.pairwise_mergeSort`. -/
theorem kvE2_sepSlotsLOf_mergeSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepSlotsLOf wo).Pairwise (fun a b => kvE2_sepSlotMergeLe wo a b = true) := by
  rw [kvE2_sepSlotsLOf]
  exact List.pairwise_mergeSort (kvE2_sepSlotMergeLe_trans wo) (kvE2_sepSlotMergeLe_total wo) _

/-- **Merge-key sortedness, RIGHT** (mirror of `kvE2_sepSlotsLOf_mergeSorted`). -/
theorem kvE2_sepSlotsROf_mergeSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    (kvE2_sepSlotsROf wo).Pairwise (fun a b => kvE2_sepSlotMergeLe wo a b = true) := by
  rw [kvE2_sepSlotsROf]
  exact List.pairwise_mergeSort (kvE2_sepSlotMergeLe_trans wo) (kvE2_sepSlotMergeLe_total wo) _

/-- The wo-ordered owner list projects into any list carrying wo's owner projection:
    `kvE2_sepOrderOwners wo` is a `mergeSort` permutation of `wo.map Prod.fst`. Generic over
    the owner list `L`: enumeration members supply `L = kvE2_sepPosI qnf`
    via `kvE2_sepOrderTypes_owners`; the Phase-4-pending honest order supplies its own direct
    `zipIdx` projection. -/
theorem kvE2_sepOrderOwners_mem_pos {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepOrderOwners wo) : σ ∈ L := by
  rw [kvE2_sepOrderOwners] at hσ
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map
    Prod.fst
  rw [howners] at hperm
  exact hperm.mem_iff.mp hσ

/-- Every slot of the joint LEFT list belongs to some owner's slot block (owners drawn from
    any list carrying wo's owner projection — see `kvE2_sepOrderOwners_mem_pos`). -/
theorem kvE2_sepSlotsLOf_mem_block {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsLOf wo) :
    ∃ σ ∈ L, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsLOf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos howners hσ, by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsσ⟩

/-- Every slot of the joint RIGHT list belongs to some owner's slot block (mirror). -/
theorem kvE2_sepSlotsROf_mem_block {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {L : List (NormalForm sig 1 4)}
    {wo : KvE2SepWeakOrder sig} (howners : wo.map Prod.fst = L)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2_sepSlotsROf wo) :
    ∃ σ ∈ L, s ∈ kvE2_sepSlotBlock σ := by
  rw [kvE2_sepSlotsROf] at hs
  obtain ⟨σ, hσ, hsσ⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hs)
  exact ⟨σ, kvE2_sepOrderOwners_mem_pos howners hσ, by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsσ⟩

/-- **Value-sortedness of the joint LEFT list on the honest order**: the merged
    LEFT slot list is `Pairwise` value-nondecreasing. Consumes the banked halign trio: the list is
    merge-key sorted (`kvE2_sepSlotsLOf_mergeSorted`), and on the honest order a strictly smaller
    merge key forces a strictly smaller value — contrapositively, `value b < value a` would give
    `key b < key a` (`kvE2_sepSlotGIdx_honestOrder_mono`), contradicting `key a ≤ key b`. -/
theorem kvE2_sepSlotsLOf_honest_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsLOf (kvE2_sepHonestOrder qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  -- The honest order's owner projection is read off its `zipIdx` carrier
  -- directly — now the interior index `kvE2_sepPosI`.
  have hwo : (kvE2_sepHonestOrder qnf M w x t h).map Prod.fst
      = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder, List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsLOf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsLOf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsLOf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-- **Value-sortedness of the joint RIGHT list on the honest order** (mirror). -/
theorem kvE2_sepSlotsROf_honest_valueSorted {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (kvE2_sepSlotsROf (kvE2_sepHonestOrder qnf M w x t h)).Pairwise
      (fun a b => kvE2_sepSlotValue qnf M w x t h a ≤ kvE2_sepSlotValue qnf M w x t h b) := by
  -- Direct `zipIdx` owner projection onto `kvE2_sepPosI` (see LEFT mirror).
  have hwo : (kvE2_sepHonestOrder qnf M w x t h).map Prod.fst
      = kvE2_sepPosI qnf := by
    rw [kvE2_sepHonestOrder, List.map_map]
    exact List.zipIdx_map_fst 0 _
  refine (kvE2_sepSlotsROf_mergeSorted _).imp_of_mem ?_
  intro a b ha hb hab
  obtain ⟨σ, hσ, haσ⟩ := kvE2_sepSlotsROf_mem_block hwo ha
  obtain ⟨τ, hτ, hbτ⟩ := kvE2_sepSlotsROf_mem_block hwo hb
  rw [kvE2_sepSlotMergeLe, decide_eq_true_eq] at hab
  by_contra hlt
  rw [not_le] at hlt
  exact absurd hab (not_le.mpr (kvE2_sepSlotGIdx_honestOrder_mono qnf M w x t h
    (kvE2_sepPosI_subset hτ) (kvE2_sepPosI_subset hσ) hbτ haσ hlt))

/-! ### Region-assembly foundations (anchor boundary facts)

The region-assembly helper (`kvE2_sepHonest_engineInputs`) feeds `k1v_sorted_realizationK` regions
whose boundaries are the value-sorted interior anchors. The structural inputs `hpos`/`hlink`/`hbdry`
rest on two anchor facts, banked here as green sub-lemmas (H2 decomposition of the partition):
(i) each anchor (`.lX1`/`.rX1`) slot value lies strictly in its side's open interval — from the
honest bundles; (ii) distinct interior owners have distinct anchor values — the keystone
`kvE2_sepAnchor_injOn` lifted to the slot-value layer. These are model-order facts consumed as the
`hpos` strictness and `hbdry` endpoints; they do NOT re-derive the banked halign/value-sortedness
trio. -/

/-- **LEFT anchor slot in `(x, w)`** (Phase 1 `hbdry`/`hpos` ingredient): a LEFT-interior owner's
    `.lX1` slot value lies strictly between `x` and the shared `w`. Directly the honest bundle L's
    anchor bounds, re-typed through the definitional `kvE2_sepSlotValue_lX1`. -/
theorem kvE2_sepSlotValue_lX1_mem {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    x < kvE2_sepSlotValue qnf M w x t h (.lX1 σ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.lX1 σ) < w := by
  rw [kvE2_sepSlotValue_lX1]
  exact ⟨(kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).1,
    (kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone).2.1⟩

/-- **RIGHT anchor slot in `(w, t)`** (mirror of `kvE2_sepSlotValue_lX1_mem`): a RIGHT-interior
    owner's `.rX1` slot value lies strictly between the shared `w` and `t`. Honest bundle R. -/
theorem kvE2_sepSlotValue_rX1_mem {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    w < kvE2_sepSlotValue qnf M w x t h (.rX1 σ)
      ∧ kvE2_sepSlotValue qnf M w x t h (.rX1 σ) < t := by
  rw [kvE2_sepSlotValue_rX1]
  exact ⟨(kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).1,
    (kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone).2.1⟩

/-- **LEFT anchor value distinctness** (Phase 1 `hpos` strictness ingredient): distinct positive
    owners have distinct `.lX1` slot values. The keystone `kvE2_sepAnchor_injOn` at the slot-value
    layer (via the definitional `kvE2_sepSlotValue_lX1`). -/
theorem kvE2_sepSlotValue_lX1_injOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    (heq : kvE2_sepSlotValue qnf M w x t h (.lX1 σ)
      = kvE2_sepSlotValue qnf M w x t h (.lX1 τ)) : σ = τ := by
  rw [kvE2_sepSlotValue_lX1, kvE2_sepSlotValue_lX1] at heq
  exact kvE2_sepAnchor_injOn qnf M w x t h hσ hτ heq

/-- **RIGHT anchor value distinctness** (mirror): distinct positive owners have distinct `.rX1`
    slot values. -/
theorem kvE2_sepSlotValue_rX1_injOn {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    {σ τ : NormalForm sig 1 4} (hσ : σ ∈ kvE2_sepPos qnf) (hτ : τ ∈ kvE2_sepPos qnf)
    (heq : kvE2_sepSlotValue qnf M w x t h (.rX1 σ)
      = kvE2_sepSlotValue qnf M w x t h (.rX1 τ)) : σ = τ := by
  rw [kvE2_sepSlotValue_rX1, kvE2_sepSlotValue_rX1] at heq
  exact kvE2_sepAnchor_injOn qnf M w x t h hσ hτ heq

/-! ### Merged slot-list `Nodup` (region `hnd` foundation)

`k1v_sorted_realizationK`'s `hnd` obligation (each region's slot content duplicate-free) rests on
the
whole merged list being duplicate-free. Distinct individual slots stay distinct through the
point-level `mergeSort` (a permutation): the pre-sort per-owner LEFT/RIGHT blocks are each `Nodup`
(left/right parts of the banked `kvE2_sepSlotBlock_nodup`) and cross-owner disjoint (subsets of the
banked disjoint full blocks). Model-independent; collision-free (structural slot identity, not model
value). -/

/-- σ's canonical LEFT-region slot block is duplicate-free (left part of the `Nodup` full block). -/
theorem kvE2_sepSlotsLFor_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Nodup := by
  have h := kvE2_sepSlotBlock_nodup σ
  rw [kvE2_sepSlotBlock, List.nodup_append] at h
  exact h.1

/-- σ's canonical RIGHT-region slot block is duplicate-free (right part of the `Nodup` full
block). -/
theorem kvE2_sepSlotsRFor_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Nodup := by
  have h := kvE2_sepSlotBlock_nodup σ
  rw [kvE2_sepSlotBlock, List.nodup_append] at h
  exact h.2.1

/-- LEFT blocks of distinct owners are disjoint (subsets of the disjoint full blocks). -/
theorem kvE2_sepSlotsLFor_disjoint {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotsLFor σ).Disjoint (kvE2_sepSlotsLFor τ) := by
  intro a ha hb
  exact kvE2_sep_blocks_disjoint hne
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ ha)
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hb)

/-- RIGHT blocks of distinct owners are disjoint (subsets of the disjoint full blocks). -/
theorem kvE2_sepSlotsRFor_disjoint {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ τ : NormalForm sig 1 4}
    (hne : σ ≠ τ) : (kvE2_sepSlotsRFor σ).Disjoint (kvE2_sepSlotsRFor τ) := by
  intro a ha hb
  exact kvE2_sep_blocks_disjoint hne
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ ha)
    (by rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hb)

/-- The wo-ordered owner list is duplicate-free (a `mergeSort` permutation of the `Nodup`
    interior spine `kvE2_sepPosI`). -/
theorem kvE2_sepOrderOwners_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepOrderOwners wo).Nodup := by
  rw [kvE2_sepOrderOwners]
  have hperm : List.Perm
      ((wo.mergeSort (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst)
      (kvE2_sepPosI qnf) := by
    have hp := (List.mergeSort_perm wo
      (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst
    rwa [kvE2_sepOrderTypes_owners qnf hwo] at hp
  exact hperm.nodup_iff.mpr (kvE2_sepPosI_nodup qnf)

/-- **The joint LEFT slot list is duplicate-free**: distinct
    slots stay distinct through the point-level merge. `mergeSort` is a permutation, and the
    pre-sort
    flatMap over the (`Nodup`) positive owners of the per-owner LEFT blocks is `Nodup` by
    `kvE2_sepSlotsLFor_nodup` + cross-owner `kvE2_sepSlotsLFor_disjoint`. -/
theorem kvE2_sepSlotsLOf_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepSlotsLOf wo).Nodup := by
  rw [kvE2_sepSlotsLOf]
  refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
  rw [List.nodup_flatMap]
  exact ⟨fun σ _ => kvE2_sepSlotsLFor_nodup σ,
    (kvE2_sepOrderOwners_nodup qnf hwo).imp (fun hne => kvE2_sepSlotsLFor_disjoint hne)⟩

/-- **The joint RIGHT slot list is duplicate-free** (mirror of `kvE2_sepSlotsLOf_nodup`). -/
theorem kvE2_sepSlotsROf_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepOrderTypes qnf) :
    (kvE2_sepSlotsROf wo).Nodup := by
  rw [kvE2_sepSlotsROf]
  refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
  rw [List.nodup_flatMap]
  exact ⟨fun σ _ => kvE2_sepSlotsRFor_nodup σ,
    (kvE2_sepOrderOwners_nodup qnf hwo).imp (fun hne => kvE2_sepSlotsRFor_disjoint hne)⟩

/-! ### R2 — soundness side-conditions over arbitrary `wo ∈ kvE2_sepArr'`

The `kvE2_sepBody_extract` side-conditions (the `hpairL`/`hpairR`/`hnd`
shapes) quantify over EVERY valid weak order. The provable core lands here: conjunct (ii)
of `kvE2_sepDisjValid` (region-scoped payload consistency, `kvE2_sepConsistentBlock`)
reflects the merge-key sortedness of `kvE2_sepSlotsL/ROf wo` into SAME-OWNER rank order —
the `if`-true branch of `kvE2_sepSlotLe` — for arbitrary `wo ∈ kvE2_sepArr' qnf`, not just
the honest order. -/

/-- Consistency accessor (conjunct (ii) of `kvE2_sepDisjValid`): membership in the faithful
    carrier yields every owner's region-scoped payload consistency. Companion of
    `kvE2_sepArr'_sound`, which surfaces conjuncts (i)/(iii')/(iv) and discards (ii). -/
theorem kvE2_sepArr'_consistent {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf) :
    ∀ p ∈ wo, kvE2_sepConsistentBlock p.1 p.2.2 = true := by
  have hv : kvE2_sepDisjValid qnf wo = true := (List.mem_filter.mp hwo).2
  rw [kvE2_sepDisjValid, Bool.and_eq_true, Bool.and_eq_true, Bool.and_eq_true] at hv
  exact fun p hp => (List.all_eq_true.mp hv.1.1.2) p hp

/-- `find?` at an owner key resolves to that owner's entry on any weak order whose owner
    projection is duplicate-free (every `kvE2_sepOrderTypes` member, via
    `kvE2_sepOrderTypes_owners` + `kvE2_sepPosI_nodup`). -/
private theorem kvE2_sep_find?_owner_entry {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ} :
    ∀ {wo : KvE2SepWeakOrder sig}, (wo.map Prod.fst).Nodup → (σ, tag, t) ∈ wo →
      wo.find? (fun q => decide (q.1 = σ)) = some (σ, tag, t) := by
  intro wo
  induction wo with
  | nil => intro _ hp; simp at hp
  | cons a l ih =>
    intro hnd hp
    rw [List.map_cons, List.nodup_cons] at hnd
    rcases List.mem_cons.mp hp with heq | hpl
    · subst heq
      exact List.find?_cons_of_pos (by simp)
    · have hne : ¬(a.1 = σ) := fun he => hnd.1 (by
        rw [he]
        exact List.mem_map_of_mem hpl)
      rw [List.find?_cons_of_neg (by simpa using hne)]
      exact ih hnd.2 hpl

/-- Payload read of the merge key on an enumeration member: for `(σ, tag, t) ∈ wo` with
    duplicate-free owners, the global index of an own slot `s` is `t`'s entry at `s`'s
    block position (the arbitrary-`wo` generalization of the honest-order bridge
    `kvE2_sepSlotGIdx_honestOrder`). -/
private theorem kvE2_sepSlotGIdx_read {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {wo : KvE2SepWeakOrder sig} (hnd : (wo.map Prod.fst).Nodup)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {s : KvE2SepSlot sig} (hsub : kvE2_sepSlotSub s = σ) :
    kvE2_sepSlotGIdx wo s = t.getD (kvE2_sepBlockPos s) 0 := by
  unfold kvE2_sepSlotGIdx
  rw [hsub, kvE2_sep_find?_owner_entry hnd hp]
  simp only [Option.map_some, Option.getD_some]

/-- **Same-owner rank order from merge-key order** (the provable core of the R2 `hpair`
    side-conditions): on a valid weak order, two same-region slots of one owner whose merge
    keys are `≤`-ordered are rank-ordered — conjunct (ii) region-consistency reflected
    through the payload read. -/
private theorem kvE2_sep_rank_le_of_gidx_le {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock σ)
    (hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b)
    (hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b) :
    kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b := by
  by_contra hgt
  push Not at hgt
  have hnd : (wo.map Prod.fst).Nodup := by
    rw [kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1]
    exact kvE2_sepPosI_nodup qnf
  have hcons := kvE2_sepArr'_consistent qnf hwo (σ, tag, t) hp
  rw [kvE2_sepConsistentBlock, decide_eq_true_eq] at hcons
  have hsa : kvE2_sepSlotSub a = σ := kvE2_sepSlotSub_of_mem_block ha
  have hsb : kvE2_sepSlotSub b = σ := kvE2_sepSlotSub_of_mem_block hb
  have hal : (kvE2_sepSlotBlock σ).idxOf a < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem ha
  have hbl : (kvE2_sepSlotBlock σ).idxOf b < (kvE2_sepSlotBlock σ).length :=
    List.idxOf_lt_length_of_mem hb
  have hga : (kvE2_sepSlotBlock σ).get ⟨_, hal⟩ = a := List.idxOf_get hal
  have hgb : (kvE2_sepSlotBlock σ).get ⟨_, hbl⟩ = b := List.idxOf_get hbl
  have hlt : t.getD ((kvE2_sepSlotBlock σ).idxOf b) 0
      < t.getD ((kvE2_sepSlotBlock σ).idxOf a) 0 :=
    hcons ⟨_, hbl⟩ ⟨_, hal⟩ (by rw [hga, hgb]; exact hreg.symm)
      (by rw [hga, hgb]; exact hgt)
  have hra : kvE2_sepSlotGIdx wo a = t.getD ((kvE2_sepSlotBlock σ).idxOf a) 0 := by
    rw [kvE2_sepSlotGIdx_read hnd hp hsa, kvE2_sepBlockPos, hsa]
  have hrb : kvE2_sepSlotGIdx wo b = t.getD ((kvE2_sepSlotBlock σ).idxOf b) 0 := by
    rw [kvE2_sepSlotGIdx_read hnd hp hsb, kvE2_sepBlockPos, hsb]
  rw [hra, hrb] at hle
  omega

/-- **Strict same-owner key order from rank order** (Route A, (b)): the
    contrapositive of the landed `kvE2_sep_rank_le_of_gidx_le` (ℕ: `¬ ≤` is `<`). On a
    valid weak order, two same-region slots of one owner with strictly ordered region ranks
    carry strictly ordered global merge keys — the fact that separates a same-owner
    anchor/base pair into DISTINCT tie classes (conjunct (ii) via
    `kvE2_sepArr'_consistent`; no cross-owner relation enters). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (H,I,J).
theorem kvE2_sep_gidx_lt_of_rank_lt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈ kvE2_sepArr' qnf)
    {σ : NormalForm sig 1 4} {tag : KvE2SepSpikeOrderType} {t : List ℕ}
    (hp : (σ, tag, t) ∈ wo)
    {a b : KvE2SepSlot sig} (ha : a ∈ kvE2_sepSlotBlock σ) (hb : b ∈ kvE2_sepSlotBlock σ)
    (hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b)
    (hrk : kvE2_sepSlotRank a < kvE2_sepSlotRank b) :
    kvE2_sepSlotGIdx wo a < kvE2_sepSlotGIdx wo b := by
  by_contra hnlt
  push Not at hnlt
  have hle := kvE2_sep_rank_le_of_gidx_le qnf hwo hp hb ha hreg.symm hnlt
  omega

/-- **Same-owner `hpairL` core**: on every valid weak order the joint
    LEFT slot list is `kvE2_sepSlotLe`-pairwise on SAME-OWNER pairs — merge-key sortedness
    reflected through conjunct (ii). This is the half of the `hpairL` side-condition that
    IS a consequence of `kvE2_sepDisjValid` membership. -/
theorem kvE2_sepSlotsLOf_pairwise_sameOwner {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsLOf wo).Pairwise
        (fun a b => kvE2_sepSlotSub a = kvE2_sepSlotSub b → kvE2_sepSlotLe a b = true) := by
  intro wo hwo
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf :=
    kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1
  refine (kvE2_sepSlotsLOf_mergeSorted wo).imp_of_mem ?_
  intro a b hma hmb hab hsub
  rw [kvE2_sepSlotsLOf] at hma hmb
  obtain ⟨σ, hσo, hsa⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hma)
  obtain ⟨τ, hτo, hsb⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hmb)
  have hsuba : kvE2_sepSlotSub a = σ := kvE2_sepSlotsLFor_sub hsa
  have hsubb : kvE2_sepSlotSub b = τ := kvE2_sepSlotsLFor_sub hsb
  have hστ : σ = τ := hsuba.symm.trans (hsub.trans hsubb)
  subst hστ
  have hσp : σ ∈ wo.map Prod.fst := by
    rw [howners]; exact kvE2_sepOrderOwners_mem_pos howners hσo
  obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
  have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
  have hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b := by
    simpa [kvE2_sepSlotMergeLe] using hab
  have hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b := by
    rw [kvE2_sepSlotsLFor_regionLeft σ hsa, kvE2_sepSlotsLFor_regionLeft σ hsb]
  have hba : a ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsa
  have hbb : b ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_left _ hsb
  exact kvE2_sepSlotLe_same hsub
    (kvE2_sep_rank_le_of_gidx_le qnf hwo hpe hba hbb hreg hle)

/-- **Same-owner `hpairR` core** (RIGHT mirror of `kvE2_sepSlotsLOf_pairwise_sameOwner`). -/
theorem kvE2_sepSlotsROf_pairwise_sameOwner {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    ∀ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepSlotsROf wo).Pairwise
        (fun a b => kvE2_sepSlotSub a = kvE2_sepSlotSub b → kvE2_sepSlotLe a b = true) := by
  intro wo hwo
  have howners : wo.map Prod.fst = kvE2_sepPosI qnf :=
    kvE2_sepOrderTypes_owners qnf (List.mem_filter.mp hwo).1
  refine (kvE2_sepSlotsROf_mergeSorted wo).imp_of_mem ?_
  intro a b hma hmb hab hsub
  rw [kvE2_sepSlotsROf] at hma hmb
  obtain ⟨σ, hσo, hsa⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hma)
  obtain ⟨τ, hτo, hsb⟩ := List.mem_flatMap.mp ((List.mergeSort_perm _ _).mem_iff.mp hmb)
  have hsuba : kvE2_sepSlotSub a = σ := kvE2_sepSlotsRFor_sub hsa
  have hsubb : kvE2_sepSlotSub b = τ := kvE2_sepSlotsRFor_sub hsb
  have hστ : σ = τ := hsuba.symm.trans (hsub.trans hsubb)
  subst hστ
  have hσp : σ ∈ wo.map Prod.fst := by
    rw [howners]; exact kvE2_sepOrderOwners_mem_pos howners hσo
  obtain ⟨p, hpwo, hp1⟩ := List.mem_map.mp hσp
  have hpe : (σ, p.2.1, p.2.2) ∈ wo := by rw [← hp1]; exact hpwo
  have hle : kvE2_sepSlotGIdx wo a ≤ kvE2_sepSlotGIdx wo b := by
    simpa [kvE2_sepSlotMergeLe] using hab
  have hreg : kvE2_sepSlotRegionLeft a = kvE2_sepSlotRegionLeft b := by
    rw [kvE2_sepSlotsRFor_regionRight σ hsa, kvE2_sepSlotsRFor_regionRight σ hsb]
  have hba : a ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsa
  have hbb : b ∈ kvE2_sepSlotBlock σ := by
    rw [kvE2_sepSlotBlock]; exact List.mem_append_right _ hsb
  exact kvE2_sepSlotLe_same hsub
    (kvE2_sep_rank_le_of_gidx_le qnf hwo hpe hba hbb hreg hle)

/-! **R2 exact-shape discharge — NOT derivable from `kvE2_sepDisjValid` (blocker
record, machine-checked residues).** The full `kvE2_sepBody_extract` shapes
(`hpairL`/`hpairR`: `Pairwise (kvE2_sepSlotLe · · = true)`; `hnd`:
`(… .map (kvE2_sepSlotGIdx wo)).Nodup`) are FALSE over arbitrary
`wo ∈ kvE2_sepArr' qnf`:

* **Cross-owner half of `hpair`**: for a cross-owner sorted pair the relation is
  `kvE2_sepCompat a b`, which at a fresh-adjacent pair reads the fresh owner's OPEN
  `zXU`/`zUW` bit at the foreign 1-type (`kvE2_sepCompat_lX1_eq`). NO
  `kvE2_sepDisjValid` conjunct reads a cross-owner OPEN bit: (i) reads each owner's OWN
  tag bit at its OWN fresh type, (ii) is per-owner payload consistency, (iii') is
  anchor-payload distinctness, (iv) reads only CLOSED keys at payload ties. A valid `wo`
  placing a foreign `.lXU τ χ` payload below `.lX1 σ` with
  `kvE2_sepBits σ kvE_sub2_zXU χ = false` realizes the failure.
* **`hnd`**: base-base payload ties are DELIBERATELY admitted (conjunct (iii) removal —
  the Lemma 3.2(1) equality-case completeness repair; `kvE2_sepAnchorDistinct` docstring:
  "base slots may tie freely"). A tied payload duplicates the mapped `kvE2_sepSlotGIdx`
  value, so the `.map` is not `Nodup`.

This matches the carrier's own annotations: `kvE2_sepBody_extract` calls
`hnd` a restriction "to the TIE-FREE configuration" whose tie-admitting replacement "is
the Phases 8-10 arbitration item", and the note beside it says the `hpair`
facts "hold whenever the canonical union is a single region-sorted block". The same-owner
`Pairwise` core above is the part of R2 that IS a validity consequence; the cross-owner
and no-tie halves are properties of the SPECIFIC realized weak order, to be threaded as
per-`wo` hypotheses (or discharged by the grouped tie-admitting extraction), never as
`∀ wo ∈ kvE2_sepArr'` lemmas. -/

/-! ### Strict base realizers in the whole side interval (region `hreal`)

The engine `k1v_sorted_realizationK`'s `hreal` obligation asks, for every base 1-type `χ` placed in
a
region `(lo, hi)`, for a STRICT-interior realizer. The design-committed resolution (b) supplies the
strict realizer from the OWNER-RELATIVE honest bundle intervals (`kvE2_sepHonestAnchorBundleL/R`),
which are strict BY CONSTRUCTION — `χ` of a LEFT owner `σ` realizes strictly inside `(x, a_σ)` (its
`zXU` types) or `(a_σ, w)` (its `zUW` types), both `⊆ (x, w)`; mirror on the right in `(w, t)`. This
is the whole-side (`(x,w)` / `(w,t)`) strict realizer, monotonicity-closed through the bundle anchor
bounds. It does NOT rest on any base-value ≠ anchor-value non-collision claim (resolution (a), which
is false in general): the strictness is entirely owner-relative. -/

/-- **LEFT base realizer in `(x, w)`** (Phase 1 region `hreal` ingredient): every base 1-type of a
    LEFT-interior owner `σ` — whether in the below-anchor `zXU` set or the above-anchor `zUW` set —
    has a strict-interior realizer in the whole LEFT interval `(x, w)`. From honest bundle L: the
    `zXU` witness sits in `(x, a_σ) ⊆ (x, w)` (via `a_σ < w`), the `zUW` witness in `(a_σ, w) ⊆
    (x, w)` (via `x < a_σ`). Resolution (b) strictness — no non-collision assumption. -/
theorem kvE2_sepHonestBaseRealizerL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3)
    (χ : NormalForm sig 0 1)
    (hχ : χ ∈ kvE2_sepS σ kvE_sub2_zXU ++ kvE2_sepS σ kvE_sub2_zUW) :
    ∃ u : M.carrier, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
  have hb := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone
  rcases List.mem_append.mp hχ with hc | hc
  · obtain ⟨u, hxu, hua, hev⟩ := hb.2.2.1 χ hc
    exact ⟨u, hxu, lt_trans hua hb.2.1, hev⟩
  · obtain ⟨u, hau, huw, hev⟩ := hb.2.2.2 χ hc
    exact ⟨u, lt_trans hb.1 hau, huw, hev⟩

/-- **RIGHT base realizer in `(w, t)`** (mirror of `kvE2_sepHonestBaseRealizerL`): every base 1-type
    of a RIGHT-interior owner `σ` — below-anchor `zWX1` or above-anchor `zWT` — has a
    strict-interior
    realizer in the whole RIGHT interval `(w, t)`, from honest bundle R. Resolution (b)
    strictness. -/
theorem kvE2_sepHonestBaseRealizerR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3)
    (χ : NormalForm sig 0 1)
    (hχ : χ ∈ kvE2_sepS σ kvE2_sep_zWX1 ++ kvE2_sepS σ kvE_sub2_zWT) :
    ∃ u : M.carrier, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
  have hb := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone
  rcases List.mem_append.mp hχ with hc | hc
  · obtain ⟨u, hwu, hua, hev⟩ := hb.2.2.1 χ hc
    exact ⟨u, hwu, lt_trans hua hb.2.1, hev⟩
  · obtain ⟨u, hau, hut, hev⟩ := hb.2.2.2 χ hc
    exact ⟨u, lt_trans hb.1 hau, hut, hev⟩

/-! ### Per-owner per-zone base-type `Nodup` (region `hnd` packaging)

**Packaging decision (SECONDARY question resolved, grounded in code):** `k1v_sorted_realizationK`'s
`hnd` is on the TYPE list `List (NormalForm sig 0 1)` of each region. Two DISTINCT base slots of
DIFFERENT owners can carry the SAME base type `χ` in the same zone, so the FLAT joint left/right
type list is NOT `Nodup` (even though the SLOT list is — `kvE2_sepSlotsLOf_nodup`), and simply
`dedup`-ing the flat list is WRONG: the eventual bracket needs ONE strictly-ordered point PER SLOT,
so collapsing shared types would under-count the points. The correct packaging — mirroring the
single-owner sound path (`SubBracket2V.lean:1982`, `k1v_bracket_construct3` fed `hndXU`/`hndUW`/
`hndWT` per single owner) — is PER-OWNER, PER-ZONE regions: each region's type list is a SINGLE
owner's SINGLE-zone set `kvE2_sepS σ zs`, which is a `filter` of the `Nodup` `Finset.univ.toList`
and hence `Nodup`. This banks that `hnd` foundation. The remaining engine-inputs delta is the
CROSS-OWNER TILING of these per-owner regions (see the Phase-1 continuation note). The per-region
`hnd` foundation `(kvE2_sepS σ zs).Nodup` is ALREADY BANKED as `kvE2_sepS_nodup` (:372) — a `filter`
of the `Nodup` universe list — so it is CONSUMED, not re-derived. -/

/-! ### The joint engine inputs (cross-owner value→gap partition)

The remaining Phase-1 deliverable: boundary-linked region lists `kvE2_sepHonestRegionsL/R`
feeding `k1v_sorted_realizationK` (SubBracket2V.lean:633-646), with the five preconditions
`hpos`/`hlink`/`hnd`/`hreal`/`hbdry` bundled as `kvE2_sepHonest_engineInputs`.

**Design (cycle-8 resolution, consumed not re-derived):**
- **Boundaries** are the value-sorted LEFT anchors `a_1 < … < a_k` (the `kvE2_sepAnchorVal`s of
  the LEFT-interior owners), so `regionsL = [(x,a_1,S_0), (a_1,a_2,S_1), …, (a_k,w,S_k)]`;
  `interleaveK` will emit `a_1..a_k` as internal boundaries and `w` as the final un-emitted
  `hi`, matching the bracket layout `lL ++ ptW :: lR`. Mirror on the right in `(w,t)`.
  Strict sortedness is anchor injectivity (`kvE2_sepAnchor_injOn`) + `mergeSort`.
- **Cross-owner value→gap partition**: each base slot contributes a `(value, type)` pair
  (`kvE2_sepSlotValue`), and a gap `(lo,hi)` carries exactly the types having SOME pair with
  value strictly interior to the gap (`kvE2_sepGapTypes`) — placement by VALUE, not statically
  by owner (a `zUW` type of owner σ is realized in `(a_σ,w)`, spanning several gaps).
- **Collision folding carried structurally**: a base value CAN equal a foreign anchor
  (base values are `Classical.epsilon` choices; resolution (a) is false in general). The gap
  filter is STRICT, so a colliding pair is simply absent from both adjacent gaps — it never
  poisons `hreal` — and `kvE2_sepGapTypes_mem_of` records exactly when a type IS present.
  Realizing the folded types AT their anchor (the meet-type fold flagged in the 5D docstring)
  is Phase 3's point-type step, not a gap `hreal` obligation.
- **`hnd` without flat-dedup of slots**: each gap's TYPE list is a `filter` of the `dedup`ed
  type pool, hence `Nodup`; the per-SLOT multiplicity (one bracket point per slot,
  `kvE2_sepDisjunct_extract`) is untouched — slots and their values remain available to the
  Phase-2/3 alignment through the pair pools `kvE2_sepHonestBasePairsL/R`.
- **`hreal` is value-witnessed**: for a type in a gap the witnessing pair's own value is the
  strict-interior realizer — interiority from the gap filter itself, realization from the
  slot-value spec lemmas (`kvE2_sepSlotValue_*_spec`, owner-relative resolution (b) strictness;
  no non-collision assumption anywhere).
- **F4/LITMUS**: all bounds below are between extracted witness VALUES and the bracket range
  `x`/`w`/`t` — no `x1 < e_i` relative-position literal, no owner-to-owner chain. -/

/-- The types a gap `(lo, hi)` carries: those base 1-types having SOME `(value, type)` pair with
    value STRICTLY interior to the gap. A `filter` of the `dedup`ed type pool, hence `Nodup` —
    the engine's per-region `hnd` — while the pair pool itself keeps full per-slot multiplicity
    for the later alignment. Pairs whose value collides with a gap boundary (an anchor) are
    excluded by strictness: the fold structure. -/
noncomputable def kvE2_sepGapTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo hi : M.carrier) :
    List (NormalForm sig 0 1) :=
  (pairs.map Prod.snd).dedup.filter
    (fun χ => pairs.any (fun p => decide (p.2 = χ) && decide (lo < p.1) && decide (p.1 < hi)))

/-- Gap type lists are duplicate-free (engine `hnd`): a `filter` of a `dedup`. -/
theorem kvE2_sepGapTypes_nodup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo hi : M.carrier) :
    (kvE2_sepGapTypes pairs lo hi).Nodup :=
  List.Nodup.filter _ (List.nodup_dedup _)

/-- Membership extraction for a gap type: some pair carries it with strictly interior value
    (the engine `hreal` witness source). -/
theorem kvE2_sepGapTypes_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {pairs : List (M.carrier × NormalForm sig 0 1)} {lo hi : M.carrier}
    {χ : NormalForm sig 0 1} (hχ : χ ∈ kvE2_sepGapTypes pairs lo hi) :
    ∃ p ∈ pairs, p.2 = χ ∧ lo < p.1 ∧ p.1 < hi := by
  obtain ⟨-, hany⟩ := List.mem_filter.mp hχ
  obtain ⟨p, hp, hcond⟩ := List.any_eq_true.mp hany
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hcond
  exact ⟨p, hp, hcond.1.1, hcond.1.2, hcond.2⟩

/-- Membership introduction for a gap type (the fold-structure carrier: a pair with strictly
    interior value puts its type in the gap; a boundary-colliding pair does not qualify). -/
theorem kvE2_sepGapTypes_mem_of {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    {pairs : List (M.carrier × NormalForm sig 0 1)} {lo hi : M.carrier}
    {p : M.carrier × NormalForm sig 0 1} (hp : p ∈ pairs)
    (hlo : lo < p.1) (hhi : p.1 < hi) : p.2 ∈ kvE2_sepGapTypes pairs lo hi := by
  refine List.mem_filter.mpr ⟨List.mem_dedup.mpr (List.mem_map.mpr ⟨p, hp, rfl⟩), ?_⟩
  exact List.any_eq_true.mpr ⟨p, hp, by simp [hlo, hhi]⟩

/-- Gap region skeleton over interior boundaries: `lo -| mid_1 | mid_2 | … |- hi`, each gap
    carrying its `kvE2_sepGapTypes`. Recursive on the boundary list so `hlink`/`hpos`/`hbdry`
    fall to structural induction. -/
noncomputable def kvE2_sepGapRegions {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) :
    M.carrier → List M.carrier → M.carrier →
      List (M.carrier × M.carrier × List (NormalForm sig 0 1))
  | lo, [], hi => [(lo, hi, kvE2_sepGapTypes pairs lo hi)]
  | lo, a :: as, hi => (lo, a, kvE2_sepGapTypes pairs lo a) :: kvE2_sepGapRegions pairs a as hi

/-- The gap region list is never empty (there is always the `(lo, hi)` gap). -/
theorem kvE2_sepGapRegions_ne_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo : M.carrier) (mid : List M.carrier)
    (hi : M.carrier) : kvE2_sepGapRegions pairs lo mid hi ≠ [] := by
  cases mid <;> simp [kvE2_sepGapRegions]

/-- The first gap region starts at `lo` (left half of the engine's `hbdry`). -/
theorem kvE2_sepGapRegions_head?_fst {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (lo : M.carrier) (mid : List M.carrier)
    (hi : M.carrier) : ∀ y ∈ (kvE2_sepGapRegions pairs lo mid hi).head?, y.1 = lo := by
  cases mid with
  | nil =>
    intro y hy
    simp only [kvE2_sepGapRegions, List.head?_cons, Option.mem_def, Option.some.injEq] at hy
    subst hy; rfl
  | cons a as =>
    intro y hy
    simp only [kvE2_sepGapRegions, List.head?_cons, Option.mem_def, Option.some.injEq] at hy
    subst hy; rfl

/-- The last gap region ends at `hi` (right half of the engine's `hbdry`). -/
theorem kvE2_sepGapRegions_getLast?_snd {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} (pairs : List (M.carrier × NormalForm sig 0 1))
    (mid : List M.carrier) : ∀ (lo hi : M.carrier),
      ∀ y ∈ (kvE2_sepGapRegions pairs lo mid hi).getLast?, y.2.1 = hi := by
  induction mid with
  | nil =>
    intro lo hi y hy
    simp only [kvE2_sepGapRegions, List.getLast?_singleton, Option.mem_def,
      Option.some.injEq] at hy
    subst hy; rfl
  | cons a as ih =>
    intro lo hi y hy
    simp only [kvE2_sepGapRegions] at hy
    cases hrec : kvE2_sepGapRegions pairs a as hi with
    | nil => exact absurd hrec (kvE2_sepGapRegions_ne_nil pairs a as hi)
    | cons b bs =>
      rw [hrec, List.getLast?_cons_cons] at hy
      exact ih a hi y (by rw [hrec]; exact hy)

/-- Consecutive gap regions share their boundary anchor (the engine's `hlink`). -/
theorem kvE2_sepGapRegions_chain' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier),
      List.IsChain (fun a b => a.2.1 = b.1) (kvE2_sepGapRegions pairs lo mid hi) := by
  induction mid with
  | nil =>
    intro lo hi
    simp only [kvE2_sepGapRegions]
    exact List.isChain_singleton _
  | cons a as ih =>
    intro lo hi
    simp only [kvE2_sepGapRegions]
    refine List.isChain_cons.mpr ⟨?_, ih a hi⟩
    intro y hy
    exact (kvE2_sepGapRegions_head?_fst pairs a as hi y hy).symm

/-- Under a strict boundary chain `lo < mid_1 < … < hi`, every gap is nonempty
    (the engine's `hpos`). -/
theorem kvE2_sepGapRegions_pos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.IsChain (· < ·) (lo :: (mid ++ [hi])) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, r.1 < r.2.1 := by
  induction mid with
  | nil =>
    intro lo hi hch r hr
    simp only [List.nil_append] at hch
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr
    exact (List.isChain_cons_cons.mp hch).1
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.isChain_cons_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · exact h1.1
    · exact ih a hi h1.2 r hr

/-- Every gap region's type list is the `kvE2_sepGapTypes` of its own endpoints
    (feeds `hnd`/`hreal` instantiation). -/
theorem kvE2_sepGapRegions_types {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi,
      r.2.2 = kvE2_sepGapTypes pairs r.1 r.2.1 := by
  induction mid with
  | nil =>
    intro lo hi r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; rfl
  | cons a as ih =>
    intro lo hi r hr
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · rfl
    · exact ih a hi r hr

/-- Strictly-between boundary points chain strictly from `lo` to `hi`. -/
private theorem kvE2_sepChain_lt_between {α : Type*} [Preorder α] (mid : List α) :
    ∀ lo hi : α, mid.Pairwise (· < ·) → (∀ a ∈ mid, lo < a ∧ a < hi) → lo < hi →
      List.IsChain (· < ·) (lo :: (mid ++ [hi])) := by
  induction mid with
  | nil =>
    intro lo hi _ _ hlh
    exact List.IsChain.cons_cons hlh (List.IsChain.singleton _)
  | cons a as ih =>
    intro lo hi hpw hmem hlh
    have hc := List.pairwise_cons.mp hpw
    simp only [List.cons_append]
    refine List.IsChain.cons_cons (hmem a List.mem_cons_self).1 ?_
    exact ih a hi hc.2 (fun b hb => ⟨hc.1 b hb, (hmem b (List.mem_cons_of_mem _ hb)).2⟩)
      (hmem a List.mem_cons_self).2

/-- LEFT `(value, type)` pair pool: every base slot of the joint LEFT side — a LEFT-interior
    owner's below-anchor (`lXU`) and above-anchor (`lUW`) types AND a RIGHT-interior owner's
    left-region (`rXW`) types — paired with its engine-bound `kvE2_sepSlotValue`. Placement into
    gaps is by VALUE (cross-owner), never statically by owner. -/
noncomputable def kvE2_sepHonestBasePairsL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × NormalForm sig 0 1) :=
  (kvE2_sepPosIn qnf kvE2_sep_zXW3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zXU).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lXU σ χ), χ))
        ++ (kvE2_sepS σ kvE_sub2_zUW).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lUW σ χ), χ)))
    ++ (kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zXU).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rXW σ χ), χ)))

/-- RIGHT `(value, type)` pair pool (mirror): a RIGHT-interior owner's below-anchor (`rWX1`)
    and above-anchor (`rX1T`) types AND a LEFT-interior owner's right-region (`lWT`) types. -/
noncomputable def kvE2_sepHonestBasePairsR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × NormalForm sig 0 1) :=
  (kvE2_sepPosIn qnf kvE2_sep_zXW3).flatMap (fun σ =>
      (kvE2_sepS σ kvE_sub2_zWT).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.lWT σ χ), χ)))
    ++ (kvE2_sepPosIn qnf kvE2_sep_zWT3).flatMap (fun σ =>
      (kvE2_sepS σ kvE2_sep_zWX1).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rWX1 σ χ), χ))
        ++ (kvE2_sepS σ kvE_sub2_zWT).map
        (fun χ => (kvE2_sepSlotValue qnf M w x t h (.rX1T σ χ), χ)))

/-- Every LEFT pair's value realizes its type (the `hreal` evaluation core; interiority is the
    gap filter's own strictness). From the six per-slot value specs — owner-relative
    resolution (b), no non-collision assumption. -/
theorem kvE2_sepHonestBasePairsL_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ p ∈ kvE2_sepHonestBasePairsL qnf M w x t h,
      nf_eval_nf M 0 1 (fun _ => p.1) p.2 := by
  intro p hp
  rw [kvE2_sepHonestBasePairsL] at hp
  rcases List.mem_append.mp hp with hp | hp
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
      of_decide_eq_true (List.mem_filter.mp hσ).2
    rcases List.mem_append.mp hpσ with hpm | hpm
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_lXU_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_lUW_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpσ
    exact (kvE2_sepSlotValue_rXW_spec qnf M w x t h σ hσpos χ hχ).2.2

/-- Every RIGHT pair's value realizes its type (mirror of `kvE2_sepHonestBasePairsL_eval`). -/
theorem kvE2_sepHonestBasePairsR_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ p ∈ kvE2_sepHonestBasePairsR qnf M w x t h,
      nf_eval_nf M 0 1 (fun _ => p.1) p.2 := by
  intro p hp
  rw [kvE2_sepHonestBasePairsR] at hp
  rcases List.mem_append.mp hp with hp | hp
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpσ
    exact (kvE2_sepSlotValue_lWT_spec qnf M w x t h σ hσpos χ hχ).2.2
  · obtain ⟨σ, hσ, hpσ⟩ := List.mem_flatMap.mp hp
    have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
    have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
      of_decide_eq_true (List.mem_filter.mp hσ).2
    rcases List.mem_append.mp hpσ with hpm | hpm
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_rWX1_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2
    · obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hpm
      exact (kvE2_sepSlotValue_rX1T_spec qnf M w x t hxw hwt h σ hσpos hzone χ hχ).2.2

/-- Value-sorted LEFT anchor boundary list: the LEFT-interior owners' canonical anchors in
    `≤`-`mergeSort` order (strictified below by anchor injectivity). -/
noncomputable def kvE2_sepHonestAnchorsL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : List M.carrier :=
  ((kvE2_sepPosIn qnf kvE2_sep_zXW3).map
    (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort (fun a b => decide (a ≤ b))

/-- Value-sorted RIGHT anchor boundary list (mirror). -/
noncomputable def kvE2_sepHonestAnchorsR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) : List M.carrier :=
  ((kvE2_sepPosIn qnf kvE2_sep_zWT3).map
    (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort (fun a b => decide (a ≤ b))

/-- Every LEFT boundary anchor is strictly inside `(x, w)` (honest bundle L bounds). -/
theorem kvE2_sepHonestAnchorsL_bounds {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ a ∈ kvE2_sepHonestAnchorsL qnf M w x t h, x < a ∧ a < w := by
  intro a ha
  rw [kvE2_sepHonestAnchorsL] at ha
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp ((List.mergeSort_perm _ _).mem_iff.mp ha)
  have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
  have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3 :=
    of_decide_eq_true (List.mem_filter.mp hσ).2
  have hb := kvE2_sepHonestAnchorBundleL qnf M w x t hxw hwt h σ hσpos hzone
  exact ⟨hb.1, hb.2.1⟩

/-- Every RIGHT boundary anchor is strictly inside `(w, t)` (honest bundle R bounds). -/
theorem kvE2_sepHonestAnchorsR_bounds {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∀ a ∈ kvE2_sepHonestAnchorsR qnf M w x t h, w < a ∧ a < t := by
  intro a ha
  rw [kvE2_sepHonestAnchorsR] at ha
  obtain ⟨σ, hσ, rfl⟩ := List.mem_map.mp ((List.mergeSort_perm _ _).mem_iff.mp ha)
  have hσpos : σ ∈ kvE2_sepPos qnf := (List.mem_filter.mp hσ).1
  have hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3 :=
    of_decide_eq_true (List.mem_filter.mp hσ).2
  have hb := kvE2_sepHonestAnchorBundleR qnf M w x t hxw hwt h σ hσpos hzone
  exact ⟨hb.1, hb.2.1⟩

/-- The sorted anchor list is `≤`-sorted and duplicate-free, hence STRICTLY sorted: the
    `hpos`/`hlink` strictness seed. Nodup is the keystone `kvE2_sepAnchor_injOn` on the
    `Nodup` positive spine. Stated generically over the zone filter to serve both sides. -/
private theorem kvE2_sepHonestAnchors_pairwise_aux {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) (zs : ZoneSpec 3) :
    (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Pairwise (· < ·) := by
  have hle : (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Pairwise (fun a b => decide (a ≤ b) = true) :=
    List.pairwise_mergeSort
      (fun a b c hab hbc => by
        simp only [decide_eq_true_eq] at hab hbc ⊢
        exact le_trans hab hbc)
      (fun a b => by
        simp only [Bool.or_eq_true, decide_eq_true_eq]
        exact le_total a b) _
  have hnd : (((kvE2_sepPosIn qnf zs).map
      (fun σ => kvE2_sepAnchorVal qnf M w x t h σ)).mergeSort
        (fun a b => decide (a ≤ b))).Nodup := by
    refine (List.mergeSort_perm _ _).nodup_iff.mpr ?_
    refine List.Nodup.map_on ?_ (List.Nodup.filter _ (kvE2_sepPos_nodup qnf))
    intro σ hσ τ hτ heq
    exact kvE2_sepAnchor_injOn qnf M w x t h
      (List.mem_filter.mp hσ).1 (List.mem_filter.mp hτ).1 heq
  have hle' := hle.imp (fun hab => of_decide_eq_true hab)
  exact (hle'.and hnd).imp (fun hc => lt_of_le_of_ne hc.1 hc.2)

/-- The LEFT boundary chain is strict: `x < a_1 < … < a_k < w`. -/
theorem kvE2_sepHonestAnchorsL_chain {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List.IsChain (· < ·) (x :: (kvE2_sepHonestAnchorsL qnf M w x t h ++ [w])) :=
  kvE2_sepChain_lt_between _ x w
    (kvE2_sepHonestAnchors_pairwise_aux qnf M w x t h kvE2_sep_zXW3)
    (kvE2_sepHonestAnchorsL_bounds qnf M w x t hxw hwt h) hxw

/-- The RIGHT boundary chain is strict: `w < a_1 < … < a_k < t`. -/
theorem kvE2_sepHonestAnchorsR_chain {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List.IsChain (· < ·) (w :: (kvE2_sepHonestAnchorsR qnf M w x t h ++ [t])) :=
  kvE2_sepChain_lt_between _ w t
    (kvE2_sepHonestAnchors_pairwise_aux qnf M w x t h kvE2_sep_zWT3)
    (kvE2_sepHonestAnchorsR_bounds qnf M w x t hxw hwt h) hwt

/-- **The joint LEFT engine region list**: gaps between `x`, the value-sorted LEFT anchors, and
    `w`, each carrying the base types whose slot value is strictly interior to it. -/
noncomputable def kvE2_sepHonestRegionsL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × M.carrier × List (NormalForm sig 0 1)) :=
  kvE2_sepGapRegions (kvE2_sepHonestBasePairsL qnf M w x t h) x
    (kvE2_sepHonestAnchorsL qnf M w x t h) w

/-- **The joint RIGHT engine region list** (mirror in `(w, t)`). -/
noncomputable def kvE2_sepHonestRegionsR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    List (M.carrier × M.carrier × List (NormalForm sig 0 1)) :=
  kvE2_sepGapRegions (kvE2_sepHonestBasePairsR qnf M w x t h) w
    (kvE2_sepHonestAnchorsR qnf M w x t h) t

/-- **The Phase-1 engine-input bundle**: the joint LEFT/RIGHT gap region lists
    satisfy ALL five `k1v_sorted_realizationK` preconditions —
    `hpos` (strict anchor chain), `hlink` (shared boundaries), `hnd` (filter-of-dedup type
    lists), `hreal` (each gap type's own slot value is a strict-interior realizer) — plus the
    endpoint boundary alignment `hbdry` (`regionsL` runs `x … w`, `regionsR` runs `w … t`, so
    the merged chain is `x < … < w < … < t` with `w` the single shared pivot).

    Folded (anchor-colliding) base values are structurally absent from every gap list — their
    realization AT the anchors is Phase 3's meet-type point step. Alignment of the gap content
    with `kvE2_sepSlotsLOf/ROf` (halign) is Phase 2/3, consuming the banked
    `kvE2_sepSlotGIdx_honestOrder` trio — not part of this bundle. -/
theorem kvE2_sepHonest_engineInputs {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.1 < r.2.1) ∧
    List.IsChain (fun a b => a.2.1 = b.1) (kvE2_sepHonestRegionsL qnf M w x t h) ∧
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.2.Nodup) ∧
    (∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.1 < r.2.1) ∧
    List.IsChain (fun a b => a.2.1 = b.1) (kvE2_sepHonestRegionsR qnf M w x t h) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.2.Nodup) ∧
    (∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
    kvE2_sepHonestRegionsL qnf M w x t h ≠ [] ∧
    kvE2_sepHonestRegionsR qnf M w x t h ≠ [] ∧
    (∀ y ∈ (kvE2_sepHonestRegionsL qnf M w x t h).head?, y.1 = x) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsL qnf M w x t h).getLast?, y.2.1 = w) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsR qnf M w x t h).head?, y.1 = w) ∧
    (∀ y ∈ (kvE2_sepHonestRegionsR qnf M w x t h).getLast?, y.2.1 = t) := by
  have hrealL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro r hr χ hχ
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr] at hχ
    obtain ⟨p, hp, rfl, hlo, hhi⟩ := kvE2_sepGapTypes_mem hχ
    exact ⟨p.1, hlo, hhi, kvE2_sepHonestBasePairsL_eval qnf M w x t hxw hwt h p hp⟩
  have hrealR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, ∀ χ ∈ r.2.2,
      ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro r hr χ hχ
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr] at hχ
    obtain ⟨p, hp, rfl, hlo, hhi⟩ := kvE2_sepGapTypes_mem hχ
    exact ⟨p.1, hlo, hhi, kvE2_sepHonestBasePairsR_eval qnf M w x t hxw hwt h p hp⟩
  have hndL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.2.Nodup := by
    intro r hr
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr]
    exact kvE2_sepGapTypes_nodup _ _ _
  have hndR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.2.Nodup := by
    intro r hr
    rw [kvE2_sepGapRegions_types _ _ _ _ r hr]
    exact kvE2_sepGapTypes_nodup _ _ _
  exact ⟨kvE2_sepGapRegions_pos _ _ x w
      (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h),
    kvE2_sepGapRegions_chain' _ _ x w, hndL, hrealL,
    kvE2_sepGapRegions_pos _ _ w t
      (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h),
    kvE2_sepGapRegions_chain' _ _ w t, hndR, hrealR,
    kvE2_sepGapRegions_ne_nil _ _ _ _, kvE2_sepGapRegions_ne_nil _ _ _ _,
    kvE2_sepGapRegions_head?_fst _ _ _ _, kvE2_sepGapRegions_getLast?_snd _ _ _ _,
    kvE2_sepGapRegions_head?_fst _ _ _ _, kvE2_sepGapRegions_getLast?_snd _ _ _ _⟩

/-! ### Global monotone bracket witness (engine invocation + stitch)

`kvE2_sepHonest_witnesses` invokes `k1v_sorted_realizationK` (SubBracket2V.lean:633) once per
side on the Phase-1 region lists and stitches the two `interleaveK` chains around the single
shared pivot `w` into the globally strictly monotone bracket witness chain, with per-side
range bounds `x < · < w` (LEFT) and `w < · < t` (RIGHT). The full engine `Forall₂` data is
exposed so Phase 3 can thread the per-region realizers into the per-slot point-type step.
All bounds are between engine points and the bracket range `x`/`w`/`t` — no `x1 < e_i`
relative-position literal, no owner-to-owner chain (F4/LITMUS NavigatedSpine:437). Per-slot
re-indexing into `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` (the halign step over
the banked `kvE2_sepSlotGIdx_honestOrder` trio + value-sortedness, including the duplicate
per-gap type and folded-anchor cases) is Phase 3's alignment work, consuming this chain. -/

/-- Under a strict boundary chain every gap region's `lo` is at least the global `lo`
    (feeds the stitcher's `hlo` for the engine's point lists). -/
theorem kvE2_sepGapRegions_lo_le {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.IsChain (· < ·) (lo :: (mid ++ [hi])) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, lo ≤ r.1 := by
  induction mid with
  | nil =>
    intro lo hi _ r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; exact le_refl _
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.isChain_cons_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · exact le_refl _
    · exact le_of_lt (lt_of_lt_of_le h1.1 (ih a hi h1.2 r hr))

/-- Under a strict boundary chain every gap region's `hi` is at most the global `hi`
    (feeds the interleave upper bound for the engine's point lists). -/
theorem kvE2_sepGapRegions_hi_le {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {M : OrderedMonadicStructure sig}
    (pairs : List (M.carrier × NormalForm sig 0 1)) (mid : List M.carrier) :
    ∀ (lo hi : M.carrier), List.IsChain (· < ·) (lo :: (mid ++ [hi])) →
      ∀ r ∈ kvE2_sepGapRegions pairs lo mid hi, r.2.1 ≤ hi := by
  induction mid with
  | nil =>
    intro lo hi _ r hr
    simp only [kvE2_sepGapRegions, List.mem_singleton] at hr
    subst hr; exact le_refl _
  | cons a as ih =>
    intro lo hi hch r hr
    simp only [List.cons_append] at hch
    have h1 := List.isChain_cons_cons.mp hch
    simp only [kvE2_sepGapRegions, List.mem_cons] at hr
    rcases hr with rfl | hr
    · have hpw := List.isChain_iff_pairwise.mp h1.2
      exact le_of_lt (List.rel_of_pairwise_cons hpw
        (List.mem_append_right _ (List.mem_singleton_self hi)))
    · exact ih a hi h1.2 r hr

/-- **Interleave upper bound** (dual of the stitcher's global lower bound
    `k1v_stitch_regions` `.2`): if every block point sits strictly below its region's `hi`,
    the regions are non-degenerate and boundary-linked, and every region `hi` is at most a
    global `hi`, then the whole interleaved chain sits strictly below the global `hi`. -/
theorem kvE2_sepInterleaveK_lt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {β : Type _} :
    ∀ (regs : List (M.carrier × M.carrier × List (β × M.carrier))) (hi : M.carrier),
      (∀ e ∈ regs, ∀ q ∈ e.2.2, q.2 < e.2.1) →
      (∀ e ∈ regs, e.1 < e.2.1) →
      List.IsChain (fun a b => a.2.1 = b.1) regs →
      (∀ e ∈ regs, e.2.1 ≤ hi) →
      ∀ y ∈ interleaveK regs, y < hi := by
  intro regs
  induction regs with
  | nil => intro hi _ _ _ _ y hy; simp [interleaveK] at hy
  | cons e rest ih =>
    intro hi hblk hpos hlink hhi y hy
    obtain ⟨el, esep, eblk⟩ := e
    cases rest with
    | nil =>
      simp only [interleaveK, List.mem_map] at hy
      obtain ⟨q, hq, rfl⟩ := hy
      exact lt_of_lt_of_le (hblk _ List.mem_cons_self q hq) (hhi _ List.mem_cons_self)
    | cons e' rest' =>
      simp only [interleaveK, List.mem_append, List.mem_cons] at hy
      rcases hy with hy | hy | hy
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hy
        exact lt_of_lt_of_le (hblk _ List.mem_cons_self q hq) (hhi _ List.mem_cons_self)
      · have hsep : esep = e'.1 := (List.isChain_cons_cons.mp hlink).1
        rw [hy, hsep]
        exact lt_of_lt_of_le (hpos e' (List.mem_cons_of_mem _ List.mem_cons_self))
          (hhi e' (List.mem_cons_of_mem _ List.mem_cons_self))
      · exact ih hi (fun g hg => hblk g (List.mem_cons_of_mem _ hg))
          (fun g hg => hpos g (List.mem_cons_of_mem _ hg))
          (List.isChain_cons_cons.mp hlink).2
          (fun g hg => hhi g (List.mem_cons_of_mem _ hg)) y hy

/-- `Forall₂` left-membership extraction (local helper): each left element is related to
    some member of the right list. -/
private theorem kvE2_sepForall₂_mem_left {α β : Type _} {R : α → β → Prop} :
    ∀ {l₁ : List α} {l₂ : List β}, List.Forall₂ R l₁ l₂ →
      ∀ a ∈ l₁, ∃ b ∈ l₂, R a b := by
  intro l₁ l₂ hf
  induction hf with
  | nil => intro a ha; simp at ha
  | cons hab _ ih =>
    intro a ha
    rcases List.mem_cons.mp ha with rfl | ha'
    · exact ⟨_, List.mem_cons_self, hab⟩
    · obtain ⟨b, hb, hR⟩ := ih a ha'
      exact ⟨b, List.mem_cons_of_mem _ hb, hR⟩

/-- `Forall₂` boundary-skeleton transfer (local helper): when related entries share both
    boundaries, the boundary-link `Chain'` transfers from the region list to the engine's
    point list. -/
private theorem kvE2_sepForall₂_chain' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {β γ : Type _}
    {R : (M.carrier × M.carrier × β) → (M.carrier × M.carrier × γ) → Prop}
    (hR : ∀ p r, R p r → p.1 = r.1 ∧ p.2.1 = r.2.1) :
    ∀ {ps : List (M.carrier × M.carrier × β)} {rs : List (M.carrier × M.carrier × γ)},
      List.Forall₂ R ps rs →
      List.IsChain (fun a b => a.2.1 = b.1) rs →
      List.IsChain (fun a b => a.2.1 = b.1) ps := by
  intro ps rs hf
  induction hf with
  | nil => intro _; exact List.isChain_nil
  | @cons p r ps' rs' hpr hf' ih =>
    intro hch
    cases hf' with
    | nil => exact List.isChain_singleton _
    | @cons p' r' ps'' rs'' hpr' hf'' =>
      have hch' := List.isChain_cons_cons.mp hch
      refine List.isChain_cons_cons.mpr ⟨?_, ih hch'.2⟩
      rw [(hR p r hpr).2, hch'.1, ← (hR p' r' hpr').1]

/-- **Phase 2 — the global monotone bracket witness**: invoking the engine
    `k1v_sorted_realizationK` on the Phase-1 LEFT/RIGHT region lists yields per-side
    point-tagged region lists `psL`/`psR` — full engine `Forall₂` guarantees exposed for
    the Phase-3 point-type step — whose stitched chains sit strictly inside `(x, w)` resp.
    `(w, t)` and concatenate around the single shared pivot `w` into the globally strictly
    monotone bracket witness chain `interleaveK psL ++ w :: interleaveK psR`, every point
    strictly inside the bracket range `(x, t)`. Consumes the Phase-1 bundle
    `kvE2_sepHonest_engineInputs`; all bounds ride the bracket range `x`/`w`/`t`
    (F4/LITMUS: no `x1 < e_i` literal, no owner-to-owner chain). -/
theorem kvE2_sepHonest_witnesses {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    ∃ (psL psR : List (M.carrier × M.carrier × List (NormalForm sig 0 1 × M.carrier))),
      List.Forall₂ (fun p r => p.1 = r.1 ∧ p.2.1 = r.2.1 ∧
          List.Perm (p.2.2.map Prod.fst) r.2.2 ∧
          (p.2.2.map Prod.snd).Pairwise (· < ·) ∧
          (∀ q ∈ p.2.2, (r.1 < q.2 ∧ q.2 < r.2.1) ∧ nf_eval_nf M 0 1 (fun _ => q.2) q.1))
        psL (kvE2_sepHonestRegionsL qnf M w x t h) ∧
      List.Forall₂ (fun p r => p.1 = r.1 ∧ p.2.1 = r.2.1 ∧
          List.Perm (p.2.2.map Prod.fst) r.2.2 ∧
          (p.2.2.map Prod.snd).Pairwise (· < ·) ∧
          (∀ q ∈ p.2.2, (r.1 < q.2 ∧ q.2 < r.2.1) ∧ nf_eval_nf M 0 1 (fun _ => q.2) q.1))
        psR (kvE2_sepHonestRegionsR qnf M w x t h) ∧
      (∀ y ∈ interleaveK psL, x < y ∧ y < w) ∧
      (∀ y ∈ interleaveK psR, w < y ∧ y < t) ∧
      (interleaveK psL ++ w :: interleaveK psR).Pairwise (· < ·) := by
  obtain ⟨hposL, hlinkL, hndL, hrealL, hposR, hlinkR, hndR, hrealR,
    hneL, hneR, hheadL, hlastL, hheadR, hlastR⟩ :=
    kvE2_sepHonest_engineInputs qnf M w x t hxw hwt h
  obtain ⟨psL, hfL, hsortL⟩ := k1v_sorted_realizationK M _ hposL hlinkL hndL hrealL
  obtain ⟨psR, hfR, hsortR⟩ := k1v_sorted_realizationK M _ hposR hlinkR hndR hrealR
  -- Region-level global bounds from the strict anchor boundary chains.
  have hloL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, x ≤ r.1 :=
    kvE2_sepGapRegions_lo_le _ _ x w (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h)
  have hhiL : ∀ r ∈ kvE2_sepHonestRegionsL qnf M w x t h, r.2.1 ≤ w :=
    kvE2_sepGapRegions_hi_le _ _ x w (kvE2_sepHonestAnchorsL_chain qnf M w x t hxw hwt h)
  have hloR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, w ≤ r.1 :=
    kvE2_sepGapRegions_lo_le _ _ w t (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h)
  have hhiR : ∀ r ∈ kvE2_sepHonestRegionsR qnf M w x t h, r.2.1 ≤ t :=
    kvE2_sepGapRegions_hi_le _ _ w t (kvE2_sepHonestAnchorsR_chain qnf M w x t hxw hwt h)
  -- Transfer the region skeleton facts through the engine's `Forall₂` onto `psL`/`psR`.
  have hmemL := kvE2_sepForall₂_mem_left hfL
  have hmemR := kvE2_sepForall₂_mem_left hfR
  have hposPsL : ∀ p ∈ psL, p.1 < p.2.1 := by
    intro p hp; obtain ⟨r, hr, h1, h2, -, -, -⟩ := hmemL p hp
    rw [h1, h2]; exact hposL r hr
  have hposPsR : ∀ p ∈ psR, p.1 < p.2.1 := by
    intro p hp; obtain ⟨r, hr, h1, h2, -, -, -⟩ := hmemR p hp
    rw [h1, h2]; exact hposR r hr
  have hloPsL : ∀ p ∈ psL, x ≤ p.1 := by
    intro p hp; obtain ⟨r, hr, h1, -, -, -, -⟩ := hmemL p hp
    rw [h1]; exact hloL r hr
  have hloPsR : ∀ p ∈ psR, w ≤ p.1 := by
    intro p hp; obtain ⟨r, hr, h1, -, -, -, -⟩ := hmemR p hp
    rw [h1]; exact hloR r hr
  have hhiPsL : ∀ p ∈ psL, p.2.1 ≤ w := by
    intro p hp; obtain ⟨r, hr, -, h2, -, -, -⟩ := hmemL p hp
    rw [h2]; exact hhiL r hr
  have hhiPsR : ∀ p ∈ psR, p.2.1 ≤ t := by
    intro p hp; obtain ⟨r, hr, -, h2, -, -, -⟩ := hmemR p hp
    rw [h2]; exact hhiR r hr
  have hsortPsL : ∀ p ∈ psL, (p.2.2.map Prod.snd).Pairwise (· < ·) := by
    intro p hp; obtain ⟨r, hr, -, -, -, h4, -⟩ := hmemL p hp; exact h4
  have hsortPsR : ∀ p ∈ psR, (p.2.2.map Prod.snd).Pairwise (· < ·) := by
    intro p hp; obtain ⟨r, hr, -, -, -, h4, -⟩ := hmemR p hp; exact h4
  have hrangePsL : ∀ p ∈ psL, ∀ q ∈ p.2.2, p.1 < q.2 ∧ q.2 < p.2.1 := by
    intro p hp q hq; obtain ⟨r, hr, h1, h2, -, -, h5⟩ := hmemL p hp
    rw [h1, h2]; exact (h5 q hq).1
  have hrangePsR : ∀ p ∈ psR, ∀ q ∈ p.2.2, p.1 < q.2 ∧ q.2 < p.2.1 := by
    intro p hp q hq; obtain ⟨r, hr, h1, h2, -, -, h5⟩ := hmemR p hp
    rw [h1, h2]; exact (h5 q hq).1
  have hlinkPsL : List.IsChain (fun a b => a.2.1 = b.1) psL :=
    kvE2_sepForall₂_chain' (fun p r hpr => ⟨hpr.1, hpr.2.1⟩) hfL hlinkL
  have hlinkPsR : List.IsChain (fun a b => a.2.1 = b.1) psR :=
    kvE2_sepForall₂_chain' (fun p r hpr => ⟨hpr.1, hpr.2.1⟩) hfR hlinkR
  -- Per-side strict range bounds on the stitched chains.
  have hLlow : ∀ y ∈ interleaveK psL, x < y :=
    (k1v_stitch_regions psL x hsortPsL hrangePsL hposPsL hlinkPsL hloPsL).2
  have hRlow : ∀ y ∈ interleaveK psR, w < y :=
    (k1v_stitch_regions psR w hsortPsR hrangePsR hposPsR hlinkPsR hloPsR).2
  have hLhigh : ∀ y ∈ interleaveK psL, y < w :=
    kvE2_sepInterleaveK_lt psL w (fun p hp q hq => (hrangePsL p hp q hq).2)
      hposPsL hlinkPsL hhiPsL
  have hRhigh : ∀ y ∈ interleaveK psR, y < t :=
    kvE2_sepInterleaveK_lt psR t (fun p hp q hq => (hrangePsR p hp q hq).2)
      hposPsR hlinkPsR hhiPsR
  refine ⟨psL, psR, hfL, hfR,
    fun y hy => ⟨hLlow y hy, hLhigh y hy⟩,
    fun y hy => ⟨hRlow y hy, hRhigh y hy⟩, ?_⟩
  -- Stitch around the single shared pivot `w`.
  rw [List.pairwise_append]
  refine ⟨hsortL, List.pairwise_cons.mpr ⟨fun y hy => hRlow y hy, hsortR⟩, ?_⟩
  intro a ha b hb
  have haw : a < w := hLhigh a ha
  rcases List.mem_cons.mp hb with rfl | hb'
  · exact haw
  · exact haw.trans (hRlow b hb')

end Bimodal.Metalogic.WeakCanonical.Kamp
