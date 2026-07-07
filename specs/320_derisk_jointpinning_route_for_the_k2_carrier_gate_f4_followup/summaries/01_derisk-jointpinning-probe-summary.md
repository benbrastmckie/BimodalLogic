# Implementation Summary: Task 320 — Joint-Pinning Probe (F4 Follow-Up)

- **Task**: 320 — derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup
- **Plan**: `plans/01_derisk-jointpinning-probe.md` (8 phases, all COMPLETED)
- **Deliverable**: `reports/02_jointpinning-probe-results.md`
- **Outcome**: **GO — route b3 (nested F_i-chain, Cor 5.4).** b1 = NO-GO, b2 = NOT NEEDED.
- **Session**: sess_1783424133_5a7ad0_320

## What was done

A machine-checked PROBE (not carrier surgery) discriminating the three joint-pinning routes. Retained
probe code lands as a NON-CONSUMED, append-only verdict section in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (after the F4 record, +90/−0,
first 5609 lines byte-identical by sha256):

- **`probe_P1_channel_i_collapse`** (`rfl`) — re-confirms the channel-(i) flattening: the finite pin
  arrangement family collapses to a constant function of `nfk_projFresh σ` (σ.1-level), `witnessZone`
  discarded → **b1 NO-GO**.
- **`probe_P3_cor54_step_shape`** — `fChainFrom`/`fChainPred` (EANegation:552/567) MATCH Rabinovich
  Cor 5.4's `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (via the landed proven `fChainFrom_step`). Audit
  MEDIUM-confidence claim 6 machine-confirmed.
- **`probe_P4_b3_positions_by_eval_point`** — the landed proven `bracket_implies_fChainPred` recovers
  honest witness positions from `bf.holds` ALONE, `e`-free, with inter-anchor position carried by the
  nested-Until evaluation point → **b3 GO** (litmus PASS); its sole hypothesis being `bf.holds` (no
  uniqueness premise) → **b2 NOT NEEDED**.

All three probes are axiom-clean (`propext`, `Classical.choice`, `Quot.sound`), no sorry.

The deliverable report contains a concrete **design spec for task 321**: new definitions
`kvE_subBracket` (reads σ.2, the joint inner structure, not σ.1), `kvE_subChain := …fChainPred`,
`kvE2_body`, `bracketEndChar_kvE2`, with the demonstrated-closed crux goal (P4 instantiated at
`kvE_subBracket`). No route needed provider-side pinning or `EANegation :1090/:1249` — no escalation
blocker; no F5 defect record warranted.

## Verification

- `lake build` (full project): green, 1709 jobs.
- Landed assets byte-identical (sha256 of lines 1–5609 unchanged; diff is pure append `@@ -5607,4 +5607,94 @@`).
- 0 code sorries, 0 vacuous definitions, 0 new axioms.
- No `simp`/`omega`/`aesop` in any proof body (bodies are `rfl` / term-mode delegations); the only
  `by omega` are `Fin`-index typing obligations in signatures (identical to landed `fChainFrom_step`).

## Plan Deviations

- **Phase 1 (altered)**: The provider-independent ℤ counterexample was captured via probe P1's `rfl`
  (the channel-(i) collapse that is the counterexample's discriminating-failure root) plus the landed,
  green-re-certified F4 verdict record, rather than by rebuilding a fresh standalone `ExistProviders`/ℤ
  falsity term. Faithful to the machine-checked-baseline requirement; avoids re-deriving material the
  landed record already certifies.
- **Retained-code location (as-planned option)**: probe code landed as an appended non-consumed section
  IN `NfMultiAnchorBridge.lean` (the plan's sanctioned house-style option) rather than a separate
  scratch file — needed for in-module access to the `private` channel defs; no landed asset edited.
- No other deviations; the probe ladder (b1 boxed falsifier → b3 lead → b2 conditional) and the
  position-by-evaluation-point GO-gate litmus were applied exactly as planned.
