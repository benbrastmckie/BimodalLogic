/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Present

/-!
# The computable realized-triple set of a presentation (B3b, the read-out half)

`Present.lean` computes the `k`-types of the finite paths of a finite labelled presentation
(`pathTypes`, `pathTypesNow`) and decides liveness in a graph of such paths (`live`). This
module reads the realized family triples off those: `hitOf lab step now k` is a computable
`Finset` of triples `(τneg, τzero, τpos)`, and `mem_hitOf_iff` says it is EXACTLY the set of
family triples (`InFamily`, the `(τneg)^(ω*) · τzero · (τpos)^ω` factorizations of
`KTypeSummary/Family.lean`) of the traces of the presentation's runs anchored at any `t`. This
is the read-out of the per-model device on an abstract presentation: nothing here mentions a
model, a history, or the realized set `Hit` of a seam, and the connection from presentations to
histories of a regular model — B2b, constructing a model whose seam traces are a given
presentation's runs — is not built anywhere in this tree. What `hitOf` does establish is that
the family triples of a presentation's runs are computable; whether those runs are a seam's
traces is a hypothesis (`Presented`), never a theorem of this cluster.

## Disjoint segments, joined by one step

A factorization cuts the time axis into DISJOINT segments `[W z, W (z + 1))`, each a nonempty
`now`-free `step`-path of the presentation, with consecutive segments joined by ONE `step`
(from the last state of one to the first state of the next). A chain in the graph
`G_τ := {(x, y) | τ ∈ pathTypes … x y}` of `Present.lean` is not that shape: its consecutive
paths SHARE their endpoint, and the `k`-type of a path minus its last state is not the type of
the path. On the two-state presentation with `step x y := (x ≠ y)`, where state `false` reads
one letter and state `true` reads none, `fwdLive` is `true` at `false` for the type of `[false]`
(the one-state path is a self-loop of `G_τ`), yet no run factors into disjoint segments of that
type (every run alternates, and the depth-`1` type sees the letterless state). The realized
triples are therefore read through the graph of disjoint segments instead: `fwdSepGraph … τ x y`
holds when one `step` leads from `x` into a `now`-free path of type `τ` ending at `y`, and
`fwdLiveSep`/`bwdLiveSep` are `live` in that graph and its mirror (`fwdLiveSep_iff`,
`bwdLiveSep_iff`). `Present.lean`'s `fwdLive`/`bwdLive` are left as they are; they are not
consumed here.

## The read-out

`hitOf lab step now k` collects, over every pair of states `(q₀, q₁)`, the triples whose middle
type is in `pathTypesNow … q₀ q₁`, whose negative type is backward-live at `q₀`, and whose
positive type is forward-live at `q₁` (`mem_hitOf_iff_live`). It is an image of `Finset.univ`
over `Q × Q`, never a filter over the triple product of `KType sig k` — that product has
`2 ^ (3 · |NormalForm sig k 0|)` elements and would never enumerate — with the candidate types
drawn from the finitely many path types of the presentation (`allPathTypes`). It does not depend
on the anchor `t`: runs are translation-invariant, and `mem_hitOf_iff` holds for every `t`.

## The two directions

* **Splice (`exists_run_of_live`, the `→` direction).** From the `pathTypesNow` path for the
  middle segment, a forward chain of disjoint `τpos`-paths and a backward chain of disjoint
  `τneg`-paths, a `ℤ`-indexed family of nonempty state lists is assembled and concatenated along
  the time axis (`cutAt`, `exists_concat`): the `z`-th list occupies `[cutAt z, cutAt (z + 1))`.
  The concatenation is a run (`isRun_concat`: steps inside a list by its chain, across a cut by
  the joining `step`, and `now` exactly at the one `now` position of the middle list), and its
  trace's segments have the lists' `k`-types (`kTypeOf_segZ_concat`, by
  `kTypeOf_segZ_eq_listSeg`), so the cuts are a `SegmentFactorization` with the given triple.
  This splices RUNS OF THE PRESENTATION, not histories of a model — the construction that the
  model-level realizability half (B2b) cannot perform without an infinite committed-state slice
  is unproblematic on the abstract presentation.
* **Read-out (`live_of_run`, the `←` direction).** From a factorization of a run's trace, the
  states on each segment form a `step`-path (`runSeg`), and the segments' types are the
  factorization's. Two facts are `k`-type-visible at depth `k ≥ 1`, and this is exactly where
  the hypothesis `1 ≤ k` enters: nonemptiness (`∃x ¬(x < x)`, `nonempty_iff_of_kTypeOf_eq`) and
  the presence of a `now` state (`∃x now x`, `exists_interp_iff_of_kTypeOf_eq`), both through
  `doets_lemma_1_1` (`eval_iff_of_kTypeOf_eq`). So every positive and negative segment is
  nonempty because the first one is, and the segment containing `t` is the middle one, because
  a `now` state in a positive (negative) segment would put a second `now` in the next (previous)
  one, contradicting the run's uniqueness of `now`.

## Computability

`hitOf`, `allPathTypes`, `fwdLiveSep`, `bwdLiveSep` are `def`s and evaluate; a two-state
presentation at depth 1 runs. No complexity bound is claimed: `hitOf` recomputes `pathTypes`
at every graph query, and everything is exponential in `|NormalForm sig k 0|`.

## Main definitions and results

* `countP_eq_one_iff` — `countP p l = 1` iff exactly one position of `l` satisfies `p`.
* `eval_iff_of_kTypeOf_eq`, `nonempty_iff_of_kTypeOf_eq`, `exists_interp_iff_of_kTypeOf_eq` —
  `k`-type visibility of depth-`≤ k` sentences, of nonemptiness, and of a realized predicate.
* `cutAt`, `exists_cut`, `cut_unique`, `exists_concat` — the `ℤ`-indexed concatenation of
  nonempty lists, with `isRun_concat` and `kTypeOf_segZ_concat`.
* `runSeg` — the states of a run on `[a, b)` as a `step`-path, with `kTypeOf_runSeg`.
* `fwdSepGraph`, `bwdSepGraph`, `fwdLiveSep`, `bwdLiveSep`, `fwdLiveSep_iff`, `bwdLiveSep_iff`
  — liveness through disjoint segments.
