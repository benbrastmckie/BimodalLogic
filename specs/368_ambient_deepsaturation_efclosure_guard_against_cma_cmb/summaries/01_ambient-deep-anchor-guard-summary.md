# Task 368 — Ambient Deep-Saturation EF-Closure Guard against CM-A/CM-B — Implementation Summary

**Task**: 368 — Ambient deep-saturation EF-closure guard against CM-A/CM-B
**Status**: COMPLETED (6/6 phases)
**Type**: lean4 (hard mode)
**Plan**: `plans/01_ambient-deep-anchor-guard.md`
**Session**: sess_1784070774_ef21fe

---

## Outcome

The ambient EF-closure deep-anchor guard is landed in production and machine-adjudicated
against the task's binding definition of done. Every listed certificate verifies at the floor
axioms `[propext, Classical.choice, Quot.sound]` (no `sorryAx`), the full `lake build` is green
(1761 jobs), the new guard is never unfolded outside its home module, the frozen layer is
byte-unchanged, and the active completeness/consumer-chain sorry residual is exactly the two
pre-existing `KampPrior.lean:519`/`:522` arms (task-358 territory, untouched).

Task 358's re-keyed Phases 4-8 can now be constructed against this interface.

---

## Final guard shape (as landed)

`Bimodal.Metalogic.WeakCanonical.Kamp.kvE_ambientDeepAnchor`
(`Theories/.../NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean:109`)

```
noncomputable def kvE_ambientDeepAnchor {sig} : {k n : Nat} → NormalForm sig (k + 2) n → Bool
  | 0,     _, _   => true                                   -- m = 0 binder: inert (rfl)
  | k + 1, n, qnf =>
      (univ.toList).all fun τ =>  !qnf.2 τ ||               -- ∀ marked sub τ
        (univ.toList).all fun ρ => !τ.2 ρ ||                -- ∀ deep element ρ of τ
          (univ.toList).any fun σ' =>                       -- ∃ marked sub σ'
            qnf.2 σ' && σ'.2 (swapNF01 ρ)                   -- covering swapNF01 ρ
```

σ-independent decidable syntax over the NF fintype. Reads **only** `qnf.2` (the characteristic
marking), never `qnf.1` (the atom row). Both EF-closure clauses, as exposed by the readback
`kvE_ambientDeepAnchor_iff`:

1. **∀-marked / ∀-deep**: for every marked sub `τ` (`qnf.2 τ = true`) and every deep element
   `ρ` of `τ` (`τ.2 ρ = true`), ...
2. **∃-marked-mate under fresh rotation**: ... there exists a marked sub `σ'` (`qnf.2 σ' = true`)
   whose deep content covers the **top-two-slot swap** of `ρ` (`σ'.2 (swapNF01 ρ) = true`).

This is the fresh-rotation EF-closure that both fake ambients (CM-A deep-incomplete homogeneous
ambient; CM-B) violate, while every honestly-realized `qnf` satisfies it
(`kvE_ambientDeepAnchor_of_realized`, the load-bearing anti-vacuity crux).

### Interface lemmas (the discharge terms task 358 must construct against)

