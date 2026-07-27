/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberKitK1
import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull

/-! # Since-navigated w-package `navPackLeft`

Folds the w-DEPENDENT fibers of the past-exterior channel `w < x < t` — the atoms at `w`,
and the three w-anchored zones `v < w`, `v = w`, `w < v < x` of the Phase-13 kit
(`extZoneFiber_k1`, ExteriorFiberKitK1.lean) — into a SINGLE one-free-variable temporal
predicate `navPackLeft σ : TemporalPred` evaluated at the pin `x`. The fold iff
`navPackLeft_correct` shows the predicate at `x` is exactly the `∃ w < x` package of the
four w-dependent clause groups, stated verbatim in the `extZoneFiber_k1` clause shapes so
the Phase-14c `∃w` glue consumes it by direct rewriting.

## Devices (per fiber class — the Phase 14a record)

| Fiber class | bit-TRUE device | bit-FALSE device |
|---|---|---|
| atoms at `w` | `nf_depth0_char_formula` on the position-0 projection | (same conjunction, literal
polarity) |
| zone `v = w` | characteristic conjunct `charF χ` at the Since-witness | negated characteristic
`(charF χ).neg` |
| zone `v < w` | native Since-lit `S(charF χ, ⊤)` at the witness | negated Since-lit `(S(charF χ,
⊤)).neg` |
| zone `w < v < x` | arrangement slot inside the fold (nested-Since chain `navLChain`, one disjunct
per permutation of the bit-true profile list) | exclusion segment `navLSegGuard` (segment guard =
disjunction of bit-TRUE characteristics; every interior point's unique profile is forced bit-true) |

Phase-11 `negFix` was NOT needed at any fiber: the exclusion-segment device suffices for
every bit-false `w < v < x` fiber because monadic profiles are exhaustive and exclusive
(`navL_profile_exists` / `navL_profile_unique`), so excluding a profile from a segment is
expressible as the segment guard above — no bracket-level negation is required.

## Structure

1. Local profile helpers (the `ExteriorNegation.lean` private-idiom copies).
2. `navLProjW` / `navLPastLit` / `navLAtWPack` — the w-point package and its reading.
3. `navLBitTrueList` / `navLSegGuard` — the `(w,x)` exclusion segment.
4. `navLChain` — the nested-Since arrangement chain (Lemma 7.10 shape; the `buildLeft`
   Since-chain technique of Translation.lean, anchored at the w-package instead of `H`).
5. `navLChain_sound` / `navLChain_complete` — chain semantics both directions (the
   completeness side threads witnesses by repeated maximum extraction).
6. `navPackLeft` + **`navPackLeft_correct`** — the E2 fold iff.

## Guards

G1 — lossless re-fibering only; the `∃w` stays honest (it is literally the RHS binder).
G2/G4 — anchors: only the pin `x` is free; `w` is existentially introduced by the fold and
no interior point enters an env. G5 — every bridge is a manual
`constructor`/`intro`/`exact` step. FORBIDDEN `nf_char3_deeper_split` is not referenced.
No frozen file is touched.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem": **Lemma 7.10 / Prop 3.5** one-free-variable
  fold to TL(Since, K⁺) (chunks 0023, 0010) — the exact device this module instantiates.
- Phase-13 kit consumed by name: `extZBelowW/extZAtW/extZIntWX` zone fibers of
  `extZoneFiber_k1` (ExteriorFiberKitK1.lean).
- The negfix-refactor design for the exterior carriers, Phase 14a (E2 — the past-side navigator).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

section ExteriorNavPast

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable (atomMap : Formula → sig.preds)
variable (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

/-! ## Local profile helpers (the ExteriorNegation.lean private idiom, re-derived) -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Monadic-profile evaluation unfolds to the per-predicate reading (the `AtomKind sig 1`
    order case is uninhabited). -/
private theorem navL_profile_iff (M : OrderedMonadicStructure sig)
    (v : M.carrier) (χ : NormalForm sig 0 1) :
    nf_eval_nf M 0 1 (fun _ => v) χ ↔
      (∀ p : sig.preds, M.interp p v ↔ χ (.pred p 0) = true) := by
  constructor
  · intro h p
    exact h (.pred p 0)
  · intro h a
    match a with
    | .pred p i =>
      have hi : i = 0 := Subsingleton.elim i 0
      subst hi
      exact h p
    | .order i j hij => exact absurd (Subsingleton.elim i j) hij

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Profiles realized by the same point coincide. -/
private theorem navL_profile_unique (M : OrderedMonadicStructure sig)
    (v : M.carrier) (χ χ' : NormalForm sig 0 1)
    (h : nf_eval_nf M 0 1 (fun _ => v) χ) (h' : nf_eval_nf M 0 1 (fun _ => v) χ') :
    χ = χ' := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have := ((h (.pred p 0)).symm.trans (h' (.pred p 0)))
    cases hχ : χ (.pred p 0) <;> cases hχ' : χ' (.pred p 0) <;> simp_all
  | .order i j hij => exact absurd (Subsingleton.elim i j) hij

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Every point realizes its depth-0 monadic characteristic. -/
private theorem navL_profile_exists (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

omit [DecidableEq sig.preds] in
/-- Depth-0 characteristic-formula correctness in `nf_eval` form (the
    `nf_depth0_char_correct'` idiom, local copy). -/
private theorem navL_char_correct (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  rw [nf_depth0_char_formula_correct]
  exact (navL_profile_iff M u χ).symm

/-! ## The w-point package: atoms at `w`, zone `v = w`, zone `v < w` -/

/-- Position-0 predicate projection of the arity-3 atom row: the monadic profile that the
    row prescribes AT the exterior witness `w`. -/
def navLProjW (row : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => row (.pred p ⟨0, by omega⟩)
  | .order _ _ _ => false

/-- Native past Since-lit: `S(charF χ, ⊤)` — "some strict-past point realizes `χ`". -/
noncomputable def navLPastLit (χ : NormalForm sig 0 1) : Formula :=
  Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top

omit [DecidableEq sig.preds] in
/-- Reading of the past Since-lit. -/
private theorem navL_pastLit_iff (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (navLPastLit atomMap h_surj χ) ↔
      ∃ v : M.carrier, v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navLPastLit, temporal_truth]
  constructor
  · rintro ⟨s, hsu, hφ, -⟩
    exact ⟨s, hsu, (navL_char_correct atomMap h_surj M χ s).mp hφ⟩
  · rintro ⟨v, hvu, hχ⟩
    exact ⟨v, hvu, (navL_char_correct atomMap h_surj M χ v).mpr hχ,
      fun r _ _ => temporal_truth_top M atomMap r⟩

/-- Generic polarity-group reading: the conjunction over ALL monadic profiles of the
    bit-directed literal (`lit χ` when the bit is true, `(lit χ).neg` when false) holds
    iff every profile's semantic clause matches its bit. -/
private theorem navL_bitGroup_iff (M : OrderedMonadicStructure sig) (u : M.carrier)
    (bit : NormalForm sig 0 1 → Bool) (lit : NormalForm sig 0 1 → Formula)
    (P : NormalForm sig 0 1 → Prop)
    (hlit : ∀ χ, temporal_truth M atomMap u (lit χ) ↔ P χ) :
    temporal_truth M atomMap u (formula_conjList
      (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
        if bit χ = true then lit χ else (lit χ).neg)) ↔
    ∀ χ : NormalForm sig 0 1, P χ ↔ bit χ = true := by
  rw [formula_conjList_iff]
  constructor
  · intro h χ
    have hmem : (if bit χ = true then lit χ else (lit χ).neg) ∈
        ((Finset.univ : Finset (NormalForm sig 0 1)).toList).map
          (fun χ => if bit χ = true then lit χ else (lit χ).neg) :=
      List.mem_map.mpr ⟨χ, Finset.mem_toList.mpr (Finset.mem_univ χ), rfl⟩
    have hφ := h _ hmem
    by_cases hb : bit χ = true
    · rw [if_pos hb] at hφ
      exact iff_of_true ((hlit χ).mp hφ) hb
    · rw [if_neg hb] at hφ
      exact iff_of_false (fun hP => (temporal_truth_neg M atomMap u (lit χ)).mp hφ
        ((hlit χ).mpr hP)) hb
  · intro h φ hmem
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hmem
    by_cases hb : bit χ = true
    · rw [if_pos hb]
      exact (hlit χ).mpr ((h χ).mpr hb)
    · rw [if_neg hb]
      exact (temporal_truth_neg M atomMap u (lit χ)).mpr
        (fun hφ => hb ((h χ).mp ((hlit χ).mp hφ)))

/-- **The w-point package**: atoms at `w` (position-0 projection characteristic), the
    `v = w` fiber group (characteristic literals), and the `v < w` fiber group (native
    Since-lits, negated Since-lits on bit-false fibers). -/
noncomputable def navLAtWPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navLProjW σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extZAtW χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extZBelowW χ σ.1) = true
         then navLPastLit atomMap h_surj χ
         else (navLPastLit atomMap h_surj χ).neg)]

