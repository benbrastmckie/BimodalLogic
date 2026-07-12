# Task 349 v7 Phase 2 — Dispatch Summary (BLOCKED, determinacy core landed)

**Session**: sess_1783880791_cb6149 (hard-mode single-phase dispatch, phase_number=2)
**Status**: Phase 2 `[BLOCKED]` (design-level); design-invariant determinacy core landed GREEN
**Commits**: 34a173e88 (phase 2.1), af794abcb (phase 2.2), c4c5c7eb1 (phase 2.3)

## What was executed

Phase 2 of plan v7 (`plans/07_enriched-bracket-carrier.md`): the `k`-generalized per-side
exterior brackets. The four bracket lemmas in the prescribed shape are blocked (see below);
the shared determinacy foundation was landed in the NEW module
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketK.lean`.

## Theorems/defs landed (all green, sorry-free, axioms exactly [propext, Classical.choice, Quot.sound])

| Decl | Content |
|------|---------|
| `nfk_truncD` / `nfk_truncD_atom` | one-layer depth truncation `NormalForm sig (k+1) n → NormalForm sig k n`, full-arity fiber-existential (G1) |
| `nf_eval_truncD` | ONE-DIRECTIONAL truncation soundness (`nf_eval_unique M k` determinacy at every layer) |
| `nf_eval_take` / `nf_eval_projFresh` | depth-GENERAL prefix-restriction soundness for `nfk_take`/`nfk_projFresh` (symbolic-`k` generalization of the depth-1-only `kvE2_sepProjFresh_eval`, SharedWitness.lean:7297) |
| `kvE_sepPos` / `kvE_sepPos_mem` | positive subs of a depth-`(k+2)` arity-3 qnf |
| `kvE_projFreshD` / `nf_eval_projFreshD` | depth-`k` fresh shadow of a depth-`(k+1)` sub + realization soundness |
| `kvE_futAnyBit` | depth-`k` zone-fact bit at `χ : NormalForm sig k 1` |
| `kvE_futAnyBit_correct` | **the depth-`k` `habove`/`hbelow` pin** — honest under realized qnf, in the plan's exact prescribed `NormalForm sig k 1` / `nf_eval_nf M k 1` shape |
| `kvE_subBit` / `kvE_subBit_iff` | fiber-existential full-arity fold read of a depth-`(k+1)` sub's quant layer, consuming Phase-1's `nf_eval_nfk_iff_efold` |
| `kvE_projFreshD_zero` / `kvE_futAnyBit_zero` + recovery `example` | k=2-rung agreement with the frozen `kvE2_futAnyBit`/`kvE2_futAnyBit_correct` (plan's sanity task, for the landed decls) |

## Blocker (four-element record; full text in the plan's Phase-2 BLOCKER block)

The four bracket lemmas `kvE_extBracketPast/Fut_sound`/`_complete` in the prescribed
byte-identical-statement shape are not provable by any bracket formula constructible in the
prescribed leaf module (imports ExteriorBracket + NfEFold, 300-500 line budget):

1. The frozen clause layer (ExteriorNegation/-Past) is depth-hardwired: every `σ.2` read goes
   through `nf0_assemble`'s coordinatization, lossless ONLY at depth-0 subs (NfEFold.lean:549-561),
   with `σ : NormalForm sig 1 4` fixed.
2. A truncation-shadow bracket provably cannot satisfy both lemmas: an F2-style pair
   (bit-false σ / positive σ'' with equal depth-1 truncations, differing on a joint-coupled
   depth-`k` sub — the `f2_sub_proj_eq` pattern, RefutationF2.lean:471) breaks `_complete`
   under a full-bit clause selector and `_sound` under a shadow-bit selector.
3. The faithful Rabinovich Def-7.5 rung-`(k+1)` bracket consumes rung-`k` formulas from the
   recursion (report 10 adversarial §2) — an `ExistProviders` channel (PriorInterface.lean:38)
   and/or the Phase-3 carrier; a depth-`k` clause-layer rebuild is ExteriorNegation-scale
   (~2000+ lines), 5-10x the phase budget.

**Resolutions for adjudication** (all consume the landed core unchanged): (a) re-scope Phase 2
with a `P : ExistProviders` parameter + multi-dispatch clause-layer sub-plan; (b) build the
brackets inside the recursion (mutual with `endIntervalStep`); (c) weaken the statements with
an explicit joint-depth-content hypothesis dischargeable by Phase 4. Recommend `/spawn 349`.

## Fix-forward (out-of-file, in-task)

Latent Phase-1 regression repaired: `nf_eval_atom_layer` (added to NfEFold.lean in Phase 1)
collided with the pre-existing `NfZoneDepthK.lean:190` export of the same fully-qualified
name, breaking `Base.lean` and the entire NfMultiAnchorBridge import chain (Phase 1's
NfEFold-scoped build could not see it). Renamed the Phase-1 addition to
`nf_eval_nf_atom_layer` (NfEFold.lean only, 2 sites; commit 34a173e88).

## Verification

- Scoped build `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK`: GREEN (1019 jobs)
- sorries: 0; vacuous defs: 0; new axioms: 0; FORBIDDEN grep: clean
- `lean_verify` on `kvE_futAnyBit_correct`, `kvE_subBit_iff`, `nf_eval_truncD`: exactly `[propext, Classical.choice, Quot.sound]`
- `git diff` on all 7 frozen providers + KampPrior + Lemma32Reduction: EMPTY

## Plan deviations

Recorded inline in the plan's Phase-2 checklist: bracket-builder and `_sound`/`_complete`
tasks blocked; sanity + route-audit tasks completed for the landed scope (altered).
