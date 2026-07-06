# Task 305 — Plan v39 Implementation Summary

Plan: `plans/39_direct-nf-construction.md`. Session: `sess_1783306400_33dd64` (hard mode, `--lit`).
This session dispatched **Phase 10 ONLY** (budget-constrained; session PAUSES after).

## Phase 10 — mergeNF_succ_quant (diagonal quant-layer collapse, x=t arm) — [PARTIAL]

### Landed (sorry-free, off live path)

- **`renameNF_eval_diag0`** in
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfDepth0Generalized.lean` (~48 lines):
  the **depth-0** value-duplication (diagonal) congruence
  `nf_eval_nf M 0 a E (renameNF r f nf) ↔ nf_eval_nf M 0 b e nf`, requiring value-compatibility
  `hcomp` (`e = E∘f`), `hcomp2` (`E = e∘r`), and the retraction `hsec2` (`r∘f = id`) plus `M.lt`
  irreflexivity — deliberately dropping the `hsec` (`f∘r = id`) that the non-injective merge
  (`skipFin`/`totalUnskip`) violates. Verified `[propext, Classical.choice, Quot.sound]`, no
  `sorryAx`. This is the reusable atom-layer transfer and the `k = 0` base case for the x=t arm.

### Blocked (NON-theorem at depth k ≥ 1)

The depth-`k+1` lift (`mergeNF_succ_quant` / the full x=t arm iff) is a genuine **non-theorem**,
not merely a hard proof. Two routes were tried and refuted:

1. **Plain top-level iff** `nf_eval (k+1) 2 [t,t] sub_nf ↔ nf_eval (k+1) 1 [t] (mergeNF_succ sub_nf 0 0)`:
   the arity-2 atom layer constrains BOTH positions against `M(t)`; the merged arity-1 layer only
   position 1. So `.mpr` fails whenever `sub_nf`'s pred rows at positions 0,1 disagree.
2. **`renameNF_eval_diag` congruence** (evaluate the *duplicated* form on the bigger diagonal env):
   the `→` half of its quant layer is provable (round-trip
   `renameNF (liftIdx f)(liftIdx r)(renameNF (liftIdx r)(liftIdx f) g) = g` via `skipFin`/`liftIdx f`
   injectivity + IH), but the `←` half is a genuine non-theorem. The quant layer of the duplicated
   form ranges over ALL `sub_nf : NF K (a+1)`; the collapse-then-expand via the **non-injective**
   `liftIdx (totalUnskip …)` cannot recover a non-diagonal-invariant `sub_nf`, which is unrealizable
   on the diagonal env (`∃ x …` false) while `nq` of its collapse can be `true`.

**Root cause**: this is exactly the **realizability structure** that Phase 11 (the depth-`k`
two-anchor zone converter / characteristic-NF machinery) is designed to supply. Report-39's
Phase-8a scoping — "x=t collapse is self-contained, before Phase 11" — holds only at depth 0; at
depth `k ≥ 1` the x=t arm is **NOT separable** from the Phase-11 crux.

The exact stuck `lean_goal` state and the full analysis are recorded inline in the plan Phase 10
`[PARTIAL]` block and in a doc-comment divergence note in `NfDepth0Generalized.lean` (after
`renameNF_eval_diag0`).

## Verification (this dispatch)

- `lake build` — **GREEN, 1700 jobs**.
- Live-path sorry count **UNCHANGED at 2** (`KampPrior.lean:391`, `:394`); no sorry added on any path.
- `renameNF_eval_diag0` → `lean_verify` axioms `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- Zero new top-level `axiom` declarations.
- No `VecEA_m.holds`-wiring, per-model bridge, uniform Prop 4.2/4.3, De Morgan restructure, or
  NF-depth/arity-tower reintroduction; `KampPrior.lean` untouched (x=t arm fully off the live path).

## Recommendation for resumption (`/orchestrate 305 --hard`)

- **Re-scope**: fold Phase 10's remaining content into Phase 11 — they share one inductive crux
  (depth-`k` realizability). Build the Phase-11 characteristic-NF / zone machinery first; the x=t
  arm then follows (a `mergeNF_succ char[t,t] = char[t]` collapse restricted to realizable forms),
  or add a compile-time diagonal-consistency guard on `sub_nf` in the Phase-14 assembly.
- `renameNF_eval_diag0` is a preserved reusable asset (depth-0 base + atom transfer).
