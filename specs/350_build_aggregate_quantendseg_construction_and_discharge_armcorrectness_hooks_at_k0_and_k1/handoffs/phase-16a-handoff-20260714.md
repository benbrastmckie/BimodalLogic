# Phase 16a Handoff — (F) zone classifier + per-qnf dispatcher `C(qnf)` + clause iff (task 350)

**Status**: Phase 16a COMPLETED. Single-phase dispatch (phase_number=16a); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 16b — aggPop1 + kampArm_past_k1 / kampArm_future_k1 + certs)

In `AggregateOffDiagK1.lean` (same module): `aggPop1` = conjFull-fold over
`(Finset.univ : Finset (NormalForm sig 1 3)).toList` with `(CAggOd qnf)` on bit-true and
`(CAggOd qnf).negFix` on bit-false qnf; `aggPop1_correct` verbatim from the plan's Design
section (fold induction over `VVecEA2.conjFull_iff` + per-qnf `CAggOd_clause_iff` +
`VVecEA2.negFix_iff`; `h_INF := prior_hasAttainedINF … h_UZ`, `h_SUP := prior_hasAttainedSUP …
h_SZ`; local `maxHeartbeats` raise if needed, R4). Then `kampArm_past_k1(_correct)` via
`VVecEA2.translateRight_correct` (NfToVecEA.lean:451) and `kampArm_future_k1(_correct)` via
`translateLeft_correct` (VecEATranslation.lean:549); shape certificates against
`kampPrior_site_trichotomy` disjunct shapes at generic-site index `1 + 1` (Phase-3/5 technique,
no KampPrior import).

**16b mirror-carrier decision input (RECORD)**: the mirror CLASSIFICATION for the future arm is
delivered (`aggOdRow{ExtPastF,PtTF,IntF,PtXF,ExtFutF}` + `aggOdClassifyF` +
`aggOdZone3F_route_of_eval` + `aggOdZone3F_bot_eval_false`, all under ambient `t < x`), but NO
mirror dispatcher/carrier was built — the delivered channel carriers (`CExtPast`/`CExtFut`
ambient `x < t`; `CAggInt` order bits x<w<t; `agg2Past` five zones of `x < t`) are all keyed to
the `x < t` pin order. Per plan, 16b must either (a) find that `kampArm_future_k1` can consume
the SAME `aggPop1` at pins `(t, x)` reordered so the smaller pin is z0 (in which case
`translateLeft` at origin t lays x above t and `CAggOd`'s x<t-keyed channels apply verbatim with
the roles x:=laid-witness, t:=origin SWAPPED into (z0,z1)=(t,x) — check `holdsLeft`'s pin order
first), or (b) build the mirror dispatcher `CAggOdF` casing on `aggOdClassifyF` with mirrored
channel carriers — and record the decision.

## Current State

- Phases 1-13 + 14a-c + 15 + 16a COMPLETED (20 of 22 headings; remaining: 16b, 17).
- Full `lake build` green: 1751 jobs (scoped module 1046).
- Sorry census over `NfMultiAnchorBridge/`: 0. Sorry inventory: EMPTY.
- `lean_verify` on `CAggOd_clause_iff`, `agg2Past_holds_pin_iff`, `aggOdZone3_route_of_eval`:
  exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- No frozen-file / KampPrior / task-358 edits (diff = new AggregateOffDiagK1.lean (~1120 lines)
  + aggregator import + plan file). `nf_char3_deeper_split` not referenced.
- Incremental commits: 16a.1 (classifier rows + routing + mirror classification), 16a.2
  (`agg2Past_holds_pin_iff`), 16a final (channel carriers + dispatcher + aggregator + wrap-up).

## Phase-16a delivered names (BINDING — consume, never rebuild)

