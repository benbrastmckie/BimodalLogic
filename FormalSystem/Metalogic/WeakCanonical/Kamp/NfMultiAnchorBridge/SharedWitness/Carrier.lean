/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.OrderGate

/-! # Shared-Interior-Witness Joint Carrier — the joint carrier (O1)

Module C of the `SharedWitness` tower. The joint carrier definition `kvE2_sepBody` — the
shared-interior-witness conjunction realized as a flat order-type disjunction (Rabinovich
Lemma 3.2(1), PDF p.3) — together with its gate discharge `kvE2_sepGate_holds_of_honest`
and the coincident-anchor discharge.

`kvE2_sepBody` is the FIRST declaration of this module and precedes every consumer
(`kvE2_sepBody_extract` in `Assembly`, `kvE2_outer_fold_frag` in `FragmentFoldRight`), so
the tower has no forward reference into it. -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## The joint carrier (O1) -/

/-- **`kvE2_sepBody` — the joint separate-content shared-witness carrier** (O1,
    subsequently rewired). Model-independent: disjuncts enumerate the ORDER-TYPE
    DISJUNCTION `kvE2_sepArr'` — one FLAT bracket per VALID weak order on the merged anchor set
    (Lemma 3.2(1), PDF p.3), where each disjunct reads the zone bit appropriate to its own arrangement
    (strict disjuncts the OPEN `zXU`/`zUW` bits, the coincidence disjunct the CLOSED `zAtX1L` bit;
    §5 meet-typed shared point, PDF p.6). The bracket (`kvE2_sepDisjunct`) carries one shared
    `ptW`, per-σ E[Σ]-atom fresh slots, refined-conjunction segments, and the joint endpoint
    conjunction at the fixed anchors (Lemma 3.2(2), PDF p.3: everything over the two free variables
    `(x, t)`), built over the canonical per-owner region-block slot lists `kvE2_sepSlotsL/R qnf`.
    Gate-failure branch is the empty disjunction (its `holds` is `False`). Non-vacuity now follows
    from `kvE2_sepArr' ≠ []` (the coincidence disjunct is admitted by the closed channel), NEVER
    from a valid slot permutation of the flat union (which can be empty — handoff 05). -/
noncomputable def kvE2_sepBody {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : VVecEA2 :=
  @dite _ (kvE2_sepGate qnf) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          -- Rewired OFF `List.Perm.refl`/the additive `kvE2_sepArrL/R`
          -- flat-union permutation-filter ONTO the order-type disjunction `kvE2_sepArr'`
          -- (Lemma 3.2(1), PDF p.3). One disjunct per VALID weak order (per-order-type validity);
          -- the bracket carries the region-partitioned Def 3.1 point/segment content over the
          -- canonical per-owner region blocks. Non-vacuity now follows from `kvE2_sepArr' ≠ []`
          -- (the coincidence disjunct is admitted by the closed channel), never from a valid slot
          -- permutation of the flat union (which can be empty — handoff 05).
          -- CONSUME `wo` — each disjunct realizes its OWN cross-owner slot
          -- order `kvE2_sepSlotsLOf/ROf wo` (the per-owner blocks sequenced by wo's merged-chain
          -- rank), NEVER the discarded-`_wo` fixed concatenation `kvE2_sepSlotsL/R qnf` (root bug).
          -- Meet-folded GROUPED disjuncts — one strict bracket slot per tie
          -- class (`kvE2_sepTieGroupedL/R wo`, the index-level tie classes), point type = the
          -- meet of the tied slot types (`kvE2_sepDisjunct'`). On a Nodup payload the groups
          -- are singletons and the disjunct agrees with the flat per-slot builder
          -- (`kvE2_sepDisjunct'_map_singleton_iff`). Strict-quotient guard: ties collapse the
          -- index, never the bracket.
          (kvE2_sepArr' qnf).map fun wo =>
            kvE2_sepDisjunct' charBase charK qnf
              (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo) })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation (mirror of the landed `_gate_fail` house pattern). -/
