# v35 Phase 1 — `merge_forward_succ` attempt 3 (STRIKE 3 of 3 — FINAL; build GREEN preserved)

- **Task**: 305 (lean4, hard mode)
- **Plan**: plans/35_zone-split-gated.md, Phase 1
- **Route**: A (committed in v35-gate-decision.md)
- **Date**: 2026-06-24
- **H6 three-strikes**: this is **strike 3** (the cap) on the `mergeNF_succ`/`merge_forward_succ` leaf.
- **Outcome**: the value-duplication route was carried out to a **conclusive negative result**.
  `merge_forward_succ` is **NOT provable as a standalone forward lemma at depth `k+1`**, for two
  independent, now-rigorously-established reasons. Stopped cleanly per H6 (cap reached). Build GREEN;
  baseline unchanged; **two sorry-free reusable assets were landed** (`totalUnskip`, `mergeNF_succ`).

## What was landed (sorry-free, axiom-clean, committed)

Added to `NfDepth0Generalized.lean` (in the build path, GREEN):

1. The full proven `renameNF` infrastructure recovered verbatim from
   `v35-phase-1-strike-2-renameNF-proven.lean.txt`: `liftIdx` (+`_zero/_succ/_comp/_id`),
   `cons_comp_liftIdx`, `renameNF`, `renameNF_roundtrip`, `renameNF_eval_iff` (bidirectional
   congruence, induction on `k`). Sorry-free, axiom-clean. Reusable for **bijective** renamings.
2. `totalUnskip (skip) (keep) : Fin (m+1) → Fin m` — the total retraction of `skipFin` (dropped
   position → `keep`); and `totalUnskip_skipFin` (`r ∘ f = id`). Sorry-free.
3. `mergeNF_succ sub_nf j i' := renameNF (skipFin j) (totalUnskip j i') sub_nf` — the depth-`(k+1)`
   position-merge **definition** (arity `n+2 → n+1`), plus `mergeNF_succ_atom` proving its atom
   layer coincides with the depth-0 `mergeNF` on `sub_nf.1`. Sorry-free, axiom-clean
   (`lean_verify mergeNF_succ_atom` = `[propext, Quot.sound]`).

These are genuine, durable infrastructure — the *definition* of the depth-`(k+1)` merge and its
atom-layer correctness are settled. **What does not exist is its forward correctness lemma.**

## Conclusive obstruction (why `merge_forward_succ` is not a standalone forward lemma)

The depth-`(k+1)` forward conclusion is
`∃ env, nf_eval_nf M (k+1) (n+2) (insertEnv env t) sub_nf`, whose quant layer demands, for the
duplicating env `full_val`,
`∀ qnf : NormalForm k (n+3), (∃ w, nf_eval_nf M k (n+3) (Fin.cons w full_val) qnf) ↔ sub_nf.2 qnf`.

**Obstruction 1 — the env-congruence bridge needs bijectivity (sharpens strikes 1–2).**
To relate the wide existential on `full_val` to the merged hypothesis (narrow existential on
`env'`), one needs a depth-`k` env-congruence
`(∃w eval(cons w full_val, qnf)) ↔ (∃w eval(cons w env', renameNF (liftIdx (skipFin j)) … qnf))`.
This was attempted as `renameNF_eval_dup`. Result: **even one-directionally, even at the env level
(not just the index level), the quant layer cannot close.** The narrow quant assignment is
`nf.2 ∘ renameNF (liftIdx r) (liftIdx f)`; threading the wide `hquant` through it lands on the
**merge-roundtrip** `renameNF (liftIdx r) (liftIdx f) (renameNF (liftIdx f) (liftIdx r) qnf)`,
whose elimination back to `qnf` requires `renameNF_roundtrip` and hence **both** lifted sections
`f∘r = id` AND `r∘f = id`. The merge supplies only `r∘f = id` (`totalUnskip_skipFin`); it violates
`f∘r = id` at the dropped position. The duplication env-compatibility `hcomp2` (`E = e∘r`, which
`full_val` *does* satisfy on all positions) is **not** a substitute for the missing index section
in the quant recursion. So the bijectivity requirement is intrinsic not only to the index-map
congruence (strike 2) but to **any** renaming-mediated bridge, single-direction or bidirectional,
index-level or env-level.

