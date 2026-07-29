# Phase 27 continuation — the EF bridge and the coloured-order `≡ₖ` fact

- **Task**: 408, `faithful_route_to_strong_completeness_for_the_dedekind_extension`
- **Phase**: 27 (continuation dispatch), `[PARTIAL]` — one of the two open halves closed
- **Plan**: `plans/10_strong-completeness-dedekind-v10.md`

## What the dispatch was for

The prior dispatch left Phase 27 with two independent open halves, recorded in its handoff:

1. **`doets_lemma_1_5`** (Doets 1987, 3.1.8 — the mixing lemma) stated but unproved.
2. **`kEquiv_shuffle_shuffleReal`'s `hcol` hypothesis**: that the coloured index orders `(ℚ, σ)`
   and `(ℝ, σ*)` are `≡ₖ` as structures over `colourSig`, carried as an explicit hypothesis
   rather than a second `sorry` so that what remained open was readable from the statement.

Half 2 is now **discharged**. Half 1 remains open, but its route is materially sharper and its
engine is landed.

## What landed

### `FormalSystem/Metalogic/WeakCanonical/BackAndForth.lean` (new, sorry-free, axiom-clean)

The Ehrenfeucht-Fraïssé characterization of `k`-equivalence, for an **arbitrary pair** of
structures:

- `BackForth` — the depth-indexed back-and-forth relation on environments.
- `nfAgree_of_backForth` — a depth-`d` strategy gives depth-`d` normal-form agreement.
- `backForth_of_nfAgree` — and conversely, via `extend_fwd` / `extend_bwd`.
- `kEquiv_iff_backForth` — the sentence-level characterization.
- `backForth_mono`.

Both halves of this argument already existed in `NEquivalence.lean`, but only *inside* the
ordered-sum proof and only for a **shared** index set. Two observations made the generalization
mechanical rather than speculative:

- `sum_nf_lift_gen` (`NEquivalence.lean:831`) threads its `_h_comp` argument through the
  induction and **never consumes it**; the index structure is likewise unused. The content is
  the generic EF lemma wearing an ordered-sum costume, and `BiCompat` (`:194`) is a
  back-and-forth relation specialized to one index type.
- `component_extend_fwd` / `component_extend_bwd` (`:221`, `:242`) are the converse direction,
  stated for a summand pair `ms j`, `ms' j` but proved using nothing about summands — only
  `nf_characteristic_satisfies`, `nf_eval_unique` and `nf_agreement_from_shared_nf`.

This matters because a *two-index* argument matches a witness at a **different** index on the
other side, so it cannot be phrased through the single index type `BiCompat` assumes.

### `FormalSystem/Metalogic/WeakCanonical/ColourOrders.lean` (new, sorry-free, axiom-clean)

Now owns `colourSig`, `colourStructure` and `kTypeColouring` (moved out of `ShuffleReal.lean`),
and adds:

- `IsShuffleColouring S c` — Reynolds' density condition (`IsShuffleMap`) stated for an
  arbitrary index order, plus the endpoint and nonemptiness clauses, with
  `exists_colour_lt` / `exists_colour_gt` / `exists_colour` and a recolouring lemma
  `IsShuffleColouring.map`.
- `colour_atom_agree` — two environments agree on all atoms of `colourSig` exactly when they are
  order- and colour-preserving. This is the invariant the game maintains.
- `exists_matching_point` — the combinatorial heart. Four cases: the new point is already
  matched; it lies in a gap of the finite matched configuration (density of its colour in that
  gap); it lies above or below everything (no endpoints, then density); the configuration is
  empty.
- `backForth_colourStructure`, `kEquiv_colourStructure` — **any two shuffle colourings over a
  common palette give `≡ₖ` coloured index orders, at every depth.**

Nothing in the argument is specific to `ℚ` or `ℝ`: only the density of each palette colour in
every interval and the absence of endpoints are used. There is no cardinality obstruction, which
is why it applies verbatim to the pair Reynolds needs.

