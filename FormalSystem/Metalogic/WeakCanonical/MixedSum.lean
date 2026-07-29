/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.ColourOrders

/-!
# Mixing two ordered sums over different index orders

Doets 1987, 3.1.8 — *the mixing lemma*: if the `Z`-coloured index orders are `≡ⁿ`, with `Z` the
finite set of `k`-types and the colour of an index the `k`-type of its summand, then the ordered
sums are `≡ⁿ`.

## The invariant

`OrderedSum.lean`'s `doets_lemma_1_4` is the special case `I = J`, and `NEquivalence.lean`
carries out its game argument with `BiCompat` plus the `CompData` bookkeeping structure. Neither
survives the passage to two index orders: `BiCompat` matches a witness at index `j` in one sum
with a witness at *the same* `j` in the other, and `CompData` indexes its per-summand data by the
shared index type.

`Mixed` is the two-index replacement. A game position consists of environments `eA`, `eB` in the
two sums together with:

* a **slot family** `uA : Fin s → I`, `uB : Fin s → J` — the matched pairs of *indices*, injective
  on each side, carrying a depth-`d` strategy on the **coloured index orders**;
* for each slot `t`, a depth-`d` strategy **inside the matched pair of summands** `m (uA t)`,
  `m' (uB t)`, on environments `wA`, `wB` of arity `n` (the full position count — slots hold
  padding at positions living in other summands);
* the **link**: a position `p` assigned to slot `t` has `eA p = ⟨uA t, wA p⟩` and
  `eB p = ⟨uB t, wB p⟩`.

Two design choices keep the bookkeeping free of dependent casts, which is what made
`build_bicompat` heavy:

1. The link is stated as an equation in the **sum carrier** (a `Sigma` equality), never as a
   transport of a summand element along an index equality.
2. Every slot's environment has the **same arity `n`**, so a move extends every slot by exactly
   one position — the touched slot by the real witness, the others by a junk move answered by
   their own strategy. No `Fin (sz t)` reindexing, and hence none of `CompData`'s
   `NormalForm`-type casts.

The depth budget `d + n ≤ k` is exactly what a freshly created slot needs: its summands are
`≡ₖ` (same colour), and `backForth_pad` spends `n` moves to reach arity `n` and one more for the
real witness, leaving depth `d`.

## Main results

* `Mixed` — the invariant.
* `mixed_step` — one move: Spoiler plays in the second sum, Duplicator answers, and the invariant
  is restored one depth down and one arity up.
* `backForth_of_mixed` — the invariant yields a strategy on the sums.
* `kEquiv_orderedSum_of_kEquiv_colour` — the mixing lemma itself.

## References
- Doets 1987/1989, 3.1.8: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1992, §8, printed p.188 (*"by another simple game argument"*)
-/

namespace FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## Symmetry and padding for `BackForth` -/

