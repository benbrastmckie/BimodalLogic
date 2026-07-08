# Implementation Plan: Faithful Separate-Bracket Joint Carrier — Shared-Witness Conjunction and the k=2 Gate (v7)

- **Task**: 321 - Implement corrected k=2 carrier and close the correctness gate (F4 resolution)
- **Status**: [IMPLEMENTING]
- **Effort**: ~15 hours for the open phases (7-13; six implementation dispatches + one decision gate). Phases 1-6 are landed (v6). Estimated 670-1,120 additive lines, per report 07 §3 (650-1,100 band).
- **Dependencies**: 320 (route design spec, COMPLETED). 325 (VVecEA2 arity-4 pair, COMPLETED). 326 (per-σ interior closers, COMPLETED). 330 (faithfulness audit, COMPLETED — the v6 redesign basis). **331 (NfMultiAnchorBridge split + separate-bracket API, COMPLETED — the module landscape this plan is written against)**.
- **Research Inputs**:
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/07_v7-consolidated-faithful-route.md (PRIMARY — coordinate re-map, Candidate A/C signatures, O1-O8 decomposition, H4 caveats, N1/N2 fallback spec)
  - specs/330_k2_carrier_faithfulness_audit_and_correct_fold_representation/reports/01_faithfulness-audit-fold-representation.md (the v6 redesign mandate, carried forward)
  - specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md (position-by-evaluation-point litmus, carried forward)
  - specs/331_refactor_nfmultianchorbridge_split_and_separate_bracket_api/summaries/01_split-summary.md (module inventory, import DAG, handoff notes)
  - /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (GROUND TRUTH — Def 3.1/4.1, Lemma 3.2, Lemma 3.4, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Cor 5.4)
- **Artifacts**: plans/07_v7-faithful-separate-bracket.md (this file; supersedes plans/06_corrected-k2-carrier-gate-v6-redesign.md)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/state-management.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4

## Overview

v6 landed its Phases 1-6 (navigated spine, Prop 4.3 re-flatten engine, arrangement membership
collapse, 10 non-interior dischargers) and then hit a machine-precise wall at Phase 7: the k=2
gate `BracketCarrierCorrectVPrior` cannot close over the quarantined MERGED carrier
(`kvE2_body`'s `slotsFor` splice concatenates every positive sub's chain into one point-type
list carrying union/existential zone content, so the per-σ `hgate` the task-326 closers require
is underivable). Task 331 then split the 9,249-line monolith into 10 modules, isolating the
faithful separate-bracket API (`SubBracket2V.lean` + `NavigatedSpine.lean`) from the merged-route
dead code (`MergedQuarantine.lean`, off-limits).

v7 replaces the blocked v6 Phase 7 with the route report 07 adversarially verified: build the
**one unbuilt object** named by the SubBracket2V API banner (`SubBracket2V.lean:25-27`) — the
shared-interior-witness conjunction `∃ w, ⋀_σ (per-σ realization at that same w)` — as a
concrete, model-independent joint carrier `kvE2_sepBody` (Candidate A, staged via Candidate C),
whose disjuncts are single FLAT brackets: one shared `ptW` slot, per-σ single-point
`charK` E[Σ]-atom slots, joint interleavings per Lemma 3.2(1) (md:77), refined-conjunction
segments, endpoint conjunction at the fixed anchors. Its correctness pair
`kvE2_sepBody_correct_prior` discharges `BracketCarrierCorrectVPrior`
(`PriorInterface.lean:60`). The make-or-break is **O4** — the carrier-side per-σ `hgate`
derivation (the exact residue of the captured crux, `NavigatedSpine.lean:414-421` step (d)) —
scheduled as its own earliest-possible gated phase, with an explicit DECISION GATE phase after
it wired to the N2 single-positive-sub fallback.

**Definition of done:** the k=2 `BracketCarrierCorrectVPrior` gate closes both directions over
`kvE2_sepBody` (full scope, or the N1/N2 fragment selected by the decision gate), the F4 `ℤ`
counterexample fails against the new carrier, the build is green with no `sorry` on any live
path, every do-not-edit asset is byte-identical, and the GO/NO-GO verdict record is landed.

