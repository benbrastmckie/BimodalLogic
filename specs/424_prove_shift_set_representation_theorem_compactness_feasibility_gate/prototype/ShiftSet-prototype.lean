import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Extension.Extension

open FormalSystem.Semantics FormalSystem.Syntax

structure ShiftSet (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] where
  Carrier : Type
  carrier_nonempty : Nonempty Carrier
  sh : Carrier → D → Carrier
  sh_zero : ∀ w, sh w 0 = w
  sh_add : ∀ w a b, sh (sh w a) b = sh w (a + b)
  sep : ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ u = sh w y) → u = w
  A : Atom → Carrier → Prop

namespace ShiftSet

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

theorem sh_neg (S : ShiftSet D) (w : S.Carrier) (d : D) : S.sh (S.sh w d) (-d) = w := by
  rw [S.sh_add, add_neg_cancel, S.sh_zero]

theorem sh_neg' (S : ShiftSet D) (w : S.Carrier) (d : D) : S.sh (S.sh w (-d)) d = w := by
  rw [S.sh_add, neg_add_cancel, S.sh_zero]

def frame (S : ShiftSet D) : TaskFrame D where
  WorldState := S.Carrier
  nonempty := S.carrier_nonempty
  TaskRel := fun w d u => u = S.sh w d
  nullity_identity := by intro w u; rw [S.sh_zero]; exact eq_comm
  comp := by
    intro w v x y _ _
    constructor
    · intro h
      refine ⟨S.sh w x, rfl, ?_⟩
      show v = S.sh (S.sh w x) y
      rw [S.sh_add]; exact h
    · rintro ⟨u, rfl, rfl⟩
      show S.sh (S.sh w x) y = S.sh w (x + y)
      rw [S.sh_add]
  converse := by
    intro w d u
    constructor
    · rintro rfl; show w = S.sh (S.sh w d) (-d); rw [S.sh_neg]
    · rintro rfl; show u = S.sh (S.sh u (-d)) d; rw [S.sh_neg']
  serial := by
    intro w x _
    refine ⟨⟨S.sh w x, rfl⟩, ⟨S.sh w (-x), ?_⟩⟩
    show w = S.sh (S.sh w (-x)) x
    rw [S.sh_neg']
  limit := S.sep
  spherical := by
    intro Sfam hdir hmem
    obtain ⟨s, hs⟩ := hdir.1
    obtain ⟨a, ha⟩ := (hmem s hs).2
    have hsingle : ∀ (c : Set S.Carrier), (TaskFrame.IsFiber (fun w d u => u = S.sh w d) c ∨
        TaskFrame.IsSegment (fun w d u => u = S.sh w d) c) → ∀ p ∈ c, ∀ q ∈ c, p = q := by
      rintro c (⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩) p hp q hq
      · exact hp.trans hq.symm
      · exact hp.1.trans hq.1.symm
    refine ⟨a, fun t ht => ?_⟩
    obtain ⟨S', hS', hsub⟩ := hdir.2 s hs t ht
    obtain ⟨b, hb⟩ := (hmem S' hS').2
    rw [hsingle s (hmem s hs).1 a ha b (hsub hb).1]
    exact (hsub hb).2

/-- The induced total history through `w`. -/
def hist (S : ShiftSet D) (w : S.Carrier) : WorldHistory S.frame where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => S.sh w t
  respects_task := by
    intro s t _ _
    show S.sh w t = S.sh (S.sh w s) (t - s)
    rw [S.sh_add, add_sub_cancel]
  convex := by intros; trivial

theorem hist_isTotal (S : ShiftSet D) (w : S.Carrier) : (S.hist w).IsTotal := fun _ => trivial

def model (S : ShiftSet D) : TaskModel S.frame where
  valuation := fun w p => S.A p w

/-- Local copy of history extensionality. -/
theorem wh_ext {F : TaskFrame D} {σ τ : WorldHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : D) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨⟨d₁, n₁, s₁, t₁⟩, c₁⟩ := σ
  obtain ⟨⟨d₂, n₂, s₂, t₂⟩, c₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by funext r h; exact hs r h h
  subst this
  rfl

/-- **New forward obligation**: the constructed frame's total histories are exactly the
shift orbits. -/
theorem total_eq_orbit (S : ShiftSet D) (σ : WorldHistory S.frame) (hσ : σ.IsTotal) :
    σ = S.hist (σ.states 0 (hσ 0)) := by
  refine wh_ext (funext fun z => propext ⟨fun _ => trivial, fun _ => hσ z⟩) ?_
  intro r h h'
  have := σ.respects_task 0 r (hσ 0) h
  rw [sub_zero] at this
  exact this

/-- Truth on a shift set, with `box` ranging over the whole carrier. -/
def ShiftTruth (S : ShiftSet D) : S.Carrier → D → Formula → Prop
  | w, t, Formula.atom p => S.A p (S.sh w t)
  | _, _, Formula.bot => False
  | w, t, Formula.imp φ ψ => ShiftTruth S w t φ → ShiftTruth S w t ψ
  | _, t, Formula.box φ => ∀ v : S.Carrier, ShiftTruth S v t φ
  | w, t, Formula.untl ψ φ => ∃ s : D, t < s ∧ ShiftTruth S w s φ ∧
      ∀ r : D, t < r → r < s → ShiftTruth S w r ψ
  | w, t, Formula.snce ψ φ => ∃ s : D, s < t ∧ ShiftTruth S w s φ ∧
      ∀ r : D, s < r → r < t → ShiftTruth S w r ψ

/-- **FORWARD DIRECTION**: truth in the induced task model is shift-set truth. -/
theorem forward_repr (S : ShiftSet D) (w : S.Carrier) (t : D) (φ : Formula) :
    TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ := by
  induction φ generalizing w t with
  | atom p => exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
  | bot => exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    exact ⟨fun h hψ => (ihχ w t).mp (h ((ihψ w t).mpr hψ)),
           fun h hψ => (ihχ w t).mpr (h ((ihψ w t).mp hψ))⟩
  | box ψ ih =>
    constructor
    · intro h v
      exact (ih v t).mp (h (S.hist v) (S.hist_isTotal v))
    · intro h σ hσ
      rw [total_eq_orbit S σ hσ]
      exact (ih _ t).mpr (h _)
  | untl ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mp he, fun r h1 h2 => (ihψ w r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mpr he, fun r h1 h2 => (ihψ w r).mpr (hg r h1 h2)⟩
  | snce ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mp he, fun r h1 h2 => (ihψ w r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ w s).mpr he, fun r h1 h2 => (ihψ w r).mpr (hg r h1 h2)⟩


/-! ## Reverse direction -/

theorem ts_zero {F : TaskFrame D} (σ : WorldHistory F) :
    WorldHistory.timeShift σ 0 = σ := by
  refine wh_ext (funext fun z => by simp [WorldHistory.timeShift]) ?_
  intro r h h'
  exact WorldHistory.states_eq_of_time_eq σ (r + 0) r (add_zero r) h h'

theorem ts_add {F : TaskFrame D} (σ : WorldHistory F) (a b : D) :
    WorldHistory.timeShift (WorldHistory.timeShift σ a) b = WorldHistory.timeShift σ (a + b) := by
  refine wh_ext (funext fun z => ?_) ?_
  · show σ.domain ((z + b) + a) = σ.domain (z + (a + b))
    rw [add_assoc, add_comm b a]
  · intro r h h'
    exact WorldHistory.states_eq_of_time_eq σ ((r + b) + a) (r + (a + b))
      (by rw [add_assoc, add_comm b a]) h h'

theorem rev_sep {F : TaskFrame D} (σ τ : F.HF)
    (h : ∀ x : D, 0 < x → ∃ y : D, |y| < x ∧ τ = σ.timeShift y) : τ = σ := by
  apply Subtype.ext
  refine wh_ext (funext fun z => propext ⟨fun _ => σ.property z, fun _ => τ.property z⟩) ?_
  intro t ht ht'
  refine F.limit (σ.val.states t ht') (τ.val.states t ht) ?_
  intro x hx
  obtain ⟨y, hy, hEq⟩ := h x hx
  refine ⟨y, hy, ?_⟩
  subst hEq
  have h2 := σ.val.respects_task t (t + y) ht' (σ.property (t + y))
  rw [add_sub_cancel_left] at h2
  exact h2

/-- **REVERSE DIRECTION**: every task model induces a shift set. -/
def ofModel (F : TaskFrame D) (M : TaskModel F) : ShiftSet D where
  Carrier := F.HF
  carrier_nonempty := PartialHistory.hF_nonempty F F.nonempty.some
  sh := TaskFrame.HF.timeShift
  sh_zero := by intro w; apply Subtype.ext; exact ts_zero w.val
  sh_add := by intro w a b; apply Subtype.ext; exact ts_add w.val a b
  sep := fun w u h => rev_sep w u h
  A := fun p τ => TruthAt M τ.val 0 (Formula.atom p)

/-- **REVERSE DIRECTION, truth correspondence.** -/
theorem reverse_repr (F : TaskFrame D) (M : TaskModel F) (τ : F.HF) (t : D) (φ : Formula) :
    ShiftTruth (ofModel F M) τ t φ ↔ TruthAt M τ.val t φ := by
  induction φ generalizing τ t with
  | atom p =>
    show TruthAt M ((TaskFrame.HF.timeShift τ t).val) 0 (Formula.atom p) ↔ _
    rw [TaskFrame.HF.timeShift_val]
    have := TimeShift.time_shift_preserves_truth M τ.val 0 t (Formula.atom p)
    rw [sub_zero] at this
    exact this
  | bot => exact Iff.rfl
  | imp ψ χ ihψ ihχ =>
    exact ⟨fun h hψ => (ihχ τ t).mp (h ((ihψ τ t).mpr hψ)),
           fun h hψ => (ihχ τ t).mpr (h ((ihψ τ t).mp hψ))⟩
  | box ψ ih =>
    constructor
    · intro h σ hσ
      exact (ih ⟨σ, hσ⟩ t).mp (h ⟨σ, hσ⟩)
    · intro h v
      exact (ih v t).mpr (h v.val v.property)
  | untl ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mp he, fun r h1 h2 => (ihψ τ r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mpr he, fun r h1 h2 => (ihψ τ r).mpr (hg r h1 h2)⟩
  | snce ψ χ ihψ ihχ =>
    constructor
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mp he, fun r h1 h2 => (ihψ τ r).mp (hg r h1 h2)⟩
    · rintro ⟨s, hs, he, hg⟩
      exact ⟨s, hs, (ihχ τ s).mpr he, fun r h1 h2 => (ihψ τ r).mpr (hg r h1 h2)⟩

end ShiftSet

#print axioms ShiftSet.forward_repr
#print axioms ShiftSet.reverse_repr
#print axioms ShiftSet.total_eq_orbit
