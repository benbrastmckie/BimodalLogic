# Phase 10 — `HasDedekindINF` / `HasDedekindSUP` from the dense Prior axioms

**Status**: COMPLETED. **The route's single point of failure held.**

**Owns**: `FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINFDense.lean` (new, 420 lines,
18 declarations, sorry-free).

`DedekindINF.lean`, `PriorINF.lean` and Phase 9's `PriorDefsDense.lean` are byte-identical —
consumed, never edited.

## Outcome

The derivation of Rabinovich's eq (5.2) first-occurrence carrier from Reynolds' dense Prior
axioms is complete, sorry-free and axiom-clean, with **no discreteness, no attainment and no flow
completeness**. The plan's proof skeleton (steps 1-6) transcribed verbatim on the first attempt;
the module built green on its first compilation with no tactic search required.

Phase 9's finding was confirmed and is now **a theorem on disk rather than a note**.

## What was landed

### The derivation (Rabinovich 2014 Lemma 5.3 Case 2 / eq (5.2), PDF p.8, from Reynolds 1992 Prior-U/Prior-S, printed p.168)

| Declaration | Statement |
|---|---|
| `prior_hasGuardedDedekindINF_dense` | `SemanticPriorU → HasGuardedDedekindINF`. Plan skeleton steps 1-6 verbatim, at `p := ¬P` |
| `prior_hasGuardedDedekindSUP_dense` | `SemanticPriorS → HasGuardedDedekindSUP`, the mirror |
| **`prior_hasDenseDedekindINF_dense`** | **`SemanticPriorU → HasDenseDedekindINF`** — the exported form |
| **`prior_hasDenseDedekindSUP_dense`** | **`SemanticPriorS → HasDenseDedekindSUP`** |

### The refutation of the unguarded statement

| Declaration | Statement |
|---|---|
| `hasDedekindINF_fails_of_interval_witness` | On **any** densely ordered flow, `HasDedekindINF` fails as soon as some formula holds at `z₀` **and** throughout `(z₀,z₁)`. Axioms: `[propext]` only |
| `hasDedekindSUP_fails_of_interval_witness` | The `Since` mirror |
| `hasDedekindINF_fails_on_dense_window` | Instantiation at `denseWindowFlow` (`P` = the atom, `z₀ = 1/2`, `z₁ = 1`) |
| `hasDedekindSUP_fails_on_dense_window` | Instantiation at `z₀ = 0`, `z₁ = 1/2` |
| `hasGuardedDedekindINF_not_implies_hasDedekindINF` | One structure satisfying `SemanticPriorU`, `SemanticPriorS` and the guarded carrier while refuting the unguarded one |

### Carriers and shims

