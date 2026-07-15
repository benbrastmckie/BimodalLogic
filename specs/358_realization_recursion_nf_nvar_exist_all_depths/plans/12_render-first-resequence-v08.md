# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Wave-DAG De-Inversion: Shared Ambient Render First, Then Exterior Supplies (v08)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by supplying the depth>=1 interior/exterior obligations against task 368's ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`, and by PRODUCING the genuine realizer `hsigma` (Rabinovich 2014 Cor 5.4(1)⇐, p.9) that discharges the interior `hreal`/`hexcl` and the exterior converter seam.
- **Status**: [NOT STARTED]
- **Effort**: 20-32 hours remaining (Phases 1-4 [COMPLETED]; 7 build/rewrite phases, each bounded to ~one agent run with a machine gate; heavy phases carry named green-commit split points)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface), 364 (completed — co-realization mate check), 367 (completed — fiber-side deep-anchor guard `kvE_deepOnFiber`), **368 (completed, verified — ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`; CLOSED the plan-06 Phase-4 BLOCKER by excluding CM-A/CM-B from the antecedent population, 2026-07-14)**
- **Research Inputs**:
  - handoffs/phase-4-handoff-20260714.md (2026-07-14 — AUTHORITATIVE driver for this revision: the Phase-4 bridge-adjudication finding that the plan's Wave DAG is INVERTED for the exterior supplies; the deep ambient realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf` is not constructible from `hAmb` + igPtW but is reconstructed by the Phase-5 interior realizer; the pinned target signatures for rows 12-13/10-11/uniqueness; the landed m=0 skeleton)
  - specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/summaries/01_ambient-deep-anchor-guard-summary.md (2026-07-14 — the landed ambient guard, its byte-stable API, the consumer-binder restatement, the residue-row decision, and the certificate inventory)
  - reports/10_spawn-analysis.md (round 10 — the blocker decomposition that produced task 368: CM-A/CM-B root cause = P17 anchor-content gap on the AMBIENT side; the probe-first, one-task, 367-mirrored prescription)
  - plans/06_deep-anchor-rekey-v06.md (superseded plan; its Phase-4 BLOCKER record is the countermodel ground truth task 368 answered; Phases 1-3 preserved verbatim from it)
  - reports/08_g2-rekey-against-364-interface.md (round 8 — byte-stable 364 discharge-lemma routing, still binding)
  - reports/06_remaining-work-and-plan-revision.md (round 6 — two-live-sorry map, ordered decomposition, verification bar)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, routes R1-R5; the *mathematics* of each gap)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐ grounding; corpus: `~/Projects/Literature/sources/rabinovich_2014/chunk_0014`-`chunk_0015` — Lemma 5.3 Dedekind `inf`-selection + the Cor 5.4(1)⇐ two-way `min`/case-split. CITATION RULE (sub-index hazard): cite the PDF by page number only, e.g. "Rabinovich 2014, Cor 5.4, p.9"; NEVER md:NN line numbers)
- **Reports Integrated**: handoffs/phase-4-handoff-20260714.md (v08 — new, the wave-inversion finding), specs/368 summary 01 (v07), reports/10_spawn-analysis.md (v07), specs/367 summary 01 (v06, carried), phase-2-v05-handoff (v06, carried), 08_g2-rekey-against-364-interface.md (v05), 06_remaining-work-and-plan-revision.md (v04), 04_post-360-gap-map-and-route.md (v03/v04), 02_literature-proof-method-survey.md (v02)
- **Artifacts**: plans/12_render-first-resequence-v08.md (this file)
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

**What changed since v07 — the wave-DAG de-inversion.** Plan v07 sequenced the exterior deep/slice
supplies (rows 12-13, 10-11, and the G2-2 uniqueness kernel) as Phase 4, ahead of the interior
realizer (Phase 5). Phase-4 implementation (sess_1784078566_52d1da) LANDED the 368 interface pin +
re-probe gate GREEN and the **m=0 arms** of rows 12-13 sorry-free (`ExteriorDeepExclSupplyK.lean`,
`kvE_deepExcl_zero_vacuous` + the two m=0 legs), but its **bridge-adjudication gate FAILED** for the
general-`m` arms and produced a decisive finding:

> The general-`m` discharge of rows 12-13 / 10-11 / uniqueness ALL require the **full deep ambient
> realization** `nf_eval_nf M (k+2) 3 [w,x,t] qnf` at the binder site. That render is NOT
> constructible from the Phase-4-local hypotheses: `igPtW`/`kvExt_gate_henv`
> (`ExteriorGateAssembleK.lean:61`) renders ONLY the atom layer `nf_eval_nf M 0 3 [w,x,t] qnf.1`, and
> `kvE_ambientDeepAnchor` is a purely SYNTACTIC `Bool` of `qnf` (no model `M`). The DEEP quant layer
> `qnf.2` is reconstructed by the **Phase-5 interior realizer** (`kampPrior_hreal_supply`, via
> `P.correct` + fold bit + `kvE_ambientDeepAnchor_iff` EF-closure). CM-A/CM-B exclusion makes the
> render SOUND (true) but not CONSTRUCTIBLE from `hAmb` + igPtW alone.

So the v07 wave DAG (Phase 5 depends on Phase 4) is **inverted** for the exterior supplies: they
depend on the Phase-5 interior ambient render, not the other way around. This revision **re-orders
the remaining work to land the shared interior ambient render FIRST**, then have the exterior
supplies consume it. The two deferred general-`m` arms
(`ExteriorDeepExclSupplyK.lean:105`, `:133`) become fill-in work once the render lemma exists.

**This is a re-sequence + gap-fill, NOT a rewrite.** All v07 mathematics, byte-stable lemma names,
target signatures, machine-gate checklists, routing constraints, and preserved-asset accounting are
carried verbatim. The re-key against task 368's guard is unchanged; only the phase ORDER changes,
plus the extraction of the render step into a standalone de-inverting root phase.