theorem kvE2_sepBody_gate_fail {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (h : ¬ kvE2_sepGate qnf) :
    kvE2_sepBody charBase charK qnf = { disjuncts := [] } := by
  simp only [kvE2_sepBody]
  exact dif_neg h

/-- **O2 — arrangement-product membership collapse** for the joint enumeration: on the
    gate-true branch, the carrier holds at the fixed endpoints iff SOME pair of left/right
    interleavings' disjunct holds. Carrier-specific instantiation of the landed structural
    collapse `VVecEA2.holds_flatMap_map` (`NavigatedSpine.lean:220`), applying by
    `rw [dif_pos]` because the disjunct builder and both interleaving sets are TOP-LEVEL
    defs (crux failed-closer-3 lesson: no `let`-buried `S_L`/`S_R`/`mkDisjunct`). -/
theorem kvE2_sepBody_holds_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (hg : kvE2_sepGate qnf)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier) :
    (kvE2_sepBody charBase charK qnf).holds M atomMap x t ↔
      ∃ wo ∈ kvE2_sepArr' qnf,
        (kvE2_sepDisjunct' charBase charK qnf
          (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t := by
  simp only [kvE2_sepBody]
  rw [dif_pos hg]
  simp only [VVecEA2.holds, List.mem_map]
  constructor
  · rintro ⟨vea, ⟨wo, hwo, rfl⟩, hvea⟩
    exact ⟨wo, hwo, hvea⟩
  · rintro ⟨wo, hwo, hvea⟩
    exact ⟨_, ⟨wo, hwo, rfl⟩, hvea⟩

/-! ## O1b — non-vacuity (fresh analog of `kvE_subBracket2V_nonvacuous`,
`SubBracket2V.lean:1425`; FM-vac discipline: the honest configuration must take the
gate-true branch and produce a NON-empty disjunct list, so no later direction can close
vacuously). -/

/-- Bool bridge: a truth-value biconditional forces Bool equality. -/
private theorem kvE2_sep_boolEq {b c : Bool} (h : (b = true) ↔ (c = true)) : b = c := by
  cases b <;> cases c <;> simp_all

/-- A trivially-total relation is pairwise on any list. -/
private theorem kvE2_sep_pairwise_of_forall {α : Type} {R : α → α → Prop} :
    ∀ {l : List α}, (∀ a b, R a b) → l.Pairwise R
  | [], _ => List.Pairwise.nil
  | _ :: _, h => List.Pairwise.cons (fun b _ => h _ b) (kvE2_sep_pairwise_of_forall h)

/-- Pairwise over a `flatMap` from within-block pairwise + cross-block totality on a
    duplicate-free spine. -/
private theorem kvE2_sep_pairwise_flatMap {α β : Type} {R : β → β → Prop}
    {f : α → List β} {l : List α} (hnd : l.Nodup)
    (hin : ∀ a ∈ l, (f a).Pairwise R)
    (hcross : ∀ a ∈ l, ∀ b ∈ l, a ≠ b → ∀ x ∈ f a, ∀ y ∈ f b, R x y) :
    (l.flatMap f).Pairwise R := by
  induction l with
  | nil => exact List.Pairwise.nil
  | cons a as ih =>
    rw [List.flatMap_cons, List.pairwise_append]
    obtain ⟨hna, hnd'⟩ := List.nodup_cons.mp hnd
    refine ⟨hin a List.mem_cons_self,
      ih hnd' (fun b hb => hin b (List.mem_cons_of_mem _ hb))
        (fun b hb c hc => hcross b (List.mem_cons_of_mem _ hb) c (List.mem_cons_of_mem _ hc)),
      ?_⟩
    intro x hx y hy
    obtain ⟨b, hb, hyb⟩ := List.mem_flatMap.mp hy
    exact hcross a List.mem_cons_self b (List.mem_cons_of_mem _ hb)
      (fun he => hna (he ▸ hb)) x hx y hyb

/-- Same-owner rank monotonicity satisfies the validity relation (the `if`-true branch). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (E).
theorem kvE2_sepSlotLe_same {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {a b : KvE2SepSlot sig}
    (hsub : kvE2_sepSlotSub a = kvE2_sepSlotSub b)
    (h : kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [if_pos hsub]
  exact decide_eq_true h

/-- Distinct owners satisfy the validity relation exactly when cross-σ bit-compatible
    (`kvE2_sepCompat`) — the compat-aware replacement of the unconditional `_of_sub_ne`. -/
private theorem kvE2_sepSlotLe_of_ne_compat {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {a b : KvE2SepSlot sig}
    (h : kvE2_sepSlotSub a ≠ kvE2_sepSlotSub b)
    (hc : kvE2_sepCompat a b = true) : kvE2_sepSlotLe a b = true := by
  unfold kvE2_sepSlotLe
  rw [if_neg h]
  exact hc

/-- Same-owner, rank-sorted lists are `kvE2_sepSlotLe`-pairwise (bridges a rank-only
    `Pairwise` to the validity relation on a single-σ block). -/
private theorem kvE2_sep_pairwise_rank_same {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {l : List (KvE2SepSlot sig)} {σ : NormalForm sig 1 4}
    (hsub : ∀ s ∈ l, kvE2_sepSlotSub s = σ)
    (hr : l.Pairwise (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b)) :
    l.Pairwise (fun a b => kvE2_sepSlotLe a b = true) := by
  induction l with
  | nil => exact List.Pairwise.nil
  | cons x xs ih =>
    rw [List.pairwise_cons] at hr ⊢
    refine ⟨fun b hb => kvE2_sepSlotLe_same ?_ (hr.1 b hb),
      ih (fun s hs => hsub s (List.mem_cons_of_mem _ hs)) hr.2⟩
    rw [hsub x List.mem_cons_self, hsub b (List.mem_cons_of_mem _ hb)]

/-- Every slot of σ's canonical LEFT block is owned by σ. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (E).
theorem kvE2_sepSlotsLFor_sub {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (h : s ∈ kvE2_sepSlotsLFor σ) : kvE2_sepSlotSub s = σ := by
  unfold kvE2_sepSlotsLFor at h
  split at h
  · rcases List.mem_append.mp h with h' | h'
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h'; rfl
    · rcases List.mem_cons.mp h' with rfl | h''
      · rfl
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h''; rfl
  · split at h
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h; rfl
    · exact (List.not_mem_nil h).elim

/-- Every slot of σ's canonical RIGHT block is owned by σ. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (E).
theorem kvE2_sepSlotsRFor_sub {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    {s : KvE2SepSlot sig} (h : s ∈ kvE2_sepSlotsRFor σ) : kvE2_sepSlotSub s = σ := by
  unfold kvE2_sepSlotsRFor at h
  split at h
  · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h; rfl
  · split at h
    · rcases List.mem_append.mp h with h' | h'
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h'; rfl
      · rcases List.mem_cons.mp h' with rfl | h''
        · rfl
        · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp h''; rfl
    · exact (List.not_mem_nil h).elim

/-- σ's canonical LEFT block respects the region-rank order (`XU* < x1 < UW*`). -/
private theorem kvE2_sepSlotsLFor_rankPairwise {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise
      (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  unfold kvE2_sepSlotsLFor
  split
  · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.zero_le _))
    · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
      · intro b hb
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
        exact (Nat.le_succ 1)
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
    · intro s hs b _
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
      exact (Nat.zero_le _)
  · split
    · exact List.pairwise_map.mpr
        (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
    · exact List.Pairwise.nil

/-- σ's canonical LEFT block is a valid same-owner arrangement. -/
private theorem kvE2_sepSlotsLFor_pairwise {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsLFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) :=
  kvE2_sep_pairwise_rank_same (fun _ hs => kvE2_sepSlotsLFor_sub hs)
    (kvE2_sepSlotsLFor_rankPairwise σ)

/-- σ's canonical RIGHT block respects the region-rank order (`WX1* < x1 < X1T*`). -/
private theorem kvE2_sepSlotsRFor_rankPairwise {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise
      (fun a b => kvE2_sepSlotRank a ≤ kvE2_sepSlotRank b) := by
  unfold kvE2_sepSlotsRFor
  split
  · exact List.pairwise_map.mpr
      (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
  · split
    · refine List.pairwise_append.mpr ⟨?_, ?_, ?_⟩
      · exact List.pairwise_map.mpr
          (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.zero_le _))
      · refine List.pairwise_cons.mpr ⟨?_, ?_⟩
        · intro b hb
          obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hb
          exact (Nat.le_succ 1)
        · exact List.pairwise_map.mpr
            (kvE2_sep_pairwise_of_forall fun _ _ => (Nat.le_refl _))
      · intro s hs b _
        obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hs
        exact (Nat.zero_le _)
    · exact List.Pairwise.nil

/-- σ's canonical RIGHT block is a valid same-owner arrangement. -/
private theorem kvE2_sepSlotsRFor_pairwise {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) :
    (kvE2_sepSlotsRFor σ).Pairwise (fun a b => kvE2_sepSlotLe a b = true) :=
  kvE2_sep_pairwise_rank_same (fun _ hs => kvE2_sepSlotsRFor_sub hs)
    (kvE2_sepSlotsRFor_rankPairwise σ)

/-- The positive-sub spine is duplicate-free (`Finset.univ.toList` + filter). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (E).
theorem kvE2_sepPos_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    (kvE2_sepPos qnf).Nodup :=
  (Finset.nodup_toList _).filter _

-- REMOVED: the two FALSE scaffolds `kvE2_sepSlotsL_valid`/`kvE2_sepSlotsR_valid`
-- (which asserted `kvE2_sepValid (kvE2_sepSlotsL/R qnf) = true` — the identity interleaving of the
-- flat union is a valid additive arrangement). They were documented FALSE post-switch (the identity
-- interleaving need not be cross-σ compat; handoff 05) and carried the two `sorryAx` placeholders
-- that contaminated `kvE2_sepBody_nonvacuous`. The rewired non-vacuity routes through the
-- order-type
-- disjunction `kvE2_sepArr'` (`kvE2_sepArr'_mem_modelOrder`), which is axiom-clean. (Risk R5.)

/-- Dropping the fresh coordinate of a REALIZED arity-4 depth-0 base recovers the
    arity-3 base realized at the same three points (Def 3.1 env-restriction channel):
    both sides answer every `[w,x,t]`-atom by the same model truth. -/
private theorem kvE2_sep_dropFresh_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {x1 w x t : M.carrier}
    (σ1 : NormalForm sig 0 4) (r : NormalForm sig 0 3)
    (hσ : ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ1 a = true)
    (hr : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ r a = true) :
    nf0_dropFresh σ1 = r := by
  funext a
  match a with
  | .pred p i =>
    have h4 := hσ (.pred p i.succ)
    have h3 := hr (.pred p i)
    simp only [atom_eval, Fin.cons_succ] at h4 h3
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    exact kvE2_sep_boolEq (h4.symm.trans h3)
  | .order i j hne =>
    have h4 := hσ (.order i.succ j.succ (fun he => hne (Fin.succ_injective _ he)))
    have h3 := hr (.order i j hne)
    simp only [atom_eval, Fin.cons_succ] at h4 h3
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    exact kvE2_sep_boolEq (h4.symm.trans h3)

/-- **Arity-3 outer zone consistency** (fresh analog of the private arity-4
    `kvE_sub2V_zone_consistent`, `SubBracket2V.lean:1270` — template only, new code):
    a point realized in some zone relative to the honest `[w,x,t]` (with `x < w < t`)
    sits in one of the SEVEN consistent outer zones (Def 3.1, PDF pp.2-3). -/
private theorem kvE2_sep_zone3_consistent {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    kvE2_sepOuterConsistent zs := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  have hzs : ∀ (p0 p1 p2 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
      zs = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
    intro p0 p1 p2 e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => exact e0
    | ⟨1, _⟩ => exact e1
    | ⟨2, _⟩ => exact e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | rfl | hux
  · -- u < x : zPastX3
    have huw : u < w := hux.trans hxw
    have hut : u < t := hux.trans hxt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX3
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl _),
        k1v_bool_eq_false h1.2 (lt_irrefl _)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against w
    rcases lt_trichotomy u w with huw | rfl | huw
    · -- x < u < w : zXW3
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w : zAtW3 (the shared-witness self-zone)
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl _),
          k1v_bool_eq_false h0.2 (lt_irrefl _)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u : split against t
      rcases lt_trichotomy u t with hut | rfl | hut
      · -- w < u < t : zWT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t : zAtT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl _),
            k1v_bool_eq_false h2.2 (lt_irrefl _)⟩)))))))
      · -- t < u : zFutT3
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- RIGHT-geometry mirror of `kvE2_sep_zone4_consistent`: any zone realized over `[x1,w,x,t]`
    with `x < w < x1 < t` is one of the nine `kvE2_sepInnerConsistentR` zones. Its contrapositive
    is the h_fwd direction; `hInnerR` supplies the bit→consistent direction (the fragR blocker). -/
theorem kvE2_sep_zone4_consistentR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t u : M.carrier)
    (hxw : x < w) (hwx1 : w < x1) (hx1t : x1 < t)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs u) :
    kvE2_sepInnerConsistentR zs := by
  unfold kvE2_sepInnerConsistentR
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
  have hwt : w < t := hwx1.trans hx1t
  have hxt : x < t := hxw.trans hwt
  have hxx1 : x < x1 := hxw.trans hwx1
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x : zPastX
    have hux1 : u < x1 := hux.trans hxx1
    have huw : u < w := hux.trans hxw
    have hut : u < t := hux.trans hxt
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
  · -- x < u : split against w
    rcases lt_trichotomy u w with huw | huw | huw
    · -- x < u < w : zXW  (kvE_sub2_zXU pattern)
      have hux1 : u < x1 := huw.trans hwx1
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))
    · -- u = w : zAtWR
      subst huw
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hwx1, k1v_bool_eq_false h0.2 (lt_asymm hwx1)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
          k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxw), h2.2.mp hxw⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hwt, k1v_bool_eq_false h3.2 (lt_asymm hwt)⟩)))))
    · -- w < u : split against x1
      have hxu : x < u := hxw.trans huw
      rcases lt_trichotomy u x1 with hux1 | hux1 | hux1
      · -- w < u < x1 : zWX1
        have hut : u < t := hux1.trans hx1t
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))
      · -- u = x1 : zAtX1R
        subst hux1
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
            k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwx1), h1.2.mp hwx1⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxx1), h2.2.mp hxx1⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hx1t, k1v_bool_eq_false h3.2 (lt_asymm hx1t)⟩)))))))
      · -- x1 < u : split against t
        have hx1u : x1 < u := hux1
        have hwu : w < u := hwx1.trans hx1u
        have hxu' : x < u := hxw.trans hwu
        rcases lt_trichotomy u t with hut | hut | hut
        · -- x1 < u < t : zX1T  (kvE_sub2_zWT pattern)
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu), h1.2.mp hwu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))))
        · -- u = t : zAtT
          subst hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu), h1.2.mp hwu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_irrefl u),
              k1v_bool_eq_false h3.2 (lt_irrefl u)⟩)))))))))
        · -- t < u : zFutT
          have hx1u' : x1 < u := hx1t.trans hut
          have hxu'' : x < u := hxt.trans hut
          have hwu' : w < u := hwt.trans hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u'), h0.2.mp hx1u'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu'), h1.2.mp hwu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu''), h2.2.mp hxu''⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_asymm hut), h3.2.mp hut⟩)))))))))