**Every coordinate in this plan is post-331** (report 07 §1 re-map, verified against the tree
on 2026-07-07). All modules are under
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` unless noted;
`VecEAFormula.lean`, `VecEAClosure.lean`, `EANegationClosure.lean`, `NormalForm.lean`,
`PriorINF.lean`, `NfEFold.lean` are the sibling Kamp files untouched by 331.

### Research Integration

- **Newly integrated (this revision)**: reports/07_v7-consolidated-faithful-route.md — the 38-symbol
  stale-to-fresh coordinate re-map; the Candidate A-via-C carrier signature; the O1-O8
  decomposition with the 650-1,100 line estimate; the two H4 caveats (§2.4 negation statement
  shape; §3.4 private k1v lemmas); the risk-profile inversion (§5.1) and two-axis N1/N2
  fallback (§5.2); the §6 off-limits table.
- **Carried forward from v6**: task 330 audit (navigated/witness-growing invariant), task 320
  report (LITMUS), the v5 Phase 15 F4 `ℤ` adversarial consumer (now Phase 13).

### Settled Decisions (recorded per report 07's open choices — binding for all phases)

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| D1 | Placement of all new code | NEW module `NfMultiAnchorBridge/SharedWitness.lean`, importing `SubBracket2V` + `NavigatedSpine` only, plus ONE additive import line in the umbrella `NfMultiAnchorBridge.lean` | 331 handoff: "task 321's blocked engine work should build against SubBracket2V + NavigatedSpine only". The umbrella is import-only (88 lines, zero declarations) and not on the do-not-edit lemma list; the import addition is additive. No faithful module may import `MergedQuarantine` or `RefutationF2`. |
| D2 | O7 atom-layer reconstruction (`k1v_reconstruct_nf3` is **private**, `CarrierK1V.lean:918`) | **Re-derive additively** in `SharedWitness.lean` from the joint carrier's `epL`/`epR`/`ptW` heads (est. +40-60 lines, inside O7's band). De-privatization is NOT chosen: it would token-edit a task-331-landed file and requires explicit sanction this plan does not have. | Report 07 §3.4 + H4 finding; purely-additive constraint. |
| D3 | Negative subs (`qnf.2 sub = false`) | Route through **uniqueness/coverage**: `nf_eval_unique` (`NormalForm.lean:245`) + `nf_characteristic_satisfies` (`:224`) + the joint gate's off-fiber and zone-consistency clauses. **NEVER** through Prop 4.2 pointwise-existence forms. | Report 07 §2.4 (H4): `neg_2var_vec_ea` (`EANegationClosure.lean:722`) concludes `∃ v', v'.holds` — trivially satisfiable by a top-shaped witness as stated; no `↔`-form or model-independent negation operator exists. Pointwise combinators remain usable inside fixed-M proof directions only. |
| D4 | Carrier architecture | Candidate A staged via Candidate C: the standalone shared-w conjunction theorem `kvE2_sepConj_sharedW` over an arbitrary positive list first (isolates the new mathematics), then the gate wrapper (atom layer + negatives). The Lemma 5.1 kit (`leftPart_holds`/`rightPart_holds`/`splitAt_combine`, `VecEAFormula.lean:375/:412/:478`) is CONSUMED for every shared-`w` pivot — never rebuilt. | Report 07 §2.2-§2.4 recommendation. |

## Goals & Non-Goals

- **Goals**:
  - Build the model-independent joint carrier `kvE2_sepBody : NormalForm sig 2 3 → VVecEA2`
    with one shared `ptW` slot, per-σ `charK` E[Σ]-atom slots, Lemma 3.2(1) joint-interleaving
    disjuncts, refined-conjunction segments, and a depth-2 gate + empty-branch (Phase 7 = O1+O1b+O2).
  - Extract soundness data — shared `w` + per-σ witness bundles — from a realized joint
    disjunct (Phase 8 = O3), and derive each positive σ's 6-conjunct `hgate` bundle from the
    joint carrier's realized segments + endpoint literals (Phase 9 = O4, the make-or-break).
  - Run the explicit DECISION GATE after O3+O4 (Phase 10): FULL continues; O4 failure routes to
    fallback N2 (appendix); exterior overrun later routes to N1.
  - Assemble both directions of the gate (Phase 11 = O5+O6) and discharge
    `BracketCarrierCorrectVPrior` via `kvE2_sepBody_correct_prior` (Phase 12 = O7).
  - Discharge the F4 `ℤ` adversarial counterexample against the new carrier and land the
    GO/NO-GO verdict record (Phase 13 = O8, the preserved v5-Phase-15 consumer).
- **Non-Goals** (goal-state outputs, NOT in-scope work):
  - Task 309 Phase 13.4 (general-k one-step correctness) and the `KampPrior.lean:351` strategic-
    sorry hook rewire are what a GO verdict UNBLOCKS — they are downstream tasks, not phases here.
  - No edits to any task-331-landed module beyond the single umbrella import line (D1). No
    de-privatization (D2). No edit to any .lean file outside `SharedWitness.lean` + the umbrella.
  - Do NOT build or consume anything in the §6 off-limits table below (merged-route quarantine,
    refuted constant-arity infrastructure, pointwise-existence combinators as gate carriers).

## Risks & Mitigations

- **Risk (the make-or-break):** O4 — the carrier-side per-σ `hgate` derivation — cannot be
  closed: the per-σ zone biconditionals may not be recoverable from refined-conjunction
  segments + E[Σ]-atom literals. The honest-side `kvE_subBracket2V_gate_holds_of_honest`
  (`SubBracket2V.lean:1392`) derives `hgate` from an `nf_eval` the soundness direction does not
  have; the carrier-side derivation is genuinely new mathematics (report 07 flags it OPEN).
  **Mitigation:** O4 is its own phase (9), scheduled at the earliest possible point, ONE
  dedicated dispatch, followed by an explicit decision gate (Phase 10) that routes an O4
  failure to fallback N2 — never to chain splicing (FM-merge) or an `x1 < e_i` literal (LITMUS).
- **Risk:** Joint interleaving enumeration (O1) or its membership collapse (O2) gets buried in
  `let`-bound internals that `rw` cannot match through — the exact failure of crux closer 3
  (`NavigatedSpine.lean:431-434`). **Mitigation:** expose the disjunct builder and the
  interleaving sets as TOP-LEVEL `def`s so `VVecEA2.holds_flatMap_map`
  (`NavigatedSpine.lean:220`) applies by `rfl`/`rw` (binding task in Phase 7).
- **Risk:** Exterior/boundary volume overruns in Phase 11 (O5/O6). Per report 07 §5.1 this is
  now LOW risk (risk-profile inversion: exterior content conjoins trivially at the fixed
  endpoints via `formula_conjList`, both directions already landed as the
  `kvE_nonInterior_*` dischargers `NavigatedSpine.lean:257-383`). **Mitigation:** if it
  nonetheless overruns, drop to N1 (interior+boundary fragment, saves ~100-150 lines) — N1 does
  NOT dodge O4, so it is only for a post-gate exterior overrun.
- **Risk:** An additive edit perturbs a do-not-edit asset or a 331-landed module.
  **Mitigation:** all new code confined to the new `SharedWitness.lean`; the only touch outside
  it is one umbrella import line; every phase verifies `git diff --stat` shows exactly those
  files; Phase 13 re-runs the full byte-identity sweep.
- **Risk:** Deflection into analysis (v7 after six versions). **Mitigation:** every phase has a
  concrete sorry-free Lean object + green build as its stopping condition; analysis-only output
  is not an acceptable phase result (H2); the decision gate is the ONLY phase whose output is a
  record rather than code.

## POSTMORTEM CONSTRAINTS — Failure Lineage v1-v6 (binding on every phase)

Six versions have not converged. v6's postmortem identified the v1-v5 root cause (static
constant-arity carrier vs Rabinovich's navigated fold); v6 itself then failed at the merged
carrier's union-content splice. The failure-mode codes below (report 07 §3) are cited per-phase;
each phase MUST avoid the modes listed against it.

| Code | Failure mode | Version(s) that died on it | The v7 discipline |
|------|--------------|---------------------------|-------------------|
| FM-G6 | Arity-4 residual forced through a static arity-1 channel (`EAtomDom`, `NfEFold.lean:69`) | v1-v5 (G6/F4/327 — one obstruction) | NAVIGATED/witness-growing only; arity-4 zone data rides `zoneHolds M [x1,w,x,t] zs v` slot-position reads |
| FM-x1t | Unbounded-above `fChainPred` cannot certify `x1 < t` | report-03 wall | Witness bounds come from the bracket's OWN range/ordering (every witness strictly inside `(x,t)`); the joint bracket is single-level |
| FM-merge | Per-σ chains spliced as point types of ONE bracket (`slotsFor`) | v6 Phase 7 (the crux) | Point types are ONLY `charBase χ` / `charK (nfk_projFresh σ)` — quantifier-free / E[Σ]-atom (Lemma 5.1 md:72); no `fChainPred` in any point-type position; no bracket-in-bracket |
| FM-vac | Vacuous carrier / empty-gate closure | task 324/325-v1 | Non-vacuity lemma mandatory (O1b); both gate directions stated against the real `nf_eval_nf M 2 3`; no `True`-shaped placeholder |
| FM-lvl | Per-sub closer applied to the outer quant map wholesale | crux failed closer 1 (`NavigatedSpine.lean:424-427`) | Per-sub closers applied per σ ∈ pos AFTER O3/O4 supply per-σ data — never to `qnf.2` wholesale |

**Binding invariant (unchanged from v6):** reconstruction is NAVIGATED / witness-growing, never
a static arity-1 characteristic; inter-anchor coupling rides the evaluation point / structural
position of nested `Until`/`Since` (Prop 3.5 / Cor 5.4). **LITMUS:** no `x1 < e_i`
relative-position literal on any live path — positions are carried by bracket witness slots
(internal monotonicity + range), `Since`/`Until` evaluation points at the fixed endpoints, and
`leftPart`/`rightPart` structural split at an INDEX (md:218: "which i the new point corresponds
to"). **No-nesting:** quantifier-free point types per Lemma 5.1 (md:72); an E[Σ]-atom
(`charK …`) predicates only of its own point — never another bracket's witness structure
(no-nesting rule, `NavigatedSpine.lean:43-48`).

**Binding constraints (from the task description, non-negotiable):** purely additive;
DO-NOT-EDIT (byte-identical) task-325/326 landed lemmas, the `kvE2_body`/`bracketEndChar_kvE2`
splice, `kvE_subChain2V`, `BracketCarrierCorrectVPrior`, `EANegation`, F1-F4 records; no
provider-side pinning (Amendment F3); anchor cap 2 (Lemma 3.2(2), md:78; `VVecEA2` type
invariant `VecEAFormula.lean:271`); G5 citations at every chain step; axiom-clean
`[propext, Classical.choice, Quot.sound]`; no `sorry` on any live path.

## Off-Limits Table (report 07 §6 — no phase may build on or consume these)

| Off-limits | Location | Reason |
|---|---|---|
| `kvE_body` / `kvE'_body` / `kvE2_body` (+ local `slotsFor` lets) | `MergedQuarantine.lean:148/:490/:807` | The merged bracket-whose-points-are-brackets; FM-merge; private, off the faithful import path |
| `bracketEndChar_kvE` / `_kvE'` / `_kvE2` / `_two_eq` | `MergedQuarantine.lean:262/:595/:911/:926` | Merged carriers; `_two_eq` is a protected verdict record |
| `kvE_gate` / `kvE_pinArrangements` / `kvE_pinDisjunct` / `kvE_exclConj` / `kvE_consistent(-Zones)` | `MergedQuarantine.lean:127/:449/:459/:472/:112/:435` | Union/existential zone content — the exact reason per-sub `hgate` was underivable |
| `kvE2_joint_nonvacuous_at_honest` | `MergedQuarantine.lean:947` | Non-vacuity of the merged carrier only; write a fresh O1b analog of `SubBracket2V.lean:1425` |
| `bracketFromLists_flatMap_subchain_below_pin` | `SubBracket2V.lean:1099` (private) | Merge-undoing engineering artifact; must not be extended |
| `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` / `nf_eval_nf1_cons_factor` / `efold_of_nfk` / `nf_quant_layer_fold_k2_gate` | prose-only, task-327 record (`MergedQuarantine.lean:959-end`) | Refuted constant-arity route; do NOT create |
| `EAtomDom` static arity-1 factorization as a live path | `NfEFold.lean:69` | The category error at k>=1 (audit 330) |
| Any `fChainPred`-typed point slot; any `x1 < e_i` literal; any provider-side pinning (`w = e 1`) | — | FM-merge / LITMUS / Amendment F3 |
| `RefutationF2.lean` contents | quarantined module (`f2_relativized_refutation:859`) | Negative-result record only |
| Pointwise-existence combinators AS the gate carrier: `reflatten_prop43`, `conj_holds_vvecEA2`, `neg_2var_vec_ea`, `reflatten_neg_step` | `NavigatedSpine.lean:193`, `VecEAClosure.lean:238`, `EANegationClosure.lean:722`, `NavigatedSpine.lean:178` | §2.4 statement-shape caveat (D3); usable inside fixed-M proof directions only |

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
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |
| 11 | 12 | 11 |
| 12 | 13 | 12 |