* `allPathTypes`, `hitOf`, `mem_hitOf_iff_live`, `exists_run_of_live`, `live_of_run`,
  `mem_hitOf_iff` — the computable realized-triple set and its characterization.

## References

* [I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, 2000], Def. 11 (runs) and the splice of Lemma 17, performed here on runs of a
  presentation.
* [K. Doets, *Monadic Π¹₁-theories of Π¹₁-properties*, 1989], Lemma 1.1, for the visibility of
  depth-`≤ k` sentences in the `k`-type.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## Exactly one position satisfies a predicate -/

section CountOne

variable {α : Type} (p : α → Bool)

/-- **`countP p l = 1` iff exactly one position of `l` satisfies `p`.** -/
theorem countP_eq_one_iff (l : List α) :
    l.countP p = 1 ↔
      ∃ i : ℕ, ∃ hi : i < l.length, p l[i] = true ∧
        ∀ j : ℕ, ∀ hj : j < l.length, p l[j] = true → j = i := by
  induction l with
  | nil => simp
  | cons a l ih =>
    rw [List.countP_cons]
    by_cases ha : p a = true
    · rw [if_pos ha]
      constructor
      · intro h
        have h0 : l.countP p = 0 := by omega
        rw [List.countP_eq_zero] at h0
        refine ⟨0, by simp, by simpa using ha, ?_⟩
        intro j hj hpj
        cases j with
        | zero => rfl
        | succ j =>
          exfalso
          rw [List.getElem_cons_succ] at hpj
          exact h0 _ (List.getElem_mem _) (by simpa using hpj)
      · rintro ⟨i, hi, -, huniq⟩
        have h0 : l.countP p = 0 := by
          rw [List.countP_eq_zero]
          intro x hx hpx
          obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hx
          have h1 := huniq (j + 1) (by simpa using hj) (by simpa using hpx)
          have h2 := huniq 0 (by simp) (by simpa using ha)
          omega
        omega
    · rw [if_neg ha, add_zero, ih]
      constructor
      · rintro ⟨i, hi, hpi, huniq⟩
        refine ⟨i + 1, by simpa using hi, by simpa using hpi, ?_⟩
        intro j hj hpj
        cases j with
        | zero => exact absurd (by simpa using hpj) ha
        | succ j =>
          have := huniq j (by simpa using hj) (by simpa using hpj)
          omega
      · rintro ⟨i, hi, hpi, huniq⟩
        cases i with
        | zero => exact absurd (by simpa using hpi) ha
        | succ i =>
          refine ⟨i, by simpa using hi, by simpa using hpi, ?_⟩
          intro j hj hpj
          have := huniq (j + 1) (by simpa using hj) (by simpa using hpj)
          omega

end CountOne

/-! ## `k`-type visibility -/

section Visibility

/-- **Two structures with the same `k`-type satisfy the same sentences of depth at most `k`**
(`doets_lemma_1_1`), on structures rather than on `ℤ`-blocks. -/
theorem eval_iff_of_kTypeOf_eq (k : ℕ) (ψ : MonadicFormula sig 0) (hψ : ψ.quantifierDepth ≤ k)
    {M N : OrderedMonadicStructure sig} (h : kTypeOf sig k M = kTypeOf sig k N) :
    eval M Fin.elim0 ψ ↔ eval N Fin.elim0 ψ := by
  refine doets_lemma_1_1 k 0 ψ hψ M N Fin.elim0 Fin.elim0 ?_
  intro nf
  unfold kTypeOf at h
  have h_pt := congr_fun h nf
  simp only [decide_eq_decide] at h_pt
  exact h_pt

/-- Nonemptiness is `k`-type-visible at every depth `k ≥ 1`: the sentence `∃x ¬(x < x)`. -/
theorem nonempty_iff_of_kTypeOf_eq {k : ℕ} (hk : 1 ≤ k) {M N : OrderedMonadicStructure sig}
    (h : kTypeOf sig k M = kTypeOf sig k N) : Nonempty M.carrier ↔ Nonempty N.carrier := by
  have := eval_iff_of_kTypeOf_eq k (.ex (.not (.lt 0 0))) (by change 1 ≤ k; exact hk) h
  simpa only [eval, Fin.cons_zero, lt_self_iff_false, not_false_eq_true,
    exists_true_iff_nonempty] using this

/-- A realized predicate is `k`-type-visible at every depth `k ≥ 1`: the sentence `∃x (p x)`. -/
theorem exists_interp_iff_of_kTypeOf_eq {k : ℕ} (hk : 1 ≤ k) (p : sig.preds)
    {M N : OrderedMonadicStructure sig} (h : kTypeOf sig k M = kTypeOf sig k N) :
    (∃ x, M.interp p x) ↔ ∃ x, N.interp p x := by
  have := eval_iff_of_kTypeOf_eq k (.ex (.atom p 0)) (by change 1 ≤ k; exact hk) h
  simpa only [eval, Fin.cons_zero] using this

end Visibility

/-! ## A `ℤ`-indexed concatenation of nonempty lists -/

section Concat

variable {Q : Type} (L : ℤ → List Q) (b : ℤ)

