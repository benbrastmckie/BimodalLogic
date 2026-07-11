# Implementation Plan: prop43_exterior_reflatten

- **Task**: 348 - prop43_exterior_reflatten
- **Status**: [IMPLEMENTING]
- **Effort**: 24 hours (8 phases, one agent run each, ~2-4 h per phase)
- **Dependencies**: 335 (landed — fragment gate + hexclExt binder), 346 (landed — isolation), 347 (landed — R1 narrowing to exterior-marked σ)
- **Research Inputs**: specs/348_prop43_exterior_reflatten/reports/01_prop43-exterior-reflatten.md (hard-mode, H4-verified); specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md; specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md §prop43_exterior_reflatten (authoritative spec)
- **Artifacts**: plans/01_prop43-exterior-reflatten.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: lean4
- **Mode**: hard (H8 phase sizing, postmortem constraints, wave declarations, H3 grounding)

## Overview

Discharge the exterior-marked `hexclExt` residue (verbatim binder at OuterGate.lean:312/:393,
SharedWitness.lean:12710; sole consumption point SW:12788) by the settled Rabinovich
re-flatten/adjacency method: (1) an order-atom zone-triage lemma shrinking the residue to
`zPastX3`/`zFutT3`-marked σ; (2) model-independent one-sided complement clauses (Cor 5.4(1)/(2)
exterior analogs, p.9) over the finite σ alphabet, gated by a single-σ GO/NO-GO spike;
(3) adjacent exterior brackets for `(−∞,x)` / `(t,∞)` (Def 7.5 p.13 / Lemma 7.10 p.15 shapes);
(4) an enriched gate — interior gate ∧ extBracketPast(x) ∧ extBracketFut(t), the degenerate
Lemma 7.6 (p.14) adjacency composition at the shared anchors — plus a discharge theorem calling
`bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean:359) with `hexclExt` closed.
Definition of done for THIS task is the amended DoD under the R1 scope decision below; all new
code lands in new files on the gate path, axiom-clean {propext, Classical.choice, Quot.sound},
no sorry on live paths.

### Research Integration

- `reports/01_prop43-exterior-reflatten.md` (v1, integrated 2026-07-11): F1 verbatim goal shape
  + residue extent; F2 `neg_2var_vec_ea` feeds via machinery not statement; F3 four-stage
  architecture with sizes; H3 9-row lemma mapping; risks R1-R6; H4 claim table (all load-bearing
  claims VERIFIED).
- 335 handoff 03 (integrated): binder contract, companion obligations `hrealI`/`hrealB`/`hexcl`
  are 309-Phase-14 provider obligations; ⇐ half of the gate unconditional.

### R1 Scope Decision (SETTLED by this plan — do not re-open)

**KampPrior.lean:351 strategic-sorry retirement is OUT of 348's scope and DEFERRED to task 309
Phase 14.** 348 delivers through the Phase 8 discharge theorem
`bracketEndChar_kvE2Ext_correct_two_prior_frag`, in which `hexclExt` is discharged internally
and `hrealI`/`hrealB`/`hexcl` (+ `hfrag`) remain threaded hypotheses. Rationale:

1. The 335 handoff §1/§3 assigns `hrealI`/`hrealB`/`hexcl` to 309's Phase-14 provider
   instantiation — absorbing them here would duplicate 309's scope inside 348.
2. The ∀k-lift fragment-scoping needed for the :351 wiring is explicitly flagged as a
   **309-plan decision** (handoff §5, options (a)/(b)); 348 pre-deciding it would create
   cross-task churn on 309's plan.
3. state.json dependencies for 348 are {335, 346, 347}; 309 is 348's *consumer*. Pulling :351
   retirement in would invert the dependency graph (348 would then depend on 309 Phase 14).

**Amended DoD for 348**: the enriched composed gate and its discharge theorem exist, sorry-free
and axiom-clean, with `hexclExt` no longer an input obligation — the only remaining hypotheses
are the 309-owned provider obligations. The task-description clause "KampPrior.lean:351
strategic sorry retired" transfers to 309 Phase 14 (which now consumes 348's theorem plus its
own provider discharge). Phase 8 records this transfer in a doc-comment next to
KampPrior.lean:351 and in the implementation summary. This is deferral to an EXISTING dependent
task — no new task is spawned and this is NOT a skeleton plan (`skeleton: false`).

### Preserved Assets

The following work is complete and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| k=2 fragment gate (`bracketEndChar_kvE2_correct_two_prior_frag`, `_sound_two_prior_frag`, `_complete_two_prior`) | Kamp/NfMultiAnchorBridge/OuterGate.lean (:147/:288/:359) | [COMPLETED] task 335, commit 147af2fbe, axiom-clean | 2026-07-11 |
| Narrowed `hexclExt` binder + re-threaded fold `kvE2_outer_fold_frag` | Kamp/NfMultiAnchorBridge/SharedWitness.lean:12665/:12710 | [COMPLETED] task 347 R1, commit 3b8aee3c4 | 2026-07-11 |
| Interior-slice discharge `kvE2_sepInterior_exterior_notRealizable` | SharedWitness.lean:12627 (below SW:10210 GATE banner) | [COMPLETED] task 347 R1, commit d370d438e | 2026-07-11 |
| Lemma 5.3 F-chain kit (`fChainFrom`/`fChainPred`/`bracket_implies_fChainPred`) | Kamp/EANegation.lean:552/:567/:660 | [COMPLETED] | 2026-07-11 |
| §5 complement constructions (`neg_vecEA2`, `neg_interval_formula`, `neg_b2_bracket_formula` + disjointness) | Kamp/EANegationClosure.lean (thm `neg_2var_vec_ea` :722) | [COMPLETED] | 2026-07-11 |
| `HasAttainedINF` + `prior_hasAttainedINF` (from `h_UZ`) | Kamp/PriorINF.lean:202/:224 | [COMPLETED] | 2026-07-11 |
| Prop 4.3 atom/lt building blocks + blocker doc | Kamp/Prop43.lean (off live import path) | [COMPLETED] (keep off-path) | 2026-07-11 |
| Witness-growing carrier `BracketEndCharCarrierV` | Kamp/NfMultiAnchorBridge/CarrierK1V.lean:365 (task-description pointer ":1872" is STALE) | [COMPLETED] | 2026-07-11 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from 330 report 01 (REDESIGN), 335
report 07 (Refutations), 347 report 01 (adjudication), and the 348 research report (F2, R2-R6).

**Do NOT**:
- Prove `hexclExt` as strictly-exterior completeness / non-realization on the interior `(x,t)`
  bracket — retired phantom framing, machine-argued inexpressible (335 report 07 Refutation 2;
  `bracketEndChar_kv_factors` arity-1 information ceiling, CarrierKv.lean:422; 335 handoff:
  "machine-confirmed impossible" to derive from interior-bracket hypotheses).
- Bound `nf_eval_nf`'s outer existential in place (NormalForm.lean:203–207 is correct raw FOMLO
  semantics; the bounding lives in the NEW bracket formulas, never in the evaluator).
- Cite `neg_2var_vec_ea` (EANegationClosure.lean:722) as the discharge step: its conclusion
  `∃ v', v'.holds M atomMap z0 z1` is pointwise and closable by the trivially-true `VVecEA2`
  (:699–708) — vacuous as a black box (F2/R4). Consume its MACHINERY instead: `neg_vecEA2`,
  `neg_interval_formula`, `neg_b2_bracket_formula` + disjointness, the `fChain*` kit,
  `prior_hasAttainedINF`.
- Attempt the general model-independent negation backward direction or the full uniform
  Prop 4.3 connective cases — UNFIXABLE as-constructed (report-18 B.1; NegationIndep.lean:331–359,
  re-confirmed task-305 probe). 348 needs only the SPECIFIC finite exterior σ-clauses.
- Edit `SharedWitness.lean` / `SubBracket2V.lean` above the SW:10210 GATE banner (341/347
  frozen-file gate; 335 left both byte-unchanged). `OuterGate.lean` may only be extended
  additively; prefer new files.
- Introduce any new semantic hypothesis on `M`: `HasAttainedINF` derives from the already-carried
  `h_UZ` via `prior_hasAttainedINF` (PriorINF.lean:224).
- Use the stale carrier pointer `NfMultiAnchorBridge.lean:1872` — the declaration is
  `CarrierK1V.lean:365`.
- Fall back, on any difficulty, to a vacuous per-model existential statement (the F2 trap) or to
  analysis-only output: every dispatch lands compiling Lean (H2).

**MUST preserve**:
- Everything in the Preserved Assets table (in particular: no signature change to the landed
  gate theorems; the `hexclExt` binder shape stays byte-identical where it already appears).
- Full-project `lake build` green and the axiom set {propext, Classical.choice, Quot.sound} on
  the gate path after every phase.
- `Prop43.lean` stays off the live import path (blocker documentation home; Phase 8 only updates
  its blocker note to point at the landed exterior instances).

**Design decisions are SETTLED** (re-open only with a machine counterexample):
- Method = Rabinovich Prop 4.3 re-flatten (p.6, Fig. 1 p.10) + Lemma 7.6 adjacency (p.14):
  exterior arrangements belong to ADJACENT intervals `(−∞,x)` / `(t,∞)` with their own brackets,
  composed with the landed interior bracket at seam anchors `x, t` (347 adjudication verdict (b)).
- The Lemma 7.6 composition degenerates to plain conjunction at the shared free anchors `x, t`
  at this rung — no new seam existential at the k=2 gate level.
- R1 scope decision above (:351 retirement deferred to 309 Phase 14).
- The Phase 2 spike's clause SIGNATURE (w/x threading) is BINDING on Phases 3–6 once GO —
  changing it afterwards is churn and triggers H6 convergence policing.

## Goals & Non-Goals

- **Goals**:
  - Zone-triage lemma reducing `hexclExt` to two per-side obligations (`zPastX3` @ `x1 < x`,
    `zFutT3` @ `x1 > t`).
  - Model-independent one-sided complement clauses `kvE2_extNegFut` / `kvE2_extNegPast` with
    `_sound` AND `_complete` per side, over the finite σ alphabet (both directions genuinely
    needed: `_sound` discharges `hexclExt`; `_complete` keeps the enriched gate's ⇐ half true).
  - Adjacent exterior brackets `kvE2_extBracketFut` / `kvE2_extBracketPast` + enriched composed
    gate `bracketEndChar_kvE2Ext` and discharge theorem
    `bracketEndChar_kvE2Ext_correct_two_prior_frag`.
  - Amended DoD (see R1 decision): `hexclExt` eliminated as an input obligation; 309-owned
    hypotheses still threaded.
- **Non-Goals**:
  - KampPrior.lean:351 retirement (deferred to 309 Phase 14 — R1 decision).
  - Discharging `hrealI`/`hrealB`/`hexcl` or the ∀k-lift composition (309 Phase 14).
  - The full uniform Prop 4.3 connective cases / general `VVecEA_m` negation (Prop43.lean
    blocker stands; only the exterior instances are built).
  - Multi-positive / full `On` generalization (deferred to the 321-N2 successor per 335
    handoff §4).
  - The general `(∃z1)`-form of Lemma 7.6 (only needed for the general Prop 4.3 induction).

## Source-to-Implementation Mapping (Tier 1 — Rabinovich 2014, page cites only)

Condensed from the research report's H3 table (authoritative version there); page numbers per
the sub-index citation rule.

| Rabinovich | Lean counterpart | Status | Plan phase |
|------------|------------------|--------|------------|
| Prop 4.2 p.6 (stmt), §5 pp.7–11 (proof) | `neg_2var_vec_ea` machinery (EANegationClosure.lean) | landed (feed machinery, NOT statement) | 2–6 consume |
| Lemma 5.3 p.8 | `fChainFrom`/`fChainPred`/`bracket_implies_fChainPred` (EANegation.lean:552/:567/:660) | landed | 2–6 consume |
| Cor 5.4 ⇐ p.9 | `hrealI` binder (OuterGate.lean:288) | landed (interior instance) | preserved |
| Cor 5.4(1)/(2) p.9 — one-sided exterior analogs | `kvE2_extNegFut`/`kvE2_extNegPast` + `_sound`/`_complete` | MISSING — the core | 2, 3, 4, 5, 6 |
| Prop 4.3 p.6–7 | exterior instances only (uniform case stays blocked) | atom/lt landed; exterior instances pending | 3, 5 |
| Def 7.5 p.13 | `kvE2_extBracketFut`/`kvE2_extBracketPast` | MISSING | 7 |
| Lemma 7.6 p.14 | enriched-gate conjunction at anchors `x, t` (degenerate adjacency) | MISSING | 7, 8 |
| Lemma 7.10 p.15 | TL-expressibility: `Until`/`Since`-navigated clause forms | MISSING | 2, 3, 5, 7 |
| Notation 5.2 / §5 interior bounding | `kvE2_sepInterior_exterior_notRealizable` (SW:12627) | landed (347 R1) | Phase 1 mirrors its transfer pattern |

## Risks & Mitigations

- **R2 — model-independence of one-sided complements (HIGH, the mathematical bet)**: the generic
  backward direction is B.1-obstructed; 348 bets the SPECIFIC one-sided σ-clauses evade it
  (Rabinovich's Cor 5.4 O_n construction is syntactic on the page). Mitigation: Phase 2 is a
  mandatory single-σ GO/NO-GO spike, both directions sorry-free, BEFORE any alphabet-indexed
  machinery. Explicit NO-GO protocol in Phase 2 — never left implicit.
- **R3 — depth-1 inner content of σ (MEDIUM)**: exterior σ carry inner witnesses over zones of
  `[x1,w,x,t]`. Mitigation: reuse the placement-generic inner-zone constants (SW:98–128) and the
  SubBracket2 `fChainPred` bridge (SubBracket2.lean:102); budgeted inside Phases 2–6, not
  rebuilt.
- **R4 — statement-shape debt (MEDIUM)**: see Postmortem "Do NOT cite `neg_2var_vec_ea`".
- **R5 — frozen-file discipline (LOW)**: all new work in new files; SharedWitness only below the
  SW:10210 banner if unavoidable; OuterGate additive only.
- **R6 — guard-shape plumbing (LOW)**: `¬(x ≤ x1 ∧ x1 ≤ t)` → `x1 < x ∨ t < x1` needs
  `push_neg`/`lt_of_not_le` on `M.carrier`'s linear order. Phase 1 verifies the `LinearOrder`
  instance is exposed (it is at SW:12784's `by_cases` sites) before writing the split.
- **Estimate inflation (process risk)**: hard cap — if any phase exceeds its line budget by >2x
  or stalls >4 h, STOP, commit green partial work, record exact goal state in the phase progress
  file, and split N.1/N.2 rather than pushing one oversized dispatch.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 (GO) |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 3, 4, 5, 6 |
| 6 | 8 | 1, 7 |

Phases within the same wave can execute in parallel. Territory (H7): Wave 1 — Phase 1 owns
`ExteriorZoneTriage.lean`, Phase 2 owns `ExteriorNegation.lean` (disjoint new files). Wave 3 —
Phase 4 owns `ExteriorNegation.lean`, Phase 5 owns `ExteriorNegationPast.lean` (disjoint).
Phases 3–8 are all conditional on Phase 2 returning GO.

### Phase 1: Exterior zone-determination lemma (residue triage) [COMPLETED]

- **Goal:** Land `kvE2_exterior_zone_determination` — the order-atom-only lemma forcing a
  realized exterior witness's zone marking:
  `nf_eval_nf M 1 4 [x1,w,x,t] σ → x < w → w < t → (x1 < x → nf0_zoneSpec σ.1 = kvE2_sep_zPastX3) ∧ (t < x1 → nf0_zoneSpec σ.1 = kvE2_sep_zFutT3)`,
  plus the corollary discharging every exterior-guarded σ NOT marked `zPastX3`/`zFutT3`
  (R1-style refutation from order atoms). This is the task's first sorry-free lemma (H2 bar).
- **File targets:** NEW file
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorZoneTriage.lean`
  (imports SharedWitness for zone constants; nothing frozen is edited).
