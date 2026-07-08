# Implementation Plan: Corrected k=2 Carrier via the Navigated / Witness-Growing Route (v6 REDESIGN)

- **Task**: 321 - Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Status**: [NOT STARTED]
- **Effort**: ~16 hours (8 phases; the make-or-break navigated-fold spine is Phase 2, tested early; heavy reuse of landed assets keeps this below a from-scratch estimate)
- **Dependencies**: 320 (route design spec, COMPLETED). 325 (VVecEA2 arity-4 pair, COMPLETED). 326 (interior closers `kvE_subBracket2V_sound_of_outer`/`_complete`, COMPLETED). **330 (faithfulness audit — the PRIMARY BASIS for this redesign, COMPLETED)**. Folds in the redefined scope of former tasks 328 and 329 (both [ABANDONED]; NOT re-spawned — see "Folded-In Scope" below).
- **Research Inputs**:
  - specs/330_k2_carrier_faithfulness_audit_and_correct_fold_representation/reports/01_faithfulness-audit-fold-representation.md (PRIMARY — the REDESIGN mandate)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (position-by-evaluation-point litmus)
  - /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (GROUND TRUTH — Def 3.1/4.1, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Cor 5.4)
- **Artifacts**: plans/06_corrected-k2-carrier-gate-v6-redesign.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/state-management.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4

## Overview

Task 330's PDF-verified faithfulness audit determined that the entire v1–v5 route rested on a
**mis-citation**: the "constant-arity E[Sigma]-fold (Def 4.1)" cited by report 05 and prior plans
does not exist in Rabinovich 2014. **Definition 4.1 (p.5) is the E[Sigma] ALPHABET EXPANSION**
(TL-formulas-as-unary-atoms), not a fold. The real fold is **Prop 3.5 / Cor 5.4**: a *navigated*
(nested `Until`/`Since`) characteristic over **FLAT** exists-forall blocks with **quantifier-free**
point types (Lemma 5.1, p.7); higher FO quantifier depth is discharged by **structural induction**
(Prop 4.3, p.6), never by nesting a depth-k characteristic. The prior static arity-1 E-atom
(`EAtomDom := ZoneSpec n x NormalForm sig k 1`, NfEFold:69) is a **category error at k>=1**: the
recurring wall — G6 (:1609–1641), F4 (:5689–5765), and the k=2 NO-GO (327, :8760–8825) — is ONE
obstruction: an arity-1 monadic channel cannot carry an inner witness's joint coupling to multiple
anchors (goal needs `ZoneSpec 4`, channel supplies `ZoneSpec 1`).

v6 REDESIGNS around the navigated / witness-growing route the audit found faithful. It **drops**
every phase depending on the refuted constant-arity infrastructure, **consumes** the already-landed
assets the audit identified (the witness-growing carrier `BracketCarrierCorrectV`, the LANDED
Prop 4.2 negation closure `neg_2var_vec_ea`, and the task-326 interior closers), **adds** the one
missing ingredient (the Prop 4.3 re-flatten structural-induction wiring), and **folds in** the
redefined scope of the now-abandoned prerequisite tasks 328 (navigated witness-growing fold) and 329
(per-arrangement non-interior dischargers). Phase 15 of v5 (the F4 `ℤ` adversarial gate + verdict
record) is preserved as the downstream consumer (now Phase 8). **Definition of done:** the k=2
`BracketCarrierCorrectVPrior` gate closes both directions over the navigated route, the F4 `ℤ`
counterexample fails against the new carrier, the build is green with no `sorry` on any live path,
and every do-not-edit asset is byte-identical.

### Research Integration

This plan integrates report 330 (`reports/01_faithfulness-audit-fold-representation.md`) as its
primary basis. The audit's Part 2 §4 "correct NormalForm/carrier shape" and the "Corrected
Lean-ready targets" (report §H5) supply the exact signatures below. The v5 phase skeleton is
consumed only for continuity of the do-not-edit list, the F4 `ℤ` adversarial test, and the verdict
record house style.

### Folded-In Scope (former tasks 328 / 329, NOT re-spawned)

- **Former task 328** (was: constant-arity depth-1 split-kit + k=2 quant-layer fold engine —
  REFUTED premise) → REDEFINED as the **navigated witness-growing fold** itself: the Prop 4.3
  re-flatten induction over flat exists-forall blocks (Phases 3–4).
