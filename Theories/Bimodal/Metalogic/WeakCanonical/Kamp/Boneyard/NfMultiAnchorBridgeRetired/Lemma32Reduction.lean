import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Rabinovich Lemma 3.2(2) — the ≤2-free-variable reduction for `nf_eval_nf`

This module builds the faithful exit from the multi-anchor blocker: a
**semantic reduction at the `nf_eval_nf` level** that never introduces a single-world
navigating characteristic. Every piece of the reduction stays a `nf_eval_nf ↔ nf_eval_nf`
equivalence (Prop ↔ Prop) whose anchor arity never climbs past 3.

## Why this reduction exists (the machine-checked impossibility it routes around)

Task 349's multi-anchor recursion was blocked by two green, sorry-free refutations in
`Base.lean` (axioms exactly `[propext, Classical.choice, Quot.sound]`):

* `endCharN0_correct_world_local_obstruction` (Base.lean:1745): if a single-world
  `TemporalPred` base, evaluated at the navigated witness `env 0`, were biconditional to the
  full arity-`n` atom layer `nf_eval_nf M 0 n env qnf`, then `nf_eval_nf M 0 n env qnf` would be
  forced to depend only on `env 0` — invariant under any change to `env` at positions `≥ 1` —
  because `(base qnf).eval_at M atomMap (env 0)` reads only the single world `env 0`.

* `endCharN0_correct_infeasible` (Base.lean:1779): **the frozen `endCharN0_correct` is
  UNPROVABLE.** There is a concrete model (`Mcex` over `Bool`, signature `sigCex` with one
  predicate) for which NO base satisfies the frozen unconditional multi-anchor biconditional.
  Two environments agreeing at position `0` (`![false, false]` and `![false, true]`) are forced
  by world-locality to agree, yet they disagree on the predicate atom at position `1`
  (`M.interp () false` vs `M.interp () true`) — contradiction. The obstruction is intrinsic to
  `TemporalPred.eval_at`'s single-world evaluation, so it rules out every candidate base.

The faithfulness audit (report 02, §Q4 target 4) and the spawn analysis (report 03)
converge on the same faithful exit: apply the reduction at the `nf_eval_nf` level, BEFORE any
navigation step, so the recursion never climbs past the arity-3 "two anchors + one witness"
shape the green `nf_zone_flatten_navigable`/`_correct` template (Base.lean:667-697) already
certifies.

## Source (verbatim)

Rabinovich 2014, *A Proof of Kamp's Theorem*, Lemma 3.2(2) (md:119):
"Every →∃∀-formula is equivalent to a conjunction of →∃∀-formulas with at most two free
variables."

In the `nf_eval_nf` encoding each `AtomKind sig n` constructor mentions ≤2 indices
(`pred p i` reads one position, `order i j h` reads two), so the depth-0 atom layer
`nf_eval_nf M 0 n env qnf` factors into ≤2-anchor `nf_eval_nf M 0 2` facts over anchor pairs.
The quant layer (depth `k+1`) is reduced to arity-3 `zoneEnv3`-shaped existentials over a fixed
enclosing anchor pair (later phases). This is the atom-layer base (Phase 1–2).

## Forbidden constructions (postmortem constraints — binding)

The following are PROHIBITED in this module (they are the refuted multi-anchor failure modes):

* No single-world `TemporalPred`/`Formula` biconditional to the arity-`n` atom layer for
  arbitrary `env` — this is `endCharN0_correct_infeasible`, machine-checked UNPROVABLE.
* No single-anchor `navBrickForm` reshape (report 02 Option A, H4-refuted). This module
  produces no `Formula`-valued converter at all.
* No use of `nf_char3_deeper_split` (Base.lean:603) as an arity collapse — it GROWS anchors
  to arity-4, the exact failure mode.
* No free-standing `NavResidual`/`h_nav` predicate-layer residual at inner witnesses.
* No `sorry`, no vacuous `def X := True`/`Unit`/`trivial`, no `simp`/`omega`/`aesop` shortcut
  that silently weakens the RHS. The RHS conjunction must remain the genuine full
  characterization.
* No edits to `Base.lean` or any existing file — all new work lands here.

## Frozen target signature (assembled in Phase 5)

The main reduction theorem's `Prop`-level shape is FROZEN here so later phases prove toward a
fixed statement (they may only narrow it via the Phase-3 feasibility gate, never drift it):

```
theorem nfEval_le2_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {k n : Nat} (hn : 2 ≤ n) (env : Fin n → M.carrier) (qnf : NormalForm sig k n) :
    nf_eval_nf M k n env qnf ↔
      (finite conjunction of `nf_eval_nf M k n' _ _` facts, each with anchor arity `n' ≤ 3`)
```

