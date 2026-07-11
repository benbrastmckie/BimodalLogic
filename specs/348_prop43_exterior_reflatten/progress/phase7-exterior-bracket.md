# Task 348 Phase 7 Progress — Adjacent exterior brackets + enriched composed gate

- **Status**: done
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11

## Delivered (NEW file `Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`, 686 lines +
additive import wiring in `Kamp/NfMultiAnchorBridge.lean`)

| Declaration | Role |
|---|---|
| `kvE2_futBelowZones` / `kvE2_pastAboveZones` (+ `_key` lemmas) | the six per-side `hbits` zone index sets with their at-or-below-`t` / at-or-above-`x` keys |
| `kvE2_futMarked` / `kvE2_pastMarked` (+ `_iff`) | syntactic per-σ compatibility marking against qnf: exterior zone + `hbase` + six-zone `hbits` (the Phase-4/6 `_complete` σ-side inventory, made decidable) |
| `kvE2_extBase_of_realizer` | side-neutral: any realizer over `[x1,w,x,t]` in an `henv`-pinned model forces `nf0_dropFresh σ.1 = qnf.1` |
| `kvE2_futMarked_of_realizer` / `kvE2_pastMarked_of_realizer` | an exterior realizer FORCES the full marking (zone via Phase-1 triage, base via the above, bits via file-local zone-4/3 coupling lifts against `hbelow`/`habove`) |
| `kvE2_extBracketFut` / `kvE2_extBracketPast` (+ `_iff`) | **Def 7.5 adjacent brackets**: conjunction over marked σ — bit-true ↦ `kvE2_futPos`/`kvE2_pastPos` (Lemma 7.10), bit-false ↦ `kvE2_extNegFut`/`kvE2_extNegPast` |
| `kvE2_extBracketFut_sound` / `kvE2_extBracketPast_sound` | bracket at anchor kills EVERY bit-false σ at every exterior `x1` on its side (σ NOT assumed marked — the `hexclExt` discharge shape for Phase 8) |
| `kvE2_extBracketFut_exists` / `kvE2_extBracketPast_exists` | bracket at anchor + marked bit-true σ ⇒ exterior realizer (per-side `_complete` contrapositive) |
| `kvE2_extBracketFut_complete` / `kvE2_extBracketPast_complete` | per-σ exterior facts re-establish the bracket at its anchor (Phase-8 ⇐ shape; per-side `_complete` + `_sound` contrapositive) |
| `VVecEA2.enrichEndpoints` (+ `_holds`) | endpoint 1-type enrichment of a `VVecEA2` — the degenerate Lemma 7.6 conjunction, disjunct-independent so it factors |
| `bracketEndChar_kvE2Ext` (+ `_holds_iff`) | **the enriched composed gate**: interior `bracketEndChar_kvE2` with `extBracketPast` conjoined at LEFT anchor `x` and `extBracketFut` at RIGHT anchor `t`; `holds ↔` interior `∧` bracketPast@`x` `∧` bracketFut@`t` |

## Key decisions (settled design respected — H6 clean)

1. **Marking = zone + base + bits** (not zone alone): the ⇐ half is UNPROVABLE for
   base/bit-incompatible σ (their `Pos` forms can be true at the anchor while σ is
   unrealizable for anchor-invisible reasons — exactly the Phase-2 R2 escape shapes), and
   soundness needs no wider index because realizers FORCE the marking
   (`_of_realizer` lemmas). Marking is Bool-decidable, model-independent.
2. **Per-side sound/complete lemmas CALLED, never re-proved**: `kvE2_extNegFut_sound`/
   `_complete` (ExteriorNegation.lean:1243/:1484), `kvE2_extNegPast_sound`/`_complete`
   (ExteriorNegationPast.lean:581/:855). Only the two `private` zone-4/3 coupling lifts are
   mirrored file-locally (`extBk_futZone4_below_iff`, `extBk_pastZone4_above_iff`) —
   the sanctioned Phase-5/6 porting pattern.
3. **Enriched gate is a genuine `BracketEndCharCarrierV sig 2`** (formula-level Def 7.5
   object), via disjunct-wise `TemporalPred.conj` on the endpoint 1-types; the Lemma 7.6
   degenerate conjunction is exposed by `bracketEndChar_kvE2Ext_holds_iff`.
4. **Positive clauses reused**: bit-true conjuncts are the landed `kvE2_futPos`/`kvE2_pastPos`
   (Lemma 7.10 `Until`/`Since`-navigated forms) — no duplicates.
5. **Import wiring**: `NfMultiAnchorBridge.lean` gains one leaf edge to `ExteriorBracket`,
   bringing ExteriorNegation/Past onto the live import path (root build 1721 → 1724 jobs).

## Verification (phase gate)

- Scoped `lake build …ExteriorBracket`: GREEN, zero errors/warnings in the new file.
- Full `lake build`: GREEN, 1724 jobs (= 1721 baseline + the 3 exterior modules newly wired).
- `#print axioms` on all 17 public deliverables ⊆ `{propext, Classical.choice, Quot.sound}`.
- Repo sorry census (stripper) 163 = Phase-4/5/6 baseline; zero sorries in task files.
- No vacuous definitions; no new `axiom` declarations (repo greps: pre-existing hits only).
- H7 territory clean: NEW `ExteriorBracket.lean` + 7-line additive import note in
  `NfMultiAnchorBridge.lean`; ExteriorNegation/Past/ZoneTriage/OuterGate/SharedWitness/
  SubBracket2V byte-unchanged this dispatch.

## Notes for Phase 8 (discharge theorem + wiring + closeout)

- `hexclExt` discharge recipe: `kvE2_exterior_zone_triage` splits the exterior guard;
  each side closes by `kvE2_extBracketPast_sound` / `kvE2_extBracketFut_sound` — these
  take σ UNMARKED (marking is derived internally from the hypothesized realizer), so the
  triage's zone facts are not even needed beyond side selection.
- ⇐ re-establishment recipe: from realized qnf derive `henv` (= `hq.1` restricted),
  `hbelow`/`habove` (= `kvE2_futAnyBit_correct`, ExteriorNegation.lean:148 — side-neutral,
  gives ALL zones, keys are then immediate), `hpos` (realized bit-true σ + zone marking in
  `kvE2_futMarked_iff`/`kvE2_pastMarked_iff` positions the witness exterior via the σ.1
  order atoms), `hneg` (bit-false ⇒ no realizer anywhere from raw `nf_eval_nf` semantics);
  then `kvE2_extBracket{Fut,Past}_complete` + `bracketEndChar_kvE2_complete_two_prior`
  assemble `bracketEndChar_kvE2Ext_holds_iff.mpr`.
- Deferred dedupe (churn bar, read-only territory): `nf_profile_unique/exists`,
  `kvE2_pastCharZone4/3'`, side-neutral `.pred`/`.order` cases — unchanged from Phase-6 note.