- **Former task 329** (was: non-interior 5-zone dischargers over the constant-arity channel —
  REFUTED premise) → REDEFINED as the **per-arrangement `VVecEA2` non-interior dischargers**
  (soundness + completeness) for the 5 non-interior zones `zPastX` / `zAtX` / `zAtW` / `zAtT` /
  `zFutT`, over the `VVecEA2` channels rather than per-`(zone, χ : NormalForm sig 1 1)` obligations
  (Phases 5–6).

## Goals & Non-Goals

- **Goals**:
  - Establish the navigated-fold spine (`kvE_fold_navigated` over `BracketCarrierCorrectV`) and
    test the make-or-break early (Phase 2).
  - Wire the Prop 4.3 re-flatten structural induction — the currently MISSING ingredient — using
    the LANDED Prop 4.2 negation closure `neg_2var_vec_ea` (Phase 3).
  - Complete the navigated witness-growing fold engine over all arrangements (Phase 4, folds in 328).
  - Discharge the 5 non-interior zones per-arrangement, both directions (Phases 5–6, folds in 329).
  - Close the k=2 `BracketCarrierCorrectVPrior` gate both directions over the navigated route
    (Phase 7), reusing the task-326 interior closers for the interior zones.
  - Discharge the F4 `ℤ` adversarial counterexample against the new carrier and land the GO verdict
    record (Phase 8, preserved from v5 Phase 15).

- **Non-Goals**:
  - Do NOT build or consume any refuted constant-arity infrastructure: `nfk_assemble` /
    `nfk_dropFresh` / `nfk_zoneSpec` (never existed — do NOT create), `nf_eval_nf1_cons_factor`,
    `efold_of_nfk`, or the constant-arity fold engine `nf_quant_layer_fold_k2_gate`.
  - Do NOT re-attempt any static arity-1 characteristic fold (327 refuted it; the audit shows it is
    unfaithful).
  - Do NOT edit any do-not-edit asset (see Preserved-Assets table) — all new work PURELY ADDITIVE.
  - Do NOT introduce an `x1 < e_i` relative-position literal (LITMUS — reconstruction rides the
    evaluation point / structural position, never a two-anchor single-point identity).
  - Do NOT re-spawn tasks 328/329 — their redefined scope is folded into the phases below.

## Risks & Mitigations

- **Risk:** The navigated fold spine (Phase 2) fails to discharge `BracketCarrierCorrectV` for the
  k>=1 instance even on the interior fragment. **Mitigation:** This is the make-or-break, placed
  earliest by design (H8). If it cannot close within one dispatch, escalate immediately to the
  RE-SCOPE fallback (narrow `BracketCarrierCorrectVPrior` to the interior + boundary fragment already
  reachable via task 326 + `epL`/`epR`/`ptW` point channels, deferring exterior-navigated
  completeness) — do NOT churn on the constant-arity route.
- **Risk:** Prop 4.3 re-flatten induction (Phase 3) requires a lemma beyond the landed
  `neg_2var_vec_ea` (e.g. the existential step, Lemma 3.4). **Mitigation:** scope Phase 3 to the
  negation + disjunction steps that `neg_2var_vec_ea` + landed `VVecEA2` machinery already support;
  isolate any genuinely-missing existential-closure lemma as a strategic sorry with a follow-up,
  not a silent stall.
- **Risk:** Per-arrangement dischargers (Phases 5–6) blow up combinatorially
  (`S_L.permutations × S_R.permutations`). **Mitigation:** factor the arrangement induction once and
  reuse per zone; keep each of the 5 zones to a shared discharger schema. If a single phase exceeds
  ~500 lines, split soundness/completeness across the two phases already allocated (5 = soundness,
  6 = completeness).
- **Risk:** An additive edit accidentally perturbs a do-not-edit asset. **Mitigation:** Phase 1
  captures a byte-identity snapshot; Phase 8 re-verifies `git diff` is additive-only against the
  baseline SHA. Every phase runs a scoped build.
- **Risk:** Deflection into analysis (this is v6 after 5 non-converging versions). **Mitigation:**
  each phase has a concrete green stopping condition (a sorry-free Lean object + green build);
  analysis-only output is not an acceptable phase result (H2).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel (Phases 5 and 6 own disjoint lemma
territory — soundness names vs completeness names — over the same additive file region, per H7).

