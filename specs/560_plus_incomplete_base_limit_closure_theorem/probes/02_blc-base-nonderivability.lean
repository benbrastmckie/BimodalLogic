import FormalSystem.Metalogic.Independence.CoarsenedModels

/-!
# Probe 02 (research for the Base incompleteness theorem): non-derivability of `blc` at `.Base`

Against the LIVE definitions. Parts: (C) the frame `eR` on `Option (Bool x Nat)` as a
`FrameOver (TemporalOrder.of Int)` with ALL fields including *Saturation*; walks <-> world
histories. (A) `PasteClosed`, the two purity congruences for `CTruthAt`, PS / US and their
reflected forms, and the soundness recursion from `PlusDerivable .Base []` to validity on every
paste-closed coarse model. (D) the image facts ported from the integer-time mirror, the coarse
model `eK`, `eK_pasteClosed`, `blc_cRefuted`, and `blc_not_plusDerivable_base`.
Sorry-free; same compile recipe as probe 01.
Axioms of `blc_not_plusDerivable_base`: `propext`, `Classical.choice`, `Quot.sound`.
-/

namespace Probe560
open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem FormalSystem.Semantics FormalSystem.Metalogic.Independence
open CTruth

abbrev EW := Option (Bool × ℕ)

def eR : EW → EW → Prop
  | none, _ => True
  | some _, none => False
  | some (_, k), some (c', k') => k' ≤ k ∧ (c' = true → k' < k)

def eπ : EW → Bool
  | none => false
  | some (c, _) => c

theorem eR_trans {x y z : EW} (h1 : eR x y) (h2 : eR y z) : eR x z := by
  rcases x with _ | ⟨c, k⟩
  · trivial
  · rcases y with _ | ⟨c1, k1⟩
    · exact h1.elim
    · rcases z with _ | ⟨c2, k2⟩
      · exact h2.elim
      · exact ⟨le_trans h2.1 h1.1, fun hc => lt_of_lt_of_le (h2.2 hc) h1.1⟩

theorem eR_dense {x z : EW} (h : eR x z) : ∃ y, eR x y ∧ eR y z := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial, trivial⟩
  · rcases z with _ | ⟨c2, k2⟩
    · exact h.elim
    · exact ⟨some (false, k), ⟨le_rfl, by simp⟩, h⟩

theorem eR_succ (x : EW) : ∃ y, eR x y := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial⟩
  · exact ⟨some (false, k), le_rfl, by simp⟩

/-- The two-sided presentation. -/
def eRel (w : EW) (d : ℤ) (u : EW) : Prop :=
  (d = 0 ∧ w = u) ∨ (0 < d ∧ eR w u) ∨ (d < 0 ∧ eR u w)

theorem eRel_zero {w u : EW} : eRel w 0 u ↔ w = u := by
  unfold eRel
  constructor
  · rintro (⟨_, h⟩ | ⟨h, _⟩ | ⟨h, _⟩)
    · exact h
    · omega
    · omega
  · exact fun h => Or.inl ⟨rfl, h⟩

theorem eRel_pos {w u : EW} {d : ℤ} (hd : 0 < d) : eRel w d u ↔ eR w u := by
  unfold eRel
  constructor
  · rintro (⟨h, _⟩ | ⟨_, h⟩ | ⟨h, _⟩)
    · omega
    · exact h
    · omega
  · exact fun h => Or.inr (Or.inl ⟨hd, h⟩)

theorem eRel_neg {w u : EW} {d : ℤ} (hd : d < 0) : eRel w d u ↔ eR u w := by
  unfold eRel
  constructor
  · rintro (⟨h, _⟩ | ⟨h, _⟩ | ⟨_, h⟩)
    · omega
    · omega
    · exact h
  · exact fun h => Or.inr (Or.inr ⟨hd, h⟩)

theorem eRel_reflection (w : EW) (d : ℤ) (u : EW) : eRel w d u ↔ eRel u (-d) w := by
  unfold eRel
  constructor
  · rintro (⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩)
    · exact Or.inl ⟨by omega, e.symm⟩
    · exact Or.inr (Or.inr ⟨by omega, e⟩)
    · exact Or.inr (Or.inl ⟨by omega, e⟩)
  · rintro (⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩)
    · exact Or.inl ⟨by omega, e.symm⟩
    · exact Or.inr (Or.inr ⟨by omega, e⟩)
    · exact Or.inr (Or.inl ⟨by omega, e⟩)

