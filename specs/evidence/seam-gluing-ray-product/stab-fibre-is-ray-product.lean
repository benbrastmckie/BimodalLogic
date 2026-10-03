/-
Probe 718: **the `⊡` fibre IS the fibre product of the past-ray and future-ray spaces over the
seam state** — the keystone the round's every downstream route assumes, settled affirmatively.

Three parts.

- **Part 1 (general task frame, any duration).** `PastRay F t` and `FutRay F t` are the convex
  histories on the half-lines `(-∞, t]` and `[t, ∞)`, presented as dependent functions on the
  time subtypes so that equality is funext. `seamFibreEquiv` is an `Equiv` between the `⊡`
  quantification domain `{σ : WorldHistory F // σ.state t = s}` and the fibre product
  `{(b, f) // b t = s ∧ f t = s}`. The construction uses *Compositionality* and the reflection
  convention ONLY: no *Saturation*, no Extension Theorem, no Zorn, no `Classical.choice`, no
  frame-class assumption. This is the paper's `app:gluing` at the seam — its `⌢_z` — in the one
  case the paper's own (commented-out) pasting passage needs, and in `Equiv` rather than
  closure-only form.
- **Part 2 (ω-sequences, over ℤ).** `seamOmegaEquiv`: over a regular ℤ-frame the same fibre is
  equivalent to `BwdSeq × FwdSeq`, the pairs of **ω-indexed** step sequences out of the seam
  state — the round's "re-base on ω-sequences" proposal, as a theorem about the landed ℤ-time
  semantics rather than a new semantics. The backward factor is an ω-sequence run *against* the
  arrow of time; this is where the two-sidedness of the landed refutations is located.
- **Part 3 (the `⊡` clause).** `plusStab_iff_rays` / `plusStab_iff_omega`: `⊡φ` at `(τ, t)` iff
  `φ` holds at every seam gluing / at every pair of ω-sequences through `τ.state t`. This is the
  decidability-relevant form: `⊡` is a quantifier over a PRODUCT OF TWO PATH SPACES.

What this does NOT do, stated so the report cannot overclaim: it bounds nothing, decides nothing,
and evades no refutation. `not_finite_width_fmp` stands untouched — Part 3 is precisely the
*mechanism* behind it (a product of two path spaces cannot be a finite fibre), not an escape from
it.

Compile-check from the repository root with:
  lake env lean specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean
-/
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace Probe718

/-! ## Part 1: the seam fibre product at a general task frame -/

section General

variable {F : TaskFrame}

