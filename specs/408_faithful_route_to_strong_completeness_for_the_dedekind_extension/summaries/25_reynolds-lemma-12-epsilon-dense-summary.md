# Phase 25 Summary — Reynolds §8 Lemma 12: `ε(x,y)` defines `∼_M`, and the finite `γ`-set

**Status**: COMPLETED — sorry-free, axiom-clean, scoped and full builds green.
**Owns**: `FormalSystem/Metalogic/WeakCanonical/RealModel/EpsilonDense.lean` (new, 1058 lines).
**Source**: Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the
IRR Rule*, §8, printed pp.186-187 (statement and whole proof transcribed verbatim into the
module header).

## What landed

### Objective 25.1 — `∼_M` and the finite `γ`-set

| Declaration | Content |
|---|---|
| `SimDense` | Reynolds' three printed clauses (p.186): `a = b`, or `a < b` and `M \| (a,b)` very good, or `b < a` and `M \| (b,a)` very good |
| `simDense_refl`, `simDense_symm` | The two easy clauses of the equivalence |
| `openSubOpenSubEquiv`, `kEquiv_openSub_openSub` | `(M\|(a,b))\|(z,w) ≅ M\|(z,w)` |
| `veryGoodDense_openSubinterval_mono` | *"very goodness is inherited by substructures on subintervals"* (p.187) |
| `simDense_convex` | *"the `∼_M` classes are intervals"* (p.187) |
| `goodNFs`, `gammaSentences`, `gammaDisj` | The finite `{γ_1,…,γ_s}` and `⋁_{i≤s} γ_i` |
| `kEquiv_of_shared_nf` | *"if `N_1 ⊨ γ` then `N_2 ≡_k N_1` iff `N_2 ⊨ γ`"* |
| `goodDense_iff_eval_gammaDisj` | *"`N` is good iff `N ⊨ ⋁_{i≤s} γ_i`"* |

Finiteness is `Finset`-level and needs no argument: `NormalForm sig k 0` is already a `Fintype`
via `normalForm_card`. The `NormalForm` / `nfCharacteristic` / `nfToSentence` layer was consumed
as it stands. The `hn : n ≤ 1` restriction that `Kamp.nf_nvar_exist_all_depths` carries does not
bite here — that restriction belongs to the Prior-expressiveness route, which needs a
normal-form-to-`U`/`S` translation at `n` free variables; this module stays inside the monadic
language and uses only the `n = 0` case.

### Objective 25.2 — open-interval relativization

`relativizeOpen`, `relativizeOpenSentence`, `relativizeOpenEnv` and `relativizeOpen_correct`.

The plan anticipated that this was prepaid by `relativizeAt`. It is not, and the module header
records why: `relativizeAt` (`DenseModelSurgery/Lemma5.lean:672`) relativizes to an **`ε`-class**
cut out by a binary formula at **one** parameter, whereas Reynolds' `γ(z,t)` relativizes to an
**interval** cut out by **two**. The tree's `relativize` (`MonadicFO.lean:551`) is the right
shape but is the **closed** `[z,t]` of the discrete Lemma 15. `relativizeOpen` is the open
sibling: the same recursion and the same variable layout, with `<` guards in place of `≤` and
`openSubinterval` in place of `subinterval`.

### Objective 25.3 — `γ'(z,t)`, `ε(x,y)`, and the defining theorem

| Declaration | Content |
|---|---|
| `gammaPrime` | `γ(z,t) ∧ ∃u(z < u < t)` |
| `eval_gammaPrime` | `γ'(z,t)` says exactly that `M \| (z,t)` is non-empty and good |
| `epsDense` | `ε(x,y)`, both guarded conjuncts, transcribed verbatim from p.187 |
| `eval_epsDense`, `veryGoodDense_openSubinterval_iff` | The two unfoldings that meet in the middle |
| `contempEquivDense_epsDense_iff` | **`ε` defines `∼_M`** |

### Objective 25.4 — contemporaneity

`openSubOrderEquiv`, `veryGoodDense_of_orderIso`, `subOpenSubEquiv`, `veryGoodDense_subOpen_iff`,
`simDense_contemporary`.

### Objective 25.5 — transitivity and the assembled Lemma 12

