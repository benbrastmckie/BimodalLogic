/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.TruthLemma

/-!
# The countermodel's valuation, and the shape of the gap obligation

`Bridge/Omega.lean` fixes the frame (`regionFrame W ι D`, whose states are
`W × (Set ι × Set ι)` — a branch world paired with a region code) and the shift-closed admissible
set. `Bridge/TruthLemma.lean` proves that truth is constant on each region of the placement.
Neither file supplies a `TaskModel`. This file does.

## O1 — the valuation (discharged here)

A `TaskModel (regionFrame W ι D)` is exactly a predicate on `(world, region code) × Atom`.
`regionValuation` splits that predicate along the only distinction the placement makes:

* a **placed** code is one of the form `regionCode f (f i)` — the region of a placed point, which
  `sameRegion_singleton` shows is the singleton `{f i}`. There the branch dictates the value, and
  `regionValuation_placed` reads it back verbatim;
* every other code is a **gap** code — an open interval between consecutive placed points, or one
  of the two open rays. There the branch says nothing and the value is a parameter, `gapVal`.

`branchValuation` instantiates the placed half at `b.hasPosAt (.atom p) ⟨w, timeAt b i⟩`, which is
the assignment the plan names, and `truthAt_atom_branch_placed` is the readback the truth lemma's
atom case consumes:

```
TruthAt (branchModel b f gapVal) (regionOmega f) (regionHistory f w 0) (f i) (.atom p)
  ↔ b.hasPosAt (.atom p) ⟨w, timeAt b i⟩ = true
```

Readback needs `Function.Injective f` and nothing else — `placedCode_injective` turns injectivity
of the placement into injectivity of `i ↦ regionCode f (f i)`, via `placed_ne_of_sameRegion_ne`.
Every monotone placement (`Bridge/Embed.lean`, `Bridge/Carrier.lean`) is injective, so this is a
hypothesis the carrier route already pays for.

`gapVal` is left as an explicit parameter rather than being given a definition, because the choice
is not free — see below — and a wrong concrete choice would be worse than an honest parameter.

## O2 — what the gap valuation still owes

The gap value is unconstrained by any *atomic* branch fact (a gap region contains no label) and
totally constrained by the *universally quantified* ones. `GapDemands` below is that constraint
set written out: at a gap point `r`,

1. every `φ` with `T(G φ) @ (w, t)` and `f t < r` must be true,
2. every `φ` with `T(H φ) @ (w, t)` and `r < f t` must be true,
3. every `φ` with `T(□ φ)` anywhere must be true (`truthAt_box_iff_base`: `□` is the universal
   modality once `Ω` is shift-closed), and
4. the guard of every `T(U(φ,ψ))`/`T(S(φ,ψ))` whose witness straddles `r` must be true.

The obvious shortcut is refuted, and this file records the refutation as a theorem rather than as
prose. `not_leftCopy_gapAdequate` exhibits a placement, a placed valuation and the *left-copy* gap
policy — "a gap takes the value of the placed point below it", i.e. the half-open partition
`[f i, f (i+1))` — under which `G p` is false at `f 0` although `p` is false only at `f 0` itself.
`not_rightCopy_gapAdequate` is its mirror image for `H p`. A branch may perfectly well carry
`T(G p)` and `F(p)` at one label (`p` false now, true ever after), so neither copy policy can be
the truth lemma's valuation. This is the "half-open partition" the Phase 6 banner refutes, stated
against the actual model rather than against region-constancy.

What remains is to exhibit a `gapVal` satisfying `GapDemands` for every gated saturated branch.
That is the mathematical content still owed; it is the one obligation on the Phase 7 critical path
that is not mechanical, and the engine's `denseRules` (the `prior_U_gap`/`prior_S_gap`/`sep`
family) are what must be consumed to discharge it.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## Placed codes -/

section Placed

