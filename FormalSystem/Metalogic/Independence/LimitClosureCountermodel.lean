/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.PastedCoarseModels
import FormalSystem.Metalogic.Independence.LimitClosureFrame
import FormalSystem.Semantics.PlusLanguage.PlusLimitClosure

/-!
# The limit-closure formula is not a `.Base` theorem of TM⁺

The coarsened-state model `eK` on the limit-closure frame `EF`
(`Metalogic/Independence/LimitClosureFrame.lean`), with `π` the Boolean class component and every
sentence letter read as the `true` class, is paste-closed and refutes the limit-closure formula
`blc p` (`Semantics/PlusLanguage/PlusLimitClosure.lean`) at every history and time. By soundness
of TM⁺ for paste-closed coarse models (`Metalogic/Independence/PastedCoarseModels.lean`), `blc p`
is not derivable at `.Base`.

## The argument

Everything reduces to one fact about `π`-images.

* **The image of the world histories of `EF` under `π` is exactly `evFalse`**, the set of
  eventually-false Boolean sequences. Every image is eventually false (`hist_image_mem`): a walk
  that ever leaves the hub carries a budget bounding its remaining `true`-visits, and a walk that
  never leaves it is constantly `false`. Conversely every eventually-false sequence is an image
  (`exists_hist_of_evFalse`): take as budget at `n` the number of `true`s strictly between `n`
  and the point after which the sequence is `false`.
* **Paste-closed.** Splicing two eventually-false sequences at a common value gives an
  eventually-false sequence (`eK_pasteClosed`), so PS and US hold.
* **Not closed.** The all-`true`-from-here-on limit is missing, and that is the whole refutation
  (`blc_cRefuted`). The antecedent of `blc p` holds: some sequence in the class reaches a later
  `true`, and at any `true`-point of any sequence in the class, a sequence with one further
  `true` exists. The consequent asks for a single sequence in the class with `true` recurring
  after every later `true`-point — infinitely many `true`s, which no member of `evFalse` has.

In the one-line reading: the coarsened countermodel is a dense, non-closed bundle. PS and US say
the bundle is paste-closed, MF says it is translation-closed, and nothing in TM⁺ says it is
closed.

## Consistency check

Under `⊡ = id` the formula is a propositional tautology, hence a theorem of TM⁺ extended by
*Determined*, and TM⁺ + *Determined* is sound for deterministic frames. So the countermodel is
necessarily nondeterministic, and it is: the hub of `EF` reaches every state in one step, and the
coarsening identifies states that the exact-state reading of `⊡` would keep apart.

## Main Definitions

- `evFalse` — the eventually-false Boolean sequences
- `eK` — the coarse model on `EF`

## Main Results

- `hist_image_mem`, `exists_hist_of_evFalse` — the `π`-image of the histories of `EF` is `evFalse`
- `eK_pasteClosed`
- `blc_cRefuted` — `¬ CTruthAt eK τ t (blc p)` at every history and time
- `blc_not_plusDerivable_base` — `¬ PlusDerivable FrameClass.Base [] (blc p)`

## References

Paper: — (formalization-native)
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Semantics.Walk
open CTruth

/-- The eventually-false Boolean sequences over `ℤ`. -/
def evFalse : Set (ℤ → Bool) := {β | ∃ m, ∀ k, m ≤ k → β k = false}

/-- Once a walk is at a non-hub state with budget `k`, it stays at non-hub states with budget at
most `k`. -/
theorem eR_budget (σ : ℤ → EW) (hσ : IsWalk eR σ) (n : ℤ) (c : Bool) (k : ℕ)
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

/-- A walk at a non-hub state is eventually in the `false` class, by strong induction on the
budget: a later `true`-visit strictly lowers it. -/
theorem eR_evFalse_aux (σ : ℤ → EW) (hσ : IsWalk eR σ) :
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

