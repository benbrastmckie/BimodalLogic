# Implementation Plan: Corrected k=2 Carrier (nested F_i-chain) and F4 Correctness-Gate Resolution

> **[SUPERSEDED by plans/02_corrected-k2-carrier-fi-chain-v2.md]** — This v1 plan BLOCKED at Phase 2
> (task-320 design spec §5 was probe-level: general-`k` `σ.2` unrealizable; encoding under-specified;
> no k≥2 gate precedent). Blocker research (`reports/01_blocker-research-successor-k.md`) resolved all
> three findings with machine-checked formulations, and v2 supersedes this plan. Phase 1 [COMPLETED]
> here is preserved verbatim in v2. Retained for history only; do not implement from this file.

- **Task**: 321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Status**: [SUPERSEDED]
- **Effort**: 14 hours
- **Dependencies**: 320 (GO verdict on route b3, design spec §5 — COMPLETED)
- **Research Inputs**:
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md (design spec §5, route b3 GO)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (binding framing caveat)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 blocker origin)
- **Artifacts**: plans/01_corrected-k2-carrier-fi-chain.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

Task 320's machine-checked probe returned a clean GO on route **b3** (nested F_i-chain / bracket
recursion, Rabinovich Cor 5.4) for the k=2 carrier correctness gate, refuting the flat-carrier
route b1 (NO-GO by `rfl`) and establishing that the structural-identity route b2 is not needed
(`probe_P4_b3` closes with `bf.holds` as sole hypothesis). This task builds the FULL corrected
carrier construction under NEW names per the task-320 design spec §5 — `kvE_subBracket`,
`kvE_subChain`, `kvE2_body`, `bracketEndChar_kvE2` — **additive** alongside the landed (do-not-edit)
`bracketEndChar_kvE` (13.2) and `bracketEndChar_kvE'` (13.25), then re-runs the k=2
`BracketCarrierCorrectVPrior` gate to a **GO** verdict. The mandatory adversarial test is the F4
provider-independent ℤ counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
`σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` marked false), which MUST now FAIL against the
new construction because `kvE_subBracket` reads `σ.2` (where the two subs differ) rather than the
shared `σ.1` `nfk_projFresh`.

Definition of done: `bracketEndChar_kvE2` lands additively; the k=2 correctness gate passes to a
recorded GO verdict; the F4 ℤ counterexample is discriminated (LHS FALSE at `(10,20)` under the new
carrier); green `lake build`; axiom-clean (`propext`, `Classical.choice`, `Quot.sound`); no `sorry`
on any live path; every do-not-edit landed asset byte-identical; a verdict record landed either way.

### Research Integration

The task-320 report §5 supplies the complete, directly-implementable design spec (route b3 GO) —
this plan implements it WITHOUT re-deriving the decision. Key machine-established facts consumed:

- **§2 (route b1 NO-GO)**: channel-(i) collapse is `rfl`-confirmed vacuous (function of `σ.1` alone);
  the flat carrier can never carry inter-anchor position. A third flat carrier variant is OUT OF SCOPE.
- **§3 (Cor 5.4 chain-shape MATCH)**: the landed `BracketFormula.fChainFrom_step`/`fChainFrom_base`
  (EANegation:616/580) coincide definitionally with Cor 5.4's `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`.
  No fallback to rebuild the chain from `A_past`/`A_future` primitives is required.
- **§4 (route b3 GO)**: the landed, PROVEN `BracketFormula.bracket_implies_fChainPred`
  (EANegation:660) recovers honest witness positions from `bf.holds` alone, `e`-free — position
  carried by the nested-Until evaluation point (position-by-evaluation-point litmus PASS).
- **§5**: the ONLY new construction obligation is `kvE_subBracket`'s `σ.2` read; the recovery
  mechanism is entirely landed, proven `fChain` machinery.
- **§6 (route b2 NOT NEEDED)**: no `nf_eval_unique`/`nfPred_correct` structural-identity hypothesis is
  required; do NOT build that plumbing speculatively.

### Prior Plan Reference

No prior plan exists for task 321. The lineage context (v6→v7 re-pointing pattern, F1–F4 house
style, one-round budget) is carried from the parent task 309's plan v7 via the task-320 report and
the task description; this plan honors those constraints as binding but does not template from a
prior 321 plan.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context; `roadmap_flag` not set). Goal-state
alignment for the enclosing chain: this task's GO gate is the prerequisite for task 309's Phase 13.4
(general-k one-step correctness) and Phase 14 (hook rewire discharging KampPrior.lean:351's strategic
`sorry`, target axioms exactly `[propext, Classical.choice, Quot.sound]`). After completion, task 309
resumes via `/implement 309` (possibly preceded by `/revise 309` for a v8 re-pointing to the new
deliverable names).

