# Implementation Summary: Task #364 — Strengthen kvE_fiberElemConsistent mate check

- **Task**: 364 - Strengthen kvE_fiberElemConsistent mate check against planted unrealizable mates
- **Status**: IMPLEMENTED (all 6 phases green, zero debt)
- **Session**: sess_1784050830_a53a7b
- **Date**: 2026-07-14
- **Plan**: plans/01_strengthen-fiber-mate-check.md (all phases [COMPLETED])

## Which approach landed

**Approach (b)-JOINT SYNTHESIS** — realizability-anchored mate, taken **jointly with the
ambient σ** (not standalone). The exact final mate-check form
(`ExteriorFiberConsistencyK.lean`, `kvE_fiberElemConsistent`, succ arm):

```lean
(Finset.univ.toList (α := NormalForm sig (j + 1) (n + 1))).any fun s' =>
  σ.2 s' && decide (mergeNF (e.atom_assgn) ⟨1, by omega⟩ = s'.atom_assgn) &&
    @decide (∃ (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
        (u : M.carrier),
        nf_eval_nf M (j + 2) n env σ ∧
        nf_eval_nf M (j + 1) (n + 1) (Fin.cons u env) s')
      (Classical.dec _)
```

i.e. the task-363 atom-row match PLUS one new conjunct: the mate `s'` must be **co-realized
with σ in some model** (`∃ M env u, σ` realized at `env` ∧ `s'` realized at `Fin.cons u env`).
Everything else is byte-stable: name, signature, the `| 0, _, _, _ => true` depth-0 arm,
`kvE_fiberElemConsistent_zero` / `kvE_fiberConsistent_zero` (still `rfl`-based), and the
`kvE_fiberElemConsistent_of_realized` / `kvE_fiberConsistent_of_realized` statements. All five
consumer modules (`ExteriorNegationK`, `ExteriorNegationPastK`, `EndIntervalConsumerK`,
`ExteriorPinnedConverseK`, `KampPrior`) compiled with ZERO statement or script changes.

### Adjudication record (why not (a), why not standalone (b))