### Phase 1: Baseline snapshot + refuted-infrastructure quarantine [COMPLETED]

- **Goal:** Capture a byte-identity baseline for every do-not-edit asset, record the baseline git
  SHA, and formally confirm no live path depends on the refuted constant-arity infrastructure that
  v6 drops.
- **Tasks:**
  - [ ] Record the baseline commit SHA and a hash snapshot of the do-not-edit assets (task-325
        VVecEA2 block, task-326 pin-slot block, `kvE2_body`/`bracketEndChar_kvE2` splice,
        `kvE_subChain2V`, `BracketCarrierCorrectVPrior`, `EANegation` :1090/:1249, F1–F4 records).
  - [ ] Confirm (grep + `lean_build`) that `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` do not
        exist and are not referenced; confirm `nf_eval_nf1_cons_factor` / `efold_of_nfk` /
        `nf_quant_layer_fold_k2_gate` are inert doc/NO-GO records with 0 live `sorry`, and mark them
        explicitly DROPPED (no v6 phase consumes them).
  - [ ] Verify `BracketEndCharCarrierV` (:1872) / `BracketCarrierCorrectV` (:1881),
        `neg_2var_vec_ea` (EANegationClosure.lean:722), `kvE_subChain2V` (:6955),
        `kvE_subBracket2V_sound_of_outer` (:7910), `_complete` (:8159) are present with the expected
        signatures (the consumed-assets list).
- **Timing:** ~1 hour. **Depends on:** none.
- **Files:** `NfMultiAnchorBridge.lean` (read-only this phase; append a short quarantine note block).
- **Green stopping condition:** Baseline SHA + asset hashes recorded; consumed-asset signatures
  confirmed; refuted-infra confirmed inert and quarantined; `lake build` green.

### Phase 2: Navigated-fold SPINE — `kvE_fold_navigated` over the interior fragment (MAKE-OR-BREAK) [NOT STARTED]

- **Goal:** State and prove the navigated-fold spine for the interior fragment, establishing that
  the witness-growing carrier `BracketCarrierCorrectV` discharges the k>=1 instance via navigation
  (Until/Since reach) rather than a static arity-1 channel. This is the earliest test of the whole
  redesign.
- **Tasks:**
  - [ ] State `kvE_fold_navigated` (audit §H5 target 2): for `qnf : NormalForm sig k 3`,
        `(BracketEndCharCarrierV-instance qnf).holds M atomMap x t ↔
        ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`, over the `VVecEA2`
        witness-growth — NOT a per-`(zone, χ:NormalForm sig 1 1)` reduction.
  - [ ] Prove the interior-fragment instance by consuming the task-326 interior closers
        (`kvE_subBracket2V_sound_of_outer` / `_complete`) and the navigated literals
        (`epL`/`epR`, `bracketBuildLeft`/`bracketBuildRight`, :1676–1739). Cite Prop 3.5 / Cor 5.4
        (md:87–94, md:154–157) at each chain step (G5).
  - [ ] Confirm the reconstruction rides the evaluation point of the nested temporal operators
        (LITMUS: no `x1 < e_i` literal anywhere in the body).
- **Timing:** ~3 hours. **Depends on:** 1.
- **Files:** `NfMultiAnchorBridge.lean` — append `kvE_fold_navigated` (interior fragment).
- **Green stopping condition:** `kvE_fold_navigated` interior instance is sorry-free, axiom-clean
  (`propext`, `Classical.choice`, `Quot.sound` via `lean_verify`), scoped build green. **If it
  cannot close in one dispatch, STOP and escalate to the RE-SCOPE fallback — do NOT revert to a
  constant-arity attempt.**

### Phase 3: Prop 4.3 re-flatten structural induction wiring (ADD the missing ingredient) [NOT STARTED]

- **Goal:** Wire the Prop 4.3 induction that discharges higher FO quantifier depth by re-flattening
  to a disjunction of flat exists-forall blocks — never by nesting a depth-k characteristic. This is
  the ingredient the audit's H3 table marks MISSING.
