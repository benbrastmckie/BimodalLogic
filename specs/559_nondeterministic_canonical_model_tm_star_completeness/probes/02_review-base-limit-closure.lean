import Mathlib

/-!
# REVIEW COPY of `01_limit-closure-probes.lean` + Part G

Lines up to `lcPlus_refuted_coarse` are the original probe, verbatim (re-compiled: exit 0).
**Part G (new, from the review)** adds the X-free formula
`BLC := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`:
`blc_valid_full` (valid on every full ℤ-model), `evFalse_pasteClosed`, `blc_refuted`,
`eR`/`eπ`/`eR_image_eq`/`blc_refuted_coarse` (coarse countermodel on a ℤ-digraph), and the
ingredients of the Saturation paper argument (`eR_trans`, `eR_dense`, `eR_succ`, `eR_from_hub`).
NOT compiled here: validity of BLC over arbitrary durations (Zorn + the Extension Theorem), and
Saturation of `eR`. Compiled with bare `lean`, Mathlib oleans only, no `lake`. Sorry-free.
-/

/-!
# Probes: limit closure and the incompleteness of TM⁺ over ℤ-time (all-histories semantics)

Self-contained (Mathlib-only) mirror of `PlusTruthAt` specialised to ℤ-time. Over ℤ a task frame
is a digraph `R = ⇒₁` serial in both directions (`⇒ₙ = Rⁿ` by Compositionality), and its world
histories are exactly the bi-infinite `R`-walks. A *bundled* model replaces "all walks" by a set
`B` of state sequences; a coarsened-state model (`Independence/CoarsenedModels.lean`) is exactly a
bundled model on the `π`-image of the walks.

Sorry-free; imports Mathlib only. Compiled with the pinned toolchain's bare `lean` against the
pinned Mathlib oleans (`LEAN_PATH` set by hand, no `lake` invocation, no `FormalSystem` import:
another session was rebuilding the tree); the clause lemmas and Part A were also run through
`lean_run_code`. Axioms: `propext`, `Classical.choice`, `Quot.sound` only.
-/

namespace Probe559

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
def someFuture (φ : Fm) : Fm := untl top φ
def allFuture (φ : Fm) : Fm := neg (someFuture (neg φ))
def somePast (φ : Fm) : Fm := snce top φ
def allPast (φ : Fm) : Fm := neg (somePast (neg φ))
def next (φ : Fm) : Fm := untl bot φ
def dstab (φ : Fm) : Fm := neg (stab (neg φ))
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

theorem dstab_iff (φ : Fm) :
    T M σ t φ.dstab ↔ ∃ ρ ∈ M.B, σ t = ρ t ∧ T M ρ t φ := by
  simp only [Fm.dstab, Fm.neg, T]
  constructor
  · intro h; by_contra hc; exact h fun ρ hρ he hφ => hc ⟨ρ, hρ, he, hφ⟩
  · rintro ⟨ρ, hρ, he, hφ⟩ h; exact h ρ hρ he hφ

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

theorem next_iff (φ : Fm) : T M σ t φ.next ↔ T M σ (t + 1) φ := by
  simp only [Fm.next, T]
  constructor
  · rintro ⟨s, hs, hφ, hb⟩
    obtain rfl : s = t + 1 := by
      by_contra hne; exact hb (t + 1) (by omega) (by omega)
    exact hφ
  · intro h; exact ⟨t + 1, by omega, h, fun r h1 h2 => by omega⟩

end Clauses

/-! ## Part A — full (all-walks) models over ℤ and the limit-closure validity LC⁺ -/

section Full
variable {W : Type} (R : W → W → Prop)

/-- A bi-infinite `R`-walk: over ℤ-time, exactly a world history of the task frame `⇒ₙ = Rⁿ`. -/
def IsWalk (σ : ℤ → W) : Prop := ∀ n, R (σ n) (σ (n + 1))

/-- The full (all-histories) model of a digraph: the bundle is *every* walk. -/
abbrev fullModel (V : W → ℕ → Prop) : BModel := ⟨W, V, {σ | IsWalk R σ}⟩

/-- Splice: `ρ` up to and including `s`, `η` after `s` (repo `Semantics/PlusLanguage/PlusPasting.lean`). -/
def paste {C : Type} (ρ η : ℤ → C) (s : ℤ) : ℤ → C := fun n => if n ≤ s then ρ n else η n

theorem paste_walk {ρ η : ℤ → W} {s : ℤ} (hρ : IsWalk R ρ) (hη : IsWalk R η) (h : ρ s = η s) :
    IsWalk R (paste ρ η s) := by
  intro n
  simp only [paste]
  by_cases h1 : n + 1 ≤ s
  · rw [if_pos (by omega), if_pos h1]; exact hρ n
  · by_cases h2 : n ≤ s
    · rw [if_pos h2, if_neg h1]
      obtain rfl : n = s := by omega
      rw [h]; exact hη n
    · rw [if_neg h2, if_neg h1]; exact hη n

variable (V : W → ℕ → Prop) (p : ℕ) (w : W) (t : ℤ)

/-- Stage `k` of the limit construction: a walk through `w` at `t` with `p` at `t+1 … t+1+k`. -/
def Good (k : ℕ) (ρ : ℤ → W) : Prop :=
  IsWalk R ρ ∧ ρ t = w ∧ ∀ j : ℕ, j ≤ k → V (ρ (t + 1 + j)) p

variable (h2 : ∀ ρ, IsWalk R ρ → ρ t = w → ∀ s, t < s → V (ρ s) p →
    ∃ η, IsWalk R η ∧ η s = ρ s ∧ V (η (s + 1)) p)

include h2 in
theorem good_step (k : ℕ) (ρ : ℤ → W) (hρ : Good R V p w t k ρ) :
    ∃ ρ', Good R V p w t (k + 1) ρ' ∧ ∀ n, n ≤ t + 1 + k → ρ' n = ρ n := by
  obtain ⟨hw, h0, hp⟩ := hρ
  obtain ⟨η, hη, hs, hv⟩ := h2 ρ hw h0 (t + 1 + k) (by omega) (hp k le_rfl)
  refine ⟨paste ρ η (t + 1 + k), ⟨paste_walk R hw hη hs.symm, ?_, ?_⟩, ?_⟩
  · simp only [paste]; rw [if_pos (by omega)]; exact h0
  · intro j hj
    simp only [paste]
    by_cases hjk : j ≤ k
    · rw [if_pos (by omega)]; exact hp j hjk
    · obtain rfl : j = k + 1 := by omega
      rw [if_neg (by omega)]
      have : t + 1 + ((k + 1 : ℕ) : ℤ) = t + 1 + k + 1 := by push_cast; ring
      rw [this]; exact hv
  · intro n hn; simp only [paste]; rw [if_pos hn]

