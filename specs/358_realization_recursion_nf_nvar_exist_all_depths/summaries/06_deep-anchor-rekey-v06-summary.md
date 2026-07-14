# Task 358 implementation summary — v06 dispatch (2026-07-14)

Session: sess_1784059448_2c72f2_358 | Plan: plans/06_deep-anchor-rekey-v06.md
**Outcome: PARTIAL — Phases 2-3 landed GREEN; Phase 4 [BLOCKED] on a machine-checkable
interface inadequacy (gates Phases 5-8). Targets `:519`/`:522` NOT retired. Zero debt
introduced: no sorry, no vacuous def, no forced proof.**

## Landed (green, committed)

### Phase 2 — 367 interface pin + re-probe gate (commit b11c4ac06)
- 14-certificate inventory `lean_verify` GREEN at floor axioms `[propext, Classical.choice,
  Quot.sound]`, no sorryAx (367 x4, 364 x4, 363 x3, 358 x3). Kamp sorries exactly
  `KampPrior.lean:519`/`:522`. Zero source edits.
- Pins + the Phase-3 adjudication pre-result recorded in
  handoffs/phase-2-v06-handoff-20260714.md.

### Phase 3 — general-m rows-8-9 supply (commit 46d1f3ebc)
NEW leaf `Theories/.../NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean`:
- `kvE_hsliceFut_supply` / `kvE_hslicePast_supply` at GENERAL k, binder-shape-exact for the
  gate-match rows 8-9. k = 0 routes through `kvE_deepOnFiber_zero` + the FROZEN task-360
  `_zero` supplies; k >= 1 via the **mate-collapse**: `kvE_deepMate_collapse` proves the
  guard's qnf-marked mate IS σ itself (common marked fiber element pins both atom rows via
  `kvE_futAdmissible_onFiber` / `kvE_fiber_dropFresh`; `Prod.ext` collapses) — the
  `kvE_probe367_copyPlant_collapses` mechanism in the honest direction. Plus
  `kvE_{fut,past}SliceEq_refl`.
- Machine gate: scoped build green; all new theorems at floor axioms; guard-unfold scan
  zero; frozen files byte-identical; tailDG + depth2DG certificates re-verified green.
- Full-tree `lake build` GREEN (1760 jobs) at dispatch end.

## Blocked (Phase 4; gates 5-8) — the P17 gap inside the consumer interface

Adjudicating the plan-mandated igPtW → ambient bridge FIRST (before any Phase-4 build)
produced two countermodel casts showing the igPtW-guarded binders (rows 5, 6, 10-13) are
**FALSE as stated at m >= 1** — the bridge is CIRCULAR (ambient realization ⇔ atom row +
rows 5+6+10-13 themselves):

- **CM-A** (kills row 13): homogeneous ℤ (R = ∅); fake qnf marks one honest representative
  per profile bucket ({char[x-1], char[x], char[w], char[t], char[t+1]}) and omits
  σ := char[t+2,w,x,t]; σ is admissible, on-row, bit-false, guard-false (char[t+1].2 lacks
  the gap-point element), realized at x1 = t+2, while igPtW + rows 5/5a/6/10/11 all hold.
- **CM-B** (kills row 5): a Probe358TailK-style spacing-discrepant fake tail; the marked
  sub_g (AtW-zoned char over the fake tail, same (AtW, χ_w) bucket, fiber-consistent) is
  `[w,x,t]`-unrealizable.

Root cause: `igPtW`/`igFoldBit` read `qnf.2` at PROFILE level only; deep content below a
bucket is free at m >= 1. This is the P17 anchor-content gap (point-type at w drops anchor
content) resurfacing inside the 349/363/367 interface. Prescription (structured blocker in
the plan, Phase 4): a 367-style AMBIENT-side deep-saturation/EF-closure guard, m = 0-inert,
on the igPtW-guarded binders + gate formula; probe-first over the Probe358TailK ℤ infra;
then re-key and re-dispatch 358. Recommended: `/spawn 358`.

Phase-3's landings are immune (rows 8-9 are ambient-realization-guarded) and survive any
ambient-side strengthening.

## Verification record

- Full `lake build`: GREEN (1760 jobs). New leaf sorry-free at floor axioms.
- New sorries: 0. New axioms: 0 (repo greps 2 = 2, pre-existing docstring hits). New
  vacuous defs: 0 (1 pre-existing legitimate Examples hit, unchanged since 367 audit).
- Guard-unfold scan (new code): zero. Frozen boundary: byte-identical.
- Targets `:519`/`:522`: still open (correctly — retiring them requires Phases 4-8).

## Plan Deviations

- Phase 3 *(altered)*: G2-A1/A2's separate admissibility + slice-equality sub-derivations
  subsumed by the mate-collapse kernel; `kvE_futRealizer_admissible` not needed (witness is
  σ itself, admissible by antecedent). Annotated in the plan Phase-3 record.
- Phase 4 *(blocked, no build)*: the bridge adjudication (the phase's FIRST checklist item)
  failed analytically; per Rollback/Contingency the phase went [BLOCKED] with the
  countermodels recorded instead of building supplies against them. Machine probes of CM-A/
  CM-B are prescribed as the successor task's first deliverable (context budget did not
  permit landing the ~300-line probe leaf this dispatch).
- Phases 5-8: not started (gated by the Phase-4 blocker; row 5 is itself CM-B's target).