| Lemma | Role |
|-------|------|
| `kvE_ambientDeepAnchor_zero` | m = 0 inertness (`= true` by `rfl`) — frozen m=0/k≤1 guard rail |
| `kvE_ambientDeepAnchor_iff` | deep-arm readback (∀τ∀ρ∃σ' proposition) — the ONLY sanctioned unfold route |
| `kvE_ambientDeepAnchor_of_realized` | honest preservation at a GENERAL `OrderedMonadicStructure` — the `_of_realized`/`_iff`-only discharge route (zero guard unfoldings) |

Gate-formula carrier: `kvE_ambientGuardForm` + `kvE_ambientGuardForm_truth`
(`ExteriorGateAssembleK.lean`); the guard rides `bracketEndChar_kvExt.holds` via a second
`enrichEndpoints` layer, surfaced as the 4th conjunct of `bracketEndChar_kvExt_holds_iff`.

---

## Certificate inventory — `lean_verify` axiom results

All results: `axioms = [propext, Classical.choice, Quot.sound]`, `warnings = []`, no `sorryAx`.

### Task 368 — CM-A/CM-B re-probe + hereditary + copy-plant (probe leaf `ExteriorAmbientDeepAnchorProbe358K.lean`)

| Certificate | Adversarial role | Axioms |
|-------------|------------------|--------|
| `kvE_probe368_cmA_ambient_rejected` | CM-A fake ambient ⇒ guard = false | floor ✓ |
| `kvE_probe368_cmB_ambient_rejected` | CM-B fake ambient ⇒ guard = false | floor ✓ |
| `kvE_probe368_real_ambient_anchored` | honest ambient ⇒ guard = true (anti-vacuity) | floor ✓ |
| `kvE_probe368_cmA_row13_refuted` | Phase-1 live record: CM-A refutes OLD row 13 | floor ✓ |
| `kvE_probe368_cmB_row5_refuted` | Phase-1 live record: CM-B refutes OLD row 5 | floor ✓ |
| `kvE_probe368_depth2_ambient_rejected` | hereditary depth-2 doppelganger ⇒ guard = false | floor ✓ |
| `kvE_probe368_ambient_copyPlant_passes_guard` | copy-plant passes the σ-independent guard (expected) | floor ✓ |
| `kvE_probe368_ambient_copyPlant_collapses` | copy-plant self-defeats via row/anchoring collapse | floor ✓ |
| `kvE_probe368_ambient_supply_route` | supply-route bridge to `_of_realized` | floor ✓ |

### Production guard + gate/consumer certs (new/changed)

| Certificate | File | Axioms |
|-------------|------|--------|
| `kvE_ambientDeepAnchor_of_realized` | `ExteriorAmbientDeepAnchorK.lean` | floor ✓ |
| `kvE_ambientDeepAnchor_zero` | `ExteriorAmbientDeepAnchorK.lean` | floor ✓ |
| `kvE_ambientDeepAnchor_iff` | `ExteriorAmbientDeepAnchorK.lean` | floor ✓ |
| `bracketEndChar_kvExt_correct_prior` | `ExteriorGateAssembleK.lean` | floor ✓ |
| `kampPrior_site_rungK_gate_match` | `KampPrior.lean` | floor ✓ |

### Prior GO inventory re-verification (unchanged; regression guard)

| Family | Certificates verified | Axioms |
|--------|----------------------|--------|
| probe367 (x4) | `tailDG_deep_rejected`, `real_slice_deep_anchored`, `depth2DG_deep_rejected`, `copyPlant_collapses` | floor ✓ |
| probe364 (x6) | `plant_rejected`, `sigma2_sstar_inconsistent`, `m1fake_rejected`, `sigma2_slice_inconsistent`, `replant_selfdefeating`, `honest_fiber_consistent` | floor ✓ |
| probe363 (x5) | `fake_elem_inconsistent`, `fake_slice_inconsistent`, `sigma_inadmissible`, `qnfG1_antecedent_fails`, `honest_fiber_consistent` | floor ✓ |
| probe358 (x3) | `tailDG_gapItem_pinned_fails`, `tailDG_sigma_in_population`, `eP_atomMate_present` | floor ✓ |
| M1 residuals (x2) | `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` | floor ✓ |

---

## Adversarial outcomes

- **CM-A / CM-B**: both fake ambients machine-excluded by the guard (guard = false), certified
  LIVE against the current interface before landing (Phase 1) and re-certified against the
  production definition (Phase 6).
- **Hereditary depth-2 doppelganger**: the +1-fiber lift of CM-A is rejected verbatim
  (`kvE_probe368_depth2_ambient_rejected`) — the accessor structure is depth-uniform.
- **Ambient copy-plant**: a marking-copy PASSES the σ-independent guard (as designed — the guard
  reads only `qnf.2`), so the attack must self-defeat elsewhere; it collapses through the
  row/anchoring clause (`nfk_dropFresh` marked-sub = `qnf.1`), pinning the row and identifying
  the fake with the honest ambient (`kvE_probe368_ambient_copyPlant_collapses`). This is the
  ambient analog of 367's `kvE_probe367_copyPlant_collapses`.
- **Anti-vacuity**: `kvE_ambientDeepAnchor_of_realized` at a GENERAL structure proves the guard
  is not vacuously restrictive — every honest ambient passes.

---

## Consumption-site repair record

Rows 5/6/10-13 gained the single σ-independent antecedent `kvE_ambientDeepAnchor qnf = true`,
restated across the consumer chain:

- `EndIntervalConsumerK.lean` — `EndIntervalCorrectPrior` rows 5/6/10-13 + threading + ledger
- `ExteriorGateAssembleK.lean` — gate-formula strengthening (`bracketEndChar_kvExt` second
  `enrichEndpoints` layer) + guard-restated gate binders; `⇒` reads the guard off `.holds`,
  `⇐` re-establishes it from realization via `kvE_ambientDeepAnchor_of_realized`
- `KampPrior.lean` — `kampPrior_site_rungK_gate_match` mirror + threading

Full consumer chain green.

---

## Adjudicated residue-row decision

**No new residue rows added.** Unlike 367's per-σ `kvE_deepOnFiber` (which split off rows
12-13), the σ-independent ambient guard is a SINGLE added antecedent on existing rows 5/6/10-13,
and is m=0-VACUOUS through `kvE_ambientDeepAnchor_zero` (guard ≡ true at m=0, so the antecedent
is trivially discharged by the frozen task-360 supply). Recorded in the `EndIntervalConsumerK`
obligation-disposition ledger.

---

## Definition-of-done gate results (machine-checked)

