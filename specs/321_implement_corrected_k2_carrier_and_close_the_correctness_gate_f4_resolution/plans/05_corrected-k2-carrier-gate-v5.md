# Implementation Plan (v5): Corrected k=2 Carrier — Close the k=2 Correctness Gate (re-point Stage C soundness at task-326's bounded pin-slot deliverable)

- **Task**: 321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Status**: [IMPLEMENTING]
- **Effort**: ~19 hours total (Stages A+B + integrity + Phase-8 wiring ≈ 15h COMPLETED and landed; ~7h remaining across the re-pointed Stage C soundness closure (9+10) + Stage D completeness (11-14) + final verdict (15) — down from v4's ~9h because task 326 landed the bounded pin-slot soundness composition `kvE_subBracket2V_sound_of_outer` that Phase 10's `_sound` consumption previously lacked).
- **Dependencies**: 320 (GO verdict on route b3, design spec §5 — COMPLETED). 325 (COMPLETED 2026-07-07 — the VVecEA2 arity-4 correctness pair, wired by Phase 8). **326 (COMPLETED 2026-07-07 — the bounded point-insertion composition `kvE_subBracket2V_sound_of_outer` that unblocks Phase 10)**. Task 324 is [ABANDONED] (superseded by 325); its landed Phases 1-5 assets remain consumable.
- **Research Inputs**:
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md (blocker resolution: successor-parameterization, forced encoding, staged gate — Section 3 is the drop-in amended design spec)
  - specs/326_bounded_pointinsertion_composition_lemma_for_k2_subwitness_soundness/reports/01_proof-strategy.md (**the unblock rationale** — the pin-slot route: the outer bracket's PIN SLOTS `⟨charK (nfk_projFresh σ)⟩` are LEFT witnesses pinned in `(x, w_outer) ⊂ (x, t)` by monotonicity, supplying the bounded sub-anchor `hanchor`+`hx1t` STRUCTURALLY, sidestepping the documented-unprovable reverse Cor 5.4 direction)
  - specs/326_bounded_pointinsertion_composition_lemma_for_k2_subwitness_soundness/summaries/01_bounded-pointinsertion-composition-summary.md (**the landed deliverable** — `kvE_sub2V_bounded_anchor_of_outer` :7876 and the end-to-end `kvE_subBracket2V_sound_of_outer` :7910, both green, axiom-clean, purely additive; the drop-in Phase-10 closer)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/summaries/02_vvecea2-carrier-v2-completion-summary.md (the landed VVecEA2 arity-4 correctness pair wired by Phase 8)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/plans/02_vvecea2-carrier-v2-nine-zone-gate.md (the executed v2 nine-zone-gate plan behind that asset)
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md (postmortem background: why the old `kvE_subBracket` upward-only chain could never satisfy Phase 8's `zXU`-below-`u` obligation)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md (design spec §5, route b3 GO)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (binding framing caveat)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 blocker origin)
- **Artifacts**: plans/05_corrected-k2-carrier-gate-v5.md (this file; supersedes plans/04_corrected-k2-carrier-gate-v4.md)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **reports_integrated**: 01_blocker-research-successor-k.md; 01_proof-strategy.md (task 326); 01_bounded-pointinsertion-composition-summary.md (task 326); 02_vvecea2-carrier-v2-completion-summary.md; 02_vvecea2-carrier-v2-nine-zone-gate.md; 02_phase6-blocker-research.md; 02_jointpinning-probe-results.md; 01_literature-alignment.md; 06_spawn-analysis-f4.md

## Overview

This is **v5**, superseding v4 (`plans/04_corrected-k2-carrier-gate-v4.md`). v4 wired task 325's landed
`kvE_subBracket2V` VVecEA2 arity-4 correctness pair into `kvE2_body`/`bracketEndChar_kvE2` (Phase 8,
landed green — commit `8448ea135`), then re-pointed Stage C soundness (Phases 9-10) and Stage D
completeness (Phases 11-14) at that pair. v4's **Phase 8 landed** (the joint-channel re-point at
`kvE_subChain2V`, `two_eq` re-derived by `rfl`, non-vacuity gate consumed). But v4's **Phase 10 hit a
machine-grounded structural blocker** (session sess_1783452940_63339e): the per-sub soundness closure
needed to lift the outer joint channel's FLAT `bracketFromLists3.fChainPred` (one per arrangement,
realized at a single interior point by `k1v_bracket_extract`) back to a nested `(kvE_subBracket2V σ).holds`
— the **REVERSE Cor 5.4 direction**, documented UNPROVABLE at `EANegation.lean:1217-1234` / report 18
§10.3. Phase 9's reduction/extraction recipe was machine-verified but, being inseparable from that
blocked closure, was marked `[BLOCKED]` on the same root cause. v4 recorded the blocker and spawned
**task 326** to supply a forward composition that recovers the bounded sub-anchor WITHOUT the reverse
direction.

