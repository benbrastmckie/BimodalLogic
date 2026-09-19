import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Semantics.PlusLanguage.PlusValidity
import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Metalogic.Independence.PastedCoarseModels

/-!
# Probe 01 — the translation product against the LIVE `FrameOver` structure

Every result here is stated against `FormalSystem/Semantics/TaskFrame.lean`'s `FrameOver`,
`Semantics/PartialHistory.lean`'s `WorldHistory`, the three live truth recursions
(`TruthAt`, `PlusTruthAt`, `StarTruthAt`) and the coarsened recursion `CTruthAt`. Sorry-free;
compiled with `lake env lean` against the repository's own oleans.

Contents, keyed to the dispatch questions:

* Q1 — `prodRel R` over a BARE relation, with each `FrameOver` obligation discharged from the
  named hypothesis on `R` alone: reflection (`prodRel_reflection`, from reflection of `R`),
  Compositionality (`prodRel_comp`), Seriality (`prodRel_serial`), *Limit*
  (`prodRel_limit`, from `R w 0 u → u = w` ONLY), *Saturation* (`prodRel_saturation`, from
  Saturation of `R`; and the converse `saturation_of_prodRel`). `prodFrame F : FrameOver D` is
  the live frame; `prodFrame_sat` shows it sits in the same `FrameClass` as `F` at every tag.
  `colourClock` builds a task frame over ANY `D` from a finite reflective serial compositional
  relation with `⇒₀ ⊆ id`, with no Limit hypothesis.
* Histories — `liftH`/`projH`, `projH_liftH`, `liftH_projH` (histories of the product are
  exactly history-plus-offset pairs, live), `clock_eq`, `prod_no_recurrence`,
  `prod_no_transposition`.
