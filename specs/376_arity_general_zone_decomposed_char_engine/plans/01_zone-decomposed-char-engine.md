# Implementation Plan: Arity-General Zone-Decomposed Char Engine
- **Task**: 376 - arity_general_zone_decomposed_char_engine
- **Status**: [NOT STARTED]
- **Effort**: 24 hours (9 phases, one orchestrator dispatch each; ~11-cycle budget remaining, 2 slack cycles reserved for retry/split)
- **Dependencies**: None upstream (task 375 depends on THIS task and will audit its definition of done)
- **Research Inputs**:
  - specs/376_arity_general_zone_decomposed_char_engine/reports/01_zone-decomposed-seam-interface.md (H4-verified; Q4 phase set adopted verbatim)
  - specs/376_arity_general_zone_decomposed_char_engine/reports/01_zone-seam-probe.lean (compiled machine artifact; Blocks A/B/C templates)
- **Artifacts**: plans/01_zone-decomposed-char-engine.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (literature fidelity, vacuous-definition prohibition)
  - .claude/rules/plan-compliance.md (this plan is the contract for every phase dispatch)
  - .claude/extensions/lean/context/contracts/reference-grounding.md (H3 Tier 1)
- **Type**: lean4
- **Mode**: hard (`--hard --lit`); reference-grounding Tier 1 (Rabinovich 2014)

## Overview

Replace the refuted char-seam pair `hcharFib`/`hcharFibSoundP` (refuted by the compiled
`seamPair_joint_refutation`, `SeamPairRefutationProbe.lean:47/:145`) with the zone-guarded pair
{`hcharFibZone`, `hcharFibZoneSound`} (research report Blocks A/B, already elaboration-checked),
then build the arity-general `zoneExistF` provider engine (Rabinovich 2014 Lemma 5.3
n-induction) that discharges `KampPrior.lean:519` (n=1) and `:522` (n>=2) together, dissolving
Gap C. Close Gap D (general-m supplies for ledger rows 6/10/11) and Gap E (general-k arm
assembly) to reach the definition of done: **zero sorries in KampPrior.lean, full `lake build`
green, axiom set exactly {propext, Classical.choice, Quot.sound}** — the exact properties the
downstream verification task will re-audit.

**Phase 1 is a HARD GATE**: a bounded refutation-or-clearance probe compiling the report's
§Q2.3 cross-anchor-context attack against the re-signed pair. The prior seam looked provable
until a probe refuted it; this plan does not repeat that mistake. All volume phases (2-9) are
conditional on Phase 1 returning CLEARED. This plan does NOT assume CLEARED — the REFUTED exit
is a first-class deliverable (compiled counterexample + blocker handoff + plan invalidation).

### Research Integration

| Report | Integrated |
|--------|-----------|
| reports/01_zone-decomposed-seam-interface.md | Q1 (Blocks A/B/C verbatim), Q2 (refutation-escape + §Q2.3 residual attack -> Phase 1 gate), Q3 (engine shape + paper-to-Lean table), Q4 (phase set adopted verbatim), H3 mapping table (reused, not re-derived) |
| reports/01_zone-seam-probe.lean | Phase 1/2 starting template: Blocks A/B binders to splice; Block C proof to transplant. Specs-side artifact, deliberately NOT in the Theories/ build. |

### Scope Partition (binding; carried verbatim from research + task description)

**FROZEN (sibling-level, NOT file-level — touching any of these is a planning/implementation
error; re-scope instead of editing)**:
- `bracketEndChar_kv` body (`CarrierKv.lean:240-249`)
- Both defeq bridges (`InteriorGateGeneralK.lean:339-351`; `CarrierKv.lean:294-351`)
- The carrier trio definitions (`Base.lean` / `CarrierK1V.lean` / `CarrierKv.lean`)
- `kampPrior_site_rungK_gate_match` (`KampPrior.lean:941`; live consumer
  `EndIntervalConsumerK.lean:248`)

The research concludes NO frozen surface needs touching. Every phase below is scoped to the
EDITABLE additive `*Fib` sibling chain or to new leaf files.

**EDITABLE (the additive `*Fib` sibling chain)**:
- `step_sound` (`InteriorGateGeneralK.lean:2101/:2115`), `step_complete` (`:1733`)
- `bracketEndChar_kvExtFib_correct_prior` (`ExteriorGateAssembleK.lean:559-660`)
- `kampPrior_site_rungKFib_gate_match` (`KampPrior.lean:1058-1181`)

**PRESERVE (re-consume, never discard; signatures unchanged except the two char-seam binders
plus the matching parameter lists of the four siblings that thread them)**:
- `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:61`)
- `kvE_hsliceFut`/`hslicePast` supplies (`ExteriorDeepSliceSupplyK.lean:131/:161`)
- `kvE_hexclDeep*` supplies (`ExteriorDeepExclSupplyK.lean:77/:107`)
- `bracketEndChar_kvFib_realize_futT`/`_pastX` (`InteriorGateGeneralK.lean:1565/:1597`)
- `kampPrior_existProviders_zero` (`KampPrior.lean:1409`)
- The landed k<=1 arms (`AggregateHookDischarge.lean`, `AggregateOffDiagK1.lean`)

**CLOSED ROUTES (do not re-propose)**:
- Restating `nf_nvar_exist_all_depths` to n<=1 — REFUTED (`ExistProviders.existF` is
  all-arity; `P.existF 4` consumed at 38 sites)