/-- **The depth-2 joint gate holds for an honest `qnf`** (the arity-3 lift of
    `kvE_subBracket2V_gate_holds_of_honest`, `SubBracket2V.lean:1392`): from an honest
    depth-2 realization at `[w,x,t]` under `x < w < t`, all four gate clauses hold —
    (i)/(ii) by realizing each positive sub and reading its atom layer against the model
    (Prop 4.2, PDF p.3); (iii) via the landed depth-1 fold decomposition
    (`nf_eval_depth1_fold_iff`, `CarrierKv.lean:466`); (iv) by CONSUMING the landed per-σ
    honest gate lemma at the realized fresh witness. -/
theorem kvE2_sepGate_holds_of_honest {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    kvE2_sepGate qnf := by
  obtain ⟨h_atom, h_quant⟩ := h
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- (i) outer off-fiber falsity
    intro σ hne
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
      exact absurd
        (kvE2_sep_dropFresh_eq M σ.1 qnf.1
          ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1 h_atom) hne
  · -- (ii) outer seven-zone consistency
    intro σ hncons
    cases hb : qnf.2 σ with
    | false => rfl
    | true =>
      obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
      have hσ_atom := ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1
      have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec σ.1) x1 := by
        intro i
        constructor
        · have h1 := hσ_atom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
          simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
          exact h1
        · have h1 := hσ_atom (.order i.succ 0 (Fin.succ_ne_zero i))
          simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
          exact h1
      exact absurd (kvE2_sep_zone3_consistent M w x t x1 hxw hwt _ hz) hncons
  · -- (iii) inner off-fiber falsity for every positive sub
    intro σ hb
    obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
    exact ((nf_eval_depth1_fold_iff M _ σ).mp hσ).2.2
  · -- (iv) inner nine-zone consistency for LEFT-interior positives
    intro σ hb hzone
    obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
    have hσ_atom := ((nf_eval_depth1_fold_iff M _ σ).mp hσ).1
    -- Read the two left-interior order bits off the placement guard (the zone-spec
    -- components ARE σ.1's fresh-coupling order bits, `nf0_zoneSpec` def).
    have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨1, by omega⟩]; decide
    have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    -- Transfer the bits to real order facts through the realized atom layer.
    have hxx1 : x < x1 := by
      have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_xx1
    have hx1w : x1 < w := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_x1w
    exact fun zs χ hncons =>
      (kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt hσ).2 zs χ hncons
  · -- (v) inner nine-zone consistency for RIGHT-interior positives (mirror of iv)
    intro σ hb hzone
    obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
    obtain ⟨hσ_atom, h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
    -- Read the two right-interior order bits off the RIGHT placement guard.
    have hbit_wx1 : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
      rw [congrFun hzone ⟨0, by omega⟩]; decide
    have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
      rw [congrFun hzone ⟨2, by omega⟩]; decide
    have hwx1 : w < x1 := by
      have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_wx1
    have hx1t : x1 < t := by
      have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
      simp only [atom_eval, Fin.cons] at h1
      exact h1.mpr hbit_x1t
    -- Any marked bit realizes its zone over [x1,w,x,t]; the RIGHT classifier forces consistency.
    intro zs χ hncons
    cases hbit : σ.2 (nf0_assemble zs χ σ.1) with
    | false => rfl
    | true =>
      obtain ⟨u, hzu, _hu⟩ := (h_zone zs χ).mpr hbit
      exact absurd (kvE2_sep_zone4_consistentR M x1 w x t u hxw hwx1 hx1t zs hzu) hncons

