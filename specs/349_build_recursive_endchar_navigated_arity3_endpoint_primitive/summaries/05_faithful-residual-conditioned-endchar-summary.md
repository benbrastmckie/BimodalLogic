# Task 349 v5 — Phase 1 Implementation Summary

**Phase:** 1 of 4 — Spec freeze + `endChar` skeleton + base case
**Status:** COMPLETED (green, sorry-free)
**Session:** sess_1783841542_df767b

## Deliverables landed (all in `NavigatedEndChar.lean`, additive)

1. **Frozen spec — `endChar_correct` (report 05 §3.2).** Pinned verbatim in a new "Phase 1 (v5)"
   docstring: the residual-conditioned, **x,t-EXPLICIT** biconditional carrying `h_res` at every `k`.
   The docstring records the FORBIDDEN unconditional world-local form (`endCharN0_correct_infeasible`,
   Base.lean:1779) and WHY `h_res` + x,t-explicitness is the discriminator (report 05 §5.2). Also
   records that v4's `nf_char3_endpoint_tl` / `navPieceForm_correct` converter is DELETED from the
   critical path.

2. **`endChar` recursion skeleton.** `noncomputable def endChar (atomMap) (h_surj) : (k) → EndCharCarrier sig k`
   by `Nat`-recursion: `| 0 => endChar0 atomMap h_surj`, `| (k+1) => endCharStep atomMap h_surj (endChar … k)`.

3. **`endCharStep` scaffold.** Declared with a genuine `TemporalPred`-valued placeholder body
   (`fun qnf => endChar0 atomMap h_surj qnf.1`, the position-0 atom layer). Non-vacuous, not
   proof-carrying — installed only so the recursion and statement elaborate; replaced fix-forward in
   Phase 3 (`_rec` → `rec`).

4. **Base case — `endChar_correct_zero`.** The `k=0` instance of the frozen statement, proved by
   `exact endChar0_correct M atomMap h_surj qnf w x t h_res` (the `Nat`-rec zero branch makes
   `endChar … 0` defeq to `endChar0 …`). This is the base block Phase 4 feeds to induction on `k`.

## Verification

- Scoped `lake build …NavigatedEndChar`: **GREEN** (1009/1009; warnings are pre-existing in
  `CarrierK1V.lean`, not this file).
- `lean_verify endChar_correct_zero` = `[propext, Classical.choice, Quot.sound]`, no warnings, no sorry.
- Route audit: no `nf_char3_deeper_split` / `nfRestrict` / arity-4 collapse / unconditional world-local
  code; the only `navPieceForm_correct` / `sorry` tokens are prose in FORBIDDEN / "sorry-free"
  docstrings. `EndCharCarrier` unchanged (not widened). Base.lean untouched this phase.
- Guards: G1 (arity fixed at 3, closed-Formula read only at base), G2/G4 (anchors ⊆ {x,t}, ≤2; `w`
  bracket witness), G3/G5 (not exercised — no interior/chain steps in Phase 1) all respected.

## Deviation note

The full `∀k` `endChar_correct` **theorem name** is produced in **Phase 4** (by induction on `k`),
not Phase 1: a `∀k` theorem cannot leave its k+1 step a sorry-free hole, so Phase 1 freezes the
statement as a pinned spec and lands the compiled `k=0` building block `endChar_correct_zero`. This
matches the plan (Phase 4: "Prove `endChar_correct` by induction … base = Phase-1 `k=0`").

## Next (Phase 2)

Build the arity-4 → `nfEvalRHS` reduction wiring inside the step (Step A) via `exists_congr` +
`nfEval_le2_reduction` / green `navPiece_reduce` (witness `v` OUTSIDE), before any `Formula`
conversion. Then Phase 3 replaces the `endCharStep` scaffold with the real navigated builder.

---

## Phase 2 (v5) — `endCharStep` Step A: arity-4 → `nfEvalRHS` reduction (REDUCE-FIRST)

**Status: COMPLETED, green, sorry-free.** All additive to `NavigatedEndChar.lean`; `Base.lean` and
every frozen provider untouched.

### Landed (5 theorems)

- `nfEval4_reduction` — arity-4 specialization of task-351 `nfEval_le2_reduction` (mirror of the
  green `nfEval3_reduction`): `nf_eval_nf M k 4 env sub ↔ nfEvalRHS M k 4 env sub`.
- `nfEval4_reduction_zero_shape` / `nfEval4_reduction_succ_shape` — arity confirmations
  (`:= nfEvalRHS_zero` / `:= nfEvalRHS_succ`): every emitted `nf_eval_nf` conjunct of the reduced RHS
  is `nf_eval_nf M 0 2 …` (anchor arity **2**, ≤ 3); the "4"/"5" are the recursion env domains of the
  `∃ w` binder, never emitted anchor arities. No arity climb past 3.
- `endCharStep_reduceA` — the per-`sub` Step-A existential reduction
  `(∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔ (∃ v, nfEvalRHS M k 4 (Fin.cons v (zoneEnv3 w x t)) sub)`,
  proved `:= navPiece_reduce M w x t sub` (consumes the preserved green witness-outside merge; `v`
  stays OUTSIDE). This is the exact `[v,w,x,t]` reduction of report 05 §3.4 Step A.
- `endCharStep_quant_reduceA` — the whole depth-`(k+1)` quant-layer reduction the Phase-3 assembly
  threads: `forall_congr' (fun sub => iff_congr (endCharStep_reduceA …) Iff.rfl)`. Witness `v` OUTSIDE
  each clause; quant assignment `qnf.2` preserved verbatim (no arity-collapsing `nfRestrict`); no
  per-pair `∀ij ∃v` distribution.

### Verification

- Scoped `lake build …NavigatedEndChar`: **GREEN** (1009/1009).
- `lean_verify` on all 5 = `[propext, Classical.choice, Quot.sound]`, no warnings, no sorry.
- Route audit: **no `Formula` converter yet** (Steps B–D are Phase 3); G1 (no arity-1 collapse),
  G2/G4 (`v` existential/OUTSIDE, anchors `{x,t}` EXPLICIT, `v` a bracket witness), G5 (manual
  `exists_congr`/`forall_congr'`/`iff_congr`; `Iff.rfl`/`rfl` on defeq shapes only) respected;
  no `nf_char3_deeper_split`, no arity-4 enclosing-pair collapse, no quant `nfRestrict` (`nfRestrict0`
  only at the atom layer), no `navPieceForm_correct` in code (prose-only). Git scope = this file +
  plan only.

### Next (Phase 3, the feasibility gate)

Replace the `endCharStep` scaffold body with the real navigated builder and prove the k+1 case of
`endChar_correct`. Consume `endCharStep_quant_reduceA` for Step A, then navigate each reduced arity-3
piece via `nf_zone_flatten_navigable_correct` (Step B), ride the interior on `seg`/`seg_holds_coupled`
(Step C), and collapse at the base via `nf3_locus0` (Step D), threading the residual `h_res`
(positions 1,2 pinned) to each sub-piece — the unproven residual-threading obligation.
