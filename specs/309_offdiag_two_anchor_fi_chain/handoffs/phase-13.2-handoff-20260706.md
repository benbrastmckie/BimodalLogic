# Task 309 Phase 13.2 Handoff — per-sub enriched carrier `bracketEndChar_kvE` (2026-07-06)

## Immediate Next Action (orchestrator routing)

Dispatch **Phase 13.3** (k=2 correctness GO/NO-GO gate for `bracketEndChar_kvE`; report 05
label 13.II-b). Preconditions are met: 13.2 landed GREEN. DECISION GATE — machine-probe,
record the verdict either way, land no partial theorem, no sorry (task-311 Phase-5 pattern).

## Current State

- Phase 13.2 [COMPLETED]; v6 heading count: **13 of 16** complete
  (1-5, 6.1, 9-12, 13.0, 13.1, 13.2). Remaining: 13.3, 13.4, 14.
- `lake build` full tree GREEN (1709 jobs).
- Diff this dispatch: additive-only — 1 Lean file (NfMultiAnchorBridge.lean), 283 insertions,
  0 deletions. All preserved assets byte-identical (`bracketEndChar_kv`/`kv_body`, k1v kit,
  13.1 material, F1/F2 records, fold assets).
- Commit: `22334d430` (`task 309 phase 13.2: per-sub enriched carrier bracketEndChar_kvE +
  concrete k=2 instance`).
- New sorries: 0. `lean_verify` on `bracketEndChar_kvE`, `bracketEndChar_kvE_two_eq`,
  `nf_eval_depth1_fold_iff`: exactly `[propext, Classical.choice, Quot.sound]`.
- No `VecEA2 1` regression in the new block; anchors `{x,t}` (two-point `VVecEA2.holds`).

## Deliverables landed (NfMultiAnchorBridge.lean, current line numbers)

| Item | Line | Notes |
|---|---|---|
| Section doc (A2 + N1/N2 + Def 3.1 md:61-74 + G5 v6 + exclusion design record) | :4921 | full construction/decision record |
| `kvE_consistent : ZoneSpec 3 → Prop` | :5000 | seven consistent zones, literal list IDENTICAL to `k1v_zone_consistent` RHS (:2065) — 13.3 can reuse that lemma |
| `kvE_gate r q` | :5015 | per-sub two-conjunct gate: (i) atom-layer off-fiber honesty, (ii) PER-SUB order-conflict falsity |
| `kvE_body charBase charK exF r q` | :5036 | private per-sub successor body (Risk-R6 factoring); parametric in `charBase`/`charK`/`exF` |
| `kvE_body_gate_fail` | :5130 | `¬ kvE_gate r q → kvE_body … = ⟨[]⟩` (off-gate branch of 13.3, mirrors `kv_body_gate_fail` :3697) |
| `bracketEndChar_kvE atomMap h_surj P` | :5150 | `{k} (P : ExistProviders sig atomMap k) : BracketEndCharCarrierV sig (k+1)`; = `kvE_body (nf_depth0_char_formula …) (P.existF 0) (P.existF 3) qnf.1 qnf.2` |
| `bracketEndChar_kvE_two_eq` | :5167 | k=2 instance bridge, pure `rfl` (P at depth 1) |
| `nf_eval_depth1_fold_iff` | :5187 | depth-1 arity-n per-sub obligation decomposition (atom layer ∧ folded quant layer ∧ off-fiber clause), wrapping `nf_quant_layer_fold_iff` |

## Phase-13.3 entry points — exactly what to consume

**Target**: `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE atomMap h_surj P)` at
`k + 1 = 2` (`P : ExistProviders sig atomMap 1`), via private direction lemmas
`bracketEndChar_kvE_sound_two` / `_complete_two` (mirror the k1v split :2325/:2966 region).

**Unfolding lemmas / literal shapes to consume (do NOT re-derive)**:

1. `bracketEndChar_kvE_two_eq` (:5167) — rewrite the carrier to `kvE_body` applied form.
2. `kvE_body` (:5036) — after `simp only [kvE_body]` (zeta-reduces the lets), the on-gate
   branch is a `dite (kvE_gate qnf.1 qnf.2)` whose true branch is the arrangement
   disjunction `S_L.permutations.flatMap … S_R.permutations.map … mkDisjunct`; the false
   branch is `⟨[]⟩`. Use `kvE_body_gate_fail` (:5130) for the off-gate branch.