- Deferring `KampPrior.lean:522` separately — Gap C entangles it with `:519` at site
  depths >= 3

### Preserved Assets

The following work is complete and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Gap-B seam-pair refutation probe (verdict R) | Theories/.../NfMultiAnchorBridge/SeamPairRefutationProbe.lean | [COMPLETED] | 2026-07 (compiled, in build) |
| Re-signed seam probe (Blocks A/B/C) | specs/376_.../reports/01_zone-seam-probe.lean | [COMPLETED] | 2026-07-15 (`lake env lean` exit 0) |
| hreal supply (ledger row 5) | InteriorHrealSupplyK.lean:61 | [COMPLETED] | task-370 era, build green |
| Deep-slice supplies (rows 8-9) | ExteriorDeepSliceSupplyK.lean:131/:161 | [COMPLETED] | build green |
| Deep-excl supplies (rows 12-13) | ExteriorDeepExclSupplyK.lean:77/:107 | [COMPLETED] | build green |
| m=0 slice-exclusion supplies (rows 10-11) | ExteriorPinnedConversePastK.lean:769; ExteriorPinnedConverseK.lean:1242 | [COMPLETED] | grep-verified this session (report cited :1250; actual :1242 — minor drift, content confirmed) |
| Endpoint extractions | InteriorGateGeneralK.lean:1565/:1597 | [COMPLETED] | build green (re-threaded, not discarded, in Phase 2) |
| Depth-0 provider bundle | KampPrior.lean:1409 (`kampPrior_existProviders_zero`) | [COMPLETED] | build green |
| k<=1 trichotomy arms + aggregates | AggregateHookDischarge.lean, AggregateOffDiagK1.lean | [COMPLETED] | build green (pattern source for Gap E) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the compiled Gap-B refutation
(the failure that created this task), the H4 adversarial findings of report 01, and the
adjudicated closed routes.

**Do NOT**:
- Do NOT re-introduce the unguarded seam shape: a w-universal, qnf-independent, guard-free
  `hcharFibSoundP`-style binder is REFUTED (compiled, `SeamPairRefutationProbe.lean:47`).
  Every soundness-direction char seam MUST carry anchor order + carrier-eval gates +
  marked-fiber guard + zoneHolds guard exactly as in Block B.
- Do NOT drop or weaken the marked-fiber guard `qnf.2 τ = true` — it is load-bearing, not
  cosmetic: without it the §Q2.3 cross-anchor-context attack goes through (report,
  Contradiction Log entry 2).
- Do NOT start any volume phase (2-9) before Phase 1 returns CLEARED. Do NOT plan around, or
  implement toward, a hoped-for CLEARED.
- Do NOT touch any FROZEN surface (list above). If a proof appears to require it, the phase is
  mis-scoped: mark [BLOCKED] and escalate; do not edit.
- Do NOT re-propose the closed routes: `nf_nvar_exist_all_depths` restriction to n<=1;
  deferring `:522` separately from `:519`.
- Do NOT re-type `charFib` to arity 1 to "restore" the Rabinovich unary invariant — that
  re-opens the frozen carrier trio. The invariant is expressed at arity 4 by GUARDING
  (settled; report §Q2.4).
- Do NOT bypass literature steps with `simp`/`omega`/`aesop` where Rabinovich handles them
  explicitly (Lemma 5.3 case split, Cor 5.4(1) witness split) — lean4.md literature fidelity.
- Do NOT create vacuous definitions (`def X := True`, `theorem X := trivial`, etc.) — these
  are sorry-equivalent and will fail the task-375 audit.
- Do NOT introduce new axioms. Acceptance axiom set is exactly
  {propext, Classical.choice, Quot.sound}.
- Do NOT re-derive the paper-to-Lean mapping from scratch — reuse the report's H3 table and
  §Q3 correspondence table.
- Do NOT cite task numbers in any file under `Theories/` (no-task-references rule); docstrings
  reference sibling declarations, file names, and Rabinovich propositions instead.

**MUST preserve**:
- Everything in the Preserved Assets table (byte-stable signatures; consumers re-thread, never
  fork-and-abandon).
- The two existing sorries `KampPrior.lean:519/:522` remain the ONLY sorries in that file
  through Phases 2-7; they are retired in Phases 8-9 and never joined by new ones.
- Frozen surfaces byte-identical (verify with `git diff` scoped to frozen files = empty at
  every phase end).
- task 370's decircularization: `hcharFibZoneSound` stays render-FREE (no
  `nf_eval_nf M _ 3 [...] qnf` hypothesis) — the guards added are order/carrier/fiber/zone,
  never the deep render.

**Design decisions are SETTLED** (do not re-open without a compiled counterexample):
- The seam is a PAIR (guarded <-> for completeness + guarded render-free -> for soundness),
  not a single statement — one seam cannot serve both directions without re-introducing
  circularity or unguarded transport (report Contradiction Log entry 1).
- Route (a)-amended for `:522` — `zoneExistF` at n>=2 directly; route (b) stays closed.
- `inf` from Lemma 5.3 maps to UZ/SZ first/last-occurrence (`PriorDefs.lean:22/:33`), the
  discrete analog load-tested by the landed k<=1 arms.
- Zone guards use `zoneHolds` + `nf0_zoneSpec` (`NfEFold.lean:58/:153`) and the fold-bit decode
  `igFoldBitFib qnf zs σ = decide (qnf.2 σ = true ∧ nf0_zoneSpec σ.atom_assgn = zs)`.

