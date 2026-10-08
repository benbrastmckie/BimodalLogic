/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Compose

/-!
# Finite labelled presentations and the path-type closure (B3b, the closure half)

`Compose.lean` states composition on representatives: the `k`-type of a concatenation of
label lists depends only on the `k`-types of the parts (`kTypeOf_listSeg_append_congr`). This
module uses exactly that congruence to COMPUTE the `k`-types of the finite paths of a finite
labelled presentation, and to decide whether a state starts (or ends) an infinite chain of
such paths. Nothing here summarizes a history, decides anything about `⊡`, or touches the
realized triples `Hit`: the computable realized-triple set of a presentation and its
characterization are the next step in this cluster, and the connection from presentations to
histories of a model — B2b, constructing a regular model realizing a given presentation — is
not built anywhere in this tree.

## Finite labelled presentations

A **presentation** is unbundled: a state type `Q` with `[Fintype Q] [DecidableEq Q]`, a
labelling `lab : Q → sig.preds → Bool`, a step relation `step : Q → Q → Bool`, and a
distinguished marker letter `now : sig.preds`. Its **runs** (`IsRun`) are the bi-infinite
`step`-chains reading `now` at exactly one time, and the **trace** of a run (`runTrace`) is the
decidable colouring of `ℤ` reading each predicate off the state's label. This is the shape
Hodkinson–Wolter–Zakharyaschev's state function (Def. 10) takes once the per-time alphabet is a
finite set of letters. Two things are deliberately NOT imposed on a presentation:

* the local run conditions of `Closure.lean` are not a run condition here — a trace of a
  history satisfies them as a CONSEQUENCE (`clTrace_localRun`), so a presentation whose runs
  are exactly the seam's traces inherits them, and keying the closure on a discharge set would
  only duplicate `LocalRun`; this is the recorded decision dropping the research's
  `dischargeSet` key;
* the product/liveness structure a REALIZABLE presentation needs (the seam fibre is a product
  of ray summaries, and the Lemma 17 splice is a closure property of that product) is B2b's
  and is not stated here — `Presented`, the explicit hypothesis that a seam's traces are a
  presentation's runs, is what connects runs to histories, and nothing in this module asserts
  it for any model.

## The path-type closure

`pathTypes lab step now k q q'` is the finite set of `k`-types of the nonempty `now`-free
`step`-paths from `q` to `q'`, and `pathTypesNow` the same for paths reading `now` exactly once
(the middle segment of a run). Both are read off `pathClosure`, a `Finset` of entries
`PathEntry` carrying a source, a target, a `now` flag, a `k`-type, and ONE representative label
list for that key. One round (`closureStep`) extends every entry by every admissible successor
state whose extended key is new, computing the new `k`-type on the extended representative with
`kTypeOfFin`; by the congruence, the result is the `k`-type of EVERY path with that key, which
is what makes keeping a single representative sound (`exists_mem_iterate_of_stepPath`). A
non-stationary round adds a new key, and keys live in `Q × Q × Bool × KType sig k`, so the
iterate is stationary within `closureBound` rounds (`iterate_stabilizes`, a generic
bounded-measure lemma; `closureStep_pathClosure`). The computable iterate `closureIter` stops
at the first stationary round and is proved equal to the `Nat.iterate`
(`closureIter_eq_iterate`), and `closureBound` is computed arithmetically from
`Fintype.card (NormalForm sig k 0)`, never by enumerating `KType sig k`. The membership
characterizations `mem_pathTypes_iff` and `mem_pathTypesNow_iff` are stated on lists
(`head?`, `getLast?`, `List.IsChain`) through the inductive `StepPath` and its
characterization `stepPath_iff`.

## Liveness

`fwdLive lab step now k τ q` decides whether `q` starts an infinite forward chain
`q = q₀ → q₁ → …` in the graph joining `x` to `y` when `τ ∈ pathTypes … x y`, and `bwdLive`
the backward mirror; `fwdLive_iff` / `bwdLive_iff` are the characterizations. The decision is
the greatest fixpoint of the pruning step "keep the states with a successor still in the set"
(`liveSet`, generic in a Boolean graph `G` on a finite type, `live_iff`): the pruning iterate
from `univ` is stationary within `Fintype.card Q` rounds by the same bounded-measure lemma, its
fixpoint is closed under taking successors (so every member starts an infinite chain by
choosing successors), and every state starting an infinite chain survives every round. This is
the "some reachable state lies on a cycle" criterion in fixpoint form — the same
`fwdLive_iff` statement, without unrolling a cycle.

## Computability