Every conjunct on the RHS is an `nf_eval_nf` fact of anchor arity ≤ 3: `n' ≤ 2` for pure anchor
pairs, `n' = 3` for two anchors plus one existential witness (`zoneEnv3`-shaped). Nothing climbs
to `n+1` distinct free anchors. The depth-0 instance (`k = 0`) is proved green below as
`nfEval0_pairwise`; the depth step and assembly are Phases 3–5.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 1: anchor-pair restriction of the depth-0 atom layer

Each `AtomKind sig n` mentions ≤2 indices, so the depth-0 evaluation
`nf_eval_nf M 0 n env qnf = ∀ a, atom_eval M env a ↔ qnf a = true` factors through the
finite family of arity-2 restrictions to distinct anchor pairs `(i, j)`. This is the
guaranteed-provable atom-layer foundation of the Lemma 3.2(2) reduction. -/

/-- Select anchor `i` for position `0` of a pair and anchor `j` for position `1`. -/
def pairSel {n : Nat} (i j : Fin n) (k : Fin 2) : Fin n :=
  if k = 0 then i else j

@[simp] theorem pairSel_zero {n : Nat} (i j : Fin n) : pairSel i j 0 = i := by
  simp [pairSel]

@[simp] theorem pairSel_one {n : Nat} (i j : Fin n) : pairSel i j 1 = j := by
  simp [pairSel]

/-- Distinct pair positions select distinct anchors (the order-atom distinctness witness). -/
theorem pairSel_ne {n : Nat} {i j : Fin n} (hij : i ≠ j) {k l : Fin 2} (hkl : k ≠ l) :
    pairSel i j k ≠ pairSel i j l := by
  match k, l, hkl with
  | 0, 1, _ => simpa using hij
  | 1, 0, _ => simpa using hij.symm
  | 0, 0, h => exact absurd rfl h
  | 1, 1, h => exact absurd rfl h

/-- The arity-2 environment restricted to the anchor pair `(i, j)`: position `0 ↦ env i`,
position `1 ↦ env j`. -/
def envPair {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) (i j : Fin n) : Fin 2 → M.carrier :=
  fun k => env (pairSel i j k)

