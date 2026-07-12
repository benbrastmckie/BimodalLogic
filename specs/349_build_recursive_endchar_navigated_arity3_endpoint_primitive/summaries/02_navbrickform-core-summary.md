# Task 349 — Phase 4 Implementation Summary: `navBrickForm` + `_correct` (load-bearing core)

- **Task**: 349 — Build the recursive navigated arity-3 endpoint primitive
- **Phase**: 4 (the flagged load-bearing "~300-500 line core")
- **Status**: implemented (Phase 4 COMPLETED; full pass, no 4a/4b split)
- **Session**: sess_1783824622_947f0b
- **Plan**: `plans/02_endchar-faithful-architecture.md`

## What was built

Two additive, sorry-free objects in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean`:

1. **`navBrickForm`** (Base.lean:1806) — the arity-general navigable brick, a `Formula`.
2. **`navBrickForm_correct`** (Base.lean:1827) — its correctness under three parametric hooks.

Target proved (anchor `a`; Phase 5 sets `a := env 0`):

```
temporal_truth M atomMap a (navBrickForm rec sub) ↔
  ∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub
```

## Key design decision (deviation from schematic plan, faithfulness-required)

The plan/report §3.1 schematically described `navBrickForm` as the "arity-`(n+1)` generalization
of `nf_zone_flatten_navigable`" — a Prop-valued **5-zone two-anchor** brick. But `navBrickForm`
must be a `Formula` (it feeds `nf_endpoint_tl_gen`'s `innerConv : NormalForm sig k (n+1) → Formula`,
per the frozen `endCharRec` body at Base.lean:1518) evaluated at the **single accessible anchor**
`a = env 0`. A formula at one point cannot reference the other `n-1` env positions semantically, so
the two-anchor 5-zone Prop is not realizable as a formula.

The faithful realization is therefore the **single-anchor 3-zone** navigated existential converter —
the exact structural analog of the already-green diagonal converter `nf_char2_diag_exist_tl`
(Base.lean:168), one arity up and **segment-carrying**:

- `w'` navigated in three order zones relative to `a`: past exterior (`w' < a`), present (`w' = a`),
  future exterior (`a < w'`);
- open exterior zones = seg-carrying `A_past`/`A_future` (NfZoneFlattenNavigable.lean:335/386) over
  endpoint hook `rec sub`;
- interior interval type = the genuine characteristic `rec sub` via `BracketFormula.trivial
  (rec sub)` — **never `TemporalPred.top`** (G3);
- the other `n-1` env positions and the `seg.holds` interior conjunct are absorbed by the
  **parametric** hooks `h_past`/`h_now`/`h_fut` (discharged in Phase 5).

## Proof method (G5, manual)

`simp only [navBrickForm]` → `rw [temporal_truth_or, temporal_truth_or, A_past_correct,
A_future_correct, exists_trichotomy_split …]` → manual `or_congr`/`exists_congr`/`and_congr_right`
composition. No `simp`/`omega`/`aesop` chain-step shortcut. Mirrors `nf_char2_diag_exist_tl_correct`
(Base.lean:204-205) and `nf_zone_flatten_navigable_correct` (Base.lean:700-706).

## Verification (green bar — all met)

- Scoped `lake build` of the Base module: **GREEN** (1005 jobs).
- `navBrickForm`/`navBrickForm_correct`: **sorry-free**.
- `lean_verify navBrickForm_correct` = exactly `[propext, Classical.choice, Quot.sound]`.
- Grep: **no** `nf_char3_deeper_split` and **no** `TemporalPred.top` code-reference in the new
  objects (docstring narrative only). `EndCharCarrier` not widened.
- Route guards: G2/G4 (single free anchor `a`; every `w'` a bracket witness bound by
  `Until`/`Since`, free-anchor count ≤2), G3 (non-trivial `rec sub` interior), G5 (manual bridges).

## Sorry inventory

Empty. No sorries introduced; none pre-existing on the touched objects.

## For Phase 5 (hook discharge — the recursion closure)

Phase 5 defines `nf_endpoint_tl_gen` + `endCharRec` and proves `endCharRec_correct` by induction on
`k`, discharging `navBrickForm_correct`'s hooks with the IH `endCharRec_correct k (n+1)`.

**Critical subtlety surfaced this dispatch** (recorded in the handoff): `endCharRec_correct`'s
conclusion holds only under `NavResidual M sub (Fin.cons w' env)`, which pins `sub`'s order-0 atoms
(the order of `w'` relative to each env position). For `w'` where `NavResidual` fails, `nf_eval_nf`
is false (atom-layer mismatch), so the existential is unaffected — but Phase 5's per-zone hook
discharge must establish `NavResidual` for the navigated witness (the one-witness-at-a-time
ordering invariant, report 01 §3.3). This zone-consistency reasoning belongs to Phase 5's assembly;
Phase 4 correctly holds the hooks parametric.