/-- Reading of the w-point package: exactly the three w-anchored clause groups of
    `extZoneFiber_k1` (atom layer restricted to position 0; `v = w`; `v < w`). -/
private theorem navL_atWPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w : M.carrier) :
    temporal_truth M atomMap w (navLAtWPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => w) χ ↔ σ.2 (nf0_assemble extZAtW χ σ.1) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         (∃ v : M.carrier, v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
           σ.2 (nf0_assemble extZBelowW χ σ.1) = true)) := by
  simp only [navLAtWPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap w Formula.top := temporal_truth_top M atomMap w
  constructor
  · rintro ⟨h1, h2, h3, -⟩
    refine ⟨?_, ?_, ?_⟩
    · intro p
      have := (nf_depth0_char_formula_correct M atomMap h_surj (navLProjW σ.1) w).mp h1 p
      exact this
    · exact (navL_bitGroup_iff atomMap M w _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ w)).mp h2
    · exact (navL_bitGroup_iff atomMap M w _ _ _
        (fun χ => navL_pastLit_iff atomMap h_surj M χ w)).mp h3
  · rintro ⟨h1, h2, h3⟩
    refine ⟨?_, ?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navLProjW σ.1) w).mpr h1
    · exact (navL_bitGroup_iff atomMap M w _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ w)).mpr h2
    · exact (navL_bitGroup_iff atomMap M w _ _ _
        (fun χ => navL_pastLit_iff atomMap h_surj M χ w)).mpr h3

/-! ## The `(w, x)` exclusion segment -/

/-- The bit-TRUE `w < v < x` fiber profiles of `σ` (the arrangement-slot inventory). -/
noncomputable def navLBitTrueList (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) :=
  ((Finset.univ : Finset (NormalForm sig 0 1)).filter
    fun χ => σ.2 (nf0_assemble extZIntWX χ σ.1) = true).toList

private theorem navL_bitTrueList_mem (σ : NormalForm sig 1 3)
    (χ : NormalForm sig 0 1) :
    χ ∈ navLBitTrueList σ ↔ σ.2 (nf0_assemble extZIntWX χ σ.1) = true := by
  simp [navLBitTrueList, Finset.mem_toList, Finset.mem_filter]

private theorem navL_bitTrueList_nodup (σ : NormalForm sig 1 3) :
    (navLBitTrueList σ).Nodup :=
  Finset.nodup_toList _

/-- **The exclusion segment**: the disjunction of the bit-TRUE characteristics. A segment
    all of whose points satisfy it excludes every bit-FALSE profile (profiles are
    exhaustive and exclusive), which is exactly the bit-false `w < v < x` obligation. -/