**What is now unblocked.** With CM-A/CM-B excluded by construction (task 368), the `igPtW` →
ambient-realization bridge is sound; the remaining obstacle was purely one of ORDER. Landing the
render lemma (`igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf`) as the de-inverted root
unblocks the exterior deep/slice supplies AND supplies the G1-1 step of the interior realizer.

**The crux is UNCHANGED and now correctly ordered: PRODUCE `hsigma`** — the genuine interior/exterior
realizer `nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`, selected per Rabinovich 2014 Cor 5.4(1)⇐ (p.9) via the
two-way `min`/case-split induction. The engine is LANDED sorry-free
(`kampPrior_fChain_realize_from` KampPrior.lean:1415, `_bracket` :1549,
`kampPrior_{fut,past}Realizer_assemble` :1602, `_of_pos` :1662 + Past mirrors) — this task
INSTANTIATES it. The render lemma (new Phase 5) is the G1-1 ambient-render step of that instantiation,
now pulled ahead as a shared lemma so the exterior consumers can reference it.

**Definition of done** (binding): `:519` and `:522` both sorry-free; the two tracked strategic
sorries in `ExteriorDeepExclSupplyK.lean` (`:105`, `:133`) retired; all igPtW-guarded rows 5/6/10-13
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

Newly integrated this revision (v07 -> v08):