### `RealModel/ShuffleReal.lean` (edited)

- Imports `ColourOrders.lean`; the three colour definitions moved there.
- Adds `isShuffleColouring_of_isShuffleMap` and `isShuffleColouring_of_isShuffleMapReal`, the
  bridge from the concrete `ℚ`- and `ℝ`-forms of the density condition to the generic one.
- **`kEquiv_shuffle_shuffleReal` no longer carries `hcol`.** It takes `hγ : γ₁ ∈ S` and
  `hσ : IsShuffleMap S σ` — the shuffle data the hypothesis was always a consequence of — and
  proves the coloured-order fact by recolouring both colourings along `kTypeOf`-of-summand onto
  a common palette and applying `kEquiv_colourStructure`. It is now conditional on
  `doets_lemma_1_5` **alone**.
- `doets_lemma_1_5`'s docstring rewritten to record that the engine is landed and to name
  precisely what remains.

## What remains, and why

`doets_lemma_1_5` is still a tracked strategic `sorry`. The engine is no longer the obstacle:
`kEquiv_iff_backForth` converts the hypothesis into a depth-`k` strategy on the coloured index
orders, converts `kTypeOf`-equality of matched summands into a depth-`k` strategy inside each
matched pair, and reduces the conclusion to exhibiting a strategy on the sums.

What remains is the bookkeeping that assembles those strategies into one. The invariant carried
down the induction must record, for each already-matched pair of indices `(i, j)`, the sub-tuple
of environment positions lying in that pair of summands together with a strategy relating them —
the two-index analogue of `CompData` (`NEquivalence.lean:333`) and `build_bicompat` (`:512`).
Phrasing it through `BackForth` rather than through normal-form agreement avoids `CompData`'s
dependent `NormalForm`-type casts (the `convert … using 2` `HEq` blocks, which are the bulk of
`build_bicompat`'s difficulty), so this is a genuine simplification of the remaining work — but
it is still phase-sized formalization, not a gap in an otherwise complete proof.

**Re-association was checked in the prior dispatch and does not help**, and was not re-attempted:
`Σ_{r∈ℝ} σ*(r)` is not a re-bracketing of `Σ_{q∈ℚ} σ(q)`, because a convex partition of `ℝ` into
countably many blocks cannot have quotient order `ℚ`.

## Verification

| Check | Result |
|---|---|
| `lake build` (full project) | passes, 1983 jobs |
| Sorry census outside `Boneyard/` | **2** — `Transfer.lean:1242` (pre-existing), `ShuffleReal.lean:226` (tracked strategic). Unchanged from baseline: zero new sorries. |
| Vacuous definitions | 1, pre-existing and unrelated (`Examples/TemporalStructures.lean:279`, a genuine `trivial` for an always-true domain, not a placeholder) |
| `axiom` declarations | 2, unchanged from baseline |
| `#print axioms` on all 12 new/affected declarations | `propext`, `Classical.choice`, `Quot.sound` only — except `kEquiv_shuffle_shuffleReal`, which carries `sorryAx` exactly via `doets_lemma_1_5` |

## Commits

- `4b32a75df` phase 27.4 — EF back-and-forth characterization of `k`-equivalence
- `7b5f557b0` phase 27.5 — coloured index orders and the shuffle back-and-forth
- `d4120f61b` phase 27.6 — discharge `kEquiv_shuffle_shuffleReal`'s coloured-order hypothesis

## Deviations

None from the dispatch charter. The charter set half 1 (`doets_lemma_1_5`) as the priority and
half 2 as the fallback, and directed that whichever did not fit the budget be landed as a
documented remaining item. Half 1 was assessed first: it requires rewriting the
`CompData` / `build_bicompat` bookkeeping for two index sets, which is not one dispatch. Half 2
was closeable and was closed. The bridge built along the way is the asset half 1 needs, so the
ordering cost nothing.