noncomputable def navLSegGuard (σ : NormalForm sig 1 3) : Formula :=
  formula_disjList
    ((navLBitTrueList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Reading of the exclusion segment. -/
private theorem navL_segGuard_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (v : M.carrier) :
    temporal_truth M atomMap v (navLSegGuard atomMap h_surj σ) ↔
      ∃ χ : NormalForm sig 0 1, σ.2 (nf0_assemble extZIntWX χ σ.1) = true ∧
        nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navLSegGuard]
  rw [formula_disjList_iff]
  constructor
  · rintro ⟨φ, hmem, hφ⟩
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hmem
    exact ⟨χ, (navL_bitTrueList_mem σ χ).mp hχmem,
      (navL_char_correct atomMap h_surj M χ v).mp hφ⟩
  · rintro ⟨χ, hbit, hχ⟩
    exact ⟨_, List.mem_map.mpr ⟨χ, (navL_bitTrueList_mem σ χ).mpr hbit, rfl⟩,
      (navL_char_correct atomMap h_surj M χ v).mpr hχ⟩

/-! ## The nested-Since arrangement chain (Lemma 7.10 shape) -/

/-- Nested-Since arrangement chain: one Since step per listed profile (listed from the
    TOP slot nearest `x` downward), each guarded by the exclusion segment, anchored at
    the w-point package. The `buildLeft` technique of Translation.lean with the
    w-package in place of the `H`-closure base. -/
noncomputable def navLChain (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) → Formula
  | [] => Formula.snce (navLAtWPack atomMap h_surj σ) (navLSegGuard atomMap h_surj σ)
  | χ :: rest => Formula.snce
      (Formula.and (nf_depth0_char_formula atomMap h_surj χ) (navLChain σ rest))
      (navLSegGuard atomMap h_surj σ)

/-- **Chain soundness**: a chain at `u` yields the anchor `w < u` carrying the w-point
    package, one witness per listed profile inside `(w, u)`, and the exclusion segment
    (or a listed witness profile) at every interior point. -/
private theorem navL_chain_sound (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) :
    ∀ (L : List (NormalForm sig 0 1)) (u : M.carrier),
      temporal_truth M atomMap u (navLChain atomMap h_surj σ L) →
      ∃ w : M.carrier, w < u ∧
        temporal_truth M atomMap w (navLAtWPack atomMap h_surj σ) ∧
        (∀ χ ∈ L, ∃ v : M.carrier, w < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
        (∀ v : M.carrier, w < v → v < u →
          temporal_truth M atomMap v (navLSegGuard atomMap h_surj σ) ∨
            ∃ χ ∈ L, nf_eval_nf M 0 1 (fun _ => v) χ) := by
  intro L
  induction L with
  | nil =>
    intro u h
    simp only [navLChain, temporal_truth] at h
    obtain ⟨s, hsu, hpack, hguard⟩ := h
    exact ⟨s, hsu, hpack, fun χ hχ => absurd hχ List.not_mem_nil,
      fun v hsv hvu => Or.inl (hguard v hsv hvu)⟩
  | cons χ1 rest ih =>
    intro u h
    simp only [navLChain, temporal_truth] at h
    obtain ⟨s, hsu, hand, hguard⟩ := h
    rw [temporal_truth_and] at hand
    obtain ⟨hχ1s, hrest⟩ := hand
    obtain ⟨w, hws, hpack, hwit, hseg⟩ := ih s hrest
    refine ⟨w, hws.trans hsu, hpack, ?_, ?_⟩
    · intro χ hχmem
      rcases List.mem_cons.mp hχmem with rfl | hmem
      · exact ⟨s, hws, hsu, (navL_char_correct atomMap h_surj M χ s).mp hχ1s⟩
      · obtain ⟨v, hwv, hvs, hv⟩ := hwit χ hmem
        exact ⟨v, hwv, hvs.trans hsu, hv⟩
    · intro v hwv hvu
      rcases lt_trichotomy v s with hvs | rfl | hsv
      · rcases hseg v hwv hvs with hg | ⟨χ, hm, hv⟩
        · exact Or.inl hg
        · exact Or.inr ⟨χ, List.mem_cons_of_mem _ hm, hv⟩
      · exact Or.inr ⟨χ1, List.mem_cons_self ..,
          (navL_char_correct atomMap h_surj M χ1 v).mp hχ1s⟩
      · exact Or.inl (hguard v hsv hvu)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Maximum extraction over a nonempty list (the witness-threading key). -/
private theorem navL_listMax {α : Type} (M : OrderedMonadicStructure sig)
    (f : α → M.carrier) :
    ∀ l : List α, l ≠ [] → ∃ a ∈ l, ∀ b ∈ l, f b ≤ f a := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons x tl ih =>
    intro _
    by_cases htl : tl = []
    · subst htl
      exact ⟨x, List.mem_cons_self .., fun b hb => by
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact absurd h List.not_mem_nil⟩
    · obtain ⟨m, hm, hmax⟩ := ih htl
      rcases le_total (f x) (f m) with hle | hle
      · refine ⟨m, List.mem_cons_of_mem _ hm, fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact hle
        · exact hmax b h
      · refine ⟨x, List.mem_cons_self .., fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact (hmax b h).trans hle

/-- **Chain completeness**: given the w-point package at `w < u`, one witness per listed
    profile inside `(w, u)` (the list duplicate-free), and the exclusion segment at every
    interior point, SOME arrangement of the list has its chain holding at `u`. Witnesses
    are threaded descending by repeated maximum extraction; distinct listed profiles have
    distinct witnesses (`navL_profile_unique`), so the maxima strictly decrease. -/
private theorem navL_chain_complete (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w : M.carrier)
    (hpack : temporal_truth M atomMap w (navLAtWPack atomMap h_surj σ)) :
    ∀ (n : Nat) (T : List (NormalForm sig 0 1)), T.length = n → T.Nodup →
      ∀ u : M.carrier, w < u →
      (∀ χ ∈ T, ∃ v : M.carrier, w < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) →
      (∀ v : M.carrier, w < v → v < u →
        temporal_truth M atomMap v (navLSegGuard atomMap h_surj σ)) →
      ∃ L ∈ T.permutations, temporal_truth M atomMap u (navLChain atomMap h_surj σ L) := by
  intro n
  induction n with
  | zero =>
    intro T hlen hnd u hwu hwit hguard
    have hT : T = [] := List.eq_nil_of_length_eq_zero hlen
    subst hT
    refine ⟨[], List.mem_permutations.mpr (List.Perm.refl []), ?_⟩
    simp only [navLChain, temporal_truth]
    exact ⟨w, hwu, hpack, fun r hwr hru => hguard r hwr hru⟩
  | succ n ih =>
    intro T hlen hnd u hwu hwit hguard
    have hTne : T ≠ [] := by
      intro h; subst h; simp at hlen
    -- Choose one witness per profile, then extract the profile with the MAXIMAL witness.
    have hattne : T.attach ≠ [] := by
      intro h
      have := congrArg List.length h
      rw [List.length_attach] at this
      exact hTne (List.eq_nil_of_length_eq_zero this)
    obtain ⟨⟨χ1, hχ1T⟩, -, hmax⟩ :=
      navL_listMax M (fun s : {χ // χ ∈ T} => (hwit s.1 s.2).choose) T.attach hattne
    obtain ⟨hwv1, hv1u, hχ1v1⟩ := (hwit χ1 hχ1T).choose_spec
    set v1 := (hwit χ1 hχ1T).choose with hv1def
    -- Recurse on the erased list below the maximal witness.
    have hrestlen : (T.erase χ1).length = n := by
      rw [List.length_erase_of_mem hχ1T, hlen]
      omega
    have hrestnd : (T.erase χ1).Nodup := hnd.erase χ1
    have hrestwit : ∀ χ ∈ T.erase χ1,
        ∃ v : M.carrier, w < v ∧ v < v1 ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
      intro χ hχrest
      obtain ⟨hne, hχT⟩ := (List.Nodup.mem_erase_iff hnd).mp hχrest
      obtain ⟨hwv, hvu, hχv⟩ := (hwit χ hχT).choose_spec
      have hle : (hwit χ hχT).choose ≤ v1 :=
        hmax ⟨χ, hχT⟩ (List.mem_attach T ⟨χ, hχT⟩)
      have hvne : (hwit χ hχT).choose ≠ v1 := by
        intro he
        rw [he] at hχv
        exact hne (navL_profile_unique M v1 χ χ1 hχv hχ1v1)
      exact ⟨(hwit χ hχT).choose, hwv, lt_of_le_of_ne hle hvne, hχv⟩
    have hrestguard : ∀ v : M.carrier, w < v → v < v1 →
        temporal_truth M atomMap v (navLSegGuard atomMap h_surj σ) :=
      fun v hwv hv => hguard v hwv (hv.trans hv1u)
    obtain ⟨L', hL'mem, hL'chain⟩ :=
      ih (T.erase χ1) hrestlen hrestnd v1 hwv1 hrestwit hrestguard
    refine ⟨χ1 :: L', ?_, ?_⟩
    · -- (χ1 :: L') is a permutation of T.
      have h1 : L'.Perm (T.erase χ1) := List.mem_permutations.mp hL'mem
      have h2 : T.Perm (χ1 :: T.erase χ1) := List.perm_cons_erase hχ1T
      exact List.mem_permutations.mpr ((List.Perm.cons χ1 h1).trans h2.symm)
    · -- The chain holds at u with top witness v1.
      simp only [navLChain, temporal_truth]
      refine ⟨v1, hv1u, ?_, fun r hv1r hru => hguard r (hwv1.trans hv1r) hru⟩
      rw [temporal_truth_and]
      exact ⟨(navL_char_correct atomMap h_surj M χ1 v1).mpr hχ1v1, hL'chain⟩

/-! ## The E2 deliverable: `navPackLeft` + the fold iff -/

/-- **`navPackLeft`** (E2, Lemma 7.10 / Prop 3.5): the Since-navigated w-package — the
    disjunction, over all arrangements of the bit-TRUE `w < v < x` fiber profiles, of the
    nested-Since chain anchored at the w-point package and guarded by the exclusion
    segment. A single one-free-variable temporal predicate evaluated at the pin `x`. -/
noncomputable def navPackLeft (σ : NormalForm sig 1 3) : TemporalPred :=
  ⟨formula_disjList
    ((navLBitTrueList σ).permutations.map (navLChain atomMap h_surj σ))⟩

/-- **The E2 fold iff** (`navPackLeft` correctness): the Since-navigated w-package at the
    pin `x` is exactly the `∃ w < x` fold of the four w-DEPENDENT clause groups of
    `extZoneFiber_k1` — atoms at `w` (position-0 predicate layer), the `v = w` fiber
    biconditionals, the `v < w` fiber biconditionals, and the `w < v < x` fiber
    biconditionals — each stated verbatim in the Phase-13 kit shape. No ambient
    hypothesis is needed: the fold itself introduces the exterior witness `w`. -/
theorem navPackLeft_correct (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x : M.carrier) :
    (navPackLeft atomMap h_surj σ).eval_at M atomMap x ↔
      ∃ w : M.carrier, w < x ∧
        ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => w) χ ↔
             σ.2 (nf0_assemble extZAtW χ σ.1) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZBelowW χ σ.1) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, w < v ∧ v < x ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZIntWX χ σ.1) = true)) := by
  simp only [navPackLeft, TemporalPred.eval_at]
  rw [formula_disjList_iff]
  constructor
  · -- Soundness: some arrangement's chain at x yields the ∃w package.
    rintro ⟨φ, hmem, hφ⟩
    obtain ⟨L, hLperm, rfl⟩ := List.mem_map.mp hmem
    have hperm : L.Perm (navLBitTrueList σ) := List.mem_permutations.mp hLperm
    obtain ⟨w, hwx, hpack, hwit, hseg⟩ := navL_chain_sound atomMap h_surj M σ L x hφ
    obtain ⟨ha, hc, hb⟩ := (navL_atWPack_iff atomMap h_surj M σ w).mp hpack
    refine ⟨w, hwx, ha, hc, hb, ?_⟩
    intro χ
    constructor
    · rintro ⟨v, hwv, hvx, hχv⟩
      rcases hseg v hwv hvx with hg | ⟨χ', hχ'L, hχ'v⟩
      · obtain ⟨χ'', hbit'', hχ''v⟩ := (navL_segGuard_iff atomMap h_surj M σ v).mp hg
        rwa [navL_profile_unique M v χ χ'' hχv hχ''v]
      · rw [navL_profile_unique M v χ χ' hχv hχ'v]
        exact (navL_bitTrueList_mem σ χ').mp (hperm.mem_iff.mp hχ'L)
    · intro hbit
      have hχL : χ ∈ L := hperm.mem_iff.mpr ((navL_bitTrueList_mem σ χ).mpr hbit)
      exact hwit χ hχL
  · -- Completeness: the ∃w package realizes some arrangement's chain at x.
    rintro ⟨w, hwx, ha, hc, hb, hd⟩
    have hpack : temporal_truth M atomMap w (navLAtWPack atomMap h_surj σ) :=
      (navL_atWPack_iff atomMap h_surj M σ w).mpr ⟨ha, hc, hb⟩
    have hwit : ∀ χ ∈ navLBitTrueList σ,
        ∃ v : M.carrier, w < v ∧ v < x ∧ nf_eval_nf M 0 1 (fun _ => v) χ :=
      fun χ hχ => (hd χ).mpr ((navL_bitTrueList_mem σ χ).mp hχ)
    have hguard : ∀ v : M.carrier, w < v → v < x →
        temporal_truth M atomMap v (navLSegGuard atomMap h_surj σ) := by
      intro v hwv hvx
      obtain ⟨χv, hχv⟩ := navL_profile_exists M v
      exact (navL_segGuard_iff atomMap h_surj M σ v).mpr
        ⟨χv, (hd χv).mp ⟨v, hwv, hvx, hχv⟩, hχv⟩
    obtain ⟨L, hLmem, hLchain⟩ := navL_chain_complete atomMap h_surj M σ w hpack
      (navLBitTrueList σ).length (navLBitTrueList σ) rfl
      (navL_bitTrueList_nodup σ) x hwx hwit hguard
    exact ⟨navLChain atomMap h_surj σ L, List.mem_map.mpr ⟨L, hLmem, rfl⟩, hLchain⟩

