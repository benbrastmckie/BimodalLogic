/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.TruthLemma

/-!
# The countermodel's valuation, and the shape of the gap obligation

`Bridge/RegionFrame.lean` fixes the frame (`regionFrame W ι D`, whose states are `W × D` — a
branch world paired with a **time**, since the deterministic clock relation forced the region code
out of the state space) and its total histories. `Bridge/TruthLemma.lean` proves that truth is
constant on each region of the placement, given that the *model* reads the time only through its
region code (`RegionValued`). Neither file supplies a `TaskModel`. This file does, and discharges
that condition for it (`regionValued_regionModel`).

## O1 — the valuation (discharged here)

A `TaskModel (regionFrame W ι D)` is a predicate on `(world, time) × Atom`; `regionModel` builds
the one this file needs by factoring the time through `regionCode f`, so it is equivalently a
predicate on `(world, region code) × Atom`. `regionValuation` splits that predicate along the only
distinction the placement makes:

* a **placed** code is one of the form `regionCode f (f i)` — the region of a placed point, which
  `sameRegion_singleton` shows is the singleton `{f i}`. There the branch dictates the value, and
  `regionValuation_placed` reads it back verbatim;
* every other code is a **gap** code — an open interval between consecutive placed points, or one
  of the two open rays. There the branch says nothing and the value is a parameter, `gapVal`.

`branchValuation` instantiates the placed half at `b.hasPosAt (.atom p) ⟨w, timeAt b i⟩`, which is
the assignment the plan names, and `truthAt_atom_branch_placed` is the readback the truth lemma's
atom case consumes:

```
TruthAt (branchModel b f gapVal) Set.univ (regionHistory f w 0) (f i) (.atom p)
  ↔ b.hasPosAt (.atom p) ⟨w, timeAt b i⟩ = true
```

Readback needs `Function.Injective f` and nothing else — `placedCode_injective` turns injectivity
of the placement into injectivity of `i ↦ regionCode f (f i)`, via `placed_ne_of_sameRegion_ne`.
Every monotone placement (`Bridge/Embed.lean`, `Bridge/Carrier.lean`) is injective, so this is a
hypothesis the carrier route already pays for.

## O2 — the gap policy

The gap value is unconstrained by any *atomic* branch fact (a gap region contains no label) and
constrained only by the *universally quantified* ones: at a gap point `r`,

1. every `p` with `T(G p) @ (w, t)` and `f t < r` must be true,
2. every `p` with `T(H p) @ (w, t)` and `r < f t` must be true,
3. every `p` with `T(□ p)` anywhere must be true (`truthAt_box_iff_base`: `□` is the universal
   modality), and
4. the guard of every `T(U(φ,ψ))`/`T(S(φ,ψ))` whose witness straddles `r` must be true.

The obvious shortcut is refuted, and this file records the refutation as a theorem rather than as
prose. `not_leftCopy_gapAdequate` exhibits a placement, a placed valuation and the *left-copy* gap
policy — "a gap takes the value of the placed point below it", i.e. the half-open partition
`[f i, f (i+1))` — under which `G p` is false at `f 0` although `p` is false only at `f 0` itself.
`not_rightCopy_gapAdequate` is its mirror image for `H p`. A branch may perfectly well carry
`T(G p)` and `F(p)` at one label (`p` false now, true ever after), so neither copy policy can be
the truth lemma's valuation. This is the "half-open partition" the Phase 6 banner refutes, stated
against the actual model rather than against region-constancy.

**`GapDemands` states the obligation backwards and is vacuous.** Its hypothesis is *model* truth
of `G φ` at a placed point, which `Truth.future_iff` makes definitionally equivalent to its own
conclusion. `gapDemands_trivial` proves that every policy whatsoever satisfies it — including the
two refuted above. It is retained only so the mistake stays visible; `GapAdequate` replaces it,
taking the *branch* fact as hypothesis and delivering model truth at gap points.