**Task 326 delivered (COMPLETED 2026-07-07).** Its research (`reports/01_proof-strategy.md`) established
— by adversarial self-verification and Rabinovich §5 grounding — that the v4 audit **overlooked a
second, already-bounded source of the `charK` anchor: the outer carrier's PIN SLOTS**. `kvE_pinDisjunct`
(:5374) emits `⟨charK (nfk_projFresh σ)⟩` as a genuine outer-bracket witness point type, spliced into
`slotsFor lL` as a LEFT witness (left of the `ptW` = `w_outer` split). By bracket monotonicity every
left witness is pinned strictly in `(x, w_outer) ⊂ (x, t)`, so the outer `.holds` **directly supplies a
`charK` witness `q` with `x < q < w_outer < t`** — the bounded anchor (`hanchor` + the `x1 < t` bound
`hx1t`), STRUCTURALLY (slot position, never an `x1 < e_i` literal), with **no reverse Cor 5.4 and no
splice restructure**. Task 326 landed the additive, green, axiom-clean lemmas (do-not-edit, CONSUME):
- `bracketFromLists_flatMap_subchain_below_pin` (:7793) — from any chosen pin `p0 ∈ pins a`, produces
  `q` realizing `p0` and shows every `fcp ∈ subChain a` is realized strictly below `q` (sub-chain
  segment precedes the pins in the contiguous monotone witness block; the `< q` bound rides
  `k1v_bracket_extract_mono`'s monotonicity, never a formula literal).
- `kvE_sub2V_bounded_anchor_of_outer` (:7876) — from the outer bracket's soundness-side `.holds` + the
  anchor pin, assembles the bounded bundle `(q, x<q, q<t, hanchor, hbelow)` (feeding
  `kvE_subChain2V_hbelow_of_realized` for `hbelow`).
- `kvE_subBracket2V_sound_of_outer` (:7910) — **the END-TO-END drop-in Phase-10 closer**: chains
  `kvE_sub2V_bounded_anchor_of_outer` into `kvE_subBracket2V_sound_of_parts`, taking the outer
  soundness-side `.holds` + a pin `p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pins σ` + the outer `hgate` and
  directly yielding `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` — exactly the per-sub soundness
  crux. Supporting: `bracketFromLists3_fChainPred_head_extract`/`_at_head`, `kvE_subChain2V_hbelow_of_realized`,
  `k1v_bracket_extract_mono`, `bracketFromLists_flatMap_first_pin_anchor`, and
  `exists_permutation_cons_head` (EANegationClosure.lean:752).

**The purpose of v5 is narrow and surgical**: this is a **targeted re-pointing revision** (mirroring the
v6→v7 and prior re-pointing pattern), NOT a from-scratch redesign. It carries forward everything v4 got
right — the landed Stage A/B (Phases 1-7), the **landed Phase 8 wiring** (commit `8448ea135`), the
Stage-D completeness decomposition (Phases 11-14), the final verdict phase (15), and every binding
constraint — and re-points **only** the BLOCKED Stage C soundness closure at task 326's now-landed
`kvE_subBracket2V_sound_of_outer` (:7910). Phase 9's machine-verified reduction recipe (still valid)
produces exactly the outer soundness-side data `sound_of_outer` consumes; Phase 10 becomes: apply the
reduction, thread σ's pin witnesses (already in `.holds`) + the order-preserving extract into
`kvE_subBracket2V_sound_of_outer`, discharge the non-joint channels via the landed k1v closers, assemble
`bracketEndChar_kvE2_sound`. Phases 9 and 10 are reconciled from `[BLOCKED]` to `[NOT STARTED]` and are
now both **closeable** (they land as a single soundness commit — the reduction is inseparable from the
closure, so Phase 9's green code merges into Phase 10's `sound_of_outer` consumption, now unblocked).

Definition of done (unchanged in substance): the k=2 correctness gate for `bracketEndChar_kvE2` passes
to a recorded **GO** verdict (both directions closed) over the `kvE_subBracket2V`-based carrier; the F4
`ℤ` counterexample is discriminated (LHS FALSE at `(10,20)`); green `lake build`; axiom-clean (`propext`,
`Classical.choice`, `Quot.sound`); no `sorry` on any live path; every forbidden-list do-not-edit asset
(now including all task-326 landed lemmas) byte-identical; a verdict record landed. If a Stage-D phase
hits a *genuine machine-grounded obstruction* (not mere effort), the per-phase escalation rule fires
(record F-house-style, keep green work committed, stop).

### Research Integration

v5 integrates the **new task-326 deliverable** as its central asset. The landed symbols (grep-verified
in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`; line numbers confirmed
against the current tree):

- `kvE_subBracket2V_sound_of_outer` (:7910) — **the drop-in Phase-10 closer**. Signature (confirmed):
  ```
  theorem kvE_subBracket2V_sound_of_outer (atomMap) (h_surj) (charK) (σ) (M) (w x t)
      (l) (pins) (ptW segL segR) (lR) (hσl : σ ∈ l)
      (p0) (hp0 : p0 ∈ pins σ) (hp0eq : p0 = ⟨charK (nfk_projFresh σ)⟩)
      (h : (bracketFromLists (l.flatMap (fun b => kvE_subChain2V (nf_depth0_char_formula atomMap h_surj) charK b ++ pins b)) ptW lR segL segR).holds M atomMap x t)
      (hgate : ∀ a, x < a → a < t → ⟨charK (nfk_projFresh σ)⟩.eval_at M atomMap a →
        a < w ∧ w < t ∧ nf_eval_nf M 0 4 (a,w,x,t) σ.1 ∧ (off-fiber) ∧ (zone folds forward) ∧ (zone folds reverse)) :
      ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
  ```
  **Crucial shape fact**: the `hgate` here takes `a < t` as INPUT and yields `a < w` — it CONSUMES the
  `x1 < t` bound rather than producing it. The bound is supplied STRUCTURALLY by the pin slot's position
  inside `kvE_sub2V_bounded_anchor_of_outer`. This is the exact inversion that unblocks v4's Phase 10:
  v4 assumed `hgate` had to reconstruct/supply `x1 < t` (which forced the reverse Cor 5.4 wall); task 326
  moves that bound to the pin-slot route, leaving `hgate` a pure forward reconstruction from the outer
  gate channels.
- `kvE_sub2V_bounded_anchor_of_outer` (:7876) — the bounded-bundle producer `(q, x<q, q<t, hanchor, hbelow)`
  from the outer `.holds` + pin, used internally by `sound_of_outer` (available if Phase 10 needs the
  bundle directly rather than the end-to-end closer).
- `bracketFromLists_flatMap_subchain_below_pin` (:7793) — the multi-element sub-chain-below-pin helper
  (matches `kvE2_body`'s `slotsFor lL = lL.flatMap (fun σ => kvE_subChain2V charBase charK σ ++ pinSlots σ)`
  block shape exactly).
- `kvE_subBracket2V_sound_of_parts` (:7719) — the `.holds`-free consumer `sound_of_outer` chains into;
  its `(x1, hxx1, hx1t, hanchor, hbelow, hgate)` argument tuple is what the bundle instantiates.
- Supporting (do-not-edit, CONSUME): `bracketFromLists3_fChainPred_head_extract` (:6794),
  `bracketFromLists3_fChainPred_at_head` (:7001), `kvE_subChain2V_hbelow_of_realized` (:7036),
  `k1v_bracket_extract_mono` (:2274), `bracketFromLists_flatMap_first_pin_anchor` (:2404),
  `exists_permutation_cons_head` (EANegationClosure.lean:752).

**Carried forward from v4 (unchanged, landed by Phase 8):** the task-325 pair `kvE_subBracket2V`
(:6779), `kvE_subChain2V` (:6901), `kvE_subBracket2V_sound` (:7640), `kvE_subBracket2V_complete` (:7783),
`kvE_subBracket2V_nonvacuous`; the arity-4 three-region bracket kit (`bracketFromLists3`,
`k1v_sorted_realization3`, `k1v_bracket_construct3`, `bracketFromLists3_extract`); the non-vacuity gate
`kvE2_joint_nonvacuous_at_honest`.

**How the soundness route re-points (requirement 1).** The v4 threading table for soundness's `hgate` is
superseded by the task-326 pin-slot route. The updated map:

| Obligation | Where v5 discharges it |
|------------|------------------------|
| The joint-slot per-sub crux `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ` | Phase 10: hand the outer `.holds` `hbr` (the raw LEFT-list bracket `.holds` on `slotsFor lL`, reached by the Phase-9 reduction) + a pin `p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pinSlots σ` + `hσl : σ ∈ lL` + `hgate` DIRECTLY into `kvE_subBracket2V_sound_of_outer` (:7910). NO `k1v_bracket_extract` on the joint channel — `sound_of_outer` does its own order-preserving extraction internally (`k1v_bracket_extract_mono`). |
| The `x1 < t` bound (v4's reverse-Cor-5.4 wall) | Supplied STRUCTURALLY inside `kvE_sub2V_bounded_anchor_of_outer` from the pin slot's position left of `ptW` (bracket monotonicity), NOT reconstructed by `hgate`. |
| Pin-witness threading (NEW obligation, requirement 1) | Phase 10 must exhibit `p0 = ⟨charK (nfk_projFresh σ)⟩` and prove `p0 ∈ pinSlots σ` (from `kvE_pinDisjunct` :5374, whose disjunct list is `[⟨charK (nfk_projFresh σ)⟩]`, non-empty at every σ ∈ `lL` via `kvE_pinArrangements` :5364 mapping consistentZones), plus `hσl : σ ∈ lL`. These are the σ's pin witnesses "already present in `.holds`" that v5 extracts and threads — spelled out precisely in Phase 10 tasks. |
| `hgate` forward reconstruction (`a<w ∧ w<t ∧ nf_eval_nf reconstruction ∧ off-fiber ∧ zone folds`) | Phase 10: from the outer `kvE2_body` gate channels exposed by the Phase-9 reduction — the gate branch `hg : kvE_gate qnf.1 qnf.2` supplies the fold reconstruction + off-fiber; the non-joint channels (`hepL`/`hepR`/`hptWe`/`hLgap`/`hRgap`) supply the segment/endpoint data; `w`/`w<t` from the outer bracket's `ptW` witness (`k1v_bracket_extract` on the outer bracket for the NON-joint channels only). |
| `kvE_subBracket2V_complete`'s order bits + `hcharK` (completeness, requirement 2) | Phases 11-14, carried forward from v4 UNCHANGED (the v4 completeness threading table still applies — the splice shape is untouched). |

Carried forward from v4/v3 (unchanged): route b1 NO-GO, Cor 5.4 chain-shape MATCH, route b3 GO, route b2
NOT NEEDED; successor-parameterization is a landed fact. The `01_blocker-research-successor-k.md`
§2/Q3 staged-gate structure remains the binding amended design spec. **The Rabinovich §5 grounding for
the pin-slot route**: Lemma 5.1 point-insertion (md:169-171) — the pin witness's bound rides its
structural position (a bracket slot left of the `ptW` split), a faithful instance of "boundedness via a
shared/structural endpoint, never a formula assertion"; Cor 5.4 reverse (md:154-157) is sidestepped
entirely; Lemma 5.3 (md:137-152) underwrites `kvE_subChain2V`'s `S_XU.permutations` structure used by the
`hbelow` coverage.

### Prior Plan Reference

v4 (`plans/04_corrected-k2-carrier-gate-v4.md`) is **[SUPERSEDED]** by this v5. v4's Phases 1-7 (Stage A
construction + Stage B discrimination + PARTIAL-GO verdict + baseline) AND **Phase 8 (the wiring
foundation — joint-channel re-point at `kvE_subChain2V`, `two_eq` re-derived, non-vacuity gate consumed;
landed commit `8448ea135`)** are `[COMPLETED]`, landed, and committed; they are carried forward verbatim
and are never re-executed. v4's Phases 9-10 were `[BLOCKED]` (the reverse-Cor-5.4 wall — the outer flat
`fChainPred` could not be lifted back to a nested `.holds`); v4 Phases 11-15 were `[NOT STARTED]`. v5
**re-points only Phases 9-10** at task 326's now-landed `kvE_subBracket2V_sound_of_outer`, reconciling
them from `[BLOCKED]` to `[NOT STARTED]` and closeable; Phases 11-15 are carried forward `[NOT STARTED]`
verbatim. The lineage context (v6→v7 re-pointing pattern, F1-F4 house style, parent task 309) remains
binding.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context). Goal-state alignment for the enclosing
chain: this task's GO gate is the prerequisite for task 309's Phase 13.4 (general-k one-step
correctness) and Phase 14 (hook rewire discharging `KampPrior.lean:351`'s strategic `sorry`, target
axioms exactly `[propext, Classical.choice, Quot.sound]`). After a GO here, task 309 resumes via
`/implement 309` (possibly preceded by `/revise 309` for a v8 re-pointing to the new deliverable
names). Because v5 keeps the gate **in-task**, no further completeness spawn is created; the gate GO is
delivered by task 321 itself.

## Goals & Non-Goals

**Goals**:
- Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` to a proven **GO** (both
  directions) over the carrier re-pointed (Phase 8, landed) at task 325's `kvE_subBracket2V`, by
  **consuming** task 326's `kvE_subBracket2V_sound_of_outer` (:7910) for the SOUNDNESS joint slot
  (Phase 10) and task 325's `kvE_subBracket2V_complete` for the COMPLETENESS joint slot (Phase 12) — not
  re-deriving them — and discharging their explicit hypotheses (pin witnesses + `hgate` for soundness;
  order bits + `hcharK` for completeness) from the outer `kvE2_body` gate channels.
- Re-point the BLOCKED Stage C soundness closure (Phases 9-10) at `kvE_subBracket2V_sound_of_outer`,
  threading σ's pin witnesses (`p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pinSlots σ`, `σ ∈ lL`) already present
  in the outer `.holds`.
- Preserve the Stage-D outer-gate completeness assembly (Phases 11-14) as the novel highest-risk region
  with H8 one-dispatch sizing and explicit sub-split valves, CARRIED FORWARD from v4 UNCHANGED.
- Discharge the F4 `ℤ` semantic LHS-FALSE at `(10,20)` against the re-pointed `bracketEndChar_kvE2`,
  then run the integrity sweep and land a GO/NO-GO verdict record.
- Preserve every forbidden-list do-not-edit asset byte-identical (now including all task-326 landed
  lemmas); keep all remaining new work additive (Phase 8's authorized re-point of the three 321-owned
  defs is already landed).
- Carry the **non-vacuity gate** forward: `kvE2_joint_nonvacuous_at_honest` (landed by Phase 8) is
  consumed at the wiring boundary BEFORE any correctness direction — the structural countermeasure to the
  three prior gate-class vacuity/reachability failures.

**Non-Goals**:
- **BINDING NON-GOAL (requirement 2, from task 326 research): v5 must NOT alter the `kvE_subChain2V`
  splice shape in `kvE2_body`.** v5 re-points the SOUNDNESS PROOF only; it consumes the EXISTING
  Phase-8 joint-channel splice (`slotsFor lL = lL.flatMap (fun σ => kvE_subChain2V charBase charK σ ++
  pinSlots σ)`) byte-identical. Completeness (Phases 12-14) stays closed ONLY IF the splice shape is
  untouched — the whole point of task 326 is that soundness now works WITHOUT restructuring the splice
  (the pin slots are already present in the unchanged `.holds`). Touching the splice would re-open the
  completeness risk and is prohibited.
- No re-execution, re-derivation, or edit of the completed Stage A/B assets or the LANDED Phase-8 wiring
  (`kvE2_body`/`bracketEndChar_kvE2`/`bracketEndChar_kvE2_two_eq`/`kvE2_joint_nonvacuous_at_honest` are
  landed at commit `8448ea135` and are not touched again).
- No re-derivation of task 326's soundness composition (`kvE_subBracket2V_sound_of_outer`,
  `kvE_sub2V_bounded_anchor_of_outer`, `bracketFromLists_flatMap_subchain_below_pin`, and the supporting
  lemmas) — they are landed, axiom-clean, and consumed as-is.
- No re-derivation of task 325's `kvE_subBracket2V` correctness pair or its kit — landed, consumed as-is.
- No re-attempt of the REVERSE Cor 5.4 `fChainPred → bracket` direction (documented unprovable at
  `EANegation.lean:1217-1234` / report 18 §10.3). The pin-slot route sidesteps it; Phase 10 must NOT
  reintroduce it.
- No spawn of the completeness direction to a separate task — v5 keeps the gate in task 321.
- No third FLAT carrier variant (`kvE''`-style per-sub literal at `t`) — the F3/F4-refuted shape.
- No provider-side pinning (Amendment F3 binding); the provider *disappears* from the joint path. The
  pin-slot route is provider-free (the anchor `q` is a bracket witness, not `e 1`/`e 2`).
- No consumption of `EANegation :1090/:1249`.
- No structural-identity / `nf_eval_unique` / `nfPred_correct` hypothesis on the gate (route b2 NOT
  NEEDED).
- No edits to any forbidden-list landed asset (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1-F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material, the task-320 probes, the
  task-324 landed kit, the task-325 VVecEA2 block, **and the task-326 pin-slot composition block**).
  Task 321's own PARTIAL-GO verdict record is updated to the final GO/NO-GO record in Phase 15 — that is
  task 321's own output.
- No general-k work (task 309 Phase 13.4/14) — out of scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The pin-witness threading (`p0 ∈ pinSlots σ`, `σ ∈ lL`) does not line up with the Phase-9 reduction's exposed `lL`/pin data | H | L | The Phase-9 reduction exposes `lL`/`hlLp` and `hbr` (the raw LEFT-list `.holds`); the pin membership comes from `kvE_pinDisjunct` (:5374, disjunct list `[⟨charK (nfk_projFresh σ)⟩]`) + `kvE_pinArrangements` (:5364, non-empty). If the exposed `lL` is not literally the `sound_of_outer` `l` argument, adjust the `subst`/`obtain` in the reduction so `hbr`'s bracket-list is definitionally `l.flatMap (fun b => kvE_subChain2V … b ++ pins b)`; do NOT restructure the splice. Sub-split valve at the pin-threading boundary. |
| `sound_of_outer`'s `hgate` forward reconstruction (`a<w ∧ w<t ∧ nf_eval_nf reconstruction ∧ off-fiber ∧ zone folds`) is heavier to discharge from the outer gate channels than the direct hand-off | H | M | Phase 10 maps each `hgate` conjunct to a named outer channel (see the Research-Integration threading table); the gate branch `hg : kvE_gate qnf.1 qnf.2` + the non-joint extract (`k1v_bracket_extract` on the outer bracket for `hepL`/`hepR`/`hptWe`/`hLgap`/`hRgap` + `w`/`w<t`) supply it. Land any intermediate mapping lemma phase-per-lemma, commit-per-green. Sub-split valve at the `hgate`-assembly boundary. |
| Phase 9's reduction green code is inseparable from Phase 10's closure (an inline half-proof over `kvE2_body`'s internal `let`s), so neither is independently committable | M | H (structural) | This is expected and handled: Phases 9+10 land as a SINGLE soundness commit (the reduction prefix + the `sound_of_outer` consumption + non-joint channels + assembly = one `bracketEndChar_kvE2_sound` theorem). No `sorry`-skeleton is committed at the 9/10 boundary; the WIP stays uncommitted until the assembled soundness theorem is green. |
| Threading `hcharK` + the three order bits through the outer completeness direction (Stage D) stalls | H | M | CARRIED FORWARD from v4 UNCHANGED. Stage D decomposed into 4 phases (11 extraction+order-bits, 12 arrangement disjunct via `_complete`, 13 non-joint channels + assembly, 14 gate close), phase-per-lemma, commit-per-green. Per-phase escalation on genuine obstruction. The splice-untouched non-goal keeps the v4 completeness threading valid. |
| v5 accidentally alters the `kvE_subChain2V` splice while re-pointing soundness, re-opening completeness | H | L | **BINDING NON-GOAL**: the soundness re-point consumes the UNCHANGED splice (`sound_of_outer` takes the raw `slotsFor lL` `.holds`). Verify in Phase 15 that `kvE2_body`'s splice is byte-identical to the Phase-8 commit `8448ea135`; the only new content is additive soundness/completeness proof-side. |
| The re-pointed carrier is vacuous at the outer level (empty `disjuncts` ⇒ soundness closes trivially) | H | L | **Non-vacuity gate countermeasure (binding, landed by Phase 8)**: `kvE2_joint_nonvacuous_at_honest` is consumed at the honest σ to confirm `disjuncts ≠ []` before any correctness direction. |
| Accidental edit / byte drift of a forbidden-list do-not-edit asset (now including the task-326 block) | H | L | All v5 work is additive proof-side (Phase 8's authorized re-point is already landed). Verify byte-identity via `git diff` (expect additive-only after the Phase-8 commit) in Phase 15; the 326/325/324 kits are consumed, not rebuilt. |
| Anchor growth / third-anchor tower slips in via the pin/completeness witnesses (G2/G4/G6) | H | L | Anchor set fixed at 2 `{x,t}`; `x1`/`w` are interior witness slots; the pin anchor `q` is a bracket WITNESS in `(x, w_outer)`, not an anchor (adding self-zones to the `VVecEA2` gate does not make them anchors — a self-zone is a zone-spec value, per 325 Guard G4). Verify in Phase 15. |
| F4 counterexample does not discriminate at the semantic level (LHS still holds) | H | L | Construction-level discrimination is LANDED (v3 Phase 7). Phase 15 evaluates on `M=ℤ`; if LHS still holds, the completeness wiring lost the `σ.2` dependence — return to Stage D, do NOT weaken the test. The soundness pin-route does not weaken counterexample rejection (task 326 H4 verified: the recovery only fires WHEN `.holds` holds; rejection lives in `.holds`). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Stage |
|------|--------|------------|-------|
| 1 | 1 | -- | (baseline, COMPLETED) |
| 2 | 2 | 1 | A (construction, COMPLETED) |
| 3 | 3 | 2 | A (COMPLETED) |
| 4 | 4 | 3 | A (COMPLETED) |
| 5 | 5 | 4 | A (COMPLETED) |
| 6 | 6 | 5 | A (COMPLETED) |
| 7 | 7 | 6 | B (discrimination + PARTIAL-GO verdict, COMPLETED) |
| 8 | 8 | 7 | Wiring foundation — re-point carrier (COMPLETED, commit `8448ea135`) |
| 9 | 9 | 8 | C (soundness reduction/scaffolding over new carrier — reconciled, closeable) |
| 10 | 10 | 9 | C (per-sub soundness via `kvE_subBracket2V_sound_of_outer` + pin threading + assembly — RE-POINTED) |
| 11 | 11 | 10 | D (fold extraction + order-bit/`hcharK` prep — carried forward) |
| 12 | 12 | 11 | D (arrangement disjunct via `_complete` — carried forward) |
| 13 | 13 | 12 | D (non-joint completeness channels + assembly — carried forward) |
| 14 | 14 | 13 | D (gate close to GO, both directions — carried forward) |
| 15 | 15 | 14 | Final (ℤ LHS-FALSE + integrity + GO/NO-GO verdict — carried forward) |

This construction is inherently sequential (each gate layer builds on the previous), so each wave holds
one phase. **Implementation resumes at Phase 9** (soundness reduction, now closeable); Phases 1-8 are
landed and carried forward. Phases 9+10 execute and land as a single soundness commit.

### Preserved-Assets Table

| Asset | Origin | v5 disposition |
|-------|--------|----------------|
| `kvE_subFoldBits`, `kvE_subInteriorZones` | 321 Stage A (P2-3) | **KEEP** (landed, byte-identical; still consumed by the fold reads) |
| `kvE_subBracket`, `kvE_subChain`, `kvE_subBracket_implies_subChain` | 321 Stage A (P3-4) | **KEEP landed but UNREFERENCED on joint path** (the F4-blocked upward-only design; superseded on the joint path by `kvE_subChain2V`) |
| `kvE2_body`, `kvE2_body_gate_fail`, `bracketEndChar_kvE2`, `bracketEndChar_kvE2_two_eq`, `kvE2_joint_nonvacuous_at_honest` | 321 Stage A + Phase 8 (LANDED, commit `8448ea135`) | **KEEP landed byte-identical** — the Phase-8 re-point is complete; v5 does NOT touch these (splice-untouched non-goal) |
| Stage-B discrimination lemmas (`kvE_subBracket_witnessCount`, `_ne_of_witnessCount_ne`) | 321 Stage B (P7) | **KEEP** landed; construction-level F4 record (semantic tail is Phase 15) |
| `kvE_subBracket2V` (+ `kvE_subChain2V`, `bracketFromLists3`, kit) | **task 325** | **CONSUME** (do-not-edit; the wired joint-channel carrier) |
| `kvE_subBracket2V_sound`, `kvE_subBracket2V_complete`, `kvE_subBracket2V_sound_of_parts`, `kvE_subBracket2V_nonvacuous` | **task 325** | **CONSUME** (do-not-edit; the correctness pair + parts refactor) |
| `kvE_subBracket2V_sound_of_outer` (:7910), `kvE_sub2V_bounded_anchor_of_outer` (:7876), `bracketFromLists_flatMap_subchain_below_pin` (:7793), `bracketFromLists3_fChainPred_head_extract`/`_at_head`, `kvE_subChain2V_hbelow_of_realized`, `k1v_bracket_extract_mono`, `bracketFromLists_flatMap_first_pin_anchor`, `exists_permutation_cons_head` (EANegationClosure:752) | **task 326** | **CONSUME** (do-not-edit; the bounded pin-slot soundness composition — the Phase-10 closer) |
| `kvE_sub2` zone kit, `kvE_subBracket2_complete_extract` | task 324 (landed P1-5) | **CONSUME if needed** (do-not-edit; 324 abandoned but assets landed) |
| `k1v_bracket_extract` (:2150), `bracketEndChar_k1v_sound` (:2338), `bracketEndChar_k1v_complete` (:2979) | k1v template | **CONSUME** (do-not-edit; outer-gate template one arity down) |
| `BracketCarrierCorrectVPrior`, `ExistProviders`, `bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`, F1-F4 records, task-320 probes, task-310/311 material | forbidden list | **DO-NOT-EDIT** (byte-identical) |

### Postmortem — Phase-10 blocker (v4) and how v5 resolves it

| Field | Record |
|-------|--------|
| **Blocker (v4 Phase 10)** | The per-sub soundness closure needed to lift the outer joint channel's FLAT `bracketFromLists3.fChainPred` (one per arrangement, realized at ONE interior point by `k1v_bracket_extract`) back to a nested `(kvE_subBracket2V σ).holds` — the REVERSE Cor 5.4 direction — to feed `kvE_subBracket2V_sound`. Phase 9's reduction was machine-verified but inseparable from that blocked closure, so both were `[BLOCKED]`. |
| **Root cause** | Splicing sub-content as flat `TemporalPred` entries into the outer bracket's witness list (then extracting via `k1v_bracket_extract`, which realizes each entry at a single point) is inherently incompatible with recovering a nested sub-bracket `.holds`; and `kvE_subBracket2V_sound` demanded the below-anchor `hbelow` witnesses that only a genuine `.holds` (not a flat realized `fChainPred`) supplies. The reverse `fChainPred → bracket` direction is DOCUMENTED UNPROVABLE (`EANegation.lean:1217-1234`, report 18 §10.3). The missing datum was specifically the `x1 < t` bound on the recovered anchor. |
| **Resolution (task 326)** | The v4 audit overlooked the outer carrier's PIN SLOTS as a second, already-bounded `charK`-anchor source. `kvE_pinDisjunct` (:5374) emits `⟨charK (nfk_projFresh σ)⟩` as a LEFT outer-bracket witness (left of the `ptW` split), so bracket monotonicity pins it in `(x, w_outer) ⊂ (x, t)` — supplying `hanchor` + the `x1 < t` bound STRUCTURALLY, with NO reverse Cor 5.4. Task 326 landed `kvE_subBracket2V_sound_of_outer` (:7910), which takes the outer `.holds` + the pin + a forward `hgate` (that now CONSUMES `a < t`) and directly yields `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`. |
| **How v5 avoids the blocker** | Phase 10 never re-attempts the reverse lift. It hands the outer `.holds` `hbr` + the pin `p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pinSlots σ` + `σ ∈ lL` + the forward `hgate` straight into `kvE_subBracket2V_sound_of_outer`; the bounded anchor + `hbelow` are assembled INSIDE the landed lemma via the pin-slot route (`kvE_sub2V_bounded_anchor_of_outer` → `kvE_subChain2V_hbelow_of_realized`). v5 does plumbing (pin threading + `hgate` reconstruction from the outer gate channels), not chain construction, on the joint path. |

---

### Phase 1: Baseline capture and landed-asset integrity snapshot [COMPLETED]

- **Commit:** `b9cb244e6`.
- **Outcome (landed):** Scoped `lake build` green; task-320 probe section present and axiom-clean;
  do-not-edit asset byte ranges recorded; F4 crux goal + `ℤ` counterexample recaptured;
  CONSUME-DO-NOT-REBUILD asset list confirmed available; `git diff` clean at phase start.
- **Files:** `NfMultiAnchorBridge.lean` (read-only).

### Phase 2: Successor-parameterized σ.2 read and sub-fold-bit decoding [COMPLETED] (Stage A)

- **Commit:** `0c9f0bc88`.
- **Outcome (landed):** `kvE_subFoldBits` (:5728) + `_eq_destructors` (`rfl`); the gate-instance decoder
  via `nf_eval_depth1_fold_iff` (:5187) at `n=4`. No forbidden tactics.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 3: Construct kvE_subBracket (nested sub-bracket over σ.2, forced k1v routing) [COMPLETED] (Stage A)

- **Commit:** `201902b97`.
- **Outcome (landed):** `kvE_subBracket` (:5779) type-checks as `Σ m, BracketFormula (m+1)`,
  axiom-clean; `kvE_subInteriorZones = [zXU, zUW, zWT]` (:5751). G1-G6 verified. Rabinovich Def 3.1 /
  Lemma 5.1 cited. **NOTE:** the upward-only design (superseded on the joint path by `kvE_subBracket2V`);
  kept byte-identical.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 4: Define kvE_subChain and its position-recovery lemma [COMPLETED] (Stage A)

- **Commit:** `c8db183da`.
- **Outcome (landed):** `kvE_subChain` (:5807) + `kvE_subBracket_implies_subChain` (:5824). Rabinovich
  Cor 5.4 / Prop 3.5 cited. Kept byte-identical; superseded on the joint path by `kvE_subChain2V`.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 5: Assemble kvE2_body (corrected enriched body, successor-parameterized) [COMPLETED] (Stage A)

- **Commit:** `e3dfba315`.
- **Outcome (landed):** `kvE2_body … : VVecEA2` + `kvE2_body_gate_fail` mirror; `P.existF 3` dropped
  from the joint path. **Re-pointed at `kvE_subChain2V` by Phase 8 (landed, commit `8448ea135`).**
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 6: Define bracketEndChar_kvE2 carrier and two_eq bridge [COMPLETED] (Stage A)

- **Commit:** `2075533a8`.
- **Outcome (landed):** `bracketEndChar_kvE2 (P : ExistProviders sig atomMap 1) :
  BracketEndCharCarrierV sig 2` + `bracketEndChar_kvE2_two_eq` (`rfl`). **`two_eq` re-derived by Phase 8
  (landed, commit `8448ea135`, closed by `rfl` — valve 8b not needed).**
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 7: F4 construction-level discrimination + PARTIAL-GO verdict [COMPLETED] (Stage B)

- **Commit:** `4e1986627`.
- **Outcome (landed):** `kvE_subBracket_witnessCount` (`rfl`) + `kvE_subBracket_ne_of_witnessCount_ne`;
  axiom-clean. Honest vs dishonest subs produce DIFFERENT witness-slot lists. The full `M=ℤ` SEMANTIC
  LHS-FALSE is deferred to Phase 15. The PARTIAL-GO verdict record is updated to the final GO/NO-GO
  record in Phase 15.
- **Files:** `NfMultiAnchorBridge.lean` (append).

---

### Phase 8: Wiring foundation — re-point kvE2_body/bracketEndChar_kvE2 at kvE_subChain2V + re-derive two_eq [COMPLETED]

- **Commit:** `8448ea135`.
- **DO-NOT-EDIT discipline note (binding):** `kvE2_body`, `kvE2_body_gate_fail`, `bracketEndChar_kvE2`,
  and `bracketEndChar_kvE2_two_eq` are **task 321's OWN Stage-A assets**; editing them to re-point the
  joint channel was within this task's authority. **This phase is now LANDED — v5 does NOT touch these
  assets again (splice-untouched binding non-goal).** The forbidden-list assets (including the task-325
  VVecEA2 block and task-326 pin-slot composition block) remain byte-identical.
- **Outcome (landed):** The joint channel of `kvE2_body` re-pointed from `kvE_subChain σ` to
  `kvE_subChain2V σ`; `slotsFor lL = lL.flatMap (fun σ => kvE_subChain2V charBase charK σ ++ pinSlots σ)`
  (deviation: `kvE_subChain2V` returns `List TemporalPred`, so the joint splice became `ptSub σ ++
  pinSlots σ`). `bracketEndChar_kvE2` inherits the re-point; `bracketEndChar_kvE2_two_eq` closes by `rfl`.
  Non-vacuity gate consumed: `kvE2_joint_nonvacuous_at_honest` (from `kvE_subBracket2V_nonvacuous`),
  axiom-clean. Necessary relocation: the four 321-owned defs + the non-vacuity lemma moved to just before
  `end Bimodal…` (after the task-325 block) to resolve the forward-reference; `git diff` comm-verified
  additive + relocation only.
- **Files:** `NfMultiAnchorBridge.lean` (landed).
- **Verification (passed):** Scoped build green; `bracketEndChar_kvE2` characterizes `kvE_subBracket2V`
  on the joint path; `two_eq` closes by `rfl`; `kvE_subBracket2V_nonvacuous` consumed; axiom-clean; no
  `sorry`; all forbidden-list assets byte-identical.

### Phase 9: Stage C soundness reduction — gate entry + k1v channel extraction over the new carrier [BLOCKED] (Stage C — reduction VERIFIED green; lands jointly with Phase 10, which is BLOCKED)

**PROGRESS (task 321 dispatch, session sess_1783452940_63339e):** The machine-verified reduction
recipe (lines 383-399) was applied VERBATIM and **type-checks green** (confirmed via `lean_goal`
on uncommitted WIP). Concretely verified:
- `rw [bracketEndChar_kvE2_two_eq] at h`; `simp only [kvE2_body, VVecEA2.holds] at h`;
  `obtain ⟨vea, hmem, hveah⟩ := h`; `split at hmem` (isFalse closes via `simp at hmem`; isTrue
  keeps `hg : kvE_gate qnf.1 qnf.2`); `rw [List.mem_flatMap]`/`List.mem_map`; `subst hEq`;
  `obtain ⟨hepL, hepR, hbr⟩ := hveah` — ALL type-check.
- `hbr` IS in the `kvE_subBracket2V_sound_of_outer` `h`-shape: its bracket-list is
  `lL.flatMap (fun σ => kvE_subChain2V (nf_depth0_char_formula atomMap h_surj) (fun χ => P.existF 0 χ) σ ++ pinSlots σ)`
  where `pinSlots σ = (kvE_pinArrangements σ).flatMap (fun a => (kvE_pinDisjunct … σ a).1)` — this
  is DEFINITIONALLY the closer's `h` argument with `l := lL`, `pins := pinSlots`,
  `charK := fun χ => P.existF 0 χ`. No `show`/`change` needed.
- `k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr` yields
  `⟨w, hxw, hwt, hptWe, hLwit, hRwit, hLgap, hRgap⟩` and `refine ⟨w, ?_⟩` reduces the goal to
  `nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x fun _ => t)) qnf`.
- `refine ⟨?_, ?_⟩` splits that into the atom layer
  `∀ a : AtomKind sig 3, atom_eval M [w,x,t] a ↔ qnf.1 a = true` (reconstructible via
  `k1v_reconstruct_nf3`, exactly as k1v) and the quant layer (see Phase-10 BLOCKER).

This reduction prefix is uncommitted (it is a proof-side half-proof with no independent green
terminus; removed from the working tree to keep the build green). Re-dispatch can reuse the
recipe above VERBATIM.


**RECONCILIATION (v5):** v4 marked this phase `[BLOCKED]` because its machine-verified reduction recipe
was inseparable from the then-BLOCKED Phase-10 closure (the reverse-Cor-5.4 wall). Task 326 unblocks the
downstream closure, so Phase 9 is reconciled to `[NOT STARTED]` and is now **closeable**. Its reduction
recipe (below) is UNCHANGED and STILL VALID: it produces exactly the outer soundness-side data
(`hbr` = the raw LEFT-list `.holds`; the gate branch `hg`; the non-joint channels) that
`kvE_subBracket2V_sound_of_outer` consumes. Because the reduction is an inline half-proof over
`kvE2_body`'s internal `let`-bound objects, it is NOT independently committable — **Phases 9 and 10 land
as a SINGLE soundness commit** (the reduction prefix + the Phase-10 closure = one `bracketEndChar_kvE2_sound`
theorem). No `sorry`-skeleton is committed at the 9/10 boundary.

- **Goal:** Open the `BracketCarrierCorrectVPrior` soundness direction (carrier holds ⇒ ∃w realization)
  for the re-pointed `bracketEndChar_kvE2`, reduce it through `bracketEndChar_kvE2_two_eq` to the
  k1v-shaped body, and expose (a) the raw outer LEFT-list `.holds` `hbr`, (b) the gate branch `hg`, and
  (c) the non-joint per-channel obligations — WITHOUT yet discharging the joint obligation (that is
  Phase 10's `sound_of_outer` consumption).
- **Machine-verified reduction recipe (from v4 Phase-9 WIP, still valid):**
  - `rw [bracketEndChar_kvE2_two_eq] at h`
  - `simp only [kvE2_body, VVecEA2.holds] at h`
  - `obtain ⟨vea, hmem, hveah⟩ := h; split at hmem`
  - `case isFalse hg => simp at hmem` (empty-disjunct gate-fail branch closes)
  - `case isTrue hg => rw [List.mem_flatMap] at hmem; obtain ⟨lL, hlLp, hmem⟩ := hmem;`
    `rw [List.mem_map] at hmem; obtain ⟨lR, hlRp, hEq⟩ := hmem; subst hEq;`
  - `obtain ⟨hepL, hepR, hbr⟩ := hveah`
  - **Then (v5 change): DO NOT run `k1v_bracket_extract` on the joint channel.** `hbr` is the raw
    LEFT-list bracket `.holds` `(bracketFromLists (slotsFor lL) ptW lR segL segR).holds M atomMap x t`,
    whose bracket-list `slotsFor lL` is definitionally `lL.flatMap (fun b => kvE_subChain2V charBase
    charK b ++ pinSlots b)` — EXACTLY the `l.flatMap (fun b => kvE_subChain2V … b ++ pins b)` argument
    `kvE_subBracket2V_sound_of_outer` takes as its `h`. Hand `hbr` to Phase 10 directly.
  - For the NON-joint channels (`hgate` reconstruction + endpoint/segment obligations), run
    `k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr` to obtain
    `⟨w, hxw, hwt, hptWe, hLwit, hRwit, hLgap, hRgap⟩` — used ONLY for `w`/`w<t`/the segment classifications
    (`hLgap`/`hRgap`) and `ptW` (`hptWe`), NOT for the joint slot.
- **Tasks:**
  - [ ] State the soundness half of the gate for `bracketEndChar_kvE2` (proof-side; do NOT edit
        `BracketCarrierCorrectVPrior`). Rewrite through `bracketEndChar_kvE2_two_eq`.
  - [ ] Apply the reduction recipe to reach `hbr` (raw LEFT-list `.holds`), the gate branch `hg`, and the
        non-joint channels (`hepL`/`hepR`/`hptWe`/`hLgap`/`hRgap`, `w`/`w<t`).
  - [ ] Confirm `hbr`'s bracket-list is definitionally `lL.flatMap (fun b => kvE_subChain2V charBase
        charK b ++ pinSlots b)` (the `sound_of_outer` `h`-argument shape) — so Phase 10 can feed it
        directly. If a `show`/`change` is needed to expose this defeq, land it here.
  - [ ] Cite Rabinovich at each structural step (G5); no `simp`/`omega`/`aesop` in any body.
- **Timing:** ~1 hour. **Depends on:** 8.
- **Files:** `NfMultiAnchorBridge.lean` — the soundness-direction reduction prefix (uncommitted WIP; lands
  jointly with Phase 10 as `bracketEndChar_kvE2_sound`).
- **Verification:** The reduction type-checks and exposes `hbr` in the `sound_of_outer` `h`-shape + the
  gate branch + non-joint channels (verified via `lean_goal` on the uncommitted WIP; a `sorry`-free
  skeleton is NOT committed — the green terminus is the assembled Phase-10 theorem). Axiom-clean on
  anything eventually committed.

### Phase 10: Stage C — per-sub soundness via kvE_subBracket2V_sound_of_outer (pin threading + hgate discharge) + non-joint channels + assembly [BLOCKED] (Stage C — RE-POINTED at task 326; blocked on MISSING outer general-j=1 quant-layer fold engine)

**BLOCKER (Phase 10; task 321 dispatch, session sess_1783452940_63339e — machine-grounded,
F-house record):**

- **What failed / exact goal.** After the Phase-9 reduction (verified green) and
  `refine ⟨w, ?_⟩; refine ⟨?_, ?_⟩`, the residual soundness goal
  `∃ w, nf_eval_nf M 2 3 (Fin.cons w [w,x,t]) qnf` splits (definitional unfold of `nf_eval_nf`
  at successor depth, NormalForm.lean:198) into:
  1. atom layer `∀ a : AtomKind sig 3, atom_eval M (Fin.cons w (Fin.cons x fun _ => t)) a ↔ qnf.1 a = true`
     — DISCHARGEABLE via `k1v_reconstruct_nf3` exactly as k1v (`bracketEndChar_k1v_sound` :2578);
  2. **quant layer** `∀ sub : NormalForm sig 1 4,
     (∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ => t))) sub) ↔ qnf.2 sub = true`
     — this is the conjunct that **cannot be discharged from landed assets**.
- **Conjunct attempted.** The quant layer over **depth-1** subs `sub : NormalForm sig 1 4`.
  `kvE_subBracket2V_sound_of_outer` (:7910) discharges the BACKWARD direction only for a
  **single interior** sub `σ ∈ lL ⊆ posIn zXW` (and symmetrically `posIn zWT`) — the joint
  channel carried by `kvE_subChain2V`. It does NOT discharge the quant layer over the other
  **five** consistent zones (`zPastX`, `zAtX`, `zAtW`, `zAtT`, `zFutT`, all permitted positive by
  `kvE_gate`/`kvE_consistent` :5157), nor the FORWARD (realization ⇒ bit) direction that needs a
  per-sub exclusion for negative subs in those zones.
- **Why structural (not effort).** For the 5 non-interior zones the carrier `kvE2_body` stores
  ONLY the **arity-1 fresh projection** literal `charK (nfk_projFresh σ) = P.existF 0 (nfk_projFresh σ)`
  (in `epL`/`ptW`/`epR` via `hasPos`), plus Since/Until wrappers. Reconstructing a full **arity-4**
  depth-1 sub `σ : NormalForm sig 1 4` (its atom layer `σ.1 : NormalForm sig 0 4` at all of
  `[x1,w,x,t]` AND its inner quant `σ.2`) from an arity-1 unary projection is impossible:
  `(zone σ, nfk_projFresh σ)` does NOT determine `σ` (unlike the depth-0 case where
  `nf0_assemble zs χ r` is a bijection). The ONLY landed quant-layer fold engines —
  `nf_quant_layer_fold_iff` (NfEFold:391) and its gate wrapper `nf_quant_layer_fold_k1_gate`
  (NfEFold:525) — are restricted to **depth-0 subs** (`NormalForm sig 0 (n+1)`, reconstructed via
  `nf0_assemble`). `nf_eval_depth1_fold_iff` (:5344) reconstructs a *single* depth-1 form, not the
  quant layer over depth-1 subs. **There is NO landed engine** producing
  `∀ sub : NormalForm sig 1 4, (∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] sub) ↔ q sub = true`. This is
  exactly the "general-`j` fold-engine lift" that the `kvE2_body` doc comment (:5602-5607) records
  as **DEFERRED follow-on** — v5's Phase-10 step-5 "assemble the discharged channels + the closed
  per-sub crux into the full soundness statement" presumes an outer quant-layer assembly that has
  no landed realization.
- **What is needed (concrete action to unblock).** A NEW general-`j=1` quant-layer fold engine
  reconstructing the depth-2 outer quant layer over depth-1 subs from the carrier's per-zone
  channels — the arity-4 / depth-1 analog of `nf_quant_layer_fold_k1_gate`, carrying the full
  arity-4 sub structure for ALL 7 consistent zones (not just the 2 interior ones the task-326
  joint channel `kvE_subChain2V` + `kvE_subBracket2V_sound_of_outer` cover). This is a plan-level
  scope gap: it belongs in a dedicated phase/task (adjacent to Stage D's fold work), NOT inside
  Phase 10's "reuse landed assets" budget. The `kvE_subBracket2V_sound_of_outer` re-point solves
  the *interior joint* crux (the reverse-Cor-5.4 wall v4 hit) but is NOT sufficient for the full
  `BracketCarrierCorrectVPrior` soundness half.
- **Prohibited (honored).** No `sorry` (live-path or strategic) landed; no vacuous placeholder;
  `kvE2_body`/`bracketEndChar_kvE2`/`kvE_subChain2V` splice UNTOUCHED (working tree byte-identical
  to commit `8448ea135`); no landed asset edited; no reverse `fChainPred → .holds` lift attempted.

**RE-POINT NOTE (v5) — original planning content follows:**

- **RE-POINT NOTE (v5):** v4's Phase 10 was `[BLOCKED]` on the reverse-Cor-5.4 wall (lifting the flat
  `fChainPred` back to a nested `.holds`). Task 326's `kvE_subBracket2V_sound_of_outer` (:7910) is the
  drop-in closer: it takes the outer `.holds` + a pin + a FORWARD `hgate` (that CONSUMES `a < t`) and
  yields the per-sub crux directly, assembling the bounded anchor + `hbelow` internally via the pin-slot
  route. Phase 10 does plumbing (pin threading + `hgate` reconstruction), not the reverse lift.
- **Goal:** Close the per-sub positive obligation (the F4 crux `∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`) by
  **consuming** `kvE_subBracket2V_sound_of_outer`, threading σ's pin witnesses and discharging its
  forward `hgate` from the outer gate channels; discharge the retained non-joint per-channel obligations
  by reusing the landed k1v closers; assemble the full soundness direction into `bracketEndChar_kvE2_sound`.
- **Tasks:**
  - [ ] **Thread σ's pin witnesses (requirement 1 — spelled out).** For the sub `σ ∈ lL` under
        consideration, exhibit `p0 := (⟨charK (nfk_projFresh σ)⟩ : TemporalPred)` and prove
        `hp0 : p0 ∈ pinSlots σ` from `kvE_pinDisjunct` (:5374, whose disjunct list is
        `[⟨charK (nfk_projFresh σ)⟩]`) — non-empty at every σ via `kvE_pinArrangements` (:5364, mapping
        `kvE_consistentZones`); supply `hσl : σ ∈ lL` (from the reduction's `hlLp`, or the outer
        `posIn zXW` membership) and `hp0eq : p0 = ⟨charK (nfk_projFresh σ)⟩` (`rfl`). These are the pin
        witnesses "already present in `.holds`" — extracted structurally, NOT re-derived.
  - [ ] **Feed `kvE_subBracket2V_sound_of_outer`** with `atomMap`, `h_surj`, `charK = P.existF 0`, `σ`,
        `M`, `w`/`x`/`t`, `l = lL`, `pins = pinSlots`, `ptW`/`segL`/`segR`/`lR`, `hσl`, `p0`/`hp0`/`hp0eq`,
        and `h = hbr` (the raw LEFT-list `.holds` from Phase 9) to obtain
        `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` — NO provider `e`, NO `w = e 1`/`x = e 2`
        residual (Amendment F3; the anchor `q` is a bracket witness, not `e`).
  - [ ] **Discharge the forward `hgate`** (`∀ a, x<a → a<t → charK-real a → a<w ∧ w<t ∧ nf_eval_nf
        reconstruction ∧ off-fiber ∧ zone-folds-forward ∧ zone-folds-reverse`) from the outer `kvE2_body`
        gate channels: the gate branch `hg : kvE_gate qnf.1 qnf.2` supplies the `nf_eval_nf`
        reconstruction + off-fiber + zone folds; `w`/`w<t` from the outer bracket's `ptW` extract
        (`hptWe`/`hwt`); `a<w` from bracket monotonicity on the LEFT slot (the pin's position). **Note the
        inversion**: `hgate` CONSUMES `a<t` (does NOT produce `x1<t`) — the `x1<t` bound comes from the
        pin-slot route inside the landed lemma. Land any intermediate mapping lemma phase-per-lemma if the
        direct hand-off does not close.
  - [ ] Discharge the non-joint channels (gate, unary `epL`/`epR`, zones, `ptW`, `segL`/`segR`,
        channel-(ii) `exclAt`) by reusing the landed k1v soundness lemmas / `kvE_pinDisjunct`/`kvE_exclConj`
        reasoning (same-module access). Confirm no `P.existF 3 σ` rebinding literal on any channel.
  - [ ] Assemble the discharged channels + the closed per-sub crux into the full soundness statement
        `bracketEndChar_kvE2_sound`; close it (no `sorry`). **This is the single soundness commit that
        subsumes the Phase-9 reduction prefix.**
  - [ ] Cite Rabinovich Cor 5.4 (forward) / Prop 3.5 / Lemma 5.1 (pin bound) at each step (G5); `by omega`
        only for `Fin`-index typing.
- **Sub-split valve:** if the `hgate` discharge exceeds the dispatch budget, split at the `hgate`-assembly
  boundary: 10a = pin threading + `sound_of_outer` consumption with `hgate` as a named open `have`
  (uncommitted WIP); 10b = `hgate` discharge + non-joint channels + soundness assembly (the green commit).
  Do NOT commit a `sorry`-shaped `hgate`.
- **Timing:** ~1.5 hours. **Depends on:** 9.
- **Files:** `NfMultiAnchorBridge.lean` — append the soundness theorem `bracketEndChar_kvE2_sound`
  (reduction prefix from Phase 9 + `sound_of_outer` consumption + pin threading + `hgate` discharge +
  non-joint closers + assembly).
- **Verification:** Scoped build green; the soundness direction closes with NO residual `e`-equation;
  `kvE_subBracket2V_sound_of_outer` consumed with all hypotheses discharged; the splice
  (`kvE_subChain2V` in `kvE2_body`) is UNTOUCHED (byte-identical to commit `8448ea135`); axiom-clean; no
  `sorry` on any live path. If a residual `e`-equation reappears, the pin was not threaded correctly —
  re-check the pin membership, do NOT introduce a pinning device (Amendment F3). If the closure appears
  to need the reverse `fChainPred → .holds` lift, STOP — that route is prohibited; the pin route must be
  used.
- **Escalation (per-phase, pre-authorized):** On a *genuine machine-grounded obstruction* in the `hgate`
  forward discharge (a concrete failing goal, not effort), record it F-house-style (exact goal, conjunct
  attempted, why structural), keep any green prefix committed, STOP for orchestrator re-dispatch. Do NOT
  absorb, shortcut, or land a `sorry`.

### Phase 11: Stage D — inner-witness fold extraction + order-bit / hcharK preparation [NOT STARTED] (Stage D — novel, highest risk; CARRIED FORWARD from v4)

- **Goal:** Begin the outer completeness direction (honest realization ⇒ carrier holds): extract σ's
  inner witnesses via the fold engine and prepare the three σ.1 order bits + the `hcharK` witness that
  `kvE_subBracket2V_complete` requires.
- **Tasks:**
  - [ ] Fold `nf_eval_depth1_fold_iff` (:5187) at `n = 4` over `(ZoneSpec 4 × NormalForm sig 0 1)` to
        extract σ's inner witnesses from `nf_eval_nf` (report Q3 Stage D; the same decomposition
        `kvE_subFoldBits` was built on, now consumed in reverse).
  - [ ] **Prepare the three order bits** `h_xx1 : σ.1 (.order ⟨2,_⟩ ⟨0,_⟩ _) = true` (x<x1),
        `h_x1w : σ.1 (.order ⟨0,_⟩ ⟨1,_⟩ _) = true` (x1<w), `h_wt : σ.1 (.order ⟨1,_⟩ ⟨3,_⟩ _) = true`
        (w<t) from the honest σ's atom layer — the exact hypotheses `kvE_subBracket2V_complete` names.
  - [ ] **Prepare `hcharK`** (`∀ a, nf_eval_nf M 1 4 (Fin.cons a [w,x,t]) σ → charK-real at a`) from the
        outer gate's charK channel (`charK = P.existF 0`), the forward-direction analog of soundness's
        `hgate` charK conjunct.
  - [ ] Cite Rabinovich at each step (G5); no forbidden tactics.
- **Timing:** ~2 hours. **Depends on:** 10.
- **Files:** `NfMultiAnchorBridge.lean` — append the fold-extraction + order-bit + `hcharK` prep lemmas.
- **Verification:** Scoped build green after each committed lemma; the extracted witness data + the
  three order bits + `hcharK` type-check against `kvE_subBracket2V_complete`'s signature; axiom-clean;
  no `sorry` on a live path.
- **Escalation (per-phase, pre-authorized):** On a *genuine machine-grounded obstruction* (a concrete
  failing goal that is not mere effort — e.g. the fold decomposition does not expose an order bit at the
  needed granularity), record it F-house-style (exact goal, lemma attempted, why structural not effort),
  keep all green work committed, and STOP for orchestrator re-dispatch or `/revise`. Do NOT absorb,
  shortcut, or land a `sorry`.

### Phase 12: Stage D — arrangement disjunct via kvE_subBracket2V_complete consumption [NOT STARTED] (Stage D — novel, highest risk; CARRIED FORWARD from v4)

- **Goal:** Discharge the joint slot of the outer completeness direction by **consuming**
  `kvE_subBracket2V_complete` (:7783), feeding the Phase-11 order bits + `hcharK` + the honest
  realization to obtain `(kvE_subBracket2V …).holds M atomMap x t`.
- **CONSTRAINT (binding non-goal):** this phase consumes the UNCHANGED `kvE_subChain2V` splice; do NOT
  alter it. Completeness stays closed only because the splice shape is byte-identical to commit `8448ea135`.
- **Tasks:**
  - [ ] Apply `kvE_subBracket2V_complete` with the three order bits (11), `hcharK` (11), and the honest
        `∃ x1, nf_eval_nf M 1 4 …` witness to produce the joint-slot `.holds` needed by the outer
        arrangement disjunct.
  - [ ] Wire the resulting `.holds` into the outer completeness arrangement as the landed :2966/:2979
        `bracketEndChar_k1v_complete` template does one arity down.
  - [ ] **Non-vacuity check (binding):** confirm (via `kvE_subBracket2V_nonvacuous` /
        `kvE2_joint_nonvacuous_at_honest`) the disjunct set is non-empty at the honest σ before the
        arrangement selection is attempted.
  - [ ] Cite Rabinovich at each chain step (G5); `by omega` only for `Fin`-index typing.
- **Timing:** ~2 hours. **Depends on:** 11.
- **Files:** `NfMultiAnchorBridge.lean` — append the `_complete` consumption + arrangement wiring.
- **Verification:** Scoped build green; `kvE_subBracket2V_complete` consumed with all hypotheses
  discharged; the arrangement disjunct type-checks; non-vacuity confirmed; the splice untouched;
  axiom-clean; no `sorry`.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine obstruction ⇒ record
  F-house-style, keep green, STOP; no absorb/shortcut/`sorry`.

### Phase 13: Stage D — non-joint completeness channels + completeness assembly [NOT STARTED] (Stage D — novel, highest risk; CARRIED FORWARD from v4)

- **Goal:** Discharge the non-joint completeness channels by reusing the landed k1v completeness lemmas,
  then assemble the full completeness direction from Phases 11-12.
- **Tasks:**
  - [ ] Discharge the non-joint completeness channels (gate, `epL`/`epR`, zones, `ptW`, `segL`/`segR`,
        `exclAt`) by reusing the landed k1v completeness lemmas where the template applies (they mirror
        the retained-verbatim channels).
  - [ ] Assemble the completeness direction (honest realization ⇒ carrier holds) from the fold
        extraction (11), the `_complete`-supplied joint disjunct (12), and the non-joint channels.
  - [ ] Cite Rabinovich at each chain step (G5).
- **Timing:** ~1.5 hours. **Depends on:** 12.
- **Files:** `NfMultiAnchorBridge.lean` — append the non-joint completeness closers + completeness
  assembly.
- **Verification:** Scoped build green; the completeness direction assembles (no `sorry`); axiom-clean;
  no forbidden tactics.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11.

### Phase 14: Stage D — gate close to GO (both directions) [NOT STARTED] (Stage D — novel, highest risk; CARRIED FORWARD from v4)

- **Goal:** Assemble the soundness (Phase 10) + completeness (Phase 13) directions into a proven **GO**
  of the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` over the new carrier.