## Goals & Non-Goals

- **Goals**:
  - Machine-check (Phase 1) that the §Q2.3 cross-anchor-context attack fails against the full
    guarded pair — or refute the pair NOW, in one bounded dispatch.
  - Land Blocks A/B in the four `*Fib` siblings; re-thread all consumers (Block C template).
  - Build `zoneExistF` + `zoneExistF_correct` + `kampPrior_zoneProviders` (Lemma 5.3 engine).
  - Close Gaps C, D, E; retire `KampPrior.lean:519` and `:522`.
  - Zero sorries in KampPrior.lean; full `lake build` green; axiom-clean; tree auditable by the
    downstream verification task.
- **Non-Goals**:
  - No edits to frozen surfaces; no re-typing of `charFib`; no removal of the byte-identical
    non-Fib originals (`kampPrior_site_rungK_gate_match` etc. keep their live consumers).
  - No repo-wide sorry elimination — the bar is KampPrior.lean (its transitive dependencies
    must of course be sorry-free for `lean_verify` to pass, which the phases ensure).
  - No new automation/tactic framework — the Gap-B probe toolkit transfers unchanged (report,
    Tactic Survey).

## Risks & Mitigations

- **Risk (top)**: Phase 1 REFUTES the re-signed pair. *Mitigation*: that is a designed exit,
  not a failure — bounded to one dispatch; deliverable = compiled counterexample + blocker
  handoff; Phases 2-9 invalidated pending re-research of a render-gated Seam-2 variant (which
  also stays sibling-level; frozen surfaces still untouched).
- **Risk**: Phase 4 (Cor 5.4(1) <=-induction with re-anchoring) is the research-grade core and
  could exceed one dispatch. *Mitigation*: explicit stop condition (see phase); the n=0/1
  basis (Phase 3) lands first so a Phase-4 overrun strands only the step case; 2 slack cycles
  reserved.
- **Risk**: Gap D row 6 (`hexcl`) has NO interior-exclusion precedent to pattern-follow
  (riskiest supply row). *Mitigation*: sequenced AFTER the seam re-signing (it consumes the
  same guards); its shape is the contrapositive face of the `hz'` fold biconditional
  (`InteriorGateGeneralK.lean:1773-1801`), which Phase 2 will have already exercised.
- **Risk**: parameter-list ripple from re-signing the four siblings breaks distant consumers.
  *Mitigation*: grep confirmed no consumer invokes the char seams at unmarked σ; Phase 2's done
  criterion is full `lake build` green, catching any missed thread immediately.
- **Risk**: shift-homogeneity escape (Gap A analog) for the guarded pair is pen-and-paper only
  (Medium confidence). *Mitigation*: Phase 1's probe includes the old counterexample replay;
  Gap-A-style attacks require a fixed pinned truth set which the guarded form does not assert —
  monitored, not blocking.
- **Risk**: cycle-budget overrun (9 phases, ~11 cycles). *Mitigation*: phases sized to one
  bounded unit each; if any phase returns [PARTIAL] twice, the orchestrator's churn detection
  (H6) escalates rather than burning remaining cycles.

## Literature Proof Structure (Tier 1 — Rabinovich 2014)

Corpus: doc_id `rabinovich_2014`, dir
`/home/benjamin/Projects/Literature/sources/rabinovich_2014` (index metadata "1 chunk" is
stale — chunks 0001..0022+ exist on disk; Read by absolute path; `literature-search.sh`
requires period-free queries). Kamp 1968 available at
`/home/benjamin/Projects/Literature/sources/kamp_1968_tense-logic-linear-order` (background
only).

1. **Lemma 5.3** (chunk_0014 lines 7-41, paper §5 pp. 8-9): n-witness interval existential
   reduced by induction on n; step case-splits on `r0 = inf{z ∈ (z0,z1) : P1(z)}` into
   (1) P1 absent -> ∀-form; (2) `K⁺(P1)(z0) ∧ On(P2…, z0, z1)`; (3) INF-definable `r0` ∧
   `On(P2…, r0, z1)` re-anchored. Lean: `zoneExistF` structural recursion on n; `inf` ↦ UZ/SZ
   first/last-occurrence.
2. **Cor 5.4(1)** (chunk_0015 lines 3-43, p. 9): the <=-direction witness extraction — each
   next witness fired by the `Until` (`y2 > y1`, `βn+1` along `(y1,y2)`, lines 23-29), with the
   two-case split `y2 ≤ xn+1` / `xn+1 < y2` (lines 31-37). Lean: Block C (compiled) is the
   single-step shape; the engine's correctness proof iterates it.
3. **Design invariant** (chunk_0014 line 39 + chunk_0015 throughout): unary content rides
   formulas; order content is positional (bracket/zones). The old seams violated it; Blocks A/B
   restore it by guarding. The divergence from the OLD Lean signatures is a REVERSION to the
   source, justified by the compiled refutation of the divergent form
   (`SeamPairRefutationProbe.lean:47`) — transcription-discipline requirement satisfied.

### H3 Source-to-Implementation Mapping (reused from report; statuses to be advanced per phase)