theorem eRel_serial : TaskFrame.Serial (D := TemporalOrder.of ℤ) eRel := by
  intro w x hx
  have hx' : (0 : ℤ) ≤ x := hx
  rcases hx'.eq_or_lt with h | h
  · subst h
    exact ⟨⟨w, eRel_zero.mpr rfl⟩, ⟨w, eRel_zero.mpr rfl⟩⟩
  · obtain ⟨y, hy⟩ := eR_succ w
    exact ⟨⟨y, (eRel_pos h).mpr hy⟩, ⟨none, (eRel_pos h).mpr trivial⟩⟩

theorem eRel_comp : TaskFrame.Compositional (D := TemporalOrder.of ℤ) eRel := by
  intro w v x y hx hy
  have hx' : (0 : ℤ) ≤ x := hx
  have hy' : (0 : ℤ) ≤ y := hy
  change eRel w ((x : ℤ) + y) v ↔ ∃ u, eRel w (x : ℤ) u ∧ eRel u (y : ℤ) v
  rcases hx'.eq_or_lt with h | h
  · subst h
    rw [zero_add]
    exact ⟨fun h => ⟨w, eRel_zero.mpr rfl, h⟩, fun ⟨u, h1, h2⟩ => (eRel_zero.mp h1) ▸ h2⟩
  · rcases hy'.eq_or_lt with h' | h'
    · subst h'
      rw [add_zero]
      exact ⟨fun h => ⟨v, h, eRel_zero.mpr rfl⟩, fun ⟨u, h1, h2⟩ => (eRel_zero.mp h2) ▸ h1⟩
    · rw [eRel_pos (add_pos h h')]
      constructor
      · intro hr
        obtain ⟨u, h1, h2⟩ := eR_dense hr
        exact ⟨u, (eRel_pos h).mpr h1, (eRel_pos h').mpr h2⟩
      · rintro ⟨u, h1, h2⟩
        exact eR_trans ((eRel_pos h).mp h1) ((eRel_pos h').mp h2)

theorem eRel_limit :
    ∀ w u, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ eRel w y u) → u = w :=
  TaskFrame.limit_of_succOrder (D := ℤ) fun _ _ h => (eRel_zero.mp h).symm

/-! ### Saturation -/

/-- A `⊇`-directed family of nonempty sets with one finite member has nonempty intersection. -/
theorem sInter_nonempty_of_directed_of_finite_mem {W : Type} {S : Set (Set W)}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂) (hne : ∀ s ∈ S, s.Nonempty)
    {s₀ : Set W} (h₀ : s₀ ∈ S) (hfin : s₀.Finite) : (⋂₀ S).Nonempty := by
  classical
  have hex : ∃ n : ℕ, ∃ s ∈ S, s.Finite ∧ Set.ncard s = n := ⟨_, s₀, h₀, hfin, rfl⟩
  obtain ⟨Sstar, hStarMem, hStarFin, hStarCard⟩ := Nat.find_spec hex
  refine TaskFrame.sInter_nonempty_of_directed_of_minimal hd hne hStarMem ?_
  intro T hT hsub
  have hTfin : T.Finite := hStarFin.subset hsub
  have hle : Set.ncard Sstar ≤ Set.ncard T := by
    rw [hStarCard]; exact Nat.find_le ⟨T, hT, hTfin, rfl⟩
  have heq : T = Sstar := Set.eq_of_subset_of_ncard_le hsub hle hStarFin
  rw [heq]

theorem eR_fwd_finite (c : Bool) (k : ℕ) : {u : EW | eR (some (c, k)) u}.Finite := by
  refine Set.Finite.subset
    ((Finset.univ (α := Bool) ×ˢ Finset.range (k + 1)).image some).finite_toSet ?_
  rintro (_ | ⟨c', k'⟩) hu
  · exact hu.elim
  · have : k' ≤ k := hu.1
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_product,
      Finset.mem_univ, true_and, Finset.mem_range]
    exact ⟨(c', k'), by omega, rfl⟩

theorem eRel_fib_hub_or_finite (w : EW) (d : ℤ) :
    none ∈ TaskFrame.Fib (D := TemporalOrder.of ℤ) eRel w d ∨
      (TaskFrame.Fib (D := TemporalOrder.of ℤ) eRel w d).Finite := by
  rcases lt_trichotomy d 0 with h | h | h
  · exact Or.inl ((eRel_neg h).mpr trivial)
  · subst h
    refine Or.inr (Set.Finite.subset (Set.finite_singleton w) ?_)
    intro u hu
    exact (eRel_zero.mp hu).symm
  · rcases w with _ | ⟨c, k⟩
    · exact Or.inl ((eRel_pos h).mpr trivial)
    · refine Or.inr (Set.Finite.subset (eR_fwd_finite c k) ?_)
      intro u hu
      exact (eRel_pos h).mp hu

theorem eRel_seg_hub_or_finite (w v : EW) (x y : ℤ) (hy : 0 ≤ y) :
    none ∈ TaskFrame.Seg (D := TemporalOrder.of ℤ) eRel w v x y ∨
      (TaskFrame.Seg (D := TemporalOrder.of ℤ) eRel w v x y).Finite := by
  rcases eRel_fib_hub_or_finite w x with h1 | h1
  · rcases hy.eq_or_lt with h | h
    · subst h
      refine Or.inr (Set.Finite.subset (Set.finite_singleton v) ?_)
      intro u hu
      have : eRel v (-0) u := hu.2
      rw [neg_zero] at this
      exact (eRel_zero.mp this).symm
    · exact Or.inl ⟨h1, (eRel_neg (by omega)).mpr trivial⟩
  · exact Or.inr (h1.subset Set.inter_subset_left)

theorem eRel_saturation : TaskFrame.Saturation (D := TemporalOrder.of ℤ) eRel := by
  intro S hdir hmem
  obtain ⟨_, hd⟩ := hdir
  have hne : ∀ s ∈ S, s.Nonempty := fun s hs => (hmem s hs).2
  by_cases hfin : ∃ s ∈ S, s.Finite
  · obtain ⟨s₀, h₀, hf⟩ := hfin
    exact sInter_nonempty_of_directed_of_finite_mem hd hne h₀ hf
  · refine ⟨none, fun s hs => ?_⟩
    rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, hy, rfl⟩
    · exact (eRel_fib_hub_or_finite w x).resolve_right fun h => hfin ⟨_, hs, h⟩
    · exact (eRel_seg_hub_or_finite w v x y hy).resolve_right fun h => hfin ⟨_, hs, h⟩

@[reducible] def eFrameOver : FrameOver (TemporalOrder.of ℤ) where
  WorldState := EW
  PosRel w x u := eRel w x u
  comp := TaskFrame.compositional_reflect_of_reflective eRel_reflection eRel_comp
  serial := TaskFrame.serial_reflect_of_reflective eRel_reflection eRel_serial
  limit := TaskFrame.limit_reflect_of_reflective eRel_reflection eRel_limit
  saturation := TaskFrame.saturation_reflect_of_reflective eRel_reflection eRel_saturation

@[reducible] def EF : TaskFrame := eFrameOver.toTaskFrame

theorem ef_taskRel_iff (w : EW) (d : ℤ) (u : EW) : EF.TaskRel w d u ↔ eRel w d u :=
  TaskFrame.reflect_restrict_iff (R := eRel) eRel_reflection

/-! ### Walks and world histories -/

def IsWalk (f : ℤ → EW) : Prop := ∀ n, eR (f n) (f (n + 1))

theorem isWalk_state (τ : WorldHistory EF) : IsWalk τ.state := by
  intro n
  have h := (ef_taskRel_iff _ _ _).mp (τ.respects_task n (n + 1))
  have e : (n + 1 - n : ℤ) = 1 := by omega
  change eRel (τ.state n) (n + 1 - n) (τ.state (n + 1)) at h
  rw [e] at h
  exact (eRel_pos one_pos).mp h

theorem walk_lt {f : ℤ → EW} (hf : IsWalk f) {s t : ℤ} (h : s < t) : eR (f s) (f t) := by
  have key : ∀ k : ℕ, eR (f s) (f (s + 1 + k)) := by
    intro k
    induction k with
    | zero => simpa using hf s
    | succ k ih =>
      have := hf (s + 1 + k)
      rw [show s + 1 + (k : ℤ) + 1 = s + 1 + ((k + 1 : ℕ) : ℤ) by push_cast; ring] at this
      exact eR_trans ih this
  have := key (t - s - 1).toNat
  rwa [show s + 1 + ((t - s - 1).toNat : ℤ) = t by omega] at this

def histOfWalk (f : ℤ → EW) (hf : IsWalk f) : WorldHistory EF :=
  WorldHistory.ofTotal EF f <| by
    intro s t
    refine (ef_taskRel_iff _ _ _).mpr ?_
    change eRel (f s) (t - s) (f t)
    rcases lt_trichotomy s t with h | h | h
    · exact (eRel_pos (sub_pos.mpr h)).mpr (walk_lt hf h)
    · subst h; rw [sub_self]; exact eRel_zero.mpr rfl
    · exact (eRel_neg (sub_neg.mpr h)).mpr (walk_lt hf h)

section PC
variable {F : TaskFrame}

/-- Image-level splice at equal `π`-class. -/
def PasteClosed (K : CoarseModel F) : Prop :=
  ∀ (ρ σ : WorldHistory F) (t : F.Duration), SameUnder K ρ σ t →
    ∃ η : WorldHistory F, (∀ s, s ≤ t → K.π (η.state s) = K.π (ρ.state s)) ∧
      (∀ s, t ≤ s → K.π (η.state s) = K.π (σ.state s))

theorem c_truth_congr_from (K : CoarseModel F) {φ : PlusFormula} (hφ : IsPureFuture φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration),
      (∀ s, t ≤ s → K.π (τ.state s) = K.π (σ.state s)) →
      (CTruthAt K τ t φ ↔ CTruthAt K σ t φ) := by
  induction hφ with
  | atom p => intro τ σ t hag; exact K.atom_inv_iff (hag t le_rfl) p
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ σ t hag; exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | untl _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ τ σ s fun r hr => hag r (le_trans hts.le hr))
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ τ σ r fun u hu => hag u (le_trans htr.le hu))