## Goals & Non-Goals

**Goals**:
- Land `kvE_subBracket` (nested sub-bracket reading `σ.2`), `kvE_subChain` (its `fChainPred`),
  `kvE2_body` (corrected enriched body), `bracketEndChar_kvE2` (corrected carrier) — additive, under
  the task-320 §5 names.
- Discharge the per-sub positive soundness crux (previously the unpinnable `w = e 1`, `x = e 2`) by
  instantiating `probe_P4_b3`-style `bracket_implies_fChainPred` at `bf := kvE_subBracket … σ`.
- Re-run the k=2 `BracketCarrierCorrectVPrior` gate to a recorded GO verdict.
- Prove the F4 ℤ counterexample now FAILS against `bracketEndChar_kvE2` (mandatory adversarial test).
- Preserve every do-not-edit landed asset byte-identical; land a verdict record either way.

**Non-Goals**:
- No third FLAT carrier variant (another `kvE''`-style body with smarter per-sub literals evaluated
  at `t`) — that is the exact F3/F4-refuted shape, OUT OF SCOPE regardless of intermediate suggestion.
- No provider-side pinning (v7 Amendment F3 binding).
- No consumption of `EANegation :1090/:1249`.
- No structural-identity / `nf_eval_unique` / `nfPred_correct` hypothesis (route b2 NOT NEEDED).
- No edits to any landed asset (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1–F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material, the task-320 probes).
- No general-k work (task 309 Phase 13.4/14) — out of scope for this task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `σ.2` exposure at the sub level needs a projection that does not exist among landed normal-form projections | H | M | Reuse the landed `nf_x_proj3`/`nf_t_proj3`/`nf_y_proj` family (VecEADecomp:33-47) at the sub level; if a needed projection is genuinely absent, define it additively as a thin wrapper, never editing landed projections; escalate before inventing a two-anchor single-point read (design smell per Gabbay cross-check). |
| Temptation to flatten `kvE_subBracket` back into a single-point per-sub literal under proof pressure | H | M | Position-by-evaluation-point litmus is the GO gate; every inter-anchor fact MUST ride a nested-Until eval point (probes P3/P4). A single-point relative-position assertion is an automatic escalation, not an engineering workaround (G6-as-amended, framing caveat). |
| Forbidden tactics (`simp`/`omega`/`aesop`) creeping into chain-construction bodies | M | M | G5: cite Rabinovich at every chain step; `by omega` permitted ONLY for `Fin`-index typing obligations in signatures (identical to landed `fChainFrom_step`), never in a chain-construction body. |
| Accidental edit / byte drift of a do-not-edit landed asset | H | L | Snapshot do-not-edit assets in Phase 1; verify byte-identity via `git diff` (expect additive `+N/-0`) in Phase 9; all new defs land AFTER the task-320 probe section. |
| Correctness gate does not close (soundness direction stalls at a residual) | H | L | The crux is already machine-probed closed (§4/§5); Phase 7 instantiates the landed proven `bracket_implies_fChainPred` — if a residual `e`-equation reappears, the joint literal was not fully replaced (return to Phase 5), NOT a new pinning device. |
| F4 counterexample does not discriminate (LHS still holds) | H | L | Phase 8 verifies `kvE_subBracket` reads `σ.2` at the point the two subs differ; if LHS still holds, the `σ.2` read is incomplete — fix the construction (Phase 3), do not weaken the test. |
| Anchor growth / third-anchor tower slips in (G2/G4/G6 violation) | H | L | Anchor set fixed at 2 `{x,t}`; F_i witnesses are bracket witnesses BETWEEN the fixed endpoints; `kvE_subBracket` generalizes one level, never a third anchor. Verify in Phase 9. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. This construction is inherently sequential
(each carrier layer builds on the previous), so each wave holds one phase.

### Phase 1: Baseline capture and landed-asset integrity snapshot [COMPLETED]

- **Goal:** Establish a green baseline, record the F4 counterexample state, and snapshot every
  do-not-edit landed asset so byte-identity can be verified at the end.
