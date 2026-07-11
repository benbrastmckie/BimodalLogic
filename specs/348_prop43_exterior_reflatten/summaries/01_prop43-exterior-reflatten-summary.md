# Implementation Summary: prop43_exterior_reflatten (task 348)

- **Status**: implemented (8/8 phases COMPLETED)
- **Session**: sess_1783796165_b5b482_348 (final phase; earlier phases same session id)
- **Date**: 2026-07-11
- **Plan**: specs/348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md

## What was built

Rabinovich Prop 4.3 re-flatten + Lemma 7.6 adjacency for the k=2 gate's exterior residue:
exterior arrangements (`x1 < x` / `x1 > t`) get their own adjacent-interval brackets,
composed with the landed interior bracket at the shared anchors `x, t` (degenerate
Lemma 7.6 conjunction), so that the `hexclExt` obligation of the 335 interior gate is
**discharged internally** and disappears as an input.

### Phases 1–7 (previously completed, this task)

1. `ExteriorZoneTriage.lean` — order-atom zone determination + exterior triage.
2. GO spike: single-σ future-side complement clause, both directions, GO-conditional
   (pin inventory `henv`/`hbelow` recorded as irreducible).
3. `ExteriorNegation.lean` — future-side clause family `kvE2_extNegFut` + `_sound`.
4. Future-side `_complete`.
5. `ExteriorNegationPast.lean` — past-side mirror `kvE2_extNegPast` + `_sound`.
6. Past-side `_complete`.
7. `NfMultiAnchorBridge/ExteriorBracket.lean` — markings, Def 7.5 adjacent brackets,
   per-side `_sound`/`_exists`/`_complete` bridges, enriched gate `bracketEndChar_kvE2Ext`
   (+ import wiring: ExteriorNegation/Past onto the live path, 1721 → 1724 build jobs).

### Phase 8 (this dispatch)

Appended to `ExteriorBracket.lean` (686 → 1173 lines, +487):

- `kvE2_extGate_henv` (private): the `henv` pin derived at the SW:12788-shaped site from
  the gate's own `ptW`/`EpL`/`EpR` head conjuncts + order bits — the recorded Phase-2
  derivation obligation, discharged.
- `kvE2_extGate_anyBit_iff` (private): the zone-fact pin, UNRESTRICTED over zones
  (subsumes `hbelow` AND `habove`). Forward: cone witnesses via `hexcl` on depth-1
  characteristics; strictly-exterior witnesses via the interior gate's own
  `zPastX3`-`Since` / `zFutT3`-`Until` `kvE2_sepHasPos` endpoint literals, bridged
  depth-1 → depth-0 through a `hrealB` realizer + `kvE2_sepProjFresh_eval` +
  `nf_eval_unique`. Backward: provider realization (`hrealI`/`hrealB`) + atom-layer
  readback.
- **`bracketEndChar_kvE2Ext_correct_two_prior_frag`** — the discharge theorem:
  enriched-gate `holds ↔ ∃ w` under `hfrag`/`hrealI`/`hrealB`/`hexcl` + order bits +
  `h_UZ`/`h_SZ` ONLY. `hexclExt` eliminated (guard split → per-side bracket soundness
  under the two pins). ⇐ extends `bracketEndChar_kvE2_complete_two_prior` with the two
  per-side `_complete` re-establishments from realized qnf.
- Doc-comment closeout: `KampPrior.lean` :351-block transfer note (retirement = 309
  Phase 14, R1); `Prop43.lean` blocker note now points at the landed exterior instances.

## Definition of Done (amended, per plan R1)

MET: the enriched composed gate and its discharge theorem exist, sorry-free and
axiom-clean, with `hexclExt` no longer an input obligation; interior + boundary +
adjacent-exterior = full k=2 completeness under the 309-owned provider inventory.
The KampPrior.lean strategic sorry retirement is EXPLICITLY DEFERRED to task 309
Phase 14 (R1 scope decision; transfer note landed; consumption guide in
`handoffs/02_enriched-gate-for-309.md`). Not a skeleton: `skeleton: false`.

## Final verification

| Check | Result |
|---|---|
| Full `lake build` | GREEN, 1724 jobs (= Phase-7 baseline) |
| `#print axioms` discharge theorem | `{propext, Classical.choice, Quot.sound}` exactly |
| Regression axioms (335 gate ×3, `kvE2_outer_fold_frag`) | same set, unchanged |
| Sorries in task-348 files | 0 (repo stripper census 163 = baseline) |
| Vacuous defs / new `axiom` | none (pre-existing hits only) |
| Frozen files (SharedWitness/SubBracket2V/OuterGate/ExtNeg/ExtNegPast) | byte-unchanged in Phase 8 |

## Plan deviations (Phase 8, annotated inline in the plan)

- ⇒ half routed through `bracketEndChar_kvE2_sound_two_prior_frag` directly (not `.mp` of
  the biconditional); pin obligations discharged by the two new private lemmas; one
  unrestricted zone-fact lemma serves both `hbelow` and `habove` (keys dropped at the
  consumption site).

## Commits (Phase 8)

- `0c61d255b` task 348 phase 8.1: gate-level pin derivations
- `1d4a06832` task 348 phase 8.2: discharge theorem
- `f38c84f46` task 348 phase 8.3: closeout doc-comments
- (final) task 348 phase 8: complete — plan/summary/handoff/JSON artifacts

## Sorry inventory

Empty for task 348. Out-of-scope pre-existing: KampPrior.lean `n = 1` strategic sorry
(309-owned, transfer-noted), KampPrior.lean `n + 2` case, EANegation.lean:834/:1129,
Boneyard/Expressiveness (unrelated, pre-existing).
