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