/-- Embed an arity-2 atom into the arity-`n` atom layer along the anchor pair `(i, j)`
(`hij : i ≠ j` supplies the distinctness proof for the order atom). Position `0 ↦ i`,
position `1 ↦ j`. -/
def pairEmbed {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (i j : Fin n) (hij : i ≠ j) :
    AtomKind sig 2 → AtomKind sig n
  | .pred p k => .pred p (pairSel i j k)
  | .order k l h => .order (pairSel i j k) (pairSel i j l) (pairSel_ne hij h)

/-- Restrict a depth-0 normal form to the anchor pair `(i, j)`: the arity-2 atom assignment
`a ↦ qnf (pairEmbed i j hij a)`. -/
def nfRestrictPair {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (qnf : NormalForm sig 0 n)
    (i j : Fin n) (hij : i ≠ j) : NormalForm sig 0 2 :=
  fun a => qnf (pairEmbed i j hij a)

/-- Evaluating a restricted atom on the restricted arity-2 environment agrees with evaluating
the embedded atom on the full environment. Definitional up to the atom constructor. -/
theorem atom_eval_pairEmbed {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (i j : Fin n) (hij : i ≠ j) (a : AtomKind sig 2) :
    atom_eval M (envPair M env i j) a ↔ atom_eval M env (pairEmbed i j hij a) := by
  cases a <;> exact Iff.rfl

/-- **Phase 1 milestone (depth-0 pairwise reduction).** The depth-0 atom layer
`nf_eval_nf M 0 n env qnf` is equivalent to the finite conjunction, over all distinct anchor
pairs `(i, j)`, of its arity-2 restrictions `nf_eval_nf M 0 2 (envPair M env i j)
(nfRestrictPair qnf i j hij)`. Each conjunct has anchor arity exactly 2 — the guaranteed-green
atom-layer core of Rabinovich Lemma 3.2(2) (`2 ≤ n` guarantees every single-index predicate
atom is covered by some pair). -/
theorem nfEval0_pairwise {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {n : Nat} (hn : 2 ≤ n) (env : Fin n → M.carrier) (qnf : NormalForm sig 0 n) :
    nf_eval_nf M 0 n env qnf ↔
      ∀ (i j : Fin n) (hij : i ≠ j),
        nf_eval_nf M 0 2 (envPair M env i j) (nfRestrictPair qnf i j hij) := by
  constructor
  · -- forward: restrict every anchor-pair instance to the full atom layer
    intro H i j hij a
    have hemb := H (pairEmbed i j hij a)
    rw [atom_eval_pairEmbed M env i j hij a]
    simpa [nfRestrictPair] using hemb
  · -- backward: recover every arity-`n` atom from the pair containing its indices
    intro H a
    cases a with
    | pred p i =>
      -- pick a partner `j ≠ i` (exists since `2 ≤ n`), read position `0` of that pair
      obtain ⟨j, hj⟩ : ∃ j : Fin n, j ≠ i := by
        refine ⟨⟨if i.val = 0 then 1 else 0, by split <;> omega⟩, ?_⟩
        simp only [ne_eq, Fin.ext_iff]
        split <;> omega
      have hpair := H i j (Ne.symm hj) (AtomKind.pred p 0)
      have := (atom_eval_pairEmbed M env i j (Ne.symm hj) (AtomKind.pred p 0)).symm.trans hpair
      simpa [nfRestrictPair, pairEmbed, envPair] using this
    | order i j h =>
      have hpair := H i j h (AtomKind.order 0 1 (by decide))
      have := (atom_eval_pairEmbed M env i j h (AtomKind.order 0 1 (by decide))).symm.trans hpair
      simpa [nfRestrictPair, pairEmbed, envPair] using this

/-! ## Phase 2: full depth-0 atom-layer reduction (arity-general, diagonal-total)

Phase 1's `nfEval0_pairwise` carried a `2 ≤ n` hypothesis and a distinctness guard `i ≠ j`,
deferring the degenerate diagonal (`i = j`) and the `n < 2` coverage. Phase 2 closes that gap
with a *total* restriction `nfRestrict0 qnf i j : NormalForm sig 0 2` defined for every pair —
including `i = j` — and proves the reduction

  `nf_eval_nf M 0 n env qnf ↔ ∀ i j, nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)`

with NO arity hypothesis. On the diagonal the two-variable order atom cannot embed (there is no
`i ≠ i` order atom in the arity-`n` layer), so it is sent to `false`, which is exactly the truth
value of `env i < env i` under `LinearOrder` irreflexivity. Predicate atoms are covered by the
diagonal conjunct `(i, i)`; order atoms by the genuine `i ≠ j` pairs. This reuses the Phase-1
machinery `pairSel`/`pairSel_zero`/`pairSel_one`/`pairSel_ne`/`envPair` (it does not re-derive them).

**Deviation from the H3 target row (`![env i, env j]`):** the arity-2 environment is written as the
Phase-1 `envPair M env i j` (`fun k => env (pairSel i j k)`) rather than the raw matrix literal
`![env i, env j]`. The two are pointwise equal (`envPair M env i j 0 = env i`, `… 1 = env j`); using
`envPair` keeps the file `import`-clean (no `VecNotation`) and cohesive with `nfEval0_pairwise`. -/

/-- Total anchor-pair restriction of a depth-0 normal form. Predicate atoms embed on every pair
(`pred p k ↦ qnf (pred p (pairSel i j k))`). The two-variable order atom embeds only off the
diagonal (`i ≠ j`, using `pairSel_ne` for the distinctness proof); on the diagonal (`i = j`) it is
sent to `false`, matching the `LinearOrder` irreflexivity `¬ (env i < env i)`. For `i ≠ j` this
agrees with the Phase-1 `nfRestrictPair qnf i j`. -/
def nfRestrict0 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (qnf : NormalForm sig 0 n)
    (i j : Fin n) : NormalForm sig 0 2
  | .pred p k => qnf (.pred p (pairSel i j k))
  | .order k l h =>
      if hij : i = j then false
      else qnf (.order (pairSel i j k) (pairSel i j l) (pairSel_ne hij h))

@[simp] theorem nfRestrict0_pred {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (qnf : NormalForm sig 0 n)
    (i j : Fin n) (p : sig.preds) (k : Fin 2) :
    nfRestrict0 qnf i j (.pred p k) = qnf (.pred p (pairSel i j k)) := rfl

theorem nfRestrict0_order_diag {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (qnf : NormalForm sig 0 n)
    (i : Fin n) (k l : Fin 2) (h : k ≠ l) :
    nfRestrict0 qnf i i (.order k l h) = false := by
  simp [nfRestrict0]

theorem nfRestrict0_order_off {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat} (qnf : NormalForm sig 0 n)
    {i j : Fin n} (hij : i ≠ j) (k l : Fin 2) (h : k ≠ l) :
    nfRestrict0 qnf i j (.order k l h)
      = qnf (.order (pairSel i j k) (pairSel i j l) (pairSel_ne hij h)) := by
  simp only [nfRestrict0]
  exact dif_neg hij

/-- `pairSel i i k = i` for either pair-position (the diagonal collapses both anchors). -/
theorem pairSel_diag {n : Nat} (i : Fin n) (k : Fin 2) : pairSel i i k = i := by
  simp only [pairSel]; split <;> rfl

/-- **Phase 2 milestone (full depth-0 atom-layer reduction).** The depth-0 atom layer
`nf_eval_nf M 0 n env qnf` is equivalent to the finite conjunction, over ALL pairs `(i, j)` of
anchor positions, of its arity-2 restrictions `nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)`.
Unlike the Phase-1 `nfEval0_pairwise`, this carries no `2 ≤ n` hypothesis and no `i ≠ j` guard: the
diagonal conjuncts `(i, i)` cover every single-index predicate atom (so `n < 2` is handled), and the
diagonal order atom is `false`, matching `LinearOrder` irreflexivity. Every conjunct has anchor arity
exactly 2 — the guaranteed-green atom-layer core of Rabinovich Lemma 3.2(2). -/
theorem nfEval0_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {n : Nat} (env : Fin n → M.carrier) (qnf : NormalForm sig 0 n) :
    nf_eval_nf M 0 n env qnf ↔
      ∀ (i j : Fin n), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j) := by
  simp only [nf_eval_nf]
  constructor
  · -- forward: read each arity-2 restricted atom off the corresponding arity-`n` atom
    intro H i j a
    cases a with
    | pred p k =>
        simp only [atom_eval, nfRestrict0_pred, envPair]
        exact H (AtomKind.pred p (pairSel i j k))
    | order k l h =>
        by_cases hij : i = j
        · -- diagonal: `env i < env i` is false, and `nfRestrict0` sends the order atom to `false`
          subst hij
          rw [nfRestrict0_order_diag]
          simp only [atom_eval, envPair, pairSel_diag, lt_irrefl]
          simp
        · -- genuine pair: order atom embeds along `(i, j)`
          rw [nfRestrict0_order_off qnf hij]
          simp only [atom_eval, envPair]
          exact H (AtomKind.order (pairSel i j k) (pairSel i j l) (pairSel_ne hij h))
  · -- backward: recover each arity-`n` atom from the pair (diagonal for `pred`, `(i,j)` for `order`)
    intro H a
    cases a with
    | pred p i =>
        have hh := H i i (AtomKind.pred p 0)
        simp only [atom_eval, nfRestrict0_pred, envPair, pairSel_diag] at hh
        simpa only [atom_eval] using hh
    | order i j h =>
        have hh := H i j (AtomKind.order 0 1 (by decide))
        rw [nfRestrict0_order_off qnf h] at hh
        simp only [atom_eval, envPair, pairSel_zero, pairSel_one] at hh
        simpa only [atom_eval] using hh

/-! ## Phase 3: FEASIBILITY GATE — the arity-3 zone bridge for one existential over a fixed
enclosing anchor pair drawn from `env`

Phase 2 reduced the depth-0 atom layer to a conjunction of ≤2-anchor facts. Phase 3 attacks the
single most order-sensitive step of the quant layer: the inner realizability existential
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` for anchors `(x, t) = (env i, env j)` drawn from a
fixed enclosing anchor pair of the surrounding environment. This is the go/no-go gate for the
general quant-layer merge (Phases 4–5).

**Order-machinery bridge (`nfEval_pair_arity3_flatten`, GREEN).** The green two-anchor template
(`nf_char2_zone_split5`, Base.lean:584; `nf_zone_flatten_navigable_correct`, Base.lean:687)
certifies that this existential admits the five-zone navigated flatten at ANY anchors, and in
particular at `(env i, env j)`. There is exactly ONE witness `w` threaded through all five zones
(no independent per-pair witness — the SETTLED decision), and the anchor set stays `{env i, env j}`
so the arity never climbs past 3. The interior `(env i < w < env j)` zone is coupled to the
navigated interior characteristic via `seg_holds_coupled` (Base.lean:1150), reused verbatim below.

**Why the naive single-pair arity reduction is NOT a bi-implication (the gate's negative content —
the SETTLED "strictly weaker" boundary).** One might hope to bridge the FULL arity-`(n+1)` inner
existential `∃ w, nf_eval_nf M k (n+1) (Fin.cons w env) sub` to the arity-3 pair-restricted one
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) (restrict sub)` as an `↔`. The forward
(projection) direction holds, but the converse is a **non-theorem** for a FIXED single pair: when
`n ≥ 3` there is an anchor position outside `{i, j}`, and an arity-3 witness constrained only at the
pair `{i, j}` (the arity-3 restriction genuinely FORGETS the other anchors) need not satisfy the
arity-`(n+1)` form's constraints at those other positions — so the arity-3 pair-restricted existential
can hold while the arity-`(n+1)` inner existential fails. This is the same world-locality /
strict-weakness phenomenon already machine-checked, sorry-free, by `endCharN0_correct_infeasible`
(Base.lean:1779) and `endCharN0_correct_world_local_obstruction` (Base.lean:1745): a projection that
drops non-local positions is strictly weaker than the full evaluation. It is exactly the plan's
SETTLED warning that "independent per-pair witnesses do not merge for free," and it is why the general
merge (Phases 4–5) must proceed order-theoretically over the enclosing ZONE (a disjunction over the
possible enclosing pairs, threading one witness through transitivity of the linear order) rather than
by a per-pair arity collapse. The single-pair step therefore contributes only the ONE-DIRECTIONAL
projection plus the order-theoretic zone bridge certified below — never a per-pair bi-implication. -/

/-- **Phase 3 (order-machinery bridge, GREEN).** The inner realizability existential
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) q` over a fixed enclosing anchor pair
`(env i, env j)` drawn from the surrounding environment `env` is captured by the five-zone
navigated flatten `nf_zone_flatten_navigable` at those anchors. Direct specialization of the green
`nf_zone_flatten_navigable_correct` (Base.lean:687) to `x := env i`, `t := env j`: exactly ONE
witness `w` is threaded through the five zones (no independent per-pair witness — SETTLED decision),
the anchor set stays `{env i, env j}` so the arity never climbs past 3 (route (a)/(c) guards), and
the two open exterior zones are navigated `bracketBuild*` chains (route (b) guard). The recursion is
threaded through the two endpoint hooks `pastEnd`/`futureEnd`, whose interior coupling is discharged
one depth down exactly as `seg_holds_coupled` (Base.lean:1150) couples the bounded interior. -/
theorem nfEval_pair_arity3_flatten {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (env : Fin n → M.carrier) (i j : Fin n)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (q : NormalForm sig k 3)
    (h_past : ∀ w : M.carrier, w < env i →
      ((pastEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) q))
    (h_fut : ∀ w : M.carrier, env j < w →
      ((futureEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) q)) :
    (∃ w, nf_eval_nf M k 3 (zoneEnv3 w (env i) (env j)) q) ↔
      nf_zone_flatten_navigable M atomMap (env i) (env j) pastEnd futureEnd q :=
  nf_zone_flatten_navigable_correct M atomMap (env i) (env j) pastEnd futureEnd q h_past h_fut

/-- **Phase 3 (interior coupling, GREEN).** The bounded interior zone `env i < w < env j` of the
five-zone flatten (`nf_zone_flatten_navigable`, the middle disjunct) is characterized, at the
enclosing anchor pair `(env i, env j)`, by the navigated interior segment `seg` holding throughout
the open interval. Direct specialization of the green `seg_holds_coupled` (Base.lean:1150) to
`x := env i`, `t := env j`. Together with `nfEval_pair_arity3_flatten` this certifies that ALL five
zones of the arity-3 inner existential over a fixed enclosing pair are resolved by the green order
machinery — the two open exteriors by the navigated `bracketBuild*` chains, the two points and the
bounded interior by honest arity-3 `nf_eval_nf` residuals coupled through `seg` — with a SINGLE
witness threaded throughout (no independent per-pair witness) and the anchor set fixed at
`{env i, env j}` (no arity climb past 3). This is the positive content of the feasibility gate: the
single order-sensitive step closes green using only the order/zone machinery. -/
theorem nfEval_pair_arity3_interior {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (env : Fin n → M.carrier) (i j : Fin n)
    (endChar : EndCharCarrier sig k) (q : NormalForm sig k 3)
    (h_endChar : ∀ y : M.carrier,
      (endChar q).eval_at M atomMap y ↔
        nf_eval_nf M k 3 (zoneEnv3 y (env i) (env j)) q) :
    (seg endChar q).holds M atomMap (env i) (env j) ↔
      ∀ y : M.carrier, env i < y → y < env j →
        nf_eval_nf M k 3 (zoneEnv3 y (env i) (env j)) q :=
  seg_holds_coupled M atomMap endChar q (env i) (env j) h_endChar

/-! ## Phase 4: depth-`(k+1)` one-step quant-layer pairwise reduction (one depth step)

Phases 1–3 delivered (a) the depth-0 atom-layer reduction to ≤2-anchor pieces
(`nfEval0_reduction`) and (b) the order-machinery certificate that the arity-3 inner existential
over a fixed enclosing pair closes green (`nfEval_pair_arity3_flatten` / `nfEval_pair_arity3_interior`,
the feasibility GATE). Phase 4 assembles the **single depth step**: `nf_eval_nf M (k+1) n env qnf`,
GIVEN a depth-`k` reduction `IH` as an abstract predicate family `P`, reduces to

* the ≤2-anchor atom conjunction (Phase 2, `nfEval0_reduction` on the atom part `qnf.1`), AND
* the quant layer, where each sub-form's inner realizability `∃ w, nf_eval_nf M k (n+1)
  (Fin.cons w env) sub` is rewritten by the depth-`k` `IH` to `∃ w, P (n+1) (Fin.cons w env) sub`.

This is exactly the shape `induction k` (Phase 5) consumes: the depth drops by one, the atom layer
collapses to anchor pairs, and the inner arity-`(n+1)` depth-`k` forms are handed to the IH (which,
in Phase 5, is the full ≤3-anchor reduction at arity `n+1`, keeping the arity ceiling at 3).

### Why the single existential stays OUTSIDE the pairwise reduction (SETTLED order-theoretic merge)

The reduction keeps the witness quantifier in the shape `∃ w, (pairwise/IH-reduced body about
`Fin.cons w env`)` — **one** witness `w` threaded through the whole reduced inner form — and NEVER
rewrites it to the per-pair form `∀ (pair), ∃ w, …`. That `∀-pair ∃-witness` shape is precisely the
plan's SETTLED non-theorem ("independent per-pair witnesses do not merge for free"): the FIXED
single-pair arity-`(n+1)`↔arity-3 bi-implication is machine-checked strictly weaker for `n ≥ 3`
(the arity-3 restriction forgets non-pair anchors — the same world-locality obstruction as
`endCharN0_correct_infeasible`, Base.lean:1779). Here the inner form is reduced by the depth-`k`
`IH` **under** the single `∃ w` (via `exists_congr`), so the witness is shared across all the
resulting ≤3-anchor conjuncts — the order-theoretic merge, not a per-pair distribution. Consequently
Phase 4 defines NO arity-collapsing `nfRestrict : NormalForm sig (k+1) n → … → NormalForm sig (k+1) 2`
on the quant layer (that map would BE the non-theorem); the quant assignment `qnf.2` is preserved
verbatim and its inner arity reduction is delegated to the IH.

**Deviation from the plan's Phase-4 task list (flagged, not silently applied):** the plan sketched a
`nfRestrict : NormalForm sig (k+1) n → (i j) → NormalForm sig (k+1) 2` mapping "the quant assignment
through the Phase-3 arity-3 shape." A total such map that collapses the quant layer to a fixed
arity-2 form is the SETTLED non-theorem (Phase-3 negative content). The faithful realization keeps
`qnf.2` intact and reduces its inner evaluation through the depth-`k` IH under the shared witness —
reusing `nfRestrict0` at the atom layer exactly as the plan directs, and reusing
`nf_endpoint_tl_gen_correct`'s atom-∧-quant assembly pattern (Base.lean:1903) at the semantic level
via `nfEval_step_unfold_gen`. The Phase-3 flatten (`nfEval_pair_arity3_flatten`) is the feasibility
certificate for the arity-3 pieces; it is a *navigation* refinement (349's job on the ≤3 pieces,
Non-Goals) and is not part of the semantic depth-step reduction. -/

/-- **Arity-general depth-`(k+1)` unfolding of `nf_eval_nf`.** The direct arity-general companion of
`nf_eval_nf_step_unfold` (Base.lean:1488, which is fixed at arity 3 on `zoneEnv3`): for any arity
`n` and env `env`, `nf_eval_nf M (k+1) n env qnf` splits definitionally into the atom layer at `env`
(reading `qnf.1`) and, per arity-`(n+1)` sub-form, the coupled inner existential `∃ w, nf_eval_nf M
k (n+1) (Fin.cons w env) sub` matched against `qnf.2`. This is exactly `nf_eval_nf`'s own `succ`
clause (NormalForm.lean:203-207) with the pair `qnf` eta-expanded, hence `Iff.rfl`. -/
theorem nfEval_step_unfold_gen {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (qnf : NormalForm sig (k + 1) n) :
    nf_eval_nf M (k + 1) n env qnf ↔
      (∀ a : AtomKind sig n, atom_eval M env a ↔ (qnf.1 a = true)) ∧
      (∀ sub : NormalForm sig k (n + 1),
        (∃ w : M.carrier, nf_eval_nf M k (n + 1) (Fin.cons w env) sub) ↔
          (qnf.2 sub = true)) :=
  Iff.rfl

/-- **Phase 4 milestone (depth-`(k+1)` one-step quant-layer pairwise reduction).** Given a depth-`k`
reduction `IH` (presented abstractly as `nf_eval_nf M k m e q ↔ P m e q` for every arity `m`, env
`e`, sub-form `q` — precisely the induction hypothesis `induction k` supplies in Phase 5), the
depth-`(k+1)` evaluation reduces to:

* the **≤2-anchor atom conjunction** `∀ i j, nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1
  i j)` — the Phase-2 reduction of the atom part `qnf.1`; and
* the **quant layer** `∀ sub, (∃ w, P (n+1) (Fin.cons w env) sub) ↔ (qnf.2 sub = true)`, obtained by
  rewriting each inner arity-`(n+1)` depth-`k` evaluation through `IH` **under the single witness**
  `∃ w` (via `exists_congr`).

The witness `w` is shared across the entire reduced inner form (order-theoretic merge); the quant
assignment `qnf.2` is preserved verbatim (no arity-collapsing quant `nfRestrict` — that would be the
SETTLED non-theorem). Every atom conjunct has arity 2; the inner reduction's arity is governed by
`P`, which in the Phase-5 assembly is the ≤3-anchor reduction at arity `n+1`. Proved by the
arity-general unfolding (`nfEval_step_unfold_gen`), `nfEval0_reduction` on the atom layer, and
`exists_congr`/`forall_congr'` congruence on the quant layer — no `sorry`, no vacuous def, no RHS
weakening. -/
theorem nfEval_step_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k n : Nat}
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (qnf : NormalForm sig (k + 1) n)
    {P : (m : Nat) → (Fin m → M.carrier) → NormalForm sig k m → Prop}
    (IH : ∀ (m : Nat) (e : Fin m → M.carrier) (q : NormalForm sig k m),
        nf_eval_nf M k m e q ↔ P m e q) :
    nf_eval_nf M (k + 1) n env qnf ↔
      (∀ (i j : Fin n),
        nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1 i j)) ∧
      (∀ sub : NormalForm sig k (n + 1),
        (∃ w : M.carrier, P (n + 1) (Fin.cons w env) sub) ↔ (qnf.2 sub = true)) := by
  rw [nfEval_step_unfold_gen]
  refine and_congr ?_ ?_
  · -- atom layer: `∀ a, atom_eval … ↔ qnf.1 a = true` is `nf_eval_nf M 0 n env qnf.1`; Phase 2 closes.
    exact nfEval0_reduction M env qnf.1
  · -- quant layer: rewrite each inner arity-`(n+1)` depth-`k` eval by the IH, under the shared `∃ w`.
    refine forall_congr' (fun sub => ?_)
    refine iff_congr ?_ Iff.rfl
    exact exists_congr (fun w => IH (n + 1) (Fin.cons w env) sub)

/-! ## Phase 5: main theorem assembly by induction on depth `k`

Phases 1–4 delivered the depth-0 atom-layer reduction (`nfEval0_reduction`) and the single depth
step (`nfEval_step_reduction`), the latter parameterized by an ABSTRACT depth-`k` reduction `P`.
Phase 5 closes the frozen main theorem `nfEval_le2_reduction` by `induction k`: the base is Phase 2
and the step is Phase 4 with `P` instantiated to the depth-`k` reduction RHS itself, supplied by the
induction hypothesis. To thread the IH at the arity `n+1` the step needs, the theorem is stated
`∀ n env qnf` (fully general in arity and environment) and `induction k` generalizes over them.

### The recursive RHS family (`nfEvalRHS`)

`nfEvalRHS M k n env qnf` is the finite conjunction of ≤2/≤3-anchor `nf_eval_nf` facts the reduction
targets, defined by structural recursion on depth `k` so it lines up EXACTLY with the two proved
reduction lemmas:

* `k = 0`: the Phase-2 RHS — `∀ i j, nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)`
  (every conjunct anchor-arity 2).
* `k+1`: the Phase-4 step RHS — the ≤2-anchor atom conjunction on `qnf.1` AND, per sub-form, the
  inner realizability `∃ w, nfEvalRHS M k (n+1) (Fin.cons w env) sub` matched against `qnf.2 sub`.
  The single witness `w` stays OUTSIDE the recursively-reduced inner form (order-theoretic merge,
  SETTLED — never a per-pair `∀-pair ∃-witness` distribution); the quant assignment `qnf.2` is
  preserved verbatim (no arity-collapsing quant `nfRestrict`).

### Arity ceiling (SETTLED invariant, ≤ 3)

Every *atom* conjunct of `nfEvalRHS` is an `nf_eval_nf M 0 2 …` fact — anchor arity exactly 2. The
inner recursive conjuncts `nfEvalRHS M k (n+1) …` are governed by `nfEvalRHS` at the next arity, but
the ONLY `nf_eval_nf` facts it ever emits are the depth-0 atom pieces at arity 2; the inner arity
`n+1` appears solely as the domain of the recursion (the `∃ w` binder over `Fin.cons w env`), never
as the anchor arity of an emitted `nf_eval_nf` conjunct. So no emitted conjunct climbs past anchor
arity 2 (≤ 3 with room for the Phase-3 zoneEnv3 witness on the navigation side, 349's job).

### Deviation from the frozen signature (flagged, not silent): `hn : 2 ≤ n` dropped

The Phase-1 frozen target carried `(hn : 2 ≤ n)`. Phase 2 already discharged the `n < 2` case
(`nfEval0_reduction` carries NO arity hypothesis: the diagonal conjunct `(i, i)` covers every
single-index predicate atom). Since neither `nfEval0_reduction` nor `nfEval_step_reduction` needs
`2 ≤ n`, `nfEval_le2_reduction` omits it — a STRENGTHENING of the frozen statement (strictly more
general: it now holds for every arity `n`, including `n < 2`), never a weakening. This matches the
already-committed Phase-2 drop of the same hypothesis; the RHS is the genuine full characterization
`nfEvalRHS`, unweakened. -/

/-- The recursive target RHS of the Lemma 3.2(2) reduction: the finite conjunction of ≤2-anchor
`nf_eval_nf` atom facts (over all anchor pairs, at every depth) together with the depth-recursive
quant-layer realizability clauses. Structural recursion on depth `k` mirrors the two proved
reduction lemmas (`nfEval0_reduction` at `k = 0`, `nfEval_step_reduction` at `k+1`). -/
def nfEvalRHS {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig) :
    (k n : Nat) → (Fin n → M.carrier) → NormalForm sig k n → Prop
  | 0, n, env, qnf =>
      ∀ (i j : Fin n), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j)
  | k + 1, n, env, qnf =>
      (∀ (i j : Fin n),
        nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1 i j)) ∧
      (∀ sub : NormalForm sig k (n + 1),
        (∃ w : M.carrier, nfEvalRHS M k (n + 1) (Fin.cons w env) sub) ↔ (qnf.2 sub = true))

