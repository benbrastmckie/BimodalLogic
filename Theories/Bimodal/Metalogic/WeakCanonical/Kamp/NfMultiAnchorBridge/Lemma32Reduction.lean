import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base

/-!
# Rabinovich Lemma 3.2(2) — the ≤2-free-variable reduction for `nf_eval_nf`

This module builds the faithful exit from the task-349 multi-anchor blocker: a
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

The faithfulness audit (task 349, report 02, §Q4 target 4) and the spawn analysis (report 03)
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

The following are PROHIBITED in this module (they are the refuted task-349 failure modes):

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
theorem nfEval_le2_reduction {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    {k n : Nat} (hn : 2 ≤ n) (env : Fin n → M.carrier) (qnf : NormalForm sig k n) :
    nf_eval_nf M k n env qnf ↔
      (finite conjunction of `nf_eval_nf M k n' _ _` facts, each with anchor arity `n' ≤ 3`)
```

Every conjunct on the RHS is an `nf_eval_nf` fact of anchor arity ≤ 3: `n' ≤ 2` for pure anchor
pairs, `n' = 3` for two anchors plus one existential witness (`zoneEnv3`-shaped). Nothing climbs
to `n+1` distinct free anchors. The depth-0 instance (`k = 0`) is proved green below as
`nfEval0_pairwise`; the depth step and assembly are Phases 3–5.
-/

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
def envPair {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) (i j : Fin n) : Fin 2 → M.carrier :=
  fun k => env (pairSel i j k)

/-- Embed an arity-2 atom into the arity-`n` atom layer along the anchor pair `(i, j)`
(`hij : i ≠ j` supplies the distinctness proof for the order atom). Position `0 ↦ i`,
position `1 ↦ j`. -/
def pairEmbed {sig : MonadicSignature} {n : Nat} (i j : Fin n) (hij : i ≠ j) :
    AtomKind sig 2 → AtomKind sig n
  | .pred p k => .pred p (pairSel i j k)
  | .order k l h => .order (pairSel i j k) (pairSel i j l) (pairSel_ne hij h)

/-- Restrict a depth-0 normal form to the anchor pair `(i, j)`: the arity-2 atom assignment
`a ↦ qnf (pairEmbed i j hij a)`. -/
def nfRestrictPair {sig : MonadicSignature} {n : Nat} (qnf : NormalForm sig 0 n)
    (i j : Fin n) (hij : i ≠ j) : NormalForm sig 0 2 :=
  fun a => qnf (pairEmbed i j hij a)

/-- Evaluating a restricted atom on the restricted arity-2 environment agrees with evaluating
the embedded atom on the full environment. Definitional up to the atom constructor. -/
theorem atom_eval_pairEmbed {sig : MonadicSignature} {n : Nat}
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
theorem nfEval0_pairwise {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
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

end Bimodal.Metalogic.WeakCanonical.Kamp