/-! ## Phase 14b (E3): w-independent distribution `navDistribLeft`

Distributes the w-INDEPENDENT parts of the past-exterior channel `w < x < t` out of the
`∃w` (Rabinovich Lemma 7.6 gluing decomposition):

- zone `v = x` (+ atoms at `x`, position-1 layer) → the `endpointLeft` conjunct
  `navDAtXPack`, read AT the pin `x`;
- zone `x < v < t` fibers → the `(x, t)` bracket arrangement slots `navDXTBracket`
  (one witness slot per bit-TRUE profile, per arrangement) + the exclusion segment
  `navDXTSegGuard` on every gap;
- zones `v = t`, `t < v` and the atoms at `t` (position-2 layer) → the `endpointRight`
  conjunct `navDAtTPack`, read AT the pin `t` (future fibers as native Until-lits
  `U(charF χ, ⊤)`, the future dual of `navLPastLit`);
- the order-channel row bits → the pure σ-condition `navDOrderRow` (constant across all
  `w < x` given the ambient `x < t`, hence w-independent);
- inconsistent-zone falsity and off-fiber honesty → pure σ-conditions, verbatim.

This peeling avoids both refutations: no monadic re-fibering of joint depth-1 content
(F1), and no single predicate carrying t-reads (world-locality) — each read stays at its
own pin (`navPackLeft`/`navDAtXPack` at `x`, `navDAtTPack` at `t`, arrangement witnesses
strictly inside `(x, t)`). -/

/-- Position-1 predicate projection of the arity-3 atom row: the monadic profile that the
    row prescribes AT the pin `x`. -/
def navDProjX (row : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => row (.pred p ⟨1, by omega⟩)
  | .order _ _ _ => false

/-- Position-2 predicate projection of the arity-3 atom row: the monadic profile that the
    row prescribes AT the pin `t`. -/
def navDProjT (row : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => row (.pred p ⟨2, by omega⟩)
  | .order _ _ _ => false

/-- Native future Until-lit: `U(charF χ, ⊤)` — "some strict-future point realizes `χ`".
    The future dual of `navLPastLit`. -/
noncomputable def navDFutLit (χ : NormalForm sig 0 1) : Formula :=
  Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top

omit [DecidableEq sig.preds] in
/-- Reading of the future Until-lit. -/
private theorem navD_futLit_iff (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (navDFutLit atomMap h_surj χ) ↔
      ∃ v : M.carrier, u < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navDFutLit, temporal_truth]
  constructor
  · rintro ⟨s, hus, hφ, -⟩
    exact ⟨s, hus, (navL_char_correct atomMap h_surj M χ s).mp hφ⟩
  · rintro ⟨v, huv, hχ⟩
    exact ⟨v, huv, (navL_char_correct atomMap h_surj M χ v).mpr hχ,
      fun r _ _ => temporal_truth_top M atomMap r⟩

/-! ### The x-endpoint conjunct (`endpointLeft` slot content) -/

/-- **The x-endpoint conjunct**: atoms at `x` (position-1 projection characteristic) and
    the `v = x` fiber group (characteristic literals). The w-independent conjunct that
    Phase 14c attaches to `navPackLeft` inside `endpointLeft`. -/
noncomputable def navDAtXPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navDProjX σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extZAtX χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg)]

/-- Reading of the x-endpoint conjunct: exactly the two x-anchored w-independent clause
    groups of `extZoneFiber_k1` (atom layer restricted to position 1; zone `v = x`). -/
theorem navD_atXPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x : M.carrier) :
    temporal_truth M atomMap x (navDAtXPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p x ↔ σ.1 (.pred p ⟨1, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => x) χ ↔ σ.2 (nf0_assemble extZAtX χ σ.1) = true)) := by
  simp only [navDAtXPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap x Formula.top := temporal_truth_top M atomMap x
  constructor
  · rintro ⟨h1, h2, -⟩
    refine ⟨?_, ?_⟩
    · intro p
      exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjX σ.1) x).mp h1 p
    · exact (navL_bitGroup_iff atomMap M x _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ x)).mp h2
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjX σ.1) x).mpr h1
    · exact (navL_bitGroup_iff atomMap M x _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ x)).mpr h2