/-- A **past ray** at `t`: a convex history on `(-∞, t]`, as a dependent function on the times
`≤ t` with the all-pairs task constraint. The domain is a subtype rather than a predicate on all
of `F.Duration` so that two rays are equal exactly when their values agree (funext). -/
def PastRay (F : TaskFrame) (t : F.Duration) : Type _ :=
  {g : {x : F.Duration // x ≤ t} → F.WorldState //
    ∀ x y : {x : F.Duration // x ≤ t}, F.TaskRel (g x) (y.1 - x.1) (g y)}

/-- A **future ray** at `t`: a convex history on `[t, ∞)`. -/
def FutRay (F : TaskFrame) (t : F.Duration) : Type _ :=
  {g : {x : F.Duration // t ≤ x} → F.WorldState //
    ∀ x y : {x : F.Duration // t ≤ x}, F.TaskRel (g x) (y.1 - x.1) (g y)}

/-- The seam value of a past ray: its state at `t`, the right endpoint. -/
def PastRay.seam {t : F.Duration} (b : PastRay F t) : F.WorldState := b.1 ⟨t, le_rfl⟩

/-- The seam value of a future ray: its state at `t`, the left endpoint. -/
def FutRay.seam {t : F.Duration} (f : FutRay F t) : F.WorldState := f.1 ⟨t, le_rfl⟩

/-- The pasted state function of a ray pair: the past ray up to and including `t`, the future ray
after. -/
def glueFun {t : F.Duration} (b : PastRay F t) (f : FutRay F t) :
    F.Duration → F.WorldState :=
  fun s => if h : s ≤ t then b.1 ⟨s, h⟩ else f.1 ⟨s, (not_le.mp h).le⟩

/-- The task relation across the seam, from the past ray at `s ≤ t` to the future ray at
`s' > t`: *Compositionality* through the shared seam state. This is the only place a frame law is
used, and it is `TaskFrame.comp` alone. -/
theorem glue_rel_le_lt [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (b.1 ⟨s, hs⟩) (s' - s) (f.1 ⟨s', (not_le.mp hs').le⟩) := by
  have h1 : F.TaskRel (b.1 ⟨s, hs⟩) (t - s) (b.1 ⟨t, le_rfl⟩) := b.2 ⟨s, hs⟩ ⟨t, le_rfl⟩
  have h2 : F.TaskRel (f.1 ⟨t, le_rfl⟩) (s' - t) (f.1 ⟨s', (not_le.mp hs').le⟩) :=
    f.2 ⟨t, le_rfl⟩ ⟨s', (not_le.mp hs').le⟩
  rw [show b.1 ⟨t, le_rfl⟩ = f.1 ⟨t, le_rfl⟩ from hseam] at h1
  have heq : s' - s = (t - s) + (s' - t) := by
    rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm
  rw [heq]
  exact (F.comp _ _ _ _ (sub_nonneg.mpr hs) (sub_nonneg.mpr (le_of_lt (not_le.mp hs')))).mpr
    ⟨_, h1, h2⟩

/-- The glued state function respects the task relation at every pair of times. -/
theorem glue_rel [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) :
    ∀ s s' : F.Duration, F.TaskRel (glueFun b f s) (s' - s) (glueFun b f s') := by
  intro s s'
  unfold glueFun
  by_cases hs : s ≤ t <;> by_cases hs' : s' ≤ t
  · rw [dif_pos hs, dif_pos hs']; exact b.2 ⟨s, hs⟩ ⟨s', hs'⟩
  · rw [dif_pos hs, dif_neg hs']; exact glue_rel_le_lt b f hseam hs hs'
  · rw [dif_neg hs, dif_pos hs', F.reflection, neg_sub]
    exact glue_rel_le_lt b f hseam hs' hs
  · rw [dif_neg hs, dif_neg hs']
    exact f.2 ⟨s, (not_le.mp hs).le⟩ ⟨s', (not_le.mp hs').le⟩

/-- **Seam gluing.** A past ray and a future ray agreeing at the seam glue to a possible world.
Choice-free: `glue_rel` uses *Compositionality* and the reflection convention and nothing else. -/
def glue [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) : WorldHistory F :=
  WorldHistory.ofTotal F (glueFun b f) (glue_rel b f hseam)

@[simp]
theorem glue_state_of_le [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s : F.Duration} (hs : s ≤ t) :
    (glue b f hseam).state s = b.1 ⟨s, hs⟩ := by
  show glueFun b f s = _
  rw [glueFun, dif_pos hs]

@[simp]
theorem glue_state_of_not_le [F.IsRegular] {t : F.Duration} (b : PastRay F t) (f : FutRay F t)
    (hseam : b.seam = f.seam) {s : F.Duration} (hs : ¬ s ≤ t) :
    (glue b f hseam).state s = f.1 ⟨s, (not_le.mp hs).le⟩ := by
  show glueFun b f s = _
  rw [glueFun, dif_neg hs]

/-- The `⊡` quantification domain at `(t, s)`: the possible worlds in state `s` at time `t`.
This is `PlusTruth.stab_iff`'s domain verbatim. -/
def StabFibre (F : TaskFrame) (t : F.Duration) (s : F.WorldState) : Type _ :=
  {σ : WorldHistory F // σ.state t = s}

/-- The **fibre product** of the past-ray and future-ray spaces over the seam state `s`. -/
def RayPair (F : TaskFrame) (t : F.Duration) (s : F.WorldState) : Type _ :=
  {bf : PastRay F t × FutRay F t // bf.1.seam = s ∧ bf.2.seam = s}

/-- Restriction of a possible world to the past half-line. -/
def pastOf (σ : WorldHistory F) (t : F.Duration) : PastRay F t :=
  ⟨fun x => σ.state x.1, fun x y => σ.respects_task x.1 y.1⟩

/-- Restriction of a possible world to the future half-line. -/
def futOf (σ : WorldHistory F) (t : F.Duration) : FutRay F t :=
  ⟨fun x => σ.state x.1, fun x y => σ.respects_task x.1 y.1⟩

/--
**THE KEYSTONE.** The `⊡` fibre over a seam state is the fibre product of the past-ray and
future-ray spaces over that state.

Forward: restrict. Backward: glue. The two round trips are `WorldHistory.ext_state` and funext.
Nothing beyond *Compositionality* and the reflection convention is used, at any duration.
-/
def seamFibreEquiv [F.IsRegular] (t : F.Duration) (s : F.WorldState) :
    StabFibre F t s ≃ RayPair F t s where
  toFun σ := ⟨(pastOf σ.1 t, futOf σ.1 t), σ.2, σ.2⟩
  invFun bf := ⟨glue bf.1.1 bf.1.2 (bf.2.1.trans bf.2.2.symm),
    by rw [glue_state_of_le _ _ _ le_rfl]; exact bf.2.1⟩
  left_inv := by
    rintro ⟨σ, hσ⟩
    refine Subtype.ext (WorldHistory.ext_state fun r => ?_)
    by_cases hr : r ≤ t
    · rw [glue_state_of_le _ _ _ hr]; rfl
    · rw [glue_state_of_not_le _ _ _ hr]; rfl
  right_inv := by
    rintro ⟨⟨b, f⟩, hb, hf⟩
    have hseam : b.seam = f.seam := hb.trans hf.symm
    refine Subtype.ext (Prod.ext (Subtype.ext (funext fun x => ?_))
      (Subtype.ext (funext fun x => ?_)))
    · show (glue b f hseam).state x.1 = b.1 x
      rw [glue_state_of_le _ _ _ x.2]
    · show (glue b f hseam).state x.1 = f.1 x
      by_cases hx : x.1 ≤ t
      · have hxt : x.1 = t := le_antisymm hx x.2
        rw [glue_state_of_le _ _ _ hx]
        have hb' : b.1 ⟨x.1, hx⟩ = s := by
          rw [show (⟨x.1, hx⟩ : {y : F.Duration // y ≤ t}) = ⟨t, le_rfl⟩ from Subtype.ext hxt]
          exact hb
        have hf' : f.1 x = s := by
          rw [show x = (⟨t, le_rfl⟩ : {y : F.Duration // t ≤ y}) from Subtype.ext hxt]
          exact hf
        rw [hb', hf']
      · rw [glue_state_of_not_le _ _ _ hx]

end General

/-! ## Part 3a: the `⊡` clause as a quantifier over ray pairs -/

section Stab

variable {F : TaskFrame} [F.IsRegular]

/--
**`⊡` is a quantifier over a product of two path spaces.** `⊡φ` holds at `(τ, t)` exactly when
`φ` holds at every gluing of a past ray and a future ray through `τ`'s state at `t`.

This is the decidability-relevant restatement: the quantification is over PAIRS, one factor
running backward from the seam and one forward.
-/
theorem plusStab_iff_rays (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ (b : PastRay F t) (f : FutRay F t) (hb : b.seam = τ.state t) (hf : f.seam = τ.state t),
        PlusTruthAt M (glue b f (hb.trans hf.symm)) t φ := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h b f hb hf
    refine h _ ?_
    rw [glue_state_of_le _ _ _ le_rfl]
    exact hb.symm
  · intro h σ hσ
    have hb : (pastOf σ t).seam = τ.state t := hσ.symm
    have hf : (futOf σ t).seam = τ.state t := hσ.symm
    have hglue : glue (pastOf σ t) (futOf σ t) (hb.trans hf.symm) = σ := by
      refine WorldHistory.ext_state fun r => ?_
      by_cases hr : r ≤ t
      · rw [glue_state_of_le _ _ _ hr]; rfl
      · rw [glue_state_of_not_le _ _ _ hr]; rfl
    have := h (pastOf σ t) (futOf σ t) hb hf
    rwa [hglue] at this

end Stab

/-! ## Part 2: the ω-sequence form over ℤ -/

section Omega

variable {F : FrameOver intOrder}

/-- A **backward ω-sequence**: each `b (n+1)` steps to `b n`. The ω-indexing runs *against* the
arrow of time, which is exactly the half of the structure a forward-only re-basing deletes. -/
def BwdSeq (F : FrameOver intOrder) : Type _ :=
  {b : ℕ → F.WorldState // ∀ n, F.step (b (n + 1)) (b n)}

/-- A **forward ω-sequence**: each `f n` steps to `f (n+1)`. -/
def FwdSeq (F : FrameOver intOrder) : Type _ :=
  {f : ℕ → F.WorldState // ∀ n, F.step (f n) (f (n + 1))}

/-- The fibre product of the two ω-sequence spaces over the seam state `s`. -/
def SeqPair (F : FrameOver intOrder) (s : F.WorldState) : Type _ :=
  {bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}

/-- The `⊡` fibre read on bare bi-infinite step paths, via the landed
`FrameOver.mem_HF_iff_adjacent`. -/
def ZPathFibre (F : FrameOver intOrder) (t : ℤ) (s : F.WorldState) : Type _ :=
  {g : ℤ → F.WorldState // IsStepPath F g ∧ g t = s}

variable [F.IsRegular]

/-- Possible worlds in a given state at a given time are exactly the step paths through that
state: `WorldHistory.ext_state` one way, `FrameOver.worldHistoryOfStepPath` the other. -/
def pathFibreEquiv (t : ℤ) (s : F.WorldState) :
    StabFibre F.toTaskFrame t s ≃ ZPathFibre F t s where
  toFun σ := ⟨σ.1.path, σ.1.isStepPath, σ.2⟩
  invFun g := ⟨FrameOver.worldHistoryOfStepPath F g.1 g.2.1, g.2.2⟩
  left_inv := by
    rintro ⟨σ, hσ⟩
    exact Subtype.ext (WorldHistory.ext_state fun r => rfl)
  right_inv := by
    rintro ⟨g, hg, hgt⟩
    exact Subtype.ext rfl

/-- The glued path of an ω-sequence pair: the forward sequence from `t` on, the backward sequence
strictly before. -/
def splice (t : ℤ) (b : BwdSeq F) (f : FwdSeq F) : ℤ → F.WorldState :=
  fun z => if t ≤ z then f.1 (z - t).natAbs else b.1 (t - z).natAbs

omit [F.IsRegular] in
/-- The spliced path is a bi-infinite step path. The only non-routine case is the seam step
`z + 1 = t`, where the shared base point `b 0 = s = f 0` is used. -/
theorem splice_isStepPath (t : ℤ) (b : BwdSeq F) (f : FwdSeq F) {s : F.WorldState}
    (hb : b.1 0 = s) (hf : f.1 0 = s) : IsStepPath F (splice t b f) := by
  intro z
  unfold splice
  by_cases hz : t ≤ z
  · rw [if_pos hz, if_pos (by omega : t ≤ z + 1)]
    have e : (z + 1 - t).natAbs = (z - t).natAbs + 1 := by omega
    rw [e]
    exact f.2 _
  · rw [if_neg hz]
    by_cases hz1 : t ≤ z + 1
    · rw [if_pos hz1]
      have e1 : (t - z).natAbs = 0 + 1 := by omega
      have e2 : (z + 1 - t).natAbs = 0 := by omega
      rw [e1, e2, hf, ← hb]
      exact b.2 0
    · rw [if_neg hz1]
      have e : (t - z).natAbs = (t - (z + 1)).natAbs + 1 := by omega
      rw [e]
      exact b.2 _

/--
**The ω-splitting of the fibre.** The step paths through a state `s` at time `t` are exactly the
pairs of a backward and a forward ω-step-sequence based at `s`.
-/
def omegaSplitEquiv (t : ℤ) (s : F.WorldState) :
    ZPathFibre F t s ≃ SeqPair F s where
  toFun g :=
    ⟨(⟨fun n => g.1 (t - n), fun n => by
        have h := g.2.1 (t - ((n + 1 : ℕ) : ℤ))
        rwa [show t - ((n + 1 : ℕ) : ℤ) + 1 = t - (n : ℕ) by push_cast; ring] at h⟩,
      ⟨fun n => g.1 (t + n), fun n => by
        have h := g.2.1 (t + ((n : ℕ) : ℤ))
        rwa [show t + ((n : ℕ) : ℤ) + 1 = t + ((n + 1 : ℕ) : ℤ) by push_cast; ring] at h⟩),
     by
      refine ⟨?_, ?_⟩
      · show g.1 (t - ((0 : ℕ) : ℤ)) = s
        rw [show t - ((0 : ℕ) : ℤ) = t by push_cast; ring]; exact g.2.2
      · show g.1 (t + ((0 : ℕ) : ℤ)) = s
        rw [show t + ((0 : ℕ) : ℤ) = t by push_cast; ring]; exact g.2.2⟩
  invFun bf :=
    ⟨splice t bf.1.1 bf.1.2, splice_isStepPath t bf.1.1 bf.1.2 bf.2.1 bf.2.2, by
      show splice t bf.1.1 bf.1.2 t = s
      unfold splice
      rw [if_pos (le_refl t), show (t - t).natAbs = 0 by omega]
      exact bf.2.2⟩
  left_inv := by
    rintro ⟨g, hg, hgt⟩
    refine Subtype.ext (funext fun z => ?_)
    show splice t _ _ z = g z
    unfold splice
    by_cases hz : t ≤ z
    · rw [if_pos hz]
      show g (t + (((z - t).natAbs : ℕ) : ℤ)) = g z
      congr 1
      omega
    · rw [if_neg hz]
      show g (t - (((t - z).natAbs : ℕ) : ℤ)) = g z
      congr 1
      omega
  right_inv := by
    rintro ⟨⟨b, f⟩, hb, hf⟩
    refine Subtype.ext (Prod.ext (Subtype.ext (funext fun n => ?_))
      (Subtype.ext (funext fun n => ?_)))
    · show splice t b f (t - ((n : ℕ) : ℤ)) = b.1 n
      unfold splice
      by_cases hn : t ≤ t - ((n : ℕ) : ℤ)
      · have hn0 : n = 0 := by omega
        subst hn0
        rw [if_pos hn, show (t - ((0 : ℕ) : ℤ) - t).natAbs = 0 by push_cast; omega, hf, ← hb]
      · rw [if_neg hn, show (t - (t - ((n : ℕ) : ℤ))).natAbs = n by omega]
    · show splice t b f (t + ((n : ℕ) : ℤ)) = f.1 n
      unfold splice
      rw [if_pos (by omega : t ≤ t + ((n : ℕ) : ℤ)),
        show (t + ((n : ℕ) : ℤ) - t).natAbs = n by omega]

/--
**The ω-sequence form of the keystone.** Over a regular ℤ-frame the `⊡` fibre over a seam state
is equivalent to the pairs of ω-indexed step sequences out of that state.

This is the round's "re-base the semantics on ω-sequences" proposal, proved as a theorem ABOUT
the landed ℤ-time semantics: no new semantics is introduced, and the backward factor is retained
as an ω-sequence run against the arrow of time rather than deleted.
-/
def seamOmegaEquiv (t : ℤ) (s : F.WorldState) :
    StabFibre F.toTaskFrame t s ≃ SeqPair F s :=
  (pathFibreEquiv t s).trans (omegaSplitEquiv t s)

end Omega

/-! ## Part 3b: the `⊡` clause over ω-sequence pairs -/

section StabOmega

variable {F : FrameOver intOrder} [F.IsRegular]

/--
**`⊡` as a quantifier over pairs of ω-sequences.** The form a decision procedure would have to
check: for every pair of a backward and a forward ω-step-sequence out of the present state.

A deterministic ω-automaton running along each factor is the standard way to summarise such a
quantification finitely; that is the content of the round's ω-automata route, and this theorem is
what makes it the SAME route as the infinite-fibre route.
-/
theorem plusStab_iff_omega (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ bf : SeqPair F (τ.state t),
        PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h bf
    exact h _ ((seamOmegaEquiv t (τ.state t)).symm bf).2.symm
  · intro h σ hσ
    have key := h ((seamOmegaEquiv t (τ.state t)) ⟨σ, hσ.symm⟩)
    rw [(seamOmegaEquiv t (τ.state t)).symm_apply_apply ⟨σ, hσ.symm⟩] at key
    exact key

end StabOmega

end Probe718

/-! ## Axiom record -/

#print axioms Probe718.seamFibreEquiv
#print axioms Probe718.plusStab_iff_rays
#print axioms Probe718.seamOmegaEquiv
#print axioms Probe718.plusStab_iff_omega
