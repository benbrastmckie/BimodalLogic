# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Crux-First Re-Sequence: The Interior Realizer PRODUCES the Deep Render, Exterior Supplies CONSUME It as a Hypothesis (v09)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by PRODUCING the genuine interior realizer `hsigma` (Rabinovich 2014 Cor 5.4(1)⇐, p.9) — whose two directions ARE the deep ambient render — and then discharging the exterior deep/slice obligations by threading that render/realizer as a HYPOTHESIS (mirroring the already-landed rows 8-9 at KampPrior.lean:990/997), against task 368's ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`.
- **Status**: [NOT STARTED]
- **Effort**: 20-32 hours remaining (Phases 1-4 [COMPLETED]; 6 build/rewrite phases, each bounded to ~one agent run with a machine gate; the Crux A `hreal` phase carries a named green-commit split point)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface), 364 (completed — co-realization mate check), 367 (completed — fiber-side deep-anchor guard `kvE_deepOnFiber`), **368 (completed, verified — ambient-side deep-saturation/EF-closure guard `kvE_ambientDeepAnchor`; CLOSED the plan-06 Phase-4 BLOCKER by excluding CM-A/CM-B from the antecedent population, 2026-07-14)**
- **Research Inputs**:
  - **handoffs/phase-5-handoff-20260714.md** (2026-07-14 — AUTHORITATIVE driver for this revision: the machine-grounded render-adjudication finding that REFUTED the v08 "separable shared render" premise. The full deep ambient render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` is NOT a cheap root — it is the CONCLUSION of the interior realization: `ExteriorGateAssembleK.lean:337-338` produces it ONLY via `bracketEndChar_kv_step_sound … (hreal hGuard)(hexcl hGuard)`, consuming BOTH crux supplies. Its deep ⇐ direction IS the Phase-8 witness selection; its deep ⇒ direction IS the Phase-9 exclusion. `kvE_ambientDeepAnchor_iff` yields only a syntactic `Bool`/`Prop` EF-closure with no model `M`, provably unable to discharge the model-carrier witness goal. Also: `kvE_hexclDeepFut_supply`'s binder carries no `P`/`h_UZ`/`h_SZ`/`hInt` seam, so a render lemma cannot be reconstructed at its consumption site — the render must be THREADED AS A HYPOTHESIS, exactly as rows 8-9 already do at KampPrior.lean:990/997.)
  - handoffs/phase-4-handoff-20260714.md (2026-07-14 — the prior wave-inversion finding: the exterior general-`m` supplies require the full deep ambient realization at the binder site, not derivable from `hAmb` + igPtW; the pinned rows 12-13/10-11/uniqueness target signatures; the landed m=0 skeleton)
  - specs/368_ambient_deepsaturation_efclosure_guard_against_cma_cmb/summaries/01_ambient-deep-anchor-guard-summary.md (2026-07-14 — the landed ambient guard, its byte-stable API, the consumer-binder restatement, the residue-row decision, and the certificate inventory)
  - reports/10_spawn-analysis.md (round 10 — the blocker decomposition that produced task 368: CM-A/CM-B root cause = P17 anchor-content gap on the AMBIENT side; the probe-first, one-task, 367-mirrored prescription)
  - plans/06_deep-anchor-rekey-v06.md (superseded plan; its Phase-4 BLOCKER record is the countermodel ground truth task 368 answered; Phases 1-3 preserved verbatim from it)
  - reports/08_g2-rekey-against-364-interface.md (round 8 — byte-stable 364 discharge-lemma routing, still binding)
  - reports/06_remaining-work-and-plan-revision.md (round 6 — two-live-sorry map, ordered decomposition, verification bar)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, routes R1-R5; the *mathematics* of each gap)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐ grounding; corpus: `~/Projects/Literature/sources/rabinovich_2014/chunk_0014`-`chunk_0015` — Lemma 5.3 Dedekind `inf`-selection + the Cor 5.4(1)⇐ two-way `min`/case-split. CITATION RULE (sub-index hazard): cite the PDF by page number only, e.g. "Rabinovich 2014, Cor 5.4, p.9"; NEVER md:NN line numbers)
- **Reports Integrated**: handoffs/phase-5-handoff-20260714.md (v09 — new, the render-adjudication refutation that de-inverts the de-inversion: crux-first), handoffs/phase-4-handoff-20260714.md (v08, carried — wave-inversion finding), specs/368 summary 01 (v07), reports/10_spawn-analysis.md (v07), specs/367 summary 01 (v06, carried), phase-2-v05-handoff (v06, carried), 08_g2-rekey-against-364-interface.md (v05), 06_remaining-work-and-plan-revision.md (v04), 04_post-360-gap-map-and-route.md (v03/v04), 02_literature-proof-method-survey.md (v02)
- **Artifacts**: plans/13_crux-first-interior-realizer-v09.md (this file)
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

**What changed since v08 — the render-adjudication refutation drives a crux-FIRST re-sequence.** Plan
v08 treated the full deep ambient render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` as a **separable cheap
root** (its Phase 5), to be built from `igPtW + hAmb + P` ahead of the interior realizer, so the
exterior supplies could consume it. The Phase-5 implementation (sess_1784078566_52d1da) ran that
plan's own mandatory render-adjudication gate FIRST and it **FAILED** with a machine-grounded finding:

> The full deep ambient render is the **CONCLUSION** of the interior realization, not a precursor.
> A `refine ⟨fun a => ?_, fun sub => ⟨fun hreal => ?_, fun hmark => ?_⟩⟩` split of the render exposes
> three irreducible residual goals: (1) an **atom layer** `atom_eval M [w,x,t] a ↔ qnf.1 a = true`
> that needs `hInt` + the six order facts (ABSENT at the rows-12-13 consumption site; `kvExt_gate_henv`
> is `private`); (2) the **deep ⇒** direction `(∃x1, nf_eval_nf … sub) → qnf.2 sub = true` — which IS
> the exclusion `hexcl` (old Phase 9); (3) the **deep ⇐** direction
> `qnf.2 sub = true → ∃x1 : M.carrier, nf_eval_nf M (k+1) 4 (cons x1 [w,x,t]) sub` — which IS the
> Rabinovich Cor 5.4(1)⇐ within-bracket witness selection `kampPrior_hreal_supply` (old Phase 8, the
> crux). `simp_all [kvE_ambientDeepAnchor_iff]` rewrites `hAmb` to a purely SYNTACTIC `Bool`/`Prop`
> statement with no model `M`, no carrier — provably unable to discharge goal (3)'s model-carrier
> witness. `ExteriorGateAssembleK.lean:337-338` builds the render ONLY via
> `bracketEndChar_kv_step_sound … (hreal hGuard)(hexcl hGuard)`. The v08 de-inverted-root premise is
> CIRCULAR: the render's directions ARE Phases 8/9.

So v08's Phase 5 as a separable node **does not exist**. The render is produced by the two crux
interior phases; the exterior supplies must take it AS A HYPOTHESIS. **Rows 8-9 already demonstrate
the correct pattern**: `hslicePast` (KampPrior.lean:989-990) and `hsliceFut` (:996-997) both LEAD with
`nf_eval_nf M (k + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →` — the render is a binder
hypothesis, not something reconstructed locally.

**This v09 revision re-orders the remaining work CRUX-FIRST** and DISSOLVES the phantom separable-render
phase:
1. Produce the interior realizer `hsigma` / `hreal` (Crux A — old Phase 8, the deep ⇐ witness
   selection) FIRST — the genuine hardest kernel of the task.
2. Produce `hexcl` (Crux B — old Phase 9, the deep ⇒ / contrapositive channel).
3. Together (1)+(2) are precisely what `bracketEndChar_kv_step_sound` consumes to yield the deep
   render; the exterior deep/slice supplies (rows 12-13, then uniqueness + rows 10-11) then take that
   render AS A HYPOTHESIS, re-specified to mirror rows 8-9.
4. Arm-rewrite retire S1 (`:519`), then G4 retire S2 (`:522`) + terminal audit.

**This is a RE-SEQUENCE + RE-SPECIFICATION, NOT a math rewrite.** All v08/v07 mathematics, byte-stable
lemma names (363/367/368), target signatures, machine-gate checklists, routing constraints,
literature-fidelity notes, and preserved-asset accounting are carried verbatim. The Rabinovich
witness-selection mathematics is UNCHANGED. Only the phase ORDER changes (crux-first instead of
render-first), the phantom render phase is dissolved (folded into the crux phases as their genuine
output), and the exterior supply/consumer binders are re-specified to carry the render as a hypothesis.

**The crux is UNCHANGED and now correctly ordered: PRODUCE `hsigma`** — the genuine interior/exterior
realizer `nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`, selected per Rabinovich 2014 Cor 5.4(1)⇐ (p.9) via the
two-way `min`/case-split induction. The engine is LANDED sorry-free
(`kampPrior_fChain_realize_from` KampPrior.lean:1415, `_bracket` :1549,
`kampPrior_{fut,past}Realizer_assemble` :1602, `_of_pos` :1662 + Past mirrors) — this task
INSTANTIATES it. The deep ambient render (formerly v08's phantom root) is now correctly understood as
the JOINT OUTPUT of Crux A + Crux B, produced at the arm site via `bracketEndChar_kv_step_sound`.

**Definition of done** (binding): `:519` and `:522` both sorry-free; the two tracked strategic
sorries in `ExteriorDeepExclSupplyK.lean` (`:105`, `:133`) retired; all igPtW-guarded rows 5/6/10-13
discharged with the render/realizer threaded per the crux outputs and witnesses/mates extracted only
through `kvE_ambientDeepAnchor_iff`; full-tree `lake build` GREEN;
`#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete` =
`[propext, Classical.choice, Quot.sound]` (+ acceptable `ofReduceBool`/`trustCompiler` from
`native_decide` in the Syntax layer) with **NO `sorryAx`**; all task-368 + prior-family
(367/364/363/358/M1) certificates re-verified green at floor axioms; guard-unfold source scan = 0.
`:522` CANNOT be silently deferred. **ZERO-DEBT TERMINUS**: no sorry, no vacuous definition, no
forcing a proof against a live countermodel — a sub-piece that cannot close green goes [BLOCKED] with
structured escalation, never a landed sorry.

### Research Integration

Newly integrated this revision (v08 -> v09):

- **handoffs/phase-5-handoff-20260714.md** (the render-adjudication refutation). Integration effects:
  1. **The v08 separable-render phase is DISSOLVED (not carried as a `[NOT STARTED]` phase).** The
     render is not a cheap root; it is the CONCLUSION of the interior realization. There is NO
     standalone `igPtW + hAmb + P → render` lemma. The content of v08's Phase 5 is precisely Phases
     5+6 of this plan (Crux A `hreal` + Crux B `hexcl`), whose joint consumption by
     `bracketEndChar_kv_step_sound` (ExteriorGateAssembleK.lean:337-338) yields the render.
  2. **Crux-FIRST re-ordering.** The remaining phases are re-sequenced so the interior realizer
     produces the render FIRST (Phases 5-6), then the exterior deep/slice supplies consume it as a
     hypothesis (Phases 7-8), then the arm rewrites (Phases 9-10). This is the topological order
     dictated by the render's real data-flow, confirmed against `ExteriorGateAssembleK.lean:337-338`.
  3. **Render-as-hypothesis threading (mirroring rows 8-9).** Rows 8-9 (`hslicePast` KampPrior.lean:990,
     `hsliceFut` :997) ALREADY take `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` as a binder hypothesis. The
     exterior deep/slice supplies (rows 10-13) are re-specified to do the same: their supply lemmas
     (`kvE_hexclDeepFut_supply`, etc.) take a render/realizer hypothesis parameter, and their
     consumer binders are updated in lockstep to carry it.
  4. **CONSUMER-BINDER SIGNATURE CHANGE FLAGGED (not assumed free).** Source inspection this revision
     confirms rows 10-13 (`hexclSlicePast` KampPrior.lean:1003, `hexclSliceFut` :1010, `hexclDeepPast`
     :1017, `hexclDeepFut` :1024) currently LEAD with `kvE_ambientDeepAnchor qnf = true → … igPtW…eval_at
     M atomMap w →` and do NOT carry the render hypothesis — UNLIKE rows 8-9. Threading the render as a
     hypothesis into rows 10-13 therefore REQUIRES changing these frozen consumer-region binder
     signatures (and their `kampPrior_site_rungK_gate_match` / `EndIntervalConsumerK` /
     `ExteriorGateAssembleK` mirrors) to carry `nf_eval_nf M (k+2) 3 [w,x,t] qnf →`. This is an
     explicit, called-out sub-step and risk in Phase 7 — it is NOT assumed free. See Phase 7 and
     Risks §"Consumer-binder signature retrofit".

Carried from v08 (still integrated): handoffs/phase-4-handoff-20260714.md (the pinned rows 12-13/10-11/
uniqueness target signatures + landed m=0 skeleton), specs/368 summary (ambient guard
`kvE_ambientDeepAnchor` + API + restated binders + probes — the re-keying contract), reports/10
(CM-A/CM-B characterization + interface-only scope boundary), specs/367 summary (fiber guard
`kvE_deepOnFiber` + API — the rows-8-9 gate), report 08 (byte-stable 364 discharge routing), report 06
(flow), report 04 (gap mathematics), report 02 (Rabinovich engine grounding).

### Dissolved Node: the v08 "separable shared render" phase (FOLDED into Crux A/B — NOT a phase)

v08 Phase 5 ("Shared interior ambient render — the de-inverted root, a standalone
`igPtW + hAmb + P → nf_eval_nf M (k+2) 3 [w,x,t] qnf` lemma") **does not exist as a separable node**
and is REMOVED. It is not renumbered, not marked `[NOT STARTED]`, and carries no phase heading. Its
intended content is the JOINT OUTPUT of Crux A (Phase 5, deep ⇐ witness selection) and Crux B (Phase 6,
deep ⇒ exclusion): `ExteriorGateAssembleK.lean:337-338` produces the render ONLY via
`bracketEndChar_kv_step_sound … (hreal hGuard)(hexcl hGuard)`. Do NOT re-attempt a standalone render
lemma — the Phase-5 handoff machine-refuted it (three irreducible residual goals: an atom layer needing
absent `hInt`, and the two deep directions that ARE the crux phases). The render is henceforth THREADED
AS A HYPOTHESIS into the exterior consumers (Phases 7-8), exactly as rows 8-9 already do at
KampPrior.lean:990/997.

### GLOBAL ROUTING CONSTRAINT (binding on Phases 5-10)

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

**Scope caveat (v09):** the ONE deliberate, flagged exception to "frozen consumer region" is the
rows-10-13 binder-signature retrofit in Phase 7 (adding the render hypothesis to
`hexclSlicePast`/`hexclSliceFut`/`hexclDeepPast`/`hexclDeepFut` at KampPrior.lean:1003/1010/1017/1024
and their gate-match / `EndIntervalConsumerK` / `ExteriorGateAssembleK` mirrors, to mirror rows 8-9 at
:990/997). Rows 8-9 themselves, the m=0 legs, and all 363/364/367/368 leaves stay byte-identical.

| Landed asset | Interface (by name) | File:line | Owner |
|---|---|---|---|
| **k=0 arm of `\| 1 =>`** | `kampPrior_case1_arm_k0` | KampPrior.lean:~271 (consumed :504) | 358 P5.1 — **FROZEN** |
| **k=1 arm of `\| 1 =>`** | `kampPrior_case1_arm_k1` | KampPrior.lean (consumed :505) | 309 P20 — **FROZEN** |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | 350 — **FROZEN** |
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1415/1549/1602/1662 (+Past) | 358 P1-2 — sorry-free |
| Consumer stack + 13-row ledger (BINDING) | `endIntervalStepPrior`/`endInterval_step_correct`/ledger table | EndIntervalConsumerK.lean | 349+367+368 |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:941-1043 | 349 (368-mirrored binders) |
| Render producer (joint output of Crux A+B) | `bracketEndChar_kv_step_sound` (consumes `hreal`+`hexcl` → `∃w, nf_eval_nf M (k+2) 3 [w,x,t] qnf`) | ExteriorGateAssembleK.lean:337-338 | consume by name; do NOT reconstruct a standalone render |
| Atom-render helper (atom layer only) | `kvExt_gate_henv` (igPtW eval → `nf_eval_nf M 0 3 [w,x,t] qnf.1`) | ExteriorGateAssembleK.lean:61 (`private`; needs `hInt`) | 368 — **FROZEN, consume by name** |
| **368 ambient guard + API** | `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized` | **ExteriorAmbientDeepAnchorK.lean:109/125/131/195** | **368 — the re-keying contract; FROZEN** |
| **368 gate carrier** | `kvE_ambientGuardForm`, `kvE_ambientGuardForm_truth`; `bracketEndChar_kvExt_correct_prior` | ExteriorGateAssembleK.lean | **368 — FROZEN, consume by name** |
| **368 probe certificates** | `kvE_probe368_{cmA,cmB}_ambient_rejected`, `_real_ambient_anchored`, `_{cmA_row13,cmB_row5}_refuted`, `_depth2_ambient_rejected`, `_ambient_copyPlant_{passes_guard,collapses}`, `_ambient_supply_route` | ExteriorAmbientDeepAnchorProbe358K.lean | **368 — GREEN adjudication evidence; cite, do not modify** |
| **367 deep-anchor guard + API** | `kvE_deepOnFiber` + `_zero`/`_base`/`_iff`/`_row`/`_of_realized` | ExteriorFiberDeepAnchorK.lean:81-168 | **367 — FROZEN** |
| **367 probe certificates** | `kvE_probe367_tailDG_deep_rejected`, `_real_slice_deep_anchored`, `_depth2DG_deep_rejected`, `_copyPlant_collapses` | ExteriorFiberDeepAnchorProbe367K.lean | **367 — FROZEN** |
| **358 Phase-3 landing** (rows 8-9 supply, render-as-hypothesis PATTERN) | `kvE_hsliceFut_supply` (:131), `kvE_hslicePast_supply` (:161), `kvE_deepMate_collapse` (:90), `kvE_{fut,past}SliceEq_refl` (:63/:72) — consumer binders `hslicePast`/`hsliceFut` (KampPrior.lean:989-995/996-1002) ALREADY carry `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` (the render hypothesis to mirror) | **ExteriorDeepSliceSupplyK.lean** | **358 P3 — FROZEN; the pattern Phases 7-8 replicate** |
| **358 Phase-4 m=0 deep-exclusion landing** | `kvE_deepExcl_zero_vacuous` (:63, sorry-free), `kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` **m=0 arms** (sorry-free); general-`m` arms are the tracked strategic sorries `:105`/`:133` to be FILLED | **ExteriorDeepExclSupplyK.lean** | **358 P4 — m=0 legs FROZEN; append/fill only** |
| **m=0 slice supply** (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (:1250) (+Past :769) | ExteriorPinnedConverse{K,PastK}.lean | 360 — **FROZEN, byte-unchanged through 368** |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_futSliceUnique_zero` (:1122)/`kvE_pastSliceUnique_zero` (:356) | ExteriorPinnedConverse{K,PastK}.lean | 360 — **FROZEN** |
| 363/364 fiber-consistency predicate + discharge | `kvE_fiberElemConsistent`/`kvE_fiberConsistent` (+`_zero`, `_of_realized` x2) | ExteriorFiberConsistencyK.lean | **FROZEN — consume by name, NEVER unfold** |
| 363/364 exterior guard + entry/readers | `kvE_{fut,past}Admissible`, `kvE_futRealizer_admissible` (+Past), `_fiber_dichotomy`, `_onFiber`, `_offFiber` | ExteriorNegation{K,PastK}.lean; ExteriorConverter{K,PastK}.lean | **FROZEN** |
| 364/363/358 rejection certificates | `kvE_probe364_*`, `kvE_probe363_*`, `kvE_probe358_*`, `kvE_probeM1_*` | ExteriorFiberConsistencyProbe{,364}K.lean; ExteriorPinnedProbe358{,Tail}K.lean; ExteriorPinnedProbeM1K.lean | **FROZEN — regression records** |
| Exterior converters (discharge templates) | `kvE_futBundle_of_realizer` (:231); `kvE_pastBundle_of_realizer` (:199) | ExteriorConverter{K,PastK}.lean | 356/360 — apply to genuine `hsigma` only |
| n=0 / k=0 target arms | `nf_nvar_exist_all_depths` `\| 0 =>`, `\| k+1, 0 =>` | KampPrior.lean | do NOT touch |

Task 360's m=0 supply and the k<=1 rungs are byte-unchanged through 363, 364, 367, AND 368; this plan
MUST keep them so. The m=0 discharge of the ambient antecedent flows through
`kvE_ambientDeepAnchor_zero` (`rfl`, landed by 368) composed with the frozen task-360 `_zero`
supplies — no m=0 work remains. The Phase-4 m=0 deep-exclusion legs
(`ExteriorDeepExclSupplyK.lean`) are likewise landed and FROZEN; only the two general-`m` arms
(`:105`, `:133`) are open, and this plan FILLS them (append/edit within those two arm bodies only,
plus the flagged render-hypothesis parameter addition to their signatures).

## Goals & Non-Goals

- **Goals**:
  - **PRODUCE the interior realizer `hsigma` / `hreal` (Crux A)**: prove `kampPrior_hreal_supply`
    matching the row-5 binder (KampPrior.lean:964-970): under `kvE_ambientDeepAnchor qnf = true`, for
    every igPtW-selected w and qnf-marked fiber-consistent σ, produce `x1` with
    `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`. Rabinovich 2014 Cor 5.4(1)⇐ (p.9) within-bracket bounded
    witness selection through the landed engine; this is the deep ⇐ direction of the render and the
    genuine hardest kernel of the whole task.
  - **PRODUCE `hexcl` (Crux B)**: prove `kampPrior_hexcl_supply` matching the row-6 binder
    (KampPrior.lean:971-977): a within-`[x,t]` realizer of a bit-false fiber-consistent σ is
    impossible — the deep ⇒ / contrapositive channel.
  - **Confirm the joint render output**: Crux A + Crux B are exactly what
    `bracketEndChar_kv_step_sound` (ExteriorGateAssembleK.lean:337-338) consumes to yield
    `∃w, nf_eval_nf M (k+2) 3 [w,x,t] qnf`. Do NOT build a standalone render lemma.
  - **Fill the two deferred rows-12-13 general-`m` arms** (`ExteriorDeepExclSupplyK.lean:105`, `:133`),
    re-specified to TAKE the render/realizer as a hypothesis (mirroring rows 8-9 at :990/997): with the
    render threaded in, close by the `kvE_deepOnFiber_of_realized` contradiction. Retrofit the rows-10-13
    consumer binders to carry the render hypothesis (flagged signature change).
  - **Rebuild the G2-2 uniqueness kernel** (`kvE_futSliceUnique`/`kvE_pastSliceUnique` general-m) over
    the ambient-guarded + deep-anchored population, extracting EF-closure only via
    `kvE_ambientDeepAnchor_iff`; supply rows 10-11 (`hexclSliceFut`/`hexclSlicePast`) consuming the
    render hypothesis + the uniqueness kernel.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 13 ledger rows, PRODUCING the render via
    `bracketEndChar_kv_step_sound (hreal)(hexcl)` and threading it to the exterior consumers, and
    supplying `kvE_ambientDeepAnchor qnf = true` via `kvE_ambientDeepAnchor_of_realized` where the
    row-5/6 gate binders still demand it; replace `:519`.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm; replace `:522`.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset — esp. the 368 guard/API/probe leaf,
    the 367 guard/API/probes, the `_zero` kernel family, the k<=1 rungs, task 360 m=0 supply, task
    358 Phase 3's `ExteriorDeepSliceSupplyK.lean` (rows 8-9), and task 358 Phase 4's m=0 legs in
    `ExteriorDeepExclSupplyK.lean` (only the two general-`m` arms + their signature are open).
  - **Do NOT re-attempt a standalone `igPtW + hAmb + P → render` lemma** — machine-refuted (Phase-5
    handoff). The render is the JOINT OUTPUT of Crux A+B and is threaded as a hypothesis.
  - Do NOT unfold any guard body (GLOBAL ROUTING CONSTRAINT) — byte-stable lemmas only.
  - Do NOT re-run the render-adjudication as an independent gate: the finding is established (the
    render is the conclusion of the interior realization, not a separable root).
  - Do NOT re-attempt v05's G2-1 (`kvE_{fut,past}SliceId_of_end` at general m via the free-env →
    pinned upgrade) — machine-refuted; superseded.
  - Do NOT re-key or re-supply rows 8-9 — they carry the render hypothesis and are done (Phase 3);
    they are the PATTERN, not work.
  - Do NOT re-introduce any `hbr*`-shaped UNIVERSAL binder; do NOT consume
    `kvE_{fut,past}Bundle_of_realizer` without a genuine produced realizer.
  - Do NOT re-derive, weaken, or re-probe CM-A/CM-B or add ambient guard machinery — task 368 owns
    the interface; this task consumes it.
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` M-independent.

## Risks & Mitigations

- **Risk: `hsigma` production (Crux A, Phase 5) exceeds one agent run.** This is the single hardest
  phase — Rabinovich Cor 5.4(1)⇐ within-bracket witness selection. Mitigation: split at the documented
  green-commit boundary — **Phase 5.1 exterior-zone drivers** (σ with `x1` outside `(x,t)`: fold bit
  fires `kvE_{fut,past}Pos`, `kampPrior_{fut,past}Realizer_of_pos` selects `x1`, transfer inputs close
  by the recursion IH at depth k) vs. **Phase 5.2 interior-zone F-chain selection** (σ with `x1 ∈ (x,t)`:
  `kampPrior_fChain_realize_bracket` with F-chain firing from the fold-bit fiber content, bracket
  endpoints `(x,t)` — the Cor 5.4(1)⇐ selection). Each sub-phase is self-contained with its own green
  commit. If the interior-zone F-chain selection resists the engine after literature-fidelity
  escalation (re-read source → alternative encodings → check unstated lemmas), [BLOCKED] + escalate —
  never a sorry.
- **Risk: Consumer-binder signature retrofit (Phase 7) touches the frozen consumer region.** Threading
  the render as a hypothesis into rows 10-13 REQUIRES changing `hexclSlicePast`/`hexclSliceFut`/
  `hexclDeepPast`/`hexclDeepFut` (KampPrior.lean:1003/1010/1017/1024) to carry
  `nf_eval_nf M (k+2) 3 [w,x,t] qnf →`, plus their `kampPrior_site_rungK_gate_match` (:941-1043),
  `EndIntervalConsumerK.lean`, and `ExteriorGateAssembleK.lean` mirrors — this is NOT free. Mitigation:
  the change is a MECHANICAL replication of the rows-8-9 shape (:990/997), which already type-checks and
  is consumed at the same site; do it as a single atomic edit across all mirror sites, then scoped-build
  the whole consumer stack before proceeding. If the retrofit cascades into the row-5/6 producer binders
  or breaks `bracketEndChar_kvExt_correct_prior`, STOP, record the exact break, [BLOCKED] + escalate —
  do not paper over it. Re-confirm rows 8-9 and the m=0 legs stay byte-identical.
- **Risk: rows 12-13 general-`m` fill needs the σ-realizer AND ambient realized simultaneously** for
  `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 needs both). Mitigation: with the
  render threaded as a hypothesis the ambient realization is IN SCOPE by name; the σ-realizer is the
  hypothesis being contradicted (`_hσ` at the exterior tuple). Both present at the binder site.
- **Risk: G2-2 uniqueness at general m needs a deep transfer kernel** (EF-style exterior-chain
  matching). Mitigation: build over the ambient-guarded + deep-anchored population where the second
  witness's deep content is pinned; both σ's realized over the SAME rendered ambient tail (threaded
  hypothesis); extract via `kvE_ambientDeepAnchor_iff`; probe against the countermodel families before
  trusting; [BLOCKED]+escalate on a new countermodel.
- **Risk: `hexcl` (Crux B) does not close under the contrapositive route.** Mitigation: the
  back-propagation through the fold (`nf_eval_nfk_iff_efold`) + the Phase-8 uniqueness/readback kernel
  is the route; if it stalls, probe the residual against CM-A/CM-B (fakes are guard-excluded), [BLOCKED]
  + escalate. Note Crux B shares the interior seam with Crux A and reuses its machinery.
- **Risk: `:522` arity-lift does not close under either reduction route.** Mitigation: G4-1 route
  adjudication at Phase 10 start; if neither closes, [BLOCKED] + spawn an isolated arity-lift task,
  keep S1 landed — NEVER a carried sorry.
- **Risk: touching frozen layers.** Mitigation: per-phase `git diff` audit against the Preserved
  Assets table (the exactly-5 368-changed files must not be re-touched beyond `KampPrior.lean`'s own
  arm bodies + the flagged rows-10-13 binder retrofit, the 368 probe/guard leaves stay byte-identical,
  the Phase-3 rows-8-9 leaf + the Phase-4 m=0 legs stay byte-identical); scoped `lake build` per phase;
  full-tree build + certificate re-verification at terminus.

## Implementation Phases

**Dependency Analysis** (wave DAG — CRUX-FIRST; the interior realizer is the root, the render is its
joint output, exterior supplies consume it as a hypothesis):

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 5 (Crux A — `hreal`) | -- (Phases 1-4 complete) |
| 2 | 6 (Crux B — `hexcl`) | 5 (shares interior seam; joint render output needs both) |
| 3 | 7 (rows 12-13 fill), 8 (uniqueness + rows 10-11) | 5, 6 (the render, produced by `hreal`+`hexcl`) |
| 4 | 9 (arm rewrite — retire S1 `:519`) | 5, 6, 7, 8 (all 13 rows discharged) |
| 5 | 10 (retire S2 `:522` + terminal audit) | 9 |

Crux A (`hreal`, Phase 5) is the ROOT: it is the deep ⇐ direction of the render and the hardest kernel.
Crux B (`hexcl`, Phase 6) is the deep ⇒ direction and shares the interior seam. Together they are what
`bracketEndChar_kv_step_sound` (ExteriorGateAssembleK.lean:337-338) consumes to PRODUCE the deep
render. The exterior deep/slice supplies (Phases 7-8) then TAKE that render as a hypothesis (mirroring
rows 8-9 at KampPrior.lean:990/997); they occupy disjoint territory
(`ExteriorDeepExclSupplyK.lean` two general-`m` arms vs. a new uniqueness + slice leaf) and can run in
the same wave. The arm rewrite (Phase 9) instantiates the site seam, produces the render, threads it to
the exterior consumers, and discharges all 13 rows; Phase 10 retires the arity-lift arm + terminal
audit. Every phase ends with a machine gate: scoped build + `lean_verify` at floor axioms + guard-unfold
source scan + frozen-boundary git-diff audit.

### Phase 1: Consume and pin the task-363 interface [COMPLETED]

> **P1 outcome (2026-07-14, sess_1784045100_2e3ffe)**: all six checklist items executed —
> signatures/conjunct-2/antecedent-pair pinned by name; three re-probe certificates lean_verify
> GREEN at floor axioms; target signatures recorded in handoffs/phase-1-handoff-20260714.md.
> Anchor-content gate: PASSED-WITH-ADVERSE-FINDING — machine-confirmed in v05 P2 and DISSOLVED in
> three steps: task 364 (co-realization mate check), task 367 (fiber-side deep-anchor guard), and
> task 368 (ambient-side deep-anchor guard).
- **Goal:** (historical) Bind 363's landed fiber-consistency interface by name.
- **Tasks:** (all executed; see plans/05 for the retained checklist)
- **Timing:** 1-2 hours (spent).
- **Depends on:** none.
- **Completed:** 2026-07-14 (sess_1784045100_2e3ffe; commit b11c4ac06).

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
- **Completed:** 2026-07-14 (sess_1784059448_2c72f2_358; commit 46d1f3ebc).

### Phase 3: Exterior rows 8-9 supply at general m (deep-mate route, render-as-hypothesis) [COMPLETED]

> **P3 outcome (2026-07-14, sess_1784059448_2c72f2_358)**: NEW leaf
> `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` — `kvE_hsliceFut_supply` (:131) /
> `kvE_hslicePast_supply` (:161) at GENERAL k (binder-shape-exact), via the mate-collapse kernel
> `kvE_deepMate_collapse` (:90) + `kvE_{fut,past}SliceEq_refl` (:63/:72). Machine gate: scoped build
> green (1031 jobs); all three new theorems at floor axioms, no sorryAx; guard-unfold scan zero;
> frozen files byte-identical.
>
> **THE PATTERN (v09): rows 8-9's consumer binders `hslicePast` (KampPrior.lean:989-995) / `hsliceFut`
> (:996-1002) ALREADY carry `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` (lines 990/997) — the render as a
> HYPOTHESIS.** They do NOT lead with `kvE_ambientDeepAnchor qnf = true →`. This is precisely the
> shape Phases 7-8 replicate for rows 10-13. Rows 8-9 carry NO ambient antecedent and stay FROZEN.
- **Goal:** (historical) Prove `kvE_hsliceFut_supply`/`kvE_hslicePast_supply` at general m.
- **Tasks:** (all executed; see plans/06 for the retained checklist)
- **Timing:** 4-6 hours (spent).
- **Depends on:** 2.
- **Completed:** 2026-07-14 (sess_1784059448_2c72f2_358; commit 46d1f3ebc).

### Phase 4: 368 ambient-guard interface pin + re-probe gate + m=0 deep-exclusion arms [COMPLETED]

> **P4 outcome (2026-07-14, sess_1784078566_52d1da; commit d62d69b20)**: pin + re-probe gate GREEN;
> the m = 0 arms of rows 12-13 LANDED sorry-free; the general-`m` exterior supply produced a decisive
> wave-inversion FINDING (later refined by the Phase-5 render-adjudication into the crux-first order of
> this v09). See handoffs/phase-4-handoff-20260714.md.
>
> **Landed this phase** (green, FROZEN):
> - Pin (read-only): `kvE_ambientDeepAnchor` + `_zero`/`_iff`/`_of_realized`
>   (ExteriorAmbientDeepAnchorK.lean:109/125/131/195), the six ambient-guarded binders
>   (KampPrior.lean:964/971/1003/1010/1017/1024) and their `EndIntervalConsumerK`/
>   `ExteriorGateAssembleK` mirrors, the frozen m=0 `_zero` supplies. Target general-`m` signatures
>   recorded in the Phase-4 handoff.
> - Re-probe gate: representative `kvE_probe368_*`/`kvE_probe367_*` certificates `lean_verify` GREEN
>   at floor axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx; Kamp-path sorries confirmed
>   exactly KampPrior.lean:519/:522; rows 8-9 confirmed to carry the render hypothesis (NOT the ambient
>   antecedent) — Phase-3 landing unaffected.
> - NEW leaf `ExteriorDeepExclSupplyK.lean`: `kvE_deepExcl_zero_vacuous` (:63, sorry-free, floor
>   axioms) + `kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` with **m=0 arms sorry-free**
>   (vacuity via `kvE_deepOnFiber_zero`). Scoped build green (1035 jobs); guard-unfold scan clean;
>   frozen files byte-identical.
>
> **FINDING (drove v08, refined by v09)**: the general-`m` arms of rows 12-13/10-11/uniqueness ALL
> require the full deep ambient realization `nf_eval_nf M (k+2) 3 [w,x,t] qnf`. v08 mis-modeled this as
> a separable render root; the Phase-5 render-adjudication (handoffs/phase-5-handoff) machine-refuted
> that and established the render is the CONCLUSION of the interior realization — hence this v09
> crux-first re-sequence.
- **Goal:** (historical) Pin the 368 ambient-guard interface, certify ground truth, and land the m=0
  deep-exclusion legs. **The general-`m` exterior supply is now re-sequenced BEHIND the crux phases.**
- **Tasks:** (pin + re-probe gate + m=0 arms all executed; the general-`m` arms are re-sequenced —
  see Phases 5, 6, 7, 8)
- **Timing:** ~2 hours (spent on the landed pin/gate/m=0 portion).
- **Depends on:** none (Phases 1-3 complete).
- **Completed:** 2026-07-14 (sess_1784078566_52d1da, commit d62d69b20 — pin + gate + m=0 legs).

### Phase 5: Crux A — interior `hreal` supply: PRODUCE `hsigma` (Rabinovich Cor 5.4(1)⇐ witness selection, the deep ⇐ direction) [PARTIAL]

**PARTIAL (session sess_1784078566_52d1da, 2026-07-14).** The correctly-typed
`kampPrior_hreal_supply` (row-5 binder conclusion verbatim) landed green in the NEW leaf
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorHrealSupplyK.lean`;
body is ONE tracked strategic sorry. **Machine-confirmed root obstruction (fix-forward blocker,
not forcing):** the plan's firing route ("fold bit fires `kvE_{fut,past}Pos`") is CIRCULAR — the
only fold-bit → model-realizer bridge `igFoldBit_realize_iff` (`InteriorGateGeneralK.lean:563`)
requires the deep ambient render `nf_eval_nf M (k+2) 3 [w,x,t] qnf` as a hypothesis, and that
render is DOWNSTREAM of `hreal` (produced by `bracketEndChar_kv_step_sound (hreal)(hexcl)` at
`ExteriorGateAssembleK.lean:337-338`). The row-5 binder exposes only `igPtW`-at-`w` (igZAtW
zone); the endpoint firings the exterior drivers consume are absent, and
`kvE_ambientDeepAnchor_iff` gives only a syntactic EF-closure (no carrier). Neither 5.1 nor 5.2
green-commit boundary reached (both need the non-circular firing transducer).
**Unblock:** build an `igFoldBit → kvE_{fut,past}Pos` firing transducer that routes through the
depth-`k` recursion IH bundled in `P` WITHOUT `igFoldBit_realize_iff`'s render hypothesis — OR
re-sequence so Crux A and the render are produced jointly (as the prior render-adjudication
recommended). `lean_verify` = `[propext, sorryAx, Classical.choice, Quot.sound]`; frozen boundary
clean (only the new leaf added).
- **Goal:** Prove `kampPrior_hreal_supply` matching the gate-match row-5 binder
  (`hreal`, KampPrior.lean:964-970): under `kvE_ambientDeepAnchor qnf = true`, for every igPtW-selected
  w and every qnf-marked fiber-consistent σ, produce `x1` with
  `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` — the genuine realizer `hsigma`. **This is the task's crux and
  the ROOT of the crux-first DAG**: it is the deep ⇐ direction of the deep ambient render (Phase-5
  handoff goal 3), and the hardest kernel of the whole task. Rabinovich 2014 Cor 5.4(1)⇐ (p.9): from
  F-chain firing inside the bracket, select the witness by the two-way `min`/case-split induction
  (corpus: rabinovich_2014/chunk_0015; the `inf`-selection is Lemma 5.3, p.8-9, chunk_0014).
  LITERATURE FIDELITY: follow the source case structure step-by-step; the landed engine transcribes it
  — this phase INSTANTIATES it.
- **Why this is the root** (Phase-5 handoff): the full deep ambient render
  `nf_eval_nf M (k+2) 3 [w,x,t] qnf` is NOT a separable precursor — its deep ⇐ direction
  `qnf.2 sub = true → ∃x1 : M.carrier, nf_eval_nf M (k+1) 4 (cons x1 [w,x,t]) sub` IS exactly this
  supply. `kvE_ambientDeepAnchor_iff` yields only a syntactic EF-closure (no model `M`) and cannot
  produce the model-carrier witness; the witness comes from the engine here.
- **Restated consumer binder discharged**: `hreal` (KampPrior.lean:964) — leads with
  `kvE_ambientDeepAnchor qnf = true →`; and the row-5 mirror in `EndIntervalConsumerK.lean` /
  `bracketEndChar_kvExt_correct_prior`. NO signature change to rows 5-6 (they are the PRODUCERS).
- **Byte-stable lemmas consumed**: `kampPrior_{fut,past}Realizer_of_pos` (KampPrior.lean:1662 + Past),
  `kampPrior_fChain_realize_bracket` (:1549), `kampPrior_fChain_realize_from` (:1415),
  `kvE_deepOnFiber_of_realized` (guard antecedents on realizer-derived σ),
  `kvE_fiberConsistent_of_realized` (`hfiberCons`), `kvE_{fut,past}Bundle_of_realizer` (converter seam),
  the provider bridge `kampPrior_existProviders_of_ih_existF0_char` + `hcharK` + `P.correct` under the
  pinned seam, `kvE_ambientDeepAnchor_iff` (deep-content EF-closure readback).
- **Tasks:**
  - [ ] **G1-2 population handling**: `=>`-direction (forall-σ agreement, DEFINITIONAL); `<=`-ws
        (igPtW-selected, `hAmb` in scope): reconstruct w's realization of `igFoldBit qnf` from
        `P.correct` + the fold bit + `kvE_ambientDeepAnchor_iff`.
  - [ ] **[Phase 5.1 — exterior-zone drivers, green-commit boundary]** per marked σ with `x1` OUTSIDE
        `(x,t)`: fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; drivers `kampPrior_{fut,past}Realizer_of_pos`
        select `x1` and emit `hsigma`; transfer inputs close by the recursion IH at depth k. **Green
        commit** (`task 358 phase 5.1: hreal exterior-zone witness drivers`).
  - [ ] **[Phase 5.2 — interior-zone F-chain selection, green-commit boundary]** per marked σ with
        `x1 ∈ (x,t)`: `kampPrior_fChain_realize_bracket` with F-chain firing from the fold-bit fiber
        content, bracket endpoints `(x,t)` — the Cor 5.4(1)⇐ selection. **Green commit**
        (`task 358 phase 5.2: hreal interior-zone F-chain selection`).
  - [ ] Discharge `hfiberCons` on realized ambients via `kvE_fiberConsistent_of_realized`; discharge
        guard antecedents on realizer-derived σ via `kvE_deepOnFiber_of_realized`.
  - [ ] **Re-probe** the produced `hreal` against the CM-A/CM-B casts + the depth-2 / copy-plant
        families (the witness must not exist for the guard-false fakes). Certify green.
  - [ ] Deliver `kampPrior_hreal_supply` matching the row-5 binder shape (leading
        `kvE_ambientDeepAnchor qnf = true →`) exactly. Machine gate: scoped `lake build`;
        `lean_verify kampPrior_hreal_supply` at floor axioms, no sorryAx; guard-unfold source scan
        (zero); frozen-boundary git-diff audit.
- **Timing:** 5-8 hours (the heaviest remaining phase and the de-risking root; split at the
  5.1 exterior-zone / 5.2 interior-zone green-commit boundary if it exceeds one agent run; each
  sub-phase self-contained).
- **Depends on:** none new (Phases 1-4 complete).
- **Territory:** `KampPrior.lean` interior region (or a new interior leaf under `Kamp/` if it grows
  unwieldy). Read-only: all exterior leaf files, guard/probe modules, the Phase-3/Phase-4 leaves.

### Phase 6: Crux B — interior `hexcl` supply (contrapositive channel, the deep ⇒ direction) [NOT STARTED]
- **Goal:** Prove `kampPrior_hexcl_supply` matching the gate-match row-6 binder
  (`hexcl`, KampPrior.lean:971-977, leading `kvE_ambientDeepAnchor qnf = true →`): a within-`[x,t]`
  realizer of a bit-false fiber-consistent σ is impossible. **This is the deep ⇒ direction of the deep
  ambient render** (Phase-5 handoff goal 2): `(∃x1, nf_eval_nf … sub) → qnf.2 sub = true`. Together
  with Phase 5, `bracketEndChar_kv_step_sound … (hreal)(hexcl)` (ExteriorGateAssembleK.lean:337-338)
  PRODUCES the render.
- **Restated consumer binder discharged**: `hexcl` (KampPrior.lean:971) + row-6 mirror in
  `EndIntervalConsumerK.lean`. NO signature change to rows 5-6.
- **Byte-stable lemmas consumed**: the Phase-5 `hreal` machinery (shared interior seam); the Phase-8
  uniqueness/readback kernel is NOT yet available in this wave — Crux B's contrapositive is
  self-contained via the fold back-propagation `nf_eval_nfk_iff_efold` + `kvE_ambientDeepAnchor_iff`
  (deep-content pinning: fakes are guard-excluded); `kvE_ambientDeepAnchor_zero` (m=0).
- **Tasks:**
  - [ ] **G1-3**: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW agreement;
        the deep content of any second witness is pinned by `kvE_ambientDeepAnchor_iff` (guard-false
        fakes excluded). Reuse the Phase-5 interior seam for the ambient realization.
  - [ ] **Re-probe** the produced `hexcl` against CM-A/CM-B + depth-2 / copy-plant families. Certify
        green.
  - [ ] Deliver `kampPrior_hexcl_supply`. Machine gate: scoped `lake build`;
        `lean_verify kampPrior_hexcl_supply` at floor axioms, no sorryAx; guard-unfold scan (zero);
        frozen-boundary audit; prior certificate set green.
  - [ ] **Confirm the joint render**: `lean_multi_attempt` that `bracketEndChar_kv_step_sound` applied
        to the produced `hreal` + `hexcl` yields `∃w, nf_eval_nf M (k+2) 3 [w,x,t] qnf` at the pinned
        seam (this is a consumption check, NOT a new lemma). Record the render term shape for Phases 7-8.
- **Timing:** 3-5 hours.
- **Depends on:** 5 (shares the interior seam and `hreal` machinery; the joint render output needs both).
- **Territory:** same as Phase 5. Read-only: all exterior leaf files, guard/probe modules.

### Phase 7: Fill rows 12-13 general-`m` arms + retrofit consumer binders to carry the render hypothesis [NOT STARTED]
- **Goal:** Retire the two tracked strategic sorries in the Phase-4 leaf
  (`ExteriorDeepExclSupplyK.lean:105`, `:133`) by RE-SPECIFYING the supply lemmas to TAKE the render as
  a hypothesis (mirroring rows 8-9 at KampPrior.lean:990/997), then discharge the general-`m` arms of
  `kvE_hexclDeepFut_supply` (`:105`, row 13) and `kvE_hexclDeepPast_supply` (`:133`, row 12) via the
  `kvE_deepOnFiber_of_realized` contradiction. **This phase also performs the FLAGGED consumer-binder
  signature retrofit** (below).
- **FLAGGED SIGNATURE CHANGE (not free — called out per the finding):** rows 10-13 consumer binders —
  `hexclSlicePast` (KampPrior.lean:1003), `hexclSliceFut` (:1010), `hexclDeepPast` (:1017),
  `hexclDeepFut` (:1024) — currently LEAD with `kvE_ambientDeepAnchor qnf = true → … igPtW…eval_at M
  atomMap w →` and do NOT carry the render hypothesis, UNLIKE rows 8-9 (:990/997 carry
  `nf_eval_nf M (k+2) 3 [w,x,t] qnf →`). Per the Phase-5 handoff, `kvE_hexclDeepFut_supply`'s binder
  carries no `P`/`h_UZ`/`h_SZ`/`hInt` seam, so the render CANNOT be reconstructed inside the supply
  lemma — it MUST be threaded in as a hypothesis parameter. Therefore this phase changes the rows-10-13
  binder signatures (and their `kampPrior_site_rungK_gate_match` :941-1043, `EndIntervalConsumerK.lean`,
  and `ExteriorGateAssembleK.lean` mirrors) to carry `nf_eval_nf M (k+2) 3 [w,x,t] qnf →`, exactly
  mirroring rows 8-9. The arm rewrite (Phase 9) supplies that render via
  `bracketEndChar_kv_step_sound (hreal)(hexcl)` from the crux outputs. **This is a change to the frozen
  consumer region — do NOT assume it is free; execute it as one atomic cross-mirror edit and
  scoped-build the whole consumer stack before proceeding.** If the retrofit cascades into the row-5/6
  producers or breaks `bracketEndChar_kvExt_correct_prior`, STOP + [BLOCKED] + escalate.
- **Byte-stable lemmas consumed**: the threaded render hypothesis (ambient realized at `[w,x,t]`),
  `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 — needs BOTH the ambient realized
  AND the σ-realizer; forces `kvE_deepOnFiber qnf σ = true`, contradicting the binder's `= false`).
- **Tasks:**
  - [ ] **Retrofit the supply-lemma + consumer-binder signatures** (the flagged change): add the
        render hypothesis parameter `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` to `kvE_hexclDeepFut_supply` /
        `kvE_hexclDeepPast_supply` and to the rows-10-13 consumer binders (:1003/1010/1017/1024) + all
        mirrors, mirroring rows 8-9. Scoped-build the consumer stack; confirm rows 8-9 + m=0 legs stay
        byte-identical. **Green commit** (`task 358 phase 7.1: retrofit rows 10-13 render hypothesis`).
  - [ ] Fill `ExteriorDeepExclSupplyK.lean:105` (`kvE_hexclDeepFut_supply` `(j+1)` arm): from the
        threaded render hypothesis (ambient realized) + the hypothetical
        `_hσ : nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, apply `kvE_deepOnFiber_of_realized` to force
        `kvE_deepOnFiber qnf σ = true`, contradicting `_hguard : kvE_deepOnFiber qnf σ = false`. Edit
        ONLY the arm body (the m=0 leg + docstring stay byte-identical).
  - [ ] Fill `ExteriorDeepExclSupplyK.lean:133` (`kvE_hexclDeepPast_supply` `(j+1)` arm): Past mirror,
        same route.
  - [ ] Re-probe the filled supplies against the CM-A/CM-B / depth-2 / copy-plant families.
        **Green commit** (`task 358 phase 7.2: fill rows 12-13 general-m deep-exclusion arms`).
  - [ ] Machine gate: scoped `lake build` of `ExteriorDeepExclSupplyK.lean` + consumers;
        `lean_verify kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` at floor axioms, **no
        sorryAx** (the two `:105`/`:133` strategic sorries GONE); guard-unfold source scan (zero);
        frozen-boundary git-diff (m=0 legs + docstring + rows 8-9 byte-identical; the rows-10-13
        binder retrofit is the ONLY consumer-region change).
- **Timing:** 3-5 hours (the signature retrofit is the bulk; the two arm fills are mechanical once
  the render is threaded).
- **Depends on:** 5, 6 (the render, produced by `hreal`+`hexcl`).
- **Territory:** `ExteriorDeepExclSupplyK.lean` (the two `(j+1)` arm bodies + signatures) + the flagged
  rows-10-13 binder retrofit in `KampPrior.lean` / `EndIntervalConsumerK.lean` /
  `ExteriorGateAssembleK.lean`. Read-only: everything else.

### Phase 8: G2-2 uniqueness kernel + rows 10-11 slice supplies (render-as-hypothesis) [NOT STARTED]
- **Goal:** Rebuild the G2-2 uniqueness kernel (`kvE_futSliceUnique`/`kvE_pastSliceUnique` general-m)
  over the ambient-guarded + deep-anchored population, then supply rows 10-11
  (`kvE_hexclSliceFut_supply`/`kvE_hexclSlicePast_supply`) consuming it + the threaded render
  hypothesis (retrofitted in Phase 7).
- **Restated consumer binders discharged**: `hexclSliceFut` (KampPrior.lean:1010, rows 11),
  `hexclSlicePast` (:1003, rows 10) — retrofitted in Phase 7 to carry the render hypothesis. Target
  signatures verbatim from the Phase-4 handoff §"Target signatures" (rows 10-11 = rows 12-13 shape with
  `qnf.2 σ = false → kvE_{fut,past}SliceMarked qnf σ = true →` replacing the deep-anchor row pair),
  now additionally carrying `nf_eval_nf M (k+2) 3 [w,x,t] qnf →` per the Phase-7 retrofit.
- **Byte-stable lemmas consumed**: the threaded render hypothesis (both σ's realized over the SAME
  ambient tail), `kvE_ambientDeepAnchor_iff` (EF-closure for the second witness's deep content),
  `kvE_deepOnFiber_iff` (deep-content pinning `σ'.2 = σ.2` heredity), `kvE_futAdmissible_onFiber`
  (on-fiber row pinning) in place of the refuted free-env upgrade; m=0 via the frozen
  `kvE_hexclSliceFut_supply_zero` (ExteriorPinnedConverseK.lean:1250) + `kvE_futSliceUnique_zero`
  (:1122) (+Past :769/:356).
- **Tasks:**
  - [ ] **G2-B2 (uniqueness kernel)**: prove `kvE_futSliceUnique` / `kvE_pastSliceUnique` at general m
        over the ambient-guarded + deep-anchored population (both σ's pinned over the SAME rendered
        ambient tail — the threaded hypothesis). Use deep-content pinning + the
        `kvE_ambientDeepAnchor_iff` EF-closure + on-fiber row pinning. Probe against the countermodel
        families BEFORE consuming it. **Green commit.**
  - [ ] **G2-B3 (rows 10-11)**: prove `kvE_hexclSliceFut_supply` / `kvE_hexclSlicePast_supply`
        general-m matching the Phase-7-retrofitted `hexclSliceFut`/`hexclSlicePast` (:1010/:1003): the
        threaded render + the G2-B2 uniqueness + the admissibility-zone readback
        (`kvE_futAdmissible_fiber_dichotomy`). m=0 via the frozen `kvE_hexclSlice{Fut,Past}_supply_zero`.
        **Green commit.**
  - [ ] Machine gate: scoped `lake build` of the new leaf + consumers; `lean_verify` new theorems at
        floor axioms; guard-unfold source scan (zero); frozen-boundary git-diff audit; full prior
        certificate set re-verified green.
- **Timing:** 3-5 hours (two green-commit sub-steps: uniqueness ~2-3h; rows 10-11 ~1-2h).
- **Depends on:** 5, 6 (the render), 7 (the render-hypothesis retrofit rows 10-13 share).
- **Territory:** a new sibling leaf under `NfMultiAnchorBridge/` (+ append-only
  `ExteriorPinnedConverse{K,PastK}.lean`, m=0 regions frozen). Read-only: all guard/probe modules,
  the 368-changed files, the Phase-3/Phase-4/Phase-7 leaves.

### Phase 9: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body (KampPrior.lean:506-519) to discharge all 13
  ledger rows and replace the `:519` sorry (route R4). **This is the site that PRODUCES the render**
  via `bracketEndChar_kv_step_sound (hreal)(hexcl)` and THREADS it into the exterior consumers
  (rows 8-13).
- **Restated consumer site discharged**: `kampPrior_site_rungK_gate_match` (KampPrior.lean:941-1043,
  with the Phase-7 rows-10-13 render-hypothesis retrofit) — the arm must PRODUCE the render (feeding it
  to rows 8-13) and PRODUCE `kvE_ambientDeepAnchor qnf = true` where the row-5/6 binders demand it,
  from the realized ambient in scope at the recursion site.
- **Byte-stable lemmas supplying the seam**: `bracketEndChar_kv_step_sound`
  (ExteriorGateAssembleK.lean:337-338 — produce the render from `hreal`+`hexcl`);
  `kvE_ambientDeepAnchor_of_realized` (ExteriorAmbientDeepAnchorK.lean:195 — PRODUCE guard=true from the
  ambient realizer for the row-5/6 binders). NEVER unfold the guard.
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
        recursive calls). Rows 1-2 discharged.
  - [ ] **G3c-2**: produce the render via `bracketEndChar_kv_step_sound (hreal)(hexcl)` and thread it
        into rows 8-13. Discharge rows 5-6 via Phases 5-6 (+ `hfiberCons` via
        `kvE_fiberConsistent_of_realized`); rows 8-9 via Phase 3 (`kvE_hslice{Fut,Past}_supply`, already
        render-hypothesis-shaped); rows 10-11 via Phase 8 (G2-B3); rows 12-13 via Phase 7; rows 3-4
        ambient; row 7 internal (task 356). Supply `kvE_ambientDeepAnchor qnf = true` to the row-5/6
        guard-leading binders via `kvE_ambientDeepAnchor_of_realized`. Close via
        `kampPrior_case1_trichotomy_assemble` + `kampPrior_site_rungK_gate_match` (single-depth
        providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing notes (KampPrior.lean:486-518 residual comments)
        in the SAME edit to record the full resolution chain (363: fiber-consistency; 364:
        co-realization mate check; 367: fiber deep-anchor; 368: ambient deep-anchor; 358: crux
        `hsigma` production + render threaded as a hypothesis to the exterior consumers).
  - [ ] Machine gate: scoped `lake build` of `KampPrior`; confirm `:519` gone; `lean_verify
        nf_nvar_exist_all_depths` shows only the `| n+2 =>` arm still contributing `sorryAx`;
        guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 3-5 hours.
- **Depends on:** 5, 6, 7, 8.
- **Territory:** `KampPrior.lean` only.

### Phase 10: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
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
- **Depends on:** 9.
- **Territory:** `KampPrior.lean` only.

## Testing & Validation

- [ ] **NO render-adjudication gate (v09 change)**: the v08 render-adjudication gate is REMOVED — the
      finding is established (the render is the conclusion of the interior realization, produced by
      `bracketEndChar_kv_step_sound (hreal)(hexcl)`, not a separable root). Do NOT re-attempt a
      standalone render lemma. Phase 6 instead confirms the JOINT render output as a consumption check.
- [ ] **Re-probe gate (carried, already green at Phase 4)**: full certificate inventory
      (`kvE_probe368_*` x9, `kvE_probe367_*` x4, `kvE_probe364_*` x6, `kvE_probe363_*` x5,
      `kvE_probe358_*` x3, `kvE_probeM1_*` x2) `lean_verify` GREEN at floor axioms
      `[propext, Classical.choice, Quot.sound]`, no sorryAx, re-checked at every phase gate.
- [ ] **Per-phase machine gate (binding, every phase)**: scoped `lake build` + `lean_verify` of each
      new theorem at floor axioms + guard-unfold source scan (zero occurrences of
      `rw`/`unfold`/`simp only` on `kvE_ambientDeepAnchor`/`kvE_deepOnFiber`/`kvE_fiberElemConsistent`/
      `kvE_fiberConsistent`/`kvE_{fut,past}Admissible` in new proofs) + frozen-boundary `git diff`
      audit (m=0 `_zero` family, 360 supplies, k<=1 rungs, 363/364/367 declarations, the 368
      guard/probe/gate leaves, `ExteriorDeepSliceSupplyK.lean` rows 8-9, and
      `ExteriorDeepExclSupplyK.lean`'s m=0 legs + docstring — byte-identical; the ONLY sanctioned
      consumer-region change is the Phase-7 rows-10-13 render-hypothesis retrofit).
- [ ] **Consumer-binder retrofit audit (Phase 7)**: after the rows-10-13 signature retrofit, confirm
      rows 8-9 (:990/997) unchanged, the m=0 legs unchanged, and `bracketEndChar_kvExt_correct_prior`
      still builds; the retrofit is a mechanical replication of the rows-8-9 render-hypothesis shape.
- [ ] **Re-probe discipline per phase**: the countermodel-family certificates re-verified green after
      each phase's landings (the casts the new theorems must not readmit — esp. CM-A/CM-B).
- [ ] **Strategic-sorry retirement**: `ExteriorDeepExclSupplyK.lean:105`/`:133` GONE by end of
      Phase 7 (`lean_verify kvE_hexclDeepFut_supply`/`kvE_hexclDeepPast_supply` shows no sorryAx).
- [ ] **Zero live sorries at terminus**: currently exactly two main-target live (`:519`, `:522`) +
      two tracked strategic (`ExteriorDeepExclSupplyK.lean:105`/`:133`); terminus shows none.
- [ ] **Axiom transcript**: `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`, and
      `completeness_discrete` at floor axioms with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline post-368: green per 368's
      terminal audit, 1761 jobs).
- [ ] **Zero-debt scan**: no vacuous definitions (`def X := True` family) introduced anywhere.

## Artifacts & Outputs

- plans/13_crux-first-interior-realizer-v09.md (this file)
- summaries/13_crux-first-interior-realizer-v09-summary.md (on implementation completion)
- Crux A/B handoff (handoffs/, the produced `hreal`/`hexcl` signatures + the confirmed joint render term)
- Lean edits: `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` in `KampPrior.lean` (or interior leaf);
  the rows-10-13 render-hypothesis binder retrofit (`KampPrior.lean` / `EndIntervalConsumerK.lean` /
  `ExteriorGateAssembleK.lean`); the two filled general-`m` arms in `ExteriorDeepExclSupplyK.lean`; the
  G2-2 uniqueness kernel + rows 10-11 supplies (new sibling leaf); the two arm rewrites replacing
  `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step committed as it
  lands (`task 358 phase P.O: {objective}`); failures roll back to the last green milestone. Phase 5
  carries an explicit 5.1/5.2 green-commit split.
- **Crux A `hreal` production stalls** (a marked σ's zone case resists the engine after
  literature-fidelity escalation — re-read source -> alternative encodings -> unstated lemmas): commit
  all green sub-steps (esp. the 5.1 exterior-zone landing), record the exact failing σ shape and goal
  state, [BLOCKED] + escalate — never a sorry. This is the de-risking ROOT; do NOT descend into
  Phases 6-9 with `hreal` unproven.
- **Crux B `hexcl` production stalls**: same escalation; the contrapositive back-propagation route is
  the literature path.
- **Consumer-binder retrofit (Phase 7) cascades** (the render-hypothesis addition breaks the row-5/6
  producers or `bracketEndChar_kvExt_correct_prior`): STOP, record the exact break, [BLOCKED] +
  escalate — do NOT paper over a broken frozen boundary. Re-confirm rows 8-9 + m=0 legs byte-identical.
- **Re-probe gate fails** (any prior certificate no longer verifies at floor axioms): STOP —
  the ground truth has shifted; do NOT build. [BLOCKED] with the failing certificate named; escalate.
- **Phase-7/8 exterior fill stalls** (the render is threaded but the `kvE_deepOnFiber_of_realized`
  contradiction / uniqueness kernel still does not close, or a new countermodel survives the ambient
  guard): probe it (additive leaf, sorry-free), mark the phase [BLOCKED], `/spawn 358` an isolated
  kernel follow-up. Never force the supply against a live countermodel.
- **Phase-10 `:522` cannot close** under either route: [BLOCKED] + spawn an isolated arity-lift task;
  S1 (`:519`) stays landed and committed — itself a shippable milestone.
- **Regression detected** (any frozen declaration changed outside the flagged Phase-7 retrofit):
  snapshot per git-workflow.md, targeted `git checkout` of the offending file to the last green commit,
  re-run the scoped build, re-attempt within phase territory only.