- **handoffs/phase-4-handoff-20260714.md** (the wave-inversion finding). Integration effects:
  1. **The v07 Wave DAG is INVERTED for the exterior supplies — re-ordered here.** Rows 12-13, rows
     10-11, and the G2-2 uniqueness kernel all consume the deep ambient realization
     `nf_eval_nf M (k+2) 3 [w,x,t] qnf`, which is produced by the interior realizer (v07 Phase 5),
     NOT derivable from `hAmb` + igPtW at the exterior binder site. The remaining phases are
     re-sequenced so the shared render lands first (new Phase 5), then the exterior consumers.
  2. **The render lemma is the de-inverted root.** Extracted as a standalone shared lemma
     `igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf` (the G1-1 ambient-render step of
     `kampPrior_hreal_supply`), built via `hcharK` + `P.correct` +
     `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam, consuming
     `kvE_ambientDeepAnchor_iff` for the deep content. Everything downstream references it by name.
  3. **The landed m=0 skeleton is preserved and consumed, not re-planned.**
     `ExteriorDeepExclSupplyK.lean` already type-checks the exact rows-12-13 target signatures
     against the binder shapes, discharges m=0 sorry-free (`kvE_deepExcl_zero_vacuous`), and carries
     the two general-`m` arms as tracked strategic sorries (`:105`, `:133`). The re-sequenced Phase 6
     only FILLS those two arms via `kvE_deepOnFiber_of_realized` once the render exists.
  4. **The pinned target signatures are carried verbatim** (handoff §"Target signatures"): rows 12-13
     `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply`; rows 10-11 `kvE_hexclSliceFut_supply` /
     `kvE_hexclSlicePast_supply`; uniqueness `kvE_futSliceUnique` / `kvE_pastSliceUnique`. The
     atom-render helper `kvExt_gate_henv` (`ExteriorGateAssembleK.lean:61`, atom layer only) and the
     contradiction engine `kvE_deepOnFiber_of_realized` (`ExteriorFiberDeepAnchorK.lean:141`, needs
     BOTH ambient realized AND σ realized) are the fixed seams.

Carried from v07 (still integrated): specs/368 summary (ambient guard `kvE_ambientDeepAnchor` + API +
restated binders + probes — the re-keying contract), reports/10_spawn-analysis.md (CM-A/CM-B
characterization + interface-only scope boundary), specs/367 summary (fiber guard `kvE_deepOnFiber` +
API — the rows-8-9 gate), report 08 (byte-stable 364 discharge routing), report 06 (flow), report 04
(gap mathematics), report 02 (Rabinovich engine grounding).

### GLOBAL ROUTING CONSTRAINT (binding on Phases 5-11)

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
363/364/367/368's guards/lemmas/probes, task 358 Phase 3's own landing, AND task 358 Phase 4's landed
pin/gate/m=0 leaf.

| Landed asset | Interface (by name) | File:line | Owner |
|---|---|---|---|
| **k=0 arm of `\| 1 =>`** | `kampPrior_case1_arm_k0` | KampPrior.lean:~271 (consumed :504) | 358 P5.1 — **FROZEN** |
| **k=1 arm of `\| 1 =>`** | `kampPrior_case1_arm_k1` | KampPrior.lean (consumed :505) | 309 P20 — **FROZEN** |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | 350 — **FROZEN** |
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1415/1549/1602/1662 (+Past) | 358 P1-2 — sorry-free |
| Consumer stack + 13-row ledger (BINDING) | `endIntervalStepPrior`/`endInterval_step_correct`/ledger table | EndIntervalConsumerK.lean | 349+367+368 |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:941-1043 | 349 (368-mirrored binders) |
| Atom-render helper (atom layer only) | `kvExt_gate_henv` (igPtW eval → `nf_eval_nf M 0 3 [w,x,t] qnf.1`) | ExteriorGateAssembleK.lean:61 | 368 — **FROZEN, consume by name** |
| **368 ambient guard + API** | `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized` | **ExteriorAmbientDeepAnchorK.lean:109/125/131/195** | **368 — the re-keying contract; FROZEN** |
| **368 gate carrier** | `kvE_ambientGuardForm`, `kvE_ambientGuardForm_truth`; `bracketEndChar_kvExt_correct_prior` | ExteriorGateAssembleK.lean | **368 — FROZEN, consume by name** |
| **368 probe certificates** | `kvE_probe368_{cmA,cmB}_ambient_rejected`, `_real_ambient_anchored`, `_{cmA_row13,cmB_row5}_refuted`, `_depth2_ambient_rejected`, `_ambient_copyPlant_{passes_guard,collapses}`, `_ambient_supply_route` | ExteriorAmbientDeepAnchorProbe358K.lean | **368 — GREEN adjudication evidence; cite, do not modify** |
| **367 deep-anchor guard + API** | `kvE_deepOnFiber` + `_zero`/`_base`/`_iff`/`_row`/`_of_realized` | ExteriorFiberDeepAnchorK.lean:81-168 | **367 — FROZEN** |
| **367 probe certificates** | `kvE_probe367_tailDG_deep_rejected`, `_real_slice_deep_anchored`, `_depth2DG_deep_rejected`, `_copyPlant_collapses` | ExteriorFiberDeepAnchorProbe367K.lean | **367 — FROZEN** |
| **358 Phase-3 landing** (rows 8-9 supply) | `kvE_hsliceFut_supply` (:131), `kvE_hslicePast_supply` (:161), `kvE_deepMate_collapse` (:90), `kvE_{fut,past}SliceEq_refl` (:63/:72) | **ExteriorDeepSliceSupplyK.lean** | **358 P3 — FROZEN; survives ambient-side strengthening** |
| **358 Phase-4 m=0 deep-exclusion landing** | `kvE_deepExcl_zero_vacuous` (:63, sorry-free), `kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` **m=0 arms** (sorry-free); general-`m` arms are the tracked strategic sorries `:105`/`:133` to be FILLED | **ExteriorDeepExclSupplyK.lean** | **358 P4 — m=0 legs FROZEN; append/fill only** |
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
supplies — no m=0 work remains. The Phase-4 m=0 deep-exclusion legs
(`ExteriorDeepExclSupplyK.lean`) are likewise landed and FROZEN; only the two general-`m` arms
(`:105`, `:133`) are open, and this plan FILLS them (append/edit within those two arm bodies only).

## Goals & Non-Goals

- **Goals**:
  - **Land the shared interior ambient render (the de-inverted root)**: a standalone render lemma
    `igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf` (the G1-1 ambient-render step of
    `kampPrior_hreal_supply`), via `hcharK` + `P.correct` +
    `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam, consuming
    `kvE_ambientDeepAnchor_iff` for the deep content. All exterior/interior consumers reference it.
  - **Fill the two deferred rows-12-13 general-`m` arms** (`ExteriorDeepExclSupplyK.lean:105`, `:133`):
    with the render in scope, close by the `kvE_deepOnFiber_of_realized` contradiction (a σ-realizer +
    ambient realized forces `kvE_deepOnFiber qnf σ = true`, contradicting the binder's `= false`).
  - Rebuild the G2-2 uniqueness kernel (`kvE_futSliceUnique`/`kvE_pastSliceUnique` general-m) over
    the ambient-guarded + deep-anchored population, extracting EF-closure only via
    `kvE_ambientDeepAnchor_iff`; supply rows 10-11 (`hexclSliceFut`/`hexclSlicePast`) consuming it +
    the render.
  - **PRODUCE `hsigma`** (interior rows 5-6, `kampPrior_hreal_supply`/`kampPrior_hexcl_supply`):
    Rabinovich 2014 Cor 5.4(1)⇐ (p.9) within-bracket bounded witness selection through the landed
    engine; build the G1-2 per-σ chain-firing on top of the Phase-5 render; discharge `hfiberCons`
    via `kvE_fiberConsistent_of_realized`; discharge the exterior `hbr*`-shaped seam by APPLYING
    `kvE_{fut,past}Bundle_of_realizer` to the produced `hsigma`.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 13 ledger rows, PRODUCING
    `kvE_ambientDeepAnchor qnf = true` via `kvE_ambientDeepAnchor_of_realized` at the realized-ambient
    seam where the restated gate binders demand it; replace `:519`.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm; replace `:522`.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset — esp. the 368 guard/API/probe leaf,
    the 367 guard/API/probes, the `_zero` kernel family, the k<=1 rungs, task 360 m=0 supply, task
    358 Phase 3's `ExteriorDeepSliceSupplyK.lean` (rows 8-9), and task 358 Phase 4's m=0 legs in
    `ExteriorDeepExclSupplyK.lean` (only the two general-`m` arms are open).
  - Do NOT unfold any guard body (GLOBAL ROUTING CONSTRAINT) — byte-stable lemmas only.
  - Do NOT re-run the Phase-4 bridge-adjudication as an INDEPENDENT step: the finding is established
    (the render is not constructible from `hAmb` + igPtW alone). The render is now built as its own
    phase FIRST; do not attempt to discharge the exterior general-`m` arms before it exists.
  - Do NOT re-attempt v05's G2-1 (`kvE_{fut,past}SliceId_of_end` at general m via the free-env →
    pinned upgrade) — machine-refuted; superseded.
  - Do NOT re-key or re-supply rows 8-9 — they carry NO ambient antecedent and are done (Phase 3).
  - Do NOT re-introduce any `hbr*`-shaped UNIVERSAL binder; do NOT consume
    `kvE_{fut,past}Bundle_of_realizer` without a genuine produced realizer.
  - Do NOT re-derive, weaken, or re-probe CM-A/CM-B or add ambient guard machinery — task 368 owns
    the interface; this task consumes it.
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` M-independent.

## Risks & Mitigations

- **Risk: the shared render lemma (Phase 5) itself does not close** — the bridge construction
  (`hcharK` + `P.correct` + `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam) must
  actually consume the `kvE_ambientDeepAnchor_iff` EF-closure to reconstruct the deep content, and the
  Phase-4 finding only established that igPtW alone is insufficient — it did NOT establish that
  `_iff` + `P.correct` + fold bit suffice. Mitigation: Phase 5 runs a render-adjudication gate FIRST
  (paper + `lean_multi_attempt`) before committing; if `_iff` + the provider bridge still under-supply
  the deep content, probe the exact residual gap against the CM-A/CM-B casts, mark [BLOCKED], and
  `/spawn 358` an isolated render-kernel task — never force it. **This is the single highest-risk
  phase and the de-inverting root; everything downstream depends on it.**