/-- The class-sequence of every `eR`-walk is eventually false. -/
theorem eR_image_mem (σ : ℤ → EW) (hσ : IsWalk eR σ) : (fun n => eπ (σ n)) ∈ evFalse := by
  by_cases hall : ∀ n, σ n = none
  · exact ⟨0, fun j _ => by simp [hall j, eπ]⟩
  · push Not at hall
    obtain ⟨n, hn⟩ := hall
    cases h : σ n with
    | none => exact (hn h).elim
    | some x => obtain ⟨c, k⟩ := x; exact eR_evFalse_aux σ hσ k n c h

/-- Every eventually-false sequence is the class-sequence of an `eR`-walk: the budget at `n` is
the number of `true`s strictly between `n` and the bound. -/
theorem mem_eR_image (β : ℤ → Bool) (hβ : β ∈ evFalse) :
    ∃ σ : ℤ → EW, IsWalk eR σ ∧ ∀ n, eπ (σ n) = β n := by
  obtain ⟨M, hM⟩ := hβ
  let cnt : ℤ → ℕ := fun n => ((Finset.Ioo n M).filter (fun m => β m = true)).card
  refine ⟨fun n => some (β n, cnt n), fun n => ?_, fun n => rfl⟩
  change cnt (n + 1) ≤ cnt n ∧ (β (n + 1) = true → cnt (n + 1) < cnt n)
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

/-- The class-sequence of every world history of `EF` is eventually false. -/
theorem hist_image_mem (τ : WorldHistory EF) : (fun n : ℤ => eπ (τ.state n)) ∈ evFalse :=
  eR_image_mem _ (isWalk_state τ)

/-- Every eventually-false sequence is the class-sequence of a world history of `EF`. -/
theorem exists_hist_of_evFalse (β : ℤ → Bool) (hβ : β ∈ evFalse) :
    ∃ η : WorldHistory EF, ∀ n : ℤ, eπ (η.state n) = β n := by
  obtain ⟨f, hf, he⟩ := mem_eR_image β hβ
  exact ⟨histOfWalk f hf, he⟩

