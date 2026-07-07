# Implementation Plan: Task #320 — De-risk the Joint-Pinning Route for the k=2 Carrier Gate (F4 Follow-Up)

- **Task**: 320 - derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup
- **Status**: [NOT STARTED]
- **Effort**: 8 hours (range 6-10)
- **Dependencies**: None (parent task 309 blocked at Phase 13.35; this task de-risks before New Task 2 / task 321 implements)
- **Research Inputs**:
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (probe-order audit, GO-gate litmus)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 root cause, route b1/b2/b3 definitions)
- **Artifacts**: plans/01_derisk-jointpinning-probe.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; .claude/rules/artifact-formats.md; .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Parent task 309 is BLOCKED at Phase 13.35: finding F4 (the second-and-last k=2 correctness-gate
NO-GO under v7 Amendment F3's one-round uniformization budget). The landed `bracketEndChar_kvE'`
carrier flattens an interior positive sub's *joint* two-anchor content into a single evaluation-point
provider literal, leaving the funext residual `w = e 1`, `x = e 2` unpinnable (no hypothesis relates
the provider-chosen `e : Fin 3 -> M.carrier` to the honest anchors). This task does NOT rebuild the
carrier; it runs machine-checked *minimal probes* to decide which of three routes can structurally
carry the discriminating per-sub joint content, then emits a concrete design spec (for the GO route)
or an F5 defect record (if all routes NO-GO in budget). The deliverable is a report in this task's own
`reports/` directory. All probe code is scratch-only: no landed asset is edited, and any retained code
lands as a clearly-marked, non-consumed verdict addition per the F1-F4 house style.

Definition of done: (i) machine-checked probe results for each route attempted (rfl/exact/type-mismatch
states captured, no sorry landed on any live path); (ii) an explicit GO/NO-GO per route under the
position-by-evaluation-point litmus; (iii) for the GO route, a concrete named design spec (exact new
definition names, signatures, demonstrated-closed crux goal) that task 321 can implement directly; OR
(iv) an F5 defect record with a fresh counterexample if all routes NO-GO.

### Research Integration

The literature-alignment audit (report 01) revises the probe ladder from the spawn analysis's default
b1->b2->b3 order. Its load-bearing findings, integrated into the phase design below:

- **b3 (nested F_i-chain, Cor 5.4) is the literature-faithful LEAD route.** Rabinovich carries joint
  two-anchor content by the NESTED Until evaluation point (`F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`,
  Cor 5.4 md:154-157; Prop 3.5 single-free-variable nesting md:87-94), never by a single-point formula
  asserting a relative-position identity. Cross-validated by Gabbay's single-anchor separation (ch902
  md:17-45).
- **b1 is a BOXED fast falsifier (expected NO-GO).** Def 3.1 pinning (md:61-74) is real but pins sigma's
  OWN witnesses inside sigma's OWN bracket; it has no counterpart for pinning across the provider/`e`
  boundary (the actual F4 gap). Its value is as an F5-generator, not a live design candidate. Strictly
  timeboxed; must not consume the b3 budget.
- **b2 is a CONDITIONAL micro-check, not a route of its own.** `nf_eval_unique` / `nfPred_correct`
  uniqueness has no construction-level counterpart in Rabinovich or Gabbay and inherits the same
  sigma.2-exposure obstruction as b1. Pursue only if b3's design turns out to need a structural-identity
  hypothesis at a per-sub obligation site.
- **GO-gate litmus (position-by-evaluation-point):** a design passes GO only if every inter-anchor
  positional fact is carried by the EVALUATION POINT of a nested temporal operator, never by a formula
  asserted at a single evaluation point claiming a relative-position identity between two independently
  bound variables (the exact shape refuted by F3/F4).
- **MEDIUM-confidence claim to confirm FIRST** (audit claim 6): verify that `fChainFrom`/`fChainPred`
  (EANegation:552/:567) genuinely match the Cor 5.4 chain shape before any full b3 build — the audit
  relied on the codebase's own labelling for this.

### Prior Plan Reference

No prior plan exists for task 320. The binding constraints (Guards G1-G6, v7 Amendment F3, do-not-edit
asset list, CONSUME-DO-NOT-REBUILD list) are carried from parent task 309's plan v7 via the spawn
analysis (report 06) and are treated as fixed inputs, not re-litigated. Effort calibration (6-10h) is
inherited from the spawn analysis's New Task 1 estimate.

### Roadmap Alignment

No `roadmap_flag` was set for this dispatch; ROADMAP.md was not consulted for phase generation. This
task advances the Kamp's-theorem formalization track (topic `kamp_theorem_formalization`) by de-risking
the k=2 carrier gate that gates parent task 309's Phase 13.4 (general-k correctness) and Phase 14 (hook
rewire, `KampPrior.lean:351`).

## Goals & Non-Goals

**Goals**:
- Reconstruct the F4 crux goal and the provider-independent ℤ counterexample as a machine-checked
  baseline (the adversarial test case every route must be judged against).
- Machine-test route b1 (repair `kvE_pinDisjunct` to consume `witnessZone`) as a strictly timeboxed
  fast falsifier; capture its exact refutation state.
- Confirm (or refute) that `fChainFrom`/`fChainPred` match the Cor 5.4 chain shape before committing
  b3 design effort.
- Machine-probe route b3 (nested F_i-chain sub-bracket for the interior positive sub) with a minimal
  standalone probe — demonstrate whether evaluating the nested chain at the honest point recovers the
  honest positions WITHOUT any `e`-to-anchor equation.
- Conditionally micro-check route b2 only if b3 needs a structural-identity hypothesis.
- Apply the position-by-evaluation-point GO-gate litmus and emit an explicit GO/NO-GO per route.
- Deliver either a concrete named design spec (GO route) or an F5 defect record with fresh
  counterexample (all NO-GO), in this task's `reports/` directory.

**Non-Goals**:
- Full carrier surgery or a full corrected-carrier build (that is task 321 / New Task 2).
- Editing any landed asset (`bracketEndChar_kv*`, `kvE_pinDisjunct`, `kvE_exclConj`, the F1-F4 verdict
  records, `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material).
