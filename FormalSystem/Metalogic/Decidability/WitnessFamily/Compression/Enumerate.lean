/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Family

/-!
# The Computable Candidate List

`cands φ` lists every witness family the compression theorem can produce: every canonical box
guess `fun χ => decide (χ ∈ S)` with `S` a subset of the target closure, crossed with every
non-empty list of at most `|C| + 1` labelled lassos whose three segments are bounded by
`compressionBound [] [φ]`.

## The grid is swept whole, and that is the point

The enumeration ranges over **every** triple of segment lengths in `[0, B]³`, not over the single
triple `(B, B, B)`. That is not tidiness: the consuming model checker folds `back`/`mid`/`fwd`
bounds by exact modulus, so a search at bound `n` represents exactly the periods dividing `n`,
and a search restricted to one triple would be silently incomplete. Representability, not
magnitude, is what the folding decides. `mem_boundedLassos` is where this is discharged — it
ranges over every length, never over a fixed one.

## Computability, and why `Finset.powerset` cannot be used

`Finset.powerset` is fine mathematically but `Finset.toList` is noncomputable, which would make
the whole enumeration noncomputable and defeat the purpose — exactly as `BiLasso/Enumerate.lean`'s
`closureSubsets` docstring records. Sublists of the closure's underlying list
(`Formula.subformulas φ`) give the same collection of `Finset`s and compute.

For the same reason `closureSubsetsOf` is indexed by the formula rather than by an abstract
`C : Finset Formula`: an abstract `Finset` has no computable underlying list, and the only
closure this module ever enumerates is `closureOf ([] ++ [φ]) = subformulaClosure φ`.

## `ListEnumC` is transcribed, not imported

`BiLasso/Enumerate.lean`'s `ListEnum.ofLen` / `ListEnum.upTo` are fully generic in `α` and would
serve verbatim, but importing that module would pull `BiLasso/Decide.lean` and the whole
presentation layer into this subdirectory. They are transcribed here under the namespace
`ListEnumC` — a different namespace, so that both copies can coexist in one build — with the same
named retirement trigger the rest of this subdirectory carries.

## Honest accounting of the size

The list is astronomically large: `~(2^k)^{3B(1 + k)}` with `k = |C|` and `B = compressionBound`.
This is a **decidability** construction, not an algorithm; see `Assembly.lean`'s docstring for the
complexity statement and the literature's own lower bound.

## Main Definitions

- `ListEnumC.ofLen` / `ListEnumC.upTo` — all lists of a given (or bounded) length over a universe
- `closureSubsetsOf` — every subset of the target closure, computably
- `boundedLassos` — every labelled lasso with segments bounded by `n`
- `cands` — **the candidate list**

## Main Results

- `mem_closureSubsetsOf` / `closureSubsetsOf_sub` — completeness and soundness for subsets
- `mem_boundedLassos` — completeness for lassos, over the whole length grid
- `mem_cands_of_bounded` — **completeness for families**
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## Enumerating lists over a finite universe -/

namespace ListEnumC

variable {α : Type*}

/-- Every list of exactly length `k` with entries drawn from `u`. -/
def ofLen (u : List α) : ℕ → List (List α)
  | 0 => [[]]
  | k + 1 => (ofLen u k).flatMap (fun l => u.map (fun a => a :: l))

/-- Every list of length at most `n` with entries drawn from `u`. -/
def upTo (u : List α) (n : ℕ) : List (List α) :=
  (List.range (n + 1)).flatMap (ofLen u)

