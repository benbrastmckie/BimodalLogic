# Implementation Summary: Task 367 — Deep-anchor exterior fiber population against the tail-doppelgänger

- **Task**: 367 (lean4)
- **Status**: implemented (all 6 phases COMPLETED, zero redesign loops consumed)
- **Session**: sess_1784059448_2c72f2_367
- **Plan**: `plans/01_deep-anchor-fiber-guard.md`

## Which candidate landed — the final guard form

A **synthesis of handoff candidates (a) and (b)**, adjudicated by probe (Phases 1-3),
landed as `kvE_deepOnFiber` in the NEW production module
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean`:

```lean
noncomputable def kvE_deepOnFiber {sig : MonadicSignature} :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)
  | 1, _, qnf, σ => decide (nfk_dropFresh σ = qnf.1)          -- m = 0 arm: pure row check (rfl-inert)
  | (j + 2), n, qnf, σ =>
    decide (nfk_dropFresh σ = qnf.1) &&
    ((Finset.univ.toList (α := NormalForm sig (j + 2) (n + 1))).any fun σ' =>
      qnf.2 σ' && decide (σ'.2 = σ.2))                        -- qnf-marked deep-content mate
```

At σ-depth ≥ 2 the guard demands a **qnf-marked deep-content mate**: some `σ'` with
`qnf.2 σ' = true` carrying EXACTLY σ's whole deep marking (`σ'.2 = σ.2`). Full `.2` equality
compares σ's marked-fiber content at every depth simultaneously — hereditary to depth 0 by
construction (not a single extra level), and it resolves the plan's Risk-2 depth/arity
bookkeeping without any deep slot-drop operation. Candidate (a)-literal (one-slot-dropped
recursive matching) was rejected as subsumed; candidate (b)-literal (raw semantic binder
condition) was rejected because the guard must be a `Bool` over the NF fintype to key the
bracket range.

**Interface restatement**: in the rows-8-9 binders (`_hslicePast`/`_hsliceFut`,
`EndIntervalConsumerK.lean`, mirrored in `bracketEndChar_kvExt_correct_prior` and
`kampPrior_site_rungK_gate_match`) the antecedent `nfk_dropFresh σ = qnf.1` is **REPLACED**
by `kvE_deepOnFiber qnf σ = true`. The bracket range filters (`kvE_extBracket{Fut,Past}`)
are re-keyed identically. NEW rows 12-13 (`hexclDeepPast`/`hexclDeepFut`) carry the ⇒-side
residue for on-row guard-false bit-false σ (m = 0-vacuous). Rows 10-11 are byte-stable.

## Certificate inventory (all sorry-free, axioms `[propext, Classical.choice, Quot.sound]`)

Production lemmas (`ExteriorFiberDeepAnchorK.lean`):
| Lemma | Role |
|---|---|
| `kvE_deepOnFiber_zero` (`rfl`) | Gate 1b — m = 0 inertness (guard ≡ row check at fiber depth 1) |
| `kvE_deepOnFiber_base` (`rfl`) | depth-0 arm inertness |
| `kvE_deepOnFiber_iff` | deep-arm extraction (never-unfold routing interface) |
| `kvE_deepOnFiber_row` | guard → old row antecedent (m = 0 supply adapter direction) |
| `kvE_deepOnFiber_of_realized` | Gate 2 crux — honest preservation at general model/signature; mate is σ itself |

Probe certificates (`ExteriorFiberDeepAnchorProbe367K.lean`, certifying the PRODUCTION definition):
| Certificate | Gate | Content |
|---|---|---|
| `kvE_probe367_tailDG_deep_rejected` | 1a | the 358 tail-doppelgänger `m3sigma` fails the guard w.r.t. the real ambient (`kvE_deepOnFiber qnf367 m3sigma = false`) |
| `kvE_probe367_real_slice_deep_anchored` | 2a | honest real slice passes, DERIVED from `_of_realized` (gate 2b route: zero guard-unfoldings) |
| `kvE_probe367_depth2DG_deep_rejected` | 3a | depth-2 hereditary doppelgänger (fake tail `[40, 9, 8, 11]`, discrete-gap discrepancy `(9,10) = ∅` visible only two fiber layers down) rejected — heredity fires |
| `kvE_probe367_copyPlant_collapses` | 3 | content-copying plant is construction-impossible: any admissible σ★ copying the real deep marking IS the real slice (via byte-stable `kvE_futAdmissible_onFiber`) |

Adversarial re-plant outcome: **candidate survived both attacks; ZERO redesign loops
consumed** (churn cap was one). The (ℚ, <) analytical-family closure and the prior-family
cross-check are recorded in the probe leaf's module docstring.

Prior GO re-verification (Phase 5, all at floor axioms, no sorryAx): task-363 set (9),
task-364 set (11), `kvE_probe358_eP_atomMate_present`, both `kvE_probe358_tailDG_*`
(byte-stable, supersession note added to the docstring only), M1 residuals
(`kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical`).

## Consumption-site repair record

| File | Change |
|---|---|
| `ExteriorFiberDeepAnchorK.lean` | NEW production guard module |
| `ExteriorFiberDeepAnchorProbe367K.lean` | NEW probe leaf (cast, gates, permanent regression record; rewired to production def) |
| `EndIntervalConsumerK.lean` | rows 8-9 restated; NEW rows 12-13; `endInterval_step_correct` threading; ledger updated |
| `ExteriorGateAssembleK.lean` | `hslice*` binders restated; NEW `hexclDeep*` binders; ⇒-discharge re-cased (off-row → offForce; on-row+guard-true → D1/rows 10-11; on-row+guard-false → rows 12-13) |
| `ExteriorBracketAssembleK.lean` | bracket range filters re-keyed to the guard; `_iff` lemmas; D1/D2 (guard antecedent), D3/D4 (`hslice` binder) |
| `KampPrior.lean` | `kampPrior_site_rungK_gate_match` binder mirror + pass-through; `:519`/`:522` sorries untouched |
| `ExteriorPinnedProbe358TailK.lean` | docstring-only supersession note (statements byte-stable) |

Frozen-layer audit: `ExteriorFiberConsistencyK/ProbeK/Probe364K`, `ExteriorNegation{,Past}K`,
`ExteriorPinnedConverse{,Past}K` (kernels, slice defs, m = 0 supply), `ExteriorPinnedProbe358K`,
`ExteriorPinnedProbeM1K` — ALL byte-identical to baseline `1fa31549f`. Full `lake build`
green; lean-token sorry count unchanged (835 = 835); Kamp-path proof sorries exactly
`KampPrior.lean:519`/`:522`; axiom count unchanged (2 = 2); vacuous-def scan clean (one
pre-existing legitimate `Examples` hit only); zero `kvE_deepOnFiber` unfoldings outside its
home module.

## Plan Deviations

- **Altered — guard shape**: landed as the (a)/(b) synthesis (row check + full-`.2`
  qnf-marked mate), not candidate (a)-literal; fiber-depth-1 arm is the pure row check,
  giving `rfl` m = 0 inertness. Annotated on the Phase-1 checklist.
- **Altered — edit boundary**: `ExteriorBracketAssembleK.lean` added to the Phase-4 file
  list via the Phase-1 consumption map (the map is the plan's authoritative edit boundary).
  Forced three ways: (i) rows-8-9 binders are passed whole to D3/D4, so the D3/D4 `hslice`
  binder types must change; (ii) D3/D4's slice-unmarked branch applies `hslice` to arbitrary
  bracket-range σ, so the range must carry the guard; (iii) the un-re-keyed bracket FORMULA
  is honestly unsatisfiable at m ≥ 1 (the fake σ's negative clause conjoins against its own
  firing chain). Annotated on the Phase-1 and Phase-4 checklists.
- **Altered — interface arity**: the restatement adds NEW rows 12-13 (`hexclDeep*`,
  m = 0-vacuous) beyond the planned rows-8-9-only change, because deep-anchored range σ
  that are on-row but guard-false carry no bracket clause and must be excluded by a carried
  obligation. Rows 10-11 stay byte-stable (better than planned). Annotated on Phase 4.

## Notes for task 358 (re-key)

The guard shape dictates the witness term the re-keyed G2 supply must construct:
**hereditary marked-characteristic membership** — for a realizer-derived σ over the
ambient's own tail, discharge rows 8-9's guard antecedent via `kvE_deepOnFiber_of_realized`
(the mate is σ itself; no guard unfolding). The m = 0 discharge routes through
`kvE_deepOnFiber_zero` (guard ≡ row at fiber depth 1) + the frozen task-360 supply. Rows
12-13's general-m discharge: under an honest ambient a pinned realizer forces the guard via
`_of_realized`, contradicting guard-false. Next action: `/revise 358` (re-key Phase 2
against the refined rows-8-9/12-13 interface) then `/implement 358`.
