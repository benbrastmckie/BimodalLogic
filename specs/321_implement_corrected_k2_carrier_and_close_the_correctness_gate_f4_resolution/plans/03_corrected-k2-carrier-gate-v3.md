# Implementation Plan (v3): Corrected k=2 Carrier — Close the k=2 Correctness Gate (Stages C/D decomposed)

- **Task**: 321 - implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution
- **Status**: [NOT STARTED]
- **Effort**: ~31 hours total (Stages A+B + integrity ≈ 13.5h COMPLETED; ~17.5h remaining across Stages C/D + final verdict)
- **Dependencies**: 320 (GO verdict on route b3, design spec §5 — COMPLETED)
- **Research Inputs**:
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md (blocker resolution: successor-parameterization, forced encoding, staged gate — Section 3 is the drop-in amended design spec)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/02_jointpinning-probe-results.md (design spec §5, route b3 GO)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (binding framing caveat)
  - specs/309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md (F4 blocker origin)
- **Artifacts**: plans/03_corrected-k2-carrier-gate-v3.md (this file; supersedes plans/02_corrected-k2-carrier-fi-chain-v2.md)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

This is **v3**, superseding v2 (`plans/02_corrected-k2-carrier-fi-chain-v2.md`). v2 executed its full
Stage A (the corrected k=2 carrier construction) and Stage B (construction-level F4 discrimination) to
**GREEN, committed, additive `+394/−0`, all landed assets byte-identical, full `lake build` green
(1709 jobs), axiom-clean, no `sorry`**. What v2 did NOT close was the k=2
`BracketCarrierCorrectVPrior` correctness gate for `bracketEndChar_kvE2` (Stages C soundness + D
completeness) plus the `M=ℤ` semantic LHS-FALSE tail — v2 had sized that remainder as a single "prove
the gate" pair of phases, which hit the pre-authorized sizing boundary (the landed k1v simple gate it
mirrors spans ~800 lines, `:2150-3405`, and the completeness direction has no k≥2 precedent). v2 fired
its pre-authorized fallback and recorded a PARTIAL-GO.

**The purpose of v3 is narrow and structural**: decompose exactly that BLOCKED remainder (Stages C and
D) into single-dispatch-sized phases (~100-500 lines of output each) so implementation resumes **within
task 321** — no spawn to a separate task. The completed Stage A/B/integrity work is carried forward
verbatim as `[COMPLETED]` and is never re-run or re-derived. All binding constraints (Guards G1-G6 +
Corrected Anchor-Cap, Amendment F3, do-not-edit byte-identity, consume-do-not-rebuild, no EANegation
`:1090/:1249`, no `simp`/`omega`/`aesop` on chain steps, Rabinovich citations per G5, no `sorry` on
live paths, verdict record either way, full green build) are carried unchanged.

The technical basis for the decomposition is the just-finished implementer's continuation roadmap
(recorded in `.orchestrator-handoff.json`), which is itself the concrete instantiation of report
`01_blocker-research-successor-k.md` §2/Q3 (staged gate) applied to the now-landed assets:

- **Stage C (soundness)**: drive `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 …)`
  soundness via `bracketEndChar_kvE2_two_eq` + `k1v_bracket_extract` (:2150) + the `:2338` soundness
  direction template, closing the per-sub positive crux with the already-landed, `e`-free
  `kvE_subBracket_implies_subChain`.
- **Stage D (completeness)**: fold `nf_eval_depth1_fold_iff` (:5187) at `n=4` to extract σ's inner
  witnesses, construct the sub-bracket `IntervalPattern.holds` data (Lemma 5.3 order-theoretic), then
  the arrangement disjunct (:2979 template), then close the gate to GO. Finally instantiate the F4 `ℤ`
  counterexample for the semantic LHS-FALSE.

Definition of done (unchanged from v2): the k=2 correctness gate for `bracketEndChar_kvE2` passes to a
recorded **GO** verdict (both directions closed); the F4 `ℤ` counterexample is discriminated (LHS FALSE
at `(10,20)` under the new carrier); green `lake build`; axiom-clean (`propext`, `Classical.choice`,
`Quot.sound`); no `sorry` on any live path; every do-not-edit landed asset byte-identical; a verdict
record landed. If a Stage-D phase hits a *genuine machine-grounded obstruction* (not mere effort), the
per-phase escalation rule fires (record F-house-style, keep green work committed, stop) — see each
Stage-D phase's Escalation bullet.

### Research Integration

v3 integrates **no new research report** — it is a structural re-decomposition (`revision_reason:
blocker`) of v2's BLOCKED Stages C/D into single-dispatch-sized phases. The `reports_integrated` set is
unchanged from v2: `01_blocker-research-successor-k.md` remains the binding amended design spec (its
§2/Q3 staged-gate structure is what v3 realizes at phase granularity), on top of the task-320 §5 design
spec (`02_jointpinning-probe-results.md`) and the framing caveat (`01_literature-alignment.md`). The
concrete phase-level decomposition is driven by the just-finished implementer's
`.orchestrator-handoff.json` continuation roadmap (the machine-grounded continuation context), which
maps each remaining gate obligation onto a landed k1v template line and a landed reusable asset:

- Stage C soundness ← `k1v_bracket_extract` (:2150) + `bracketEndChar_k1v_sound` template (:2338) +
  `kvE_subBracket_implies_subChain` (landed, `e`-free crux closer).
- Stage D completeness ← `nf_eval_depth1_fold_iff` (:5187) fold extraction + `IntervalPattern.holds`
  (Lemma 5.3) + `bracketEndChar_k1v_complete` arrangement template (:2979) + `k1v` gate-assembly
  (:3391).

