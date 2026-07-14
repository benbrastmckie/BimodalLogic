# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Re-Keyed to Task 367's Deep-Anchor Rows-8-9/12-13 Interface, hsigma Production as the Crux (v06)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by supplying the depth>=1 interior/exterior obligations against task 367's deep-anchored rows-8-9/12-13 interface, and by PRODUCING the genuine realizer `hsigma` (Rabinovich 2014 Cor 5.4(1)⇐, p.9) that actually discharges the interior `hreal`/`hexcl` and the exterior converter seam
- **Status**: [NOT STARTED]
- **Effort**: 20-32 hours remaining (Phase 1 [COMPLETED]; 7 build/rewrite phases, each bounded to ~one agent run with a machine gate)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface), 364 (completed — co-realization mate check), **367 (completed, verified — deep-anchor guard `kvE_deepOnFiber`; UNBLOCKS the v05 Phase-2 blocker, 2026-07-14)**
- **Research Inputs**:
  - specs/367_deepanchor_exterior_fiber_population_against_taildoppelganger/summaries/01_deep-anchor-fiber-guard-summary.md (2026-07-14 — AUTHORITATIVE driver for this revision: the landed guard, its API, the interface restatement, and the prescribed 358 re-key route)
  - handoffs/phase-2-v05-handoff-20260714.md (the tail-doppelgänger refutation record that 367 answers; binder-level closure analysis)
  - reports/08_g2-rekey-against-364-interface.md (round 8 — byte-stable 364 discharge-lemma routing, still binding)
  - reports/06_remaining-work-and-plan-revision.md (round 6 — two-live-sorry map, ordered decomposition, verification bar)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, routes R1-R5; the *mathematics* of each gap)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐ grounding; corpus: `~/Projects/Literature/sources/rabinovich_2014/chunk_0014`-`chunk_0015` — Lemma 5.3 Dedekind `inf`-selection + the Cor 5.4(1)⇐ two-way `min`/case-split. CITATION RULE (sub-index hazard): cite the PDF by page number only, e.g. "Rabinovich 2014, Cor 5.4, p.9"; NEVER md:NN line numbers)
- **Reports Integrated**: specs/367 summary 01 (v06), phase-2-v05-handoff (v06), 08_g2-rekey-against-364-interface.md (v05), 06_remaining-work-and-plan-revision.md (v04), 04_post-360-gap-map-and-route.md (v03/v04), 02_literature-proof-method-survey.md (v02)
- **Artifacts**: plans/06_deep-anchor-rekey-v06.md (this file)
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

**What changed since v05.** Plan v05's Phase 2 was [BLOCKED]: the G2-1 general-m slice-id kernel
and the rows-8-9 binders as-then-stated were machine-refuted by an all-honest tail-doppelgänger at
fiber depth 1 (`kvE_probe358_tailDG_gapItem_pinned_fails`, `kvE_probe358_tailDG_sigma_in_population`
— ExteriorPinnedProbe358TailK.lean, sorry-free, floor axioms). **Task 367 has landed the prescribed
interface refinement**: a hereditary deep-anchor guard `kvE_deepOnFiber qnf σ`
(NEW `NfMultiAnchorBridge/ExteriorFiberDeepAnchorK.lean:81`) — depth-0 row check at σ-depth <= 1
(`rfl`-inert at m=0), row check `&&` a **qnf-marked deep-content mate** (`∃ σ', qnf.2 σ' ∧
σ'.2 = σ.2`) at σ-depth >= 2. The rows-8-9 antecedent `nfk_dropFresh σ = qnf.1` is **REPLACED** by
`kvE_deepOnFiber qnf σ = true` (EndIntervalConsumerK.lean:158-171, ExteriorGateAssembleK.lean,
`kampPrior_site_rungK_gate_match` KampPrior.lean:989-1002); the bracket range filters are re-keyed
identically (ExteriorBracketAssembleK.lean); **NEW m=0-vacuous rows 12-13** (`hexclDeepPast`/
`hexclDeepFut`, EndIntervalConsumerK.lean:191-204, gate-match KampPrior.lean:1017-1030) carry the
on-row guard-false residue; rows 10-11 are byte-stable. The tail-doppelgänger is guard-REJECTED
(`kvE_probe367_tailDG_deep_rejected`), the depth-2 hereditary doppelgänger too
(`kvE_probe367_depth2DG_deep_rejected`), and the content-copying plant collapses to the honest
slice (`kvE_probe367_copyPlant_collapses`). **The ledger is now 13 rows.**

