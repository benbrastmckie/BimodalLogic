# Implementation Plan: Task #349 (v6 — faithful two-endpoint carrier `endInterval`)

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive, RE-BASED onto the faithful
  two-endpoint carrier (`endInterval : (k) → BracketEndCharCarrierV sig k` + `endInterval_correct`)
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction` family, green, sorry-free, 0-new-axiom)
- **Research Inputs**:
  - reports/06_phase3-gate-adjudication.md (AUTHORITATIVE — Lean-feasibility verdict: Case 3
    ARCHITECTURE INFEASIBLE for the single-point `EndCharCarrier→TemporalPred` carrier; §4.5 the
    corrected `endInterval_correct` signature; §3.2/§4.4 the faithful two-endpoint alternative)
  - reports/07_rabinovich-faithfulness-deep-check.md (AUTHORITATIVE — paper-faithfulness verdict:
    UNFAITHFUL carrier type; §1 Rabinovich free-variable discipline; §5 the faithful primitive =
    `BracketEndCharCarrierV`; §3 5-column faithfulness map; §7 adversarial self-verification)
  - reports/04_arity4-bridge-feasibility-audit.md (the arity-4 enclosing-pair / parameter-independence
    NON-THEOREM refutation)
  - reports/05_...-summary (the v5 residual-conditioned plan this SUPERSEDES; its Phase-1/2 reduction
    assets are PRESERVED, its Phase-3 single-point carrier is RETIRED)
  - specs/REVIEW_codebase-restructure/00_synthesis-and-recommendation.md §1 (corrected finish path:
    349 faithful revise → 350 → 309 Phases 18-19; endChar is the single shared bottleneck)
- **Artifacts**: plans/06_faithful-two-endpoint-carrier.md (this file); supersedes
  plans/05_faithful-residual-conditioned-endchar.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md;
  reference-grounding.md (H3 Tier-1); literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [06_phase3-gate-adjudication.md, 07_rabinovich-faithfulness-deep-check.md]

## Overview

Re-base task 349's deliverable off the **proven-infeasible** single-point recursion carrier
`EndCharCarrier sig k := NormalForm sig k 3 → TemporalPred` (Base.lean:1007) onto the **faithful,
two-endpoint, `x,t`-EXPLICIT, `Prop`-valued** recursion carrier
`BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2` (CarrierK1V.lean:365). The deliverable
is `endInterval : (k) → BracketEndCharCarrierV sig k` by recursion on modal depth `k`, plus
`endInterval_correct` (the `BracketCarrierCorrectV`-shaped biconditional, x,t explicit on BOTH sides,
in the k0-mirror bracket-zone-order conditional form). This supersedes v5, whose single-point
carrier was independently proven **UNFAITHFUL** (report 07: applies Rabinovich's Prop-3.5 single-point
collapse at 2 free variables) and **ARCHITECTURE INFEASIBLE** (report 06: the report-04 non-theorem
`endCharN0_correct_infeasible` survives the `h_res` residual escape at every `k ≥ 1`).

The faithful carrier is **already green at `k = 0` and `k = 1`**: `bracketEndChar_k0`/`_correct`
(CarrierK1V:73/87) and `bracketEndChar_k1v`/`_correct` (CarrierK1V:433/2041, proved sorry-free via
`_sound`+`_complete` and a ~1500-line helper kit). This plan lifts that concrete `k=1` template to
arbitrary `k`, threading the depth-`k` IH `endInterval_correct k` (itself x,t-explicit) at the
endpoint/interior hooks — the exact piece v5 got backwards (report 06 §SQ2 wall 2). The
`EndCharCarrier→TemporalPred` / `navPieceForm` / `navPieceForm_correct` / `endChar_correct` /
`endCharStep` line is **retired** (machine-checked non-theorems, reports 04/06/07).

**Definition of done**: `endInterval`/`endInterval_correct` sorry-free; `lean_verify endInterval_correct`
= exactly `[propext, Classical.choice, Quot.sound]`; scoped `lake build` (CarrierK1V module) GREEN at
every phase and final whole-tree `lake build` GREEN; the refuted single-point scaffold is archived to
`Kamp/Boneyard/`; the preserved reduction family survives green; `git status --short` touches only the
sanctioned additive/archival scope (below); `endInterval_correct` is a top-level citable name that
task 309's re-plan (Phases 18-19) can consume.

### Scope change recorded (the "frozen `EndCharCarrier`" constraint is LIFTED)

The original task-349 description froze `EndCharCarrier sig k` (Base.lean:1007) and forbade widening
it. **That constraint is EXPLICITLY LIFTED for this re-base**, on the authority of TWO converging
audits:
- **report 06** (Lean feasibility): the frozen carrier forces the `navPieceForm_correct` non-theorem
  at every `k ≥ 1`; `endCharN0_correct_infeasible` (Base.lean:1779, machine-checked) survives the
  `h_res` escape because the depth-0 atom-residual cancellation structurally cannot fire at `k+1`.
- **report 07** (paper faithfulness): the frozen carrier has no counterpart in Rabinovich's proof —
  it applies the Prop-3.5 single-point collapse (one free variable, md:137) to a two-free-variable
  object (md:219). The faithful motive is the two-endpoint interval `[…](z0,z1)`.

The carrier is NOT "widened" — it is **replaced** by the already-endorsed, already-green
`BracketEndCharCarrierV`. The frozen `EndCharCarrier` abbrev (Base.lean:1007) and its single-point
`endChar0` base are left inert/preserved; nothing in this plan reads them as the recursion motive.

### Preserved Assets

Complete, green, sorry-free — **consume by name, do NOT rebuild or regress**.

| Component | File:line | Status | Role in v6 |
|-----------|-----------|--------|------------|
| `BracketEndCharCarrierV` (VVecEA2 carrier type) | CarrierK1V.lean:365 | [COMPLETED] | THE re-typed recursion motive |
| `BracketCarrierCorrectV` (x,t-explicit correctness Prop) | CarrierK1V.lean:374 | [COMPLETED] | shape of `endInterval_correct` |
| `bracketEndChar_k0` / `bracketEndChar_k0_correct` | CarrierK1V.lean:73/87 | [COMPLETED] | recursion base (`k=0`), embedded into VVecEA2 |
| `bracketEndChar_k1v` / `_correct` (+ `_sound`/`_complete`) | CarrierK1V.lean:433/2041 | [COMPLETED] | the GREEN `k=1` step + proof TEMPLATE to generalize |
| `bracketFromLists` (disjunct builder) | CarrierK1V.lean:389 | [COMPLETED] | step assembly vehicle (§5 bracket `[α…](z0,z1)`) |
| k1v helper kit (`k1v_bracket_extract`, `k1v_zone_consistent`, `k1v_bool_eq_false`, `k1v_sorted_realization`, …) | CarrierK1V.lean:513-2039 | [COMPLETED] | proof kit to generalize from `k=1` to `k` |
| `nfEval_le2_reduction` (Rabinovich Lem 3.2(2)) | Lemma32Reduction.lean:535 | [COMPLETED] task 351 | Step A: arity-4 → ≤3-anchor conjunction, reduce FIRST |
| `nfEval3_reduction`/`nfEval4_reduction` (+`_zero`/`_succ`_shape) | NavigatedEndChar.lean:75/396 | [COMPLETED] v5 P1/P2 | arity reduction shapes (Step A) — **preserve verbatim** |
| `endCharStep_reduceA` / `endCharStep_quant_reduceA` | NavigatedEndChar.lean:441/459 | [COMPLETED] v5 P2 | whole-quant-layer reduction (Step A); code-independent of refuted defs |
| `navPiece_reduce` | NavigatedEndChar.lean:215 | [COMPLETED] v5 P3a | witness-outside arity-3 reduction (Step A) |
| `endCharNav0_correct` (+`_pairwise`) | NavigatedEndChar.lean:118/135 | [COMPLETED] v5 P2 | reduced-RHS base composition |
| `nf_zone_flatten_navigable` / `_correct` / `_brick` | Base.lean:667/687/813 | [COMPLETED] | Step B: Prop-valued x,t-EXPLICIT merge (report 06 §4.5 discharge tool) |
| `nf_3var_bracket_xyt` / `_correct` | VecEADecomp:233/244 | [COMPLETED] | the depth-0 two-anchor bracket (`bracketEndChar_k0` interior) |
| `nf_depth0_char_formula` / `_correct`, `formula_conjList` / `_iff` | Separation | [COMPLETED] | endpoint/segment literal builders |
| `endCharN0_correct_infeasible` (+ `sigCex`/`Mcex`) | Base.lean:1779 | [COMPLETED] | NEGATIVE guardrail — the machine-checked non-theorem the single-point line is refuted by |

### Boneyard restore assessment (archival swap, RESTORE side)

A Wave-1 cleanup (git 31473e6d2) archived four green files to `Kamp/Boneyard/`. Direct dependency
analysis (this planning dispatch) verified the **arity-2** faithful carrier
(`CarrierK1V`/`CarrierKv`/`NavigatedSpine`/`SubBracket2V`/`Base`/`NfZoneFlattenNavigable`, built on
`VecEA2`/`VVecEA2`) references **none** of the four by name — 0 code hits. Restore is therefore
**DEMAND-DRIVEN**, not forced:

| Boneyard file | Provides | Consumed by faithful path today? | Import reversal | Verdict |
|---------------|----------|----------------------------------|-----------------|---------|
| `NegationIndep.lean` | `neg_vecEA2_indep(_correct)`, `neg_2var_vec_ea_indep(_correct)` (arity-2 negation, Prop 4.2) | NO (0 hits) | none (pure `git mv`) | RESTORE-ON-DEMAND (top candidate if the step needs model-independent negation) |
| `RabinovichTranslation.lean` | `ExistsForallSpec.translate(_correct)`, future/past chains (Thm 4.4 FO→TL) | NO (0 hits) | none (pure `git mv`) | RESTORE-ON-DEMAND (most plausibly a 309-downstream, not 349) |
| `EAVecNegationClosure.lean` | `VecEA_m.liftEndpoint/liftInterval(_holds)` (arity-**m** lifting) | NO (arity-m, not arity-2) | YES (revert `.Boneyard.VecEAArityFirewall`) | LEAVE ARCHIVED (wrong arity family) |
| `VecEA_m.lean` | `env2`, `extendEnv`, `VecEA_m`/`VVecEA_m` (arity-**m** carrier) | NO (0 hits; carrier uses arity-2 `VecEA2`) | none | LEAVE ARCHIVED (wrong arity family) |

The refuted probes `NfZoneDepthK1Probe.lean` / `NfZoneNavProbe.lean` (machine-checked NO-GO results,
no live code refs) and `VecEAArityFirewall.lean` (arity-m cluster) **STAY ARCHIVED**. No restore is
forced by the current build; Phase 1 records this and Phases 3-4 restore `NegationIndep` /
`RabinovichTranslation` **only at first code reference** (zero import cost).

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

Load-bearing decisions cite `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(`md:NNN`) via reports 06/07. 5-column format per reference-grounding.md.

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature / Fact | Status |
|--------------------------|---------------|-----------------|-----------------------|--------|
| Lemma 3.2(2) — reduce to ≤2-free conjunction | md:119 (p.4) | `nfEval_le2_reduction`, `endCharStep_quant_reduceA` | arity-`n` → conjuncts of anchor-arity ≤3, witness bound | transcribed |
| Prop 4.2 / §5 — negate/navigate at **2** free vars, both endpoints explicit | md:165/219 (p.7) | `BracketEndCharCarrierV`, `nf_zone_flatten_navigable_correct` | `NormalForm sig k 3 → VVecEA2`; merge x,t explicit both sides | transcribed (carrier); pending (step) |
| §5 Notation 5.2 — two-endpoint interval `[α0,β1,…,αn](z0,z1)` | md:219 (p.7) | `bracketFromLists`, `BracketCarrierCorrectV` | `(carrier qnf).holds M atomMap x t ↔ ∃w, nf_eval_nf M k 3 [w,x,t] qnf` | transcribed (k≤1); pending (k) |
| Lemma 3.4 — ∨∃∀ closed under ∃; absorbed witness JOINS prefix | md (p.5) | `bracketFromLists` (n witnesses), VVecEA2 disjuncts | `BracketFormula (lL.length+1+lR.length)` | transcribed |
| Lemma 5.3 — navigate (`r0=inf`), re-anchor endpoint; no 3rd free var | md:233-247 | endpoint hooks via IH `endInterval_correct k` | `h_past`/`h_fut` from x,t-explicit IH | pending (step) |
| Cor 5.4 — endpoint characteristic chain (recursion) | md:261-263 | `endIntervalStep` (IH hook) | `endInterval k` at ≤3-anchor sub-pieces | pending (step) |
| Prop 3.5 — collapse to single-point TL formula **only at 1 free var** | md:137 (p.5) | `bracketEndChar_k0` (base) / downstream 309 extraction | closed `TemporalPred` only at ≤1 free — NOT inside recursion | transcribed (base); out-of-scope (top extraction = 309) |
| single-point char CANNOT certify multi-anchor eval | (Lean impossibility) | `endCharN0_correct_infeasible` | machine-checked non-theorem | guardrail (forbidden target) |

