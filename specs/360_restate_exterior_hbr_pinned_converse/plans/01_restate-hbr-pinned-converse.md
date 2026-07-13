# Implementation Plan: Restate exterior hbr* obligations + land the pinned fiber-realization converse (m=0)

- **Task**: 360 - restate_exterior_hbr_pinned_converse
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours (7 phases, each one agent run)
- **Dependencies**: None (this task unblocks 358 Phase 3 and 349 v8 Phase 6)
- **Research Inputs**:
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/03_pinned-converse-adjudication.md (PRIMARY — sections 2.3-2.4, 3.3, 6, 7)
  - specs/360_restate_exterior_hbr_pinned_converse/reports/01_spawn-pointer.md
- **Artifacts**: plans/01_restate-hbr-pinned-converse.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; state-management.md; lean4.md (literature fidelity, vacuous-def prohibition)
- **Type**: lean4 (hard mode, --lit; ground truth = Rabinovich 2014, `~/Projects/Literature/sources/rabinovich_2014/` chunks 0013-0016, 0021-0023)

## Overview

The four exterior obligations `hbrPastReal`/`hbrPastSat`/`hbrFutReal`/`hbrFutSat` — threaded
verbatim through EndIntervalConsumerK.lean:129-154, ExteriorGateAssembleK.lean:142-167, and
KampPrior.lean:845-870, all copies of the `hreal`/`hsat` parameters of
`kvE_extNeg{Fut,Past}_complete` (ExteriorConverterK.lean:126-134 / ExteriorConverterPastK.lean)
— are **semantically false universals** (machine-refuted on `P2M=(ℤ,<), P={0,10,20}`;
ExteriorFiberProbeK.lean:61 + task-356 concession). The 354→356→357 outward threading dropped
the truth antecedents their interior siblings kept (`hreal`/`hexcl` carry the `igPtW` site
truth, EndIntervalConsumerK.lean:117-128; the `Sat` halves carry the `kvE_*End` endpoint truth,
:147-154; the exterior `Real` halves carry neither).