| Declaration | Content |
|---|---|
| `binSumFamily`, `binSum`, `kEquiv_binSum` | The first **general** binary lexicographic sum in the tree (`GoodDense.lean` had only the one-sided `pointSum` and `sumPoint`) |
| `catBlock`, `kEquiv_binSum_catBlock` | The `ℝ`-interval block realizing a concatenation of two abutting real intervals |
| `ioo_union_ico` | `(0,1) ∪ [1,2) = (0,2)` — the seam closes up |
| `goodDense_binSum_pointSum` | **`X + M\|{b} + Y` is good**: `X` onto `(0,1)`, `b` onto `1`, `Y` onto `(1,2)` |
| `kEquiv_openSub_split` | `M\|(t,u) ≡_k M\|(t,b) + M\|[b,u)` for `t < b < u` |
| `veryGoodDense_openSub_trans` | The core of transitivity: Reynolds' three cases |
| `simDense_trans`, `simDense_equivalence` | *"The difficult part is transitivity"* (p.187) |
| `epsDense_isContempEquiv` | Lemma 12, assembled |

Why the concatenated flow is again an interval of `ℝ`: the witness `R₁` inherits `M | (t,b)`'s
lack of a right end point through `noMaxOrder_of_kEquiv` — which is where `2 ≤ k` is spent — so
no two consecutive points arise at the seam. Without that the sum would have a jump and no
ordered subset of `ℝ` could realize it.

## Deviation: two hypotheses Reynolds leaves implicit

Reynolds states Lemma 12 for *"any `M`"*. The proof uses two hypotheses he never writes down,
and the phase's deliverable carries them explicitly rather than papering over them:

* **`[Countable M.carrier]`.** The step *"`M | (t,b)` and `M | (b,u)` are both very good so are
  good"* is Lemma 11, whose hypothesis is countability.
* **`[DenselyOrdered M.carrier]`.** Without it transitivity is **false**, not merely unproved.
  Take `M | (a,b)` order-isomorphic to `(0,1]`, with maximum `x`, and `M | (b,c)` very good.
  Then `a ∼ b` and `b ∼ c`. But `ε(a,c)` quantifies over all `z,t` with `a < z < t < c`, and the
  pair `(x, b)` qualifies while `M | (x,b)` is empty — so `M | (a,c)` is not very good and
  `a ≁ c`. Reynolds' *"if `b = t` or `b = u` then use a lexicographic sum"* silently assumes the
  boundary subinterval is non-empty, which density supplies.

Both hold at Doets' theorem's `M` (countable, dense, endpointless), so nothing downstream is
weakened. The consequence for the shape of the deliverable is that the three clauses are landed
as `simDense_equivalence` / `simDense_convex` / `simDense_contemporary`, bundled by
`epsDense_isContempEquiv`, rather than as the `∀ M`-quantified `IsContempEquivDense` structure of
`DenseModelSurgery/Defs.lean:234`.

**What Phase 29 must do about it**: its anti-vacuity checkbox wants a live `ε` satisfying
`IsContempEquivDense`. Either instantiate `epsDense_isContempEquiv` at the chronicle structure
and package the clauses directly — the chronicle flow is countable and dense, so both hypotheses
discharge — or introduce a hypothesis-carrying variant of `IsContempEquivDense` restricted to
countable dense structures. The first is the smaller change and needs no edit to `Defs.lean`.

## Verification

| Gate | Result |
|---|---|
| `lake build FormalSystem.Metalogic.WeakCanonical.RealModel.EpsilonDense` | green, zero warnings |
| `lake build` (full) | green, 1983 jobs |
| `sorry` in `EpsilonDense.lean` | 0 |
| sorry census outside `Boneyard/` | `Transfer.lean:1242` only — unchanged from the plan's baseline |
| vacuous definitions introduced | 0 (repo total is 1, pre-existing, in `Examples/TemporalStructures.lean`) |
| axioms declared | 0 introduced |
| `#print axioms` on the eight headline declarations | `[propext, Classical.choice, Quot.sound]` only |

**Build-reachability note**: `RealModel/` modules are not on the `FormalSystem` root import
chain, so the full `lake build` does not compile them. Verification therefore uses the scoped
build, exactly as Phase 24 did. Putting `RealModel` on the root chain is a separate decision and
was left alone.

## Commits

```
93aaf6b81  task 408 phase 25.1: SimDense, very-goodness inheritance, and the finite gamma-set
ea75c0e40  task 408 phase 25.2: open interval relativization and its correctness theorem
daf39d57c  task 408 phase 25.3: gamma prime, the epsilon formula, and epsilon defines the relation
1f06f1b13  task 408 phase 25.4: order iso transfer of very goodness and contemporaneity
5977a9d08  task 408 phase 25.5: transitivity via the lexicographic sum and the assembled Lemma 12
```