/-- Two positions of two equal lists at equal indices hold the same element. -/
theorem getElem_eq_of_eq {l l' : List Q} (h : l = l') {i j : ℕ} (hij : i = j)
    {hi : i < l.length} {hj : j < l'.length} : l[i]'hi = l'[j]'hj := by
  subst h; subst hij; rfl

/-- Forward offsets: `fwdOff n` is the total length of `L 0, …, L (n - 1)`. -/
def fwdOff : ℕ → ℕ
  | 0 => 0
  | n + 1 => fwdOff n + (L n).length

/-- Backward offsets: `bwdOff n` is the total length of `L (-1), …, L (-n)`. -/
def bwdOff : ℕ → ℕ
  | 0 => 0
  | n + 1 => bwdOff n + (L (-((n : ℤ) + 1))).length

/-- **The cuts of the concatenation**: the `z`-th list occupies `[cutAt z, cutAt (z + 1))`,
with `cutAt 0 = b`. -/
def cutAt (z : ℤ) : ℤ := if 0 ≤ z then b + fwdOff L z.toNat else b - bwdOff L (-z).toNat

theorem cutAt_zero : cutAt L b 0 = b := by simp [cutAt, fwdOff]

theorem cutAt_succ (z : ℤ) : cutAt L b (z + 1) = cutAt L b z + (L z).length := by
  unfold cutAt
  by_cases hz : 0 ≤ z
  · rw [if_pos hz, if_pos (by omega), show (z + 1).toNat = z.toNat + 1 by omega]
    simp only [fwdOff]
    rw [show ((z.toNat : ℕ) : ℤ) = z by omega]
    push_cast; ring
  · by_cases hz1 : z + 1 = 0
    · rw [if_pos (by omega), if_neg hz, show (-z).toNat = 1 by omega,
        show (z + 1).toNat = 0 by omega]
      simp only [fwdOff, bwdOff]
      rw [show -(((0 : ℕ) : ℤ) + 1) = z by omega]
      push_cast; ring
    · rw [if_neg (by omega), if_neg hz, show (-z).toNat = (-(z + 1)).toNat + 1 by omega]
      simp only [bwdOff]
      rw [show -((((-(z + 1)).toNat : ℕ) : ℤ) + 1) = z by omega]
      push_cast; ring

theorem cutAt_lt_succ (hL : ∀ z, L z ≠ []) (z : ℤ) : cutAt L b z < cutAt L b (z + 1) := by
  rw [cutAt_succ]
  have := List.length_pos_iff.mpr (hL z)
  omega

theorem cutAt_mono (hL : ∀ z, L z ≠ []) : Monotone (cutAt L b) :=
  (strictMono_int_of_lt_succ (cutAt_lt_succ L b hL)).monotone

theorem le_cutAt_add (hL : ∀ z, L z ≠ []) (z : ℤ) (n : ℕ) :
    cutAt L b z + n ≤ cutAt L b (z + n) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Nat.cast_succ, ← add_assoc, ← add_assoc]
    have := cutAt_lt_succ L b hL (z + n)
    omega

/-- A strictly increasing cut sequence that reaches below and above `s` has a segment
containing `s`. -/
theorem exists_cut {W : ℤ → ℤ} (hW : ∀ z, W z < W (z + 1)) {s zL zH : ℤ} (hlo : W zL ≤ s)
    (hhi : s < W zH) : ∃ z, W z ≤ s ∧ s < W (z + 1) := by
  have hmono := (strictMono_int_of_lt_succ hW).monotone
  have hex : ∃ n : ℕ, ¬ W (zL + n + 1) ≤ s := by
    have hzz : zL < zH := by
      by_contra hc
      have := hmono (not_lt.mp hc)
      omega
    refine ⟨(zH - zL - 1).toNat, ?_⟩
    rw [show zL + ((zH - zL - 1).toNat : ℤ) + 1 = zH by omega]
    omega
  classical
  obtain ⟨n, hn, hmin⟩ : ∃ n : ℕ, ¬ W (zL + n + 1) ≤ s ∧ ∀ m < n, W (zL + m + 1) ≤ s :=
    ⟨Nat.find hex, Nat.find_spec hex, fun m hm => by simpa using Nat.find_min hex hm⟩
  refine ⟨zL + n, ?_, by omega⟩
  cases n with
  | zero => simpa using hlo
  | succ m =>
    have := hmin m (Nat.lt_succ_self m)
    rw [Nat.cast_succ, ← add_assoc]
    exact this