| Gate | Result |
|------|--------|
| G1 CM-A/CM-B re-probe + hereditary + copy-plant + Phase-1 records at floor axioms | **PASS** (9 certs) |
| G2 Full prior certificate inventory at floor axioms, no sorryAx | **PASS** (20 certs) |
| G3 Guard-unfold source scan (new guard + inherited, outside home modules) | **PASS** (= 0) |
| G4 Frozen-layer diff (byte-unchanged vs baseline `9f4f6302b`) | **PASS** (exactly 5 changed files) |
| G5 Zero-debt: full build green; completeness-chain sorry = 2; vacuous clean; 0 new axioms | **PASS** |
| G6 Summary + handoff exist, non-empty, JSON parses | **PASS** |

### G3 detail (guard-unfold scan)

- The NEW production guard `kvE_ambientDeepAnchor` is **never** unfolded outside its home module
  `ExteriorAmbientDeepAnchorK.lean`; consumers route only through `_iff`/`_zero`/`_of_realized`.
- Task 368 introduced **zero** new unfolds of the inherited guards (`kvE_deepOnFiber`,
  `kvE_fiberElemConsistent`, `kvE_fiberConsistent`, `kvE_futAdmissible`, `kvE_pastAdmissible`) —
  diff-confirmed over the 3 touched consumer files.
- Pre-existing admissibility unfolds in `ExteriorGateAssembleK:403/419` are attributed to the
  baseline commit `9f4f6302b` (blame-confirmed) and sit in the sanctioned negation/converter
  home family; the probe leaf's `rw [show kvE_ambientDeepAnchorV0 … from rfl]` operate on the
  probe-local V0 abbrev alias (home = the probe leaf) on concrete CM inputs.

### G4 detail (change set)

Exactly 5 files changed across all of task 368 (vs baseline `9f4f6302b`):
`KampPrior.lean`, `EndIntervalConsumerK.lean`, `ExteriorAmbientDeepAnchorK.lean` (NEW),
`ExteriorAmbientDeepAnchorProbe358K.lean` (NEW), `ExteriorGateAssembleK.lean`. Every frozen file
(363/364/367 files, m=0 kernels, k≤1 rungs, task-360 supply, `ExteriorDeepSliceSupplyK.lean`,
negation/converter families, historical probe records, `ExteriorPinnedProbe358TailK.lean`) is
byte-unchanged. The optional docstring-only supersession note on `ExteriorPinnedProbe358TailK`
was judged NOT warranted (statements already byte-stable) and not added.

### G5 detail (sorry inventory — full transparency)

The active kampPrior completeness/consumer-chain sorry residual is **exactly**
`KampPrior.lean:519`/`:522` — both present at the baseline at identical line numbers (identity
byte-stable), task-358 Phase 7/8 territory, untouched.

A directory-wide census of `Theories/.../Kamp/` reports 6 `sorry` tokens; the other 4 are
**pre-existing and out of scope**, and NOT on the kampPrior completeness path:
- `EANegation.lean:1090` / `:1249` — a separate negation leaf that `KampPrior` does **not**
  import (byte-identical at baseline; `:1249` self-documents "does NOT block the completeness
  proof").
- `Kamp/Boneyard/EndpointNegation.lean:160`, `Kamp/Boneyard/FOToVEA.lean:118` — deprecated
  graveyard code.

None of these 4 are in task 368's change set; task 368 introduced and retired **zero** sorries.

---

## Plan deviations

- **Probe leaf docstring note not added** — the plan permitted an optional docstring-only
  supersession note on `ExteriorPinnedProbe358TailK.lean` "IF warranted." Judged not warranted;
  file left byte-stable. This keeps the change set at exactly 5 files (tighter than the plan's
  "5 + probe leaf" allowance).
- **Sorry-inventory scoping clarified** — the definition-of-done phrase "Kamp-path sorry
  inventory = 2" is adjudicated as the active completeness/consumer chain (which yields exactly
  KampPrior:519/522); the 4 additional directory-wide sorries are documented above as
  pre-existing out-of-scope debt off the completeness path. No paper-over: full census reported.

---

## Files touched (task 368, all phases)

Production (5):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorAmbientDeepAnchorProbe358K.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

Artifacts:
- `specs/368_.../plans/01_ambient-deep-anchor-guard.md` (status markers)
- `specs/368_.../summaries/01_ambient-deep-anchor-guard-summary.md` (this file)
- `specs/368_.../.orchestrator-handoff.json`, `.return-meta.json`

---

## Next action

`/revise 358` then `/implement 358` — re-key task 358's Phases 4-8 to construct the discharge
terms this guard's interface dictates (m≥1 rows 5/6/10-13 now carry the σ-independent
`kvE_ambientDeepAnchor qnf = true` antecedent, dischargeable via `kvE_ambientDeepAnchor_of_realized`
+ `kvE_ambientDeepAnchor_iff`, m=0-vacuous via `kvE_ambientDeepAnchor_zero`).