This task (a) restates the four obligations so they are **true-as-stated** — carrying the
endpoint-truth and level-up-ambient antecedents through the whole interface chain, keeping every
current consumer green — and (b) lands the **m=0 instance** of the NEW pinned fiber-realization
converse `kvE_{fut,past}Pinned_of_end` (Rabinovich Cor 5.4(1)⇐ one fiber level down + Cor 5.4(2)
re-anchoring; exact target signature in report 03 §2.4), re-deriving realization content from
the chain destructor's currently-DISCARDED pinned walk facts (`_hgap`/`_hocc`,
ExteriorConverterK.lean:159, returned by `kvE_futChainDestructG`, ExteriorNegationK.lean:300-303)
plus the ambient qnf realization, via the landed complete-type totality
(`nf_characteristic_satisfies` / `nf_eval_unique`,
Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:224/:245 — NOTE: this is the correct
path; the task description's `Syntax/NormalForm.lean` is a typo). The m=0 instance is all task
358's `:361` arm needs (report 03 §2.3 item 3, claim C8).

**Definition of done**: Phase-0 machine probes adjudicated (C3 at m=1, C8 at m=0); the four
obligations restated in guarded (true) form across all 5 consumer levels with `lake build`
green; `kvE_futPinned_of_end_zero` + `kvE_pastPinned_of_end_zero` proved sorry-free; m=0 supply
theorems discharging all four restated obligations proved sorry-free; zero sorries, zero vacuous
defs in every touched file; full `lake build` green. If the Phase-0 C8 probe fails, the terminus
is **[BLOCKED] + escalation handoff**, not construction.

### Research Integration

- Report 03 (pinned-converse adjudication): §2.4 target signature, §2.3 three-ingredient proof
  route, §3.1-3.3 restatement necessity + recommended shape, §6 C3/C8 probe mandates, §7
  postmortem. Integrated fully; this plan's phases are its §3.3 spawn mandate operationalized.

### Preserved Assets

The following work is complete at HEAD `be5086f6b` and must not regress. "Re-threaded" means the
statement's binder types change deliberately (that is the task), but the theorem must remain
sorry-free and its proof technique preserved; "read-only" means no edit permitted.

| Component | File | Status | Constraint |
|-----------|------|--------|-----------|
| `kvE_futChainDestructG` (pinned walk destructor) | ExteriorNegationK.lean:293-331 | [COMPLETED] green | read-only |
| Depth-k clause family (`kvE_futPos`/`End`/`GapD`/`ItemShift`/`extNegFut` + correctness :442-451) | ExteriorNegationK.lean:333-470 | [COMPLETED] green | read-only |
| Past mirrors of the above | ExteriorNegationPastK.lean | [COMPLETED] green | read-only |
| `kvE_extNegFut_complete` / `kvE_extNegPast_complete` | ExteriorConverterK.lean:119-190 / ExteriorConverterPastK.lean:94- | [COMPLETED] green | re-threaded (Phase 1) |
| `kvE_futBundle_of_realizer` / Past mirror | ExteriorConverterK.lean:208-225 / ExteriorConverterPastK.lean:174- | [COMPLETED] green | read-only (consumed by Phase 5) |
| D3/D4 composed per-side completeness | ExteriorBracketAssembleK.lean:154-247 | [COMPLETED] green | re-threaded (Phase 1) |
| `bracketEndChar_kvExt_correct_prior` (gate, `hexclExt` internal) | ExteriorGateAssembleK.lean:106-241 | [COMPLETED] green | re-threaded (Phase 1) |
| `EndIntervalCorrectPrior` + `endInterval_step_correct` | EndIntervalConsumerK.lean:95-194 | [COMPLETED] green | re-threaded (Phase 1) |
| KampPrior binder-mirror | KampPrior.lean:838-876 | [COMPLETED] green | re-threaded (Phase 1); NO arm logic edits (`:361`/`:364` arms belong to task 358) |
| Phase-2 realizer engine `kampPrior_fChain_realize{,_cons,_from,_bracket}` | KampPrior.lean:1149ff | [COMPLETED] green (task 358 P2) | read-only |
| `nf_characteristic` / `_satisfies` / `nf_eval_unique` | Metalogic/WeakCanonical/NormalForm.lean:215/224/245 | [COMPLETED] green | read-only (small NEW helper lemmas may be appended if needed; existing declarations untouched) |
| Existing free-env countermodel probe | ExteriorFiberProbeK.lean | [COMPLETED] green | read-only |
| `HasAttainedINF.first_occ` | EANegationClosure.lean:54-66 | [COMPLETED] green | read-only |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the report-03 §7 divergence audit
(354→356→357→358 threading failure, 349's 8 plan versions) and machine-refuted claims.

**Do NOT**:
- Attempt to derive pinned realization from free-env `P.existF 4` content alone. Machine-refuted
  (compiled `lean_run_code` probe + P2M countermodel, ExteriorFiberProbeK.lean:61). SETTLED — do
  not re-litigate.
- Thread an obligation outward without the truth antecedents under which it is consumed. This is
  the root cause of the current falsity (report 03 §7 postmortem). Every restated binder must
  name its consumption-site antecedents explicitly.
- Treat "consumer compiles green" as evidence a binder is TRUE. Hypotheses are free; falsity
  surfaces only at the supply site. Truth claims about binder shapes require the Phase-0 probe
  discipline (machine countermodel attempt) or a proof.
- Attempt the general-m (m ≥ 1) pinned converse in this task. Report 03 §2.3 item 3: endpoint
  identification at m ≥ 1 requires the recursion's own `charF`/provider level-descent — new
  structured work, explicitly OUT OF SCOPE (see Non-Goals). Do not let any phase silently expand
  into it.
- Attempt an "in-scope KampPrior-only reformulation" that instantiates the current (false)
  binders from a true supply. Structurally impossible (report 03 §3.1). SETTLED.
- Edit KampPrior.lean arm logic (`| 1 =>` at :361, `| n+2 =>` at :364) or the Phase-2 realizer
  engine (:1149ff). Only the binder-mirror lines :845-876 are in scope in that file.
- Discard the destructor's pinned facts. Any re-proof of `_complete` must bind `hgap`/`hocc`
  (currently `_hgap`/`_hocc` at ExteriorConverterK.lean:159) and consume them or pass them on.
- Insert `sorry`, vacuous defs (`def X := True`, `theorem X := trivial`, etc.), or axioms.
  Zero-debt contract: an un-closable sub-piece → phase [BLOCKED] + escalation handoff, never debt.
- Bypass Rabinovich's explicit steps with `simp`/`omega`/`aesop` shortcuts where the plan cites a
  literature step (lean4.md literature-fidelity policy). The proof route is Cor 5.4(1)⇐'s
  milestone reconstruction, not tactic search.
- Re-derive or restate anything in this plan from memory of prior tasks; when in doubt, re-read
  report 03 and the Rabinovich chunks (`literature-search.sh "Cor 5.4"` or Read
  `~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md`).

**MUST preserve**:
- Every row of the Preserved Assets table above; all currently green consumers of the touched
  files (verify via scoped `lake build` at every phase exit).
- Task 358's green Phase 1-2 work (HEAD lineage `83fd80e78`, `6453bee06`).

**Design decisions are SETTLED** (do not re-open without a concrete machine counterexample):
1. **Restated binder shape = report 03 §2.4 antecedent set**: chain-fire truth (`kvE_*Pos` at the
   anchor) and/or destructor-endpoint truth (`kvE_*End` at `x1`), the destructor facts
   `hgap`/`hocc`, AND the level-up ambient `nf_eval_nf M (m+2) 3 [w,x,t] qnf`. The ambient is
   included by default; the Phase-0 C3 probe can only CONFIRM its necessity (countermodel found
   at m=1 for the ambient-free guarded form), never remove it — removal would require a proof of
   the ambient-free form, which claim C3 adversarially refutes at m ≥ 1.
2. **General-m elimination is NOT attempted**: at general m the four obligations remain
   hypothesis binders (restated, guarded, true-as-stated); the m=0 supply theorems (Phase 5)
   provide the actual discharge task 358 needs. Rationale: report 03 §2.3 item 3 (level-descent
   is separate structured work) + H8 bounded-unit test (a general-m converse phase has no fixed
   attempt surface).
3. **New lemmas live in NEW files** `ExteriorPinnedConverseK.lean` (Future) and
   `ExteriorPinnedConversePastK.lean` (Past) under NfMultiAnchorBridge/, importing
   ExteriorNegation{,Past}K + ExteriorConverter{,Past}K + WeakCanonical/NormalForm. Keeps
   territory disjoint from the Phase-1 restatement chain (enables Wave-2 parallelism) and keeps
   preserved files read-only.
4. **The interface stays obligation-carrying** (same architectural style as the interior
   siblings); the fix is antecedent repair + m=0 discharge, not an interface redesign.

**Territory note**: stale locks from tasks 351/354 exist on NfMultiAnchorBridge/ but are >30 min
stale — proceed; record the override in the phase-exit handoff. This task owns:
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/{ExteriorNegationK,
ExteriorNegationPastK, ExteriorConverterK, ExteriorConverterPastK, ExteriorBracketAssembleK,
ExteriorGateAssembleK, EndIntervalConsumerK, ExteriorPinnedConverseK (new),
ExteriorPinnedConversePastK (new), ExteriorPinnedProbeK (new, Phase 0)}.lean` +
`KampPrior.lean:838-876` (binder-mirror only) + append-only access to
`Metalogic/WeakCanonical/NormalForm.lean`.

## Source-to-Implementation Mapping (H3, Tier 1)

Load-bearing rows only; full table in report 03 §1.

| Rabinovich 2014 source | Chunk:lines | Lean target | Status |
|---|---|---|---|
| Cor 5.4(1)⇐ (milestone reconstruction: `F0(z0)` + `Fi(xi)` pinned in `(z0,z1)`) | chunk_0015:11-37 | `kvE_futPinned_of_end_zero` proof spine (Phases 2-3) | NEW |
| Cor 5.4(2) mirror re-anchoring | chunk_0015:43, chunk_0016:17 | fresh-slot shift already landed (`kvE_futItemShift_correct`, ExteriorNegationK.lean:442-451); Past mirror phase 4 | LANDED / NEW |
| Def 7.7 canonical-expansion complete type (truth at a point = complete pinned datum) | chunk_0022:5 | `nf_characteristic` + `_satisfies` + `nf_eval_unique` (NormalForm.lean:215/224/245) | LANDED |
| `O_n` chain semantics → endpoint + per-item pinned occurrence | chunk_0015:39-41 | `kvE_futChainDestructG` `hend`/`hgap`/`hocc` (ExteriorNegationK.lean:300-303) | LANDED (currently discarded at use site) |
| The pinned fiber-realization converse (composite, one fiber level down) | §2.4 of report 03 | `kvE_futPinned_of_end_zero` / `kvE_pastPinned_of_end_zero` | NEW (Phases 2-4) |

## Goals & Non-Goals

- **Goals**:
  - G1. Phase-0 machine adjudication of claims C3 (m=1 countermodel vs the ambient-free guarded
    binder) and C8 (m=0 positive route) — the GO/NO-GO gate.
  - G2. The four exterior obligations restated true-as-stated (guarded per settled decision 1)
    across ExteriorConverter{,Past}K → ExteriorBracketAssembleK → ExteriorGateAssembleK →
    EndIntervalConsumerK → KampPrior.lean:845-870, all consumers green, `hgap`/`hocc` no longer
    discarded.
  - G3. `kvE_futPinned_of_end_zero` + `kvE_pastPinned_of_end_zero` (the report-03 §2.4 signature
    at m := 0) proved sorry-free.
  - G4. m=0 supply theorems: all four restated obligations derivable at the m=0 rung from the
    ambient — exactly what 358's `:361` arm and 349 v8 Phase 6 consume.
  - G5. Zero-debt terminus: no sorries, no vacuous defs, full `lake build` green.
- **Non-Goals**:
  - The general-m (m ≥ 1) pinned converse / level-descent (settled decision 2; future task).
  - KampPrior `:361`/`:364` arm discharge or the carrier→formula fold (task 358 revised Phase 3).
  - `endInterval_correct` / endpoint primitive work (task 349 Phases 5-7).
  - Any edit to the depth-k clause family definitions (`kvE_futPos`/`End`/etc. are read-only;
    only their CONSUMERS' hypothesis types change).

## Risks & Mitigations

- **Risk**: C8 probe fails (m=0 route machine-refuted or no positive artifact within budget).
  Confidence is Medium (report 03 §6). **Mitigation**: Phase 0 is a hard gate; terminus becomes
  [BLOCKED] + escalation handoff naming the refuting configuration; no construction phase runs.
- **Risk**: Phase 3 (fiber-fold identification) silently expands into general-m reasoning.
  **Mitigation**: explicit m=0 signatures only (`σ : NormalForm sig 1 4`, fibers
  `NormalForm sig 0 5`); stopping condition + split trigger (3.1/3.2) declared in the phase;
  postmortem rule forbids scope expansion.
- **Risk**: Phase-1 re-threading breaks a consumer not on the map. **Mitigation**: `grep -rn`
  for every restated name before edit; scoped builds of all 7 chain files + full `lake build` at
  phase exit; preserved-assets table checked.
- **Risk**: Ambient antecedent cannot be threaded at the converter level (no `qnf` in scope
  there today). **Mitigation**: settled shape allows adding `qnf`/ambient parameters to
  `kvE_extNeg*_complete` (that IS the report's preferred "re-prove `_complete` from ambient"
  form); intermediate D3/D4 levels already quantify `qnf`.
- **Risk**: heartbeat blowups in EndIntervalConsumerK (already at `maxHeartbeats 1600000`).
  **Mitigation**: keep re-threading purely type-level (pass-through of new antecedent
  arguments); raise heartbeats only as last resort and record it.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2 | 0 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 1, 3, 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel (Phase 1 edits the existing chain files;
Phase 2 creates a new file — disjoint territory per H7).

### Phase 0: Mandatory machine-probe gate (C3 at m=1, C8 at m=0) [COMPLETED]

**PHASE-0 RECORD (2026-07-13, sess_1783950096_9d2925)**

- **C8 verdict: GO.** Compiled positive artifacts (all sorry-free, axioms ⊆ [propext,
  Classical.choice, Quot.sound], persisted in ExteriorPinnedProbeK.lean; scoped build green):
  - (a) `kvE_probe_selfZone_coincide` — self-zone coupling `(false,false)` forces fresh/`x1`
    coincidence on ANY linear order (abstract, stronger than the concrete mandate).
  - (b) `kvE_probe_endpoint_totality` — τ := `nf_characteristic P3M 1 4 [25,15,2,18]` is
    pinned-realized AND marked by the honest ambient `nf_characteristic P3M 2 3 [15,2,18]`.
  - (c) `kvE_probe_gapItem_pinned` / `kvE_probe_rayItem_pinned` — the depth-0 free-env→pinned
    upgrade: on-fiber (`nf0_dropFresh s = σ.1`) + zone spec + walk-interval placement upgrade a
    free-env occurrence to PINNED realization via `nf_eval_nf0_cons_factor` (three channels:
    zone re-rendered by `kvE_futZone4_of_above`, fresh profile verbatim, env-restriction from
    the pinned atom layer). This is the exact "identification closes with landed machinery at
    m=0" mechanism of report 03 §2.3 item 3.
  - (c′) `kvE_probe_marking_separated` — separation contrast: σ′ := τ with the P-gap element
    `e* = char [20,25,15,2,18]` unmarked FAILS `kvE_futGapD P σ′` at walk point 20 under the
    concrete depth-0 provider — at m=0 the hypothesis set provably separates marking variants.
- **C3 verdict: B (unconfirmed at binder level; core compiled; informative only).**
  `kvE_probe_c3_pair` compiles the marking-ambiguity core at the m=1 fiber type
  (`NormalForm sig 1 5`): s ≠ s′ differing only in a depth-0 marking, all atom-layer channels
  agreeing (`s.1 = s′.1`, shared `nfk_zoneSpec`/fresh profile), pinned realization separating
  them. The full binder-level countermodel was NOT assembled within budget: stating `kvE_futEnd
  P σ` at m=1 requires a concrete depth-1 `ExistProviders` instance and none exists in-tree
  (task 358's open recursion). Ambient stays included per settled decision 1 regardless.
- **Finalized restated-binder antecedent set (for Phase 1)**: per settled decision 1, unchanged
  by the probes — endpoint truth `temporal_truth M atomMap x1 (kvE_*End P σ)` for the Real
  halves (Sat halves already carry it); the level-up ambient
  `nf_eval_nf M (m+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` for all four; chain-fire
  `hpos` where the consumption site provides it; destructor facts `hgap`/`hocc` bound and
  threaded (no longer `_`-discarded).
- **Territory note**: stale 351/354 locks on NfMultiAnchorBridge/ overridden (>30 min stale)
  per plan; Phase 0 touched only the new probe file.

- **Goal:** Machine-adjudicate the two Medium-confidence claims from report 03 §6 BEFORE any
  construction. This phase is the GO/NO-GO gate: no later phase may start until C8 is confirmed.
- **Bounded unit:** one probe file + two recorded verdicts. Fixed attempt surface: at most 12
  `lean_run_code`/`lean_multi_attempt` attempts per probe; on exhaustion the fallback verdicts
  below apply — the phase cannot run open-ended.
- **Tasks:**
  - [x] Re-read report 03 §2.3-2.4 and §6 rows C3/C8; Read
        `ExteriorFiberProbeK.lean:57-153` for the established P2M probe conventions
        (`P2M=(ℤ,<)`, `P={0,10,20}`-style monadic structure).
  - [x] **C3 probe (informative, does NOT gate)**: via `lean_run_code`, attempt the report-03
        §6-C3 countermodel at fiber depth m=1 against the guarded-WITHOUT-ambient binder (i.e.
        `hbrFutReal` + site truth + `kvE_futEnd` endpoint truth, no ambient): two admissible
        on-fiber σ ≠ σ′ sharing `(w,x,t)`-slot atoms and endpoint atomic profile (self-zone
        coincidence), differing only in depth-1 fiber marking. Verdict A (countermodel
        compiles): ambient necessity CONFIRMED — record. Verdict B (budget exhausted):
        record "unconfirmed"; ambient stays included regardless (settled decision 1).
        *(deviation: altered — the full binder-level m=1 countermodel requires a concrete
        depth-1 ExistProviders instance to state `kvE_futEnd` semantically and none exists
        in-tree; compiled the marking-ambiguity CORE `kvE_probe_c3_pair` instead and recorded
        Verdict B, directly in the persisted probe file rather than scratch `lean_run_code`)*
  - [x] **C8 probe (GATES the plan)**: positive m=0 route. Via `lean_run_code`, verify on the
        concrete probe model the three identification ingredients at m=0 (σ : NormalForm sig 1 4,
        fibers NormalForm sig 0 5): (a) self-zone coupling `(false,false)`
        (`kvE_futSelfZone`, semantics `kvE_futZone4_of_above` ExteriorNegationK.lean:457-469)
        forces fresh/`x1` coincidence on a linear order; (b) endpoint characteristic
        `τ := nf_characteristic M 1 4 [x1,w,x,t]` is pinned-realized
        (`nf_characteristic_satisfies`) and marked by the ambient (`(h.2 τ).mp`); (c) for
        admissible σ passing `hend`+`hgap`+`hocc`, the depth-0 identification σ = τ holds on the
        probe instance. GO requires a compiled positive artifact for (a)-(c) (concrete-instance
        check OR a sorry-free abstract prototype of the chain in scratch).
        *(deviation: altered — (c) verified via its two load-bearing mechanisms as compiled
        theorems: the gap/ray free-env→pinned upgrade lemmas + the marking-variant separation
        contrast at the walk point, i.e. concrete-instance checks of the identification chain's
        per-item steps rather than a full quantified σ = τ on the instance; artifacts written
        directly to the persisted probe file, not scratch)*
  - [x] Persist whichever probes compiled into a NEW file
        `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbeK.lean`
        (precedent: ExteriorFiberProbeK.lean) so the evidence is regression-checked.
  - [x] Record both verdicts + the finalized restated-binder antecedent set in
        `.orchestrator-handoff.json` (`continuation_context`) and in this plan file under this
        phase's heading.
  - [x] **NO-GO branch**: if C8 is refuted or no positive artifact exists at budget exhaustion,
        set this plan's Status to [BLOCKED], write the escalation handoff (refuting
        configuration or last failing goal state, verbatim), update task status to blocked, and
        STOP. Phases 1-6 do not run.
- **Done when:** probe file builds green (`lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedProbeK`), both verdicts recorded, GO/NO-GO decided.
- **Estimated output:** ~150-300 lines (probe file + records).
- **Timing:** 2-3 hours.
- **Depends on:** none
- **File scope:** ExteriorPinnedProbeK.lean (new); plan file + handoff JSON (records). No
  production-file edits.

### Phase 1: Restate the four exterior obligations through the 5-level interface chain [COMPLETED]

**PHASE-1 RECORD (2026-07-13, sess_1783950096_9d2925)**: All four obligations restated in the
report-03 §2.4 guarded form at every level. Antecedent order (uniform, all levels):
`∀ x1, {t < x1 | x1 < x} → hpos (chain-fire at anchor) → hend (kvE_*End at x1) → hgap → hocc
(l-free, over kvE_fiberZoneList σ kvE_*GapZone) → ∀ s, …`; the level-up ambient
`nf_eval_nf M (k+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →` inserted after `w < t →` at
the three ∀-w levels (ExteriorGateAssembleK, EndIntervalConsumerK, KampPrior mirror); converter
binders carry hpos/hend/hgap/hocc only (w is a theorem parameter there — the ambient is consumed
at gate instantiation `hbr* w hxw hwt h`). Destructor facts bound (`hgap`/`hocc`, no `_`), with
`hoccZ` l-free conversion via `hlperm.mem_iff`; converters save `hpos0` before the `rw` consumes
`hpos`. Past-side item formula stated raw as `P.existF 4 (renameNF rot5Fwd rot5Bwd a)` (no
`kvE_pastItemShift` def exists; clause family is read-only). D3/D4 and `endInterval_step_correct`
proof bodies unchanged (verbatim shape pass-through). Full `lake build` green (1734 jobs); axiom
audit via `lake env lean` `#print axioms` on all 7 restated theorems: exactly
`[propext, Classical.choice, Quot.sound]`. Zero sorries introduced (KampPrior `:361`/`:364` arm
sorries pre-existing, task-358 territory, untouched).

- **Goal:** Make `hbrPastReal`/`hbrPastSat`/`hbrFutReal`/`hbrFutSat` true-as-stated by carrying
  the settled antecedent set (endpoint `kvE_*End` truth for the Real halves — the Sat halves
  already carry it; the level-up ambient `nf_eval_nf M (m+2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`
  for all four; chain-fire/site antecedents where the Phase-0 record requires) through every
  level, and stop discarding the destructor facts.
- **Bounded unit:** one coherent type-level re-threading, verified by green builds of all seven
  chain files. No new mathematics; every consumption point already has the antecedents in scope
  (report 03 C6: `hpos` intro'd at ExteriorConverterK.lean:140, `hend` at :159-163, `hreal` used
  at :171/:182 with both available).
- **Tasks:**
  - [x] `ExteriorConverterK.lean` — restate `kvE_extNegFut_complete` (:119): add the antecedents
        to `hreal` (endpoint-truth guard `temporal_truth M atomMap x1 (kvE_futEnd P σ) →` at
        minimum; ambient + `qnf`/`hfib`/unmarked parameters if the Phase-0 record settled the
        ambient at converter level); change `obtain ⟨x1, htx1, hend, _hgap, _hocc⟩` (:159) to
        bind `hgap`/`hocc` and thread them to the (restated) hypothesis applications. Proof body
        adjustments are argument-passing only.
  - [x] `ExteriorConverterPastK.lean` — mirror restatement of `kvE_extNegPast_complete` (:94).
  - [x] `ExteriorBracketAssembleK.lean` — re-thread D3/D4 (`hreal`/`hsat` at :181-185/:223-227
        gain the same antecedents; applications at :205/:247 pass them through; `qnf` already in
        scope).
  - [x] `ExteriorGateAssembleK.lean` — restate the four `hbr*` binders (:142-167) to the guarded
        form; applications at :215-239 pass the new antecedent arguments.
  - [x] `EndIntervalConsumerK.lean` — restate the four `_hbr*` binders inside
        `EndIntervalCorrectPrior` (:129-154) identically ("binder types copied verbatim from
        ExteriorGateAssembleK" discipline, per the file's own doc comment); `endInterval_step_correct`
        (:187-193) re-threads by intro/pass-through.
  - [x] `KampPrior.lean:838-876` — mirror the restated binders (:845-870) and pass-through
        (:875). NO other KampPrior lines.
  - [x] `grep -rn "hbrFutReal\|hbrFutSat\|hbrPastReal\|hbrPastSat"` across the repo to confirm no
        unlisted consumer; fix any found by the same pass-through pattern.
  - [x] Scoped builds of all six edited files, then full `lake build`.
- **Done when:** all six files + every downstream consumer build green; the four obligations at
  every level carry the settled antecedents; `hgap`/`hocc` bound (not `_`-discarded); zero
  sorries introduced.
- **Estimated output:** ~250-400 diff lines across 6 files.
- **Timing:** 3-4 hours.
- **Depends on:** 0
- **File scope:** ExteriorConverterK, ExteriorConverterPastK, ExteriorBracketAssembleK,
  ExteriorGateAssembleK, EndIntervalConsumerK, KampPrior.lean:838-876.

### Phase 2: Future pinned converse at m=0 — endpoint atom-layer pinning [NOT STARTED]

- **Goal:** In NEW file `ExteriorPinnedConverseK.lean`, prove the atom-layer half of
  `kvE_futPinned_of_end_zero`: under the §2.4 hypotheses at m := 0, the endpoint's complete
  atomic profile is pinned — `σ.1 = nf_characteristic M 0 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))).1`-equivalent
  (i.e. `nf_eval_nf M 0 4 [x1,w,x,t] σ.1`).
- **Bounded unit:** one lemma (`kvE_futAtomPinned_zero`) plus at most 3 named helpers; each
  helper is a single verifiable fact.
- **Tasks:**
  - [ ] Create `ExteriorPinnedConverseK.lean` with imports (ExteriorNegationK, ExteriorConverterK,
        WeakCanonical/NormalForm) and the report-03 §2.4 signature transcribed at m := 0 as the
        file-head docstring (source: report 03 §2.4, quote verbatim).
  - [ ] Helper: self-zone coincidence — a fresh witness `v` of the self-zone content at `x1`
        satisfies `v = x1` (from coupling `(false,false)` via `kvE_futZone4_of_above` semantics +
        linear order trichotomy).
  - [ ] Helper: outer-slot pinning from the ambient — σ on qnf's fiber (`nf1_dropFresh σ = qnf.1`)
        + ambient `h` pins σ.1's non-`x1`-slot atoms to the actual `[w,x,t]` profile.
  - [ ] Helper: `x1`-slot pinning from `hend` — the self-zone element's fresh-slot atoms are
        pinned to `x1`'s actual profile (coincidence), and admissibility's self-zone fresh/`x1`
        slot agreement (`kvE_futAdmissible` conjunct-4 uniqueness discipline, ExteriorNegationK.lean:391-400
        doc) transfers it to σ.1's `x1`-slot atoms. Reuse the factoring pattern of
        `kvE_futAtom_of_bundle` (ExteriorConverterK.lean:100-105, `nf_eval_nf0_cons_factor`).
  - [ ] Assemble `kvE_futAtomPinned_zero`; `lean_verify` sorry/axiom check; scoped build.
- **Done when:** `kvE_futAtomPinned_zero` compiles sorry-free; scoped `lake build` of the new
  file green; nothing else touched.
- **Stopping condition (bounded-unit):** if the admissibility conjunct does NOT provide the
  fresh/`x1`-slot agreement needed (goal-state evidence required), mark phase [BLOCKED] with the
  exact missing fact as a candidate strengthening — do not weaken the lemma or widen scope.
- **Estimated output:** ~150-250 lines (new file).
- **Timing:** 2-4 hours.
- **Depends on:** 0 (parallel with Phase 1; disjoint files)
- **File scope:** ExteriorPinnedConverseK.lean (new) only.

### Phase 3: Future pinned converse at m=0 — fiber-fold identification and `kvE_futPinned_of_end_zero` [NOT STARTED]

- **Goal:** Complete the Future converse at m=0: prove σ's fiber fold matches the endpoint
  characteristic (`∀ sub : NormalForm sig 0 5` on σ's fiber,
  `(∃ v, nf_eval_nf M 0 5 [v,x1,w,x,t] sub) ↔ σ.2 sub = true`), conclude via
  `nf_eval_nfk_iff_efold`/`nf_eval_unique` the full pinned realization
  `nf_eval_nf M 1 4 [x1,w,x,t] σ` — the theorem `kvE_futPinned_of_end_zero`.
- **Bounded unit:** one theorem via a per-zone case analysis with a FIXED case list (the zone
  specs partition every `v` by its order relations to `(x1,w,x,t)`); each case cites a named
  supplier. This is the task's difficulty atom; the case list below is the fixed attempt surface.
- **Tasks:**
  - [ ] Forward direction (realized at pinned coords → marked), by the fresh witness `v`'s zone:
    - [ ] gap zone `(t,x1)`: `hgap` gives the gap disjunction at `v`; membership of the realized
          `sub` in `kvE_fiberZoneList σ kvE_futGapZone` via depth-0 atom uniqueness
          (`nf_eval_unique` at k=0) against the listed element realized at `v` → marked.
    - [ ] ray zone `(x1,∞)`: `hend`'s `kvE_futRayForm` exact-ray-content conjunct (every future
          point carries a ray element; each ray element occurs) — same uniqueness argument.
    - [ ] self zone `v = x1`: Phase-2 coincidence + `hend` self-zone content.
    - [ ] interior/below-`t` zones: the ambient `h` + σ-on-fiber (`nf1_dropFresh σ = qnf.1`) —
          qnf's own fold at `[w,x,t]` renders these zones' population.
  - [ ] Backward direction (marked → realized at pinned coords), by the marked element's zone:
        `hocc` for gap items (pinned occurrence in `(t,x1)` — the walked milestones,
        Cor 5.4(1)⇐'s core step), `hend` ray conjuncts for ray items, self via coincidence,
        interior via ambient. Depth-0 elements are pure atom assignments, so a free-env
        occurrence + Phase-2 pinned atom layer upgrades to pinned realization
        (`nf_eval_nf0_cons_factor` pattern).
  - [ ] Off-fiber falsity via `kvE_futAdmissible_offFiber` (as in ExteriorConverterK.lean:187).
  - [ ] Assemble `kvE_futPinned_of_end_zero` with the report-03 §2.4 signature at m := 0
        (hypotheses: `hadm`, `hfib`, order facts, ambient `h`, `htx1`, `hpos`, `hend`, `hgap`,
        `hocc`; conclusion `nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`).
  - [ ] `lean_verify` (sorry/axiom check) + scoped build.
- **Done when:** `kvE_futPinned_of_end_zero` compiles sorry-free; scoped build green.
- **Stopping condition / split trigger:** if after the forward direction the phase already
  exceeds ~350 lines or the dispatch is at 70% budget, commit the forward half green as
  sub-phase 3.1 (`task 360 phase 3.1` commit) and finish the backward direction + assembly as
  3.2 in the next dispatch. If any single zone case has no supplier among
  {hgap, hocc, hend, ambient, Phase-2 lemma}, mark [BLOCKED] with the exact goal state — that is
  a C8-adjudication defect, escalate; do not invent new interface hypotheses.
- **Estimated output:** ~200-350 lines.
- **Timing:** 3-4 hours (up to 2 dispatches via 3.1/3.2).
- **Depends on:** 2
- **File scope:** ExteriorPinnedConverseK.lean only (append small helpers to
  Metalogic/WeakCanonical/NormalForm.lean ONLY if a generic depth-0 uniqueness/factoring fact is
  missing there; existing declarations untouched).

### Phase 4: Past mirror — `kvE_pastPinned_of_end_zero` [NOT STARTED]

- **Goal:** Port Phases 2-3 to the Past side in NEW file `ExteriorPinnedConversePastK.lean`:
  `kvE_pastAtomPinned_zero` + `kvE_pastPinned_of_end_zero` (endpoint `x1 < x`, `kvE_pastEnd`,
  `kvE_pastAdmissible`, Past zone specs), mirroring lemma-for-lemma.
- **Bounded unit:** a mechanical mirror of a now-landed technique; the Future file is the
  template (same lemma names with `past`, same case list).
- **Tasks:**
  - [ ] Create `ExteriorPinnedConversePastK.lean` (imports: ExteriorNegationPastK,
        ExteriorConverterPastK, WeakCanonical/NormalForm, and the Future file if shared helpers
        emerged — prefer hoisting side-agnostic helpers to the Future file and importing).
  - [ ] Port the atom-layer lemma; port the fiber-fold theorem; assemble
        `kvE_pastPinned_of_end_zero`.
  - [ ] `lean_verify` + scoped build.
- **Done when:** `kvE_pastPinned_of_end_zero` compiles sorry-free; scoped build green.
- **Estimated output:** ~250-400 lines (new file).
- **Timing:** 2-3 hours.
- **Depends on:** 3
- **File scope:** ExteriorPinnedConversePastK.lean (new); read-only elsewhere.

### Phase 5: m=0 supply theorems — discharge the restated obligations at the `:361` rung [NOT STARTED]

- **Goal:** Prove, in ExteriorPinnedConverseK.lean / -PastK.lean, the four supply theorems
  showing the RESTATED (Phase-1) obligations hold at m = 0: from the ambient + the guarded
  antecedents, each restated `hbr*` binder instance is derivable. Route per report 03 §2.4
  consequences: for unmarked σ the converse's conclusion + `(h.2 σ).mp` is the contradiction
  (vacuous discharge); for the content halves, `kvE_futBundle_of_realizer`
  (ExteriorConverterK.lean:208) / Past mirror converts the converse's conclusion into exactly
  the Real/Sat conjuncts at the selected `x1`.
- **Bounded unit:** four theorems (`kvE_hbrFutReal_supply_zero`, `kvE_hbrFutSat_supply_zero`,
  `kvE_hbrPastReal_supply_zero`, `kvE_hbrPastSat_supply_zero`) whose statements are the Phase-1
  binder types instantiated at m := 0, quantified over the ambient — signature-locked, no design
  freedom.
- **Tasks:**
  - [ ] Transcribe the Phase-1 restated binder types at m := 0 as theorem statements (copy the
        binder text verbatim from EndIntervalConsumerK.lean; this is the interface 358 consumes).
  - [ ] Prove the two Future supplies via `kvE_futPinned_of_end_zero` +
        `kvE_futBundle_of_realizer`; the two Past supplies via the mirrors.
  - [ ] Add a short module docstring cross-referencing task 358 `:361` and task 349 v8 Phase 6 as
        the intended consumers.
  - [ ] `lean_verify` all four; scoped builds.
- **Done when:** four supply theorems compile sorry-free with statements verbatim-matching the
  restated interface at m=0; scoped builds green.
- **Estimated output:** ~120-200 lines.
- **Timing:** 2 hours.
- **Depends on:** 1, 3, 4
- **File scope:** ExteriorPinnedConverseK.lean, ExteriorPinnedConversePastK.lean.

### Phase 6: Zero-debt gate, full build, wrap-up [NOT STARTED]

- **Goal:** Terminal verification and handoff.
- **Tasks:**
  - [ ] Full `lake build` (whole project) green.
  - [ ] `grep -rn "sorry" ` over all touched files → zero hits;
        `grep -rn ":= True\|:= trivial"` over new files → zero vacuous defs;
        `lean_verify` on `kvE_futPinned_of_end_zero`, `kvE_pastPinned_of_end_zero`, all four
        supply theorems, and `endInterval_step_correct` (axioms ⊆ [propext, Classical.choice,
        Quot.sound]).
  - [ ] Confirm preserved assets: `kampPrior_fChain_realize*`, `kvE_futChainDestructG`,
        `kvE_futBundle_of_realizer` unchanged (`git diff --stat` scoped review).
  - [ ] Update `.orchestrator-handoff.json` (phases_completed, next_action_hint, note for 358
        Phase 3 + 349 v8 Phase 6: consume the restated interface + supply theorems).
  - [ ] Write `summaries/01_restate-hbr-pinned-converse-summary.md` including the sorry
        inventory (empty), the Phase-0 verdicts, and the deviation flags if any.
- **Done when:** full build green, zero-debt checks pass, handoff + summary written.
- **Estimated output:** ~40-80 lines (summary/handoff).
- **Timing:** 1 hour.
- **Depends on:** 5
- **File scope:** handoff JSON, summary, plan-file status markers only.

## Testing & Validation

- [ ] Phase-exit gate at EVERY phase: scoped `lake build <touched modules>` green (module paths
      `Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.<File>`); full
      `lake build` at Phases 1 and 6.
- [ ] Phase 0 probes are the semantic tests: C3 countermodel attempt (m=1), C8 positive route
      (m=0); persisted in ExteriorPinnedProbeK.lean.
- [ ] `lean_verify` (sorry + axiom audit) on every new theorem at its phase exit.
- [ ] Consumer regression: `endInterval_step_correct`, `bracketEndChar_kvExt_correct_prior`,
      KampPrior :838-876 mirror all compile after Phase 1 and stay green thereafter.
- [ ] Commit-per-green-substep (git-workflow mandate): `task 360 phase {P}: {name}` at each
      phase exit; `task 360 phase 3.1/3.2` if the split trigger fires.

## Artifacts & Outputs

- plans/01_restate-hbr-pinned-converse.md (this file)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedProbeK.lean (Phase 0, new)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedConverseK.lean (Phases 2, 3, 5, new)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedConversePastK.lean (Phases 4, 5, new)
- Restated interface across ExteriorConverter{,Past}K / ExteriorBracketAssembleK /
  ExteriorGateAssembleK / EndIntervalConsumerK / KampPrior.lean:838-876 (Phase 1)
- specs/360_restate_exterior_hbr_pinned_converse/.orchestrator-handoff.json (updated per phase)
- summaries/01_restate-hbr-pinned-converse-summary.md (Phase 6)

## Rollback/Contingency

- Every phase ends at a green commit; rollback = revert the last phase commit (tree is never
  left mid-restatement — Phase 1 is atomic within one dispatch).
- If Phase 0 C8 is NO-GO: Status → [BLOCKED]; escalation handoff carries the refuting
  configuration; no production file has been edited (Phase 0 touches only the new probe file).
- If Phase 3 blocks on a missing supplier: Future-converse file remains a green partial (atom
  layer landed); Phase 1's restatement is independently valuable and stays; escalate with the
  exact goal state per the recovery ladder (fix-forward first; never destructive git on
  uncommitted work — `git-snapshot.sh` before any intentional rollback).
- Stale 351/354 territory locks: overridden (>30 min stale); if either task resumes, this
  plan's file-scope table is the ownership record.