Phases 1-6 are landed (v6). The open work (7-13) is strictly sequential: the carrier must exist
before extraction (7→8), extraction feeds the hgate derivation (8→9), the gate verdict follows
O4 (9→10), and assembly/wrapper/adversarial phases consume everything upstream (10→11→12→13).

### Phase 1: Baseline snapshot + refuted-infrastructure quarantine [COMPLETED]

Landed under v6. Baseline SHA + do-not-edit asset hashes recorded; refuted constant-arity
infrastructure (`nfk_assemble`/`nfk_dropFresh`/`nfk_zoneSpec`, `nf_eval_nf1_cons_factor`,
`efold_of_nfk`, `nf_quant_layer_fold_k2_gate`) confirmed nonexistent-or-inert and DROPPED;
consumed-asset signatures verified. Post-331 note: these assets now live in the split modules
(re-map: report 07 §1); byte-identity for phases 7-13 is checked against the post-331 tree
(331 ORIG_SHA `2146e9c05d144b54495f566169a08a7e734bf645`; 331 gate 6 proved the split itself
byte-identical).

### Phase 2: Navigated-fold SPINE — `kvE_fold_navigated` (MAKE-OR-BREAK, passed at sub granularity) [COMPLETED]

Landed @ 4a7d130 (v6, scope deviation recorded). `kvE_fold_navigated` (now
`NavigatedSpine.lean:83`) landed at SUB granularity, consuming the task-326
`kvE_subBracket2V_correctness_pair` (now `SubBracket2V.lean:1855`) as the named navigated
spine. The arity-4 residual that killed the constant-arity route IS carried at sub level
(`zoneHolds M [x1,w,x,t] zs v` over `ZoneSpec 4`). Sorry-free, axiom-clean, additive, LITMUS-clean.

### Phase 3: Prop 4.3 re-flatten structural induction wiring [COMPLETED]

Landed @ cec30d8 (v6). `VVecEA2.disjList` / `disjList_holds` (now `NavigatedSpine.lean:140/:149`
— the Lemma 3.4 finite-disjunction collapse), `reflatten_neg_step` (`:178`), `reflatten_prop43`
(`:193`). Sorry-free, axiom-clean, additive (171/0). v7 note (D3): these are pointwise-existence
forms — consumable inside fixed-M directions only, never as the gate carrier.

### Phase 4: Arrangement-product membership collapse [COMPLETED]

