-- PROBE (scratch, not a library module). Compiled green via `lean_run_code` against this tree
-- (Lean v4.33.0-rc1, Mathlib tag v4.33.0-rc1). Evidence for Q2 and Q3 of the research report.
--
-- Q2 (the headline, CONFIRMED): over ℝ, every task frame with countably many world states is
-- static. No finiteness, no uniform dwell time.
--
-- Section `Sierp` is the missing Mathlib ingredient: Sierpiński's theorem in the form
-- "a map ℝ → W with W countable and all level sets closed is constant". Mathlib's `Sierpinski*`
-- declarations are all about the Sierpiński SPACE; the partition theorem is absent, and this
-- section proves the real-line case directly (Baire on the non-locally-constant part).
--
-- Section `Frame` spends it: *Saturation* (through `thm:extension`) yields a total history
-- realizing any task, *Limit* makes each of its level sets closed, and Sierpiński collapses it.
--
-- `import Mathlib` is used for probe convenience only; see the report's promotion recommendation
-- for the narrowed import list.
import Mathlib
import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.Correspondence.Rigidity

namespace Probe
open FormalSystem.Semantics TaskFrame

/-! ## Sierpiński's theorem on the real line -/

namespace Sierp

variable {W : Type} [Countable W] (h : ℝ → W)

/-- The level set of `a`. -/
def S (a : W) : Set ℝ := {t | h t = a}

omit [Countable W] in
theorem mem_S {t : ℝ} {a : W} : t ∈ S h a ↔ h t = a := Iff.rfl

/-- The locally-constant part: the union of the interiors of the level sets. Its complement is
where the Baire argument lives. -/
def U : Set ℝ := ⋃ a, interior (S h a)

omit [Countable W] in
theorem isOpen_U : IsOpen (U h) := isOpen_iUnion fun _ => isOpen_interior

omit [Countable W] in
theorem mem_U_iff {t : ℝ} : t ∈ U h ↔ t ∈ interior (S h (h t)) := by
  constructor
  · rintro ⟨s, ⟨a, rfl⟩, hts⟩
    have ha : h t = a := (mem_S h).mp (interior_subset hts)
    subst ha; exact hts
  · intro ht; exact Set.mem_iUnion.mpr ⟨h t, ht⟩

omit [Countable W] in
/-- On a preconnected subset of the locally-constant part, `h` is constant. Proved by splitting
the level-set interiors into "the value at `c₀`" and "all the others". -/
theorem const_of_preconnected {C : Set ℝ} (hC : IsPreconnected C) (hCU : C ⊆ U h)
    {c₀ : ℝ} (hc₀ : c₀ ∈ C) : ∀ t ∈ C, h t = h c₀ := by
  by_contra hcon
  push Not at hcon
  obtain ⟨t, htC, hne⟩ := hcon
  set u : Set ℝ := interior (S h (h c₀)) with hu
  set v : Set ℝ := ⋃ a ∈ {a : W | a ≠ h c₀}, interior (S h a) with hv
  have hopenu : IsOpen u := isOpen_interior
  have hopenv : IsOpen v := isOpen_biUnion fun _ _ => isOpen_interior
  have hsub : C ⊆ u ∪ v := by
    intro x hx
    have hx' := (mem_U_iff h).mp (hCU hx)
    by_cases hxa : h x = h c₀
    · left; rw [hu, ← hxa]; exact hx'
    · right; exact Set.mem_biUnion hxa hx'
  have hCu : (C ∩ u).Nonempty := ⟨c₀, hc₀, (mem_U_iff h).mp (hCU hc₀)⟩
  have hCv : (C ∩ v).Nonempty := ⟨t, htC, Set.mem_biUnion hne ((mem_U_iff h).mp (hCU htC))⟩
  obtain ⟨x, _, hxu, hxv⟩ := hC u v hopenu hopenv hsub hCu hCv
  obtain ⟨a, ha, hxa⟩ := Set.mem_iUnion₂.mp hxv
  exact ha (((mem_S h).mp (interior_subset hxa)).symm.trans ((mem_S h).mp (interior_subset hxu)))

/--
**Sierpiński, real-line form.** A map `ℝ → W` with `W` countable and all level sets closed is
constant.