/-- The coarse model on `EF`: `π` is the Boolean class component, and every sentence letter is
read as the `true` class, so `atom_inv` is a rewrite. -/
def eK : CoarseModel EF where
  toModel := ⟨fun w _ => eπ w = true⟩
  Cls := Bool
  π := eπ
  atom_inv := fun {w u} h _ hv => by
    have h' : eπ w = eπ u := h
    change eπ u = true
    rw [← h']; exact hv

/-- The splice of two class-sequences of `EF` at a common value is again one: the splice of two
eventually-false sequences is eventually false. Stated at `ℤ` so that `omega` sees the times. -/
theorem eK_pasteClosed_aux (ρ σ : WorldHistory EF) (t : ℤ)
    (h : eπ (ρ.state t) = eπ (σ.state t)) :
    ∃ η : WorldHistory EF, (∀ s : ℤ, s ≤ t → eπ (η.state s) = eπ (ρ.state s)) ∧
      (∀ s : ℤ, t ≤ s → eπ (η.state s) = eπ (σ.state s)) := by
  obtain ⟨m, hm⟩ := hist_image_mem σ
  obtain ⟨η, he⟩ := exists_hist_of_evFalse
    (fun s => if s ≤ t then eπ (ρ.state s) else eπ (σ.state s))
    ⟨max m (t + 1), fun k hk => by
      have h1 : ¬ k ≤ t := by omega
      simp only [h1, if_false]
      exact hm k (by omega)⟩
  refine ⟨η, fun s hs => ?_, fun s hs => ?_⟩
  · rw [he s]; simp only [hs, if_true]
  · rw [he s]
    by_cases hst : s ≤ t
    · obtain rfl : s = t := le_antisymm hst hs
      simp only [le_refl, if_true]; exact h
    · simp only [hst, if_false]

/-- `eK` is paste-closed. -/
theorem eK_pasteClosed : eK.PasteClosed := fun ρ σ t h => eK_pasteClosed_aux ρ σ t h

/--
**The refutation.** `blc p` fails in `eK` at every history and time. The antecedent holds because
`evFalse` contains, for any finite pattern, a sequence realising it; the consequent would give a
single eventually-false sequence with a `true` beyond every bound.
-/
theorem blc_cRefuted (p : Atom) (τ : WorldHistory EF) (t : ℤ) : ¬ CTruthAt eK τ t (blc p) := by
  intro h
  have hyp : CTruthAt eK τ t ((dstab (someFuture (.atom p))).and
      (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))) := by
    rw [and_iff]
    constructor
    · obtain ⟨η, he⟩ := exists_hist_of_evFalse
        (fun n => if n = t + 1 then true else if n = t then eπ (τ.state t) else false)
        ⟨t + 2, fun k hk => by
          have h1 : k ≠ t + 1 := by omega
          have h2 : k ≠ t := by omega
          simp [h1, h2]⟩
      rw [dstab_iff]
      refine ⟨η, ?_,
        (someFuture_iff eK η t _).mpr ⟨t + 1, (show (t : ℤ) < t + 1 by omega), ?_⟩⟩
      · change eπ (τ.state t) = eπ (η.state t)
        rw [he t]; simp
      · change eπ (η.state (t + 1)) = true
        rw [he (t + 1)]; simp
    · intro ρ _
      rw [allFuture_iff]
      intro s _ hp
      have hp' : eπ (ρ.state s) = true := hp
      obtain ⟨η, he⟩ := exists_hist_of_evFalse
        (fun n => if n = s ∨ n = s + 1 then true else false)
        ⟨s + 2, fun k hk => by
          have h1 : k ≠ s := by omega
          have h2 : k ≠ s + 1 := by omega
          simp [h1, h2]⟩
      rw [dstab_iff]
      refine ⟨η, ?_,
        (someFuture_iff eK η s _).mpr ⟨s + 1, (show (s : ℤ) < s + 1 from Int.lt_succ s), ?_⟩⟩
      · change eπ (ρ.state s) = eπ (η.state s)
        rw [he s, hp']; simp
      · change eπ (η.state (s + 1)) = true
        rw [he (s + 1)]; simp
  have hc := h hyp
  rw [dstab_iff] at hc
  obtain ⟨ρ, _, hc⟩ := hc
  rw [and_iff] at hc
  obtain ⟨hF, hG⟩ := hc
  rw [someFuture_iff] at hF
  rw [allFuture_iff] at hG
  obtain ⟨m, hm⟩ := hist_image_mem ρ
  have key : ∀ j : ℕ, ∃ s : ℤ, t + j < s ∧ eπ (ρ.state s) = true := by
    intro j
    induction j with
    | zero =>
      obtain ⟨s, hs, hp⟩ := hF
      exact ⟨s, by simpa using hs, hp⟩
    | succ j ih =>
      obtain ⟨s, hs, hp⟩ := ih
      have hts : t < s := by omega
      obtain ⟨s', hs', hp'⟩ := (someFuture_iff eK ρ s _).mp (hG s hts hp)
      have hs'' : s < s' := hs'
      exact ⟨s', by push_cast; omega, hp'⟩
  obtain ⟨s, hs, hp⟩ := key (m - t).toNat
  have hf : eπ (ρ.state s) = false := hm s (by omega)
  rw [hf] at hp
  exact Bool.false_ne_true hp

/--
**The limit-closure formula is not a `.Base` theorem of TM⁺.** `eK` is a paste-closed coarse
model refuting it, and TM⁺ at `.Base` is sound for such models.

Paper: — (formalization-native)
-/
theorem blc_not_plusDerivable_base (p : Atom) :
    ¬ PlusDerivable FrameClass.Base [] (blc p) := by
  obtain ⟨τ⟩ := PartialHistory.hF_nonempty EF (none : EW)
  exact not_plusDerivable_of_pcRefuted EF eK eK_pasteClosed τ (0 : ℤ) (blc_cRefuted p τ 0)

end FormalSystem.Metalogic.Independence