**Obstruction 2 — the quant `←` direction manufactures a model witness from arbitrary data.**
Independently of any bridge: the `←` direction of the conclusion's quant clause
(`sub_nf.2 qnf = true → ∃ w, nf_eval_nf M k (n+3) (Fin.cons w full_val) qnf`) asks to **construct
a carrier witness `w` and a realizing env from an arbitrary `Bool` quantifier assignment
`sub_nf.2`**. With only `h_merged` (merged satisfied) and the atom-level merge-compatibility
`h_pred`/`h_ord`, there is **no hypothesis forcing `sub_nf.2` to be realized by the model `M`**.
Depth 0 has no quant layer, so depth-0 `merge_forward` is true with only `h_pred`/`h_ord`; at depth
`k+1` the forward lemma is **false** for arbitrary `sub_nf` and requires a *quant-merge-compatibility*
(equivalently, `sub_nf` being a characteristic NF of `M` on the duplicated subspace) that the
abstract leaf cannot assume and that no atom-level hypothesis entails.

**Verdict.** The leaf "depth-`k` position merge as a self-contained forward lemma" is the wrong
decomposition. `merge_forward_succ` (as scoped by Phase 1) is **not a theorem**. The x=t-zone
collapse `(y,x,t) → (y,t)` must instead be discharged *in situ* at the consumer
(`KampPrior.lean:391`), where `sub_nf` is the model's characteristic NF (so quant-merge-compatibility
holds by construction) and the existential `←` direction is supplied by the actual model — i.e. via
the assembled 3-way zone formula (Phase 3), not a standalone arity-merge lemma applied blindly.

## H6 ledger (strike 3 = cap)

- Strike 1: single-variance `renameNF` along `skipFin j` — type-check failure (contravariant quant
  layer needs a retraction). Superseded.
- Strike 2: retraction-carrying `renameNF` + bidirectional `renameNF_eval_iff` — proven sorry-free
  but **structurally insufficient** (the congruence needs a bijection; the merge is non-bijective).
- Strike 3 (this): value-duplication route — **negative**. Obstruction 1 closes the env-level
  bridge (any renaming-mediated congruence needs bijectivity); Obstruction 2 shows the quant `←`
  direction is **false** for an abstract `sub_nf`. Net: the Phase-1 leaf as specified is not a
  theorem.
- Forbidden paths (Approach-5 pair-formula, mutual char/exist, k+2 NF-disjunction) NOT touched.
  Descend-only respected. One leaf only; no leaf-switching.

## Required next action (per plan Rollback/Contingency)

Phase 1 has consumed its 3-strike budget with a conclusive verdict that the leaf is mis-specified.
**Re-run the Phase 0 decision gate** (plans/35_zone-split-gated.md §"Rollback/Contingency" and
§"Phase 0"): the new evidence is that **Route A's leaf decomposition is unsound** — the x=t merge
cannot be a standalone arity-reduction lemma. The gate should now weigh:
- **Route A′ (revised zone-split)**: keep the 3-way zone split but discharge the x=t zone *in situ*
  at `KampPrior.lean:391` using the model's characteristic NF (quant-merge-compat free), NOT via a
  standalone `merge_forward_succ`. Re-scope Phase 1 accordingly (the `mergeNF_succ` *definition* and
  `mergeNF_succ_atom` are already landed and reusable; only the forward *correctness* moves to the
  assembled consumer).
- **Route B (re-anchor through `US_expressively_complete_over_Z`)**: the alternative faithful exit
  (Teammate C), which sidesteps the depth-induction merge entirely. The strike-3 result is concrete
  new evidence in B's favor, since A's bulk construction has now hit a non-theorem at its first leaf.

Do **NOT** reopen Approach-5. Do **NOT** retry a fourth `renameNF`/`mergeNF_succ` forward encoding —
both obstructions are mathematical, not tactical.

## Verification at this boundary

- `lake build`: **GREEN (1700 jobs)**.
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete`:
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`
  — **unchanged; no new axioms**.
- Baseline sorries: `KampPrior.lean:391`, `:394` both present (unchanged). No new sorries in the
  build path.
- `lean_verify mergeNF_succ_atom` = `[propext, Quot.sound]` (sorry-free, axiom-clean).
- New top-level `axiom` declarations: **0** (the 2 `^axiom ` grep hits are Boneyard comments).