## Goals & Non-Goals

**Goals**:
- Archive the refuted single-point scaffold (`endChar`, `endCharStep`, `endChar_correct`,
  `endChar_correct_zero`, `endChar_correct_step`, `navPieceForm`) from NavigatedEndChar.lean to
  `Kamp/Boneyard/`, preserving the green Step-A reduction family; whole-tree build stays GREEN.
- Define `endInterval : (k) → BracketEndCharCarrierV sig k` by `Nat.rec`: base = `bracketEndChar_k0`
  (embedded VecEA2 1 → VVecEA2); step = `endIntervalStep`.
- Prove `endInterval_correct` at every `k` in the `BracketCarrierCorrectV` / report-06-§4.5 form
  (x,t explicit on BOTH sides, k0-mirror bracket-zone-order conditional), base from
  `bracketEndChar_k0_correct`, step by generalizing `bracketEndChar_k1v_correct`'s `_sound`/`_complete`
  proof, discharging endpoint/interior hooks from the depth-`k` IH `endInterval_correct k`.
- Keep everything sorry-free; `lean_verify endInterval_correct` = exactly
  `[propext, Classical.choice, Quot.sound]`.

**Non-Goals**:
- Any single-point `EndCharCarrier→TemporalPred` recursion carrier, `navPieceForm(_correct)`,
  `endChar_correct` with `h_res`, or the residual-threading lemma — all machine-checked non-theorems
  (reports 04/06/07). RETIRED, never re-stated.
