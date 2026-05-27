import Bimodal.Metalogic.WeakCanonical.EFGames.CustomGame

/-!
# GHR93 Proposition 7: Strategy Composition for EF Games

## References
- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Proposition 7
- Task 155 plan: Phase 6A
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Pivot Transfer -/

/-- From (e < c ↔ e' < d) and (e = c ↔ e' = d), derive c < e ↔ d < e'. -/
private theorem pivot_flip {α β : Type*} [LinearOrder α] [LinearOrder β]
    {e : α} {e' : β} {c : α} {d : β}
    (hlt : e < c ↔ e' < d) (heq : e = c ↔ e' = d) :
    (c < e ↔ d < e') ∧ (c = e ↔ d = e') := by
  have aux1 : c < e → d < e' := by
    intro h
    rcases lt_trichotomy e' d with h' | h' | h'
    · exact absurd (hlt.mpr h') (not_lt.mpr (le_of_lt h))
    · exact absurd h (not_lt.mpr (le_of_eq (heq.mpr h')))
    · exact h'
  have aux2 : d < e' → c < e := by
    intro h
    rcases lt_trichotomy e c with h' | h' | h'
    · exact absurd (hlt.mp h') (not_lt.mpr (le_of_lt h))
    · exact absurd h (not_lt.mpr (le_of_eq (heq.mp h')))
    · exact h'
  exact ⟨⟨aux1, aux2⟩,
    ⟨fun h => (heq.mp h.symm).symm, fun h => (heq.mpr h.symm).symm⟩⟩

/-! ## Main Theorem -/

/-- **GHR93 Proposition 7**: Strategy composition for EF games. -/
theorem ghr93_strategy_compose {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (h_left : ghr93_duplicator_wins M N atomMap n r x c x' d)
    (h_right : ghr93_duplicator_wins M N atomMap n r c y d y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  intro a ha
  -- Pad selections
  let a_L := fun i => if a i ≤ c then a i else c
  let a_R := fun i => if a i ≤ c then c else a i
  have ha_L : ∀ i, inClosedInterval x c (a_L i) := by
    intro i; simp only [a_L]; split <;> [exact ⟨(ha i).1, ‹_›⟩; exact ⟨hxc, le_refl c⟩]
  have ha_R : ∀ i, inClosedInterval c y (a_R i) := by
    intro i; simp only [a_R]; split
    · exact ⟨le_refl c, hcy⟩
    · exact ⟨le_of_lt (lt_of_not_ge ‹_›), (ha i).2⟩
  -- Apply sub-strategies
  obtain ⟨a'_L, ha'_L, hwin_L⟩ := h_left a_L ha_L
  obtain ⟨a'_R, ha'_R, hwin_R⟩ := h_right a_R ha_R
  -- Merge
  let a' := fun i => if a i ≤ c then a'_L i else a'_R i
  have ha' : ∀ i, inClosedInterval x' y' (a' i) := by
    intro i; simp only [a']; split
    · exact ⟨(ha'_L i).1, le_trans (ha'_L i).2 hdy'⟩
    · exact ⟨le_trans hx'd (ha'_R i).1, (ha'_R i).2⟩
  refine ⟨a', ha', ?_⟩
  -- Round 2
  intro b' hb'
  -- Get BOTH sub-strategies' winning conditions
  rcases le_or_gt (extendPoint (sig := sig) (atomMap := atomMap) (r := r) b') d with hb'd | hdb'
  · -- b' ≤ d: left side
    obtain ⟨b, hb_L, hcond_L⟩ := hwin_L b' ⟨hb'.1, hb'd⟩
    -- Need right side winning condition. Find point in [d, y'].
    rcases Classical.em (∃ p : N.carrier,
        inClosedInterval d y' (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p))
      with ⟨p_R, hp_R⟩ | h_no_pt_R
    · obtain ⟨b_R, hb_R, hcond_R⟩ := hwin_R p_R hp_R
      have hL_eq : ∀ i, a i ≤ c → a_L i = a i := fun i h => by simp [a_L, h]
      have hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i := fun i h => by simp [a_R, h]
      refine ⟨b, ⟨hb_L.1, le_trans hb_L.2 hcy⟩, ?_⟩
      show ghr93_winning_condition n (game_tuple x y a b)
        (game_tuple x' y' a' b')
      exact compose_wc hb_L.2 hxc hcy hx'd hdy' hcd_type hcd_gp
        a a_L a_R a'_L a'_R ha_L ha_R ha'_L ha'_R hL_eq hR_eq hcond_L hcond_R
    · sorry -- degenerate case
  · -- d < b': right side
    obtain ⟨b, hb_R, hcond_R⟩ := hwin_R b' ⟨le_of_lt hdb', hb'.2⟩
    rcases Classical.em (∃ p : N.carrier,
        inClosedInterval x' d (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p))
      with ⟨p_L, hp_L⟩ | h_no_pt_L
    · obtain ⟨b_L, hb_L, hcond_L⟩ := hwin_L p_L hp_L
      have hL_eq : ∀ i, a i ≤ c → a_L i = a i := fun i h => by simp [a_L, h]
      have hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i := fun i h => by simp [a_R, h]
      refine ⟨b, ⟨le_trans hxc hb_R.1, hb_R.2⟩, ?_⟩
      show ghr93_winning_condition n (game_tuple x y a b)
        (game_tuple x' y' a' b')
      exact compose_wc_right hb_R.1 hxc hcy hx'd hdy' hcd_type hcd_gp
        a a_L a_R a'_L a'_R ha_L ha_R ha'_L ha'_R hL_eq hR_eq hcond_L hcond_R
    · sorry -- degenerate case
where
  /-- Winning condition when b comes from left strategy (b ≤ c). -/
  compose_wc
      {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat}
      {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
      {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
      {b b_R : M.carrier} {b' b'_R : N.carrier}
      (hb_le_c : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b ≤ c)
      (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
      (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A))
      (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
      (a a_L a_R : Fin n → ExtendedCarrier M atomMap r)
      (a'_L a'_R : Fin n → ExtendedCarrier N atomMap r)
      (ha_L : ∀ i, inClosedInterval x c (a_L i))
      (ha_R : ∀ i, inClosedInterval c y (a_R i))
      (ha'_L : ∀ i, inClosedInterval x' d (a'_L i))
      (ha'_R : ∀ i, inClosedInterval d y' (a'_R i))
      (hL_eq : ∀ i, a i ≤ c → a_L i = a i)
      (hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i)
      (hcond_L : ghr93_winning_condition n
        (game_tuple x c a_L b) (game_tuple x' d a'_L b'))
      (hcond_R : ghr93_winning_condition n
        (game_tuple c y a_R b_R) (game_tuple d y' a'_R b'_R)) :
      ghr93_winning_condition n
        (game_tuple x y a b)
        (game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b') := by
    sorry
  /-- Winning condition when b comes from right strategy (c ≤ b). -/
  compose_wc_right
      {sig : MonadicSignature}
      {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
      {n r : Nat}
      {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
      {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
      {b b_L : M.carrier} {b' b'_L : N.carrier}
      (hbR_ge_c : c ≤ extendPoint (sig := sig) (atomMap := atomMap) (r := r) b)
      (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
      (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r c A ↔
         stavi_temporal_truth_mu N atomMap r d A))
      (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
      (a a_L a_R : Fin n → ExtendedCarrier M atomMap r)
      (a'_L a'_R : Fin n → ExtendedCarrier N atomMap r)
      (ha_L : ∀ i, inClosedInterval x c (a_L i))
      (ha_R : ∀ i, inClosedInterval c y (a_R i))
      (ha'_L : ∀ i, inClosedInterval x' d (a'_L i))
      (ha'_R : ∀ i, inClosedInterval d y' (a'_R i))
      (hL_eq : ∀ i, a i ≤ c → a_L i = a i)
      (hR_eq : ∀ i, ¬(a i ≤ c) → a_R i = a i)
      (hcond_L : ghr93_winning_condition n
        (game_tuple x c a_L b_L) (game_tuple x' d a'_L b'_L))
      (hcond_R : ghr93_winning_condition n
        (game_tuple c y a_R b) (game_tuple d y' a'_R b')) :
      ghr93_winning_condition n
        (game_tuple x y a b)
        (game_tuple x' y' (fun i => if a i ≤ c then a'_L i else a'_R i) b') := by
    sorry

end Bimodal.Metalogic.WeakCanonical