If the locally-constant part `U` is everything, `ℝ` is connected and `h` is constant outright.
Otherwise `Uᶜ` is a nonempty closed — hence complete, hence Baire — subspace covered by the
countably many closed traces of the level sets, so one trace has interior in `Uᶜ`: there is a
`t ∈ Uᶜ` and an `r > 0` with `Uᶜ ∩ (t-r, t+r) ⊆ S a`. A sup/inf argument then propagates the
value `a` across the *whole* of `(t-r, t+r)` — each point off `Uᶜ` is joined to the nearest
point of `Uᶜ` by an interval inside `U`, on which `const_of_preconnected` applies and whose
closed endpoint carries the value back. So `t ∈ U`, contradicting `t ∈ Uᶜ`.
-/
theorem const_of_isClosed_levels (hc : ∀ a, IsClosed (S h a)) : ∀ s t : ℝ, h s = h t := by
  by_contra hcon
  push Not at hcon
  obtain ⟨s₀, t₀, hne⟩ := hcon
  have hBclosed : IsClosed (U h)ᶜ := (isOpen_U h).isClosed_compl
  rcases Set.eq_empty_or_nonempty (U h)ᶜ with hBempty | hBne
  · have hUuniv : U h = Set.univ := Set.compl_empty_iff.mp hBempty
    exact hne (const_of_preconnected h isPreconnected_univ (by rw [hUuniv]) (Set.mem_univ t₀)
      s₀ (Set.mem_univ s₀))
  · haveI : Nonempty ((U h)ᶜ : Set ℝ) := hBne.to_subtype
    haveI : CompleteSpace ((U h)ᶜ : Set ℝ) := hBclosed.completeSpace_coe
    have hcov : (⋃ a : W, (Subtype.val ⁻¹' (S h a) : Set ((U h)ᶜ : Set ℝ))) = Set.univ := by
      ext x
      simp only [Set.mem_iUnion, Set.mem_preimage, Set.mem_univ, iff_true]
      exact ⟨h x.1, rfl⟩
    have hclosed : ∀ a : W, IsClosed (Subtype.val ⁻¹' (S h a) : Set ((U h)ᶜ : Set ℝ)) :=
      fun a => (hc a).preimage continuous_subtype_val
    obtain ⟨a, tB, htint⟩ := nonempty_interior_of_iUnion_of_closed hclosed hcov
    rw [mem_interior_iff_mem_nhds, Metric.mem_nhds_iff] at htint
    obtain ⟨r, hr, hball⟩ := htint
    set t : ℝ := tB.1 with htdef
    have htB : t ∉ U h := tB.2
    have hkey : ∀ x : ℝ, x ∉ U h → |x - t| < r → h x = a := by
      intro x hxB hxd
      refine (mem_S h).mp (hball (show dist (⟨x, hxB⟩ : ((U h)ᶜ : Set ℝ)) tB < r from ?_))
      rw [Subtype.dist_eq, Real.dist_eq]; exact hxd
    have hta : h t = a := hkey t htB (by simpa using hr)
    have hmain : ∀ x ∈ Set.Ioo (t - r) (t + r), h x = a := by
      intro x hx
      by_cases hxB : x ∉ U h
      · exact hkey x hxB (by rw [abs_lt]; exact ⟨by linarith [hx.1], by linarith [hx.2]⟩)
      · push Not at hxB
        rcases lt_trichotomy x t with hlt | heq | hgt
        · have hKclosed : IsClosed ((U h)ᶜ ∩ Set.Icc x t) := hBclosed.inter isClosed_Icc
          have hKne : ((U h)ᶜ ∩ Set.Icc x t).Nonempty := ⟨t, htB, le_of_lt hlt, le_refl t⟩
          have hKbdd : BddBelow ((U h)ᶜ ∩ Set.Icc x t) := ⟨x, fun y hy => hy.2.1⟩
          set c := sInf ((U h)ᶜ ∩ Set.Icc x t) with hcdef
          have hcK : c ∈ (U h)ᶜ ∩ Set.Icc x t := hKclosed.csInf_mem hKne hKbdd
          have hcB : c ∉ U h := hcK.1
          have hxc : x < c := lt_of_le_of_ne hcK.2.1 (fun hh => hcB (by rw [← hh]; exact hxB))
          have hct : c ≤ t := hcK.2.2
          have hca : h c = a := hkey c hcB (by rw [abs_lt]; exact ⟨by linarith [hx.1], by linarith⟩)
          have hIco : Set.Ico x c ⊆ U h := by
            intro y hy
            by_contra hyU
            exact absurd hy.2 (not_lt.mpr (csInf_le hKbdd ⟨hyU, hy.1,
              le_trans (le_of_lt hy.2) hct⟩))
          have hconst := const_of_preconnected h isPreconnected_Ico hIco
            (⟨le_refl x, hxc⟩ : x ∈ Set.Ico x c)
          have hcclos : c ∈ closure (Set.Ico x c) := by
            rw [closure_Ico (ne_of_lt hxc)]; exact ⟨le_of_lt hxc, le_refl c⟩
          have hmem : c ∈ S h (h x) :=
            (hc (h x)).closure_subset_iff.mpr (fun y hy => hconst y hy) hcclos
          exact ((mem_S h).mp hmem).symm.trans hca
        · rw [heq]; exact hta
        · have hKclosed : IsClosed ((U h)ᶜ ∩ Set.Icc t x) := hBclosed.inter isClosed_Icc
          have hKne : ((U h)ᶜ ∩ Set.Icc t x).Nonempty := ⟨t, htB, le_refl t, le_of_lt hgt⟩
          have hKbdd : BddAbove ((U h)ᶜ ∩ Set.Icc t x) := ⟨x, fun y hy => hy.2.2⟩
          set c := sSup ((U h)ᶜ ∩ Set.Icc t x) with hcdef
          have hcK : c ∈ (U h)ᶜ ∩ Set.Icc t x := hKclosed.csSup_mem hKne hKbdd
          have hcB : c ∉ U h := hcK.1
          have hct : t ≤ c := hcK.2.1
          have hcx : c < x := lt_of_le_of_ne hcK.2.2 (fun hh => hcB (by rw [hh]; exact hxB))
          have hca : h c = a := hkey c hcB (by rw [abs_lt]; exact ⟨by linarith, by linarith [hx.2]⟩)
          have hIoc : Set.Ioc c x ⊆ U h := by
            intro y hy
            by_contra hyU
            exact absurd hy.1
              (not_lt.mpr (le_csSup hKbdd ⟨hyU, le_trans hct (le_of_lt hy.1), hy.2⟩))
          have hconst := const_of_preconnected h isPreconnected_Ioc hIoc
            (⟨hcx, le_refl x⟩ : x ∈ Set.Ioc c x)
          have hcclos : c ∈ closure (Set.Ioc c x) := by
            rw [closure_Ioc (ne_of_lt hcx)]; exact ⟨le_refl c, le_of_lt hcx⟩
          have hmem : c ∈ S h (h x) :=
            (hc (h x)).closure_subset_iff.mpr (fun y hy => hconst y hy) hcclos
          exact ((mem_S h).mp hmem).symm.trans hca
    exact htB ((mem_U_iff h).mpr (by
      rw [hta]
      exact mem_interior.mpr ⟨Set.Ioo (t - r) (t + r), fun y hy => (mem_S h).mpr (hmain y hy),
        isOpen_Ioo, ⟨by linarith, by linarith⟩⟩))

/-- **Countable-range form.** Only the *range* has to be countable, not the codomain. -/
theorem const_of_countable_range {V : Type} (f : ℝ → V) (hcount : (Set.range f).Countable)
    (hcl : ∀ a : V, IsClosed (S f a)) : ∀ s t : ℝ, f s = f t := by
  haveI : Countable (Set.range f) := hcount.to_subtype
  have hlev : ∀ a : (Set.range f),
      IsClosed (S (fun t : ℝ => (⟨f t, ⟨t, rfl⟩⟩ : Set.range f)) a) := by
    intro a
    have hset : S (fun t : ℝ => (⟨f t, ⟨t, rfl⟩⟩ : Set.range f)) a = S f a.1 := by
      ext t; exact ⟨fun hh => congrArg Subtype.val hh, fun hh => Subtype.ext hh⟩
    rw [hset]; exact hcl a.1
  intro s t
  exact congrArg Subtype.val (const_of_isClosed_levels _ hlev s t)

end Sierp

/-! ## The frame-level consequences over ℝ -/

noncomputable abbrev RO : TemporalOrder := TemporalOrder.of ℝ

variable (F : FrameOver RO)

/--
**Level sets of a world history are closed — from *Limit* alone.**

`def:frame#Limit` gives, for each pair `a ≠ b`, a radius `r > 0` with no task of duration
`|y| < r` from `b` to `a`. `def:world-history`'s `respects_task` then keeps every time within
`r` of a `b`-time out of the `a`-level set.
-/
theorem levels_closed (τ : WorldHistory F.toTaskFrame) (a : F.WorldState) :
    IsClosed {t : ℝ | τ.state t = a} := by
  rw [← isOpen_compl_iff, Metric.isOpen_iff]
  intro t ht
  have hne : a ≠ τ.state t := fun hh => ht hh.symm
  have hnot : ¬ (∀ x : ℝ, 0 < x → ∃ y, |y| < x ∧ F.TaskRel (τ.state t) y a) :=
    fun hh => hne (F.limit _ _ hh)
  push Not at hnot
  obtain ⟨r, hr, hrad⟩ := hnot
  refine ⟨r, hr, ?_⟩
  intro s hs
  simp only [Metric.mem_ball, Real.dist_eq] at hs
  intro hsa
  have hrel : F.TaskRel (τ.state t) (s - t) (τ.state s) := τ.respects_task t s
  rw [(hsa : τ.state s = a)] at hrel
  exact (hrad (s - t) hs) hrel

/--
**`thm:extension` at the two-point partial history `{⟨0, w⟩, ⟨x, u⟩}`** (`x ≠ 0`): every task is
realized by a total history. The domain `{0, x}` is not convex, so this is `thm:extension` and
not `cor:occurrence`; the construction is the one already used by
`Semantics/DeterministicBridge.lean`'s `deterministic_of_singletonClasses`.
-/
theorem exists_history (w u : F.WorldState) (x : ℝ) (hx : x ≠ 0) (hR : F.TaskRel w x u) :
    ∃ σ : WorldHistory F.toTaskFrame, σ.state 0 = w ∧ σ.state x = u := by
  have hne0 : ¬ ((0 : ℝ) = x) := fun h0 => hx h0.symm
  have h0x : (if (0 : ℝ) = x then u else w) = w := if_neg hne0
  have hxx : (if x = x then u else w) = u := if_pos rfl
  have hresp : ∀ (s t : ℝ), (s = 0 ∨ s = x) → (t = 0 ∨ t = x) →
      F.TaskRel (if s = x then u else w) (t - s) (if t = x then u else w) := by
    intro s t hs ht
    rcases hs with hs | hs <;> rcases ht with ht | ht <;> rw [hs, ht]
    · rw [h0x, sub_zero]; exact (F.nullity_identity w w).mpr rfl
    · rw [h0x, hxx, sub_zero]; exact hR
    · rw [h0x, hxx, zero_sub]; exact (F.reflection w x u).mp hR
    · rw [hxx, sub_self]; exact (F.nullity_identity u u).mpr rfl
  obtain ⟨σ, hext⟩ := PartialHistory.extension F.toTaskFrame
    { domain := fun t => t = 0 ∨ t = x
      nonempty_domain := ⟨0, Or.inl rfl⟩
      states := fun t _ => if t = x then u else w
      respects_task := fun s t hs ht => hresp s t hs ht }
  exact ⟨σ, (hext.agree 0 (Or.inl rfl)).trans h0x, (hext.agree x (Or.inr rfl)).trans hxx⟩

/-- **Every world history over `ℝ` whose range is countable is constant.** The sharp form: it is
the range, not the carrier, that has to be countable. -/
theorem constant_of_countable_range (τ : WorldHistory F.toTaskFrame)
    (hcount : (Set.range τ.state).Countable) : ∀ s t : ℝ, τ.state s = τ.state t :=
  Sierp.const_of_countable_range τ.state hcount (levels_closed F τ)

/--
**Q2, CONFIRMED: over `ℝ`, a countable carrier forces a static frame.**

No finiteness and no uniform dwell time. The axioms consumed: *Saturation* (through
`thm:extension`, which is where Zorn enters), *Limit* (for closed level sets), *Seriality* plus
the reflection law (for the positive half of `Static`), and from *Compositionality* only what
`thm:extension` itself needs. Density and the Archimedean property of the duration order are
NOT used; Dedekind completeness (via Baire) replaces them.
-/
theorem static_of_countable [Countable F.WorldState] : Static F.TaskRel := by
  have fwd : ∀ w x u, F.TaskRel w x u → w = u := by
    intro w x u hR
    by_cases hx : x = 0
    · subst hx; exact (F.nullity_identity w u).mp hR
    · obtain ⟨σ, h0, hxu⟩ := exists_history F w u x hx hR
      have hcst := constant_of_countable_range F σ (Set.to_countable _) 0 x
      rw [h0, hxu] at hcst; exact hcst
  intro w x u
  refine ⟨fwd w x u, ?_⟩
  rintro rfl
  rcases le_total (0 : ℝ) x with hx | hx
  · obtain ⟨⟨v, hv⟩, _⟩ := F.serial w x hx
    have hh := fwd w x v hv
    subst hh; exact hv
  · obtain ⟨⟨v, hv⟩, _⟩ := F.serial w (-x) (neg_nonneg.mpr hx)
    have hh := fwd w (-x) v hv
    subst hh
    exact (F.reflection w x w).mpr hv

/-- **Q3, the exact claim that IS settled: a non-constant history over `ℝ` has uncountable
range.** (The stronger "some history is injective on an interval" is NOT settled — see the
report.) -/
theorem range_uncountable_of_nonconstant (τ : WorldHistory F.toTaskFrame) {s t : ℝ}
    (h : τ.state s ≠ τ.state t) : ¬ (Set.range τ.state).Countable :=
  fun hc => h (constant_of_countable_range F τ hc s t)

/--
**Q3, the local-clock theorem.** At a time where a history is not locally constant, *every*
time-window already carries uncountably many world states.

The window is reached without leaving `ℝ`: compose the history with the continuous retraction
of `ℝ` onto `[t-r, t+r]`. Its level sets are still closed and its range is the window's image,
so if that image were countable the Sierpiński collapse would make the history constant on the
window — i.e. locally constant at `t`.
-/
theorem uncountable_image_of_not_localConst (τ : WorldHistory F.toTaskFrame) {t : ℝ}
    (ht : t ∉ Sierp.U τ.state) {r : ℝ} (hr : 0 < r) :
    ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := by
  intro hcount
  set p : ℝ → ℝ := fun s => max (t - r) (min (t + r) s) with hp
  have hpcont : Continuous p := continuous_const.max (continuous_const.min continuous_id)
  have hpmem : ∀ s, p s ∈ Set.Icc (t - r) (t + r) :=
    fun s => ⟨le_max_left _ _, max_le (by linarith) (min_le_left _ _)⟩
  have hrange : (Set.range (τ.state ∘ p)).Countable := by
    refine Set.Countable.mono ?_ hcount
    rintro _ ⟨s, rfl⟩
    exact ⟨p s, hpmem s, rfl⟩
  have hclosed : ∀ a, IsClosed (Sierp.S (τ.state ∘ p) a) :=
    fun a => (levels_closed F τ a).preimage hpcont
  have hconst := Sierp.const_of_countable_range (τ.state ∘ p) hrange hclosed
  refine ht ((Sierp.mem_U_iff τ.state).mpr (mem_interior.mpr
    ⟨Set.Ioo (t - r) (t + r), ?_, isOpen_Ioo, ⟨by linarith, by linarith⟩⟩))
  intro y hy
  have h1 : p y = y := by
    rw [hp]
    simp only
    rw [min_eq_right (le_of_lt hy.2), max_eq_right (le_of_lt hy.1)]
  have h2 : p t = t := by
    rw [hp]
    simp only
    rw [min_eq_right (by linarith), max_eq_right (by linarith)]
  have hyt := hconst y t
  simp only [Function.comp_apply, h1, h2] at hyt
  exact hyt

/--
**Q3, assembled: a non-constant history over `ℝ` reads a clock somewhere.** There is a time `t`
such that every window `[t-r, t+r]`, however short, carries uncountably many world states.

This is the exact sense in which a non-static frame over `ℝ` must "contain a clock". The
stronger reading — that some history is *injective* on an interval — is NOT proved here and is
recorded UNVERIFIED in the report.
-/
theorem exists_local_clock (τ : WorldHistory F.toTaskFrame) {s₀ t₀ : ℝ}
    (hne : τ.state s₀ ≠ τ.state t₀) :
    ∃ t : ℝ, ∀ r : ℝ, 0 < r → ¬ (τ.state '' Set.Icc (t - r) (t + r)).Countable := by
  have hB : ((Sierp.U τ.state)ᶜ : Set ℝ).Nonempty := by
    rcases Set.eq_empty_or_nonempty ((Sierp.U τ.state)ᶜ) with he | hne'
    · exact absurd (Sierp.const_of_preconnected τ.state isPreconnected_univ
        (by rw [Set.compl_empty_iff.mp he]) (Set.mem_univ t₀) s₀ (Set.mem_univ s₀)) hne
    · exact hne'
  obtain ⟨t, ht⟩ := hB
  exact ⟨t, fun r hr => uncountable_image_of_not_localConst F τ ht hr⟩

end Probe