- **Tasks:**
  - [ ] State the re-flatten lemma: every higher-depth obligation reduces to a `∨` of flat
        exists-forall blocks over the E[Sigma] alphabet with quantifier-free point types (Lemma 5.1,
        md:134–135). Cite Prop 4.3 (md, p.6) at the induction skeleton.
  - [ ] Discharge the negation step by consuming the LANDED `neg_2var_vec_ea`
        (EANegationClosure.lean:722, Prop 4.2) — the hardest step, already proven.
  - [ ] Discharge the disjunction/base steps over the landed `VVecEA2` machinery. If the
        existential step (Lemma 3.4) needs an unlanded lemma, isolate it as a single strategic sorry
        with a declared follow-up (do not silently stall) and record it in Testing & Validation.
- **Timing:** ~2.5 hours. **Depends on:** 2.
- **Files:** `NfMultiAnchorBridge.lean` — append the re-flatten induction wiring.
- **Green stopping condition:** re-flatten lemma sorry-free on the live path (or a single declared
  strategic sorry with follow-up), consuming `neg_2var_vec_ea`; no nested depth-k characteristic
  introduced; scoped build green.

### Phase 4: Navigated witness-growing fold engine — full carrier (folds in former 328) [NOT STARTED]

- **Goal:** Complete `kvE_fold_navigated` over the FULL carrier (all arrangements), realizing the
  Prop 3.5 / Cor 5.4 nested Until/Since fold over flat exists-forall blocks with witness growth —
  the object former task 328 was redefined to build.
- **Tasks:**
  - [ ] Extend Phase 2's interior spine to all arrangements: witness lists grow per disjunct
        (`S_L.permutations × S_R.permutations`, :1929–1931); the fold is the navigating Until/Since
        chain `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ …))` (Prop 3.5 fold, md:87–94; Cor 5.4, md:154–157).
  - [ ] Compose with the Phase 3 re-flatten induction so higher FO depth is discharged by
        re-flattening, not nesting.
  - [ ] Keep anchors capped at 2 (Lemma 3.2(2), md:76–79; `VecEAFormula:276` type invariant);
        witness block grows but is jointly ordered with quantifier-free types.
- **Timing:** ~3 hours. **Depends on:** 3.
- **Files:** `NfMultiAnchorBridge.lean` — append the full navigated fold engine.
- **Green stopping condition:** the navigated fold engine closes its stated direction over the full
  `VVecEA2` witness-growth, sorry-free on the live path, axiom-clean, scoped build green; LITMUS
  respected (positions by evaluation point / Until-Since reach).

### Phase 5: Per-arrangement non-interior dischargers — SOUNDNESS (folds in former 329) [NOT STARTED]

- **Goal:** Discharge the soundness direction of the 5 non-interior zones (`zPastX`, `zAtX`,
  `zAtW`, `zAtT`, `zFutT`) per-arrangement over the `VVecEA2` channels — the object former task 329
  was redefined to build (soundness half).
- **Tasks:**
  - [ ] Factor a shared per-arrangement soundness discharger schema over the `VVecEA2` channels
        (`epL`/`epR`/`ptW` + navigation reach), NOT per-`(zone, χ:NormalForm sig 1 1)`.
  - [ ] Instantiate the schema for each of the 5 non-interior zones; exterior-zone witnesses
        (`zPastX`/`zFutT`) positioned by `Since`/`Until` reach (LITMUS: never an `x1 < e_i` literal).
  - [ ] Cite Prop 3.5 navigation at each zone's chain step (G5).
- **Timing:** ~2 hours. **Depends on:** 4.
- **Files:** `NfMultiAnchorBridge.lean` — append the 5 soundness dischargers (distinct `_sound`
  names; disjoint territory from Phase 6).
- **Green stopping condition:** all 5 non-interior soundness dischargers sorry-free, axiom-clean,
  scoped build green.

### Phase 6: Per-arrangement non-interior dischargers — COMPLETENESS (folds in former 329) [NOT STARTED]

- **Goal:** Discharge the completeness direction of the same 5 non-interior zones per-arrangement
  over the `VVecEA2` channels — the completeness half of the redefined former task 329.
- **Tasks:**
  - [ ] Factor a shared per-arrangement completeness discharger schema (order bits + `hcharK`
        threaded at the integration site) over the `VVecEA2` channels.
  - [ ] Instantiate for each of the 5 non-interior zones; consume the arrangement disjunct output.
  - [ ] Cite Prop 3.5 / Cor 5.4 at each chain step (G5); LITMUS respected.
