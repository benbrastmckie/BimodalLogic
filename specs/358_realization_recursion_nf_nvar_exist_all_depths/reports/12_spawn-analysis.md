# Blocker Analysis: Task #358

**Parent Task**: #358 - Realization recursion: land the nf_nvar_exist_all_depths n>=1 arms
**Generated**: 2026-07-15
**Blocker**: Verdict (C), machine-confirmed by an H5 divergence audit: the
`{σ-realizer, kvE_futPos firing, deep render}` triple at Plan v09 Phase 5 (Crux A, currently
`[PARTIAL]`) is a closed mutual cycle with no landed base producer. No re-sequencing of existing
infrastructure can discharge it; a new lemma must be built.

## Root Cause

The audit report (`specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md`)
enumerates every landed lemma that produces any node of the cycle and finds each one gated by
another node of the same cycle:

- `igFoldBit_realize_iff` (`InteriorGateGeneralK.lean:563`) — the only fold-bit -> model-realizer
  bridge — requires `h : nf_eval_nf M (k+1) 3 [w,x,t] qnf` (the deep render) as hypothesis. It is
  **render-gated**.
- `kvE_futPos_of_realizer` (`ExteriorPinnedConverseK.lean:252`) — the only landed producer of
  `temporal_truth M t (kvE_futPos P σ)` — requires `hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` (the
  σ-realizer). It is **realizer-gated**.
- The render itself is only *built* by `bracketEndChar_kv_step_sound`
  (`ExteriorGateAssembleK.lean:337-338`, delegation at `InteriorGateGeneralK.lean:1150-1165`)
  from `hreal`/`hexcl` — i.e. from the very obligations (rows 5-6 of `KampPrior.lean:964-970`)
  the cycle is trying to discharge.

Root cause (single shared diagnosis across three prior dispatches — v07/Phase 4, v08/render-
adjudication, v09/Crux-A — each independently assumed a different escape from this cycle and was
independently refuted by machine fact; see the audit's divergence table): **`igFoldBit` is lossy
(finding F1)**. `igPtW@w` (`InteriorGateGeneralK.lean:243`) carries only the AtW zone over
depth-`k` **1-types** `χ : NF k 1` — a lossy fold projection of `qnf`'s arity-4 fibers `σ`. No
hypothesis available at the interior site can rebuild the arity-4 σ-realizer from that 1-type
content. Rabinovich 2014 (Cor 5.4(1)⇐, corpus chunk_0015 lines 23-29) fires the future witness
**directly** from the full `Until` formula without ever folding the bracket sequence into 1-type
bits — the fold is a Lean-encoding deviation from the source, not a structural necessity, which is
why a **new lemma sourcing the firing from the carrier's endpoint `Until`** (not from the render,
not from the σ-realizer) is the audit's recommended fix.

This blocks Plan v09 Phase 5 (`kampPrior_hreal_supply`, statement landed in
`InteriorHrealSupplyK.lean:60`, body currently a tracked strategic sorry at `:116` per the
Crux-A handoff, `specs/358_.../handoffs/phase-5-crux-a-handoff-20260714.md`) and, transitively,
every phase downstream of it (Phase 6 Crux B, Phase 7 rows 12-13, Phase 8 rows 10-11, Phases 9-10).

## Proposed New Tasks

### New Task 1: M1 endpoint-sourced kvE_futPos supply (break render/realizer cycle for 358)
- **Effort**: high (Lean4, new mathematics + a bounded feasibility gate)
- **Task Type**: lean4
- **Rationale**: This is the exact missing infrastructure identified by the audit's Corrected
  Target. It is the sole way to discharge task 358 Plan v09 Phase 5 (`kampPrior_hreal_supply`)
  without re-encountering the cycle. No other task or existing lemma can supply it — the audit's
  H4 adversarial self-verification pass confirmed no landed lemma secretly closes the gap.
- **Depends on**: None (foundational; it is a new, downstream-of-`KampPrior` leaf that consumes
  only already-landed infrastructure — `P.correct`, `kampPrior_futRealizer_of_pos`, and the
  carrier's own `igEpR`/`igEpL` endpoint evals that `step_sound` already destructs).

## Dependency Reasoning

- **Task 358 depends on New Task 1**: Task 358's Plan v09 Phase 5 cannot be re-dispatched against
  the current `kampPrior_hreal_supply` binder — the audit explicitly states "Do NOT re-dispatch
  Phase 5 against the current interface" because it is provably under-provisioned (F1 lossy-fold
  refutation). New Task 1 must land the M1 lemma (`kvE_futPos_supply_of_endpoint` + past mirror)
  and enrich the `bracketEndChar_kv_step_sound`/`step_correct` binders with the `hepL`/`hepR`
  endpoint evals *before* task 358's Phase 5 body can be filled without circularity. This is a
  genuine implementation-detail dependency, not just an ordering courtesy: task 358's Phase 5
  discharge code (`kampPrior_hreal_supply`, enriched with `hepL`/`hepR`) directly calls the M1
  lemma by name in its zone-split branch, per the audit's dependency sketch. Task 358 cannot be
  correctly re-dispatched until New Task 1's exact target signature (or its M2 fallback shape, if
  M1's feasibility gate fails) is known, because the enriched binder's shape depends on which of
  M1/M2 the new task lands.