variable {ι : Type*} {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-- The region code of a placed point. Its region is the singleton `{f i}`. -/
def placedCode (f : ι → D) (i : ι) : Set ι × Set ι := regionCode f (f i)

/-- A code is *placed* when some placed point carries it, and a *gap* code otherwise. -/
def IsPlacedCode (f : ι → D) (c : Set ι × Set ι) : Prop := ∃ i, placedCode f i = c

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
theorem isPlacedCode_placedCode (f : ι → D) (i : ι) : IsPlacedCode f (placedCode f i) :=
  ⟨i, rfl⟩

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
Distinct placed points have distinct codes.

Two points with the same code are region-mates (`sameRegion_iff_regionCode_eq`), and
`placed_ne_of_sameRegion_ne` says distinct region-mates lie in a region containing no placed
point — impossible when both *are* placed.
-/
theorem placedCode_injective {f : ι → D} (hf : Function.Injective f) :
    Function.Injective (placedCode f) := by
  intro i j hij
  have hsame : SameRegion f (f i) (f j) := sameRegion_iff_regionCode_eq.mpr hij
  by_cases heq : f i = f j
  · exact hf heq
  · exact absurd rfl (placed_ne_of_sameRegion_ne hsame heq |>.1 i)

end Placed

/-! ## O1: the valuation -/

section Valuation

variable {ι : Type*} {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

open Classical in
/--
**The countermodel's valuation on region codes.** Placed codes read their value off `placedVal`;
every other code reads it off `gapVal`.

Total on codes by construction — the model is defined at *every* point of the carrier, not merely
at the placed branch times (`regionExtend`'s "never an island" principle, applied to truth values
rather than to states).
-/
noncomputable def regionValuation (f : ι → D) (placedVal : ι → Atom → Prop)
    (gapVal : Set ι × Set ι → Atom → Prop) (c : Set ι × Set ι) (p : Atom) : Prop :=
  if h : IsPlacedCode f c then placedVal h.choose p else gapVal c p

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- **Readback at a placed code.** The only property of `regionValuation` the truth lemma uses. -/
theorem regionValuation_placed {f : ι → D} (hf : Function.Injective f)
    (placedVal : ι → Atom → Prop) (gapVal : Set ι × Set ι → Atom → Prop) (i : ι) (p : Atom) :
    regionValuation f placedVal gapVal (placedCode f i) p ↔ placedVal i p := by
  have hex : IsPlacedCode f (placedCode f i) := isPlacedCode_placedCode f i
  have hchoose : hex.choose = i := placedCode_injective hf hex.choose_spec
  rw [regionValuation, dif_pos hex, hchoose]

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- At a gap code the valuation is exactly the parameter. -/
theorem regionValuation_gap {f : ι → D} {c : Set ι × Set ι} (hc : ¬ IsPlacedCode f c)
    (placedVal : ι → Atom → Prop) (gapVal : Set ι × Set ι → Atom → Prop) (p : Atom) :
    regionValuation f placedVal gapVal c p ↔ gapVal c p := by
  rw [regionValuation, dif_neg hc]

end Valuation

/-! ## The model, and the atom clause -/

section Model

variable {W ι : Type} {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The countermodel.** A world of `regionFrame W ι D` is a pair `(w, c)`; its valuation is the
world's own placed assignment at placed codes and its own gap assignment elsewhere.

Both parameters are indexed by the world: the branch assigns atoms per label, and a label carries
a world as well as a time.
-/
noncomputable def regionModel (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) : TaskModel (regionFrame W ι D) where
  valuation := fun s p => regionValuation f (placedVal s.1) (gapVal s.1) s.2 p

@[simp]
theorem regionModel_valuation (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) (s : W × (Set ι × Set ι)) (p : Atom) :
    (regionModel f placedVal gapVal).valuation s p =
      regionValuation f (placedVal s.1) (gapVal s.1) s.2 p := rfl

/--
**The atom clause of the truth lemma, at an arbitrary carrier point.** Every region history has
total domain, so the existential in `TruthAt`'s atom case is discharged outright and truth of an
atom is exactly the valuation at the point's region code.
-/
theorem truthAt_atom_regionHistory (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) (w : W) (r : D) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) r
        (Formula.atom p) ↔
      regionValuation f (placedVal w) (gapVal w) (regionCode f r) p := by
  simp only [TruthAt, regionHistory_states, regionModel_valuation, add_zero]
  exact ⟨fun ⟨_, hv⟩ => hv, fun hv => ⟨trivial, hv⟩⟩

/-- **The atom clause at a placed point** — the form the truth lemma's induction consumes. -/
theorem truthAt_atom_placed {f : ι → D} (hf : Function.Injective f)
    (placedVal : W → ι → Atom → Prop) (gapVal : W → Set ι × Set ι → Atom → Prop)
    (w : W) (i : ι) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) (f i)
        (Formula.atom p) ↔
      placedVal w i p := by
  rw [truthAt_atom_regionHistory]
  exact regionValuation_placed hf _ _ i p

/-- **The atom clause at a gap point.** -/
theorem truthAt_atom_gap {f : ι → D} {r : D} (hr : ¬ IsPlacedCode f (regionCode f r))
    (placedVal : W → ι → Atom → Prop) (gapVal : W → Set ι × Set ι → Atom → Prop)
    (w : W) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) r
        (Formula.atom p) ↔
      gapVal w (regionCode f r) p := by
  rw [truthAt_atom_regionHistory]
  exact regionValuation_gap hr _ _ p

end Model

/-! ## The branch's own valuation -/

