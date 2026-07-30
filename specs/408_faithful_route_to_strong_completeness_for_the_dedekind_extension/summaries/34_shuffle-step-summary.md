# Sub-phase 29.6 — the shuffle step; `doets_theorem_dense` is sorry-free

**Phase**: 29, "Doets' Theorem — Reynolds §8 Theorem 6". Third orchestration cycle on this phase.

**Terminus framing (unchanged, and load-bearing)**: the headline result for `FrameClass.Dedekind`
is **weak** completeness, `completeness_dedekind`, together with the finite-context consequence form
`consequence_completeness_dedekind` (`Γ : Context = List Formula`). Genuine infinite-premise strong
completeness is **provably unavailable** for this class — the class consequence relation is not
compact (Reynolds 1992 §2, printed p.169) — so it is refuted, not deferred. The task directory and
plan filename retain `strong_completeness` as historical identifiers only. Reynolds §8 Theorem 6 is
an ingredient of the weak-completeness route; nothing here bears on the terminus, and no declaration
was named or renamed toward "strong".

## What landed

`goodDense_unionClasses` — the tracked strategic sorry at `DoetsTheorem.lean:1318` at dispatch start
— is discharged. `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean` now contains
**no `sorry` at all**, and `doets_theorem_dense` is the printed Theorem 6 statement, with no added
hypotheses beyond `hk : 2 ≤ k`, **sorry-free and axiom-clean**.

Twenty-eight new declarations, all sorry-free and axiom-clean, in four layers. Each layer is one of
Reynolds' printed sentences, and the section headers quote them.

### Layer 11 — the two-sided closed normalization of `N_γ`

Printed p.187's *"choose an `N_γ ⊨ γ` whose flow of time is an interval of the reals"*, sharpened to
p.188's *"because the `γᵢ`'s say so the summands themselves are **closed** intervals of the reals"*.

`goodDense` hands back *some* order-connected set of reals. The five summand hypotheses of
`goodDense_shuffle` (`hne`, `hdense`, `hsum`, `hbot`, `hsep`) are the facts that hold of a closed
bounded interval and **fail** for the open one: an open interval has no least element and is not
closed under suprema. *"Has an end point"* is a depth-2 sentence, so it travels across `≡ₖ` at
`k ≥ 2` exactly as *"has no end point"* does in `noMaxOrder_of_kEquiv`; the two ends then pin the
flow down with no residual choice, because an order-connected set of reals with a least and a
greatest element **is** the closed interval between them.

`exists_max_of_kEquiv`, `exists_min_of_kEquiv`, `nfEvalNf_of_kEquiv`, `ordConnected_eq_Icc`,
`IsIccLike`, `isIccLike_of_carrierSet_eq_Icc`, `exists_iccLike_witness`,
`exists_icc_witness_of_subsingleton`, `subsingleton_of_carrierSet_eq_Icc_self`.

**Correction to the prior record's sketch.** It called for transporting `DenselyOrdered` across
`≡ₖ` alongside the two end points. That transport is not needed **and could not have been used**:
*"densely ordered"* is a depth-3 sentence, so it does not travel at `hk : 2 ≤ k`. Density instead
comes for free from `OrdConnected` in `ℝ`. Only the two end-point transfers are real work, and both
reuse the existing depth-2 `hasMaxSent` / `hasMinSent` machinery. The sketch was otherwise correct
and was followed.

### Layer 12 — the `∼`-classes *are* the closed-interval summands

Two facts the prior sketch assumed without naming:

* **`M | E` is good.** `x ∼ y` *means* very-goodness of `M | (x,y)` (`SimDense`, printed p.185), and
  convexity of the class (Lemma 12) puts `(x,y)` inside `E` whenever `x, y ∈ E`. So every open
  subinterval of `M | E` is such an `M | (x,y)`, which makes `M | E` very good, and Lemma 11 turns
  that into goodness.
* **Layer 9's end-point construction applies at an *interior* class** — run at `(e,d)` and at
  `(c,e)` rather than at `(c,d)`. An interior class is bounded above by `d` and below by `c`, so
  Lemma 13 and D1 attain both bounds *inside* the class. This is what makes each summand closed on
  both sides.

`kEquiv_restrictSet_openSub`, `kEquiv_openSub_restrictSet`, `veryGoodDense_contempClassStructure`,
`goodDense_contempClassStructure`, `exists_max_contempClass`, `exists_min_contempClass`,
`exists_iccLike_contempClass`.

### Layer 13 — Reynolds' `σ`

Printed p.187's *"Any structure is a model of just one such `γ`"* makes the colour a **function**,
not a choice: `classNF` reads it off a point, `classColour` is the same map on `M/∼` — well defined
because `∼`-equivalent points have literally the **same** class structure, not merely isomorphic ones
— and `σ` is `classColour ∘ e.symm`. Reynolds' *"we can choose `σ` appropriately"* is discharged by
the order isomorphism `e : I ≃o ℚ` alone.

`trivialIccStructure`, `isIccLike_trivialIccStructure`, `classNF`, `classNF_spec`,
`classNF_eq_of_nfEvalNf`, `contempClassStructure_congr`, `classNF_congr`, `classColour`,
`classColour_cls`, `classNF_mem_gammaBetween`, `isShuffleMap_classColour`.