- **Timing:** ~2 hours. **Depends on:** 4. **Parallel with:** 5 (disjoint lemma names).
- **Files:** `NfMultiAnchorBridge.lean` — append the 5 completeness dischargers (distinct
  `_complete` names).
- **Green stopping condition:** all 5 non-interior completeness dischargers sorry-free, axiom-clean,
  scoped build green.

### Phase 7: Gate assembly — close `BracketCarrierCorrectVPrior` both directions [NOT STARTED]

- **Goal:** Assemble the k=2 `BracketCarrierCorrectVPrior` gate to a proven GO in both directions
  over the navigated route: interior zones via the task-326 closers, non-interior zones via
  Phases 5–6, glued by the Phase 4 navigated fold and Phase 3 re-flatten induction.
- **Tasks:**
  - [ ] Soundness assembly: combine interior (`kvE_subBracket2V_sound_of_outer`) + non-interior
        (Phase 5) + navigated fold; NO reverse `fChainPred → .holds` lift; NO provider-side pinning
        (Amendment F3 still binding); no residual `w = e 1` / `x = e 2`.
  - [ ] Completeness assembly: combine interior (`kvE_subBracket2V_complete`) + non-interior
        (Phase 6) + navigated fold; order bits + `hcharK` discharged at the integration site.
  - [ ] Confirm the gate consumes `BracketCarrierCorrectVPrior` byte-identically (do-not-edit) and
        the assembly is purely additive.
- **Timing:** ~2 hours. **Depends on:** 5, 6.
- **Files:** `NfMultiAnchorBridge.lean` — append the gate-close theorem (both directions).
- **Green stopping condition:** k=2 gate closes both directions, sorry-free on the live path,
  axiom-clean, scoped build green; `BracketCarrierCorrectVPrior` untouched.

### Phase 8: F4 `ℤ` adversarial LHS-FALSE + integrity sweep + GO verdict record (preserved from v5 Phase 15) [NOT STARTED]

- **Goal:** Discharge the mandatory F4 `ℤ` adversarial counterexample against the now-closed gate
  over the new navigated carrier, run the full integrity sweep, and land the final GO verdict —
  the deliverable that unblocks task 309 Phase 13.4/14.