/-- The chain of stages, by dependent choice. -/
noncomputable def chain (ρ0 : ℤ → W) (h0 : Good R V p w t 0 ρ0) :
    (k : ℕ) → {ρ // Good R V p w t k ρ}
  | 0 => ⟨ρ0, h0⟩
  | k + 1 =>
    ⟨Classical.choose (good_step R V p w t h2 k _ (chain ρ0 h0 k).2),
      (Classical.choose_spec (good_step R V p w t h2 k _ (chain ρ0 h0 k).2)).1⟩

include h2 in
theorem chain_agree (ρ0 : ℤ → W) (h0 : Good R V p w t 0 ρ0) (k : ℕ) :
    ∀ m, ∀ n, n ≤ t + 1 + k →
      (chain R V p w t h2 ρ0 h0 (k + m)).1 n = (chain R V p w t h2 ρ0 h0 k).1 n := by
  intro m
  induction m with
  | zero => intros; rfl
  | succ m ih =>
    intro n hn
    rw [← ih n hn]
    show Classical.choose (good_step R V p w t h2 (k + m) _ (chain R V p w t h2 ρ0 h0 (k + m)).2) n = _
    exact (Classical.choose_spec
      (good_step R V p w t h2 (k + m) _ (chain R V p w t h2 ρ0 h0 (k + m)).2)).2 n (by omega)

include h2 in
/-- **The limit-closure lemma over ℤ.** From a first `p`-step and "every `p`-point on a walk
through `w` can be continued by one more `p`-step", a single walk through `w` carries `p` forever. -/
theorem limit_walk (h1 : ∃ ρ, IsWalk R ρ ∧ ρ t = w ∧ V (ρ (t + 1)) p) :
    ∃ ρ, IsWalk R ρ ∧ ρ t = w ∧ ∀ s, t < s → V (ρ s) p := by
  obtain ⟨ρ0, hw0, ht0, hp0⟩ := h1
  have h0 : Good R V p w t 0 ρ0 :=
    ⟨hw0, ht0, fun j hj => by
      obtain rfl : j = 0 := by omega
      simpa using hp0⟩
  let c := chain R V p w t h2 ρ0 h0
  have agree : ∀ k k' : ℕ, k ≤ k' → ∀ n, n ≤ t + 1 + k → (c k').1 n = (c k).1 n := by
    intro k k' hk n hn
    obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hk
    exact chain_agree R V p w t h2 ρ0 h0 k m n hn
  let lim : ℤ → W := fun n => (c (n - t).toNat).1 n
  refine ⟨lim, ?_, ?_, ?_⟩
  · intro n
    have e1 : lim (n + 1) = (c (n + 1 - t).toNat).1 (n + 1) := rfl
    have e0 : lim n = (c (n + 1 - t).toNat).1 n :=
      (agree _ _ (by omega) n (by omega)).symm
    rw [e0, e1]; exact (c _).2.1 n
  · show (c (t - t).toNat).1 t = w
    exact (c _).2.2.1
  · intro s hs
    show V ((c (s - t).toNat).1 s) p
    have := (c (s - t).toNat).2.2.2 ((s - t).toNat - 1) (by omega)
    have e : t + 1 + (((s - t).toNat - 1 : ℕ) : ℤ) = s := by omega
    rwa [e] at this

end Full

/-- `LC⁺ := (⟐Xp ∧ ⊡G(p → ⟐Xp)) → ⟐Gp` — the transposition of Reynolds' limit-closure axiom
(`AG(Eα → EX(Eβ U Eα)) → (Eα → EG(Eβ U Eα))`, Reynolds 2001 §6) to the stability modal. -/
def lcPlus (p : ℕ) : Fm :=
  Fm.imp (Fm.and (Fm.dstab (Fm.next (.atom p)))
      (Fm.stab (Fm.allFuture (Fm.imp (.atom p) (Fm.dstab (Fm.next (.atom p)))))))
    (Fm.dstab (Fm.allFuture (.atom p)))

/-- **LC⁺ is valid over every ℤ-time task frame (all-histories semantics).** -/
theorem lcPlus_valid_full {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) (p : ℕ)
    (σ : ℤ → W) (t : ℤ) : T (fullModel R V) σ t (lcPlus p) := by
  intro h
  obtain ⟨h1, h2⟩ := (and_iff _ _ _ _ _).mp h
  rw [dstab_iff] at h1
  obtain ⟨ρ0, hρ0, he0, hn0⟩ := h1
  rw [next_iff] at hn0
  rw [dstab_iff]
  obtain ⟨ρ, hρ, hρt, hp⟩ := limit_walk R V p (σ t) t
    (fun ρ hw ht s hs hv => by
      have := (allFuture_iff _ _ _ _).mp (h2 ρ hw ht.symm) s hs hv
      obtain ⟨η, hη, he, hn⟩ := (dstab_iff _ _ _ _).mp this
      exact ⟨η, hη, he.symm, (next_iff _ _ _ _).mp hn⟩)
    ⟨ρ0, hρ0, he0.symm, hn0⟩
  exact ⟨ρ, hρ, hρt.symm, (allFuture_iff _ _ _ _).mpr hp⟩

/-! ## Part B — paste-closed bundles validate PS and US (and their mirrors) -/

/-- Mirror of `IsPureFuture`. -/
inductive PF : Fm → Prop
  | atom (p : ℕ) : PF (.atom p)
  | bot : PF .bot
  | imp {φ ψ : Fm} : PF φ → PF ψ → PF (.imp φ ψ)
  | box (φ : Fm) : PF (.box φ)
  | stab (φ : Fm) : PF (.stab φ)
  | untl {ψ φ : Fm} : PF ψ → PF φ → PF (.untl ψ φ)

/-- Mirror of `IsPurePast`. -/
inductive PP : Fm → Prop
  | atom (p : ℕ) : PP (.atom p)
  | bot : PP .bot
  | imp {φ ψ : Fm} : PP φ → PP ψ → PP (.imp φ ψ)
  | box (φ : Fm) : PP (.box φ)
  | stab (φ : Fm) : PP (.stab φ)
  | snce {ψ φ : Fm} : PP ψ → PP φ → PP (.snce ψ φ)

theorem pf_congr (M : BModel) {φ : Fm} (h : PF φ) :
    ∀ (ρ σ : ℤ → M.C) (t : ℤ), (∀ s, t ≤ s → ρ s = σ s) → (T M ρ t φ ↔ T M σ t φ) := by
  induction h with
  | atom p => intro ρ σ t hs; show M.V _ p ↔ M.V _ p; rw [hs t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ih1 ih2 => intro ρ σ t hs; exact Iff.imp (ih1 ρ σ t hs) (ih2 ρ σ t hs)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro ρ σ t hs
    show (∀ η ∈ M.B, ρ t = η t → _) ↔ (∀ η ∈ M.B, σ t = η t → _)
    rw [hs t le_rfl]
  | untl _ _ ihψ ihφ =>
    intro ρ σ t hs
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ ρ σ s fun u hu => hs u (by omega))
        (forall_congr' fun r => imp_congr_right fun htr => imp_congr_right fun _ =>
          ihψ ρ σ r fun u hu => hs u (by omega))

theorem pp_congr (M : BModel) {φ : Fm} (h : PP φ) :
    ∀ (ρ σ : ℤ → M.C) (t : ℤ), (∀ s, s ≤ t → ρ s = σ s) → (T M ρ t φ ↔ T M σ t φ) := by
  induction h with
  | atom p => intro ρ σ t hs; show M.V _ p ↔ M.V _ p; rw [hs t le_rfl]
  | bot => intros; exact Iff.rfl
  | imp _ _ ih1 ih2 => intro ρ σ t hs; exact Iff.imp (ih1 ρ σ t hs) (ih2 ρ σ t hs)
  | box φ => intros; exact Iff.rfl
  | stab φ =>
    intro ρ σ t hs
    show (∀ η ∈ M.B, ρ t = η t → _) ↔ (∀ η ∈ M.B, σ t = η t → _)
    rw [hs t le_rfl]
  | snce _ _ ihψ ihφ =>
    intro ρ σ t hs
    exact exists_congr fun s => and_congr_right fun hts =>
      and_congr (ihφ ρ σ s fun u hu => hs u (by omega))
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun hrt =>
          ihψ ρ σ r fun u hu => hs u (by omega))

/-- A bundle is **paste-closed** when splicing two of its members at a shared state stays in it. -/
def PasteClosed (M : BModel) : Prop :=
  ∀ ρ ∈ M.B, ∀ η ∈ M.B, ∀ s, ρ s = η s → paste ρ η s ∈ M.B

/-- **PS in every paste-closed bundle**: `⟐φ⁺ → ⟐ψ⁻ → ⟐(φ⁺ ∧ ψ⁻)`. -/
theorem ps_valid (M : BModel) (hM : PasteClosed M) {φ ψ : Fm} (hφ : PF φ) (hψ : PP ψ)
    (τ : ℤ → M.C) (t : ℤ) :
    T M τ t (.imp φ.dstab (.imp ψ.dstab (φ.and ψ).dstab)) := by
  intro h1 h2
  obtain ⟨σ1, hσ1, he1, hφ1⟩ := (dstab_iff _ _ _ _).mp h1
  obtain ⟨σ2, hσ2, he2, hψ2⟩ := (dstab_iff _ _ _ _).mp h2
  have hB := hM σ2 hσ2 σ1 hσ1 t (he2.symm.trans he1)
  refine (dstab_iff _ _ _ _).mpr ⟨paste σ2 σ1 t, hB, ?_, (and_iff _ _ _ _ _).mpr ⟨?_, ?_⟩⟩
  · simp [paste, he2]
  · refine (pf_congr M hφ _ σ1 t fun s hs => ?_).mpr hφ1
    simp only [paste]
    by_cases h : s ≤ t
    · obtain rfl : s = t := le_antisymm h hs
      rw [if_pos le_rfl, ← he2, he1]
    · rw [if_neg h]
  · refine (pp_congr M hψ _ σ2 t fun s hs => ?_).mpr hψ2
    simp only [paste]; rw [if_pos hs]

/-- **US in every paste-closed bundle**: `(α⁻ U ⟐φ⁺) → ⟐(α⁻ U φ⁺)`, at every member `τ`. -/
theorem us_valid (M : BModel) (hM : PasteClosed M) {α φ : Fm} (hα : PP α) (hφ : PF φ)
    (τ : ℤ → M.C) (hτ : τ ∈ M.B) (t : ℤ) :
    T M τ t (.imp (.untl α φ.dstab) (Fm.untl α φ).dstab) := by
  rintro ⟨y, hty, hy, hα'⟩
  obtain ⟨σ, hσ, he, hφy⟩ := (dstab_iff _ _ _ _).mp hy
  refine (dstab_iff _ _ _ _).mpr ⟨paste τ σ y, hM τ hτ σ hσ y he, ?_, y, hty, ?_, ?_⟩
  · simp only [paste]; rw [if_pos (by omega)]
  · refine (pf_congr M hφ _ σ y fun s hs => ?_).mpr hφy
    simp only [paste]
    by_cases h : s ≤ y
    · obtain rfl : s = y := le_antisymm h hs
      rw [if_pos le_rfl, he]
    · rw [if_neg h]
  · intro r h1 h2
    refine (pp_congr M hα _ τ r fun s hs => ?_).mpr (hα' r h1 h2)
    simp only [paste]; rw [if_pos (by omega)]

/-! ## Part C — the countermodel: a paste-closed bundle refuting LC⁺ -/

/-- The bundle of Boolean sequences with no infinite forward `true`-run. -/
def finRuns : Set (ℤ → Bool) := {β | ∀ n, ∃ m, n ≤ m ∧ β m = false}

/-- The bundled model on two classes: `true` = the `p`-class `a`, `false` = the class `b`. -/
abbrev cModel : BModel := ⟨Bool, fun c _ => c = true, finRuns⟩

theorem finRuns_pasteClosed : PasteClosed cModel := by
  intro ρ _ η hη s _ n
  obtain ⟨m, hm, hf⟩ := hη (max n (s + 1))
  refine ⟨m, le_trans (le_max_left _ _) hm, ?_⟩
  simp only [paste]; rw [if_neg (by omega)]; exact hf

theorem finRuns_shiftClosed (β : ℤ → Bool) (hβ : β ∈ finRuns) (d : ℤ) :
    (fun n => β (n + d)) ∈ finRuns := by
  intro n
  obtain ⟨m, hm, hf⟩ := hβ (n + d)
  exact ⟨m - d, by omega, by simpa using hf⟩

/-- **LC⁺ fails in the paste-closed bundle `cModel`**, at every member and every time. -/
theorem lcPlus_refuted (σ : ℤ → Bool) (hσ : σ ∈ finRuns) (t : ℤ) :
    ¬ T cModel σ t (lcPlus 0) := by
  intro h
  have hyp : T cModel σ t (Fm.and (Fm.dstab (Fm.next (.atom 0)))
      (Fm.stab (Fm.allFuture (Fm.imp (.atom 0) (Fm.dstab (Fm.next (.atom 0))))))) := by
    refine (and_iff _ _ _ _ _).mpr ⟨?_, ?_⟩
    · let ρ0 : ℤ → Bool := fun n => if n = t + 1 then true else if n = t then σ t else false
      refine (dstab_iff _ _ _ _).mpr ⟨ρ0, ?_, ?_, (next_iff _ _ _ _).mpr ?_⟩
      · intro n
        refine ⟨max n (t + 2), le_max_left _ _, ?_⟩
        have h1 : max n (t + 2) ≠ t + 1 := by omega
        have h2 : max n (t + 2) ≠ t := by omega
        simp [ρ0, h1, h2]
      · show σ t = ρ0 t
        simp [ρ0]
      · show ρ0 (t + 1) = true
        simp [ρ0]
    · intro ρ _ _
      refine (allFuture_iff _ _ _ _).mpr fun s _ hp => ?_
      let η : ℤ → Bool := fun n => if n = s ∨ n = s + 1 then true else false
      refine (dstab_iff _ _ _ _).mpr ⟨η, ?_, ?_, (next_iff _ _ _ _).mpr ?_⟩
      · intro n
        refine ⟨max n (s + 2), le_max_left _ _, ?_⟩
        have h1 : max n (s + 2) ≠ s := by omega
        have h2 : max n (s + 2) ≠ s + 1 := by omega
        simp [η, h1, h2]
      · have : ρ s = true := hp
        show ρ s = η s
        simp [η, this]
      · show η (s + 1) = true
        simp [η]
  obtain ⟨ρ, hρ, _, hG⟩ := (dstab_iff _ _ _ _).mp (h hyp)
  obtain ⟨m, hm, hf⟩ := hρ (t + 1)
  have : ρ m = true := (allFuture_iff _ _ _ _).mp hG m (by omega)
  rw [hf] at this; exact Bool.false_ne_true this

/-- The completion of `cModel` — the same two classes, the universal digraph, *all* walks —
validates LC⁺ (`lcPlus_valid_full`). So a bundled model and its all-histories completion are
**not** L⁺-indistinguishable: route (c) of the dispatch is closed. -/
theorem completion_validates (σ : ℤ → Bool) (t : ℤ) :
    T (fullModel (fun _ _ : Bool => True) (fun c _ => c = true)) σ t (lcPlus 0) :=
  lcPlus_valid_full _ _ 0 σ t

/-! ## Part D — `cModel` is the `π`-image of all walks of a genuine infinite ℤ-task frame

States `Option ℕ`: `none` is `b`, `some j` is `a` with counter `j`. Edges: `b → x` for all `x`,
`a_j → b`, `a_j → a_m` for `m < j`. Every state has an in- and out-edge, and `R ∘ R` is universal,
so every nonzero-duration fibre and segment contains `b`: Saturation holds (the zero-duration
ones are singletons). `π := Option.isSome`. -/

def cR : Option ℕ → Option ℕ → Prop
  | none, _ => True
  | some _, none => True
  | some j, some m => m < j

theorem cR_to_none (x : Option ℕ) : cR x none := by cases x <;> trivial
theorem cR_from_none (y : Option ℕ) : cR none y := trivial
theorem cR_two_universal (x y : Option ℕ) : ∃ z, cR x z ∧ cR z y := ⟨none, cR_to_none x, trivial⟩

/-- Every walk's `π`-image has no infinite forward `a`-run: counters strictly decrease. -/
theorem image_walk_mem (σ : ℤ → Option ℕ) (hσ : IsWalk cR σ) :
    (fun n => (σ n).isSome) ∈ finRuns := by
  intro n
  by_contra hne
  push Not at hne
  have hsome : ∀ k : ℕ, ∃ j, σ (n + k) = some j := by
    intro k
    have := hne (n + k) (by omega)
    cases h : σ (n + k) with
    | none => simp [h] at this
    | some j => exact ⟨j, rfl⟩
  choose f hf using hsome
  have hdec : ∀ k, f (k + 1) < f k := by
    intro k
    have e := hσ (n + k)
    rw [hf k, show n + k + 1 = n + ((k + 1 : ℕ) : ℤ) by push_cast; ring, hf (k + 1)] at e
    exact e
  have : ∀ k, f k + k ≤ f 0 := by
    intro k
    induction k with
    | zero => simp
    | succ k ih => have := hdec k; omega
  have := this (f 0 + 1); omega

/-- Conversely every member of `finRuns` is the image of a walk: at an `a`-time, the counter is
the distance to the next `b` minus one. -/
theorem mem_image_walk (β : ℤ → Bool) (hβ : β ∈ finRuns) :
    ∃ σ : ℤ → Option ℕ, IsWalk cR σ ∧ ∀ n, (σ n).isSome = β n := by
  classical
  have hex : ∀ n, ∃ k : ℕ, β (n + 1 + k) = false := by
    intro n
    obtain ⟨m, hm, hf⟩ := hβ (n + 1)
    exact ⟨(m - (n + 1)).toNat, by rw [show n + 1 + ((m - (n + 1)).toNat : ℤ) = m by omega]; exact hf⟩
  let d : ℤ → ℕ := fun n => Nat.find (hex n)
  let σ : ℤ → Option ℕ := fun n => if β n = true then some (d n) else none
  refine ⟨σ, ?_, fun n => by by_cases h : β n = true <;> simp [σ, h]⟩
  intro n
  by_cases hn : β n = true
  · by_cases hn1 : β (n + 1) = true
    · simp only [σ, hn, hn1, if_true, cR]
      -- d n = d (n+1) + 1
      have h0 : d n ≠ 0 := by
        intro h0
        have := Nat.find_spec (hex n)
        have e : d n = 0 := h0
        simp only [d] at e
        rw [e] at this; simp at this; rw [this] at hn1; exact Bool.false_ne_true hn1
      have hspec := Nat.find_spec (hex (n + 1))
      have hle : d n ≤ d (n + 1) + 1 := Nat.find_min' (hex n) (by
        rw [show n + 1 + ((d (n + 1) + 1 : ℕ) : ℤ) = n + 1 + 1 + (d (n + 1) : ℤ) by push_cast; ring]
        exact hspec)
      have hge : d (n + 1) + 1 ≤ d n := by
        have hs := Nat.find_spec (hex n)
        have : d n - 1 ≥ d (n + 1) := Nat.find_min' (hex (n + 1)) (by
          rw [show n + 1 + 1 + ((d n - 1 : ℕ) : ℤ) = n + 1 + (d n : ℤ) by omega]
          exact hs)
        omega
      omega
    · have : σ (n + 1) = none := by simp [σ, hn1]
      show cR (σ n) (σ (n + 1))
      rw [this]; exact cR_to_none _
  · have : σ n = none := by simp [σ, hn]
    show cR (σ n) (σ (n + 1))
    rw [this]; exact trivial