Landed @ 0a4c3db4 (v6). `VVecEA2.holds_flatMap_map` (now `NavigatedSpine.lean:220`) — the
structural flatMap/map collapse, general over the disjunct builder. Sorry-free, axiom-clean,
additive (203/0). The SEMANTIC gate content was deferred — v6 Phase 7 then found it blocked
over the merged carrier; v7 phases 7-12 supply it over the separate-bracket carrier instead.

### Phase 5: Per-arrangement non-interior dischargers — SOUNDNESS [COMPLETED]

Landed @ f76a3f1c (v6). 5 `_sound` dischargers, now `kvE_nonInterior_{zPastX,zFutT,zAtX,zAtT,zAtW}_sound`
(`NavigatedSpine.lean:257/:271/:284/:295/:308`). Stated over raw `formula_conjList` +
membership — channel-abstract, so the JOINT `epL`/`epR`/`ptW` literals of phases 7-11
instantiate them uniformly (report 07 contradiction log: NOT retired by the merged route's
death). Sorry-free, axiom-clean, additive (287/0), LITMUS-clean.

### Phase 6: Per-arrangement non-interior dischargers — COMPLETENESS [COMPLETED]

Landed @ c45e34ea (v6). 5 `_complete` dischargers (`NavigatedSpine.lean:336/:348/:359/:368/:378`),
mirroring Phase 5. Sorry-free, axiom-clean, additive (356/0), LITMUS-clean.

**v6 Phase 7 lineage note:** v6 Phase 7 (gate assembly over the merged `bracketEndChar_kvE2`)
is [BLOCKED]-superseded: its captured crux + 4 failed closers are landed as an inert decision
record (now `NavigatedSpine.lean:385-449`, @ cb1631d). Report 07 resolved the blocker into the
O1-O8 decomposition; v7 phases 7-13 below replace it. The merged carrier is quarantined
(off-limits table); nothing below touches it. v6 Phase 8 (F4 adversarial consumer) is preserved
as v7 Phase 13.

### Phase 7: Joint carrier `kvE2_sepBody` + non-vacuity + membership collapse (O1 + O1b + O2) [COMPLETED]