- The top-level ≤1-free-variable closed-`TemporalPred` collapse (Prop 3.5 / Thm 4.4) — this is the
  DOWNSTREAM 350/309 extraction step, OUT OF 349 scope. 349 delivers the two-endpoint carrier only.
- Restoring the arity-**m** cluster (`VecEA_m`, `EAVecNegationClosure`, `VecEAArityFirewall`) or the
  refuted probes (`NfZoneDepthK1Probe`, `NfZoneNavProbe`) — they stay archived.
- Re-deriving task 351's `nfEval_le2_reduction`, the k1v helper kit, or the k=0/k=1 green instances.
- Editing the seven frozen provider files, `KampPrior.lean`, `Lemma32Reduction.lean`, or
  `nf_nvar_exist_all_depths`'s signature.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **General-`k` step proof (Phases 4/5) is research-grade / >500 lines / open-ended** — the `k=1` correctness alone is ~1500 lines | H | H | Pre-declared split by proof DIRECTION (Phase 4 = soundness LHS→RHS, Phase 5 = completeness RHS→LHS + ↔ assembly), mirroring the green `bracketEndChar_k1v_sound`/`_complete` structure. Each direction is a bounded unit with the k=1 kit as a working template (NON-refuted, inhabited at k=0 AND k=1 — categorically unlike v5's non-theorem). Bounded-unit stop: direction closed OR `[BLOCKED]` + recorded `lean_goal`. If a direction overruns one run, split further at the reduce-first (Step A) / merge (Step B) seam |