- Provider-side pinning / pinned-anchor converters (route (a), barred by v7 Amendment F3).
- Consuming `EANegation :1090/:1249` (uniform-backward sorries) — needing them is itself a blocker
  finding to record and escalate, never a silent absorption.
- Landing any sorry on a live path, or a partial theorem, on any route.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| b1 fast-falsifier over-runs its timebox, consuming b3 design budget (the F3->F4 failure mode) | H | M | Hard cap b1 at ~20% of probe budget (Phase 2 timing); on first confirmed unpinnable residual, stop and record the F5-candidate, do not iterate "make b1 work" |
| `fChainFrom`/`fChainPred` do NOT actually match Cor 5.4 shape (audit MEDIUM-confidence claim 6) | M | M | Phase 3 confirms shape BEFORE full b3 build; if mismatch, record it, raise b3 cost estimate, and probe the nested chain from `A_past`/`A_future` primitives instead — b3's faithfulness verdict rests on Cor 5.4 md:154-157 directly, not on the codebase labelling |
| b3 nested sub-bracket needs a structural-identity hypothesis that is not derivable at the obligation site | H | M | Phase 5 (b2 conditional micro-check) checks `nf_eval_unique`/`nfPred_correct` availability; if absent, record as a scoped sub-finding and treat b3 as NO-GO-pending rather than fabricating the hypothesis |
| A route "appears" to close by asserting a two-anchor identity in a single-point formula (another flattening patch) | H | M | GO-gate litmus (Phase 6) rejects on sight any candidate whose inter-anchor fact is carried by a single-point assertion rather than a nested evaluation point |
| All routes NO-GO in budget (F5 outcome) | M | M | Phase 7 emits a full F5 defect record with a fresh counterexample and an explicit escalation recommendation — this is a legitimate deliverable, never silent absorption |
| Scratch probe accidentally edits or is confused with a landed asset | H | L | Phase 1 records the do-not-edit / CONSUME-DO-NOT-REBUILD lists; Phase 8 verifies byte-identity of landed assets and confirms scratch is discarded or marked non-consumed |
| `simp`/`omega`/`aesop` shortcut smuggled into an F_i chain step (violates G5) | M | L | G5 discipline: every chain step cited to Rabinovich per-step; Phase 8 greps probe code for forbidden tactics on chain-construction lines |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 2, 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. Phase 2 (b1 fast falsifier) and Phase 3 (Cor 5.4
shape confirmation) are independent and share Wave 2; keeping them parallel protects the b3 budget by
letting the shape check proceed regardless of b1's outcome.

