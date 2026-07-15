# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Re-Keyed to Task 368's Ambient Deep-Saturation/EF-Closure Guard `kvE_ambientDeepAnchor` (v07)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by supplying the depth>=1 interior/exterior obligations against task 368's ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`, and by PRODUCING the genuine realizer `hsigma` (Rabinovich 2014 Cor 5.4(1)⇐, p.9) that discharges the interior `hreal`/`hexcl` and the exterior converter seam.
- **Status**: [NOT STARTED]
- **Effort**: 20-32 hours remaining (Phases 1-3 [COMPLETED]; 5 build/rewrite phases, each bounded to ~one agent run with a machine gate; heavy phases carry named green-commit split points)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface), 364 (completed — co-realization mate check), 367 (completed — fiber-side deep-anchor guard `kvE_deepOnFiber`), **368 (completed, verified — ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`; CLOSED the plan-06 Phase-4 BLOCKER by excluding CM-A/CM-B from the antecedent population, 2026-07-14)**
- **Research Inputs**:
  - specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/summaries/01_ambient-deep-anchor-guard-summary.md (2026-07-14 — AUTHORITATIVE driver for this revision: the landed ambient guard, its byte-stable API, the consumer-binder restatement, the residue-row decision, and the certificate inventory)
  - reports/10_spawn-analysis.md (round 10 — the blocker decomposition that produced task 368: CM-A/CM-B root cause = P17 anchor-content gap on the AMBIENT side; the probe-first, one-task, 367-mirrored prescription)
  - plans/06_deep-anchor-rekey-v06.md (superseded plan; its Phase-4 BLOCKER record is the countermodel ground truth task 368 answered; Phases 1-3 preserved verbatim from it)
  - reports/08_g2-rekey-against-364-interface.md (round 8 — byte-stable 364 discharge-lemma routing, still binding)
  - reports/06_remaining-work-and-plan-revision.md (round 6 — two-live-sorry map, ordered decomposition, verification bar)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, routes R1-R5; the *mathematics* of each gap)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐ grounding; corpus: `~/Projects/Literature/sources/rabinovich_2014/chunk_0014`-`chunk_0015` — Lemma 5.3 Dedekind `inf`-selection + the Cor 5.4(1)⇐ two-way `min`/case-split. CITATION RULE (sub-index hazard): cite the PDF by page number only, e.g. "Rabinovich 2014, Cor 5.4, p.9"; NEVER md:NN line numbers)
- **Reports Integrated**: specs/368 summary 01 (v07 — new), reports/10_spawn-analysis.md (v07 — new), specs/367 summary 01 (v06, carried), phase-2-v05-handoff (v06, carried), 08_g2-rekey-against-364-interface.md (v05), 06_remaining-work-and-plan-revision.md (v04), 04_post-360-gap-map-and-route.md (v03/v04), 02_literature-proof-method-survey.md (v02)
- **Artifacts**: plans/11_deep-anchor-rekey-v07.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (Literature Fidelity; Vacuous Definitions PROHIBITED; zero-debt terminus)
- **Type**: lean4

## Overview

Retire the LAST TWO live Kamp-path sorries in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (verified current this revision):
- **S1** at `:519` — the `| _k + 2, _sub_nf =>` **k>=2 residual** of the `| 1 =>` arm (k=0/k=1 legs
  FROZEN, see Preserved Assets);
- **S2** at `:522` — the `| n + 2 =>` **arity-lift arm** (off critical path, in-scope for zero-debt).

**What changed since v06.** Plan v06's Phase 4 was [BLOCKED]: the `igPtW`-guarded ledger rows
5/6/10-13 were machine-proven FALSE-as-stated at m >= 1 by two paper countermodels INSIDE the
antecedent population — CM-A (kills row 13: a deep-incomplete homogeneous-ℤ fake ambient) and CM-B
(kills row 5: an ambient-side tail-doppelgänger). Root cause: `igFoldBit`/`igPtW` read `qnf.2` only
at PROFILE level, leaving deep content below a bucket unconstrained — the **P17 anchor-content gap**
resurfacing on the AMBIENT side (the fiber-side twin having been closed by 367). **Task 368 has
landed the prescribed ambient-side refinement**: a σ-independent EF-closure guard
`kvE_ambientDeepAnchor qnf : Bool` (NEW production module
`NfMultiAnchorBridge/ExteriorAmbientDeepAnchorK.lean:109`), added as a SINGLE antecedent
`kvE_ambientDeepAnchor qnf = true →` to the igPtW-guarded binders (rows 5, 6, 10-13) of
`EndIntervalConsumerK.lean`, their mirrors in `ExteriorGateAssembleK.lean`
(`bracketEndChar_kvExt_correct_prior`, gate-formula strengthened via a second `enrichEndpoints`
layer / `kvE_ambientGuardForm`), and `kampPrior_site_rungK_gate_match`
(KampPrior.lean:964/971/1003/1010/1017/1024). The guard is m=0-VACUOUS (`kvE_ambientDeepAnchor_zero`,
`rfl`), so NO new residue rows were added and the frozen task-360 m=0 supply still discharges the
m=0 instances. Both fake ambients are machine-excluded (`kvE_probe368_cmA_ambient_rejected`,
`kvE_probe368_cmB_ambient_rejected`), honest ambients pass
(`kvE_ambientDeepAnchor_of_realized` / `kvE_probe368_real_ambient_anchored`), and the hereditary
depth-2 and copy-plant variants are handled
(`kvE_probe368_depth2_ambient_rejected`, `kvE_probe368_ambient_copyPlant_collapses`).

**What is now unblocked.** With CM-A/CM-B excluded by construction, the `igPtW` → ambient-realization
bridge that plan v06's Phase-4 mitigation relied on is NO LONGER circular: under the added
`kvE_ambientDeepAnchor qnf = true` hypothesis the fake ambients are gone, so rows 5/6/10-13 are true
as restated and their supply theorems can be built. Task 368 delivered the INTERFACE ONLY (guard +
API + restated binders + probes) and explicitly did NOT build the supply theorems — those are this
task's responsibility (spawn-analysis §"SCOPE BOUNDARY").

**The crux is UNCHANGED and now unobstructed: PRODUCE `hsigma`** — the genuine interior/exterior
realizer `nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`, selected per Rabinovich 2014 Cor 5.4(1)⇐ (p.9) via the
two-way `min`/case-split induction. The engine is LANDED sorry-free
(`kampPrior_fChain_realize_from` KampPrior.lean:1415, `_bracket` :1549,
`kampPrior_{fut,past}Realizer_assemble` :1602, `_of_pos` :1662 + Past mirrors) — this task
INSTANTIATES it.

**Definition of done** (binding): `:519` and `:522` both sorry-free; all igPtW-guarded rows 5/6/10-13
discharged with the `kvE_ambientDeepAnchor qnf = true` antecedent supplied via
`kvE_ambientDeepAnchor_of_realized` (NEVER by unfolding the guard) and witnesses/mates extracted only
through `kvE_ambientDeepAnchor_iff`; full-tree `lake build` GREEN;
`#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete` =
`[propext, Classical.choice, Quot.sound]` (+ acceptable `ofReduceBool`/`trustCompiler` from
`native_decide` in the Syntax layer) with **NO `sorryAx`**; all task-368 + prior-family
(367/364/363/358/M1) certificates re-verified green at floor axioms; guard-unfold source scan = 0.
`:522` CANNOT be silently deferred. **ZERO-DEBT TERMINUS**: no sorry, no vacuous definition, no
forcing a proof against a live countermodel — a sub-piece that cannot close green goes [BLOCKED] with
structured escalation, never a landed sorry.

### Research Integration

Newly integrated this revision (v06 -> v07):

- **specs/368 summary** (01_ambient-deep-anchor-guard-summary.md). Integration effects:
  1. **v06 Phase-4 blocker DISSOLVED at interface level.** CM-A and CM-B are machine-excluded by
     `kvE_ambientDeepAnchor` (`kvE_probe368_cmA_ambient_rejected`, `kvE_probe368_cmB_ambient_rejected`,
     both floor-axiom green). The igPtW → ambient bridge is de-circularized: the guard antecedent
     removes exactly the ambients that broke it. Phases 4-8 are re-keyed and unblocked.
  2. **The re-key is by a SINGLE σ-independent antecedent** `kvE_ambientDeepAnchor qnf = true →` on
     rows 5/6/10-13 — NOT a per-σ split. Unlike 367 (which added rows 12-13), 368 added NO new
     residue rows (residue-row decision: m=0-vacuous through `_zero`). The ledger stays 13 rows.
  3. **The supply discharge route is fixed**: consume the guard hypothesis (`hAmb`) inside each
     supply proof; render ambient realization from `hAmb` + igPtW (now sound); extract EF-closure
     mates via `kvE_ambientDeepAnchor_iff`; where a realizer must FEED a guard-demanding consumer,
     produce `kvE_ambientDeepAnchor qnf = true` via `kvE_ambientDeepAnchor_of_realized` (general
     `OrderedMonadicStructure`) — NEVER unfold the guard body.
  4. **Rows 8-9 (`hslicePast`/`hsliceFut`, KampPrior.lean:989/996) do NOT carry the ambient
     antecedent** (confirmed against the landed binders) — they are gated by `kvE_deepOnFiber` (367)
     and ambient realization only. Phase 3's landing (`ExteriorDeepSliceSupplyK.lean`) is therefore
     UNAFFECTED by the ambient-side strengthening and stays [COMPLETED] byte-for-byte (spawn-analysis
     §"What Is Already Banked" confirms it survives ambient-side strengthening).
  5. **Frozen-layer confirmation**: 368's terminal audit (G4) changed exactly 5 files
     (`ExteriorAmbientDeepAnchorK.lean` NEW, `ExteriorAmbientDeepAnchorProbe358K.lean` NEW,
     `ExteriorGateAssembleK.lean`, `EndIntervalConsumerK.lean`, `KampPrior.lean`); ALL 363/364/367
     files, the m=0 `_zero` kernels, k<=1 rungs, task-360 supply, and
     `ExteriorDeepSliceSupplyK.lean` are byte-unchanged. Baseline for this task is 368's terminal
     commit; the completeness-chain sorry residual is exactly `:519`/`:522`.
- **reports/10_spawn-analysis.md**: the CM-A/CM-B characterization and the "interface-only" scope
  boundary are carried as binding constraints — this task builds the supply theorems the guard's
  restated binders now demand; it does NOT touch the guard, its API, or the probe leaf.

Carried from v06 (still integrated): specs/367 summary (fiber guard `kvE_deepOnFiber` + API — still
the rows-8-9 gate, still consumed by Phase 3's landing), report 08 (byte-stable 364 discharge
routing), report 06 (flow G2 -> G1 -> arm rewrites), report 04 (gap mathematics), report 02
(Rabinovich engine grounding).

### GLOBAL ROUTING CONSTRAINT (binding on Phases 4-8)

**Never unfold ANY guard body.** All consumption of the layered guards MUST route through the
byte-stable lemmas; hand-attacking a guard body re-opens a closed plantability surface:

| Guard | Sanctioned discharge/reading routes (ONLY these) |
|---|---|
| **`kvE_ambientDeepAnchor` (368)** | `kvE_ambientDeepAnchor_of_realized` (ExteriorAmbientDeepAnchorK.lean:195 — honest discharge at GENERAL `OrderedMonadicStructure`, PRODUCE guard=true from a realizer), `kvE_ambientDeepAnchor_zero` (:125, `rfl` m=0 inertness), `kvE_ambientDeepAnchor_iff` (:131, the ONLY deep-arm ∀τ∀ρ∃σ' readback / mate-extraction direction) |
| `kvE_deepOnFiber` (367) | `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 — honest discharge, needs ambient realized + σ realized), `kvE_deepOnFiber_zero` (:94, `rfl` m=0), `kvE_deepOnFiber_row` (:127, guard → old row), `kvE_deepOnFiber_iff` (:106, deep-arm extraction) |
| `kvE_fiberElemConsistent` / `kvE_fiberConsistent` (363/364) | `kvE_fiberElemConsistent_of_realized`, `kvE_fiberConsistent_of_realized` (ExteriorFiberConsistencyK.lean) |
| `kvE_futAdmissible` / `kvE_pastAdmissible` (363/364) | proving: `kvE_futRealizer_admissible` (+Past); reading: `kvE_futAdmissible_fiber_dichotomy`, `_onFiber`, `_offFiber` |

Per-phase verification includes a source scan of newly added proofs for
`rw`/`unfold`/`simp only` on `kvE_ambientDeepAnchor`, `kvE_deepOnFiber`, `kvE_fiberElemConsistent`,
`kvE_fiberConsistent`, `kvE_futAdmissible`, `kvE_pastAdmissible` — zero occurrences allowed outside
their home modules.

### RE-PROBE DISCIPLINE (363/364/367/368 house style, binding)

Every new supply theorem/kernel is machine-adjudicated against the EXISTING countermodel families
BEFORE being trusted: the ambient CM-A/CM-B casts (`kvE_probe368_cmA_ambient_rejected`,
`kvE_probe368_cmB_ambient_rejected` — must stay guard-false), the ambient depth-2 hereditary
doppelgänger (`kvE_probe368_depth2_ambient_rejected`), the ambient copy-plant collapse
(`kvE_probe368_ambient_copyPlant_collapses`), the fiber-side 367 family
(`kvE_probe367_tailDG_deep_rejected`, `_depth2DG_deep_rejected`, `_copyPlant_collapses`,
`_real_slice_deep_anchored`), the 364 plant family, and the 363 family. ALL prior
358/363/364/367/368 certificates must REMAIN green at floor axioms
`[propext, Classical.choice, Quot.sound]` at every phase gate. If a NEW countermodel is found against
a restated obligation: build the probe (additive leaf, sorry-free), record the binder-level closure
in its docstring, mark the phase [BLOCKED], and escalate — never force the proof.

### Preserved Assets (ALREADY LANDED — FROZEN, OUT OF SCOPE, do NOT re-open)

Green; consumed by name; MUST NOT regress, be re-derived, or overwritten. **PRESERVE
BYTE-FOR-BYTE**: m=0 kernels (`_zero` suffix family), k<=1 rungs, task 360's m=0 supply, ALL of task
363/364/367/368's guards/lemmas/probes, AND task 358 Phase 3's own landing.

| Landed asset | Interface (by name) | File:line | Owner |
|---|---|---|---|
| **k=0 arm of `\| 1 =>`** | `kampPrior_case1_arm_k0` | KampPrior.lean:~271 (consumed :504) | 358 P5.1 — **FROZEN** |
| **k=1 arm of `\| 1 =>`** | `kampPrior_case1_arm_k1` | KampPrior.lean (consumed :505) | 309 P20 — **FROZEN** |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | 350 — **FROZEN** |
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1415/1549/1602/1662 (+Past) | 358 P1-2 — sorry-free |
| Consumer stack + 13-row ledger (BINDING) | `endIntervalStepPrior`/`endInterval_step_correct`/ledger table | EndIntervalConsumerK.lean | 349+367+368 |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:941-1043 | 349 (368-mirrored binders) |
| **368 ambient guard + API** | `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized` | **ExteriorAmbientDeepAnchorK.lean:109/125/131/195** | **368 — the re-keying contract; FROZEN** |
| **368 gate carrier** | `kvE_ambientGuardForm`, `kvE_ambientGuardForm_truth`; `bracketEndChar_kvExt_correct_prior` | ExteriorGateAssembleK.lean | **368 — FROZEN, consume by name** |
| **368 probe certificates** | `kvE_probe368_{cmA,cmB}_ambient_rejected`, `_real_ambient_anchored`, `_{cmA_row13,cmB_row5}_refuted`, `_depth2_ambient_rejected`, `_ambient_copyPlant_{passes_guard,collapses}`, `_ambient_supply_route` | ExteriorAmbientDeepAnchorProbe358K.lean | **368 — GREEN adjudication evidence; cite, do not modify** |
| **367 deep-anchor guard + API** | `kvE_deepOnFiber` + `_zero`/`_base`/`_iff`/`_row`/`_of_realized` | ExteriorFiberDeepAnchorK.lean:81-168 | **367 — FROZEN** |
| **367 probe certificates** | `kvE_probe367_tailDG_deep_rejected`, `_real_slice_deep_anchored`, `_depth2DG_deep_rejected`, `_copyPlant_collapses` | ExteriorFiberDeepAnchorProbe367K.lean | **367 — FROZEN** |
| **358 Phase-3 landing** (rows 8-9 supply) | `kvE_hsliceFut_supply` (:131), `kvE_hslicePast_supply` (:161), `kvE_deepMate_collapse` (:90), `kvE_{fut,past}SliceEq_refl` (:63/:72) | **ExteriorDeepSliceSupplyK.lean** | **358 P3 — FROZEN; survives ambient-side strengthening** |
| **m=0 slice supply** (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (:1250) (+Past :769) | ExteriorPinnedConverse{K,PastK}.lean | 360 — **FROZEN, byte-unchanged through 368** |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_futSliceUnique_zero` (:1122)/`kvE_pastSliceUnique_zero` (:356) | ExteriorPinnedConverse{K,PastK}.lean | 360 — **FROZEN** |
| 363/364 fiber-consistency predicate + discharge | `kvE_fiberElemConsistent`/`kvE_fiberConsistent` (+`_zero`, `_of_realized` x2) | ExteriorFiberConsistencyK.lean | **FROZEN — consume by name, NEVER unfold** |
| 363/364 exterior guard + entry/readers | `kvE_{fut,past}Admissible`, `kvE_futRealizer_admissible` (+Past), `_fiber_dichotomy`, `_onFiber`, `_offFiber` | ExteriorNegation{K,PastK}.lean; ExteriorConverter{K,PastK}.lean | **FROZEN** |
| 364/363/358 rejection certificates | `kvE_probe364_*`, `kvE_probe363_*`, `kvE_probe358_*`, `kvE_probeM1_*` | ExteriorFiberConsistencyProbe{,364}K.lean; ExteriorPinnedProbe358{,Tail}K.lean; ExteriorPinnedProbeM1K.lean | **FROZEN — regression records** |
| Exterior converters (discharge templates) | `kvE_futBundle_of_realizer` (:231); `kvE_pastBundle_of_realizer` (:199) | ExteriorConverter{K,PastK}.lean | 356/360 — apply to genuine `hsigma` only |
| n=0 / k=0 target arms | `nf_nvar_exist_all_depths` `\| 0 =>`, `\| k+1, 0 =>` | KampPrior.lean | do NOT touch |

Task 360's m=0 supply and the k<=1 rungs are byte-unchanged through 363, 364, 367, AND 368; this plan
MUST keep them so. The m=0 discharge of the new ambient antecedent flows through
`kvE_ambientDeepAnchor_zero` (`rfl`, landed by 368) composed with the frozen task-360 `_zero`
supplies — no m=0 work remains.

## Goals & Non-Goals

- **Goals**:
  - Supply the exterior rows 12-13 (`hexclDeepFut`/`hexclDeepPast`) at general m: consume the
    `kvE_ambientDeepAnchor qnf = true` hypothesis + igPtW to render ambient realization, then close
    by the `kvE_deepOnFiber_of_realized` contradiction (a σ-realizer + ambient realized forces
    `kvE_deepOnFiber qnf σ = true`, contradicting the binder's `= false`).
  - Rebuild the G2-2 uniqueness kernel (`kvE_futSliceUnique`/`kvE_pastSliceUnique` general-m) over
    the ambient-guarded + deep-anchored population, extracting EF-closure only via
    `kvE_ambientDeepAnchor_iff`; supply rows 10-11 (`hexclSliceFut`/`hexclSlicePast`) consuming it.
  - **PRODUCE `hsigma`** (interior rows 5-6, `kampPrior_hreal_supply`/`kampPrior_hexcl_supply`):
    Rabinovich 2014 Cor 5.4(1)⇐ (p.9) within-bracket bounded witness selection through the landed
    engine; consume the `kvE_ambientDeepAnchor qnf = true` antecedent for the igPtW → ambient
    render; discharge `hfiberCons` via `kvE_fiberConsistent_of_realized`; discharge the exterior
    `hbr*`-shaped seam by APPLYING `kvE_{fut,past}Bundle_of_realizer` to the produced `hsigma`.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 13 ledger rows, PRODUCING
    `kvE_ambientDeepAnchor qnf = true` via `kvE_ambientDeepAnchor_of_realized` at the realized-ambient
    seam where the restated gate binders demand it; replace `:519`.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm; replace `:522`.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset — esp. the 368 guard/API/probe leaf,
    the 367 guard/API/probes, the `_zero` kernel family, the k<=1 rungs, task 360 m=0 supply, and
    task 358 Phase 3's `ExteriorDeepSliceSupplyK.lean` (rows 8-9 supply — already banked, unaffected).
  - Do NOT unfold any guard body (GLOBAL ROUTING CONSTRAINT) — byte-stable lemmas only.
  - Do NOT re-attempt v05's G2-1 (`kvE_{fut,past}SliceId_of_end` at general m via the free-env →
    pinned upgrade) — machine-refuted; superseded.
  - Do NOT re-key or re-supply rows 8-9 — they carry NO ambient antecedent and are done (Phase 3).
  - Do NOT re-introduce any `hbr*`-shaped UNIVERSAL binder; do NOT consume
    `kvE_{fut,past}Bundle_of_realizer` without a genuine produced realizer.
  - Do NOT re-derive, weaken, or re-probe CM-A/CM-B or add ambient guard machinery — task 368 owns
    the interface; this task consumes it.
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` M-independent.

## Risks & Mitigations

- **Risk: the ambient-realization render from `hAmb` + igPtW still does not close** even with CM-A/CM-B
  excluded — the guard restores truth but the *bridge construction* (`hcharK` + `P.correct` +
  `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam) must actually consume the
  `kvE_ambientDeepAnchor_iff` EF-closure to reconstruct the deep content. Mitigation: Phase 4 runs a
  bridge-adjudication gate FIRST (before any build), mirroring 368's own probe-first discipline; if
  the render needs more than `_iff` + igPtW provides, probe the exact gap against the CM-A/CM-B casts
  and [BLOCKED]+escalate — never force it.
- **Risk: rows 12-13 discharge needs the σ-realizer AND ambient realized simultaneously** for
  `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 needs both). Mitigation: the
  σ-realizer is the hypothesis being contradicted (`nf_eval_nf … σ`); the ambient realization is the
  Phase-4 bridge output. Both in scope at the binder site; adjudicate the bridge first.
- **Risk: G2-2 uniqueness at general m needs a deep transfer kernel** (EF-style exterior-chain
  matching). Mitigation: build over the ambient-guarded + deep-anchored population where the second
  witness's deep content is pinned; extract via `kvE_ambientDeepAnchor_iff`; probe against the
  countermodel families before trusting; [BLOCKED]+escalate on a new countermodel.
- **Risk: `hsigma` production (G1) exceeds one agent run.** Mitigation: Phase 5 is scoped to `hreal`
  only (the Cor 5.4(1)⇐ selection); `hexcl` is Phase 6. If Phase 5 overruns, split at the G1-1/G1-2
  boundary (population split vs. per-σ chain-firing) with a green commit between.
- **Risk: `:522` arity-lift does not close under either reduction route.** Mitigation: G4-1 route
  adjudication at Phase 8 start; if neither closes, [BLOCKED] + spawn an isolated arity-lift task,
  keep S1 landed — NEVER a carried sorry.
- **Risk: touching frozen layers.** Mitigation: per-phase `git diff` audit against the Preserved
  Assets table (esp. the exactly-5 368-changed files must not be re-touched beyond `KampPrior.lean`'s
  own arm bodies, and the 368 probe/guard leaves stay byte-identical); scoped `lake build` per phase;
  full-tree build + certificate re-verification at terminus.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 4 | -- (1-3 complete) |
| 2 | 5 | 4 |
| 3 | 6 | 4, 5 |
| 4 | 7 | 4, 5, 6 |
| 5 | 8 | 7 |

Phase 4 subsumes the 368 interface pin + re-probe gate (read-only) followed by the exterior supply
build; it carries named green-commit split points (pin-gate | G2-B1 rows 12-13 | G2-B2 uniqueness +
G2-B3 rows 10-11) so each sub-step is one agent run. Phase 5 (interior/KampPrior seam) and Phase 4
(exterior leaf) occupy disjoint territory but Phase 5 consumes Phase 4's uniqueness kernel in its
`hexcl` companion, so they are sequenced. Every phase ends with a machine gate: scoped build +
`lean_verify` at floor axioms + guard-unfold source scan + frozen-boundary git-diff audit.

### Phase 1: Consume and pin the task-363 interface [COMPLETED]

> **P1 outcome (2026-07-14, sess_1784045100_2e3ffe)**: all six checklist items executed —
> signatures/conjunct-2/antecedent-pair pinned by name; three re-probe certificates lean_verify
> GREEN at floor axioms; target signatures recorded in handoffs/phase-1-handoff-20260714.md.
> Anchor-content gate: PASSED-WITH-ADVERSE-FINDING — machine-confirmed in v05 P2 and DISSOLVED in
> three steps: task 364 (co-realization mate check), task 367 (fiber-side deep-anchor guard), and
> task 368 (ambient-side deep-anchor guard — this revision's driver).
- **Goal:** (historical) Bind 363's landed fiber-consistency interface by name.
- **Tasks:** (all executed; see plans/05 for the retained checklist)
- **Timing:** 1-2 hours (spent).
- **Depends on:** none.
- **Completed:** 2026-07-14 (sess_1784045100_2e3ffe).

### Phase 2: 367 fiber-guard interface pin + re-probe gate [COMPLETED]

> **P2 outcome (2026-07-14, sess_1784059448_2c72f2_358)**: all five checklist items executed —
> binders/mirrors/API/converters/SliceEq pinned by name; 14-certificate re-probe gate GREEN at floor
> axioms; Kamp sorries exactly :519/:522; zero source edits. Adjudication PRE-RESULT for Phase 3
> recorded in handoffs/phase-2-v06-handoff-20260714.md: the deep-mate COLLAPSES to σ itself, so
> SliceEq needs nothing beyond row + deep content.
- **Goal:** (historical) Pin the 367 restated rows-8-9 interface and machine-certify ground truth.
- **Tasks:** (all executed; see plans/06 for the retained checklist)
- **Timing:** 1-2 hours (spent).
- **Depends on:** none (Phase 1 complete).
- **Completed:** 2026-07-14 (sess_1784059448_2c72f2_358).

### Phase 3: Exterior rows 8-9 supply at general m (deep-mate route) [COMPLETED]

> **P3 outcome (2026-07-14, sess_1784059448_2c72f2_358)**: NEW leaf
> `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` — `kvE_hsliceFut_supply` (:131) /
> `kvE_hslicePast_supply` (:161) at GENERAL k (binder-shape-exact), via the mate-collapse kernel
> `kvE_deepMate_collapse` (:90) + `kvE_{fut,past}SliceEq_refl` (:63/:72). The guard's mate collapses
> to σ itself (Prod ext over a common marked fiber element), so the k>=1 arm concludes with σ' := σ;
> k=0 discharges through `kvE_deepOnFiber_zero` + the FROZEN 360 `_zero` supplies. Machine gate:
> scoped build green (1031 jobs); all three new theorems at floor axioms, no sorryAx; guard-unfold
> scan zero; frozen files byte-identical.
>
> **v07 note**: rows 8-9's binders (`hslicePast` KampPrior.lean:989, `hsliceFut` :996) carry NO
> `kvE_ambientDeepAnchor` antecedent — confirmed against the 368-landed gate_match signature. Task
> 368's ambient-side strengthening only strengthens the ambient-realization antecedent these binders
> already carry, so this landing is UNAFFECTED and stays FROZEN (spawn-analysis §"What Is Already
> Banked").
- **Goal:** (historical) Prove `kvE_hsliceFut_supply`/`kvE_hslicePast_supply` at general m.
- **Tasks:** (all executed; see plans/06 for the retained checklist)
- **Timing:** 4-6 hours (spent).
- **Depends on:** 2.
- **Completed:** 2026-07-14 (sess_1784059448_2c72f2_358).

### Phase 4: 368 ambient-guard interface pin + exterior rows 12-13/10-11 supply + G2-2 uniqueness (re-keyed) [NOT STARTED]
- **Goal:** Pin the 368-restated ambient-guarded binders and machine-certify ground truth (pin +
  re-probe gate, read-only), then complete the exterior ledger against the new interface: rows 12-13
  (`hexclDeepFut`/`hexclDeepPast`) via the `kvE_deepOnFiber_of_realized` contradiction under the
  ambient-render bridge; the G2-2 uniqueness kernel over the ambient-guarded population; rows 10-11
  (`hexclSliceFut`/`hexclSlicePast`) consuming carried `hreal` + uniqueness. This phase REPLACES plan
  v06's [BLOCKED] Phase 4 — the blocker is dissolved because `kvE_ambientDeepAnchor qnf = true`
  excludes CM-A/CM-B from the antecedent population.
- **Restated consumer binders discharged**: `hexclDeepFut` (KampPrior.lean:1024, mirror
  EndIntervalConsumerK.lean rows 13), `hexclDeepPast` (:1017, rows 12), `hexclSliceFut` (:1010, rows
  11), `hexclSlicePast` (:1003, rows 10) — each leads with `kvE_ambientDeepAnchor qnf = true →`.
- **Byte-stable 368 lemmas supplying the guard antecedent**: `kvE_ambientDeepAnchor_iff`
  (ExteriorAmbientDeepAnchorK.lean:131 — EF-closure extraction for the ambient render and uniqueness),
  `kvE_ambientDeepAnchor_zero` (:125 — m=0 vacuity), `kvE_ambientDeepAnchor_of_realized` (:195 — where
  a produced realizer must re-establish guard=true); `kvE_deepOnFiber_of_realized`
  (ExteriorFiberDeepAnchorK.lean:141 — the rows-12-13 contradiction engine).
- **Tasks:**
  - [ ] **Pin (read-only)**: pin `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized`
        (ExteriorAmbientDeepAnchorK.lean:109/125/131/195), the six ambient-guarded binders
        (KampPrior.lean:964/971/1003/1010/1017/1024) and their `EndIntervalConsumerK`/
        `ExteriorGateAssembleK` mirrors (`bracketEndChar_kvExt_correct_prior`, `kvE_ambientGuardForm`),
        and the frozen m=0 `_zero` supplies (`kvE_hexclSliceFut_supply_zero`
        ExteriorPinnedConverseK.lean:1250, `kvE_futSliceUnique_zero` :1122, +Past :769/:356). Record
        the exact general-m supply-theorem TARGET signatures in a phase handoff. Confirm rows 8-9
        carry NO ambient antecedent (Phase-3 landing unaffected).
  - [ ] **Re-probe gate** (before any build): `lean_verify` at floor axioms, no sorryAx — the nine
        `kvE_probe368_*` (`cmA_ambient_rejected`, `cmB_ambient_rejected`, `real_ambient_anchored`,
        `cmA_row13_refuted`, `cmB_row5_refuted`, `depth2_ambient_rejected`,
        `ambient_copyPlant_passes_guard`, `ambient_copyPlant_collapses`, `ambient_supply_route`), the
        four `kvE_probe367_*`, the six `kvE_probe364_*`, the five `kvE_probe363_*`, the three
        `kvE_probe358_*`, the two `kvE_probeM1_*`. Confirm Kamp-path sorries are exactly
        KampPrior.lean:519 and :522 (`grep -n "sorry"`). **Green commit** (`task 358 phase 4.0: 368
        interface pin + re-probe gate`).
  - [ ] **Bridge adjudication (before building the supply)**: verify on paper + by
        `lean_multi_attempt` that under `hAmb : kvE_ambientDeepAnchor qnf = true` + the igPtW guard,
        ambient realization at `[w,x,t]` is renderable (the `hcharK` + `P.correct` +
        `kampPrior_existProviders_of_ih_existF0_char` bridge, now de-circularized because CM-A/CM-B
        are guard-excluded — consume `kvE_ambientDeepAnchor_iff` for the deep content). If the render
        fails, STOP: probe the gap against the CM-A/CM-B casts, [BLOCKED]+escalate.
  - [ ] **G2-B1 (rows 12-13)**: prove `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply`
        general-m matching the `hexclDeepFut`/`hexclDeepPast` binder shape (KampPrior.lean:1024/1017):
        take `hAmb` + igPtW → render ambient realized; suppose a realizer of σ at the pinned exterior
        tuple; `kvE_deepOnFiber_of_realized M env x1 qnf σ (ambient) (σ-realizer)` forces
        `kvE_deepOnFiber qnf σ = true`, contradicting the binder's `kvE_deepOnFiber qnf σ = false`.
        m=0 vacuous via `kvE_ambientDeepAnchor_zero` + frozen `_zero`. **Green commit.** (G2-B1 is
        independent of the uniqueness kernel — a natural split boundary.)
  - [ ] **G2-B2 (uniqueness kernel)**: prove `kvE_futSliceUnique` / `kvE_pastSliceUnique` at general m
        over the ambient-guarded + deep-anchored population (both σ's pinned over the SAME real tail).
        Use deep-content pinning (`σ'.2 = σ.2` heredity, `kvE_deepOnFiber_iff`) + the EF-closure from
        `kvE_ambientDeepAnchor_iff` + on-fiber row pinning (`kvE_futAdmissible_onFiber`) in place of
        the refuted free-env upgrade. Probe against the countermodel families BEFORE consuming it.
  - [ ] **G2-B3 (rows 10-11)**: prove `kvE_hexclSliceFut_supply` / `kvE_hexclSlicePast_supply`
        general-m matching `hexclSliceFut`/`hexclSlicePast` (:1010/:1003): carried `hreal` + G2-B2
        uniqueness + the admissibility-zone readback (`kvE_futAdmissible_fiber_dichotomy`). m=0 via
        the frozen `kvE_hexclSlice{Fut,Past}_supply_zero`. **Green commit.**
  - [ ] Machine gate: scoped `lake build` of the new/extended leaf + `ExteriorGateAssembleK`/
        `EndIntervalConsumerK` consumers; `lean_verify` new theorems at floor axioms; guard-unfold
        source scan (zero on all six guards); frozen-boundary git-diff (m=0 supplies, `_zero` kernels,
        368 guard/probe leaves, `ExteriorDeepSliceSupplyK.lean` byte-identical); full prior
        certificate set re-verified green.
- **Timing:** 6-9 hours (three green-commit sub-steps: pin-gate ~1-2h; G2-B1 ~2-3h; G2-B2+B3 ~3-4h).
- **Depends on:** none new (Phases 1-3 complete).
- **Territory:** the Phase-3 leaf `ExteriorDeepSliceSupplyK.lean` (append-only) or a new sibling leaf
  under `NfMultiAnchorBridge/` (+ append-only `ExteriorPinnedConverse{K,PastK}.lean`, m=0 regions
  frozen). Read-only: all guard/probe modules, the 368-changed files.

### Phase 5: Interior `hreal` supply — PRODUCE `hsigma` (Rabinovich Cor 5.4(1)⇐) [NOT STARTED]
- **Goal:** Prove `kampPrior_hreal_supply` matching the gate-match row-5 binder
  (`hreal`, KampPrior.lean:964-970): under `kvE_ambientDeepAnchor qnf = true`, for every igPtW-selected
  w and every qnf-marked fiber-consistent σ, produce `x1` with
  `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` — the genuine realizer `hsigma`. This is the task's crux:
  Rabinovich 2014 Cor 5.4(1)⇐ (p.9) — from F-chain firing inside the bracket, select the witness by
  the two-way `min`/case-split induction (corpus: rabinovich_2014/chunk_0015; the `inf`-selection is
  Lemma 5.3, p.8-9, chunk_0014). LITERATURE FIDELITY: follow the source case structure step-by-step;
  the landed engine transcribes it — this phase INSTANTIATES the engine.
- **Restated consumer binder discharged**: `hreal` (KampPrior.lean:964) — leads with
  `kvE_ambientDeepAnchor qnf = true →`; and the row-5 mirror in `EndIntervalConsumerK.lean` /
  `bracketEndChar_kvExt_correct_prior`.
- **Byte-stable 368 lemma supplying the guard antecedent**: `kvE_ambientDeepAnchor_iff`
  (ExteriorAmbientDeepAnchorK.lean:131 — the igPtW → ambient render consumes its EF-closure);
  `kvE_ambientDeepAnchor_zero` (:125 — m=0). Guard antecedents on realizer-derived σ (rows-8-9
  application, bracket membership) discharged via `kvE_deepOnFiber_of_realized` (mate = σ itself).
- **Tasks:**
  - [ ] **G1-1 (population split)**: split the `w` population. `=>`-direction ws (ambient
        `nf_eval_nf M (k+2) 3 [w,x,t] qnf` in scope): forall-σ agreement is DEFINITIONAL. `<=`-ws
        (igPtW-selected, `hAmb` in scope): render w's realization of `igFoldBit qnf` via `hcharK` +
        `P.correct` + `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam — consuming
        `kvE_ambientDeepAnchor_iff` for the deep content (the Phase-4 bridge, now sound).
  - [ ] **G1-2 (per-σ chain-firing -> witness)**: per marked σ, fold-bit -> chain-firing bridge, then
        witness selection. Exterior-zone σ: fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; drivers
        `kampPrior_{fut,past}Realizer_of_pos` (KampPrior.lean:1662 + Past mirror) select `x1` and emit
        `hsigma`; transfer inputs close by the recursion IH at depth k. Interior-zone σ (`x1 ∈ (x,t)`):
        `kampPrior_fChain_realize_bracket` (KampPrior.lean:1549) with F-chain firing from the fold-bit
        fiber content, bracket endpoints `(x,t)` — the Cor 5.4(1)⇐ selection.
  - [ ] **Converter-seam discharge**: at each site holding the produced `hsigma`, discharge the
        `hbr*`-shaped carried obligations by APPLYING `kvE_futBundle_of_realizer`
        (ExteriorConverterK.lean:231) / `kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:199)
        to `hsigma`. Guard antecedents on realizer-derived σ discharged via `kvE_deepOnFiber_of_realized`.
  - [ ] Discharge `hfiberCons` on realized ambients via `kvE_fiberConsistent_of_realized`.
  - [ ] Deliver `kampPrior_hreal_supply` matching the row-5 binder shape (leading
        `kvE_ambientDeepAnchor qnf = true →`) exactly. Machine gate: scoped build; `lean_verify` at
        floor axioms; guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 6-9 hours (heaviest phase; if it exceeds one agent run, split G1-1 from G1-2 at a green
  commit — G1-2 per-zone sub-splits are also natural seams).
