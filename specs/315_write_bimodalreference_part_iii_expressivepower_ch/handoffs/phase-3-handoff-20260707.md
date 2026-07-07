# Phase 3 Handoff: p3-ltl-to-tm.typ

- **Task**: 315
- **Phase**: 3 (Write p3-ltl-to-tm.typ) — COMPLETED
- **Session**: sess_1783410218_f83296_315

## Done
- Full chapter (~110 lines): mandated thesis paragraph (Until/Since over linear orders fused
  with S5 + MF over task frames; modality over constructed history space); traces-vs-task-frames
  contrast (time domain, initial point, LTS reading) cross-referencing @sec:truth; four-row
  operator-convention table (strict/non-strict, derived `next`/`prev` with
  `next_unfold`/`prev_unfold`, past operators, anchored vs floating validity); GPSS future-only
  point routed to the vlach chapter's Kamp discussion via @ch:vlach-blstar; fusion-vs-product
  positioning citing @gabbay2003manyvalued; LTL/CTL/CTL*/HyperLTL triangulation (pnueli1977,
  clarke1982, emerson1986, lamport1980, vardi2001, clarkson2014, finkbeiner2016); STIT/Rumberg/
  Thomason branching neighbors + lind2021 shifts-of-finite-type; two-layer conservativity story
  (paper theorem paper-side; `Metalogic/ConservativeExtension/` proves `lift_derivation_qfree`
  only, cross-ref @sec:conservative-extension).
- Perpetuity cited by cross-reference (semantics Time-Shift + theorems chapter), not restated.
- Exactly one forward reference to @sec:decidability-frontier (a second was written, then
  reworded to plain prose to honor the at-most-one constraint).

## Verification
- `typst compile` exit 0.
- Grep clean: no "vanilla LTL", no "LTL + S5" phrasing.
- Backticks: `next`, `prev`, `next_unfold`, `prev_unfold`, `untl`, `snce`,
  `Metalogic/ConservativeExtension/`, `lift_derivation_qfree` (all verified-list).
