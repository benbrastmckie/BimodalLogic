import Mathlib

/-!
# Probes, round 03: two-way morphisms, the clock product, a sound naming rule, and the LC schema

Self-contained (Mathlib-only) ℤ-time mirror of `PlusTruthAt`, same conventions as probes 01/02
(the header below repeats their `Fm`/`T`/`fullModel`/`paste` verbatim so that this file compiles
alone with bare `lean`). Sorry-free. Contents:

* Part H — `TwoWay` (two-way bounded morphisms of digraphs), `lift_walk`, `tw_invariance`:
  truth in all-walks models is invariant under surjective two-way bounded morphisms. So world
  states CAN be split without changing `⊡`, provided the split keeps branching in both directions.
* Part K — the clock product `clockR`, `clock_twoWay`, `T_fresh`, and `clock_irr_sound`: the rule
  "from `(q ∧ □A(once q ∧ rigid q)) → φ` with `q` fresh infer `φ`" preserves validity over all
  (doubly serial) all-walks ℤ-models. `q` names a time *within each ⊡-cluster*.
* Part J — `coneR`, `cone_twoWay`, `aa_expand`: the forward-cone unravelling is a two-way bounded
  morphic preimage in which the forward cone of the current state is a tree, so Reynolds 2001's
  Auxiliary-Atoms labelling (a finite-state machine run from the current point) exists.
* Part I — `omega_limit`, `omega_chain` (the general ω-limit-of-splices principle, of which
  `limit_walk` and `limit_walkB` of probes 01/02 are instances) and `lcN_valid_full`: Reynolds
  2003's infinite LC schema, transposed to `⊡` with G≤, is valid on every all-walks ℤ-model,
  for every `n ≥ 1` and arbitrary parameter formulas.
-/

namespace Probe559c

/-- Mirror of `PlusFormula`. -/
inductive Fm : Type where
  | atom : ℕ → Fm
  | bot : Fm
  | imp : Fm → Fm → Fm
  | box : Fm → Fm
  | untl : Fm → Fm → Fm
  | snce : Fm → Fm → Fm
  | stab : Fm → Fm

namespace Fm
def neg (φ : Fm) : Fm := imp φ bot
def top : Fm := imp bot bot
def and (φ ψ : Fm) : Fm := neg (imp φ (neg ψ))
def or (φ ψ : Fm) : Fm := imp (neg φ) ψ
def someFuture (φ : Fm) : Fm := untl top φ
def allFuture (φ : Fm) : Fm := neg (someFuture (neg φ))
def somePast (φ : Fm) : Fm := snce top φ
def allPast (φ : Fm) : Fm := neg (somePast (neg φ))
def dstab (φ : Fm) : Fm := neg (stab (neg φ))
/-- `G≤`: now and always in the future. -/
def gle (φ : Fm) : Fm := and φ (allFuture φ)
/-- always: past, present and future. -/
def always (φ : Fm) : Fm := and (allPast φ) (and φ (allFuture φ))
end Fm

/-- A bundled ℤ-model: states `C`, valuation `V`, bundle `B` of state sequences. -/
structure BModel where
  C : Type
  V : C → ℕ → Prop
  B : Set (ℤ → C)

/-- Mirror of `PlusTruthAt`; `□` and `⊡` range over the bundle. -/
def T (M : BModel) (σ : ℤ → M.C) (t : ℤ) : Fm → Prop
  | .atom p => M.V (σ t) p
  | .bot => False
  | .imp φ ψ => T M σ t φ → T M σ t ψ
  | .box φ => ∀ ρ ∈ M.B, T M ρ t φ
  | .untl ψ φ => ∃ s, t < s ∧ T M σ s φ ∧ ∀ r, t < r → r < s → T M σ r ψ
  | .snce ψ φ => ∃ s, s < t ∧ T M σ s φ ∧ ∀ r, s < r → r < t → T M σ r ψ
  | .stab φ => ∀ ρ ∈ M.B, σ t = ρ t → T M ρ t φ

section Clauses
variable (M : BModel) (σ : ℤ → M.C) (t : ℤ)

theorem neg_iff (φ : Fm) : T M σ t φ.neg ↔ ¬ T M σ t φ := Iff.rfl

theorem and_iff (φ ψ : Fm) : T M σ t (φ.and ψ) ↔ T M σ t φ ∧ T M σ t ψ := by
  simp only [Fm.and, Fm.neg, T]; tauto

theorem or_iff (φ ψ : Fm) : T M σ t (φ.or ψ) ↔ T M σ t φ ∨ T M σ t ψ := by
  simp only [Fm.or, Fm.neg, T]; tauto

theorem dstab_iff (φ : Fm) :
    T M σ t φ.dstab ↔ ∃ ρ ∈ M.B, σ t = ρ t ∧ T M ρ t φ := by
  simp only [Fm.dstab, Fm.neg, T]
  constructor
  · intro h; by_contra hc; exact h fun ρ hρ he hφ => hc ⟨ρ, hρ, he, hφ⟩
  · rintro ⟨ρ, hρ, he, hφ⟩ h; exact h ρ hρ he hφ

theorem someFuture_iff (φ : Fm) : T M σ t φ.someFuture ↔ ∃ s, t < s ∧ T M σ s φ := by
  simp only [Fm.someFuture, Fm.top, T]
  constructor
  · rintro ⟨s, hs, h, -⟩; exact ⟨s, hs, h⟩
  · rintro ⟨s, hs, h⟩; exact ⟨s, hs, h, fun _ _ _ h => h⟩

theorem somePast_iff (φ : Fm) : T M σ t φ.somePast ↔ ∃ s, s < t ∧ T M σ s φ := by
  simp only [Fm.somePast, Fm.top, T]
  constructor
  · rintro ⟨s, hs, h, -⟩; exact ⟨s, hs, h⟩
  · rintro ⟨s, hs, h⟩; exact ⟨s, hs, h, fun _ _ _ h => h⟩

theorem allFuture_iff (φ : Fm) : T M σ t φ.allFuture ↔ ∀ s, t < s → T M σ s φ := by
  simp only [Fm.allFuture, Fm.someFuture, Fm.neg, Fm.top, T]
  constructor
  · intro h s hs; by_contra hc; exact h ⟨s, hs, hc, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hc, -⟩; exact hc (h s hs)

theorem allPast_iff (φ : Fm) : T M σ t φ.allPast ↔ ∀ s, s < t → T M σ s φ := by
  simp only [Fm.allPast, Fm.somePast, Fm.neg, Fm.top, T]
  constructor
  · intro h s hs; by_contra hc; exact h ⟨s, hs, hc, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hc, -⟩; exact hc (h s hs)