- **Tasks:**
  - [x] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` and confirm green
        (baseline, ~1005 jobs); confirm the task-320 probe section (`probe_P1`/`probe_P3`/`probe_P4`)
        is present and axiom-clean. *(completed — build exit 0; probes present at :5634-5698)*
  - [x] Record the byte ranges / signatures of do-not-edit assets: `bracketEndChar_kv`, `kvE_body`,
        `bracketEndChar_kvE`, `bracketEndChar_kvE'`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
        the F1–F4 verdict records, `ExistProviders`, `BracketCarrierCorrectVPrior`, the task-320 probes
        (`git stash`-free snapshot; note current `git diff` is clean). *(completed — git diff clean on Lean file)*
  - [x] Re-capture the F4 crux goal and ℤ counterexample verbatim from the F4 record (:5559-5595) and
        the design spec §1 as the Phase 8 acceptance oracle. *(completed — recorded in-file at :5584-5595)*
  - [x] Confirm the CONSUME-DO-NOT-REBUILD asset list is available (E[Σ]-fold engine, k1v proof kit,
        `nf_eval_unique`/`nfPred_correct`, `A_past`/`A_future`, `bracketBuildLeft/Right`,
        `VVecEA2`/`bracketFromLists`/`existsBounded_right`, `fChainFrom`/`fChainPred`,
        EANegationClosure forward stack proof-side only, `prior_hasAttainedINF`/`HasAttainedINF`).
- **Timing:** ~1 hour
- **Depends on:** none
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — read-only this phase
    (no edits; snapshot + baseline build).
- **Verification:**
  - Green scoped build; task-320 probes present and axiom-clean; `git diff` clean at phase start.

### Phase 2: Expose σ.2 inner-witness structure via sub-level projections [BLOCKED]