**Correction to the prior record's sizing.** It called this half *"bookkeeping over landed assets"*.
One step is not. `gammaBetween_dense_of_minimal` produces a class realizing `γ` inside *some*
`≁`-pair of `M`-points; the shuffle needs it inside the pair **the two rationals name**. The bridge
is Layer 9's end points run a second time, at the two classes `e.symm r` and `e.symm s`: a class
strictly inside `(x', y')` is inequivalent to both named classes and lies between them, which is
*"strictly between them in `I`"* and hence, along `e`, *"at a rational strictly between `r` and
`s`"*. So the class end points are needed **twice over** — once to close each summand (Layer 12) and
once to locate it (Layer 13).

### Layer 14 — the composition

`exists_singleton_class_between` produces Reynolds' `γ₁` where Reynolds produces it, from **D2**: a
singleton class strictly inside `(c,d)` is all `γ₁` needs to be, and printed p.188's *"`γ₁` is only
satisfied by one point structures"* is then `subsingleton_of_carrierSet_eq_Icc_self` at the
degenerate interval `[0,0]`.

`exists_iccLike_family` makes the one remaining choice, once. Its three clauses are the three uses
the shuffle puts the family to: `IsIccLike` at **every** index (because `goodDense_shuffle`
quantifies its five summand hypotheses over all of `ι`, not just over `S` — at indices outside `G`
the value is the degenerate interval), *"`N_γ ⊨ γ`"* at the indices `σ` can reach, and the `γ₁`
clause carrying `hone` through.

`kEquiv_classBlock` is the one step of the composition **Reynolds does not write at all**: on paper
`M | E` is one object, but the block map cuts the class out of `M | (c',d')` while the `γ`-palette
cuts it out of `M`, and in Lean those are different types.

`goodDense_unionClasses` then composes `kEquiv_blocks_shuffle` (Reynolds' `M | (⋃ I) =
Σ_{E ∈ I} M | E ≡ₖ Σ_{q ∈ ℚ} σ(q)`) with `goodDense_shuffle` (his `Σ_{q ∈ ℚ} σ(q) ≡ₖ
Σ_{r ∈ ℝ} σ*(r)` and *"`R` is isomorphic to the reals"*).

## Verification

| Check | Result |
|---|---|
| `sorry` in `DoetsTheorem.lean` | **0** |
| non-Boneyard sorry census | **1** — `Transfer.lean:1242`, pre-existing and unrelated (was 2 at dispatch start; **fell** by one) |
| `#print axioms goodDense_unionClasses` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms reynolds_theorem6_contradiction` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms doets_goodDense` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms doets_theorem_dense` | `[propext, Classical.choice, Quot.sound]` |
| scoped build | green, 2234 jobs, `DenseModelSurgery.ChronicleInstance` as canary |
| full `lake build` | green, 1983 jobs |
| vacuous definitions | 0 in territory (one repo-wide hit, `Examples/TemporalStructures.lean:279`, pre-existing and out of territory) |
| new axioms | 0 (the two `^axiom ` grep hits are Boneyard docstring prose, not declarations) |
| territory | one Lean file modified: `RealModel/DoetsTheorem.lean`. No §6 file, no `Decidability/`, no `Automation/` |

Every one of the eleven new declarations spot-checked with `#print axioms` reports exactly
`[propext, Classical.choice, Quot.sound]`; no `sorryAx` occurs anywhere in the chain.

## Why the phase is still `[PARTIAL]`

The proof is done. The phase's third checkbox is not, and it is now the **only** outstanding item:

> **Anti-vacuity**: instantiate at `chronicleIsDensePriorSepStructure` with the D1 and D2 instances
> from Phases 22-23, and land the resulting `ℝ`-flowed structure as a named definition.

This is **no longer coupled to any tracked sorry** — that coupling is what the previous two cycles'
records described, and it is gone. It is gated instead on discharging `DoetsD1` / `DoetsD2` at the
chronicle structure, which requires §6 to run on the countable-dense bundle `IsContempEquivDenseCD`.
That was attempted and **measured to fail** in an earlier sub-dispatch, irreducibly:
`reynolds_lemma9` demands `DenselyOrdered (surgeredStructure M ε Q t).carrier`, and that structure
collapses a bad interval to a single class, so by Lemma 4 (*"no first class in any maximal
interval"*) it has adjacent points and is **not** densely ordered. Supplying it as a hypothesis would
make §6 Theorem 4 vacuous. Closing the checkbox at `epsTop` is vacuous by the plan's own caveat.

That obstruction lives in §6, outside this phase's territory, and this dispatch did not widen scope
into it. `exists_realFlow_shuffleReal_point` remains landed as a weaker but honest anti-vacuity
witness and is **not** claimed to discharge the checkbox.

## Stale documentation corrected rather than left standing

* The module header's *"Honesty charter"* claimed the `G`-minimality argument was **not** landed and
  was carried as a named hypothesis of a `doets_theorem_dense_core`. That declaration no longer
  exists — it was discharged, not renamed — and the claim was false as of this dispatch.
* `reynolds_theorem6_contradiction`'s docstring still asserted that `#print axioms` reports
  `sorryAx` and *"will until the shuffle step lands"*. The shuffle step has landed.
* Four rows added to the source-to-implementation map for Layers 11-14, and the map's
  `doets_theorem_dense_core` row replaced.

## Commits

| Commit | Content |
|---|---|
| `5fd6cf1bc` | Layer 11 — the two-sided closed normalization |
| `68a26f8dc` | Layer 12 — the classes are the closed-interval summands |
| `7699f54eb` | Layer 13 — Reynolds' `σ` and its shuffle-map property |
| `785f9b9a7` | Layer 14 — the shuffle step lands; `doets_theorem_dense` is sorry-free |