theorem gle_iff (φ : Fm) : T M σ t φ.gle ↔ ∀ s, t ≤ s → T M σ s φ := by
  rw [Fm.gle, and_iff, allFuture_iff]
  constructor
  · rintro ⟨h0, h1⟩ s hs
    rcases eq_or_lt_of_le hs with rfl | h
    · exact h0
    · exact h1 s h
  · intro h; exact ⟨h t le_rfl, fun s hs => h s hs.le⟩

theorem always_iff (φ : Fm) : T M σ t φ.always ↔ ∀ s, T M σ s φ := by
  rw [Fm.always, and_iff, and_iff, allFuture_iff, allPast_iff]
  constructor
  · rintro ⟨h0, h1, h2⟩ s
    rcases lt_trichotomy s t with h | rfl | h
    · exact h0 s h
    · exact h1
    · exact h2 s h
  · intro h; exact ⟨fun s _ => h s, h t, fun s _ => h s⟩

end Clauses

/-- A bi-infinite `R`-walk: over ℤ-time, exactly a world history of the task frame `⇒ₙ = Rⁿ`. -/
def IsWalk {W : Type} (R : W → W → Prop) (σ : ℤ → W) : Prop := ∀ n, R (σ n) (σ (n + 1))

/-- The full (all-histories) model of a digraph: the bundle is *every* walk. -/
abbrev fullModel {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) : BModel :=
  ⟨W, V, {σ | IsWalk R σ}⟩

/-- Doubly serial digraph: the ℤ-time content of *Seriality*. -/
def DS {W : Type} (R : W → W → Prop) : Prop := (∀ w, ∃ v, R w v) ∧ (∀ w, ∃ u, R u w)

/-- Splice: `ρ` up to and including `s`, `η` after `s`. -/
def paste {C : Type} (ρ η : ℤ → C) (s : ℤ) : ℤ → C := fun n => if n ≤ s then ρ n else η n

theorem paste_walk {W : Type} {R : W → W → Prop} {ρ η : ℤ → W} {s : ℤ}
    (hρ : IsWalk R ρ) (hη : IsWalk R η) (h : ρ s = η s) : IsWalk R (paste ρ η s) := by
  intro n
  simp only [paste]
  by_cases h1 : n + 1 ≤ s
  · rw [if_pos (by omega), if_pos h1]; exact hρ n
  · by_cases h2 : n ≤ s
    · rw [if_pos h2, if_neg h1]
      obtain rfl : n = s := by omega
      rw [h]; exact hη n
    · rw [if_neg h2, if_neg h1]; exact hη n

/-! ## Part H — two-way bounded morphisms and invariance -/