- **Tasks:**
  - [x] Preflight re-verification (research H4 flagged Medium-trust): `lake build` full project
        green; `#print axioms` on `bracketEndChar_kvE2_correct_two_prior_frag`,
        `_sound_two_prior_frag`, `_complete_two_prior` = {propext, Classical.choice, Quot.sound}.
  - [x] Verify `LinearOrder`-style facts on `M.carrier` support the
        `¬(x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1` split (R6). *(verified: instance
        `OrderedMonadicStructure.carrier_order`, MonadicFO.lean:103-109; `not_and_or`/`not_le`
        used in `kvE2_exterior_zone_triage`)*
  - [x] Prove the zone-determination lemma by the SW:12642–12649 transfer pattern in reverse
        (depth-0 atom clause, NormalForm.lean:201–202; `lt_trans` chains through `x < w < t`).
        *(landed as `kvE2_exterior_zone_determination` + per-side `_past`/`_fut` workhorses +
        bit-transfer helpers `kvE2_zoneBit_below`/`_above`)*
  - [x] Corollary: under `hexclExt`'s guards, every σ with
        `nf0_zoneSpec σ.1 ∉ {zPastX3, zFutT3}` is not realizable at exterior `x1`.
        *(landed as `kvE2_exterior_offZone_notRealizable`, via the Phase-8-facing
        `kvE2_exterior_zone_triage` disjunction — deviation: additive extra lemma, the exact
        split shape Phase 8 consumes at SW:12788)*