**The policy, defined outright.** `branchGapVal` is conditions 1-3 read as a definition: at a gap
code `c`, the atom `p` holds when some index in `c.1` (the placed points below the gap) carries
`T(G p)`, or some index in `c.2` (those above) carries `T(H p)`, or `T(□ p)` is on the branch at
all. It reads only the region code and the branch — nothing is imported from an endpoint, so it is
neither copy policy. `branchGapVal_gapAdequate` discharges all three `GapAdequate` fields.

**`GapAdequate` is necessary but NOT sufficient, and `gapAdequate_insufficient` proves it.** The
paragraph this replaces claimed the remaining Phase 7.1 work was the induction itself with
`branchGapVal` fixed as the atom clause's gap arm. That is refuted. `GapAdequate` constrains the
policy at *atoms*, on the ground that a compound formula's value at a gap point is fixed by the
induction. `□` breaks the ground: `truthAt_box_iff_base` makes `T(□χ)` a demand at every point of
every base history for a possibly **compound** `χ`, so the branch fact constrains the gap's
*induced* values, which only the atom policy can supply. On the two-formula branch
`refuteBoxBranch` — `T(□p)` and `T(□(p → q))`, with no `T(□q)`, `T(G q)` or `T(H q)` anywhere,
a configuration the engine really produces (`Tests/BimodalTest/BoxSpreadProbe.lean`, row D) —
`branchGapVal` makes `p` true and `q` false at every gap, so `□(p → q)` is false in the model the
branch asserts it in.

Condition 4, the `U`/`S` straddling guards, remains an obligation of the induction and not of the
policy — that part of the previous reading survives. What does not survive is the idea that an
atom-wise gap policy read off the branch can be completed at all: the required gap state must be
closed under the propositional consequences of the forced set
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and a saturated branch is not (the same
argument runs on the lower ray from `T(H(p → q))`, `T(H p)` and `F(q)` at the earliest known time,
which is satisfiable and forces `q` on the ray with nothing on the branch naming it). The residual
is therefore a **realisability condition on the branch** — in the decidable-check family of
`timeOrderTotal` and `boxAnchoredCheck` — not a degree of freedom of `gapVal`. See the
`BoxCompoundRefuted` section below for the statement and for what it rules out.
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
**The countermodel.** A world of `regionFrame W ι D` is a pair `(w, x)` — a branch world together
with a **time** — and its valuation is the world's own placed assignment at placed codes and its
own gap assignment elsewhere, read off the *region code of the time*.

The time enters only through `regionCode f`, never bare: that factorisation is the whole content
of `RegionValued` (`Bridge/TruthLemma.lean`), and it is what the invariance induction consumes now
that the region code has moved out of the frame's state space. A valuation stated against the
former code-carrying states transports here verbatim as `V p (w, x) := V₀ p (w, regionCode f x)`,
which is precisely the definition below.

Both parameters are indexed by the world: the branch assigns atoms per label, and a label carries
a world as well as a time.
-/
noncomputable def regionModel (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) : TaskModel (regionFrame W ι D) where
  valuation := fun s p => regionValuation f (placedVal s.1) (gapVal s.1) (regionCode f s.2) p

@[simp]
theorem regionModel_valuation (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) (s : W × D) (p : Atom) :
    (regionModel f placedVal gapVal).valuation s p =
      regionValuation f (placedVal s.1) (gapVal s.1) (regionCode f s.2) p := rfl

/--
**The region condition, discharged.** `regionModel`'s valuation is a function of `regionCode f`
applied to the time component, and region-mates have equal codes
(`sameRegion_iff_regionCode_eq`), so the model cannot separate them.

This is the hypothesis `interpInvariantAt_regionHistory` asks for, and the reason the region
structure survives the move to a deterministic task relation.
-/
theorem regionValued_regionModel (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) :
    RegionValued f (regionModel f placedVal gapVal) := by
  intro w r r' h p
  simp only [regionModel_valuation, sameRegion_iff_regionCode_eq.mp h]