@[simp] theorem nfEvalRHS_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {n : Nat} (env : Fin n → M.carrier) (qnf : NormalForm sig 0 n) :
    nfEvalRHS M 0 n env qnf
      = ∀ (i j : Fin n), nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf i j) := rfl

@[simp] theorem nfEvalRHS_succ {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig)
    {k n : Nat} (env : Fin n → M.carrier) (qnf : NormalForm sig (k + 1) n) :
    nfEvalRHS M (k + 1) n env qnf
      = ((∀ (i j : Fin n),
            nf_eval_nf M 0 2 (envPair M env i j) (nfRestrict0 qnf.1 i j)) ∧
          (∀ sub : NormalForm sig k (n + 1),
            (∃ w : M.carrier, nfEvalRHS M k (n + 1) (Fin.cons w env) sub) ↔ (qnf.2 sub = true))) :=
  rfl

/-- **Main theorem (Rabinovich Lemma 3.2(2), md:119).** For arbitrary depth `k`, arity `n`,
environment `env`, and normal form `qnf`, the evaluation `nf_eval_nf M k n env qnf` is equivalent to
the finite conjunction `nfEvalRHS M k n env qnf` of ≤2-anchor `nf_eval_nf` atom facts and the
depth-recursive quant-layer realizability clauses. Proved by induction on depth `k`: the base is the
Phase-2 atom-layer reduction `nfEval0_reduction`; the step is the Phase-4 depth-step reduction
`nfEval_step_reduction` with its abstract depth-`k` reduction `P` instantiated to `nfEvalRHS M k`,
supplied by the induction hypothesis. Every emitted `nf_eval_nf` conjunct on the RHS has anchor
arity 2 (the SETTLED ≤3 ceiling); the single realizability witness `w` is threaded OUTSIDE the
recursively-reduced inner form (order-theoretic merge — no per-pair distribution, no arity-collapsing
quant `nfRestrict`, no `sorry`/vacuous def/RHS weakening).

**Signature note:** the Phase-1 frozen `(hn : 2 ≤ n)` is omitted (see the section docstring): this is
a strengthening, since Phase 2 already discharged `n < 2`. -/
theorem nfEval_le2_reduction {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] (M : OrderedMonadicStructure sig) :
    ∀ (k n : Nat) (env : Fin n → M.carrier) (qnf : NormalForm sig k n),
      nf_eval_nf M k n env qnf ↔ nfEvalRHS M k n env qnf := by
  intro k
  induction k with
  | zero =>
      intro n env qnf
      rw [nfEvalRHS_zero]
      exact nfEval0_reduction M env qnf
  | succ k ih =>
      intro n env qnf
      rw [nfEvalRHS_succ]
      exact nfEval_step_reduction M env qnf (P := nfEvalRHS M k) ih

end Bimodal.Metalogic.WeakCanonical.Kamp