/-- **Per-σ honest witness bundle (LEFT list, left-interior σ)** — point-map step 1
    (the ⇐-direction of Rabinovich Lemma 3.2(1), PDF p.3). From the qnf
    honest realization, a LEFT-interior positive σ (`x < x1_σ < w`, guard `hzone`) has at
    its extracted fresh anchor `x1_σ` a real witness point in `(x, x1_σ)` for every 1-type
    in `kvE2_sepS σ kvE_sub2_zXU`, and one in `(x1_σ, w)` for every 1-type in
    `kvE2_sepS σ kvE_sub2_zUW`. These are exactly the `hrealXU`/`hrealUW` inputs the joint
    slot sort consumes to place each foreign χ-slot on the model-correct side of `x1_σ` (so
    that `kvE2_sepCompat` holds via `kvE2_sepCompat_lX1_eq`/`_lX1_after_eq`). Reuses the
    do-not-edit extractor `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`); no new
    model reasoning, and NO `x1 < e_i` model-order literal is exposed (LITMUS: the anchor
    `x1_σ` is an interval endpoint of the witness bundle, never compared to a slot index). -/
private theorem kvE2_sepHonestBundleL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (_hxw : x < w) (_hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :
    ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zXU,
        ∃ u : M.carrier, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zUW,
        ∃ u : M.carrier, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  obtain ⟨h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  obtain ⟨hσ_atom, _h_off, _h_zonefwd, hbelowXU, hbelowUW, _hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hbit_xx1 : (nf0_zoneSpec σ.1 ⟨1, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨1, by omega⟩]; decide
  have hbit_x1w : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hxx1 : x < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨1, by omega⟩) 0 (Fin.succ_ne_zero ⟨1, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_xx1
  have hx1w : x1 < w := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨0, by omega⟩) (Fin.succ_ne_zero ⟨0, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1w
  refine ⟨x1, hxx1, hx1w, ?_, ?_⟩
  · intro χ hχ
    obtain ⟨u, hxu, _huw, hux1, hrel⟩ := hbelowXU χ (List.mem_filter.mp hχ).2
    exact ⟨u, hxu, hux1, hrel⟩
  · intro χ hχ
    exact hbelowUW χ (List.mem_filter.mp hχ).2

/-- **Per-owner RIGHT honest bundle** (C13 — the completeness-side mirror of
    `kvE2_sepHonestBundleL` :1207). From an honest `qnf` and a RIGHT-interior owner σ
    (`nf0_zoneSpec σ.1 = kvE2_sep_zWT3`, i.e. `w < x1 < t`), extract σ's fresh anchor `x1`
    strictly inside `(w, t)` together with real witnesses for each of its `zWX1`-positive
    (region `(w, x1)`) and `zWT`-positive (region `(x1, t)`) 1-types. Symmetric to the LEFT
    bundle: the LEFT bundle serves `zXU`/`zUW` around a `(x, w)`-interior anchor; this serves
    `zWX1`/`zWT` around a `(w, t)`-interior anchor (`kvE_sub2_zWT` reads `x1 < v < t` for a
    right-interior σ, per the placement-generic comment :102-105).

    Proof route (mirrors L, per plan 03 Phase-7 tasks): `qnf`'s depth-2 quant layer supplies σ's
    model witness `x1`; the depth-1 fold decomposition `nf_eval_depth1_fold_iff` (the extractor's
    generic zone-forward channel, the SAME `h_zone` iff feeding `kvE_subBracket2_complete_extract`)
    fired REVERSE (`.mpr`) at zones `zWX1`/`zWT` yields the region witnesses, whose intervals are
    decoded by the pure order fact `kvE_sub2_zoneHolds_cons_iff` (the Phase-3 region structure;
    Def 3.1 exterior/interior β, PDF p.3; Lemma 3.2(1) ⇐ honest arrangement, PDF p.3). No
    `x1 < e_i` literal (F4); QF point types only (F1); disjunction realized non-vacuously per
    honest owner (F2). -/
private theorem kvE2_sepHonestBundleR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (_hxw : x < w) (_hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (σ : NormalForm sig 1 4) (hσpos : σ ∈ kvE2_sepPos qnf)
    (hzone : nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
      (∀ χ ∈ kvE2_sepS σ kvE2_sep_zWX1,
        ∃ u : M.carrier, w < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ) ∧
      (∀ χ ∈ kvE2_sepS σ kvE_sub2_zWT,
        ∃ u : M.carrier, x1 < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ) := by
  have hb : qnf.2 σ = true := (List.mem_filter.mp hσpos).2
  obtain ⟨_h_atom, h_quant⟩ := h
  obtain ⟨x1, hσ⟩ := (h_quant σ).mpr hb
  obtain ⟨hσ_atom, h_zone, _h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hσ
  have hbit_wx1 : (nf0_zoneSpec σ.1 ⟨0, by omega⟩).2 = true := by
    rw [congrFun hzone ⟨0, by omega⟩]; decide
  have hbit_x1t : (nf0_zoneSpec σ.1 ⟨2, by omega⟩).1 = true := by
    rw [congrFun hzone ⟨2, by omega⟩]; decide
  have hwx1 : w < x1 := by
    have h1 := hσ_atom (.order (Fin.succ ⟨0, by omega⟩) 0 (Fin.succ_ne_zero ⟨0, by omega⟩))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_wx1
  have hx1t : x1 < t := by
    have h1 := hσ_atom (.order 0 (Fin.succ ⟨2, by omega⟩) (Fin.succ_ne_zero ⟨2, by omega⟩).symm)
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr hbit_x1t
  refine ⟨x1, hwx1, hx1t, ?_, ?_⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE2_sep_zWX1 χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE2_sep_zWX1 χ).mpr hbit
    obtain ⟨hp0, hp1, _, _⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (true, false) (false, true) (false, true)
        (true, false)).mp hz
    exact ⟨v, hp1.2.mpr rfl, hp0.1.mpr rfl, hv⟩
  · intro χ hχ
    have hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zWT χ).mpr hbit
    obtain ⟨hp0, _, _, hp3⟩ :=
      (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (false, true) (false, true)
        (true, false)).mp hz
    exact ⟨v, hp0.2.mpr rfl, hp3.1.mpr rfl, hv⟩