- **Tasks:**
  - [ ] Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` — both directions
        closed, provider-independent (only `P.correct` consumed); no provider-side pinning; no
        `EANegation :1090/:1249`; no structural-identity / `nf_eval_unique` premise (route b2 NOT
        NEEDED).
  - [ ] Confirm the gate result reuses the landed 325/326 lemmas unchanged where the template applies and
        the non-vacuity gate is consumed on both directions; cite Rabinovich at each chain step (G5).
- **Timing:** ~1 hour. **Depends on:** 13.
- **Files:** `NfMultiAnchorBridge.lean` — append the completeness assembly's tail + the GO gate result.
- **Verification:** Scoped build green; the k=2 GO gate theorem type-checks (both directions closed);
  axiom-clean; no `sorry` on any live path.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine gate-close obstruction ⇒
  record F-house-style, keep green (Stages A-C + Phases 11-13 remain landed), STOP.

### Phase 15: F4 ℤ semantic LHS-FALSE + integrity sweep + GO/NO-GO verdict record [NOT STARTED] (Final; CARRIED FORWARD from v4)

- **Goal:** Discharge the deferred F4 `ℤ` semantic adversarial check against the now-closed gate over
  the new carrier, run the full integrity sweep, and land the final GO/NO-GO verdict record — the
  deliverable that unblocks task 309 Phase 13.4/14.
- **Tasks:**
  - [ ] Instantiate the F4 `ℤ` counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` marked false) against the re-pointed
        `bracketEndChar_kvE2` and prove the LHS is FALSE at `(10,20)` — the mandatory adversarial test
        MUST fail against the new carrier (discrimination via the `σ.2` read, landed at construction
        level in Phase 7). If LHS still holds, the completeness wiring lost the `σ.2` dependence —
        return to Stage D, do NOT weaken the test.
  - [ ] Update task 321's verdict record (F1-F4 house style) from PARTIAL-GO to the final **GO** (or a
        precise NO-GO/obstruction record if a Stage-D escalation fired): route b3 realized;
        `kvE_subBracket2V` wired into `kvE2_body`/`bracketEndChar_kvE2`; k=2 `BracketCarrierCorrectVPrior`
        gate closed both directions (soundness via the task-326 pin-slot route); F4 discriminated
        (construction- and semantic-level); citations per G5. The F1-F4 prior records stay byte-identical.
  - [ ] Verify byte-identity: `git diff` on `NfMultiAnchorBridge.lean` (against the Phase-8 commit
        `8448ea135`) shows a pure additive delta; the joint-channel splice (`kvE_subChain2V` in
        `kvE2_body`) is byte-identical; every forbidden-list do-not-edit asset (task-325 VVecEA2 block,
        task-326 pin-slot composition block, task-324 kit, `BracketCarrierCorrectVPrior`) unchanged; no
        other landed file touched.
  - [ ] Confirm no `simp`/`omega`/`aesop` in any chain-construction body (only `by omega` for
        `Fin`-index/length typing).
  - [ ] Run full `lake build`; confirm green, no new `sorry` on any live path, new defs/theorems
        axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) via `lean_verify`.