3. **Literal shapes inside a disjunct** (endpoints/segments/points):
   - `epL` = `formula_conjList (xType :: [lit (hasPos zPastX χ) (Formula.snce (charK χ) ⊤)]_χ
     ++ [lit (hasPos zAtX χ) (charK χ)]_χ)` — kv_body unary families with
     `hasPos zs χ = (posIn zs).any (nfk_projFresh · = χ)` DERIVED from per-sub positives.
   - `epR` = `formula_conjList (tType :: [lit (hasPos zAtT χ) (charK χ)]_χ
     ++ [lit (hasPos zFutT χ) (Formula.untl (charK χ) ⊤)]_χ ++ (pos.map exF))` — the NEW
     per-sub joint literals `exF σ = P.existF 3 σ`, one per positive sub (ANY zone).
     `P.correct 3 σ M h_UZ h_SZ t` gives
     `temporal_truth M t (P.existF 3 σ) ↔ ∃ e : Fin 3 → M.carrier,
     nf_eval_nf M 1 4 (insertEnv e t) σ`, and `insertEnv e t = [e0,e1,e2,t]` (anchor LAST,
     NfDepth0Generalized:42/:46/:51) — the honest obligation env `[u,w,x,t]` is the
     `e = (u,w,x)` instance. Completeness direction: witness with `e := (u,w,x)`.
     Soundness direction: the fake-anchor looseness of `e` is the designed gap — pin the
     real anchors via zone/segment/endpoint content + the negation stack (see 4).
   - `segL`/`segR` = `formula_conjList [if hasPos z{XW,WT} χ then ⊤ else (charK χ).neg]_χ` —
     honest-safe unary exclusions (kv shape, `hasPos`-guarded).
   - `ptW` = `formula_conjList (charBase (nf_y_proj qnf.1) :: [lit (hasPos zAtW χ) (charK χ)]_χ)`.
   - Slot point types: `ptSub σ = ⟨charK (nfk_projFresh σ)⟩`, slots per-sub — S_L/S_R are
     `posIn zXW`/`posIn zWT` (lists of SUBS); distinct positive subs need distinct witnesses
     (`nf_eval_unique`, NormalForm:245) — the multiplicity content the fiber read lacked.
   - `charK χ = P.existF 0 χ`: `P.correct 0 χ M h_UZ h_SZ v` +
     `insertEnv_zero` (NfDepth0Generalized:54) give
     `temporal_truth M v (P.existF 0 χ) ↔ nf_eval_nf M 1 1 (fun _ => v) χ`.
4. **Per-sub obligation discharge (A2 inside-out)**: `nf_eval_depth1_fold_iff` (:5187) at
   `n = 4`, env `[u,w,x,t]`, `σ : NormalForm sig 1 4` — splits
   `nf_eval_nf M 1 4 [u,w,x,t] σ` into atom layer ∧ zone-bounded depth-0 monadic
   existentials (over `ZoneSpec 4 × NormalForm sig 0 1`, subs reassembled by `nf0_assemble`)
   ∧ off-fiber falsity. This is the arity-5 `nf0_split_assemble` shape of the plan's
   acceptance (it rides inside `nf_quant_layer_fold_iff`).
5. **Negative-sub content is proof-side** (F-D discipline; the carrier deliberately carries
   NO uniform negative joint literal): discharge through `prior_hasAttainedINF h_UZ`
   (PriorINF:224) + EANegationClosure stack (`neg_interval_formula` :401,
   `neg_bounded_exists` :492, `neg_vecEA2`/`neg_2var_vec_ea` :646/:720,
   `neg_orderedPointsExist_is_vbracket` EANegation:347) — consumed ONLY per-model inside the
   proof. If a direction cannot close through the proof-side route, that is the NO-GO
   finding (uniformization fallback 13.2b via `/revise 309` v7) — do NOT weaken the 13.2
   carrier or the 13.1 predicate.
6. Zone kit reuse: `kvE_consistent`'s literal list = `k1v_zone_consistent` RHS (:2065);
   `k1v_zoneHolds_cons_iff` (:2041) applies to the `[w,x,t]` env unchanged.

## Key Decisions (this dispatch)

1. **`epR`/`t` anchoring of per-sub joint literals**: `insertEnv` puts the provider anchor at
   the LAST position, which for the obligation env `[u,w,x,t]` is the fixed endpoint `t` —
   the only position the A1 bundle can anchor without navigation (A2 bars navigated
   characteristics). Evaluating `P.existF 3 σ` at a witness slot `u` would NOT be
   honest-true (`u` sits at position 0, not 3) — rejected.
2. **Exclusion literal shapes (design deliverable)**: honest-safe unary families only;
   uniform `¬(P.existF 3 σ)` for negative σ over-excludes through fake anchors (F-D gap).
   Negative joint content = 13.3 proof-side obligations.
3. **Inner-existential flattening rides the provider formula** *(documented deviation from a
   literal reading of the plan sentence)*: slot-level flattening of σ's depth-(k-1) inner
   content needs depth-(k-1) converters, which the depth-k `ExistProviders` bundle does not
   supply; and 13.3/13.4 must target the SAME uniform-in-k definition. The Phase-14
   instantiation of `P.existF` is itself the Lemma-3.4 flattened TL form, so the flattening
   happens one round earlier, inside the provider.
4. **`hasPos` fiber occupancy is DERIVED, not read**: computed from the per-sub positive
   lists (`(posIn zs).any …`), so every read of `qnf.2` in the body is `q σ` at an
   individual sub — the code-review per-sub criterion holds syntactically.

## Sorry Inventory (unchanged — no new; inherited live-path baseline)

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:351` — strategic (task-309
  target); discharged by Phase 14 after the ladder lands.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:354` — deliberately remains;
  owned by task 305.
- (Pre-existing elsewhere: EANegation.lean:1090/:1249 uniform-backward variants and
  Bundle/Boneyard files — untouched, outside task 309 scope; touched only if 13.3's
  uniformization fallback is triggered, and then only via the v7 revision.)

## References

- Plan: `specs/309_offdiag_two_anchor_fi_chain/plans/06_offdiag-fi-chain-plan.md`
  (Phase 13.2 heading carries the completion record; Phase 13.3 is next).
- Report: `specs/309_offdiag_two_anchor_fi_chain/reports/05_k2-vocab-enrichment-redesign.md`
  (Pillar 2 realized this phase; Pillar 3 + F-D caveat feed 13.3).
- Previous handoff: `handoffs/phase-13.1-handoff-20260706.md` (13.1 entry points; note its
  pre-13.1 line references shift again by +283 for post-13.2 numbers where applicable —
  13.1-material lines :4831-4918 are unchanged since 13.2 appended at end of file).
- Commit this dispatch: `22334d430`.
