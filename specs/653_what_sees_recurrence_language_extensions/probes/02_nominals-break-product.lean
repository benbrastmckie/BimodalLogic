/-
Probe 02 — state registers and nominals against the translation product (Q2), and what they
still cannot see (determinism).

Research probe only (sorry-free, compiled with `lake env lean`); nothing here is proposed for
`FormalSystem/`. Names live in `Probe653`.

Contents:
* `recF_valid_product`, `transF_valid_product` — the product of ANY frame validates the
  recurrence and transposition formulas (it is recurrence-free).
* `recF_separates`, `transF_separates` — for a frame with recurrence, the product validates what
  the frame refutes: the naming breaks under the clock. Instantiated on the one-state frame.
* `reg_not_prodInvariant` — the exact point of failure: no register vector on the base makes the
  register clause invariant along the projection.
* `hybridValidOn_incomparable` — in the hybrid language, frame-level validity of a frame and of
  its product are incomparable (each validates a sentence the other refutes), whereas in L⁺ the
  product validates a subset (`plusValidOn_of_prod`).
* `hsatSet`, `hybridTruthAt_iff_mem_hsatSet`, `fzero_hybridValidOn_iff_f1`,
  `deterministic_not_hybridDefinable` — state registers, `[≡]` and the binder do NOT see
  determinism: the drift frame `F°` and the translation flow `F¹` validate exactly the same hybrid
  sentences. Only the time registers of L⋆ separate them (`star_discriminates_where_plus_cannot`).
-/

import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.HybridLanguage.HybridRecurrence
import FormalSystem.HybridLanguage.HybridTransposition
import FormalSystem.Metalogic.Independence.DeterminismUndefinable

namespace Probe653

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.HybridLanguage
open FormalSystem.HybridLanguage.HybridTruth
open FormalSystem.Metalogic.Independence

/-! ## Q2 — the product of a frame with nominals -/

section Product
variable {D : TemporalOrder} (F : FrameOver D)

/-- The product of any frame validates the recurrence formula, at every register. -/
theorem recF_valid_product (i : ℕ) :
    F.translationProduct.toTaskFrame.HybridValidOn (HybridFormula.recF i) :=
  (recF_defines _ i).2 (translationProduct_recurrenceFree F)

/-- The product of any frame validates the transposition formula (universal modality inside). -/
theorem transF_valid_product :
    F.translationProduct.toTaskFrame.HybridValidOn (HybridFormula.transF 0 1) :=
  (transF_defines _).2 (translationProduct_recurrenceFree F)

/-- **The naming breaks under the clock.** If `F` has a recurrence, its product validates the
recurrence formula and `F` refutes it: a state nominal on the product names a clocked state
`(w, e)`, which no history revisits. -/
theorem recF_separates (h : ¬ F.toTaskFrame.RecurrenceFree) (i : ℕ) :
    F.translationProduct.toTaskFrame.HybridValidOn (HybridFormula.recF i) ∧
      ¬ F.toTaskFrame.HybridValidOn (HybridFormula.recF i) :=
  ⟨recF_valid_product F i, fun hv => h ((recF_defines _ i).1 hv)⟩

/-- The same with the universal modality: the transposition formula. -/
theorem transF_separates (h : ¬ F.toTaskFrame.RecurrenceFree) :
    F.translationProduct.toTaskFrame.HybridValidOn (HybridFormula.transF 0 1) ∧
      ¬ F.toTaskFrame.HybridValidOn (HybridFormula.transF 0 1) :=
  ⟨transF_valid_product F, fun hv => h ((transF_defines _).1 hv)⟩

end Product

/-- The constant history of the one-state frame over a temporal order. -/
private def constHist {D : TemporalOrder} :
    WorldHistory (FrameOver.trivialFrame (D := ↑D)).toTaskFrame :=
  WorldHistory.ofTotal _ (fun _ => ()) fun _ _ => FrameOver.trivialFrame_taskRel.mpr trivial