`HasGuardedDedekindINF` / `HasGuardedDedekindSUP` (guard `¬P(z₀)` resp. `¬P(z₁)`;
conclusion is `HasDedekindINF`'s disjunction character-for-character);
`HasDenseDedekindINF` / `HasDenseDedekindSUP` (hypothesis-free trichotomy);
`HasDedekindINF.toHasDenseDedekindINF`, `HasDedekindINF.toHasGuardedDedekindINF`,
`HasAttainedINF.toHasGuardedDedekindINF` and the four mirrors, plus the interderivability pair
`HasDenseDedekindINF.toHasGuardedDedekindINF` / `HasGuardedDedekindINF.toHasDenseDedekindINF`.

### Anti-vacuity — all three disjuncts reachable, each exhibited

- `hasDenseDedekindINF_of_dense_window`, `hasGuardedDedekindINF_of_dense_window` and the `SUP`
  mirrors instantiate at Phase 9's contentful witness.
- `denseWindow_kplus_at_zero` — the `K⁺(P)(z₀)` disjunct, at `z₀ = 0`.
- `denseWindow_guardedINF_right_disjunct` — the eq (5.2) disjunct, at `z₀ = -1`, forced by
  `denseWindow_kplus_fails_at_neg_one`.
- `denseWindow_endpoint_disjunct_forced` — the new `P(z₀)` disjunct, at `z₀ = 1/2`, together with
  proofs that the *other two fail there*. This is the counterexample displayed disjunct by
  disjunct.

## The deviation, and why it is not a softening

The plan targeted `HasDedekindINF` and its Phase 9 note anticipated two honest fallbacks: a
guarded sibling carrier, or supplying `HasDedekindINF` only where the endpoint case is excluded.
The landed primary export is neither exactly — it is the **trichotomy**, which adds `P(z₀)` as a
third disjunct of the *conclusion* rather than as a hypothesis.

The reason is measured, not assumed. A survey of every `.first_occ` / `.last_occ` call site
outside `Boneyard/` established that **`¬P(z₀)` is available at none of them**: each is reached
from a `by_cases` on whether `P` occurs at an *interior* point of `(z₀,z₁)`, and no hypothesis
about `z₀` is ever in scope. A guarded carrier would therefore have been formally correct and
downstream-unusable.

The trichotomy is the faithful general form, not a weakening. Rabinovich's case split is on
`r₀ = inf{z ∈ (z₀,z₁) | P₁(z)}`, which has three cases — `r₀ = z₀` with `P₁(z₀)`, `r₀ = z₀` with
`¬P₁(z₀)` (i.e. `K⁺(P₁)(z₀)`), and `r₀ > z₀` (eq (5.2)). His printed *"`r₀ = z₀` iff
`K⁺(P₁)(z₀)`"* (PDF p.8) merges the first two. **Read literally that biconditional is false** —
left-to-right needs `¬P₁(z₀)`, since `K⁺` carries `¬P₁(z₀)` as its first conjunct while
`r₀ = z₀` does not. It is sound in his Lemma 5.3 because the infimum is always taken at a point
of the negation chain where the relevant predicate fails, so the hypothesis is discharged by his
construction and never surfaces in his prose. The trichotomy simply keeps the two cases apart.

The endpoint guard, the trichotomy and the refutation are labelled in the module docstring as
**original glue** — a formalization-level correction prompted by a machine-checked
counterexample, present in neither source.

## Second finding — unplanned, material to Phases 11-13

An `EANegationFixFaithful/` subtree plus `Lemma53Faithful.lean` and `Prop42Faithful.lean`
**already exist in-tree and already consume `HasDedekindINF`**, among them
`negChainOnFaithful_iff` (`Lemma53Faithful.lean:274`), `negFixOneFaithful_cover`
(`NegFixOneFaithful.lean:422`) and the list analogue (`NegFixListFaithful.lean:446`).
`DedekindINF.lean`'s docstring still describes this re-base as DEFERRED, and Phases 11-13 are
written as though these modules do not exist.

Because they are pinned at the **unguarded** `HasDedekindINF`, they cannot be instantiated at any
dense Prior structure — the hypothesis is refutable there. Phases 11-13 should be re-scoped
against what is on disk before dispatch; the work may be largely a hypothesis-swap onto
`HasDenseDedekindINF` plus the new endpoint case, rather than the from-scratch construction the
plan describes.

## Verification

| Gate | Result |
|---|---|
| Scoped build | Green, first attempt |
| Full `lake build` | Green — "Build completed successfully (1912 jobs)" |
| Sorries in new module | 0 |
| Live sorry outside `Boneyard/` | Exactly `Transfer.lean:1242` — baseline unchanged |
| `#print axioms`, 18 declarations | `[propext, Classical.choice, Quot.sound]`; the two exclusion lemmas and the two `toHasDenseDedekind*` shims need only `[propext]` |
| Canaries | `completeness_dense`, `completeness_discrete`, `countermodel_discrete_reynolds_v2` — all `[propext, Classical.choice, Quot.sound]`, unchanged |
| Vacuous definitions | 0 |
| New axioms | 0 |
| Frozen files | `DedekindINF.lean`, `PriorINF.lean`, `PriorDefsDense.lean`, the amputated arc, `StrongCompleteness.lean` — all byte-identical |

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Lemma 5.3 Case 2 and eq (5.2), **PDF p.8**
  (cited by PDF page only — the `.md` conversion is corrupt)
- Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
  Prior-U / Prior-S, **printed p.168**