section BranchModel

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The placed half, dictated by the branch**: at the region of the placed point `f i`, the atom `p`
holds in world `w` exactly when the branch carries `T(p)` at the label `(w, timeAt b i)`.
-/
def branchPlacedVal (b : Branch) (w : WorldIndex) (i : BranchTime b) (p : Atom) : Prop :=
  b.hasPosAt (Formula.atom p) ⟨w, timeAt b i⟩ = true

/-- **The countermodel of a branch**, with the gap policy still a parameter. -/
noncomputable def branchModel (b : Branch) (f : BranchTime b → D)
    (gapVal : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop) :
    TaskModel (regionFrame WorldIndex (BranchTime b) D) :=
  regionModel f (branchPlacedVal b) gapVal

/--
**O1, discharged.** At a placed point the extracted model's atoms are exactly the branch's, at the
label that point names.
-/
theorem truthAt_atom_branch_placed (b : Branch) {f : BranchTime b → D}
    (hf : Function.Injective f)
    (gapVal : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop)
    (w : WorldIndex) (i : BranchTime b) (p : Atom) :
    TruthAt (branchModel b f gapVal) (regionOmega f) (regionHistory f w (0 : D)) (f i)
        (Formula.atom p) ↔
      b.hasPosAt (Formula.atom p) ⟨w, timeAt b i⟩ = true :=
  truthAt_atom_placed hf (branchPlacedVal b) gapVal w i p

end BranchModel

/-! ## O2: the gap obligation, and the refutation of the copy policies -/

section GapDemands

variable {W ι : Type} {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**What a gap policy must deliver.** Stated semantically — against the assembled model rather than
against the branch — so that it is the exact hypothesis `not_valid_of_hasOpen` will discharge:
every formula the branch asserts universally at a placed point must survive at every gap point the
universal reaches.

`allFuture`/`allPast` are the two directions of the temporal universals; `box` is handled by
`truthAt_box_iff_base` and so is stated over all worlds and all points at once. The `untl`/`snce`
guards are consequences of these together with region invariance, and are not repeated here.
-/
structure GapDemands (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) : Prop where
  /-- `T(G φ)` at a placed point survives at every later point, gaps included. -/
  future : ∀ (w : W) (i : ι) (φ : Formula),
    TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) (f i)
      φ.allFuture →
    ∀ r : D, f i < r →
      TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) r φ
  /-- `T(H φ)` at a placed point survives at every earlier point, gaps included. -/
  past : ∀ (w : W) (i : ι) (φ : Formula),
    TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) (f i)
      φ.allPast →
    ∀ r : D, r < f i →
      TruthAt (regionModel f placedVal gapVal) (regionOmega f) (regionHistory f w (0 : D)) r φ

end GapDemands

/-! ### The copy policies are unsound

Two theorems, not two paragraphs. The setting is the smallest one that separates the policies:
one placed point at `0 : ℚ`, one world, and the atom `p` false at that point and nowhere else
constrained. A branch may carry `T(G p)` together with `F(p)` at a single label — `p` false now,
true ever after — so an adequate gap policy has to make `p` true immediately above `0`. The
left-copy policy makes it false there, and the right-copy policy makes it false immediately below.
-/

section CopyRefuted

variable {W ι : Type*} {D : Type*} [LinearOrder D]