/-! ## Part E — the naming-rule candidate of the earlier axiomatization research is unsound

`from ⊢ (q ∧ ⊡q ∧ □H¬q ∧ □G¬q) → φ infer ⊢ φ`: the antecedent is **unsatisfiable** in every
shift-closed bundle (in particular every full model), because the shift of a history through the
`q`-state visits that state again one step later. So the premise holds for `φ := ⊥` and the rule
derives `⊥`. -/

theorem naming_antecedent_unsat (M : BModel)
    (hshift : ∀ β ∈ M.B, (fun n => β (n + -1)) ∈ M.B)
    (τ : ℤ → M.C) (hτ : τ ∈ M.B) (t : ℤ) (q : ℕ)
    (hq : T M τ t (.atom q)) (hG : T M τ t (.box (Fm.allFuture (Fm.neg (.atom q))))) : False := by
  have := (allFuture_iff _ _ _ _).mp (hG _ (hshift τ hτ)) (t + 1) (by omega)
  exact this (by show M.V (τ (t + 1 + -1)) q; rw [show t + 1 + -1 = t by omega]; exact hq)

/-! ## Part F — coarsened-state truth over a digraph *is* bundled truth on the `π`-image

The mirror of `Independence/CoarsenedModels.lean`'s `CTruthAt` over a ℤ-digraph: `⊡` quantifies
over the walks whose state at `t` has the same `π`-class. Its truth at `(σ, t)` equals bundled
truth at `(π ∘ σ, t)` in the image bundle. With Part D this makes `cModel` a coarsened-state model
on the genuine task frame `cR` (`π := Option.isSome`), i.e. exactly the object the repo's
`not_naiveDerivable_of_cRefuted` pattern consumes. -/