| Source | Prop/Location | Lean Identifier | Type Signature (abbrev.) | Status | Phase |
|--------|---------------|-----------------|--------------------------|--------|-------|
| Rabinovich 2014 | Lemma 5.3, chunk_0014 ll.7-41, pp.8-9 | `zoneExistF` / `kampPrior_zoneProviders` | `(n : Nat) → NormalForm sig (k+1) (n+1) → Formula` + `ExistProviders` bundle | pending | 3-4 |
| Rabinovich 2014 | Lemma 5.3 basis n=1, chunk_0014 l.9, p.8 | `KampPrior.lean:519` arm | `∃ A, … ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf …` | sorry | 5, 8 |
| Rabinovich 2014 | Lemma 5.3 step, chunk_0014 ll.11-41, pp.8-9 | `KampPrior.lean:522` arm | `∃ A, … ↔ ∃ env : Fin (n+2) → M.carrier, …` | sorry | 4, 9 |
| Rabinovich 2014 | Cor 5.4(1) <=, chunk_0015 ll.23-29, p.9 | `bracketEndChar_kvFibZone_realize_futT` (+ `_pastX` mirror) | see probe l.102-116 | transcribed (probe; production landing Phase 2) | 2 |
| Rabinovich 2014 | §5 unary/positional invariant, chunk_0014 l.39 + chunk_0015, pp.8-9 | `hcharFibZone` / `hcharFibZoneSound` | Blocks A/B (probe ll.70-92) | transcribed as statement; instantiation Phase 5 | 1, 2, 5 |
| Rabinovich 2014 | Lemma 5.3 Case 2 `inf`, chunk_0014 ll.19-27, p.8 | `semantic_prior_UZ`/`_SZ` (`PriorDefs.lean:22/:33`) | (existing, unchanged) | transcribed (pre-existing) | — |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 7 | 1 |
| 3 | 4, 6 | 3 (P4); 2 (P6) |
| 4 | 5 | 2, 4 |
| 5 | 8 | 5, 6, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel (territory-disjoint files: Phase 2 owns the
four sibling files; Phase 3 owns the new engine leaf; Phase 7 owns the two
ExteriorPinnedConverse* files). The orchestrator dispatches one phase per cycle; the wave map
declares which orderings are legal, not a demand for simultaneous dispatch.

### Phase 1: Cross-anchor-context refutation-or-clearance probe (HARD GATE) [COMPLETED]

**VERDICT: CLEARED** (2026-07-15). Probe file `ZoneSeamCrossContextProbe.lean` compiles
sorry-free (commit 895fa4bf4). Attack 1 blocked by the transplanted
`zoneGuard_blocks_seamPair_counterexample`. Attack 2 (§Q2.3): surface (i) — the marked-fiber
guard IS satisfiable (`cpQnf_marks_cpTau`) and the zone guard holds in BOTH contexts
(`cpTau_zoneHolds_A`/`_B`), so route (ii) applied — non-certifiability of context B proven by
`crossContext_wGate_blocks_attack`: the `igPtWFib` gate at `w' = 3` is unsatisfiable for EVERY
`charFib`/`atomMap` and every qnf rendered at the certified context (the charFib-independent
`charBase` head literal demands qnf's w-slot 1-type — which declares `P` forced by `P(1)` —
at `3 ∉ P`). `crossContext_attack_payload` locates the death point exactly: all other attack
premises are derivable in the instance. `lean_verify` on all three public theorems: standard
axioms only, no sorryAx. Proceed to wave 2.
- **Goal:** Compile the report §Q2.3 cross-anchor-context attack against the FULL guarded pair
  {Block A, Block B} jointly, in the exact `SeamPairRefutationProbe.lean` methodology, and
  return an explicit CLEARED or REFUTED verdict. No volume work in this dispatch.