- **Risk: rows 12-13 general-`m` fill needs the σ-realizer AND ambient realized simultaneously** for
  `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 needs both). Mitigation: with the
  Phase-5 render landed the ambient realization is now IN SCOPE by name; the σ-realizer is the
  hypothesis being contradicted (`_hσ` at the exterior tuple). Both present at the binder site.
- **Risk: G2-2 uniqueness at general m needs a deep transfer kernel** (EF-style exterior-chain
  matching). Mitigation: build over the ambient-guarded + deep-anchored population where the second
  witness's deep content is pinned; both σ's realized over the SAME Phase-5-rendered ambient tail;
  extract via `kvE_ambientDeepAnchor_iff`; probe against the countermodel families before trusting;
  [BLOCKED]+escalate on a new countermodel.
- **Risk: `hsigma` production (Phase 8) exceeds one agent run.** Mitigation: the render (G1-1) is
  already banked in Phase 5; Phase 8 is scoped to the G1-2 per-σ chain-firing + witness selection +
  converter seam only. If it overruns, split at the exterior-zone / interior-zone boundary with a
  green commit between.
- **Risk: `:522` arity-lift does not close under either reduction route.** Mitigation: G4-1 route
  adjudication at Phase 11 start; if neither closes, [BLOCKED] + spawn an isolated arity-lift task,
  keep S1 landed — NEVER a carried sorry.
- **Risk: touching frozen layers.** Mitigation: per-phase `git diff` audit against the Preserved
  Assets table (esp. the exactly-5 368-changed files must not be re-touched beyond `KampPrior.lean`'s
  own arm bodies, the 368 probe/guard leaves stay byte-identical, and the Phase-4 m=0 legs in
  `ExteriorDeepExclSupplyK.lean` stay byte-identical outside the two general-`m` arm bodies); scoped
  `lake build` per phase; full-tree build + certificate re-verification at terminus.

## Implementation Phases

**Dependency Analysis** (wave DAG DE-INVERTED — the shared render is now the root):
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 5 | -- (Phases 1-4 complete) |
| 2 | 6, 7 | 5 |
| 3 | 8 | 5, 7 |
| 4 | 9 | 5, 7, 8 |
| 5 | 10 | 6, 7, 8, 9 |
| 6 | 11 | 10 |

Phase 5 (the shared interior ambient render) is the de-inverted ROOT: the exterior deep/slice
supplies (Phases 6-7) and the interior witness production (Phases 8-9) all consume it. Phases 6 and 7
occupy disjoint territory (`ExteriorDeepExclSupplyK.lean` two general-`m` arms vs. a new uniqueness +
slice leaf) and can run in the same wave. Phase 8 (`hreal` G1-2) consumes the render + the Phase-7
uniqueness kernel for its exclusion legs; Phase 9 (`hexcl`) shares the interior seam with Phase 8.
Every phase ends with a machine gate: scoped build + `lean_verify` at floor axioms + guard-unfold
source scan + frozen-boundary git-diff audit.

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
> **v07 note (carried)**: rows 8-9's binders (`hslicePast` KampPrior.lean:989, `hsliceFut` :996)
> carry NO `kvE_ambientDeepAnchor` antecedent — confirmed against the 368-landed gate_match
> signature. Task 368's ambient-side strengthening only strengthens the ambient-realization
> antecedent these binders already carry, so this landing is UNAFFECTED and stays FROZEN.
- **Goal:** (historical) Prove `kvE_hsliceFut_supply`/`kvE_hslicePast_supply` at general m.
- **Tasks:** (all executed; see plans/06 for the retained checklist)
- **Timing:** 4-6 hours (spent).
- **Depends on:** 2.
- **Completed:** 2026-07-14 (sess_1784059448_2c72f2_358).

### Phase 4: 368 ambient-guard interface pin + re-probe gate + m=0 deep-exclusion arms [COMPLETED]

> **P4 outcome (2026-07-14, sess_1784078566_52d1da; commit d62d69b20)**: pin + re-probe gate GREEN;
> the m = 0 arms of rows 12-13 LANDED sorry-free; the general-`m` exterior supply produced a decisive
> wave-inversion FINDING that drove this v08 revision. See handoffs/phase-4-handoff-20260714.md.
>
> **Landed this phase** (green, FROZEN):
> - Pin (read-only): `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized`
>   (ExteriorAmbientDeepAnchorK.lean:109/125/131/195), the six ambient-guarded binders
>   (KampPrior.lean:964/971/1003/1010/1017/1024) and their `EndIntervalConsumerK`/
>   `ExteriorGateAssembleK` mirrors, the frozen m=0 `_zero` supplies. Target general-`m` signatures
>   recorded in the Phase-4 handoff.
> - Re-probe gate: representative `kvE_probe368_*`/`kvE_probe367_*` certificates `lean_verify` GREEN
>   at floor axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx; Kamp-path sorries confirmed
>   exactly KampPrior.lean:519/:522; rows 8-9 confirmed to carry NO ambient antecedent (Phase-3
>   landing unaffected).
> - NEW leaf `ExteriorDeepExclSupplyK.lean`: `kvE_deepExcl_zero_vacuous` (:63, sorry-free, floor
>   axioms) + `kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` with **m=0 arms sorry-free**
>   (vacuity via `kvE_deepOnFiber_zero`). Scoped build green (1035 jobs); guard-unfold scan clean;
>   frozen files byte-identical.
>
> **WAVE-INVERSION FINDING (drove v08)**: the general-`m` arms of rows 12-13/10-11/uniqueness ALL
> require the full deep ambient realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf`, which igPtW does NOT
> supply (`kvExt_gate_henv` renders only the atom layer `qnf.1`) and `kvE_ambientDeepAnchor` cannot
> supply (syntactic `Bool`, no model `M`). The deep quant layer is reconstructed by the interior
> realizer. The two general-`m` arms (`ExteriorDeepExclSupplyK.lean:105`, `:133`) were landed as
> TRACKED strategic sorries (NOT the `:519`/`:522` main-target sorries) pending the render. This v08
> re-sequences the render ahead of the exterior supplies (new Phases 5-7).
- **Goal:** (historical) Pin the 368 ambient-guard interface, certify ground truth, and land the m=0
  deep-exclusion legs. **The general-`m` exterior supply moved to Phases 6-7 behind the Phase-5
  render.**