---

### Phase 1: Scratch harness + F4 crux-goal / counterexample baseline [COMPLETED]

**Goal**: Stand up a scratch probe context and reproduce the F4 crux goal and the provider-independent
ℤ counterexample as a machine-checked baseline, so every subsequent route probe is judged against the
same adversarial test case.

**Tasks**:
- [ ] Read the F4 verdict record (`NfMultiAnchorBridge.lean` final section after :5533) and the F3 record
  immediately preceding it; transcribe the exact crux goal state (`he : nf_eval_nf M 1 (3+1) (insertEnv e t) sigma`
  vs goal `nf_eval_nf M 1 (3+1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ => t))) sigma`, residual `w = e 1`, `x = e 2`).
- [ ] Record the do-not-edit asset list and the CONSUME-DO-NOT-REBUILD list verbatim into a scratch
  notes header, so no landed asset is touched.
- [x] Reconstruct the counterexample in scratch: `M = ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
  dishonest positive `sigma'' = char[14,16,11,20]`, honest `char[14,15,10,20]` marked false; confirm it
  is on-fiber (zone `zXW`, fresh type `type(14)`, sharing sigma.1 while differing at sigma.2). *(deviation: altered — the ℤ counterexample is the one already machine-recorded and re-certified green in the landed F4 verdict record (:5584-5595); rather than rebuild a standalone ℤ ExistProviders term, the baseline is captured mechanistically via probe P1, which `rfl`-re-confirms the channel-(i) collapse that IS the counterexample's root (`type(14)=type(15)` share). Byte-identity + green build re-certify the landed counterexample.)*
- [x] Machine-confirm the baseline: the F4 statement is FALSE against `bracketEndChar_kvE'` for this
  counterexample (the defect still reproduces) — capture the rfl/type-mismatch state. *(completed via probe P1 `rfl` + the landed, green-re-certified F4 record probe A/B states.)*
- [ ] Cite Def 3.1 (Rabinovich md:61-74) and the F4 record for the crux-goal shape.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- Scratch probe file only (e.g. `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/scratch/F4Probe.lean` or an in-repo scratch section) — NO landed asset edited.

**Verification**:
- The reconstructed counterexample type-checks and the F4 falsity is machine-confirmed (baseline captured).
- The do-not-edit and CONSUME-DO-NOT-REBUILD lists are recorded in the scratch header.

---

### Phase 2: Route b1 boxed fast falsifier (consume `witnessZone`) [COMPLETED]

**Goal**: Machine-test whether repairing channel (i) to actually consume `witnessZone` (point type
`alpha_j` + adjacent interval types `beta_j`, `beta_{j+1}` relative to `(x,w,t)`, per Def 3.1) can force
`e 1 = w`, `e 2 = x`. Expected NO-GO; the value is a captured refutation strengthening the F4/F5 record.

**Tasks**:
- [ ] In scratch, build a repaired `kvE_pinDisjunct`-analogue that encodes which of the seven consistent
  zones the pin witness occupies AND the two adjacent segment types, using the landed non-trivial-segment
  machinery (`A_past`/`A_future` NfZoneFlattenNavigable:335/:386, `bracketBuildLeft/Right` VecEATranslation
  — fixed-endpoint literals only, per G3/N4). Additive scratch only.