- **Timing:** ~1.5 hours. **Depends on:** 14.
- **Files:** `NfMultiAnchorBridge.lean` — append the F4 `ℤ` LHS-FALSE lemma + the final verdict record.
- **Verification:** Full `lake build` green; F4 counterexample lemma proves LHS FALSE under the
  re-pointed `bracketEndChar_kvE2`; `git diff` additive-only (after commit `8448ea135`);
  `lean_verify` axiom-clean on all new symbols; forbidden-list assets byte-identical; a GO/NO-GO
  verdict record landed.

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 15.
- [ ] Phase 8 (LANDED, commit `8448ea135`): `bracketEndChar_kvE2` characterizes `kvE_subBracket2V` on the
      joint path; `two_eq` closes; `kvE2_joint_nonvacuous_at_honest` consumed (non-vacuity gate passed)
      BEFORE any correctness direction.
- [ ] Stage C soundness (Phases 9-10, RE-POINTED): the soundness direction of the k=2 gate closes with NO
      residual `w = e 1`/`x = e 2` (no provider `e` on the joint path) via `kvE_subBracket2V_sound_of_outer`,
      with σ's pin witnesses threaded (`p0 = ⟨charK (nfk_projFresh σ)⟩ ∈ pinSlots σ`, `σ ∈ lL`) and the
      forward `hgate` discharged from the outer gate channels; NO reverse `fChainPred → .holds` lift used.