- **Tasks:**
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ZoneSeamCrossContextProbe.lean`
        (same import/namespace/`maxHeartbeats` header as `SeamPairRefutationProbe.lean`; needs
        `open Bimodal.Metalogic.WeakCanonical.Separation`).
  - [x] Attack 1 (regression, expected BLOCKED — already compiled in the specs probe): replay
        the old counterexample (σ* := characteristic of `(w0,w0,x,t)`, step-(3) transport
        `w := w' ≠ w0`, `x1 := w0`) against the guarded pair; transplant
        `zoneGuard_blocks_seamPair_counterexample` from
        `specs/376_.../reports/01_zone-seam-probe.lean:29-53` into the build tree sorry-free.
  - [x] Attack 2 (the NEW §Q2.3 attack, the gate proper): formalize the two-context
        construction — model `(ℤ, P={1})`-style, τ := characteristic of `(5,1,0,10)` (declares
        `P` at the w-slot), contexts `w = 1` vs `w' = 3`, shared `x1` in the same zone — and
        attempt to derive `False` from a pair of Block-B instances. Attempt surface (fixed,
        finite): (i) instantiate both Block-B binders and check the marked-fiber guard
        `qnf.2 τ = true` ties τ's anchor content to qnf's — if the guard cannot be satisfied in
        context B, prove that failure as a sorry-free blocking theorem (CLEARED shape, mirror of
        Attack 1); (ii) if the guard IS satisfiable in both contexts, check the carrier-eval
        gates (`igPtWFib` at `w' = 3` contains charBase/charFib literals for qnf's w-slot
        1-type + fold bits) — prove non-certifiability of context B, or complete the refutation.
  - [x] Write the verdict as a module docstring: `VERDICT: CLEARED` (both attacks blocked by
        sorry-free theorems) or `VERDICT: REFUTED` (a sorry-free `False`-deriving or
        joint-inconsistency theorem compiles). *(verdict: CLEARED)*
  - [x] Verify with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ZoneSeamCrossContextProbe`
        (exit 0) and `lean_verify` on each probe theorem (no sorry, standard axioms).
- **Exit CLEARED** -> proceed to wave 2.
- **Exit REFUTED** -> STOP. Deliverable = the compiled counterexample file + a blocker entry in
  `.orchestrator-handoff.json` (`blockers`: "re-signed seam pair refuted by cross-anchor-context
  attack; Phases 2-9 invalidated; re-research a render-gated Seam-2 variant (stays
  sibling-level; frozen surfaces still untouched)"; `next_action_hint`: re-dispatch research).
  Do NOT proceed to any later phase; do NOT attempt an in-dispatch re-design.
- **Estimated output:** ~60-120 lines (bounded; if Attack 2 cannot be closed either way within
  this budget x2, report the exact stuck subgoal as [PARTIAL] with the open goal state — that
  itself is gate-relevant information, not license to start volume work).
- **Done when:** probe file compiles in the build tree with an explicit VERDICT docstring; all
  non-deliberate theorems sorry-free per `lean_verify`; frozen-surface diff empty.
- **Constraints:** postmortem rules global; additionally: this phase writes ONLY the new probe
  file — zero edits elsewhere.
- **Timing:** 2 hours
- **Depends on:** none

### Phase 2: Re-sign the additive *Fib sibling chain with Blocks A/B [NOT STARTED]
- **Goal:** Substitute the refuted `hcharFib`/`hcharFibSoundP` binders with `hcharFibZone`
  (Block A) / `hcharFibZoneSound` (Block B) across the four EDITABLE siblings, re-thread the
  endpoint extractions, and return the tree to full green with the two KampPrior sorries
  unchanged.
- **Tasks:**
  - [ ] `ExteriorGateAssembleK.lean`: in `bracketEndChar_kvExtFib_correct_prior` (:559-660),
        replace the `hcharFib` binder (:574-578) with Block A and `hcharFibSoundP` (:579-581)
        with Block B (byte-verbatim from the probe file, ll.70-92); repair the proof body's
        uses (every use site must now supply the marked-fiber guard from the fold-bit decode
        and the zone witness — Block C shows the pattern).
  - [ ] `InteriorGateGeneralK.lean`: re-sign the byte-mirror binders in `step_complete`
        (:1733/:1742-1746) — its `hz'` fold biconditional (:1773-1801) already manufactures
        the zoneHolds guard — and `step_sound` (:2101/:2115) — carrier evals from the
        destructured `hveah` (:2137), anchor order from the carrier's order literals.
  - [ ] `InteriorGateGeneralK.lean`: re-thread `bracketEndChar_kvFib_realize_futT` (:1565) per
        Block C (transplant the compiled proof from the specs probe, ll.102-152, adapting
        binder names) and the `_pastX` mirror (:1597; `snce` firing, `igZPastX`, `x1 < x`;
        symmetric zone discharge).
  - [ ] `KampPrior.lean`: re-sign the threaded parameter list of
        `kampPrior_site_rungKFib_gate_match` (:1058-1181) to match.
  - [ ] Known pitfalls (report Tactic Survey): bare `Fin.cons … j` outside application context
        needs type ascription `(… : Fin 3 → M.carrier)`; `decide` closes Bool-bit absurdities;
        `open …Separation` already present in these files.
  - [ ] Verify: `lake build` (full) exit 0; sorry census of KampPrior.lean unchanged (exactly
        :519/:522-equivalent two); `git diff` on all FROZEN files empty; PRESERVE-list
        signatures unchanged except the two char-seam binders + threaded parameter lists.
- **Estimated output:** ~250-400 lines of diff across the 3 files (one bounded unit: one
  binder-pair substitution propagated through its four byte-mirror sites — no new theorems
  beyond the re-threaded extractions whose proofs are transplants).
- **Done when:** full `lake build` green; two sorries unchanged; frozen diff empty;
  `lean_verify` on `bracketEndChar_kvFibZone`-renamed extractions reports sorry-free.
- **Constraints:** no new sorries anywhere; if any single use-site repair resists the Block C
  pattern after 3 distinct attempts, mark [PARTIAL] with the goal state rather than weakening
  a guard.
- **Timing:** 3.5 hours
- **Depends on:** 1

### Phase 3: zoneExistF engine core — definition + n=0/1 basis correctness [NOT STARTED]
- **Goal:** Create the engine leaf file with the full `zoneExistF` recursion (all three
  Lemma 5.3 disjuncts, so the DEFINITION is complete and never revisited) and prove
  `zoneExistF_correct` for the basis cases n=0 and n=1, sorry-free.
