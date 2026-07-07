# Implementation Plan (v4): Corrected k=2 Carrier — Close the k=2 Correctness Gate (wire task-325's VVecEA2 correctness pair)

- **Task**: 321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Status**: [NOT STARTED]
- **Effort**: ~19 hours total (Stages A+B + integrity ≈ 13.5h COMPLETED and landed; ~9h remaining across the v4 wiring/gate close + final verdict — down from v3's ~17.5h because task 325 delivered the arity-4 sub-bracket correctness pair the v3 Phase-8 blocker demanded)
- **Dependencies**: 320 (GO verdict on route b3, design spec §5 — COMPLETED). Task 324 is [ABANDONED] (superseded by 325); its landed Phases 1-5 assets remain consumable. The k=2 sub-bracket correctness pair is supplied by task 325 (COMPLETED 2026-07-07).
- **Research Inputs**:
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md (blocker resolution: successor-parameterization, forced encoding, staged gate — Section 3 is the drop-in amended design spec)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/summaries/02_vvecea2-carrier-v2-completion-summary.md (**the new asset** — authoritative statement of the landed VVecEA2 arity-4 correctness pair that unblocks Phase 8)
  - specs/325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/plans/02_vvecea2-carrier-v2-nine-zone-gate.md (the executed v2 nine-zone-gate plan behind that asset)
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md (postmortem background: why the old `kvE_subBracket` upward-only chain could never satisfy Phase 8's `zXU`-below-`u` obligation)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md (design spec §5, route b3 GO)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (binding framing caveat)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 blocker origin)
- **Artifacts**: plans/04_corrected-k2-carrier-gate-v4.md (this file; supersedes plans/03_corrected-k2-carrier-gate-v3.md)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **reports_integrated**: 01_blocker-research-successor-k.md; 02_vvecea2-carrier-v2-completion-summary.md; 02_vvecea2-carrier-v2-nine-zone-gate.md; 02_phase6-blocker-research.md; 02_jointpinning-probe-results.md; 01_literature-alignment.md; 06_spawn-analysis-f4.md

## Overview

This is **v4**, superseding v3 (`plans/03_corrected-k2-carrier-gate-v3.md`). v3 decomposed the k=2
`BracketCarrierCorrectVPrior` correctness gate (Stages C soundness + D completeness) into
single-dispatch phases and resumed at Phase 8. Phase 8 hit a **machine-grounded structural blocker**
(commit `537dac4fb`): the per-sub soundness crux could not be reduced to the landed Stage-A assets,
because the landed `kvE_subBracket` places `u`'s own point-type at the TOP of a strictly-**upward**
`fChainPred`, so σ's below-anchor interior zone `zXU = (x < v < u)` is structurally unreachable — a
defect of the LANDED carrier construction, not a proof-effort gap. Resolving it required **editing a
do-not-edit landed asset** (a Stage-A redesign), so task 321 recorded a PARTIAL-GO and **spawned task
325** to build a correct sub-bracket with a machine-driven correctness pair.

**Task 325 delivered (COMPLETED 2026-07-07).** It landed a corrected two-anchor bracket-characteristic
carrier `kvE_subBracket2V` (codomain `VVecEA2`, a nine-zone arrangement-disjunction) together with a
freshly re-derived, machine-driven-through **soundness AND completeness pair** — the arity-4 analog of
the k1v pair `(bracketEndChar_k1v_sound, bracketEndChar_k1v_complete)`. Both directions are closed
sorry-free and **non-vacuously**, axiom-clean `{propext, Classical.choice, Quot.sound}`, STANDALONE
against `nf_eval_nf M 1 4`. It is deliberately NOT yet wired into `kvE2_body`/`bracketEndChar_kvE2`;
**that wiring is exactly this v4's subject** (325's do-not-edit exception explicitly deferred it here).

**The purpose of v4 is narrow and structural**: fold the landed `kvE_subBracket2V` carrier + its
`kvE_subBracket2V_sound`/`kvE_subBracket2V_complete` pair into a phase decomposition that (a) re-points
the outer soundness scaffolding at `kvE_subBracket2V_sound` (consuming, not re-deriving), (b) wires the
new carrier into `kvE2_body`/`bracketEndChar_kvE2`, (c) discharges/threads the completeness lemma's
`hcharK` + order-bit hypotheses at the integration site, (d) preserves the Stage-D outer-gate
completeness assembly as the novel highest-risk region with H8 one-dispatch sizing + sub-split valves,
(e) carries forward all guards G1-G6 + Corrected Anchor-Cap, Amendment F3, driven-proof validation
discipline, forbidden-tactics rules, and the non-vacuity-gate countermeasure, and (f) ends with the
outer `bracketEndChar_kvE2` correctness statement over the new carrier, machine-verified — the
deliverable that unblocks task 309 Phase 13.4/14.

The completed Stage A/B/integrity work (v3 Phases 1-7) is carried forward verbatim as `[COMPLETED]`
with commit hashes and is never re-run or re-derived. **The single exception is the deliberate
re-pointing of `kvE2_body`/`bracketEndChar_kvE2`/`bracketEndChar_kvE2_two_eq` at the new carrier —
these are task 321's OWN Stage-A assets, so editing them is within this task's authority** (see the
DO-NOT-EDIT discipline note under Phase 8 and the preserved-assets table). All other binding
constraints (Guards G1-G6 + Corrected Anchor-Cap, Amendment F3, do-not-edit byte-identity of the
forbidden-list assets, consume-do-not-rebuild, no `EANegation :1090/:1249`, no `simp`/`omega`/`aesop`
on chain steps, Rabinovich citations per G5, no `sorry` on live paths, non-vacuity gate before any
correctness direction, verdict record either way, full green build) are carried unchanged.

Definition of done (unchanged in substance from v3): the k=2 correctness gate for `bracketEndChar_kvE2`
passes to a recorded **GO** verdict (both directions closed) over the new `kvE_subBracket2V`-based
carrier; the F4 `ℤ` counterexample is discriminated (LHS FALSE at `(10,20)` under the new carrier);
green `lake build`; axiom-clean (`propext`, `Classical.choice`, `Quot.sound`); no `sorry` on any live
path; every forbidden-list do-not-edit asset byte-identical; a verdict record landed. If a Stage-D
phase hits a *genuine machine-grounded obstruction* (not mere effort), the per-phase escalation rule
fires (record F-house-style, keep green work committed, stop).

### Research Integration

v4 integrates the **new task-325 deliverable** as its central asset. The landed symbols (grep-verified
in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`; anchors below, line
numbers indicative only):

- `kvE_subBracket2V` (:6779) — nine-zone `VVecEA2` arrangement-disjunction carrier (three-region
  `bracketFromLists3 lXU ptX1 lUW ptW lWT`), STANDALONE against `nf_eval_nf M 1 4`.
- `kvE_subChain2V` (:6901) — the sub-chain (`.fChainPred`) over the three-region bracket.
- `bracketFromLists3` (:6753), `k1v_sorted_realization3` (:6947), `k1v_bracket_construct3` (:7023),
  `bracketFromLists3_extract` (:7251) — the arity-4 three-region bracket kit.
- `kvE_subBracket2V_gate_holds_of_honest` (:7710), `kvE_subBracket2V_nonvacuous` (:7743) — the
  **non-vacuity gate**: honest σ ⟹ `disjuncts ≠ []`; the structural countermeasure that closes the
  three prior gate-class failures (task 321 P8 reachability; task 324 P6 false-∀-M converse; task 325
  v1 empty-gate vacuity).
- `kvE_subBracket2V_sound` (:7514) — `.holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`, taking
  an **explicit `hgate`** reconstruction hypothesis (Amendment F3: no provider pinning).
- `kvE_subBracket2V_complete` (:7783) — the reverse; takes **three σ.1 order bits** (`h_xx1: x<x1`,
  `h_x1w: x1<w`, `h_wt: w<t`, expressed as `σ.1 (.order …) = true`) **plus an explicit `hcharK`**
  charK-realization hypothesis, the exact mirror of soundness's `hgate` (recorded plan deviation, 325
  Phase 3, because `ptX1`'s head is `charK (nfk_projFresh σ)`, a depth-1 type).
- `kvE_subBracket2V_correctness_pair` (:8173) — doc bundle of the pair; no new proof obligations.

**How the completeness hypotheses are threaded (requirement c).** The v4 wiring phases discharge the
explicit hypotheses of both directions at the outer-gate integration site (they are NOT re-derived —
they are supplied by the outer `kvE2_body`/`bracketEndChar_kvE2` gate channels):

| 325 lemma hypothesis | Where v4 discharges it |
|----------------------|------------------------|
| `kvE_subBracket2V_sound.hgate` (∀ a ∈ (x,t), charK-real at a ⇒ anchor placement + full `nf_eval_nf` reconstruction + off-fiber + zone folds) | Phase 10: from the outer `kvE2_body` gate channels — `kvE_gate` supplies the anchor `a∈(x,t)`; the point-coincidence/exterior/zone channels supply the fold reconstruction; off-fiber from the outer gate. |
| `kvE_subBracket2V_complete.h_xx1/h_x1w/h_wt` (three σ.1 order bits) | Phase 11: from the honest σ's atom layer via `nf_eval_depth1_fold_iff` (:5187) at `n=4` — the honest realization forces `x < x1 < w < t`, read off as the three `.order` bits. |
| `kvE_subBracket2V_complete.hcharK` (∀ a, `nf_eval_nf … σ` ⇒ charK-real at a) | Phase 12/13: from the outer gate's charK channel (`charK = P.existF 0` in `bracketEndChar_kvE2`), the same channel that supplies soundness's `hgate` charK conjunct, run in the forward direction. |

Carried forward from v3 (unchanged): route b1 NO-GO, Cor 5.4 chain-shape MATCH, route b3 GO, route b2
NOT NEEDED; successor-parameterization is a landed fact. The `01_blocker-research-successor-k.md`
§2/Q3 staged-gate structure remains the binding amended design spec.

### Prior Plan Reference

v3 (`plans/03_corrected-k2-carrier-gate-v3.md`) is **[SUPERSEDED]** by this v4. v3's Phases 1-7 (Stage
A construction + Stage B discrimination + PARTIAL-GO verdict + baseline) are `[COMPLETED]`, landed,
and committed (hashes below); they are carried forward verbatim and are never re-executed. v3's Phase 8
was `[BLOCKED]` (the upward-only-chain-cannot-reach-`zXU` structural defect); v3 Phases 9-15 were
`[NOT STARTED]` under the assumption that Stage C was "extraction reuse + landed crux closer" — an
assumption the Phase-8 blocker refuted. v4 **replaces v3 Phases 8-15** with a decomposition that
consumes task 325's now-landed sub-bracket correctness pair: a wiring-foundation phase (8), a
re-pointed Stage C (soundness, 9-10), a re-pointed Stage D (completeness, 11-14, the preserved novel
highest-risk region), and the final verdict phase (15). The lineage context (v6→v7 re-pointing pattern,
F1-F4 house style, parent task 309) remains binding.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context). Goal-state alignment for the enclosing
chain: this task's GO gate is the prerequisite for task 309's Phase 13.4 (general-k one-step
correctness) and Phase 14 (hook rewire discharging `KampPrior.lean:351`'s strategic `sorry`, target
axioms exactly `[propext, Classical.choice, Quot.sound]`). After a GO here, task 309 resumes via
`/implement 309` (possibly preceded by `/revise 309` for a v8 re-pointing to the new deliverable
names). Because v4 keeps the gate **in-task**, no further completeness spawn is created; the gate GO is
delivered by task 321 itself.

## Goals & Non-Goals

**Goals**:
- Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` to a proven **GO** (both
  directions) over a carrier re-pointed at task 325's `kvE_subBracket2V`, by **consuming**
  `kvE_subBracket2V_sound`/`kvE_subBracket2V_complete` (not re-deriving them) and discharging their
  explicit `hgate`/`hcharK`/order-bit hypotheses from the outer `kvE2_body` gate channels.
- Wire the new carrier into `kvE2_body`/`bracketEndChar_kvE2` and re-derive the `two_eq` bridge (task
  321 owns these assets — see the DO-NOT-EDIT discipline note under Phase 8).
- Preserve the Stage-D outer-gate completeness assembly (Phases 11-14) as the novel highest-risk region
  with H8 one-dispatch sizing and explicit sub-split valves.
- Discharge the F4 `ℤ` semantic LHS-FALSE at `(10,20)` against the re-pointed `bracketEndChar_kvE2`,
  then run the integrity sweep and land a GO/NO-GO verdict record.
- Preserve every forbidden-list do-not-edit asset byte-identical; keep all new work additive except the
  authorized re-point of `kvE2_body`/`bracketEndChar_kvE2`/`two_eq`.
- Carry the **non-vacuity gate** forward: any new carrier-level lemma must pass a non-vacuity check
  (consume `kvE_subBracket2V_nonvacuous`, or prove the analog) BEFORE its correctness directions are
  attempted — the structural countermeasure to the three prior gate-class vacuity/reachability failures.

**Non-Goals**:
- No re-execution, re-derivation, or edit of the completed Stage A/B assets other than the authorized
  re-point (`kvE_subFoldBits`, `kvE_subInteriorZones`, the old `kvE_subBracket`/`kvE_subChain` +
  `kvE_subBracket_implies_subChain`, the Stage-B discrimination lemmas remain landed and byte-identical
  and become UNREFERENCED on the joint path once the re-point lands).
- No re-derivation of task 325's `kvE_subBracket2V` correctness pair — it is landed, axiom-clean, and
  consumed as-is. No edit of task-325's kit (`bracketFromLists3`, `k1v_sorted_realization3`,
  `k1v_bracket_construct3`, `bracketFromLists3_extract`, the `_sound`/`_complete`/`_nonvacuous`/
  `_correctness_pair` block) or task-324's landed kit.
- No spawn of the completeness direction to a separate task — v4 keeps the gate in task 321.
- No third FLAT carrier variant (`kvE''`-style per-sub literal at `t`) — the F3/F4-refuted shape.
- No provider-side pinning (Amendment F3 binding); the provider *disappears* from the joint path.
- No consumption of `EANegation :1090/:1249`.
- No structural-identity / `nf_eval_unique` / `nfPred_correct` hypothesis on the gate (route b2 NOT
  NEEDED).
- No edits to any forbidden-list landed asset (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1-F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material, the task-320 probes, the
  task-324 landed kit, and the task-325 VVecEA2 block). Task 321's own PARTIAL-GO verdict record is
  updated to the final GO/NO-GO record in the final phase — that is task 321's own output.
- No general-k work (task 309 Phase 13.4/14) — out of scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The re-point of `kvE2_body` at `kvE_subChain2V` drifts the body shape so `bracketEndChar_kvE2_two_eq` no longer closes by `rfl` | M | M | Phase 8 sub-split valve: 8a re-point body, 8b re-derive the `two_eq` bridge; if `rfl` fails, the k1v-shaped `two_eq` discipline (:5972) is the template — adjust the depth threading, do NOT edit the landed carrier signature `BracketEndCharCarrierV sig 2`. |
| Discharging soundness's explicit `hgate` from the outer `kvE2_body` gate channels is heavier than a direct hand-off (the ∀a reconstruction bundles anchor placement + off-fiber + zone folds) | H | M | Phase 10 maps each `hgate` conjunct to a named outer channel (see Research-Integration threading table); if the mapping needs an intermediate lemma, land it phase-per-lemma, commit-per-green. Sub-split valve at the `hgate`-assembly boundary. |
| Threading `hcharK` + the three order bits through the outer completeness direction (Stage D) stalls — outer-gate completeness has no k≥2 precedent even though the inner pair is landed | H | M | Stage D decomposed into 4 phases (11 extraction+order-bits, 12 arrangement disjunct via `_complete`, 13 non-joint channels + assembly, 14 gate close), phase-per-lemma, commit-per-green. **Per-phase escalation**: on a genuine machine-grounded obstruction, record it F-house-style, keep green work committed, STOP. |
| A wiring phase re-inflates past one dispatch (~150-400 line output) | M | M | Each phase is bounded to one agent run and one named obligation cluster; if output would exceed budget, split at the next lemma boundary and commit the green prefix (explicit sub-split valves noted per phase). |
| The re-pointed carrier is vacuous at the outer level (empty `disjuncts` ⇒ soundness closes trivially) — the exact failure mode of task 325 v1 | H | L | **Non-vacuity gate countermeasure (binding)**: before ANY correctness direction is attempted over the re-pointed carrier, consume `kvE_subBracket2V_nonvacuous` (:7743) at the honest σ to confirm `disjuncts ≠ []`. A carrier-level lemma without a passing non-vacuity check is a Phase-8/9 return, not a workaround. |
| Accidental edit / byte drift of a forbidden-list do-not-edit asset (now including the task-325 VVecEA2 block and task-324 kit) | H | L | All v4 work is additive after the landed blocks except the authorized `kvE2_body`/`bracketEndChar_kvE2`/`two_eq` re-point; verify byte-identity via `git diff` (expect additive + the three re-pointed 321-owned defs) in the final phase; the 325/324 kits are consumed, not rebuilt. |
| Anchor growth / third-anchor tower slips in via the completeness witnesses (G2/G4/G6) | H | L | Anchor set fixed at 2 `{x,t}`; `x1`/`w` are interior witness slots (adding their self-zones to the `VVecEA2` gate does not make them anchors — a self-zone is a zone-spec value, per 325 Guard G4). Verify in the final phase. |
| F4 counterexample does not discriminate at the semantic level (LHS still holds) | H | L | Construction-level discrimination is LANDED (v3 Phase 7). The final phase evaluates on `M=ℤ`; if LHS still holds, the completeness wiring lost the `σ.2` dependence — return to Stage D, do NOT weaken the test. |

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
| 8 | 8 | 7 | Wiring foundation — re-point carrier (resume here) |
| 9 | 9 | 8 | C (soundness scaffolding over new carrier) |
| 10 | 10 | 9 | C (per-sub soundness via `_sound` + `hgate` + assembly) |
| 11 | 11 | 10 | D (fold extraction + order-bit/`hcharK` prep) |
| 12 | 12 | 11 | D (arrangement disjunct via `_complete`) |
| 13 | 13 | 12 | D (non-joint completeness channels + assembly) |
| 14 | 14 | 13 | D (gate close to GO, both directions) |
| 15 | 15 | 14 | Final (ℤ LHS-FALSE + integrity + GO/NO-GO verdict) |

This construction is inherently sequential (each gate layer builds on the previous), so each wave holds
one phase. **Implementation resumes at Phase 8** (wiring foundation); Phases 1-7 are landed and carried
forward.

### Preserved-Assets Table

| Asset | Origin | v4 disposition |
|-------|--------|----------------|
| `kvE_subFoldBits`, `kvE_subInteriorZones` | 321 Stage A (P2-3) | **KEEP** (landed, byte-identical; still consumed by the fold reads) |
| `kvE_subBracket`, `kvE_subChain`, `kvE_subBracket_implies_subChain` | 321 Stage A (P3-4) | **KEEP landed but UNREFERENCED on joint path** after the Phase-8 re-point (the F4-blocked upward-only design; superseded on the joint path by `kvE_subChain2V`) |
| `kvE2_body`, `kvE2_body_gate_fail` | 321 Stage A (P5) | **EDIT (authorized re-point)** — joint channel `kvE_subChain σ` → `kvE_subChain2V σ`; 321-owned |
| `bracketEndChar_kvE2`, `bracketEndChar_kvE2_two_eq` | 321 Stage A (P6) | **EDIT (authorized re-point)** — carrier picks up new joint channel; `two_eq` re-derived; 321-owned |
| Stage-B discrimination lemmas (`kvE_subBracket_witnessCount`, `_ne_of_witnessCount_ne`) | 321 Stage B (P7) | **KEEP** landed; construction-level F4 record (semantic tail is Phase 15) |
| `kvE_subBracket2V` (+ `kvE_subChain2V`, `bracketFromLists3`, `k1v_sorted_realization3`, `k1v_bracket_construct3`, `bracketFromLists3_extract`) | **task 325** | **CONSUME** (do-not-edit; the new joint-channel carrier) |
| `kvE_subBracket2V_sound`, `kvE_subBracket2V_complete`, `kvE_subBracket2V_correctness_pair` | **task 325** | **CONSUME** (do-not-edit; the correctness pair fed at the joint slot) |
| `kvE_subBracket2V_gate_holds_of_honest`, `kvE_subBracket2V_nonvacuous` | **task 325** | **CONSUME** (do-not-edit; the non-vacuity gate countermeasure) |
| `kvE_sub2` zone kit, `kvE_subBracket2_complete_extract` | task 324 (landed P1-5) | **CONSUME if needed** (do-not-edit; 324 abandoned but assets landed) |
| `k1v_bracket_extract` (:2150), `bracketEndChar_k1v_sound` (:2338), `bracketEndChar_k1v_complete` (:2979) | k1v template | **CONSUME** (do-not-edit; outer-gate template one arity down) |
| `BracketCarrierCorrectVPrior`, `ExistProviders`, `bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`, F1-F4 records, task-320 probes, task-310/311 material | forbidden list | **DO-NOT-EDIT** (byte-identical) |

### Postmortem — Phase-8 blocker (v3) and how v4 avoids it

| Field | Record |
|-------|--------|
| **Blocker** | v3 Phase 8 (`537dac4fb`): soundness's per-sub crux `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` was not reducible to the landed assets. |
| **Root cause** | The landed `kvE_subBracket` builds a single strictly-**upward** `fChainPred` with `u`'s own point-type at the TOP of `posSlots ++ [u]`. σ's interior zone `zXU = (x < v < u)` lies BELOW `u` and is unreachable by any upward chain from `u`; `kvE_subBracket_implies_subChain` also runs the WRONG direction for soundness (bracket-holds → chain-at-point, not `nf_eval_nf` reconstruction). The `zXU`-below-`u` gap is a property of the landed construction, so fixing it in-place would require editing a do-not-edit asset. |
| **Resolution (task 325)** | `kvE_subBracket2V` lifts the k1v LOWER-endpoint geometry one arity up: `x1`/`u`'s slot sits in the MIDDLE of the ascending witness list, so a single upward chain from the lower endpoint `x` reaches all three interior zones including `zXU`. The nine-zone `VVecEA2` arrangement disjunction + non-vacuity gate closes BOTH directions non-vacuously. |
| **How v4 wiring avoids the blocker** | v4 never re-attempts the reachability crux by hand — Phase 10 **consumes** `kvE_subBracket2V_sound` (which already reaches `zXU`), discharging only its explicit `hgate` from the outer gate; Phases 11-14 **consume** `kvE_subBracket2V_complete`, discharging its order-bits + `hcharK`. The reachability geometry is settled inside the landed 325 pair; v4 does plumbing, not chain construction, on the joint path. |

---

### Phase 1: Baseline capture and landed-asset integrity snapshot [COMPLETED]

- **Commit:** `b9cb244e6`.
- **Outcome (landed):** Scoped `lake build` green; task-320 probe section present and axiom-clean;
  do-not-edit asset byte ranges recorded; F4 crux goal + `ℤ` counterexample recaptured;
  CONSUME-DO-NOT-REBUILD asset list confirmed available; `git diff` clean at phase start.
- **Files:** `NfMultiAnchorBridge.lean` (read-only).

### Phase 2: Successor-parameterized σ.2 read and sub-fold-bit decoding [COMPLETED] (Stage A)

- **Commit:** `0c9f0bc88` (after machine-grounded resolution of the `e8521fd1d` design-gap blocker).
- **Outcome (landed):** `kvE_subFoldBits` (:5728) + `_eq_destructors` (`rfl`); the gate-instance decoder
  via `nf_eval_depth1_fold_iff` (:5187) at `n=4`. No forbidden tactics.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 3: Construct kvE_subBracket (nested sub-bracket over σ.2, forced k1v routing) [COMPLETED] (Stage A)

- **Commit:** `201902b97`.
- **Outcome (landed):** `kvE_subBracket` (:5779) type-checks as `Σ m, BracketFormula (m+1)`,
  axiom-clean; `kvE_subInteriorZones = [zXU, zUW, zWT]` (:5751); `posSlots`/`segExcl` route the `σ.2`
  bits. G1-G6 verified. Rabinovich Def 3.1 / Lemma 5.1 cited. **NOTE:** this is the upward-only design
  whose `zXU`-below-`u` reachability gap caused the v3 Phase-8 blocker; superseded on the joint path by
  task 325's `kvE_subBracket2V`, but kept byte-identical.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 4: Define kvE_subChain and its position-recovery lemma [COMPLETED] (Stage A)

- **Commit:** `c8db183da`.
- **Outcome (landed):** `kvE_subChain` (:5807) + `kvE_subBracket_implies_subChain` (:5824), sole
  hypothesis `bf.holds`, no provider env `e`. Rabinovich Cor 5.4 / Prop 3.5 cited. Kept byte-identical;
  superseded on the joint path by `kvE_subChain2V`.
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 5: Assemble kvE2_body (corrected enriched body, successor-parameterized) [COMPLETED] (Stage A)

- **Commit:** `e3dfba315`.
- **Outcome (landed):** `kvE2_body … : VVecEA2` (the concrete gate instance) + `kvE2_body_gate_fail`
  mirror; flat per-sub joint literal replaced by the `kvE_subChain σ` splice; `P.existF 3` dropped from
  the joint path. **v4 re-points this joint splice at `kvE_subChain2V` in Phase 8 (321-owned asset).**
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 6: Define bracketEndChar_kvE2 carrier and two_eq bridge [COMPLETED] (Stage A)

- **Commit:** `2075533a8`.
- **Outcome (landed):** `bracketEndChar_kvE2 (P : ExistProviders sig atomMap 1) :
  BracketEndCharCarrierV sig 2` + `bracketEndChar_kvE2_two_eq` (`rfl`), delegating to `kvE2_body`,
  `charBase = nf_depth0_char_formula`, `charK = P.existF 0`. **v4 re-derives `two_eq` in Phase 8 after
  the joint-channel re-point (321-owned asset).**
- **Files:** `NfMultiAnchorBridge.lean` (append).

### Phase 7: F4 construction-level discrimination + PARTIAL-GO verdict [COMPLETED] (Stage B)

- **Commit:** `4e1986627` (recorded as "phase 7+11": Stage-B discrimination + PARTIAL-GO verdict).
- **Outcome (landed):** `kvE_subBracket_witnessCount` (`rfl`) + `kvE_subBracket_ne_of_witnessCount_ne`;
  axiom-clean. Honest vs dishonest subs produce DIFFERENT witness-slot lists (they read `σ.2`). The
  full `M=ℤ` SEMANTIC LHS-FALSE is deferred to Phase 15. The PARTIAL-GO verdict record landed here is
  updated to the final GO/NO-GO record in Phase 15 (task 321's own output).
- **Files:** `NfMultiAnchorBridge.lean` (append).

---

### Phase 8: Wiring foundation — re-point kvE2_body/bracketEndChar_kvE2 at kvE_subChain2V + re-derive two_eq [COMPLETED]

- **DO-NOT-EDIT discipline note (binding):** `kvE2_body`, `kvE2_body_gate_fail`, `bracketEndChar_kvE2`,
  and `bracketEndChar_kvE2_two_eq` are **task 321's OWN Stage-A assets** (landed by commits
  `e3dfba315`/`2075533a8` under this very task). Editing them to re-point the joint channel at the new
  carrier is therefore **within this task's authority** — it is NOT an edit of a forbidden-list
  do-not-edit asset. Task 325's do-not-edit exception explicitly deferred this re-point to task 321.
  The forbidden-list assets (`bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
  `BracketCarrierCorrectVPrior`, `ExistProviders`, F1-F4 records, task-320 probes, task-324 kit,
  task-325 VVecEA2 block) remain byte-identical.
- **Goal:** Re-point the joint channel of `kvE2_body` from the old (F4-blocked) `kvE_subChain σ` splice
  to task 325's `kvE_subChain2V σ` (the sub-chain over `bracketFromLists3`), so `bracketEndChar_kvE2`
  characterizes the new `kvE_subBracket2V` carrier; re-derive the `two_eq` bridge; confirm non-vacuity.
- **Tasks:**
  - [x] Edit `kvE2_body` (321-owned): replace the joint-channel splice `kvE_subChain σ` with
        `kvE_subChain2V σ` (:6901). Retain every non-joint 13.2 channel verbatim. No `P.existF 3` on
        the joint path; `P.existF 0` retained. *(deviation: altered — `kvE_subChain2V` returns
        `List TemporalPred` (one fChainPred per arrangement-disjunct), not a single `TemporalPred`
        like the old `kvE_subChain`, so `ptSub`'s codomain became `List TemporalPred` and the joint
        splice in `slotsFor` changed from `ptSub σ :: pinSlots σ` to `ptSub σ ++ pinSlots σ`. All
        non-joint channels byte-identical.)*
  - [x] Confirm `bracketEndChar_kvE2` (321-owned) now delegates to the re-pointed `kvE2_body` at
        `BracketEndCharCarrierV sig 2` with `charBase = nf_depth0_char_formula`, `charK = P.existF 0`.
        *(unchanged def; inherits the re-point through `kvE2_body`.)*
  - [x] Re-derive `bracketEndChar_kvE2_two_eq` (321-owned): closes by `rfl` (verified green — depth
        threading unchanged; valve 8b not needed).
  - [x] **Non-vacuity gate (binding countermeasure):** consumed `kvE_subBracket2V_nonvacuous` (:7743)
        as a `have` in new additive lemma `kvE2_joint_nonvacuous_at_honest` at the wiring boundary,
        BEFORE any Stage-C/D direction. Axiom-clean.
  - [x] Cite Rabinovich at each structural step (G5); no `simp`/`omega`/`aesop` in any body.
  - *(deviation: altered — necessary relocation. The re-point makes `kvE2_body` reference
    `kvE_subChain2V`/`kvE_subBracket2V` which are DEFINED LATER (task-325 block :6757/:7599) than
    `kvE2_body`'s landed position (:5859), a Lean forward-reference error. Resolved by relocating the
    four 321-owned defs (`kvE2_body`, `kvE2_body_gate_fail`, `bracketEndChar_kvE2`,
    `bracketEndChar_kvE2_two_eq`) + the new `kvE2_joint_nonvacuous_at_honest` to just before
    `end Bimodal…`, after the task-325 block. Task-325 VVecEA2 block + all other forbidden-list
    assets stay byte-identical; `git diff` comm-verified that only the joint-channel lines + the new
    lemma are content changes, the rest is pure relocation.)*
- **Sub-split valve:** 8a = re-point `kvE2_body` + `bracketEndChar_kvE2`; 8b = re-derive `two_eq` +
  non-vacuity consumption. If 8a's build is green but 8b's `two_eq` needs shape adjustment, commit 8a's
  green prefix and continue 8b in the next dispatch.
- **Timing:** ~1.5 hours. **Depends on:** 7.
- **Files:** `NfMultiAnchorBridge.lean` — edit the three 321-owned defs; append the non-vacuity `have`.
- **Verification:** Scoped build green; `bracketEndChar_kvE2` characterizes `kvE_subBracket2V` on the
  joint path; `two_eq` closes (`rfl` or the adjusted bridge); `kvE_subBracket2V_nonvacuous` consumed;
  axiom-clean; no `sorry`; `git diff` shows only the three authorized 321-owned edits + the additive
  `have`, all forbidden-list assets byte-identical.

### Phase 9: Stage C soundness scaffolding — gate entry + k1v extraction reuse over the new carrier [NOT STARTED] (Stage C)

- **Goal:** Open the `BracketCarrierCorrectVPrior` soundness direction (carrier holds ⇒ ∃w realization)
  for the re-pointed `bracketEndChar_kvE2`, reduce it through `bracketEndChar_kvE2_two_eq` to the
  k1v-shaped body, and reuse the landed extraction lemma to expose the per-channel / per-sub obligation
  structure — WITHOUT yet discharging the joint obligation (that is Phase 10's `_sound` consumption).
- **Tasks:**
  - [ ] State the soundness half of the gate for `bracketEndChar_kvE2` (proof-side; do NOT edit
        `BracketCarrierCorrectVPrior`). Rewrite through `bracketEndChar_kvE2_two_eq` so the goal is the
        re-pointed `kvE2_body` at the k=2 instantiation.
  - [ ] Apply `k1v_bracket_extract` (:2150) to split the carrier hypothesis into its channels (gate,
        `epL`/`epR`, zones, arrangements, `ptW`, `segL`/`segR`, `exclAt`) and the per-sub joint slot,
        as the landed `bracketEndChar_k1v_sound` (:2338) template does one arity down. Surface the
        obligations as named `have`/`obtain` goals (left open for Phase 10).
  - [ ] Confirm the joint slot now exposes a `(kvE_subBracket2V …).holds` hypothesis (the shape
        `kvE_subBracket2V_sound` consumes), not the old `kvE_subChain` shape.
  - [ ] Cite Rabinovich at each structural step (G5); no `simp`/`omega`/`aesop` in any body.
- **Timing:** ~1.5 hours. **Depends on:** 8.
- **Files:** `NfMultiAnchorBridge.lean` — append the soundness-direction entry + extraction scaffolding.
- **Verification:** Scoped build green with the obligations exposed as explicit open goals (a
  `sorry`-free skeleton is NOT permitted on a live path — keep intermediate goals inside an uncommitted
  WIP and commit only the green prefix; do NOT land a `sorry`). Axiom-clean on anything committed. The
  reduction through `two_eq` type-checks; the joint slot exposes the `kvE_subBracket2V` holds shape.

### Phase 10: Stage C — per-sub soundness via kvE_subBracket2V_sound (hgate discharge) + non-joint channels + assembly [NOT STARTED] (Stage C)

- **Goal:** Close the per-sub positive obligation (the F4 crux) by **consuming**
  `kvE_subBracket2V_sound` (:7514), discharging its explicit `hgate` from the outer gate channels;
  discharge the retained non-joint per-channel obligations by reusing the landed k1v closers; assemble
  the full soundness direction.
- **Tasks:**
  - [ ] Feed the joint-slot `(kvE_subBracket2V …).holds` hypothesis into `kvE_subBracket2V_sound` to
        obtain `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` — NO provider `e`, NO `w = e 1`/`x = e 2`
        residual (Amendment F3).
  - [ ] **Discharge `hgate`** (the `∀ a, x<a<t, charK-real a ⇒ anchor placement + `nf_eval_nf`
        reconstruction + off-fiber + zone folds`) from the outer `kvE2_body` gate channels: `kvE_gate`
        supplies `a∈(x,t)`; the point-coincidence/exterior/zone channels supply the fold reconstruction
        and off-fiber (per the Research-Integration threading table). Land any intermediate mapping
        lemma phase-per-lemma if the direct hand-off does not close.
  - [ ] Discharge the non-joint channels (gate, unary `epL`/`epR`, zones, arrangements `pinSlots`,
        `ptW`, `segL`/`segR`, channel-(ii) `exclAt`) by reusing the landed k1v soundness lemmas /
        `kvE_pinDisjunct`/`kvE_exclConj` reasoning (same-module access). Confirm no `P.existF 3 σ`
        rebinding literal on any discharged channel.
  - [ ] Assemble the discharged channels + the closed per-sub crux into the full soundness statement
        for `bracketEndChar_kvE2`; close it (no `sorry`).
  - [ ] Cite Rabinovich Cor 5.4 / Prop 3.5 at each chain step (G5); `by omega` only for `Fin`-index
        typing.
- **Sub-split valve:** if the `hgate` discharge exceeds the dispatch budget, split at the
  `hgate`-assembly boundary: 10a = `_sound` consumption + `hgate` discharge (commit green); 10b =
  non-joint channels + soundness assembly.
- **Timing:** ~2 hours. **Depends on:** 9.
- **Files:** `NfMultiAnchorBridge.lean` — append the per-sub `_sound` consumption + `hgate` discharge +
  non-joint closers + soundness assembly.
- **Verification:** Scoped build green; the soundness direction closes with NO residual `e`-equation;
  axiom-clean; no `sorry` on any live path. If a residual `e`-equation reappears, the joint literal was
  not fully consumed — return to Phase 8/9, do NOT introduce a pinning device (Amendment F3).

### Phase 11: Stage D — inner-witness fold extraction + order-bit / hcharK preparation [NOT STARTED] (Stage D — novel, highest risk)

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

### Phase 12: Stage D — arrangement disjunct via kvE_subBracket2V_complete consumption [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Discharge the joint slot of the outer completeness direction by **consuming**
  `kvE_subBracket2V_complete` (:7783), feeding the Phase-11 order bits + `hcharK` + the honest
  realization to obtain `(kvE_subBracket2V …).holds M atomMap x t`.
- **Tasks:**
  - [ ] Apply `kvE_subBracket2V_complete` with the three order bits (11), `hcharK` (11), and the honest
        `∃ x1, nf_eval_nf M 1 4 …` witness to produce the joint-slot `.holds` needed by the outer
        arrangement disjunct.
  - [ ] Wire the resulting `.holds` into the outer completeness arrangement as the landed :2966/:2979
        `bracketEndChar_k1v_complete` template does one arity down (the joint slot now supplied by the
        325 carrier rather than a hand-built disjunct).
  - [ ] **Non-vacuity check (binding):** confirm (via `kvE_subBracket2V_nonvacuous`) the disjunct set is
        non-empty at the honest σ before the arrangement selection is attempted.
  - [ ] Cite Rabinovich at each chain step (G5); `by omega` only for `Fin`-index typing.
- **Timing:** ~2 hours. **Depends on:** 11.
- **Files:** `NfMultiAnchorBridge.lean` — append the `_complete` consumption + arrangement wiring.
- **Verification:** Scoped build green; `kvE_subBracket2V_complete` consumed with all hypotheses
  discharged; the arrangement disjunct type-checks; non-vacuity confirmed; axiom-clean; no `sorry`.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine obstruction ⇒ record
  F-house-style, keep green, STOP; no absorb/shortcut/`sorry`.

### Phase 13: Stage D — non-joint completeness channels + completeness assembly [NOT STARTED] (Stage D — novel, highest risk)

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

### Phase 14: Stage D — gate close to GO (both directions) [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Assemble the soundness (Phase 10) + completeness (Phase 13) directions into a proven **GO**
  of the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` over the new carrier.
- **Tasks:**
  - [ ] Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` — both directions
        closed, provider-independent (only `P.correct` consumed); no provider-side pinning; no
        `EANegation :1090/:1249`; no structural-identity / `nf_eval_unique` premise (route b2 NOT
        NEEDED).
  - [ ] Confirm the gate result reuses the landed 325 pair unchanged where the template applies and the
        non-vacuity gate is consumed on both directions; cite Rabinovich at each chain step (G5).
- **Timing:** ~1 hour. **Depends on:** 13.
- **Files:** `NfMultiAnchorBridge.lean` — append the completeness assembly's tail + the GO gate result.
- **Verification:** Scoped build green; the k=2 GO gate theorem type-checks (both directions closed);
  axiom-clean; no `sorry` on any live path.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine gate-close obstruction ⇒
  record F-house-style, keep green (Stages A-C + Phases 11-13 remain landed), STOP.

### Phase 15: F4 ℤ semantic LHS-FALSE + integrity sweep + GO/NO-GO verdict record [NOT STARTED] (Final)

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
        gate closed both directions; F4 discriminated (construction- and semantic-level); citations per
        G5. The F1-F4 prior records stay byte-identical.
  - [ ] Verify byte-identity: `git diff` on `NfMultiAnchorBridge.lean` shows a pure additive delta after
        the landed blocks EXCEPT the three authorized 321-owned re-points
        (`kvE2_body`/`bracketEndChar_kvE2`/`two_eq`); every forbidden-list do-not-edit asset (including
        the task-325 VVecEA2 block, task-324 kit, and `BracketCarrierCorrectVPrior`) unchanged; no other
        landed file touched.
  - [ ] Confirm no `simp`/`omega`/`aesop` in any chain-construction body (only `by omega` for
        `Fin`-index/length typing, matching landed `bracketFromLists` :1900 / task-325 kit).
  - [ ] Run full `lake build`; confirm green, no new `sorry` on any live path, new defs/theorems
        axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) via `lean_verify`.
- **Timing:** ~1.5 hours. **Depends on:** 14.
- **Files:** `NfMultiAnchorBridge.lean` — append the F4 `ℤ` LHS-FALSE lemma + the final verdict record.
- **Verification:** Full `lake build` green; F4 counterexample lemma proves LHS FALSE under the
  re-pointed `bracketEndChar_kvE2`; `git diff` additive-only (+ the three authorized re-points);
  `lean_verify` axiom-clean on all new symbols; forbidden-list assets byte-identical; a GO/NO-GO
  verdict record landed.

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 15.
- [ ] Phase 8: `bracketEndChar_kvE2` characterizes `kvE_subBracket2V` on the joint path; `two_eq`
      closes; `kvE_subBracket2V_nonvacuous` consumed (non-vacuity gate passed) BEFORE any correctness
      direction.
- [ ] Stage C soundness (Phases 9-10): the soundness direction of the k=2 gate closes with NO residual
      `w = e 1`/`x = e 2` (no provider `e` on the joint path) via `kvE_subBracket2V_sound`, with `hgate`
      discharged from the outer gate channels.
- [ ] Stage D completeness (Phases 11-14): `kvE_subBracket2V_complete`'s order bits + `hcharK` are
      discharged at the integration site; the arrangement disjunct consumes the `_complete` output; the
      k=2 `BracketCarrierCorrectVPrior` gate closes to a proven GO (both directions).
- [ ] MANDATORY adversarial test (Phase 15): F4 `ℤ` counterexample (`char[14,16,11,20]` vs honest
      `char[14,15,10,20]`) FAILS against the re-pointed carrier (LHS FALSE at `(10,20)`).
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on any
      live path (no `sorry`-skeleton committed at any phase boundary).
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Guards G1-G6 + Corrected Anchor-Cap honored; anchor set fixed at 2; no third-anchor tower; the
      completeness witnesses are bracket WITNESSES between the fixed endpoints (`x1`/`w` self-zones are
      zone-spec values, not anchors — 325 Guard G4).
- [ ] EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3).
- [ ] Every forbidden-list do-not-edit asset byte-identical (task-325 VVecEA2 block, task-324 kit,
      `BracketCarrierCorrectVPrior`, all F1-F4 records); only the three 321-owned re-points
      (`kvE2_body`/`bracketEndChar_kvE2`/`two_eq`) are edited, all other new work additive.

## Artifacts & Outputs

- `specs/321_.../plans/04_corrected-k2-carrier-gate-v4.md` (this plan; supersedes v3).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — the authorized re-point of
  `kvE2_body`/`bracketEndChar_kvE2`/`two_eq` at `kvE_subChain2V`/`kvE_subBracket2V` (Phase 8); the
  additive soundness-direction scaffolding + per-channel closers + per-sub `_sound` consumption + `hgate`
  discharge + soundness assembly (Phases 9-10); the completeness fold-extraction + order-bit/`hcharK`
  prep + arrangement disjunct via `_complete` + non-joint channels + gate-close to GO (Phases 11-14);
  the F4 `ℤ` LHS-FALSE lemma + final GO/NO-GO verdict record (Phase 15). All on top of the already-landed
  Stage A/B block and the consumed task-325 VVecEA2 pair; forbidden-list do-not-edit assets
  byte-identical.
- `specs/321_.../summaries/04_corrected-k2-carrier-gate-v4-summary.md` (at implementation completion).

## Rollback/Contingency

- Phase 8's re-point of the three 321-owned defs is revertible via `git checkout` of the single file to
  the Stage-A/B-complete HEAD (snapshot via `git-snapshot.sh` first if the tree is dirty). All later
  Stage C/D work is additive proof-side; to revert, delete the appended definitions/theorems/verdict
  update — every forbidden-list do-not-edit asset (including the task-325 pair) is untouched.
- If the Phase-8 `two_eq` `rfl` fails: the joint-splice re-point drifted the body shape — fire the 8b
  sub-split valve and adjust the depth threading against the k1v `two_eq` (:5972) template; do NOT edit
  the landed carrier signature `BracketEndCharCarrierV sig 2` or any forbidden-list asset.
- If soundness's `hgate` discharge (Phase 10) exceeds budget: fire the 10a/10b sub-split valve; commit
  the `_sound`-consumption green prefix and continue non-joint channels + assembly next dispatch.
- If the soundness crux reappears as an `e`-residual (Phase 10): the joint literal was not fully
  consumed — return to Phase 8/9, do NOT introduce a pinning device (Amendment F3).
- If a Stage-D phase (11-14) hits a *genuine machine-grounded obstruction*: fire that phase's Escalation
  bullet — record it F-house-style (exact goal, why not effort), keep all green work committed, and STOP
  for orchestrator re-dispatch or `/revise`. Do NOT absorb, shortcut, or `sorry`.
- If the F4 counterexample fails to discriminate semantically (Phase 15): the completeness wiring lost
  the `σ.2` dependence — return to Stage D; do not weaken the adversarial test.
- If any step appears to require a two-anchor single-point assertion: design smell (Gabbay
  cross-check) — escalate to the orchestrator blocker ladder, do not engineer around it. Land a verdict
  record either way (GO, NO-GO, or a defect record), per F1-F4 house style; no partial theorem, no
  `sorry`.