section Coarse
variable {W K : Type} (R : W → W → Prop) (π : W → K) (V : K → ℕ → Prop)

def CT (σ : ℤ → W) (t : ℤ) : Fm → Prop
  | .atom p => V (π (σ t)) p
  | .bot => False
  | .imp φ ψ => CT σ t φ → CT σ t ψ
  | .box φ => ∀ ρ, IsWalk R ρ → CT ρ t φ
  | .untl ψ φ => ∃ s, t < s ∧ CT σ s φ ∧ ∀ r, t < r → r < s → CT σ r ψ
  | .snce ψ φ => ∃ s, s < t ∧ CT σ s φ ∧ ∀ r, s < r → r < t → CT σ r ψ
  | .stab φ => ∀ ρ, IsWalk R ρ → π (σ t) = π (ρ t) → CT ρ t φ

/-- The image bundle. -/
abbrev imageModel : BModel := ⟨K, V, {β | ∃ ρ, IsWalk R ρ ∧ β = fun n => π (ρ n)}⟩

theorem ct_iff_image (φ : Fm) : ∀ (σ : ℤ → W) (t : ℤ),
    CT R π V σ t φ ↔ T (imageModel R π V) (fun n => π (σ n)) t φ := by
  induction φ with
  | atom p => intros; exact Iff.rfl
  | bot => intros; exact Iff.rfl
  | imp φ ψ ih1 ih2 => intro σ t; exact Iff.imp (ih1 σ t) (ih2 σ t)
  | box φ ih =>
    intro σ t
    constructor
    · rintro h β ⟨ρ, hρ, rfl⟩; exact (ih ρ t).mp (h ρ hρ)
    · intro h ρ hρ; exact (ih ρ t).mpr (h _ ⟨ρ, hρ, rfl⟩)
  | untl ψ φ ihψ ihφ =>
    intro σ t
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ σ s)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ σ r)
  | snce ψ φ ihψ ihφ =>
    intro σ t
    exact exists_congr fun s => and_congr_right fun _ => and_congr (ihφ σ s)
      (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ σ r)
  | stab φ ih =>
    intro σ t
    constructor
    · rintro h β ⟨ρ, hρ, rfl⟩ he; exact (ih ρ t).mp (h ρ hρ he)
    · intro h ρ hρ he; exact (ih ρ t).mpr (h _ ⟨ρ, hρ, rfl⟩ he)