Carried forward from v2's research integration (unchanged): route b1 NO-GO (`rfl`), Cor 5.4 chain-shape
MATCH, route b3 GO (`bracket_implies_fChainPred` recovers positions `e`-free), route b2 NOT NEEDED. And
the successor-parameterization resolution of the three v1 blockers (report Q1/Q2/Q3) is now a landed
fact, not a plan assumption.

### Prior Plan Reference

v2 (`plans/02_corrected-k2-carrier-fi-chain-v2.md`) is **[SUPERSEDED]** by this v3 and marked as such in
its header. v2's Phases 1-6 (Stage A) and Phase 7 construction-level part (Stage B) + Phase 11
(integrity sweep) are `[COMPLETED]`, landed, and committed; they are carried forward verbatim below and
are never re-executed. v2's Phases 8-10 (Stages C/D gate) were `[BLOCKED]` under a too-coarse "prove the
gate" sizing; v3 replaces those three coarse phases with a fine decomposition (Stage C → 3 phases,
Stage D → 4 phases) plus a dedicated final verdict phase. The lineage context (v6→v7 re-pointing
pattern, F1-F4 house style, parent task 309) remains binding.

### Roadmap Alignment

No ROADMAP.md consulted (not provided in delegation context). Goal-state alignment for the enclosing
chain: this task's GO gate is the prerequisite for task 309's Phase 13.4 (general-k one-step
correctness) and Phase 14 (hook rewire discharging `KampPrior.lean:351`'s strategic `sorry`, target
axioms exactly `[propext, Classical.choice, Quot.sound]`). After a GO here, task 309 resumes via
`/implement 309` (possibly preceded by `/revise 309` for a v8 re-pointing to the new deliverable
names). Because v3 keeps the gate **in-task**, no separate completeness task is created; the gate GO is
delivered by task 321 itself.

## Goals & Non-Goals

**Goals**:
- Close the k=2 `BracketCarrierCorrectVPrior` gate for the landed `bracketEndChar_kvE2` to a proven
  **GO** (both directions), by decomposing Stage C (soundness, 3 phases) and Stage D (completeness, 4
  phases) into single-dispatch-sized, phase-per-lemma, commit-per-green units — resuming at Stage C.
- Stage C reuses the landed `kvE_subBracket_implies_subChain` (`e`-free crux closer),
  `k1v_bracket_extract` (:2150), and the `:2338` soundness template.
- Stage D builds the novel completeness direction: fold-extraction of inner witnesses
  (`nf_eval_depth1_fold_iff` :5187), `IntervalPattern.holds` data construction (Lemma 5.3), the
  arrangement disjunct (:2979 template), and the gate close.
- Discharge the F4 `ℤ` semantic LHS-FALSE at `(10,20)` against `bracketEndChar_kvE2`, then run the
  integrity sweep and land a GO/NO-GO verdict record.
- Preserve every do-not-edit landed asset byte-identical; keep all new work additive.

**Non-Goals**:
- No re-execution, re-derivation, or edit of the completed Stage A/B assets (`kvE_subFoldBits`,
  `kvE_subInteriorZones`, `kvE_subBracket`, `kvE_subChain` + `kvE_subBracket_implies_subChain`,
  `kvE2_body` + gate-fail, `bracketEndChar_kvE2` + `two_eq`, the Stage-B discrimination lemmas). They
  are landed and byte-identical; treat them as consumed.
- No spawn of the completeness direction to a separate task — v3 keeps the gate in task 321.
- No third FLAT carrier variant (`kvE''`-style per-sub literal at `t`) — the F3/F4-refuted shape, OUT
  OF SCOPE.
- No provider-side pinning (Amendment F3 binding); the provider *disappears* from the joint path.
- No consumption of `EANegation :1090/:1249`.
- No structural-identity / `nf_eval_unique` / `nfPred_correct` hypothesis on the gate (route b2 NOT
  NEEDED).
- No edits to any landed asset (`bracketEndChar_kv`/`kvE_body`/`bracketEndChar_kvE`,
  `bracketEndChar_kvE'`/`kvE'_body`/`kvE_pinDisjunct`/`kvE_exclConj`, F1-F4 verdict records,
  `ExistProviders`/`BracketCarrierCorrectVPrior`, all task-310/311 material, the task-320 probes, and
  the now-landed Stage A/B code). Task 321's own PARTIAL-GO verdict record is updated to the final
  GO/NO-GO record in the final phase — that is task 321's own output, not a do-not-edit asset.