- **Tasks:** (pin + re-probe gate + m=0 arms all executed; the general-`m` arms are re-sequenced —
  see Phases 5, 6, 7)
- **Timing:** ~2 hours (spent on the landed pin/gate/m=0 portion).
- **Depends on:** none (Phases 1-3 complete).
- **Completed:** 2026-07-14 (sess_1784078566_52d1da, commit d62d69b20 — pin + gate + m=0 legs).

### Phase 5: Shared interior ambient render — the de-inverted root (`igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf`) [NOT STARTED]
- **Goal:** Land the shared interior ambient render as a standalone, reusable lemma: under
  `hAmb : kvE_ambientDeepAnchor qnf = true` + the igPtW guard + the recursion providers `P`, render
  the FULL deep ambient realization `nf_eval_nf M (k+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`
  at the rows-12-13/10-11 binder site (and the row-5 `hreal` interior site). This is the **G1-1
  ambient-render step** of `kampPrior_hreal_supply`, PULLED AHEAD as the de-inverted root that the
  exterior deep/slice supplies (Phases 6-7) and the interior witness production (Phases 8-9) consume.
- **Why this is the root** (Phase-4 finding): igPtW/`kvExt_gate_henv` (ExteriorGateAssembleK.lean:61)
  renders ONLY the atom layer `nf_eval_nf M 0 3 [w,x,t] qnf.1`; `kvE_ambientDeepAnchor` is a syntactic
  `Bool` (no model `M`). The deep quant layer `qnf.2` must be reconstructed HERE, from `P.correct` +
  the fold bit + `hAmb`'s EF-closure (`kvE_ambientDeepAnchor_iff`), before any consumer can proceed.
- **Byte-stable lemmas consumed**: `kvE_ambientDeepAnchor_iff` (ExteriorAmbientDeepAnchorK.lean:131 —
  the ONLY EF-closure readback for the deep content), `kvE_ambientDeepAnchor_zero` (:125 — m=0
  vacuity), `kvExt_gate_henv` (ExteriorGateAssembleK.lean:61 — atom layer), the provider bridge
  `kampPrior_existProviders_of_ih_existF0_char` + `hcharK` + `P.correct` under the pinned seam.
- **Tasks:**
  - [ ] **Render adjudication (before any commit)**: verify on paper + by `lean_multi_attempt` that
        `kvE_ambientDeepAnchor_iff` + `P.correct` + the fold bit + `kvExt_gate_henv`'s atom layer
        SUFFICE to reconstruct `nf_eval_nf M (k+2) 3 [w,x,t] qnf` (both the atom layer `qnf.1` and the
        deep quant layer `qnf.2`). The Phase-4 finding established igPtW alone is insufficient; it did
        NOT establish these together suffice. If a residual gap remains, probe it against the
        CM-A/CM-B casts, [BLOCKED] + `/spawn 358` an isolated render-kernel task — never force it.
  - [ ] **Build the render lemma** (name e.g. `kampPrior_ambient_render` / `kvE_ambient_render_of_igPtW`),
        binder-shape-exact for the rows-12-13/10-11 site (params `{sig} {atomMap} (k) (h_surj)
        (charF) (M) (qnf : NormalForm sig (k+2) 3) (x t) (w)`, hypotheses `hAmb` + igPtW eval),
        concluding `nf_eval_nf M (k+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`. m=0 via
        `kvE_ambientDeepAnchor_zero` composed with the atom render. **Green commit** (`task 358 phase
        5: shared ambient render lemma`).
  - [ ] **Re-probe** the render against the CM-A/CM-B casts (`kvE_probe368_cmA_ambient_rejected`,
        `_cmB_ambient_rejected`) + the depth-2 / copy-plant families: the render must NOT hold for the
        guard-false fakes (they never satisfy `hAmb`). Certify green.
  - [ ] Machine gate: scoped `lake build` of the render leaf; `lean_verify` at floor axioms, no
        sorryAx; guard-unfold source scan (zero); frozen-boundary git-diff audit (368 guard/probe
        leaves, Phase-3/Phase-4 leaves byte-identical outside the new lemma).
- **Timing:** 4-6 hours (highest-risk phase; the de-inverting root — if the render-adjudication gate
  fails, STOP and escalate rather than descend into the two general-`m` arms).
- **Depends on:** none new (Phases 1-4 complete).
- **Territory:** a new render leaf under `NfMultiAnchorBridge/` (or an append to
  `ExteriorGateAssembleK`'s consumer side ONLY if it does not touch the frozen `kvExt_gate_henv`
  region) or `KampPrior.lean`'s interior region. Read-only: all guard/probe modules, the 368-changed
  files, the Phase-3/Phase-4 landed leaves.

### Phase 6: Fill the deferred rows 12-13 general-`m` arms (`ExteriorDeepExclSupplyK.lean:105`, `:133`) [NOT STARTED]
- **Goal:** Retire the two tracked strategic sorries in the Phase-4 leaf. With the Phase-5 render in
  scope, discharge the general-`m` arms of `kvE_hexclDeepFut_supply` (`:105`, row 13) and
  `kvE_hexclDeepPast_supply` (`:133`, row 12) via the `kvE_deepOnFiber_of_realized` contradiction.
- **Restated consumer binders discharged**: `hexclDeepFut` (KampPrior.lean:1024, mirror
  EndIntervalConsumerK.lean rows 13), `hexclDeepPast` (:1017, rows 12) — each leads with
  `kvE_ambientDeepAnchor qnf = true →`. The m=0 legs are already banked (Phase 4).