end Coarse

/-- The image bundle of `cR` under `π = isSome` is exactly `finRuns`. -/
theorem cR_image_eq :
    {β | ∃ ρ, IsWalk cR ρ ∧ β = fun n => (ρ n).isSome} = finRuns := by
  ext β
  constructor
  · rintro ⟨ρ, hρ, rfl⟩; exact image_walk_mem ρ hρ
  · intro hβ
    obtain ⟨σ, hσ, he⟩ := mem_image_walk β hβ
    exact ⟨σ, hσ, funext fun n => (he n).symm⟩

/-- **The coarsened-state countermodel, end to end**: on the digraph `cR` with `π = isSome` and
`p` read on the `a`-class, LC⁺ fails at every walk and time. -/
theorem lcPlus_refuted_coarse (σ : ℤ → Option ℕ) (hσ : IsWalk cR σ) (t : ℤ) :
    ¬ CT cR Option.isSome (fun c _ => c = true) σ t (lcPlus 0) := by
  rw [ct_iff_image]
  have key : ∀ S : Set (ℤ → Bool), S = finRuns →
      ¬ T ⟨Bool, fun c _ => c = true, S⟩ (fun n => (σ n).isSome) t (lcPlus 0) := by
    intro S hS; subst hS; exact lcPlus_refuted _ (image_walk_mem σ hσ) t
  exact key _ cR_image_eq


/-! ## REVIEW PART G — a Base-valid (X-free) limit-closure formula, refuted in a paste-closed bundle