/-! ### The t-endpoint pack (`endpointRight` slot content) -/

/-- **The t-endpoint pack**: atoms at `t` (position-2 projection characteristic), the
    `v = t` fiber group (characteristic literals), and the `t < v` fiber group (native
    future Until-lits, negated on bit-false fibers). The `endpointRight` content of the
    Phase-14c carrier — every t-read lives HERE, at its own pin (world-locality). -/
noncomputable def navDAtTPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navDProjT σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extZAtT χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extZAboveT χ σ.1) = true
         then navDFutLit atomMap h_surj χ
         else (navDFutLit atomMap h_surj χ).neg)]

/-- Reading of the t-endpoint pack: exactly the three t-anchored clause groups of
    `extZoneFiber_k1` (atom layer restricted to position 2; `v = t`; `t < v`). -/
theorem navD_atTPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (t : M.carrier) :
    temporal_truth M atomMap t (navDAtTPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p t ↔ σ.1 (.pred p ⟨2, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => t) χ ↔ σ.2 (nf0_assemble extZAtT χ σ.1) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         (∃ v : M.carrier, t < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
           σ.2 (nf0_assemble extZAboveT χ σ.1) = true)) := by
  simp only [navDAtTPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap t Formula.top := temporal_truth_top M atomMap t
  constructor
  · rintro ⟨h1, h2, h3, -⟩
    refine ⟨?_, ?_, ?_⟩
    · intro p
      exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjT σ.1) t).mp h1 p
    · exact (navL_bitGroup_iff atomMap M t _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ t)).mp h2
    · exact (navL_bitGroup_iff atomMap M t _ _ _
        (fun χ => navD_futLit_iff atomMap h_surj M χ t)).mp h3
  · rintro ⟨h1, h2, h3⟩
    refine ⟨?_, ?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjT σ.1) t).mpr h1
    · exact (navL_bitGroup_iff atomMap M t _ _ _
        (fun χ => navL_char_correct atomMap h_surj M χ t)).mpr h2
    · exact (navL_bitGroup_iff atomMap M t _ _ _
        (fun χ => navD_futLit_iff atomMap h_surj M χ t)).mpr h3

/-! ### The `(x, t)` bracket arrangement slots + exclusion segment -/

/-- The bit-TRUE `x < v < t` fiber profiles of `σ` (the `(x, t)` arrangement-slot
    inventory). -/
noncomputable def navDXTBitTrueList (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) :=
  ((Finset.univ : Finset (NormalForm sig 0 1)).filter
    fun χ => σ.2 (nf0_assemble extZIntXT χ σ.1) = true).toList

private theorem navD_xtBitTrueList_mem (σ : NormalForm sig 1 3)
    (χ : NormalForm sig 0 1) :
    χ ∈ navDXTBitTrueList σ ↔ σ.2 (nf0_assemble extZIntXT χ σ.1) = true := by
  simp [navDXTBitTrueList, Finset.mem_toList, Finset.mem_filter]

private theorem navD_xtBitTrueList_nodup (σ : NormalForm sig 1 3) :
    (navDXTBitTrueList σ).Nodup :=
  Finset.nodup_toList _

/-- **The `(x, t)` exclusion segment**: the disjunction of the bit-TRUE characteristics.
    A gap all of whose points satisfy it excludes every bit-FALSE `x < v < t` profile
    (profiles are exhaustive and exclusive). -/
noncomputable def navDXTSegGuard (σ : NormalForm sig 1 3) : TemporalPred :=
  ⟨formula_disjList
    ((navDXTBitTrueList σ).map (nf_depth0_char_formula atomMap h_surj))⟩

/-- Reading of the `(x, t)` exclusion segment. -/
private theorem navD_xtSegGuard_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (v : M.carrier) :
    (navDXTSegGuard atomMap h_surj σ).eval_at M atomMap v ↔
      ∃ χ : NormalForm sig 0 1, σ.2 (nf0_assemble extZIntXT χ σ.1) = true ∧
        nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navDXTSegGuard, TemporalPred.eval_at]
  rw [formula_disjList_iff]
  constructor
  · rintro ⟨φ, hmem, hφ⟩
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hmem
    exact ⟨χ, (navD_xtBitTrueList_mem σ χ).mp hχmem,
      (navL_char_correct atomMap h_surj M χ v).mp hφ⟩
  · rintro ⟨χ, hbit, hχ⟩
    exact ⟨_, List.mem_map.mpr ⟨χ, (navD_xtBitTrueList_mem σ χ).mpr hbit, rfl⟩,
      (navL_char_correct atomMap h_surj M χ v).mpr hχ⟩

/-- **The `(x, t)` bracket arrangement**: one witness slot per listed profile — listed
    from the TOP slot nearest `t` downward (the `navLChain` convention) — with the
    exclusion segment on EVERY gap. Built by `BracketFormula.snoc` recursion so the slot
    count is the list length (the §5 bracket `[α_0, …, α_n](z_0, z_1)` shape that the
    Phase-14c `VecEA2` disjuncts carry). -/
noncomputable def navDXTBracket (σ : NormalForm sig 1 3) :
    (L : List (NormalForm sig 0 1)) → BracketFormula L.length
  | [] => BracketFormula.trivial (navDXTSegGuard atomMap h_surj σ)
  | χ :: rest => (navDXTBracket σ rest).snoc
      ⟨nf_depth0_char_formula atomMap h_surj χ⟩
      (navDXTSegGuard atomMap h_surj σ)

/-- **Arrangement soundness**: a held arrangement on `(x, u)` yields one witness per
    listed profile strictly inside `(x, u)`, and the exclusion segment (or a listed
    witness profile) at every interior point. -/