`pathClosure`, `pathTypes`, `pathTypesNow`, `fwdLive` and `bwdLive` are `def`s and evaluate
(a two-state presentation at depth 1 runs in seconds). Equality of `k`-types is decided by
`Fintype.decidablePiFintype`; the one instance resolution cannot find on its own — the
closure's filter predicate, a conjunction under a binder — is supplied by name (`Extendable`).
The `Fintype Q` and `DecidableEq Q` instances are the presentation's own; no `ℤ`-subtype
instance is involved.

## No complexity bound

None is claimed, upper or lower. `closureBound` is astronomically larger than the rounds any
closure actually takes, `fwdLive` recomputes `pathTypes` at every edge query, and `decide` on
`KType sig k` equality is exponential in `|NormalForm sig k 0|`; witnesses run at depth 1 on
two-state presentations.

## Main definitions and results

* `IsRun`, `runTrace`, `pathLabels`, `StepPath`, `stepPath_iff` — runs and traces of a
  presentation, and its finite paths.
* `PathEntry`, `Realizes`, `closureStep`, `closureIter`, `closureBound`, `pathClosure` — the
  representative-carrying closure, with `closureIter_eq_iterate`, `closureStep_pathClosure`
  (stationarity), `realizes_of_mem_iterate` (soundness) and `exists_mem_iterate_of_stepPath`
  (completeness).
* `pathTypes`, `pathTypesNow`, `mem_pathTypes_iff`, `mem_pathTypesNow_iff` — the path types
  and their membership characterizations.
* `live`, `live_iff`, `fwdLive`, `bwdLive`, `fwdLive_iff`, `bwdLive_iff` — liveness.
* `iterate_stabilizes` — a bounded iterate with a strictly growing finite measure is stationary.

## References

* [I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, 2000], Def. 10 (state functions) and Def. 11 (runs), for the shape of a
  presentation and its runs.
* [W. Thomas, *Ehrenfeucht-Fraïssé games, the composition method, and the monadic theory of
  ordinal words*, 1997] for the composition method the closure instantiates.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## A bounded iterate stabilizes once a finite measure stops growing -/

section Stabilize

variable {α : Type} (f : α → α)