open Classical in
/-- The **left-copy** gap policy: a gap takes the value of the greatest placed point below it, and
the bottom ray takes a default. This is the half-open partition `[f i, f (i+1))`. -/
noncomputable def leftCopyGap (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (dflt : Prop) (w : W) (c : Set ι × Set ι) (p : Atom) : Prop :=
  if h : ∃ i, i ∈ c.1 ∧ ∀ j ∈ c.1, f j ≤ f i then placedVal w h.choose p else dflt

open Classical in
/-- The **right-copy** gap policy: a gap takes the value of the least placed point above it. -/
noncomputable def rightCopyGap (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (dflt : Prop) (w : W) (c : Set ι × Set ι) (p : Atom) : Prop :=
  if h : ∃ i, i ∈ c.2 ∧ ∀ j ∈ c.2, f i ≤ f j then placedVal w h.choose p else dflt

/-- The one-point placement used by both refutations. -/
abbrev refutePlacement : Fin 1 → ℚ := fun _ => (0 : ℚ)

/-- `p` false at the single placed point, in the single world. -/
abbrev refutePlacedVal : Unit → Fin 1 → Atom → Prop := fun _ _ _ => False

/--
**The left-copy policy is not gap-adequate.** With `p` false at the only placed point, left-copy
makes `p` false on the whole ray above it, so `G p` fails at `0` — although a branch carrying
`T(G p)` and `F(p)` at one label is perfectly consistent.
-/
theorem not_leftCopy_gapAdequate (p : Atom) :
    ¬ TruthAt (regionModel refutePlacement refutePlacedVal
        (leftCopyGap refutePlacement refutePlacedVal False))
      (regionOmega refutePlacement)
      (regionHistory refutePlacement () (0 : ℚ)) (0 : ℚ) (Formula.allFuture (Formula.atom p)) := by
  intro h
  have h1 : TruthAt (regionModel refutePlacement refutePlacedVal
      (leftCopyGap refutePlacement refutePlacedVal False))
      (regionOmega refutePlacement) (regionHistory refutePlacement () (0 : ℚ)) (1 : ℚ)
      (Formula.atom p) := by
    by_contra hc
    exact h ⟨1, by norm_num, hc, fun _ _ _ => id⟩
  rw [truthAt_atom_regionHistory] at h1
  have hgap : ¬ IsPlacedCode refutePlacement (regionCode refutePlacement (1 : ℚ)) := by
    rintro ⟨i, hi⟩
    have : (0 : Fin 1) ∈ (regionCode refutePlacement (1 : ℚ)).1 := by
      simp only [regionCode, refutePlacement, Set.mem_setOf_eq]; norm_num
    rw [← hi] at this
    simp only [placedCode, regionCode, refutePlacement, Set.mem_setOf_eq] at this
    exact absurd this (lt_irrefl 0)
  rw [regionValuation_gap hgap] at h1
  have hchoice : ∃ i, i ∈ (regionCode refutePlacement (1 : ℚ)).1 ∧
      ∀ j ∈ (regionCode refutePlacement (1 : ℚ)).1, refutePlacement j ≤ refutePlacement i :=
    ⟨0, by simp only [regionCode, refutePlacement, Set.mem_setOf_eq]; norm_num,
      fun _ _ => le_refl _⟩
  rw [leftCopyGap, dif_pos hchoice] at h1
  exact h1

/--
**The right-copy policy is not gap-adequate either** — the mirror image. With `p` false at the
only placed point, right-copy makes `p` false on the whole ray below it, so `H p` fails at `0`,
although a branch carrying `T(H p)` and `F(p)` at one label is equally consistent.

Together with `not_leftCopy_gapAdequate` this closes both halves of the half-open partition: the
gap valuation cannot be imported from either endpoint and must be defined outright.
-/
theorem not_rightCopy_gapAdequate (p : Atom) :
    ¬ TruthAt (regionModel refutePlacement refutePlacedVal
        (rightCopyGap refutePlacement refutePlacedVal False))
      (regionOmega refutePlacement)
      (regionHistory refutePlacement () (0 : ℚ)) (0 : ℚ) (Formula.allPast (Formula.atom p)) := by
  intro h
  have h1 : TruthAt (regionModel refutePlacement refutePlacedVal
      (rightCopyGap refutePlacement refutePlacedVal False))
      (regionOmega refutePlacement) (regionHistory refutePlacement () (0 : ℚ)) (-1 : ℚ)
      (Formula.atom p) := by
    by_contra hc
    exact h ⟨-1, by norm_num, hc, fun _ _ _ => id⟩
  rw [truthAt_atom_regionHistory] at h1
  have hgap : ¬ IsPlacedCode refutePlacement (regionCode refutePlacement (-1 : ℚ)) := by
    rintro ⟨i, hi⟩
    have : (0 : Fin 1) ∈ (regionCode refutePlacement (-1 : ℚ)).2 := by
      simp only [regionCode, refutePlacement, Set.mem_setOf_eq]; norm_num
    rw [← hi] at this
    simp only [placedCode, regionCode, refutePlacement, Set.mem_setOf_eq] at this
    exact absurd this (lt_irrefl 0)
  rw [regionValuation_gap hgap] at h1
  have hchoice : ∃ i, i ∈ (regionCode refutePlacement (-1 : ℚ)).2 ∧
      ∀ j ∈ (regionCode refutePlacement (-1 : ℚ)).2, refutePlacement i ≤ refutePlacement j :=
    ⟨0, by simp only [regionCode, refutePlacement, Set.mem_setOf_eq]; norm_num,
      fun _ _ => le_refl _⟩
  rw [rightCopyGap, dif_pos hchoice] at h1
  exact h1

end CopyRefuted

/-! ## Sanity checks -/

section Checks

/-- The valuation elaborates at each of the three dense carriers. -/
example (b : Branch) (f : BranchTime b → ℚ)
    (g : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop) :
    Nonempty (TaskModel (regionFrame WorldIndex (BranchTime b) ℚ)) := ⟨branchModel b f g⟩

example (b : Branch) (f : BranchTime b → ℝ)
    (g : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop) :
    Nonempty (TaskModel (regionFrame WorldIndex (BranchTime b) ℝ)) := ⟨branchModel b f g⟩

example (b : Branch) (f : BranchTime b → ℤ)
    (g : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop) :
    Nonempty (TaskModel (regionFrame WorldIndex (BranchTime b) ℤ)) := ⟨branchModel b f g⟩

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