/-- **Fresh-anchor / base-χ point distinctness — REDUCED FORM**.
    σ's fresh anchor `x1` realizes σ at env `[x1,w,x,t]`; its OWN depth-0 arity-1 base type is
    therefore `nf0_projFresh σ.1` (extracted by `nf_eval_nf0_cons_factor`). Hence any point `p`
    realizing a base type `χ` that DIFFERS from `nf0_projFresh σ.1` is distinct from `x1`
    (`nf_eval_unique` forces the two base types equal on coincidence). This is the honest,
    sorry-free, axiom-clean distinctness engine.

    IMPORTANT (make-or-break residual): the hypothesis `hχne : χ ≠ nf0_projFresh σ.1` is the
    genuine obstruction. Research established (and the crux investigation confirmed) that there
    is NO fresh-vs-base type-separation lemma, and the "E[Σ]-atom incompatible with a base type
    at a point" intuition is UNSOUND (`charK = existF` is existential; a point may satisfy both).
    So the distinctness `p ≠ x1` can only come from the base-type inequality `χ ≠ nf0_projFresh
    σ.1`,
    which is NOT dischargeable for arbitrary cross-owner base types — distinct positive owners may
    carry the same base type, and a foreign owner's χ-witness may coincide exactly with another
    owner's fresh anchor. See the Phase-2 blocker note in the plan. -/
