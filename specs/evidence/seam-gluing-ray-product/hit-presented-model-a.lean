/-
Probe 745 (requirement (C) of the ray-product verdict), **part 1 of the record: the fixture and
the step-path classification.** This file is being built up phase by phase toward the headline
`∃ L, HitPresented MA stayA t Fp (labOf L) (stepOf L) k`; what is landed here is the fixture
(model A of the B2b verdict probe, transcribed) together with the **rigidity** result that makes
the rest possible: every step path of model A through the seam `(t, a)` is either the constant
`a`-path or an `a`-then-`b` jump path whose jump time is `≥ t`. Nothing in this file yet mentions
`HitCl`, `hitOf` or `HitPresented`.

**The fixture.** Model A of `quasistate-does-not-determine-hit.lean` and of
`presented-not-complete.lean` (three states on `Fin 3`, `p` at `b` only, steps `a→a, a→b, b→b`),
transcribed and never imported, as this collection's convention requires; closure
`cl = {p, Fp}` with `Fp := someFuture (.atom pa)`. Bi-serial, built by `FrameOver.ofSlicedStep`,
regular through `FrameOver.ofSlicedStep_isRegular`. The seam is `(t, a)` on the constant history
`stayA`.

**The argument, in two sentences.** The sliced step relation `RA t u v := v = u ∨ v = b` makes a
step path's time component advance by exactly one (so it is pinned by its value at `t`), makes `a`
reachable only from `a` (so the slice is pinned at `a` everywhere at or before the seam), and
makes `b` absorbing (so once the slice is `b` it stays `b`). Taking `Nat.find` of the first
forward index at which the slice is `b` therefore turns the path into `jump w` for `w ≥ t`, and
the absence of such an index leaves the constant `a`-path.

