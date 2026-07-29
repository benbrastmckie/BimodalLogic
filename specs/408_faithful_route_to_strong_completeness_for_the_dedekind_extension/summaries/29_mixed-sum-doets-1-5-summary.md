# Phase 27 (final item): `doets_lemma_1_5` discharged

## What this dispatch did

Phase 27's last open item — the mixing lemma, Doets 1987 3.1.8 — is proved. Phase 27 is now
`[COMPLETED]`.

New module: `FormalSystem/Metalogic/WeakCanonical/MixedSum.lean` (~560 lines, sorry-free,
axiom-clean). `ShuffleReal.lean`'s `doets_lemma_1_5` is now a one-line consequence of it, and
`kEquiv_shuffle_shuffleReal` is unconditional.

## The proof

The prior dispatch's diagnosis was correct: the *engine* (`BackAndForth.lean`'s `BackForth` and
`kEquiv_iff_backForth`) was already in the tree, and what remained was the bookkeeping that
assembles a strategy on the coloured index orders with the per-summand strategies into a single
strategy on the sums — the two-index analogue of `NEquivalence.lean`'s `CompData` / `build_bicompat`.

`Mixed` is that invariant. A game position after `n` moves carries:

* a **slot family** `uA : Fin s → I`, `uB : Fin s → J` — the matched pairs of *indices*, injective
  on each side, with a depth-`d` strategy and atom agreement on the coloured index orders;
* for each slot `t`, a depth-`d` strategy inside the matched pair of summands `m (uA t)`,
  `m' (uB t)` on environments of arity `n`;
* `slotOf : Fin n → Fin s`, surjective, and the **link**: a position `p` in slot `t` satisfies
  `eA p = ⟨uA t, wA p⟩` and `eB p = ⟨uB t, wB p⟩`;
* the budget `d + n ≤ k`, and the sum-level atom agreement reached so far.

Two design choices are what made this tractable, and they are the substance of the difference
from `build_bicompat`:

1. **The link is a `Sigma` equality in the sum carrier**, never a transport of a summand element
   along an index equality. `CompData.consistent` states `h ▸ (env_M p).2 = eM j q`; here the same
   content is `eA p = orderedSumPt (uA t) (wA p)`, which needs no `▸` and no `cast_lt_iff`.
2. **Every slot's environment has the same arity as the position count.** A move therefore extends
   *every* slot by exactly one entry — the touched slot by the real witness, the others by a junk
   move answered by that slot's own strategy (`comp_extend_junk`; the junk point is one the slot
   already holds, so no nonemptiness hypothesis is needed). This removes `CompData`'s
   `sz : I → Nat` and its `if t' = t then sz t + 1 else sz t'` update, and with it every one of
   `build_bicompat`'s `convert … using 2` `HEq` blocks over `NormalForm` types.

`mixed_step` is the move. Spoiler plays `y = ⟨j₀, b⟩` in the second sum; two cases:

* **`j₀` already matched** at slot `t₀`: that slot's own strategy answers `b` with an `a` in
  `m (uA t₀)`, and the slot family is unchanged (its strategy drops a depth by `backForth_succ`).
* **`j₀` new**: the coloured index game answers with `i₀`, which the order atoms show is new on the
  `I` side too. The colour atom at `i₀` says `kTypeOf sig k (m i₀) = kTypeOf sig k (m' j₀)`, i.e.
  the summands are `≡ₖ`; `backForth_pad` plays that out into arity `n` retaining depth `d + 1`,
  and one more move gives the real witness at depth `d`. This is the only place the budget is
  spent, and it balances exactly: `(d + 1) + n ≤ k` is precisely what `n + (d + 1) ≤ k` needs.

`backForth_of_mixed` runs the induction on depth, generalizing both index orders so the backward
clause is the forward clause of the swapped position (`Mixed.symm`, `backForth_symm`) — the move
analysis is written once, not four times.

## Supporting lemmas added

* `backForth_symm`, `backForth_pad` — symmetry and padding for `BackForth`.
* `sum_lt_iff`, `sumPt_lt_sumPt`, `sumPt_lt_of_ne`, `lt_sumPt_of_ne` — every lexicographic
  comparison the argument performs, isolated so no later proof unfolds `Sigma.Lex`.
* `orderedSum_atoms_cons` — the winning condition one move on, from the index-level comparisons
  plus the pair game's atom agreement.
* `colour_lt_agree`, `colour_eq_agree` — reading order and colour off a matched index tuple.

## Formalization note worth keeping

The coloured index game's witness is bound at type `(kTypeColouring sig k m).carrier`, not at `I`.
The two are definitionally equal, but a `Fin.cons` built over the former is type-correct only at
*default* transparency, so `simp` and `rw` both refuse to enter it — `Fin.cons_zero` silently makes
no progress, and `rw` reports the target "not type-correct under the `implicit` transparency
level". The fix is to restate the game's forward clause once with its witness typed in `I`
(`hfwdI` in `mixed_step`) and obtain the witness from that. Relatedly, most `Fin.cons` reductions
here hold by `rfl` at default transparency; where `simp` failed, `exact`/`rfl` succeeded.

## Verification

* `lake build` — passes.
* Sorry census outside `Boneyard/` directories: exactly `Transfer.lean:1242` (pre-existing).
  `ShuffleReal.lean`'s strategic sorry is gone; no new sorries.
* Vacuous definitions: 1, pre-existing and unrelated (`Examples/TemporalStructures.lean:279`).
* `axiom` declarations: 2, unchanged from baseline.
* `#print axioms`: `kEquiv_orderedSum_of_kEquiv_colour`, `backForth_of_mixed`, `mixed_step`,
  `doets_lemma_1_5`, `kEquiv_shuffle_shuffleReal` all depend on exactly
  `propext, Classical.choice, Quot.sound` — no `sorryAx`. `backForth_pad` needs only
  `propext, Quot.sound`; `backForth_symm` only `propext`.

## Downstream

Phase 29 consumes `kEquiv_shuffle_shuffleReal`, which is now unconditional. Phase 28 was never
affected. Nothing in the tree is conditional on an unproved mixing lemma any longer.
