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

/-! ## Reading the coloured index game -/

/-- Order agreement between two matched index tuples. -/
private theorem colour_lt_agree {ι I J : Type} [LinearOrder I] [LinearOrder J]
    {c : I → ι} {c' : J → ι} {s : Nat} {uA : Fin s → I} {uB : Fin s → J}
    (hidx : ∀ ak : AtomKind (colourSig ι) s,
      AtomEval (colourStructure I c) uA ak ↔ AtomEval (colourStructure J c') uB ak)
    (t₁ t₂ : Fin s) : uA t₁ < uA t₂ ↔ uB t₁ < uB t₂ := by
  by_cases h : t₁ = t₂
  · subst h; simp
  · exact hidx (.order t₁ t₂ h)

/-- Colour agreement between two matched index tuples. -/
private theorem colour_eq_agree {ι I J : Type} [LinearOrder I] [LinearOrder J]
    {c : I → ι} {c' : J → ι} {s : Nat} {uA : Fin s → I} {uB : Fin s → J}
    (hidx : ∀ ak : AtomKind (colourSig ι) s,
      AtomEval (colourStructure I c) uA ak ↔ AtomEval (colourStructure J c') uB ak)
    (t : Fin s) : c (uA t) = c' (uB t) :=
  ((hidx (.pred (c (uA t)) t)).mp rfl).symm

/-! ## One move -/

/-- Extend an untouched slot by one padding move: its own strategy answers a point it already
holds, which costs one unit of depth and buys one unit of arity. -/
private theorem comp_extend_junk {M N : OrderedMonadicStructure sig} {d n : Nat}
    (wA : Fin n → M.carrier) (wB : Fin n → N.carrier) (p : Fin n)
    (hbf : BackForth sig (d + 1) n M N wA wB) :
    ∃ (wA' : Fin (n + 1) → M.carrier) (wB' : Fin (n + 1) → N.carrier),
      (∀ ak : AtomKind sig (n + 1), AtomEval M wA' ak ↔ AtomEval N wB' ak) ∧
      BackForth sig d (n + 1) M N wA' wB' ∧
      (∀ q : Fin n, wA' q.succ = wA q ∧ wB' q.succ = wB q) := by
  obtain ⟨_, hbwd⟩ := hbf
  obtain ⟨b, hat, hbf'⟩ := hbwd (wA p)
  exact ⟨Fin.cons (wA p) wA, Fin.cons b wB, hat, hbf', fun q => ⟨by simp, by simp⟩⟩

/--
**One move of the mixed game.** Spoiler plays `y` in the second sum; Duplicator answers with an
`x` in the first sum restoring the invariant one depth down.

Two cases. If `y`'s index is already matched, the answer comes from that slot's own strategy and
the slot family is unchanged. If it is new, the coloured index game supplies a matching index
`i₀`; matched indices carry the same `k`-type, so their summands are `≡ₖ` and `backForth_pad`
inflates that to the arity the position count demands — this is the only place the budget
`d + n ≤ k` is spent.
-/
theorem mixed_step {k : Nat} {I J : Type} [LinearOrder I] [LinearOrder J]
    {m : I → OrderedMonadicStructure sig} {m' : J → OrderedMonadicStructure sig}
    {d n : Nat}
    {eA : Fin n → (orderedSum sig I m).carrier}
    {eB : Fin n → (orderedSum sig J m').carrier}
    (h : Mixed sig k m m' (d + 1) n eA eB) (y : (orderedSum sig J m').carrier) :
    ∃ x : (orderedSum sig I m).carrier,
      Mixed sig k m m' d (n + 1) (Fin.cons x eA) (Fin.cons y eB) := by
  classical
  obtain ⟨hbud, hsum, s, uA, uB, slotOf, hinjA, hinjB, hidx, hstrat, hsurj, hcomp⟩ := h
  -- Every position lives in the summands of its slot.
  have hidxA : ∀ q : Fin n, (eA q).1 = uA (slotOf q) := by
    intro q
    obtain ⟨_, _, _, _, hlink⟩ := hcomp (slotOf q)
    rw [(hlink q rfl).1]; rfl
  have hidxB : ∀ q : Fin n, (eB q).1 = uB (slotOf q) := by
    intro q
    obtain ⟨_, _, _, _, hlink⟩ := hcomp (slotOf q)
    rw [(hlink q rfl).2]; rfl
  obtain ⟨j₀, b⟩ := y
  by_cases hcase : ∃ t : Fin s, uB t = j₀
  · -- **Case 1**: the index `j₀` is already matched, at slot `t₀`.
    obtain ⟨t₀, ht₀⟩ := hcase
    subst ht₀
    obtain ⟨wA₀, wB₀, _, hbf₀, hlink₀⟩ := hcomp t₀
    obtain ⟨hfwd, _⟩ := hbf₀
    obtain ⟨a, hpair, hbfa⟩ := hfwd b
    have hslotA : ∀ q : Fin n, (eA q).1 = uA t₀ → slotOf q = t₀ :=
      fun q hq => hinjA ((hidxA q).symm.trans hq)
    have hslotB : ∀ q : Fin n, (eB q).1 = uB t₀ → slotOf q = t₀ :=
      fun q hq => hinjB ((hidxB q).symm.trans hq)
    have hidxEq : ∀ q : Fin n, (eA q).1 = uA t₀ ↔ (eB q).1 = uB t₀ := by
      intro q
      constructor
      · intro hq; rw [hidxB q, hslotA q hq]
      · intro hq; rw [hidxA q, hslotB q hq]
    refine ⟨orderedSumPt (ms := m) (uA t₀) a, by omega, ?_, s, uA, uB,
      Fin.cons t₀ slotOf, hinjA, hinjB, hidx,
      backForth_succ (colourSig (KType sig k)) d s
        (kTypeColouring sig k m) (kTypeColouring sig k m') uA uB hstrat, ?_, ?_⟩
    · -- Atom agreement for the extended sum environments.
      refine orderedSum_atoms_cons a b wA₀ wB₀ (fun q hq => (hlink₀ q (hslotA q hq)).1)
        (fun q hq => (hlink₀ q (hslotB q hq)).2) hidxEq (fun q => ?_) (fun q => ?_) hpair hsum
      · rw [hidxA q, hidxB q]; exact colour_lt_agree hidx t₀ (slotOf q)
      · rw [hidxA q, hidxB q]; exact colour_lt_agree hidx (slotOf q) t₀
    · -- Every slot still has a live position.
      intro t
      obtain ⟨p, hp⟩ := hsurj t
      exact ⟨p.succ, by simpa using hp⟩
    · -- Per-slot data one move on.
      intro t
      by_cases ht : t = t₀
      · subst ht
        refine ⟨Fin.cons a wA₀, Fin.cons b wB₀, hpair, hbfa, ?_⟩
        intro p hp
        cases p using Fin.cases with
        | zero => exact ⟨rfl, rfl⟩
        | succ q => exact hlink₀ q hp
      · obtain ⟨wA, wB, _, hbf, hlink⟩ := hcomp t
        obtain ⟨p₀, _⟩ := hsurj t
        obtain ⟨wA', wB', hat', hbf', hsucc⟩ := comp_extend_junk wA wB p₀ hbf
        refine ⟨wA', wB', hat', hbf', ?_⟩
        intro p hp
        cases p using Fin.cases with
        | zero => exact absurd hp.symm ht
        | succ q =>
          rw [(hsucc q).1, (hsucc q).2]
          exact hlink q hp
  · -- **Case 2**: the index `j₀` is new, so the coloured index game must answer it.
    push_neg at hcase
    -- The coloured index game's forward clause, restated with its witness typed in `I` rather
    -- than in the (definitionally equal) carrier of the coloured structure. Without this the
    -- `Fin.cons` terms below are type-correct only at default transparency, and `simp` and `rw`
    -- both refuse to enter them.
    have hfwdI : ∀ z : J, ∃ w : I,
        (∀ ak : AtomKind (colourSig (KType sig k)) (s + 1),
          AtomEval (kTypeColouring sig k m) (Fin.cons w uA) ak ↔
          AtomEval (kTypeColouring sig k m') (Fin.cons z uB) ak) ∧
        BackForth (colourSig (KType sig k)) d (s + 1)
          (kTypeColouring sig k m) (kTypeColouring sig k m')
          (Fin.cons w uA) (Fin.cons z uB) := hstrat.1
    obtain ⟨i₀, hidxat, hidxbf⟩ := hfwdI j₀
    have hltF : ∀ t : Fin s, (i₀ < uA t ↔ j₀ < uB t) := fun t =>
      hidxat (.order 0 t.succ (Ne.symm (Fin.succ_ne_zero t)))
    have hltB : ∀ t : Fin s, (uA t < i₀ ↔ uB t < j₀) := fun t =>
      hidxat (.order t.succ 0 (Fin.succ_ne_zero t))
    -- A new index on one side is answered by a new index on the other.
    have hnewA : ∀ t : Fin s, uA t ≠ i₀ := by
      intro t hEq
      refine hcase t ?_
      rcases lt_trichotomy (uB t) j₀ with hc | hc | hc
      · exact absurd ((hltB t).mpr hc) (by rw [hEq]; exact lt_irrefl i₀)
      · exact hc
      · exact absurd ((hltF t).mpr hc) (by rw [hEq]; exact lt_irrefl i₀)
    -- Matched indices carry the same `k`-type, so their summands are `≡ₖ`.
    have hKE : KEquiv sig k (m i₀) (m' j₀) := by
      have hcol : kTypeOf sig k (m' j₀) = kTypeOf sig k (m i₀) :=
        (hidxat (.pred (kTypeOf sig k (m i₀)) 0)).mp rfl
      exact hcol.symm
    -- Inflate that to the arity the position count demands: this spends the budget.
    obtain ⟨wA, wB, hbfp⟩ := backForth_pad sig (m i₀) (m' j₀) b n (d + 1)
      (backForth_mono (by omega) (backForth_of_kEquiv k (m i₀) (m' j₀) hKE))
    obtain ⟨hf, _⟩ := hbfp
    obtain ⟨a, hpair, hbfa⟩ := hf b
    have hnewA' : ∀ q : Fin n, ¬ ((eA q).1 = i₀) := fun q hq =>
      hnewA (slotOf q) ((hidxA q).symm.trans hq)
    have hnewB' : ∀ q : Fin n, ¬ ((eB q).1 = j₀) := fun q hq =>
      hcase (slotOf q) ((hidxB q).symm.trans hq)
    refine ⟨orderedSumPt (ms := m) i₀ a, by omega, ?_, s + 1, Fin.cons i₀ uA, Fin.cons j₀ uB,
      Fin.cons 0 (fun q => (slotOf q).succ), ?_, ?_, hidxat, hidxbf, ?_, ?_⟩
    · -- Atom agreement for the extended sum environments.
      refine orderedSum_atoms_cons a b wA wB (fun q hq => absurd hq (hnewA' q))
        (fun q hq => absurd hq (hnewB' q))
        (fun q => iff_of_false (hnewA' q) (hnewB' q)) (fun q => ?_) (fun q => ?_) hpair hsum
      · rw [hidxA q, hidxB q]; exact hltF (slotOf q)
      · rw [hidxA q, hidxB q]; exact hltB (slotOf q)
    · -- The extended index tuple is still injective on the `I` side.
      intro p q hpq
      cases p using Fin.cases with
      | zero =>
        cases q using Fin.cases with
        | zero => rfl
        | succ t =>
          simp only [Fin.cons_zero, Fin.cons_succ] at hpq
          exact absurd hpq.symm (hnewA t)
      | succ t =>
        cases q using Fin.cases with
        | zero =>
          simp only [Fin.cons_zero, Fin.cons_succ] at hpq
          exact absurd hpq (hnewA t)
        | succ t' =>
          simp only [Fin.cons_succ] at hpq
          exact congrArg Fin.succ (hinjA hpq)
    · -- ... and on the `J` side.
      intro p q hpq
      cases p using Fin.cases with
      | zero =>
        cases q using Fin.cases with
        | zero => rfl
        | succ t =>
          simp only [Fin.cons_zero, Fin.cons_succ] at hpq
          exact absurd hpq.symm (hcase t)
      | succ t =>
        cases q using Fin.cases with
        | zero =>
          simp only [Fin.cons_zero, Fin.cons_succ] at hpq
          exact absurd hpq (hcase t)
        | succ t' =>
          simp only [Fin.cons_succ] at hpq
          exact congrArg Fin.succ (hinjB hpq)
    · -- Every slot, old and new, has a live position.
      intro t
      cases t using Fin.cases with
      | zero => exact ⟨0, by simp⟩
      | succ t' =>
        obtain ⟨p, hp⟩ := hsurj t'
        exact ⟨p.succ, by simpa using congrArg Fin.succ hp⟩
    · -- Per-slot data one move on.
      intro t
      cases t using Fin.cases with
      | zero =>
        refine ⟨Fin.cons a wA, Fin.cons b wB, hpair, hbfa, ?_⟩
        intro p hp
        cases p using Fin.cases with
        | zero => exact ⟨rfl, rfl⟩
        | succ q => exact absurd hp (Fin.succ_ne_zero (slotOf q))
      | succ t' =>
        obtain ⟨wAt, wBt, _, hbft, hlinkt⟩ := hcomp t'
        obtain ⟨p₀, _⟩ := hsurj t'
        obtain ⟨wA', wB', hat', hbf', hsucc⟩ := comp_extend_junk wAt wBt p₀ hbft
        refine ⟨wA', wB', hat', hbf', ?_⟩
        intro p hp
        cases p using Fin.cases with
        | zero => exact absurd hp.symm (Fin.succ_ne_zero t')
        | succ q =>
          have hq : (slotOf q).succ = t'.succ := hp
          rw [(hsucc q).1, (hsucc q).2]
          exact hlinkt q (Fin.succ_injective _ hq)

/-! ## The mixing lemma -/

/--
**The invariant yields a strategy on the sums.**

The induction is on the remaining depth, with both index orders generalized so that the
*backward* clause can be obtained from the forward one by `Mixed.symm` and `backForth_symm`.
-/
theorem backForth_of_mixed (sig : MonadicSignature) (k : Nat) :
    ∀ (d : Nat) {I J : Type} [LinearOrder I] [LinearOrder J]
      (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
      (n : Nat) (eA : Fin n → (orderedSum sig I m).carrier)
      (eB : Fin n → (orderedSum sig J m').carrier),
      Mixed sig k m m' d n eA eB →
      BackForth sig d n (orderedSum sig I m) (orderedSum sig J m') eA eB := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _ _ _ _ _ _; trivial
  | succ d ih =>
    intro I J _ _ m m' n eA eB h
    refine ⟨fun y => ?_, fun x => ?_⟩
    · obtain ⟨x, hx⟩ := mixed_step h y
      exact ⟨x, hx.2.1, ih m m' (n + 1) _ _ hx⟩
    · obtain ⟨y, hy⟩ := mixed_step (Mixed.symm h) x
      exact ⟨y, fun ak => (hy.2.1 ak).symm,
        backForth_symm sig d (n + 1) (orderedSum sig J m') (orderedSum sig I m) _ _
          (ih m' m (n + 1) _ _ hy)⟩

/--
**Doets 1987, 3.1.8 — the mixing lemma.**

> if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
> `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`

The empty position satisfies `Mixed` with no slots at all: there is nothing to link, the budget
is `k + 0 ≤ k`, and the hypothesis *is* the depth-`k` strategy on the coloured index orders.
-/
theorem kEquiv_orderedSum_of_kEquiv_colour (k : Nat) {I J : Type}
    [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (hcol : KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k m) (kTypeColouring sig k m')) :
    KEquiv sig k (orderedSum sig I m) (orderedSum sig J m') := by
  refine kEquiv_of_backForth k _ _
    (backForth_of_mixed sig k k m m' 0 Fin.elim0 Fin.elim0 ?_)
  exact ⟨by omega, fun ak => (atomKind_zero_isEmpty ak).elim,
    0, Fin.elim0, Fin.elim0, Fin.elim0,
    fun p _ _ => p.elim0, fun p _ _ => p.elim0,
    fun ak => (atomKind_zero_isEmpty ak).elim,
    backForth_of_kEquiv k (kTypeColouring sig k m) (kTypeColouring sig k m') hcol,
    fun t => t.elim0, fun t => t.elim0⟩

end FormalSystem.Metalogic.WeakCanonical