/-- **Stabilization by a bounded measure.** If every non-stationary application of `f`
strictly increases a measure bounded by `B`, then `B` iterations reach a fixpoint. -/
theorem iterate_stabilizes (μ : α → ℕ) (B : ℕ) (hB : ∀ x, μ x ≤ B)
    (hμ : ∀ x, f x ≠ x → μ x < μ (f x)) (x₀ : α) : f (f^[B] x₀) = f^[B] x₀ := by
  by_contra h
  -- every round up to `B` is non-stationary, else `f^[B] x₀` would already be fixed
  have hns : ∀ m ≤ B, f (f^[m] x₀) ≠ f^[m] x₀ := by
    intro m hm hfix
    apply h
    have hB' : f^[B] x₀ = f^[m] x₀ := by
      rw [show B = (B - m) + m by omega, Function.iterate_add_apply, Function.iterate_fixed hfix]
    rw [hB', hfix]
  have hgrow : ∀ n ≤ B + 1, n ≤ μ (f^[n] x₀) := by
    intro n
    induction n with
    | zero => intro _; exact Nat.zero_le _
    | succ n ih =>
      intro hn
      have h1 := ih (by omega)
      have h2 := hμ _ (hns n (by omega))
      rw [Function.iterate_succ_apply']
      omega
  have h3 := hgrow (B + 1) le_rfl
  have h4 := hB (f^[B + 1] x₀)
  omega

end Stabilize

/-! ## Finite labelled presentations: runs, traces, and finite paths -/

section Runs

variable {Q : Type} (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds)

/-- **A run of a presentation anchored at `t`**: a bi-infinite `step`-chain of states whose
`now` letter is read at time `t` and nowhere else. -/
def IsRun (t : ℤ) (ρ : ℤ → Q) : Prop :=
  (∀ z, step (ρ z) (ρ (z + 1)) = true) ∧ ∀ z, (lab (ρ z) now = true ↔ z = t)

/-- The trace of a run: the colouring of `ℤ` reading each predicate off the state's label. -/
def runTrace (ρ : ℤ → Q) : sig.preds → ℤ → Prop := fun p z => lab (ρ z) p = true

/-- The trace of a run is decidable letter by letter. -/
instance runTraceDecidablePred (ρ : ℤ → Q) : ∀ p, DecidablePred (runTrace lab ρ p) :=
  fun p z => inferInstanceAs (Decidable (lab (ρ z) p = true))

/-- The label list of a finite state path. -/
def pathLabels (p : List Q) : List (sig.preds → Bool) := p.map lab

@[simp] theorem pathLabels_singleton (q : Q) : pathLabels lab [q] = [lab q] := rfl

@[simp] theorem pathLabels_append (p₁ p₂ : List Q) :
    pathLabels lab (p₁ ++ p₂) = pathLabels lab p₁ ++ pathLabels lab p₂ :=
  List.map_append ..

/-- **A finite `step`-path** from `q` to `q'`, as the list of its states: nonempty, built by
appending one `step`-successor at a time. -/
inductive StepPath : Q → Q → List Q → Prop
  | single (q : Q) : StepPath q q [q]
  | snoc {q q' : Q} {p : List Q} (q'' : Q) :
      StepPath q q' p → step q' q'' = true → StepPath q q'' (p ++ [q''])

/-- A `step`-path is a nonempty list with the stated ends whose consecutive states are
`step`-related. -/
theorem stepPath_iff (q q' : Q) (p : List Q) :
    StepPath step q q' p ↔
      p ≠ [] ∧ p.head? = some q ∧ p.getLast? = some q' ∧
        p.IsChain (fun x y => step x y = true) := by
  constructor
  · intro h
    induction h with
    | single => simp
    | snoc q'' _ hs ih =>
      obtain ⟨hne, hh, hl, hc⟩ := ih
      refine ⟨List.append_ne_nil_of_right_ne_nil _ (by simp), ?_, List.getLast?_concat, ?_⟩
      · rw [List.head?_append_of_ne_nil _ hne, hh]
      · rw [List.isChain_append]
        refine ⟨hc, List.isChain_singleton _, ?_⟩
        intro x hx y hy
        rw [hl] at hx
        simp only [Option.mem_def, Option.some.injEq, List.head?_cons] at hx hy
        subst hx; subst hy; exact hs
  · induction p using List.reverseRecOn generalizing q q' with
    | nil => intro h; exact absurd rfl h.1
    | append_singleton p q'' ih =>
      rintro ⟨-, hh, hl, hc⟩
      rw [List.getLast?_concat, Option.some.injEq] at hl
      subst hl
      by_cases hp : p = []
      · subst hp
        simp only [List.nil_append, List.head?_cons, Option.some.injEq] at hh
        subst hh
        exact StepPath.single _
      · rw [List.head?_append_of_ne_nil _ hp] at hh
        rw [List.isChain_append] at hc
        obtain ⟨hc₁, -, hc₂⟩ := hc
        refine StepPath.snoc _
          (ih q (p.getLast hp) ⟨hp, hh, List.getLast?_eq_some_getLast hp, hc₁⟩) ?_
        exact hc₂ _ (by rw [List.getLast?_eq_some_getLast hp]; rfl) _ rfl

end Runs

/-! ## The path-type closure -/

/-- **An entry of the path-type closure**: a path from `src` to `dst`, reading `now` iff
`hasNow`, of `k`-type `ty`, represented by its label list `rep`. -/
structure PathEntry (sig : MonadicSignature) (Q : Type) (k : ℕ) where
  src : Q
  dst : Q
  hasNow : Bool
  ty : KType sig k
  rep : List (sig.preds → Bool)

namespace PathEntry

variable {Q : Type} {k : ℕ}

/-- The key of an entry: everything but the representative. -/
def key (e : PathEntry sig Q k) : Q × Q × Bool × KType sig k := (e.src, e.dst, e.hasNow, e.ty)

theorem key_inj {e e' : PathEntry sig Q k} (h : e.key = e'.key) :
    e.src = e'.src ∧ e.dst = e'.dst ∧ e.hasNow = e'.hasNow ∧ e.ty = e'.ty := by
  simpa [key, Prod.ext_iff] using h

/-- Entries are decidably equal: `k`-types are, by `Fintype.decidablePiFintype`. -/
instance [Fintype sig.preds] [DecidableEq sig.preds] [DecidableEq Q] :
    DecidableEq (PathEntry sig Q k) := fun a b =>
  decidable_of_iff (a.src = b.src ∧ a.dst = b.dst ∧ a.hasNow = b.hasNow ∧ a.ty = b.ty ∧
    a.rep = b.rep) (by cases a; cases b; simp)

end PathEntry

section Realization

variable {Q : Type} (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds) {k : ℕ}

/-- An entry is **realized**: its key is read off some `step`-path carrying its
representative's labels, and its `k`-type is the `k`-type of its representative. -/
def Realizes (e : PathEntry sig Q k) : Prop :=
  (∃ p : List Q, StepPath step e.src e.dst p ∧
      p.countP (fun x => lab x now) = (bif e.hasNow then 1 else 0) ∧ pathLabels lab p = e.rep) ∧
    e.ty = kTypeOf sig k (listSeg e.rep)

end Realization

section PathClosure

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]
variable (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds) {k : ℕ}

omit [Fintype Q] [DecidableEq Q] in
/-- Extend an entry by one more state `q''`: the representative grows by one letter and the
`k`-type is recomputed on it. -/
def extendEntry (e : PathEntry sig Q k) (q'' : Q) : PathEntry sig Q k where
  src := e.src
  dst := q''
  hasNow := e.hasNow || lab q'' now
  ty := kTypeOfFin (listSeg (e.rep ++ [lab q''])) k
  rep := e.rep ++ [lab q'']

omit [Fintype sig.preds] [DecidableEq sig.preds] [Fintype Q] [DecidableEq Q] in
/-- `q''` may extend `e`: it is a `step`-successor of the end state and does not read a
second `now`. -/
def canExtend (e : PathEntry sig Q k) (q'' : Q) : Bool :=
  step e.dst q'' && !(e.hasNow && lab q'' now)

omit [Fintype Q] in
/-- The extension `x = (e, q'')` is admissible against `T`: `q''` may extend `e` and the
extended key is not yet in `T`. -/
def Extendable (T : Finset (PathEntry sig Q k)) (x : PathEntry sig Q k × Q) : Prop :=
  canExtend lab step now x.1 x.2 = true ∧ (extendEntry lab now x.1 x.2).key ∉ T.image PathEntry.key

omit [Fintype Q] in
instance (T : Finset (PathEntry sig Q k)) : DecidablePred (Extendable lab step now T) :=
  fun _ => instDecidableAnd

/-- **One closure round**: add every one-state extension of an entry whose key is new. -/
def closureStep (T : Finset (PathEntry sig Q k)) : Finset (PathEntry sig Q k) :=
  T ∪ ((T ×ˢ (Finset.univ : Finset Q)).filter (Extendable lab step now T)).image
    (fun (x : PathEntry sig Q k × Q) => extendEntry lab now x.1 x.2)

omit [Fintype Q] [DecidableEq Q] in
variable (k) in
/-- The one-state path at `q`. -/
def singleEntry (q : Q) : PathEntry sig Q k where
  src := q
  dst := q
  hasNow := lab q now
  ty := kTypeOfFin (listSeg [lab q]) k
  rep := [lab q]

variable (k) in
/-- The closure's seed: every one-state path. -/
def closureInit : Finset (PathEntry sig Q k) := Finset.univ.image (singleEntry lab now k)

/-- `n` closure rounds, stopping early at the first stationary round. -/
def closureIter : ℕ → Finset (PathEntry sig Q k) → Finset (PathEntry sig Q k)
  | 0, T => T
  | n + 1, T =>
      if closureStep lab step now T = T then T
      else closureIter n (closureStep lab step now T)

/-- The number of rounds that certainly suffices: the number of keys, computed arithmetically
(never by enumerating `KType sig k`). -/
def closureBound (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (Q : Type) [Fintype Q] (k : ℕ) : ℕ :=
  Fintype.card Q * (Fintype.card Q * (2 * 2 ^ Fintype.card (NormalForm sig k 0)))

omit [DecidableEq Q] in
theorem closureBound_eq (k : ℕ) :
    closureBound sig Q k = Fintype.card (Q × Q × Bool × KType sig k) := by
  simp [closureBound, Fintype.card_prod]

variable (k) in
/-- **The path-type closure** of a presentation: all realized keys, with one representative
each, reached from the one-state paths. -/
def pathClosure : Finset (PathEntry sig Q k) :=
  closureIter lab step now (closureBound sig Q k) (closureInit lab now k)

variable (k) in
/-- **The `k`-types of the `now`-free `step`-paths from `q` to `q'`.** -/
def pathTypes (q q' : Q) : Finset (KType sig k) :=
  ((pathClosure lab step now k).filter
    (fun e => e.src = q ∧ e.dst = q' ∧ e.hasNow = false)).image PathEntry.ty

variable (k) in
/-- **The `k`-types of the `step`-paths from `q` to `q'` reading `now` exactly once.** -/
def pathTypesNow (q q' : Q) : Finset (KType sig k) :=
  ((pathClosure lab step now k).filter
    (fun e => e.src = q ∧ e.dst = q' ∧ e.hasNow = true)).image PathEntry.ty

/-! ### The closure is a monotone iterate with a fixpoint -/

theorem subset_closureStep (T : Finset (PathEntry sig Q k)) :
    T ⊆ closureStep lab step now T := by
  unfold closureStep; exact Finset.subset_union_left

theorem iterate_closureStep_subset {n m : ℕ} (h : n ≤ m) (T : Finset (PathEntry sig Q k)) :
    (closureStep lab step now)^[n] T ⊆ (closureStep lab step now)^[m] T := by
  obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h
  clear h
  induction d with
  | zero => exact Finset.Subset.refl _
  | succ d ih =>
    rw [show n + (d + 1) = (n + d) + 1 from rfl, Function.iterate_succ_apply']
    exact ih.trans (subset_closureStep lab step now _)

theorem closureIter_eq_iterate (n : ℕ) (T : Finset (PathEntry sig Q k)) :
    closureIter lab step now n T = (closureStep lab step now)^[n] T := by
  induction n generalizing T with
  | zero => rfl
  | succ n ih =>
    unfold closureIter
    split_ifs with h
    · rw [Function.iterate_succ_apply, h, Function.iterate_fixed h]
    · rw [ih, Function.iterate_succ_apply]

/-- **The closure is stationary**: a non-stationary round adds an entry whose key is new, and
there are at most `closureBound` keys. -/
theorem closureStep_pathClosure :
    closureStep lab step now (pathClosure lab step now k) = pathClosure lab step now k := by
  unfold pathClosure
  rw [closureIter_eq_iterate, closureBound_eq]
  refine iterate_stabilizes _ (fun T => (T.image PathEntry.key).card) _
    (fun T => Finset.card_le_univ _) ?_ _
  intro T hT
  apply Finset.card_lt_card
  rw [Finset.ssubset_iff_subset_ne]
  refine ⟨Finset.image_subset_image (subset_closureStep lab step now T), ?_⟩
  intro heq
  apply hT
  refine Finset.Subset.antisymm ?_ (subset_closureStep lab step now T)
  intro e he
  have he' := he
  unfold closureStep at he'
  rcases Finset.mem_union.mp he' with h1 | h2
  · exact h1
  · obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp h2
    exfalso
    obtain ⟨-, hk⟩ := (Finset.mem_filter.mp hx).2
    apply hk
    rw [heq]
    exact Finset.mem_image_of_mem _ he

theorem iterate_subset_pathClosure (n : ℕ) :
    (closureStep lab step now)^[n] (closureInit lab now k) ⊆ pathClosure lab step now k := by
  have hfix := closureStep_pathClosure lab step now (k := k)
  unfold pathClosure at hfix ⊢
  rw [closureIter_eq_iterate] at hfix ⊢
  by_cases h : n ≤ closureBound sig Q k
  · exact iterate_closureStep_subset lab step now h _
  · rw [show n = (n - closureBound sig Q k) + closureBound sig Q k by omega,
      Function.iterate_add_apply, Function.iterate_fixed hfix]

/-! ### Soundness: every entry is realized -/

omit [Fintype Q] [DecidableEq Q] in
theorem realizes_singleEntry (q : Q) : Realizes lab step now (singleEntry lab now k q) := by
  refine ⟨⟨[q], StepPath.single q, ?_, rfl⟩, kTypeOfFin_listSeg _ _⟩
  simp only [singleEntry, List.countP_singleton]
  cases lab q now <;> rfl

omit [Fintype Q] [DecidableEq Q] in
theorem realizes_extendEntry {e : PathEntry sig Q k} (he : Realizes lab step now e) {q'' : Q}
    (hc : canExtend lab step now e q'' = true) :
    Realizes lab step now (extendEntry lab now e q'') := by
  obtain ⟨⟨p, hp, hcnt, hrep⟩, hty⟩ := he
  simp only [canExtend, Bool.and_eq_true, Bool.not_eq_true'] at hc
  obtain ⟨hstep, hnb⟩ := hc
  refine ⟨⟨p ++ [q''], StepPath.snoc q'' hp hstep, ?_, by simp [extendEntry, hrep]⟩,
    kTypeOfFin_listSeg _ _⟩
  rw [List.countP_append, hcnt, List.countP_singleton]
  change _ = bif e.hasNow || lab q'' now then 1 else 0
  rcases Bool.eq_false_or_eq_true e.hasNow with h1 | h1 <;>
    rcases Bool.eq_false_or_eq_true (lab q'' now) with h2 | h2 <;> simp [h1, h2] at hnb ⊢

theorem realizes_of_mem_iterate (n : ℕ) :
    ∀ e ∈ (closureStep lab step now)^[n] (closureInit lab now k), Realizes lab step now e := by
  induction n with
  | zero =>
    intro e he
    simp only [Function.iterate_zero, id_eq, closureInit] at he
    obtain ⟨q, -, rfl⟩ := Finset.mem_image.mp he
    exact realizes_singleEntry lab step now q
  | succ n ih =>
    intro e he
    rw [Function.iterate_succ_apply'] at he
    unfold closureStep at he
    rcases Finset.mem_union.mp he with h | h
    · exact ih e h
    · obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp h
      obtain ⟨hx₁, hc, -⟩ := Finset.mem_filter.mp hx
      exact realizes_extendEntry lab step now (ih _ (Finset.mem_product.mp hx₁).1) hc

/-! ### Completeness: every path's key is found -/

theorem exists_key_mem_closureStep {T : Finset (PathEntry sig Q k)} {e : PathEntry sig Q k}
    (he : e ∈ T) {q'' : Q} (hc : canExtend lab step now e q'' = true) :
    ∃ e₂ ∈ closureStep lab step now T, e₂.key = (extendEntry lab now e q'').key := by
  by_cases h : (extendEntry lab now e q'').key ∈ T.image PathEntry.key
  · obtain ⟨e₂, he₂, hk⟩ := Finset.mem_image.mp h
    exact ⟨e₂, subset_closureStep lab step now T he₂, hk⟩
  · refine ⟨extendEntry lab now e q'', ?_, rfl⟩
    unfold closureStep
    exact Finset.mem_union_right _ <| Finset.mem_image.mpr ⟨(e, q''),
      Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨he, Finset.mem_univ _⟩, ⟨hc, h⟩⟩, rfl⟩

/-- Every `step`-path reading `now` at most once has its key in some round of the closure,
with the composition congruence `kTypeOf_listSeg_append_congr` identifying the path's
`k`-type with the one computed on the stored representative. -/
theorem exists_mem_iterate_of_stepPath {q q' : Q} {p : List Q} (hp : StepPath step q q' p)
    (hc : p.countP (fun x => lab x now) ≤ 1) :
    ∃ n, ∃ e ∈ (closureStep lab step now)^[n] (closureInit lab now k),
      e.src = q ∧ e.dst = q' ∧ p.countP (fun x => lab x now) = (bif e.hasNow then 1 else 0) ∧
        e.ty = kTypeOf sig k (listSeg (pathLabels lab p)) := by
  induction hp with
  | single =>
    rename_i q
    refine ⟨0, singleEntry lab now k q, Finset.mem_image_of_mem _ (Finset.mem_univ q), rfl, rfl,
      ?_, kTypeOfFin_listSeg _ _⟩
    simp only [singleEntry, List.countP_singleton]
    cases lab q now <;> rfl
  | snoc q'' hp hs ih =>
    rename_i q q' p
    have hc' : p.countP (fun x => lab x now) ≤ 1 := by
      rw [List.countP_append] at hc; omega
    obtain ⟨n, e, he, hsrc, hdst, hcnt, hty⟩ := ih hc'
    have hreal := realizes_of_mem_iterate lab step now n e he
    rw [List.countP_append, hcnt, List.countP_singleton] at hc
    have hcan : canExtend lab step now e q'' = true := by
      simp only [canExtend, Bool.and_eq_true, Bool.not_eq_true', hdst, hs, true_and]
      rcases Bool.eq_false_or_eq_true e.hasNow with h1 | h1 <;>
        rcases Bool.eq_false_or_eq_true (lab q'' now) with h2 | h2 <;> simp [h1, h2] at hc ⊢
    obtain ⟨e₂, he₂, hk⟩ := exists_key_mem_closureStep lab step now he hcan
    obtain ⟨hk1, hk2, hk3, hk4⟩ := PathEntry.key_inj hk
    refine ⟨n + 1, e₂, by rw [Function.iterate_succ_apply']; exact he₂, ?_, hk2, ?_, ?_⟩
    · rw [hk1]; exact hsrc
    · rw [List.countP_append, hcnt, List.countP_singleton, hk3]
      change _ = bif e.hasNow || lab q'' now then 1 else 0
      rcases Bool.eq_false_or_eq_true e.hasNow with h1 | h1 <;>
        rcases Bool.eq_false_or_eq_true (lab q'' now) with h2 | h2 <;> simp [h1, h2] at hc ⊢
    · rw [hk4]
      change kTypeOfFin (listSeg (e.rep ++ [lab q''])) k = _
      rw [kTypeOfFin_listSeg, pathLabels_append, pathLabels_singleton]
      exact kTypeOf_listSeg_append_congr k (hreal.2.symm.trans hty) rfl

/-! ### The membership characterizations -/

theorem mem_pathTypes_iff_stepPath (q q' : Q) (τ : KType sig k) :
    τ ∈ pathTypes lab step now k q q' ↔
      ∃ p : List Q, StepPath step q q' p ∧ (∀ x ∈ p, lab x now = false) ∧
        kTypeOf sig k (listSeg (pathLabels lab p)) = τ := by
  constructor
  · intro h
    obtain ⟨e, he, rfl⟩ := Finset.mem_image.mp h
    obtain ⟨he, hsrc, hdst, hnow⟩ := Finset.mem_filter.mp he
    unfold pathClosure at he
    rw [closureIter_eq_iterate] at he
    obtain ⟨⟨p, hp, hcnt, hrep⟩, hty⟩ := realizes_of_mem_iterate lab step now _ e he
    rw [hsrc, hdst] at hp
    refine ⟨p, hp, ?_, by rw [hrep, hty]⟩
    rw [hnow] at hcnt
    intro x hx
    exact Bool.eq_false_iff.mpr (List.countP_eq_zero.mp hcnt x hx)
  · rintro ⟨p, hp, hfree, hty⟩
    have hc : p.countP (fun x => lab x now) = 0 :=
      List.countP_eq_zero.mpr (fun x hx => by rw [hfree x hx]; decide)
    obtain ⟨n, e, he, hsrc, hdst, hcnt, hty'⟩ :=
      exists_mem_iterate_of_stepPath lab step now hp (by omega)
    refine Finset.mem_image.mpr ⟨e, Finset.mem_filter.mpr
      ⟨iterate_subset_pathClosure lab step now n he, hsrc, hdst, ?_⟩, hty'.trans hty⟩
    rw [hc] at hcnt
    rcases Bool.eq_false_or_eq_true e.hasNow with h1 | h1 <;> simp [h1] at hcnt ⊢

theorem mem_pathTypesNow_iff_stepPath (q q' : Q) (τ : KType sig k) :
    τ ∈ pathTypesNow lab step now k q q' ↔
      ∃ p : List Q, StepPath step q q' p ∧ p.countP (fun x => lab x now) = 1 ∧
        kTypeOf sig k (listSeg (pathLabels lab p)) = τ := by
  constructor
  · intro h
    obtain ⟨e, he, rfl⟩ := Finset.mem_image.mp h
    obtain ⟨he, hsrc, hdst, hnow⟩ := Finset.mem_filter.mp he
    unfold pathClosure at he
    rw [closureIter_eq_iterate] at he
    obtain ⟨⟨p, hp, hcnt, hrep⟩, hty⟩ := realizes_of_mem_iterate lab step now _ e he
    rw [hsrc, hdst] at hp
    refine ⟨p, hp, ?_, by rw [hrep, hty]⟩
    rw [hnow] at hcnt
    exact hcnt
  · rintro ⟨p, hp, hc, hty⟩
    obtain ⟨n, e, he, hsrc, hdst, hcnt, hty'⟩ :=
      exists_mem_iterate_of_stepPath lab step now hp (by omega)
    refine Finset.mem_image.mpr ⟨e, Finset.mem_filter.mpr
      ⟨iterate_subset_pathClosure lab step now n he, hsrc, hdst, ?_⟩, hty'.trans hty⟩
    rw [hc] at hcnt
    rcases Bool.eq_false_or_eq_true e.hasNow with h1 | h1 <;> simp [h1] at hcnt ⊢

/-- **Membership in `pathTypes`**, in list terms: `τ` is the `k`-type of a nonempty `now`-free
list of states from `q` to `q'` whose consecutive states are `step`-related. -/
theorem mem_pathTypes_iff (q q' : Q) (τ : KType sig k) :
    τ ∈ pathTypes lab step now k q q' ↔
      ∃ p : List Q, p ≠ [] ∧ p.head? = some q ∧ p.getLast? = some q' ∧
        p.IsChain (fun x y => step x y = true) ∧ (∀ x ∈ p, lab x now = false) ∧
        kTypeOf sig k (listSeg (pathLabels lab p)) = τ := by
  rw [mem_pathTypes_iff_stepPath]
  simp only [stepPath_iff, and_assoc]

/-- **Membership in `pathTypesNow`**, in list terms: the same with exactly one `now` state. -/
theorem mem_pathTypesNow_iff (q q' : Q) (τ : KType sig k) :
    τ ∈ pathTypesNow lab step now k q q' ↔
      ∃ p : List Q, p ≠ [] ∧ p.head? = some q ∧ p.getLast? = some q' ∧
        p.IsChain (fun x y => step x y = true) ∧ p.countP (fun x => lab x now) = 1 ∧
        kTypeOf sig k (listSeg (pathLabels lab p)) = τ := by
  rw [mem_pathTypesNow_iff_stepPath]
  simp only [stepPath_iff, and_assoc]

end PathClosure

/-! ## Liveness: the states starting an infinite chain of a finite graph -/

section Liveness

variable {Q : Type} [Fintype Q] [DecidableEq Q] (G : Q → Q → Bool)

/-- One pruning round: keep the states that still have a `G`-successor in the set. -/
def pruneStep (S : Finset Q) : Finset Q := S.filter (fun x => ∃ y ∈ S, G x y = true)

/-- **The live states**: the greatest fixpoint of `pruneStep`, reached from `univ` within
`Fintype.card Q` rounds. -/
def liveSet : Finset Q := (pruneStep G)^[Fintype.card Q] Finset.univ

/-- `q` starts an infinite `G`-chain — decided. -/
def live (q : Q) : Bool := decide (q ∈ liveSet G)

omit [Fintype Q] [DecidableEq Q] in
/-- `q` starts an infinite `G`-chain. -/
def HasChain (q : Q) : Prop := ∃ f : ℕ → Q, f 0 = q ∧ ∀ n, G (f n) (f (n + 1)) = true

omit [Fintype Q] [DecidableEq Q] in
theorem pruneStep_subset (S : Finset Q) : pruneStep G S ⊆ S := Finset.filter_subset _ _

omit [DecidableEq Q] in
/-- The pruning iterate is stationary after `Fintype.card Q` rounds: a non-stationary round
strictly shrinks the set. -/
theorem pruneStep_liveSet : pruneStep G (liveSet G) = liveSet G := by
  unfold liveSet
  refine iterate_stabilizes _ (fun S => Fintype.card Q - S.card) _ (fun S => Nat.sub_le _ _) ?_ _
  intro S hS
  have h1 : (pruneStep G S).card < S.card :=
    Finset.card_lt_card (Finset.ssubset_iff_subset_ne.mpr ⟨pruneStep_subset G S, hS⟩)
  have h2 := Finset.card_le_univ S
  omega

omit [DecidableEq Q] in
theorem hasChain_mem_iterate {q : Q} (h : HasChain G q) (n : ℕ) :
    q ∈ (pruneStep G)^[n] Finset.univ := by
  induction n generalizing q with
  | zero => exact Finset.mem_univ q
  | succ n ih =>
    rw [Function.iterate_succ_apply']
    have hq := ih h
    obtain ⟨f, hf0, hf⟩ := h
    refine Finset.mem_filter.mpr ⟨hq, f 1, ih ⟨fun m => f (m + 1), rfl, fun m => hf (m + 1)⟩, ?_⟩
    rw [← hf0]; exact hf 0

omit [Fintype Q] [DecidableEq Q] in
/-- Every member of a set closed under pruning starts an infinite chain: choose successors. -/
theorem hasChain_of_mem_fixed {S : Finset Q} (hS : pruneStep G S = S) {q : Q} (hq : q ∈ S) :
    HasChain G q := by
  have hnext : ∀ x : {x // x ∈ S}, ∃ y : {x // x ∈ S}, G x.1 y.1 = true := by
    intro x
    have hx : x.1 ∈ pruneStep G S := by rw [hS]; exact x.2
    obtain ⟨y, hy, hG⟩ := (Finset.mem_filter.mp hx).2
    exact ⟨⟨y, hy⟩, hG⟩
  choose next hnext using hnext
  let chain : ℕ → {x // x ∈ S} := fun n => Nat.rec ⟨q, hq⟩ (fun _ x => next x) n
  exact ⟨fun n => (chain n).1, rfl, fun n => hnext (chain n)⟩

/-- **`live` decides `HasChain`.** -/
theorem live_iff (q : Q) : live G q = true ↔ HasChain G q := by
  unfold live
  rw [decide_eq_true_iff]
  exact ⟨hasChain_of_mem_fixed G (pruneStep_liveSet G), fun h => hasChain_mem_iterate G h _⟩

end Liveness

section PresentationLiveness

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {Q : Type} [Fintype Q] [DecidableEq Q]
variable (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (now : sig.preds) (k : ℕ)

/-- **Forward liveness**: `q` starts an infinite forward chain in the graph `G_τ` joining `x`
to `y` when some `now`-free path from `x` to `y` has `k`-type `τ`. -/
def fwdLive (τ : KType sig k) (q : Q) : Bool :=
  live (fun x y => decide (τ ∈ pathTypes lab step now k x y)) q

/-- **Backward liveness**: `q` ends an infinite backward chain in `G_τ`. -/
def bwdLive (τ : KType sig k) (q : Q) : Bool :=
  live (fun x y => decide (τ ∈ pathTypes lab step now k y x)) q

theorem fwdLive_iff (τ : KType sig k) (q : Q) :
    fwdLive lab step now k τ q = true ↔
      ∃ f : ℕ → Q, f 0 = q ∧ ∀ n, τ ∈ pathTypes lab step now k (f n) (f (n + 1)) := by
  unfold fwdLive
  rw [live_iff]
  simp only [HasChain, decide_eq_true_iff]

theorem bwdLive_iff (τ : KType sig k) (q : Q) :
    bwdLive lab step now k τ q = true ↔
      ∃ f : ℕ → Q, f 0 = q ∧ ∀ n, τ ∈ pathTypes lab step now k (f (n + 1)) (f n) := by
  unfold bwdLive
  rw [live_iff]
  simp only [HasChain, decide_eq_true_iff]

end PresentationLiveness

end FormalSystem.Metalogic.WeakCanonical
