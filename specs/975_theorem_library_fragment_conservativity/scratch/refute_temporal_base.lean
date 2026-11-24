import BimodalLib.Conservativity
import FormalSystem.ProofSystem.DerivedAxioms
import Mathlib.Data.Sum.Order
import Mathlib.Algebra.Order.Field.Rat
import Mathlib.Tactic

open FormalSystem.Syntax FormalSystem.ProofSystem BimodalLib

namespace Scratch

/-- Truth on a strict order, `□` read as the identity (never met inside the temporal cell). -/
def LTruth {T : Type} (lt : T → T → Prop) (v : T → Atom → Prop) : Formula → T → Prop
  | .atom a, t => v t a
  | .bot, _ => False
  | .imp φ ψ, t => LTruth lt v φ t → LTruth lt v ψ t
  | .box φ, t => LTruth lt v φ t
  | .untl g e, t => ∃ s, lt t s ∧ LTruth lt v e s ∧ ∀ r, lt t r → lt r s → LTruth lt v g r
  | .snce g e, t => ∃ s, lt s t ∧ LTruth lt v e s ∧ ∀ r, lt r t → lt s r → LTruth lt v g r

structure Lin {T : Type} (lt : T → T → Prop) : Prop where
  trans : ∀ {a b c}, lt a b → lt b c → lt a c
  tri : ∀ a b, lt a b ∨ a = b ∨ lt b a
  noMax : ∀ a, ∃ b, lt a b
  noMin : ∀ a, ∃ b, lt b a

theorem Lin.flip {T : Type} {lt : T → T → Prop} (L : Lin lt) : Lin (fun a b => lt b a) where
  trans := fun h1 h2 => L.trans h2 h1
  tri := fun a b => by rcases L.tri a b with h | h | h <;> tauto
  noMax := L.noMin
  noMin := L.noMax

variable {T : Type} {lt : T → T → Prop} {v : T → Atom → Prop}

theorem reflect_iff (φ : Formula) (t : T) :
    LTruth lt v φ.reflectTime t ↔ LTruth (fun a b => lt b a) v φ t := by
  induction φ generalizing t with
  | atom a => simp [Formula.reflectTime, LTruth]
  | bot => simp [Formula.reflectTime, LTruth]
  | imp φ ψ ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]
  | box φ ih => simp [Formula.reflectTime, LTruth, ih]
  | untl g e ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]
  | snce g e ih1 ih2 => simp [Formula.reflectTime, LTruth, ih1, ih2]

@[simp] theorem t_imp (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.imp ψ) t ↔ (LTruth lt v φ t → LTruth lt v ψ t) := Iff.rfl
@[simp] theorem t_bot (t : T) : LTruth lt v Formula.bot t ↔ False := Iff.rfl
@[simp] theorem t_neg (φ : Formula) (t : T) : LTruth lt v φ.neg t ↔ ¬ LTruth lt v φ t := Iff.rfl
@[simp] theorem t_top (t : T) : LTruth lt v Formula.top t ↔ True := by simp [Formula.top]
@[simp] theorem t_and (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.and ψ) t ↔ (LTruth lt v φ t ∧ LTruth lt v ψ t) := by
  simp only [Formula.and, t_neg, t_imp]; tauto
@[simp] theorem t_or (φ ψ : Formula) (t : T) :
    LTruth lt v (φ.or ψ) t ↔ (LTruth lt v φ t ∨ LTruth lt v ψ t) := by
  simp only [Formula.or, t_neg, t_imp]; tauto
theorem t_untl (g e : Formula) (t : T) : LTruth lt v (g.untl e) t ↔
    ∃ s, lt t s ∧ LTruth lt v e s ∧ ∀ r, lt t r → lt r s → LTruth lt v g r := Iff.rfl
@[simp] theorem t_F (φ : Formula) (t : T) :
    LTruth lt v φ.someFuture t ↔ ∃ s, lt t s ∧ LTruth lt v φ s := by
  simp [Formula.someFuture, t_untl]
