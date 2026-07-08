# Task 334 — Phase 1 (make-or-break spike) handoff — GATE: GREEN

- **Session**: sess_1783529677_8c950d (lean-implementation-agent, orchestrator_mode)
- **Plan**: plans/03_faithful-carrier-regrounding.md, Phase 1 → **[COMPLETED]**
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (+104 lines, before the closing `end`)
- **Build**: `lake build …SharedWitness` exit 0 (1013 jobs).

## GATE OUTCOME: GREEN

The faithful Rabinovich Lemma 3.2(1) order-type-disjunction structure COMPOSES on the exact
2-owner coincidence the additive filter made FALSE (handoff 05). The closed `zAtX1L` channel
routes into per-order-type validity to yield non-vacuity.

## What was built (all sorry-free, axiom-clean)

- `KvE2SepSpikeOrderType` — order-type index `{strictBefore, strictAfter, coincident}` (tie = first-class disjunct).
- `kvE2_sepSpikeOrderTypes` — the disjunction list (includes the coincidence order-type).
- `kvE2_sepSpikeDisjValid σ χ` — per-order-type validity: strict disjuncts read OPEN `zXU`/`zUW`; the coincidence disjunct reads CLOSED `zAtX1L`. No open/closed conflation.
- `kvE2_sepSpikeArr σ χ := orderTypes.filter (disjValid σ χ)` — faithful analog of `kvE2_sepArrL`.
- `kvE2_sepSpike_additiveOpenOnly_vacuous` — CONTRAST/RED baseline: the open-only filter `= []` when both open bits are false (the plan-02 failure).
- `kvE2_sepSpike_twoOwner_coincidence_nonvacuous` — **the GATE lemma**: `kvE2_sepSpikeArr σ χ ≠ []`, closed by feeding the preserved axiom-clean `kvE2_sepCoincidentAnchor_discharge` into the coincidence disjunct's validity.

## Axiom check (lean_verify)

- `kvE2_sepSpike_twoOwner_coincidence_nonvacuous`: `[propext, Classical.choice, Quot.sound]` — NO `sorryAx`.
- `kvE2_sepSpike_additiveOpenOnly_vacuous`: `[propext, Quot.sound]` — NO `sorryAx`.

## Sorry inventory (unchanged from baseline)

4 pre-existing code sorries in SharedWitness: @897, @904 (FALSE scaffolds `kvE2_sepSlotsL/R_valid`, removed in Phase 6), @2093, @2225 (singleton strategic sorries, removed in Phase 8). **0 new sorries; 0 vacuous defs; 0 new axioms.** The two spike lemmas are themselves sorry-free.

## Modeling decision (deviation, altered — read before Phase 2)

The counterexample is encoded as a **realization-parametrized** 2-owner arrangement (hypotheses:
σ realized at `[x1,w,x,t]`, χ = τ's foreign base type realized AT `x1`, `zXU`/`zUW` bits pinned
false), NOT a hardcoded finite `sig`/`M`/`qnf` fixture. This exercises the REAL preserved brick and
is a robust, general encoding of exactly the handoff-05 scenario. The `_hzXU`/`_hzUW` hypotheses are
deliberately unused in the non-vacuity proof (the FULL faithful arr needs only the coincidence
disjunct); they pin the scenario and are consumed by the contrast lemma.

## Immediate next action (Phase 2, pending user review of the gate)

Generalize the spike to the k-owner merged anchor set `A := {x1_σ : σ∈kvE2_sepPos qnf} ∪ {w}`:
- `kvE2_sepOrderTypes qnf : List (WeakOrder A)` (finite, decidable; ties = coincidences); reuse `VVecEA2.disjList` (NavigatedSpine:140).
- `kvE2_sepDisjValid qnf π` — strict adjacencies via the surviving open-zone compat leaves; ties via the closed-zone leaf (Phase 4 forward-decl/stub).
- `kvE2_sepArr' qnf := (kvE2_sepOrderTypes qnf).filter (kvE2_sepDisjValid qnf)` — replaces `kvE2_sepArrL/R`.
- The Phase-1 `kvE2_sepSpike*` defs may be promoted or deleted once `kvE2_sepArr'` lands (plan: "spike, may be deleted or promoted after Phase 2").

Key reusable assets confirmed live: `kvE2_sepCoincidentAnchor_discharge` (SW:1161, axiom-clean), `kvE2_sepBits` (SW:152), zone specs `kvE2_sep_zAtX1L`/`kvE_sub2_zXU`/`kvE_sub2_zUW`.