- **Byte-stable lemmas consumed**: the Phase-5 render lemma (ambient realized at `[w,x,t]`),
  `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 — needs BOTH the ambient realized
  AND the σ-realizer; forces `kvE_deepOnFiber qnf σ = true`, contradicting the binder's `= false`).
- **Tasks:**
  - [ ] Fill `ExteriorDeepExclSupplyK.lean:105` (`kvE_hexclDeepFut_supply` `(j+1)` arm): from
        `hAmb` + igPtW, obtain the ambient realization via the Phase-5 render; from the hypothetical
        `_hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, apply `kvE_deepOnFiber_of_realized` to force
        `kvE_deepOnFiber qnf σ = true`, contradicting `_hguard : kvE_deepOnFiber qnf σ = false`. Edit
        ONLY the arm body (the m=0 leg and the whole module docstring/signature stay byte-identical).
  - [ ] Fill `ExteriorDeepExclSupplyK.lean:133` (`kvE_hexclDeepPast_supply` `(j+1)` arm): Past mirror,
        same route.
  - [ ] Re-probe the filled supplies against the CM-A/CM-B / depth-2 / copy-plant families.
        **Green commit** (`task 358 phase 6: fill rows 12-13 general-m deep-exclusion arms`).
  - [ ] Machine gate: scoped `lake build` of `ExteriorDeepExclSupplyK.lean` + consumers; `lean_verify
        kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` at floor axioms, **no sorryAx** (the two
        `:105`/`:133` strategic sorries GONE); guard-unfold source scan (zero); frozen-boundary
        git-diff (m=0 legs + docstring byte-identical).
- **Timing:** 2-4 hours.
- **Depends on:** 5 (the render).
- **Territory:** `ExteriorDeepExclSupplyK.lean` (the two `(j+1)` arm bodies ONLY). Read-only:
  everything else.

### Phase 7: G2-2 uniqueness kernel + rows 10-11 slice supplies [NOT STARTED]
- **Goal:** Rebuild the G2-2 uniqueness kernel (`kvE_futSliceUnique`/`kvE_pastSliceUnique` general-m)
  over the ambient-guarded + deep-anchored population, then supply rows 10-11
  (`kvE_hexclSliceFut_supply`/`kvE_hexclSlicePast_supply`) consuming it + the Phase-5 render.
- **Restated consumer binders discharged**: `hexclSliceFut` (KampPrior.lean:1010, rows 11),
  `hexclSlicePast` (:1003, rows 10) — each leads with `kvE_ambientDeepAnchor qnf = true →`. Target
  signatures verbatim from the Phase-4 handoff §"Target signatures" (rows 10-11 = rows 12-13 shape
  with `qnf.2 σ = false → kvE_{fut,past}SliceMarked qnf σ = true →` replacing the deep-anchor row
  pair).