- **Tasks:**
  - [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ZoneProviderEngine.lean`;
        wire its import into the `NfMultiAnchorBridge.lean` aggregator (additive only).
  - [ ] Define `zoneExistF` per report §Q3: `| 0, sub =>` atom-layer char (existing depth-0
        route via `nf_depth0_char_formula`); `| n+1, sub =>` disjunction of (1) negated
        Until/Since chain (∀-form), (2) UZ first-occurrence at left anchor ∧ recursive call at
        n same anchors, (3) Until-fired intermediate anchor ∧ recursive call re-anchored at r0
        (`renameNF`-style environment surgery; rot5 precedent `ExteriorNegationK.lean:375`).
  - [ ] Prove `zoneExistF_correct` at n=0 (reduces to the depth-0 characteristic route) and
        n=1 (Lemma 5.3 basis, chunk_0014 l.9: `¬∃x1 ∈ (z0,z1) P1(x1) ≡ (∀y ∈ (z0,z1)) ¬P1(y)`
        + the UZ first-occurrence disjunct) — the n=1 statement matches the `:519` goal shape.
  - [ ] Statement of the full `zoneExistF_correct` (all n) is WRITTEN in this phase with the
        n>=2 step case as the file's only `sorry`, explicitly annotated as Phase-4 scope
        (pre-declared division point within this plan's own phases, not a skeleton sorry —
        retired next dispatch).
  - [ ] Verify: `lake build …ZoneProviderEngine` exit 0; `lean_verify` on the n=0/n=1 basis
        lemmas sorry-free; frozen diff empty.
- **Estimated output:** ~200-350 lines (new leaf file; no edits to existing files beyond the
  aggregator import line).
- **Done when:** engine file compiles; basis correctness sorry-free; exactly one annotated
  sorry (the n>=2 step) in the new file; no other file gains a sorry.
- **Constraints:** UZ/SZ analog of `inf` is SETTLED — do not attempt Dedekind machinery; the
  definition must be complete in this phase (no `sorry`-bodied definition arms, only the one
  step-case proof sorry).
- **Timing:** 3 hours
- **Depends on:** 1 (file-territory independent of Phase 2; legal in the same wave)

### Phase 4: zoneExistF inductive step (n>=2) + Cor 5.4(1) witness induction [NOT STARTED]
- **Goal:** Retire the Phase-3 step-case sorry: prove `zoneExistF_correct` for n+1 via the
  three-disjunct case split and the Cor 5.4(1) <=-direction witness extraction; bundle
  `kampPrior_zoneProviders : ExistProviders sig atomMap (k+1)`.
- **Tasks:**
  - [ ] Forward direction (=>): from `∃ env`, case-split on the first witness against the
        interval per Lemma 5.3 (chunk_0014 ll.11-41): absent -> disjunct (1); at/adjacent to
        left anchor -> disjunct (2); interior first occurrence -> disjunct (3) with UZ
        first-occurrence witness.
  - [ ] Reverse direction (<=): iterate the Block C single-step shape — each `Until` firing
        yields the next witness with the two-case split `y2 ≤ xn+1` / `xn+1 < y2`
        (chunk_0015 ll.31-37); re-anchoring handled by the disjunct-(3) environment surgery.
  - [ ] Define `kampPrior_zoneProviders … : ExistProviders sig atomMap (k+1) :=
        ⟨zoneExistF …, zoneExistF_correct …⟩` (check against `PriorInterface.lean:38-45`).
  - [ ] Verify: `lake build …ZoneProviderEngine` exit 0; `lean_verify zoneExistF_correct` and
        `lean_verify kampPrior_zoneProviders` — sorry-free, standard axioms; engine file now
        has ZERO sorries.
- **Estimated output:** ~250-450 lines (one bounded unit: one theorem's step case + a
  2-line bundle).
- **Stop condition (bounded-unit guard):** this is the research-grade core. If after
  exhausting the literature-faithful route (both directions attempted, each subgoal tried with
  the Gap-B toolkit + `lean_multi_attempt`) a specific subgoal remains open, STOP and return
  [PARTIAL] naming that exact subgoal and its goal state — do not thrash on alternative
  encodings beyond 2 per subgoal, and do not touch other files to "unblock" it.
- **Done when:** `ZoneProviderEngine.lean` sorry-free per `lean_verify`; full `lake build`
  green; frozen diff empty.
- **Constraints:** literature fidelity is strict here — follow chunk_0014/0015 case structure
  explicitly; no `aesop`-bypass of the case split.
- **Timing:** 4 hours
- **Depends on:** 3

### Phase 5: charFib instantiation + seam discharge; green providers at all depths [NOT STARTED]
- **Goal:** Instantiate `charFib` concretely (depth-0 point content ∧ per-fiber-element
  clauses from `zoneExistF` at depth k) and discharge `hcharFibZone`/`hcharFibZoneSound` at
  the `:519` gate site, greening `kampPrior_existProviders_of_ih` at ALL depths (Gap C
  dissolves).
- **Tasks:**
  - [ ] Define the concrete `charFib (k+1) σ` (in `ZoneProviderEngine.lean` or a small
        companion leaf): conjunction of σ's point pred-content (depth-0 char) with
        per-fiber-element clauses built from `zoneExistF` at depth k (report §Q3 "charFib
        instantiation" row) — the Blocks A/B guards are exactly what make this finite formula
        sufficient (order content never expressed by it).
  - [ ] Prove the two seam-discharge lemmas: the guarded <-> (Block A shape) via
        `step_complete`'s reconstruction route, and the guarded render-free -> (Block B shape)
        via the carrier-gated soundness route.
  - [ ] Instantiate the gate route at the `:519` site's depth (`_k+2` fiber layer +
        `hcharFibZone` from `zoneExistF`); show `kampPrior_existProviders_of_ih` accepts
        `kampPrior_zoneProviders` beyond depth 0 (companion to the landed
        `kampPrior_existProviders_zero`, `KampPrior.lean:1409`).
  - [ ] Verify: full `lake build` green; `lean_verify` on the two discharge lemmas and the
        all-depth provider theorem — sorry-free, standard axioms; the `:519`/`:522` sorries
        themselves may still be present (arm REWRITE is Phases 8-9); frozen diff empty.
- **Estimated output:** ~250-400 lines.
- **Done when:** provider bundle certified at all depths by a compiled sorry-free theorem;
  no new sorries; build green.
- **Constraints:** if a discharge lemma appears to need a frozen defeq-bridge edit, that is a
  mis-scope — [BLOCKED] + escalate; the report certifies zero frozen touches are needed.
- **Timing:** 3.5 hours
- **Depends on:** 2, 4

### Phase 6: Gap D row 6 — general-m hexcl supply [NOT STARTED]
- **Goal:** Land the first-ever general-m interior-exclusion supply for ledger row 6
  (`hexcl`, `ExteriorGateAssembleK.lean:609-614` binder): interval-bounded non-realization of
  UNMARKED σ, as the contrapositive face of the zone machinery.
- **Tasks:**
  - [ ] New leaf file (suggested `InteriorExclSupplyK.lean`, sibling of
        `InteriorHrealSupplyK.lean` which is the only landed interior supply precedent).
  - [ ] Prove the general-m `hexcl` supply: the `hz'`-style fold biconditional
        (`InteriorGateGeneralK.lean:1773-1801` pattern) gives `¬realizer → ¬marked` per zone;
        seven-zone case split by `nf0_zoneSpec (atom_assgn σ)` as in
        `kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:61`).
  - [ ] Thread the supply into the row-6 binder at the gate-match site (consuming, not
        editing, the PRESERVE list).
  - [ ] Verify: full `lake build` green; `lean_verify` on the supply theorem sorry-free;
        frozen diff empty.
