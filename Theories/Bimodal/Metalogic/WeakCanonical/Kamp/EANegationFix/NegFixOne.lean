import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFixAnchored
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.ConcatPin

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! # Lemma 5.1 fixed-formula negation: the n = 1 gated instance


Rabinovich's Lemma 5.1 (chunk_0016) outputs `∨_i (Cond_i ∧ Form_i)` — the case
gates ride IN the disjuncts. For the one-witness bracket `[s0, p, s1]` on
attained structures the gate-complete disjunct list is `{A, B1, B2, B3, B4,
B4′}`:

- `A  = [¬p]` — `p` never occurs in `(z0, z1)`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — `s0` fails strictly before the first `p`-point;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — `s1` fails strictly after the last `p`-point;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — a `¬s0`-point strictly before a `¬s1`-point;
- `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` — the last `¬s1`-point, a `¬p`
  corridor, then the first `¬s0`-point;
- `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` — the coincidence case of `B4`.

Each disjunct individually implies `¬[s0, p, s1]` (no attainment needed); the
cover direction pins the first `¬s0`-point and the last `¬s1`-point via
`HasAttainedINF`/`HasAttainedSUP`. The ℤ counterexample below (`NegFixGateProbe`)
machine-checks that the two-point gated shapes `B4`/`B4′` are unavoidable. -/

/-- The one-witness bracket `[s0, p, s1]`. -/
def bracketOne (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend s0 p (BracketFormula.trivial s1)

/-- Unfolded semantics of `[s0, p, s1]`. -/
theorem bracketOne_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) :
    (bracketOne s0 p s1).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x ∧
      (∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y) ∧
      (∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y) := by
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
    rw [BracketFormula.trivial_holds] at h5
    exact ⟨r, h1, h2, h3, h4, h5⟩
  · rintro ⟨x, h1, h2, h3, h4, h5⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ _ _ x h1 h2 h3 h4
      ((BracketFormula.trivial_holds M atomMap s1 x z1).mpr h5)

/-- Disjunct `A = [¬p]`. -/
def negFix1A (p : TemporalPred) : BracketFormula 0 :=
  BracketFormula.trivial p.neg

/-- Disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B1 (s0 p : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def negFix1B2 (p s1 : TemporalPred) : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1.neg).conj p.neg) p.neg

