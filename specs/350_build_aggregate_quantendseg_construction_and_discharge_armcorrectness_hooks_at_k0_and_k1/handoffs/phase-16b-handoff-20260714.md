# Phase 16b Handoff — aggPop1 + kampArm_past_k1 / kampArm_future_k1 + shape certs (task 350)

**Status**: Phase 16b COMPLETED. Single-phase dispatch (phase_number=16b); stopped at phase
boundary per contract. Session `sess_1784009176_e5245f`.

## Immediate Next Action (Phase 17 — full-DoD verification, citability doc-hooks, wrap-up)

1. Full `lake build` (whole tree; 16b baseline **1751 jobs**, already green at 16b close).
2. `lean_verify` on ALL SIX `kampArm_{past,diag,future}_{k0,k1}_correct` (fully qualified under
   `Bimodal.Metalogic.WeakCanonical.Kamp.`) = exactly `[propext, Classical.choice, Quot.sound]`;
   record the transcript in the summary.
3. Guard audit: `git diff --stat` over the task's commits — no frozen-file / KampPrior /
   ExteriorPinnedConverse(Past)K changes; KampPrior sorry count still exactly 2 (:361, :364);
   zero term-level `nf_char3_deeper_split`; zero live `sorry` in new modules; R1 audit
   (EANegationFix move = relocations + imports only).
4. `Base.lean` citability doc-hook update (docstring-only): replace the k=1 past/future blocker
   note (Base.lean:1284 region says `kampArm_past_k1` "is BLOCKED on the missing biconditional
   VVecEA2 conjunction" — now FALSE, both lemmas delivered in
   `NfMultiAnchorBridge/AggregateOffDiagK1.lean`) with the two new lemma names + the
   EANegationFix/ module DAG map.
5. Task summary `summaries/03_negfix-refactor-exterior-carriers-summary.md`; final commit;
   orchestrator handoff (blockers []); task status update.

## Current State

- Phases 1-13 + 14a-c + 15 + 16a + 16b COMPLETED (21 of 22 headings; remaining: 17 only).
- Full `lake build` green: **1751 jobs** (scoped module 1046).
- Sorry census over `NfMultiAnchorBridge/`: **0**. Sorry inventory: EMPTY.
- `lean_verify` on `aggPop1_correct`, `kampArm_past_k1_correct`, `kampArm_future_k1_correct`:
  exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- **ALL SIX DoD lemmas now delivered**: `kampArm_{past,diag,future}_k0` (Phase 3),
  `kampArm_diag_k1` (Phase 5), `kampArm_past_k1` + `kampArm_future_k1` (this phase).
- No frozen-file / KampPrior / task-358 edits (diff = AggregateOffDiagK1.lean append,
  1169 → 1540 lines). `nf_char3_deeper_split` not referenced (16a docstring guard note only).
- Incremental commits: 16b.1 (`aggPop1(_correct)` + fold lemma), 16b.2 (swap transport +
  `aggPop1F(_correct)` + decision record), 16b.3 (atom carriers + both arm lemmas + certs).

## Phase-16b delivered names (BINDING — consume, never rebuild)