- **Estimated output:** ~100–250 lines.
- **Done when:** `lake build` green; new declarations sorry-free; `#print axioms` on the new
  lemma clean; preflight checks recorded in progress file.
- **Timing:** 2–3 h.
- **Depends on:** none.

### Phase 2: R2 GO/NO-GO spike — one concrete future-side σ-clause [COMPLETED]

**SPIKE VERDICT: GO** (conditional-complete under the pinned gate inventory — the plan's
NO-GO-protocol step-2 sanctioned outcome, adopted as the BINDING signature for Phases 3-6).
Both directions (`kvE2_extNegFutSpike_sound`, `kvE2_extNegFutSpike_complete`) proved sorry-free
and axiom-clean `{propext, Classical.choice, Quot.sound}`. The R2-obstructed converse
(report-18 B.1) is EVADED for the specific one-sided finite σ-clause: the model-independence
crux `kvE2_futAnyBit_correct` (syntactic↔semantic zone-fact bridge) is proved outright, and
`_complete` reconstructs a full exterior realizer from a realized positive-existence form under
exactly two pins (`henv` anchor-base, `hbelow` qnf-zone-fact bridge) available at the sole
consumption site. File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean`
(839 lines). **BINDING SIGNATURE for Phases 3-6** (H6): `kvE2_extNegFut{Fut/Past} σ` with
`_sound` under `(hxw, hwt)` only and `_complete` under `(hxw, hwt, henv, hbelow)`; clause =
`(Until/Since-navigated positive local-existence form).neg`.

- **Goal:** For ONE concrete `zFutT3`-marked σ (implementer picks the simplest realizable
  representative of the `NormalForm sig 1 4` alphabet), construct a **model-independent**
  `Formula` (anchored at `t`, `Until`-navigated per Lemma 7.10 p.15) and prove BOTH directions
  sorry-free:
  `_sound : temporal_truth M atomMap t (clause σ) → ∀ x1, t < x1 → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ` and
  `_complete` (converse), under exactly the hypothesis inventory available at the gate
  (`h_UZ`/`h_SZ`, order bits, `sepPtW` eval at `w` — matching the `hexclExt` binder; derive
  `HasAttainedINF` via `prior_hasAttainedINF`, PriorINF.lean:224). Fix the exact w/x-threading
  SIGNATURE — it becomes BINDING for Phases 3–6.
- **File targets:** NEW file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean`
  (shared one-sided helpers + future side; imports EANegation, EANegationClosure, PriorINF).