**BLOCKER** (Phase 2 — surfaced here; also gates Phases 3-9):
- **What failed**: Two independent, machine-grounded obstructions to the task-320 design spec §5,
  discovered during Phase 2 feasibility probing.
  1. **Design-spec §5(1) signature is not realizable as written.** The spec gives
     `kvE_subBracket … (σ : NormalForm sig k 4) : BracketFormula m` with **general `k`** and says
     read `σ.2`. Machine-confirmed: `σ.2` for `σ : NormalForm sig k 4` with a *variable* `k` fails to
     elaborate — `error: Invalid projection … the expression σ has type NormalForm sig k 4 which does
     not have fields` (NfMultiAnchorBridge.lean scratch probe at ~:5708). `NormalForm sig k 4` only
     reduces to a pair `(atom_assgn, quant_assgn)` when `k` is a *literal successor*
     (`NormalForm.lean:134-136`). A successor-specialized signature `(σ : NormalForm sig (k+1) 4)`
     *does* elaborate (scratch `scratch_innerSubs_succ` built green), but the general-`k` body
     `kvE'_body`/`kvE2_body` (parametric `{k}`, subs `σ : NormalForm sig k 4`) cannot call a
     successor-only `kvE_subBracket` without a `k`-matching reformulation that the design spec does
     not supply. The spec's "SINGLE new construction obligation … expose σ.2 via projections" glossed
     this type-level obstruction; the honest resolution needs a design decision (match `kvE2_body` on
     `k`, or restate the whole enriched-body/carrier family at successor-sub depth), not present in §5.
  2. **The concrete `pointTypes`/`segmentTypes` encoding is under-specified and unvalidatable in
     isolation.** §5(1) gives the *shape* ("σ's inner-witness structure as bracket witnesses between
     the honest anchor pair, read from σ.2") but not the Lean term mapping `σ.2 : NormalForm sig 0 5 →
     Bool` (at the k=2 gate) to `pointTypes : Fin m → TemporalPred` / `segmentTypes : Fin (m+1) →
     TemporalPred`. Choosing this encoding IS the research contribution; landing an *invented*
     encoding whose semantic correctness cannot be validated without the (unbuilt) Phase 7-8 gate is
     exactly the under-proof-pressure construction the plan's Risk row 2 and Non-Goals forbid (the
     flat-variant trap; "single-point relative-position assertion is an automatic escalation").
- **What was tried**:
  - Read design spec §5 (task-320 report 02), the landed `kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`
    (:5374-5530), the F4 record (:5532-5608), probes P1/P3/P4 (:5634-5698), `BracketFormula`
    (VecEAFormula:128), `fChainFrom`/`fChainPred`/`bracket_implies_fChainPred` (EANegation:552-698),
    `NormalForm`/`nf_eval_nf` (NormalForm:134-207), `BracketCarrierCorrectVPrior`/`ExistProviders`
    (NfMultiAnchorBridge:4853-4888).
  - Machine probe: `scratch_innerSubs_succ` (`σ : NormalForm sig (k+1) 4`, reads `σ.2`) — **built
    green**. `scratch_innerSubs_genk` (`σ : NormalForm sig k 4`, per §5(1)) — **type error** ("does
    not have fields"). Both scratch probes removed; file restored byte-identical to the green baseline.
- **Why it's stuck**: The design spec is at the probe/abstract level (P3/P4 operate on an *abstract*
  `bf : BracketFormula (n+1)`, never constructing one from a general-`k` sub's `σ.2`). Bridging from
  the abstract recovery lemma to a concrete, general-`k`-integrable `kvE_subBracket` requires
  resolving (1) the successor-depth `k`-matching and (2) the concrete inner-NF → bracket encoding —
  neither supplied by §5. Downstream, Phases 7-8 require the **first-ever proven k≥2
  `BracketCarrierCorrectVPrior`** for an enriched carrier: the only landed proven instances are the
  *simple* `bracketEndChar_kv` at k=0/k=1 (:4899/:4915); both prior enriched k=2 gates
  (`bracketEndChar_kvE` :5203, `bracketEndChar_kvE'` :5532) are NO-GO defect records (F1/F4). No
  successful k≥2 template exists to reuse, and the reverse direction (honest realization ⟹
  sub-bracket holds) plus the fChainPred→`nf_eval_nf` semantic bridge are unprobed and unbuilt.
- **What is needed** (to unblock — user / `/revise 321` decision):
  1. Amend the design spec (or task 320 report §5) with the concrete `kvE_subBracket` term: the exact
     `k`-matching reformulation of `kvE2_body` (successor-sub specialization) AND the explicit
     `pointTypes`/`segmentTypes` construction from `σ.2`'s inner NFs, with the intended
     `nf_eval_nf`-connection stated.
  2. Confirm the Phase 7-8 gate proof strategy against the reality that no proven k≥2 enriched-carrier
     correctness precedent exists — likely a dedicated multi-phase proof-build task, not a single
     construction pass.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, a vacuous placeholder, or an
  invented flat/single-point per-sub literal (OUT OF SCOPE, F3/F4-refuted). Escalated per the plan's
  "design smell → escalate, do not engineer around" directive (Risks table; Gabbay cross-check).

- **Goal:** Provide the `σ.2` read the design spec §5 identifies as the SINGLE new construction
  obligation — expose an interior positive sub's inner anchor/segment types from its own normal form.
- **Tasks:**
  - [ ] Identify, for `σ : NormalForm sig k 4`, the projections that expose σ's inner-witness
        structure (σ's own `u`, inner anchor pair, inner segment types) from `σ.2`, reusing the landed
        `nf_x_proj3`/`nf_t_proj3`/`nf_y_proj` pattern (VecEADecomp:33-47). *(deviation: BLOCKED — the
        design-spec §5(1) general-`k` signature `(σ : NormalForm sig k 4)` cannot read `σ.2`
        (machine-confirmed type error "does not have fields"); only successor-depth `(k+1)` elaborates,
        requiring a `k`-matching reformulation not supplied by §5.)*
  - [ ] Define, additively, any thin wrapper projections needed to read σ's inner anchor/segment types
        at the sub level (e.g. `nfk_subAnchor`/`nfk_subSegment`-style), each a projection over the
        existing normal-form structure — NOT a derived-identity hypothesis (route b2 is NOT NEEDED).
        *(deviation: BLOCKED — concrete `pointTypes`/`segmentTypes` encoding from `σ.2` is
        under-specified in §5 and unvalidatable without the unbuilt Phase 7-8 gate.)*
  - [ ] Confirm the read distinguishes the F4 pair: on `σ''=char[14,16,11,20]` vs honest
        `char[14,15,10,20]` the `σ.2` read must differ (they share `σ.1` `nfk_projFresh`=`type(14)`
        but differ at `σ.2`). *(deviation: not reached — gated behind the projection obstruction above.)*
- **Timing:** ~2 hours
- **Depends on:** 1
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append new projection
    wrappers after the task-320 probe section.
- **Verification:**
  - Scoped build green; a `#eval`/`rfl` micro-check (in a NON-CONSUMED scratch block or via
    `lean_multi_attempt`) shows the `σ.2` read yields DIFFERENT values on the F4 dishonest vs honest
    sub; no `simp`/`omega`/`aesop` in any construction body.

### Phase 3: Construct kvE_subBracket (nested sub-bracket over σ.2) [NOT STARTED]

- **Goal:** Build `kvE_subBracket … (σ : NormalForm sig k 4) : BracketFormula m` encoding σ's
  inner-witness structure as bracket witnesses between the honest anchor pair for σ's zone, read from
  `σ.2` — the Cor 5.4 recursive construction, generalized one level, never a third anchor.
- **Tasks:**
  - [ ] Define `kvE_subBracket {sig} {k} (charBase) (charK) (r : NormalForm sig 0 3)
        (σ : NormalForm sig k 4) : BracketFormula m` with the signature from design spec §5(1).
  - [ ] Build the `pointTypes`/`segmentTypes` of the sub-bracket from σ's inner anchor/segment types
        (Phase 2 reads), with `m` = number of σ's inner witnesses (≥ 1; the sub's own `u`).
  - [ ] Assemble via landed fixed-endpoint machinery (`bracketBuildLeft/Right`, `bracketFromLists`,
        `VVecEA2`) per G3/N4/G6 — endpoints are the honest anchor pair `(x,w)` or `(w,t)` per σ's zone;
        cite Rabinovich Lemma 5.1 point-insertion split (md:159-173) for endpoint sharing.
  - [ ] Verify G-guard compliance: no arity-1 collapse (G1); no projection-based VecEA2/third-anchor
        tower (G2); off-diagonal segments carry real interval types via `segmentTypes`, not trivial-top
        (G3); anchor set fixed at 2, witnesses grow only (G4/G6-as-amended).
- **Timing:** ~2 hours
- **Depends on:** 2
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append
    `kvE_subBracket`.
- **Verification:**
  - Scoped build green; `kvE_subBracket` type-checks as a `BracketFormula`; no forbidden tactics; the
    construction reads `σ.2` (grep the body for the Phase 2 projections, absence of a single-point
    `charK (nfk_projFresh σ)` joint literal).

### Phase 4: Define kvE_subChain and its position-recovery lemma [NOT STARTED]

- **Goal:** Wrap the sub-bracket's Cor 5.4 F_i-chain predicate as `kvE_subChain` and land the
  position-recovery lemma that carries σ's joint content by nested-Until evaluation point.
- **Tasks:**
  - [ ] Define `kvE_subChain … (σ : NormalForm sig k 4) : TemporalPred :=
        (kvE_subBracket charBase charK r σ).fChainPred` (design spec §5(2)).
  - [ ] Land a recovery lemma instantiating the landed proven `BracketFormula.bracket_implies_fChainPred`
        (EANegation:660) at `bf := kvE_subBracket … σ`: from the sub-bracket holding on σ's honest
        interval, `kvE_subChain σ` is satisfied at a witness strictly inside, with NO provider
        environment `e` and NO residual `w = e 1`/`x = e 2` (probe P4 shape).
  - [ ] Cite Rabinovich Cor 5.4 (md:154-157) and Prop 3.5 (md:87-94) at the chain step; confirm the
        step shape matches `probe_P3_cor54_step_shape` (§3, MATCH).
- **Timing:** ~2 hours
- **Depends on:** 3
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append `kvE_subChain`
    and its recovery lemma.
- **Verification:**
  - Scoped build green; recovery lemma closes via `bracket_implies_fChainPred` (sole hypothesis
    `bf.holds`), axiom-clean, no `sorry`; no structural-identity premise in the signature.

### Phase 5: Assemble kvE2_body (corrected enriched body) [NOT STARTED]

- **Goal:** Build `kvE2_body` = `kvE'_body` with the flattened per-sub joint literal replaced by
  `kvE_subChain σ` spliced at the honest bracket position for σ's zone; retain all non-joint 13.2
  channels verbatim.
- **Tasks:**
  - [ ] Define `kvE2_body` additively, mirroring `kvE'_body` (:5405-5490) structurally, but replacing
        `ptSub σ = ⟨charK (nfk_projFresh σ)⟩` (:5467) and the `t`-anchored `pos.map exF`
        (`exF = P.existF 3 σ`, :5448) joint literal with `kvE_subChain σ` at σ's honest bracket position.
  - [ ] Retain verbatim ALL non-joint channels that behaved correctly at k=1 (gate `kvE_gate`, unary
        families `epL`/`epR` non-joint parts, zones, arrangements `pinSlots`, `ptW`, `segL`/`segR`,
        channel-(ii) `exclAt`) — F4 isolated the gap to the per-sub joint channel ONLY.
  - [ ] Land a `kvE2_body_gate_fail` mirror (analogous to `kvE'_body_gate_fail` :5494) so gate-failure
        yields the empty disjunction.
- **Timing:** ~2 hours
- **Depends on:** 4
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append `kvE2_body` and
    `kvE2_body_gate_fail`.
- **Verification:**
  - Scoped build green; `kvE2_body` type-checks; the joint literal `P.existF 3 σ` / `charK
    (nfk_projFresh σ)` does NOT appear on the joint path of `kvE2_body`; `kvE_pinDisjunct`/`kvE_exclConj`
    still referenced (non-joint channels retained); no forbidden tactics.

### Phase 6: Define bracketEndChar_kvE2 carrier and two_eq bridge [NOT STARTED]

- **Goal:** Land the corrected carrier `bracketEndChar_kvE2` additively (same instantiation pattern as
  `bracketEndChar_kvE'`, UNCHANGED) plus its definitional `two_eq` bridge for the gate re-run.
- **Tasks:**
  - [ ] Define `bracketEndChar_kvE2` mirroring `bracketEndChar_kvE'` (:5510-5517) but delegating to
        `kvE2_body` (design spec §5(4)); instantiation `charBase = nf_depth0_char_formula`,
        `charK = P.existF 0`, and the joint channel now carried by `kvE_subChain` (no `exF` on the
        joint path).
  - [ ] Land `bracketEndChar_kvE2_two_eq` (mirror of `bracketEndChar_kvE'_two_eq` :5523) — pure `rfl`
        exposing `kvE2_body` at the k=2 standard instantiation.
- **Timing:** ~1 hour
- **Depends on:** 5
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append
    `bracketEndChar_kvE2` and `bracketEndChar_kvE2_two_eq`.
- **Verification:**
  - Scoped build green; `bracketEndChar_kvE2_two_eq` closes by `rfl`; `bracketEndChar_kvE'` and its
    `two_eq` unchanged (byte-identical).

### Phase 7: Discharge the per-sub positive soundness crux (correctness direction) [NOT STARTED]

- **Goal:** Discharge the per-sub positive soundness obligation — previously the unpinnable
  `w = e 1`, `x = e 2` — using the Phase 4 recovery lemma, closing the direction the F4 flat carrier
  could not.
- **Tasks:**
  - [ ] Drive the `BracketCarrierCorrectVPrior` soundness direction for `bracketEndChar_kvE2` to the
        per-sub positive obligation; feed `bf.holds` (the honest realization makes `kvE_subBracket … σ`
        hold on σ's honest interval).
  - [ ] Read back σ's honest witness positions via the Phase 4 recovery lemma (`bracket_implies_fChainPred`
        at `bf := kvE_subBracket … σ`) — NO `e`-to-anchor equation; confirm no `P.existF 3 σ` rebinding
        literal appears on the joint path (so the F4 residual does not arise).
  - [ ] Cite Rabinovich Cor 5.4 / Prop 3.5 at each chain step (G5); confirm the completeness/other
        direction of the gate reuses landed machinery unchanged.
- **Timing:** ~2.5 hours
- **Depends on:** 6
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the correctness
    proof scaffolding for `bracketEndChar_kvE2` (proof-side; does not edit `BracketCarrierCorrectVPrior`
    itself, which is consumed do-not-rebuild).
- **Verification:**
  - Scoped build green; the per-sub positive obligation closes with no residual `e`-equation; axiom-clean;
    no `sorry` on any live path.

### Phase 8: Re-run k=2 correctness gate to GO + F4 ℤ counterexample adversarial test [NOT STARTED]

- **Goal:** Establish `BracketCarrierCorrectVPrior` applied to `bracketEndChar_kvE2` as a GO, and prove
  the mandatory F4 ℤ counterexample now FAILS against the new carrier.
- **Tasks:**
  - [ ] Complete the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` to a proven GO
        (both directions closed, provider-independent — only `P.correct` consumed).
  - [ ] Instantiate the F4 ℤ counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]`, `qnf.2 (char[14,15,10,20])=false`, `qnf.2 σ''=true`) and prove the new
        carrier's LHS is now FALSE at `(10,20)` — DISTINGUISHING the dishonest and honest subs because
        `kvE_subChain`/`kvE_subBracket` read `σ.2` (where they differ), not the shared `σ.1`.
  - [ ] Confirm the discrimination mechanism explicitly: the `σ.2` read is the discriminator (Phase 2/3),
        contrasting the F4 record's `rfl`-collapse of the flat channel-(i) content.