- **(a) syntactic mate-content comparison** (swap-row / diagonal-row constraints on the
  mate's `.2` marking): rejected as short-cycle plantable. The honest semantics is reflexive —
  drop∘swap of `e_P`'s row returns `s*`'s own row and `s*.2 e_P = true`, so a
  content-manufacturing plant closes a 2-cycle with `s*` itself; the diagonal form is 1-cycle
  self-supporting. At the probe's critical depth the inner witnesses are depth 0, so rows are
  all any syntactic condition can compare.
- **(b) standalone realizability**: rejected — defeated by the honest-in-M2M mate
  `nf_characteristic M2M 1 5 [20,25,15,2,21]` (genuinely realizable, exact required row,
  interior-zoned).
- **(b)-joint (landed)**: honest preservation costs exactly one witness
  (`⟨M, env, u, hσ, nf_characteristic_satisfies⟩`), and the adversarial game closes
  **universally** (see Gate 3a below). Literature grounding: Rabinovich Def 4.1 (PDF p.5)
  interprets every E[Σ]-atom of the canonical expansion as `{a ∈ M | M, a ⊨ A}` — point
  content is realization content, so a mate ungrounded in any joint realization of the
  ambient is not a Def-4.1 mate at all.

## Certificate inventory (all sorry-free, kernel-checked axioms `[propext, Classical.choice, Quot.sound]`)

New (in `ExteriorFiberConsistencyProbe364K.lean`, stated against PRODUCTION definitions):

| Gate | Certificate | Statement |
|------|-------------|-----------|
| 1a | `kvE_probe364_plant_rejected` | `kvE_fiberElemConsistent m2sigma m2sstar = false` |
| 1a/5 | `kvE_probe364_sigma2_sstar_inconsistent` | canonical DoD alias of Gate 1a |
| 1b | `kvE_probe364_m1fake_rejected` | `kvE_fiberElemConsistent m1sigma m1sstar = false` |
| 2a | `kvE_probe364_honest_tau_consistent` | `kvE_fiberConsistent m2tau = true` |
| 2a | `kvE_probe364_honest_fiber_consistent` | uniform in `r : ℤ`, every pinned fiber passes |
| 3a | `kvE_probe364_sstar_honest_unrealizable` | ANY `X` marking `s*` + one honest fiber is realized in NO model |
| 3a | `kvE_probe364_replant_selfdefeating` | for every such `X`: `kvE_fiberElemConsistent X m2sstar = false` |
| 3a | `kvE_probe364_adapted_plant_rejected` | concrete strongest re-plant `σ₃ = τ ⊕ s* ⊕ mate₃` rejected |
| 5 | `kvE_probe364_sigma2_slice_inconsistent` | `kvE_fiberConsistent m2sigma = false` |
| 5 | `kvE_probe364_sigma2_inadmissible` | `kvE_futAdmissible m2sigma = false` |

Production (re-proved, signatures byte-identical): `kvE_fiberElemConsistent_of_realized`,
`kvE_fiberConsistent_of_realized`, `kvE_fiberElemConsistent_zero`, `kvE_fiberConsistent_zero`.

Regression re-run (kernel `#print axioms`, all floor):
- All 8 task-363 GO certificates in `ExteriorFiberConsistencyProbeK.lean` (fake excluded 1, 2,
  6, 7; honest preserved 3, 4, 5a/5b, 8 including `kvE_probe363_tau_admissible`). Only cert 1
  needed a proof-script repair (one extra `Bool.and_eq_true` destructure discarding the new
  conjunct); statements all frozen.
- M1 residual: `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` green.
- `kvE_probe358_eP_atomMate_present` KEPT green as the permanent atom-row regression record
  (the row is present; it no longer suffices), with a task-364 supersession record added to
  the 358K module and theorem docstrings.

## Adversarial re-plant outcome (Gate 3a)

Closed **universally**, stronger than the plan's single-plant requirement: any adapted slice
`X : NormalForm m2sig 2 4` marking both `s*` and one honest fiber
(`nf_characteristic M2M 1 5 (Fin.cons hf m2env4)`, ANY `hf : ℤ`) admits **no** joint
realization — `s*` forces an interior `P`-point via its marked witness `e_P`
(`P v ∧ env'₁ < v < env'₃`), while every honest fiber's quant layer is decided in `M2M`
(where `P ∩ (15,18) = ∅`) and cannot mark the realized interior-`P` 6-type. Slice-equality
forces honest exterior fibers to stay marked, so every re-plant in the countermodel's
constraint set is self-defeating. Concrete instance mechanized at the strongest plant
`mate₃ := char M2M 1 5 [20,25,15,2,21]` (the honest-in-M2M realizable mate that defeats both
rejected candidate families). No redesign loop was consumed.

The phase-2 handoff's u-class enumeration is superseded at guard level: no per-class mate
supply can service ANY class inside an unrealizable ambient (recorded in the leaf docstring).

## Retired / superseded record decisions

- `kvE_probeM1_sliceId_NOGO`: remains retired-to-git-history by task 363 — its absence is the
  documented expected state, NOT a regression (not resurrected).
- `kvE_probe358_eP_atomMate_present`: NOT retired — kept true and green as the atom-row
  regression record; superseded at guard level by `kvE_probe364_sigma2_*`.
- `kvE_fiberElemConsistentV2` (probe candidate): promoted verbatim into
  `kvE_fiberElemConsistent` and the duplicate dropped (363 promotion precedent); the leaf is
  the permanent regression record against the production names.

## Zero-debt verification

- Full `lake build`: green (1759 jobs).
- Kernel `#print axioms` sweep over all 14 new/changed certs + 10 regression certs: floor
  axioms only, no `sorryAx`.
- KampPrior sorries: exactly 2 (`:519`/`:522`), unchanged — not touched.
- Frozen layers (rung0/rung1, task-360 m=0 supply, `kampPrior_case1_arm_k0`): byte-unchanged
  (`git diff --name-only` over the change set shows only the four planned files).
- No vacuous definitions introduced (repo-wide pattern scan: the single hit is pre-existing
  in `Examples/TemporalStructures.lean:269`, outside scope, where the domain is genuinely
  trivial).

## Files touched

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean` — in-place restatement + docstrings + `_of_realized` witness
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean` — cert-1 proof-script repair only
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` — NEW probe leaf / regression record
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean` — docstring supersession record only

## Re-key notes for task 358 (Phase 2/3 resume)

The strengthened interface shapes the G2 supply witness as follows: to discharge
`kvE_fiberElemConsistent σ s = true` for an honest σ, the mate obligation now requires
exhibiting a **joint co-realization** `⟨M, env, u⟩` of σ and the mate — NOT a fresh-projection
content payload. For σ's arising from realizers (the supply population), this is free via
`kvE_fiberElemConsistent_of_realized` / `kvE_fiberConsistent_of_realized` /
`kvE_futRealizer_admissible`, whose statements are unchanged — the supply proofs should route
through these lemmas and never unfold the guard body. The σ₂ doppelgänger is now excluded at
all three levels (`kvE_probe364_sigma2_{sstar_inconsistent,slice_inconsistent,inadmissible}`),
and the universal certificate `kvE_probe364_sstar_honest_unrealizable` is available as an
engine for excluding future adapted fakes. Resume `/implement 358` (Phase 2, plan v04).

## Plan Deviations

- Phase 1 *(altered)*: adjudication landed the (b)-joint synthesis rather than the plan's
  primary approach (a) — every (a)-style syntactic content comparison was shown short-cycle
  plantable at design level (swap 2-cycle via `s*`, diagonal 1-cycle), and (b)-standalone is
  defeated by the honest-in-M2M mate. Authorized by the plan's "approach (a), (b), or
  synthesis, adjudicated in-task" clause; full record in the leaf docstring.
- Phase 1/3 *(altered)*: the Phase-3 universal engine (`kvE_probe364_sstar_honest_unrealizable`)
  was front-loaded into Phase 1, since it is the candidate's core validation mechanism; Gates
  1a/1b are corollaries of it rather than replicated row-contradiction scripts (the original
  row proof remains live in the repaired production probe, cert 1).
- Phase 4 *(altered, narrower than planned)*: only ONE of the four ProbeK fake-exclusion
  certificate proofs needed repair (cert 1); certs 2, 6, 7 consume cert 1 or the unchanged
  `kvE_futAdmissible` skeleton and compiled untouched.
- Phase 5 *(altered)*: successor certificates placed in the 364 leaf rather than
  `ExteriorPinnedProbe358K.lean` (the m2 cast objects are `private` in 358K; the plan's "or
  the 364 leaf" option was taken); 358K received the docstring supersession record only.
- No skipped or deferred items; no redesign loop consumed; no scope widening.