- **Estimated output:** ~200-400 lines.
- **Done when:** row 6 supplied by a compiled sorry-free theorem consumed at the gate site.
- **Constraints:** riskiest supply row (no precedent): stop condition = if the per-zone case
  split stalls on a specific zone arm after 3 attempts, [PARTIAL] with the arm named; do not
  weaken to an m=0 variant (that row needs general m).
- **Timing:** 3 hours
- **Depends on:** 2 (consumes the re-signed guards; independent of the engine)

### Phase 7: Gap D rows 10/11 — general-m slice-exclusion supplies [NOT STARTED]
- **Goal:** Generalize `kvE_hexclSlicePast_supply_zero` (`ExteriorPinnedConversePastK.lean:769`)
  and `kvE_hexclSliceFut_supply_zero` (`ExteriorPinnedConverseK.lean:1242`) to general m,
  following the landed general-m pattern of rows 8-9/12-13.
- **Tasks:**
  - [ ] `kvE_hexclSliceFut_supply` (general m) in `ExteriorPinnedConverseK.lean` (or the
        deep-supply sibling file if that matches the rows-8-9 layout better): pattern-follow
        `kvE_hsliceFut_supply` (`ExteriorDeepSliceSupplyK.lean:131/:161`) and
        `kvE_hexclDeepFut_supply` (`ExteriorDeepExclSupplyK.lean:77/:107`).
  - [ ] `kvE_hexclSlicePast_supply` (general m), symmetric mirror in the Past file.
  - [ ] Keep both `_zero` variants byte-stable (PRESERVE); the general-m theorems are
        additive siblings.
  - [ ] Thread both supplies into the rows-10/11 binders.
  - [ ] Verify: full `lake build` green; `lean_verify` both supplies sorry-free; `_zero`
        variants byte-identical; frozen diff empty.
- **Estimated output:** ~150-350 lines per pair (~300-500 total, two symmetric mirrors of one
  landed pattern — a single bounded unit because the pattern is mechanical; if the Fut side
  proves NON-mechanical, land Fut alone as 7 and split Past to a 7.1 dispatch).
- **Done when:** rows 10/11 supplied general-m by compiled sorry-free theorems.
- **Constraints:** territory-disjoint from all other phases (two ExteriorPinnedConverse*
  files) — legal to dispatch any time after Phase 1.
- **Timing:** 3 hours
- **Depends on:** 1 (independent of engine and seam re-signing; wave 2)

### Phase 8: Gap E arm assembly part 1 — general-k arms; retire :519 [NOT STARTED]
- **Goal:** Build the general-k trichotomy arms + aggregate carriers (`kampArm_*_kv` analogs of
  the landed k<=1 stack) and REWRITE the `KampPrior.lean:519` arm to consume the gate route,
  retiring that sorry.
- **Tasks:**
  - [ ] New leaf file (suggested `AggregateArmKv.lean`): general-k analogs of
        `kampArm_{past,diag,future}_k{0,1}` (`AggregateHookDischarge.lean:1686-1747/:2087`,
        `AggregateOffDiagK1.lean:1456/:1485`), aggregate carriers (`aggAtomK1*`,
        `aggPop1/aggPop1F` analogs), parameterized ONCE over k — the payoff of the re-signed
        per-qnf gate certificate already being general-k.
  - [ ] Translation glue from the arms to the `:519` goal shape (`∃ A, ∀ M h_UZ h_SZ t,
        temporal_truth … ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf …` — the n=1 existential IS
        `zoneExistF 1`).
  - [ ] Rewrite the `:519` arm in `KampPrior.lean` to invoke the assembled route; delete that
        `sorry`.
  - [ ] Verify: full `lake build` green; KampPrior.lean sorry census = exactly 1 (the `:522`
        arm); `lean_verify` on the rewritten arm's enclosing declaration reports its only
        remaining `sorryAx` source as the `:522` arm; frozen diff empty
        (`kampPrior_site_rungK_gate_match` and the k<=1 arms byte-identical).