`BLC := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` — the Burgess/Thomason formula
`□G(p → ◇Fp) → ◇G(p → Fp)` transposed to `⊡`. -/

theorem someFuture_iff (M : BModel) (σ : ℤ → M.C) (t : ℤ) (φ : Fm) :
    T M σ t φ.someFuture ↔ ∃ s, t < s ∧ T M σ s φ := by
  simp only [Fm.someFuture, Fm.top, T]
  constructor
  · rintro ⟨s, hs, h, -⟩; exact ⟨s, hs, h⟩
  · rintro ⟨s, hs, h⟩; exact ⟨s, hs, h, fun _ _ _ h => h⟩

def blc (p : ℕ) : Fm :=
  Fm.imp (Fm.and (Fm.dstab (Fm.someFuture (.atom p)))
      (Fm.stab (Fm.allFuture (Fm.imp (.atom p) (Fm.dstab (Fm.someFuture (.atom p)))))))
    (Fm.dstab (Fm.and (Fm.someFuture (.atom p))
      (Fm.allFuture (Fm.imp (.atom p) (Fm.someFuture (.atom p))))))

/-- Bundle: eventually always `false` (finitely many `p`-times in every future). -/
def evFalse : Set (ℤ → Bool) := {β | ∃ m, ∀ k, m ≤ k → β k = false}

abbrev eModel : BModel := ⟨Bool, fun c _ => c = true, evFalse⟩

theorem evFalse_pasteClosed : PasteClosed eModel := by
  intro ρ _ η hη s _
  obtain ⟨m, hm⟩ := hη
  refine ⟨max m (s + 1), fun k hk => ?_⟩
  simp only [paste]; rw [if_neg (by omega)]; exact hm k (by omega)

theorem evFalse_shiftClosed (β : ℤ → Bool) (hβ : β ∈ evFalse) (d : ℤ) :
    (fun n => β (n + d)) ∈ evFalse := by
  obtain ⟨m, hm⟩ := hβ
  exact ⟨m - d, fun k hk => hm (k + d) (by omega)⟩

theorem blc_refuted (σ : ℤ → Bool) (t : ℤ) : ¬ T eModel σ t (blc 0) := by
  intro h
  have hyp : T eModel σ t (Fm.and (Fm.dstab (Fm.someFuture (.atom 0)))
      (Fm.stab (Fm.allFuture (Fm.imp (.atom 0) (Fm.dstab (Fm.someFuture (.atom 0))))))) := by
    refine (and_iff _ _ _ _ _).mpr ⟨?_, ?_⟩
    · let ρ0 : ℤ → Bool := fun n => if n = t + 1 then true else if n = t then σ t else false
      refine (dstab_iff _ _ _ _).mpr ⟨ρ0, ⟨t + 2, fun k hk => ?_⟩, ?_,
        (someFuture_iff _ _ _ _).mpr ⟨t + 1, by omega, ?_⟩⟩
      · have h1 : k ≠ t + 1 := by omega
        have h2 : k ≠ t := by omega
        simp [ρ0, h1, h2]
      · show σ t = ρ0 t
        simp [ρ0]
      · show ρ0 (t + 1) = true
        simp [ρ0]
    · intro ρ _ _
      refine (allFuture_iff _ _ _ _).mpr fun s _ hp => ?_
      let η : ℤ → Bool := fun n => if n = s ∨ n = s + 1 then true else false
      refine (dstab_iff _ _ _ _).mpr ⟨η, ⟨s + 2, fun k hk => ?_⟩, ?_,
        (someFuture_iff _ _ _ _).mpr ⟨s + 1, by omega, ?_⟩⟩
      · have h1 : k ≠ s := by omega
        have h2 : k ≠ s + 1 := by omega
        simp [η, h1, h2]
      · have : ρ s = true := hp
        show ρ s = η s
        simp [η, this]
      · show η (s + 1) = true
        simp [η]
  obtain ⟨ρ, ⟨m, hm⟩, _, hc⟩ := (dstab_iff _ _ _ _).mp (h hyp)
  obtain ⟨hF, hG⟩ := (and_iff _ _ _ _ _).mp hc
  have key : ∀ j : ℕ, ∃ s, t + j < s ∧ ρ s = true := by
    intro j
    induction j with
    | zero =>
      obtain ⟨s, hs, hp⟩ := (someFuture_iff _ _ _ _).mp hF
      exact ⟨s, by simpa using hs, hp⟩
    | succ j ih =>
      obtain ⟨s, hs, hp⟩ := ih
      obtain ⟨s', hs', hp'⟩ :=
        (someFuture_iff _ _ _ _).mp ((allFuture_iff _ _ _ _).mp hG s (by omega) hp)
      exact ⟨s', by push_cast; omega, hp'⟩
  obtain ⟨s, hs, hp⟩ := key (m - t).toNat
  have := hm s (by omega)
  rw [this] at hp; exact Bool.false_ne_true hp

/-! ### BLC is valid on every full ℤ-model (ω-step version of the transfinite pasting argument) -/

section FullBLC
variable {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) (p : ℕ) (w : W) (t : ℤ)

/-- Stage invariant: walk through `w` at `t`, `p` at some time `> t + k`-ish marker `c`,
and every `p`-point in `(t, c)` has a later `p`-point `≤ c`. -/
def GoodB (c : ℤ) (ρ : ℤ → W) : Prop :=
  IsWalk R ρ ∧ ρ t = w ∧ t < c ∧ V (ρ c) p ∧ ∀ s, t < s → s < c → V (ρ s) p → ∃ s', s < s' ∧ s' ≤ c ∧ V (ρ s') p