theorem c_truth_congr_upTo (K : CoarseModel F) {φ : PlusFormula} (hφ : IsPurePast φ) :
    ∀ (τ σ : WorldHistory F) (t : F.Duration),
      (∀ s, s ≤ t → K.π (τ.state s) = K.π (σ.state s)) →
      (CTruthAt K τ t φ ↔ CTruthAt K σ t φ) := by
  induction hφ with
  | atom p => intro τ σ t hag; exact K.atom_inv_iff (hag t le_rfl) p
  | bot => intros; exact Iff.rfl
  | imp _ _ ihφ ihψ => intro τ σ t hag; exact Iff.imp (ihφ τ σ t hag) (ihψ τ σ t hag)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro τ σ t hag
    exact forall_congr' fun ρ => imp_congr_left
      ⟨fun h => (hag t le_rfl).symm.trans h, fun h => (hag t le_rfl).trans h⟩
  | snce _ _ ihψ ihφ =>
    intro τ σ t hag
    exact exists_congr fun s => and_congr_right fun hst =>
      and_congr (ihφ τ σ s fun r hr => hag r (le_trans hr hst.le))
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ τ σ r fun u hu => hag u (le_trans hu hrt.le))

variable {K : CoarseModel F}

theorem c_paste (hK : PasteClosed K) (τ : WorldHistory F) (t : F.Duration)
    {φ ψ : PlusFormula} (hφ : IsPureFuture φ) (hψ : IsPurePast ψ) :
    CTruthAt K τ t (.imp (dstab φ) (.imp (dstab ψ) (dstab (φ.and ψ)))) := by
  intro h1 h2
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  obtain ⟨η, hup, hfrom⟩ := hK ρ σ t (hτρ.symm.trans hτσ)
  refine ⟨η, hτρ.trans (hup t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(c_truth_congr_from K hφ η σ t hfrom).mpr hφσ, (c_truth_congr_upTo K hψ η ρ t hup).mpr hψρ⟩

theorem c_paste' (hK : PasteClosed K) (τ : WorldHistory F) (t : F.Duration)
    {ψ φ : PlusFormula} (hψ : IsPurePast ψ) (hφ : IsPureFuture φ) :
    CTruthAt K τ t (.imp (dstab ψ) (.imp (dstab φ) (dstab (ψ.and φ)))) := by
  intro h2 h1
  rw [dstab_iff] at h1 h2 ⊢
  obtain ⟨σ, hτσ, hφσ⟩ := h1
  obtain ⟨ρ, hτρ, hψρ⟩ := h2
  obtain ⟨η, hup, hfrom⟩ := hK ρ σ t (hτρ.symm.trans hτσ)
  refine ⟨η, hτρ.trans (hup t le_rfl).symm, ?_⟩
  rw [and_iff]
  exact ⟨(c_truth_congr_upTo K hψ η ρ t hup).mpr hψρ, (c_truth_congr_from K hφ η σ t hfrom).mpr hφσ⟩

theorem c_untl_paste (hK : PasteClosed K) (τ : WorldHistory F) (t : F.Duration)
    {α φ : PlusFormula} (hα : IsPurePast α) (hφ : IsPureFuture φ) :
    CTruthAt K τ t (.imp (.untl α (dstab φ)) (dstab (.untl α φ))) := by
  rintro ⟨y, hty, hy, hguard⟩
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  obtain ⟨η, hup, hfrom⟩ := hK τ ρ y hτρ
  rw [dstab_iff]
  refine ⟨η, (hup t hty.le).symm, y, hty, (c_truth_congr_from K hφ η ρ y hfrom).mpr hφρ, ?_⟩
  intro r htr hry
  exact (c_truth_congr_upTo K hα η τ r fun s hs => hup s (le_trans hs hry.le)).mpr
    (hguard r htr hry)

theorem c_snce_paste (hK : PasteClosed K) (τ : WorldHistory F) (t : F.Duration)
    {α φ : PlusFormula} (hα : IsPureFuture α) (hφ : IsPurePast φ) :
    CTruthAt K τ t (.imp (.snce α (dstab φ)) (dstab (.snce α φ))) := by
  rintro ⟨y, hyt, hy, hguard⟩
  rw [dstab_iff] at hy
  obtain ⟨ρ, hτρ, hφρ⟩ := hy
  obtain ⟨η, hup, hfrom⟩ := hK ρ τ y hτρ.symm
  rw [dstab_iff]
  refine ⟨η, (hfrom t hyt.le).symm, y, hyt, (c_truth_congr_upTo K hφ η ρ y hup).mpr hφρ, ?_⟩
  intro r hyr hrt
  exact (c_truth_congr_from K hα η τ r fun s hs => hfrom s (le_trans hyr.le hs)).mpr
    (hguard r hyr hrt)

/-- Validity over every paste-closed coarse model. -/
def PCValid (φ : PlusFormula) : Prop :=
  ∀ (F : TaskFrame) (K : CoarseModel F), PasteClosed K → ∀ (τ : WorldHistory F) (t : F.Duration),
    CTruthAt K τ t φ

theorem plusAxiom_pcValid {φ : PlusFormula} (ax : PlusAxiom φ)
    (hb : ax.minFrameClass ≤ FrameClass.Base) : PCValid φ ∧ PCValid φ.reflectTime := by
  by_cases hn : PlusAxiom.IsNaive ax
  · exact ⟨fun F K _ => naiveAxiom_cValid ax hn hb F K,
      fun F K _ => naiveAxiom_cValid_reflect_time ax hn hb F K⟩
  · cases ax with
    | paste a0 a1 h0 h1 =>
      refine ⟨fun F K hK τ t => c_paste hK τ t h0 h1, ?_⟩
      simp only [PlusFormula.reflectTime, reflect_time_dstab, reflect_time_and]
      exact fun F K hK τ t => c_paste' hK τ t h0.reflectTime h1.reflectTime
    | untl_paste a0 a1 h0 h1 =>
      refine ⟨fun F K hK τ t => c_untl_paste hK τ t h0 h1, ?_⟩
      simp only [PlusFormula.reflectTime, reflect_time_dstab]
      exact fun F K hK τ t => c_snce_paste hK τ t h0.reflectTime h1.reflectTime
    | _ => exact absurd trivial hn

theorem plus_pcValid_and_reflect_time {φ : PlusFormula}
    (d : PlusDerivationTree FrameClass.Base [] φ) : PCValid φ ∧ PCValid φ.reflectTime := by
  match d with
  | .axiom _ _ h_ax h_fc => exact plusAxiom_pcValid h_ax h_fc
  | .assumption _ _ h_mem => exact absurd h_mem List.not_mem_nil
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := plus_pcValid_and_reflect_time d1
    have h2 := plus_pcValid_and_reflect_time d2
    exact ⟨fun F K hK τ t => (h1.1 F K hK τ t) (h2.1 F K hK τ t),
      fun F K hK τ t => (h1.2 F K hK τ t) (h2.2 F K hK τ t)⟩
  | .necessitation psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    exact ⟨fun F K hK _ t σ => h.1 F K hK σ t, fun F K hK _ t σ => h.2 F K hK σ t⟩
  | .temporal_necessitation psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    constructor
    · intro F K hK τ t
      rw [CTruth.allFuture_iff]
      intro s _
      exact h.1 F K hK τ s
    · intro F K hK τ t
      rw [reflect_time_all_future, CTruth.allPast_iff]
      intro s _
      exact h.2 F K hK τ s
  | .time_reflection psi' d' =>
    have h := plus_pcValid_and_reflect_time d'
    refine ⟨h.2, ?_⟩
    rw [reflect_time_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_term := PlusDerivationTree.height_ofWeakeningNil_lt d' h_sub
    exact plus_pcValid_and_reflect_time (d'.ofWeakeningNil h_sub)
termination_by d.height
decreasing_by
  all_goals first
    | exact PlusDerivationTree.mp_height_gt_left _ _
    | exact PlusDerivationTree.mp_height_gt_right _ _
    | omega
    | simp only [PlusDerivationTree.height]; omega

theorem not_plusDerivable_of_pcRefuted {φ : PlusFormula} (F : TaskFrame) (K : CoarseModel F)
    (hK : PasteClosed K) (τ : WorldHistory F) (t : F.Duration) (h : ¬ CTruthAt K τ t φ) :
    ¬ PlusDerivable FrameClass.Base [] φ :=
  fun ⟨d⟩ => h ((plus_pcValid_and_reflect_time d).1 F K hK τ t)


end PC

/-! ### Part D — image facts (ported from the ℤ-mirror), the coarse model, the refutation -/

def evFalse : Set (ℤ → Bool) := {β | ∃ m, ∀ k, m ≤ k → β k = false}

theorem eR_budget (σ : ℤ → EW) (hσ : IsWalk σ) (n : ℤ) (c : Bool) (k : ℕ)
    (h : σ n = some (c, k)) : ∀ j : ℕ, ∃ c' k', σ (n + j) = some (c', k') ∧ k' ≤ k := by
  intro j
  induction j with
  | zero => exact ⟨c, k, by simpa using h, le_rfl⟩
  | succ j ih =>
    obtain ⟨c', k', he, hk⟩ := ih
    have e := hσ (n + j)
    rw [he, show n + (j : ℤ) + 1 = n + ((j + 1 : ℕ) : ℤ) by push_cast; ring] at e
    cases h' : σ (n + ((j + 1 : ℕ) : ℤ)) with
    | none => rw [h'] at e; exact e.elim
    | some x =>
      obtain ⟨c'', k''⟩ := x
      rw [h'] at e
      exact ⟨c'', k'', rfl, le_trans e.1 hk⟩

theorem eR_evFalse_aux (σ : ℤ → EW) (hσ : IsWalk σ) :
    ∀ k : ℕ, ∀ n c, σ n = some (c, k) → ∃ m, ∀ j, m ≤ j → eπ (σ j) = false := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    intro n c h
    by_cases hex : ∃ j, n < j ∧ eπ (σ j) = true
    · obtain ⟨j, hj, hπ⟩ := hex
      obtain ⟨c1, k1, he1, hk1⟩ := eR_budget σ hσ n c k h (j - 1 - n).toNat
      have e := hσ (n + ((j - 1 - n).toNat : ℤ))
      rw [he1, show n + ((j - 1 - n).toNat : ℤ) + 1 = j by omega] at e
      cases h' : σ j with
      | none => rw [h'] at e; exact e.elim
      | some x =>
        obtain ⟨c2, k2⟩ := x
        rw [h'] at e hπ
        have hc2 : c2 = true := hπ
        exact ih k2 (lt_of_lt_of_le (e.2 hc2) hk1) j c2 h'
    · refine ⟨n + 1, fun j hj => ?_⟩
      by_contra hne
      exact hex ⟨j, by omega, by simpa using hne⟩

theorem eR_image_mem (σ : ℤ → EW) (hσ : IsWalk σ) : (fun n => eπ (σ n)) ∈ evFalse := by
  by_cases hall : ∀ n, σ n = none
  · exact ⟨0, fun j _ => by simp [hall j, eπ]⟩
  · push Not at hall
    obtain ⟨n, hn⟩ := hall
    cases h : σ n with
    | none => exact (hn h).elim
    | some x => obtain ⟨c, k⟩ := x; exact eR_evFalse_aux σ hσ k n c h

theorem mem_eR_image (β : ℤ → Bool) (hβ : β ∈ evFalse) :
    ∃ σ : ℤ → EW, IsWalk σ ∧ ∀ n, eπ (σ n) = β n := by
  obtain ⟨M, hM⟩ := hβ
  let cnt : ℤ → ℕ := fun n => ((Finset.Ioo n M).filter (fun m => β m = true)).card
  refine ⟨fun n => some (β n, cnt n), fun n => ?_, fun n => rfl⟩
  show cnt (n + 1) ≤ cnt n ∧ (β (n + 1) = true → cnt (n + 1) < cnt n)
  have hsub : (Finset.Ioo (n + 1) M).filter (fun m => β m = true) ⊆
      (Finset.Ioo n M).filter (fun m => β m = true) :=
    Finset.filter_subset_filter _ (Finset.Ioo_subset_Ioo (by omega) le_rfl)
  refine ⟨Finset.card_le_card hsub, fun hb => Finset.card_lt_card ⟨hsub, fun hrev => ?_⟩⟩
  have hlt : n + 1 < M := by
    by_contra hge
    have := hM (n + 1) (by omega)
    rw [this] at hb; exact Bool.false_ne_true hb
  have hmem : n + 1 ∈ (Finset.Ioo n M).filter (fun m => β m = true) := by
    simp [hb, hlt]
  have := hrev hmem
  simp at this

theorem hist_image_mem (τ : WorldHistory EF) : (fun n : ℤ => eπ (τ.state n)) ∈ evFalse :=
  eR_image_mem _ (isWalk_state τ)

theorem exists_hist_of_evFalse (β : ℤ → Bool) (hβ : β ∈ evFalse) :
    ∃ η : WorldHistory EF, ∀ n : ℤ, eπ (η.state n) = β n := by
  obtain ⟨f, hf, he⟩ := mem_eR_image β hβ
  exact ⟨histOfWalk f hf, he⟩

/-- The coarse model: `π` the Bool component, every atom read as the `true`-class. -/
def eK : CoarseModel EF where
  toModel := ⟨fun w _ => eπ w = true⟩
  Cls := Bool
  π := eπ
  atom_inv := fun {w u} h _ hv => by
    have h' : eπ w = eπ u := h
    show eπ u = true
    rw [← h']; exact hv

theorem eK_pasteClosed_aux (ρ σ : WorldHistory EF) (t : ℤ)
    (h : eπ (ρ.state t) = eπ (σ.state t)) :
    ∃ η : WorldHistory EF, (∀ s : ℤ, s ≤ t → eπ (η.state s) = eπ (ρ.state s)) ∧
      (∀ s : ℤ, t ≤ s → eπ (η.state s) = eπ (σ.state s)) := by
  obtain ⟨m, hm⟩ := hist_image_mem σ
  obtain ⟨η, he⟩ := exists_hist_of_evFalse
    (fun s => if s ≤ t then eπ (ρ.state s) else eπ (σ.state s))
    ⟨max m (t + 1), fun k hk => by
      have h1 : ¬ k ≤ t := by omega
      simp only [h1, if_false]
      exact hm k (by omega)⟩
  refine ⟨η, fun s hs => ?_, fun s hs => ?_⟩
  · rw [he s]; simp only [hs, if_true]
  · rw [he s]
    by_cases hst : s ≤ t
    · obtain rfl : s = t := le_antisymm hst hs
      simp only [le_refl, if_true]; exact h
    · simp only [hst, if_false]

theorem eK_pasteClosed : PasteClosed eK := fun ρ σ t h => eK_pasteClosed_aux ρ σ t h

def blc (p : Atom) : PlusFormula :=
  ((dstab (someFuture (.atom p))).and
      (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))).imp
    (dstab ((someFuture (.atom p)).and
      (allFuture ((PlusFormula.atom p).imp (someFuture (.atom p))))))

theorem blc_cRefuted (p : Atom) (τ : WorldHistory EF) (t : ℤ) : ¬ CTruthAt eK τ t (blc p) := by
  intro h
  have hyp : CTruthAt eK τ t ((dstab (someFuture (.atom p))).and
      (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))) := by
    rw [and_iff]
    constructor
    · obtain ⟨η, he⟩ := exists_hist_of_evFalse
        (fun n => if n = t + 1 then true else if n = t then eπ (τ.state t) else false)
        ⟨t + 2, fun k hk => by
          have h1 : k ≠ t + 1 := by omega
          have h2 : k ≠ t := by omega
          simp [h1, h2]⟩
      rw [dstab_iff]
      refine ⟨η, ?_, (someFuture_iff eK η t _).mpr ⟨t + 1, (show (t : ℤ) < t + 1 by omega), ?_⟩⟩
      · show eπ (τ.state t) = eπ (η.state t)
        rw [he t]; simp
      · show eπ (η.state (t + 1)) = true
        rw [he (t + 1)]; simp
    · intro ρ _
      rw [allFuture_iff]
      intro s _ hp
      have hp' : eπ (ρ.state s) = true := hp
      obtain ⟨η, he⟩ := exists_hist_of_evFalse
        (fun n => if n = s ∨ n = s + 1 then true else false)
        ⟨s + 2, fun k hk => by
          have h1 : k ≠ s := by omega
          have h2 : k ≠ s + 1 := by omega
          simp [h1, h2]⟩
      rw [dstab_iff]
      refine ⟨η, ?_, (someFuture_iff eK η s _).mpr ⟨s + 1, (show (s : ℤ) < s + 1 from Int.lt_succ s), ?_⟩⟩
      · show eπ (ρ.state s) = eπ (η.state s)
        rw [he s, hp']; simp
      · show eπ (η.state (s + 1)) = true
        rw [he (s + 1)]; simp
  have hc := h hyp
  rw [dstab_iff] at hc
  obtain ⟨ρ, _, hc⟩ := hc
  rw [and_iff] at hc
  obtain ⟨hF, hG⟩ := hc
  rw [someFuture_iff] at hF
  rw [allFuture_iff] at hG
  obtain ⟨m, hm⟩ := hist_image_mem ρ
  have key : ∀ j : ℕ, ∃ s : ℤ, t + j < s ∧ eπ (ρ.state s) = true := by
    intro j
    induction j with
    | zero =>
      obtain ⟨s, hs, hp⟩ := hF
      exact ⟨s, by simpa using hs, hp⟩
    | succ j ih =>
      obtain ⟨s, hs, hp⟩ := ih
      have hts : t < s := by omega
      obtain ⟨s', hs', hp'⟩ := (someFuture_iff eK ρ s _).mp (hG s hts hp)
      have hs'' : s < s' := hs'
      exact ⟨s', by push_cast; omega, hp'⟩
  obtain ⟨s, hs, hp⟩ := key (m - t).toNat
  have hf : eπ (ρ.state s) = false := hm s (by omega)
  rw [hf] at hp
  exact Bool.false_ne_true hp

/-- The non-derivability half of the headline. -/
theorem blc_not_plusDerivable_base (p : Atom) : ¬ PlusDerivable FrameClass.Base [] (blc p) := by
  obtain ⟨τ⟩ := PartialHistory.hF_nonempty EF (none : EW)
  exact not_plusDerivable_of_pcRefuted EF eK eK_pasteClosed τ (0 : ℤ) (blc_cRefuted p τ 0)

#print axioms blc_not_plusDerivable_base
end Probe560