- **Tasks:**
  - [x] Choose the spike σ; document why it is representative (must exercise depth-1 inner-zone
        content, R3 — not a degenerate σ). *(landed as `kvE2_futSpikeSigma`: a `zFutT3`-marked
        depth-1 σ whose inner layer genuinely prescribes all nine `[x1,w,x,t]` zones —
        below-t content tied to qnf via `kvE2_futAnyBit`, gap all-χmid, fresh χfr, ray empty;
        the correctness proofs exercise the full `nf_eval_depth1_fold_iff` fold.)*
  - [x] Build the clause via the Cor 5.4 O_n / F-chain device over `(t, ∞)`. *(deviation:
        built as the length-2 `Until`-navigated positive local-existence form
        `kvE2_futSpikePos` and its negation `kvE2_extNegFutSpike` — the Lemma 5.3 F-chain
        shape instantiated directly; the landed `fChain*` kit is reused conceptually but the
        finite length-2 instance is written explicitly for the spike, per H2 first-principles.)*
  - [x] Prove `_sound` and `_complete` for the spike σ, sorry-free. *(both landed, axiom-clean.)*
  - [x] Record GO/NO-GO verdict + the settled signature in the progress file and handoff JSON.
- **Estimated output:** ~150–400 lines.
- **Done when:** GO = both directions sorry-free, build green, axioms clean; verdict recorded.
- **NO-GO protocol (explicit — do not improvise):** If either direction cannot be closed:
  1. Commit all green partial work (constructions + whichever direction closed).
  2. Attempt ONE bounded narrowing (same dispatch, ≤1 h): weaken `_complete` to a conditional
     completeness under the gate-level hypotheses actually available at the sole consumption
     site (SW:12788 forward direction) — if that closes both needs, record the weakened contract
     as the binding signature and declare GO-conditional.
  3. If still NO-GO: STOP all Phase 3–8 work. Write the exact failing goal state (pretty-printed
     `lean_goal` output) into `specs/348_prop43_exterior_reflatten/handoffs/01_spike-no-go.md`,
     set task status [BLOCKED] via `update-task-status.sh`, and route to `/spawn 348` for a
     dedicated obstruction-analysis task. FORBIDDEN fallbacks: exterior-exclusion on the
     interior bracket (retired framing) and any vacuous per-model existential restatement.
