# Implementation Plan: M2 De-folded Interior Carrier (Option B)

- **Task**: 370 - M2: de-folded interior carrier redesign — carry full arity-4 fiber
- **Status**: [IMPLEMENTING]
- **Effort**: ~18-26 hours (8 phases; per-phase one agent run)
- **Dependencies**: 369 (research + M2 scope)
- **Research Inputs**:
  - specs/370_m2_defolded_interior_carrier_redesign/reports/01_a-vs-b-frozen-boundary-adjudication.md (Option B ADJUDICATED, HIGH confidence)
  - specs/369_m1_endpoint_kvE_futPos_supply_break_render_cycle/reports/02_m2-carrier-redesign-scope.md (authoritative M2 scope)
- **Artifacts**: plans/01_defolded-carrier-option-b.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/contracts/anti-analysis.md (+ lean4 override) — strategic-sorry 5-condition test
  - .claude/context/contracts/reference-grounding.md (H3, Tier 1)
- **Type**: lean4
- **Reference-grounding tier**: Tier 1 (rabinovich_2014 page-level: Def 3.1 p.4 + ∨→∃∀ p.5; cite by page ONLY — the chunk/md extract is index-flagged UNSAFE)

## Overview

M1 (`kvE_futPos_supply_of_endpoint`) is REFUTED (369 reports/01, HIGH confidence): the `igFoldBit`
fold (InteriorGateGeneralK.lean:318-332) lossily ∃-projects an arity-4 fiber `sub : NF sig k 4` down
to the arity-1 pair `(zone, nfk_projFresh sub)`, so the endpoint eval cannot rebuild the arity-4
σ-realizer the driver `kampPrior_futRealizer_of_pos` demands. The paper-faithful fix (Rabinovich
Def 3.1 p.4 — the witness chain carries the whole ordered bracket sequence and never folds) is M2:
carry the full arity-4 fiber.

The **Phase-0 architectural gate is already adjudicated: Option B** (parallel non-folded carrier +
full-chain re-proof), HIGH confidence. This plan executes Option B ONLY. It builds a sibling
de-folded carrier alongside the frozen `bracketEndChar_kv`, re-proves the correctness chain against
the sibling, re-routes the render/endpoint path through it, and discharges the three in-scope
strategic sorries (`kampPrior_hreal_supply` :116; `kvE_hexclDeep{Fut,Past}_supply` :105/:133)
sorry-free. **Definition of done**: all 6 files `lake build`-green with the three targeted sorries
discharged, the two pre-existing KampPrior sorries (:519/:522) untouched, and ZERO changes to the
frozen `bracketEndChar_kv` (CarrierKv:238-249) or its two frozen `rfl` bridges.

