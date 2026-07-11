# Task 348 Final Handoff — the enriched gate, for task 309 Phase 14

- **Date**: 2026-07-11
- **Session**: sess_1783796165_b5b482_348
- **Status**: task 348 COMPLETE (8/8 phases). This handoff is the consumption guide for
  task 309 (the KampPrior.lean:351-block retirement, 309 Phase 14).

## What to consume

**`bracketEndChar_kvE2Ext_correct_two_prior_frag`**
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`,
on the live import path via `NfMultiAnchorBridge.lean`):

```
(bracketEndChar_kvE2Ext atomMap h_surj P qnf).holds M atomMap x t ↔
  ∃ w : M.carrier, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

The carrier `bracketEndChar_kvE2Ext atomMap h_surj P : BracketEndCharCarrierV sig 2` is the
landed interior gate `bracketEndChar_kvE2` with the past-side adjacent bracket conjoined at
the LEFT anchor `x` and the future-side one at the RIGHT anchor `t`
(`VVecEA2.enrichEndpoints`; destructure with `bracketEndChar_kvE2Ext_holds_iff`).

## Hypothesis inventory (ALL 309-owned — `hexclExt` is GONE)

| Hypothesis | Shape | 309 Phase-14 discharge route |
|---|---|---|
| `h_xy` … `h_tx` | six qnf order bits (`x < w < t` bracket order) | from the realized/target qnf's atom layer, as at the :351 site |
| `h_UZ` / `h_SZ` | `semantic_prior_UZ/SZ M atomMap` | already carried at the :351 site |
| `hfrag` | `kvE2_sepFragment qnf` (interior-singleton fragment) | the N2 fragment scoping — the ∀k-lift fragment decision is 309's (335 handoff §5 options (a)/(b)) |
| `hrealI` | interior positives realized interval-BOUNDED `x < x1 < t` at the pivot | the Phase-14 provider instantiation (335 handoff §1/§3) |
| `hrealB` | non-interior-marked positives realized (unbounded) | same provider instantiation |
| `hexcl` | bit-false σ excluded on the closed cone `x ≤ x1 ≤ t` | same provider instantiation |

## The R1 transfer (do not re-litigate)

The task-description clause "KampPrior.lean:351 strategic sorry retired" was TRANSFERRED to
309 Phase 14 by the task-348 plan's R1 scope decision (settled; rationale in plan §R1).
The sorry (KampPrior.lean, `| 1 =>` case of `nf_nvar_exist_all_depths`) now carries an
inline transfer note. Retirement = consume the discharge theorem above + discharge the
provider inventory; neither half alone suffices.

## Supporting API (all in ExteriorBracket.lean unless noted)

- `bracketEndChar_kvE2Ext_holds_iff` — degenerate Lemma 7.6 conjunction, exposed.
- `kvE2_extBracketFut_sound/_exists/_complete`, `kvE2_extBracketPast_*` — per-side bracket
  lemmas (pins: `henv`, `hbelow`/`habove`).
- `kvE2_futMarked`/`kvE2_pastMarked` (+ `_iff`, `_of_realizer`) — the syntactic marking.
- `kvE2_exterior_zone_triage` (+ determination lemmas) — `ExteriorZoneTriage.lean`.
- One-sided complement clause families with `_sound`/`_complete`:
  `ExteriorNegation.lean` (future) / `ExteriorNegationPast.lean` (past).
- Pin derivations at a gate-holds site WITHOUT a realized qnf (if 309 needs them):
  `kvE2_extGate_henv` / `kvE2_extGate_anyBit_iff` are `private` in ExteriorBracket.lean —
  mirror or de-private them in a 309 dispatch if the Phase-14 wiring needs the same shapes.

## Verification state at handoff

- Full `lake build` green (1724 jobs); discharge theorem + all consumed lemmas axiom-clean
  (`{propext, Classical.choice, Quot.sound}`).
- Zero sorries in all task-348 files; repo stripper census 163 = pre-348 baseline.
- Frozen territory byte-unchanged (SharedWitness / SubBracket2V / OuterGate /
  ExteriorNegation / ExteriorNegationPast in Phase 8).