- **Timing:** ~2 hours
- **Depends on:** 7
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append the GO gate
    result and the F4 adversarial-test lemma.
- **Verification:**
  - Scoped build green; the GO gate theorem type-checks; the F4 counterexample lemma proves LHS FALSE
    under `bracketEndChar_kvE2` (the adversarial test MUST fail against the new construction); axiom-clean.

### Phase 9: Final integrity sweep, verdict record, full green build [NOT STARTED]

- **Goal:** Land the GO verdict record (F1–F4 house style), verify byte-identity of all do-not-edit
  landed assets, and confirm a full green, axiom-clean, sorry-free build.
- **Tasks:**
  - [ ] Land a verdict record (GO) documenting: route b3 realized, `kvE_subBracket`/`kvE_subChain`/
        `kvE2_body`/`bracketEndChar_kvE2` landed, F4 counterexample now discriminated, citations per G5.
  - [ ] Verify byte-identity: `git diff` on `NfMultiAnchorBridge.lean` shows a pure additive
        `+N/-0` after the task-320 probe section; every do-not-edit asset unchanged; no other landed
        file touched.
  - [ ] Confirm no `simp`/`omega`/`aesop` in any chain-construction body (only `by omega` for `Fin`-index
        typing obligations in signatures, matching landed `fChainFrom_step`).
  - [ ] Run full `lake build`; confirm green, no new `sorry` on any live path, new defs/theorems
        axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) via `lean_verify`.