- **Tasks:**
  - [ ] Instantiate the F4 `ℤ` counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` marked false) against the navigated
        carrier and prove the LHS is FALSE at `(10,20)` — the test MUST fail against the new carrier.
        If the LHS still holds, the completeness wiring lost the discriminating dependence — return
        to Phases 5–7; do NOT weaken the test.
  - [ ] Land the final GO verdict record (F1–F4 house style): navigated route realized;
        `kvE_fold_navigated` + Prop 4.3 induction + per-arrangement dischargers wired; k=2
        `BracketCarrierCorrectVPrior` closed both directions; F4 discriminated; citations per G5.
  - [ ] Byte-identity sweep: `git diff` against the Phase-1 baseline SHA shows a pure additive
        delta; every do-not-edit asset unchanged; no other landed file touched (edits confined to
        `NfMultiAnchorBridge.lean`, plus `EANegationClosure.lean` / `NfEFold.lean` only if consuming,
        never editing).
  - [ ] Full `lake build` green; no `sorry` on any live path; all new symbols axiom-clean via
        `lean_verify`; no `simp`/`omega`/`aesop` in chain-construction bodies (only `by omega` for
        `Fin`-index/length typing).
- **Timing:** ~1.5 hours. **Depends on:** 7.
- **Files:** `NfMultiAnchorBridge.lean` — append the F4 `ℤ` LHS-FALSE lemma + final verdict record.
- **Green stopping condition:** F4 `ℤ` LHS FALSE proven; full build green; `git diff` additive-only;
  do-not-edit assets byte-identical; axiom-clean; GO verdict record landed.

## POSTMORTEM — Failure Lineage (v1–v5) and the ONE Invariant v6 Changes

This is v6 after **five non-converging versions**. Per task 330's audit, all five shared a single
refuted assumption; the redesign changes exactly one architectural invariant.

### What each prior version assumed (and what the audit refuted)

| Version | Core assumption (all built on the constant-arity static carrier) | Refuted by (task 330) |
|---------|--------------------------------------------------------------------|------------------------|
| v1 / v2 (`01`, `02`) | A flat successor-parameterized `kvE2` carrier with forced k1v encoding folds the depth-2 obligation per-sub. | The obligation does NOT factor into per-`(zone, χ:NormalForm sig 1 1)` monadic pieces (case C); the flat carrier is the exact shape F3/F4 refuted. |
| v3 (`03`) | Decomposing the BLOCKED Stage C/D soundness/completeness into smaller dispatches over the same constant-arity channel would close the gate. | Decomposition cannot rescue a channel that structurally cannot carry the joint coupling (`ZoneSpec 4` needed, `ZoneSpec 1` supplied). |
| v4 (`04`) | Wiring task-325's VVecEA2 arity-4 pair into `kvE2_body`/`bracketEndChar_kvE2` supplies the missing arity. | The arity-4 pair was still consumed through the arity-1 `EAtomDom` factorization — the category error, not the fix. |
| v5 (`05`) | Re-pointing Stage C soundness at task-326's bounded pin-slot composition sidesteps the reverse-Cor-5.4 wall. | Correct as a bounded-composition lemma, but still assembled over the refuted constant-arity fold engine (Phase 10 BLOCKED on the "missing general-j=1 outer quant-layer fold engine" — which the audit shows should never be built). |

**Root cause (audit §H5 postmortem):** the design adopted a **Doets nested depth-indexed** normal
form plus a **static constant-arity** fold, citing Rabinovich Def 4.1 / Prop 4.3 as the
faithfulness warrant — but **Def 4.1 is an alphabet expansion, not a fold**, and Rabinovich's
actual fold (Prop 3.5) is **navigated**, over **flat** exists-forall blocks with
**quantifier-free** point types, depth handled by **re-flattening induction** (Prop 4.3). G6 was a
self-imposed guard that fought the source. Every attempt to avoid navigation re-hit the same
arity-4 residual.

### The ONE invariant v6 changes

> **Reconstruction is NAVIGATED / witness-growing — never a static arity-1 characteristic.** The
> inter-anchor coupling is carried by the EVALUATION POINT / structural position of nested
> `Until`/`Since` operators (Prop 3.5 / Cor 5.4), with higher FO depth discharged by Prop 4.3
> re-flatten induction. **LITMUS (binding):** no `x1 < e_i` relative-position literal ever appears;
> reconstruction rides the evaluation point, never a two-anchor single-point identity.

Everything else (anchor cap ≤2, purely additive, byte-identical do-not-edit assets, no
provider-side pinning per Amendment F3, G5 citations at every chain step) is preserved from v5.

## Preserved-Assets Table

### CONSUMES (landed lemmas v6 builds on — do NOT rebuild)

| Asset | file:line | Role in v6 |
|-------|-----------|------------|
| `BracketEndCharCarrierV` | NfMultiAnchorBridge.lean:1872 | The witness-growing carrier type (`NormalForm sig k 3 → VVecEA2`). |
| `BracketCarrierCorrectV` | NfMultiAnchorBridge.lean:1881 | Correctness spec discharged by the navigated fold (Phases 2, 4). |
| `neg_2var_vec_ea` | EANegationClosure.lean:722 | Prop 4.2 negation closure — the hardest landed step; consumed by Phase 3. |
| `kvE_subBracket2V_sound_of_outer` | NfMultiAnchorBridge.lean:7910 | Task-326 interior soundness closer (Phases 2, 7). |
| `kvE_subBracket2V_complete` | NfMultiAnchorBridge.lean:8159 | Task-326 interior completeness closer (Phases 2, 7). |
| `epL`/`epR`, `bracketBuildLeft/Right` | NfMultiAnchorBridge.lean:1676–1739 | Navigated fold literals (Until/Since reach). |
| `VVecEA2` / `VecEAFormula` anchor cap | VecEAFormula:276 | ≤2-anchor type invariant (Lemma 3.2(2)). |

### ADDS (new, purely additive)

| New object | Phase | Rabinovich basis |
|------------|-------|-------------------|
| `kvE_fold_navigated` (interior spine) | 2 | Prop 3.5 / Cor 5.4 |
| Prop 4.3 re-flatten structural induction wiring | 3 | Prop 4.3, using Prop 4.2 |
| `kvE_fold_navigated` full engine (folds in 328) | 4 | Prop 3.5 fold + Prop 4.3 |
| 5 non-interior soundness dischargers (folds in 329) | 5 | Prop 3.5 navigation |
| 5 non-interior completeness dischargers (folds in 329) | 6 | Prop 3.5 / Cor 5.4 |
| k=2 gate-close (both directions) | 7 | Lemma 5.3 / Cor 5.4 |
| F4 `ℤ` LHS-FALSE + GO verdict record | 8 | (adversarial gate) |

### DROPS (refuted infrastructure — do NOT build or consume)

`nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` (never existed), `nf_eval_nf1_cons_factor`,
`efold_of_nfk`, the constant-arity fold engine `nf_quant_layer_fold_k2_gate`, and the `EAtomDom`
static arity-1 factorization (`NfEFold.lean:69`) as a live path.

### DO-NOT-EDIT (byte-identical)

Task-325 landed lemmas, task-326 landed lemmas, `kvE2_body` / `bracketEndChar_kvE2` splice,
`kvE_subChain2V`, `BracketCarrierCorrectVPrior`, `EANegation` (:1090/:1249), F1–F4 verdict records.
All new infrastructure PURELY ADDITIVE to `NfMultiAnchorBridge.lean` (plus `EANegationClosure.lean`
/ `NfEFold.lean` only if consuming, never editing).

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`.
- [ ] Full `lake build` green at Phase 8.
- [ ] Phase 2 make-or-break: `kvE_fold_navigated` interior instance sorry-free BEFORE any later phase.
- [ ] Prop 4.3 re-flatten induction (Phase 3) consumes `neg_2var_vec_ea`; no nested depth-k
      characteristic introduced (any strategic sorry declared with a follow-up).