| **Regression onto the refuted single-point line** because it "looks cleaner" | H | M | PROHIBITED (postmortem). The discriminator is the CARRIER TYPE: `→ VVecEA2` (x,t explicit), never `→ TemporalPred`. Any goal of shape `temporal_truth w φ ↔ ∃v nf_eval_nf … [v,w,x,t] sub` is `navPieceForm_correct` (report-04 non-theorem) — STOP, it means the carrier regressed |
| **Archive surgery breaks the interleaved preserved reduction family** (refuted and preserved decls interleave at lines 196-480) | H | M | Verified code-independence this dispatch: `endCharStep_reduceA`/`_quant_reduceA`/`nfEval4_reduction`/`navPiece_reduce` reference the refuted defs 0 times in CODE (only in stale docstrings). Move only the 6 refuted decls; if `navPiece_reduce`'s STATEMENT references `navPieceForm`, retain `navPieceForm` inert rather than archive it. Scoped build after the move confirms the family survives |
| **k=0 (VecEA2 1) vs step (VVecEA2) carrier-type mismatch** in the recursion base | M | M | Phase 2 embeds `bracketEndChar_k0` (VecEA2 1) as a **singleton VVecEA2 disjunct**; `endInterval_correct 0` lifts `bracketEndChar_k0_correct` through the singleton-disjunct `VVecEA2.holds` unfolding. Implementer confirms the embedding elaborates before proceeding |
| **General-`k` fold**: `bracketEndChar_k1v` reads `qnf.2` through the k=1-specific `efold_of_nf1`; general `k+1` has a depth-`k` arity-4 sub-evaluation | H | M | The general-`k` channel is NOT a new fold — it is **reduce-first (Step A, preserved `nfEval_le2_reduction`/`endCharStep_quant_reduceA`) THEN the IH carrier `endInterval k`** characterizing each ≤3-anchor depth-`k` conjunct. The IH `endInterval_correct k` (x,t explicit) discharges the endpoint hooks — the report-06-§4.5 fix. No arity-4 single-point read forms |
| Accidental edit to a frozen file (7 providers, `KampPrior.lean`, `Lemma32Reduction.lean`, `nf_nvar_exist_all_depths` sig) | H | L | Never open for edit; verify `git status --short` before each commit shows only the sanctioned scope (CarrierK1V additive, NavigatedEndChar archive-edit, Boneyard moves, plan/summary) |
| Manual Rabinovich chain step tempts a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro`/`or_congr`/`exists_congr`/`and_congr_right`, mirroring the k1v kit (CarrierK1V:558-633) |
| Fake green (`sorry` / `def X := True` / weakening simp) when a direction resists | H | M | PROHIBITED. A stuck main target is `[BLOCKED]` + `lean_goal` record + `/spawn 349`, never a fake green |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 5 |

Phases are **sequential** (single-territory recursion; each depends on the prior's carrier/statement
shape). Territory: **additive** edits to `CarrierK1V.lean` (new `endInterval`, `endIntervalStep`,
`endInterval_correct` and helpers), an **archive-only** edit to `NavigatedEndChar.lean`, and the
**Boneyard file moves**. NO edits to the seven frozen providers, `KampPrior.lean`,
`Lemma32Reduction.lean`, or `nf_nvar_exist_all_depths`'s signature.

**Per-phase hard bar (every `[NOT STARTED]` phase)**:
- sorry-free; `lean_verify` on the phase's new lemma = exactly `[propext, Classical.choice, Quot.sound]`;
  scoped `lake build` of the CarrierK1V module GREEN (whole-tree GREEN at Phases 1 and 6).
- Preserved assets consumed by name, never rebuilt; "reuse vs rebuild" note satisfied.
- **Guards (binding)**: **G1** no arity-1 collapse — arity fixed at 3, the single-point closed-formula
  collapse is reserved for the ≤1-free downstream extraction (out of scope), never inside the recursion;
  **G2/G4** anchors ⊆ {x,t}, ≤2; `w` and the VVecEA2 disjunct witnesses are bracket witnesses, never a
  third free anchor; **G3** interior segments (`segL`/`segR`) are real exclusions, never `TemporalPred.top`;
  **G5** manual bridges only (no `simp`/`omega`/`aesop` on a Rabinovich chain step). FORBIDDEN
  (grep-confirmed absent in new code): the single-point `→TemporalPred` carrier, `navPieceForm`,
  `navPieceForm_correct`, `h_res` residual-threading, arity-4 collapse / arity-4-enclosing-pair
  single-point read, per-pair `∀ij∃w` distribution.

### Phase 1: Archival swap — archive refuted single-point scaffold; record demand-driven restore [COMPLETED]

- **Goal:** Retire the machine-checked non-theorem line by moving the refuted single-point scaffold
  from `NavigatedEndChar.lean` to `Kamp/Boneyard/`, preserving the green Step-A reduction family;
  record (do not force) the demand-driven Boneyard restore rule. Whole-tree build stays GREEN.
- **Archive targets** (the refuted single-point construction + its blocked correctness — reports 04/06/07):
  `endChar` (:329), `endCharStep` (:313), `endChar_correct` (:263), `endChar_correct_zero` (:343),
  `endChar_correct_step` (:480, BLOCKED non-theorem), and `navPieceForm` (:196) — the
  `EndCharCarrier→TemporalPred` recursion and `navPieceForm` converter. Move to
  `Kamp/Boneyard/NavigatedEndCharSinglePoint.lean` with a header note citing reports 04/06/07.
- **Preserve (do NOT move)** — the Step-A reduction family, verified code-independent of the refuted
  defs this dispatch: `nfEval3_reduction` (+shapes, :75), `endCharNav0_correct` (+`_pairwise`, :118),
  `navPiece_reduce` (:215), `nfEval4_reduction` (+shapes, :396), `endCharStep_reduceA` (:441),
  `endCharStep_quant_reduceA` (:459).
- **Reuse vs rebuild:** pure file surgery — no new proofs. If `navPiece_reduce`'s STATEMENT references
  `navPieceForm`, retain `navPieceForm` inert in NavigatedEndChar rather than archive it (assess first).
- **Tasks:**
  - [x] Confirm compilation-safety: grep the non-Boneyard tree for live references to the archive
        targets (verified this dispatch: referenced only inside NavigatedEndChar; the `seg endChar`
        hits in Base/Lemma32Reduction are LOCAL hook parameters, not the global def). *(done: also
        confirmed nothing imports NavigatedEndChar — it is an orphan leaf; Base.lean:1558
        `def endChar` is a fenced doc-comment signature, not real code.)*
  - [x] Assess the interleave: confirm the 6 preserved reduction lemmas reference the archive targets
        0 times in CODE (docstring mentions are fine). Retain any refuted def a preserved STATEMENT
        depends on (expected: none, or `navPieceForm` inert). *(done: 0 code refs; `navPiece_reduce`
        is `exists_congr (nfEval_le2_reduction …)` — does NOT reference `navPieceForm`, so NO inert
        retention needed. All 11 preserved decls moved 0 archive targets.)*
  - [x] `git mv`-equivalent: create `Boneyard/NavigatedEndCharSinglePoint.lean`, move the refuted
        decls, add the boneyard import; delete them from `NavigatedEndChar.lean`. Keep the reduction
        family in place. *(done: 4 real decls + 3 doc-sections moved; NavigatedEndChar −272/+31 lines;
        import `…Boneyard.NavigatedEndCharSinglePoint` added; no cycle.)*
  - [x] Record the demand-driven restore rule (from the Boneyard restore assessment above) as a
        docstring/plan note: restore `NegationIndep`/`RabinovichTranslation` ONLY at first code
        reference in Phases 3-4; leave arity-m + probes archived. No restore forced now. *(done:
        recorded in the new Boneyard file header §"Demand-driven Boneyard restore rule" and in the
        note below; nothing restored in Phase 1.)*
  - [x] Route audit: `git status --short` shows only NavigatedEndChar.lean + the new Boneyard file
        (+ plan); no frozen-file edit. *(done: only NavigatedEndChar.lean [M], the new Boneyard file
        [??], plan + TODO/state status-sync; 0 frozen-provider / KampPrior / Lemma32Reduction / Base
        proof edits.)*

**Phase 1 result (v6):** Whole-tree `lake build` GREEN (1724 jobs). Preserved reduction lemmas
`navPiece_reduce` and `endCharStep_quant_reduceA` `lean_verify` = `[propext, Classical.choice,
Quot.sound]`. No sorry/vacuous defs in either scoped file (the 2 `EANegation.lean` sorries are
pre-existing, out of scope). `nf_nvar_exist_all_depths` and all 7 frozen providers untouched.

**Demand-driven Boneyard restore note (recorded, not executed):** The faithful arity-2 two-endpoint
carrier references NONE of the 4 `Kamp/Boneyard/` files today. `NegationIndep` (`neg_vecEA2_indep`)
and `RabinovichTranslation` are zero-cost restore-on-demand candidates for Phases 3-4 — restore ONLY
at first genuine code reference; leave `EAVecNegationClosure`/`VecEA_m` (arity-m) and the
`NfZone*Probe` files archived. No restore forced now.
- **Estimated output:** ~50-150 lines moved (net additive ~0); no new proof.
- **Done when:** the refuted decls are off `NavigatedEndChar.lean`, the preserved reduction family is
  green, `lake build` (whole tree) GREEN, `lean_verify` on a preserved reduction lemma =
  `[propext, Classical.choice, Quot.sound]`.
- **Depends on:** none.
- **Files to modify:** `.../NavigatedEndChar.lean` (archive-edit), `.../Boneyard/NavigatedEndCharSinglePoint.lean` (new).

### Phase 2: Carrier retype + `endInterval_correct` statement freeze + `k=0` base [NOT STARTED]

- **Goal:** Declare `endInterval : (k) → BracketEndCharCarrierV sig k` skeleton (base =
  `bracketEndChar_k0` embedded into VVecEA2; step named `endIntervalStep`, body deferred to Phase 3),
  STATE `endInterval_correct` in the `BracketCarrierCorrectV` / report-06-§4.5 form, and prove the
  **base case** (`k=0`) via `bracketEndChar_k0_correct`.
- **Exact statement to freeze** (report 06 §4.5; the green `BracketCarrierCorrectV` shape,
  CarrierK1V:374; k0-mirror bracket-zone-order conditional, matching `bracketEndChar_k0_correct` and
  `bracketEndChar_k1v_correct`):
  ```lean
  theorem endInterval_correct {sig} (atomMap) (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
      ∀ (k : Nat) (qnf : NormalForm sig k 3) (M : OrderedMonadicStructure sig) (x t : M.carrier)
        (h_xy … h_tx : <the six k0-mirror bracket-zone order bits on qnf's atom layer>),
      (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
        ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
  ```
  (x,t EXPLICIT on BOTH sides — immune to the parameter-independence refutation; NEVER a
  single-point `.eval_at w` on the LHS.)
- **Skeleton to freeze:**
  ```
  endInterval 0     qnf = <bracketEndChar_k0 qnf embedded VecEA2 1 → VVecEA2 (singleton disjunct)>
  endInterval (k+1) qnf = endIntervalStep (endInterval k) qnf   -- Phase 3 hole
  ```
- **Reuse vs rebuild:** REUSE `BracketEndCharCarrierV` (:365), `BracketCarrierCorrectV` (:374),
  `bracketEndChar_k0`/`_correct` (:73/87), `VVecEA2`/`VecEA2` (VecEAFormula:271/252). BUILD only the
  statement + skeleton + the singleton-disjunct embedding + the `k=0` proof.
- **Tasks:**
  - [ ] Define the VecEA2 1 → VVecEA2 singleton-disjunct embedding; confirm it elaborates and its
        `.holds` unfolds to `bracketEndChar_k0`'s `.holds`.
  - [ ] Define the `endInterval` skeleton by `Nat.rec` with the embedded base and a named
        `endIntervalStep` hole (genuine deferred def, not `sorry`/vacuous).
  - [ ] State `endInterval_correct` verbatim in the x,t-explicit VVecEA2 form above.
  - [ ] Prove the `k=0` case via `bracketEndChar_k0_correct` threaded through the singleton-disjunct
        unfolding.
  - [ ] Record (docstring) the FORBIDDEN single-point pointer (`endCharN0_correct_infeasible`,
        Base.lean:1779) and WHY the two-endpoint x,t-explicit carrier is the discriminator (report 07 §5).
  - [ ] Route audit: grep-confirm no `→ TemporalPred` recursion carrier, no `navPieceForm`, no `h_res`;
        git scope = CarrierK1V.lean additive + plan.
- **Estimated output:** ~100-180 lines.
- **Done when:** statement + skeleton + `k=0` base compile sorry-free; `lean_verify` on the base
  lemma = `[propext, Classical.choice, Quot.sound]`; scoped build GREEN.
- **Depends on:** 1.
- **Files to modify:** `.../CarrierK1V.lean` (additive).

### Phase 3: `endIntervalStep` def — the two-endpoint step construction (`k → k+1`) [NOT STARTED]

- **Goal:** Define `endIntervalStep : BracketEndCharCarrierV sig k → BracketEndCharCarrierV sig (k+1)`
  by generalizing the green `bracketEndChar_k1v` (CarrierK1V:433) from the concrete `k=1` to arbitrary
  `k`, with the depth-`k` IH carrier `endInterval k` (VVecEA2) supplying the sub-piece characteristics.
- **Construction (generalize `bracketEndChar_k1v`, faithful to Rabinovich §5):**
  - **Reduce FIRST (Step A):** for each `sub : NormalForm sig k 4`, apply `nfEval_le2_reduction` /
    `endCharStep_quant_reduceA` to expose the ≤2-free-anchor (≤ arity-3) conjunction, witness bound
    (Rabinovich Lem 3.2(2), md:119). NO Formula conversion before reduction.
  - **Characterize each ≤3-anchor depth-`k` conjunct** via the IH carrier `endInterval k` (VVecEA2),
    NOT a closed formula — this is the general-`k` analog of `bracketEndChar_k1v`'s `efold_of_nf1`
    channel (which was k=1-specific).
  - **Assemble** the `k+1` VVecEA2 via `bracketFromLists` (:389): interior-positive `(zone, χ)` content
    on witness slots between the FIXED endpoints `{x,t}` (§5 bracket `[α…](z0,z1)`, md p.7), `segL`/`segR`
    real exclusions (G3), endpoint predicates `epL`/`epR` at the fixed anchors. Model-dependent witness
    order carried by the finite disjunction over arrangements (rule N5).
  - Restore `NegationIndep.lean` (`neg_vecEA2_indep`) here ONLY if the construction references it.
- **Reuse vs rebuild:** REUSE `bracketFromLists`, the k1v building blocks (fold bits shape, zone specs,
  `char`, `lit`, `epL`/`epR`, `segL`/`segR`, gate), Step-A reduction family, and the IH `endInterval k`.
  BUILD only the general-`k` `endIntervalStep` def. Do NOT resurrect `navPieceForm`/`endCharStep`.
- **Tasks:**
  - [ ] Define `endIntervalStep` generalizing `bracketEndChar_k1v` with `endInterval k` in place of the
        depth-0 `char`/fold; anchors FIXED at `{x,t}`, witnesses in disjunct slots (G2/G4).
  - [ ] Confirm arity never climbs past 3 among emitted `nf_eval_nf` facts (Step A caps it).
  - [ ] Route audit: no closed-`Formula` single-point read at `w`; no arity-4 collapse; no per-pair
        `∀ij∃w`; `segL`/`segR` non-trivial (G3); grep clean.
- **Estimated output:** ~150-300 lines (def only; `bracketEndChar_k1v` is ~80 lines at k=1).
- **Done when:** `endIntervalStep` def elaborates green + sorry-free; `endInterval (k+1)` typechecks
  against it; scoped build GREEN; `lean_verify` on the def = `[propext, Classical.choice, Quot.sound]`.
- **Depends on:** 2.
- **Files to modify:** `.../CarrierK1V.lean` (additive; `NegationIndep.lean` restore iff referenced).

### Phase 4: Step correctness — soundness direction (LHS → RHS) [NOT STARTED]

- **Goal:** Prove the LHS→RHS (soundness) direction of the `k+1` case of `endInterval_correct`,
  generalizing `bracketEndChar_k1v_sound` (CarrierK1V, via `k1v_zone_consistent`/`k1v_bracket_extract`)
  from `k=1` to arbitrary `k`, discharging the endpoint hooks from the x,t-explicit IH `endInterval_correct k`.
- **Discharge structure** (report 06 §3.2 Steps A-D; report 07 §5):
  - **Step B** — endpoint/merge via `nf_zone_flatten_navigable_correct` (Base.lean:687), LHS
    `(∃w, nf_eval_nf M k 3 [w,x,t] q)` and RHS both x,t-EXPLICIT (immune to the refutation). Endpoint
    hooks `h_past`/`h_fut` discharged by the depth-`k` IH `endInterval_correct k` (x,t explicit — the
    v5 backwards piece, now correct), NOT a residual-conditioned single-point `endChar k`.
  - **Step C** — interior via the disjunct segment exclusions `segL`/`segR` + `k1v_bracket_extract`
    generalized (interior witnesses pinned strictly between the FIXED endpoints by `IntervalPattern.holds`
    monotonicity, never type-anchored — the refuted device stays dead).
- **Reuse vs rebuild:** REUSE `nf_zone_flatten_navigable_correct`, `k1v_zone_consistent`,
  `k1v_bracket_extract`, `k1v_bool_eq_false` (generalize the `k=1` order-zone arguments to depth `k`),
  the IH `endInterval_correct k`, and Step-A reduction. BUILD the general-`k` soundness lemma.
- **Tasks:**
  - [ ] State + prove `endInterval_step_sound` (LHS→RHS at `k+1`), IH-parametric, manual bridges (G5).
  - [ ] Discharge each interior-positive `(zone, χ)` witness via the disjunct slot + IH; endpoints via
        `nf_zone_flatten_navigable_correct` + IH.
  - [ ] Route audit: no single-point `↔` obligation of shape `temporal_truth w φ ↔ ∃v … [v,w,x,t] sub`
        (that is `navPieceForm_correct` — the STOP signal); anchors ≤2; grep clean.
- **Pre-declared split (bounded-unit guard):** if the direction overruns one run, split at the Step-A
  (reduce) / Step-B (merge) seam. Stop condition: soundness closed OR `[BLOCKED]` + recorded `lean_goal`.
- **Feasibility-gate contingency:** unlike v5 this statement is NON-refuted (green at k=0 AND k=1). If a
  sub-goal cannot close, mark `[BLOCKED]`, record the exact `lean_goal`, `/spawn 349` — do NOT `sorry`,
  vacuous-def, collapse, or regress to the single-point carrier.
- **Estimated output:** ~250-450 lines (load-bearing; split if it overruns).
- **Done when:** `endInterval_step_sound` green + sorry-free; `lean_verify` =
  `[propext, Classical.choice, Quot.sound]`; scoped build GREEN. (Or `[BLOCKED]` per contingency.)
- **Depends on:** 3.
- **Files to modify:** `.../CarrierK1V.lean` (additive).

### Phase 5: Step correctness — completeness (RHS → LHS) + step ↔ assembly [NOT STARTED]

- **Goal:** Prove the RHS→LHS (completeness) direction of the `k+1` case, generalizing
  `bracketEndChar_k1v_complete` (via `k1v_sorted_realization` insertion induction, rule N5) from `k=1`
  to arbitrary `k`, then assemble the full `k+1` biconditional `endInterval_step_correct` from
  soundness (Phase 4) + completeness.
- **Discharge structure:** from `∃w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`, reduce-first (Step A), obtain
  each depth-`k` sub-piece's characteristic from the IH `endInterval_correct k` (RHS→LHS), and realize
  the witness order via the finite disjunction over arrangements (`k1v_sorted_realization` generalized).
- **Reuse vs rebuild:** REUSE `k1v_sorted_realization` (+ the insertion-induction kit),
  `nf_zone_flatten_navigable_correct`, the IH, and Step-A reduction. BUILD the general-`k` completeness
  lemma + the `↔` assembly (mirroring `bracketEndChar_k1v_correct = ⟨_sound, _complete⟩`, CarrierK1V:2054).
- **Tasks:**
  - [ ] State + prove `endInterval_step_complete` (RHS→LHS at `k+1`), IH-parametric, manual (G5).
  - [ ] Assemble `endInterval_step_correct` = `⟨endInterval_step_sound, endInterval_step_complete⟩`.
  - [ ] Route audit: anchors ≤2, witnesses in disjunct slots (G4); no single-point regression; grep clean.
- **Pre-declared split (bounded-unit guard):** if completeness overruns one run, split the insertion
  induction (base arrangement / inductive insertion) from the ↔ assembly. Stop condition: completeness
  closed OR `[BLOCKED]` + recorded `lean_goal`.
- **Feasibility-gate contingency:** same as Phase 4 (non-refuted statement; `[BLOCKED]`+`/spawn`, never fake green).
- **Estimated output:** ~250-450 lines (load-bearing; split if it overruns).
- **Done when:** `endInterval_step_complete` and `endInterval_step_correct` green + sorry-free;
  `lean_verify` = `[propext, Classical.choice, Quot.sound]`; scoped build GREEN. (Or `[BLOCKED]`.)
- **Depends on:** 3, 4.
- **Files to modify:** `.../CarrierK1V.lean` (additive).

### Phase 6: Recursion close + `endInterval_correct` by induction + axiom audit [NOT STARTED]

- **Goal:** Close `endInterval` by `Nat.rec`, prove `endInterval_correct` by induction on `k` (base
  from Phase 2, step from Phase 5), and confirm every definition-of-done gate.
- **Reuse vs rebuild:** REUSE the Phase-2 base, the Phase-5 step (`endInterval_step_correct` as the
  `Nat.rec` step with IH instantiated to `endInterval_correct k`), and `endIntervalStep`. REBUILD nothing.
- **Tasks:**
  - [ ] Confirm `endInterval = Nat.rec <embedded bracketEndChar_k0> (fun k rec => endIntervalStep rec)`
        genuinely recurses (not vacuous).
  - [ ] Prove `endInterval_correct` by induction: base = Phase 2; step = Phase 5 with IH =
        `endInterval_correct k`.
  - [ ] `lean_verify endInterval_correct` (fully qualified) = exactly
        `[propext, Classical.choice, Quot.sound]`; no `sorry`, no new axiom.
  - [ ] Whole-project `lake build` GREEN.
  - [ ] Confirm the FORBIDDEN list (single-point `→TemporalPred` carrier, `navPieceForm(_correct)`,
        `h_res`, arity-4 collapse, per-pair distribution) is absent from the final term; `git status
        --short` shows only the sanctioned scope (CarrierK1V additive, Phase-1 archive, plan/summary) —
        NO frozen-file edits.
  - [ ] Finalize the H3 Tier-1 mapping STATUS column (all rows `transcribed`); grep-confirm
        `endInterval_correct` is a top-level citable name reachable by task 309's re-plan.
- **Estimated output:** ~80-180 lines.
- **Done when:** `endInterval`/`endInterval_correct` sorry-free and green by induction; axiom audit
  exactly `[propext, Classical.choice, Quot.sound]`; whole-tree build GREEN; file scope confirmed;
  309-citable.
- **Depends on:** 5.
- **Files to modify:** `.../CarrierK1V.lean` (additive).

## Testing & Validation

- [ ] Scoped `lake build` of the CarrierK1V module GREEN after every phase (whole-tree GREEN after
      Phases 1 and 6).
- [ ] `lean_verify` on `endInterval_correct`, `endInterval_step_correct` (and `_sound`/`_complete`),
      `endIntervalStep`, and `endInterval` = exactly `[propext, Classical.choice, Quot.sound]`, no
      `sorry`, no new axiom.
- [ ] `endInterval_correct` is the two-endpoint, x,t-EXPLICIT form (report 06 §4.5 /
      `BracketCarrierCorrectV`), x,t on BOTH sides — NEVER a single-point `.eval_at w` LHS, NEVER the
      `h_res`-conditioned form, NEVER `endCharN0_correct_infeasible`'s shape.
- [ ] The arity-4 inner existential is reduced to ≤3-anchor pieces (Step A) BEFORE characterization;
      each depth-`k` sub-piece is characterized by the IH carrier `endInterval k` (VVecEA2), never a
      closed formula read at `w`.
- [ ] Anchors stay `{x,t}` (≤2); `w` and disjunct witnesses are bracket witnesses, never a third free
      anchor (G2/G4); `segL`/`segR` non-trivial (G3); manual bridges only (G5).
- [ ] The refuted single-point scaffold (`endChar`/`endCharStep`/`navPieceForm`/`endChar_correct*`) is
      archived to `Kamp/Boneyard/`; the preserved Step-A reduction family survives green.
- [ ] No occurrence of `navPieceForm(_correct)`, `h_res` residual-threading, arity-4 collapse, or the
      single-point `→TemporalPred` recursion carrier in new code.
- [ ] `git status --short` shows only `CarrierK1V.lean` (additive), `NavigatedEndChar.lean`
      (archive-edit), the new `Boneyard/` file, and plan/summary — NO frozen-provider, NO
      `KampPrior.lean`, NO `Lemma32Reduction.lean`, NO change to `nf_nvar_exist_all_depths`'s signature.
- [ ] `endInterval`/`endInterval_correct` are top-level, name-citable declarations for task 309's re-plan.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the FOUR strikes of the single-point
non-theorem (reports 04/06/07 H5 divergence audits), the carrier-type root cause, and the two
converging audits. Landing any forbidden construct is a `[BLOCKED]` escalation, never a silent workaround.

**The four strikes (H5 root cause).** `navBrickForm` → `navMultiAnchorForm` → `navPieceForm` → v5
`endCharStep`-via-`navPieceForm` (the `h_res` re-freeze) were **the same non-theorem four times**: each
kept the single-point `EndCharCarrier := NormalForm sig k 3 → TemporalPred` carrier (Base.lean:1007)
and re-patched the anchor layer differently. The invariant defect lives in the **carrier TYPE**, not any
converter's internals: a one-point object (function of `w` alone) asked to characterize a
two-free-variable object (function of `w,x,t`). It applies Rabinovich's Prop-3.5 single-point collapse
(one free variable, md:137) at TWO free variables. Machine-refuted by `endCharN0_correct_infeasible`
(Base.lean:1779) — a concrete 2-point countermodel deriving `False` — which survives the `h_res` escape
at every `k ≥ 1` because the depth-0 atom-residual cancellation structurally cannot fire at the `k+1`
quant layer (different arity: `AtomKind sig 3` residual vs `NormalForm sig k 4` sub-evaluation).

**Do NOT**:
- Re-introduce the single-point `EndCharCarrier→TemporalPred` recursion carrier, or any recursion
  motive whose value is read at a single world `w`. The carrier is `→ VVecEA2` (x,t explicit), full stop.
- State `navPieceForm_correct` or any single-point closed-formula `↔` for a ≥2-free-anchor quant target
  (shape `temporal_truth w φ ↔ ∃v nf_eval_nf … [v,w,x,t] sub`) — machine-checked non-theorem (report 04
  §2.1; report 06 §SQ2). If a goal of this shape appears, the carrier has regressed: STOP.
- Introduce an `h_res` (atom-residual) hypothesis to pin the anchors — it has no Rabinovich analogue
  (report 07 §3.3) and is a non-theorem to thread (report 06 §SQ3). The second endpoint is a genuine
  explicit free variable, not a residual.
- Use an arity-4 enclosing-pair collapse, a single-pair arity-4→3 forgetting collapse
  (`Lemma32Reduction.lean:290-306`), or any `nfRestrict`-based arity collapse — machine-checked
  non-theorems (report 04).
- Use the naive per-pair `∀ij∃w` distribution (non-theorem for `n ≥ 3`). The single witness stays
  outside the reduced inner form (order-theoretic `∃w ∀ij`); Step A reduces arity FIRST, witness bound.
- Fake green with `sorry`, `def X := True`/`Unit`/`trivial`, or a `simp`/`omega`/`aesop` shortcut that
  silently weakens the RHS. A stuck main target is `[BLOCKED]` + `lean_goal` record + `/spawn 349`.

**MUST preserve** (green, do not rebuild or regress — see Preserved Assets table):
- The faithful carrier machinery: `BracketEndCharCarrierV`/`BracketCarrierCorrectV`,
  `bracketEndChar_k0`/`_correct`, `bracketEndChar_k1v`/`_correct` (+`_sound`/`_complete`),
  `bracketFromLists`, and the ~1500-line k1v helper kit.
- The Step-A reduction family: `nfEval_le2_reduction`, `nfEval3_reduction`/`nfEval4_reduction`(+shapes),
  `endCharStep_reduceA`/`_quant_reduceA`, `navPiece_reduce`, `endCharNav0_correct`.
- Base machinery: `nf_zone_flatten_navigable`/`_correct`/`_brick`, `nf_3var_bracket_xyt`/`_correct`,
  `nf_depth0_char_formula`/`_correct`, `formula_conjList`/`_iff`.
- The negative guardrail `endCharN0_correct_infeasible` (document WHY the single-point form is forbidden).

**Design decisions are SETTLED** (do not re-open without a concrete machine-checked counterexample):
- **The recursion carrier is `BracketEndCharCarrierV` (VVecEA2), x,t EXPLICIT** (reports 06 §4.4/§4.5,
  07 §5). The single-point `TemporalPred` appears ONLY at the ≤1-free base (`bracketEndChar_k0`) and at
  the downstream (309) top-level extraction — never inside the recursion. The `EndCharCarrier` freeze
  is LIFTED (two-audit justification, "Scope change" above).
- **Reduce arity FIRST (Step A), characterize each sub-piece via the IH carrier `endInterval k`** —
  never convert to a closed formula before the ≤1-free base. Lemma 3.2(2) caps ANCHORS at ≤2 (a
  TYPE-level invariant of `VVecEA2.holds`); witness growth is licensed (§5 bracket, Lemma 3.4), anchor
  growth is not.
- **Endpoint hooks are discharged by the x,t-explicit IH `endInterval_correct k`** (report 06 §SQ2 wall
  2: v5 had this backwards), NOT by a residual-conditioned single-point `endChar k`.
- **The general-`k` step is a proof-engineering obligation on a NON-refuted, green-at-k=0-and-k=1
  statement** — categorically unlike v5's non-theorem dead-end. It is `[BLOCKED]`+`/spawn` on failure,
  never `sorry`.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` — additive: the
  `endInterval` skeleton + `endInterval_correct` statement + `k=0` base (Phase 2), `endIntervalStep`
  (Phase 3), step soundness (Phase 4), step completeness + ↔ assembly (Phase 5), recursion close +
  induction (Phase 6).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NavigatedEndChar.lean` — archive-edit
  (refuted single-point scaffold removed; Step-A reduction family retained).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/NavigatedEndCharSinglePoint.lean` — new
  (refuted scaffold, header note citing reports 04/06/07).
- (conditional) `.../Kamp/NegationIndep.lean` / `RabinovichTranslation.lean` restored from Boneyard iff
  the step references them.
- `specs/349_.../plans/06_faithful-two-endpoint-carrier.md` (this plan; supersedes plans/05).
- `specs/349_.../summaries/06_faithful-two-endpoint-carrier-summary.md` (on completion).

## Rollback/Contingency

- Work is confined to additive edits in `CarrierK1V.lean`, an archive-edit of `NavigatedEndChar.lean`,
  and Boneyard file moves; the seven frozen providers, `Lemma32Reduction.lean`, and `KampPrior.lean` are
  never touched, so no green asset can be lost by a v6 rollback. Snapshot before any intentional rollback
  (`bash .claude/scripts/git-snapshot.sh` first, per "No Destructive Git on Uncommitted Work").
- Each green phase (and each pre-declared sub-split) is committed as it lands (commit-per-green-substep
  mandate); no progress is lost across dispatches.
- **Phase 4/5 feasibility gate**: if a proof direction cannot close green without a forbidden construct,
  mark the phase `[BLOCKED]`, record the exact `lean_goal`, return `status: partial` with
  `requires_user_review: true`, and `/spawn 349` for the specific missing sub-lemma. Do NOT land a
  vacuous, `sorry`'d, single-point, collapse, or per-pair-distributed `endInterval`. Note: the statement
  is green at k=0 AND k=1, so a block here is a proof-engineering gap on a proven-inhabited carrier, not
  a non-theorem — the escalation seeks the missing generalization lemma, never a carrier-type change.