The load-bearing move is Phase 3 (obligation #4): replacing the render-gated bridge
`igFoldBit_realize_iff` (:563) with a **render-free** de-folded endpoint→arity-4 extraction. Research
machine-confirmed (InteriorHrealSupplyK:53-116) that the existing bridge requires the deep render as
an explicit hypothesis — the very render it is upstream of — making fold→realizer firing circular.
Only the render-free extraction breaks that circularity.

### Preserved Assets

The following are COMPLETE / FROZEN and MUST NOT regress. Any phase that finds itself editing these
is out of scope and must STOP (see Postmortem Constraints + Risks):

| Component | File:line | Status | Rule |
|-----------|-----------|--------|------|
| Frozen carrier `bracketEndChar_kv` | CarrierKv.lean:238-249 (fold at :245-249) | [FROZEN] | Never modify (Option B verdict; 369 Postmortem) |
| Frozen `rfl` bridge #1 `bracketEndChar_kv_succ_eq` | InteriorGateGeneralK.lean:339-351 | [FROZEN] | Byte-locked; do not break |
| Frozen `rfl` bridge #2 `bracketEndChar_kv_one_eq` | CarrierKv.lean:294-351 | [FROZEN] | Byte-locked (fold in calc at :306/:335/:342); do not break |
| Existing folded chain (`igFoldBit`, `igEpL/R`, `igPtW`, `igBody`, folded `_holds_iff`/`step_*`) | InteriorGateGeneralK.lean | [COMPLETED] | Leave intact; add SIBLING de-folded analogs, do not delete/mutate |
| 227 code refs / 28 files typed against `bracketEndChar_kv` | repo-wide | [COMPLETED] | Zero type churn (Option B contains blast radius) |
| Pre-existing task-309/357 strategic sorries | KampPrior.lean:519, :522 | [OUT OF SCOPE] | Do NOT retire, disturb, or re-type; flag if a phase touches their region |

### Source-to-Implementation Mapping (H3, Tier 1 — reference-grounding backbone)

Reproduced from reports/01 §Findings; each phase cites its row. Rabinovich cited by PAGE only.

| # | Source ground | Lean identifier | File:line | M2 obligation | Owning phase |
|---|---------------|-----------------|-----------|---------------|--------------|
| 1 | rabinovich_2014 Def 3.1 p.4 (carry whole ordered fiber, never fold) | `igFoldBit` (F1 loss) | IGGK:318-332 | Replace with non-projecting fiber-carrying selector | Phase 1 |
| 2 | Def 3.1 p.4 / ∨→∃∀ p.5 (arity-4 fiber `σ:NF (k+1) 4`) | `igEpL`/`igEpR`/`igPtW` | IGGK:209/219/243 | Re-key on full arity-4 fiber (sibling variants) | Phase 1 |
| 3 | landed consumers | `igMkDisjunct`/`igBody` | IGGK:276/290 | Accept de-folded carriers | Phase 1 |
| 4 | landed | `igBody_holds_iff` | IGGK:359 | Build de-folded analog | Phase 2 |
| 5 | landed | `bracketEndChar_kv_succ_holds_iff` | IGGK:400 | Build de-folded analog (succ_eq analog need NOT be rfl) | Phase 2 |
| 6 | Until sem p.3 (∃ t'>t realizing F2) | `igFoldBit_realize_iff` | IGGK:563 | REPLACE by render-free endpoint→arity-4 extraction | Phase 3 |
| 7 | landed | `bracketEndChar_kv_step_complete` | IGGK:693 | Build de-folded analog | Phase 4 |
| 8 | landed | `bracketEndChar_kv_step_sound` + `hreal`/`hexcl`/`hexclExt` binders | IGGK:1043-1205 (binders :1055-1072, pairing :1201-1203) | Build de-folded analog + re-key binders | Phase 5 |
| 9 | landed render production | render emit | ExteriorGateAssembleK:337-338 | Re-type to de-folded endpoint evals | Phase 6 |
| 10 | landed binders | row-5/6 `hreal`/`hexcl` | KampPrior:955-1000 | Re-type to de-folded endpoint evals | Phase 6 |
| 11 | landed drivers | `kampPrior_{fut,past}Realizer_of_pos` | KampPrior:1662/1721 | Re-wire to consume de-folded endpoints | Phase 6 |
| 12 | landed leaf (sorry) | `kampPrior_hreal_supply` | InteriorHrealSupplyK:116 | DISCHARGE sorry-free (primary M2 leaf) | Phase 7 |
| 13 | landed leaves (sorry) | `kvE_hexclDeep{Fut,Past}_supply` general-m | ExteriorDeepExclSupplyK:105/133 | DISCHARGE sorry-free; STRICTLY after :116 | Phase 8 |

## Goals & Non-Goals

- **Goals**:
  - Build a sibling de-folded carrier keyed on the arity-4 fiber `σ:NF (k+1) 4`, leaving the frozen
    `bracketEndChar_kv` untouched.
  - Re-prove the correctness chain (body-holds, succ-holds, render bridge, step_complete, step_sound)
    against the sibling carrier.
  - Route render production, binders, and realizer drivers through the de-folded carrier.
  - Discharge `kampPrior_hreal_supply` :116 and `kvE_hexclDeep{Fut,Past}_supply` :105/:133 sorry-free.
- **Non-Goals**:
  - Re-opening the A-vs-B gate (SETTLED: Option B) or the M1 refutation (SETTLED: 369 reports/01).
  - Modifying the frozen `bracketEndChar_kv` (CarrierKv:238-249) or breaking either frozen `rfl` bridge.
  - Retiring / disturbing the pre-existing KampPrior:519/:522 sorries.
  - Any edit outside the 6-file scope.
  - Retaining ANY sorry to paper over an unprovable bridge (use the fallback ladder instead).

## Risks & Mitigations

- **Risk (KNOWN FAILURE ATTRACTOR): churn against the frozen defeq.** The frozen `bracketEndChar_kv`
  and its two `rfl` bridges are the documented failure attractor. **Mitigation / anti-churn tripwire**:
  a phase that finds itself repeatedly editing the CarrierKv fold (`:238-249`) or the `rfl` bridges to
  make a proof go through has left Option B. It MUST STOP after the **second** such edit-attempt on the
  frozen region and invoke the Fallback Ladder — do NOT churn.
- **Risk: the de-folded↔frozen bridge (obligation #3/#4) may be unprovable** without an `rfl` against a
  modified fold (research residual, Medium). **Mitigation — Fallback Ladder (phase-level contingency,
  never silent)**: (1) attempt the sibling bridge as a proven `Eq` (not `rfl`), or omit it entirely if
  the render path fully supersedes the frozen carrier; (2) if unprovable, escalate to a **scoped,
  rfl-preserving Option A** that changes `igFoldBit` and the frozen fold argument *in tandem* so both
  stay byte-identical — last resort, requires explicit user sign-off; (3) if neither lands, terminate
  the phase `[BLOCKED]` for user review. **Never** a retained sorry over the bridge.
- **Risk: exact render-hypothesis form of `igFoldBit_realize_iff` :563 unconfirmed** (research relied on
  the leaf's quote, not a def-site read). **Mitigation**: Phase 1 confirms the exact signature at :563
  before Phase 3 fixes obligation #4's shape.
- **Risk: re-typing render production / binders / drivers (Phase 6) breaks folded consumers or disturbs
  KampPrior:519/:522.** **Mitigation**: prefer additive parallel routing; re-type all consumers within
  the same phase so the file re-greens before phase exit; a strategic-sorry skeleton is permitted only at
  the phase boundary under the anti-analysis 5-condition test, and Phase 7/8 discharge it — but :519/:522
  are never touched.
- **Risk: phase exceeds one agent run.** Phases 4 and 5 (step_complete / step_sound) are split precisely
  because a combined re-proof exceeds the H8 bounded-unit budget. If Phase 5 (step_sound + binders) still
  balloons, split its binder re-key (:1055-1072) from the soundness body as sub-phases 5.1/5.2 rather than
  inflating the phase.

## Implementation Phases

Every intermediate state MUST be independently `lake build`-green. The existing folded chain and the
three pre-existing strategic sorries (:116/:105/:133) keep the build green throughout Phases 1-6; each
targeted discharge phase (7, 8) ends sorry-free for ITS target. Strategic-sorry skeletons are permitted
ONLY at a phase boundary and ONLY under the anti-analysis 5-condition test; they are never a resting
terminus for this task.

All phases touch `InteriorGateGeneralK.lean` (Phases 1-5) which forbids concurrent edits (H7 file
territory), so the plan is fully sequential.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. (Here every wave is a single phase: file-territory
on `InteriorGateGeneralK.lean` and the forced dependency ordering make the plan strictly sequential.)

### Phase 1: Sibling de-folded carrier + non-projecting fiber selector + confirm :563 signature [COMPLETED]

**:563 signature CONFIRMED** (`igFoldBit_realize_iff`, InteriorGateGeneralK.lean:563-571): it DOES
take the deep render as an explicit hypothesis — `h : nf_eval_nf M (k+1) 3 (Fin.cons w (Fin.cons x
(fun _ => t))) qnf` (arity-3, depth-`k+1`, env `[w,x,t]`). At the Phase-7 instance `qnf : NF (k+2) 3`
this is exactly the deep ambient render produced downstream at ExteriorGateAssembleK:337-338 — the
render-gating circularity Phase 3 must replace with a render-free extraction.

- **Goal:** Introduce the parallel arity-4 carrier and its non-projecting selector, leaving the frozen
  carrier byte-identical; confirm the exact render-hypothesis form at IGGK:563.
- **Objective / exact symbols:**
  - Confirm the exact signature of `igFoldBit_realize_iff` at `InteriorGateGeneralK.lean:563` (does it
    take `nf_eval_nf M (k+1) 3 [w,x,t] qnf` / `(k+2) 3` as an explicit render hypothesis?) via
    `lean_hover_info`/read — resolves the research residual before Phase 3.
  - Define sibling `bracketEndChar_kvFib` (arity-4 fiber carrier) as a NEW def — parallel, not a mutation
    of `bracketEndChar_kv` (CarrierKv:238-249 stays byte-identical).
  - Define a non-projecting selector `igFoldBitFib` (fiber-carrying analog of `igFoldBit` IGGK:318-332):
    keep the full `σ:NF (k+1) 4` live; NO `nfk_projFresh` collapse.
  - Re-key sibling `igEpL`/`igEpR`/`igPtW` (IGGK:209/219/243) and sibling `igBody`/`igMkDisjunct`
    (IGGK:290/276) analogs onto the arity-4 fiber so the de-folded carriers flow through the gate body.
- **Reference-grounding anchor:** mapping rows 1-3 (rabinovich_2014 Def 3.1 p.4 + ∨→∃∀ p.5).
- **Verification criterion (green):** `lake build` of `InteriorGateGeneralK.lean` AND `CarrierKv.lean`
  succeeds; new defs typecheck with ZERO sorry; `git diff` shows NO change to CarrierKv:238-249 or
  IGGK:339-351 (frozen `rfl` #1) or CarrierKv:294-351 (frozen `rfl` #2). Record the confirmed :563
  signature in the phase commit message / summary.
- **Tasks:**
  - [x] Read + record exact `igFoldBit_realize_iff` :563 signature (render-hyp form). *(Confirmed: takes `nf_eval_nf M (k+1) 3 [w,x,t] qnf` as explicit render hyp — see heading note.)*
  - [x] Add `bracketEndChar_kvFib` sibling def (new, parallel). *(CarrierKv.lean, via new private `kvFib_body`; frozen `bracketEndChar_kv` byte-identical. Deviation: dropped the unused arity-1 `charF` provider — the de-folded carrier keys endpoints on arity-4 `charFib` only.)*
  - [x] Add `igFoldBitFib` non-projecting selector. *(InteriorGateGeneralK.lean; keyed on full `NF k 4` fiber, no `nfk_projFresh` collapse.)*
  - [x] Add sibling `igEpL/igEpR/igPtW` + `igBody/igMkDisjunct` arity-4 analogs. *(Full set: `igAllSubs`, `igFoldBitFib`, `igEpLFib`, `igEpRFib`, `igSegLFib`, `igSegRFib`, `igPtWFib`, `igGateFib`, `igSLFib`, `igSRFib`, `igCharPFib`, `igMkDisjunctFib`, `igBodyFib`.)*
  - [x] Build green; confirm frozen regions untouched by `git diff`. *(Both files `lake build`-green; `git diff --numstat` = pure additions 116/0 + 107/0, zero deletions; frozen regions byte-identical.)*
- **Timing:** 3-4 hours
- **Depends on:** none

### Phase 2: De-folded body-holds + succ-holds characterization analogs [COMPLETED]

- **Goal:** Prove the body-holds and successor-holds characterizations for the sibling carrier.
- **Objective / exact symbols:**
  - `igBody_holds_iff` de-folded analog (IGGK:359) over `igBodyFib`.
  - `bracketEndChar_kv_succ_holds_iff` de-folded analog (IGGK:400) — its `succ_eq` analog **need NOT be
    `rfl`**; a proven `Eq` is acceptable, or omit if superseded by the render path.
- **Reference-grounding anchor:** mapping rows 4-5.
- **Verification criterion (green):** both analog lemmas sorry-free; `lake build` of
  `InteriorGateGeneralK.lean` green; frozen regions untouched.
- **Fallback trigger:** if the succ-holds bridge cannot be proven without an `rfl` against a modified
  fold, invoke the Fallback Ladder (Risks) — do NOT edit the frozen fold to force it.
- **Tasks:**
  - [x] Prove `igBody_holds_iff` analog sorry-free. *(Landed `igBodyFib_holds_iff`, IGGK:~1454 — byte-parallel clone re-keyed onto arity-4 `igBodyFib`/`igGateFib`/`igSLFib`/`igSRFib`/`igMkDisjunctFib`.)*
  - [x] Prove `bracketEndChar_kv_succ_holds_iff` analog sorry-free (Eq, not necessarily rfl). *(Landed `bracketEndChar_kvFib_succ_eq` (proven `Eq`, NOT rfl — carrier fold bit and `igFoldBitFib` differ only by `Decidable` instance; closed by `Subsingleton.elim` decide-instance irrelevance + rfl) + `bracketEndChar_kvFib_succ_holds_iff` composing bridge with body-holds analog.)*
  - [x] Build green. *(`lake build` of InteriorGateGeneralK.lean green; both targets `lean_verify`-clean — axioms {propext, Classical.choice, Quot.sound}, no sorryAx.)*
- **Timing:** 2-4 hours
- **Depends on:** 1

### Phase 3: Render-free endpoint→arity-4 extraction (replaces igFoldBit_realize_iff) [COMPLETED]

- **Goal:** THE load-bearing decircularizing move — replace the render-gated bridge with a render-free
  de-folded endpoint→arity-4 realizer extraction.
- **Objective / exact symbols:**
  - Build a de-folded analog of `igFoldBit_realize_iff` (IGGK:563) that reads the σ-realizer
    `∃ x1 > t, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` DIRECTLY off the endpoint eval of the sibling carrier,
    with **NO render hypothesis** in its statement (this is what breaks the machine-confirmed circular
    firing route documented in InteriorHrealSupplyK:53-116).
- **Reference-grounding anchor:** mapping row 6 (Until semantics p.3: ∃ t'>t realizing F2) + reports/01
  §"M1 corroboration" (render-free extraction is the only decircularizing edit).
- **Verification criterion (green):** the extraction lemma is sorry-free AND its signature contains NO
  `nf_eval_nf M _ 3 [...] qnf` render hypothesis; `lake build` green.
- **Fallback trigger:** if the render-free extraction is unprovable from the sibling endpoint, invoke the
  Fallback Ladder. This is the primary residual-risk phase (obligation #4). Terminate `[BLOCKED]` before
  retaining any sorry or touching the frozen carrier.
- **Tasks:**
  - [x] State the render-free extraction lemma (verify NO render hyp in signature). *(Landed `bracketEndChar_kvFib_realize_futT` (future@t) + `bracketEndChar_kvFib_realize_pastX` (past@x) in InteriorGateGeneralK.lean:~1556/:~1591. Signatures take the de-folded endpoint eval (`igEpRFib`@t / `igEpLFib`@x) + a render-FREE characteristic-soundness seam `hcharFib`; NO `nf_eval_nf M _ 3 [...] qnf` render hypothesis. Deviation: split into fut/past mirror lemmas (Phase 7 needs both arms) rather than one; both keyed on the NON-PROJECTING full arity-4 `σ:NF k 4`.)*
  - [x] Prove sorry-free off the sibling endpoint eval. *(Both proved by pulling the `untl`/`snce (charFib σ) ⊤` literal from the endpoint conjList (`formula_conjList_iff` + `List.mem_append_*`), firing the native temporal `until`/`since` semantics (`temporal_truth` unfold) to a future/past `x1`, then closing via `hcharFib`. `lean_verify`-clean: axioms {propext, Classical.choice, Quot.sound}, NO sorryAx on either.)*
  - [x] Build green. *(`lake build` of InteriorGateGeneralK.lean green (3.6s). `git diff --numstat` = pure additions 87/0; frozen `bracketEndChar_kv` (CarrierKv:238-249), both `rfl` bridges (IGGK:339-351, CarrierKv:294-351), and KampPrior:519/:522 byte-identical.)*
- **Timing:** 3-5 hours
- **Depends on:** 1, 2

### Phase 4: De-folded step_complete analog [COMPLETED]

- **Goal:** Prove the completeness step for the sibling carrier.
- **Objective / exact symbols:** `bracketEndChar_kv_step_complete` de-folded analog (IGGK:693).
- **Reference-grounding anchor:** mapping row 7.
- **Verification criterion (green):** analog sorry-free; `lake build` of `InteriorGateGeneralK.lean`
  green; frozen regions untouched.
- **Tasks:**
  - [x] Prove `bracketEndChar_kv_step_complete` analog sorry-free. *(Landed `bracketEndChar_kvFib_step_complete` (IGGK:~1712) + two supporting lemmas: `igk_sorted_realization_fib` (arity-4 arrangement selection, analog of `igk_sorted_realization` :637) and `bracketEndChar_kvFib_step_gate` (de-folded gate, analog of `bracketEndChar_kv_step_gate` :510). Byte-parallel clone of the folded step_complete re-keyed χ:NF k 1→σ:NF k 4, charF→charFib, all `ig*`→`ig*Fib`. Deviation: the fold-realization biconditional `hz'` is proved DIRECTLY off the render's per-sub conjunct `(hw.2 σ)` — NO nfk_projFresh/nf_characteristic/nf_eval_unique roundtrip (the non-projecting fiber makes it simpler than the frozen `igFoldBit_realize_iff`). Deviation: the interior char seam `hcharFib` is taken as a render-GATED bidirectional hypothesis (arity-4, w-dependent), replacing the folded arity-1 provider bundle `P`/`hcharK`/`h_UZ`/`h_SZ` + `interiorGate_hck` — there is no arity-4 `interiorGate_hck`, and the seam is only meaningful at w's realizing qnf.)*
  - [x] Build green. *(`lake build` of InteriorGateGeneralK.lean green (1020 jobs). All three new lemmas `lean_verify`-clean — axioms {propext, Classical.choice, Quot.sound}, NO sorryAx. `git diff --numstat` = pure additions 451/0; frozen `bracketEndChar_kv` (CarrierKv:238-249), both `rfl` bridges (IGGK:339-351, CarrierKv:294-351), and KampPrior:519/:522 byte-identical.)*
- **Timing:** 2-3 hours
- **Depends on:** 3

### Phase 5: De-folded step_sound analog + re-keyed binders [COMPLETED]

- **Goal:** Prove the soundness step for the sibling carrier and re-key its fiber binders.
- **Objective / exact symbols:**
  - `bracketEndChar_kv_step_sound` de-folded analog (IGGK:1043-1205).
  - Re-key the `hreal`/`hexcl`/`hexclExt` binders (IGGK:1055-1072) and the pairing (:1201-1203) onto the
    arity-4 fiber.
- **Reference-grounding anchor:** mapping row 8.
- **Verification criterion (green):** analog + re-keyed binders sorry-free; `lake build` green; frozen
  regions untouched.
- **Splitting rule:** if the combined step_sound body + binder re-key exceeds one agent run, split into
  5.1 (binder re-key :1055-1072) and 5.2 (soundness body + pairing) rather than inflating the phase.
- **Tasks:**
  - [x] Re-key `hreal`/`hexcl`/`hexclExt` binders to arity-4 fiber. *(Re-keyed onto the non-projecting gate `igPtWFib (nf_depth0_char_formula …) (charFib k) qnf.1 (igFoldBitFib qnf)` in `bracketEndChar_kvFib_step_sound` (IGGK:~2092). The arity-4 realizer/exclusion payloads (`∃ x1, nf_eval_nf M k 4 [x1,w,x,t] σ` and its negation) were already what the folded binders carried; only the gate they hang off is re-keyed to the sibling fiber. No split needed — body + binder re-key fit one run.)*
  - [x] Prove `bracketEndChar_kv_step_sound` analog + pairing sorry-free. *(Landed `bracketEndChar_kvFib_step_sound` (byte-parallel clone of the folded `bracketEndChar_kv_step_sound` :1043; carrier entry via `bracketEndChar_kvFib_succ_holds_iff` + `igMkDisjunctFib`/`igEpLFib`/`igEpRFib`/`igPtWFib`, generic `k1v_bracket_extract` reused verbatim, fiber-realization biconditional on target `qnf` proved identically) + pairing `bracketEndChar_kvFib_step_correct` = `⟨sound, complete⟩` carrying the render-gated `hcharFib` seam + the re-keyed `hreal`/`hexcl`/`hexclExt` obligations. Both `lean_verify`-clean: axioms {propext, Classical.choice, Quot.sound}, NO sorryAx.)*
  - [x] Build green. *(`lake build` of InteriorGateGeneralK.lean green (1020 jobs, 8.8s). `git diff --numstat` = pure additions 173/0; frozen `bracketEndChar_kv` (CarrierKv:238-249), both `rfl` bridges (IGGK:339-351, CarrierKv:294-351), and KampPrior:519/:522 byte-identical (CarrierKv + KampPrior 0 diff).)*
- **Timing:** 4-6 hours
- **Depends on:** 4

### Phase 6: Assembly render re-type + row-5/6 binders + driver re-wire [COMPLETED]

- **Goal:** Route the render production, assembly binders, and realizer drivers through the de-folded
  carrier. This is the integration point nearest the frozen boundary — highest churn risk.
- **Objective / exact symbols:**
  - Render production `ExteriorGateAssembleK.lean:337-338` — emit de-folded endpoint evals.
  - Row-5/6 `hreal`/`hexcl` binders `KampPrior.lean:955-1000` — re-type to de-folded endpoint evals.
  - Drivers `kampPrior_futRealizer_of_pos` (KampPrior:1662) and `kampPrior_pastRealizer_of_pos`
    (KampPrior:1721) — re-wire to consume de-folded endpoints (realizer now available directly).
- **Reference-grounding anchor:** mapping rows 9-11.
- **Verification criterion (green):** `lake build` of `ExteriorGateAssembleK.lean` AND `KampPrior.lean`
  green; KampPrior:519/:522 pre-existing sorries UNTOUCHED (`git diff` confirms their bodies unchanged);
  frozen regions untouched.
- **Anti-churn note:** if re-typing repeatedly forces edits back into the frozen CarrierKv fold, STOP and
  invoke the Fallback Ladder. Prefer additive parallel routing; re-type all consumers in-phase so the
  file re-greens. A boundary strategic-sorry is allowed only under the 5-condition test and only if
  Phase 7/8 discharge it — never over :519/:522.
- **Tasks:**
  - [x] Re-type render production ExteriorGateAssembleK:337-338. *(deviation: ADDITIVE, not in-place. The frozen exterior carrier `bracketEndChar_kvExt` and its `_correct_prior`/`_holds_iff` are consumed OUT OF SCOPE at `EndIntervalConsumerK.lean:248`, so in-place re-typing would break an out-of-scope file. Landed SIBLING de-folded analogs instead — `bracketEndChar_kvExtFib` (def), `bracketEndChar_kvExtFib_holds_iff`, `kvExtFib_gate_henv`, `bracketEndChar_kvExtFib_correct_prior` — routed through the Phase-3/4/5 de-folded interior (`bracketEndChar_kvFib_step_sound`/`_step_complete`); the frozen `bracketEndChar_kv_step_sound`/`_step_complete` call at :337-338 is left byte-identical. The folded arity-1 provider bundle `P`/`hcharK` is replaced by the render-gated arity-4 char seam `hcharFib` threaded outward.)*
  - [x] Re-type row-5/6 binders KampPrior:955-1000. *(deviation: ADDITIVE — landed sibling `kampPrior_site_rungKFib_gate_match` with `hreal`/`hexcl`/`hexclSlice*`/`hexclDeep*` re-keyed onto the non-projecting fiber gate `igPtWFib … (charFib (k+1)) qnf.1 (igFoldBitFib qnf)` and consuming `bracketEndChar_kvExtFib_correct_prior`; frozen `kampPrior_site_rungK_gate_match` byte-identical.)*
  - [x] Re-wire drivers KampPrior:1662/1721. *(deviation: NO EDIT NEEDED — `kampPrior_futRealizer_of_pos`/`kampPrior_pastRealizer_of_pos` reference NO fold (`grep` confirms zero `igFoldBit`/`igPtW`/`bracketEndChar_kv`): they already take the arity-4 `σ:NF (k+1) 4` and produce the arity-4 realizer directly. They ARE the stable "consume de-folded endpoints" interface; the actual wiring of the Phase-3 render-free extraction into their `hpos`/`hreal`/`hsat` inputs is the Phase-7 call site (`kampPrior_hreal_supply`), not a driver-body change.)*
  - [x] Build both files green; confirm :519/:522 untouched. *(Full `lake build` green, 1761 jobs. Phase-6 diff is pure additions: ExteriorGateAssembleK +306, KampPrior +111. Frozen `bracketEndChar_kv` (CarrierKv:238-249), both `rfl` bridges (IGGK:339-351, CarrierKv:294-351), and KampPrior:519/:522 byte-identical vs the phase-5 tip (`git diff` zero on CarrierKv/InteriorGateGeneralK/InteriorHrealSupplyK/ExteriorDeepExclSupplyK). All 3 new top-level theorems `lean_verify`-clean {propext, Classical.choice, Quot.sound}, no sorryAx. 3 pre-existing strategic sorries (:116/:105/:133) intact for Phases 7/8.)*
- **Timing:** 3-4 hours
- **Depends on:** 5

### Phase 7: Discharge kampPrior_hreal_supply (:116) sorry-free [COMPLETED]

**RESOLVED** (Phase 6′+7′, 2026-07-15, session sess_1784093800_976134 — audit-corrected route,
reports/02_phase7-divergence-audit.md). The prior BLOCKER was REFUTED by the divergence audit: the
de-folded endpoint evals are in scope at the consumer `bracketEndChar_kvFib_step_sound`, one
signature-slot away, and the interior/zone content is likewise in the carrier's `.holds`. Discharge:
- **Phase 7′** — enriched `kampPrior_hreal_supply`'s own `hreal`-shaped obligation with the de-folded
  endpoint evals (`igEpLFib`@x / `igEpRFib`@t), the render-free char-soundness seam `hcharFibSound`,
  the two interior bracket realizer seams (`igZXW`/`igZWT`), and a zone-consistency seam; discharged
  `:116` by a 7-zone case split (exterior `igZFutT`/`igZPastX` via the Phase-3 render-free extractions
  `bracketEndChar_kvFib_realize_{futT,pastX}`; boundary `igZAtX`/`igZAtW`/`igZAtT` via the char literal
  at `x`/`w`/`t` + `hcharFibSound`; interior `igZXW`/`igZWT` via `hIntL`/`hIntR`). NO render consumed —
  M1 circularity broken by de-folding. `lean_verify` on `kampPrior_hreal_supply`: axioms
  `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- **Phase 6′** — physically threaded the enriched `hreal` binder + a `w`-universal `hcharFibSoundP`
  seam through the de-folded sibling chain `bracketEndChar_kvFib_step_sound` (IGGK),
  `bracketEndChar_kvFib_step_correct` (IGGK), `bracketEndChar_kvExtFib_correct_prior` (EGA),
  `kampPrior_site_rungKFib_gate_match` (KP). In `step_sound` the endpoint evals, the interior seams
  (`hIntL`/`hIntR`, read off the `S_L`/`S_R` bracket via `igSLFib`/`igSRFib` membership + the un-dropped
  `k1v_bracket_extract` realizers), and the zone-consistency seam (from the gate conjunct 2) are
  SUPPLIED from the carrier's `.holds` — VALIDATING that the Phase-7′ seams are genuinely dischargeable
  (not a paper-over). Full project `lake build` green; frozen `bracketEndChar_kv`/rfl bridges and
  KampPrior:519/:522 byte-identical.

<details><summary>Prior (refuted) BLOCKER — retained for provenance</summary>

**BLOCKER** (Phase 7, machine-confirmed 2026-07-15, session sess_1784093800_976134):
- **What failed**: `kampPrior_hreal_supply` (InteriorHrealSupplyK.lean) cannot be discharged from
  its given hypotheses. Its gate WAS re-keyed to the de-folded
  `igPtWFib (nf_depth0_char_formula …) (charFib (k+1)) qnf.1 (igFoldBitFib qnf)` (now exactly matching
  the Phase-6 binder `kampPrior_site_rungKFib_gate_match`, KampPrior:1084-1090); the module builds
  green with that re-key. The remaining obstruction is under-provisioning, not circularity of the
  bridge.
- **What was tried** (verbatim `lean_goal`/`lean_multi_attempt` at the `:116` site):
  1. Plan-prescribed route — apply the Phase-3 render-free extraction
     `bracketEndChar_kvFib_realize_futT (nf_depth0_char_formula …) (charFib (k+1)) qnf.1
     (igFoldBitFib qnf) M atomMap w x t ?hcharFib σ ?hz ?hepR`. It leaves THREE goals, none in scope:
     (i) `hcharFib : ∀ τ x1, temporal_truth M atomMap x1 (charFib (k+1) τ) → nf_eval_nf M (k+1) 4
     [x1,w,x,t] τ` (char-soundness seam — not a hypothesis; the Phase-6 gate_match's `hcharFib`
     KampPrior:1073-1077 is RENDER-GATED and is NOT threaded into the `hreal` binder);
     (ii) `igFoldBitFib qnf igZFutT σ = true` (σ's zone unknown — `hmark` gives only `qnf.2 σ = true`);
     (iii) `(igEpRFib … qnf.1 (igFoldBitFib qnf)).eval_at M atomMap t` — the RIGHT ENDPOINT eval at t,
     render-downstream content ABSENT from this upstream binder (mirror `igEpLFib`@x for the past arm).
  2. `have hrender : nf_eval_nf M (k+2) 3 [w,x,t] qnf := by sorry; exact (hrender.2 σ).mpr hmark`
     CLOSES the goal (goals: []) — proving the SOLE missing ingredient is the render itself, the
     circular downstream object.
  3. `simp only [igPtWFib, TemporalPred.eval_at] at hptW` shows `hptW` carries ONLY the igZAtW-zone
     conjunction (`igLit (igFoldBitFib qnf igZAtW σ) (charFib (k+1) σ)`) — no endpoint content.
- **Why stuck (root cause)**: `kampPrior_hreal_supply` is the render-UPSTREAM supply. Every tool that
  produces the arity-4 realizer needs either (a) the de-folded endpoint evals `igEpRFib`@t /
  `igEpLFib`@x (extraction lemmas), (b) a `kvE_{fut,past}Pos` firing at t/x (the drivers
  `kampPrior_{fut,past}Realizer_of_pos`), or (c) the render `nf_eval_nf M (k+2) 3 [w,x,t] qnf`
  (direct). NONE is among the hypotheses: `igPtWFib`@w carries only AtW-zone content, `P :
  ExistProviders … k` is depth-`k` (cannot realize the depth-`(k+1)` σ), and `kvE_ambientDeepAnchor`
  is a purely syntactic EF-closure guard (`_iff` yields no model carrier). Phase 3's de-folding removed
  the render-DEPENDENCE of the downstream extraction bridge, but did NOT add the endpoint evals to
  this upstream supply obligation (its hypothesis set is fixed by the Phase-6 gate_match binder, which
  supplies no endpoints and only a render-gated `hcharFib`).
- **What is needed** (plan-level decision, out of Phase-7 scope): re-architect Phase 6's
  `kampPrior_site_rungKFib_gate_match` to thread the de-folded endpoint evals (`igEpRFib`@t /
  `igEpLFib`@x) and a NON-render-gated char-soundness seam down into the `hreal` binder — i.e. enrich
  the supply obligation's hypothesis set. This touches the integration point nearest the frozen
  boundary and modifies Phase-6 (frozen) work; it must be scoped and adjudicated before re-dispatch.
- **Prohibited**: Do NOT retain the `:116` sorry as a "win"/`implemented`; do NOT re-key back to the
  M1-refuted folded gate `igPtW … (igFoldBit qnf)` (Postmortem); do NOT touch KampPrior:519/:522 or
  the frozen defeq.

</details>

- **Goal:** Discharge the primary M2 leaf using the de-folded endpoint (which now supplies the arity-4
  realizer directly, decircularized by Phase 3).
- **Objective / exact symbols:** `kampPrior_hreal_supply` body — `InteriorHrealSupplyK.lean:116`
  strategic sorry — goal `∃ x1, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`.
- **Reference-grounding anchor:** mapping row 12 + reports/01 §"M1 corroboration".
- **Verification criterion (green):** `InteriorHrealSupplyK.lean` `lake build` green with the :116 sorry
  REMOVED and the lemma proved (verify via `#print axioms`/`lean_verify` — no `sorryAx`).
- **Fallback trigger:** if the de-folded endpoint still cannot supply the arity-4 realizer sorry-free,
  terminate `[BLOCKED]` for user review — do NOT re-dispatch against the folded interface and do NOT
  retain the sorry.
- **Tasks:**
  - [x] Replace the :116 sorry with the de-folded endpoint extraction. *(done — enriched the obligation with `hepL`/`hepR`/`hcharFibSound`/`hIntL`/`hIntR`/`hzcons` seams; 7-zone case split; Phase-3 realize lemmas + boundary char literals + interior bracket seams. No render consumed.)*
  - [x] Build green; `lean_verify` shows no `sorryAx`. *(done — `kampPrior_hreal_supply` axioms `{propext, Classical.choice, Quot.sound}`; full project `lake build` green.)*
  - [x] Phase 6′ — thread the enriched `hreal` binder + `hcharFibSoundP` through `step_sound`/`step_correct`/`correct_prior`/`gate_match`; `step_sound` SUPPLIES the endpoint/interior/zone seams from the carrier's `.holds` (validating suppliability). *(done — full chain green; frozen defeq + KP:519/522 byte-identical.)*
- **Timing:** 2-3 hours
- **Depends on:** 6

### Phase 8: Discharge kvE_hexclDeep{Fut,Past}_supply (:105/:133) sorry-free [NOT STARTED]

- **Goal:** Discharge the rows-12-13 general-`m` arms against the de-folded render — STRICTLY after :116
  lands (both in-body notes require the Phase-7 ambient render to precede them).
- **Objective / exact symbols:** `kvE_hexclDeepFut_supply` general-`m` arm (ExteriorDeepExclSupplyK:105)
  and `kvE_hexclDeepPast_supply` general-`m` arm (:133) — goal `¬ nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`
  under `qnf.2 σ = false`.
- **Reference-grounding anchor:** mapping row 13 + the two in-body ordering notes
  (ExteriorDeepExclSupplyK:99-110, :130-133).
- **Verification criterion (green):** `ExteriorDeepExclSupplyK.lean` `lake build` green with both :105
  and :133 sorries REMOVED and proved (`lean_verify` — no `sorryAx`). Full-scope check: all 6 files
  build green; only :116/:105/:133 discharged; KampPrior:519/:522 still present and unchanged.
- **Fallback trigger:** as Phase 7 — `[BLOCKED]` before any retained sorry.
- **Tasks:**
  - [ ] Discharge :105 (Fut arm) sorry-free.
  - [ ] Discharge :133 (Past arm) sorry-free.
  - [ ] Full 6-file build green; confirm :519/:522 untouched.
- **Timing:** 2-3 hours
- **Depends on:** 7

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from 369 reports/01+02, task-370 reports/01
adjudication, and the machine-confirmed failure modes.

**Do NOT**:
- Modify the frozen `bracketEndChar_kv` (CarrierKv.lean:238-249) — it breaks BOTH frozen `rfl` bridges
  (`bracketEndChar_kv_succ_eq` IGGK:339-351 AND `bracketEndChar_kv_one_eq` CarrierKv:294-351). Zero
  frozen-boundary defeq breaks. This is Option A, which is REJECTED.
- Re-open the A-vs-B gate (SETTLED: Option B) or the M1 refutation (SETTLED: 369 reports/01) without a
  concrete `lean_goal`-documented counterexample.
- Retain ANY sorry to paper over an unprovable de-folded↔frozen bridge. The correct terminus is the
  Fallback Ladder (scoped rfl-preserving Option A with user sign-off → `[BLOCKED]`), never a retained sorry.
- Retire, disturb, or re-type the pre-existing task-309/357 sorries at KampPrior.lean:519/:522 — they are
  OUT OF SCOPE for M2. Flag immediately if any phase's edit region approaches them.
- Re-dispatch `kampPrior_hreal_supply` (:116) against the current or `hepR`-enriched FOLDED interface —
  it is provably under-provisioned; it is dischargeable only against the de-folded endpoint.
- Churn the frozen defeq: if a phase makes a SECOND edit-attempt on the frozen CarrierKv fold or a `rfl`
  bridge to force a proof through, STOP and invoke the Fallback Ladder.

**MUST preserve**:
- The frozen carrier and both `rfl` bridges byte-identical (verify via `git diff` each phase).
- The entire existing folded chain (add SIBLING de-folded analogs; do not delete/mutate the folded ones).
- KampPrior.lean:519/:522 bodies unchanged.
- `lake build`-green at every phase boundary.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Option B (parallel non-folded carrier + full-chain re-proof) is the architecture — Option A's blast
  radius (28 files / 227 refs / 56 headers / 29 `.holds`, TWO frozen rfl breaks) is the reason.
- The de-folded carrier is a SIBLING; the parallel-to-frozen bridge need NOT be `rfl` (a proven `Eq`, or
  omission if the render path supersedes the frozen carrier, suffices).
- The render-free endpoint→arity-4 extraction (Phase 3, obligation #4) is the load-bearing decircularizing
  edit; `igFoldBit_realize_iff`'s render-hypothesis dependence is what makes the folded firing route circular.
- Rabinovich fidelity rests on PAGE-level grounds (Def 3.1 p.4 + ∨→∃∀ p.5) only — the md/chunk extract is
  index-flagged UNSAFE; never cite it by md:NN / chunk line.

## Testing & Validation

- [ ] Each phase: targeted `lake build` of the edited file(s) green before commit.
- [ ] Phases 7-8: `lean_verify` (or `#print axioms`) on the discharged lemmas shows no `sorryAx`.
- [ ] Final: all 6 in-scope files `lake build` green.
- [ ] Final: `git diff` confirms CarrierKv:238-249, IGGK:339-351, CarrierKv:294-351, and KampPrior:519/:522
  are unchanged.
- [ ] Final: only :116, :105, :133 sorries removed; no new sorries introduced anywhere.

## Artifacts & Outputs

- plans/01_defolded-carrier-option-b.md (this file)
- summaries/01_defolded-carrier-option-b-summary.md (on completion)
- Modified: InteriorGateGeneralK.lean, CarrierKv.lean (sibling def only), ExteriorGateAssembleK.lean,
  KampPrior.lean, InteriorHrealSupplyK.lean, ExteriorDeepExclSupplyK.lean

## Rollback/Contingency

- Per-phase commits allow reverting a single phase without losing prior green phases.
- If Phase 2/3 bridge (obligation #3/#4) proves unprovable: invoke the Fallback Ladder —
  (1) proven-`Eq` bridge or omission, (2) scoped rfl-preserving Option A (igFoldBit + frozen fold changed
  in tandem, byte-identical) with explicit user sign-off, (3) `[BLOCKED]` for user review. Never a retained
  sorry.
- If any phase must touch the frozen carrier or KampPrior:519/:522 to proceed: STOP, do not commit, and
  escalate `[BLOCKED]` — the frozen boundary is inviolable under Option B.