- No general-k work (task 309 Phase 13.4/14) — out of scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stage D completeness (honest realization ⇒ sub-bracket holds) stalls — genuinely novel, no k≥2 precedent; `IntervalPattern.holds` witness construction from `nf_eval_nf` is order-theoretic (Lemma 5.3 style) | H | M | Decomposed into 4 phases (fold-extraction → `IntervalPattern.holds` data → arrangement disjunct → gate close), phase-per-lemma, commit-per-green. **Per-phase escalation**: on a *genuine machine-grounded obstruction*, record it F-house-style (exact goal, why not effort), keep green work committed, stop — do NOT absorb or shortcut. |
| A gate phase re-inflates past one dispatch (~500-line output) | M | M | Each phase is bounded to one agent run and to a single named obligation cluster (extraction reuse, per-channel, per-sub crux+assembly for C; extraction, holds-data, disjunct, close for D). If a phase's output would exceed the budget, split at the next lemma boundary and commit the green prefix. |
| Per-sub positive soundness crux reappears as an `e`-residual (Stage C) | H | L | The crux is machine-probed closed and LANDED (`kvE_subBracket_implies_subChain`, probe 6, sole hypothesis `bf.holds`, no `e`). If a residual `e`-equation reappears, the joint literal was not fully consumed — return to the soundness scaffolding phase, NOT a new pinning device (Amendment F3). |
| Forbidden tactics (`simp`/`omega`/`aesop`) creeping into chain-construction bodies | M | M | G5: cite Rabinovich at every chain step; `by omega` permitted ONLY for `Fin`-index typing obligations in signatures (identical to landed `fChainFrom_step`), never in a chain-construction body. |
| `IntervalPattern.holds` data does not match `kvE_subBracket`'s Phase-3 slot discipline | H | M | Phase 12 explicitly checks the constructed holds-data against the landed `kvE_subBracket` zone routing (`kvE_subInteriorZones`, `posSlots`/`segExcl`) before the Phase 13 arrangement disjunct consumes it; a mismatch is a Phase 11/12 return, not a Phase 13 workaround. |
| F4 counterexample does not discriminate at the semantic level (LHS still holds) | H | L | Construction-level discrimination is already LANDED (`kvE_subBracket_witnessCount` `rfl`; σ'' true in `(14,16)∋15`, honest `(14,15)=∅`). The final phase evaluates on `M=ℤ`; if LHS still holds, the gate's completeness wiring lost the `σ.2` dependence — return to Stage D, do NOT weaken the test. |
| Accidental edit / byte drift of a do-not-edit landed asset (now including the Stage A/B code) | H | L | All Stage C/D work is proof-side and additive after the landed Stage A/B block; verify byte-identity via `git diff` (expect additive) in the final phase; `BracketCarrierCorrectVPrior` is consumed, not rebuilt. |
| Anchor growth / third-anchor tower slips in via the completeness witnesses (G2/G4/G6) | H | L | Anchor set fixed at 2 `{x,t}`; the `IntervalPattern.holds` witnesses are bracket WITNESSES between the fixed endpoints (the `Σ m, BracketFormula (m+1)` shape), never a third anchor. Verify in the final phase. |

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
| 7 | 7 | 6 | B (adversarial check, construction-level COMPLETED) |
| 8 | 8 | 7 | C (soundness — resume here) |
| 9 | 9 | 8 | C |
| 10 | 10 | 9 | C |
| 11 | 11 | 10 | D (completeness) |
| 12 | 12 | 11 | D |
| 13 | 13 | 12 | D |
| 14 | 14 | 13 | D |
| 15 | 15 | 14 | Final (ℤ LHS-FALSE + integrity + GO/NO-GO verdict) |

This construction is inherently sequential (each gate layer builds on the previous), so each wave holds
one phase. **Implementation resumes at Phase 8** (Stage C); Phases 1-7 are landed and carried forward.

---

### Phase 1: Baseline capture and landed-asset integrity snapshot [COMPLETED]

- **Goal:** Establish a green baseline, record the F4 counterexample state, and snapshot every
  do-not-edit landed asset so byte-identity can be verified at the end.
- **Outcome (landed):** Scoped `lake build` green (~1005 jobs); task-320 probe section present and
  axiom-clean (`probe_P1`/`probe_P3`/`probe_P4` at :5634-5698); do-not-edit asset byte ranges recorded;
  F4 crux goal + `ℤ` counterexample recaptured (:5584-5595); CONSUME-DO-NOT-REBUILD asset list
  confirmed available; `git diff` clean at phase start.
- **Depends on:** none. **Files:** `NfMultiAnchorBridge.lean` (read-only this phase).

### Phase 2: Successor-parameterized σ.2 read and sub-fold-bit decoding [COMPLETED] (Stage A)

- **Goal:** Land the successor-depth `σ.2` read and the sub-level fold-bit decoder (the realizable,
  forced foundation from the blocker research), replacing v1's unrealizable general-`k` layer.
- **Outcome (landed):** `kvE_subFoldBits` (successor `σ.2` read for `σ : NormalForm sig (j+1) 4`) +
  `kvE_subFoldBits_eq_destructors` (`rfl`); the gate-instance decoder `fun zs χ => σ.2 (nf0_assemble
  zs χ σ.1)` via `nf_eval_depth1_fold_iff` (:5187) at `n=4` over `(ZoneSpec 4 × NormalForm sig 0 1)`
  (`nf0_assemble`, NfEFold.lean:180); scoped build green; no forbidden tactics. General-`j` engine lift
  left as documented non-blocking follow-on; the concrete `M=ℤ` bit evaluation deferred to the F4
  adversarial phase.
- **Depends on:** 1. **Files:** `NfMultiAnchorBridge.lean` (append, after the task-320 probe section).

### Phase 3: Construct kvE_subBracket (nested sub-bracket over σ.2, forced k1v routing) [COMPLETED] (Stage A)

- **Goal:** Build `kvE_subBracket … (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m+1)` encoding σ's
  inner-witness structure as bracket witnesses between the honest anchor pair, read from `σ.2` via the
  forced `bracketEndChar_k1v` (:1940) zone-bit routing one arity up — the Cor 5.4 recursive construction
  generalized one level, never a third anchor.
- **Outcome (landed):** `kvE_subBracket` type-checks as `Σ m, BracketFormula (m+1)` (matches probe 5),
  axiom-clean; `kvE_subInteriorZones = [zXU, zUW, zWT]` (the arity-4 refinement of k1v's interior
  zones); `posSlots`/`segExcl` route the `σ.2` bits (interior-positive → witness slots `⟨charBase χ⟩`;
  interior-negative → `(charBase χ).neg` exclusion conjuncts). Point-coincidence/exterior zones remain
  at the outer `kvE2_body` level (`epL`/`epR`/`ptW`), so the sub-bracket carries only the
  interior-positive JOINT content — the exact F4 gap — keeping the `(m+1)` `fChainPred` shape. Rabinovich
  Def 3.1 (md:61-74), Lemma 5.1 (md:134-135) cited. G1-G6 verified (no arity-1 collapse, no third
  anchor, real exclusion segments, witnesses grow only). No flat `charK (nfk_projFresh σ)` joint literal
  on the joint path.
- **Depends on:** 2. **Files:** `NfMultiAnchorBridge.lean` (append `kvE_subBracket`).