* Q3 — `truth_invariance` (L), `plus_invariance` (L⁺), `star_invariance` (L⋆: settles report
  04's UNVERIFIED case), `validIn_iff_recurrenceFree` / `plusValidIn_iff_recurrenceFree` /
  `starValidIn_iff_recurrenceFree` (class validity = validity over recurrence-free members, at
  every `FrameClass` tag, for all three languages), and
  `frame_validity_not_reflected` (frame-level validity is NOT preserved: the product validates
  strictly fewer formulas because it admits clock-dependent valuations).
* Q2 — `HistMorphism` (the general notion the invariance proof consumes), `histMorphism_invariance`,
  `prodProj` as an instance, `Clock`, and `clockedFactor`: every clocked history-morphism into `F`
  factors through the product.
* Q4(c) — `liftK`, `c_invariance`, `pasteClosed_liftK` / `pasteClosed_of_liftK`: the product of a
  paste-closed coarse model is paste-closed, and coarse refutations transfer.
-/

set_option linter.unusedSectionVars false

namespace Probe624

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Metalogic.Independence

/-! ## Q1 — the product relation over a bare relation -/

section Bare
variable {D : TemporalOrder} {W : Type} (R : W → ↑D → W → Prop)

/-- The translation-product relation on `W × D`: a task of duration `x` advances the clock by
`x`. This is `probe 559/04`'s `clockP`, stated over `↑D` for a `TemporalOrder`. -/
def prodRel : (W × ↑D) → ↑D → (W × ↑D) → Prop :=
  fun a x b => R a.1 x b.1 ∧ b.2 = a.2 + x

/-- **Reflection** needs only reflection of `R`. -/
theorem prodRel_reflection (hR : ∀ w d u, R w d u ↔ R u (-d) w) :
    ∀ a d b, prodRel R a d b ↔ prodRel R b (-d) a := by
  intro a d b
  constructor
  · rintro ⟨h1, h2⟩
    exact ⟨(hR _ _ _).1 h1, by rw [h2]; abel⟩
  · rintro ⟨h1, h2⟩
    exact ⟨(hR _ _ _).2 h1, by rw [h2]; abel⟩

/-- **Compositionality** (biconditional) needs only Compositionality of `R`. -/
theorem prodRel_comp (hC : TaskFrame.Compositional R) : TaskFrame.Compositional (prodRel R) := by
  intro a b x y hx hy
  constructor
  · rintro ⟨h1, h2⟩
    obtain ⟨u, hu1, hu2⟩ := (hC a.1 b.1 x y hx hy).1 h1
    exact ⟨(u, a.2 + x), ⟨hu1, rfl⟩, ⟨hu2, by show b.2 = a.2 + x + y; rw [h2]; abel⟩⟩
  · rintro ⟨u, ⟨h1, h2⟩, ⟨h3, h4⟩⟩
    exact ⟨(hC a.1 b.1 x y hx hy).2 ⟨u.1, h1, h3⟩, by show b.2 = a.2 + (x + y); rw [h4, h2]; abel⟩

/-- **Seriality** needs only Seriality of `R`. -/
theorem prodRel_serial (hS : TaskFrame.Serial R) : TaskFrame.Serial (prodRel R) := by
  intro a x hx
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := hS a.1 x hx
  exact ⟨⟨(u, a.2 + x), hu, rfl⟩, ⟨(v, a.2 - x), hv, by rw [sub_add_cancel]⟩⟩

/-- **Limit is free**: it needs only `⇒₀ ⊆ id` in `R` — no Limit hypothesis on `R`, no
hypothesis on cones. This is the live counterpart of `probe 559/04`'s `clock_limit`, routed
through the landed `TaskFrame.limit_of_shift`. -/
theorem prodRel_limit (h0 : ∀ w u, R w 0 u → u = w) :
    ∀ a b, (∀ x : ↑D, 0 < x → ∃ y, |y| < x ∧ prodRel R a y b) → b = a :=
  TaskFrame.limit_of_shift (D := ↑D) Prod.snd (fun _ _ _ h => h.2)
    (fun a b h => Prod.ext (h0 _ _ h.1) (by rw [h.2, add_zero]))

/-- Every fibre and every segment of the product has a constant clock coordinate. -/
theorem prodRel_const_clock (s : Set (W × ↑D))
    (h : TaskFrame.IsFiber (prodRel R) s ∨ TaskFrame.IsSegment (prodRel R) s) :
    ∃ c, ∀ b ∈ s, b.2 = c := by
  rcases h with ⟨a, x, rfl⟩ | ⟨a, a', x, y, _, _, rfl⟩
  · exact ⟨a.2 + x, fun b hb => hb.2⟩
  · exact ⟨a.2 + x, fun b hb => hb.1.2⟩

/-- The state-projection of a product fibre is the corresponding fibre of `R`. -/
theorem prodRel_fib_image (a : W × ↑D) (x : ↑D) :
    Prod.fst '' TaskFrame.Fib (prodRel R) a x = TaskFrame.Fib R a.1 x := by
  ext u
  constructor
  · rintro ⟨b, hb, rfl⟩; exact hb.1
  · intro hu; exact ⟨(u, a.2 + x), ⟨hu, rfl⟩, rfl⟩

/-- The state-projection of a NONEMPTY product segment is the corresponding segment of `R`. -/
theorem prodRel_seg_image (a a' : W × ↑D) (x y : ↑D)
    (hne : (TaskFrame.Seg (prodRel R) a a' x y).Nonempty) :
    Prod.fst '' TaskFrame.Seg (prodRel R) a a' x y = TaskFrame.Seg R a.1 a'.1 x y := by
  obtain ⟨b₀, hb₀⟩ := hne
  have hclk : a.2 + x = a'.2 + -y := by rw [← hb₀.1.2, ← hb₀.2.2]
  ext u
  constructor
  · rintro ⟨b, hb, rfl⟩; exact ⟨hb.1.1, hb.2.1⟩
  · intro hu; exact ⟨(u, a.2 + x), ⟨⟨hu.1, rfl⟩, ⟨hu.2, hclk⟩⟩, rfl⟩

/-- **Saturation of the product from Saturation of `R`** (report 03 §3.2's paper argument,
now compiled): members of a `⊇`-directed family share one clock value, so the family projects
to a directed family of nonempty fibres and segments of `R`. -/
theorem prodRel_saturation (hsat : TaskFrame.Saturation R) :
    TaskFrame.Saturation (prodRel R) := by
  intro S hdir hmem
  obtain ⟨⟨s₀, hs₀⟩, hd⟩ := hdir
  obtain ⟨b₀, hb₀⟩ := (hmem s₀ hs₀).2
  -- every member has the clock value of `b₀`
  have hclk : ∀ s ∈ S, ∀ b ∈ s, b.2 = b₀.2 := by
    intro s hs b hb
    obtain ⟨s', hs', hsub⟩ := hd s₀ hs₀ s hs
    obtain ⟨b', hb'⟩ := (hmem s' hs').2
    have h1 := hsub hb'
    obtain ⟨c₀, hc₀⟩ := prodRel_const_clock R s₀ (hmem s₀ hs₀).1
    obtain ⟨c₁, hc₁⟩ := prodRel_const_clock R s (hmem s hs).1
    calc b.2 = c₁ := hc₁ b hb
      _ = b'.2 := (hc₁ b' h1.2).symm
      _ = c₀ := hc₀ b' h1.1
      _ = b₀.2 := (hc₀ b₀ hb₀).symm
  -- the projected family
  let S₀ : Set (Set W) := (fun s => Prod.fst '' s) '' S
  have hdir₀ : TaskFrame.DirectedFamily S₀ := by
    refine ⟨⟨_, s₀, hs₀, rfl⟩, ?_⟩
    rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
    obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁ s₂ hs₂
    refine ⟨Prod.fst '' s', ⟨s', hs', rfl⟩, ?_⟩
    rintro _ ⟨b, hb, rfl⟩
    exact ⟨⟨b, (hsub hb).1, rfl⟩, ⟨b, (hsub hb).2, rfl⟩⟩
  have hmem₀ : ∀ s ∈ S₀, (TaskFrame.IsFiber R s ∨ TaskFrame.IsSegment R s) ∧ s.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    obtain ⟨hcls, ⟨b, hb⟩⟩ := hmem s hs
    refine ⟨?_, ⟨b.1, b, hb, rfl⟩⟩
    rcases hcls with ⟨a, x, rfl⟩ | ⟨a, a', x, y, hx, hy, rfl⟩
    · exact Or.inl ⟨a.1, x, prodRel_fib_image R a x⟩
    · exact Or.inr ⟨a.1, a'.1, x, y, hx, hy, prodRel_seg_image R a a' x y ⟨b, hb⟩⟩
  obtain ⟨u, hu⟩ := hsat S₀ hdir₀ hmem₀
  refine ⟨(u, b₀.2), fun s hs => ?_⟩
  obtain ⟨b, hb, hb1⟩ : u ∈ Prod.fst '' s := Set.mem_sInter.1 hu _ ⟨s, hs, rfl⟩
  have : b = (u, b₀.2) := Prod.ext hb1 (hclk s hs b hb)
  exact this ▸ hb

/-- **Saturation of `R` from Saturation of the product** — the product is neutral on
Saturation: it neither buys nor loses it. -/
theorem saturation_of_prodRel (hsat : TaskFrame.Saturation (prodRel R)) :
    TaskFrame.Saturation R := by
  intro S hdir hmem
  obtain ⟨⟨s₀, hs₀⟩, hd⟩ := hdir
  -- embed each member at clock `0`
  let e : Set W → Set (W × ↑D) := fun s => {b | b.1 ∈ s ∧ b.2 = 0}
  let S' : Set (Set (W × ↑D)) := e '' S
  have hdir' : TaskFrame.DirectedFamily S' := by
    refine ⟨⟨_, s₀, hs₀, rfl⟩, ?_⟩
    rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩
    obtain ⟨s', hs', hsub⟩ := hd s₁ hs₁ s₂ hs₂
    exact ⟨e s', ⟨s', hs', rfl⟩, fun b hb => ⟨⟨(hsub hb.1).1, hb.2⟩, ⟨(hsub hb.1).2, hb.2⟩⟩⟩
  have hmem' : ∀ s ∈ S', (TaskFrame.IsFiber (prodRel R) s ∨ TaskFrame.IsSegment (prodRel R) s)
      ∧ s.Nonempty := by
    rintro _ ⟨s, hs, rfl⟩
    obtain ⟨hcls, ⟨u, hu⟩⟩ := hmem s hs
    refine ⟨?_, ⟨(u, 0), hu, rfl⟩⟩
    rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, hx, hy, rfl⟩
    · refine Or.inl ⟨(w, -x), x, ?_⟩
      ext b
      show b.1 ∈ TaskFrame.Fib R w x ∧ b.2 = 0 ↔ R w x b.1 ∧ b.2 = -x + x
      rw [neg_add_cancel]; exact Iff.rfl
    · refine Or.inr ⟨(w, -x), (v, y), x, y, hx, hy, ?_⟩
      ext b
      show b.1 ∈ TaskFrame.Seg R w v x y ∧ b.2 = 0 ↔
        (R w x b.1 ∧ b.2 = -x + x) ∧ (R v (-y) b.1 ∧ b.2 = y + -y)
      rw [neg_add_cancel, add_neg_cancel]
      constructor
      · rintro ⟨⟨h1, h2⟩, h3⟩; exact ⟨⟨h1, h3⟩, ⟨h2, h3⟩⟩
      · rintro ⟨⟨h1, h3⟩, ⟨h2, _⟩⟩; exact ⟨⟨h1, h2⟩, h3⟩
  obtain ⟨b, hb⟩ := hsat S' hdir' hmem'
  exact ⟨b.1, fun s hs => (Set.mem_sInter.1 hb _ ⟨s, hs, rfl⟩).1⟩

/-- **Any finite reflective, serial, compositional relation with `⇒₀ ⊆ id` clocks to a task
frame over ANY temporal order.** No Limit hypothesis: the clock supplies it. Saturation of the
colour relation is `cor:saturation-finite`. This is report 04 §4.2's "frame axioms are not the
obstacle", compiled against the live structure. -/
def colourClock [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w) : FrameOver D :=
  haveI : Nonempty ↑D := ⟨0⟩
  FrameOver.ofReflective (W × ↑D) (prodRel R) (prodRel_reflection R hR) (prodRel_comp R hC)
    (prodRel_serial R hS) (prodRel_limit R h0)
    (prodRel_saturation R (TaskFrame.saturation_of_finite R))

end Bare

/-! ## Q1 — the product of a live frame -/

section Frame
variable {D : TemporalOrder} (F : FrameOver D)

/-- **The translation product of a live frame.** Each field is discharged from the
corresponding field of `F`; the Limit field uses only `F.eq_of_taskRel_zero`. -/
def prodFrame : FrameOver D :=
  haveI : Nonempty ↑D := ⟨0⟩
  FrameOver.ofReflective (F.WorldState × ↑D) (prodRel F.TaskRel) (prodRel_reflection _ F.reflection)
    (prodRel_comp _ F.comp) (prodRel_serial _ F.serial)
    (prodRel_limit _ fun _ _ h => (F.eq_of_taskRel_zero h).symm)
    (prodRel_saturation _ F.saturation)

@[simp] theorem prodFrame_taskRel (a : F.WorldState × ↑D) (x : ↑D) (b : F.WorldState × ↑D) :
    (prodFrame F).TaskRel a x b ↔ F.TaskRel a.1 x b.1 ∧ b.2 = a.2 + x :=
  FrameOver.ofReflective_taskRel

/-- The product lives in exactly the same `FrameClass` as `F`, at every tag: the four tags
constrain the temporal order only, and the product keeps `D`. -/
theorem prodFrame_sat (fc : FormalSystem.ProofSystem.FrameClass) :
    fc.Sat (prodFrame F).toTaskFrame ↔ fc.Sat F.toTaskFrame := by
  cases fc <;> exact Iff.rfl

/-- The product preserves and reflects determinism (`def:deterministic`): it is neutral on it. -/
theorem prodFrame_deterministic_iff :
    (prodFrame F).toTaskFrame.Deterministic ↔ F.toTaskFrame.Deterministic := by
  constructor
  · intro h w d u hu u' hu'
    have hu1 : (u, (0 : ↑D) + d) ∈ TaskFrame.Fib (prodFrame F).TaskRel (w, 0) d :=
      (prodFrame_taskRel F (w, 0) d (u, 0 + d)).2 ⟨TaskFrame.mem_Fib.1 hu, rfl⟩
    have hu2 : (u', (0 : ↑D) + d) ∈ TaskFrame.Fib (prodFrame F).TaskRel (w, 0) d :=
      (prodFrame_taskRel F (w, 0) d (u', 0 + d)).2 ⟨TaskFrame.mem_Fib.1 hu', rfl⟩
    exact congrArg Prod.fst (h (w, 0) d hu1 hu2)
  · intro h a d b hb b' hb'
    have hb := (prodFrame_taskRel F _ _ _).1 hb
    have hb' := (prodFrame_taskRel F _ _ _).1 hb'
    exact Prod.ext (h a.1 d (TaskFrame.mem_Fib.2 hb.1) (TaskFrame.mem_Fib.2 hb'.1))
      (hb.2.trans hb'.2.symm)

/-! ### Histories of the product -/

/-- The lift of a history of `F` with clock offset `c`. -/
def liftH (ρ : WorldHistory F.toTaskFrame) (c : ↑D) : WorldHistory (prodFrame F).toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => (ρ.state t, c + t)) (by
    intro s t
    exact (prodFrame_taskRel F _ _ _).2 ⟨ρ.respects_task s t, by show c + t = c + s + (t - s); abel⟩)

/-- The projection of a history of the product. -/
def projH (τ' : WorldHistory (prodFrame F).toTaskFrame) : WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => (τ'.state t).1)
    (fun s t => ((prodFrame_taskRel F _ _ _).1 (τ'.respects_task s t)).1)

@[simp] theorem liftH_state (ρ : WorldHistory F.toTaskFrame) (c t : ↑D) :
    (liftH F ρ c).state t = (ρ.state t, c + t) := rfl

@[simp] theorem projH_state (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D) :
    (projH F τ').state t = (τ'.state t).1 := rfl

theorem projH_liftH (ρ : WorldHistory F.toTaskFrame) (c : ↑D) : projH F (liftH F ρ c) = ρ :=
  WorldHistory.ext_state fun _ => rfl

/-- The clock along any history of the product is time plus a constant. -/
theorem clock_eq (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D) :
    (τ'.state t).2 = (τ'.state 0).2 + t := by
  have := ((prodFrame_taskRel F _ _ _).1 (τ'.respects_task 0 t)).2
  rwa [sub_zero] at this

/-- **Histories of the product are exactly history-plus-offset pairs** (live form of
`clock_hist_iff`): lifts are unique and no Extension Theorem is needed. -/
theorem liftH_projH (τ' : WorldHistory (prodFrame F).toTaskFrame) :
    liftH F (projH F τ') (τ'.state 0).2 = τ' :=
  WorldHistory.ext_state fun t => Prod.ext rfl (clock_eq F τ' t).symm

/-- **No history of the product visits a world state twice.** -/
theorem prod_no_recurrence (τ' : WorldHistory (prodFrame F).toTaskFrame) {s t : ↑D}
    (h : τ'.state s = τ'.state t) : s = t := by
  have h2 : (τ'.state s).2 = (τ'.state t).2 := by rw [h]
  rw [clock_eq F τ' s, clock_eq F τ' t] at h2
  exact add_left_cancel h2

/-- **No two histories of the product transpose two world states**: the clock is monotone, so
the same pair of states cannot be visited in opposite orders. (In an ordered abelian group
`x - y = y - x` forces `x = y`.) -/
theorem prod_no_transposition :
    ¬ ∃ (τ σ : WorldHistory (prodFrame F).toTaskFrame) (s t : ↑D),
      s ≠ t ∧ τ.state s = σ.state t ∧ τ.state t = σ.state s := by
  rintro ⟨τ, σ, s, t, hne, h1, h2⟩
  have e1 : (τ.state 0).2 + s = (σ.state 0).2 + t := by
    rw [← clock_eq, ← clock_eq, h1]
  have e2 : (τ.state 0).2 + t = (σ.state 0).2 + s := by
    rw [← clock_eq, ← clock_eq, h2]
  have h4 : ((τ.state 0).2 + (σ.state 0).2) + (s + s) = ((τ.state 0).2 + (σ.state 0).2) + (t + t) := by
    calc ((τ.state 0).2 + (σ.state 0).2) + (s + s)
        = ((τ.state 0).2 + s) + ((σ.state 0).2 + s) := by abel
      _ = ((σ.state 0).2 + t) + ((τ.state 0).2 + t) := by rw [e1, ← e2]
      _ = ((τ.state 0).2 + (σ.state 0).2) + (t + t) := by abel
  have h5 : s + s = t + t := add_left_cancel h4
  rcases lt_trichotomy s t with hlt | heq | hgt
  · exact absurd h5 (ne_of_lt (add_lt_add hlt hlt))
  · exact hne heq
  · exact absurd h5 (ne_of_gt (add_lt_add hgt hgt))

/-! ### Q3 — truth invariance under the projection, for L, L⁺ and L⋆ -/

/-- The lift of a model: the valuation ignores the clock (sentence letters denote sets of world
states, `def:BL-semantics`). -/
def liftM (M : TaskModel F.toTaskFrame) : TaskModel (prodFrame F).toTaskFrame :=
  ⟨fun a p => M.valuation a.1 p⟩

/-- The lift of a history through a given product state at a given time. -/
theorem liftH_through (ρ : WorldHistory F.toTaskFrame) (a : F.WorldState × ↑D) (t : ↑D)
    (h : a.1 = ρ.state t) : (liftH F ρ (a.2 - t)).state t = a :=
  Prod.ext h.symm (by show a.2 - t + t = a.2; exact sub_add_cancel _ _)

/-- **L: truth is preserved by the projection.** -/
theorem truth_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : Formula) (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D),
      TruthAt (liftM F M) τ' t φ ↔ TruthAt M (projH F τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)

/-- **L⁺: truth is preserved by the projection** (live form of `clock_invariance`). The `⊡`
clause is where the clock matters: a history through the projected state lifts to a history
through the product state itself, with the clock offset read off that state. -/
theorem plus_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D),
      PlusTruthAt (liftM F M) τ' t φ ↔ PlusTruthAt M (projH F τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | stab a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      have hl := liftH_through F ρ (τ'.state t) t hρ
      have := (ih _ t).1 (h _ hl.symm)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ (congrArg Prod.fst he))

/-- **L⋆: truth is preserved by the projection, at every register vector.** The two register
clauses are inert: `timeStore` updates the vector and `timeRecall` moves the time, neither
touches the history. This settles report 04 §3.3's UNVERIFIED item: recurrence is invisible to
L⋆ as well. -/
theorem star_invariance (M : TaskModel F.toTaskFrame) :
    ∀ (φ : StarFormula) (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D)
      (v : ℕ → ↑D),
      StarTruthAt (liftM F M) τ' t v φ ↔ StarTruthAt M (projH F τ') t v φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t v; exact Iff.rfl
  | bot => intro τ' t v; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t v; exact imp_congr (ih1 τ' t v) (ih2 τ' t v)
  | box a ih =>
    intro τ' t v
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t v).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t v).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t v
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s v) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r v)
  | snce a b ih1 ih2 =>
    intro τ' t v
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s v) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r v)
  | stab a ih =>
    intro τ' t v
    constructor
    · intro h ρ hρ
      have hl := liftH_through F ρ (τ'.state t) t hρ
      have := (ih _ t v).1 (h _ hl.symm)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t v).2 (h _ (congrArg Prod.fst he))
  | timeStore i a ih => intro τ' t v; exact ih τ' t _
  | timeRecall i a ih => intro τ' t v; exact ih τ' _ v

/-! ### Q3 — class validity equals validity over recurrence-free members -/

/-- A task frame is **recurrence-free** when no world history visits a world state twice. -/
def RecurrenceFree (G : TaskFrame) : Prop :=
  ∀ (τ : WorldHistory G) (s t : G.Duration), τ.state s = τ.state t → s = t

theorem prodFrame_recurrenceFree : RecurrenceFree (prodFrame F).toTaskFrame :=
  fun τ' _ _ h => prod_no_recurrence F τ' h

/-- Frame validity on the product implies frame validity on `F` (lift the model and the
history). The converse FAILS: see `frame_validity_not_reflected`. -/
theorem plusValidOn_of_prod (φ : PlusFormula)
    (h : (prodFrame F).toTaskFrame.PlusValidOn φ) : F.toTaskFrame.PlusValidOn φ := by
  intro M τ t
  have := (plus_invariance F M φ (liftH F τ 0) t).1 (h _ _ _)
  rwa [projH_liftH] at this

theorem starValidOn_of_prod (φ : StarFormula)
    (h : (prodFrame F).toTaskFrame.StarValidOn φ) : F.toTaskFrame.StarValidOn φ := by
  intro M τ t v
  have := (star_invariance F M φ (liftH F τ 0) t v).1 (h _ _ _ _)
  rwa [projH_liftH] at this

theorem validOn_of_prod (φ : Formula)
    (h : (prodFrame F).toTaskFrame.ValidOn φ) : F.toTaskFrame.ValidOn φ := by
  intro M τ t
  have := (truth_invariance F M φ (liftH F τ 0) t).1 (h _ _ _)
  rwa [projH_liftH] at this

end Frame

section ClassValidity

/-- **At every `FrameClass` tag, L⁺-validity over the class equals L⁺-validity over its
recurrence-free members.** The recurrence-free members are a subclass (⇒); every frame of the
class is covered by its product, which is recurrence-free and in the class (⇐). -/
theorem plusValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : PlusFormula) :
    PlusValidIn fc φ ↔ PlusValidOnFrames (fun G => fc.Sat G ∧ RecurrenceFree G) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : (prodFrame G.toFibre).toTaskFrame.PlusValidOn φ :=
      h _ ⟨(prodFrame_sat G.toFibre fc).2 hG, prodFrame_recurrenceFree G.toFibre⟩
    exact plusValidOn_of_prod G.toFibre φ hp

/-- The same for L. -/
theorem validIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass) (φ : Formula) :
    ValidIn fc φ ↔ ValidOnFrames (fun G => fc.Sat G ∧ RecurrenceFree G) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : (prodFrame G.toFibre).toTaskFrame.ValidOn φ :=
      h _ ⟨(prodFrame_sat G.toFibre fc).2 hG, prodFrame_recurrenceFree G.toFibre⟩
    exact validOn_of_prod G.toFibre φ hp

/-- The same for L⋆. -/
theorem starValidIn_iff_recurrenceFree (fc : FormalSystem.ProofSystem.FrameClass)
    (φ : StarFormula) :
    StarValidIn fc φ ↔ StarValidOnFrames (fun G => fc.Sat G ∧ RecurrenceFree G) φ := by
  constructor
  · intro h G hG; exact h G hG.1
  · intro h G hG
    have hp : (prodFrame G.toFibre).toTaskFrame.StarValidOn φ :=
      h _ ⟨(prodFrame_sat G.toFibre fc).2 hG, prodFrame_recurrenceFree G.toFibre⟩
    exact starValidOn_of_prod G.toFibre φ hp

/-- The one sentence letter the counterexample uses. -/
def p₀ : Atom := ⟨"p", none⟩

/-- **Frame-level validity is NOT reflected by the product.** On the trivial one-state frame
`p → Gp` is valid (every history is constant); on its product — the translation frame on `D` —
a clock-dependent valuation refutes it. The product validates strictly fewer formulas than `F`:
the projection is a bounded morphism for LIFTED valuations only, and the extra valuations on
`W × D` are exactly the manuscript's abundant two-dimensional models (lines 832-937). -/
theorem frame_validity_not_reflected {D : TemporalOrder} :
    ∃ φ : PlusFormula,
      (FrameOver.trivialFrame (D := ↑D)).toTaskFrame.PlusValidOn φ ∧
      ¬ (prodFrame (FrameOver.trivialFrame (D := ↑D))).toTaskFrame.PlusValidOn φ := by
  refine ⟨(PlusFormula.atom p₀).imp (PlusFormula.allFuture (PlusFormula.atom p₀)), ?_, ?_⟩
  · intro M τ t hp
    rw [PlusTruth.allFuture_iff]
    intro s _
    haveI : Subsingleton (FrameOver.trivialFrame (D := ↑D)).WorldState :=
      inferInstanceAs (Subsingleton Unit)
    have : τ.state s = τ.state t := Subsingleton.elim _ _
    show M.valuation (τ.state s) p₀
    rw [this]; exact hp
  · intro h
    obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
    let M : TaskModel (prodFrame (FrameOver.trivialFrame (D := ↑D))).toTaskFrame :=
      ⟨fun a _ => a.2 ≤ 0⟩
    let τ : WorldHistory (prodFrame (FrameOver.trivialFrame (D := ↑D))).toTaskFrame :=
      liftH _ (WorldHistory.ofTotal _ (fun _ => ()) fun _ _ =>
        FrameOver.trivialFrame_taskRel.mpr True.intro) 0
    have h1 := h M τ 0
    have hp : PlusTruthAt M τ 0 (PlusFormula.atom p₀) := by
      show (0 : ↑D) + 0 ≤ 0
      rw [add_zero]
    have h2 := (PlusTruth.allFuture_iff _ _ _ _).1 (h1 hp) x hx
    have h3 : (0 : ↑D) + x ≤ 0 := h2
    rw [zero_add] at h3
    exact absurd hx (not_lt.2 h3)

end ClassValidity

/-! ## Q2 — the general notion: history-lifting morphisms -/

section Morphism
variable {D : TemporalOrder}

/-- A **history-lifting map** `F' → F`: a state map that carries tasks forward (`forth`) and
lifts every history of `F` through every preimage state (`lift`). `lift` is a history-level
condition, strictly stronger than the relation-level "back" clause of a bounded morphism, which
lifts one task at a time and yields a total lift only with an extension argument. -/
structure HistMap (F' F : FrameOver D) where
  toFun : F'.WorldState → F.WorldState
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (toFun a) x (toFun b)
  lift : ∀ (τ : WorldHistory F.toTaskFrame) (a : F'.WorldState) (t : ↑D),
    toFun a = τ.state t →
      ∃ τ' : WorldHistory F'.toTaskFrame, τ'.state t = a ∧ ∀ s, toFun (τ'.state s) = τ.state s

/-- A **history-lifting morphism**: a history-lifting map that is onto histories. This is
exactly what the invariance induction consumes: `forth` for the projection, `onto` for `□`,
`lift` for `⊡` (through the given state). -/
structure HistMorphism (F' F : FrameOver D) extends HistMap F' F where
  onto : ∀ τ : WorldHistory F.toTaskFrame,
    ∃ τ' : WorldHistory F'.toTaskFrame, ∀ s, toFun (τ'.state s) = τ.state s

variable {F' F : FrameOver D}

/-- The image of a history under a map. -/
def HistMap.mapH (g : HistMap F' F) (τ' : WorldHistory F'.toTaskFrame) :
    WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => g.toFun (τ'.state t))
    (fun s t => g.forth _ _ _ (τ'.respects_task s t))

@[simp] theorem HistMap.mapH_state (g : HistMap F' F) (τ' : WorldHistory F'.toTaskFrame)
    (t : ↑D) : (g.mapH τ').state t = g.toFun (τ'.state t) := rfl

/-- The pullback of a model along a map. -/
def HistMap.pullM (g : HistMap F' F) (M : TaskModel F.toTaskFrame) : TaskModel F'.toTaskFrame :=
  ⟨fun a p => M.valuation (g.toFun a) p⟩

/-- Surjectivity on states follows from `onto` plus occurrence of every state on some history;
it is not assumed. -/
theorem HistMorphism.surj_of_occurs (g : HistMorphism F' F)
    (hocc : ∀ w : F.WorldState, ∃ (τ : WorldHistory F.toTaskFrame) (t : ↑D), τ.state t = w) :
    Function.Surjective g.toFun := by
  intro w
  obtain ⟨τ, t, ht⟩ := hocc w
  obtain ⟨τ', hτ'⟩ := g.onto τ
  exact ⟨τ'.state t, (hτ' t).trans ht⟩

/-- **Truth invariance along any history-lifting morphism** (L⁺). -/
theorem histMorphism_invariance (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
      PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih ρ' t).1 (h _)
      rwa [hm] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | stab a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      obtain ⟨ρ', hρ't, hρ'⟩ := g.lift ρ (τ'.state t) t hρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih ρ' t).1 (h _ hρ't.symm)
      rwa [hm] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ (congrArg g.toFun he))

/-- **The projection is a history-lifting morphism.** -/
def prodProj (F : FrameOver D) : HistMorphism (prodFrame F) F where
  toFun := Prod.fst
  forth := fun _ _ _ h => ((prodFrame_taskRel F _ _ _).1 h).1
  lift := fun τ a t h => ⟨liftH F τ (a.2 - t), liftH_through F τ a t h, fun _ => rfl⟩
  onto := fun τ => ⟨liftH F τ 0, fun _ => rfl⟩

/-- A **clock** on a frame: a state function advanced by exactly the task duration. The
product carries the clock `Prod.snd`. -/
structure Clock (G : FrameOver D) where
  c : G.WorldState → ↑D
  adv : ∀ a x b, G.TaskRel a x b → c b = c a + x

def prodClock (F : FrameOver D) : Clock (prodFrame F) :=
  ⟨Prod.snd, fun _ _ _ h => ((prodFrame_taskRel F _ _ _).1 h).2⟩

/-- **Clocked covers factor through the product as history-lifting maps**: a map `g : F' → F`
with a clock on `F'` yields `F' → F × D`, `a ↦ (g a, c a)`, whose composite with the projection
is `g` and whose clock coordinate is `c`; uniqueness is `Prod.ext`. -/
def clockedFactor (g : HistMap F' F) (k : Clock F') : HistMap F' (prodFrame F) where
  toFun := fun a => (g.toFun a, k.c a)
  forth := fun a x b h => (prodFrame_taskRel F _ _ _).2 ⟨g.forth a x b h, k.adv a x b h⟩
  lift := by
    intro τ' a t h
    obtain ⟨ρ', hρ't, hρ'⟩ := g.lift (projH F τ') a t (congrArg Prod.fst h)
    refine ⟨ρ', hρ't, fun s => Prod.ext (hρ' s) ?_⟩
    show k.c (ρ'.state s) = (τ'.state s).2
    have h1 := k.adv _ _ _ (ρ'.respects_task t s)
    have h2 : k.c a = (τ'.state t).2 := congrArg Prod.snd h
    rw [h1, hρ't, h2, clock_eq F τ' s, clock_eq F τ' t]
    abel

theorem clockedFactor_fst (g : HistMap F' F) (k : Clock F') (a : F'.WorldState) :
    ((clockedFactor g k).toFun a).1 = g.toFun a := rfl

theorem clockedFactor_snd (g : HistMap F' F) (k : Clock F') (a : F'.WorldState) :
    ((clockedFactor g k).toFun a).2 = k.c a := rfl

/-- The factored map is a history-lifting **morphism** (onto histories) exactly when the clock
is jointly surjective with `g`: every (state, clock value) pair is realised. -/
def clockedFactorMorphism (g : HistMap F' F) (k : Clock F')
    (hjoint : ∀ (w : F.WorldState) (d : ↑D), ∃ a, g.toFun a = w ∧ k.c a = d) :
    HistMorphism F' (prodFrame F) where
  toHistMap := clockedFactor g k
  onto := by
    intro τ'
    obtain ⟨a, ha1, ha2⟩ := hjoint ((projH F τ').state 0) (τ'.state 0).2
    obtain ⟨ρ', hρ'0, hρ'⟩ := g.lift (projH F τ') a 0 ha1
    refine ⟨ρ', fun s => Prod.ext (hρ' s) ?_⟩
    show k.c (ρ'.state s) = (τ'.state s).2
    have h1 := k.adv _ _ _ (ρ'.respects_task 0 s)
    rw [h1, hρ'0, ha2, clock_eq F τ' s, sub_zero]

/-- **Joint surjectivity can fail**, so the factored map need not be onto: on the product of
the translation frame, `c (u, e) := u` is a clock, and `(fst, c)` misses `(0, x)` for any
`x ≠ 0`. A clocked cover therefore factors through the product, but not necessarily ONTO it. -/
def stateClock : Clock (prodFrame (translationFrame D)) :=
  ⟨fun a => a.1, fun a x b h =>
    (translationFrame_taskRel a.1 x b.1).1 ((prodFrame_taskRel _ _ _ _).1 h).1⟩

theorem stateClock_not_joint :
    ¬ ∀ (w : (translationFrame D).WorldState) (d : ↑D),
      ∃ a : (prodFrame (translationFrame D)).WorldState,
        (prodProj (translationFrame D)).toFun a = w ∧ stateClock.c a = d := by
  intro h
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := ↑D)
  obtain ⟨a, ha1, ha2⟩ := h (0 : ↑D) x
  have e1 : a.1 = (0 : ↑D) := ha1
  have e2 : a.1 = x := ha2
  have e3 : (0 : ↑D) = x := e1.symm.trans e2
  rw [← e3] at hx
  exact lt_irrefl _ hx

end Morphism

/-! ## Q4(c) — coarsened models -/

section Coarse
variable {D : TemporalOrder} (F : FrameOver D)

/-- The product of a coarse model: the coarsening forgets the clock. -/
def liftK (K : CoarseModel F.toTaskFrame) : CoarseModel (prodFrame F).toTaskFrame where
  toModel := liftM F K.toModel
  Cls := K.Cls
  π := fun a => K.π a.1
  atom_inv := fun h p hp => K.atom_inv h p hp

/-- **Coarse truth is preserved by the projection.** -/
theorem c_invariance (K : CoarseModel F.toTaskFrame) :
    ∀ (φ : PlusFormula) (τ' : WorldHistory (prodFrame F).toTaskFrame) (t : ↑D),
      CTruthAt (liftK F K) τ' t φ ↔ CTruthAt K (projH F τ') t φ := by
  intro φ
  induction φ with
  | atom p => intro τ' t; exact Iff.rfl
  | bot => intro τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro τ' t; exact imp_congr (ih1 τ' t) (ih2 τ' t)
  | box a ih =>
    intro τ' t
    constructor
    · intro h ρ
      have := (ih (liftH F ρ 0) t).1 (h _)
      rwa [projH_liftH] at this
    · intro h σ'; exact (ih σ' t).2 (h _)
  | untl a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | snce a b ih1 ih2 =>
    intro τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 τ' s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 τ' r)
  | stab a ih =>
    intro τ' t
    constructor
    · intro h ρ hρ
      -- `hρ : SameUnder K (projH τ') ρ t`, i.e. `K.π (τ' t).1 = K.π (ρ t)`
      have hl : SameUnder (liftK F K) τ' (liftH F ρ 0) t := hρ
      have := (ih _ t).1 (h _ hl)
      rwa [projH_liftH] at this
    · intro h σ' he
      exact (ih σ' t).2 (h _ he)

/-- **The product of a paste-closed coarse model is paste-closed.** -/
theorem pasteClosed_liftK (K : CoarseModel F.toTaskFrame) (hK : K.PasteClosed) :
    (liftK F K).PasteClosed := by
  intro ρ' σ' t hs
  obtain ⟨η, h1, h2⟩ := hK (projH F ρ') (projH F σ') t hs
  exact ⟨liftH F η 0, fun s hst => h1 s hst, fun s hts => h2 s hts⟩

/-- And conversely: paste-closure of the product gives paste-closure of `K`. -/
theorem pasteClosed_of_liftK (K : CoarseModel F.toTaskFrame) (hK : (liftK F K).PasteClosed) :
    K.PasteClosed := by
  intro ρ σ t hs
  obtain ⟨η', h1, h2⟩ := hK (liftH F ρ 0) (liftH F σ 0) t hs
  exact ⟨projH F η', fun s hst => h1 s hst, fun s hts => h2 s hts⟩

/-- **Coarse refutations transfer to the product**: a coarse countermodel on `F` (any `D`) is a
coarse countermodel on the clocked frame, which additionally satisfies *Limit* for free. -/
theorem c_refuted_lift (K : CoarseModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ↑D) (φ : PlusFormula) (h : ¬ CTruthAt K τ t φ) :
    ¬ CTruthAt (liftK F K) (liftH F τ 0) t φ := by
  intro h'
  have := (c_invariance F K φ (liftH F τ 0) t).1 h'
  rw [projH_liftH] at this
  exact h this

end Coarse

end Probe624