- **Depends on:** 4 (consumes the Phase-4 bridge adjudication + uniqueness kernel for its exclusion legs).
- **Territory:** `KampPrior.lean` (or a new interior leaf under `Kamp/` if it grows unwieldy).
  Read-only: all exterior leaf files, guard/probe modules.

### Phase 6: Interior `hexcl` supply (contrapositive channel) [NOT STARTED]
- **Goal:** Prove `kampPrior_hexcl_supply` matching the gate-match row-6 binder
  (`hexcl`, KampPrior.lean:971-977, leading `kvE_ambientDeepAnchor qnf = true →`): a within-`[x,t]`
  realizer of a bit-false fiber-consistent σ is impossible.
- **Restated consumer binder discharged**: `hexcl` (KampPrior.lean:971) + row-6 mirror in
  `EndIntervalConsumerK.lean`.
- **Byte-stable 368 lemma supplying the guard antecedent**: `kvE_ambientDeepAnchor_iff` (the igPtW →
  ambient render feeding the fold back-propagation); `kvE_ambientDeepAnchor_zero` (m=0).
- **Tasks:**
  - [ ] **G1-3**: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW agreement,
        via the Phase-4 uniqueness/readback kernel (deep-anchored: any second witness's deep content
        is pinned; fakes are guard-excluded). Consume `hAmb` for the ambient render exactly as Phase 5.
  - [ ] Deliver `kampPrior_hexcl_supply`. Machine gate: scoped build; `lean_verify` at floor axioms;
        guard-unfold scan (zero); frozen-boundary audit; prior certificate set green.