All appended to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/AggregateOffDiagK1.lean`
(§9-§11), namespace `Bimodal.Metalogic.WeakCanonical.Kamp`, section variables `(atomMap) (h_surj)`:

| Asset | Content |
|---|---|
| `aggOd_holdsRight_iff_holds` / `aggOd_holdsLeft_iff_holds` | pin bridges: `holdsRight t ↔ ∃ x < t, holds x t` / `holdsLeft t ↔ ∃ x > t, holds t x` (pure reassociation) |
| **`aggOdPopFold_iff`** | the generic BICONDITIONAL population fold: `(l.map (if bit then D else (D ·).negFix)).foldr conjFull trivialTrue` holds iff `∀ qnf ∈ l, (D qnf).holds ↔ bit qnf` — gated on `HasAttainedINF/SUP` + `z0 < z1` |
| **`aggPop1`** / **`aggPop1_correct`** | the k=1 population carrier (Design-verbatim fold over `univ.toList` of `CAggOd`/`.negFix`) + correctness at pins `(x, t)`, `x < t`: holds ↔ the population MATCH `∀ qnf, ((∃ w, eval [w,x,t] qnf) ↔ sub_nf.2 qnf)`; `h_INF/h_SUP := prior_hasAttained{INF,SUP}` |
| `aggOdSwap12` / `aggOdSwap12_involutive` / `aggOdSwap12_eval_iff` | the `Fin 3` pin swap (fix 0, swap 1↔2), involution by `decide`, eval transport = `renameNF_eval_iff` instance |
| `CAggOdSwap_clause_iff` | dispatcher at the SWAPPED qnf read at flipped pins `(t, x)`, `t < x` ↔ population existential at trichotomy env `[w, x, t]` |
| **`aggPop1F`** / **`aggPop1F_correct`** | the future-arm fold (per-qnf carrier `CAggOd (swap qnf)`, bit at the ORIGINAL qnf) + correctness at flipped pins `(t, x)` |
| `aggOd_eval2_iff` | the definitional depth-(1+1) seam (`Iff.rfl`): `nf_eval_nf M 2 2 env sub_nf ↔ atom layer ∧ population MATCH` (local restatement of the `kampPrior_site_perQnf_seam` shape — no KampPrior import) |
| `aggAtomK1Past` / `aggAtomK1Past_holds_iff` | past atom carrier (endpoint locus at `x`, guarded origin locus at `t`, trivial bracket) ↔ `nf_eval_nf M 0 2 [x,t] sub_nf.1` under `x < t` |
| `aggAtomK1Fut` / `aggAtomK1Fut_holds_iff` | future mirror (FLIPPED origin guard `nf_char2_atom_offdiag_origin_future` at `t` = `z0`) under `t < x` |
| **`kampArm_past_k1`** / **`kampArm_past_k1_correct`** | DoD lemma 5/6: `((aggAtomK1Past ∧ aggPop1).translateRight)`; `temporal_truth t … ↔ ∃ x, x < t ∧ nf_eval_nf M 2 2 [x,t] sub_nf` under h_UZ/h_SZ |
| **`kampArm_future_k1`** / **`kampArm_future_k1_correct`** | DoD lemma 6/6: `((aggAtomK1Fut ∧ aggPop1F).translateLeft)`; `… ↔ ∃ x, t < x ∧ nf_eval_nf M 2 2 [x,t] sub_nf` |
| `ShapeCertificatesK1` | two `example`s at generic-site index `1 + 1` (verbatim trichotomy disjunct shapes; no KampPrior import) |

## Key Decisions

1. **Mirror-carrier decision (the 16a record-decision input) — route (a)-variant**: NO mirror
   dispatcher `CAggOdF` was built and the 16a mirror classification (`aggOdRow*F`,
   `aggOdClassifyF`, `aggOdZone3F_*`) stays UNCONSUMED. The future arm reuses the SAME
   `x < t`-keyed `CAggOd` through the bijective pin swap `aggOdSwap12` transported by
   `renameNF_eval_iff` (NfDepth0Generalized:440 — applicable exactly because the swap is a
   bijection, unlike the Phase-12 merge maps): at pins `(z0,z1) = (t,x)` with `t < x`,
   `CAggOd_clause_iff` yields the population at env `[w,t,x]` and the swap carries it to the
   trichotomy env `[w,x,t]`. A distinct fold carrier `aggPop1F` IS defined (the "Mirror
   `aggPop1F` … if" branch of the plan task), but it is two lines different from `aggPop1`
   (swap insertion) rather than a mirrored channel stack.
2. **Biconditional fold is generic in (D, bit, l)**: `aggOdPopFold_iff` takes the carrier
   family and bit function as parameters, so `aggPop1_correct` and `aggPop1F_correct` share one
   induction; the `univ` enumeration is never normalized (R4 never fired — no `maxHeartbeats`
   raise anywhere).
3. **Depth-(1+1) seam is definitional**: `aggOd_eval2_iff := Iff.rfl` (structure eta), the
   in-module analog of `kampPrior_site_perQnf_seam` — keeps the no-KampPrior-import guard.
4. **Atom layer rides a single-disjunct VVecEA2** with `BracketFormula.trivial TemporalPred.top`
   (same device as `VVecEA2.trivialTrue`), so the arm assembly is literally
   `(atom ∧ pop).translate{Right,Left}` + `conjFull_iff` — no new endpoint algebra.
5. **k=1 arms genuinely consume h_UZ/h_SZ** (they gate `negFix_iff` inside the fold), unlike
   the k=0 arms where the Prior hypotheses were carried unused. Statement shape is unchanged
   (binders were already there at k=0 for skeleton parity).

## Sorry Inventory

[] (empty — module and all consumed assets sorry-free)

## References

- Plan: `specs/350_…/plans/03_negfix-refactor-exterior-carriers.md` Phase 16b (now [COMPLETED],
  with inline landing notes) and Phase 17 (next).
- Consumed: Phase-16a `CAggOd`/`CAggOd_clause_iff`; Phase-11 `VVecEA2.conjFull(_iff)`,
  `VVecEA2.negFix(_iff)`, `trivialTrue(_holds)`; `renameNF`/`renameNF_eval_iff`
  (NfDepth0Generalized:373/:440); `prior_hasAttainedINF/SUP` (PriorINF:224/:269);
  `nf_char2_atom_offdiag_{endpoint,origin,correct}` (Base:342/:353/:369) +
  `_origin_future`/`_correct_future` (Base:1364/:1380); `VVecEA2.translateRight_correct`
  (NfToVecEA:451); `VVecEA2.translateLeft_correct` (VecEATranslation:549).
- Rabinovich 2014: Lemma 3.4 closure under ∧/∃ (chunk_0010); Cor 5.4 "all order patterns"
  (chunks 0014-0015).
