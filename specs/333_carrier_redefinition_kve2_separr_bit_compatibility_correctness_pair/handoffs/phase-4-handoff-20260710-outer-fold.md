# Task 333 — Phase 4 Handoff (kvE2_outer_fold COMPLETED — final phase)

- **Dispatch**: sess_1783679696_817168, lean-implementation-hard-agent, phase_number=4
- **Date**: 2026-07-10
- **Status**: Phase 4 [COMPLETED] — green + axiom-clean, committed `9370893b1`. Task 333's
  plan (all 4 phases) is complete.

## Immediate Next Action

Task 333 is implementation-complete. Next lifecycle step is downstream: task 335 closes the
OuterGate ⇒ half (R5) by wrapping `kvE2_outer_fold`. **Interface notice for 335 (read
before dispatching)**: in addition to the two anticipated per-class gate families
(`hgateL`/`hgateR`, verbatim `kvE2_sepBody_kit_sound` shapes), the fold threads TWO further
Amendment-F3 residual families that 335 (or a successor provider-strengthening task) must
discharge at the `charK := P.existF 0` instantiation:

- `hbdry` — realization of the five NON-interior positive placement classes
  (`zPastX3`/`zAtX3`/`zAtW3`/`zAtT3`/`zFutT3`): carrier content rides the σ-level `charK`
  E[Σ]-atom literals of `kvE2_sepEpL`/`kvE2_sepPtW`/`kvE2_sepEpR`; typing them into arity-4
  depth-1 evaluations is the `ExistProviders.correct` step (c) of the NavigatedSpine:445
  sketch.
- `hexcl` — the outer forward/exclusion clause (negative subs unrealized): the depth-2
  carrier pins per-σ content only up to (outer zone, projected 1-type) — machine-checked by
  `bracketEndChar_kv_factors` (`CarrierKv.lean:422`) — so this clause is provider-conditional
  in exactly the A1 sense (`PriorInterface.lean:47-59`). If 335 cannot discharge it from
  UZ/SZ + provider correctness, the faithful move is to strengthen the PROVIDER interface
  (A1 conditionality), never the carrier filter.

## Current State

- Phases 1, 2, 3, 4 of 4 [COMPLETED]. `lake build` FULL project green (1720 jobs);
  scoped `…SharedWitness` green (1013 jobs); downstream `…OuterGate` green (1014 jobs).
- Commit this dispatch: `9370893b1` (phase 4, `kvE2_outer_fold`).
- `kvE2_outer_fold` (tail of `SharedWitness.lean`): `lean_verify` =
  `["propext","Classical.choice","Quot.sound"]`, no `sorryAx`, no warnings.
- Statement shape (the 335 contract surface): from
  `(kvE2_sepBody (nf_depth0_char_formula …) charK qnf).holds M atomMap x t`, the six
  `BracketCarrierCorrectVPrior` order-bit hypotheses on `qnf.1`, `hgateL`, `hgateR`,
  `hbdry`, `hexcl` (all four families quantified over the pivot `w` with
  `x < w → w < t → ptW.eval_at w →` heads), conclude
  `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` — the
  `BracketCarrierCorrectVPrior` ⇒-RHS verbatim.
- Derived inside the proof (never assumed): pivot + bounds via `kvE2_sepBody_kit_sound`;
  full outer atom layer (predicate bits from the three head point-type conjuncts of
  `kvE2_sepPtW`/`kvE2_sepEpL`/`kvE2_sepEpR` via `formula_conjList_iff` + `nfPred_correct`;
  order bits from `x<w<t` + the six hypotheses); positive-sub membership/zone
  classification; interior-class realizations via the Phase-3 kit.

## Key Decisions

1. **Residual families threaded, not fabricated and not blocked.** The alternative readings
   were (a) BLOCK claiming "no viable fold route" or (b) attempt to derive `hbdry`/`hexcl`
   from `.holds`. (b) is refuted by the landed information-loss record
   (`bracketEndChar_kv_factors`): the carrier's σ-level channels compress to
   (zone, projected 1-type), so the exclusion clause is genuinely provider-conditional.
   (a) is wrong because a viable route exists — the same F3 threading the plan itself uses
   for the gate families (`kit_sound`), grounded in the A1 provider-conditionality note in
   `PriorInterface.lean`. The conclusion is NOT weakened; the hypothesis surface is explicit
   and named.
2. **Atom layer derived from the carrier's own point types** rather than threaded — the
   Def 3.1 (p.4) point-type channel: head conjuncts of ptW/EpL/EpR realize
   `kvE2_sepProj3 qnf.1 k` at `w`/`x`/`t` respectively.
3. **Statement stays charK-generic** (no `hck`, no `ExistProviders` bundle parameter), so
   335 instantiates `charK := P.existF 0` and owns all provider-typing steps.

## Verification Record

- Territory census (`lean-sorry-census.sh` on `NfMultiAnchorBridge/`): **sorry_count 0**.
- Live-sorry grep on `SharedWitness.lean`: 0 (3 prose hits, pre-existing).
- LITMUS: **0 hits in added lines; zero-delta full-file** (19 pre-existing prose hits).
- Vacuous defs in diff: 0 (repo's 1 hit is pre-existing, `Examples/TemporalStructures.lean`).
- New axioms: 0. New `md:NN` citations: 0 (docstrings cite PDF pages).
- Diff scope: Lean diff touches ONLY `SharedWitness.lean` (+187 lines); `OuterGate.lean`,
  `NavigatedSpine.lean`, `NfEFold.lean`, `SubBracket2V.lean`, carrier structure
  byte-identical.
- No-nesting / L-R confinement: no new point types or slot lists introduced (consume-only
  assembly).

## Sorry Inventory

(empty — no sorries anywhere on the territory module)

## References

- Plan: `plans/06_route-a-grouped-extraction.md` (Phase 4 marked [COMPLETED] with per-task
  deviation annotations — see task 2's annotation for the full residual-family rationale)
- Consumer coordination: `OuterGate.lean:172-201` (335's stale BLOCKED record — doubly
  stale per report 03 §C.5; updating it is 335's file scope, not 333's)
- Grounding: `bracketEndChar_kv_factors` (`CarrierKv.lean:422`),
  `BracketCarrierCorrectVPrior` + A1 note (`PriorInterface.lean:47-73`),
  NavigatedSpine RESCOPE record (`NavigatedSpine.lean:385-449`)