**What is NOT established.** No bound of any kind — the later phases' headline carries an
unexhibited `∃ L` extracted from `Set.Finite.bddAbove`, i.e. from `Classical.choice`, and this
file establishes nothing that would make such an `L` effective. Forward-only: nothing about
`⊡(P p)`, because the fixture is forward-only and there is still no backward Bool-fixture bridge
(`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture remains the only
backward fixture result, and no symmetry is implied here). No decidability of anything:
`Decidable (PlusValidZTime φ)` is NOT stated in any form, conditional or otherwise, and no claim
is made that L⁺ is decidable, qualified or not. No complexity bound, upper or lower. Nothing
about general regular `ℤ`-models (see the next paragraph). Nothing about models whose slices are
infinite: this fixture's slice is `Fin 3` while its carrier `ℤ × Fin 3` is infinite, which is the
shape `NoFiniteWidth.not_finite_width_fmp` leaves standing, so no finite-fibre or finite-width
assumption is made or needed anywhere in this file.

**This does NOT generalize.** Model A's splices are eventually constant in BOTH directions, and
that is exactly what lets a finite presentation realize finitely many of them exactly. For a
general regular `ℤ`-model the route needs one lasso per family triple, and the `⊆` direction of
that route is open. The classification below is a fact about `RA` specifically — it is read off
`v = u ∨ v = b` — and nothing in it survives replacement of the fixture.

**This does NOT weaken or retire `Probe735.not_presented`.** That probe refutes an equality of
TRACE sets (`RaySummary.Presented`); this record establishes an equality of FAMILY-TRIPLE sets
(`RaySummary.HitPresented`). The presentation this record builds is deliberately NOT `Presented`
— it realizes only finitely many of the seam's traces — so there is no conflict: both hold
simultaneously on the same fixture, at the same seam, for the same `φ`. Task 735's verdict and
its wired probe stand unchanged.

**The decision held in place.** The Hit-level hypothesis named in `Probe735.not_presented`'s
header is SATISFIABLE, not refuted: the forward-type observation that blocked the transfer of
735's refutation is real, so the obstruction that killed `Presented` does not reach `HitPresented`,
and the route through (C) is not closed by 735. The companion decision, recorded by the later
phases rather than here, is that satisfiability buys no bound.

**Axiom record.** `path_classify` and the fixture's history definitions: see the `#print axioms`
foot. `Classical.choice` is inherited from `FrameOver.worldHistoryOfStepPath` and from the
`Nat.find`/`by_cases` bookkeeping in `path_classify`, as in every probe of this collection.
Nothing in this file is left unproved: zero sorries.

**Compile line.**
`lake env lean specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`
(wiring into `scripts/check-evidence-probes.sh` lands with the headline in this record's final
phase).
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe745

/-! ## The fixture (model A of the B2b verdict probe, re-declared) -/

abbrev St := Fin 3

def a : St := 0
def b : St := 1

def pa : Atom := ⟨"p", none⟩

abbrev Fp : PlusFormula := someFuture (.atom pa)

/-- Fixture model A's sliced step relation: stay, or jump to `b`. -/
def RA : ℤ → St → St → Prop := fun _ u v => v = u ∨ v = b

theorem RA_fwd : ∀ (t : ℤ) (w : St), ∃ u, RA t w u := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_bwd : ∀ (t : ℤ) (w : St), ∃ v, RA (t - 1) v w := fun _ w => ⟨w, Or.inl rfl⟩
theorem RA_aa : ∀ t, RA t a a := fun _ => Or.inl rfl
theorem RA_ab : ∀ t, RA t a b := fun _ => Or.inr rfl
theorem RA_bb : ∀ t, RA t b b := fun _ => Or.inl rfl

abbrev FA : FrameOver intOrder := FrameOver.ofSlicedStep RA RA_fwd RA_bwd

instance instFARegular : FA.IsRegular := FrameOver.ofSlicedStep_isRegular RA RA_fwd RA_bwd

theorem ab_ne : a ≠ b := by decide

/-- `p` holds exactly at `b`. -/
def MA : TaskModel FA.toTaskFrame where
  valuation q _ := q.2 = b

/-- The constant history at `a`. -/
noncomputable def stayA : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, a)) (by
    intro z
    exact (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, RA_aa z⟩)

theorem stayA_state (z : ℤ) : stayA.state z = (z, a) := rfl

/-- The history at `a` up to `w` and at `b` from `w + 1`. -/
noncomputable def jump (w : ℤ) : WorldHistory FA.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath FA (fun z => (z, if w < z then b else a)) (by
    intro z
    refine (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mpr ⟨rfl, ?_⟩
    show RA z (if w < z then b else a) (if w < z + 1 then b else a)
    by_cases h : w < z
    · rw [if_pos h, if_pos (by omega)]
      exact RA_bb z
    · rw [if_neg h]
      by_cases h' : w < z + 1
      · rw [if_pos h']
        exact RA_ab z
      · rw [if_neg h']
        exact RA_aa z)

theorem jump_state (w z : ℤ) : (jump w).state z = (z, if w < z then b else a) := rfl

theorem p_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z (.atom pa) ↔ (σ.state z).2 = b := Iff.rfl

theorem Fp_iff (σ : WorldHistory FA.toTaskFrame) (z : ℤ) :
    PlusTruthAt MA σ z Fp ↔ ∃ s, z < s ∧ (σ.state s).2 = b :=
  PlusTruth.someFuture_iff _ _ _ _

theorem jump_p_iff (w z : ℤ) : PlusTruthAt MA (jump w) z (.atom pa) ↔ w < z := by
  rw [p_iff, jump_state]
  by_cases h : w < z
  · simp [h]
  · simp [h, a, b]

theorem jump_Fp (w z : ℤ) : PlusTruthAt MA (jump w) z Fp := by
  rw [Fp_iff]
  refine ⟨max w z + 1, by omega, ?_⟩
  rw [jump_state]
  show (if w < max w z + 1 then b else a) = b
  rw [if_pos (by omega)]

/-! ## Step-path rigidity on model A at the seam `(t, a)`

Everything in this section is a fact about `RA` — read off `v = u ∨ v = b` — and nothing in it
survives replacement of the fixture. -/

theorem stepA {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (z : ℤ) :
    (g (z + 1)).1 = (g z).1 + 1 ∧ RA (g z).1 (g z).2 (g (z + 1)).2 :=
  (FrameOver.ofSlicedStep_step RA RA_fwd RA_bwd _ _).mp (hg z)

/-- The time component advances by one, so it is pinned by its value at `t`. -/
theorem time_eq {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).1 = t) :
    ∀ z, (g z).1 = z := by
  have key : ∀ n : ℤ, (g (t + n)).1 = t + n := by
    intro n
    induction n using Int.induction_on with
    | zero => simpa using ht
    | succ i ih =>
      have := (stepA hg (t + i)).1
      rw [ih] at this
      rw [show t + ((i : ℤ) + 1) = t + (i : ℤ) + 1 by ring, this]
    | pred i ih =>
      have := (stepA hg (t + (-(i : ℤ) - 1))).1
      rw [show t + (-(i : ℤ) - 1) + 1 = t + -(i : ℤ) by ring, ih] at this
      omega
  intro z
  have := key (z - t)
  simpa using this

/-- Backward from the seam the slice is pinned at `a`: in `RA`, `a` is reachable only from `a`. -/
theorem bwd_a {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).2 = a) :
    ∀ z ≤ t, (g z).2 = a := by
  have key : ∀ n : ℕ, (g (t - n)).2 = a := by
    intro n
    induction n with
    | zero => simpa using ht
    | succ i ih =>
      have h := (stepA hg (t - (i + 1 : ℕ))).2
      push_cast at h ih ⊢
      rw [show t - ((i : ℤ) + 1) + 1 = t - (i : ℤ) by ring, ih] at h
      rcases h with h | h
      · exact h.symm
      · exact absurd h ab_ne
  intro z hz
  have := key (t - z).toNat
  rwa [show t - ((t - z).toNat : ℤ) = z by omega] at this

/-- Forward from the seam the slice is `a` or `b`. -/
theorem fwd_dichotomy {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ) (ht : (g t).2 = a) :
    ∀ n : ℕ, (g (t + n)).2 = a ∨ (g (t + n)).2 = b := by
  intro n
  induction n with
  | zero => exact Or.inl (by simpa using ht)
  | succ i ih =>
    have h := (stepA hg (t + (i : ℕ))).2
    push_cast at h ih ⊢
    rw [show t + ((i : ℤ) + 1) = t + (i : ℤ) + 1 by ring]
    rcases h with h | h
    · rw [h]; exact ih
    · exact Or.inr h

/-- `b` absorbs. -/
theorem fwd_absorb {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (z : ℤ) (h : (g z).2 = b) :
    (g (z + 1)).2 = b := by
  have h2 := (stepA hg z).2
  rcases h2 with h2 | h2
  · rw [h2, h]
  · exact h2

/-- **The seam's step paths, classified.** Every step path through `(t, a)` is the constant
`a`-path or an `a`-then-`b` jump path with jump time `w ≥ t`. This is the rigidity the rest of
the record rests on: the seam's splices form a one-parameter family indexed by `w ≥ t`, plus the
constant path, and nothing else. -/
theorem path_classify {g : ℤ → ℤ × St} (hg : IsStepPath FA g) (t : ℤ)
    (ht1 : (g t).1 = t) (ht2 : (g t).2 = a) :
    (∀ z, g z = (z, a)) ∨ ∃ w : ℤ, t ≤ w ∧ ∀ z, g z = (z, if w < z then b else a) := by
  have htime := time_eq hg t ht1
  have habs : ∀ (m : ℕ) (z : ℤ), (g z).2 = b → (g (z + m)).2 = b := by
    intro m
    induction m with
    | zero => intro z h; simpa using h
    | succ i ih =>
      intro z h
      have hstep := fwd_absorb hg (z + i) (ih z h)
      rwa [show z + ((i + 1 : ℕ) : ℤ) = z + (i : ℤ) + 1 by push_cast; ring]
  by_cases h : ∃ n : ℕ, (g (t + n)).2 = b
  · right
    classical
    set n0 : ℕ := Nat.find h with hn0
    have hspec : (g (t + (n0 : ℤ))).2 = b := Nat.find_spec h
    have hmin : ∀ m : ℕ, m < n0 → (g (t + (m : ℤ))).2 ≠ b := fun m hm => Nat.find_min h hm
    have hn0pos : 0 < n0 := by
      rcases Nat.eq_zero_or_pos n0 with h0 | h0
      · exfalso
        rw [h0] at hspec
        simp only [Nat.cast_zero, add_zero] at hspec
        exact ab_ne (ht2.symm.trans hspec)
      · exact h0
    refine ⟨t + (n0 : ℤ) - 1, by omega, ?_⟩
    intro z
    refine Prod.ext (htime z) ?_
    by_cases hz : t + (n0 : ℤ) - 1 < z
    · rw [if_pos hz]
      have := habs (z - (t + (n0 : ℤ))).toNat (t + (n0 : ℤ)) hspec
      rwa [show t + (n0 : ℤ) + ((z - (t + (n0 : ℤ))).toNat : ℤ) = z by omega] at this
    · rw [if_neg hz]
      by_cases hzt : z ≤ t
      · exact bwd_a hg t ht2 z hzt
      · have hlt : (z - t).toNat < n0 := by omega
        rcases fwd_dichotomy hg t ht2 (z - t).toNat with hc | hc
        · rwa [show t + (((z - t).toNat : ℕ) : ℤ) = z by omega] at hc
        · exact absurd (show (g (t + (((z - t).toNat : ℕ) : ℤ))).2 = b from hc) (hmin _ hlt)
  · left
    simp only [not_exists] at h
    intro z
    refine Prod.ext (htime z) ?_
    by_cases hzt : z ≤ t
    · exact bwd_a hg t ht2 z hzt
    · rcases fwd_dichotomy hg t ht2 (z - t).toNat with hc | hc
      · rwa [show t + (((z - t).toNat : ℕ) : ℤ) = z by omega] at hc
      · exact absurd hc (h _)

#print axioms path_classify
#print axioms stayA
#print axioms jump

end Probe745