/-- The segment containing a time is unique. -/
theorem cut_unique {W : ℤ → ℤ} (hW : ∀ z, W z < W (z + 1)) {s z z' : ℤ} (h1 : W z ≤ s)
    (h2 : s < W (z + 1)) (h1' : W z' ≤ s) (h2' : s < W (z' + 1)) : z = z' := by
  have hmono := (strictMono_int_of_lt_succ hW).monotone
  by_contra hne
  rcases lt_or_gt_of_ne hne with h | h
  · have := hmono (show z + 1 ≤ z' by omega)
    omega
  · have := hmono (show z' + 1 ≤ z by omega)
    omega

theorem cutAt_cover (hL : ∀ z, L z ≠ []) (s : ℤ) :
    ∃ z, cutAt L b z ≤ s ∧ s < cutAt L b (z + 1) := by
  have h1 : cutAt L b (-(((b - s).toNat : ℕ) : ℤ)) ≤ s := by
    have := le_cutAt_add L b hL (-(((b - s).toNat : ℕ) : ℤ)) (b - s).toNat
    rw [show -(((b - s).toNat : ℕ) : ℤ) + (((b - s).toNat : ℕ) : ℤ) = 0 by ring,
      cutAt_zero] at this
    omega
  have h2 : s < cutAt L b (((s - b).toNat + 1 : ℕ) : ℤ) := by
    have := le_cutAt_add L b hL 0 ((s - b).toNat + 1)
    rw [cutAt_zero, zero_add] at this
    push_cast at this ⊢
    omega
  exact exists_cut (cutAt_lt_succ L b hL) h1 h2

/-- Every time decomposes as a cut plus an offset into the list there. -/
theorem exists_pos_of_cut (hL : ∀ z, L z ≠ []) (s : ℤ) :
    ∃ (z : ℤ) (i : ℕ) (_ : i < (L z).length), s = cutAt L b z + i := by
  obtain ⟨z, h1, h2⟩ := cutAt_cover L b hL s
  rw [cutAt_succ] at h2
  exact ⟨z, (s - cutAt L b z).toNat, by omega, by omega⟩

/-- **The concatenation**: a function on `ℤ` reading the `z`-th list on `[cutAt z, cutAt (z + 1))`.
Existence only; the function is read through this specification. -/
theorem exists_concat (hL : ∀ z, L z ≠ []) :
    ∃ ρ : ℤ → Q, ∀ (z : ℤ) (i : ℕ) (hi : i < (L z).length), ρ (cutAt L b z + i) = (L z)[i] := by
  classical
  have hcov := cutAt_cover L b hL
  refine ⟨fun s =>
    (L (Classical.choose (hcov s)))[(s - cutAt L b (Classical.choose (hcov s))).toNat]'?_, ?_⟩
  · have hs := Classical.choose_spec (hcov s)
    rw [cutAt_succ] at hs
    omega
  · intro z i hi
    have hs := Classical.choose_spec (hcov (cutAt L b z + i))
    have hz : Classical.choose (hcov (cutAt L b z + i)) = z :=
      cut_unique (cutAt_lt_succ L b hL) hs.1 hs.2 (by omega) (by rw [cutAt_succ]; omega)
    exact getElem_eq_of_eq (congrArg L hz) (by rw [hz]; omega)

end Concat

/-! ## The concatenation is a run with the lists' segment types -/

section Splice

variable {Q : Type} (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)
variable (L : ℤ → List Q) (b : ℤ) (ρ : ℤ → Q)

theorem pathLabels_getElem (p : List Q) (i : ℕ) (hi : i < (pathLabels lab p).length) :
    (pathLabels lab p)[i] = lab (p[i]'(by simpa [pathLabels] using hi)) :=
  List.getElem_map lab

/-- **The concatenation is a run**: steps inside a list by its chain, across a cut by the
joining step, and `now` exactly at position `i₀` of the middle list. -/
theorem isRun_concat (hL : ∀ z, L z ≠ [])
    (hρ : ∀ (z : ℤ) (i : ℕ) (hi : i < (L z).length), ρ (cutAt L b z + i) = (L z)[i])
    (hlink : ∀ z, ∃ x y, (L z).getLast? = some x ∧ (L (z + 1)).head? = some y ∧ step x y = true)
    (hchain : ∀ z, (L z).IsChain (fun x y => step x y = true))
    (i₀ : ℕ) (hi₀ : i₀ < (L 0).length)
    (hnow : ∀ (z : ℤ) (i : ℕ) (x : Q), (L z)[i]? = some x →
      (lab x now = true ↔ z = 0 ∧ i = i₀)) :
    IsRun lab step now (b + i₀) ρ := by
  constructor
  · intro s
    obtain ⟨z, i, hi, rfl⟩ := exists_pos_of_cut L b hL s
    rw [hρ z i hi]
    by_cases hlt : i + 1 < (L z).length
    · rw [show cutAt L b z + ↑i + 1 = cutAt L b z + ↑(i + 1) by push_cast; ring,
        hρ z (i + 1) hlt]
      exact (List.isChain_iff_getElem.mp (hchain z)) i hlt
    · have hlen : i + 1 = (L z).length := by omega
      rw [show cutAt L b z + ↑i + 1 = cutAt L b (z + 1) + ((0 : ℕ) : ℤ) by
          rw [cutAt_succ]; push_cast; omega,
        hρ (z + 1) 0 (List.length_pos_iff.mpr (hL _))]
      obtain ⟨x, y, hx, hy, hxy⟩ := hlink z
      rw [List.getLast?_eq_some_getLast (hL z), List.getLast_eq_getElem,
        Option.some.injEq] at hx
      rw [List.head?_eq_some_head (hL (z + 1)), List.head_eq_getElem, Option.some.injEq] at hy
      have h1 : (L z)[i] = (L z)[(L z).length - 1]'(by omega) :=
        getElem_eq_of_eq rfl (by omega)
      rw [h1, hx, hy]
      exact hxy
  · intro s
    obtain ⟨z, i, hi, rfl⟩ := exists_pos_of_cut L b hL s
    rw [hρ z i hi, hnow z i _ (List.getElem?_eq_getElem hi)]
    constructor
    · rintro ⟨rfl, rfl⟩
      rw [cutAt_zero]
    · intro h
      have hz : z = 0 :=
        cut_unique (s := cutAt L b z + i) (z' := 0) (cutAt_lt_succ L b hL) (by omega)
          (by rw [cutAt_succ]; omega) (by rw [cutAt_zero]; omega)
          (by rw [cutAt_succ, cutAt_zero]; omega)
      subst hz
      refine ⟨rfl, ?_⟩
      rw [cutAt_zero] at h
      omega

/-- The letters of the concatenation's trace on the `z`-th segment are the labels of the
`z`-th list. -/
theorem labels_concat
    (hρ : ∀ (z : ℤ) (i : ℕ) (hi : i < (L z).length), ρ (cutAt L b z + i) = (L z)[i]) (z : ℤ) :
    labels (runTrace lab ρ) (cutAt L b z) (cutAt L b (z + 1)) = pathLabels lab (L z) := by
  apply List.ext_getElem
  · rw [labels_length, cutAt_succ]
    simp only [pathLabels, List.length_map]
    omega
  · intro i h₁ h₂
    have hi : i < (L z).length := by simpa [pathLabels] using h₂
    funext p
    rw [Bool.eq_iff_iff, labels_getElem, decide_eq_true_iff, pathLabels_getElem]
    change lab (ρ (cutAt L b z + i)) p = true ↔ _
    rw [hρ z i hi]

/-- **The segments of the concatenation's trace have the lists' `k`-types.** -/
theorem kTypeOf_segZ_concat [Finite sig.preds]
    (hρ : ∀ (z : ℤ) (i : ℕ) (hi : i < (L z).length), ρ (cutAt L b z + i) = (L z)[i])
    (k : ℕ) (z : ℤ) :
    kTypeOf sig k (segZ sig (runTrace lab ρ) (cutAt L b z) (cutAt L b (z + 1))) =
      kTypeOf sig k (listSeg (pathLabels lab (L z))) := by
  rw [kTypeOf_segZ_eq_listSeg, labels_concat lab L b ρ hρ z]

end Splice

/-! ## The states of a run on a segment -/

section RunSegments

variable {Q : Type} (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)
variable (ρ : ℤ → Q)

/-- **The states of a run on `[a, b)`**, as a list. -/
def runSeg (a b : ℤ) : List Q := (List.range (b - a).toNat).map fun (i : ℕ) => ρ (a + (i : ℤ))

@[simp] theorem runSeg_length (a b : ℤ) : (runSeg ρ a b).length = (b - a).toNat := by
  simp only [runSeg, List.length_map, List.length_range]

theorem runSeg_getElem (a b : ℤ) (i : ℕ) (hi : i < (runSeg ρ a b).length) :
    (runSeg ρ a b)[i] = ρ (a + i) := by
  simp only [runSeg, List.getElem_map, List.getElem_range]

theorem runSeg_ne_nil {a b : ℤ} (h : a < b) : runSeg ρ a b ≠ [] := by
  rw [← List.length_pos_iff, runSeg_length]
  omega

theorem runSeg_head? {a b : ℤ} (h : a < b) : (runSeg ρ a b).head? = some (ρ a) := by
  rw [List.head?_eq_some_head (runSeg_ne_nil ρ h), List.head_eq_getElem, runSeg_getElem]
  simp

theorem runSeg_getLast? {a b : ℤ} (h : a < b) :
    (runSeg ρ a b).getLast? = some (ρ (b - 1)) := by
  rw [List.getLast?_eq_some_getLast (runSeg_ne_nil ρ h), List.getLast_eq_getElem, runSeg_getElem,
    runSeg_length, show a + (((b - a).toNat - 1 : ℕ) : ℤ) = b - 1 by omega]

theorem runSeg_isChain (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (a b : ℤ) :
    (runSeg ρ a b).IsChain (fun x y => step x y = true) := by
  rw [List.isChain_iff_getElem]
  intro i hi
  rw [runSeg_getElem, runSeg_getElem, show a + ((i + 1 : ℕ) : ℤ) = a + i + 1 by push_cast; ring]
  exact hstep _

theorem pathLabels_runSeg (a b : ℤ) :
    pathLabels lab (runSeg ρ a b) = labels (runTrace lab ρ) a b := by
  apply List.ext_getElem
  · simp [pathLabels]
  · intro i h₁ h₂
    funext p
    rw [Bool.eq_iff_iff, labels_getElem, decide_eq_true_iff, pathLabels_getElem, runSeg_getElem]
    exact Iff.rfl

/-- **The segment's path has the segment's `k`-type.** -/
theorem kTypeOf_runSeg [Finite sig.preds] (k : ℕ) (a b : ℤ) :
    kTypeOf sig k (listSeg (pathLabels lab (runSeg ρ a b))) =
      kTypeOf sig k (segZ sig (runTrace lab ρ) a b) := by
  rw [pathLabels_runSeg, kTypeOf_segZ_eq_listSeg]

theorem runSeg_now_free {t : ℤ} (hnow : ∀ z, lab (ρ z) now = true ↔ z = t) {a b : ℤ}
    (ht : t < a ∨ b ≤ t) : ∀ x ∈ runSeg ρ a b, lab x now = false := by
  intro x hx
  obtain ⟨i, hi, rfl⟩ := List.mem_iff_getElem.mp hx
  rw [runSeg_getElem, ← Bool.not_eq_true, hnow]
  rw [runSeg_length] at hi
  omega

theorem runSeg_countP_one {t : ℤ} (hnow : ∀ z, lab (ρ z) now = true ↔ z = t) {a b : ℤ}
    (ha : a ≤ t) (hb : t < b) : (runSeg ρ a b).countP (fun x => lab x now) = 1 := by
  rw [countP_eq_one_iff]
  refine ⟨(t - a).toNat, by rw [runSeg_length]; omega, ?_, ?_⟩
  · simp only [runSeg_getElem, hnow]
    omega
  · intro j hj hpj
    simp only [runSeg_getElem, hnow] at hpj
    omega

end RunSegments

/-! ## Liveness through disjoint segments -/

section SeparatedLiveness

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]
variable (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds) (k : ℕ)

/-- **The forward graph of disjoint `τ`-segments**: `x` is joined to `y` when one `step` leads
from `x` into a `now`-free path of type `τ` ending at `y`. -/
def fwdSepGraph (τ : KType sig k) (x y : Q) : Bool :=
  decide (∃ x' : Q, step x x' = true ∧ τ ∈ pathTypes lab step now k x' y)

/-- The backward mirror: `y` is joined to `x` when a `now`-free path of type `τ` starting at
`y` is followed by one `step` into `x`. -/
def bwdSepGraph (τ : KType sig k) (x y : Q) : Bool :=
  decide (∃ x' : Q, τ ∈ pathTypes lab step now k y x' ∧ step x' x = true)

/-- **Forward liveness through disjoint segments**: `q` starts an infinite chain of disjoint
`now`-free `τ`-paths, each entered by one `step`. -/
def fwdLiveSep (τ : KType sig k) (q : Q) : Bool := live (fwdSepGraph lab step now k τ) q

/-- **Backward liveness through disjoint segments**: `q` ends an infinite backward chain of
disjoint `now`-free `τ`-paths, each left by one `step`. -/
def bwdLiveSep (τ : KType sig k) (q : Q) : Bool := live (bwdSepGraph lab step now k τ) q

theorem fwdLiveSep_iff (τ : KType sig k) (q : Q) :
    fwdLiveSep lab step now k τ q = true ↔
      ∃ f : ℕ → Q, f 0 = q ∧
        ∀ n, ∃ x', step (f n) x' = true ∧ τ ∈ pathTypes lab step now k x' (f (n + 1)) := by
  unfold fwdLiveSep
  rw [live_iff]
  simp only [HasChain, fwdSepGraph, decide_eq_true_iff]

theorem bwdLiveSep_iff (τ : KType sig k) (q : Q) :
    bwdLiveSep lab step now k τ q = true ↔
      ∃ f : ℕ → Q, f 0 = q ∧
        ∀ n, ∃ x', τ ∈ pathTypes lab step now k (f (n + 1)) x' ∧ step x' (f n) = true := by
  unfold bwdLiveSep
  rw [live_iff]
  simp only [HasChain, bwdSepGraph, decide_eq_true_iff]

/-- All path types of the presentation: the candidates for `τneg` and `τpos`. -/
def allPathTypes : Finset (KType sig k) :=
  (Finset.univ : Finset (Q × Q)).biUnion fun xy => pathTypes lab step now k xy.1 xy.2

theorem mem_allPathTypes_of_fwdLiveSep {τ : KType sig k} {q : Q}
    (h : fwdLiveSep lab step now k τ q = true) : τ ∈ allPathTypes lab step now k := by
  obtain ⟨f, -, hf⟩ := (fwdLiveSep_iff lab step now k τ q).mp h
  obtain ⟨x', -, hx'⟩ := hf 0
  exact Finset.mem_biUnion.mpr ⟨(x', f 1), Finset.mem_univ _, hx'⟩

theorem mem_allPathTypes_of_bwdLiveSep {τ : KType sig k} {q : Q}
    (h : bwdLiveSep lab step now k τ q = true) : τ ∈ allPathTypes lab step now k := by
  obtain ⟨f, -, hf⟩ := (bwdLiveSep_iff lab step now k τ q).mp h
  obtain ⟨x', hx', -⟩ := hf 0
  exact Finset.mem_biUnion.mpr ⟨(f 1, x'), Finset.mem_univ _, hx'⟩

/-- **The computable realized-triple set of a presentation**: over every pair of states
`(q₀, q₁)`, the triples `(τneg, τzero, τpos)` with `τzero` the type of a path from `q₀` to `q₁`
reading `now` once, `τneg` backward-live at `q₀` and `τpos` forward-live at `q₁`. An image over
`Q × Q`, never a filter over the triple product of `KType sig k`. -/
def hitOf : Finset (KType sig k × KType sig k × KType sig k) :=
  (Finset.univ : Finset (Q × Q)).biUnion fun qq =>
    ((allPathTypes lab step now k).filter fun τ => bwdLiveSep lab step now k τ qq.1 = true) ×ˢ
      (pathTypesNow lab step now k qq.1 qq.2 ×ˢ
        (allPathTypes lab step now k).filter fun τ => fwdLiveSep lab step now k τ qq.2 = true)

/-- Membership in `hitOf`, in liveness terms. -/
theorem mem_hitOf_iff_live (x : KType sig k × KType sig k × KType sig k) :
    x ∈ hitOf lab step now k ↔
      ∃ q₀ q₁ : Q, x.2.1 ∈ pathTypesNow lab step now k q₀ q₁ ∧
        bwdLiveSep lab step now k x.1 q₀ = true ∧ fwdLiveSep lab step now k x.2.2 q₁ = true := by
  unfold hitOf
  simp only [Finset.mem_biUnion, Finset.mem_univ, true_and, Finset.mem_product,
    Finset.mem_filter, Prod.exists]
  constructor
  · rintro ⟨q₀, q₁, ⟨-, hb⟩, hz, -, hf⟩
    exact ⟨q₀, q₁, hz, hb, hf⟩
  · rintro ⟨q₀, q₁, hz, hb, hf⟩
    exact ⟨q₀, q₁, ⟨mem_allPathTypes_of_bwdLiveSep lab step now k hb, hb⟩, hz,
      mem_allPathTypes_of_fwdLiveSep lab step now k hf, hf⟩

end SeparatedLiveness

/-! ## The membership characterization -/

section Characterization

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]
variable (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds) (k : ℕ)

/-- **Splice.** From the middle path and the two liveness chains, a run anchored at `t` whose
trace factors into disjoint segments with the given triple. -/
theorem exists_run_of_live (t : ℤ) (τneg τzero τpos : KType sig k) {q₀ q₁ : Q}
    (hz : τzero ∈ pathTypesNow lab step now k q₀ q₁)
    (hb : bwdLiveSep lab step now k τneg q₀ = true)
    (hf : fwdLiveSep lab step now k τpos q₁ = true) :
    ∃ ρ : ℤ → Q, IsRun lab step now t ρ ∧ InFamily sig k τneg τzero τpos (runTrace lab ρ) := by
  classical
  obtain ⟨p₀, hp₀ne, hp₀h, hp₀l, hp₀c, hp₀n, hp₀t⟩ :=
    (mem_pathTypesNow_iff lab step now q₀ q₁ τzero).mp hz
  obtain ⟨f, hf0, hfn⟩ := (fwdLiveSep_iff lab step now k τpos q₁).mp hf
  choose xf hxf using hfn
  have hpf' := fun n => (mem_pathTypes_iff lab step now (xf n) (f (n + 1)) τpos).mp (hxf n).2
  choose pf hpf using hpf'
  obtain ⟨g, hg0, hgn⟩ := (bwdLiveSep_iff lab step now k τneg q₀).mp hb
  choose xb hxb using hgn
  have hpb' := fun n => (mem_pathTypes_iff lab step now (g (n + 1)) (xb n) τneg).mp (hxb n).1
  choose pb hpb using hpb'
  -- the `ℤ`-indexed family: the backward paths below, the middle path at `0`, the forward
  -- paths above
  let L : ℤ → List Q := fun z =>
    if 0 < z then pf (z - 1).toNat else if z = 0 then p₀ else pb (-z - 1).toNat
  have hLpos : ∀ z, 0 < z → L z = pf (z - 1).toNat := fun z hz => by simp [L, hz]
  have hL0 : L 0 = p₀ := by simp [L]
  have hLneg : ∀ z, z < 0 → L z = pb (-z - 1).toNat := fun z hz => by
    simp [L, not_lt.mpr hz.le, hz.ne]
  have hL : ∀ z, L z ≠ [] := by
    intro z
    rcases lt_trichotomy z 0 with h | rfl | h
    · rw [hLneg z h]; exact (hpb _).1
    · rw [hL0]; exact hp₀ne
    · rw [hLpos z h]; exact (hpf _).1
  obtain ⟨i₀, hi₀, hpi₀, huniq⟩ := (countP_eq_one_iff _ p₀).mp hp₀n
  obtain ⟨ρ, hρ⟩ := exists_concat L (t - i₀) hL
  refine ⟨ρ, ?_, ?_⟩
  · have hrun := isRun_concat lab step now L (t - i₀) ρ hL hρ ?_ ?_ i₀ (by rw [hL0]; exact hi₀)
      ?_
    · rwa [show t - (i₀ : ℤ) + i₀ = t by ring] at hrun
    · -- the joining steps
      intro z
      rcases lt_trichotomy z 0 with h | rfl | h
      · by_cases h1 : z = -1
        · subst h1
          refine ⟨xb 0, q₀, ?_, ?_, ?_⟩
          · rw [hLneg (-1) (by norm_num)]
            exact (hpb 0).2.2.1
          · rw [show (-1 : ℤ) + 1 = 0 by norm_num, hL0]
            exact hp₀h
          · rw [← hg0]
            exact (hxb 0).2
        · have hz1 : z + 1 < 0 := by omega
          refine ⟨xb (-z - 1).toNat, g (-z - 1).toNat, ?_, ?_, ?_⟩
          · rw [hLneg z h]
            exact (hpb _).2.2.1
          · rw [hLneg (z + 1) hz1, show (-(z + 1) - 1).toNat = (-z - 1).toNat - 1 by omega]
            have := (hpb ((-z - 1).toNat - 1)).2.1
            rwa [show (-z - 1).toNat - 1 + 1 = (-z - 1).toNat by omega] at this
          · exact (hxb _).2
      · refine ⟨q₁, xf 0, ?_, ?_, ?_⟩
        · rw [hL0]
          exact hp₀l
        · rw [show (0 : ℤ) + 1 = 1 by norm_num, hLpos 1 one_pos]
          exact (hpf 0).2.1
        · rw [← hf0]
          exact (hxf 0).1
      · refine ⟨f ((z - 1).toNat + 1), xf ((z - 1).toNat + 1), ?_, ?_, ?_⟩
        · rw [hLpos z h]
          exact (hpf _).2.2.1
        · rw [hLpos (z + 1) (by omega), show (z + 1 - 1).toNat = (z - 1).toNat + 1 by omega]
          exact (hpf _).2.1
        · exact (hxf _).1
    · -- the chains inside the lists
      intro z
      rcases lt_trichotomy z 0 with h | rfl | h
      · rw [hLneg z h]; exact (hpb _).2.2.2.1
      · rw [hL0]; exact hp₀c
      · rw [hLpos z h]; exact (hpf _).2.2.2.1
    · -- `now` exactly at position `i₀` of the middle list
      intro z i x hx
      rcases lt_trichotomy z 0 with h | rfl | h
      · rw [hLneg z h] at hx
        have hmem : x ∈ pb (-z - 1).toNat := List.mem_of_getElem? hx
        simp only [(hpb _).2.2.2.2.1 x hmem, Bool.false_eq_true, false_iff, not_and]
        intro h0
        omega
      · rw [hL0, List.getElem?_eq_some_iff] at hx
        obtain ⟨hi, rfl⟩ := hx
        simp only [true_and]
        exact ⟨fun h => huniq i hi h, fun h => by subst h; exact hpi₀⟩
      · rw [hLpos z h] at hx
        have hmem : x ∈ pf (z - 1).toNat := List.mem_of_getElem? hx
        simp only [(hpf _).2.2.2.2.1 x hmem, Bool.false_eq_true, false_iff, not_and]
        intro h0
        omega
  · -- the factorization at the cuts
    refine ⟨⟨cutAt L (t - i₀), cutAt_mono L _ hL, cutAt_cover L _ hL, τpos, τneg, ?_, ?_, ?_, ?_,
      τzero, ?_⟩, rfl, rfl, rfl⟩
    · intro z hz
      rw [kTypeOf_segZ_concat lab L _ ρ hρ, hLpos z hz]
      exact (hpf _).2.2.2.2.2
    · intro z hz
      rw [kTypeOf_segZ_concat lab L _ ρ hρ, hLneg z hz]
      exact (hpb _).2.2.2.2.2
    · exact cutAt_lt_succ L _ hL 1
    · have := cutAt_lt_succ L (t - i₀) hL (-2)
      rwa [show (-2 : ℤ) + 1 = -1 by norm_num] at this
    · have := kTypeOf_segZ_concat lab L (t - i₀) ρ hρ k 0
      rw [zero_add] at this
      rw [this, hL0]
      exact hp₀t

/-- **Read-out.** From a factorization of a run's trace at depth `k ≥ 1`, the middle segment's
path and the two liveness chains. -/
theorem live_of_run (hk : 1 ≤ k) {t : ℤ} {ρ : ℤ → Q} (hρ : IsRun lab step now t ρ)
    (F : SegmentFactorization sig k (runTrace lab ρ)) :
    ∃ q₀ q₁ : Q, F.τzero ∈ pathTypesNow lab step now k q₀ q₁ ∧
      bwdLiveSep lab step now k F.τneg q₀ = true ∧
        fwdLiveSep lab step now k F.τpos q₁ = true := by
  obtain ⟨hstep, hnow⟩ := hρ
  have hne : ∀ a b : ℤ, Nonempty (segZ sig (runTrace lab ρ) a b).carrier ↔ a < b := by
    intro a b
    constructor
    · rintro ⟨⟨s, h1, h2⟩⟩
      omega
    · intro h
      exact ⟨⟨a, le_rfl, h⟩⟩
  -- every positive and negative segment is nonempty: nonemptiness is `k`-type-visible
  have hpos_ne : ∀ z, 0 < z → F.W z < F.W (z + 1) := by
    intro z hz
    rw [← hne, nonempty_iff_of_kTypeOf_eq hk
      ((F.pos_type z hz).trans (F.pos_type 1 one_pos).symm), hne]
    exact F.strict_pos
  have hneg_ne : ∀ z, z < 0 → F.W z < F.W (z + 1) := by
    intro z hz
    rw [← hne, nonempty_iff_of_kTypeOf_eq hk
      ((F.neg_type z hz).trans (F.neg_type (-2) (by norm_num)).symm), hne]
    have := F.strict_neg
    rwa [show (-1 : ℤ) = -2 + 1 by norm_num] at this
  -- `now` lies in the middle segment: a `now` state is `k`-type-visible
  have hmid : F.W 0 ≤ t ∧ t < F.W 1 := by
    obtain ⟨z₀, h1, h2⟩ := F.cover t
    have hseg : ∃ x : (segZ sig (runTrace lab ρ) (F.W z₀) (F.W (z₀ + 1))).carrier,
        (segZ sig (runTrace lab ρ) (F.W z₀) (F.W (z₀ + 1))).interp now x :=
      ⟨⟨t, h1, h2⟩, (hnow t).mpr rfl⟩
    rcases lt_trichotomy z₀ 0 with hz | rfl | hz
    · exfalso
      obtain ⟨⟨s, hs1, hs2⟩, hs⟩ := (exists_interp_iff_of_kTypeOf_eq hk now
        ((F.neg_type z₀ hz).trans (F.neg_type (z₀ - 1) (by omega)).symm)).mp hseg
      have hst : s = t := (hnow s).mp hs
      have := F.mono (show z₀ - 1 + 1 ≤ z₀ by omega)
      omega
    · rw [zero_add] at h2
      exact ⟨h1, h2⟩
    · exfalso
      obtain ⟨⟨s, hs1, hs2⟩, hs⟩ := (exists_interp_iff_of_kTypeOf_eq hk now
        ((F.pos_type z₀ hz).trans (F.pos_type (z₀ + 1) (by omega)).symm)).mp hseg
      have hst : s = t := (hnow s).mp hs
      omega
  refine ⟨ρ (F.W 0), ρ (F.W 1 - 1), ?_, ?_, ?_⟩
  · -- the middle segment
    rw [mem_pathTypesNow_iff]
    have h01 : F.W 0 < F.W 1 := by omega
    refine ⟨runSeg ρ (F.W 0) (F.W 1), runSeg_ne_nil ρ h01, runSeg_head? ρ h01,
      runSeg_getLast? ρ h01, runSeg_isChain step ρ hstep _ _,
      runSeg_countP_one lab now ρ hnow hmid.1 hmid.2, ?_⟩
    rw [kTypeOf_runSeg]
    exact F.zero_type
  · -- the backward chain: the first states of the negative segments
    rw [bwdLiveSep_iff]
    refine ⟨fun n => ρ (F.W (-(n : ℤ))), by simp, ?_⟩
    intro n
    have e : -((n + 1 : ℕ) : ℤ) + 1 = -(n : ℤ) := by push_cast; ring
    have hlt : F.W (-((n + 1 : ℕ) : ℤ)) < F.W (-(n : ℤ)) := by
      have := hneg_ne (-((n + 1 : ℕ) : ℤ)) (by push_cast; omega)
      rwa [e] at this
    refine ⟨ρ (F.W (-(n : ℤ)) - 1), ?_, ?_⟩
    · rw [mem_pathTypes_iff]
      refine ⟨runSeg ρ (F.W (-((n + 1 : ℕ) : ℤ))) (F.W (-(n : ℤ))), runSeg_ne_nil ρ hlt,
        runSeg_head? ρ hlt, runSeg_getLast? ρ hlt, runSeg_isChain step ρ hstep _ _,
        runSeg_now_free lab now ρ hnow (Or.inr ?_), ?_⟩
      · have := F.mono (show -(n : ℤ) ≤ 0 by omega)
        omega
      · rw [kTypeOf_runSeg]
        have := F.neg_type (-((n + 1 : ℕ) : ℤ)) (by push_cast; omega)
        rwa [e] at this
    · have := hstep (F.W (-(n : ℤ)) - 1)
      rwa [sub_add_cancel] at this
  · -- the forward chain: the last states of the positive segments
    rw [fwdLiveSep_iff]
    refine ⟨fun n => ρ (F.W ((n : ℤ) + 1) - 1), by simp, ?_⟩
    intro n
    refine ⟨ρ (F.W ((n : ℤ) + 1)), ?_, ?_⟩
    · have := hstep (F.W ((n : ℤ) + 1) - 1)
      rwa [sub_add_cancel] at this
    · rw [mem_pathTypes_iff]
      have hlt : F.W ((n : ℤ) + 1) < F.W ((n : ℤ) + 1 + 1) := hpos_ne _ (by omega)
      refine ⟨runSeg ρ (F.W ((n : ℤ) + 1)) (F.W ((n : ℤ) + 1 + 1)), runSeg_ne_nil ρ hlt,
        runSeg_head? ρ hlt, ?_, runSeg_isChain step ρ hstep _ _,
        runSeg_now_free lab now ρ hnow (Or.inl ?_), ?_⟩
      · rw [runSeg_getLast? ρ hlt]
        simp only [Nat.cast_succ]
      · have := F.mono (show (1 : ℤ) ≤ (n : ℤ) + 1 by omega)
        omega
      · rw [kTypeOf_runSeg]
        exact F.pos_type _ (by omega)

/-- **`hitOf` is exactly the set of family triples of the presentation's runs**, at every anchor
`t` and every depth `k ≥ 1`. -/
theorem mem_hitOf_iff (t : ℤ) (hk : 1 ≤ k) (x : KType sig k × KType sig k × KType sig k) :
    x ∈ hitOf lab step now k ↔
      ∃ ρ : ℤ → Q, IsRun lab step now t ρ ∧
        InFamily sig k x.1 x.2.1 x.2.2 (runTrace lab ρ) := by
  rw [mem_hitOf_iff_live]
  constructor
  · rintro ⟨q₀, q₁, hz, hb, hf⟩
    exact exists_run_of_live lab step now k t x.1 x.2.1 x.2.2 hz hb hf
  · rintro ⟨ρ, hρ, F, hneg, hzero, hpos⟩
    obtain ⟨q₀, q₁, h1, h2, h3⟩ := live_of_run lab step now k hk hρ F
    rw [← hneg, ← hzero, ← hpos]
    exact ⟨q₀, q₁, h1, h2, h3⟩

end Characterization

end FormalSystem.Metalogic.WeakCanonical