- [ ] Attempt to discharge the funext residual `w = e 1`, `x = e 2` from the repaired channel's deliverable.
- [ ] Capture the exact failure state (the repaired pin constrains sigma's OWN fresh witness placement,
  not the provider's independently-bound `e` — confirm or refute machine-side).
- [ ] Cite Def 3.1 (md:61-74) for the pinning discipline and record whether the across-`e`-boundary gap
  is genuinely unreachable by a zone-faithful pin.

**Timing**: 1.5 hours (HARD CAP ~20% of probe budget — on first confirmed unpinnable residual, STOP; do
not iterate toward "making b1 work").

**Depends on**: 1

**Files to modify**:
- Scratch probe file only.

**Verification**:
- Explicit machine-captured GO/NO-GO for b1 with the rfl/exact/type-mismatch state recorded.
- If NO-GO (expected): the refutation is documented as an F5-candidate with the sharpened diagnosis
  (Def 3.1 pins within-bracket, not across the provider boundary).

---

### Phase 3: Cor 5.4 chain-shape confirmation for `fChainFrom`/`fChainPred` [COMPLETED]

**Goal**: Confirm (or refute) the audit's MEDIUM-confidence claim that `fChainFrom`/`fChainPred`
(EANegation:552/:567) genuinely match the Cor 5.4 chain shape `F_n := alpha_n`,
`F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)` — BEFORE any full b3 build.

**Tasks**:
- [ ] Read `fChainFrom`/`fChainPred` (EANegation:552/:567) signatures and definitions.
- [ ] Compare their recursion shape step-by-step against Cor 5.4 (md:154-157): base `F_n := alpha_n`,
  step `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`, with the increasing sequence recovered by
  unfolding the nested Until (each `alpha_i` landing at its own witness position).
- [ ] Record a machine-checked verdict: MATCH (b3 can reuse these landed shapes) or MISMATCH (b3 must
  build the nested chain from `A_past`/`A_future` primitives; raise the b3 cost estimate).
- [ ] Cite Cor 5.4 (md:154-157) and Prop 3.5 (md:87-94) per the G5 discipline.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- Scratch probe file only.

**Verification**:
- An explicit MATCH/MISMATCH verdict recorded, with the specific structural correspondence (or divergence)
  between `fChainFrom`/`fChainPred` and Cor 5.4 cited line-by-line.

---

### Phase 4: Route b3 primary design probe (nested F_i-chain sub-bracket) [COMPLETED]

**Goal**: Machine-probe a MINIMAL nested-Until sub-bracket that gives the interior positive sub's own
witness `u` an explicit two-anchor sub-bracket relative to the CURRENT bracket's real interval
decomposition, so that TL evaluation at the actual honest point yields the honest positions directly —
WITHOUT any `e`-to-anchor equation. This is the demonstrated-closed crux goal task 321 needs.

**Tasks**:
- [ ] Using the Phase 3 verdict, construct a minimal nested sub-bracket for `u`: reuse `fChainFrom`/
  `fChainPred` if MATCH, else build from `A_past`/`A_future`/`bracketBuildLeft/Right`/`VVecEA2`
  (VecEAFormula:271, NfMultiAnchorBridge:1883, VecEAClosure:265), generalized rather than reused verbatim,
  never a third anchor (G6-as-amended).
- [ ] Demonstrate that evaluating the nested chain at the honest point recovers the honest positions
  `(w,x)` directly — the same mechanism that already lets `A_past`/`A_future` see `(x,t)` under G3,
  generalized one level.
- [ ] Verify the joint content rides the nested Until EVALUATION POINT, not a single-point assertion
  (pre-check against the GO-gate litmus applied fully in Phase 6).
- [ ] Confirm G1-G6 compliance: no arity-1 collapse (G1), no projection-based VecEA2/third-anchor tower
  (G2), no trivial-top off-diagonal segment (G3), `w` stays a bracket WITNESS with anchor set `{x,t}`
  fixed at 2 (G4), F_i chain steps cited step-by-step with no `simp`/`omega`/`aesop` (G5), two-anchor
  fixed-endpoint bracket / `VVecEA2` witness-growing codomain (G6).
- [ ] Cite per G5 at each chain step: Def 3.1 (md:61-74), Prop 3.5 (md:87-94), Cor 5.4 (md:154-157),
  Lemma 5.1 point-insertion split (md:159-173); Gabbay ch902 md:17-45 as a single-anchor cross-validation
  margin note.
- [ ] Capture the machine state: crux goal demonstrated-closed (no residual `w=e1`/`x=e2`, no sorry on
  the live path) OR the exact obstruction if the nested chain still cannot pin.

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- Scratch probe file only.

**Verification**:
- The minimal nested sub-bracket type-checks and either closes the crux goal without an `e`-to-anchor
  equation (GO evidence) or exposes a precise obstruction (feeds Phase 5 / Phase 7).
- No sorry landed on the live path; all chain steps carry Rabinovich citations.

---

### Phase 5: Route b2 conditional structural-identity micro-check [COMPLETED]

**Goal**: ONLY if Phase 4's b3 design needs a structural-identity hypothesis at a per-sub obligation
site, check whether `nf_eval_unique` (NormalForm:245) / `nfPred_correct` (NfToVecEA:69) can supply it —
i.e. that sigma IS (by the outer recursion's own construction/selection) the complete type realized by
the actual honest quadruple `[u,w,x,t]` at the site where b3 needs it.

**Tasks**:
- [x] Gate check: does Phase 4's nested chain require a structural-identity hypothesis at the
  zone/arrangement selection machinery? If NO, record "b2 not needed — b3 closes without it" and treat
  this phase as a no-op with a recorded reason. *(RESULT: b2 NOT NEEDED. Probe P4 (`probe_P4_b3_positions_by_eval_point`) closes the b3 recovery with `bf.holds` as its SOLE hypothesis — no `nf_eval_unique`/`nfPred_correct`/uniqueness premise appears anywhere in its signature. The absence of such a premise in a type-checked theorem IS the machine evidence that b3 needs no structural-identity assist. Phase treated as recorded no-op.)*
- [ ] If YES: probe whether the selection fact ("sigma is the honest quadruple's complete type at this
  obligation site") is ALREADY derivable from `nf_eval_unique`/`nfPred_correct` at the actual 13.25/13.35
  binder shapes — do NOT build new plumbing speculatively.
- [ ] Capture the machine state: hypothesis available (b3 GO with b2 as a lemma-level assist) OR absent
  (record as a scoped sub-finding; b3 is NO-GO-pending, escalate rather than fabricate).
- [ ] Note the sigma.2-exposure obstruction (the discriminating content lives in sigma.2, which the
  carrier collapses) if it recurs here.

**Timing**: 1 hour (conditional — may be a recorded no-op)

**Depends on**: 4

**Files to modify**:
- Scratch probe file only.

**Verification**:
- Either a recorded "not needed" no-op with reason, or an explicit available/absent verdict for the
  structural-identity hypothesis with the exact binder-shape evidence.

---

### Phase 6: GO-gate litmus + per-route GO/NO-GO decision [NOT STARTED]

**Goal**: Apply the position-by-evaluation-point litmus to each probed route and emit an explicit
GO/NO-GO decision, ensuring no route is passed that carries a two-anchor positional identity inside a
single-point formula.

**Tasks**:
- [ ] For each route (b1, b2-if-run, b3), apply the litmus: GO only if every inter-anchor positional fact
  is carried by the EVALUATION POINT of a nested temporal operator, never by a single-point formula
  asserting a relative-position identity between two independently-bound variables.
- [ ] Record the per-route verdict table (route -> machine state -> litmus pass/fail -> GO/NO-GO).
- [ ] Confirm the expected pattern (b1 NO-GO, b2 conditional, b3 GO-if-Phase-4-closed) or document the
  deviation.
- [ ] Determine the overall outcome: at least one GO route (-> Phase 7 design spec) or all NO-GO
  (-> Phase 7 F5 defect record).

**Timing**: 1 hour

**Depends on**: 2, 4, 5

**Files to modify**:
- Scratch probe file only (verdict notes).

**Verification**:
- A complete per-route GO/NO-GO table with litmus justification for each verdict.
- An unambiguous overall outcome selecting the Phase 7 deliverable branch.

---

### Phase 7: Deliverable — design spec (GO) or F5 defect record (all NO-GO) [NOT STARTED]

**Goal**: Author the task deliverable report in this task's `reports/` directory, in the F1-F4 house
style, matching whichever branch Phase 6 selected.

**Tasks**:
- [ ] Write `specs/320_.../reports/02_jointpinning-probe-results.md` containing: (i) machine-checked probe
  results per route (rfl/exact/type-mismatch states captured); (ii) explicit GO/NO-GO per route.
- [ ] GO branch (b3, expected): include a concrete design spec — exact new definition names, signatures,
  and the demonstrated-closed crux goal — that task 321 can implement directly without re-deriving the
  decision. Make explicit that "carrier" denotes the Cor 5.4 recursive construction (a formula-building
  recursion over interior subs), not a flat carrier with more channels.
- [ ] NO-GO branch (all routes fail in budget): include a new F5 defect record with a fresh counterexample
  proving the joint-pinning content is inexpressible in the current per-sub-literal `ExistProviders`
  architecture, plus an explicit escalation recommendation (do NOT silently absorb).
- [ ] If any route needed `EANegation :1090/:1249` or provider-side pinning, record it as a blocker
  finding to surface, per the binding constraints.
- [ ] Cite Rabinovich per G5 throughout (Def 3.1, Prop 3.5, Cor 5.4, Lemma 5.1; Gabbay ch902 as
  cross-validation).

**Timing**: 1.5 hours

**Depends on**: 6

**Files to modify**:
- `specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md` (new report).

**Verification**:
- The report exists, is non-empty, and contains the required sections (per-route machine results, GO/NO-GO,
  and either a named design spec or an F5 defect record with counterexample).

---

### Phase 8: Scratch cleanup + landed-asset integrity verification [NOT STARTED]

**Goal**: Ensure no landed asset was edited and the scratch probe code is either discarded or landed as
a clearly-marked, non-consumed verdict addition, and that the repository still builds.

**Tasks**:
- [ ] Verify byte-identity of all do-not-edit assets (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1/F2/F3/F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material) via `git diff` — expect no
  changes.
- [ ] Discard scratch probe code, OR land it as an ADDITIVE, clearly-marked non-consumed
  scratch/verdict addition alongside the F4 record (never an edit of a landed asset), per house style.
- [ ] Grep retained probe code for forbidden `simp`/`omega`/`aesop` on F_i chain-construction lines (G5).
- [ ] Run `lake build` on the affected module to confirm the tree is green (no new sorry on a live path,
  no broken landed asset).

**Timing**: 0.5 hours

**Depends on**: 7

**Files to modify**:
- Scratch probe file (discarded or converted to a marked non-consumed addition); no landed asset.

**Verification**:
- `git diff` shows zero changes to any do-not-edit asset.
- `lake build` passes; no sorry on any live path; no forbidden tactic on any chain step.

---

## Testing & Validation

- [ ] F4 baseline reproduces: the ℤ counterexample makes the `bracketEndChar_kvE'` statement FALSE
  (Phase 1 machine-confirmed).
- [ ] Each route has a machine-captured GO/NO-GO with its rfl/exact/type-mismatch state (Phases 2, 4, 5, 6).
- [ ] `fChainFrom`/`fChainPred` MATCH/MISMATCH verdict against Cor 5.4 recorded (Phase 3).
- [ ] GO-gate litmus applied to every route; no route passed on a single-point positional assertion (Phase 6).
- [ ] Deliverable report exists with either a named design spec or an F5 defect record + counterexample (Phase 7).
- [ ] No landed asset edited (byte-identical `git diff`); `lake build` green; no live-path sorry (Phase 8).
- [ ] No consumption of `EANegation :1090/:1249` or provider-side pinning (or, if needed, recorded as an
  escalated blocker finding).

## Artifacts & Outputs

- plans/01_derisk-jointpinning-probe.md (this file)
- reports/02_jointpinning-probe-results.md (deliverable: per-route machine probe results, GO/NO-GO,
  design spec OR F5 defect record)
- summaries/01_derisk-jointpinning-probe-summary.md (implementation summary, produced by /implement)
- Scratch probe file: discarded or landed as a clearly-marked non-consumed verdict addition (no landed
  asset edited)

## Rollback/Contingency

- All probe work is scratch-only and additive; rollback is discarding the scratch file — no landed asset
  is at risk (Phase 8 verifies byte-identity).
- If the b3 probe (Phase 4) cannot be completed in budget, mark Phase 4 [PARTIAL], capture the partial
  nested-chain state, and record the remaining obstruction; the deliverable becomes an F5-pending record
  with an explicit "b3 not closed in budget" escalation rather than a fabricated GO.
- If all routes NO-GO, the F5 defect record IS the deliverable (not a failure state) — route directly to
  escalation per the spawn analysis's After-Completion guidance, do NOT open a third mechanical channel round.
- On any need to consume `EANegation :1090/:1249` or attempt provider-side pinning, STOP and record the
  blocker finding — these are barred and their necessity is itself an escalation trigger.