theorem length_of_mem_ofLen {u : List α} : ∀ {k : ℕ}
    {l : List α}, l ∈ ofLen u k → l.length = k := by
  intro k
  induction k with
  | zero => intro l hl; simp only [ofLen, List.mem_singleton] at hl; simp [hl]
  | succ k ih =>
    intro l hl
    simp only [ofLen, List.mem_flatMap, List.mem_map] at hl
    obtain ⟨l', hl', a, _, rfl⟩ := hl
    simp [ih hl']

theorem mem_ofLen {u : List α} : ∀ (l : List α), (∀ a ∈ l, a ∈ u) → l ∈ ofLen u l.length := by
  intro l
  induction l with
  | nil => intro _; simp [ofLen]
  | cons a l ih =>
    intro hmem
    simp only [List.length_cons, ofLen, List.mem_flatMap, List.mem_map]
    exact ⟨l, ih (fun b hb => hmem b (List.mem_cons_of_mem a hb)),
      a, hmem a (List.mem_cons_self ..), rfl⟩

theorem mem_upTo {u : List α} {l : List α} {n : ℕ} (hlen : l.length ≤ n)
    (hmem : ∀ a ∈ l, a ∈ u) : l ∈ upTo u n := by
  simp only [upTo, List.mem_flatMap]
  exact ⟨l.length, List.mem_range.mpr (by omega), mem_ofLen l hmem⟩

theorem length_of_mem_upTo {u : List α} {l : List α} {n : ℕ} (h : l ∈ upTo u n) :
    l.length ≤ n := by
  simp only [upTo, List.mem_flatMap] at h
  obtain ⟨k, hk, hl⟩ := h
  rw [length_of_mem_ofLen hl]
  exact Nat.lt_succ_iff.mp (List.mem_range.mp hk)

end ListEnumC

/-! ## Enumerating closure subsets -/

/--
Every subset of the target closure `closureOf ([] ++ [φ])`, computably.

Indexed by the formula rather than by an abstract `Finset` because only a formula carries a
computable underlying list; see this module's header.
-/
def closureSubsetsOf (φ : Formula) : List (Finset Formula) :=
  ((Formula.subformulas φ).sublists).map List.toFinset

theorem closureSubsetsOf_sub {φ : Formula} {X : Finset Formula}
    (h : X ∈ closureSubsetsOf φ) : X ⊆ closureOf ([] ++ [φ]) := by
  obtain ⟨l, hl, rfl⟩ := List.mem_map.mp h
  intro a ha
  rw [closureOf_nil_singleton]
  simp only [subformulaClosure, List.mem_toFinset] at ha ⊢
  exact (List.mem_sublists.mp hl).subset ha

theorem mem_closureSubsetsOf {φ : Formula} {X : Finset Formula}
    (h : X ⊆ closureOf ([] ++ [φ])) : X ∈ closureSubsetsOf φ := by
  rw [closureOf_nil_singleton] at h
  refine List.mem_map.mpr ⟨(Formula.subformulas φ).filter (fun a => decide (a ∈ X)), ?_, ?_⟩
  · exact List.mem_sublists.mpr List.filter_sublist
  · ext a
    simp only [List.mem_toFinset, List.mem_filter, decide_eq_true_eq]
    constructor
    · exact fun hx => hx.2
    · intro hx
      exact ⟨List.mem_toFinset.mp (h hx), hx⟩

/-! ## Enumerating labelled lassos -/

/-- A raw candidate lasso: three label lists, before any condition is imposed. -/
abbrev RawLabelledLasso := List (Finset Formula) × List (Finset Formula) × List (Finset Formula)

/--
Every raw triple with all three segments bounded by `n`.

Each component ranges over `upTo … n`, i.e. over **every** length in `[0, n]`, which is what
makes the sweep cover the whole grid `[0, n]³` rather than a single triple.
-/
def rawLabelledLassos (φ : Formula) (n : ℕ) : List RawLabelledLasso :=
  (ListEnumC.upTo (closureSubsetsOf φ) n).flatMap (fun b =>
    (ListEnumC.upTo (closureSubsetsOf φ) n).flatMap (fun m =>
      (ListEnumC.upTo (closureSubsetsOf φ) n).map (fun f => (b, m, f))))

theorem mem_rawLabelledLassos {φ : Formula} {n : ℕ} {t : RawLabelledLasso}
    (hb : t.1.length ≤ n) (hm : t.2.1.length ≤ n) (hf : t.2.2.length ≤ n)
    (hsub : ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ closureOf ([] ++ [φ])) :
    t ∈ rawLabelledLassos φ n := by
  obtain ⟨b, m, f⟩ := t
  have huniv : ∀ (l : List (Finset Formula)),
      (∀ X ∈ l, X ⊆ closureOf ([] ++ [φ])) → ∀ X ∈ l, X ∈ closureSubsetsOf φ := by
    intro l hl X hX
    exact mem_closureSubsetsOf (hl X hX)
  simp only [rawLabelledLassos, List.mem_flatMap, List.mem_map]
  exact ⟨b, ListEnumC.mem_upTo hb (huniv b (fun X hX => hsub X (by simp [hX]))),
    m, ListEnumC.mem_upTo hm (huniv m (fun X hX => hsub X (by simp [hX]))),
    f, ListEnumC.mem_upTo hf (huniv f (fun X hX => hsub X (by simp [hX]))), rfl⟩

theorem length_of_mem_rawLabelledLassos {φ : Formula} {n : ℕ} {t : RawLabelledLasso}
    (h : t ∈ rawLabelledLassos φ n) :
    t.1.length ≤ n ∧ t.2.1.length ≤ n ∧ t.2.2.length ≤ n := by
  obtain ⟨b, m, f⟩ := t
  simp only [rawLabelledLassos, List.mem_flatMap, List.mem_map] at h
  obtain ⟨b', hb', m', hm', f', hf', heq⟩ := h
  cases heq
  exact ⟨ListEnumC.length_of_mem_upTo hb', ListEnumC.length_of_mem_upTo hm',
    ListEnumC.length_of_mem_upTo hf'⟩

/-- The `LabelledLasso` structure's own three conditions, as a decidable predicate. -/
def IsLabelledLasso (φ : Formula) (t : RawLabelledLasso) : Prop :=
  t.1 ≠ [] ∧ t.2.2 ≠ [] ∧ ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ closureOf ([] ++ [φ])

instance instDecidableIsLabelledLasso (φ : Formula) :
    DecidablePred (IsLabelledLasso φ) := by
  intro t
  dsimp only [IsLabelledLasso]
  infer_instance

/-- **Every labelled lasso with segments bounded by `n`.** -/
def boundedLassos (φ : Formula) (n : ℕ) : List (LabelledLasso (closureOf ([] ++ [φ]))) :=
  (rawLabelledLassos φ n).filterMap (fun t =>
    if h : IsLabelledLasso φ t then some ⟨t.1, t.2.1, t.2.2, h.1, h.2.1, h.2.2⟩ else none)

/--
**Completeness.** Every labelled lasso whose segments are bounded by `n` is enumerated.

The proof ranges over the lasso's *own* three lengths, each merely bounded by `n`, so the sweep
really is the whole grid.
-/
theorem mem_boundedLassos {φ : Formula} {n : ℕ} (Λ : LabelledLasso (closureOf ([] ++ [φ])))
    (hb : Λ.back.length ≤ n) (hm : Λ.mid.length ≤ n) (hf : Λ.fwd.length ≤ n) :
    Λ ∈ boundedLassos φ n := by
  have hraw : (Λ.back, Λ.mid, Λ.fwd) ∈ rawLabelledLassos φ n :=
    mem_rawLabelledLassos hb hm hf Λ.label_sub
  have hcond : IsLabelledLasso φ (Λ.back, Λ.mid, Λ.fwd) :=
    ⟨Λ.back_ne, Λ.fwd_ne, Λ.label_sub⟩
  simp only [boundedLassos, List.mem_filterMap]
  exact ⟨(Λ.back, Λ.mid, Λ.fwd), hraw, by rw [dif_pos hcond]⟩

/-- **Soundness.** Every enumerated lasso has segments bounded by `n`. -/
theorem boundedLassos_sound {φ : Formula} {n : ℕ}
    {Λ : LabelledLasso (closureOf ([] ++ [φ]))} (h : Λ ∈ boundedLassos φ n) :
    Λ.back.length ≤ n ∧ Λ.mid.length ≤ n ∧ Λ.fwd.length ≤ n := by
  simp only [boundedLassos, List.mem_filterMap] at h
  obtain ⟨t, ht, heq⟩ := h
  by_cases hc : IsLabelledLasso φ t
  · rw [dif_pos hc] at heq
    obtain ⟨hb, hm, hf⟩ := length_of_mem_rawLabelledLassos ht
    cases heq
    exact ⟨hb, hm, hf⟩
  · rw [dif_neg hc] at heq
    exact absurd heq (by simp)

/-! ## The candidate list -/

/--
**The computable candidate list**: every canonical-`bx` family whose lassos are drawn from the
full length grid `[0, compressionBound [] [φ]]³`, with at most `|C| + 1` of them.

`bx` is enumerated by its `Finset` `S`, never as a function on the infinite type `Formula`; see
`Family.lean`'s header for why that is the only available route.
-/
def cands (φ : Formula) : List (WitnessFamily [] [φ]) :=
  (closureSubsetsOf φ).flatMap (fun S =>
    (ListEnumC.upTo (boundedLassos φ (compressionBound [] [φ]))
        ((closureOf ([] ++ [φ])).card + 1)).filterMap (fun L =>
      if h : L ≠ [] then some ⟨fun χ => decide (χ ∈ S), L, h⟩ else none))

/--
**Completeness of the candidate list.**

Any family meeting the three side conditions the compression theorem delivers — the segment
bounds, the lasso-count bound, and the canonical-`bx` form — is a member. All three are consumed;
none is decoration.
-/
theorem mem_cands_of_bounded (φ : Formula) (W : WitnessFamily [] [φ])
    (hlen : ∀ Λ ∈ W.lassos,
      Λ.back.length ≤ compressionBound [] [φ] ∧
      Λ.mid.length ≤ compressionBound [] [φ] ∧
      Λ.fwd.length ≤ compressionBound [] [φ])
    (hcount : W.lassos.length ≤ (closureOf ([] ++ [φ])).card + 1)
    (hbx : ∃ S : Finset Formula, S ⊆ closureOf ([] ++ [φ]) ∧ W.bx = fun χ => decide (χ ∈ S)) :
    W ∈ cands φ := by
  obtain ⟨S, hSsub, hSeq⟩ := hbx
  obtain ⟨bxW, lasW, hne⟩ := W
  simp only at hlen hcount hSeq
  subst hSeq
  have hmemL : lasW ∈ ListEnumC.upTo (boundedLassos φ (compressionBound [] [φ]))
      ((closureOf ([] ++ [φ])).card + 1) := by
    refine ListEnumC.mem_upTo hcount (fun Λ hΛ => ?_)
    obtain ⟨hb, hm, hf⟩ := hlen Λ hΛ
    exact mem_boundedLassos Λ hb hm hf
  simp only [cands, List.mem_flatMap, List.mem_filterMap]
  exact ⟨S, mem_closureSubsetsOf hSsub, lasW, hmemL, by rw [dif_pos hne]⟩

end FormalSystem.Metalogic.Decidability