All in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean`
(new leaf; imports VecEAConjFull, EANegationFix (shim), AggregatePointMergeK1,
ExteriorNavPastK1, ExteriorNavFutK1, AggregateHookDischarge), namespace
`Bimodal.Metalogic.WeakCanonical.Kamp`, section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `aggOdRowPtX` / `aggOdRowInt` / `aggOdRowPtT` | six-bit order rows of `qnf.1` for w=x / x<w<t / w=t (exterior rows reuse delivered `navDOrderRow`/`navROrderRow`). `aggOdRowInt`'s conjunct ORDER = the six hypotheses of `bracketEndChar_kv_correct_one_prior` verbatim |
| `aggOd_{navDRow,rowPtX,rowInt,rowPtT,navRRow}_of_eval` | eval-forcing: a realizer at each witness position forces its row (via `nf_eval_depth1_fold_iff` atom layer) |
| **`aggOdZone3_route_of_eval`** | routing totality (ambient x<t): any realizer routes to exactly the row of its witness trichotomy position |
| `AggOdZone3` / `aggOdClassify` / `aggOdClassify_{extPast,ptX,int,ptT,extFut}` | 6-constructor channel type, total classifier (Classical if-chain), row → constructor lemmas (pairwise one-bit clashes ⇒ exactly-one) |
| `aggOdZone3_bot_eval_false` | 3-bot falsity: all five rows refuted ⇒ unrealizable at every w (given x<t) |
| `aggOdRow*F` ×5, `aggOdClassifyF`, `aggOdZone3F_route_of_eval`, `aggOdZone3F_bot_eval_false` | MIRROR classification for the future arm (ambient t<x); no mirror carrier (16b decision) |
| **`agg2Past_holds_pin_iff`** | two-pin fixed-endpoint reading of the DELIVERED `agg2Past` carrier: `(agg2Past sub_nf).holds M atomMap x t ↔ nf_eval_nf M 1 2 [x,t] sub_nf` under x<t (pointwise companion of `agg2Past_holdsRight_iff`; same fiber algebra) |
| `CAggPtX` / `CAggPtX_correct` / **`CAggPtX_clause_iff`** | w=x point channel: dite on `aggPm01GateK1`, on-gate `agg2Past (aggPm01CollapseK1 qnf)`, off-gate empty (gate forced by `aggPm01_gate_of_eval`); clause iff on `aggOdRowPtX` (bits force w=x) |
| `CAggPtT` / `CAggPtT_correct` / **`CAggPtT_clause_iff`** | w=t mirror via `aggPm02*` |
| `aggOdCharF` | depth provider: `nf_depth0_char_formula` at 0 (`h0 := rfl`), `⊤` above |
| `CAggInt` / **`CAggInt_clause_iff`** | interior channel: `bracketEndChar_kv … 1` consumed via `bracketEndChar_kv_correct_one_prior` at `aggOdRowInt`'s bits (needs h_UZ, h_SZ; no ambient) |
| **`CExtPast_clause_iff`** / **`CExtFut_clause_iff`** | exterior clause iffs: on the row the delivered `∃w<x`/`∃w>t` bound is redundant |
| **`CAggOd`** | the per-qnf dispatcher `C(qnf) : VVecEA2` (Classical if-chain on the five rows; 3-bot = empty disjunction) |
| **`CAggOd_clause_iff`** | THE master clause iff (what 16b's fold consumes): under `(h_UZ) (h_SZ) (x t) (hxt : x < t)`: `(CAggOd qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` |

## Key Decisions

1. **Point channels reuse `agg2Past` bodily**: the collapsed arity-2 evaluation at fixed pins
   `[x, t]` is read by a NEW pointwise lemma `agg2Past_holds_pin_iff` on the DELIVERED `agg2Past`
   VVecEA2 (whose endpoint packs/bracket/gate are exactly the two-pin fiber content) — no new
   carrier definition; the proof is the delivered `agg2Past_holdsRight_iff` with the outer `∃x<t`
   stripped (pins fixed as arguments).
2. **Classifier = row props + total function**: the six-bit rows are pairwise disjoint by one-bit
   clashes; `aggOdClassify` is total by construction; the dispatcher's if-chain mirrors it branch
   for branch, so channel order is semantically irrelevant.
3. **Mirror scoping**: 16a delivers the mirror CLASSIFICATION only (rows/classifier/routing under
   t<x); the mirror carrier question is 16b's record-decision per the plan text.
4. **Interior needs no ambient**: `CAggInt_clause_iff` takes (h_UZ, h_SZ) but NOT x<t — the rung
   is ambient-free; the master iff threads hxt only for the other channels + routing.
5. **Elaboration note**: `(hlayer _).mp hlt` with an inferred order-atom fails when the target
   bit is not yet known (Fin-proof metavariables block `atom_eval` reduction); type-ascribe the
   bit (`have hb : qnf.1 (.order ⟨i,_⟩ ⟨j,_⟩ _) = true := (hlayer _).mp hlt`) — the pattern used
   throughout.

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_.../plans/03_negfix-refactor-exterior-carriers.md` Phase 16a (now
  [COMPLETED]) and Phase 16b (next); Design section (aggPop1 target statement).
- Consumed: Phase-11 `VecEAConjFull`/negFix shim (imports only this phase); Phase-12a/12b
  `aggPm01/02GateK1`, `aggPm01/02CollapseK1`, `agg_pm01/02_collapse_k1`,
  `aggPm01/02_gate_of_eval`; Phase-14c `CExtPast(_correct)`; Phase-15 `CExtFut(_correct)`;
  `agg2Past` kit + `aggBracket_extract/construct` + `agg2_zone*` (AggregateHookDischarge);
  `bracketEndChar_kv(_correct_one_prior)` (PriorInterface); `nf_eval_depth1_fold_iff`
  (CarrierKv); `k1v_sorted_realization`/`k1v_not_of_iff_false` (CarrierK1V);
  `nf_char2_atom_offdiag_correct` (Base); `nfPred_correct` (NfToVecEA).
- Rabinovich 2014: Cor 5.4 "all order patterns" (chunks 0014-0015); Lemma 3.2(2)
  coincident-witness collapse (chunk_0009); Lemma 7.6 gluing (chunk_0021).