- [ ] Navigated fold engine (Phase 4) closes over full `VVecEA2` witness-growth; anchors capped ≤2.
- [ ] All 5 non-interior soundness + completeness dischargers (Phases 5–6) sorry-free.
- [ ] k=2 `BracketCarrierCorrectVPrior` gate closes both directions (Phase 7); no reverse
      `fChainPred → .holds` lift; no provider-side pinning (Amendment F3).
- [ ] MANDATORY adversarial test (Phase 8): F4 `ℤ` counterexample (`char[14,16,11,20]` vs honest
      `char[14,15,10,20]`) FAILS against the navigated carrier (LHS FALSE at `(10,20)`).
- [ ] LITMUS: no `x1 < e_i` relative-position literal anywhere on any live path.
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry` on
      any live path.
- [ ] No `simp`/`omega`/`aesop` in chain-construction bodies; Rabinovich cited at every chain step (G5).
- [ ] Every do-not-edit asset byte-identical; all new work additive against the Phase-1 baseline SHA.

## Artifacts & Outputs

- specs/321_.../plans/06_corrected-k2-carrier-gate-v6-redesign.md (this plan; supersedes v5).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — additive: the navigated
  fold spine + full engine (`kvE_fold_navigated`), the Prop 4.3 re-flatten induction wiring, the 10
  per-arrangement non-interior dischargers (soundness + completeness for 5 zones), the k=2 gate-close
  (both directions), the F4 `ℤ` LHS-FALSE lemma, and the final GO verdict record.
- specs/321_.../summaries/06_corrected-k2-carrier-gate-v6-redesign-summary.md (at completion).

## Rollback/Contingency

- **Additive-only guarantee:** every phase appends to `NfMultiAnchorBridge.lean`; rollback is
  reverting the phase's commit. Do-not-edit assets are never touched, so no landed asset is at risk.
- **RE-SCOPE fallback (audit-sanctioned):** if the navigated fold + Prop 4.3 induction wiring
  exceeds budget (Phase 2 or 4 cannot close in one dispatch), narrow `BracketCarrierCorrectVPrior`
  to the interior-zone + boundary fragment already reachable via task 326 + `epL`/`epR`/`ptW` point
  channels, deferring the full exterior-navigated completeness to a follow-up task. This is a scope
  narrowing, NOT a return to the refuted constant-arity route.
- **No destructive git on uncommitted work:** snapshot before any intentional rollback per
  `.claude/rules/git-workflow.md`.