- **Timing:** 3–4 h.
- **Depends on:** none (parallel with Phase 1; different file territory).

### Phase 3: Future-side clause family — construction + soundness [COMPLETED]

- **Goal:** Generalize the spike to the full finite alphabet:
  `kvE2_extNegFut (σ : NormalForm sig 1 4) : Formula` + `kvE2_extNegFut_sound` for ALL
  `zFutT3`-marked σ, using the Phase-2 BINDING signature verbatim.
- **File targets:** `Kamp/ExteriorNegation.lean` (extend).
- **Tasks:**
  - [x] Factor the spike construction into σ-generic helpers (per-σ inner-zone case analysis
        must be finite and mechanical — `Fintype`/`decide`-style dispatch or per-constructor
        case split, whichever the spike showed viable). *(landed as the σ-channel readers
        `kvE2_futGapBit`/`kvE2_futRayBit`/`kvE2_futSelfBit` + `Fintype`-filter lists
        `kvE2_futGapList`/`kvE2_futRayList`, the nine-zone classification
        `kvE2_futPossibleZones`/`kvE2_futZoneClass`, and the syntactic order-admissibility
        Bool `kvE2_futAdmissible` with `kvE2_futRealizer_admissible` — the mechanical
        list/filter dispatch over the finite alphabet the spike showed viable)*
  - [x] `kvE2_extNegFut` definition for all σ. *(= `(kvE2_futPos σ).neg`; `kvE2_futPos` =
        admissibility-gated disjunction over permutations of the gap-profile list of
        `D`-guarded `Until` chains (`kvE2_futChain`, the Cor 5.4 O_n device) ending in
        `kvE2_futEnd` (fresh profile + exact ray content `kvE2_futRayForm`); inadmissible
        σ get `⊥` — trivially-true clause, sound because a realizer forces admissibility.
        Signature verbatim per Phase 2: clause = (Until-navigated positive local-existence
        form).neg, no qnf parameter.)*
  - [x] `kvE2_extNegFut_sound` for all σ, sorry-free. *(deviation: additive strengthening —
        proved for ALL σ with NO `zFutT3`-marking hypothesis, since a σ realized at exterior
        `t < x1` is forced `zFutT3`-marked via Phase 1's
        `kvE2_exterior_zone_determination_fut`; hypotheses exactly `(hxw, hwt)` per the
        binding signature. Chain construction sorts occurrences by minimal-witness
        extraction (`kvE2_futMinPick`/`kvE2_futChainBuild`); axioms
        {propext, Classical.choice, Quot.sound}; commit a2c4a2552, +483 lines.)*