- **Estimated output:** ~300-500 lines.
- **Done when:** `:519` retired; exactly one sorry left in KampPrior.lean; build green.
- **Constraints:** consume (never edit) the PRESERVE list and the k<=1 stack; if the
  general-k parameterization forces an edit to `AggregateHookDischarge.lean` internals, stop —
  that stack is a pattern SOURCE, additive siblings only.
- **Timing:** 4 hours
- **Depends on:** 5, 6, 7

### Phase 9: Gap E part 2 — retire :522; zero sorries; final verification for audit [NOT STARTED]
- **Goal:** Rewrite the `:522` arm via `kampPrior_zoneProviders` at n>=2 (route (a)-amended),
  reach zero sorries in KampPrior.lean, and leave the tree in the exact state the downstream
  verification task will audit.
- **Tasks:**
  - [ ] Rewrite the `:522` arm: `⟨zoneExistF (n+2) sub_nf, zoneExistF_correct …⟩` through the
        assembled arm/translation glue from Phase 8; delete the last `sorry`.
  - [ ] Full-tree verification sweep: `lake build` (full project) exit 0; `grep -c "sorry"`
        over code (non-comment) in KampPrior.lean = 0; `lean_verify` on the top-level
        KampPrior theorem(s) (the declaration formerly enclosing `:519`/`:522`, plus
        `kampPrior_zoneProviders` and the Phase-5 all-depth provider theorem): sorry-free,
        axiom set exactly {propext, Classical.choice, Quot.sound} — no `sorryAx`, no new
        axioms.
  - [ ] Frozen-surface final check: `git diff <pre-task-baseline> -- <frozen files>` empty.
  - [ ] Write `specs/376_arity_general_zone_decomposed_char_engine/summaries/01_zone-engine-summary.md`
        recording: per-phase outcomes, the final sorry census (0), the `lean_verify` axiom
        output verbatim, the preserved-assets regression check, and any plan deviations — the
        audit task's input.
  - [ ] Update `.return-meta.json` (status `implemented`, completion_data) per the
        implementation agent's own contract.
- **Estimated output:** ~100-250 lines of Lean + summary artifact.
- **Done when:** zero sorries in KampPrior.lean; full `lake build` green; `lean_verify`
  axiom-clean on all named targets; summary written.
- **Constraints:** this phase must NOT paper over a residual gap with a vacuous def or a
  weakened statement; if `:522` resists, [PARTIAL] with the exact subgoal — an honest partial
  beats a fake completion, and the audit task will catch the latter.
- **Timing:** 3 hours
- **Depends on:** 8

## Testing & Validation

- [ ] Phase-end scoped builds: `lake build <Module>` per phase; FULL `lake build` at the end of
      every phase that edits existing files (2, 5, 6, 7, 8, 9).
- [ ] `lean_verify` (fully qualified names) on every new theorem a phase claims sorry-free;
      acceptance axiom set exactly {propext, Classical.choice, Quot.sound}.
- [ ] Sorry census invariant: KampPrior.lean has exactly 2 sorries through Phases 2-7, exactly
      1 after Phase 8, exactly 0 after Phase 9; `ZoneProviderEngine.lean` has exactly 1
      annotated sorry after Phase 3 and 0 after Phase 4; no other file ever gains one.
- [ ] Frozen-surface regression: `git diff` scoped to the four frozen surfaces empty at every
      phase end.
- [ ] Preserved-assets regression: PRESERVE-list signatures unchanged (except the two char-seam
      binders + the four siblings' threaded parameter lists, per Phase 2's explicit scope).
- [ ] Phase 1 verdict recorded explicitly (CLEARED/REFUTED docstring + handoff) before any
      wave-2 dispatch.
- [ ] Incremental commits at every green milestone per git-workflow.md
      (`task 376 phase P: …`); never commit a RED tree.

## Artifacts & Outputs

- plans/01_zone-decomposed-char-engine.md (this file)
- Theories/.../NfMultiAnchorBridge/ZoneSeamCrossContextProbe.lean (Phase 1)
- Theories/.../NfMultiAnchorBridge/ZoneProviderEngine.lean (Phases 3-5)
- Theories/.../NfMultiAnchorBridge/InteriorExclSupplyK.lean (Phase 6; name indicative)
- Theories/.../NfMultiAnchorBridge/AggregateArmKv.lean (Phase 8; name indicative)
- Edits: ExteriorGateAssembleK.lean, InteriorGateGeneralK.lean, KampPrior.lean (Phases 2, 8, 9);
  ExteriorPinnedConverseK.lean, ExteriorPinnedConversePastK.lean (Phase 7)
- summaries/01_zone-engine-summary.md (Phase 9; the audit input)

## Rollback/Contingency

- Every phase commits only on green; a failed phase leaves the last green commit as the
  rollback point (use `git-snapshot.sh` before any intentional discard — never raw
  `git reset --hard` on a dirty tree).
- Phase 1 REFUTED: no rollback needed (only the probe file exists); task returns to research
  with the compiled counterexample as the new research input.
- Phase 4 overrun: engine definition + basis (Phase 3) remain landed and green; the step-case
  sorry is annotated and localized — a follow-up dispatch resumes exactly there.
- Cycle-budget exhaustion after Phase 5: the seam + engine + providers are the durable core;
  Gaps D/E phases are additive leaves that a successor task can pick up without rework — if
  fewer than 2 cycles remain before Phase 6, the orchestrator should prefer stopping at a green
  boundary and reporting [PARTIAL] with the remaining phases enumerated over starting a phase
  it cannot finish.