private theorem navD_bracket_sound (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) :
    ∀ (L : List (NormalForm sig 0 1)) (x u : M.carrier),
      (navDXTBracket atomMap h_surj σ L).holds M atomMap x u →
      (∀ χ ∈ L, ∃ v : M.carrier, x < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
      (∀ v : M.carrier, x < v → v < u →
        (navDXTSegGuard atomMap h_surj σ).eval_at M atomMap v ∨
          ∃ χ ∈ L, nf_eval_nf M 0 1 (fun _ => v) χ) := by
  intro L
  induction L with
  | nil =>
    intro x u h
    simp only [navDXTBracket] at h
    rw [BracketFormula.trivial_holds] at h
    exact ⟨fun χ hχ => absurd hχ List.not_mem_nil,
      fun v hxv hvu => Or.inl (h v hxv hvu)⟩
  | cons χ1 rest ih =>
    intro x u h
    simp only [navDXTBracket] at h
    rw [BracketFormula.snoc_holds_iff] at h
    obtain ⟨s, hxs, hsu, hfront, hpt, hseg⟩ := h
    obtain ⟨hwit, hcov⟩ := ih x s hfront
    refine ⟨?_, ?_⟩
    · intro χ hχmem
      rcases List.mem_cons.mp hχmem with rfl | hmem
      · exact ⟨s, hxs, hsu, (navL_char_correct atomMap h_surj M χ s).mp hpt⟩
      · obtain ⟨v, hxv, hvs, hv⟩ := hwit χ hmem
        exact ⟨v, hxv, hvs.trans hsu, hv⟩
    · intro v hxv hvu
      rcases lt_trichotomy v s with hvs | rfl | hsv
      · rcases hcov v hxv hvs with hg | ⟨χ, hm, hv⟩
        · exact Or.inl hg
        · exact Or.inr ⟨χ, List.mem_cons_of_mem _ hm, hv⟩
      · exact Or.inr ⟨χ1, List.mem_cons_self ..,
          (navL_char_correct atomMap h_surj M χ1 v).mp hpt⟩
      · exact Or.inl (hseg v hsv hvu)

/-- **Arrangement completeness**: given one witness per listed profile strictly inside
    `(x, u)` (the list duplicate-free) and the exclusion segment at every interior point,
    SOME arrangement of the list holds on `(x, u)`. Witnesses are threaded descending by
    repeated maximum extraction (`navL_listMax`); distinct listed profiles have distinct
    witnesses (`navL_profile_unique`), so the maxima strictly decrease. -/
private theorem navD_bracket_complete (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x : M.carrier) :
    ∀ (n : Nat) (T : List (NormalForm sig 0 1)), T.length = n → T.Nodup →
      ∀ u : M.carrier,
      (∀ χ ∈ T, ∃ v : M.carrier, x < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) →
      (∀ v : M.carrier, x < v → v < u →
        (navDXTSegGuard atomMap h_surj σ).eval_at M atomMap v) →
      ∃ L ∈ T.permutations,
        (navDXTBracket atomMap h_surj σ L).holds M atomMap x u := by
  intro n
  induction n with
  | zero =>
    intro T hlen hnd u hwit hguard
    have hT : T = [] := List.eq_nil_of_length_eq_zero hlen
    subst hT
    refine ⟨[], List.mem_permutations.mpr (List.Perm.refl []), ?_⟩
    simp only [navDXTBracket]
    rw [BracketFormula.trivial_holds]
    exact fun r hxr hru => hguard r hxr hru
  | succ n ih =>
    intro T hlen hnd u hwit hguard
    have hTne : T ≠ [] := by
      intro h; subst h; simp at hlen
    -- Choose one witness per profile, then extract the profile with the MAXIMAL witness.
    have hattne : T.attach ≠ [] := by
      intro h
      have := congrArg List.length h
      rw [List.length_attach] at this
      exact hTne (List.eq_nil_of_length_eq_zero this)
    obtain ⟨⟨χ1, hχ1T⟩, -, hmax⟩ :=
      navL_listMax M (fun s : {χ // χ ∈ T} => (hwit s.1 s.2).choose) T.attach hattne
    obtain ⟨hxv1, hv1u, hχ1v1⟩ := (hwit χ1 hχ1T).choose_spec
    set v1 := (hwit χ1 hχ1T).choose with hv1def
    -- Recurse on the erased list below the maximal witness.
    have hrestlen : (T.erase χ1).length = n := by
      rw [List.length_erase_of_mem hχ1T, hlen]
      omega
    have hrestnd : (T.erase χ1).Nodup := hnd.erase χ1
    have hrestwit : ∀ χ ∈ T.erase χ1,
        ∃ v : M.carrier, x < v ∧ v < v1 ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
      intro χ hχrest
      obtain ⟨hne, hχT⟩ := (List.Nodup.mem_erase_iff hnd).mp hχrest
      obtain ⟨hxv, hvu, hχv⟩ := (hwit χ hχT).choose_spec
      have hle : (hwit χ hχT).choose ≤ v1 :=
        hmax ⟨χ, hχT⟩ (List.mem_attach T ⟨χ, hχT⟩)
      have hvne : (hwit χ hχT).choose ≠ v1 := by
        intro he
        rw [he] at hχv
        exact hne (navL_profile_unique M v1 χ χ1 hχv hχ1v1)
      exact ⟨(hwit χ hχT).choose, hxv, lt_of_le_of_ne hle hvne, hχv⟩
    have hrestguard : ∀ v : M.carrier, x < v → v < v1 →
        (navDXTSegGuard atomMap h_surj σ).eval_at M atomMap v :=
      fun v hxv hv => hguard v hxv (hv.trans hv1u)
    obtain ⟨L', hL'mem, hL'holds⟩ :=
      ih (T.erase χ1) hrestlen hrestnd v1 hrestwit hrestguard
    refine ⟨χ1 :: L', ?_, ?_⟩
    · -- (χ1 :: L') is a permutation of T.
      have h1 : L'.Perm (T.erase χ1) := List.mem_permutations.mp hL'mem
      have h2 : T.Perm (χ1 :: T.erase χ1) := List.perm_cons_erase hχ1T
      exact List.mem_permutations.mpr ((List.Perm.cons χ1 h1).trans h2.symm)
    · -- The arrangement holds on (x, u) with top witness v1.
      simp only [navDXTBracket]
      rw [BracketFormula.snoc_holds_iff]
      exact ⟨v1, hxv1, hv1u, hL'holds,
        (navL_char_correct atomMap h_surj M χ1 v1).mpr hχ1v1,
        fun r hv1r hru => hguard r (hxv1.trans hv1r) hru⟩

/-- **The `(x, t)` interior fiber reading** (E3 bracket iff): some arrangement of the
    bit-TRUE `x < v < t` profiles holds on `(x, t)` iff every fiber biconditional of the
    `extZIntXT` zone reads correctly — stated verbatim in the `extZoneFiber_k1` clause
    shape. No ambient hypothesis is needed. -/
theorem navDXTBracket_arrangements_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) :
    (∃ L ∈ (navDXTBitTrueList σ).permutations,
        (navDXTBracket atomMap h_surj σ L).holds M atomMap x t) ↔
      ∀ χ : NormalForm sig 0 1,
        (∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
          σ.2 (nf0_assemble extZIntXT χ σ.1) = true := by
  constructor
  · rintro ⟨L, hLperm, hL⟩
    have hperm : L.Perm (navDXTBitTrueList σ) := List.mem_permutations.mp hLperm
    obtain ⟨hwit, hcov⟩ := navD_bracket_sound atomMap h_surj M σ L x t hL
    intro χ
    constructor
    · rintro ⟨v, hxv, hvt, hχv⟩
      rcases hcov v hxv hvt with hg | ⟨χ', hχ'L, hχ'v⟩
      · obtain ⟨χ'', hbit'', hχ''v⟩ := (navD_xtSegGuard_iff atomMap h_surj M σ v).mp hg
        rwa [navL_profile_unique M v χ χ'' hχv hχ''v]
      · rw [navL_profile_unique M v χ χ' hχv hχ'v]
        exact (navD_xtBitTrueList_mem σ χ').mp (hperm.mem_iff.mp hχ'L)
    · intro hbit
      exact hwit χ (hperm.mem_iff.mpr ((navD_xtBitTrueList_mem σ χ).mpr hbit))
  · intro hd
    have hwit : ∀ χ ∈ navDXTBitTrueList σ,
        ∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ :=
      fun χ hχ => (hd χ).mpr ((navD_xtBitTrueList_mem σ χ).mp hχ)
    have hguard : ∀ v : M.carrier, x < v → v < t →
        (navDXTSegGuard atomMap h_surj σ).eval_at M atomMap v := by
      intro v hxv hvt
      obtain ⟨χv, hχv⟩ := navL_profile_exists M v
      exact (navD_xtSegGuard_iff atomMap h_surj M σ v).mpr
        ⟨χv, (hd χv).mp ⟨v, hxv, hvt, hχv⟩, hχv⟩
    exact navD_bracket_complete atomMap h_surj M σ x
      (navDXTBitTrueList σ).length (navDXTBitTrueList σ) rfl
      (navD_xtBitTrueList_nodup σ) t hwit hguard

/-! ### The order-channel row and the atom-layer split -/

/-- **The w-independent order-channel row**: the six order bits of `σ.1` forced by the
    channel pattern `w < x < t`. Constant across ALL exterior witnesses `w < x` (given the
    ambient `x < t`), hence w-independent — a pure σ-condition that distributes out of the
    `∃w` as a Bool-side conjunct. -/
def navDOrderRow (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false

/-- A biconditional against a refuted proposition forces the bit false. -/
private theorem navD_atomBit_false {P : Prop} {b : Bool}
    (h : P ↔ b = true) (hnp : ¬P) : b = false := by
  cases b with
  | false => rfl
  | true => exact absurd (h.mpr rfl) hnp

/-- A refuted proposition is equivalent to a false bit's truth. -/
private theorem navD_atomBit_iff_false {P : Prop} {b : Bool}
    (hnp : ¬P) (hb : b = false) : P ↔ b = true := by
  subst hb
  exact iff_of_false hnp Bool.false_ne_true

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The atom-layer split**: under `w < x < t`, the arity-3 atom layer of
    `extZoneFiber_k1` splits into the three per-position predicate layers (at `w`, `x`,
    `t`) and the order-channel row. The position-0 layer is the ONLY w-dependent part;
    the row is constant across all `w < x` — this is the atom-level content of the E3
    distribution. -/
private theorem navD_atomLayer_iff (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwx : w < x) (hxt : x < t) (σ : NormalForm sig 1 3) :
    (∀ a : AtomKind sig 3,
        atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ σ.1 a = true) ↔
      ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
       (∀ p : sig.preds, M.interp p x ↔ σ.1 (.pred p ⟨1, by omega⟩) = true) ∧
       (∀ p : sig.preds, M.interp p t ↔ σ.1 (.pred p ⟨2, by omega⟩) = true) ∧
       navDOrderRow σ) := by
  constructor
  · intro h
    exact ⟨fun p => h (.pred p (0 : Fin 3)), fun p => h (.pred p (1 : Fin 3)),
      fun p => h (.pred p (2 : Fin 3)),
      (h _).mp hwx, (h _).mp (hwx.trans hxt), (h _).mp hxt,
      navD_atomBit_false (h _) (lt_asymm hwx),
      navD_atomBit_false (h _) (lt_asymm (hwx.trans hxt)),
      navD_atomBit_false (h _) (lt_asymm hxt)⟩
  · rintro ⟨h0, h1, h2, h01, h02, h12, h10, h20, h21⟩
    intro a
    match a with
    | .pred p i =>
      match i with
      | ⟨0, _⟩ => exact h0 p
      | ⟨1, _⟩ => exact h1 p
      | ⟨2, _⟩ => exact h2 p
    | .order i j hij =>
      match i, j with
      | ⟨0, _⟩, ⟨0, _⟩ => exact absurd rfl hij
      | ⟨0, _⟩, ⟨1, _⟩ => exact iff_of_true hwx h01
      | ⟨0, _⟩, ⟨2, _⟩ => exact iff_of_true (hwx.trans hxt) h02
      | ⟨1, _⟩, ⟨0, _⟩ => exact navD_atomBit_iff_false (lt_asymm hwx) h10
      | ⟨1, _⟩, ⟨1, _⟩ => exact absurd rfl hij
      | ⟨1, _⟩, ⟨2, _⟩ => exact iff_of_true hxt h12
      | ⟨2, _⟩, ⟨0, _⟩ => exact navD_atomBit_iff_false (lt_asymm (hwx.trans hxt)) h20
      | ⟨2, _⟩, ⟨1, _⟩ => exact navD_atomBit_iff_false (lt_asymm hxt) h21
      | ⟨2, _⟩, ⟨2, _⟩ => exact absurd rfl hij
      | ⟨_ + 3, hn⟩, _ => exact absurd hn (by omega)
      | _, ⟨_ + 3, hn⟩ => exact absurd hn (by omega)

/-! ### The E3 deliverable: `navDistribLeft` -/

/-- **The E3 distribution lemma `navDistribLeft`** (Rabinovich Lemma 7.6 gluing
    decomposition): under the ambient `x < t`, the `∃ w < x` past-exterior evaluation
    splits into the w-DEPENDENT package (exactly `navPackLeft`, by its fold iff) and the
    w-INDEPENDENT remainder, each part read at its own slot:

    - `navPackLeft` at the pin `x` (the ∃w fold — Phase 14a);
    - `navDAtXPack` at the pin `x` (atoms at `x`; zone `v = x`) — the `endpointLeft`
      conjunct;
    - the `(x, t)` bracket arrangement disjunction (zone `x < v < t`) — the bracket
      slots + exclusion segment;
    - `navDAtTPack` at the pin `t` (atoms at `t`; zones `v = t`, `t < v`) — the
      `endpointRight` content;
    - the order-channel row, inconsistent-zone falsity, and off-fiber honesty — pure
      σ-conditions.

    This is the peeling that avoids both refutations: the joint depth-1 content is
    never re-fibered monadically (F1), and no single predicate carries reads at more
    than one pin (world-locality). Phase 14c consumes this iff directly for the ∃w glue
    of `CExtPast_correct`. -/
theorem navDistribLeft (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (∃ w : M.carrier, w < x ∧
        nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) ↔
      ((navPackLeft atomMap h_surj σ).eval_at M atomMap x ∧
       temporal_truth M atomMap x (navDAtXPack atomMap h_surj σ) ∧
       (∃ L ∈ (navDXTBitTrueList σ).permutations,
         (navDXTBracket atomMap h_surj σ L).holds M atomMap x t) ∧
       temporal_truth M atomMap t (navDAtTPack atomMap h_surj σ) ∧
       navDOrderRow σ ∧
       (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
          ¬(zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
            zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT) →
          σ.2 (nf0_assemble zs χ σ.1) = false) ∧
       (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)) := by
  constructor
  · -- Distribution: peel the w-independent clause groups out of the ∃w.
    rintro ⟨w, hwx, hnf⟩
    obtain ⟨hatom, ⟨h1, h2, h3, h4, h5, h6, h7⟩, hbad, hoff⟩ :=
      (extZoneFiber_k1 M w x t hwx hxt σ).mp hnf
    obtain ⟨ha0, ha1, ha2, hrow⟩ := (navD_atomLayer_iff M w x t hwx hxt σ).mp hatom
    refine ⟨?_, ?_, ?_, ?_, hrow, hbad, hoff⟩
    · exact (navPackLeft_correct atomMap h_surj M σ x).mpr ⟨w, hwx, ha0, h2, h1, h3⟩
    · exact (navD_atXPack_iff atomMap h_surj M σ x).mpr ⟨ha1, h4⟩
    · exact (navDXTBracket_arrangements_iff atomMap h_surj M σ x t).mpr h5
    · exact (navD_atTPack_iff atomMap h_surj M σ t).mpr ⟨ha2, h6, h7⟩
  · -- Gluing: the ∃w of the navPackLeft fold carries the w-independent parts back in.
    rintro ⟨hpack, hX, hbr, hT, hrow, hbad, hoff⟩
    obtain ⟨w, hwx, ha0, hatW, hbelW, hintWX⟩ :=
      (navPackLeft_correct atomMap h_surj M σ x).mp hpack
    obtain ⟨ha1, hatX⟩ := (navD_atXPack_iff atomMap h_surj M σ x).mp hX
    obtain ⟨ha2, hatT, haboveT⟩ := (navD_atTPack_iff atomMap h_surj M σ t).mp hT
    have hintXT := (navDXTBracket_arrangements_iff atomMap h_surj M σ x t).mp hbr
    refine ⟨w, hwx, (extZoneFiber_k1 M w x t hwx hxt σ).mpr
      ⟨(navD_atomLayer_iff M w x t hwx hxt σ).mpr ⟨ha0, ha1, ha2, hrow⟩,
       ⟨hbelW, hatW, hintWX, hatX, hintXT, hatT, haboveT⟩, hbad, hoff⟩⟩

/-! ## Phase 14c (E4): the past-exterior carrier `CExtPast` + the ∃w pin glue

Assembles E1-E3 into the per-qnf past-exterior carrier (Rabinovich Lemma 7.6
`(∃z1)_{z0}^{z2}(ϕ1∧ϕ2)` closure for the ∃w glue at the pin `x`; Lemma 7.8(1)
TL(Since,K⁺)): one `VecEA2` disjunct per arrangement of the bit-TRUE `(x, t)` profiles,
with the shared endpoints

- `endpointLeft` = `navPackLeft ∧ navDAtXPack` at the pin `x` — the Since-navigated
  ∃w fold glued to the x-endpoint conjunct;
- `bracket` = the `(x, t)` arrangement slots + exclusion segment (`navDXTBracket`);
- `endpointRight` = `navDAtTPack` at the pin `t`;

gated on the three pure σ-side conditions of `navDistribLeft` (order-channel row,
inconsistent-zone falsity, off-fiber honesty) — the carrier is the EMPTY disjunction
off-gate, so its `holds` is `False` exactly when the σ-side data is order-channel
inconsistent (the arity-3 `agg2_zone_consistent_*` falsity form, 3-anchor instance). -/

/-- **The past-exterior gate**: the three pure σ-side conjuncts of `navDistribLeft` —
    the order-channel row `navDOrderRow`, inconsistent-zone falsity, and off-fiber
    honesty. A Prop on `σ` alone (no model data); the carrier `CExtPast` is the empty
    disjunction off-gate. -/
def navDGate (σ : NormalForm sig 1 3) : Prop :=
  navDOrderRow σ ∧
  (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      ¬(zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
        zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT) →
      σ.2 (nf0_assemble zs χ σ.1) = false) ∧
  (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)

/-- **The E4 past-exterior carrier `CExtPast`** (the `w < x` channel): one `VecEA2`
    disjunct per arrangement of the bit-TRUE `(x, t)` profiles — `endpointLeft` is the
    Since-navigated w-package `navPackLeft` (the ∃w fold across the pin `x`) conjoined
    with the x-endpoint conjunct `navDAtXPack`; the bracket carries the `(x, t)`
    arrangement slots + exclusion segment; `endpointRight` is the t-endpoint pack
    `navDAtTPack` (every t-read at its own pin — world-locality). Gated on `navDGate`
    (empty disjunction off-gate). -/
noncomputable def CExtPast (σ : NormalForm sig 1 3) : VVecEA2 :=
  @dite _ (navDGate σ) (Classical.dec _)
    (fun _ =>
      { disjuncts := (navDXTBitTrueList σ).permutations.map (fun L =>
          ⟨L.length,
           { endpointLeft := ⟨Formula.and (navPackLeft atomMap h_surj σ).formula
               (navDAtXPack atomMap h_surj σ)⟩
             endpointRight := ⟨navDAtTPack atomMap h_surj σ⟩
             bracket := navDXTBracket atomMap h_surj σ L }⟩) })
    (fun _ => { disjuncts := [] })

/-- **The E4 correctness iff `CExtPast_correct`** (the ∃w glue across the pin at `x`,
    Rabinovich Lemma 7.6): under the ambient `x < t`, the carrier's 2-pin semantics at
    `(x, t)` is exactly the `∃ w < x` past-exterior evaluation of `σ` at `[w, x, t]`.
    Pure plumbing against `navDistribLeft`: the shared endpoints distribute over the
    arrangement disjunction, and the three gate conjuncts are exactly the pure
    σ-conditions of the distribution RHS. -/
theorem CExtPast_correct (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (CExtPast atomMap h_surj σ).holds M atomMap x t ↔
      ∃ w : M.carrier, w < x ∧
        nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  rw [navDistribLeft atomMap h_surj M σ x t hxt]
  unfold CExtPast
  split
  case isTrue hg =>
    obtain ⟨hrow, hbad, hoff⟩ := hg
    constructor
    · rintro ⟨vea, hmem, hv⟩
      rw [List.mem_map] at hmem
      obtain ⟨L, hLperm, rfl⟩ := hmem
      obtain ⟨hepL, hepR, hbr⟩ := hv
      simp only [TemporalPred.eval_at] at hepL hepR
      rw [temporal_truth_and] at hepL
      exact ⟨hepL.1, hepL.2, ⟨L, hLperm, hbr⟩, hepR, hrow, hbad, hoff⟩
    · rintro ⟨hpack, hX, ⟨L, hLperm, hbr⟩, hT, -, -, -⟩
      have hepL : temporal_truth M atomMap x
          (Formula.and (navPackLeft atomMap h_surj σ).formula
            (navDAtXPack atomMap h_surj σ)) :=
        (temporal_truth_and M atomMap x _ _).mpr ⟨hpack, hX⟩
      exact ⟨_, List.mem_map.mpr ⟨L, hLperm, rfl⟩, hepL, hT, hbr⟩
  case isFalse hg =>
    constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · rintro ⟨-, -, -, -, hrow, hbad, hoff⟩
      exact absurd ⟨hrow, hbad, hoff⟩ hg

/-! ### 3-bot falsity for order-channel-inconsistent `σ` (arity-3
`agg2_zone_consistent_*` falsity form) -/

/-- **Eval-side 3-bot falsity**: if the order-channel row of `σ` does not match the
    channel pattern `w < x < t`, then NO exterior triple realizes `σ` — the atom layer
    of `extZoneFiber_k1` forces the row (arity-3 `agg2_zone_consistent_*` technique). -/
theorem navD_inconsistent_eval_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hrow : ¬ navDOrderRow σ)
    (w x t : M.carrier) (hwx : w < x) (hxt : x < t) :
    ¬ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  intro hnf
  obtain ⟨hatom, -, -, -⟩ := (extZoneFiber_k1 M w x t hwx hxt σ).mp hnf
  exact hrow ((navD_atomLayer_iff M w x t hwx hxt σ).mp hatom).2.2.2

/-- **Carrier-side 3-bot falsity (off-gate)**: off the gate the carrier is the empty
    disjunction, so its 2-pin semantics is `False` at EVERY pin pair — no ambient
    hypothesis needed. -/
theorem CExtPast_offGate_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hg : ¬ navDGate σ) (x t : M.carrier) :
    ¬ (CExtPast atomMap h_surj σ).holds M atomMap x t := by
  unfold CExtPast
  rw [dif_neg hg]
  rintro ⟨vea, hmem, -⟩
  exact List.not_mem_nil hmem

/-- **Carrier-side 3-bot falsity (order-channel-inconsistent `σ`)**: a `σ` whose
    order-channel row does not match `w < x < t` fails the gate, so the carrier's
    semantics is `False` everywhere — the two falsity readings agree with
    `CExtPast_correct` (both sides `False`). -/
theorem CExtPast_inconsistent_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hrow : ¬ navDOrderRow σ) (x t : M.carrier) :
    ¬ (CExtPast atomMap h_surj σ).holds M atomMap x t :=
  CExtPast_offGate_false atomMap h_surj M σ (fun hg => hrow hg.1) x t

end ExteriorNavPast

end Bimodal.Metalogic.WeakCanonical.Kamp
