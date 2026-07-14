import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberKitK1
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation

/-! # Since-navigated w-package `navPackLeft` (task 350 Phase 14a / E2)

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
| atoms at `w` | `nf_depth0_char_formula` on the position-0 projection | (same conjunction, literal polarity) |
| zone `v = w` | characteristic conjunct `charF χ` at the Since-witness | negated characteristic `(charF χ).neg` |
| zone `v < w` | native Since-lit `S(charF χ, ⊤)` at the witness | negated Since-lit `(S(charF χ, ⊤)).neg` |
| zone `w < v < x` | arrangement slot inside the fold (nested-Since chain `navLChain`, one disjunct per permutation of the bit-true profile list) | exclusion segment `navLSegGuard` (segment guard = disjunction of bit-TRUE characteristics; every interior point's unique profile is forced bit-true) |

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
- specs/350_…/plans/03_negfix-refactor-exterior-carriers.md, Phase 14a (E2).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

section ExteriorNavPast

variable {sig : MonadicSignature}
variable (atomMap : Formula → sig.preds)
variable (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

/-! ## Local profile helpers (the ExteriorNegation.lean private idiom, re-derived) -/

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

/-- Every point realizes its depth-0 monadic characteristic. -/
private theorem navL_profile_exists (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

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

end ExteriorNavPast

end Bimodal.Metalogic.WeakCanonical.Kamp