- **Byte-stable lemmas consumed**: the Phase-5 render (both σ's realized over the SAME ambient tail),
  `kvE_ambientDeepAnchor_iff` (EF-closure for the second witness's deep content), `kvE_deepOnFiber_iff`
  (deep-content pinning `σ'.2 = σ.2` heredity), `kvE_futAdmissible_onFiber` (on-fiber row pinning) in
  place of the refuted free-env upgrade; m=0 via the frozen `kvE_hexclSliceFut_supply_zero`
  (ExteriorPinnedConverseK.lean:1250) + `kvE_futSliceUnique_zero` (:1122) (+Past :769/:356).
- **Tasks:**
  - [ ] **G2-B2 (uniqueness kernel)**: prove `kvE_futSliceUnique` / `kvE_pastSliceUnique` at general m
        over the ambient-guarded + deep-anchored population (both σ's pinned over the SAME
        Phase-5-rendered ambient tail). Use deep-content pinning + the `kvE_ambientDeepAnchor_iff`
        EF-closure + on-fiber row pinning. Probe against the countermodel families BEFORE consuming
        it. **Green commit.**
  - [ ] **G2-B3 (rows 10-11)**: prove `kvE_hexclSliceFut_supply` / `kvE_hexclSlicePast_supply`
        general-m matching `hexclSliceFut`/`hexclSlicePast` (:1010/:1003): the Phase-5 render + the
        G2-B2 uniqueness + the admissibility-zone readback (`kvE_futAdmissible_fiber_dichotomy`). m=0
        via the frozen `kvE_hexclSlice{Fut,Past}_supply_zero`. **Green commit.**
  - [ ] Machine gate: scoped `lake build` of the new leaf + consumers; `lean_verify` new theorems at
        floor axioms; guard-unfold source scan (zero); frozen-boundary git-diff audit; full prior
        certificate set re-verified green.
- **Timing:** 3-5 hours (two green-commit sub-steps: uniqueness ~2-3h; rows 10-11 ~1-2h).
- **Depends on:** 5 (the render).
- **Territory:** a new sibling leaf under `NfMultiAnchorBridge/` (+ append-only
  `ExteriorPinnedConverse{K,PastK}.lean`, m=0 regions frozen). Read-only: all guard/probe modules,
  the 368-changed files, the Phase-3/Phase-4/Phase-5 leaves.

### Phase 8: Interior `hreal` supply — PRODUCE `hsigma` (G1-2 Rabinovich Cor 5.4(1)⇐ witness selection) [NOT STARTED]
- **Goal:** Prove `kampPrior_hreal_supply` matching the gate-match row-5 binder
  (`hreal`, KampPrior.lean:964-970): under `kvE_ambientDeepAnchor qnf = true`, for every igPtW-selected
  w and every qnf-marked fiber-consistent σ, produce `x1` with
  `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` — the genuine realizer `hsigma`. This is the task's crux:
  Rabinovich 2014 Cor 5.4(1)⇐ (p.9) — from F-chain firing inside the bracket, select the witness by
  the two-way `min`/case-split induction (corpus: rabinovich_2014/chunk_0015; the `inf`-selection is
  Lemma 5.3, p.8-9, chunk_0014). LITERATURE FIDELITY: follow the source case structure step-by-step;
  the landed engine transcribes it — this phase INSTANTIATES it. **The G1-1 ambient render is already
  banked (Phase 5); this phase builds the G1-2 per-σ chain-firing on top of it.**
- **Restated consumer binder discharged**: `hreal` (KampPrior.lean:964) — leads with
  `kvE_ambientDeepAnchor qnf = true →`; and the row-5 mirror in `EndIntervalConsumerK.lean` /
  `bracketEndChar_kvExt_correct_prior`.
- **Byte-stable lemmas consumed**: the Phase-5 render (G1-1), the Phase-7 uniqueness kernel (for the
  exclusion legs), `kampPrior_{fut,past}Realizer_of_pos` (KampPrior.lean:1662 + Past),
  `kampPrior_fChain_realize_bracket` (:1549), `kvE_deepOnFiber_of_realized` (guard antecedents on
  realizer-derived σ), `kvE_fiberConsistent_of_realized` (`hfiberCons`),
  `kvE_{fut,past}Bundle_of_realizer` (converter seam).
- **Tasks:**
  - [ ] **G1-2 population handling**: `=>`-direction ws (ambient render in scope via Phase 5):
        forall-σ agreement is DEFINITIONAL. `<=`-ws (igPtW-selected, `hAmb` in scope): consume the
        Phase-5 render for w's realization of `igFoldBit qnf`.
  - [ ] **G1-2 (per-σ chain-firing -> witness)**: per marked σ, fold-bit -> chain-firing bridge, then
        witness selection. Exterior-zone σ: fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; drivers
        `kampPrior_{fut,past}Realizer_of_pos` select `x1` and emit `hsigma`; transfer inputs close by
        the recursion IH at depth k. Interior-zone σ (`x1 ∈ (x,t)`): `kampPrior_fChain_realize_bracket`
        with F-chain firing from the fold-bit fiber content, bracket endpoints `(x,t)` — the Cor
        5.4(1)⇐ selection.
  - [ ] **Converter-seam discharge**: at each site holding the produced `hsigma`, discharge the
        `hbr*`-shaped carried obligations by APPLYING `kvE_futBundle_of_realizer`
        (ExteriorConverterK.lean:231) / `kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:199)
        to `hsigma`. Guard antecedents on realizer-derived σ discharged via `kvE_deepOnFiber_of_realized`.
  - [ ] Discharge `hfiberCons` on realized ambients via `kvE_fiberConsistent_of_realized`.
  - [ ] Deliver `kampPrior_hreal_supply` matching the row-5 binder shape (leading
        `kvE_ambientDeepAnchor qnf = true →`) exactly. Machine gate: scoped build; `lean_verify` at
        floor axioms; guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 5-8 hours (heaviest remaining phase; if it exceeds one agent run, split the
  exterior-zone from the interior-zone witness selection at a green commit).
- **Depends on:** 5 (render), 7 (uniqueness kernel for the exclusion legs).
- **Territory:** `KampPrior.lean` (or a new interior leaf under `Kamp/` if it grows unwieldy).
  Read-only: all exterior leaf files, guard/probe modules, the Phase-5/6/7 leaves.

### Phase 9: Interior `hexcl` supply (contrapositive channel) [NOT STARTED]
- **Goal:** Prove `kampPrior_hexcl_supply` matching the gate-match row-6 binder
  (`hexcl`, KampPrior.lean:971-977, leading `kvE_ambientDeepAnchor qnf = true →`): a within-`[x,t]`
  realizer of a bit-false fiber-consistent σ is impossible.
- **Restated consumer binder discharged**: `hexcl` (KampPrior.lean:971) + row-6 mirror in
  `EndIntervalConsumerK.lean`.
- **Byte-stable lemmas consumed**: the Phase-5 render (ambient realization feeding the fold
  back-propagation); the Phase-7 uniqueness/readback kernel; `kvE_ambientDeepAnchor_zero` (m=0).
- **Tasks:**
  - [ ] **G1-3**: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW agreement,
        via the Phase-7 uniqueness/readback kernel (deep-anchored: any second witness's deep content
        is pinned; fakes are guard-excluded). Consume the Phase-5 render for the ambient realization
        exactly as Phase 8.
  - [ ] Deliver `kampPrior_hexcl_supply`. Machine gate: scoped build; `lean_verify` at floor axioms;
        guard-unfold scan (zero); frozen-boundary audit; prior certificate set green.
- **Timing:** 3-5 hours.
- **Depends on:** 5 (render), 7 (uniqueness kernel), 8 (shares the interior seam and `hreal`
  machinery).
- **Territory:** same as Phase 8.

### Phase 10: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body (KampPrior.lean:506-519) to discharge all 13
  ledger rows and replace the `:519` sorry (route R4).
- **Restated consumer site discharged**: `kampPrior_site_rungK_gate_match` (KampPrior.lean:941-1043) —
  the arm must PRODUCE `kvE_ambientDeepAnchor qnf = true` where the six ambient-guarded binders (rows
  5/6/10-13) demand it, from the realized ambient in scope at the recursion site.
- **Byte-stable lemma supplying the guard antecedent**: `kvE_ambientDeepAnchor_of_realized`
  (ExteriorAmbientDeepAnchorK.lean:195 — PRODUCE guard=true from the ambient realizer; this is the
  "supply side" the delegation names — the arm holds the ambient realizer and feeds it to the guard
  lemma to satisfy the restated binders). NEVER unfold the guard.
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
        recursive calls). Rows 1-2 discharged.
  - [ ] **G3c-2**: discharge rows 5-6 via Phases 8-9 (+ `hfiberCons` via
        `kvE_fiberConsistent_of_realized`); rows 8-9 via Phase 3 (`kvE_hslice{Fut,Past}_supply`); rows
        10-11 via Phase 7 (G2-B3); rows 12-13 via Phase 6; rows 3-4 ambient; row 7 internal
        (task 356). Supply `kvE_ambientDeepAnchor qnf = true` to the guard-leading binders via
        `kvE_ambientDeepAnchor_of_realized` applied to the ambient realizer. Close via
        `kampPrior_case1_trichotomy_assemble` + `kampPrior_site_rungK_gate_match` (single-depth
        providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing notes (KampPrior.lean:486-518 residual comments)
        in the SAME edit to record the full resolution chain (363: fiber-consistency; 364:
        co-realization mate check; 367: fiber deep-anchor; 368: ambient deep-anchor; 358: supply +
        hsigma production + shared ambient render).
  - [ ] Machine gate: scoped build of `KampPrior`; confirm `:519` gone; `lean_verify
        nf_nvar_exist_all_depths` shows only the `| n+2 =>` arm still contributing `sorryAx`;
        guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 3-5 hours.
- **Depends on:** 6, 7, 8, 9.
- **Territory:** `KampPrior.lean` only.

### Phase 11: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
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
        vacuous-def scan clean; confirm the two `ExteriorDeepExclSupplyK.lean` strategic sorries
        (`:105`/`:133`) are retired.
  - [ ] Confirm downstream unlock: retiring `:519`/`:522` fully retires task 309's `:361` and unblocks
        task 307 Phase 7 (note in the completion summary; do not action here).
- **Timing:** 2-4 hours.
- **Depends on:** 10.
- **Territory:** `KampPrior.lean` only.

## Testing & Validation

- [ ] **Render adjudication (Phase 5, binding, BEFORE the exterior general-`m` fills)**: on paper +
      `lean_multi_attempt`, confirm `kvE_ambientDeepAnchor_iff` + `P.correct` + fold bit +
      `kvExt_gate_henv` reconstruct the full `nf_eval_nf M (k+2) 3 [w,x,t] qnf` (deep layer included).
      If not, [BLOCKED] + escalate — do NOT descend into Phases 6-7.
- [ ] **Re-probe gate (carried, already green at Phase 4)**: full certificate inventory
      (`kvE_probe368_*` x9, `kvE_probe367_*` x4, `kvE_probe364_*` x6, `kvE_probe363_*` x5,
      `kvE_probe358_*` x3, `kvE_probeM1_*` x2) `lean_verify` GREEN at floor axioms
      `[propext, Classical.choice, Quot.sound]`, no sorryAx, re-checked at every phase gate.
- [ ] **Per-phase machine gate (binding, every phase)**: scoped `lake build` + `lean_verify` of each
      new theorem at floor axioms + guard-unfold source scan (zero occurrences of
      `rw`/`unfold`/`simp only` on `kvE_ambientDeepAnchor`/`kvE_deepOnFiber`/`kvE_fiberElemConsistent`/
      `kvE_fiberConsistent`/`kvE_{fut,past}Admissible` in new proofs) + frozen-boundary `git diff`
      audit (m=0 `_zero` family, 360 supplies, k<=1 rungs, 363/364/367 declarations, the 368
      guard/probe/gate leaves, `ExteriorDeepSliceSupplyK.lean`, and `ExteriorDeepExclSupplyK.lean`'s
      m=0 legs + docstring — byte-identical).
- [ ] **Re-probe discipline per phase**: the countermodel-family certificates re-verified green after
      each phase's landings (the casts the new theorems must not readmit — esp. CM-A/CM-B).
- [ ] **Strategic-sorry retirement**: `ExteriorDeepExclSupplyK.lean:105`/`:133` GONE by end of
      Phase 6 (`lean_verify kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` shows no sorryAx).
- [ ] **Zero live sorries at terminus**: currently exactly two main-target live (`:519`, `:522`) +
      two tracked strategic (`ExteriorDeepExclSupplyK.lean:105`/`:133`); terminus shows none.
- [ ] **Axiom transcript**: `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`, and
      `completeness_discrete` at floor axioms with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline post-368: green per 368's
      terminal audit, 1761 jobs).
- [ ] **Zero-debt scan**: no vacuous definitions (`def X := True` family) introduced anywhere.

## Artifacts & Outputs

- plans/12_render-first-resequence-v08.md (this file)
- summaries/12_render-first-resequence-v08-summary.md (on implementation completion)
- Phase-5 render handoff (handoffs/, the shared render lemma signature + adjudication result)
- Lean edits: the shared ambient render lemma (new leaf); the two filled general-`m` arms in
  `ExteriorDeepExclSupplyK.lean`; the G2-2 uniqueness kernel + rows 10-11 supplies (new sibling leaf);
  `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` in `KampPrior.lean` (or interior leaf); the two
  arm rewrites replacing `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step committed as it
  lands (`task 358 phase P.O: {objective}`); failures roll back to the last green milestone.
- **Phase-5 render adjudication fails** (the deep ambient realization is not reconstructible even from
  `kvE_ambientDeepAnchor_iff` + `P.correct` + fold bit + atom layer): STOP — this is the de-inverted
  ROOT; do NOT descend into Phases 6-9. Probe the residual gap (additive leaf, sorry-free, binder-level
  closure in the docstring — house style), mark Phase 5 [BLOCKED], `/spawn 358` an isolated
  ambient-render-kernel task. Never force the render against a live countermodel.
- **Re-probe gate fails** (any prior certificate no longer verifies at floor axioms): STOP —
  the ground truth has shifted; do NOT build. [BLOCKED] with the failing certificate named; escalate.
- **Phase-6/7 exterior fill stalls** (the render is landed but the `kvE_deepOnFiber_of_realized`
  contradiction / uniqueness kernel still does not close, or a new countermodel survives the ambient
  guard): probe it (additive leaf, sorry-free), mark the phase [BLOCKED], `/spawn 358` an isolated
  kernel follow-up. Never force the supply against a live countermodel.
- **Phase-8/9 realizer production stalls** (a marked σ's zone case resists the engine): commit all
  green sub-steps, record the exact failing σ shape and goal state, [BLOCKED] + escalate via the
  literature-fidelity path (re-read source -> alternative encodings -> flag gap), never a sorry.
- **Phase-11 `:522` cannot close** under either route: [BLOCKED] + spawn an isolated arity-lift task;
  S1 (`:519`) stays landed and committed — itself a shippable milestone.
- **Regression detected** (any frozen declaration changed): snapshot per git-workflow.md, targeted
  `git checkout` of the offending file to the last green commit, re-run the scoped build, re-attempt
  within phase territory only.