### Phase 4: Define kvE_subChain and its position-recovery lemma [COMPLETED] (Stage A)

- **Goal:** Wrap the sub-bracket's Cor 5.4 F_i-chain predicate as `kvE_subChain` and land the
  position-recovery lemma at the CONSTRUCTED sub-bracket (probe 6), carrying σ's joint content by
  nested-Until evaluation point.
- **Outcome (landed):** `kvE_subChain … (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvE_subBracket charBase charK σ).2.fChainPred`; `kvE_subBracket_implies_subChain` instantiates the
  landed `BracketFormula.bracket_implies_fChainPred` (EANegation:660) at the constructed `bf :=
  (kvE_subBracket … σ).2` — **sole hypothesis `bf.holds`, no provider env `e`, no residual `w = e 1`/`x
  = e 2`** (probe P4 shape), axiom-clean via `lean_verify`. Rabinovich Cor 5.4 (md:154-157) / Prop 3.5
  cited; step shape matches `probe_P3_cor54_step_shape`. **This is the landed Stage-C crux closer.**
- **Depends on:** 3. **Files:** `NfMultiAnchorBridge.lean` (append `kvE_subChain` + recovery lemma).

### Phase 5: Assemble kvE2_body (corrected enriched body, successor-parameterized) [COMPLETED] (Stage A)

