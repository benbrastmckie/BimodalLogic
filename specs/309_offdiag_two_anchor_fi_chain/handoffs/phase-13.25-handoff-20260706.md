# Phase 13.25 Handoff — Uniformization (v6-named "Phase 13.2b")

**Status:** COMPLETED (construction green, additive, sorry-free). Commit `71e41de5c`.

## Immediate Next Action
Dispatch **Phase 13.35** (k=2 correctness gate RE-RUN for `bracketEndChar_kvE'`, ONCE).
Entry point: `bracketEndChar_kvE'_two_eq` (NfMultiAnchorBridge.lean :5510).
**FIRST obligation of 13.35:** the deferred `kvE'_pin_honest` honest-safety smoke lemma
(H8-budget deferral from 13.25 — recorded, not dropped, per the phase's own routing).

## Current State
- Phase 13.25 landed additively after the F3 verdict record (NfMultiAnchorBridge.lean :5282-5531).
- Full tree GREEN (1709 jobs). 0 new sorries, 0 new axioms.
- `lean_verify` on `bracketEndChar_kvE'` and `bracketEndChar_kvE'_two_eq` = exactly
  `[propext, Classical.choice, Quot.sound]`.
- Additive-only diff: 250 insertions, 0 deletions. `kvE_body`/`bracketEndChar_kvE` byte-identical.
- EANegation :1090/:1249 NOT consumed (only the required non-consumption doc statement names them).

## Deliverables (all in NfMultiAnchorBridge.lean, additive)
- `kvE_PinArrangement` (private structure) — witnessZone + witnessType.
- `kvE_consistentZones` — the 7 consistent order-type placements (list form of `kvE_consistent`).
- `kvE_pinArrangements` — per-sub finite candidate placements (fresh type × consistent zones).
- `kvE_pinDisjunct` — channel (i) point/segment builders.
- `kvE_exclConj` — channel (ii) negated finite disjunction, honest-safe.
- `kvE'_body` (+ `kvE'_body_gate_fail`) — `kvE_body` verbatim EXTENDED with both channels:
  pin witness slots spliced per positive interior sub (`slotsFor`/`pinSlots`), exclusion
  conjuncts conjoined into `segL`/`segR` (`exclAt`, guarded by `hasPos`). All 13.2 channels
  retained verbatim (gate, unary families, `t`-anchored `exF σ`, per-sub `ptSub` slots).
- `bracketEndChar_kvE'` — new carrier alongside the UNCHANGED `bracketEndChar_kvE`.
- `bracketEndChar_kvE'_two_eq` — `rfl` k=2 instance bridge.

## Key Decisions
- Design choice (a) carrier channel extension (NOT provider-side pinning) — per v7 Amendment F3.
- Finite disjunctions over the candidate family via `Fintype (NormalForm sig k n)` + explicit
  `List` builders (`kvE_consistentZones.map`, `Finset.univ.toList.filter`) — no `decide`/`Fintype`
  on the anchor path beyond the existing `zone`/`hasPos` machinery.
- Parametric in k (no `σ.2` destructuring) — kept for Phase 13.4 symbolic-k reuse.

## PRIMARY RISK for the 13.35 gate (flagged, not hidden)
The discriminating per-sub JOINT content — σ's INNER-witness structure (`σ.2`) measured against
the honest anchors — is NOT parametrically expressible in `kvE'_body` at symbolic k without
destructuring `σ.2` (which the plan bans as depth-baking) or a multi-anchor provider (banned,
F-A circular). The landed channels carry `σ.1`-level positional content (zone + fresh type) plus
the finite-disjunction exclusion. This is a legitimate, well-typed, non-vacuous realization of
the channel SHAPES, but its SUFFICIENCY for the k=2 soundness direction is unverified and is
13.35's machine determination. If the F3 crux residual (`e 1 = w`, `e 2 = x` unpinnable) recurs
under the machine probe, that is the legitimate machine-probed escalation (F4 candidate per plan
13.35 routing) — a second NO-GO escalates to the orchestrator blocker ladder, does NOT trigger a
13.2c (uniformization budget = ONE round). Do NOT dispatch 13.4/14 until 13.35 returns GO.

## Sorry Inventory (unchanged from baseline)
- KampPrior.lean:351 — strategic, n=1 arm; follow-up: 13.35 gate → Phase 14.
- KampPrior.lean:354 — strategic, n>=2 arm; owned by task 305.
