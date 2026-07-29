# Phase 26 — Reynolds §8 Lemma 13 and the `ℚ`-shuffle

**Status**: implemented (sorry-free, axiom-clean, full `lake build` green)
**Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/Shuffle.lean` (new, 497 lines)

## Phases executed

Phase 26 only (single-phase dispatch). Three commits at green sub-steps:

- `91565d273` — 26.1: Lemma 13
- `f91c8a80d` — 26.2: the shuffle, index reindexing of lexicographic sums
- `e7494c0f5` — 26.3: block decomposition and the assembled shuffle equivalence

## Theorems landed

### Lemma 13 (printed p.187)

| Name | Content |
|------|---------|
| `endsInGapOnRight_epsDense_iff` | `EndsInGapOnRight M (epsDense sig k)` read in `SimDense` |
| `endsInGapOnLeft_epsDense_iff` | the left mirror |
| `veryGoodDense_openSub_of_forall_simDense` | an interval inside one `∼`-class is very good |
| `reynolds_lemma13_right` | class bounded above ⇒ class has a last point |
| `reynolds_lemma13_left` | class bounded below ⇒ class has a first point |
| `reynolds_lemma13` | both halves, from gap-freeness at every point |

### The shuffle (printed p.186)

| Name | Content |
|------|---------|
| `IsShuffleMap` | Reynolds' density condition on `π : ℚ → S` |
| `shuffle` | `Σ_{t∈ℚ} π(t)` |
| `kEquiv_shuffle_congr` | congruence in the summands |
| `kEquiv_shuffle_congr_orderIso` | invariance under colour-preserving reindexing of `ℚ` |

### `M | (⋃I) ≡ₖ Σ_{q∈ℚ} σ(q)` (printed p.187)

| Name | Content |
|------|---------|
| `orderedSumReindexEquiv`, `kEquiv_orderedSum_reindex` | relabel a lex sum along `I ≃o J` |
| `kEquiv_orderedSum_of_orderIso` | sums over order-isomorphic index sets |
| `OrderedMonadicStructure.restrictSet` | substructure on an arbitrary subset |
| `kEquiv_orderedSum_blocks` | `P ≡ₖ Σ_{i∈I} P|blockᵢ` (the left-hand identity) |
| `kEquiv_shuffle_of_classIso` | `Σ_{E∈I} M|E ≡ₖ Σ_{q∈ℚ} σ(q)` |
| `kEquiv_blocks_shuffle` | the two composed — the phase's deliverable |
| `blocks_lt_of_monotone_cls` | monotone labelling ⇒ order-respecting blocks |
| `kEquiv_singletonBlocks` | anti-vacuity instance: the singleton partition |

## Verification

- `sorry_count` (this file): 0. Tree baseline outside `Boneyard/` unchanged
  (`Transfer.lean:1242` only); `lake build` reports `compiler_sorry_count: 0`.
- `vacuous_count`: 0 new (the one repo hit, `Examples/TemporalStructures.lean:277`, is
  pre-existing and is a genuine `trivial` goal).
- `axiom_count`: unchanged (the two `^axiom ` hits are prose lines in `Boneyard/`).
- `#print axioms`: every declaration in the module is `[propext, Classical.choice, Quot.sound]`,
  except `blocks_lt_of_monotone_cls` which is `[propext]`.
- `build_passed`: true (`lake build`, 2202 jobs).

## Plan deviations

Two checkboxes were landed in altered form; both are annotated inline in the plan and both are
recorded in the module's "Honesty charter notes".

1. **Lemma 13 carries `[Countable]` and `[DenselyOrdered]`**, which Reynolds' *"for any structure
   `M`"* does not. His one-line proof rests on *"clearly `M | E` is very good"*, and
   `veryGoodDense` — following his own §8 definition — demands every open subinterval be
   non-empty; at an immediate-successor pair inside a class that fails. Getting from very good to
   good is Lemma 11, stated for countable structures. Both hypotheses are standing hypotheses of
   Doets' theorem (printed p.185), so no downstream consumer is weakened.

2. **"Well defined up to isomorphism" is landed only in its reindexing form.** The full claim is
   the colour-preserving Cantor back-and-forth for finitely many colours dense in `ℚ`; Mathlib
   carries only the uncoloured `Order.iso_of_countable_dense`. No result in this tree consumes
   it — the main proof produces exactly one shuffle, from the classes themselves, via
   `kEquiv_blocks_shuffle`. Deferred as a named follow-up (see the handoff), not sorried.

## Note for Phase 29

`kEquiv_blocks_shuffle` takes the class labelling `cls : P.carrier → I` and its monotonicity as
inputs. Constructing that labelling from `SimDense` (the `∼`-quotient with its induced linear
order) is not done here; `blocks_lt_of_monotone_cls` reduces the obligation to monotonicity of
the labelling, which `simDense_convex` supplies. This is the assembly step Phase 29 owns.