- **Estimated output:** ~300–500 lines.
- **Done when:** build green; `_sound` sorry-free and axiom-clean over the whole alphabet;
  no signature drift from Phase 2 (H6).
- **Timing:** 3–4 h.
- **Depends on:** 2 (GO).

### Phase 4: Future-side completeness [NOT STARTED]

- **Goal:** `kvE2_extNegFut_complete` for all `zFutT3`-marked σ:
  `(∀ x1, t < x1 → ¬ nf_eval_nf …) → temporal_truth … (kvE2_extNegFut σ)` (or the
  GO-conditional weakening fixed in Phase 2). Needed so the enriched gate's ⇐ half stays true
  (a realized `qnf` gives no exterior realizer for a bit-false σ, from which `_complete`
  re-establishes the clause).
- **File targets:** `Kamp/ExteriorNegation.lean` (extend).
- **Tasks:**
  - [ ] Prove `_complete` per the spike's template, generalized over σ.
  - [ ] Confirm the statement matches exactly what Phase 8's ⇐ extension will need (read
        OuterGate.lean:147 `bracketEndChar_kvE2_complete_two_prior` consumption shape first —
        read budget: that theorem + the fold's per-σ biconditional only).
- **Estimated output:** ~200–450 lines.
- **Done when:** build green; `_complete` sorry-free, axiom-clean, alphabet-complete.
- **Timing:** 3 h.
- **Depends on:** 3.

