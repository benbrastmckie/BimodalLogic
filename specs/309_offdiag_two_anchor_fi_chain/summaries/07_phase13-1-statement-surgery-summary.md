# Task 309 Phase 13.1 Summary — Statement surgery: `ExistProviders` + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts

**Date**: 2026-07-06 | **Session**: sess_1783391112_643ec1 | **Commit**: `1a11acf6f`
**Plan**: `plans/06_offdiag-fi-chain-plan.md` Phase 13.1 (single-phase hard-mode dispatch,
full-ladder branch after the 13.0 F2 CONFIRMED verdict)

## Phase Executed

Phase 13.1 only (per dispatch contract). Plan headings now 12 of 16 complete
(1-5, 6.1, 9-12, 13.0, 13.1; remaining: 13.2, 13.3, 13.4, 14).

## Deliverables (all in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`, additive)

| Deliverable | Line | Content |
|---|---|---|
| Import edge | :4 (+NOTE :6-12) | `import …Kamp.EANegationClosure` — **LANDED cycle-free** (compile-verified; the explicit-Props fallback was NOT needed). Supplies PriorINF + negation-stack assets for 13.2-13.4 |
| Section doc-block | :4831 | A1 amendment citation (report 05 §d) + rule-N1 citation split |
| `structure ExistProviders` | :4853 | Provider bundle, exact report-05 Pillar 1 signature: `existF : (n : Nat) → NormalForm sig k (n+1) → Formula` + UZ/SZ-conditional `correct` (↔ against `nf_eval_nf` over `insertEnv`) |
| `def BracketCarrierCorrectVPrior` | :4875 | UZ/SZ-relativized correctness predicate over `qnf : NormalForm sig k 3` with the six bracket-zone order hypotheses in k0-mirror form, stated uniformly via `NormalForm.atom_assgn` |
| `bracketEndChar_kv_correct_zero_prior` | :4895 | k=0 relativized lift — drop-hypotheses term-mode delegation to the landed `bracketEndChar_kv_correct_zero` |
| `bracketEndChar_kv_correct_one_prior` | :4910 | k=1 relativized lift — same, delegating to `bracketEndChar_kv_correct_one` (retains the depth-0 provider agreement `h0`) |

## Final Verification Results

- `lake build` full tree: **GREEN** (1709 jobs); scoped Bridge build GREEN (1005 jobs).
- New sorries: **0** (sorry census cross-check run; compiler count 30 / stripper 163 is the
  pre-existing Boneyard-dominated baseline, unchanged; live-path baseline stays exactly
  KampPrior:351/:354 + out-of-scope EANegation:1090/:1249).
- `lean_verify` on both `_prior` lifts: exactly `[propext, Classical.choice, Quot.sound]`.
- Vacuous definitions introduced: 0 (the single repo-wide grep hit is pre-existing,
  `Examples/TemporalStructures.lean:269`). New axioms: 0.
- Preserved assets: byte-identical — `git diff` for Theories in this dispatch is 97 insertions,
  0 deletions, confined to NfMultiAnchorBridge.lean.

## Plan Deviations

1. **Binder concretization (plan-anticipated, documented)**: the plan left the six order
   hypotheses' depth-generic form as "(k0-mirror :1581-1594 shape)"; realized via
   `NormalForm.atom_assgn` (NormalForm:151), definitionally `qnf` at k=0 and `qnf.1` at k+1,
   which makes both lifts pure term applications of the landed lemmas. No other binder deviation.
2. **Cosmetic lint accepted**: keeping the plan-normative binder names `h_UZ`/`h_SZ` in the
   predicate produces two `unusedVariables` warnings (:4884-4885); accepted to keep the
   report-05 signature verbatim.
3. The 13.0 direct `PriorDefs` import is retained alongside the new transitive supply
   (additive-only discipline; redundant but harmless).

## Sorry Inventory

Unchanged (no new): KampPrior:351 (strategic — Phase 14 target), KampPrior:354 (task 305).

## Next

Phase 13.2 (`bracketEndChar_kvE` per-sub enriched carrier + concrete k=2 instance). Entry
points and guards: `handoffs/phase-13.1-handoff-20260706.md`.
