# Task 348 Phase 8 Progress — Discharge theorem + wiring + closeout

- **Status**: done
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11

## Delivered (appended to `Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`, 686 → 1173
lines; comment-only touches to `Kamp/KampPrior.lean` and `Kamp/Prop43.lean`)

| Declaration | Role |
|---|---|
| `extDis_zPastX3_not_interior` / `extDis_zFutT3_not_interior` (private) | exterior zones are not interior (index-1/index-2 pair mismatch) — the `hrealB` guard |
| `kvE2_extGate_henv` (private) | **the `henv` pin from the gate inventory**: pred parts from the `ptW`/`EpL`/`EpR` `kvE2_sepProj3` head conjuncts, order parts from `hxw`/`hwt` + the six qnf order bits (the recorded Phase-2 SW:12788-site derivation obligation, discharged; body = the fold's SW:12718-12775 atom-layer block, standalone) |
| `kvE2_extGate_anyBit_iff` (private) | **the zone-fact pin, UNRESTRICTED over zones** (subsumes both the `hbelow` at-or-below-`t` and `habove` at-or-above-`x` keys). Forward: cone witnesses ride `hexcl` on their own depth-1 characteristic; below-`x` / above-`t` witnesses ride the interior gate's own `zPastX3`-`Since` / `zFutT3`-`Until` `kvE2_sepHasPos` endpoint literals, bridged from the depth-1 `nfk_projFresh` channel to the depth-0 `kvE2_futAnyBit` channel through a `hrealB` realizer + `kvE2_sepProjFresh_eval` + `nf_eval_unique`. Backward: positive owners provider-realized (`hrealI` interior / `hrealB` otherwise); realizer reads back zone + profile from its atom layer |
| `bracketEndChar_kvE2Ext_correct_two_prior_frag` | **THE DISCHARGE THEOREM**: enriched-gate `holds ↔ ∃ w` under the 309-owned inventory ONLY (`hfrag`/`hrealI`/`hrealB`/`hexcl` + order bits + `h_UZ`/`h_SZ`) — `hexclExt` ELIMINATED as an input obligation (discharged internally: `not_and_or` guard split → per-side `kvE2_extBracket{Past,Fut}_sound` under the two pins). ⇐: `bracketEndChar_kvE2_complete_two_prior` + per-side `_complete` with pins from realized qnf (`hq.1`, `kvE2_futAnyBit_correct`), positives positioned exterior by the marking's zone bits, negatives excluded by raw `nf_eval_nf` semantics |

## Key decisions (settled design respected — H6 clean)

1. **One unrestricted zone-fact lemma instead of separate `hbelow`/`habove` derivations**:
   both pins are the same biconditional with different key restrictions; the keys are
   simply dropped at the consumption site (`fun zs χ _ => hany zs χ`).
2. **Depth-1 → depth-0 profile bridge via realizer** (not via `nfk_take` internals): the
   `kvE2_sepHasPos` channel is depth-1 (`nfk_projFresh`), `kvE2_futAnyBit` is depth-0
   (`nf0_projFresh`); the bridge realizes the owner via `hrealB` and equates both profiles
   at the realizer via the public `kvE2_sepProjFresh_eval` + `nf_eval_unique` — no private
   `nf_profile_unique` mirrors needed.
3. **⇒ routed through `bracketEndChar_kvE2_sound_two_prior_frag`** (the landed ⇒ half)
   rather than `.mp` of the full biconditional — CALLED, never re-proved.

## Verification (phase gate + task DoD)

- Full `lake build`: GREEN, 1724 jobs (= Phase-7 baseline; no new modules).
- `#print axioms bracketEndChar_kvE2Ext_correct_two_prior_frag` =
  `{propext, Classical.choice, Quot.sound}` exactly.
- Regression: same axiom set re-verified on `bracketEndChar_kvE2_correct_two_prior_frag`,
  `_sound_two_prior_frag`, `_complete_two_prior`, `kvE2_outer_fold_frag`.
- Repo sorry census (stripper) 163 = baseline; ZERO sorries in all task-348 files.
- Frozen files byte-unchanged this dispatch: SharedWitness, SubBracket2V, OuterGate,
  ExteriorNegation, ExteriorNegationPast (git status clean on all five).
- Vacuous-definition / `^axiom` greps: pre-existing hits only (Examples + Boneyard prose).
- `KampPrior.lean` n=1 strategic sorry REMAINS (309-owned per plan R1) — now carrying the
  task-348 transfer note.

## Commits

- `0c61d255b` task 348 phase 8.1: gate-level pin derivations
- `1d4a06832` task 348 phase 8.2: discharge theorem
- `f38c84f46` task 348 phase 8.3: closeout doc-comments
