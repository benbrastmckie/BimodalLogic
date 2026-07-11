# Task 348 Phase 7 Handoff (2026-07-11) — Adjacent exterior brackets + enriched gate COMPLETE

## Immediate Next Action

Phase 8 (discharge theorem + wiring + closeout, `ExteriorBracket.lean` + doc-comments):
prove `bracketEndChar_kvE2Ext_correct_two_prior_frag` — assuming
`(bracketEndChar_kvE2Ext atomMap h_surj P qnf).holds M atomMap x t` (destructure via
`bracketEndChar_kvE2Ext_holds_iff`) + the 309-owned inventory ONLY (`hfrag`, `hrealI`,
`hrealB`, `hexcl`, order bits, `h_UZ`/`h_SZ`), conclude the gate biconditional with
`hexclExt` discharged internally:
- ⇒: call `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean:359) supplying
  `hexclExt := ` triage (`kvE2_exterior_zone_triage`, side split only) ∘ per-side
  `kvE2_extBracketPast_sound` / `kvE2_extBracketFut_sound` (both take σ UNMARKED). The
  per-side pins `henv`/`hbelow`/`habove` must be derived at the SW:12788-shaped site from
  the endpoint 1-types + order bits (the recorded Phase-2 derivation obligation).
- ⇐: extend `bracketEndChar_kvE2_complete_two_prior` (OuterGate.lean:147) with the two
  bracket re-establishments via `kvE2_extBracket{Past,Fut}_complete`; pins from realized
  qnf: `henv = hq.1`-restriction, `hbelow`/`habove` from `kvE2_futAnyBit_correct`
  (ExteriorNegation.lean:148, side-neutral), `hpos`/`hneg` from qnf's quant layer
  (raw `nf_eval_nf` outer existential + zone determination positions bit-true witnesses
  exterior). Then doc-comment updates (Prop43.lean blocker note, KampPrior.lean:351
  transfer note) + summary + final handoff JSON for 309.
Depends on 1, 7 — both done. Details in
`progress/phase7-exterior-bracket.md` §Notes for Phase 8.

## Current State

- Phase 7 of 8 COMPLETED. Phases 1–7 done; 8 pending.
- NEW file `Kamp/NfMultiAnchorBridge/ExteriorBracket.lean` (686 lines) + 7-line additive
  import note in `Kamp/NfMultiAnchorBridge.lean` — this wiring put ExteriorNegation/Past
  on the live import path: full `lake build` GREEN at 1724 jobs (= 1721 baseline + 3).
- Repo sorry census 163 = baseline; zero sorries in task files. All 17 public Phase-7
  deliverables axiom-checked ⊆ {propext, Classical.choice, Quot.sound}.
- H7 territory clean: ExteriorNegation/ExteriorNegationPast/ExteriorZoneTriage/OuterGate/
  SharedWitness/SubBracket2V byte-unchanged.

## Key Decisions (within settled design — H6 clean)

1. **Marking = zone + base + six-zone bits** (`kvE2_futMarked`/`kvE2_pastMarked`,
   Bool-decidable): the bracket conjunction ranges over the σ for which the per-side
   `_complete` hypotheses (`hbase`, `hbits`) hold SYNTACTICALLY; realizers force the
   marking (`kvE2_futMarked_of_realizer`/`kvE2_pastMarked_of_realizer`), so soundness
   covers unmarked σ for free and the ⇐ half stays true (the R2 escape shapes are
   excluded by construction, not by hypothesis).
2. **Bit-true conjuncts are the landed `kvE2_futPos`/`kvE2_pastPos`** (Lemma 7.10 forms);
   their existence content is exposed by `kvE2_extBracket{Fut,Past}_exists`
   (per-side `_complete` contrapositive under the marking's own hbase/hbits).
3. **Enriched gate is a `BracketEndCharCarrierV sig 2`**: `bracketEndChar_kvE2Ext` =
   interior carrier with `extBracketPast` conjoined at anchor `x` (endpointLeft) and
   `extBracketFut` at anchor `t` (endpointRight) via `VVecEA2.enrichEndpoints`;
   `bracketEndChar_kvE2Ext_holds_iff` exposes the degenerate Lemma 7.6 conjunction.
4. **Dedupe task skipped** (churn bar): candidates are `private` in read-only territory;
   only the two zone-coupling lifts were mirrored file-locally (Phase-5/6 pattern).

## Sorry Inventory

Empty for task 348. (Pre-existing out-of-scope: KampPrior.lean strategic sorry —
309-owned per plan R1; EANegation.lean:834/:1129 pre-existing; Boneyard/BXCanonical/
Expressiveness pre-existing, unrelated.)

## References

- Plan: `specs/348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md`
  (Phase 7 [COMPLETED] with inline deviation notes; Phase 8 next).
- Progress: `specs/348_prop43_exterior_reflatten/progress/phase7-exterior-bracket.md`
  (delivered-declaration table, verification log, Phase-8 recipes).
- Prior handoffs: phase-6 (symmetric per-side hypothesis inventories), phase-2 (binding
  signature + pin irreducibility), phase-4 (completeness template).