theorem kvE2_sepFreshAnchor_ne_baseChiPoint {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (p : M.carrier) (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => p) χ)
    (hχne : χ ≠ nf0_projFresh σ.1) :
    p ≠ x1 := by
  intro heq
  subst heq
  have hσ1 : nf_eval_nf M 0 4 (Fin.cons p (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 :=
    hσ.1
  have hfresh : nf_eval_nf M 0 1 (fun _ => p) (nf0_projFresh σ.1) :=
    ((nf_eval_nf0_cons_factor M (Fin.cons w (Fin.cons x (fun _ => t))) p σ.1).mp hσ1).2.1
  exact hχne (nf_eval_unique M 0 1 (fun _ => p) χ (nf0_projFresh σ.1) hp hfresh)

/-- **CRUX VERIFICATION SPIKE — coincident-anchor discharge** (the
    front-loaded make-or-break). At a shared anchor `v = x1` (σ's fresh witness point), a
    foreign base type `χ` realized AT that point (`nf_eval_nf M 0 1 (fun _ => x1) χ`) discharges
    σ's CLOSED self-zone fold bit `kvE2_sepBits σ kvE2_sep_zAtX1L χ` — WITHOUT any `p ≠ x1`
    inequality. Route: the extractor's generic zone-forward channel
    (`SubBracket2.lean:614-618`, `∀ zs χ, (∃ v, zoneHolds env zs v ∧ v realizes χ) → bit = true`)
    fired at the closed self-zone `kvE2_sep_zAtX1L` with witness `v = x1` (`zoneHolds` at the
    anchor is a pure order fact given `x < x1 < w < t`). This is the Rabinovich §5 shared-anchor
    meet-type identification (PDF p.6): the point genuinely realizes both σ's depth-1 fresh
    type and the foreign depth-0 `χ` (existential `charK`, NavigatedSpine:411), so the coincidence
    is DISCHARGED, not refuted. No extractor extension needed — the generic channel already
    quantifies over ALL zone specs including the closed self-zone. -/
theorem kvE2_sepCoincidentAnchor_discharge {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1)
    (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepBits σ kvE2_sep_zAtX1L χ = true := by
  obtain ⟨_, _, h_zonefwd, _, _, _⟩ := kvE_subBracket2_complete_extract σ M x1 w x t hσ
  have hx1t : x1 < t := lt_trans hx1w hwt
  refine h_zonefwd kvE2_sep_zAtX1L χ ⟨x1, ?_, hp⟩
  -- `zoneHolds env kvE2_sep_zAtX1L x1` is a pure order fact (v = x1: `x < x1 < w < t`).
  refine (kvE_sub2_zoneHolds_cons_iff M x1 w x t x1
    (false, false) (true, false) (false, true) (true, false)).mpr ?_
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_false (lt_irrefl _) (by decide)
  · exact iff_of_true hx1w rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1w)) (by decide)
  · exact iff_of_false (not_lt.mpr (le_of_lt hxx1)) (by decide)
  · exact iff_of_true hxx1 rfl
  · exact iff_of_true hx1t rfl
  · exact iff_of_false (not_lt.mpr (le_of_lt hx1t)) (by decide)

-- REMOVED: the dead conditional non-vacuity lemma
-- `kvE2_sepBody_nonvacuous`. Its hypothesis `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder
-- qnf) = true` is NOT honestly attainable (the strict `kvE2_sepModelOrder` reads σ's OPEN
-- `zXU`/`zUW` bits at σ's own fresh type, FALSE at self-coincidence; the honest disjunct is the
-- coincidence order `kvE2_sepCoincidentOrder`). It had zero live consumers and is superseded by the
-- unconditional `kvE2_sepBody_complete` (`Completeness.lean`). See plan 04, Phase 1.

end FormalSystem.Metalogic.WeakCanonical.Kamp