**The crux of this task is UNCHANGED and is now unobstructed: PRODUCE `hsigma`** — the genuine
interior/exterior realizer `nf_eval_nf M (m+1) 4 [x1,w,x,t] σ`, selected per Rabinovich 2014
Cor 5.4(1)⇐ (p.9): from the fold-bit F-chain firing, pick the witness by the two-way `min`/
case-split induction (within-bracket bounded selection; `inf`/`sup` existence from Dedekind-style
completeness is Lemma 5.3's mechanism, p.8-9). The engine is LANDED sorry-free
(`kampPrior_fChain_realize_from` KampPrior.lean:1415, `_bracket` :1549,
`kampPrior_futRealizer_assemble` :1602, `kampPrior_futRealizer_of_pos` :1662 + Past mirrors).
Producing `hsigma` ACTUALLY DISCHARGES (not carries):
- the interior rows 5-6 (`hreal`/`hexcl`, gate-match KampPrior.lean:964-977), with `hfiberCons`
  (:962) via `kvE_fiberConsistent_of_realized`;
- the four task-356 exterior `hbr*`-shaped obligations at the CONVERTER seam:
  `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:231) / `kvE_pastBundle_of_realizer`
  (ExteriorConverterPastK.lean:199) are converters ONLY — given genuine `hsigma` they yield the
  `hbr*` conjuncts (their documented "discharge template" purpose). The missing piece was never
  the converter; it is producing `hsigma`.

Task 367's prescribed re-key for the exterior rows (binding, from its summary §"Notes for task
358"): **hereditary marked-characteristic membership** — for a realizer-derived σ over the
ambient's own tail, discharge the rows-8-9 guard antecedent via `kvE_deepOnFiber_of_realized`
(the mate is σ itself; no guard unfolding); m=0 routes through `kvE_deepOnFiber_zero` + the frozen
task-360 supply; rows 12-13 general-m via the `_of_realized` contradiction (an honest-ambient
pinned realizer forces the guard true, contradicting guard-false).

**Definition of done** (binding, carried from v04/v05): `:519` and `:522` both sorry-free; all
**13** ledger rows discharged at the `kampPrior_site_rungK_gate_match` recursion site over the
deep-anchored population; full-tree `lake build` GREEN; `#print axioms nf_nvar_exist_all_depths`
and `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]` (+ acceptable
`ofReduceBool`/`trustCompiler` from `native_decide` in the Syntax layer) with **NO `sorryAx`**.
`:522` CANNOT be silently deferred. **ZERO-DEBT TERMINUS**: no sorry, no vacuous definition, no
forcing a proof against a live countermodel — a sub-piece that cannot close green goes [BLOCKED]
with structured escalation, never a landed sorry.

### GLOBAL ROUTING CONSTRAINT (binding on Phases 2-8)

**Never unfold ANY guard body.** All consumption of the layered guards MUST route through the
byte-stable lemmas; hand-attacking a guard body re-opens a closed plantability surface:

| Guard | Sanctioned discharge/reading routes (ONLY these) |
|---|---|
| `kvE_deepOnFiber` (367) | `kvE_deepOnFiber_of_realized` (ExteriorFiberDeepAnchorK.lean:141 — honest discharge, mate = σ itself), `kvE_deepOnFiber_zero` (:94, `rfl` m=0 inertness), `kvE_deepOnFiber_row` (:127, guard → old row), `kvE_deepOnFiber_iff` (:106, deep-arm extraction — the ONLY mate-reading direction) |
| `kvE_fiberElemConsistent` / `kvE_fiberConsistent` (363/364) | `kvE_fiberElemConsistent_of_realized` (ExteriorFiberConsistencyK.lean:149), `kvE_fiberConsistent_of_realized` (:238) |
| `kvE_futAdmissible` / `kvE_pastAdmissible` (363/364) | proving: `kvE_futRealizer_admissible` (ExteriorNegationK.lean:131, pinned n=4 `(x1,w,x,t)`, strict chain `x<w<t<x1`) + Past mirror; reading: `kvE_futAdmissible_fiber_dichotomy`, `kvE_futAdmissible_onFiber` (ExteriorConverterK.lean:63), `kvE_futAdmissible_offFiber` |

Per-phase verification includes a source scan of newly added proofs for
`rw`/`unfold`/`simp only` on `kvE_deepOnFiber`, `kvE_fiberElemConsistent`, `kvE_fiberConsistent`,
`kvE_futAdmissible`, `kvE_pastAdmissible` — zero occurrences allowed outside their home modules.

### RE-PROBE DISCIPLINE (363/364/367 house style, binding)

Every new supply theorem/kernel is machine-adjudicated against the EXISTING countermodel families
BEFORE being trusted: the tail-doppelgänger cast (`kvE_probe358_tailDG_*` — must be excluded by
guard-false, per `kvE_probe367_tailDG_deep_rejected`), the depth-2 hereditary doppelgänger
(`kvE_probe367_depth2DG_deep_rejected`), the copy-plant (`kvE_probe367_copyPlant_collapses`), and
the 364 plant family (`kvE_probe364_sigma2_*`, `kvE_probe364_sstar_honest_unrealizable`). ALL
prior 358/363/364/367 certificates must REMAIN green at floor axioms
`[propext, Classical.choice, Quot.sound]` at every phase gate. If a NEW countermodel is found
against a restated obligation: build the probe (additive leaf, sorry-free), record the binder-level
closure in its docstring, mark the phase [BLOCKED], and escalate — never force the proof.

### Research Integration

Newly integrated this revision (v05 -> v06):

- **specs/367 summary** (01_deep-anchor-fiber-guard-summary.md). Integration effects:
  1. **v05 Phase-2 blocker DISSOLVED at interface level.** The rows-8-9 population is now
     deep-anchored: the tail-doppelgänger and its depth-2 hereditary variant are guard-rejected;
     the copy-plant is construction-impossible. Phase 2 is restated (see the resolution record).
  2. **G2-1 (`kvE_{fut,past}SliceId_of_end` at general m) is SUPERSEDED as a route.** The
     free-env → pinned upgrade that kernel rested on is machine-refuted at fiber depth >= 1 and is
     NOT resurrected by 367 — instead, the deep guard's qnf-marked mate (read via
     `kvE_deepOnFiber_iff`) replaces the slice-identification role in the rows-8-9 supply. Do NOT
     re-attempt G2-1 as stated in v05.
  3. **Rows 12-13 are new obligations** (m=0-vacuous); their general-m discharge is prescribed:
     `_of_realized` contradiction under an honest ambient.
  4. **Rows 10-11 byte-stable**; their general-m supply (and the G2-2 uniqueness kernel it
     consumes) is rebuilt against the deep-anchored population (367 handoff scope note: G2-2 was
     never refuted — both σ's pinned over the SAME tail — but its population is restated).
  5. **Converter-seam clarification** (delegation, supersedes the v05 non-goal wording): the
     machine-refuted v2 route was re-introducing `hbr*`-shaped UNIVERSAL binders / consuming the
     converter without a realizer. Applying `kvE_{fut,past}Bundle_of_realizer` TO a genuinely
     produced `hsigma` is the converter's documented purpose and is the sanctioned discharge site
     for the four task-356 exterior obligations.
  6. **Frozen-layer confirmation**: 367's terminal audit verified `ExteriorFiberConsistencyK/
     ProbeK/Probe364K`, `ExteriorNegation{,Past}K`, `ExteriorPinnedConverse{,Past}K`,
     `ExteriorPinnedProbe358K`, `ExteriorPinnedProbeM1K` byte-identical to baseline `1fa31549f`;
     Kamp-path sorries exactly `:519`/`:522`; full-tree build green.
- **phase-2-v05-handoff-20260714.md**: the refutation record and its scope notes are carried as
  constraints (G2-2/G1/rows-10-11 not refuted but must be rebuilt against the refined interface).

Carried from v05 (still integrated): report 08 (byte-stable 364 discharge routing — now extended
by the 367 row), report 06 (flow G2 -> G1 -> arm rewrites), report 04 (gap mathematics), report 02
(Rabinovich engine grounding).

### Preserved Assets (ALREADY LANDED — FROZEN, OUT OF SCOPE, do NOT re-open)

Green; consumed by name; MUST NOT regress, be re-derived, or overwritten. **PRESERVE
BYTE-FOR-BYTE**: m=0 kernels (`_zero` suffix family), k<=1 rungs, task 360's m=0 supply, and ALL
of task 363/364/367's guards/lemmas/probes.

| Landed asset | Interface (by name) | File:line | Owner |
|---|---|---|---|
| **k=0 arm of `\| 1 =>`** | `kampPrior_case1_arm_k0` | KampPrior.lean:~271 (consumed :504) | 358 P5.1 — **FROZEN** |
| **k=1 arm of `\| 1 =>`** | `kampPrior_case1_arm_k1` | KampPrior.lean (consumed :505) | 309 P20 — **FROZEN** |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | 350 — **FROZEN** |
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1415/1549/1602/1662 (+Past) | 358 P1-2 — sorry-free |
| Consumer stack + 13-row ledger (BINDING) | `endIntervalStepPrior`/`endInterval_step_correct`/ledger table | EndIntervalConsumerK.lean (rows table :293-298) | 349+367 |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:941-1043 | 349 (367-mirrored binders) |
| Provider shim | `kampPrior_existProviders_of_ih` (+variants) | KampPrior.lean:~985-1122 region | [COMPLETED] |
| Trichotomy assemble | `kampPrior_case1_trichotomy_assemble` | KampPrior.lean:~1146 | [COMPLETED] |
| **m=0 slice supply** (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (+Past) | ExteriorPinnedConverseK.lean:1301/1242; PastK:822/769 | 360 — **FROZEN, byte-unchanged through 367** |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_{fut,past}SliceUnique_zero` | ExteriorPinnedConverseK.lean:891; PastK:530 | 360 — **FROZEN** |
| hbr* refutation regression guard | `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:500 | do NOT delete/weaken |
| 363/364 fiber-consistency predicate + discharge lemmas | `kvE_fiberElemConsistent`/`kvE_fiberConsistent` (+`_zero`, `_of_realized` x2, `kvE_nf_mem_univ_toList`) | ExteriorFiberConsistencyK.lean | **FROZEN — consume by name, NEVER unfold** |
| 363/364 exterior guard + entry/readers | `kvE_{fut,past}Admissible`, `kvE_futRealizer_admissible` (+Past), `_fiber_dichotomy`, `_onFiber`, `_offFiber` | ExteriorNegation{K,PastK}.lean; ExteriorConverter{K,PastK}.lean | **FROZEN** |
| **367 deep-anchor guard + API** | `kvE_deepOnFiber` + `_zero`/`_base`/`_iff`/`_row`/`_of_realized` | **ExteriorFiberDeepAnchorK.lean:81-168** | **367 — the re-keying contract; FROZEN** |
| **367 probe certificates** | `kvE_probe367_tailDG_deep_rejected`, `_real_slice_deep_anchored`, `_depth2DG_deep_rejected`, `_copyPlant_collapses` | ExteriorFiberDeepAnchorProbe367K.lean | **367 — GREEN adjudication evidence; cite, do not modify** |
| 364 rejection certificates | `kvE_probe364_sigma2_{sstar_inconsistent,slice_inconsistent,inadmissible}`, `kvE_probe364_sstar_honest_unrealizable` | ExteriorFiberConsistencyProbe364K.lean | 364 — **FROZEN** |
| 363 re-probe certificates | `kvE_probe363_*` | ExteriorFiberConsistencyProbeK.lean | 363 — **FROZEN** |
| 358 refutation probes (historical, superseded-noted) | `kvE_probe358_eP_atomMate_present`; `kvE_probe358_tailDG_gapItem_pinned_fails`/`_sigma_in_population` | ExteriorPinnedProbe358K.lean; ExteriorPinnedProbe358TailK.lean | 358 — regression records, statements byte-stable |
| M1 residual records | `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` | ExteriorPinnedProbeM1K.lean | 363 residuals |
| Exterior converters (discharge templates) | `kvE_futBundle_of_realizer`; `kvE_pastBundle_of_realizer` | ExteriorConverterK.lean:231; ExteriorConverterPastK.lean:199 | 356/360 — apply to genuine `hsigma` only |
| n=0 / k=0 target arms | `nf_nvar_exist_all_depths` `\| 0 =>`, `\| k+1, 0 =>` | KampPrior.lean | do NOT touch |

Task 360's m=0 supply and the k<=1 rungs are byte-unchanged through 363, 364, AND 367 (git-audited
in each summary); this plan MUST keep them so. Note: the restated m=0 discharge already flows
through the `kvE_deepOnFiber_zero` adapter (landed by 367) — no m=0 work remains.

## Goals & Non-Goals

- **Goals**:
  - Supply the deep-anchored exterior rows 8-9 at general m: the guard's qnf-marked deep-content
    mate (read via `kvE_deepOnFiber_iff`) replaces the refuted slice-id kernel; guard antecedents
    on realizer-derived σ discharged via `kvE_deepOnFiber_of_realized`.
  - Supply the NEW rows 12-13 at general m via the `_of_realized` contradiction.
  - Rebuild the G2-2 uniqueness kernel + rows 10-11 supply against the deep-anchored population.
  - **PRODUCE `hsigma`** (interior rows 5-6, `kampPrior_hreal_supply`/`kampPrior_hexcl_supply`):
    Rabinovich 2014 Cor 5.4(1)⇐ (p.9) within-bracket bounded witness selection through the landed
    engine; discharge `hfiberCons` via `kvE_fiberConsistent_of_realized`; discharge the exterior
    `hbr*`-shaped seam by APPLYING `kvE_{fut,past}Bundle_of_realizer` to the produced `hsigma`.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 13 ledger rows; replace `:519`.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm; replace `:522`.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset (esp. the `_zero` kernel family,
    k<=1 rungs, 360 m=0 supply, 363/364/367 guards/lemmas/probes).
  - Do NOT unfold any guard body (GLOBAL ROUTING CONSTRAINT) — byte-stable lemmas only.
  - Do NOT re-attempt v05's G2-1 (`kvE_{fut,past}SliceId_of_end` at general m via the free-env →
    pinned upgrade) — machine-refuted; superseded by the deep-mate route.
  - Do NOT re-introduce any `hbr*`-shaped UNIVERSAL binder; do NOT consume
    `kvE_{fut,past}Bundle_of_realizer` without a genuine produced realizer (that hypothetical-
    consumption pattern is the machine-refuted v2 route). Applying the converters TO `hsigma`
    once produced is sanctioned and prescribed.
  - Do NOT delete/weaken any probe certificate or the refutation regression guard.
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` M-independent.

## Risks & Mitigations

- **Risk: the rows-8-9 supply's mate-to-witness step does not close** — from the guard's mate σ'
  (`qnf.2 σ' = true`, `σ'.2 = σ.2`) the supply must produce `kvE_futAdmissible σ' = true ∧
  kvE_futSliceEq σ' σ = true`. Admissibility: σ' is qnf-marked and the ambient is realized in
  rows 8-9's antecedent, so σ' is realized at some witness `x1'` (qnf's quant layer) — route
  through `kvE_futRealizer_admissible` if the pinned chain shape is available, else through the
  `_of_realized` family (stated general); slice-equality should follow from `σ'.2 = σ.2` + both
  rows pinned to `qnf.1` (`kvE_deepOnFiber_row` for σ; depth-0 factorization for σ'). If
  `kvE_futSliceEq` compares MORE than row + deep content, adjudicate by probe FIRST (Phase 3
  gate) — a mismatch is a [BLOCKED]-and-escalate, not a force.
- **Risk: rows 12-13 discharge needs ambient realization where only `igPtW` is in scope.** The
  `_of_realized` contradiction requires `nf_eval_nf … qnf` at `[w,x,t]`; the rows-12-13 binders
  carry `igPtW`-guards. Mitigation: the same `igPtW` → ambient bridge G1 uses (`hcharK` +
  `P.correct` + `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam) renders the
  ambient realization; Phase 4 adjudicates this bridge first and probes if it fails.
- **Risk: G2-2 uniqueness at general m needs a deep transfer kernel** (EF-style exterior-chain
  matching — 367 handoff scope note). Mitigation: build against the deep-anchored population where
  the second witness's deep content is pinned (`σ'.2 = σ.2` heredity); probe against the
  countermodel families before trusting; [BLOCKED]+escalate if a new countermodel appears.
- **Risk: `hsigma` production (G1) exceeds one agent run.** Mitigation: Phase 5 is scoped to
  `hreal` only (the Cor 5.4(1)⇐ selection); `hexcl` is Phase 6. If Phase 5 still overruns, split
  at the G1-1/G1-2 boundary (population split vs. per-σ chain-firing) with a green commit between.
- **Risk: `:522` arity-lift does not close under either reduction route.** Mitigation: G4-1 route
  adjudication at Phase 8 start; if neither closes, [BLOCKED] + spawn an isolated arity-lift task,
  keep S1 landed — NEVER a carried sorry.
- **Risk: touching frozen layers.** Mitigation: per-phase `git diff` audit against the Preserved
  Assets table; scoped `lake build` per phase; full-tree build + certificate re-verification at
  terminus.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- (1 complete) |
| 2 | 3, 5 | 2 |
| 3 | 4 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 3, 4, 5, 6 |
| 6 | 8 | 7 |

Phases within a wave can run in parallel with disjoint territory: Phase 3 (exterior leaf files)
and Phase 5 (KampPrior/interior leaf) do not overlap. Phase 4 shares Phase 3's territory
(sequential). Every phase ends with a machine gate: scoped build + `lean_verify` at floor axioms
+ guard-unfold source scan + frozen-boundary git-diff audit.

### Phase 1: Consume and pin the task-363 interface [COMPLETED]

> **P1 outcome (2026-07-14, sess_1784045100_2e3ffe)**: all six checklist items executed —
> signatures/conjunct-2/antecedent-pair pinned by name; three re-probe certificates
> lean_verify GREEN at floor axioms; target signatures recorded in
> handoffs/phase-1-handoff-20260714.md. Anchor-content gate: PASSED-WITH-ADVERSE-FINDING —
> machine-confirmed in v05 P2 and DISSOLVED in two steps: task 364 (co-realization mate check —
> killed the planted-mate family) and task 367 (deep-anchor guard — killed the all-honest
> tail-doppelgänger family).
>
> **v06 note**: the P1 pins predate task 367's interface restatement (rows 8-9 antecedent
> replaced; rows 12-13 added). The fresh pin against the 367 interface is Phase 2 of THIS plan.
> The 363-era pinned signatures remain correct for the guards 367 left byte-stable.
- **Goal:** (historical) Bind 363's landed fiber-consistency interface by name.
- **Tasks:** (all executed; see plans/05 for the retained checklist)
- **Timing:** 1-2 hours (spent).
- **Depends on:** none.
- **Completed:** 2026-07-14 (sess_1784045100_2e3ffe).

### Phase 2: 367 interface pin + re-probe gate [COMPLETED]

> **P2 outcome (2026-07-14, sess_1784059448_2c72f2_358)**: all five checklist items executed —
> binders/mirrors/API/converters/SliceEq pinned by name; 14-certificate re-probe gate GREEN at
> floor axioms; Kamp sorries exactly :519/:522; zero source edits. Adjudication PRE-RESULT for
> Phase 3 recorded in handoffs/phase-2-v06-handoff-20260714.md: the deep-mate COLLAPSES to σ
> itself (Prod ext via common marked fiber; the `kvE_probe367_copyPlant_collapses` mechanism),
> so SliceEq needs nothing beyond row + deep content — the supply route is confirmed viable.

> **BLOCKER RESOLUTION RECORD (v05 Phase 2 [BLOCKED] -> v06 restated, 2026-07-14)**: v05's
> Phase 2 (G2-1/G2-2 slice-id + uniqueness kernels at general m) was blocked by the all-honest
> tail-doppelgänger machine refutation (`kvE_probe358_tailDG_gapItem_pinned_fails`,
> `kvE_probe358_tailDG_sigma_in_population` — the free-env → pinned upgrade FALSE at fiber
> depth >= 1; rows 8-9 FALSE-as-then-stated at m >= 1), with the blocker record prescribing a
> 363/364-style DEEP interface refinement and forbidding re-dispatch against the old interface.
> **Task 367 (verified [COMPLETED], session sess_1784059448_2c72f2_367) LANDED that refinement**:
> the hereditary deep-anchor guard `kvE_deepOnFiber` restates rows 8-9, re-keys the bracket
> ranges, and adds rows 12-13; the tail-doppelgänger and its depth-2 variant are guard-rejected
> (`kvE_probe367_tailDG_deep_rejected`, `kvE_probe367_depth2DG_deep_rejected`), the copy-plant
> collapses (`kvE_probe367_copyPlant_collapses`), and honest realized slices pass
> (`kvE_probe367_real_slice_deep_anchored`, derived via `_of_realized` with zero guard
> unfoldings). v05's G2-1 route is SUPERSEDED (not resurrected): the deep guard's qnf-marked
> mate takes over the slice-identification role. The v05 blocker artifacts
> (`ExteriorPinnedProbe358TailK.lean`, the handoff) are retained as regression records — do not
> delete; 367 already added the supersession docstring note (statements byte-stable).
- **Goal:** Pin the restated interface by name and machine-certify the ground truth before any
  build — the v06 analogue of v05's P2-0 gate.
- **Tasks:**
  - [ ] Pin the restated rows-8-9 binder text (`_hslicePast`/`_hsliceFut`,
        EndIntervalConsumerK.lean:158-171) and the NEW rows-12-13 binder text (`_hexclDeepPast`/
        `_hexclDeepFut`, :191-204), and their `kampPrior_site_rungK_gate_match` mirrors
        (KampPrior.lean:989-1002, :1017-1030). Confirm rows 10-11 byte-stable against 360's
        supply statements. Record the exact general-m supply-theorem TARGET signatures (the
        statements Phases 3-6 must prove) in a phase handoff.
  - [ ] Pin the deep-anchor API signatures (`kvE_deepOnFiber` + `_zero`/`_base`/`_iff`/`_row`/
        `_of_realized`, ExteriorFiberDeepAnchorK.lean:81-168) and the converter signatures
        (`kvE_futBundle_of_realizer` ExteriorConverterK.lean:231, `kvE_pastBundle_of_realizer`
        ExteriorConverterPastK.lean:199 — note: delegation line refs :208/:177 are stale).
  - [ ] Pin `kvE_futSliceEq`/`kvE_pastSliceEq` and `kvE_{fut,past}SliceMarked` definitions
        (reading only — needed to adjudicate the Phase-3 mate-to-witness step).
  - [ ] **Re-probe gate**: `lean_verify` at floor axioms, no sorryAx: the four `kvE_probe367_*`,
        the four `kvE_probe364_*`, `kvE_probe363_*` (3), `kvE_probe358_eP_atomMate_present`,
        both `kvE_probe358_tailDG_*`. Confirm Kamp-path sorries are exactly KampPrior.lean:519
        and :522 (`grep -n "sorry"`).
  - [ ] Zero file edits this phase (pin-and-gate only); git status audit confirms.
- **Timing:** 1-2 hours.
- **Depends on:** none (Phase 1 complete).
- **Territory:** read-only.

### Phase 3: Exterior rows 8-9 supply at general m (deep-mate route) [COMPLETED]

> **P3 outcome (2026-07-14, sess_1784059448_2c72f2_358)**: NEW leaf
> `NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean` — `kvE_hsliceFut_supply` /
> `kvE_hslicePast_supply` at GENERAL k (binder-shape-exact), via the side-shared
> mate-collapse kernel `kvE_deepMate_collapse` (+ `kvE_{fut,past}SliceEq_refl`). Adjudication
> gate result: SliceEq needs NOTHING beyond row + deep content — the guard's mate collapses
> to σ itself (Prod ext over a common marked fiber element; the
> `kvE_probe367_copyPlant_collapses` mechanism), so the k>=1 arm concludes with σ' := σ.
> k=0 discharges through `kvE_deepOnFiber_zero` + the FROZEN 360 `_zero` supplies (verbatim
> consumption, zero edits). Machine gate: scoped build green (1031 jobs); all three new
> theorems at floor axioms, no sorryAx; guard-unfold scan zero; frozen files byte-identical;
> `kvE_probe367_tailDG_deep_rejected` + `_depth2DG_deep_rejected` re-verified green.
> *(deviation: altered — G2-A1/A2 admissibility+slice-equality sub-derivations were subsumed
> by the mate-collapse; `kvE_futRealizer_admissible` not needed since the conclusion's
> witness is σ itself, already admissible by antecedent.)*
- **Goal:** Prove `kvE_hsliceFut_supply` / `kvE_hslicePast_supply` at general m matching the
  restated rows-8-9 binder shapes: given σ admissible, `kvE_deepOnFiber qnf σ = true`, chain
  firing, and the ambient realized — exhibit a qnf-marked σ' with `kvE_{fut,past}SliceEq σ' σ =
  true` and admissible. The refuted slice-id kernel is REPLACED by the guard's own mate.
- **Tasks:**
  - [ ] **Adjudication gate (before building)**: from Phase 2's `kvE_futSliceEq` pin, verify on
        paper + by `lean_multi_attempt` that mate σ' (from `kvE_deepOnFiber_iff`: `qnf.2 σ' =
        true`, `σ'.2 = σ.2`) yields `kvE_futSliceEq σ' σ = true` given both on-row (σ via
        `kvE_deepOnFiber_row`; σ' via its realizer's depth-0 factorization). If SliceEq needs
        more than row + deep content, STOP: probe the gap against the countermodel families,
        [BLOCKED]+escalate on a live countermodel.
  - [ ] **G2-A1 (Future)**: prove `kvE_hsliceFut_supply` general-m. Route: extract the mate via
        `kvE_deepOnFiber_iff` (sanctioned reading); realize σ' from the ambient realization +
        `qnf.2 σ' = true` (quant-layer witness `x1'`); admissibility of σ' via
        `kvE_futRealizer_admissible` (if the pinned strict chain is available at `x1'`) or the
        `_of_realized` family (general form); slice-equality per the adjudication gate. NEVER
        unfold any guard.
  - [ ] **G2-A2 (Past)**: mirror for `kvE_hslicePast_supply`.
  - [ ] Confirm the m=0 layer unregressed: the frozen `_zero` supplies + the landed
        `kvE_deepOnFiber_zero` adapter discharge is byte-unchanged (git-diff audit).
  - [ ] Machine gate: scoped `lake build` of the new leaf + `ExteriorGateAssembleK`/
        `EndIntervalConsumerK` consumers; `lean_verify` new theorems at floor axioms; guard-unfold
        source scan (zero); re-verify `kvE_probe367_tailDG_deep_rejected` +
        `kvE_probe367_depth2DG_deep_rejected` still green (the casts these theorems must not
        readmit).
- **Timing:** 4-6 hours.
- **Depends on:** 2.
- **Territory:** NEW leaf under `NfMultiAnchorBridge/` (recommended:
  `ExteriorDeepSliceSupplyK.lean`) or append-only in `ExteriorPinnedConverse{K,PastK}.lean`
  (m=0 regions frozen). Read-only: all guard/probe modules.

### Phase 4: Exterior rows 12-13 supply + G2-2 uniqueness kernel + rows 10-11 supply at general m [NOT STARTED]
- **Goal:** Complete the exterior ledger: rows 12-13 (`hexclDeep*`) via the `_of_realized`
  contradiction; the G2-2 uniqueness kernel restated over the deep-anchored population; rows
  10-11 (`hexclSlice*`, byte-stable statements) consuming carried `hreal` + uniqueness.
- **Tasks:**
  - [ ] **Bridge adjudication**: render ambient realization from the rows-12-13 `igPtW` guard
        (the `hcharK` + `P.correct` + `kampPrior_existProviders_of_ih_existF0_char` bridge under
        the pinned seam — same move G1 uses). If the bridge fails at this binder site, probe and
        escalate per the re-probe discipline.
  - [ ] **G2-B1 (rows 12-13)**: prove `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply`
        general-m: suppose a realizer of σ at the pinned exterior tuple; with the ambient realized,
        `kvE_deepOnFiber_of_realized` forces `kvE_deepOnFiber qnf σ = true`, contradicting the
        binder's guard-false antecedent. (m=0 instance vacuous via `_zero` — already landed; do
        not touch.)
  - [ ] **G2-B2 (uniqueness kernel)**: prove `kvE_{fut,past}SliceUnique` at general m over the
        deep-anchored population (both σ's pinned over the SAME real tail — the cast that never
        refuted it). Use the deep-content pinning (`σ'.2 = σ.2` heredity) + on-fiber row pinning
        (`kvE_futAdmissible_onFiber`) in place of the refuted free-env upgrade; EF-style exterior
        chain matching only where the deep content does not already decide. Probe against the
        countermodel families BEFORE consuming it downstream.
  - [ ] **G2-B3 (rows 10-11)**: prove `kvE_hexclSliceFut_supply` / `kvE_hexclSlicePast_supply`
        general-m: carried `hreal` + G2-B2 uniqueness + the admissibility-zone readback
        (`kvE_futAdmissible_fiber_dichotomy` reading direction).
  - [ ] Machine gate: scoped build; `lean_verify` at floor axioms; guard-unfold scan (zero);
        frozen-boundary git-diff (m=0 supplies + `_zero` kernels byte-identical); full prior
        certificate set re-verified green.
- **Timing:** 5-8 hours (if it exceeds one agent run, split G2-B1 from G2-B2/B3 with a green
  commit between — B1 is independent of the kernel).
- **Depends on:** 3 (same territory; consumes Phase-3 statement shapes).
- **Territory:** same leaf as Phase 3 (+ append-only `ExteriorPinnedConverse{K,PastK}.lean`).

### Phase 5: Interior `hreal` supply — PRODUCE `hsigma` (Rabinovich Cor 5.4(1)⇐) [NOT STARTED]
- **Goal:** Prove `kampPrior_hreal_supply` matching the gate-match row-5 binder
  (KampPrior.lean:964-970): for every `igPtW`-selected w and every qnf-marked fiber-consistent σ,
  produce `x1` with `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` — the genuine realizer `hsigma`. This is
  the task's crux and the dominant mathematics: Rabinovich 2014 Cor 5.4(1)⇐ (p.9) — from F-chain
  firing inside the bracket, select the witness by the two-way `min`/case-split induction
  (corpus: rabinovich_2014/chunk_0015; the `inf`-selection mechanism is Lemma 5.3, p.8-9,
  chunk_0014). LITERATURE FIDELITY: follow the source's case structure step-by-step; the landed
  engine already transcribes it — this phase INSTANTIATES the engine, it does not re-derive it.
- **Tasks:**
  - [ ] **G1-1 (population split)**: split the `w` population. `=>`-direction ws (ambient
        `nf_eval_nf M (k+2) 3 [w,x,t] qnf` in scope): forall-σ agreement is DEFINITIONAL —
        discharge outright. `<=`-direction ws (igPtW-selected): render w's realization of
        `igFoldBit qnf` via `hcharK` + `P.correct` + `kampPrior_existProviders_of_ih_existF0_char`
        under the pinned seam.
  - [ ] **G1-2 (per-σ chain-firing -> witness)**: per marked σ, the fold-bit -> chain-firing
        bridge, then witness selection. Exterior-zone σ: fold bit fires `kvE_{fut,past}Pos (Pbr)
        σ`; drivers `kampPrior_{fut,past}Realizer_of_pos` (KampPrior.lean:1662 + Past mirror)
        select `x1` and emit `hsigma`; their transfer inputs are the SAME statement one fiber
        level down — close by the recursion's IH at depth k (level descent; depth-0 base atomic,
        ExteriorFiberProbeK.lean:252 pattern). Interior-zone σ (`x1 ∈ (x,t)`):
        `kampPrior_fChain_realize_bracket` (KampPrior.lean:1549) with F-chain firing from the
        fold-bit fiber content, bracket endpoints `(x,t)` — the Cor 5.4(1)⇐ selection.
  - [ ] **Converter-seam discharge**: at each site holding the produced `hsigma`, discharge the
        `hbr*`-shaped carried obligations by APPLYING `kvE_futBundle_of_realizer`
        (ExteriorConverterK.lean:231) / `kvE_pastBundle_of_realizer`
        (ExteriorConverterPastK.lean:199) to `hsigma`. Guard antecedents on realizer-derived σ
        (bracket-range membership, rows-8-9 application) discharged via
        `kvE_deepOnFiber_of_realized` (mate = σ itself) — 367's prescribed route.
  - [ ] Discharge `hfiberCons` on honest/realized ambients via `kvE_fiberConsistent_of_realized`
        applied to the ambient realizer.
  - [ ] Deliver `kampPrior_hreal_supply` matching the row-5 binder shape exactly. Machine gate:
        scoped build of `KampPrior` (or the new interior leaf); `lean_verify` at floor axioms;
        guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 6-9 hours (heaviest phase; if it exceeds one agent run, split G1-1 from G1-2 at a
  green commit — G1-2 per-zone sub-splits are also natural seams).
- **Depends on:** 2. Runs in parallel with Phase 3 (disjoint territory).
- **Territory:** `KampPrior.lean` (or a new interior leaf under `Kamp/` if it grows unwieldy).
  Read-only: all exterior leaf files.

### Phase 6: Interior `hexcl` supply (contrapositive channel) [NOT STARTED]
- **Goal:** Prove `kampPrior_hexcl_supply` matching the gate-match row-6 binder
  (KampPrior.lean:971-977): a within-`[x,t]` realizer of a bit-false fiber-consistent σ is
  impossible.
- **Tasks:**
  - [ ] **G1-3**: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW
        agreement, via the Phase-4 uniqueness/readback kernel (now deep-anchored: any second
        witness's deep content is pinned; fakes are outside the population by guard).
  - [ ] Deliver `kampPrior_hexcl_supply`. Machine gate: scoped build; `lean_verify` at floor
        axioms; guard-unfold scan (zero); frozen-boundary audit; prior certificate set green.
- **Timing:** 3-5 hours.
- **Depends on:** 4 (uniqueness kernel), 5 (shares the interior seam and `hreal` machinery).
- **Territory:** same as Phase 5.

### Phase 7: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body (KampPrior.lean:506-519) to discharge all 13
  ledger rows and replace the `:519` sorry (route R4).
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally
        decreasing recursive calls — the documented Phase-16 move). Rows 1-2 discharged.
  - [ ] **G3c-2**: discharge rows 5-6 via Phases 5-6 (+ `hfiberCons` via
        `kvE_fiberConsistent_of_realized`); rows 8-9 via Phase 3; rows 10-11 via Phase 4 (G2-B3);
        rows 12-13 via Phase 4 (G2-B1); rows 3-4 ambient; row 7 internal (task 356). Close via
        `kampPrior_case1_trichotomy_assemble` + `kampPrior_site_rungK_gate_match` (single-depth
        providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing notes (KampPrior.lean:486-518 residual
        comments naming `P17-frozen-interface-gap`) in the SAME edit to record the full
        resolution chain (363: fiber-consistency guard; 364: co-realization mate check; 367:
        deep-anchor guard; 358: supply + hsigma production).
  - [ ] Machine gate: scoped build of `KampPrior`; confirm `:519` gone; `lean_verify
        nf_nvar_exist_all_depths` shows only the `| n+2 =>` arm still contributing `sorryAx`;
        guard-unfold scan (zero); frozen-boundary audit.
- **Timing:** 3-5 hours.
- **Depends on:** 3, 4, 5, 6.
- **Territory:** `KampPrior.lean` only.

### Phase 8: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
- **Goal:** Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replace the `:522` sorry, and
  perform the terminal full-tree + axiom audit.
- **Tasks:**
  - [ ] **G4-1 route adjudication** (report 04 §3 G4): (i) iterated one-variable reduction through
        the `| 1 =>` machinery (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`;
        needs an arity-general restatement of the arity-2-specific trichotomy/nf_char2 layer) vs.
        (ii) docstring bootstrap (KampPrior.lean:~323-331). The realizer engine/drivers are
        arity-generic. Note: `kvE_futRealizer_admissible` is pinned at n=4; off n=4 route through
        the `_of_realized` family (stated general) — never unfold.
  - [ ] Rewrite the `| n + 2 =>` arm; replace the `:522` sorry.
  - [ ] **If neither route closes green** -> [BLOCKED] + spawn an isolated arity-lift task; S1
        stays landed; NEVER a carried sorry.
  - [ ] **Terminal audit**: full-tree `lake build` GREEN; `grep -n "sorry" KampPrior.lean` shows
        no live proof sorry; `#print axioms nf_nvar_exist_all_depths` and
        `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]`
        (+ acceptable native_decide axioms), NO `sorryAx`; tree-wide guard-unfold scan (zero
        introduced by this task); full prior-certificate inventory (358/363/364/367) re-verified
        green; vacuous-def scan clean.
  - [ ] Confirm downstream unlock: retiring `:519`/`:522` fully retires task 309's `:361` and
        unblocks task 307 Phase 7 (note in the completion summary; do not action here).
- **Timing:** 2-4 hours.
- **Depends on:** 7.
- **Territory:** `KampPrior.lean` only.

## Testing & Validation

- [ ] **Phase-2 re-probe gate**: full certificate inventory (`kvE_probe367_*` x4,
      `kvE_probe364_*` x4, `kvE_probe363_*` x3, `kvE_probe358_*` x3) `lean_verify` GREEN at floor
      axioms `[propext, Classical.choice, Quot.sound]`, no sorryAx, BEFORE any supply build.
- [ ] **Per-phase machine gate (binding, every phase)**: scoped `lake build` + `lean_verify` of
      each new theorem at floor axioms + guard-unfold source scan (zero occurrences of
      `rw`/`unfold`/`simp only` on `kvE_deepOnFiber`/`kvE_fiberElemConsistent`/
      `kvE_fiberConsistent`/`kvE_{fut,past}Admissible` in new proofs) + frozen-boundary
      `git diff` audit (m=0 `_zero` family, 360 supplies, k<=1 rungs, `kampPrior_case1_arm_k0`,
      363/364/367 guard/lemma/probe declarations — byte-identical).
- [ ] **Re-probe discipline per phase**: the countermodel-family certificates re-verified green
      after each phase's landings (the casts the new theorems must not readmit).
- [ ] **Zero live sorries at terminus**: currently exactly two live (`:519`, `:522`); terminus
      shows none.
- [ ] **Axiom transcript**: `nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`, and
      `completeness_discrete` at floor axioms with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline post-367: green per 367's
      terminal audit).
- [ ] **Zero-debt scan**: no vacuous definitions (`def X := True` family) introduced anywhere.

## Artifacts & Outputs

- plans/06_deep-anchor-rekey-v06.md (this file)
- summaries/06_deep-anchor-rekey-v06-summary.md (on implementation completion)
- Phase-2 pin handoff (handoffs/, target supply-theorem signatures)
- Lean edits: NEW exterior supply leaf (recommended `ExteriorDeepSliceSupplyK.lean`) with rows
  8-9/12-13 supplies, uniqueness kernel, rows 10-11 supplies; `kampPrior_hreal_supply`/
  `kampPrior_hexcl_supply` in `KampPrior.lean` (or interior leaf); the two arm rewrites replacing
  `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step committed as
  it lands (`task 358 phase P.O: {objective}`); failures roll back to the last green milestone.
- **Phase-2 gate fails** (any prior certificate no longer verifies at floor axioms): STOP — the
  ground truth has shifted; do NOT build. [BLOCKED] with the failing certificate named; escalate.
- **Phase-3 adjudication gate fails** (`kvE_futSliceEq` needs more than row + deep content, or a
  new countermodel survives the deep guard): probe it (additive leaf, sorry-free, binder-level
  closure in the docstring — house style), mark the phase [BLOCKED], `/spawn 358` an isolated
  interface/kernel follow-up. Never force the supply against a live countermodel.
- **Phase-4 bridge or kernel fails** (igPtW → ambient bridge unavailable at the rows-12-13 site,
  or uniqueness meets a new countermodel): same probe-then-[BLOCKED] discipline; keep Phase-3
  landings intact.
- **Phase-5/6 realizer production stalls** (a marked σ's zone case resists the engine): commit all
  green sub-steps, record the exact failing σ shape and goal state, [BLOCKED] + escalate — the
  literature-fidelity escalation path (re-read source -> alternative encodings -> flag gap), never
  a sorry.
- **Phase-8 `:522` cannot close** under either route: [BLOCKED] + spawn an isolated arity-lift
  task; S1 (`:519`) stays landed and committed — itself a shippable milestone.
- **Regression detected** (any frozen declaration changed): snapshot per git-workflow.md, targeted
  `git checkout` of the offending file to the last green commit, re-run the scoped build,
  re-attempt within phase territory only.