/--
**The atom clause of the truth lemma, at an arbitrary carrier point.** Every region history has
total domain, so the existential in `TruthAt`'s atom case is discharged outright and truth of an
atom is exactly the valuation at the point's region code.
-/
theorem truthAt_atom_regionHistory (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) (w : W) (r : D) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) r
        (Formula.atom p) ↔
      regionValuation f (placedVal w) (gapVal w) (regionCode f r) p := by
  simp only [TruthAt, regionHistory_states, regionModel_valuation, add_zero]
  exact ⟨fun ⟨_, hv⟩ => hv, fun hv => ⟨trivial, hv⟩⟩

/-- **The atom clause at a placed point** — the form the truth lemma's induction consumes. -/
theorem truthAt_atom_placed {f : ι → D} (hf : Function.Injective f)
    (placedVal : W → ι → Atom → Prop) (gapVal : W → Set ι × Set ι → Atom → Prop)
    (w : W) (i : ι) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) (f i)
        (Formula.atom p) ↔
      placedVal w i p := by
  rw [truthAt_atom_regionHistory]
  exact regionValuation_placed hf _ _ i p

/-- **The atom clause at a gap point.** -/
theorem truthAt_atom_gap {f : ι → D} {r : D} (hr : ¬ IsPlacedCode f (regionCode f r))
    (placedVal : W → ι → Atom → Prop) (gapVal : W → Set ι × Set ι → Atom → Prop)
    (w : W) (p : Atom) :
    TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) r
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
    TruthAt (branchModel b f gapVal) Set.univ (regionHistory f w (0 : D)) (f i)
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
    TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) (f i)
      φ.allFuture →
    ∀ r : D, f i < r →
      TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) r φ
  /-- `T(H φ)` at a placed point survives at every earlier point, gaps included. -/
  past : ∀ (w : W) (i : ι) (φ : Formula),
    TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) (f i)
      φ.allPast →
    ∀ r : D, r < f i →
      TruthAt (regionModel f placedVal gapVal) Set.univ (regionHistory f w (0 : D)) r φ

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
      Set.univ
      (regionHistory refutePlacement () (0 : ℚ)) (0 : ℚ) (Formula.allFuture (Formula.atom p)) := by
  intro h
  have h1 : TruthAt (regionModel refutePlacement refutePlacedVal
      (leftCopyGap refutePlacement refutePlacedVal False))
      Set.univ (regionHistory refutePlacement () (0 : ℚ)) (1 : ℚ)
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
      Set.univ
      (regionHistory refutePlacement () (0 : ℚ)) (0 : ℚ) (Formula.allPast (Formula.atom p)) := by
  intro h
  have h1 : TruthAt (regionModel refutePlacement refutePlacedVal
      (rightCopyGap refutePlacement refutePlacedVal False))
      Set.univ (regionHistory refutePlacement () (0 : ℚ)) (-1 : ℚ)
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

/-! ## `GapDemands` is stated backwards, and this is the proof

`GapDemands` takes *model* truth of `G φ` at a placed point as its hypothesis. But
`Semantics.future_iff` is an `iff`:
`TruthAt M Set.univ τ x φ.allFuture ↔ ∀ s > x, TruthAt M Set.univ τ s φ`.
The hypothesis therefore already *is* the conclusion, and `GapDemands` holds of every policy —
including the two this file refutes. `gapDemands_trivial` below proves exactly that, so the
vacuity is recorded as a theorem rather than discovered again.

What the truth lemma actually owes is the other direction: the *branch* asserts `T(G φ)` at a
label, and the model must make `φ` true at every later carrier point, gaps included.
`not_leftCopy_gapAdequate` is stated against that reading and is unaffected — it refutes the
left-copy policy by showing the model's `G p` is false where the branch may assert it.
`GapAdequate` below is the corrected obligation.
-/

section GapDemandsVacuous