/-- The back-and-forth relation is symmetric: swap the two structures and the two clauses. -/
theorem backForth_symm (sig : MonadicSignature) :
    ∀ (d n : Nat) (M N : OrderedMonadicStructure sig)
      (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
      BackForth sig d n M N eM eN → BackForth sig d n N M eN eM := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _ _; trivial
  | succ d ih =>
    intro n M N eM eN h
    obtain ⟨hf, hb⟩ := h
    refine ⟨fun a => ?_, fun b => ?_⟩
    · obtain ⟨b, hat, hbf⟩ := hb a
      exact ⟨b, fun ak => (hat ak).symm, ih (n + 1) M N _ _ hbf⟩
    · obtain ⟨a, hat, hbf⟩ := hf b
      exact ⟨a, fun ak => (hat ak).symm, ih (n + 1) M N _ _ hbf⟩

/--
**Padding.** A depth-`(n + r)` strategy from the empty position can be played out into *some*
position of arity `n` retaining depth `r`.

Only the existence of the padded environments matters: they are the junk entries a slot holds at
positions living in other summands. The junk point `junk` is what Spoiler is made to play at each
padding move, so no nonemptiness hypothesis is needed beyond it.
-/
theorem backForth_pad (sig : MonadicSignature) (M N : OrderedMonadicStructure sig)
    (junk : N.carrier) :
    ∀ (n r : Nat), BackForth sig (n + r) 0 M N Fin.elim0 Fin.elim0 →
      ∃ (wM : Fin n → M.carrier) (wN : Fin n → N.carrier), BackForth sig r n M N wM wN := by
  intro n
  induction n with
  | zero =>
    intro r h
    exact ⟨Fin.elim0, Fin.elim0, by simpa using h⟩
  | succ n ih =>
    intro r h
    have harith : n + 1 + r = n + (r + 1) := by omega
    obtain ⟨wM, wN, hbf⟩ := ih (r + 1) (harith ▸ h)
    obtain ⟨hfwd, _⟩ := hbf
    obtain ⟨a, _, hbf'⟩ := hfwd junk
    exact ⟨Fin.cons a wM, Fin.cons junk wN, hbf'⟩

/-! ## Order in an ordered sum

Three lemmas isolate every comparison the mixing argument performs, so that no later proof has to
unfold the lexicographic order or handle a `Sigma` transport by hand.
-/

private theorem sum_lt_iff {I : Type} [LinearOrder I] {m : I → OrderedMonadicStructure sig}
    (x z : (orderedSum sig I m).carrier) :
    x < z ↔ x.1 < z.1 ∨ ∃ h : x.1 = z.1, h ▸ x.2 < z.2 := by
  change @LT.lt (Sigma fun i => (m i).carrier) Sigma.Lex.linearOrder.toLT x z ↔ _
  exact Sigma.Lex.lt_def

/-- Inside one summand, the sum order is the summand's order. -/
private theorem sumPt_lt_sumPt {I : Type} [LinearOrder I] {m : I → OrderedMonadicStructure sig}
    {i : I} (c c' : (m i).carrier) :
    (orderedSumPt (ms := m) i c) < (orderedSumPt (ms := m) i c') ↔ c < c' := by
  rw [sum_lt_iff]
  constructor
  · rintro (h | ⟨_, h2⟩)
    · exact absurd h (lt_irrefl i)
    · exact h2
  · exact fun h => Or.inr ⟨rfl, h⟩

/-- Across distinct summands, the sum order is the index order. -/
private theorem sumPt_lt_of_ne {I : Type} [LinearOrder I] {m : I → OrderedMonadicStructure sig}
    (i : I) (c : (m i).carrier) (z : (orderedSum sig I m).carrier) (hne : i ≠ z.1) :
    (orderedSumPt (ms := m) i c) < z ↔ i < z.1 := by
  rw [sum_lt_iff]
  constructor
  · rintro (h | ⟨h, _⟩)
    · exact h
    · exact absurd h hne
  · exact Or.inl

/-- Across distinct summands, the sum order is the index order (other direction). -/
private theorem lt_sumPt_of_ne {I : Type} [LinearOrder I] {m : I → OrderedMonadicStructure sig}
    (z : (orderedSum sig I m).carrier) (i : I) (c : (m i).carrier) (hne : z.1 ≠ i) :
    z < (orderedSumPt (ms := m) i c) ↔ z.1 < i := by
  rw [sum_lt_iff]
  constructor
  · rintro (h | ⟨h, _⟩)
    · exact h
    · exact absurd h hne
  · exact Or.inl

/-! ## Atom agreement for an extended pair of sum environments -/

/--
**The winning condition, one move on.**

Given the atom agreement already achieved at `n` positions, the index-level comparisons between
the new indices `i₀`, `j₀` and the old ones, and the atom agreement of the extended environments
*inside* the matched summands, the extended sum environments agree on every atom.

`hlinkA` / `hlinkB` are the link fields of `Mixed`, restricted to the touched slot: a position
lying in summand `i₀` is `⟨i₀, wA q⟩`, so its comparison with the new point is the summand
comparison the pair game already decided.
-/
private theorem orderedSum_atoms_cons {I J : Type} [LinearOrder I] [LinearOrder J]
    {m : I → OrderedMonadicStructure sig} {m' : J → OrderedMonadicStructure sig} {n : Nat}
    {eA : Fin n → (orderedSum sig I m).carrier} {eB : Fin n → (orderedSum sig J m').carrier}
    {i₀ : I} {j₀ : J} (a : (m i₀).carrier) (b : (m' j₀).carrier)
    (wA : Fin n → (m i₀).carrier) (wB : Fin n → (m' j₀).carrier)
    (hlinkA : ∀ q : Fin n, (eA q).1 = i₀ → eA q = orderedSumPt (ms := m) i₀ (wA q))
    (hlinkB : ∀ q : Fin n, (eB q).1 = j₀ → eB q = orderedSumPt (ms := m') j₀ (wB q))
    (hidxEq : ∀ q : Fin n, (eA q).1 = i₀ ↔ (eB q).1 = j₀)
    (hidxLtF : ∀ q : Fin n, i₀ < (eA q).1 ↔ j₀ < (eB q).1)
    (hidxLtB : ∀ q : Fin n, (eA q).1 < i₀ ↔ (eB q).1 < j₀)
    (hpair : ∀ ak : AtomKind sig (n + 1),
      AtomEval (m i₀) (Fin.cons a wA) ak ↔ AtomEval (m' j₀) (Fin.cons b wB) ak)
    (hold : ∀ ak : AtomKind sig n,
      AtomEval (orderedSum sig I m) eA ak ↔ AtomEval (orderedSum sig J m') eB ak) :
    ∀ ak : AtomKind sig (n + 1),
      AtomEval (orderedSum sig I m) (Fin.cons (orderedSumPt (ms := m) i₀ a) eA) ak ↔
      AtomEval (orderedSum sig J m') (Fin.cons (orderedSumPt (ms := m') j₀ b) eB) ak := by
  intro ak
  cases ak with
  | pred p idx =>
    cases idx using Fin.cases with
    | zero =>
      have hp := hpair (.pred p 0)
      simp only [AtomEval, Fin.cons_zero] at hp ⊢
      exact hp
    | succ q =>
      have hp := hold (.pred p q)
      simp only [AtomEval, Fin.cons_succ] at hp ⊢
      exact hp
  | order idx1 idx2 hne =>
    cases idx1 using Fin.cases with
    | zero =>
      cases idx2 using Fin.cases with
      | zero => exact absurd rfl hne
      | succ q =>
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ]
        by_cases h : (eA q).1 = i₀
        · have h' : (eB q).1 = j₀ := (hidxEq q).mp h
          rw [hlinkA q h, hlinkB q h', sumPt_lt_sumPt, sumPt_lt_sumPt]
          have hp := hpair (.order 0 q.succ (Ne.symm (Fin.succ_ne_zero q)))
          simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at hp
          exact hp
        · have h' : ¬ ((eB q).1 = j₀) := fun hh => h ((hidxEq q).mpr hh)
          rw [sumPt_lt_of_ne i₀ a (eA q) (Ne.symm h), sumPt_lt_of_ne j₀ b (eB q) (Ne.symm h')]
          exact hidxLtF q
    | succ q =>
      cases idx2 using Fin.cases with
      | zero =>
        simp only [AtomEval, Fin.cons_zero, Fin.cons_succ]
        by_cases h : (eA q).1 = i₀
        · have h' : (eB q).1 = j₀ := (hidxEq q).mp h
          rw [hlinkA q h, hlinkB q h', sumPt_lt_sumPt, sumPt_lt_sumPt]
          have hp := hpair (.order q.succ 0 (Fin.succ_ne_zero q))
          simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at hp
          exact hp
        · have h' : ¬ ((eB q).1 = j₀) := fun hh => h ((hidxEq q).mpr hh)
          rw [lt_sumPt_of_ne (eA q) i₀ a h, lt_sumPt_of_ne (eB q) j₀ b h']
          exact hidxLtB q
      | succ q2 =>
        have hne' : q ≠ q2 := fun heq => hne (by simp [heq])
        have hp := hold (.order q q2 hne')
        simp only [AtomEval, Fin.cons_succ] at hp ⊢
        exact hp

/-! ## The mixing invariant -/

/--
**The mixing invariant** at remaining depth `d` with `n` positions played.

See the module docstring for the reading of each clause. `slotOf` assigns each position the slot
(matched pair of indices) whose summands it lives in; `slotOf` is surjective, so every slot has a
live position and hence a point available to play as junk.
-/
def Mixed (sig : MonadicSignature) (k : Nat) {I J : Type} [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (d n : Nat)
    (eA : Fin n → (orderedSum sig I m).carrier)
    (eB : Fin n → (orderedSum sig J m').carrier) : Prop :=
  d + n ≤ k ∧
  (∀ ak : AtomKind sig n,
    AtomEval (orderedSum sig I m) eA ak ↔ AtomEval (orderedSum sig J m') eB ak) ∧
  ∃ (s : Nat) (uA : Fin s → I) (uB : Fin s → J) (slotOf : Fin n → Fin s),
    Function.Injective uA ∧ Function.Injective uB ∧
    (∀ ak : AtomKind (colourSig (KType sig k)) s,
      AtomEval (kTypeColouring sig k m) uA ak ↔ AtomEval (kTypeColouring sig k m') uB ak) ∧
    BackForth (colourSig (KType sig k)) d s
      (kTypeColouring sig k m) (kTypeColouring sig k m') uA uB ∧
    (∀ t : Fin s, ∃ p : Fin n, slotOf p = t) ∧
    (∀ t : Fin s, ∃ (wA : Fin n → (m (uA t)).carrier) (wB : Fin n → (m' (uB t)).carrier),
      (∀ ak : AtomKind sig n, AtomEval (m (uA t)) wA ak ↔ AtomEval (m' (uB t)) wB ak) ∧
      BackForth sig d n (m (uA t)) (m' (uB t)) wA wB ∧
      (∀ p : Fin n, slotOf p = t →
        eA p = orderedSumPt (ms := m) (uA t) (wA p) ∧
        eB p = orderedSumPt (ms := m') (uB t) (wB p)))

/-- The invariant is symmetric in the two sums. Halves the move analysis: Duplicator's answer to
a move in the first sum is Duplicator's answer to a move in the second sum of the swapped
position. -/
theorem Mixed.symm {k : Nat} {I J : Type} [LinearOrder I] [LinearOrder J]
    {m : I → OrderedMonadicStructure sig} {m' : J → OrderedMonadicStructure sig}
    {d n : Nat}
    {eA : Fin n → (orderedSum sig I m).carrier}
    {eB : Fin n → (orderedSum sig J m').carrier}
    (h : Mixed sig k m m' d n eA eB) : Mixed sig k m' m d n eB eA := by
  obtain ⟨hbud, hsum, s, uA, uB, slotOf, hinjA, hinjB, hidx, hstrat, hsurj, hcomp⟩ := h
  refine ⟨hbud, fun ak => (hsum ak).symm, s, uB, uA, slotOf, hinjB, hinjA,
    fun ak => (hidx ak).symm,
    backForth_symm _ d s (kTypeColouring sig k m) (kTypeColouring sig k m') uA uB hstrat,
    hsurj, fun t => ?_⟩
  obtain ⟨wA, wB, hat, hbf, hlink⟩ := hcomp t
  exact ⟨wB, wA, fun ak => (hat ak).symm,
    backForth_symm _ d n (m (uA t)) (m' (uB t)) wA wB hbf,
    fun p hp => ⟨(hlink p hp).2, (hlink p hp).1⟩⟩

end FormalSystem.Metalogic.WeakCanonical