**Completion note (2026-07-07, sess_1783487859_3f6358):** Landed @ 5f3d4cdab (O1+O2) +
c9dcc0c0e (O1b) in NEW `NfMultiAnchorBridge/SharedWitness.lean` (943 lines) + one umbrella
import line. All named objects landed: `kvE2_sepBody`, `kvE2_sepGate`, `kvE2_sepDisjunct`,
`kvE2_sepArrL`/`kvE2_sepArrR` (top-level interleaving sets = permutations filtered by the
per-σ region-rank validity `kvE2_sepValid`), fresh N-slot builder `kvE2_sepBracketN`
(per-index segment types), O2 collapse `kvE2_sepBody_holds_iff` (direct
`VVecEA2.holds_flatMap_map` instantiation via `dif_pos` — no `let`-buried internals), O1b
`kvE2_sepBody_nonvacuous` + `kvE2_sepGate_holds_of_honest`. Axiom-clean (exactly
`[propext, Classical.choice, Quot.sound]`), litmus grep 0 hits, 0 sorries, full `lake build`
green. *Recorded scope decision (deviation: altered — plan's O1 sketch was silent on
σ-placement):* positive subs are classified by outer zone `nf0_zoneSpec σ.1` (seven-zone
set incl. `zAtW3` witness self-zone); BOTH interior classes (`zXW3` left, `zWT3` right)
receive tagged slot groups (mirrored right-interior zone constants added); the five
non-interior classes ride σ-level `charK` `Since`/`Until`/at-anchor endpoint literals
(merged-carrier pattern re-derived additively, the Phase-5/6 dischargers' shape). The inner
nine-zone gate clause is stated for LEFT-interior positives only (the class the landed
per-σ kit serves) — extending to the mirrored right class is deferred to Phases 8-10
arbitration and is an additive file-internal change if needed.

- **Goal:** Land the model-independent joint separate-content carrier as a concrete `def`, its
  non-vacuity lemma, and its arrangement-membership collapse — the Candidate A object staged
  for Candidate C consumption.
- **Target file(s):** NEW `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (imports: `SubBracket2V`, `NavigatedSpine` — nothing else from the bridge; D1) + ONE import
  line added to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (umbrella).
- **Tasks:**
  - [x] Create `SharedWitness.lean` with a module banner citing this plan, report 07, and the
        SubBracket2V API banner's "ONE unbuilt object" note (`SubBracket2V.lean:25-27`).
  - [x] O1 — state the carrier exactly per report 07 §2.2:
        ```lean
        noncomputable def kvE2_sepBody {sig : MonadicSignature}
            (charBase : NormalForm sig 0 1 → Formula)
            (charK : NormalForm sig 1 1 → Formula)
            (qnf : NormalForm sig 2 3) : VVecEA2
        ```
        Construction: `pos := Finset.univ.toList.filter qnf.2` (Fintype instance
        `NormalForm.lean:167-178`); ONE shared `ptW` slot (arity-3 analog of the per-σ `ptW`,
        pattern `SubBracket2V.lean:216-219`); per positive σ one `ptX1_σ` slot typed
        `charK (nfk_projFresh σ)` (a unary E[Σ]-atom) plus σ's per-region interior-positive
        `charBase χ` types; disjuncts enumerate the JOINT interleavings (permutation product
        generalizing `S_XU/S_UW/S_WT` of `SubBracket2V.lean:249-251` to the union over `pos`),
        one flat N-slot `bracketFromLists`-style bracket per interleaving (write a fresh N-slot
        builder — `bracketFromLists` `CarrierK1V.lean:389` is public 2-region, the private
        `bracketFromLists3` `SubBracket2V.lean:72` is a 2-slot pattern only), refined segment
        types = conjunction of every σ's exclusion content on that refined sub-interval;
        `epL_joint`/`epR_joint` = `formula_conjList` of all per-σ exterior/boundary literals
        (per-σ `epL`/`epR` content, `SubBracket2V.lean:183-192`) + `qnf.1`'s endpoint 1-types;
        gate-failure branch `{ disjuncts := [] }` under the depth-2 gate (off-fiber falsity +
        joint zone-consistency), mirroring `SubBracket2V.lean:232-252` and including the two
        self-zones per witness slot (nine-zone lesson, `SubBracket2V.lean:160-166`).
        Cite Lemma 3.2(1) (md:77) at the interleaving enumeration, Lemma 5.1 (md:72) at the
        point-type discipline (G5).
  - [x] O1b — non-vacuity lemma (fresh analog of `kvE_subBracket2V_nonvacuous`,
        `SubBracket2V.lean:1425`): the honest configuration produces a nonempty disjunct list.
        *(landed as `kvE2_sepBody_nonvacuous` + `kvE2_sepGate_holds_of_honest` +
        `kvE2_sep_zone3_consistent`)*
  - [x] O2 — membership collapse: expose the disjunct builder and interleaving sets as
        TOP-LEVEL `def`s (crux failed-closer-3 lesson: no `let`-buried `S_L`/`S_R`/`mkDisjunct`)
        and land the carrier-specific instantiation of `VVecEA2.holds_flatMap_map`
        (`NavigatedSpine.lean:220`) so `(kvE2_sepBody …).holds ↔ ∃ arrangement ∈ …, disjunct.holds`
        applies by `rfl`/`rw`.
- **Postmortem constraints:** FM-merge (point types ONLY `charBase χ` / `charK (nfk_projFresh σ)`;
  zero `fChainPred` occurrences in the file); FM-vac (non-vacuity mandatory, self-zones in the
  gate).
- **Verification:** `lake build` exit 0; `lean_verify` on `kvE2_sepBody`-namespace lemmas =
  exactly `[propext, Classical.choice, Quot.sound]`; litmus grep on `SharedWitness.lean`:
  `grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e( |$|[0-9])" ` returns 0 live-path hits;
  no-nesting audit: no point-type position references any bracket/chain constructor;
  `git diff --stat` touches only `SharedWitness.lean` + the umbrella import line.
- **Estimated lines:** 170-280 (O1 130-200 incl O1b; O2 40-80).
- **Timing:** ~3 hours. **Depends on:** 6 (all landed assets).
- **Commit:** `task 321 phase 7: joint sepBody carrier + non-vacuity + membership collapse`
- **Rollback/Contingency:** fix-forward; the phase is a single new file + one import line, so a
  true rollback is reverting the commit (run `bash .claude/scripts/git-snapshot.sh` first if the
  tree is dirty). A definition-shape failure here is NOT a route failure — iterate within the
  dispatch; only an inability to STATE the carrier model-independently escalates to the Phase 10
  gate early (direct to N2 assessment).

### Phase 8: Joint soundness extraction — shared `w` + per-σ bundles (O3) [NOT STARTED]

- **Goal:** From a realized joint disjunct of `kvE2_sepBody`, extract the shared witness `w`
  (from the `ptW` slot; `x < w < t` from the bracket's own range) and, for EVERY positive σ,
  the witness bundle `(x1_σ, hxx1, hx1t, hanchor, hbelow)` — the per-σ inputs the task-326
  closers consume.
- **Target file(s):** `SharedWitness.lean` (append).
- **Tasks:**
  - [ ] State and prove the extraction theorem (Candidate C staging: over an arbitrary positive
        list where convenient, per the `kvE2_sepConj_sharedW` shape of report 07 §2.4):
        realized disjunct → `∃ w, x < w ∧ w < t ∧ wAnchor w ∧ ∀ σ ∈ pos, (per-σ bundle at that same w)`.
  - [ ] Consume the Lemma 5.1 kit for the shared-`w` pivot: `BracketFormula.leftPart_holds` /
        `rightPart_holds` (`VecEAFormula.lean:375/:412`) — from a realized joint bracket, both
        halves hold at the shared witness point. Cite Lemma 5.1 (md:168-171, md:218) at each
        split step (G5).
  - [ ] Use the landed extraction patterns as TEMPLATES (new code regardless — N slots vs 2):
        `kvE_sub2V_bounded_anchor_of_outer` (public, `SubBracket2V.lean:1182`); the private
        `kvE_subBracket2V_extract` (`SubBracket2V.lean:762`) is a pattern only, not consumable.
- **Postmortem constraints:** FM-x1t (`x1_σ < t` comes from the bracket's own range/ordering —
  every witness strictly inside `(x,t)`; the joint bracket is single-level, so the report-03
  wall does not arise; NEVER from a chain); FM-G6 (arity-4 zone data rides
  `zoneHolds M [x1_σ,w,x,t] zs v` slot-position reads).
- **Verification:** `lake build` exit 0; `lean_verify` axiom check; litmus grep + no-nesting
  audit as Phase 7; `git diff --stat` touches only `SharedWitness.lean`.
- **Estimated lines:** 150-250.
- **Timing:** ~3 hours. **Depends on:** 7.
- **Commit:** `task 321 phase 8: joint soundness extraction (shared w + per-sigma bundles)`
- **Rollback/Contingency:** fix-forward within the dispatch. If extraction itself cannot close,
  record the precise failing goal (captured `lean_goal`) as an inert note and proceed to the
  Phase 10 gate with a FAIL input — do not attempt chain splicing.

### Phase 9: Carrier-side per-σ `hgate` derivation (O4 — MAKE-OR-BREAK, one dedicated dispatch) [NOT STARTED]

- **Goal:** For each positive σ, at the Phase-8-extracted shared `w`, derive the 6-conjunct
  `hgate` bundle that `kvE_subBracket2V_correctness_pair` (`SubBracket2V.lean:1855`, bundle
  spec at `:1868-1882`) and `kvE_subBracket2V_sound_of_parts` (`:1025`) require — from the
  joint carrier's realized refined segments + endpoint literals. This is the exact residue of
  the captured crux (`NavigatedSpine.lean:414-421`, step (d)) and the open mathematics report
  07 could not verify in advance.
- **Target file(s):** `SharedWitness.lean` (append).
- **Tasks:**
  - [ ] Re-derive an N-point analog of the zone-consistency plumbing (`kvE_sub2V_zone_consistent`,
        private `SubBracket2V.lean:1270`, is a template only).
  - [ ] Derive each per-σ zone biconditional from: the refined-conjunction segments (each
        refined sub-interval carries EVERY σ's exclusion content by O1's construction), the
        `charK (nfk_projFresh σ)` E[Σ]-atom literal at σ's own slot, and the joint
        `epL`/`epR`/`ptW` endpoint literals. The honest-side derivation
        `kvE_subBracket2V_gate_holds_of_honest` (`SubBracket2V.lean:1392`) is the shape target
        but consumes an `nf_eval` this direction does not have — the carrier-side derivation is
        genuinely new.
  - [ ] Cite Prop 3.5 (md:91-94) at each navigation literal and Lemma 5.1 (md:72) at each
        quantifier-free segment read (G5).
- **Postmortem constraints:** This phase is the crux. PROHIBITED on failure: chain splicing
  (FM-merge), any `x1 < e_i` literal (LITMUS), a gate-modulo-assumed-`hgate`, a vacuous
  placeholder, a `sorry`. One dedicated dispatch ONLY — an incomplete O4 goes to Phase 10 as a
  FAIL, with the failing goal captured as an inert record (crux house style).
- **Verification:** `lake build` exit 0; `lean_verify` axiom check on the hgate-derivation
  lemmas; litmus grep + no-nesting audit; `git diff --stat` touches only `SharedWitness.lean`.
- **Estimated lines:** 150-250.
- **Timing:** ~3 hours (one dispatch, hard cap). **Depends on:** 8.
- **Commit:** `task 321 phase 9: carrier-side per-sigma hgate derivation (O4)` (on PASS) or
  `task 321 phase 9: O4 crux capture (FAIL input to decision gate)` (inert record only).
- **Rollback/Contingency:** fix-forward inside the single dispatch; NO second O4 dispatch at
  full scope — the decision gate owns the routing. Snapshot via `git-snapshot.sh` before any
  revert of probe edits (only inert records are committed on FAIL, mirroring v6 Phase 7 practice).

### Phase 10: DECISION GATE — FULL / N1 / N2 verdict on the Phase-B outcome [NOT STARTED]

- **Goal:** Evaluate the O3+O4 outcome against concrete pass/fail criteria and route the
  remainder of the plan. This is the gate report 07 mandates after Phase B; its output is a
  decision record + (on FAIL) a plan amendment — no Lean code.
- **PASS criteria (ALL must hold):**
  1. Phase 8 extraction theorem landed sorry-free, axiom-clean: realized joint disjunct →
     shared `w` (`x < w < t`, `wAnchor`) + per-σ bundles for every positive σ.
  2. Phase 9 landed sorry-free, axiom-clean: for each positive σ, the full 6-conjunct `hgate`
     bundle (per `SubBracket2V.lean:1868-1882`) derived at the extracted shared `w` from
     realized segments + endpoint literals — no assumed `hgate`, no placeholder.
  3. Litmus + no-nesting audits clean over `SharedWitness.lean`; `git diff` additive-only.
- **FAIL looks like (ANY of):** a per-σ zone bit required by `hgate` underdetermined by the
  refined-conjunction segments + E[Σ]-atom literals (the derivation genuinely doesn't go
  through); a type-level mismatch that can only be closed by splicing chains into point types
  (FM-merge) or introducing an `x1 < e_i` literal (LITMUS) — both prohibited, hence FAIL; O4
  not closed within its one dedicated dispatch.
- **Routing:**
  - **PASS → FULL:** proceed to Phase 11 unchanged.
  - **FAIL on O4 → N2** (single-positive-sub fragment, ~200-350 lines total): amend this plan
    to promote Appendix N2's phase sequence (N2-A/N2-B/N2-C) as replacement content for Phases
    11-12, re-run `generate-todo.sh` after the state edit, and proceed. N2 — NOT N1 — because
    O4 is the crux and N2 isolates the same make-or-break at minimum size (one σ against its
    OWN segments, the configuration `kvE_subBracket2V_sound_of_outer` `SubBracket2V.lean:1216`
    + `kvE_sub2V_bounded_anchor_of_outer` `:1182` already handle).
  - **PASS but a later exterior overrun in Phase 11 → N1** (interior+boundary fragment, saves
    ~100-150 lines): restrict via `interiorBoundaryOnly` (Appendix N1) — a Phase-11-local
    narrowing, no gate re-run.
- **Tasks:**
  - [ ] Write the verdict record (FULL/N1-armed/N2) as a dated note in this plan file under
        this phase heading, citing the Phase 8/9 commits and any captured failing goal.
  - [ ] On FAIL: apply the N2 plan amendment (promote appendix, rescope Phases 11-12), commit.
- **Verification:** verdict record present; on FAIL, amended plan still satisfies
  plan-format-enforcement (phase heading regex, required sections).
- **Estimated lines:** 0 Lean lines (record + possible plan amendment only).
- **Timing:** ~0.5 hours. **Depends on:** 9.
- **Commit:** `task 321 phase 10: decision gate verdict (FULL|N1-armed|N2)`
- **Rollback/Contingency:** none needed (no code). The RE-SCOPE ladder (below) is the
  contingency structure this phase administers.

### Phase 11: Gate assembly — soundness + completeness, both directions (O5 + O6) [NOT STARTED]

- **Goal:** Assemble both directions of the shared-w correctness statement over the extracted
  data: soundness by per-σ closer application + negatives via coverage; completeness from the
  honest model to a realized joint disjunct.
- **Target file(s):** `SharedWitness.lean` (append).
- **Tasks:**
  - [ ] O5 soundness assembly: apply `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`)
        per σ ∈ pos with the Phase 8/9 data (FM-lvl: never to `qnf.2` wholesale). Negatives
        (`qnf.2 sub = false`) via D3 ONLY: `nf_eval_unique` (`NormalForm.lean:245`) +
        `nf_characteristic_satisfies` (`:224`) + the joint off-fiber gate clause — NOT
        `neg_2var_vec_ea` or any pointwise-existence form.
  - [ ] O6 completeness: honest `w` + per-σ honest `x1_σ` → select the joint sorted
        interleaving (`exists_permutation_cons_head`, `EANegationClosure.lean:752`) → realize
        slots + refined segments (each σ's completeness-side zone bits hold on each refined
        sub-interval — per-σ `_complete` mechanism, `SubBracket2V.lean:1465`, doc `:1448-1464`)
        → assemble via `BracketFormula.splitAt_combine` (`VecEAFormula.lean:478`, the Lemma 5.1
        combine direction). Exterior/boundary literals via the landed intro dischargers
        (`NavigatedSpine.lean:336-383`); extraction side already uses `:257-308`.
  - [ ] Cite Lemma 3.4 (md:85) at the disjunction closure, Lemma 5.1 (md:168-171) at the
        combine step, Prop 3.5 (md:91-94) at navigation literals (G5).
- **Postmortem constraints:** FM-lvl (per-σ application only); FM-merge-dual (the joint carrier
  is a DISJUNCTION over interleavings — the honest model realizes its OWN sorted interleaving,
  never all splices simultaneously); D3 binding (no Prop 4.2 routing for negatives).
- **N1 trigger (from Phase 10, armed only on exterior overrun):** if the exterior halves of
  `epL`/`epR` wiring overrun this dispatch, restrict to `interiorBoundaryOnly` (Appendix N1) and
  record the narrowing — O4 already passed, so N1 is sufficient and N2 is not needed.
- **Verification:** `lake build` exit 0; `lean_verify` axiom check; litmus grep + no-nesting
  audit; `git diff --stat` touches only `SharedWitness.lean`.
- **Estimated lines:** 210-370 (O5 60-120; O6 150-250). If the dispatch overruns without an
  exterior cause, split O5/O6 into 11 + a continuation dispatch of the same phase before
  invoking N1.
- **Timing:** ~3 hours. **Depends on:** 10.
- **Commit:** `task 321 phase 11: gate soundness + completeness assembly`
- **Rollback/Contingency:** fix-forward; N1 narrowing per above; snapshot before any revert.

### Phase 12: `BracketCarrierCorrectVPrior` gate wrapper (O7) [NOT STARTED]

- **Goal:** Discharge the gate itself:
  ```lean
  theorem kvE2_sepBody_correct_prior {sig : MonadicSignature}
      (atomMap : Formula → sig.preds)
      (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
      (P : ExistProviders sig atomMap) :
      BracketCarrierCorrectVPrior atomMap
        (fun qnf => kvE2_sepBody (nf_depth0_char_formula atomMap h_surj) (P.existF 0) qnf)
  ```
  against `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) with `ExistProviders`
  (`PriorInterface.lean:40-45`), consuming Phase 11 both directions.
- **Target file(s):** `SharedWitness.lean` (append).
- **Tasks:**
  - [ ] Depth-2 unfold via `nf_eval_nf` (`NormalForm.lean:198-207`): atom clause over `[w,x,t]`
        + outer quant clause `∀ sub : NormalForm sig 1 4, (∃ x1, …) ↔ qnf.2 sub`.
  - [ ] Atom-layer reconstruction at `[w,x,t]` from the `epL`/`epR`/`ptW` heads — **re-derived
        additively per D2** (`k1v_reconstruct_nf3` `CarrierK1V.lean:918` is private and stays
        untouched; `nf_eval_depth1_fold_iff` `CarrierKv.lean:466` available as the depth-1 fold
        reference). Order-bit recovery at the integration site.
  - [ ] Both directions stated against the real `nf_eval_nf M 2 3` (FM-vac: no `True`-shaped
        placeholder). `BracketCarrierCorrectVPrior` consumed byte-identically.
  - [ ] Cite Prop 4.3 (md:104-110) at the depth ladder (G5).
- **Postmortem constraints:** FM-vac; D2 (no de-privatization); purely additive.
- **Verification:** `lake build` exit 0; `lean_verify kvE2_sepBody_correct_prior` = exactly
  `[propext, Classical.choice, Quot.sound]`; litmus grep + no-nesting audit; `git diff` shows
  no 331-landed module touched.
- **Estimated lines:** 60-100 (+40-60 atom-layer re-derivation → 100-160 total band).
- **Timing:** ~2 hours. **Depends on:** 11.
- **Commit:** `task 321 phase 12: BracketCarrierCorrectVPrior gate wrapper (kvE2_sepBody_correct_prior)`
- **Rollback/Contingency:** fix-forward. If the atom-layer re-derivation stalls specifically on
  a fact only `k1v_reconstruct_nf3` provides, do NOT de-privatize unilaterally — surface it as
  a one-token sanctioned-edit request (331 precedent) in the phase output and stop.

### Phase 13: F4 `ℤ` adversarial LHS-FALSE + integrity sweep + GO verdict record (O8, preserved v5-Phase-15 consumer) [NOT STARTED]

- **Goal:** Discharge the mandatory F4 `ℤ` adversarial counterexample against the closed gate,
  run the full integrity sweep, and land the final GO/NO-GO verdict record — the deliverable
  whose GO unblocks task 309 Phase 13.4 (general-k one-step correctness) and the
  `KampPrior.lean:351` strategic-sorry hook rewire (both downstream, out of scope here).
- **Target file(s):** `SharedWitness.lean` (append).
- **Tasks:**
  - [ ] Instantiate the F4 `ℤ` counterexample (`M=ℤ`, `p={0}`, `r={13}`, `x=10`, `t=20`,
        `σ''=char[14,16,11,20]` vs honest `char[14,15,10,20]` marked false) against
        `kvE2_sepBody` and prove the LHS is FALSE at `(10,20)`. The test MUST fail against the
        new carrier: if the LHS still holds, completeness lost the `σ.2` dependence — return to
        Phases 9/11; do NOT weaken the test. (Under N2 the test still runs meaningfully: F4's
        counterexample is a single-σ discriminator.)
  - [ ] Land the final verdict record (F1-F4 house style): separate-bracket route realized;
        `kvE2_sepBody` + shared-w extraction + hgate derivation + both directions +
        `kvE2_sepBody_correct_prior` wired; F4 discriminated; scope = FULL/N1/N2 per the
        Phase 10 verdict; G5 citations enumerated; explicit GO/NO-GO line for task 309
        Phase 13.4 + the KampPrior hook rewire.
  - [ ] Integrity sweep: full `lake build` exit 0; `git diff` against the pre-Phase-7 SHA is
        purely additive (`SharedWitness.lean` + one umbrella import + task artifacts); every
        do-not-edit asset byte-identical; no `sorry` on any live path; all new symbols
        axiom-clean via `lean_verify`; litmus grep + no-nesting audit over the whole new file;
        no `simp`/`omega`/`aesop` in chain-construction bodies (only `by omega` for
        `Fin`-index/length typing).
- **Verification:** all sweep items above green; F4 LHS-FALSE lemma sorry-free.
- **Estimated lines:** 80-120.
- **Timing:** ~1.5 hours. **Depends on:** 12.
- **Commit:** `task 321 phase 13: F4 Z adversarial gate + GO verdict record`
- **Rollback/Contingency:** fix-forward. An F4 LHS-TRUE outcome is a correctness regression,
  not a formatting issue: reopen Phase 11 (completeness) — never edit the test to pass.

## RE-SCOPE Ladder (trigger conditions — administered by Phase 10)

```
FULL (Phases 7-13 as written, 670-1,120 lines)
  │  trigger: O4 (Phase 9) fails its one dedicated dispatch
  ├──────────────► N2 — single-positive-sub fragment (~200-350 lines total; Appendix N2)
  │                 dodges the interleaving engine entirely; isolates O4 at minimum size
  │  trigger: O4 PASSES but exterior epL/epR wiring overruns Phase 11
  └──────────────► N1 — interior+boundary fragment (saves ~100-150 lines; Appendix N1)
                    drops exterior halves; keeps O1-O8 otherwise unchanged
```

Neither narrowing re-admits any constant-arity or merged-bracket construction. Both remain
subject to every postmortem constraint, the LITMUS, and the F4 adversarial test (Phase 13).

## Testing & Validation

- [ ] Scoped build green after each phase: `lake build` exit 0 (module target:
      `Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`); full
      `lake build` at Phase 13.
- [ ] Phase 9 (O4) is the make-or-break: one dedicated dispatch, then the Phase 10 gate — no
      full-scope O4 retry outside the gate's routing.
- [ ] Negatives NEVER routed through `neg_2var_vec_ea` / `reflatten_prop43` /
      `conj_holds_vvecEA2` / `reflatten_neg_step` as carriers (D3); coverage route only.
- [ ] No de-privatization of any 331-landed lemma (D2); the only edit outside
      `SharedWitness.lean` is the single umbrella import line (D1).
- [ ] LITMUS grep per phase: no `x1 < e_i`-shaped relative-position literal, no `fChainPred`
      occurrence, anywhere in `SharedWitness.lean` live paths.
- [ ] No-nesting audit per phase: every point-type position is `charBase χ` or
      `charK (nfk_projFresh σ)` — quantifier-free / E[Σ]-atom (Lemma 5.1 md:72); no bracket or
      chain in any point-type position (`NavigatedSpine.lean:43-48`).
- [ ] MANDATORY adversarial test (Phase 13): F4 `ℤ` counterexample (`char[14,16,11,20]` vs
      honest `char[14,15,10,20]`) FAILS against `kvE2_sepBody` (LHS FALSE at `(10,20)`).
- [ ] Axiom-clean (`propext`, `Classical.choice`, `Quot.sound`) on all new symbols; no `sorry`
      on any live path; no `simp`/`omega`/`aesop` in chain-construction bodies.
- [ ] Every do-not-edit asset byte-identical; all new work additive; `git diff --stat` audited
      at every phase commit.
- [ ] G5: Rabinovich citation at every chain step — Lemma 3.2(1) md:77 (interleaving), Lemma
      3.2(2) md:78 (anchor cap), Lemma 3.4 md:85 (closure), Prop 3.5 md:91-94 (navigation),
      Prop 4.2 md:100-101 (negation context, D3 caveat), Prop 4.3 md:104-110 (depth ladder),
      Lemma 5.1 md:72/md:168-171/md:218 (point types, split/insertion, index discipline).

## Artifacts & Outputs

- specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md (this plan; supersedes v6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (NEW —
  all v7 Lean output: `kvE2_sepBody` + non-vacuity + membership collapse, extraction, hgate
  derivation, both directions, `kvE2_sepBody_correct_prior`, F4 `ℤ` LHS-FALSE, verdict record)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (umbrella — ONE added
  import line)
- Phase 10 decision-gate verdict record (in this plan file; plus plan amendment on FAIL)
- specs/321_.../summaries/07_v7-faithful-separate-bracket-summary.md (at completion)
- **Goal-state outputs (downstream, not in-scope):** GO/NO-GO verdict for task 309 Phase 13.4
  (general-k one-step correctness) and the `KampPrior.lean:351` strategic-sorry hook rewire.

## Rollback/Contingency

- **Additive-only guarantee:** every phase appends to the new `SharedWitness.lean` (Phase 7 also
  adds one umbrella import line); rollback of any phase is reverting that phase's commit.
  Do-not-edit assets and all 331-landed modules are never touched, so no landed asset is at risk.
- **Fix-forward first:** per `.claude/rules/error-handling.md`, correct the source rather than
  discarding work. Before any TRUE rollback (revert/reset) on a dirty tree, run
  `bash .claude/scripts/git-snapshot.sh` (git-workflow.md mandate).
- **RE-SCOPE ladder:** FULL → N1 / N2 per the trigger table above, administered exclusively by
  the Phase 10 decision gate (N1 may also be invoked Phase-11-locally on exterior overrun after
  a PASS). A NO-GO outcome at Phase 13 (F4 not discriminated and not fixable by reopening
  Phase 11) produces an honest NO-GO verdict record in the F1-F4 house style — never a weakened
  test, never a vacuous gate.

---

## Appendix — Fallback N2: single-positive-sub fragment (promoted by Phase 10 amendment ONLY)

**Not scannable phases by design** (no `### Phase N:` headings): these blocks are promoted into
Phases 11-12 replacement content by an explicit plan amendment if and only if the Phase 10 gate
returns FAIL on O4. Estimated total: 200-350 lines. Restriction predicate: `qnf` with at most
one positive sub (`∀ σ σ', qnf.2 σ = true → qnf.2 σ' = true → σ = σ'`).

#### N2-A: Degenerate carrier + wrapper (replaces the FULL O1 consumption)

The joint carrier degenerates to the single σ's `kvE_subBracket2V` (`SubBracket2V.lean:139`)
plus the atom layer and negatives: O1 collapses to a wrapper def (`kvE2_sepBody_singleton` or a
restriction of `kvE2_sepBody` — reuse Phase 7's def if landed); no interleaving enumeration.
Est. 40-80 lines. Verification: build green, non-vacuity analog, litmus/no-nesting audits.
Commit: `task 321 phase 11 (N2-A): singleton carrier wrapper`.

#### N2-B: Singleton extraction + O4-at-minimum-size + both directions

O3 collapses to the landed per-σ extraction machinery (`kvE_sub2V_bounded_anchor_of_outer`
`SubBracket2V.lean:1182`; `kvE_subBracket2V_sound_of_outer` `:1216` as the assembled shape).
O4 remains — but over ONE σ against σ's OWN segments, the configuration the landed `_of_outer`
closers already handle for the pin-spliced shape. Then O5/O6 both directions with negatives via
D3 coverage. Est. 120-200 lines. Verification: as Phase 11.
Commit: `task 321 phase 11 (N2-B): singleton extraction + hgate + both directions`.

#### N2-C: Gate wrapper restricted to the fragment

```lean
theorem kvE2_sepBody_correct_singleton … :
  ∀ qnf, (∀ σ σ', qnf.2 σ = true → qnf.2 σ' = true → σ = σ') → (gate biconditional for qnf)
```
Atom layer per D2 (re-derive additively). Est. 40-70 lines. Phase 13 (F4) then runs unchanged —
the F4 counterexample is a single-σ discriminator, so the adversarial gate remains meaningful
against N2, and the verdict record states the fragment scope explicitly.
Commit: `task 321 phase 12 (N2-C): singleton gate wrapper`.

## Appendix — Fallback N1: interior+boundary fragment (Phase-11-local narrowing on exterior overrun)

Restriction predicate (report 07 §5.2):

```lean
def interiorBoundaryOnly {sig} (σ : NormalForm sig 1 4) : Prop :=
  ∀ χ : NormalForm sig 0 1,
    σ.2 (nf0_assemble zPastX χ σ.1) = false ∧ σ.2 (nf0_assemble zFutT χ σ.1) = false

theorem kvE2_sepBody_correct_interiorBoundary … :
  ∀ qnf, (∀ σ, qnf.2 σ = true → interiorBoundaryOnly σ) → (gate biconditional for qnf)
```

Drops: the exterior halves of `epL`/`epR` content (O1) and the two exterior discharger wirings
(`zPastX`/`zFutT` consumers) in O5/O6. Keeps: everything else unchanged — N1 does NOT dodge O4,
so it is valid only after an O4 PASS. Saves ~100-150 lines. The verdict record (Phase 13)
states the fragment scope; exterior-navigated completeness defers to a follow-up task.