- **Timing:** 3-5 hours.
- **Depends on:** 4 (uniqueness kernel), 5 (shares the interior seam and `hreal` machinery).
- **Territory:** same as Phase 5.

### Phase 7: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body (KampPrior.lean:506-519) to discharge all 13
  ledger rows and replace the `:519` sorry (route R4).
- **Restated consumer site discharged**: `kampPrior_site_rungK_gate_match` (KampPrior.lean:941-1043) —
  the arm must PRODUCE `kvE_ambientDeepAnchor qnf = true` where the six ambient-guarded binders (rows
  5/6/10-13) demand it, from the realized ambient in scope at the recursion site.
- **Byte-stable 368 lemma supplying the guard antecedent**: `kvE_ambientDeepAnchor_of_realized`
  (ExteriorAmbientDeepAnchorK.lean:195 — PRODUCE guard=true from the ambient realizer; this is the
  "supply side" the delegation names — the arm holds the ambient realizer and feeds it to the guard
  lemma to satisfy the restated binders). NEVER unfold the guard.
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
        recursive calls). Rows 1-2 discharged.
  - [ ] **G3c-2**: discharge rows 5-6 via Phases 5-6 (+ `hfiberCons` via
        `kvE_fiberConsistent_of_realized`); rows 8-9 via Phase 3 (`kvE_hslice{Fut,Past}_supply`); rows
        10-11 via Phase 4 (G2-B3); rows 12-13 via Phase 4 (G2-B1); rows 3-4 ambient; row 7 internal
        (task 356). Supply `kvE_ambientDeepAnchor qnf = true` to the guard-leading binders via
        `kvE_ambientDeepAnchor_of_realized` applied to the ambient realizer. Close via
        `kampPrior_case1_trichotomy_assemble` + `kampPrior_site_rungK_gate_match` (single-depth
        providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing notes (KampPrior.lean:486-518 residual comments)
        in the SAME edit to record the full resolution chain (363: fiber-consistency; 364:
        co-realization mate check; 367: fiber deep-anchor; 368: ambient deep-anchor; 358: supply +
        hsigma production).
  - [ ] Machine gate: scoped build of `KampPrior`; confirm `:519` gone; `lean_verify
        nf_nvar_exist_all_depths` shows only the `| n+2 =>` arm still contributing `sorryAx`;
        guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 3-5 hours.
- **Depends on:** 4, 5, 6.
- **Territory:** `KampPrior.lean` only.

### Phase 8: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
- **Goal:** Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replace the `:522` sorry, and
  perform the terminal full-tree + axiom audit.
- **Tasks:**
  - [ ] **G4-1 route adjudication** (report 04 §3 G4): (i) iterated one-variable reduction through the
        `| 1 =>` machinery (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`; needs an
        arity-general restatement of the arity-2-specific trichotomy/nf_char2 layer) vs. (ii)
        docstring bootstrap (KampPrior.lean:~323-331). The realizer engine/drivers are arity-generic;
        the ambient guard `kvE_ambientDeepAnchor` is stated at general arity `n` (:109), so no arity
        pin obstructs; `kvE_ambientDeepAnchor_of_realized` is general-`n`. Route off n=4 through the
        `_of_realized` families — never unfold.
  - [ ] Rewrite the `| n + 2 =>` arm; replace the `:522` sorry.
  - [ ] **If neither route closes green** -> [BLOCKED] + spawn an isolated arity-lift task; S1 stays
        landed; NEVER a carried sorry.
  - [ ] **Terminal audit**: full-tree `lake build` GREEN; `grep -n "sorry" KampPrior.lean` shows no
        live proof sorry; `#print axioms nf_nvar_exist_all_depths` and
        `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]` (+ acceptable
        native_decide axioms), NO `sorryAx`; tree-wide guard-unfold scan (zero introduced by this
        task); full prior-certificate inventory (358/363/364/367/368) re-verified green;
        vacuous-def scan clean.
  - [ ] Confirm downstream unlock: retiring `:519`/`:522` fully retires task 309's `:361` and unblocks
        task 307 Phase 7 (note in the completion summary; do not action here).
- **Timing:** 2-4 hours.
- **Depends on:** 7.
- **Territory:** `KampPrior.lean` only.

## Testing & Validation

- [ ] **Phase-4 re-probe gate**: full certificate inventory (`kvE_probe368_*` x9, `kvE_probe367_*`
      x4, `kvE_probe364_*` x6, `kvE_probe363_*` x5, `kvE_probe358_*` x3, `kvE_probeM1_*` x2)
      `lean_verify` GREEN at floor axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx,
      BEFORE any supply build.
- [ ] **Per-phase machine gate (binding, every phase)**: scoped `lake build` + `lean_verify` of each
      new theorem at floor axioms + guard-unfold source scan (zero occurrences of
      `rw`/`unfold`/`simp only` on `kvE_ambientDeepAnchor`/`kvE_deepOnFiber`/`kvE_fiberElemConsistent`/
      `kvE_fiberConsistent`/`kvE_{fut,past}Admissible` in new proofs) + frozen-boundary `git diff`
      audit (m=0 `_zero` family, 360 supplies, k<=1 rungs, 363/364/367 declarations, the 368
      guard/probe/gate leaves, `ExteriorDeepSliceSupplyK.lean` — byte-identical).
- [ ] **Re-probe discipline per phase**: the countermodel-family certificates re-verified green after
      each phase's landings (the casts the new theorems must not readmit — esp. CM-A/CM-B).
- [ ] **Zero live sorries at terminus**: currently exactly two live (`:519`, `:522`); terminus shows
      none.
- [ ] **Axiom transcript**: `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`, and
      `completeness_discrete` at floor axioms with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline post-368: green per 368's
      terminal audit, 1761 jobs).
- [ ] **Zero-debt scan**: no vacuous definitions (`def X := True` family) introduced anywhere.

## Artifacts & Outputs

- plans/11_deep-anchor-rekey-v07.md (this file)
- summaries/11_deep-anchor-rekey-v07-summary.md (on implementation completion)
- Phase-4 pin handoff (handoffs/, target supply-theorem signatures against the 368 interface)
- Lean edits: exterior rows-12-13/10-11 supplies + G2-2 uniqueness kernel (append to
  `ExteriorDeepSliceSupplyK.lean` or a new sibling leaf); `kampPrior_hreal_supply`/
  `kampPrior_hexcl_supply` in `KampPrior.lean` (or interior leaf); the two arm rewrites replacing
  `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step committed as it
  lands (`task 358 phase P.O: {objective}`); failures roll back to the last green milestone.
- **Phase-4 re-probe gate fails** (any prior certificate no longer verifies at floor axioms): STOP —
  the ground truth has shifted; do NOT build. [BLOCKED] with the failing certificate named; escalate.
- **Phase-4 bridge adjudication fails** (ambient render not obtainable from `hAmb` + igPtW even with
  CM-A/CM-B excluded, or a new countermodel survives the ambient guard): probe it (additive leaf,
  sorry-free, binder-level closure in the docstring — house style), mark the phase [BLOCKED], `/spawn
  358` an isolated interface/kernel follow-up. Never force the supply against a live countermodel.
- **Phase-5/6 realizer production stalls** (a marked σ's zone case resists the engine): commit all
  green sub-steps, record the exact failing σ shape and goal state, [BLOCKED] + escalate via the
  literature-fidelity path (re-read source -> alternative encodings -> flag gap), never a sorry.
- **Phase-8 `:522` cannot close** under either route: [BLOCKED] + spawn an isolated arity-lift task;
  S1 (`:519`) stays landed and committed — itself a shippable milestone.
- **Regression detected** (any frozen declaration changed): snapshot per git-workflow.md, targeted
  `git checkout` of the offending file to the last green commit, re-run the scoped build, re-attempt
  within phase territory only.