/-- **Concrete separation on the one-state frame** over any temporal order: its product (the
translation frame on `D`) validates `¬(i ∧ (P i ∨ F i))`; the frame itself refutes it. -/
theorem recF_separates_trivial {D : TemporalOrder} :
    (FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame.HybridValidOn
        (HybridFormula.recF 0) ∧
      ¬ (FrameOver.trivialFrame (D := ↑D)).toTaskFrame.HybridValidOn (HybridFormula.recF 0) :=
  recF_separates _ trivialFrame_not_recurrenceFree 0

/-- **Exactly where invariance fails: the register clause.** On the one-state frame, with the
product register `r' 0 := ((), 0)`, the register formula `0` is true at the lifted constant
history at time `0` and false at any positive time, while the projected history is constant. No
register vector `r` on the base makes the clause invariant. -/
theorem reg_not_prodInvariant {D : TemporalOrder} :
    let F := FrameOver.trivialFrame (D := ↑D)
    let M : TaskModel F.toTaskFrame := ⟨fun _ _ => False⟩
    let τ' := liftH F constHist 0
    let r' : ℕ → F.translationProduct.WorldState := fun _ => ((), 0)
    ¬ ∃ r : ℕ → F.WorldState, ∀ t : ↑D,
      HybridTruthAt (liftModel F M) τ' t r' (HybridFormula.reg 0) ↔
        HybridTruthAt M (projH F τ') t r (HybridFormula.reg 0) := by
  intro F M τ' r'
  rintro ⟨r, h⟩
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  haveI : Subsingleton (FrameOver.trivialFrame (D := ↑D)).toTaskFrame.WorldState :=
    inferInstanceAs (Subsingleton Unit)
  -- on the base, `reg 0` holds at every time: the carrier is `Unit`
  have hbase : HybridTruthAt M (projH F τ') x r (HybridFormula.reg 0) := by
    rw [reg_iff]
    exact Subsingleton.elim _ _
  have hprod := (h x).2 hbase
  rw [reg_iff] at hprod
  -- `hprod : (liftH F constHist 0).state x = ((), 0)`; read off the clock
  have hclk : (0 : ↑D) + x = 0 := congrArg Prod.snd hprod
  rw [zero_add] at hclk
  exact hx.ne' hclk

/-- **Frame-level hybrid validity of a frame and of its product are incomparable.** The product
validates the recurrence formula, which the one-state frame refutes; the one-state frame
validates `p → Gp` (embedded from L⁺), which its product refutes. Contrast L⁺, where the product
validates a subset (`plusValidOn_of_prod`, `frame_validity_not_reflected`). -/
theorem hybridValidOn_incomparable {D : TemporalOrder} :
    ∃ φ ψ : HybridFormula,
      ((FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame.HybridValidOn φ ∧
        ¬ (FrameOver.trivialFrame (D := ↑D)).toTaskFrame.HybridValidOn φ) ∧
      ((FrameOver.trivialFrame (D := ↑D)).toTaskFrame.HybridValidOn ψ ∧
        ¬ (FrameOver.trivialFrame (D := ↑D)).translationProduct.toTaskFrame.HybridValidOn ψ) := by
  obtain ⟨χ, h1, h2⟩ := frame_validity_not_reflected (D := D)
  refine ⟨HybridFormula.recF 0, HybridFormula.ofPlus χ, recF_separates_trivial, ?_, ?_⟩
  · exact (hybridValidOn_ofPlus_iff _ χ).2 h1
  · intro h; exact h2 ((hybridValidOn_ofPlus_iff _ χ).1 h)

/-! ## What state registers still cannot see: determinism

`Independence/StateSetTruth.lean` proves that over an (H1)+(H2) frame the truth of an L⁺ formula
depends only on the world state of evaluation. The three hybrid clauses are state-local too:
`reg i` compares the present state with a stored one, `bind i` stores the present state, and
`[≡]` quantifies over the pairs at the present state. So the state-set recursion extends, and
`F°` and `F¹` — the indistinguishable pair of `cor:no-characterization` — validate exactly the
same hybrid sentences. -/

/-- The state set of a hybrid formula under a valuation and a register vector, by recursion on
the formula; the register vector is threaded through and updated by the binder. -/
def hsatSet {W : Type} [LinearOrder W] (V : W → Atom → Prop) :
    HybridFormula → (ℕ → W) → Set W
  | .atom p, _ => {w | V w p}
  | .bot, _ => ∅
  | .imp φ ψ, r => {w | w ∈ hsatSet V φ r → w ∈ hsatSet V ψ r}
  | .box φ, r => {_w | ∀ v : W, v ∈ hsatSet V φ r}
  | .untl ψ φ, r => {w | ∃ v, w < v ∧ v ∈ hsatSet V φ r ∧ ∀ u, w < u → u < v → u ∈ hsatSet V ψ r}
  | .snce ψ φ, r => {w | ∃ v, v < w ∧ v ∈ hsatSet V φ r ∧ ∀ u, v < u → u < w → u ∈ hsatSet V ψ r}
  | .stab φ, r => hsatSet V φ r
  | .same φ, r => hsatSet V φ r
  | .reg i, r => {w | w = r i}
  | .bind i φ, r => {w | w ∈ hsatSet V φ (Function.update r i w)}

variable {F : TaskFrame} [LinearOrder F.WorldState]

/-- **The hybrid state-set bridge.** Over an (H1)+(H2) frame, a hybrid formula is true at a
history, time and register vector exactly when the present state lies in its state set. The
seven L⁺ cases are those of `plusTruthAt_iff_mem_satSet`; `same`, `reg` and `bind` are
state-local by their clauses. -/
theorem hybridTruthAt_iff_mem_hsatSet (h1 : OrderFlow F) (h2 : StateOccurs F)
    (M : TaskModel F) (φ : HybridFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration) (r : ℕ → F.WorldState),
      HybridTruthAt M τ t r φ ↔ τ.state t ∈ hsatSet M.valuation φ r := by
  induction φ with
  | atom p => intro τ t r; exact Iff.rfl
  | bot => intro τ t r; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
    intro τ t r
    exact imp_congr (ihφ τ t r) (ihψ τ t r)
  | box φ ih =>
    intro τ t r
    constructor
    · intro h v
      obtain ⟨σ, hst⟩ := h2 v t
      have hv := (ih σ t r).mp (h σ)
      rwa [hst] at hv
    · intro h σ
      exact (ih σ t r).mpr (h _)
  | untl ψ φ ihψ ihφ =>
    intro τ t r
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨τ.state s, h1.strictMono τ hts, (ihφ τ s r).mp hφ, ?_⟩
      intro u hu1 hu2
      obtain ⟨c, hc1, hc2, hcu⟩ := h1.between τ hu1 hu2
      have hc := (ihψ τ c r).mp (hψ c hc1 hc2)
      rwa [hcu] at hc
    · rintro ⟨v, hlt, hv, hu⟩
      obtain ⟨s, hts, hsv⟩ := h1.hits_future τ hlt
      refine ⟨s, hts, (ihφ τ s r).mpr (by rw [hsv]; exact hv), ?_⟩
      intro q hq1 hq2
      refine (ihψ τ q r).mpr (hu _ (h1.strictMono τ hq1) ?_)
      have hqs := h1.strictMono τ hq2
      rwa [hsv] at hqs
  | snce ψ φ ihψ ihφ =>
    intro τ t r
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨τ.state s, h1.strictMono τ hst, (ihφ τ s r).mp hφ, ?_⟩
      intro u hu1 hu2
      obtain ⟨c, hc1, hc2, hcu⟩ := h1.between_past τ hu1 hu2
      have hc := (ihψ τ c r).mp (hψ c hc1 hc2)
      rwa [hcu] at hc
    · rintro ⟨v, hlt, hv, hu⟩
      obtain ⟨s, hst, hsv⟩ := h1.hits_past τ hlt
      refine ⟨s, hst, (ihφ τ s r).mpr (by rw [hsv]; exact hv), ?_⟩
      intro q hq1 hq2
      refine (ihψ τ q r).mpr (hu _ ?_ (h1.strictMono τ hq2))
      have hsq := h1.strictMono τ hq1
      rwa [hsv] at hsq
  | stab φ ih =>
    intro τ t r
    constructor
    · intro h; exact (ih τ t r).mp (h τ rfl)
    · intro h σ hsame
      refine (ih σ t r).mpr ?_
      rw [← hsame]; exact h
  | same φ ih =>
    intro τ t r
    constructor
    · intro h; exact (ih τ t r).mp (h τ t rfl)
    · intro h σ s hs
      refine (ih σ s r).mpr ?_
      rw [hs]; exact h
  | reg i => intro τ t r; exact Iff.rfl
  | bind i φ ih => intro τ t r; exact ih τ t _

/-- The validity corollary: over an (H1)+(H2) frame, a hybrid formula is frame-valid iff its
state set is everything under every valuation and every register vector. -/
theorem hybridValidOn_iff_hsatSet_univ (h1 : OrderFlow F) (h2 : StateOccurs F)
    (φ : HybridFormula) :
    F.HybridValidOn φ ↔
      ∀ (V : F.WorldState → Atom → Prop) (r : ℕ → F.WorldState), hsatSet V φ r = Set.univ := by
  constructor
  · intro hv V r
    ext w
    simp only [Set.mem_univ, iff_true]
    obtain ⟨τ, hst⟩ := h2 w 0
    have h := (hybridTruthAt_iff_mem_hsatSet h1 h2 ⟨V⟩ φ τ 0 r).mp (hv ⟨V⟩ τ 0 r)
    rwa [hst] at h
  · intro h M τ t r
    refine (hybridTruthAt_iff_mem_hsatSet h1 h2 M φ τ t r).mpr ?_
    rw [h M.valuation r]
    exact Set.mem_univ _

/-- **`F°` and `F¹` validate exactly the same hybrid sentences.** State registers, the binder
and `[≡]` do not separate the drift frame from the deterministic translation flow. -/
theorem fzero_hybridValidOn_iff_f1 (φ : HybridFormula) :
    F0.HybridValidOn φ ↔ F1.HybridValidOn φ := by
  rw [hybridValidOn_iff_hsatSet_univ fzero_orderFlow fzero_stateOccurs φ,
      hybridValidOn_iff_hsatSet_univ f1_orderFlow f1_stateOccurs φ]

/-- **`Deterministic` is not definable in the hybrid state language** — `cor:no-characterization`
survives the addition of state nominals, registers, the binder and `[≡]`. -/
theorem deterministic_not_hybridDefinable :
    ¬ ∃ Γ : Set HybridFormula, ∀ F : TaskFrame, F.Deterministic ↔ ∀ φ ∈ Γ, F.HybridValidOn φ := by
  rintro ⟨Γ, hΓ⟩
  have h1 : ∀ φ ∈ Γ, F1.HybridValidOn φ := (hΓ F1).mp f1_deterministic
  have h0 : ∀ φ ∈ Γ, F0.HybridValidOn φ :=
    fun φ hφ => (fzero_hybridValidOn_iff_f1 φ).mpr (h1 φ hφ)
  exact fzero_not_deterministic ((hΓ F0).mpr h0)

end Probe653