- **Goal:** Build `kvE2_body` = `kvE'_body` with the flattened per-sub joint literal replaced by the
  sub-bracket slot splice (`kvE_subChain σ` at σ's honest bracket position); retain all non-joint 13.2
  channels verbatim.
- **Outcome (landed):** `kvE2_body (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1
  1 → Formula) (r : NormalForm sig 0 3) (q : NormalForm sig 1 4 → Bool) : VVecEA2` (the CONCRETE gate
  instance — the general-`j` fold engine is deferred follow-on, so no `two_eq` depth bridge is needed).
  The flat `ptSub σ = ⟨charK (nfk_projFresh σ)⟩` / `t`-anchored `pos.map exF` joint literal is replaced
  by the `kvE_subChain σ` splice; `exF`/`P.existF 3` drops from the joint path entirely, `P.existF 0`
  retained. All non-joint channels retained verbatim at the `k=1` sub depth (gate, unary `epL`/`epR`,
  zones, arrangements `pinSlots`, `ptW`, `segL`/`segR`, channel-(ii) `exclAt`;
  `kvE_pinDisjunct`/`kvE_exclConj` still referenced). `kvE2_body_gate_fail` mirror landed. No `P.existF
  3 σ` / flat joint literal on the joint path; no forbidden tactics.
- **Depends on:** 4. **Files:** `NfMultiAnchorBridge.lean` (append `kvE2_body` + `kvE2_body_gate_fail`).

### Phase 6: Define bracketEndChar_kvE2 carrier and two_eq bridge [COMPLETED] (Stage A)

- **Goal:** Land the corrected carrier `bracketEndChar_kvE2` additively plus its definitional `two_eq`
  bridge to the landed gate signature.
- **Outcome (landed):** `bracketEndChar_kvE2 (P : ExistProviders sig atomMap 1) :
  BracketEndCharCarrierV sig 2` (the concrete landed k=2 gate signature — exact hypotheses of
  `bracketEndChar_kvE'_two_eq`), delegating to `kvE2_body` with `charBase = nf_depth0_char_formula`,
  `charK = P.existF 0`, joint channel carried by `kvE_subChain` (no `exF` on the joint path),
  axiom-clean. `bracketEndChar_kvE2_two_eq` (mirror of :5523) closes by pure `rfl`, confirming the depth
  threading; `bracketEndChar_kvE'` and its `two_eq` byte-identical.
- **Depends on:** 5. **Files:** `NfMultiAnchorBridge.lean` (append `bracketEndChar_kvE2` + `two_eq`).

### Phase 7: F4 construction-level discrimination [COMPLETED] (Stage B); ℤ semantic tail deferred to Phase 15

- **Goal:** Machine-verify at the CONSTRUCTION level that the corrected carrier separates the F4 pair
  (the mandatory adversarial test's discrimination mechanism), front-loaded before the gate.
- **Outcome (landed):** `kvE_subBracket_witnessCount` (`rfl`, showing the witness count is a function of
  `σ.2` — the positive analog of probe P1's collapse) + `kvE_subBracket_ne_of_witnessCount_ne`
  (discrimination corollary); axiom-clean. The honest and dishonest subs produce DIFFERENT witness-slot
  lists because `kvE_subChain`/`kvE_subBracket` read `σ.2` (where they differ), not the shared `σ.1`
  `nfk_projFresh`. These are the landed, spawn-independent discrimination record.
- **Deferred to Phase 15:** the full `M=ℤ` SEMANTIC LHS-FALSE at `(10,20)` — it needs the corrected
  carrier's `ℤ` evaluation semantics (the same `BracketCarrierCorrectVPrior` machinery as Stages C/D),
  so it is now correctly placed AFTER the gate close rather than as a separable pre-gate step.
- **Depends on:** 6. **Files:** `NfMultiAnchorBridge.lean` (append the two discrimination lemmas).

---

### Phase 8: Stage C soundness scaffolding — gate entry + k1v extraction reuse [BLOCKED] (Stage C)

**BLOCKER** (Phase 8, machine-grounded; task 321 resume dispatch, session `sess_1783424133_5a7ad0_321`):

- **What failed**: The per-sub soundness crux (Phase 10's core) cannot be reduced to the landed
  assets as the plan premises. The soundness direction of `BracketCarrierCorrectVPrior …
  bracketEndChar_kvE2` reduces (via `bracketEndChar_kvE2_two_eq` + outer `k1v_bracket_extract`) to a
  per-positive-`σ` obligation `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`, where the only
  resource for `σ` is the outer witness slot carrying `ptSub σ = kvE_subChain σ`, i.e. the sub-chain
  predicate holding **at a single point** `u`. Machine-driving this obligation through the FORCED
  `nf_eval_depth1_fold_iff` decomposition (the plan's own Stage-D engine, applied here in reverse)
  produces three sub-goals, none closable from `kvE_subChain σ @ u`:
  - `refine_1`: `∀ a : AtomKind sig 4, atom_eval M (Fin.cons u [w,x,t]) a ↔ σ.1 a = true` — σ's FULL
    atom layer (order bits among all four positions `[u,w,x,t]` **and** pred bits at each). `hchain`
    carries none of σ.1's atom-layer content (the sub-bracket reads `σ.2` only, via
    `kvE_subFoldBits σ zs χ = σ.2 (nf0_assemble zs χ σ.1)`; its point types are `charBase χ` /
    `charK (nfk_projFresh σ)`).
  - `refine_2.mpr`: `σ.2 (nf0_assemble zs χ σ.1) = true → ∃ v, zoneHolds M (Fin.cons u [w,x,t]) zs v
    ∧ nf_eval_nf M 0 1 (fun _ => v) χ` for an **arbitrary** `zs : ZoneSpec 4`. `kvE_subChain σ =
    (kvE_subBracket σ).2.fChainPred` is an Until-based (`fChainFrom_base`/`_step`, EANegation:580/616)
    strictly-**upward** chain from the base witness `u`. σ's interior zone `zXU = (x < v < u)`
    (`kvE_subInteriorZones`, :5757) lies **below** `u` and is unreachable by any upward chain from
    `u`; the chain witnesses are not placed in σ's `[u,w,x,t]` zones at all. So the ⟸ direction of
    σ's interior fold cannot be reconstructed for `zXU`-positive σ (nor, absent σ's placement,
    generally).
  - `refine_3`: `∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false` (off-fiber) — requires the outer
    `kvE_gate`, not present in the isolated crux.
- **What was tried** (`lean_multi_attempt` at the crux, this dispatch, all machine-recorded):
  - `refine ⟨u, ?_⟩; rw [nf_eval_depth1_fold_iff]; refine ⟨?_, ?_, ?_⟩` → the three goals above.
  - `have hstep := (kvE_subBracket …).2.bracket_implies_fChainPred M atomMap; exact?` → the sole
    landed connector `kvE_subBracket_implies_subChain` (via `BracketFormula.bracket_implies_fChainPred`,
    EANegation:660) has hypothesis `bracket.holds z0 z` — the sub-bracket **holding on an interval**,
    which is NOT available in the soundness direction (there one HAS `fChainPred @ u` and NEEDS σ's
    eval; the lemma goes the other way, bracket.holds → chain-at-point). `exact?` could not close.
- **Why it's stuck (structural, not effort)**: The plan's Phase 10 premise — "the per-sub positive
  crux closes via the LANDED `kvE_subBracket_implies_subChain`, `e`-free" — does not hold. That lemma
  is a single building block in the WRONG direction for soundness; it yields `fChainPred`-recovery
  from a bracket-holds hypothesis, not the `nf_eval_nf M 1 4` reconstruction the crux needs.
  Reconstructing σ's full depth-1 arity-4 evaluation from the sub-chain requires substantial NEW
  arity-4 sub-bracket **correctness** machinery (both directions) — σ.1 atom-layer recovery + interior
  fold matching across all `ZoneSpec 4` zones + off-fiber via the outer gate — none of which is among
  the landed Stage-A/B assets. Worse, the `zXU`-below-`u` direction gap is a property of the LANDED
  `kvE_subBracket` construction itself (single upward chain from the σ-slot cannot reach σ's
  `zXU = (x,v,u)` interior positives), so resolving it would require **editing a do-not-edit landed
  asset** (`kvE_subBracket`), i.e. a Stage-A redesign, not a Stage-C proof-side append. This matches
  the file's own RECORDED CONTINUATION (:6062–6082, written by the Stage-A/B implementer): the k=2
  gate "is a GENUINE, well-scoped, multi-dispatch effort with no k≥2 enriched precedent, NOT
  completable within this dispatch," completeness "genuinely unprobed … plausibly multi-dispatch."
- **What is needed**: A `/revise` to a v4 that either (a) adds a Stage-A' redesign phase for
  `kvE_subBracket` so a single chain (or a Since+Until pair) reaches all three interior zones
  including `zXU` below the σ-slot, then a NEW arity-4 sub-bracket soundness+completeness pair
  (`kvE_subBracket`-correctness, ~the k1v `:2338`/`:2979` proofs re-derived at arity 4 with the
  cross-body σ.1 atom-layer channel), OR (b) re-scopes the gate close as its own spawned task with
  those sub-bracket-correctness lemmas as explicit prerequisites. The plan's assumption that Stage C
  is "extraction reuse + landed crux closer" understates the missing sub-bracket-correctness theorem.
- **Prohibited workarounds** (observed): no `sorry`, no `def X := True`/vacuous placeholder, no
  `simp`/`omega`/`aesop` shortcut of a chain step, no provider-side pinning (Amendment F3), no edit of
  any landed asset. None used; the WIP probe was removed and the file is byte-identical to the
  Stage-A/B-complete HEAD.

- **Goal:** Open the `BracketCarrierCorrectVPrior` soundness direction (carrier holds ⇒ ∃w realization)
  for `bracketEndChar_kvE2`, reduce it through `bracketEndChar_kvE2_two_eq` to the k1v-shaped body, and
  reuse the landed extraction lemma to expose the per-channel / per-sub obligation structure — WITHOUT
  yet discharging the obligations. This is the "extraction lemma reuse" unit of the k1v gate's internal
  structure.
- **Tasks:**
  - [ ] State the soundness half of the gate for `bracketEndChar_kvE2` (proof-side; do NOT edit
        `BracketCarrierCorrectVPrior`, consumed do-not-rebuild). Rewrite through
        `bracketEndChar_kvE2_two_eq` (landed `rfl` bridge) so the goal is the `kvE2_body` at the k=2
        standard instantiation — the same shape the k1v soundness template consumes.
  - [ ] Apply `k1v_bracket_extract` (:2150) to split the carrier hypothesis into its channels (gate,
        `epL`/`epR`, zones, arrangements, `ptW`, `segL`/`segR`, `exclAt`) and the per-sub joint slot,
        exactly as the landed `bracketEndChar_k1v_sound` (:2338) template does one arity down. Surface
        the resulting obligation list as named `have`/`obtain` goals (leave them open for Phases 9-10).
  - [ ] Cite Rabinovich at each structural step (G5); no `simp`/`omega`/`aesop` in any body.
- **Timing:** ~2 hours. **Depends on:** 7.
- **Files:** `NfMultiAnchorBridge.lean` — append the soundness-direction entry + extraction scaffolding
  (proof-side).
- **Verification:** Scoped build green with the obligations exposed as explicit open goals (a
  `sorry`-free skeleton is NOT permitted on a live path — if intermediate goals cannot yet close, keep
  them inside an uncommitted WIP and only commit the green prefix; do NOT land a `sorry`). Axiom-clean
  on anything committed. The reduction through `two_eq` type-checks (a depth mismatch fails here).

### Phase 9: Stage C — discharge the retained non-joint per-channel soundness obligations [NOT STARTED] (Stage C)

- **Goal:** Close every non-joint channel obligation exposed in Phase 8 by reusing the landed k1v
  per-channel closers verbatim where the template applies — the "per-channel obligations" unit. These
  channels were retained byte-for-byte-shaped from `kvE'_body`, so their soundness reuses the landed k1v
  proofs one arity down.
- **Tasks:**
  - [ ] Discharge the gate channel (`kvE_gate`), the unary `epL`/`epR` non-joint parts, the zone
        obligations, the arrangements (`pinSlots`), `ptW`, `segL`/`segR`, and channel-(ii) `exclAt` by
        reusing the corresponding landed k1v soundness lemmas / `kvE_pinDisjunct`/`kvE_exclConj`
        reasoning (same-module `private` access).
  - [ ] Confirm NO `P.existF 3 σ` rebinding literal appears on the joint path of any discharged channel
        (so the F4 residual cannot arise here); the joint content is untouched (it is Phase 10's crux).
  - [ ] Cite Rabinovich Cor 5.4 / Prop 3.5 at each chain step (G5); `by omega` only for `Fin`-index
        typing, never in a chain body.
- **Timing:** ~2 hours. **Depends on:** 8.
- **Files:** `NfMultiAnchorBridge.lean` — append the non-joint per-channel soundness closers.
- **Verification:** Scoped build green with all non-joint channel obligations closed (no `sorry`);
  axiom-clean; only the per-sub positive joint obligation remains open for Phase 10; no forbidden
  tactics; no residual `e`-equation introduced.

### Phase 10: Stage C — per-sub positive crux + soundness assembly [NOT STARTED] (Stage C)

- **Goal:** Close the per-sub positive obligation (the F4 crux — previously the unpinnable `w = e 1`, `x
  = e 2`) via the LANDED `kvE_subBracket_implies_subChain`, then assemble the full soundness direction —
  the "per-sub positive crux + assembly" unit.
- **Tasks:**
  - [ ] Feed `bf.holds` (the honest realization makes `kvE_subBracket … σ` hold on σ's honest interval)
        into the landed `kvE_subBracket_implies_subChain` (Phase 4) to recover σ's honest witness
        positions — NO provider environment `e`, NO `w = e 1`/`x = e 2` residual (probe P4 / probe 6
        shape). Confirm no `P.existF 3 σ` rebinding literal on the joint path.
  - [ ] Assemble the discharged non-joint channels (Phase 9) with the closed per-sub crux into the full
        soundness statement for `bracketEndChar_kvE2`; close it (no `sorry`).
  - [ ] Cite Rabinovich Cor 5.4 / Prop 3.5 at each chain step (G5).
- **Timing:** ~2 hours. **Depends on:** 9.
- **Files:** `NfMultiAnchorBridge.lean` — append the per-sub crux closure + soundness assembly.
- **Verification:** Scoped build green; the soundness direction of the gate for `bracketEndChar_kvE2`
  closes with NO residual `e`-equation; axiom-clean; no `sorry` on any live path. If a residual
  `e`-equation reappears, the joint literal was not fully consumed — return to Phase 8/9, do NOT
  introduce a pinning device (Amendment F3).

### Phase 11: Stage D — inner-witness fold extraction [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Begin the novel completeness direction (honest realization ⇒ carrier holds): extract σ's
  inner witnesses via the fold engine — the "witness extraction" unit. No k≥2 precedent exists.
- **Tasks:**
  - [ ] Fold `nf_eval_depth1_fold_iff` (:5187) at `n = 4` over `(ZoneSpec 4 × NormalForm sig 0 1)` to
        extract σ's inner witnesses from `nf_eval_nf` (report Q3 Stage D; the same decomposition
        `kvE_subFoldBits` was built on, now consumed in the reverse direction).
  - [ ] Land the extraction as named lemmas producing, per interior zone (`kvE_subInteriorZones` =
        `[zXU, zUW, zWT]`), the witness/no-witness data the sub-bracket slot discipline expects.
  - [ ] Cite Rabinovich at each step (G5); no forbidden tactics.
- **Timing:** ~2.5 hours. **Depends on:** 10.
- **Files:** `NfMultiAnchorBridge.lean` — append the fold-extraction lemmas (proof-side).
- **Verification:** Scoped build green after each committed lemma; the extracted witness data type-checks
  against `kvE_subInteriorZones`; axiom-clean; no `sorry` on a live path.
- **Escalation (per-phase, pre-authorized):** On a *genuine machine-grounded obstruction* (a concrete
  failing goal that is not a mere-effort/plumbing problem — e.g. the fold decomposition does not expose
  the witness at the needed zone granularity), record it F-house-style (exact goal state, the lemma
  attempted, why it is a structural obstruction and not effort), keep all green work committed, and
  STOP — hand back to the orchestrator for re-dispatch or `/revise`. Do NOT absorb the obstruction into
  a later phase, do NOT invent a flat/single-point shortcut, do NOT land a `sorry`.

### Phase 12: Stage D — IntervalPattern.holds data construction [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Construct the sub-bracket's `IntervalPattern.holds` witness data (monotone enumeration,
  range, point, segment conditions) from the Phase-11 extracted inner witnesses — the order-theoretic
  (Rabinovich Lemma 5.3, md:137-152) core — and confirm it matches the `kvE_subBracket` slot discipline.
  This is the "IntervalPattern.holds construction" unit.
- **Tasks:**
  - [ ] Build the `IntervalPattern.holds` data (monotone position enumeration, range/point/segment
        conditions) from the Phase-11 witnesses, Lemma 5.3 style; cite per G5. Phase-per-lemma,
        commit-per-green.
  - [ ] Confirm the constructed holds-data matches the Phase-3 `kvE_subBracket` slot discipline (same
        zone routing via `posSlots`/`segExcl` over `kvE_subInteriorZones`) so the Phase-13 arrangement
        disjunct can consume it directly. A mismatch is a Phase 11/12 return, not a Phase 13 workaround.
  - [ ] Cite Rabinovich Lemma 5.3 / Cor 5.4 at each step (G5); no `simp`/`omega`/`aesop` in chain
        bodies.
- **Timing:** ~2.5 hours. **Depends on:** 11.
- **Files:** `NfMultiAnchorBridge.lean` — append the `IntervalPattern.holds` construction (proof-side).
- **Verification:** Scoped build green after each committed lemma; the `IntervalPattern.holds` data
  type-checks against `kvE_subBracket`'s slot shape; no forbidden tactics; axiom-clean; no `sorry`.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — on a genuine machine-grounded
  obstruction (e.g. the monotone enumeration cannot be built from the extracted witnesses without a
  structural-identity premise route b2 forbids), record it F-house-style, keep green work committed,
  STOP. Do NOT absorb, shortcut, or `sorry`.

### Phase 13: Stage D — arrangement disjunct [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Build the arrangement disjunct from the Phase-12 `IntervalPattern.holds` data using the
  landed `bracketEndChar_k1v_complete` (:2979) template one arity up, and wire the non-joint
  completeness channels — the "arrangement disjunct" unit.
- **Tasks:**
  - [ ] Build the arrangement disjunct as in the landed :2966/:2979 completeness template, consuming the
        Phase-12 `IntervalPattern.holds` data for the joint slot.
  - [ ] Discharge the non-joint completeness channels by reusing the landed k1v completeness lemmas
        where the template applies (they mirror the retained-verbatim channels).
  - [ ] Cite Rabinovich at each chain step (G5); `by omega` only for `Fin`-index typing.
- **Timing:** ~2.5 hours. **Depends on:** 12.
- **Files:** `NfMultiAnchorBridge.lean` — append the arrangement disjunct (proof-side).
- **Verification:** Scoped build green; the arrangement disjunct type-checks and consumes the Phase-12
  holds-data; axiom-clean; no `sorry` on a live path; no forbidden tactics.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine obstruction ⇒ record
  F-house-style, keep green, STOP; no absorb/shortcut/`sorry`.

### Phase 14: Stage D — completeness assembly + gate close to GO [NOT STARTED] (Stage D — novel, highest risk)

- **Goal:** Assemble the completeness direction from Phases 11-13 and close the k=2
  `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` to a proven **GO** (both directions) —
  the "assembly" unit.
- **Tasks:**
  - [ ] Assemble the completeness direction (honest realization ⇒ carrier holds) from the fold
        extraction (11), the `IntervalPattern.holds` data (12), and the arrangement disjunct (13).
  - [ ] Close the k=2 `BracketCarrierCorrectVPrior` gate for `bracketEndChar_kvE2` — both directions
        closed, provider-independent (only `P.correct` consumed); no provider-side pinning; no
        `EANegation :1090/:1249`; no structural-identity / `nf_eval_unique` premise (route b2 NOT
        NEEDED).
  - [ ] Confirm the completeness proof reuses landed machinery unchanged where the template applies;
        cite Rabinovich at each chain step (G5).
- **Timing:** ~2.5 hours. **Depends on:** 13.
- **Files:** `NfMultiAnchorBridge.lean` — append the completeness assembly + the GO gate result.
- **Verification:** Scoped build green; the k=2 GO gate theorem type-checks (both directions closed);
  axiom-clean; no `sorry` on any live path.
- **Escalation (per-phase, pre-authorized):** Same as Phase 11 — genuine gate-close obstruction ⇒
  record F-house-style, keep green (Stages A-C + Phases 11-13 remain landed), STOP; no
  absorb/shortcut/`sorry`.

### Phase 15: F4 ℤ semantic LHS-FALSE + integrity sweep + GO/NO-GO verdict record [NOT STARTED] (Final)

- **Goal:** Discharge the deferred F4 `ℤ` semantic adversarial check against the now-closed gate, run
  the full integrity sweep, and land the final GO/NO-GO verdict record — updating task 321's own
  PARTIAL-GO record to the final verdict.
- **Tasks:**
  - [ ] Instantiate the F4 `ℤ` counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` marked false) against `bracketEndChar_kvE2`
        and prove the LHS is FALSE at `(10,20)` — the mandatory adversarial test MUST fail against the
        new carrier (discrimination via the `σ.2` read, already landed at construction level in Phase
        7). If LHS still holds, the completeness wiring lost the `σ.2` dependence — return to Stage D,
        do NOT weaken the test.
  - [ ] Update task 321's verdict record (F1-F4 house style) from PARTIAL-GO to the final **GO** (or a
        precise NO-GO/obstruction record if a Stage-D escalation fired): route b3 realized via successor
        parameterization; `kvE_subBracket`/`kvE_subChain`/`kvE2_body`/`bracketEndChar_kvE2` landed; k=2
        `BracketCarrierCorrectVPrior` gate closed both directions; F4 discriminated (construction- and
        semantic-level); citations per G5. The F1-F4 prior records stay byte-identical.
  - [ ] Verify byte-identity: `git diff` on `NfMultiAnchorBridge.lean` shows a pure additive delta after
        the landed Stage A/B block; every do-not-edit asset (including the Stage A/B code and
        `BracketCarrierCorrectVPrior`) unchanged; no other landed file touched.
  - [ ] Confirm no `simp`/`omega`/`aesop` in any chain-construction body (only `by omega` for
        `Fin`-index typing, matching landed `bracketFromLists` :1900).
  - [ ] Run full `lake build`; confirm green, no new `sorry` on any live path, new defs/theorems
        axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) via `lean_verify`.
- **Timing:** ~1.5 hours. **Depends on:** 14.
- **Files:** `NfMultiAnchorBridge.lean` — append the F4 `ℤ` LHS-FALSE lemma + the final verdict record.
- **Verification:** Full `lake build` green; F4 counterexample lemma proves LHS FALSE under
  `bracketEndChar_kvE2`; `git diff` additive-only; `lean_verify` axiom-clean on all new symbols;
  do-not-edit assets byte-identical; a GO/NO-GO verdict record landed.

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 15.
- [ ] Stage C soundness (Phases 8-10): the soundness direction of the k=2 gate closes with NO residual
      `w = e 1`/`x = e 2` (no provider `e` on the joint path) via `kvE_subBracket_implies_subChain` at
      the constructed sub-bracket.
- [ ] Stage D completeness (Phases 11-14): the `IntervalPattern.holds` data type-checks against
      `kvE_subBracket`'s slot shape; the arrangement disjunct consumes it; the k=2
      `BracketCarrierCorrectVPrior` gate closes to a proven GO (both directions).
- [ ] MANDATORY adversarial test (Phase 15): F4 `ℤ` counterexample (`char[14,16,11,20]` vs honest
      `char[14,15,10,20]`) FAILS against the new carrier (LHS FALSE at `(10,20)`) — discrimination via
      the `σ.2` read.
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on any
      live path (no `sorry`-skeleton committed at any phase boundary).
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Guards G1-G6 + Corrected Anchor-Cap honored; anchor set fixed at 2; no third-anchor tower; the
      completeness witnesses are bracket WITNESSES between the fixed endpoints.
- [ ] EANegation :1090/:1249 untouched; no provider-side pinning (Amendment F3) — the provider
      disappears from the joint path rather than being pinned.
- [ ] Every do-not-edit landed asset byte-identical (including the completed Stage A/B code and
      `BracketCarrierCorrectVPrior`); all Stage C/D work purely additive.

## Artifacts & Outputs

- `specs/321_.../plans/03_corrected-k2-carrier-gate-v3.md` (this plan; supersedes v2).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — additive Stage C/D: the
  soundness-direction scaffolding + per-channel closers + per-sub crux + soundness assembly (Phases
  8-10); the completeness fold-extraction + `IntervalPattern.holds` data + arrangement disjunct +
  gate-close to GO (Phases 11-14); the F4 `ℤ` LHS-FALSE lemma + final GO/NO-GO verdict record (Phase
  15). All on top of the already-landed Stage A/B block, byte-identical do-not-edit assets.
- `specs/321_.../summaries/03_corrected-k2-carrier-gate-v3-summary.md` (at implementation completion).

## Rollback/Contingency

- All Stage C/D work is purely additive (proof-side) after the landed Stage A/B block. To revert:
  delete the appended Stage C/D definitions/theorems/verdict update; every do-not-edit landed asset
  (including the Stage A/B code) is untouched, so rollback restores the byte-identical Stage-A/B-complete
  state (`git checkout` of the single file after snapshotting per `git-snapshot.sh` if the tree is
  dirty).
- If the Phase-8 soundness reduction through `two_eq` fails: the k=2 body shape drifted from the k1v
  template — re-check the `bracketEndChar_kvE2_two_eq` bridge (landed `rfl`), do NOT edit the landed
  carrier.
- If the soundness crux reappears as an `e`-residual (Phase 10): the joint literal was not fully
  consumed — return to Phase 8/9, do NOT introduce a pinning device (Amendment F3) or a flat carrier
  variant.
- If a Stage-D phase (11-14) hits a *genuine machine-grounded obstruction*: fire that phase's Escalation
  bullet — record it F-house-style (exact goal, why not effort), keep all green work committed, and STOP
  for orchestrator re-dispatch or `/revise`. Do NOT absorb the obstruction into a later phase, invent a
  flat/single-point shortcut, or land a `sorry`.
- If the F4 counterexample fails to discriminate semantically (Phase 15): the completeness wiring lost
  the `σ.2` dependence — return to Stage D; do not weaken the adversarial test.
- If a step appears to require a two-anchor single-point assertion: that is a design smell (Gabbay
  cross-check) — escalate to the orchestrator blocker ladder, do not engineer around it. Land a verdict
  record either way (GO, NO-GO, or a defect record), per F1-F4 house style; no partial theorem, no
  `sorry`.