- **Timing:** ~1 hour
- **Depends on:** 8
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — append verdict record.
- **Verification:**
  - Full `lake build` green; `git diff` additive-only; `lean_verify` axiom-clean on all new symbols;
    do-not-edit assets byte-identical.

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 9.
- [ ] `bracketEndChar_kvE2` lands additively; `bracketEndChar_kvE`/`bracketEndChar_kvE'` byte-identical.
- [ ] Per-sub positive soundness crux closes with NO residual `w = e 1`/`x = e 2` (no provider `e` on
      the joint path).
- [ ] k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` = GO (proven, both directions).
- [ ] MANDATORY adversarial test: F4 ℤ counterexample (`char[14,16,11,20]` vs honest `char[14,15,10,20]`)
      FAILS against the new carrier (LHS FALSE at `(10,20)`) — discrimination via the `σ.2` read.
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on any
      live path.
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Guards G1–G6 + Corrected Anchor-Cap honored; anchor set fixed at 2; no third-anchor tower.
- [ ] EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3).

## Artifacts & Outputs

- `specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/01_corrected-k2-carrier-fi-chain.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — additive: `kvE_subBracket`,
  `kvE_subChain` (+ recovery lemma), `kvE2_body` (+ gate-fail mirror), `bracketEndChar_kvE2`
  (+ `two_eq`), correctness gate GO result, F4 adversarial-test lemma, GO verdict record.
- `specs/321_.../summaries/01_corrected-k2-carrier-fi-chain-summary.md` (at implementation completion)

## Rollback/Contingency

- All work is purely additive after the task-320 probe section. To revert: delete the appended
  definitions/theorems/verdict record; every do-not-edit landed asset is untouched, so rollback restores
  the byte-identical pre-task state (`git checkout` of the single file after snapshotting per
  `git-snapshot.sh` if the tree is dirty).
- If the correctness gate stalls at a reappearing `e`-residual (Phase 7): the joint literal was not fully
  replaced — return to Phase 5, do NOT introduce a pinning device (Amendment F3) or a flat carrier variant.
- If the F4 counterexample fails to discriminate (Phase 8): the `σ.2` read is incomplete — return to
  Phase 2/3; do not weaken the adversarial test.
- If a step appears to require a two-anchor single-point assertion: that is a design smell (Gabbay
  cross-check) — escalate to the orchestrator blocker ladder, do not engineer around it. Land a verdict
  record either way (GO or a defect record), per F1–F4 house style; no partial theorem, no `sorry`.