### Phase 5: Past-side mirror — construction + soundness [NOT STARTED]

- **Goal:** `kvE2_extNegPast σ : Formula` (anchored at `x`, `Since`-navigated) +
  `kvE2_extNegPast_sound` for all `zPastX3`-marked σ — the temporal mirror of Phase 3 on
  `(−∞, x)`, same BINDING signature modulo side.
- **File targets:** NEW file
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegationPast.lean` (imports
  ExteriorNegation for shared helpers; disjoint territory from Phase 4).
- **Tasks:**
  - [ ] Port σ-generic helpers to the past side (or generalize them side-parametrically in
        ExteriorNegation.lean ONLY if that file is not concurrently owned — if Wave 3 runs
        parallel, keep past-side copies local and deduplicate in Phase 7).
  - [ ] `kvE2_extNegPast` + `_sound`, sorry-free.
- **Estimated output:** ~300–500 lines.
- **Done when:** build green; past-side `_sound` sorry-free, axiom-clean, alphabet-complete.
- **Timing:** 3 h.
- **Depends on:** 3 (templates; runs parallel to 4 — disjoint files).

### Phase 6: Past-side completeness [NOT STARTED]

- **Goal:** `kvE2_extNegPast_complete` for all `zPastX3`-marked σ, mirroring Phase 4.
- **File targets:** `Kamp/ExteriorNegationPast.lean` (extend).
- **Tasks:**
  - [ ] Prove `_complete` on the past side per the Phase-4 template.
- **Estimated output:** ~200–400 lines.
- **Done when:** build green; sorry-free, axiom-clean, alphabet-complete.
- **Timing:** 2–3 h.
- **Depends on:** 4, 5.

### Phase 7: Adjacent exterior brackets + enriched composed gate formula [NOT STARTED]

- **Goal:** Def 7.5 / Lemma 7.10 shapes: `kvE2_extBracketFut atomMap h_surj P qnf : Formula` —
  conjunction over `zFutT3`-marked σ: bit-true → positive `Until`-navigated existence clause
  ("some `x1 > t` realizes σ", Lemma 7.10 p.15 / Prop 3.5-style formalization); bit-false →
  `kvE2_extNegFut σ`. Mirror `kvE2_extBracketPast`. Define the enriched gate
  `bracketEndChar_kvE2Ext … := bracketEndChar_kvE2 … ∧ extBracketPast @ x ∧ extBracketFut @ t`
  (degenerate Lemma 7.6 p.14 composition at the shared anchors) plus per-side bridge lemmas
  (bracket holds at anchor ↔ per-σ clause conjunction holds).
- **File targets:** NEW file
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`.
- **Tasks:**
  - [ ] Positive existence clauses per side (bit-true σ).
  - [ ] Bracket definitions per side + enriched-gate definition.
  - [ ] Bridge lemmas unfolding bracket-at-anchor to per-σ `_sound`/`_complete`/existence
        conjuncts (the exact shapes Phase 8 consumes).
  - [ ] Deduplicate any Phase-5 helper copies if trivially unifiable (skip if not — churn bar).
- **Estimated output:** ~300–500 lines.
- **Done when:** build green; definitions + bridge lemmas sorry-free, axiom-clean.
- **Timing:** 3–4 h.
- **Depends on:** 3, 4, 5, 6.

### Phase 8: Discharge theorem + wiring + closeout [NOT STARTED]

