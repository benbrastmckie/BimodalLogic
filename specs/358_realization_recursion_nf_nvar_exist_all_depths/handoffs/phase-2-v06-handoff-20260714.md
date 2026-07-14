# Task 358 v06 Phase 2 handoff — 367 interface pin + re-probe gate (2026-07-14)

Session: sess_1784059448_2c72f2_358

## Re-probe gate: GREEN

All 14 certificates `lean_verify` at floor axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx:
- 367: `kvE_probe367_tailDG_deep_rejected`, `_real_slice_deep_anchored`, `_depth2DG_deep_rejected`, `_copyPlant_collapses`
- 364: `kvE_probe364_sigma2_sstar_inconsistent`, `_sigma2_slice_inconsistent`, `_sigma2_inadmissible`, `_sstar_honest_unrealizable`
- 363: `kvE_probe363_fake_elem_inconsistent`, `_fake_slice_inconsistent`, `_qnfG1_antecedent_fails`
- 358: `kvE_probe358_eP_atomMate_present`, `kvE_probe358_tailDG_gapItem_pinned_fails`, `_tailDG_sigma_in_population`

Kamp-path sorries: exactly `KampPrior.lean:519` and `:522` (grep-confirmed). Zero source edits this phase.

## Pinned interface (v06, post-367)

- Rows 8-9 binders: `EndIntervalConsumerK.lean:158-171`; gate-match mirrors `KampPrior.lean:989-1002`. Antecedent is `kvE_deepOnFiber qnf σ = true` (replaces `nfk_dropFresh σ = qnf.1`).
- Rows 12-13 binders (`_hexclDeepPast`/`_hexclDeepFut`): `EndIntervalConsumerK.lean:191-204`; mirrors `KampPrior.lean:1017-1030`. Antecedents: adm, `qnf.2 σ = false`, `nfk_dropFresh σ = qnf.1`, `kvE_deepOnFiber qnf σ = false`, x1 exterior.
- Rows 10-11 byte-stable (statements match 360 `_zero` supplies at k := 0).
- Guard API: `kvE_deepOnFiber` + `_zero`(:94, rfl)/`_base`(:100)/`_iff`(:106, j+3/j+2 indexing)/`_row`(:127)/`_of_realized`(:141), ExteriorFiberDeepAnchorK.lean.
- Converters: `kvE_futBundle_of_realizer` ExteriorConverterK.lean:231; `kvE_pastBundle_of_realizer` ExteriorConverterPastK.lean:199 (from realizer hσ at [x1,w,x,t]: fiber-forward bundle + saturation slice).
- `kvE_futSliceEq` (ExteriorPinnedConverseK.lean:675): `σ'.1 = σ.1` (depth-0 atom row) && three `kvE_fiberZoneList` agreements (zone lists depend ONLY on σ.2: `kvE_fiberZoneList σ z = (kvE_fiber σ).filter (nfk_zoneSpec · = z)`, `kvE_fiber` = σ.2-filter). Past mirror at ExteriorPinnedConversePastK.lean:35.
- `NormalForm sig (k+1) n = (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)` — genuine Prod; `Prod.ext` applies. `σ.1` is the DEPTH-0 atom layer; `nfk_dropFresh : NF k (n+1) → NF 0 n`.
- `nf_eval_nf M (k+1) n env qnf` = atom-match ∧ ∀ sub, (∃ x, eval (cons x env) sub) ↔ qnf.2 sub = true (unrestricted iff; `hqnf.2 sub` usable directly).

## Phase-3 adjudication result (mate-collapse): SliceEq needs NO more than row + deep content

For k ≥ 1, given σ admissible + `kvE_deepOnFiber qnf σ = true` + ambient realized at env = [w,x,t]:
1. `kvE_deepOnFiber_iff` → row + mate σ' (`qnf.2 σ' = true`, `σ'.2 = σ.2`).
2. `(hqnf.2 σ').mpr` → σ' realized at (x1', env) for some x1'.
3. σ'.2 nonempty: s₀ := `nf_characteristic M k 5 (cons v (cons x1' env))` any v; `(hσ'.2 s₀).mp ⟨v, nf_characteristic_satisfies ...⟩`.
4. σ.2 s₀ = true by `σ'.2 = σ.2`; `kvE_futAdmissible_onFiber` (ExteriorConverterK:63) → `nfk_dropFresh s₀ = σ.1`.
5. `kvE_fiber_dropFresh` (ExteriorFiberK:157) on σ' realized → `nfk_dropFresh s₀ = σ'.1`.
6. `Prod.ext` → **σ' = σ**; hence `qnf.2 σ = true`; conclude with σ itself + SliceEq-refl.
This is precisely the `kvE_probe367_copyPlant_collapses` mechanism (admissibility pins σ.1 to the marked fibers' dropped row). k = 0 routes through `kvE_deepOnFiber_zero` + frozen `kvE_hsliceFut_supply_zero` (ExteriorPinnedConverseK:1309) / `kvE_hslicePast_supply_zero` (ExteriorPinnedConversePastK:822).

## Phase-3 target signatures (general k, binder-shape-exact)

`kvE_hsliceFut_supply` / `kvE_hslicePast_supply`: parameters `(P : ExistProviders sig atomMap k) (M) (h_UZ) (h_SZ) (qnf : NormalForm sig (k+2) 3) (x t)`; conclusion = the rows-8-9 binder body verbatim (Fut: truth at t of `kvE_futPos P σ`; Past: truth at x of `kvE_pastPos P σ`). New leaf: `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean`, imports: ExteriorFiberDeepAnchorK, ExteriorPinnedConverseK, ExteriorPinnedConversePastK (converters/negation arrive transitively).

## Phase-4 notes

- Rows 12-13 general-m: from a hypothetical realizer at pinned exterior x1 with ambient realized, `kvE_deepOnFiber_of_realized` forces guard true, contradicting guard-false. Needs ambient realization at the binder site — igPtW→ambient bridge adjudication FIRST (`hcharK` + `P.correct` + `kampPrior_existProviders_of_ih_existF0_char`).
- G2-B2 uniqueness kernel population is now deep-anchored; mate-collapse (above) may similarly shrink the work: any two guard-true admissible σ over the same realized ambient are both qnf-marked and (if slice-equal) share .1 via marked fibers.

## Stale-ref note

Plan's converter refs :231/:199 CORRECT; delegation-context note about ":208/:177 stale" refers to older revision — ignore.