- [ ] Stage D completeness (Phases 11-14, CARRIED FORWARD): `kvE_subBracket2V_complete`'s order bits +
      `hcharK` are discharged at the integration site; the arrangement disjunct consumes the `_complete`
      output; the k=2 `BracketCarrierCorrectVPrior` gate closes to a proven GO (both directions).
- [ ] **Splice untouched (binding non-goal):** the `kvE_subChain2V` joint splice in `kvE2_body` is
      byte-identical to commit `8448ea135` after the soundness re-point.
- [ ] MANDATORY adversarial test (Phase 15): F4 `ℤ` counterexample (`char[14,16,11,20]` vs honest
      `char[14,15,10,20]`) FAILS against the re-pointed carrier (LHS FALSE at `(10,20)`).
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on any
      live path (no `sorry`-skeleton committed at any phase boundary, including the 9/10 boundary).
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Guards G1-G6 + Corrected Anchor-Cap honored; anchor set fixed at 2; no third-anchor tower; the pin
      anchor `q` is a bracket WITNESS in `(x, w_outer)` (not an anchor); `x1`/`w` self-zones are zone-spec
      values, not anchors (325 Guard G4).
- [ ] EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3).
- [ ] Every forbidden-list do-not-edit asset byte-identical (task-325 VVecEA2 block, task-326 pin-slot
      composition block, task-324 kit, `BracketCarrierCorrectVPrior`, all F1-F4 records); all new work
      additive after commit `8448ea135`.