- **Goal:** `bracketEndChar_kvE2Ext_correct_two_prior_frag`: assuming the enriched gate holds
  (+ `hfrag`, `hrealI`, `hrealB`, `hexcl`, order bits, `h_UZ`/`h_SZ` — the 309-owned inventory
  ONLY), conclude the gate biconditional with `hexclExt` discharged internally: Phase 1 triage
  splits the exterior residue per side; `_sound` per side closes it; the ⇐ half extends
  `bracketEndChar_kvE2_complete_two_prior` (OuterGate.lean:147) with `_complete` per side.
  `hexclExt` disappears as an input obligation — the amended DoD.
- **File targets:** `NfMultiAnchorBridge/ExteriorBracket.lean` (theorem); `Kamp/Prop43.lean`
  (doc-comment only: blocker note now points at the landed exterior instances);
  `Kamp/KampPrior.lean` (doc-comment only, adjacent to :351: records that 348's theorem is
  landed and retirement awaits 309 Phase 14 — no code change).
- **Tasks:**
  - [ ] Prove the discharge theorem by calling `bracketEndChar_kvE2_correct_two_prior_frag`
        (OuterGate.lean:359) with `hexclExt := ` (Phase 1 triage ∘ per-side `_sound`).
  - [ ] Extend the ⇐ half with per-side `_complete` (enriched gate re-established from a
        realized `qnf`).
  - [ ] `#print axioms` on the new theorem = {propext, Classical.choice, Quot.sound};
        `grep -rn "sorry"` over all new files = none.
  - [ ] Doc-comment updates (Prop43.lean blocker note; KampPrior.lean:351 transfer note).
  - [ ] Write implementation summary + final handoff JSON for 309 (what to consume, the R1
        transfer, the theorem name and hypothesis inventory).
- **Estimated output:** ~200–400 lines.
- **Done when:** full-project `lake build` green; discharge theorem sorry-free and axiom-clean;
  amended DoD met; summary + handoff written.
- **Timing:** 3 h.
- **Depends on:** 1, 7.

## Testing & Validation

- [ ] Per phase: `lake build` (full project) green — no phase commits red.
- [ ] Per phase: `#print axioms` (via `lean_verify` or `lake env lean`) on every new theorem =
      {propext, Classical.choice, Quot.sound} exactly; no `sorryAx`.
- [ ] Per phase: `grep -n "sorry" <new files>` empty (live paths).
- [ ] Phase 8 regression: `#print axioms` re-run on the three preserved 335 gate theorems
      (unchanged) and on `kvE2_outer_fold_frag`.
- [ ] Frozen-file check at closeout: `git diff` shows `SharedWitness.lean` / `SubBracket2V.lean`
      byte-unchanged (or additions strictly below the SW:10210 banner with justification).
- [ ] Convergence check (H6): Phase 2's binding signature appears verbatim in Phases 3–6
      statements (modulo side); any drift is logged as churn.

## Artifacts & Outputs

- plans/01_prop43-exterior-reflatten.md (this file)
- New Lean files:
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorZoneTriage.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegationPast.lean`,
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`
- Doc-comment-only touches: `Kamp/Prop43.lean`, `Kamp/KampPrior.lean` (Phase 8)
- Progress files per phase: `specs/348_prop43_exterior_reflatten/progress/phase{1..8}-*.md`
- On NO-GO only: `specs/348_prop43_exterior_reflatten/handoffs/01_spike-no-go.md`
- Summary: `specs/348_prop43_exterior_reflatten/summaries/01_prop43-exterior-reflatten-summary.md`
- Final handoff for 309: `specs/348_prop43_exterior_reflatten/handoffs/02_enriched-gate-for-309.md`

## Rollback/Contingency

- All new work is in NEW files: rollback of any phase = `git revert` of that phase's commits (or
  file deletion + import removal); the landed 335/346/347 state is untouched by construction.
- Commit-per-green-substep (H9): every sorry-free lemma is committed as it lands
  (`task 348 phase P.O: {objective}`); a failed dispatch never strands more than one objective.
- Spike NO-GO: Phase 2 protocol (commit green partials, [BLOCKED], `/spawn 348`) — Phases 3–8
  are never started.
- Oversized phase: stop at budget, commit green work, split N.1/N.2 in a plan revision rather
  than one inflated dispatch (H8 splitting rule).
- If Phase 8's ⇐ extension exposes a gap in `_complete`'s statement shape: do NOT weaken the
  gate biconditional silently — revise Phase 4/6 statements in a plan revision with the exact
  goal state recorded.