No other proposed tasks exist to reason about independence for — a single new task is sufficient
per the Task Minimization Principle: the audit's own recommendation is one dedicated infra task,
and its Phase-1 feasibility gate (M1 vs M2 fallback) is an internal decision point within that one
task, not a separable task, because the gate's outcome determines the rest of that same task's
implementation shape (it is not independently useful work).

## New Task 1 — Full Description (for task creation)

**Title**: M1 endpoint-sourced kvE_futPos supply (break render/realizer cycle for 358)

**Source of truth**: `specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md`
(H5 divergence audit, verdict C — missing infrastructure). Also consult the crux-A circularity
witness at `specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-5-crux-a-handoff-20260714.md`.

**Mandatory Phase 1 — bounded feasibility adjudication (must run FIRST, before any binder
enrichment or M1 body construction)**: M1's core proof obligation is upgrading the 1-type `Until`
witness that `igEpR@t` provides (`Until(charK χ, top)`, `InteriorGateGeneralK.lean:219`) to a
full arity-4 `σ`-witness, using only `hAmb : kvE_ambientDeepAnchor qnf = true` (a purely syntactic
EF-closure guard, `ExteriorAmbientDeepAnchorK.lean:131` — no `M`, no carrier) plus
`hcons : kvE_fiberConsistent σ = true` and the depth-`(k+1)` saturation of `M`. The prior audit's
own H4 adversarial pass could **not** machine-verify this upgrade step is provable — it is an
UNRESOLVED RISK, not a known-good path. Phase 1 must run a bounded `lean_multi_attempt`-style
adjudication of this specific 1-type -> arity-4 step under `hAmb` and produce a definitive
verdict before committing to either target:

- **If the upgrade is provable**: proceed to build **M1** —
  `kvE_futPos_supply_of_endpoint` (+ past mirror `kvE_pastPos_supply_of_endpoint` using
  `hepL`/`igEpL`/`Since`), in a NEW leaf downstream of `KampPrior`
  (e.g. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorEndpointFiringSupplyK.lean`,
  following the `InteriorHrealSupplyK.lean` precedent of a leaf deliberately NOT added to the
  `NfMultiAnchorBridge` aggregator to avoid an import cycle, but still built by default `lake
  build`). Target signature (from the audit's Corrected Target section):
  ```
  theorem kvE_futPos_supply_of_endpoint (P : ExistProviders sig atomMap k) (M : ...)
      (hepR : (igEpR ... (igFoldBit qnf)).eval_at M atomMap t)   -- the Until firing, carrier-provided
      (hAmb : kvE_ambientDeepAnchor qnf = true)
      (σ : NormalForm sig (k+1) 4) (hmark : qnf.2 σ = true) (hcons : kvE_fiberConsistent σ = true)
      (hfut : kvE_futAdmissible σ = true) :
      temporal_truth M atomMap t (kvE_futPos P σ)
  ```
  This sources the firing from `igEpR@t` (NOT the render), so `kampPrior_futRealizer_of_pos` +
  `P.correct` then build the σ-realizer with no cycle (see the audit's dependency sketch,
  §Corrected Target, for the full no-cycle diagram). This requires enriching the row-5 `hreal`
  binder consumers — `bracketEndChar_kv_step_sound`/`step_correct` — with the `hepL`/`hepR`
  endpoint evals they already destruct and currently discard.

- **If the upgrade is NOT provable** (fold loss irreparable at the endpoint): fall back to
  **M2** — a de-folded interior carrier that keeps the full arity-4 fiber content at the
  endpoints (a non-`igFoldBit` variant of `igEpR`/`igPtW`), making the render's fiber layer
  directly readable. This is a larger refactor of `InteriorGateGeneralK.lean` (carrier redesign)
  and should be scoped and documented as such if M1 is refuted — do not attempt it speculatively
  before the Phase 1 gate returns a negative verdict.

**File sites to consult / touch**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:563`
  (`igFoldBit_realize_iff`, render-gated bridge — the lemma M1 must route around)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:209/219`
  (`igEpL`/`igEpR` endpoint firing definitions — `Since`/`Until` over 1-types)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:243`
  (`igPtW`, the lossy AtW-zone-only carrier — root cause F1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:1150-1165`
  (`step_sound`'s fiber-layer delegation to `hreal`/`hexcl` — where the enriched binder plugs in)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean:252`
  (`kvE_futPos_of_realizer`, realizer-gated — the other cycle edge M1 must avoid)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean:337-338`
  (`bracketEndChar_kv_step_sound`, render production site — binder to enrich with `hepL`/`hepR`)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:964-970` (rows 5-6, the `hreal`/
  `hexcl` obligations M1 ultimately discharges)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/PriorInterface.lean:38-46`
  (`ExistProviders.correct`, the depth-`k` IH M1 threads)

**Definition of done**: M1 (or, if the Phase 1 gate refutes M1, a scoped-and-documented M2 plan)
lands sorry-free; `bracketEndChar_kv_step_sound`/`step_correct` binders are enriched with
`hepL`/`hepR`; `lake build` green; zero new vacuous defs/axioms beyond the existing floor
(`propext, sorryAx, Classical.choice, Quot.sound`). If M1 is refuted and M2 is scoped instead,
mark this task's outcome accordingly and hand off the M2 refactor scope explicitly rather than
attempting it in the same dispatch.