## Artifacts & Outputs

- `specs/321_.../plans/05_corrected-k2-carrier-gate-v5.md` (this plan; supersedes v4).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — the additive soundness
  theorem `bracketEndChar_kvE2_sound` (Phases 9-10: reduction prefix + `kvE_subBracket2V_sound_of_outer`
  consumption + pin threading + forward `hgate` discharge + non-joint closers + assembly); the
  completeness fold-extraction + order-bit/`hcharK` prep + arrangement disjunct via `_complete` +
  non-joint channels + gate-close to GO (Phases 11-14); the F4 `ℤ` LHS-FALSE lemma + final GO/NO-GO
  verdict record (Phase 15). All additive on top of the already-landed Stage A/B block, the LANDED
  Phase-8 wiring (commit `8448ea135`), and the consumed task-325/326 lemmas; forbidden-list do-not-edit
  assets byte-identical; the `kvE_subChain2V` splice untouched.
- `specs/321_.../summaries/05_corrected-k2-carrier-gate-v5-summary.md` (at implementation completion).

## Rollback/Contingency

- All v5 work is additive proof-side after the landed Phase-8 commit `8448ea135`; to revert, delete the
  appended definitions/theorems/verdict update — every forbidden-list do-not-edit asset (including the
  task-325/326 lemmas) and the `kvE2_body` splice are untouched.
