# Implementation Summary: Corrected k=2 Carrier (v6 REDESIGN) — PARTIAL

- **Task**: 321 — Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Plan**: plans/06_corrected-k2-carrier-gate-v6-redesign.md
- **Status**: PARTIAL — Phases 1-6 COMPLETED (sorry-free, additive); Phase 7 BLOCKED on a precise
  missing engine; Phase 8 deferred (requires the closed gate)
- **Session**: sess_1783470318_b10c5a
- **Baseline SHA**: 71b0ea938d86355b22ef786ffb277026c6f05a98
- **HEAD SHA**: cb1631d625934004d0ea640c236e5220dcdd03dd

## Outcome

The v6 navigated / witness-growing route was executed through Phase 6, landing real, sorry-free,
axiom-clean, purely-additive infrastructure (422 insertions, 0 deletions to
`NfMultiAnchorBridge.lean`). The k=2 gate did NOT close. The obstruction is now diagnosed to
machine precision and — critically — is **NOT** a task-327-style NO-GO: the navigated route is
structurally capable; a single well-scoped decomposition lemma plus an assembly engine remain
unbuilt.

## Phases Executed

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 1 | COMPLETED @ c6f2f73 | Baseline snapshot + refuted-infrastructure quarantine note |
| 2 | COMPLETED @ 4a7d130 | `kvE_fold_navigated` — navigated spine (Iff-repackage of landed task-326 `kvE_subBracket2V_correctness_pair`) |
| 3 | COMPLETED @ cec30d8 | `VVecEA2.disjList` + `disjList_holds`, `reflatten_neg_step` (consumes Prop 4.2 `neg_2var_vec_ea`), `reflatten_prop43` (Prop 4.3 re-flatten) |
| 4 | COMPLETED @ 0a4c3db4 | `VVecEA2.holds_flatMap_map` — arrangement-product (S_L × S_R) structural collapse |
| 5 | COMPLETED @ f76a3f1c | 5 non-interior SOUNDNESS dischargers (zPastX/zFutT genuine Since/Until extraction) |
| 6 | COMPLETED @ c45e34ea | 5 non-interior COMPLETENESS dischargers (zPastX/zFutT genuine Since/Until introduction) |
| 7 | BLOCKED @ cb1631d | Gate close attempted twice (assembly + dedicated engine probe); both reverted; inert decision record with captured crux landed |
| 8 | NOT STARTED | F4 ℤ adversarial gate — requires a closed gate; deferred |

## Theorems/Lemmas Landed (16, all sorry-free)

`kvE_fold_navigated`, `VVecEA2.disjList`, `VVecEA2.disjList_holds`, `reflatten_neg_step`,
`reflatten_prop43`, `VVecEA2.holds_flatMap_map`,
`kvE_nonInterior_{zPastX,zFutT,zAtX,zAtT,zAtW}_sound`,
`kvE_nonInterior_{zPastX,zFutT,zAtX,zAtT,zAtW}_complete`.

## The Blocker (Phase 7 — machine-precise)

The k=2 gate `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 …)` cannot be closed from the
landed assets because of a **carrier-shape mismatch**:

- `kvE2_body`'s per-arrangement disjunct is a **single merged bracket**
  `bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR`, where
  `slotsFor l = l.flatMap (fun σ => kvE_subChain2V … σ ++ pinSlots σ)` concatenates **every**
  positive sub's F-chain into one point-type list. Its shared `epL/epR/segL/segR/ptW` literals encode
  **union/existential** zone content `(List.filter qnf.2 …).any (fun σ' => nfk_projFresh σ' = χ)`.
- The task-326 closers (`kvE_subBracket2V_correctness_pair` :8549, `_sound_of_outer` :7910) require
  the **per-sub** bits `σ.2 (nf0_assemble zs χ σ.1)` via their `hgate` hypothesis, and operate on the
  **standalone** carrier `kvE_subBracket2V σ` (explicitly "NOT wired into kvE2_body", :8546-8547).
- The union structure of the merged bracket does not expose the individual sub's bits, so `hgate`
  cannot be discharged — in **both** directions.

**Not a NO-GO.** The per-sub bits are recoverable (σ's own fChainPred is built from
`bits zs χ = σ.2 (nf0_assemble zs χ σ.1)`, :6960); the arity-4 joint content is already carried by
`correctness_pair` via `zoneHolds M [x1,w,x,t] zs v` over `ZoneSpec 4` (the exact content task-327
lacked). The gap is a missing lemma.

## Precise Follow-Up (recommended dedicated task)

1. **`bracketFromLists_slot_decompose`** — from `(bracketFromLists (A ++ chain ++ B) ptW R segL segR).holds x t`,
   isolate the individual sub σ's `kvE_subChain2V` fChainPred fragment realized at its own witness
   slot, independent of the co-spliced slots.
2. **`kvE2_outer_fold`** — compose the decomposition with the task-326 fChainPred readers:
   `kvE2_body.holds ↔ atomLayer ∧ ∀ σ, (∃ x1, nf_eval M 1 4 [x1,w,x,t] σ) ↔ qnf.2 σ`.
3. **Phase-7 gate close** (both directions) then **Phase-8** F4 ℤ adversarial test.

Estimated ~200-500 lines. Phases 1-6 assets are the correct, ready inputs.

## Final Verification

- `sorry_count`: **0** (census `--cross-check` clean; every `sorry` token in the file is prose)
- `vacuous_count`: **0**
- `new_axiom_count`: **0**
- `build_passed`: **true** (full `lake build`, exit 0)
- Additive-only: **422 / 0** (insertions / deletions) vs baseline
- Do-not-edit assets: **byte-identical** (BracketCarrierCorrectVPrior, kvE2_body/bracketEndChar_kvE2
  splice, kvE_subChain2V, task-325/326 lemmas, EANegation, F1-F4 records)
- LITMUS: **clean** — no `x1 < e_i` relative-position literal on any live path; exterior witnesses
  ride `v < x` / `t < v` Since/Until reach
- Axiom-clean: `[propext, Classical.choice, Quot.sound]` on all new symbols

## Plan Deviations

- **Phase 2** delivered at sub granularity (`σ : NormalForm sig 1 4`), an Iff-repackage of the
  pre-existing landed `kvE_subBracket2V_correctness_pair`, rather than the §H5 carrier-level statement.
  The make-or-break question was genuinely answered (the arity-4 content is carried at sub level), but
  the true semantic crux was the outer-fold engine, deferred through every phase.
- **Phase 7** RE-SCOPE fallback (narrow the zones) was found inapplicable: the missing connector is
  upstream of all zones, so zone-narrowing cannot dodge it. Escalated to BLOCKED with a precise,
  well-scoped follow-up rather than churn (H6 convergence policing — two consecutive forks hit the
  same wall).