/-- A two-way bounded morphism of digraphs: homomorphism with forth AND back conditions. -/
structure TwoWay {W' W : Type} (R' : W' → W' → Prop) (R : W → W → Prop) (f : W' → W) : Prop where
  hom : ∀ a b, R' a b → R (f a) (f b)
  forth : ∀ a v, R (f a) v → ∃ b, R' a b ∧ f b = v
  back : ∀ a u, R u (f a) → ∃ c, R' c a ∧ f c = u

section Lift
variable {W' W : Type} {R' : W' → W' → Prop} {R : W → W → Prop} {f : W' → W}

open Classical in
/-- Forward half of a lift, by choice. -/
noncomputable def fwdSeq (R' : W' → W' → Prop) (f : W' → W) (ρ : ℤ → W) (t : ℤ) (a : W') : ℕ → W'
  | 0 => a
  | k + 1 =>
    if h : ∃ b, R' (fwdSeq R' f ρ t a k) b ∧ f b = ρ (t + k + 1) then h.choose
    else fwdSeq R' f ρ t a k

open Classical in
/-- Backward half of a lift, by choice. -/
noncomputable def bwdSeq (R' : W' → W' → Prop) (f : W' → W) (ρ : ℤ → W) (t : ℤ) (a : W') : ℕ → W'
  | 0 => a
  | k + 1 =>
    if h : ∃ c, R' c (bwdSeq R' f ρ t a k) ∧ f c = ρ (t - k - 1) then h.choose
    else bwdSeq R' f ρ t a k

theorem fwdSeq_spec (h : TwoWay R' R f) {ρ : ℤ → W} (hρ : IsWalk R ρ) {t : ℤ} {a : W'}
    (ha : f a = ρ t) (k : ℕ) :
    f (fwdSeq R' f ρ t a k) = ρ (t + k) ∧
      R' (fwdSeq R' f ρ t a k) (fwdSeq R' f ρ t a (k + 1)) := by
  have key : ∀ k : ℕ, f (fwdSeq R' f ρ t a k) = ρ (t + k) →
      ∃ b, R' (fwdSeq R' f ρ t a k) b ∧ f b = ρ (t + k + 1) := by
    intro k hk
    apply h.forth
    rw [hk]; exact hρ (t + k)
  have hf : ∀ k : ℕ, f (fwdSeq R' f ρ t a k) = ρ (t + k) := by
    intro k
    induction k with
    | zero => simpa [fwdSeq] using ha
    | succ k ih =>
      have ex := key k ih
      have e : fwdSeq R' f ρ t a (k + 1) = ex.choose := by
        simp only [fwdSeq]; rw [dif_pos ex]
      have e2 : t + ((k + 1 : ℕ) : ℤ) = t + k + 1 := by push_cast; ring
      rw [e, ex.choose_spec.2, e2]
  refine ⟨hf k, ?_⟩
  have ex := key k (hf k)
  have e : fwdSeq R' f ρ t a (k + 1) = ex.choose := by
    simp only [fwdSeq]; rw [dif_pos ex]
  rw [e]; exact ex.choose_spec.1

theorem bwdSeq_spec (h : TwoWay R' R f) {ρ : ℤ → W} (hρ : IsWalk R ρ) {t : ℤ} {a : W'}
    (ha : f a = ρ t) (k : ℕ) :
    f (bwdSeq R' f ρ t a k) = ρ (t - k) ∧
      R' (bwdSeq R' f ρ t a (k + 1)) (bwdSeq R' f ρ t a k) := by
  have key : ∀ k : ℕ, f (bwdSeq R' f ρ t a k) = ρ (t - k) →
      ∃ c, R' c (bwdSeq R' f ρ t a k) ∧ f c = ρ (t - k - 1) := by
    intro k hk
    apply h.back
    rw [hk]
    have := hρ (t - k - 1)
    rwa [show t - (k : ℤ) - 1 + 1 = t - k by ring] at this
  have hf : ∀ k : ℕ, f (bwdSeq R' f ρ t a k) = ρ (t - k) := by
    intro k
    induction k with
    | zero => simpa [bwdSeq] using ha
    | succ k ih =>
      have ex := key k ih
      have e : bwdSeq R' f ρ t a (k + 1) = ex.choose := by
        simp only [bwdSeq]; rw [dif_pos ex]
      have e2 : t - ((k + 1 : ℕ) : ℤ) = t - k - 1 := by push_cast; ring
      rw [e, ex.choose_spec.2, e2]
  refine ⟨hf k, ?_⟩
  have ex := key k (hf k)
  have e : bwdSeq R' f ρ t a (k + 1) = ex.choose := by
    simp only [bwdSeq]; rw [dif_pos ex]
  rw [e]; exact ex.choose_spec.1

/-- The lifted walk. -/
noncomputable def liftFn (R' : W' → W' → Prop) (f : W' → W) (ρ : ℤ → W) (t : ℤ) (a : W')
    (n : ℤ) : W' :=
  if t ≤ n then fwdSeq R' f ρ t a (n - t).toNat else bwdSeq R' f ρ t a (t - n).toNat

/-- **Walk lifting.** Every walk through `f a` at `t` lifts to a walk through `a` at `t`. -/
theorem lift_walk (h : TwoWay R' R f) {ρ : ℤ → W} (hρ : IsWalk R ρ) (t : ℤ) (a : W')
    (ha : f a = ρ t) :
    ∃ ρ' : ℤ → W', IsWalk R' ρ' ∧ ρ' t = a ∧ ∀ n, f (ρ' n) = ρ n := by
  refine ⟨liftFn R' f ρ t a, ?_, ?_, ?_⟩
  · intro n
    by_cases h1 : t ≤ n
    · obtain ⟨k, rfl⟩ : ∃ k : ℕ, n = t + k := ⟨(n - t).toNat, by omega⟩
      have e1 : (t + (k : ℤ) - t).toNat = k := by omega
      have e2 : (t + (k : ℤ) + 1 - t).toNat = k + 1 := by omega
      simp only [liftFn, if_pos h1, if_pos (show t ≤ t + (k : ℤ) + 1 by omega), e1, e2]
      exact (fwdSeq_spec h hρ ha k).2
    · obtain ⟨k, rfl⟩ : ∃ k : ℕ, n = t - 1 - k := ⟨(t - 1 - n).toNat, by omega⟩
      have e1 : (t - (t - 1 - (k : ℤ))).toNat = k + 1 := by omega
      have hb := (bwdSeq_spec h hρ ha k).2
      cases k with
      | zero =>
        have e3 : (t - 1 - ((0 : ℕ) : ℤ) + 1 - t).toNat = 0 := by omega
        simp only [liftFn, if_neg h1, if_pos (show t ≤ t - 1 - ((0 : ℕ) : ℤ) + 1 by omega), e1, e3]
        exact hb
      | succ k =>
        have e3 : (t - (t - 1 - ((k + 1 : ℕ) : ℤ) + 1)).toNat = k + 1 := by omega
        simp only [liftFn, if_neg h1,
          if_neg (show ¬ t ≤ t - 1 - ((k + 1 : ℕ) : ℤ) + 1 by omega), e1, e3]
        exact hb
  · simp [liftFn, fwdSeq]
  · intro n
    by_cases h1 : t ≤ n
    · obtain ⟨k, rfl⟩ : ∃ k : ℕ, n = t + k := ⟨(n - t).toNat, by omega⟩
      have e1 : (t + (k : ℤ) - t).toNat = k := by omega
      simp only [liftFn, if_pos h1, e1]
      exact (fwdSeq_spec h hρ ha k).1
    · obtain ⟨k, rfl⟩ : ∃ k : ℕ, n = t - k := ⟨(t - n).toNat, by omega⟩
      have e1 : (t - (t - (k : ℤ))).toNat = k := by omega
      simp only [liftFn, if_neg h1, e1]
      exact (bwdSeq_spec h hρ ha k).1

/-- **Invariance.** Truth in all-walks models is invariant under surjective two-way bounded
morphisms (surjectivity is used for `□` only). -/
theorem tw_invariance (h : TwoWay R' R f) (hs : Function.Surjective f) (V : W → ℕ → Prop) :
    ∀ (φ : Fm) (σ' : ℤ → W') (t : ℤ),
      T (fullModel R' (fun x => V (f x))) σ' t φ ↔
        T (fullModel R V) (fun n => f (σ' n)) t φ := by
  intro φ
  induction φ with
  | atom p => intro σ' t; exact Iff.rfl
  | bot => intro σ' t; exact Iff.rfl
  | imp φ ψ ih1 ih2 => intro σ' t; exact imp_congr (ih1 σ' t) (ih2 σ' t)
  | box φ ih =>
    intro σ' t
    constructor
    · intro hb ρ hρ
      obtain ⟨a, ha⟩ := hs (ρ t)
      obtain ⟨ρ', hw, -, hf⟩ := lift_walk h hρ t a ha
      have h1 := (ih ρ' t).1 (hb ρ' hw)
      have e : (fun n => f (ρ' n)) = ρ := funext hf
      exact e ▸ h1
    · intro hb ρ' hρ'
      exact (ih ρ' t).2 (hb (fun n => f (ρ' n)) (fun n => h.hom _ _ (hρ' n)))
  | untl ψ φ ih1 ih2 =>
    intro σ' t
    constructor
    · rintro ⟨s, hs', h1, h2⟩
      exact ⟨s, hs', (ih2 σ' s).1 h1, fun r hr1 hr2 => (ih1 σ' r).1 (h2 r hr1 hr2)⟩
    · rintro ⟨s, hs', h1, h2⟩
      exact ⟨s, hs', (ih2 σ' s).2 h1, fun r hr1 hr2 => (ih1 σ' r).2 (h2 r hr1 hr2)⟩
  | snce ψ φ ih1 ih2 =>
    intro σ' t
    constructor
    · rintro ⟨s, hs', h1, h2⟩
      exact ⟨s, hs', (ih2 σ' s).1 h1, fun r hr1 hr2 => (ih1 σ' r).1 (h2 r hr1 hr2)⟩
    · rintro ⟨s, hs', h1, h2⟩
      exact ⟨s, hs', (ih2 σ' s).2 h1, fun r hr1 hr2 => (ih1 σ' r).2 (h2 r hr1 hr2)⟩
  | stab φ ih =>
    intro σ' t
    constructor
    · intro hb ρ hρ he
      obtain ⟨ρ', hw, hat, hf⟩ := lift_walk h hρ t (σ' t) he
      have h1 := (ih ρ' t).1 (hb ρ' hw hat.symm)
      have e : (fun n => f (ρ' n)) = ρ := funext hf
      exact e ▸ h1
    · intro hb ρ' hρ' he
      exact (ih ρ' t).2 (hb (fun n => f (ρ' n)) (fun n => h.hom _ _ (hρ' n))
        (by show f (σ' t) = f (ρ' t); rw [he]))

end Lift

/-! ## Part K — the clock product and a sound naming rule -/

/-- `q` does not occur in the formula. -/
def Fm.fresh (q : ℕ) : Fm → Prop
  | .atom p => p ≠ q
  | .bot => True
  | .imp a b => Fm.fresh q a ∧ Fm.fresh q b
  | .box a => Fm.fresh q a
  | .untl a b => Fm.fresh q a ∧ Fm.fresh q b
  | .snce a b => Fm.fresh q a ∧ Fm.fresh q b
  | .stab a => Fm.fresh q a

/-- Truth does not depend on atoms that do not occur. -/
theorem T_fresh {C : Type} (B : Set (ℤ → C)) (V V' : C → ℕ → Prop) (q : ℕ)
    (hV : ∀ c p, p ≠ q → (V c p ↔ V' c p)) :
    ∀ φ : Fm, φ.fresh q → ∀ (σ : ℤ → C) (t : ℤ),
      (T ⟨C, V, B⟩ σ t φ ↔ T ⟨C, V', B⟩ σ t φ) := by
  intro φ
  induction φ with
  | atom p => intro hq σ t; exact hV _ _ hq
  | bot => intro _ σ t; exact Iff.rfl
  | imp a b ih1 ih2 => intro hq σ t; exact imp_congr (ih1 hq.1 σ t) (ih2 hq.2 σ t)
  | box a ih =>
    intro hq σ t
    exact forall_congr' fun ρ => imp_congr Iff.rfl (ih hq ρ t)
  | untl a b ih1 ih2 =>
    intro hq σ t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).1 h1, fun r a1 a2 => (ih1 hq.1 σ r).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).2 h1, fun r a1 a2 => (ih1 hq.1 σ r).2 (h2 r a1 a2)⟩
  | snce a b ih1 ih2 =>
    intro hq σ t
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).1 h1, fun r a1 a2 => (ih1 hq.1 σ r).1 (h2 r a1 a2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih2 hq.2 σ s).2 h1, fun r a1 a2 => (ih1 hq.1 σ r).2 (h2 r a1 a2)⟩
  | stab a ih =>
    intro hq σ t
    exact forall_congr' fun ρ => imp_congr Iff.rfl (imp_congr Iff.rfl (ih hq ρ t))

section Clock
variable {W : Type} (R : W → W → Prop)

/-- The clock product: states carry an integer clock that every step advances by one. -/
def clockR : W × ℤ → W × ℤ → Prop := fun a b => R a.1 b.1 ∧ b.2 = a.2 + 1

theorem clock_twoWay : TwoWay (clockR R) R Prod.fst where
  hom := fun _ _ h => h.1
  forth := fun a v h => ⟨(v, a.2 + 1), ⟨h, rfl⟩, rfl⟩
  back := fun a u h => ⟨(u, a.2 - 1), ⟨h, by simp⟩, rfl⟩

theorem clock_DS (h : DS R) : DS (clockR R) := by
  refine ⟨fun a => ?_, fun a => ?_⟩
  · obtain ⟨v, hv⟩ := h.1 a.1; exact ⟨(v, a.2 + 1), hv, rfl⟩
  · obtain ⟨u, hu⟩ := h.2 a.1; exact ⟨(u, a.2 - 1), hu, by simp⟩

variable {R}

theorem clock_add {σ : ℤ → W × ℤ} (hσ : IsWalk (clockR R) σ) (n : ℤ) (k : ℕ) :
    (σ (n + k)).2 = (σ n).2 + k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have := (hσ (n + k)).2
    rw [show n + ((k + 1 : ℕ) : ℤ) = n + k + 1 by push_cast; ring, this, ih]
    push_cast; ring

/-- Along a walk of the clock product the clock is `time + constant`. -/
theorem clock_eq {σ : ℤ → W × ℤ} (hσ : IsWalk (clockR R) σ) (s t : ℤ) :
    (σ s).2 = (σ t).2 + (s - t) := by
  rcases le_total t s with h | h
  · obtain ⟨k, rfl⟩ : ∃ k : ℕ, s = t + k := ⟨(s - t).toNat, by omega⟩
    rw [clock_add hσ]; ring
  · obtain ⟨k, rfl⟩ : ∃ k : ℕ, t = s + k := ⟨(t - s).toNat, by omega⟩
    rw [clock_add hσ]; ring

end Clock

/-- `q` is true now and at no other time of this history. -/
def nm (q : ℕ) : Fm := (Fm.atom q).and (((Fm.atom q).neg.allPast).and ((Fm.atom q).neg.allFuture))
/-- `q` is true at exactly one time of this history. -/
def once (q : ℕ) : Fm := ((nm q).or ((nm q).somePast)).or ((nm q).someFuture)
/-- The time at which `q` holds is the same on every history through the current state. -/
def rigid (q : ℕ) : Fm :=
  (((Fm.atom q).someFuture).imp ((Fm.atom q).someFuture.stab)).and
    (((Fm.atom q).somePast).imp ((Fm.atom q).somePast.stab))
/-- Antecedent of the clock rule: `q` now, and everywhere `q` is a ⊡-rigid name of one time. -/
def clockAnte (q : ℕ) : Fm := (Fm.atom q).and (((once q).and (rigid q)).always.box)

/-- **Soundness of the clock rule** (ℤ-mirror). If `(q ∧ □A(once q ∧ rigid q)) → φ` is valid on
every doubly serial all-walks model and `q` does not occur in `φ`, then `φ` is valid on every
doubly serial all-walks model. -/
theorem clock_irr_sound (q : ℕ) (φ : Fm) (hq : φ.fresh q)
    (hprem : ∀ (W : Type) (R : W → W → Prop) (V : W → ℕ → Prop) (σ : ℤ → W) (t : ℤ),
      DS R → IsWalk R σ → T (fullModel R V) σ t ((clockAnte q).imp φ)) :
    ∀ (W : Type) (R : W → W → Prop) (V : W → ℕ → Prop) (σ : ℤ → W) (t : ℤ),
      DS R → IsWalk R σ → T (fullModel R V) σ t φ := by
  intro W R V σ t hDS hσ
  -- the clock product, with `q` true exactly at clock value 0
  let V' : W × ℤ → ℕ → Prop := fun a p => if p = q then a.2 = 0 else V a.1 p
  let σ' : ℤ → W × ℤ := fun n => (σ n, n - t)
  have hσ' : IsWalk (clockR R) σ' := fun n => ⟨hσ n, by show n + 1 - t = n - t + 1; ring⟩
  -- `q` at `(ρ, s)` iff the clock of `ρ` at `s` is zero
  have hqat : ∀ (ρ : ℤ → W × ℤ) (s : ℤ),
      T (fullModel (clockR R) V') ρ s (Fm.atom q) ↔ (ρ s).2 = 0 := by
    intro ρ s; show V' (ρ s) q ↔ _; simp [V']
  have hnm : ∀ (ρ : ℤ → W × ℤ) (s : ℤ), IsWalk (clockR R) ρ → (ρ s).2 = 0 →
      T (fullModel (clockR R) V') ρ s (nm q) := by
    intro ρ s hρ h0
    rw [nm, and_iff, and_iff, allPast_iff, allFuture_iff]
    refine ⟨(hqat ρ s).2 h0, fun r hr => ?_, fun r hr => ?_⟩
    · rw [neg_iff, hqat]; have := clock_eq hρ r s; omega
    · rw [neg_iff, hqat]; have := clock_eq hρ r s; omega
  have hante : T (fullModel (clockR R) V') σ' t (clockAnte q) := by
    rw [clockAnte, and_iff]
    refine ⟨(hqat σ' t).2 (by show t - t = 0; ring), ?_⟩
    intro ρ hρ
    rw [always_iff]
    intro s
    rw [and_iff]
    -- the unique time at which `ρ` has clock zero
    have hz : (ρ (s - (ρ s).2)).2 = 0 := by have := clock_eq hρ (s - (ρ s).2) s; omega
    constructor
    · rw [once, or_iff, or_iff, somePast_iff, someFuture_iff]
      rcases lt_trichotomy (ρ s).2 0 with hlt | heq | hgt
      · right; exact ⟨s - (ρ s).2, by omega, hnm ρ _ hρ hz⟩
      · left; left; exact hnm ρ s hρ heq
      · left; right; exact ⟨s - (ρ s).2, by omega, hnm ρ _ hρ hz⟩
    · rw [rigid, and_iff]
      constructor
      · intro hF η hη he
        rw [someFuture_iff] at hF ⊢
        obtain ⟨s', hs', hq'⟩ := hF
        rw [hqat] at hq'
        refine ⟨s', hs', (hqat η s').2 ?_⟩
        have a1 := clock_eq hρ s' s
        have a2 := clock_eq hη s' s
        have a3 : (ρ s).2 = (η s).2 := by rw [he]
        omega
      · intro hP η hη he
        rw [somePast_iff] at hP ⊢
        obtain ⟨s', hs', hq'⟩ := hP
        rw [hqat] at hq'
        refine ⟨s', hs', (hqat η s').2 ?_⟩
        have a1 := clock_eq hρ s' s
        have a2 := clock_eq hη s' s
        have a3 : (ρ s).2 = (η s).2 := by rw [he]
        omega
  have h1 : T (fullModel (clockR R) V') σ' t φ :=
    hprem (W × ℤ) (clockR R) V' σ' t (clock_DS R hDS) hσ' hante
  -- forget `q`, then project along the two-way morphism `Prod.fst`
  have h2 : T (fullModel (clockR R) (fun x => V (Prod.fst x))) σ' t φ :=
    (T_fresh {σ | IsWalk (clockR R) σ} V' (fun x => V (Prod.fst x)) q
      (fun c p hp => by simp [V', hp]) φ hq σ' t).1 h1
  exact (tw_invariance (clock_twoWay R) Prod.fst_surjective V φ σ' t).1 h2

/-- **Gabbay's plain IRR rule is sound too** (corollary): from `(q ∧ H¬q) → φ` with `q` fresh
infer `φ`. The clock antecedent implies `q ∧ H¬q`. -/
theorem irr_sound (q : ℕ) (φ : Fm) (hq : φ.fresh q)
    (hprem : ∀ (W : Type) (R : W → W → Prop) (V : W → ℕ → Prop) (σ : ℤ → W) (t : ℤ),
      DS R → IsWalk R σ →
        T (fullModel R V) σ t (((Fm.atom q).and ((Fm.atom q).neg.allPast)).imp φ)) :
    ∀ (W : Type) (R : W → W → Prop) (V : W → ℕ → Prop) (σ : ℤ → W) (t : ℤ),
      DS R → IsWalk R σ → T (fullModel R V) σ t φ := by
  apply clock_irr_sound q φ hq
  intro W R V σ t hDS hσ hante
  apply hprem W R V σ t hDS hσ
  rw [clockAnte, and_iff] at hante
  obtain ⟨hqt, hbox⟩ := hante
  have h1 := hbox σ hσ
  rw [always_iff] at h1
  have h2 := h1 t
  rw [and_iff] at h2
  have h3 := h2.1
  rw [once, or_iff, or_iff, somePast_iff, someFuture_iff] at h3
  rw [and_iff]
  refine ⟨hqt, ?_⟩
  rcases h3 with (h | ⟨s, hs, h⟩) | ⟨s, hs, h⟩
  · rw [nm, and_iff, and_iff] at h; exact h.2.1
  · rw [nm, and_iff, and_iff, allPast_iff, allFuture_iff] at h
    exact absurd hqt (h.2.2 t hs)
  · rw [nm, and_iff, and_iff, allPast_iff, allFuture_iff] at h
    exact absurd hqt (h.2.1 t hs)

/-! ## Part J — the forward-cone unravelling and the Auxiliary-Atoms expansion -/

section AA
variable {W : Type} (R : W → W → Prop)

/-- Forward-cone unravelling. `inl` is a verbatim copy of the digraph; `inr (v, h)` is a copy of
`v` reached along the recorded path `h` (most recent first). Every copy keeps ALL predecessors
(from the `inl` part), so the projection is a two-way bounded morphism; but inside the `inr` part
every node has exactly one `inr`-predecessor, so the forward cone of `inr (x, [])` is a tree. -/
def coneR : W ⊕ (W × List W) → W ⊕ (W × List W) → Prop
  | .inl u, .inl v => R u v
  | .inl u, .inr y => R u y.1
  | .inr x, .inr y => R x.1 y.1 ∧ y.2 = x.1 :: x.2
  | .inr _, .inl _ => False

def coneF : W ⊕ (W × List W) → W
  | .inl w => w
  | .inr x => x.1

theorem cone_twoWay : TwoWay (coneR R) R coneF where
  hom := by
    rintro (u | x) (v | y) h
    · exact h
    · exact h
    · exact h.elim
    · exact h.1
  forth := by
    rintro (u | x) v h
    · exact ⟨.inl v, h, rfl⟩
    · exact ⟨.inr (v, x.1 :: x.2), ⟨h, rfl⟩, rfl⟩
  back := by
    rintro (v | y) u h
    · exact ⟨.inl u, h, rfl⟩
    · exact ⟨.inl u, h, rfl⟩

theorem coneF_surjective : Function.Surjective (coneF (W := W)) := fun w => ⟨.inl w, rfl⟩

variable {Q I : Type}

/-- Run of the finite-state machine `p` from `b₀` along a recorded path (most recent first). -/
def run (p : Q → I → Q) (b₀ : Q) (idx : W → I) : List W → Q
  | [] => b₀
  | u :: h => p (run p b₀ idx h) (idx u)

/-- Which auxiliary atom is true at a node of the unravelling. -/
def coneSt (p : Q → I → Q) (b₀ : Q) (idx : W → I) : W ⊕ (W × List W) → Q
  | .inl _ => b₀
  | .inr x => run p b₀ idx x.2

/-- **Auxiliary-atoms expansion** (semantic core of Reynolds 2001 Lemma 6, transposed). Above any
point of any all-walks model there is a two-way-bounded-morphic preimage (`cone_twoWay`, so by
`tw_invariance` with the same truths for the old language) carrying a machine-state labelling `st`
with: `b₀` now, and on every history through the current state, at every time from now on, every
history through the state reached moves to the machine's next state. That is the semantic content
of `b₀ ∧ ⊡G≤ ⋀((b ∧ aᵢ) → ⊡X p(b,i))`, with `idx` reading off which `aᵢ` holds at a state. -/
theorem aa_expand (p : Q → I → Q) (b₀ : Q) (idx : W → I) (σ : ℤ → W) (hσ : IsWalk R σ) (t : ℤ) :
    ∃ σ' : ℤ → W ⊕ (W × List W), IsWalk (coneR R) σ' ∧ (∀ n, coneF (σ' n) = σ n) ∧
      coneSt p b₀ idx (σ' t) = b₀ ∧
      ∀ ρ', IsWalk (coneR R) ρ' → ρ' t = σ' t → ∀ s, t ≤ s →
        ∀ η', IsWalk (coneR R) η' → η' s = ρ' s →
          coneSt p b₀ idx (η' (s + 1)) = p (coneSt p b₀ idx (ρ' s)) (idx (coneF (ρ' s))) := by
  obtain ⟨σ', hw, hat, hf⟩ := lift_walk (cone_twoWay R) hσ t (.inr (σ t, [])) rfl
  refine ⟨σ', hw, hf, by rw [hat]; rfl, ?_⟩
  intro ρ' hρ' he s hs η' hη' heη
  have hin : ∀ k : ℕ, ∃ x, ρ' (t + k) = .inr x := by
    intro k
    induction k with
    | zero => exact ⟨(σ t, []), by simp [he, hat]⟩
    | succ k ih =>
      obtain ⟨x, hx⟩ := ih
      have h1 := hρ' (t + k)
      rw [hx] at h1
      rw [show t + ((k + 1 : ℕ) : ℤ) = t + k + 1 by push_cast; ring]
      rcases hv : ρ' (t + k + 1) with v | y
      · rw [hv] at h1; exact h1.elim
      · exact ⟨y, rfl⟩
  obtain ⟨k, rfl⟩ : ∃ k : ℕ, s = t + k := ⟨(s - t).toNat, by omega⟩
  obtain ⟨x, hx⟩ := hin k
  have h1 := hη' (t + k)
  rw [heη, hx] at h1
  rcases hv : η' (t + k + 1) with v | y
  · rw [hv] at h1; exact h1.elim
  · rw [hv] at h1
    rw [hx]
    show run p b₀ idx y.2 = p (run p b₀ idx x.2) (idx x.1)
    rw [h1.2]; rfl

end AA

/-! ## Part I — the ω-limit of splices and the LC schema -/

section Omega
variable {W : Type} {R : W → W → Prop}

theorem c_mono {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) (k d : ℕ) : c k ≤ c (k + d) := by
  induction d with
  | zero => exact le_rfl
  | succ d ih => have := hc (k + d); rw [← add_assoc]; omega

theorem c_ge {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) (k : ℕ) : c 0 + k ≤ c k := by
  induction k with
  | zero => simp
  | succ k ih => have := hc k; push_cast; omega

theorem agree_add {τ : ℕ → ℤ → W} {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1))
    (hag : ∀ k n, n ≤ c k → τ (k + 1) n = τ k n) (k d : ℕ) (n : ℤ) (hn : n ≤ c k) :
    τ (k + d) n = τ k n := by
  induction d with
  | zero => rfl
  | succ d ih =>
    rw [← ih, ← add_assoc]
    exact hag (k + d) n (le_trans hn (c_mono hc k d))

/-- **ω-limit of splices.** A sequence of walks, each agreeing with its predecessor up to a
strictly increasing marker, has a limit walk agreeing with stage `k` up to marker `k`. -/
theorem omega_limit {τ : ℕ → ℤ → W} {c : ℕ → ℤ} (hw : ∀ k, IsWalk R (τ k))
    (hc : ∀ k, c k < c (k + 1)) (hag : ∀ k n, n ≤ c k → τ (k + 1) n = τ k n) :
    ∃ lim : ℤ → W, IsWalk R lim ∧ ∀ k n, n ≤ c k → lim n = τ k n := by
  have hidx : ∀ n : ℤ, n ≤ c (n - c 0).toNat := by
    intro n; have := c_ge hc (n - c 0).toNat; omega
  have hlim : ∀ k n, n ≤ c k → τ (n - c 0).toNat n = τ k n := by
    intro k n hn
    rcases le_total k (n - c 0).toNat with h | h
    · obtain ⟨d, hd⟩ := Nat.exists_eq_add_of_le h
      rw [hd]; exact agree_add hc hag k d n hn
    · obtain ⟨d, hd⟩ := Nat.exists_eq_add_of_le h
      rw [hd]; exact (agree_add hc hag _ d n (hidx n)).symm
  refine ⟨fun n => τ (n - c 0).toNat n, ?_, hlim⟩
  intro n
  show R (τ (n - c 0).toNat n) (τ (n + 1 - c 0).toNat (n + 1))
  have h1 : n ≤ c (n + 1 - c 0).toNat := by have := hidx (n + 1); omega
  rw [hlim _ n h1]
  exact hw _ n

variable (R) in
/-- A stage of the chain: a walk through `w` at `t` with a marker `c ≥ t` carrying `A i`. -/
structure Stg (w : W) (t : ℤ) (A : ℕ → ℤ → W → Prop) (i : ℕ) where
  τ : ℤ → W
  c : ℤ
  walk : IsWalk R τ
  thru : τ t = w
  le : t ≤ c
  hA : A i c (τ c)

variable (w : W) (t : ℤ) (A : ℕ → ℤ → W → Prop) (P : ℕ → (ℤ → W) → ℤ → ℤ → Prop)

theorem stg_step
    (hP : ∀ i (η η' : ℤ → W) s s', (∀ n, s < n → n ≤ s' → η' n = η n) → P i η s s' → P i η' s s')
    (H : ∀ i (ρ : ℤ → W) s, IsWalk R ρ → ρ t = w → t ≤ s → A i s (ρ s) →
      ∃ (η : ℤ → W) (s' : ℤ), IsWalk R η ∧ η s = ρ s ∧ s < s' ∧ A (i + 1) s' (η s') ∧ P i η s s')
    {i : ℕ} (x : Stg R w t A i) :
    ∃ y : Stg R w t A (i + 1), x.c < y.c ∧ (∀ n, n ≤ x.c → y.τ n = x.τ n) ∧ P i y.τ x.c y.c := by
  obtain ⟨η, s', hη, he, hlt, hA', hP'⟩ := H i x.τ x.c x.walk x.thru x.le x.hA
  have hpn : ∀ n, x.c < n → paste x.τ η x.c n = η n := by
    intro n hn; simp only [paste]; rw [if_neg (by omega)]
  have hpl : ∀ n, n ≤ x.c → paste x.τ η x.c n = x.τ n := by
    intro n hn; simp only [paste]; rw [if_pos hn]
  refine ⟨⟨paste x.τ η x.c, s', paste_walk x.walk hη he.symm, ?_, by have := x.le; omega, ?_⟩,
    hlt, hpl, ?_⟩
  · rw [hpl t x.le]; exact x.thru
  · rw [hpn s' hlt]; exact hA'
  · exact hP i η _ x.c s' (fun n h1 _ => hpn n h1) hP'

/-- **ω-chain principle.** If every `A i`-point on a walk through `w` at `t` can be continued,
by a splice, to a later `A (i+1)`-point with the spliced segment satisfying `P i`, then one walk
through `w` at `t` realises the whole sequence. -/
theorem omega_chain
    (hP : ∀ i (η η' : ℤ → W) s s', (∀ n, s < n → n ≤ s' → η' n = η n) → P i η s s' → P i η' s s')
    (H : ∀ i (ρ : ℤ → W) s, IsWalk R ρ → ρ t = w → t ≤ s → A i s (ρ s) →
      ∃ (η : ℤ → W) (s' : ℤ), IsWalk R η ∧ η s = ρ s ∧ s < s' ∧ A (i + 1) s' (η s') ∧ P i η s s')
    (ρ₀ : ℤ → W) (s₀ : ℤ) (h0 : IsWalk R ρ₀) (h0w : ρ₀ t = w) (h0s : t ≤ s₀)
    (h0A : A 0 s₀ (ρ₀ s₀)) :
    ∃ (τ : ℤ → W) (c : ℕ → ℤ), IsWalk R τ ∧ (∀ n, n ≤ s₀ → τ n = ρ₀ n) ∧ c 0 = s₀ ∧
      (∀ k, c k < c (k + 1)) ∧ (∀ k, A k (c k) (τ (c k))) ∧ ∀ k, P k τ (c k) (c (k + 1)) := by
  classical
  let chain : (k : ℕ) → Stg R w t A k := fun k =>
    Nat.rec (motive := fun k => Stg R w t A k) ⟨ρ₀, s₀, h0, h0w, h0s, h0A⟩
      (fun _ x => (stg_step w t A P hP H x).choose) k
  have hstep : ∀ k, (chain k).c < (chain (k + 1)).c ∧
      (∀ n, n ≤ (chain k).c → (chain (k + 1)).τ n = (chain k).τ n) ∧
      P k (chain (k + 1)).τ (chain k).c (chain (k + 1)).c :=
    fun k => (stg_step w t A P hP H (chain k)).choose_spec
  obtain ⟨lim, hlw, hlag⟩ := omega_limit (τ := fun k => (chain k).τ) (c := fun k => (chain k).c)
    (fun k => (chain k).walk) (fun k => (hstep k).1) (fun k => (hstep k).2.1)
  refine ⟨lim, fun k => (chain k).c, hlw, fun n hn => hlag 0 n hn, rfl, fun k => (hstep k).1,
    fun k => ?_, fun k => ?_⟩
  · rw [hlag k _ le_rfl]; exact (chain k).hA
  · exact hP k _ _ _ _ (fun n _ h2 => hlag (k + 1) n h2) (hstep k).2.2

end Omega

/-- Finite conjunction `g 0 ∧ … ∧ g (n-1)`. -/
def bigAnd : ℕ → (ℕ → Fm) → Fm
  | 0, _ => Fm.top
  | n + 1, g => (bigAnd n g).and (g n)

theorem bigAnd_iff (M : BModel) (σ : ℤ → M.C) (t : ℤ) (g : ℕ → Fm) :
    ∀ n, T M σ t (bigAnd n g) ↔ ∀ i, i < n → T M σ t (g i) := by
  intro n
  induction n with
  | zero => simp only [bigAnd, Fm.top, T]; exact ⟨fun _ i hi => absurd hi (by omega), fun _ h => h⟩
  | succ n ih =>
    rw [bigAnd, and_iff, ih]
    constructor
    · rintro ⟨h1, h2⟩ i hi
      rcases Nat.lt_succ_iff_lt_or_eq.1 hi with h | rfl
      · exact h1 i h
      · exact h2
    · intro h; exact ⟨fun i hi => h i (by omega), h n (by omega)⟩

/-- Antecedent of `LC_n` (Reynolds 2003, transposed to `⊡`):
`⊡G≤ ⋀_{i<n} (⟐αᵢ → ⟐F⟐α_{i+1 mod n})`. -/
def lcAnte (n : ℕ) (α : ℕ → Fm) : Fm :=
  (bigAnd n fun i => (α i).dstab.imp ((α ((i + 1) % n)).dstab.someFuture.dstab)).gle.stab

/-- Consequent of `LC_n`: `⟐G≤ ⋀_{i<n} (⟐αᵢ → F⟐α_{i+1 mod n})`. -/
def lcCons (n : ℕ) (α : ℕ → Fm) : Fm :=
  (bigAnd n fun i => (α i).dstab.imp ((α ((i + 1) % n)).dstab.someFuture)).gle.dstab

def lcN (n : ℕ) (α : ℕ → Fm) : Fm := (lcAnte n α).imp (lcCons n α)

/-- **`LC_n` is valid on every all-walks ℤ-model**, for every `n ≥ 1` and all parameters. -/
theorem lcN_valid_full {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) (n : ℕ) (hn : 0 < n)
    (α : ℕ → Fm) (σ : ℤ → W) (t : ℤ) (hσ : IsWalk R σ) :
    T (fullModel R V) σ t (lcN n α) := by
  intro hante
  -- unpack the antecedent
  have hA : ∀ (ρ : ℤ → W), IsWalk R ρ → ρ t = σ t → ∀ s, t ≤ s → ∀ i, i < n →
      T (fullModel R V) ρ s (α i).dstab →
      T (fullModel R V) ρ s ((α ((i + 1) % n)).dstab.someFuture.dstab) := by
    intro ρ hρ he s hs i hi
    have h1 := hante ρ hρ he.symm
    rw [gle_iff] at h1
    exact (bigAnd_iff _ _ _ _ n).1 (h1 s hs) i hi
  rw [lcCons, dstab_iff]
  by_cases hex : ∃ (ρ : ℤ → W) (s : ℤ) (i : ℕ), IsWalk R ρ ∧ ρ t = σ t ∧ t ≤ s ∧ i < n ∧
      T (fullModel R V) ρ s (α i).dstab
  · obtain ⟨ρ₀, s₀, i₀, h0, h0w, h0s, hi₀, h0A⟩ := hex
    -- state/time predicates: `⟐α_{(i₀+k) mod n}` at the state, at that time
    let A : ℕ → ℤ → W → Prop := fun k s v =>
      ∃ η : ℤ → W, IsWalk R η ∧ v = η s ∧ T (fullModel R V) η s (α ((i₀ + k) % n))
    have hAiff : ∀ k (ρ : ℤ → W) s, A k s (ρ s) ↔
        T (fullModel R V) ρ s (α ((i₀ + k) % n)).dstab := by
      intro k ρ s; rw [dstab_iff]
      constructor
      · rintro ⟨η, h1, h2, h3⟩; exact ⟨η, h1, h2, h3⟩
      · rintro ⟨η, h1, h2, h3⟩; exact ⟨η, h1, h2, h3⟩
    obtain ⟨τ, c, hτ, hag, hc0, hcl, hcA, -⟩ :=
      omega_chain (R := R) (σ t) t A (fun _ _ _ _ => True) (fun _ _ _ _ _ _ _ => trivial)
        (by
          intro k ρ s hρ he hs hk
          have h1 := hA ρ hρ he s hs ((i₀ + k) % n) (Nat.mod_lt _ hn) ((hAiff k ρ s).1 hk)
          rw [dstab_iff] at h1
          obtain ⟨η, hη, he', h2⟩ := h1
          rw [someFuture_iff] at h2
          obtain ⟨s', hs', h3⟩ := h2
          refine ⟨η, s', hη, he'.symm, hs', ?_, trivial⟩
          rw [hAiff (k + 1) η s']
          have e : (i₀ + (k + 1)) % n = ((i₀ + k) % n + 1) % n := by
            rw [Nat.mod_add_mod, add_assoc]
          rw [e]; exact h3)
        ρ₀ s₀ h0 h0w h0s (by
          rw [hAiff 0 ρ₀ s₀, Nat.add_zero, Nat.mod_eq_of_lt hi₀]; exact h0A)
    refine ⟨τ, hτ, ?_, ?_⟩
    · rw [hag t h0s, h0w]
    · rw [gle_iff]
      intro s hs
      rw [bigAnd_iff]
      intro j hj _
      rw [someFuture_iff]
      -- a marker beyond `s` whose index is `j + 1` modulo `n`
      obtain ⟨m, hm⟩ : ∃ m, n = i₀ + m := ⟨n - i₀, by omega⟩
      let N : ℕ := (s - s₀).toNat + 1
      let k : ℕ := j + 1 + m + N * n
      have hk1 : (i₀ + k) % n = (j + 1) % n := by
        have : i₀ + k = (j + 1) + n * (N + 1) := by
          show i₀ + (j + 1 + m + N * n) = (j + 1) + n * (N + 1)
          rw [hm]; ring
        rw [this, Nat.add_mul_mod_self_left]
      have hk2 : s < c k := by
        have h1 := c_ge hcl k
        have h2 : N ≤ N * n := Nat.le_mul_of_pos_right N hn
        have h3 : (N : ℤ) ≤ (k : ℤ) := by
          have : N ≤ k := by show N ≤ j + 1 + m + N * n; omega
          exact_mod_cast this
        have h4 : s - s₀ < (N : ℤ) := by
          show s - s₀ < (((s - s₀).toNat + 1 : ℕ) : ℤ); push_cast; omega
        omega
      refine ⟨c k, hk2, ?_⟩
      have := (hAiff k τ (c k)).1 (hcA k)
      rwa [hk1] at this
  · -- no `⟐αᵢ`-point is reachable: `σ` itself witnesses the consequent vacuously
    refine ⟨σ, hσ, rfl, ?_⟩
    rw [gle_iff]
    intro s hs
    rw [bigAnd_iff]
    intro j hj hj'
    exact absurd ⟨σ, s, j, hσ, rfl, hs, hj, hj'⟩ hex

end Probe559c
