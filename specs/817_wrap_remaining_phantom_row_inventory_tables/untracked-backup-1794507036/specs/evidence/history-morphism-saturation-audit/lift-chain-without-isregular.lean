import FormalSystem.Semantics.HistoryMorphism

/-!
PROBE: restate the HistoryMorphism lift chain with the four `def:frame` constraints as
EXPLICIT hypotheses, and NO `IsRegular` instance on either frame.  If this file compiles,
*Saturation* is not consumed anywhere in the chain, and the base frame `F` needs only *Limit*.
-/

namespace Probe898

open FormalSystem.Semantics FormalSystem.ProofSystem

variable {D : TemporalOrder} {F' F : FrameOver D}

/-- `exists_preimage_step_neg` with *Limit* on each side instead of `[IsRegular]`. -/
theorem exists_preimage_step_neg_of_ne
    {f : F'.WorldState → F.WorldState}
    (hlim' : TaskFrame.Limit F'.TaskRel)
    (h : TwoWayBounded f)
    (a : F'.WorldState) (x : ↑D) (hx : x ≠ 0) (u : F.WorldState)
    (hu : F.TaskRel u x (f a)) :
    ∃ c : F'.WorldState, F'.TaskRel c x a ∧ f c = u := by
  obtain ⟨c, hc, hfc⟩ := h.step a (-x) u
    ((TaskFrame.reflect_reflection_of_ne (P := F.PosRel) hx).1 hu)
  exact ⟨c, (F'.reflection_of_limit hlim' c x a).2 hc, hfc⟩

open Classical in
private noncomputable def fwdSeq (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) : ℕ → F'.WorldState
  | 0 => a
  | k + 1 =>
      if h : ∃ b, F'.TaskRel (fwdSeq f δ w a k) δ b ∧ f b = w ((k : ℤ) + 1) then h.choose
      else fwdSeq f δ w a k

open Classical in
private noncomputable def bwdSeq (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) : ℕ → F'.WorldState
  | 0 => a
  | k + 1 =>
      if h : ∃ c, F'.TaskRel c δ (bwdSeq f δ w a k) ∧ f c = w (-(k : ℤ) - 1) then h.choose
      else bwdSeq f δ w a k

private theorem fwdSeq_spec {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    {δ : ↑D} (hδne : δ ≠ 0) {w : ℤ → F.WorldState}
    (hw : ∀ i : ℤ, F.TaskRel (w i) δ (w (i + 1)))
    {a : F'.WorldState} (ha : f a = w 0) (k : ℕ) :
    f (fwdSeq f δ w a k) = w (k : ℤ) ∧
      F'.TaskRel (fwdSeq f δ w a k) δ (fwdSeq f δ w a (k + 1)) := by
  have key : ∀ k : ℕ, f (fwdSeq f δ w a k) = w (k : ℤ) →
      ∃ b, F'.TaskRel (fwdSeq f δ w a k) δ b ∧ f b = w ((k : ℤ) + 1) := by
    intro k hk
    exact h.step _ δ _ (by rw [hk]; exact hw (k : ℤ))
  have hf : ∀ k : ℕ, f (fwdSeq f δ w a k) = w (k : ℤ) := by
    intro k
    induction k with
    | zero => simpa [fwdSeq] using ha
    | succ k ih =>
      have ex := key k ih
      have e : fwdSeq f δ w a (k + 1) = ex.choose := by
        simp only [fwdSeq]; rw [dif_pos ex]
      rw [e, ex.choose_spec.2]
      exact congrArg w (by omega)
  refine ⟨hf k, ?_⟩
  have ex := key k (hf k)
  have e : fwdSeq f δ w a (k + 1) = ex.choose := by
    simp only [fwdSeq]; rw [dif_pos ex]
  rw [e]; exact ex.choose_spec.1

private theorem bwdSeq_spec
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    {δ : ↑D} (hδne : δ ≠ 0) {w : ℤ → F.WorldState}
    (hw : ∀ i : ℤ, F.TaskRel (w i) δ (w (i + 1)))
    {a : F'.WorldState} (ha : f a = w 0) (k : ℕ) :
    f (bwdSeq f δ w a k) = w (-(k : ℤ)) ∧
      F'.TaskRel (bwdSeq f δ w a (k + 1)) δ (bwdSeq f δ w a k) := by
  have key : ∀ k : ℕ, f (bwdSeq f δ w a k) = w (-(k : ℤ)) →
      ∃ c, F'.TaskRel c δ (bwdSeq f δ w a k) ∧ f c = w (-(k : ℤ) - 1) := by
    intro k hk
    refine exists_preimage_step_neg_of_ne hlim' h _ δ hδne _ ?_
    rw [hk]
    have hi := hw (-(k : ℤ) - 1)
    rwa [show -(k : ℤ) - 1 + 1 = -(k : ℤ) by ring] at hi
  have hf : ∀ k : ℕ, f (bwdSeq f δ w a k) = w (-(k : ℤ)) := by
    intro k
    induction k with
    | zero => simpa [bwdSeq] using ha
    | succ k ih =>
      have ex := key k ih
      have e : bwdSeq f δ w a (k + 1) = ex.choose := by
        simp only [bwdSeq]; rw [dif_pos ex]
      rw [e, ex.choose_spec.2]
      congr 1
      push_cast
      ring
  refine ⟨hf k, ?_⟩
  have ex := key k (hf k)
  have e : bwdSeq f δ w a (k + 1) = ex.choose := by
    simp only [bwdSeq]; rw [dif_pos ex]
  rw [e]; exact ex.choose_spec.1

private noncomputable def chain (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) (i : ℤ) : F'.WorldState :=
  if 0 ≤ i then fwdSeq f δ w a i.toNat else bwdSeq f δ w a (-i).toNat

private theorem chain_of_nonneg (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) {i : ℤ} (hi : 0 ≤ i) :
    chain f δ w a i = fwdSeq f δ w a i.toNat := if_pos hi

private theorem chain_of_neg (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) {i : ℤ} (hi : i < 0) :
    chain f δ w a i = bwdSeq f δ w a (-i).toNat := if_neg (not_le.mpr hi)

private theorem chain_zero (f : F'.WorldState → F.WorldState) (δ : ↑D)
    (w : ℤ → F.WorldState) (a : F'.WorldState) : chain f δ w a 0 = a := by
  rw [chain_of_nonneg f δ w a le_rfl]; simp [fwdSeq]

private theorem chain_spec
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    {δ : ↑D} (hδne : δ ≠ 0) {w : ℤ → F.WorldState}
    (hw : ∀ i : ℤ, F.TaskRel (w i) δ (w (i + 1)))
    {a : F'.WorldState} (ha : f a = w 0) (i : ℤ) :
    f (chain f δ w a i) = w i := by
  rcases le_or_gt 0 i with hi | hi
  · rw [chain_of_nonneg f δ w a hi, (fwdSeq_spec h hδne hw ha i.toNat).1, Int.toNat_of_nonneg hi]
  · rw [chain_of_neg f δ w a hi, (bwdSeq_spec hlim' h hδne hw ha (-i).toNat).1,
      Int.toNat_of_nonneg (by omega : (0 : ℤ) ≤ -i), neg_neg]

private theorem chain_step
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    {δ : ↑D} (hδne : δ ≠ 0) {w : ℤ → F.WorldState}
    (hw : ∀ i : ℤ, F.TaskRel (w i) δ (w (i + 1)))
    {a : F'.WorldState} (ha : f a = w 0) (i : ℤ) :
    F'.TaskRel (chain f δ w a i) δ (chain f δ w a (i + 1)) := by
  rcases le_or_gt 0 i with hi | hi
  · rw [chain_of_nonneg f δ w a hi, chain_of_nonneg f δ w a (by omega : (0 : ℤ) ≤ i + 1),
      show (i + 1).toNat = i.toNat + 1 by omega]
    exact (fwdSeq_spec h hδne hw ha i.toNat).2
  · rcases lt_or_ge (i + 1) 0 with hlt | hge
    · rw [chain_of_neg f δ w a hi, chain_of_neg f δ w a hlt,
        show (-i).toNat = (-(i + 1)).toNat + 1 by omega]
      exact (bwdSeq_spec hlim' h hδne hw ha (-(i + 1)).toNat).2
    · rw [chain_of_neg f δ w a hi, chain_of_nonneg f δ w a hge,
        show (-i).toNat = 1 by omega, show (i + 1).toNat = 0 by omega]
      exact (bwdSeq_spec hlim' h hδne hw ha 0).2

private theorem chain_rel
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    {δ : ↑D} (hδ : 0 ≤ δ) (hδne : δ ≠ 0) {w : ℤ → F.WorldState}
    (hw : ∀ i : ℤ, F.TaskRel (w i) δ (w (i + 1)))
    {a : F'.WorldState} (ha : f a = w 0) (i j : ℤ) :
    F'.TaskRel (chain f δ w a i) ((j - i) • δ) (chain f δ w a j) := by
  have fwd : ∀ (m : ℕ) (i : ℤ),
      F'.TaskRel (chain f δ w a i) ((m : ℤ) • δ) (chain f δ w a (i + m)) := by
    intro m
    induction m with
    | zero =>
      intro i
      simpa using TaskFrame.nullity_of_serial_limit hser' hlim' (chain f δ w a i)
    | succ m ih =>
      intro i
      have h3 : F'.TaskRel (chain f δ w a i) ((m : ℤ) • δ + δ) (chain f δ w a (i + m + 1)) :=
        TaskFrame.forward_of_comp hcomp' _ _ _ _ _ (zsmul_nonneg hδ (by omega)) hδ (ih i)
          (chain_step hlim' h hδne hw ha (i + m))
      rw [show ((m + 1 : ℕ) : ℤ) • δ = (m : ℤ) • δ + δ by push_cast; rw [add_zsmul, one_zsmul],
        show i + ((m + 1 : ℕ) : ℤ) = i + m + 1 by push_cast; ring]
      exact h3
  rcases le_or_gt i j with hij | hij
  · have hi := fwd (j - i).toNat i
    rw [show i + (((j - i).toNat : ℤ)) = j by omega,
      show (((j - i).toNat : ℤ)) = j - i by omega] at hi
    exact hi
  · have hi := fwd (i - j).toNat j
    rw [show j + (((i - j).toNat : ℤ)) = i by omega,
      show (((i - j).toNat : ℤ)) = i - j by omega,
      show i - j = -(j - i) by ring, neg_zsmul] at hi
    exact (F'.reflection_of_limit hlim' _ _ _).2 hi

/-- `exists_histMorphism_of_isZTime` with explicit constraints, NO `IsRegular`, and
*Saturation* nowhere. -/
theorem exists_histMorphism_of_isZTime_of_constraints
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) :
    ∃ g : HistMorphism F' F, g.toFun = f := by
  classical
  obtain ⟨e, δ, hsmul, hδnonneg, hδne⟩ :
      ∃ (e : ↑D ≃+o ℤ) (δ : ↑D),
        (∀ m : ℤ, m • δ = e.symm m) ∧ (0 : ↑D) ≤ δ ∧ δ ≠ 0 := by
    refine ⟨intIso, (intIso (D := ↑D)).symm 1, fun m => ?_, ?_, ?_⟩
    · rw [← map_zsmul (intIso (D := ↑D)).symm m 1, zsmul_eq_mul, mul_one, Int.cast_id]
    · have h1 : (intIso (D := ↑D)).symm (0 : ℤ) ≤ (intIso (D := ↑D)).symm 1 :=
        OrderHomClass.monotone _ (by norm_num)
      rwa [map_zero] at h1
    · intro hz
      have : (1 : ℤ) = 0 := by
        have := congrArg (intIso (D := ↑D)) hz
        rwa [OrderAddMonoidIso.apply_symm_apply, map_zero] at this
      exact one_ne_zero this
  have key : ∀ (τ : WorldHistory F.toTaskFrame) (a : F'.WorldState) (t : ↑D),
      f a = τ.state t →
        ∃ τ' : WorldHistory F'.toTaskFrame,
          τ'.state t = a ∧ ∀ s, f (τ'.state s) = τ.state s := by
    intro τ a t ha
    have hsymm_add : ∀ i : ℤ, e.symm (i + 1) = e.symm i + δ := by
      intro i; rw [map_add, ← hsmul 1, one_zsmul]
    have hw : ∀ i : ℤ,
        F.TaskRel (τ.state (t + e.symm i)) δ (τ.state (t + e.symm (i + 1))) := by
      intro i
      have hr := τ.respects_task (t + e.symm i) (t + e.symm (i + 1))
      rwa [show t + e.symm (i + 1) - (t + e.symm i) = δ by rw [hsymm_add]; abel] at hr
    have ha0 : f a = (fun i : ℤ => τ.state (t + e.symm i)) 0 := by
      change f a = τ.state (t + e.symm 0)
      rw [map_zero, add_zero]; exact ha
    refine ⟨WorldHistory.ofTotal F'.toTaskFrame
      (fun n => chain f δ (fun i : ℤ => τ.state (t + e.symm i)) a (e (n - t))) ?_, ?_, ?_⟩
    · intro s u
      have hr := chain_rel hcomp' hser' hlim' h hδnonneg hδne hw ha0 (e (s - t)) (e (u - t))
      rwa [show (e (u - t) - e (s - t)) • δ = u - s by
        rw [hsmul, ← map_sub e, show u - t - (s - t) = u - s by abel,
          OrderAddMonoidIso.symm_apply_apply]] at hr
    · change chain f δ (fun i : ℤ => τ.state (t + e.symm i)) a (e (t - t)) = a
      rw [sub_self, map_zero, chain_zero]
    · intro s
      change f (chain f δ (fun i : ℤ => τ.state (t + e.symm i)) a (e (s - t))) = τ.state s
      rw [chain_spec hlim' h hδne hw ha0]
      change τ.state (t + e.symm (e (s - t))) = τ.state s
      rw [OrderAddMonoidIso.symm_apply_apply]
      congr 1
      abel
  refine ⟨⟨⟨f, h.forth, fun τ a t hat => key τ a t hat⟩, ?_⟩, rfl⟩
  intro τ
  obtain ⟨a, ha⟩ := hs (τ.state 0)
  obtain ⟨τ', _, hτ'⟩ := key τ a 0 ha
  exact ⟨τ', hτ'⟩

open FormalSystem.PlusLanguage in
/-- `plus_invariance_of_isZTime` with explicit constraints, NO `IsRegular`, Saturation nowhere. -/
theorem plus_invariance_of_isZTime_of_constraints
    [SuccOrder ↑D] [IsSuccArchimedean ↑D]
    (hcomp' : TaskFrame.Compositional F'.TaskRel) (hser' : TaskFrame.Serial F'.TaskRel)
    (hlim' : TaskFrame.Limit F'.TaskRel)
    {f : F'.WorldState → F.WorldState} (h : TwoWayBounded f)
    (hs : Function.Surjective f) (M : TaskModel F.toTaskFrame) :
    ∃ g : HistMorphism F' F, g.toFun = f ∧
      ∀ (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D),
        PlusTruthAt (g.pullM M) τ' t φ ↔ PlusTruthAt M (g.mapH τ') t φ := by
  obtain ⟨g, hg⟩ :=
    exists_histMorphism_of_isZTime_of_constraints hcomp' hser' hlim' h hs
  exact ⟨g, hg, fun φ τ' t => g.plus_invariance M φ τ' t⟩

end Probe898
