# Rescued scratch measurements

These files were produced by an implementation dispatch that was stopped mid-run by the
orchestrator to end a concurrent-dispatch overlap. They were recovered from the session
scratchpad, not from a committed artifact.

## Status: UNVERIFIED, scratch-script measurements — NOT module builds

- `reach418.out` / `reach418.lean` — a scratch re-encoding of BoxNegReachabilityProbe-style
  queries (8 rows emitted). This is NOT a `lake build BimodalTest` run of
  `Tests/BimodalTest/BoxNegReachabilityProbe.lean` (12 `#guard_msgs` rows), and must not be
  recorded as one. Treat as a lead to confirm, not as the AFTER measurement.
- `decide.out`, `anchor418c.out`, `anchor418c.lean` — anchor-row discrimination for
  `(G p) -> box (G p)`. Corroborates the committed Phase 6.4 finding (`.fuelExhausted`, no
  countermodel) and adds a fuel=400 datapoint that RETURNS, which the committed measurement
  did not have.

`TableauConformance.lean` (27 rows) is NOT represented here and remains unmeasured.