- If the pin threading (Phase 10) does not line up with the Phase-9 reduction's exposed `lL`/pin data:
  fire the pin-threading sub-split valve; adjust the `subst`/`obtain`/`change` so `hbr`'s bracket-list is
  definitionally the `sound_of_outer` `h`-argument shape; do NOT restructure the splice.
- If soundness's forward `hgate` discharge (Phase 10) exceeds budget: fire the 10a/10b sub-split valve;
  keep the `sound_of_outer` consumption with `hgate` as an open `have` in an uncommitted WIP; discharge
  `hgate` + non-joint channels + assembly next dispatch (commit the assembled green theorem).
- If the soundness closure appears to require the reverse `fChainPred → .holds` lift: STOP — that route is
  prohibited (documented unprovable). The pin-slot route via `kvE_subBracket2V_sound_of_outer` is the only
  sanctioned mechanism; re-check the pin membership + `hgate` mapping.
- If a residual `e`-equation reappears (Phase 10): the pin was not threaded correctly — re-check the pin
  membership, do NOT introduce a pinning device (Amendment F3).
- If a Stage-D phase (11-14) hits a *genuine machine-grounded obstruction*: fire that phase's Escalation
  bullet — record it F-house-style (exact goal, why not effort), keep all green work committed, and STOP
  for orchestrator re-dispatch or `/revise`. Do NOT absorb, shortcut, or `sorry`.
- If the F4 counterexample fails to discriminate semantically (Phase 15): the completeness wiring lost
  the `σ.2` dependence — return to Stage D; do not weaken the adversarial test.
- If any step appears to require a two-anchor single-point assertion: design smell (Gabbay
  cross-check) — escalate to the orchestrator blocker ladder, do not engineer around it. Land a verdict
  record either way (GO, NO-GO, or a defect record), per F1-F4 house style; no partial theorem, no
  `sorry`.
