# v35 Phase 1 — `mergeNF_succ` attempt 1 (STRIKE 1 of 3; build GREEN preserved)

- **Task**: 305 (lean4, hard mode)
- **Plan**: plans/35_zone-split-gated.md, Phase 1
- **Route**: A (committed in v35-gate-decision.md)
- **Date**: 2026-06-24
- **H6 three-strikes**: this is **strike 1** on the `mergeNF_succ`/`renameNF` leaf.

## Settled design attempted

Build a general precomposition renaming functor `renameNF` on `NormalForm sig k m`
along an index map, then derive `mergeNF_succ` (= `renameNF` along `skipFin j`) and
`merge_forward_succ` (lift the depth-0 `merge_forward` env-duplication through the
quant layer). Descend-only: `renameNF` at depth `k+1` recurses only into depth `k`.

Target shape:
```lean
def renameNF {sig} : {k m m' : Nat} → (g : Fin m → Fin m') → Injective g →
    NormalForm sig k m' → NormalForm sig k m
  | 0,   _, _, g, hg, nf => fun a => match a with
      | .pred p i   => nf (.pred p (g i))
      | .order i j h => nf (.order (g i) (g j) (hg.ne h))
  | k+1, _, _, g, hg, nf =>
      (atom layer: same as depth 0 on nf.1,
       quant layer: fun qnf => nf.2 (renameNF (liftIdx g) (liftIdx_injective hg) qnf))
```
with `liftIdx g := Fin.cases 0 (fun i => (g i).succ)`.

## Precise obstacle (advances Obstacle 2 from v34)

The **quant layer is contravariant** in the position structure, so a single-variance
`renameNF` along an *injection* does not type-check. Concretely:

- `renameNF g : NormalForm sig k m' → NormalForm sig k m` (output index = `dom g = m`).
- At depth `k+1`, `nf.2 : NormalForm sig k (m'+1) → Bool` and the output must be
  `NormalForm sig k (m+1) → Bool`, i.e. `fun qnf : NormalForm sig k (m+1) => nf.2 (φ qnf)`
  where `φ : NormalForm sig k (m+1) → NormalForm sig k (m'+1)`.
- But `renameNF (liftIdx g)` has type `NormalForm sig k (m'+1) → NormalForm sig k (m+1)`
  — the **wrong direction**. (Verified: `lake build` error at the quant arm,
  "Application type mismatch: g : Fin m → Fin m' but expected Fin m' → ...".)

The depth-0 `mergeNF`/`merge_forward` avoid this entirely because depth 0 has **no
quant layer** — there is nothing to push the renaming through. The renaming the quant
layer needs goes `NormalForm sig k (m+1) → NormalForm sig k (m'+1)`, i.e. precomposition
along a map `Fin (m'+1) → Fin (m+1)`. For `g = skipFin j` (an injection that is NOT
surjective) there is no canonical such map from `g` alone.

## Concrete next action (what unblocks the leaf — for strike 2)

Give `renameNF` a **retraction** at the quant layer. Two viable encodings:

1. **Retraction-carrying functor.** Define
   `renameNF (g : Fin m → Fin m') (r : Fin m' → Fin m) (hgr : r ∘ g = id) : ...`
   and at the quant layer recurse with the *retraction* `liftIdx r` so the variance
   matches: `renameNF (liftIdx g) (liftIdx r) ... : NormalForm sig k (m+1) → NormalForm sig k (m'+1)`.
   For the merge use case `g = skipFin j`, the retraction is `unskipFin j` (already in
   NfDepth0Generalized.lean:130 with `skipFin_unskipFin`/`unskipFin_skipFin` proven).
   NOTE: `unskipFin` needs a totalization (it has a `pos ≠ skip` hypothesis); supply a
   default at the dropped position (e.g. map `j ↦ i`, matching the merge's duplication).

2. **Bypass the functor; mirror `merge_forward` directly at `k+1`.** Prove
   `merge_forward_succ` by reusing the depth-0 `full_val` env-duplication and discharging
   the quant clause `∀ qnf, (∃ y, nf_eval_nf M k (m+2) (Fin.cons y (insertEnv env t)) qnf) ↔ …`
   via an *induction on k* lemma relating `nf_eval_nf` under the merged vs. duplicated env
   (the value multiset is unchanged by duplication, so existentials agree). This needs the
   `nf_eval_nf` env-congruence lemma that currently does NOT exist
   (`grep` for nf_eval_nf congruence → none) — it must be built first.

Either path is the genuine new content. Encoding (1) is the smaller, more mechanical leaf
and is the recommended strike-2 attempt: build `renameNF` with retraction + its
`nf_eval_nf` commutation by `induction k`, then specialize to `mergeNF_succ`/`merge_forward_succ`.

## H6 ledger
- Overturns nothing. Sharpens v34 Obstacle 2 from "missing depth-k merge" to the specific
  diagnosis "the quant layer needs a retraction, not just the injection `skipFin j`."
- Forbidden paths (Approach-5 pair-formula, mutual char/exist, k+2 NF-disjunction) NOT touched.
- Descend-only invariant respected in the attempted design (recursion strictly at depth `k`).

## Verification at this boundary
- `lake build`: **GREEN (1700 jobs)** — the failed `renameNF` attempt was fully reverted;
  zero `.lean` files modified (`git status` shows only spec artifacts).
- `lean_verify completeness_discrete`: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]` — unchanged; **no new axioms**.
- Baseline sorries: KampPrior.lean:391, :394 both present (unchanged).
