# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v10

> **Revision provenance (v10, 2026-07-14, reviser-agent).** Revised from v9
> (plans/09_offdiag-fi-chain-v9.md) to consume the **now-LANDED successor tasks 349 and 350**,
> which resolve v9's Track-B blocker `P18b-endChar-recursive-core-unbuilt`
> (`.orchestrator-handoff.json`, 2026-07-11) exactly as that handoff's own resolution clause
> prescribed:
> - **Task 349 (COMPLETED, archived)** — the recursive endChar navigated arity-3 endpoint
>   primitive. Landed name mapping (Base.lean:991 doc-hook): the planned `endChar :
>   EndCharCarrier sig k` / `endChar_correct` is REALIZED as `endInterval` /
>   `endInterval_correct` on carrier `BracketEndCharCarrierV` (genuine `Nat.rec`, three `rfl`
>   reductions certified), `NfMultiAnchorBridge/EndIntervalConsumerK.lean`, whole-tree GREEN
>   (1736 jobs), axiom-clean. Do NOT hunt for a literal `endChar_correct` — it does not exist
>   under that name. See `specs/archive/349_*/summaries/09_consume-interior-gate-general-k-summary.md`.
> - **Task 350 (COMPLETED)** — the ∀-qnf aggregate quantEnd/seg construction + the SIX arm-hook
>   discharge lemmas `kampArm_{past,diag,future}_{k0,k1}(_correct)`, all sorry-free on exactly
>   `[propext, Classical.choice, Quot.sound]` (22-item axiom transcript). The k=1 pair's blocker
>   `blk-350-p4-offdiag-k1-aggregate` is CLOSED (`VVecEA2.conjFull_iff`). See
>   `specs/350_*/summaries/03_negfix-refactor-exterior-carriers-summary.md` §1/§5 (the explicit
>   task-309 consumption instructions this v10 encodes).
> - **Already-landed intermediate consumption (task 358, commit 8a7d504ec)**: the ambient-k=0
>   arm closure `kampPrior_case1_arm_k0` (KampPrior.lean:1668) ALREADY consumes the 350 k=0
>   triple through the Phase-18a skeleton `kampPrior_case1_trichotomy_assemble`
>   (KampPrior.lean:1146 — the handoff's ":1056", drifted by task-358 additions). The k=1
>   analog and the `:361` narrowing itself remain UNBUILT — they are this v10's open work.
>
> **Scope honesty (binding)**: tasks 349/350 resolve TRACK B only. The independent Track-A
> blocker `P17-frozen-interface-gap` (hrealI/hrealB anchor-content interface gap; convergent
> three-agent finding, v9 Phase 17) is NOT resolved — it feeds the **k ≥ 2 residue** and is now
> embodied in the BLOCKED successor task 358 (realization recursion at the `:361`/`:364` seam)
> plus the rungK seam obligations (349 ledger rows 5-6, 8-11). This v10 therefore scopes the
> achievable deliverable as the **k ≤ 1 narrowing** of `:361` (blanket sorry →
> `match k with | 0 => _ | 1 => _ | k+2 => sorry`) with a clearly-marked k≥2 residual phase —
> NOT full retirement.

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [PLANNED]
- **Effort**: ~2-5 hours remaining (Phases 20-21; ~80-200 lines of Lean total, each phase one H8-bounded agent run)
- **Dependencies**: 310, 311, 320, 333, 335, 346, 348 (all COMPLETE, carried from v9); **349 (COMPLETE — recursive endChar core, landed as the `endInterval` stack)**; **350 (COMPLETE — aggregate quantEnd/seg + six `kampArm_*` arm-hook lemmas)**. All nine dependencies resolved. Task 358 is NOT a dependency of the k≤1 scope — it is the named successor for the k≥2 residue.
- **Research Inputs**:
  - reports/01-05, 07 + 347/335/348 handoff inputs (carried verbatim from v9 metadata — see plans/09:36-46)
  - `specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json` (2026-07-11 — the two-blocker record this v10 re-scopes against; Track B RESOLVED, Track A OPEN)
  - **`specs/350_.../summaries/03_negfix-refactor-exterior-carriers-summary.md`** (**v10 revision authority** — deliverable↔consuming-site name map §1; task-309 Phase-18b consumption instructions §5; axiom transcript §2)
  - **`specs/archive/349_.../summaries/09_consume-interior-gate-general-k-summary.md`** (**v10 revision authority** — the `endInterval` stack, the EndCharCarrier→BracketEndCharCarrierV name mapping, the 11-obligation disposition ledger routing rows 1-6/8-11 to 309-Phase-14/358)
- **Artifacts**:
  - plans/01-03, 05-08 (v1-v8, superseded — lineage recorded in v8/v9 §Overview)
  - plans/09_offdiag-fi-chain-v9.md (v9, superseded — its Phase-17-feeds-Phase-18 sequencing and its Phase-19 GO-full/GO-k1 routing are re-scoped by the 349/350 landings and the corrected arm indexing; its history sections remain the verbatim record for Phases 1-18a)
  - plans/10_offdiag-fi-chain-v10.md (this file, v10)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md, 04_spawn-analysis.md, 05_k2-vocab-enrichment-redesign.md, 347/reports/01_bracket-faithfulness-adjudication.md, 335/handoffs/03_frag-gate-for-309-and-348.md, 348/handoffs/02_enriched-gate-for-309.md, 350/summaries/03_negfix-refactor-exterior-carriers-summary.md, 349/summaries/09_consume-interior-gate-general-k-summary.md, 309/.orchestrator-handoff.json

## Overview

**Goal of the remaining work**: NARROW the `KampPrior.lean:361` strategic sorry (the `| 1 =>`
n=1 arm of `nf_nvar_exist_all_depths`, inside the `k+1` depth branch; goal per
`sub_nf : NormalForm sig (k+1) 2`: `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔
∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`) from a blanket
`sorry` to

```lean
match k with
| 0     => kampPrior_case1_arm_k0 atomMap h_surj sub_nf          -- LANDED (task 358)
| 1     => kampPrior_case1_arm_k1 atomMap h_surj sub_nf          -- Phase 20 (this plan)
| k + 2 => sorry  -- NARROWED residual: Track A (hrealI/hrealB interface gap) → task 358
```

discharging the k=0 and k=1 arms by CITING the landed task-350 arm lemmas by name through the
landed Phase-18a skeleton — and leaving the `k+2` arm as an explicitly documented, narrowed
residual gated on the independent Track-A blocker (task 358 + the rungK seam obligations).

**Why this is now a small task**: everything the v9 Phase-18b STRUCTURAL FINDING identified as
unbuilt frontier work has landed externally:
- the recursive endChar core → task 349 (`endInterval`/`endInterval_correct`);
- the ∀-qnf aggregate quantEnd/seg + the six arm-hook discharges at k=0/k=1 → task 350
  (`kampArm_{past,diag,future}_{k0,k1}_correct`);
- the k=0 assembly pattern → task 358's `kampPrior_case1_arm_k0` (KampPrior.lean:1668),
  which is the EXACT recipe Phase 20 mirrors at k=1 (its own docstring says so: "The
  ambient-k=1 instance follows the IDENTICAL recipe once task 350's off-diagonal k=1 pair
  lands" — it has now landed).

Note the hook decomposition v9 planned (threading `h_quant` binders of
`nf_char2_{past,future}_formula_correct`) was **machine-refuted** (task 350 R1/R2,
`AggregateHookDischarge.lean:12-43`); the sanctioned route is Route V — consume the
SKELETON-SHAPED arm conclusions by name (350 summary §5 instruction 1). Do not thread
`h_quant`.

**Achievable definition of done (v10)**: full `lake build` GREEN; the new named lemmas
(`kampPrior_case1_arm_k1` and any wiring) each `lean_verify` = exactly
`[propext, Classical.choice, Quot.sound]`; the `:361` blanket sorry replaced by the k-match
with k=0/k=1 closed and EXACTLY ONE narrowed residual sorry at `k+2` carrying an inline
successor note (task 358 / Track A); `:364` untouched; file sorry-token count unchanged at 2;
frozen provider territory byte-unchanged. Full sorry-free retirement of
`nf_nvar_exist_all_depths` is EXPLICITLY OUT OF SCOPE — it completes only when the Track-A
successor lands the k≥2 realization recursion.

**Plan lineage summary (v1 → v10).** v1-v8: see v9 §Overview (verbatim record). v9: provider
chain (335/348) consumed; Phases 15/16 landed; Phase 18a skeleton landed; Phase 17 hit the
Track-A interface gap (convergent finding); Phase 18b hit the Track-B unbuilt-recursive-core
wall → BLOCKED with two-successor handoff. **v10**: both Track-B successors (349, 350) landed
sorry-free; the k=0 arm closure landed intermediately (358); open work re-scoped to the k=1
arm closure + the k≤1 `:361` narrowing (Phases 20-21); Track A honestly deferred (k≥2
residual → task 358).

### Research Integration

All v6-v9 integration records (F1-F4, A1/A2, guards, the 347 adjudication, the v9 ∀k-lift
option-(a) decision, the Phase-15 corrected arm indexing) are carried unchanged — see
plans/09 §Research Integration and §∀k-Lift Composition Decision. **New in v10 (the two
landed-successor summaries + the blocker handoff):**

1. **Track B RESOLVED.** The six DoD arm lemmas + `aggPop1_correct` + the P1/P2/P3 primitive
   stack landed (task 350; axiom transcript items 1-22 all exactly the three standard axioms).
   The k=1 `_correct` conclusions match the `kampPrior_site_trichotomy` disjunct shapes
   VERBATIM — certified by the `ShapeCertificatesK1` examples in `AggregateOffDiagK1.lean`
   (at `sub_nf1 : NormalForm sig (1 + 1) 2`, the generic-site index). No shape bridging is
   needed at the consumption site.
2. **The recursive endChar core landed under a different name.** `endInterval` /
   `endInterval_correct` / `EndIntervalCorrectPrior` (`EndIntervalConsumerK.lean`, task 349
   consuming 355/356/357/360). 309 consumes it INDIRECTLY (it underlies the 350 arm stack);
   direct citation only appears in the k≥2 residual routing (the m+2 arm's obligations rows
   1-6/8-11 are the 358 seam).
3. **Track A NOT resolved.** `P17-frozen-interface-gap` stands: `hrealI`/`hrealB`
   (OuterGate:374/:380) need x/t anchor content the frozen producer chain drops
   (`kvE2_sepPtW` is a point-type at `w`). It feeds ONLY the k≥2 residue. Its discharge task
   is 358 (BLOCKED), which also owns `:364` and the general-m slice obligations.
4. **Seam/territory clarification (new, binding — see guard V10-3).** Task 358 has landed
   ADDITIVE material in KampPrior.lean (`kampPrior_case1_arm_k0`) and its own plan
   contemplates an eventual arm rewrite. Per the orchestrator's revision directive
   (2026-07-14), the **k≤1 narrowing of `:361` is 309's territory** — it is exactly what 350
   deliberately did not touch and what the 309 blocker handoff scoped as the post-successor
   step. The k+2 residual, `:364`, and the general-k realization recursion remain 358
   territory. Phase 21 carries a pre-edit coordination check so the two tasks cannot collide.

### Corrected Anchor-Cap Statement (CARRIED FORWARD; still binding)

Carried verbatim from v8/v9: anchors strictly `{x,t}` (≤2, Rabinovich cap; G2/G4);
`nf_char3_deeper_split` FORBIDDEN; the task-347 corrected model settled; the raw fresh-witness
`∃` of `nf_eval_nf` is NOT bounded in place.

## Preserved / Live Assets (consume — do NOT rebuild)

The full v8/v9 asset tables are carried unchanged (plans/08:256-310, plans/09:164-191).
**NEW rows (the landed 349/350/358 material — frozen or additive-landed territory, consume BY
NAME):**

### Lemma-name → consuming-site table (the v10 consumption contract)

| Landed lemma (namespace `Bimodal.Metalogic.WeakCanonical.Kamp`) | File | Consuming site in this plan |
|---|---|---|
| `kampArm_past_k0` / `_correct`, `kampArm_diag_k0` / `_correct`, `kampArm_future_k0` / `_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` | ALREADY consumed by `kampPrior_case1_arm_k0` (KampPrior.lean:1668, task 358) — cited by the Phase-21 `| 0 =>` match arm |
| `kampArm_diag_k1` / `kampArm_diag_k1_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` (:2098) | Phase 20 — diagonal disjunct of `kampPrior_case1_arm_k1` |
| `kampArm_past_k1` / `kampArm_past_k1_correct` | `NfMultiAnchorBridge/AggregateOffDiagK1.lean` (:1467) | Phase 20 — past disjunct (shape certified verbatim by `ShapeCertificatesK1`) |
| `kampArm_future_k1` / `kampArm_future_k1_correct` | `NfMultiAnchorBridge/AggregateOffDiagK1.lean` (:1495) | Phase 20 — future disjunct |
| `kampPrior_case1_trichotomy_assemble` (Phase-18a skeleton, task 309) | `KampPrior.lean:1146` | Phase 20 — the or_congr assembly engine (instantiated at k=1) |
| `kampPrior_case1_arm_k0` (task 358) | `KampPrior.lean:1668` | Phase 20 — the recipe template (mirror verbatim at k=1); Phase 21 — the `| 0 =>` arm |
| `kampPrior_site_trichotomy` + Phase-15 site lemmas | `KampPrior.lean:677` (+ :646-798 region) | consumed inside the skeleton; no new use needed |
| `endInterval_correct` / `endInterval_step_correct` / `EndIntervalCorrectPrior` (task 349; the delivered realization of the planned `endChar`/`endChar_correct`) | `NfMultiAnchorBridge/EndIntervalConsumerK.lean` (:220/:185/:97) | consumed INDIRECTLY (underlies the 350 arm stack); cited by name only in the Phase-21 residual note (k≥2 routing rows 1-6/8-11 → task 358) |
| `aggPop1_correct`, `CExtPast_correct`, `CExtFut_correct`, `VVecEA2.conjFull_iff`, `negFix_iff` family, `concatPin_holds_iff` family | `AggregateOffDiagK1.lean`, `ExteriorNav{Past,Fut}K1.lean`, `VecEAConjFull.lean`, `EANegationFix/*` | interior machinery of the 350 arm lemmas — NOT consumed directly by 309; listed to bar rebuilding |

**Import note (350 summary §5.3)**: `import …Kamp.NfMultiAnchorBridge` (the aggregator) already
reaches everything; KampPrior.lean already imports it. NO new import is expected. Never create
a leaf → aggregator import (acyclicity, 350 Phase 17).

**Frozen-territory rule (v10 — extends V9-1)**: the seven v9 provider files
(`SharedWitness`, `SubBracket2V`, `OuterGate`, `ExteriorBracket`, `ExteriorZoneTriage`,
`ExteriorNegation`, `ExteriorNegationPast`) PLUS the 349/350/355/356/357/360 stack
(`InteriorGateGeneralK`, `ExteriorGateAssembleK`, `ExteriorBracketAssembleK`,
`EndIntervalConsumerK`, `ExteriorBracketK`, `ExteriorPinnedConverse{,Past}K`,
`AggregateHookDischarge`, `AggregateOffDiagK1`, `AggregatePointMergeK1`,
`ExteriorFiberKitK1`, `ExteriorNav{Past,Fut}K1`, `VecEAConjFull`, `EANegationFix.lean` +
`EANegationFix/*`, `Base.lean`) are consume-only for this task. ALL 309 edits confine to
`KampPrior.lean` (additive lemma in Phase 20; the single `:361` match rewrite in Phase 21).

### Source-to-Implementation Mapping (H3, Tier 1)

The v8/v9 tables are carried unchanged. v10 updates the live rows:

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|---|---|---|---|
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms, k=1 aggregate | p.9 | `kampArm_{past,future}_k1_correct` — **LANDED (350), consumed by name** | 20 |
| Lemma 3.4 iff-form conjunction (population match) | p.4 | `VVecEA2.conjFull_iff` — **LANDED (350)**, interior to the arm lemmas | — (barred from rebuild) |
| Trichotomy over anchor order patterns | p.9 | `kampPrior_site_trichotomy` + `kampPrior_case1_trichotomy_assemble` — LANDED (309 P15/P18a) | 20-21 |
| Cor 5.4 inf/sup within-bracket bounded witness selection (general k) | p.9 l.263-273 | the k≥2 realization recursion — **DEFERRED, task 358** | 21 residual note |

## Postmortem Constraints

Guards G1-G6 (+ amendments), rules N1-N5, v7 Amendment F3, the v8 corrected-model constraints,
and v9 Amendments V9-1..V9-5 are carried VERBATIM (plans/08:337-507, plans/09:207-245) and
remain binding, with V9-1's frozen list extended per the v10 Frozen-territory rule. v10 adds:

**v10 Amendments (NEW):**

- **V10-1 (Route V — no hook threading)**: do NOT thread the `h_quant`/`h_past`/`h_fut`/
  `h_diag` binders of `nf_char2_{past,future}_formula_correct` / `A_diag_correct`
  (Base.lean:1230/:758/:1430) — the literal `(quantEnd, seg)` hook decomposition is
  machine-refuted (350 R1/R2, `AggregateHookDischarge.lean:12-43`). Consume the
  skeleton-shaped `kampArm_*_correct` conclusions by name (350 summary §5.1).
- **V10-2 (name-mapping discipline)**: the task-349 deliverable is `endInterval` /
  `endInterval_correct` on `BracketEndCharCarrierV` — there is NO `endChar_correct`
  declaration. Any dispatch text or residual note citing the 349 core MUST use the landed
  names (Base.lean:991 doc-hook is the citation map).
- **V10-3 (358-seam coordination)**: before editing `:361`, verify by `git log`/grep that no
  intervening task-358 commit has already narrowed or rewritten the arm; if it has, Phase 21
  degrades to verification + record (no double edit). Do NOT touch `:364` (358 territory), do
  NOT touch `kampPrior_case1_arm_k0` (landed 358 material), and the `k+2` residual note MUST
  name task 358 (and the Track-A `P17-frozen-interface-gap` blocker id) as the successor —
  mirroring the 348 transfer-note pattern at `:352-360`.
- **V10-4 (sorry-count discipline)**: the Phase-21 edit replaces ONE blanket sorry with ONE
  narrowed sorry inside the new `match k` — KampPrior.lean's sorry-token count stays exactly 2
  (`| k+2 =>` residual + `:364`-region). No other new sorry anywhere. `nf_nvar_exist_all_depths`
  remains `sorryAx`-dependent by design until 358 lands — the v9 Phase-19 GO-full axiom bar
  (`no sorryAx` on the recursion) is NOT this plan's DoD and MUST NOT be claimed.
- **V10-5 (honest completion language)**: on Phase-21 success the task closes as
  **k≤1-narrowing COMPLETE with a documented k≥2 residual** — the summary and handoff must
  state the residual and the successor (358) explicitly; never "sorry retired" without the
  k≤1 qualifier.

**Do NOT** (headline items, carried in full from v8/v9): no arity-1 collapse (G1); no third
anchor (G2/G4); no `nf_char3_deeper_split`; no chain-step tactic shortcuts (G5); no edits to
any landed asset or F-record; no consumption of EANegation `:1090`/`:1249`; no domain axioms;
no in-place bounding of the fresh-witness `∃`; no import cycles; no `hexclExt` resurrection
(V9-2); no re-shaping of `nf_nvar_exist_all_depths`'s statement (V9-4).

**Design decisions SETTLED (do not re-open)**: all v8/v9-settled items, plus: the arm-hook
route is Route V (skeleton-shaped conclusions; 350/358 machine finding); the 349 core is
consumed as `endInterval_*` (V10-2); the k≤1/k≥2 scope split (this v10, per the orchestrator
directive and the Phase-15 corrected arm indexing — the k≥2 arms were ALWAYS the residual
under GO-k1; the 349/350 landings move the k=0/k=1 arms from "blocked" to "assemble now").

## v9 → v10 Phase Mapping

| v9 phase | v9 status | v10 disposition |
|---|---|---|
| 1-13.35 (+ retired 13.4/14) | [COMPLETED]/records | **Survive verbatim** (records in v8/v9; not re-listed here) |
| 15 (site/coverage probe, GO-k1 verdict) | [COMPLETED] | **Survives verbatim** (record below). Its corrected arm indexing is v10's scaffolding |
| 16 (ExistProviders shim) | [COMPLETED] | **Survives verbatim** (record below). NOT needed for the k≤1 arms (they carry no obligations); pays at the k≥2 seam (358 ledger rows 1-2) |
| 17 (hrealI/hrealB/hexcl discharge) | [BLOCKED] | **SUPERSEDED — DEFERRED OUT OF 309 SCOPE.** The convergent finding stands: an interface gap in frozen territory, not a 309-dischargeable proof. It feeds ONLY the k≥2 residue; its discharge site is task 358 (349 ledger rows 5-6). Never dispatch under this heading; record preserved below |
| 18 (18a skeleton + 18b hook discharge) | [PARTIAL] | **18a survives [COMPLETED]** (skeleton landed :1146). **18b SUPERSEDED**: its unbuilt-frontier content landed EXTERNALLY (349 core + 350 arm lemmas + 358 k=0 assembly); the residual 309-owned slice (k=1 assembly) is re-scoped as **Phase 20** |
| 19 (∀k lift + `:361` retirement) | [NOT STARTED] | **SUPERSEDED — RE-SCOPED as Phase 21** (the k≤1 narrowing). v9's GO-k1 branch anticipated exactly this shape ("narrowed, documented strategic sorry + follow_up_task"); the successor is now NAMED (358) and the escalation is the orchestrator directive itself — no further AskUserQuestion gate is required to land the pre-committed residual |

## Goals & Non-Goals

**Goals:**
- Build the ambient-k=1 arm closure `kampPrior_case1_arm_k1` by mirroring the landed
  `kampPrior_case1_arm_k0` recipe over the task-350 k=1 triple (Phase 20).
- **Narrow the `KampPrior.lean:361` blanket sorry** to the k-match with k=0/k=1 discharged by
  name and a single documented `| k+2 =>` residual sorry naming task 358 (Phase 21).
- Full-tree GREEN; axiom-clean new lemmas; sorry count unchanged at 2; honest completion
  record per V10-5.

**Non-Goals:**
- Closing the `| k+2 =>` residual or `:364` (task 358 scope — Track A + realization recursion).
- Discharging `hrealI`/`hrealB`/`hexcl` (v9 Phase 17 — interface gap, 358 scope).
- Rebuilding ANY 349/350/355/356/357/360 material (frozen; consume by name).
- Re-opening the hook-threading route (V10-1), the kvE' carrier (V9-3), the monolithic gate
  (F3/F4/347), or the multi-positive/full-`On` generalization (321-N2 successor).
- Consuming the kvE2Ext gate at the k≤1 arms — the Phase-15 corrected indexing settled that
  the k=0/k=1 arms do NOT consume the gate; it pays at k=2 within the 358 seam.

## Risks & Mitigations

- **Risk (Low-Medium): shape mismatch at the k=1 assembly.** The `kampArm_*_k1_correct`
  conclusions are stated at `NormalForm sig 2 2` / `nf_eval_nf M 2 2`, while the match arm
  sees `sub_nf : NormalForm sig (1+1) 2`. **Mitigation**: the `ShapeCertificatesK1` examples
  (`AggregateOffDiagK1.lean:1518-1536`) certify the disjunct shapes verbatim AT the
  generic-site index `1 + 1` with no KampPrior import — defeq holds; if elaboration balks,
  `show`-normalize the index, never restate the arm lemmas.
- **Risk (Low): the trichotomy skeleton's binder shapes drifted.** **Mitigation**: the
  identical recipe is ALREADY GREEN at k=0 (`kampPrior_case1_arm_k0`, :1668) — copy its
  application shape exactly; the assemble lemma is generic in `k`.
- **Risk (Low-Medium): territory collision with task 358 at `:361`.** 358's own plan
  contemplates an arm rewrite (its Phase 9, gated on the k=1/general-k folds).
  **Mitigation**: V10-3 pre-edit coordination check; the narrowing is additive-in-effect
  (the `| k+2 =>` residual preserves 358's remaining seam exactly); the residual note names
  358 so the successor dispatch finds an unambiguous target. 358 is currently [BLOCKED], so
  no concurrent dispatch exists.
- **Risk (Low): line-number drift in citations.** :361/:364 are current at HEAD; :1146/:1668
  verified 2026-07-14. **Mitigation**: every dispatch re-greps by NAME
  (`kampPrior_case1_trichotomy_assemble`, `kampPrior_case1_arm_k0`) before editing; names,
  not lines, are the contract.
- **Risk (Low): silent scope creep toward the k≥2 arm.** **Mitigation**: V10-4/V10-5; the
  residual sorry is pre-committed and the DoD language is fixed; any attempt to discharge
  `| k+2 =>` in-task is a guard violation (it requires the 358 interface work).

## Implementation History (landed / superseded — NOT open work)

None of these match the orchestrator open-phase heading-scan. Do not re-dispatch. Full
verbatim records: plans/08:601-1139 (Phases 1-13.35), plans/09:395-624 (Phases 15-18).

### Phase 15: Site/coverage probe — GO-k1 verdict + corrected arm indexing [COMPLETED]
Commit 765054d5a. Seven sorry-free site lemmas (KampPrior:646-798); rung certificates
arm 0/1 unconditional, arm 2 = kvE2Ext gate (fragment-scoped), arms ≥3 no rung. The corrected
indexing is v10's scaffolding: the k≤1 arms carry NO gate and NO provider obligations.

### Phase 16: ExistProviders instantiation shim [COMPLETED]
Commits 14608ddc7/bfe51fcbc. Six axiom-clean declarations (KampPrior tail). Consumed at the
k≥2 seam (358 ledger rows 1-2), NOT by Phases 20-21.

### Phase 17: Provider-obligation discharge — hrealI / hrealB / hexcl [BLOCKED — SUPERSEDED, deferred to task 358; do not dispatch]
The 2026-07-12 convergent three-agent finding stands (plans/09:527-541 verbatim record):
`hrealI`/`hrealB` are NOT dischargeable from their frozen obligation binders — the producer
chain drops the x/t anchor content (`kvE2_sepPtW` is a point-type at `w`). This is the
Track-A blocker `P17-frozen-interface-gap` (.orchestrator-handoff.json), UNRESOLVED by
349/350. It feeds ONLY the k≥2 residue; discharge site: task 358 (349 obligation ledger rows
5-6, plus slice rows 8-11 at general m). No 309 dispatch may re-attempt it (frozen territory,
V9-1/v10 extension).

### Phase 18: Enriched-gate consumption + hook discharge + depth-2 assembly [PARTIAL — 18a COMPLETED; 18b superseded by external landings; residue re-scoped as Phase 20]
- **18a LANDED** (commit 53a3cd2cd): `kampPrior_case1_trichotomy_assemble` (KampPrior:1146) —
  the or_congr skeleton, generic in `k`, axiom-clean.
- **18b's structural finding RESOLVED EXTERNALLY**: the unbuilt recursive endChar core →
  task 349 (`endInterval` stack); the ∀-qnf aggregate + arm-hook discharges at k=0/k=1 →
  task 350 (six `kampArm_*` lemmas); the k=0 assembly → task 358 (`kampPrior_case1_arm_k0`,
  :1668, commit 8a7d504ec). The v9 18b heading is retired; the sole remaining 309-owned
  slice (k=1 assembly) is Phase 20. Do not dispatch under this heading.

### Phase 19 (v9): ∀k lift + `:361` retirement [NOT STARTED — SUPERSEDED; re-scoped as Phase 21; do not dispatch under this heading]
v9's GO-k1 routing anticipated the exact v10 shape (narrowed residual + named successor).
Superseded because: (i) the k=0 arm landed externally (358); (ii) the escalation the GO-k1
residual required has been executed at the orchestrator level (the 309 blocker handoff +
spawn of 349/350 + this revision directive); (iii) the successor is now a NAMED EXISTING task
(358), not a to-be-spawned one.

## Implementation Phases (open work — Phases 20-21)

**Dependency Analysis (v10):**

| Wave | Phases | Blocked by |
|---|---|---|
| 1 | 20 (k=1 arm closure, additive) | — (all inputs landed: 350 k=1 triple, 18a skeleton, k=0 template) |
| 2 | 21 (`:361` k≤1 narrowing + verification) | 20 |

Strictly sequential (21 cites 20's lemma by name). Edit territory: `KampPrior.lean` ONLY.
One agent run per phase (H8). The orchestrator dispatches exactly one open phase per cycle by
heading-scan.

### Phase 20: Ambient-k=1 arm closure `kampPrior_case1_arm_k1` (additive; no `:361` edit) [COMPLETED]

- **Goal:** Land the ambient-k=1 analog of `kampPrior_case1_arm_k0` — the `| 1 =>` arm
  statement of `nf_nvar_exist_all_depths` at ambient `k = 1`
  (`sub_nf : NormalForm sig 2 2`):
  ```
  ∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔
    ∃ env : Fin 1 → M.carrier, nf_eval_nf M 2 2 (insertEnv env t) sub_nf
  ```
  by the IDENTICAL recipe as `kampPrior_case1_arm_k0` (KampPrior:1668 — copy its structure
  verbatim, k=0 → k=1): witness
  `Formula.or (kampArm_past_k1 …) (Formula.or (kampArm_diag_k1 …) (kampArm_future_k1 …))`,
  then `kampPrior_case1_trichotomy_assemble atomMap M 1 sub_nf t` applied to the three
  `_correct` lemmas — `kampArm_past_k1_correct` (`AggregateOffDiagK1.lean:1467`),
  `kampArm_diag_k1_correct` (`AggregateHookDischarge.lean:2098`),
  `kampArm_future_k1_correct` (`AggregateOffDiagK1.lean:1495`). Per 350 summary §5.2 the
  shapes match the trichotomy disjuncts verbatim (`ShapeCertificatesK1`); if the `1 + 1` vs
  `2` index needs normalizing, use `show`, never restate the arm lemmas (V10-1).
- **Deliverables:** `theorem kampPrior_case1_arm_k1` (additive, end of KampPrior.lean, next to
  the k=0 twin, with a docstring citing task 350's deliverables and this plan), sorry-free.
- **File targets:** `KampPrior.lean` ONLY (additive; `:361`/`:364` untouched).
- **Consume, do NOT rebuild:** the three k=1 arm lemmas (350); `kampPrior_case1_trichotomy_assemble`
  (18a); the k=0 twin as template (358). No new imports expected (aggregator already imported).
- **Acceptance criteria:** scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior`
  GREEN; `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kampPrior_case1_arm_k1` = exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings; KampPrior sorry-token count
  unchanged (2); frozen files byte-unchanged; `:361`/`:364` byte-unchanged this phase.
- **Estimated lines:** 30-80 (one agent run; H8 — small by design).
- **Guards enforced:** G1-G6, N1-N5, V9-1..V9-5 (as extended), V10-1..V10-5.
- **Commit:** `task 309 phase 20: ambient-k=1 arm closure kampPrior_case1_arm_k1`

### Phase 21: `:361` k≤1 narrowing (`match k with | 0 | 1 | k+2 => sorry`) + verification [COMPLETED]

> **Completion record (2026-07-14, sess_1784036998_a5fcb0).** All acceptance criteria met;
> see summaries/10_k1-narrowing-summary.md. *(deviation: altered — the pre-authorized
> forward-reference hoist WAS taken: `kampPrior_site_env_bridge`, `kampPrior_site_trichotomy`,
> `kampPrior_case1_trichotomy_assemble`, `kampPrior_case1_arm_k0`, and `kampPrior_case1_arm_k1`
> moved VERBATIM above `nf_nvar_exist_all_depths` (statements/proofs byte-identical; hoist
> notes left at each original site), exactly the plan's preferred contingency. No other
> deviation.)*

- **Goal:** Execute the pre-committed narrowing of the `| 1 =>` (n=1) blanket sorry
  (KampPrior:361 — re-locate by grepping the `task 348 … transfer note` comment block, V10-3):
  1. **Coordination check first (V10-3)**: confirm the sorry is still the blanket form and no
     task-358 commit has intervened (`git log --oneline -- …KampPrior.lean` since HEAD-of-plan
     + grep). If already narrowed/rewritten: STOP the edit; record; phase degrades to
     verification of the existing state.
  2. Replace the single `sorry` with a `match k with` (or equivalent `Nat`-cases) dispatch:
     - `| 0 =>` cite `kampPrior_case1_arm_k0 atomMap h_surj sub_nf` (landed, 358);
     - `| 1 =>` cite `kampPrior_case1_arm_k1 atomMap h_surj sub_nf` (Phase 20);
     - `| k + 2 =>` ONE narrowed `sorry` with an inline residual note (mirror the `:352-360`
       transfer-note pattern): names the Track-A blocker `P17-frozen-interface-gap`
       (hrealI/hrealB anchor-content interface gap), the successor **task 358** (realization
       recursion; 349 obligation-ledger rows 1-6/8-11), and the landed general-k machinery it
       will consume (`endInterval_correct`, the kvE2Ext/kvExt gate stack) — landed names only
       (V10-2). Forward-reference safety: `kampPrior_case1_arm_k0/_k1` are declared AFTER the
       recursion in file order — if Lean rejects the forward reference, hoist the two arm
       closures above `nf_nvar_exist_all_depths` (pure additive move of Phase-20/358 material;
       document as a deviation; the 358 lemma moves verbatim, no proof edit) or restate the
       match arms via the underlying `kampArm_*` lemmas + assemble call inline. Prefer hoisting.
  3. Update the `:352-360` comment block: the task-348 transfer note gains a dated v10 record
     ("k≤1 arms discharged by task 309 v10 Phases 20-21 via task 349/350/358 deliverables;
     k+2 residual → task 358").
  4. **Verification sweep**: full-tree `lake build` GREEN (baseline ~1736-1751 jobs);
     KampPrior sorry-token count exactly 2 (the narrowed `| k+2 =>` + `:364`); `#print axioms`
     on `nf_nvar_exist_all_depths` — EXPECTED to still show `sorryAx` (the two residuals; this
     is the honest v10 bar, V10-4 — do NOT claim the GO-full bar); `lean_verify` on
     `kampPrior_case1_arm_k1` and (unchanged) `kampPrior_case1_arm_k0` = exactly the three
     standard axioms; frozen-territory git-diff EMPTY; grep confirms no `h_quant` threading
     (V10-1), no `hexclExt` (V9-2), no new import.
- **Deliverables:** the narrowed `| 1 =>` arm; the updated transfer-note block; the
  verification record; the honest completion statement (V10-5) in the summary + handoff:
  **k≤1 narrowing COMPLETE; k≥2 residual documented and routed to task 358; `:364` untouched**.
- **File targets:** `KampPrior.lean` ONLY.
- **Consume, do NOT rebuild:** Phase-20 lemma; `kampPrior_case1_arm_k0`; nothing else.
- **Acceptance criteria (v10 definition of done):** full-tree `lake build` GREEN; the `| 1 =>`
  arm's k=0/k=1 cases close by the named citations; exactly ONE narrowed residual sorry at
  `| k+2 =>` with the successor note (grep-checkable: `task 358` appears in the note);
  KampPrior sorry-token count = 2; `:364` byte-unchanged; frozen files byte-unchanged;
  `nf_nvar_exist_all_depths` signature byte-unchanged (V9-4); summary/handoff use the V10-5
  language; task-307 Phase-7 impact reported honestly (still gated on the k≥2 residual — the
  unblock claim, if any, is scoped to what 307 actually needs; do not overstate).
- **Estimated lines:** 20-60 edited/added (+ hoist move if taken) (one agent run; H8).
- **Guards enforced:** G1-G6, N1-N5, V9-1..V9-5 (as extended), V10-1..V10-5; sorry + axiom
  discipline per V10-4.
- **Commit:** `task 309 phase 21: narrow KampPrior :361 to k<=1 (k=0/k=1 discharged; k+2 residual -> task 358)`

## Testing & Validation

- After each phase: scoped `lake build …Kamp.KampPrior`; full-tree build at Phase 21.
- Per-phase axiom check (`lean_verify`) on each new named lemma: exactly
  `[propext, Classical.choice, Quot.sound]`, no warnings.
- **Sorry-count check (both phases)**: KampPrior.lean sorry-token count exactly 2 before and
  after Phase 20; exactly 2 after Phase 21 (blanket → narrowed is count-neutral; V10-4).
- **Frozen-territory check (every phase)**: git diff confirms the v10 frozen set (v9 seven +
  the 349/350/355-360 stack + Base.lean) byte-identical.
- **Route-V check (Phase 20)**: grep confirms NO reference to `h_quant`, `quantEnd`, `seg
  endChar`, or the `nf_char2_*_formula_correct` binder threading in new material (V10-1); NO
  `endChar_correct` identifier anywhere (V10-2 — the landed name is `endInterval_correct`).
- **Seam check (Phase 21)**: pre-edit V10-3 git/grep coordination record present; post-edit
  grep shows `task 358` in the residual note; `:364` and `kampPrior_case1_arm_k0` byte-unchanged
  (modulo the documented hoist, which moves the latter verbatim).
- **Interface check (Phase 21)**: `nf_nvar_exist_all_depths` statement byte-unchanged (V9-4).
- **Anchor-cap check**: no new anchor beyond `{x,t}`/the arm-internal witnesses (G2/G4/G6).
- **Honesty check (Phase 21)**: the summary/handoff contain the V10-5 scope statement; no
  claim of full `:361` retirement or of a sorryAx-free `nf_nvar_exist_all_depths`.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` — `kampPrior_case1_arm_k1`
  (P20), the narrowed `| 1 =>` arm + updated transfer note (P21), optional documented hoist.
  Everything else in the file byte-identical (in particular `:364` and all landed 15/16/18a/358
  material).
- `specs/309_offdiag_two_anchor_fi_chain/summaries/{NN}_k1-narrowing-summary.md` on completion
  (V10-5 language mandatory).
- Per-phase handoffs under `specs/309_offdiag_two_anchor_fi_chain/handoffs/`.
- Two scoped commits (`task 309 phase 20/21: …`), continuing the task history.

## Rollback/Contingency

- Each phase is one scoped commit; revert the last commit to roll back one phase (H9). The
  Phase-20 lemma is purely additive — reverting Phase 21 alone restores the blanket sorry with
  the k=1 closure still landed and green.
- **Phase-20 contingency**: if the defeq `1 + 1`/`2` normalization resists `show`, land the
  three per-disjunct bridge `example`s first (mirroring `ShapeCertificatesK1` inside
  KampPrior's context) to localize the mismatch; if a genuine shape gap appears (it should
  not — machine-certified), STOP + record + escalate; do NOT restate or edit the 350 lemmas.
- **Phase-21 contingency**: if the forward-reference hoist grows beyond a verbatim move
  (e.g. hidden dependency of the arm closures on post-recursion material), fall back to
  inlining the two arm constructions at the match arms via the `kampArm_*` lemmas +
  `kampPrior_case1_trichotomy_assemble` directly (both are declared before nothing relevant —
  they live after the recursion too; in that case build the match arms as `by exact` terms
  citing the Phase-20 lemma via a forward `private theorem` placed above the recursion). If no
  green formulation exists within the run's budget, land Phase 20 only, park Phase 21
  [PARTIAL] on a green commit with the exact elaboration error recorded — never a broken tree,
  never an extra sorry.
- **If task 358 unblocks concurrently**: V10-3 makes the collision detectable; the
  orchestrator serializes (309 Phase 21 is a strictly smaller edit and should land first; 358
  then consumes the narrowed match by replacing only `| k+2 =>`).
- The escalation fence bars any implementer-level scope growth toward the k≥2 arm; the
  residual routing is pre-committed and non-negotiable at dispatch level.
