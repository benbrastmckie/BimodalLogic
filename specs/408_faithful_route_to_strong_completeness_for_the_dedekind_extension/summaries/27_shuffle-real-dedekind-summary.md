# Phase 27 — The `ℝ`-extension of the shuffle, its Dedekind completeness and its countable dense subflow

**Status**: PARTIAL. Everything the phase chartered landed except the *proof* of
`doets_lemma_1_5`, which is a tracked strategic sorry with a named follow-up.

**Source**: Reynolds 1992, §8 *"Doets' Theorem"*, printed **p.188**; the mixing argument is
`ADAPTED-FROM: Doets 1987, 3.1.8`.

**Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` (new, ~565 lines).

## What landed

### `σ*` and the `ℝ`-shuffle (sorry-free, axiom-clean)

| Declaration | Content |
|---|---|
| `shuffleColourReal γ₁ σ` | Reynolds' `σ*`: `σ` at the rationals, the distinguished colour `γ₁` elsewhere |
| `shuffleColourReal_rat`, `shuffleColourReal_irrational` | its two computation rules |
| `IsShuffleMapReal` | his density condition read with index order `ℝ` |
| `isShuffleMapReal_shuffleColourReal` | `σ*` is again a shuffle colouring — the one place density of `ℚ` in `ℝ` enters |
| `shuffleReal N γ₁ σ` | `Σ_{r∈ℝ} σ*(r)` |

### The flow `R` (sorry-free, axiom-clean)

Proved for a general `ℝ`-indexed family, then instantiated at the shuffle. These are exactly
Phase 28's inputs, and Phase 28 is fully unblocked by them.

| General form | Shuffle instance | Printed claim |
|---|---|---|
| `denselyOrdered_orderedSumReal` | `denselyOrdered_shuffleReal` | *"`R` is dense"* |
| `noMax_orderedSumReal` | `noMax_shuffleReal` | *"without end points"* |
| `noMin_orderedSumReal` | `noMin_shuffleReal` | *"without end points"* |
| `exists_isLUB_orderedSumReal` | `exists_isLUB_shuffleReal` | *"`R` is also Dedekind complete"* |
| `exists_countableDense_orderedSumReal` | `exists_countableDense_shuffleReal` | *"`R` has a countable dense subflow"* |

Non-vacuity: `pointStructure` / `pointFam` / `pointFam_hyps` / `pointFam_orderedSum_facts`
exhibit one family satisfying every hypothesis of all five lemmas at once — and it is the
degenerate case `σ*` actually produces at the irrationals, not an artificial witness.

### `doets_lemma_1_5` (statement live, proof deferred)

`colourSig`, `colourStructure` and `kTypeColouring` render the source's `Z`-coloured index
order `(I, {i | m(i) ⊨ σ})_{σ∈Z}` as a structure in its own right, with `Z := KType sig k`.
`doets_lemma_1_5` then carries Doets 3.1.8 verbatim, under the live names `kTypeOf`/`KEquiv`,
with no `Boneyard` import. `kEquiv_shuffle_shuffleReal` is the `ℚ`-to-`ℝ` mixing application.

## Deviations and honesty notes

1. **The archived draft's hypothesis was not copied, deliberately.** The plan directed that the
   drafted `doets_lemma_1_5` at `SingletonSorriedDecls.lean:58` be re-stated under live names.
   Its hypothesis — that the two index sets realize the same *set* of `k`-types — does not imply
   its conclusion: two summands of types `τ₁, τ₂` in either order realize the same set but need
   not give `≡ₖ` sums. Reproducing it would have landed a false statement. The live re-statement
   carries Doets 3.1.8's actual hypothesis instead, on the *coloured index orders*. Both
   `OrderedSum.lean`'s status block and the archive note now record this.

2. **`doets_lemma_1_5`'s proof is a strategic sorry** (`ShuffleReal.lean:201`), with the
   follow-up named in its docstring. The tree's engine for the shared-index case
   (`sum_nf_agree`, behind `doets_lemma_1_4`) matches a witness at index `i` in one sum with a
   witness at the *same* `i` in the other; Doets 3.1.8 needs the witness matched at a different
   index supplied by a coloured back-and-forth between two index orders. Re-association was
   checked as an escape route and does not work: `Σ_{r∈ℝ} σ*(r)` is not a re-bracketing of
   `Σ_{q∈ℚ} σ(q)`, because a convex partition of `ℝ` into countably many blocks cannot have
   quotient order `ℚ` (`ℝ` is Dedekind complete, `ℚ` is not), so Phase 26's
   `kEquiv_orderedSum_of_orderIso` does not apply.

3. **The coloured-order `≡ₖ` fact is an explicit hypothesis, not a second sorry.**
   `kEquiv_shuffle_shuffleReal` takes `hcol` — that `(ℚ, σ)` and `(ℝ, σ*)` are `≡ₖ` as coloured
   orders — as a hypothesis. It is true (both are dense endpointless orders coloured by the same
   finite palette with every colour dense) but is not formalized here. Carrying it visibly keeps
   what remains open readable from the statement rather than buried in a proof body.

4. **The Dedekind-completeness transcription adds a case Reynolds' sentence passes over.**
   *"Any subset bounded above intersects a last summand"* is not always so: the supremum `ρ` of
   the indices met by the subset need not itself be met. That case is handled with the least
   element of the summand at `ρ` — which is *"the summands themselves are closed intervals of the
   reals"* used on the left rather than the right.

5. **An `LE`-instance hazard was hit and is documented in-module.** An anonymous `⟨r, a⟩` at type
   `(orderedSum sig ℝ fam).carrier` forces the type to weak head normal form, and typeclass
   search then selects Mathlib's *non-lexicographic* `Sigma.instLE` over the structure's
   `carrierOrder` — silently stating the lemma about the wrong order. The four transfer lemmas go
   through `orderedSumPt` instead. This is the same hazard `orderedSum`'s docstring warns about
   for `LinearOrder`, met for `LE`.

## Verification

- Scoped build green; full `lake build` green.
- `#print axioms` on all 13 sorry-free declarations: `propext`, `Classical.choice`, `Quot.sound`
  only.
- Vacuous-definition scan of `RealModel/`: 0.
- `axiom` declarations repo-wide: 2, unchanged from baseline.
- Sorry census outside `Boneyard/`: `Transfer.lean:1242` (pre-existing) plus
  `ShuffleReal.lean:201` (this dispatch, tracked strategic). The plan's "still exactly
  `Transfer.lean:1242`" gate is therefore **not** met, and the phase is marked `[PARTIAL]`
  rather than `[COMPLETED]`.

## Downstream impact

- **Phase 28**: unaffected and unblocked — it consumes only the four order facts, all sorry-free
  and axiom-clean.
- **Phase 29**: its use of `kEquiv_shuffle_shuffleReal` is conditional until both halves of the
  follow-up land.