/-- Disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def negFix1B3 (s0 s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0.neg
    (BracketFormula.prepend TemporalPred.top s1.neg
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B4 (s0 p s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1.neg).conj p.neg)
    (BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]`. -/
def negFix1B4c (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend TemporalPred.top
    ((s0.neg).conj ((s1.neg).conj p.neg))
    (BracketFormula.trivial TemporalPred.top)

/-- The fixed n = 1 negation formula: the six-disjunct gate-complete list. -/
def negFixOne (s0 p s1 : TemporalPred) : VBracketFormula :=
  ⟨[⟨0, negFix1A p⟩, ⟨1, negFix1B1 s0 p⟩, ⟨1, negFix1B2 p s1⟩,
    ⟨2, negFix1B3 s0 s1⟩, ⟨2, negFix1B4 s0 p s1⟩, ⟨1, negFix1B4c s0 p s1⟩]⟩

/-! ## Backward lemmas: each gated disjunct refutes the bracket -/

private theorem negFix1A_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1A p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1A, BracketFormula.trivial_holds] at h
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, -⟩
  have hnp := h x hx0 hx1
  rw [TemporalPred.eval_at_neg'] at hnp
  exact hnp hxp

private theorem negFix1B1_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B1 s0 p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, hwseg, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, -⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · have hnp := hwseg x hx0 hlt
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp
  · exact hwpt.2 (heq ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 hgt)

private theorem negFix1B2_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B2 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1B2, BracketFormula.snoc_holds_iff] at h
  obtain ⟨w, hw0, hw1, -, hwpt, hwseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, hxs1⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · exact hwpt.1 (hxs1 w hlt hw1)
  · exact hwpt.2 (heq ▸ hxp)
  · have hnp := hwseg x hgt hx1
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp

private theorem negFix1B3_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B3 s0 s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w0, hw00, hw01, hw0pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w1, hw10, hw11, hw1pt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg'] at hw0pt hw1pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_or_ge w0 x with h1 | h1
  · exact hw0pt (hxs0 w0 hw00 h1)
  · rcases lt_or_ge x w1 with h2 | h2
    · exact hw1pt (hxs1 w1 h2 hw11)
    · exact absurd (lt_of_le_of_lt (le_trans h2 h1) hw10) (lt_irrefl w1)

private theorem negFix1B4_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4 s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w1, hw10, hw11, hw1pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w2, hw21, hw22, hw2pt, hcorr, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hw1pt hw2pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w1 with h1 | h1 | h1
  · exact hw1pt.1 (hxs1 w1 h1 hw11)
  · exact hw1pt.2 (h1 ▸ hxp)
  · rcases lt_trichotomy x w2 with h2 | h2 | h2
    · have hnp := hcorr x h1 h2
      rw [TemporalPred.eval_at_neg'] at hnp
      exact hnp hxp
    · exact hw2pt.2 (h2 ▸ hxp)
    · exact hw2pt.1 (hxs0 w2 (lt_trans hw10 hw21) h2)

private theorem negFix1B4c_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4c s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
    TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w with h1 | h1 | h1
  · exact hwpt.2.1 (hxs1 w h1 hw1)
  · exact hwpt.2.2 (h1 ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 h1)

/-! ## The n = 1 cover (consumes attained INF and SUP) -/

/-- **Cover** (Rabinovich Lemma 5.1, n = 1, gated): if `[s0, p, s1]` fails on
    `(z0, z1)`, one of the six gated disjuncts holds. The `B3/B4/B4′` cases pin
    the first `¬s0`-point and the last `¬s1`-point (attained INF/SUP). -/
theorem negFixOne_cover {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : ¬ (bracketOne s0 p s1).holds M atomMap z0 z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 := by
  rw [bracketOne_holds_iff] at h_neg
  by_cases hp_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x
  case neg =>
    -- Disjunct A
    push_neg at hp_occ
    refine ⟨⟨0, negFix1A p⟩, by simp [negFixOne], ?_⟩
    rw [negFix1A, BracketFormula.trivial_holds]
    intro y hy0 hy1
    rw [TemporalPred.eval_at_neg']
    exact hp_occ y hy0 hy1
  case pos =>
  obtain ⟨r0, hr00, hr01, hp_r0, hnb0⟩ := h_INF.first_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs0_pre : ∀ y : M.carrier, z0 < y → y < r0 → s0.eval_at M atomMap y
  case neg =>
    -- Disjunct B1: s0 fails strictly before the first p-point
    push_neg at hs0_pre
    obtain ⟨w, hw0, hw1, hws0⟩ := hs0_pre
    refine ⟨⟨1, negFix1B1 s0 p⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 w hw0
      (lt_trans hw1 hr01) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws0, hnb0 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hnb0 y hy0 (lt_trans hy1 hw1)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  case pos =>
  obtain ⟨rN, hrN0, hrN1, hp_rN, hna1⟩ := h_SUP.last_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs1_post : ∀ y : M.carrier, rN < y → y < z1 → s1.eval_at M atomMap y
  case neg =>
    -- Disjunct B2: s1 fails strictly after the last p-point
    push_neg at hs1_post
    obtain ⟨w, hw0, hw1, hws1⟩ := hs1_post
    refine ⟨⟨1, negFix1B2 p s1⟩, by simp [negFixOne], ?_⟩
    rw [negFix1B2, BracketFormula.snoc_holds_iff]
    refine ⟨w, lt_trans hrN0 hw0, hw1, ?_, ?_, ?_⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws1, hna1 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hna1 y (lt_trans hw0 hy0) hy1
  case pos =>
  -- Both boundary gates hold: pin the last ¬s1-point and the first ¬s0-point.
  have h1fail : ¬ ∀ y : M.carrier, r0 < y → y < z1 → s1.eval_at M atomMap y :=
    fun hpost => h_neg ⟨r0, hr00, hr01, hp_r0, hs0_pre, hpost⟩
  push_neg at h1fail
  obtain ⟨v1, hv10, hv11, hv1s1⟩ := h1fail
  have h0fail : ¬ ∀ y : M.carrier, z0 < y → y < rN → s0.eval_at M atomMap y :=
    fun hpre => h_neg ⟨rN, hrN0, hrN1, hp_rN, hpre, hs1_post⟩
  push_neg at h0fail
  obtain ⟨v0, hv00, hv01, hv0s0⟩ := h0fail
  obtain ⟨y1, hy10, hy11, hy1s1, hy1last⟩ :=
    h_SUP.last_occ_tp s1.neg z0 z1 h_lt
      ⟨v1, lt_trans hr00 hv10, hv11,
        (TemporalPred.eval_at_neg' M atomMap s1 v1).mpr hv1s1⟩
  obtain ⟨y0, hy00, hy01, hy0s0, hy0first⟩ :=
    h_INF.first_occ_tp s0.neg z0 z1 h_lt
      ⟨v0, hv00, lt_trans hv01 hrN1,
        (TemporalPred.eval_at_neg' M atomMap s0 v0).mpr hv0s0⟩
  -- s1 holds strictly after y1; s0 holds strictly before y0.
  have hs1_after : ∀ y : M.carrier, y1 < y → y < z1 → s1.eval_at M atomMap y := by
    intro y hy hyz
    have := hy1last y hy hyz
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  have hs0_before : ∀ y : M.carrier, z0 < y → y < y0 → s0.eval_at M atomMap y := by
    intro y hy hyy
    have := hy0first y hy hyy
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  rw [TemporalPred.eval_at_neg'] at hy1s1 hy0s0
  rcases lt_trichotomy y0 y1 with hlt | heq | hgt
  · -- Disjunct B3: the first ¬s0-point sits strictly before the last ¬s1-point
    refine ⟨⟨2, negFix1B3 s0 s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01
      ((TemporalPred.eval_at_neg' M atomMap s0 y0).mpr hy0s0)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    refine BracketFormula.prepend_holds M atomMap _ _ _ y0 z1 y1 hlt hy11
      ((TemporalPred.eval_at_neg' M atomMap s1 y1).mpr hy1s1)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4′: the pins coincide; the point is also a ¬p-point
    have hnp : ¬ p.eval_at M atomMap y0 := by
      intro hp_y0
      have hfail : ¬ ∀ y : M.carrier, y0 < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨y0, hy00, hy01, hp_y0, hs0_before, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwa, hwb, hws1⟩ := hfail
      exact hws1 (hs1_after w (heq ▸ hwa) hwb)
    refine ⟨⟨1, negFix1B4c s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
        TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy0s0, heq ▸ hy1s1, hnp⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4: last ¬s1-point, ¬p corridor, first ¬s0-point
    have hnp : ∀ x : M.carrier, y1 ≤ x → x ≤ y0 → ¬ p.eval_at M atomMap x := by
      intro x hx1 hx0 hpx
      have hx_in0 : z0 < x := lt_of_lt_of_le hy10 hx1
      have hx_in1 : x < z1 := lt_of_le_of_lt hx0 hy01
      have hpre : ∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y :=
        fun y hy0 hyx => hs0_before y hy0 (lt_of_lt_of_le hyx hx0)
      have hfail : ¬ ∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨x, hx_in0, hx_in1, hpx, hpre, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwx, hwz, hws1⟩ := hfail
      exact hws1 (hs1_after w (lt_of_le_of_lt hx1 hwx) hwz)
    refine ⟨⟨2, negFix1B4 s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y1 hy10 hy11 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy1s1, hnp y1 le_rfl (le_of_lt hgt)⟩
    · refine BracketFormula.prepend_holds M atomMap _ _ _ y1 z1 y0 hgt hy01 ?_ ?_ ?_
      · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
          TemporalPred.eval_at_neg']
        exact ⟨hy0s0, hnp y0 (le_of_lt hgt) le_rfl⟩
      · intro y hy0 hy1'
        rw [TemporalPred.eval_at_neg']
        exact hnp y (le_of_lt hy0) (le_of_lt hy1')
      · rw [BracketFormula.trivial_holds]
        intro y _ _
        exact TemporalPred.eval_at_top M atomMap y

/-- **Lemma 5.1, n = 1, fixed formula** (Rabinovich 2014, gated): on attained
    structures, `negFixOne s0 p s1` holds on `(z0, z1)` iff the bracket
    `[s0, p, s1]` fails on `(z0, z1)`. -/
theorem negFixOne_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 ↔
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  constructor
  · rintro ⟨d, hmem, hd⟩
    simp only [negFixOne, List.mem_cons, List.not_mem_nil, or_false] at hmem
    rcases hmem with rfl | rfl | rfl | rfl | rfl | rfl
    · exact negFix1A_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B1_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B2_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B3_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4c_backward M atomMap s0 p s1 z0 z1 hd
  · exact negFixOne_cover M atomMap h_INF h_SUP s0 p s1 z0 z1 h_lt

/-! # Lemma 5.1 fixed-formula negation: the gate probes

## R2 gate: the ℤ counterexample

Rabinovich's Lemma 5.1 output is `∨_i (Cond_i ∧ Form_i)` — the case gates RIDE
IN the disjuncts (chunk_0016 md:5). The report's Medium-High-confidence claim
(plan R2) is that the gates are load-bearing: a gate-free disjunct list cannot
be a biconditional cover. The following ℤ instance machine-checks this.

Take carrier ℤ, interval `(0, 10)`, and `bf = [s0, p, s1]` (one witness point
of type `p`, segment `s0` before it, `s1` after it) with
- `p` true exactly at `{2, 8}`,
- `¬s0` true exactly at `{7}` (i.e. `s0 = (· ≠ 7)`),
- `¬s1` true exactly at `{3}` (i.e. `s1 = (· ≠ 3)`).

Then `¬bf.holds 0 10` (witness 2 fails at `s1 3`; witness 8 fails at `s0 7`),
yet the four single-pin negation disjuncts all FAIL:
- `A = [¬p]` — refuted by `p 2`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — the only `¬s0` point is 7, but `p 2` breaks
  the `¬p` prefix;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — the only `¬s1` point is 3, but `p 8` breaks
  the `¬p` suffix;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — needs a `¬s0` point BEFORE a `¬s1` point,
  i.e. `7 < 3`.

Only the two-point gated disjunct
`B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` holds (witnesses 3 < 7): the
last-`¬s1` point, then a `¬p` corridor, then the first-`¬s0` point. Hence any
biconditional negation cover MUST contain the B4/B4′ gated shapes; the
Boneyard's 3-disjunct list (A/B1-prepend/B2-INF) is forward-only. -/

namespace NegFixGateProbe

/-- Three predicate symbols: `p`, `s0`, `s1`. -/
abbrev sigZ : MonadicSignature := { preds := Fin 3 }

/-- The ℤ structure of the counterexample: `p` exactly at `{2, 8}`, `¬s0`
    exactly at `{7}`, `¬s1` exactly at `{3}`. -/
abbrev MZ : OrderedMonadicStructure sigZ where
  carrier := ℤ
  interp k t :=
    match k with
    | ⟨0, _⟩ => t = 2 ∨ t = 8
    | ⟨1, _⟩ => t ≠ 7
    | ⟨2, _⟩ => t ≠ 3
  carrier_order := inferInstance

/-- Atom map: fresh atoms with indices 0, 1, 2 name the three predicates. -/
def atomMapZ : Formula → sigZ.preds
  | .atom ⟨_, some 1⟩ => 1
  | .atom ⟨_, some 2⟩ => 2
  | _ => 0

/-- The point predicate `p` (true exactly at `{2, 8}`). -/
def pZ : TemporalPred := ⟨.atom ⟨"", some 0⟩⟩

/-- The left segment predicate `s0` (false exactly at `7`). -/
def s0Z : TemporalPred := ⟨.atom ⟨"", some 1⟩⟩

/-- The right segment predicate `s1` (false exactly at `3`). -/
def s1Z : TemporalPred := ⟨.atom ⟨"", some 2⟩⟩

theorem pZ_eval (t : ℤ) : pZ.eval_at MZ atomMapZ t ↔ t = 2 ∨ t = 8 := Iff.rfl

theorem s0Z_eval (t : ℤ) : s0Z.eval_at MZ atomMapZ t ↔ t ≠ 7 := Iff.rfl

theorem s1Z_eval (t : ℤ) : s1Z.eval_at MZ atomMapZ t ↔ t ≠ 3 := Iff.rfl

/-- The bracket `[s0, p, s1]`: one interior `p`-point, `s0` before, `s1`
    after. -/
def bfZ : BracketFormula 1 :=
  BracketFormula.prepend s0Z pZ (BracketFormula.trivial s1Z)

/-- Gate-free disjunct `A = [¬p]`. -/
def caseA_Z : BracketFormula 0 := BracketFormula.trivial pZ.neg

/-- Gated disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB1_Z : BracketFormula 1 :=
  BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Gated disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def caseB2_Z : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1Z.neg).conj pZ.neg) pZ.neg

/-- Gate-free disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def caseB3_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0Z.neg
    (BracketFormula.prepend TemporalPred.top s1Z.neg
      (BracketFormula.trivial TemporalPred.top))

/-- The gated two-point disjunct
    `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB4_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1Z.neg).conj pZ.neg)
    (BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- The bracket `[s0, p, s1]` FAILS on `(0, 10)`: witness 2 is broken by
    `¬s1 3`, witness 8 by `¬s0 7`. -/
theorem bfZ_not_holds : ¬ bfZ.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hp, hseg, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [BracketFormula.trivial_holds] at htail
  rcases (pZ_eval r).mp hp with h2 | h8
  · have h3 := htail (3 : ℤ) (show (r : ℤ) < 3 by rw [h2]; decide) (by decide)
    rw [s1Z_eval] at h3
    exact h3 rfl
  · have h7 := hseg (7 : ℤ) (by decide) (show (7 : ℤ) < r by rw [h8]; decide)
    rw [s0Z_eval] at h7
    exact h7 rfl

/-- Disjunct `A` fails: `p 2`. -/
theorem caseA_not_holds : ¬ caseA_Z.holds MZ atomMapZ 0 10 := by
  rw [caseA_Z, BracketFormula.trivial_holds]
  intro h
  have h2 := h (2 : ℤ) (by decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B1` fails: the only `¬s0` point is 7, but `p 2` breaks the
    `¬p` prefix on `(0, 7)`. -/
theorem caseB1_not_holds : ¬ caseB1_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hpt, hseg, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s0Z_eval, pZ_eval] at hpt
  have hr7 : (r : ℤ) = 7 := not_not.mp hpt.1
  have h2 := hseg (2 : ℤ) (by decide) (show (2 : ℤ) < r by rw [hr7]; decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B2` fails: the only `¬s1` point is 3, but `p 8` breaks the
    `¬p` suffix on `(3, 10)`. -/
theorem caseB2_not_holds : ¬ caseB2_Z.holds MZ atomMapZ 0 10 := by
  intro h
  rw [caseB2_Z, BracketFormula.snoc_holds_iff] at h
  obtain ⟨x, hx0, hx1, -, hpt, hseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s1Z_eval, pZ_eval] at hpt
  have hx3 : (x : ℤ) = 3 := not_not.mp hpt.1
  have h8 := hseg (8 : ℤ) (show (x : ℤ) < 8 by rw [hx3]; decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h8
  exact h8 (Or.inr rfl)

/-- Disjunct `B3` fails: it needs a `¬s0` point strictly before a `¬s1`
    point, i.e. `7 < 3`. -/
theorem caseB3_not_holds : ¬ caseB3_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r1, hr10, hr11, hpt1, -, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  obtain ⟨r2, hr21, hr22, hpt2, -, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg', s0Z_eval] at hpt1
  rw [TemporalPred.eval_at_neg', s1Z_eval] at hpt2
  have h12 : (r1 : ℤ) < r2 := hr21
  rw [not_not.mp hpt1, not_not.mp hpt2] at h12
  exact absurd h12 (by decide)

/-- The gated two-point disjunct `B4` HOLDS with witnesses `3 < 7`: the
    last-`¬s1` point, a `¬p` corridor, the first-`¬s0` point. -/
theorem caseB4_holds : caseB4_Z.holds MZ atomMapZ 0 10 := by
  refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ 0 10 (3 : ℤ)
    (by decide) (by decide) ?_ ?_ ?_
  · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg', s1Z_eval, pZ_eval]
    exact ⟨fun hne => hne rfl, by omega⟩
  · intro y _ _
    exact TemporalPred.eval_at_top MZ atomMapZ y
  · refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ (3 : ℤ) 10 (7 : ℤ)
      (by decide) (by decide) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg', s0Z_eval, pZ_eval]
      exact ⟨fun hne => hne rfl, by omega⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg', pZ_eval]
      have h0 : (3 : ℤ) < y := hy0
      have h1 : (y : ℤ) < 7 := hy1
      rintro (h | h)
      · rw [h] at h0
        exact absurd h0 (by decide)
      · rw [h] at h1
        exact absurd h1 (by decide)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top MZ atomMapZ y

end NegFixGateProbe


end Bimodal.Metalogic.WeakCanonical.Kamp