variable (h2 : ∀ ρ, IsWalk R ρ → ρ t = w → ∀ s, t < s → V (ρ s) p →
    ∃ η, IsWalk R η ∧ η s = ρ s ∧ ∃ s', s < s' ∧ V (η s') p)

include h2 in
theorem goodB_step (c : ℤ) (ρ : ℤ → W) (hρ : GoodB R V p w t c ρ) :
    ∃ c' ρ', c < c' ∧ GoodB R V p w t c' ρ' ∧ ∀ n, n ≤ c → ρ' n = ρ n := by
  obtain ⟨hw, h0, htc, hpc, hinv⟩ := hρ
  obtain ⟨η, hη, hs, s', hs', hv⟩ := h2 ρ hw h0 c htc hpc
  have hagree : ∀ n, n ≤ c → paste ρ η c n = ρ n := fun n hn => by simp only [paste]; rw [if_pos hn]
  have hafter : ∀ n, c < n → paste ρ η c n = η n := fun n hn => by
    simp only [paste]; rw [if_neg (by omega)]
  refine ⟨s', paste ρ η c, hs', ⟨paste_walk R hw hη hs.symm, ?_, by omega, ?_, ?_⟩, hagree⟩
  · rw [hagree t (by omega)]; exact h0
  · rw [hafter s' hs']; exact hv
  · intro s hts hsc hps
    by_cases hlt : s < c
    · rw [hagree s (by omega)] at hps
      obtain ⟨s'', h1, h2', h3⟩ := hinv s hts hlt hps
      exact ⟨s'', h1, by omega, by rw [hagree s'' h2']; exact h3⟩
    · exact ⟨s', by omega, le_rfl, by rw [hafter s' hs']; exact hv⟩

end FullBLC


section FullBLC2
variable {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) (p : ℕ) (w : W) (t : ℤ)
variable (h2 : ∀ ρ, IsWalk R ρ → ρ t = w → ∀ s, t < s → V (ρ s) p →
    ∃ η, IsWalk R η ∧ η s = ρ s ∧ ∃ s', s < s' ∧ V (η s') p)

abbrev StageB := {x : ℤ × (ℤ → W) // GoodB R V p w t x.1 x.2}

noncomputable def chainB (x0 : StageB R V p w t) : ℕ → StageB R V p w t
  | 0 => x0
  | k + 1 =>
    ⟨(Classical.choose (goodB_step R V p w t h2 _ _ (chainB x0 k).2),
      Classical.choose (Classical.choose_spec (goodB_step R V p w t h2 _ _ (chainB x0 k).2))),
     (Classical.choose_spec (Classical.choose_spec
        (goodB_step R V p w t h2 _ _ (chainB x0 k).2))).2.1⟩

theorem chainB_lt (x0 : StageB R V p w t) (k : ℕ) :
    (chainB R V p w t h2 x0 k).1.1 < (chainB R V p w t h2 x0 (k + 1)).1.1 :=
  (Classical.choose_spec (Classical.choose_spec
    (goodB_step R V p w t h2 _ _ (chainB R V p w t h2 x0 k).2))).1

theorem chainB_agree1 (x0 : StageB R V p w t) (k : ℕ) (n : ℤ)
    (hn : n ≤ (chainB R V p w t h2 x0 k).1.1) :
    (chainB R V p w t h2 x0 (k + 1)).1.2 n = (chainB R V p w t h2 x0 k).1.2 n :=
  (Classical.choose_spec (Classical.choose_spec
    (goodB_step R V p w t h2 _ _ (chainB R V p w t h2 x0 k).2))).2.2 n hn

theorem chainB_mono (x0 : StageB R V p w t) (k m : ℕ) :
    (chainB R V p w t h2 x0 k).1.1 + m ≤ (chainB R V p w t h2 x0 (k + m)).1.1 := by
  induction m with
  | zero => simp
  | succ m ih =>
    have := chainB_lt R V p w t h2 x0 (k + m)
    rw [show k + (m + 1) = k + m + 1 from rfl]; push_cast; omega

theorem chainB_agree (x0 : StageB R V p w t) (k m : ℕ) (n : ℤ)
    (hn : n ≤ (chainB R V p w t h2 x0 k).1.1) :
    (chainB R V p w t h2 x0 (k + m)).1.2 n = (chainB R V p w t h2 x0 k).1.2 n := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [← ih]
    have := chainB_mono R V p w t h2 x0 k m
    exact chainB_agree1 R V p w t h2 x0 (k + m) n (by omega)

include h2 in
/-- **The X-free limit-closure lemma over ℤ.** -/
theorem limit_walkB (h1 : ∃ ρ, IsWalk R ρ ∧ ρ t = w ∧ ∃ s, t < s ∧ V (ρ s) p) :
    ∃ ρ, IsWalk R ρ ∧ ρ t = w ∧ (∃ s, t < s ∧ V (ρ s) p) ∧
      ∀ s, t < s → V (ρ s) p → ∃ s', s < s' ∧ V (ρ s') p := by
  obtain ⟨ρ0, hw0, ht0, s0, hs0, hp0⟩ := h1
  let x0 : StageB R V p w t := ⟨(s0, ρ0), hw0, ht0, hs0, hp0, fun s _ hsc _ => ⟨s0, hsc, le_rfl, hp0⟩⟩
  let c := chainB R V p w t h2 x0
  have cge : ∀ k : ℕ, s0 + k ≤ (c k).1.1 := fun k => by
    have := chainB_mono R V p w t h2 x0 0 k
    rw [Nat.zero_add] at this; exact this
  have agree : ∀ k k' : ℕ, ∀ n, n ≤ (c k).1.1 → n ≤ (c k').1.1 → (c k').1.2 n = (c k).1.2 n := by
    intro k k' n hk hk'
    rcases le_total k k' with hle | hle
    · obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hle
      exact chainB_agree R V p w t h2 x0 k m n hk
    · obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hle
      exact (chainB_agree R V p w t h2 x0 k' m n hk').symm
  let lim : ℤ → W := fun n => (c (n - s0).toNat).1.2 n
  have hK : ∀ n, n ≤ (c (n - s0).toNat).1.1 := fun n => by
    have := cge (n - s0).toNat; omega
  have lim_eq : ∀ k n, n ≤ (c k).1.1 → lim n = (c k).1.2 n := fun k n hn =>
    (agree k _ n hn (hK n))
  refine ⟨lim, ?_, ?_, ?_, ?_⟩
  · intro n
    have hn1 := hK (n + 1)
    rw [lim_eq (n + 1 - s0).toNat n (by omega), lim_eq (n + 1 - s0).toNat (n + 1) hn1]
    exact (c _).2.1 n
  · have ht : t ≤ (c 0).1.1 := by have := (c 0).2.2.2.1; omega
    rw [lim_eq 0 t ht]; exact (c 0).2.2.1
  · refine ⟨s0, hs0, ?_⟩
    rw [lim_eq 0 s0 le_rfl]; exact hp0
  · intro s hts hps
    have hs := hK s
    rw [lim_eq _ s hs] at hps
    rcases lt_or_eq_of_le hs with hlt | heq
    · obtain ⟨s', h1', h2', h3⟩ := (c (s - s0).toNat).2.2.2.2.2 s hts hlt hps
      exact ⟨s', h1', by rw [lim_eq _ s' h2']; exact h3⟩
    · have hlt : (c (s - s0).toNat).1.1 < (c ((s - s0).toNat + 1)).1.1 :=
        chainB_lt R V p w t h2 x0 (s - s0).toNat
      refine ⟨(c ((s - s0).toNat + 1)).1.1, by omega, ?_⟩
      rw [lim_eq _ _ le_rfl]; exact (c ((s - s0).toNat + 1)).2.2.2.2.1

end FullBLC2

/-- **BLC is valid over every ℤ-time task frame (all-histories semantics).** -/
theorem blc_valid_full {W : Type} (R : W → W → Prop) (V : W → ℕ → Prop) (p : ℕ)
    (σ : ℤ → W) (t : ℤ) : T (fullModel R V) σ t (blc p) := by
  intro h
  obtain ⟨h1, h2⟩ := (and_iff _ _ _ _ _).mp h
  obtain ⟨ρ0, hρ0, he0, hF0⟩ := (dstab_iff _ _ _ _).mp h1
  obtain ⟨s0, hs0, hp0⟩ := (someFuture_iff _ _ _ _).mp hF0
  obtain ⟨ρ, hρ, hρt, hF, hG⟩ := limit_walkB R V p (σ t) t
    (fun ρ hw ht s hs hv => by
      have := (allFuture_iff _ _ _ _).mp (h2 ρ hw ht.symm) s hs hv
      obtain ⟨η, hη, he, hn⟩ := (dstab_iff _ _ _ _).mp this
      obtain ⟨s', hs', hv'⟩ := (someFuture_iff _ _ _ _).mp hn
      exact ⟨η, hη, he.symm, s', hs', hv'⟩)
    ⟨ρ0, hρ0, he0.symm, s0, hs0, hp0⟩
  refine (dstab_iff _ _ _ _).mpr ⟨ρ, hρ, hρt.symm, (and_iff _ _ _ _ _).mpr ⟨?_, ?_⟩⟩
  · obtain ⟨s, hs, hv⟩ := hF
    exact (someFuture_iff _ _ _ _).mpr ⟨s, hs, hv⟩
  · refine (allFuture_iff _ _ _ _).mpr fun s hs hv => ?_
    obtain ⟨s', hs', hv'⟩ := hG s hs hv
    exact (someFuture_iff _ _ _ _).mpr ⟨s', hs', hv'⟩

/-! ### `evFalse` is the `π`-image of all walks of a genuine ℤ-frame

States `Option (Bool × ℕ)`: `none` is a `b`-hub `⊤` (`⊤ → x` for all `x`, only `⊤ → ⊤` into it);
`some (c, k)` is class `c` with a budget `k` bounding the number of future `a`-visits. -/

def eR : Option (Bool × ℕ) → Option (Bool × ℕ) → Prop
  | none, _ => True
  | some _, none => False
  | some (_, k), some (c', k') => k' ≤ k ∧ (c' = true → k' < k)

def eπ : Option (Bool × ℕ) → Bool
  | none => false
  | some (c, _) => c

theorem eR_budget (σ : ℤ → Option (Bool × ℕ)) (hσ : IsWalk eR σ) (n : ℤ) (c : Bool) (k : ℕ)
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

theorem eR_evFalse_aux (σ : ℤ → Option (Bool × ℕ)) (hσ : IsWalk eR σ) :
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

theorem eR_image_mem (σ : ℤ → Option (Bool × ℕ)) (hσ : IsWalk eR σ) :
    (fun n => eπ (σ n)) ∈ evFalse := by
  by_cases hall : ∀ n, σ n = none
  · exact ⟨0, fun j _ => by simp [hall j, eπ]⟩
  · push Not at hall
    obtain ⟨n, hn⟩ := hall
    cases h : σ n with
    | none => exact (hn h).elim
    | some x => obtain ⟨c, k⟩ := x; exact eR_evFalse_aux σ hσ k n c h

theorem mem_eR_image (β : ℤ → Bool) (hβ : β ∈ evFalse) :
    ∃ σ : ℤ → Option (Bool × ℕ), IsWalk eR σ ∧ ∀ n, eπ (σ n) = β n := by
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

theorem eR_image_eq :
    {β | ∃ ρ, IsWalk eR ρ ∧ β = fun n => eπ (ρ n)} = evFalse := by
  ext β
  constructor
  · rintro ⟨ρ, hρ, rfl⟩; exact eR_image_mem ρ hρ
  · intro hβ
    obtain ⟨σ, hσ, he⟩ := mem_eR_image β hβ
    exact ⟨σ, hσ, funext fun n => (he n).symm⟩

/-- **The coarsened-state countermodel to BLC, end to end.** -/
theorem blc_refuted_coarse (σ : ℤ → Option (Bool × ℕ)) (t : ℤ) :
    ¬ CT eR eπ (fun c _ => c = true) σ t (blc 0) := by
  rw [ct_iff_image]
  have key : ∀ S : Set (ℤ → Bool), S = evFalse →
      ¬ T ⟨Bool, fun c _ => c = true, S⟩ (fun n => eπ (σ n)) t (blc 0) := by
    intro S hS; subst hS; exact blc_refuted _ t
  exact key _ eR_image_eq

/-- Frame facts for Saturation (paper argument in the review): `eR` is transitive, dense, serial
both ways; forward fibres of non-hub states are finite; every other nonempty fibre/segment of
nonzero duration contains the hub. -/
theorem eR_trans {x y z : Option (Bool × ℕ)} (h1 : eR x y) (h2 : eR y z) : eR x z := by
  rcases x with _ | ⟨c, k⟩
  · trivial
  · rcases y with _ | ⟨c1, k1⟩
    · exact h1.elim
    · rcases z with _ | ⟨c2, k2⟩
      · exact h2.elim
      · exact ⟨le_trans h2.1 h1.1, fun hc => lt_of_lt_of_le (h2.2 hc) h1.1⟩

theorem eR_dense {x z : Option (Bool × ℕ)} (h : eR x z) : ∃ y, eR x y ∧ eR y z := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial, trivial⟩
  · rcases z with _ | ⟨c2, k2⟩
    · exact h.elim
    · exact ⟨some (false, k), ⟨le_rfl, by simp⟩, h⟩

theorem eR_succ (x : Option (Bool × ℕ)) : ∃ y, eR x y := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial⟩
  · exact ⟨some (false, k), le_rfl, by simp⟩

theorem eR_from_hub (y : Option (Bool × ℕ)) : eR none y := trivial

#print axioms blc_valid_full
#print axioms blc_refuted_coarse

end Probe559