@[simp] theorem t_G (φ : Formula) (t : T) :
    LTruth lt v φ.allFuture t ↔ ∀ s, lt t s → LTruth lt v φ s := by
  simp [Formula.allFuture]

/-- Soundness of the temporal cell at the base class over every serial linear order. -/
theorem cell_sound : ∀ {Γ : Context} {φ : Formula} (d : DerivationTree FrameClass.Base Γ φ),
    Γ = [] → within { temporal := true } d →
    ∀ (T : Type) (lt : T → T → Prop), Lin lt → ∀ (v : T → Atom → Prop) (t : T),
      LTruth lt v φ t := by
  intro Γ φ d
  induction d with
  | «axiom» Γ φ h hfc =>
    intro _ hw T lt L v t
    simp only [within] at hw
    cases h with
    | prop_k φ ψ χ => simp only [t_imp]; tauto
    | prop_s φ ψ => simp only [t_imp]; tauto
    | ex_falso φ => simp
    | peirce φ ψ => simp only [t_imp]; tauto
    | modal_t φ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | modal_5_collapse φ =>
      exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le, Formula.diamond, Formula.neg])
    | modal_k_dist φ ψ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | serial_future => simpa using L.noMax t
    | left_mono_until_G φ χ ψ =>
      simp only [t_imp, t_G, t_untl]
      rintro hG ⟨s, hs, he, hg⟩
      exact ⟨s, hs, he, fun r h1 h2 => hG r h1 (hg r h1 h2)⟩
    | right_mono_until φ ψ χ =>
      simp only [t_imp, t_G, t_untl]
      rintro hG ⟨s, hs, he, hg⟩
      exact ⟨s, hs, hG s hs he, hg⟩
    | enrichment_until φ ψ p =>
      simp only [t_imp, t_and, t_untl]
      rintro ⟨hp, s, hs, he, hg⟩
      exact ⟨s, hs, ⟨he, t, hs, hp, fun r h1 h2 => hg r h2 h1⟩, hg⟩
    | self_accum_until φ ψ =>
      simp only [t_imp, t_and, t_untl]
      rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, he, fun r h1 h2 => ⟨hg r h1 h2, s, h2, he,
        fun r' h1' h2' => hg r' (L.trans h1 h1') h2'⟩⟩
    | absorb_until φ ψ =>
      simp only [t_imp, t_and, t_untl]
      rintro ⟨s, hs, ⟨hφ, s', hs', he, hg'⟩, hg⟩
      refine ⟨s', L.trans hs hs', he, fun r h1 h2 => ?_⟩
      rcases L.tri r s with h | h | h
      · exact hg r h1 h
      · exact h ▸ hφ
      · exact hg' r h h2
    | linear_until φ ψ χ θ =>
      simp only [t_imp, t_and, t_or, t_untl]
      rintro ⟨⟨s, hs, he, hg⟩, s', hs', he', hg'⟩
      rcases L.tri s s' with h | h | h
      · exact Or.inr (Or.inl ⟨s, hs, ⟨he, hg' s hs h⟩,
          fun r h1 h2 => ⟨hg r h1 h2, hg' r h1 (L.trans h2 h)⟩⟩)
      · subst h
        exact Or.inl ⟨s, hs, ⟨he, he'⟩, fun r h1 h2 => ⟨hg r h1 h2, hg' r h1 h2⟩⟩
      · exact Or.inr (Or.inr ⟨s', hs', ⟨hg s' hs' h, he'⟩,
          fun r h1 h2 => ⟨hg r h1 (L.trans h2 h), hg' r h1 h2⟩⟩)
    | modal_future φ => exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | discrete_box_necessity =>
      exact absurd hw (by simp [profileF, Profile.join, LE.le, Profile.le])
    | prior_UZ φ => exact absurd hfc (by show ¬ (FrameClass.ZTime ≤ FrameClass.Base); decide)
    | dense_indicator => exact absurd hfc (by decide)
    | prior_U_gap φ => exact absurd hfc (by show ¬ (FrameClass.RTime ≤ FrameClass.Base); decide)
    | sep φ => exact absurd hfc (by show ¬ (FrameClass.RTime ≤ FrameClass.Base); decide)
  | assumption Γ φ h => intro hΓ; subst hΓ; cases h
  | modus_ponens Γ φ ψ d1 d2 ih1 ih2 =>
    intro hΓ hw T lt L v t
    simp only [within] at hw
    exact ih1 hΓ hw.2.1 T lt L v t (ih2 hΓ hw.2.2 T lt L v t)
  | necessitation φ d ih =>
    intro _ hw
    simp only [within, conclOf] at hw
    exact absurd hw.1 (by simp [profileF, LE.le, Profile.le])
  | temporal_necessitation φ d ih =>
    intro _ hw T lt L v t
    simp only [within] at hw
    simp only [t_G]
    exact fun s _ => ih rfl hw.2 T lt L v s
  | time_reflection φ d ih =>
    intro _ hw T lt L v t
    simp only [within] at hw
    exact (reflect_iff φ t).mpr (ih rfl hw.2 T _ L.flip v t)
  | weakening Γ Δ φ d h ih =>
    intro hΔ hw T lt L v t
    subst hΔ
    simp only [within] at hw
    exact ih (List.subset_nil.mp h) hw.2 T lt L v t

/-- `X⊤ → G X⊤`, a theorem of TM at the base class. -/
def NF : Formula := (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
  (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))

abbrev Z_Q := ℤ ⊕ₗ ℚ

theorem lin_ZQ : Lin (fun a b : Z_Q => a < b) where
  trans := lt_trans
  tri := fun a b => lt_trichotomy a b
  noMax := exists_gt
  noMin := exists_lt

theorem NF_fails : ¬ LTruth (fun a b : Z_Q => a < b) (fun _ _ => False) NF (toLex (Sum.inl 0)) := by
  intro h
  simp only [NF, t_imp, t_G, t_untl, t_bot] at h
  have h0 : ∃ s : Z_Q, toLex (Sum.inl 0) < s ∧
      LTruth (fun a b : Z_Q => a < b) (fun _ _ => False) (Formula.bot.imp Formula.bot) s ∧
      ∀ r : Z_Q, toLex (Sum.inl 0) < r → r < s → False := by
    refine ⟨toLex (Sum.inl 1), by simp [Sum.Lex.toLex_lt_toLex], by simp, ?_⟩
    intro r h1 h2
    obtain ⟨r, rfl⟩ := toLex.surjective r
    rcases r with n | q
    · simp [Sum.Lex.toLex_lt_toLex] at h1 h2; omega
    · simp [Sum.Lex.toLex_lt_toLex] at h2
  obtain ⟨s, hs, -, hgap⟩ := h h0 (toLex (Sum.inr 0)) (by simp [Sum.Lex.toLex_lt_toLex])
  obtain ⟨s, rfl⟩ := toLex.surjective s
  rcases s with n | q
  · simp [Sum.Lex.toLex_lt_toLex] at hs
  · have hq : (0 : ℚ) < q := by simpa [Sum.Lex.toLex_lt_toLex] using hs
    exact hgap (toLex (Sum.inr (q / 2))) (by simp [Sum.Lex.toLex_lt_toLex]; linarith)
      (by simp [Sum.Lex.toLex_lt_toLex]; linarith)

/-- The registered statement `temporalBooleanIntoTMBase` is false. -/
theorem temporalEdge_base_refuted : ¬ ConservativeEdge { temporal := true } FrameClass.Base := by
  intro h
  obtain ⟨d, hd⟩ := h NF (by decide) ⟨DerivedAxioms.discretePropagateFwd⟩
  exact NF_fails (cell_sound d rfl hd Z_Q _ lin_ZQ _ _)

end Scratch
#print axioms Scratch.temporalEdge_base_refuted