variable {W ι : Type} {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**`GapDemands` constrains nothing.** Both fields are instances of `future_iff`/`past_iff` read
left to right, so every `gapVal` whatsoever satisfies them.
-/
theorem gapDemands_trivial (f : ι → D) (placedVal : W → ι → Atom → Prop)
    (gapVal : W → Set ι × Set ι → Atom → Prop) : GapDemands f placedVal gapVal where
  future := fun _ _ φ h r hr => (Truth.future_iff _ φ).mp h r hr
  past := fun _ _ φ h r hr => (Truth.past_iff _ φ).mp h r hr

end GapDemandsVacuous

/-! ## O2: the gap policy, defined outright

The gap value cannot be imported from an endpoint (`not_leftCopy_gapAdequate`,
`not_rightCopy_gapAdequate`), so it is defined outright, from the branch, as the union the Phase 7
banner names:

* `{p : T(G p)` at a placed point **below** the gap`}` — everything the past forces forward,
* `{p : T(H p)` at a placed point **above** the gap`}` — everything the future forces backward,
* `{p : T(□ p)` anywhere`}` — `□` is the universal modality over the whole model
  (`truthAt_box_iff_base`), so its content is forced at every point of every world.

A gap region carries no label, so no *atomic* branch fact contradicts the assignment: the three
disjuncts are the only constraints there are, and taking their union is the largest — hence the
most permissive — policy consistent with them. Nothing is copied: the policy reads only the
region *code*, which is the pair of sets of placed indices below and above the gap
(`regionCode f r = ({i | f i < r}, {i | r < f i})`), and the branch.

`GapAdequate` states the three survival conditions against the assembled model, with the *branch*
fact as hypothesis — the direction `GapDemands` had backwards — and `branchGapVal_gapAdequate`
discharges all three.
-/

section GapPolicy

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The branch's gap policy.** At a gap code `c`, an atom holds when the branch forces it there:
some placed index below the gap carries `T(G p)`, or some placed index above it carries `T(H p)`,
or `T(□ p)` appears anywhere at all.

`c.1` is exactly the set of placed indices below the gap and `c.2` the set above, so the two
temporal disjuncts are readable off the code with no reference to the carrier.
-/
def branchGapVal (b : Branch) (w : WorldIndex)
    (c : Set (BranchTime b) × Set (BranchTime b)) (p : Atom) : Prop :=
  (∃ i ∈ c.1, b.hasPosAt (Formula.allFuture (Formula.atom p)) ⟨w, timeAt b i⟩ = true) ∨
  (∃ j ∈ c.2, b.hasPosAt (Formula.allPast (Formula.atom p)) ⟨w, timeAt b j⟩ = true) ∨
  (∃ l : Label, (⟨.pos, Formula.box (Formula.atom p), l⟩ : SignedFormula) ∈ b)

/--
**The corrected gap obligation.** Each field takes a *branch* fact and delivers *model* truth at a
gap point — the direction `GapDemands` reverses. Stated for atoms, because that is the only place
a gap policy has any freedom: at every compound formula the value is fixed by the induction.
-/
structure GapAdequate (b : Branch) (f : BranchTime b → D)
    (gapVal : WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop) : Prop where
  /-- `T(G p)` at a placed label makes `p` true at every gap point above it. -/
  future : ∀ (w : WorldIndex) (i : BranchTime b) (p : Atom),
    b.hasPosAt (Formula.allFuture (Formula.atom p)) ⟨w, timeAt b i⟩ = true →
    ∀ r : D, f i < r → ¬ IsPlacedCode f (regionCode f r) →
      TruthAt (branchModel b f gapVal) Set.univ (regionHistory f w (0 : D)) r
        (Formula.atom p)
  /-- `T(H p)` at a placed label makes `p` true at every gap point below it. -/
  past : ∀ (w : WorldIndex) (j : BranchTime b) (p : Atom),
    b.hasPosAt (Formula.allPast (Formula.atom p)) ⟨w, timeAt b j⟩ = true →
    ∀ r : D, r < f j → ¬ IsPlacedCode f (regionCode f r) →
      TruthAt (branchModel b f gapVal) Set.univ (regionHistory f w (0 : D)) r
        (Formula.atom p)
  /-- `T(□ p)` anywhere makes `p` true at every gap point of every world. -/
  box : ∀ (l : Label) (p : Atom),
    (⟨.pos, Formula.box (Formula.atom p), l⟩ : SignedFormula) ∈ b →
    ∀ (w : WorldIndex) (r : D), ¬ IsPlacedCode f (regionCode f r) →
      TruthAt (branchModel b f gapVal) Set.univ (regionHistory f w (0 : D)) r
        (Formula.atom p)

/--
**O2's atomic half, discharged.** The policy defined outright meets all three survival conditions,
by construction and with no appeal to any adjacent placed value.
-/
theorem branchGapVal_gapAdequate (b : Branch) (f : BranchTime b → D) :
    GapAdequate b f (branchGapVal b) where
  future := by
    intro w i p hG r hr hgap
    rw [show (branchModel b f (branchGapVal b)) =
      regionModel f (branchPlacedVal b) (branchGapVal b) from rfl, truthAt_atom_gap hgap]
    exact Or.inl ⟨i, hr, hG⟩
  past := by
    intro w j p hH r hr hgap
    rw [show (branchModel b f (branchGapVal b)) =
      regionModel f (branchPlacedVal b) (branchGapVal b) from rfl, truthAt_atom_gap hgap]
    exact Or.inr (Or.inl ⟨j, hr, hH⟩)
  box := by
    intro l p hbox w r hgap
    rw [show (branchModel b f (branchGapVal b)) =
      regionModel f (branchPlacedVal b) (branchGapVal b) from rfl, truthAt_atom_gap hgap]
    exact Or.inr (Or.inr ⟨l, hbox⟩)

/-- The gap policy is not either copy policy: it reads the whole region code, not one endpoint. -/
example (b : Branch) (f : BranchTime b → D) : GapAdequate b f (branchGapVal b) :=
  branchGapVal_gapAdequate b f

end GapPolicy

/-! ## `GapAdequate` is necessary but NOT sufficient — the compound-`□` refutation

`branchGapVal` meets `GapAdequate` (proved just above) and yet **cannot** be the truth lemma's
atom clause. `GapAdequate` constrains the policy at *atoms* only, on the stated ground that "at
every compound formula the value is fixed by the induction". That ground is false for `□`.

`truthAt_box_iff_base` makes `□` the universal modality over **every point of every base
history**, gaps included, and `regionHistory` has total domain — so a branch fact `T(□χ)` with
`χ` compound is a demand on the gap points' *induced* values, which the atom policy alone must
already satisfy. Take `χ := p → q`. A branch may carry `T(□p)` and `T(□(p → q))` and no `T(□q)`,
no `T(G q)` and no `T(H q)` anywhere — the engine never emits `T(□q)`, since `boxPos` copies a box
formula's *content* and no rule closes the box context under modus ponens. At any gap point
`branchGapVal` then makes `p` true (third disjunct, via `T(□p)`) and `q` false (no disjunct
applies), so `p → q` is **false** there and `□(p → q)` is false at every point of the model, while
the branch asserts it.

`not_truthLemma_branchGapVal` is that refutation, on the two-formula branch `refuteBoxBranch`. It
needs no engine run and no saturation hypothesis: it refutes the *interface*, showing
`GapAdequate` is too weak to be the truth lemma's gap obligation, not merely that this policy is
the wrong one.

**What this rules out, and what it leaves open.** No atom-wise policy read off the branch's
`T(G ·)`/`T(H ·)`/`T(□ ·)` facts can work, because the required gap state must be closed under the
propositional consequences of the forced set and the branch is not: the same argument runs on the
lower ray with `T(H(p → q))`, `T(H p)` and `F(q)` at the earliest known time, which is satisfiable
and forces `q` on the ray with nothing on the branch to name it. What a correct gap clause must
supply is a *state* realising the forced set
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}` — i.e. a realisability condition on the
branch, in the same decidable-check family as `timeOrderTotal` and `boxAnchoredCheck`, rather than
a degree of freedom of `gapVal`. Note the two copy policies are *not* rehabilitated by this: they
remain refuted for atoms (`not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`), and their
union — left-or-right — dies on the rays, where one endpoint is missing and the other's own value
is unconstrained by the `H`-demand that reaches past it.
-/

section BoxCompoundRefuted

/--
The refuting branch: `T(□p)` and `T(□(p → q))` at the single label `⟨0, 0⟩`, and nothing else.

Deliberately a literal, not an engine run: the refutation is of the *interface*, so it must not
depend on saturation, openness, or any rule firing. `Tests/BimodalTest/BoxSpreadProbe.lean` carries
the companion row showing the engine does produce branches of this shape.
-/
def refuteBoxBranch (p q : Atom) : Branch :=
  [⟨.pos, Formula.box (Formula.atom p), ⟨0, 0⟩⟩,
   ⟨.pos, Formula.box ((Formula.atom p).imp (Formula.atom q)), ⟨0, 0⟩⟩]

/-- Both formulas sit at one label, so the branch has exactly one known time. -/
theorem refuteBoxBranch_knownTimes (p q : Atom) : (refuteBoxBranch p q).knownTimes = [0] := rfl

/-- Its single branch time. -/
def refuteBoxTime (p q : Atom) : BranchTime (refuteBoxBranch p q) :=
  ⟨0, by rw [refuteBoxBranch_knownTimes]; norm_num⟩

/-- The one-point placement of that time, at the origin of `ℚ`. -/
def refuteBoxPlacement (p q : Atom) : BranchTime (refuteBoxBranch p q) → ℚ := fun _ => 0

/-- `1` is a gap point of the one-point placement. -/
theorem refuteBox_gap (p q : Atom) :
    ¬ IsPlacedCode (refuteBoxPlacement p q)
      (regionCode (refuteBoxPlacement p q) (1 : ℚ)) := by
  rintro ⟨i, hi⟩
  have hmem : refuteBoxTime p q ∈ (regionCode (refuteBoxPlacement p q) (1 : ℚ)).1 := by
    simp only [regionCode, refuteBoxPlacement, Set.mem_setOf_eq]; norm_num
  rw [← hi] at hmem
  simp only [placedCode, regionCode, refuteBoxPlacement, Set.mem_setOf_eq] at hmem
  exact absurd hmem (lt_irrefl 0)

/--
**`GapAdequate` is not the truth lemma's gap obligation.** On `refuteBoxBranch` the branch asserts
`T(□(p → q))`, yet the model built with `branchGapVal` — a policy this file proves `GapAdequate` —
makes `□(p → q)` false. So the truth lemma's `box` case cannot be closed from `GapAdequate`, and
the residual is a condition on the branch, not on the policy. See the section preamble.
-/
theorem not_truthLemma_branchGapVal (p q : Atom) (hpq : p ≠ q) :
    (⟨.pos, Formula.box ((Formula.atom p).imp (Formula.atom q)), ⟨0, 0⟩⟩ : SignedFormula)
        ∈ refuteBoxBranch p q ∧
    ¬ TruthAt (branchModel (refuteBoxBranch p q) (refuteBoxPlacement p q)
          (branchGapVal (refuteBoxBranch p q)))
        Set.univ
        (regionHistory (refuteBoxPlacement p q) 0 (0 : ℚ)) (0 : ℚ)
        (Formula.box ((Formula.atom p).imp (Formula.atom q))) := by
  refine ⟨by simp [refuteBoxBranch], ?_⟩
  intro h
  have hgap := refuteBox_gap p q
  have hmodel : branchModel (refuteBoxBranch p q) (refuteBoxPlacement p q)
      (branchGapVal (refuteBoxBranch p q)) =
      regionModel (refuteBoxPlacement p q) (branchPlacedVal (refuteBoxBranch p q))
        (branchGapVal (refuteBoxBranch p q)) := rfl
  -- `□` is the universal modality: the inner formula must hold at *every* point, gaps included.
  -- `f` is no longer pinned by the carrier argument (which is now `Set.univ`), so the placement
  -- is supplied explicitly.
  have himp := (truthAt_box_iff_base _ (refuteBoxPlacement p q) _ _ _).mp h 0 (1 : ℚ)
  -- `p` is true at the gap, forced by `T(□p)`.
  have hp : TruthAt (branchModel (refuteBoxBranch p q) (refuteBoxPlacement p q)
      (branchGapVal (refuteBoxBranch p q))) Set.univ
      (regionHistory (refuteBoxPlacement p q) 0 (0 : ℚ)) (1 : ℚ) (Formula.atom p) := by
    rw [hmodel, truthAt_atom_gap hgap]
    exact Or.inr (Or.inr ⟨⟨0, 0⟩, by simp [refuteBoxBranch]⟩)
  -- so `q` must be true at the gap — and no disjunct of the policy supplies it.
  have hq := himp hp
  rw [hmodel, truthAt_atom_gap hgap] at hq
  rcases hq with ⟨i, _, hG⟩ | ⟨j, hj, _⟩ | ⟨l, hl⟩
  · simp only [Branch.hasPosAt, Branch.contains, refuteBoxBranch, SignedFormula.pos,
      List.any_cons, List.any_nil, Bool.or_false, Bool.or_eq_true, beq_iff_eq,
      SignedFormula.mk.injEq, Formula.allFuture, Formula.someFuture, Formula.neg,
      Formula.top] at hG
    exact hG.elim (fun hx => Formula.noConfusion hx.2.1) (fun hx => Formula.noConfusion hx.2.1)
  · simp only [regionCode, refuteBoxPlacement, Set.mem_setOf_eq] at hj
    exact absurd hj (by norm_num)
  · rcases List.mem_cons.mp hl with heq | hl2
    · injection heq with _ hf _
      injection hf with hf'
      injection hf' with hqp
      exact hpq hqp.symm
    · rcases List.mem_cons.mp hl2 with heq | hnil
      · injection heq with _ hf _
        injection hf with hf'
        exact Formula.noConfusion hf'
      · exact absurd hnil (by simp)

/--
**The insufficiency, as one statement.** The policy is `GapAdequate`, the branch asserts
`T(□(p → q))`, and the model makes `□(p → q)` false — all three at once, so no reading of
`GapAdequate` closes the truth lemma's `box` case.

This is the fact to cite; the two conjuncts above are its parts.
-/
theorem gapAdequate_insufficient (p q : Atom) (hpq : p ≠ q) :
    GapAdequate (refuteBoxBranch p q) (refuteBoxPlacement p q)
        (branchGapVal (refuteBoxBranch p q)) ∧
    (⟨.pos, Formula.box ((Formula.atom p).imp (Formula.atom q)), ⟨0, 0⟩⟩ : SignedFormula)
        ∈ refuteBoxBranch p q ∧
    ¬ TruthAt (branchModel (refuteBoxBranch p q) (refuteBoxPlacement p q)
          (branchGapVal (refuteBoxBranch p q)))
        Set.univ
        (regionHistory (refuteBoxPlacement p q) 0 (0 : ℚ)) (0 : ℚ)
        (Formula.box ((Formula.atom p).imp (Formula.atom q))) :=
  ⟨branchGapVal_gapAdequate _ _, (not_truthLemma_branchGapVal p q hpq).1,
    (not_truthLemma_branchGapVal p q hpq).2⟩

end BoxCompoundRefuted

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
